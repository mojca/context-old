if not modules then modules = { } end modules ['char-utf'] = {
    version   = 1.001,
    comment   = "companion to char-ini.tex",
    author    = "Hans Hagen, PRAGMA-ADE, Hasselt NL",
    copyright = "PRAGMA ADE / ConTeXt Development Team",
    license   = "see context related readme files"
}

--[[ldx--
<p>When a sequence of <l n='utf'/> characters enters the application, it may
be neccessary to collapse subsequences into their composed variant.</p>

<p>This module implements methods for collapsing and expanding <l n='utf'/>
sequences. We also provide means to deal with characters that are
special to <l n='tex'/> as well as 8-bit characters that need to end up
in special kinds of output (for instance <l n='pdf'/>).</p>

<p>We implement these manipulations as filters. One can run multiple filters
over a string.</p>
--ldx]]--

utf = utf or unicode.utf8

characters              = characters              or { }
characters.graphemes    = characters.graphemes    or { }
characters.filters      = characters.filters      or { }
characters.filters.utf  = characters.filters.utf  or { }

characters.filters.utf.initialized = false
characters.filters.utf.collapsing  = true
characters.filters.utf.expanding   = true

--[[ldx--
<p>It only makes sense to collapse at runtime, since we don't expect
source code to depend on collapsing:</p>

<typing>
characters.filters.utf.collapsing = true
input.filters.utf_translator      = characters.filters.utf.collapse
</typing>
--ldx]]--

function characters.filters.utf.initialize()
    if characters.filters.utf.collapsing and not characters.filters.utf.initialized then
        characters.graphemes = { }
        local cg = characters.graphemes
        local uc = utf.char
        for k,v in pairs(characters.data) do
            -- using vs and first testing for length is faster (.02->.01 s)
            local vs = v.specials
            if vs and #vs == 3 and vs[1] == 'char' then
                local first, second = uc(vs[2]), uc(vs[3])
                if not cg[first] then
                    cg[first] = { }
                end
                cg[first][second] = uc(k)
            end
        end
        characters.filters.utf.initialized = true
    end
end

function characters.filters.utf.collapse(str)
    if characters.filters.utf.collapsing and str and #str > 1 then
        if not characters.filters.utf.initialized then -- saves a call
            characters.filters.utf.initialize()
        end
        local tokens, first, done = { }, false, false
        local cg = characters.graphemes
        for second in string.utfcharacters(str) do
            local cgf = cg[first]
            if cgf and cgf[second] then
                first, done = cgf[second], true
            elseif first then
                tokens[#tokens+1] = first
                first = second
            else
                first = second
            end
        end
        if done then
            tokens[#tokens+1] = first
            return table.concat(tokens,"")
        end
    end
    return str
end

--[[ldx--
<p>In order to deal with 8-bit output, we need to find a way to
go from <l n='utf'/> to 8-bit. This is handled in the
<l n='luatex'/> engine itself.</p>

<p>This leaves us problems with characters that are specific to
<l n='tex'/> like <type>{}</type>, <type>$</type> and alike.</p>

<p>We can remap some chars that tex input files are sensitive for to
a private area (while writing to a utility file) and revert then
to their original slot when we read in such a file. Instead of
reverting, we can (when we resolve characters to glyphs) map them
to their right glyph there.</p>

<p>For this purpose we can use the private planes 0x0F0000 and
0x100000.</p>
--ldx]]--

characters.filters.utf.private      = { }
characters.filters.utf.private.high = { }
characters.filters.utf.private.low  = { }

do

    local ub, uc, ug = utf.byte, utf.char, utf.gsub
    local cfup = characters.filters.utf.private

    function characters.filters.utf.private.set(ch)
        local cb = ub(ch)
        if cb < 256 then
            cfup.low[ch] = uc(0x0F0000 + cb)
            cfup.high[uc(0x0F0000 + cb)] = ch
        end
    end

    function characters.filters.utf.private.replace(str)
        ug("(.)", cfup.low)
    end

    function characters.filters.utf.private.revert(str)
        ug("(.)", cfup.high)
    end

    for _, ch in ipairs({ '~', '#', '$', '%', '^', '&', '_', '{', '}' }) do
        cfup.set(ch)
    end

end

--[[ldx--
<p>We get a more efficient variant of this when we integrate
replacements in collapser. This more or less renders the previous
private code redundant. The following code is equivalent but the
first snippet uses the relocated dollars.</p>

<typing>
[󰀤x󰀤] [$x$]
</typing>
--ldx]]--

do

    local cg = characters.graphemes
    local cr = characters.filters.utf.private.high

    function characters.filters.utf.collapse(str)
        if characters.filters.utf.collapsing and str then
            if #str > 1 then
                if not characters.filters.utf.initialized then -- saves a call
                    characters.filters.utf.initialize()
                end
                local tokens, first, done = { }, false, false
                for second in string.utfcharacters(str) do
                    if cr[second] then
                        if first then
                            tokens[#tokens+1] = first
                        end
                        first, done = cr[second], true
                    else
                        local cgf = cg[first]
                        if cgf and cgf[second] then
                            first, done = cgf[second], true
                        elseif first then
                            tokens[#tokens+1] = first
                            first = second
                        else
                            first = second
                        end
                    end
                end
                if done then
                    tokens[#tokens+1] = first
                    return table.concat(tokens,"")
                end
            elseif #str > 0 then
                return cr[str] or str
            end
        end
        return str
    end

end

--[[ldx--
<p>In the beginning of <l n='luatex'/> we experimented with a sequence
of filters so that we could manipulate the input stream. However, since
this is a partial solution (not taking macro expansion into account)
and since it may interfere with non-text, we will not use this feature
by default.</p>

<typing>
characters.filters.utf.collapsing = true
characters.filters.append(characters.filters.utf.collapse)
characters.filters.activated = true
callback.register('process_input_buffer', characters.filters.process)
</typing>

<p>The following helper functions may disappear (or become optional)
in the future. Well, they are now.</p>
--ldx]]--

--[[obsolete--

characters.filters.sequences = characters.filters.sequences or { }
characters.filters.activated = false

function characters.filters.append(name)
    table.insert(characters.filters.sequences,name)
end

function characters.filters.prepend(name)
    table.insert(characters.filters.sequences,1,name)
end

function characters.filters.remove(name)
    for k,v in ipairs(characters.filters.sequences) do
        if v == name then
            table.remove(characters.filters.sequences,k)
        end
    end
end

function characters.filters.replace(name_1,name_2)
    for k,v in ipairs(characters.filters.sequences) do
        if v == name_1 then
            characters.filters.sequences[k] = name_2
            break
        end
    end
end

function characters.filters.insert_before(name_1,name_2)
    for k,v in ipairs(characters.filters.sequences) do
        if v == name_1 then
            table.insert(characters.filters.sequences,k,name_2)
            break
        end
    end
end

function characters.filters.insert_after(name_1,name_2)
    for k,v in ipairs(characters.filters.sequences) do
        if v == name_1 then
            table.insert(characters.filters.sequences,k+1,name_2)
            break
        end
    end
end

function characters.filters.list(separator)
    table.concat(characters.filters.sequences,seperator or ' ')
end

function characters.filters.process(str)
    if characters.filters.activated then
        for _,v in ipairs(characters.filters.sequences) do
            str = v(str)
        end
        return str
    else
        return nil -- luatex callback optimalisation
    end
end

--obsolete]]--

--[[ldx--
<p>The following code is no longer needed and replaced by token
collectors somehwere else.</p>
--ldx]]--

--[[obsolete--

characters.filters.collector            = { }
characters.filters.collector.data       = { }
characters.filters.collector.collecting = false

function characters.filters.collector.reset()
    characters.filters.collector.data = { }
end

function characters.filters.collector.flush(separator)
    tex.sprint(table.concat(characters.filters.collector.data,separator))
end

function characters.filters.collector.prune(n)
    for i=1,n do
        table.remove(characters.filters.collector.data,-1)
    end
end

function characters.filters.collector.numerate(str)
    if characters.filters.collector.collecting then
        table.insert(characters.filters.collector.data,(unicode.utf8.gsub(str,"(.)", function(c)
            return string.format("0x%04X ",unicode.utf8.byte(c))
        end)))
    end
    return str
end

--obsolete]]--
