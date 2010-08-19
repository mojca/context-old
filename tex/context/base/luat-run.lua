if not modules then modules = { } end modules ['luat-run'] = {
    version   = 1.001,
    comment   = "companion to luat-lib.mkiv",
    author    = "Hans Hagen, PRAGMA-ADE, Hasselt NL",
    copyright = "PRAGMA ADE / ConTeXt Development Team",
    license   = "see context related readme files"
}

local format, rpadd = string.format, string.rpadd
local insert = table.insert

local trace_lua_dump = false  trackers  .register("system.dump", function(v) trace_lua_dump = v end)

local report_lua_dump = logs.new("lua dump actions")

luatex       = luatex or { }
local luatex = luatex

local startactions = { }
local stopactions  = { }

function luatex.registerstartactions(...) insert(startactions, ...) end
function luatex.registerstopactions (...) insert(stopactions,  ...) end

luatex.showtexstat = luatex.showtexstat or function() end
luatex.showjobstat = luatex.showjobstat or statistics.showjobstat

local function start_run()
    if logs.start_run then
        logs.start_run()
    end
    for i=1,#startactions do
        startactions[i]()
    end
end

local function stop_run()
    for i=1,#stopactions do
        stopactions[i]()
    end
    if luatex.showjobstat then
        statistics.show(logs.report_job_stat)
    end
    if luatex.showtexstat then
        for k,v in next, status.list() do
            logs.report_tex_stat(k,v)
        end
    end
    if logs.stop_run then
        logs.stop_run()
    end
end

local function start_shipout_page()
    logs.start_page_number()
end

local function stop_shipout_page()
    logs.stop_page_number()
end

local function report_output_pages()
end

local function report_output_log()
end

local function pre_dump_actions()
    lua.finalize(trace_lua_dump and report_lua_dump or nil)
    statistics.reportstorage("log")
 -- statistics.savefmtstatus("\jobname","\contextversion","context.tex")
end

-- this can be done later

callbacks.register('start_run',             start_run,           "actions performed at the beginning of a run")
callbacks.register('stop_run',              stop_run,            "actions performed at the end of a run")

callbacks.register('report_output_pages',   report_output_pages, "actions performed when reporting pages")
callbacks.register('report_output_log',     report_output_log,   "actions performed when reporting log file")

callbacks.register('start_page_number',     start_shipout_page,  "actions performed at the beginning of a shipout")
callbacks.register('stop_page_number',      stop_shipout_page,   "actions performed at the end of a shipout")

callbacks.register('process_input_buffer',  false,               "actions performed when reading data")
callbacks.register('process_output_buffer', false,               "actions performed when writing data")

callbacks.register("pre_dump",              pre_dump_actions,    "lua related finalizers called before we dump the format") -- comes after \everydump
