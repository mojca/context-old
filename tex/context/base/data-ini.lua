if not modules then modules = { } end modules ['data-ini'] = {
    version   = 1.001,
    comment   = "companion to luat-lib.mkiv",
    author    = "Hans Hagen, PRAGMA-ADE, Hasselt NL",
    copyright = "PRAGMA ADE / ConTeXt Development Team",
    license   = "see context related readme files",
}

local gsub, find, gmatch = string.gsub, string.find, string.gmatch
local concat = table.concat
local next, type = next, type

local filedirname, filebasename, fileextname, filejoin = file.dirname, file.basename, file.extname, file.join

local trace_locating   = false  trackers.register("resolvers.locating",   function(v) trace_locating   = v end)
local trace_detail     = false  trackers.register("resolvers.details",    function(v) trace_detail     = v end)
local trace_expansions = false  trackers.register("resolvers.expansions", function(v) trace_expansions = v end)

local report_resolvers = logs.new("resolvers")

local ostype, osname, ossetenv, osgetenv = os.type, os.name, os.setenv, os.getenv

-- The code here used to be part of a data-res but for convenience
-- we now split it over multiple files. As this file is now the
-- starting point we introduce resolvers here.

resolvers       = resolvers or { }
local resolvers = resolvers

-- We don't want the kpse library to kick in. Also, we want to be able to
-- execute programs. Control over execution is implemented later.

texconfig.kpse_init    = false
texconfig.shell_escape = 't'

kpse = { original = kpse }

setmetatable(kpse, {
    __index = function(kp,name)
        report_resolvers("fatal error: kpse library is accessed (key: %s)",name)
        os.exit()
    end
} )

-- First we check a couple of environment variables. Some might be
-- set already but we need then later on. We start with the system
-- font path.

do

    local osfontdir = osgetenv("OSFONTDIR")

    if osfontdir and osfontdir ~= "" then
        -- ok
    elseif osname == "windows" then
        ossetenv("OSFONTDIR","c:/windows/fonts//")
    elseif osname == "macosx" then
        ossetenv("OSFONTDIR","$HOME/Library/Fonts//;/Library/Fonts//;/System/Library/Fonts//")
    end

end

-- Next comes the user's home path. We need this as later on we have
-- to replace ~ with its value.

do

    local homedir = osgetenv(ostype == "windows" and 'USERPROFILE' or 'HOME') or '~'

    homedir = file.collapse_path(homedir)

    ossetenv("HOME",       homedir) -- can be used in unix cnf files
    ossetenv("USERPROFILE",homedir) -- can be used in windows cnf files

    environment.homedir = homedir

end

-- The following code sets the name of the own binary and its
-- path. This is fallback code as we have os.selfdir now.

do

    local args = environment.originalarguments or arg -- this needs a cleanup

    local ownbin  = environment.ownbin  or args[-2] or arg[-2] or args[-1] or arg[-1] or arg[0] or "luatex"
    local ownpath = environment.ownpath or os.selfdir

    ownbin  = file.collapse_path(ownbin)
    ownpath = file.collapse_path(ownpath)

    if not ownpath or ownpath == "" or ownpath == "unset" then
        ownpath = args[-1] or arg[-1]
        ownpath = ownpath and filedirname(gsub(ownpath,"\\","/"))
        if not ownpath or ownpath == "" then
            ownpath = args[-0] or arg[-0]
            ownpath = ownpath and filedirname(gsub(ownpath,"\\","/"))
        end
        local binary = ownbin
        if not ownpath or ownpath == "" then
            ownpath = ownpath and filedirname(binary)
        end
        if not ownpath or ownpath == "" then
            if os.binsuffix ~= "" then
                binary = file.replacesuffix(binary,os.binsuffix)
            end
            local path = osgetenv("PATH")
            if path then
                for p in gmatch(path,"[^"..io.pathseparator.."]+") do
                    local b = filejoin(p,binary)
                    if lfs.isfile(b) then
                        -- we assume that after changing to the path the currentdir function
                        -- resolves to the real location and use this side effect here; this
                        -- trick is needed because on the mac installations use symlinks in the
                        -- path instead of real locations
                        local olddir = lfs.currentdir()
                        if lfs.chdir(p) then
                            local pp = lfs.currentdir()
                            if trace_locating and p ~= pp then
                                report_resolvers("following symlink '%s' to '%s'",p,pp)
                            end
                            ownpath = pp
                            lfs.chdir(olddir)
                        else
                            if trace_locating then
                                report_resolvers("unable to check path '%s'",p)
                            end
                            ownpath =  p
                        end
                        break
                    end
                end
            end
        end
        if not ownpath or ownpath == "" then
            ownpath = "."
            report_resolvers("forcing fallback ownpath .")
        elseif trace_locating then
            report_resolvers("using ownpath '%s'",ownpath)
        end
    end

    environment.ownbin  = ownbin
    environment.ownpath = ownpath

end

resolvers.ownpath = environment.ownpath

function resolvers.getownpath()
    return environment.ownpath
end

-- The self variables permit us to use only a few (or even no)
-- environment variables.

do

    local ownpath = environment.ownpath or dir.current()

    if ownpath then
        ossetenv('SELFAUTOLOC',    file.collapse_path(ownpath))
        ossetenv('SELFAUTODIR',    file.collapse_path(ownpath .. "/.."))
        ossetenv('SELFAUTOPARENT', file.collapse_path(ownpath .. "/../.."))
    else
        report_resolvers("error: unable to locate ownpath")
        os.exit()
    end

end

-- The running os:

-- todo: check is context sits here os.platform is more trustworthy
-- that the bin check as mtx-update runs from another path

local texos   = environment.texos   or osgetenv("TEXOS")
local texmfos = environment.texmfos or osgetenv('SELFAUTODIR')

if not texos or texos == "" then
    texos = file.basename(texmfos)
end

ossetenv('TEXMFOS',       texmfos)      -- full bin path
ossetenv('TEXOS',         texos)        -- partial bin parent
ossetenv('SELFAUTOSYSTEM',os.platform)  -- bonus

environment.texos   = texos
environment.texmfos = texmfos

-- The current root:

local texroot = environment.texroot or osgetenv("TEXROOT")

if not texroot or texroot == "" then
    texroot = osgetenv('SELFAUTOPARENT')
    ossetenv('TEXROOT',texroot)
end

environment.texroot = file.collapse_path(texroot)

-- Tracing. Todo ...

function resolvers.settrace(n) -- no longer number but: 'locating' or 'detail'
    if n then
        trackers.disable("resolvers.*")
        trackers.enable("resolvers."..n)
    end
end

resolvers.settrace(osgetenv("MTX_INPUT_TRACE"))

-- todo:

-- if profiler and osgetenv("MTX_PROFILE_RUN") == "YES" then
--     profiler.start("luatex-profile.log")
-- end
