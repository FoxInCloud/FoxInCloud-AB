* {fr} abTxt.prg
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
AB()
return abUnitTests()

* ===================================================================
function cTronc && {fr} Chaîne tronquée à une longueur donnée en la terminant par "..."
lparameters ;
  tcChain; && {fr} Chaine à tronquer
, tnTronc; && [50] {fr} Nombre de caractères oû la chaine totale doit tenir
, tlWord; && [.F.] {fr} couper à la fin d'un mot
, tcDropped; && @ [''] {fr} Partie éventuellement coupée
, tlEllipsNot; && [.F.] {fr} Ne pas ajouter de points de suspension
, tcSep && [any] {fr} preferred separator

local lcResult;
, llResult;
, lcEllips;

store '' to tcDropped, lcResult

llResult = vartype(m.tcChain) == 'C'
assert m.llResult message "Required parameter tcChain is invalid"
if m.llResult

	tnTronc = Iif(ga_Type_IsPositiveInteger(m.tnTronc), m.tnTronc, 50)

	* {fr} Si la chaîne est plus longue que la troncature
	lcResult = iif(empty(substr(m.tcChain, m.tnTronc + 1));
		, leftc(m.tcChain, m.tnTronc);
		, m.tcChain;
		)
	if len(m.lcResult) > m.tnTronc

		lcEllips = iif(lTrue(m.tlEllipsNot);
			, '';
			, chr(160) + replicate('.', 3);
			)
		lcResult = left(m.lcResult, m.tnTronc - lenc(m.lcEllips))

		* {fr} Si coupure à la fin d'un mot
		if lTrue(m.tlWord);
		 and (.f.;
			or ' ' $ m.lcResult;
		 	or ', ' $ m.lcResult;
		 	or '; ' $ m.lcResult;
		 	or '. ' $ m.lcResult;
		 	or '! ' $ m.lcResult;
		 	or '? ' $ m.lcResult;
		 	)

			tnTronc = iif(ga_Type_IsChar(m.tcSep, .t.) and m.tcSep $ m.lcResult;
				, ratc(';', m.lcResult) + lenc(m.tcSep);
				, max(;
						ratc(' ', m.lcResult);
					, ratc(', ', m.lcResult) + 2;
					, ratc('; ', m.lcResult) + 2;
					, ratc('. ', m.lcResult) + 2;
					, ratc('! ', m.lcResult) + 2;
					, ratc('? ', m.lcResult) + 2;
					);
				)
			if m.tnTronc > 0
				lcResult = trim(leftc(m.lcResult, m.tnTronc - 1))
			endif
		endif

		lcResult = m.lcResult + m.lcEllips
		tcDropped = alltrim(substr(m.tcChain, m.tnTronc))
	endif
endif

return m.lcResult
endfunc

* --------------------
procedure cTronc_test

local loTest as abUnitTest of abDev.prg, lcDropped
loTest = newobject('abUnitTest', 'abDev.prg')

* _cliptext = Chr(160)

loTest.Test('891-1490, 791-14 ...', '891-1490, 791-1491, 1890, 2891 (MilitÃ¤rfzg. Mit geteilert Scheibe)', 20) && {fr} Len('891-1490, 791-14') = 16
loTest.Test('891-1490,Â ...', '891-1490, 791-1491, 1890, 2891 (MilitÃ¤rfzg. Mit geteilert Scheibe)', 20, .t., @m.lcDropped)
loTest.assert('791-1491, 1890, 2891 (MilitÃ¤rfzg. Mit geteilert Scheibe)', m.lcDropped)

return loTest.Result()

* ===================================================================
function cJustified && {en} String justified on a given number of columns {fr} Chaîne justifiée sur un nombre de colonnes
lparameters ;
  tcChain; && {en} String to justify {fr} Chaîne à justifier
, tnCols; && [80] {en} Number of columns {fr} Nombre de colonnes

tcChain = iif(vartype(m.tcChain) == 'C', m.tcChain, '')
tnCols = evl(m.tnCols, 80)

local lnLine, laLine[1], liLine, lcLine

lnLine = alines(laLine, m.tcChain)
if m.lnLine > 0

	for liLine = 1 to m.lnLine
		lcLine = laLine[m.liLine]
		laLine[m.liLine] = ''
		do while not empty(m.lcLine)
			laLine[m.liLine] = c2Words(laLine[m.liLine], CRLF, cTronc(m.lcLine, m.tnCols, .t., @m.lcLine, .t.))
		enddo
	endfor

	return cListOfArray(@m.laLine, CRLF,,,.t.) + Iif(m.lnLine > 1, CRLF, '')
else
	return ''
endif
endfunc

* ===================================================================
function cWords && {en} Words separated if not empty {fr} Mots séparés si non vides
lparameters ;
  tuSep; && {en} Separator {fr} Séparateur, type variable
, tuW0; && {en} array of words (1 dim.) or first word {fr} tableau de mots (1 dim.) ou premier mot
, tuW1, tuW2, tuW3, tuW4, tuW5, tuW6, tuW7, tuW8, tuW9, tuW10, tuW11, tuW12, tuW13, tuW14, tuW15, tuW16, tuW17, tuW18, tuW19, tuW20, tuW21, tuW22, tuW23, tuW24 && [''] {en} other words {fr} mots suivants

local lcResult;
, liWord

lcResult = ''

do case
case !Vartype(m.tuSep) == 'C'

case type('tuW0',1) == 'A' && array
	external array tuW0
	for m.liWord = 1 to Alen(m.tuW0)
		lcResult = c2Words(m.lcResult, m.tuSep, m.tuW0[m.liWord])
	endfor

case pcount() > 2
	for m.liWord = 0 to pcount()-2
		lcResult = c2Words(m.lcResult, m.tuSep, evaluate('m.tuW' + ltrim(str(m.liWord))))
	endfor
endcase

return m.lcResult
endfunc

* -----------------------------------------------------------------
procedure cWords_test

local loTest as abUnitTest of abDev.prg
loTest = newobject('abUnitTest', 'abDev.prg')

* m.loTest.coverageSet()

loTest.Test('10/.F./VFP', '/', '', 10, .f., 'VFP')

local array laW[6]
laW[1] = 'VFP'
laW[2] = 15
laW[3] = .f.
laW[4] = ''
laW[5] = 0
laW[6] = createobject('form')
loTest.Test('VFP,15,.F.,0', ',', @m.laW)

return m.loTest.result()
endproc

* ===================================================================
function c2Words && {en} 2 words separated if not empty {fr} Deux mots séparés si non vides
lparameters ;
  tuW1; && {en} First word {fr} Premier mot, type variable
, tuSep; && {en} Separator {fr} Séparateur, type variable
, tuW2; && {en} Second word {fr} Second mot, type variable

local llW1Empty, llW2Empty, lcSep, lnSep, lcW1, lcW2

llW1Empty = vartype(m.tuW1) == 'C' and empty(m.tuW1) or vartype(m.tuW1) $ 'OGXU'
llW2Empty = vartype(m.tuW2) == 'C' and empty(m.tuW2) or vartype(m.tuW2) $ 'OGXU'

do case
case pcount() < 3
	return iif(m.llW1Empty, '', transform(m.tuW1))

case not (m.llW1Empty or m.llW2Empty)
	lcSep = transform(m.tuSep)
	lnSep = lenc(m.lcSep)
	lcW1 = transform(m.tuW1)
	lcW2 = transform(m.tuW2)

	return '';
	 + iif(rightc(m.lcW1, m.lnSep) == m.lcSep, leftc(m.lcW1, lenc(m.lcW1)-m.lnSep), m.lcW1);
	 + m.lcSep;
	 + iif(leftc(m.lcW2, m.lnSep) == m.lcSep, rightc(m.lcW2, lenc(m.lcW2)-m.lnSep), m.lcW2)

case m.llW1Empty
	return transform(m.tuW2)

otherwise && {fr} CASE m.llW2Empty
	return transform(m.tuW1)
endcase
endfunc

* -----------------------------------------------------------------
procedure c2Words_test

local loTest as abUnitTest of abDev.prg
loTest = newobject('abUnitTest', 'abDev.prg')

loTest.Test('toto', 'toto')
loTest.Test('toto', 'toto', ' est ')
loTest.Test('content', '', ' est ', 'content')
loTest.Test('toto', 'toto', ' est ', '')

loTest.Test('toto est content', 'toto', ' est ', 'content')
loTest.Test("l'age de toto est 10", "l'age de toto", ' est ', 10)

loTest.Test("test;test", "test;", ';', ';test')

loTest.EnvSet([SET DATE FRENCH])
loTest.EnvSet([SET CENTURY ON])
loTest.Test("Je suis né le 05/08/1955", "Je suis né", ' le ', date(1955,8,5))

return loTest.Result()

* ===================================================================
function cC && {fr} Alias de cComparable()
lparameters ;
  tc; && Texte source
, tnLength && [trim] {fr} Si > 0, le résultat est paddé à cette longueur (pour index)

return cComparable(m.tc, m.tnLength)

* ===================================================================
function cComparable && {fr} Texte débarrassé de ses variantes typographiques pour comparaison
lparameters ;
  tc; && {fr} Texte source
, tnLength && [trim] {fr} Si > 0, le résultat est paddé à cette longueur (pour index)

local lcChars, lcResult && Texte comparable

do case
case isnull(m.tc) or empty(m.tc)
	lcResult = ''

case vartype(m.tc) == 'C'
	lcResult = upper(alltrim(m.tc))
	lcResult = cEuroANSI(m.lcResult) && {fr} désaccentue
	lcChars  = chrtran(m.EuroAnsi, '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz ', '')
	lcResult = chrtran(m.lcResult, m.lcChars, space(len(m.lcChars))) && {fr} ne garde que les caractères alphanumériques et les espaces
	lcResult = cRepCharDel(m.lcResult) && {fr} supprime les double espaces
	lcResult = cSpaceAroundGroup(m.lcResult) && {fr} normalise le nombre d'espaces autour des caractères de groupement

otherwise
	lcResult = ''
endcase

if vartype(m.tnLength) == 'N' and m.tnLength > 0
	lcResult = padr(m.lcResult, m.tnLength)
endif

return m.lcResult

* -----------------------------------------------------------------
procedure cComparable_test

local loTest as abUnitTest of abDev.prg
loTest = newobject('abUnitTest', 'abDev.prg')

loTest.Test('TOTO EST ENERVE', 'toto est  énervé')
loTest.Test([CA C EST SUR LE SAVOIR FAIRE D ABAQUE EST IMMENSE], [ça c'est  sûr, le savoir-faire d'Abaque est immense])
loTest.Test(space(50), .null., 50)

return loTest.Result()
endproc

* ===================================================================
function cRepCharsDel && {fr} Séquences de caractères identiques remplacées par un caractère simple
lparameters ;
  tcChain; && {fr} Chaine de caractères à traiter
, tcChars && {fr} Caractère(s) dont les répétitions sont à éliminer

local lcChars, llResult, lcResult
lcResult = ''

llResult = vartype(m.tcChain) = 'C' and vartype(m.tcChars)='C' and len(m.tcChars) > 0
assert m.llResult message cAssertMsg(textmerge([paramètres invalides : <<m.tcChain>> | <<m.tcChars>>]))
if m.llResult

	lcResult = m.tcChain

	lcChars = m.tcChars + m.tcChars
	do while m.lcChars $ m.lcResult
		lcResult = strtran(m.lcResult, m.lcChars, m.tcChars)
	enddo
endif

return lcResult

* ===================================================================
function cRepCharDel && {fr} Séquences d'un caractère remplacées par un caractère simple
lparameters ;
  tcChain; && {fr} Chaine de caractères à traiter
, tcChar && [space(1)] {fr} Caractère dont les répétitions sont à éliminer

if ga_Type_IsChar(m.tcChain, .T.)

	local lcResult, lcChar, lcChars

	lcResult = m.tcChain
	lcChar = iif(vartype(m.tcChar) == 'C' and len(m.tcChar) > 0, left(m.tcChar, 1), space(1))
	lcChars = replicate(m.lcChar, 2)

	do while m.lcChars $ m.lcResult
		lcResult = strtran(m.lcResult, m.lcChars, m.lcChar)
	enddo

	return m.lcResult
else
	return ''
endif

* -----------------------------------------------------------------
procedure cRepCharDel_Test && {fr} Tests cRepCharDel

local loTest as abUnitTest of abDev.prg
loTest = newobject('abUnitTest', 'abDev.prg')

loTest.Test('appuie-tête', 'appuie--tête', '-')
loTest.Test('appuie tête', 'appuie  tête')
loTest.Test('appuie-tête', 'appuie----------------tête', '-')

return loTest.Result()

* ===================================================================
function cSpaceAround && {fr} Chaîne oû les nombres d'Space(1) avant et après une sous-chaîne donnée sont normalisés
lparameters ;
  tcChain ; && {fr} Chaine à traiter
, tcSubChain ; && {fr} Sous-chaine dont les espaces avant - après sont à normaliser
, tnBefore ; && [0] {fr} Nombre d'espaces avant la sous-chaine
, tnAfter && [tnBefore] {fr} Nombre d'espaces après la sous-chaine

if vartype(m.tcChain) == 'C';
 and vartype(m.tcSubChain) == 'C' ;
 and ! empty(m.tcSubChain) ;
 and m.tcSubChain $ m.tcChain
	lcResult = m.tcChain

	* {fr} Delete spaces before and after character chain
	do while space(1) + m.tcSubChain $ m.lcResult
		lcResult = strtran(m.lcResult, space(1)+m.tcSubChain, m.tcSubChain)
	enddo
	do while m.tcSubChain + space(1) $ m.lcResult
		lcResult = strtran(m.lcResult, m.tcSubChain+space(1), m.tcSubChain)
	enddo

	* {fr} Add the required number of spaces before and after character chain
	tnBefore = iif(vartype(m.tnBefore)='N' and m.tnBefore > 0, m.tnBefore, 0)
	tnAfter = iif(vartype(tnAfter)='N' and m.tnAfter > 0, m.tnAfter, m.tnBefore)

	return strtran(m.lcResult ;
						, m.tcSubChain ;
						, replicate(space(1), m.tnBefore) + m.tcSubChain + replicate(space(1), m.tnAfter))

else

	return m.tcChain
endif

* -----------------------------------------------------------------
procedure cSpaceAround_Test

local loTest as abUnitTest of abDev.prg
loTest = newobject('abUnitTest', 'abDev.prg')

loTest.Test('appuie   -   tête', 'appuie - tête', '-', 3)
loTest.Test('10.150 F, FL', '10.150 F,FL', [,], 0, 1)

return loTest.Result()

* ===================================================================
function cSpaceAroundGroup && {fr} Chaîne oû le nombre d'Space(1) autour des caractères de groupement '({[]})' est normalisé
lparameters tcChain && {fr} Chaîne

local lcResult
lcResult = ''

#define GROUPCAR_OPEN		'([{'
#define GROUPCAR_CLOSE	')]}'

if vartype(m.tcChain)='C' ;
 and not empty(m.tcChain)
 m.tcChain = cRepCharDel(m.tcChain)

 local lnCar, lcCar, llGroupCarOpen, llGroupCarClose, llSpace
 for m.lnCar = 1 to len(m.tcChain)
 	lcCar = substrc(m.tcChain, m.lnCar, 1)

 	do case
	case m.lcCar == space(1)
		lcResult = m.lcResult + iif(m.llGroupCarOpen, '', m.lcCar)
	case m.lcCar $ GROUPCAR_OPEN
		lcResult = iif(m.llSpace, m.lcResult, m.lcResult + space(1)) + m.lcCar
	case m.lcCar $ GROUPCAR_CLOSE
		lcResult = iif(m.llSpace, left(m.lcResult, len(m.lcResult)-1), m.lcResult) + m.lcCar
	otherwise
		lcResult = m.lcResult + iif(m.llGroupCarClose, space(1), '') + m.lcCar
	endcase

	llSpace = m.lcCar == space(1)
 	llGroupCarOpen = m.lcCar $ GROUPCAR_OPEN
 	llGroupCarClose = m.lcCar $ GROUPCAR_CLOSE
 endfor
endif

return m.lcResult

* -----------------------------------------------------------------
procedure cSpaceAroundGroup_test

local loTest as abUnitTest of abDev.prg
loTest = NewObject('abUnitTest', 'abDev.prg')

loTest.Test('abc ((efg))', 'abc ( (efg ))')
loTest.Test('abc [(efg)]', 'abc [ (efg )]')
loTest.Test('abc [(efg)] toto', 'abc[ ( efg )]toto')
loTest.Test('Cabriolet (8G) 91-', 'Cabriolet  (  8G  )  91-')
loTest.Test('Cabriolet (8G) 91-', 'Cabriolet(8G)91-')
loTest.Test('Cabriolet (8G) 91-', 'Cabriolet (8G) 91-')

return loTest.Result()

* ===================================================================
function cSepGrpsXFigs && {fr} Groupe les chiffres dans une chaîne de caractères
lparameters ;
  tcChain; && {fr} Chaine à traiter
, tnFactGroup; && [3] {fr} Facteur de regroupement des groupes de chiffres
, tcSep && [Space(1)] {fr} Caractère de séparation des groupes de chiffres
local lcResult
store '' to m.lcResult

* {fr} Si une chaine valide a été passée
if vartype(m.tcChain) == 'C'

	local lcChain, lnChain
	lcChain = alltrim(m.tcChain)
	lnChain = len(m.lcChain)
	lcResult = m.lcChain

	* {fr} Donner leur valeur par défaut aux paramètres optionnels
	local lnFactGroup, lcSep
	lnFactGroup = ;
		iif	(vartype(m.tnFactGroup) == 'N' ;
					and m.tnFactGroup > 0 ;
					and m.tnFactGroup < m.lnChain ; && {fr} aberrant
					, m.tnFactGroup, 3)
	lcSep = iif(vartype(m.tcSep)=='C' and not empty(m.tcSep), left(ltrim(m.tcSep), 1), space(1))

	if m.lnFactGroup < m.lnChain

		* {fr} Pour chaque caractère en partant de la fin
		local lnCar, lcCar, lnChiffres, llSepAj
		lnChiffres = 0
		lcResult = ''
		for m.lnCar = m.lnChain to 1 step -1

			lcCar = substr(m.lcChain, m.lnCar, 1)
			do case

			case isdigit(m.lcCar)
				lnChiffres = m.lnChiffres + 1
				if m.lnChiffres = m.lnFactGroup ;
				 and m.lnCar > 1 && {fr} ne pas ajouter de séparateur devant le 1er caractère !
					lnChiffres = 0
					lcCar = m.lcSep + m.lcCar
					llSepAj = .t.
				else
					llSepAj = .f.
				endif

			case m.lcCar == m.lcSep
				if m.llSepAj
					* {fr} Ce séparateur fait double emploi avec celui que l'on vient d'ajouter,
					* {fr} Ne pas le garder
					loop
				endif

			otherwise && {fr} ni chiffre ni séparateur

				* {fr} Si un séparateur vient d'être ajouté, le supprimer.
				if m.llSepAj
					lcResult = substr(m.lcResult, 2)
				endif
				lnChiffres = 0
				llSepAj = .f.
			endcase

			lcResult = m.lcCar + m.lcResult
		endfor
	endif
endif

return lcResult

* -----------------------------------------------------------------
procedure cSepGrpsXFigs_Test && {fr} Teste cSepGrpsXFigs

local loTest as abUnitTest of abDev.prg
loTest = NewObject('abUnitTest', 'abDev.prg')

loTest.test('ABCDE123 456', 'ABCDE123456', 3)
loTest.test('ABCDE123.456', 'ABCDE123....456', 3, '.')
loTest.test('ABCDE123.456.', 'ABCDE123....456.', 3, '.')
loTest.test('AL01 021', 'AL01021', 10)
loTest.test('AL01 021', 'AL01021')
loTest.test('1 2', '12', 1)
loTest.test('AL 01 021', 'AL 01021')
loTest.test('1 256 001 021', '1256001021')
loTest.test('1,256,001,021', '1256001021', , ',')
loTest.test('12560|01021', '1256001021', 5, '|')

return loTest.Result()

* ===================================================================
function cListOfArrayC && {fr} Liste délimitée du contenu d'un tableau caractère
lparameters ;
  taWords ; && @ {fr} Mots de type C
, tcDelim ; && [','] {fr} Délimiteur
, tnCol && [1] {fr} N° de colonne, -1 pour toutes les colonnes (tableau taWords à 2 dimensions)
external array taWords

&& /!\ en chantier

* ===================================================================
function cListOfArray && {fr} Liste délimitée du contenu d'un tableau
lparameters ;
  taWords; && @ {fr} Mots de types divers (CNDTLY sont supportés)
, tcDelim; && [','] {fr} Délimiteur
, tnCol; && [1] {fr} N° de colonne, -1 pour toutes les colonnes (tableau taWords à 2 dimensions)
, tlLitterals; && [.F.] {fr} écrire les mots sous la forme de litteraux VFP (ex. foo > "foo",  02/07/03 > {^2003-02-07})
, tlKeepEmpty; && [tlLitterals] {fr} Include empty words
, tlKeepNull; && [tlLitterals] {fr} Include .NULL. words
, tlKeepWeird; && [.F.] {fr} Include words of type G/U
, tlDistinct; && [.F.] {fr} Élimine les doublons
, tlLines; && [.F.] {fr} Séparer les lignes (tableau taWords à 2 dimensions et m.tnCol = -1)
, tnColFilter; && [aucune] {fr} n° de colonne contenant un filtre des lignes à lister
, tlRtrimNot; && [.F.] {fr} Ne pas supprimer les espaces en queue des éléments de type caractère

external array taWords

local lnCols;
, lcPoint, llPoint; && , loPoint
, liWord, luWord, lcWord;
, lcVarType;
, lcDelim;
, llRtrim;
, lcResult

lcResult = ''

if not laEmpty(@m.taWords)

	* {fr} Déterminer le nombre de colonnes du tableau
	lnCols = alen(taWords, 2)

	* {fr} Donner leur valeur par défaut aux paramètres optionnels
	tcDelim = iif(vartype(m.tcDelim) == 'C' and lenc(m.tcDelim) > 0, m.tcDelim, ',')
	tnCol = icase(;
		M.lnCols = 0,; && {fr} tableau à 1 dimension
			0,;
		vartype(m.tnCol) == 'N',;
			icase(;
				between(m.tnCol, 1, m.lnCols),;
			 		M.tnCol,;
				M.tnCol = -1,;
				 	0,;
					1;
				),;
			1;
		)
	tlLitterals = lTrue(m.tlLitterals)
	tlKeepEmpty = iif(pcount()>= 5 and vartype(m.tlKeepEmpty) == 'L', m.tlKeepEmpty, m.tlLitterals)
	tlKeepNull = iif(pcount()>= 6 and vartype(m.tlKeepNull) == 'L', m.tlKeepNull, m.tlLitterals)
	tlDistinct = lTrue(m.tlDistinct)
	tlLines = m.lnCols > 0 and lTrue(m.tlLines) and vartype(m.tnCol) == 'N' and m.tnCol <= 0
	tnColFilter = iif(vartype(m.tnColFilter) == 'N' and between(m.tnColFilter, 1, m.lnCols), m.tnColFilter, 0)
	tlRtrimNot = lTrue(m.tlRtrimNot)
	llRtrim = !m.tlRtrimNot

	* {fr} Si le délimiteur peut entrer en conflit avec le séparateur décimal, changer celui-ci
	lcPoint = set('POINT')
	llPoint = m.lcPoint $ m.tcDelim
	if m.llPoint
		set point to icase(;
			not '.' $ m.tcDelim, '.',;
			not ',' $ m.tcDelim, ',',;
			not ';' $ m.tcDelim, ';',;
			'?')

*-				loPoint = abSet('POINT', ICase(; && {fr} ne marche pas
*-									NOT '.' $ m.tcDelim, '.',;
*-									NOT ',' $ m.tcDelim, ',',;
*-									NOT ';' $ m.tcDelim, ';',;
*-									'?'),,, .T.)
	endif

	* {fr} Pour chaque élément du tableau
	lcDelim = ''
	for liWord = 1 to iif(m.tnCol <= 0, alen(m.taWords), alen(m.taWords, 1))

		luWord = iif(m.tnCol <= 0;
			, taWords[m.liWord];
			, taWords[m.liWord, m.tnCol];
			)
		lcVarType = Vartype(m.luWord)
		lcWord = ''

		* {fr} Si la valeur est valide
		if .t.;
		 and m.lcVarType $ 'CNDTLYOX'; && {fr} G not supported
		 and (m.tlKeepNull or not m.lcVarType == 'X');
		 and (m.lcVarType == 'O' or m.tlKeepEmpty or not empty(m.luWord)); && {fr} Gestion des vides
		 and (m.tnColFilter = 0 or not empty(taWords[m.liWord, m.tnColFilter]))

			lcWord = icase(;
				m.tlLitterals,;
					cLitteral(m.luWord, m.llRtrim),;
				m.lcVarType == 'C' and m.tlRtrimNot,;
					m.luWord,;
					trim(transform(m.luWord));
				)

			* {fr} Si le mot n'est pas répété
			if not (.t.;
				and m.tlDistinct;
				and (.f.;
					or m.lcDelim + m.lcWord + m.lcDelim $ m.lcResult;
					or m.tcDelim + m.lcWord + m.tcDelim $ m.lcResult;
					or left(m.lcResult, lenc(m.lcWord + m.lcDelim)) == m.lcWord + m.lcDelim;
					or left(m.lcResult, lenc(m.lcWord + m.tcDelim)) == m.lcWord + m.tcDelim;
					);
				)

				lcResult = m.lcResult + m.lcDelim + m.lcWord
			endif
		endif

		&& 2016-02-23 thn -- {en} fixed: must always set delimiter, even if element is not rendered
		lcDelim = iCase(;
			Empty(m.lcResult),;
				'',;
			m.tlLines and (Asubscript(m.taWords, m.liWord, 2) = m.lnCols or m.lcDelim == CRLF and Empty(m.lcWord)),;
				CRLF,;
				m.tcDelim;
			)
	endfor
	&& 2016-02-23 thn -- {en} no more extra delimiter to remove
*	lcResult = leftc(m.lcResult, lenc(m.lcResult) - lenc(evl(m.lcDelim, ''))) && {fr} supprime le dernier délimiteur

	if m.llPoint
		set point to m.lcPoint
	endif
endif

return m.lcResult

* -----------------------------------------------------------------
procedure cListofArray_Test

local loTest as abUnitTest of abDev.prg, laTest[1]
loTest = newobject('abUnitTest', 'abDev.prg')

	dimension laTest [9]
	laTest[1] = 'First' && {fr} C
	laTest[2] = 2.25	 && {fr} N
	laTest[3] = .t.	 && {fr} L
	laTest[4] = date(2003,2,8) && {fr} D
	laTest[5] = datetime(2003,2,8,11,34,15) && {fr} T
	laTest[6] = '' && {fr} C Empty
	laTest[7] = 0	 && {fr} N Empty
	laTest[8] = .f. && {fr} L Empty
	laTest[9] = {} && {fr} D Empty
loTest.Test('"First",2.25,.T.,{^2003-02-08},{^2003-02-08 11:34:15},"",0,.F.,{/}', @m.laTest,,,.t.)

	dimension laTest[5,2]
	laTest= ''
	laTest[1,2] = 'First'
	laTest[2,2] = 'Second'
	laTest[3,2] = '  '
	laTest[4,2] = 'Fourth'
	laTest[5,2] = 'Fifth'
loTest.Test('"First","Second","","Fourth","Fifth"', @m.laTest,,2,.t.)
loTest.Test('"","First","","Second","","","","Fourth","","Fifth"', @m.laTest,,-1,.t.)
loTest.Test('First,Second,Fourth,Fifth', @m.laTest,,-1)
loTest.Test(cWords(CRLF, 'First','Second','Fourth','Fifth'), @m.laTest,,-1,,,,,,.t.) && {fr} toutes les colonnes, sans les vides, lignes séparées par CRLF
loTest.Test('First,,Second,,,,Fourth,,Fifth', @m.laTest,,-1,,.t.)

return m.loTest.Result()

* ===================================================================
function cPrintable && {fr} Chaine ne contenant que des caractères imprimables
lparameters ;
  tcChain && {fr} Chaine à normaliser

if vartype(m.tcChain) == 'C' ;
 and not empty(m.tcChain)

	return cRepCharDel(chrtranc(m.tcChain, NON_PRINTABLE, space(len(NON_PRINTABLE))))
else
	return ''
endif

* ===================================================================
function cOfLitteral && {fr} Chaîne depuis un littéral
lparameters ;
  tcLitteral;
, tlLitteral && [.F.] {en} return an empty string if tcLitteral is not a String literal

local Result, length

Result = alltrim(m.tcLitteral)
length = lenc(m.Result) - 2

Result = alltrim(m.Result, "'")
Result = iif(lenc(m.Result) = m.length;
	, m.Result;
	, alltrim(m.Result, '"');
	)
Result = iif(lenc(m.Result) = m.length;
	, m.Result;
	, alltrim(m.Result, '[', ']');
	)

return iif(lenc(m.Result) = m.length;
	, m.Result;
	, iif(lTrue(m.tlLitteral), '', m.tcLitteral);
	)

* -----------------------------------------------------------------
procedure cOfLitteral_Test && 0,020 ms

local loTest as abUnitTest of abDev.prg
loTest = newobject('abUnitTest', 'abDev.prg')

loTest.Test('test', [ 'test'])
loTest.Test(' test', [ " test"])
loTest.Test(' test ', " [ test ] ")
loTest.Test('', "  test ", .t.)

return m.loTest.Result()

* ===================================================================
function cL && {fr} Littéral VFP && {fr} Alias de cLitteral()
lparameters ;
  tuData ; && {fr} Valeur à convertir en littéral (type supportés : tous soit CDGLNOQTUXY)
, tlRTrim; && [.F.] {fr} si type C, ôter les espaces à droite
, tnTronc; && [aucun] {fr} si type C, nombre de caractères de troncature
, tlXML; && [.F.] {fr} Encoder pour XML
, tlObjRecurseNot; && [.F.] {fr} Ne pas récurser dans les membres et propriétés de type objet

return cLitteral(;
	 @m.tuData;
	, m.tlRTrim;
	, m.tnTronc;
	, m.tlXML;
	, m.tlObjRecurseNot;
	)

* ===================================================================
function cLitteral && {fr} Littéral VFP
lparameters ;
  tuData; && @ {fr} Valeur à convertir en littéral (type supportés : tous soit CDGLNOQTUXY)
, tlRTrim; && [.F.] {fr} si type C, ôter les espaces à droite
, tnTronc; && [aucun] {fr} si type C, nombre de caractères de troncature
, tlXML; && [.F.] {fr} Encoder pour XML
, tlObjRecurseNot; && [.F.] {fr} Ne pas récurser dans les membres et propriétés de type objet

#if .f. && {fr} Vartype VFP9
	C && {fr} Character, Memo, Varchar, Varchar (Binary)
	D && {fr} Date
	G && {fr} General
	L && {fr} Logical
	n && {fr} Numeric, Float, Double, or Integer
	O && {fr} Object
	Q && {fr} Blob, Varbinary
	t && {fr} DateTime
	U && {fr} Unknown or variable does not exist
	X && {fr} Null
	y && {fr} Currency
#endif

tlRTrim = lTrue(m.tlRTrim)
tlXML = lTrue(m.tlXML)
tlObjRecurseNot = lTrue(m.tlObjRecurseNot)

local lcVarType
lcVarType = vartype(m.tuData)

return ICase(;
	type('tuData', 1) == 'A',;
		'[' + cListOfArray(@m.tuData, ', ',-1,.t.,.t.,.t.,.t.) + ']',;
	M.lcVarType == 'C',;
		cLitteral_C(m.tuData, m.tlRTrim, m.tnTronc, m.tlXML),;
	M.lcVarType == 'L',;
		iif(m.tuData, '.T.', '.F.'),;
	M.lcVarType $ 'DT',;
		cLitteralDTStrict(m.tuData),;
	M.lcVarType $ 'YN',;
		cLitteral_N(m.tuData, m.lcVarType),;
	M.lcVarType == 'X',;
		'.NULL.',;
	M.lcVarType == 'O',;
		cLitteral_O(m.tuData, m.tlRTrim, m.tnTronc, m.tlXML, m.tlObjRecurseNot),;
	M.lcVarType == 'G',;
		'General',;
	M.lcVarType == 'Q',;
		'Blob, Varbinary',;
		'Unknown type';
)

* -----------------------------------------------------------------
function cLitteral_C && {fr} Littéral VFP de type caractère
lparameters ;
  tcData ; && {fr} Valeur à convertir en littéral (type supportés : tous soit CDGLNOQTUXY)
, tlRTrim; && [.F.] {fr} si type C, ôter les espaces à droite
, tnTronc; && [aucun] {fr} si type C, nombre de caractères de troncature
, tlXML && [.F.] {fr} Encoder pour support XML

local lcResult as string;
, llTronc as Boolean;
, aa[1] as string;
, s as string;
, lnData as integer;
, lnData_ as integer;
, lcLine as string;

lcResult = ''

llTronc = Vartype(m.tnTronc) == 'N'
tnTronc = iif(m.llTronc and between(m.tnTronc, 1, 255); && {fr} Maximum length of a string literal : 255
	, int(m.tnTronc);
	, 255;
	)

if alines(m.aa, m.tcData) > 0

	lnData_ = 0
	for each s in m.aa

		s = iif(m.tlRTrim, rtrim(m.s), m.s)
		s = iif(m.tlXML, cEscaped_XML(m.s), m.s)

		lnData = lenc(m.s)
		lnData_ = m.lnData_ + m.lnData

		do case
		case m.llTronc
			lcLine = cLitteral_C_(iif(m.lnData > m.tnTronc, cTronc(m.s, m.tnTronc), m.s))

		case m.lnData > 255 && {fr} limite d'un littéral caractère
			lcLine = ''
			do while m.lnData > 0
				lcLine = m.lcLine + '+' + cLitteral_C_(leftc(m.s, 255))
				s = substrc(m.s, 256)
				lnData = m.lnData - 255
			enddo
			lcLine = substrc(m.lcLine, 2)

		otherwise
			lcLine = cLitteral_C_(m.s)
		endcase

		lcResult = c2Words(m.lcResult, '+Chr(13)+Chr(10)+', m.lcLine)

		if m.llTronc and m.lnData_ > m.tnTronc
			exit
		endif
	endfor
endif

return m.lcResult
endfunc

* -----------------------------------------------------------------
function cLitteral_C_(tcData) && {fr} privée de cLitteral_C() - chaîne avec délimiteurs

return icase(;
	not ["] $ m.tcData,;
		["] + m.tcData + ["],; && {fr} Le plus généralement accepté
	not ['] $ m.tcData,;
		['] + m.tcData + ['],;
	not ('[' $ m.tcData or ']' $ m.tcData),;
		'[' + m.tcData + ']',;
		cLitteral_C__(m.tcData);
	)

* -----------------------------------------------------------------
function cLitteral_C__(tcData) && {fr} littéral d'un chaîne contenant ",[]

local lnAt;
, lnAtSimple, lnAtDouble, lnAtBracket;
, llAtSimple, llAtDouble, llAtBracket;
, Result

Result = ''

do while .t.
	lnAtSimple = at_c("'", m.tcData)
	lnAtDouble = at_c('"', m.tcData)
	lnAtBracket= evl(;
		min(at_c('[', m.tcData), at_c(']', m.tcData));
	, max(at_c('[', m.tcData), at_c(']', m.tcData));
	)
	if m.lnAtSimple * m.lnAtDouble * m.lnAtBracket = 0
		Result = m.Result + '+' + cLitteral_C_(m.tcData)
		exit
	else
		lnAt = max(m.lnAtSimple, m.lnAtDouble, m.lnAtBracket)
		llAtSimple = m.lnAt = m.lnAtSimple
		llAtDouble = m.lnAt = m.lnAtDouble
		llAtBracket= m.lnAt = m.lnAtBracket
		Result = m.Result;
			+ iif(empty(m.Result), '', '+');
			+ icase(;
				M.llAtSimple, "'",;
				M.llAtDouble, '"',;
				'[';
			);
			+ substr(m.tcData, 1, m.lnAt-1);
			+ icase(;
				M.llAtSimple, "'",;
				M.llAtDouble, '"',;
				']';
			)
		tcData = substr(m.tcData, m.lnAt)
	endif
enddo

return m.Result

* -----------------------------------------------------------------
function cLitteral_N && {fr} Littéral VFP de type numérique
lparameters ;
  tuData; && {fr} Nombre  à convertir en littéral
, lcVarType

local result as String

result = chrtran(;
	  iif(m.lcVarType = 'Y';
		, '$' + alltrim(str(m.tuData, 200, 6));
		, transform(m.tuData);
		);
	, set("Point"), '.'; && {fr} Gregory Adam http://www.atoutfox.org/nntp.asp?ID=0000008895
	)

return Iif('.' $ m.result, Trim(m.result, '0'), m.result)
endfunc

* -----------------------------------------------------------------
function cLitteral_O && {fr} Littéral VFP de type objet
lparameters ;
  toObject; && {fr} Objet à convertir en littéral
, tlRTrim; && [.F.] {fr} si type C, ôter les espaces à droite
, tnTronc; && [aucun] {fr} si type C, nombre de caractères de troncature
, tlXML; && [.F.] {fr} Encoder pour XML
, tlObjRecurseNot; && [.F.] {fr} Ne pas récurser dans les membres et propriétés de type objet

local lcResult;
, loObject;
, aProp[1];
, iProp as integer;
, cProps as string;
, cProp as string;

lcResult = ''

do case

case type('m.toObject.class') == 'C' and type('m.toObject.classLibrary') == 'C' && Visual FoxPro Object
	&& All Visual FoxPro base classes except the Empty class have the following minimum set of properties: 
	&& - Class Property 
	&& - BaseClass Property 
	&& - ClassLibrary Property 
	&& - ParentClass Property 
	
	lcResult = cWords(', ';
		, 'BaseClass: ' + Iif(PemStatus(m.toObject, 'BaseClass', 2), 'N/A', cLitteral(m.toObject.BaseClass));
		, nEvl(m.toObject.ParentClass, 'ParentClass: ' + cLitteral(m.toObject.ParentClass));
		, 'Class: ' + cLitteral(m.toObject.class);
		, nEvl(m.toObject.ClassLibrary, 'ClassLibrary:' + cLitteral(m.toObject.ClassLibrary));
		, Iif(type('m.toObject.Parent') == 'O' and type('m.toObject.Parent.Name') == 'C', 'parent: ' + m.toObject.Parent.Name, '');
		, cLitteral_O_cProps(m.toObject, m.tlRTrim, m.tnTronc, m.tlXML, m.tlObjRecurseNot);
		)

case type('m.toObject.Application') == 'O' and type('m.toObject.Application.Name') == 'C' && {fr} and ! 'foxpro' $ Lower(m.toObject.Application.Name) && {fr} COM object? eg 'Microsoft Excel'
	lcResult = 'COM class: ' + m.toObject.application.name

case type('m.toObject.class') == 'C' && {fr} weird Object
	lcResult = "class: " + m.toObject.class

otherwise && {fr} Empty Object

	lcResult = cWords(', ';
		, 'class: "Empty"';
		, cLitteral_O_cProps(m.toObject, m.tlRTrim, m.tnTronc, m.tlXML, m.tlObjRecurseNot);
		)
endcase

return nEvl(m.lcResult, 'Object {' + m.lcResult + '}')
endfunc

* -----------------------------------------------------------------
function cLitteral_O_cProps && {fr} Propriétés d'un objet modifiées par rapport à sa classe
lparameters ;
  toObject; && {fr} Objet à convertir en littéral
, tlRTrim; && [.F.] {fr} si type C, ôter les espaces à droite
, tnTronc; && [aucun] {fr} si type C, nombre de caractères de troncature
, tlXML; && [.F.] {fr} Encoder pour XML
, tlObjRecurseNot; && [.F.] {fr} Ne pas récurser dans les membres et propriétés de type objet

local lcResult as string;
, aProp[1];
, cProp as string;
, lProp as Boolean;
, uProp as Variant;
, aa[1];
, lArray as Boolean;

lcResult = ''

if amembers(aProp, m.toObject) > 0 && {fr} can be an empty object without properties

	for each cProp in m.aProp

		if Lower(m.cProp) == '_memberdata'
			loop
		endif
		
		lProp = !pemstatus(m.toObject, m.cProp, 2) && {fr} protected

		lArray = m.lProp and type('m.toObject.' + m.cProp, 1) == 'A'
		do case
		case !m.lArray
		case alen(m.toObject.&cProp, 2) > 0
			dimension aa[Alen(m.toObject.&cProp, 1), Alen(m.toObject.&cProp, 2)]
		otherwise
			dimension aa[Alen(m.toObject.&cProp, 1)]
		endcase
		if m.lArray
			acopy(m.toObject.&cProp, m.aa)
		endif

		lcResult = m.lcResult + iif(.T.; && and !pemstatus(m.toObject, m.cProp, 6); && {en} not inherited
			and pemstatus(m.toObject, m.cProp, 0); && {en} modified
			, ', ' + lower(m.cProp) + ': ' + iif(m.lProp;
				, iCase(;
					m.lArray,;
						cLitteral(@m.aa, m.tlRTrim, m.tnTronc, m.tlXML, m.tlObjRecurseNot),; && /!\ recursion
					InList(m.cProp, Upper('ActiveForm'), Upper('ActiveControl'));
					 or !varSet(@m.uProp, Evaluate('m.toObject.' + m.cProp));
					 or m.tlObjRecurseNot and Vartype(m.uProp) == 'O',;
						[object],;
						cLitteral(m.uProp, m.tlRTrim, m.tnTronc, m.tlXML, m.tlObjRecurseNot); && /!\ recursion
					);
				, '[protected or hidden]';
				);
			, '';
			)
	endfor
endif

return ltrim(substr(m.lcResult, 2))
endfunc

* -----------------------------------------------------------------
procedure cLitteral_Test && {fr} cLitteral() unit test

local loTest as abUnitTest of abDev.prg;
, luTest;
, luExpected;
, lcOnError;
, llError

loTest = newobject('abUnitTest', 'abDev.prg')

loTest.Test([" foo"], ' foo') && {fr} C
loTest.Test(['" foo"'], '" foo"') && {fr} C
loTest.Test('[' + ["foo"'] + ']+"' + "[bar]'" + '"', '"foo"' + "'[bar]'") && {fr} C
loTest.Test('"' + replicate('a', 255) + '"+[a' + ["foo"'] + ']+"' + "[bar]'" + '"';
	, replicate('a', 256) + '"foo"' + "'[bar]'") && {fr} C

loTest.Test('2.5487', 2.5487) && {fr} N

loTest.Test('{^2003-02-08}', date(2003,2,8)) && {fr} D

loTest.EnvSet([SET SYSFORMATS ON])
loTest.Test('{^2003-02-08 11:34:15}', datetime(2003,2,8,11,34,15)) && {fr} T
loTest.Test('.T.', .t.) && {fr} L

	luTest = $1254.25 && {fr} le littéral ne passe pas dans l'appel de méthode
loTest.EnvSet([SET DECIMALS TO 3])
loTest.Test('$1254.25', m.luTest) && {fr} Y 

	local loFoo as container
	loFoo = createobject('container')
	loFoo.name = 'cntFoo'
	loFoo.addobject('lblFoo', 'label')

* {fr} loTest.Test('Object of address: cntFoo.LBLFOO', m.loFoo.lblFoo) && {fr} O

&& {fr} G ???

loTest.Test('.NULL.', .null.) && {fr} X

	lcOnError = on('error')
	on error m.llError = .t.
loTest.Test('', foo) && {fr} U = 'Unknown type'
	on error &lcOnError

	luTest = "0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20";
	+ ",21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40";
	+ ",41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60";
	+ ",61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80";
	+ ",81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100";
	+ ",101,102,103"
	luExpected = '"0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20';
	+ ',21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40';
	+ ',41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60';
	+ ',61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80';
	+ ',81,82,83,84,85,86,87,8"+"8,89,90,91,92,93,94,95,96,97,98,99,100';
	+ ',101,102,103"'
loTest.Test(m.luExpected, m.luTest)

return loTest.Result()

* ===================================================================
function cLitterals && {fr} Littéraux
lparameters tu01, tu02, tu03, tu04, tu05, tu06, tu07, tu08, tu09, tu10, tu11, tu12, tu13, tu14, tu15, tu16, tu17, tu18, tu19, tu20 && {fr} Variables

local lcResult;
, liParm;
, luParm;

lcResult = ''
for liParm = 1 to pcount()
	luParm = evaluate(textmerge([m.tu<<Transform(m.liParm, '@L 99')>>]))
	lcResult = m.lcResult + Iif(Vartype(m.luParm) == 'C' and ',' $ m.luParm;
		, cLitterals_List(m.luParm);
		, cLitteral(m.luParm);
		) + ','
endfor
return left(m.lcResult, len(m.lcResult)-1) && {fr} supprime la dernière ','
endfunc

* -----------------------------------------------------------------
function cLitterals_List && {fr} Littéral d'une liste
lparameters cList, cDelim
local aa[1]
return Iif(alines(aa, Evl(m.cList, ''), 5, Evl(m.cDelim, ',')) > 0;
	, cListOfArray(@m.aa,,,.T.);
	, cLitteral(m.cList);
	)
endfunc

* -----------------------------------------------------------------
procedure cLitterals_Test && {fr} teste cLitteral

local loTest as abUnitTest of abDev.prg, lcTest
loTest = newobject('abUnitTest', 'abDev.prg')

loTest.Test(["toto",2.5,.F.,{^2009-03-10}], 'toto', 2.5, .f., date(2009,3,10))
loTest.Test(["toto","tutu"], 'toto, tutu')

return loTest.Result()

* =============================================================
function cLitteralJS_HTML && {fr} Littéral Javascript d'après une valeur VFP pour ajout à un attribut HTML
lparameters ;
  tuData; && @ {fr} Valeur à convertir en littéral ; types supportés : cf. cLitteralJS_lSupport()
, tlTrim; && [.F.] {fr} si type C, ôter les espaces à droite

return strtran(cLitteralJS(m.tuData, m.tlTrim), '"', '&#34;') && {fr} échappe les guillements '"' par '&#34;' pour le HTML
endfunc

* -----------------------------------------------
procedure cLitteralJS_HTML_Test && {fr} cLitteralJS_HTML() unit test

local loTest as abUnitTest of abDev.prg;
, loAsserts as abSet of abDev.prg;
, luData as Variant

loTest = abUnitTest()
loAsserts = abSet('ASSERTS', 'OFF') && 'ON'

loTest.Test(['&#34;Order id&#34;\nTrier : clic gauche\nFiltrer/chercher : clic droit\n(insensible à la casse)'];
	, '"Order id"' + CRLF + 'Trier : clic gauche' + CRLF + 'Filtrer/chercher : clic droit' + CRLF + '(insensible à la casse)';
	)

return m.loTest.Result()
endproc

* =============================================================
function cLitteralJS && {fr} Littéral Javascript d'après une valeur VFP
lparameters ;
  tuData; && @ {fr} Valeur à convertir en littéral ; types supportés : cf. cLitteralJS_lSupport()
, tlTrim; && [.F.] {fr} si type C, ôter les espaces à droite
, tlJSON; && [.F.] {fr} produire un littéral compatible JSON
, tlQuotesNo; && [.F.] {fr} si type C, ne pas entourer de guillemets (XML)

external array tuData

tlJSON = lTrue(m.tlJSON)

local lcVarType, llResult, lcResult

lcResult = ''

lcVarType = type('tuData', 1)
lcVarType = iif(m.lcVarType == 'A', m.lcVarType, vartype(m.tuData))
do case

case m.lcVarType == 'C'

* {fr} Supprimer les caractères non imprimables
&& /!\ 2/8/07	conserver les sauts de ligne		lcResult = cPrintable(m.lcResult)

	* {fr} Encadrer la chaîne de délimiteur, échapper si nécessaire
	* {fr} return ["] + Strtran(Strtran(Iif(lTrue(m.tlTrim), Trim(m.tuData), m.tuData), '\', '\\'), ["], [\"]) + ["]
	return icase(;
		lTrue(m.tlQuotesNo),;
		[];
			+ strtran(strtran(strtran(strtran(iif(lTrue(m.tlTrim), trim(m.tuData), m.tuData);
				, '\', '\\');
				, CRLF, '\n');
				, CR, '\n');
				, LF, '\n');
			+ [],;
		M.tlJSON,;
		[];
			+ ["];
			+ strtran(strtran(strtran(strtran(strtran(iif(lTrue(m.tlTrim), trim(m.tuData), m.tuData);
				, '\', '\\');
				, ["], [\"]);
				, CRLF, '\n');
				, CR, '\n');
				, LF, '\n');
			+ ["],;
		[];
			+ ['];
			+ strtran(strtran(strtran(strtran(strtran(iif(lTrue(m.tlTrim), trim(m.tuData), m.tuData);
				, '\', '\\');
				, ['], [\']); && {fr} see GA_STRINGPARSE_CLASS.MaskStrings(), parameter JSstring
				, CRLF, '\n');
				, CR, '\n');
				, LF, '\n');
			+ ['];
		)

case m.lcVarType $ 'DT'
	return iif(m.tlJSON;
		, textmerge(["<<Year(m.tuData)>>-<<Padl(Month(m.tuData), 2, '0')>>-<<Padl(Day(m.tuData), 2, '0')>>T<<Padl(Hour(m.tuData), 2, '0')>>:<<Padl(Minute(m.tuData), 2, '0')>>:<<Padl(Sec(m.tuData), 2, '0')>>Z"]);
		, 'new Date(' + cYMDHMS(m.tuData, .t.) + ')';
		)

case m.lcVarType == 'X'
	return 'null'

case m.lcVarType == 'L'
	return iif(m.tuData, 'true', 'false')

case m.lcVarType == 'N'
	return strtran(transform(m.tuData), set("Point"), '.')

case m.lcVarType == 'Y'
	return strtran(transform(mton(m.tuData)), set("Point"), '.')

case m.lcVarType == 'O' && {fr} Objet
&& {V 1.25}
	llResult = cLitteralJS_lSupport(m.tuData, @m.lcResult)
	assert m.llResult message cAssertMsg(m.lcResult)
	if m.llResult
&& {V 1.25}

		local laProp[1], lcProp
		if amembers(laProp, m.tuData, 0, 'U') > 0 && 'U' : user-defined
			asort(laProp)
			for each lcProp in laProp
				if not pemstatus(m.tuData, m.lcProp, 2) && {fr} protected
					lcResult = m.lcResult + ',"' + lower(m.lcProp) + '":' + cLitteralJS(getpem(m.tuData, m.lcProp),, .t.) && {fr} JSON compatible
				endif
			next
		endif
		lcResult = '{' + substr(m.lcResult, 2) + '}'
	else
		lcResult = ''
	endif

case m.lcVarType == 'A' && {fr} Array
	if !laEmpty(@m.tuData)
		local luElt, liRow, lcRow, liCol
		if Alen(m.tuData, 2) > 0
			for liRow = 1 to Alen(m.tuData, 1)
				lcResult = m.lcResult + ', ['
				lcRow = ''
				for liCol = 1 to Alen(m.tuData, 2)
					lcRow = m.lcRow + ', ' + cLitteralJS(m.tuData[m.liRow, m.liCol], m.tlTrim, m.tlJSON)
				endfor
				lcResult = m.lcResult + Ltrim(m.lcRow, ',', ' ') + ']'
			endfor
		else
			for each luElt in tuData
				lcResult = m.lcResult + ', ' + cLitteralJS(m.luElt, m.tlTrim, m.tlJSON)
			next
		endif
	endif
	lcResult = '[' + Ltrim(m.lcResult, ',', ' ') + ']'

otherwise
	assert .f. message cAssertMsg(textmerge([could not build a JavaScript constant from <<m.tuData>> of type <<m.lcVarType>>]))
endcase

return m.lcResult
endfunc

* -----------------------------------------------
function cLJS && {fr} Littéral Javascript d'après une valeur VFP && {fr} Alias (simplifié) de cLitteralJS()
lparameters ;
  tuData; && @ {fr} Valeur à convertir en littéral ; types supportés : cf. cLitteralJS_lSupport()
, tlTrim; && [.F.] {fr} si type C, ôter les espaces à droite
, tlJSON && [.F.] {fr} produire un littéral compatible JSON

return cLitteralJS(@m.tuData, m.tlTrim, m.tlJSON)
endfunc

* -----------------------------------------------
function cLitteralJS_lSupport && {fr} Une données est supportée pour conversion en littéral Javascript
lparameters ;
  tuData; && {fr} Donnée à analyser
, tcResult && @ {fr} Résultat localisé si pas supporté

local lcVarType, llResult

lcVarType = type('tuData', 1)
lcVarType = iif(m.lcVarType == 'A', m.lcVarType, vartype(m.tuData))

do case

case m.lcVarType $ 'ACDTXLYN'
	llResult = .t.

case m.lcVarType == 'O'
	do case

	case type('m.tuData.Application.Name') == 'C' and not 'foxpro' $ lower(m.tuData.application.name)
		tcResult = textmerge(icase(;
			cLangUser() = 'fr',	[les objets non foxPro (<<m.tuData.Application.Name>>) ne sont pas supportés],;
													[non-FoxPro objects (<<m.tuData.Application.Name>>) are not supported]; && Default: English
		))

	case type('m.tuData.Class') == 'U' && {fr} Empty class
		llResult = .t.

	case type('m.tuData.BaseClass') == 'C' and inlist(m.tuData.baseclass, 'Collection', 'Control', 'Olecontrol') && {fr} unsupported foxpro class
		tcResult = textmerge(icase(;
			cLangUser() = 'fr',	[la classe de base '<<m.tuData.BaseClass>>' n'est pas supportée],;
													[base class '<<m.tuData.BaseClass>>' is not supported]; && Default: English
		))
	otherwise
		llResult = .t.
	endcase

otherwise
	tcResult = textmerge(icase(;
		cLangUser() = 'fr',	[le type '<<m.lcVartype>>' n'est pas supporté],;
												[type '<<m.lcVartype>>' is not supported]; && Default: English
	))

endcase

return m.llResult

* -----------------------------------------------
procedure cLitteralJS_Test && {fr} cLitteralJS() unit test

local loTest as abUnitTest of abDev.prg;
, loAsserts as abSet of abDev.prg;
, luData as Variant

loTest = abUnitTest()
loAsserts = abSet('ASSERTS', 'OFF') && 'ON'

loTest.Test('4', 4)

loTest.Test('', createobject('Collection'))

loTest.Test('', createobject('Excel.Application'))

luData = createobject('Custom')
m.luData.addproperty('car', 'a')
m.luData.addproperty('num', 2)
m.luData.addproperty('date', date(2012,06,20))
loTest.Test('{"car":"a","date":"2012-06-20T00:00:00Z","num":2}', m.luData)

return m.loTest.Result()

* ===================================================================
function uEmpty && {fr} Valeur vide selon les différents Type()
lparameters ;
  tuType; && {fr} Type de valeur, ou valeur si m.tlValue
, tlValue && [.F.] {fr} tuType contient une valeur

tlValue = lTrue(m.tlValue)

#if .f. && {fr} Types supportés
A	array (only returned when the optional 1 parameter is included)
B	double
C	character, varchar, varchar (Binary)
D	date
F	float
G	general
I	integer
L	Logical
M	memo
N	Numeric, float, double, or integer
O	object
Q	varbinary
S	screen
T	datetime
U	Undefined type of expression or cannot evaluate expression.
V	varchar
W	blob
Y	currency
#endif

local lcType, llResult

do case
case m.tlValue
	lcType = vartype(m.tuType)
	llResult = .T.
case Vartype(m.tuType) == 'C' and varSet(@m.lcType, Upper(Alltrim(m.tuType))) and Lenc(m.lcType) = 1
	llResult = m.lcType $ 'BCDFILMNQTVWY' && 13 types
endcase

assert m.llResult message cAssertMsg(textmerge("Spécification de type non supportée : <<cL(m.tuType)>>"))

return ICase(;
 !m.llResult, .null.,;
	m.lcType $ 'CMV', space(iif(m.tlValue, lenc(m.tuType), 0)),;
	m.lcType $ 'BFNYI', iif(m.tlValue, m.tuType * 0, iif(m.lcType == 'Y', $0, 0)),;
	m.lcType $ 'D', ctod(''),;
	m.lcType $ 'T', ctot(''),;
	m.lcType $ 'L', .f.,;
	m.lcType $ 'QW', 0H,; && {fr} Blob, Varbinary
	.null.;
	)
endfunc

* ===================================================================
function cLitteralNum && {fr} Littéral numérique d'après une chaine de caractères représentant un nombre
lparameters ;
  tcNum; && {fr} Chaine de caractères supposée représenter un nombre
, tlPeriod && [.F.] {fr} séparateur décimal point (.F.: courant) [Val() veut courant, calcul et ALTER COLUMN veulent point]

local llResult, lcResult
lcResult = ''

* {fr} Si le paramètre est de type caractère
llResult = inlist(vartype(m.tcNum), 'C', 'X')
assert m.llResult message cAssertMsg("Paramètre de type caractère ou .NULL. attendu")
if m.llResult

	* {fr} Si le paramètre peut représenter un nombre
	llResult = lNumber(m.tcNum)
	if m.llResult

		* {fr} Supprimer les espaces et séparateurs de milliers éventuels
		local lcNum, lcSep, lcPoint
		lcNum = alltrim(m.tcNum)
		lcSep = set('Separator')
		lcPoint = set('Point')
		lcNum = iif(m.lcSep == m.lcPoint, m.lcNum, chrtran(m.lcNum, m.lcSep, ''))
		lcNum = chrtran(m.lcNum, space(1), '')

		* {fr} Lire si séparateur décimal POINT demandé
		local llPeriod
		llPeriod = iif(vartype(m.tlPeriod) == 'L', m.tlPeriod, .f.)

		* {fr} Si la chaine comporte au plus un séparateur décimal
		local llPoint, lnPoints, lnPeriods
		llPoint = m.lcPoint == '.'
		lnPoints = occurs(m.lcPoint, m.lcNum)
		lnPeriods = iif(m.llPoint, 0, occurs('.', m.lcNum))
		llResult = m.lnPoints + m.lnPeriods <= 1
		if m.llResult

			* {fr} Si le séparateur courant n'est pas le point
			if not m.llPoint

				* {fr} Ajuster le séparateur si nécessaire
				do case
				case m.llPeriod and m.lnPoints = 1
					lcNum = chrtran(m.lcNum, m.lcPoint, '.')
				case not m.llPeriod and m.lnPeriods = 1
					lcNum = chrtran(m.lcNum, '.', m.lcPoint)
				endcase
			endif

			lcResult = m.lcNum
		endif
	endif
endif

return m.lcResult

* -----------------------------------------------------------------
procedure cLitteralNum_Test && {fr} teste cLitteralNum

local loTest as abUnitTest of abDev.prg
loTest = newobject('abUnitTest', 'abDev.prg')
loTest.EnvSet([SET POINT TO ','])
loTest.EnvSet([SET SEPARATOR TO ' '])

loTest.Test('2021.50', ' 2 021,5 0', .t.)
loTest.Test('2021.50', ' 2 021.50', .t.)
loTest.Test('9,99', ' 9.99')
loTest.Test(',99', ' .99')

loTest.EnvSet([SET POINT TO])
loTest.Test('9.99', ' 9.99')

return loTest.Result()

* ===================================================================
function cLitteralDTStrict && {fr} Littéral Date [-Heure] selon le format VFP strict (avec le siècle)
lparameters tuDT && {fr} Date ou DateTime à convertir

local lcVarType, lcResult

lcVarType = vartype(m.tuDT)
if m.lcVarType $ 'DT' and not empty(m.tuDT)

	lcResult = '^' + 	;
			alltrim(str(year(m.tuDT)))+ '-' + ;
			padl(alltrim(str(month(m.tuDT))), 2, '0') + '-' + ;
			padl(alltrim(str(day(m.tuDT),2)), 2, '0') && {fr} Transform(Dtos(m.tuDT), '@R {^####/##/##') + '}' && {fr} Gregory Adam

	return iif(m.lcVarType = 'D';
		, '{' + m.lcResult + '}';
		, '{' + m.lcResult + space(1) + ttoc(m.tuDT, 2) + '}';
		)
else

	return iif(m.lcVarType = 'T', '{/:}', '{/}')
endif

* -----------------------------------------------------------------
procedure cLitteralDTStrict_Test && {fr} teste cLitteralDTStrict()

local loTest as abUnitTest of abDev.prg
loTest = newobject('abUnitTest', 'abDev.prg')

loTest.Test('{/}')
loTest.Test('{^2003-02-08}', date(2003,2,8))

loTest.EnvSet([SET SYSFORMATS ON])
loTest.Test('{^2003-02-08 11:34:15}', datetime(2003,2,8,11,34,15))

return loTest.Result()
endproc

* ===================================================================
function cEuroANSI && {fr} Chaine de caractères désaccentuée
lparameters tuEuropean && {fr} type C : Chaine de caractères accentuée, .T. : supprimer les variables publiques créées

local lcVarType, lcResult && {fr} Chaine de caractères désaccentuée
lcResult = ''

* {fr} Si le paramètre est correct
lcVarType = vartype(m.tuEuropean)
do case
case m.lcVarType == 'C' and not empty(m.tuEuropean)

 	* {fr} Si les chaines de traduction ne sont pas en mémoire, les lire
 	if not vartype(m.EuroAnsi) == 'C'
		public European, EuroAnsi && {fr} pour accélérer les appels répétés
		external file European.mem
		restore from (home() + 'european.mem') additive
	endif

	* {fr} Désaccentuer la chaine
	lcResult = sys(15, m.EuroAnsi, m.tuEuropean)

case m.lcVarType == 'L' and m.tuEuropean
	release European, EuroAnsi
endcase

return m.lcResult

* -----------------------------------------------------------------
procedure cEuroANSI_Test

local loTest as abUnitTest of abDev.prg
loTest = newobject('abUnitTest', 'abDev.prg')
release European, EuroAnsi
loTest.Test('hebete', 'hébété')
loTest.Test('aaaeeeeioouu', 'àäâéèêëioòûù')
loTest.Test('AAAEEEEIOOUU', 'ÀÄÂÉÈÊËIOÒÙÛ')
loTest.Test('', .t.)
loTest.Test('', '')
loTest.Test('', null)

return loTest.Result()

#define PASSWORD_SPECIAL_CHAR	'!#$%&*()_+-={}|[]\";' + ['<>?,./]

* ===================================================================
function cRandPW && {fr} Mot de passe aléatoire sûr selon indications Windows
lparameters ;
  tnLength; && [14] {fr} Nombre de caractères
, tnSep && [0] {fr} Espacer par groupe tnSep caractères à partir de la droite
tnLength = iif(vartype(m.tnLength) = 'N' and m.tnLength > 0, m.tnLength, 14)

local lcCars, lnCars, lnCar, lnSep, lcResult

* {fr} Générer une suite de caractères 'aléatoires' autorisés dans les mots de passe Windows
lcCars = '';
	+ 'abcdefghikklmnopqrstuvwxyz';
	+ 'ABCDEFGHIKKLMNOPQRSTUVWXYZ';
	+ '0123456789';
	+ PASSWORD_SPECIAL_CHAR

lnCars = len(m.lcCars)
lcResult = ''
rand(-1)

for m.lnCar = 1 to m.tnLength
	lcResult = m.lcResult + substr(m.lcCars, evl(int(rand()*m.lnCars), 1), 1)
endfor

* {fr} Si séparateurs demandés, placer
if vartype(m.tnSep) == 'N' and between(m.tnSep, 1, m.tnLength-1)
	lnSep = 0
	do while .t.
		lnSep = m.lnSep + m.tnSep
		if m.lnSep > m.tnLength
			exit
		endif
		lcResult = substr(m.lcResult, 1, m.tnLength - m.lnSep) + space(1) + substr(m.lcResult, m.tnLength - m.lnSep + 1)
	enddo
	lcResult = alltrim(m.lcResult)
endif

return m.lcResult
endfunc

* ===================================================================
function lPasswordSafe && {fr} Un mot de passe est sûr
lparameters ;
  result as String; && @ {en} result
, cPW as String; && {en} password for check
, nChar as Integer; && [10] {en} minimum length in characters, at least 7
, lStrong as Boolean; && [10] {en} minimum length in characters, at least 7

local abRegExp as abRegExp of abTxt.prg, lcSpecial

result = ''

return .T.;
 and (ga_Type_IsChar(m.cPW, .T.) or !varSet(@m.result, 'password should be a non-empty string'));
 and varSet(@m.cPW, Alltrim(m.cPW));
 and varSet(@m.nChar, Iif(ga_Type_IsPositiveInteger(m.nChar), Max(m.nChar, 7), 10));
 and (Lenc(m.cPW) >= m.nChar or !varSet(@m.result, 'password should be at least ' + Cast(m.nChar as M) + ' characters long'));
 and varSet(@m.abRegExp, abRegExp());
 and m.abRegExp.setup('[A-Z]') and (m.abRegExp.test(m.cPW) or !varSet(@m.result, [password should contain at least one upper-case letter]));
 and m.abRegExp.setup('[a-z]') and (m.abRegExp.test(m.cPW) or !varSet(@m.result, [password should contain at least one lower-case letter]));
 and m.abRegExp.setup('[0-9]') and (m.abRegExp.test(m.cPW) or !varSet(@m.result, [password should contain at least one figure]));
 and (!lTrue(m.lStrong) or m.abRegExp.setup('[' + Strtran(Strtran(Strtran(PASSWORD_SPECIAL_CHAR, '-', '\-'), '[', '\['), ']', '\]') + ']') and (m.abRegExp.test(m.cPW) or !varSet(@m.result, [password should contain at least one special character such as ] + PASSWORD_SPECIAL_CHAR)));
 and .T.

endfunc
* -----------------------------------------------------------------
procedure lPasswordSafe_Test && {fr} teste lPasswordSafe()

local loTest as abUnitTest of abDev.prg, result as String
loTest = newobject('abUnitTest', 'abDev.prg')

loTest.Test(.F., @m.result, 'ABCDEFGHI')
wWAIT(m.result, 'window nowait')

loTest.Test(.F., @m.result, 'ABCDEFGHIJK')
wWAIT(m.result, 'window nowait')

loTest.Test(.F., @m.result, 'ABCDEFGHIJk')
wWAIT(m.result, 'window nowait')

loTest.Test(.T., @m.result, 'ABCDEFGHIJk0')
wWAIT(m.result, 'window nowait')

loTest.Test(.F., @m.result, 'ABCDEFGHIJk0', , .T.)
wWAIT(m.result, 'window nowait')

loTest.Test(.T., @m.result, 'ABCDEFGHIJk0!')
wWAIT(m.result, 'window nowait')

return loTest.Result()
endproc


* ===================================================================
function lNumber && {fr} Chaine de caractères représente un nombre
lparameters tcChain && {fr} Chaine à vérifier

local llResult, lcSeps, lcChain, lnChar, lcChar

* {fr} Si la chaine est correcte
if vartype(m.tcChain) == 'C' and not empty(m.tcChain)

	lcSeps = set("Point") + set("Separator") + [ .+-] && {fr} caractères non numériques possibles

 	lcChain = alltrim(m.tcChain)
 	llResult = .t.
	for lnChar = 1 to lenc(m.lcChain)

		lcChar = substr(m.lcChain, m.lnChar, 1)
		if not (isdigit(m.lcChar) or m.lcChar $ m.lcSeps)

			llResult = .f.
			exit
		endif
	endfor
endif

return m.llResult

* ===================================================================
function lDigits && {fr} Chaine composée que de chiffres
lparameters tcChain && {fr} Chaine à vérifier

local llResult, lnChar

if vartype(m.tcChain) == 'C' and not empty(m.tcChain)

	llResult = .t.
	for m.lnChar = 1 to len(m.tcChain)
		if not isdigit(substr(m.tcChain, m.lnChar))
			llResult = .f.
			exit
		endif
	endfor
endif

return m.llResult

* ===================================================================
function nAtDigits && {fr} Position de la première série de chiffres dans une chaine
lparameters ;
  tcChain; && {fr} Chaîne de caractère oû chercher la suite de chiffres
, tnChiffres; && {fr} Longueur de la suite de chiffres à trouver
, tlIgnoreSpace; && [.F.] {fr} Ignorer les espaces au sein de la suite de chiffres
, tcChiffres && @ {fr} Chaîne de chiffres trouvée en retour
local lnResult, llResult
lnResult = 0
tcChiffres = ''

* {fr} Si les paramètres requis sont valides
llResult = vartype(m.tcChain) == 'C' ;
 and vartype(m.tnChiffres) == 'N';
 and m.tnChiffres > 0
assert m.llResult message "Paramètres requis invalides"
if m.llResult

	* {fr} Si la chaine comporte plus de caractères que le nombre de chiffres cherché
	local lnChain
	lnChain = len(m.tcChain)
	if m.lnChain >= m.tnChiffres
		local llIgnoreSpace
		llIgnoreSpace = iif(vartype(m.tlIgnoreSpace) =='L', m.tlIgnoreSpace, .f.)

		* {fr} Pour chaque position dans la chaine
		local lnStart, lcChiffres, lnSpaces, lnCar, lcCar, llChiffre
		for m.lnStart = 1 to m.lnChain - m.tnChiffres + 1
			lcChiffres = ''
			lnSpaces = 0

			* {fr} Pour chaque caractère dans la limite du nombre de chiffres
			for m.lnCar = 0 to m.tnChiffres - 1
				lcCar = substr (m.tcChain, m.lnStart + m.lnCar + m.lnSpaces, 1)

				* {fr} Si le caractère est invalide, décompter
				if m.llIgnoreSpace ;
				 and m.lcCar == space(1) ;
				 and m.lnCar > 0
					lnSpaces = m.lnSpaces + 1
					lnCar = m.lnCar - 1 && {fr} impossible de modifier la borne sup de la boucle

				* {fr} Sinon (caractère valide)
				else

					* {fr} Si le caractère est un chiffre, ajouter à la chaine de chiffres
					llChiffre = lNumChar(m.lcCar)
					if m.llChiffre
						lcChiffres = m.lcChiffres + m.lcCar

					* {fr} Sinon, abandonner la recherche
					else
						exit
					endif
				endif
			endfor

			* {fr} Si la chaine de chiffres a été trouvée, sortir
			if m.llChiffre
				exit
			endif
		endfor

		* {fr} Si la chaine de chiffres a été trouvée, mémoriser en retour
		if llChiffre
			lnResult = m.lnStart
			tcChiffres = m.lcChiffres
		endif
	endif
endif

return lnResult

* -----------------------------------------------------------------
procedure nAtDigits_Test && {fr} Teste nAtDigits

local loTest as abUnitTest of abDev.prg, result as String
loTest = newobject('abUnitTest', 'abDev.prg')

loTest.Test(1, '0123456789', 3)
loTest.Test(1, '0123456789', 3, .f., @m.result)
loTest.assert(m.result, '012')
loTest.Test(4, '01 23456789', 3, .f., @m.result)
loTest.assert(m.result, '234')
loTest.Test(1, '01 23456789', 3, .t., @m.result)
loTest.assert(m.result, '012')
loTest.Test(0, '012345678 9', 10, .f., @m.result)
loTest.assert(m.result, '')
loTest.Test(1, '012345678 9', 10, .t., @m.result)
loTest.assert(m.result, '0123456789')
loTest.Test(7, 'ABCDEF678 9', 4, .t., @m.result)
loTest.assert(m.result, '6789')
loTest.Test(12, '1 2 3ABCDEF678 9', 4, .t., @m.result)
loTest.assert(m.result, '6789')

return m.loTest.result()

* ===================================================================
function nAtSep && {fr} Position du premier séparateur en partant de la gauche
lparameter ;
  tcChain; && {fr} Chaîne à analyser
, tcSeps; && [".,:;|/\-_*#!$Â§Â£&"] {fr} Séparateurs recherchés
, tnOcc && [1] {fr} Numéro d'occurrence de séparateur recherchée
local lnResult && {fr} Position du séparateur dans la chaîne (= 0 si aucun)

lnResult = nLRAtSep ('L', m.tcChain, m.tcSeps, m.tnOcc)

return m.lnResult

* ===================================================================
function nRAtSep && {fr} Position du premier séparateur en partant de la droite
lparameter ;
  tcChain; && {fr} Chaîne à analyser
, tcSeps; && [".,:;|/\-_*#!$Â§Â£&"] {fr} Séparateurs recherchés
, tnOcc && [1] {fr} Numéro d'occurrence de séparateur recherchée
local lnResult && {fr} Position du séparateur dans la chaîne (= 0 si aucun)

lnResult = nLRAtSep ('R', m.tcChain, m.tcSeps, m.tnOcc)

return m.lnResult

* ===================================================================
function nLRAtSep && {fr} Position du premier séparateur en partant de la gauche ou de la droite
lparameter 	;
  tcSens; && ['L'] {fr} indique s'il faut chercher en partant de la gauche (L) ou de la droite (R)
, tcChain; && {fr} Chaîne à analyser
, tcSeps; && [".,:;|/\-_*#!$Â§Â£&"] {fr} Séparateurs recherchés
, tnOcc && [1] {fr} Numéro d'occurrence de séparateur recherchée
local lnResult && {fr} Position du séparateur dans la chaîne (= 0 si aucun)
lnResult = 0

#define DEFAULT_SEP 	".,:;|/\-_*#!$Â§Â£&"

* {fr} Si une chaîne non vide a été passée
if vartype(m.tcChain) == 'C' ;
 and not empty(m.tcChain)

	* {fr} Régler les valeurs par défaut des paramètres optionnels
	local lcSens, lcSeps, lnOcc
	lcSens = iif(vartype(m.tcSens) = 'C', upper(left(ltrim(m.tcSens),1)), 'L')
	lcSens = iif(m.lcSens $ 'LR', m.lcSens, 'L')
	lcSeps = iif(vartype(m.tcSeps)='C' and ! empty(m.tcSeps), m.tcSeps, DEFAULT_SEP)
	lnOcc = iif(vartype(m.tnOcc)='N' and m.tnOcc > 0, m.tnOcc, 1)

	* {fr} Pour chaque séparateur
	local lnSep, lcSep
	for m.lnSep = 1 to len(m.lcSeps)
		lcSep = substr(m.lcSeps, m.lnSep, 1)

		* {fr} Si le séparateurs est dans le chaine, arrêter
		lnResult = iif(m.lcSens = 'L', ;
											at (m.lcSep, m.tcChain, m.lnOcc), ;
											rat (m.lcSep, m.tcChain, m.lnOcc))
		if m.lnResult > 0
			exit
		endif
	endfor
endif

return m.lnResult

* ===================================================================
function cFigures && {fr} Chiffres contenus dans une chaîne de caractères
lparameters ;
  tcChain; && {fr} Chaîne à analyser
, tlRight && [.F.] {fr} Chercher en partant de la droite
local lcResult && {fr} Chiffres extraits dans l'ordre oû ils se trouvent
lcResult = ''

* {fr} Si la chaine comporte des caractères
if vartype(m.tcChain)='C' ;
 and not empty(m.tcChain)

	* {fr} Calculer la longueur de la chaine
	local lcChain, lnChain
	lcChain = alltrim(m.tcChain)
	lnChain = len(m.lcChain)

	* {fr} Déterminer le sens de recherche
	local llRight, lnStart, lnEnd, lnStep
	llRight = iif(vartype(m.tlRight)=='L', m.tlRight, .f.)
	lnStart = iif(m.llRight, m.lnChain, 1)
	lnEnd = iif(m.llRight, 1, m.lnChain)
	lnStep = iif(m.llRight, -1, 1)

	* {fr} Pour chaque caractère dans l'ordre demandé
	local lnCar, lcCar
	for m.lnCar = m.lnStart to m.lnEnd step m.lnStep
		lcCar = substr(m.lcChain, m.lnCar, 1)

		* {fr} Si le caractère est un chiffre, ajouter au résultat
		if isdigit(m.lcCar)
			lcResult = iif(m.llRight, m.lcCar + m.lcResult, m.lcResult + m.lcCar)
		endif
	endfor
endif

return m.lcResult

* ===================================================================
function lNumChar && {fr} Chaine de caractères commence par un chiffre, un séparateur ou un opérateur
lparameters tcChain
return Iif(vartype(m.tcChain)='C'; &&  and varSet(@m.tcChain, Alltrim(m.tcChain))
	, IsDigit(m.tcChain) or Leftc(m.tcChain, 1) $ set('POINT') + '-+';
	, .null.;
	)

* -----------------------------------------------------------------
procedure lNumChar_Test && {fr} teste lNumChar

local loTest as abUnitTest of abDev.prg, loPoint as abSet of abDev.prg
loTest = newobject('abUnitTest', 'abDev.prg')

loTest.Test(.null., .null.)
loTest.Test(.null., 854)
loTest.Test(.F., '')
loTest.Test(.F., ' ')
loTest.Test(.F., 'toto')
loTest.Test(.F., ' 915')
loTest.Test(.T., '915')

loTest.envSet('set point to ","')
loTest.Test(.F., '.915')
loTest.Test(.T., ',915')

loTest.envSet('set point to')
loTest.Test(.T., '.915')
loPoint = .null.

return m.loTest.result()

* ===================================================================
function lEmailAddrOK && {fr} Adresse courriel valide
lparameters tcEmailAddr && {fr} Adresse courriel à valider

local lceMailAddr, lnCar, llResult

&& {fr} réécrire avec RegExp : "^([0-9a-zA-Z]+([-.=_+&])*[0-9a-zA-Z]+)*@([-0-9a-zA-Z]+[.])+[a-zA-Z]{2,6}$"

* {fr} Si l'adresse est non vide
llResult = not empty(m.tcEmailAddr)
if m.llResult
	lceMailAddr = upper(alltrim(m.tcEmailAddr))

	* {fr} Si l'adresse ne comporte que des caractères autorisés
	for m.lnCar = 1 to lenc(m.lceMailAddr)
		llResult = substr(m.lceMailAddr, m.lnCar, 1) $ "1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ@.-_"
		if not m.llResult
			exit
		endif
	endfor
	if m.llResult

		* {fr} Si l'adresse comporter un "@" un un seul
		llResult = occurs("@", m.lceMailAddr) = 1
		if m.llResult

			* {fr} Si l'adresse comporte au moins un point à droite de "@" (pour le nom de domaine)
			lnCar = atc("@", m.lceMailAddr)
			llResult = occurs('.', substr(m.lceMailAddr, m.lnCar + 1)) > 0
		endif
	endif
endif

return m.llResult

* ===================================================================
function cVFPNameSubstr && {fr} Nom VFP commençant à partir d'une position dans une chaîne
lparameters ;
  tcChain; && {fr} Chaine de caractère
, tiPos && {fr} Position du nom dans la chaîne; Si @, devient la position immédiatement après le nom trouvé

local lcResult;
, lcChar;
, llChar;

lcResult = ''

* {en} Move until first non-space character
do while substr(m.tcChain, m.tiPos, 1) == space(1)
	tiPos = m.tiPos + 1
enddo

* {en} Check first character is alpha or '_'
lcChar = substr(m.tcChain, m.tiPos, 1)
llChar = isalpha(m.lcChar) or m.lcChar == '_'

* {en} Check following characters
do while m.llChar
	lcResult = m.lcResult + m.lcChar
	tiPos = m.tiPos + 1
	lcChar = substr(m.tcChain, m.tiPos, 1)
	llChar = IsAlpha(m.lcChar) or m.lcChar == '_' or IsDigit(m.lcChar)
enddo

return m.lcResult
endfunc

* --------------------
procedure cVFPNameSubstr_Test && {fr} teste cVFPNameSubstr()

local loTest as abUnitTest of abDev.prg, loPoint as abSet of abDev.prg
loTest = newobject('abUnitTest', 'abDev.prg')

loTest.Test('tcChain', 'lpara tcChain', 7)
loTest.Test('tcChain', 'lpara tcChain', 6)
loTest.Test('', 'lpara 3cChain', 7)
loTest.Test('_cChain', 'lpara _cChain', 7)

return m.loTest.result()

* ===================================================================
function cParenth && {fr} Met une chaîne entre parenthèses ou autre signes encadrants
lparameters ;
  tcChain; && {fr} chaine source
, tcParenth && [()] {fr} caractères d'encadement à ajouter

local llResult, lcResult && {fr} Chaine avec la référence ajoutée
lcResult = ''

llResult = vartype(m.tcChain) == 'C'
assert m.llResult message cAssertMsg(textmerge("Paramètre invalide: <<m.tcChain>>"))
if m.llResult

	tcParenth = iif(vartype(m.tcParenth) == 'C' and lenc(alltrim(m.tcParenth)) = 2, alltrim(m.tcParenth), [()])
	lcResult = iif(empty(m.tcChain), m.tcChain, leftc(m.tcParenth, 1) + m.tcChain + rightc(m.tcParenth, 1))
endif

return m.lcResult

* ===================================================================
function cRefAppend && {en} Appends a (reference) to a string {fr} Ajoute une référence entre parenthèses à la fin d'une chaîne
lparameters ;
  tcChain; && {en} source string {fr} chaine source
, tuRef; && {en} reference to append; .null. removes any existing reference {fr} Référence à ajouter ; .NULL. supprimer une référence existante éventuelle
, tlReplace; && [.F.] {en} Replace an existing reference if any {fr} Remplacer une référence existante éventuelle
, tlNoZero; && [.F.] {en} do not mention '0' {fr} Ne pas mentionner la valeur 0
, tcPrefix && [''] {en} prefix to the reference to be appended {fr} préfixe à la référence à ajouter

local lcResult; && {fr} Chaine avec la référence ajoutée
, llResult;
, liOpen, lcOpen;
, lnRat, lcRefType

lcResult = nvl(evl(m.tcChain, ''), '')

llResult = vartype(m.lcResult) == 'C'
assert m.llResult message cAssertMsg(textmerge("Paramètre invalide: <<m.tcChain>>"))
if m.llResult and !empty(m.lcResult)

	tlReplace = lTrue(m.tlReplace) or isnull(m.tuRef)
	lcRefType = vartype(m.tuRef)

	#define cRefAppend_OPENS '([{<'
	#define cRefAppend_CLOSE ')]}>'

	for liOpen = 1 to len(cRefAppend_OPENS)
		lcOpen = substr(cRefAppend_OPENS, m.liOpen, 1)

		lnRat = ratc(m.lcOpen, m.lcResult)
		if m.lnRat = 0 or m.tlReplace

			* ===================================================
			return iif(.f.;
				 or m.lcRefType == 'X';
				 or m.lcRefType == 'N' and lTrue(m.tlNoZero) and empty(m.tuRef);
				 or m.lcRefType == 'C' and empty(m.tuRef);
				 , trim(iif(m.lnRat > 0;
				   , left(m.lcResult, m.lnRat-1);
				   , m.lcResult;
				   ));
				 , '';
					+ trim(iif(m.tlReplace and m.lnRat > 0;
						, left(m.lcResult, m.lnRat-1);
						, m.lcResult;
						));
					+ ' ';
					+ m.lcOpen;
					+ c2Words(;
						  iif(ga_Type_IsChar(m.tcPrefix, .t.), alltrim(m.tcPrefix), '');
						, ' ';
						, alltrim(transform(m.tuRef));
						);
					+ substr(cRefAppend_CLOSE, m.liOpen, 1);
				 )
				* ===================================================
		endif
	endfor

	assert .f. message cAssertMsg(textmerge("<<m.tcChain>> contains all opening characters: ") + cLitteral(cRefAppend_OPENS))
endif

return m.lcResult

* -----------------------------------------------------------------
procedure cRefAppend_Test && {fr} Test unitaire de cRefAppend() && .060 ms - 60 Âµs

local loTest as abUnitTest of abDev.prg
loTest = newobject('abUnitTest', 'abDev.prg')

loTest.Test('appuie-tête (1)', 'appuie-tête', 1)
loTest.Test('appuie tête (10)', 'appuie tête', 10)
loTest.Test('appuie-tête (2) [test]', 'appuie-tête (2)', 'test')
loTest.Test('appuie tête', 'appuie tête (10)', .null.)
loTest.Test('appuie tête (5)', 'appuie tête (10)', 5, .t.)
loTest.Test('appuie tête', 'appuie tête (10)', 0, .t., .t.)
loTest.Test('appuie tête (nombre: 5)', 'appuie tête (10)', 5, .t., , 'nombre: ')

return loTest.Result()

* ===================================================================
function lInList && {fr} Un mot se trouve dans une liste délimitée
lparameters ;
  tcWord; && {fr} Mot à trouver
, tcList; && {fr} Liste délimitée
, tcSep; && [,] {fr} Séparateur de liste
, tlCase; && [.F.] {fr} Respecter la casse
, tlExactCur && [.F.] {fr} Conserver Set("Exact") - .F. : SET EXACT ON

local laElts[1], llResult

llResult = vartype(m.tcList) == 'C' and vartype(m.tcWord) == 'C'
assert m.llResult message cAssertMsg(textmerge([la liste <<m.tcList>> et le mot <<m.tcWord>> doivent être de type caractère]))
if m.llResult

	llResult = not (empty(m.tcList) or empty(m.tcWord))
	if m.llResult

		tcSep = iif(vartype(m.tcSep) == 'C' , iif(empty(m.tcSep), m.tcSep, alltrim(m.tcSep)), ',')
* {fr} tcSep = Iif(Lenc(m.tcSep) == 1, m.tcSep, ',')
		tlCase = lTrue(m.tlCase)
		tlExactCur = lTrue(m.tlExactCur)

		alines(laElts, m.tcList, 1, m.tcSep)
		llResult = ascan(laElts, alltrim(m.tcWord), 1, -1, 1, iif(m.tlCase, 0, 1) + iif(m.tlExactCur, 0, 2+4)) > 0
	endif
endif

return m.llResult
endfunc

* -----------------------------------------------------------------
procedure lInList_Test

local loTest as abUnitTest of abDev.prg, lnAtc
loTest = newobject('abUnitTest', 'abDev.prg')

loTest.Test(.t., 'dossier', 'DOSSIER, COND, SINISTRE')
loTest.Test(.f., 'dossier', 'DOSSIER, COND, SINISTRE', ';')
loTest.Test(.f., 'dossier', 'DOSSIER, COND, SINISTRE', , .t.)

return loTest.Result()
endproc

* ===================================================================
function cListEdit && {fr} Ajoute ou supprime un élément d'une liste sans doublon
lparameters ;
  tcList; && {fr} Liste à éditer
, tcElts; && {fr} Élément(s) à ajouter / supprimer
, tlRemove; && [.F.] {fr} Supprimer le ou les élément(s)
, tcSep; && [,] {fr} Séparateur de liste
, tlCase; && [.F.] {fr} Respecter la casse

local lcResult;
, llResult;
, laList[1], lnList;
, lnFlags;
, laElts[1], lcElt, liElt, llElt;

lcResult = m.tcList

llResult = vartype(m.tcList) == 'C' and vartype(m.tcElts) == 'C'
assert m.llResult message cAssertMsg(textmerge([la liste <<cLitteral(m.tcList)>> et le ou les élément(s) <<cLitteral(m.tcElts)>> doivent être de type caractère]))
if m.llResult

	tcSep = iif(vartype(m.tcSep) == 'C' and lenc(m.tcSep) == 1, m.tcSep, ',')

	* {fr} Si des éléments sont spécifiés
	if ALines(laElts, m.tcElts, 1+4, m.tcSep) > 0

		tlRemove = lTrue(m.tlRemove)
		lnFlags = iif(lTrue(m.tlCase), 0, 1) + 2 + 4

		* {fr} Pour chaque élément de la liste existante
		lnList = ALines(laList, m.tcList, 1+4, m.tcSep)
		for each lcElt in laElts

			* {fr} Voir si l'élément est dans la liste
			liElt = ascan(laList, m.lcElt, 1, -1, 1, m.lnFlags)
			llElt = m.liElt > 0

			do case
			case m.tlRemove and m.llElt
				adel(laList, m.liElt)
				lnList = m.lnList - 1

			case !m.tlRemove and !m.llElt
				lnList = m.lnList + 1
				dimension laList[m.lnList]
				laList[m.lnList] = m.lcElt
			endcase
		endfor

		* {fr} Reconstituer la liste
		lcResult = Iif(m.lnList > 0, cListOfArray(@m.laList, m.tcSep), '')
	endif
endif

return m.lcResult
endfunc

* ===================================================================
function cListsIntersect as String && {fr} Intersections de 2 listes
&& 2016-11-07 thn -- {FiC V 2.23.0-beta.2} {en} created
lparameters ;
  tcList1 as String; && {en} List 1
, tcList2 as String; && {en} List 2
, tcSep as String; && [','] {en} Item separator
, tlCase as Boolean; && [.F.] {en} case-sensitive comparison {fr} Comparer en respectant la casse
, tlOuter as Boolean; && [.F.] {en} Elements of List 1 not in List 2

tcSep = Iif(Vartype(m.tcSep) == 'C' and Lenc(m.tcSep) > 0, m.tcSep, ',')
tlOuter = lTrue(m.tlOuter)

local aList1[1], lList1, aList2[1], lList2

lList1 = ALines(aList1, m.tcList1, 5, m.tcSep) > 0
lList2 = ALines(aList2, m.tcList2, 5, m.tcSep) > 0

return ICase(;
	m.lList1 and m.lList2,;
		Iif(aFilter(@m.aList1, @m.aList2, , m.tlCase, m.tlOuter) > 0;
			, cListOfArray(@m.aList1, m.tcSep);
			, '';
			),;
	!m.lList1,;
		'',;
	m.lList1 and !m.lList2,;
		Iif(m.tlOuter, m.tcList1, ''),;
		'';
	)
endfunc

* -----------------------------------------------------------------
procedure cListsIntersect_Test

local loTest as abUnitTest of abDev.prg, lnAtc
loTest = newobject('abUnitTest', 'abDev.prg')

loTest.Test('bar baz';
	, 'foo bar baz'; && tcList1 {en} List 1
	, 'fuu bar baz'; && tcList2 {en} List 2
	, ' '; && tcSep [','] {en} Item separator
	, ; && tlCase [.F.] {en} case-sensitive comparison {fr} Comparer en respectant la casse
	, ; && tlOuter [.F.] {en} Elements of List 1 not in List 2
	)

loTest.Test('bar';
	, 'foo bar'; && tcList1 {en} List 1
	, 'fuu BAR'; && tcList2 {en} List 2
	, ' '; && tcSep [','] {en} Item separator
	, ; && tlCase [.F.] {en} case-sensitive comparison {fr} Comparer en respectant la casse
	, ; && tlOuter [.F.] {en} Elements of List 1 not in List 2
	)

loTest.Test('';
	, 'foo bar'; && tcList1 {en} List 1
	, 'fuu BAR'; && tcList2 {en} List 2
	, ' '; && tcSep [','] {en} Item separator
	, .T.; && tlCase [.F.] {en} case-sensitive comparison {fr} Comparer en respectant la casse
	, ; && tlOuter [.F.] {en} Elements of List 1 not in List 2
	)

loTest.Test('foo';
	, 'foo bar'; && tcList1 {en} List 1
	, 'fuu BAR'; && tcList2 {en} List 2
	, ' '; && tcSep [','] {en} Item separator
	, ; && tlCase [.F.] {en} case-sensitive comparison {fr} Comparer en respectant la casse
	, .T.; && tlOuter [.F.] {en} Elements of List 1 not in List 2
	)

loTest.Test('';
	, 'active'; && tcList1 {en} List 1
	, ''; && tcList2 {en} List 2
	, ' '; && tcSep [','] {en} Item separator
	, ; && tlCase [.F.] {en} case-sensitive comparison {fr} Comparer en respectant la casse
	, ; && tlOuter [.F.] {en} Elements of List 1 not in List 2
	)

loTest.Test('active';
	, 'active'; && tcList1 {en} List 1
	, ''; && tcList2 {en} List 2
	, ' '; && tcSep [','] {en} Item separator
	, ; && tlCase [.F.] {en} case-sensitive comparison {fr} Comparer en respectant la casse
	, .T.; && tlOuter [.F.] {en} Elements of List 1 not in List 2
	)

loTest.Test('';
	, ''; && tcList1 {en} List 1
	, 'active'; && tcList2 {en} List 2
	, ' '; && tcSep [','] {en} Item separator
	, ; && tlCase [.F.] {en} case-sensitive comparison {fr} Comparer en respectant la casse
	, ; && tlOuter [.F.] {en} Elements of List 1 not in List 2
	)

loTest.Test('';
	, ''; && tcList1 {en} List 1
	, 'active'; && tcList2 {en} List 2
	, ' '; && tcSep [','] {en} Item separator
	, ; && tlCase [.F.] {en} case-sensitive comparison {fr} Comparer en respectant la casse
	, .T.; && tlOuter [.F.] {en} Elements of List 1 not in List 2
	)

loTest.Test('active';
	, 'active'; && tcList1 {en} List 1
	, ''; && tcList2 {en} List 2
	, ' '; && tcSep [','] {en} Item separator
	, ; && tlCase [.F.] {en} case-sensitive comparison {fr} Comparer en respectant la casse
	, .T.; && tlOuter [.F.] {en} Elements of List 1 not in List 2
	)

loTest.Test('';
	, 'active'; && tcList1 {en} List 1
	, 'active'; && tcList2 {en} List 2
	, ' '; && tcSep [','] {en} Item separator
	, ; && tlCase [.F.] {en} case-sensitive comparison {fr} Comparer en respectant la casse
	, .T.; && tlOuter [.F.] {en} Elements of List 1 not in List 2
	)

return loTest.Result()
endproc

* ===================================================================
function lWordsIn && {fr} Plusieurs mots se trouvent dans une chaîne
lparameters ;
  tcWords; && {fr} Mots à chercher
, tcChain; && {fr} Chaine oû chercher
, tlCaseIgnore; && [.F.] {fr} Ignorer la casse
, tlAnyWord; && [.F.] {fr} Traiter le mot même s'il comporte des caractère de séparation
, tnAtc; && @ [1] {fr} position de début de recherche, en retour, position trouvée, 0 si pas trouvé
, tlOr && [.F.] {fr} Trouver au moins un des mots
tlOr = lTrue(m.tlOr)

local laWord[1], lcWord, llWord, llResult

llResult = vartype(m.tcWords) == 'C' and alines(laWord, m.tcWords, 7, ',', ';') > 0
assert m.llResult message cAssertMsg(textmerge("received invalid parameters"))
if m.llResult

	llResult = not m.tlOr

	for each lcWord in laWord

		llWord = lWordIn(m.lcWord, m.tcChain, m.tlCaseIgnore, m.tlAnyWord, m.tnAtc)

		if m.tlOr
			if m.llWord
				return .t.
			endif
		else
			if not m.llWord
				return .f.
			endif
		endif
	endfor
endif

return m.llResult

* ===================================================================
function lWordIn && {fr} Un mot se trouve dans une chaîne
lparameters ;
  tcWord; && {fr} Mot à chercher
, tcChain; && {fr} Chaine oû chercher
, tlCaseIgnore; && [.F.] {fr} Ignorer la casse
, tlAnyWord; && [.F.] {fr} Traiter le mot même s'il comporte des caractère de séparation
, tnAtc && @ [1] {fr} position de début de recherche, en retour, position trouvée, 0 si pas trouvé

local llResult

llResult = vartype(m.tcChain) == 'C';
 and vartype(m.tcWord) == 'C';
 and not (empty(m.tcChain) or empty(m.tcWord));
 and (lTrue(m.tlAnyWord);
 		 or chrtran(m.tcWord, VFPOPSEPCARS, '') == m.tcWord)
assert m.llResult message cAssertMsg(textmerge("received invalid parameters"))
if m.llResult

	tlCaseIgnore = lTrue(m.tlCaseIgnore)
	tnAtc = iif(vartype(m.tnAtc) == 'N' and m.tnAtc > 0, m.tnAtc, 1)

	* {fr} Si le mot est présent dans la chaîne à partir de la position de départ
	local lcWord, lnWord, lcChain, lnAt, lcCarAnte, lcCarPost
	lcWord = iif(m.tlCaseIgnore, upper(m.tcWord), m.tcWord)
	lnWord = len(m.lcWord)
	lcChain = substr(iif(m.tlCaseIgnore, upper(m.tcChain), m.tcChain), m.tnAtc)
	tnAtc = m.tnAtc - 1 && {fr} piquets et intervalles !
	do while .t.

		lnAt = atc(m.lcWord, m.lcChain)
		llResult = m.lnAt > 0
		if m.llResult

			tnAtc = m.tnAtc + m.lnAt

			* {fr} Si le mot trouvé est encadré par un séparateur ou un opérateur
			lcCarAnte = substr(m.lcChain, m.lnAt - 1, 1)
			lcCarPost = substr(m.lcChain, m.lnAt + len(m.tcWord), 1)

			llResult = (empty(m.lcCarAnte) or m.lcCarAnte $ VFPOPSEPCARS);
						 and (empty(m.lcCarPost) or m.lcCarPost $ VFPOPSEPCARS)
			if m.llResult
				exit
			else
				lcChain = substr(m.lcChain, m.lnAt + m.lnWord)
				tnAtc = m.tnAtc + m.lnWord - 1 && {fr} piquets et intervalles !
			endif
		else
			exit
		endif
	enddo
endif

tnAtc = iif(m.llResult, m.tnAtc, 0)

return m.llResult

* -----------------------------------------------------------------
procedure lWordIn_Test

local loTest as abUnitTest of abDev.prg, lnAtc
loTest = newobject('abUnitTest', 'abDev.prg')

loTest.Test(.t., 'le', 'je+suis-décidément le meilleur')
loTest.Test(.t., 'LE', 'je+suis-décidément le meilleur', .t.)
loTest.Test(.t., 'suis', 'je+suis-décidément le meilleur')

loTest.Test(.f., 'déci', 'je+suis-décidément le meilleur')
loTest.Test(.f., 'deci', 'je+suis-décidément le meilleur')
loTest.Test(.f., 'DÉCI', 'je+suis-décidément le meilleur')

loTest.Test(.t., 'nDOW', 'anDOW + cnDOW(nDOW)', .t., .t., @m.lnAtc)
loTest.assert(15, lnAtc)

lnAtc = 14
loTest.Test(.t., 'BATDUR', 'ISNULL(batdur).OR.BETWEEN(batdur,0,20)', .t.,, @m.lnAtc)
loTest.assert(27, lnAtc)

return loTest.Result()

* ===================================================================
function anWordIn && {fr} Positions d'un mot dans une chaîne
lparameters ;
  ta; && @ {fr} Positions du mot
, tcChain; && {fr} Chaine
, tcWord; && {fr} Mot à chercher
, tlCaseIgnore; && [.F.] {fr} Ignorer la casse
, tlAnyWord && [.F.] {fr} Traiter le mot même s'il comporte des caractère de séparation
external array ta

local lnAtc, lnResult && {fr} nombre de positions trouvées

lnResult = 0
if aClear(@m.ta)

	lnAtc = 0
	do while .t.
		if lWordIn(m.tcWord, m.tcChain, m.tlCaseIgnore, m.tlAnyWord, @m.lnAtc)
			lnResult = lnResult + 1
			dimension ta[m.lnResult]
			ta[m.lnResult] = m.lnAtc
			lnAtc = lnAtc + len(m.tcWord)
		else
			exit
		endif
	enddo
endif

return m.lnResult

* -----------------------------------------------------------------
procedure anWordIn_Test

local loTest as abUnitTest of abDev.prg, laTest[1]
loTest = newobject('abUnitTest', 'abDev.prg')

loTest.Test(1, @m.laTest, 'je+suis-décidément le meilleur', 'le')
loTest.assert(20, laTest[1])

return loTest.Result()

* ===================================================================
function lExpression(m.tcExpr) && {fr} Une chaîne est une expression (alias de lExpr())
return lExpr(m.tcExpr)

* ===================================================================
function lExpr && {fr} Une chaîne est une expression /!\ simpliste!
lparameters tcExpr

local array laOps[1]

return .t.;
 and vartype(m.tcExpr) == 'C';
 and aOperands(@m.laOps, alltrim(m.tcExpr, ' ', '(', ')', '[' , ']')) > 1

* -----------------------------------------------------------------
procedure lExpr_Test

local loTest as abUnitTest of abDev.prg
loTest = newobject('abUnitTest', 'abDev.prg')

loTest.Test(.t., 'toto = alias.field +fonction(alias.tutu)')
loTest.Test(.f., 'alias.tutu')
loTest.Test(.f., 'm.tutu')

return loTest.Result()

* ===================================================================
function aOperands && {fr} Opérandes d'une expression /!\ simpliste!
lparameters ;
  taOps; && @ {fr} Opérande | position dans l'expression
, tcExp && {fr} Expression

* {fr} Si les paramètres sont valides
if type('taOps', 1) == 'A' and vartype(m.tcExp) == 'C'

	* {fr} Tabuler les opérandes
	local lcVFPOpSepCars
	lcVFPOpSepCars = VFPOPSEPCARSLIST && {fr} pour macro-substitution
	return alines(taOps, m.tcExp, 1+4, &lcVFPOpSepCars)

else
	assert .f. message cAssertMsg(textmerge([received invalid parameters]))
	return 0

endif

external array taOps

* -----------------------------------------------------------------
procedure aOperands_Test && aOperands() unit test

local loTest as abUnitTest of abDev.prg, laOps[1]
loTest = newobject('abUnitTest', 'abDev.prg')

loTest.Test(4, @m.laOps, 'toto = alias.field +fonction(alias.tutu)')

loTest.Test(5, @m.laOps, 'toto = alias.field +fonction(alias.tutu + 5)')
loTest.assert('toto', m.laOps[1])
loTest.assert('alias.field', m.laOps[2])
loTest.assert('fonction', m.laOps[3])
loTest.assert('alias.tutu', m.laOps[4])
loTest.assert('5', m.laOps[5])

return loTest.Result()
endproc

* ===================================================================
function cVFPOpSepCarsList && {fr} Opérateurs et séparateurs VFP séparés par une ','
lparameters tcCarsExclude && [''] {fr} Caractères à exclure

local lcResult;
, lcCars, lnCar

lcResult = ''

* {fr} Lister les opérateurs et séparateurs
lcCars = chrtran(VFPOPSEPCARS, uDefault(m.tcCarsExclude, ''), '')

for lnCar = 1 to len(m.lcCars)
	lcResult = m.lcResult + ',' + ['] + substr(m.lcCars, m.lnCar, 1) + [']
endfor

return substr(m.lcResult, 2) && {fr} supprime la ',' initiale

* ===================================================================
function cFirstAlpha && {fr} Chaîne dont l'initiale est alphabétique
lparameters ;
  tcChain && {fr} Chaine
local llResult, lcResult
lcResult = ''

llResult = vartype(m.tcChain) == 'C'
assert m.llResult message cAssertMsg(textmerge("paramètre invalide: <<m.tcChain>>"))
if m.llResult

	lcResult = m.tcChain
	do while not isalpha(m.lcResult)
		lcResult = substr(m.lcResult, 2)
	enddo
endif

return m.lcResult

* -----------------------------------------------------------------
procedure cFirstAlpha_Test

local loTest as abUnitTest of abDev.prg
loTest = newobject('abUnitTest', 'abDev.prg')

loTest.Test('ceci est un test', '123 ceci est un test')
loTest.Test('ceci est un test', '1$3 ceci est un test')
loTest.Test('ceci est un test', '1*3 ceci est un test')
loTest.Test('ceci est un test', '1"3 ceci est un test')

return loTest.Result()

* ===================================================================
function cUIDRand && {fr} Identifiant probablement unique de 14 caractères
rand(-1)
return sys(2015) + transform(int(rand()*1000), '@L 9999')

* ===================================================================
function abRegExp && {fr} Objet abRegExp
lparameters ;
  tcPattern as String; && [''] {fr} Expression régulière de recherche
, tcFlags as String; && [''] {fr} commutateurs (igm)

local abRegExp as abRegExp of abTxt.prg

abRegExp = createobject('abRegExp') && # 5 ms
if vartype(m.abRegExp) == 'O' and ga_Type_IsChar(m.tcPattern, .t.)
	m.abRegExp.setup(m.tcPattern, evl(m.tcFlags, ''))
endif

return m.abRegExp
endfunc

* ----------------------
procedure abRegExp_Test

local loTest as abUnitTest of abDev.prg
loTest = newobject('abUnitTest', 'abDev.prg')
loTest.Test
return loTest.Result()

* ===================================================================
function abRegExpTest && {fr} Une chaîne satisfait un RegExp
lparameters ;
  tcString; && [''] {fr} Chaîne à tester
, tcPattern; && [''] {fr} Expression régulière de recherche
, tcFlags; && [''] {fr} commutateurs (igm)

local abRegExp as abRegExp of abTxt.prg
abRegExp = abRegExp(m.tcPattern, m.tcFlags)
return Vartype(m.abRegExp) == 'O' and ga_Type_IsChar(m.tcString, .T.) and m.abRegExp.test(m.tcString)
endfunc

* ===================================================================
function cRegExpTestedOK && {fr} Chaîne(s) filtrées par test OK sur un RegExp
lparameters ;
  tcStrings; && [''] {fr} Chaîne à tester
, tcPattern; && [''] {fr} Expression régulière de recherche
, tcFlags; && [''] {fr} commutateurs (igm)
, tlKO; && [.F.] {fr} test KO

local abRegExp as abRegExp of abTxt.prg, aa[1], nString, iString

abRegExp = abRegExp(m.tcPattern, m.tcFlags)
if  Vartype(m.abRegExp) == 'O' and ga_Type_IsChar(m.tcStrings, .T.)
	tlKO = lTrue(m.tlKO)
	nString = ALines(m.aa, m.tcStrings, 5, ',')
	for iString = m.nString to 1 step -1
		if m.abRegExp.test(m.aa[m.iString]) = m.tlKO
			nString = m.nString - 1
			Adel(m.aa, m.iString)
		endif
	endfor
	if m.nString > 0
		dimension m.aa[m.nString]
		tcStrings = cListOfArray(@m.aa)
	else
		tcStrings = ''
	endif
endif
return m.tcStrings
endfunc

* ----------------------
procedure cRegExpTestedOK_Test

local loTest as abUnitTest of abDev.prg
loTest = newobject('abUnitTest', 'abDev.prg')
loTest.Test('awrlr', 'awrlr, awtoto, awOLEpdfAcro', 'aw(\w{3}|olepdfxc|ole(?!pdf)\w+)\b', 'i')
return loTest.Result()

* ===================================================================
function cRegExpTestedKO && {fr} Chaîne(s) filtrées par test KO sur un RegExp
lparameters ;
  tcStrings; && [''] {fr} Chaîne à tester
, tcPattern; && [''] {fr} Expression régulière de recherche
, tcFlags; && [''] {fr} commutateurs (igm)

return cRegExpTestedOK(m.tcStrings, m.tcPattern, m.tcFlags, .T.)
endfunc

* ----------------------
procedure cRegExpTestedKO_Test

local loTest as abUnitTest of abDev.prg
loTest = newobject('abUnitTest', 'abDev.prg')
loTest.Test('awtoto,awOLEpdfAcro', 'awrlr, awtoto, awOLEpdfAcro', 'aw(\w{3}|olepdfxc|ole(?!pdf)\w+)\b', 'i')
return loTest.Result()

* ===================================================================
define class abRegExp as GA_LIGHTWEIGHT_CLASS && {fr} Expression régulière ; Implements VBScript.RegExp
* ===================================================================

&& {fr} RÉGLAGES - cf. this.init() / this.setup()
pattern = '' && {fr} Masque d'expression régulière
IgnoreCase = .f. && {fr} Ignorer la casse dans les comparaisons
Global = .f. && {fr} Trouver toutes les occurrences ou la première seulement
Multiline = .f. && {fr} Le texte comporte plusieurs lignes && ^ = iif(Multiline, line start, chain start) $ = iif(Multiline, line end, chain end)

&& {fr} RÉSULTATS
nMatches = 0 && {fr} Nombre de résultats
dimension Matches[1] && [index, match, submatches (collection), length]
&& .Matches[?, 1] = index
&& .Matches[?, 2] = match
&& .Matches[?, 3] = submatches (collection)
&& .Matches[?, 4] = length
&& .Matches[?, 5] = line number

PatternMatched = '' && {fr} si this.lPatterns, pattern qui satisfait this.Test()
nPattern = 0 && {fr} n° du Pattern courant, cf. this.Pattern_Assign()

&& {fr} INTERNES
protected;
	oRegExp; && {fr} AS VBScript.RegExp
, nSeconds; && {fr} au début de this.Execute(), Seconds(); à la fin, durée
, lPatterns; && {fr} Patterns multiples, cf. this.Pattern_Assign()
, aPattern[1]; && {fr} Patterns multiples, cf. this.Pattern_Assign()
, lDebug && {fr} Afficher le résultat de this.execute() à l'écran et dans la fenêtre Debug

* -----------------------------------------------------------------
protected procedure init
lparameters ;
  tlDebug; && [.F.] {fr} Afficher le résultat de .execute() à l'écran et dans la fenêtre Debug
, tcResult && @ [''] {fr} Résultat de l'instanciation

local loException as exception, llResult

try

	this.lDebug = lTrue(m.tlDebug)

	* {fr} Si l'objet RegExp peut être créé
	this.oRegExp = createobject("VBscript.RegExp")
	llResult = vartype(m.this.oRegExp) == 'O'
	if m.llResult

		this.IgnoreCase = m.this.IgnoreCase && {fr} cf. this.IgnoreCase_assign()
		this.global = m.this.global && {fr} cf. this.Global_assign()
		this.Multiline = m.this.Multiline && {fr} cf. this.Multiline_assign()
	endif
catch to loException
	tcResult = cException(m.loException)
endtry

return m.llResult && .F. > {fr} objet non créé

* -----------------------------------------------------------------
protected procedure destroy
return && 2016-09-29 thn -- no default
endproc

* -----------------------------------------------------------------
protected function cPatterns && {en} chainable patterns
lparameters ;
  tcFunction; && {fr} Fonction qui 'fabrique' les patterns ('.xx' pour une méthode de cet objet ou 'xx' pour une fonction libre)
, tcParms && {fr} Paramètres à passer à la fonction pour 'fabriquer' les Patterns

local lcResult;
, laParm[1];
, lcParm

lcResult = ''

if alines(laParm, m.tcParms) > 0 && {fr} cInLineCommentStripped(m.tcParms)

	tcFunction = alltrim(m.tcFunction)
	for each lcParm in laParm
		lcResult = m.lcResult + CRLF + evaluate(m.tcFunction + '(m.lcParm)')
	endfor
	lcResult = substr(m.lcResult, 3)
endif

return m.lcResult
endfunc

* -----------------------------------------------------------------
hidden procedure Pattern_Assign
lparameters tcPattern && [''] {fr} Expression régulière de recherche
tcPattern = iif(vartype(m.tcPattern) == 'C', m.tcPattern, '')

this.lPatterns = CR $ m.tcPattern

if m.this.lPatterns
	alines(m.this.aPattern, m.tcPattern) && {fr} cInLineCommentStripped(m.tcPattern)
else
	store m.tcPattern to this.pattern, this.oRegExp.pattern
endif

* -----------------------------------------------------------------
hidden procedure IgnoreCase_Assign
lparameters tlIgnoreCase && [.F.] {fr} Ignorer la casse dans les comparaisons

if vartype(m.tlIgnoreCase) == 'L'
	store m.tlIgnoreCase to this.IgnoreCase, this.oRegExp.IgnoreCase
else
	this.tag = Cast(m.tlIgnoreCase as M)
endif

* -----------------------------------------------------------------
hidden procedure Global_Assign
lparameters tlGlobal && [.F.] {fr} Trouver toutes les occurrences ou la première seulement

if vartype(m.tlGlobal) == 'L'
	store m.tlGlobal to this.global, this.oRegExp.global
else
	this.tag = Cast(m.tlGlobal as M)
endif

* -----------------------------------------------------------------
hidden procedure Multiline_Assign
lparameters tlMultiline && [.F.] {fr} Le texte comporte plusieurs lignes

if vartype(m.tlMultiline) == 'L'
	store m.tlMultiline to this.Multiline, this.oRegExp.Multiline
else
	this.tag = Cast(m.tlMultiline as M)
endif

* -----------------------------------------------------------------
procedure clear && {fr} Efface les résultats de recherche précédents

this.nMatches = 0 && {fr} Nombre de résultats
dimension this.Matches[1]
this.Matches[1] = .f.
this.PatternMatched = ''

* -----------------------------------------------------------------
procedure setup && {fr} Règle les options de recherche
lparameters ;
  tcPattern; && [''] {fr} Expression régulière de recherche
, tuIgnoreCase; && [.null.] {fr} Ignorer la casse dans les comparaisons
, tlGlobal; && [.null.] {fr} Trouver toutes les occurrences ou la première seulement
, tlMultiline; && [.null.] {fr} Le texte comporte plusieurs lignes

local lnParms
lnParms = Pcount()

if Empty(m.lnParms) or !ga_Type_IsChar(m.tcPattern)
	return .f.
else
	this.pattern = m.tcPattern
	do case
	case m.lnParms = 1
*		store .F. to this.IgnoreCase, this.global, this.Multiline && 2018-03-14 thn -- {en} keep unchanged
	case ga_Type_IsChar(m.tuIgnoreCase); && JavaScript style
	 and varSet(@m.tuIgnoreCase, Alltrim(Lower(m.tuIgnoreCase)));
	 and Lenc(Chrtran(m.tuIgnoreCase, ' ', '')) <= 3;
	 and Empty(Chrtran(m.tuIgnoreCase, 'gmi', ''));
	 and .T.
		this.IgnoreCase = 'i' $ m.tuIgnoreCase
		this.global = 'g' $ m.tuIgnoreCase
		this.Multiline = 'm' $ m.tuIgnoreCase
	otherwise
		this.IgnoreCase = m.tuIgnoreCase
		this.global = m.tlGlobal
		this.Multiline = m.tlMultiline
	endcase
endif
endproc

* -----------------------------------------------------------------
procedure Test && {fr} Teste l'expression de recherche
lparameters tcIn && {fr} Chaîne oû chercher

local llResult

with m.this as abRegExp of abTxt.prg
	.clear

	if .lPatterns
		for .nPattern = 1 to alen(.aPattern) && {fr} FOR EACH .Pattern IN .aPattern produit une erreur 1903 ('String is too long to fit')
			if .setup(.aPattern[.nPattern]) and .oRegExp.Test(m.tcIn)
				.PatternMatched = .aPattern[.nPattern]
				llResult = .t.
				* ====
				exit
				* ====
			endif
		endfor
		.lPatterns = .t. && {fr} pour reuse, .Pattern = le remet à .F.
	else
		llResult = .oRegExp.Test(m.tcIn)
	endif
endwith

return m.llResult

* -----------------------------------------------------------------
procedure Execute && {fr} Tabule les occurrences dans this.matches[]
lparameters ;
  tcIn; && {fr} Chaîne oû chercher
, tlDebug && [.F.] {fr} Débuguer
tlDebug = lTrue(m.tlDebug)

local lnResult

with m.this as abRegExp of abTxt.prg

	.nPattern = 0
	.clear

	lnResult = iif(.lPatterns; && /!\ ne marche pas avec HIDDEN .lPatterns !
		, .Execute_Patterns(@m.tcIn, m.tlDebug); && {fr} plusieurs patterns (exécution récursive)
		, .Execute_Pattern(@m.tcIn, m.tlDebug); && {fr} un seul pattern (cas général)
		)

endwith

return m.lnResult
endproc

* -----------------------------------------------------------------
protected procedure Execute_Patterns && {fr} Exécute des patterns multiples
lparameters ;
  tcIn; && {fr} Chaîne oû chercher
, tlDebug && [.F.] {fr} Débuguer

local lnPattern, laMatches[1], laResult[1], lnResult

lnResult = 0
for .nPattern = 1 to alen(.aPattern) && {fr} FOR EACH .Pattern IN .aPattern produit une erreur 1903 ('String is too long to fit')

	.pattern = .aPattern[.nPattern] && {fr} see this.Pattern_assign()

	* {fr} Si des occurrences sont trouvées
	if .Execute_Pattern(@m.tcIn, m.tlDebug) > 0

		lnResult = m.lnResult + .nMatches

		* {fr} Ajouter les occurrences au résultat final
		dimension laMatches[Alen(.Matches, 1), Alen(.Matches, 2)]
		acopy(.Matches, laMatches)
		aAppend(@m.laResult, @m.laMatches)
	endif
endfor

if lnResult > 0
	asort(laResult, 1) && {fr} dans l'ordre des positions
	dimension .Matches[m.lnResult, Alen(laResult, 2)]
	acopy(laResult, .Matches)
endif

.nMatches = lnResult
.lPatterns = .t. && {fr} pour reuse, .Pattern = le remet à .F.

return m.lnResult
endproc

* -----------------------------------------------------------------
protected procedure Execute_Pattern && {fr} Exécute un pattern unique
lparameters ;
  tcIn; && {fr} Chaîne oû chercher
, tlDebug as Boolean && [.F.] {fr} Débuguer

tlDebug = Vartype(m.tlDebug) == 'L' and m.tlDebug or m.this.lDebug

.nSeconds = seconds()
.nMatches = 0 && {fr} Nombre de Résultats

if not empty(.pattern)

	local loResults, loResult;
	, llSubMatches, loSubMatches as collection;
	, lcSubMatch;
	, lcHead

	loResults = .oRegExp.Execute(@m.tcIn)
	if Vartype(m.loResults) == 'O' and m.loResults.count > 0

		dimension .Matches[m.loResults.Count, 5] && [1- index, 2- valeur, 3-submatches, 4-length, 5-line number] && 2016-11-16 thn -- {en} added 5-line number
		for each loResult in m.loResults && {fr} GA ne met pas la clause 'foxobject'

			* {fr} Objectifier les sub-matches en base 1 (VFP)
			llSubMatches = ga_Collection_Object(@m.loSubMatches)
			assert m.llSubMatches
			if m.llSubMatches
				for each lcSubMatch in loResult.SubMatches
					loSubMatches.add(m.lcSubMatch)
				endfor
			endif

			* {fr} Tabuler les résultats
			.nMatches = .nMatches + 1
			.Matches[.nMatches, 1] = m.loResult.firstIndex + 1 && {fr} fox strings are 1-based
			.Matches[.nMatches, 2] = m.loResult.value
			.Matches[.nMatches, 3] = m.loSubMatches
			.Matches[.nMatches, 4] = m.loResult.length
				lcHead = Leftc(m.tcIn, .Matches[.nMatches, 1])
			.Matches[.nMatches, 5] = Max(Occurs(CR, m.lcHead), Occurs(LF, m.lcHead)) + 1
		endfor
	endif
endif

= m.tlDebug and .Execute_Debug(@m.tcIn)

return .nMatches
endproc

* -----------------------------------------------------------------
protected procedure Execute_Debug && {fr} Affiche le déboguage de l'exécution courante
lparameters tcIn && {fr} Chaîne oû chercher

local junk;
, lcPlural;
, lcSecond;
, lnMatch;
, lnSubMatches;
, lnSubMatch;
, lcResult

activate screen
if .nPattern = 1
	clear
endif

lcPlural = iif(.nMatches > 1, 's', '')
lcSecond = textmerge([<<.nMatches>> occurrence<<m.lcPlural>> trouvée<<m.lcPlural>> en <<Seconds() - .nSeconds)>> secondes])

text TO lcResult TEXTMERGE NOSHOW FLAGS 1
* <<Replicate('=', 40)>>
<<Ttoc(Datetime(),2)>> - <<c2Words(.Tag, ', ', 'PATTERN')>> <<Iif(.nPattern > 0, '#' + Transform(.nPattern), '')>> (<<Lenc(.Pattern)>> cars) :
<<.Pattern>>
IgnoreCase: <<cOUINON(.IgnoreCase)>>, Global: <<cOUINON(.Global)>>, MultiLine: <<cOUINON(.MultiLine)>>
TEXTE (<<Ltrim(Transform(Lenc(m.tcIn), '99 999 999'))>> cars) :
<<cLitteral(cTronc(m.tcIn, 100, .T.))>>
<<m.lcSecond>>
ENDTEXT

if .nMatches > 0;
	and (.nMatches < 15;
		 or messagebox(textmerge([<<.nMatches>> résultats, détailler ?]), 4, program(), 2000) # 7)

	for lnMatch = 1 to .nMatches

		text TO lcResult TEXTMERGE NOSHOW FLAGS 1
<<m.lcResult>>

--- occurrence <<m.lnMatch>>/<<.nMatches>> - position <<.matches[m.lnMatch, 1])>> - longueur <<.matches[m.lnMatch, 4])>> cars - ligne <<.matches[m.lnMatch, 5])>>
<<Strtran(cTronc(cLitteral(.matches[m.lnMatch, 2]), 200, .T.), Chr(13) + Chr(10), Chr(182) + Chr(13) + Chr(10))>>
		ENDTEXT

		lnSubMatches = .Matches[m.lnMatch, 3].count
		if m.lnSubMatches > 0
			for lnSubMatch = 1 to m.lnSubMatches
				lcResult = m.lcResult;
				 + CRLF;
				 + '>> '; && {fr} ne passe pas dans Textmerge()
				 + textmerge("subMatch: <<m.lnSubMatch>>/<<m.lnSubMatches>> <<Strtran(cTronc(cLitteral(.matches[m.lnMatch, 3].Item(m.lnSubMatch)), 200, .T.), Chr(13) + Chr(10), Chr(182) + Chr(13) + Chr(10))>>")
			endfor
		endif
	endfor
endif
text TO lcResult TEXTMERGE NOSHOW FLAGS 1
<<m.lcResult>>
* <<Replicate('=', 40)>>
<<m.lcSecond>>
ENDTEXT

this.DebugDisplay(m.lcResult)

* -----------------------------------------------------------------
procedure replace && {fr} Remplace
lparameters ;
  tcIn; && {fr} Chaîne oû chercher
, tcTo && [''] {fr} Chaîne remplaçante

tcTo = iif(vartype(m.tcTo) == 'C', m.tcTo, '')

with m.this as abRegExp of abTxt.prg

	if .lPatterns

		local lcResult

		lcResult = m.tcIn
		for .nPattern = 1 to alen(.aPattern) && {fr} FOR EACH .Pattern IN .aPattern produit une erreur 1903 ('String is too long to fit')
			if .setup(.aPattern[.nPattern])
				lcResult = .replace(m.lcResult, m.tcTo)
			endif
		endfor

		.lPatterns = .t. && {fr} pour reuse, .Pattern = le remet à .F.
		return m.lcResult

	else
		return .oRegExp.replace(m.tcIn, m.tcTo)
	endif
endwith

* -----------------------------------------------------------------
procedure DebugDisplay && {fr} En mode déboguage, affiche un résultat à l'écran et dans la fenêtre de debug
lparameters tcDebug

tcDebug = CRLF + evl(m.tcDebug, '')

? m.tcDebug
debugout m.tcDebug
endproc

* ===================================================================
enddefine && {fr} CLASS abRegExp
* ===================================================================

* ===================================================================
function cCRto && {fr} chaîne oû les sauts de ligne sont remplacés par ...
lparameters ;
  tcChain; && {fr} Chaîne
, tcReplace && [' '] {fr} Chaîne remplaçant les sauts de ligne

tcReplace = Iif(ga_Type_IsChar(m.tcReplace), m.tcReplace, ' ')

return strtran(strtran(strtran(strtran(m.tcChain;
	, CRLF, m.tcReplace); && modify file abTxt.h
	, LFCR, m.tcReplace); && modify file abTxt.h
	, CR, m.tcReplace); && modify file abTxt.h
	, LF, m.tcReplace) && modify file abTxt.h
endfunc

* ===================================================================
function cCR2to && {fr} chaîne oû les sauts de ligne doubles sont remplacés par ...
lparameters ;
  tcChain; && {fr} Chaîne
, tcReplace && {fr} Chaîne remplaçant les sauts de ligne

return strtran(strtran(strtran(strtran(m.tcChain;
	, CRLF2, m.tcReplace); && modify file abTxt.h
	, LFCR2, m.tcReplace); && modify file abTxt.h
	, CR2, m.tcReplace); && modify file abTxt.h
	, LF2, m.tcReplace) && modify file abTxt.h
endfunc

* ===================================================================
function cCRDel && {fr} chaîne oû les sauts de ligne sont supprimés
lparameters tcChain && {fr} Chaîne
return cCRto(m.tcChain, '')

* ===================================================================
function cCRSpace && {fr} chaîne oû les sauts de ligne sont remplacés par un Space(1)
lparameters tcChain && {fr} Chaîne
return cCRto(m.tcChain, space(1))

* ===================================================================
function cOuiNon(tl) && {fr} oui ou non selon une condition logique
return iif(vartype(m.tl) $ 'LX', iif(m.tl, 'OUI', 'NON'), m.tl) && .NULL. <> .F.
endfunc

* ===================================================================
function cOKKO(tl) && {fr} OK ou KO selon une condition logique
return iif(vartype(m.tl) $ 'LX', iif(m.tl, 'OK', 'KO'), m.tl) && .NULL. <> .F.
endfunc

* ===================================================================
function cYesNo(tl) && {fr} yes ou no selon une condition logique
return iif(vartype(m.tl) $ 'LX', iif(m.tl, 'Yes', 'No'), m.tl) && .NULL. <> .F.
endfunc

* ===================================================================
function cYes(tl) && {fr} yes ou vide selon une condition logique
return iif(vartype(m.tl) $ 'LX', iif(m.tl, 'Yes', ''), m.tl) && .NULL. <> .F.
endfunc

* ===================================================================
function cFirstProper && {fr} Chaîne calée à gauche avec son premier caractère en majuscule
lparameters tcChain && {fr} Chaîne à traiter

local lcResult
lcResult = ''

if vartype(m.tcChain) == 'C'
	lcResult = lower(ltrim(m.tcChain))
	lcResult = upper(left(m.lcResult, 1)) + substr(m.lcResult, 2)
endif

return m.lcResult
endfunc

* ===================================================================
function cEscaped && {fr} Chaîne compatible HTTP / XML
lparameters tcChain

return iif(vartype(m.tcChain) == 'C';
	, cEscaped_Misc(cEscaped_Punc(cEscaped_XML(m.tcChain)));
	, '';
	)
endfunc

* ===================================================================
function cEscaped_Base(tcChain) && {fr} Encode les entités ignorées par le parser XML (&<>) && {fr} Alias de cEscaped_XML()
return cEscaped_XML(m.tcChain)
endfunc

* ===================================================================
function cEscaped_XML(tcChain) && {fr} Encode les entités ignorées par le parser XML (&<>)
return strtran(strtran(strtran(strtran(strtran(strtran(chrtran(m.tcChain; && http://www.w3.org/TR/2008/REC-xml-20081126/#charsets Char ::=  #x9 | #xA | #xD | [#x20-#xD7FF] | [#xE000-#xFFFD] | [#x10000-#x10FFFF]
	, NON_XML, ''); && modify file abTxt.h
	, [&], '&#38;'); && '&amp;'
	, [<], '&#60;'); && '&lt;'
	, [>], '&#62;'); && '&gt;'
	, [&#38;#38;], '&#38;'); && {en} encoded twice
	, [&#38;#60;], '&#60;'); && {en} encoded twice
	, [&#38;#62;], '&#62;'); && {en} encoded twice

&& 2018-05-24 thn -- {en} should work but no
*!*	return strtran(strtran(strtran(strtran(strtran(chrtran(m.tcChain; && http://www.w3.org/TR/2008/REC-xml-20081126/#charsets Char ::=  #x9 | #xA | #xD | [#x20-#xD7FF] | [#xE000-#xFFFD] | [#x10000-#x10FFFF]
*!*		, NON_XML, ''); && modify file abTxt.h
*!*		, [&#], '~#~#~#~#');
*!*		, [&], '&#38;'); && '&amp;'
*!*		, [<], '&#60;'); && '&lt;'
*!*		, [>], '&#62;'); && '&gt;'
*!*		, '~#~#~#~#', [&#]);
*!*		, [&#38;#], '&#'); && {en} encoded twice

endfunc

&& 		, '> <', '><')

* ===================================================================
function cEscaped_Punc(tcChain) && {fr} Encode les entités de ponctuation
return cEscaped_Spac(strtran(strtran(m.tcChain;
	, ["], '&#34;'); && '&quot;' && /!\ pb avec absiteLoc
	, ['], '&#39;'); && '&apos;' && /!\ pb avec absiteLoc
	)
endfunc

* ===================================================================
function cEscaped_Spac(tcChain) && {fr} Encode les entités d'espacement
return strtran(strtran(strtran(strtran(m.tcChain;
	, POINTSUSP, replicate('.', 3)); && &hellip; ne semble pas supportée
	, chr(150), '&#8211;'); && '&ndash;'
	, chr(151), '&#8212;'); && '&mdash;'
	, chr(160), '&#160;'); && '&nbsp;'

endfunc

* ===================================================================
function cEscaped_Misc(tcChain) && {fr} Encode les entités diverses (€,™ etc.)
return strtran(strtran(strtran(m.tcChain;
	, chr(128), '&#8364;'); && '&euro;'
	, chr(153), '&#8482;'); && '&trade;'
	, chr(156), '&#339;'); && '&oelig;'

endfunc

* ===================================================================
function cUnescaped && {fr} Inverse de cEscaped()
lparameters tcChain

return iif(vartype(m.tcChain) == 'C';
	, strtran(strtran(strtran(strtran(strtran(strtran(strtran(strtran(strtran(cUnescaped_Base(m.tcChain);
	  , '&#34;', ["]);
	  , '&#39;', [']);
	  , '&#8211;', chr(150));
	  , '&#8212;', chr(151));
	  , '&#160;',  chr(160));
	  , '&#8364;', chr(128));
	  , '&#8482;', chr(153));
	  , '&#339;',  chr(156));
	  , '&#8209;', '-'); && non-breaking hyphen -- not supported by ASCII
	, m.tcChain;
	)

* ===================================================================
function cUnescaped_XML(tcChain) && {fr} Inverse de cEscaped_XML()
return cUnescaped_Base(tcChain)

* ===================================================================
function cUnescaped_Base(tcChain) && {fr} Inverse de cEscaped_Base()
return iif(vartype(m.tcChain) == 'C';
	, strtran(strtran(strtran(m.tcChain;
	  , '&#38;', [&]);
	  , '&#60;', [<]);
	  , '&#62;', [>]);
	, m.tcChain;
	)

* -------------------------------------------------------------
define class test1 as custom
	add object Matches as collection
	procedure init
	this.Matches.add(createobject('test2'))
enddefine

define class test2 as custom
	Position = 0
enddefine

* ===================================================================
function cy && {fr} Montant en caractères dans une devise
lparameters ;
  ty; && {fr} Montant
, tcCurrency; && ['USD'] {fr} code devise selon norme ISO 4217 http://www.xe.com/iso4217.php

tcCurrency = evl(m.tcCurrency, 'USD')

local loCurrency1 as abSet of abDev.prg;
, loCurrency2 as abSet of abDev.prg

loCurrency1 = abSet('Currency', icase(;
	M.tcCurrency == 'EUR', ' Â€',; && Copy-paste this line to add another currency support
		'$';
	),,,.t.)

loCurrency2 = abSet('Currency', icase(;
	M.tcCurrency == 'EUR', 'RIGHT',; && Copy-paste this line to add another currency support
		'LEFT';
	),,,.t.)

return transform(cast(m.ty as y))

* -------------------------------
function lBotSpider && {fr} Une requête émane d'une araignée d'un moteur de recherche
lparameters tcUA && [m.Request.getBrowser()] {fr} User Agent de la requête HTTP

tcUA = iif(empty(m.tcUA) and vartype(m.Request) == 'O';
	, m.Request.getBrowser();
	, m.tcUA;
	)
if vartype(m.tcUA) == 'C' and !empty(m.tcUA)

	tcUA = lower(m.tcUA)

	return .f.; && {fr} pour placer facilement les plus fréquents en tête && {fr} http://www.botsVSbrowsers.com/
	or 'googlebot' $ m.tcUA;
	or 'west wind' $ m.tcUA; && {fr} West Wind Internet Protocols x,xx
	or '/slurp' $ m.tcUA; && "Mozilla/5.0 (compatible; Yahoo! Slurp; http://help.yahoo.com/help/us/ysearch/slurp)" - https://help.yahoo.com/kb/search/SLN22600.html?impressions=true
	or '/bot' $ m.tcUA;
	or 'bot/' $ m.tcUA;
	or ' bot ' $ m.tcUA;
	or 'adsbot' $ m.tcUA; && {fr} AdsBot-Google (+http://www.google.com/adsbot.html) 15/6/15
	or 'zgrab' $ m.tcUA; && 2015-12-31 16:14:19 thn -- {en} https://en.wikipedia.org/wiki/Banner_grabbing Banner grabbing is a technique used to glean information about a computer system on a network and the services running on its open ports. Administrators can use this to take inventory of the systems and services on their network. However, an intruder can use banner grabbing in order to find network hosts that are running versions of applications and operating systems with known exploits.
	or 'crawl' $ m.tcUA;
	or 'clients.your-server.de' $ m.tcUA;
	or 'spider' $ m.tcUA;
	or 'robot' $ m.tcUA;
	or 'yahoo!+slurp' $ m.tcUA;
	or 'msnbot' $ m.tcUA;
	or 'bingbot' $ m.tcUA;
	or 'exabot' $ m.tcUA;
	or 'voilabot' $ m.tcUA;
	or 'alexa.com' $ m.tcUA;
	or 'ccbot' $ m.tcUA;
	or 'catchbot' $ m.tcUA;
	or 'proximic' $ m.tcUA;
	or 'jooblebot' $ m.tcUA;
	or 'linkedinbot' $ m.tcUA;
	or 'surveybot' $ m.tcUA;
	or 'careerbot' $ m.tcUA;
	or 'comspybot' $ m.tcUA;
	or 'ezooms.bot' $ m.tcUA;
	or 'komodiabot' $ m.tcUA;
	or 'paperlibot' $ m.tcUA;
	or 'facebookexternalhit' $ m.tcUA;
	or 'procogseobot' $ m.tcUA; && {fr} ProCogSEOBot
	or 'coccoc' $ m.tcUA; && {fr} Mozilla/5.0 (compatible; coccoc/1.0; +http://help.coccoc.com/) && {fr} Coccoc bot is a web crawling bot made by Coc Coc search engine. The bot will discover new and updated pages to be added to Coc Coc search engine index. By allowing Coccoc Bot to index your website, the number of users who are able to find your content will increase and make your site more popular on the search engine. Coccoc bot supports robot exclusion standard (robots.txt)
	or 'linkchecker' $ m.tcUA; && {fr} LinkChecker/7.4 (+http://linkchecker.sourceforge.net/)
	or 'replazbot' $ m.tcUA; && {fr} ReplazBot
	or 'semrushbot' $ m.tcUA; && {fr} SemrushBot
	or 'tweetedtimes bot' $ m.tcUA; && {fr} TweetedTimes Bot
	or 'tweetmemebot' $ m.tcUA; && {fr} TweetmemeBot
	or 'urlappendbot' $ m.tcUA; && {fr} URLAppendBot
	or 'wasalive-bot' $ m.tcUA; && {fr} WASALive-Bot
	or 'yodaobot' $ m.tcUA; && {fr} YodaoBot
	or 'aihitbot' $ m.tcUA; && {fr} aiHitBot
	or 'discoverybot' $ m.tcUA; && {fr} discoverybot
	or 'ltbot' $ m.tcUA; && {fr} ltbot
	or 'news bot' $ m.tcUA; && {fr} news bot
	or 'ncbot' $ m.tcUA; && {fr} NCBot (http://netcomber.com : tool for finding true domain owners) Queries/complaints: bot@netcomber.com
	or 'seznambot' $ m.tcUA; && {fr} SeznamBot/3.0 (+http://fulltext.sblog.cz/)
	or 'twitterbot' $ m.tcUA; && {fr} Twitterbot
	or 'wotbox' $ m.tcUA; && {fr} Wotbox/2.01 (+http://www.wotbox.com/bot/) nrsbot
	or 'nrsbot' $ m.tcUA; && {fr} nrsbot
	or 'yandex.com' $ m.tcUA;
	or 'python-urllib' $ m.tcUA;
	or 'synomia' $ m.tcUA;
	or 'gigabot' $ m.tcUA;
	or 'ocelli' $ m.tcUA;
	or 'dcbot.html' $ m.tcUA;
	or 'pompos.html' $ m.tcUA;
	or 'aipbot.com' $ m.tcUA;
	or 'shopwiki.com' $ m.tcUA;
	or 'ia_archiver' $ m.tcUA;
	or 'bingbot' $ m.tcUA;
	or 'mj12bot' $ m.tcUA;
	or 'openisearch' $ m.tcUA;
	or 'seekbot' $ m.tcUA;
	or 'jyxobot' $ m.tcUA;
	or 'biglotron' $ m.tcUA;
	or 'psbot' $ m.tcUA;
	or 'dumbot' $ m.tcUA;
	or 'clicksense' $ m.tcUA;
	or 'sondeur' $ m.tcUA;
	or 'naverbot' $ m.tcUA;
	or 'spyder+' $ m.tcUA;
	or 'convera' $ m.tcUA;
	or 'misesajour' $ m.tcUA;
	or 'updated' $ m.tcUA;
	or 'infoseek' $ m.tcUA;
	or 'envolk' $ m.tcUA;
	or 'twiceler' $ m.tcUA;
	or 'snap.com' $ m.tcUA;
	or 'netresearchserver' $ m.tcUA;
	or 'gaisbot' $ m.tcUA;
	or 'antibot' $ m.tcUA;
	or 'lexxebot' $ m.tcUA;
	or 'ask+jeeves' $ m.tcUA;
	or 'dotbot' $ m.tcUA;
	or 'chainn.com' $ m.tcUA;
	or 'seoprofiler.com' $ m.tcUA;
	or 'sbider' $ m.tcUA;
	or 'soso.com' $ m.tcUA;
	or 'antibot' $ m.tcUA;
	or 'siteexplorer' $ m.tcUA;
	or 'compspybot' $ m.tcUA;
	or 'meanpathbot' $ m.tcUA;
	or 'lipperhey' $ m.tcUA;
	or .f. && {fr} pour placer facilement les plus fréquents en tête

endif

* -------------------------------
function cChr && {fr} chaine en chr()
lparameters tc, tlHexa

local liResult, lcFormat, lcResult

lcResult = ''
if vartype(m.tc) == 'C' and len(m.tc) > 0
	lcFormat = iif(lTrue(m.tlHexa);
	  , '@0'; && {fr} hexadécimal
	  , '@L 999'; && 3 chiffres décimaux
		)
	for liResult = 1 to lenc(m.tc)
		lcResult = m.lcResult;
			+ [ + Chr(];
			+ transform(asc(substr(m.tc, m.liResult, 1)), m.lcFormat);
			+ [)]
	endfor
	lcResult = substr(m.lcResult, len([ + ]) + 1)
endif

return m.lcResult

* -------------------------------
function ParmsLit && {fr} paramètres en littéral
lparameters result; && @ {fr} paramètres en littéral
,t01,t02,t03,t04,t05,t06,t07,t08,t09,t10,t11,t12,t13,t14,t15,t16,t17,t18,t19,t20

result = ''
if pcount() > 1
	local I
	for I = 1 to pcount()-1
		result = m.result + ', ' + cLitteral(evaluate('m.t' + padl(m.I, 2, '0')))
	endfor
	result = substr(m.result, 3)
endif

*----------------------------------------------------
function cCRLF2fix && {fr} Chaîne où toutes les lignes se terminent par CRLF simple
lparameters tcChain

tcChain = cCRLFfix(m.tcChain)
do while CRLF2 $ m.tcChain
	tcChain = strtran(m.tcChain, CRLF2, CRLF)
enddo
do while CR2 $ m.tcChain
	tcChain = strtran(m.tcChain, CR2, CR)
enddo

return m.tcChain

*----------------------------------------------------
function cCRLFfix && {fr} Chaîne oû toutes les lignes se terminent par CRLF
lparameters tcChain, lKeepHeadingSpaces

tcChain = iif(vartype(m.tcChain) == 'C';
	, cCRLFfix_(cCRLFfix_(cCRLFfix_(cCRLFfix_(cCRLFfix_(cCRLFfix_(m.tcChain;
	  , TABUL + CRLF);
	  , TABUL + CR);
	  , TABUL + LF);
	  , ' ' + CRLF);
	  , ' ' + CR);
	  , ' ' + LF);
	, m.tcChain;
	)

tcChain = iif(vartype(m.tcChain) == 'C' and !m.lKeepHeadingSpaces;
	, cCRLFfix_(cCRLFfix_(cCRLFfix_(cCRLFfix_(cCRLFfix_(cCRLFfix_(m.tcChain;
	  , CRLF + TABUL);
	  , CR + TABUL);
	  , LF + TABUL);
	  , CRLF + ' ');
	  , CR + ' ');
	  , LF + ' ');
	, m.tcChain;
	)

return m.tcChain
endfunc

*----------------------------------------------------
function cCRLFfix_ && {fr} [privée de cCRLFfix()]
lparameters tcChain, tcNewLine

do while m.tcNewLine $ m.tcChain
	tcChain = iif(' ' $ m.tcNewLine;
	  , strtran(m.tcChain, m.tcNewLine, alltrim(m.tcNewLine));
	  , strtran(m.tcChain, m.tcNewLine, CRLF);
		)
enddo

return m.tcChain
endfunc

*----------------------------------------------------
function addFS && {en} adds a forward Slash if none
lparameters tcChain
tcChain = trim(Evl(m.tcChain, ''), ' ', '/')
return nEvl(m.tcChain, m.tcChain + '/')
endfunc

*----------------------------------------------------
function alltrim_ && {en} alltrim() including CR, LF and TABUL
lparameters tcChain
return Alltrim(Alltrim(m.tcChain), CR, LF, TABUL)
endfunc

*----------------------------------------------------
function cStringsMasked && {fr} Chaîne oû les litteraux caractères sont masqués par _ga_StringParseBits_Class_.maskStrings()
lparameters ;
  tcChain;
, result; && @ {en} in: .T. for JavaScript string, @out: .T. if success, else ga_StringParse_Object() instantiation result

local loParser, cResult

return iif(.t.;
		and ga_Type_IsChar(m.tcChain, .t.);
		and (.f.;
			or ga_StringParse_Object(@m.loParser); && modify command abGA
			or cResultAdd(@m.result, GA_STRINGPARSE_CLASS + [ class instantiation failed!]);
			);
		and (!lTrue(m.result) or varSet(@m.tcChain, strtran(strtran(m.tcChain, '\"'), "\'")));
		and varSet(@m.result, m.loParser.maskStrings(@m.cResult, m.tcChain)); && modify command abGA
		and m.result;
	, m.cResult;
	, m.tcChain;
	)
endfunc

* -----------------------------------------------------------------
procedure cStringsMasked_Test && {fr} cStringsMasked() unit test && 1.5 ms dev

local loTest as abUnitTest of abDev.prg
loTest = newobject('abUnitTest', 'abDev.prg')

loTest.Test([Evl(m.test, ~~~~~~~~~~~~~~~~)], [Evl(m.test, "this is a test")]) && _cliptext = Replicate('~', Len('"this is a test"'))

return loTest.result()

* =================================
function chunked && {en} chunked strings separated with CR LF
lparameters ;
  raw; && {en} raw text
, chunkLen && [76]

chunkLen = evl(m.chunkLen, 76)

local chunked, iChunk, chunk

chunked = ''
iChunk = 1
do while .t.
	chunk = substr(m.raw, m.iChunk, m.chunkLen)
	if empty(m.chunk)
		exit
	else
		chunked = m.chunked + m.chunk + CRLF
		iChunk = m.iChunk + m.chunkLen
	endif
enddo

return trim(m.chunked, CR, LF)
endfunc

* =================================
function abLocalized && {en} text where localized comments are removed except those in the user's language {fr} texte oû le mentions localisées sont retirées sauf celles dans la langue de l'utilisateur
lparameters ;
  cTxt; && {en} Text to localize (source code in general) {fr} Texte à localiser (code source en général)
, cLangUser; && [cLangUser()] {en} user's preferred language as ISO 639-1 code {fr} langue préférée de l'utilisateur selon code ISO 639-1
, cCommentStrings; && ['*|&&|note'] {en} strings beginning a comment line in code source {fr} chaîne de caractère commençant une ligne de commentaires dans le code source
, tlCRLFend; && [.F.] {en} always end by CRLF {fr} terminer par CRLF

cLangUser = evl(evl(m.cLangUser, cLangUser()), 'en')
cLangUser = lower(left(alltrim(m.cLangUser), 2))
cLangUser = iif('{' + m.cLangUser + '}' $ m.cTxt, m.cLangUser, 'en')

with newobject('abRegExp', 'abTxt.prg') as abRegExp of abTxt.prg

	.setup(abLocalized_cPattern1(m.cLangUser), 'gmi')
	cTxt = .replace(m.cTxt, ' ') && {fr} supprime les mentions des autres langues

	cLangUser = '{' + m.cLangUser + '}'
	cTxt = strtran(strtran(m.cTxt, m.cLangUser + ' '), m.cLangUser) && {fr} supprime les balises de la langue demandée

	.setup(abLocalized_cPattern2(m.cCommentStrings), 'gmi')
	cTxt = .replace(m.cTxt) && {fr} supprime les lignes de commentaire vides
endwith

do while replicate(CRLF, 3) $ m.cTxt
	cTxt = strtran(m.cTxt, replicate(CRLF, 3), replicate(CRLF, 2))
enddo

return m.cTxt + Iif(lTrue(m.tlCRLFend) and Trim(m.cTxt, CR, LF) # m.cTxt, CRLF, '')
endfunc

* --------------------------
function abLocalized_cPattern1 && {en} localized string {fr} chaîne localisée
lparameters cLangUser && [cLangUser()] {en} user's preferred language as ISO 639-1 code {fr} langue préférée de l'utilisateur selon code ISO 639-1

&& modify command c:\test\test\regexp_clanguser.prg

&& {fr} '{' non suivi de la langue de l'utilisateur
&& {fr} puis 2 caractères alphabétiques
&& {fr} puis '}'
&& {fr} puis toute suite de caractères suivie de : '{\w\w}' ou '<' ou la fin de ligne

return '\s*{(?!' + m.cLangUser + ')\w\w}[^\u002A\r\n]+?(?=(?:{\w\w})|<|\u002A|$)' && \n\r && [ \f\t\u00a0\u2028\u2029]
endfunc

* --------------------------
function abLocalized_cPattern2 && {en} empty comment lines {fr} lignes de commentaire vide
lparameters cCommentStrings && ['*|&&|note'] {en} strings beginning a comment line in code source {fr} chaîne de caractère commençant une ligne de commentaires dans le code source
return '^\s*?(?:' + strtran(strtran(evl(m.cCommentStrings, '*|&'+'&|note'), '*', '\u002A'), '/', '\/') + ')\s*?$\r?\n?' && [ \f\t\u00a0\u2028\u2029]
endfunc

* --------------------------
procedure abLocalized_Test && {fr} abLocalized() unit test

local loTest as abUnitTest of abDev.prg, lcTest, lcExpected
loTest = newobject('abUnitTest', 'abDev.prg')

_cliptext = ''

* {fr} test 1 ----
text to lcTest noshow
&& {en} FoxInCloud Adaptation Assistant (FAA) step 3-Publish created this program
&& {fr} L'étape 3 (Publier) de l'Assistant d'Adaptation FoxInCloud (FAA) a créé ce programme

ENDTEXT

text to lcExpected noshow
&& L'étape 3 (Publier) de l'Assistant d'Adaptation FoxInCloud (FAA) a créé ce programme

ENDTEXT

m.loTest.Test(m.lcExpected, m.lcTest, 'fr')

* {fr} test 2 ----
text to lcTest noshow
functtion sourceCodeWindow() { /* {en} displays source code from current HTML element into a child window {fr} affiche le HTML de l'élément courant dans une fenêtre fille */
	// {en} displays source code from current HTML element into a child window {fr} affiche le HTML de l'élément courant dans une fenêtre fille
ENDTEXT

text to lcExpected noshow
functtion sourceCodeWindow() { /* displays source code from current HTML element into a child window */
	// displays source code from current HTML element into a child window
ENDTEXT

m.loTest.Test(m.lcExpected, m.lcTest, 'en', '//')

* {fr} test 3 ----
text to lcTest noshow
IF m.THISFORM.wlHTMLgen && {en} FoxInCloud Automated Adaptation {fr} Adaptation Automatique FoxInCloud
	RETURN .T. && {en} Execute this VFP event code on FoxInCloud server {fr} Traiter l'événement sur le serveur
ENDIF
Rand(-1)
this.Parent.SetAll('Value', '', 'ficTxt') && {en} clear textboxes
this.Parent.Refresh && {en} refresh child lists
ENDTEXT

text to lcExpected noshow
IF m.THISFORM.wlHTMLgen && Adaptation Automatique FoxInCloud
	RETURN .T. && Traiter l'événement sur le serveur
ENDIF
Rand(-1)
this.Parent.SetAll('Value', '', 'ficTxt') && 
this.Parent.Refresh && 
ENDTEXT

m.loTest.Test(m.lcExpected, m.lcTest, 'fr')

* {fr} test 4 ----
text to lcTest noshow
  // {fr} - modifier ce code source,
  // {fr} - communiquer ce code à un tiers sans notre accord explicite préalable : ni en totalité ni en partie,
  // {fr}   ni au format source ni au format compilé, par tout moyen de communication, oral, écrit ou électronique.
  // {fr} Vous devez prendre toutes les mesures de protection évitant la divulgation, 
  // {fr}   accidentelle ou volontaire, de ce code à des tiers
  // --------------------------------------------------------------------------------------------------------------
  // {en} This software is distributed under FoxInCloud license, as is, without any warranty.
  // {en} You may:
  // {en} - read this source code,
  // {en} - learn and inspire from it,
ENDTEXT

text to lcExpected noshow
  // - modifier ce code source,
  // - communiquer ce code à un tiers sans notre accord explicite préalable : ni en totalité ni en partie,
  //   ni au format source ni au format compilé, par tout moyen de communication, oral, écrit ou électronique.
  // Vous devez prendre toutes les mesures de protection évitant la divulgation, 
  //   accidentelle ou volontaire, de ce code à des tiers
  // --------------------------------------------------------------------------------------------------------------
endtext

m.loTest.Test(m.lcExpected + CR, m.lcTest, 'fr', '//')

return loTest.result()
endproc

* -------------------------------
function cTagsStripped && {fr} Texte HTML sans balises
lparameters ;
  tcHTML; && {fr} Texte HTML
, tcTags && [toutes] {fr} Balises à supprimer

local laTags[1], lcTag, loRE, lcResult
lcResult = m.tcHTML

if vartype(m.tcTags) == 'C'

	alines(laTags, m.tcTags, 1, ',', ';')
	for each lcTag in laTags

		lcResult = cTagStripped(m.lcResult, m.lcTag)
	endfor
else

	loRE = create('VBscript.regexp')
	loRE.pattern = '<[^>]+>'
	loRE.global = .t.
	lcResult = loRE.replace(m.tcHTML, '')
endif

return m.lcResult

* -------------------------------
function cTagStripped && {fr} Texte HTML sans une balise
lparameters ;
  tcHTML; && Texte HTML
, tcTag; && [toutes] {fr} Balise(s) à supprimer
, tlExcept; && [.F.] {fr} Sauf balises ci-dessus

tcTag = iif(vartype(m.tcTag) == 'C', upper(alltrim(m.tcTag)), '')
tlExcept = lTrue(m.tlExcept)

local lcResult;
, liTagBeg;
, liTagEnd;
, llTagEnd;
, lcTag;
, lcHTML;
, lnOccBeg;
, lnOccEnd;

lcResult = iif(vartype(m.tcHTML) == 'C', m.tcHTML, '')
if !empty(m.lcResult)

	lnOccBeg = 0
	do while .t.
		lnOccBeg = m.lnOccBeg + 1

		* {fr} Si balise cherchée ouvrante,
		liTagBeg = atcc('<' + m.tcTag, m.lcResult, m.lnOccBeg)
		if m.liTagBeg > 0

			* {fr} Trouver la position de la balise fermante correspondante
			lcHTML = substrc(m.lcResult, m.liTagBeg)
			lnOccEnd = 1
			do while .t. && /!\ bug boucle infinie

				liTagEnd = atcc('>', m.lcHTML, m.lnOccEnd)
				llTagEnd = m.liTagend > 0
				if !m.llTagEnd or occurs('<', leftc(m.lcHTML, m.liTagEnd)) = m.lnOccEnd
					exit
				else
					lnOccEnd = m.lnOccEnd + 1
				endif
			enddo

			if m.llTagEnd

				lcTag = Substrc(m.lcHTML, 2, Evl(Atcc(' ', m.lcHTML), m.liTagEnd) - 2)
				
				* {fr} Supprimer la balise
				lcHTML = substrc(m.lcHTML, 1, m.liTagEnd)
				lcResult = strtran(m.lcResult, m.lcHTML, '', 1, 1, 1)

				* {fr} Supprimer la balise fermante correspondante
				lcHTML = '</' + m.tcTag + '>'
				if atcc(m.lcHTML, m.lcResult) > 0
					lcResult = strtran(m.lcResult, m.lcHTML, '', 1, 1, 1)
				endif
			endif

		* {fr} Sinon, terminé
		else
			exit
		endif
	enddo
endif

return strtran(alltrim(m.lcResult), '> <', '><')
endfunc

* -----------------------------------------------------------------
procedure cTagStripped_Test && {fr} test unitaire cTagStripped()

local loTest as abUnitTest of abDev.prg
loTest = newobject('abUnitTest', 'abDev.prg')

loTest.Test([2 050 030], [<a href="javascript:void(0);" onmouseover="WindowOpen(event, '2 050 030', 300, 100, '<h2>Référence 2 050 030 ...</h2>');">2 050 030</a>], 'a')

return loTest.result()

* -------------------------------------------------------------
function nChainFractLines && {fr} Nombre de lignes d'une chaîne de Caractères fractionnée pour justifier une largeur en mm
LPARAMETERS ;
  tcChain; && {fr} Chaîne à fractionner
, tcCarsCoupPref; && [DEF_CAR_COUP] {fr} Caractères de coupure préférés (limités à 10) '_' pour Space(1)
, tnJustif; && {fr} Largeur de justification de la chaîne (en mm)
, tcPolice; && {fr} Police
, tnCorps; && {fr} Corps en points (un point = 1/72 inch)
, tcStyle; && [N] {fr} Style (ex : BI...)
, tnChasse; && [100%] {fr} Chasse (déformation) en %

tcChain = cChainFract(; && {fr} Chaîne de Caractères fractionnée pour justifier une largeur en mm
	  tcChain; && {fr} Chaîne à fractionner
	, tcCarsCoupPref; && [DEF_CAR_COUP] {fr} Caractères de coupure préférés (limités à 10) '_' pour Space(1)
	, tnJustif; && {fr} Largeur de justification de la chaîne (en mm)
	, tcPolice; && {fr} Police
	, tnCorps; && {fr} Corps en points (un point = 1/72 inch)
	, tcStyle; && [N] {fr} Style (ex : BI...)
	, tnChasse; && [100%] {fr} Chasse (déformation) en %
	)

return Iif(Empty(m.tcChain);
	, 0;
	, Occurs(CR, m.tcChain) + 1;
	)

endfunc

* -----------------------------------------------------------------
PROCEDURE nChainFractLines_Test && {fr} Test unitaire de nChainFractLines()

LOCAL loTest AS abUnitTest OF abDev.prg, lcIn, lcOut, oForm

loTest = NewObject('abUnitTest', 'abDev.prg')

text to lcIn noshow flags 1 pretext 3
	ODBC error # 1526
	Error message: this is a pretty long error message for testing cChainFract() -- should not fit in width
	ODBC error message: message
	ODBC SQL state: state
	Error number from the ODBC data source: 12
	ODBC connection handle: 1
endtext

text to lcOut noshow flags 1 pretext 3
	ODBC error # 1526
	Error message: this is a pretty long error message for
	testing cChainFract() -- should not fit in width
	ODBC error message: message
	ODBC SQL state: state
	Error number from the ODBC data source: 12
	ODBC connection handle: 1

endtext

m.loTest.Test(Occurs(CR, m.lcOut); && 2015-12-17 13:12:32 thn --  modify class awFrmMB of aw
	, m.lcIn;
	, ''; && [DEF_CAR_COUP] {fr} Caractères de coupure préférés (limités à 10) '_' pour Space(1)
	, nMMofPX(376); && {fr} Largeur de justification de la chaîne (en mm)
	, 'verdana'; && {fr} Police
	, 9; && {fr} Corps en points (un point = 1/72 inch)
	, ; && [N] {fr} Style (ex : BI...)
	, ; && [100%] {fr} Chasse (déformation) en %
	)

RETURN loTest.result()

* -------------------------------------------------------------
function cChainFract && {fr} Chaîne de Caractères fractionnée pour justifier une largeur en mm
LPARAMETERS ;
  tcChain; && {fr} Chaîne à fractionner
, tcCarsCoupPref; && [DEF_CAR_COUP] {fr} Caractères de coupure préférés (limités à 10) '_' pour Space(1)
, tnJustif; && {fr} Largeur de justification de la chaîne (en mm)
, tcPolice; && {fr} Police
, tnCorps; && {fr} Corps en points (un point = 1/72 inch)
, tcStyle; && [N] {fr} Style (ex : BI...)
, tnChasse; && [100%] {fr} Chasse (déformation) en %

local result as String;
, cTete as String; && @ {fr} Tête de la chaîne justifiante 
, cQueue as String; && @ {fr} Queue de la chaîne à passer à la ligne suivante
, aa[1] as String, iLine as Integer, cLine as String;

result = ''

for iLine = ALines(m.aa, m.tcChain, 1) to 1 step -1
	cTete = ''
	cQueue = m.aa[m.iLine]
	cLine = ''
	do while !Empty(m.cQueue) and 0 < nChainFract(;&& {fr} Fractionne une Chaîne de Caractères pour justifier une largeur en mm
		  m.cQueue; && {fr} Chaîne à fractionner
	  ,@m.cTete; && @ {fr} Tête de la chaîne justifiante 
	  ,@m.cQueue; && @ {fr} Queue de la chaîne à passer à la ligne suivante
	  , m.tcCarsCoupPref; && [DEF_CAR_COUP] {fr} Caractères de coupure préférés (limités à 10) '_' pour Space(1)
	  , m.tnJustif; && {fr} Largeur de justification de la chaîne (en mm)
	  , m.tcPolice; && {fr} Police
	  , m.tnCorps; && {fr} Corps en points (un point = 1/72 inch)
	  , m.tcStyle; && [N] {fr} Style (ex : BI...)
	  , m.tnChasse; && [100%] {fr} Chasse (déformation) en %
		)
		cLine = m.cLine + CRLF + m.cTete
	enddo
	
	result = Substr(m.cLine, 3) + CRLF + m.result
endfor

return Trim(m.result, CR, LF)
endfunc

* -----------------------------------------------------------------
PROCEDURE cChainFract_Test && {fr} Test unitaire de cChainFract()

LOCAL loTest AS abUnitTest OF abDev.prg, lcIn, lcOut, oForm

loTest = NewObject('abUnitTest', 'abDev.prg')

text to lcIn noshow flags 1 pretext 3
	ODBC error # 1526
	Error message: this is a pretty long error message for testing cChainFract() -- should not fit in width
	ODBC error message: message
	ODBC SQL state: state
	Error number from the ODBC data source: 12
	ODBC connection handle: 1
endtext

text to lcOut noshow flags 1 pretext 3
	ODBC error # 1526
	Error message: this is a pretty long error message for
	testing cChainFract() -- should not fit in width
	ODBC error message: message
	ODBC SQL state: state
	Error number from the ODBC data source: 12
	ODBC connection handle: 1
endtext

if Program(-1) = 1
	wForm('awFrmMB', .T., m.lcIn, 5+48, 'cChainFract_Test()', 10000)
endif

#if .F.
MessageBox(mess,5+48,'',10000)
#endif

m.loTest.Test(m.lcOut; && 2015-12-17 13:12:32 thn --  modify class awFrmMB of aw
	, m.lcIn;
	, ''; && [DEF_CAR_COUP] {fr} Caractères de coupure préférés (limités à 10) '_' pour Space(1)
	, nMMofPX(376); && {fr} Largeur de justification de la chaîne (en mm)
	, 'verdana'; && {fr} Police
	, 9; && {fr} Corps en points (un point = 1/72 inch)
	, ; && [N] {fr} Style (ex : BI...)
	, ; && [100%] {fr} Chasse (déformation) en %
	)

RETURN loTest.Result()

* -------------------------------------------------------------
FUNCTION nChainFract && {fr} Fractionne une Chaîne de Caractères pour justifier une largeur en mm
LPARAMETERS ;
  tcChain; && {fr} Chaîne à fractionner
, tcTete; && @ {fr} Tête de la chaîne justifiante 
, tcQueue; && @ {fr} Queue de la chaîne à passer à la ligne suivante
, tcCarsCoupPref; && [DEF_CAR_COUP] {fr} Caractères de coupure préférés (limités à 10) '_' pour Space(1)
, tnJustif; && {fr} Largeur de justification de la chaîne (en mm)
, tcPolice; && {fr} Police
, tnCorps; && {fr} Corps en points (un point = 1/72 inch)
, tcStyle; && [N] {fr} Style (ex : BI...)
, tnChasse; && [100%] {fr} Chasse (déformation) en %
, tlForce; && [.F.] {fr} Forcer la césure

LOCAL lnResult && {fr} Longueur de la Tête en mm
lnResult = -1

*================================================================
* {fr} Date	Par		Action
* --------	---		-----------------------------------------------
* 06/06/01	SR		Création
* 07/06/01	SR+TN Test au moyen de 'utilitaires\testenContCh.prg' : OK
* 17/10/02	TN 		Les caractères de coupure indiqués sont préférés au lieu d'imposés
* 20/10/02	TN 		TO DO passer en objet: init du tableau des car par défaut une fois pour toutes puis exploration des caractères préférentiels puis par défaut.
*================================================================

IF  .T.;
 AND Vartype(m.tcChain) = 'C';
 AND Vartype(m.tnJustif) = 'N'  AND m.tnJustif > 0;
 AND Vartype(m.tcPolice) = 'C';
 AND Vartype(m.tnCorps) = 'N' AND m.tnCorps >= 1

	LOCAL lcChain, llForce, lnEncTot, lnJustif
	lcChain = Rtrim(m.tcChain)
	llForce = lTrue(m.tlForce)
	lnEncTot = nWidthMMtext(m.lcChain, m.tcPolice, m.tnCorps, m.tcStyle, m.tnChasse)
	lnJustif = Iif(m.llForce, Min(m.lnEncTot * .9, m.tnJustif), m.tnJustif)

	* {fr} Si la chaîne tient dans l'encombrement
	IF m.lnEncTot <= m.lnJustif
		
		* {fr} Passer toute le chaine en tête
		tcTete = m.lcChain
		tcQueue = ''
		lnResult = m.lnEncTot

	* {fr} Sinon (le chaine ne tient pas)
	ELSE

		* {fr} Si on peut trouver le dernier caractère entrant dans la justif.
	 && {fr} Ici, la chaine a un encombrement > 0, elle a au moins 1 caractère
		LOCAL lnCarLim
		lnCarLim = Len(m.lcChain) - 1
		DO WHILE m.lnJustif < nWidthMMtext(Left(m.lcChain, m.lnCarLim), m.tcPolice, m.tnCorps, m.tcStyle, m.tnChasse)
			lnCarLim = m.lnCarLim - 1
		ENDDO
		IF m.lnCarLim > 0

			LOCAL lnCarCoup && {fr} n° du caractère de coupure
			lnCarCoup = 0

			* {fr} Si des caractères de coupure préférés sont spécifiés
			LOCAL lcCarsCoupPref, lnCarsCoupPref, llCarsCoupPref
			lcCarsCoupPref = Chrtran(Iif(Vartype(m.tcCarsCoupPref)='C', Left(Ltrim(m.tcCarsCoupPref), 10), ''), '_', Space(1))
			lnCarsCoupPref = Len(m.lcCarsCoupPref)
			llCarsCoupPref = m.lnCarsCoupPref > 0
			IF m.llCarsCoupPref
			
				* {fr} Chercher une coupure avec les caractères préférés
				lnCarCoup = nChainFract_nCarCoup(m.lcChain, m.lnCarLim, m.lcCarsCoupPref, '9876543210')
			ENDIF

			* {fr} Si aucune coupure trouvée
			IF m.lnCarCoup = 0

				* {fr} Chercher une coupure avec les caractères par défaut
				#DEFINE DEF_CAR_COUP	',.; -?!)]}>+/\"' + "'"	 && {fr} rangés par notes décroissantes
				#DEFINE DEF_CAR_NOTE	'998876655544332' + "1"
				lnCarCoup = nChainFract_nCarCoup(m.lcChain, m.lnCarLim, DEF_CAR_COUP, DEF_CAR_NOTE)
			ENDIF
			
			* {fr} Si aucune coupure trouvée, coupure sauvage
			lnCarCoup = Iif(m.lnCarCoup = 0 AND m.llForce, m.lnCarLim, m.lnCarCoup)
			
			* {fr} Déterminer la tête et la queue
			tcTete = Rtrim(Left(m.lcChain, m.lnCarCoup))
			tcQueue = Ltrim(Substr(m.lcChain, m.lnCarCoup + 1))
			lnResult = nWidthMMtext(m.tcTete, m.tcPolice, m.tnCorps, m.tcStyle, m.tnChasse)

		* {fr} Sinon (aucun caractère n'entre dans la justif.)
		ELSE
			tcTete = ''
			tcQueue = m.tcChain
			lnResult = 0
		ENDIF
	ENDIF
ENDIF

RETURN m.lnResult

* -------------------------------------------------------------
FUNCTION nChainFract_nCarCoup && {fr} N° du dernier caractère de la chaîne avant la coupure
LPARAMETERS ;
  tcChain; && {fr} Chaine à couper
, tnCarLim; && {fr} n° du Caractère avant lequel la coupure doit s'opérer
, tcCarsCoup; && {fr} caractères où la coupure est autorisée, PAR NOTES DÉCROISSANTES
, tcCarsCoupNotes && {fr} notes (de 0 à 9) des caractères de coupure (sans séparateur)

LOCAL lnResult; && {fr} N° du dernier caractère de la chaîne avant la coupure
, lcChain;
, lnCarsCoup, lnCarCoup, lcCarCoup;
, lnNotesMax, lnPos;
, lnNote, lnNotes, lnNoteMax

lnResult = 0
lcChain = Left(m.tcChain, m.tnCarLim)
lnCarsCoup = Len(m.tcCarsCoup)
lnNotesMax = m.tnCarLim / 7 && {fr} limite le nombre de notes selon la longueur de la chaîne
STORE 0 TO m.lnNotes, m.lnNoteMax

* {fr} Pour chaque caractère de coupure
FOR m.lnCarCoup = 1 TO lnCarsCoup
	lcCarCoup = Substr(tcCarsCoup, m.lnCarCoup, 1)
	
	* {fr} Si le caractère de coupure existe dans la chaine
	IF m.lcCarCoup $ m.lcChain
	
		* {fr} Trouver la position du caractère de coupure en partant de la fin, et sa note
			&& {fr} La note est la somme de la note du caractère de coupure et de la position par rapport au début
		lnPos = Ratc(m.lcCarCoup, m.lcChain)
		lnNote = Val(Substr(tcCarsCoupNotes, m.lnCarCoup, 1)) + m.lnPos
		
		* {fr} Si la note est la meilleur, mémoriser
		IF m.lnNote > m.lnNoteMax
			lnNoteMax = m.lnNote
			lnResult = m.lnPos
		ENDIF

		* {fr} Si le compte de notes est atteint, terminer la recherche
		lnNotes = m.lnNotes + 1
		IF m.lnNotes = m.lnNotesMax
			EXIT
		ENDIF
	ENDIF
ENDFOR

RETURN m.lnResult

* -----------------------------------------------------------------
PROCEDURE nChainFract_Test && {fr} Test unitaire de nChainFract()

LOCAL loTest AS abUnitTest OF abDev.prg, lcT, lcQ
loTest = NewObject('abUnitTest', 'abDev.prg')

m.loTest.Test(.null., 'mon capitaine', @m.lcT, @m.lcQ, '', 10, 'arial', 9) && {fr} Longueur de la Tête en mm
m.loTest.assert('mon', m.lcT)
m.loTest.assert('capitaine', m.lcQ)

m.loTest.Test(.null., '2.0 Twin SparkSélecspeed', @m.lcT, @m.lcQ, '/,', 20, 'Univers-CondensedBold', 9, , .9)
m.loTest.assert('2.0 Twin', m.lcT)
m.loTest.assert('SparkSélecspeed', m.lcQ)


*!*	? Str(nChainFract('mon/capitaine', @m.lcT, @m.lcQ, '/', 10, 'arial', 9),6,2) + '|' + m.lcT + '|' + m.lcQ
*!*	? Str(nChainFract('mon-capitaine', @m.lcT, @m.lcQ, '/', 10, 'arial', 9),6,2) + '|' + m.lcT + '|' + m.lcQ
*!*	? Str(nChainFract('280B20, 280G/201, 205, 207, 280G/202, 203, 204, 206, 280C20B', @m.lcT, @m.lcQ, '', 47, 'Univers Light Condensed', 8, , .9),6,2) + '|' + m.lcT + '|' + m.lcQ

RETURN loTest.Result()

* -------------------------------------------------------------
FUNCTION nWidthMMtext && {fr} Largeur d'un texte en mm papier (PM)
LPARAMETERS ;
  tcTexte; && Texte
, tcFont; && {fr} Police
, tnCorps; && {fr} Corps en points (un point = 1/72 inch)
, tcStyle; && [N] {fr} style selon standard fontMetric : BINOQS–TU
, tnChasse && [100%] {fr} Chasse en fraction ou en %, de 20 à 2000 %

LOCAL lnResult

lnResult = nWidthPXText(m.tcTexte, m.tcFont, m.tnCorps, m.tcStyle)
IF m.lnResult > 0

	* {fr} Convertir les pixels en mm
	lnResult = nMMofPX (m.lnResult)

	* {fr} Appliquer la chasse
	LOCAL lnChasse
	lnChasse = m.tnChasse
	IF varType (m.lnChasse) # 'N' ;
	 OR m.lnChasse = 0
		lnChasse = 1
	ELSE
		IF m.lnChasse >= 20 && {fr} la chasse a dû être passée en %
			lnChasse = m.lnChasse / 100
		ENDIF
	ENDIF
	lnResult = m.lnResult * m.lnChasse

	* {fr} Appliquer des correctifs lorsque la mesure est optimiste
	&& {fr} Notamment dans PM6.5 vs PM4
	LOCAL lcPolice, lnCorps
	lcPolice = upper(allTrim (m.tcFont))
	lnCorps = Int(m.tnCorps)
	DO CASE
	CASE m.lcPolice = 'UNIVERS CONDENSED'
		DO CASE
		CASE m.lnCorps = 8
			lnResult = m.lnResult * 18/19
		ENDCASE
	CASE m.lcPolice = 'UNIVERS LIGHT CONDENSED'
		DO CASE
		case m.lnCorps = 7
			lnResult = m.lnResult * 1.12
		case m.lnCorps = 8
			lnResult = m.lnResult * 1.045
		ENDCASE
	CASE m.lcPolice = 'HELVETICA-NARROW'
		DO CASE
		case m.lnCorps = 7
			lnResult = m.lnResult * 1.05
		case m.lnCorps = 8
		case m.lnCorps = 9
			lnResult = m.lnResult * 62/59	 && 27/06/01 - AR p 52 du BI éclairage LHD
		ENDCASE
	CASE m.lcPolice = 'ARIAL BLACK'
		lnResult = m.lnResult * 1.05
	ENDCASE

ENDIF

RETURN m.lnResult

* -----------------------------------------------------------------
PROCEDURE nWidthMMtext_Test_man && manual test

LOCAL loTest AS abUnitTest OF abDev.prg
loTest = NewObject('abUnitTest', 'abDev.prg')

? nWidthMMtext ('My taylor is rich', 'helvetica', 9, 'B', .8)
? nWidthMMtext ('My taylor is rich', 'helvetica', 9, 'B', 80)
? nWidthMMtext ('My taylor is rich', Wfont(1), 9, 'B', 80)
? nWidthMMtext ('My taylor is rich', 'arial', 9, 'B', 80)
? nWidthMMtext ('My taylor is rich', 'toto', 9, 'B', 80)
? nWidthMMtext ('My taylor is rich', 'futura', 9, 'B', 80)
? nWidthMMtext ('My taylor is rich', 'futurabold', 9, 'B', 80)

* -------------------------------------------------------------
FUNCTION nWidthPXText && {fr} Largeur d'un texte en pixels écran
LPARAMETERS ;
  tcTexte; && Texte
, tcFont; && {fr} Police
, tnCorps; && {fr} Corps en points (un point = 1/72 inch)
, tcStyle && [N] {fr} style selon standard fontMetric() (BINOQS–TU)

LOCAL lnResult

IF Vartype(m.tcTexte) == 'C';
 AND Vartype(m.tcFont) == 'C';
 AND !Empty(m.tcFont) ;
 AND Vartype(m.tnCorps) == 'N';
 AND m.tnCorps >= 0

	IF Empty(m.tcTexte) OR Empty(m.tnCorps)
		lnResult = 0
	ELSE
		tcFont = Alltrim(m.tcFont) && 10/05/2004 valeur erronée avec m.tcFont = 'UniveLigUltCon         '
		tcStyle = Iif(Vartype(m.tcStyle) == 'C', m.tcStyle, '')
		lnResult = Txtwidth(m.tcTexte, m.tcFont, m.tnCorps, m.tcStyle) * Fontmetric(6, m.tcFont, m.tnCorps, m.tcStyle)
	ENDIF
ELSE
	lnResult = -1
ENDIF

RETURN m.lnResult
endfunc

* -------------------------------------------------------------
function nLineHeightPX && {fr} Hauteur d'une ligne de texte en pixels écran
lparameters cFontName, nFontSize, cFontStyle
cFontStyle = Evl(m.cFontStyle, '')
return 0;
	+ Fontmetric(2, m.cFontName, m.nFontSize, m.cFontStyle); && Character ascent  (units above baseline) in pixels
	+ Fontmetric(3, m.cFontName, m.nFontSize, m.cFontStyle); && Character descent (units below baseline) in pixels
	+ 0
endfunc

* -------------------------------------------------------------
function nLineInterPX && {fr} Interligne de texte en pixels écran
lparameters cFontName, nFontSize, cFontStyle
cFontStyle = Evl(m.cFontStyle, '')
return nLineHeightPX(m.cFontName, m.nFontSize, m.cFontStyle);
	+ Fontmetric(4, m.cFontName, m.nFontSize, m.cFontStyle); && leading (space between lines)
	+ Fontmetric(5, m.cFontName, m.nFontSize, m.cFontStyle); && extra leading
	+ 0
endfunc

* -------------------------------------------------------------
function noLineHeightPX && {fr} Hauteur d'une ligne de texte d'un objet
lparameters toControl as awTxt of aw.vcx
return Iif(lProperty(m.toControl, 'FontName');
	, nLineHeightPX(m.toControl.FontName, m.toControl.FontSize, coFontStyle(m.toControl));
	, .null.;
	)
endfunc

* -------------------------------------------------------------
function noLineInterPX && {fr} Hauteur d'une ligne de texte d'un objet
lparameters toControl as awTxt of aw.vcx
return Iif(lProperty(m.toControl, 'FontName');
	, nLineInterPX(m.toControl.FontName, m.toControl.FontSize, coFontStyle(m.toControl));
	, .null.;
	)
endfunc

* -------------------------------------------------------------
function atcFirst && {fr} Position du premier caractère présent dans une chaîne
lparameters ;
  tuChars; && {fr} caractères à chercher
, tcChain; && {fr} chaîne où chercher

external array tuChars

local liResult as Integer;
, laChars[1], lcChar, liChar;

do case
case !ga_Type_IsChar(m.tcChain, .T.)
	return .null.
case Type('tuChars', 1) == 'A'
	dimension laChars[Alen(m.tuChars)]
	Acopy(tuChars, laChars)
case ga_Type_IsChar(m.tuChars, .T.)
otherwise
	return .null.
endcase	

liResult = .null.
for each lcChar in m.laChars
	liChar = At_c(Transform(m.lcChar), m.tcChain)
	liResult = ICase(m.liChar = 0, m.liResult, IsNull(m.liResult), m.liChar, Min(m.liChar, m.liResult))
endfor

return Nvl(m.liResult, 0)
endfunc
