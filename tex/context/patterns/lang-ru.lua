return {
 ["comment"]="% generated by mtxrun --script pattern --convert",
 ["exceptions"]={
  ["characters"]="абвгдежзийклмнопрстуфхцчшщыьэюя",
  ["data"]="ас-бест бездн биз-нес-мен буй-нак-ске вбли-зи взба-ла-муть-ся вздрем-нешь во-до-сли-вом волж-ске воп-лем вопль вост-ра во-ткать во-ткем во-ткешь во-тку во-ткут впол-обо-ро-та впол-уха все-во-лож-ске вцспс га-рем-но-го го-ло-дра-нец грэс дву-зу-бец днепр добре-ем до-бре-ем-ся добре-ет добре-е-те до-бре-е-тесь до-бре-ет-ся добре-ешь до-бре-ешь-ся добрею до-бре-юсь добре-ют до-бре-ют-ся до-бре-сти до-бро-дят до-брось до-брось-те до-бро-сят до-бро-шу домну доп-пель драх-му дрейф-лю дрейфь-те еди-но-жды зав-сек-то-ром за-мру за-члись из-древ-ле изо-тру ин-ког-ни-то искр ка-за-шек казнь кольд-кре-мом корн-па-пир ксендз лик-бе-зом ло-шадь-ми людь-ми лю-э-сом ма-зу-те ме-ти-лам ме-ти-ла-ми мно-га-жды морщь-те на-бе-крень навз-ничь на-вскид-ку на-встре-чу нагл на-изусть на-ис-ко-сок наи-ме-нее на-ис-кось на-обо-рот на-от-рез на-супь-ся на-угад на-уголь-ник не-ост-ра нес-лась нес-лись нет-то не-уду обидь-ся обо-шлось об-ра-сти од-на-жды ослаб-ла ото-мстят ото-мщу ото-тру отру отрусь паб-ли-си-ти па-на-ме па-на-мец па-ра-так-сис пе-ре-вру пе-ре-ме-жать пе-ре-ме-жать-ся пе-ре-шла пис-чая по-все-дне-вен по-гре-мок по-до-тру по-ис-ти-не по-лу-то-ра-ста по-лу-явью по-млад-ше помни по-мнись помни-те по-мни-тесь по-мно-гу по-мру пол-вто-ро-го пол-шка-фа по-на-доб-люсь по-трафь-те преж-де прид-ти при-шла при-шлось про-тру про-хлад-ца пско-ва пыл-че раз-орем-ся раз-оре-тесь раз-орет-ся раз-орешь-ся разо-тру ра-зу-мом резв-люсь рсфср сан-узел сдрейф-лю се-го-дня сме-жат со-блю-сти со-лжешь сост-рим сост-ришь сост-рю сост-рят со-ткать со-ткем со-ткешь сотку со-ткут срос-лась срос-лись стрем-глав так-же тве-ре-зо-го те-ле-ате-лье тер-но-сли-вом троп-лю тьфу узу-фрукт умнем умнет умнете умну умру услышь-те ушла фо-то-пле-нок ца-ре-дво-рец че-рес-чур чер-но-сли-вом чресл чуж-дость шесть-де-сят юсом ядо-зу-бе ярем-но-го",
  ["n"]=184,
 },
 ["metadata"]={
  ["mnemonic"]="ru",
  ["source"]="hyph-ru.tex",
  ["texcomment"]="% This file is part of hyph-utf8 package and resulted from\
% semi-manual conversions of hyphenation patterns into UTF-8 in June 2008.\
%\
% Source: TODO:WRITEME (2003-03-10)\
% Author: Alexander I. Lebedev <swan at scon155.phys.msu.su>\
%\
% The above mentioned file should become obsolete,\
% and the author of the original file should preferaby modify this file instead.\
%\
% Modificatios were needed in order to support native UTF-8 engines,\
% but functionality (hopefully) didn't change in any way, at least not intentionally.\
% This file is no longer stand-alone; at least for 8-bit engines\
% you probably want to use loadhyph-foo.tex (which will load this file) instead.\
%\
% Modifications were done by Jonathan Kew, Mojca Miklavec & Arthur Reutenauer\
% with help & support from:\
% - Karl Berry, who gave us free hands and all resources\
% - Taco Hoekwater, with useful macros\
% - Hans Hagen, who did the unicodifisation of patterns already long before\
%               and helped with testing, suggestions and bug reports\
% - Norbert Preining, who tested & integrated patterns into TeX Live\
%\
% However, the \"copyright/copyleft\" owner of patterns remains the original author.\
%\
% The copyright statement of this file is thus:\
%\
%    Do with this file whatever needs to be done in future for the sake of\
%    \"a better world\" as long as you respect the copyright of original file.\
%    If you're the original author of patterns or taking over a new revolution,\
%    plese remove all of the TUG comments & credits that we added here -\
%    you are the Queen / the King, we are only the servants.\
%\
% If you want to change this file, rather than uploading directly to CTAN,\
% we would be grateful if you could send it to us (http://tug.org/tex-hyphen)\
% or ask for credentials for SVN repository and commit it yourself;\
% we will then upload the whole \"package\" to CTAN.\
%\
% Before a new \"pattern-revolution\" starts,\
% please try to follow some guidelines if possible:\
%\
% - \\lccode is *forbidden*, and I really mean it\
% - all the patterns should be in UTF-8\
% - the only \"allowed\" TeX commands in this file are: \\patterns, \\hyphenation,\
%   and if you really cannot do without, also \\input and \\message\
% - in particular, please no \\catcode or \\lccode changes,\
%   they belong to loadhyph-foo.tex,\
%   and no \\lefthyphenmin and \\righthyphenmin,\
%   they have no influence here and belong elsewhere\
% - \\begingroup and/or \\endinput is not needed\
% - feel free to do whatever you want inside comments\
%\
% We know that TeX is extremely powerful, but give a stupid parser\
% at least a chance to read your patterns.\
%\
% For more unformation see\
%\
%    http://tug.org/tex-hyphen\
%\
%------------------------------------------------------------------------------\
%\
% Russian hyphenation patterns, version 2003/03/10\
% Copyright 1999-2003 Alexander I. Lebedev <swan@scon155.phys.msu.su>\
%\
% This program may be distributed and/or modified under the conditions\
% of the LaTeX Project Public License, either version 1.2 or any later\
% version.\
%\
% Patterns were generated with patgen from a 990,000-word list and then\
% manually corrected.\
%\
% The program consists of the files ruhyphal.tex, cyryoal.tex and two\
% document files README.ruhyphal and hyphen.rules.  The file cyryoal.tex\
% can be regenerated using mkcyryo script (a part of ruhyphen package)\
% and the latest release of rus-ispell dictionaries\
% <ftp://scon155.phys.msu.su/pub/russian/ispell/>.",
 },
 ["patterns"]={
  ["characters"]="абвгдежзийклмнопрстуфхцчшщъыьэюяё",
  ["data"]=".аб1р .аг1ро .ади2 .аи2 .ак1р .аль3я .ар2т1о2 .ас1то .аст1р .ау2 .би2о .во2б3л .во3ж2д .го2ф .дек2 .де1кв .ди2ак .ди1о .до3п .до3т2 .епи3 .зав2р .за3м2н .за3п .иг1р .изг2 .из3н .ии2 .ик1р .ио2 .ио4на .ис3 .ле2о .ле2п3р .лес1к .ль2 .люст1 .ме2ж1у2 .ми1ом .мо2к1 .му2шт1 .на1в .на3т .на3ш2 .не3вн .не1др .не1з2 .не1сл .не1с2ц .не3т .нос1к .нук1л .обо3ж2 .ово1 .ог3н .оз4 .ос2ка .ос2п .ос3пи .от1в .от1ро .от1ру .от1уж .по3в2 .по3ж2 .поз2н .прос2 .ра2с3т .ре2бр .ре2з3в .ри2ск .ри2ч .ро2з3в .ро2с3л .ро2х .септ2 .ск2 .ст2 .су2ж .те2о3 .тиа3 .ти2г .тиг1р .ти2о .уб2 .уд2 .уе2 .уз2на .ук2 .ум2ч .уо3 .уп2 .ур2в .ус2 .ут2р .ую2 .хо2р3в .че2с1к .юс1 4а3а аа2п аа2р аа2ц а1б абе3ст а3бла аб2лю аб1ри а3бу ав1в а1ве ав3зо а1ви ави2а а1во аво1с а2вот ав1ра ав2се а2вт а1ву а2вх а3в2че 2ага ага1с2 а2гд а2гити а2гле аг2ли а2глос аг2лот 2аго а3гу а1д 2адв а2две ад2жи ади2од а2дл а2д1обл ад1ро а2д1ру аду3ч ад2ц а2дын а1е ае2го ае2ди ае2л а2еп ае2ре ае2с аза4ш3 азв2 аз3вез аз1вл азг2 аз1др аз1об аз2о1бр а2зовь а2золь а1зори аз2о1с аз1р а1и аи2г1 аи3гл а2их а1к ак1в 1акк ак2л ак3лем ако1б2 2аконс ако3т 2акри ак1с а1ла а3лаг а1ле 2алек а3ли ало1з а1лу алу2ш алуш1т а1лы а2льщ а1лю 2ама амб4 2амет а2минт ам2нет 2амо амо1з2 амои2 а2мч ана2дц а2н1а2ме а2наф ан2дра а2н1о2б ан1о2хр ан1р ан2сп анс1у ан2сур а2н1уз а1нь 2а1о ао2д ао2к ао2р ао2с аост1 а3пла ап2лом 2апо апо4вс апо3ч2т ап2ра ап1рел а1ра ара2ст ар2бок ар2вал 1аргу а1ре аре1дв аре1ол ар2жа а1ри а1ро ар2тор ар2т1р а1ру ар1х а1ры а1рю а1ря 2ас1к ас3ми ас3но 1ассиг аст1ву ас3тем ас2тин ас2тия ас1тоо ас1тух а1стье ас2шед ас2шес а1сьи а1та 1атак ат3ва ат1ви ат1ву 2атез а1ти а1то ат1обе а2томн ато2ш ат1рах ат1ри а1ту ат2х а1ты а1тье а3тью а3тья а1тю а1тя а1у а2уб ау2д ау3до а2уле аут1р ау2х ау2ч ау3чь ауэ1 а2ф1л ах2а ахми2 ах3с а1ч 2ача а2чл ач1т а2шл аэ2ли а2эр аю1та а1я ая2б ая2в ая2з 1ба ба2бв ба2г1р ба2др ба1з ба3зу балю1 ба2о бас3м ба1ст ба1тр 2б1б б1в бвы2 бг2 2б1д 1бе 3бев бе2гл бе2гн бе2д1р 3бее 3бе2з без1а2 без5д4 бе3зи без3н без1о2 без1р бе2с1к бес3п бе2с1т бес3те бес3ти 3бец 2бещ 2бж б1з2 1б2и 3биа би2б 2биж 3бик били3т2 3био би2об би2од би2он би2ор би2тв би1х 2б3к б1л 1благ 1б2лаз б3лази б2лан 1б2лее б3лен б2лес1к 1б2лея б2луд 1б2луж 2блы 2б2ль 2б3лю. б2люд б2люе б2люл 2б3люсь 2бля 2б3н 1бо бо1бра бо3вш бо2гд бо1дра бо1з2 бо1л2ж бо1льс бо3м2л бо2мч бо3мш бону1 бо1ру бо2са бо1ск бо3ско бо3сти 3бот бо2тв бот2р боя2р 2бр. б3раб б2рав бра1зо 1б2рал 2б1рам б2ран 1брас б2рать б1рах 1б2рач 2б3рая 1б2ред б1рей б1рек б2рем б2рех б2рид б2рито б2риты 1б2роди б1рол б1ром. 1б2роси бро2с1к 2брс б1ру 3брукс 2брь 1б2рю 2б3рю. б1ря 2б1с2 б3ск бс4л б1т 1б2у бу2г1р бук1л бу1с 2бф 2б1х 2бц 2б1ч 2бш 2бщ 1бы бы2г1 бы2с быс1к быст1 1бь 2бь. 2бьс 2бьт бэ1р 3б2ю бю1та 1бя 1ва ва2бр 3ваг ва2д1р вадь2 ва3ж2д ва1з ванс2 ва1ст ва2стр ва1тр вах1 3вац 3вая 2в1б в1ви в1вр 2вг2 в1д в2дох 1вев 3вег вед1р ве3ду 1вее 1вез 3везе 3везл вез2у 1вей. ве2п1 2верд 1вес ве2с1к ве2ст1в вет3р 1вец 1вею 1вея 1в2з2 взг2 взд2 взо1б взъ2 взъе3д ви2аз ви2ак ви2ар ви2а1с2 виа1т ви3аф ви2гв ви2гл 1виз 1винт 1винч ви1о ви1с2ни виу3 ви2ф 2в1к вк2л 3в2кус в1л в2ла 2в3лаб в2лев в2лек в2лет в2леч 2вли в2лия 2влю в2люб 2вля 2вм 1вме 2в1н 4в3на в2нес вно1 в3ну. 3в2нук 3в2нуч в3ны во1б2 во2б3ла вов2 во3вк 1вод во1дв во1др во2ер во2жж вои2с1 1вок во3м2 воп2 во1ру 2ворц 2ворь вос1к во1см во1сн вос3пе во2стр вот2р 1вох во1хл во3х2т 1вою 2вп2 2вр. 2вра. в2рав 2в1рам в1рас 2в1рах 2врац 2вре. 2в1рен 1врид 1в2риз в1рии в1рик в1рил в1рис в1рит 2в1ро вро3т2 2в1ры 1врю в1ря 2в1с2 3все3 в3ская 4в3ски 4в3ску 3в2сп 3в2сю в1т2 вто1б2 вто3ш 1вуа ву3г 1ву1з 2вуи 2ву1к ву3п ву1с2 ву2х1а вух3в ву1чл вф2 1вхо 2вц 2в1ч 2вш 3в2шив 2вщ въ2 1вы вы3г2 вы3зн вып2 вы3т2 вых2 вы3ш2л 2вь. 1вье 1вьин 2вьс 2вьт 1вью 1вья 1в2э1 1в2ю 1вя 1г г2а га1з га1ст2 га2у 2г3б гба2 г1ви 2гг г3дан 2г3ди 3ге. ге2б1 гено1 ге2об ге2од ге1ор 2г3ж 2г1з г2и ги2бл ги3бр ги2гр ги1сл гист2 2г1к 2гла. г2лав г1лай г1лами 2глась 2глая г1ле г2лет 2гли. г2лин 3г2лиф 2гло. г3лобл 2глов 2глог 2глое 2глой 2глою 2глую 2г1лы г2ляж 2гляк 2г3м г2нав г2нан г3не. г2нев г3нен г3неп г3нес г2нир гнит2р г2ное г2нои г2нос г3ня го1б2 го2вл го3ж2д го1з го2зл гоз2н гоиг2 3гой г2ол гоми2 го2с1а го2сд го1скл го1сн го1спа 2готд гоу3т го1чл 3гою 2гп 2гр. г1рае г1рай г1рар г1рег г1рек г1рец гри4в3н г1рик г1рил г1рин г1рис г1рич г1ров г2роз г1рок г1рон г1роп г1рот г1роф гру2п г1рыв 2грю г1ряе г1рял г1рят 2г3с2 г4са г4сб 2г3т гу1в гу1с гу2с1к 2гф 2г1ч 2г3ш 2г3э 1да да2б1 да2ген да2гр да1з да2о даст1р дат1р 2д1б дв2 д1ве 1дви 2д1вид 2двиз 2двинт 2двинч 2д1вис 2д1вит д3вк д1вл 2двод д1воз 1дворь 2двя 2дг2 2д1д2 1де де1б2л де1б2р 3девр 3дез де2з1а2 де2зи дез1о2 де2зу деио2 де1кл 3деме де2од део3п де3пл дерас2 де2с3в дес2к де2ср де1хл 2дж. д2жам д2ж3м 2джс 2д1з2 1ди ди2ад диа2з ди2али ди2ало ди2ар ди2ас ди2об дио3де ди2ор дио1с ди1оти дип2 ди2пи ди3пт ди2с1тр диу3 ди3фр ди3фто ди1х 2д1к д1л д2лев 2д3м2 2д1н д3на днеа2 3дневн 4д3но1 дно3д2 днос2 4д3ны 3д2няш 1до 2д1о2бед до2бл 2д1обла до1б2ра дов2л до3в2м до1д2 до3дн до3ж2д до1з доз2н дои2р 2докт 2долим до2м1р доп2 до3пл 2допле до2пре до2руб до1с д1о2сен д1о2син 2д1осно дос2п 2дотд 2дотл дот2ри 2д1отря 2дотъ до3ть 3дохл до2ш3в до3ш2к до2шлы до2щу 2дп 2др. д1раб 1дравш 2дразв 1д2разн д1ране д1рар д1ра2с3 д1рах д1рач д2раю д1ре д2реб 2д3реж 2дрез д2рел д2рем 1дрема 1дремл дрем3н 1дремы 2д3рен дре2ск д2ресс д1ри д2рий 2дрин д2рип д2рих дро2г3н д1род д1рое 1д2рож 2д3роз д1рой д1рол д1рон д1рос д1рот д1рою д1руб 1друг 1друж д1рум д1рую д1ры 2дрыв 1д2рыг д1ря д2ряб 1д2ряг д2рях 2д1с2 дск2 дс3кн 2д1т 1ду дуб3р ду3г 2д1уд ду2да ду2о дуп1л дус1к д1усл ду1ст ду2ста 2дут1р ду1х ду2чи дуэ1т 2дф д1х 2д3це 2дцу 2дцы 2д1ч 2д3ш2 2дщ 2дъ дъе2м 1ды 2дыг ды2г1р 2дыд 2дыме 2ды2с1 2дыт 2дыщ 2дь. 1дье 2дьк 2дьт 1дью 1дья дь3яр 1д2ю 1дя е1а еа2д еади3 еа3до еа2з еан2д1р еат1р 2еб еба2с е1бра еб1рен еб1ри е1бро еб1ров еб1ры е2б3рю е1ве 2евер е1ви е3в2ме ев2ним ев2нят е1во 2евол евра1с 2е1вре ев1рее ев1рей ев1рея ев1ри е2вт е1ву е1вх ев2хо е1вь ега1с2 ег2д е2глан е2гле е2гли е2гло ег2на ег2но 2ег2р ед1во ед2ж е1дже е1д2лин едноу3 ед1опр е2дотв е2дох е2д1ощ е1дру е2дру. е2ду2б ед1убо е2дуве е2дуг е2дус ед1уст 2е3душ е2дын е1е е2евид ее2в1р ее2ги ее1с2 ее2ст еест1р ее2х е2жг е4ждев еж3ди 2еже е2ж1р еза2вр езау3 е1з2ва езд1р е3зе еззу3 е3зит ез1об ез1о2г е1зом ез1оп ез1о2р ез1от ез1ош ез2ря ез1у2д ез1у2к ез1уп ез1ус езу2со езу2сы ез1у2х ез1уча е3зя е1и еи2г1 еи2д еи2м еи2о еис1л еис1тр е1ка ека2б ек2з е1ки 2е1ко 2е1кр ек2ро ек1ск ек1сте е1ку е1ла е1ле еле3ск еле1сц е1лу е1лы е1лю е3ля еми3д2 еми3к емо1с 2емуж е2мч 2емыс е3на ен2д1р 2е1нр енс2 ен3ш2 е1нэ 2ео е1о2б еоб2ро е2о3гл ео2гро е1од ео3да ео2де еоде3з ео2до е1о2ж е2ои ео3кл е1ол. е1ола ео3ли е1олк е1олы е1оль е2ом е1он. е2она е2они ео3но е1онс еоп2 е1опе ео2пр ео4пу е2о3ро еос2 е1о2сви ео1ск е1осм е1осн еост1р ео3сх е1отл еот2ру е1о2ч е1о2щ епат2 епа1тр 2епе епис2к е2пл е3пла еп1леш е3п2лод еп1лу е3плы еп1лющ е4пн 2епо е4п3с е4пт е1ра ер1акт е2рв ер1ве е1ре е3ре. ере3до ере1др ере1к2 ере3м2н ере3п ере1х4 е1ри ерио3з е1ро еро2б ер1обл 2ерови 2ерокр 2ерол еро3ф2 ер3ск е1ру е2р1у2п е1ры е1рю е1ря е3с2а ес2ба е1сг е1ск е2с1ка. ес1кал е2ске е2сков е4с1ку. 2есл ес1лас ес2лин ес2лов ес2лом е1слу е1слы е1с4м е3со 2есп ес2пек ес3пол е2спу е1ст ес2тан е2стл е3сту ес2чет е1та ет1ве ет1ви е1тво 2етеч е1ти е1то ето1с ет1р ет2ря е1ту е1ты е1тье е3тью е3тья е1тю е1тя е1у2 2еуб еуб3р еуз2 еук2ло ефи3б2 еф2л еф1ре еха2т ех1ато ех3вал ех3лоп ех1об ех1опо ех1ре ех1ру ех1у2ч 2ецв е1чл е2шл еэ2 ею2г е1я ея2з 1ж жа2бл жа2бр жа1з жат1в 2ж1б2 2ж1в жг2 2жга ж2ги 3ж2гл ж2гу 2ж1д ж2дак ж2дач 3ж2дел 4ждеме ж2деп ж2ди 4ж2дл ждо3 жду1 4ждь 3ж2дя 3жев же3д2 же1к2в же1кл же1о2 же3п2 же1с2 же3ск 2жжа ж2же 2жжев 2ж1з2 жи1о 2жирр 2ж1к 2ж1л ж2м ж3ма 2ж3мо 2ж1н жно1 2ж1об 2ж1о2т1 жоу3 жоу1с 2жп2 жпо1 ж2ру 2ж1с 2жф 2жц 2ж1ч 2жъ 2жь. 2жьс 2жьт 1за1 заа2 заб2 за2в1ри за2вру з1аву заг4 з1адр зае2д зае2х за3ж2д за3з2 з1акт за3мне 3з2ан за3на занс2 зап2 зар2в за3р2д зар2ж зас2 заст2 зат2 за3тк зау2 зах2 зач2т за3ш2 зая2 з1б2 2з3ва. з2вав з3валь з2ван 2звая з1ве з2вез з1ви з3в2к з1вла з1во 2звол 1з2вон з1вр 1зву 2з1вую з1вь 2зг з3га з2гли зг2на з2гну з1д2в з2деш здож3 1зе зе2б1 зе2ев зе2од 2зж2 з3з2 1зи 3зи. 3зий. з1инт зи2оз зи2оно зи1оп 3зис зи3т2р зиу3м 3зич 2з1к зко1 зко3п2 з1л з2лащ з2лоб з2лоп з2лор з2лющ 2зм2 з3мн з1н 2зна. з2нав з2нае з2най з2нак з2нан з2нат з2наю 2зная 2зне 2з3ни 2зно 2зну 2з3ны з2обе зо2би 1зов зо3в2м зо2гл зо1др 1зое зо1з2 1зои 1зой. 1зок. з1окс 1зол2 зо1лг зо1лж зо3м2 1зом. 2зомн 1зон 2зонр 1зоо зо2о3п зо2ос зо2па з2опл з2опр з1орг 1з2о3ре зос2 з1осн зо1сп зо2тв з2оте з1отк з2ото зот2ре зот2ри 1зох зош2 зо2ши 1зоэ 1зою з1ра з2рак зра2с з2рач з2рен з1рес з2риш з1ро зро2с3 з1ру з2рю з1ря 2з1с 2зт з1ти 1зу 3зу. 2з1у2бе зу2б3р зу1в 2зуве 2зу2г 3зуе 2з1уз3 2зу1к 3зуме з1у2мо 2зуп зу2пр з1урб з1у2те зу2час 2зц з1ч 2зш зъе2м 1зы 2зы2г1 зы2з 2зыме 2зымч 2зы2с1 2зыщ 1зье 1зьи 1зью 3зья 1з2ю 1зя и1а и2аб и2ав иаг2 и2агр и2аде и2ади иа2зов иа2му и3ана иа2нал ианд2 иао2 и2ап иа1с2к иа1ста иа1сто иат1ро и3ату и2аф и2а1х иа2це 2и1б и2б1р 2иваж 2и1ве и2в3з и1ви 2и1во и1в2р и3в2с и1ву ив2хо 2ивы иг2д и3ге 2игл и2гле и2гли и2гн игни3 иг1рен иг1ро иг1ру иг1ры и2г1ря и1дв и2дей и1д2ж иди1ом иди1от ид1р и1дь и1е и2евод ие2г ие2д ие3де ие2зу и3ени ие1о2 иепи1 ие2р и3ж2д из1в2 из2гне 1из1д из2нал и1зо изо2о из1р и1и ийс2 и1к и3к2а ика1с2 ик2ва и2кви и2кля и3ко ик1ро ик1ск ик2с1т и3ку и1л и2л1а2ц ило1ск илп2 и2л1у2п и2ль ильт2 2има и2мено и2мену 2имень и3ми имои2 им3пл и2м1р и2мч им2ча инд2 1инж ино2к3л ино3п2л ино1с инс2 1инсп 1инсти 1инсу 1инф 1инъ и1об ио2бо ио2вр и2ог и1од ио2де и1оз ио3зо и1окс и1оле и1он и3онов и1опт и1ор и3ора ио1ру ио2са ио3скл ио1с2п и1ота ио2т1в и1отк и1отс иоуг2 ио2хо и1ош 2ип ипат2 ипа1тр ип2ля ип3н ипо3к2 и1р ира2ст и2р1ау и2рв и2рж ири2ск ириу3 иро1з2 1ирр исан2д1 и2сб и2сд ис1к ис3ка. ис3кам ис3ках ис3ке ис3ки ис3ков ис3ку. и2слам ис1лы ис3ме ис3му ис3но исо2ск и2с3пр и4сс и1ст и2ст1в и2стл ис1тяз и1сьи и1т ита2в ит3ва и2т1ве ит1ви ит1ву и2тм и2т1р ит2рес ит3ром и2т1уч и3тью и3тья и1у2 иу3п иф1л иф2лю и2фр иха3д и2х1ас их2ло2 ихлор1 и3х2о ихо3к их1ре их1ри и1ху и1ч иш2ли и2шлы и2шт ию4л ию2н ию2т ию3та и1я ия2д 2й1 йд2 й2д3в йно1 й2о1с йо2тр йп2л й2сб й3ска йс2ке йс4мо й2с3му й2сн й2с3ф й2сш й2тм й2хм йх2с3 йя1 ка2бл ка2бри 1кав к2ад ка3дне ка2д1р 1кае каз3н ка1зо 1кай 1кал. 1кало 1калс 1кам 1кан ка2п1л ка2пре кар3тр 3к2ас ка1ст 1кат ка1т2р 1ках ка2ш1т 1каю 2к1б к2вак к2вас к2ваш к1ви к2воз к1ву 2кг 2к1д кда2 1ке 2кеа ке2гл кед1р ке2с1к ке2ст1 2к1з 1кив ки1о киос1 ки2пл ки1с2ни 1кит 2к1к2 кк3с 2к3ла. 2к3лась 2к3ле. 2клем к3лем. к3лен к1лео 2к3ли. 2к3лив к2лик к2лин 2к3лис к3лия 2к3ло. к2лоз к3лом 2к3лос кло3т 1клук к3лы 2кль 1клю 2к3лю. 2кля. 2клям 2клях 2км 2к1н 3к2ниж к2ноп 3к2няж к2о ко1б2ри 1ков 3кова 1код ко1др 1коз 1кольс 2комин 3конс коп2р ко2р3в ко1ру 1кос ко1ск кос3м ко1сп 1котн ко2фр кохо2р3 1кош 2кп 2кр. к1рел кре1о кре2сл к1реч 1криб к1рид к2риз кри2о3 к2рит к1рих к1роа к1роб к2рое к1рок к1роо к1рор к1рос к1роф к1рох к1роэ кру1с к1ряд 2кс ксанд2 к2с3в кс3г к2с3д к2сиб к1ски кс1кл к1ско кс3м к3со к1стам к1стан кс3те к1сто кс1тр к1сту к3су 2к1т кта2к 3к2то. кто1с кт2р к2у ку1ве 3куе 1куй 1куля 3кум куп1л ку2п1р 1кур ку3ро кус1к ку1ст 1кут ку3ть 1куче 1куют 3кующ 2кф 2к1х2 2кц 2к1ч 2кш 1кь к2ю 1ла. 2лабе ла2бл 2лаго ла2гр ла2д1аг 1лае ла3ж2д ла1зо л2ак лак2р 1лам. 1лами. лан2д1р ла1ста ласт1в ла1сте ла1сто ла2ст1р ла1сту ла1стя ла1т2р лау1 ла2ус ла2фр 1ла1х 1лая 2лб л1бр л1ве л1ви л1во л1ву 1л2гал л2гл лго1 2л3д2 1ле. ле1вл лев1ра ле2г1л ле1дж ле3до ле1з2о3 ле1зр лек1л 2лемн 1лен ле1онт ле1о2с ле2сб ле2ск ле4ска ле1с2л ле1спе ле1тв ле1т2р 1лех ле1хр л1зо 1ли лиа2м 3ливо 3ливы лиг2л ли2гро лие3р ли2кв 2лимп лио1с ли2пл лис3м 2л1исп ли2тв лиу3м ли2х3в ли1хл ли1хр 2л1к лк2в л2к1л 2л1л л2ль ллю1 2лм 2л1н лни2е 1ло ло2бл ло1б2р 2ловия ло2вл 3ловод ло2г3д лого1с ло1др 2лоен ло1зв ло2к1а2у ло2кл лок3ла 3лопас ло2рв 2л1орг ло1ру лос1к ло1с2п 2лотд лот2р ло2шл 2лп 2л1с2 лс3б л1т 1лу. лу1бр лу1в лу3г лу1д4р 1луе лу1зн лу1кр 1лун луо2д лу3п2ло лу1с лу3ть 1лую 2л3ф2 2л1х2 л2х3в 2лц л1ч 1лы. 1лые 1лыж 1лый 1лым 1лых. 4ль. 2льд 3лье 3льи 2льк 2льм 2льн 3льо 2льск 1льсти 1льстя 2льт 2льц 2льч 1льща 1льще 1льщу 3лью 3лья л2ю 1лю. 1люж 1люсь лю1та 1ля 3ля. ля1ви 3ляво 3лявы 2ляд 3лям ля1ре ля1ру 3лях 1м ма2вз 3маг ма2гн ма2др ма2дь ма1зо ма2к1р 2м1алл ман2д1р мас3л ма1с4т ма2тоб ма2т1р ма2у маф2 3мач ма2чт 4м1б м3би мб2л м3бля 2м3в2 2мг2 3м2гл 2м1д меан2 ме2ег ме2ел ме2ж1ат ме1зо ме2с1к ме2ст1р меч1т 2мж 2м1з2 ми2гре ми1зв 2мизд ми1зн ми2кр мик1ри ми2оз ми1опи ми2ор ми1с2л 2м1к2 3мкн 2м1л м2лее м2лел 2мм 2м1н 4м3на мне1д 3м2неш 4мное м2нож 4мной 4мном м2нор 4мною м2нут 4м3ны мо1б2 мо3вл 3мод мо1др мо2жж мо1зв мо1зр моис1т мо2к3в мо3м2 3мон 3моп мо1ру мос1ка мо1см мо1сн мо1с2п 3моти мо2т1р 3моф 2мп мп2л м1раб 2мри 2м1ро м1ры 2м1с мс2к мс2н м2с1ор 3м2сти 2м1т му1с2к му1с4л му1ст мут1р му3ть 2мф мфи3 2м1х 2мц м2чав м2чал м2чит м2чиш 2мш2 2мщ 3м2ще мым1 мы2мр мы2с 2мь. 2мьс мью1 2мэ мэ1р м2ю мя1р мя1ст 1на наби1о наб2р на1в2р наг2н на3жд на1з2 на2ил на2ин на2и1с2 4накк на3м2н нап2л на1рва на1р2ви на1с2 на1тв на1т2р н1а2фр на1х2 2нач на3ш2л 2нащ наэ1р 3ная 2н1б2 2н1в 2нг н2г1в нги2о нг4л нго1с нг2р 2н1д н2дак н2д1в нде3з нде2с нд2ж н3д2з н2дл нд1раг нд1раж нд2ре нд2риа н2дря нд2сп н2дц 1не не1б2 не1в2д 2невн не3вня нег2 3нед не1д2л нед2о не2дра не1дро не3ду не3е нее2д не3ж2д не1зв не1з2л не1зн не1зо не1зр неи2 не1к2в не1кл не3м2н 3не1о2 не2ода не2ол не3п2 не1р2ж не2р1от нес2к не3с2н не1с2п нест2 не1с2х не1с2ч не1т2в не3т2л не1т2р 3неу не2фр не1хр не3шк нея2 2н1з2 нзо1с 1ни ни3б2 ни2ен 3ний ни2кл нила2 ни2л1ал ни2л1ам 2нинсп 2н1инст ни1сл нис3п нист2р ниу3 ни1х 3ниц 3нищ 2н1к нк2в нк2л нкоб2 нко3п2 н2к1ро нк1с н1л 2н1н нно3п2 1но ноб2 но1бр но2вл но1дв но1др но2ер но1зв но2зд но3з2о но1зр но3кн 3номе ном3ш но2рв но1ру но1скл но2сли но1с2п но2сч 2нотд но3ф2 ноэ2 н3п2 2н1ре 2н1ри н1ро 2н1с н2с3в н2сг нс2ке н2скон н2сл н3сла н2с3м н2сн н2с1ок н3с2пе нст2р нсу2р н2с3ф н2съ3 2н1т н2т1в нти1о2к н2тм нт2ра н2тр1а2г нтр1аж н2трар нтрас2 нт2ре н2трив н2трок нт2ру нтр1уд нт2ры н2т1ря 1ну нут1р ну1х 3ную 2нф2 н1х нхо1 2нц 2н1ч н2чл 2нш нш2т 2нщ 1ны 3ны. 2нь. 1нье 1ньи 2ньк 1ньо 2ньс 2ньт 2ньч 1нью 1нья н2э 1н2ю 2н3ю2р 1ня ня1ви 2о1а2 о3ав оап1 2оба 2обио об2лев об2лем о1блю 1обм обо1л2г обо3м2 обо2с 2обот об1р о2бра. о1брав о1бран 1объ 2обь о1в о3вла о3в2ло ов3но о3в2нуш о2в1ри ов2се ов3ско ов2т о2вх ог2 2о3ге ог3ла. ог3ли. ог3ло. о3гря 2одан од1вое о3де. 1о2деял 2оди3а 2о3дим од2лит о2д1о2пе одо3пр о2д1о2пы о2доси о2д1отч о1драг од1раж од1раз од1рак о1драл од3реб о1дроб од1ров о2д1у2ч о2дыма о2дыму о2дын о1дь о2дьб о1е ое1б о2е1вл ое2д о3ежек ое2жи ое1о ое1с2 ое2ст о2ето ое2ц о3жди о3ж2ду оза2б3в 2озав о1з2ва оз2вен оз2ви о1з2вя оз2гло оз2дор о1здр озе1о оз3но о1зо о2з1об 2озон о2зоп озо1ру оз1уг о2зым о3зыс о3и ои2г1 оиг2н оие3 ои2з ои2м ои3мо ои2о 2ой ойс2 о1к 2о3кан ок2в 2ок2л о3клю око1б 2о3кол око3п2л ок1ск 1окт 2окти 2окум о3ла ол2ган о1ле 1олимп о3ло о1лу олу3д2 о1лы о1лю о3ля о3ма ом2бл 2оме о3м2нем о3м2нет о3множ ом1ри ом2ч ом2ше о2мь о3мья о3на онд2 оне3ф2 оно1б о1нр онс2 он2тру о1о2 о2ол оо3пс оос3м оост1р о2оти о2оф о3пак о3пар о2пле. о2п1лей о2пли оп2лит оп2ло оп3лю. о2пля о3пляс опо4вс опоз2н опо2ш3л оп2ри о3п2те оп2то о1ра ора2с3 ор2б3л о1р2в о1ре 2о3рег оре2ск о1ри ор1исп о1ро оро2с3л ор2тр о1руе о1рук ор1укс о1рус 2орц о1ры о1рю о1ря о3сад оса3ж2 ос2б о2с3ба о2с1ка. ос3кар оск1во о2ске ос1ки о2ски. о2сков ос1кой ос1ком о1с2коп ос1кою о2с1ку. ос1кую о1с2л ос3лей ос3лог ос3лых ос3ми ос3мос о1с2ним ос2нял ос2пас о1с2пу ос2пя ос2св ос2с3м о1ст ос2та о3стра о2суч 2осх ос2цен о1с2ч о1с2шив о1т отв2 от3ва от1ве от1ви от1вл 1отг 1отд 2о3тек о3тер 2о3тех о3ти о3ткал о2тм от1раб от1рад от1раз отра2с от1реж от1рек от1реч от1реш от1ри от1род от1рое от1рок от1рос от1роч от1руг от3см оту2а от1у2ч 1отх о3тью о3тья о1у2 оуп2 оус2к оу3та оу3то 2офаш о3фе 2офит 2офон о2фори 2офот о2фри 2охи ох1лы о2хля ох2ме 2охор о1хр о1ху о2цо оча1с оч2л оч1ле о3чли о1чт о2ч1то ош3ва ош2ла ошпа2к3 ош2т оэ1ти 2ою о1я оя2в оя2д оя2з оя2ри 1п пави3 пав3л па2вь па2др па2ен па1зо пас1л пас1та па1сте пас1то пас1ту па2с1ты па1тро па2ун па3ф па1ху па2шт 2п1в2 2п1д пе1 пе2дв пе2д1ин пе2з пе3за пе3зо пе2к1ла пе2ль пе4пл пери1о пе2с1к пе2сн пе2ст1р пе2сц пе2сч пе2тр пе2шт пиаст1 пи2ж3м пи2к1р 3пинк 3пися 4п3к 2пл. 4пла. пла1с п1лем. п1лемс 2плен п2ленк п1ле2о плес1к п1лею 2плив 3п2лик 2пло. 2плов 2плог 2плый 2плым п1лын п1лых 2плю. п1лют п2ляс п2ляш 2п1н п3на п3но1 п3ны по1б2 по3вл по3в2с под1во по2д1о2к подо3м2 пое2л пое2х по1зве по1здо по1з2л по1зн пои2щ 3пой 3полк по3мно по3мну 3по3п2 п1орг пор2ж по1ру по1с4 3посл по3сс пот2в пот2р по1х2 по2шло по2шлы по2шля поэ3м 2пп2 ппо1д 2пр. 3прев пре1з прей2 пре1л пре1ог 3прет при1 при3в приг2 при3д2 при3к при3л приль2 прип2 п2риц про1бл прод2л про3ж2 про1з2 п1розо 3прои про3п профо2 2прс п2ру 2п1с2 3п2сал п3син 3п2сих п3со 2п1т п2т3в 3п2тих п3ту 3пуб пуг3н пус1ку пу1ст пу3ть 2пф2 пх2 2пц 4п3ч 2пш 2пщ 2пь. 2пьт пэ1ра п2ю1 1ра. раа2 ра2бл 1рабо ра2б1р 1равня ра2гв ра2гл рад2ж радо1б2 ра2дц ра2жур ра2зий ра2зуб рак2в 1ракиз ра2к3л 1ралг 1рамк 1рамн ра2нох ран2сц ра2п1л рас3к2 1расл рас3п рас1т 1раста рас3т2л ра2так рат1в ра1т2р 2рахи 1ращи 1раю 1рая 2раят 2р1б рб2ла р2бле рб2ло рб2лю рбо3с 1р2вав р3вак р3вар р3вата р3веж р2вео 1рвет р1ви р3вин р2вит р1во рво1з2д р1вь 2рг р2гв р2г1л р2гн рг2р 2р1д рда1с р2д1в рд2ж рди2а р2дл рдос2 р2дц 1ре. ре1вр рег2ля рег2н ре2д1о2п ре2дос рее2в рее2д рее2л ре3ж2д 1резк ре1з2л ре1зна 1ре1зо ре1зр рез2у 1рейш ре1к2л 1рекш ре3мно 3ремо ремо2г3 1ренк 1рень ре1он ре1оп ре1о2р ре1о2ф ре1ох ре1о2ц 1репь ре3р2 рес1ки ре1сл ре1с2п рес2с3м ре3ста ре3сто ре1сч ре1тв ре1т2р реуч3т ре1чт ре3шл р3жа. р3жам р3жан р3ж2д 2рз р1з2в р1зо ри3а риб2 ри3бр ри3в2н 2риги ри2гло ри3г2н 2ридж ри1д2р рие2л рие3р риз2в рик2р ри3м2н ри3м2ч р2ин 1ринс рио2з рио2с ри1от ри3р2 ри1с2 ри3сб 2рисп ри3ств ри3т2р 1риу ри2фл ри3фр ри1хл 1риц 1риш риэти2 2р1к р2кв р2к1л рк1с 2р1л2 р2ль рлю1 р3ля 2рм р2мч 2р1н рнас4 рне3о рне1с2 рно3сл 1ро. ро2блю ро1б2р ро2вл 1рогол 1рогру ро1дв ро3д2з ро1дл род2ле ро2д1от ро1др 1родь рое2л рое2м рое2х 1розар ро1з2в ро1зр 3розыс рои2с3 1рокон 1рокр 1ролис 1ролиц 1ромор 1ронаж 1ронап 1ронос рооп1р ро2плю ро3пс 2р1орг ро1р2ж ро1ру ро1ск ро2ски ро2ску 1росл ро1см ро1с2п рос2ф 1росш 1росю 1рот2в 1ротк рот2ри 1роу роуг2 ро2ф1ак ро2фр ро1хл рош2л ро3шн 1рояз 2рп рп2ло р2плю 2р1р 4р1с рс2к р2сн рс2п рств2 р3ствл 2р1т р2такк р2т1акт р2т1в рт3ва рт2вл р2тм р2т1об рт1орг рт1ра рт2ран рт1ре рт1ри ртус1 р2т1у2чи р3тью рт1яч 1ру. 1руба руг3н ру2дар 1ружей 2рукс 1рул рус1к рус3л ру1ста руст1р ру3ть 1руха 1рухо 1ручн 2рф рф2л 2рх р2хв р2х1ин рх1л р1х2ло р2х1оп рх1р 2рц р2цв 2р1ч р2чл р2чм 2рш р3ш2м рш2т 2рщ 2ръ 1ры. 1рыб ры2дв 2рыз ры2кл 1рым ры2с1к ры2х1 2рь. 1рье 1рьи 2рьк 2рьс 2рьт 1рью 1рья рэ1л р2ю 1рю. 1рюс ря1ви 1ряю 1са са2бл са2дь са2кв са2кл 2с1альп с1апп 2с1арк 2с1атл са1тр са2ун са2ф1р са1х2 1сб2 2сбе3з2 сбезо3 сбе3с2 2с3бу с2бы 2сбю 1с2в 2с3вен сг2 с2ги с2гн с2го 1сд2 с2да с2де с3ди с2до 1с2е сег2н се1з2 се1кв сек1л се2к1р секс4 семи1 сере2б се2ск се2ст се3ста се3сте сест1р 1с2ж с1з 1с2и 3сиз си1ом си1оп си2пл си1х 4ск. 2скам с2канд 1с2каф 2сках ск2ва с2кви 3скино ск2л с2кля ск3ляв 2скн с1кон 2скона с2копс 2скош ск2р с1кра 2скриб ск1с 2скуе 2с3ла. 1слав 1слад с1лам 2с3лая с3лев с3лее с1лей слео2 с1лет с3лею 2с3ли. 2слиц 2с3ло. с2лож с3лому 2с3лос 2с3лую 2с3лые 2с3лый 2с3лым 2сль с1люс 2с3ля с2м 1смес с4мея с3мур с1н 1с2наб с2нас 2сная 1с2неж 2с3ник 2сно сно1з2 2сную 2с3ны 1со со1б2р с2ов сов2р со1д со1з2 со1л2г со3м2 со2рие со1ру со1ск со1с2п со2сь сот2р со1чл сош2л сп2 с2пав с2пее с2пел с2пен с2пех 1с2пец с2пеш с2пею с2пим 2спися с3пн спо1з2 2спол с2пос 2спь 1ср 2ср. с2раб сра2с с1рат сре2б1 сре3до 2с1с ссанд2 с2сб сс3во 4с5си с3с2к сс2л с2сн с3с2не с2сори сс2п сст2 сс2ч 2ст. 1ста. 2стб 4ств. ст1вер 2ствл ст2вол ст2вя с2те 1с4те. 1стей 1стел 1стен. с3тет. с3тете сте3х с3теш 1сти с2тие с2тии 2стимп 2стинд 2стинф 2стинъ с2тич с2тишк с2тию 2стк ст2ла с3т2ле 2стли ст2лил ст2лит 2стля 2стм 2стн 1сто. с2то1б 1стов 1стог сто2г3н 1стод 1стое 3с2тои 1сток 1стом 1стон 2сторг 2сторж 2сторс 1стос 1стот с2тоц 1стою 2стп 2стр. страс2 4страя 2стред ст1рей 2стрив ст1риз 2стрил 2стрищ ст1роа с4т1ров ст1род ст1рох ст2руб ст1руш 2стс с1тут 1стую 2стф 2стц 1сты с2тыв с4ть 2сть. 2стьс 3стью 1стья 1стям 1стях 1су су2б суб1а2 суб1о су1в су3гл су2ев су2з су1кр сума1 супе2 сус3л сус3п су1ст сут1р су2ф3 су1х 1с2фе с1х2 1с2хе 2сца с2цена 2с3ци 2сцо сч2 1сча с2час сче2с1к с3чив 2счик с2чит с1чл 2счо сш2 с3шн 1съ2 съе3д съе3л 1сы сы2г1 сы2з сы2п1л сы2с сыс1ка 2сь. 1сье 2ськ 2сьт 1сью 1сья сэ1р с2эс 1с2ю сю1с 1ся 2сяз ся3ть та2бл таб2р та1ври 1таг та2гн та1з2 так3ле т2ан та2пл 1тас та1ст та1тр 1тащ 2т1б2 2тв. 2т2ва т1вей т1вел т1вет 2тви т1вое т1во1з 2т1вой т1вос 2твою 2т1вр 2тву 2твы 2твя 2тг 2т1д 1т2е те2гн те1д те1зо 3тека тек1л 3текш теле1о тем2б1 те2о3д те1ох те4п1л те2рак тере2о 3терз тер3к 3теря те2ска те2с1ки те2с1ко те2ску тест2 те2хо 2тж 2т1з тиа2м ти2бл ти3д2 ти1зна тии2 тиис1 тик2 тила2м т1имп 2т1инв т1инд 2тинж 2тинф ти1с2л ти3ств ти3ф2р ти1хр 2т1к2 3т2кав 3т2кан 3т2кет 3ткн 2т1л тло2б т2ль тм2 тми2с тмист1 т3мщ 2т1н то2бес то1б2л 2тобъ то2вл то1д то3д2р то1з2 ток2р 2т1омм 2томс 2тонг 1торг 1торж 1торс то1ру 1торш то1с2н то1с2п то1с2ц 2тотд то3тк 1тощ 2тп2 тпа1т т1рага 2т1раж 2трб 2трв 2трг 2трд трдо2 т1реа 1требо 1требу т1ребь т1реве т1ревш т1рег т1ред т1рее т1реза т1резн треп1л 3тре2с трес1к т1рест т1рету 3т2ре2х т1рец т2решь т1рею 1триб т1рив три2г1л т1рил т1рим 4тринс три1о т1рит три3ф т1рищ 2трм 2трн т1рогл т1роид 2трой тро3пл т1рор т1росо тро3т 4т3роц 2трою 2трп 2трр 1труб т2руд 2трук т2рум т2рут 2трф 2трщ 2тръ т1ры т1ря. т1ряв 2т1ряд т1ряе т1ряж т1ряй т3ряк т1рят т1рящ т1ряя 4т1с2 т2сб т2с3д тсеп2 т2с3м т2с3п 2т1т т2тм ту2гр ту2жин 2т1у2пр ту1сл ту1ст ту2фл 1туша 1тушо 1тушь 1тущ 2тф 2т1х 4тц 2т1ч 2тш2 2тщ 2тъ ты2г1 ты2с1к 2ть 4ть. 3тье 3тьи ть2м 4тьт тью1 2тэ т2ю тю1т 1тяг 1тяж 1тяп 2тя2ч у1а у2але у2ас у3бел убо1д убос2 уб1р 1убра уб3рю 1у2быт у1ве. у1ви ув2л у1во у1ву у2гв у2гл у2гн уг2на уг2не уг1ре уг1ря уда1с уд2в уд1рам уд1ро у3ду у1е уе2д уе2л уе1с уе2с1к уес2л уе2х у2жж у1з2в у1зо узо3п у1и у1ка ук1в у1ки у1ко уко1б у1ку1 у1ла у1ле у1лу у1лых у1лю у2мч у3на ун2д1р у1нь у1о уо2б уо2в у2оза уо2к уо2п уо2с уост1 уо2т1 уо2ф у2пл уп1лю у3про у1ра у1ре уре2т3р у1ри урке3 у1ро у2род уро2дл урт2р у3ру у1ры у1рю у1ря у2сад у1сг ус1ка ус1ки уск3л ус1ком у1скр ус1ку. ус2л усла4ж3 ус3ли у1см у2сн ус2п ус3с у1сте у1стя у1сф 2усц у2сч у2сь у3сья у1та у3тер у1ти ут2ля у1то уто3п2с ут1ри у1ту у1ты у1тье у3тью 1утю у1тя у1у ууг2 уу2с у3фи уф1л уф2ля у2фр ух1ад уха2т у2хв у3х4во ух1л ух3ля ух1р у2чеб 1учр у1чь у3ше у3ши у2шл уш1ла у2шп 2уэ у1я уя2з 1ф фа2б1 фа2гн фа1зо фан2д фанд1р фа1тр фа2х 3фаш фаэ1 2ф1б 2ф1в 2фг 2ф1д фев1р фед1р фе1о3 фе2с1к ф4и фиа2к1 фи2гл фи2ж фи2зо фи2нин фи1о 3фит 2ф1к ф2ла ф2ли ф2ло 2фм 2ф1н 2фобъ 3фон фо2рв 2ф1орг фор3тр фо1ру фос1к 3фот фото3п ф1раб фра1з фра1с ф1рат ф2рен фре2с ф1ри ф2риж ф2риз ф1ро ф2рон ф1ру 2ф3с 2ф1т ф2тм ф2тор 2ф1у2п фу3тл 2фуф 2фф 2ф1ч 2фш2 2фь. ф2ю1 1ха ха2бл ха2д 2х1ак хан2д хао3 х1арш 2х1б 1х2в 2х3ве 2х3ви х3вы 2хг х3д2 1хе хео3 х1з2 1хи хиат1 хие2 2х1изы хи1с2 х1к2 х1лав х1лас х1лат х1лац 1хлеб х2лес х1лет х3ло. х2лоп 1х2лор х1лу 1х2му 2х1н 3х2ны 1хо 2х1о2к хоп2 хо2пе хо2пор хо1ру х1осм 2х1осн хоф2 хох1л хоя2 хп2 х1раз 1хран х1ра1с2 х1рей хри2пл х2рис х1ров 1хром хро2мч х1ры х1ря 2х1с2 2х1т 1ху. х1у2г 2хуе 2хуй 1хун х1у2р ху3ра 1хус 1хуш 2хую х1х2 2х1ч2 2хш хью1 1ц ца1 3ца. 3цам ца2пл 3цах 2ц1б ц2ве 2цвы 2цг 2ц1д це1з це1к це1от цеп1л цес2л це1т 2цетат 2ц1з ци1 ци2к1 цик3л ци2ол цип2 ци2ск циу3 циф1р 2ц1к2 2ц1л 2цм 2ц1н ц1о2б 2ц1о2д 2ц1от 2цп2 2ц1р 2ц1с 2ц1т 3цу 2цц 2ц3ш2 3цы цы2п цып3л цю1 1ча ча2др ча2дц ча2ево ча2евы ча2ер част1в ча1сте ча1сту ча1стя 3чато 3чаты 2ч1б ч1в 2ч1д 1че че1вл че2гл че1о чер2с черст1 че1сл ч2ж чжо2 1чи 3чик 3чиц 2ч1к 1ч2ла ч2ле ч3лег ч3леж 2чли ч2ли. 1ч2ло 1чм 2чма 2чме ч2мо 2ч1н 3чо 2ч1с 2ч1та ч2те 2чтм 1чу 3чук ч2х 2ч1ч 2чь. 1чье 1чьи 2чьс 2чьт 1чью 1чья 1ш ша2бл ша2гн ша2г1р ша2др шан2кр шар3т2 ша1ст ша1тро 2ш1б ш2в ш3вен ше2гл ше1к ше1о2 ше3пл ше1с2 ши2бл ши2пл шиф1р 2ш1к2 3ш2кол 2ш1лей 2шлен ш2ли. 2шлив 2шлил ш2лин ш2лис ш2лите ш2лиф ш2ло. 2шлов ш2лог ш1лы ш2лю 2шляе 2шляк ш2ляп 2шлят 2шляч 2шляю 2шм 3ш2мы 4ш3мы. 2ш1н 4шни ш2нур ш2п2 ш3пр 2ш1р 2ш1с ш1ти 2штс шу2ев шуст1 2шф ш1х 2шц 2ш1ч 2шь 4шь. 3шье 3шьи 3шью 3шья ш2ю1 1щ 2щ3в2 ще1б2л ще2гл щед1р щеи2 щеис1 ще1с ще1х щеш2 ще3шк щи2п1л 2щм 2щ1н 2щ1р 2щь. ъ1 ъе2г ъе2д ъе3до ъе2л ъ2е2р ъе2с ъе2хи ъю2 ъя2 ъя3н ы1 ы2бл ы3га ы3ги ыг2л ы2гн ы2дл ыд2ре ы2д1ро ы2дря ые2 ы3ж2д ыз2ва ыз2д ы2зл ы2зн ыз2на ыи2 ыиг1 ы2к1в ык2л ы2к3ло ыко1з ык1с ы2ль ы2мч ынос3л ы3по ыра2с3 ыр2в ыре2х ы3са ы3се ыс1ки ыс1ку ы2сн ы3со ыс2п ы2сх ыс2ч ы2сш ыт1ви ыт2р ы3тью ы3тья ыу2 ы2ш1л ы3шь ь1 ьб2 ь2вя ь2дц ь2е ье1зо ье1к ье2с1к ь2зн ь2и1 ь2кл ьми3д ьми3к ьмо1 ьне2о ь2о ь2п1л ь3п2то ьс2к ь2сн ь2сти ь2стя ь2т1амп ьти3м ь2тм ь2тот ь2траб ьт2ре ьт2ру ьт2ры ьхо2 ьхоз1 ь2ща ь2ще ь2щу ь2ю ь2я ья1в ь3ягс 1э э1в эв1р 2эг эд1р эк1л экс1 эк2ст эле1о э2м э3ма э2н э3нь эо2з э2п эпи3к э1ре э1ри эри4тр эро1с2 э1ру э1ры эс1 эск2 эс3м э2со эс3те эс2т1р э2те этил1а эт1ра э2ф эх2 эхо3 э2ц эя2 1ю ю1а ю1б ю2бв ю2бл ю2б1ре ю1в ю1дь ю1е юз2г юзи2к ю1зо ю1и ю2идал ю1к ю2к1в ю1ла ю1ле ю2ли ю1лю 2юм ю2мч ю2нь ю1о1 ю1ра ю1ре юре4м ю1ри юри2ск ю1ро ю1ру ю1ры ю2с1к ю1ста ю1сте ю1сто ю1стя ю1ти ю1то ю1ту ю1ты ю1х юха1с ю1ч ю2щь ю1я я2бр яб1ра яб3ре яб1ри яб3рю 3явикс я1во я1ву я1в2х я2г1л я2гн яд1в яд1р я1е яз2гн я1зо я1и я1к я2к1в я2к1л як1с я1л я2ль ям2б3л я2мь я3на янс2 я1ра я1ри я1ро я1рь яс1к яс1л яс2т яст3в я1сто яст1р я1та ят3в я3ти яти1з я1то я1ту я1ты я3тью я3тья я1тя я1у ях1л я1ху яце1 я2шл 2яю. 2я1я .бо2дра .вст2р .доб2рел .до1б2ри .об2люю .об2рее .об2рей .об2рею .об2рив .об2рил .об2рит .па2н1ис .пом2ну .реа2н .ро2с3пи .со2пла а2ньш атро2ск безу2с бино2ск виз2гн выб2ре гст4р ди1с2лов дос2ня дро2ж3ж 2дружей е2мьд е2о3плато е2о3пози ере3с2со 4ж3дик 4ж3дич заи2л зао2з 2з1а2хав заю2л з2рят зу2мь 6зь. и2л1а2мин илло3к2 й2кь ла2б1р лу3с4н ме2динс ме2д1о2см мети2л1ам мис4с3н нар2ват не2о3ре ни1с2кол ни4сь. но4л1а2мин н2трасс о2д1о2бол о4ж3дев о1и2с1тр ойс4ков о2м3че. они3л2ам он2трат о2плюс осо4м3н оти4дн пере1с2н по2доде по2д1у2ро пое2ж по2стин прем2но приче2с1к пти4дн редо4пл реж4ди рни3л2а3м роб2лею 2сбрук1 со2стрит со3т2кал 2стче. 2стьт сы2мит 2сься. 6тр. тро2етес 6хуя. ы2рьм ыя2вя ьбат2 а1вё а2двё а1ё аз3вёз а1лё 2алёк 2амёт ам2нёт а1рё ас3тём а1тьё 1бё бё2д1р б3лён б2лёс1к б2люё б1рёк б2рём б2рёх 1веё 3везё вёд1р 1вёз 2вёрд 1вёс в2лёк в2лёт 1вмё в2нёс 2в1рён 3всё3 1вьё г1лё г2лёт г2нёв г3нён г2ноё д1вё 1дё .доб2рёл 2доплё до2прё д1рё д2рёб 2д3рёж д2рём 1дрёма 1дрёмы 2д3рён дъё2м 1дьё еб1рён е1вё 2евёр 2е1врё е2глё е1ё 2ежё е3зё е1лё 2епё ер1вё е1рё ерё3до ерё1к2 ес2чёт ет1вё е1тьё 2ёб ё1бра ёб1ры ё1ве ё1во 2ё1вре ё1ву ё1дру 2ё3душ 2ёже ё3зе ёз1о2г ё1зом ё1ка ё1ки 2ё1ко 2ё1кр ёк2ро ё1ку ё1ла ё1ле ё1лу ё1лы 2ёмуж ё2мч ё3на ён2д1р ёнс2 ёпат2 2ёпе ё2пл ё3пла ёп1лу ё3плы ё4пн 2ёпо ё4пт ё1ра ё1ре ё3ре. ё1ри ё1ро ёр3ск ё1ру ё1ры ё3с2а ё1ск ё2с1ка. ё2ске ё4с1ку. 2ёсл ё3со ё1ст ёс2тан ё3сту ё1та 2ётеч ё1ти ё1то ёто1с ёт1р ё1ту ё1ты ё1тю ё1тя ёха2т ёх1ато ёх3вал ёх3лоп ёх1опо ёх1ру 3жёв жё1с2 ж2жё за3мнё з1вё з2вёз 1зё з2наё 2знё 1з2о3рё з2отё зот2рё 3зуё зъё2м 2зымё 2и1вё иг1рён и1ё их1рё 1каё 1кё к3лён к2роё 3куё ла1стё лё3до лё1з2о3 лёк1л 1лён лё2ск лё4ска 1лёх 2лоён 1луё 3льё 1льщё 3м2нёш 3м2щё нд2рё не3ё 1нё нё1б2 3номё 1ньё од3рёб о1ё оё2жи о1лё 2омё о3м2нём о3м2нёт о2п1лёй о1рё о2скё от1вё 2о3тёк о3тёр от1рёк от1рёш о3фё пё1 пё2ст1р пё2тр 2плён п2лёнк плёс1к п1лёю поё2ж 3прёт причё2с1к р2блё 1рвёт .рё2бр 1рёзк рё1зна 1рё1зо рёз2у 1рёкш 3рёмо 1рёнк рё3ста рё3сто род2лё роё2м 1рьё с2дё се3стё 1с2ё сёкс4 сё2ст сёст1р 2скуё с1лёт с2тё 1стёл 1стён. с3тёт. с3тёте стё3х с3тёш с3т2лё счё2с1к 1сьё т1вёл т1воё 1т2ё тё2гн тё1зо 3тёка тёк1л 3тёкш тё4п1л тёр3к тё2ска тё2с1ки тё2с1ко тё2ску тё2хо 3т2кёт т1ревё 3т2рё2х т2рёшь тро2етёс 3тьё уг2нё уг1рё .уё2 у1ё у1лё у1рё у1стё у3тёр у1тьё у2чёб у3шё 2х3вё 1хлёб х2лёс ц2вё 1чё чёр2с чёрст1 .чё2с1к ч2тё 1чьё 2шлён 3шьё ъ2ё2р ыд2рё ырё2х ы3сё ь2ё ьё1зо ь2щё ю1ё яб3рё .не8 8не. 8бъ. 8въ. 8гъ. 8дъ. 8жъ. 8зъ. 8къ. 8лъ. 8мъ. 8нъ. 8пъ. 8ръ. 8съ. 8тъ. 8фъ. 8хъ. 8цъ. 8чъ. 8шъ. 8щъ.",
  ["minhyphenmax"]=1,
  ["minhyphenmin"]=1,
  ["n"]=4808,
 },
 ["version"]="1.001",
}