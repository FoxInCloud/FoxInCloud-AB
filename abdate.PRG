* {fr} abDate.prg
* =====================================================
* (c) Abaque SARL, 66 rue Michel Ange - 75016 Paris - France
* contact@FoxInCloud.com - http://foxincloud.com/ - +33 9 53 41 90 90
* {fr} -----------------------------------------------------
* {fr} Ce logiciel est distribué sous GNU General Public License, tel quel, sans aucune garantie
* {fr} Il peut être utilisé et/ou redistribué sans restriction
* {fr} Toute modification doit être reversée à la communauté
* {fr} La présente mention doit être intégralement reproduite dans toute copie même partielle
* {en} -----------------------------------------------------
* {en} This software is distributed under the terms of GNU General Public License, AS IS, without any warranty
* {en} It can be used and/or distributed without restriction
* {en} Any modification or improvement must be given for free to the community
* {en} This permission notice shall be entirely included in all copies or substantial portions of the Software
* =====================================================

#INCLUDE AB.H
#define DATE_SEP	'/|.:;$,'
#define SIXTY	60

AB()
return abUnitTests()

* ================================================
function cJJHHMMSS && {fr} "JJ j HH:MM:SS" d'après une durée en secondes {en}
lparameters ;
  tnSecs; && {fr} Nombre de secondes
, tlFixedLen && [.F.] {fr} Taille fixe (15 caractères)
local lcResult
lcResult = space(iif(m.tlFixedLen, 15, 0))

if vartype(m.tnSecs) == 'N' ;
 and m.tnSecs >= 0

 	local lnDays, lcDays
 	lnDays = int(m.tnSecs / 3600 / 24)
 	lcDays = iif(m.lnDays > 0, ltrim(str(m.lnDays)) + ' j ', '')
 	lcResult = textmerge([<<m.lcDays>><<cHHMMSS(Mod(m.tnSecs, 24*3600))>>])
endif

return m.lcResult

* ---------------------------------------------------------
procedure cJJHHMMSS_test && {fr} Teste cJJHHMMSS()

local loTest as abUnitTest of abDev.prg
loTest = newobject('abUnitTest', 'abDev.prg')

loTest.Test("1 j 01:00:00", 25*3600)
loTest.Test("23:00:00", 23*3600)

return loTest.Result()

* ================================================
function cHHMMSS && {fr} HH:MM:SS d'après une durée en secondes
lparameters ;
  tnSecs; && {fr} Nombre de secondes
, tlFixedLen; && [.F.] {fr} Taille fixe (8 caractères)
, tlLtrim && [.F.] {fr} Supprimer les heures si = 0

local lnHours, lnMins, lnSecs, lcResult
lcResult = space(iif(m.tlFixedLen, 8, 0))

if vartype(m.tnSecs) == 'N' ;
 and m.tnSecs >= 0

	store 0 to m.lnHours, m.lnMins
	lnSecs = round(m.tnSecs, 0)

	if m.lnSecs >= SIXTY
		lnMins = int(m.lnSecs / SIXTY)
		lnSecs = mod(m.lnSecs, SIXTY)
		if m.lnMins >= SIXTY
			lnHours = int(m.lnMins / SIXTY)
			lnMins = mod(m.lnMins, SIXTY)
		endif
	endif

	lcResult = ;
		Iif(lTrue(m.tlLtrim) and m.lnHours = 0;
			, space(iif(m.tlFixedLen, 3, 0));
			, padl(ltrim(str(m.lnHours)), 2, '0') + ':');
	+	padl(ltrim(str(m.lnMins)), 2, '0') + ':';
	+	padl(ltrim(str(m.lnSecs)), 2, '0')
endif

return m.lcResult

* ---------------------------------------------------------
procedure cHHMMSS_test && {fr} Teste cHHMMSS()

local loTest as abUnitTest of abDev.prg
loTest = newobject('abUnitTest', 'abDev.prg')

loTest.Test("00:00:00", 00)
loTest.Test("00:00:59", 59)
loTest.Test("00:01:00", 59.9)
loTest.Test("00:01:00", 60)
loTest.Test("00:01:00", 60.1)
loTest.Test("00:01:01", 61)
loTest.Test("00:59:59", 3600-1)
loTest.Test("01:00:01", 3600+1)
loTest.Test("24:00:10", 24*3600+10)
loTest.Test("99:00:00", 99*3600)
loTest.Test('', -1)

return loTest.Result()

* ================================================
function cHHMMSecs && {fr} HH:MM d'après une durée en secondes
lparameters tnSecs && {fr} Nombre de minutes
local lcResult

lcResult = cHHMMSS(m.tnSecs)
if not empty(m.lcResult)

	lcResult = left(m.lcResult, 5)
endif

return m.lcResult

* ================================================
function cHHMM && {fr} HH:MM d'après une durée en minutes
lparameters tnMins && {fr} Nombre de minutes
local lcResult

lcResult = cHHMMSecs(m.tnMins * SIXTY)

return m.lcResult

* ---------------------------------------------------------
procedure cHHMM_test && {fr} Teste cHHMM()

local loTest as abUnitTest of abDev.prg
loTest = newobject('abUnitTest', 'abDev.prg')

loTest.Test("02:05", 125)

return loTest.Result()

* ================================================
function cYMDHMS && {fr} "Y,M,D[,H,M,S]" d'après une date ou dateTime
lparameters ;
  tuDate; && [DateTime()] {fr} Date ou dateTime
, tlJS && {fr} Javascript

local luDate, lcType, liJS, lcResult

luDate = iif(vartype(m.tuDate) $ 'DT', m.tuDate, datetime())
lcType = vartype(m.luDate)
liJS = iif(lTrue(m.tlJS), -1, 0) && {fr} base 0 en javascript

lcResult = cWords(',' ;
	, ltrim(str(year(m.luDate)));
	, ltrim(str(month(m.luDate) + m.liJS));
	, ltrim(str(day(m.luDate)));
	)
if m.lcType == 'T'
	lcResult = cWords(',' ;
		, m.lcResult;
		, ltrim(str(hour(m.luDate) + m.liJS));
		, ltrim(str(minute(m.luDate) + m.liJS));
		, ltrim(str(sec(m.luDate) + m.liJS));
		)
endif

return m.lcResult

* ================================================
function cY_M_D_H_M_S(tt)
return stuffc(stuffc(stuffc(stuffc(stuffc(Ttoc(Evl(m.tt, Datetime()), 1), 13, 0, '-'), 11, 0, '-'), 9, 0, '_'), 7, 0, '-'), 5, 0, '-')
endfunc

* ================================================
function nYear && {fr} Année avec ou sans siècle, -1 si invalide
lparameters tuYear && {fr} Contient l'année présumée (CNDT)

local lcType

lcType = vartype(m.tuYear)

return icase(;
	m.lcType == 'N',;
		m.tuYear,;
	m.lcType == 'C' and isdigit(alltrim(m.tuYear)),;
		val(m.tuYear),;
	m.lcType $ 'DT',;
		year(m.tuYear),;
		-1;
	)

* ================================================
function lYear && {fr} Ce nombre peut être considéré comme une année
lparameters tnYear && {fr} Année présumée

return .t.;
 and vartype(m.tnYear) == 'N' ;
 and m.tnYear - int(m.tnYear) = 0 ; && {fr} entière
 and between(tnYear, 0, 3000)

* ================================================
function nYearCent && {fr} Année avec le siècle
lparameters tuYear && {fr} Année avec ou sans le siècle (CNDT)

local lnYear
lnYear = nYear(m.tuYear)

#define CENT_CURRENT int(year(date())/100)*100
#define CENT_ROLLOVER year(date()) - CENT_CURRENT + 30 && -70 ans à + 30 ans

return icase(;
	!lYear(m.lnYear),;
		0,;
	m.lnYear >= 100,;&& {fr} année avec siècle
		m.lnYear,;
		CENT_CURRENT - iif(m.lnYear > CENT_ROLLOVER, 100, 0) + m.lnYear;
	)

* -----------------------------------------------------
procedure nYearCent_test && {fr} Teste nYearCent()

local loTest as abUnitTest of abDev.prg
loTest = newobject('abUnitTest', 'abDev.prg')

loTest.Test(0, 2004.25)
loTest.Test(2004, 2004)
loTest.Test(2004, 04)
loTest.Test(2033, 33)
loTest.Test(2040, 40)
loTest.Test(1999, 99)

return loTest.Result()

* ================================================
function cYearCent && {fr} Année avec le siècle
lparameters tuYear && {fr} Année avec ou sans le siècle (CNDT)

local lnYearCent

lnYearCent = nYearCent(m.tuYear)

return iif(m.lnYearCent = 0, '', ltrim(str(m.lnYearCent)))

* ---------------------------------------------------------
procedure cYearCent_test && {fr} Teste cYearCent

local loTest as abUnitTest of abDev.prg
loTest = newobject('abUnitTest', 'abDev.prg')

loTest.Test('', '2004,25')
loTest.Test('2004', '2004')
loTest.Test('2004', '04')
loTest.Test('2033', '33')
loTest.Test('1940', '40')
loTest.Test('1999', '99')

return loTest.Result()

* ================================================
function nYearNoCent && {fr} Année sans le siècle
lparameters tuYear && {fr} Année avec ou sans le siècle (CNDT)

local lnYear

lnYear = nYear(m.tuYear)

return icase(;
	!lYear(m.lnYear),;
		-1,;
	m.lnYear < 100,;&& {fr} année sans siècle
		m.lnYear,;
		m.lnYear - int(m.lnYear / 100) * 100;
	)

* ---------------------------------------------------------
procedure nYearNoCent_test && {fr} teste nYearNoCent

local loTest as abUnitTest of abDev.prg
loTest = newobject('abUnitTest', 'abDev.prg')

loTest.Test(-1, 4.25)
loTest.Test(00, 2000)
loTest.Test(4, 2004)
loTest.Test(33, 2033)
loTest.Test(40, 2040)
loTest.Test(99, 1999)

return loTest.Result()

* ================================================
function cYearNoCent && {fr} Année sans le siècle
lparameters tuYear && {fr} Année avec ou sans le siècle (CNDT)

local lnYearNoCent

lnYearNoCent = nYearNoCent(m.tuYear)

return iif(m.lnYearNoCent >= 0;
	, padl(ltrim(str(m.lnYearNoCent)), 2, '0');
	, '';
	)

* ---------------------------------------------------------
procedure cYearNoCent_test && {fr} teste cYearNoCent()

local loTest as abUnitTest of abDev.prg
loTest = newobject('abUnitTest', 'abDev.prg')

loTest.Test('', 4.25)
loTest.Test('00', 2000)
loTest.Test('04', 2004)
loTest.Test('33', 2033)
loTest.Test('40', 2040)
loTest.Test('99', 1999)

return loTest.Result()

* ================================================
function cYearOrder && {fr} Ordre de tri des années
lparameters tuYear && {fr} Année avec ou sans le siècle (CNDT)

return evl(cYearCent(m.tuYear), '0000')

* ================================================
function nMonth && {fr} N° de mois compris entre 1 et 12
lparameters tnMonth && {fr} n° de Mois

return iif(vartype(m.tnMonth)=='N';
	, min(max(m.tnMonth;
			, 01); && {fr} janvier
			, 12); && {fr} décembre
	, 0;
	)

* ================================================
function cMMAA && {fr} Date MM/AA à partir d'un date JJ/MM/AA avec ou sans JJ et MM ou des MM et AA séparés
lparameters ;
  tcDate; && @ {fr} Date complète [[JJ/]MM/]AA[AA]
, tcMois; && @ [''] {fr} Mois séparé
, tcAn	 && @ [''] {fr} An séparé

local lcResult
lcResult = ''

if  .f.;
 or vartype(m.tcDate) = 'C' and ! empty(m.tcDate) ;
 or vartype(m.tcMois) = 'C'  and ! empty(m.tcMois) ;
 or vartype(m.tcAn) = 'C' and ! empty(m.tcAn)

	if ! empty(m.tcDate)	 && {fr} Date fournie complète
		tcDate = alltrim (m.tcDate)

* {fr} Localiser les éventuels séparateurs entre jours, mois et année
		local lnPosSepJM, lnPosSepMA
		lnPosSepJM = nAtSep (m.tcDate, DATE_SEP)
		lnPosSepMA = nRAtSep (m.tcDate, DATE_SEP)
		if m.lnPosSepMA > 1
			lnPosSepJM = iif(m.lnPosSepJM = m.lnPosSepMA, 0, m.lnPosSepJM)
			tcMois = cFigures(substr (m.tcDate, m.lnPosSepJM + 1, m.lnPosSepMA - 1))
		else
			tcMois = ''
		endif
		if m.lnPosSepMA >= 0
			tcAn = cFigures(substr (m.tcDate, m.lnPosSepMA + 1))
		endif
	endif

	local llAnNul, llMoisNul
	llMoisNul = empty(m.tcMois)
	llAnNul = empty(m.tcAn) && 00 pour 2000 n'est pas un an nul
	if m.llAnNul and !m.llMoisNul && {fr} l'année a été passée à la place du mois
		tcAn = m.tcMois
		tcMois = ''
		llAnNul = .f.
	endif

* {fr} Année: Ajuster le siècle
	if ! m.llAnNul and len (m.tcAn) <= 2 && {fr} Année à deux chiffres
		local lnAn, lcSiecle
		lnAn = val (m.tcAn)
		lcSiecle = iif(m.lnAn <= 50,; && {fr} Année entre 2000 et 2050
							'20', '19')
		tcAn = m.lcSiecle + padl (alltrim (str (m.lnAn)), 2, '0')
	endif

	llMoisNul = val(m.tcMois) = 0
	tcMois = iif(m.llMoisNul, '', padl(alltrim(m.tcMois), 2, '0'))

	tcDate = '';
		+ iif(m.llMoisNul, '', alltrim (m.tcMois));
		+ iif(m.llMoisNul or m.llAnNul, '', '/');
		+ iif(m.llAnNul, '', iif(m.llMoisNul, m.tcAn, right(alltrim(m.tcAn), 2))) && {fr} Ne garder que les années !

	lcResult = m.tcDate
endif && {fr} Vartype(tcDate) = 'C' ...

return m.lcResult

* ---------------------------------------------------------
procedure cMMAA_test && {fr} Test de cMMAA()
?
? sys(16)
? 'N°  Retour  Résultats'
local i, lcDate, lcMois, lcAn, llResult
for m.i = 1 to 9
	store '' to m.lcDate, m.lcMois, m.lcAn
	do case
	case m.i = 1
	case m.i = 2
		lcMois= '10'
		lcAn = '56'
	case m.i = 3
		lcDate = '12/2001'
	case m.i = 4
		lcDate = '.12/96-'
	case m.i = 5
		lcDate = '00-->'
	case m.i = 6
		lcMois= '00'
		lcAn = 'toto'
		lcDate = '1984   '
	case m.i = 7
		lcDate = '  89'
	case m.i = 8
		lcDate = '1986/02'
	case m.i = 9
		lcDate = '01/11/1989'
	endcase
	lcResult = cMMAA (@m.lcDate, @m.lcMois, @m.lcAn)
	? str(m.i, 2) + '.'
	?? m.lcResult + ' = ' + m.lcMois + '/' + m.lcAn + ' - ' + m.lcDate
endfor

* ================================================
function cMMAAofXL1900 && {fr} Date "MM/AA" à partir d'un date en nombre excel base 1900
lparameters tuXL1900 && {fr} C|N nombre représentant une date dans Excel, base 1900 (standard XL pour Windows)

return substr(cJJMMAAofXL1900(m.tuXL1900), 4)

* ================================================
function cJJMMAAofXL1900 && {fr} Date "JJ/MM/AA" à partir d'un date en nombre excel base 1900
lparameters tuXL1900 && {fr} C|N nombre représentant une date dans Excel, base 1900 (standard Excel pour Windows)

local lcResult; && {fr} Date "JJ/MM/AA"
, lcType;
, lnXL1900;
, loDate as abSet of abDev.prg

lcResult = ''

lcType = vartype(m.tuXL1900)
if m.lcType $ 'CN'

	lnXL1900 = iif(m.lcType == 'N', m.tuXL1900, val(m.tuXL1900))
 	if m.lnXL1900 > 0

	 	loDate = abSet('DATE', 'FRENCH')
		lcResult = dtoc(date(1899, 12, 30) + m.lnXL1900) && 00/01/1900 dans Excel
	endif
endif

return m.lcResult

* -----------------------------------------------------------------
procedure cJJMMAAofXL1900_Test && {fr} teste cJJMMAAofXL1900(), nouvelle version

local loTest as abUnitTest of abDev.prg
loTest = newobject('abUnitTest', 'abDev.prg')

loTest.Test('30/04/84', 30802) && 30/04/1984 dans excel
loTest.Test('01/05/84', 30803) && 01/05/1984 dans excel
loTest.Test('01/12/01', 37226)

return loTest.Result()

* ================================================
function cAAAAMM && <Année>/<mois en 2 chiffres>
lparameters tu && [Date()] {fr} Date ou date & heure ou nombre AAAAMM
tu = evl(m.tu, date())

return padr(;
			alltrim(str(year(m.tu)));
		+ '/';
		+ padl(alltrim(str(month(m.tu))), 2, '0');
		, 7)

* ================================================
function cAAAA_MMMM && {fr} <Année> <mois en toutes lettres>
lparameters tu && [Date()] {fr} Date ou date & heure ou nombre AAAAMM
tu = evl(m.tu, date())

local lcType, lnYear, lnMonth, ld, lcDate, llResult, lcResult
lcResult = ''

lcType = vartype(m.tu)
if m.lcType == 'N' and m.tu > 0
	tu = int(m.tu)
	llResult = between(m.tu, 1, 999912) && {fr} When using strict date formats, {^0001-01-01}, January 1st, 1 A.D to {^9999-12-31}, December 31st, 9999 A.D.
	assert m.llResult message cAssertMsg(textmerge([<<Program()>> - donnée invalide : <<m.tu>>]))
	if m.llResult

		lnMonth = m.tu % 100
		llResult = between(m.lnMonth, 1, 12)
		assert m.llResult message cAssertMsg(textmerge([<<Program()>> - donnée invalide : <<m.tu>>]))
		if m.llResult

			lnYear = int((m.tu-m.lnMonth)/100)
			tu = date(m.lnYear, m.lnMonth, 1)
			lcType = 'D'
		endif
	endif
endif

if m.lcType $ 'DT'

	lcDate = set("Date")
	set date long
	lcResult = dtoc(iif(m.lcType == 'D', m.tu, ttod(m.tu)))
	set date &lcDate
	lcResult = getwordnum(m.lcResult, 4) + space(1) + getwordnum(m.lcResult, 3)
endif

return padr(m.lcResult, 15)

* ================================================
function cDateOrder && {fr} Ordre d'une date (AAAAMMJJ)
lparameters tcDate && {fr} Date sous la forme [JJ][MM]AA[AA], séparée par '.', '/', ou '-'

local lcResult
lcResult = space(8)

* {fr} Si une date valide a été passée
if vartype(m.tcDate) == 'C' ;
 and val(chrtran(m.tcDate, DATE_SEP, '')) > 0

* {fr} Localiser les éventuels séparateurs d'an et de mois
	local lnSepAn, lnSepMois
	lnSepAn = nRAtSep(m.tcDate, DATE_SEP, 1)
	lnSepMois = nRAtSep(m.tcDate, DATE_SEP, 2)

* {fr} Calculer l'an (avec le siècle), le mois et le jour en numérique
	local lnAn, lnMois, lnJour
	lnAn = nYearCent(val(substr(m.tcDate, m.lnSepAn + 1)))
	lnMois = val(substr(m.tcDate, m.lnSepMois + 1, m.lnSepAn - 1))
	lnMois = iif(m.lnMois < 1 or m.lnMois > 12, 1, m.lnMois)
	lnJour = val(substr(m.tcDate, 1, m.lnSepMois - 1))
	lnJour = iif(m.lnJour < 1 or m.lnJour > 31, 1, m.lnJour)

* {fr} Calculer le résultat
	lcResult = dtoc(date(m.lnAn, m.lnMois, m.lnJour), 1) && 1 Returns the date in a format suitable for indexing
endif

return m.lcResult

* ------------------------------------------------
procedure cDateOrder_test

local loTest as abUnitTest of abDev.prg
loTest = newobject('abUnitTest', 'abDev.prg')

loTest.Test(space(8), '')
loTest.Test('20010101', '01')
loTest.Test('20030101', '1.03')
loTest.Test('20030401', '4.03')
loTest.Test('20030402', '2.4.03')

return loTest.Result()

* ================================================
function tDateCTime && {fr} Date et Heure d'après la date et l'heure en caractères (issue de aDir() par ex.)
lparameters ;
  td; && {fr} Date
, tcTime && {fr} Heure en caractères

return iif(vartype(m.td) == 'D' ;
			 and vartype(m.tcTime) == 'C' ;
			 and ':' $ m.tcTime;
		 , ctot(dtoc(m.td) + space(1) + m.tcTime);
		 , .null.)

* ================================================
function cDateLong && {fr} Date longue
lparameters ;
  tu; && {fr} [Datetime()] Date ou date-heure
, tlNoDay && [.F.] {fr} ôter le jour de la semaine

tu = Evl(m.tu, Datetime())

local lcResult;
, llResult;
, lcType;
, lcDate

lcResult = ''

lcType = vartype(m.tu)
llResult = m.lcType $ 'DT'
assert m.llResult message cAssertMsg(textmerge("<<Program()>> - Invalid parameter <<cLitteral(m.tu)>>"))
if m.llResult

	lcDate = set("Date")
	set date long
	lcResult = proper(iif(m.lcType == 'T', ttoc(m.tu), dtoc(m.tu)))
	set date &lcDate

	if lTrue(m.tlNoDay)
		lcResult = '';
			+ getwordnum(m.lcResult, 2) + space(1);
			+ getwordnum(m.lcResult, 3) + space(1);
			+ getwordnum(m.lcResult, 4)
	endif
endif

return m.lcResult

* ================================================
function cDateLongAbbr && {fr} Jour en toutes lettres et date du mois
lparameters tu && {fr} Date ou date-heure

local lcResult;
, llResult;
, lcWords, lnWords

lcResult = ''

lcWords = cDateLong(m.tu)
lnWords = getwordcount(m.lcWords)
llResult = m.lnWords > 1
if m.llResult

	lcResult = getwordnum(m.lcWords, 1) + ' ' + getwordnum(m.lcWords, 2)
endif

return m.lcResult
endfunc

* ================================================
function cMonthFR && {fr} Mois en français
lparameters tnMonth && {fr} N° du mois

return icase(;
	!vartype(m.tnMonth) == 'N', transform(m.tnMonth) + '?',;
	m.tnMonth = 01, 'janvier',;
	m.tnMonth = 02, 'février',;
	m.tnMonth = 03, 'mars',;
	m.tnMonth = 04, 'avril',;
	m.tnMonth = 05, 'mai',;
	m.tnMonth = 06, 'juin',;
	m.tnMonth = 07, 'juillet',;
	m.tnMonth = 08, 'août',;
	m.tnMonth = 09, 'septembre',;
	m.tnMonth = 10, 'octobre',;
	m.tnMonth = 11, 'novembre',;
	m.tnMonth = 12, 'décembre',;
	textmerge('n° de mois non supporté : <<m.tnMonth>>');
	)
endfunc

* ================================================
function iAge && {fr} Age en années entières
lparameters td
return iYears(m.td, date())
endfunc

* ================================================
function iYears && {fr} Années entières entre deux dates ou date-heures
lparameters ;
  tdBeg; && {fr} date ou date-heure début
, tdEnd && {fr} date ou date-heure fin

local llResult, lnMonthEnd, lnMonthBeg

llResult = vartype(m.tdBeg) $ 'DT' and vartype(m.tdEnd) $ 'DT'
assert m.llResult message cAssertMsg(textmerge([<<Program()>> - Deux paramètres date ou date-heure attendu eu lieu de <<cLitteral(m.tdBeg)>> et <<cLitteral(m.tdEnd)>>]))
if m.llResult

	lnMonthEnd = month(m.tdEnd)
	lnMonthBeg = month(m.tdBeg)

	return year(m.tdEnd);
		- year(m.tdBeg) ;
		- iif(.f.;
			or m.lnMonthEnd < m.lnMonthBeg;
			or m.lnMonthEnd = m.lnMonthBeg and day(m.tdEnd) < day(m.tdBeg);
			, 1;
			, 0;
			)

else
	return .null.
endif

* ---------------------------------------------------------
procedure iYears_test && {fr} Teste iYears()

local loTest as abUnitTest of abDev.prg
loTest = newobject('abUnitTest', 'abDev.prg')

loTest.Test(6, date(2000, 9, 15), date(2007, 2, 15))
loTest.Test(7, date(2000, 9, 15), datetime(2007, 9, 15, 10, 0, 0))

return loTest.Result()

* ================================================
function iAgeMonths && {fr} Age en mois entiers
lparameters td
return nMonths(m.td, date())

* ================================================
function iMonth && {fr} Mois à partir d'une valeur en caractères
lparameters tcMonth
tcMonth = proper(cEuroANSI(left(alltrim(evl(m.tcMonth, '')), 3)))

return icase(;
	empty(len(chrtran(m.tcMonth, '01234856789', ''))) and between(cast(m.tcMonth as i), 1, 12), cast(m.tcMonth as i),;
	len(trim(m.tcMonth)) < 3, .null.,;
	inlist(m.tcMonth, 'Jan'), 01,;
	inlist(m.tcMonth, 'Fev', 'Feb'), 02,;
	inlist(m.tcMonth, 'Mar'), 03,;
	inlist(m.tcMonth, 'Avr', 'Apr'), 04,;
	inlist(m.tcMonth, 'Mai', 'May'), 05,;
	inlist(m.tcMonth, 'Jun'), 06,;
	inlist(m.tcMonth, 'Jui', 'Jul'), 07,;
	inlist(m.tcMonth, 'Aou', 'Aug'), 08,;
	inlist(m.tcMonth, 'Sep'), 09,;
	inlist(m.tcMonth, 'Oct'), 10,;
	inlist(m.tcMonth, 'Noc'), 11,;
	inlist(m.tcMonth, 'Dec'), 12,;
	.null.;
)

* ================================================
function nMonths && {fr} Nombre de mois entre deux dates ou dates-heure /!\ à renommer 'iMonths'
lparameters ;
  tu1; && {fr} date ou date-heure de départ
, tu2 && {fr} date ou date-heure d'arrivée

return iif(vartype(m.tu1) $ 'DT' and vartype(m.tu2) $ 'DT';
		, month(m.tu2) - month(m.tu1) + (year(m.tu2) - year(m.tu1)) * 12;
		, .null.;
		)

* ---------------------------------------------------------
procedure nMonths_test && {fr} Teste nMonths()

local loTest as abUnitTest of abDev.prg
loTest = newobject('abUnitTest', 'abDev.prg')

loTest.Test(5, date(2006, 9, 15), date(2007, 2, 1))

return loTest.Result()

* ================================================
function nWeeks && {fr} Nombre de semaines (périodes de 7 jours) entre deux dates ou dates-heure
lparameters ;
  tdt1; && {fr} date ou date-heure de départ
, tdt2 && {fr} date ou date-heure d'arrivée

local lcType1, lcType2, llResult, lnResult
lnResult = .null.

lcType1 = vartype(m.tdt1)
lcType2 = vartype(m.tdt2)
llResult = m.lcType1 $ 'DT' and m.lcType2 $ 'DT'
assert m.llResult message cAssertMsg(textmerge([<<Program()>> - Invalid parameters(s) type : <<m.tdt1>> or <<m.tdt2>> should be date or date-time]))
if m.llResult

	lnResult = floor((iif(m.lcType2 == 'D', m.tdt2, ttod(m.tdt2)) - iif(m.lcType1 == 'D', m.tdt1, ttod(m.tdt1)))/7)
endif

return m.lnResult

* ---------------------------------------------------------
procedure nWeeks_test && {fr} Teste nWeeks()

local loTest as abUnitTest of abDev.prg
loTest = newobject('abUnitTest', 'abDev.prg')

loTest.Test(19, date(2006, 9, 15), date(2007, 2, 1))
loTest.Test(19, datetime(2006, 9, 15), date(2007, 2, 1))

return loTest.Result()

* ================================================
function nWeeksOld && {fr} Âge en semaines (périodes de 7 jours) d'une date ou date&heure
lparameters tdt && {fr} date ou date-heure
return nWeeks(m.tdt, date())

* ================================================
function dWeekCurFirst && {fr} Date du premier jour de la semaine courante
local ld
ld = date()
return m.ld - dow(m.ld,0) + 1

* ================================================
function cdWeekCurFirst && {fr} Littéral date du premier jour de la semaine courante
return cLitteral(dWeekCurFirst())

* ================================================
function cYearWeek && {fr} AAAA|SS à partir d'une date ou d'une date-heure
lparameters ;
  tdt; && {fr} date ou date&heure
, tcSep && ['|'] {fr} séparateur entre l'année et la semaine
tdt = nvl(m.tdt, uEmpty('D'))
tcSep = iif(vartype(m.tcSep) == 'C' and not empty(m.tcSep), m.tcSep, '|')

return transform(year(m.tdt), '@L 9999') + m.tcSep + transform(week(m.tdt,0,0), '@L 99')

* ================================================
function dInC && {fr} Date à l'intérieur d'une chaîne de caractères
lparameters ;
  tc && @ {fr} Chaîne, au retour avec date ôtée
local loRegExp as abRegExp of abtxt.prg, llResult, lcResult, ldResult

llResult = vartype(m.tc) == 'C' and not empty(m.tc)
if m.llResult

	loRegExp = createobject('abRegExp')
	loRegExp.setup('\d+/\d+/\d\d+', .t., .t., .f.)
	llResult = loRegExp.Execute(m.tc) = 1
	if m.llResult

		lcResult = loRegExp.matches[2]&& [index, valeur, submatches]
		ldResult = ctod(m.lcResult)
		llResult = not empty(m.ldResult)
		if m.llResult

			tc = strtran(m.tc, m.lcResult, '')
		endif
	endif
endif

return iif(m.llResult, m.ldResult, uEmpty('D'))

* ---------------------------------------------------------
procedure dInC_test && {fr} Teste dInC()

local loTest as abUnitTest of abDev.prg
loTest = newobject('abUnitTest', 'abDev.prg')
loTest.envSet('SET SYSFORMATS ON')

loTest.Test(date(2008, 1, 12), "toto 12/1/2008")
loTest.Test(date(2008, 2, 1), "toto 1/2/08 est le meilleur")
loTest.Test(uEmpty('D'), "toto 1/2/8 est le meilleur")

return loTest.Result()

* ================================================
function TtocSep && {fr} Ttoc(, 1) avec an, mois, jour, etc. séparés
lparameters ;
  tt;
, tcSep && ['.'] {fr} séparateur entre an, mois, jour, etc.
tcSep = left(alltrim(evl(m.tcSep, '.')), 1)

local lnLen, lnSep, lnPos, lcResult

lcResult = ttoc(evl(m.tt, datetime()), 1)
lnLen = len(m.lcResult)

for lnSep = 1 to 5
	lnPos = m.lnLen - 2*m.lnSep
	lcResult = substr(m.lcResult, 1, m.lnPos) + m.tcSep + substr(m.lcResult, m.lnPos+1)
next

return m.lcResult

* ================================================
function DtocSep && {fr} Dtoc(, 1) avec an, mois, jour, etc. séparés
lparameters ;
  tt;
, tcSep; && ['.'] {fr} séparateur entre an, mois, jour, etc.

return left(TtocSep(m.tt, m.tcSep), 10)
endfunc

* ================================================
function cSecs && {en} number of seconds with unit formatted in current user language
lparameters tnSecs && {en} number of seconds

local cLangUser
cLangUser = cLangUser()
return Ltrim(ICase(;
	!Vartype(m.tnSecs) == 'N',;
		'',;
	m.tnSecs >= 60 * 5,;
		cHHMMSS(m.tnSecs),;
		transform(m.tnSecs, ICase(; && 2016-03-23 thn -- {en} lTrim(): don't prepend a space for use in ? command
			m.tnSecs >= 10 or ga_Type_IsInteger(m.tnSecs),;
				'9999',;
			m.tnSecs >= 1,;
				'9.9',;
			m.tnSecs >= .1,;
				'9.99',;
				'9.999';
			));
		+ ' ' + icase(;
			m.cLangUser = 'fr',	'sec',; && copy-paste this line to add another language support
			m.cLangUser = 'de',	'sek',; && copy-paste this line to add another language support
													'sec'; && default: English
			);
		+ iif(m.tnSecs >= 2, 's', '') + '.');
		)
endfunc

* ================================================
function cSeconds && {fr} Secondes écoulées tenant compte du passage par minuit pour affichage
lparameters tnSeconds && {fr} Seconds() au début, si @, Seconds() en retour

local lnResult, cLangUser
lnResult = nSeconds(@m.tnSeconds)

return iif(m.lnResult < 60 and varSet(@m.cLangUser, cLangUser()); && 2016-03-23 thn -- {en} {FiC V 2.21.0-beta.11} don't prepend a space for use in ? command
	, cSecs(m.lnResult);
	, cHHMMSS(m.lnResult);
	)
endfunc

* ================================================
function nSeconds && {fr} Secondes écoulées tenant compte du passage par minuit
lparameters tnSeconds && {fr} Seconds() au début, si @, Seconds() en retour
tnSeconds = iif(vartype(m.tnSeconds) == 'N' and m.tnSeconds > 0, m.tnSeconds, 0)

local lnResult, lnSeconds

lnSeconds = seconds()

lnResult = m.lnSeconds - m.tnSeconds + iif(m.lnSeconds < m.tnSeconds;
	, 86400; && _Cliptext = Transform(24*3600) && {fr} passage à minuit
	, 0;
	)

tnSeconds = m.lnSeconds && {fr} pour retour

return m.lnResult
endfunc

* ================================================
function nMilliSeconds && {fr} Millisecondes écoulées tenant compte du passage par minuit
lparameters tnSeconds && {fr} Seconds() au début, si @, Seconds() en retour

return nMS(@m.tnSeconds)

* ================================================
function nMS && {fr} Millisecondes écoulées tenant compte du passage par minuit
lparameters tnSeconds && {fr} Seconds() au début, si @, Seconds() en retour

return int(nSeconds(@m.tnSeconds) * 1000)

* ================================================
function cMS && {fr} Millisecondes écoulées tenant compte du passage par minuit
lparameters tnSeconds && {fr} Seconds() au début, si @, Seconds() en retour

return transform(nMS(@m.tnSeconds)) + ' ms.'

* ================================================
function cDateTimeSep && {fr} Date et heure avec séparateurs compatibles pour nom de fichier
lparameters tt && [Datetime()] {fr} Date et heure
return chrtran(ttoc(evl(m.tt, datetime()), 3), ':', '-')

* ================================================
function DtocXL && {fr} Date formatée selon masque de type Excel
lparameters ldDate, lsFormatExcel

ldDate = evl(m.ldDate, date())
lsFormatExcel = evl(m.lsFormatExcel, "JJ/MM/AAAA") && {fr} on pourrait tenir compte de Set("Date") pour déterminer le défaut

* {fr} AAAA / YYYY = Année avec siècle
* {fr} AAA / YYY = Année avec siècle
* {fr} AA / YY = Année sans le siècle
* {fr} A / Y = Année 1 chiffre
* {fr} MMMM = Nom du Mois
* {fr} MMM = 3 Premiere lettres du Nom du Mois
* {fr} MM  = n° mois sur 2 chiffres
* {fr} M  = n° du mois court
* {fr} JJJJ / DDD = Nom du Jour
* {fr} JJJ / DDD = 3 premières lettres du nom du jour
* {fr} JJ / DD = n° de jour sur 2 chiffres
* {fr} J / D = n° du jour court

* {fr} Il ne faut pas remplacer ce qui a été substitué exemple JJJJ -> "Jeudi" -> 7eudi
* {fr} et format possible anglais. Passage par <9999> Année <8888> Mois <7777> Jours ...H M S a faire
* /!\ L'ordre des Strtran() a une importance : du plus long au plus court
return strtran(strtran(strtran(strtran(strtran(strtran(strtran(strtran(strtran(strtran(strtran(strtran(strtran(strtran(strtran(strtran(strtran(strtran(strtran(strtran(strtran(strtran(strtran(strtran(chrtran(upper(m.lsFormatExcel), 'YD', 'AJ');
	, "AAAA", "<9999>", 1);
	, "AAA", "<999>", 1);
	, "AA", "<99>", 1);
	, "A", "<9>", 1);
	, "MMMM", "<8888>", 1);
	, "MMM", "<888>", 1);
	, "MM", "<88>", 1);
	, "M", "<8>", 1);
	, "JJJJ", "<7777>", 1);
	, "JJJ", "<777>", 1);
	, "JJ", "<77>", 1);
	, "J", "<7>", 1);
	, "<9999>", str(year(m.ldDate),4,0), 1);
	, "<999>", str(year(m.ldDate),4,0), 1);
	, "<99>", right(str(year(m.ldDate),4,0), 2), 1);
	, "<9>", right(str(year(m.ldDate),4,0), 1), 1);
	, "<8888>", proper(cmonth(m.ldDate)), 1);
	, "<888>", left(proper(cmonth(m.ldDate)),3), 1);
	, "<88>", padl(month(m.ldDate),2,"0"), 1);
	, "<8>", alltrim(str(month(m.ldDate),2,0)), 1);
	, "<7777>", proper(cdow(m.ldDate)), 1);
	, "<777>", left(proper(cdow(m.ldDate)),3), 1);
	, "<77>", padl(day(m.ldDate),2,"0"), 1);
	, "<7>", alltrim(str(day(m.ldDate),2,0)), 1)

* ---------------------------------------------------------
procedure DtocXL_test && {fr} Teste DtocXL()

local loTest as abUnitTest of abDev.prg
loTest = newobject('abUnitTest', 'abDev.prg')

loTest.Test('12-06-07', date(2012, 6, 7), 'yy-mm-jj') && 0,020 ms

return loTest.Result()

* ----------------------------------------------
function cDTformat_AW_XL && {fr} Format de date ou date-heure pour ActiveWidget ou Excel
lparameters ;
  tlT; && [.F.] {fr} Format de date et heure
, tlXL; && [.F.] {fr} Format pour Excel /!\ à implémenter

tlXL = lTrue(m.tlXL)

local lcResult as string;
, lcDate as string;
, lcYear as string;
, lcMark as string;

lcDate = set('Date')
lcYear = iif(set("Century") == 'ON', 'yyyy', 'yy')

lcResult = icase(;
	m.lcDate == 'ANSI', m.lcYear + '.mm.dd',;
	m.lcDate == 'AMERICAN', 'mm/dd/' + m.lcYear,;
	m.lcDate == 'BRITISH', 'dd/mm/' + m.lcYear,;
	m.lcDate == 'FRENCH', 'dd/mm/' + m.lcYear,;
	m.lcDate == 'GERMAN', 'dd.mm.' + m.lcYear,;
	m.lcDate == 'ITALIAN', 'dd-mm-' + m.lcYear,;
	m.lcDate == 'JAPAN', m.lcYear + '/mm/dd',;
	m.lcDate == 'TAIWAN', m.lcYear + '/mm/dd',;
	m.lcDate == 'USA', 'mm-dd-' + m.lcYear,;
	m.lcDate == 'MDY', 'mm/dd/' + m.lcYear,;
	m.lcDate == 'DMY', 'dd/mm/' + m.lcYear,;
	m.lcDate == 'YMD', m.lcYear + '/mm/dd',;
	m.lcDate == 'SHORT', 'dd/mm/yy',; && {fr} Short date format determined by the Windows Control Panel short date setting /!\ à approfondir
	m.lcDate == 'LONG', 'dd/mm/yyyy',; && {fr} Long date format determined by the Windows Control Panel long date setting /!\ à approfondir
	'dd/mm/yyyy';
	)

lcMark = set('Mark', 1)

return '';
	+ iif(empty(m.lcMark);
		, m.lcResult;
		, chrtran(m.lcResult, './-', replicate(m.lcMark, len('./-')));
		);
	+	iif(lTrue(m.tlT);
		, space(1) + iif(.f.;
				or m.lcDate $ 'SHORT,LONG';  && {fr} à approfondir
			 	or set("Seconds") == 'ON';
			 , 'hh:mm:ss';
			 , 'hh:mm');
		, '';
		)
endfunc

* ================================================
function nWeeksYear && {fr} Nombre de semaines dans une année
lparameters ;
  tnYear; && {fr} Année
, nFirstWeek; && [1] {fr} première semaine de l'année selon Week()
, nFirstDayOfWeek && [1] {fr} premier jour de la semaine selon Week()
nFirstWeek = iif(pcount() >= 2 and vartype(m.nFirstWeek) == 'N' and int(m.nFirstWeek) = m.nFirstWeek and between(m.nFirstWeek, 0, 3), m.nFirstWeek, 1)
nFirstDayOfWeek = iif(pcount() >= 3 and vartype(m.nFirstDayOfWeek) == 'N' and int(m.nFirstDayOfWeek) = m.nFirstDayOfWeek and between(m.nFirstDayOfWeek, 0, 7), m.nFirstDayOfWeek, 1)

local ldResult, lnResult

ldResult = date(m.tnYear, 12, 31)
do while .t.
	lnResult = week(m.ldResult, m.nFirstWeek, m.nFirstDayOfWeek)
	if m.lnResult > 1
		exit
	else
		ldResult = m.ldResult - 1
	endif
enddo

return m.lnResult

* ================================================
function cAgo && {fr} mention 'il y a' {en} 'some time ago' caption
lparameters ;
  ttd; && {en} date or datetime
, lShort; && [.F.] {en} use abbreviations whenever possible
, lAgoNo; && [.F.] {en} do not mention 'ago' {fr} pas de 'il y a'
, lGMT; && [.F.] {en} GMT time {fr} heures GMT

local cAgo as string;
, cType as string;
, lDate as Boolean;
, ltdNow;
, nAgo as integer;
, nAgoS as integer;
, cLangUser as string;

lShort = lTrue(m.lShort)
lAgoNo = lTrue(m.lAgoNo)
cType = vartype(m.ttd)

if !m.cType $ 'DT' or Empty(m.ttd)
	return .null.

else

	lDate = m.cType == 'D'
	ltdNow = Datetime() + Iif(lTrue(m.lGMT) and Upper('wwAPI.fxp') $ Set("Procedure");
		, Evaluate("GetTimeZone()*60"); && modify command wwAPI
		, 0;
		)
	ltdNow = iif(m.lDate, Ttod(m.ltdNow), m.ltdNow)
	nAgo = m.ltdNow - m.ttd && > 0 if ttd is past
	nAgoS = abs(m.nAgo) && {fr} seconds
	nAgoS = m.nAgoS * iif(m.lDate, 60*60*24, 1)
	nAgoS = Iif(m.nAgoS < 10, 0, m.nAgoS) && {fr} moins de 10 secondes : à l'instant
	nAgo = Iif(Empty(m.nAgoS), 0, m.nAgo)

	cLangUser = cLangUser()

	do case

	case m.lDate and between(m.nAgo, -2, 2)
		do case
		case m.nAgo = 2
			cAgo = icase(;
				m.cLangUser = 'fr',	[avant-hier],; && copy-paste this line to add another language support
														[day before yesterday]; && default: English
				)
		case m.nAgo = 1
			cAgo = icase(;
				m.cLangUser = 'fr',	[hier],; && copy-paste this line to add another language support
														[yesterday]; && default: English
				)
		case empty(m.nAgo)
			cAgo = icase(;
				m.cLangUser = 'fr',	[aujourd'hui],; && copy-paste this line to add another language support
														[today]; && default: English
				)
		case m.nAgo = -1
			cAgo = icase(;
				m.cLangUser = 'fr',	[demain],; && copy-paste this line to add another language support
														[tomorrow]; && default: English
				)
		case m.nAgo = -2
			cAgo = icase(;
				m.cLangUser = 'fr',	[après-demain],; && copy-paste this line to add another language support
														[day after tomorrow]; && default: English
				)
		endcase
		store 0 to nAgo, nAgoS

	case Empty(m.nAgoS)
		cAgo = Iif(m.lShort;
		, icase(;
			m.cLangUser = 'fr',	"à l'inst.",; && copy-paste this line to add another language support
													'just now'; && default: English
			);
		, icase(;
			m.cLangUser = 'fr',	"à l'instant",; && copy-paste this line to add another language support
													'just now'; && default: English
			);
		)

	case m.nAgoS < 60
		cAgo = Iif(m.lShort;
		, icase(;
			m.cLangUser = 'fr',	'sec.',; && copy-paste this line to add another language support
													'sec.'; && default: English
			);
		, icase(;
			m.cLangUser = 'fr',	'seconde',; && copy-paste this line to add another language support
													'second'; && default: English
			);
		)
	case m.nAgoS < (60*60)
		nAgoS = round(m.nAgoS / 60, 0)
		cAgo = Iif(m.lShort;
		, icase(;
			m.cLangUser = 'fr',	'min.',; && copy-paste this line to add another language support
													'min.'; && default: English
			);
		, icase(;
			m.cLangUser = 'fr',	'minute',; && copy-paste this line to add another language support
													'minute'; && default: English
			);
		)
	case m.nAgoS < (60*60*24)
		nAgoS = round(m.nAgoS / (60*60), 0)
		cAgo = Iif(m.lShort;
		, icase(;
			m.cLangUser = 'fr',	'h.',; && copy-paste this line to add another language support
													'h.'; && default: English
			);
		, icase(;
			m.cLangUser = 'fr',	'heure',; && copy-paste this line to add another language support
													'hour'; && default: English
			);
		)
	case m.nAgoS < (60*60*24*7)
		nAgoS = round(m.nAgoS / (60*60*24), 0)
		cAgo = Iif(m.lShort;
		, icase(;
			m.cLangUser = 'fr',	'j.',; && copy-paste this line to add another language support
													'dy'; && default: English
			);
		, icase(;
			m.cLangUser = 'fr',	'jour',; && copy-paste this line to add another language support
													'day'; && default: English
			);
		)
	case between(m.ttd, gomonth(date(), -1), gomonth(date(), 1))
		nAgoS = round(m.nAgoS / (60*60*24*7), 0)
		cAgo = Iif(m.lShort;
		, icase(;
			m.cLangUser = 'fr',	'sem.',; && copy-paste this line to add another language support
													'w.'; && default: English
			);
		, icase(;
			m.cLangUser = 'fr',	'semaine',; && copy-paste this line to add another language support
													'week'; && default: English
			);
		)
	otherwise
		nAgoS = abs(nMonths(m.ltdNow, m.ttd))
		cAgo = Iif(m.lShort;
		, icase(;
			m.cLangUser = 'fr',	'm.',; && copy-paste this line to add another language support
													'm.'; && default: English
			);
		, icase(;
			m.cLangUser = 'fr',	'mois',; && copy-paste this line to add another language support
													'month'; && default: English
			);
		)
	endcase

	return '';
		+ ICase(;
			empty(m.nAgoS) or m.lAgoNo,;
				'',;
			m.nAgo > 0,; && {fr} ttd is past
				icase(;
					m.cLangUser = 'fr',	'il y a ',; && copy-paste this line to add another language support
															''; && default: English
					),;
				icase(;
					m.cLangUser = 'fr',	'dans ',; && copy-paste this line to add another language support
															'in '; && default: English
					);
			);
		+ nEvl(evl(m.nAgo, ''), ltrim(str(m.nAgoS))+ Chr(160));
		+ iif(m.nAgoS > 1 and !m.lShort;
			, trim(m.cAgo, 's') + 's';
			, m.cAgo;
			);
		+ ICase(;
			empty(m.nAgoS) or m.lAgoNo,;
				'',;
			m.nAgo > 0,; && {fr} ttd is past
				icase(;
					m.cLangUser = 'fr',	'',; && copy-paste this line to add another language support
															' ago'; && default: English
					),;
				icase(;
					m.cLangUser = 'fr',	'',; && copy-paste this line to add another language support
															''; && default: English
					);
			);
		+ ''

endif
endfunc

* ---------------------------------------------------------
procedure cAgo_test && {fr} cAgo() unit test

local loTest as abUnitTest of abDev.prg, cLangUser
loTest = newobject('abUnitTest', 'abDev.prg')

cLangUser = cLangUser()

cLangUser('en')
loTest.Test('today', date())
loTest.Test('yesterday', date()-1)
loTest.Test('2 minutes ago', datetime()-2*60)
loTest.Test('2 min. ago', datetime()-2*60, .T.)
loTest.Test('2 hours ago', datetime()-2*60*60)
loTest.Test('just now', datetime()-2)
loTest.Test('just now', datetime())

cLangUser('fr')
loTest.Test('après-demain', date()+2)

cLangUser(m.cLangUser)

return loTest.Result()

* ================================================
function cDateFig_Long && {fr} Date en chiffres et longue
lparameters ;
  tu; && {fr} Date ou date-heure
, tlNoDay && [.F.] {fr} ôter le jour de la semaine

local result

result = cDateLong(@m.tu, m.tlNoDay)
return transform(m.tu) + ' (' + m.result + ')'
endfunc

* ================================================
function ctRFC822 && {fr} Date et heure selon la norme RFC822
lparameters ;
  tt; && [datetime()] {fr} date-heure
, tlGMT; && [.F.] {fr} GMT

local lcType, laDays[7], laMonths[12], lnOffset, lcDate, lcSeconds, lcHours, lcTime, lcResult

lcType = vartype(m.tt)
tt = icase(m.lcType == 'T', m.tt;
		, m.lcType == 'D', dtot(m.tt);
		, datetime())
tlGMT = lTrue(m.tlGMT)

laDays[1] = "Mon" && {fr} Dow(, 2)
laDays[2] = "Tue"
laDays[3] = "Wed"
laDays[4] = "Thu"
laDays[5] = "Fri"
laDays[6] = "Sat"
laDays[7] = "Sun"
laMonths[01] = "Jan"
laMonths[02] = "Feb"
laMonths[03] = "Mar"
laMonths[04] = "Apr"
laMonths[05] = "May"
laMonths[06] = "Jun"
laMonths[07] = "Jul"
laMonths[08] = "Aug"
laMonths[09] = "Sep"
laMonths[10] = "Oct"
laMonths[11] = "Nov"
laMonths[12] = "Dec"

lnOffset = 'GetTimeZone' && {fr} évite une dépendance à wwAPI
lnOffset = evaluate(m.lnOffset + '()')/60 && {fr} GetTimeZone() est en minutes && modify command wwAPI
if m.tlGMT
	tt = m.tt + m.lnOffset * 3600
endif

* {fr} Lire l'heure avec les secondes
lcDate = set("Date")
lcHours = transform(set("Hours"))
lcSeconds = set("Seconds")
set date to french && {fr} If DATE is set to SHORT or LONG, the SET CENTURY, SET MARK, SET HOURS, and SET SECONDS settings are ignored
set hours to 24
set seconds on
lcTime = ttoc(m.tt, 2) && {fr} HH:MM:SS
set date to &lcDate
set hours to &lcHours
set seconds &lcSeconds

lcResult = textmerge("<<laDays[Dow(m.tt, 2)]>>, <<Padl(Day(m.tt),2,'0')>> <<laMonths[Month(m.tt)]>> <<Str(Year(m.tt),4)>> <<m.lcTime>>");
	+ iif(m.tlGMT, " GMT", iif(m.lnOffset > 0," -"," +");
	+ padl(transform(abs(m.lnOffset)), 2, "0") + "00")

return m.lcResult

* ================================================
function iQuarter && {fr} N° de trimestre
lparameters td
return Ceiling(Month(m.td)/3)

* ================================================
function iDayMonthYear && {fr} position du jour, mois et année dans le format de date courant
lparameters ;
  liDay; && {fr} position du jour
, liMonth; && {fr} position du mois
, liYear && {fr} position de l'année

local iSetDate1 as Integer

iSetDate1 = Set("Date", 1) && Date Ordering: 0 – MDY, 1 – DMY, 2 – YMD

liDay   = ICase(m.iSetDate1 = 0, 2, m.iSetDate1 = 1, 1, m.iSetDate1 = 2, 3, .null.)
liMonth = ICase(m.iSetDate1 = 0, 1, m.iSetDate1 = 1, 2, m.iSetDate1 = 2, 2, .null.)
liYear  = ICase(m.iSetDate1 = 0, 3, m.iSetDate1 = 1, 3, m.iSetDate1 = 2, 1, .null.)

endfunc

* ================================================
function nGMToffsetMin && {fr} Minutes entre l'heure locale et l'heure GMT

declare integer;
	GetTimeZoneInformation;
	in win32api;
	string @ TimeZoneStruct
   
local lcTZ, lnDayLightSavings

lcTZ = Space(256)
lnDayLightSavings = GetTimeZoneInformation(@m.lcTZ)

RETURN nOfcDWord(Substr(m.lcTZ, 1, 4), .T.); && modify command abDev
	- Iif(m.lnDaylightSavings = 2, 60, 0)

endfunc