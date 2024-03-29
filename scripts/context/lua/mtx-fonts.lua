if not modules then modules = { } end modules ['mtx-fonts'] = {
    version   = 1.001,
    comment   = "companion to mtxrun.lua",
    author    = "Hans Hagen, PRAGMA-ADE, Hasselt NL",
    copyright = "PRAGMA ADE / ConTeXt Development Team",
    license   = "see context related readme files"
}

local getargument = environment.getargument
local setargument = environment.setargument
local givenfiles  = environment.files

local helpinfo = [[
<?xml version="1.0"?>
<application>
 <metadata>
  <entry name="name">mtx-fonts</entry>
  <entry name="detail">ConTeXt Font Database Management</entry>
  <entry name="version">0.21</entry>
 </metadata>
 <flags>
  <category name="basic">
   <subcategory>
    <flag name="save"><short>save open type font in raw table</short></flag>
    <flag name="unpack"><short>save a tma file in a more readale format</short></flag>
   </subcategory>
   <subcategory>
    <flag name="reload"><short>generate new font database (use <ref name="force"/> when in doubt)</short></flag>
    <flag name="reload"><short><ref name="simple"/>:generate luatex-fonts-names.lua (not for context!)</short></flag>
   </subcategory>
   <subcategory>
    <flag name="list"><short><ref name="name"/>: list installed fonts, filter by name [<ref name="pattern"/>]</short></flag>
    <flag name="list"><short><ref name="spec"/>: list installed fonts, filter by spec [<ref name="filter"/>]</short></flag>
    <flag name="list"><short><ref name="file"/>: list installed fonts, filter by file [<ref name="pattern"/>]</short></flag>
   </subcategory>
   <subcategory>
    <flag name="pattern" value="str"><short>filter files using pattern</short></flag>
    <flag name="filter" value="list"><short>key-value pairs</short></flag>
    <flag name="all"><short>show all found instances (combined with other flags)</short></flag>
    <flag name="info"><short>give more details</short></flag>
    <flag name="track" value="list"><short>enable trackers</short></flag>
    <flag name="statistics"><short>some info about the database</short></flag>
   </subcategory>
  </category>
 </flags>
 <examples>
  <category>
   <title>Examples of searches</title>
   <subcategory>
    <example><command>mtxrun --script font --list somename (== --pattern=*somename*)</command></example>
   </subcategory>
   <subcategory>
    <example><command>mtxrun --script font --list --name somename</command></example>
    <example><command>mtxrun --script font --list --name --pattern=*somename*</command></example>
   </subcategory>
   <subcategory>
    <example><command>mtxrun --script font --list --spec somename</command></example>
    <example><command>mtxrun --script font --list --spec somename-bold-italic</command></example>
    <example><command>mtxrun --script font --list --spec --pattern=*somename*</command></example>
    <example><command>mtxrun --script font --list --spec --filter="fontname=somename"</command></example>
    <example><command>mtxrun --script font --list --spec --filter="familyname=somename,weight=bold,style=italic,width=condensed"</command></example>
    <example><command>mtxrun --script font --list --spec --filter="familyname=crap*,weight=bold,style=italic"</command></example>
   </subcategory>
   <subcategory>
    <example><command>mtxrun --script font --list --all</command></example>
    <example><command>mtxrun --script font --list --file somename</command></example>
    <example><command>mtxrun --script font --list --file --all somename</command></example>
    <example><command>mtxrun --script font --list --file --pattern=*somename*</command></example>
   </subcategory>
  </category>
 </examples>
</application>
]]

local application = logs.application {
    name     = "mtx-fonts",
    banner   = "ConTeXt Font Database Management 0.21",
    helpinfo = helpinfo,
}

local report = application.report

-- todo: fc-cache -v en check dirs, or better is: fc-cat -v | grep Directory

if not fontloader then fontloader = fontforge end

dofile(resolvers.findfile("font-otp.lua","tex")) -- we need to unpack the font for analysis
dofile(resolvers.findfile("font-syn.lua","tex"))
dofile(resolvers.findfile("font-mis.lua","tex"))

scripts       = scripts       or { }
scripts.fonts = scripts.fonts or { }

function fonts.names.statistics()
    fonts.names.load()

    local data = fonts.names.data
    local statistics = data.statistics

    local function counted(t)
        local n = { }
        for k, v in next, t do
            n[k] = table.count(v)
        end
        return table.sequenced(n)
    end

    report("cache uuid      : %s", data.cache_uuid)
    report("cache version   : %s", data.cache_version)
    report("number of trees : %s", #data.datastate)
    report()
    report("number of fonts : %s", statistics.fonts or 0)
    report("used files      : %s", statistics.readfiles or 0)
    report("skipped files   : %s", statistics.skippedfiles or 0)
    report("duplicate files : %s", statistics.duplicatefiles or 0)
    report("specifications  : %s", #data.specifications)
    report("families        : %s", table.count(data.families))
    report()
    report("mappings        : %s", counted(data.mappings))
    report("fallbacks       : %s", counted(data.fallbacks))
    report()
    report("used styles     : %s", table.sequenced(statistics.used_styles))
    report("used variants   : %s", table.sequenced(statistics.used_variants))
    report("used weights    : %s", table.sequenced(statistics.used_weights))
    report("used widths     : %s", table.sequenced(statistics.used_widths))
    report()
    report("found styles    : %s", table.sequenced(statistics.styles))
    report("found variants  : %s", table.sequenced(statistics.variants))
    report("found weights   : %s", table.sequenced(statistics.weights))
    report("found widths    : %s", table.sequenced(statistics.widths))

end

function fonts.names.simple()
    local simpleversion = 1.001
    local simplelist = { "ttf", "otf", "ttc", "dfont" }
    local name = "luatex-fonts-names.lua"
    fonts.names.filters.list = simplelist
    fonts.names.version = simpleversion -- this number is the same as in font-dum.lua
    report("generating font database for 'luatex-fonts' version %s",fonts.names.version)
    fonts.names.identify(true)
    local data = fonts.names.data
    if data then
        local simplemappings = { }
        local simplified = {
            mappings = simplemappings,
            version = simpleversion,
        }
        local specifications = data.specifications
        for i=1,#simplelist do
            local format = simplelist[i]
            for tag, index in next, data.mappings[format] do
                local s = specifications[index]
                simplemappings[tag] = { s.rawname, s.filename, s.subfont }
            end
        end
        report("saving names in '%s'",name)
        io.savedata(name,table.serialize(simplified,true))
        local data = io.loaddata(resolvers.findfile("luatex-fonts-syn.lua","tex")) or ""
        local dummy = string.match(data,"fonts%.names%.version%s*=%s*([%d%.]+)")
        if tonumber(dummy) ~= simpleversion then
            report("warning: version number %s in 'font-dum' does not match database version number %s",dummy or "?",simpleversion)
        end
    elseif lfs.isfile(name) then
        os.remove(name)
    end
end

function scripts.fonts.reload()
    if getargument("simple") then
        fonts.names.simple()
    else
        fonts.names.load(true,arguments.force)
    end
end

local function subfont(sf)
    if sf then
        return string.format("index: % 2s", sf)
    else
        return ""
    end
end

local function fontweight(fw)
    if fw then
        return string.format("conflict: %s", fw)
    else
        return ""
    end
end

local function showfeatures(tag,specification)
    report()
    report("mapping : %s",tag)
    report("fontname: %s",specification.fontname)
    report("fullname: %s",specification.fullname)
    report("filename: %s",specification.filename)
    report("family  : %s",specification.familyname or "<nofamily>")
    report("weight  : %s",specification.weight or "<noweight>")
    report("style   : %s",specification.style or "<nostyle>")
    report("width   : %s",specification.width or "<nowidth>")
    report("variant : %s",specification.variant or "<novariant>")
    report("subfont : %s",subfont(specification.subfont))
    report("fweight : %s",fontweight(specification.fontweight))
    -- maybe more
    local features = fonts.helpers.getfeatures(specification.filename,specification.format)
    if features then
        for what, v in table.sortedhash(features) do
            local data = features[what]
            if data and next(data) then
                report()
                report("%s features:",what)
                report()
                report("feature  script   languages")
                report()
                for f,ff in table.sortedhash(data) do
                    local done = false
                    for s, ss in table.sortedhash(ff) do
                        if s == "*"  then s       = "all" end
                        if ss  ["*"] then ss["*"] = nil ss.all = true end
                        if done then
                            f = ""
                        else
                            done = true
                        end
                        report("% -8s % -8s % -8s",f,s,table.concat(table.sortedkeys(ss), " ")) -- todo: padd 4
                    end
                end
            end
        end
    else
        report("no features")
    end
    report()
end

local function reloadbase(reload)
    if reload then
        report("fontnames, reloading font database")
        names.load(true,arguments.force)
        report("fontnames, done\n\n")
    end
end

local function list_specifications(t,info)
    if t then
        local s = table.sortedkeys(t)
        if info then
            for k=1,#s do
                local v = s[k]
                showfeatures(v,t[v])
            end
        else
            for k=1,#s do
                local v = s[k]
                local entry = t[v]
                s[k] = {
                    entry.familyname  or "<nofamily>",
                    entry.weight      or "<noweight>",
                    entry.style       or "<nostyle>",
                    entry.width       or "<nowidth>",
                    entry.variant     or "<novariant>",
                    entry.fontname,
                    entry.filename,
                    subfont(entry.subfont),
                    fontweight(entry.fontweight),
                }
            end
            utilities.formatters.formatcolumns(s)
            for k=1,#s do
                texio.write_nl(s[k])
            end
        end
    end
end

local function list_matches(t,info)
    if t then
        local s, w = table.sortedkeys(t), { 0, 0, 0 }
        if info then
            for k=1,#s do
                local v = s[k]
                showfeatures(v,t[v])
            end
        else
            for k=1,#s do
                local v = s[k]
                local entry = t[v]
                s[k] = {
                    v,
                    entry.fontname,
                    entry.filename,
                    subfont(entry.subfont)
                }
            end
            utilities.formatters.formatcolumns(s)
            for k=1,#s do
                texio.write_nl(s[k])
            end
        end
    end
end

function scripts.fonts.list()

    local all     = getargument("all")
    local info    = getargument("info")
    local reload  = getargument("reload")
    local pattern = getargument("pattern")
    local filter  = getargument("filter")
    local given   = givenfiles[1]

    reloadbase(reload)

    if getargument("name") then
        if pattern then
            --~ mtxrun --script font --list --name --pattern=*somename*
            list_matches(fonts.names.list(string.topattern(pattern,true),reload,all),info)
        elseif filter then
            report("not supported: --list --name --filter",name)
        elseif given then
            --~ mtxrun --script font --list --name somename
            list_matches(fonts.names.list(given,reload,all),info)
        else
            report("not supported: --list --name <no specification>",name)
        end
    elseif getargument("spec") then
        if pattern then
            --~ mtxrun --script font --list --spec --pattern=*somename*
            report("not supported: --list --spec --pattern",name)
        elseif filter then
            --~ mtxrun --script font --list --spec --filter="fontname=somename"
            list_specifications(fonts.names.getlookups(filter),info)
        elseif given then
            --~ mtxrun --script font --list --spec somename
            list_specifications(fonts.names.collectspec(given,reload,all),info)
        else
            report("not supported: --list --spec <no specification>",name)
        end
    elseif getargument("file") then
        if pattern then
            --~ mtxrun --script font --list --file --pattern=*somename*
            list_specifications(fonts.names.collectfiles(string.topattern(pattern,true),reload,all),info)
        elseif filter then
            report("not supported: --list --spec",name)
        elseif given then
            --~ mtxrun --script font --list --file somename
            list_specifications(fonts.names.collectfiles(given,reload,all),info)
        else
            report("not supported: --list --file <no specification>",name)
        end
    elseif pattern then
        --~ mtxrun --script font --list --pattern=*somename*
       list_matches(fonts.names.list(string.topattern(pattern,true),reload,all),info)
    elseif given then
        --~ mtxrun --script font --list somename
        list_matches(fonts.names.list(given,reload,all),info)
    elseif all then
        pattern = "*"
        list_matches(fonts.names.list(string.topattern(pattern,true),reload,all),info)
    else
        report("not supported: --list <no specification>",name)
    end

end

function scripts.fonts.unpack()
    local name = file.removesuffix(file.basename(givenfiles[1] or ""))
    if name and name ~= "" then
        local cache = containers.define("fonts", "otf", 2.730, true)
        local cleanname = containers.cleanname(name)
        local data = containers.read(cache,cleanname)
        if data then
            local savename = file.addsuffix(cleanname .. "-unpacked","tma")
            report("fontsave, saving data in %s",savename)
            fonts.handlers.otf.enhancers.unpack(data)
            io.savedata(savename,table.serialize(data,true))
        else
            report("unknown file '%s'",name)
        end
    end
end

function scripts.fonts.save()
    local name = givenfiles[1] or ""
    local sub  = givenfiles[2] or ""
    local function save(savename,fontblob)
        if fontblob then
            savename = savename:lower() .. ".lua"
            report("fontsave, saving data in %s",savename)
-- fontloader.apply_featurefile(fontblob, "./ts/test.fea")
            table.tofile(savename,fontloader.to_table(fontblob),"return")
            fontloader.close(fontblob)
        end
    end
    if name and name ~= "" then
        local filename = resolvers.findfile(name) -- maybe also search for opentype
        if filename and filename ~= "" then
            local suffix = string.lower(file.suffix(filename))
            if suffix == 'ttf' or suffix == 'otf' or suffix == 'ttc' or suffix == "dfont" then
                local fontinfo = fontloader.info(filename)
                if fontinfo then
                    report("font: %s located as %s",name,filename)
                    if fontinfo[1] then
                        for k=1,#fontinfo do
                            local v = fontinfo[k]
                            save(v.fontname,fontloader.open(filename,v.fullname))
                        end
                    else
                        save(fontinfo.fullname,fontloader.open(filename))
                    end
                else
                    report("font: %s cannot be read",filename)
                end
            else
                report("font: %s not saved",filename)
            end
        else
            report("font: %s not found",name)
        end
    else
        report("font: no name given")
    end
end

if getargument("names") then
    setargument("reload",true)
    setargument("simple",true)
end

if getargument("list") then
    scripts.fonts.list()
elseif getargument("reload") then
    scripts.fonts.reload()
elseif getargument("save") then
    scripts.fonts.save()
elseif getargument("unpack") then
    scripts.fonts.unpack()
elseif getargument("statistics") then
    fonts.names.statistics()
elseif getargument("exporthelp") then
    application.export(getargument("exporthelp"),givenfiles[1])
else
    application.help()
end
