if not modules then modules = { } end modules ['lpdf-pdx'] = {
    version   = 1.001,
    comment   = "companion to lpdf-ini.mkiv",
    author    = "Peter Rolf and Hans Hagen",
    copyright = "PRAGMA ADE / ConTeXt Development Team",
    license   = "see context related readme files",
}

-- context --directives="backend.format=PDF/X-1a:2001" --trackers=backend.format yourfile

local trace_pdfx   = false  trackers.register("backend.pdfx",   function(v) trace_pdfx   = v end)
local trace_format = false  trackers.register("backend.format", function(v) trace_format = v end)

local report_backends = logs.new("backends")

local codeinjections = backends.codeinjections -- normally it is registered
local variables      = interfaces.variables

local pdfdictionary  = lpdf.dictionary
local pdfarray       = lpdf.array
local pdfconstant    = lpdf.constant
local pdfreference   = lpdf.reference
local pdfflushobject = lpdf.flushobject
local pdfstring      = lpdf.string
local pdfverbose     = lpdf.verbose
local pdfobject      = lpdf.object

local addtoinfo, injectxmpinfo, insertxmpinfo = lpdf.addtoinfo, lpdf.injectxmpinfo, lpdf.insertxmpinfo

local lower, gmatch, format, find = string.lower, string.gmatch, string.format, string.find
local concat, serialize = table.concat, table.serialize

local channels = {
    gray = 1,
    grey = 1,
    rgb  = 3,
    cmyk = 4,
}

local prefixes = {
    gray = "DefaultGray",
    grey = "DefaultGray",
    rgb  = "DefaultRGB",
    cmyk = "DefaultCMYK",
}

local pdfxspecification, pdfxformat = nil, nil

-- * correspondent document wide flags (write once) needed for permission tests

local pdfx = {
    ["version"] = {
        external_icc_profiles   = 1.4, -- 'p' in name; URL reference of output intent
        jbig2_compression       = 1.4,
        jpeg2000_compression    = 1.5, -- not supported yet
        nchannel_colorspace     = 1.6, -- 'n' in name; n-channel colorspace support
        open_prepress_interface = 1.3, -- 'g' in name; reference to external graphics
        opentype_fonts          = 1.6,
        optional_content        = 1.5,
        transparency            = 1.4,
        object_compression      = 1.5,
    },
    ["default"] = {
        pdf_version             = 1.7,  -- todo: block tex primitive
        format_name             = "default",
        gray_scale              = true,
        cmyk_colors             = true,
        rgb_colors              = true,
        spot_colors             = true,
        calibrated_rgb_colors   = true, -- unknown
        cielab_colors           = true, -- unknown
        nchannel_colorspace     = true, -- unknown
        internal_icc_profiles   = true, -- controls profile inclusion
        external_icc_profiles   = true, -- controls profile inclusion
        include_intents         = true,
        open_prepress_interface = true, -- unknown
        opentype_fonts          = true, -- out of our control
        optional_content        = true, -- todo: block at lua level
        transparency            = true, -- todo: block at lua level
        jbig2_compression       = true, -- todo: block at lua level
        jpeg2000_compression    = true, -- todo: block at lua level
        inject_metadata         = function()
            -- nothing
        end
    },
    ["pdf/x-1a:2001"] = {
        pdf_version             = 1.3,
        format_name             = "PDF/X-1a:2001",
        gray_scale              = true,
        cmyk_colors             = true,
        spot_colors             = true,
        internal_icc_profiles   = true,
        inject_metadata         = function()
            addtoinfo("GTS_PDFXVersion","PDF/X-1a:2001")
            injectxmpinfo("xml://rdf:RDF","<rdf:Description rdf:about='' xmlns:pdfxid='http://www.npes.org/pdfx/ns/id/'><pdfxid:GTS_PDFXVersion>PDF/X-1a:2001</pdfxid:GTS_PDFXVersion></rdf:Description>",false)
        end
    },
    ["pdf/x-1a:2003"] = {
        pdf_version             = 1.4,
        format_name             = "PDF/X-1a:2003",
        gray_scale              = true,
        cmyk_colors             = true,
        spot_colors             = true,
        internal_icc_profiles   = true,
        inject_metadata         = function()
            addtoinfo("GTS_PDFXVersion","PDF/X-1a:2003")
            injectxmpinfo("xml://rdf:RDF","<rdf:Description rdf:about='' xmlns:pdfxid='http://www.npes.org/pdfx/ns/id/'><pdfxid:GTS_PDFXVersion>PDF/X-1a:2003</pdfxid:GTS_PDFXVersion></rdf:Description>",false)
        end
    },
    ["pdf/x-3:2002"] = {
        pdf_version             = 1.3,
        format_name             = "PDF/X-3:2002",
        gray_scale              = true,
        cmyk_colors             = true,
        rgb_colors              = true,
        calibrated_rgb_colors   = true,
        spot_colors             = true,
        cielab_colors           = true,
        internal_icc_profiles   = true,
        include_intents         = true,
        inject_metadata         = function()
            addtoinfo("GTS_PDFXVersion","PDF/X-3:2002")
        end
    },
    ["pdf/x-3:2003"] = {
        pdf_version             = 1.4,
        format_name             = "PDF/X-3:2003",
        gray_scale              = true,
        cmyk_colors             = true,
        rgb_colors              = true,
        calibrated_rgb_colors   = true,
        spot_colors             = true,
        cielab_colors           = true,
        internal_icc_profiles   = true,
        include_intents         = true,
        jbig2_compression       = true,
        inject_metadata         = function()
            addtoinfo("GTS_PDFXVersion","PDF/X-3:2003")
        end
    },
    ["pdf/x-4"] = {
        pdf_version             = 1.6,
        format_name             = "PDF/X-4",
        gray_scale              = true,
        cmyk_colors             = true,
        rgb_colors              = true,
        calibrated_rgb_colors   = true,
        spot_colors             = true,
        cielab_colors           = true,
        internal_icc_profiles   = true,
        include_intents         = true,
        opentype_fonts          = true,
        optional_content        = true,
        transparency            = true,
        jbig2_compression       = true,
        jpeg2000_compression    = true,
        inject_metadata         = function()
            injectxmpinfo("xml://rdf:RDF","<rdf:Description rdf:about='' xmlns:pdfxid='http://www.npes.org/pdfx/ns/id/'><pdfxid:GTS_PDFXVersion>PDF/X-4</pdfxid:GTS_PDFXVersion></rdf:Description>",false)
            insertxmpinfo("xml://rdf:Description/xmpMM:InstanceID","<xmpMM:VersionID>1</xmpMM:VersionID>",false)
            insertxmpinfo("xml://rdf:Description/xmpMM:InstanceID","<xmpMM:RenditionClass>default</xmpMM:RenditonClass>",false)
        end
    },
    ["pdf/x-4p"] = {
        pdf_version             = 1.6,
        format_name             = "PDF/X-4p",
        gray_scale              = true,
        cmyk_colors             = true,
        rgb_colors              = true,
        calibrated_rgb_colors   = true,
        spot_colors             = true,
        cielab_colors           = true,
        internal_icc_profiles   = true,
        external_icc_profiles   = true,
        include_intents         = true,
        opentype_fonts          = true,
        optional_content        = true,
        transparency            = true,
        jbig2_compression       = true,
        jpeg2000_compression    = true,
        nchannel_colorspace     = false,
        inject_metadata         = function()
            injectxmpinfo("xml://rdf:RDF","<rdf:Description rdf:about='' xmlns:pdfxid='http://www.npes.org/pdfx/ns/id/'><pdfxid:GTS_PDFXVersion>PDF/X-4p</pdfxid:GTS_PDFXVersion></rdf:Description>",false)
            insertxmpinfo("xml://rdf:Description/xmpMM:InstanceID","<xmpMM:VersionID>1</xmpMM:VersionID>",false)
            insertxmpinfo("xml://rdf:Description/xmpMM:InstanceID","<xmpMM:RenditionClass>default</xmpMM:RenditonClass>",false)
        end
    },
    ["pdf/x-5g"] = {
        pdf_version             = 1.6,
        format_name             = "PDF/X-5g",
        gray_scale              = true,
        cmyk_colors             = true,
        rgb_colors              = true,
        calibrated_rgb_colors   = true,
        spot_colors             = true,
        cielab_colors           = true,
        internal_icc_profiles   = true,
        include_intents         = true,
        open_prepress_interface = true,
        opentype_fonts          = true,
        optional_content        = true,
        transparency            = true,
        jbig2_compression       = true,
        jpeg2000_compression    = true,
        inject_metadata         = function()
            -- todo
        end
    },
    ["pdf/x-5pg"] = {
        pdf_version             = 1.6,
        format_name             = "PDF/X-5pg",
        gray_scale              = true,
        cmyk_colors             = true,
        rgb_colors              = true,
        calibrated_rgb_colors   = true,
        spot_colors             = true,
        cielab_colors           = true,
        internal_icc_profiles   = true,
        external_icc_profiles   = true,
        include_intents         = true,
        open_prepress_interface = true,
        opentype_fonts          = true,
        optional_content        = true,
        transparency            = true,
        jbig2_compression       = true,
        jpeg2000_compression    = true,
        inject_metadata         = function()
            -- todo
        end
    },
    ["pdf/x-5n"] = {
        pdf_version             = 1.6,
        format_name             = "PDF/X-5n",
        gray_scale              = true,
        cmyk_colors             = true,
        rgb_colors              = true,
        calibrated_rgb_colors   = true,
        spot_colors             = true,
        cielab_colors           = true,
        internal_icc_profiles   = true,
        include_intents         = true,
        opentype_fonts          = true,
        optional_content        = true,
        transparency            = true,
        jbig2_compression       = true,
        jpeg2000_compression    = true,
        nchannel_colorspace     = true,
        inject_metadata         = function()
            -- todo
        end
    }
}

lpdf.pdfx = pdfx -- it does not hurt to have this one visible

local filenames = {
    "colorprofiles.xml",
    "colorprofiles.lua",
}

local function locatefile(filename)
    local fullname = resolvers.find_file(filename,"icc")
    if not fullname or fullname == "" then
        fullname = resolvers.finders.loc(filename) -- could be specific to the project
    end
    return fullname or ""
end

local function loadprofile(name,filename)
    local profile = false
    local databases = filename and filename ~= "" and aux.settings_to_array(filename) or filenames
    for i=1,#databases do
        local filename = locatefile(databases[i])
        if filename and filename ~= "" then
            local suffix = file.extname(filename)
            local lname = lower(name)
            if suffix == "xml" then
                local xmldata = xml.load(filename) -- no need for caching it
                if xmldata then
                    profile = xml.filter(xmldata,format('xml://profiles/profile/(info|filename)[lower(text())=="%s"]/../table()',lname))
                end
            elseif suffix == "lua" then
                local luadata = loadfile(filename)
                luadata = ludata and luadata()
                if luadata then
                    profile = luadata[name] or luadata[lname] -- hashed
                    if not profile then
                        for i=1,#luadata do
                            local li = luadata[i]
                            if lower(li.info) == lname then -- indexed
                                profile = li
                                break
                            end
                        end
                    end
                end
            end
            if profile then
                if next(profile) then
                    report_backends("profile specification '%s' loaded from '%s'",name,filename)
                    return profile
                elseif trace_pdfx then
                    report_backends("profile specification '%s' loaded from '%s' but empty",name,filename)
                end
                return false
            end
        end
    end
    report_backends("profile specification '%s' not found in '%s'",name,concat(filenames, ", "))
end

local function urls(url)
    if not url or url == "" then
        return nil
    else
        local u = pdfarray()
        for url in gmatch(url,"([^, ]+)") do
            if find(url,"^http") then
                u[#u+1] = pdfdictionary {
                    FS = pdfconstant("URL"),
                    F  = pdfstring(url),
                }
            end
        end
        return u
    end
end

local function profilename(filename)
    return lower(file.basename(filename))
end

local internalprofiles = { }

local function handleinternalprofile(s,include)
    local filename, colorspace = s.filename or "", s.colorspace or ""
    if filename == "" or colorspace == "" then
        report_backends("error in internal profile specification: %s",serialize(s,false))
    else
        local tag = profilename(filename)
        local profile = internalprofiles[tag]
        if not profile then
            local colorspace = lower(colorspace)
            if include then
             -- local fullname = resolvers.findctxfile(filename) or ""
                local fullname = locatefile(filename)
                local channel = channels[colorspace] or nil
                if fullname == "" then
                    report_backends("error, couldn't locate profile '%s'",filename)
                elseif not channel then
                    report_backends("error, couldn't resolve channel entry for colorspace '%s'",colorspace)
                else
                    local a = pdfdictionary { N = channel }
                    profile = pdfobject { -- does a flush too
                        compresslevel = 0,
                        immediate     = true, -- !
                        type          = "stream",
                        file          = fullname,
                        attr          = a(),
                    }
                    internalprofiles[tag] = profile
                    if trace_pdfx then
                        report_backends("including '%s' color profile from '%s'",colorspace,fullname)
                    end
                end
            else
                internalprofiles[tag] = true
                if trace_pdfx then
                    report_backends("not including '%s' color profile '%s'",colorspace,filename)
                end
            end
        end
        return profile
    end
end

local externalprofiles = { }

local function handleexternalprofile(s,include) -- specification (include ignored here)
    local name, url, filename, checksum, version, colorspace =
        s.info or s.filename or "", s.url or "", s.filename or "", s.checksum or "", s.version or "", s.colorspace or ""
    if false then -- somehow leads to invalid pdf
        local iccprofile = colors.iccprofile(filename)
        if iccprofile then
            name       = name       ~= "" and name       or iccprofile.tags.desc.cleaned       or ""
            url        = url        ~= "" and url        or iccprofile.tags.dmnd.cleaned       or ""
            checksum   = checksum   ~= "" and checksum   or file.checksum(iccprofile.fullname) or ""
            version    = version    ~= "" and version    or iccprofile.header.version          or ""
            colorspace = colorspace ~= "" and colorspace or iccprofile.header.colorspace       or ""
        end
     -- table.print(iccprofile)
    end
    if name == "" or url == "" or checksum == "" or version == "" or colorspace == "" or filename == "" then
        local profile = handleinternalprofile(s)
        if profile then
            report_backends("incomplete external profile specification, falling back to internal")
        else
            report_backends("error in external profile specification: %s",serialize(s,false))
        end
    else
        local tag = profilename(filename)
        local profile = externalprofiles[tag]
        if not profile then
            local d = pdfdictionary {
                ProfileName = name,                                     -- not file name!
                ProfileCS   = colorspace,
                URLs        = urls(url),                                -- array containing at least one URL
                CheckSum    = pdfverbose { "<", lower(checksum), ">" }, -- 16byte MD5 hash
                ICCVersion  = pdfverbose { "<", version, ">"  },        -- bytes 8..11 from the header of the ICC profile, as a hex string
            }
            profile = pdfflushobject(d)
            externalprofiles[tag] = profile
        end
        return profile
    end
end

local loadeddefaults = { }

local function handledefaultprofile(s) -- specification
    local filename, colorspace = s.filename or "", lower(s.colorspace or "")
    if filename == "" or colorspace == "" then
        report_backends("error in default profile specification: %s",serialize(s,false))
    elseif not loadeddefaults[colorspace] then
        local tag = profilename(filename)
        local n = internalprofiles[tag] -- or externalprofiles[tag]
        if n == true then -- not internalized
            report_backends("no default profile '%s' for colorspace '%s'",filename,colorspace)
        elseif n then
            local a = pdfarray {
                pdfconstant("ICCBased"),
                pdfreference(n),
            }
             -- used in page /Resources, so this must be inserted at runtime
            lpdf.adddocumentcolorspace(prefixes[colorspace],pdfreference(pdfflushobject(a)))
            loadeddefaults[colorspace] = true
            report_backends("setting '%s' as default '%s' color space",filename,colorspace)
        else
            report_backends("no default profile '%s' for colorspace '%s'",filename,colorspace)
        end
    elseif trace_pdfx then
        report_backends("a default '%s' colorspace is already in use",colorspace)
    end
end

local loadedintents, intents = { }, pdfarray()

local function handleoutputintent(s)
    local name, url, filename, id, outputcondition, info = s.info or s.filename or "", s.url or "", s.filename or "", s.id or "", s.outputcondition or "", s.info or ""
    if name == "" or id == "" then
        report_backends("error in output intent specification: %s",serialize(s,false))
    elseif not loadedintents[name] then
        local tag = profilename(filename)
        local internal, external = internalprofiles[tag], externalprofiles[tag]
        if internal or external then
            local d = {
                  Type                      = pdfconstant("OutputIntent"),
                  S                         = pdfconstant("GTS_PDFX"),
                  OutputConditionIdentifier = id,
                  RegistryName              = url,
                  OutputCondition           = outputcondition,
                  Info                      = info,
            }
            if internal and internal ~= true then
                d.DestOutputProfile    = pdfreference(internal)
            elseif external and external ~= true then
                d.DestOutputProfileRef = pdfreference(external)
            else
                report_backends("omitting reference to profile for intent '%s'",name)
            end
            intents[#intents+1] = pdfreference(pdfflushobject(pdfdictionary(d)))
            if trace_pdfx then
                report_backends("setting output intent to '%s' with id '%s' (entry %s)",name,id,#intents)
            end
        else
            report_backends("invalid output intent '%s'",name)
        end
        loadedintents[name] = true
    elseif trace_pdfx then
        report_backends("an output intent with name '%s' is already in use",name)
    end
end

local function handleiccprofile(message,name,filename,how,options,alwaysinclude)
    if name and name ~= "" then
        local list = aux.settings_to_array(name)
        for i=1,#list do
            local name = list[i]
            local profile = loadprofile(name,filename)
            if trace_pdfx then
                report_backends("handling %s '%s'",message,name)
            end
            if profile then
                if pdfxspecification.cmyk_colors then
                    profile.colorspace = profile.colorspace or "CMYK"
                else
                    profile.colorspace = profile.colorspace or "RGB"
                end
                local external = pdfxspecification.external_icc_profiles
                local internal = pdfxspecification.internal_icc_profiles
                local include  = pdfxspecification.include_intents
                local always, never = options[variables.always], options[variables.never]
                if always or alwaysinclude then
                    if trace_pdfx then
                        report_backends("forcing internal profiles") -- can make preflight unhappy
                    end
                 -- internal, external = true, false
                    internal, external = not never, false
                elseif never then
                    if trace_pdfx then
                        report_backends("forcing external profiles") -- can make preflight unhappy
                    end
                    internal, external = false, true
                end
                if external then
                    if trace_pdfx then
                        report_backends("handling external profiles cf. '%s'",name)
                    end
                    handleexternalprofile(profile,false)
                else
                    if trace_pdfx then
                        report_backends("handling internal profiles cf. '%s'",name)
                    end
                    if internal then
                        handleinternalprofile(profile,always or include)
                    else
                        report_backends("no profile inclusion for '%s'",pdfxformat)
                    end
                end
                how(profile)
            elseif trace_pdfx then
                report_backends("unknown profile '%s'",name)
            end
        end
    end
end

local function flushoutputintents()
    if #intents > 0 then
        lpdf.addtocatalog("OutputIntents",pdfreference(pdfflushobject(intents)))
    end
end

lpdf.registerdocumentfinalizer(flushoutputintents,2,"output intents")

directives.register("backend.format", function(v)
    codeinjections.setformat(v)
end)

function codeinjections.setformat(s)
    local format, level, profile, intent, option, filename =
        s.format or "", s.level or "", s.profile or "", s.intent or "", s.option or "", s.file or ""
    if format == "" then
        -- we ignore this as we hook it in \everysetupbackend
    else
        local spec = pdfx[lower(format)]
        if spec then
            pdfxspecification, pdfxformat = spec, spec.format_name
            report_backends("setting format to '%s'",pdfxformat)
            local pdf_version, inject_metadata = spec.pdf_version * 10, spec.inject_metadata
            local majorversion, minorversion = math.div(pdf_version,10), math.mod(pdf_version,10)
            local objectcompression = pdf_version >= 15
            tex.pdfcompresslevel = level and tonumber(level) or tex.pdfobjcompresslevel  -- keep default
            tex.pdfobjcompresslevel = objectcompression and tex.pdfobjcompresslevel or 0 -- keep default
            tex.pdfmajorversion = majorversion
            tex.pdfminorversion = minorversion
            report_backends("forcing pdf version %s.%s, compression level %s, object compression %sabled",
                majorversion,minorversion,tex.pdfcompresslevel,compression and "en" or "dis")
            --
            -- context.setupcolors { -- not this way
            --     cmyk = spec.cmyk_colors and variables.yes or variables.no,
            --     rgb  = spec.rgb_colors  and variables.yes or variables.no,
            -- }
            --
            colors.forcesupport(
                spec.gray_scale          or false,
                spec.rgb_colors          or false,
                spec.cmyk_colors         or false,
                spec.spot_colors         or false,
                spec.nchannel_colorspace or false
            )
            transparencies.forcesupport(
                spec.transparency        or false
            )
            viewerlayers.forcesupport(
                spec.optional_content    or false
            )
            viewerlayers.setfeatures(
                spec.has_order           or false -- new
            )
            --
            -- spec.jbig2_compression    : todo, block in image inclusion
            -- spec.jpeg2000_compression : todo, block in image inclusion
            --
            if type(inject_metadata) == "function" then
                inject_metadata()
            end
            local options = aux.settings_to_hash(option)
            handleiccprofile("color profile",profile,filename,handledefaultprofile,options,true)
            handleiccprofile("output intent",intent,filename,handleoutputintent,options,false)
            if trace_format then
                for k, v in table.sortedhash(pdfx.default) do
                    local v = pdfxspecification[k]
                    if type(v) ~= "function" then
                        report_backends("%s = %s",k,tostring(v or false))
                    end
                end
            end
            function codeinjections.setformat(noname)
                report_backends("error, format is already set to '%s', ignoring '%s'",pdfxformat,noname)
            end
        else
            report_backends("error, format '%s' is not supported",format)
        end
    end
end

function codeinjections.getformatoption(key)
    return pdfxspecification and pdfxspecification[key]
end

--~ The following is somewhat cleaner but then we need to flag that there are
--~ color spaces set so that the page flusher does not optimize the (at that
--~ moment) still empty array away. So, next(d_colorspaces) should then become
--~ a different test, i.e. also on flag. I'll add that when we need more forward
--~ referencing.
--~
--~ local function embedprofile = handledefaultprofile
--~
--~ local function flushembeddedprofiles()
--~     for colorspace, filename in next, defaults do
--~         embedprofile(colorspace,filename)
--~     end
--~ end
--~
--~ local function handledefaultprofile(s)
--~     defaults[lower(s.colorspace)] = s.filename
--~ end
--~
--~ lpdf.registerdocumentfinalizer(flushembeddedprofiles,1,"embedded color profiles")
