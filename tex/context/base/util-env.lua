if not modules then modules = { } end modules ['util-env'] = {
    version   = 1.001,
    comment   = "companion to luat-lib.mkiv",
    author    = "Hans Hagen, PRAGMA-ADE, Hasselt NL",
    copyright = "PRAGMA ADE / ConTeXt Development Team",
    license   = "see context related readme files"
}

local allocate, mark = utilities.storage.allocate, utilities.storage.mark

local format, sub, match, gsub, find = string.format, string.sub, string.match, string.gsub, string.find
local unquoted, quoted = string.unquoted, string.quoted
local concat, insert, remove = table.concat, table.insert, table.remove

environment       = environment or { }
local environment = environment

-- precautions

os.setlocale(nil,nil) -- useless feature and even dangerous in luatex

function os.setlocale()
    -- no way you can mess with it
end

-- dirty tricks (we will replace the texlua call by luatex --luaonly)

local validengines = allocate {
    ["luatex"]        = true,
    ["luajittex"]     = true,
 -- ["luatex.exe"]    = true,
 -- ["luajittex.exe"] = true,
}

local basicengines = allocate {
    ["luatex"]        = "luatex",
    ["texlua"]        = "luatex",
    ["texluac"]       = "luatex",
    ["luajittex"]     = "luajittex",
    ["texluajit"]     = "luajittex",
 -- ["texlua.exe"]    = "luatex",
 -- ["texluajit.exe"] = "luajittex",
}

local luaengines=allocate {
    ["lua"]    = true,
    ["luajit"] = true,
}

environment.validengines = validengines
environment.basicengines = basicengines

-- [-1] = binary
-- [ 0] = self
-- [ 1] = argument 1 ...

-- instead we could set ranges

if not arg then
    -- used as library
elseif luaengines[file.removesuffix(arg[-1])] then
--     arg[-1] = arg[0]
--     arg[ 0] = arg[1]
--     for k=2,#arg do
--         arg[k-1] = arg[k]
--     end
--     remove(arg) -- last
elseif validengines[file.removesuffix(arg[0])] then
    if arg[1] == "--luaonly" then
        arg[-1] = arg[0]
        arg[ 0] = arg[2]
        for k=3,#arg do
            arg[k-2] = arg[k]
        end
        remove(arg) -- last
        remove(arg) -- pre-last
    else
        -- tex run
    end

    -- This is an ugly hack but it permits symlinking a script (say 'context') to 'mtxrun' as in:
    --
    --   ln -s /opt/minimals/tex/texmf-linux-64/bin/mtxrun context
    --
    -- The special mapping hack is needed because 'luatools' boils down to 'mtxrun --script base'
    -- but it's unlikely that there will be more of this

    local originalzero   = file.basename(arg[0])
    local specialmapping = { luatools == "base" }

    if originalzero ~= "mtxrun" and originalzero ~= "mtxrun.lua" then
       arg[0] = specialmapping[originalzero] or originalzero
       insert(arg,0,"--script")
       insert(arg,0,"mtxrun")
    end

end

-- environment

environment.arguments   = allocate()
environment.files       = allocate()
environment.sortedflags = nil

-- context specific arguments (in order not to confuse the engine)

function environment.initializearguments(arg)
    local arguments, files = { }, { }
    environment.arguments, environment.files, environment.sortedflags = arguments, files, nil
    for index=1,#arg do
        local argument = arg[index]
        if index > 0 then
            local flag, value = match(argument,"^%-+(.-)=(.-)$")
            if flag then
                flag = gsub(flag,"^c:","")
                arguments[flag] = unquoted(value or "")
            else
                flag = match(argument,"^%-+(.+)")
                if flag then
                    flag = gsub(flag,"^c:","")
                    arguments[flag] = true
                else
                    files[#files+1] = argument
                end
            end
        end
    end
    environment.ownname = file.reslash(environment.ownname or arg[0] or 'unknown.lua')
end

function environment.setargument(name,value)
    environment.arguments[name] = value
end

-- todo: defaults, better checks e.g on type (boolean versus string)
--
-- tricky: too many hits when we support partials unless we add
-- a registration of arguments so from now on we have 'partial'

function environment.getargument(name,partial)
    local arguments, sortedflags = environment.arguments, environment.sortedflags
    if arguments[name] then
        return arguments[name]
    elseif partial then
        if not sortedflags then
            sortedflags = allocate(table.sortedkeys(arguments))
            for k=1,#sortedflags do
                sortedflags[k] = "^" .. sortedflags[k]
            end
            environment.sortedflags = sortedflags
        end
        -- example of potential clash: ^mode ^modefile
        for k=1,#sortedflags do
            local v = sortedflags[k]
            if find(name,v) then
                return arguments[sub(v,2,#v)]
            end
        end
    end
    return nil
end

environment.argument = environment.getargument

function environment.splitarguments(separator) -- rather special, cut-off before separator
    local done, before, after = false, { }, { }
    local originalarguments = environment.originalarguments
    for k=1,#originalarguments do
        local v = originalarguments[k]
        if not done and v == separator then
            done = true
        elseif done then
            after[#after+1] = v
        else
            before[#before+1] = v
        end
    end
    return before, after
end

function environment.reconstructcommandline(arg,noquote)
    arg = arg or environment.originalarguments
    if noquote and #arg == 1 then
        -- we could just do: return unquoted(resolvers.resolve(arg[i]))
        local a = arg[1]
        a = resolvers.resolve(a)
        a = unquoted(a)
        return a
    elseif #arg > 0 then
        local result = { }
        for i=1,#arg do
            -- we could just do: result[#result+1] = format("%q",unquoted(resolvers.resolve(arg[i])))
            local a = arg[i]
            a = resolvers.resolve(a)
            a = unquoted(a)
            a = gsub(a,'"','\\"') -- tricky
            if find(a," ") then
                result[#result+1] = quoted(a)
            else
                result[#result+1] = a
            end
        end
        return concat(result," ")
    else
        return ""
    end
end

-- -- to be tested:
--
-- function environment.reconstructcommandline(arg,noquote)
--     arg = arg or environment.originalarguments
--     if noquote and #arg == 1 then
--         return unquoted(resolvers.resolve(arg[1]))
--     elseif #arg > 0 then
--         local result = { }
--         for i=1,#arg do
--             result[#result+1] = format("%q",unquoted(resolvers.resolve(arg[i]))) -- always quote
--         end
--         return concat(result," ")
--     else
--         return ""
--     end
-- end

if arg then

    -- new, reconstruct quoted snippets (maybe better just remove the " then and add them later)
    local newarg, instring = { }, false

    for index=1,#arg do
        local argument = arg[index]
        if find(argument,"^\"") then
            newarg[#newarg+1] = gsub(argument,"^\"","")
            if not find(argument,"\"$") then
                instring = true
            end
        elseif find(argument,"\"$") then
            newarg[#newarg] = newarg[#newarg] .. " " .. gsub(argument,"\"$","")
            instring = false
        elseif instring then
            newarg[#newarg] = newarg[#newarg] .. " " .. argument
        else
            newarg[#newarg+1] = argument
        end
    end
    for i=1,-5,-1 do
        newarg[i] = arg[i]
    end

    environment.initializearguments(newarg)

    environment.originalarguments = mark(newarg)
    environment.rawarguments      = mark(arg)

    arg = { } -- prevent duplicate handling

end
