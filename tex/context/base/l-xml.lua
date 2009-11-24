if not modules then modules = { } end modules ['l-xml'] = {
    version   = 1.001,
    comment   = "this module is replaced by the lxml-* ones",
    author    = "Hans Hagen, PRAGMA-ADE, Hasselt NL",
    copyright = "PRAGMA ADE / ConTeXt Development Team",
    license   = "see context related readme files"
}

-- We asume that the helper modules l-*.lua are loaded
-- already. But anyway if you use mtxrun to run your script
-- all is taken care of.

if not trackers then
    require('trac-tra.lua')
end

if not xml then
    require('lxml-tab.lua')
    require('lxml-lpt.lua')
    require('lxml-mis.lua')
    require('lxml-aux.lua')
    require('lxml-xml.lua')
end
