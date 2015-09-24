* abArray.prg
* =====================================================
* (c) Abaque SARL, 66 rue Michel Ange - 75016 Paris - France
* contact@FoxInCloud.com - http://www.FoxInCloud.com/ - +33 9 53 41 90 90
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
function aChars && {fr} Tabule les caractères d'une chaîne {en} splits characters of a string into an array
lparameters ;
<<<<<<< HEAD:abarray.prg
  taResult; && @ {fr} R�sultat {en} Result
, tcString && {fr} Cha�ne � splitter {en} String to be splitted
=======
	taResult; && @ {fr} Résultat {en} Result
, tcString && {fr} Chaîne à splitter {en} String to be splitted
>>>>>>> origin/master:abArray.prg

external array taResult && pour le gestionnaire de projet

local lnResult; && nombre de lignes du Résultat
, llResult;
, lnChar

lnResult = 0

llResult = aClear(@m.taResult) and vartype(m.tcString) == 'C'
assert m.llResult message cAssertMsg(textmerge(icase(;
	cLangUser() = 'fr',	[tableau attendu en premier paramètre : <<cL(m.taResult)>>, chaîne en 2nd <<cL(m.tcString)>> !],; && copy-paste this line to add another language support
						[Array expected as 1st parameter: <<cL(m.taResult)>>, String as 2nd <<cL(m.tcString)>>!]; && Default: English
	)))
if m.llResult

	lnResult = lenc(m.tcString)
	if m.lnResult > 0

		dimension taResult[m.lnResult]
		for lnChar = 1 to m.lnResult
			taResult[m.lnChar] = substrc(m.tcString, m.lnChar, 1)
		endfor
	endif
endif

return m.lnResult

* ===================================================================
function aAppend && {fr} Ajoute les lignes d'un tableau à un autre {en} Appends line from an array to another
lparameters ;
	taDest,; && @ {fr} Résultat {en} Result
	taSrce,; && @ {fr} Source des lignes ajoutées à taDest {en} array to append to taDest
	tlUnique,; && [.F.] {fr} ne pas ajouter les lignes existantes {en} don't append lines that already exists in the target
	tlPrepend && [.F.] {fr} ajouter en début de tableau {en} append at the beginning of the array

external array taDest, taSrce && {fr} pour le gestionnaire de projet {en} for the project manager
tlUnique = lTrue(m.tlUnique)
tlPrepend = lTrue(m.tlPrepend)

local llResult, lnResult; && {fr} nombre de lignes du Résultat {en} number of lines of the array taDest
, lnRowsSrce, liRowSrce;
, lnRowsDest, liRowDest;
, lnColsSrce, llColsSrce, liColSrce;
, lnColsDest, llColsDest

lnResult = 0

* {fr} Si des tableaux ont bien été passés {en} if parameters are really array
llResult = type('taDest',1) == 'A' and type('taSrce', 1) == 'A'
assert m.llResult message cAssertMsg(icase(;
	cLangUser() = 'fr',	'Les deux paramètres taDest et taSrce doivent être des tableaux',; && copy-paste this line to add another language support
						'The type of parameters taDest and taSrce must be array'; && Default: English
	))
if m.llResult

	* {fr} Si le second tableau a des lignes {en} If second array belongs line(s)
	lnRowsSrce = iif(laEmpty(@m.taSrce) , 0, alen(taSrce, 1))
	lnRowsDest = iif(laEmpty(@m.taDest) , 0, alen(taDest, 1)) && {fr} alen(taDest,1) Fonctionne pour 1 et 2 dimensions {en} alen(taDest,1) is compatible for 1 and 2 dimensions
	lnResult = m.lnRowsDest + m.lnRowsSrce
	if m.lnRowsSrce > 0

		* {fr} Ajuster le nombre de lignes et de colonnes du Résultat {en} adjusts the number of lines and columns for the result's array
		lnColsSrce = alen(taSrce, 2)
		llColsSrce = m.lnColsSrce > 0
		lnColsDest = alen(taDest, 2) && {fr} 0 si 1 dimension {en} 0 if dimension == 1
		lnColsDest = max(m.lnColsDest, m.lnColsSrce)
		llColsDest = m.lnColsDest > 0
		if m.llColsDest
			dimension taDest[m.lnResult, m.lnColsDest]
		else
			dimension taDest[m.lnResult]
		endif
		if m.tlPrepend
			for m.liRowSrce = 1 to m.lnRowsSrce
				ains(taDest, 1) && {fr} ajoute au début du tableau {en} insert at the beginning of the array
			endfor
		endif

		* {fr} Pour chaque ligne du tableau source {en} for each line of the array
		for m.liRowSrce = 1 to m.lnRowsSrce

			liRowDest = iif(m.tlPrepend, m.liRowSrce, m.lnRowsDest + m.liRowSrce)

			do case

			case m.llColsDest and m.llColsSrce && {fr} les 2 tableaux ont 2 dimensions {en} each array has 2 dimensions
				for m.liColSrce = 1 to m.lnColsSrce
					taDest[m.liRowDest, m.liColSrce] = taSrce[m.liRowSrce, m.liColSrce]
				endfor

			case m.llColsDest && {fr} tableau destination à 2 dimensions, tableau source à 1 dimension {en} target array has 2 dimensions, source array has only one
				taDest[m.liRowDest, 1] = taSrce[m.liRowSrce]

			otherwise && {fr} les 2 tableaux ont 1 dimension {en} each array has one dimension
				taDest[m.liRowDest] = taSrce[m.liRowSrce]

			endcase
		endfor

		lnResult = iif(m.tlUnique, aDistinct(@m.taDest), m.lnResult)
	endif
endif

return m.lnResult


* --------------------------------------
procedure aAbarray_Test_a && {fr} pour construire les Array de test {en} to build the test environment
lparameters ;
	taTest,; && {fr} premier tableau {en} first array
	taTest1 && {fr} second tableau {en} second array

dimension taTest[3,3]
taTest = .f.
taTest[1,1] = 1
taTest[1,2] = 2
taTest[1,3] = 3
taTest[2,1] = 4
taTest[2,2] = 5
taTest[2,3] = 6
taTest[3,1] = 7
taTest[3,2] = 8
taTest[3,3] = 9
dimension taTest1[3,3]
taTest1 = .f.
taTest1[1,1] = "A"
taTest1[1,2] = "B"
taTest1[1,3] = "C"
taTest1[2,1] = "D"
taTest1[2,2] = "E"
taTest1[2,3] = "F"
taTest1[3,1] = "G"
taTest1[3,2] = "H"
taTest1[3,3] = "I"

* -----------------------------------------------------------------
procedure aAppend_Test && Teste aAppend()

local loUnitTest as abUnitTest of abDev.prg
loUnitTest = newobject('abUnitTest', 'abDev.prg')

public array laTest[3, 3], laTest1[3, 3] && PUBLIC pour l'examiner après test

loUnitTest.Test(6, @m.laTest, @m.laTest1)
loUnitTest.assert(6, alen(laTest, 1))

return m.loUnitTest.Result()

* ===================================================================
function aSubstract && {fr} Soustrait les éléments d'un tableau à un autre {en} remove some elements from an array to another
lparameters ;
	taDest,; && @ {fr} Résultat {en} Result
	taSrce && @ {fr} Tableau contenant les lignes à soustraire de taDest {fr} array with lines to remove from taDest
external array taDest, taSrce

local liResult, llResult, lnResult

lnResult = 0
llResult = type('taDest', 1) == 'A' and type('taSrce', 1) == 'A'
assert m.llResult message cAssertMsg(textmerge(icase(;
	cLangUser() = 'fr',	[deux tableaux attendus en paramètres],; && copy-paste this line to add another language support
						[two Arrays expected as parameters]; && Default: English
	)))

if m.llResult

	lnResult = alen(taDest)
	for liResult = m.lnResult to 1 step -1
		if ascan(taSrce, taDest[m.liResult], 1, -1, 1, 7+8) > 0 && 7: case insensitive, EXACT ON
			lnResult = m.lnResult - 1
			adel(m.taDest, m.liResult)
		endif
	endfor

	if m.lnResult = 0
		aClear(@m.taDest)
	else
		dimension taDest[m.lnResult]
	endif
endif

return m.lnResult

* -------------------------------------------------------------
procedure aSubstract_Test && Teste aSubstract()

local loUnitTest as abUnitTest of abDev.prg, laDest[1], laSrce[1]

loUnitTest = newobject('abUnitTest', 'abDev.prg')
alines(laDest, 'toto,tutu,junk,foo,bar', ',')
alines(laSrce, 'Tutu,fOo', ',')

loUnitTest.Test(3, @m.laDest, @m.laSrce)
loUnitTest.assert('toto', laDest[1])
loUnitTest.assert('junk', laDest[2])
loUnitTest.assert('bar', laDest[3])

return loUnitTest.Result()

* ===================================================================
function aFilter && {fr} Filtre les éléments d'un tableau par un autre {en} Filters the elements of an array by another array
lparameters ;
	taDest,; && @ {fr} Résultat {en} result
	taSrce,; && @ {fr} Tableau contenant les lignes filtrant taDest {en} array with lines used to filter taDest
	tlExactOff,; && [.F.] {fr} Comparer avec exact off {en} compare with exact off
	tlCase,; && [.F.] {fr} Comparer en respectant la casse {en} case-sensitive comparison
	tlExclude && [.F.] {fr} Garder les éléments destination absents de la source {en} Keep destination elements that can't be found in source

external array taDest, taSrce

local lnResult as integer; && dimension du tableau résultat
, llResult as Boolean;
, liDest, luDest;
, lnSrce, liSrce;
, liCompare

lnResult = 0

llResult = .t.;
	and type('taDest', 1) == 'A';
	and alen(taDest, 2) <= 1;
	and type('taSrce', 1) == 'A';
	and alen(taSrce, 2) <= 1
assert m.llResult message cAssertMsg(textmerge(icase(;
	cLangUser() = 'fr',	[deux tableaux à une dimension attendus en 1er et 2ème paramètres],; && copy-paste this line to add another language support
											[two one-dimensional Arrays expected as parameters #1 and 2]; && Default: English
	)))

if m.llResult

	lnResult = alen(taDest)
	lnSrce = alen(taSrce)
	liCompare = 0;
		+ iif(lTrue(m.tlCase), 0, 1);
		+ iif(lTrue(m.tlExactOff), 0, 2) + 4 && override SET EXACT setting
	tlExclude = lTrue(m.tlExclude)

	for liDest = m.lnResult to 1 step -1

		luDest = taDest[m.liDest]
		luDest = ascan(taSrce, m.luDest, 1, -1, 1, m.liCompare)
		if iif(m.tlExclude, m.luDest > 0, m.luDest = 0)

			lnResult = m.lnResult - 1
			adel(m.taDest, m.liDest)
		endif
	endfor

	if m.lnResult = 0
		aClear(@m.taDest)
	else
		dimension taDest[m.lnResult]
	endif
endif

return m.lnResult

* -------------------------------------------------------------
procedure aFilter_Test && Teste aFilter()

local loUnitTest as abUnitTest of abDev.prg, laDest[1], laSrce[1]

loUnitTest = newobject('abUnitTest', 'abDev.prg')

alines(laDest, 'toto,tutu,junk,foo,bar', ',')
alines(laSrce, 'Tutu,fOo', ',')

loUnitTest.Test(2, @m.laDest, @m.laSrce)
loUnitTest.assert('tutu', laDest[1])
loUnitTest.assert('foo', laDest[2])

alines(laDest, 'toto,tutu,junk,foo,bar', ',')
alines(laSrce, 'Tutu,fOo', ',')

loUnitTest.Test(2, @m.laDest, @m.laSrce,,,.t.)
loUnitTest.assert('toto', laDest[1])
loUnitTest.assert('junk', laDest[2])
loUnitTest.assert('bar', laDest[3])

return loUnitTest.Result()

* ===================================================================
function laEmpty && {fr} Tableau inexistant ou vide {en} array don't exists or empty
lparameters ta && @ {fr} Tableau à vérifier {en} array to verify

return not type('ta', 1) == 'A' or ;
	alen(ta) = 1 and vartype(ta[1]) == 'L' and not ta[1]

external array ta && après RETURN pour éviter exécution

* -------------------------------------------------------------
procedure laEmpty_test

local loUnitTest as abUnitTest of abDev.prg;
, laTest[1]

loUnitTest = newobject('abUnitTest', 'abDev.prg')
loUnitTest.Test(.t., @m.laTest)

return loUnitTest.Result()

* ===================================================================
function aRowDel && {fr} Supprime PHYSIQUEMENT une ligne d'un tableau {en} remove a line from an array
lparameters ;
	taResult,; && @ {fr} Résultat {en} result
	tnRow && {fr} n° de ligne à supprimer {en} number of the line to remove
external array taResult

local llResult, lnResult && {fr} par analogie avec aDel(), 1 si la ligne est bien supprimée, 0 sinon {en} like aDel(), 1 if the line is suppressed, otherwise 0

lnResult = 0
llResult = not type('taResult[1,2]') == 'U' ; && au moins 2 colonnes
 and vartype(m.tnRow) == 'N' ;
 and m.tnRow > 0 ;
 and m.tnRow <= alen(taResult, 1)
assert m.llResult message cAssertMsg(icase(;
	cLangUser() = 'fr',	'Paramètre(s) requis incorrect(s)',; && copy-paste this line to add another language support
						'Parameters required not allowed'; && Default: English
	))
if m.llResult

	* Effacer la ligne
	adel(taResult, m.tnRow)

	* Redimensionner
	lnResult = alen(taResult, 1) - 1
	if m.lnResult = 0
		aClear(@m.taResult)
	else
		dimension taResult[m.lnResult, Alen(taResult, 2)]
	endif
endif

return m.lnResult

* ===================================================================
function aRowMove && {fr} Déplace une ligne dans un tableau {fr} move one line inside an array
lparameters ;
	taResult,; && @ {fr} Résultat {en} result
	tnFrom,; && {fr} n° de ligne à déplacer {en} number for the line to move
	tnTo && {fr} n° de ligne destination {en} number for the target line
external array taResult

local lnRow, lnCol, llCol, laResult[1], llResult

llResult = .t.;
 and type('taResult', 1) = 'A';
 and vartype(m.tnFrom) == 'N';
 and vartype(m.tnTo) == 'N';
 and not m.tnFrom = m.tnTo;
 and between(m.tnFrom, 1, alen(taResult, 1));
 and between(m.tnTo, 1, alen(taResult, 1))
assert m.llResult message cAssertMsg(icase(;
	cLangUser() = 'fr',	'Paramètre(s) requis incorrect(s)',; && copy-paste this line to add another language support
						'Parameters required not allowed'; && Default: English
	))
if m.llResult

	lnRow = alen(taResult, 1)
	lnCol = alen(taResult, 2)
	llCol = m.lnCol > 0

	llResult = iif(m.llCol;
		, acopy(taResult, laResult, aelement(taResult, m.tnFrom, 1), m.lnCol);
		, acopy(taResult, laResult, m.tnFrom, 1);
		) > 0
	assert m.llResult
	if m.llResult

		adel(taResult, m.tnFrom)
		ains(taResult, m.tnTo)

		llResult = iif(m.llCol;
			, acopy(laResult, taResult, 1, m.lnCol, aelement(taResult, m.tnTo, 1));
			, acopy(laResult, taResult, 1, 1, m.tnTo);
			) > 0
		assert m.llResult
	endif
endif

return m.llResult

* -------------------------------------------------------------
procedure aRowMove_test && Teste aRowMove()

local loUnitTest as abUnitTest of abDev.prg, laResult[1]

loUnitTest = newobject('abUnitTest', 'abDev.prg')

aRowMove_test_a1(@m.laResult)
loUnitTest.Test(.t., @m.laResult, 3, 1)
loUnitTest.assert('3', m.laResult[1])
loUnitTest.assert('1', m.laResult[2])

aRowMove_test_a1(@m.laResult)
loUnitTest.Test(.t., @m.laResult, 1, 3)
loUnitTest.assert('2', m.laResult[1])
loUnitTest.assert('1', m.laResult[3])

aRowMove_test_a2(@m.laResult)
loUnitTest.Test(.t., @m.laResult, 3, 1)
loUnitTest.assert('31', m.laResult[1, 1])
loUnitTest.assert('11', m.laResult[2, 1])

aRowMove_test_a2(@m.laResult)
loUnitTest.Test(.t., @m.laResult, 1, 3)
loUnitTest.assert('21', m.laResult[1, 1])
loUnitTest.assert('11', m.laResult[3, 1])

return loUnitTest.Result()

* -------------------------------------------------------------
	function aRowMove_test_a1 && tableau de test à 1 dimension
	lparameters laResult && @ tableau
	external array laResult

	dimension laResult[6]
	laResult[1] = '1'
	laResult[2] = '2'
	laResult[3] = '3'
	laResult[4] = '4'
	laResult[5] = '5'
	laResult[6] = '6'

* -------------------------------------------------------------
	function aRowMove_test_a2 && tableau de test à 2 dimensions
	lparameters laResult && @ tableau

	local lcResult
	text TO lcResult NOSHOW PRETEXT 1+2
		11	12
		21	22
		31	32
		41	42
		51	52
		61	62
	ENDTEXT
	aLinesCols(@m.laResult, m.lcResult)

* ===================================================================
function aColDel && {fr} Supprime physiquement une colonne d'un tableau {en} remove one column from an array
lparameters ;
	taResult,; && @ {fr} Résultat {en} Result
	tnCol && {fr} n° de colonne à supprimer {en} number of the column to remove
external array taResult

local lnRow, liRow, lnCol, llResult, lnResult && {fr} par analogie avec aDel(), 1 si la colonne est bien supprimée, 0 sinon {en} like aDel() return 1 if the column is successfull removed, otherwise 0

lnResult = 0
llResult = .t.;
	 and not type('taResult[1,2]') == 'U' ; && au moins 2 colonnes
	 and vartype(m.tnCol) == 'N' ;
	 and between(m.tnCol, 1, alen(taResult, 2))
assert m.llResult message cAssertMsg(icase(;
	cLangUser() = 'fr',	'Paramètre(s) requis incorrect(s)',; && copy-paste this line to add another language support
						'Parameters required not allowed'; && Default: English
	))
if m.llResult

	* Convertir le tableau en mono-dimensionnel
	lnRow = alen(taResult, 1)
	lnCol = alen(taResult, 2)
	dimension taResult[m.lnRow * m.lnCol]

	* Supprimer physiquement les cellules de la colonne à enlever
	for m.liRow = m.lnRow to 1 step -1
		lnResult = adel(taResult, (m.liRow - 1) * m.lnCol + m.tnCol)
		if m.lnResult = 0
			exit
		endif
	endfor

	* Rétablir le tableau en 2 dimensions
	if m.lnResult > 0
		dimension taResult[m.lnRow, m.lnCol - 1]
	endif
endif

return m.lnResult

* --------------------------------------
procedure aColDel_Test_a(laTest)

dimension laTest[2,4]
laTest = .f.
laTest[1,1] = 1
laTest[1,2] = 2
laTest[1,3] = 3
laTest[1,4] = 4
laTest[2,1] = "A"
laTest[2,2] = "B"
laTest[2,3] = "C"
laTest[2,4] = "D"

* --------------------------------------
procedure aColDel_Test_aa(laTest)

local lcTest
text TO lcTest NOSHOW PRETEXT 1+2
	11	.T.
	21	.F.	"toto"
	31	.T.	"tutu"	{^2014-01-10}
	41	.NULL.	"tutu"	{^2014-01-11}
ENDTEXT

return aLinesCols(@m.laTest, m.lcTest, TABUL, 'ILCD')

* --------------------------------------
procedure aColDel_Test

local loUnitTest as abUnitTest of abDev.prg, laTest[1]
loUnitTest = newobject('abUnitTest', 'abDev.prg')

* Supprimer la colonne de gauche
aColDel_Test_a(@m.laTest)
loUnitTest.Test(1, @m.laTest, 1)
loUnitTest.assert(alen(laTest, 2), 3)
loUnitTest.assert(laTest[1,1], 2)
loUnitTest.assert(laTest[2,1], "B")
loUnitTest.assert(laTest[1,2], 3)
loUnitTest.assert(laTest[2,2], "C")

* Supprimer une colonne interne
aColDel_Test_a(@m.laTest)
loUnitTest.Test(1, @m.laTest, 2)
loUnitTest.assert(alen(laTest, 2), 3)
loUnitTest.assert(laTest[1,1], 1)
loUnitTest.assert(laTest[2,1], "A")
loUnitTest.assert(laTest[1,2], 3)
loUnitTest.assert(laTest[2,2], "C")

* Supprimer la colonne de droite
aColDel_Test_a(@m.laTest)
loUnitTest.Test(1, @m.laTest, 4)
loUnitTest.assert(alen(laTest, 2), 3)
loUnitTest.assert(laTest[1,1], 1)
loUnitTest.assert(laTest[2,1], "A")
loUnitTest.assert(laTest[1,2], 2)
loUnitTest.assert(laTest[2,2], "B")
loUnitTest.assert(laTest[1,3], 3)
loUnitTest.assert(laTest[2,3], "C")

return loUnitTest.Result()

* ===================================================================
function aColsDel && {fr} Supprime physiquement plusieurs colonnes d'un tableau {en} remove many columns from an array
lparameters ;
	taResult,; && @ {fr} Résultat {en} Result
	tnCol1,; && {fr} n° de la première colonne à supprimer {en} index of the first column to remove
	tnCol2 && {fr} [dernière] N° de la dernière colonne à supprimer {en} [last] index of the last column to remove
external array taResult

local llResult, lnResult; && {fr} analogue à aDel() : 1 si les colonnes sont bien supprimées, 0 sinon {en} like aDel() if columns succesfull removed 1, otherwise 0
, lnCols, lnCol2, liCol

lnResult = 0

* Si les paramètres requis sont valides
llResult = not type('taResult[1,2]') == 'U' ; && {fr} au moins 2 colonnes {en} at least two columns
 and vartype(m.tnCol1) == 'N' ;
 and m.tnCol1 > 0 ;
 and m.tnCol1 <= alen(taResult, 2)
assert m.llResult message cAssertMsg(icase(;
	cLangUser() = 'fr',	'Paramètre(s) requis incorrect(s)',; && copy-paste this line to add another language support
											'Some of the required parameters are invalid'; && Default: English
	))
if m.llResult

	* Régler les paramètres optionnels à leur valeur par défaut
	lnCols = alen(taResult, 2)
	lnCol2 = iif(vartype(m.tnCol2) == 'N' and m.tnCol2 <= m.lnCols, m.tnCol2, m.lnCols)
	lnCol2 = max(m.lnCol2, m.tnCol1)

	* Si la suppression des colonnes est possible
	llResult = not (m.tnCol1 = 1 and m.lnCol2 = m.lnCols)
	assert m.llResult message cAssertMsg(icase(;
	cLangUser() = 'fr',	"Impossible de supprimer toutes les colonnes d'un tableau",; && copy-paste this line to add another language support
						'Cannot remove all columns from an array'; && Default: English
	))

	if m.llResult

	* Supprimer chaque colonne
		for m.liCol = m.lnCol2 to m.tnCol1 step -1
			lnResult = aColDel(@m.taResult, m.liCol)
			if m.lnResult = 0
				exit
			endif
		endfor
	endif
endif

return m.lnResult

* --------------------------------------
procedure aColsDel_Test
? sys(16)
local array laTest[1]

local loUnitTest as abUnitTest of abDev.prg, laTest[1]
loUnitTest = newobject('abUnitTest', 'abDev.prg')

aColDel_Test_a(@m.laTest)
loUnitTest.Test(1, @m.laTest, 2, 3)
loUnitTest.assert(alen(laTest, 2), 2)
loUnitTest.assert(laTest[1,1], 1)
loUnitTest.assert(laTest[2,1], "A")
loUnitTest.assert(laTest[1,2], 4)
loUnitTest.assert(laTest[2,2], "D")

aColDel_Test_a(@m.laTest)
loUnitTest.Test(1, @m.laTest, 3)
loUnitTest.assert(alen(laTest, 2), 2)
loUnitTest.assert(laTest[1,1], 1)
loUnitTest.assert(laTest[2,1], "A")
loUnitTest.assert(laTest[1,2], 4)
loUnitTest.assert(laTest[2,2], "D")

return loUnitTest.Result()

* ===================================================================
function aVarType && {fr} Vartypes d'après un tableau ou une liste délimitée ou non {en} Vartypes from an array or a list delimited or not
lparameters ;
	taResult,; && @ {fr} Résultat {en} Result
	tuTypes && @ {fr} (Var)types (array ou cListe) {en} (Var)types (array or cListe)
external array taResult, tuTypes

local llArray, llResult

llResult = aClear(@m.taResult)
assert m.llResult message cAssertMsg(textmerge(icase(;
	cLangUser() = 'fr',	[paramètre(s) invalides : <<cLitteral(m.taResult)>>, <<cLitteral(m.tuTypes)>>],; && copy-paste this line to add another language support
						[parameters invalids : <<cLitteral(m.taResult)>>, <<cLitteral(m.tuTypes)>>]; && Default: English
	)))

llArray = type('tuTypes', 1) == 'A'

return icase(;
			not m.llResult, 0,;
			M.llArray, min(acopy(tuTypes, taResult), 0) + alen(taResult),;
			vartype(m.tuTypes) == 'C', iif(;
				',' $ m.tuTypes or ';' $ m.tuTypes or TABUL $ m.tuTypes or '|' $ m.tuTypes;
									, alines(taResult, upper(m.tuTypes), 1+4, ',', ';', TABUL, '|'),;
				aChars(@m.taResult, upper(chrtran(m.tuTypes, space(1), space(0))))),;
			0)


* ===================================================================
function aColsIns && {fr} Insère physiquement une ou plusieurs colonne(s) dans un tableau {en} Insert one or many columns inside an array
lparameters ;
	taResult,; && @ {fr} Résultat {en} Result
	tnColBef,; && {fr} [dernière] n° de colonne APRÈS laquelle insérer la(es) nouvelle(s) colonne(s), 0 pour ajouter au début {en} [last] index of column AFTER we insert the new column(s), 0 to insert at the beginning
	tnColsIns,; && {fr} [1] Nombre de colonnes à insérer {en} [1] number of column to insert
	tuVal,; && {fr} [.F. ou uEmpty(tuTypes)] Valeur des cellules ajoutées {en} [.F. or uEmpty(tuTypes)] Value of cells to insert
	tuTypes && @ {fr} Types des colonnes (array ou liste) in 'CDGLNOQTUXYI' {en} Types of column (array or list) in 'CDGLNOQTUXYI'

local llResult, lnResult; && {fr} Nombre de colonnes après l'insersion {en} number of columns after insertion
, lnRow, liRow;
, lnCol, liCol

lnResult = 0

* Si un tableau a été passé
llResult = type('taResult', 1) == 'A'
assert m.llResult message cAssertMsg(textmerge(icase(;
	cLangUser() = 'fr',	[tableau attendu en premier paramètre : <<cLitteral(m.taResult)>> !],; && copy-paste this line to add another language support
						[array expected as the first parameter : <<cLitteral(m.taResult)>> !]; && Default: English
	)))
if m.llResult

	lnRow = alen(taResult, 1)
	lnCol = alen(taResult, 2)

	* Si tableau à une dim.
	if m.lnCol = 0

	* Convertir à 2 dimensions
		lnCol = 1
		dimension taResult[m.lnRow, m.lnCol]
	endif

	* Vérifier la validité du n° de colonne passé
	if vartype(m.tnColBef) == 'N'
		llResult = between(m.tnColBef, 0, m.lnCol)
		assert m.llResult message cAssertMsg(textmerge(icase(;
	cLangUser() = 'fr',	"<<Proper(Program())>>() - le n° de colonne <<m.tnColBef>> est hors des limites du tableau.",; && copy-paste this line to add another language support
						"<<Proper(Program())>>() - index of column <<m.tnColBef>> outside the length of array."; && Default: English
	)))
	else
		tnColBef = m.lnCol && {fr} après la dernière colonne {en} after the last column
	endif
endif

if m.llResult

	tnColsIns = iif(vartype(m.tnColsIns) == 'N' and m.tnColsIns > 0, m.tnColsIns, 1)
	lnResult = m.lnCol + m.tnColsIns

	* Créer un tableau de travail
	local laTemp[m.lnRow, m.lnResult];
	,	laType[1], lnType;
	, llColBeg, lnColIns, llColIns, llColInsTyped

	* Voir si le typage est demandé
	lnType = aVarType(@m.laType, @m.tuTypes)

	* Remplir le tableau de travail
	for m.liCol = 1 to m.lnResult

		llColBeg = m.liCol <= m.tnColBef

		lnColIns = m.liCol - m.tnColBef
		llColIns = between(m.lnColIns, 1, m.tnColsIns)
		llColInsTyped = m.llColIns and m.lnColIns <= m.lnType

		for m.liRow = 1 to m.lnRow

			laTemp[m.liRow, m.liCol] = icase(;
				M.llColBeg, taResult[m.liRow, m.liCol],; && {fr} avant la(es) nouvelle(s) colonne(s) {en} before new column(s)
				m.llColIns; && {fr} nouvelle(s) colonne(s) {en} new column(s)
							, iif(m.llColInsTyped;
									, uEmpty(laType[m.lnColIns]);
									, m.tuVal;
							),;
				taResult[m.liRow, m.liCol - m.tnColsIns]; && {fr} après la(es) nouvelle(s) colonne(s) {en} after new column(s)
				)
		endfor
	endfor

	* Copier le tableau de travail dans le résultat
	dimension taResult[m.lnRow, m.lnResult]
	acopy(laTemp, taResult) && contrairement à ce que dit la doc, ne dimensionne pas correctement taResult
endif

return m.lnResult

* --------------------------------------
procedure aColsIns_Test && Teste aColsIns()

local loUnitTest as abUnitTest of abDev.prg, laTest[1]
loUnitTest = newobject('abUnitTest', 'abDev.prg')

&& TABLEAU À UNE DIMENSION

aColsIns_Test_a(@m.laTest, 3)
	loUnitTest.Test(3, @m.laTest, 0, 2) && 2 colonnes au début
	loUnitTest.assert(.f., laTest[3,1]) && 1ère colonne insérée
	loUnitTest.assert(2, laTest[2,3]) && La colonne initiale est maintenant # 3

&& TABLEAU À DEUX DIMENSIONS

&& ajout au début
aColsIns_Test_a(@m.laTest, 2, 3)
	loUnitTest.Test(5, @m.laTest, 0, 2) && 2 colonnes au début (1,2)
	loUnitTest.assert(6, laTest[2,5]) && donnée initiale
	loUnitTest.assert(.f., laTest[1,2]) && 2ème colonne insérée

&& ajout à l'intérieur
aColsIns_Test_a(@m.laTest, 2, 3)
	loUnitTest.Test(5, @m.laTest, 2, 2) && 2 colonnes après la 2 (3,4)
	loUnitTest.assert(6, laTest[2,5]) && donnée initiale
	loUnitTest.assert(.f., laTest[1,4]) && 2ème colonne insérée

&& ajout à la fin
aColsIns_Test_a(@m.laTest, 2, 3)
	loUnitTest.Test(5, @m.laTest, , 2) && 2 colonnes à la fin (4,5)
	loUnitTest.assert(6, laTest[2,3]) && donnée initiale
	loUnitTest.assert(.f., laTest[2,5]) && 2ème colonne insérée

&& ajout à la fin avec valeur imposée
	aColsIns_Test_a(@m.laTest, 2, 3)
		loUnitTest.Test(5, @m.laTest, , 2, 'test') && 2 colonnes à la fin (4,5)
		loUnitTest.assert(6, laTest[2,3]) && donnée initiale
		loUnitTest.assert('test', laTest[2,5]) && 2ème colonne insérée

&& ajout à la fin avec type imposé
	aColsIns_Test_a(@m.laTest, 2, 3)
		loUnitTest.Test(5, @m.laTest, , 2, , 'IC') && 2 colonnes à la fin (4,5)
		loUnitTest.assert(6, laTest[2,3]) && donnée initiale
		loUnitTest.assert('', laTest[2,5]) && 2ème colonne insérée

* --------------------------------------
	procedure aColsIns_Test_a && Initialise le tableau de test avec aElement()
	lparameters taTest, tnRows, tnCols
	external array taTest
	if empty(m.tnCols)
		dimension taTest[m.tnRows]
	else
		dimension taTest[m.tnRows, m.tnCols]
	endif
	local lnTest
	for lnTest = 1 to alen(taTest)
		taTest[m.lnTest] = m.lnTest
	endfor

* ===================================================================
function laEqual && {fr} Deux tableaux sont identiques {en} Two arrays are equals
lparameters ;
	ta1,; && @ {fr} tableau 1 {en} array 1
	ta2,; && @ {fr} tableau 2 {en} array 2
	tlCase,; && {fr} [.F.] Si élements de type caractère, ignorer la casse, les diacritiques et les espaces de fin {en} If type 'C', case insensitive and ending spaces are ignored
	taDelta && @ {fr} tableau différentiel {en} array of differences
tlCase = lTrue(m.tlCase)
external array ta1, ta2, taDelta

local llParms, lnElt1, lnElt2, lnCol1, lnCol2, liElt, luElt1, luElt2, llElt;
, lcType, llDelta, lnDelta, liDelta;
, llResult && {fr} Tableaux identiques {en} same arrays

* Si deux tableaux ont bien été passés
llParms = type('ta1', 1) == 'A' and type('ta2', 1) == 'A'
assert m.llParms message cAssertMsg(textmerge(icase(;
	cLangUser() = 'fr',	[<<Proper(Program())>>() - Deux tableaux attendus: <<ta1>> | <<ta2>>],; && copy-paste this line to add another language support
						[<<Proper(Program())>>() - Two arrays expected: <<ta1>> | <<ta2>>]; && Default: English
	)))

if m.llParms

	llDelta = aClear(@m.taDelta)
	lnElt1 = alen(ta1)
	lnElt2 = alen(ta2)
	if m.lnElt1 = m.lnElt2 or m.llDelta

		* Pour chaque élément
		lnDelta = 0
		lnCol1 = alen(m.ta1, 2)
		lnCol2 = alen(m.ta2, 2)
		llResult = .t.
		for liElt = 1 to max(m.lnElt1, m.lnElt2)

			luElt1 = iif(m.liElt <= m.lnElt1, ta1[m.liElt], .null.)
			luElt2 = iif(m.liElt <= m.lnElt2, ta2[m.liElt], .null.)
			lcType = vartype(m.luElt1)
			llElt = m.lcType == vartype(m.luElt2); && {fr} éléments de même type {en} same type element
				 and iif(m.lcType = 'C' and m.tlCase;
						, upper(cEuroAnsi(rtrim(m.luElt1))) == upper(cEuroAnsi(rtrim(m.luElt2)));
						, luEqual(m.luElt1, m.luElt2);
						)
			llResult = m.llResult and m.llElt
			if not m.llElt && {fr} élements différents {en} type element not similar

				if m.llDelta
					lnDelta = m.lnDelta + 1
					dimension taDelta[m.lnDelta, Evl(m.lnCol1, 1) + Evl(m.lnCol2, 1)]
					liDelta = iif(m.liElt <= m.lnElt1;
						, iif(m.lnCol1 > 0, asubscript(m.ta1, m.liElt, 2), 1);
						, iif(m.lnCol2 > 0, asubscript(m.ta2, m.liElt, 2), 1);
						)
					taDelta[m.lnDelta, m.liDelta] = m.luElt1
					taDelta[m.lnDelta, Evl(m.lnCol1, 1) + m.liDelta] = m.luElt2
				else
					exit
				endif
			endif
		endfor
	endif
endif

return m.llResult

* -------------------------------------------------------------
procedure laEqual_test

local loUnitTest as abUnitTest of abDev.prg
loUnitTest = newobject('abUnitTest', 'abDev.prg')

local array la1[5], la2[5], laDelta[1]
la1[1] = 'tete'
la1[2] = 2.5
la1[3] = .f.
la1[4] = date()
la1[5] = datetime()

la2[1] = 'Tête'
la2[2] = 2.5
la2[3] = .f.
la2[4] = date()
la2[5] = datetime()

loUnitTest.Test(.t., @m.la1, @m.la2, .t.)

loUnitTest.Test(.t., @m.la1, @m.la2, .f., @m.laDelta)
loUnitTest.assert('tete,Tête', cListOfArray(@m.laDelta,, -1))

return loUnitTest.Result()

* ===================================================================
function laOccurs && {fr} Un tableau à une dimension est une ligne d'un tableau à 2 dim. {en} an array at one dimension is a line of an array at two dimensions
lparameters ;
	ta1,; && @ {fr} tableau 1 à une dimension {en} array 1 with one dimension
	ta2,; && @ {fr} tableau 2 à deux dimensions {en} array 2 with two dimensions
	tlCase && [.F.] {fr} Élements caractère : Comparer en ignorant la casse, les diacritiques et les espaces de fin {fr} Type 'C' : compare case insensitive and don't care of the terminal spaces
external array ta1, ta2

local llResult; && {fr} La ligne existe {en} The line exists
, lnCol, liRow, laRow[1]

* Si des tableaux ont bien été passés
llResult = type('ta1', 1) == 'A'  and type('ta2', 1) = 'A'
assert m.llResult message cAssertMsg(textmerge(icase(;
	cLangUser() = 'fr',	[<<Proper(Program())>>() - paramètre(s) invalides],; && copy-paste this line to add another language support
						[<<Proper(Program())>>() - Invalid parameters]; && Default: English
	)))
if m.llResult

	* Si le second tableau est à 2 dims et les deux tableaux ont le même nombre de colonnes
	lnCol = alen(ta2, 2)
	llResult = m.lnCol > 0 and alen(ta1) = m.lnCol
	assert m.llResult message cAssertMsg(textmerge(icase(;
	cLangUser() = 'fr',	[<<Proper(Program())>>() - Les deux tableaux doivent avoir le même nombre de colonnes],; && copy-paste this line to add another language support
						[<<Proper(Program())>>() - each array must have the same number of columns]; && Default: English
	)))
	if m.llResult

	* Pour chaque ligne du second tableau
		dimension laRow[m.lnCol]
		for liRow = 1 to alen(ta2, 1)

			* Extraire la ligne dans un tableau temporaire
			acopy(ta2, laRow, aelement(ta2, m.liRow, 1), m.lnCol)
			dimension laRow[m.lnCol] && Acopy() dimensionne laRow comme ta2

			* Si la ligne est identique au tableau 1, terminé
			llResult = laEqual(@m.laRow, @m.ta1, m.tlCase)
			if m.llResult
				exit
			endif
		endfor
	endif
endif

return m.llResult

* ===================================================================
function aDistinct && {fr} Tableau dont chaque ligne est unique {en} array where each line is unique
lparameters taResult && @ {fr} Tableau {en} array
external array taResult

local lnResult; && {fr} Nombre de lignes du tableau après dédoublonnage {en} number of lines after removing duplicates lines
, llResult;
, lnCol, liCol;
, laRow[1], liRow, liRow_;
, llDup

lnResult = 0

* Si tableau
llResult = type('taResult', 1) == 'A'
assert m.llResult message cAssertMsg(textmerge(icase(;
	cLangUser() = 'fr',	[<<Proper(Program())>>() - Tableau attendu au lieu de <<cLitteral(taResult)>>],; && copy-paste this line to add another language support
						[<<Proper(Program())>>() - Array expected instead of <<cLitteral(taResult)>>]; && Default: English
	)))
if m.llResult

	* Si plus d'une ligne
	lnResult = alen(taResult, 1)
	if m.lnResult > 1

		* Pour chaque ligne en partant de la fin
		lnCol = alen(taResult, 2)
		dimension laRow[Evl(m.lnCol, 1)]
		for liRow = m.lnResult to 2 step -1

			* Copier la ligne pour référence
			= iif(m.lnCol > 0;
				, acopy(taResult, laRow, aelement(taResult, m.liRow, 1), m.lnCol);
				, acopy(taResult, laRow, aelement(taResult, m.liRow), 1);
				)

			* Pour chaque ligne jusqu'à celle précédant celle examinée
			for liRow_ = 1 to m.liRow - 1
				if m.lnCol > 0
					llDup = .t.
					for liCol = 1 to m.lnCol
						if not taResult[m.liRow_, m.liCol] == laRow[m.liCol]
							llDup = .f.
							exit
						endif
					endfor
				else
					llDup = taResult[m.liRow_] == laRow[1]
				endif
				if m.llDup
					exit
				endif
			endfor

			* Si la ligne existe, supprimer
			if m.llDup
				adel(taResult, m.liRow)
				lnResult = m.lnResult - 1
			endif
		endfor

		* Retailler le tableau
		if m.lnCol > 0
			dimension taResult[m.lnResult, m.lnCol]
		else
			dimension taResult[m.lnResult]
		endif
	endif
endif

return m.lnResult

* -----------------------------------------------------------------
procedure aDistinct_Test && Teste aDistinct

local loUnitTest as abUnitTest of abDev.prg
loUnitTest = newobject('abUnitTest', 'abDev.prg')

public array laTest[3, 3] && PUBLIC pour l'examiner après test
laTest[1, 1] = 'toto'
laTest[1, 2] = 3
laTest[1, 3] = .t.

laTest[2, 1] = 'TOTO'
laTest[2, 2] = 3
laTest[2, 3] = .t.

laTest[3, 1] = 'toto'
laTest[3, 2] = 3
laTest[3, 3] = .t.

loUnitTest.Test(2, @m.laTest)

return m.loUnitTest.Result()

* ===================================================================
function aLookup && {fr} Valeur d'une colonne d'un tableau selon une clé cherchée dans une autre colonne {en} Value found in an array column based on a key sought in another column
lparameters ;
	taSrce,; && @ {fr} Tableau source {en} Array source
	tuVal,; && {fr} Valeur à trouver {en} Value to find
	tnColIn,; && {fr} Colonne où chercher {en} Column where is the key
	tnColOut,; && {fr}Colonne où trouver {en} Column where is the value
	tnFlags && [15] {fr} nFlags selon options de aScan() {en} nFlags as in aScan()
external array taSrce
tnFlags = iif(vartype(m.tnFlags) == 'N' and between(m.tnFlags, 0, 15), m.tnFlags, 15)

local luResult; && {en} Value found {fr} Valeur trouvée
, llResult;
, liResult;

luResult = .null. && {en} if value not found in array {fr} Si valeur pas trouvée dans le tableau

llResult = type('taSrce', 1) == 'A';
 and vartype(m.tnColIn) == 'N';
 and between(m.tnColIn, 1, alen(taSrce, 2));
 and vartype(m.tnColOut) == 'N';
 and between(m.tnColOut, 1, alen(taSrce, 2));
 and not m.tnColIn = m.tnColOut
assert m.llResult message cAssertMsg(textmerge(icase(;
	cLangUser() = 'fr',	"Au moins un paramètre invalide",; && copy-paste this line to add another language support
											"At least one parameter is not conform"; && Default: English
	)))
if m.llResult
	liResult = ascan(taSrce, m.tuVal, 1, -1, m.tnColIn, m.tnFlags)
	luResult = iif(m.liResult > 0;
		, taSrce[m.liResult, m.tnColOut];
		, m.luResult;
		)
endif

return m.luResult

* ===================================================================
function aSelect && {fr} Lignes d'un tableau selon une clé {en} Lines from an array conform to a key
lparameters ;
	taSrce,; && @ {fr} Tableau source {en} Array source
	taDest,; && @ {fr} Tableau destination {en} Array target
	tnCol,; && {fr} Colonne où chercher {en} Column where to find
	tuVal,; && {fr} Valeur à trouver {en} Value to search
	tnFlags && [15] {fr} nFlags selon options de aScan() {en} nFlags as in aScan()
external array taSrce, taDest
tnFlags = iif(vartype(m.tnFlags) == 'N' and between(m.tnFlags, 0, 15), m.tnFlags, 15)

local liResult, llResult, lnResult && {fr} Nombre de lignes trouvées {en} Number of lines found
lnResult = 0

llResult = type('taSrce', 1) == 'A';
 and type('taDest', 1) == 'A';
 and vartype(m.tnCol) == 'N';
 and between(m.tnCol, 1, alen(taSrce, 2))
assert m.llResult message cAssertMsg(textmerge(icase(;
	cLangUser() = 'fr',	"<<Proper(Program())>>() - Au moins un paramètre invalide",; && copy-paste this line to add another language support
						"<<Proper(Program())>>() - At least one parameter is not conform"; && Default: English
	)))
if m.llResult

	* Si la valeur existe
	liResult = ascan(taSrce, m.tuVal, 1, -1, m.tnCol, m.tnFlags)
	if m.liResult > 0

		aClear(@m.taDest)

		do while liResult > 0
			aRowCopyIns(@m.taDest, @m.taSrce,, m.liResult)
			lnResult = m.lnResult + 1
			liResult = ascan(taSrce, m.tuVal, m.liResult+1, -1, m.tnCol, m.tnFlags)
		enddo
	endif
endif

return m.lnResult

* -----------------------------------------------------------------
procedure aSelect_Test && Teste aSelect()

local loUnitTest as abUnitTest of abDev.prg
loUnitTest = newobject('abUnitTest', 'abDev.prg')

public array laSrce[1], laDest[1] && PUBLIC pour examen après test
avcxclasses(laSrce, 'aw'+'.vcx') && évite d'embarquer aw.vcx dans le projet

loUnitTest.Test(2, @m.laSrce, @m.laDest, 2, 'commandbutton')

return m.loUnitTest.Result()

* ===================================================================
function aClear && {fr} Vide un tableau {en} Return an empty array
lparameters taResult && @ {fr} Tableau {en} Array

if type('taResult', 1) == 'A'
	dimension taResult[1]
	taResult[1] = .f.
	return .t.
else
	return .f.
endif

external array taResult

* -----------------------------------------------------------------
procedure aClear_test

local loUnitTest as abUnitTest of abDev.prg
loUnitTest = newobject('abUnitTest', 'abDev.prg')

local array laTest[3]
loUnitTest.Test(.t., @m.laTest)

return loUnitTest.Result()

* ===================================================================
function aRowCopyIns && {fr} Copie une ligne d'un tableau et l'insère dans un autre à une position donnée {en} Copy one line from an array and insert it in another array at a specific position
lparameters ;
	taDest,; && @ {fr} Résultat {en} Result
	taSrce,; && @ {fr} tableau source des lignes copiées dans taDest {en} array source from where one line is inserted in taDest
	tiDest,; && [dernière] {fr} N° de ligne APRÈS laquelle insérer la ligne copiée, 0 pour insérer au début {en} index of line AFTER the line is inserted
	tiSrce   && [1] {fr} n° de la ligne du tableau source à copier dans la destination {en} index of line from source array to be copied in taDest
external array taDest, taSrce

local lnCol, liCol, llResult, lnResult && {fr} nombre de lignes du tableau destination {en} number of lines of target array

lnResult = 0
llResult = type('taDest', 1) == 'A' and type('taSrce', 1) == 'A'
assert m.llResult message cAssertMsg(textmerge(icase(;
	cLangUser() = 'fr',	[les deux premiers paramètres doivent être des tableaux],; && copy-paste this line to add another language support
						[the firsts two parameters must be arrays]; && Default: English
	)))
if m.llResult

	llResult = laEmpty(@m.taDest)
	if m.llResult
		lnCol = alen(taSrce,2)
	else
		lnCol = alen(taDest,2)
		llResult = m.lnCol = alen(taSrce,2)
		assert m.llResult message cAssertMsg(textmerge(icase(;
	cLangUser() = 'fr',	[les deux tableaux doivent avoir le même nombre de colonnes],;
						[the arrays must have the same number of columns]; && Default: English
	)))
		lnResult = iif(m.llResult, alen(taDest, 1), 0)
	endif
	if m.llResult

		tiDest = iif(vartype(m.tiDest) == 'N' and between(m.tiDest, 0, m.lnResult), m.tiDest, m.lnResult) + 1 && {fr} spec aIns() : AVANT {en} aIns() : BEFORE
		tiSrce = iif(vartype(m.tiSrce) == 'N' and between(m.tiSrce, 1, alen(taSrce, 1)), m.tiSrce, 1)

		* Insérer la nouvelle ligne
		lnResult = m.lnResult + 1
		dimension taDest[m.lnResult, m.lnCol]
		ains(taDest, m.tiDest)

		* Copier les données dans la nouvelle ligne
		for liCol = 1 to m.lnCol
			taDest[m.tiDest, m.liCol] = taSrce[m.tiSrce, m.liCol]
		endfor
	endif
endif

return m.lnResult

* ===================================================================
function aAdd && {fr} Ajoute un élément à un tableau à UNE dimension {en} Add one element to an array with one dimension
lparameters ;
	taResult,; && @ {fr} Résultat {en} Result
	tuElt,; && {fr} élément à ajouter {en} element to append
	tlUnique,; && [.F.] {fr} ne pas ajouter l'élément s'il existe déjà {en} don't append it if it exists already
	tlPush && [.F.] {fr} Ajouter au début {en} Append at the beginning
external array taResult && {fr} pour le gestionnaire de projet {en} for the project manager

local llResult, lu, lnResult && {fr} nombre de lignes du Résultat {en} number of line of Result

lnResult = 0
llResult = type('taResult', 1) == 'A'
assert m.llResult message cAssertMsg(textmerge(icase(;
	cLangUser() = 'fr',	[tableau attendu en premier paramètre : <<cLitteral(m.taResult)>> !],;
						[array expected as the first parameter : <<cLitteral(m.taResult)>> !]; && Default: English
	)))
if m.llResult

	llResult = alen(taResult,2) = 0
	assert m.llResult message cAssertMsg(textmerge(icase(;
	cLangUser() = 'fr',	[tableau à une dimension attendu : <<cLitteral(m.taResult)>> !],; && copy-paste this line to add another language support
						[array with one dimension only expected : <<cLitteral(m.taResult)>> !]; && Default: English
	)))
	if m.llResult

		lnResult = alen(taResult)
		if lTrue(m.tlUnique)

			if vartype(m.tuElt) == 'O' && {fr} Ascan() ne marche pas pour les objets {en} Ascan() don't work with object
				for each lu in taResult
					llResult = not (vartype(m.lu) == 'O' and m.lu = m.tuElt)
					if not m.llResult
						exit
					endif
				endfor
			else
				llResult = ascan(taResult, m.tuElt, 1, -1, -1, 1+2+4) = 0
			endif
		endif
		if m.llResult

			lnResult = iif(laEmpty(@m.taResult), 0, m.lnResult) + 1
			dimension taResult[m.lnResult]
			if lTrue(m.tlPush)
				ains(taResult, 1)
				taResult[1] = m.tuElt
			else
				taResult[m.lnResult] = m.tuElt
			endif
		endif
	endif
endif

return m.lnResult

* ===================================================================
function aPop && {fr} Supprime le premier élément d'un tableau à UNE dimension {en} Remove the first element from an array with one dimension
lparameters taResult && @ {fr} Résultat {en} Result
external array taResult

local llResult, lnResult

lnResult = 0

llResult = type('taResult', 1) == 'A';
 and alen(taResult, 2) = 0 && une dimension
assert m.llResult message cAssertMsg(textmerge(icase(;
	cLangUser() = 'fr',	[paramètres invalides ou incomplets],; && copy-paste this line to add another language support
						[parameters not conform or unusable]; && Default: English
	)))
if m.llResult

	adel(taResult, 1)
	lnResult = alen(taResult) - 1
	if m.lnResult > 0
		dimension taResult[m.lnResult]
	else
		aClear(@m.taResult)
	endif
endif

return m.lnResult

* ===================================================================
function aPush && {fr} Ajoute un élément à la fin d'un tableau à UNE dimension {en} Append an element at the bottom of an array with dimension ONE
lparameters ;
	taResult,; && @ {fr} Résultat {en} Result
	tuElt,; && {fr} élément à ajouter {en} element to add
	tlUnique && [.F.] {fr} Ne pas ajouter l'élément au tableau s'il y est déjà {en} don't add it, if it exists already
external array taResult

local llResult, lnResult

lnResult = 0

llResult = type('taResult', 1) == 'A';
 and alen(taResult, 2) = 0; && une dimension
 and pcount() >= 2
assert m.llResult message cAssertMsg(textmerge(icase(;
	cLangUser() = 'fr',	[paramètres invalides ou incomplets],; && copy-paste this line to add another language support
						[parameters not conform or unusable]; && Default: English
	)))

if .t.;
 and m.llResult;
 and (.f.;
 		or not (lTrue(m.tlUnique));
 		or ascan(m.taResult, m.tuElt, 1, -1, 1, 5) = 0;
 		)

	lnResult = iif(laEmpty(@m.taResult), 0, alen(m.taResult)) + 1
	dimension taResult[m.lnResult]
	taResult[m.lnResult] = m.tuElt
endif

return m.lnResult

* -------------------------------------------------
procedure aPush_test

local loUnitTest as abUnitTest of abDev.prg;
, laResult[1], lnResult;
, laExpected[1], lnExpected

loUnitTest = newobject('abUnitTest', 'abDev.prg')

lnResult = aLitteral(@m.laResult, [1,'toto',1,2,'tata',2])
lnExpected = aLitteral(@m.laExpected, [1,'toto',1,2,'tata',2, .F.])
loUnitTest.Test(m.lnResult + 1, @m.laResult, .f.)
loUnitTest.assert(@m.laExpected, @m.laResult)

lnResult = aLitteral(@m.laResult, [1,'toto',1,2,'tata',2])
lnExpected = aLitteral(@m.laExpected, [1,'toto',1,2,'tata',2])
loUnitTest.Test(m.lnResult, @m.laResult, 'toto', .t.)
loUnitTest.assert(@m.laExpected, @m.laResult)

lnResult = aLitteral(@m.laResult, [1,'toto',1,2,'tata',2])
lnExpected = aLitteral(@m.laExpected, [1,'toto',1,2,'tata',2])
loUnitTest.Test(m.lnResult, @m.laResult, 1, .t.)
loUnitTest.assert(@m.laExpected, @m.laResult)

return loUnitTest.Result()

* ===================================================================
function aLocate && {fr} Cherche plusieurs valeurs dans un tableau à 2 dimensions [à la manière de LOCATE FOR] {en} Search many values inside an array with 2 dimensions like the command LOCATE FOR
lparameters ;
  taIn; && @ {fr} Tableau où chercher {en} Array where to search
, taFor; && @ {fr} Valeurs à chercher dans l'ordre des colonnes ; .NULL. pour ignorer une colonne {en} Values to search in order of columns ; .NULL. to avoid a column
, tlCaseNo; && [.F.] {fr} Chercher les valeurs caractères en ignorant la casse {en} Search characters value case insensitive
, tlExactNo; && [.F.] {fr} Chercher les valeurs caractères en EXACT OFF {en} Search characters value with SET EXACT OFF
, liColKey; && [search] {fr} colonne ou se trouve la clé {en} column where the key sits

external array taIn, taFor

local liResult as integer; && {fr} Ligne trouvée, 0 si aucune {en} Line found, 0 if nothing
, llResult as Boolean;
, lcExact  as string;
, lcExact_ as string;
, lnCol;
, liCol;
, luKey;
, lnFlags;
, liRow;

liResult = 0

llResult = .t.;
 and type('taIn', 1) == 'A';
 and type('taFor', 1) == 'A';
 and alen(m.taFor, 2) = 0; && une dimension
 and (laEmpty(@m.taIn) or alen(m.taIn, 2) >= alen(m.taFor))
assert m.llResult message cAssertMsg(textmerge(icase(;
	cLangUser() = 'fr',	[au moins un paramètre invalide],; && copy-paste this line to add another language support
											[at least one parameter is invalid]; && Default: English
	)))
if m.llResult and not laEmpty(@m.taIn)

* Si au moins une valeur à chercher est non nulle (clé)
	lnCol = alen(m.taFor)
	liColKey = cast(m.liColKey as integer)
	if between(m.liColKey, 1, m.lnCol) and !isnull(m.taFor[m.liColKey])
		luKey = m.taFor[m.liColKey]
	else
		llResult = .f.
		for liColKey = m.lnCol to 1 step -1
			luKey = m.taFor[m.liColKey]
			if !isnull(m.luKey)
				llResult = .t.
				exit
			endif
		endfor
	endif
	if m.llResult

		tlCaseNo = lTrue(m.tlCaseNo)
		lnFlags = iif(m.tlCaseNo, 1, 0) + 8

		lcExact  = set("Exact")
		lcExact_ = iif(lTrue(m.tlExactNo), 'OFF', 'ON')
		set exact &lcExact_

		liRow = 0
		llResult = .f.
		do while .t.

* Si la clé existe dans le tableau
			liRow = ascan(m.taIn, m.luKey, m.liRow + 1, -1, m.liColKey, m.lnFlags)
			if m.liRow > 0

* Si les autres valeurs sont dans la ligne
				llResult = .t.
				for liCol = 1 to m.lnCol
					if !(vartype(m.taFor[m.liCol]) == 'X'; && ignored
					 or vartype(m.taFor[m.liCol]) == vartype(m.taIn[m.liRow, m.liCol]); && m.lcType && selon coverage, plus rapide de recalculer Vartype(m.luFor) plusieurs fois que de lire une variable lcType
					  and iif(m.tlCaseNo and vartype(m.taFor[m.liCol]) == 'C';
								, upper(m.taIn[m.liRow, m.liCol]) = upper(m.taFor[m.liCol]);
								, m.taIn[m.liRow, m.liCol] = m.taFor[m.liCol];
								);
						)
						llResult = .f.
						exit
					endif
				endfor
				if m.llResult
					liResult = m.liRow
					exit
				endif
			else
				exit
			endif
		enddo
		set exact &lcExact
	endif
endif

return m.liResult
endfunc

* -------------------------------------------------------------
procedure aLocate_test

local loUnitTest as abUnitTest of abDev.prg, laIn[1], laFor[1]
loUnitTest = newobject('abUnitTest', 'abDev.prg')

aLitteral(@m.laIn, [1,'toto',1,2,'tata',2], 3)
aLitteral(@m.laFor, [2,'tata',.NULL.])

loUnitTest.Test(2, @m.laIn, @m.laFor)

aLitteral(@m.laFor, [2,'TATA',.NULL.])
loUnitTest.Test(2, @m.laIn, @m.laFor, .t.)

aLitteral(@m.laFor, [2,'TAT',.NULL.])
loUnitTest.Test(2, @m.laIn, @m.laFor, .t., .t.)

return loUnitTest.Result()

* ===================================================================
function aLitteral && {fr} Tableau d'après une liste de litteraux {en} Array from a list of strings
lparameters ;
	taResult,; && @ {fr} Résultat {en} Result
	tc,; && {fr} Constantes séparées par une ',' ou un point ',' {en} Strings delimited by coma or dot.
	tiCols && [0] {fr} Nombre de colonnes {en} Number of columns
external array taResult

local liResult, llResult, lnResult && {fr} nombre de lignes du Résultat {en} number of lines of Result

lnResult = 0

llResult = type('taResult', 1) == 'A' and vartype(m.tc) == 'C' and not empty(m.tc)
assert m.llResult message cAssertMsg(textmerge(icase(;
	cLangUser() = 'fr',	[au moins un paramètre invalide],; && copy-paste this line to add another language support
						[at least one parameter not conform]; && Default: English
	)))
if m.llResult

	lnResult = alines(taResult, m.tc, 1, ',', ';')
	for liResult = 1 to m.lnResult
		taResult[m.liResult] = evaluate(taResult[m.liResult])
	endfor

	tiCols = iif(vartype(m.tiCols) == 'N' and int(tiCols) = m.tiCols, m.tiCols, 0)
	if tiCols > 0
		lnResult = ceiling(alen(taResult) / m.tiCols)
		dimension taResult[m.lnResult, m.tiCols]
	endif
endif

return m.lnResult

* ===================================================================
function aColsDelim && {fr} Tableau à 2 dim d'après un tableau à une dimension contenant du texte délimité {en} Array with 2 dimensins from an array with one dimension containing delimited text
lparameters ;
	taRow,; && @ {fr} Tableau à traiter et résultat en retour {en} Array to use and to return
	tcSeps,; && [,;<Chr(9)>|] {fr} Séparateur de colonnes (plus rapide en le précisant) {en} Column delimiter (faster when indicated)
	tuTypes && @ {fr} Types des colonnes (array ou liste) in 'CDGLNOQTUXYI' - les colonnes non précisées restent en caractères {en} Columns type (array or list) in 'CDGLNOQTUXYI' - when not indicated stay in character
external array taRow, tuTypes

local lnResult; && {fr} nombre de lignes {en} number of lines
, llResult;
, laSep[1], lcSep, llSep;
,	laRow[1], liRow, lcRow;
,	laCol[1], liCol, lnCol;
,	laType[1], lnType, llType

llResult = not laEmpty(@m.taRow) and alen(taRow,2) <= 1
assert m.llResult message cAssertMsg(textmerge(icase(;
	cLangUser() = 'fr',	[le premier paramètre doit être un tableau à une dimension non vide : <<cLitteral(@m.taRow)>>],; && copy-paste this line to add another language support
						[first parameter must be an array with one dimension and not empty : <<cLitteral(@m.taRow)>>]; && Default: English
	)))
if m.llResult

	lnResult = alen(taRow, 1)

* Tabuler les séparateurs de colonnes
	llSep = 1 = aChars(;
		  @m.laSep;
		, iif(vartype(m.tcSeps) == 'C' and lenc(m.tcSeps) > 0;
			, m.tcSeps;
			, [,;|] + TABUL;
		))

* Calculer le nombre de colonnes et le séparateur s'il est ambigu
	lnCol = 0
	lcSep = iif(m.llSep, m.tcSeps, space(0))
	for each lcRow in taRow
		lnCol = max(m.lnCol, 1 + iif(m.llSep;
							, occurs(m.lcSep, m.lcRow);
							, aColsDelim_nColsSep(m.lcRow, @m.laSep, @m.lcSep);
							))
	endfor
*		ASSERT Lenc(m.lcSep) = 1 MESSAGE cAssertMsg(Textmerge([<<Proper(Program())>>() n'a trouvé aucun séparateur, le tableau aura une seule colonne]))

* Si le typage est demandé, forcer le nombre de colonnes à la spécification de types
	lnType = aVarType(@m.laType, @m.tuTypes)
	llType = m.lnType > 0
	lnCol = max(m.lnCol, m.lnType)

* Tabuler à deux dimensions
	dimension laRow[m.lnResult, m.lnCol]
	laRow = space(0)
	for liRow = 1 to m.lnResult
		alines(laCol, taRow[m.liRow], 1, m.lcSep)
		for liCol = 1 to alen(laCol)
			laRow[m.liRow, m.liCol] = laCol[m.liCol]
		endfor
	endfor
	dimension taRow[m.lnResult, m.lnCol]
	acopy(laRow, taRow)

* Le cas échéant, typer les données
	if m.llType

		for liCol = 1 to min(m.lnCol, m.lnType)
			for liRow = 1 to m.lnResult
				taRow[m.liRow, m.liCol] = uValue(taRow[m.liRow, m.liCol], laType[m.liCol])
			endfor
		endfor
	endif
endif

return m.lnResult

* -------------------------------------------------------------
function aColsDelim_nColsSep && {fr} Nombre de colonnes et séparateur par défaut {en} Columns number and default separator
lparameters tcRow, taSep, tcSep

local lnResult;
, llResult;
, lcSep;
, lnSep;
, lcSepMax

lnResult = 0
lcSepMax = ''
for each lcSep in taSep
	lnSep = occurs(lcSep, m.tcRow)
	if m.lnSep > m.lnResult
		lnResult = m.lnSep
		lcSepMax = m.lcSep
	endif
endfor

if lenc(m.tcSep) = 0
	tcSep = m.lcSepMax
	return m.lnResult
else
	llResult = lenc(m.lcSepMax) = 0 or m.lcSepMax == m.tcSep
	assert m.llResult message cAssertMsg(textmerge(icase(;
	cLangUser() = 'fr',	[Séparateur de colonne ambigu, veuillez préciser '<<m.lcSepMax>>' ou '<<m.tcSep>>'],; && copy-paste this line to add another language support
											[Column delimiter unusable, please explain '<<m.lcSepMax>>' or '<<m.tcSep>>']; && Default: English
	)))
	return iif(m.llResult, m.lnResult, 0)
endif

external array taSep

* ===================================================================
function aLinesCols && {fr} Tableau à 2 dim d'après un texte multiligne délimité {en} Array with 2 dimensions from a delimited multiline text
lparameters ;
	taResult,; && @ {fr} Résultat {en} Result
	tcTxt,; && {fr} Texte multiligne tabulé {en} Tabulated multiline text
	tcSep,; && [,;<Chr(9)>|] {fr} Séparateur de colonnes (plus rapide en le précisant) {en} Column separator (faster when specified)
	tuTypes && {fr} Types des colonnes (array ou liste) in 'CDGLNOQTUXYI' - les colonnes non précisées restent en caractères {en} Columns type (array or list) in 'CDGLNOQTUXYI' - when not indicated stay in character
external array taResult, tuTypes

local llResult, lnResult && {fr} lignes {en} lines

llResult = aClear(@m.taResult) and vartype(m.tcTxt) == 'C' and not empty(m.tcTxt)
assert m.llResult message cAssertMsg(textmerge(icase(;
	cLangUser() = 'fr',	[Au moins un paramètre invalide],; && copy-paste this line to add another language support
											[At least one parameter is invalid]; && Default: English
	)))
if m.llResult

* Tabuler les lignes
	alines(taResult, m.tcTxt)

	return aColsDelim(@m.taResult, m.tcSep, @m.tuTypes)
else
	return 0
endif

* -------------------------------------------------------------
procedure aLinesCols_test && Teste aLinesCols()

local loUnitTest as abUnitTest of abDev.prg, laLinesCols[1], lcTxt, laType[2]
loUnitTest = newobject('abUnitTest', 'abDev.prg')
text TO lcTxt NOSHOW PRETEXT 1+2
	11	12
	21	22	23
	31	32	33	34	35
ENDTEXT

loUnitTest.Test(3, @m.laLinesCols, m.lcTxt, TABUL)
loUnitTest.assert(5, alen(laLinesCols, 2))

loUnitTest.Test(3, @m.laLinesCols, m.lcTxt, , 'N')
loUnitTest.assert(21, laLinesCols[2,1])
loUnitTest.assert('22', laLinesCols[2,2])

loUnitTest.Test(3, @m.laLinesCols, m.lcTxt, , 'N,N')
loUnitTest.assert(21, laLinesCols[2,1])
loUnitTest.assert(22, laLinesCols[2,2])

loUnitTest.Test(3, @m.laLinesCols, m.lcTxt, , 'N|N')
loUnitTest.assert(21, laLinesCols[2,1])
loUnitTest.assert(22, laLinesCols[2,2])

loUnitTest.Test(3, @m.laLinesCols, m.lcTxt, , 'II')
loUnitTest.assert(21, laLinesCols[2,1])
loUnitTest.assert(22, laLinesCols[2,2])

laType = 'I'
loUnitTest.Test(3, @m.laLinesCols, m.lcTxt, , @m.laType)
loUnitTest.assert(21, laLinesCols[2,1])
loUnitTest.assert(22, laLinesCols[2,2])

loUnitTest.Test(3, @m.laLinesCols, m.lcTxt, , replicate('I', 6))
loUnitTest.assert(21, laLinesCols[2,1])
loUnitTest.assert(22, laLinesCols[2,2])
loUnitTest.assert(0, laLinesCols[1,6]) && nombre de colonnes selon typage

return loUnitTest.Result()

* ===================================================================
function aReverse && {fr} Tableau inversé {en} Inverse array
lparameters taSrce && @ {fr} Tableau source {en} Source array
external array taSrce

if type('taSrce', 1) == 'A'

	local lnRow, liRow, lnCol, llCol, laDest[1]

	lnRow = alen(taSrce, 1)
	lnCol = alen(taSrce, 2)
	llCol = m.lnCol > 0
	if m.llCol
		dimension laDest[m.lnRow, m.lnCol]
	else
		dimension laDest[m.lnRow]
	endif
	for liRow = 1 to m.lnRow
		if m.llCol
			acopy(taSrce, laDest, aelement(taSrce, m.liRow, 1), m.lnCol, aelement(laDest, m.lnRow - m.liRow + 1, 1))
		else
			acopy(taSrce, laDest, m.liRow, 1, m.lnRow - m.liRow + 1)
		endif
	endfor
	acopy(laDest, taSrce)
	return m.lnRow
else
	return 0
endif

* ===================================================================
function aStrExtract && {fr} Occurences entre délimiteurs /!\ non imbriquées {en} Strings found between delimiters /!\ not nested
lparameters ;
	taResult,;
	tcString,;
	tcBeginDelim,; && {fr} Selon StrExtract() {en} as StrExtract()
	tcEndDelim,; && {fr} Selon StrExtract() {en} as StrExtract()
	tnFlag && {fr} Selon StrExtract() {en} as StrExtract()
external array taResult

local liResult, llFlag, lnResult

aClear(@m.taResult)
lnResult = occurs(m.tcBeginDelim, m.tcString)
if m.lnResult > 0

	tnFlag = evl(m.tnFlag, 0)
	for liResult = 1 to m.lnResult
		aPush(@m.taResult, strextract(m.tcString, m.tcBeginDelim, m.tcEndDelim, m.liResult, m.tnFlag))
	endfor
endif

return m.lnResult

* ===================================================================
function aToBase64 as Boolean
lparameters ;
	Result as string; && @ out
, aa && @ out

external array aa

local success as Boolean;
, memFile as string;
, oResult as exception

success = type('m.aa', 1) == 'A'
if m.success

	memFile = addbs(sys(2023)) + 'temp' + cast(_vfp.processid as M) + '.mem'

	try

		save to (m.memFile) all like aa
		Result = strconv(filetostr(m.memFile), 13)

		do case

		case empty(m.Result)
			success = cResultAdd(@m.Result, [])

		case !FileDel(m.memFile,,, @m.Result) && FileDelete() abandonné à cause d'un conflit avec FileDelete.exe de web connect

		endcase

	catch to oResult

		oResult = cException(m.oResult)
		success = .f.
		assert m.success message cAssertMsg(m.oResult)
		cResultAdd(@m.Result, m.oResult)

	endtry

else
	cResultAdd(@m.Result, [])
endif

return m.success

* ===================================================================
function aOfBase64 as Boolean
lparameters ;
	Result as string; && @ out
, aa; && @ out
, base64 as string

external array aa

local success as Boolean;
, memFile as string;
, oResult as exception

do case

case !type('m.aa', 1) == 'A'
	success = cResultAdd(@m.Result, [])
	assert m.success

case !ga_Type_IsChar(m.base64, .t.)
	success = cResultAdd(@m.Result, [])
	assert m.success

otherwise

	memFile = addbs(sys(2023)) + 'temp' + cast(_vfp.processid as M) + '.mem'

	try

		success = strtofile(strconv(m.base64, 14), m.memFile) > 0
		if m.success
			restore from (m.memFile) additive
			success = FileDel(m.memFile,,, @m.Result) && FileDelete() abandonné à cause d'un conflit avec FileDelete.exe de web connect
		else
			cResultAdd(@m.Result, [])
		endif

	catch to oResult

		oResult = cException(m.oResult)
		success = .f.
		assert m.success message cAssertMsg(m.oResult)
		cResultAdd(@m.Result, m.oResult)

	endtry

endcase

return m.success
endfunc
