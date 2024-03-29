if not modules then modules = { } end modules ['trac-log'] = {
    version   = 1.001,
    comment   = "companion to trac-log.mkiv",
    author    = "Hans Hagen, PRAGMA-ADE, Hasselt NL",
    copyright = "PRAGMA ADE / ConTeXt Development Team",
    license   = "see context related readme files"
}

if tex and (tex.jobname or tex.formatname) then

    -- quick hack, awaiting speedup in engine (8 -> 6.4 sec for --make with console2)

    local texio_write_nl = texio.write_nl
    local texio_write    = texio.write
    local io_write       = io.write

    local write_nl = function(target,...)
        if not io_write then
            io_write = io.write
        end
        if target == "term and log" then
            texio_write_nl("log",...)
            texio_write_nl("term","")
            io_write(...)
        elseif target == "log" then
            texio_write_nl("log",...)
        elseif target == "term" then
            texio_write_nl("term","")
            io_write(...)
        else
            texio_write_nl("log",...)
            texio_write_nl("term","")
            io_write(...)
        end
    end

    local write = function(target,...)
        if not io_write then
            io_write = io.write
        end
        if target == "term and log" then
            texio_write("log",...)
            io_write(...)
        elseif target == "log" then
            texio_write("log",...)
        elseif target == "term" then
            io_write(...)
        else
            texio_write("log",...)
            io_write(...)
        end
    end

    texio.write    = write
    texio.write_nl = write_nl

else

    -- texlua or just lua

end

-- todo: less categories, more subcategories (e.g. nodes)
-- todo: split into basics and ctx specific

local write_nl, write = texio and texio.write_nl or print, texio and texio.write or io.write
local format, gmatch, find = string.format, string.gmatch, string.find
local concat, insert, remove = table.concat, table.insert, table.remove
local topattern = string.topattern
local texcount = tex and tex.count
local next, type, select = next, type, select
local utfchar = utf.char

local setmetatableindex = table.setmetatableindex
local formatters        = string.formatters

--[[ldx--
<p>This is a prelude to a more extensive logging module. We no longer
provide <l n='xml'/> based logging as parsing is relatively easy anyway.</p>
--ldx]]--

logs       = logs or { }
local logs = logs

local moreinfo = [[
More information about ConTeXt and the tools that come with it can be found at:
]] .. "\n" .. [[
maillist : ntg-context@ntg.nl / http://www.ntg.nl/mailman/listinfo/ntg-context
webpage  : http://www.pragma-ade.nl / http://tex.aanhet.net
wiki     : http://contextgarden.net
]]

-- -- we extend the formatters:
--
-- function utilities.strings.unichr(s) return "U+" .. format("%05X",s) .. " (" .. utfchar(s) .. ")" end
-- function utilities.strings.chruni(s) return utfchar(s) .. " (U+" .. format("%05X",s) .. ")" end
--
-- utilities.strings.formatters.add (
--     string.formatters, "uni",
--     [[unichr(%s)]],
--     [[local unichr = utilities.strings.unichr]]
-- )
--
-- utilities.strings.formatters.add (
--     string.formatters, "chr",
--     [[chruni(%s)]],
--     [[local chruni = utilities.strings.chruni]]
-- )

utilities.strings.formatters.add (
    formatters, "unichr",
    [["U+" .. format("%%05X",%s) .. " (" .. utfchar(%s) .. ")"]]
)

utilities.strings.formatters.add (
    formatters, "chruni",
    [[utfchar(%s) .. " (U+" .. format("%%05X",%s) .. ")"]]
)

-- print(formatters["Missing character %!chruni! in font."](234))
-- print(formatters["Missing character %!unichr! in font."](234))

-- basic loggers

local function ignore() end

setmetatableindex(logs, function(t,k) t[k] = ignore ; return ignore end)

local report, subreport, status, settarget, setformats, settranslations

local direct, subdirect, writer, pushtarget, poptarget

if tex and (tex.jobname or tex.formatname) then

 -- local format = string.formatter

    local valueiskey   = { __index = function(t,k) t[k] = k return k end } -- will be helper

    local target       = "term and log"

    logs.flush         = io.flush

    local formats      = { } setmetatable(formats,     valueiskey)
    local translations = { } setmetatable(translations,valueiskey)

    writer = function(...)
        write_nl(target,...)
    end

    newline = function()
        write_nl(target,"\n")
    end

    local f_one = formatters["%-15s > %s\n"]
    local f_two = formatters["%-15s >\n"]

    -- we can use formatters but best check for % then because for simple messages
    -- we con't want this overhead for single messages (not that there are that
    -- many; we could have a special weak table)

    report = function(a,b,c,...)
        if c then
            write_nl(target,f_one(translations[a],formatters[formats[b]](c,...)))
        elseif b then
            write_nl(target,f_one(translations[a],formats[b]))
        elseif a then
            write_nl(target,f_two(translations[a]))
        else
            write_nl(target,"\n")
        end
    end

    local f_one = formatters["%-15s > %s"]
    local f_two = formatters["%-15s >"]

    direct = function(a,b,c,...)
        if c then
            return f_one(translations[a],formatters[formats[b]](c,...))
        elseif b then
            return f_one(translations[a],formats[b])
        elseif a then
            return f_two(translations[a])
        else
            return ""
        end
    end

    local f_one = formatters["%-15s > %s > %s\n"]
    local f_two = formatters["%-15s > %s >\n"]

    subreport = function(a,s,b,c,...)
        if c then
            write_nl(target,f_one(translations[a],translations[s],formatters[formats[b]](c,...)))
        elseif b then
            write_nl(target,f_one(translations[a],translations[s],formats[b]))
        elseif a then
            write_nl(target,f_two(translations[a],translations[s]))
        else
            write_nl(target,"\n")
        end
    end

    local f_one = formatters["%-15s > %s > %s"]
    local f_two = formatters["%-15s > %s >"]

    subdirect = function(a,s,b,c,...)
        if c then
            return f_one(translations[a],translations[s],formatters[formats[b]](c,...))
        elseif b then
            return f_one(translations[a],translations[s],formats[b])
        elseif a then
            return f_two(translations[a],translations[s])
        else
            return ""
        end
    end

    local f_one = formatters["%-15s : %s\n"]
    local f_two = formatters["%-15s :\n"]

    status = function(a,b,c,...)
        if c then
            write_nl(target,f_one(translations[a],formatters[formats[b]](c,...)))
        elseif b then
            write_nl(target,f_one(translations[a],formats[b]))
        elseif a then
            write_nl(target,f_two(translations[a]))
        else
            write_nl(target,"\n")
        end
    end

    local targets = {
        logfile  = "log",
        log      = "log",
        file     = "log",
        console  = "term",
        terminal = "term",
        both     = "term and log",
    }

    settarget = function(whereto)
        target = targets[whereto or "both"] or targets.both
        if target == "term" or target == "term and log" then
            logs.flush = io.flush
        else
            logs.flush = ignore
        end
    end

    local stack = { }

    pushtarget = function(newtarget)
        insert(stack,target)
        settarget(newtarget)
    end

    poptarget = function()
        if #stack > 0 then
            settarget(remove(stack))
        end
    end

    setformats = function(f)
        formats = f
    end

    settranslations = function(t)
        translations = t
    end

else

    logs.flush = ignore

    writer = write_nl

    newline = function()
        write_nl("\n")
    end

    local f_one = formatters["%-15s | %s"]
    local f_two = formatters["%-15s |"]

    report = function(a,b,c,...)
        if c then
            write_nl(f_one(a,formatters[b](c,...)))
        elseif b then
            write_nl(f_one(a,b))
        elseif a then
            write_nl(f_two(a))
        else
            write_nl("")
        end
    end

    local f_one = formatters["%-15s | %s | %s"]
    local f_two = formatters["%-15s | %s |"]

    subreport = function(a,sub,b,c,...)
        if c then
            write_nl(f_one(a,sub,formatters[b](c,...)))
        elseif b then
            write_nl(f_one(a,sub,b))
        elseif a then
            write_nl(f_two(a,sub))
        else
            write_nl("")
        end
    end

    local f_one = formatters["%-15s : %s\n"]
    local f_two = formatters["%-15s :\n"]

    status = function(a,b,c,...) -- not to be used in lua anyway
        if c then
            write_nl(f_one(a,formatters[b](c,...)))
        elseif b then
            write_nl(f_one(a,b)) -- b can have %'s
        elseif a then
            write_nl(f_two(a))
        else
            write_nl("\n")
        end
    end

    direct          = ignore
    subdirect       = ignore

    settarget       = ignore
    pushtarget      = ignore
    poptarget       = ignore
    setformats      = ignore
    settranslations = ignore

end

logs.report          = report
logs.subreport       = subreport
logs.status          = status
logs.settarget       = settarget
logs.pushtarget      = pushtarget
logs.poptarget       = poptarget
logs.setformats      = setformats
logs.settranslations = settranslations

logs.direct          = direct
logs.subdirect       = subdirect
logs.writer          = writer
logs.newline         = newline

-- installer

-- todo: renew (un) locks when a new one is added and wildcard

local data, states = { }, nil

function logs.reporter(category,subcategory)
    local logger = data[category]
    if not logger then
        local state = false
        if states == true then
            state = true
        elseif type(states) == "table" then
            for c, _ in next, states do
                if find(category,c) then
                    state = true
                    break
                end
            end
        end
        logger = {
            reporters = { },
            state = state,
        }
        data[category] = logger
    end
    local reporter = logger.reporters[subcategory or "default"]
    if not reporter then
        if subcategory then
            reporter = function(...)
                if not logger.state then
                    subreport(category,subcategory,...)
                end
            end
            logger.reporters[subcategory] = reporter
        else
            local tag = category
            reporter = function(...)
                if not logger.state then
                    report(category,...)
                end
            end
            logger.reporters.default = reporter
        end
    end
    return reporter
end

logs.new = logs.reporter -- for old times sake

-- context specicific: this ends up in the macro stream

local ctxreport = logs.writer

function logs.setmessenger(m)
    ctxreport = m
end

function logs.messenger(category,subcategory)
    -- we need to avoid catcode mess (todo: fast context)
    if subcategory then
        return function(...)
            ctxreport(subdirect(category,subcategory,...))
        end
    else
        return function(...)
            ctxreport(direct(category,...))
        end
    end
end

-- so far

local function setblocked(category,value)
    if category == true then
        -- lock all
        category, value = "*", true
    elseif category == false then
        -- unlock all
        category, value = "*", false
    elseif value == nil then
        -- lock selective
        value = true
    end
    if category == "*" then
        states = value
        for k, v in next, data do
            v.state = value
        end
    else
        states = utilities.parsers.settings_to_hash(category)
        for c, _ in next, states do
            if data[c] then
                v.state = value
            else
                c = topattern(c,true,true)
                for k, v in next, data do
                    if find(k,c) then
                        v.state = value
                    end
                end
            end
        end
    end
end

function logs.disable(category,value)
    setblocked(category,value == nil and true or value)
end

function logs.enable(category)
    setblocked(category,false)
end

function logs.categories()
    return table.sortedkeys(data)
end

function logs.show()
    local n, c, s, max = 0, 0, 0, 0
    for category, v in table.sortedpairs(data) do
        n = n + 1
        local state = v.state
        local reporters = v.reporters
        local nc = #category
        if nc > c then
            c = nc
        end
        for subcategory, _ in next, reporters do
            local ns = #subcategory
            if ns > c then
                s = ns
            end
            local m = nc + ns
            if m > max then
                max = m
            end
        end
        local subcategories = concat(table.sortedkeys(reporters),", ")
        if state == true then
            state = "disabled"
        elseif state == false then
            state = "enabled"
        else
            state = "unknown"
        end
        -- no new here
        report("logging","category %a, subcategories %a, state %a",category,subcategories,state)
    end
    report("logging","categories: %s, max category: %s, max subcategory: %s, max combined: %s",n,c,s,max)
end

local delayed_reporters = { } setmetatableindex(delayed_reporters,function(t,k)
    local v = logs.reporter(k)
    t[k] = v
    return v
end)

function utilities.setters.report(setter,...)
    delayed_reporters[setter](...)
end

directives.register("logs.blocked", function(v)
    setblocked(v,true)
end)

directives.register("logs.target", function(v)
    settarget(v)
end)

-- tex specific loggers (might move elsewhere)

local report_pages = logs.reporter("pages") -- not needed but saves checking when we grep for it

local real, user, sub

function logs.start_page_number()
    real, user, sub = texcount.realpageno, texcount.userpageno, texcount.subpageno
--     real, user, sub = 0, 0, 0
end

local timing    = false
local starttime = nil
local lasttime  = nil

trackers.register("pages.timing", function(v) -- only for myself (diagnostics)
    starttime = os.clock()
    timing    = true
end)

function logs.stop_page_number() -- the first page can includes the initialization so we omit this in average
    if timing then
        local elapsed, average
        local stoptime = os.clock()
        if not lasttime or real < 2 then
            elapsed   = stoptime
            average   = stoptime
            starttime = stoptime
        else
            elapsed  = stoptime - lasttime
            average  = (stoptime - starttime) / (real - 1)
        end
        lasttime = stoptime
        if real <= 0 then
            report_pages("flushing page, time %0.04f / %0.04f",elapsed,average)
        elseif user <= 0 then
            report_pages("flushing realpage %s, time %0.04f / %0.04f",real,elapsed,average)
        elseif sub <= 0 then
            report_pages("flushing realpage %s, userpage %s, time %0.04f / %0.04f",real,user,elapsed,average)
        else
            report_pages("flushing realpage %s, userpage %s, subpage %s, time %0.04f / %0.04f",real,user,sub,elapsed,average)
        end
    else
        if real <= 0 then
            report_pages("flushing page")
        elseif user <= 0 then
            report_pages("flushing realpage %s",real)
        elseif sub <= 0 then
            report_pages("flushing realpage %s, userpage %s",real,user)
        else
            report_pages("flushing realpage %s, userpage %s, subpage %s",real,user,sub)
        end
    end
    logs.flush()
end

-- we don't have show_open and show_close callbacks yet

local report_files = logs.reporter("files")
local nesting      = 0
local verbose      = false
local hasscheme    = url.hasscheme

function logs.show_open(name)
 -- if hasscheme(name) ~= "virtual" then
 --     if verbose then
 --         nesting = nesting + 1
 --         report_files("level %s, opening %s",nesting,name)
 --     else
 --         write(formatters["(%s"](name)) -- tex adds a space
 --     end
 -- end
end

function logs.show_close(name)
 -- if hasscheme(name) ~= "virtual" then
 --     if verbose then
 --         report_files("level %s, closing %s",nesting,name)
 --         nesting = nesting - 1
 --     else
 --         write(")") -- tex adds a space
 --     end
 -- end
end

function logs.show_load(name)
 -- if hasscheme(name) ~= "virtual" then
 --     if verbose then
 --         report_files("level %s, loading %s",nesting+1,name)
 --     else
 --         write(formatters["(%s)"](name))
 --     end
 -- end
end

-- there may be scripts out there using this:

local simple = logs.reporter("comment")

logs.simple     = simple
logs.simpleline = simple

-- obsolete

function logs.setprogram  () end -- obsolete
function logs.extendbanner() end -- obsolete
function logs.reportlines () end -- obsolete
function logs.reportbanner() end -- obsolete
function logs.reportline  () end -- obsolete
function logs.simplelines () end -- obsolete
function logs.help        () end -- obsolete

-- applications

-- local function reportlines(t,str)
--     if str then
--         for line in gmatch(str,"([^\n\r]*)[\n\r]") do
--             t.report(line)
--         end
--     end
-- end

local Carg, C, lpegmatch = lpeg.Carg, lpeg.C, lpeg.match
local p_newline = lpeg.patterns.newline

local linewise = (
    Carg(1) * C((1-p_newline)^1) / function(t,s) t.report(s) end
  + Carg(1) * p_newline^2        / function(t)   t.report()  end
  + p_newline
)^1

local function reportlines(t,str)
    if str then
        lpegmatch(linewise,str,1,t)
    end
end

local function reportbanner(t)
    local banner = t.banner
    if banner then
        t.report(banner)
        t.report()
    end
end

local function reportversion(t)
    local banner = t.banner
    if banner then
        t.report(banner)
    end
end

local function reporthelp(t,...)
    local helpinfo = t.helpinfo
    if type(helpinfo) == "string" then
        reportlines(t,helpinfo)
    elseif type(helpinfo) == "table" then
        for i=1,select("#",...) do
            reportlines(t,t.helpinfo[select(i,...)])
            if i < n then
                t.report()
            end
        end
    end
end

local function reportinfo(t)
    t.report()
    reportlines(t,t.moreinfo)
end

local function reportexport(t,method)
    report(t.helpinfo)
end

local reporters = {
    lines    = reportlines, -- not to be overloaded
    banner   = reportbanner,
    version  = reportversion,
    help     = reporthelp,
    info     = reportinfo,
    export   = reportexport,
}

logs.reporters = reporters

function logs.application(t)
    t.name     = t.name   or "unknown"
    t.banner   = t.banner
    t.moreinfo = moreinfo
    t.report   = logs.reporter(t.name)
    t.help     = function(...)
        reporters.banner(t)
        reporters.help(t,...)
        reporters.info(t)
    end
    t.export   = function(...)
        reporters.export(t,...)
    end
    t.identify = function()
        reporters.banner(t)
    end
    t.version  = function()
        reporters.version(t)
    end
    return t
end

-- somewhat special .. will be redone (already a better solution in place in lmx)

-- logging to a file

-- local syslogname = "oeps.xxx"
--
-- for i=1,10 do
--     logs.system(syslogname,"context","test","fonts","font %s recached due to newer version (%s)","blabla","123")
-- end

function logs.system(whereto,process,jobname,category,...)
    local message = formatters["%s %s => %s => %s => %s\r"](os.date("%d/%m/%y %H:%m:%S"),process,jobname,category,format(...))
    for i=1,10 do
        local f = io.open(whereto,"a") -- we can consider keeping the file open
        if f then
            f:write(message)
            f:close()
            break
        else
            sleep(0.1)
        end
    end
end

local report_system = logs.reporter("system","logs")

function logs.obsolete(old,new)
    local o = loadstring("return " .. new)()
    if type(o) == "function" then
        return function(...)
            report_system("function %a is obsolete, use %a",old,new)
            loadstring(old .. "=" .. new  .. " return ".. old)()(...)
        end
    elseif type(o) == "table" then
        local t, m = { }, { }
        m.__index = function(t,k)
            report_system("table %a is obsolete, use %a",old,new)
            m.__index, m.__newindex = o, o
            return o[k]
        end
        m.__newindex = function(t,k,v)
            report_system("table %a is obsolete, use %a",old,new)
            m.__index, m.__newindex = o, o
            o[k] = v
        end
        if libraries then
            libraries.obsolete[old] = t -- true
        end
        setmetatable(t,m)
        return t
    end
end

if utilities then
    utilities.report = report_system
end

if tex and tex.error then
    function logs.texerrormessage(...) -- for the moment we put this function here
        tex.error(format(...), { })
    end
else
    function logs.texerrormessage(...)
        print(format(...))
    end
end

-- this is somewhat slower but prevents out-of-order messages when print is mixed
-- with texio.write

io.stdout:setvbuf('no')
io.stderr:setvbuf('no')

-- windows: > nul  2>&1
-- unix   : > null 2>&1
