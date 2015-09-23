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
RETURN abUnitTests()

* ===================================================================
FUNCTION aChars && {fr} Tabule les caractères d'une chaîne {en} splits characters of a string into an array
LPARAMETERS ;
	taResult,; && @ {fr} Résultat {en} Result
	tcString && {fr} Chaîne à splitter {en} String to be splitted
EXTERNAL ARRAY taResult && pour le gestionnaire de projet

LOCAL lnResult; && nombre de lignes du Résultat
, llResult;
, lnChar

lnResult = 0

llResult = aClear(@m.taResult) AND Vartype(m.tcString) == 'C'
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge(ICase(;
	cLangUser() = 'fr',	[tableau attendu en premier paramètre : <<cL(m.taResult)>>, chaîne en 2nd <<cL(m.tcString)>> !],; && copy-paste this line to add another language support
						[Array expected as 1st parameter: <<cL(m.taResult)>>, String as 2nd <<cL(m.tcString)>>!]; && Default: English
	)))
IF m.llResult

	lnResult = Lenc(m.tcString)
	IF m.lnResult > 0

		DIMENSION taResult[m.lnResult]
		FOR lnChar = 1 TO m.lnResult
			taResult[m.lnChar] = Substrc(m.tcString, m.lnChar, 1)
		ENDFOR
	ENDIF
ENDIF

RETURN m.lnResult

* ===================================================================
FUNCTION aAppend && {fr} Ajoute les lignes d'un tableau à un autre {en} Appends line from an array to another
LPARAMETERS ;
	taDest,; && @ {fr} Résultat {en} Result
	taSrce,; && @ {fr} Source des lignes ajoutées à taDest {en} array to append to taDest
	tlUnique,; && [.F.] {fr} ne pas ajouter les lignes existantes {en} don't append lines that already exists in the target
	tlPrepend && [.F.] {fr} ajouter en début de tableau {en} append at the beginning of the array
EXTERNAL ARRAY taDest, taSrce && {fr} pour le gestionnaire de projet {en} for the project manager
tlUnique = Vartype(m.tlUnique) == 'L' AND m.tlUnique
tlPrepend = Vartype(m.tlPrepend) == 'L' AND m.tlPrepend

LOCAL llResult, lnResult; && {fr} nombre de lignes du Résultat {en} number of lines of the array taDest
, lnRowsSrce, liRowSrce;
, lnRowsDest, liRowDest;
, lnColsSrce, llColsSrce, liColSrce;
, lnColsDest, llColsDest

lnResult = 0

* {fr} Si des tableaux ont bien été passés {en} if parameters are really array
llResult = Type('taDest',1) == 'A' AND Type('taSrce', 1) == 'A'
ASSERT m.llResult MESSAGE cAssertMsg(ICase(;
	cLangUser() = 'fr',	'Les deux paramètres taDest et taSrce doivent être des tableaux',; && copy-paste this line to add another language support
						'The type of parameters taDest and taSrce must be array'; && Default: English
	))



IF m.llResult

	* {fr} Si le second tableau a des lignes {en} If second array belongs line(s)
	lnRowsSrce = Iif(laEmpty(@m.taSrce) , 0, Alen(taSrce, 1))
	lnRowsDest = Iif(laEmpty(@m.taDest) , 0, Alen(taDest, 1)) && {fr} alen(taDest,1) Fonctionne pour 1 et 2 dimensions {en} alen(taDest,1) is compatible for 1 and 2 dimensions
	lnResult = m.lnRowsDest + m.lnRowsSrce
	IF m.lnRowsSrce > 0

		* {fr} Ajuster le nombre de lignes et de colonnes du Résultat {en} adjusts the number of lines and columns for the result's array
		lnColsSrce = Alen(taSrce, 2)
		llColsSrce = m.lnColsSrce > 0
		lnColsDest = Alen(taDest, 2) && {fr} 0 si 1 dimension {en} 0 if dimension == 1
		lnColsDest = Max(m.lnColsDest, m.lnColsSrce)
		llColsDest = m.lnColsDest > 0
		IF m.llColsDest
			DIMENSION taDest[m.lnResult, m.lnColsDest]
		ELSE
			DIMENSION taDest[m.lnResult]
		ENDIF
		IF m.tlPrepend
			FOR m.liRowSrce = 1 TO m.lnRowsSrce
				Ains(taDest, 1) && {fr} ajoute au début du tableau {en} insert at the beginning of the array
			ENDFOR
		ENDIF

		* {fr} Pour chaque ligne du tableau source {en} for each line of the array
		FOR m.liRowSrce = 1 TO m.lnRowsSrce

			liRowDest = Iif(m.tlPrepend, m.liRowSrce, m.lnRowsDest + m.liRowSrce)

			DO CASE

			CASE m.llColsDest AND m.llColsSrce && {fr} les 2 tableaux ont 2 dimensions {en} each array has 2 dimensions
				FOR m.liColSrce = 1 TO m.lnColsSrce
					taDest[m.liRowDest, m.liColSrce] = taSrce[m.liRowSrce, m.liColSrce]
				ENDFOR

			CASE m.llColsDest && {fr} tableau destination à 2 dimensions, tableau source à 1 dimension {en} target array has 2 dimensions, source array has only one
				taDest[m.liRowDest, 1] = taSrce[m.liRowSrce]

			OTHERWISE && {fr} les 2 tableaux ont 1 dimension {en} each array has one dimension
				taDest[m.liRowDest] = taSrce[m.liRowSrce]

			ENDCASE
		ENDFOR

		lnResult = Iif(m.tlUnique, aDistinct(@m.taDest), m.lnResult)
	ENDIF
ENDIF

RETURN m.lnResult


* --------------------------------------
PROCEDURE aAbarray_Test_a && {fr} pour construire les Array de test {en} to build the test environment
LPARAMETERS ;
	taTest,; && {fr} premier tableau {en} first array
	taTest1 && {fr} second tableau {en} second array

DIMENSION taTest[3,3]
taTest = .F.
taTest[1,1] = 1
taTest[1,2] = 2
taTest[1,3] = 3
taTest[2,1] = 4
taTest[2,2] = 5
taTest[2,3] = 6
taTest[3,1] = 7
taTest[3,2] = 8
taTest[3,3] = 9
DIMENSION taTest1[3,3]
taTest1 = .F.
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
PROCEDURE aAppend_Test && Teste aAppend()

LOCAL loUnitTest as abUnitTest OF abDev.prg
loUnitTest = NewObject('abUnitTest', 'abDev.prg')

PUBLIC ARRAY laTest[3, 3], laTest1[3, 3] && PUBLIC pour l'examiner après test

loUnitTest.Test(6, @m.laTest, @m.laTest1)
loUnitTest.assert(6, Alen(laTest, 1))

RETURN m.loUnitTest.Result()

* ===================================================================
FUNCTION aSubstract && {fr} Soustrait les éléments d'un tableau à un autre {en} remove some elements from an array to another
LPARAMETERS ;
	taDest,; && @ {fr} Résultat {en} Result
	taSrce && @ {fr} Tableau contenant les lignes à soustraire de taDest {fr} array with lines to remove from taDest
EXTERNAL ARRAY taDest, taSrce

LOCAL liResult, llResult, lnResult

lnResult = 0
llResult = Type('taDest', 1) == 'A' AND Type('taSrce', 1) == 'A'
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge(ICase(;
	cLangUser() = 'fr',	[deux tableaux attendus en paramètres],; && copy-paste this line to add another language support
						[two Arrays expected as parameters]; && Default: English
	)))

IF m.llResult

	lnResult = Alen(taDest)
	FOR liResult = m.lnResult TO 1 STEP -1
		IF Ascan(taSrce, taDest[m.liResult], 1, -1, 1, 7+8) > 0 && 7: case insensitive, EXACT ON
			lnResult = m.lnResult - 1
			Adel(m.taDest, m.liResult)
		ENDIF
	ENDFOR

	IF m.lnResult = 0
		aClear(@m.taDest)
	ELSE
		DIMENSION taDest[m.lnResult]
	ENDIF
ENDIF

RETURN m.lnResult

* -------------------------------------------------------------
PROCEDURE aSubstract_Test && Teste aSubstract()

LOCAL loUnitTest AS abUnitTest OF abDev.prg, laDest[1], laSrce[1]

loUnitTest = NewObject('abUnitTest', 'abDev.prg')
ALines(laDest, 'toto,tutu,junk,foo,bar', ',')
ALines(laSrce, 'Tutu,fOo', ',')

loUnitTest.Test(3, @m.laDest, @m.laSrce)
loUnitTest.Assert('toto', laDest[1])
loUnitTest.Assert('junk', laDest[2])
loUnitTest.Assert('bar', laDest[3])

RETURN loUnitTest.Result()

* ===================================================================
FUNCTION aFilter && {fr} Filtre les éléments d'un tableau par un autre {en} Filters the elements of an array by another array
LPARAMETERS ;
	taDest,; && @ {fr} Résultat {en} result
	taSrce,; && @ {fr} Tableau contenant les lignes filtrant taDest {en} array with lines used to filter taDest
	tlExactOff,; && [.F.] {fr} Comparer avec exact off {en} compare with exact off
	tlCase,; && [.F.] {fr} Comparer en respectant la casse {en} case-sensitive comparison
	tlExclude && [.F.] {fr} Garder les éléments destination absents de la source {en} Keep destination elements that can't be found in source

EXTERNAL ARRAY taDest, taSrce

LOCAL lnResult as Integer; && dimension du tableau résultat
, llResult as Boolean;
, liDest, luDest;
, lnSrce, liSrce;
, liCompare

lnResult = 0

llResult = .T.;
	and Type('taDest', 1) == 'A';
	and Alen(taDest, 2) <= 1;
	and Type('taSrce', 1) == 'A';
	and Alen(taSrce, 2) <= 1
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge(ICase(;
	cLangUser() = 'fr',	[deux tableaux à une dimension attendus en 1er et 2ème paramètres],; && copy-paste this line to add another language support
											[two one-dimensional Arrays expected as parameters #1 and 2]; && Default: English
	)))

IF m.llResult

	lnResult = Alen(taDest)
	lnSrce = Alen(taSrce)
	liCompare = 0;
		+ Iif(Vartype(m.tlCase) == 'L' AND m.tlCase, 0, 1);
		+ Iif(Vartype(m.tlExactOff) == 'L' AND m.tlExactOff, 0, 2) + 4 && override SET EXACT setting
	tlExclude = Vartype(m.tlExclude) == 'L' and m.tlExclude

	FOR liDest = m.lnResult TO 1 STEP -1

		luDest = taDest[m.liDest]
		luDest = Ascan(taSrce, m.luDest, 1, -1, 1, m.liCompare)
		IF Iif(m.tlExclude, m.luDest > 0, m.luDest = 0)

			lnResult = m.lnResult - 1
			Adel(m.taDest, m.liDest)
		ENDIF
	ENDFOR

	IF m.lnResult = 0
		aClear(@m.taDest)
	ELSE
		DIMENSION taDest[m.lnResult]
	ENDIF
ENDIF

RETURN m.lnResult

* -------------------------------------------------------------
PROCEDURE aFilter_Test && Teste aFilter()

LOCAL loUnitTest AS abUnitTest OF abDev.prg, laDest[1], laSrce[1]

loUnitTest = NewObject('abUnitTest', 'abDev.prg')

ALines(laDest, 'toto,tutu,junk,foo,bar', ',')
ALines(laSrce, 'Tutu,fOo', ',')

loUnitTest.Test(2, @m.laDest, @m.laSrce)
loUnitTest.Assert('tutu', laDest[1])
loUnitTest.Assert('foo', laDest[2])

ALines(laDest, 'toto,tutu,junk,foo,bar', ',')
ALines(laSrce, 'Tutu,fOo', ',')

loUnitTest.Test(2, @m.laDest, @m.laSrce,,,.T.)
loUnitTest.Assert('toto', laDest[1])
loUnitTest.Assert('junk', laDest[2])
loUnitTest.Assert('bar', laDest[3])

RETURN loUnitTest.Result()

* ===================================================================
FUNCTION laEmpty && {fr} Tableau inexistant ou vide {en} array don't exists or empty
LPARAMETERS ta && @ {fr} Tableau à vérifier {en} array to verify

RETURN NOT Type('ta', 1) == 'A' OR ;
	Alen(ta) = 1 AND Vartype(ta[1]) == 'L' AND NOT ta[1]

EXTERNAL ARRAY ta && après RETURN pour éviter exécution

* -------------------------------------------------------------
PROCEDURE laEmpty_test

LOCAL loUnitTest as abUnitTest OF abDev.prg;
, laTest[1]

loUnitTest = NewObject('abUnitTest', 'abDev.prg')
loUnitTest.Test(.T., @m.laTest)

RETURN loUnitTest.Result()

* ===================================================================
FUNCTION aRowDel && {fr} Supprime PHYSIQUEMENT une ligne d'un tableau {en} remove a line from an array
LPARAMETERS ;
	taResult,; && @ {fr} Résultat {en} result
	tnRow && {fr} n° de ligne à supprimer {en} number of the line to remove
EXTERNAL ARRAY taResult

LOCAL llResult, lnResult && {fr} par analogie avec aDel(), 1 si la ligne est bien supprimée, 0 sinon {en} like aDel(), 1 if the line is suppressed, otherwise 0

lnResult = 0
llResult = NOT Type('taResult[1,2]') == 'U' ; && au moins 2 colonnes
 AND Vartype(m.tnRow) == 'N' ;
 AND m.tnRow > 0 ;
 AND m.tnRow <= Alen(taResult, 1)
ASSERT m.llResult MESSAGE cAssertMsg(ICase(;
	cLangUser() = 'fr',	'Paramètre(s) requis incorrect(s)',; && copy-paste this line to add another language support
						'Parameters required not allowed'; && Default: English
	))
IF m.llResult

	* Effacer la ligne
	Adel(taResult, m.tnRow)

	* Redimensionner
	lnResult = Alen(taResult, 1) - 1
	IF m.lnResult = 0
		aClear(@m.taResult)
	ELSE
		DIMENSION taResult[m.lnResult, Alen(taResult, 2)]
	ENDIF
ENDIF

RETURN m.lnResult

* ===================================================================
FUNCTION aRowMove && {fr} Déplace une ligne dans un tableau {fr} move one line inside an array
LPARAMETERS ;
	taResult,; && @ {fr} Résultat {en} result
	tnFrom,; && {fr} n° de ligne à déplacer {en} number for the line to move
	tnTo && {fr} n° de ligne destination {en} number for the target line
EXTERNAL ARRAY taResult

LOCAL lnRow, lnCol, llCol, laResult[1], llResult

llResult = .T.;
 AND Type('taResult', 1) = 'A';
 AND Vartype(m.tnFrom) == 'N';
 AND Vartype(m.tnTo) == 'N';
 AND NOT m.tnFrom = m.tnTo;
 AND Between(m.tnFrom, 1, Alen(taResult, 1));
 AND Between(m.tnTo, 1, Alen(taResult, 1))
ASSERT m.llResult MESSAGE cAssertMsg(ICase(;
	cLangUser() = 'fr',	'Paramètre(s) requis incorrect(s)',; && copy-paste this line to add another language support
						'Parameters required not allowed'; && Default: English
	))
IF m.llResult

	lnRow = Alen(taResult, 1)
	lnCol = Alen(taResult, 2)
	llCol = m.lnCol > 0

	llResult = Iif(m.llCol;
		, Acopy(taResult, laResult, Aelement(taResult, m.tnFrom, 1), m.lnCol);
		, Acopy(taResult, laResult, m.tnFrom, 1);
		) > 0
	ASSERT m.llResult
	IF m.llResult

		Adel(taResult, m.tnFrom)
		Ains(taResult, m.tnTo)

		llResult = Iif(m.llCol;
			, Acopy(laResult, taResult, 1, m.lnCol, Aelement(taResult, m.tnTo, 1));
			, Acopy(laResult, taResult, 1, 1, m.tnTo);
			) > 0
		ASSERT m.llResult
	ENDIF
ENDIF

RETURN m.llResult

* -------------------------------------------------------------
PROCEDURE aRowMove_test && Teste aRowMove()

LOCAL loUnitTest as abUnitTest OF abDev.prg, laResult[1]

loUnitTest = NewObject('abUnitTest', 'abDev.prg')

aRowMove_test_a1(@m.laResult)
loUnitTest.Test(.T., @m.laResult, 3, 1)
loUnitTest.Assert('3', m.laResult[1])
loUnitTest.Assert('1', m.laResult[2])

aRowMove_test_a1(@m.laResult)
loUnitTest.Test(.T., @m.laResult, 1, 3)
loUnitTest.Assert('2', m.laResult[1])
loUnitTest.Assert('1', m.laResult[3])

aRowMove_test_a2(@m.laResult)
loUnitTest.Test(.T., @m.laResult, 3, 1)
loUnitTest.Assert('31', m.laResult[1, 1])
loUnitTest.Assert('11', m.laResult[2, 1])

aRowMove_test_a2(@m.laResult)
loUnitTest.Test(.T., @m.laResult, 1, 3)
loUnitTest.Assert('21', m.laResult[1, 1])
loUnitTest.Assert('11', m.laResult[3, 1])

RETURN loUnitTest.Result()

	* -------------------------------------------------------------
	FUNCTION aRowMove_test_a1 && tableau de test à 1 dimension
	LPARAMETERS laResult && @ tableau
	EXTERNAL ARRAY laResult

	DIMENSION laResult[6]
	laResult[1] = '1'
	laResult[2] = '2'
	laResult[3] = '3'
	laResult[4] = '4'
	laResult[5] = '5'
	laResult[6] = '6'

	* -------------------------------------------------------------
	FUNCTION aRowMove_test_a2 && tableau de test à 2 dimensions
	LPARAMETERS laResult && @ tableau

	LOCAL lcResult
	TEXT TO lcResult NOSHOW PRETEXT 1+2
		11	12
		21	22
		31	32
		41	42
		51	52
		61	62
	ENDTEXT
	aLinesCols(@m.laResult, m.lcResult)

* ===================================================================
FUNCTION aColDel && {fr} Supprime physiquement une colonne d'un tableau {en} remove one column from an array
LPARAMETERS ;
	taResult,; && @ {fr} Résultat {en} Result
	tnCol && {fr} n° de colonne à supprimer {en} number of the column to remove
EXTERNAL ARRAY taResult

LOCAL lnRow, liRow, lnCol, llResult, lnResult && {fr} par analogie avec aDel(), 1 si la colonne est bien supprimée, 0 sinon {en} like aDel() return 1 if the column is successfull removed, otherwise 0

lnResult = 0
llResult = .T.;
	 AND NOT Type('taResult[1,2]') == 'U' ; && au moins 2 colonnes
	 AND Vartype(m.tnCol) == 'N' ;
	 AND Between(m.tnCol, 1, Alen(taResult, 2))
ASSERT m.llResult MESSAGE cAssertMsg(ICase(;
	cLangUser() = 'fr',	'Paramètre(s) requis incorrect(s)',; && copy-paste this line to add another language support
						'Parameters required not allowed'; && Default: English
	))
IF m.llResult

	* Convertir le tableau en mono-dimensionnel
	lnRow = Alen(taResult, 1)
	lnCol = Alen(taResult, 2)
	DIMENSION taResult[m.lnRow * m.lnCol]

	* Supprimer physiquement les cellules de la colonne à enlever
	FOR m.liRow = m.lnRow TO 1 STEP -1
		lnResult = Adel(taResult, (m.liRow - 1) * m.lnCol + m.tnCol)
		IF m.lnResult = 0
			EXIT
		ENDIF
	ENDFOR

 	* Rétablir le tableau en 2 dimensions
	IF m.lnResult > 0
		DIMENSION taResult[m.lnRow, m.lnCol - 1]
	ENDIF
ENDIF

RETURN m.lnResult

* --------------------------------------
PROCEDURE aColDel_Test_a(laTest)

DIMENSION laTest[2,4]
laTest = .F.
laTest[1,1] = 1
laTest[1,2] = 2
laTest[1,3] = 3
laTest[1,4] = 4
laTest[2,1] = "A"
laTest[2,2] = "B"
laTest[2,3] = "C"
laTest[2,4] = "D"

* --------------------------------------
PROCEDURE aColDel_Test_aa(laTest)

LOCAL lcTest
TEXT TO lcTest NOSHOW PRETEXT 1+2
	11	.T.
	21	.F.	"toto"
	31	.T.	"tutu"	{^2014-01-10}
	41	.NULL.	"tutu"	{^2014-01-11}
endtext

RETURN aLinesCols(@m.laTest, m.lcTest, TABUL, 'ILCD')

* --------------------------------------
PROCEDURE aColDel_Test

LOCAL loUnitTest as abUnitTest OF abDev.prg, laTest[1]
loUnitTest = NewObject('abUnitTest', 'abDev.prg')

* Supprimer la colonne de gauche
aColDel_Test_a(@m.laTest)
loUnitTest.Test(1, @m.laTest, 1)
loUnitTest.Assert(Alen(laTest, 2), 3)
loUnitTest.Assert(laTest[1,1], 2)
loUnitTest.Assert(laTest[2,1], "B")
loUnitTest.Assert(laTest[1,2], 3)
loUnitTest.Assert(laTest[2,2], "C")

* Supprimer une colonne interne
aColDel_Test_a(@m.laTest)
loUnitTest.Test(1, @m.laTest, 2)
loUnitTest.Assert(Alen(laTest, 2), 3)
loUnitTest.Assert(laTest[1,1], 1)
loUnitTest.Assert(laTest[2,1], "A")
loUnitTest.Assert(laTest[1,2], 3)
loUnitTest.Assert(laTest[2,2], "C")

* Supprimer la colonne de droite
aColDel_Test_a(@m.laTest)
loUnitTest.Test(1, @m.laTest, 4)
loUnitTest.Assert(Alen(laTest, 2), 3)
loUnitTest.Assert(laTest[1,1], 1)
loUnitTest.Assert(laTest[2,1], "A")
loUnitTest.Assert(laTest[1,2], 2)
loUnitTest.Assert(laTest[2,2], "B")
loUnitTest.Assert(laTest[1,3], 3)
loUnitTest.Assert(laTest[2,3], "C")

RETURN loUnitTest.Result()

* ===================================================================
FUNCTION aColsDel && {fr} Supprime physiquement plusieurs colonnes d'un tableau {en} remove many columns from an array
LPARAMETERS ;
	taResult,; && @ {fr} Résultat {en} Result
	tnCol1,; && {fr} n° de la première colonne à supprimer {en} index of the first column to remove
	tnCol2 && {fr} [dernière] N° de la dernière colonne à supprimer {en} [last] index of the last column to remove
EXTERNAL ARRAY taResult

LOCAL llResult, lnResult; && {fr} analogue à aDel() : 1 si les colonnes sont bien supprimées, 0 sinon {en} like aDel() if columns succesfull removed 1, otherwise 0
, lnCols, lnCol2, liCol

lnResult = 0

* Si les paramètres requis sont valides
llResult = NOT Type('taResult[1,2]') == 'U' ; && {fr} au moins 2 colonnes {en} at least two columns
 AND Vartype(m.tnCol1) == 'N' ;
 AND m.tnCol1 > 0 ;
 AND m.tnCol1 <= Alen(taResult, 2)
ASSERT m.llResult MESSAGE cAssertMsg(ICase(;
	cLangUser() = 'fr',	'Paramètre(s) requis incorrect(s)',; && copy-paste this line to add another language support
											'Some of the required parameters are invalid'; && Default: English
	))
IF m.llResult

	* Régler les paramètres optionnels à leur valeur par défaut
	lnCols = Alen(taResult, 2)
	lnCol2 = Iif(Vartype(m.tnCol2) == 'N' AND m.tnCol2 <= m.lnCols, m.tnCol2, m.lnCols)
	lnCol2 = Max(m.lnCol2, m.tnCol1)

	* Si la suppression des colonnes est possible
	llResult = NOT (m.tnCol1 = 1 AND m.lnCol2 = m.lnCols)
	ASSERT m.llResult MESSAGE cAssertMsg(ICase(;
	cLangUser() = 'fr',	"Impossible de supprimer toutes les colonnes d'un tableau",; && copy-paste this line to add another language support
						'Cannot remove all columns from an array'; && Default: English
	))

	IF m.llResult

		* Supprimer chaque colonne
		FOR m.liCol = m.lnCol2 TO m.tnCol1 STEP -1
			lnResult = aColDel(@m.taResult, m.liCol)
			IF m.lnResult = 0
				EXIT
			ENDIF
		ENDFOR
	ENDIF
ENDIF

RETURN m.lnResult

* --------------------------------------
PROCEDURE aColsDel_Test
? Sys(16)
LOCAL ARRAY laTest[1]

LOCAL loUnitTest as abUnitTest OF abDev.prg, laTest[1]
loUnitTest = NewObject('abUnitTest', 'abDev.prg')

aColDel_Test_a(@m.laTest)
loUnitTest.Test(1, @m.laTest, 2, 3)
loUnitTest.Assert(Alen(laTest, 2), 2)
loUnitTest.Assert(laTest[1,1], 1)
loUnitTest.Assert(laTest[2,1], "A")
loUnitTest.Assert(laTest[1,2], 4)
loUnitTest.Assert(laTest[2,2], "D")

aColDel_Test_a(@m.laTest)
loUnitTest.Test(1, @m.laTest, 3)
loUnitTest.Assert(Alen(laTest, 2), 2)
loUnitTest.Assert(laTest[1,1], 1)
loUnitTest.Assert(laTest[2,1], "A")
loUnitTest.Assert(laTest[1,2], 4)
loUnitTest.Assert(laTest[2,2], "D")

RETURN loUnitTest.Result()

* ===================================================================
FUNCTION aVarType && {fr} Vartypes d'après un tableau ou une liste délimitée ou non {en} Vartypes from an array or a list delimited or not
LPARAMETERS ;
	taResult,; && @ {fr} Résultat {en} Result
	tuTypes && @ {fr} (Var)types (array ou cListe) {en} (Var)types (array or cListe)
EXTERNAL ARRAY taResult, tuTypes

LOCAL llArray, llResult

llResult = aClear(@m.taResult)
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge(ICase(;
	cLangUser() = 'fr',	[paramètre(s) invalides : <<cLitteral(m.taResult)>>, <<cLitteral(m.tuTypes)>>],; && copy-paste this line to add another language support
						[parameters invalids : <<cLitteral(m.taResult)>>, <<cLitteral(m.tuTypes)>>]; && Default: English
	)))

llArray = Type('tuTypes', 1) == 'A'

RETURN ICase(;
			NOT m.llResult, 0,;
			m.llArray, Min(Acopy(tuTypes, taResult), 0) + Alen(taResult),;
			Vartype(m.tuTypes) == 'C', Iif(;
				',' $ m.tuTypes OR ';' $ m.tuTypes OR TABUL $ m.tuTypes OR '|' $ m.tuTypes;
									, ALines(taResult, Upper(m.tuTypes), 1+4, ',', ';', TABUL, '|'),;
				aChars(@m.taResult, Upper(Chrtran(m.tuTypes, Space(1), Space(0))))),;
			0)


* ===================================================================
FUNCTION aColsIns && {fr} Insère physiquement une ou plusieurs colonne(s) dans un tableau {en} Insert one or many columns inside an array
LPARAMETERS ;
	taResult,; && @ {fr} Résultat {en} Result
	tnColBef,; && {fr} [dernière] n° de colonne APRÈS laquelle insérer la(es) nouvelle(s) colonne(s), 0 pour ajouter au début {en} [last] index of column AFTER we insert the new column(s), 0 to insert at the beginning
	tnColsIns,; && {fr} [1] Nombre de colonnes à insérer {en} [1] number of column to insert
	tuVal,; && {fr} [.F. ou uEmpty(tuTypes)] Valeur des cellules ajoutées {en} [.F. or uEmpty(tuTypes)] Value of cells to insert
	tuTypes && @ {fr} Types des colonnes (array ou liste) in 'CDGLNOQTUXYI' {en} Types of column (array or list) in 'CDGLNOQTUXYI'

LOCAL llResult, lnResult; && {fr} Nombre de colonnes après l'insersion {en} number of columns after insertion
, lnRow, liRow;
, lnCol, liCol

lnResult = 0

* Si un tableau a été passé
llResult = Type('taResult', 1) == 'A'
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge(ICase(;
	cLangUser() = 'fr',	[tableau attendu en premier paramètre : <<cLitteral(m.taResult)>> !],; && copy-paste this line to add another language support
						[array expected as the first parameter : <<cLitteral(m.taResult)>> !]; && Default: English
	)))
IF m.llResult

	lnRow = Alen(taResult, 1)
	lnCol = Alen(taResult, 2)

	* Si tableau à une dim.
	IF m.lnCol = 0

		* Convertir à 2 dimensions
		lnCol = 1
		DIMENSION taResult[m.lnRow, m.lnCol]
	ENDIF

	* Vérifier la validité du n° de colonne passé
	IF Vartype(m.tnColBef) == 'N'
		llResult = Between(m.tnColBef, 0, m.lnCol)
		ASSERT m.llResult MESSAGE cAssertMsg(Textmerge(ICase(;
	cLangUser() = 'fr',	"<<Proper(Program())>>() - le n° de colonne <<m.tnColBef>> est hors des limites du tableau.",; && copy-paste this line to add another language support
						"<<Proper(Program())>>() - index of column <<m.tnColBef>> outside the length of array."; && Default: English
	)))
	ELSE
		tnColBef = m.lnCol && {fr} après la dernière colonne {en} after the last column
	ENDIF
ENDIF

IF m.llResult

	tnColsIns = Iif(Vartype(m.tnColsIns) == 'N' AND m.tnColsIns > 0, m.tnColsIns, 1)
	lnResult = m.lnCol + m.tnColsIns

	* Créer un tableau de travail
	LOCAL laTemp[m.lnRow, m.lnResult];
	,	laType[1], lnType;
	, llColBeg, lnColIns, llColIns, llColInsTyped

	* Voir si le typage est demandé
	lnType = aVarType(@m.laType, @m.tuTypes)

	* Remplir le tableau de travail
	FOR m.liCol = 1 TO m.lnResult

		llColBeg = m.liCol <= m.tnColBef

		lnColIns = m.liCol - m.tnColBef
		llColIns = Between(m.lnColIns, 1, m.tnColsIns)
		llColInsTyped = m.llColIns AND m.lnColIns <= m.lnType

		FOR m.liRow = 1 TO m.lnRow

			laTemp[m.liRow, m.liCol] = ICase(;
				m.llColBeg, taResult[m.liRow, m.liCol],; && {fr} avant la(es) nouvelle(s) colonne(s) {en} before new column(s)
				m.llColIns; && {fr} nouvelle(s) colonne(s) {en} new column(s)
							, Iif(m.llColInsTyped;
									, uEmpty(laType[m.lnColIns]);
									, m.tuVal;
							),;
				taResult[m.liRow, m.liCol - m.tnColsIns]; && {fr} après la(es) nouvelle(s) colonne(s) {en} after new column(s)
				)
		ENDFOR
	ENDFOR

	* Copier le tableau de travail dans le résultat
	DIMENSION taResult[m.lnRow, m.lnResult]
	Acopy(laTemp, taResult) && contrairement à ce que dit la doc, ne dimensionne pas correctement taResult
ENDIF

RETURN m.lnResult

* --------------------------------------
PROCEDURE aColsIns_Test && Teste aColsIns()

LOCAL loUnitTest as abUnitTest OF abDev.prg, laTest[1]
loUnitTest = NewObject('abUnitTest', 'abDev.prg')

&& TABLEAU À UNE DIMENSION

aColsIns_Test_a(@m.laTest, 3)
	loUnitTest.Test(3, @m.laTest, 0, 2) && 2 colonnes au début
	loUnitTest.Assert(.F., laTest[3,1]) && 1ère colonne insérée
	loUnitTest.Assert(2, laTest[2,3]) && La colonne initiale est maintenant # 3

&& TABLEAU À DEUX DIMENSIONS

&& ajout au début
aColsIns_Test_a(@m.laTest, 2, 3)
	loUnitTest.Test(5, @m.laTest, 0, 2) && 2 colonnes au début (1,2)
	loUnitTest.Assert(6, laTest[2,5]) && donnée initiale
	loUnitTest.Assert(.F., laTest[1,2]) && 2ème colonne insérée

&& ajout à l'intérieur
aColsIns_Test_a(@m.laTest, 2, 3)
	loUnitTest.Test(5, @m.laTest, 2, 2) && 2 colonnes après la 2 (3,4)
	loUnitTest.Assert(6, laTest[2,5]) && donnée initiale
	loUnitTest.Assert(.F., laTest[1,4]) && 2ème colonne insérée

&& ajout à la fin
aColsIns_Test_a(@m.laTest, 2, 3)
	loUnitTest.Test(5, @m.laTest, , 2) && 2 colonnes à la fin (4,5)
	loUnitTest.Assert(6, laTest[2,3]) && donnée initiale
	loUnitTest.Assert(.F., laTest[2,5]) && 2ème colonne insérée

	&& ajout à la fin avec valeur imposée
	aColsIns_Test_a(@m.laTest, 2, 3)
		loUnitTest.Test(5, @m.laTest, , 2, 'test') && 2 colonnes à la fin (4,5)
		loUnitTest.Assert(6, laTest[2,3]) && donnée initiale
		loUnitTest.Assert('test', laTest[2,5]) && 2ème colonne insérée

	&& ajout à la fin avec type imposé
	aColsIns_Test_a(@m.laTest, 2, 3)
		loUnitTest.Test(5, @m.laTest, , 2, , 'IC') && 2 colonnes à la fin (4,5)
		loUnitTest.Assert(6, laTest[2,3]) && donnée initiale
		loUnitTest.Assert('', laTest[2,5]) && 2ème colonne insérée

	* --------------------------------------
	PROCEDURE aColsIns_Test_a && Initialise le tableau de test avec aElement()
	LPARAMETERS taTest, tnRows, tnCols
	EXTERNAL ARRAY taTest
	IF Empty(m.tnCols)
		DIMENSION taTest[m.tnRows]
	ELSE
		DIMENSION taTest[m.tnRows, m.tnCols]
	ENDIF
	LOCAL lnTest
	FOR lnTest = 1 TO Alen(taTest)
		taTest[m.lnTest] = m.lnTest
	ENDFOR

* ===================================================================
FUNCTION laEqual && {fr} Deux tableaux sont identiques {en} Two arrays are equals
LPARAMETERS ;
	ta1,; && @ {fr} tableau 1 {en} array 1
	ta2,; && @ {fr} tableau 2 {en} array 2
	tlCase,; && {fr} [.F.] Si élements de type caractère, ignorer la casse, les diacritiques et les espaces de fin {en} If type 'C', case insensitive and ending spaces are ignored
	taDelta && @ {fr} tableau différentiel {en} array of differences
tlCase = Vartype(m.tlCase) == 'L' AND m.tlCase
EXTERNAL ARRAY ta1, ta2, taDelta

LOCAL llParms, lnElt1, lnElt2, lnCol1, lnCol2, liElt, luElt1, luElt2, llElt;
, lcType, llDelta, lnDelta, liDelta;
, llResult && {fr} Tableaux identiques {en} same arrays

* Si deux tableaux ont bien été passés
llParms = Type('ta1', 1) == 'A' AND Type('ta2', 1) == 'A'
ASSERT m.llParms MESSAGE cAssertMsg(Textmerge(ICase(;
	cLangUser() = 'fr',	[<<Proper(Program())>>() - Deux tableaux attendus: <<ta1>> | <<ta2>>],; && copy-paste this line to add another language support
						[<<Proper(Program())>>() - Two arrays expected: <<ta1>> | <<ta2>>]; && Default: English
	)))

IF m.llParms

	llDelta = aClear(@m.taDelta)
	lnElt1 = Alen(ta1)
	lnElt2 = Alen(ta2)
	IF m.lnElt1 = m.lnElt2 OR m.llDelta

		* Pour chaque élément
		lnDelta = 0
		lnCol1 = Alen(m.ta1, 2)
		lnCol2 = Alen(m.ta2, 2)
		llResult = .T.
		FOR liElt = 1 TO MAX(m.lnElt1, m.lnElt2)

			luElt1 = IIF(m.liElt <= m.lnElt1, ta1[m.liElt], .NULL.)
			luElt2 = IIF(m.liElt <= m.lnElt2, ta2[m.liElt], .NULL.)
			lcType = Vartype(m.luElt1)
			llElt = m.lcType == Vartype(m.luElt2); && {fr} éléments de même type {en} same type element
				 AND Iif(m.lcType = 'C' AND m.tlCase;
						, Upper(cEuroAnsi(Rtrim(m.luElt1))) == Upper(cEuroAnsi(Rtrim(m.luElt2)));
						, luEqual(m.luElt1, m.luElt2);
						)
			llResult = m.llResult AND m.llElt
			IF NOT m.llElt && {fr} élements différents {en} type element not similar

				IF m.llDelta
					lnDelta = m.lnDelta + 1
					DIMENSION taDelta[m.lnDelta, Evl(m.lnCol1, 1) + Evl(m.lnCol2, 1)]
					liDelta = IIF(m.liElt <= m.lnElt1;
						, Iif(m.lnCol1 > 0, Asubscript(m.ta1, m.liElt, 2), 1);
						, Iif(m.lnCol2 > 0, Asubscript(m.ta2, m.liElt, 2), 1);
						)
					taDelta[m.lnDelta, m.liDelta] = m.luElt1
					taDelta[m.lnDelta, Evl(m.lnCol1, 1) + m.liDelta] = m.luElt2
				ELSE
					EXIT
				ENDIF
			ENDIF
		ENDFOR
	ENDIF
ENDIF

RETURN m.llResult

* -------------------------------------------------------------
PROCEDURE laEqual_test

LOCAL loUnitTest as abUnitTest OF abDev.prg
loUnitTest = NewObject('abUnitTest', 'abDev.prg')

LOCAL ARRAY la1[5], la2[5], laDelta[1]
la1[1] = 'tete'
la1[2] = 2.5
la1[3] = .F.
la1[4] = Date()
la1[5] = Datetime()

la2[1] = 'Tête'
la2[2] = 2.5
la2[3] = .F.
la2[4] = Date()
la2[5] = Datetime()

loUnitTest.Test(.T., @m.la1, @m.la2, .T.)

loUnitTest.Test(.T., @m.la1, @m.la2, .F., @m.laDelta)
loUnitTest.Assert('tete,Tête', cListOfArray(@m.laDelta,, -1))

RETURN loUnitTest.Result()

* ===================================================================
FUNCTION laOccurs && {fr} Un tableau à une dimension est une ligne d'un tableau à 2 dim. {en} an array at one dimension is a line of an array at two dimensions
LPARAMETERS ;
	ta1,; && @ {fr} tableau 1 à une dimension {en} array 1 with one dimension
	ta2,; && @ {fr} tableau 2 à deux dimensions {en} array 2 with two dimensions
	tlCase && [.F.] {fr} Élements caractère : Comparer en ignorant la casse, les diacritiques et les espaces de fin {fr} Type 'C' : compare case insensitive and don't care of the terminal spaces
EXTERNAL ARRAY ta1, ta2

LOCAL llResult; && {fr} La ligne existe {en} The line exists
, lnCol, liRow, laRow[1]

* Si des tableaux ont bien été passés
llResult = Type('ta1', 1) == 'A'  AND Type('ta2', 1) = 'A'
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge(ICase(;
	cLangUser() = 'fr',	[<<Proper(Program())>>() - paramètre(s) invalides],; && copy-paste this line to add another language support
						[<<Proper(Program())>>() - Invalid parameters]; && Default: English
	)))
IF m.llResult

	* Si le second tableau est à 2 dims et les deux tableaux ont le même nombre de colonnes
	lnCol = Alen(ta2, 2)
	llResult = m.lnCol > 0 AND Alen(ta1) = m.lnCol
	ASSERT m.llResult MESSAGE cAssertMsg(Textmerge(ICase(;
	cLangUser() = 'fr',	[<<Proper(Program())>>() - Les deux tableaux doivent avoir le même nombre de colonnes],; && copy-paste this line to add another language support
						[<<Proper(Program())>>() - each array must have the same number of columns]; && Default: English
	)))
	IF m.llResult

		* Pour chaque ligne du second tableau
		dimension laRow[m.lnCol]
		FOR liRow = 1 TO Alen(ta2, 1)

			* Extraire la ligne dans un tableau temporaire
			Acopy(ta2, laRow, Aelement(ta2, m.liRow, 1), m.lnCol)
			dimension laRow[m.lnCol] && Acopy() dimensionne laRow comme ta2

			* Si la ligne est identique au tableau 1, terminé
			llResult = laEqual(@m.laRow, @m.ta1, m.tlCase)
			IF m.llResult
				EXIT
			ENDIF
		ENDFOR
	ENDIF
ENDIF

RETURN m.llResult

* ===================================================================
FUNCTION aDistinct && {fr} Tableau dont chaque ligne est unique {en} array where each line is unique
LPARAMETERS taResult && @ {fr} Tableau {en} array
EXTERNAL ARRAY taResult

LOCAL lnResult; && {fr} Nombre de lignes du tableau après dédoublonnage {en} number of lines after removing duplicates lines
, llResult;
, lnCol, liCol;
, laRow[1], liRow, liRow_;
, llDup

lnResult = 0

* Si tableau
llResult = Type('taResult', 1) == 'A'
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge(ICase(;
	cLangUser() = 'fr',	[<<Proper(Program())>>() - Tableau attendu au lieu de <<cLitteral(taResult)>>],; && copy-paste this line to add another language support
						[<<Proper(Program())>>() - Array expected instead of <<cLitteral(taResult)>>]; && Default: English
	)))
IF m.llResult

	* Si plus d'une ligne
	lnResult = Alen(taResult, 1)
	IF m.lnResult > 1

		* Pour chaque ligne en partant de la fin
		lnCol = Alen(taResult, 2)
		dimension laRow[Evl(m.lnCol, 1)]
		FOR liRow = m.lnResult TO 2 STEP -1

			* Copier la ligne pour référence
			= Iif(m.lnCol > 0;
				, Acopy(taResult, laRow, Aelement(taResult, m.liRow, 1), m.lnCol);
				, Acopy(taResult, laRow, Aelement(taResult, m.liRow), 1);
				)

			* Pour chaque ligne jusqu'à celle précédant celle examinée
			FOR liRow_ = 1 TO m.liRow - 1
				IF m.lnCol > 0
					llDup = .T.
					FOR liCol = 1 TO m.lnCol
						IF NOT taResult[m.liRow_, m.liCol] == laRow[m.liCol]
							llDup = .F.
							EXIT
						ENDIF
					ENDFOR
				ELSE
					llDup = taResult[m.liRow_] == laRow[1]
				ENDIF
				IF m.llDup
					EXIT
				ENDIF
			ENDFOR

			* Si la ligne existe, supprimer
			IF m.llDup
				Adel(taResult, m.liRow)
				lnResult = m.lnResult - 1
			ENDIF
		ENDFOR

		* Retailler le tableau
		IF m.lnCol > 0
			DIMENSION taResult[m.lnResult, m.lnCol]
		ELSE
			DIMENSION taResult[m.lnResult]
		ENDIF
	ENDIF
ENDIF

RETURN m.lnResult

* -----------------------------------------------------------------
PROCEDURE aDistinct_Test && Teste aDistinct

LOCAL loUnitTest as abUnitTest OF abDev.prg
loUnitTest = NewObject('abUnitTest', 'abDev.prg')

PUBLIC ARRAY laTest[3, 3] && PUBLIC pour l'examiner après test
laTest[1, 1] = 'toto'
laTest[1, 2] = 3
laTest[1, 3] = .T.

laTest[2, 1] = 'TOTO'
laTest[2, 2] = 3
laTest[2, 3] = .T.

laTest[3, 1] = 'toto'
laTest[3, 2] = 3
laTest[3, 3] = .T.

loUnitTest.Test(2, @m.laTest)

RETURN m.loUnitTest.Result()

* ===================================================================
FUNCTION aLookup && {fr} Valeur d'une colonne d'un tableau selon une clé cherchée dans une autre colonne {en} Value found in an array column based on a key sought in another column
LPARAMETERS ;
	taSrce,; && @ {fr} Tableau source {en} Array source
	tuVal,; && {fr} Valeur à trouver {en} Value to find
	tnColIn,; && {fr} Colonne où chercher {en} Column where is the key
	tnColOut,; && {fr}Colonne où trouver {en} Column where is the value
	tnFlags && [15] {fr} nFlags selon options de aScan() {en} nFlags as in aScan()
EXTERNAL ARRAY taSrce
tnFlags = Iif(Vartype(m.tnFlags) == 'N' AND Between(m.tnFlags, 0, 15), m.tnFlags, 15)

LOCAL luResult; && {en} Value found {fr} Valeur trouvée
, llResult;
, liResult;

luResult = .null. && {en} if value not found in array {fr} Si valeur pas trouvée dans le tableau

llResult = Type('taSrce', 1) == 'A';
 AND Vartype(m.tnColIn) == 'N';
 AND Between(m.tnColIn, 1, Alen(taSrce, 2));
 AND Vartype(m.tnColOut) == 'N';
 AND Between(m.tnColOut, 1, Alen(taSrce, 2));
 AND NOT m.tnColIn = m.tnColOut
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge(ICase(;
	cLangUser() = 'fr',	"Au moins un paramètre invalide",; && copy-paste this line to add another language support
											"At least one parameter is not conform"; && Default: English
	)))
IF m.llResult
	liResult = Ascan(taSrce, m.tuVal, 1, -1, m.tnColIn, m.tnFlags)
	luResult = Iif(m.liResult > 0;
		, taSrce[m.liResult, m.tnColOut];
		, m.luResult;
		)
ENDIF

RETURN m.luResult

* ===================================================================
FUNCTION aSelect && {fr} Lignes d'un tableau selon une clé {en} Lines from an array conform to a key
LPARAMETERS ;
	taSrce,; && @ {fr} Tableau source {en} Array source
	taDest,; && @ {fr} Tableau destination {en} Array target
	tnCol,; && {fr} Colonne où chercher {en} Column where to find
	tuVal,; && {fr} Valeur à trouver {en} Value to search
	tnFlags && [15] {fr} nFlags selon options de aScan() {en} nFlags as in aScan()
EXTERNAL ARRAY taSrce, taDest
tnFlags = Iif(Vartype(m.tnFlags) == 'N' AND Between(m.tnFlags, 0, 15), m.tnFlags, 15)

LOCAL liResult, llResult, lnResult && {fr} Nombre de lignes trouvées {en} Number of lines found
lnResult = 0

llResult = Type('taSrce', 1) == 'A';
 AND Type('taDest', 1) == 'A';
 AND Vartype(m.tnCol) == 'N';
 AND Between(m.tnCol, 1, Alen(taSrce, 2))
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge(ICase(;
	cLangUser() = 'fr',	"<<Proper(Program())>>() - Au moins un paramètre invalide",; && copy-paste this line to add another language support
						"<<Proper(Program())>>() - At least one parameter is not conform"; && Default: English
	)))
IF m.llResult

	* Si la valeur existe
	liResult = Ascan(taSrce, m.tuVal, 1, -1, m.tnCol, m.tnFlags)
	IF m.liResult > 0

		aClear(@m.taDest)

		DO WHILE liResult > 0
			aRowCopyIns(@m.taDest, @m.taSrce,, m.liResult)
			lnResult = m.lnResult + 1
			liResult = Ascan(taSrce, m.tuVal, m.liResult+1, -1, m.tnCol, m.tnFlags)
		ENDDO
	ENDIF
ENDIF

RETURN m.lnResult

* -----------------------------------------------------------------
PROCEDURE aSelect_Test && Teste aSelect()

LOCAL loUnitTest as abUnitTest OF abDev.prg
loUnitTest = NewObject('abUnitTest', 'abDev.prg')

PUBLIC ARRAY laSrce[1], laDest[1] && PUBLIC pour examen après test
AVcxClasses(laSrce, 'aw'+'.vcx') && évite d'embarquer aw.vcx dans le projet

loUnitTest.Test(2, @m.laSrce, @m.laDest, 2, 'commandbutton')

RETURN m.loUnitTest.Result()

* ===================================================================
FUNCTION aClear && {fr} Vide un tableau {en} Return an empty array
LPARAMETERS taResult && @ {fr} Tableau {en} Array

IF Type('taResult', 1) == 'A'
	DIMENSION taResult[1]
	taResult[1] = .F.
	RETURN .T.
ELSE
	RETURN .F.
ENDIF

EXTERNAL ARRAY taResult

* -----------------------------------------------------------------
PROCEDURE aClear_test

LOCAL loUnitTest as abUnitTest OF abDev.prg
loUnitTest = NewObject('abUnitTest', 'abDev.prg')

LOCAL ARRAY laTest[3]
loUnitTest.Test(.T., @m.laTest)

RETURN loUnitTest.Result()

* ===================================================================
FUNCTION aRowCopyIns && {fr} Copie une ligne d'un tableau et l'insère dans un autre à une position donnée {en} Copy one line from an array and insert it in another array at a specific position
LPARAMETERS ;
	taDest,; && @ {fr} Résultat {en} Result
	taSrce,; && @ {fr} tableau source des lignes copiées dans taDest {en} array source from where one line is inserted in taDest
	tiDest,; && [dernière] {fr} N° de ligne APRÈS laquelle insérer la ligne copiée, 0 pour insérer au début {en} index of line AFTER the line is inserted
	tiSrce   && [1] {fr} n° de la ligne du tableau source à copier dans la destination {en} index of line from source array to be copied in taDest
EXTERNAL ARRAY taDest, taSrce

LOCAL lnCol, liCol, llResult, lnResult && {fr} nombre de lignes du tableau destination {en} number of lines of target array

lnResult = 0
llResult = Type('taDest', 1) == 'A' AND Type('taSrce', 1) == 'A'
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge(ICase(;
	cLangUser() = 'fr',	[les deux premiers paramètres doivent être des tableaux],; && copy-paste this line to add another language support
						[the firsts two parameters must be arrays]; && Default: English
	)))
IF m.llResult

	llResult = laEmpty(@m.taDest)
	IF m.llResult
		lnCol = Alen(taSrce,2)
	ELSE
		lnCol = Alen(taDest,2)
		llResult = m.lnCol = Alen(taSrce,2)
		ASSERT m.llResult MESSAGE cAssertMsg(Textmerge(ICase(;
	cLangUser() = 'fr',	[les deux tableaux doivent avoir le même nombre de colonnes],;
						[the arrays must have the same number of columns]; && Default: English
	)))
		lnResult = Iif(m.llResult, Alen(taDest, 1), 0)
	ENDIF
	IF m.llResult

		tiDest = Iif(Vartype(m.tiDest) == 'N' AND Between(m.tiDest, 0, m.lnResult), m.tiDest, m.lnResult) + 1 && {fr} spec aIns() : AVANT {en} aIns() : BEFORE
		tiSrce = Iif(Vartype(m.tiSrce) == 'N' AND Between(m.tiSrce, 1, Alen(taSrce, 1)), m.tiSrce, 1)

		* Insérer la nouvelle ligne
		lnResult = m.lnResult + 1
		DIMENSION taDest[m.lnResult, m.lnCol]
		Ains(taDest, m.tiDest)

		* Copier les données dans la nouvelle ligne
		FOR liCol = 1 TO m.lnCol
			taDest[m.tiDest, m.liCol] = taSrce[m.tiSrce, m.liCol]
		ENDFOR
	ENDIF
ENDIF

RETURN m.lnResult

* ===================================================================
FUNCTION aAdd && {fr} Ajoute un élément à un tableau à UNE dimension {en} Add one element to an array with one dimension
LPARAMETERS ;
	taResult,; && @ {fr} Résultat {en} Result
	tuElt,; && {fr} élément à ajouter {en} element to append
	tlUnique,; && [.F.] {fr} ne pas ajouter l'élément s'il existe déjà {en} don't append it if it exists already
	tlPush && [.F.] {fr} Ajouter au début {en} Append at the beginning
EXTERNAL ARRAY taResult && {fr} pour le gestionnaire de projet {en} for the project manager

LOCAL llResult, lu, lnResult && {fr} nombre de lignes du Résultat {en} number of line of Result

lnResult = 0
llResult = Type('taResult', 1) == 'A'
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge(ICase(;
	cLangUser() = 'fr',	[tableau attendu en premier paramètre : <<cLitteral(m.taResult)>> !],;
						[array expected as the first parameter : <<cLitteral(m.taResult)>> !]; && Default: English
	)))
IF m.llResult

	llResult = Alen(taResult,2) = 0
	ASSERT m.llResult MESSAGE cAssertMsg(Textmerge(ICase(;
	cLangUser() = 'fr',	[tableau à une dimension attendu : <<cLitteral(m.taResult)>> !],; && copy-paste this line to add another language support
						[array with one dimension only expected : <<cLitteral(m.taResult)>> !]; && Default: English
	)))
	IF m.llResult

		lnResult = Alen(taResult)
		IF Vartype(m.tlUnique) == 'L' AND m.tlUnique

			IF Vartype(m.tuElt) == 'O' && {fr} Ascan() ne marche pas pour les objets {en} Ascan() don't work with object
				FOR EACH lu IN taResult
					llResult = NOT (Vartype(m.lu) == 'O' AND m.lu = m.tuElt)
					IF NOT m.llResult
						EXIT
					ENDIF
				ENDFOR
			ELSE
				llResult = Ascan(taResult, m.tuElt, 1, -1, -1, 1+2+4) = 0
			ENDIF
		ENDIF
		IF m.llResult

			lnResult = Iif(laEmpty(@m.taResult), 0, m.lnResult) + 1
			DIMENSION taResult[m.lnResult]
			IF Vartype(m.tlPush) == 'L' AND m.tlPush
				Ains(taResult, 1)
				taResult[1] = m.tuElt
			ELSE
				taResult[m.lnResult] = m.tuElt
			ENDIF
		ENDIF
	ENDIF
ENDIF

RETURN m.lnResult

* ===================================================================
FUNCTION aPop && {fr} Supprime le premier élément d'un tableau à UNE dimension {en} Remove the first element from an array with one dimension
LPARAMETERS taResult && @ {fr} Résultat {en} Result
EXTERNAL ARRAY taResult

LOCAL llResult, lnResult

lnResult = 0

llResult = Type('taResult', 1) == 'A';
 AND Alen(taResult, 2) = 0 && une dimension
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge(ICase(;
	cLangUser() = 'fr',	[paramètres invalides ou incomplets],; && copy-paste this line to add another language support
						[parameters not conform or unusable]; && Default: English
	)))
IF m.llResult

	Adel(taResult, 1)
	lnResult = Alen(taResult) - 1
	IF m.lnResult > 0
		DIMENSION taResult[m.lnResult]
	ELSE
		aClear(@m.taResult)
	ENDIF
ENDIF

RETURN m.lnResult

* ===================================================================
FUNCTION aPush && {fr} Ajoute un élément à la fin d'un tableau à UNE dimension {en} Append an element at the bottom of an array with dimension ONE
LPARAMETERS ;
	taResult,; && @ {fr} Résultat {en} Result
	tuElt,; && {fr} élément à ajouter {en} element to add
	tlUnique && [.F.] {fr} Ne pas ajouter l'élément au tableau s'il y est déjà {en} don't add it, if it exists already
EXTERNAL ARRAY taResult

LOCAL llResult, lnResult

lnResult = 0

llResult = Type('taResult', 1) == 'A';
 AND Alen(taResult, 2) = 0; && une dimension
 AND Pcount() >= 2
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge(ICase(;
	cLangUser() = 'fr',	[paramètres invalides ou incomplets],; && copy-paste this line to add another language support
						[parameters not conform or unusable]; && Default: English
	)))

IF .T.;
 AND m.llResult;
 AND (.F.;
 		OR NOT (Vartype(m.tlUnique) == 'L' AND m.tlUnique);
 		OR Ascan(m.taResult, m.tuElt, 1, -1, 1, 5) = 0;
 		)

	lnResult = Iif(laEmpty(@m.taResult), 0, Alen(m.taResult)) + 1
	DIMENSION taResult[m.lnResult]
	taResult[m.lnResult] = m.tuElt
ENDIF

RETURN m.lnResult

* -------------------------------------------------
PROCEDURE aPush_test

LOCAL loUnitTest as abUnitTest OF abDev.prg;
, laResult[1], lnResult;
, laExpected[1], lnExpected

loUnitTest = NewObject('abUnitTest', 'abDev.prg')

lnResult = aLitteral(@m.laResult, [1,'toto',1,2,'tata',2])
lnExpected = aLitteral(@m.laExpected, [1,'toto',1,2,'tata',2, .F.])
loUnitTest.Test(m.lnResult + 1, @m.laResult, .F.)
loUnitTest.Assert(@m.laExpected, @m.laResult)

lnResult = aLitteral(@m.laResult, [1,'toto',1,2,'tata',2])
lnExpected = aLitteral(@m.laExpected, [1,'toto',1,2,'tata',2])
loUnitTest.Test(m.lnResult, @m.laResult, 'toto', .T.)
loUnitTest.Assert(@m.laExpected, @m.laResult)

lnResult = aLitteral(@m.laResult, [1,'toto',1,2,'tata',2])
lnExpected = aLitteral(@m.laExpected, [1,'toto',1,2,'tata',2])
loUnitTest.Test(m.lnResult, @m.laResult, 1, .T.)
loUnitTest.Assert(@m.laExpected, @m.laResult)

RETURN loUnitTest.Result()

* ===================================================================
FUNCTION aLocate && {fr} Cherche plusieurs valeurs dans un tableau à 2 dimensions [à la manière de LOCATE FOR] {en} Search many values inside an array with 2 dimensions like the command LOCATE FOR
LPARAMETERS ;
  taIn; && @ {fr} Tableau où chercher {en} Array where to search
, taFor; && @ {fr} Valeurs à chercher dans l'ordre des colonnes ; .NULL. pour ignorer une colonne {en} Values to search in order of columns ; .NULL. to avoid a column
, tlCaseNo; && [.F.] {fr} Chercher les valeurs caractères en ignorant la casse {en} Search characters value case insensitive
, tlExactNo; && [.F.] {fr} Chercher les valeurs caractères en EXACT OFF {en} Search characters value with SET EXACT OFF
, liColKey; && [search] {fr} colonne ou se trouve la clé {en} column where the key sits

EXTERNAL ARRAY taIn, taFor

LOCAL liResult as Integer; && {fr} Ligne trouvée, 0 si aucune {en} Line found, 0 if nothing
, llResult as Boolean;
, lcExact  as String;
, lcExact_ as String;
, lnCol;
, liCol;
, luKey;
, lnFlags;
, liRow;

liResult = 0

llResult = .T.;
 AND Type('taIn', 1) == 'A';
 AND Type('taFor', 1) == 'A';
 AND Alen(m.taFor, 2) = 0; && une dimension
 AND (laEmpty(@m.taIn) OR Alen(m.taIn, 2) >= Alen(m.taFor))
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge(ICase(;
	cLangUser() = 'fr',	[au moins un paramètre invalide],; && copy-paste this line to add another language support
											[at least one parameter is invalid]; && Default: English
	)))
IF m.llResult AND NOT laEmpty(@m.taIn)

	* Si au moins une valeur à chercher est non nulle (clé)
	lnCol = Alen(m.taFor)
	liColKey = Cast(m.liColKey as Integer)
	IF Between(m.liColKey, 1, m.lnCol) and !IsNull(m.taFor[m.liColKey])
		luKey = m.taFor[m.liColKey]
	ELSE
		llResult = .F.
		FOR liColKey = m.lnCol TO 1 STEP -1
			luKey = m.taFor[m.liColKey]
			IF !IsNull(m.luKey)
				llResult = .T.
				EXIT
			ENDIF
		ENDFOR
	ENDIF
	IF m.llResult

		tlCaseNo = lTrue(m.tlCaseNo)
		lnFlags = Iif(m.tlCaseNo, 1, 0) + 8

		lcExact  = Set("Exact")
		lcExact_ = Iif(lTrue(m.tlExactNo), 'OFF', 'ON')
		set exact &lcExact_

		liRow = 0
		llResult = .F.
		DO WHILE .T.

			* Si la clé existe dans le tableau
			liRow = Ascan(m.taIn, m.luKey, m.liRow + 1, -1, m.liColKey, m.lnFlags)
			IF m.liRow > 0

				* Si les autres valeurs sont dans la ligne
				llResult = .T.
				for liCol = 1 TO m.lnCol
					IF !(Vartype(m.taFor[m.liCol]) == 'X'; && ignored
					 or Vartype(m.taFor[m.liCol]) == Vartype(m.taIn[m.liRow, m.liCol]); && m.lcType && selon coverage, plus rapide de recalculer Vartype(m.luFor) plusieurs fois que de lire une variable lcType
					  and Iif(m.tlCaseNo AND Vartype(m.taFor[m.liCol]) == 'C';
								, Upper(m.taIn[m.liRow, m.liCol]) = Upper(m.taFor[m.liCol]);
								, m.taIn[m.liRow, m.liCol] = m.taFor[m.liCol];
								);
						)
						llResult = .F.
						exit
					ENDIF
				endfor
				IF m.llResult
					liResult = m.liRow
					exit
				ENDIF
			ELSE
				exit
			ENDIF
		enddo
		set exact &lcExact
	ENDIF
ENDIF

RETURN m.liResult
endfunc

* -------------------------------------------------------------
PROCEDURE aLocate_test

LOCAL loUnitTest as abUnitTest OF abDev.prg, laIn[1], laFor[1]
loUnitTest = NewObject('abUnitTest', 'abDev.prg')

aLitteral(@m.laIn, [1,'toto',1,2,'tata',2], 3)
aLitteral(@m.laFor, [2,'tata',.NULL.])

loUnitTest.Test(2, @m.laIn, @m.laFor)

aLitteral(@m.laFor, [2,'TATA',.NULL.])
loUnitTest.Test(2, @m.laIn, @m.laFor, .T.)

aLitteral(@m.laFor, [2,'TAT',.NULL.])
loUnitTest.Test(2, @m.laIn, @m.laFor, .T., .T.)

RETURN loUnitTest.Result()

* ===================================================================
FUNCTION aLitteral && {fr} Tableau d'après une liste de litteraux {en} Array from a list of strings
LPARAMETERS ;
	taResult,; && @ {fr} Résultat {en} Result
	tc,; && {fr} Constantes séparées par une ',' ou un point ',' {en} Strings delimited by coma or dot.
	tiCols && [0] {fr} Nombre de colonnes {en} Number of columns
EXTERNAL ARRAY taResult

LOCAL liResult, llResult, lnResult && {fr} nombre de lignes du Résultat {en} number of lines of Result

lnResult = 0

llResult = Type('taResult', 1) == 'A' AND Vartype(m.tc) == 'C' AND NOT Empty(m.tc)
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge(ICase(;
	cLangUser() = 'fr',	[au moins un paramètre invalide],; && copy-paste this line to add another language support
						[at least one parameter not conform]; && Default: English
	)))
IF m.llResult

	lnResult = ALines(taResult, m.tc, 1, ',', ';')
	FOR liResult = 1 TO m.lnResult
		taResult[m.liResult] = Evaluate(taResult[m.liResult])
	ENDFOR

	tiCols = Iif(Vartype(m.tiCols) == 'N' AND Int(tiCols) = m.tiCols, m.tiCols, 0)
	IF tiCols > 0
		lnResult = Ceiling(Alen(taResult) / m.tiCols)
		DIMENSION taResult[m.lnResult, m.tiCols]
	ENDIF
ENDIF

RETURN m.lnResult

* ===================================================================
FUNCTION aColsDelim && {fr} Tableau à 2 dim d'après un tableau à une dimension contenant du texte délimité {en} Array with 2 dimensins from an array with one dimension containing delimited text
LPARAMETERS ;
	taRow,; && @ {fr} Tableau à traiter et résultat en retour {en} Array to use and to return
	tcSeps,; && [,;<Chr(9)>|] {fr} Séparateur de colonnes (plus rapide en le précisant) {en} Column delimiter (faster when indicated)
	tuTypes && @ {fr} Types des colonnes (array ou liste) in 'CDGLNOQTUXYI' - les colonnes non précisées restent en caractères {en} Columns type (array or list) in 'CDGLNOQTUXYI' - when not indicated stay in character
EXTERNAL ARRAY taRow, tuTypes

LOCAL lnResult; && {fr} nombre de lignes {en} number of lines
, llResult;
, laSep[1], lcSep, llSep;
,	laRow[1], liRow, lcRow;
,	laCol[1], liCol, lnCol;
,	laType[1], lnType, llType

llResult = NOT laEmpty(@m.taRow) AND Alen(taRow,2) <= 1
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge(ICase(;
	cLangUser() = 'fr',	[le premier paramètre doit être un tableau à une dimension non vide : <<cLitteral(@m.taRow)>>],; && copy-paste this line to add another language support
						[first parameter must be an array with one dimension and not empty : <<cLitteral(@m.taRow)>>]; && Default: English
	)))
IF m.llResult

	lnResult = Alen(taRow, 1)

	* Tabuler les séparateurs de colonnes
	llSep = 1 = aChars(;
		  @m.laSep;
		, Iif(Vartype(m.tcSeps) == 'C' AND Lenc(m.tcSeps) > 0;
			, m.tcSeps;
			, [,;|] + TABUL;
		))

	* Calculer le nombre de colonnes et le séparateur s'il est ambigu
	lnCol = 0
	lcSep = Iif(m.llSep, m.tcSeps, Space(0))
	FOR EACH lcRow IN taRow
		lnCol = Max(m.lnCol, 1 + Iif(m.llSep;
							, Occurs(m.lcSep, m.lcRow);
							, aColsDelim_nColsSep(m.lcRow, @m.laSep, @m.lcSep);
							))
	ENDFOR
*		ASSERT Lenc(m.lcSep) = 1 MESSAGE cAssertMsg(Textmerge([<<Proper(Program())>>() n'a trouvé aucun séparateur, le tableau aura une seule colonne]))

	* Si le typage est demandé, forcer le nombre de colonnes à la spécification de types
	lnType = aVarType(@m.laType, @m.tuTypes)
	llType = m.lnType > 0
	lnCol = Max(m.lnCol, m.lnType)

	* Tabuler à deux dimensions
	DIMENSION laRow[m.lnResult, m.lnCol]
	laRow = Space(0)
	FOR liRow = 1 TO m.lnResult
		ALines(laCol, taRow[m.liRow], 1, m.lcSep)
		FOR liCol = 1 TO Alen(laCol)
			laRow[m.liRow, m.liCol] = laCol[m.liCol]
		ENDFOR
	ENDFOR
	DIMENSION taRow[m.lnResult, m.lnCol]
	Acopy(laRow, taRow)

	* Le cas échéant, typer les données
	IF m.llType

		FOR liCol = 1 TO Min(m.lnCol, m.lnType)
			FOR liRow = 1 TO m.lnResult
				taRow[m.liRow, m.liCol] = uValue(taRow[m.liRow, m.liCol], laType[m.liCol])
			ENDFOR
		ENDFOR
	ENDIF
ENDIF

RETURN m.lnResult

* -------------------------------------------------------------
FUNCTION aColsDelim_nColsSep && {fr} Nombre de colonnes et séparateur par défaut {en} Columns number and default separator
LPARAMETERS tcRow, taSep, tcSep

LOCAL lnResult;
, llResult;
, lcSep;
, lnSep;
, lcSepMax

lnResult = 0
lcSepMax = ''
FOR EACH lcSep IN taSep
	lnSep = Occurs(lcSep, m.tcRow)
	IF m.lnSep > m.lnResult
		lnResult = m.lnSep
		lcSepMax = m.lcSep
	ENDIF
ENDFOR

IF Lenc(m.tcSep) = 0
	tcSep = m.lcSepMax
	RETURN m.lnResult
ELSE
	llResult = Lenc(m.lcSepMax) = 0 OR m.lcSepMax == m.tcSep
	ASSERT m.llResult MESSAGE cAssertMsg(Textmerge(ICase(;
	cLangUser() = 'fr',	[Séparateur de colonne ambigu, veuillez préciser '<<m.lcSepMax>>' ou '<<m.tcSep>>'],; && copy-paste this line to add another language support
											[Column delimiter unusable, please explain '<<m.lcSepMax>>' or '<<m.tcSep>>']; && Default: English
	)))
	RETURN Iif(m.llResult, m.lnResult, 0)
ENDIF

EXTERNAL ARRAY taSep

* ===================================================================
FUNCTION aLinesCols && {fr} Tableau à 2 dim d'après un texte multiligne délimité {en} Array with 2 dimensions from a delimited multiline text
LPARAMETERS ;
	taResult,; && @ {fr} Résultat {en} Result
	tcTxt,; && {fr} Texte multiligne tabulé {en} Tabulated multiline text
	tcSep,; && [,;<Chr(9)>|] {fr} Séparateur de colonnes (plus rapide en le précisant) {en} Column separator (faster when specified)
	tuTypes && {fr} Types des colonnes (array ou liste) in 'CDGLNOQTUXYI' - les colonnes non précisées restent en caractères {en} Columns type (array or list) in 'CDGLNOQTUXYI' - when not indicated stay in character
EXTERNAL ARRAY taResult, tuTypes

LOCAL llResult, lnResult && {fr} lignes {en} lines

llResult = aClear(@m.taResult) AND Vartype(m.tcTxt) == 'C' AND NOT Empty(m.tcTxt)
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge(ICase(;
	cLangUser() = 'fr',	[Au moins un paramètre invalide],; && copy-paste this line to add another language support
											[At least one parameter is invalid]; && Default: English
	)))
IF m.llResult

	* Tabuler les lignes
	ALines(taResult, m.tcTxt)

	RETURN aColsDelim(@m.taResult, m.tcSep, @m.tuTypes)
ELSE
	RETURN 0
ENDIF

* -------------------------------------------------------------
PROCEDURE aLinesCols_test && Teste aLinesCols()

LOCAL loUnitTest as abUnitTest OF abDev.prg, laLinesCols[1], lcTxt, laType[2]
loUnitTest = NewObject('abUnitTest', 'abDev.prg')
TEXT TO lcTxt NOSHOW PRETEXT 1+2
	11	12
	21	22	23
	31	32	33	34	35
ENDTEXT

loUnitTest.Test(3, @m.laLinesCols, m.lcTxt, TABUL)
loUnitTest.Assert(5, Alen(laLinesCols, 2))

loUnitTest.Test(3, @m.laLinesCols, m.lcTxt, , 'N')
loUnitTest.Assert(21, laLinesCols[2,1])
loUnitTest.Assert('22', laLinesCols[2,2])

loUnitTest.Test(3, @m.laLinesCols, m.lcTxt, , 'N,N')
loUnitTest.Assert(21, laLinesCols[2,1])
loUnitTest.Assert(22, laLinesCols[2,2])

loUnitTest.Test(3, @m.laLinesCols, m.lcTxt, , 'N|N')
loUnitTest.Assert(21, laLinesCols[2,1])
loUnitTest.Assert(22, laLinesCols[2,2])

loUnitTest.Test(3, @m.laLinesCols, m.lcTxt, , 'II')
loUnitTest.Assert(21, laLinesCols[2,1])
loUnitTest.Assert(22, laLinesCols[2,2])

laType = 'I'
loUnitTest.Test(3, @m.laLinesCols, m.lcTxt, , @m.laType)
loUnitTest.Assert(21, laLinesCols[2,1])
loUnitTest.Assert(22, laLinesCols[2,2])

loUnitTest.Test(3, @m.laLinesCols, m.lcTxt, , Replicate('I', 6))
loUnitTest.Assert(21, laLinesCols[2,1])
loUnitTest.Assert(22, laLinesCols[2,2])
loUnitTest.Assert(0, laLinesCols[1,6]) && nombre de colonnes selon typage

RETURN loUnitTest.Result()

* ===================================================================
FUNCTION aReverse && {fr} Tableau inversé {en} Inverse array
LPARAMETERS taSrce && @ {fr} Tableau source {en} Source array
EXTERNAL ARRAY taSrce

IF Type('taSrce', 1) == 'A'

	LOCAL lnRow, liRow, lnCol, llCol, laDest[1]

	lnRow = Alen(taSrce, 1)
	lnCol = Alen(taSrce, 2)
	llCol = m.lnCol > 0
	IF m.llCol
		DIMENSION laDest[m.lnRow, m.lnCol]
	ELSE
		DIMENSION laDest[m.lnRow]
	ENDIF
	FOR liRow = 1 TO m.lnRow
		IF m.llCol
			Acopy(taSrce, laDest, Aelement(taSrce, m.liRow, 1), m.lnCol, Aelement(laDest, m.lnRow - m.liRow + 1, 1))
		ELSE
			Acopy(taSrce, laDest, m.liRow, 1, m.lnRow - m.liRow + 1)
		ENDIF
	ENDFOR
	Acopy(laDest, taSrce)
	RETURN m.lnRow
ELSE
	RETURN 0
ENDIF

* ===================================================================
FUNCTION aStrExtract && {fr} Occurences entre délimiteurs /!\ non imbriquées {en} Strings found between delimiters /!\ not nested
LPARAMETERS ;
	taResult,;
	tcString,;
	tcBeginDelim,; && {fr} Selon StrExtract() {en} as StrExtract()
	tcEndDelim,; && {fr} Selon StrExtract() {en} as StrExtract()
	tnFlag && {fr} Selon StrExtract() {en} as StrExtract()
EXTERNAL ARRAY taResult

LOCAL liResult, llFlag, lnResult

aClear(@m.taResult)
lnResult = Occurs(m.tcBeginDelim, m.tcString)
IF m.lnResult > 0

	tnFlag = Evl(m.tnFlag, 0)
	FOR liResult = 1 TO m.lnResult
		aPush(@m.taResult, StrExtract(m.tcString, m.tcBeginDelim, m.tcEndDelim, m.liResult, m.tnFlag))
	ENDFOR
ENDIF

RETURN m.lnResult

* ===================================================================
FUNCTION aToBase64 as Boolean
LPARAMETERS ;
	result as String; && @ out
, aa && @ out

EXTERNAL ARRAY aa

LOCAL success as Boolean;
, memFile as String;
, oResult as Exception

success = Type('m.aa', 1) == 'A'
IF m.success

	memFile = Addbs(Sys(2023)) + 'temp' + Cast(_VFP.processID as M) + '.mem'

	try

		save to (m.memFile) all like aa
		result = Strconv(FileToStr(m.memFile), 13)

		do case

		case Empty(m.result)
			success = cResultAdd(@m.result, [])

		case !FileDel(m.memFile,,, @m.result) && FileDelete() abandonné à cause d'un conflit avec FileDelete.exe de web connect

		endcase

	catch to oResult

		oResult = cException(m.oResult)
		success = .F.
		assert m.success message cAssertMsg(m.oResult)
		cResultAdd(@m.result, m.oResult)

	endtry

ELSE
	cResultAdd(@m.result, [])
ENDIF

RETURN m.success

* ===================================================================
FUNCTION aOfBase64 as Boolean
LPARAMETERS ;
	result as String; && @ out
, aa; && @ out
, base64 as String

EXTERNAL ARRAY aa

LOCAL success as Boolean;
, memFile as String;
, oResult as Exception

do case

case !Type('m.aa', 1) == 'A'
	success = cResultAdd(@m.result, [])
	assert m.success

case !ga_Type_IsChar(m.base64, .T.)
	success = cResultAdd(@m.result, [])
	assert m.success

otherwise

	memFile = Addbs(Sys(2023)) + 'temp' + Cast(_VFP.processID as M) + '.mem'

	try

		success = StrToFile(Strconv(m.base64, 14), m.memFile) > 0
		IF m.success
			restore from (m.memFile) additive
			success = FileDel(m.memFile,,, @m.result) && FileDelete() abandonné à cause d'un conflit avec FileDelete.exe de web connect
		ELSE
			cResultAdd(@m.result, [])
		ENDIF

	catch to oResult

		oResult = cException(m.oResult)
		success = .F.
		assert m.success message cAssertMsg(m.oResult)
		cResultAdd(@m.result, m.oResult)

	endtry

endcase

RETURN m.success
endfunc
