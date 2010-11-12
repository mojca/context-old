if not modules then modules = { } end modules ['supp-fil'] = {
    version   = 1.001,
    comment   = "companion to supp-fil.mkiv",
    author    = "Hans Hagen, PRAGMA-ADE, Hasselt NL",
    copyright = "PRAGMA ADE / ConTeXt Development Team",
    license   = "see context related readme files"
}

-- This module will be redone !

-- context is not defined yet! todo! (we need to load tupp-fil after cld)

--[[ldx--
<p>It's more convenient to manipulate filenames (paths) in
<l n='lua'/> than in <l n='tex'/>. These methods have counterparts
at the <l n='tex'/> side.</p>
--ldx]]--

local find, gsub, match, format, concat = string.find, string.gsub, string.match, string.format, table.concat
local texcount = tex.count

local trace_modules = false  trackers.register("modules.loading", function(v) trace_modules = v end)

local report_modules = logs.new("modules")

commands          = commands or { }
local commands    = commands
environment       = environment or { }
local environment = environment

function commands.checkfilename(str) -- "/whatever..." "c:..." "http://..."
    texcount.kindoffile = (find(str,"^/") or find(str,"[%a]:") and 1) or 0
end

function commands.thesanitizedfilename(str)
    context((gsub(str,"\\","/")))
end

local testcase = commands.testcase

function commands.splitfilename(fullname)
    local path, name, base, suffix, kind = '', fullname, fullname, '', 0
    local p, n = match(fullname,"^(.+)/(.-)$")
    if p and n then
        path, name, base = p, n, n
    end
    local b, s = match(base,"^(.+)%.(.-)$")
    if b and s then
        name, suffix = b, s
    end
    texcount.splitoffkind = (path == "" and 0) or (path == '.' and 1) or 2
    local setvalue = context.setvalue
    setvalue("splitofffull", fullname)
    setvalue("splitoffpath", path)
    setvalue("splitoffbase", base)
    setvalue("splitoffname", name)
    setvalue("splitofftype", suffix)
end

function commands.splitfiletype(fullname)
    local name, suffix = fullname, ''
    local n, s = match(fullname,"^(.+)%.(.-)$")
    if n and s then
        name, suffix = n, s
    end
    local setvalue = context.setvalue
    setvalue("splitofffull", fullname)
    setvalue("splitoffpath", "")
    setvalue("splitoffname", name)
    setvalue("splitofftype", suffix)
end

function commands.doifparentfileelse(n)
    testcase(n == environment.jobname or n == environment.jobname .. '.tex' or n == environment.outputfilename)
end

-- saves some .15 sec on 12 sec format generation

local lastexistingfile = ""

function commands.doiffileexistelse(name)
    if not name or name == "" then
        lastexistingfile = ""
    else
        lastexistingfile = resolvers.findtexfile(name) or ""
    end
    return testcase(lastexistingfile ~= "")
end

function commands.lastexistingfile()
    context(lastexistingfile)
end

-- more, we can cache matches

local finders, loaders, openers = resolvers.finders, resolvers.loaders, resolvers.openers

local found = { } -- can best be done in the resolver itself

-- todo: tracing

local function readfilename(specification,backtrack,treetoo)
    local fnd = found[specification]
    if not fnd then
        local splitspec = resolvers.splitmethod(specification)
        local filename = splitspec.path or ""
        if lfs.isfile(filename) then
            fnd = filename
        end
        if not fnd and backtrack then
            local fname = filename
            for i=1,backtrack,1 do
                fname = "../" .. fname
                if lfs.isfile(fname) then
                    fnd = fname
                    break
                end
            end
        end
        if not fnd and treetoo then
--~             fnd = resolvers.findfile(filename)
            fnd = resolvers.findtexfile(filename)
        end
        found[specification] = fnd
    end
    return fnd or ""
end

commands.readfilename = readfilename

function finders.job(filename) return readfilename(filename,nil,false) end -- current path, no backtracking
function finders.loc(filename) return readfilename(filename,2,  false) end -- current path, backtracking
function finders.sys(filename) return readfilename(filename,nil,true ) end -- current path, obeys tex search
function finders.fix(filename) return readfilename(filename,2,  false) end -- specified path, backtracking
function finders.set(filename) return readfilename(filename,nil,false) end -- specified path, no backtracking
function finders.any(filename) return readfilename(filename,2,  true ) end -- loc job sys

openers.job = openers.generic loaders.job = loaders.generic
openers.loc = openers.generic loaders.loc = loaders.generic
openers.sys = openers.generic loaders.sys = loaders.generic
openers.fix = openers.generic loaders.fix = loaders.generic
openers.set = openers.generic loaders.set = loaders.generic
openers.any = openers.generic loaders.any = loaders.generic

function commands.doreadfile(protocol,path,name) -- better do a split and then pass table
    local specification
    if url.hasscheme(name) then
        specification = name
    else
        specification = ((path == "") and format("%s:///%s",protocol,name)) or format("%s:///%s/%s",protocol,path,name)
    end
    context(resolvers.findtexfile(specification))
end

-- modules can only have a tex or mkiv suffix or can have a specified one

local prefixes  = { "m", "p", "s", "x", "t" }
local suffixes  = { "mkiv", "tex" } -- what about cld
local modstatus = { }

local function usemodule(name,hasscheme)
    local foundname
    if hasscheme then
        -- no auto suffix as http will return a home page or error page
        -- so we only add one if missing
        local fullname = file.addsuffix(name,"tex")
        if trace_modules then
            report_modules("checking scheme driven file '%s'",fullname)
        end
        foundname = resolvers.findtexfile(fullname) or ""
    elseif file.extname(name) ~= "" then
        if trace_modules then
            report_modules("checking suffix driven file '%s'",name)
        end
        foundname = commands.readfilename(name,false,true) or ""
    elseif true then
        for i=1,#suffixes do
            local fullname = file.addsuffix(name,suffixes[i])
            if trace_modules then
                report_modules("checking suffix driven file '%s'",fullname)
            end
            foundname = commands.readfilename(fullname,false,true) or ""
            if foundname ~= "" then
                break
            end
        end
    else
     -- -- we don't want a tex file for each mkiv file so we do some checking
     -- local foundtexname  = commands.readfilename(file.addsuffix(name,"tex"), false,true) or ""
     -- local foundmkivname = commands.readfilename(file.addsuffix(name,"mkiv"),false,true) or ""
     -- if foundtexfile ~= "" and foundmkivfile ~= "" then
     --     if file.dirname(foundtexname) == file.dirname(foundmkivname) then
     --         foundname = foundtexname -- we assume that this (shared) file loads the mkiv file
     --         if trace_modules then
     --             report_modules("using tex file for module '%s' (mkiv file on same dir)",name)
     --         end
     --     else
     --         foundname = foundmkivname -- we assume that the tex file is an old one someplace else
     --         if trace_modules then
     --             report_modules("using mkiv file for module '%s' (tex file on other dir)",name)
     --         end
     --     end
     -- elseif foundtexfile ~= "" then
     --     foundname = foundtexname
     --     if trace_modules then
     --         report_modules("using tex file for module '%s'",name)
     --     end
     -- elseif foundmkivfile ~= "" then
     --     foundname = foundmkivname
     --     if trace_modules then
     --         report_modules("using mkiv file for module '%s'",name)
     --     end
     -- else
     --     -- nothing
     -- end
    end
    if foundname ~= "" then
        if trace_modules then
            report_modules("loading '%s'",foundname)
        end
        context.startreadingfile()
        context.input(foundname)
        context.stopreadingfile()
        return true
    else
        return false
    end
end

function commands.usemodules(prefix,askedname,truename)
    local hasprefix = prefix and prefix ~= ""
    local hashname = ((hasprefix and prefix) or "*") .. "-" .. truename
    local status = modstatus[hashname]
    if status == 0 then
        -- not found
    elseif status == 1 then
        status = status + 1
    else
        if trace_modules then
            report_modules("locating '%s'",truename)
        end
        local hasscheme = url.hasscheme(truename)
        if hasscheme then
            -- no prefix and suffix done
            if usemodule(truename,true) then
                status = 1
            else
                status = 0
            end
        elseif hasprefix then
            if usemodule(prefix .. "-" .. truename) then
                status = 1
            else
                status = 0
            end
        else
            for i=1,#prefixes do
                -- todo: reconstruct name i.e. basename
                local thename = prefixes[i] .. "-" .. truename
                if usemodule(thename) then
                    status = 1
                    break
                end
            end
            if status then
                -- ok, don't change
            elseif usemodule(truename) then
                status = 1
            else
                status = 0
            end
        end
    end
    if status == 0 then
        if trace_modules then
            report_modules("skipping '%s' (not found)",truename)
        else
            interfaces.showmessage("systems",6,askedname)
        end
    elseif status == 1 then
        if not trace_modules then
            interfaces.showmessage("systems",5,askedname)
        end
    else
        if trace_modules then
            report_modules("skipping '%s' (already loaded)",truename)
        else
            interfaces.showmessage("systems",7,askedname)
        end
    end
    modstatus[hashname] = status
end

statistics.register("loaded tex modules", function()
    if next(modstatus) then
        local t, f, nt, nf = { }, { }, 0, 0
        for k, v in table.sortedhash(modstatus) do
            k = file.basename(k)
            if v == 0 then
                nf = nf + 1
                f[nf] = k
            else
                nt = nt + 1
                t[nt] = k
            end
        end
        local ts = (nt>0 and format(" (%s)",concat(t," "))) or ""
        local fs = (nf>0 and format(" (%s)",concat(f," "))) or ""
        return format("%s requested, %s found%s, %s missing%s",nt+nf,nt,ts,nf,fs)
    else
        return nil
    end
end)
