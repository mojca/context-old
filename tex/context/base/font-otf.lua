if not modules then modules = { } end modules ['font-otf'] = {
    version   = 1.001,
    comment   = "companion to font-ini.tex",
    author    = "Hans Hagen, PRAGMA-ADE, Hasselt NL",
    copyright = "PRAGMA ADE / ConTeXt Development Team",
    license   = "see context related readme files"
}


-- abvf abvs blwf blwm blws dist falt half halt jalt lfbd ljmo
-- mset opbd palt pwid qwid rand rtbd rtla ruby size tjmo twid valt vatu vert
-- vhal vjmo vkna vkrn vpal vrt2

-- otfdata zit in tfmdata / check

--~ function string:split_at_space()
--~     local t = { }
--~     for s in self:gmatch("(%S+)") do
--~         t[#t+1] = s
--~     end
--~     return t
--~ end

-- beware, the node related functions need to return head, current -- todo
-- we may move marks to components so that parsing is faster

-- using for i=1,#t do ... t[i] ... end is much faster than using ipairs
-- copying some functions is faster than sharing code chunks esp here

--[[ldx--
<p>This module is sparesely documented because it is a moving target.
The table format of the reader changes and we experiment a lot with
different methods for supporting features.</p>

<p>As with the <l n='afm'/> code, we may decide to store more information
in the <l n='otf'/> table.</p>
--ldx]]--

fonts                        = fonts or { }
fonts.otf                    = fonts.otf or { }
fonts.otf.version            = 1.64 -- incrementing this number one up will force a re-cache
fonts.otf.tables             = fonts.otf.tables or { }
fonts.otf.meanings           = fonts.otf.meanings or { }
fonts.otf.enhance_data       = false
fonts.otf.syncspace          = true
fonts.otf.features           = { }
fonts.otf.features.aux       = { }
fonts.otf.features.data      = { }
fonts.otf.features.list      = { } -- not (yet) used, oft fonts have gpos/gsub lists
fonts.otf.features.default   = { }
fonts.otf.trace_features     = false
fonts.otf.trace_replacements = false
fonts.otf.trace_contexts     = false
fonts.otf.trace_anchors      = false
fonts.otf.trace_ligatures    = false
fonts.otf.trace_kerns        = false
fonts.otf.notdef             = false
fonts.otf.cache              = containers.define("fonts", "otf", fonts.otf.version, true)

--[[ldx--
<p>We start with a lot of tables and related functions.</p>
--ldx]]--

fonts.otf.tables.scripts = {
    ['dflt'] = 'Default',

    ['arab'] = 'Arabic',
    ['armn'] = 'Armenian',
    ['bali'] = 'Balinese',
    ['beng'] = 'Bengali',
    ['bopo'] = 'Bopomofo',
    ['brai'] = 'Braille',
    ['bugi'] = 'Buginese',
    ['buhd'] = 'Buhid',
    ['byzm'] = 'Byzantine Music',
    ['cans'] = 'Canadian Syllabics',
    ['cher'] = 'Cherokee',
    ['copt'] = 'Coptic',
    ['cprt'] = 'Cypriot Syllabary',
    ['cyrl'] = 'Cyrillic',
    ['deva'] = 'Devanagari',
    ['dsrt'] = 'Deseret',
    ['ethi'] = 'Ethiopic',
    ['geor'] = 'Georgian',
    ['glag'] = 'Glagolitic',
    ['goth'] = 'Gothic',
    ['grek'] = 'Greek',
    ['gujr'] = 'Gujarati',
    ['guru'] = 'Gurmukhi',
    ['hang'] = 'Hangul',
    ['hani'] = 'CJK Ideographic',
    ['hano'] = 'Hanunoo',
    ['hebr'] = 'Hebrew',
    ['ital'] = 'Old Italic',
    ['jamo'] = 'Hangul Jamo',
    ['java'] = 'Javanese',
    ['kana'] = 'Hiragana and Katakana',
    ['khar'] = 'Kharosthi',
    ['khmr'] = 'Khmer',
    ['knda'] = 'Kannada',
    ['lao' ] = 'Lao',
    ['latn'] = 'Latin',
    ['limb'] = 'Limbu',
    ['linb'] = 'Linear B',
    ['math'] = 'Mathematical Alphanumeric Symbols',
    ['mlym'] = 'Malayalam',
    ['mong'] = 'Mongolian',
    ['musc'] = 'Musical Symbols',
    ['mymr'] = 'Myanmar',
    ['nko' ] = "N'ko",
    ['ogam'] = 'Ogham',
    ['orya'] = 'Oriya',
    ['osma'] = 'Osmanya',
    ['phag'] = 'Phags-pa',
    ['phnx'] = 'Phoenician',
    ['runr'] = 'Runic',
    ['shaw'] = 'Shavian',
    ['sinh'] = 'Sinhala',
    ['sylo'] = 'Syloti Nagri',
    ['syrc'] = 'Syriac',
    ['tagb'] = 'Tagbanwa',
    ['tale'] = 'Tai Le',
    ['talu'] = 'Tai Lu',
    ['taml'] = 'Tamil',
    ['telu'] = 'Telugu',
    ['tfng'] = 'Tifinagh',
    ['tglg'] = 'Tagalog',
    ['thaa'] = 'Thaana',
    ['thai'] = 'Thai',
    ['tibt'] = 'Tibetan',
    ['ugar'] = 'Ugaritic Cuneiform',
    ['xpeo'] = 'Old Persian Cuneiform',
    ['xsux'] = 'Sumero-Akkadian Cuneiform',
    ['yi'  ] = 'Yi'
}

fonts.otf.tables.languages = {
    ['dflt'] = 'Default',

    ['aba'] = 'Abaza',
    ['abk'] = 'Abkhazian',
    ['ady'] = 'Adyghe',
    ['afk'] = 'Afrikaans',
    ['afr'] = 'Afar',
    ['agw'] = 'Agaw',
    ['als'] = 'Alsatian',
    ['alt'] = 'Altai',
    ['amh'] = 'Amharic',
    ['ara'] = 'Arabic',
    ['ari'] = 'Aari',
    ['ark'] = 'Arakanese',
    ['asm'] = 'Assamese',
    ['ath'] = 'Athapaskan',
    ['avr'] = 'Avar',
    ['awa'] = 'Awadhi',
    ['aym'] = 'Aymara',
    ['aze'] = 'Azeri',
    ['bad'] = 'Badaga',
    ['bag'] = 'Baghelkhandi',
    ['bal'] = 'Balkar',
    ['bau'] = 'Baule',
    ['bbr'] = 'Berber',
    ['bch'] = 'Bench',
    ['bcr'] = 'Bible Cree',
    ['bel'] = 'Belarussian',
    ['bem'] = 'Bemba',
    ['ben'] = 'Bengali',
    ['bgr'] = 'Bulgarian',
    ['bhi'] = 'Bhili',
    ['bho'] = 'Bhojpuri',
    ['bik'] = 'Bikol',
    ['bil'] = 'Bilen',
    ['bkf'] = 'Blackfoot',
    ['bli'] = 'Balochi',
    ['bln'] = 'Balante',
    ['blt'] = 'Balti',
    ['bmb'] = 'Bambara',
    ['bml'] = 'Bamileke',
    ['bos'] = 'Bosnian',
    ['bre'] = 'Breton',
    ['brh'] = 'Brahui',
    ['bri'] = 'Braj Bhasha',
    ['brm'] = 'Burmese',
    ['bsh'] = 'Bashkir',
    ['bti'] = 'Beti',
    ['cat'] = 'Catalan',
    ['ceb'] = 'Cebuano',
    ['che'] = 'Chechen',
    ['chg'] = 'Chaha Gurage',
    ['chh'] = 'Chattisgarhi',
    ['chi'] = 'Chichewa',
    ['chk'] = 'Chukchi',
    ['chp'] = 'Chipewyan',
    ['chr'] = 'Cherokee',
    ['chu'] = 'Chuvash',
    ['cmr'] = 'Comorian',
    ['cop'] = 'Coptic',
    ['cos'] = 'Corsican',
    ['cre'] = 'Cree',
    ['crr'] = 'Carrier',
    ['crt'] = 'Crimean Tatar',
    ['csl'] = 'Church Slavonic',
    ['csy'] = 'Czech',
    ['dan'] = 'Danish',
    ['dar'] = 'Dargwa',
    ['dcr'] = 'Woods Cree',
    ['deu'] = 'German',
    ['dgr'] = 'Dogri',
    ['div'] = 'Divehi',
    ['djr'] = 'Djerma',
    ['dng'] = 'Dangme',
    ['dnk'] = 'Dinka',
    ['dri'] = 'Dari',
    ['dun'] = 'Dungan',
    ['dzn'] = 'Dzongkha',
    ['ebi'] = 'Ebira',
    ['ecr'] = 'Eastern Cree',
    ['edo'] = 'Edo',
    ['efi'] = 'Efik',
    ['ell'] = 'Greek',
    ['eng'] = 'English',
    ['erz'] = 'Erzya',
    ['esp'] = 'Spanish',
    ['eti'] = 'Estonian',
    ['euq'] = 'Basque',
    ['evk'] = 'Evenki',
    ['evn'] = 'Even',
    ['ewe'] = 'Ewe',
    ['fan'] = 'French Antillean',
    ['far'] = 'Farsi',
    ['fin'] = 'Finnish',
    ['fji'] = 'Fijian',
    ['fle'] = 'Flemish',
    ['fne'] = 'Forest Nenets',
    ['fon'] = 'Fon',
    ['fos'] = 'Faroese',
    ['fra'] = 'French',
    ['fri'] = 'Frisian',
    ['frl'] = 'Friulian',
    ['fta'] = 'Futa',
    ['ful'] = 'Fulani',
    ['gad'] = 'Ga',
    ['gae'] = 'Gaelic',
    ['gag'] = 'Gagauz',
    ['gal'] = 'Galician',
    ['gar'] = 'Garshuni',
    ['gaw'] = 'Garhwali',
    ['gez'] = "Ge'ez",
    ['gil'] = 'Gilyak',
    ['gmz'] = 'Gumuz',
    ['gon'] = 'Gondi',
    ['grn'] = 'Greenlandic',
    ['gro'] = 'Garo',
    ['gua'] = 'Guarani',
    ['guj'] = 'Gujarati',
    ['hai'] = 'Haitian',
    ['hal'] = 'Halam',
    ['har'] = 'Harauti',
    ['hau'] = 'Hausa',
    ['haw'] = 'Hawaiin',
    ['hbn'] = 'Hammer-Banna',
    ['hil'] = 'Hiligaynon',
    ['hin'] = 'Hindi',
    ['hma'] = 'High Mari',
    ['hnd'] = 'Hindko',
    ['ho']  = 'Ho',
    ['hri'] = 'Harari',
    ['hrv'] = 'Croatian',
    ['hun'] = 'Hungarian',
    ['hye'] = 'Armenian',
    ['ibo'] = 'Igbo',
    ['ijo'] = 'Ijo',
    ['ilo'] = 'Ilokano',
    ['ind'] = 'Indonesian',
    ['ing'] = 'Ingush',
    ['inu'] = 'Inuktitut',
    ['iri'] = 'Irish',
    ['irt'] = 'Irish Traditional',
    ['isl'] = 'Icelandic',
    ['ism'] = 'Inari Sami',
    ['ita'] = 'Italian',
    ['iwr'] = 'Hebrew',
    ['jan'] = 'Japanese',
    ['jav'] = 'Javanese',
    ['jii'] = 'Yiddish',
    ['jud'] = 'Judezmo',
    ['jul'] = 'Jula',
    ['kab'] = 'Kabardian',
    ['kac'] = 'Kachchi',
    ['kal'] = 'Kalenjin',
    ['kan'] = 'Kannada',
    ['kar'] = 'Karachay',
    ['kat'] = 'Georgian',
    ['kaz'] = 'Kazakh',
    ['keb'] = 'Kebena',
    ['kge'] = 'Khutsuri Georgian',
    ['kha'] = 'Khakass',
    ['khk'] = 'Khanty-Kazim',
    ['khm'] = 'Khmer',
    ['khs'] = 'Khanty-Shurishkar',
    ['khv'] = 'Khanty-Vakhi',
    ['khw'] = 'Khowar',
    ['kik'] = 'Kikuyu',
    ['kir'] = 'Kirghiz',
    ['kis'] = 'Kisii',
    ['kkn'] = 'Kokni',
    ['klm'] = 'Kalmyk',
    ['kmb'] = 'Kamba',
    ['kmn'] = 'Kumaoni',
    ['kmo'] = 'Komo',
    ['kms'] = 'Komso',
    ['knr'] = 'Kanuri',
    ['kod'] = 'Kodagu',
    ['koh'] = 'Korean Old Hangul',
    ['kok'] = 'Konkani',
    ['kon'] = 'Kikongo',
    ['kop'] = 'Komi-Permyak',
    ['kor'] = 'Korean',
    ['koz'] = 'Komi-Zyrian',
    ['kpl'] = 'Kpelle',
    ['kri'] = 'Krio',
    ['krk'] = 'Karakalpak',
    ['krl'] = 'Karelian',
    ['krm'] = 'Karaim',
    ['krn'] = 'Karen',
    ['krt'] = 'Koorete',
    ['ksh'] = 'Kashmiri',
    ['ksi'] = 'Khasi',
    ['ksm'] = 'Kildin Sami',
    ['kui'] = 'Kui',
    ['kul'] = 'Kulvi',
    ['kum'] = 'Kumyk',
    ['kur'] = 'Kurdish',
    ['kuu'] = 'Kurukh',
    ['kuy'] = 'Kuy',
    ['kyk'] = 'Koryak',
    ['lad'] = 'Ladin',
    ['lah'] = 'Lahuli',
    ['lak'] = 'Lak',
    ['lam'] = 'Lambani',
    ['lao'] = 'Lao',
    ['lat'] = 'Latin',
    ['laz'] = 'Laz',
    ['lcr'] = 'L-Cree',
    ['ldk'] = 'Ladakhi',
    ['lez'] = 'Lezgi',
    ['lin'] = 'Lingala',
    ['lma'] = 'Low Mari',
    ['lmb'] = 'Limbu',
    ['lmw'] = 'Lomwe',
    ['lsb'] = 'Lower Sorbian',
    ['lsm'] = 'Lule Sami',
    ['lth'] = 'Lithuanian',
    ['ltz'] = 'Luxembourgish',
    ['lub'] = 'Luba',
    ['lug'] = 'Luganda',
    ['luh'] = 'Luhya',
    ['luo'] = 'Luo',
    ['lvi'] = 'Latvian',
    ['maj'] = 'Majang',
    ['mak'] = 'Makua',
    ['mal'] = 'Malayalam Traditional',
    ['man'] = 'Mansi',
    ['map'] = 'Mapudungun',
    ['mar'] = 'Marathi',
    ['maw'] = 'Marwari',
    ['mbn'] = 'Mbundu',
    ['mch'] = 'Manchu',
    ['mcr'] = 'Moose Cree',
    ['mde'] = 'Mende',
    ['men'] = "Me'en",
    ['miz'] = 'Mizo',
    ['mkd'] = 'Macedonian',
    ['mle'] = 'Male',
    ['mlg'] = 'Malagasy',
    ['mln'] = 'Malinke',
    ['mlr'] = 'Malayalam Reformed',
    ['mly'] = 'Malay',
    ['mnd'] = 'Mandinka',
    ['mng'] = 'Mongolian',
    ['mni'] = 'Manipuri',
    ['mnk'] = 'Maninka',
    ['mnx'] = 'Manx Gaelic',
    ['moh'] = 'Mohawk',
    ['mok'] = 'Moksha',
    ['mol'] = 'Moldavian',
    ['mon'] = 'Mon',
    ['mor'] = 'Moroccan',
    ['mri'] = 'Maori',
    ['mth'] = 'Maithili',
    ['mts'] = 'Maltese',
    ['mun'] = 'Mundari',
    ['nag'] = 'Naga-Assamese',
    ['nan'] = 'Nanai',
    ['nas'] = 'Naskapi',
    ['ncr'] = 'N-Cree',
    ['ndb'] = 'Ndebele',
    ['ndg'] = 'Ndonga',
    ['nep'] = 'Nepali',
    ['new'] = 'Newari',
    ['ngr'] = 'Nagari',
    ['nhc'] = 'Norway House Cree',
    ['nis'] = 'Nisi',
    ['niu'] = 'Niuean',
    ['nkl'] = 'Nkole',
    ['nko'] = "N'ko",
    ['nld'] = 'Dutch',
    ['nog'] = 'Nogai',
    ['nor'] = 'Norwegian',
    ['nsm'] = 'Northern Sami',
    ['nta'] = 'Northern Tai',
    ['nto'] = 'Esperanto',
    ['nyn'] = 'Nynorsk',
    ['oci'] = 'Occitan',
    ['ocr'] = 'Oji-Cree',
    ['ojb'] = 'Ojibway',
    ['ori'] = 'Oriya',
    ['oro'] = 'Oromo',
    ['oss'] = 'Ossetian',
    ['paa'] = 'Palestinian Aramaic',
    ['pal'] = 'Pali',
    ['pan'] = 'Punjabi',
    ['pap'] = 'Palpa',
    ['pas'] = 'Pashto',
    ['pgr'] = 'Polytonic Greek',
    ['pil'] = 'Pilipino',
    ['plg'] = 'Palaung',
    ['plk'] = 'Polish',
    ['pro'] = 'Provencal',
    ['ptg'] = 'Portuguese',
    ['qin'] = 'Chin',
    ['raj'] = 'Rajasthani',
    ['rbu'] = 'Russian Buriat',
    ['rcr'] = 'R-Cree',
    ['ria'] = 'Riang',
    ['rms'] = 'Rhaeto-Romanic',
    ['rom'] = 'Romanian',
    ['roy'] = 'Romany',
    ['rsy'] = 'Rusyn',
    ['rua'] = 'Ruanda',
    ['rus'] = 'Russian',
    ['sad'] = 'Sadri',
    ['san'] = 'Sanskrit',
    ['sat'] = 'Santali',
    ['say'] = 'Sayisi',
    ['sek'] = 'Sekota',
    ['sel'] = 'Selkup',
    ['sgo'] = 'Sango',
    ['shn'] = 'Shan',
    ['sib'] = 'Sibe',
    ['sid'] = 'Sidamo',
    ['sig'] = 'Silte Gurage',
    ['sks'] = 'Skolt Sami',
    ['sky'] = 'Slovak',
    ['sla'] = 'Slavey',
    ['slv'] = 'Slovenian',
    ['sml'] = 'Somali',
    ['smo'] = 'Samoan',
    ['sna'] = 'Sena',
    ['snd'] = 'Sindhi',
    ['snh'] = 'Sinhalese',
    ['snk'] = 'Soninke',
    ['sog'] = 'Sodo Gurage',
    ['sot'] = 'Sotho',
    ['sqi'] = 'Albanian',
    ['srb'] = 'Serbian',
    ['srk'] = 'Saraiki',
    ['srr'] = 'Serer',
    ['ssl'] = 'South Slavey',
    ['ssm'] = 'Southern Sami',
    ['sur'] = 'Suri',
    ['sva'] = 'Svan',
    ['sve'] = 'Swedish',
    ['swa'] = 'Swadaya Aramaic',
    ['swk'] = 'Swahili',
    ['swz'] = 'Swazi',
    ['sxt'] = 'Sutu',
    ['syr'] = 'Syriac',
    ['tab'] = 'Tabasaran',
    ['taj'] = 'Tajiki',
    ['tam'] = 'Tamil',
    ['tat'] = 'Tatar',
    ['tcr'] = 'TH-Cree',
    ['tel'] = 'Telugu',
    ['tgn'] = 'Tongan',
    ['tgr'] = 'Tigre',
    ['tgy'] = 'Tigrinya',
    ['tha'] = 'Thai',
    ['tht'] = 'Tahitian',
    ['tib'] = 'Tibetan',
    ['tkm'] = 'Turkmen',
    ['tmn'] = 'Temne',
    ['tna'] = 'Tswana',
    ['tne'] = 'Tundra Nenets',
    ['tng'] = 'Tonga',
    ['tod'] = 'Todo',
    ['trk'] = 'Turkish',
    ['tsg'] = 'Tsonga',
    ['tua'] = 'Turoyo Aramaic',
    ['tul'] = 'Tulu',
    ['tuv'] = 'Tuvin',
    ['twi'] = 'Twi',
    ['udm'] = 'Udmurt',
    ['ukr'] = 'Ukrainian',
    ['urd'] = 'Urdu',
    ['usb'] = 'Upper Sorbian',
    ['uyg'] = 'Uyghur',
    ['uzb'] = 'Uzbek',
    ['ven'] = 'Venda',
    ['vit'] = 'Vietnamese',
    ['wa' ] = 'Wa',
    ['wag'] = 'Wagdi',
    ['wcr'] = 'West-Cree',
    ['wel'] = 'Welsh',
    ['wlf'] = 'Wolof',
    ['xbd'] = 'Tai Lue',
    ['xhs'] = 'Xhosa',
    ['yak'] = 'Yakut',
    ['yba'] = 'Yoruba',
    ['ycr'] = 'Y-Cree',
    ['yic'] = 'Yi Classic',
    ['yim'] = 'Yi Modern',
    ['zhh'] = 'Chinese Hong Kong',
    ['zhp'] = 'Chinese Phonetic',
    ['zhs'] = 'Chinese Simplified',
    ['zht'] = 'Chinese Traditional',
    ['znd'] = 'Zande',
    ['zul'] = 'Zulu'
}

fonts.otf.tables.features = {
    ['aalt'] = 'Access All Alternates',
    ['abvf'] = 'Above-Base Forms',
    ['abvm'] = 'Above-Base Mark Positioning',
    ['abvs'] = 'Above-Base Substitutions',
    ['afrc'] = 'Alternative Fractions',
    ['akhn'] = 'Akhands',
    ['blwf'] = 'Below-Base Forms',
    ['blwm'] = 'Below-Base Mark Positioning',
    ['blws'] = 'Below-Base Substitutions',
    ['c2pc'] = 'Petite Capitals From Capitals',
    ['c2sc'] = 'Small Capitals From Capitals',
    ['calt'] = 'Contextual Alternates',
    ['case'] = 'Case-Sensitive Forms',
    ['ccmp'] = 'Glyph Composition/Decomposition',
    ['cjct'] = 'Conjunct Forms',
    ['clig'] = 'Contextual Ligatures',
    ['cpsp'] = 'Capital Spacing',
    ['cswh'] = 'Contextual Swash',
    ['curs'] = 'Cursive Positioning',
    ['dflt'] = 'Default Processing',
    ['dist'] = 'Distances',
    ['dlig'] = 'Discretionary Ligatures',
    ['dnom'] = 'Denominators',
    ['expt'] = 'Expert Forms',
    ['falt'] = 'Final glyph Alternates',
    ['fin2'] = 'Terminal Forms #2',
    ['fin3'] = 'Terminal Forms #3',
    ['fina'] = 'Terminal Forms',
    ['frac'] = 'Fractions',
    ['fwid'] = 'Full Width',
    ['half'] = 'Half Forms',
    ['haln'] = 'Halant Forms',
    ['halt'] = 'Alternate Half Width',
    ['hist'] = 'Historical Forms',
    ['hkna'] = 'Horizontal Kana Alternates',
    ['hlig'] = 'Historical Ligatures',
    ['hngl'] = 'Hangul',
    ['hojo'] = 'Hojo Kanji Forms',
    ['hwid'] = 'Half Width',
    ['init'] = 'Initial Forms',
    ['isol'] = 'Isolated Forms',
    ['ital'] = 'Italics',
    ['jalt'] = 'Justification Alternatives',
    ['jp04'] = 'JIS2004 Forms',
    ['jp78'] = 'JIS78 Forms',
    ['jp83'] = 'JIS83 Forms',
    ['jp90'] = 'JIS90 Forms',
    ['kern'] = 'Kerning',
    ['lfbd'] = 'Left Bounds',
    ['liga'] = 'Standard Ligatures',
    ['ljmo'] = 'Leading Jamo Forms',
    ['lnum'] = 'Lining Figures',
    ['locl'] = 'Localized Forms',
    ['mark'] = 'Mark Positioning',
    ['med2'] = 'Medial Forms #2',
    ['medi'] = 'Medial Forms',
    ['mgrk'] = 'Mathematical Greek',
    ['mkmk'] = 'Mark to Mark Positioning',
    ['mset'] = 'Mark Positioning via Substitution',
    ['nalt'] = 'Alternate Annotation Forms',
    ['nlck'] = 'NLC Kanji Forms',
    ['nukt'] = 'Nukta Forms',
    ['numr'] = 'Numerators',
    ['onum'] = 'Old Style Figures',
    ['opbd'] = 'Optical Bounds',
    ['ordn'] = 'Ordinals',
    ['ornm'] = 'Ornaments',
    ['palt'] = 'Proportional Alternate Width',
    ['pcap'] = 'Petite Capitals',
    ['pnum'] = 'Proportional Figures',
    ['pref'] = 'Pre-base Forms',
    ['pres'] = 'Pre-base Substitutions',
    ['pstf'] = 'Post-base Forms',
    ['psts'] = 'Post-base Substitutions',
    ['pwid'] = 'Proportional Widths',
    ['qwid'] = 'Quarter Widths',
    ['rand'] = 'Randomize',
    ['rkrf'] = 'Rakar Forms',
    ['rlig'] = 'Required Ligatures',
    ['rphf'] = 'Reph Form',
    ['rtbd'] = 'Right Bounds',
    ['rtla'] = 'Right-To-Left Alternates',
    ['ruby'] = 'Ruby Notation Forms',
    ['salt'] = 'Stylistic Alternates',
    ['sinf'] = 'Scientific Inferiors',
    ['size'] = 'Optical Size',
    ['smcp'] = 'Small Capitals',
    ['smpl'] = 'Simplified Forms',
    ['ss01'] = 'Sylistic Set 1',
    ['ss02'] = 'Sylistic Set 2',
    ['ss03'] = 'Sylistic Set 3',
    ['ss04'] = 'Sylistic Set 4',
    ['ss05'] = 'Sylistic Set 5',
    ['ss06'] = 'Sylistic Set 6',
    ['ss07'] = 'Sylistic Set 7',
    ['ss08'] = 'Sylistic Set 8',
    ['ss09'] = 'Sylistic Set 9',
    ['ss10'] = 'Sylistic Set 10',
    ['ss11'] = 'Sylistic Set 11',
    ['ss12'] = 'Sylistic Set 12',
    ['ss13'] = 'Sylistic Set 13',
    ['ss14'] = 'Sylistic Set 14',
    ['ss15'] = 'Sylistic Set 15',
    ['ss16'] = 'Sylistic Set 16',
    ['ss17'] = 'Sylistic Set 17',
    ['ss18'] = 'Sylistic Set 18',
    ['ss19'] = 'Sylistic Set 19',
    ['ss20'] = 'Sylistic Set 20',
    ['subs'] = 'Subscript',
    ['sups'] = 'Superscript',
    ['swsh'] = 'Swash',
    ['titl'] = 'Titling',
    ['tjmo'] = 'Trailing Jamo Forms',
    ['tnam'] = 'Traditional Name Forms',
    ['tnum'] = 'Tabular Figures',
    ['trad'] = 'Traditional Forms',
    ['twid'] = 'Third Widths',
    ['unic'] = 'Unicase',
    ['valt'] = 'Alternate Vertical Metrics',
    ['vatu'] = 'Vattu Variants',
    ['vert'] = 'Vertical Writing',
    ['vhal'] = 'Alternate Vertical Half Metrics',
    ['vjmo'] = 'Vowel Jamo Forms',
    ['vkna'] = 'Vertical Kana Alternates',
    ['vkrn'] = 'Vertical Kerning',
    ['vpal'] = 'Proportional Alternate Vertical Metrics',
    ['vrt2'] = 'Vertical Rotation',
    ['zero'] = 'Slashed Zero'
}

fonts.otf.tables.baselines = {
    ['hang'] = 'Hanging baseline',
    ['icfb'] = 'Ideographic character face bottom edge baseline',
    ['icft'] = 'Ideographic character face tope edige baseline',
    ['ideo'] = 'Ideographic em-box bottom edge baseline',
    ['idtp'] = 'Ideographic em-box top edge baseline',
    ['math'] = 'Mathmatical centered baseline',
    ['romn'] = 'Roman baseline'
}

function fonts.otf.tables.to_tag(id)
    return stringformat("%4s",id:lower())
end

function fonts.otf.meanings.resolve(tab,id)
    if tab and id then
        id = id:lower()
        return tab[id] or tab[id:gsub(" ","")] or tab['dflt'] or ''
    else
        return "unknown"
    end
end

function fonts.otf.meanings.script(id)
    return fonts.otf.meanings.resolve(fonts.otf.tables.scripts,id)
end
function fonts.otf.meanings.language(id)
    return fonts.otf.meanings.resolve(fonts.otf.tables.languages,id)
end
function fonts.otf.meanings.feature(id)
    return fonts.otf.meanings.resolve(fonts.otf.tables.features,id)
end
function fonts.otf.meanings.baseline(id)
    return fonts.otf.meanings.resolve(fonts.otf.tables.baselines,id)
end

--[[ldx--
<p>Here we go.</p>
--ldx]]--

fonts.otf.enhance           = fonts.otf.enhance or { }
fonts.otf.enhance.add_kerns = true

function fonts.otf.load(filename,format,sub,featurefile)
    local name = file.basename(file.removesuffix(filename))
    if featurefile then
        name = name .. "@" .. file.removesuffix(file.basename(featurefile))
    end
    if sub == "" then sub = false end
    local hash = name
    if sub then -- name cleanup will move to cache code
        hash = hash .. "-" .. sub
        hash = hash:lower()
        hash = hash:gsub("[^%w%d]+","-")
    end
    local data = containers.read(fonts.otf.cache, hash)
    if not data then
        local ff, messages
        if sub then
            ff, messages = fontforge.open(filename,sub)
        else
            ff, messages = fontforge.open(filename)
        end
        if messages and #messages > 0 then
            for _, m in ipairs(messages) do
                logs.report("load otf","warning: " .. m)
            end
        end
        if ff then
            logs.report("load otf","loading: " .. filename)
            if featurefile then
                featurefile = input.find_file(texmf.instance,file.addsuffix(featurefile,'fea'),"FONTFEATURES")
                if featurefile and featurefile ~= "" then
                    logs.report("load otf", "featurefile: " .. featurefile)
                    fontforge.apply_featurefile(ff, featurefile)
                end
            end
            data = fontforge.to_table(ff)
            fontforge.close(ff)
            if data then
                logs.report("load otf","enhance: before")
                fonts.otf.enhance.before(data,filename)
                logs.report("load otf","enhance: analyze")
                fonts.otf.enhance.analyze(data,filename)
                logs.report("load otf","enhance: after")
                fonts.otf.enhance.after(data,filename)
                logs.report("load otf","enhance: patch")
                fonts.otf.enhance.patch(data,filename)
                logs.report("load otf","saving: in cache")
                data = containers.write(fonts.otf.cache, hash, data)
            else
                logs.error("load otf","loading failed")
            end
        end
    end
    if data then
        local map      = data.map.map
        local backmap  = data.map.backmap
        local unicodes = data.luatex.unicodes
        local glyphs   = data.glyphs
        -- maybe handy some day, not used
        data.name_to_unicode  = function (n) return unicodes[n] end
        data.name_to_index    = function (n) return map[unicodes[n]] end
        data.index_to_name    = function (i) return glyphs[i].name end
        data.unicode_to_name  = function (u) return glyphs[map[u]].name end
        data.index_to_unicode = function (u) return backmap[u] end
        data.unicode_to_index = function (u) return map[u] end
    end
    return data
end

-- todo: normalize, design_size => designsize

function fonts.otf.enhance.analyze(data,filename)
    local t = {
        filename = file.basename(filename),
        version  = fonts.otf.version,
        creator  = "context mkiv",
        unicodes = fonts.otf.analyze_unicodes(data),
        gposfeatures = fonts.otf.analyze_features(data.gpos),
        gsubfeatures = fonts.otf.analyze_features(data.gsub),
        marks = fonts.otf.analyze_class(data,'mark'),
    }
    t.subtables, t.name_to_type, t.internals, t.always_valid, t.ignore_flags = fonts.otf.analyze_subtables(data)
    data.luatex = t
end

function fonts.otf.load_cidmap(filename)
    local data = io.loaddata(filename)
    if data then
        local unicodes, names = { }, {}
        data = data:gsub("^(%d+)%s+(%d+)\n","")
        for a,b in data:gmatch("(%d+)%s+([%d%a]+)\n") do
            unicodes[tonumber(a)] = tonumber(b,16)
        end
        for a,b,c in data:gmatch("(%d+)%.%.(%d+)%s+([%d%a]+)%s*\n") do
            c = tonumber(c,16)
            for i=tonumber(a),tonumber(b) do
                unicodes[i] = c
                c = c + 1
            end
        end
        for a,b in data:gmatch("(%d+)%s+\/(%S+)%s*\n") do
            names[tonumber(a)] = b
        end
        local supplement, registry, ordering = filename:match("^(.-)%-(.-)%-()%.(.-)$")
        return {
            supplement = supplement,
            registry   = registry,
            ordering   = ordering,
            filename   = filename,
            unicodes   = unicodes,
            names      = names
        }
    else
        return nil
    end
end

fonts.otf.cidmaps = { }

function fonts.otf.cidmap(registry,ordering,supplement)
    local template = "%s-%s-%s.cidmap"
    local filename = string.format(template,registry,ordering,supplement)
    local supplement = tonumber(supplement)
    if not fonts.otf.cidmaps[filename] then
        for i=supplement,0,-1 do
            logs.report("load otf",string.format("checking cidmap, registry: %s, ordering: %s, supplement: %s",registry,ordering,i))
            filename = string.format(template,registry,ordering,i)
            local fullname = input.find_file(texmf.instance,filename,'cid') or ""
            if fullname ~= "" then
                local cidmap = fonts.otf.load_cidmap(fullname)
                if cidmap then
                    logs.report("load otf",string.format("using cidmap file %s",filename))
                    fonts.otf.cidmaps[filename] = cidmap
                    if i < supplement then
                        for j=i+1,supplement do
                            filename = string.format(template,registry,ordering,j)
                            fonts.otf.cidmaps[filename] = cidmap -- copy of ref
                        end
                    end
                    return cidmap
                end
            end
        end
    end
    return nil
end

--~  ["cidinfo"]={
--~   ["ordering"]="Japan1",
--~   ["registry"]="Adobe",
--~   ["supplement"]=6,
--~   ["version"]=6,
--~  },

function fonts.otf.enhance.before(data,filename)
    local private = 0xE000
    if data.subfonts and table.is_empty(data.glyphs) then
        local cidinfo = data.cidinfo
        if cidinfo.registry then
            local cidmap = fonts.otf.cidmap(cidinfo.registry,cidinfo.ordering,cidinfo.supplement)
            if cidmap then
                local glyphs, uni_to_int, int_to_uni, nofnames, nofunicodes, zerobox = { }, { }, { }, 0, 0, { 0, 0, 0, 0 }
                local unicodes, names = cidmap.unicodes, cidmap.names
                for n, subfont in pairs(data.subfonts) do
                    for index, g in pairs(subfont.glyphs) do
                        if not next(g) then
                            -- dummy entry
                        else
                            local unicode, name = unicodes[index], names[index]
                            g.cidindex = n
                            g.boundingbox = g.boundingbox or zerobox
                            g.name = g.name or name or "unknown"
                            if unicode then
                                g.unicodeenc = unicode
                                uni_to_int[unicode] = index
                                int_to_uni[index] = unicode
                                nofunicodes = nofunicodes + 1
                            elseif name then
                                g.unicodeenc = -1
                                nofnames = nofnames + 1
                            end
                            glyphs[index] = g
                        end
                    end
                    subfont.glyphs = nil
                end
                logs.report("load otf",string.format("cid font remapped, %s unicode points, %s symbolic names, %s glyphs",nofunicodes, nofnames, nofunicodes+nofnames))
                data.glyphs = glyphs
                data.map = data.map or { }
                data.map.map = uni_to_int
                data.map.backmap = int_to_uni
            else
                logs.report("load otf",string.format("unable to remap cid font, missing cid file for %s",filename))
            end
        else
            logs.report("load otf",string.format("font %s has no glyphs",filename))
        end
    end
    if data.map then
        local uni_to_int = data.map.map
        local int_to_uni = data.map.backmap
        for index, glyph in pairs(data.glyphs) do
            if glyph.name then
                local unic = glyph.unicodeenc or -1
                if index > 0 and (unic == -1 or unic >= 0x110000) then
                    while uni_to_int[private] do
                        private = private + 1
                    end
                    uni_to_int[private] = index
                    int_to_uni[index] = private
                    glyph.unicodeenc = private
                    if fonts.trace then
                        logs.report("load otf",string.format("enhance: glyph %s at index %s is moved to private unicode slot %s",glyph.name,index,private))
                    end
                end
            end
        end
        local n = 0
        for k,v in pairs(int_to_uni) do
            if v == -1 or v >= 0x110000 then
                int_to_uni[k], n = nil, n+1
            end
        end
        if fonts.trace then
            logs.report("load otf",string.format("enhance: %s entries removed from map.backmap",n))
        end
        local n = 0
        for k,v in pairs(uni_to_int) do
            if k == -1 or k >= 0x110000 then
                uni_to_int[k], n = nil, n+1
            end
        end
        if fonts.trace then
            logs.report("load otf",string.format("enhance: %s entries removed from map.mapmap",n))
        end
    else
        data.map = { map = {}, backmap = {} }
    end
    if data.ttf_tables then
        for _, v in ipairs(data.ttf_tables) do
            if v.data then v.data = "deleted" end
        --~ if v.data then v.data = v.data:gsub("\026","\\026") end -- does not work out well
        end
    end
    table.compact(data.glyphs)
    if data.subfonts then
        for _, subfont in pairs(data.subfonts) do
            table.compact(subfont.glyphs)
        end
    end
end

function fonts.otf.enhance.after(data,filename) -- to be split
    if fonts.otf.enhance.add_kerns then
        local glyphs, mapmap, unicodes = data.glyphs, data.map.map, data.luatex.unicodes
        for index, glyph in pairs(data.glyphs) do
            if glyph.kerns then
                local mykerns = { } -- unicode indexed !
                for k,v in pairs(glyph.kerns) do
                    local vc, vo, vl = v.char, v.off, v.lookup
                    if vc and vo and vl then -- brrr, wrong! we miss the non unicode ones
                        local uvc = unicodes[vc]
                        if uvc then
                            local mkl = mykerns[vl]
                            if not mkl then
                                mkl = { [unicodes[vc]] = vo }
                                mykerns[v.lookup] = mkl
                            else
                                mkl[unicodes[vc]] = vo
                            end
                        else
                            logs.report("load otf", string.format("problems with unicode %s of kern %s at glyph %s",vc,k,index))
                        end
                    end
                end
                glyph.mykerns = mykerns
            end
        end
        if data.gpos then
            for _, gpos in ipairs(data.gpos) do
                if gpos.subtables then
                    for _, subtable in ipairs(gpos.subtables) do
                        local kernclass = subtable.kernclass
                        if kernclass then
                            for _, kcl in ipairs(kernclass) do
                                local firsts, seconds, offsets, lookup = kcl.firsts, kcl.seconds, kcl.offsets, kcl.lookup
                                local maxfirsts, maxseconds = table.getn(firsts), table.getn(seconds)
                                logs.report("load otf", string.format("adding kernclass %s with %s times %s pairs)",lookup, maxfirsts, maxseconds))
                                for fk, fv in pairs(firsts) do
                                    for first in fv:gmatch("(%S+)") do
                                        local glyph = glyphs[mapmap[unicodes[first]]]
                                        local mykerns = glyph.mykerns
                                        if not mykerns then
                                            mykerns = { } -- unicode indexed !
                                            glyph.mykerns = mykerns
                                        end
                                        local lookupkerns = mykerns[lookup]
                                        if not lookupkerns then
                                            lookupkerns = { }
                                            mykerns[lookup] = lookupkerns
                                        end
                                        for sk, sv in pairs(seconds) do
                                            for second in sv:gmatch("(%S+)") do
                                                lookupkerns[unicodes[second]] = offsets[(fk-1) * maxseconds + sk]
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        subtable.comment = "The kernclass table is merged into mykerns in the indexed glyph tables."
                        subtable.kernclass = { }
                    end
                end
            end
        end
    end
    if data.map then
        data.map.enc = nil -- not needed
    end
    data.luatex.comment = "Glyph tables have their original index. When present, mykern tables are indexed by unicode."
end

fonts.otf.enhance.patches = { }

function fonts.otf.enhance.patch(data,filename)
    local basename = file.basename(filename)
    for pattern, action in pairs(fonts.otf.enhance.patches) do
        if basename:find(pattern) then
            action(data,filename)
        end
    end
end

do -- will move to a typescript

    local function patch(data,filename)
        if data.design_size == 0 then
            local ds = (file.basename(filename)):match("(%d+)")
            if ds then
                logs.report("load otf",string.format("patching design size (%s)",ds))
                data.design_size = tonumber(ds) * 10
            end
        end
    end

    fonts.otf.enhance.patches["^lmroman"]      = patch
    fonts.otf.enhance.patches["^lmsans"]       = patch
    fonts.otf.enhance.patches["^lmtypewriter"] = patch

end

function fonts.otf.analyze_class(data,class)
    local classes = { }
    for index, glyph in pairs(data.glyphs) do
        if glyph.class == class then
            classes[glyph.unicodeenc] = true
        end
    end
    return classes
end

function fonts.otf.analyze_subtables(data)
    local subtables, name_to_type, internals, always_valid, ignore_flags = { }, { }, { }, { }, { }
    local function collect(g)
        if g then
            for k,v in ipairs(g) do
                if v.features then
                    local ignored = { false, false, false }
                    if v.flags.ignorecombiningmarks then ignored[1] = 'mark'    end
                    if v.flags.ignorebasechars      then ignored[2] = 'base'     end
                    if v.flags.ignoreligatures      then ignored[3] = 'ligature' end
                    if v.subtables then
                        local type = v.type
                        for _, feature in ipairs(v.features) do
                            local ft = feature.tag:lower()
                            subtables[ft] = subtables[ft] or { }
                            for _, script in ipairs(feature.scripts) do
                                local ss = script.script
                                ss = ss:lower()
                                ss = ss:strip()
                                sft = subtables[ft]
                                sft[ss] = sft[ss] or { }
                                local sfts = sft[ss]
                                for _, language in ipairs(script.langs) do
                                    language = language:lower()
                                    language = language:strip()
                                    sfts[language] = sfts[language] or { }
                                    local sftsl = sfts[language]
                                    local lookups, valid = sftsl.lookups or { }, sftsl.valid or { }
                                    for n, subtable in ipairs(v.subtables) do
                                        local stl = subtable.name
                                        if stl then
                                            lookups[#lookups+1] = stl
                                            valid[stl] = true
                                            name_to_type[stl] = type
                                            ignore_flags[stl] = ignored
                                        end
                                    end
                                    sftsl.lookups, sftsl.valid = lookups, valid
                                end
                            end
                        end
                    end
                else
                    -- we have an internal feature, say ss_l_83 that resolves to
                    -- subfeatures like ss_l_83_s which we find in the glyphs
                    name_to_type[v.name] = v.type
                    local lookups, valid = { }, { }
                    for n, subtable in ipairs(v.subtables) do
                        local stl = subtable.name
                        if stl then
                            lookups[#lookups+1] = stl
                            valid[stl] = true
                        --  name_to_type[stl] = type
                            always_valid[stl] = true
                        end
                    end
                    internals[v.name] = {
                        lookups = lookups,
                        valid = valid
                    }
                    always_valid[v.name] = true -- bonus
                end
            end
        end
    end
    collect(data.gsub)
    collect(data.gpos)
    return subtables, name_to_type, internals, always_valid, ignore_flags
end

function fonts.otf.analyze_unicodes(data)
    local unicodes = { }
    for _, blob in pairs(data.glyphs) do
        if blob.name then
            unicodes[blob.name] = blob.unicodeenc or 0
        end
    end
    unicodes['space'] = unicodes['space'] or 32 -- handly later on
    return unicodes
end

function fonts.otf.analyze_features(g)
    if g then
        local t, done = { }, { }
        for k,v in ipairs(g) do
            local f = v.features
            if f then
                for k, v in ipairs(f) do
                    -- scripts and tag
                    local tag = v.tag
                    if not done[tag] then
                        t[#t+1] = tag
                        done[tag] = true
                    end
                end
            end
        end
        if #t > 0 then
            return t
        end
    end
    return nil
end

function fonts.otf.valid_subtable(otfdata,language,script,kind)
    local t = otfdata.luatex.subtables
    return t[kind] and t[kind][script] and t[kind][script][language] and t[kind][script][language].lookups
end

function fonts.otf.features.register(name,default)
    fonts.otf.features.list[#fonts.otf.features.list+1] = name
    fonts.otf.features.default[name] = default
end

function fonts.otf.set_features(tfmdata)
    local shared = tfmdata.shared
    local otfdata = shared.otfdata
    shared.features = fonts.define.check(shared.features,fonts.otf.features.default)
    local features = shared.features
tfmdata.language = tfmdata.language or 'dflt'
tfmdata.script = tfmdata.script or 'dflt'
    if not table.is_empty(features) then
        local gposlist = otfdata.luatex.gposfeatures
        local gsublist = otfdata.luatex.gsubfeatures
        local mode = tfmdata.mode or fonts.mode
        local fi = fonts.initializers[mode]
        if fi and fi.otf then
            local function initialize(list) -- using tex lig and kerning
                if list then
                    for _, f in ipairs(list) do
                        local value = features[f]
                        if value and fi.otf[f] then -- brr
                            if fonts.otf.trace_features then
                                logs.report("define otf",string.format("initializing feature %s to %s for mode %s for font %s",f,tostring(value),mode or 'unknown', tfmdata.fullname or 'unknown'))
                            end
                            fi.otf[f](tfmdata,value) -- can set mode (no need to pass otf)
                            mode = tfmdata.mode or fonts.mode
                            fi = fonts.initializers[mode]
                        end
                    end
                end
            end
            initialize(fonts.triggers)
            initialize(gsublist)
            initialize(gposlist)
        end
        local fm = fonts.methods[mode]
        if fm and fm.otf then
            local function register(list) -- node manipulations
                if list then
                    for _, f in ipairs(list) do
                        if features[f] and fm.otf[f] then -- brr
                            if fonts.otf.trace_features then
                                logs.report("define otf",string.format("installing feature handler %s for mode %s for font %s",f,mode or 'unknown', tfmdata.fullname or 'unknown'))
                            end
                            if not shared.processors then -- maybe also predefine
                                shared.processors = { fm.otf[f] }
                            else
                                shared.processors[#shared.processors+1] = fm.otf[f]
                            end
                        end
                    end
                end
            end
            register(fonts.triggers)
            register(gsublist)
            register(gposlist)
        end
    end
end

function fonts.otf.otf_to_tfm(specification)
    local name     = specification.name
    local sub      = specification.sub
    local filename = specification.filename
    local format   = specification.format
    local features = specification.features.normal
    local cache_id = specification.hash
    local tfmdata  = containers.read(fonts.tfm.cache,cache_id)
    if not tfmdata then
        local otfdata = fonts.otf.load(filename,format,sub,features and features.featurefile)
        if not table.is_empty(otfdata) then
            tfmdata = fonts.otf.copy_to_tfm(otfdata)
            if not table.is_empty(tfmdata) then
                tfmdata.shared = tfmdata.shared or { }
                tfmdata.unique = tfmdata.unique or { }
                tfmdata.shared.otfdata = otfdata
                tfmdata.shared.features = features
                fonts.otf.set_features(tfmdata)
            end
        end
        containers.write(fonts.tfm.cache,cache_id,tfmdata)
    end
    return tfmdata
end

function fonts.otf.features.prepare_base_kerns(tfmdata,kind,value) -- todo what kind of kerns, currently all
    if value then
        local otfdata = tfmdata.shared.otfdata
        local charlist = otfdata.glyphs
        local unicodes = otfdata.luatex.unicodes
        local somevalid = fonts.otf.some_valid_feature(otfdata,tfmdata.language,tfmdata.script,kind)
        for _, chr in pairs(tfmdata.characters) do
            local d = charlist[chr.index]
            if d and d.kerns then
                local t, done = chr.kerns or { }, false
                for _, v in pairs(d.kerns) do
                    if somevalid[v.lookup] then
                        local k = unicodes[v.char]
                        if k > 0 then
                            t[k], done = v.off, true
                        end
                    end
                end
                if done then
                    chr.kerns = t
                end
            end
        end
    end
end

function fonts.otf.copy_to_tfm(data)
    if data then
        local tfm = { characters = { }, parameters = { } }
        local unicodes = data.luatex.unicodes
        local characters = tfm.characters
        local force = fonts.otf.notdef
        for k,v in pairs(data.map.map) do
            -- k = unicode, v = slot
            local d = data.glyphs[v]
            if d and (force or d.name) then
                local t = {
                    index       =   v,
                    unicode     =   k,
                    name        =   d.name           or ".notdef",
                    boundingbox =   d.boundingbox    or nil,
                    width       =   d.width          or 0,
                    height      =   d.boundingbox[4] or 0,
                    depth       = - d.boundingbox[2] or 0,
                    class       =   d.class,
                }
                if d.class == "mark" then
                    t.width = - t.width
                end
                characters[k] =   t
            end
        end
        local designsize = data.designsize or data.design_size or 100
        if designsize == 0 then
            designsize = 100
        end
        local spaceunits = 500
        tfm.units              = data.units_per_em or 1000
        -- we need a runtime lookup because of running from cdrom or zip, brrr
        tfm.filename           = input.findbinfile(texmf.instance,data.luatex.filename,"") or data.luatex.filename
        tfm.fullname           = data.fullname or data.fontname
        tfm.encodingbytes      = 2
        tfm.cidinfo            = data.cidinfo
        tfm.cidinfo.registry   = tfm.cidinfo.registry or ""
        tfm.type               = "real"
        tfm.stretch            = 0 -- stretch
        tfm.slant              = 0 -- slant
        tfm.direction          = 0
        tfm.boundarychar_label = 0
        tfm.boundarychar       = 65536
        tfm.designsize         = (designsize/10)*65536
        tfm.spacer             = "500 units"
        data.isfixedpitch      = data.pfminfo and data.pfminfo.panose and data.pfminfo.panose["proportion"] == "Monospaced"
        data.charwidth         = nil
        if data.pfminfo then
            data.charwidth = data.pfminfo.avgwidth
        end
        local endash, emdash = unicodes['space'], unicodes['emdash']
        if data.isfixedpitch then
            if characters[endash] then
                spaceunits, tfm.spacer = characters[endash].width, "space"
            end
            if not spaceunits and characters[emdash] then
                spaceunits, tfm.spacer = characters[emdash].width, "emdash"
            end
            if not spaceunits and data.charwidth then
                spaceunits, tfm.spacer = data.charwidth, "charwidth"
            end
        else
            if characters[endash] then
                spaceunits, tfm.spacer = characters[endash].width, "space"
            end
            if not spaceunits and characters[emdash] then
                spaceunits, tfm.spacer = characters[emdash].width/2, "emdash/2"
            end
            if not spaceunits and data.charwidth then
                spaceunits, tfm.spacer = data.charwidth, "charwidth"
            end
        end
        spaceunits = tonumber(spaceunits) or tfm.units/2 -- 500 -- brrr
        tfm.parameters[1] = 0                     -- slant
        tfm.parameters[2] = spaceunits            -- space
        tfm.parameters[3] = tfm.units/2   --  500 -- space_stretch
        tfm.parameters[4] = 2*tfm.units/3 --  333 -- space_shrink
        tfm.parameters[5] = 4*tfm.units/5 --  400 -- x_height
        tfm.parameters[6] = tfm.units     -- 1000 -- quad
        tfm.parameters[7] = 0                     -- extra_space (todo)
        if spaceunits < 2*tfm.units/5 then
            -- todo: warning
        end
        tfm.italicangle = data.italicangle
        tfm.ascender    = math.abs(data.ascent  or 0)
        tfm.descender   = math.abs(data.descent or 0)
        if data.italicangle then -- maybe also in afm _
           tfm.parameters[1] = tfm.parameters[1] - math.round(math.tan(data.italicangle*math.pi/180))
        end
        if data.isfixedpitch then
            tfm.parameters[3] = 0
            tfm.parameters[4] = 0
        elseif fonts.otf.syncspace then --
            tfm.parameters[3] = spaceunits/2  -- space_stretch
            tfm.parameters[4] = spaceunits/3  -- space_shrink
        end
        if data.pfminfo and data.pfminfo.os2_xheight and data.pfminfo.os2_xheight > 0 then
            tfm.parameters[5] = data.pfminfo.os2_xheight
        else
            local x = characters[unicodes['x']]
            if x then
                tfm.parameters[5] = x.height
            end
        end
        -- [6]
        return tfm
    else
        return nil
    end
end

function fonts.tfm.read_from_open_type(specification)
    local tfmtable = fonts.otf.otf_to_tfm(specification)
    if tfmtable then
        tfmtable.name = specification.name
        tfmtable.sub = specification.sub
        tfmtable = fonts.tfm.scale(tfmtable, specification.size)
     -- here we resolve the name; file can be relocated, so this info is not in the cache
        local otfdata = tfmtable.shared.otfdata
        local filename = (otfdata and otfdata.luatex and otfdata.luatex.filename) or specification.filename
        if not filename then
            -- try to locate anyway and set otfdata.luatex.filename
        end
        if filename then
            tfmtable.encodingbytes = 2
            tfmtable.filename = input.findbinfile(texmf.instance,filename,"") or filename
            tfmtable.fullname = otfdata.fontname or otfdata.fullname
            tfmtable.format = specification.format
            tfmtable.name = tfmtable.filename or tfmtable.fullname
        end
        fonts.logger.save(tfmtable,file.extname(specification.filename),specification)
    end
    return tfmtable
end

-- scripts

fonts.otf.default_language = 'latn'
fonts.otf.default_script   = 'dflt'

--~ function fonts.otf.valid_feature(otfdata,language,script) -- return hash is faster
--~     local language = language or fonts.otf.default_language
--~     local script   = script   or fonts.otf.default_script
--~     if not (script and language) then
--~         return boolean.alwaystrue
--~     else
--~         language = string.padd(language:lower(),4)
--~         script   = string.padd(script:lower  (),4)
--~         local t = { }
--~         for k,v in pairs(otfdata.luatex.subtables) do
--~             local vv = v[script]
--~             if vv and vv[language] then
--~                 t[k] = vv[language].valid
--~             end
--~         end
--~         local always = otfdata.luatex.always_valid -- for the moment not per feature
--~         --~         return function(kind,tag) -- is the kind test needed
--~         --~             return always[tag] or (kind and t[kind] and t[kind][tag])
--~         --~         end
--~         return function(kind,tag) -- better inline
--~             return always[tag] or (t[kind] and t[kind][tag])
--~         end
--~     end
--~ end

function fonts.otf.valid_feature(otfdata,language,script,feature) -- return hash is faster
    local language = language or fonts.otf.default_language
    local script   = script   or fonts.otf.default_script
    if not (script and language) then
        return true
    else
        language = string.padd(language:lower(),4)
        script   = string.padd(script:lower  (),4)
--~         local t = { }
--~         for k,v in pairs(otfdata.luatex.subtables) do
--~             local vv = v[script]
--~             if vv and vv[language] then
--~                 t[k] = vv[language].valid
--~             end
--~         end
        local ft = otfdata.luatex.subtables[feature]
        local st = ft[script]
        return false, otfdata.luatex.always_valid, st and st[language] and st[language].valid
    end
end

function fonts.otf.some_valid_feature(otfdata,language,script,kind)
    local language = language or fonts.otf.default_language
    local script   = script   or fonts.otf.default_script
    if not (script and language) then
        return boolean.alwaystrue
    else
        language = string.padd(language:lower(),4)
        script   = string.padd(script:lower  (),4)
        local t = otfdata.luatex.subtables[kind]
        if t and t[script] and t[script][language] and t[script][language].valid then
            return t[script][language].valid
        else
            return { }
        end
--~         return (t and t[script][language] and t[script][language].valid) or { }
    end
end

function fonts.otf.features.aux.resolve_ligatures(tfmdata,ligatures,kind)
    local otfdata = tfmdata.shared.otfdata
    local unicodes  = otfdata.luatex.unicodes
    local chars = tfmdata.characters
    local changed = tfmdata.changed or { }
    local done  = { }
    kind = kind or "unknown"
    while true do
        local ok = false
        for k,v in pairs(ligatures) do
            local lig = v[1]
            if not done[lig] then
                local ligs = lig:split(" ")
                if #ligs == 2 then
                    local c, f, s = chars[v[2]], ligs[1], ligs[2]
                    local uf, us = unicodes[f], unicodes[s]
                    if changed[uf] or changed[us] then
                        if fonts.otf.trace_features then
                            logs.report("define otf",string.format("%s: %s (%s) + %s (%s) ignored",kind,f,uf,s,us))
                        end
                    else
                        local first, second = chars[uf], us
                        if first and second then
                            if not first.ligatures then first.ligatures = { } end
                            first.ligatures[second] = {
                                char = unicodes[c.name],
                                type = 0
                            }
                            if fonts.otf.trace_features then
                                logs.report("define otf",string.format("%s: %s (%s) + %s (%s) = %s (%s)",kind,f,uf,s,us,c.name,unicodes[c.name]))
                            end
                        end
                    end
                    ok, done[lig] = true, c.name
                end
            end
        end
        if ok then
            for d,n in pairs(done) do
                local pattern = "^(" .. d .. ") "
                for k,v in pairs(ligatures) do
                    v[1] = v[1]:gsub(pattern, function(str)
                        return n .. " "
                    end)
                end
            end
        else
            break
        end
    end
end

function fonts.otf.features.prepare_base_substitutions(tfmdata,kind,value) -- we can share some code with the node features
    if value then
        local ligatures = { }
        local otfdata = tfmdata.shared.otfdata
        local unicodes = otfdata.luatex.unicodes
        local trace = fonts.otf.trace_features
        local chars = tfmdata.characters
        local somevalid = fonts.otf.some_valid_feature(otfdata,tfmdata.language,tfmdata.script,kind)
        tfmdata.changed = tfmdata.changed or { }
        local changed = tfmdata.changed
        for k,c in pairs(chars) do
            local o = otfdata.glyphs[c.index]
            if o and o.lookups then
                for lookup,ps in pairs(o.lookups) do
--~                     if valid(kind,lookup) then -- can be optimized for #p = 1
if somevalid[lookup] then -- can be optimized for #p = 1
                        for i=1,#ps do
                            local p = ps[i]
                            local t = p.type
                            if t == 'substitution' then
                                local ps = p.specification
                                if ps and ps.variant then
                                    local pv = ps.variant
                                    if pv then
                                        local upv = unicodes[pv]
                                        if upv and chars[upv] then
                                            if trace then
                                                logs.report("define otf",string.format("%s: %s (%s) => %s (%s)",kind,chars[k].name,k,chars[upv].name,upv))
                                            end
                                            chars[k] = chars[upv]
                                            changed[k] = true
                                        end
                                    end
                                end
                            elseif t == 'alternate' then
                                local pa = p.specification if pa and pa.components then
                                    local pc = pa.components:match("(%S+)")
                                    if pc then
                                        local upc = unicodes[pc]
                                        if upc and chars[upc] then
                                            if trace then
                                                logs.report("define otf",string.format("%s: %s (%s) => %s (%s)",kind,chars[k].name,k,chars[upc].name,upc))
                                            end
                                            chars[k] = chars[upc]
                                            changed[k] = true
                                        end
                                    end
                                end
                            elseif t == 'ligature' and not changed[k] then
                                local pl = p.specification
                                if pl and pl.components then
                                    if trace then
                                        logs.report("define otf",string.format("%s: %s => %s (%s)",kind,pl.components,chars[k].name,k))
                                    end
                                    ligatures[#ligatures+1] =  { pl.components, k }
                                end
                            end
                        end
                    end
                end
            end
        end
        fonts.otf.features.aux.resolve_ligatures(tfmdata,ligatures,kind)
    else
        tfmdata.ligatures = tfmdata.ligatures or { }
    end
end

function fonts.initializers.base.otf.liga(tfm,value) fonts.otf.features.prepare_base_substitutions(tfm,'liga',value) end
function fonts.initializers.base.otf.dlig(tfm,value) fonts.otf.features.prepare_base_substitutions(tfm,'dlig',value) end
function fonts.initializers.base.otf.rlig(tfm,value) fonts.otf.features.prepare_base_substitutions(tfm,'rlig',value) end
function fonts.initializers.base.otf.hlig(tfm,value) fonts.otf.features.prepare_base_substitutions(tfm,'hlig',value) end
function fonts.initializers.base.otf.pnum(tfm,value) fonts.otf.features.prepare_base_substitutions(tfm,'pnum',value) end
function fonts.initializers.base.otf.onum(tfm,value) fonts.otf.features.prepare_base_substitutions(tfm,'onum',value) end
function fonts.initializers.base.otf.tnum(tfm,value) fonts.otf.features.prepare_base_substitutions(tfm,'tnum',value) end
function fonts.initializers.base.otf.lnum(tfm,value) fonts.otf.features.prepare_base_substitutions(tfm,'lnum',value) end
function fonts.initializers.base.otf.zero(tfm,value) fonts.otf.features.prepare_base_substitutions(tfm,'zero',value) end
function fonts.initializers.base.otf.smcp(tfm,value) fonts.otf.features.prepare_base_substitutions(tfm,'smcp',value) end
function fonts.initializers.base.otf.cpsp(tfm,value) fonts.otf.features.prepare_base_substitutions(tfm,'cpsp',value) end
function fonts.initializers.base.otf.c2sc(tfm,value) fonts.otf.features.prepare_base_substitutions(tfm,'c2sc',value) end
function fonts.initializers.base.otf.ornm(tfm,value) fonts.otf.features.prepare_base_substitutions(tfm,'ornm',value) end
function fonts.initializers.base.otf.aalt(tfm,value) fonts.otf.features.prepare_base_substitutions(tfm,'aalt',value) end

function fonts.initializers.base.otf.hwid(tfm,value) fonts.otf.features.prepare_base_substitutions(tfm,'hwid',value) end
function fonts.initializers.base.otf.fwid(tfm,value) fonts.otf.features.prepare_base_substitutions(tfm,'fwid',value) end

fonts.otf.features.data.tex = {
    { "endash", "hyphen hyphen" },
    { "emdash", "hyphen hyphen hyphen" },
    { "quotedblleft", "quoteleft quoteleft" },
    { "quotedblright", "quoteright quoteright" },
    { "quotedblleft", "grave grave" },
    { "quotedblright", "quotesingle quotesingle" },
    { "quotedblbase", "comma comma" }
}

--~ 0x201C 0x2018 0x2018
--~ 0x201D 0x2019 0x2019
--~ 0x201E 0X002C 0x002C

function fonts.initializers.base.otf.texligatures(tfm,value)
    local otfdata = tfm.shared.otfdata
    local unicodes = otfdata.luatex.unicodes
    local ligatures = { }
    for _,v in pairs(fonts.otf.features.data.tex) do
        if type(v[1]) == "string" then
            local c = unicodes[v[1]]
            if c then
                ligatures[#ligatures+1] = { v[2], c }
            end
        else
            ligatures[#ligatures+1] = { v[2], v[1] }
        end
    end
    fonts.otf.features.aux.resolve_ligatures(tfm,ligatures)
end

function fonts.initializers.base.otf.texquotes(tfm,value)
    tfm.characters[0x0022] = table.fastcopy(tfm.characters[0x201D])
    tfm.characters[0x0027] = table.fastcopy(tfm.characters[0x2019])
    tfm.characters[0x0060] = table.fastcopy(tfm.characters[0x2018])
end

fonts.initializers.base.otf.trep = fonts.initializers.base.otf.texquotes
fonts.initializers.base.otf.tlig = fonts.initializers.base.otf.texligatures

table.insert(fonts.triggers,"texquotes")
table.insert(fonts.triggers,"texligatures")
table.insert(fonts.triggers,"tlig")

-- Here comes the real thing ... node processing! The next session prepares
-- things. The main features (unchained by rules) have their own caches,
-- while the private ones cache locally.

do

    fonts.otf.features.prepare = { }

    -- also share vars

    function fonts.otf.features.prepare.feature(tfmdata,kind,value) -- check BASE VS NODE
        if value then
            tfmdata.unique = tfmdata.unique or { }
            tfmdata.shared = tfmdata.shared or { }
            local shared = tfmdata.shared
            shared.featuredata = shared.featuredata or { }
            shared.featuredata[kind] = shared.featuredata[kind] or { }
            shared.featurecache = shared.featurecache or { }
            shared.featurecache[kind] = false -- signal
            local otfdata = shared.otfdata
            local lookuptable = fonts.otf.valid_subtable(otfdata,tfmdata.language,tfmdata.script,kind)
            shared.lookuptable = shared.lookuptable or { }
            shared.lookuptable[kind] = lookuptable
            if lookuptable then
                shared.processes = shared.processes or { }
                shared.processes[kind] = shared.processes[kind] or { }
                local processes = shared.processes[kind]
                local types = otfdata.luatex.name_to_type
                local flags = otfdata.luatex.ignore_flags
                local preparers = fonts.otf.features.prepare
                local process = fonts.otf.features.process
                for noflookups, lookupname in ipairs(lookuptable) do
                    local lookuptype = types[lookupname]
                    local prepare = preparers[lookuptype]
                    if prepare then
                        local processdata = prepare(tfmdata,kind,lookupname)
                        if processdata then
                            local processflags = flags[lookupname] or {false,false,false}
                            processes[#processes+1] = { process[lookuptype], lookupname, processdata, processflags }
                        end
                    end
                end
            end
        end
    end

    -- helper: todo, we don't need to store non local ones for chains so we can pass the
    -- validator as parameter

    function fonts.otf.features.collect_ligatures(tfmdata,kind,internal) -- ligs are spread all over the place
        local otfdata = tfmdata.shared.otfdata
        local unicodes = tfmdata.shared.otfdata.luatex.unicodes -- actually the char index is ok too
        local trace = fonts.otf.trace_features
        local ligatures = { }
        local function collect(lookup,o,ps)
            for i=1,#ps do
                local p = ps[i]
                if p.specification and p.type == 'ligature' then
                    if trace then
                        logs.report("define otf",string.format("feature %s ligature %s => %s",kind,p.specification.components,o.name))
                    end
                    local t = ligatures[lookup]
                    if not t then
                        t = { }
                        ligatures[lookup] = t
                    end
                    local first = true
                    for s in p.specification.components:gmatch("(%S+)") do
                        local u = unicodes[s]
                        if first then
                            if not t[u] then
                                t[u] = { { } }
                            end
                            t = t[u]
                            first = false
                        else
                            if not t[1][u] then
                                t[1][u] = { { } }
                            end
                            t = t[1][u]
                        end
                    end
                    t[2] = o.unicodeenc
                end
            end
        end
        if internal then
            local always = otfdata.luatex.always_valid
            for _,o in pairs(otfdata.glyphs) do
                if o.lookups then
                    for lookup, ps in pairs(o.lookups) do
                        if always[lookup] then
                            collect(lookup,o,ps)
                        end
                    end
                end
            end
        else -- check if this valid is still ok
--~             local valid = fonts.otf.valid_feature(otfdata,tfmdata.language,tfmdata.script)
            local forced, always, okay = fonts.otf.valid_feature(otfdata,tfmdata.language,tfmdata.script,kind)
            for _,o in pairs(otfdata.glyphs) do
                if o.lookups then
--~                     for lookup, ps in pairs(o.lookups) do
--~                         if valid(kind,lookup) then
--~                             collect(lookup,o,ps)
--~                         end
--~                     end
                    if forced then
                        for lookup, ps in pairs(o.lookups) do                                        collect(lookup,o,ps)     end
                    elseif okay then
                        for lookup, ps in pairs(o.lookups) do if always[lookup] or okay[lookup] then collect(lookup,o,ps) end end
                    else
                        for lookup, ps in pairs(o.lookups) do if always[lookup]                 then collect(lookup,o,ps) end end
                    end
                end
            end
        end
        return ligatures
    end

    -- gsub_single        -> done
    -- gsub_multiple      -> done
    -- gsub_alternate     -> done
    -- gsub_ligature      -> done
    -- gsub_context       -> todo
    -- gsub_contextchain  -> done
    -- gsub_reversechain  -> todo

    -- we used to share code in the following functions but that was relatively
    -- due to extensive calls to functions (easily hundreds of thousands per
    -- document)

    function fonts.otf.features.prepare.gsub_single(tfmdata,kind,lookupname)
        local featuredata = tfmdata.shared.featuredata[kind]
        local substitutions = featuredata[lookupname]
        if not substitutions then
            substitutions = { }
            featuredata[lookupname] = substitutions
            local otfdata = tfmdata.shared.otfdata
            local unicodes = otfdata.luatex.unicodes
            local trace = fonts.otf.trace_features
            for _, o in pairs(otfdata.glyphs) do
                local lookups = o.lookups
                if lookups then
                    for lookup,ps in pairs(lookups) do
                        if lookup == lookupname then
                            for i=1,#ps do
                                local p = ps[i]
                                if p.specification and p.type == 'substitution' then
                                    local old, new = o.unicodeenc, unicodes[p.specification.variant]
                                    substitutions[old] =  new
                                    if trace then
                                        logs.report("define otf",string.format("%s:%s substitution %s => %s",kind,lookupname,old,new))
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        return substitutions
    end

    function fonts.otf.features.prepare.gsub_multiple(tfmdata,kind,lookupname)
        local featuredata = tfmdata.shared.featuredata[kind]
        local substitutions = featuredata[lookupname]
        if not substitutions then
            substitutions = { }
            featuredata[lookupname] = substitutions
            local otfdata = tfmdata.shared.otfdata
            local unicodes = otfdata.luatex.unicodes
            local trace = fonts.otf.trace_features
            for _,o in pairs(otfdata.glyphs) do
                local lookups = o.lookups
                if lookups then
                    for lookup,ps in pairs(lookups) do
                        if lookup == lookupname then
                            for i=1,#ps do
                                local p = ps[i]
                                if p.specification and p.type == 'multiple' then
                                    local old, new = o.unicodeenc, { }
                                    substitutions[old] = new
                                    for pc in p.specification.components:gmatch("(%S+)") do
                                        new[#new+1] = unicodes[pc]
                                    end
                                    if trace then
                                        logs.report("define otf",string.format("%s:%s multiple %s => %s",kind,lookupname,old,table.concat(new," ")))
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        return substitutions
    end

    function fonts.otf.features.prepare.gsub_alternate(tfmdata,kind,lookupname)
        -- todo: configurable preference list
        local featuredata = tfmdata.shared.featuredata[kind]
        local substitutions = featuredata[lookupname]
        if not substitutions then
            featuredata[lookupname] = { }
            substitutions = featuredata[lookupname]
            local otfdata = tfmdata.shared.otfdata
            local unicodes = otfdata.luatex.unicodes
            local trace = fonts.otf.trace_features
            for _,o in pairs(otfdata.glyphs) do
                local lookups = o.lookups
                if lookups then
                    for lookup,ps in pairs(lookups) do
                        if lookup == lookupname then
                            for i=1,#ps do
                                local p = ps[i]
                                if p.specification and p.type == 'alternate' then
                                    local old = o.unicodeenc
                                    local t = { }
                                    for pc in p.specification.components:gmatch("(%S+)") do
                                        t[#t+1] = unicodes[pc]
                                    end
                                    substitutions[old] =  t
                                    if trace then
                                        logs.report("define otf",string.format("%s:%s alternate %s => %s",kind,lookupname,old,table.concat(substitutions,"|")))
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        return substitutions
    end

    function fonts.otf.features.prepare.gsub_ligature(tfmdata,kind,lookupname)
        -- we collect them for all lookups, this saves loops, we only use the
        -- lookupname for testing, we need to check if this leads to redundant
        -- collections
        local ligatures = tfmdata.shared.featuredata[kind]
        if not ligatures[lookupname] then
            ligatures = fonts.otf.features.collect_ligatures(tfmdata,kind)
            tfmdata.shared.featuredata[kind] = ligatures
        end
        return ligatures[lookupname]
    end

    function fonts.otf.features.prepare.contextchain(tfmdata,kind,lookupname)
        local featuredata  = tfmdata.shared.featuredata[kind]
        local contexts = featuredata[lookupname]
        if not contexts then
            featuredata[lookupname] = { }
            contexts = featuredata[lookupname]
            local otfdata = tfmdata.shared.otfdata
            local unicodes = otfdata.luatex.unicodes
            local internals = otfdata.luatex.internals
            local flags = otfdata.luatex.ignore_flags
            local types = otfdata.luatex.name_to_type
            otfdata.luatex.covers = otfdata.luatex.covers or { }
            local cache = otfdata.luatex.covers
            local characters = tfmdata.characters
            local function uncover(covers)
                if covers then
                    local result = { }
                    for n, c in ipairs(covers) do
                        local cc = cache[c]
                        if not cc then
                            local t = { }
                            for s in c:gmatch("(%S+)") do
                                t[unicodes[s]] = true
                            end
                            cache[c] = t
                            result[n] = t
                        else
                            result[n] = cc
                        end
                    end
                    return result
                else
                    return { }
                end
            end
            local lookupdata = otfdata.lookups[lookupname]
            if not lookupdata then
                logs.error("otf process", string.format("missing lookupdata table %s",lookupname))
            elseif lookupdata.rules then
                for nofrules, rule in ipairs(lookupdata.rules) do
                    local coverage = rule.coverage
                    if coverage and coverage.current then
                        local current = uncover(coverage.current)
                        local before = uncover(coverage.before)
                        local after = uncover(coverage.after)
                        if current[1] then
                            local lookups, lookuptype = rule.lookups, 'self'
                            -- for the moment only lookup index 1
                            if lookups then
                                if #lookups > 1 then
                                    logs.report("otf process","WARNING: more than one lookup in rule")
                                end
                                lookuptype = types[lookups[1]]
                            end
                            for unic, _ in pairs(current[1]) do
                                local t = contexts[unic]
                                if not t then
                                    contexts[unic] = { lookups={}, flags=flags[lookupname] }
                                    t = contexts[unic].lookups
                                end
                                t[#t+1] = { nofrules, lookuptype, current, before, after, lookups }
                            end
                        end
                    end
                end
            end
        end
        return contexts
    end

    fonts.otf.features.prepare.gsub_context             = fonts.otf.features.prepare.contextchain
    fonts.otf.features.prepare.gsub_contextchain        = fonts.otf.features.prepare.contextchain
    fonts.otf.features.prepare.gsub_reversecontextchain = fonts.otf.features.prepare.contextchain

    -- ruled->lookup=ks_latn_l_27_c_4 => internal[ls_l_84] => valid[ls_l_84_s]

    -- gpos_mark2base     -> done
    -- gpos_mark2ligature -> done
    -- gpos_mark2mark     -> done
    -- gpos_single        -> not done
    -- gpos_pair          -> not done
    -- gpos_cursive       -> not done
    -- gpos_context       -> not done
    -- gpos_contextchain  -> not done

    function fonts.otf.features.prepare.anchors(tfmdata,kind,lookupname) -- tracing
        local featuredata = tfmdata.shared.featuredata[kind]
        local anchors = featuredata[lookupname]
        if not anchors then
            featuredata[lookupname] = { }
            anchors = featuredata[lookupname]
            local otfdata = tfmdata.shared.otfdata
            local unicodes = otfdata.luatex.unicodes
            local validanchors = { }
            local glyphs = otfdata.glyphs
            if otfdata.anchor_classes then
                for k,v in ipairs(otfdata.anchor_classes) do
                    if v.lookup == lookupname then
                        validanchors[v.name] = true
                    end
                end
            end
            for _,o in pairs(glyphs) do
                local oanchor = o.anchors
                if oanchor then
                    local t, ok = { }, false
                    for type, anchors in pairs(oanchor) do -- types
                        local tt = false
                        for name, anchor in pairs(anchors) do
                            if validanchors[name] then
                                if not tt then
                                    tt = { [name] = anchor }
                                    t[type] = tt
                                    ok = true
                                else
                                    tt[name] = anchor
                                end
                            end
                        end
                    end
                    if ok then
                        anchors[o.unicodeenc] = t
                    end
                end
            end
        end
        return anchors
    end

    fonts.otf.features.prepare.gpos_mark2base     = fonts.otf.features.prepare.anchors
    fonts.otf.features.prepare.gpos_mark2ligature = fonts.otf.features.prepare.anchors
    fonts.otf.features.prepare.gpos_mark2mark     = fonts.otf.features.prepare.anchors
    fonts.otf.features.prepare.gpos_cursive       = fonts.otf.features.prepare.anchors
    fonts.otf.features.prepare.gpos_context       = fonts.otf.features.prepare.contextchain
    fonts.otf.features.prepare.gpos_contextchain  = fonts.otf.features.prepare.contextchain

    function fonts.otf.features.prepare.gpos_single(tfmdata,kind,lookupname)
        logs.report("otf define","gpos_single not yet supported")
    end

    --  ["kerns"]={ { ["char"]="ytilde", ["lookup"]="pp_l_1_s", ["off"]=-83, ...
    --  ["mykerns"] = { ["pp_l_1_s"] = { [67] = -28, ...

    function fonts.otf.features.prepare.gpos_pair(tfmdata,kind,lookupname)
        local featuredata = tfmdata.shared.featuredata[kind]
        local kerns = featuredata[lookupname]
        if not kerns then
            featuredata[lookupname] = { }
            kerns = featuredata[lookupname]
            local otfdata = tfmdata.shared.otfdata
            local unicodes = otfdata.luatex.unicodes
            local glyphs = otfdata.glyphs
            -- ff has isolated kerns in a separate table
            for k,o in pairs(glyphs) do
                local list = o.mykerns
                if list then
                    local omk = list[lookupname]
                    if omk then
                        local one = o.unicodeenc
                        for char, off in pairs(omk) do
                            local two = char
                            local krn = kerns[one]
                            if krn then
                                krn[two] = off
                            else
                                kerns[one] = { two = off }
                            end
                            if fonts.otf.trace_features then
                                logs.report("define otf",string.format("feature %s kern pair %s - %s",kind,one,two))
                            end
                        end
                    end
                elseif o.kerns then
                    local one = o.unicodeenc
                    for _, l in ipairs(o.kerns) do
                        if l.lookup == lookupname then
                            local char = l.char
                            if char then
                                local two = unicodes[char]
                                local krn = kerns[one]
                                if krn then
                                    krn[two] = l.off
                                else
                                    kerns[one] = { two = l.off }
                                end
                                if fonts.otf.trace_features then
                                    logs.report("define otf",string.format("feature %s kern pair %s - %s",kind,one,two))
                                end
                            end
                        end
                    end
                end
                list = o.lookups
                if list then
                    local one = o.unicodeenc
                    for lookup,ps in pairs(list) do
                        if lookup == lookupname then
                            for i=1,#ps do
                                local p = ps[i]
                                if p.type == 'pair' then
                                    local specification = p.specification
                                    local two = unicodes[specification.paired]
                                    local krn = kerns[one]
                                    if krn then
                                        krn[two] = specification.offsets
                                    else
                                        kerns[one] = { two = specification.offsets }
                                    end
                                    if fonts.otf.trace_features then
                                        logs.report("define otf",string.format("feature %s kern pair %s - %s",kind,one,two))
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        return kerns
    end

    fonts.otf.features.prepare.gpos_contextchain = fonts.otf.features.prepare.contextchain

end

-- can be generalized: one loop in main

do

    local prepare = fonts.otf.features.prepare.feature

    function fonts.initializers.node.otf.aalt(tfm,value) return prepare(tfm,'aalt',value) end
    function fonts.initializers.node.otf.afrc(tfm,value) return prepare(tfm,'afrc',value) end
    function fonts.initializers.node.otf.akhn(tfm,value) return prepare(tfm,'akhn',value) end
    function fonts.initializers.node.otf.c2pc(tfm,value) return prepare(tfm,'c2pc',value) end
    function fonts.initializers.node.otf.c2sc(tfm,value) return prepare(tfm,'c2sc',value) end
    function fonts.initializers.node.otf.calt(tfm,value) return prepare(tfm,'calt',value) end
    function fonts.initializers.node.otf.case(tfm,value) return prepare(tfm,'case',value) end
    function fonts.initializers.node.otf.ccmp(tfm,value) return prepare(tfm,'ccmp',value) end
    function fonts.initializers.node.otf.clig(tfm,value) return prepare(tfm,'clig',value) end
    function fonts.initializers.node.otf.cpsp(tfm,value) return prepare(tfm,'cpsp',value) end
    function fonts.initializers.node.otf.cswh(tfm,value) return prepare(tfm,'cswh',value) end
    function fonts.initializers.node.otf.curs(tfm,value) return prepare(tfm,'curs',value) end
    function fonts.initializers.node.otf.dlig(tfm,value) return prepare(tfm,'dlig',value) end
    function fonts.initializers.node.otf.dnom(tfm,value) return prepare(tfm,'dnom',value) end
    function fonts.initializers.node.otf.expt(tfm,value) return prepare(tfm,'expt',value) end
    function fonts.initializers.node.otf.fin2(tfm,value) return prepare(tfm,'fin2',value) end
    function fonts.initializers.node.otf.fin3(tfm,value) return prepare(tfm,'fin3',value) end
    function fonts.initializers.node.otf.fina(tfm,value) return prepare(tfm,'fina',value) end
    function fonts.initializers.node.otf.frac(tfm,value) return prepare(tfm,'frac',value) end
    function fonts.initializers.node.otf.fwid(tfm,value) return prepare(tfm,'fwid',value) end
    function fonts.initializers.node.otf.haln(tfm,value) return prepare(tfm,'haln',value) end
    function fonts.initializers.node.otf.hist(tfm,value) return prepare(tfm,'hist',value) end
    function fonts.initializers.node.otf.hkna(tfm,value) return prepare(tfm,'hkna',value) end
    function fonts.initializers.node.otf.hlig(tfm,value) return prepare(tfm,'hlig',value) end
    function fonts.initializers.node.otf.hngl(tfm,value) return prepare(tfm,'hngl',value) end
    function fonts.initializers.node.otf.hwid(tfm,value) return prepare(tfm,'hwid',value) end
    function fonts.initializers.node.otf.init(tfm,value) return prepare(tfm,'init',value) end
    function fonts.initializers.node.otf.isol(tfm,value) return prepare(tfm,'isol',value) end
    function fonts.initializers.node.otf.ital(tfm,value) return prepare(tfm,'ital',value) end
    function fonts.initializers.node.otf.jp78(tfm,value) return prepare(tfm,'jp78',value) end
    function fonts.initializers.node.otf.jp83(tfm,value) return prepare(tfm,'jp83',value) end
    function fonts.initializers.node.otf.jp90(tfm,value) return prepare(tfm,'jp90',value) end
    function fonts.initializers.node.otf.kern(tfm,value) return prepare(tfm,'kern',value) end
    function fonts.initializers.node.otf.liga(tfm,value) return prepare(tfm,'liga',value) end
    function fonts.initializers.node.otf.lnum(tfm,value) return prepare(tfm,'lnum',value) end
    function fonts.initializers.node.otf.locl(tfm,value) return prepare(tfm,'locl',value) end
    function fonts.initializers.node.otf.mark(tfm,value) return prepare(tfm,'mark',value) end
    function fonts.initializers.node.otf.med2(tfm,value) return prepare(tfm,'med2',value) end
    function fonts.initializers.node.otf.medi(tfm,value) return prepare(tfm,'medi',value) end
    function fonts.initializers.node.otf.mgrk(tfm,value) return prepare(tfm,'mgrk',value) end
    function fonts.initializers.node.otf.mkmk(tfm,value) return prepare(tfm,'mkmk',value) end
    function fonts.initializers.node.otf.nalt(tfm,value) return prepare(tfm,'nalt',value) end
    function fonts.initializers.node.otf.nlck(tfm,value) return prepare(tfm,'nlck',value) end
    function fonts.initializers.node.otf.nukt(tfm,value) return prepare(tfm,'nukt',value) end
    function fonts.initializers.node.otf.numr(tfm,value) return prepare(tfm,'numr',value) end
    function fonts.initializers.node.otf.onum(tfm,value) return prepare(tfm,'onum',value) end
    function fonts.initializers.node.otf.ordn(tfm,value) return prepare(tfm,'ordn',value) end
    function fonts.initializers.node.otf.ornm(tfm,value) return prepare(tfm,'ornm',value) end
    function fonts.initializers.node.otf.pnum(tfm,value) return prepare(tfm,'pnum',value) end
    function fonts.initializers.node.otf.pref(tfm,value) return prepare(tfm,'pref',value) end
    function fonts.initializers.node.otf.pres(tfm,value) return prepare(tfm,'pres',value) end
    function fonts.initializers.node.otf.pstf(tfm,value) return prepare(tfm,'pstf',value) end
    function fonts.initializers.node.otf.rlig(tfm,value) return prepare(tfm,'rlig',value) end
    function fonts.initializers.node.otf.rphf(tfm,value) return prepare(tfm,'rphf',value) end
    function fonts.initializers.node.otf.salt(tfm,value) return prepare(tfm,'salt',value) end
    function fonts.initializers.node.otf.sinf(tfm,value) return prepare(tfm,'sinf',value) end
    function fonts.initializers.node.otf.smcp(tfm,value) return prepare(tfm,'smcp',value) end
    function fonts.initializers.node.otf.smpl(tfm,value) return prepare(tfm,'smpl',value) end
    function fonts.initializers.node.otf.ss01(tfm,value) return prepare(tfm,'ss01',value) end
    function fonts.initializers.node.otf.ss02(tfm,value) return prepare(tfm,'ss02',value) end
    function fonts.initializers.node.otf.ss03(tfm,value) return prepare(tfm,'ss03',value) end
    function fonts.initializers.node.otf.ss04(tfm,value) return prepare(tfm,'ss04',value) end
    function fonts.initializers.node.otf.ss05(tfm,value) return prepare(tfm,'ss05',value) end
    function fonts.initializers.node.otf.ss06(tfm,value) return prepare(tfm,'ss06',value) end
    function fonts.initializers.node.otf.ss07(tfm,value) return prepare(tfm,'ss07',value) end
    function fonts.initializers.node.otf.ss08(tfm,value) return prepare(tfm,'ss08',value) end
    function fonts.initializers.node.otf.ss09(tfm,value) return prepare(tfm,'ss09',value) end
    function fonts.initializers.node.otf.subs(tfm,value) return prepare(tfm,'subs',value) end
    function fonts.initializers.node.otf.sups(tfm,value) return prepare(tfm,'sups',value) end
    function fonts.initializers.node.otf.swsh(tfm,value) return prepare(tfm,'swsh',value) end
    function fonts.initializers.node.otf.titl(tfm,value) return prepare(tfm,'titl',value) end
    function fonts.initializers.node.otf.tnam(tfm,value) return prepare(tfm,'tnam',value) end
    function fonts.initializers.node.otf.tnum(tfm,value) return prepare(tfm,'tnum',value) end
    function fonts.initializers.node.otf.trad(tfm,value) return prepare(tfm,'trad',value) end
    function fonts.initializers.node.otf.unic(tfm,value) return prepare(tfm,'unic',value) end
    function fonts.initializers.node.otf.zero(tfm,value) return prepare(tfm,'zero',value) end

end

do

    local glyph         = node.id('glyph')
    local glue          = node.id('glue')
    local kern_node     = node.new("kern")
    local glue_node     = node.new("glue")
    local glyph_node    = node.new("glyph")

    local fontdata      = fonts.tfm.id
    local has_attribute = node.has_attribute
    local set_attribute = node.set_attribute
    local state         = attributes.numbers['state'] or 100
    local marknumber    = attributes.numbers['mark']  or 200
    local format        = string.format
    local report        = logs.report

    fonts.otf.features.process = { }

    -- we share aome vars here, after all, we have no nested lookups and
    -- less code

    local tfmdata     = false
    local otfdata     = false
    local characters  = false
    local marks       = false
    local glyphs      = false
    local currentfont = false

    function fonts.otf.features.process.feature(head,font,kind,attribute)
        tfmdata = fontdata[font]
        otfdata = tfmdata.shared.otfdata
        characters = tfmdata.characters
        marks = otfdata.luatex.marks
        glyphs = otfdata.glyphs
        currentfont = font
        local lookuptable = tfmdata.shared.lookuptable[kind]
        if lookuptable then
            local types = otfdata.luatex.name_to_type
            local start, done, ok = head, false, false
            local processes = tfmdata.shared.processes[kind]
            if #processes == 1 then
                local p = processes[1]
                while start do
                    if start.id == glyph and start.font == font and (not attribute or has_attribute(start,state,attribute)) then
                        -- we can make the p vars also global to this closure
                        local pp = p[3] -- all lookups
                        local pc = pp[start.char]
                        if pc then
                            start, ok = p[1](start,kind,p[2],pc,pp,p[4])
                            done = done or ok
                            if start then start = start.next end
                        else
                            start = start.next
                        end
                    else
                        start = start.next
                    end
                end
            else
                while start do
                    if start.id == glyph and start.font == font and (not attribute or has_attribute(start,state,attribute)) then
                        for i=1,#processes do local p = processes[i]
                            local pp = p[3]
                            local pc = pp[start.char]
                            if pc then
                                start, ok = p[1](start,kind,p[2],pc,pp,p[4])
                                if ok then
                                    done = true
                                    break
                                elseif not start then
                                    break
                                end
                            end
                        end
                        if start then start = start.next end
                    else
                        start = start.next
                    end
                end
            end
            return head, done
        else
            return head, false
        end
    end

    -- todo: components / else subtype 0 / maybe we should be able to force this

    local function toligature(start,stop,char,markflag)
        if start ~= stop then
            local deletemarks = markflag ~= "mark"
            start.components = node.copy_list(start,stop)
            node.slide(start.components)
            -- todo: components
            start.subtype = 1
            start.char = char
            local marknum = 1
            local next = start.next
            while true do
                if marks[next.char] then
                    if not deletemarks then
                        set_attribute(next,marknumber,marknum)
                    end
                else
                    marknum = marknum + 1
                end
                if next == stop then
                    break
                else
                    next = next.next
                end
            end
            next = stop.next
            while next do
                if next.id == glyph and next.font == currentfont and marks[next.char] then
                    set_attribute(next,marknumber,marknum)
                    next = next.next
                else
                    break
                end
            end
            local next = start.next
            while true do
                if next == stop or deletemarks or marks[next.char] then
                    local crap = next
                    next.prev.next = next.next
                    if next.next then
                        next.next.prev = next.prev
                    end
                    if next == stop then
                        stop = crap.prev
                        node.free(crap)
                        break
                    else
                        next = next.next
                        node.free(crap)
                    end
                else
                    next = next.next
                end
            end
        end
        return start
    end

    function fonts.otf.features.process.gsub_single(start,kind,lookupname,replacements)
        if replacements then
            start.char = replacements
            if fonts.otf.trace_replacements then
                report("process otf",format("%s:%s replacing %s by %s",kind,lookupname,start.char,replacements))
            end
            return start, true
        else
            return start, false
        end
    end

    function fonts.otf.features.process.gsub_alternate(start,kind,lookupname,alternatives)
        if alternatives then
            start.char = alternatives[1] -- will be preference
            if fonts.otf.trace_replacements then
                report("process otf",format("%s:%s alternative %s => %s",kind,lookupname,start.char,table.concat(alternatives,"|")))
            end
            return start, true
        else
            return start, false
        end
    end

    function fonts.otf.features.process.gsub_multiple(start,kind,lookupname,multiples)
        if multiples then
            start.char = multiples[1]
            if #multiples > 1 then
                for k=2,#multiples do
                    local n = node.copy(start)
                    n.char = multiples[k]
                    n.next = start.next
                    n.prev = start
                    if start.next then
                        start.next.prev = n
                    end
                    start.next = n
                    start = n
                end
            end
            if fonts.otf.trace_replacements then
                report("process otf",format("%s:%s alternative %s => %s",kind,lookupname,start.char,table.concat(multiples," ")))
            end
            return start, true
        else
            return start, false
        end
    end

    function fonts.otf.features.process.gsub_ligature(start,kind,lookupname,ligatures,alldata,flags)
        local s, stop = start.next, nil
        while s and s.id == glyph and s.subtype == 0 and s.font == currentfont do
            if marks[s.char] then
                s = s.next
            else
                local lg = ligatures[1][s.char]
                if not lg then
                    break
                else
                    stop = s
                    ligatures = lg
                    s = s.next
                end
            end
        end
        if stop and ligatures[2] then
            start = toligature(start,stop,ligatures[2],flags[1])
            if fonts.otf.trace_ligatures then
                report("process otf",format("%s: inserting ligature %s (%s)",kind,start.char,utf.char(start.char)))
            end
            return start, true
        end
        return start, false
    end

    -- again, using copies is more efficient than sharing code

    function fonts.otf.features.process.gpos_mark2base(start,kind,lookupname,baseanchors,anchors) -- maybe use copies
        local bases = baseanchors['basechar']
        if bases then
            local component = start.next
            if component and component.id == glyph and component.font == currentfont and marks[component.char] then
                local trace = fonts.otf.trace_anchors
                local last, done = start, false
                while true do
                    local markanchors = anchors[component.char]
                    if markanchors then
                        local marks = markanchors['mark']
                        if marks then
                            for anchor,data in pairs(marks) do
                                local ba = bases[anchor]
                                if ba then
                                    local dx = tex.scale(ba.x-data.x, tfmdata.factor)
                                    local dy = tex.scale(ba.y-data.y, tfmdata.factor)
                                    component.xoffset = start.xoffset - dx
                                    component.yoffset = start.yoffset + dy
                                    if trace then
                                        report("process otf",format("%s: anchoring mark %s to basechar %s => (%s,%s) => (%s,%s)",kind,component.char,start.char,dx,dy,component.xoffset,component.yoffset))
                                    end
                                    done = true
                                    break
                                end
                            end
                        end
                        last = component
                    end
                    component = component.next
--~ if component and component.id == kern then
--~     component = component.next
--~ end
                    if component and component.id == glyph and component.font == currentfont and marks[component.char] then
                        -- ok
                    else
                        break
                    end
                end
                return last, done
            end
        end
        return start, false
    end

    function fonts.otf.features.process.gpos_mark2ligature(start,kind,lookupname,baseanchors,anchors)
        local bases = baseanchors['baselig']
        if bases then
            local component = start.next
            if component and component.id == glyph and component.font == currentfont and marks[component.char] then
                local trace = fonts.otf.trace_anchors
                local last, done = start, false
                while true do
                    local markanchors = anchors[component.char]
                    if markanchors then
                        local marks = markanchors['mark']
                        if marks then
                            for anchor,data in pairs(marks) do
                                local ba = bases[anchor]
                                if ba then
                                    local n = has_attribute(component,marknumber)
                                    local ban = ba[n]
                                    if ban then
                                        local dx = tex.scale(ban.x-data.x, tfmdata.factor)
                                        local dy = tex.scale(ban.y-data.y, tfmdata.factor)
                                        component.xoffset = start.xoffset - dx
                                        component.yoffset = start.yoffset + dy
                                        if trace then
                                            report("process otf",format("%s:%s:%s anchoring mark %s to baselig %s => (%s,%s) => (%s,%s)",kind,anchor,n,component.char,start.char,dx,dy,component.xoffset,component.yoffset))
                                        end
                                        done = true
                                        break
                                    end
                                end
                            end
                        end
                    end
                    last = component
                    component = component.next
--~ if component and component.id == kern then
--~     component = component.next
--~ end
                    if component and component.id == glyph and component.font == currentfont and marks[component.char] then
                        -- ok
                    else
                        break
                    end
                end
                return last, done
            end
        end
        return start, false
    end

    function fonts.otf.features.process.gpos_mark2mark(start,kind,lookupname,baseanchors,anchors)
        -- we can stay in the loop for all anchors
        local bases = baseanchors['basemark']
        if bases then
            local component = start.next
            if component and component.id == glyph and component.font == currentfont and marks[component.char] then
                local baseattr = has_attribute(start,marknumber) or 1
                local trace = fonts.otf.trace_anchors
                local last, done = start, false
                while true do
                    local markattr = has_attribute(component,marknumber) or 1
                    if baseattr == markattr then
                        local markanchors = anchors[component.char]
                        if markanchors then
                            local marks = markanchors['mark']
                            if marks then
                                for anchor,data in pairs(marks) do
                                    local ba = bases[anchor]
                                    if ba then
                                        local dx = tex.scale(ba.x-data.x, tfmdata.factor)
                                        local dy = tex.scale(ba.y-data.y, tfmdata.factor)
                                        component.xoffset = start.xoffset - dx
                                        component.yoffset = start.yoffset + dy
                                        if trace then
                                            report("process otf",format("%s:%s:%s anchoring mark %s to basemark %s => (%s,%s) => (%s,%s)",kind,anchor,n,start.char,component.char,dx,dy,component.xoffset,component.yoffset))
                                        end
                                        done = true
                                        break
                                    end
                                end
                            end
                        end
                        last = component
                        component = component.next
--~ if component and component.id == kern then
--~     component = component.next
--~ end
                        if component and component.id == glyph and component.font == currentfont and marks[component.char] then
                            -- ok
                        else
                            break
                        end
                    else
                        break
                    end
                end
                return last, done
            end
        end
        return start, false
    end

    function fonts.otf.features.process.gpos_cursive(start,kind,lookupname,exitanchors,anchors)
        local trace = fonts.otf.trace_anchors
        local next, done, x, y, total, t, first = start.next, false, 0, 0, 0, { }, nil
        local function finish()
            local i = 0
            while first do
                if characters[first.char].class == 'mark' then
                    first = first.next
                else
                    first.yoffset = tex.scale(total, tfmdata.factor)
                    if first == next then
                        break
                    else
                        i = i + 1
                        total = total - (t[i] or 0)
                        first = first.next
                    end
                end
            end
            x, y, total, t, first = 0, 0, 0, { }, nil
        end
        while next do
            if next.id == glyph and next.font == currentfont then
                local nextchar = next.char
                if marks[nextchar] then
                    next = next.next
                else
                    local entryanchors, exitanchors = anchors[nextchar], anchors[start.char]
                    if entryanchors and exitanchors then
                        local centry, cexit = entryanchors['centry'], exitanchors['cexit']
                        if centry and cexit then
                            for anchor, entry in pairs(centry) do
                                local exit = cexit[anchor]
                                if exit then
                                    if not first then first = start end
                                    t[#t+1] = exit.y + entry.y
                                    total = total + t[#t]
                                    done = true
                                    break
                                end
                            end
                        else
                            finish()
                        end
                    else
                        finish()
                    end
                    start = next
                    next = start.next
                end
            else
                finish()
                break
            end
        end
        return start, done
    end

    function fonts.otf.features.process.gpos_single(start,kind,lookupname,basekerns,kerns)
        report("otf process","gpos_single not yet supported")
        return start, false
    end

    function fonts.otf.features.process.gpos_pair(start,kind,lookupname,basekerns,kerns)
        local next, prev, done = start.next, start, false
        -- to be optimized
        while next and next.id == glyph and next.font == currentfont do
            if characters[next.char].class == 'mark' then
                prev = next
                next = next.next
            else
                local krn = basekerns[next.char]
                if not krn then
                    -- skip
                elseif type(krn) == "table" then
                    local a, b = krn[1], krn[2]
                    if a and a.x then
                        local k = node.copy(kern_node)
                        k.kern = tex.scale(a.x,fontdata[currentfont].factor) -- tfmdata.factor
                        if b and b.x then
                            report("otf process","we need to do something with the second kern xoff " .. b.x)
                        end
                        k.next = next
                        k.prev = prev
                        prev.next = k
                        next.prev = k
                        if fonts.otf.trace_kerns then
                            -- todo
                        end
                    end
                else
                    -- todo, just start, next = node.insert_before(head,next,nodes.kern(tex.scale(kern,fontdata[currentfont].factor)))
                    local k = node.copy(kern_node)
                    k.kern = tex.scale(krn,fontdata[currentfont].factor) -- tfmdata.factor
                    k.next = next
                    k.prev = prev
                    prev.next = k
                    next.prev = k
                end
                break
            end
        end
        return start, done
    end

    local chainprocs = { } -- we can probably optimize this because they're all internal lookups

    -- For the moment we save each looked up glyph in the sequence, which is ok because
    -- each lookup in the chain has its own sequence. This saves memory. Only ligatures
    -- are stored in the featurecache, because we don't want to loop over all characters
    -- in order to locate them.

    -- We had a version that shared code, but it was too much a slow down
    -- todo n x n.

    function chainprocs.gsub_single(start,stop,kind,lookupname,sequence,lookups)
        local char = start.char
        local cacheslot = sequence[1]
        local replacement = cacheslot[char]
        if replacement == true then
            if lookups then
                local looks = glyphs[tfmdata.characters[char].index].lookups
                if looks then
                    local lookups = otfdata.luatex.internals[lookups[1]].lookups
                    local unicodes = otfdata.luatex.unicodes
                    for l=1,#lookups do
                        local lv = looks[lookups[l]]
                        if lv then
                            replacement = unicodes[lv[1].specification.variant] or char
                            cacheslot[char] = replacement
                            break
                        end
                    end
                else
                    replacement, cacheslot[char] = char, char
                end
            else
                replacement, cacheslot[char] = char, char
            end
        end
        if fonts.otf.trace_replacements then
            report("otf chain",format("%s: replacing character %s by single %s",kind,char,replacement))
        end
        start.char = replacement
        return start
    end

    function chainprocs.gsub_multiple(start,stop,kind,lookupname,sequence,lookups)
        local char = start.char
        local cacheslot = sequence[1]
        local replacement = cacheslot[char]
        if replacement == true then
            if lookups then
                local looks = glyphs[tfmdata.characters[char].index].lookups
                if looks then
                    local lookups = otfdata.luatex.internals[lookups[1]].lookups
                    local unicodes = otfdata.luatex.unicodes
                    for l=1,#lookups do
                        local lv = looks[lookups[l]]
                        if lv then
                            replacement = { }
                            for c in lv[1].specification.components:gmatch("(%S+)") do
                                replacement[#replacement+1] = unicodes[c]
                            end
                            cacheslot[char] = replacement
                            break
                        end
                    end
                else
                    replacement = { char }
                    cacheslot[char] = replacement
                end
            else
                replacement = { char }
                cacheslot[char] = replacement
            end
        end
        if fonts.otf.trace_replacements then
            report("otf chain",format("%s: replacing character %s by multiple",kind,char))
        end
        start.char = replacement[1]
        if #replacement > 1 then
            for k=2,#replacement do
                local n = node.copy(start)
                n.char = replacement[k]
                n.next = start.next
                n.prev = start
                if start.next then
                    start.next.prev = n
                end
                start.next = n
                start = n
            end
        end
        return start
    end

    function chainprocs.gsub_alternate(start,stop,kind,lookupname,sequence,lookups)
        local char = start.char
        local cacheslot = sequence[1]
        local replacement = cacheslot[char]
        if replacement == true then
            if lookups then
                local looks = glyphs[tfmdata.characters[char].index].lookups
                if looks then
                    local lookups = otfdata.luatex.internals[lookups[1]].lookups
                    local unicodes = otfdata.luatex.unicodes
                    for l=1,#lookups do
                        local lv = looks[lookups[l]]
                        if lv then
                            replacement = { }
                            for c in lv[1].specification.components:gmatch("(%S+)") do
                                replacement[#replacement+1] = unicodes[c]
                            end
                            cacheslot[char] = replacement
                            break
                        end
                    end
                else
                    replacement = { char }
                    cacheslot[char] = replacement
                end
            else
                replacement = { char }
                cacheslot[char] = replacement
            end
        end
        if fonts.otf.trace_replacements then
            report("otf chain",format("%s: replacing character %s by alternate",kind,char))
        end
        start.char = replacement[1]
        return start
    end

    function chainprocs.gsub_ligature(start,stop,kind,lookupname,sequence,lookups,flags)
        if lookups then
            local featurecache = fontdata[currentfont].shared.featurecache
            if not featurecache[kind] then
                featurecache[kind] = fonts.otf.features.collect_ligatures(tfmdata,kind)
                -- to be tested: only collect internal
                -- featurecache[kind] = fonts.otf.features.collect_ligatures(tfmdata,kind,true) --
            end
            local lookups = otfdata.luatex.internals[lookups[1]].lookups
            local ligaturecache = featurecache[kind]
            for i=1,#lookups do
                local ligatures = ligaturecache[lookups[i]]
                if ligatures and ligatures[start.char] then
                    ligatures = ligatures[start.char]
                    local s = start.next
                    while s do
                        if characters[s.char].class == 'mark' then
                            s = s.next
                        else
                            local lg = ligatures[1][s.char]
                            if not lg then
                                break
                            else
                                ligatures = lg
                                if s == stop then
                                    break
                                else
                                    s = s.next
                                end
                            end
                        end
                    end
                    if ligatures[2] then
                        if fonts.otf.trace_ligatures then
                            report("otf chain",format("%s: replacing character %s by ligature",kind,start.char))
                        end
                        return toligature(start,stop,ligatures[2],flags[1])
                    end
                    break
                end
            end
        end
        return stop
    end

    function chainprocs.gpos_mark2base(start,stop,kind,lookupname,sequence,lookups)
        local component = start.next
        if component and component.id == glyph and component.font == currentfont and marks[component.char] then
            local char = start.char
            local anchortag = sequence[1][char]
            if anchortag == true then
                local classes = otfdata.anchor_classes
                for k=1,#classes do
                    local v = classes[k]
                    if v.lookup == lookupname and v.type == kind then
                        anchortag = v.name
                        sequence[1][char] = anchortag
                        break
                    end
                end
            end
            if anchortag ~= true then
                local glyph = glyphs[characters[char].index]
                if glyph.anchors and glyph.anchors[anchortag] then
                    local trace = fonts.otf.trace_anchors
                    local last, done = start, false
                    local baseanchors = glyph.anchors['basechar'][anchortag]
                    while true do
                        local nextchar = component.char
                        local charnext = characters[nextchar]
                        local markanchors = glyphs[charnext.index].anchors['mark'][anchortag]
                        if markanchors then
                            for anchor,data in pairs(markanchors) do
                                local ba = baseanchors[anchor]
                                if ba then
                                    local dx = tex.scale(ba.x-data.x, tfmdata.factor)
                                    local dy = tex.scale(ba.y-data.y, tfmdata.factor)
                                    component.xoffset = start.xoffset - dx
                                    component.yoffset = start.yoffset + dy
                                    if trace then
                                        report("otf chain",format("%s: anchoring mark %s to basechar %s => (%s,%s) => (%s,%s)",kind,component.char,start.char,dx,dy,component.xoffset,component.yoffset))
                                    end
                                    done = true
                                    break
                                end
                            end
                        end
                        last = component
                        component = component.next
                        if component and component.id == glyph and component.font == currentfont and marks[component.char] then
                            -- ok
                        else
                            break
                        end
                    end
                    return last, done
                end
            end
        end
        return start, false
    end

    function chainprocs.gpos_mark2ligature(start,stop,kind,lookupname,sequence,lookups)
        local component = start.next
        if component and component.id == glyph and component.font == currentfont and marks[component.char] then
            local char = start.char
            local anchortag = sequence[1][char]
            if anchortag == true then
                local classes = otfdata.anchor_classes
                for k=1,#classes do
                    local v = classes[k]
                    if v.lookup == lookupname and v.type == kind then
                        anchortag = v.name
                        sequence[1][char] = anchortag
                        break
                    end
                end
            end
            if anchortag ~= true then
                local glyph = glyphs[characters[char].index]
                if glyph.anchors and glyph.anchors[anchortag] then
                    local trace = fonts.otf.trace_anchors
                    local done = false
                    local last = start
                    local baseanchors = glyph.anchors['baselig'][anchortag]
                    while true do
                        local nextchar = component.char
                        local charnext = characters[nextchar]
                        local markanchors = glyphs[charnext.index].anchors['mark'][anchortag]
                        if markanchors then
                            for anchor,data in pairs(markanchors) do
                                local ba = baseanchors[anchor]
                                if ba then
                                    local n = has_attribute(component,marknumber)
                                    local ban = ba[n]
                                    if ban then
                                        local dx = tex.scale(ban.x-data.x, tfmdata.factor)
                                        local dy = tex.scale(ban.y-data.y, tfmdata.factor)
                                        component.xoffset = start.xoffset - dx
                                        component.yoffset = start.yoffset + dy
                                        if trace then
                                            report("otf chain",format("%s: anchoring mark %s to baselig %s => (%s,%s) => (%s,%s)",kind,component.char,start.char,dx,dy,component.xoffset,component.yoffset))
                                        end
                                        done = true
                                        break
                                    end
                                end
                            end
                        end
                        last = component
                        component = component.next
                        if component and component.id == glyph and component.font == currentfont and marks[component.char] then
                            -- ok
                        else
                            break
                        end
                    end
                    return last, done
                end
            end
        end
        return start, false
    end

    function chainprocs.gpos_mark2mark(start,stop,kind,lookupname,sequence,lookups)
        local component = start.next
        if component and component.id == glyph and component.font == currentfont and marks[component.char] then
            local char = start.char
            local anchortag = sequence[1][char]
            if anchortag == true then
                local classes = otfdata.anchor_classes
                for k=1,#classes do
                    local v = classes[k]
                    if v.lookup == lookupname and v.type == kind then
                        anchortag = v.name
                        sequence[1][char] = anchortag
                        break
                    end
                end
            end
            local baseattr = has_attribute(start,marknumber)
            local markattr = has_attribute(component,marknumber)
            if baseattr == markattr and anchortag ~= true then
                local glyph = glyphs[characters[char].index]
                if glyph.anchors and glyph.anchors[anchortag] then
                    local trace = fonts.otf.trace_anchors
                    local last, done = false
                    local baseanchors = glyph.anchors['basemark'][anchortag]
                    while true do
                        local nextchar = component.char
                        local charnext = characters[nextchar]
                        local markanchors = glyphs[charnext.index].anchors['mark'][anchortag]
                        if markanchors then
                            for anchor,data in pairs(markanchors) do
                                local ba = baseanchors[anchor]
                                if ba then
                                    local dx = tex.scale(ba.x-data.x, tfmdata.factor)
                                    local dy = tex.scale(ba.y-data.y, tfmdata.factor)
                                    component.xoffset = start.xoffset - dx
                                    component.yoffset = start.yoffset + dy
                                    if trace then
                                        report("otf chain",format("%s: anchoring mark %s to basemark %s => (%s,%s) => (%s,%s)",kind,component.char,start.char,dx,dy,component.xoffset,component.yoffset))
                                    end
                                    done = true
                                    break
                                end
                            end
                        end
                        last = component
                        component = component.next
                        if component and component.id == glyph and component.font == currentfont and marks[component.char] then
                            markattr = has_attribute(component,marknumber)
                            if baseattr ~= markattr then
                                break
                            end
                        else
                            break
                        end
                    end
                    return last, done
                end
            end
        end
        return start, false
    end

    function chainprocs.gpos_cursive(start,stop,kind,lookupname,sequence,lookups)
        report("otf chain","chainproc gpos_cursive not yet supported")
        return start
    end
    function chainprocs.gpos_single(start,stop,kind,lookupname,sequence,lookups)
        report("otf process","chainproc gpos_single not yet supported")
        return start
    end
    function chainprocs.gpos_pair(start,stop,kind,lookupname,sequence,lookups)
        report("otf process","chainproc gpos_pair not yet supported")
        return start
    end

    function chainprocs.self(start,stop,kind,lookupname,sequence,lookups)
        report("otf process","self refering lookup cannot happen")
        return stop
    end

    function fonts.otf.features.process.contextchain(start,kind,lookupname,contextdata)
        local done = false
        local contexts = contextdata.lookups
        local flags = contextdata.flags
        local skipmark, skipligature, skipbase = unpack(flags)
        for k=1,#contexts do
            local match, stop = true, start
            local rule, lookuptype, sequence, before, after, lookups = unpack(contexts[k])
            if #sequence > 0 then
                if #sequence == 1 then
                    match = sequence[1][start.char]
                else -- n = #sequence -> faster
                    for n=1,#sequence do
                        if stop and stop.id == glyph and stop.font == currentfont then
                            local char = stop.char
                            local class = characters[char].class
                            if class == skipmark or class == skipligature or class == skipbase then
                                -- skip 'm
                            elseif sequence[n][char] then
                                if n < #sequence then
                                    stop = stop.next
                                end
                            else
                                match = false break
                            end
                        else
                            match = false break
                        end
                    end
                end
            end
            if match and #before > 0 then
                local prev = start.prev
                if prev then
                    if #before == 1 then
                        match = prev.id == glyph and prev.font == currentfont and before[1][prev.char]
                    else
                        for n=#before,1 do
                            if prev then
                                if prev.id == glyph and prev.font == currentfont then -- normal char
                                    local char = prev.char
                                    local class = characters[char].class
                                    if class == skipmark or class == skipligature or class == skipbase then
                                        -- skip 'm
                                    elseif not before[n][char] then
                                        match = false break
                                    end
                                elseif not before[n][32] then
                                    match = false break
                                end
                                prev = prev.prev
                            elseif not before[n][32] then
                                match = false break
                            end
                        end
                    end
                elseif #before == 1 then
                    match = before[1][32]
                else
                    for n=#before,1 do
                        if not before[n][32] then
                            match = false break
                        end
                    end
                end
            end
            if match and #after > 0 then
                local next = stop.next
                if next then
                    if #after == 1 then
                        match = next.id == glyph and next.font == currentfont and after[1][next.char]
                    else
                        for n=1,#after do
                            if next then
                                if next.id == glyph and next.font == currentfont then -- normal char
                                    local char = next.char
                                    local class = characters[char].class
                                    if class == skipmark or class == skipligature or class == skipbase then
                                        -- skip 'm
                                    elseif not after[n][char] then
                                        match = false break
                                    end
                                elseif not after[n][32] then -- brrr
                                    match = false break
                                end
                                next = next.next
                            elseif not after[n][32] then
                                match = false break
                            end
                        end
                    end
                elseif #after == 1 then
                    match = after[1][32]
                else
                    for n=1,#after do
                        if not after[n][32] then
                            match = false break
                        end
                    end
                end
            end
            if match then
                local trace = fonts.otf.trace_contexts
                if trace then
                    report("otf chain",format("%s: rule %s of %s matches %s times at char %s (%s) lookuptype %s",kind,rule,lookupname,#sequence,char,utf.char(char),lookuptype))
                end
                if lookups then
                    local cp = chainprocs[lookuptype]
                    if cp then
                        start = cp(start,stop,kind,lookupname,sequence,lookups,flags)
                    else
                        report("otf chain",format("%s: lookuptype %s not supported yet for %s",kind,lookuptype,lookupname))
                    end
                elseif trace then
                    report("otf chain",format("%s: skipping match for %s",kind,lookupname))
                end
                done = true
                break
            end
        end
        return start, done
    end

    function fonts.otf.features.process.reversecontextchain(start,kind,lookupname,contextdata)
        -- there is only a single substitution here so it is a simple case of the normal one
        -- sequence is one character here and we swap the rest
        local done = false
        local contexts = contextdata.lookups
        local flags = contextdata.flags
        local skipmark, skipligature, skipbase = unpack(flags)
        for k=1,#contexts do
            local match, stop = true, start
            local rule, lookuptype, sequence, before, after, lookups = unpack(contexts[k])
            match = sequence[1][start.char]
            if match and #after > 0 then
                local prev = start.prev
                if prev then
                    if #after == 1 then
                        match = prev.id == glyph and prev.font == currentfont and after[1][prev.char]
                    else
                        for n=1,#after do
                            if prev then
                                if prev.id == glyph and prev.font == currentfont then -- normal char
                                    local char = prev.char
                                    local class = characters[char].class
                                    if class == skipmark or class == skipligature or class == skipbase then
                                        -- skip 'm
                                    elseif not after[n][char] then
                                        match = false break
                                    end
                                elseif not after[n][32] then
                                    match = false break
                                end
                                prev = prev.prev
                            elseif not after[n][32] then
                                match = false break
                            end
                        end
                    end
                elseif #after == 1 then
                    match = after[1][32]
                else
                    for n=#after,1 do
                        if not after[n][32] then
                            match = false break
                        end
                    end
                end
            end
            if match and #before > 0 then
                local next = stop.next
                if next then
                    if #after == 1 then
                        match = next.id == glyph and next.font == currentfont and before[1][next.char]
                    else
                        for n=#before,1 do
                            if next then
                                if next.id == glyph and next.font == currentfont then -- normal char
                                    local char = next.char
                                    local class = characters[char].class
                                    if class == skipmark or class == skipligature or class == skipbase then
                                        -- skip 'm
                                    elseif not before[n][char] then
                                        match = false break
                                    end
                                elseif not before[n][32] then -- brrr
                                    match = false break
                                end
                                next = next.next
                            elseif not before[n][32] then
                                match = false break
                            end
                        end
                    end
                elseif #before == 1 then
                    match = before[1][32]
                else
                    for n=1,#before do
                        if not before[n][32] then
                            match = false break
                        end
                    end
                end
            end
            if match then
                local trace = fonts.otf.trace_contexts
                if trace then
                    report("otf reverse chain",format("%s: rule %s of %s matches %s times at char %s (%s) lookuptype %s",kind,rule,lookupname,#sequence,char,utf.char(char),lookuptype))
                end
                if lookups then
                    local cp = chainprocs[lookuptype]
                    if cp then
                        start = cp(start,stop,kind,lookupname,sequence,lookups,flags)
                    else
                        report("otf reverse chain",format("%s: lookuptype %s not supported yet for %s",kind,lookuptype,lookupname))
                    end
                elseif trace then
                    report("otf reverse chain",format("%s: skipping match for %s",kind,lookupname))
                end
                done = true
                break
            end
        end
        return start, done
    end

    fonts.otf.features.process.gsub_context             = fonts.otf.features.process.contextchain
    fonts.otf.features.process.gsub_contextchain        = fonts.otf.features.process.contextchain
    fonts.otf.features.process.gsub_reversecontextchain = fonts.otf.features.process.reversecontextchain

    fonts.otf.features.process.gpos_contextchain        = fonts.otf.features.process.contextchain
    fonts.otf.features.process.gpos_context             = fonts.otf.features.process.contextchain

end

do

    local process = fonts.otf.features.process.feature

    function fonts.methods.node.otf.aalt(head,font) return process(head,font,'aalt') end
    function fonts.methods.node.otf.afrc(head,font) return process(head,font,'afrc') end
    function fonts.methods.node.otf.akhn(head,font) return process(head,font,'akhn') end
    function fonts.methods.node.otf.c2pc(head,font) return process(head,font,'c2pc') end
    function fonts.methods.node.otf.c2sc(head,font) return process(head,font,'c2sc') end
    function fonts.methods.node.otf.calt(head,font) return process(head,font,'calt') end
    function fonts.methods.node.otf.case(head,font) return process(head,font,'case') end
    function fonts.methods.node.otf.ccmp(head,font) return process(head,font,'ccmp') end
    function fonts.methods.node.otf.clig(head,font) return process(head,font,'clig') end
    function fonts.methods.node.otf.cpsp(head,font) return process(head,font,'cpsp') end
    function fonts.methods.node.otf.cswh(head,font) return process(head,font,'cswh') end
    function fonts.methods.node.otf.curs(head,font) return process(head,font,'curs') end
    function fonts.methods.node.otf.dlig(head,font) return process(head,font,'dlig') end
    function fonts.methods.node.otf.dnom(head,font) return process(head,font,'dnom') end
    function fonts.methods.node.otf.expt(head,font) return process(head,font,'expt') end
    function fonts.methods.node.otf.fin2(head,font) return process(head,font,'fin2') end
    function fonts.methods.node.otf.fin3(head,font) return process(head,font,'fin3') end
    function fonts.methods.node.otf.fina(head,font) return process(head,font,'fina',3) end
    function fonts.methods.node.otf.frac(head,font) return process(head,font,'frac') end
    function fonts.methods.node.otf.fwid(head,font) return process(head,font,'fwid') end
    function fonts.methods.node.otf.haln(head,font) return process(head,font,'haln') end
    function fonts.methods.node.otf.hist(head,font) return process(head,font,'hist') end
    function fonts.methods.node.otf.hkna(head,font) return process(head,font,'hkna') end
    function fonts.methods.node.otf.hlig(head,font) return process(head,font,'hlig') end
    function fonts.methods.node.otf.hngl(head,font) return process(head,font,'hngl') end
    function fonts.methods.node.otf.hwid(head,font) return process(head,font,'hwid') end
    function fonts.methods.node.otf.init(head,font) return process(head,font,'init',1) end
    function fonts.methods.node.otf.isol(head,font) return process(head,font,'isol',4) end
    function fonts.methods.node.otf.ital(head,font) return process(head,font,'ital') end
    function fonts.methods.node.otf.jp78(head,font) return process(head,font,'jp78') end
    function fonts.methods.node.otf.jp83(head,font) return process(head,font,'jp83') end
    function fonts.methods.node.otf.jp90(head,font) return process(head,font,'jp90') end
    function fonts.methods.node.otf.kern(head,font) return process(head,font,'kern') end
    function fonts.methods.node.otf.liga(head,font) return process(head,font,'liga') end
    function fonts.methods.node.otf.lnum(head,font) return process(head,font,'lnum') end
    function fonts.methods.node.otf.locl(head,font) return process(head,font,'locl') end
    function fonts.methods.node.otf.mark(head,font) return process(head,font,'mark') end
    function fonts.methods.node.otf.med2(head,font) return process(head,font,'med2') end
    function fonts.methods.node.otf.medi(head,font) return process(head,font,'medi',2) end
    function fonts.methods.node.otf.mgrk(head,font) return process(head,font,'mgrk') end
    function fonts.methods.node.otf.mkmk(head,font) return process(head,font,'mkmk') end
    function fonts.methods.node.otf.nalt(head,font) return process(head,font,'nalt') end
    function fonts.methods.node.otf.nlck(head,font) return process(head,font,'nlck') end
    function fonts.methods.node.otf.nukt(head,font) return process(head,font,'nukt') end
    function fonts.methods.node.otf.numr(head,font) return process(head,font,'numr') end
    function fonts.methods.node.otf.onum(head,font) return process(head,font,'onum') end
    function fonts.methods.node.otf.ordn(head,font) return process(head,font,'ordn') end
    function fonts.methods.node.otf.ornm(head,font) return process(head,font,'ornm') end
    function fonts.methods.node.otf.pnum(head,font) return process(head,font,'pnum') end
    function fonts.methods.node.otf.pref(head,font) return process(head,font,'pref') end
    function fonts.methods.node.otf.pres(head,font) return process(head,font,'pres') end
    function fonts.methods.node.otf.pstf(head,font) return process(head,font,'pstf') end
    function fonts.methods.node.otf.rlig(head,font) return process(head,font,'rlig') end
    function fonts.methods.node.otf.rphf(head,font) return process(head,font,'rphf') end
    function fonts.methods.node.otf.salt(head,font) return process(head,font,'calt') end
    function fonts.methods.node.otf.sinf(head,font) return process(head,font,'sinf') end
    function fonts.methods.node.otf.smcp(head,font) return process(head,font,'smcp') end
    function fonts.methods.node.otf.smpl(head,font) return process(head,font,'smpl') end
    function fonts.methods.node.otf.ss01(head,font) return process(head,font,'ss01') end
    function fonts.methods.node.otf.ss02(head,font) return process(head,font,'ss02') end
    function fonts.methods.node.otf.ss03(head,font) return process(head,font,'ss03') end
    function fonts.methods.node.otf.ss04(head,font) return process(head,font,'ss04') end
    function fonts.methods.node.otf.ss05(head,font) return process(head,font,'ss05') end
    function fonts.methods.node.otf.ss06(head,font) return process(head,font,'ss06') end
    function fonts.methods.node.otf.ss07(head,font) return process(head,font,'ss07') end
    function fonts.methods.node.otf.ss08(head,font) return process(head,font,'ss08') end
    function fonts.methods.node.otf.ss09(head,font) return process(head,font,'ss09') end
    function fonts.methods.node.otf.subs(head,font) return process(head,font,'subs') end
    function fonts.methods.node.otf.sups(head,font) return process(head,font,'sups') end
    function fonts.methods.node.otf.swsh(head,font) return process(head,font,'swsh') end
    function fonts.methods.node.otf.titl(head,font) return process(head,font,'titl') end
    function fonts.methods.node.otf.tnam(head,font) return process(head,font,'tnam') end
    function fonts.methods.node.otf.tnum(head,font) return process(head,font,'tnum') end
    function fonts.methods.node.otf.trad(head,font) return process(head,font,'trad') end
    function fonts.methods.node.otf.unic(head,font) return process(head,font,'unic') end
    function fonts.methods.node.otf.zero(head,font) return process(head,font,'zero') end

end

--~ function fonts.initializers.node.otf.install(feature,attribute)
--~     function fonts.initializers.node.otf[feature](tfm,value) return fonts.otf.features.prepare.feature(tfm,feature,value) end
--~     function fonts.methods.node.otf[feature]     (head,font) return fonts.otf.features.process.feature(head,font,feature,attribute) end
--~ end

-- common stuff

function fonts.otf.features.language(tfm,value)
    if value then
        value = value:lower()
        if fonts.otf.tables.languages[value] then
            tfm.language = value
        end
    end
end

function fonts.otf.features.script(tfm,value)
    if value then
        value = value:lower()
        if fonts.otf.tables.scripts[value] then
            tfm.script = value
        end
    end
end

function fonts.otf.features.mode(tfm,value)
    if value then
        tfm.mode = value:lower()
    end
end

fonts.initializers.base.otf.language = fonts.otf.features.language
fonts.initializers.base.otf.script   = fonts.otf.features.script
fonts.initializers.base.otf.mode     = fonts.otf.features.mode
fonts.initializers.base.otf.method   = fonts.otf.features.mode

fonts.initializers.node.otf.language = fonts.otf.features.language
fonts.initializers.node.otf.script   = fonts.otf.features.script
fonts.initializers.node.otf.mode     = fonts.otf.features.mode
fonts.initializers.node.otf.method   = fonts.otf.features.mode

fonts.initializers.node.otf.trep         = fonts.initializers.base.otf.trep
fonts.initializers.node.otf.tlig         = fonts.initializers.base.otf.tlig
fonts.initializers.node.otf.texquotes    = fonts.initializers.base.otf.texquotes
fonts.initializers.node.otf.texligatures = fonts.initializers.base.otf.texligatures

-- we need this because fonts can be bugged

-- \definefontfeature[calt][language=nld,script=latn,mode=node,calt=yes,clig=yes,rlig=yes]
-- \definefontfeature[dflt][language=nld,script=latn,mode=node,calt=no, clig=yes,rlig=yes]
-- \definefontfeature[fixd][language=nld,script=latn,mode=node,calt=no, clig=yes,rlig=yes,ignoredrules={44,45,47}]

-- \starttext

-- {\type{dflt:}\font\test=ZapfinoExtraLTPro*dflt at 24pt \test \char57777\char57812 c/o} \endgraf
-- {\type{calt:}\font\test=ZapfinoExtraLTPro*calt at 24pt \test \char57777\char57812 c/o} \endgraf
-- {\type{fixd:}\font\test=ZapfinoExtraLTPro*fixd at 24pt \test \char57777\char57812 c/o} \endgraf

-- \stoptext

--~ table.insert(fonts.triggers,"ignoredrules")

--~ function fonts.initializers.node.otf.ignoredrules(tfmdata,value)
--~     if value then
--~         -- these tests must move !
--~         tfmdata.unique = tfmdata.unique or { }
--~         tfmdata.unique.ignoredrules = tfmdata.unique.ignoredrules or { }
--~         local ignored = tfmdata.unique.ignoredrules
--~         -- value is already ok now
--~         for s in string.gmatch(value:gsub("[{}]","")..",", "%s*(.-),") do
--~             ignored[tonumber(s)] = true
--~         end
--~     end
--~ end

fonts.initializers.base.otf.equaldigits = fonts.initializers.common.equaldigits
fonts.initializers.node.otf.equaldigits = fonts.initializers.common.equaldigits

fonts.initializers.base.otf.lineheight  = fonts.initializers.common.lineheight
fonts.initializers.node.otf.lineheight  = fonts.initializers.common.lineheight

fonts.initializers.base.otf.complement  = fonts.initializers.common.complement
fonts.initializers.node.otf.complement  = fonts.initializers.common.complement

-- temp hack, may change

function fonts.initializers.base.otf.kern(tfmdata,value)
    fonts.otf.features.prepare_base_kerns(tfmdata,'kern',value)
end

--~ fonts.initializers.node.otf.kern = fonts.initializers.base.otf.kern

-- there is no real need to register features here, only the defaults; supported
-- features are part of the font data

-- fonts.otf.features.register('tlig',true)
-- fonts.otf.features.register('liga',true)
-- fonts.otf.features.register('kern',true)

-- bonus function

function fonts.otf.name_to_slot(name) -- todo: afm en tfm
    local tfmdata = fonts.tfm.id[font.current()]
    if tfmdata and tfmdata.shared then
        local otfdata = tfmdata.shared.otfdata
        if otfdata and otfdata.luatex then
            return otfdata.luatex.unicodes[name]
        end
    end
    return nil
end

function fonts.otf.char(n) -- todo: afm en tfm
    if type(n) == "string" then
        n = fonts.otf.name_to_slot(n)
    end
    if n then
        tex.sprint(tex.ctxcatcodes,string.format("\\char%s ",n))
    end
end

--~ function fonts.otf.name_to_table(name)
--~     lcoal temp, result = { }
--~     local tfmdata = fonts.tfm.id[font.current()]
--~     if tfmdata and tfmdata.shared then
--~         local otfdata = tfmdata.shared.otfdata
--~         if otfdata and otfdata.luatex then
--~             for k,v in pairs(otfdata.glyphs) do
--~                 if v.name:find(name) then
--~                     temp[v.name] = v.unicodeenc
--~                 end
--~             end
--~         end
--~     end
--~     for k,v in pairs(table.sortedkeys(temp)) do
--~         result[#result+1] = { v, temp[v] }
--~     end
--~     return result
--~ end

-- Here we plug in some analyzing code

-- will move to font-tfm

do

    local glyph           = node.id('glyph')
    local glue            = node.id('glue')
    local penalty         = node.id('penalty')

    local fontdata        = fonts.tfm.id
    local set_attribute   = node.set_attribute
    local has_attribute   = node.has_attribute
    local state           = attributes.numbers['state'] or 100

    -- in the future we will use language/script attributes instead of the
    -- font related value, but then we also need dynamic features which is
    -- somewhat slower; and .. we need a chain of them

    function fonts.initializers.node.otf.analyze(tfm,value)
        local script, language = tfm.script, tfm.language
        local action = fonts.analyzers.initializers[script]
        if action then
            if type(action) == "function" then
                return action(tfm,value)
            elseif action[language] then
                return action[language](tfm,value)
            end
        end
        return nil
    end

    function fonts.methods.node.otf.analyze(head,font)
        local tfmdata = fontdata[font]
        local script, language = fontdata[font].script, fontdata[font].language
        local action = fonts.analyzers.methods[script]
        if action then
            if type(action) == "function" then
                return action(head,font)
            elseif action[language] then
                return action[language](head,font)
            end
        end
        return head, false
    end

    fonts.otf.features.register("analyze",true) -- we always analyze
    table.insert(fonts.triggers,"analyze")      -- we need a proper function for doing this

    -- latin

    fonts.analyzers.methods.latn = fonts.analyzers.aux.setstate

    -- arab / todo: 0640 tadwil

    -- this info eventually will go into char-def

    local isol = {
        [0x0621] = true,
    }

    local isol_fina = {
        [0x0622] = true, [0x0623] = true, [0x0624] = true, [0x0625] = true, [0x0627] = true, [0x062F] = true,
        [0x0630] = true, [0x0631] = true, [0x0632] = true,
        [0x0648] = true,
        [0xFEF5] = true, [0xFEF7] = true, [0xFEF9] = true, [0xFEFB] = true,
    }

    local isol_fina_medi_init = {
        [0x0626] = true, [0x0628] = true, [0x0629] = true, [0x062A] = true, [0x062B] = true, [0x062C] = true, [0x062D] = true, [0x062E] = true,
        [0x0633] = true, [0x0634] = true, [0x0635] = true, [0x0636] = true, [0x0637] = true, [0x0638] = true, [0x0639] = true, [0x063A] = true,
        [0x0641] = true, [0x0642] = true, [0x0643] = true, [0x0644] = true, [0x0645] = true, [0x0646] = true, [0x0647] = true, [0x0649] = true, [0x064A] = true,
        [0x067E] = true,
        [0x0686] = true,
    }

    local arab_warned = { }

    local function warning(current,what)
        local char = current.char
        if not arab_warned[char] then
            log.report("analyze",string.format("arab: character %s (0x%04X) has no %s class", char, char, what))
            arab_warned[char] = true
        end
    end

    local fcs = fonts.color.set
    local fcr = fonts.color.reset

    function fonts.analyzers.methods.nocolor(head,font)
        for n in nodes.traverse(glyph) do
            if not font or n.font == font then
                fcr(n)
            end
        end
        return head, true
    end

    function fonts.analyzers.methods.arab(head,font) -- maybe make a special version with no trace
        local characters = fontdata[font].characters
        local first, last, current, done = nil, nil, head, false
        local trace = fonts.color.trace
    --~ local laststate = 0
        local function finish()
            if last then
                if first == last then
                    if isol_fina_medi_init[first.char] or isol_fina[first.char] then
                        set_attribute(first,state,4) -- isol
                        if trace then fcs(first,"font:isol") end
                    else
                        warning(first,"isol")
                        set_attribute(first,state,0) -- error
                        if trace then fcr(first) end
                    end
                else
                    if isol_fina_medi_init[last.char] or isol_fina[last.char] then -- why isol here ?
                    -- if laststate == 1 or laststate == 2 or laststate == 4 then
                        set_attribute(last,state,3) -- fina
                        if trace then fcs(last,"font:fina") end
                    else
                        warning(last,"fina")
                        set_attribute(last,state,0) -- error
                        if trace then fcr(last) end
                    end
                end
                first, last = nil, nil
            elseif first then
                -- first and last are either both set so we never com here
                if isol_fina_medi_init[first.char] or isol_fina[first.char] then
                    set_attribute(first,state,4) -- isol
                    if trace then fcs(first,"font:isol") end
                else
                    warning(first,"isol")
                    set_attribute(first,state,0) -- error
                    if trace then fcr(first) end
                end
                first = nil
            end
        --~ laststate = 0
        end
        while current do
            if current.id == glyph and current.font == font then
                done = true
                local char = current.char
                if characters[char].class == "mark" then -- marks are now in components
                    set_attribute(current,state,5) -- mark
                    if trace then fcs(current,"font:mark") end
                elseif isol[char] then
                    finish()
                    set_attribute(current,state,4) -- isol
                    if trace then fcs(current,"font:isol") end
                    first, last = nil, nil
                --~ laststate = 0
                elseif not first then
                    if isol_fina_medi_init[char] then
                        set_attribute(current,state,1) -- init
                        if trace then fcs(current,"font:init") end
                        first, last = first or current, current
                    --~ laststate = 1
                    elseif isol_fina[char] then
                        set_attribute(current,state,4) -- isol
                        if trace then fcs(current,"font:isol") end
                        first, last = nil, nil
                    --~ laststate = 0
                    else -- no arab
                        finish()
                    end
                elseif isol_fina_medi_init[char] then
                    first, last = first or current, current
                    set_attribute(current,state,2) -- medi
                    if trace then fcs(current,"font:medi") end
                    --~ laststate = 2
                elseif isol_fina[char] then
                    -- if not laststate == 1 then
                    if not has_attribute(last,state,1) then
                        -- tricky, we need to check what last may be !
                        set_attribute(last,state,2) -- medi
                        if trace then fcs(last,"font:medi") end
                    end
                    set_attribute(current,state,3) -- fina
                    if trace then fcs(current,"font:fina") end
                    first, last = nil, nil
                --~ laststate = 0
                elseif char >= 0x0600 and char <= 0x06FF then
                    if trace then fcs(current,"font:rest") end
                    finish()
                else --no
                    finish()
                end
            else
                finish()
            end
            current = current.next
        end
        finish()
        return head, done
    end

    -- han (chinese) (unfinished)

    -- this info eventually will go into char-def

    -- list by Zhichu Chen

    local end_punctuation = table.tohash {
        0x3002, -- 。
        0xFF0E, -- ．
        0xFF0C, -- ，
        0x3001, -- 、
        0xFF1B, -- ；
        0xFF1F, -- ？
        0xFF01, -- ！
    }

    local begin_punctuation = table.tohash {
        0xFF1A, -- ：
        0x2236, -- ∶
        0xFF0C, -- ，
    }

    local left_punctuation = table.tohash {
        0x2018, -- ‘
        0x201C, -- “
        0x300C, -- 「   left quote
        0x300E, -- 『   left double quote
        0x3008, -- 〈   Left book quote
        0x300A, -- 《   Left double book quote
        0x3014, -- 〔   left book quote
        0x3016, --〖   left double book quote
        0x3010, -- 【   left double book quote
        0xFF08, -- （   left parenthesis
        0xFF3B, -- ［   left square brackets
        0xFF5B, -- ｛   left curve bracket
    }

    local right_punctuation = table.tohash {
        0x2019, -- ’   right quote, right
        0x201D, -- ”   right double quote
        0x300D, -- 」   right quote, right
        0x300F, -- 』   right double quote
        0x3009, -- 〉   book quote
        0x300B, -- 》   double book quote
        0x3015, -- 〕   right book quote
        0x3017, -- 〗  right double book quote
        0x3011, -- 】   right double book quote
        0xFF09, -- ）   right parenthesis
        0xFF3D, -- ］   right square brackets
        0xFF5D, -- ｝   right curve brackets
    }

    -- the characters below are always appear in a double form, so there
    -- will be two Chinese ellipsis characters together that denote
    -- ellipsis marks and it is not allowed to break between them

    local hyphenation = table.tohash {
        0x2026, -- …   ellipsis
        0x2014, -- —   hyphen
    }

    -- an alternative is to deal with it in the line breaker

    local function is_han_character(char)
        return
            (char>=0x04E00 and char<=0x09FFF) or
            (char>=0x03400 and char<=0x04DFF) or
            (char>=0x20000 and char<=0x2A6DF) or
            (char>=0x0F900 and char<=0x0FAFF) or
            (char>=0x2F800 and char<=0x2FA1F)
    end

    -- end_punctuation begin_punctuation right_punctuation
    -- left_punctuation
    -- hyphenation

    -- will move to node-ini :

    local allowbreak = node.new("penalty")   allowbreak.penalty =  -100
    local nobreak    = node.new("penalty")   nobreak.penalty    = 10000

    fonts.analyzers.methods.stretch_hang = true

    -- for the moment we insert potential breakpoinst here, but eventually
    -- it wil become either a mkiv feature or an attribute, so this is
    -- experimental

    function fonts.analyzers.methods.hang(head,font) -- maybe make a special version with no trace
        local characters = fontdata[font].characters
        local current, last, done, stretch, prevchinese = head, nil, false, 0, false
        local trace = fonts.color.trace
        if fonts.analyzers.methods.stretch_hang then
            stretch = fontdata[font].parameters[6]
        end
        while current do
            if current.id == glyph then
                if current.font == font then
                    if prevchinese then
                        local temp = current.prev
                        while temp and temp.id == glue and temp.spec and temp.spec.width > 0 do
                            head, temp = nodes.delete(head,temp)
                            if temp then temp = temp.prev end
                        end
                    end
                    last = current -- faster that current.next
                    local char = current.char
                    -- penalty before break
                    if left_punctuation[char] then -- (
                        set_attribute(current,state,1)
                        if trace then fcs(current,"font:init") end
                        head, current = node.insert_after(head,current,node.copy(nobreak))
                        done = true
                    elseif right_punctuation[char] then -- )
                        set_attribute(current,state,2)
                        if trace then fcs(current,"font:fina") end
                        if prevchinese then
                            head, current = node.insert_before(head,current.prev,node.copy(nobreak))
                        end
                        current, done = last, true
                    elseif begin_punctuation[char] then -- :
                        set_attribute(current,state,1)
                        if trace then fcs(current,"font:init") end
                        if prevchinese then
                            head, current = node.insert_before(head,current.prev,node.copy(nobreak))
                        end
                        current, done = last, true
                    elseif end_punctuation[char] then -- .
                        set_attribute(current,state,2)
                        if trace then fcs(current,"font:fina") end
                        if prevchinese then
                            head, current = node.insert_before(head,current.prev,node.copy(nobreak))
                        end
                        current, done = last, true
                    elseif hyphenation[char] then
                        set_attribute(current,state,3) -- xxxx
                        local prev, next = current.prev, current.next
                        if next and next.id == glyph and hyphenation[next.char] then
                            if trace then fcs(current,"font:medi") fcs(next,"font:medi")end -- we need nice names
                            if prev then
                                if prevchinese then
                                    head, current = node.insert_before(head,current.prev,node.copy(nobreak))
                                end
                                current = last
                                head, current = node.insert_before(head,current,node.copy(nobreak))
                            end
                        end
                        current, done = last.next, true
                --  elseif is_han_character(char) then
                    end
                    head, current = node.insert_after(head,current,nodes.glue(0,stretch,0))
                    prevchinese = true
                else
                    prevchinese = false
                end
            end
            if current then
                current = current.next
            end
        end
        return head, done
    end



    fonts.analyzers.methods.hani = fonts.analyzers.methods.hang

end

-- experimental and will probably change

function fonts.install_feature(type,...)
    if fonts[type] and fonts[type].install_feature then
        fonts[type].install_feature(...)
    end
end
function fonts.otf.install_feature(tag)
    fonts.methods.node.otf     [tag] = function(head,font) return fonts.otf.features.process.feature(head,font,tag) end
    fonts.initializers.node.otf[tag] = function(tfm,value) return fonts.otf.features.prepare.feature(tfm,tag,value) end
end

--~ exclam     + quoteleft  => exclamdown
--~ question   + quoteleft  => questiondown

--~ less       + less       => guillemotleft
--~ greater    + greater    => guillemotright

--~ I          + J          => IJ
--~ f          + f          => ff
--~ f          + i          => fi
--~ f          + l          => fl
--~ f          + k          => fk
--~ ff         + i          => ffi
--~ ff         + l          => ffl
--~ i          + j          => ij

--~ comma      + comma      => quotedblbase
--~ quoteleft  + quoteleft  => quotedblleft
--~ quoteright + quoteright => quotedblright

--~ hyphen     + hyphen     => endash
--~ endash     + hyphen     => emdash

