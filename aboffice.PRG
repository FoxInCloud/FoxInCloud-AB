	* abOffice.prg
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

	* --------------------------------------------------
	PROCEDURE XLWBtablesBeautify && Améliore l'aspect des feuilles d'un classeur Excel contenant une table
	LPARAMETERS ;
		tcXLWB && Adresse d'un classeur Excel

	LOCAL llResult, lnResult && Nombre de feuilles du classeur ont été traitées

	lnResult = 0
	llResult = Vartype(m.tcXLWB) == 'C' AND File(m.tcXLWB)
	ASSERT m.llResult MESSAGE "Aucun fichier à l'adresse" + Space(1) + cLitteral(m.tcXLWB)
	IF m.llResult
		
		* Ouvrir Excel en automation si pas encore fait
		LOCAL loXL as Excel.Application
		loXL = Vartype(m.poXL) == 'O' AND loXL(m.poXL)
		IF NOT m.loXL
			PRIVATE poXL as Excel.Application
			poXL = oXL()
		ENDIF
		llResult = loXL(m.poXL)
		ASSERT m.llResult MESSAGE "Impossible d'ouvrir Excel en automation"
		IF m.llResult

			* Si le classeur contient au moins une feuille de calcul
			LOCAL laXLWSs[1], lnXLWSs
			lnXLWSs = acXLWSs(@laXLWSs, m.tcXLWB)
			llResult = m.lnXLWSs > 0
			ASSERT m.llResult MESSAGE "Aucune feuille trouvée dans le classeur" + Space(1) + cLitteral(m.tcXLWB)
			IF m.llResult

				* Pour chaque feuille du classeur
				LOCAL lcXLWS
				FOR EACH m.lcXLWS IN m.laXLWSs
					
					* Enrichir l'aspect
					llResult = XLWStableBeautify(oXLWS(m.tcXLWB + '|' + m.lcXLWS))
					lnResult = m.lnResult + Iif(m.llResult, 1, 0)
				ENDFOR
			ENDIF

			IF NOT m.loXL
				poXL.Quit
				RELEASE m.poXL
			ENDIF
		ENDIF
	ENDIF

	RETURN m.lnResult

	* --------------------------------------------------
	PROCEDURE XLWStableBeautify && Améliore l'aspect d'une feuille Excel contenant une table
	LPARAMETERS ;
		tuXLWS,; && Référence à une feuille ou @ adresse d'un classeur Excel
		tcXLWSName,; && [nom du classeur] Nom de la feuille si on veut la renommer
		tcTypes && [ignoré] Types des colonnes
	external array tcTypes

	local llResult as Boolean; && La feuille a été traitée
	, llOpened;
	, loXLWS as Excel.WorkSheet;
	, lcXLWSName;
	, lnRow;
	, lnCol;
	, liCol;
	, luValue;
	, lnMargin;
	, llTypes;
	, laTypes[1];
	
	* Si la feuille excel peut être ouverte
	loXLWS = oXLWS(@m.tuXLWS, @llOpened)
	llResult = Vartype(m.loXLWS)=='O' AND NOT IsNull(m.loXLWS)
	IF m.llResult

		WITH m.loXLWS AS Excel.WorkSheet

			* Nommer la feuille élégament
			lcXLWSName = Iif(Vartype(m.tcXLWSName) == 'C' AND NOT Empty(m.tcXLWSName), m.tcXLWSName, .Name)
			lcXLWSName = Chrtran(m.lcXLWSName, ["'/\:|_], Space(1))
			lcXLWSName = cRepCharDel(m.lcXLWSName)
			lcXLWSName = Alltrim(m.lcXLWSName)
			IF NOT Empty(m.lcXLWSName)
				.Name = Iif(Len(m.lcXLWSName) < 5, Upper(m.lcXLWSName), cTronc(Proper(m.lcXLWSName), 31)) && 31 est la limite Excel 97
			ENDIF

			* Si lignes et colonnes
			lnRow = .UsedRange.Rows.Count
			lnCol = .UsedRange.Columns.Count
			IF m.lnRow > 1 AND m.lnCol > 0

				* Empty 0-cells
				.UsedRange.Replace(0, Space(0), 1)

				llTypes = .F.;
					or Type('tcTypes', 1) == 'A' and !laEmpty(@m.tcTypes) and Acopy(m.tcTypes, m.laTypes) > 0;
					or Vartype(m.tcTypes) == 'C' and ALines(m.laTypes, Upper(m.tcTypes), 5, ',', ';') > 0 and !laEmpty(@m.laTypes)

				* Pour chaque colonne
				.AutoFilterMode = .F.
				FOR m.liCol = 1 TO m.lnCol

					* Régler la cellule de la première ligne
					WITH .Cells(1, m.liCol) AS Excel.Range
						IF m.liCol = 1 AND m.lnRow > 60
							.AutoFilter
						ENDIF
						luValue = .Value
						IF Vartype(m.luValue) == 'C' AND NOT IsNull(m.luValue)
							.Font.Name = 'Calibri'
							.Font.Bold = .T.
							.Value = Upper(cRepCharDel(Chrtran(m.luValue, '_', ' ')))
							.Interior.Color = Rgb(0,255,64) && Green
						ENDIF
					ENDWITH
					
					WITH .Columns(m.liCol) AS Excel.Range

						* Si colonne date ou datetime, ajuster le format
						if m.llTypes and Upper(m.laTypes[m.liCol]) $ 'DT'
							.NumberFormat = cDTformat_AW_XL(Upper(m.laTypes[m.liCol]) == 'T') && modify command abDate
						endif

						* Ajuster la largeur de colonne en automatique
						IF NOT .WrapText
							.AutoFit
							.ColumnWidth = Min(.ColumnWidth, 30) && maximum 30
						ENDIF
					endwith
				ENDFOR
			ENDIF

			* Set up page for printing
			lnMargin = .parent.parent.CentimetersToPoints(1) && 1 cm
			WITH .PageSetup
				.RightMargin = m.lnMargin
				.HeaderMargin = m.lnMargin
				.FooterMargin = m.lnMargin

				lnMargin = m.lnMargin * 1.7
				.LeftMargin = m.lnMargin
				.TopMargin = m.lnMargin
				.BottomMargin = m.lnMargin

				.PrintTitleRows = '$1:$1' && Repeat 1st row on each page
				
				&& cf. "Formatting codes for headers and footers" in XL8.h
				.LeftHeader = '&10&F' && name of the document
				.CenterHeader = '&12&A' && nom de la feuille en xx points
				.RightHeader = 'Printed on &J' && date
				
				.LeftFooter = 'Generated by Abaque on ' + Transform(Date())
				.CenterFooter = 'Page &P/&N' && &N = nombre total de pages et non le nom du classeur comme documenté
				.RightFooter = '&W' && nom du classeur ??

				.PrintGridLines = .T.
			ENDWITH
		ENDWITH

		* Traiter le classeur
		WITH m.loXLWS.parent AS Excel.Workbook && parent = WB

			* Changer la police normale
			WITH .Styles('Normal').Font
				.Name = 'Calibri'
				.Size = 10
			ENDWITH

			* Ajuster la présentation à l'écran
			WITH .Windows(1) AS Excel.Window

				* Freeze panes on first row
				.SplitRow = 1
				.FreezePanes = .T.

				* Dimensionner la fenêtre à un minimum
				LOCAL lnWindowState
				lnWindowState = .WindowState
				.WindowState = xlNormal
				.Width = Max(.Width , .7 * 72 * 20) && pouces logiques > points > twips
				.Height = Max(.Height,  .4 * 72 * 20)
				.WindowState = m.lnWindowState
			ENDWITH

			* Sauvegarder en version courante
			.SaveAs(Iif(Vartype(m.tuXLWS) == 'C', m.tuXLWS, .FullName), xlWorkbookNormal)

			* Refermer s'il était fermé à l'entrée
			IF m.llOpened
				.Close
			ENDIF
		ENDWITH
	ENDIF

	RETURN m.llResult

	* -----------------------------------------------------------------
	PROCEDURE XLWStableBeautify_Test && teste XLWStableBeautify(), nouvelle version

	LOCAL loTest as sesXLWSTableBeautify_Test
	loTest = CreateObject('sesXLWSTableBeautify_Test')

	LOCAL lcTableTest, lcXLWBTest
	lcTableTest = "XLWStableBeautify_Test"
	lcXLWBTest = loTest.DataOpen(m.lcTableTest)

	loTest.DataShow()
	loTest.CoverageSet(.T.)
	loTest.Test(.T., m.lcXLWBTest)

	RETURN loTest.Result()

	* ------------------------------
	DEFINE CLASS sesXLWSTableBeautify_Test as abUnitTest OF abDev.prg

	PROCEDURE DataOpen
		LPARAMETERS tcTable
		LOCAL lcResult

		* Créer une table de test dans le dossier temporaire
		LOCAL lcAddr
		lcAddr = Addbs(Sys(2023)) + ForceExt(m.tcTable, EXT_DBF)
		CREATE TABLE (m.lcAddr) FREE ;
					(PK I, cX1 C(20) NULL, nX2 N(5))
		INSERT INTO (m.tcTable) VALUES (1, 'Premier', 100)
		INSERT INTO (m.tcTable) VALUES (2, 'Second', 200)
		INSERT INTO (m.tcTable) VALUES (3, 'Troisième', 300)
		INSERT INTO (m.tcTable) VALUES (4, NULL, 400)

		* Copier dans un classeur Excel
		lcResult = ForceExt(m.lcAddr, EXT_XLS)
		COPY TO (m.lcResult) TYPE XL5

		RETURN m.lcResult

	PROCEDURE DataShow

		IF Set("Asserts") == 'ON'
			LOCAL lcWindow
			lcWindow = Wontop()
			BROWSE TITLE Alias()
			ACTIVATE WINDOW (m.lcWindow)
		ENDIF
	
	ENDDEFINE && CLASS sesXLWSTableBeautify_Test

	* ---------------------
	PROCEDURE XLWSMultiLineCellExpand && Augmente la hauteur des cellules contenant plusieurs lignes
	LPARAMETERS ;
		tuXLWS,; && Référence à une feuille ou adresse d'un classeur Excel
		tuCol,; && n° ou nom de la colonne
		tnColor && [sans changement] Couleur à appliquer aux cellules contenant plusieurs lignes
	LOCAL llResult

	* Si on peut accéder à la feuille Excel
	LOCAL loXLWS AS Excel.WorkSheet, llOpened
	loXLWS = oXLWS(@m.tuXLWS, @llOpened)
	llResult = Vartype(m.loXLWS) == 'O'
	ASSERT m.llResult MESSAGE Program() + ": impossible d'accéder à la feuille Excel sépcifiée " + cLitteral(m.tuXLWS)
	IF m.llResult

		WITH m.loXLWS AS Excel.WorkSheet

			* Compter les lignes et les colonnes de la feuille
			LOCAL lnRows, lnCols
			lnRows = .usedRange.rows.count
			lnCols = .usedRange.columns.count
			
			* Si au moins une ligne
			llResult = m.lnRows > 1
			IF m.llResult

				* Si la colonne spécifiée existe
				LOCAL lnCol
				lnCol = nXLWSCol(m.loXLWS, m.tuCol)
				llResult = m.lnCol > 0
				ASSERT m.llResult MESSAGE Program() + " - spécification de colonne invalide" + cLitteral(m.tuCol)
				IF m.llResult

					* Voir s'il faut appliquer une couleur aux cellules concernées
					LOCAL llColor
					llColor = Vartype(m.tnColor) == 'N' AND m.tnColor > 0 AND m.tnColor < Rgb(255,255,255)

					* Pour chaque ligne de données
					LOCAL lnRow, luValue, llAlign
					FOR m.lnRow = 2 TO m.lnRows && la première ligne doit contenir les noms des champs
						
						* Si la cellule contient un saut de ligne, traiter
						WITH .cells(m.lnRow, m.lnCol)
							luValue = .value
							IF Vartype(m.luValue) == 'C' ;
							 AND LF $ m.luValue
								.value = m.luValue && Simulates 'F2 + enter'
								.WrapText = .T. && Retour à la ligne automatique
								.EntireRow.AutoFit && Hauteur de ligne automatique
								IF m.llColor
									.interior.color = m.tnColor
								ENDIF
								llAlign = .T.
							ENDIF
						ENDWITH
					ENDFOR
				ENDIF

				* Si au moins une cellule détectée, aligner tout en haut
				IF m.llAlign
					.usedRange.VerticalAlignment = xlVAlignTop
				ENDIF
				
				* Sauvegarder le classeur
				.parent.SaveAs(.parent.FullName, xlWorkbookNormal)
			ENDIF
		ENDWITH
	ENDIF
	
	* Si le classeur a été ouvert, refermer
	IF m.llOpened
		loXLWS.parent.close()
	ENDIF

	RETURN m.llResult

	* --------------------------------------------------
	PROCEDURE XLWStableBlankLinesDel && Supprime les lignes vides d'un tableau Excel
	LPARAMETERS ;
		tuXLWS,; && Référence à une feuille ou adresse d'un classeur Excel
		tcXLWSName && [nom du classeur] Nom de la feuille si on veut la renommer
	LOCAL llResult && La feuille a été traitée
	
	* Si la feuille excel peut être ouverte
	LOCAL llOpened, loXLWS as Excel.WorkSheet
	loXLWS = oXLWS(@m.tuXLWS, @llOpened)
	llResult = Vartype(m.loXLWS)=='O' AND NOT IsNull(m.loXLWS)
	IF m.llResult

		WITH m.loXLWS as Excel.WorkSheet

			* S'il y a des lignes et des colonnes
			LOCAL lnRows, lnCols
			lnRows = .usedRange.rows.count
			lnCols = .usedRange.columns.count
			llResult = m.lnRows > 1 AND m.lnCols > 0
			IF m.llResult

				* Pour chaque Ligne
				LOCAL lnRow, lnCol, llRowEmpty, luValue
				FOR m.lnRow = m.lnRows TO 2 STEP -1
				
					* Si chaque cellule est vide
					llRowEmpty = .F.
					FOR m.lnCol = 1 TO m.lnCols
						luValue = .cells(m.lnRow, m.lnCol).Value
						llRowEmpty = Empty(m.luValue) OR IsNull(m.luValue)
						IF NOT m.llRowEmpty
							EXIT
						ENDIF
					ENDFOR
					
					* Si la ligne est vide, supprimer
					IF m.llRowEmpty
						.cells(m.lnRow,1).EntireRow.Delete()
					ENDIF
				ENDFOR

				* Sauvegarder le classeur en version courante
				.parent.SaveAs(Iif(Vartype(m.tuXLWS) == 'C', m.tuXLWS, .FullName), xlWorkbookNormal)
			ENDIF

			* Refermer le classeur s'il était fermé à l'entrée
			IF m.llOpened
				.parent.Close
			ENDIF
		ENDWITH
	ENDIF

	RETURN m.llResult

	* ---------------------
	PROCEDURE XLWSColFormatNumber && Applique un format de présentation à une colonne d'une feuille Excel
	LPARAMETERS ;
		tuXLWS,; && Référence à une feuille ou adresse d'un classeur Excel
		tuCol,; && n° ou nom de la colonne
		tcNumberFormat && [sans changement] Code format Excel à appliquer

	LOCAL loXLWSCol AS Excel.Range, llOpened, llResult

	* Si on peut accéder à la colonne de la feuille Excel
	loXLWSCol = oXLWSCol(m.tuXLWS, m.tuCol, @llOpened)
	llResult = not IsNull(m.loXLWSCol)
	IF m.llResult

		LOCAL loWB as Excel.Workbook, lcFormat
		loWB = m.loXLWSCol.Parent.Parent
		
		* Si un format est spécifié
		lcFormat = uDefault(m.tcNumberFormat, Space(0))
		llResult = not Empty(m.lcFormat)
		ASSERT m.llResult MESSAGE Program() + " - Spécification de format invalide " + cLitteral(m.tcNumberFormat)
		IF m.llResult
			
			* Appliquer le format à la colonne
			loXLWSCol.NumberFormat = m.lcFormat

			* Sauvegarder le classeur en version courante
			loWB.SaveAs(Iif(Vartype(m.tuXLWS) == 'C', m.tuXLWS, .FullName), xlWorkbookNormal)
		ENDIF

		* Refermer le classeur si on l'a ouvert à l'entrée
		IF m.llOpened
			loWB.close
		ENDIF
	ENDIF
	
	RETURN m.llResult

	* ---------------------
	PROCEDURE XLWSColFormatHAlign && Applique un format d'alignement horizontal à une colonne d'une feuille Excel
	LPARAMETERS ;
		tuXLWS,; && Référence à une feuille ou adresse d'un classeur Excel
		tuCol,; && n° ou nom de la colonne
		tnHAlign && [xlHAlignGeneral] format d'alignement horizontal à appliquer (selon constantes Excel)

	LOCAL loXLWSCol AS Excel.Range, llOpened, llResult

	* Si on peut accéder à la colonne de la feuille Excel
	loXLWSCol = oXLWSCol(m.tuXLWS, m.tuCol, @llOpened)
	llResult = NOT IsNull(m.loXLWSCol)
	IF m.llResult

		LOCAL loWB as Excel.Workbook
		loWB = m.loXLWSCol.Parent.Parent
		
		* Si un format est spécifié
		LOCAL lnHAlign
		lnHAlign = uDefault(m.tnHAlign, xlHAlignGeneral)
		llResult = InList(m.lnHAlign, xlHAlignCenter,xlHAlignCenterAcrossSelection,xlHAlignDistributed,xlHAlignFill,xlHAlignGeneral,xlHAlignJustify,xlHAlignLeft,xlHAlignRight)
		ASSERT m.llResult MESSAGE Program() + " - Spécification de format invalide : " + cLitteral(m.tnHAlign)
		IF m.llResult
			
			* Appliquer le format à la colonne
			loXLWSCol.HorizontalAlignment = m.lnHAlign

			* Sauvegarder le classeur en version courante
			loWB.SaveAs(Iif(Vartype(m.tuXLWS) == 'C', m.tuXLWS, .FullName), xlWorkbookNormal)
		ENDIF

		* Refermer le classeur si on l'a ouvert à l'entrée
		IF m.llOpened
			loWB.close
		ENDIF
	ENDIF
	
	RETURN m.llResult

	* ---------------------
	PROCEDURE oXLWSCol && Colonne d'une feuille Excel
	LPARAMETERS ;
		tuXLWS,; && Référence à une feuille ou adresse d'un classeur Excel
		tuCol,; && n° ou nom de la colonne
		tlOpened && @ Le classeur excel a été ouvert

	LOCAL llResult, loResult as excel.Range && Référence à l'objet colonne
	loResult = .NULL.
	
	* Si on peut accéder à la feuille Excel
	LOCAL loXLWS AS Excel.WorkSheet
	loXLWS = oXLWS(@m.tuXLWS, @tlOpened)
	llResult = Vartype(m.loXLWS) == 'O'
	ASSERT m.llResult MESSAGE Program() + ": impossible d'accéder à la feuille Excel " + cLitteral(m.tuXLWS)
	IF m.llResult
		WITH m.loXLWS AS Excel.WorkSheet

			* Si au moins une ligne dans la feuille
			LOCAL lnRows
			lnRows = .usedRange.rows.count
			llResult = m.lnRows > 1
			ASSERT m.llResult MESSAGE Program() + " - Moins d'une ligne dans la feuille " + cLitteral(m.tuXLWS)
			IF m.llResult

				* Si la colonne spécifiée existe
				LOCAL lnCol
				lnCol = nXLWSCol(m.loXLWS, m.tuCol)
				llResult = m.lnCol > 0
				ASSERT m.llResult MESSAGE Program() + " - spécification de colonne invalide : " + cLitteral(m.tuCol)
				IF m.llResult
				
					loResult = m.loXLWS.Cells(1, m.lnCol).EntireColumn
				ENDIF
			ENDIF
		ENDWITH
	ENDIF
	
	RETURN m.loResult

	* ---------------------
	PROCEDURE XLWSRowsInteriorColor && Applique une couleur de fond à des rangées d'une feuille Excel selon un critère de filtre sur une colonne
	LPARAMETERS ;
		tuXLWS,; && Référence à une feuille ou adresse d'un classeur Excel
		tuCol,; && n° ou nom de la colonne
		tcCrit,; && Critère à appliquer : UDF de type logique à UN SEUL PARAMÈTRE ou opérateur relationnel (=<>$!)
		tlOpLeft,; && [.F.] l'opération relationnelle est appliquée à gauche de la valeur
		tnColor && [-1] Couleur rgb(),  -1 pour xlColorIndexNone, -2 pour xlColorIndexAutomatic 
	LOCAL llResult

	* Si on peut sélectionner les rangées de la feuille Excel
	LOCAL loXLWSRows AS Excel.Range, llOpened
	loXLWSRows = oXLWSRowsFilter(m.tuXLWS, m.tuCol, m.tcCrit, m.tlOpLeft, @llOpened)
	llResult = NOT IsNull(m.loXLWSRows)
	IF m.llResult
			LOCAL loWB as Excel.Workbook
			loWB = m.loXLWSRows.Parent.Parent
			
			* Donner sa valeur par défaut à la couleur spécifiée
			LOCAL lnColor
			lnColor = uDefault(m.tnColor, -1)
			lnColor = Iif(m.lnColor < -2 OR m.lnColor > Rgb(255,255,255), -1, m.lnColor)
				
			* Appliquer la couleur demandée
			WITH m.loXLWSRows.Interior
				IF m.lnColor < 0
					.ColorIndex = Iif(m.lnColor = -1, xlColorIndexNone, xlColorIndexAutomatic)
				ELSE
					.Color = m.lnColor
				ENDIF
			ENDWITH

			* Sauvegarder le classeur en version courante
			loWB.SaveAs(Iif(Vartype(m.tuXLWS) == 'C', m.tuXLWS, .FullName), xlWorkbookNormal)

			* Refermer le classeur si on l'a ouvert à l'entrée
			IF m.llOpened
				loWB.close()
			ENDIF
	ENDIF
	
	RETURN m.llResult

	* ---------------------
	FUNCTION oXLWSRowsFilter && Rangées d'une feuille Excel selon un critère de filtre sur une colonne
	LPARAMETERS ;
		tuXLWS,; && Référence à une feuille ou adresse d'un classeur Excel
		tuCol,; && n° ou nom de la colonne où se trouve le critère
		tcCrit,; && [aucun, toutes les lignes sont renvoyées] Critère de filtre des lignes : UDF de type logique à UN SEUL PARAMÈTRE ou opération relationnelle (=<>$!)
		tlOpLeft,; && [.F.] l'opération relationnelle est appliquée à gauche de la valeur
		tlOpened && @ Le classeur excel a été ouvert
	LOCAL loResult as excel.Range && Référence à l'objet Range contenant les lignes
	loResult = .NULL.

	LOCAL llResult
	
	* Si on peut accéder à la feuille Excel
	LOCAL loXLWS AS Excel.WorkSheet
	loXLWS = oXLWS(@m.tuXLWS, @tlOpened)
	llResult = Vartype(m.loXLWS) == 'O'
	ASSERT m.llResult MESSAGE Program() + ": impossible d'accéder à la feuille Excel " + cLitteral(m.tuXLWS)
	IF m.llResult
		WITH m.loXLWS AS Excel.WorkSheet

			* Si au moins une ligne dans la feuille
			LOCAL lnRows
			lnRows = .usedRange.rows.count
			llResult = m.lnRows > 1
			ASSERT m.llResult MESSAGE Program() + " - moins de deux lignes dans la feuille " + cLitteral(m.tuXLWS)
			IF m.llResult

				* Si la colonne spécifiée existe
				LOCAL lnCol
				lnCol = nXLWSCol(m.loXLWS, m.tuCol)
				llResult = m.lnCol > 0
				ASSERT m.llResult MESSAGE Program() + " - spécification de colonne invalide : " + cLitteral(m.tuCol)
				IF m.llResult
				
					* Si le critère est précisé
					LOCAL lcCrit
					lcCrit = Alltrim(uDefault(m.tcCrit, Space(0)))
					llResult = NOT Empty(m.lcCrit)
					IF m.llResult
					
						LOCAL llOpLeft
						llOpLeft = uDefault(m.tlOpLeft, .F.)
						
						* Si le critère est valide
						LOCAL luVal, lcType, lcTest, llOp, loErr
						luVal = .Cells(2, m.lnCol).Value
						lcType = Vartype(m.luVal)
						lcTest = cLitteral(m.luVal)
						#DEFINE VFPLOGOP '=<>$!'
						llOp = Iif(m.llOpLeft, Right(m.lcCrit, 1) $ VFPLOGOP, Left(m.lcCrit, 1) $ VFPLOGOP)
						TRY
							LOCAL lcEval
							lcEval = cCritEval(m.lcCrit, m.lcTest, m.llOp, m.llOpLeft)
							luResult = Evaluate(m.lcEval)
							llResult = Vartype(m.luResult) == 'L'
						CATCH TO m.loErr
						ENDTRY
						ASSERT m.llResult MESSAGE Program() + " - critère de filtrage incorrect : " + cLitteral(m.tcCrit)
						IF m.llResult
						
							* Pour chaque ligne à partir de la seconde (la première contient les noms des champs)
							LOCAL lnRow, luVal, loXl as excel.Application
							loXl = .Parent.Parent
							FOR m.lnRow = 2 TO m.lnRows
								WITH .Cells(m.lnRow, m.lnCol) as excel.Range
									luVal = .Value

									* Si la valeur est du type attendu
									IF Vartype(m.luVal) == m.lcType
									
										* Si le critère est respecté
										lcTest = cLitteral(m.luVal)
										IF Evaluate(cCritEval(m.lcCrit, m.lcTest, m.llOp, m.llOpLeft))
										
											* Ajouter la ligne au Range
											loResult = Iif(IsNull(m.loResult), .EntireRow, m.loXl.Union(m.loResult, .EntireRow))
										ENDIF
									ENDIF
								ENDWITH
							ENDFOR
						ENDIF
					ELSE
						loResult = .Cells
					ENDIF
				ENDIF
			ENDIF
		ENDWITH
	ENDIF
	
	RETURN m.loResult
	
	* ---------------------
	FUNCTION cCritEval && Critère de filtre à évaluer
	LPARAMETERS ;
		tcCrit,; && Critère de filtre
		tcVal,; && Valeur sous forme de constante caractère
		tlOp,; && Le critère est une opération relationnelle (UDF si .F.)
		tlOpLeft && l'opération relationnelle est appliquée à gauche de la valeur
	
	RETURN ICase(;
		!m.tlOp,;
			m.tcCrit + '(' + m.tcVal + ')',;
		m.tlOpLeft,;
			m.tcCrit + m.tcVal,;
			m.tcVal + m.tcCrit;
		)
	* ---------------------
	FUNCTION nXLWSCol && N° d'une colonne d'après son nom inscrit dans la première ligne
	LPARAMETERS ;
		toXLWS as Excel.WorkSheet,; && Référence présumée à une feuille Excel
		tuCol && Nom ou n° de de la colonne
	LOCAL lnResult
	lnResult = 0
	
	LOCAL lcType
	lcType = Vartype(m.tuCol)
	IF loXLWS(m.toXLWS) ;
	 AND m.lcType $ 'CN' ;
	 AND NOT Empty(m.tuCol)
			
		* Compter les lignes et les colonnes de la feuille
		LOCAL lnRows, lnCols
		lnRows = m.toXLWS.usedRange.rows.count
		lnCols = m.toXLWS.usedRange.columns.count
		
		* Si au moins une ligne et une colonne
		IF m.lnRows > 0 AND m.lnCols > 0
		
			* Si un n° de colonne a été spécifié et qu'il est dans la plage de colonnes, OK
			IF m.lcType == 'N'
				IF m.tuCol <= m.lnCols
					lnResult = m.tuCol
				ENDIF

			* Sinon (nom de colonne spécifié)
			ELSE

				* Pour chaque cellule de la première ligne
				LOCAL lcCol, lnCol, luValue
				lcCol = Upper(Alltrim(m.tuCol))
				FOR m.lnCol = 1 TO m.lnCols
					
					* Si la valeur contient le nom de colonne cherché, trouvé !
					luValue = m.toXLWS.cells(1, m.lnCol).value
					IF Vartype(m.luValue) == 'C' ;
					 AND Upper(Alltrim(m.luValue)) == m.lcCol
					 	lnResult = m.lnCol
						EXIT
					ENDIF
				ENDFOR
			ENDIF
		ENDIF
	ENDIF

	RETURN m.lnResult

	* -------------------------------------------------------------
	FUNCTION oXL && Référence à un objet Excel.Application

	LOCAL lcWindow, loResult AS Excel.Application
	loResult = .NULL.

	* Si Excel est déjà instancié dans la variable standard (publique ou privée)
	IF Vartype(m.poXL) == 'O' ; && standard Abaque pour éviter d'instancier excel plusieurs fois
	AND Type('m.poXL.ActiveWorkbook') == 'O' && vrai même si aucun classeur n'est ouvert

		loResult = m.poXL

	* Sinon (aucune référence disponible)
	ELSE

		lcWindow = WOUTPUT()
		TRY
			loResult = GetObject(Space(0), 'Excel.Application') && le premier paramètre est requis
			loResult = Iif(Vartype(m.loResult) == 'O', m.loResult, CreateObject('Excel.Application'))
		CATCH
		ENDTRY
		IF Vartype(m.loResult) == 'O'
			loResult.DisplayAlerts = .F.

			* Rétablir la fenêtre active avant l'instanciation
			IF Empty(m.lcWindow) OR NOT Wvisible(m.lcWindow)
				ACTIVATE SCREEN
			ELSE
				ACTIVATE WINDOW (m.lcWindow)
			ENDIF
		ENDIF
	ENDIF

	RETURN m.loResult

	* -------------------------------------------------------------
	FUNCTION oXLWB && Référence à un objet Excel.WorkBook
	LPARAMETERS ;
		tuXLWB,; && Référence ou adresse d'un classeur Excel
		tlOpened,; && @ le classeur a été ouvert
		tlCreated && @ le classeur a été créé
	STORE .F. TO tlOpened, tlCreated

	LOCAL loResult AS Excel.Workbook
	loResult = .NULL.

	DO CASE

	* Si une référence à un classeur Excel a été passée
	CASE loXLWB(m.tuXLWB)

		* Renvoyer tout simplement
		loResult = m.tuXLWB

	* Si l'adresse d'un classeur Excel a été passée
	CASE Vartype(m.tuXLWB)=='C' ;
	 AND Upper(JustExt(m.tuXLWB)) == EXT_XLS

		* Démarrer Excel
		LOCAL loXL as Excel.Application
		loXL = oXL()
		
		* Si le classeur existe
		IF lFile(m.tuXLWB)

			* Ouvrir le classeur
			loResult = m.loXL.Workbooks.Open(FullPath(m.tuXLWB), 0) && 0: Ne met à jour aucune référence
			tlOpened = .T.

		* Sinon (le classeur n'existe pas)
		ELSE

			* Si l'adresse du classeur est valide
			LOCAL llResult
			llResult = lDir(JustPath(m.tuXLWB))
			ASSERT m.llResult MESSAGE Program() + " - Invalid Excel Workbook specification : " + cLitteral(m.tuXLWB)
			IF m.llResult
				
				loResult = m.loXL.Workbooks.Add()
				tlCreated = .T.
			ENDIF
		ENDIF
	ENDCASE
	
	RETURN m.loResult

	* ---------------------
	FUNCTION oXLWS && Référence à un objet Excel.Worksheet
	LPARAMETERS ;
		tuXLWS,; && Référence à une Feuille Excel OU @ adresse d'un classeur [(|!,) Nom Feuille]
		tlOpened && @ le classeur a été ouvert
	tlOpened = .F.

	LOCAL loResult as Excel.Worksheet;
	, loXLWB as Excel.Workbook;
	, liSep;
	, lcXLWB;
	, lcXLWS;

	loResult = .NULL.

	* Si une référence à une feuille Excel a été passée
	do case
	case loXLWS(m.tuXLWS)

		* Renvoyer tout simplement
		loResult = m.tuXLWS

	case Vartype(m.tuXLWS) == 'C'

		* Lire l'adresse du classeur [et le nom de la feuille]
		liSep = Evl(Evl(At_c('|', m.tuXLWS), At_c(',', m.tuXLWS)), At_c('!', m.tuXLWS))
		
		if m.liSep > 0
			lcXLWB = Leftc(m.tuXLWS, m.liSep - 1)
			lcXLWS = Substrc(m.tuXLWS, m.liSep + 1)
		else
			store cFileCased(m.tuXLWS, .T.) to lcXLWB, m.tuXLWS
			lcXLWS = ''
		endif

		* Si le classeur peut être ouvert
		loXLWB = oXLWB(m.lcXLWB)
		IF Vartype(m.loXLWB) == 'O'
			tlOpened = .T.

			* Renvoyer une référence à la feuille spécifiée, à défaut la première feuille du classeur
			loResult = Iif(lXLWS(m.lcXLWS, m.loXLWB);
				, m.loXLWB.Sheets(m.lcXLWS);
				, m.loXLWB.ActiveSheet;
				)
		ENDIF
	endcase

	RETURN m.loResult

	* ---------------------
	FUNCTION acXLWSs && Noms des feuilles de calcul contenues dans un classeur Excel
	LPARAMETERS ;
		taXLWS,; && @ Noms des feuilles de calcul contenues dans le classeur Excel
		tcXLWBAddr && Adresse du classeur Excel à explorer

	EXTERNAL ARRAY taXLWS

	LOCAL llXLWBAddr, lnResult && Nombre de feuilles de calcul contenues dans le classeur Excel
	lnResult = 0
		
	* Initialiser le tableau des feuilles
	aClear(@m.taXLWS)
	
	* Si le classeur XL indiqué peut être localisé
	llXLWBAddr = File(m.tcXLWBAddr)
	ASSERT m.llXLWBAddr MESSAGE "Impossible de trouver un classeur XL à l'adresse" + Alltrim(m.tcXLWBAdd)
	IF m.llXLWBAddr
		
		* Ouvrir le classeur XL en automation
		LOCAL loXL as Excel.Application,;
			loXLWB as Excel.Workbook
		loXL = oXL()
		loXLWB = loXL.Workbooks.Open(FullPath(m.tcXLWBAddr), 0, .T.)

		* Lire les noms des feuilles de calcul contenues dans le classeur
		LOCAL loXLWS as EXCEL.Worksheet
		FOR EACH m.loXLWS IN m.loXLWB.Worksheets
			lnResult = m.lnResult + 1
			DIMENSION m.taXLWS[m.lnResult]
			taXLWS[m.lnResult] = m.loXLWS.Name
		ENDFOR

		* Fermer le classeur et XL
		loXLWB.Close()
		loXL = .NULL.
	ENDIF

	RETURN m.lnResult

	* ---------------------
	FUNCTION loXL && C'est une référence à un objet application Excel
	LPARAMETERS toXL && Référence présumée à un objet application Excel

	RETURN ;
		Vartype(m.toXL) == 'O';
	 AND Type('m.toXL.Name') == 'C';
	 AND 'excel' $ Lower(m.toXL.Name) ;
	 AND Type('m.toXL.WorkBooks') == 'O'

	* ---------------------
	FUNCTION loXLWB && C'est une référence à un objet classeur Excel
	lparameters toXLWB && Référence présumée à une classeur Excel

	RETURN ;
		Vartype(m.toXLWB) == 'O';
	 AND Type('m.toXLWB.Application') == 'O';
	 AND loXL(m.toXLWB.Application) ;
	 AND Type('m.toXLWB.WorkSheets') == 'O'

	* ---------------------
	FUNCTION loXLWS && C'est une référence à un objet feuille de calcul Excel
	LPARAMETERS toXLWS && Référence présumée à une feuille Excel

	RETURN ;
		Vartype(m.toXLWS) == 'O';
	 AND Type('m.toXLWS.parent') == 'O';
	 AND loXLWB(m.toXLWS.parent)

	* ---------------------
	PROCEDURE loXLWS_Test && Teste loXLWS(), nouvelle version

	LOCAL loTest as abUnitTest OF abDev.prg
	loTest = NewObject('abUnitTest', 'abDev.prg')

	LOCAL loXL as Excel.Application, loXLWB as excel.Workbook
	loXL = oXL()
	loXLWB = m.loXL.Workbooks.Add()

	loTest.Test(.T., m.loXLWB.ActiveSheet)

	loXLWB.Close()
	loXL.Quit()

	RETURN loTest.Result()
	
	* ---------------------
	FUNCTION lXLWS && La feuille XL existe dans le classeur spécifié
	LPARAMETERS ;
		tcSheet,; && Nom de la feuille cherchée
		tuXLWB && Référence ou adresse d'un classeur Excel
	LOCAL llResult
		
	* Si une feuille valide a été indiquée
	llResult = Vartype(m.tcSheet) == 'C' AND NOT Empty(m.tcSheet)
	IF m.llResult

		* Si le classeur spécifié peut être ouvert
		LOCAL loXLWB as Excel.WorkBook
		loXLWB = oXLWB(m.tuXLWB)
		llResult = NOT IsNull(m.loXLWB)
		IF m.llResult
		
			* Pour chaque feuille contenue
			LOCAL lcSheet, loSheet as Excel.Worksheet
			lcSheet = Lower(Alltrim(m.tcSheet))
			llResult = .F.
			FOR EACH m.loSheet IN m.loXLWB.Worksheets
			
				* Si la feuille porte le nom spécifié, terminé
				llResult = Lower(m.loSheet.Name) == m.lcSheet
				IF m.llResult
					EXIT
				ENDIF
			ENDFOR
		ENDIF
	ENDIF
	
	RETURN m.llResult

	* -------------------------------------------------------------
	PROCEDURE XLWBfromWSs && Regroupe des feuilles Excel dans un classeur
	LPARAMETERS ;
		taWBWSSrce,; && @ Adresses des classeurs | noms des feuilles [Feuille # 1] à regrouper
		tcWBDestAddr,; && Adresse du classeur Excel destination
		tlWBSrceDel,; && [.F.] Supprimer les classeurs source après copie des feuilles dans le classeur destination
		tlBeautify && [.F.] Embellir les feuilles
	EXTERNAL ARRAY taWBWSSrce
	tlWBSrceDel = Vartype(m.tlWBSrceDel) == 'L' AND m.tlWBSrceDel
	tlBeautify = Vartype(m.tlBeautify) == 'L' ANd m.tlBeautify

	LOCAL llResult && Toutes les feuilles ont bien été copiées dans le classeur destination

	* Si des classeurs source sont indiqués
	IF Type('taWBWSSrce', 1) == 'A'

		LOCAL lnWBSrces
		lnWBSrces = Alen(m.taWBWSSrce, 1)
		IF m.lnWBSrces > 0 ;
		 AND lFileAddress(m.tcWBDestAddr)

			* Vérifier si des feuilles ont aussi été indiquées
			LOCAL llWSSrce
			llWSSrce = Alen(m.taWBWSSrce, 2) > 1

			* Créer un tableau de résultats
			LOCAL ARRAY laResult[m.lnWBSrces]

			* Lancer Excel en automation
			LOCAL loXL as Excel.Application
			loXL = oXL()

			* Pour chaque classeur source,
			LOCAL ;
				lnWBSrce, lcWBSrce, loWBSrce as Excel.Workbook,;
				lcWSSrce, loWSSrce as Excel.Worksheet,;
				llWBDest
			FOR m.lnWBSrce = 1 TO m.lnWBSrces

				* Si le classeur source existe
				lcWBSrce = Iif(m.llWSSrce, m.taWBWSSrce[m.lnWBSrce, 1], m.taWBWSSrce[m.lnWBSrce])
				IF Vartype(m.lcWBSrce) == 'C' AND File(m.lcWBSrce)

					* Ouvrir le classeur source
					loWBSrce = m.loXL.WorkBooks.Open(FullPath(m.lcWBSrce))
					
					* Si une feuille source a été indiquée
					lcWSSrce = Iif(m.llWSSrce, m.taWBWSSrce[m.lnWBSrce, 2], Space(0))
					laResult[m.lnWBSrce] = .T.
					IF Vartype(m.lcWSSrce) == 'C' ;
					 AND NOT Empty(m.lcWSSrce)
						
						* Si la feuille existe dans le classeur
						IF lXLWS(m.lcWSSrce, m.loWBSrce)

							* Ouvrir la feuille source indiquée,
							loWSSrce = m.loWBSrce.Worksheets(m.lcWSSrce)
							
						* Sinon, erreur
						ELSE
							laResult[m.lnWBSrce] = .F.
						ENDIF

					* Sinon, (aucune feuille source indiquée), ouvrir la première feuille
					ELSE
						loWSSrce = m.loWBSrce.Worksheets(1)
						lcWSSrce = m.loWSSrce.Name
					ENDIF

					* Si la feuille a été ouverte,
					IF laResult[m.lnWBSrce]

						* Si le classeur destination n'est pas créé, le créer
						IF NOT m.llWBDest
							LOCAL ;
								loWBDest as Excel.Workbook,;
								lnWBDestDefaultSheets,;
								loWSDest as Excel.Worksheet
							loWBDest = m.loXL.workBooks.add() && new WB
							lnWBDestDefaultSheets = m.loWBDest.Sheets.Count && default sheets
							loWSDest = m.loWBDest.Sheets(m.lnWBDestDefaultSheets) && Last sheet
							llWBDest = .T.
						ENDIF
							
						IF m.tlBeautify
							XLWStableBeautify(m.loWSSrce)
						ENDIF

						* Copier la feuille dans le classeur destination après les feuilles existantes
						loWSSrce.Copy(NULL, m.loWSDest)
						loWSDest = m.loWBDest.Sheets(m.loWBDest.Sheets.Count) && last sheet

						* Supprimer les styles automatiques nommés selon la nouvelle feuille
						lcWBSrce = Upper(JustStem(m.lcWBSrce))
						lcWSSrce = Upper(Alltrim(m.lcWSSrce))
						LOCAL lcStyle, loStyle as Excel.Style
						FOR EACH m.loStyle IN m.loWBDest.Styles
							lcStyle = Upper(Alltrim(m.loStyle.Name))
							IF Right(m.lcStyle, 1 + Len(m.lcWBSrce)) == '_' + m.lcWBSrce ;
							 OR Right(m.lcStyle, 1 + Len(m.lcWSSrce)) == '_' + m.lcWSSrce
								loStyle.Delete()
							ENDIF
						ENDFOR

						* Fermer le classeur source
						loWSSrce = .NULL.
						loWBSrce.Close

						* Si la suppression des classeurs sources a été demandée, supprimer
						IF m.tlWBSrceDel
							DELETE FILE (m.lcWBSrce)
						ENDIF
					ENDIF
				ENDIF
			ENDFOR

			* Si le classeur destination a bien été créé
			IF m.llWBDest
				WITH m.loWBDest

					* Supprimer les feuilles initiales vides
					IF m.lnWBDestDefaultSheets > 0
						LOCAL lnSheet
						FOR m.lnSheet = m.lnWBDestDefaultSheets TO 1 STEP -1
							.Sheets(m.lnSheet).Delete()
						ENDFOR
					ENDIF

					* Sélectionner la première feuille et dimensionner la fenêtre
					.Sheets(1).Select()
					.Windows(1).Width = 900
					.Windows(1).Height = 700
					
					* Enregistrer et fermer le nouveau classeur
					.SaveAs(m.tcWBDestAddr, xlWorkbookNormal)
					.Close
				ENDWITH
				
				* Calculer le résultat
				llResult = Ascan(m.laResult, .F.) = 0
			ENDIF
		ENDIF
	ENDIF

	RETURN m.llResult

	* -------------------------------------------------------------
	PROCEDURE XLWBfromWSs_Test && teste XLWBfromWSs, ancienne version
	
	?
	? Sys(16)

	PRIVATE poXL as excel.Application
	poXL = oXL()

	LOCAL lcDos, lcAdr
	lcDos = "C:\aDossier\3639 VS Emb PL\Client\Envoi\"
	lcAdr = m.lcDos + "XLWBfromWSs_Test.xls"
	DELETE FILE (m.lcAdr)

	LOCAL ARRAY laWBs[2, 2]
	laWBs[1,1] = m.lcDos + "KEM_Warn.xls"
	laWBs[1,2] = "KEM_Warn"
	laWBs[2,1] = m.lcDos + "EEM_Warn.xls"
	laWBs[2,2] = "EEM_Warn"

	? XLWBfromWSs(@laWBs, m.lcAdr)
	
	poXL.quit()

	* -------------------------------------------------------------
	PROCEDURE XLWBfromWSs_Test && teste XLWBfromWSs, nouvelle version
	
	LOCAL loTest as abUnitTest OF abDev.prg
	loTest = NewObject('abUnitTest', 'abDev.prg')

	LOCAL lcDos
	lcDos = "C:\aDossier\3639 VS Emb PL\Client\Envoi\"
	IF Directory(m.lcDos)

		LOCAL ARRAY laWBs[2, 2]
		laWBs[1,1] = m.lcDos + "KEM_Warn.xls"
		laWBs[1,2] = "KEM_Warn"
		laWBs[2,1] = m.lcDos + "EEM_Warn.xls"
		laWBs[2,2] = "EEM_Warn"
		IF File(m.laWBs[1,1]) AND File(m.laWBs[2,1])

			LOCAL lcAdr
			lcAdr = m.lcDos + "XLWBfromWSs_Test.xls"
			DELETE FILE (m.lcAdr)

			PRIVATE poXL as Excel.Application
			poXL = oXL()

			loTest.Test( .T., @laWBs, m.lcAdr)

			poXL.quit()
		ENDIF
	ENDIF

	RETURN loTest.Result()
	*========================================
	PROCEDURE XLWSofTableMemo && feuille Excel d'après une table FoxPro avec les champs MEMO (impossible avec COPY TO)
	LPARAMETERS ;
		tuTable,;	&& [Alias()] Alias, zone ou adresse de la table source
		tcXLWBAddr && [forceExt(tuTable, 'XLS'] Adresse du classeur XL cible
	LOCAL llResult
	llResult = .T.
	
	* Si la table existe
	LOCAL lcAlias, llDBFOpened
	lcAlias = cAlias(m.tuTable, @llDBFOpened)
	llResult = Used(m.lcAlias)
	ASSERT m.llResult MESSAGE Program() + " - Invalid table specification : " + cLitteral(m.tuTable)
	IF m.llResult
	
		* Si le classeur peut être ouvert ou créé
		LOCAL lcTableAddr, lcXLWBAddr, loXLWB as Excel.Workbook, llXLSOpened, llCreated
		lcTableAddr = cTableAddress(m.lcAlias)
		lcXLWBAddr = uDefault(m.tcXLWBAddr, ForceExt(m.lcTableAddr, EXT_XLS))
		loXLWB = oXLWB(m.lcXLWBAddr, @llXLSOpened, @llCreated)
		llResult = loXLWB(m.loXLWB)
		IF m.llResult
			WITH m.loXLWB as Excel.Workbook
			
				* Si la feuille existe,
				LOCAL lcXLWS, loXLWS as Excel.Worksheet
				lcXLWS = JustStem(m.lcTableAddr)
				IF lXLWS(m.lcXLWS, m.loXLWB)
					
					* Sélectionner
					loXLWS = .Worksheets(m.lcXLWS)

					* Razer les données et les styles
					WITH m.loXLWS.UsedRange as Excel.Range
						.Value = .NULL.
						.Style = m.loXLWB.Styles.Item('normal')
					ENDWITH

				* Sinon, ajouter une feuille au classeur
				ELSE
					loXLWS = .Worksheets.Add()
					loXLWS.Name = m.lcXLWS
				ENDIF

				WITH m.loXLWS as Excel.Worksheet
					
					* Copier les noms des champs dans la première ligne
					LOCAL lnRow, lnCol, lnCols
					lnRow = 1
					lnCols = Fcount(m.lcAlias)
					FOR m.lnCol = 1 TO m.lnCols
						.Cells(m.lnRow, m.lnCol).Value = Field(m.lnCol, m.lcAlias)
					ENDFOR

					* Copier les données de la table dans les lignes suivantes
					LOCAL lnSelect, luValue
					lnSelect = Select(0)
					SELECT (m.lcAlias)
					SCAN
						lnRow = m.lnRow + 1
						FOR m.lnCol = 1 TO m.lnCols
							luValue = Evaluate(Field(m.lnCol, m.lcAlias))
							luValue = Iif(Vartype(m.luValue) == 'C', Rtrim(m.luValue), m.luValue)
							.Cells(m.lnRow, m.lnCol).Value = m.luValue
						ENDFOR
					ENDSCAN
					SELECT (m.lnSelect)
				ENDWITH
				
			* Sauver le classeur et fermer Excel
				IF m.llCreated
					.SaveAs(m.lcXLWBAddr, xlWorkbookNormal)
				ELSE
					.Save()
				ENDIF
				IF m.llXLSOpened
					.Parent.Quit()
				ENDIF
			ENDWITH
		ENDIF
		IF m.llDBFOpened
			USE IN (m.lcAlias)
		ENDIF
	ENDIF

	RETURN m.llResult
	
	*========================================
	PROCEDURE TableMemoOfXLWS && Table FoxPro avec les champs MEMO d'après une feuille Excel (impossible avec Import ou append from)
	LPARAMETERS ;
		tuTable,;	&& [Alias()] Alias, zone ou adresse de la table destination
		tcXLWBAddr,; && [forceExt(tuTable, 'XLS'] Adresse du classeur XL source
		tcXLWS,; && [première] Feuille contenant les données à importer
		tlFieldsCheck && [.F.] Vérifier que les champs de la feuille sont tous dans la table
	LOCAL llResult
	llResult = .T.
	
	* Si la table existe
	LOCAL lcAlias, llOpened
	lcAlias = cAlias(m.tuTable, @llOpened)
	llResult = Used(m.lcAlias)
	ASSERT m.llResult MESSAGE cAssertMsg(Textmerge("<<Program()>> - Invalid table specification : <<cLitteral(m.tuTable)>>"))
	IF m.llResult
	
		* Si le classeur existe et peut être ouvert en automation
		LOCAL lcTableAddr, lcXLWBAddr, loXLWB as Excel.Workbook, llOpened, llCreated
		lcTableAddr = cTableAddress(m.lcAlias)
		lcXLWBAddr = uDefault(m.tcXLWBAddr, ForceExt(m.lcTableAddr, EXT_XLS))
		loXLWB = oXLWB(m.lcXLWBAddr, @llOpened, @llCreated)
		llResult = loXLWB(m.loXLWB) AND NOT m.llCreated
		IF m.llResult
			WITH m.loXLWB as Excel.Workbook
			
				* Sélectionner la feuille indiquée, la première par défaut
				LOCAL lcXLWS, loXLWS as Excel.Worksheet
				lcXLWS = uDefault(m.tcXLWS, Space(0))
				loXLWS = .Worksheets(Iif(lXLWS(m.lcXLWS, m.loXLWB), m.lcXLWS, 1))
				WITH m.loXLWS as Excel.Worksheet
					lcXLWS = .Name
					LOCAL lnCols, lnRow, lnCol
					lnCols = .UsedRange.Columns.Count
					
					* Si tous les champs dont les noms sont dans la première ligne figurent dans la table
					LOCAL llFieldsCheck, lcField
					llFieldsCheck = uDefault(m.tlFieldsCheck, .F.)
					LOCAL ARRAY laFields[m.lnCols]
					lnRow = 1
					FOR m.lnCol = 1 TO m.lnCols
						lcField = .Cells(m.lnRow, m.lnCol).Value
						IF lField(m.lcField, m.lcAlias)
							laFields[m.lnCol] = m.lcField
						ELSE
							llResult = NOT m.llFieldsCheck
							IF m.llResult
								laFields[m.lnCol] = Space(0)
							ELSE
								EXIT
							ENDIF
						ENDIF
					ENDFOR
					ASSERT m.llResult MESSAGE Program() + " - Some Field(s) of Worksheet " + cLitteral(m.lcXLWS) + " miss in table" + cLitteral(m.tuTable)
					IF m.llResult

						* Si la table peut être ouverte en exclusif
						lcAlias = ExclusiveForce(m.lcAlias)
						llResult = Used(m.lcAlias)
						ASSERT m.llResult MESSAGE Program() + " - Table cannot be opened exclusively :" + cLitteral(m.tuTable)
						IF m.llResult
							LOCAL lnSelect
							lnSelect = Select(0)
							SELECT (m.lcAlias)
							
							* Vider la table
							ZAP
							
							* Rouvrir en shared
							USE
							lcAlias = cAlias(m.tuTable)
							SELECT (m.lcAlias)
							
							* Créer une variable mémoire par champ destination
							LOCAL lcFields, luValue
							lcFields = cListOfArray(@laFields)
							lcFields = Strtran(m.lcFields, ',' + ',', ',') && élimine les champs vides
							LOCAL &lcFields

							* Pour chaque ligne de données de la feuille Excel
							FOR m.lnRow = 2 TO .UsedRange.Rows.Count
								
								* Ajouter un nouvel enregistrement vierge
								APPEND BLANK
								SCATTER MEMVAR MEMO
							
								* Pour chaque colonne comportant un champ présent dans la table
								FOR m.lnCol = 1 TO m.lnCols
									lcField = m.laFields[m.lnCol]
									IF NOT Empty(m.lcField)

										* Si le contenu de la cellule est non nul, copier en mémoire
										luValue = .Cells(m.lnRow, m.lnCol).Value
										IF NOT IsNull(m.luValue)
											STORE m.luValue TO (m.lcField)
										ENDIF
									ENDIF
								ENDFOR
							
								* Copier la mémoire dans la table
								GATHER MEMVAR MEMO
							ENDFOR
							SELECT (m.lnSelect)
						ENDIF
					ENDIF
				ENDWITH

				* Refermer Excel
				.Parent.Quit()
			ENDWITH
		ENDIF
		IF m.llOpened
			USE IN (m.lcAlias)
		ENDIF
	ENDIF

	RETURN m.llResult
	
	*========================================
	PROCEDURE XL8table && Importe une feuille d'un Classeur Excel 97 dans une table
	LPARAMETERS ;
		tcXLWBAddr,; && Adresse du MASQUE de classeur Excel contenant la feuille à importer
		tcSheet,; && [feuille n°1] Nom de la feuille à importer
		tlNonVerifDernVers,; && [.F.] @ Ne pas prendre le dernier n° de version du classeur Excel ; @ la table a été rafraîchie
		tlImportForce,; && [.F.] Importer même si le classeur est plus ancien que la table
		tlCursor,; && [.F.] Importer dans un curseur
		tcFieldsAdd,; && [aucun] Champs à ajouter à la table ou au curseur résultat (définition type ALTER TABLE)
		tlAutomation && [.F.] Toujours importer par automation Excel

	tcSheet = Upper(uDefault(m.tcSheet, Space(0)))
	tlNonVerifDernVers = Vartype(m.tlNonVerifDernVers) == 'L' AND m.tlNonVerifDernVers
	tlImportForce = Vartype(m.tlImportForce) == 'L' AND m.tlImportForce
	tlCursor = Vartype(m.tlCursor) == 'L' AND m.tlCursor
	tcFieldsAdd = Evl(m.tcFieldsAdd, Space(0))
	tlAutomation = Vartype(m.tlAutomation) == 'L' AND m.tlAutomation

	&& La première ligne de la feuille doit contenir les noms des champs
	&& Les colonnes sont importées en caractères
	&& Les colonnes masquées ou sans nom ne sont pas importées
	&& Les colonnes servant à une concaténation sont tronquées

	LOCAL llResult, lcResult && Adresse de la table créée OU nom du curseur OU message d'erreur

	*================================================================
	* Date      Par   Action
	* ---------	----	----------------------------------------------------------------------------------
	* 17/05/00	RA		Création
	* 06/11/00	RA		Ajout de la procedure de recherche de dernière version
	* 07/11/00	RA		Passage de procedure en fonction de maniere à retourner le nom de la dernière version qui a été importé
	* 22/12/00	RA		Ajout de la procédure qui vérifie si l'import est réellement à faire (fichier DBF + récent que XLS)
	* 12/04/01	TN		Suppression des colonnes sans nom
	* 16/04/01	TN		Gestion du cas où le classeur demandé n'existe pas
	* 20/04/01	TN		Déboguage et simplification du renommage de la table créée
	* 19/06/01	TN		Ajout du troisième paramètre
	* 26/11/02	TN		Optimisation et restructuration
	*================================================================

	lcResult = Space(0)
	llResult = Vartype(m.tcXLWBAddr) == 'C'
	IF m.llResult

		* Si un classeur existe selon le masque spécifié
		LOCAL lcXLWBAddr, lcXLWBPath, lcDBFStem, lcDBFAddr, lcAliasUsed, llAliasUsed, llExclusive
		lcXLWBAddr = Iif(m.tlNonVerifDernVers, FullPath(m.tcXLWBAddr), cFileFreshest(m.tcXLWBAddr))
		llResult = File(m.lcXLWBAddr)
		IF m.llResult

			* Déterminer l'adresse de la table destination
			lcXLWBPath = Addbs(JustPath(m.lcXLWBAddr))
			lcDBFStem = Iif(Empty(m.tcSheet), JustStem(m.tcXLWBAddr), m.tcSheet)
			lcDBFAddr = ForcePath(m.lcDBFStem + '.' + EXT_DBF, m.lcXLWBPath)

			* Si la table est ouverte, la fermer
			lcAliasUsed = Iif(File(m.lcDBFAddr), cAliasUsed(m.lcDBFAddr, @llExclusive), '')
			llAliasUsed = Used(m.lcAliasUsed)
			IF m.llAliasUsed
				USE IN (m.lcAliasUsed)
			ENDIF

			* Si import systématique ou classeur plus récent que la table
			tlNonVerifDernVers = .F. && indique en retour si la feuille a été importée
			IF m.tlImportForce OR Nvl(lFileFresher(m.lcDBFAddr, m.lcXLWBAddr), .T.)

				* Si le classeur n'est pas couramment ouvert (IMPORT FROM échoue si le classeur est ouvert en read-write)
				LOCAL lnHandle
				lnHandle = Fopen(m.lcXLWBAddr, 2) && 2 : read-write, buffered
				llResult = m.lnHandle > 0 ;
				 OR Set('ASSERT') == 'ON';
				 	 AND 6 = MessageBox(;
									"L'importation de données depuis le classeur " + m.lcXLWBAddr + " est impossible car il est ouvert par Excel" + CRLF + ;
									"Pour continuer l'importation, veuillez fermer le classeur et cliquer sur 'oui'" + CRLF + ;
									"Pour abandonner l'importation, cliquez sur 'non'" + CRLF + ;
									"Continuer ?";
								, 4+16)
				Fclose(m.lnHandle)
				IF m.llResult

					* Tabuler les champs additionnels éventuels
					LOCAL laFieldAdd[1]
					IF NOT Empty(m.tcFieldsAdd)
						aFieldsDef(@laFieldAdd, m.tcFieldsAdd)
					ENDIF
					
					* Si la feuille peut être importée
					LOCAL loDefault, loSelect, lcSheet, loException as Exception, llSheetError, llFormatError
					loDefault = abSet('Default', m.lcXLWBPath) && IMPORT crée la table dans le dossier par défaut
					loSelect = abSelect(0)
					lcSheet = Iif(Empty(m.tcSheet), Space(0), Textmerge([SHEET <<m.tcSheet>>]))
					llResult = m.tlAutomation
					IF NOT m.llResult
						TRY 
							IMPORT FROM (m.lcXLWBAddr) TYPE XL8 &lcSheet
							llResult = .T.
						CATCH TO loException
							llSheetError = m.loException.ErrorNo = 1775 && You are trying to specify a worksheet name that does not match a name in the specified .XLS file.
							llFormatError = m.loException.ErrorNo = 1661 && The Microsoft Excel file you have attempted to import is either not version 8.0 or has been corrupted.
						ENDTRY
					ENDIF
					RELEASE loDefault

					DO CASE
					CASE m.tlAutomation OR m.llFormatError

						* Traiter le classeur en automation
						lcResult = XL8table_Auto(m.lcXLWBAddr, m.tcSheet, m.lcDBFAddr,, m.tlCursor, @laFieldAdd)
						llResult = Iif(m.tlCursor, Used(m.lcResult), File(m.lcResult))

					CASE m.llResult && IMPORT FROM successful

						LOCAL lcAlias
						lcAlias = Alias()

						* Alléger la table
						FreeTableSlim(m.lcAlias, 20) && 20% de marge

						* Renommer les champs par le contenu de la premiere ligne du tableau
						lcAlias = XL8table_ModiStru(m.lcAlias, m.tlCursor, @laFieldAdd)
						llResult = Used(m.lcAlias)
						IF m.llResult
						
							IF m.tlCursor
							
								lcResult = m.lcAlias
							ELSE

								* Renommer la table selon le nom de la feuille ou du classeur spécifiés
								LOCAL lcDBFImportAddr, lcFPTImportAddr, lcFPTAddr
								lcDBFImportAddr = cTableAddress(m.lcAlias)
								USE IN (m.lcAlias)
								IF Fullpath(m.lcDBFImportAddr) # Fullpath(m.lcDBFAddr)

									DELETE FILE (m.lcDBFAddr)
									RENAME (m.lcDBFImportAddr) TO (m.lcDBFAddr)

									lcFPTImportAddr = ForceExt(m.lcDBFImportAddr, 'fpt')
									IF File(m.lcFPTImportAddr)
										lcFPTAddr = ForceExt(m.lcDBFAddr, 'fpt')
										DELETE FILE (m.lcFPTAddr)
										RENAME (m.lcFPTImportAddr) TO (m.lcFPTAddr)
									ENDIF
								ENDIF

								lcResult = m.lcDBFAddr
							ENDIF
						ELSE
							lcResult = "XL8table() : Impossible de nommer les champs selon le contenu de la première ligne de la feuille " + m.tcSheet + " du classeur " + m.lcXLWBAddr
						ENDIF

					CASE m.llSheetError
						lcResult = "XL8table() : Importation impossible car la feuille " + m.tcSheet + " n'existe pas dans le classeur " + m.lcXLWBAddr

					OTHERWISE
						lcResult = cException(m.loException)
					ENDCASE
				ELSE
					lcResult = "XL8table() : Importation impossible car le classeur " + m.lcXLWBAddr + " était ouvert."
				ENDIF

				tlNonVerifDernVers = m.llResult && indique en retour si la feuille a été importée
			ELSE
				lcResult = m.lcDBFAddr
			ENDIF

			* Si la table était ouverte, la rouvrir
			IF m.llAliasUsed
				LOCAL lcExclusive
				lcExclusive = Iif(m.llExclusive, 'Exclusive', 'Shared')
				USE (m.lcDBFAddr) IN 0 &lcExclusive
			ENDIF
		ELSE
			lcResult = Textmerge("XL8table() : Importation impossible car aucun classeur n'existe selon le masque spécifié : '<<Alltrim(tcXLWBAddr)>>'")
		ENDIF
	ELSE
		lcResult = "XL8table() : Veuillez spécifier un masque de classeur XL en première paramètre"
	ENDIF
	
	ASSERT m.llResult MESSAGE m.lcResult

	RETURN m.lcResult

	*========================================
	PROCEDURE XL8table_Auto && Importe une feuille excel en automation
	LPARAMETERS ;
		tcXLWBAddr,; && Adresse du MASQUE de classeur Excel contenant la feuille à importer
		tcSheet,; && [feuille n°1] Nom de la feuille à importer
		tcTable,; && Table à créer
		tlNULL,; && [.F.] accepter les valeurs nulles
		tlCursor,; && [.F.] produire un curseur
		taFieldAdd && @ Champs additionnels éventuels

	tlNULL = lTrue(m.tlNULL)
	tlCursor = lTrue(m.tlCursor)
	EXTERNAL ARRAY taFieldAdd

	LOCAL lcResult as String;
	, loXL as Excel.Application;
	, loWB as Excel.Workbook;
	, loWS as Excel.Worksheet;
	, loWF as Excel.WorksheetFunction;
	, loRange as Excel.Range;

	* Ouvrir la feuille Excel en automation
	loXL = oXL()
	loWB = loXL.Workbooks.Open(m.tcXLWBAddr, .F., .T.)
	loWS = loWB.Worksheets(Iif(Vartype(m.tcSheet) == 'C' AND NOT Empty(m.tcSheet), m.tcSheet, 1))
	loWF = m.loXL.WorksheetFunction
	lcResult = Space(0)
	if !m.loXL.Calculation = -4105  && xlCalculationAutomatic
		m.loWS.Calculate
	endif
	WITH m.loWS.UsedRange as Excel.Range
		
		* Pour chaque colonne
		LOCAL lnCols, lnCol, lcCol, lnField, lcField, lnSuffix, lnRow, laCols[.Columns.Count, 6], luValue, lcType, lnLen
		lnCols = Min(.Columns.Count, 254)
		lnField = Iif(m.tlCursor, 128, 10)
		FOR lnCol = 1 TO m.lnCols

			lcType = 'U'
			STORE 0 TO laCols[m.lnCol, 3], laCols[m.lnCol, 4]
			FOR lnRow = 1 TO .Rows.Count
				IF m.lnRow = 1

					* Première ligne : lire le nom du champ
					lcCol = cVFPName(.Cells(1, m.lnCol).Value, m.lnField)
					lcCol = Evl(m.lcCol, [Col] + Transform(m.lnCol))

					* Dédoublonner le cas échéant
					lcField = m.lcCol
					lnSuffix = 0
					DO WHILE Ascan(laCols, m.lcField, 1, -1, 1, 1+2+4) > 0
						lnSuffix = m.lnSuffix + 1
						lcField = Left(m.lcCol, m.lnField-2) + '_' + Transform(m.lnSuffix)
					ENDDO
					laCols[m.lnCol, 1] = m.lcField
				ELSE

					* Autres lignes: déterminer le type du champ d'après le contenu
					loRange = .Cells(m.lnRow, m.lnCol)
					luValue = Iif(m.loRange.HasFormula() and m.loWF.IsError(m.loRange); && plantage si la cellule contient une erreur de formule http://stackoverflow.com/questions/2424718/how-to-know-if-a-cell-has-an-error-in-the-formula-in-c-sharp
						, .null.;
						, m.loRange.Value;
						)
					IF IsNull(m.luValue)
						IF m.tlNULL
							laCols[m.lnCol, 5] = .T.
						ENDIF
						LOOP

					ELSE

						lcType = Iif(m.lcType $ 'CMDT';
							, m.lcType;
							, Vartype(m.luValue);
							)
						
						DO CASE
						CASE m.lcType == 'C'
							luValue = Transform(m.luValue)
							lnLen = Evl(Len(Trim(m.luValue)), 1)
							IF m.lnLen > 254 OR CRLF $ m.luValue
								lcType = 'M'
								LOOP
							ELSE
								laCols[m.lnCol, 3] = Max(laCols[m.lnCol, 3] , m.lnLen)
							ENDIF
						CASE m.lcType == 'N'
							laCols[m.lnCol, 3] = Max(laCols[m.lnCol, 3] , Len(Transform(m.luValue))) && à modifier pour point décimal
						ENDCASE
					ENDIF
				ENDIF
			ENDFOR
			lcType = Iif(m.lcType == 'U', 'M', m.lcType)
			laCols[m.lnCol, 2] = m.lcType
			laCols[m.lnCol, 3] = ICase(m.lcType $ 'DT', 8, m.lcType $ 'BIM', 4, m.lcType == 'L', 1, laCols[m.lnCol, 3])
		ENDFOR
		
		* Créer la table ou le curseur
		LOCAL laFields[1], lnFields
		lnFields = 0
		FOR lnCol = 1 TO m.lnCols
			IF NOT Empty(laCols[m.lnCol, 1])
				lnFields = m.lnFields + 1
				DIMENSION laFields[m.lnFields, 5]
				laFields[m.lnFields, 1] = laCols[m.lnCol, 1]
				laFields[m.lnFields, 2] = laCols[m.lnCol, 2]
				laFields[m.lnFields, 3] = laCols[m.lnCol, 3]
				laFields[m.lnFields, 4] = laCols[m.lnCol, 4]
				laFields[m.lnFields, 5] = laCols[m.lnCol, 5]
				laCols[m.lnCol, 6] = m.lnFields && pour correspondance lors du remplissage
			ENDIF
		ENDFOR
		
		IF NOT laEmpty(@taFieldAdd)
			aColsDel(@taFieldAdd, 6)
			aAppend(@laFields, @taFieldAdd)
		ENDIF

		lcResult = Iif(m.tlCursor, JustStem(m.tcTable), m.tcTable)
		IF m.tlCursor
			CREATE CURSOR (m.lcResult) FROM ARRAY laFields
		ELSE
			CREATE TABLE (m.lcResult) FREE FROM ARRAY laFields
		ENDIF
		
		* Importer les données
		LOCAL loTalk, luValue
		loTalk = abSet('TALK', 'OFF')
		FOR lnRow = 2 TO .Rows.Count
			APPEND BLANK
			FOR lnCol = 1 TO .Columns.Count
				IF NOT Empty(laCols[m.lnCol, 1])
					luValue = .Cells(m.lnRow, m.lnCol)
					luValue = Iif(m.luValue.HasFormula() and m.loWF.IsError(m.luValue);
						, .null.;
						, m.luValue.Value;
						)
					luValue = Iif(laCols[m.lnCol, 2] $ 'CM';
						, Transform(Nvl(m.luValue, ''));
						, uValue(m.luValue, laCols[m.lnCol, 2]);
						)
					IF NOT m.tlNULL AND IsNull(m.luValue)
						lcType = laFields[m.lnCol, 2]
						lcType = Iif(m.lcType $ 'M', 'C', m.lcType)
						luValue = uEmpty(m.lcType)
					ENDIF
					REPLACE (Field(laCols[m.lnCol, 6])) WITH m.luValue
				ENDIF
			ENDFOR
		ENDFOR
	ENDWITH

	loWB.Close
	loXL.Quit
	
	FreeTableSlim(Alias(), 20) && 20% de marge

	IF NOT m.tlCursor
		USE
	ENDIF
	
	RETURN m.lcResult

	*========================================
	PROCEDURE XL8table_ModiStru	&& Renomme les champs selon la première ligne de la feuille XL
	LPARAMETERS ;
		tcAlias,;	&& Alias de la table importée d'Excel
		tlCursor,; && [.F.] produire un curseur
		taFieldAdd && @ Champs additionnels éventuels
	tlCursor = Vartype(m.tlCursor) == 'L' AND m.tlCursor
	EXTERNAL ARRAY taFieldAdd

	LOCAL llResult, lcResult && Alias du résultat

	* Si la table peut être ouverte en exclusif
	lcResult = ExclusiveForce(m.tcAlias)
	llResult = Used(m.lcResult)
	IF m.llResult

		LOCAL loSelect,;
			lnFields,;
			laFields[1],;
			lnField,;	&&	ne pas utiliser 'i' qui est un nom de colonne XL
			lcField,;
			laFieldsNew[1],;
			lcFieldNew,;
			lnSuffix,;
			lcSuffix,;
			lcAlter,;
			lcDelete,;
			lcAddr

		* Lire la structure de la table
		loSelect = abSelect(m.lcResult)
		lnFields = AFields(laFields)

		* Lire les nouveaux noms des champs dans la première ligne et supprimer celle-ci
		GO 1
		SCATTER TO laFieldsNew MEMO
		DELETE
		PACK

		* Pour chaque champ de la table
		STORE Space(0) TO lcAlter, lcDelete
		FOR m.lnField = m.lnFields TO 1 STEP -1
			lcField = laFields[m.lnField, 1]

			* Si le nouveau nom est vide
			lcFieldNew = laFieldsNew[m.lnField]
			lcFieldNew = Iif(Vartype(m.lcFieldNew) == 'C', Upper(Alltrim(m.lcFieldNew)), Space(0)) && toujours vrai en principe
			IF Empty(m.lcFieldNew)

				* Supprimer le champ
				lcDelete = Textmerge([<<m.lcDelete>> DROP COLUMN <<m.lcField>>])
				IF m.tlCursor
					Adel(laFields, m.lnField)
				ENDIF
				lnFields = m.lnFields - 1

			* Sinon (nouveau nom de champ non vide)
			ELSE

				* Normaliser le nom du champ
				lcFieldNew = cVFPName(m.lcFieldNew, Iif(m.tlCursor, 128, 10))

				* Si le nom du champ existe déjà, lui donner un suffixe numérique
				lnSuffix = 0
				DO WHILE Ascan(laFields, m.lcFieldNew, 1, -1, 1, 2+4) > 0
					lnSuffix = m.lnSuffix + 1
					lcSuffix = Transform(m.lnSuffix)
					lcFieldNew = Substr(m.lcFieldNew, 1, 10-Len(m.lcSuffix)) + m.lcSuffix
				ENDDO

				* Renommer le champ
				IF m.tlCursor
					laFields[m.lnField, 1] = m.lcFieldNew
				ELSE
					lcAlter = Textmerge([<<m.lcAlter>> RENAME COLUMN <<m.lcField>> TO <<m.lcFieldNew>>])
				ENDIF
			ENDIF
		ENDFOR
		
		* Si des champs additionnels sont demandés
		IF NOT laEmpty(@taFieldAdd)
			IF m.tlCursor
				aAppend(@laFields, @taFieldAdd)
			ELSE
				FOR lnField = 1 TO Alen(taFieldAdd, 1)
					lcField = cFieldExp(taFieldAdd[m.lnField, 1], taFieldAdd[m.lnField, 2], taFieldAdd[m.lnField, 3], taFieldAdd[m.lnField, 4], taFieldAdd[m.lnField, 5])
					lcAlter = Textmerge([<<m.lcAlter>> ADD COLUMN <<m.lcField>>])
				NEXT
			ENDIF
		ENDIF

		* Si un curseur a été demandé
		lcAddr = cTableAddress(m.lcResult)
		IF m.tlCursor

			LOCAL lcCursor, laData[1]
			
			* Créer le curseur
			lcCursor = Sys(2015)
			CREATE CURSOR (m.lcCursor) FROM ARRAY laFields

			* Supprimer les champs inutiles de la table
			ALTER TABLE (m.lcResult) &lcDelete
			
			* Remplir avec les données de la table
			SELECT (m.lcResult)
			SCAN
				SCATTER TO laData
				INSERT INTO (m.lcCursor) FROM ARRAY laData
			ENDSCAN
			USE
			
			* Supprimer la table qui ne sert plus à rien
			DELETE FILE (m.lcAddr)

			lcResult = m.lcCursor
		
		* Sinon (table)
		ELSE
			ALTER TABLE (m.lcResult) &lcDelete &lcAlter
		ENDIF

		DELETE FILE (ForceExt(m.lcAddr, 'BAK')) && Supprime le fichier de sauvegarde
	ENDIF

	RETURN m.lcResult

*-					* Si le champ est numérique, le passer en caractères et supprimer les espaces en tête
*-					IF laFields[m.lnField, 2] == 'N'
*-						ALTER TABLE (m.lcResult) ALTER COLUMN (m.lcField) C (laFields[m.lnField,3] + 1 + laFields[m.lnField,4])
*-						REPLACE ALL (m.lcField) WITH Ltrim(Evaluate(m.lcField))
*-						laFields[m.lnField, 2] = 'C'
*-					ENDIF

	*========================================
	PROCEDURE XL8Tables	&& Importe les feuilles d'un Classeur Excel 97 dans des tables (cf. XL8table())
	LPARAMETERS ;
		taXL8Table,; && @ Tables crées ou rafraîchies ; Col 1 : Adresse, Col 2 : Rafraîchie (.T./.F.)
		tcXLWBAddr,; && Adresse du MASQUE de classeur Excel contenant les feuille à importer
		tlNonVerifDernVers,;	&& [.F.] Ne pas prendre la dernière version du classeur Excel
		tlImportForce && [.F.] Importer même si le classeur est plus ancien que la table
	EXTERNAL ARRAY taXL8Table
	tlNonVerifDernVers = Vartype(m.tlNonVerifDernVers) == 'L' AND m.tlNonVerifDernVers
	tlImportForce = Vartype(m.tlImportForce)== 'L' AND m.tlImportForce
	
	aClear(@m.taXL8Table)

	LOCAL lcXLWBAddr, llResult, lnResult && Nombre de tables crées ou rafraîchies
	lnResult = 0

	* Si un classeur existe selon le masque spécifié
	lcXLWBAddr = Iif(m.tlNonVerifDernVers, m.tcXLWBAddr, cFileFreshest(m.tcXLWBAddr))
	llResult = File(m.lcXLWBAddr)
	ASSERT m.llResult MESSAGE cAssertMsg(Textmerge("Impossible de trouver un classeur XL suivant le masque : <<cLitteral(m.tcXLWBAddr)>>"))
	IF m.llResult
		
		* Ouvrir Excel en automation si pas encore fait
		LOCAL loXL
		loXL = Vartype(m.poXL) == 'O' AND loXL(m.poXL)
		IF NOT m.loXL
			PRIVATE poXL as Excel.Application
			poXL = oXL()
		ENDIF
		llResult = loXL(m.poXL)
		ASSERT m.llResult MESSAGE "Impossible d'ouvrir Excel en automation"
		IF m.llResult

			* Si le classeur contient au moins une feuille de calcul
			LOCAL lnXLWSs, laXLWSs[1]
			lnXLWSs = acXLWSs(@laXLWSs, m.lcXLWBAddr)
			llResult = m.lnXLWSs > 0
			ASSERT m.llResult MESSAGE "Aucune feuille trouvée dans le classeur" + Space(1) + m.lcXLWBAddr
			IF m.llResult

				* Pour chaque feuille de calcul
				LOCAL lcXLWS, llUpdate, lcDBFAdr
				FOR EACH m.lcXLWS IN laXLWSs
					
					* Si la feuille peut être importée dans une table
					llUpdate = .F.
					lcDBFAdr = XL8table(m.lcXLWBAddr, m.lcXLWS, @llUpdate, m.tlImportForce)
					IF File(m.lcDBFAdr)

						* Mémoriser l'adresse de la table
						lnResult = m.lnResult + 1
						DIMENSION taXL8Table[m.lnResult, 2]
						taXL8Table[m.lnResult, 1] = m.lcDBFAdr
						taXL8Table[m.lnResult, 2] = m.llUpdate
					ENDIF
				ENDFOR
			ENDIF

			IF NOT m.loXL
				poXL.quit
				RELEASE m.poXL
			ENDIF
		ENDIF
	ENDIF

	RETURN m.lnResult

	* =====================================
	DEFINE CLASS abWord as Relation
	* =====================================

	&& Read/write
	cDefaultFolder = Sys(5) + Addbs(Curdir()) && Dossier par défaut
	
	&& Read only
	iVersion = 0

	&& Hidden
	HIDDEN ARRAY aFileConverters[1]
	HIDDEN oWord
	oWord = .NULL. && AS Word.Application

	* -------------------------------------
	PROTECTED PROCEDURE Init && Instancie Word.Application
	LOCAL loExcept, llResult
	TRY
		this.oWord = CreateObject('Word.Application')
		WITH m.this.oWord as Word.Application
			.DisplayAlerts = 0 && wdAlertsNone
			this.Init_aFileConverters
		ENDWITH
		llResult = .T.
	CATCH TO loExcept
	ENDTRY

	RETURN m.llResult && si .F., l'objet n'est pas créé

	* -------------------------------------
	HIDDEN PROCEDURE iVersion_Access
	RETURN Int(Val(this.oWord.Version)) && 8: Word 97, etc.

	* -------------------------------------
	HIDDEN PROCEDURE Init_aFileConverters && Tabule les convertisseurs de fichiers
	IF .FileConverters.Count > 0

		LOCAL lnConv, loConv as Word.FileConverter
		DIMENSION this.aFileConverters[.FileConverters.Count, 5]
		FOR lnConv = 1 TO .FileConverters.Count

			loConv = .FileConverters(m.lnConv)
			WITH loConv as Word.FileConverter

				this.aFileConverters[m.lnConv, 1] = .ClassName
				this.aFileConverters[m.lnConv, 2] = .FormatName
				this.aFileConverters[m.lnConv, 3] = .Extensions
				this.aFileConverters[m.lnConv, 4] = Iif(.CanOpen, .OpenFormat, wdOpenFormatAuto)
				this.aFileConverters[m.lnConv, 5] = Iif(.CanSave, .SaveFormat, wdFormatDocument)
			ENDWITH
		NEXT
	ENDIF

	* -------------------------------------
	PROCEDURE FileConvertersDisplay && Affiche les convertisseurs de fichiers
	LOCAL lnConv
	FOR lnConv = 1 TO Alen(m.this.aFileConverters, 1)
		? this.aFileConverters[m.lnConv, 1];
			+ Chr(9) + this.aFileConverters[m.lnConv, 2];
			+ Chr(9) + this.aFileConverters[m.lnConv, 3];
			+ Chr(9) + Transform(this.aFileConverters[m.lnConv, 4]);
			+ Chr(9) + Transform(this.aFileConverters[m.lnConv, 5])
	NEXT

	* -------------------------------------
	PROTECTED PROCEDURE wdFormat && Code format d'ouverture / sauvegarde
	LPARAMETERS ;
		tcClass,; && Classe de conversion de document (cf. this.oDoc)
		tlSave && [.F.] .T.: format de sauvegarde ; .F. : format d'ouverture
	tlSave = Vartype(m.tlSave) == 'L' AND m.tlSave

	LOCAL lnConv, lnResult && Code format

	lnResult = Iif(m.tlSave, wdFormatDocument, wdOpenFormatAuto) && Code par défaut
	IF Vartype(m.tcClass) == 'C' AND NOT Empty(m.tcClass)

		lnConv = Ascan(m.this.aFileConverters, m.tcClass, 1, -1, 1, 15)
		IF m.lnConv > 0

			lnResult = this.aFileConverters[m.lnConv, Iif(m.tlSave, 5, 4)]
		ENDIF
	ENDIF

	RETURN m.lnResult

	* -------------------------------------
	HIDDEN PROCEDURE cFullPath && Chemin complet d'un fichier
	LPARAMETERS tcFile
	RETURN ICase(;
		File(m.tcFile), FullPath(m.tcFile),;
		Directory(JustPath(m.tcFile)), Addbs(FullPath(JustPath(m.tcFile))) + JustFname(m.tcFile),;
		this.cDefaultFolder + JustFname(m.tcFile))

	* -------------------------------------
	FUNCTION oDoc && Ouvre un document et fournit sa référence
	LPARAMETERS ;
		tcFileSrce,; && Document source
		tcClassSrce,; && Classe de conversion si l'extension est ambiguë
		tcPassWord && [''] mot de passe à l'ouverture
	tcPassWord = Iif(Vartype(m.tcPassWord) == 'C', m.tcPassWord, Space(0))
		
	LOCAL llResult, lnFormat, loExcept as Exception, loResult AS Word.Document
	loResult = .NULL.
	llResult = Vartype(m.tcFileSrce) == 'C' AND File(m.tcFileSrce)
	ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([<<Program()>> - Le fichier <<m.tcFileSrce>> est introuvable]))
	IF m.llResult

		tcFileSrce = FullPath(m.tcFileSrce)
		lnFormat = this.wdFormat(m.tcClassSrce)
		WITH this.oWord.Documents as Word.Documents

			TRY && Abaque > ThN : à cause d'un pb d'installation Word 97, la première ouverture envoie un message d'erreur 'base de registre ...'
				loResult = .Open(m.tcFileSrce, .F., .F., .F., m.tcPassWord, '', .F., m.tcPassWord, '', m.lnFormat)
			CATCH TO loExcept
			ENDTRY
			loResult = Nvl(m.loResult, .Open(m.tcFileSrce, .F., .F., .F., m.tcPassWord, '', .F., m.tcPassWord, '', m.lnFormat))
			
			* Masquer le document
			IF Vartype(m.loResult) == 'O'
				loResult.Application.Visible = .F.
			ENDIF
		ENDWITH
	ENDIF

	RETURN m.loResult

	* -------------------------------------
	HIDDEN FUNCTION oDocDefault && Document par défaut
	LPARAMETERS toDoc AS Word.Document, tnDoc && @ n° de document

	LOCAL llResult

	toDoc = ICase(.F., .NULL.;
		, Vartype(m.toDoc) == 'O', m.toDoc;
		, Type('this.oWord.Documents(1)') == 'O', this.oWord.Documents(1);
		, .NULL.)
	llResult = Vartype(m.toDoc) == 'O'
	ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([<<Program()>> - Aucun document n'est ouvert dans Word ...]))
	IF m.llResult

		* Trouver le n° du document
		FOR tnDoc = 1 TO this.oWord.Documents.Count
			IF this.oWord.Documents(m.tnDoc).FullName == m.toDoc.FullName && this.oWord.Documents(m.tnDoc) = m.toDoc ne marche pas en automation
				EXIT
			ENDIF
		NEXT
	ENDIF

	RETURN m.toDoc

	* -------------------------------------
	PROCEDURE oDocConvert && Sauvegarde un document dans un autre format (si supporté)
	LPARAMETERS ;
		tcFileDest,; && @ Adresse du fichier destination
		tcClassDest,; && Classe de conversion si l'extension est ambiguë
		tcPassWord,; && [''] mot de passe
		toDoc && [Documents(1)] Référence au document source
	tcPassWord = Iif(Vartype(m.tcPassWord) == 'C', m.tcPassWord, Space(0))
	LOCAL loException, lnFormat, llResult

	toDoc = this.oDocDefault(m.toDoc)
	llResult = Vartype(m.toDoc) == 'O'
	IF m.llResult
	
		tcFileDest = this.cFullPath(m.tcFileDest)
		lnFormat = this.wdFormat(m.tcClassDest, .T.)

		DELETE FILE (m.tcFileDest)
		TRY
			toDoc.SaveAs(m.tcFileDest, m.lnFormat, .F., m.tcPassWord)
		CATCH TO loException
		ENDTRY
		llResult = lFile(m.tcFileDest)
		IF NOT m.llResult && Abaque ThN : Word 97 me fait des misères

			toDoc.SaveAs(m.tcFileDest, m.lnFormat, .F., m.tcPassWord)
			llResult = lFile(m.tcFileDest)
		ENDIF
	ENDIF

	RETURN m.llResult

	* -------------------------------------
	PROCEDURE Convert && Ouvre un document et le convertit dans un autre format (si supporté)
	LPARAMETERS ;
		tcFileSrce,; && Document source
		tcClassSrce,; && Classe de conversion si l'extension est ambiguë
		tcFileDest,; && @ Adresse du fichier destination
		tcClassDest,; && Classe de conversion si l'extension est ambiguë
		tcPassWord && [''] mot de passe
	LOCAL loDoc
	loDoc = this.oDoc(m.tcFileSrce, m.tcClassSrce, m.tcPassWord)

	RETURN Vartype(m.loDoc) == 'O';
	 AND this.oDocConvert(m.tcFileDest, m.tcClassDest, m.tcPassWord, m.loDoc);
	 AND Nvl(loDoc.Close(.F.), .T.) && .F.: no save
	
	* -------------------------------------
	PROCEDURE UserEdit && Donne la main à l'utilisateur pour éditer un document
	LPARAMETERS toDoc as Word.Document && [Documents(1)] Référence au document source
	LOCAL lnDoc, llResult

	toDoc = this.oDocDefault(m.toDoc, @lnDoc)
	llResult = Vartype(m.toDoc) == 'O'
	IF m.llResult

*		this.PreventClose && sinon ça génère des erreurs && en fait ça marche presque à tous les coups sur Word 97
		toDoc.Activate
		WITH m.this.oWord as Word.Application

			.ActiveWindow.View.Type = 1  && wdNormalView
			.Top = Max(.Top, 0)
			.Visible = .T.
			.Activate

			* Afficher un message [Enregistrez et fermez le document pour revenir à la console] && pas trouvé comment faire :-(
			
			* Attendre que l'utilisateur ait fini ses modifications
			DO WHILE Type(Textmerge('.Documents(<<m.lnDoc>>)')) == 'O'
				Inkey(.5)
			ENDDO
		ENDWITH

		IF Type('this.oWord.Application') == 'O' && L'utilisateur peut avoir fermé Word par la X
			this.oWord.Visible = .F.
		ENDIF
	ENDIF

	RETURN m.llResult

	* -------------------------------------
	PROCEDURE PreventClose && Empêche de fermer Word && Mike Gagnon sur AtoutFox

	DECLARE Integer FindWindow In user32 String lpClassName, String lpWindowName
	DECLARE Integer GetSystemMenu In user32 Integer hWnd, Integer bRevert
	DECLARE Integer RemoveMenu In user32 Integer hMenu, Integer nPosition, Integer wFlags

	LOCAL lhWin, lhMenu, lnMenu
	lhWin = FindWindow("OPUSApp", 0) &&"OPUSApp" est le nom de la Classe Word
	lhMenu = GetSystemMenu(lhWin, 0)
	FOR lnMenu = 6 TO 0 STEP -1
	 RemoveMenu(lhMenu, m.lnMenu, 1024) && MF_BYPOSITION
	NEXT
	
	this.oWord.Top = Max(this.oWord.Top, 0) && on ne peut plus bouger la fenêtre
	
	* this.oWord.CommandBars('File').Controls('Quit').Enabled = .F. && ne marche pas

	* -------------------------------------
	PROCEDURE Destroy

	LOCAL loExcept as Exception
	TRY && Type('this.oWord.Documents') == 'O' alors que l'utilisateur a fermé Word ...
		IF Type('this.oWord.Documents') == 'O'
			IF this.oWord.Documents.Count > 0
				this.oWord.Documents.Close(.F.) && ferme tous les documents
			ENDIF
			this.oWord.Quit
		ENDIF
	CATCH TO loExcept
	ENDTRY
	
	* =====================================
	ENDDEFINE && CLASS abWord
	* =====================================
