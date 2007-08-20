if not modules then modules = { } end modules ['font-enc'] = {
    version   = 1.001,
    comment   = "companion to font-ini.tex",
    author    = "Hans Hagen, PRAGMA-ADE, Hasselt NL",
    copyright = "PRAGMA ADE / ConTeXt Development Team",
    license   = "see context related readme files"
}

--[[ldx--
<p>Because encodings are going to disappear, we don't bother defining
them in tables. But we may do so some day, for consistency.</p>
--ldx]]--

fonts.enc         = fonts.enc or { }
fonts.enc.version = 1.03
fonts.enc.cache   = containers.define("fonts", "enc", fonts.enc.version, true)

fonts.enc.known = {
    texnansi = true,
    ec       = true,
    qx       = true,
    t5       = true,
    t2a      = true,
    t2b      = true,
    t2c      = true,
    unicode  = true
}

function fonts.enc.is_known(encoding)
    return containers.is_valid(fonts.enc.cache,encoding)
end

--[[ldx--
<p>An encoding file looks like this:</p>

<typing>
/TeXnANSIEncoding [
/.notdef
/Euro
...
/ydieresis
] def
</typing>

<p>Beware! The generic encoding files don't always apply to the ones that
ship with fonts. This has to do with the fact that names follow (slightly)
different standards. However, the fonts where this applies to (for instance
Latin Modern or <l n='tex'> Gyre) come in OpenType variants too, so these
will be used.</p>
--ldx]]--

function fonts.enc.load(filename)
    local name = file.removesuffix(filename)
    local data = containers.read(fonts.enc.cache,name)
    if not data then
        local vector, tag, hash, unicodes = { }, "", { }, { }
        local foundname = input.find_file(texmf.instance,filename,'enc')
        if foundname and foundname ~= "" then
            local ok, encoding, size = input.loadbinfile(texmf.instance,foundname)
            if ok and encoding then
                local enccodes = characters.context.enccodes
                encoding = encoding:gsub("%%(.-)\n","")
                local tag, vec = encoding:match("/(%w+)%s*%[(.*)%]%s*def")
                local i = 0
                for ch in vec:gmatch("/([%a%d%.]+)") do
                    if ch ~= ".notdef" then
                        vector[i] = ch
                        if not hash[ch] then
                            hash[ch] = i
                        else
                            -- duplicate, play safe for tex ligs and take first
                        end
                        if enccodes[ch] then
                            unicodes[enccodes[ch]] = i
                        end
                    end
                    i = i + 1
                end
            end
        end
        local data = {
            name=name,
            tag=tag,
            vector=vector,
            hash=hash,
            unicodes=unicodes
        }
        data = containers.write(fonts.enc.cache, name, data)
    end
    return data
end

--[[ldx--
<p>There is no unicode encoding but for practical purposed we define
one.</p>
--ldx]]--

do
    local vector, hash = { }, { }
    for k,v in pairs(characters.data) do
        local a = v.adobename
        if a then
            vector[k], hash[a] = a, k
        else
            vector[k] = '.notdef'
        end
    end
    containers.write(fonts.enc.cache, 'unicode', { name='unicode', tag='unicode', vector=vector, hash=hash })
end
