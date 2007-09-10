-- filename : l-number.lua
-- comment  : split off from luat-lib
-- author   : Hans Hagen, PRAGMA-ADE, Hasselt NL
-- copyright: PRAGMA ADE / ConTeXt Development Team
-- license  : see context related readme files

if not versions then versions = { } end versions['l-number'] = 1.001

if not number then number = { } end

-- a,b,c,d,e,f = number.toset(100101)

function number.toset(n)
    return (tostring(n)):match("(.?)(.?)(.?)(.?)(.?)(.?)(.?)(.?)")
end

-- the lpeg way is slower on 8 digits, but faster on 4 digits, some 7.5%
-- on
--
-- for i=1,1000000 do
--     local a,b,c,d,e,f,g,h = number.toset(12345678)
--     local a,b,c,d         = number.toset(1234)
--     local a,b,c           = number.toset(123)
-- end
--
-- of course dedicated "(.)(.)(.)(.)" matches are even faster

do
    local one = lpeg.C(1-lpeg.S(''))^1

    function number.toset(n)
        return lpeg.match(one,tostring(n))
    end
end

