* abTxt.prg
* =====================================================
* (c) Abaque SARL, 66 rue Michel Ange - 75016 Paris - France
* contact@FoxInCloud.com - http://foxincloud.com/ - +33 9 53 41 90 90
* -----------------------------------------------------
* Ce logiciel est distribué sous GNU General Public License, tel quel, sans aucune garantie
* Il peut être utilisé et/ou redistribué sans restriction
* Toute modification doit être reversée à la communauté
* La présente mention doit être intégralement reproduite
&& dans toute copie même partielle
* -----------------------------------------------------
* This software is distributed under the terms of GNU General Public License, AS IS, without any warranty
* It may be used and/or distributed without restriction
* Any substantial improvement must be given for free to the community
* This permission notice shall be entirely included in all copies
&& or substantial portions of the Software
* =====================================================

#INCLUDE AB.H
AB()
return abUnitTests()

* ===================================================================
function cTronc	&& Chaîne tronquée à une longueur donnée en la terminant par "..."
lparameters ;
	tcChain,; && Chaine à tronquer
	tnTronc,; && [50] Nombre de caractères oû la chaine totale doit tenir
	tlWord,; && [.F.] couper à la fin d'un mot
	tcDropped,; && @ [''] Partie éventuellement coupée
	tlEllipsNot,; && [.F.] Ne pas ajouter de points de suspension
	tcSep && [any] preferred separator

local lcResult;
, llResult;
, lcEllips;

store '' to tcDropped, lcResult

llResult = vartype(m.tcChain) == 'C'
assert m.llResult message "Required parameter tcChain is invalid"
if m.llResult

	tnTronc = iif(vartype(m.tnTronc) == 'N' and m.tnTronc > 0, m.tnTronc, 50)

	* Si la chaîne est plus longue que la troncature
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

		* Si coupure à la fin d'un mot
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

loTest.Test('891-1490, 791-14Â ...', '891-1490, 791-1491, 1890, 2891 (MilitÃ¤rfzg. Mit geteilert Scheibe)', 20) && Len('891-1490, 791-14') = 16
loTest.Test('891-1490,Â ...', '891-1490, 791-1491, 1890, 2891 (MilitÃ¤rfzg. Mit geteilert Scheibe)', 20, .t., @m.lcDropped)
loTest.assert('791-1491, 1890, 2891 (MilitÃ¤rfzg. Mit geteilert Scheibe)', m.lcDropped)

return loTest.Result()

* ===================================================================
function cJustified	&& Chaîne justifiée
lparameters ;
	tcChain,; && Chaîne à justifier
	tnCols && [80] Nombre de colonnes
tcChain = iif(vartype(m.tcChain) == 'C', m.tcChain, '')
tnCols = evl(m.tnCols, 80)

local lnLine, laLine[1], liLine, lcLine

lnLine = alines(laLine, m.tcChain)
if m.lnLine > 0

	for liLine = 1 to m.lnLine
		lcLine = laLine[m.liLine]
		laLine[m.liLine] = space(0)
		do while not empty(m.lcLine)
			laLine[m.liLine] = c2Words(laLine[m.liLine], CRLF, cTronc(m.lcLine, m.tnCols, .t., @m.lcLine, .t.))
		enddo
	endfor

	return cListOfArray(@m.laLine, CRLF,,,.t.) + iif(m.lnLine > 1, CRLF, '')
else
	return ''
endif

* ===================================================================
function cWords && Mots séparés par paires non vides
lparameters ;
	tuSep,; && Séparateur
	tuW0,;	&& tableau de mots (1 dim.) ou premier mot
	tuW1, tuW2, tuW3, tuW4, tuW5, tuW6, tuW7, tuW8, tuW9, tuW10, tuW11, tuW12, tuW13, tuW14, tuW15, tuW16, tuW17, tuW18, tuW19, tuW20, tuW21, tuW22, tuW23, tuW24 && [''] mots suivants

local lcResult
lcResult = space(0)

if not vartype(m.tuSep) == 'L'
	local lnWord

 	if type('tuW0',1) <> 'A' && not an array
 		if pcount() > 2
	 		for m.lnWord = 0 to pcount()-2
	 			lcResult = c2Words(m.lcResult, m.tuSep, evaluate('m.tuW' + ltrim(str(m.lnWord))))
	 		endfor
	 	endif

 	else
 		external array tuW0
 		for m.lnWord = 1 to alen(m.tuW0)
 			lcResult = c2Words(m.lcResult, m.tuSep, m.tuW0[m.lnWord])
 		endfor
 	endif
endif

return m.lcResult

* -----------------------------------------------------------------
procedure cWords_test
? sys(16)

? cWords('/', space(0), 10, .f., 'moi') == '10/.F./moi'

local array laW[6]
laW[1] = 'thierry'
laW[2] = 15
laW[3] = .f.
laW[4] = space(0)
laW[5] = 0
laW[6] = createobject('form')
? cWords(',', @m.laW) == 'thierry,15,.F.,0'
laW[6] = null

* ===================================================================
function c2Words && Deux mots séparés si non vides
lparameters ;
	tuW1,; && Premier mot, type variable
	tuSep,; && Séparateur, type variable
	tuW2 && Second mot, type variable

local llW1Empty, llW2Empty, lcSep, lnSep, lcW1, lcW2

llW1Empty = vartype(m.tuW1) == 'C' and empty(m.tuW1) or vartype(m.tuW1) $ 'OGXU'
llW2Empty = vartype(m.tuW2) == 'C' and empty(m.tuW2) or vartype(m.tuW2) $ 'OGXU'

do case
case pcount() < 3
	return iif(m.llW1Empty, space(0), transform(m.tuW1))

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

otherwise && CASE m.llW2Empty
	return transform(m.tuW1)
endcase

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
function cC && Alias de cComparable()
lparameters ;
	tc,; && Texte source
	tnLength && [trim] Si > 0, le résultat est paddé à cette longueur (pour index)

return cComparable(m.tc, m.tnLength)

* ===================================================================
function cComparable && Texte débarrassé de ses variantes typographiques pour comparaison
lparameters ;
	tc,; && Texte source
	tnLength && [trim] Si > 0, le résultat est paddé à cette longueur (pour index)

local lcChars, lcResult && Texte comparable

do case
case isnull(m.tc) or empty(m.tc)
	lcResult = space(0)

case vartype(m.tc) == 'C'
	lcResult = upper(alltrim(m.tc))
	lcResult = cEuroANSI(m.lcResult) && désaccentue
	lcChars  = chrtran(m.EuroAnsi, '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz ', '')
	lcResult = chrtran(m.lcResult, m.lcChars, space(len(m.lcChars))) && ne garde que les caractères alphanumériques et les espaces
	lcResult = cRepCharDel(m.lcResult) && supprime les double espaces
	lcResult = cSpaceAroundGroup(m.lcResult) && normalise le nombre d'espaces autour des caractères de groupement

otherwise
	lcResult = space(0)
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
loTest.Test([CA C EST SUR LE SAVOIR FAIRE D ABAQUE EST IMMENSE], [Ã‡a c'est  sùr, le savoir-faire d'Abaque est immense])
loTest.Test(space(50), .null., 50)

return loTest.Result()

* ===================================================================
function cRepCharsDel && Séquences de caractères identiques remplacées par un caractère simple
lparameters ;
	tcChain,;	&& Chaine de caractères à traiter
	tcChars && Caractère(s) dont les répétitions sont à éliminer

local lcChars, llResult, lcResult
lcResult = space(0)

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
function cRepCharDel && Séquences d'un caractère remplacées par un caractère simple
lparameters ;
	tcChain,;	&& Chaine de caractères à traiter
	tcChar && [space(1)] Caractère dont les répétitions sont à éliminer

if vartype(m.tcChain) = 'C'

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
procedure cRepCharDel_Test	&& Tests cRepCharDel

local loTest as abUnitTest of abDev.prg
loTest = newobject('abUnitTest', 'abDev.prg')

loTest.Test('appuie-tête', 'appuie--tête', '-')
loTest.Test('appuie tête', 'appuie  tête')
loTest.Test('appuie-tête', 'appuie----------------tête', '-')

return loTest.Result()

* ===================================================================
function cSpaceAround	&& Chaîne oû les nombres d'Space(1) avant et après une sous-chaîne donnée sont normalisés
lparameters ;
	tcChain, ; && Chaine à traiter
	tcSubChain, ; && Sous-chaine dont les espaces avant - après sont à normaliser
	tnBefore, ;	&& [0] Nombre d'espaces avant la sous-chaine
	tnAfter && [tnBefore] Nombre d'espaces après la sous-chaine

if vartype(m.tcChain) == 'C';
 and vartype(m.tcSubChain) == 'C' ;
 and ! empty(m.tcSubChain) ;
 and m.tcSubChain $ m.tcChain
	lcResult = m.tcChain

	* Delete spaces before and after character chain
	do while space(1) + m.tcSubChain $ m.lcResult
		lcResult = strtran(m.lcResult, space(1)+m.tcSubChain, m.tcSubChain)
	enddo
	do while m.tcSubChain + space(1) $ m.lcResult
		lcResult = strtran(m.lcResult, m.tcSubChain+space(1), m.tcSubChain)
	enddo

	* Add the required number of spaces before and after character chain
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
function cSpaceAroundGroup	&& Chaîne oû le nombre d'Space(1) autour des caractères de groupement '({[]})' est normalisé
lparameters tcChain && Chaîne

local lcResult
lcResult = space(0)

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
		lcResult = m.lcResult + iif(m.llGroupCarOpen, space(0), m.lcCar)
	case m.lcCar $ GROUPCAR_OPEN
		lcResult = iif(m.llSpace, m.lcResult, m.lcResult + space(1)) + m.lcCar
	case m.lcCar $ GROUPCAR_CLOSE
		lcResult = iif(m.llSpace, left(m.lcResult, len(m.lcResult)-1), m.lcResult) + m.lcCar
	otherwise
		lcResult = m.lcResult + iif(m.llGroupCarClose, space(1), space(0)) + m.lcCar
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
loTest = newobject('abUnitTest', 'abDev.prg') && NewObject('abUnitTest', 'abDev.prg')

loTest.Test('abc ((efg))', 'abc ( (efg ))')
loTest.Test('abc [(efg)]', 'abc [ (efg )]')
loTest.Test('abc [(efg)] toto', 'abc[ ( efg )]toto')
loTest.Test('Cabriolet (8G) 91-', 'Cabriolet  (  8G  )  91-')
loTest.Test('Cabriolet (8G) 91-', 'Cabriolet(8G)91-')
loTest.Test('Cabriolet (8G) 91-', 'Cabriolet (8G) 91-')

return loTest.Result()

* ===================================================================
function cSepGrpsXFigs	&& Groupe les chiffres dans une chaîne de caractères
lparameters ;
	tcChain,; && Chaine à traiter
	tnFactGroup,;	&& [3] Facteur de regroupement des groupes de chiffres
	tcSep && [Space(1)] Caractère de séparation des groupes de chiffres
local lcResult
store space(0) to m.lcResult

* Si une chaine valide a été passée
if vartype(m.tcChain) == 'C'

	local lcChain, lnChain
	lcChain = alltrim(m.tcChain)
	lnChain = len(m.lcChain)
	lcResult = m.lcChain

	* Donner leur valeur par défaut aux paramètres optionnels
	local lnFactGroup, lcSep
	lnFactGroup = ;
		iif	(vartype(m.tnFactGroup) == 'N' ;
					and m.tnFactGroup > 0 ;
					and m.tnFactGroup < m.lnChain ;	&& aberrant
					, m.tnFactGroup, 3)
	lcSep = iif(vartype(m.tcSep)=='C' and not empty(m.tcSep), left(ltrim(m.tcSep), 1), space(1))

	if m.lnFactGroup < m.lnChain

		* Pour chaque caractère en partant de la fin
		local lnCar, lcCar, lnChiffres, llSepAj
		lnChiffres = 0
		lcResult = space(0)
		for m.lnCar = m.lnChain to 1 step -1

			lcCar = substr(m.lcChain, m.lnCar, 1)
			do case

			case isdigit(m.lcCar)
				lnChiffres = m.lnChiffres + 1
				if m.lnChiffres = m.lnFactGroup ;
				 and m.lnCar > 1 && ne pas ajouter de séparateur devant le 1er caractère !
					lnChiffres = 0
					lcCar = m.lcSep + m.lcCar
					llSepAj = .t.
				else
					llSepAj = .f.
				endif

			case m.lcCar == m.lcSep
				if m.llSepAj
					* Ce séparateur fait double emploi avec celui que l'on vient d'ajouter,
					* Ne pas le garder
					loop
				endif

			otherwise	&& ni chiffre ni séparateur

				* Si un séparateur vient d'être ajouté, le supprimer.
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
procedure cSepGrpsXFigs_Test	&& Teste cSepGrpsXFigs

? sys(16)
? cSepGrpsXFigs('ABCDE123456', 3) == 'ABCDE123 456'
? cSepGrpsXFigs('ABCDE123....456', 3, '.') == 'ABCDE123.456'
? cSepGrpsXFigs('ABCDE123....456.', 3, '.') == 'ABCDE123.456.'
? cSepGrpsXFigs('AL01021', 10) == 'AL01 021'
? cSepGrpsXFigs('AL01021') == 'AL01 021'
? cSepGrpsXFigs('12', 1) == '1 2'
? cSepGrpsXFigs('AL 01021') == 'AL 01 021'
? cSepGrpsXFigs('1256001021') == '1 256 001 021'
? cSepGrpsXFigs('1256001021', , ',') == '1,256,001,021'
? cSepGrpsXFigs('1256001021', 5, '|') == '12560|01021'

* ===================================================================
function cListOfArrayC && Liste délimitée du contenu d'un tableau caractère
lparameters ;
	taWords, ; && @ Mots de type C
	tcDelim, ; && [','] Délimiteur
	tnCol && [1] NÂ° de colonne, -1 pour toutes les colonnes (tableau taWords à 2 dimensions)
external array taWords

&& /!\ en chantier

* ===================================================================
function cListOfArray	&& Liste délimitée du contenu d'un tableau
lparameters ;
	taWords, ; && @ Mots de types divers (CNDTLY sont supportés)
	tcDelim, ; && [','] Délimiteur
	tnCol,; && [1] NÂ° de colonne, -1 pour toutes les colonnes (tableau taWords à 2 dimensions)
	tlLitterals,; && [.F.] écrire les mots sous la forme de litteraux VFP (ex. foo > "foo",  02/07/03 > {^2003-02-07})
	tlKeepEmpty,; && [tlLitterals] Include empty words
	tlKeepNull,; && [tlLitterals] Include .NULL. words
	tlKeepWeird,; && [.F.] Include words of type G/U
	tlDistinct,; && [.F.] Élimine les doublons
	tlLines,; && [.F.] Séparer les lignes (tableau taWords à 2 dimensions et m.tnCol = -1)
	tnColFilter,; && [aucune] nÂ° de colonne contenant un filtre des lignes à lister
	tlRtrimNot && [.F.] Ne pas supprimer les espaces en queue des éléments de type caractère

external array taWords

local lnCols;
, lcPoint, llPoint; && , loPoint
, liWord, luWord, lcWord;
, lcVarType, lcDelim, llRtrim;
, lcResult

lcResult = space(0)

if not laEmpty(@m.taWords)

	* Déterminer le nombre de colonnes du tableau
	lnCols = alen(taWords, 2)

	* Donner leur valeur par défaut aux paramètres optionnels
	tcDelim = iif(vartype(m.tcDelim) == 'C' and lenc(m.tcDelim) > 0 , m.tcDelim, ',')
	tnCol = icase(;
		M.lnCols = 0,; && tableau à 1 dimension
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

	* Si le délimiteur peut entrer en conflit avec le séparateur décimal, changer celui-ci
	lcPoint = set('POINT')
	llPoint = m.lcPoint $ m.tcDelim
	if m.llPoint
		set point to icase(;
					not '.' $ m.tcDelim, '.',;
					not ',' $ m.tcDelim, ',',;
					not ';' $ m.tcDelim, ';',;
					'?')

*-				loPoint = abSet('POINT', ICase(; && ne marche pas
*-									NOT '.' $ m.tcDelim, '.',;
*-									NOT ',' $ m.tcDelim, ',',;
*-									NOT ';' $ m.tcDelim, ';',;
*-									'?'),,, .T.)
	endif

	* Pour chaque élément du tableau
	for liWord = 1 to iif(m.tnCol <= 0, alen(m.taWords), alen(m.taWords, 1))

		luWord = iif(m.tnCol <= 0, taWords[m.liWord], taWords[m.liWord, m.tnCol])
		lcVarType = vartype(m.luWord)

		* Si la valeur est valide
		if .t.;
		 and m.lcVarType $ 'CNDTLYOX'; && G not supported
		 and (m.tlKeepNull or not m.lcVarType == 'X');
		 and (m.lcVarType == 'O' or m.tlKeepEmpty or not empty(m.luWord)); && Gestion des vides
		 and (m.tnColFilter = 0 or not empty(taWords[m.liWord, m.tnColFilter]))

			lcWord = icase(;
				M.tlLitterals,;
					cLitteral(m.luWord, m.llRtrim),;
				M.lcVarType == 'C' and m.tlRtrimNot,;
					M.luWord,;
					trim(transform(m.luWord));
				)

			lcDelim = iif(m.tlLines and asubscript(m.taWords, m.liWord, 2) = m.lnCols;
				, CRLF;
				, m.tcDelim;
				)

			* Si le mot n'est pas répété
			if not (.t.;
				and m.tlDistinct;
				and (.f.;
					or m.lcDelim + m.lcWord + m.lcDelim $ m.lcResult;
					or m.tcDelim + m.lcWord + m.tcDelim $ m.lcResult;
					or left(m.lcResult, lenc(m.lcWord + m.lcDelim)) == m.lcWord + m.lcDelim;
					or left(m.lcResult, lenc(m.lcWord + m.tcDelim)) == m.lcWord + m.tcDelim;
					);
				)

				lcResult = m.lcResult + m.lcWord + m.lcDelim
			endif
		endif
	endfor

	if m.llPoint
		set point to m.lcPoint
	endif

	lcResult = leftc(m.lcResult, lenc(m.lcResult) - lenc(evl(m.lcDelim, ''))) && supprime le dernier délimiteur
endif

return m.lcResult

* -----------------------------------------------------------------
procedure cListofArray_Test

local loTest as abUnitTest of abDev.prg, laTest[1]
loTest = newobject('abUnitTest', 'abDev.prg')

dimension laTest [9]
laTest[1] = 'First'	&& C
laTest[2] = 2.25		&& N
laTest[3] = .t.		&& L
laTest[4] = date(2003,2,8)	&& D
laTest[5] = datetime(2003,2,8,11,34,15)	&& T
laTest[6] = space(0)	&& C Empty
laTest[7] = 0		&& N Empty
laTest[8] = .f.	&& L Empty
laTest[9] = {}	&& D Empty
loTest.Test('"First",2.25,.T.,{^2003-02-08},{^2003-02-08 11:34:15},"",0,.F.,{/}', @m.laTest,,,.t.)

dimension laTest[5,2]
laTest= space(0)
laTest[1,2] = 'First'
laTest[2,2] = 'Second'
laTest[3,2] = '  '
laTest[4,2] = 'Fourth'
laTest[5,2] = 'Fifth'
loTest.Test('"First","Second","","Fourth","Fifth"', @m.laTest,,2,.t.)
loTest.Test('"","First","","Second","","","","Fourth","","Fifth"', @m.laTest,,-1,.t.)
loTest.Test('First,Second,Fourth,Fifth', @m.laTest,,-1)
loTest.Test(cWords(CRLF, 'First','Second','Fourth','Fifth'), @m.laTest,,-1,,,,,,.t.) && toutes les colonnes, sans les vides, lignes séparées par CRLF
loTest.Test(',First,,Second,,,,Fourth,,Fifth', @m.laTest,,-1,,.t.)

return m.loTest.Result()

* ===================================================================
function cPrintable	&& Chaine ne contenant que des caractères imprimables
lparameters ;
	tcChain && Chaine à normaliser

if vartype(m.tcChain) == 'C' ;
 and not empty(m.tcChain)

	return cRepCharDel(chrtranc(m.tcChain, NON_PRINTABLE, space(len(NON_PRINTABLE))))
else
	return space(0)
endif

* ===================================================================
function cOfLitteral && Chaîne depuis un littéral
lparameters ;
  tcLitteral;
, tlLitteral && [.F.] return an empty string if tcLitteral is not a String literal

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
function cL && Littéral VFP && Alias de cLitteral()
lparameters ;
	tuData, ; && Valeur à convertir en littéral (type supportés : tous soit CDGLNOQTUXY)
	tlRTrim,;  && [.F.] si type C, ôter les espaces à droite
	tnTronc,; && [aucun] si type C, nombre de caractères de troncature
	tlXML && [.F.] Encoder pour XML

return cLitteral(;
	 @m.tuData;
	, m.tlRTrim;
	, m.tnTronc;
	, m.tlXML;
)

* ===================================================================
function cLitteral && Littéral VFP
lparameters ;
	tuData,; && @ Valeur à convertir en littéral (type supportés : tous soit CDGLNOQTUXY)
	tlRTrim,;  && [.F.] si type C, ôter les espaces à droite
	tnTronc,; && [aucun] si type C, nombre de caractères de troncature
	tlXML && [.F.] Encoder pour XML

#if .f. && Vartype VFP9
	C && Character, Memo, Varchar, Varchar (Binary)
	D && Date
	G && General
	L && Logical
	n && Numeric, Float, Double, or Integer
	O && Object
	Q && Blob, Varbinary
	t && DateTime
	U && Unknown or variable does not exist
	X && Null
	y && Currency
#endif

local lcVarType
lcVarType = vartype(m.tuData)

return icase(;
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
		cLitteral_O(m.tuData),;
	M.lcVarType == 'G',;
		'General',;
	M.lcVarType == 'Q',;
		'Blob, Varbinary',;
		'Unknown type';
)

* -----------------------------------------------------------------
function cLitteral_C && Littéral VFP de type caractère
lparameters ;
	tcData, ; && Valeur à convertir en littéral (type supportés : tous soit CDGLNOQTUXY)
	tlRTrim,;  && [.F.] si type C, ôter les espaces à droite
	tnTronc,; && [aucun] si type C, nombre de caractères de troncature
	tlXML && [.F.] Encoder pour support XML


local lcResult as string;
, aa[1] as string;
, s as string;
, lcData as string;
, lnData as integer;
, lcLine as string;
, lnTronc as integer;

lcResult = ''
lnTronc = iif(vartype(m.tnTronc) == 'N' and between(m.tnTronc, 1, 255), int(m.tnTronc), 255) && Maximum length of a string literal : 255

if alines(m.aa, m.tcData) > 0

	for each s in m.aa

		lnData = lenc(m.s)

		s = iif(lTrue(m.tlRTrim), rtrim(m.s), m.s)
		s = iif(lTrue(m.tlXML), cEscaped_XML(m.s), m.s)

		if vartype(m.tnTronc) == 'N'
			s = iif(m.lnData > m.lnTronc, cTronc(m.s, m.lnTronc), m.s)
			lcLine = cLitteral_C_(m.s)
		else
			if m.lnData > 255 && limite d'un littéral caractère
				lcLine = ''
				lcData = m.s
				do while m.lnData > 0
					lcLine = m.lcLine + '+' + cLitteral_C_(leftc(m.lcData, 255))
					lcData = substrc(m.lcData, 256)
					lnData = m.lnData - 255
				enddo
				lcLine = substr(m.lcLine, 2)
			else
				lcLine = cLitteral_C_(m.s)
			endif
		endif

		lcResult = c2Words(m.lcResult, '+Chr(13)+Chr(10)+', m.lcLine)
	endfor
endif

return m.lcResult

* -----------------------------------------------------------------
function cLitteral_C_(tcData)

return icase(;
	not ["] $ m.tcData,;
		["] + m.tcData + ["],; && Le plus généralement accepté
	not ['] $ m.tcData,;
		['] + m.tcData + ['],;
	not ('[' $ m.tcData or ']' $ m.tcData),;
		'[' + m.tcData + ']',;
		cLitteral_C__(m.tcData);
	)

* -----------------------------------------------------------------
function cLitteral_C__(tcData) && littéral d'un chaîne contenant ",[]

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
function cLitteral_N && Littéral VFP de type numérique
lparameters ;
	tuData,; && Nombre  à convertir en littéral
	lcVarType

return chrtran(;
	iif(m.lcVarType = 'Y';
	, '$' + alltrim(str(m.tuData, 200, 6));
	, transform(m.tuData);
	);
	, set("Point"), '.') && Gregory Adam http://www.atoutfox.org/nntp.asp?ID=0000008895

* -----------------------------------------------------------------
function cLitteral_O && Littéral VFP de type objet
lparameters toObject && Objet à convertir en littéral

local lcResult;
, loObject;
, aProp[1];
, iProp as integer;
, cProps as string;
, cProp as string;

lcResult = ''


* Class

do case

case type('m.toObject.class') == 'C' and type('m.toObject.classLibrary') == 'C' && FoxPro Object

	lcResult = cWords(', ';
		, 'class: ' + cL(m.toObject.class);
		, nEvl(m.toObject.classlibrary, 'classLibrary:' + cL(m.toObject.classlibrary));
		, iif(type('m.toObject.Parent') == 'O', 'location: ' + sys(1272, m.toObject), '');
		, cLitteral_O_cProps(m.toObject);
		)

case type('m.toObject.Application') == 'O' and type('m.toObject.Application.Name') == 'C' && and ! 'foxpro' $ Lower(m.toObject.Application.Name) && COM object? eg 'Microsoft Excel'
	lcResult = 'COM class: ' + m.toObject.application.name

case type('m.toObject.class') == 'C' && weird Object
	lcResult = "class: " + m.toObject.class

otherwise && Empty Object

	lcResult = cWords(', ';
		, 'class: "Empty"';
		, cLitteral_O_cProps(m.toObject);
		)
endcase

return nEvl(m.lcResult, 'Object {' + m.lcResult + '}')
endfunc

* -----------------------------------------------------------------
function cLitteral_O_cProps && Propriétés d'un objet modifiées par rapport à sa classe
lparameters toObject && Objet à convertir en littéral

local lcResult as string;
, aProp[1];
, cProp as string;
, lProp as Boolean;
, aa[1];
, lArray as Boolean;

lcResult = ''

if amembers(aProp, m.toObject) > 0 && can be an empty object without properties

	for each cProp in m.aProp
		lProp = !pemstatus(m.toObject, m.cProp, 2) && protected
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
		lcResult = m.lcResult + iif(pemstatus(m.toObject, m.cProp, 0); && modified
			, ', ' + lower(m.cProp) + ': ' + iif(m.lProp;
				, iif(m.lArray;
					, cL(@m.aa);
					, cL(evaluate('m.toObject.' + m.cProp));
					);
				, '[hidden or protected]';
				);
			, '';
			)
	endfor
endif

return ltrim(substr(m.lcResult, 2))
endfunc

* -----------------------------------------------------------------
procedure cLitteral_Test && cLitteral() unit test

local loTest as abUnitTest of abDev.prg;
, luTest;
, luExpected;
, lcOnError;
, llError

loTest = newobject('abUnitTest', 'abDev.prg')

loTest.Test([" foo"], ' foo') && C
loTest.Test(['" foo"'], '" foo"') && C
loTest.Test('[' + ["foo"'] + ']+"' + "[bar]'" + '"', '"foo"' + "'[bar]'") && C
loTest.Test('"' + replicate('a', 255) + '"+[a' + ["foo"'] + ']+"' + "[bar]'" + '"';
	, replicate('a', 256) + '"foo"' + "'[bar]'") && C

loTest.Test('2.5487', 2.5487) && N

loTest.Test('{^2003-02-08}', date(2003,2,8)) && D

loTest.EnvSet([SET SYSFORMATS ON])
loTest.Test('{^2003-02-08 11:34:15}', datetime(2003,2,8,11,34,15)) && T
loTest.Test('.T.', .t.) && L

	luTest = $1254.25 && le littéral ne passe pas dans l'appel de méthode
loTest.Test('$1254.250000', m.luTest) && Y

	local loFoo as container
	loFoo = createobject('container')
	loFoo.name = 'cntFoo'
	loFoo.addobject('lblFoo', 'label')

* loTest.Test('Object of address: cntFoo.LBLFOO', m.loFoo.lblFoo)	&& O

&& G ???

loTest.Test('.NULL.', .null.)	&& X

	lcOnError = on('error')
	on error m.llError = .t.
loTest.Test(space(0), foo) && U = 'Unknown type'
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
function cLitterals && Constantes
lparameters tu01,tu02, tu03, tu04, tu05, tu06, tu07, tu08, tu09, tu10, tu11, tu12, tu13, tu14, tu15 && Variables
local lnParm, lcResult
lcResult = space(0)
if pcount() > 0
	for lnParm = 1 to pcount()
		lcResult = m.lcResult + cLitteral(evaluate(textmerge([m.tu<<Transform(m.lnParm, '@L 99')>>]))) + ','
	endfor
	lcResult = left(m.lcResult, len(m.lcResult)-1) && supprime la dernière ','
endif
return m.lcResult

* -----------------------------------------------------------------
procedure cLitterals_Test && teste cLitteral

local loTest as abUnitTest of abDev.prg, lcTest
loTest = newobject('abUnitTest', 'abDev.prg')

loTest.Test(["toto",2.5,.F.,{^2009-03-10}], 'toto', 2.5, .f., date(2009,3,10))

return loTest.Result()

* =============================================================
function cLitteralJS_HTML && Littéral Javascript d'après une valeur VFP pour ajout à un attribut HTML
lparameters ;
  tuData; && @ Valeur à convertir en littéral ; types supportés : cf. cLitteralJS_lSupport()
, tlTrim; && [.F.] si type C, ôter les espaces à droite

return strtran(cLitteralJS(m.tuData, m.tlTrim), '"', '&#34;') && échappe les guillements '"' par '&#34;' pour le HTML

endfunc

* -----------------------------------------------
procedure cLitteralJS_HTML_Test && cLitteralJS_HTML() unit test

local loTest as abUnitTest of abDev.prg;
, loAsserts as abSet of abDev.prg;
, luData as Variant

loTest = abUnitTest()
loAsserts = abSet('ASSERTS', 'OFF') && 'ON'

loTest.Test(['&#34;Order id&#34;\nTrier : clic gauche\nFiltrer/chercher : clic droit\n(insensible à la casse)'];
	, '"Order id"' + CRLF + 'Trier : clic gauche' + CRLF + 'Filtrer/chercher : clic droit' + CRLF + '(insensible à la casse)';
	)

return m.loTest.Result()

* =============================================================
function cLitteralJS && Littéral Javascript d'après une valeur VFP
lparameters ;
  tuData; && @ Valeur à convertir en littéral ; types supportés : cf. cLitteralJS_lSupport()
, tlTrim; && [.F.] si type C, ôter les espaces à droite
, tlJSON; && [.F.] produire un littéral compatible JSON
, tlQuotesNo; && [.F.] si type C, ne pas entourer de guillemets (XML)

tlJSON = lTrue(m.tlJSON)

local lcVarType, llResult, lcResult

lcResult = space(0)

lcVarType = type('tuData', 1)
lcVarType = iif(m.lcVarType == 'A', m.lcVarType, vartype(m.tuData))
do case

case m.lcVarType == 'C'

* Supprimer les caractères non imprimables
&& /!\ 2/8/07	conserver les sauts de ligne		lcResult = cPrintable(m.lcResult)

	* Encadrer la chaîne de délimiteur, échapper si nécessaire
	* return ["] + Strtran(Strtran(Iif(lTrue(m.tlTrim), Trim(m.tuData), m.tuData), '\', '\\'), ["], [\"]) + ["]
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
				, ['], [\']); && see GA_STRINGPARSE_CLASS.MaskStrings(), parameter JSstring
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

case m.lcVarType == 'O' && Objet
&& {V 1.25}
	llResult = cLitteralJS_lSupport(m.tuData, @m.lcResult)
	assert m.llResult message cAssertMsg(m.lcResult)
	if m.llResult
&& {V 1.25}

		local laProp[1], lcProp
		if amembers(laProp, m.tuData, 0, 'U') > 0 && 'U' : user-defined
			asort(laProp)
			for each lcProp in laProp
				if not pemstatus(m.tuData, m.lcProp, 2) && protected
					lcResult = m.lcResult + ',"' + lower(m.lcProp) + '":' + cLitteralJS(getpem(m.tuData, m.lcProp),, .t.) && JSON compatible
				endif
			next
		endif
		lcResult = '{' + substr(m.lcResult, 2) + '}'
	else
		lcResult = space(0)
	endif

case m.lcVarType == 'A' && Array
	if not laEmpty(@m.tuData)
		local luElt
		for each luElt in tuData
			lcResult = m.lcResult + ', ' + cLitteralJS(m.luElt, m.tlTrim)
		next
	endif
	lcResult = '[' + substr(m.lcResult, 2) + ']'

otherwise
	assert .f. message cAssertMsg(textmerge([could not build a JavaScript constant from <<m.tuData>> of type <<m.lcVarType>>]))
endcase

return m.lcResult
endfunc

* -----------------------------------------------
function cLJS && Littéral Javascript d'après une valeur VFP && Alias (simplifié) de cLitteralJS()
lparameters ;
	tuData,; && @ Valeur à convertir en littéral ; types supportés : cf. cLitteralJS_lSupport()
	tlTrim,; && [.F.] si type C, ôter les espaces à droite
	tlJSON && [.F.] produire un littéral compatible JSON

return cLitteralJS(@m.tuData, m.tlTrim, m.tlJSON)
endfunc

* -----------------------------------------------
function cLitteralJS_lSupport && Une données est supportée pour conversion en littéral Javascript
lparameters ;
	tuData,; && Donnée à analyser
	tcResult && @ Résultat localisé si pas supporté

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

	case type('m.tuData.Class') == 'U' && Empty class
		llResult = .t.

	case type('m.tuData.BaseClass') == 'C' and inlist(m.tuData.baseclass, 'Collection', 'Control', 'Olecontrol') && unsupported foxpro class
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
procedure cLitteralJS_Test && cLitteralJS() unit test

local loTest as abUnitTest of abDev.prg;
, loAsserts as abSet of abDev.prg;
, luData as Variant

loTest = abUnitTest()
loAsserts = abSet('ASSERTS', 'OFF') && 'ON'

loTest.Test('4', 4)

loTest.Test(space(0), createobject('Collection'))

loTest.Test(space(0), createobject('Excel.Application'))

luData = createobject('Custom')
m.luData.addproperty('car', 'a')
m.luData.addproperty('num', 2)
m.luData.addproperty('date', date(2012,06,20))
loTest.Test('{"CAR":"a","DATE":"2012-06-20T00:00:00Z","NUM":2}', m.luData)

return m.loTest.Result()

* ===================================================================
function uEmpty && Valeur vide selon les différents Type()
lparameters ;
	tuType,; && Type de valeur, ou valeur si m.tlValue
	tlValue && [.F.] tuType contient une valeur
tlValue = lTrue(m.tlValue)

#if .f. && Types supportés
A	array (only returned when the optional 1 parameter is included)
Ã¼	B	double
Ã¼	C	character, varchar, varchar (Binary)
Ã¼	D	date
Ã¼	f	float
G	general
Ã¼	I	integer
Ã¼	L	Logical
Ã¼	M	memo
Ã¼	n	Numeric, float, double, or integer
O	object
Ã¼	Q	varbinary
s	screen
Ã¼	t	datetime
U	Undefined type of expression or cannot evaluate expression.
Ã¼	V	varchar
Ã¼	W	blob
Ã¼	y	currency
#endif

local lcType, llResult, luResult
luResult = .null.

if m.tlValue
	lcType = vartype(m.tuType)
	llResult = .t.
else
	if vartype(m.tuType) == 'C' and len(m.tuType) = 1
		lcType = upper(m.tuType)
		llResult = m.lcType $ 'BCDFILMNTVQWY' && 13 types
	endif
	assert m.llResult message cAssertMsg(textmerge("Spécification de type non supportée : <<cLitteral(m.tuType)>>"))
endif
if m.llResult

	luResult = icase(.f., null;
		, m.lcType $ 'CMV', space(iif(m.tlValue, lenc(m.tuType), 0));
		, m.lcType $ 'BFNYI', iif(m.tlValue, m.tuType * 0, iif(m.lcType == 'Y', $0, 0));
		, m.lcType $ 'D', ctod('');
		, m.lcType $ 'T', ctot('');
		, m.lcType $ 'L', .f.;
		, m.lcType $ 'QW', 0H; && Blob, Varbinary
		, .null.)
endif

return m.luResult

* ===================================================================
function cLitteralNum && Littéral numérique d'après une chaine de caractères représentant un nombre
lparameters ;
	tcNum,; && Chaine de caractères supposée représenter un nombre
	tlPeriod && [.F.] séparateur décimal point (.F.: courant) [Val() veut courant, calcul et ALTER COLUMN veulent point]

local llResult, lcResult
lcResult = space(0)

* Si le paramètre est de type caractère
llResult = inlist(vartype(m.tcNum), 'C', 'X')
assert m.llResult message cAssertMsg("Paramètre de type caractère ou .NULL. attendu")
if m.llResult

	* Si le paramètre peut représenter un nombre
	llResult = lNumber(m.tcNum)
	if m.llResult

		* Supprimer les espaces et séparateurs de milliers éventuels
		local lcNum, lcSep, lcPoint
		lcNum = alltrim(m.tcNum)
		lcSep = set('Separator')
		lcPoint = set('Point')
		lcNum = iif(m.lcSep == m.lcPoint, m.lcNum, chrtran(m.lcNum, m.lcSep, space(0)))
		lcNum = chrtran(m.lcNum, space(1), space(0))

		* Lire si séparateur décimal POINT demandé
		local llPeriod
		llPeriod = iif(vartype(m.tlPeriod) == 'L', m.tlPeriod, .f.)

		* Si la chaine comporte au plus un séparateur décimal
		local llPoint, lnPoints, lnPeriods
		llPoint = m.lcPoint == '.'
		lnPoints = occurs(m.lcPoint, m.lcNum)
		lnPeriods = iif(m.llPoint, 0, occurs('.', m.lcNum))
		llResult = m.lnPoints + m.lnPeriods <= 1
		if m.llResult

			* Si le séparateur courant n'est pas le point
			if not m.llPoint

				* Ajuster le séparateur si nécessaire
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
procedure cLitteralNum_Test && teste cLitteralNum

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
function cLitteralDTStrict && Littéral Date [-Heure] selon le format VFP strict (avec le siècle)
lparameters tuDT && Date ou DateTime à convertir

local lcVarType, lcResult

lcVarType = vartype(m.tuDT)
if m.lcVarType $ 'DT' and not empty(m.tuDT)

	lcResult = '^' + 	;
			alltrim(str(year(m.tuDT)))+ '-' + ;
			padl(alltrim(str(month(m.tuDT))), 2, '0') + '-' + ;
			padl(alltrim(str(day(m.tuDT),2)), 2, '0') && Transform(Dtos(m.tuDT), '@R {^####/##/##') + '}' && Gregory Adam

	return iif(m.lcVarType = 'D';
		, '{' + m.lcResult + '}';
		, '{' + m.lcResult + space(1) + ttoc(m.tuDT, 2) + '}';
		)
else

	return iif(m.lcVarType = 'T', '{/:}', '{/}')
endif

* -----------------------------------------------------------------
procedure cLitteralDTStrict_Test && teste cLitteralDTStrict()

local loTest as abUnitTest of abDev.prg
loTest = newobject('abUnitTest', 'abDev.prg')

loTest.Test('{/}')
loTest.Test('{^2003-02-08}', date(2003,2,8))

loTest.EnvSet([SET SYSFORMATS ON])
loTest.Test('{^2003-02-08 11:34:15}', datetime(2003,2,8,11,34,15))

return loTest.Result()
endproc

* ===================================================================
function cEuroANSI && Chaine de caractères désaccentuée
lparameters tuEuropean && type C : Chaine de caractères accentuée, .T. : supprimer les variables publiques créées

local lcVarType, lcResult && Chaine de caractères désaccentuée
lcResult = space(0)

* Si le paramètre est correct
lcVarType = vartype(m.tuEuropean)
do case
case m.lcVarType == 'C' and not empty(m.tuEuropean)

 	* Si les chaines de traduction ne sont pas en mémoire, les lire
 	if not vartype(m.EuroAnsi) == 'C'
		public European, EuroAnsi && pour accélérer les appels répétés
		external file European.mem
		restore from (home() + 'european.mem') additive
	endif

	* Désaccentuer la chaine
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
loTest.Test('aaaeeeeioouu', 'àÃ¤Ã¢éèêÃ«ioÃ²ûù')
loTest.Test('AAAEEEEIOOUU', 'Ã€Ã„Ã‚ÉÃˆÃŠÃ‹IOÃ’Ã™Ã›')
loTest.Test(space(0), .t.)
loTest.Test(space(0), space(0))
loTest.Test(space(0), null)

return loTest.Result()

* ===================================================================
function cRandPW && Mot de passe aléatoire sùr selon indications Windows
lparameters ;
	tnLength,; && [14] Nombre de caractères
	tnSep && [0] Espacer par groupe tnSep caractères à partir de la droite
tnLength = iif(vartype(m.tnLength) = 'N' and m.tnLength > 0, m.tnLength, 14)

local lcCars, lnCars, lnCar, lnSep, lcResult

* Générer une suite de caractères 'aléatoires' autorisés dans les mots de passe Windows
lcCars = ;
	'abcdefghikklmnopqrstuvwxyz' + ;
	'ABCDEFGHIKKLMNOPQRSTUVWXYZ' + ;
	'0123456789$' +;
	'!#$%&*()_+-={}|[]\";' +;
	['<>?,./]
lnCars = len(m.lcCars)
lcResult = space(0)
rand(-1)

for m.lnCar = 1 to m.tnLength
	lcResult = m.lcResult + substr(m.lcCars, evl(int(rand()*m.lnCars), 1), 1)
endfor

* Si séparateurs demandés, placer
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

* ===================================================================
function lNumber && Chaine de caractères représente un nombre
lparameters tcChain && Chaine à vérifier

local llResult, lcSeps, lcChain, lnChar, lcChar

* Si la chaine est correcte
if vartype(m.tcChain) == 'C' and not empty(m.tcChain)

	lcSeps = set("Point") + set("Separator") + [ .+-] && caractères non numériques possibles

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
function lDigits && Chaine composée que de chiffres
lparameters tcChain && Chaine à vérifier

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
function nAtDigits	&& Position de la première série de chiffres dans une chaine
lparameters ;
	tcChain,; && Chaîne de caractère oû chercher la suite de chiffres
	tnChiffres,; && Longueur de la suite de chiffres à trouver
	tlIgnoreSpace,;	&& [.F.] Ignorer les espaces au sein de la suite de chiffres
	tcChiffres && @ Chaîne de chiffres trouvée en retour
local lnResult, llResult
lnResult = 0
tcChiffres = space(0)

* Si les paramètres requis sont valides
llResult = vartype(m.tcChain) == 'C' ;
 and vartype(m.tnChiffres) == 'N';
 and m.tnChiffres > 0
assert m.llResult message "Paramètres requis invalides"
if m.llResult

	* Si la chaine comporte plus de caractères que le nombre de chiffres cherché
	local lnChain
	lnChain = len(m.tcChain)
	if m.lnChain >= m.tnChiffres
		local llIgnoreSpace
		llIgnoreSpace = iif(vartype(m.tlIgnoreSpace) =='L', m.tlIgnoreSpace, .f.)

		* Pour chaque position dans la chaine
		local lnStart, lcChiffres, lnSpaces, lnCar, lcCar, llChiffre
		for m.lnStart = 1 to m.lnChain - m.tnChiffres + 1
			lcChiffres = space(0)
			lnSpaces = 0

			* Pour chaque caractère dans la limite du nombre de chiffres
			for m.lnCar = 0 to m.tnChiffres - 1
				lcCar = substr (m.tcChain, m.lnStart + m.lnCar + m.lnSpaces, 1)

				* Si le caractère est invalide, décompter
				if m.llIgnoreSpace ;
				 and m.lcCar == space(1) ;
				 and m.lnCar > 0
					lnSpaces = m.lnSpaces + 1
					lnCar = m.lnCar - 1	&& impossible de modifier la borne sup de la boucle

				* Sinon (caractère valide)
				else

					* Si le caractère est un chiffre, ajouter à la chaine de chiffres
					llChiffre = lNumChar(m.lcCar)
					if m.llChiffre
						lcChiffres = m.lcChiffres + m.lcCar

					* Sinon, abandonner la recherche
					else
						exit
					endif
				endif
			endfor

			* Si la chaine de chiffres a été trouvée, sortir
			if m.llChiffre
				exit
			endif
		endfor

		* Si la chaine de chiffres a été trouvée, mémoriser en retour
		if llChiffre
			lnResult = m.lnStart
			tcChiffres = m.lcChiffres
		endif
	endif
endif

return lnResult

* -----------------------------------------------------------------
procedure nAtDigits_Test	&& Teste nAtDigits
? sys(16)
local lcRet
lcRet = space(0)
? nAtDigits('0123456789', 3) = 1
? nAtDigits('0123456789', 3, .f., @m.lcRet) = 1 and m.lcRet == '012'
? nAtDigits('01 23456789', 3, .f., @m.lcRet) = 4 and m.lcRet == '234'
? nAtDigits('01 23456789', 3, .t., @m.lcRet) = 1 and m.lcRet == '012'
? nAtDigits('012345678 9', 10, .f., @m.lcRet) = 0 and m.lcRet == space(0)
? nAtDigits('012345678 9', 10, .t., @m.lcRet) = 1 and m.lcRet == '0123456789'
? nAtDigits('ABCDEF678 9', 4, .t., @m.lcRet) = 7 and m.lcRet == '6789'
? nAtDigits('1 2 3ABCDEF678 9', 4, .t., @m.lcRet) = 12 and m.lcRet == '6789'

* ===================================================================
function nAtSep && Position du premier séparateur en partant de la gauche
lparameter ;
	tcChain,;	&& Chaîne à analyser
	tcSeps,; && [".,:;|/\-_*#!$Â§Â£&"] Séparateurs recherchés
	tnOcc && [1] Numéro d'occurrence de séparateur recherchée
local lnResult && Position du séparateur dans la chaîne (= 0 si aucun)

lnResult = nLRAtSep ('L', m.tcChain, m.tcSeps, m.tnOcc)

return m.lnResult

* ===================================================================
function nRAtSep && Position du premier séparateur en partant de la droite
lparameter ;
	tcChain,;	&& Chaîne à analyser
	tcSeps,; && [".,:;|/\-_*#!$Â§Â£&"] Séparateurs recherchés
	tnOcc && [1] Numéro d'occurrence de séparateur recherchée
local lnResult && Position du séparateur dans la chaîne (= 0 si aucun)

lnResult = nLRAtSep ('R', m.tcChain, m.tcSeps, m.tnOcc)

return m.lnResult

* ===================================================================
function nLRAtSep && Position du premier séparateur en partant de la gauche ou de la droite
lparameter 	;
	tcSens,; && ['L'] indique s'il faut chercher en partant de la gauche (L) ou de la droite (R)
	tcChain,;	&& Chaîne à analyser
	tcSeps,; && [".,:;|/\-_*#!$Â§Â£&"] Séparateurs recherchés
	tnOcc && [1] Numéro d'occurrence de séparateur recherchée
local lnResult && Position du séparateur dans la chaîne (= 0 si aucun)
lnResult = 0

#define DEFAULT_SEP 	".,:;|/\-_*#!$Â§Â£&"

* Si une chaîne non vide a été passée
if vartype(m.tcChain) == 'C' ;
 and not empty(m.tcChain)

	* Régler les valeurs par défaut des paramètres optionnels
	local lcSens, lcSeps, lnOcc
	lcSens = iif(vartype(m.tcSens) = 'C', upper(left(ltrim(m.tcSens),1)), 'L')
	lcSens = iif(m.lcSens $ 'LR', m.lcSens, 'L')
	lcSeps = iif(vartype(m.tcSeps)='C' and ! empty(m.tcSeps), m.tcSeps, DEFAULT_SEP)
	lnOcc = iif(vartype(m.tnOcc)='N' and m.tnOcc > 0, m.tnOcc, 1)

	* Pour chaque séparateur
	local lnSep, lcSep
	for m.lnSep = 1 to len(m.lcSeps)
		lcSep = substr(m.lcSeps, m.lnSep, 1)

		* Si le séparateurs est dans le chaine, arrêter
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
function cFigures && Chiffres contenus dans une chaîne de caractères
lparameters ;
	tcChain,; && Chaîne à analyser
	tlRight && [.F.] Chercher en partant de la droite
local lcResult	&&	Chiffres extraits dans l'ordre oû ils se trouvent
lcResult = space(0)

* Si la chaine comporte des caractères
if vartype(m.tcChain)='C' ;
 and not empty(m.tcChain)

	* Calculer la longueur de la chaine
	local lcChain, lnChain
	lcChain = alltrim(m.tcChain)
	lnChain = len(m.lcChain)

	* Déterminer le sens de recherche
	local llRight, lnStart, lnEnd, lnStep
	llRight = iif(vartype(m.tlRight)=='L', m.tlRight, .f.)
	lnStart = iif(m.llRight, m.lnChain, 1)
	lnEnd = iif(m.llRight, 1, m.lnChain)
	lnStep = iif(m.llRight, -1, 1)

	* Pour chaque caractère dans l'ordre demandé
	local lnCar, lcCar
	for m.lnCar = m.lnStart to m.lnEnd step m.lnStep
		lcCar = substr(m.lcChain, m.lnCar, 1)

		* Si le caractère est un chiffre, ajouter au résultat
		if isdigit(m.lcCar)
			lcResult = iif(m.llRight, m.lcCar + m.lcResult, m.lcResult + m.lcCar)
		endif
	endfor
endif

return m.lcResult

* ===================================================================
function lNumChar	&& Chaine de caractères commence par un chiffre, un séparateur ou un opérateur
lparameters tcChain
return iif(vartype(m.tcChain)='C', ;
				isdigit(m.tcChain) or left(m.tcChain, 1) $ set('POINT') + '-+', ;
				null)

* -----------------------------------------------------------------
procedure lNumChar_Test	&& teste lNumChar
? sys(16)

? isnull(lNumChar (null))
? isnull(lNumChar (854))
? not lNumChar ('')
? not lNumChar (' ')
? not lNumChar ('toto')
? not lNumChar (' 915')
? lNumChar ('915')

local lcPoint
lcPoint = set('POINT')
set point to ','
? not lNumChar ('.915')
? lNumChar (',915')
set point to '.'
? lNumChar ('.915')
set point to (m.lcPoint)

* ===================================================================
function lEmailAddrOK && Adresse courriel valide
lparameters tcEmailAddr && Adresse courriel à valider

local lceMailAddr, lnCar, llResult

&& réécrire avec RegExp : "^([0-9a-zA-Z]+([-.=_+&])*[0-9a-zA-Z]+)*@([-0-9a-zA-Z]+[.])+[a-zA-Z]{2,6}$"

* Si l'adresse est non vide
llResult = not empty(m.tcEmailAddr)
if m.llResult
	lceMailAddr = upper(alltrim(m.tcEmailAddr))

	* Si l'adresse ne comporte que des caractères autorisés
	for m.lnCar = 1 to lenc(m.lceMailAddr)
		llResult = substr(m.lceMailAddr, m.lnCar, 1) $ "1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ@.-_"
		if not m.llResult
			exit
		endif
	endfor
	if m.llResult

		* Si l'adresse comporter un "@" un un seul
		llResult = occurs("@", m.lceMailAddr) = 1
		if m.llResult

			* Si l'adresse comporte au moins un point à droite de "@" (pour le nom de domaine)
			lnCar = atc("@", m.lceMailAddr)
			llResult = occurs('.', substr(m.lceMailAddr, m.lnCar + 1)) > 0
		endif
	endif
endif

return m.llResult

* ===================================================================
function cVFPNameSubStr && Nom VFP commençant à partir d'une position donnée dans une chaîne
lparameters ;
	tcChain,; && Chaine de caractère
	tnPos && Position du nom dans la chaîne; Si @, devient la position immédiatement après le nom trouvé
local lcResult
lcResult = space(0)

* Move until first non-space character
do while substr(m.tcChain, m.tnPos, 1) == space(1)
	tnPos = m.tnPos + 1
enddo

* Check first character is alpha or '_'
local lcChar, llChar
lcChar = substr(m.tcChain, m.tnPos, 1)
llChar = isalpha(m.lcChar) or m.lcChar == '_'

* Check following characters
do while m.llChar
	lcResult = m.lcResult + m.lcChar
	tnPos = m.tnPos + 1
	lcChar = substr(m.tcChain, m.tnPos, 1)
	llChar = isalpha(m.lcChar) or m.lcChar == '_' or isdigit(m.lcChar)
enddo

return m.lcResult

* --------------------
procedure cVFPNameSubStr_Test && teste cVFPNameSubStr()
? sys(16)
? cVFPNameSubStr('lpara tcChain', 7) == 'tcChain'
? cVFPNameSubStr('lpara tcChain', 6) == 'tcChain'
? cVFPNameSubStr('lpara 3cChain', 7) == ''
? cVFPNameSubStr('lpara _cChain', 7) == '_cChain'

* ===================================================================
function cParenth && Met une chaîne entre parenthèses ou autre signes encadrants
lparameters ;
	tcChain,; && chaine source
	tcParenth && [()] caractères d'encadement à ajouter
local llResult, lcResult && Chaine avec la référence ajoutée
lcResult = space(0)

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
	tcChain,; && {en} source string {fr} chaine source
	tuRef,; && {en} reference to append; .null. removes any existing reference {fr} Référence à ajouter ; .NULL. supprimer une référence existante éventuelle
	tlReplace,; && [.F.] {en} Replace an existing reference if any {fr} Remplacer une référence existante éventuelle
	tlNoZero,; && [.F.] {en} do not mention '0' {fr} Ne pas mentionner la valeur 0
	tcPrefix && [''] {en} prefix to the reference to be appended {fr} préfixe à la référence à ajouter

local lcResult; && Chaine avec la référence ajoutée
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
procedure cRefAppend_Test	&& Test unitaire de cRefAppend() && .060 ms - 60 Âµs

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
function lInList && Un mot se trouve dans une liste délimitée
lparameters ;
	tcWord,; && Mot à trouver
	tcList,; && Liste délimitée
	tcSep,; && [,] Séparateur de liste
	tlCase,; && [.F.] Respecter la casse
	tlExactCur && [.F.] Conserver Set("Exact") - .F. : SET EXACT ON

local laElts[1], llResult

llResult = vartype(m.tcList) == 'C' and vartype(m.tcWord) == 'C'
assert m.llResult message cAssertMsg(textmerge([la liste <<m.tcList>> et le mot <<m.tcWord>> doivent être de type caractère]))
if m.llResult

	llResult = not (empty(m.tcList) or empty(m.tcWord))
	if m.llResult

		tcSep = iif(vartype(m.tcSep) == 'C' , iif(empty(m.tcSep), m.tcSep, alltrim(m.tcSep)), ',')
*			tcSep = Iif(Lenc(m.tcSep) == 1, m.tcSep, ',')
		tlCase = lTrue(m.tlCase)
		tlExactCur = lTrue(m.tlExactCur)

		alines(laElts, m.tcList, 1, m.tcSep)
		llResult = ascan(laElts, alltrim(m.tcWord), 1, -1, 1, iif(m.tlCase, 0, 1) + iif(m.tlExactCur, 0, 2+4)) > 0
	endif
endif

return m.llResult

* ===================================================================
function cListEdit && Ajoute ou supprime un élément d'une liste sans doublon
lparameters ;
	tcList,; && Liste à éditer
	tcElts,; && Élément(s) à ajouter / supprimer
	tlRemove,; && [.F.] Supprimer le ou les élément(s)
	tcSep,; && [,] Séparateur de liste
	tlCase && [.F.] Respecter la casse

local llResult, lcResult

llResult = vartype(m.tcList) == 'C' and vartype(m.tcElts) == 'C'
assert m.llResult message cAssertMsg(textmerge([la liste <<cLitteral(m.tcList)>> et le ou les élément(s) <<cLitteral(m.tcElts)>> doivent être de type caractère]))
if m.llResult
	lcResult = m.tcList

	tlRemove = lTrue(m.tlRemove)
	tcSep = iif(vartype(m.tcSep) == 'C' and lenc(m.tcSep) == 1, m.tcSep, ',')
	tlCase = lTrue(m.tlCase)

	* Si des éléments sont spécifiés
	local array laElts[1]
*-			ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([Au moins un élément devrait être spécifié]))
	if alines(laElts, m.tcElts, 1+4, m.tcSep) > 0

		local lnItems, laItems[1], lnFlags, lcElt, lnElt, llElt

		* Tabuler la liste existante
		lnItems = alines(laItems, m.tcList, 1+4, m.tcSep)

		* Pour chaque élément
		lnFlags = iif(m.tlCase, 0, 1) + 2 + 4
		for each lcElt in laElts

			* Voir si l'élément est dans la liste
			lnElt = ascan(laItems, m.lcElt, 1, -1, 1, m.lnFlags)
			llElt = m.lnElt > 0

			* Si suppression et existe, supprimer
			if m.tlRemove
				if m.llElt
					adel(laItems, m.lnElt)
					lnItems = m.lnItems - 1
				endif

			* Sinon (ajout)
			else
				if not m.llElt
					lnItems = m.lnItems + 1
					dimension laItems[m.lnItems]
					laItems[m.lnItems] = m.lcElt
				endif
			endif
		endfor

		* Reconstituer la liste
		if m.lnItems > 0
			lcResult = cListOfArray(@m.laItems)
		endif
	endif
endif

return m.lcResult

* -----------------------------------------------------------------
procedure lInList_Test

local loTest as abUnitTest of abDev.prg, lnAtc
loTest = newobject('abUnitTest', 'abDev.prg')

loTest.Test(.t., 'dossier', 'DOSSIER, COND, SINISTRE')
loTest.Test(.f., 'dossier', 'DOSSIER, COND, SINISTRE', ';')
loTest.Test(.f., 'dossier', 'DOSSIER, COND, SINISTRE', , .t.)

return loTest.Result()

* ===================================================================
function lWordsIn && Plusieurs mots se trouvent dans une chaîne
lparameters ;
	tcWords,; && Mots à chercher
	tcChain,; && Chaine oû chercher
	tlCaseIgnore,; && [.F.] Ignorer la casse
	tlAnyWord,; && [.F.] Traiter le mot même s'il comporte des caractère de séparation
	tnAtc,; && @ [1] position de début de recherche, en retour, position trouvée, 0 si pas trouvé
	tlOr && [.F.] Trouver au moins un des mots
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
function lWordIn && Un mot se trouve dans une chaîne
lparameters ;
	tcWord,; && Mot à chercher
	tcChain,; && Chaine oû chercher
	tlCaseIgnore,; && [.F.] Ignorer la casse
	tlAnyWord,; && [.F.] Traiter le mot même s'il comporte des caractère de séparation
	tnAtc && @ [1] position de début de recherche, en retour, position trouvée, 0 si pas trouvé

local llResult

llResult = vartype(m.tcChain) == 'C';
 and vartype(m.tcWord) == 'C';
 and not (empty(m.tcChain) or empty(m.tcWord));
 and (lTrue(m.tlAnyWord);
 		 or chrtran(m.tcWord, VFPOPSEPCARS, space(0)) == m.tcWord)
assert m.llResult message cAssertMsg(textmerge("received invalid parameters"))
if m.llResult

	tlCaseIgnore = lTrue(m.tlCaseIgnore)
	tnAtc = iif(vartype(m.tnAtc) == 'N' and m.tnAtc > 0, m.tnAtc, 1)

	* Si le mot est présent dans la chaîne à partir de la position de départ
	local lcWord, lnWord, lcChain, lnAt, lcCarAnte, lcCarPost
	lcWord = iif(m.tlCaseIgnore, upper(m.tcWord), m.tcWord)
	lnWord = len(m.lcWord)
	lcChain = substr(iif(m.tlCaseIgnore, upper(m.tcChain), m.tcChain), m.tnAtc)
	tnAtc = m.tnAtc - 1 && piquets et intervalles !
	do while .t.

		lnAt = atc(m.lcWord, m.lcChain)
		llResult = m.lnAt > 0
		if m.llResult

			tnAtc = m.tnAtc + m.lnAt

			* Si le mot trouvé est encadré par un séparateur ou un opérateur
			lcCarAnte = substr(m.lcChain, m.lnAt - 1, 1)
			lcCarPost = substr(m.lcChain, m.lnAt + len(m.tcWord), 1)

			llResult = (empty(m.lcCarAnte) or m.lcCarAnte $ VFPOPSEPCARS);
						 and (empty(m.lcCarPost) or m.lcCarPost $ VFPOPSEPCARS)
			if m.llResult
				exit
			else
				lcChain = substr(m.lcChain, m.lnAt + m.lnWord)
				tnAtc = m.tnAtc + m.lnWord - 1 && piquets et intervalles !
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
function anWordIn && Positions d'un mot dans une chaîne
lparameters ;
	ta,; && @ Positions du mot
	tcChain,; && Chaine
	tcWord,; && Mot à chercher
	tlCaseIgnore,; && [.F.] Ignorer la casse
	tlAnyWord && [.F.] Traiter le mot même s'il comporte des caractère de séparation
external array ta

local lnAtc, lnResult && nombre de positions trouvées

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

local loTest as abUnitTest of abDev.prg
loTest = newobject('abUnitTest', 'abDev.prg')
local array laTest[1]

loTest.Test(1, @m.laTest, 'je+suis-décidément le meilleur', 'le')
loTest.assert(20, laTest[1])

return loTest.Result()

* ===================================================================
function lExpression(m.tcExpr) && Une chaîne est une expression (alias de lExpr())
return lExpr(m.tcExpr)

* ===================================================================
function lExpr && Une chaîne est une expression /!\ simpliste!
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
function aOperands && Opérandes d'une expression /!\ simpliste!
lparameters ;
	taOps,; && @ Opérande | position dans l'expression
	tcExp && Expression

* Si les paramètres sont valides
if type('taOps', 1) == 'A' and vartype(m.tcExp) == 'C'

	* Tabuler les opérandes
	local lcVFPOpSepCars
	lcVFPOpSepCars = VFPOPSEPCARSLIST && pour macro-substitution
	return alines(taOps, m.tcExp, 1+4, &lcVFPOpSepCars)

else
	assert .f. message cAssertMsg(textmerge([received invalid parameters]))
	return 0

endif

external array taOps

* -----------------------------------------------------------------
procedure aOperands_Test

local loTest as abUnitTest of abDev.prg, laOps[1]
loTest = newobject('abUnitTest', 'abDev.prg')

loTest.Test(4, @m.laOps, 'toto = alias.field +fonction(alias.tutu)')
*	DISPLAY MEMORY LIKE laOps
loTest.Test(5, @m.laOps, 'toto = alias.field +fonction(alias.tutu + 5)')

return loTest.Result()

* ===================================================================
function cVFPOpSepCarsList && Opérateurs et séparateurs VFP séparés par une ','
lparameters tcCarsExclude && [''] Caractères à exclure

local lcResult;
, lcCars, lnCar

lcResult = space(0)

* Lister les opérateurs et séparateurs
lcCars = chrtran(VFPOPSEPCARS, uDefault(m.tcCarsExclude, space(0)), space(0))

for lnCar = 1 to len(m.lcCars)
	lcResult = m.lcResult + ',' + ['] + substr(m.lcCars, m.lnCar, 1) + [']
endfor

return substr(m.lcResult, 2) && supprime la ',' initiale

* ===================================================================
function cFirstAlpha && Chaîne dont l'initiale est alphabétique
lparameters ;
	tcChain && Chaine
local llResult, lcResult
lcResult = space(0)

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
function cUIDRand && Identifiant probablement unique de 14 caractères
rand(-1)
return sys(2015) + transform(int(rand()*1000), '@L 9999')

* ===================================================================
function abRegExp && Objet abRegExp
lparameters ;
  tcPattern; && [''] Expression régulière de recherche
, tcFlags; && [''] commutateurs (igm)

local loResult as abRegExp of abTxt.prg

loResult = createobject('abRegExp') && # 5 ms
if vartype(m.loResult) == 'O' and ga_Type_IsChar(m.tcPattern, .t.)
	m.loResult.setup(m.tcPattern, evl(m.tcFlags, ''))
endif

return m.loResult
endfunc

* ----------------------
function abRegExp_Test

local loTest as abUnitTest of abDev.prg
loTest = newobject('abUnitTest', 'abDev.prg')
loTest.Test
return loTest.Result()

* ===================================================================
define class abRegExp as GA_LIGHTWEIGHT_CLASS && Expression régulière ; Implements VBScript.RegExp
* ===================================================================

&& RÉGLAGES - cf. this.init() / this.setup()
pattern = space(0) && Masque d'expression régulière
IgnoreCase = .f. && Ignorer la casse dans les comparaisons
global = .f. && Trouver toutes les occurrences ou la première seulement
Multiline = .f. && Le texte comporte plusieurs lignes && ^ = iif(Multiline, line start, chain start) $ = iif(Multiline, line end, chain end)

&& RÉSULTATS
nMatches = 0 && Nombre de résultats
dimension Matches[1] && [index, match, submatches (collection), length]
&& .Matches[?, 1] = index
&& .Matches[?, 2] = match
&& .Matches[?, 3] = submatches (collection)
&& .Matches[?, 4] = length

PatternMatched = '' && si this.lPatterns, pattern qui satisfait this.Test()
nPattern = 0 && nÂ° du Pattern courant, cf. this.Pattern_Assign()

&& INTERNES
protected;
		oRegExp; && AS VBScript.RegExp
	,	nSeconds; && au début de this.Execute(), Seconds(); à la fin, durée
	,	lPatterns; && Patterns multiples, cf. this.Pattern_Assign()
	,	aPattern[1]; && Patterns multiples, cf. this.Pattern_Assign()
	,	lDebug && Afficher le résultat de this.execute() à l'écran et dans la fenêtre Debug

* -----------------------------------------------------------------
protected procedure init
lparameters ;
	tlDebug,; && [.F.] Afficher le résultat de .execute() à l'écran et dans la fenêtre Debug
	tcResult && [''] @ Résultat de l'instanciation

local loException as exception, llResult

try

	this.lDebug = lTrue(m.tlDebug)

	* Si l'objet RegExp peut être créé
	this.oRegExp = createobject("VBscript.RegExp")
	llResult = vartype(m.this.oRegExp) == 'O'
	if m.llResult

		this.IgnoreCase = m.this.IgnoreCase && cf. this.IgnoreCase_assign()
		this.global = m.this.global && cf. this.Global_assign()
		this.Multiline = m.this.Multiline && cf. this.Multiline_assign()
	endif
catch to loException
	tcResult = cException(m.loException)
endtry

return m.llResult && .F. > objet non créé

* -----------------------------------------------------------------
protected function cPatterns
lparameters ;
	tcFunction,; && Fonction qui 'fabrique' les patterns ('.xx' pour une méthode de cet objet ou 'xx' pour une fonction libre)
	tcParms && Paramètres à passer à la fonction pour 'fabriquer' les Patterns

local laParm[1], lcParm, lcResult

lcResult = space(0)

if alines(laParm, m.tcParms) > 0 && cInLineCommentStripped(m.tcParms)

	tcFunction = alltrim(m.tcFunction)
	for each lcParm in laParm
		lcResult = m.lcResult + CRLF + evaluate(m.tcFunction + '(m.lcParm)')
	endfor
	lcResult = substr(m.lcResult, 3)
endif

return m.lcResult

* -----------------------------------------------------------------
hidden procedure Pattern_Assign
lparameters tcPattern && [''] Expression régulière de recherche
tcPattern = iif(vartype(m.tcPattern) == 'C', m.tcPattern, space(0))

this.lPatterns = CR $ m.tcPattern

if m.this.lPatterns
	alines(m.this.aPattern, m.tcPattern) && cInLineCommentStripped(m.tcPattern)
else
	store m.tcPattern to this.pattern, this.oRegExp.pattern
endif

* -----------------------------------------------------------------
hidden procedure IgnoreCase_Assign
lparameters tlIgnoreCase && [.F.] Ignorer la casse dans les comparaisons

if vartype(m.tlIgnoreCase) == 'L'
	store m.tlIgnoreCase to this.IgnoreCase, this.oRegExp.IgnoreCase
else
	this.tag = Cast(m.tlIgnoreCase as M)
endif

* -----------------------------------------------------------------
hidden procedure Global_Assign
lparameters tlGlobal && [.F.] Trouver toutes les occurrences ou la première seulement

if vartype(m.tlGlobal) == 'L'
	store m.tlGlobal to this.global, this.oRegExp.global
else
	this.tag = Cast(m.tlGlobal as M)
endif

* -----------------------------------------------------------------
hidden procedure Multiline_Assign
lparameters tlMultiline && [.F.] Le texte comporte plusieurs lignes

if vartype(m.tlMultiline) == 'L'
	store m.tlMultiline to this.Multiline, this.oRegExp.Multiline
else
	this.tag = Cast(m.tlMultiline as M)
endif

* -----------------------------------------------------------------
procedure clear && Efface les résultats de recherche précédents

this.nMatches = 0 && Nombre de résultats
dimension this.Matches[1]
this.Matches[1] = .f.
this.PatternMatched = ''

* -----------------------------------------------------------------
procedure setup && Règle les options de recherche
lparameters ;
  tcPattern; && [''] Expression régulière de recherche
, tuIgnoreCase; && [.F.] Ignorer la casse dans les comparaisons
, tlGlobal; && [.F.] Trouver toutes les occurrences ou la première seulement
, tlMultiline; && [.F.] Le texte comporte plusieurs lignes

local lnParms
lnParms = Pcount()

if Empty(m.lnParms)
	return .f.
else
	this.pattern = m.tcPattern

	if m.lnParms > 1

		if vartype(m.tuIgnoreCase) == 'C';
		 and Lenc(alltrim(m.tuIgnoreCase)) <= 3
			
			tuIgnoreCase = lower(m.tuIgnoreCase)
			this.IgnoreCase = 'i' $ m.tuIgnoreCase
			this.global = 'g' $ m.tuIgnoreCase
			this.Multiline = 'm' $ m.tuIgnoreCase

		else

			this.IgnoreCase = m.tuIgnoreCase

			if m.lnParms > 2
				this.global = m.tlGlobal

				if m.lnParms > 3
					this.Multiline = m.tlMultiline
				endif
			endif
		endif
	endif
endif
endproc

* -----------------------------------------------------------------
procedure Test && Teste l'expression de recherche
lparameters tcIn && Chaîne oû chercher

local llResult

with m.this as abRegExp of abTxt.prg
	.clear

	if .lPatterns
		for .nPattern = 1 to alen(.aPattern) && FOR EACH .Pattern IN .aPattern produit une erreur 1903 ('String is too long to fit')
			if .setup(.aPattern[.nPattern]) and .oRegExp.Test(m.tcIn)
				.PatternMatched = .aPattern[.nPattern]
				llResult = .t.
				* ====
				exit
				* ====
			endif
		endfor
		.lPatterns = .t. && pour reuse, .Pattern = le remet à .F.
	else
		llResult = .oRegExp.Test(m.tcIn)
	endif
endwith

return m.llResult

* -----------------------------------------------------------------
procedure Execute && Tabule les occurrences dans this.matches[]
lparameters ;
	tcIn,; && Chaîne oû chercher
	tlDebug && [.F.] Débuguer
tlDebug = lTrue(m.tlDebug)

local lnResult

with m.this as abRegExp of abTxt.prg

	.nPattern = 0
	.clear

	lnResult = iif(.lPatterns; && /!\ ne marche pas avec HIDDEN .lPatterns !
		,	.Execute_Patterns(@m.tcIn, m.tlDebug); && plusieurs patterns (exécution récursive)
		,	.Execute_Pattern(@m.tcIn, m.tlDebug); && un seul pattern (cas général)
		)

endwith

return m.lnResult

* -----------------------------------------------------------------
protected procedure Execute_Patterns && Exécute des patterns multiples
lparameters ;
	tcIn,; && Chaîne oû chercher
	tlDebug && [.F.] Débuguer

local lnPattern, laMatches[1], laResult[1], lnResult

lnResult = 0
for .nPattern = 1 to alen(.aPattern) && FOR EACH .Pattern IN .aPattern produit une erreur 1903 ('String is too long to fit')

	.pattern = .aPattern[.nPattern] && see this.Pattern_assign()

	* Si des occurrences sont trouvées
	if .Execute_Pattern(@m.tcIn, m.tlDebug) > 0

		lnResult = m.lnResult + .nMatches

		* Ajouter les occurrences au résultat final
		dimension laMatches[Alen(.Matches, 1), Alen(.Matches, 2)]
		acopy(.Matches, laMatches)
		aAppend(@m.laResult, @m.laMatches)
	endif
endfor

if lnResult > 0
	asort(laResult, 1) && dans l'ordre des positions
	dimension .Matches[m.lnResult, Alen(laResult, 2)]
	acopy(laResult, .Matches)
endif

.nMatches = lnResult
.lPatterns = .t. && pour reuse, .Pattern = le remet à .F.

return m.lnResult
endproc

* -----------------------------------------------------------------
protected procedure Execute_Pattern && Exécute un pattern unique
lparameters ;
	tcIn,; && Chaîne oû chercher
	tlDebug && [.F.] Débuguer
tlDebug = lTrue(m.tlDebug) or m.this.lDebug

.nSeconds = seconds()
.nMatches = 0 && Nombre de Résultats

if not empty(.pattern)

	local loResults, loResult, loSubMatches as collection, loSubMatch

	loResults = .oRegExp.Execute(@m.tcIn)
	if m.loResults.count > 0

		* Tabuler les résultats
		dimension .Matches[m.loResults.Count, 4] && [index, valeur, submatches, length]
		for each loResult in m.loResults && GA ne met pas la clause 'foxobject'

			* Objectifier les sub-matches
			loSubMatches = createobject('collection')
			for each loSubMatch in loResult.SubMatches
				loSubMatches.add(m.loSubMatch)
			endfor

			* Tabuler les résultats
			.nMatches = .nMatches + 1
			.Matches[.nMatches, 1] = m.loResult.firstIndex + 1 && fox strings are 1-based
			.Matches[.nMatches, 2] = m.loResult.value
			.Matches[.nMatches, 3] = m.loSubMatches
			.Matches[.nMatches, 4] = m.loResult.length
		endfor
	endif
endif

= m.tlDebug and .Execute_Debug(@m.tcIn)

return .nMatches

* -----------------------------------------------------------------
protected procedure Execute_Debug && Affiche le déboguage de l'exécution courante
lparameters tcIn && Chaîne oû chercher

local junk;
,	lcPlural;
,	lcSecond;
,	lnMatch;
,	lnSubMatches;
,	lnSubMatch;
,	lcResult

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

--- occurrence <<m.lnMatch>>/<<.nMatches>> - position <<.matches[m.lnMatch, 1])>> - longueur <<.matches[m.lnMatch, 4])>> cars
<<Strtran(cTronc(cLitteral(.matches[m.lnMatch, 2]), 200, .T.), Chr(13) + Chr(10), Chr(182) + Chr(13) + Chr(10))>>
		ENDTEXT

		lnSubMatches = .Matches[m.lnMatch, 3].count
		if m.lnSubMatches > 0
			for lnSubMatch = 1 to m.lnSubMatches
				lcResult = m.lcResult;
				 + CRLF;
				 + '>> '; && ne passe pas dans Textmerge()
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
procedure replace && Remplace
lparameters ;
	tcIn,; && Chaîne oû chercher
	tcTo && [''] Chaîne remplaçante

tcTo = iif(vartype(m.tcTo) == 'C', m.tcTo, '')

with m.this as abRegExp of abTxt.prg

	if .lPatterns

		local lcResult

		lcResult = m.tcIn
		for .nPattern = 1 to alen(.aPattern) && FOR EACH .Pattern IN .aPattern produit une erreur 1903 ('String is too long to fit')
			if .setup(.aPattern[.nPattern])
				lcResult = .replace(m.lcResult, m.tcTo)
			endif
		endfor

		.lPatterns = .t. && pour reuse, .Pattern = le remet à .F.
		return m.lcResult

	else
		return .oRegExp.replace(m.tcIn, m.tcTo)
	endif
endwith

* -----------------------------------------------------------------
procedure DebugDisplay && Affiche un résultat en mode déboguage
lparameters tcDebug

tcDebug = CRLF + evl(m.tcDebug, space(0))

? m.tcDebug
debugout m.tcDebug

* ===================================================================
enddefine && CLASS abRegExp
* ===================================================================

* ===================================================================
function cCRto && chaîne oû les sauts de ligne sont remplacés par ...
lparameters ;
	tcChain,; && Chaîne
	tcReplace && Chaîne remplaçant les sauts de ligne

return strtran(strtran(strtran(strtran(m.tcChain;
	, CRLF, m.tcReplace); && modify file abtxt.h
	, LFCR, m.tcReplace); && modify file abtxt.h
	, CR, m.tcReplace); && modify file abtxt.h
	, LF, m.tcReplace) && modify file abtxt.h

* ===================================================================
function cCR2to && chaîne oû les sauts de ligne doubles sont remplacés par ...
lparameters ;
	tcChain,; && Chaîne
	tcReplace && Chaîne remplaçant les sauts de ligne

return strtran(strtran(strtran(strtran(m.tcChain;
	, CRLF2, m.tcReplace); && modify file abtxt.h
	, LFCR2, m.tcReplace); && modify file abtxt.h
	, CR2, m.tcReplace); && modify file abtxt.h
	, LF2, m.tcReplace) && modify file abtxt.h

* ===================================================================
function cCRDel && chaîne oû les sauts de ligne sont supprimés
lparameters tcChain && Chaîne
return cCRto(m.tcChain, space(0))

* ===================================================================
function cCRSpace && chaîne oû les sauts de ligne sont remplacés par un Space(1)
lparameters tcChain && Chaîne

return cCRto(m.tcChain, space(1))

* ===================================================================
function cOuiNon(tl) && oui ou non selon logique
return iif(vartype(m.tl) $ 'LX', iif(m.tl, 'OUI', 'NON'), m.tl) && .NULL. <> .F.

* ===================================================================
function cYesNo(tl) && yes ou no selon logique
return iif(vartype(m.tl) $ 'LX', iif(m.tl, 'Yes', 'No'), m.tl) && .NULL. <> .F.

* ===================================================================
function cYes(tl) && yes ou vide selon logique
return iif(vartype(m.tl) $ 'LX', iif(m.tl, 'Yes', ''), m.tl) && .NULL. <> .F.

* ===================================================================
function cFirstProper	&& Chaîne calée à gauche avec son premier caractère en majuscule
lparameters tcChain && Chaîne à traiter

local lcResult
lcResult = ''

if vartype(m.tcChain) == 'C'
	lcResult = lower(ltrim(m.tcChain))
	lcResult = upper(left(m.lcResult, 1)) + substr(m.lcResult, 2)
endif

return m.lcResult

* ===================================================================
function cEscaped && Chaîne compatible HTTP / XML
lparameters tcChain

return iif(vartype(m.tcChain) == 'C';
	, cEscaped_Misc(cEscaped_Punc(cEscaped_Base(m.tcChain)));
	, space(0);
	)

* ===================================================================
function cEscaped_Base(tcChain) && Encode les entités ignorées par le parser XML (&<>) && Alias de cEscaped_XML()
return cEscaped_XML(m.tcChain)

* ===================================================================
function cEscaped_XML(tcChain) && Encode les entités ignorées par le parser XML (&<>)

return strtran(strtran(strtran(strtran(strtran(strtran(chrtran(m.tcChain; && http://www.w3.org/TR/2008/REC-xml-20081126/#charsets &&  	Char ::=  #x9 | #xA | #xD | [#x20-#xD7FF] | [#xE000-#xFFFD] | [#x10000-#x10FFFF]
		, NON_XML, ''); && modify file abTxt.h
		, [&], '&#38;'); && '&amp;'
		, [<], '&#60;'); && '&lt;'
		, [>], '&#62;'); && '&gt;'
		, [&#38;#38;], '&#38;'); && encoded twice
		, [&#38;#60;], '&#60;'); && encoded twice
		, [&#38;#62;], '&#62;'); && encoded twice

&& 		, '> <', '><')

* ===================================================================
function cEscaped_Punc(tcChain) && Encode les entités de ponctuation

return strtran(strtran(strtran(strtran(strtran(strtran(m.tcChain;
	, ["], '&#34;'); && '&quot;' && /!\ pb avec absiteLoc
	, ['], '&#39;'); && '&apos;' && /!\ pb avec absiteLoc
	, POINTSUSP, replicate('.', 3)); && &hellip; ne semble pas supportée
	, chr(150), '&#8211;'); && '&ndash;'
	, chr(151), '&#8212;'); && '&mdash;'
	, chr(160), '&#160;') && '&nbsp;'

* ===================================================================
function cEscaped_Misc(tcChain) && Encode les entités diverses (Â™Â€ etc.)

return strtran(strtran(strtran(m.tcChain;
	, chr(128), '&#8364;'); && '&euro;'
	, chr(153), '&#8482;'); && '&trade;'
	, chr(156), '&#339;') && '&oelig;'

* ===================================================================
function cUnescaped && Inverse de cEscaped()
lparameters tcChain

&& traiter aussi les entités !

return iif(vartype(m.tcChain) == 'C';
	, strtran(strtran(strtran(strtran(strtran(strtran(strtran(strtran(cUnescaped_Base(m.tcChain);
		, '&#34;', ["]);
		, '&#39;', [']);
		, '&#8211;', chr(150));
		, '&#8212;', chr(151));
		, '&#160;', chr(160));
		, '&#8364;', chr(128));
		, '&#8482;', chr(153));
		, '&#339;', chr(156));
	, m.tcChain)

* ===================================================================
function cUnescaped_XML(tcChain) && Inverse de cEscaped_XML()
return cUnescaped_Base(tcChain)

* ===================================================================
function cUnescaped_Base(tcChain) && Inverse de cEscaped_Base()
return iif(vartype(m.tcChain) == 'C';
	, strtran(strtran(strtran(m.tcChain;
		, '&#38;', [&]);
		, '&#60;', [<]);
		, '&#62;', [>]);
	, m.tcChain)

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
function cy && Montant en caractères dans une devise
lparameters ;
  ty; && Montant
, tcCurrency; && ['USD'] code devise selon norme ISO 4217 http://www.xe.com/iso4217.php

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
function lBotSpider && Une requête émane d'une araignée d'un moteur de recherche
lparameters tcUA && [m.Request.getBrowser()] User Agent de la requête HTTP

tcUA = iif(empty(m.tcUA) and vartype(m.Request) == 'O';
	, m.Request.getBrowser();
	, m.tcUA;
	)
if vartype(m.tcUA) == 'C' and !empty(m.tcUA)

	tcUA = lower(m.tcUA)

	return .f.; && pour placer facilement les plus fréquents en tête && http://www.botsVSbrowsers.com/
	or	'googlebot' $ m.tcUA;
	or	'west wind' $ m.tcUA; && West Wind Internet Protocols x,xx
	or	'/slurp' $ m.tcUA; && "Mozilla/5.0 (compatible; Yahoo! Slurp; http://help.yahoo.com/help/us/ysearch/slurp)" - https://help.yahoo.com/kb/search/SLN22600.html?impressions=true
	or	'/bot' $ m.tcUA;
	or	'bot/' $ m.tcUA;
	or 	' bot ' $ m.tcUA;
	or	'adsbot' $ m.tcUA; && AdsBot-Google (+http://www.google.com/adsbot.html) 15/6/15
	or	'crawl' $ m.tcUA;
	or	'spider' $ m.tcUA;
	or 	'robot' $ m.tcUA;
	or	'yahoo!+slurp' $ m.tcUA;
	or	'msnbot' $ m.tcUA;
	or	'bingbot' $ m.tcUA;
	or	'exabot' $ m.tcUA;
	or	'voilabot' $ m.tcUA;
	or 	'alexa.com' $ m.tcUA;
	or 	'ccbot' $ m.tcUA;
	or 	'catchbot' $ m.tcUA;
	or 	'proximic' $ m.tcUA;
	or 	'jooblebot' $ m.tcUA;
	or 	'linkedinbot' $ m.tcUA;
	or 	'surveybot' $ m.tcUA;
	or 	'careerbot' $ m.tcUA;
	or 	'comspybot' $ m.tcUA;
	or 	'ezooms.bot' $ m.tcUA;
	or 	'komodiabot' $ m.tcUA;
	or 	'paperlibot' $ m.tcUA;
	or 	'facebookexternalhit' $ m.tcUA;
	or 	'procogseobot' $ m.tcUA; && ProCogSEOBot
	or 	'coccoc' $ m.tcUA; && Mozilla/5.0 (compatible; coccoc/1.0; +http://help.coccoc.com/) && Coccoc bot is a web crawling bot made by Coc Coc search engine. The bot will discover new and updated pages to be added to Coc Coc search engine index. By allowing Coccoc Bot to index your website, the number of users who are able to find your content will increase and make your site more popular on the search engine. Coccoc bot supports robot exclusion standard (robots.txt)
	or 	'linkchecker' $ m.tcUA; && LinkChecker/7.4 (+http://linkchecker.sourceforge.net/)
	or 	'replazbot' $ m.tcUA; && ReplazBot
	or 	'semrushbot' $ m.tcUA; && SemrushBot
	or 	'tweetedtimes bot' $ m.tcUA; && TweetedTimes Bot
	or 	'tweetmemebot' $ m.tcUA; && TweetmemeBot
	or 	'urlappendbot' $ m.tcUA; && URLAppendBot
	or 	'wasalive-bot' $ m.tcUA; && WASALive-Bot
	or 	'yodaobot' $ m.tcUA; && YodaoBot
	or 	'aihitbot' $ m.tcUA; && aiHitBot
	or 	'discoverybot' $ m.tcUA; && discoverybot
	or 	'ltbot' $ m.tcUA; && ltbot
	or 	'news bot' $ m.tcUA; && news bot
	or 	'ncbot' $ m.tcUA; && NCBot (http://netcomber.com : tool for finding true domain owners) Queries/complaints: bot@netcomber.com
	or 	'seznambot' $ m.tcUA; && SeznamBot/3.0 (+http://fulltext.sblog.cz/)
	or 	'twitterbot' $ m.tcUA; && Twitterbot
	or 	'wotbox' $ m.tcUA; && Wotbox/2.01 (+http://www.wotbox.com/bot/) nrsbot
	or 	'nrsbot' $ m.tcUA; && nrsbot
	or 	'yandex.com' $ m.tcUA;
	or 	'python-urllib' $ m.tcUA;
	or 	'synomia' $ m.tcUA;
	or 	'gigabot' $ m.tcUA;
	or 	'ocelli' $ m.tcUA;
	or 	'dcbot.html' $ m.tcUA;
	or 	'pompos.html' $ m.tcUA;
	or 	'aipbot.com' $ m.tcUA;
	or 	'shopwiki.com' $ m.tcUA;
	or 	'ia_archiver' $ m.tcUA;
	or 	'bingbot' $ m.tcUA;
	or 	'mj12bot' $ m.tcUA;
	or 	'openisearch' $ m.tcUA;
	or 	'seekbot' $ m.tcUA;
	or 	'jyxobot' $ m.tcUA;
	or 	'biglotron' $ m.tcUA;
	or 	'psbot' $ m.tcUA;
	or 	'dumbot' $ m.tcUA;
	or 	'clicksense' $ m.tcUA;
	or 	'sondeur' $ m.tcUA;
	or 	'naverbot' $ m.tcUA;
	or 	'spyder+' $ m.tcUA;
	or 	'convera' $ m.tcUA;
	or 	'misesajour' $ m.tcUA;
	or 	'updated' $ m.tcUA;
	or 	'infoseek' $ m.tcUA;
	or 	'envolk' $ m.tcUA;
	or 	'twiceler' $ m.tcUA;
	or 	'snap.com' $ m.tcUA;
	or 	'netresearchserver' $ m.tcUA;
	or 	'gaisbot' $ m.tcUA;
	or 	'antibot' $ m.tcUA;
	or 	'lexxebot' $ m.tcUA;
	or 	'ask+jeeves' $ m.tcUA;
	or 	'dotbot' $ m.tcUA;
	or 	'chainn.com' $ m.tcUA;
	or 	'seoprofiler.com' $ m.tcUA;
	or 	'sbider' $ m.tcUA;
	or 	'soso.com' $ m.tcUA;
	or 	'antibot' $ m.tcUA;
	or 	'siteexplorer' $ m.tcUA;
	or 	'compspybot' $ m.tcUA;
	or 	'meanpathbot' $ m.tcUA;
	or 	'lipperhey' $ m.tcUA;
	or .f. && pour placer facilement les plus fréquents en tête

endif

* -------------------------------
function cChr && chaine en chr()
lparameters tc, tlHexa

local liResult, lcFormat, lcResult

lcResult = ''
if vartype(m.tc) == 'C' and len(m.tc) > 0
	lcFormat = iif(lTrue(m.tlHexa);
		, '@0'; && hexadécimal
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
function ParmsLit && paramètres en littéral
lparameters Result; && @ paramètres en littéral
 ,t01,t02,t03,t04,t05,t06,t07,t08,t09,t10,t11,t12,t13,t14,t15,t16,t17,t18,t19,t20

Result = ''
if pcount() > 1
	local I
	for I = 1 to pcount()-1
		Result = m.Result + ', ' + cLitteral(evaluate('m.t' + padl(m.I, 2, '0')))
	endfor
	Result = substr(m.Result, 3)
endif

*----------------------------------------------------
function cCRLF2fix && Chaîne oû toutes les lignes se terminent par CRLF simple
lparameters tcChain

tcChain = cCRLFfix(m.tcChain)
do while CRLF2 $ m.tcChain
	tcChain = strtran(m.tcChain, CRLF2, CRLF)
enddo

return m.tcChain

*----------------------------------------------------
function cCRLFfix && Chaîne oû toutes les lignes se terminent par CRLF
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
function cCRLFfix_ && [privée de cCRLFfix()]
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
function addFS && adds a forward Slash if none
lparameters tcChain

return trim(m.tcChain, ' ', '/') + '/'
endfunc

*----------------------------------------------------
function cStringsMasked && {fr} Chaîne oû les litteraux caractères sont masqués par _ga_StringParseBits_Class_.maskStrings()
lparameters tcChain, Result && in: .T. for JavaScript string, @out: .T. if success, else ga_StringParse_Object() instantiation result

local loParser, cResult

return iif(.t.;
		and ga_Type_IsChar(m.tcChain, .t.);
		and (.f.;
			or ga_StringParse_Object(@m.loParser); && modify command abGA
			or cResultAdd(@m.Result, GA_STRINGPARSE_CLASS + [ class instantiation failed!]);
			);
		and (!lTrue(m.Result) or varSet(@m.tcChain, strtran(strtran(m.tcChain, '\"'), "\'")));
		and varSet(@m.Result, m.loParser.maskStrings(@m.cResult, m.tcChain)); && modify command abGA
		and m.Result;
	, m.cResult;
	, m.tcChain;
	)
endfunc

* -----------------------------------------------------------------
procedure cStringsMasked_Test && cStringsMasked() unit test && 1.5 ms dev

local loTest as abUnitTest of abDev.prg
loTest = newobject('abUnitTest', 'abDev.prg')

loTest.Test([Evl(m.test, ~~~~~~~~~~~~~~~~)], [Evl(m.test, "this is a test")]) && _cliptext = Replicate('~', Len('"this is a test"'))

return loTest.Result()

* =================================
function chunked
lparameters ;
  raw; && raw text
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

cLangUser = evl(evl(m.cLangUser, cLangUser()), 'en')
cLangUser = lower(left(alltrim(m.cLangUser), 2))
cLangUser = iif('{' + m.cLangUser + '}' $ m.cTxt, m.cLangUser, 'en')

with newobject('abRegExp', 'abTxt.prg') as abRegExp of abTxt.prg

	.setup(;
		  abLocalized_cPattern1(m.cLangUser);
		, 'gmi';
		)

	cTxt = .replace(m.cTxt, ' ') && supprime les mentions des autres langues

	cLangUser = '{' + m.cLangUser + '}'
	cTxt = strtran(strtran(m.cTxt, m.cLangUser + ' '), m.cLangUser) && supprime les balises de la langue demandée

	.setup(;
		  abLocalized_cPattern2(m.cCommentStrings);
		, 'gmi';
		)
	cTxt = .replace(m.cTxt) && supprime les lignes de commentaire vides
endwith

do while replicate(CRLF, 3) $ m.cTxt
	cTxt = strtran(m.cTxt, replicate(CRLF, 3), replicate(CRLF, 2))
enddo

return m.cTxt
endfunc

* --------------------------
function abLocalized_cPattern1 && {en} localized string {fr} chaîne localisée
lparameters cLangUser && [cLangUser()] {en} user's preferred language as ISO 639-1 code {fr} langue préférée de l'utilisateur selon code ISO 639-1

&& modify command c:\test\test\regexp_clanguser.prg

&& '{' non suivi de la langue de l'utilisateur
&& puis 2 caractères alphabétiques
&& puis '}'
&& puis toute suite de caractères suivie de : '{\w\w}' ou '<' ou la fin de ligne

return '\s*{(?!' + m.cLangUser + ')\w\w}[^\u002A\r\n]+?(?=(?:{\w\w})|<|\u002A|$)'
endfunc

* --------------------------
function abLocalized_cPattern2 && {en} empty comment lines {fr} lignes de commentaire vide
lparameters cCommentStrings && ['*|&&|note'] {en} strings beginning a comment line in code source {fr} chaîne de caractère commençant une ligne de commentaires dans le code source
return '^\s*?(?:' + strtran(strtran(evl(m.cCommentStrings, '*|&'+'&|note'), '*', '\u002A'), '/', '\/') + ')\s*?$\r?\n?'
endfunc

* --------------------------
procedure abLocalized_Test && abLocalized() unit test

local loTest as abUnitTest of abDev.prg, lcTest, lcExpected
loTest = newobject('abUnitTest', 'abDev.prg')

_cliptext = ''



* test 1 ----
text to lcTest noshow
&& {en} FoxInCloud Adaptation Assistant (FAA) step 3-Publish created this program
&& {fr} L'étape 3 (Publier) de l'Assistant d'Adaptation FoxInCloud (FAA) a créé ce programme

ENDTEXT

text to lcExpected noshow
&& L'étape 3 (Publier) de l'Assistant d'Adaptation FoxInCloud (FAA) a créé ce programme

ENDTEXT

m.loTest.Test(m.lcExpected, m.lcTest, 'fr')

* test 2 ----
text to lcTest noshow
function srceCodeWindow() { /* {en} displays source code from current HTML element into a child window {fr} affiche le HTML de l'élément courant dans une fenêtre fille */
	// {en} displays source code from current HTML element into a child window {fr} affiche le HTML de l'élément courant dans une fenêtre fille
ENDTEXT

text to lcExpected noshow
function srceCodeWindow() { /* displays source code from current HTML element into a child window */
	// displays source code from current HTML element into a child window
ENDTEXT

m.loTest.Test(m.lcExpected, m.lcTest, 'en', '//')

* test 3 ----
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

* test 4 ----
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

return loTest.Result()
endproc

* -------------------------------
function cTagsStripped && Texte HTML sans balises
lparameters ;
	tcHTML,; && Texte HTML
	tcTags && [toutes] Balises à supprimer

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
function cTagStripped && Texte HTML sans une balise
lparameters ;
  tcHTML; && Texte HTML
, tcTag; && [toutes] Balise(s) à supprimer
, tlExcept; && [.F.] Sauf balises ci-dessus

tcTag = iif(vartype(m.tcTag) == 'C', upper(alltrim(m.tcTag)), '')
tlExcept = lTrue(m.tlExcept)

local lcResult;
, lnTagBeg;
, lnTagEnd;
, lcTag;
, lnOcc;

lcResult = iif(vartype(m.tcHTML) == 'C', m.tcHTML, '')

if !empty(m.lcResult)

	do while .t.

		* Si balise cherchée ouvrante,
		lnTagBeg = atcc('<' + m.tcTag, m.lcResult)
		if m.lnTagBeg > 0

			* Trouver la position de la balise fermante correspondante
			lcTag = substrc(m.lcResult, m.lnTagBeg)
			lnOcc = 1
			do while .t. && /!\ bug boucle infinie

				lnTagEnd = atcc('>', m.lcTag, m.lnOcc)
				if occurs('<', leftc(m.lcTag, m.lnTagEnd)) = m.lnOcc
					exit
				else
					lnOcc = m.lnOcc + 1
				endif
			enddo

			* Supprimer la balise
			lcTag = substrc(m.lcTag, 1, m.lnTagEnd)
			lcResult = strtran(m.lcResult, m.lcTag, '', 1, 1, 1)

			* Si balise fermante
			lcTag = '</' + m.tcTag + '>'
			if atcc(m.lcTag, m.lcResult) > 0
				lcResult = strtran(m.lcResult, m.lcTag, '', 1, 1, 1)
			endif

		* Sinon, terminé
		else
			exit
		endif
	enddo
endif

return cRepCharDel(alltrim(m.lcResult)) && Supprime les espaces répétés

* -----------------------------------------------------------------
procedure cTagStripped_Test && test unitaire cTagStripped()

local loTest as abUnitTest of abDev.prg
loTest = newobject('abUnitTest', 'abDev.prg')

loTest.Test([2 050 030], [<a href="javascript:void(0);" onmouseover="WindowOpen(event, '2 050 030', 300, 100, '<h2>Référence 2 050 030 ...</h2>');">2 050 030</a>], 'a')

return loTest.Result()
