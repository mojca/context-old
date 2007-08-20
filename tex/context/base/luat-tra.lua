-- filename : luat-tra.lua
-- comment  : companion to luat-lib.tex
-- author   : Hans Hagen, PRAGMA-ADE, Hasselt NL
-- copyright: PRAGMA ADE / ConTeXt Development Team
-- license  : see context related readme files

if not versions then versions = { } end versions['luat-tra'] = 1.001

debugger = { }

do

    local counters = { }
    local names    = { }
    local getinfo  = debug.getinfo

    local function hook()
        local f = getinfo(2,"f").func
        if f then
            if counters[f] == nil then
                counters[f] = 1
--~                 names[f] = debug.getinfo(2,"Sn")
--~                 names[f] = debug.getinfo(2,"n")
                names[f] = debug.getinfo(f)
            else
                counters[f] = counters[f] + 1
            end
        end
    end

    local function getname(func)
        local n = names[func]
        if n then
            if n.what == "C" then
                return n.name or '<luacall>'
            else
                -- source short_src linedefined what name namewhat nups func
                local name = n.name or n.namewhat or n.what
                if not name or name == "" then name = "?" end
                return string.format("%s : %s : %s", n.short_src or "unknown source", n.linedefined or "--", name)
            end
        else
            return "unknown"
        end
    end

    function debugger.showstats(printer,threshold)
        printer   = printer   or texio.write or print
        threshold = threshold or 0
        local total, grandtotal, functions = 0, 0, 0
        printer("\n") -- ugly but ok
        for func, count in pairs(counters) do
            if count > threshold then
                printer(string.format("%8i  %s\n", count, getname(func)))
                total = total + count
            end
            grandtotal = grandtotal + count
            functions = functions + 1
        end
        printer(string.format("functions: %s, total: %s, grand total: %s, threshold: %s\n", functions, total, grandtotal, threshold))
    end

    function debugger.savestats(filename,threshold)
        local f = io.open(filename,'w')
        if f then
            debugger.showstats(function(str) f:write(str) end,threshold)
            f:close()
        end
    end

    function debugger.enable()
        debug.sethook(hook,"c")
    end

    function debugger.disable()
        debug.sethook()
    --~ counters[debug.getinfo(2,"f").func] = nil
    end

    function debugger.tracing()
        return tonumber((os.env['MTX.TRACE.CALLS'] or os.env['MTX_TRACE_CALLS'] or 0)) > 0
    end

end

--~ debugger.enable()

--~ print(math.sin(1*.5))
--~ print(math.sin(1*.5))
--~ print(math.sin(1*.5))
--~ print(math.sin(1*.5))
--~ print(math.sin(1*.5))

--~ debugger.disable()

--~ print("")
--~ debugger.showstats()
--~ print("")
--~ debugger.showstats(print,3)

