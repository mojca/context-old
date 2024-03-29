if not modules then modules = { } end modules ['task-ini'] = {
    version   = 1.001,
    comment   = "companion to task-ini.mkiv",
    author    = "Hans Hagen, PRAGMA-ADE, Hasselt NL",
    copyright = "PRAGMA ADE / ConTeXt Development Team",
    license   = "see context related readme files"
}

-- this is a temporary solution, we need to isolate some modules and then
-- the load order can determine the trickery to be applied to node lists
--
-- we can disable more handlers and enable then when really used (*)
--
-- todo: two finalizers: real shipout (can be imposed page) and page shipout (individual page)

local tasks           = nodes.tasks
local appendaction    = tasks.appendaction
local disableaction   = tasks.disableaction
local freezegroup     = tasks.freezegroup
local freezecallbacks = callbacks.freeze

appendaction("processors",   "normalizers", "typesetters.characters.handler")                    -- always on
appendaction("processors",   "normalizers", "fonts.collections.process")                         -- disabled
appendaction("processors",   "normalizers", "fonts.checkers.missing")                            -- disabled

appendaction("processors",   "characters",  "scripts.autofontfeature.handler")
appendaction("processors",   "characters",  "typesetters.cleaners.handler")                      -- disabled
appendaction("processors",   "characters",  "typesetters.directions.handler")                    -- disabled
appendaction("processors",   "characters",  "typesetters.cases.handler")                         -- disabled
appendaction("processors",   "characters",  "typesetters.breakpoints.handler")                   -- disabled
appendaction("processors",   "characters",  "scripts.preprocess")

appendaction("processors",   "words",       "builders.kernel.hyphenation")                       -- always on
appendaction("processors",   "words",       "languages.words.check")                             -- disabled

appendaction("processors",   "fonts",       "builders.paragraphs.solutions.splitters.split")     -- experimental
appendaction("processors",   "fonts",       "nodes.handlers.characters")                         -- maybe todo
appendaction("processors",   "fonts",       "nodes.injections.handler")                          -- maybe todo
appendaction("processors",   "fonts",       "nodes.handlers.protectglyphs", nil, "nohead")       -- maybe todo
appendaction("processors",   "fonts",       "builders.kernel.ligaturing")                        -- always on (could be selective: if only node mode)
appendaction("processors",   "fonts",       "builders.kernel.kerning")                           -- always on (could be selective: if only node mode)
appendaction("processors",   "fonts",       "nodes.handlers.stripping")                          -- disabled (might move)
------------("processors",   "fonts",       "typesetters.italics.handler")                       -- disabled (after otf/kern handling)

appendaction("processors",   "lists",       "typesetters.spacings.handler")                      -- disabled
appendaction("processors",   "lists",       "typesetters.kerns.handler")                         -- disabled
appendaction("processors",   "lists",       "typesetters.digits.handler")                        -- disabled (after otf handling)
appendaction("processors",   "lists",       "typesetters.italics.handler")                       -- disabled (after otf/kern handling)
appendaction("processors",   "lists",       "typesetters.paragraphs.handler")                    -- disabled

appendaction("shipouts",     "normalizers", "nodes.handlers.cleanuppage")                        -- disabled
appendaction("shipouts",     "normalizers", "typesetters.alignments.handler")
appendaction("shipouts",     "normalizers", "nodes.references.handler")                          -- disabled
appendaction("shipouts",     "normalizers", "nodes.destinations.handler")                        -- disabled
appendaction("shipouts",     "normalizers", "nodes.rules.handler")                               -- disabled
appendaction("shipouts",     "normalizers", "nodes.shifts.handler")                              -- disabled
appendaction("shipouts",     "normalizers", "structures.tags.handler")                           -- disabled
appendaction("shipouts",     "normalizers", "nodes.handlers.accessibility")                      -- disabled
appendaction("shipouts",     "normalizers", "nodes.handlers.backgrounds")                        -- disabled
appendaction("shipouts",     "normalizers", "nodes.handlers.alignbackgrounds")                   -- disabled
------------("shipouts",     "normalizers", "nodes.handlers.export")                             -- disabled

appendaction("shipouts",     "finishers",   "nodes.visualizers.handler")                         -- disabled
appendaction("shipouts",     "finishers",   "attributes.colors.handler")                         -- disabled
appendaction("shipouts",     "finishers",   "attributes.transparencies.handler")                 -- disabled
appendaction("shipouts",     "finishers",   "attributes.colorintents.handler")                   -- disabled
appendaction("shipouts",     "finishers",   "attributes.negatives.handler")                      -- disabled
appendaction("shipouts",     "finishers",   "attributes.effects.handler")                        -- disabled
appendaction("shipouts",     "finishers",   "attributes.viewerlayers.handler")                   -- disabled

appendaction("math",         "normalizers", "noads.handlers.unscript", nil, "nohead")            -- always on (maybe disabled)
appendaction("math",         "normalizers", "noads.handlers.variants", nil, "nohead")            -- always on
appendaction("math",         "normalizers", "noads.handlers.families", nil, "nohead")            -- always on
appendaction("math",         "normalizers", "noads.handlers.relocate", nil, "nohead")            -- always on
appendaction("math",         "normalizers", "noads.handlers.render",   nil, "nohead")            -- always on
appendaction("math",         "normalizers", "noads.handlers.collapse", nil, "nohead")            -- always on
appendaction("math",         "normalizers", "noads.handlers.resize",   nil, "nohead")            -- always on
------------("math",         "normalizers", "noads.handlers.respace",  nil, "nohead")            -- always on
appendaction("math",         "normalizers", "noads.handlers.check",    nil, "nohead")            -- always on
appendaction("math",         "normalizers", "noads.handlers.tags",     nil, "nohead")            -- disabled
appendaction("math",         "normalizers", "noads.handlers.italics",  nil, "nohead")            -- disabled

appendaction("math",         "builders",    "builders.kernel.mlist_to_hlist")                    -- always on
------------("math",         "builders",    "noads.handlers.italics",  nil, "nohead")            -- disabled

-- quite experimental (nodes.handlers.graphicvadjust might go away)

appendaction("finalizers",   "lists",       "builders.paragraphs.keeptogether")
appendaction("finalizers",   "lists",       "nodes.handlers.graphicvadjust")                     -- todo
appendaction("finalizers",   "fonts",       "builders.paragraphs.solutions.splitters.optimize")  -- experimental
appendaction("finalizers",   "lists",       "builders.paragraphs.tag")

-- still experimental

appendaction("mvlbuilders",  "normalizers", "nodes.handlers.migrate")                            --
appendaction("mvlbuilders",  "normalizers", "builders.vspacing.pagehandler")                     -- last !

appendaction("vboxbuilders", "normalizers", "builders.vspacing.vboxhandler")                     --

-- experimental too

appendaction("mvlbuilders","normalizers","typesetters.checkers.handler")
appendaction("vboxbuilders","normalizers","typesetters.checkers.handler")

-- speedup: only kick in when used

disableaction("processors",  "scripts.autofontfeature.handler")
disableaction("processors",  "fonts.collections.process")
disableaction("processors",  "fonts.checkers.missing")
disableaction("processors",  "chars.handle_breakpoints")
disableaction("processors",  "typesetters.cleaners.handler")
disableaction("processors",  "typesetters.cases.handler")
disableaction("processors",  "typesetters.digits.handler")
disableaction("processors",  "typesetters.breakpoints.handler")
disableaction("processors",  "typesetters.directions.handler")
disableaction("processors",  "languages.words.check")
disableaction("processors",  "typesetters.spacings.handler")
disableaction("processors",  "typesetters.kerns.handler")
disableaction("processors",  "typesetters.italics.handler")
disableaction("processors",  "nodes.handlers.stripping")
disableaction("processors",  "typesetters.paragraphs.handler")

disableaction("shipouts",    "typesetters.alignments.handler")
disableaction("shipouts",    "nodes.rules.handler")
disableaction("shipouts",    "nodes.shifts.handler")
disableaction("shipouts",    "attributes.colors.handler")
disableaction("shipouts",    "attributes.transparencies.handler")
disableaction("shipouts",    "attributes.colorintents.handler")
disableaction("shipouts",    "attributes.effects.handler")
disableaction("shipouts",    "attributes.negatives.handler")
disableaction("shipouts",    "attributes.viewerlayers.handler")
disableaction("shipouts",    "structures.tags.handler")
disableaction("shipouts",    "nodes.visualizers.handler")
disableaction("shipouts",    "nodes.handlers.accessibility")
disableaction("shipouts",    "nodes.handlers.backgrounds")
disableaction("shipouts",    "nodes.handlers.alignbackgrounds")
disableaction("shipouts",    "nodes.handlers.cleanuppage")

disableaction("shipouts",    "nodes.references.handler")
disableaction("shipouts",    "nodes.destinations.handler")

--~ disableaction("shipouts",    "nodes.handlers.export")

disableaction("mvlbuilders", "nodes.handlers.migrate")

disableaction("processors",  "builders.paragraphs.solutions.splitters.split")

disableaction("finalizers",  "builders.paragraphs.keeptogether")
disableaction("finalizers",  "builders.paragraphs.solutions.splitters.optimize")
disableaction("finalizers",  "nodes.handlers.graphicvadjust") -- sort of obsolete
disableaction("finalizers",  "builders.paragraphs.tag")

disableaction("math",        "noads.handlers.tags")
disableaction("math",        "noads.handlers.italics")

disableaction("mvlbuilders", "typesetters.checkers.handler")
disableaction("vboxbuilders","typesetters.checkers.handler")

freezecallbacks("find_.*_file", "find file using resolver")
freezecallbacks("read_.*_file", "read file at once")
freezecallbacks("open_.*_file", "open file for reading")

-- experimental:

freezegroup("processors",   "normalizers")
freezegroup("processors",   "characters")
freezegroup("processors",   "words")
freezegroup("processors",   "fonts")
freezegroup("processors",   "lists")

freezegroup("finalizers",   "normalizers")
freezegroup("finalizers",   "fonts")
freezegroup("finalizers",   "lists")

freezegroup("shipouts",     "normalizers")
freezegroup("shipouts",     "finishers")

freezegroup("mvlbuilders",  "normalizers")
freezegroup("vboxbuilders", "normalizers")

-----------("parbuilders",  "lists")
-----------("pagebuilders", "lists")

freezegroup("math",         "normalizers")
freezegroup("math",         "builders")
