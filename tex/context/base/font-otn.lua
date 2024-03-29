if not modules then modules = { } end modules ['font-otn'] = {
    version   = 1.001,
    comment   = "companion to font-ini.mkiv",
    author    = "Hans Hagen, PRAGMA-ADE, Hasselt NL",
    copyright = "PRAGMA ADE / ConTeXt Development Team",
    license   = "see context related readme files",
}

-- preprocessors = { "nodes" }

-- this is still somewhat preliminary and it will get better in due time;
-- much functionality could only be implemented thanks to the husayni font
-- of Idris Samawi Hamid to who we dedicate this module.

-- in retrospect it always looks easy but believe it or not, it took a lot
-- of work to get proper open type support done: buggy fonts, fuzzy specs,
-- special made testfonts, many skype sessions between taco, idris and me,
-- torture tests etc etc ... unfortunately the code does not show how much
-- time it took ...

-- todo:
--
-- kerning is probably not yet ok for latin around dics nodes
-- extension infrastructure (for usage out of context)
-- sorting features according to vendors/renderers
-- alternative loop quitters
-- check cursive and r2l
-- find out where ignore-mark-classes went
-- default features (per language, script)
-- handle positions (we need example fonts)
-- handle gpos_single (we might want an extra width field in glyph nodes because adding kerns might interfere)
-- mark (to mark) code is still not what it should be (too messy but we need some more extreem husayni tests)
-- remove some optimizations (when I have a faster machine)


--[[ldx--
<p>This module is a bit more split up that I'd like but since we also want to test
with plain <l n='tex'/> it has to be so. This module is part of <l n='context'/>
and discussion about improvements and functionality mostly happens on the
<l n='context'/> mailing list.</p>

<p>The specification of OpenType is kind of vague. Apart from a lack of a proper
free specifications there's also the problem that Microsoft and Adobe
may have their own interpretation of how and in what order to apply features.
In general the Microsoft website has more detailed specifications and is a
better reference. There is also some information in the FontForge help files.</p>

<p>Because there is so much possible, fonts might contain bugs and/or be made to
work with certain rederers. These may evolve over time which may have the side
effect that suddenly fonts behave differently.</p>

<p>After a lot of experiments (mostly by Taco, me and Idris) we're now at yet another
implementation. Of course all errors are mine and of course the code can be
improved. There are quite some optimizations going on here and processing speed
is currently acceptable. Not all functions are implemented yet, often because I
lack the fonts for testing. Many scripts are not yet supported either, but I will
look into them as soon as <l n='context'/> users ask for it.</p>

<p>Because there are different interpretations possible, I will extend the code
with more (configureable) variants. I can also add hooks for users so that they can
write their own extensions.</p>

<p>Glyphs are indexed not by unicode but in their own way. This is because there is no
relationship with unicode at all, apart from the fact that a font might cover certain
ranges of characters. One character can have multiple shapes. However, at the
<l n='tex'/> end we use unicode so and all extra glyphs are mapped into a private
space. This is needed because we need to access them and <l n='tex'/> has to include
then in the output eventually.</p>

<p>The raw table as it coms from <l n='fontforge'/> gets reorganized in to fit out needs.
In <l n='context'/> that table is packed (similar tables are shared) and cached on disk
so that successive runs can use the optimized table (after loading the table is
unpacked). The flattening code used later is a prelude to an even more compact table
format (and as such it keeps evolving).</p>

<p>This module is sparsely documented because it is a moving target. The table format
of the reader changes and we experiment a lot with different methods for supporting
features.</p>

<p>As with the <l n='afm'/> code, we may decide to store more information in the
<l n='otf'/> table.</p>

<p>Incrementing the version number will force a re-cache. We jump the number by one
when there's a fix in the <l n='fontforge'/> library or <l n='lua'/> code that
results in different tables.</p>
--ldx]]--

-- action                    handler     chainproc             chainmore              comment
--
-- gsub_single               ok          ok                    ok
-- gsub_multiple             ok          ok                    not implemented yet
-- gsub_alternate            ok          ok                    not implemented yet
-- gsub_ligature             ok          ok                    ok
-- gsub_context              ok          --
-- gsub_contextchain         ok          --
-- gsub_reversecontextchain  ok          --
-- chainsub                  --          ok
-- reversesub                --          ok
-- gpos_mark2base            ok          ok
-- gpos_mark2ligature        ok          ok
-- gpos_mark2mark            ok          ok
-- gpos_cursive              ok          untested
-- gpos_single               ok          ok
-- gpos_pair                 ok          ok
-- gpos_context              ok          --
-- gpos_contextchain         ok          --
--
-- todo: contextpos and contextsub and class stuff
--
-- actions:
--
-- handler   : actions triggered by lookup
-- chainproc : actions triggered by contextual lookup
-- chainmore : multiple substitutions triggered by contextual lookup (e.g. fij -> f + ij)
--
-- remark: the 'not implemented yet' variants will be done when we have fonts that use them
-- remark: we need to check what to do with discretionaries

-- We used to have independent hashes for lookups but as the tags are unique
-- we now use only one hash. If needed we can have multiple again but in that
-- case I will probably prefix (i.e. rename) the lookups in the cached font file.

-- Todo: make plugin feature that operates on char/glyphnode arrays

local concat, insert, remove = table.concat, table.insert, table.remove
local gmatch, gsub, find, match, lower, strip = string.gmatch, string.gsub, string.find, string.match, string.lower, string.strip
local type, next, tonumber, tostring = type, next, tonumber, tostring
local lpegmatch = lpeg.match
local random = math.random
local formatters = string.formatters

local logs, trackers, nodes, attributes = logs, trackers, nodes, attributes

local registertracker = trackers.register

local fonts = fonts
local otf   = fonts.handlers.otf

local trace_lookups      = false  registertracker("otf.lookups",      function(v) trace_lookups      = v end)
local trace_singles      = false  registertracker("otf.singles",      function(v) trace_singles      = v end)
local trace_multiples    = false  registertracker("otf.multiples",    function(v) trace_multiples    = v end)
local trace_alternatives = false  registertracker("otf.alternatives", function(v) trace_alternatives = v end)
local trace_ligatures    = false  registertracker("otf.ligatures",    function(v) trace_ligatures    = v end)
local trace_contexts     = false  registertracker("otf.contexts",     function(v) trace_contexts     = v end)
local trace_marks        = false  registertracker("otf.marks",        function(v) trace_marks        = v end)
local trace_kerns        = false  registertracker("otf.kerns",        function(v) trace_kerns        = v end)
local trace_cursive      = false  registertracker("otf.cursive",      function(v) trace_cursive      = v end)
local trace_preparing    = false  registertracker("otf.preparing",    function(v) trace_preparing    = v end)
local trace_bugs         = false  registertracker("otf.bugs",         function(v) trace_bugs         = v end)
local trace_details      = false  registertracker("otf.details",      function(v) trace_details      = v end)
local trace_applied      = false  registertracker("otf.applied",      function(v) trace_applied      = v end)
local trace_steps        = false  registertracker("otf.steps",        function(v) trace_steps        = v end)
local trace_skips        = false  registertracker("otf.skips",        function(v) trace_skips        = v end)
local trace_directions   = false  registertracker("otf.directions",   function(v) trace_directions   = v end)

local report_direct   = logs.reporter("fonts","otf direct")
local report_subchain = logs.reporter("fonts","otf subchain")
local report_chain    = logs.reporter("fonts","otf chain")
local report_process  = logs.reporter("fonts","otf process")
local report_prepare  = logs.reporter("fonts","otf prepare")
local report_warning  = logs.reporter("fonts","otf warning")

registertracker("otf.verbose_chain", function(v) otf.setcontextchain(v and "verbose") end)
registertracker("otf.normal_chain",  function(v) otf.setcontextchain(v and "normal")  end)

registertracker("otf.replacements", "otf.singles,otf.multiples,otf.alternatives,otf.ligatures")
registertracker("otf.positions","otf.marks,otf.kerns,otf.cursive")
registertracker("otf.actions","otf.replacements,otf.positions")
registertracker("otf.injections","nodes.injections")

registertracker("*otf.sample","otf.steps,otf.actions,otf.analyzing")

local insert_node_after  = node.insert_after
local delete_node        = nodes.delete
local copy_node          = node.copy
local find_node_tail     = node.tail or node.slide
local flush_node_list    = node.flush_list
local end_of_math        = node.end_of_math

local setmetatableindex  = table.setmetatableindex

local zwnj               = 0x200C
local zwj                = 0x200D
local wildcard           = "*"
local default            = "dflt"

local nodecodes          = nodes.nodecodes
local whatcodes          = nodes.whatcodes
local glyphcodes         = nodes.glyphcodes

local glyph_code         = nodecodes.glyph
local glue_code          = nodecodes.glue
local disc_code          = nodecodes.disc
local whatsit_code       = nodecodes.whatsit
local math_code          = nodecodes.math

local dir_code           = whatcodes.dir
local localpar_code      = whatcodes.localpar

local ligature_code      = glyphcodes.ligature

local privateattribute   = attributes.private

-- Something is messed up: we have two mark / ligature indices, one at the injection
-- end and one here ... this is bases in KE's patches but there is something fishy
-- there as I'm pretty sure that for husayni we need some connection (as it's much
-- more complex than an average font) but I need proper examples of all cases, not
-- of only some.

local a_state            = privateattribute('state')
local a_markbase         = privateattribute('markbase')
local a_markmark         = privateattribute('markmark')
local a_markdone         = privateattribute('markdone') -- assigned at the injection end
local a_cursbase         = privateattribute('cursbase')
local a_curscurs         = privateattribute('curscurs')
local a_cursdone         = privateattribute('cursdone')
local a_kernpair         = privateattribute('kernpair')
local a_ligacomp         = privateattribute('ligacomp') -- assigned here (ideally it should be combined)

local injections         = nodes.injections
local setmark            = injections.setmark
local setcursive         = injections.setcursive
local setkern            = injections.setkern
local setpair            = injections.setpair

local markonce           = true
local cursonce           = true
local kernonce           = true

local fonthashes         = fonts.hashes
local fontdata           = fonthashes.identifiers

local otffeatures        = fonts.constructors.newfeatures("otf")
local registerotffeature = otffeatures.register

local onetimemessage     = fonts.loggers.onetimemessage

otf.defaultnodealternate = "none" -- first last

-- we share some vars here, after all, we have no nested lookups and less code

local tfmdata             = false
local characters          = false
local descriptions        = false
local resources           = false
local marks               = false
local currentfont         = false
local lookuptable         = false
local anchorlookups       = false
local lookuptypes         = false
local handlers            = { }
local rlmode              = 0
local featurevalue        = false

-- head is always a whatsit so we can safely assume that head is not changed

-- we use this for special testing and documentation

local checkstep       = (nodes and nodes.tracers and nodes.tracers.steppers.check)    or function() end
local registerstep    = (nodes and nodes.tracers and nodes.tracers.steppers.register) or function() end
local registermessage = (nodes and nodes.tracers and nodes.tracers.steppers.message)  or function() end

local function logprocess(...)
    if trace_steps then
        registermessage(...)
    end
    report_direct(...)
end

local function logwarning(...)
    report_direct(...)
end

local f_unicode  = formatters["%U"]
local f_uniname  = formatters["%U (%s)"]
local f_unilist  = formatters["% t (% t)"]

local function gref(n) -- currently the same as in font-otb
    if type(n) == "number" then
        local description = descriptions[n]
        local name = description and description.name
        if name then
            return f_uniname(n,name)
        else
            return f_unicode(n)
        end
    elseif n then
        local num, nam = { }, { }
        for i=1,#n do
            local ni = n[i]
            if tonumber(ni) then -- later we will start at 2
                local di = descriptions[ni]
                num[i] = f_unicode(ni)
                nam[i] = di and di.name or "-"
            end
        end
        return f_unilist(num,nam)
    else
        return "<error in node mode tracing>"
    end
end

local function cref(kind,chainname,chainlookupname,lookupname,index) -- not in the mood to alias f_
    if index then
        return formatters["feature %a, chain %a, sub %a, lookup %a, index %a"](kind,chainname,chainlookupname,lookupname,index)
    elseif lookupname then
        return formatters["feature %a, chain %a, sub %a, lookup %a"](kind,chainname,chainlookupname,lookupname)
    elseif chainlookupname then
        return formatters["feature %a, chain %a, sub %a"](kind,chainname,chainlookupname)
    elseif chainname then
        return formatters["feature %a, chain %a"](kind,chainname)
    else
        return formatters["feature %a"](kind)
    end
end

local function pref(kind,lookupname)
    return formatters["feature %a, lookup %a"](kind,lookupname)
end

-- We can assume that languages that use marks are not hyphenated. We can also assume
-- that at most one discretionary is present.

-- We do need components in funny kerning mode but maybe I can better reconstruct then
-- as we do have the font components info available; removing components makes the
-- previous code much simpler. Also, later on copying and freeing becomes easier.
-- However, for arabic we need to keep them around for the sake of mark placement
-- and indices.

local function copy_glyph(g) -- next and prev are untouched !
    local components = g.components
    if components then
        g.components = nil
        local n = copy_node(g)
        g.components = components
        return n
    else
        return copy_node(g)
    end
end

-- start is a mark and we need to keep that one

local function markstoligature(kind,lookupname,head,start,stop,char)
    if start == stop and start.char == char then
        return head, start
    else
        local prev = start.prev
        local next = stop.next
        start.prev = nil
        stop.next = nil
        local base = copy_glyph(start)
        if head == start then
            head = base
        end
        base.char = char
        base.subtype = ligature_code
        base.components = start
        if prev then
            prev.next = base
        end
        if next then
            next.prev = base
        end
        base.next = next
        base.prev = prev
        return head, base
    end
end

-- The next code is somewhat complicated by the fact that some fonts can have ligatures made
-- from ligatures that themselves have marks. This was identified by Kai in for instance
-- arabtype:  KAF LAM SHADDA ALEF FATHA (0x0643 0x0644 0x0651 0x0627 0x064E). This becomes
-- KAF LAM-ALEF with a SHADDA on the first and a FATHA op de second component. In a next
-- iteration this becomes a KAF-LAM-ALEF with a SHADDA on the second and a FATHA on the
-- third component.

local function getcomponentindex(start)
    if start.id ~= glyph_code then
        return 0
    elseif start.subtype == ligature_code then
        local i = 0
        local components = start.components
        while components do
            i = i + getcomponentindex(components)
            components = components.next
        end
        return i
    elseif not marks[start.char] then
        return 1
    else
        return 0
    end
end

local function toligature(kind,lookupname,head,start,stop,char,markflag,discfound) -- brr head
    if start == stop and start.char == char then
        start.char = char
        return head, start
    end
    local prev = start.prev
    local next = stop.next
    start.prev = nil
    stop.next = nil
    local base = copy_glyph(start)
    if start == head then
        head = base
    end
    base.char = char
    base.subtype = ligature_code
    base.components = start -- start can have components
    if prev then
        prev.next = base
    end
    if next then
        next.prev = base
    end
    base.next = next
    base.prev = prev
    if not discfound then
        local deletemarks = markflag ~= "mark"
        local components = start
        local baseindex = 0
        local componentindex = 0
        local head = base
        local current = base
        while start do
            local char = start.char
            if not marks[char] then
                baseindex = baseindex + componentindex
                componentindex = getcomponentindex(start)
            elseif not deletemarks then -- quite fishy
                start[a_ligacomp] = baseindex + (start[a_ligacomp] or componentindex)
                if trace_marks then
                    logwarning("%s: keep mark %s, gets index %s",pref(kind,lookupname),gref(char),start[a_ligacomp])
                end
                head, current = insert_node_after(head,current,copy_node(start)) -- unlikely that mark has components
            end
            start = start.next
        end
        local start = components
        while start and start.id == glyph_code do -- hm, is id test needed ?
            local char = start.char
            if marks[char] then
                start[a_ligacomp] = baseindex + (start[a_ligacomp] or componentindex)
                if trace_marks then
                    logwarning("%s: keep mark %s, gets index %s",pref(kind,lookupname),gref(char),start[a_ligacomp])
                end
            else
                break
            end
            start = start.next
        end
    end
    return head, base
end

function handlers.gsub_single(head,start,kind,lookupname,replacement)
    if trace_singles then
        logprocess("%s: replacing %s by single %s",pref(kind,lookupname),gref(start.char),gref(replacement))
    end
    start.char = replacement
    return head, start, true
end

local function get_alternative_glyph(start,alternatives,value,trace_alternatives)
    local n = #alternatives
    if value == "random" then
        local r = random(1,n)
        return alternatives[r], trace_alternatives and formatters["value %a, taking %a"](value,r)
    elseif value == "first" then
        return alternatives[1], trace_alternatives and formatters["value %a, taking %a"](value,1)
    elseif value == "last" then
        return alternatives[n], trace_alternatives and formatters["value %a, taking %a"](value,n)
    else
        value = tonumber(value)
        if type(value) ~= "number" then
            return alternatives[1], trace_alternatives and formatters["invalid value %s, taking %a"](value,1)
        elseif value > n then
            local defaultalt = otf.defaultnodealternate
            if defaultalt == "first" then
                return alternatives[n], trace_alternatives and formatters["invalid value %s, taking %a"](value,1)
            elseif defaultalt == "last" then
                return alternatives[1], trace_alternatives and formatters["invalid value %s, taking %a"](value,n)
            else
                return false, trace_alternatives and formatters["invalid value %a, %s"](value,"out of range")
            end
        elseif value == 0 then
            return start.char, trace_alternatives and formatters["invalid value %a, %s"](value,"no change")
        elseif value < 1 then
            return alternatives[1], trace_alternatives and formatters["invalid value %a, taking %a"](value,1)
        else
            return alternatives[value], trace_alternatives and formatters["value %a, taking %a"](value,value)
        end
    end
end

local function multiple_glyphs(head,start,multiple) -- marks ?
    local nofmultiples = #multiple
    if nofmultiples > 0 then
        start.char = multiple[1]
        if nofmultiples > 1 then
            local sn = start.next
            for k=2,nofmultiples do -- todo: use insert_node
                local n = copy_node(start) -- ignore components
                n.char = multiple[k]
                n.next = sn
                n.prev = start
                if sn then
                    sn.prev = n
                end
                start.next = n
                start = n
            end
        end
        return head, start, true
    else
        if trace_multiples then
            logprocess("no multiple for %s",gref(start.char))
        end
        return head, start, false
    end
end

function handlers.gsub_alternate(head,start,kind,lookupname,alternative,sequence)
    local value  = featurevalue == true and tfmdata.shared.features[kind] or featurevalue
    local choice, comment = get_alternative_glyph(start,alternative,value,trace_alternatives)
    if choice then
        if trace_alternatives then
            logprocess("%s: replacing %s by alternative %a to %s, %s",pref(kind,lookupname),gref(start.char),choice,gref(choice),comment)
        end
        start.char = choice
    else
        if trace_alternatives then
            logwarning("%s: no variant %a for %s, %s",pref(kind,lookupname),value,gref(start.char),comment)
        end
    end
    return head, start, true
end

function handlers.gsub_multiple(head,start,kind,lookupname,multiple)
    if trace_multiples then
        logprocess("%s: replacing %s by multiple %s",pref(kind,lookupname),gref(start.char),gref(multiple))
    end
    return multiple_glyphs(head,start,multiple)
end

function handlers.gsub_ligature(head,start,kind,lookupname,ligature,sequence)
    local s, stop, discfound = start.next, nil, false
    local startchar = start.char
    if marks[startchar] then
        while s do
            local id = s.id
            if id == glyph_code and s.font == currentfont and s.subtype<256 then
                local lg = ligature[s.char]
                if lg then
                    stop = s
                    ligature = lg
                    s = s.next
                else
                    break
                end
            else
                break
            end
        end
        if stop then
            local lig = ligature.ligature
            if lig then
                if trace_ligatures then
                    local stopchar = stop.char
                    head, start = markstoligature(kind,lookupname,head,start,stop,lig)
                    logprocess("%s: replacing %s upto %s by ligature %s case 1",pref(kind,lookupname),gref(startchar),gref(stopchar),gref(start.char))
                else
                    head, start = markstoligature(kind,lookupname,head,start,stop,lig)
                end
                return head, start, true
            else
                -- ok, goto next lookup
            end
        end
    else
        local skipmark = sequence.flags[1]
        while s do
            local id = s.id
            if id == glyph_code and s.subtype<256 then
                if s.font == currentfont then
                    local char = s.char
                    if skipmark and marks[char] then
                        s = s.next
                    else
                        local lg = ligature[char]
                        if lg then
                            stop = s
                            ligature = lg
                            s = s.next
                        else
                            break
                        end
                    end
                else
                    break
                end
            elseif id == disc_code then
                discfound = true
                s = s.next
            else
                break
            end
        end
        if stop then
            local lig = ligature.ligature
            if lig then
                if trace_ligatures then
                    local stopchar = stop.char
                    head, start = toligature(kind,lookupname,head, start,stop,lig,skipmark,discfound)
                    logprocess("%s: replacing %s upto %s by ligature %s case 2",pref(kind,lookupname),gref(startchar),gref(stopchar),gref(start.char))
                else
                    head, start = toligature(kind,lookupname,head, start,stop,lig,skipmark,discfound)
                end
                return head, start, true
            else
                -- ok, goto next lookup
            end
        end
    end
    return head, start, false
end

--[[ldx--
<p>We get hits on a mark, but we're not sure if the it has to be applied so
we need to explicitly test for basechar, baselig and basemark entries.</p>
--ldx]]--

function handlers.gpos_mark2base(head,start,kind,lookupname,markanchors,sequence)
    local markchar = start.char
    if marks[markchar] then
        local base = start.prev -- [glyph] [start=mark]
        if base and base.id == glyph_code and base.font == currentfont and base.subtype<256 then
            local basechar = base.char
            if marks[basechar] then
                while true do
                    base = base.prev
                    if base and base.id == glyph_code  and base.font == currentfont and base.subtype<256 then
                        basechar = base.char
                        if not marks[basechar] then
                            break
                        end
                    else
                        if trace_bugs then
                            logwarning("%s: no base for mark %s",pref(kind,lookupname),gref(markchar))
                        end
                        return head, start, false
                    end
                end
            end
            local baseanchors = descriptions[basechar]
            if baseanchors then
                baseanchors = baseanchors.anchors
            end
            if baseanchors then
                local baseanchors = baseanchors['basechar']
                if baseanchors then
                    local al = anchorlookups[lookupname]
                    for anchor,ba in next, baseanchors do
                        if al[anchor] then
                            local ma = markanchors[anchor]
                            if ma then
                                local dx, dy, bound = setmark(start,base,tfmdata.parameters.factor,rlmode,ba,ma)
                                if trace_marks then
                                    logprocess("%s, anchor %s, bound %s: anchoring mark %s to basechar %s => (%p,%p)",
                                        pref(kind,lookupname),anchor,bound,gref(markchar),gref(basechar),dx,dy)
                                end
                                return head, start, true
                            end
                        end
                    end
                    if trace_bugs then
                        logwarning("%s, no matching anchors for mark %s and base %s",pref(kind,lookupname),gref(markchar),gref(basechar))
                    end
                end
            else -- if trace_bugs then
            --  logwarning("%s: char %s is missing in font",pref(kind,lookupname),gref(basechar))
                onetimemessage(currentfont,basechar,"no base anchors",report_fonts)
            end
        elseif trace_bugs then
            logwarning("%s: prev node is no char",pref(kind,lookupname))
        end
    elseif trace_bugs then
        logwarning("%s: mark %s is no mark",pref(kind,lookupname),gref(markchar))
    end
    return head, start, false
end

function handlers.gpos_mark2ligature(head,start,kind,lookupname,markanchors,sequence)
    -- check chainpos variant
    local markchar = start.char
    if marks[markchar] then
        local base = start.prev -- [glyph] [optional marks] [start=mark]
        if base and base.id == glyph_code and base.font == currentfont and base.subtype<256 then
            local basechar = base.char
            if marks[basechar] then
                while true do
                    base = base.prev
                    if base and base.id == glyph_code and base.font == currentfont and base.subtype<256 then
                        basechar = base.char
                        if not marks[basechar] then
                            break
                        end
                    else
                        if trace_bugs then
                            logwarning("%s: no base for mark %s",pref(kind,lookupname),gref(markchar))
                        end
                        return head, start, false
                    end
                end
            end
            local index = start[a_ligacomp]
            local baseanchors = descriptions[basechar]
            if baseanchors then
                baseanchors = baseanchors.anchors
                if baseanchors then
                   local baseanchors = baseanchors['baselig']
                   if baseanchors then
                        local al = anchorlookups[lookupname]
                        for anchor,ba in next, baseanchors do
                            if al[anchor] then
                                local ma = markanchors[anchor]
                                if ma then
                                    ba = ba[index]
                                    if ba then
                                        local dx, dy, bound = setmark(start,base,tfmdata.parameters.factor,rlmode,ba,ma) -- index
                                        if trace_marks then
                                            logprocess("%s, anchor %s, index %s, bound %s: anchoring mark %s to baselig %s at index %s => (%p,%p)",
                                                pref(kind,lookupname),anchor,index,bound,gref(markchar),gref(basechar),index,dx,dy)
                                        end
                                        return head, start, true
                                    end
                                end
                            end
                        end
                        if trace_bugs then
                            logwarning("%s: no matching anchors for mark %s and baselig %s",pref(kind,lookupname),gref(markchar),gref(basechar))
                        end
                    end
                end
            else -- if trace_bugs then
            --  logwarning("%s: char %s is missing in font",pref(kind,lookupname),gref(basechar))
                onetimemessage(currentfont,basechar,"no base anchors",report_fonts)
            end
        elseif trace_bugs then
            logwarning("%s: prev node is no char",pref(kind,lookupname))
        end
    elseif trace_bugs then
        logwarning("%s: mark %s is no mark",pref(kind,lookupname),gref(markchar))
    end
    return head, start, false
end

function handlers.gpos_mark2mark(head,start,kind,lookupname,markanchors,sequence)
    local markchar = start.char
    if marks[markchar] then
        local base = start.prev -- [glyph] [basemark] [start=mark]
        local slc = start[a_ligacomp]
        if slc then -- a rather messy loop ... needs checking with husayni
            while base do
                local blc = base[a_ligacomp]
                if blc and blc ~= slc then
                    base = base.prev
                else
                    break
                end
            end
        end
        if base and base.id == glyph_code and base.font == currentfont and base.subtype<256 then -- subtype test can go
            local basechar = base.char
            local baseanchors = descriptions[basechar]
            if baseanchors then
                baseanchors = baseanchors.anchors
                if baseanchors then
                    baseanchors = baseanchors['basemark']
                    if baseanchors then
                        local al = anchorlookups[lookupname]
                        for anchor,ba in next, baseanchors do
                            if al[anchor] then
                                local ma = markanchors[anchor]
                                if ma then
                                    local dx, dy, bound = setmark(start,base,tfmdata.parameters.factor,rlmode,ba,ma)
                                    if trace_marks then
                                        logprocess("%s, anchor %s, bound %s: anchoring mark %s to basemark %s => (%p,%p)",
                                            pref(kind,lookupname),anchor,bound,gref(markchar),gref(basechar),dx,dy)
                                    end
                                    return head, start, true
                                end
                            end
                        end
                        if trace_bugs then
                            logwarning("%s: no matching anchors for mark %s and basemark %s",pref(kind,lookupname),gref(markchar),gref(basechar))
                        end
                    end
                end
            else -- if trace_bugs then
            --  logwarning("%s: char %s is missing in font",pref(kind,lookupname),gref(basechar))
                onetimemessage(currentfont,basechar,"no base anchors",report_fonts)
            end
        elseif trace_bugs then
            logwarning("%s: prev node is no mark",pref(kind,lookupname))
        end
    elseif trace_bugs then
        logwarning("%s: mark %s is no mark",pref(kind,lookupname),gref(markchar))
    end
    return head, start, false
end

function handlers.gpos_cursive(head,start,kind,lookupname,exitanchors,sequence) -- to be checked
    local alreadydone = cursonce and start[a_cursbase]
    if not alreadydone then
        local done = false
        local startchar = start.char
        if marks[startchar] then
            if trace_cursive then
                logprocess("%s: ignoring cursive for mark %s",pref(kind,lookupname),gref(startchar))
            end
        else
            local nxt = start.next
            while not done and nxt and nxt.id == glyph_code and nxt.font == currentfont and nxt.subtype<256 do
                local nextchar = nxt.char
                if marks[nextchar] then
                    -- should not happen (maybe warning)
                    nxt = nxt.next
                else
                    local entryanchors = descriptions[nextchar]
                    if entryanchors then
                        entryanchors = entryanchors.anchors
                        if entryanchors then
                            entryanchors = entryanchors['centry']
                            if entryanchors then
                                local al = anchorlookups[lookupname]
                                for anchor, entry in next, entryanchors do
                                    if al[anchor] then
                                        local exit = exitanchors[anchor]
                                        if exit then
                                            local dx, dy, bound = setcursive(start,nxt,tfmdata.parameters.factor,rlmode,exit,entry,characters[startchar],characters[nextchar])
                                            if trace_cursive then
                                                logprocess("%s: moving %s to %s cursive (%p,%p) using anchor %s and bound %s in rlmode %s",pref(kind,lookupname),gref(startchar),gref(nextchar),dx,dy,anchor,bound,rlmode)
                                            end
                                            done = true
                                            break
                                        end
                                    end
                                end
                            end
                        end
                    else -- if trace_bugs then
                    --  logwarning("%s: char %s is missing in font",pref(kind,lookupname),gref(startchar))
                        onetimemessage(currentfont,startchar,"no entry anchors",report_fonts)
                    end
                    break
                end
            end
        end
        return head, start, done
    else
        if trace_cursive and trace_details then
            logprocess("%s, cursive %s is already done",pref(kind,lookupname),gref(start.char),alreadydone)
        end
        return head, start, false
    end
end

function handlers.gpos_single(head,start,kind,lookupname,kerns,sequence)
    local startchar = start.char
    local dx, dy, w, h = setpair(start,tfmdata.parameters.factor,rlmode,sequence.flags[4],kerns,characters[startchar])
    if trace_kerns then
        logprocess("%s: shifting single %s by (%p,%p) and correction (%p,%p)",pref(kind,lookupname),gref(startchar),dx,dy,w,h)
    end
    return head, start, false
end

function handlers.gpos_pair(head,start,kind,lookupname,kerns,sequence)
    -- todo: kerns in disc nodes: pre, post, replace -> loop over disc too
    -- todo: kerns in components of ligatures
    local snext = start.next
    if not snext then
        return head, start, false
    else
        local prev, done = start, false
        local factor = tfmdata.parameters.factor
        local lookuptype = lookuptypes[lookupname]
        while snext and snext.id == glyph_code and snext.font == currentfont and snext.subtype<256 do
            local nextchar = snext.char
            local krn = kerns[nextchar]
            if not krn and marks[nextchar] then
                prev = snext
                snext = snext.next
            else
                local krn = kerns[nextchar]
                if not krn then
                    -- skip
                elseif type(krn) == "table" then
                    if lookuptype == "pair" then -- probably not needed
                        local a, b = krn[2], krn[3]
                        if a and #a > 0 then
                            local startchar = start.char
                            local x, y, w, h = setpair(start,factor,rlmode,sequence.flags[4],a,characters[startchar])
                            if trace_kerns then
                                logprocess("%s: shifting first of pair %s and %s by (%p,%p) and correction (%p,%p)",pref(kind,lookupname),gref(startchar),gref(nextchar),x,y,w,h)
                            end
                        end
                        if b and #b > 0 then
                            local startchar = start.char
                            local x, y, w, h = setpair(snext,factor,rlmode,sequence.flags[4],b,characters[nextchar])
                            if trace_kerns then
                                logprocess("%s: shifting second of pair %s and %s by (%p,%p) and correction (%p,%p)",pref(kind,lookupname),gref(startchar),gref(nextchar),x,y,w,h)
                            end
                        end
                    else -- wrong ... position has different entries
                        report_process("%s: check this out (old kern stuff)",pref(kind,lookupname))
                     -- local a, b = krn[2], krn[6]
                     -- if a and a ~= 0 then
                     --     local k = setkern(snext,factor,rlmode,a)
                     --     if trace_kerns then
                     --         logprocess("%s: inserting first kern %s between %s and %s",pref(kind,lookupname),k,gref(prev.char),gref(nextchar))
                     --     end
                     -- end
                     -- if b and b ~= 0 then
                     --     logwarning("%s: ignoring second kern xoff %s",pref(kind,lookupname),b*factor)
                     -- end
                    end
                    done = true
                elseif krn ~= 0 then
                    local k = setkern(snext,factor,rlmode,krn)
                    if trace_kerns then
                        logprocess("%s: inserting kern %s between %s and %s",pref(kind,lookupname),k,gref(prev.char),gref(nextchar))
                    end
                    done = true
                end
                break
            end
        end
        return head, start, done
    end
end

--[[ldx--
<p>I will implement multiple chain replacements once I run into a font that uses
it. It's not that complex to handle.</p>
--ldx]]--

local chainmores = { }
local chainprocs = { }

local function logprocess(...)
    if trace_steps then
        registermessage(...)
    end
    report_subchain(...)
end

local logwarning = report_subchain

local function logprocess(...)
    if trace_steps then
        registermessage(...)
    end
    report_chain(...)
end

local logwarning = report_chain

-- We could share functions but that would lead to extra function calls with many
-- arguments, redundant tests and confusing messages.

function chainprocs.chainsub(head,start,stop,kind,chainname,currentcontext,lookuphash,lookuplist,chainlookupname)
    logwarning("%s: a direct call to chainsub cannot happen",cref(kind,chainname,chainlookupname))
    return head, start, false
end

function chainmores.chainsub(head,start,stop,kind,chainname,currentcontext,lookuphash,lookuplist,chainlookupname,n)
    logprocess("%s: a direct call to chainsub cannot happen",cref(kind,chainname,chainlookupname))
    return head, start, false
end

-- The reversesub is a special case, which is why we need to store the replacements
-- in a bit weird way. There is no lookup and the replacement comes from the lookup
-- itself. It is meant mostly for dealing with Urdu.

function chainprocs.reversesub(head,start,stop,kind,chainname,currentcontext,lookuphash,replacements)
    local char = start.char
    local replacement = replacements[char]
    if replacement then
        if trace_singles then
            logprocess("%s: single reverse replacement of %s by %s",cref(kind,chainname),gref(char),gref(replacement))
        end
        start.char = replacement
        return head, start, true
    else
        return head, start, false
    end
end

--[[ldx--
<p>This chain stuff is somewhat tricky since we can have a sequence of actions to be
applied: single, alternate, multiple or ligature where ligature can be an invalid
one in the sense that it will replace multiple by one but not neccessary one that
looks like the combination (i.e. it is the counterpart of multiple then). For
example, the following is valid:</p>

<typing>
<line>xxxabcdexxx [single a->A][multiple b->BCD][ligature cde->E] xxxABCDExxx</line>
</typing>

<p>Therefore we we don't really do the replacement here already unless we have the
single lookup case. The efficiency of the replacements can be improved by deleting
as less as needed but that would also make the code even more messy.</p>
--ldx]]--

local function delete_till_stop(start,stop,ignoremarks) -- keeps start
    local n = 1
    if start == stop then
        -- done
    elseif ignoremarks then
        repeat -- start x x m x x stop => start m
            local next = start.next
            if not marks[next.char] then
                local components = next.components
                if components then -- probably not needed
                    flush_node_list(components)
                end
                delete_node(start,next)
            end
            n = n + 1
        until next == stop
    else -- start x x x stop => start
        repeat
            local next = start.next
            local components = next.components
            if components then -- probably not needed
                flush_node_list(components)
            end
            delete_node(start,next)
            n = n + 1
        until next == stop
    end
    return n
end

--[[ldx--
<p>Here we replace start by a single variant, First we delete the rest of the
match.</p>
--ldx]]--

function chainprocs.gsub_single(head,start,stop,kind,chainname,currentcontext,lookuphash,currentlookup,chainlookupname,chainindex)
    -- todo: marks ?
    local current = start
    local subtables = currentlookup.subtables
    if #subtables > 1 then
        logwarning("todo: check if we need to loop over the replacements: %s",concat(subtables," "))
    end
    while current do
        if current.id == glyph_code then
            local currentchar = current.char
            local lookupname = subtables[1] -- only 1
            local replacement = lookuphash[lookupname]
            if not replacement then
                if trace_bugs then
                    logwarning("%s: no single hits",cref(kind,chainname,chainlookupname,lookupname,chainindex))
                end
            else
                replacement = replacement[currentchar]
                if not replacement or replacement == "" then
                    if trace_bugs then
                        logwarning("%s: no single for %s",cref(kind,chainname,chainlookupname,lookupname,chainindex),gref(currentchar))
                    end
                else
                    if trace_singles then
                        logprocess("%s: replacing single %s by %s",cref(kind,chainname,chainlookupname,lookupname,chainindex),gref(currentchar),gref(replacement))
                    end
                    current.char = replacement
                end
            end
            return head, start, true
        elseif current == stop then
            break
        else
            current = current.next
        end
    end
    return head, start, false
end

chainmores.gsub_single = chainprocs.gsub_single

--[[ldx--
<p>Here we replace start by a sequence of new glyphs. First we delete the rest of
the match.</p>
--ldx]]--

function chainprocs.gsub_multiple(head,start,stop,kind,chainname,currentcontext,lookuphash,currentlookup,chainlookupname)
    delete_till_stop(start,stop) -- we could pass ignoremarks as #3 ..
    local startchar = start.char
    local subtables = currentlookup.subtables
    local lookupname = subtables[1]
    local replacements = lookuphash[lookupname]
    if not replacements then
        if trace_bugs then
            logwarning("%s: no multiple hits",cref(kind,chainname,chainlookupname,lookupname))
        end
    else
        replacements = replacements[startchar]
        if not replacements or replacement == "" then
            if trace_bugs then
                logwarning("%s: no multiple for %s",cref(kind,chainname,chainlookupname,lookupname),gref(startchar))
            end
        else
            if trace_multiples then
                logprocess("%s: replacing %s by multiple characters %s",cref(kind,chainname,chainlookupname,lookupname),gref(startchar),gref(replacements))
            end
            return multiple_glyphs(head,start,replacements)
        end
    end
    return head, start, false
end

chainmores.gsub_multiple = chainprocs.gsub_multiple

--[[ldx--
<p>Here we replace start by new glyph. First we delete the rest of the match.</p>
--ldx]]--

-- char_1 mark_1 -> char_x mark_1 (ignore marks)
-- char_1 mark_1 -> char_x

-- to be checked: do we always have just one glyph?
-- we can also have alternates for marks
-- marks come last anyway
-- are there cases where we need to delete the mark

function chainprocs.gsub_alternate(head,start,stop,kind,chainname,currentcontext,lookuphash,currentlookup,chainlookupname)
    local current = start
    local subtables = currentlookup.subtables
    local value  = featurevalue == true and tfmdata.shared.features[kind] or featurevalue
    while current do
        if current.id == glyph_code then -- is this check needed?
            local currentchar = current.char
            local lookupname = subtables[1]
            local alternatives = lookuphash[lookupname]
            if not alternatives then
                if trace_bugs then
                    logwarning("%s: no alternative hit",cref(kind,chainname,chainlookupname,lookupname))
                end
            else
                alternatives = alternatives[currentchar]
                if alternatives then
                    local choice, comment = get_alternative_glyph(current,alternatives,value,trace_alternatives)
                    if choice then
                        if trace_alternatives then
                            logprocess("%s: replacing %s by alternative %a to %s, %s",cref(kind,chainname,chainlookupname,lookupname),gref(char),choice,gref(choice),comment)
                        end
                        start.char = choice
                    else
                        if trace_alternatives then
                            logwarning("%s: no variant %a for %s, %s",cref(kind,chainname,chainlookupname,lookupname),value,gref(char),comment)
                        end
                    end
                elseif trace_bugs then
                    logwarning("%s: no alternative for %s, %s",cref(kind,chainname,chainlookupname,lookupname),gref(currentchar),comment)
                end
            end
            return head, start, true
        elseif current == stop then
            break
        else
            current = current.next
        end
    end
    return head, start, false
end

chainmores.gsub_alternate = chainprocs.gsub_alternate

--[[ldx--
<p>When we replace ligatures we use a helper that handles the marks. I might change
this function (move code inline and handle the marks by a separate function). We
assume rather stupid ligatures (no complex disc nodes).</p>
--ldx]]--

function chainprocs.gsub_ligature(head,start,stop,kind,chainname,currentcontext,lookuphash,currentlookup,chainlookupname,chainindex)
    local startchar = start.char
    local subtables = currentlookup.subtables
    local lookupname = subtables[1]
    local ligatures = lookuphash[lookupname]
    if not ligatures then
        if trace_bugs then
            logwarning("%s: no ligature hits",cref(kind,chainname,chainlookupname,lookupname,chainindex))
        end
    else
        ligatures = ligatures[startchar]
        if not ligatures then
            if trace_bugs then
                logwarning("%s: no ligatures starting with %s",cref(kind,chainname,chainlookupname,lookupname,chainindex),gref(startchar))
            end
        else
            local s = start.next
            local discfound = false
            local last = stop
            local nofreplacements = 0
            local skipmark = currentlookup.flags[1]
            while s do
                local id = s.id
                if id == disc_code then
                    s = s.next
                    discfound = true
                else
                    local schar = s.char
                    if skipmark and marks[schar] then -- marks
                        s = s.next
                    else
                        local lg = ligatures[schar]
                        if lg then
                            ligatures, last, nofreplacements = lg, s, nofreplacements + 1
                            if s == stop then
                                break
                            else
                                s = s.next
                            end
                        else
                            break
                        end
                    end
                end
            end
            local l2 = ligatures.ligature
            if l2 then
                if chainindex then
                    stop = last
                end
                if trace_ligatures then
                    if start == stop then
                        logprocess("%s: replacing character %s by ligature %s case 3",cref(kind,chainname,chainlookupname,lookupname,chainindex),gref(startchar),gref(l2))
                    else
                        logprocess("%s: replacing character %s upto %s by ligature %s case 4",cref(kind,chainname,chainlookupname,lookupname,chainindex),gref(startchar),gref(stop.char),gref(l2))
                    end
                end
                head, start = toligature(kind,lookupname,head,start,stop,l2,currentlookup.flags[1],discfound)
                return head, start, true, nofreplacements
            elseif trace_bugs then
                if start == stop then
                    logwarning("%s: replacing character %s by ligature fails",cref(kind,chainname,chainlookupname,lookupname,chainindex),gref(startchar))
                else
                    logwarning("%s: replacing character %s upto %s by ligature fails",cref(kind,chainname,chainlookupname,lookupname,chainindex),gref(startchar),gref(stop.char))
                end
            end
        end
    end
    return head, start, false, 0
end

chainmores.gsub_ligature = chainprocs.gsub_ligature

function chainprocs.gpos_mark2base(head,start,stop,kind,chainname,currentcontext,lookuphash,currentlookup,chainlookupname)
    local markchar = start.char
    if marks[markchar] then
        local subtables = currentlookup.subtables
        local lookupname = subtables[1]
        local markanchors = lookuphash[lookupname]
        if markanchors then
            markanchors = markanchors[markchar]
        end
        if markanchors then
            local base = start.prev -- [glyph] [start=mark]
            if base and base.id == glyph_code and base.font == currentfont and base.subtype<256 then
                local basechar = base.char
                if marks[basechar] then
                    while true do
                        base = base.prev
                        if base and base.id == glyph_code and base.font == currentfont and base.subtype<256 then
                            basechar = base.char
                            if not marks[basechar] then
                                break
                            end
                        else
                            if trace_bugs then
                                logwarning("%s: no base for mark %s",pref(kind,lookupname),gref(markchar))
                            end
                            return head, start, false
                        end
                    end
                end
                local baseanchors = descriptions[basechar].anchors
                if baseanchors then
                    local baseanchors = baseanchors['basechar']
                    if baseanchors then
                        local al = anchorlookups[lookupname]
                        for anchor,ba in next, baseanchors do
                            if al[anchor] then
                                local ma = markanchors[anchor]
                                if ma then
                                    local dx, dy, bound = setmark(start,base,tfmdata.parameters.factor,rlmode,ba,ma)
                                    if trace_marks then
                                        logprocess("%s, anchor %s, bound %s: anchoring mark %s to basechar %s => (%p,%p)",
                                            cref(kind,chainname,chainlookupname,lookupname),anchor,bound,gref(markchar),gref(basechar),dx,dy)
                                    end
                                    return head, start, true
                                end
                            end
                        end
                        if trace_bugs then
                            logwarning("%s, no matching anchors for mark %s and base %s",cref(kind,chainname,chainlookupname,lookupname),gref(markchar),gref(basechar))
                        end
                    end
                end
            elseif trace_bugs then
                logwarning("%s: prev node is no char",cref(kind,chainname,chainlookupname,lookupname))
            end
        elseif trace_bugs then
            logwarning("%s: mark %s has no anchors",cref(kind,chainname,chainlookupname,lookupname),gref(markchar))
        end
    elseif trace_bugs then
        logwarning("%s: mark %s is no mark",cref(kind,chainname,chainlookupname),gref(markchar))
    end
    return head, start, false
end

function chainprocs.gpos_mark2ligature(head,start,stop,kind,chainname,currentcontext,lookuphash,currentlookup,chainlookupname)
    local markchar = start.char
    if marks[markchar] then
        local subtables = currentlookup.subtables
        local lookupname = subtables[1]
        local markanchors = lookuphash[lookupname]
        if markanchors then
            markanchors = markanchors[markchar]
        end
        if markanchors then
            local base = start.prev -- [glyph] [optional marks] [start=mark]
            if base and base.id == glyph_code and base.font == currentfont and base.subtype<256 then
                local basechar = base.char
                if marks[basechar] then
                    while true do
                        base = base.prev
                        if base and base.id == glyph_code and base.font == currentfont and base.subtype<256 then
                            basechar = base.char
                            if not marks[basechar] then
                                break
                            end
                        else
                            if trace_bugs then
                                logwarning("%s: no base for mark %s",cref(kind,chainname,chainlookupname,lookupname),markchar)
                            end
                            return head, start, false
                        end
                    end
                end
                -- todo: like marks a ligatures hash
                local index = start[a_ligacomp]
                local baseanchors = descriptions[basechar].anchors
                if baseanchors then
                   local baseanchors = baseanchors['baselig']
                   if baseanchors then
                        local al = anchorlookups[lookupname]
                        for anchor,ba in next, baseanchors do
                            if al[anchor] then
                                local ma = markanchors[anchor]
                                if ma then
                                    ba = ba[index]
                                    if ba then
                                        local dx, dy, bound = setmark(start,base,tfmdata.parameters.factor,rlmode,ba,ma) -- index
                                        if trace_marks then
                                            logprocess("%s, anchor %s, bound %s: anchoring mark %s to baselig %s at index %s => (%p,%p)",
                                                cref(kind,chainname,chainlookupname,lookupname),anchor,a or bound,gref(markchar),gref(basechar),index,dx,dy)
                                        end
                                        return head, start, true
                                    end
                                end
                            end
                        end
                        if trace_bugs then
                            logwarning("%s: no matching anchors for mark %s and baselig %s",cref(kind,chainname,chainlookupname,lookupname),gref(markchar),gref(basechar))
                        end
                    end
                end
            elseif trace_bugs then
                logwarning("feature %s, lookup %s: prev node is no char",kind,lookupname)
            end
        elseif trace_bugs then
            logwarning("%s: mark %s has no anchors",cref(kind,chainname,chainlookupname,lookupname),gref(markchar))
        end
    elseif trace_bugs then
        logwarning("%s: mark %s is no mark",cref(kind,chainname,chainlookupname),gref(markchar))
    end
    return head, start, false
end

function chainprocs.gpos_mark2mark(head,start,stop,kind,chainname,currentcontext,lookuphash,currentlookup,chainlookupname)
    local markchar = start.char
    if marks[markchar] then
--~         local alreadydone = markonce and start[a_markmark]
--~         if not alreadydone then
        --  local markanchors = descriptions[markchar].anchors markanchors = markanchors and markanchors.mark
            local subtables = currentlookup.subtables
            local lookupname = subtables[1]
            local markanchors = lookuphash[lookupname]
            if markanchors then
                markanchors = markanchors[markchar]
            end
            if markanchors then
                local base = start.prev -- [glyph] [basemark] [start=mark]
                local slc = start[a_ligacomp]
                if slc then -- a rather messy loop ... needs checking with husayni
                    while base do
                        local blc = base[a_ligacomp]
                        if blc and blc ~= slc then
                            base = base.prev
                        else
                            break
                        end
                    end
                end
                if base and base.id == glyph_code and base.font == currentfont and base.subtype<256 then -- subtype test can go
                    local basechar = base.char
                    local baseanchors = descriptions[basechar].anchors
                    if baseanchors then
                        baseanchors = baseanchors['basemark']
                        if baseanchors then
                            local al = anchorlookups[lookupname]
                            for anchor,ba in next, baseanchors do
                                if al[anchor] then
                                    local ma = markanchors[anchor]
                                    if ma then
                                        local dx, dy, bound = setmark(start,base,tfmdata.parameters.factor,rlmode,ba,ma)
                                        if trace_marks then
                                            logprocess("%s, anchor %s, bound %s: anchoring mark %s to basemark %s => (%p,%p)",
                                                cref(kind,chainname,chainlookupname,lookupname),anchor,bound,gref(markchar),gref(basechar),dx,dy)
                                        end
                                        return head, start, true
                                    end
                                end
                            end
                            if trace_bugs then
                                logwarning("%s: no matching anchors for mark %s and basemark %s",gref(kind,chainname,chainlookupname,lookupname),gref(markchar),gref(basechar))
                            end
                        end
                    end
                elseif trace_bugs then
                    logwarning("%s: prev node is no mark",cref(kind,chainname,chainlookupname,lookupname))
                end
            elseif trace_bugs then
                logwarning("%s: mark %s has no anchors",cref(kind,chainname,chainlookupname,lookupname),gref(markchar))
            end
--~         elseif trace_marks and trace_details then
--~             logprocess("%s, mark %s is already bound (n=%s), ignoring mark2mark",pref(kind,lookupname),gref(markchar),alreadydone)
--~         end
    elseif trace_bugs then
        logwarning("%s: mark %s is no mark",cref(kind,chainname,chainlookupname),gref(markchar))
    end
    return head, start, false
end

function chainprocs.gpos_cursive(head,start,stop,kind,chainname,currentcontext,lookuphash,currentlookup,chainlookupname)
    local alreadydone = cursonce and start[a_cursbase]
    if not alreadydone then
        local startchar = start.char
        local subtables = currentlookup.subtables
        local lookupname = subtables[1]
        local exitanchors = lookuphash[lookupname]
        if exitanchors then
            exitanchors = exitanchors[startchar]
        end
        if exitanchors then
            local done = false
            if marks[startchar] then
                if trace_cursive then
                    logprocess("%s: ignoring cursive for mark %s",pref(kind,lookupname),gref(startchar))
                end
            else
                local nxt = start.next
                while not done and nxt and nxt.id == glyph_code and nxt.font == currentfont and nxt.subtype<256 do
                    local nextchar = nxt.char
                    if marks[nextchar] then
                        -- should not happen (maybe warning)
                        nxt = nxt.next
                    else
                        local entryanchors = descriptions[nextchar]
                        if entryanchors then
                            entryanchors = entryanchors.anchors
                            if entryanchors then
                                entryanchors = entryanchors['centry']
                                if entryanchors then
                                    local al = anchorlookups[lookupname]
                                    for anchor, entry in next, entryanchors do
                                        if al[anchor] then
                                            local exit = exitanchors[anchor]
                                            if exit then
                                                local dx, dy, bound = setcursive(start,nxt,tfmdata.parameters.factor,rlmode,exit,entry,characters[startchar],characters[nextchar])
                                                if trace_cursive then
                                                    logprocess("%s: moving %s to %s cursive (%p,%p) using anchor %s and bound %s in rlmode %s",pref(kind,lookupname),gref(startchar),gref(nextchar),dx,dy,anchor,bound,rlmode)
                                                end
                                                done = true
                                                break
                                            end
                                        end
                                    end
                                end
                            end
                        else -- if trace_bugs then
                        --  logwarning("%s: char %s is missing in font",pref(kind,lookupname),gref(startchar))
                            onetimemessage(currentfont,startchar,"no entry anchors",report_fonts)
                        end
                        break
                    end
                end
            end
            return head, start, done
        else
            if trace_cursive and trace_details then
                logprocess("%s, cursive %s is already done",pref(kind,lookupname),gref(start.char),alreadydone)
            end
            return head, start, false
        end
    end
    return head, start, false
end

function chainprocs.gpos_single(head,start,stop,kind,chainname,currentcontext,lookuphash,currentlookup,chainlookupname,chainindex,sequence)
    -- untested .. needs checking for the new model
    local startchar = start.char
    local subtables = currentlookup.subtables
    local lookupname = subtables[1]
    local kerns = lookuphash[lookupname]
    if kerns then
        kerns = kerns[startchar] -- needed ?
        if kerns then
            local dx, dy, w, h = setpair(start,tfmdata.parameters.factor,rlmode,sequence.flags[4],kerns,characters[startchar])
            if trace_kerns then
                logprocess("%s: shifting single %s by (%p,%p) and correction (%p,%p)",cref(kind,chainname,chainlookupname),gref(startchar),dx,dy,w,h)
            end
        end
    end
    return head, start, false
end

-- when machines become faster i will make a shared function

function chainprocs.gpos_pair(head,start,stop,kind,chainname,currentcontext,lookuphash,currentlookup,chainlookupname,chainindex,sequence)
--    logwarning("%s: gpos_pair not yet supported",cref(kind,chainname,chainlookupname))
    local snext = start.next
    if snext then
        local startchar = start.char
        local subtables = currentlookup.subtables
        local lookupname = subtables[1]
        local kerns = lookuphash[lookupname]
        if kerns then
            kerns = kerns[startchar]
            if kerns then
                local lookuptype = lookuptypes[lookupname]
                local prev, done = start, false
                local factor = tfmdata.parameters.factor
                while snext and snext.id == glyph_code and snext.font == currentfont and snext.subtype<256 do
                    local nextchar = snext.char
                    local krn = kerns[nextchar]
                    if not krn and marks[nextchar] then
                        prev = snext
                        snext = snext.next
                    else
                        if not krn then
                            -- skip
                        elseif type(krn) == "table" then
                            if lookuptype == "pair" then
                                local a, b = krn[2], krn[3]
                                if a and #a > 0 then
                                    local startchar = start.char
                                    local x, y, w, h = setpair(start,factor,rlmode,sequence.flags[4],a,characters[startchar])
                                    if trace_kerns then
                                        logprocess("%s: shifting first of pair %s and %s by (%p,%p) and correction (%p,%p)",cref(kind,chainname,chainlookupname),gref(startchar),gref(nextchar),x,y,w,h)
                                    end
                                end
                                if b and #b > 0 then
                                    local startchar = start.char
                                    local x, y, w, h = setpair(snext,factor,rlmode,sequence.flags[4],b,characters[nextchar])
                                    if trace_kerns then
                                        logprocess("%s: shifting second of pair %s and %s by (%p,%p) and correction (%p,%p)",cref(kind,chainname,chainlookupname),gref(startchar),gref(nextchar),x,y,w,h)
                                    end
                                end
                            else
                                report_process("%s: check this out (old kern stuff)",cref(kind,chainname,chainlookupname))
                                local a, b = krn[2], krn[6]
                                if a and a ~= 0 then
                                    local k = setkern(snext,factor,rlmode,a)
                                    if trace_kerns then
                                        logprocess("%s: inserting first kern %s between %s and %s",cref(kind,chainname,chainlookupname),k,gref(prev.char),gref(nextchar))
                                    end
                                end
                                if b and b ~= 0 then
                                    logwarning("%s: ignoring second kern xoff %s",cref(kind,chainname,chainlookupname),b*factor)
                                end
                            end
                            done = true
                        elseif krn ~= 0 then
                            local k = setkern(snext,factor,rlmode,krn)
                            if trace_kerns then
                                logprocess("%s: inserting kern %s between %s and %s",cref(kind,chainname,chainlookupname),k,gref(prev.char),gref(nextchar))
                            end
                            done = true
                        end
                        break
                    end
                end
                return head, start, done
            end
        end
    end
    return head, start, false
end

-- what pointer to return, spec says stop
-- to be discussed ... is bidi changer a space?
-- elseif char == zwnj and sequence[n][32] then -- brrr

-- somehow l or f is global
-- we don't need to pass the currentcontext, saves a bit
-- make a slow variant then can be activated but with more tracing

local function show_skip(kind,chainname,char,ck,class)
    if ck[9] then
        logwarning("%s: skipping char %s, class %a, rule %a, lookuptype %a, %a => %a",cref(kind,chainname),gref(char),class,ck[1],ck[2],ck[9],ck[10])
    else
        logwarning("%s: skipping char %s, class %a, rule %a, lookuptype %a",cref(kind,chainname),gref(char),class,ck[1],ck[2])
    end
end

local function normal_handle_contextchain(head,start,kind,chainname,contexts,sequence,lookuphash)
    --  local rule, lookuptype, sequence, f, l, lookups = ck[1], ck[2] ,ck[3], ck[4], ck[5], ck[6]
    local flags        = sequence.flags
    local done         = false
    local skipmark     = flags[1]
    local skipligature = flags[2]
    local skipbase     = flags[3]
    local someskip     = skipmark or skipligature or skipbase -- could be stored in flags for a fast test (hm, flags could be false !)
    local markclass    = sequence.markclass                   -- todo, first we need a proper test
    local skipped      = false
    for k=1,#contexts do
        local match   = true
        local current = start
        local last    = start
        local ck      = contexts[k]
        local seq     = ck[3]
        local s       = #seq
        -- f..l = mid string
        if s == 1 then
            -- never happens
            match = current.id == glyph_code and current.font == currentfont and current.subtype<256 and seq[1][current.char]
        else
            -- maybe we need a better space check (maybe check for glue or category or combination)
            -- we cannot optimize for n=2 because there can be disc nodes
            local f, l = ck[4], ck[5]
            -- current match
            if f == 1 and f == l then -- current only
                -- already a hit
             -- match = true
            else -- before/current/after | before/current | current/after
                -- no need to test first hit (to be optimized)
                if f == l then -- new, else last out of sync (f is > 1)
                 -- match = true
                else
                    local n = f + 1
                    last = last.next
                    while n <= l do
                        if last then
                            local id = last.id
                            if id == glyph_code then
                                if last.font == currentfont and last.subtype<256 then
                                    local char = last.char
                                    local ccd = descriptions[char]
                                    if ccd then
                                        local class = ccd.class
                                        if class == skipmark or class == skipligature or class == skipbase or (markclass and class == "mark" and not markclass[char]) then
                                            skipped = true
                                            if trace_skips then
                                                show_skip(kind,chainname,char,ck,class)
                                            end
                                            last = last.next
                                        elseif seq[n][char] then
                                            if n < l then
                                                last = last.next
                                            end
                                            n = n + 1
                                        else
                                            match = false
                                            break
                                        end
                                    else
                                        match = false
                                        break
                                    end
                                else
                                    match = false
                                    break
                                end
                            elseif id == disc_code then
                                last = last.next
                            else
                                match = false
                                break
                            end
                        else
                            match = false
                            break
                        end
                    end
                end
            end
            -- before
            if match and f > 1 then
                local prev = start.prev
                if prev then
                    local n = f-1
                    while n >= 1 do
                        if prev then
                            local id = prev.id
                            if id == glyph_code then
                                if prev.font == currentfont and prev.subtype<256 then -- normal char
                                    local char = prev.char
                                    local ccd = descriptions[char]
                                    if ccd then
                                        local class = ccd.class
                                        if class == skipmark or class == skipligature or class == skipbase or (markclass and class == "mark" and not markclass[char]) then
                                            skipped = true
                                            if trace_skips then
                                                show_skip(kind,chainname,char,ck,class)
                                            end
                                        elseif seq[n][char] then
                                            n = n -1
                                        else
                                            match = false
                                            break
                                        end
                                    else
                                        match = false
                                        break
                                    end
                                else
                                    match = false
                                    break
                                end
                            elseif id == disc_code then
                                -- skip 'm
                            elseif seq[n][32] then
                                n = n -1
                            else
                                match = false
                                break
                            end
                            prev = prev.prev
                        elseif seq[n][32] then -- somewhat special, as zapfino can have many preceding spaces
                            n = n -1
                        else
                            match = false
                            break
                        end
                    end
                elseif f == 2 then
                    match = seq[1][32]
                else
                    for n=f-1,1 do
                        if not seq[n][32] then
                            match = false
                            break
                        end
                    end
                end
            end
            -- after
            if match and s > l then
                local current = last and last.next
                if current then
                    -- removed optimization for s-l == 1, we have to deal with marks anyway
                    local n = l + 1
                    while n <= s do
                        if current then
                            local id = current.id
                            if id == glyph_code then
                                if current.font == currentfont and current.subtype<256 then -- normal char
                                    local char = current.char
                                    local ccd = descriptions[char]
                                    if ccd then
                                        local class = ccd.class
                                        if class == skipmark or class == skipligature or class == skipbase or (markclass and class == "mark" and not markclass[char]) then
                                            skipped = true
                                            if trace_skips then
                                                show_skip(kind,chainname,char,ck,class)
                                            end
                                        elseif seq[n][char] then
                                            n = n + 1
                                        else
                                            match = false
                                            break
                                        end
                                    else
                                        match = false
                                        break
                                    end
                                else
                                    match = false
                                    break
                                end
                            elseif id == disc_code then
                                -- skip 'm
                            elseif seq[n][32] then -- brrr
                                n = n + 1
                            else
                                match = false
                                break
                            end
                            current = current.next
                        elseif seq[n][32] then
                            n = n + 1
                        else
                            match = false
                            break
                        end
                    end
                elseif s-l == 1 then
                    match = seq[s][32]
                else
                    for n=l+1,s do
                        if not seq[n][32] then
                            match = false
                            break
                        end
                    end
                end
            end
        end
        if match then
            -- ck == currentcontext
            if trace_contexts then
                local rule, lookuptype, f, l = ck[1], ck[2], ck[4], ck[5]
                local char = start.char
                if ck[9] then
                    logwarning("%s: rule %s matches at char %s for (%s,%s,%s) chars, lookuptype %a, %a => %a",
                        cref(kind,chainname),rule,gref(char),f-1,l-f+1,s-l,lookuptype,ck[9],ck[10])
                else
                    logwarning("%s: rule %s matches at char %s for (%s,%s,%s) chars, lookuptype %a",
                        cref(kind,chainname),rule,gref(char),f-1,l-f+1,s-l,lookuptype)
                end
            end
            local chainlookups = ck[6]
            if chainlookups then
                local nofchainlookups = #chainlookups
                -- we can speed this up if needed
                if nofchainlookups == 1 then
                    local chainlookupname = chainlookups[1]
                    local chainlookup = lookuptable[chainlookupname]
                    if chainlookup then
                        local cp = chainprocs[chainlookup.type]
                        if cp then
                            head, start, done = cp(head,start,last,kind,chainname,ck,lookuphash,chainlookup,chainlookupname,nil,sequence)
                        else
                            logprocess("%s: %s is not yet supported",cref(kind,chainname,chainlookupname),chainlookup.type)
                        end
                    else -- shouldn't happen
                        logprocess("%s is not yet supported",cref(kind,chainname,chainlookupname))
                    end
                 else
                    local i = 1
                    repeat
                        if skipped then
                            while true do
                                local char = start.char
                                local ccd = descriptions[char]
                                if ccd then
                                    local class = ccd.class
                                    if class == skipmark or class == skipligature or class == skipbase or (markclass and class == "mark" and not markclass[char]) then
                                        start = start.next
                                    else
                                        break
                                    end
                                else
                                    break
                                end
                            end
                        end
                        local chainlookupname = chainlookups[i]
                        local chainlookup = lookuptable[chainlookupname] -- can be false (n matches, <n replacement)
                        local cp = chainlookup and chainmores[chainlookup.type]
                        if cp then
                            local ok, n
                            head, start, ok, n = cp(head,start,last,kind,chainname,ck,lookuphash,chainlookup,chainlookupname,i,sequence)
                            -- messy since last can be changed !
                            if ok then
                                done = true
                                -- skip next one(s) if ligature
                                i = i + (n or 1)
                            else
                                i = i + 1
                            end
                        else
                         -- is valid
                         -- logprocess("%s: multiple subchains for %s are not yet supported",cref(kind,chainname,chainlookupname),chainlookup and chainlookup.type or "?")
                            i = i + 1
                        end
                        start = start.next
                    until i > nofchainlookups
                end
            else
                local replacements = ck[7]
                if replacements then
                    head, start, done = chainprocs.reversesub(head,start,last,kind,chainname,ck,lookuphash,replacements) -- sequence
                else
                    done = true -- can be meant to be skipped
                    if trace_contexts then
                        logprocess("%s: skipping match",cref(kind,chainname))
                    end
                end
            end
        end
    end
    return head, start, done
end

-- Because we want to keep this elsewhere (an because speed is less an issue) we
-- pass the font id so that the verbose variant can access the relevant helper tables.

local verbose_handle_contextchain = function(font,...)
    logwarning("no verbose handler installed, reverting to 'normal'")
    otf.setcontextchain()
    return normal_handle_contextchain(...)
end

otf.chainhandlers = {
    normal  = normal_handle_contextchain,
    verbose = verbose_handle_contextchain,
}

function otf.setcontextchain(method)
    if not method or method == "normal" or not otf.chainhandlers[method] then
        if handlers.contextchain then -- no need for a message while making the format
            logwarning("installing normal contextchain handler")
        end
        handlers.contextchain = normal_handle_contextchain
    else
        logwarning("installing contextchain handler %a",method)
        local handler = otf.chainhandlers[method]
        handlers.contextchain = function(...)
            return handler(currentfont,...) -- hm, get rid of ...
        end
    end
    handlers.gsub_context             = handlers.contextchain
    handlers.gsub_contextchain        = handlers.contextchain
    handlers.gsub_reversecontextchain = handlers.contextchain
    handlers.gpos_contextchain        = handlers.contextchain
    handlers.gpos_context             = handlers.contextchain
end

otf.setcontextchain()

local missing = { } -- we only report once

local function logprocess(...)
    if trace_steps then
        registermessage(...)
    end
    report_process(...)
end

local logwarning = report_process

local function report_missing_cache(typ,lookup)
    local f = missing[currentfont] if not f then f = { } missing[currentfont] = f end
    local t = f[typ]               if not t then t = { } f[typ]               = t end
    if not t[lookup] then
        t[lookup] = true
        logwarning("missing cache for lookup %a, type %a, font %a, name %a",lookup,typ,currentfont,tfmdata.properties.fullname)
    end
end

local resolved = { } -- we only resolve a font,script,language pair once

-- todo: pass all these 'locals' in a table

local lookuphashes = { }

setmetatableindex(lookuphashes, function(t,font)
    local lookuphash = fontdata[font].resources.lookuphash
    if not lookuphash or not next(lookuphash) then
        lookuphash = false
    end
    t[font] = lookuphash
    return lookuphash
end)

-- fonts.hashes.lookups = lookuphashes

local autofeatures = fonts.analyzers.features -- was: constants

local function initialize(sequence,script,language,enabled)
    local features = sequence.features
    if features then
        for kind, scripts in next, features do
            local valid = enabled[kind]
            if valid then
                local languages = scripts[script] or scripts[wildcard]
                if languages and (languages[language] or languages[wildcard]) then
                    return { valid, autofeatures[kind] or false, sequence.chain or 0, kind, sequence }
                end
            end
        end
    end
    return false
end

function otf.dataset(tfmdata,font) -- generic variant, overloaded in context
    local shared     = tfmdata.shared
    local properties = tfmdata.properties
    local language   = properties.language or "dflt"
    local script     = properties.script   or "dflt"
    local enabled    = shared.features
    local res = resolved[font]
    if not res then
        res = { }
        resolved[font] = res
    end
    local rs = res[script]
    if not rs then
        rs = { }
        res[script] = rs
    end
    local rl = rs[language]
    if not rl then
        rl = {
            -- indexed but we can also add specific data by key
        }
        rs[language] = rl
        local sequences = tfmdata.resources.sequences
--         setmetatableindex(rl, function(t,k)
--             if type(k) == "number" then
--                 local v = enabled and initialize(sequences[k],script,language,enabled)
--                 t[k] = v
--                 return v
--             end
--         end)
for s=1,#sequences do
    local v = enabled and initialize(sequences[s],script,language,enabled)
    if v then
        rl[#rl+1] = v
    end
end
    end
    return rl
end

-- elseif id == glue_code then
--     if p[5] then -- chain
--         local pc = pp[32]
--         if pc then
--             start, ok = start, false -- p[1](start,kind,p[2],pc,p[3],p[4])
--             if ok then
--                 done = true
--             end
--             if start then start = start.next end
--         else
--             start = start.next
--         end
--     else
--         start = start.next
--     end

-- there will be a new direction parser (pre-parsed etc)

local function featuresprocessor(head,font,attr)

    local lookuphash = lookuphashes[font] -- we can also check sequences here

    if not lookuphash then
        return head, false
    end

    if trace_steps then
        checkstep(head)
    end

    tfmdata                = fontdata[font]
    descriptions           = tfmdata.descriptions
    characters             = tfmdata.characters
    resources              = tfmdata.resources

    marks                  = resources.marks
    anchorlookups          = resources.lookup_to_anchor
    lookuptable            = resources.lookups
    lookuptypes            = resources.lookuptypes

    currentfont            = font
    rlmode                 = 0

    local sequences        = resources.sequences
    local done             = false
    local datasets         = otf.dataset(tfmdata,font,attr)

    local dirstack = { } -- could move outside function

    -- We could work on sub start-stop ranges instead but I wonder if there is that
    -- much speed gain (experiments showed that it made not much sense) and we need
    -- to keep track of directions anyway. Also at some point I want to play with
    -- font interactions and then we do need the full sweeps.

    -- Keeping track of the headnode is needed for devanagari (I generalized it a bit
    -- so that multiple cases are also covered.)

--     for s=1,#sequences do
--         local dataset = datasets[s]
--         if dataset then
--             featurevalue = dataset[1] -- todo: pass to function instead of using a global
--             if featurevalue then -- never false

for s=1,#datasets do
    local dataset = datasets[s]
    featurevalue = dataset[1] -- todo: pass to function instead of using a global

                local sequence  = dataset[5] -- sequences[s] -- also dataset[5]
                local rlparmode = 0
                local topstack  = 0
                local success   = false
                local attribute = dataset[2]
                local chain     = dataset[3] -- sequence.chain or 0
                local typ       = sequence.type
                local subtables = sequence.subtables
                if chain < 0 then
                    -- this is a limited case, no special treatments like 'init' etc
                    local handler = handlers[typ]
                    -- we need to get rid of this slide! probably no longer needed in latest luatex
                    local start = find_node_tail(head) -- slow (we can store tail because there's always a skip at the end): todo
                    while start do
                        local id = start.id
                        if id == glyph_code then
                            if start.font == font and start.subtype<256 then
                                local a = start[0]
                                if a then
                                    a = a == attr
                                else
                                    a = true
                                end
                                if a then
                                    for i=1,#subtables do
                                        local lookupname = subtables[i]
                                        local lookupcache = lookuphash[lookupname]
                                        if lookupcache then
                                            local lookupmatch = lookupcache[start.char]
                                            if lookupmatch then
                                                head, start, success = handler(head,start,dataset[4],lookupname,lookupmatch,sequence,lookuphash,i)
                                                if success then
                                                    break
                                                end
                                            end
                                        else
                                            report_missing_cache(typ,lookupname)
                                        end
                                    end
                                    if start then start = start.prev end
                                else
                                    start = start.prev
                                end
                            else
                                start = start.prev
                            end
                        else
                            start = start.prev
                        end
                    end
                else
                    local handler = handlers[typ]
                    local ns = #subtables
                    local start = head -- local ?
                    rlmode = 0 -- to be checked ?
                    if ns == 1 then -- happens often
                        local lookupname = subtables[1]
                        local lookupcache = lookuphash[lookupname]
                        if not lookupcache then -- also check for empty cache
                            report_missing_cache(typ,lookupname)
                        else
                            while start do
                                local id = start.id
                                if id == glyph_code then
                                    if start.font == font and start.subtype<256 then
                                        local a = start[0]
                                        if a then
                                            a = (a == attr) and (not attribute or start[a_state] == attribute)
                                        else
                                            a = not attribute or start[a_state] == attribute
                                        end
                                        if a then
                                            local lookupmatch = lookupcache[start.char]
                                            if lookupmatch then
                                                -- sequence kan weg
                                                local ok
                                                head, start, ok = handler(head,start,dataset[4],lookupname,lookupmatch,sequence,lookuphash,1)
                                                if ok then
                                                    success = true
                                                end
                                            end
                                            if start then start = start.next end
                                        else
                                            start = start.next
                                        end
                                    elseif id == math_code then
                                        start = end_of_math(start).next
                                    else
                                        start = start.next
                                    end
                                elseif id == whatsit_code then -- will be function
                                    local subtype = start.subtype
                                    if subtype == dir_code then
                                        local dir = start.dir
                                        if     dir == "+TRT" or dir == "+TLT" then
                                            topstack = topstack + 1
                                            dirstack[topstack] = dir
                                        elseif dir == "-TRT" or dir == "-TLT" then
                                            topstack = topstack - 1
                                        end
                                        local newdir = dirstack[topstack]
                                        if newdir == "+TRT" then
                                            rlmode = -1
                                        elseif newdir == "+TLT" then
                                            rlmode = 1
                                        else
                                            rlmode = rlparmode
                                        end
                                        if trace_directions then
                                            report_process("directions after txtdir %a: parmode %a, txtmode %a, # stack %a, new dir %a",dir,rlparmode,rlmode,topstack,newdir)
                                        end
                                    elseif subtype == localpar_code then
                                        local dir = start.dir
                                        if dir == "TRT" then
                                            rlparmode = -1
                                        elseif dir == "TLT" then
                                            rlparmode = 1
                                        else
                                            rlparmode = 0
                                        end
                                        rlmode = rlparmode
                                        if trace_directions then
                                            report_process("directions after pardir %a: parmode %a, txtmode %a",dir,rlparmode,rlmode)
                                        end
                                    end
                                    start = start.next
                                elseif id == math_code then
                                    start = end_of_math(start).next
                                else
                                    start = start.next
                                end
                            end
                        end
                    else
                        while start do
                            local id = start.id
                            if id == glyph_code then
                                if start.font == font and start.subtype<256 then
                                    local a = start[0]
                                    if a then
                                        a = (a == attr) and (not attribute or start[a_state] == attribute)
                                    else
                                        a = not attribute or start[a_state] == attribute
                                    end
                                    if a then
                                        for i=1,ns do
                                            local lookupname = subtables[i]
                                            local lookupcache = lookuphash[lookupname]
                                            if lookupcache then
                                                local lookupmatch = lookupcache[start.char]
                                                if lookupmatch then
                                                    -- we could move all code inline but that makes things even more unreadable
                                                    local ok
                                                    head, start, ok = handler(head,start,dataset[4],lookupname,lookupmatch,sequence,lookuphash,i)
                                                    if ok then
                                                        success = true
                                                        break
                                                    end
                                                end
                                            else
                                                report_missing_cache(typ,lookupname)
                                            end
                                        end
                                        if start then start = start.next end
                                    else
                                        start = start.next
                                    end
                                else
                                    start = start.next
                                end
                            elseif id == whatsit_code then
                                local subtype = start.subtype
                                if subtype == dir_code then
                                    local dir = start.dir
                                    if     dir == "+TRT" or dir == "+TLT" then
                                        topstack = topstack + 1
                                        dirstack[topstack] = dir
                                    elseif dir == "-TRT" or dir == "-TLT" then
                                        topstack = topstack - 1
                                    end
                                    local newdir = dirstack[topstack]
                                    if newdir == "+TRT" then
                                        rlmode = -1
                                    elseif newdir == "+TLT" then
                                        rlmode = 1
                                    else
                                        rlmode = rlparmode
                                    end
                                    if trace_directions then
                                        report_process("directions after txtdir %a: parmode %a, txtmode %a, # stack %a, new dir %a",dir,rlparmode,rlmode,topstack,newdir)
                                    end
                                elseif subtype == localpar_code then
                                    local dir = start.dir
                                    if dir == "TRT" then
                                        rlparmode = -1
                                    elseif dir == "TLT" then
                                        rlparmode = 1
                                    else
                                        rlparmode = 0
                                    end
                                    rlmode = rlparmode
                                    if trace_directions then
                                        report_process("directions after pardir %a: parmode %a, txtmode %a",dir,rlparmode,rlmode)
                                    end
                                end
                                start = start.next
                            elseif id == math_code then
                                start = end_of_math(start).next
                            else
                                start = start.next
                            end
                        end
                    end
                end
                if success then
                    done = true
                end
                if trace_steps then -- ?
                    registerstep(head)
                end

--             end
--         else
--          -- report_process("warning, no dataset %a",s)
--         end

    end
    return head, done
end

local function generic(lookupdata,lookupname,unicode,lookuphash)
    local target = lookuphash[lookupname]
    if target then
        target[unicode] = lookupdata
    else
        lookuphash[lookupname] = { [unicode] = lookupdata }
    end
end

local action = {

    substitution = generic,
    multiple     = generic,
    alternate    = generic,
    position     = generic,

    ligature = function(lookupdata,lookupname,unicode,lookuphash)
        local target = lookuphash[lookupname]
        if not target then
            target = { }
            lookuphash[lookupname] = target
        end
        for i=1,#lookupdata do
            local li = lookupdata[i]
            local tu = target[li]
            if not tu then
                tu = { }
                target[li] = tu
            end
            target = tu
        end
        target.ligature = unicode
    end,

    pair = function(lookupdata,lookupname,unicode,lookuphash)
        local target = lookuphash[lookupname]
        if not target then
            target = { }
            lookuphash[lookupname] = target
        end
        local others = target[unicode]
        local paired = lookupdata[1]
        if others then
            others[paired] = lookupdata
        else
            others = { [paired] = lookupdata }
            target[unicode] = others
        end
    end,

}

local function prepare_lookups(tfmdata)

    local rawdata          = tfmdata.shared.rawdata
    local resources        = rawdata.resources
    local lookuphash       = resources.lookuphash
    local anchor_to_lookup = resources.anchor_to_lookup
    local lookup_to_anchor = resources.lookup_to_anchor
    local lookuptypes      = resources.lookuptypes
    local characters       = tfmdata.characters
    local descriptions     = tfmdata.descriptions

    -- we cannot free the entries in the descriptions as sometimes we access
    -- then directly (for instance anchors) ... selectively freeing does save
    -- much memory as it's only a reference to a table and the slot in the
    -- description hash is not freed anyway

    for unicode, character in next, characters do -- we cannot loop over descriptions !

        local description = descriptions[unicode]

        if description then

            local lookups = description.slookups
            if lookups then
                for lookupname, lookupdata in next, lookups do
                    action[lookuptypes[lookupname]](lookupdata,lookupname,unicode,lookuphash)
                end
            end

            local lookups = description.mlookups
            if lookups then
                for lookupname, lookuplist in next, lookups do
                    local lookuptype = lookuptypes[lookupname]
                    for l=1,#lookuplist do
                        local lookupdata = lookuplist[l]
                        action[lookuptype](lookupdata,lookupname,unicode,lookuphash)
                    end
                end
            end

            local list = description.kerns
            if list then
                for lookup, krn in next, list do  -- ref to glyph, saves lookup
                    local target = lookuphash[lookup]
                    if target then
                        target[unicode] = krn
                    else
                        lookuphash[lookup] = { [unicode] = krn }
                    end
                end
            end

            local list = description.anchors
            if list then
                for typ, anchors in next, list do -- types
                    if typ == "mark" or typ == "cexit" then -- or entry?
                        for name, anchor in next, anchors do
                            local lookups = anchor_to_lookup[name]
                            if lookups then
                                for lookup, _ in next, lookups do
                                    local target = lookuphash[lookup]
                                    if target then
                                        target[unicode] = anchors
                                    else
                                        lookuphash[lookup] = { [unicode] = anchors }
                                    end
                                end
                            end
                        end
                    end
                end
            end

        end

    end

end

local function split(replacement,original)
    local result = { }
    for i=1,#replacement do
        result[original[i]] = replacement[i]
    end
    return result
end

local valid = {
    coverage        = { chainsub = true, chainpos = true, contextsub = true },
    reversecoverage = { reversesub = true },
    glyphs          = { chainsub = true, chainpos = true },
}

local function prepare_contextchains(tfmdata)
    local rawdata    = tfmdata.shared.rawdata
    local resources  = rawdata.resources
    local lookuphash = resources.lookuphash
    local lookups    = rawdata.lookups
    if lookups then
        for lookupname, lookupdata in next, rawdata.lookups do
            local lookuptype = lookupdata.type
            if lookuptype then
                local rules = lookupdata.rules
                if rules then
                    local format = lookupdata.format
                    local validformat = valid[format]
                    if not validformat then
                        report_prepare("unsupported format %a",format)
                    elseif not validformat[lookuptype] then
                        -- todo: dejavu-serif has one (but i need to see what use it has)
                        report_prepare("unsupported format %a, lookuptype %a, lookupname %a",format,lookuptype,lookupname)
                    else
                        local contexts = lookuphash[lookupname]
                        if not contexts then
                            contexts = { }
                            lookuphash[lookupname] = contexts
                        end
                        local t, nt = { }, 0
                        for nofrules=1,#rules do
                            local rule         = rules[nofrules]
                            local current      = rule.current
                            local before       = rule.before
                            local after        = rule.after
                            local replacements = rule.replacements
                            local sequence     = { }
                            local nofsequences = 0
                            -- Eventually we can store start, stop and sequence in the cached file
                            -- but then less sharing takes place so best not do that without a lot
                            -- of profiling so let's forget about it.
                            if before then
                                for n=1,#before do
                                    nofsequences = nofsequences + 1
                                    sequence[nofsequences] = before[n]
                                end
                            end
                            local start = nofsequences + 1
                            for n=1,#current do
                                nofsequences = nofsequences + 1
                                sequence[nofsequences] = current[n]
                            end
                            local stop = nofsequences
                            if after then
                                for n=1,#after do
                                    nofsequences = nofsequences + 1
                                    sequence[nofsequences] = after[n]
                                end
                            end
                            if sequence[1] then
                                -- Replacements only happen with reverse lookups as they are single only. We
                                -- could pack them into current (replacement value instead of true) and then
                                -- use sequence[start] instead but it's somewhat ugly.
                                nt = nt + 1
                                t[nt] = { nofrules, lookuptype, sequence, start, stop, rule.lookups, replacements }
                                for unic, _  in next, sequence[start] do
                                    local cu = contexts[unic]
                                    if not cu then
                                        contexts[unic] = t
                                    end
                                end
                            end
                        end
                    end
                else
                    -- no rules
                end
            else
                report_prepare("missing lookuptype for lookupname %a",lookupname)
            end
        end
    end
end

-- we can consider lookuphash == false (initialized but empty) vs lookuphash == table

local function featuresinitializer(tfmdata,value)
    if true then -- value then
        -- beware we need to use the topmost properties table
        local rawdata    = tfmdata.shared.rawdata
        local properties = rawdata.properties
        if not properties.initialized then
            local starttime = trace_preparing and os.clock()
            local resources = rawdata.resources
            resources.lookuphash = resources.lookuphash or { }
            prepare_contextchains(tfmdata)
            prepare_lookups(tfmdata)
            properties.initialized = true
            if trace_preparing then
                report_prepare("preparation time is %0.3f seconds for %a",os.clock()-starttime,tfmdata.properties.fullname)
            end
        end
    end
end

registerotffeature {
    name         = "features",
    description  = "features",
    default      = true,
    initializers = {
        position = 1,
        node     = featuresinitializer,
    },
    processors   = {
        node     = featuresprocessor,
    }
}

-- This can be used for extra handlers, but should be used with care!

otf.handlers = handlers
