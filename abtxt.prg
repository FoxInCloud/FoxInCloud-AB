* abTxt.prg
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
FUNCTION cTronc	&& Chaîne tronquée à une longueur donnée en la terminant par "..."
LPARAMETERS ;
	tcChain,; && Chaine à tronquer
	tnTronc,; && [50] Nombre de caractères où la chaine totale doit tenir
	tlWord,; && [.F.] couper à la fin d'un mot
	tcDropped,; && @ [''] Partie éventuellement coupée
	tlEllipsNot,; && [.F.] Ne pas ajouter de points de suspension
	tcSep && [any] preferred separator

LOCAL lcResult;
, llResult;
, lcEllips;

STORE '' TO tcDropped, lcResult

llResult = Vartype(m.tcChain) == 'C'
ASSERT m.llResult MESSAGE "Required parameter tcChain is invalid"
IF m.llResult

	tnTronc = Iif(Vartype(m.tnTronc) == 'N' and m.tnTronc > 0, m.tnTronc, 50)

	* Si la chaîne est plus longue que la troncature
	lcResult = Iif(Empty(Substr(m.tcChain, m.tnTronc + 1));
		, Leftc(m.tcChain, m.tnTronc);
		, m.tcChain;
		)
	IF Len(m.lcResult) > m.tnTronc
	
		lcEllips = Iif(lTrue(m.tlEllipsNot);
			, '';
			, Chr(160) + Replicate('.', 3);
			)
		lcResult = Left(m.lcResult, m.tnTronc - Lenc(m.lcEllips))

		* Si coupure à la fin d'un mot
		IF lTrue(m.tlWord);
		 and (.F.;
			or ' ' $ m.lcResult;
		 	or ', ' $ m.lcResult;
		 	or '; ' $ m.lcResult;
		 	or '. ' $ m.lcResult;
		 	or '! ' $ m.lcResult;
		 	or '? ' $ m.lcResult;
		 	)

			tnTronc = Iif(ga_Type_IsChar(m.tcSep, .T.) and m.tcSep $ m.lcResult;
				, Ratc(';', m.lcResult) + Lenc(m.tcSep);
				, Max(;
						Ratc(' ', m.lcResult);
					, Ratc(', ', m.lcResult) + 2;
					, Ratc('; ', m.lcResult) + 2;
					, Ratc('. ', m.lcResult) + 2;
					, Ratc('! ', m.lcResult) + 2;
					, Ratc('? ', m.lcResult) + 2;
					);
				)
			IF m.tnTronc > 0
				lcResult = Trim(Leftc(m.lcResult, m.tnTronc - 1))
			ENDIF
		ENDIF
		
		lcResult = m.lcResult + m.lcEllips
		tcDropped = Alltrim(Substr(m.tcChain, m.tnTronc))
	ENDIF
ENDIF

RETURN m.lcResult
endfunc

* --------------------
PROCEDURE cTronc_test

LOCAL loTest AS abUnitTest OF abDev.prg, lcDropped
loTest = NewObject('abUnitTest', 'abDev.prg')

* _cliptext = Chr(160)

loTest.Test('891-1490, 791-14 ...', '891-1490, 791-1491, 1890, 2891 (Militärfzg. Mit geteilert Scheibe)', 20) && Len('891-1490, 791-14') = 16
loTest.Test('891-1490, ...', '891-1490, 791-1491, 1890, 2891 (Militärfzg. Mit geteilert Scheibe)', 20, .T., @m.lcDropped)
loTest.Assert('791-1491, 1890, 2891 (Militärfzg. Mit geteilert Scheibe)', m.lcDropped)

RETURN loTest.Result()

* ===================================================================
FUNCTION cJustified	&& Chaîne justifiée
LPARAMETERS ;
	tcChain,; && Chaîne à justifier
	tnCols && [80] Nombre de colonnes
tcChain = Iif(Vartype(m.tcChain) == 'C', m.tcChain, '')
tnCols = Evl(m.tnCols, 80)

LOCAL lnLine, laLine[1], liLine, lcLine

lnLine = ALines(laLine, m.tcChain)
IF m.lnLine > 0
	
	FOR liLine = 1 TO m.lnLine
		lcLine = laLine[m.liLine]
		laLine[m.liLine] = Space(0)
		DO WHILE NOT Empty(m.lcLine)
			laLine[m.liLine] = c2Words(laLine[m.liLine], CRLF, cTronc(m.lcLine, m.tnCols, .T., @m.lcLine, .T.))
		ENDDO
	ENDFOR

	RETURN cListOfArray(@m.laLine, CRLF,,,.T.) + Iif(m.lnLine > 1, CRLF, '')
ELSE
	RETURN ''
ENDIF

* ===================================================================
FUNCTION cWords && Mots séparés par paires non vides
LPARAMETERS ;
	tuSep,; && Séparateur
	tuW0,;	&& tableau de mots (1 dim.) ou premier mot
	tuW1, tuW2, tuW3, tuW4, tuW5, tuW6, tuW7, tuW8, tuW9, tuW10, tuW11, tuW12, tuW13, tuW14, tuW15, tuW16, tuW17, tuW18, tuW19, tuW20, tuW21, tuW22, tuW23, tuW24 && [''] mots suivants

LOCAL lcResult
lcResult = Space(0)

IF NOT Vartype(m.tuSep) == 'L'
	LOCAL lnWord

 	IF Type('tuW0',1) <> 'A' && not an array
 		IF Pcount() > 2
	 		FOR m.lnWord = 0 TO Pcount()-2
	 			lcResult = c2Words(m.lcResult, m.tuSep, Evaluate('m.tuW' + lTrim(Str(m.lnWord))))
	 		ENDFOR
	 	ENDIF

 	ELSE
 		EXTERNAL ARRAY tuW0
 		FOR m.lnWord = 1 TO Alen(m.tuW0)
 			lcResult = c2Words(m.lcResult, m.tuSep, m.tuW0[m.lnWord])
 		ENDFOR
 	ENDIF
ENDIF

RETURN m.lcResult

* -----------------------------------------------------------------
PROCEDURE cWords_test
? Sys(16)

? cWords('/', Space(0), 10, .F., 'moi') == '10/.F./moi'

LOCAL ARRAY laW[6]
laW[1] = 'thierry'
laW[2] = 15
laW[3] = .F.
laW[4] = Space(0)
laW[5] = 0
laW[6] = CreateObject('form')
? cWords(',', @m.laW) == 'thierry,15,.F.,0'
laW[6] = NULL

* ===================================================================
FUNCTION c2Words && Deux mots séparés si non vides
LPARAMETERS ;
	tuW1,; && Premier mot, type variable
	tuSep,; && Séparateur, type variable
	tuW2 && Second mot, type variable

LOCAL llW1Empty, llW2Empty, lcSep, lnSep, lcW1, lcW2

llW1Empty = Vartype(m.tuW1) == 'C' AND Empty(m.tuW1) OR Vartype(m.tuW1) $ 'OGXU'
llW2Empty = Vartype(m.tuW2) == 'C' AND Empty(m.tuW2) OR Vartype(m.tuW2) $ 'OGXU'

DO CASE
CASE Pcount() < 3
	RETURN Iif(m.llW1Empty, Space(0), Transform(m.tuW1))

CASE NOT (m.llW1Empty OR m.llW2Empty)
	lcSep = Transform(m.tuSep)
	lnSep = Lenc(m.lcSep)
	lcW1 = Transform(m.tuW1)
	lcW2 = Transform(m.tuW2)

	RETURN '';
	 + Iif(Rightc(m.lcW1, m.lnSep) == m.lcSep, Leftc(m.lcW1, Lenc(m.lcW1)-m.lnSep), m.lcW1);
	 + m.lcSep;
	 + Iif(Leftc(m.lcW2, m.lnSep) == m.lcSep, Rightc(m.lcW2, Lenc(m.lcW2)-m.lnSep), m.lcW2)

CASE m.llW1Empty
	RETURN Transform(m.tuW2)

OTHERWISE && CASE m.llW2Empty
	RETURN Transform(m.tuW1)
ENDCASE

* -----------------------------------------------------------------
PROCEDURE c2Words_test

LOCAL loTest AS abUnitTest OF abDev.prg
loTest = NewObject('abUnitTest', 'abDev.prg')

loTest.Test('toto', 'toto')
loTest.Test('toto', 'toto', ' est ')
loTest.Test('content', '', ' est ', 'content')
loTest.Test('toto', 'toto', ' est ', '')

loTest.Test('toto est content', 'toto', ' est ', 'content')
loTest.Test("l'age de toto est 10", "l'age de toto", ' est ', 10)

loTest.Test("test;test", "test;", ';', ';test')

loTest.EnvSet([SET DATE FRENCH])
loTest.EnvSet([SET CENTURY ON])
loTest.Test("Je suis né le 05/08/1955", "Je suis né", ' le ', Date(1955,8,5))

RETURN loTest.Result()

* ===================================================================
FUNCTION cC && Alias de cComparable()
LPARAMETERS ;
	tc,; && Texte source
	tnLength && [trim] Si > 0, le résultat est paddé à cette longueur (pour index)

return cComparable(m.tc, m.tnLength)

* ===================================================================
FUNCTION cComparable && Texte débarrassé de ses variantes typographiques pour comparaison
LPARAMETERS ;
	tc,; && Texte source
	tnLength && [trim] Si > 0, le résultat est paddé à cette longueur (pour index)

LOCAL lcChars, lcResult && Texte comparable

DO CASE
CASE IsNull(m.tc) OR Empty(m.tc)
	lcResult = Space(0)

CASE Vartype(m.tc) == 'C'
	lcResult = Upper(Alltrim(m.tc))
	lcResult = cEuroANSI(m.lcResult) && désaccentue
	lcChars  = Chrtran(m.EuroAnsi, '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz ', '')
	lcResult = Chrtran(m.lcResult, m.lcChars, Space(Len(m.lcChars))) && ne garde que les caractères alphanumériques et les espaces
	lcResult = cRepCharDel(m.lcResult) && supprime les double espaces
	lcResult = cSpaceAroundGroup(m.lcResult) && normalise le nombre d'espaces autour des caractères de groupement

OTHERWISE
	lcResult = Space(0)
ENDCASE

IF Vartype(m.tnLength) == 'N' AND m.tnLength > 0
	lcResult = Padr(m.lcResult, m.tnLength)
ENDIF

RETURN m.lcResult

* -----------------------------------------------------------------
PROCEDURE cComparable_test

LOCAL loTest AS abUnitTest OF abDev.prg
loTest = NewObject('abUnitTest', 'abDev.prg')

loTest.Test('TOTO EST ENERVE', 'toto est  énervé')
loTest.Test([CA C EST SUR LE SAVOIR FAIRE D ABAQUE EST IMMENSE], [Ça c'est  sûr, le savoir-faire d'Abaque est immense])
loTest.Test(Space(50), .NULL., 50)

RETURN loTest.Result()

* ===================================================================
FUNCTION cRepCharsDel && Séquences de caractères identiques remplacées par un caractère simple
LPARAMETERS ;
	tcChain,;	&& Chaine de caractères à traiter
	tcChars && Caractère(s) dont les répétitions sont à éliminer

LOCAL lcChars, llResult, lcResult
lcResult = space(0)

llResult = Vartype(m.tcChain) = 'C' AND Vartype(m.tcChars)='C' AND Len(m.tcChars) > 0
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([paramètres invalides : <<m.tcChain>> | <<m.tcChars>>]))
IF m.llResult

	lcResult = m.tcChain

	lcChars = m.tcChars + m.tcChars 
	DO WHILE m.lcChars $ m.lcResult
		lcResult = Strtran(m.lcResult, m.lcChars, m.tcChars)
	ENDDO
ENDIF

RETURN lcResult

* ===================================================================
FUNCTION cRepCharDel && Séquences d'un caractère remplacées par un caractère simple
LPARAMETERS ;
	tcChain,;	&& Chaine de caractères à traiter
	tcChar && [space(1)] Caractère dont les répétitions sont à éliminer

IF Vartype(m.tcChain) = 'C'

	LOCAL lcResult, lcChar, lcChars

	lcResult = m.tcChain
	lcChar = Iif(Vartype(m.tcChar) == 'C' AND Len(m.tcChar) > 0, Left(m.tcChar, 1), Space(1))
	lcChars = Replicate(m.lcChar, 2)

	DO WHILE m.lcChars $ m.lcResult
		lcResult = Strtran(m.lcResult, m.lcChars, m.lcChar)
	ENDDO

	RETURN m.lcResult
ELSE
	RETURN ''
ENDIF

* -----------------------------------------------------------------
PROCEDURE cRepCharDel_Test	&& Tests cRepCharDel

LOCAL loTest AS abUnitTest OF abDev.prg
loTest = NewObject('abUnitTest', 'abDev.prg')

loTest.Test('appuie-tête', 'appuie--tête', '-')
loTest.Test('appuie tête', 'appuie  tête')
loTest.Test('appuie-tête', 'appuie----------------tête', '-')

RETURN loTest.Result()

* ===================================================================
FUNCTION cSpaceAround	&& Chaîne où les nombres d'Space(1) avant et après une sous-chaîne donnée sont normalisés
LPARAMETERS ;
	tcChain, ; && Chaine à traiter
	tcSubChain, ; && Sous-chaine dont les espaces avant - après sont à normaliser
	tnBefore, ;	&& [0] Nombre d'espaces avant la sous-chaine
	tnAfter && [tnBefore] Nombre d'espaces après la sous-chaine

IF Vartype(m.tcChain) == 'C';
 AND Vartype(m.tcSubChain) == 'C' ;
 AND ! Empty(m.tcSubChain) ;
 AND m.tcSubChain $ m.tcChain
	lcResult = m.tcChain

	* Delete spaces before and after character chain
	DO WHILE Space(1) + m.tcSubChain $ m.lcResult
		lcResult = Strtran(m.lcResult, Space(1)+m.tcSubChain, m.tcSubChain)
	ENDDO
	DO WHILE m.tcSubChain + Space(1) $ m.lcResult
		lcResult = Strtran(m.lcResult, m.tcSubChain+Space(1), m.tcSubChain)
	ENDDO

	* Add the required number of spaces before and after character chain
	tnBefore = Iif(Vartype(m.tnBefore)='N' AND m.tnBefore > 0, m.tnBefore, 0)
	tnAfter = Iif(Vartype(tnAfter)='N' AND m.tnAfter > 0, m.tnAfter, m.tnBefore)

	RETURN Strtran(m.lcResult ;
						, m.tcSubChain ;
						, Replicate(Space(1), m.tnBefore) + m.tcSubChain + Replicate(Space(1), m.tnAfter))

ELSE

	RETURN m.tcChain
ENDIF

* -----------------------------------------------------------------
PROCEDURE cSpaceAround_Test

LOCAL loTest AS abUnitTest OF abDev.prg
loTest = NewObject('abUnitTest', 'abDev.prg')

loTest.Test('appuie   -   tête', 'appuie - tête', '-', 3)
loTest.Test('10.150 F, FL', '10.150 F,FL', [,], 0, 1)

RETURN loTest.Result()

* ===================================================================
FUNCTION cSpaceAroundGroup	&& Chaîne où le nombre d'Space(1) autour des caractères de groupement '({[]})' est normalisé
LPARAMETERS tcChain && Chaîne

LOCAL lcResult
lcResult = Space(0)

#DEFINE GROUPCAR_OPEN		'([{'
#DEFINE GROUPCAR_CLOSE	')]}'

IF Vartype(m.tcChain)='C' ;
 AND NOT Empty(m.tcChain)
 m.tcChain = cRepCharDel(m.tcChain)

 LOCAL lnCar, lcCar, llGroupCarOpen, llGroupCarClose, llSpace
 FOR m.lnCar = 1 TO Len(m.tcChain)
 	lcCar = Substrc(m.tcChain, m.lnCar, 1)

 	DO CASE
	CASE m.lcCar == Space(1)
		lcResult = m.lcResult + Iif(m.llGroupCarOpen, Space(0), m.lcCar)
	CASE m.lcCar $ GROUPCAR_OPEN
		lcResult = Iif(m.llSpace, m.lcResult, m.lcResult + Space(1)) + m.lcCar
	CASE m.lcCar $ GROUPCAR_CLOSE
		lcResult = Iif(m.llSpace, Left(m.lcResult, Len(m.lcResult)-1), m.lcResult) + m.lcCar
	OTHERWISE
		lcResult = m.lcResult + Iif(m.llGroupCarClose, Space(1), Space(0)) + m.lcCar
	ENDCASE

	llSpace = m.lcCar == Space(1)
 	llGroupCarOpen = m.lcCar $ GROUPCAR_OPEN
 	llGroupCarClose = m.lcCar $ GROUPCAR_CLOSE
 ENDFOR
ENDIF

RETURN m.lcResult

* -----------------------------------------------------------------
PROCEDURE cSpaceAroundGroup_test

LOCAL loTest AS abUnitTest OF abDev.prg
loTest = NewObject('abUnitTest', 'abDev.prg') && NewObject('abUnitTest', 'abDev.prg')

loTest.Test('abc ((efg))', 'abc ( (efg ))')
loTest.Test('abc [(efg)]', 'abc [ (efg )]')
loTest.Test('abc [(efg)] toto', 'abc[ ( efg )]toto')
loTest.Test('Cabriolet (8G) 91-', 'Cabriolet  (  8G  )  91-')
loTest.Test('Cabriolet (8G) 91-', 'Cabriolet(8G)91-')
loTest.Test('Cabriolet (8G) 91-', 'Cabriolet (8G) 91-')

RETURN loTest.Result()

* ===================================================================
FUNCTION cSepGrpsXFigs	&& Groupe les chiffres dans une chaîne de caractères
LPARAMETERS ;
	tcChain,; && Chaine à traiter
	tnFactGroup,;	&& [3] Facteur de regroupement des groupes de chiffres
	tcSep && [Space(1)] Caractère de séparation des groupes de chiffres
LOCAL lcResult
STORE Space(0) TO m.lcResult

* Si une chaine valide a été passée
IF Vartype(m.tcChain) == 'C'

	LOCAL lcChain, lnChain
	lcChain = Alltrim(m.tcChain)
	lnChain = Len(m.lcChain)
	lcResult = m.lcChain

	* Donner leur valeur par défaut aux paramètres optionnels
	LOCAL lnFactGroup, lcSep
	lnFactGroup = ;
		Iif	(Vartype(m.tnFactGroup) == 'N' ;
					AND m.tnFactGroup > 0 ;
					AND m.tnFactGroup < m.lnChain ;	&& aberrant
					, m.tnFactGroup, 3)
	lcSep = Iif(Vartype(m.tcSep)=='C' AND NOT Empty(m.tcSep), Left(Ltrim(m.tcSep), 1), Space(1))

	IF m.lnFactGroup < m.lnChain

		* Pour chaque caractère en partant de la fin
		LOCAL lnCar, lcCar, lnChiffres, llSepAj
		lnChiffres = 0
		lcResult = Space(0)
		FOR m.lnCar = m.lnChain TO 1 STEP -1

			lcCar = Substr(m.lcChain, m.lnCar, 1)
			DO CASE

			CASE IsDigit(m.lcCar)
				lnChiffres = m.lnChiffres + 1
				IF m.lnChiffres = m.lnFactGroup ;
				 AND m.lnCar > 1 && ne pas ajouter de séparateur devant le 1er caractère !
					lnChiffres = 0
					lcCar = m.lcSep + m.lcCar
					llSepAj = .T.
				ELSE
					llSepAj = .F.
				ENDIF

			CASE m.lcCar == m.lcSep
				IF m.llSepAj
					* Ce séparateur fait double emploi 
					* Avec celui que l'on vient d'ajouter ;
					* Ne pas le garder
					LOOP
				ENDIF

			OTHERWISE	&& ni chiffre ni séparateur

				* Si un séparateur vient d'être ajouté, le supprimer.
				IF m.llSepAj
					lcResult = Substr(m.lcResult, 2)
				ENDIF
				lnChiffres = 0
				llSepAj = .F.
			ENDCASE

			lcResult = m.lcCar + m.lcResult
		ENDFOR
	ENDIF
ENDIF

RETURN lcResult

* -----------------------------------------------------------------
PROCEDURE cSepGrpsXFigs_Test	&& Teste cSepGrpsXFigs

? Sys(16)
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
FUNCTION cListOfArrayC && Liste délimitée du contenu d'un tableau caractère
LPARAMETERS ;
	taWords, ; && @ Mots de type C
	tcDelim, ; && [','] Délimiteur
	tnCol && [1] N° de colonne, -1 pour toutes les colonnes (tableau taWords à 2 dimensions)
EXTERNAL ARRAY taWords

&& /!\ en chantier

* ===================================================================
FUNCTION cListOfArray	&& Liste délimitée du contenu d'un tableau
LPARAMETERS ;
	taWords, ; && @ Mots de types divers (CNDTLY sont supportés)
	tcDelim, ; && [','] Délimiteur
	tnCol,; && [1] N° de colonne, -1 pour toutes les colonnes (tableau taWords à 2 dimensions)
	tlLitterals,; && [.F.] écrire les mots sous la forme de litteraux VFP (ex. foo > "foo",  02/07/03 > {^2003-02-07})
	tlKeepEmpty,; && [tlLitterals] Include empty words
	tlKeepNull,; && [tlLitterals] Include .NULL. words
	tlKeepWeird,; && [.F.] Include words of type G/U
	tlDistinct,; && [.F.] Élimine les doublons
	tlLines,; && [.F.] Séparer les lignes (tableau taWords à 2 dimensions et m.tnCol = -1)
	tnColFilter,; && [aucune] n° de colonne contenant un filtre des lignes à lister
	tlRtrimNot && [.F.] Ne pas supprimer les espaces en queue des éléments de type caractère

EXTERNAL ARRAY taWords

LOCAL lnCols;
, lcPoint, llPoint; && , loPoint
, liWord, luWord, lcWord;
, lcVarType, lcDelim, llRtrim;
, lcResult

lcResult = Space(0)

IF NOT laEmpty(@m.taWords)

	* Déterminer le nombre de colonnes du tableau
	lnCols = Alen(taWords, 2)

	* Donner leur valeur par défaut aux paramètres optionnels
	tcDelim = Iif(Vartype(m.tcDelim) == 'C' AND Lenc(m.tcDelim) > 0 , m.tcDelim, ',')
	tnCol = ICase(;
		m.lnCols = 0,; && tableau à 1 dimension
			0,;
		Vartype(m.tnCol) == 'N',;
			ICase(;
				Between(m.tnCol, 1, m.lnCols),;
			 		m.tnCol,;
				m.tnCol = -1,;
				 	0,;
					1;
				),;
			1;
		)
	tlLitterals = lTrue(m.tlLitterals)
	tlKeepEmpty = Iif(Pcount()>= 5 AND Vartype(m.tlKeepEmpty) == 'L', m.tlKeepEmpty, m.tlLitterals)
	tlKeepNull = Iif(Pcount()>= 6 AND Vartype(m.tlKeepNull) == 'L', m.tlKeepNull, m.tlLitterals)
	tlDistinct = lTrue(m.tlDistinct)
	tlLines = m.lnCols > 0 AND lTrue(m.tlLines) AND Vartype(m.tnCol) == 'N' AND m.tnCol <= 0
	tnColFilter = Iif(Vartype(m.tnColFilter) == 'N' ANd Between(m.tnColFilter, 1, m.lnCols), m.tnColFilter, 0)
	tlRtrimNot = lTrue(m.tlRtrimNot)
	llRtrim = !m.tlRtrimNot

	* Si le délimiteur peut entrer en conflit avec le séparateur décimal, changer celui-ci
	lcPoint = Set('POINT')
	llPoint = m.lcPoint $ m.tcDelim
	IF m.llPoint
		SET POINT TO ICase(;
					NOT '.' $ m.tcDelim, '.',;
					NOT ',' $ m.tcDelim, ',',;
					NOT ';' $ m.tcDelim, ';',;
					'?')

*-				loPoint = abSet('POINT', ICase(; && ne marche pas
*-									NOT '.' $ m.tcDelim, '.',;
*-									NOT ',' $ m.tcDelim, ',',;
*-									NOT ';' $ m.tcDelim, ';',;
*-									'?'),,, .T.)
	ENDIF

	* Pour chaque élément du tableau
	FOR liWord = 1 TO Iif(m.tnCol <= 0, Alen(m.taWords), Alen(m.taWords, 1))

		luWord = Iif(m.tnCol <= 0, taWords[m.liWord], taWords[m.liWord, m.tnCol])
		lcVarType = Vartype(m.luWord)
		
		* Si la valeur est valide
		IF .T.;
		 and m.lcVarType $ 'CNDTLYOX'; && G not supported
		 and (m.tlKeepNull OR NOT m.lcVarType == 'X');
		 and (m.lcVarType == 'O' OR m.tlKeepEmpty OR NOT Empty(m.luWord)); && Gestion des vides
		 and (m.tnColFilter = 0 OR NOT Empty(taWords[m.liWord, m.tnColFilter]))

			lcWord = ICase(;
				m.tlLitterals,;
					cLitteral(m.luWord, m.llRtrim),;
				m.lcVarType == 'C' and m.tlRtrimNot,;
					m.luWord,;
					Trim(Transform(m.luWord));
				)

			lcDelim = Iif(m.tlLines AND Asubscript(m.taWords, m.liWord, 2) = m.lnCols;
				, CRLF;
				, m.tcDelim;
				)
			
			* Si le mot n'est pas répété
			IF NOT (.T.;
				and m.tlDistinct;
				and (.F.;
					or m.lcDelim + m.lcWord + m.lcDelim $ m.lcResult;
					OR m.tcDelim + m.lcWord + m.tcDelim $ m.lcResult;
					OR Left(m.lcResult, Lenc(m.lcWord + m.lcDelim)) == m.lcWord + m.lcDelim;
					OR Left(m.lcResult, Lenc(m.lcWord + m.tcDelim)) == m.lcWord + m.tcDelim;
					);
				)

				lcResult = m.lcResult + m.lcWord + m.lcDelim
			ENDIF
		ENDIF
	ENDFOR

	IF m.llPoint
		SET POINT TO m.lcPoint
	ENDIF

	lcResult = Leftc(m.lcResult, Lenc(m.lcResult) - Lenc(Evl(m.lcDelim, ''))) && supprime le dernier délimiteur
ENDIF

RETURN m.lcResult

* -----------------------------------------------------------------
PROCEDURE cListofArray_Test

LOCAL loTest AS abUnitTest OF abDev.prg, laTest[1]
loTest = NewObject('abUnitTest', 'abDev.prg')

DIMENSION laTest [9]
laTest[1] = 'First'	&& C
laTest[2] = 2.25		&& N
laTest[3] = .T.		&& L
laTest[4] = Date(2003,2,8)	&& D
laTest[5] = Datetime(2003,2,8,11,34,15)	&& T
laTest[6] = space(0)	&& C Empty
laTest[7] = 0		&& N Empty
laTest[8] = .F.	&& L Empty
laTest[9] = {}	&& D Empty
loTest.Test('"First",2.25,.T.,{^2003-02-08},{^2003-02-08 11:34:15},"",0,.F.,{/}', @m.laTest,,,.T.)

DIMENSION laTest[5,2]
laTest= space(0)
laTest[1,2] = 'First'
laTest[2,2] = 'Second'
laTest[3,2] = '  '
laTest[4,2] = 'Fourth'
laTest[5,2] = 'Fifth'
loTest.Test('"First","Second","","Fourth","Fifth"', @m.laTest,,2,.T.)
loTest.Test('"","First","","Second","","","","Fourth","","Fifth"', @m.laTest,,-1,.T.)
loTest.Test('First,Second,Fourth,Fifth', @m.laTest,,-1)
loTest.Test(cWords(CRLF, 'First','Second','Fourth','Fifth'), @m.laTest,,-1,,,,,,.T.) && toutes les colonnes, sans les vides, lignes séparées par CRLF
loTest.Test(',First,,Second,,,,Fourth,,Fifth', @m.laTest,,-1,,.T.)

RETURN m.loTest.Result()

* ===================================================================
FUNCTION cPrintable	&& Chaine ne contenant que des caractères imprimables
LPARAMETERS ;
	tcChain && Chaine à normaliser

IF Vartype(m.tcChain) == 'C' ;
 AND NOT Empty(m.tcChain)

	RETURN cRepCharDel(Chrtranc(m.tcChain, NON_PRINTABLE, Space(Len(NON_PRINTABLE))))
ELSE
	RETURN Space(0)
ENDIF

* ===================================================================
FUNCTION cOfLitteral && Chaîne depuis un littéral
lparameters ;
  tcLitteral;
, tlLitteral && [.F.] return an empty string if tcLitteral is not a String literal

local result, length

result = Alltrim(m.tcLitteral)
length = Lenc(m.result) - 2

result = Alltrim(m.result, "'")
result = Iif(Lenc(m.result) = m.length;
	, m.result;
	, Alltrim(m.result, '"');
	)
result = Iif(Lenc(m.result) = m.length;
	, m.result;
	, Alltrim(m.result, '[', ']');
	)

return Iif(Lenc(m.result) = m.length;
	, m.result;
	, Iif(lTrue(m.tlLitteral), '', m.tcLitteral);
	)

* -----------------------------------------------------------------
PROCEDURE cOfLitteral_Test && 0,020 ms

LOCAL loTest AS abUnitTest OF abDev.prg
loTest = NewObject('abUnitTest', 'abDev.prg')

loTest.Test('test', [ 'test'])
loTest.Test(' test', [ " test"])
loTest.Test(' test ', " [ test ] ")
loTest.Test('', "  test ", .T.)

return m.loTest.result()

* ===================================================================
FUNCTION cL && Littéral VFP && Alias de cLitteral()
LPARAMETERS ;
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
FUNCTION cLitteral && Littéral VFP
LPARAMETERS ;
	tuData,; && @ Valeur à convertir en littéral (type supportés : tous soit CDGLNOQTUXY)
	tlRTrim,;  && [.F.] si type C, ôter les espaces à droite
	tnTronc,; && [aucun] si type C, nombre de caractères de troncature
	tlXML && [.F.] Encoder pour XML

#IF .F. && Vartype VFP9
	C && Character, Memo, Varchar, Varchar (Binary)
	D && Date 
	G && General 
	L && Logical 
	N && Numeric, Float, Double, or Integer
	O && Object
	Q && Blob, Varbinary
	T && DateTime 
	U && Unknown or variable does not exist
	X && Null
	Y && Currency
#ENDIF

LOCAL lcVarType
lcVarType = Vartype(m.tuData)

RETURN ICase(;
	Type('tuData', 1) == 'A',;
		'[' + cListOfArray(@m.tuData, ', ',-1,.T.,.T.,.T.,.T.) + ']',;
	m.lcVarType == 'C',;
		cLitteral_C(m.tuData, m.tlRTrim, m.tnTronc, m.tlXML),;
	m.lcVarType == 'L',;
		Iif(m.tuData, '.T.', '.F.'),;
	m.lcVarType $ 'DT',;
		cLitteralDTStrict(m.tuData),;
	m.lcVarType $ 'YN',;
		cLitteral_N(m.tuData, m.lcVarType),;
	m.lcVarType == 'X',;
		'.NULL.',;
	m.lcVarType == 'O',;
		cLitteral_O(m.tuData),;
	m.lcVarType == 'G',;
		'General',;
	m.lcVarType == 'Q',;
		'Blob, Varbinary',;
		'Unknown type';
)

* -----------------------------------------------------------------
FUNCTION cLitteral_C && Littéral VFP de type caractère
LPARAMETERS ;
	tcData, ; && Valeur à convertir en littéral (type supportés : tous soit CDGLNOQTUXY)
	tlRTrim,;  && [.F.] si type C, ôter les espaces à droite
	tnTronc,; && [aucun] si type C, nombre de caractères de troncature
	tlXML && [.F.] Encoder pour support XML


LOCAL lcResult as String;
, aa[1] as String;
, s as String;
, lcData as String;
, lnData as Integer;
, lcLine as String;
, lnTronc as Integer;

lcResult = ''
lnTronc = Iif(Vartype(m.tnTronc) == 'N' and Between(m.tnTronc, 1, 255), Int(m.tnTronc), 255) && Maximum length of a string literal : 255

if ALines(m.aa, m.tcData) > 0

	for each s in m.aa

		lnData = Lenc(m.s)

		s = Iif(lTrue(m.tlRTrim), Rtrim(m.s), m.s)
		s = Iif(lTrue(m.tlXML), cEscaped_XML(m.s), m.s)

		IF Vartype(m.tnTronc) == 'N'
			s = Iif(m.lnData > m.lnTronc, cTronc(m.s, m.lnTronc), m.s)
			lcLine = cLitteral_C_(m.s)
		ELSE
			IF m.lnData > 255 && limite d'un littéral caractère
				lcLine = ''
				lcData = m.s
				DO WHILE m.lnData > 0
					lcLine = m.lcLine + '+' + cLitteral_C_(Leftc(m.lcData, 255))
					lcData = Substrc(m.lcData, 256)
					lnData = m.lnData - 255
				ENDDO
				lcLine = Substr(m.lcLine, 2)
			ELSE
				lcLine = cLitteral_C_(m.s)
			ENDIF
		ENDIF

		lcResult = c2Words(m.lcResult, '+Chr(13)+Chr(10)+', m.lcLine)
	endfor
endif

return m.lcResult

* -----------------------------------------------------------------
FUNCTION cLitteral_C_(tcData)

RETURN ICase(;
	NOT ["] $ m.tcData,;
		["] + m.tcData + ["],; && Le plus généralement accepté
	NOT ['] $ m.tcData,;
		['] + m.tcData + ['],;
	NOT ('[' $ m.tcData OR ']' $ m.tcData),;
		'[' + m.tcData + ']',;
		cLitteral_C__(m.tcData);
	)

* -----------------------------------------------------------------
FUNCTION cLitteral_C__(tcData) && littéral d'un chaîne contenant ",[]

local lnAt;
, lnAtSimple, lnAtDouble, lnAtBracket;
, llAtSimple, llAtDouble, llAtBracket;
, result

result = ''

do while .T.
	lnAtSimple = At_c("'", m.tcData)
	lnAtDouble = At_c('"', m.tcData)
	lnAtBracket= Evl(;
		Min(At_c('[', m.tcData), At_c(']', m.tcData));
	, Max(At_c('[', m.tcData), At_c(']', m.tcData));
	)
	if m.lnAtSimple * m.lnAtDouble * m.lnAtBracket = 0
		result = m.result + '+' + cLitteral_C_(m.tcData)
		exit
	else
		lnAt = Max(m.lnAtSimple, m.lnAtDouble, m.lnAtBracket)
		llAtSimple = m.lnAt = m.lnAtSimple
		llAtDouble = m.lnAt = m.lnAtDouble
		llAtBracket= m.lnAt = m.lnAtBracket
		result = m.result;
			+ Iif(Empty(m.result), '', '+');
			+ ICase(;
				m.llAtSimple, "'",;
				m.llAtDouble, '"',;
				'[';
			);
			+ Substr(m.tcData, 1, m.lnAt-1);
			+ ICase(;
				m.llAtSimple, "'",;
				m.llAtDouble, '"',;
				']';
			)
		tcData = Substr(m.tcData, m.lnAt)
	endif
enddo

return m.result

* -----------------------------------------------------------------
FUNCTION cLitteral_N && Littéral VFP de type numérique
LPARAMETERS ;
	tuData,; && Nombre  à convertir en littéral
	lcVarType

RETURN Chrtran(;
	Iif(m.lcVarType = 'Y';
	, '$' + Alltrim(Str(m.tuData, 200, 6));
	, Transform(m.tuData);
	);
	, Set("Point"), '.') && Gregory Adam http://www.atoutfox.org/nntp.asp?ID=0000008895

* -----------------------------------------------------------------
FUNCTION cLitteral_O && Littéral VFP de type objet
LPARAMETERS toObject && Objet à convertir en littéral

LOCAL lcResult;
, loObject;
, aProp[1];
, iProp as Integer;
, cProps as String;
, cProp as String;

lcResult = ''

* Class

DO CASE

CASE Type('m.toObject.class') == 'C' and Type('m.toObject.classLibrary') == 'C' && FoxPro Object

	lcResult = cWords(', ';
		, 'class: ' + cL(m.toObject.class);
		, nEvl(m.toObject.classLibrary, 'classLibrary:' + cL(m.toObject.classLibrary));
		, Iif(Type('m.toObject.Parent') == 'O', 'location: ' + Sys(1272, m.toObject), '');
		, cLitteral_O_cProps(m.toObject);
		)

CASE Type('m.toObject.Application') == 'O' AND Type('m.toObject.Application.Name') == 'C' && and ! 'foxpro' $ Lower(m.toObject.Application.Name) && COM object? eg 'Microsoft Excel'
	lcResult = 'COM class: ' + m.toObject.Application.Name

CASE Type('m.toObject.class') == 'C' && weird Object
	lcResult = "class: " + m.toObject.class

otherwise && Empty Object

	lcResult = cWords(', ';
		, 'class: "Empty"';
		, cLitteral_O_cProps(m.toObject);
		)
ENDCASE

return nEvl(m.lcResult, 'Object {' + m.lcResult + '}')
endfunc

* -----------------------------------------------------------------
FUNCTION cLitteral_O_cProps && Propriétés d'un objet modifiées par rapport à sa classe
LPARAMETERS toObject && Objet à convertir en littéral

LOCAL lcResult as String;
, aProp[1];
, cProp as String;
, lProp as Boolean;
, aa[1];
, lArray as Boolean;

lcResult = ''

if AMembers(aProp, m.toObject) > 0 && can be an empty object without properties

	for each cProp in m.aProp
		lProp = !PemStatus(m.toObject, m.cProp, 2) && protected
		lArray = m.lProp and Type('m.toObject.' + m.cProp, 1) == 'A'
		do case
		case !m.lArray
		case Alen(m.toObject.&cProp, 2) > 0
			dimension aa[Alen(m.toObject.&cProp, 1), Alen(m.toObject.&cProp, 2)]
		otherwise
			dimension aa[Alen(m.toObject.&cProp, 1)]
		endcase
		if m.lArray
			Acopy(m.toObject.&cProp, m.aa)
		endif
		lcResult = m.lcResult + Iif(PemStatus(m.toObject, m.cProp, 0); && modified
			, ', ' + Lower(m.cProp) + ': ' + Iif(m.lProp;
				, Iif(m.lArray;
					, cL(@m.aa);
					, cL(Evaluate('m.toObject.' + m.cProp));
					);
				, '[hidden or protected]';
				);
			, '';
			)
	endfor
endif

return Ltrim(Substr(m.lcResult, 2))
endfunc

* -----------------------------------------------------------------
PROCEDURE cLitteral_Test && cLitteral() unit test

LOCAL loTest AS abUnitTest OF abDev.prg;
, luTest;
, luExpected;
, lcOnError;
, llError

loTest = NewObject('abUnitTest', 'abDev.prg')

loTest.Test([" foo"], ' foo') && C
loTest.Test(['" foo"'], '" foo"') && C
loTest.Test('[' + ["foo"'] + ']+"' + "[bar]'" + '"', '"foo"' + "'[bar]'") && C
loTest.Test('"' + Replicate('a', 255) + '"+[a' + ["foo"'] + ']+"' + "[bar]'" + '"';
	, Replicate('a', 256) + '"foo"' + "'[bar]'") && C

loTest.Test('2.5487', 2.5487) && N

loTest.Test('{^2003-02-08}', Date(2003,2,8)) && D

loTest.envset([SET SYSFORMATS ON])
loTest.Test('{^2003-02-08 11:34:15}', Datetime(2003,2,8,11,34,15)) && T
loTest.Test('.T.', .T.) && L

	luTest = $1254.25 && le littéral ne passe pas dans l'appel de méthode
loTest.Test('$1254.250000', m.luTest) && Y

	LOCAL loFoo AS Container
	loFoo = CreateObject('container')
	loFoo.Name = 'cntFoo'
	loFoo.AddObject('lblFoo', 'label')
* loTest.Test('Object of address: cntFoo.LBLFOO', m.loFoo.lblFoo)	&& O

&& G ???	

loTest.Test('.NULL.', .NULL.)	&& X

	lcOnError = On('error')
	ON ERROR m.llError = .T.
loTest.Test(Space(0), foo) && U = 'Unknown type'
	ON ERROR &lcOnError

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

RETURN loTest.Result()

* ===================================================================
FUNCTION cLitterals && Constantes
LPARAMETERS tu01,tu02, tu03, tu04, tu05, tu06, tu07, tu08, tu09, tu10, tu11, tu12, tu13, tu14, tu15 && Variables
LOCAL lnParm, lcResult
lcResult = Space(0)
IF Pcount() > 0
	FOR lnParm = 1 TO Pcount()
		lcResult = m.lcResult + cLitteral(Evaluate(Textmerge([m.tu<<Transform(m.lnParm, '@L 99')>>]))) + ','
	ENDFOR
	lcResult = Left(m.lcResult, Len(m.lcResult)-1) && supprime la dernière ','
ENDIF
RETURN m.lcResult

* -----------------------------------------------------------------
PROCEDURE cLitterals_Test && teste cLitteral

LOCAL loTest AS abUnitTest OF abDev.prg, lcTest
loTest = NewObject('abUnitTest', 'abDev.prg')

loTest.Test(["toto",2.5,.F.,{^2009-03-10}], 'toto', 2.5, .F., Date(2009,3,10))

RETURN loTest.Result()

* =============================================================
function cLitteralJS_HTML && Littéral Javascript d'après une valeur VFP pour ajout à un attribut HTML
lparameters ;
  tuData; && @ Valeur à convertir en littéral ; types supportés : cf. cLitteralJS_lSupport()
, tlTrim; && [.F.] si type C, ôter les espaces à droite

return Strtran(cLitteralJS(m.tuData, m.tlTrim), '"', '&#34;') && échappe les guillements '"' par '&#34;' pour le HTML

endfunc

* -----------------------------------------------
procedure cLitteralJS_HTML_Test && cLitteralJS_HTML() unit test

LOCAL loTest AS abUnitTest OF abDev.prg;
, loAsserts AS abSet OF abDev.prg;
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

LOCAL lcVarType, llResult, lcResult

lcResult = Space(0)

lcVarType = Type('tuData', 1)
lcVarType = Iif(m.lcVarType == 'A', m.lcVarType, Vartype(m.tuData))
DO CASE

CASE m.lcVarType == 'C'

	* Supprimer les caractères non imprimables 
	&& /!\ 2/8/07	conserver les sauts de ligne		lcResult = cPrintable(m.lcResult)

	* Encadrer la chaîne de délimiteur, échapper si nécessaire
*		return ["] + Strtran(Strtran(Iif(lTrue(m.tlTrim), Trim(m.tuData), m.tuData), '\', '\\'), ["], [\"]) + ["]
	return ICase(;
		lTrue(m.tlQuotesNo),;
		[];
			+ Strtran(Strtran(Strtran(Strtran(Iif(lTrue(m.tlTrim), Trim(m.tuData), m.tuData);
				, '\', '\\');
				, CRLF, '\n');
				, CR, '\n');
				, LF, '\n');
			+ [],;
		m.tlJSON,;
		[];
			+ ["];
			+ Strtran(Strtran(Strtran(Strtran(Strtran(Iif(lTrue(m.tlTrim), Trim(m.tuData), m.tuData);
				, '\', '\\');
				, ["], [\"]);
				, CRLF, '\n');
				, CR, '\n');
				, LF, '\n');
			+ ["],;
		[];
			+ ['];
			+ Strtran(Strtran(Strtran(Strtran(Strtran(Iif(lTrue(m.tlTrim), Trim(m.tuData), m.tuData);
				, '\', '\\');
				, ['], [\']); && see GA_STRINGPARSE_CLASS.MaskStrings(), parameter JSstring
				, CRLF, '\n');
				, CR, '\n');
				, LF, '\n');
			+ ['];
		)

CASE m.lcVarType $ 'DT'
	return Iif(m.tlJSON;
		, Textmerge(["<<Year(m.tuData)>>-<<Padl(Month(m.tuData), 2, '0')>>-<<Padl(Day(m.tuData), 2, '0')>>T<<Padl(Hour(m.tuData), 2, '0')>>:<<Padl(Minute(m.tuData), 2, '0')>>:<<Padl(Sec(m.tuData), 2, '0')>>Z"]);
		, 'new Date(' + cYMDHMS(m.tuData, .T.) + ')';
		)

CASE m.lcVarType == 'X'
	return 'null'

CASE m.lcVarType == 'L'
	return Iif(m.tuData, 'true', 'false')

CASE m.lcVarType == 'N'
	return Strtran(Transform(m.tuData), Set("Point"), '.')

CASE m.lcVarType == 'Y'
	return Strtran(Transform(Mton(m.tuData)), Set("Point"), '.')

CASE m.lcVarType == 'O' && Objet
	&& {V 1.25}
	llResult = cLitteralJS_lSupport(m.tuData, @m.lcResult)
	ASSERT m.llResult MESSAGE cAssertMsg(m.lcResult)
	IF m.llResult
	&& {V 1.25}

		LOCAL laProp[1], lcProp
		IF AMembers(laProp, m.tuData, 0, 'U') > 0 && 'U' : user-defined
			Asort(laProp)
			FOR EACH lcProp IN laProp
				IF NOT PemStatus(m.tuData, m.lcProp, 2) && protected
					lcResult = m.lcResult + ',"' + Lower(m.lcProp) + '":' + cLitteralJS(GetPem(m.tuData, m.lcProp),, .T.) && JSON compatible
				ENDIF
			NEXT
		ENDIF
		lcResult = '{' + Substr(m.lcResult, 2) + '}'
	ELSE
		lcResult = Space(0)
	ENDIF

CASE m.lcVarType == 'A' && Array
	IF NOT laEmpty(@m.tuData)
		LOCAL luElt
		FOR EACH luElt IN tuData
			lcResult = m.lcResult + ', ' + cLitteralJS(m.luElt, m.tlTrim)
		NEXT
	ENDIF
	lcResult = '[' + Substr(m.lcResult, 2) + ']'

OTHERWISE
	ASSERT .F. MESSAGE cAssertMsg(Textmerge([<<Program()>> could not build a JavaScript constant from <<m.tuData>> of type <<m.lcVarType>>]))
ENDCASE

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

LOCAL lcVartype, llResult

lcVarType = Type('tuData', 1)
lcVarType = Iif(m.lcVarType == 'A', m.lcVarType, Vartype(m.tuData))

DO CASE

CASE m.lcVartype $ 'ACDTXLYN'
	llResult = .T.

CASE m.lcVartype == 'O'	
	DO CASE
	
	CASE Type('m.tuData.Application.Name') == 'C' AND NOT 'foxpro' $ Lower(m.tuData.Application.Name)
		tcResult = Textmerge(ICase(;
			cLangUser() = 'fr',	[les objets non foxPro (<<m.tuData.Application.Name>>) ne sont pas supportés],;
													[non-FoxPro objects (<<m.tuData.Application.Name>>) are not supported]; && Default: English
		))
		
	CASE Type('m.tuData.Class') == 'U' && Empty class
		llResult = .T.
	
	CASE Type('m.tuData.BaseClass') == 'C' AND InList(m.tuData.BaseClass, 'Collection', 'Control', 'Olecontrol') && unsupported foxpro class
		tcResult = Textmerge(ICase(;
			cLangUser() = 'fr',	[la classe de base '<<m.tuData.BaseClass>>' n'est pas supportée],;
													[base class '<<m.tuData.BaseClass>>' is not supported]; && Default: English
		))
	OTHERWISE
		llResult = .T.
	ENDCASE

OTHERWISE
	tcResult = Textmerge(ICase(;
		cLangUser() = 'fr',	[le type '<<m.lcVartype>>' n'est pas supporté],;
												[type '<<m.lcVartype>>' is not supported]; && Default: English
	))

ENDCASE

return m.llResult

* -----------------------------------------------
procedure cLitteralJS_Test && cLitteralJS() unit test

LOCAL loTest AS abUnitTest OF abDev.prg;
, loAsserts AS abSet OF abDev.prg;
, luData as Variant

loTest = abUnitTest()
loAsserts = abSet('ASSERTS', 'OFF') && 'ON'

loTest.Test('4', 4)

loTest.Test(Space(0), CreateObject('Collection'))

loTest.Test(Space(0), CreateObject('Excel.Application'))

luData = CreateObject('Custom')
m.luData.AddProperty('car', 'a')
m.luData.AddProperty('num', 2)
m.luData.AddProperty('date', Date(2012,06,20))
loTest.Test('{"CAR":"a","DATE":"2012-06-20T00:00:00Z","NUM":2}', m.luData)

return m.loTest.Result()
	
* ===================================================================
FUNCTION uEmpty && Valeur vide selon les différents Type()
LPARAMETERS ;
	tuType,; && Type de valeur, ou valeur si m.tlValue
	tlValue && [.F.] tuType contient une valeur
tlValue = lTrue(m.tlValue)

#IF .F. && Types supportés
A	Array (only returned when the optional 1 parameter is included) 
ü	B	Double
ü	C	Character, Varchar, Varchar (Binary) 
ü	D	Date 
ü	F	Float
G	General 
ü	I	Integer
ü	L	Logical
ü	M	Memo 
ü	N	Numeric, Float, Double, or Integer
O	Object
ü	Q	Varbinary 
S	Screen 
ü	T	DateTime 
U	Undefined type of expression or cannot evaluate expression.
ü	V	Varchar
ü	W	Blob 
ü	Y	Currency 
#ENDIF

LOCAL lcType, llResult, luResult
luResult = .NULL.

IF m.tlValue
	lcType = Vartype(m.tuType)
	llResult = .T.
ELSE
	IF Vartype(m.tuType) == 'C' AND Len(m.tuType) = 1
		lcType = Upper(m.tuType)
		llResult = m.lcType $ 'BCDFILMNTVQWY' && 13 types
	ENDIF
	ASSERT m.llResult MESSAGE cAssertMsg(Textmerge("Spécification de type non supportée : <<cLitteral(m.tuType)>>"))
ENDIF
IF m.llResult

	luResult = ICase(.F., NULL;
		, m.lcType $ 'CMV', Space(Iif(m.tlValue, Lenc(m.tuType), 0));
		, m.lcType $ 'BFNYI', Iif(m.tlValue, m.tuType * 0, Iif(m.lcType == 'Y', $0, 0));
		, m.lcType $ 'D', Ctod('');
		, m.lcType $ 'T', Ctot('');
		, m.lcType $ 'L', .F.;
		, m.lcType $ 'QW', 0h; && Blob, Varbinary
		, .NULL.)
ENDIF

RETURN m.luResult

* ===================================================================
FUNCTION cLitteralNum && Littéral numérique d'après une chaine de caractères représentant un nombre
LPARAMETERS ;
	tcNum,; && Chaine de caractères supposée représenter un nombre
	tlPeriod && [.F.] séparateur décimal point (.F.: courant) [Val() veut courant, calcul et ALTER COLUMN veulent point]

LOCAL llResult, lcResult
lcResult = Space(0)

* Si le paramètre est de type caractère
llResult = InList(Vartype(m.tcNum), 'C', 'X')
ASSERT m.llResult MESSAGE Program() + Space(1) + "Paramètre de type caractère ou .NULL. attendu"
IF m.llResult
	
	* Si le paramètre peut représenter un nombre
	llResult = lNumber(m.tcNum)
	IF m.llResult
		
		* Supprimer les espaces et séparateurs de milliers éventuels
		LOCAL lcNum, lcSep, lcPoint
		lcNum = Alltrim(m.tcNum)
		lcSep = Set('Separator')
		lcPoint = Set('Point')
		lcNum = Iif(m.lcSep == m.lcPoint, m.lcNum, Chrtran(m.lcNum, m.lcSep, Space(0)))
		lcNum = Chrtran(m.lcNum, Space(1), Space(0))

		* Lire si séparateur décimal POINT demandé
		LOCAL llPeriod
		llPeriod = Iif(Vartype(m.tlPeriod) == 'L', m.tlPeriod, .F.)
		
		* Si la chaine comporte au plus un séparateur décimal
		LOCAL llPoint, lnPoints, lnPeriods
		llPoint = m.lcPoint == '.'
		lnPoints = Occurs(m.lcPoint, m.lcNum)
		lnPeriods = Iif(m.llPoint, 0, Occurs('.', m.lcNum))
		llResult = m.lnPoints + m.lnPeriods <= 1
		IF m.llResult
		
			* Si le séparateur courant n'est pas le point
			IF NOT m.llPoint

				* Ajuster le séparateur si nécessaire
				DO CASE
				CASE m.llPeriod AND m.lnPoints = 1
					lcNum = Chrtran(m.lcNum, m.lcPoint, '.')
				CASE NOT m.llPeriod AND m.lnPeriods = 1
					lcNum = Chrtran(m.lcNum, '.', m.lcPoint)
				ENDCASE
			ENDIF
			
			lcResult = m.lcNum
		ENDIF
	ENDIF
ENDIF

RETURN m.lcResult

* -----------------------------------------------------------------
PROCEDURE cLitteralNum_Test && teste cLitteralNum

LOCAL loTest AS abUnitTest OF abDev.prg
loTest = NewObject('abUnitTest', 'abDev.prg')
loTest.EnvSet([SET POINT TO ','])
loTest.EnvSet([SET SEPARATOR TO ' '])

loTest.Test('2021.50', ' 2 021,5 0', .T.)
loTest.Test('2021.50', ' 2 021.50', .T.)
loTest.Test('9,99', ' 9.99')
loTest.Test(',99', ' .99')

loTest.EnvSet([SET POINT TO])
loTest.Test('9.99', ' 9.99')

RETURN loTest.Result()

* ===================================================================
FUNCTION cLitteralDTStrict && Littéral Date [-Heure] selon le format VFP strict (avec le siècle)
LPARAMETERS tuDT && Date ou DateTime à convertir

LOCAL lcVarType, lcResult

lcVarType = Vartype(m.tuDT)
IF m.lcVarType $ 'DT' AND NOT Empty(m.tuDT)

	lcResult = '^' + 	;
			Alltrim(Str(Year(m.tuDT)))+ '-' + ;
			Padl(Alltrim(Str(Month(m.tuDT))), 2, '0') + '-' + ;
			Padl(Alltrim(Str(Day(m.tuDT),2)), 2, '0') && Transform(Dtos(m.tuDT), '@R {^####/##/##') + '}' && Gregory Adam

	RETURN Iif(m.lcVarType = 'D';
		, '{' + m.lcResult + '}';
		, '{' + m.lcResult + Space(1) + Ttoc(m.tuDT, 2) + '}';
		)
ELSE

	RETURN Iif(m.lcVarType = 'T', '{/:}', '{/}')
ENDIF

* -----------------------------------------------------------------
PROCEDURE cLitteralDTStrict_Test && teste cLitteralDTStrict()

LOCAL loTest AS abUnitTest OF abDev.prg
loTest = NewObject('abUnitTest', 'abDev.prg')

loTest.Test('{/}')
loTest.Test('{^2003-02-08}', Date(2003,2,8))

loTest.EnvSet([SET SYSFORMATS ON])
loTest.Test('{^2003-02-08 11:34:15}', Datetime(2003,2,8,11,34,15))

return loTest.Result()
endproc

* ===================================================================
FUNCTION cEuroANSI && Chaine de caractères désaccentuée
LPARAMETERS tuEuropean && type C : Chaine de caractères accentuée, .T. : supprimer les variables publiques créées

LOCAL lcVarType, lcResult && Chaine de caractères désaccentuée
lcResult = Space(0)

* Si le paramètre est correct
lcVarType = Vartype(m.tuEuropean)
DO CASE
CASE m.lcVarType == 'C' AND NOT Empty(m.tuEuropean)

 	* Si les chaines de traduction ne sont pas en mémoire, les lire
 	IF NOT Vartype(m.EuroANSI) == 'C'
		PUBLIC European, EuroANSI && pour accélérer les appels répétés
		EXTERNAL FILE european.mem
		RESTORE FROM (Home() + 'european.mem') ADDITIVE
	ENDIF

 	* Désaccentuer la chaine
	lcResult = Sys(15, m.EuroANSI, m.tuEuropean)

CASE m.lcVarType == 'L' AND m.tuEuropean
	RELEASE European, EuroANSI
ENDCASE

RETURN m.lcResult

* -----------------------------------------------------------------
PROCEDURE cEuroANSI_Test

LOCAL loTest AS abUnitTest OF abDev.prg
loTest = NewObject('abUnitTest', 'abDev.prg')
RELEASE European, EuroANSI 
loTest.Test('hebete', 'hébété')
loTest.Test('aaaeeeeioouu', 'àäâéèêëioòùû')
loTest.Test('AAAEEEEIOOUU', 'ÀÄÂÉÈÊËIOÒÙÛ')
loTest.Test(space(0), .T.)
loTest.Test(space(0), space(0))
loTest.Test(space(0), null)

RETURN loTest.Result()

* ===================================================================
FUNCTION cRandPW && Mot de passe aléatoire sûr selon indications Windows
LPARAMETERS ;
	tnLength,; && [14] Nombre de caractères
	tnSep && [0] Espacer par groupe tnSep caractères à partir de la droite
tnLength = Iif(Vartype(m.tnLength) = 'N' AND m.tnLength > 0, m.tnLength, 14)

LOCAL lcCars, lnCars, lnCar, lnSep, lcResult

* Générer une suite de caractères 'aléatoires' autorisés dans les mots de passe Windows
lcCars = ;
	'abcdefghikklmnopqrstuvwxyz' + ;
	'ABCDEFGHIKKLMNOPQRSTUVWXYZ' + ;
	'0123456789$' +;
	'!#$%&*()_+-={}|[]\";' +;
	['<>?,./]
lnCars = Len(m.lcCars)
lcResult = Space(0)
Rand(-1)

FOR m.lnCar = 1 TO m.tnLength
	lcResult = m.lcResult + Substr(m.lcCars, Evl(Int(Rand()*m.lnCars), 1), 1)
ENDFOR

* Si séparateurs demandés, placer
IF Vartype(m.tnSep) == 'N' AND Between(m.tnSep, 1, m.tnLength-1)
	lnSep = 0
	DO WHILE .T.
		lnSep = m.lnSep + m.tnSep
		IF m.lnSep > m.tnLength
			EXIT
		ENDIF
		lcResult = Substr(m.lcResult, 1, m.tnLength - m.lnSep) + Space(1) + Substr(m.lcResult, m.tnLength - m.lnSep + 1)
	ENDDO
	lcResult = Alltrim(m.lcResult)
ENDIF

RETURN m.lcResult

* ===================================================================
FUNCTION lNumber && Chaine de caractères représente un nombre
LPARAMETERS tcChain && Chaine à vérifier

LOCAL llResult, lcSeps, lcChain, lnChar, lcChar

* Si la chaine est correcte
IF Vartype(m.tcChain) == 'C' AND NOT Empty(m.tcChain)
 
	lcSeps = Set("Point") + Set("Separator") + [ .+-] && caractères non numériques possibles

 	lcChain = Alltrim(m.tcChain)
 	llResult = .T.
	FOR lnChar = 1 TO Lenc(m.lcChain)

		lcChar = Substr(m.lcChain, m.lnChar, 1) 
		IF NOT (IsDigit(m.lcChar) OR m.lcChar $ m.lcSeps)

			llResult = .F.
			EXIT
		ENDIF
	ENDFOR
ENDIF

RETURN m.llResult

* ===================================================================
FUNCTION lDigits && Chaine composée que de chiffres
LPARAMETERS tcChain && Chaine à vérifier

LOCAL llResult, lnChar

IF Vartype(m.tcChain) == 'C' AND NOT Empty(m.tcChain)
 
	llResult = .T.
	FOR m.lnChar = 1 TO Len(m.tcChain)
		IF NOT IsDigit(Substr(m.tcChain, m.lnChar))
			llResult = .F.
			EXIT
		ENDIF
	ENDFOR
ENDIF

RETURN m.llResult

* ===================================================================
FUNCTION nAtDigits	&& Position de la première série de chiffres dans une chaine
LPARAMETERS ;
	tcChain,; && Chaîne de caractère où chercher la suite de chiffres
	tnChiffres,; && Longueur de la suite de chiffres à trouver
	tlIgnoreSpace,;	&& [.F.] Ignorer les espaces au sein de la suite de chiffres
	tcChiffres && @ Chaîne de chiffres trouvée en retour
LOCAL lnResult, llResult
lnResult = 0
tcChiffres = space(0)

* Si les paramètres requis sont valides
llResult = Vartype(m.tcChain) == 'C' ;
 AND Vartype(m.tnChiffres) == 'N';
 AND m.tnChiffres > 0
ASSERT m.llResult MESSAGE "Paramètres requis invalides"
IF m.llResult

	* Si la chaine comporte plus de caractères que le nombre de chiffres cherché
	LOCAL lnChain
	lnChain = Len(m.tcChain) 
	IF m.lnChain >= m.tnChiffres
		LOCAL llIgnoreSpace
		llIgnoreSpace = Iif(Vartype(m.tlIgnoreSpace) =='L', m.tlIgnoreSpace, .F.)

		* Pour chaque position dans la chaine
		LOCAL lnStart, lcChiffres, lnSpaces, lnCar, lcCar, llChiffre
		FOR m.lnStart = 1 TO m.lnChain - m.tnChiffres + 1
			lcChiffres = space(0)
			lnSpaces = 0
			
			* Pour chaque caractère dans la limite du nombre de chiffres
			FOR m.lnCar = 0 to m.tnChiffres - 1
				lcCar = subStr (m.tcChain, m.lnStart + m.lnCar + m.lnSpaces, 1)

				* Si le caractère est invalide, décompter
				IF m.llIgnoreSpace ;
				 AND m.lcCar == Space(1) ;
				 AND m.lnCar > 0
					lnSpaces = m.lnSpaces + 1
					lnCar = m.lnCar - 1	&& impossible de modifier la borne sup de la boucle
				
				* Sinon (caractère valide)
				ELSE
				
					* Si le caractère est un chiffre, ajouter à la chaine de chiffres
					llChiffre = lNumChar(m.lcCar)
					IF m.llChiffre
						lcChiffres = m.lcChiffres + m.lcCar

					* Sinon, abandonner la recherche
					ELSE
						EXIT
					ENDIF
				ENDIF
			ENDFOR

			* Si la chaine de chiffres a été trouvée, sortir
			IF m.llChiffre
				EXIT
			ENDIF
		ENDFOR
		
		* Si la chaine de chiffres a été trouvée, mémoriser en retour
		IF llChiffre
			lnResult = m.lnStart
			tcChiffres = m.lcChiffres
		ENDIF
	ENDIF
ENDIF

RETURN lnResult

* -----------------------------------------------------------------
PROCEDURE nAtDigits_Test	&& Teste nAtDigits
? Sys(16)
LOCAL lcRet
lcRet = space(0)
? nAtDigits('0123456789', 3) = 1
? nAtDigits('0123456789', 3, .F., @m.lcRet) = 1 AND m.lcRet == '012'
? nAtDigits('01 23456789', 3, .F., @m.lcRet) = 4 AND m.lcRet == '234'
? nAtDigits('01 23456789', 3, .T., @m.lcRet) = 1 AND m.lcRet == '012'
? nAtDigits('012345678 9', 10, .F., @m.lcRet) = 0 AND m.lcRet == Space(0)
? nAtDigits('012345678 9', 10, .T., @m.lcRet) = 1 AND m.lcRet == '0123456789'
? nAtDigits('ABCDEF678 9', 4, .T., @m.lcRet) = 7 AND m.lcRet == '6789'
? nAtDigits('1 2 3ABCDEF678 9', 4, .T., @m.lcRet) = 12 AND m.lcRet == '6789'

* ===================================================================
FUNCTION nAtSep && Position du premier séparateur en partant de la gauche
LPARAMETER ;
	tcChain,;	&& Chaîne à analyser
	tcSeps,; && [".,:;|/\-_*#!$§£&"] Séparateurs recherchés
	tnOcc && [1] Numéro d'occurrence de séparateur recherchée
LOCAL lnResult && Position du séparateur dans la chaîne (= 0 si aucun)

lnResult = nLRAtSep ('L', m.tcChain, m.tcSeps, m.tnOcc)

RETURN m.lnResult

* ===================================================================
FUNCTION nRAtSep && Position du premier séparateur en partant de la droite
LPARAMETER ;
	tcChain,;	&& Chaîne à analyser
	tcSeps,; && [".,:;|/\-_*#!$§£&"] Séparateurs recherchés
	tnOcc && [1] Numéro d'occurrence de séparateur recherchée
LOCAL lnResult && Position du séparateur dans la chaîne (= 0 si aucun)

lnResult = nLRAtSep ('R', m.tcChain, m.tcSeps, m.tnOcc)

RETURN m.lnResult

* ===================================================================
FUNCTION nLRAtSep && Position du premier séparateur en partant de la gauche ou de la droite
LPARAMETER 	;
	tcSens,; && ['L'] indique s'il faut chercher en partant de la gauche (L) ou de la droite (R)
	tcChain,;	&& Chaîne à analyser
	tcSeps,; && [".,:;|/\-_*#!$§£&"] Séparateurs recherchés
	tnOcc && [1] Numéro d'occurrence de séparateur recherchée
LOCAL lnResult && Position du séparateur dans la chaîne (= 0 si aucun)
lnResult = 0

#DEFINE DEFAULT_SEP 	".,:;|/\-_*#!$§£&"

* Si une chaîne non vide a été passée
IF Vartype(m.tcChain) == 'C' ;
 AND NOT Empty(m.tcChain)

	* Régler les valeurs par défaut des paramètres optionnels
	LOCAL lcSens, lcSeps, lnOcc
	lcSens = Iif(Vartype(m.tcSens) = 'C', Upper(Left(Ltrim(m.tcSens),1)), 'L')
	lcSens = Iif(m.lcSens $ 'LR', m.lcSens, 'L')
	lcSeps = Iif(Vartype(m.tcSeps)='C' AND ! Empty(m.tcSeps), m.tcSeps, DEFAULT_SEP)
	lnOcc = Iif(Vartype(m.tnOcc)='N' and m.tnOcc > 0, m.tnOcc, 1)

	* Pour chaque séparateur
	LOCAL lnSep, lcSep
	For m.lnSep = 1 to Len(m.lcSeps)
		lcSep = Substr(m.lcSeps, m.lnSep, 1)

		* Si le séparateurs est dans le chaine, arrêter
		lnResult = Iif(m.lcSens = 'L', ;
											AT (m.lcSep, m.tcChain, m.lnOcc), ;
											RAT (m.lcSep, m.tcChain, m.lnOcc))
		IF m.lnResult > 0
			EXIT
		ENDIF
	ENDFOR
ENDIF

RETURN m.lnResult

* ===================================================================
FUNCTION cFigures && Chiffres contenus dans une chaîne de caractères
LPARAMETERS ;
	tcChain,; && Chaîne à analyser
	tlRight && [.F.] Chercher en partant de la droite
LOCAL lcResult	&&	Chiffres extraits dans l'ordre où ils se trouvent
lcResult = Space(0)

* Si la chaine comporte des caractères
IF Vartype(m.tcChain)='C' ;
 AND NOT Empty(m.tcChain)

	* Calculer la longueur de la chaine
	LOCAL lcChain, lnChain
	lcChain = Alltrim(m.tcChain)
	lnChain = Len(m.lcChain)
		
	* Déterminer le sens de recherche
	LOCAL llRight, lnStart, lnEnd, lnStep
	llRight = Iif(Vartype(m.tlRight)=='L', m.tlRight, .F.)
	lnStart = Iif(m.llRight, m.lnChain, 1)
	lnEnd = Iif(m.llRight, 1, m.lnChain)
	lnStep = Iif(m.llRight, -1, 1) 

	* Pour chaque caractère dans l'ordre demandé
	LOCAL lnCar, lcCar
	FOR m.lnCar = m.lnStart TO m.lnEnd STEP m.lnStep
		lcCar = Substr(m.lcChain, m.lnCar, 1)
		
		* Si le caractère est un chiffre, ajouter au résultat
		IF IsDigit(m.lcCar)
			lcResult = Iif(m.llRight, m.lcCar + m.lcResult, m.lcResult + m.lcCar)
		ENDIF
	ENDFOR
ENDIF

RETURN m.lcResult
	
* ===================================================================
FUNCTION lNumChar	&& Chaine de caractères commence par un chiffre, un séparateur ou un opérateur
LPARAMETERS tcChain
RETURN Iif(Vartype(m.tcChain)='C', ;
				IsDigit(m.tcChain) OR Left(m.tcChain, 1) $ Set('POINT') + '-+', ;
				NULL)

* -----------------------------------------------------------------
PROCEDURE lNumChar_Test	&& teste lNumChar
? Sys(16)

? IsNull(lNumChar (NULL))
? IsNull(lNumChar (854))
? NOT lNumChar ('')
? NOT lNumChar (' ')
? NOT lNumChar ('toto')
? NOT lNumChar (' 915')
? lNumChar ('915')

LOCAL lcPoint
lcPoint = Set('POINT')
SET POINT TO ','
? NOT lNumChar ('.915')
? lNumChar (',915')
SET POINT TO '.'
? lNumChar ('.915')
SET POINT TO (m.lcPoint)

* ===================================================================
FUNCTION lEmailAddrOK && Adresse courriel valide
LPARAMETERS tcEmailAddr && Adresse courriel à valider

LOCAL lceMailAddr, lnCar, llResult

&& réécrire avec RegExp : "^([0-9a-zA-Z]+([-.=_+&])*[0-9a-zA-Z]+)*@([-0-9a-zA-Z]+[.])+[a-zA-Z]{2,6}$"

* Si l'adresse est non vide
llResult = NOT Empty(m.tcEmailAddr)
IF m.llResult
	lceMailAddr = Upper(Alltrim(m.tcEmailAddr))

	* Si l'adresse ne comporte que des caractères autorisés
	FOR m.lnCar = 1 TO Lenc(m.lceMailAddr)
		llResult = Substr(m.lceMailAddr, m.lnCar, 1) $ "1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ@.-_"
		IF NOT m.llResult
			EXIT
		ENDIF
	ENDFOR
	IF m.llResult

		* Si l'adresse comporter un "@" un un seul
		llResult = Occurs("@", m.lceMailAddr) = 1
		IF m.llResult

			* Si l'adresse comporte au moins un point à droite de "@" (pour le nom de domaine)
			lnCar = Atc("@", m.lceMailAddr)
			llResult = Occurs('.', Substr(m.lceMailAddr, m.lnCar + 1)) > 0
		ENDIF 
	ENDIF
ENDIF

RETURN m.llResult			

* ===================================================================
FUNCTION cVFPNameSubStr && Nom VFP commençant à partir d'une position donnée dans une chaîne
LPARAMETERS ;
	tcChain,; && Chaine de caractère
	tnPos && Position du nom dans la chaîne; Si @, devient la position immédiatement après le nom trouvé
LOCAL lcResult
lcResult = Space(0)

* Move until first non-space character
DO WHILE Substr(m.tcChain, m.tnPos, 1) == Space(1)
	tnPos = m.tnPos + 1
ENDDO

* Check first character is alpha or '_'
LOCAL lcChar, llChar
lcChar = Substr(m.tcChain, m.tnPos, 1)
llChar = IsAlpha(m.lcChar) OR m.lcChar == '_'

* Check following characters
DO WHILE m.llChar
	lcResult = m.lcResult + m.lcChar
	tnPos = m.tnPos + 1
	lcChar = Substr(m.tcChain, m.tnPos, 1)
	llChar = IsAlpha(m.lcChar) OR m.lcChar == '_' OR IsDigit(m.lcChar)
ENDDO

RETURN m.lcResult

* --------------------
PROCEDURE cVFPNameSubStr_Test && teste cVFPNameSubStr()
? Sys(16)
? cVFPNameSubStr('lpara tcChain', 7) == 'tcChain'
? cVFPNameSubStr('lpara tcChain', 6) == 'tcChain'
? cVFPNameSubStr('lpara 3cChain', 7) == ''
? cVFPNameSubStr('lpara _cChain', 7) == '_cChain'

* ===================================================================
FUNCTION cParenth && Met une chaîne entre parenthèses ou autre signes encadrants
LPARAMETERS ;
	tcChain,; && chaine source
	tcParenth && [()] caractères d'encadement à ajouter
LOCAL llResult, lcResult && Chaine avec la référence ajoutée
lcResult = Space(0)

llResult = Vartype(m.tcChain) == 'C'
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge("Paramètre invalide: <<m.tcChain>>"))
IF m.llResult
	
	tcParenth = Iif(Vartype(m.tcParenth) == 'C' AND Lenc(Alltrim(m.tcParenth)) = 2, Alltrim(m.tcParenth), [()])
	lcResult = Iif(Empty(m.tcChain), m.tcChain, Leftc(m.tcParenth, 1) + m.tcChain + Rightc(m.tcParenth, 1))
ENDIF

RETURN m.lcResult

* ===================================================================
FUNCTION cRefAppend && {en} Appends a (reference) to a string {fr} Ajoute une référence entre parenthèses à la fin d'une chaîne
LPARAMETERS ;
	tcChain,; && {en} source string {fr} chaine source
	tuRef,; && {en} reference to append; .null. removes any existing reference {fr} Référence à ajouter ; .NULL. supprimer une référence existante éventuelle
	tlReplace,; && [.F.] {en} Replace an existing reference if any {fr} Remplacer une référence existante éventuelle
	tlNoZero,; && [.F.] {en} do not mention '0' {fr} Ne pas mentionner la valeur 0
	tcPrefix && [''] {en} prefix to the reference to be appended {fr} préfixe à la référence à ajouter

LOCAL lcResult; && Chaine avec la référence ajoutée
, llResult;
, liOpen, lcOpen;
, lnRat, lcRefType

lcResult = Nvl(Evl(m.tcChain, ''), '')

llResult = Vartype(m.lcResult) == 'C'
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge("Paramètre invalide: <<m.tcChain>>"))
IF m.llResult and !Empty(m.lcResult)

	tlReplace = lTrue(m.tlReplace) OR IsNull(m.tuRef)
	lcRefType = Vartype(m.tuRef)

	#define cRefAppend_OPENS '([{<'
	#define cRefAppend_CLOSE ')]}>'

	FOR liOpen = 1 TO Len(cRefAppend_OPENS)
		lcOpen = Substr(cRefAppend_OPENS, m.liOpen, 1)

		lnRat = Ratc(m.lcOpen, m.lcResult)
		IF m.lnRat = 0 OR m.tlReplace

			* ===================================================
			return Iif(.F.;
				 or m.lcRefType == 'X';
				 or m.lcRefType == 'N' AND lTrue(m.tlNoZero) AND Empty(m.tuRef);
				 or m.lcRefType == 'C' AND Empty(m.tuRef);
				 , Trim(Iif(m.lnRat > 0;
				   , Left(m.lcResult, m.lnRat-1);
				   , m.lcResult;
				   ));
				 , '';
					+ Trim(Iif(m.tlReplace AND m.lnRat > 0;
						, Left(m.lcResult, m.lnRat-1);
						, m.lcResult;
						));
					+ ' ';
					+ m.lcOpen;
					+ c2Words(;
						  Iif(ga_Type_IsChar(m.tcPrefix, .T.), Alltrim(m.tcPrefix), '');
						, ' ';
						, Alltrim(Transform(m.tuRef));
						);
					+ Substr(cRefAppend_CLOSE, m.liOpen, 1);
				 )
			* ===================================================

		endif
	endfor

	ASSERT .F. MESSAGE cAssertMsg(Textmerge("<<m.tcChain>> contains all opening characters: ") + cLitteral(cRefAppend_OPENS))
endif

RETURN m.lcResult

* -----------------------------------------------------------------
PROCEDURE cRefAppend_Test	&& Test unitaire de cRefAppend() && .060 ms - 60 µs

LOCAL loTest AS abUnitTest OF abDev.prg
loTest = NewObject('abUnitTest', 'abDev.prg')

loTest.Test('appuie-tête (1)', 'appuie-tête', 1)
loTest.Test('appuie tête (10)', 'appuie tête', 10)
loTest.Test('appuie-tête (2) [test]', 'appuie-tête (2)', 'test')
loTest.Test('appuie tête', 'appuie tête (10)', .null.)
loTest.Test('appuie tête (5)', 'appuie tête (10)', 5, .T.)
loTest.Test('appuie tête', 'appuie tête (10)', 0, .T., .T.)
loTest.Test('appuie tête (nombre: 5)', 'appuie tête (10)', 5, .T., , 'nombre: ')

RETURN loTest.Result()

* ===================================================================
FUNCTION lInList && Un mot se trouve dans une liste délimitée
LPARAMETERS ;
	tcWord,; && Mot à trouver
	tcList,; && Liste délimitée
	tcSep,; && [,] Séparateur de liste
	tlCase,; && [.F.] Respecter la casse
	tlExactCur && [.F.] Conserver Set("Exact") - .F. : SET EXACT ON

LOCAL laElts[1], llResult

llResult = Vartype(m.tcList) == 'C' AND Vartype(m.tcWord) == 'C'
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([la liste <<m.tcList>> et le mot <<m.tcWord>> doivent être de type caractère]))
IF m.llResult

	llResult = NOT (Empty(m.tcList) OR Empty(m.tcWord))
	IF m.llResult

		tcSep = Iif(Vartype(m.tcSep) == 'C' , Iif(Empty(m.tcSep), m.tcSep, Alltrim(m.tcSep)), ',')
*			tcSep = Iif(Lenc(m.tcSep) == 1, m.tcSep, ',')
		tlCase = lTrue(m.tlCase)
		tlExactCur = lTrue(m.tlExactCur)

		ALines(laElts, m.tcList, 1, m.tcSep)
		llResult = Ascan(laElts, Alltrim(m.tcWord), 1, -1, 1, Iif(m.tlCase, 0, 1) + Iif(m.tlExactCur, 0, 2+4)) > 0
	ENDIF
ENDIF

RETURN m.llResult

* ===================================================================
FUNCTION cListEdit && Ajoute ou supprime un élément d'une liste sans doublon
LPARAMETERS ;
	tcList,; && Liste à éditer
	tcElts,; && Élément(s) à ajouter / supprimer
	tlRemove,; && [.F.] Supprimer le ou les élément(s)
	tcSep,; && [,] Séparateur de liste
	tlCase && [.F.] Respecter la casse

LOCAL llResult, lcResult

llResult = Vartype(m.tcList) == 'C' AND Vartype(m.tcElts) == 'C'
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([la liste <<cLitteral(m.tcList)>> et le ou les élément(s) <<cLitteral(m.tcElts)>> doivent être de type caractère]))
IF m.llResult
	lcResult = m.tcList

	tlRemove = lTrue(m.tlRemove)
	tcSep = Iif(Vartype(m.tcSep) == 'C' AND Lenc(m.tcSep) == 1, m.tcSep, ',')
	tlCase = lTrue(m.tlCase)

	* Si des éléments sont spécifiés
	LOCAL ARRAY laElts[1]
*-			ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([Au moins un élément devrait être spécifié]))
	IF ALines(laElts, m.tcElts, 1+4, m.tcSep) > 0

		LOCAL lnItems, laItems[1], lnFlags, lcElt, lnElt, llElt

		* Tabuler la liste existante
		lnItems = ALines(laItems, m.tcList, 1+4, m.tcSep)
		
		* Pour chaque élément
		lnFlags = Iif(m.tlCase, 0, 1) + 2 + 4
		FOR EACH lcElt IN laElts
		
			* Voir si l'élément est dans la liste
			lnElt = Ascan(laItems, m.lcElt, 1, -1, 1, m.lnFlags)
			llElt = m.lnElt > 0
			
			* Si suppression et existe, supprimer
			IF m.tlRemove
				IF m.llElt
					Adel(laItems, m.lnElt)
					lnItems = m.lnItems - 1
				ENDIF

			* Sinon (ajout)
			ELSE
				IF NOT m.llElt
					lnItems = m.lnItems + 1
					DIMENSION laItems[m.lnItems]
					laItems[m.lnItems] = m.lcElt
				ENDIF
			ENDIF
		ENDFOR
		
		* Reconstituer la liste
		IF m.lnItems > 0
			lcResult = cListOfArray(@m.laItems)
		ENDIF
	ENDIF
ENDIF

RETURN m.lcResult

* -----------------------------------------------------------------
PROCEDURE lInList_Test

LOCAL loTest AS abUnitTest OF abDev.prg, lnAtc
loTest = NewObject('abUnitTest', 'abDev.prg')

loTest.Test(.T., 'dossier', 'DOSSIER, COND, SINISTRE')
loTest.Test(.F., 'dossier', 'DOSSIER, COND, SINISTRE', ';')
loTest.Test(.F., 'dossier', 'DOSSIER, COND, SINISTRE', , .T.)

RETURN loTest.Result()

* ===================================================================
FUNCTION lWordsIn && Plusieurs mots se trouvent dans une chaîne
LPARAMETERS ;
	tcWords,; && Mots à chercher
	tcChain,; && Chaine où chercher
	tlCaseIgnore,; && [.F.] Ignorer la casse
	tlAnyWord,; && [.F.] Traiter le mot même s'il comporte des caractère de séparation
	tnAtc,; && @ [1] position de début de recherche, en retour, position trouvée, 0 si pas trouvé
	tlOr && [.F.] Trouver au moins un des mots
tlOr = lTrue(m.tlOr)
 
LOCAL laWord[1], lcWord, llWord, llResult

llResult = Vartype(m.tcWords) == 'C' AND ALines(laWord, m.tcWords, 7, ',', ';') > 0
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge("<<Program()>> received invalid parameters"))
IF m.llResult

	llResult = NOT m.tlOr
	
	FOR EACH lcWord IN laWord

		llWord = lWordIn(m.lcWord, m.tcChain, m.tlCaseIgnore, m.tlAnyWord, m.tnAtc)

		IF m.tlOr
			IF m.llWord
				RETURN .T.
			ENDIF
		ELSE
			IF NOT m.llWord
				RETURN .F.
			ENDIF
		ENDIF
	ENDFOR
ENDIF

RETURN m.llResult

* ===================================================================
FUNCTION lWordIn && Un mot se trouve dans une chaîne
LPARAMETERS ;
	tcWord,; && Mot à chercher
	tcChain,; && Chaine où chercher
	tlCaseIgnore,; && [.F.] Ignorer la casse
	tlAnyWord,; && [.F.] Traiter le mot même s'il comporte des caractère de séparation
	tnAtc && @ [1] position de début de recherche, en retour, position trouvée, 0 si pas trouvé

LOCAL llResult

llResult = Vartype(m.tcChain) == 'C';
 AND Vartype(m.tcWord) == 'C';
 AND NOT (Empty(m.tcChain) OR Empty(m.tcWord));
 AND (lTrue(m.tlAnyWord);
 		 OR Chrtran(m.tcWord, VFPOPSEPCARS, Space(0)) == m.tcWord)
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge("<<Program()>> received invalid parameters"))
IF m.llResult

	tlCaseIgnore = lTrue(m.tlCaseIgnore)
	tnAtc = Iif(Vartype(m.tnAtc) == 'N' AND m.tnAtc > 0, m.tnAtc, 1)

	* Si le mot est présent dans la chaîne à partir de la position de départ
	LOCAL lcWord, lnWord, lcChain, lnAt, lcCarAnte, lcCarPost
	lcWord = Iif(m.tlCaseIgnore, Upper(m.tcWord), m.tcWord)
	lnWord = Len(m.lcWord)
	lcChain = Substr(Iif(m.tlCaseIgnore, Upper(m.tcChain), m.tcChain), m.tnAtc)
	tnAtc = m.tnAtc - 1 && piquets et intervalles !
	DO WHILE .T.

		lnAt = Atc(m.lcWord, m.lcChain)
		llResult = m.lnAt > 0
		IF m.llResult

			tnAtc = m.tnAtc + m.lnAt
			
			* Si le mot trouvé est encadré par un séparateur ou un opérateur
			lcCarAnte = Substr(m.lcChain, m.lnAt - 1, 1)
			lcCarPost = Substr(m.lcChain, m.lnAt + Len(m.tcWord), 1)

			llResult = (Empty(m.lcCarAnte) OR m.lcCarAnte $ VFPOPSEPCARS);
						 AND (Empty(m.lcCarPost) OR m.lcCarPost $ VFPOPSEPCARS)
			IF m.llResult
				EXIT
			ELSE
				lcChain = Substr(m.lcChain, m.lnAt + m.lnWord)
				tnAtc = m.tnAtc + m.lnWord - 1 && piquets et intervalles !
			ENDIF
		ELSE
			EXIT
		ENDIF
	ENDDO
ENDIF

tnAtc = Iif(m.llResult, m.tnAtc, 0)
	
RETURN m.llResult 

* -----------------------------------------------------------------
PROCEDURE lWordIn_Test

LOCAL loTest AS abUnitTest OF abDev.prg, lnAtc
loTest = NewObject('abUnitTest', 'abDev.prg')

loTest.Test(.T., 'le', 'je+suis-décidément le meilleur')
loTest.Test(.T., 'LE', 'je+suis-décidément le meilleur', .T.)
loTest.Test(.T., 'suis', 'je+suis-décidément le meilleur')

loTest.Test(.F., 'déci', 'je+suis-décidément le meilleur')
loTest.Test(.F., 'deci', 'je+suis-décidément le meilleur')
loTest.Test(.F., 'DÉCI', 'je+suis-décidément le meilleur')

loTest.Test(.T., 'nDOW', 'anDOW + cnDOW(nDOW)', .T., .T., @m.lnAtc)
loTest.assert(15, lnAtc)

lnAtc = 14
loTest.Test(.T., 'BATDUR', 'ISNULL(batdur).OR.BETWEEN(batdur,0,20)', .T.,, @m.lnAtc)
loTest.assert(27, lnAtc)

RETURN loTest.Result()

* ===================================================================
FUNCTION anWordIn && Positions d'un mot dans une chaîne
LPARAMETERS ;
	ta,; && @ Positions du mot
	tcChain,; && Chaine
	tcWord,; && Mot à chercher
	tlCaseIgnore,; && [.F.] Ignorer la casse
	tlAnyWord && [.F.] Traiter le mot même s'il comporte des caractère de séparation
EXTERNAL ARRAY ta

LOCAL lnAtc, lnResult && nombre de positions trouvées

lnResult = 0
IF aClear(@m.ta)

	lnAtc = 0
	DO WHILE .T.
		IF lWordIn(m.tcWord, m.tcChain, m.tlCaseIgnore, m.tlAnyWord, @m.lnAtc)
			lnResult = lnResult + 1
			DIMENSION ta[m.lnResult]
			ta[m.lnResult] = m.lnAtc
			lnAtc = lnAtc + Len(m.tcWord)
		ELSE
			EXIT
		ENDIF
	ENDDO
ENDIF

RETURN m.lnResult

* -----------------------------------------------------------------
PROCEDURE anWordIn_Test

LOCAL loTest AS abUnitTest OF abDev.prg
loTest = NewObject('abUnitTest', 'abDev.prg')
LOCAL ARRAY laTest[1]

loTest.Test(1, @m.laTest, 'je+suis-décidément le meilleur', 'le')
loTest.assert(20, laTest[1])

RETURN loTest.Result()

* ===================================================================
FUNCTION lExpression(m.tcExpr) && Une chaîne est une expression (alias de lExpr())
RETURN lExpr(m.tcExpr)

* ===================================================================
FUNCTION lExpr && Une chaîne est une expression /!\ simpliste!
LPARAMETERS tcExpr

local array laOps[1]

return .T.;
 and Vartype(m.tcExpr) == 'C';
 and aOperands(@m.laOps, Alltrim(m.tcExpr, ' ', '(', ')', '[' , ']')) > 1
	
* -----------------------------------------------------------------
PROCEDURE lExpr_Test

LOCAL loTest AS abUnitTest OF abDev.prg
loTest = NewObject('abUnitTest', 'abDev.prg')

loTest.Test(.T., 'toto = alias.field +fonction(alias.tutu)')
loTest.Test(.F., 'alias.tutu')
loTest.Test(.F., 'm.tutu')

RETURN loTest.Result()

* ===================================================================
FUNCTION aOperands && Opérandes d'une expression /!\ simpliste!
LPARAMETERS ;
	taOps,; && @ Opérande | position dans l'expression
	tcExp && Expression

* Si les paramètres sont valides
IF Type('taOps', 1) == 'A' AND Vartype(m.tcExp) == 'C'
	
	* Tabuler les opérandes
	LOCAL lcVFPOpSepCars
	lcVFPOpSepCars = VFPOPSEPCARSLIST && pour macro-substitution
	return ALines(taOps, m.tcExp, 1+4, &lcVFPOpSepCars)

ELSE
	ASSERT .F. MESSAGE cAssertMsg(Textmerge([received invalid parameters]))
	return 0

ENDIF

EXTERNAL ARRAY taOps
	
* -----------------------------------------------------------------
PROCEDURE aOperands_Test

LOCAL loTest AS abUnitTest OF abDev.prg, laOps[1]
loTest = NewObject('abUnitTest', 'abDev.prg')

loTest.Test(4, @m.laOps, 'toto = alias.field +fonction(alias.tutu)')
*	DISPLAY MEMORY LIKE laOps
loTest.Test(5, @m.laOps, 'toto = alias.field +fonction(alias.tutu + 5)')

RETURN loTest.Result()

* ===================================================================
FUNCTION cVFPOpSepCarsList && Opérateurs et séparateurs VFP séparés par une ','
LPARAMETERS tcCarsExclude && [''] Caractères à exclure

LOCAL lcResult;
, lcCars, lnCar

lcResult = Space(0)

* Lister les opérateurs et séparateurs
lcCars = Chrtran(VFPOPSEPCARS, uDefault(m.tcCarsExclude, Space(0)), Space(0))

FOR lnCar = 1 TO Len(m.lcCars)
	lcResult = m.lcResult + ',' + ['] + Substr(m.lcCars, m.lnCar, 1) + [']
ENDFOR

RETURN Substr(m.lcResult, 2) && supprime la ',' initiale

* ===================================================================
FUNCTION cFirstAlpha && Chaîne dont l'initiale est alphabétique
LPARAMETERS ;
	tcChain && Chaine
LOCAL llResult, lcResult
lcResult = Space(0)

llResult = Vartype(m.tcChain) == 'C'
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge("paramètre invalide: <<m.tcChain>>"))
IF m.llResult
	
	lcResult = m.tcChain
	DO WHILE NOT IsAlpha(m.lcResult)
		lcResult = Substr(m.lcResult, 2)
	ENDDO
ENDIF

RETURN m.lcResult
	
* -----------------------------------------------------------------
PROCEDURE cFirstAlpha_Test

LOCAL loTest AS abUnitTest OF abDev.prg
loTest = NewObject('abUnitTest', 'abDev.prg')

loTest.Test('ceci est un test', '123 ceci est un test')
loTest.Test('ceci est un test', '1$3 ceci est un test')
loTest.Test('ceci est un test', '1*3 ceci est un test')
loTest.Test('ceci est un test', '1"3 ceci est un test')

RETURN loTest.Result()

* ===================================================================
FUNCTION cUIDRand && Identifiant probablement unique de 14 caractères
Rand(-1)
RETURN Sys(2015) + Transform(Int(Rand()*1000), '@L 9999')

* ===================================================================
FUNCTION abRegExp && Objet abRegExp
LPARAMETERS ;
  tcPattern; && [''] Expression régulière de recherche
, tcFlags; && [''] commutateurs (igm)

local loResult as abRegExp of abTxt.prg

loResult = CreateObject('abRegExp') && # 5 ms
if Vartype(m.loResult) == 'O' and ga_Type_IsChar(m.tcPattern, .T.)
	m.loResult.Setup(m.tcPattern, Evl(m.tcFlags, ''))
endif

RETURN m.loResult
endfunc

* ----------------------
FUNCTION abRegExp_Test

LOCAL loTest AS abUnitTest OF abDev.prg
loTest = NewObject('abUnitTest', 'abDev.prg')
loTest.Test
RETURN loTest.Result()

* ===================================================================
DEFINE CLASS abRegExp AS GA_LIGHTWEIGHT_CLASS && Expression régulière ; Implements VBScript.RegExp
* ===================================================================

&& RÉGLAGES - cf. this.init() / this.setup()
Pattern = Space(0) && Masque d'expression régulière
IgnoreCase = .F. && Ignorer la casse dans les comparaisons
Global = .F. && Trouver toutes les occurrences ou la première seulement
Multiline = .F. && Le texte comporte plusieurs lignes && ^ = iif(Multiline, line start, chain start) $ = iif(Multiline, line end, chain end)

&& RÉSULTATS
nMatches = 0 && Nombre de résultats
DIMENSION Matches[1] && [index, match, submatches (collection), length]
	&& .Matches[?, 1] = index
	&& .Matches[?, 2] = match
	&& .Matches[?, 3] = submatches (collection)
	&& .Matches[?, 4] = length

PatternMatched = '' && si this.lPatterns, pattern qui satisfait this.Test()
nPattern = 0 && n° du Pattern courant, cf. this.Pattern_Assign()	

&& INTERNES
PROTECTED;
		oRegExp; && AS VBScript.RegExp
	,	nSeconds; && au début de this.Execute(), Seconds(); à la fin, durée
	,	lPatterns; && Patterns multiples, cf. this.Pattern_Assign()
	,	aPattern[1]; && Patterns multiples, cf. this.Pattern_Assign()
	,	lDebug && Afficher le résultat de this.execute() à l'écran et dans la fenêtre Debug

* -----------------------------------------------------------------
PROTECTED PROCEDURE Init
LPARAMETERS ;
	tlDebug,; && [.F.] Afficher le résultat de .execute() à l'écran et dans la fenêtre Debug
	tcResult && [''] @ Résultat de l'instanciation

LOCAL loException AS Exception, llResult

TRY

	this.lDebug = lTrue(m.tlDebug)
	
	* Si l'objet RegExp peut être créé
	this.oRegExp = CreateObject("VBscript.RegExp")
	llResult = Vartype(m.this.oRegExp) == 'O'
	IF m.llResult
		
		this.IgnoreCase = m.this.IgnoreCase && cf. this.IgnoreCase_assign()
		this.Global = m.this.Global && cf. this.Global_assign()
		this.Multiline = m.this.Multiline && cf. this.Multiline_assign()
	ENDIF
CATCH TO loException
	tcResult = cException(m.loException)
ENDTRY

RETURN m.llResult && .F. > objet non créé

* -----------------------------------------------------------------
PROTECTED FUNCTION cPatterns
LPARAMETERS ;
	tcFunction,; && Fonction qui 'fabrique' les patterns ('.xx' pour une méthode de cet objet ou 'xx' pour une fonction libre)
	tcParms && Paramètres à passer à la fonction pour 'fabriquer' les Patterns

LOCAL laParm[1], lcParm, lcResult

lcResult = Space(0)

IF ALines(laParm, m.tcParms) > 0 && cInLineCommentStripped(m.tcParms)

	tcFunction = Alltrim(m.tcFunction)
	FOR EACH lcParm IN laParm
		lcResult = m.lcResult + CRLF + Evaluate(m.tcFunction + '(m.lcParm)')
	ENDFOR
	lcResult = Substr(m.lcResult, 3)
ENDIF

RETURN m.lcResult

* -----------------------------------------------------------------
HIDDEN PROCEDURE Pattern_Assign
LPARAMETERS tcPattern && [''] Expression régulière de recherche
tcPattern = Iif(Vartype(m.tcPattern) == 'C', m.tcPattern, Space(0))

this.lPatterns = CR $ m.tcPattern

IF m.this.lPatterns
	ALines(m.this.aPattern, m.tcPattern) && cInLineCommentStripped(m.tcPattern)
ELSE
	STORE m.tcPattern TO this.Pattern, this.oRegExp.Pattern
ENDIF

* -----------------------------------------------------------------
HIDDEN PROCEDURE IgnoreCase_Assign
LPARAMETERS tlIgnoreCase && [.F.] Ignorer la casse dans les comparaisons

IF Vartype(m.tlIgnoreCase) == 'L'
	STORE m.tlIgnoreCase TO this.IgnoreCase, this.oRegExp.IgnoreCase
ELSE
	this.Tag = m.tlIgnoreCase
ENDIF

* -----------------------------------------------------------------
HIDDEN PROCEDURE Global_Assign
LPARAMETERS tlGlobal && [.F.] Trouver toutes les occurrences ou la première seulement

IF Vartype(m.tlGlobal) == 'L'
	STORE m.tlGlobal TO this.Global, this.oRegExp.Global
ELSE
	this.Tag = m.tlGlobal
ENDIF

* -----------------------------------------------------------------
HIDDEN PROCEDURE Multiline_Assign
LPARAMETERS tlMultiline && [.F.] Le texte comporte plusieurs lignes

IF Vartype(m.tlMultiline) == 'L'
	STORE m.tlMultiline TO this.Multiline, this.oRegExp.Multiline
ELSE
	this.Tag = m.tlMultiline
ENDIF

* -----------------------------------------------------------------
PROCEDURE Clear && Efface les résultats de recherche précédents

this.nMatches = 0 && Nombre de résultats
DIMENSION this.Matches[1]
this.Matches[1] = .F.
this.PatternMatched = ''

* -----------------------------------------------------------------
PROCEDURE Setup && Règle les options de recherche
LPARAMETERS ;
	tcPattern,; && [''] Expression régulière de recherche
	tuIgnoreCase,; && [.F.] Ignorer la casse dans les comparaisons
	tlGlobal,; && [.F.] Trouver toutes les occurrences ou la première seulement
	tlMultiline && [.F.] Le texte comporte plusieurs lignes

LOCAL lnParms
lnParms = Pcount()

IF m.lnParms > 0
	this.Pattern = m.tcPattern

	IF m.lnParms > 1

		if Vartype(m.tuIgnoreCase) == 'C'

			tuIgnoreCase = Lower(Alltrim(m.tuIgnoreCase))
			this.IgnoreCase = 'i' $ m.tuIgnoreCase
			this.Global = 'g' $ m.tuIgnoreCase
			this.Multiline = 'm' $ m.tuIgnoreCase

		else
			
			this.IgnoreCase = m.tuIgnoreCase

			IF m.lnParms > 2
				this.Global = m.tlGlobal

				IF m.lnParms > 3
					this.Multiline = m.tlMultiline
				endif
			endif
		endif
	endif
else
	return .F.
endif

* -----------------------------------------------------------------
PROCEDURE Test && Teste l'expression de recherche
LPARAMETERS tcIn && Chaîne où chercher

LOCAL llResult

WITH m.this AS abRegExp OF abTxt.prg
	.Clear
	
	IF .lPatterns
		for .nPattern = 1 TO Alen(.aPattern) && FOR EACH .Pattern IN .aPattern produit une erreur 1903 ('String is too long to fit')
			if .Setup(.aPattern[.nPattern]) AND .oRegExp.Test(m.tcIn)
				.PatternMatched = .aPattern[.nPattern]
				llResult = .T.
				* ====
				EXIT
				* ====
			endif
		endfor
		.lPatterns = .T. && pour reuse, .Pattern = le remet à .F.
	ELSE
		llResult = .oRegExp.Test(m.tcIn)
	ENDIF
ENDWITH

RETURN m.llResult

* -----------------------------------------------------------------
PROCEDURE Execute && Tabule les occurrences dans this.matches[]
LPARAMETERS ;
	tcIn,; && Chaîne où chercher
	tlDebug && [.F.] Débuguer
tlDebug = lTrue(m.tlDebug)

LOCAL lnResult

WITH m.this AS abRegExp OF abTxt.prg

	.nPattern = 0
	.Clear

	lnResult = Iif(.lPatterns; && /!\ ne marche pas avec HIDDEN .lPatterns !
		,	.Execute_Patterns(@m.tcIn, m.tlDebug); && plusieurs patterns (exécution récursive)
		,	.Execute_Pattern(@m.tcIn, m.tlDebug); && un seul pattern (cas général)
		)

ENDWITH

RETURN m.lnResult

* -----------------------------------------------------------------
PROTECTED PROCEDURE Execute_Patterns && Exécute des patterns multiples
LPARAMETERS ;
	tcIn,; && Chaîne où chercher
	tlDebug && [.F.] Débuguer

LOCAL lnPattern, laMatches[1], laResult[1], lnResult

lnResult = 0
FOR .nPattern = 1 TO Alen(.aPattern) && FOR EACH .Pattern IN .aPattern produit une erreur 1903 ('String is too long to fit')

	.Pattern = .aPattern[.nPattern] && see this.Pattern_assign()

	* Si des occurrences sont trouvées
	IF .Execute_Pattern(@m.tcIn, m.tlDebug) > 0

		lnResult = m.lnResult + .nMatches
		
		* Ajouter les occurrences au résultat final
		DIMENSION laMatches[Alen(.Matches, 1), Alen(.Matches, 2)]
		Acopy(.Matches, laMatches)
		aAppend(@m.laResult, @m.laMatches)
	ENDIF
ENDFOR

IF lnResult > 0
	Asort(laResult, 1) && dans l'ordre des positions
	DIMENSION .Matches[m.lnResult, Alen(laResult, 2)]
	Acopy(laResult, .Matches)
ENDIF

.nMatches = lnResult
.lPatterns = .T. && pour reuse, .Pattern = le remet à .F.

RETURN m.lnResult

* -----------------------------------------------------------------
PROTECTED PROCEDURE Execute_Pattern && Exécute un pattern unique
LPARAMETERS ;
	tcIn,; && Chaîne où chercher
	tlDebug && [.F.] Débuguer
tlDebug = lTrue(m.tlDebug) OR m.this.lDebug

.nSeconds = Seconds()
.nMatches = 0 && Nombre de Résultats

IF NOT Empty(.Pattern)

	LOCAL loResults, loResult, loSubMatches AS Collection, loSubMatch

	loResults = .oRegExp.Execute(@m.tcIn)
	IF m.loResults.Count > 0

		* Tabuler les résultats
		DIMENSION .Matches[m.loResults.Count, 4] && [index, valeur, submatches, length]
		FOR EACH loResult IN m.loResults && GA ne met pas la clause 'foxobject'

			* Objectifier les sub-matches
			loSubMatches = CreateObject('collection')
			FOR EACH loSubMatch IN loResult.SubMatches
				loSubMatches.add(m.loSubMatch)
			ENDFOR

			* Tabuler les résultats
			.nMatches = .nMatches + 1
			.matches[.nMatches, 1] = m.loResult.firstIndex + 1 && fox strings are 1-based
			.matches[.nMatches, 2] = m.loResult.Value
			.matches[.nMatches, 3] = m.loSubMatches
			.matches[.nMatches, 4] = m.loResult.Length
		ENDFOR
	ENDIF
ENDIF

= m.tlDebug AND .Execute_Debug(@m.tcIn)

RETURN .nMatches

* -----------------------------------------------------------------
PROTECTED PROCEDURE Execute_Debug && Affiche le déboguage de l'exécution courante
LPARAMETERS tcIn && Chaîne où chercher

LOCAL junk;
,	lcPlural;
,	lcSecond;
,	lnMatch;
,	lnSubMatches;
,	lnSubMatch;
,	lcResult

ACTIVATE SCREEN
IF .nPattern = 1
	CLEAR
ENDIF

lcPlural = Iif(.nMatches > 1, 's', '')
lcSecond = Textmerge([<<.nMatches>> occurrence<<m.lcPlural>> trouvée<<m.lcPlural>> en <<Seconds() - .nSeconds)>> secondes])

TEXT TO lcResult TEXTMERGE NOSHOW FLAGS 1
* <<Replicate('=', 40)>>
<<Ttoc(Datetime(),2)>> - <<c2Words(.Tag, ', ', 'PATTERN')>> <<Iif(.nPattern > 0, '#' + Transform(.nPattern), '')>> (<<Lenc(.Pattern)>> cars) :
<<.Pattern>>
IgnoreCase: <<cOUINON(.IgnoreCase)>>, Global: <<cOUINON(.Global)>>, MultiLine: <<cOUINON(.MultiLine)>>
TEXTE (<<Ltrim(Transform(Lenc(m.tcIn), '99 999 999'))>> cars) :
<<cLitteral(cTronc(m.tcIn, 100, .T.))>>
<<m.lcSecond>>
ENDTEXT

IF .nMatches > 0;
	AND (.nMatches < 15;
		 OR MessageBox(Textmerge([<<.nMatches>> résultats, détailler ?]), 4, Program(), 2000) # 7)

	FOR lnMatch = 1 TO .nMatches

		TEXT TO lcResult TEXTMERGE NOSHOW FLAGS 1
<<m.lcResult>>

--- occurrence <<m.lnMatch>>/<<.nMatches>> - position <<.matches[m.lnMatch, 1])>> - longueur <<.matches[m.lnMatch, 4])>> cars
<<Strtran(cTronc(cLitteral(.matches[m.lnMatch, 2]), 200, .T.), Chr(13) + Chr(10), Chr(182) + Chr(13) + Chr(10))>>
		ENDTEXT

		lnSubMatches = .matches[m.lnMatch, 3].Count
		IF m.lnSubMatches > 0
			FOR lnSubMatch = 1 TO m.lnSubMatches
				lcResult = m.lcResult;
				 + CRLF;
				 + '>> '; && ne passe pas dans Textmerge()
				 + Textmerge("subMatch: <<m.lnSubMatch>>/<<m.lnSubMatches>> <<Strtran(cTronc(cLitteral(.matches[m.lnMatch, 3].Item(m.lnSubMatch)), 200, .T.), Chr(13) + Chr(10), Chr(182) + Chr(13) + Chr(10))>>")
			ENDFOR
		ENDIF
	ENDFOR
ENDIF
TEXT TO lcResult TEXTMERGE NOSHOW FLAGS 1
<<m.lcResult>>
* <<Replicate('=', 40)>>
<<m.lcSecond>>
ENDTEXT

this.DebugDisplay(m.lcResult)

* -----------------------------------------------------------------
PROCEDURE Replace && Remplace
LPARAMETERS ;
	tcIn,; && Chaîne où chercher
	tcTo && [''] Chaîne remplaçante

tcTo = Iif(Vartype(m.tcTo) == 'C', m.tcTo, '')

WITH m.this AS abRegExp OF abTxt.prg

	IF .lPatterns

		LOCAL lcResult

		lcResult = m.tcIn
		FOR .nPattern = 1 TO Alen(.aPattern) && FOR EACH .Pattern IN .aPattern produit une erreur 1903 ('String is too long to fit')
			IF .Setup(.aPattern[.nPattern])
				lcResult = .Replace(m.lcResult, m.tcTo)
			ENDIF
		ENDFOR

		.lPatterns = .T. && pour reuse, .Pattern = le remet à .F.
		RETURN m.lcResult

	ELSE
		RETURN .oRegExp.Replace(m.tcIn, m.tcTo)
	ENDIF
ENDWITH

* -----------------------------------------------------------------
PROCEDURE DebugDisplay && Affiche un résultat en mode déboguage 
LPARAMETERS tcDebug

tcDebug = CRLF + Evl(m.tcDebug, Space(0))

? m.tcDebug
DEBUGOUT m.tcDebug

* ===================================================================
ENDDEFINE && CLASS abRegExp
* ===================================================================

* ===================================================================
FUNCTION cCRto && chaîne où les sauts de ligne sont remplacés par ...
LPARAMETERS ;
	tcChain,; && Chaîne
	tcReplace && Chaîne remplaçant les sauts de ligne

RETURN Strtran(Strtran(Strtran(Strtran(m.tcChain;
	, CRLF, m.tcReplace); && modify file abtxt.h
	, LFCR, m.tcReplace); && modify file abtxt.h
	, CR, m.tcReplace); && modify file abtxt.h
	, LF, m.tcReplace) && modify file abtxt.h

* ===================================================================
FUNCTION cCR2to && chaîne où les sauts de ligne doubles sont remplacés par ...
LPARAMETERS ;
	tcChain,; && Chaîne
	tcReplace && Chaîne remplaçant les sauts de ligne

RETURN Strtran(Strtran(Strtran(Strtran(m.tcChain;
	, CRLF2, m.tcReplace); && modify file abtxt.h
	, LFCR2, m.tcReplace); && modify file abtxt.h
	, CR2, m.tcReplace); && modify file abtxt.h
	, LF2, m.tcReplace) && modify file abtxt.h

* ===================================================================
FUNCTION cCRDel && chaîne où les sauts de ligne sont supprimés
LPARAMETERS tcChain && Chaîne
RETURN cCRto(m.tcChain, Space(0))

* ===================================================================
FUNCTION cCRSpace && chaîne où les sauts de ligne sont remplacés par un Space(1)
LPARAMETERS tcChain && Chaîne

RETURN cCRto(m.tcChain, Space(1))

* ===================================================================
FUNCTION cOuiNon(tl) && oui ou non selon logique
RETURN Iif(Vartype(m.tl) $ 'LX', Iif(m.tl, 'OUI', 'NON'), m.tl) && .NULL. <> .F.

* ===================================================================
FUNCTION cYesNo(tl) && yes ou no selon logique
RETURN Iif(Vartype(m.tl) $ 'LX', Iif(m.tl, 'Yes', 'No'), m.tl) && .NULL. <> .F.

* ===================================================================
FUNCTION cYes(tl) && yes ou vide selon logique
RETURN Iif(Vartype(m.tl) $ 'LX', Iif(m.tl, 'Yes', ''), m.tl) && .NULL. <> .F.

* ===================================================================
FUNCTION cFirstProper	&& Chaîne calée à gauche avec son premier caractère en majuscule
LPARAMETERS tcChain && Chaîne à traiter

LOCAL lcResult
lcResult = ''

IF Vartype(m.tcChain) == 'C'
	lcResult = Lower(Ltrim(m.tcChain))
	lcResult = Upper(Left(m.lcResult, 1)) + Substr(m.lcResult, 2)
ENDIF

RETURN m.lcResult

* ===================================================================
FUNCTION cEscaped && Chaîne compatible HTTP / XML
LPARAMETERS tcChain

RETURN Iif(Vartype(m.tcChain) == 'C';
	, cEscaped_Misc(cEscaped_Punc(cEscaped_Base(m.tcChain)));
	, Space(0);
	)

* ===================================================================
FUNCTION cEscaped_Base(tcChain) && Encode les entités ignorées par le parser XML (&<>) && Alias de cEscaped_XML()
RETURN cEscaped_XML(m.tcChain)

* ===================================================================
FUNCTION cEscaped_XML(tcChain) && Encode les entités ignorées par le parser XML (&<>)

RETURN Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(Chrtran(m.tcChain; && http://www.w3.org/TR/2008/REC-xml-20081126/#charsets &&  	Char ::=  #x9 | #xA | #xD | [#x20-#xD7FF] | [#xE000-#xFFFD] | [#x10000-#x10FFFF]
		, NON_XML, ''); && modify file abTxt.h
		, [&], '&#38;'); && '&amp;'
		, [<], '&#60;'); && '&lt;'
		, [>], '&#62;'); && '&gt;'
		, [&#38;#38;], '&#38;'); && encoded twice
		, [&#38;#60;], '&#60;'); && encoded twice
		, [&#38;#62;], '&#62;'); && encoded twice

&& 		, '> <', '><')

* ===================================================================
FUNCTION cEscaped_Punc(tcChain) && Encode les entités de ponctuation

RETURN Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(m.tcChain;
	, ["], '&#34;'); && '&quot;' && /!\ pb avec absiteLoc
	, ['], '&#39;'); && '&apos;' && /!\ pb avec absiteLoc
	, POINTSUSP, Replicate('.', 3)); && &hellip; ne semble pas supportée
	, Chr(150), '&#8211;'); && '&ndash;'
	, Chr(151), '&#8212;'); && '&mdash;'
	, Chr(160), '&#160;') && '&nbsp;'

* ===================================================================
FUNCTION cEscaped_Misc(tcChain) && Encode les entités diverses (™€ etc.)

RETURN Strtran(Strtran(Strtran(m.tcChain;
	, Chr(128), '&#8364;'); && '&euro;'
	, Chr(153), '&#8482;'); && '&trade;'
	, Chr(156), '&#339;') && '&oelig;'

* ===================================================================
FUNCTION cUnescaped && Inverse de cEscaped()
LPARAMETERS tcChain

&& traiter aussi les entités !

RETURN Iif(Vartype(m.tcChain) == 'C';
	, Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(cUnescaped_Base(m.tcChain);
		, '&#34;', ["]);
		, '&#39;', [']);
		, '&#8211;', Chr(150));
		, '&#8212;', Chr(151));
		, '&#160;', Chr(160));
		, '&#8364;', Chr(128));
		, '&#8482;', Chr(153));
		, '&#339;', Chr(156));
	, m.tcChain)

* ===================================================================
FUNCTION cUnescaped_XML(tcChain) && Inverse de cEscaped_XML()
RETURN cUnescaped_Base(tcChain)

* ===================================================================
FUNCTION cUnescaped_Base(tcChain) && Inverse de cEscaped_Base()
RETURN Iif(Vartype(m.tcChain) == 'C';
	, Strtran(Strtran(Strtran(m.tcChain;
		, '&#38;', [&]);
		, '&#60;', [<]);
		, '&#62;', [>]);
	, m.tcChain)

* -------------------------------------------------------------
DEFINE CLASS test1 AS Custom
	ADD OBJECT matches AS Collection
	PROCEDURE init
	this.Matches.add(CreateObject('test2'))
ENDDEFINE

DEFINE CLASS test2 AS Custom
	Position = 0
ENDDEFINE

* ===================================================================
FUNCTION cy && Montant en caractères dans une devise
LPARAMETERS ;
  ty; && Montant
, tcCurrency; && ['USD'] code devise selon norme ISO 4217 http://www.xe.com/iso4217.php

tcCurrency = Evl(m.tcCurrency, 'USD')

LOCAL loCurrency1 as abSet of abDev.prg;
, loCurrency2 as abSet of abDev.prg

loCurrency1 = abSet('Currency', ICase(;
	m.tcCurrency == 'EUR', ' €',; && Copy-paste this line to add another currency support
		'$';
	),,,.T.)

loCurrency2 = abSet('Currency', ICase(;
	m.tcCurrency == 'EUR', 'RIGHT',; && Copy-paste this line to add another currency support
		'LEFT';
	),,,.T.)
	
RETURN Transform(Cast(m.ty as Y))

* -------------------------------
FUNCTION lBotSpider && Une requête émane d'une araignée d'un moteur de recherche
LPARAMETERS tcUA && [m.Request.getBrowser()] User Agent de la requête HTTP

tcUA = Iif(Empty(m.tcUA) AND Vartype(m.Request) == 'O';
	, m.Request.getBrowser();
	, m.tcUA;
	)
IF Vartype(m.tcUA) == 'C' AND !Empty(m.tcUA)
	
	tcUA = Lower(m.tcUA)

	RETURN .F.; && pour placer facilement les plus fréquents en tête && http://www.botsVSbrowsers.com/
	OR	'googlebot' $ m.tcUA;
	OR	'west wind' $ m.tcUA; && West Wind Internet Protocols x,xx
	OR	'/bot' $ m.tcUA;
	OR	'bot/' $ m.tcUA;
	OR 	' bot ' $ m.tcUA;
	OR	'adsbot' $ m.tcUA; && AdsBot-Google (+http://www.google.com/adsbot.html) 15/6/15
	OR	'crawl' $ m.tcUA;
	OR	'spider' $ m.tcUA;
	OR 	'robot' $ m.tcUA;
	OR	'yahoo!+slurp' $ m.tcUA;
	OR	'msnbot' $ m.tcUA;
	OR	'bingbot' $ m.tcUA;
	OR	'exabot' $ m.tcUA;
	OR	'voilabot' $ m.tcUA;
	OR 	'alexa.com' $ m.tcUA;
	OR 	'ccbot' $ m.tcUA;
	OR 	'catchbot' $ m.tcUA;
	OR 	'proximic' $ m.tcUA;
	OR 	'jooblebot' $ m.tcUA;
	OR 	'linkedinbot' $ m.tcUA;
	OR 	'surveybot' $ m.tcUA;
	OR 	'careerbot' $ m.tcUA;
	OR 	'comspybot' $ m.tcUA;
	OR 	'ezooms.bot' $ m.tcUA;
	OR 	'komodiabot' $ m.tcUA;
	OR 	'paperlibot' $ m.tcUA;
	OR 	'facebookexternalhit' $ m.tcUA;
	OR 	'procogseobot' $ m.tcUA; && ProCogSEOBot
	OR 	'coccoc' $ m.tcUA; && Mozilla/5.0 (compatible; coccoc/1.0; +http://help.coccoc.com/) && Coccoc bot is a web crawling bot made by Coc Coc search engine. The bot will discover new and updated pages to be added to Coc Coc search engine index. By allowing Coccoc Bot to index your website, the number of users who are able to find your content will increase and make your site more popular on the search engine. Coccoc bot supports robot exclusion standard (robots.txt)
	OR 	'linkchecker' $ m.tcUA; && LinkChecker/7.4 (+http://linkchecker.sourceforge.net/)
	OR 	'replazbot' $ m.tcUA; && ReplazBot
	OR 	'semrushbot' $ m.tcUA; && SemrushBot
	OR 	'tweetedtimes bot' $ m.tcUA; && TweetedTimes Bot
	OR 	'tweetmemebot' $ m.tcUA; && TweetmemeBot
	OR 	'urlappendbot' $ m.tcUA; && URLAppendBot
	OR 	'wasalive-bot' $ m.tcUA; && WASALive-Bot
	OR 	'yodaobot' $ m.tcUA; && YodaoBot
	OR 	'aihitbot' $ m.tcUA; && aiHitBot
	OR 	'discoverybot' $ m.tcUA; && discoverybot
	OR 	'ltbot' $ m.tcUA; && ltbot
	OR 	'news bot' $ m.tcUA; && news bot
	OR 	'ncbot' $ m.tcUA; && NCBot (http://netcomber.com : tool for finding true domain owners) Queries/complaints: bot@netcomber.com
	OR 	'seznambot' $ m.tcUA; && SeznamBot/3.0 (+http://fulltext.sblog.cz/)
	OR 	'twitterbot' $ m.tcUA; && Twitterbot
	OR 	'wotbox' $ m.tcUA; && Wotbox/2.01 (+http://www.wotbox.com/bot/) nrsbot
	OR 	'nrsbot' $ m.tcUA; && nrsbot
	OR 	'yandex.com' $ m.tcUA;
	OR 	'python-urllib' $ m.tcUA;
	OR 	'synomia' $ m.tcUA;
	OR 	'gigabot' $ m.tcUA;
	OR 	'ocelli' $ m.tcUA;
	OR 	'dcbot.html' $ m.tcUA;
	OR 	'pompos.html' $ m.tcUA;
	OR 	'aipbot.com' $ m.tcUA;
	OR 	'shopwiki.com' $ m.tcUA;
	OR 	'ia_archiver' $ m.tcUA;
	OR 	'bingbot' $ m.tcUA;
	OR 	'mj12bot' $ m.tcUA;
	OR 	'openisearch' $ m.tcUA;
	OR 	'seekbot' $ m.tcUA;
	OR 	'jyxobot' $ m.tcUA;
	OR 	'biglotron' $ m.tcUA;
	OR 	'psbot' $ m.tcUA;
	OR 	'dumbot' $ m.tcUA;
	OR 	'clicksense' $ m.tcUA;
	OR 	'sondeur' $ m.tcUA;
	OR 	'naverbot' $ m.tcUA;
	OR 	'spyder+' $ m.tcUA;
	OR 	'convera' $ m.tcUA;
	OR 	'misesajour' $ m.tcUA;
	OR 	'updated' $ m.tcUA;
	OR 	'infoseek' $ m.tcUA;
	OR 	'envolk' $ m.tcUA;
	OR 	'twiceler' $ m.tcUA;
	OR 	'snap.com' $ m.tcUA;
	OR 	'netresearchserver' $ m.tcUA;
	OR 	'gaisbot' $ m.tcUA;
	OR 	'antibot' $ m.tcUA;
	OR 	'lexxebot' $ m.tcUA;
	OR 	'ask+jeeves' $ m.tcUA;
	OR 	'dotbot' $ m.tcUA;
	OR 	'chainn.com' $ m.tcUA;
	OR 	'seoprofiler.com' $ m.tcUA;
	OR 	'sbider' $ m.tcUA;
	OR 	'soso.com' $ m.tcUA;
	OR 	'antibot' $ m.tcUA;
	OR 	'siteexplorer' $ m.tcUA;
	OR 	'compspybot' $ m.tcUA;
	OR 	'meanpathbot' $ m.tcUA;
	OR 	'lipperhey' $ m.tcUA;
	OR .F. && pour placer facilement les plus fréquents en tête

ENDIF

* -------------------------------
FUNCTION cChr && chaine en chr()
LPARAMETERS tc, tlHexa

LOCAL liResult, lcFormat, lcResult

lcResult = ''
IF Vartype(m.tc) == 'C' AND Len(m.tc) > 0
	lcFormat = Iif(lTrue(m.tlHexa);
		, '@0'; && hexadécimal
		, '@L 999'; && 3 chiffres décimaux
		)
	FOR liResult = 1 TO Lenc(m.tc)
		lcResult = m.lcResult;
			+ [ + Chr(];
			+ Transform(Asc(Substr(m.tc, m.liResult, 1)), m.lcFormat);
			+ [)]
	ENDFOR
	lcResult = Substr(m.lcResult, Len([ + ]) + 1)
ENDIF

RETURN m.lcResult

* -------------------------------
FUNCTION ParmsLit && paramètres en littéral
lparameters result; && @ paramètres en littéral
 ,t01,t02,t03,t04,t05,t06,t07,t08,t09,t10,t11,t12,t13,t14,t15,t16,t17,t18,t19,t20

result = ''
if Pcount() > 1
	local i
	for i = 1 to Pcount()-1
		result = m.result + ', ' + cLitteral(Evaluate('m.t' + Padl(m.i, 2, '0')))
	endfor
	result = Substr(m.result, 3)
endif

*----------------------------------------------------
FUNCTION cCRLF2fix && Chaîne où toutes les lignes se terminent par CRLF simple
lparameters tcChain

tcChain = cCRLFfix(m.tcChain)
do while CRLF2 $ m.tcChain
	tcChain = Strtran(m.tcChain, CRLF2, CRLF)
enddo

return m.tcChain

*----------------------------------------------------
FUNCTION cCRLFfix && Chaîne où toutes les lignes se terminent par CRLF
lparameters tcChain, lKeepHeadingSpaces

tcChain = Iif(Vartype(m.tcChain) == 'C';
	, cCRLFfix_(cCRLFfix_(cCRLFfix_(cCRLFfix_(cCRLFfix_(cCRLFfix_(m.tcChain;
		, TABUL + CRLF);
		, TABUL + CR);
		, TABUL + LF);
		, ' ' + CRLF);
		, ' ' + CR);
		, ' ' + LF);
	, m.tcChain;
	)

tcChain = Iif(Vartype(m.tcChain) == 'C' and !m.lKeepHeadingSpaces;
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
FUNCTION cCRLFfix_ && [privée de cCRLFfix()]
lparameters tcChain, tcNewLine

do while m.tcNewLine $ m.tcChain
	tcChain = Iif(' ' $ m.tcNewLine;
		, Strtran(m.tcChain, m.tcNewLine, Alltrim(m.tcNewLine));
		, Strtran(m.tcChain, m.tcNewLine, CRLF);
		)
enddo

return m.tcChain
endfunc

*----------------------------------------------------
function addFS && adds a forward Slash if none
lparameters tcChain

return Trim(m.tcChain, ' ', '/') + '/'
endfunc

*----------------------------------------------------
function cStringsMasked && {fr} Chaîne où les litteraux caractères sont masqués par _ga_StringParseBits_Class_.maskStrings()
lparameters tcChain, result && in: .T. for JavaScript string, @out: .T. if success, else ga_StringParse_Object() instantiation result

local loParser, cResult

return Iif(.T.;
		and ga_Type_IsChar(m.tcChain, .T.);
		and (.F.;
			or ga_StringParse_Object(@m.loParser); && modify command abGA
			or cResultAdd(@m.result, GA_STRINGPARSE_CLASS + [ class instantiation failed!]);
			);
		and (!lTrue(m.result) or varSet(@m.tcChain, Strtran(Strtran(m.tcChain, '\"'), "\'")));
		and varSet(@m.result, m.loParser.maskStrings(@m.cResult, m.tcChain)); && modify command abGA
		and m.result;
	, m.cResult;
	, m.tcChain;
	)
endfunc
	
* -----------------------------------------------------------------
PROCEDURE cStringsMasked_Test && cStringsMasked() unit test && 1.5 ms dev

LOCAL loTest AS abUnitTest OF abDev.prg
loTest = NewObject('abUnitTest', 'abDev.prg')

loTest.Test([Evl(m.test, ~~~~~~~~~~~~~~~~)], [Evl(m.test, "this is a test")]) && _cliptext = Replicate('~', Len('"this is a test"'))

RETURN loTest.Result()

* =================================
function chunked
lparameters ;
  raw; && raw text
, chunkLen && [76]

chunkLen = Evl(m.chunkLen, 76)

local chunked, iChunk, chunk

chunked = ''
iChunk = 1
do while .T.
	chunk = Substr(m.raw, m.iChunk, m.chunkLen)
	if Empty(m.chunk)
		exit
	else
		chunked = m.chunked + m.chunk + CRLF
		iChunk = m.iChunk + m.chunkLen
	endif
enddo

return Trim(m.chunked, CR, LF)
endfunc

* =================================
function abLocalized && {en} text where localized comments are removed except those in the user's language {fr} texte où le mentions localisées sont retirées sauf celles dans la langue de l'utilisateur
lparameters ;
  cTxt; && {en} Text to localize (source code in general) {fr} Texte à localiser (code source en général)
, cLangUser; && [cLangUser()] {en} user's preferred language as ISO 639-1 code {fr} langue préférée de l'utilisateur selon code ISO 639-1
, cCommentStrings; && ['*|&&|note'] {en} strings beginning a comment line in code source {fr} chaîne de caractère commençant une ligne de commentaires dans le code source

cLangUser = Evl(Evl(m.cLangUser, cLangUser()), 'en')
cLangUser = Lower(Left(Alltrim(m.cLangUser), 2))
cLangUser = Iif('{' + m.cLangUser + '}' $ m.cTxt, m.cLangUser, 'en')

with NewObject('abRegExp', 'abTxt.prg') as abRegExp of abTxt.prg
	.setup(;
		  abLocalized_cPattern1(m.cLangUser);
		, .T.;
		, .T.;
		, .T.;
		)

	cTxt = cRepCharDel(Strtran(.replace(m.cTxt), '{' + m.cLangUser + '}'))
	
	.setup(;
		  abLocalized_cPattern2(m.cCommentStrings);
		, .T.;
		, .T.;
		, .T.;
		)
	cTxt = .replace(m.cTxt)
endwith
	
do while Replicate(CRLF, 3) $ m.cTxt
	cTxt = Strtran(m.cTxt, Replicate(CRLF, 3), Replicate(CRLF, 2))
enddo

return m.cTxt
endfunc

* --------------------------
function abLocalized_cPattern1 && {en} localized string {fr} chaîne localisée
lparameters cLangUser && [cLangUser()] {en} user's preferred language as ISO 639-1 code {fr} langue préférée de l'utilisateur selon code ISO 639-1

&& modify command c:\test\test\regexp_clanguser.prg

&& '{' non suivi de la langue de l'utilisateur
&& puis 2 caractères de mot
&& puis '}'
&& puis toute suite de caractères suivie de : '{\w\w}' ou '<' ou la fin de ligne

return '{(?!' + m.cLangUser + ')\w\w}[^\u002A\r\n]+?(?=(?:{\w\w})|<|\u002A|$)'
endfunc

* --------------------------
function abLocalized_cPattern2 && {en} empty comment lines {fr} lignes de commentaire vide
lparameters cCommentStrings && ['*|&&|note'] {en} strings beginning a comment line in code source {fr} chaîne de caractère commençant une ligne de commentaires dans le code source
return '^\s*?(?:' + Strtran(Evl(m.cCommentStrings, '*|&'+'&|note'), '*', '\u002A') + ')\s*?$\r?\n?'
endfunc

* --------------------------
procedure abLocalized_Test && abLocalized() unit test

LOCAL loTest AS abUnitTest OF abDev.prg, lcTest, lcExpected
loTest = NewObject('abUnitTest', 'abDev.prg')

_cliptext = ''



* test 1 ----
text to lcTest noshow
&& {en} FoxInCloud Adaptation Assistant (FAA) step 3-Publish created this program
&& {fr} L'étape 3 (Publier) de l'Assistant d'Adaptation FoxInCloud (FAA) a créé ce programme

endtext

text to lcExpected noshow
&& L'étape 3 (Publier) de l'Assistant d'Adaptation FoxInCloud (FAA) a créé ce programme

endtext

m.loTest.test(m.lcExpected, m.lcTest, 'fr')

* test 2 ----
text to lcTest noshow
function srceCodeWindow() { /* {en} displays source code from current HTML element into a child window {fr} affiche le HTML de l'élément courant dans une fenêtre fille */
endtext

text to lcExpected noshow
function srceCodeWindow() { /* displays source code from current HTML element into a child window */
endtext

m.loTest.test(m.lcExpected, m.lcTest, 'en', '//')

* test 3 ----
text to lcTest noshow
IF m.THISFORM.wlHTMLgen && {en} FoxInCloud Automated Adaptation {fr} Adaptation Automatique FoxInCloud
	RETURN .T. && {en} Execute this VFP event code on FoxInCloud server {fr} Traiter l'événement sur le serveur
ENDIF
Rand(-1)
this.Parent.SetAll('Value', '', 'ficTxt') && {en} clear textboxes
this.Parent.Refresh && {en} refresh child lists
endtext

text to lcExpected noshow
IF m.THISFORM.wlHTMLgen && Adaptation Automatique FoxInCloud
	RETURN .T. && Traiter l'événement sur le serveur
ENDIF
Rand(-1)
this.Parent.SetAll('Value', '', 'ficTxt') && 
this.Parent.Refresh && 
endtext

m.loTest.test(m.lcExpected, m.lcTest, 'fr')

return loTest.Result()
endproc

* -------------------------------
FUNCTION cTagsStripped && Texte HTML sans balises
LPARAMETERS ;
	tcHTML,; && Texte HTML
	tcTags && [toutes] Balises à supprimer

LOCAL laTags[1], lcTag, loRE, lcResult
lcResult = m.tcHTML

IF Vartype(m.tcTags) == 'C'

	ALines(laTags, m.tcTags, 1, ',', ';')
	FOR EACH lcTag IN laTags

		lcResult = cTagStripped(m.lcResult, m.lcTag)
	ENDFOR
ELSE

	loRE = create('VBscript.regexp')
	loRE.pattern = '<[^>]+>'
	loRE.global = .T.
	lcResult = loRE.replace(m.tcHTML, '')
ENDIF

RETURN m.lcResult

* -------------------------------
FUNCTION cTagStripped && Texte HTML sans une balise
LPARAMETERS ;
  tcHTML; && Texte HTML
, tcTag; && [toutes] Balise(s) à supprimer
, tlExcept; && [.F.] Sauf balises ci-dessus

tcTag = Iif(Vartype(m.tcTag) == 'C', Upper(Alltrim(m.tcTag)), '')
tlExcept = lTrue(m.tlExcept)

LOCAL lcResult;
, lnTagBeg;
, lnTagEnd;
, lcTag;
, lnOcc;

lcResult = Iif(Vartype(m.tcHTML) == 'C', m.tcHTML, '')

IF !Empty(m.lcResult)

	DO WHILE .T.

		* Si balise cherchée ouvrante,
		lnTagBeg = Atcc('<' + m.tcTag, m.lcResult)
		IF m.lnTagBeg > 0
			
			* Trouver la position de la balise fermante correspondante
			lcTag = Substrc(m.lcResult, m.lnTagBeg)
			lnOcc = 1
			DO WHILE .T. && /!\ bug boucle infinie
				
				lnTagEnd = Atcc('>', m.lcTag, m.lnOcc)
				IF Occurs('<', Leftc(m.lcTag, m.lnTagEnd)) = m.lnOcc
					EXIT
				ELSE
					lnOcc = m.lnOcc + 1
				ENDIF
			ENDDO
			
			* Supprimer la balise
			lcTag = Substrc(m.lcTag, 1, m.lnTagEnd)
			lcResult = Strtran(m.lcResult, m.lcTag, '', 1, 1, 1)
			
			* Si balise fermante
			lcTag = '</' + m.tcTag + '>'
			IF Atcc(m.lcTag, m.lcResult) > 0
				lcResult = Strtran(m.lcResult, m.lcTag, '', 1, 1, 1)
			ENDIF

		* Sinon, terminé
		ELSE
			EXIT
		ENDIF
	ENDDO
ENDIF

RETURN cRepCharDel(Alltrim(m.lcResult)) && Supprime les espaces répétés

* -----------------------------------------------------------------
PROCEDURE cTagStripped_Test && teste cTagStripped()

LOCAL loTest as abUnitTest OF abDev.prg
loTest = NewObject('abUnitTest', 'abDev.prg')

loTest.Test([2 050 030], [<a href="javascript:void(0);" onmouseover="WindowOpen(event, '2 050 030', 300, 100, '<h2>Référence 2 050 030 ...</h2>');">2 050 030</a>], 'a')

RETURN loTest.Result()
