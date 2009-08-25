if not modules then modules = { } end modules ['l-url'] = {
    version   = 1.001,
    comment   = "companion to luat-lib.mkiv",
    author    = "Hans Hagen, PRAGMA-ADE, Hasselt NL",
    copyright = "PRAGMA ADE / ConTeXt Development Team",
    license   = "see context related readme files"
}

local char, gmatch = string.char, string.gmatch
local tonumber, type = tonumber, type

-- from the spec (on the web):
--
--     foo://example.com:8042/over/there?name=ferret#nose
--     \_/   \______________/\_________/ \_________/ \__/
--      |           |            |            |        |
--   scheme     authority       path        query   fragment
--      |   _____________________|__
--     / \ /                        \
--     urn:example:animal:ferret:nose

url = url or { }

local function tochar(s)
    return char(tonumber(s,16))
end

local colon, qmark, hash, slash, percent, endofstring = lpeg.P(":"), lpeg.P("?"), lpeg.P("#"), lpeg.P("/"), lpeg.P("%"), lpeg.P(-1)

local hexdigit  = lpeg.R("09","AF","af")
local plus      = lpeg.P("+")
local escaped   = (plus / " ") + (percent * lpeg.C(hexdigit * hexdigit) / tochar)

local scheme    =                 lpeg.Cs((escaped+(1-colon-slash-qmark-hash))^0) * colon + lpeg.Cc("")
local authority = slash * slash * lpeg.Cs((escaped+(1-      slash-qmark-hash))^0)         + lpeg.Cc("")
local path      = slash *         lpeg.Cs((escaped+(1-            qmark-hash))^0)         + lpeg.Cc("")
local query     = qmark         * lpeg.Cs((escaped+(1-                  hash))^0)         + lpeg.Cc("")
local fragment  = hash          * lpeg.Cs((escaped+(1-           endofstring))^0)         + lpeg.Cc("")

local parser = lpeg.Ct(scheme * authority * path * query * fragment)

function url.split(str)
    return (type(str) == "string" and parser:match(str)) or str
end

function url.hashed(str)
    local s = url.split(str)
    return {
        scheme = (s[1] ~= "" and s[1]) or "file",
        authority = s[2],
        path = s[3],
        query = s[4],
        fragment = s[5],
        original = str
    }
end

function url.filename(filename)
    local t = url.hashed(filename)
    return (t.scheme == "file" and t.path:gsub("^/([a-zA-Z])([:|])/)","%1:")) or filename
end

function url.query(str)
    if type(str) == "string" then
        local t = { }
        for k, v in gmatch(str,"([^&=]*)=([^&=]*)") do
            t[k] = v
        end
        return t
    else
        return str
    end
end

--~ print(url.filename("file:///c:/oeps.txt"))
--~ print(url.filename("c:/oeps.txt"))
--~ print(url.filename("file:///oeps.txt"))
--~ print(url.filename("file:///etc/test.txt"))
--~ print(url.filename("/oeps.txt"))

--~ from the spec on the web (sort of):
--~
--~ function test(str)
--~     print(table.serialize(url.hashed(str)))
--~ end
--~
--~ test("%56pass%20words")
--~ test("file:///c:/oeps.txt")
--~ test("file:///c|/oeps.txt")
--~ test("file:///etc/oeps.txt")
--~ test("file://./etc/oeps.txt")
--~ test("file:////etc/oeps.txt")
--~ test("ftp://ftp.is.co.za/rfc/rfc1808.txt")
--~ test("http://www.ietf.org/rfc/rfc2396.txt")
--~ test("ldap://[2001:db8::7]/c=GB?objectClass?one#what")
--~ test("mailto:John.Doe@example.com")
--~ test("news:comp.infosystems.www.servers.unix")
--~ test("tel:+1-816-555-1212")
--~ test("telnet://192.0.2.16:80/")
--~ test("urn:oasis:names:specification:docbook:dtd:xml:4.1.2")
--~ test("/etc/passwords")
--~ test("http://www.pragma-ade.com/spaced%20name")

--~ test("zip:///oeps/oeps.zip#bla/bla.tex")
--~ test("zip:///oeps/oeps.zip?bla/bla.tex")
