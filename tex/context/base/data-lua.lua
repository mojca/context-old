if not modules then modules = { } end modules ['data-lua'] = {
    version   = 1.001,
    comment   = "companion to luat-lib.mkiv",
    author    = "Hans Hagen, PRAGMA-ADE, Hasselt NL",
    copyright = "PRAGMA ADE / ConTeXt Development Team",
    license   = "see context related readme files"
}

-- some loading stuff ... we might move this one to slot 2 depending
-- on the developments (the loaders must not trigger kpse); we could
-- of course use a more extensive lib path spec

local trace_locating = false  trackers.register("resolvers.locating", function(v) trace_locating = v end)

local report_libraries = logs.new("resolvers","libraries")

local gsub, insert = string.gsub, table.insert
local unpack = unpack or table.unpack

local resolvers, package = resolvers, package

local  libformats = { 'luatexlibs', 'tex', 'texmfscripts', 'othertextfiles' } -- 'luainputs'
local clibformats = { 'lib' }

local _path_, libpaths, _cpath_, clibpaths

function package.libpaths()
    if not _path_ or package.path ~= _path_ then
        _path_ = package.path
        libpaths = file.splitpath(_path_,";")
    end
    return libpaths
end

function package.clibpaths()
    if not _cpath_ or package.cpath ~= _cpath_ then
        _cpath_ = package.cpath
        clibpaths = file.splitpath(_cpath_,";")
    end
    return clibpaths
end

local function thepath(...)
    local t = { ... } t[#t+1] = "?.lua"
    local path = file.join(unpack(t))
    if trace_locating then
        report_libraries("! appending '%s' to 'package.path'",path)
    end
    return path
end

local p_libpaths, a_libpaths = { }, { }

function package.appendtolibpath(...)
    insert(a_libpath,thepath(...))
end

function package.prependtolibpath(...)
    insert(p_libpaths,1,thepath(...))
end

-- beware, we need to return a loadfile result !

local function loaded(libpaths,name,simple)
    for i=1,#libpaths do -- package.path, might become option
        local libpath = libpaths[i]
        local resolved = gsub(libpath,"%?",simple)
        if trace_locating then -- more detail
            report_libraries("! checking for '%s' on 'package.path': '%s' => '%s'",simple,libpath,resolved)
        end
        if file.is_readable(resolved) then
            if trace_locating then
                report_libraries("! lib '%s' located via 'package.path': '%s'",name,resolved)
            end
            return loadfile(resolved)
        end
    end
end

package.loaders[2] = function(name) -- was [#package.loaders+1]
    if trace_locating then -- mode detail
        report_libraries("! locating '%s'",name)
    end
    for i=1,#libformats do
        local format = libformats[i]
        local resolved = resolvers.findfile(name,format) or ""
        if trace_locating then -- mode detail
            report_libraries("! checking for '%s' using 'libformat path': '%s'",name,format)
        end
        if resolved ~= "" then
            if trace_locating then
                report_libraries("! lib '%s' located via environment: '%s'",name,resolved)
            end
            return loadfile(resolved)
        end
    end
    -- libpaths
    local libpaths, clibpaths = package.libpaths(), package.clibpaths()
    local simple = gsub(name,"%.lua$","")
    local simple = gsub(simple,"%.","/")
    local resolved = loaded(p_libpaths,name,simple) or loaded(libpaths,name,simple) or loaded(a_libpaths,name,simple)
    if resolved then
        return resolved
    end
    --
    local libname = file.addsuffix(simple,os.libsuffix)
    for i=1,#clibformats do
        -- better have a dedicated loop
        local format = clibformats[i]
        local paths = resolvers.expandedpathlistfromvariable(format)
        for p=1,#paths do
            local path = paths[p]
            local resolved = file.join(path,libname)
            if trace_locating then -- mode detail
                report_libraries("! checking for '%s' using 'clibformat path': '%s'",libname,path)
            end
            if file.is_readable(resolved) then
                if trace_locating then
                    report_libraries("! lib '%s' located via 'clibformat': '%s'",libname,resolved)
                end
                return package.loadlib(resolved,name)
            end
        end
    end
    for i=1,#clibpaths do -- package.path, might become option
        local libpath = clibpaths[i]
        local resolved = gsub(libpath,"?",simple)
        if trace_locating then -- more detail
            report_libraries("! checking for '%s' on 'package.cpath': '%s'",simple,libpath)
        end
        if file.is_readable(resolved) then
            if trace_locating then
                report_libraries("! lib '%s' located via 'package.cpath': '%s'",name,resolved)
            end
            return package.loadlib(resolved,name)
        end
    end
    -- just in case the distribution is messed up
    if trace_loading then -- more detail
        report_libraries("! checking for '%s' using 'luatexlibs': '%s'",name)
    end
    local resolved = resolvers.findfile(file.basename(name),'luatexlibs') or ""
    if resolved ~= "" then
        if trace_locating then
            report_libraries("! lib '%s' located by basename via environment: '%s'",name,resolved)
        end
        return loadfile(resolved)
    end
    if trace_locating then
        report_libraries('? unable to locate lib: %s',name)
    end
--  return "unable to locate " .. name
end

resolvers.loadlualib = require

-- -- -- --

package.obsolete = package.obsolete or { }

package.append_libpath           = appendtolibpath   -- will become obsolete
package.prepend_libpath          = prependtolibpath  -- will become obsolete

package.obsolete.append_libpath  = appendtolibpath   -- will become obsolete
package.obsolete.prepend_libpath = prependtolibpath  -- will become obsolete
