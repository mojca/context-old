if not modules then modules = { } end modules ['sort-ini'] = {
    version   = 1.001,
    comment   = "companion to sort-ini.mkiv",
    author    = "Hans Hagen, PRAGMA-ADE, Hasselt NL",
    copyright = "PRAGMA ADE / ConTeXt Development Team",
    license   = "see context related readme files"
}

-- It took a while to get there, but with Fleetwood Mac's "Don't Stop"
-- playing in the background we sort of got it done.

--[[<p>The code here evolved from the rather old mkii approach. There
we concatinate the key and (raw) entry into a new string. Numbers and
special characters get some treatment so that they sort ok. In
addition some normalization (lowercasing, accent stripping) takes
place and again data is appended ror prepended. Eventually these
strings are sorted using a regular string sorter. The relative order
of character is dealt with by weighting them. It took a while to
figure this all out but eventually it worked ok for most languages,
given that the right datatables were provided.</p>

<p>Here we do follow a similar approach but this time we don't append
the manipulated keys and entries but create tables for each of them
with entries being tables themselves having different properties. In
these tables characters are represented by numbers and sorting takes
place using these numbers. Strings are simplified using lowercasing
as well as shape codes. Numbers are filtered and after getting an offset
they end up at the right end of the spectrum (more clever parser will
be added some day). There are definitely more solutions to the problem
and it is a nice puzzle to solve.</p>

<p>In the future more methods can be added, as there is practically no
limit to what goes into the tables. For that we will provide hooks.</p>

<p>Todo: decomposition with specific order of accents, this is
relatively easy to do.</p>

<p>Todo: investigate what standards and conventions there are and see
how they map onto this mechanism. I've learned that users can come up
with any demand so nothing here is frozen.</p>

<p>In the future index entries will become more clever, i.e. they will
have language etc properties that then can be used.</p>
]]--

local gsub, rep, sub, sort, concat = string.gsub, string.rep, string.sub, table.sort, table.concat
local utfbyte, utfchar, utfcharacters, utfvalues = utf.byte, utf.char, utf.characters, utf.values
local next, type, tonumber, rawget, rawset = next, type, tonumber, rawget, rawset

local allocate          = utilities.storage.allocate
local setmetatableindex = table.setmetatableindex

local trace_tests       = false  trackers.register("sorters.tests",   function(v) trace_tests   = v end)
local trace_methods     = false  trackers.register("sorters.methods", function(v) trace_methods = v end)

local report_sorters    = logs.reporter("languages","sorters")

local comparers         = { }
local splitters         = { }
local definitions       = allocate()
local tracers           = allocate()
local ignoredoffset     = 0x10000 -- frozen
local replacementoffset = 0x10000 -- frozen
local digitsoffset      = 0x20000 -- frozen
local digitsmaximum     = 0xFFFFF -- frozen

local lccodes           = characters.lccodes
local lcchars           = characters.lcchars
local shchars           = characters.shchars
local fscodes           = characters.fscodes
local fschars           = characters.fschars

local decomposed        = characters.decomposed

local variables         = interfaces.variables

local v_numbers         = variables.numbers
local v_default         = variables.default
local v_before          = variables.before
local v_after           = variables.after
local v_first           = variables.first
local v_last            = variables.last

local validmethods      = table.tohash {
 -- "ch", -- raw character
    "mm", -- minus mapping
    "zm", -- zero  mapping
    "pm", -- plus  mapping
    "mc", -- lower case - 1
    "zc", -- lower case
    "pc", -- lower case + 1
    "uc", -- unicode
}

local predefinedmethods = {
    [v_default] = "zc,pc,zm,pm,uc",
    [v_before]  = "mm,mc,uc",
    [v_after]   = "pm,mc,uc",
    [v_first]   = "pc,mm,uc",
    [v_last]    = "mc,mm,uc",
}

sorters = {
    comparers   = comparers,
    splitters   = splitters,
    definitions = definitions,
    tracers     = tracers,
    constants   = {
        ignoredoffset     = ignoredoffset,
        replacementoffset = replacementoffset,
        digitsoffset      = digitsoffset,
        digitsmaximum     = digitsmaximum,
        defaultlanguage   = v_default,
        defaultmethod     = v_default,
        defaultdigits     = v_numbers,
    }
}

local sorters   = sorters
local constants = sorters.constants

local data, language, method, digits
local replacements, m_mappings, z_mappings, p_mappings, entries, orders, lower, upper, method, sequence
local thefirstofsplit

local mte = {
    __index = function(t,k)
        if k ~= "" and utfbyte(k) < digitsoffset then
            local el
            if k then
                local l = lower[k] or lcchars[k]
                el = rawget(t,l)
            end
            if not el then
                local l = shchars[k]
                if l and l ~= k then
                    if #l > 1 then
                        l = sub(l,1,1) -- todo
                    end
                    el = rawget(t,l)
                    if not el then
                        l = lower[k] or lcchars[l]
                        if l then
                            el = rawget(t,l)
                        end
                    end
                end
                el = el or k
            end
        --  rawset(t,k,el) also make a copy?
            return el
        end
    end
}

local noorder = false

local function preparetables(data)
    local orders, lower, m_mappings, z_mappings, p_mappings = data.orders, data.lower, { }, { }, { }
    for i=1,#orders do
        local oi = orders[i]
        local n = { 2 * i }
        m_mappings[oi], z_mappings[oi], p_mappings[oi] = n, n, n
    end
    local mtm = {
        __index = function(t,k)
            local n, nn
            if k then
                if trace_tests then
                    report_sorters("simplifing character %C",k)
                end
                local l = lower[k] or lcchars[k]
                if l then
                    if trace_tests then
                        report_sorters(" 1 lower: %C",l)
                    end
                    local ml = rawget(t,l)
                    if ml then
                        n = { }
                        nn = 0
                        for i=1,#ml do
                            nn = nn + 1
                            n[nn] = ml[i] + (t.__delta or 0)
                        end
                        if trace_tests then
                            report_sorters(" 2 order: % t",n)
                        end
                    end
                end
                if not n then
                    local s = shchars[k] -- maybe all components?
                    if s and s ~= k then
                        if trace_tests then
                            report_sorters(" 3 shape: %C",s)
                        end
                        n = { }
                        nn = 0
                        for l in utfcharacters(s) do
                            local ml = rawget(t,l)
                            if ml then
                                if trace_tests then
                                    report_sorters(" 4 keep: %C",l)
                                end
                                if ml then
                                    for i=1,#ml do
                                        nn = nn + 1
                                        n[nn] = ml[i]
                                    end
                                end
                            else
                                l = lower[l] or lcchars[l]
                                if l then
                                    if trace_tests then
                                        report_sorters(" 5 lower: %C",l)
                                    end
                                    local ml = rawget(t,l)
                                    if ml then
                                        for i=1,#ml do
                                            nn = nn + 1
                                            n[nn] = ml[i] + (t.__delta or 0)
                                        end
                                    end
                                end
                            end
                        end
                    else
                     -- -- we probably never enter this branch
                     -- -- fschars returns a single char
                     --
                     -- s = fschars[k]
                     -- if s and s ~= k then
                     --     if trace_tests then
                     --         report_sorters(" 6 split: %s",s)
                     --     end
                     --     local ml = rawget(t,s)
                     --     if ml then
                     --         n = { }
                     --         nn = 0
                     --         for i=1,#ml do
                     --             nn = nn + 1
                     --             n[nn] = ml[i]
                     --         end
                     --     end
                     -- end
                        local b = utfbyte(k)
                        n = decomposed[b] or { b }
                        if trace_tests then
                            report_sorters(" 6 split: %s",utf.tostring(b)) -- todo
                        end
                    end
                    if n then
                        if trace_tests then
                            report_sorters(" 7 order: % t",n)
                        end
                    else
                        n = noorder
                        if trace_tests then
                            report_sorters(" 8 order: 0")
                        end
                    end
                end
            else
                n = noorder
                if trace_tests then
                    report_sorters(" 9 order: 0")
                end
            end
            rawset(t,k,n)
            return n
        end
    }
    data.m_mappings = m_mappings
    data.z_mappings = z_mappings
    data.p_mappings = p_mappings
    m_mappings.__delta = -1
    z_mappings.__delta =  0
    p_mappings.__delta =  1
    setmetatable(data.entries,mte)
    setmetatable(data.m_mappings,mtm)
    setmetatable(data.z_mappings,mtm)
    setmetatable(data.p_mappings,mtm)
    thefirstofsplit = data.firstofsplit
end

local function update() -- prepare parent chains, needed when new languages are added
    for language, data in next, definitions do
        local parent = data.parent or "default"
        if language ~= "default" then
            setmetatableindex(data,definitions[parent] or definitions.default)
        end
        data.language   = language
        data.parent     = parent
        data.m_mappings = { } -- free temp data
        data.z_mappings = { } -- free temp data
        data.p_mappings = { } -- free temp data
    end
end

local function setlanguage(l,m,d,u)
    language = (l ~= "" and l) or constants.defaultlanguage
    data = definitions[language or constants.defaultlanguage] or definitions[constants.defaultlanguage]
    method    = (m ~= "" and m) or data.method    or constants.defaultmethod
    digits    = (d ~= "" and d) or data.digits    or constants.defaultdigits
    if trace_tests then
        report_sorters("setting language %a, method %a, digits %a",language,method,digits)
    end
    replacements = data.replacements
    entries      = data.entries
    orders       = data.orders
    lower        = data.lower
    upper        = data.upper
    preparetables(data)
    m_mappings   = data.m_mappings
    z_mappings   = data.z_mappings
    p_mappings   = data.p_mappings
    --
    method = predefinedmethods[variables[method]] or method
    data.method  = method
    --
    data.digits  = digits
    --
    local seq = utilities.parsers.settings_to_array(method or "") -- check the list
    sequence = { }
    local nofsequence = 0
    for i=1,#seq do
        local s = seq[i]
        if validmethods[s] then
            nofsequence = nofsequence + 1
            sequence[nofsequence] = s
        else
            report_sorters("invalid sorter method %a in %a",s,method)
        end
    end
    data.sequence = sequence
    if trace_tests then
        report_sorters("using sort sequence: % t",sequence)
    end
    --
    return data
end

function sorters.update()
    update()
    setlanguage(language,method,numberorder) -- resync current language and method
end

function sorters.setlanguage(language,method,numberorder)
    update()
    setlanguage(language,method,numberorder) -- new language and method
end

-- tricky: { 0, 0, 0 } vs { 0, 0, 0, 0 } => longer wins and mm, pm, zm can have them

local function basicsort(sort_a,sort_b)
    if sort_a and sort_b then
        local na = #sort_a
        local nb = #sort_b
        if na > nb then
            na = nb
        end
        for i=1,na do
            local ai, bi = sort_a[i], sort_b[i]
            if ai > bi then
                return  1
            elseif ai < bi then
                return -1
            end
        end
    end
    return 0
end

function comparers.basic(a,b) -- trace ea and eb
    local ea, eb = a.split, b.split
    local na, nb = #ea, #eb
    if na == 0 and nb == 0 then
        -- simple variant (single word)
        local result = 0
        for j=1,#sequence do
            local m = sequence[j]
            result = basicsort(ea[m],eb[m])
            if result ~= 0 then
                return result
            end
        end
        if result == 0 then
            local la, lb = #ea.uc, #eb.uc
            if la > lb then
                return 1
            elseif lb > la then
                return -1
            else
                return 0
            end
        else
            return result
        end
    else
        -- complex variant, used in register (multiple words)
        local result = 0
        for i=1,nb < na and nb or na do
            local eai, ebi = ea[i], eb[i]
            for j=1,#sequence do
                local m = sequence[j]
                result = basicsort(eai[m],ebi[m])
                if result ~= 0 then
                    return result
                end
            end
            if result == 0 then
                local la, lb = #eai.uc, #ebi.uc
                if la > lb then
                    return 1
                elseif lb > la then
                    return -1
                end
            else
                return result
            end
        end
        if result ~= 0 then
            return result
        elseif na > nb then
            return 1
        elseif nb > na then
            return -1
        else
            return 0
        end
    end
end

local function numify(s)
    s = digitsoffset + tonumber(s) -- alternatively we can create range
    if s > digitsmaximum then
        s = digitsmaximum
    end
    return utfchar(s)
end

function sorters.strip(str) -- todo: only letters and such
    if str and str ~= "" then
        -- todo: make a decent lpeg
        str = gsub(str,"\\[\"\'~^`]*","") -- \"e -- hm, too greedy
        str = gsub(str,"\\%S*","") -- the rest
        str = gsub(str,"%s","\001") -- can be option
        str = gsub(str,"[%s%[%](){}%$\"\']*","")
        if digits == v_numbers then
            str = gsub(str,"(%d+)",numify) -- sort numbers properly
        end
        return str
    else
        return ""
    end
end

local function firstofsplit(entry)
    -- numbers are left padded by spaces
    local split = entry.split
    if #split > 0 then
        split = split[1].ch
    else
        split = split.ch
    end
    local first = split and split[1] or ""
    if thefirstofsplit then
        return thefirstofsplit(first,data,entry) -- normally the first one is needed
    else
        return first, entries[first] or "\000" -- tag
    end
end

sorters.firstofsplit = firstofsplit

-- for the moment we use an inefficient bunch of tables but once
-- we know what combinations make sense we can optimize this

function splitters.utf(str) -- we could append m and u but this is cleaner, s is for tracing
    if #replacements > 0 then
        -- todo make an lpeg for this
        for k=1,#replacements do
            local v = replacements[k]
            str = gsub(str,v[1],v[2])
        end
    end
    local m_case, z_case, p_case, m_mapping, z_mapping, p_mapping, char, byte, n = { }, { }, { }, { }, { }, { }, { }, { }, 0
    local nm, nz, np = 0, 0, 0
    for sc in utfcharacters(str) do
        local b = utfbyte(sc)
        if b >= digitsoffset then
            if n == 0 then
                -- we need to force number to the top
                z_case[1] = 0
                m_case[1] = 0
                p_case[1] = 0
                char[1] = sc
                byte[1] = 0
                m_mapping[1] = 0
                z_mapping[1] = 0
                p_mapping[1] = 0
                n = 2
            else
                n = n + 1
            end
            z_case[n] = b
            m_case[n] = b
            p_case[n] = b
            char[n] = sc
            byte[n] = b
            nm = nm + 1
            nz = nz + 1
            np = np + 1
            m_mapping[nm] = b
            z_mapping[nz] = b
            p_mapping[np] = b
        else
            n = n + 1
            local l = lower[sc]
            l = l and utfbyte(l) or lccodes[b]
            if type(l) == "table" then
                l = l[1] -- there are currently no tables in lccodes but it can be some, day
            end
            z_case[n] = l
            if l ~= b then
                m_case[n] = l - 1
                p_case[n] = l + 1
            else
                m_case[n] = l
                p_case[n] = l
            end
            char[n], byte[n] = sc, b
            local fs = fscodes[b] or b
            local msc = m_mappings[sc]
            if msc ~= noorder then
                if not msc then
                    msc = m_mappings[fs]
                end
                for i=1,#msc do
                    nm = nm + 1
                    m_mapping[nm] = msc[i]
                end
            end
            local zsc = z_mappings[sc]
            if zsc ~= noorder then
                if not zsc then
                    zsc = z_mappings[fs]
                end
                for i=1,#zsc do
                    nz = nz + 1
                    z_mapping[nz] = zsc[i]
                end
            end
            local psc = p_mappings[sc]
            if psc ~= noorder then
                if not psc then
                    psc = p_mappings[fs]
                end
                for i=1,#psc do
                    np = np + 1
                    p_mapping[np] = psc[i]
                end
            end
        end
    end
    -- -- only those needed that are part of a sequence
    --
    -- local b = byte[1]
    -- if b then
    --     -- we set them to the first split code (korean)
    --     local fs = fscodes[b] or b
    --     if #m_mapping == 0 then
    --         m_mapping = { m_mappings[fs][1] }
    --     end
    --     if #z_mapping == 0 then
    --         z_mapping = { z_mappings[fs][1] }
    --     end
    --     if #p_mapping == 0 then
    --         p_mapping = { p_mappings[fs][1] }
    --     end
    -- end
    local t = {
        ch = char,
        uc = byte,
        mc = m_case,
        zc = z_case,
        pc = p_case,
        mm = m_mapping,
        zm = z_mapping,
        pm = p_mapping,
    }

    return t
end

local function packch(entry)
    local split = entry.split
    if #split > 0 then -- useless test
        local t = { }
        for i=1,#split do
            local tt, li = { }, split[i].ch
            for j=1,#li do
                local lij = li[j]
                tt[j] = utfbyte(lij) > ignoredoffset and "[]" or lij
            end
            t[i] = concat(tt)
        end
        return concat(t," + ")
    else
        local t, li = { }, split.ch
        for j=1,#li do
            local lij = li[j]
            t[j] = utfbyte(lij) > ignoredoffset and "[]" or lij
        end
        return concat(t)
    end
end

local function packuc(entry)
    local split = entry.split
    if #split > 0 then -- useless test
        local t = { }
        for i=1,#split do
            t[i] = concat(split[i].uc, " ")
        end
        return concat(t," + ")
    else
        return concat(split.uc," ")
    end
end

function sorters.sort(entries,cmp)
    if trace_tests or trace_methods then
        local nofentries = #entries
        report_sorters("entries: %s, language: %s, method: %s, digits: %s",nofentries,language,method,tostring(digits))
        for i=1,nofentries do
            report_sorters("entry %s",table.serialize(entries[i].split,i,true,true,true))
        end
    end
    if trace_tests then
        sort(entries,function(a,b)
            local r = cmp(a,b)
            local e = (not r and "?") or (r<0 and "<") or (r>0 and ">") or "="
            report_sorters("%s %s %s | %s %s %s",packch(a),e,packch(b),packuc(a),e,packuc(b))
            return r == -1
        end)
        local s
        for i=1,#entries do
            local entry = entries[i]
            local letter, first = firstofsplit(entry)
            if first == s then
                first = "  "
            else
                s = first
                report_sorters(">> %C (%C)",first,letter)
            end
            report_sorters("   %s | %s",packch(entry),packuc(entry))
        end
    else
        sort(entries,function(a,b)
            return cmp(a,b) == -1
        end)
    end
end
