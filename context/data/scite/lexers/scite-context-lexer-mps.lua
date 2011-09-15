local info = {
    version   = 1.002,
    comment   = "scintilla lpeg lexer for metafun",
    author    = "Hans Hagen, PRAGMA-ADE, Hasselt NL",
    copyright = "PRAGMA ADE / ConTeXt Development Team",
    license   = "see context related readme files",
}

local lexer = lexer
local global, string, table, lpeg = _G, string, table, lpeg
local token, style, colors, exact_match, no_style = lexer.token, lexer.style, lexer.colors, lexer.exact_match, lexer.style_nothing
local P, R, S, V, C, Cmt = lpeg.P, lpeg.R, lpeg.S, lpeg.V, lpeg.C, lpeg.Cmt
local type, next, pcall, loadfile = type, next, pcall, loadfile

module(...)

local metafunlexer = _M
local basepath     = lexer.context and lexer.context.path or _LEXERHOME

local metafuncommands   = { }
local plaincommands     = { }
local primitivecommands = { }

do

    local definitions = lexer.context.loaddefinitions("mult-mps.lua")

    if definitions then
        metafuncommands   = definitions.metafun    or { }
        plaincommands     = definitions.plain      or { }
        primitivecommands = definitions.primitives or { }
    end

end

local whitespace = metafunlexer.WHITESPACE -- triggers states

local space      = lexer.space -- S(" \n\r\t\f\v")
local any        = lexer.any

local digit      = R("09")
local sign       = S("+-")
local period     = P(".")
local dquote     = P('"')
local cstoken    = R("az","AZ") + P("_")
local number     = sign^-1 * (                     -- at most one
                        digit^1 * period * digit^0 -- 10.0 10.
                      + digit^0 * period * digit^1 -- 0.10 .10
                      + digit^1                    -- 10
                   )

local spacing    = token(whitespace,  space^1)
local rest       = token('default',   any)
local comment    = token('comment',   P('%') * (1-S("\n\r"))^0)
local metafun    = token('command',   exact_match(metafuncommands))
local plain      = token('plain',     exact_match(plaincommands))
local quoted     = token('quote',     dquote)
                 * token('string',    P(1-dquote)^1)
                 * token('quote',     dquote)
local primitive  = token('primitive', exact_match(primitivecommands))
----- csname     = token('user',      cstoken^1)
local identifier = token('default',   cstoken^1)
local number     = token('number',    number)
local special    = token('special',   S("#()[]<>=:\""))
local extra      = token('extra',     S("`~%^&_-+/\'|\\"))

_rules = {
    { 'whitespace', spacing    },
    { 'comment',    comment    },
    { 'metafun',    metafun    },
    { 'plain',      plain      },
    { 'primitive',  primitive  },
    { 'identifier', identifier },
    { 'number',     number     },
    { 'quoted',     quoted     },
    { 'special',    special    },
    { 'extra',      extra      },
    { 'rest',       rest       },
}

_tokenstyles = lexer.context.styleset

_foldsymbols = {
    _patterns = {
        "%l+",
    },
    ["primitive"] = {
        ["beginfig"]      =  1,
        ["endfig"]        = -1,
        ["def"]           =  1,
        ["vardef"]        =  1,
        ["primarydef"]    =  1,
        ["secondarydef" ] =  1,
        ["tertiarydef"]   =  1,
        ["enddef"]        = -1,
        ["if"]            =  1,
        ["fi"]            = -1,
        ["for"]           =  1,
        ["forever"]       =  1,
        ["endfor"]        = -1,
    }
}
