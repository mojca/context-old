return {
 ["comment"]="% generated by mtxrun --script pattern --convert",
 ["exceptions"]={
  ["n"]=0,
 },
 ["metadata"]={
  ["mnemonic"]="af",
  ["source"]="hyph-af",
  ["texcomment"]="% Afrikaans Hyphenation Patterns\
% \
% (more info about the licence to be added later)\
% \
% Hyphenation patterns taken from\
%     <http://extensions.services.openoffice.org/en/project/dict_af>\
% Author:\
%     Friedel Wolff <friedel at translate dot org dot za>\
%\
% The patterns have been added on 2010-09-18 on user request\
% from South Africa, but the patterns seems to be hand-edited badly.\
% We have removed conflicting patterns manually,\
% however this is only a temporary solution.\
% Having some patterns is better than having no patterns at all,\
% but somebody should improve, test and possibly replace patterns\
% with a properly tested version.\
%\
% The hyph-utf8 team.\
%\
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\
% Hyphenation file for Afrikaans\
% Copyright (C) 2005  Friedel Wolff\
%\
% This library is free software; you can redistribute it and/or\
% modify it under the terms of the GNU Lesser General Public\
% License as published by the Free Software Foundation; either\
% version 2.1 of the License, or (at your option) any later version.\
%\
% This library is distributed in the hope that it will be useful,\
% but WITHOUT ANY WARRANTY; without even the implied warranty of\
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU\
% Lesser General Public License for more details.\
%\
% You should have received a copy of the GNU Lesser General Public\
% License along with this library; if not, write to the Free Software\
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA\
%\
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\
%\
% Woordafkapping in Afrikaans\
%\
% Kopiereg Friedel Wolff (2005), lisensie: LGPL\
%\
% Geen waarborg van enige aard nie.\
%\
% Weergawe vir altlinuxHyph\
% Gebasseer op die WAT, HAT, en reëls van die AWS en\
%         \"40 000 woorde\" deur GC Bresler\
%\
%\
%\
%\
% Uitleg\
% ======\
% 0.  Notas\
% 1.  Algemene voorvoegsels\
% 1.  Algemene agtervoegsels\
% 2.  Verkleiningsvorme\
% 3.  Alle herhalings van konsonante langs mekaar (gg, kk, ens.)\
% 4.  Deeltekens\
% 5.  Kapies\
% 6.  Konsonantkombinasies met b-z (vokale uitgesluit, hoofsaaklik geslote\
%     lettergrepe)\
% 7.  Vokaalkombinasies, diftonge, ens.\
% 8.  Oop lettergrepe\
% 9.  Geslote lettergrepe\
% 10. Vaste vorme\
% 11. Uitsonderings\
% 11. Kombinasies met \"ig\"\
% 12. Kombinasies met \"ing\"\
% 13. Trappe van vergelyking verbuigings\
% 14. Grootskaalse konsonantopeenhoping\
% 15. Waaghalsige pogings tot samestellings en verbindingsklanke\
%\
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\
% 0.  Notas\
% =========\
% Dit is belangrik dat daar nie te min karakters van 'n woord alleen op 'n reël\
% toegelaat word nie. Die verstekwaardes van 3 is waarskynlik goed genoeg dat\
% daar nie foute sal wees nie. Kleiner waardes is riskant, en is moontlik ook\
% sleg uit 'n oogpunt van leesbaarheid. Twee karakters behoort egter nie veel\
% probleme te gee nie. Op enkele plekke is daar selfs reëls vir die afkap na\
% die eerste letter van 'n woord. In Afrikaans sal dít waarskynlik nie lekker\
% lees nie.\
%\
% Hier is moontlik heelwat foute. Die volgende gee veral probleme:\
%  * samestellings, en veral samestellings met verbindings-s. Hierdie is 'n\
%    groot probleem aangesien woordgrense juis die ideale plek is om af te kap.\
%    Die afkap rondom woordgrense by samestellings kan lees bemoeilik.\
%  * leenwoorde\
%  * vreemde name en plekke\
%  * klanke wat soms een klank is en soms nie, soos sj, gh, tj\
%  * verkleiningsvorme, wat in elkgeval maar \"bie-tjie\" vreemd is\
%  * deeltekens maak dinge maklik, maar as ons breek voor hulle, moet die\
%    deelteken verval - nie moontlik nie. Die nuwe AWS maak wel voorsiening vir\
%    die behoud van die deelteken, maar ideaalgesproke moet ons dit kan\
%    verwyder, veral in gevalle waar die deelteken slegs vir leesbaarheid\
%    gebruik is.\
%  * oop lettergrepe, veral aangesien woorde wat op geslote lettergrepe eindig\
%    saamgevoeg kan word met woorde wat op vokale begin\
%  * sekere breuke, alhowel hulle korrek is, bemoeilik lees.\
%    Kyk bv. na \"vere-\".\
%  * die interaksie van reëls op mekaar is moeilik om mee tret te hou.\
%\
% Plekke waar daar iets staan soos \"200 gevalle\" is 'n rowwe aanduiding van die\
% aantal gevalle in die woordelys waar 'n sekere reël voorkom. Neem dit met 'n\
% knippie sout, aangesien die interaksie van verskillende reëls meestal nie in\
% ag geneem is nie (maar soms wel). Die woordelys is ook 'n bewegende teiken.\
%\
%\
%",
 },
 ["patterns"]={
  ["characters"]="abcdefghijklmnoprstuvwxyzäèéêëïôöûü’",
  ["data"]=".af1 f2ri1ca f2ri1ka .af2o1r .ag1te .agter1uit .an1ti1 .be1 .be2d1l .be2d1s be4e be2l. be1la be1le be1li be1lo be1lu be2ld be2n1de be2n1s .as1be2s3 .as1b be2r be3ra be3re be3ri be3ro be3ru be3ry be2s1g .er1 .er2e1 .er2i1 .er2o1 .er2u1 .er2ts1 .er2t1s2e .per1 .pe1r2a .pe1r2e .pe1r2i .pe1r2o .pe1r2u .per2s 1ties. 1tie1se. ve2r1 ve2r1a2 ve2r2e4 ve2r3ee ve3r4end ve2r3e4ni ve2r3effen ve2r3er ve2r3eis ve2r3eu ve5r4e. ve3r2i ve4r3inne ve4r3itali1aans ve2r1ont3 ve4r3uit he2r1 he2r2a he2r2e he3rent. he3ren1te. he3ren1tes. her4fs1 he1r2ing .he4r5ing he1r2o he2r3ont1 he2r1uit1 .i1m2a .i1m2i .im1 .in3 .i1n4er1 .i1n4i1 .in4k3b .in4k3p .in4k3s .in4k3t .in4k3v .in4s3gelyk .on1 .o1n2ik .o2n1in1ge n4s. 1on2t1 on3t2a on4t3aar on2t2e .on2t3eer .on2t3ei .on2t3e2r on2t2i on2t2o .on3t2o on2t2u on3t2uu on2t2y 3on2t1d 3on2t1l o4on2t1l 3on2t1ru 3on2t1st 3on2t1t on1t2o1ring 3on2t1pl 3on2t1w 4s1ont1 5s2on3ta b2ont bon1te d2ont don1te f2on3tein fron1te k2ont kon1te a2k3ont1 l2ont lon1te kl4ont klon1te a2l3ont1 e2l3ont1 i2l3ont1 o2l3ont1 u2l3ont1 m2ont mon1te o2on1te p2ont r2ont fr4ont t2ont ton1te on2t3h n4t. 1ge1 ge2e ge2i ge2i1ger1 ge2l ge3la ge3le ge3li ge3lo ge3lu ge3ly ge2n ge3na ge3ne ge3ni ge3no ge3nu ge2m ge3ma ge3me ge3mi ge3mo ge3mu ge3my ge2nt ge2r ge3r2a ge3r2e ge3r2i ge3r2o ge3r2u ge3r2y win1ge2r2d1 win1ge ge2r3de ge2r2s ge2s1pe. .na1ge1 mis1 mi1s2a mi1s2e mi1s2i mi1s2o .om1 .om2a .om2e .om2i hie2r3 .ui2t1 .ui2t1een .ui3t2en1h .ui3t2er baar3de baar4d 3baar3 1ba1re by1 by2n by3n2a by3n2e by3n2i .by2t1s by2s1ter 3dom. 1liet 1lik b2lik 1li1ke p2li1ka 3lik3he 5he3de 3heid1 hei1d2e hei1d2i heid2s1 heid5s4er1ti1 3loos. 1lo1se. 1naar s2naar 3ryk. 3ry1ke. 3ry1ker. 3ry1kes. n5k6ryk 1têr .toe1 .toe2n1 .toe3n2a .toe3n2e .toe2ts1 .toe2r1 .toe3r2a .toe3r2e .toe3r2i .toe3r2o .toe4r3ou .toe3r2u .toe3r2y 1mal s2mal ’5t2ji m3pie. aa2n1tji ant1ji jan1t2ji man1t2ji een1tji ein1tji eon1tji eun1tji iënt1ji oen1tji oon1tji uen1tji uin1tji yn1tji ar1tjie kaar1t2ji vaar1t2ji smar1t2ji har1t2ji kwar2t1ji eer1tji eur1tji be4ur2t1ji be4u koor1tji oer1tji oir1tji uer1tji uur1tji buur2t1ji aat3ji ai1tji ei1tji eu1tji ia1tji fia2t1ji fi1a lia2t1ji li1a io1tji atriot1ji nge1tjie oa1tji oet1ji oot3ji ue1tji due2t1ji nue2t1ji uit1ji .ui3t2ji bui1t2ji krui1t2ji trui1t2ji uut1jie 4b5b4 4c5c4 4d3d4 ei5s2te4d4d5 eis1te ei1s2tee 4f3f2 4f4f. 4f4f3d 4f4f3m 4f4fs 4f4f3w 4g5g4 4ghg4 4k5k4 4l3l4a 4l4l1c 4l4l1d 4l3l4e 4l4l1g 4l3l4i 4l4l1p 4l3l4o 4l4l1r 4l4ls 4l3l4u 4l4l1v 4l3l4y 4m5m4 4n3n4 4n4n. 4n4n5l 4n4n5h 4n4n5r 4n4ns 4n4n5v 4n4n5w 4p5p4 4r5r4 4s5s4 4t5t4 4w5w4 4z3z2 jaz4z3 5ä 5ë 5ï 5ö 5ü ê3e ê4r ê5re û3e ô3e 2b1d2 2b1f2 2b1g2 2b1h2 2b1j2 2b1k2 1b2l2 ro2b3ler i2b3ler 2b1m2 2b1n2 2b1p2 1b2r su2b3 su3b4iet su3b4li gesu3b4iet gesu3b4li b2s. b1s b2s1b b2s1d b1t b1v b1w c2h 1c2hr 1ch2a 1ch2e è2che 1ch2é 1ch2i 1ch4o 1ch2u 1ch2y c2i c2l c2k c2r c1t 1c2e 4o4r4c4e4s1 2d1b2 2d1c2 2d1f2 2d1g2 rid4ge 2d1h 2d1j2 .d2j abi1d2jan i1li1man1d2ja1ro mo1d2ja1d2ji 2d1k2 2d1l2 2d1m2 2d1n2 2d1p2 d1saa d1se. d1sy d2s1ywer d2s1ys1ter 2d1t2 2d2t3p 2d1v2 2d1w2 3d2waal 3d2waas 3d2weil 3d2werg1 3d2wer1g2i 3d2welm 3d2wing 3d2wong 2d1wu r3d2wyn f1b 2f2d. f1d f1g f1h f1j f1k f1m f1n f2n2ui2k 2f1p2 f1ro f1rok1k 1f2r4ok1ki f2s1f f1t f2t. delf2t f2talaat f1v f1w g3b g1da g1de g1di g1do g1dr g1du g1dy g2d1h g1f g1h .g4h g4hi1ta g4het1to g4holf g4hong g4hries g4hwa1no g4hwar sor1g4hum da1g4ha g4hai g4hie 2g3j2 2g3k2 2g1lê1 g1lu g2lun g2luu 2g3m2 2g3n2 2g3p2 2g3t2 g4th g4t. g1w g1z 1h4 2k3b2 2k3d2 2k3f2 2k1g2 2k1h2 2k1j2 1kle 2k1leer. 2k1leer1d 2k1leer1l 2k1lei1er ba3k2lei1e ba1kle 2k1len 2k1leun 2k1le1we1ri 1kle1we e1k2li 2k3lig 2k3lik 1klo 2k1lo1ka 2k1loop si3k2loop si1klo 2k1lo1per 1klo1pe 2k1loos 3k2loos1t 2k1lo1r 3k2lo1ra 2k1los l3k2los s3k2los t3k2los 1klu 2k1lui. 2k1luid 2k1lui1e 2k1lus 3si3k2lus oo2k1l n2k1lug n1klu u2k1lug u1klu 3k2lu1si 2k1m2 2k1p2 k1sa k2s1aan k1se k2s1een k2s1er1v k1si k2s1in1k k2s1in1s k1so k2s1om1d k2s1om1g k2s1om1s k2s1on k3s2on. k3s2on1b k3s2o1no k2s1oond k2s1oor k3s2oort k4s3oor1tr k2s1op1 k3s2op. 2k4t. 2k4t3v 2k4t3l 2k4t3h 2k3t2 2k1v2 luk1w k1wag1t 1kwo 2k1w2oe 2k1w2or 3k2w2o1ru k1wu k1wys l1b l1c l2d. l1da l2d1aan1b l2d1af1 l3de l1di l2d1in l3d2in. l3d2ing l3d2i1na l3d2in1n l1do l2d1of l2d1oor1d l2d1oor1l l2d1oor1s l1du l2d1uit1 l1dy l2d1ys .hal2f1 .hal2f1e2 .hal3f2i .hal2f1u2 sel2f3 l1fa l1fe l3f4ees l2f1eeu1 l2f1erts l1fi l1fo sel3f6oon sel3f6one l2f1oond l2f1o2p1o l1fu l2f1uu l1fy l1ga l2g3b l1ge l1gê 2l1gi l1go l2g1or1de. l2g1or1des l1gor1d l1gr 2l3h2 2l3j2 2l4k. l2k3t 2l1ka 2l1ke 2l1ki 2l1ko 2l1ku 2l1ky l1ma l2m1af1 l1me l1mi l1mo l2m1op l3m2ops l1mu l1my 2l1n l1p ulp1b ulp1d ul1pe ulp1f ulp1g ulp1h ul1pi ulp1j ulp1k ulp1l ul1p2la ulp1m ulp1n ulp1p ulp1r ulp1s wulp2s1 wulp3s2e wulp3s2te ulp1t ul1pu ulp1v ulp1w ulp1z l1r 2l1t 2l2t1s .al2t1 .al3t2a .al3t2e .al3t2i .al3t2y fal2t fal3teer l2t. l1v l1w m1b m1c m2d. m1d m2d1h m1f nim2f triom2f lim2f m1g m1h m1j m1k m1l m1n aam1p m1pa m1pe m1pi m1pl m1po m1pr m2p1rok m1pu m1py m1r m1sa m2s1ak1t m2s1ap1p m1se m2s1e2s m1si m1so m2s1oe m2s1om m2s1op m2s1or m1sta m1ste m1sti m2s3tig m1sto m1stu m1su m1t m1v m1w n1b n1c san2c n4d. n1da n2d1aan1 n3d2aan. n1de n1dê n1di n1do on4d1om on5d2o1me on1do n2d1ont n2d1op1b n2d1op1n n2d1op1l n3d2op1lu n2d1op1p n2d1op1s n1du n1dy n1dra nd1rat nd1rand nd1re n1d2rea n1d2rew n1dri n2d1riem n2d1rigt n1dru n2d1rug n2d1ruit n1dry n2d1ry. n2d1ryk n2d1rym n1f n1ga n2g1aa n3g2aan man5g4a4a4n1 man1ga n4g3aanb n4g3aand n4g3aan1h n4g3aan1v n4g3aan1w n2g1af on3g2aar n1ge1 n1gi n1go n2g1oef tin2g1o n2g1on n2g1oo n3g2ooi n2g1ou ng1se n1gu n2g1uit aan5g4 een5g4 .in5g4aan oon5g4 n1gl n2g1lik an2g1l an3g2li an3g2lo in2g1l in2g2las .in1g2l jon2g1l ton2g1l n1h n1j n1ka n2k1aan1va n1ke n2k1e2f1f n2k1eien n2k1ele n2k1eks3 n1ki n2k1in1h n2k1in1s n1kli n2k1lied n2k1lik nk1s nk2s1h nk2s1om1 oen1k n1l n1m n1p n1r n1sa n2s1amp n2s1aap n1se n2s1eie n2s1er1va1r n1ser1v n1si n2s1in1r n1so n2s1oog1 n2s1oord n2s1oor1g n2s1oor. n2s1op1 n1su n2s1uit1 n2s1ui1t2i n1sy n1ta n2t1aar n3t2aar. n3t2aar1v n2t1as1s n1te n2t1een1h n1ti n2t1in1n n2t1in1s n1to n2t1ont1 n2t1ope n2t1op1n n2t1op1p n2t1op1r n2t1op1s n1tru n2t1rub nt1sa nt1se nt1si nt1so nt1su nt1sy n4t3aan1v n3t2aan n1tu n2t1uit1 n3t2ui1t2i n1ty n1v n1w n1z 2p1b2 2p1c2 2p1d2 2p1f2 2p1g2 2p1h2 2p1j2 2p1k2 1pla 2p1lam 3p2la1mu 2p2land 2p1lap 2p1m2 2p1n2 p2neu1ma1 p2neu1mo1 p1sel 2p1t2 p2t3heid .p2t 2p1v2 2p1w2 2r3b2 2r3c2 r1da aar2da 2r1de aar2de 2r1di 2r1do aar2do 2r2du aar2du r1dr 2r1dy 2r1f2 2r2f. e2r2f oe2r3f ë2r2f ve2r2f1 ve4r5f4erm ve4r5f4ilm ve4r5f4lou ve4r5f4rom ve4r5f4oe ve4r5f4om ve4r5f4raai ve4r5f4rans ve4r5f4ris ve4r5f4yn wer4f dur4f kor4f mur4f skur4f tur4f 2r1g2 2r2g3lu 2r2g. ar2g1l ar2g1w ar1g r2g1d r2g2d. bo2r2g bor3ge so2r2g sor3ge be2r2g1 be2r3g2e be2r4g3eng bu2r2g bur3ge mu2r2g mur3gie wu2r2g 2r1h2 r4ho1desi 2r1j2 r1ka r2k1aan1b r2k1aan1d r2k1aan1w r2k1adre r1ke r2k1er1va1r r1ker1v r1ki r2k1in1l r2k1in1s r3k2in1so r1kli r2k1lid r2k1lied r2k1lik. r2k1li1ke r2k1li2k1h r1klik r1ko ar2k1oor ar3k2oord ar1ko r2k1op1d r2k1op1na r2k1op1er1 r1kop1p r2k1op1s r1ku r2k1uit1 r1ky r2k1y2w 2r1l paar2l ier1m r1ma r2m1aan1h r2m1af1d r2m1af1s r1me r2m1en1gel r1mi r1mo r2m1ont1 r3m2ont. r3m2on1t2a r1mu r1my r2n. 2r1n2 2r2n3s2t2 t2oor2n ker2n ker3ny lan1ter2n lan1te lu1ser2n r1p 2r1pr dor2p dor3pe or1p or2ps or2p1sie r2p1s r2p2s1h r2p2s1v r3p2si1g r4p3si2g. r1sa r2s1aar1 r2s1af1 r2s1ad1v r2s1ak1t r1si r2s1in1du r2s1in1m r2s1in1ko 2r1su r1sy r1ta r2t1aan1d r2t1aan1v 2r1t2e 2r2t3eend 2r2t3eeu 2r1t2i 2r1v2 2r1w2 2r2z. 2r1z2 s3b .s4c s4ch 2s1d s2d3h s4d. 2s1f s2feer s2fer 2s3g2 s1h .s2h s2h. s1ju 1slaa 2s2laag is1m s1pu 1s2pu. 1s2pul 1s2puis 1s2puit 1s2puug 2s1r s1te s1w 1s2waai 1s2wael 1s2war2t1 1s2war3t2e 1s2war4t3ee 1s2war3t2i 1s2wam 1s2weef 2s3weef1sel 1s2weet 1s2weis 1s2wem 1s2wel 2s3wel1syn 1s2wenk 1s2werf 1s2werm 1s2we1we 1s2woeg 1s2wik 1s2wyg 2t1b t1c t2ch. 2t3d 2t1f 2t1g r4t1g 2t1h eat2h t2h. e2t2h1le et1h .et2h be1t2h be2t3hal be2t3hel a1t2hen m3t2h 3t2ha. 3t2he. 3t2hi. 3t2ho. 3t2hu. 3t2hy. t1j t2ji t2je 1tjek uit3j 2t1k2 2t1l2 2t3m2 2t1n2 2t1p2 2t1v2 .t2wak 2t1wa t1wi t2win t3wind t2wis 1uit1wis 2t1wo t1wy t2wy1fel t2wyn 3v4 w1b w1c w1d w1f w1g w1h 1w2his1ky w1j w1l w2n w1p 1wri o2w1r w1s touw2s1ri1vier louw2s1burg w1t 1z2 hert2z a4a4 a3e a4i a3o a2u e1a e4e e4i e3o e4o1g e5o2g1g e2u i3a i2e i3i i3o i4o1g i3u o3a o4e o4i o4o2 o4u u3a u3e u2i u3o u4u4 a4a4i a4i3e a4i2d a4i3de a4i3du a4i3do au1e ei1e s3ei2er. s3ei2ers. e4e4u e4e4u3i e4e4u2s e4e4u3se e3ui i4e4uing i3ee i1eu i2e3ui i2eu. ni2eu ki2eu i2e3uu o4e4i1 o4e4i1s2 oei2d. boei4ng oi3e o4o4i1 mooi2s. kooi2s ooi2t. ou3i u2i3e y1aa y1er y1ee y1o ny2o a1y2o y1u ny2u ie1b a1ba a1be a1bi a1bo a1bu a1by e1ba e1be e1bi e1bo e2b1ont1 e3b2ont. e1bu e1by i1ba i1be i1bi i1bo i1bu i1by o1ba ô1ba o1be o1bi o1bo o1bu o1by u1ba u2bagt u1be u1bi u1bo u1bu u1by y1ba y1be y1bi y1bo y1bu y1by a1ce a1ci a1co a1cu e1ca e1ce e1ci e1co e1cu e1cy i1ca i1ce i1ci i1co i1cu o1ca o1ce o1ci o1co o1cu u1ca u1ce u1ci u1co u1cu y1co a1da aa2d1a a2d1aa a1ma3d2aa a1de aa2d1e2 a1di aa2d1i a1do aa2d1o a1du aa2d1u a2d1uit1 a1dy e1da ee2d1af ee2d1aar ee1da e1de e1di e1do e1du e2d1uit1n i1da i1de si2de. si1de k1si3de i1di i1do ui2d1o i1du i2d1uit1 o1da oo2d1a o1de oo2d1e roo3d2e broo4d3e o1di o1do oo2d1o o1du o2d1uit1 u1da u1de u1di u1do u1du u2d1uit1 y1da y1de y1di y1do y2d1oog a1fa a2f1aard a1fe aa2f1e2 a1fi a1fo aa2f1o2 a2f1oor1 a2f1oef a3f2oe1fel a1fu a2f1uu a1fy e1fa oe2f1a toe3f2a e1fe e1fi ee2f1i e1fo e2f1ont1 e3f2on1t2ei e1fu e2f1uit1 ef1y i1fa i2f1aa i3f2aal i3f2aat gi2f1a ui2f1a i2f1ar i1fe i2f1eend i2f1ei i1fi skri2f1i i1fo i1fu i2f1uit1 o1fa oo2f1a ho2f1a ho2f1aan1 o2f1ad o1fe oo2f1e2 o1fi oo2f1i2 o2f1in1 o1fo o2f1ooi oo2f1o o1fu o2f1ui o1fy u1fa u1fe u1fi u1fo u1fu yf1a ay1f2a sy1f2a y1fe y2f1ei 3s2y1fe y1fi y2f1oes y2f1olie y2f1or yf1u yf1y e1pa ee2pa a1ga aa2g1a2 a2g1aan a3g2aan. a2g1aar a2g1are 1a2gaat1 a2g1af a1ge a2g1een 1a2gent a2ge. sa3ge. ha3ge. a1gi a2g1in1s a1go aa2g1o2 a2g1ont1 a2g1oor a2g1o2p sa3g2o3 a2g1ogg a2g1oud a1gu aa2g1u a2g1ui a2g1uu a2g1y e1ga e2g1aand. e1ge lee2g1e2 e2g1eie e1gi e5g2if ee2g1in e1go ee2g1o e2g1on1g e2g1oor1 e2g1op1 e1gu e2g1uit1 eg1y i1ga i2g3aan1 i2g1aard .si3g2aar3 .si1ga i1ge i1gi .li2g1i i1go ui2g1o2 ig2oon i2g1ont1 i2g1op1t i1gu ig1y o1ga oo2g1a2 o1ge oo2g1e2 o2g1eens. o1gi oo2g1i2 o1go oo2g1o2 o1gu oo2g1u u1ga u2g1aan u2g1aar u2g1aas u2g1ad u2g1af u1ge u1gi eu2gi ug1o2 ou1g2o eu1g2o u1gu y1ga y1ge y1gi y1go a1j e1j i1j o1j u1j y1j a1ka aa2k1a a2k1aan a2k3ad1v a1ke aa2k1e a1ki a1ko aa2k1o a2k1oes. a2k1oes1te. a2k1oond a1ku a2k1uit1 a1ky e1ka e2k1aan1 e3k2aan. e3k2aans e1ke e2k1eend e1ker1v e2k1er1va oe2k1ei oe1ke e1ki e1ko e1ku e2k1uit1 e2k1uur. e1ky ee2k1y i1ka ui2k1a2 i2k1aan1j i1ke i1ki i1ko i2k1oop1m i1ku i2k1uit1 o1ka o2k1aan1 o2k1aart1 oo2k1a2 oo3k2a. o1ke oo2k1e o1ki o2k1in1s oo2k1i o1ko o2k1ou oo2k1o o2k1oo o1ku oo2k1u o2k1uit1 o1ky u1ka u1ke u2k1eti u1ki u2k1in u3k2ing u1ko u2k1ont1 ou3k2o u2k1op1h u1ku y1ka y2k1aard y1ke y1ki y2k1in y3k2ing y1ko ly2k1o y1ku aa2l1 aa2l2s aal3sa aal3se aal3si aal3so aal3su aal3sy twaal4f1 aa2l2s1g aa2l3spr a1la aa2l1a2 a1le aa2l1e2 a1li aa2l1i2 a1lo a1lô aa2l1o2 a1lu aa2l1u2 a1ly aa2l1y2 e1la ee2l1a e2l1aan e3l2aan. e3l2aans. e2l1ad1m e2l1ad1v e2l1af e1le e3lê1 tee2l1eend vee2l1eis we1le we2l1ee te1le3 tele4e tele4k2s1 tele4k3s2e tele4rs tele4nd e1li e2l1i2tem e1li1te e2l1inb e2l1ind e2l1inh e2l1inl e2l1inr e2l1ins e2l1in1v e1lo ee2l1o ee3l2ood ee3l2oon ee3l2one ee3l2oot ee2l3open ee3l2oper ee2l2oop ee2l2ooi e2l1oor e2l1op e3l2o1pe e3l2o1pi e1lu e2l1uu e3l2uuks ee2l2u e1ly i1la ui2l1aa i1le i1li i1lo i1lu i1ly o1la oo2l1a o1le o1lê oo2l1e vo1le vo2l1ei o1li oo2l1i 1po1li so1li o1lo oo2l1o vo2l1o kar1bo2l1op1 o1lu oo2l1u .vo2l1uit .vo1lu1m .vo1l2uut o1ly u1la u1le u1lê jou2le u1li u1lo u1lu u1ly y1la y1le y1li y1lo y1lu y1ly a1ma aa2m1a a1me aa2m1e a1mi aa2m1i a1mo aa2m1o a1mu aa2m1u a1my e1ma e2m1afd e2m1afr e2m1afs e1me ee2m1e4 e1mi e1mo e1mô e1mu e1my i1ma i1me i1mê i1mi i1mo i2m1op i1mu i1my o1ma oo2m1a blo2m3a2 bo1ma bo2m1aan o1me oo2m1e o1mi oo2m1i o1mo oo2m1o o2m1ont1 o1mu oo2m1u o1my oo2m1y u1ma iu2m1a2 u1me iu2m1e2 u1mi iu2m1i2 u1mo iu2m1o2 u1mu iu2m1u2 iu2m1y2 y1ma y2m1af1 y2m1ag1tig y1me y1mi y1mo y2m1op y1mu y2m1ui a1na aa2n1a2 a2n1aan a1ne aa2n1e2 aa2n1een1 a1ni aa2n1i2 a1no aa4n3o2 a2n1oor1 a2n1op a3n2op1sie a3n2o1p2l a3n2o1p2r a1nu aa2n1u a2n1ui an1y 1a2n2ys aa2n1y e1na ee4n3a2 e2n1aan e3n2aand e1ne ee2n1e2 ee3n2e2n. e2n1een. e2n1eens. e3n2eem e2n1een1h e1ni ee2n1in e2n1in1 e1no ee2n1o e2n1oor1een1 e1nu ee2n1u e2n1uu e2n1ui e1ny ee2n1y i1na i2n1aan i1ne i1nê i2n1eend i1ni i1no ui2n1o i1nu i2n1y o1na oo2n1a2 o2n1aan5 o2n1aar o1ne o1nê oo2n1e2 o1ni o1no oo2n1o o2n1op .o2n1op1 .o2n1o2p2e o1nu oo2n1u o2n1uit1 o1ny o2n1ya o2n1ye u1na u2n1arm u1ne u1ni u1no u1nu u1ny u2n1ya u2n1ye u2n1yu yn1a y2n1aar y1n2aaf y1ne y2n1ee yn1o2 y1n2ooi y1n2om1m yn1u pu1b a1pa aa2p1a a2p1aan1 a2p1arm a1pe a1pi a1po aa2p1o a1pu aa2p1u a1py e2p1aan1 e3p2aan. e1pe e1pi ee2p1op1l e1po ee1po ee2p1on ee2p1oef e2p1ont1 e1pu e1py i1pa i1pe i1pi i1po i2p1ont1 i1pu i2p1ui i1py oo2p1 oo2p2s2 o1pa oo2p1a2 o2p1aan1 o2p1amp1 o1pe o2p1een o2p1eet o2p1ein o2p1eis o1pi o1po o2p1ont1 o2p1op o1pu o2p1ui o1py u1pa u1pe u1pi u1po u2p1on1 u1pu u1py y1pa y1pe y1pi y1po y2p1ont1 y2p1or y3p2or1tret y1pu a1ra aa2r1a a1re aa2r1e a1ri aa2r1i a1ro aa2r1o sta2r1oog a1ru aa2r1u a1ry aa2r1y e1ra e2rag ee2r1a2 ee3r2aad see3ra e1re e2r1een e1ri oe4r1in1f oe4r1in1na oe1rin1n oe1ri e1ro ee2r1o e2r1ont1 ë1ro1 e2r3o2p1 e3r4o3p2a e3r4o3p2i ë2r1op te2r2o e1ru ee2r1u zee3r2ust e2r1ui2t1 e2r1ui3t2e e3r2ui3t2er e2r1u2ni e1ry e2rys. i1ra i1re ai2re aai3re i1ri i1ro i1ru i1ry o1ra o1re ô1re oo2r1e2 o2r1een o3r2een. oo4r3een. o1ri o1ro o1ru o2r1ui2t1 o1ry u1ra eu2r1a neu2r2a u1re uu2r1e u1ri u1ro uu2r1o u1ru u1ry u2r1y. y1ra y1re y1ri y1ro y1ru y1ry a1sa aa2s1a a1se aa2s1e ra2s3ei4e a1si aa2s1i a1so aa2s1o a2s1oo ga2s1on4t1 ta2s1orgaan a1su gra2s1u a1sy va2s1ys e1sa oe2s1aan1 oe1sa ee2s2a e1se e1sê e1si e1so fee2s1o lee2s1o vre1de4s5o vre1de e1su .se2s3u e1sy i1sa par1ti5saan nni2s1a ui2s1a2 i1se i1si i1so ui2s1o2 a1ri4s3o e1ni2s3o i1su ari2s1u i1sy o1sa ô1sa oo2s1a o2s1aa o1se o1si o1so oo2s1o o1su o1sy u1sa eu2s1a u1se u1si us1o bou1s2om u1s2or us1u ou1s2u u1sy y1sa y1se y2s1ee y1si ys1o y1su y1sy a1ta aa2t1a a3taaf a3taal a3t2aan a4t3aand a2t1aar spa2t1a2re a1te aa2t1e a1ti aa2t1i a1to aa2t1o a1tu aa2tu a1ty e1ta ee2ta e2taa e3taal e2tagt e1te e1ti ee2t1i e1to e2t1oo e3t2oon be3t2o be3t2oo ge3t2o ge3t2oo e1tu ie2t1u ui4e3t2u i1ta i1te i1tê 3i2tem. 3i2tems. ui1te i1ti i1to .wi2t1o i1tu i1ty o1ta oo2t1a o2t1ag1t o1te oo2t1e o1ti oo2t1i o1to oo2t1o o1tu oo2t1u o1ty u1ta ou2ta u1te u1ti u1to ou1to ou2t1op1l u2t1oond u2t1ont1 u1tu u1ty y1ta y1te y1ti y1to y1tu y1ty a1wa a1we a1wi a1wo a1wu a1wy e1wa e1we e1wi e1wo e1wu e1wy i1wa i1we i1wi i1wo i1wu i1wy o1wa o1we o1wi o1wo o1wu o1wy u1wa u1we u1wi u1wo u1wu u1wy y1wa y1we y1wi y1wo y1wu y1wy a1xi ex1a ex1i u1xa a1dr aa2d1r a2d1roet a2d1rol e1dr e2d1ramp e2d1ren e2d1rep e2d1roep e2d1rooi i1dr i2d1rig i2d1rooi i2d1rug o1dr oo2d1r oo2d3rin 1gra1fi a1tr a2t1ran1d a2t1ran1k a2t1ree a2t1reë a2t1reg. a2t1riem. a2t1ring. a2t1rug. a2t1rui1ter. a2t1ry e1tr e2t1rus. e2t1reier. e2t1reël e2t1re1ke e2t1ruim e2t1ru1br e2t1raad e2t1roed e2t1rim e2t1raam e2t1ram e2t1rot1. e2t1rot1t e2t1ring e2t1rol. e2t1riet e2t1ris1s e2t1re1pu e2t1re1ge 2d1af 3d2a1f2a 3d2a1f2é een1k 2f1af1 3f2a1f2a 3f2a1f2i nan1si an1se 2r1af1d 2r1af1g 2r1af1h 2r1af1l 2r1af1s 3r2af2s. 2r1af1t 2r1af1v 2r1af1w 2r1inf cr2af dr2af gr2af gi3r2af gi1ra .oe1fen1 .oe2fe1n2a .oe2fe1n2e .oe2fe1n2i 1oe2fen1 1oe2fe1n2a 1oe2fe1n2e 1oe2fe1n2i 4e3fee 3d2oe3fees 2d1oe2fe 4e1oe2fe 2k1oe2fe 2l1oe2fe 2m1oe2fe 2n1oe2fe 2t1oe2fe 2s1art eeg1ste .aan1 .aan2d1 .aan5d2a .aan3d2r .aan3d2e .aan4d3ete .aan3d2i .aan3d2o .aan4d1of .aan4d1oud .aan3d2u 2r1aand 1ad1min ad1m 2g1ad1min 2n1ad1min 2r1ad1min 2s1ad1min 2s1ad1vi 2s1ad1vo 1af1rig 2k1af1rig 2t1af1rig 3af1stand 4g3af1stand 4l3af1stand 4k3af1stand 4n3af1stand 4p3af1stand 4s3af1stand 2s1ak1sie 2n1s2ak1sie 2r1s2ak1sie 1a2larm 2d1a2larm 2g1a2larm 5al1leen1 al1l 2g1alleen 2k1alleen 2l1alleen 2n1alleen 2r1alleen gal1l lal1l kal1l nal1l ral1l 2s1amp 1a2rea. 1a2reas. 2f1a2rea 2m1a2rea 2n1a2rea 2p1a2rea 2t1a2rea 2s1arm 3a2syn g4a1syn 1bees1 1bid1 bi1d2e bi1d2i li1bi1d2o bos1 bo1s2e bo2s2c2h brui2n1 brui2n2d brui3n2e brui4n3eend brui3n2ing 1deur1 deu1r2e deu2r3ee deur2s1b deur2s1v brei2n1 brei3n2e brei3n2aald 3die2r3 3die3r4e1 3die3r4a1sie n2t1eie n2t1eie1ning 2s1eie 2d1eiland 2g1eiland 2l1eiland 2n1eiland 2r1eiland 2s1eiland w2eiland 2l1ek3s2am lek1sa 2s1ek1sa 5er1varing we1d6er1varing we1der1v we1de er1v e1tie2l3 e4u1r4o1p eu1ro film1 fil1m2i fil1m2o fil2m3op .ga4s1 gee2s1te2s1 gees1te3s1panning ge4l4d3 men1ge4l5d4 ge4l5d4e ge4l6d5ee ge4l5d4i ge4l6d5ins 1goed 1goud1 gou1d2a 1g2r2aa2n1 1groep 1groep1l 1gron2d1 1gron3d2e. 1gron3d2ing 1gron3d2ig 2g1rond1te. .grys1 .gry1s2e 1han2d3o hoo2f3 1hou2t1 1hou3t2e 1hou3t2ing 1illu il1l 2g1illu gil1l 2k1illu kil1l 2n1illu nil1l 2s1illu sil1l 3in1dus 2d3in1dus 2n3in1dus 2g3in1dus 2k3in1dus 2s3in1dus 2l3in1dus 2r3in1dus kaa2p3 kaa2p4s. kaa2p4s1h 1kan1toor 1kan1to1re 1kan1to ka3r2oo3 ka3r2oo3f2 ka3r2oo3l2 ka3r2oo3m2 ka3r2oo3r2 s1kas ken3ni4s3 ken1n 1kleu2r1 1kleu3r2e 1kleu4r3eg 1kleu4r3ef1fek 1kleu3r2ig 1kleu2r1in1 1kleu3r2in2g 1klier klu4b klu4b3l s1kon s2kon. 1s2ko2n1de 1s2ko1ne 1s2ko1ning 2s3ko1nin1gin 1k2on1t2ant 1k2on1t2i1 1k2on1t2i2n1g 1k2on1t2rak 1k2on1t2ak 1k2on1ta 1k2on1t2ro1le 1k2on1t2ra 1k2on1t2oer 1k2on1trei 2r3krin 2s3krin 1k2ru4l1 1land lan1de lan2d1eng1te l4aag. 1l4aai1 b2laai s2laai l4aan. 1lê1 1l2ee2r1 k2l2ee2r1t we2l3eer le2ër1 leë2r1o2 leër2s. le2ë1r2i loe2d1 1bloe2d1 1gloe2d1 loe3d2e loe3d2i loe4d3eie ly2s1 ly1s2ie s1maal3 ge3s2maal 1maat 1maat1staf 1maat1staw 2s1man 1ma1sjien s1mas 3m4ens1 3m4en1s2e 3m4en1s2i 1m2u1sie2k1 1m2u1si .my2n3 .my3n4e .my4n5ei .my4n5ent .ne2o1 .ne3o2n1 n1in n2i1ne 1n2in1k 2n3in2k. n2in2klik .wa2n3in3 2s1in1houd 3o4lie. b4o5lie. 4d3o4lie. n4g3o4lie. 4k3o4lie. 4k3o4lies. k2o3li 4l3o4lie. 4m3o4lie. mo1li 4p3o4lie. mo1no5p4o5li 1mo1no1 1mo1no2f1t 1mo1no2k1s 1mo3n2o1p 4r3o4lie. 4s3o4lie. 4t3o4lie. to1li on1der1 4g1on1der1 .dra5g2on1der 4l1on1der1 4m1on1der1 5m2on1de1r2ing 4n1on1der1 4t1on1der1 1onder1werp 1onder1wy2s3 1onder1wy3s4e 2s1on1der1w son1de son1der1s 3o2pe1ra 4l3o2pe1ra lo1pe 4p3o2pe1ra po1pe 4r3o2pe1ra ro1pe 4s3o2pe1ra so1pe 4k3o2pe1ra ko1pe .ko1pe2r1 .ko1pe2r3a 1op1lei 2m1op1lei 2r1op1lei 2s1op1tog 2s1op1tr 1pad1 pa1d2e a1tro2l1 aa2t1ro2l1 pe3t2ro2l1 pe3t2ro1l2e pe3t2ro1l2o 1par1ty1 1per3soon 2s1po1te 3pro1gram 3pro1gra4m1o pry2s1 pry3s2e 2d1rand. 2s1rand. 1reg. 2d1reg. 2t1reg. 3stad. 1s2t2o2f1 1s2t2o2w1w 1teen3 teen4d. 1s2teen3 1teen4s1w sl4uit 1fl4ui2t1 1fl4ui3t2e 1fl4ui4t3eend 1fl4ui3t2is kl4uit .oe2s1 e2l3oes 2s3oes. 2s3oes1te. 2n3oes. 1k4n4oes. 2n3oes1te. oe5l4oe oe2l1oon d3on1ge d4on1ge. g3on1ge n3on1ge ka1n4on1ge ka1no p3on1ge o4r3on1ge s3on1ge s4on1ge. 1oog. b2oog. 1dr2oog h2oog. 2k3oog. 1l2oog. pui2l3oog. 2p1oog. ge3s4oog. be1t2oog. siel3t2oog. ver3t2oog. 2p1ooi. 3oor1d2eel 3oorlog1 3oorlog2s 3oorloë1 oo2r1 p4oo2r2t k4oor2s koor3sang oo2r2d1 oo2r3d2a oo2r4d3arm oo2r3d2e oo2r3d2ig oo2r3d2in oo2r3d2ing oo2r3d2is1 oo2r3d2r noo2r2d1 noo2r4d3a2 noo2r3d2e noo2r4d3eu noo2rd1i noo2r2d3w noo2r2t noo2r3t1e noo2r3t1i on1oor1k on1oor1s on1oor1t v4oo2r1 v4oo2r2t1 v4oo2r3t2r v4oo2r4t3reis v4oo2r4t3rol v4oo2r4t3ruk voo4r5d4ra v4oor3t2a v4oor3t2e v4oor3t2o v4oor3t2ref v4oor4t1s v4oor4t2s. voor3t2u voor3t2yd pa2s1op 1pro1bleem .po2s1a .po2s1o .po2s1u 1rei2s1a 1rei1s2e 1rei2s3er4v 1rei1si 1rei2s1in1 1rei3s2in2g 1rei2s1o 1rei2s1u .reu2k1 .reu3k2e .reu3k2i 3rus1pe 1s2aa2m1 1sa1la1ri4s3 3s4a1lo 1sê1 .see3 .see3m4 .see4p1 .see5p2o1lis .see5p2os .see5p2unt .see4r1 .see5r2a .see5r2e .see6r3ee .see5r2o .see6r3oog 1sen1tra 1sen1trum 1siek 1siel 3s4ie1ning 1s2ins. .s2ins1 .sin1s2a .sin1s2pee .sin1s2peli .sin1s2t 2s1ins 3s2in1sel ge1s2ins 3s4i1tu1a1sie si1tu 1sk2ap 2s3ka1pi1taal1 3s4kool1 3s4kool2s. 3s4kroe2f1 3s4kroe3f2ie 3sol1da 3s4peel1 3s4peld spoe2d1 spoe3d2e. 5poe5d4ing s1p2r 1s2praak 1s2pra1ke 1s2pra1ki 1s2pran1kel s2pre be5s2pre 1s4preeu s2prei 1s4preuk 1s4priet 1s4p2ring 1s4p2rink 1s4p2roei 1s4p2roet 1s4p2ro1ke 1s4p2ro1kie 1s4p2rong 1s4p2ruit s1pos s1pos1te 1spier 3s4taat1 1s4taat2s 1s4taat3se. 1s4taat2s1in1 1s4taat2s1l 1s4taat2s1m 1s4taat2s1n 1s4taat2s1p 1s4taat2s1w 5s4tan1d4aard1 5s4tan1d4aar1d2e 1s2tee2k1 3s4tel1ling 3s4tel1la 3s4tel1le 3s4tel1lê 3s4tel1li toet4s5tel1ling volk4s5tel1ling 5s4tel3sel stert1 ster1t2aal ster1t2a1le ster1t2ra1li 2g1stert1 2l1stert1 2n1stert1 2p1stert1 2r1stert1 2t1stert1 ster1t2y 1s2til1stand 3s2toel 4s3toe1la 5s4torm 3s4traa2l1 3s4traa2l2s1g 3s4traa4t1 3s4traa4t2s .ka4s5traa4t 3s4tr2af1 3s4tr2a1f2yn 3s4tral 3s4tram 3s4tran4d1 3s4tran5de i1stree i1stras n1stras n1stree 5s4tra1t 3s4traw1w 3s4tre1de 3s4treef1 3s4tree4k1 3s4tree4k2s 3s4tre3k2e 3s4treel1 3s4tree4p1 3s4tre3p2ie 3s4tre3p2e 3s4trel 3s4tren 3s4tres1 3s4trep 3s4trew 3s4trib1b 3s4trik 3s4t2rin 3s4tro1ki 3s4trom 4s5trom. 4s5trom1m 4s5trom1pet 3s4trom1p 3s4trooi 3s4trook1 3s4troom1 3s4troop1 3s4trui 4s5trui. 4s5truie 3s4truk1tuu4r1 3s4truk1tu 3s4tru1w 3s4try 3s4tryd 3s4t4ryk 3s4t2oor1nis 3s4ty2l1 3s4ty3l2e 3s4ty3l2i .su1pe2r1 .su1pe3r2i 1s2weer1 aar2s3weer1 ie2s3weer1 rf2s3weer1 ng2s3weer1 ng2s3w i2s3weer1 i2s1we oor2s3weer1 oor2s3we u2s3weer1 1s2weri bor2s3weri bor2s1w ie2s3weri oe2s3weri 1trei2n1 1trei3n2e 1trei3n2i on4t3rein 1toe1stand 1toe1stel 2ë1toets 2h1toets 2r3toets 2s3toets 1tran1sa 1tran2s1at 1tuig. 1t2ui2n1 1t2ui3n2e 1t2ui3n2i 1t2ui4n3in 1t2ui5n4ing .tui4s3 twee3 .twee5 tweeb2 tweed2 .tweeg2 tweek2 tweel2 tweem2 .tween2 tweep2 .tweer2 twees2 .tweet2 tweew2 t1wee4l1d 1tyd1 tyd2s tyd3skrif ty1d2e ty1d2i ui2t1ee 2s1uit 1s2ui1te 3u2nie j4u3nie 2k1u2nie 2l1u2niea 3l2u3niet 2s1u2nie 2t1u2nie se2u2nie 3u2ni1form 4s3u2ni1form .va2k1 .va3k2an1 .va3k2er .va3k2ie .va3k2u .va4k3uit .va4k3unie 1vin3ge4r3 vi2s3arend vi2s3ete vi1seur vi2s1o4lie .vla2k1 .vla3k2oe vl4ei 1v4l4e4i4s 1v4l4e4i4s1a 1v4l4e4i4s1e 1v4l4e4i5s2e. 1v4l4e4i4s1in 1v4l4e4i4s1o 1v4l4e4i4s1u 1voël vol1struis1 vol1strui1s2i vor4s1 vor5s2e vor5s2i 3w4aar1dig 3w4aar1de 3wa1te2r3 3wa1te3r4ig .k4water a1de1k4wa 1wee4f 1wee5fonds wee4g1 1weer1 1weer2s1om1 1weer2s3v 1weer2s3w 1werk wer2k1l wer3k2lank wer3k2leur .wer2k1r .wer2k1w wer1ko wer2k1op1 wer2k1om1g wer2k1om1s wer2k1on1 wer2k1ont1 wer2k1uur wer2k1ure 1wê1rel4d1 1wet d3wet k2wets k2wet1ter s1wet s2wets s3wets1ont s3wet. s3wet1te. s2wol 3win1ke2l3 winkel4e winke3l4ie 1win1te2r1 winter2s2 win1te 1wo2l 1wo2l1a 1wo2l1d 1wo2l1g 1wo2l1i 1wo2l1m 1wo2l1o 1wo2l1p 1wo2l1s re1wo3l2u re1wo 2k1wol 3w4oo 4k3w4oo woo2r2d1 woo2r3d2a woo2r4d3arm woo2r3d2e woo2r3d2ig woo2r3d2in woo2r3d2ing woo2r3d2is1 woo2r4d3r wyd1 wy1d2e wy1di 3wy1se 3wy1ses yste2r1 yste2r2e yste2r2ing 2d3ys2ter 2e3ys2ter 2f3ys2ter 2g3ys2ter 2k3ys2ter 2m3ys2ter 2n3ys2ter 2p3ys2ter 2s3ys2ter 2t3ys2ter 2u3ys2ter ystert2 e3y2wer s3y2wer a2me1ri1ka a1me1ri .bene6 .di2a1 .di2o1 .ina4 .ine4 i4o1na i4o1ne i4o1ni i4o1no i4o1nu ge3p2oog ge1po .one4 5vil4le. vil1l ri4d4g4 .se3k2uur. .se1ku i1ge. i1ger. i1ges. 3aard. aard1w 3aards. 2k3aard. 2k3aards. 2s3aard. 2s3aar1de. 2s3aards. 3aar3dig 4n3aar3dig b4aard. v4aard 3ag3tig. ag1t 3ag3tig1heid 3ag3ti1ge 3ag3tigs. 3ag3tig1ste 2bag1tig bag1t 2dag1tig dag1t n4d4ag1tig 2fag1tig 2gag1tig 2kag1tig kag1t 4l1ag1tig lag1t sl4ag1tig slag1t 2m4ag1tig mag1t i2m5agtig o2m5agtig u2m5agtig 2nagtig nag1t 4pagtig pag1t 2ragtig rag1t 1d4r4agtig drag1t 1k4r4agtig krag1t 1pr4agtig prag1t 1wr4agtig wrag1t 4s3agtig sag1t .t4agtig 2t1agtig .bi1g 1big 1bi1ge 1dig. 1di1ge 1di2g1ste. 1kund 1kuns 1bund 1tig. 1ti1ge 1ti2g1ste. 1jig1 1kig 1ki1ge s2ki2g 1lig1 li1g2a li1g2e li1g2o li2g3om p2lig plig2s ig2s. ilig2s 1mig 1mi1ge 1mi2g1ste. 1nig 1ni1ge 1ni2g1een 1ni1gi r2ig. 1d2ing 1f2ing 3g4ing 1h2in2g j2in2g 1k2in2g 1l2in2g 1s4lin1ger s1l2ing 3m2ing 3m2ings1 1n2in2g ko1nin3gin ko1ni 3p2i2n2g 1ring b2ring d2ring k2ring 1s2ing 1t2ing 1wi2ng y1ing ein1g o1ing tuin1g lin3guis 3i4n5genieur in3ge1 be1las1tin4g3 be1las1tin4g4s 1ket1tin4g 1ket1tin4g1a 1ket1tin4g1e 1ket1tin4g1r ket1t 1lin2g1a 1lin3ge 1lin2g1in 1lin2g1r ko1rin4g rig1tin4g rig1t ves1tin4g 4d3ste. 4d3stes. es1te. e2s3tes. e2s3ter. e2s3ters. 4f3ste. 4f3ster 4f3stes. 4g3ste. 4g3ster 4g3sters 4g4s1te1ra 4g4s1ter1m 4g4s1ter2m. 4g4s1ter1rei 4g3ster1r 4g3stes. 4k3ste. 4k3ster 4k4s1te1ra 4k3sters 4k3stes. 4l3ste. 4l3ster 4l3sters 4l3stes. 4m3ste. 4m3ster 4m3sters 4m3stes. 4n3ste. 4n3stes. 4n3ster 4n3sters 4n4s1te1ra 4n5s2te2r1ag 4n3ster1m 4n3ster2m. 4n3ster1rei 4n3ster1r 4p3ste. 4p3ster 4p4s1ter1m 4p3stes. 4r3ste 4r4s1tee. 4r4s1teer 4r4s1teg 4r4s3te1hui 4r3ste1hu 4r4s1te1ken 4r3s2te1ke 4r4s1tem1po 4r4s1tend 4r4s1tens 4r3ster 4r3stes. 4t3ste. 4t3stes. d2s1k2l g2s1t2r ng2str ng1dr n2s1k2l n2g2s1k2l 2s1k2l2 1s2k2l2e1ro1 2s3aan me3s4aan se3s4aan mo3s4aan s1lie .eks1 .ek1s2a .ek1s2e .ek1s2i .ek1s2o .ek1s2u .ek1s2y ëks1 ëk1s2a ëk1s2e ëk1s2i ëk1s2o ëk1s2u ëk1s2y s1tr b1s2tr s2trak s2trek s2trem s2trib s2triem s2trop s2trok s2tronk 1s2t2ro1fa 1s2t2ro1fe. 1s2t2ro1fes 1s2t2ro1fies stro1fe s1tro1fie",
  ["minhyphenmax"]=1,
  ["minhyphenmin"]=1,
  ["n"]=3330,
 },
 ["version"]="1.001",
}