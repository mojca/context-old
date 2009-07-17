if not modules then modules = { } end modules ['font-tfm'] = {
    version   = 1.001,
    comment   = "companion to font-ini.tex",
    author    = "Hans Hagen, PRAGMA-ADE, Hasselt NL",
    copyright = "PRAGMA ADE / ConTeXt Development Team",
    license   = "see context related readme files"
}

local utf = unicode.utf8

local next, format, match, lower = next, string.format, string.match, string.lower
local concat, sortedkeys, utfbyte, serialize = table.concat, table.sortedkeys, utf.byte, table.serialize

local trace_defining = false  trackers.register("fonts.defining", function(v) trace_defining = v end)
local trace_scaling  = false  trackers.register("fonts.scaling" , function(v) trace_scaling  = v end)

-- tfmdata has also fast access to indices and unicodes
-- to be checked: otf -> tfm -> tfmscaled
--
-- watch out: no negative depths and negative eights permitted in regular fonts

--[[ldx--
<p>Here we only implement a few helper functions.</p>
--ldx]]--

fonts     = fonts     or { }
fonts.tfm = fonts.tfm or { }
fonts.ids = fonts.ids or { }

local tfm = fonts.tfm

fonts.loaded              = fonts.loaded    or { }
fonts.dontembed           = fonts.dontembed or { }
fonts.triggers            = fonts.triggers  or { } -- brrr
fonts.initializers        = fonts.initializers        or { }
fonts.initializers.common = fonts.initializers.common or { }

local fontdata      = fonts.ids
local glyph         = node.id('glyph')
local set_attribute = node.set_attribute

--[[ldx--
<p>The next function encapsulates the standard <l n='tfm'/> loader as
supplied by <l n='luatex'/>.</p>
--ldx]]--

tfm.resolve_vf       = true  -- false
tfm.share_base_kerns = false -- true (.5 sec slower on mk but brings down mem from 410M to 310M, beware: then script/lang share too)
tfm.mathactions      = { }

function tfm.enhance(tfmdata,specification)
    local name, size = specification.name, specification.size
    local encoding, filename = match(name,"^(.-)%-(.*)$") -- context: encoding-name.*
    if filename and encoding and fonts.enc.known[encoding] then
        local data = fonts.enc.load(encoding)
        if data then
            local characters = tfmdata.characters
            tfmdata.encoding = encoding
            local vector = data.vector
            local original = { }
            for k, v in next, characters do
                v.name = vector[k]
                v.index = k
                original[k] = v
            end
            for k,v in next, data.unicodes do
                if k ~= v then
                    if trace_defining then
                        logs.report("define font","mapping %s onto %s",k,v)
                    end
                    characters[k] = original[v]
                end
            end
        end
    end
end

function tfm.read_from_tfm(specification)
    local fname, tfmdata = specification.filename or "", nil
    if fname ~= "" then
        if trace_defining then
            logs.report("define font","loading tfm file %s at size %s",fname,specification.size)
        end
        tfmdata = font.read_tfm(fname,specification.size) -- not cached, fast enough
        if tfmdata then
            tfmdata.descriptions = tfmdata.descriptions or { }
            if tfm.resolve_vf then
                fonts.logger.save(tfmdata,file.extname(fname),specification) -- strange, why here
                fname = resolvers.findbinfile(specification.name, 'ovf')
                if fname and fname ~= "" then
                    local vfdata = font.read_vf(fname,specification.size) -- not cached, fast enough
                    if vfdata then
                        local chars = tfmdata.characters
                        for k,v in next, vfdata.characters do
                            chars[k].commands = v.commands
                        end
                        tfmdata.type = 'virtual'
                        tfmdata.fonts = vfdata.fonts
                    end
                end
            end
            tfm.enhance(tfmdata,specification)
        end
    elseif trace_defining then
        logs.report("define font","loading tfm with name %s fails",specification.name)
    end
    return tfmdata
end

--[[ldx--
<p>We need to normalize the scale factor (in scaled points). This has to
do with the fact that <l n='tex'/> uses a negative multiple of 1000 as
a signal for a font scaled based on the design size.</p>
--ldx]]--

local factors = {
    pt = 65536.0,
    bp = 65781.8,
}

function tfm.setfactor(f)
    tfm.factor = factors[f or 'pt'] or factors.pt
end

tfm.setfactor()

function tfm.scaled(scaledpoints, designsize) -- handles designsize in sp as well
    if scaledpoints < 0 then
        if designsize then
            if designsize > tfm.factor then -- or just 1000 / when? mp?
                return (- scaledpoints/1000) * designsize -- sp's
            else
                return (- scaledpoints/1000) * designsize * tfm.factor
            end
        else
            return (- scaledpoints/1000) * 10 * tfm.factor
        end
    else
        return scaledpoints
    end
end

--[[ldx--
<p>Before a font is passed to <l n='tex'/> we scale it. Here we also need
to scale virtual characters.</p>
--ldx]]--

function tfm.get_virtual_id(tfmdata)
    --  since we don't know the id yet, we use 0 as signal
    if not tfmdata.fonts then
        tfmdata.type = "virtual"
        tfmdata.fonts = { { id = 0 } }
        return 1
    else
        tfmdata.fonts[#tfmdata.fonts+1] = { id = 0 }
        return #tfmdata.fonts
    end
end

function tfm.check_virtual_id(tfmdata, id)
    if tfmdata and tfmdata.type == "virtual" then
        if not tfmdata.fonts or #tfmdata.fonts == 0 then
            tfmdata.type, tfmdata.fonts = "real", nil
        else
            local vfonts = tfmdata.fonts
            for f=1,#vfonts do
                local fnt = vfonts[f]
                if fnt.id and fnt.id == 0 then
                    fnt.id = id
                end
            end
        end
    end
end

--[[ldx--
<p>Beware, the boundingbox is passed as reference so we may not overwrite it
in the process; numbers are of course copies. Here 65536 equals 1pt. (Due to
excessive memory usage in CJK fonts, we no longer pass the boundingbox.)</p>
--ldx]]--

fonts.trace_scaling = false

-- the following hack costs a bit of runtime but safes memory
--
-- basekerns are scaled and will be hashed by table id
-- sharedkerns are unscaled and are be hashed by concatenated indexes

function tfm.check_base_kerns(tfmdata)
    if tfm.share_base_kerns then
        local sharedkerns = tfmdata.sharedkerns
        if sharedkerns then
            local basekerns = { }
            tfmdata.basekerns = basekerns
            return sharedkerns, basekerns
        end
    end
    return nil, nil
end

function tfm.prepare_base_kerns(tfmdata)
    if tfm.share_base_kerns and not tfmdata.sharedkerns then
        local sharedkerns = { }
        tfmdata.sharedkerns = sharedkerns
        for u, chr in next, tfmdata.characters do
            local kerns = chr.kerns
            if kerns then
                local hash = concat(sortedkeys(kerns), " ")
                local base = sharedkerns[hash]
                if not base then
                    sharedkerns[hash] = kerns
                else
                    chr.kerns = base
                end
            end
        end
    end
end

-- we can have cache scaled characters when we are in node mode and don't have
-- protruding and expansion: hash == fullname @ size @ protruding @ expansion
-- but in practice (except from mk) the otf hash will be enough already so it
-- makes no sense to mess  up the code now

local charactercache = { }

-- The scaler is only used for otf and afm and virtual fonts. If
-- a virtual font has italic correction make sur eto set the
-- has_italic flag. Some more flags will be added in the future.

function tfm.do_scale(tfmtable, scaledpoints)
    tfm.prepare_base_kerns(tfmtable) -- optimalization
    if scaledpoints < 0 then
        scaledpoints = (- scaledpoints/1000) * tfmtable.designsize -- already in sp
    end
    local delta = scaledpoints/(tfmtable.units or 1000) -- brr, some open type fonts have 2048
    local t = { }
    -- unicoded unique descriptions shared cidinfo characters changed parameters indices
    for k,v in next, tfmtable do
        if type(v) == "table" then
        --  print(k)
        else
            t[k] = v
        end
    end
    -- status
    local isvirtual = tfmtable.type == "virtual" or tfmtable.virtualized
    local hasmath = (tfmtable.math_parameters ~= nil and next(tfmtable.math_parameters) ~= nil) or (tfmtable.MathConstants ~= nil and next(tfmtable.MathConstants) ~= nil)
    local nodemode = tfmtable.mode == "node"
    local hasquality = tfmtable.auto_expand or tfmtable.auto_protrude
    local hasitalic = tfmtable.has_italic
    --
    t.parameters = { }
    t.characters = { }
    t.MathConstants = { }
    -- fast access
    local descriptions = tfmtable.descriptions or { }
    t.unicodes = tfmtable.unicodes
    t.indices = tfmtable.indices
    t.marks = tfmtable.marks
    t.descriptions = descriptions
    if tfmtable.fonts then
        t.fonts = table.fastcopy(tfmtable.fonts) -- hm  also at the end
    end
    local tp = t.parameters
    local mp = t.math_parameters
    local tfmp = tfmtable.parameters -- let's check for indexes
    --
    tp.slant         = (tfmp.slant         or tfmp[1] or 0)
    tp.space         = (tfmp.space         or tfmp[2] or 0)*delta
    tp.space_stretch = (tfmp.space_stretch or tfmp[3] or 0)*delta
    tp.space_shrink  = (tfmp.space_shrink  or tfmp[4] or 0)*delta
    tp.x_height      = (tfmp.x_height      or tfmp[5] or 0)*delta
    tp.quad          = (tfmp.quad          or tfmp[6] or 0)*delta
    tp.extra_space   = (tfmp.extra_space   or tfmp[7] or 0)*delta
    local protrusionfactor = (tp.quad ~= 0 and 1000/tp.quad) or 0
    local tc = t.characters
    local characters = tfmtable.characters
    local nameneeded = not tfmtable.shared.otfdata --hack
    local changed = tfmtable.changed or { } -- for base mode
    local ischanged = not table.is_empty(changed)
    local indices = tfmtable.indices
    local luatex = tfmtable.luatex
    local tounicode = luatex and luatex.tounicode
    local defaultwidth  = luatex and luatex.defaultwidth  or 0
    local defaultheight = luatex and luatex.defaultheight or 0
    local defaultdepth  = luatex and luatex.defaultdepth  or 0
    -- experimental, sharing kerns (unscaled and scaled) saves memory
    local sharedkerns, basekerns = tfm.check_base_kerns(tfmtable)
    -- loop over descriptions (afm and otf have descriptions, tfm not)
    -- there is no need (yet) to assign a value to chr.tonunicode
    local scaledwidth  = defaultwidth  * delta
    local scaledheight = defaultheight * delta
    local scaleddepth  = defaultdepth  * delta
    local stackmath = tfmtable.ignore_stack_math ~= true
local private = fonts.private
    for k,v in next, characters do
        local chr, description, index
        if ischanged then
            -- basemode hack
            local c = changed[k]
            if c then
                description = descriptions[c] or v
                v = characters[c] or v
                index = (indices and indices[c]) or c
            else
                description = descriptions[k] or v
                index = (indices and indices[k]) or k
            end
        else
            description = descriptions[k] or v
            index = (indices and indices[k]) or k
        end
        local width  = description.width
        local height = description.height
        local depth  = description.depth
        if width  then width  = delta*width  else width  = scaledwidth  end
        if height then height = delta*height else height = scaledheight end
    --  if depth  then depth  = delta*depth  else depth  = scaleddepth  end
        if depth and depth ~= 0 then
            depth = delta*depth
            if nameneeded then
                chr = {
                    name   = description.name,
                    index  = index,
                    height = height,
                    depth  = depth,
                    width  = width,
                }
            else
                chr = {
                    index  = index,
                    height = height,
                    depth  = depth,
                    width  = width,
                }
            end
        else
            -- this saves a little bit of memory time and memory, esp for big cjk fonts
            if nameneeded then
                chr = {
                    name   = description.name,
                    index  = index,
                    height = height,
                    width  = width,
                }
            else
                chr = {
                    index  = index,
                    height = height,
                    width  = width,
                }
            end
        end
    --  if trace_scaling then
    --      logs.report("define font","t=%s, u=%s, i=%s, n=%s c=%s",k,chr.tounicode or k,description.index,description.name or '-',description.class or '-')
    --  end
        if tounicode then
            local tu = tounicode[index] -- nb: index!
            if tu then
                chr.tounicode = tu
            end
        end
        if hasquality then
            local ve = v.expansion_factor
            if ve then
                chr.expansion_factor = ve*1000 -- expansionfactor, hm, can happen elsewhere
            end
            local vl = v.left_protruding
            if vl then
                chr.left_protruding  = protrusionfactor*width*vl
            end
            local vr = v.right_protruding
            if vr then
                chr.right_protruding  = protrusionfactor*width*vr
            end
        end
        -- todo: hasitalic
        if hasitalic then
            local vi = description.italic or v.italic
            if vi and vi ~= 0 then
                chr.italic = vi*delta
            end
        end
        -- to be tested
        if hasmath then
            -- todo, just operate on descriptions.math
            local vn = v.next
            if vn then
                chr.next = vn
            else
                local vv = v.vert_variants
                if vv then
                    local t = { }
                    for i=1,#vv do
                        local vvi = vv[i]
                        t[i] = {
                            ["start"]    = (vvi["start"]   or 0)*delta,
                            ["end"]      = (vvi["end"]     or 0)*delta,
                            ["advance"]  = (vvi["advance"] or 0)*delta,
                            ["extender"] =  vvi["extender"],
                            ["glyph"]    =  vvi["glyph"],
                        }
                    end
                    chr.vert_variants = t
                else
                    local hv = v.horiz_variants
                    if hv then
                        local t = { }
                        for i=1,#hv do
                            local hvi = hv[i]
                            t[i] = {
                                ["start"]    = (hvi["start"]   or 0)*delta,
                                ["end"]      = (hvi["end"]     or 0)*delta,
                                ["advance"]  = (hvi["advance"] or 0)*delta,
                                ["extender"] =  hvi["extender"],
                                ["glyph"]    =  hvi["glyph"],
                            }
                        end
                        chr.horiz_variants = t
                    end
                end
            end
            local vt = description.top_accent
            if vt then
                chr.top_accent = delta*vt
            end
            if stackmath then
                local mk = v.mathkerns
                if mk then
                    local kerns = { }
                 -- for k, v in next, mk do
                 --     local kk = { }
                  --     for i=1,#v do
                 --         local vi = v[i]
                 --         kk[i] = { height = delta*vi.height, kern = delta*vi.kern }
                 --     end
                 --     kerns[k] = kk
                 -- end
                    local v = mk.top_right    if v then local k = { } for i=1,#v do local vi = v[i]
                        k[i] = { height = delta*vi.height, kern = delta*vi.kern }
                    end     kerns.top_right    = k end
                    local v = mk.top_left     if v then local k = { } for i=1,#v do local vi = v[i]
                        k[i] = { height = delta*vi.height, kern = delta*vi.kern }
                    end     kerns.top_left     = k end
                    local v = mk.bottom_left  if v then local k = { } for i=1,#v do local vi = v[i]
                        k[i] = { height = delta*vi.height, kern = delta*vi.kern }
                    end     kerns.bottom_left  = k end
                    local v = mk.bottom_right if v then local k = { } for i=1,#v do local vi = v[i]
                        k[i] = { height = delta*vi.height, kern = delta*vi.kern }
                    end     kerns.bottom_right = k end
                    chr.mathkern = kerns -- singular
                end
            end
        end
        if not nodemode then
            local vk = v.kerns
            if vk then
                if sharedkerns then
                    local base = basekerns[vk] -- hashed by table id, not content
                    if not base then
                        base = {}
                        for k,v in next, vk do base[k] = v*delta end
                        basekerns[vk] = base
                    end
                    chr.kerns = base
                else
                    local tt = {}
                    for k,v in next, vk do tt[k] = v*delta end
                    chr.kerns = tt
                end
            end
            local vl = v.ligatures
            if vl then
                if true then
                    chr.ligatures = vl -- shared
                else
                    local tt = { }
                    for i,l in next, vl do
                        tt[i] = l
                    end
                    chr.ligatures = tt
                end
            end
        end
        if isvirtual then
            local vc = v.commands
            if vc then
                -- we assume non scaled commands here
                local ok = false
                for i=1,#vc do
                    local key = vc[i][1]
                    if key == "right" or key == "down" then
                        ok = true
                        break
                    end
                end
                if ok then
                    local tt = { }
                    for i=1,#vc do
                        local ivc = vc[i]
                        local key = ivc[1]
                        if key == "right" or key == "down" then
                            tt[#tt+1] = { key, ivc[2]*delta }
                        else -- not comment
                            tt[#tt+1] = ivc -- shared since in cache and untouched
                        end
                    end
                    chr.commands = tt
                else
                    chr.commands = vc
                end
            end
        end
        tc[k] = chr
    end
    -- t.encodingbytes, t.filename, t.fullname, t.name: elsewhere
    t.size = scaledpoints
    t.factor = delta
    if t.fonts then
        t.fonts = table.fastcopy(t.fonts) -- maybe we virtualize more afterwards
    end
    if hasmath then
     -- mathematics.extras.copy(t) -- can be done elsewhere if needed
        local ma = tfm.mathactions
        for i=1,#ma do
            ma[i](t,tfmtable,delta)
        end
    end
    -- needed for \high cum suis
    local tpx = tp.x_height
if hasmath then
    if not tp[13] then tp[13] = .86*tpx end  -- mathsupdisplay
    if not tp[14] then tp[14] = .86*tpx end  -- mathsupnormal
    if not tp[15] then tp[15] = .86*tpx end  -- mathsupcramped
    if not tp[16] then tp[16] = .48*tpx end  -- mathsubnormal
    if not tp[17] then tp[17] = .48*tpx end  -- mathsubcombined
    if not tp[22] then tp[22] =   0     end  -- mathaxisheight
    if t.MathConstants then t.MathConstants.AccentBaseHeight = nil end -- safeguard
end
    t.tounicode = 1
    t.cidinfo = tfmtable.cidinfo
    -- we have t.name=metricfile and t.fullname=RealName and t.filename=diskfilename
    -- when collapsing fonts, luatex looks as both t.name and t.fullname as ttc files
    -- can have multiple subfonts
    if hasmath then
        if trace_defining then
            logs.report("define font","math enabled for: %s %s %s",t.name or "noname",t.fullname or "nofullname",t.filename or "nofilename")
        end
    else
        if trace_defining then
            logs.report("define font","math disabled for: %s %s %s",t.name or "noname",t.fullname or "nofullname",t.filename or "nofilename")
        end
        t.nomath, t.MathConstants = true, nil
    end
    return t, delta
end

--[[ldx--
<p>The reason why the scaler is split, is that for a while we experimented
with a helper function. However, in practice the <l n='api'/> calls are too slow to
make this profitable and the <l n='lua'/> based variant was just faster. A days
wasted day but an experience richer.</p>
--ldx]]--

tfm.auto_cleanup = true

local lastfont = nil

-- we can get rid of the tfm instance when we have fast access to the
-- scaled character dimensions at the tex end, e.g. a fontobject.width
--
-- flushing the kern and ligature tables from memory saves a lot (only
-- base mode) but it complicates vf building where the new characters
-- demand this data

--~ for id, f in pairs(fonts.ids) do -- or font.fonts
--~     local ffi = font.fonts[id]
--~     f.characters = ffi.characters
--~     f.kerns = ffi.kerns
--~     f.ligatures = ffi.ligatures
--~ end

function tfm.cleanup_table(tfmdata) -- we need a cleanup callback, now we miss the last one
    if tfm.auto_cleanup then  -- ok, we can hook this into everyshipout or so ... todo
        if tfmdata.type == 'virtual' or tfmdata.virtualized then
            for k, v in next, tfmdata.characters do
                if v.commands then v.commands  = nil end
            end
        end
    end
end

function tfm.cleanup(tfmdata) -- we need a cleanup callback, now we miss the last one
end

function tfm.scale(tfmtable, scaledpoints)
    local t, factor = tfm.do_scale(tfmtable, scaledpoints)
    t.factor    = factor
    t.ascender  = factor*(tfmtable.ascender  or 0)
    t.descender = factor*(tfmtable.descender or 0)
    t.shared    = tfmtable.shared or { }
    t.unique    = table.fastcopy(tfmtable.unique or {})
--~ print("scaling", t.name, t.factor) -- , tfm.hash_features(tfmtable.specification))
    tfm.cleanup(t)
    return t
end

--[[ldx--
<p>Analyzers run per script and/or language and are needed in order to
process features right.</p>
--ldx]]--

fonts.analyzers              = fonts.analyzers              or { }
fonts.analyzers.aux          = fonts.analyzers.aux          or { }
fonts.analyzers.methods      = fonts.analyzers.methods      or { }
fonts.analyzers.initializers = fonts.analyzers.initializers or { }

-- todo: analyzers per script/lang, cross font, so we need an font id hash -> script
-- e.g. latin -> hyphenate, arab -> 1/2/3 analyze

-- an example analyzer (should move to font-ota.lua)

local state = attributes.private('state')

function fonts.analyzers.aux.setstate(head,font)
    local tfmdata = fontdata[font]
    local characters = tfmdata.characters
    local descriptions = tfmdata.descriptions
    local first, last, current, n, done = nil, nil, head, 0, false -- maybe make n boolean
    while current do
        if current.id == glyph and current.font == font then
            local d = descriptions[current.char]
            if d then
                if d.class == "mark" then
                    done = true
                    set_attribute(current,state,5) -- mark
                elseif n == 0 then
                    first, last, n = current, current, 1
                    set_attribute(current,state,1) -- init
                else
                    last, n = current, n+1
                    set_attribute(current,state,2) -- medi
                end
            else -- finish
                if first and first == last then
                    set_attribute(last,state,4) -- isol
                elseif last then
                    set_attribute(last,state,3) -- fina
                end
                first, last, n = nil, nil, 0
            end
        else -- finish
            if first and first == last then
                set_attribute(last,state,4) -- isol
            elseif last then
                set_attribute(last,state,3) -- fina
            end
            first, last, n = nil, nil, 0
        end
        current = current.next
    end
    if first and first == last then
        set_attribute(last,state,4) -- isol
    elseif last then
        set_attribute(last,state,3) -- fina
    end
    return head, done
end

function tfm.replacements(tfm,value)
 -- tfm.characters[0x0022] = table.fastcopy(tfm.characters[0x201D])
 -- tfm.characters[0x0027] = table.fastcopy(tfm.characters[0x2019])
 -- tfm.characters[0x0060] = table.fastcopy(tfm.characters[0x2018])
 -- tfm.characters[0x0022] = tfm.characters[0x201D]
    tfm.characters[0x0027] = tfm.characters[0x2019]
 -- tfm.characters[0x0060] = tfm.characters[0x2018]
end

-- auto complete font with missing composed characters

table.insert(fonts.manipulators,"compose")

function fonts.initializers.common.compose(tfmdata,value)
    if value then
        fonts.vf.aux.compose_characters(tfmdata)
    end
end

-- tfm features, experimental

tfm.features         = tfm.features         or { }
tfm.features.list    = tfm.features.list    or { }
tfm.features.default = tfm.features.default or { }

function tfm.enhance(tfmdata,specification)
    -- we don't really share tfm data because we always reload
    -- but this is more in sycn with afm and such
    local features = (specification.features and specification.features.normal ) or { }
    tfmdata.shared = tfmdata.shared or { }
    tfmdata.shared.features = features
    --  tfmdata.shared.tfmdata = tfmdata -- circular
    tfmdata.filename = specification.name
    if not features.encoding then
        local name, size = specification.name, specification.size
        local encoding, filename = match(name,"^(.-)%-(.*)$") -- context: encoding-name.*
        if filename and encoding and fonts.enc.known[encoding] then
            features.encoding = encoding
        end
    end
    tfm.set_features(tfmdata)
end

function tfm.set_features(tfmdata)
    -- todo: no local functions
    local shared = tfmdata.shared
--  local tfmdata = shared.tfmdata
    local features = shared.features
    if not table.is_empty(features) then
        local mode = tfmdata.mode or fonts.mode
        local fi = fonts.initializers[mode]
        if fi and fi.tfm then
            local function initialize(list) -- using tex lig and kerning
                if list then
                    for i=1,#list do
                        local f = list[i]
                        local value = features[f]
                        if value and fi.tfm[f] then -- brr
                            if tfm.trace_features then
                                logs.report("define font","initializing feature %s to %s for mode %s for font %s",f,tostring(value),mode or 'unknown',tfmdata.name or 'unknown')
                            end
                            fi.tfm[f](tfmdata,value)
                            mode = tfmdata.mode or fonts.mode
                            fi = fonts.initializers[mode]
                        end
                    end
                end
            end
            initialize(fonts.triggers)
            initialize(tfm.features.list)
            initialize(fonts.manipulators)
        end
        local fm = fonts.methods[mode]
        if fm and fm.tfm then
            local function register(list) -- node manipulations
                if list then
                    for i=1,#list do
                        local f = list[i]
                        if features[f] and fm.tfm[f] then -- brr
                            if not shared.processors then -- maybe also predefine
                                shared.processors = { fm.tfm[f] }
                            else
                                shared.processors[#shared.processors+1] = fm.tfm[f]
                            end
                        end
                    end
                end
            end
            register(tfm.features.list)
        end
    end
end

function tfm.features.register(name,default)
    tfm.features.list[#tfm.features.list+1] = name
    tfm.features.default[name] = default
end

function tfm.reencode(tfmdata,encoding)
    if encoding and fonts.enc.known[encoding] then
        local data = fonts.enc.load(encoding)
        if data then
            local characters, original, vector = tfmdata.characters, { }, data.vector
            tfmdata.encoding = encoding -- not needed
            for k, v in next, characters do
                v.name, v.index, original[k] = vector[k], k, v
            end
            for k,v in next, data.unicodes do
                if k ~= v then
                    if trace_defining then
                        logs.report("define font","reencoding U+%04X to U+%04X",k,v)
                    end
                    characters[k] = original[v]
                end
            end
        end
    end
end

tfm.features.register('reencode')

fonts.initializers.base.tfm.reencode = tfm.reencode
fonts.initializers.node.tfm.reencode = tfm.reencode

fonts.enc            = fonts.enc            or { }
fonts.enc.remappings = fonts.enc.remappings or { }

function tfm.remap(tfmdata,remapping)
    local vector = remapping and fonts.enc.remappings[remapping]
    if vector then
        local characters, original = tfmdata.characters, { }
        for k, v in next, characters do
            original[k], characters[k] = v, nil
        end
        for k,v in next, vector do
            if k ~= v then
                if trace_defining then
                    logs.report("define font","remapping U+%04X to U+%04X",k,v)
                end
                local c = original[k]
                characters[v] = c
                c.index = k
            end
        end
        tfmdata.encodingbytes = 2
        tfmdata.format = 'type1'
    end
end

tfm.features.register('remap')

fonts.initializers.base.tfm.remap = tfm.remap
fonts.initializers.node.tfm.remap = tfm.remap

-- status info

statistics.register("fonts load time", function()
    if statistics.elapsedindeed(fonts) then
        return format("%s seconds",statistics.elapsedtime(fonts))
    end
end)
