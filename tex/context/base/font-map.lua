if not modules then modules = { } end modules ['font-map'] = {
    version   = 1.001,
    comment   = "companion to font-ini.tex",
    author    = "Hans Hagen, PRAGMA-ADE, Hasselt NL",
    copyright = "PRAGMA ADE / ConTeXt Development Team",
    license   = "see context related readme files"
}

--[[ldx--
<p>Eventually this code will disappear because map files are kind
of obsolete. Some code may move to runtime or auxiliary modules.</p>
--ldx]]--

fonts            = fonts            or { }
fonts.map        = fonts.map        or { }
fonts.map.data   = fonts.map.data   or { }
fonts.map.done   = fonts.map.done   or { }
fonts.map.line   = fonts.map.line   or { }
fonts.map.loaded = fonts.map.loaded or { }
fonts.map.direct = fonts.map.direct or { }

function fonts.map.line.pdfmapline(tag,str)
    return "\\loadmapline[" .. tag .. "][" .. str .. "]"
end

function fonts.map.line.pdftex(e) -- so far no combination of slant and stretch
    if e.name and e.file then
        local fullname = e.fullname or ""
        if e.slant and tonumber(e.slant) ~= 0 then
            if e.encoding then
                return fonts.map.line.pdfmapline("=",string.format('%s %s "%g SlantFont" <%s <%s',e.name,fullname,e.slant,e.encoding,e.file))
            else
                return fonts.map.line.pdfmapline("=",string.format('%s %s "%g SlantFont" <%s',e.name,fullname,e.slant,e.file))
            end
        elseif e.stretch and tonumber(e.stretch) ~= 1 and tonumber(e.stretch) ~= 0 then
            if e.encoding then
                return fonts.map.line.pdfmapline("=",string.format('%s %s "%g ExtendFont" <%s <%s',e.name,fullname,e.stretch,e.encoding,e.file))
            else
                return fonts.map.line.pdfmapline("=",string.format('%s %s "%g ExtendFont" <%s',e.name,fullname,e.stretch,e.file))
            end
        else
            if e.encoding then
                return fonts.map.line.pdfmapline("=",string.format('%s %s <%s <%s',e.name,fullname,e.encoding,e.file))
            else
                return fonts.map.line.pdfmapline("=",string.format('%s %s <%s',e.name,fullname,e.file))
            end
        end
    else
        return nil
    end
end

function fonts.map.flushlines(backend,separator)
    local t = { }
    for k,v in pairs(fonts.map.data) do
        if not fonts.map.done[k] then
            local str = fonts.map.line[backend](v)
            if str then
                t[#t+1] = str
            end
            fonts.map.done[k] = true
        end
    end
    return table.join(t,separator or "")
end

fonts.map.line.dvips    = fonts.map.line.pdftex
fonts.map.line.dvipdfmx = function() end

function fonts.map.process_entries(filename, backend, handle)
    local root = xml.load(filename,true)
    if root then
        if not handle then handle = texio.write_nl end
        xml.process_attributes(root, "/fontlist/font", function(e,k)
            local str = fonts.map.line[backend](e)
            if str then
                handle(str)
            end
        end)
    end
end

function fonts.map.convert_entries(filename)
    if not fonts.map.loaded[filename] then
        local root = xml.load(filename,true) -- todo: stop garbage collector
        if root then
            garbagecollector.push()
            xml.process_attributes(root, "/fontlist/font", function(e,k)
                if e.name and e.file then
                    fonts.map.data[e.name] = e
                --  fonts.map.data[e.name].name = nil -- beware, deletes xml entry as well
                end
            end)
            garbagecollector.pop()
        end
        fonts.map.loaded[filename] = true
    end
end

function fonts.map.direct.pdftex(filename)
    fonts.map.process_entries(filename,'pdftex',function(str)
        tex.sprint(tex.ctxcatcodes,str)
    end)
end

-- the next one will go to a runtime module, no need to put this in the format

function fonts.map.convert_file(filename, handle) -- when handle is string, then assume file
    local f, g = io.open(filename), nil
    if f then
        if not handle then
            handle = print
        elseif type(handle) == "string" then
            g = io.open(handle,"w")
            function handle(str)
                g:write(str .. "\n")
            end
        end
        handle("<?xml version='1.0' standalone='yes'?>\n")
        handle(string.format("<!-- %s -->\n", "generated by context"))
        handle(string.format("<fontlist original='%s'>\n", filename))
        for line in f:lines() do
            local comment = line:match("^[%#%%]%s*(.*)%s*$")
            if comment then -- todo: optional
                handle(string.format("  <!-- %s -->", comment))
            elseif line:find("^\s*$") then
                handle("")
            else
                name, fullname, spec, encoding, file = line:match("^(%S+)%s+(%S-)%s*\"([^\"]-)\"%s*<%s*(%S-)%s*<%s*(%S-)%s*$")
                if not name then
                    name, fullname, spec, file = line:match("^(%S+)%s+(%S-)%s*\"([^\"]-)\"%s*<%s*(%S-)%s*$")
                end
                if not name then
                    name, fullname, encoding, file = line:match("^(%S+)%s+(%S-)%s*<%s*(%S-)%s*<%s*(%S-)%s*$")
                end
                if not name then
                    name, fullname, file = line:match("^(%S+)%s+(%S-)%s*<%s*(%S-)%s*$")
                end
                if name and name ~= "" and file and file ~= "" then
                    t = { }
                    if name                        then t[#t+1] = string.format("name='%s'"    , name)     end
                    if fullname and fullname ~= "" then t[#t+1] = string.format("fullname='%s'", fullname) end
                    if encoding and encoding ~= "" then t[#t+1] = string.format("encoding='%s'", encoding) end
                    if file                        then t[#t+1] = string.format("file='%s'"    , file)     end
                    if spec then
                        local a, b = spec:match("^([%d%.])%s+(%a+)$")
                        if a and b and b == "ExtendFont" then t[#t+1] = string.format("slant='%s'"  , a) end
                        if a and b and b == "SlantFont"  then t[#t+1] = string.format("stretch='%s'", a) end
                    end
                    handle(string.format("  <font %s/>",table.concat(t," ")))
                end
            end
        end
        handle("\n</fontlist>")
        f:close()
        if g then g:close() end
    end
end

--~ fonts.map.convert_file("c:/data/develop/tex/texmf/fonts/map/dvips/lm/lm-ec.map")
--~ fonts.map.convert_file("maptest.map")
--~ fonts.map.convert_file("maptest.map", "maptest-1.xml")
--~ fonts.map.convert_file("c:/data/develop/tex/texmf/fonts/map/pdftex/updmap/pdftex.map")
--~ fonts.map.convert_file("c:/data/develop/tex/texmf/fonts/map/pdftex/updmap/pdftex.map", "maptest-2.xml")

--~ fonts.map.convert_entries('maptest-2.xml')
--~ fonts.map.process_entries('maptest.xml','pdftex')

--~ print(table.serialize(fonts.map.data))

--~ tex.sprint(fonts.map.flushlines("pdftex","\n"))
--~ str = fonts.map.flushlines("pdftex")
