* {fr} abOffice.prg
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

* --------------------------------------------------
procedure XLWBtablesBeautify && {fr} Améliore l'aspect des feuilles d'un classeur Excel contenant une table
lparameters ;
  tcXLWB && {fr} Adresse d'un classeur Excel

local llResult, lnResult && {fr} Nombre de feuilles du classeur ont été traitées

lnResult = 0
llResult = vartype(m.tcXLWB) == 'C' and file(m.tcXLWB)
assert m.llResult message "Aucun fichier à l'adresse" + space(1) + cLitteral(m.tcXLWB)
if m.llResult

	* {fr} Ouvrir Excel en automation si pas encore fait
	local loXL as Excel.application
	loXL = vartype(m.poXL) == 'O' and loXL(m.poXL)
	if not m.loXL
		private poXL as Excel.application
		poXL = oXL()
	endif
	llResult = loXL(m.poXL)
	assert m.llResult message "Impossible d'ouvrir Excel en automation"
	if m.llResult

		* {fr} Si le classeur contient au moins une feuille de calcul
		local laXLWSs[1], lnXLWSs
		lnXLWSs = acXLWSs(@laXLWSs, m.tcXLWB)
		llResult = m.lnXLWSs > 0
		assert m.llResult message "Aucune feuille trouvée dans le classeur" + space(1) + cLitteral(m.tcXLWB)
		if m.llResult

			* {fr} Pour chaque feuille du classeur
			local lcXLWS
			for each m.lcXLWS in m.laXLWSs

				* {fr} Enrichir l'aspect
				llResult = XLWStableBeautify(oXLWS(m.tcXLWB + '|' + m.lcXLWS))
				lnResult = m.lnResult + iif(m.llResult, 1, 0)
			endfor
		endif

		if not m.loXL
			poXL.quit
			release m.poXL
		endif
	endif
endif

return m.lnResult

* --------------------------------------------------
procedure XLWStableBeautify && {fr} Améliore l'aspect d'une feuille Excel contenant une table
lparameters ;
  tuXLWS; && {fr} Référence à une feuille ou @ adresse d'un classeur Excel
, tcXLWSName; && [nom du classeur] {fr} Nom de la feuille si on veut la renommer
, tcTypes && [ignoré] {fr} Types des colonnes
external array tcTypes

local llResult as Boolean; && {fr} La feuille a été traitée
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

* {fr} Si la feuille excel peut être ouverte
loXLWS = oXLWS(@m.tuXLWS, @llOpened)
llResult = vartype(m.loXLWS)=='O' and not isnull(m.loXLWS)
if m.llResult

	with m.loXLWS as Excel.WorkSheet

		* {fr} Nommer la feuille élégament
		lcXLWSName = iif(vartype(m.tcXLWSName) == 'C' and not empty(m.tcXLWSName), m.tcXLWSName, .name)
		lcXLWSName = chrtran(m.lcXLWSName, ["'/\:|_], space(1))
		lcXLWSName = cRepCharDel(m.lcXLWSName)
		lcXLWSName = alltrim(m.lcXLWSName)
		if not empty(m.lcXLWSName)
			.name = iif(len(m.lcXLWSName) < 5, upper(m.lcXLWSName), cTronc(proper(m.lcXLWSName), 31)) && 31 est la limite Excel 97
		endif

		* {fr} Si lignes et colonnes
		lnRow = .UsedRange.rows.count
		lnCol = .UsedRange.columns.count
		if m.lnRow > 1 and m.lnCol > 0

			* {fr} Empty 0-cells
			.UsedRange.replace(0, space(0), 1)

			llTypes = .f.;
				or type('tcTypes', 1) == 'A' and !laEmpty(@m.tcTypes) and acopy(m.tcTypes, m.laTypes) > 0;
				or vartype(m.tcTypes) == 'C' and alines(m.laTypes, upper(m.tcTypes), 5, ',', ';') > 0 and !laEmpty(@m.laTypes)

			* {fr} Pour chaque colonne
			.AutoFilterMode = .f.
			for m.liCol = 1 to m.lnCol

				* {fr} Régler la cellule de la première ligne
				with .Cells(1, m.liCol) as Excel.range
					if m.liCol = 1 and m.lnRow > 60
						.AutoFilter
					endif
					luValue = .value
					if vartype(m.luValue) == 'C' and not isnull(m.luValue)
						.font.name = 'Calibri'
						.font.Bold = .t.
						.value = upper(cRepCharDel(chrtran(m.luValue, '_', ' ')))
						.Interior.color = rgb(0,255,64) && {fr} Green
					endif
				endwith

				with .columns(m.liCol) as Excel.range

					* {fr} Si colonne date ou datetime, ajuster le format
					if m.llTypes and upper(m.laTypes[m.liCol]) $ 'DT'
						.NumberFormat = cDTformat_AW_XL(upper(m.laTypes[m.liCol]) == 'T') && modify command abDate
					endif

					* {fr} Ajuster la largeur de colonne en automatique
					if not .WrapText
						.autofit
						.columnwidth = min(.columnwidth, 30) && {fr} maximum 30
					endif
				endwith
			endfor
		endif

		* {fr} Set up page for printing
		lnMargin = .parent.parent.CentimetersToPoints(1) && 1 cm
		with .PageSetup
			.RightMargin = m.lnMargin
			.HeaderMargin = m.lnMargin
			.FooterMargin = m.lnMargin

			lnMargin = m.lnMargin * 1.7
			.LeftMargin = m.lnMargin
			.TopMargin = m.lnMargin
			.BottomMargin = m.lnMargin

			.PrintTitleRows = '$1:$1' && {fr} Repeat 1st row on each page

&& {fr} cf. "Formatting codes for headers and footers" in XL8.h
			.LeftHeader = '&10&F' && {fr} name of the document
			.CenterHeader = '&12&A' && {fr} nom de la feuille en xx points
			.RightHeader = 'Printed on &J' && {fr} date

			.LeftFooter = 'Generated by Abaque on ' + transform(date())
			.CenterFooter = 'Page &P/&N' && &N = nombre total de pages et non le nom du classeur comme documenté
			.RightFooter = '&W' && {fr} nom du classeur ??

			.PrintGridLines = .t.
		endwith
	endwith

	* {fr} Traiter le classeur
	with m.loXLWS.parent as Excel.Workbook && {fr} parent = WB

		* {fr} Changer la police normale
		with .Styles('Normal').font
			.name = 'Calibri'
			.size = 10
		endwith

		* {fr} Ajuster la présentation à l'écran
		with .windows(1) as Excel.window

			* {fr} Freeze panes on first row
			.SplitRow = 1
			.FreezePanes = .t.

			* {fr} Dimensionner la fenêtre à un minimum
			local lnWindowState
			lnWindowState = .windowstate
			.windowstate = xlNormal
			.width = max(.width , .7 * 72 * 20) && {fr} pouces logiques > points > twips
			.height = max(.height,  .4 * 72 * 20)
			.windowstate = m.lnWindowState
		endwith

		* {fr} Sauvegarder en version courante
		.saveas(iif(vartype(m.tuXLWS) == 'C', m.tuXLWS, .fullname), xlWorkbookNormal)

		* {fr} Refermer s'il était fermé à l'entrée
		if m.llOpened
			.close
		endif
	endwith
endif

return m.llResult

* -----------------------------------------------------------------
procedure XLWStableBeautify_Test && {fr} teste XLWStableBeautify(), nouvelle version

local loTest as sesXLWSTableBeautify_Test
loTest = createobject('sesXLWSTableBeautify_Test')

local lcTableTest, lcXLWBTest
lcTableTest = "XLWStableBeautify_Test"
lcXLWBTest = loTest.DataOpen(m.lcTableTest)

loTest.DataShow()
loTest.CoverageSet(.t.)
loTest.Test(.t., m.lcXLWBTest)

return loTest.Result()

* ------------------------------
define class sesXLWSTableBeautify_Test as abUnitTest of abDev.prg

procedure DataOpen
	lparameters tcTable
	local lcResult

	* {fr} Créer une table de test dans le dossier temporaire
	local lcAddr
	lcAddr = addbs(sys(2023)) + forceext(m.tcTable, EXT_DBF)
	create table (m.lcAddr) free ;
				(PK I, cX1 C(20) null, nX2 n(5))
	insert into (m.tcTable) values (1, 'Premier', 100)
	insert into (m.tcTable) values (2, 'Second', 200)
	insert into (m.tcTable) values (3, 'Troisième', 300)
	insert into (m.tcTable) values (4, null, 400)

	* {fr} Copier dans un classeur Excel
	lcResult = forceext(m.lcAddr, EXT_XLS)
	copy to (m.lcResult) type xl5

	return m.lcResult

procedure DataShow

	if set("Asserts") == 'ON'
		local lcWindow
		lcWindow = wontop()
		browse title alias()
		activate window (m.lcWindow)
	endif

enddefine && {fr} CLASS sesXLWSTableBeautify_Test

* ---------------------
procedure XLWSMultiLineCellExpand && {fr} Augmente la hauteur des cellules contenant plusieurs lignes
lparameters ;
  tuXLWS; && {fr} Référence à une feuille ou adresse d'un classeur Excel
, tuCol; && {fr} n° ou nom de la colonne
, tnColor && [sans changement] {fr} Couleur à appliquer aux cellules contenant plusieurs lignes
local llResult

* {fr} Si on peut accéder à la feuille Excel
local loXLWS as Excel.WorkSheet, llOpened
loXLWS = oXLWS(@m.tuXLWS, @llOpened)
llResult = vartype(m.loXLWS) == 'O'
assert m.llResult message program() + ": impossible d'accéder à la feuille Excel sépcifiée " + cLitteral(m.tuXLWS)
if m.llResult

	with m.loXLWS as Excel.WorkSheet

		* {fr} Compter les lignes et les colonnes de la feuille
		local lnRows, lnCols
		lnRows = .UsedRange.rows.count
		lnCols = .UsedRange.columns.count

		* {fr} Si au moins une ligne
		llResult = m.lnRows > 1
		if m.llResult

			* {fr} Si la colonne spécifiée existe
			local lnCol
			lnCol = nXLWSCol(m.loXLWS, m.tuCol)
			llResult = m.lnCol > 0
			assert m.llResult message program() + " - spécification de colonne invalide" + cLitteral(m.tuCol)
			if m.llResult

				* {fr} Voir s'il faut appliquer une couleur aux cellules concernées
				local llColor
				llColor = vartype(m.tnColor) == 'N' and m.tnColor > 0 and m.tnColor < rgb(255,255,255)

				* {fr} Pour chaque ligne de données
				local lnRow, luValue, llAlign
				for m.lnRow = 2 to m.lnRows && {fr} la première ligne doit contenir les noms des champs

					* {fr} Si la cellule contient un saut de ligne, traiter
					with .Cells(m.lnRow, m.lnCol)
						luValue = .value
						if vartype(m.luValue) == 'C' ;
						 and LF $ m.luValue
							.value = m.luValue && {fr} Simulates 'F2 + enter'
							.WrapText = .t. && {fr} Retour à la ligne automatique
							.EntireRow.autofit && {fr} Hauteur de ligne automatique
							if m.llColor
								.Interior.color = m.tnColor
							endif
							llAlign = .t.
						endif
					endwith
				endfor
			endif

			* {fr} Si au moins une cellule détectée, aligner tout en haut
			if m.llAlign
				.UsedRange.VerticalAlignment = xlVAlignTop
			endif

			* {fr} Sauvegarder le classeur
			.parent.saveas(.parent.fullname, xlWorkbookNormal)
		endif
	endwith
endif

* {fr} Si le classeur a été ouvert, refermer
if m.llOpened
	loXLWS.parent.close()
endif

return m.llResult

* --------------------------------------------------
procedure XLWStableBlankLinesDel && {fr} Supprime les lignes vides d'un tableau Excel
lparameters ;
  tuXLWS; && {fr} Référence à une feuille ou adresse d'un classeur Excel
, tcXLWSName && [nom du classeur] {fr} Nom de la feuille si on veut la renommer
local llResult && {fr} La feuille a été traitée

* {fr} Si la feuille excel peut être ouverte
local llOpened, loXLWS as Excel.WorkSheet
loXLWS = oXLWS(@m.tuXLWS, @llOpened)
llResult = vartype(m.loXLWS)=='O' and not isnull(m.loXLWS)
if m.llResult

	with m.loXLWS as Excel.WorkSheet

		* {fr} S'il y a des lignes et des colonnes
		local lnRows, lnCols
		lnRows = .UsedRange.rows.count
		lnCols = .UsedRange.columns.count
		llResult = m.lnRows > 1 and m.lnCols > 0
		if m.llResult

			* {fr} Pour chaque Ligne
			local lnRow, lnCol, llRowEmpty, luValue
			for m.lnRow = m.lnRows to 2 step -1

				* {fr} Si chaque cellule est vide
				llRowEmpty = .f.
				for m.lnCol = 1 to m.lnCols
					luValue = .Cells(m.lnRow, m.lnCol).value
					llRowEmpty = empty(m.luValue) or isnull(m.luValue)
					if not m.llRowEmpty
						exit
					endif
				endfor

				* {fr} Si la ligne est vide, supprimer
				if m.llRowEmpty
					.Cells(m.lnRow,1).EntireRow.delete()
				endif
			endfor

			* {fr} Sauvegarder le classeur en version courante
			.parent.saveas(iif(vartype(m.tuXLWS) == 'C', m.tuXLWS, .fullname), xlWorkbookNormal)
		endif

		* {fr} Refermer le classeur s'il était fermé à l'entrée
		if m.llOpened
			.parent.close
		endif
	endwith
endif

return m.llResult

* ---------------------
procedure XLWSColFormatNumber && {fr} Applique un format de présentation à une colonne d'une feuille Excel
lparameters ;
  tuXLWS; && {fr} Référence à une feuille ou adresse d'un classeur Excel
, tuCol; && {fr} n° ou nom de la colonne
, tcNumberFormat && [sans changement] {fr} Code format Excel à appliquer

local loXLWSCol as Excel.range, llOpened, llResult

* {fr} Si on peut accéder à la colonne de la feuille Excel
loXLWSCol = oXLWSCol(m.tuXLWS, m.tuCol, @llOpened)
llResult = not isnull(m.loXLWSCol)
if m.llResult

	local loWB as Excel.Workbook, lcFormat
	loWB = m.loXLWSCol.parent.parent

	* {fr} Si un format est spécifié
	lcFormat = uDefault(m.tcNumberFormat, space(0))
	llResult = not empty(m.lcFormat)
	assert m.llResult message program() + " - Spécification de format invalide " + cLitteral(m.tcNumberFormat)
	if m.llResult

		* {fr} Appliquer le format à la colonne
		loXLWSCol.NumberFormat = m.lcFormat

		* {fr} Sauvegarder le classeur en version courante
		loWB.saveas(iif(vartype(m.tuXLWS) == 'C', m.tuXLWS, .fullname), xlWorkbookNormal)
	endif

	* {fr} Refermer le classeur si on l'a ouvert à l'entrée
	if m.llOpened
		loWB.close
	endif
endif

return m.llResult

* ---------------------
procedure XLWSColFormatHAlign && {fr} Applique un format d'alignement horizontal à une colonne d'une feuille Excel
lparameters ;
  tuXLWS; && {fr} Référence à une feuille ou adresse d'un classeur Excel
, tuCol; && {fr} n° ou nom de la colonne
, tnHAlign && [xlHAlignGeneral] {fr} format d'alignement horizontal à appliquer (selon constantes Excel)

local loXLWSCol as Excel.range, llOpened, llResult

* {fr} Si on peut accéder à la colonne de la feuille Excel
loXLWSCol = oXLWSCol(m.tuXLWS, m.tuCol, @llOpened)
llResult = not isnull(m.loXLWSCol)
if m.llResult

	local loWB as Excel.Workbook
	loWB = m.loXLWSCol.parent.parent

	* {fr} Si un format est spécifié
	local lnHAlign
	lnHAlign = uDefault(m.tnHAlign, xlHAlignGeneral)
	llResult = inlist(m.lnHAlign, xlHAlignCenter,xlHAlignCenterAcrossSelection,xlHAlignDistributed,xlHAlignFill,xlHAlignGeneral,xlHAlignJustify,xlHAlignLeft,xlHAlignRight)
	assert m.llResult message program() + " - Spécification de format invalide : " + cLitteral(m.tnHAlign)
	if m.llResult

		* {fr} Appliquer le format à la colonne
		loXLWSCol.HorizontalAlignment = m.lnHAlign

		* {fr} Sauvegarder le classeur en version courante
		loWB.saveas(iif(vartype(m.tuXLWS) == 'C', m.tuXLWS, .fullname), xlWorkbookNormal)
	endif

	* {fr} Refermer le classeur si on l'a ouvert à l'entrée
	if m.llOpened
		loWB.close
	endif
endif

return m.llResult

* ---------------------
procedure oXLWSCol && {fr} Colonne d'une feuille Excel
lparameters ;
  tuXLWS; && {fr} Référence à une feuille ou adresse d'un classeur Excel
, tuCol; && {fr} n° ou nom de la colonne
, tlOpened && @ {fr} Le classeur excel a été ouvert

local llResult, loResult as Excel.range && {fr} Référence à l'objet colonne
loResult = .null.

* {fr} Si on peut accéder à la feuille Excel
local loXLWS as Excel.WorkSheet
loXLWS = oXLWS(@m.tuXLWS, @tlOpened)
llResult = vartype(m.loXLWS) == 'O'
assert m.llResult message program() + ": impossible d'accéder à la feuille Excel " + cLitteral(m.tuXLWS)
if m.llResult
	with m.loXLWS as Excel.WorkSheet

		* {fr} Si au moins une ligne dans la feuille
		local lnRows
		lnRows = .UsedRange.rows.count
		llResult = m.lnRows > 1
		assert m.llResult message program() + " - Moins d'une ligne dans la feuille " + cLitteral(m.tuXLWS)
		if m.llResult

			* {fr} Si la colonne spécifiée existe
			local lnCol
			lnCol = nXLWSCol(m.loXLWS, m.tuCol)
			llResult = m.lnCol > 0
			assert m.llResult message program() + " - spécification de colonne invalide : " + cLitteral(m.tuCol)
			if m.llResult

				loResult = m.loXLWS.Cells(1, m.lnCol).EntireColumn
			endif
		endif
	endwith
endif

return m.loResult

* ---------------------
procedure XLWSRowsInteriorColor && {fr} Applique une couleur de fond à des rangées d'une feuille Excel selon un critère de filtre sur une colonne
lparameters ;
  tuXLWS; && {fr} Référence à une feuille ou adresse d'un classeur Excel
, tuCol; && {fr} n° ou nom de la colonne
, tcCrit; && {fr} Critère à appliquer : UDF de type logique à UN SEUL PARAMÃˆTRE ou opérateur relationnel (=<>$!)
, tlOpLeft; && [.F.] {fr} l'opération relationnelle est appliquée à gauche de la valeur
, tnColor && [-1] {fr} Couleur rgb(),  -1 pour xlColorIndexNone, -2 pour xlColorIndexAutomatic
local llResult

* {fr} Si on peut sélectionner les rangées de la feuille Excel
local loXLWSRows as Excel.range, llOpened
loXLWSRows = oXLWSRowsFilter(m.tuXLWS, m.tuCol, m.tcCrit, m.tlOpLeft, @llOpened)
llResult = not isnull(m.loXLWSRows)
if m.llResult
		local loWB as Excel.Workbook
		loWB = m.loXLWSRows.parent.parent

		* {fr} Donner sa valeur par défaut à la couleur spécifiée
		local lnColor
		lnColor = uDefault(m.tnColor, -1)
		lnColor = iif(m.lnColor < -2 or m.lnColor > rgb(255,255,255), -1, m.lnColor)

		* {fr} Appliquer la couleur demandée
		with m.loXLWSRows.Interior
			if m.lnColor < 0
				.ColorIndex = iif(m.lnColor = -1, xlColorIndexNone, xlColorIndexAutomatic)
			else
				.color = m.lnColor
			endif
		endwith

		* {fr} Sauvegarder le classeur en version courante
		loWB.saveas(iif(vartype(m.tuXLWS) == 'C', m.tuXLWS, .fullname), xlWorkbookNormal)

		* {fr} Refermer le classeur si on l'a ouvert à l'entrée
		if m.llOpened
			loWB.close()
		endif
endif

return m.llResult

* ---------------------
function oXLWSRowsFilter && {fr} Rangées d'une feuille Excel selon un critère de filtre sur une colonne
lparameters ;
  tuXLWS; && {fr} Référence à une feuille ou adresse d'un classeur Excel
, tuCol; && {fr} n° ou nom de la colonne oû se trouve le critère
, tcCrit; && [aucun, toutes les lignes sont renvoyées] {fr} Critère de filtre des lignes : UDF de type logique à UN SEUL PARAMÃˆTRE ou opération relationnelle (=<>$!)
, tlOpLeft; && [.F.] {fr} l'opération relationnelle est appliquée à gauche de la valeur
, tlOpened && @ {fr} Le classeur excel a été ouvert
local loResult as Excel.range && {fr} Référence à l'objet Range contenant les lignes
loResult = .null.

local llResult

* {fr} Si on peut accéder à la feuille Excel
local loXLWS as Excel.WorkSheet
loXLWS = oXLWS(@m.tuXLWS, @tlOpened)
llResult = vartype(m.loXLWS) == 'O'
assert m.llResult message program() + ": impossible d'accéder à la feuille Excel " + cLitteral(m.tuXLWS)
if m.llResult
	with m.loXLWS as Excel.WorkSheet

		* {fr} Si au moins une ligne dans la feuille
		local lnRows
		lnRows = .UsedRange.rows.count
		llResult = m.lnRows > 1
		assert m.llResult message program() + " - moins de deux lignes dans la feuille " + cLitteral(m.tuXLWS)
		if m.llResult

			* {fr} Si la colonne spécifiée existe
			local lnCol
			lnCol = nXLWSCol(m.loXLWS, m.tuCol)
			llResult = m.lnCol > 0
			assert m.llResult message program() + " - spécification de colonne invalide : " + cLitteral(m.tuCol)
			if m.llResult

				* {fr} Si le critère est précisé
				local lcCrit
				lcCrit = alltrim(uDefault(m.tcCrit, space(0)))
				llResult = not empty(m.lcCrit)
				if m.llResult

					local llOpLeft
					llOpLeft = uDefault(m.tlOpLeft, .f.)

					* {fr} Si le critère est valide
					local luVal, lcType, lcTest, llOp, loErr
					luVal = .Cells(2, m.lnCol).value
					lcType = vartype(m.luVal)
					lcTest = cLitteral(m.luVal)
					#define VFPLOGOP '=<>$!'
					llOp = iif(m.llOpLeft, right(m.lcCrit, 1) $ VFPLOGOP, left(m.lcCrit, 1) $ VFPLOGOP)
					try
						local lcEval
						lcEval = cCritEval(m.lcCrit, m.lcTest, m.llOp, m.llOpLeft)
						luResult = evaluate(m.lcEval)
						llResult = vartype(m.luResult) == 'L'
					catch to m.loErr
					endtry
					assert m.llResult message program() + " - critère de filtrage incorrect : " + cLitteral(m.tcCrit)
					if m.llResult

						* {fr} Pour chaque ligne à partir de la seconde (la première contient les noms des champs)
						local lnRow, luVal, loXL as Excel.application
						loXL = .parent.parent
						for m.lnRow = 2 to m.lnRows
							with .Cells(m.lnRow, m.lnCol) as Excel.range
								luVal = .value

								* {fr} Si la valeur est du type attendu
								if vartype(m.luVal) == m.lcType

									* {fr} Si le critère est respecté
									lcTest = cLitteral(m.luVal)
									if evaluate(cCritEval(m.lcCrit, m.lcTest, m.llOp, m.llOpLeft))

										* {fr} Ajouter la ligne au Range
										loResult = iif(isnull(m.loResult), .EntireRow, m.loXL.union(m.loResult, .EntireRow))
									endif
								endif
							endwith
						endfor
					endif
				else
					loResult = .Cells
				endif
			endif
		endif
	endwith
endif

return m.loResult

* ---------------------
function cCritEval && {fr} Critère de filtre à évaluer
lparameters ;
  tcCrit; && {fr} Critère de filtre
, tcVal; && {fr} Valeur sous forme de constante caractère
, tlOp; && {fr} Le critère est une opération relationnelle (UDF si .F.)
, tlOpLeft && {fr} l'opération relationnelle est appliquée à gauche de la valeur

return icase(;
	!m.tlOp,;
		m.tcCrit + '(' + m.tcVal + ')',;
	m.tlOpLeft,;
		m.tcCrit + m.tcVal,;
		m.tcVal + m.tcCrit;
	)
* ---------------------
function nXLWSCol && {fr} N° d'une colonne d'après son nom inscrit dans la première ligne
lparameters ;
  toXLWS as Excel.WorkSheet,; && {fr} Référence présumée à une feuille Excel
	tuCol && {fr} Nom ou n° de de la colonne
local lnResult
lnResult = 0

local lcType
lcType = vartype(m.tuCol)
if loXLWS(m.toXLWS) ;
 and m.lcType $ 'CN' ;
 and not empty(m.tuCol)

	* {fr} Compter les lignes et les colonnes de la feuille
	local lnRows, lnCols
	lnRows = m.toXLWS.UsedRange.rows.count
	lnCols = m.toXLWS.UsedRange.columns.count

	* {fr} Si au moins une ligne et une colonne
	if m.lnRows > 0 and m.lnCols > 0

		* {fr} Si un n° de colonne a été spécifié et qu'il est dans la plage de colonnes, OK
		if m.lcType == 'N'
			if m.tuCol <= m.lnCols
				lnResult = m.tuCol
			endif

		* {fr} Sinon (nom de colonne spécifié)
		else

			* {fr} Pour chaque cellule de la première ligne
			local lcCol, lnCol, luValue
			lcCol = upper(alltrim(m.tuCol))
			for m.lnCol = 1 to m.lnCols

				* {fr} Si la valeur contient le nom de colonne cherché, trouvé !
				luValue = m.toXLWS.Cells(1, m.lnCol).value
				if vartype(m.luValue) == 'C' ;
				 and upper(alltrim(m.luValue)) == m.lcCol
				 	lnResult = m.lnCol
					exit
				endif
			endfor
		endif
	endif
endif

return m.lnResult

* -------------------------------------------------------------
function oXL && {fr} Référence à un objet Excel.Application

local lcWindow, loResult as Excel.application
loResult = .null.

* {fr} Si Excel est déjà instancié dans la variable standard (publique ou privée)
if vartype(m.poXL) == 'O' ; && {fr} standard Abaque pour éviter d'instancier excel plusieurs fois
and type('m.poXL.ActiveWorkbook') == 'O' && {fr} vrai même si aucun classeur n'est ouvert

	loResult = m.poXL

* {fr} Sinon (aucune référence disponible)
else

	lcWindow = woutput()
	try
		loResult = getobject(space(0), 'Excel.Application') && {fr} le premier paramètre est requis
		loResult = iif(vartype(m.loResult) == 'O', m.loResult, createobject('Excel.Application'))
	catch
	endtry
	if vartype(m.loResult) == 'O'
		loResult.DisplayAlerts = .f.

		* {fr} Rétablir la fenêtre active avant l'instanciation
		if empty(m.lcWindow) or not wvisible(m.lcWindow)
			activate screen
		else
			activate window (m.lcWindow)
		endif
	endif
endif

return m.loResult

* -------------------------------------------------------------
function oXLWB && {fr} Référence à un objet Excel.WorkBook
lparameters ;
  tuXLWB; && {fr} Référence ou adresse d'un classeur Excel
, tlOpened; && @ {fr} le classeur a été ouvert
, tlCreated && @ {fr} le classeur a été créé
store .f. to tlOpened, tlCreated

local loResult as Excel.Workbook
loResult = .null.

do case

* {fr} Si une référence à un classeur Excel a été passée
case loXLWB(m.tuXLWB)

	* {fr} Renvoyer tout simplement
	loResult = m.tuXLWB

* {fr} Si l'adresse d'un classeur Excel a été passée
case vartype(m.tuXLWB)=='C' ;
 and upper(justext(m.tuXLWB)) == EXT_XLS

	* {fr} Démarrer Excel
	local loXL as Excel.application
	loXL = oXL()

	* {fr} Si le classeur existe
	if lFile(m.tuXLWB)

		* {fr} Ouvrir le classeur
		loResult = m.loXL.Workbooks.open(fullpath(m.tuXLWB), 0) && 0: Ne met à jour aucune référence
		tlOpened = .t.

	* {fr} Sinon (le classeur n'existe pas)
	else

		* {fr} Si l'adresse du classeur est valide
		local llResult
		llResult = lDir(justpath(m.tuXLWB), .T.)
		assert m.llResult message program() + " - Invalid Excel Workbook specification : " + cLitteral(m.tuXLWB)
		if m.llResult

			loResult = m.loXL.Workbooks.add()
			tlCreated = .t.
		endif
	endif
endcase

return m.loResult

* ---------------------
function oXLWS && {fr} Référence à un objet Excel.Worksheet
lparameters ;
  tuXLWS; && {fr} Référence à une Feuille Excel OU @ adresse d'un classeur [(|!,) Nom Feuille]
, tlOpened && @ {fr} le classeur a été ouvert
tlOpened = .f.

local loResult as Excel.WorkSheet;
, loXLWB as Excel.Workbook;
, liSep;
, lcXLWB;
, lcXLWS;

loResult = .null.

* {fr} Si une référence à une feuille Excel a été passée
do case
case loXLWS(m.tuXLWS)

	* {fr} Renvoyer tout simplement
	loResult = m.tuXLWS

case vartype(m.tuXLWS) == 'C'

	* {fr} Lire l'adresse du classeur [et le nom de la feuille]
	liSep = evl(evl(at_c('|', m.tuXLWS), at_c(',', m.tuXLWS)), at_c('!', m.tuXLWS))

	if m.liSep > 0
		lcXLWB = leftc(m.tuXLWS, m.liSep - 1)
		lcXLWS = substrc(m.tuXLWS, m.liSep + 1)
	else
		store cFileCased(m.tuXLWS, .t.) to lcXLWB, m.tuXLWS
		lcXLWS = ''
	endif

	* {fr} Si le classeur peut être ouvert
	loXLWB = oXLWB(m.lcXLWB)
	if vartype(m.loXLWB) == 'O'
		tlOpened = .t.

		* {fr} Renvoyer une référence à la feuille spécifiée, à défaut la première feuille du classeur
		loResult = iif(lXLWS(m.lcXLWS, m.loXLWB);
			, m.loXLWB.Sheets(m.lcXLWS);
			, m.loXLWB.ActiveSheet;
			)
	endif
endcase

return m.loResult

* ---------------------
function acXLWSs && {fr} Noms des feuilles de calcul contenues dans un classeur Excel
lparameters ;
  taXLWS; && @ {fr} Noms des feuilles de calcul contenues dans le classeur Excel
, tcXLWBAddr && {fr} Adresse du classeur Excel à explorer

external array taXLWS

local llXLWBAddr, lnResult && {fr} Nombre de feuilles de calcul contenues dans le classeur Excel
lnResult = 0

* {fr} Initialiser le tableau des feuilles
aClear(@m.taXLWS)

* {fr} Si le classeur XL indiqué peut être localisé
llXLWBAddr = file(m.tcXLWBAddr)
assert m.llXLWBAddr message "Impossible de trouver un classeur XL à l'adresse" + alltrim(m.tcXLWBAdd)
if m.llXLWBAddr

	* {fr} Ouvrir le classeur XL en automation
	local loXL as Excel.application,;
		loXLWB as Excel.Workbook
	loXL = oXL()
	loXLWB = loXL.Workbooks.open(fullpath(m.tcXLWBAddr), 0, .t.)

	* {fr} Lire les noms des feuilles de calcul contenues dans le classeur
	local loXLWS as Excel.WorkSheet
	for each m.loXLWS in m.loXLWB.Worksheets
		lnResult = m.lnResult + 1
		dimension m.taXLWS[m.lnResult]
		taXLWS[m.lnResult] = m.loXLWS.name
	endfor

	* {fr} Fermer le classeur et XL
	loXLWB.close()
	loXL = .null.
endif

return m.lnResult

* ---------------------
function loXL && {fr} C'est une référence à un objet application Excel
lparameters toXL && {fr} Référence présumée à un objet application Excel

return ;
	vartype(m.toXL) == 'O';
 and type('m.toXL.Name') == 'C';
 and 'excel' $ lower(m.toXL.name) ;
 and type('m.toXL.WorkBooks') == 'O'

* ---------------------
function loXLWB && {fr} C'est une référence à un objet classeur Excel
lparameters toXLWB && {fr} Référence présumée à une classeur Excel

return ;
	vartype(m.toXLWB) == 'O';
 and type('m.toXLWB.Application') == 'O';
 and loXL(m.toXLWB.application) ;
 and type('m.toXLWB.WorkSheets') == 'O'

* ---------------------
function loXLWS && {fr} C'est une référence à un objet feuille de calcul Excel
lparameters toXLWS && {fr} Référence présumée à une feuille Excel

return ;
	vartype(m.toXLWS) == 'O';
 and type('m.toXLWS.parent') == 'O';
 and loXLWB(m.toXLWS.parent)

* ---------------------
procedure loXLWS_Test && {fr} Teste loXLWS(), nouvelle version

local loTest as abUnitTest of abDev.prg
loTest = newobject('abUnitTest', 'abDev.prg')

local loXL as Excel.application, loXLWB as Excel.Workbook
loXL = oXL()
loXLWB = m.loXL.Workbooks.add()

loTest.Test(.t., m.loXLWB.ActiveSheet)

loXLWB.close()
loXL.quit()

return loTest.Result()

* ---------------------
function lXLWS && {fr} La feuille XL existe dans le classeur spécifié
lparameters ;
  tcSheet; && {fr} Nom de la feuille cherchée
, tuXLWB && {fr} Référence ou adresse d'un classeur Excel
local llResult

* {fr} Si une feuille valide a été indiquée
llResult = vartype(m.tcSheet) == 'C' and not empty(m.tcSheet)
if m.llResult

	* {fr} Si le classeur spécifié peut être ouvert
	local loXLWB as Excel.Workbook
	loXLWB = oXLWB(m.tuXLWB)
	llResult = not isnull(m.loXLWB)
	if m.llResult

		* {fr} Pour chaque feuille contenue
		local lcSheet, loSheet as Excel.WorkSheet
		lcSheet = lower(alltrim(m.tcSheet))
		llResult = .f.
		for each m.loSheet in m.loXLWB.Worksheets

			* {fr} Si la feuille porte le nom spécifié, terminé
			llResult = lower(m.loSheet.name) == m.lcSheet
			if m.llResult
				exit
			endif
		endfor
	endif
endif

return m.llResult

* -------------------------------------------------------------
procedure XLWBfromWSs && {fr} Regroupe des feuilles Excel dans un classeur
lparameters ;
  taWBWSSrce; && @ {fr} Adresses des classeurs | noms des feuilles [Feuille # 1] à regrouper
, tcWBDestAddr; && {fr} Adresse du classeur Excel destination
, tlWBSrceDel; && [.F.] {fr} Supprimer les classeurs source après copie des feuilles dans le classeur destination
, tlBeautify && [.F.] {fr} Embellir les feuilles
external array taWBWSSrce
tlWBSrceDel = lTrue(m.tlWBSrceDel)
tlBeautify = lTrue(m.tlBeautify)

local llResult && {fr} Toutes les feuilles ont bien été copiées dans le classeur destination

* {fr} Si des classeurs source sont indiqués
if type('taWBWSSrce', 1) == 'A'

	local lnWBSrces
	lnWBSrces = alen(m.taWBWSSrce, 1)
	if m.lnWBSrces > 0 ;
	 and lFileAddress(m.tcWBDestAddr)

		* {fr} Vérifier si des feuilles ont aussi été indiquées
		local llWSSrce
		llWSSrce = alen(m.taWBWSSrce, 2) > 1

		* {fr} Créer un tableau de résultats
		local array laResult[m.lnWBSrces]

		* {fr} Lancer Excel en automation
		local loXL as Excel.application
		loXL = oXL()

		* {fr} Pour chaque classeur source,
		local ;
			lnWBSrce, lcWBSrce, loWBSrce as Excel.Workbook,;
			lcWSSrce, loWSSrce as Excel.WorkSheet,;
			llWBDest
		for m.lnWBSrce = 1 to m.lnWBSrces

			* {fr} Si le classeur source existe
			lcWBSrce = iif(m.llWSSrce, m.taWBWSSrce[m.lnWBSrce, 1], m.taWBWSSrce[m.lnWBSrce])
			if vartype(m.lcWBSrce) == 'C' and file(m.lcWBSrce)

				* {fr} Ouvrir le classeur source
				loWBSrce = m.loXL.Workbooks.open(fullpath(m.lcWBSrce))

				* {fr} Si une feuille source a été indiquée
				lcWSSrce = iif(m.llWSSrce, m.taWBWSSrce[m.lnWBSrce, 2], space(0))
				laResult[m.lnWBSrce] = .t.
				if vartype(m.lcWSSrce) == 'C' ;
				 and not empty(m.lcWSSrce)

					* {fr} Si la feuille existe dans le classeur
					if lXLWS(m.lcWSSrce, m.loWBSrce)

						* {fr} Ouvrir la feuille source indiquée,
						loWSSrce = m.loWBSrce.Worksheets(m.lcWSSrce)

					* {fr} Sinon, erreur
					else
						laResult[m.lnWBSrce] = .f.
					endif

				* {fr} Sinon, (aucune feuille source indiquée), ouvrir la première feuille
				else
					loWSSrce = m.loWBSrce.Worksheets(1)
					lcWSSrce = m.loWSSrce.name
				endif

				* {fr} Si la feuille a été ouverte,
				if laResult[m.lnWBSrce]

					* {fr} Si le classeur destination n'est pas créé, le créer
					if not m.llWBDest
						local ;
							loWBDest as Excel.Workbook,;
							lnWBDestDefaultSheets;
, 						loWSDest as Excel.WorkSheet
						loWBDest = m.loXL.Workbooks.add() && {fr} new WB
						lnWBDestDefaultSheets = m.loWBDest.Sheets.count && default sheets
						loWSDest = m.loWBDest.Sheets(m.lnWBDestDefaultSheets) && {fr} Last sheet
						llWBDest = .t.
					endif

					if m.tlBeautify
						XLWStableBeautify(m.loWSSrce)
					endif

					* {fr} Copier la feuille dans le classeur destination après les feuilles existantes
					loWSSrce.copy(null, m.loWSDest)
					loWSDest = m.loWBDest.Sheets(m.loWBDest.Sheets.count) && {fr} last sheet

					* {fr} Supprimer les styles automatiques nommés selon la nouvelle feuille
					lcWBSrce = upper(juststem(m.lcWBSrce))
					lcWSSrce = upper(alltrim(m.lcWSSrce))
					local lcStyle, loStyle as Excel.style
					for each m.loStyle in m.loWBDest.Styles
						lcStyle = upper(alltrim(m.loStyle.name))
						if right(m.lcStyle, 1 + len(m.lcWBSrce)) == '_' + m.lcWBSrce ;
						 or right(m.lcStyle, 1 + len(m.lcWSSrce)) == '_' + m.lcWSSrce
							loStyle.delete()
						endif
					endfor

					* {fr} Fermer le classeur source
					loWSSrce = .null.
					loWBSrce.close

					* {fr} Si la suppression des classeurs sources a été demandée, supprimer
					if m.tlWBSrceDel
						delete file (m.lcWBSrce)
					endif
				endif
			endif
		endfor

		* {fr} Si le classeur destination a bien été créé
		if m.llWBDest
			with m.loWBDest

				* {fr} Supprimer les feuilles initiales vides
				if m.lnWBDestDefaultSheets > 0
					local lnSheet
					for m.lnSheet = m.lnWBDestDefaultSheets to 1 step -1
						.Sheets(m.lnSheet).delete()
					endfor
				endif

				* {fr} Sélectionner la première feuille et dimensionner la fenêtre
				.Sheets(1).select()
				.windows(1).width = 900
				.windows(1).height = 700

				* {fr} Enregistrer et fermer le nouveau classeur
				.saveas(m.tcWBDestAddr, xlWorkbookNormal)
				.close
			endwith

			* {fr} Calculer le résultat
			llResult = ascan(m.laResult, .f.) = 0
		endif
	endif
endif

return m.llResult

* -------------------------------------------------------------
procedure XLWBfromWSs_Test && {fr} teste XLWBfromWSs, ancienne version

?
? sys(16)

private poXL as Excel.application
poXL = oXL()

local lcDos, lcAdr
lcDos = "C:\aDossier\3639 VS Emb PL\Client\Envoi\"
lcAdr = m.lcDos + "XLWBfromWSs_Test.xls"
delete file (m.lcAdr)

local array laWBs[2, 2]
laWBs[1,1] = m.lcDos + "KEM_Warn.xls"
laWBs[1,2] = "KEM_Warn"
laWBs[2,1] = m.lcDos + "EEM_Warn.xls"
laWBs[2,2] = "EEM_Warn"

? XLWBfromWSs(@laWBs, m.lcAdr)

poXL.quit()

* -------------------------------------------------------------
procedure XLWBfromWSs_Test && {fr} teste XLWBfromWSs, nouvelle version

local loTest as abUnitTest of abDev.prg
loTest = newobject('abUnitTest', 'abDev.prg')

local lcDos
lcDos = "C:\aDossier\3639 VS Emb PL\Client\Envoi\"
if directory(m.lcDos)

	local array laWBs[2, 2]
	laWBs[1,1] = m.lcDos + "KEM_Warn.xls"
	laWBs[1,2] = "KEM_Warn"
	laWBs[2,1] = m.lcDos + "EEM_Warn.xls"
	laWBs[2,2] = "EEM_Warn"
	if file(m.laWBs[1,1]) and file(m.laWBs[2,1])

		local lcAdr
		lcAdr = m.lcDos + "XLWBfromWSs_Test.xls"
		delete file (m.lcAdr)

		private poXL as Excel.application
		poXL = oXL()

		loTest.Test( .t., @laWBs, m.lcAdr)

		poXL.quit()
	endif
endif

return loTest.Result()
*========================================
procedure XLWSofTableMemo && {fr} feuille Excel d'après une table FoxPro avec les champs MEMO (impossible avec COPY TO)
lparameters ;
  tuTable; && [Alias()] {fr} Alias, zone ou adresse de la table source
, tcXLWBAddr && [forceExt(tuTable, 'XLS'] {fr} Adresse du classeur XL cible
local llResult
llResult = .t.

* {fr} Si la table existe
local lcAlias, llDBFOpened
lcAlias = cAlias(m.tuTable, @llDBFOpened)
llResult = used(m.lcAlias)
assert m.llResult message program() + " - Invalid table specification : " + cLitteral(m.tuTable)
if m.llResult

	* {fr} Si le classeur peut être ouvert ou créé
	local lcTableAddr, lcXLWBAddr, loXLWB as Excel.Workbook, llXLSOpened, llCreated
	lcTableAddr = cTableAddress(m.lcAlias)
	lcXLWBAddr = uDefault(m.tcXLWBAddr, forceext(m.lcTableAddr, EXT_XLS))
	loXLWB = oXLWB(m.lcXLWBAddr, @llXLSOpened, @llCreated)
	llResult = loXLWB(m.loXLWB)
	if m.llResult
		with m.loXLWB as Excel.Workbook

			* {fr} Si la feuille existe,
			local lcXLWS, loXLWS as Excel.WorkSheet
			lcXLWS = juststem(m.lcTableAddr)
			if lXLWS(m.lcXLWS, m.loXLWB)

				* {fr} Sélectionner
				loXLWS = .Worksheets(m.lcXLWS)

				* {fr} Razer les données et les styles
				with m.loXLWS.UsedRange as Excel.range
					.value = .null.
					.style = m.loXLWB.Styles.item('normal')
				endwith

			* {fr} Sinon, ajouter une feuille au classeur
			else
				loXLWS = .Worksheets.add()
				loXLWS.name = m.lcXLWS
			endif

			with m.loXLWS as Excel.WorkSheet

				* {fr} Copier les noms des champs dans la première ligne
				local lnRow, lnCol, lnCols
				lnRow = 1
				lnCols = fcount(m.lcAlias)
				for m.lnCol = 1 to m.lnCols
					.Cells(m.lnRow, m.lnCol).value = field(m.lnCol, m.lcAlias)
				endfor

				* {fr} Copier les données de la table dans les lignes suivantes
				local lnSelect, luValue
				lnSelect = select(0)
				select (m.lcAlias)
				scan
					lnRow = m.lnRow + 1
					for m.lnCol = 1 to m.lnCols
						luValue = evaluate(field(m.lnCol, m.lcAlias))
						luValue = iif(vartype(m.luValue) == 'C', rtrim(m.luValue), m.luValue)
						.Cells(m.lnRow, m.lnCol).value = m.luValue
					endfor
				endscan
				select (m.lnSelect)
			endwith

			* {fr} Sauver le classeur et fermer Excel
			if m.llCreated
				.saveas(m.lcXLWBAddr, xlWorkbookNormal)
			else
				.save()
			endif
			if m.llXLSOpened
				.parent.quit()
			endif
		endwith
	endif
	if m.llDBFOpened
		use in (m.lcAlias)
	endif
endif

return m.llResult

*========================================
procedure TableMemoOfXLWS && {fr} Table FoxPro avec les champs MEMO d'après une feuille Excel (impossible avec Import ou append from)
lparameters ;
  tuTable; && [Alias()] {fr} Alias, zone ou adresse de la table destination
, tcXLWBAddr; && [forceExt(tuTable, 'XLS'] {fr} Adresse du classeur XL source
, tcXLWS; && [première] {fr} Feuille contenant les données à importer
, tlFieldsCheck && [.F.] {fr} Vérifier que les champs de la feuille sont tous dans la table
local llResult
llResult = .t.

* {fr} Si la table existe
local lcAlias, llOpened
lcAlias = cAlias(m.tuTable, @llOpened)
llResult = used(m.lcAlias)
assert m.llResult message cAssertMsg(textmerge("<<Program()>> - Invalid table specification : <<cLitteral(m.tuTable)>>"))
if m.llResult

	* {fr} Si le classeur existe et peut être ouvert en automation
	local lcTableAddr, lcXLWBAddr, loXLWB as Excel.Workbook, llOpened, llCreated
	lcTableAddr = cTableAddress(m.lcAlias)
	lcXLWBAddr = uDefault(m.tcXLWBAddr, forceext(m.lcTableAddr, EXT_XLS))
	loXLWB = oXLWB(m.lcXLWBAddr, @llOpened, @llCreated)
	llResult = loXLWB(m.loXLWB) and not m.llCreated
	if m.llResult
		with m.loXLWB as Excel.Workbook

			* {fr} Sélectionner la feuille indiquée, la première par défaut
			local lcXLWS, loXLWS as Excel.WorkSheet
			lcXLWS = uDefault(m.tcXLWS, space(0))
			loXLWS = .Worksheets(iif(lXLWS(m.lcXLWS, m.loXLWB), m.lcXLWS, 1))
			with m.loXLWS as Excel.WorkSheet
				lcXLWS = .name
				local lnCols, lnRow, lnCol
				lnCols = .UsedRange.columns.count

				* {fr} Si tous les champs dont les noms sont dans la première ligne figurent dans la table
				local llFieldsCheck, lcField
				llFieldsCheck = uDefault(m.tlFieldsCheck, .f.)
				local array laFields[m.lnCols]
				lnRow = 1
				for m.lnCol = 1 to m.lnCols
					lcField = .Cells(m.lnRow, m.lnCol).value
					if lField(m.lcField, m.lcAlias)
						laFields[m.lnCol] = m.lcField
					else
						llResult = not m.llFieldsCheck
						if m.llResult
							laFields[m.lnCol] = space(0)
						else
							exit
						endif
					endif
				endfor
				assert m.llResult message program() + " - Some Field(s) of Worksheet " + cLitteral(m.lcXLWS) + " miss in table" + cLitteral(m.tuTable)
				if m.llResult

					* {fr} Si la table peut être ouverte en exclusif
					lcAlias = ExclusiveForce(m.lcAlias)
					llResult = used(m.lcAlias)
					assert m.llResult message program() + " - Table cannot be opened exclusively :" + cLitteral(m.tuTable)
					if m.llResult
						local lnSelect
						lnSelect = select(0)
						select (m.lcAlias)

						* {fr} Vider la table
						zap

						* {fr} Rouvrir en shared
						use
						lcAlias = cAlias(m.tuTable)
						select (m.lcAlias)

						* {fr} Créer une variable mémoire par champ destination
						local lcFields, luValue
						lcFields = cListOfArray(@laFields)
						lcFields = strtran(m.lcFields, ',' + ',', ',') && {fr} élimine les champs vides
						local &lcFields

						* {fr} Pour chaque ligne de données de la feuille Excel
						for m.lnRow = 2 to .UsedRange.rows.count

							* {fr} Ajouter un nouvel enregistrement vierge
							append blank
							scatter memvar memo

							* {fr} Pour chaque colonne comportant un champ présent dans la table
							for m.lnCol = 1 to m.lnCols
								lcField = m.laFields[m.lnCol]
								if not empty(m.lcField)

									* {fr} Si le contenu de la cellule est non nul, copier en mémoire
									luValue = .Cells(m.lnRow, m.lnCol).value
									if not isnull(m.luValue)
										store m.luValue to (m.lcField)
									endif
								endif
							endfor

							* {fr} Copier la mémoire dans la table
							gather memvar memo
						endfor
						select (m.lnSelect)
					endif
				endif
			endwith

			* {fr} Refermer Excel
			.parent.quit()
		endwith
	endif
	if m.llOpened
		use in (m.lcAlias)
	endif
endif

return m.llResult

*========================================
procedure XL8table && {fr} Importe une feuille d'un Classeur Excel 97 dans une table
lparameters ;
  tcXLWBAddr; && {fr} Adresse du MASQUE de classeur Excel contenant la feuille à importer
, tcSheet; && [feuille n°1] {fr} Nom de la feuille à importer
, tlNonVerifDernVers; && @ [.F.] {fr} Ne pas prendre le dernier n° de version du classeur Excel ; @ la table a été rafraîchie
, tlImportForce; && [.F.] {fr} Importer même si le classeur est plus ancien que la table
, tlCursor; && [.F.] {fr} Importer dans un curseur
, tcFieldsAdd; && [aucun] {fr} Champs à ajouter à la table ou au curseur résultat (définition type ALTER TABLE)
, tlAutomation && [.F.] {fr} Toujours importer par automation Excel

tcSheet = upper(uDefault(m.tcSheet, space(0)))
tlNonVerifDernVers = lTrue(m.tlNonVerifDernVers)
tlImportForce = lTrue(m.tlImportForce)
tlCursor = lTrue(m.tlCursor)
tcFieldsAdd = evl(m.tcFieldsAdd, space(0))
tlAutomation = lTrue(m.tlAutomation)

&& {fr} La première ligne de la feuille doit contenir les noms des champs
&& {fr} Les colonnes sont importées en caractères
&& {fr} Les colonnes masquées ou sans nom ne sont pas importées
&& {fr} Les colonnes servant à une concaténation sont tronquées

local llResult, lcResult && {fr} Adresse de la table créée OU nom du curseur OU message d'erreur

*================================================================
* {fr} Date      Par   Action
* ---------	----	----------------------------------------------------------------------------------
* 17/05/00	RA		Création
* 06/11/00	RA		Ajout de la procedure de recherche de dernière version
* 07/11/00	RA		Passage de procedure en fonction de maniere à retourner le nom de la dernière version qui a été importé
* 22/12/00	RA		Ajout de la procédure qui vérifie si l'import est réellement à faire (fichier DBF + récent que XLS)
* 12/04/01	TN		Suppression des colonnes sans nom
* 16/04/01	TN		Gestion du cas oû le classeur demandé n'existe pas
* 20/04/01	TN		Déboguage et simplification du renommage de la table créée
* 19/06/01	TN		Ajout du troisième paramètre
* 26/11/02	TN		Optimisation et restructuration
*================================================================

lcResult = space(0)
llResult = vartype(m.tcXLWBAddr) == 'C'
if m.llResult

	* {fr} Si un classeur existe selon le masque spécifié
	local lcXLWBAddr, lcXLWBPath, lcDBFStem, lcDBFAddr, lcAliasUsed, llAliasUsed, llExclusive
	lcXLWBAddr = iif(m.tlNonVerifDernVers, fullpath(m.tcXLWBAddr), cFileFreshest(m.tcXLWBAddr))
	llResult = file(m.lcXLWBAddr)
	if m.llResult

		* {fr} Déterminer l'adresse de la table destination
		lcXLWBPath = addbs(justpath(m.lcXLWBAddr))
		lcDBFStem = iif(empty(m.tcSheet), juststem(m.tcXLWBAddr), m.tcSheet)
		lcDBFAddr = forcepath(m.lcDBFStem + '.' + EXT_DBF, m.lcXLWBPath)

		* {fr} Si la table est ouverte, la fermer
		lcAliasUsed = iif(file(m.lcDBFAddr), cAliasUsed(m.lcDBFAddr, @llExclusive), '')
		llAliasUsed = used(m.lcAliasUsed)
		if m.llAliasUsed
			use in (m.lcAliasUsed)
		endif

		* {fr} Si import systématique ou classeur plus récent que la table
		tlNonVerifDernVers = .f. && {fr} indique en retour si la feuille a été importée
		if m.tlImportForce or nvl(lFileFresher(m.lcDBFAddr, m.lcXLWBAddr), .t.)

			* {fr} Si le classeur n'est pas couramment ouvert (IMPORT FROM échoue si le classeur est ouvert en read-write)
			local lnHandle
			lnHandle = fopen(m.lcXLWBAddr, 2) && 2 : read-write, buffered
			llResult = m.lnHandle > 0 ;
			 or set('ASSERT') == 'ON';
			 	 and 6 = messagebox(;
								"L'importation de données depuis le classeur " + m.lcXLWBAddr + " est impossible car il est ouvert par Excel" + CRLF + ;
								"Pour continuer l'importation, veuillez fermer le classeur et cliquer sur 'oui'" + CRLF + ;
								"Pour abandonner l'importation, cliquez sur 'non'" + CRLF + ;
								"Continuer ?";
							, 4+16)
			fclose(m.lnHandle)
			if m.llResult

				* {fr} Tabuler les champs additionnels éventuels
				local laFieldAdd[1]
				if not empty(m.tcFieldsAdd)
					aFieldsDef(@laFieldAdd, m.tcFieldsAdd)
				endif

				* {fr} Si la feuille peut être importée
				local loDefault, loSelect, lcSheet, loException as exception, llSheetError, llFormatError
				loDefault = abSet('Default', m.lcXLWBPath) && {fr} IMPORT crée la table dans le dossier par défaut
				loSelect = abSelect(0)
				lcSheet = iif(empty(m.tcSheet), space(0), textmerge([SHEET <<m.tcSheet>>]))
				llResult = m.tlAutomation
				if not m.llResult
					try
						import from (m.lcXLWBAddr) type xl8 &lcSheet
						llResult = .t.
					catch to loException
						llSheetError = m.loException.errorno = 1775 && {fr} You are trying to specify a worksheet name that does not match a name in the specified .XLS file.
						llFormatError = m.loException.errorno = 1661 && {fr} The Microsoft Excel file you have attempted to import is either not version 8.0 or has been corrupted.
					endtry
				endif
				release loDefault

				do case
				case m.tlAutomation or m.llFormatError

					* {fr} Traiter le classeur en automation
					lcResult = XL8table_Auto(m.lcXLWBAddr, m.tcSheet, m.lcDBFAddr,, m.tlCursor, @laFieldAdd)
					llResult = iif(m.tlCursor, used(m.lcResult), file(m.lcResult))

				case m.llResult && {fr} IMPORT FROM successful

					local lcAlias
					lcAlias = alias()

					* {fr} Alléger la table
					FreeTableSlim(m.lcAlias, 20) && 20% de marge

					* {fr} Renommer les champs par le contenu de la premiere ligne du tableau
					lcAlias = XL8table_ModiStru(m.lcAlias, m.tlCursor, @laFieldAdd)
					llResult = used(m.lcAlias)
					if m.llResult

						if m.tlCursor

							lcResult = m.lcAlias
						else

							* {fr} Renommer la table selon le nom de la feuille ou du classeur spécifiés
							local lcDBFImportAddr, lcFPTImportAddr, lcFPTAddr
							lcDBFImportAddr = cTableAddress(m.lcAlias)
							use in (m.lcAlias)
							if fullpath(m.lcDBFImportAddr) # fullpath(m.lcDBFAddr)

								delete file (m.lcDBFAddr)
								rename (m.lcDBFImportAddr) to (m.lcDBFAddr)

								lcFPTImportAddr = forceext(m.lcDBFImportAddr, 'fpt')
								if file(m.lcFPTImportAddr)
									lcFPTAddr = forceext(m.lcDBFAddr, 'fpt')
									delete file (m.lcFPTAddr)
									rename (m.lcFPTImportAddr) to (m.lcFPTAddr)
								endif
							endif

							lcResult = m.lcDBFAddr
						endif
					else
						lcResult = "XL8table() : Impossible de nommer les champs selon le contenu de la première ligne de la feuille " + m.tcSheet + " du classeur " + m.lcXLWBAddr
					endif

				case m.llSheetError
					lcResult = "XL8table() : Importation impossible car la feuille " + m.tcSheet + " n'existe pas dans le classeur " + m.lcXLWBAddr

				otherwise
					lcResult = cException(m.loException)
				endcase
			else
				lcResult = "XL8table() : Importation impossible car le classeur " + m.lcXLWBAddr + " était ouvert."
			endif

			tlNonVerifDernVers = m.llResult && {fr} indique en retour si la feuille a été importée
		else
			lcResult = m.lcDBFAddr
		endif

		* {fr} Si la table était ouverte, la rouvrir
		if m.llAliasUsed
			local lcExclusive
			lcExclusive = iif(m.llExclusive, 'Exclusive', 'Shared')
			use (m.lcDBFAddr) in 0 &lcExclusive
		endif
	else
		lcResult = textmerge("XL8table() : Importation impossible car aucun classeur n'existe selon le masque spécifié : '<<Alltrim(tcXLWBAddr)>>'")
	endif
else
	lcResult = "XL8table() : Veuillez spécifier un masque de classeur XL en première paramètre"
endif

assert m.llResult message m.lcResult

return m.lcResult

*========================================
procedure XL8table_Auto && {fr} Importe une feuille excel en automation
lparameters ;
  tcXLWBAddr; && {fr} Adresse du MASQUE de classeur Excel contenant la feuille à importer
, tcSheet; && [feuille n°1] {fr} Nom de la feuille à importer
, tcTable; && {fr} Table à créer
, tlNULL; && [.F.] {fr} accepter les valeurs nulles
, tlCursor; && [.F.] {fr} produire un curseur
, taFieldAdd && @ {fr} Champs additionnels éventuels

tlNULL = lTrue(m.tlNULL)
tlCursor = lTrue(m.tlCursor)
external array taFieldAdd

local lcResult as string;
, loXL as Excel.application;
, loWB as Excel.Workbook;
, loWS as Excel.WorkSheet;
, loWF as Excel.WorksheetFunction;
, loRange as Excel.range;

* {fr} Ouvrir la feuille Excel en automation
loXL = oXL()
loWB = loXL.Workbooks.open(m.tcXLWBAddr, .f., .t.)
loWS = loWB.Worksheets(iif(vartype(m.tcSheet) == 'C' and not empty(m.tcSheet), m.tcSheet, 1))
loWF = m.loXL.WorksheetFunction
lcResult = space(0)
if !m.loXL.Calculation = -4105  && {fr} xlCalculationAutomatic
	m.loWS.calculate
endif
with m.loWS.UsedRange as Excel.range

	* {fr} Pour chaque colonne
	local lnCols, lnCol, lcCol, lnField, lcField, lnSuffix, lnRow, laCols[.Columns.Count, 6], luValue, lcType, lnLen
	lnCols = min(.columns.count, 254)
	lnField = iif(m.tlCursor, 128, 10)
	for lnCol = 1 to m.lnCols

		lcType = 'U'
		store 0 to laCols[m.lnCol, 3], laCols[m.lnCol, 4]
		for lnRow = 1 to .rows.count
			if m.lnRow = 1

				* {fr} Première ligne : lire le nom du champ
				lcCol = cVFPName(.Cells(1, m.lnCol).value, m.lnField)
				lcCol = evl(m.lcCol, [Col] + transform(m.lnCol))

				* {fr} Dédoublonner le cas échéant
				lcField = m.lcCol
				lnSuffix = 0
				do while ascan(laCols, m.lcField, 1, -1, 1, 1+2+4) > 0
					lnSuffix = m.lnSuffix + 1
					lcField = left(m.lcCol, m.lnField-2) + '_' + transform(m.lnSuffix)
				enddo
				laCols[m.lnCol, 1] = m.lcField
			else

				* {fr} Autres lignes: déterminer le type du champ d'après le contenu
				loRange = .Cells(m.lnRow, m.lnCol)
				luValue = iif(m.loRange.HasFormula() and m.loWF.IsError(m.loRange); && {fr} plantage si la cellule contient une erreur de formule http://stackoverflow.com/questions/2424718/how-to-know-if-a-cell-has-an-error-in-the-formula-in-c-sharp
					, .null.;
					, m.loRange.value;
					)
				if isnull(m.luValue)
					if m.tlNULL
						laCols[m.lnCol, 5] = .t.
					endif
					loop

				else

					lcType = iif(m.lcType $ 'CMDT';
						, m.lcType;
						, vartype(m.luValue);
						)

					do case
					case m.lcType == 'C'
						luValue = transform(m.luValue)
						lnLen = evl(len(trim(m.luValue)), 1)
						if m.lnLen > 254 or CRLF $ m.luValue
							lcType = 'M'
							loop
						else
							laCols[m.lnCol, 3] = max(laCols[m.lnCol, 3] , m.lnLen)
						endif
					case m.lcType == 'N'
						laCols[m.lnCol, 3] = max(laCols[m.lnCol, 3] , len(transform(m.luValue))) && {fr} à modifier pour point décimal
					endcase
				endif
			endif
		endfor
		lcType = iif(m.lcType == 'U', 'M', m.lcType)
		laCols[m.lnCol, 2] = m.lcType
		laCols[m.lnCol, 3] = icase(m.lcType $ 'DT', 8, m.lcType $ 'BIM', 4, m.lcType == 'L', 1, laCols[m.lnCol, 3])
	endfor

	* {fr} Créer la table ou le curseur
	local laFields[1], lnFields
	lnFields = 0
	for lnCol = 1 to m.lnCols
		if not empty(laCols[m.lnCol, 1])
			lnFields = m.lnFields + 1
			dimension laFields[m.lnFields, 5]
			laFields[m.lnFields, 1] = laCols[m.lnCol, 1]
			laFields[m.lnFields, 2] = laCols[m.lnCol, 2]
			laFields[m.lnFields, 3] = laCols[m.lnCol, 3]
			laFields[m.lnFields, 4] = laCols[m.lnCol, 4]
			laFields[m.lnFields, 5] = laCols[m.lnCol, 5]
			laCols[m.lnCol, 6] = m.lnFields && {fr} pour correspondance lors du remplissage
		endif
	endfor

	if not laEmpty(@taFieldAdd)
		aColsDel(@taFieldAdd, 6)
		aAppend(@laFields, @taFieldAdd)
	endif

	lcResult = iif(m.tlCursor, juststem(m.tcTable), m.tcTable)
	if m.tlCursor
		create cursor (m.lcResult) from array laFields
	else
		create table (m.lcResult) free from array laFields
	endif

	* {fr} Importer les données
	local loTalk, luValue
	loTalk = abSet('TALK', 'OFF')
	for lnRow = 2 to .rows.count
		append blank
		for lnCol = 1 to .columns.count
			if not empty(laCols[m.lnCol, 1])
				luValue = .Cells(m.lnRow, m.lnCol)
				luValue = iif(m.luValue.HasFormula() and m.loWF.IsError(m.luValue);
					, .null.;
					, m.luValue.value;
					)
				luValue = iif(laCols[m.lnCol, 2] $ 'CM';
					, transform(nvl(m.luValue, ''));
					, uValue(m.luValue, laCols[m.lnCol, 2]);
					)
				if not m.tlNULL and isnull(m.luValue)
					lcType = laFields[m.lnCol, 2]
					lcType = iif(m.lcType $ 'M', 'C', m.lcType)
					luValue = uEmpty(m.lcType)
				endif
				replace (field(laCols[m.lnCol, 6])) with m.luValue
			endif
		endfor
	endfor
endwith

loWB.close
loXL.quit

FreeTableSlim(alias(), 20) && 20% de marge

if not m.tlCursor
	use
endif

return m.lcResult

*========================================
procedure XL8table_ModiStru && {fr} Renomme les champs selon la première ligne de la feuille XL
lparameters ;
  tcAlias; && {fr} Alias de la table importée d'Excel
, tlCursor; && [.F.] {fr} produire un curseur
, taFieldAdd && @ {fr} Champs additionnels éventuels
tlCursor = lTrue(m.tlCursor)
external array taFieldAdd

local llResult, lcResult && {fr} Alias du résultat

* {fr} Si la table peut être ouverte en exclusif
lcResult = ExclusiveForce(m.tcAlias)
llResult = used(m.lcResult)
if m.llResult

	local loSelect;
, 	lnFields;
, 	laFields[1],;
		lnField; && {fr} ne pas utiliser 'i' qui est un nom de colonne XL
, 	lcField;
, 	laFieldsNew[1],;
		lcFieldNew;
, 	lnSuffix;
, 	lcSuffix;
, 	lcAlter;
, 	lcDelete;
, 	lcAddr

	* {fr} Lire la structure de la table
	loSelect = abSelect(m.lcResult)
	lnFields = afields(laFields)

	* {fr} Lire les nouveaux noms des champs dans la première ligne et supprimer celle-ci
	go 1
	scatter to laFieldsNew memo
	delete
	pack

	* {fr} Pour chaque champ de la table
	store space(0) to lcAlter, lcDelete
	for m.lnField = m.lnFields to 1 step -1
		lcField = laFields[m.lnField, 1]

		* {fr} Si le nouveau nom est vide
		lcFieldNew = laFieldsNew[m.lnField]
		lcFieldNew = iif(vartype(m.lcFieldNew) == 'C', upper(alltrim(m.lcFieldNew)), space(0)) && {fr} toujours vrai en principe
		if empty(m.lcFieldNew)

			* {fr} Supprimer le champ
			lcDelete = textmerge([<<m.lcDelete>> DROP COLUMN <<m.lcField>>])
			if m.tlCursor
				adel(laFields, m.lnField)
			endif
			lnFields = m.lnFields - 1

		* {fr} Sinon (nouveau nom de champ non vide)
		else

			* {fr} Normaliser le nom du champ
			lcFieldNew = cVFPName(m.lcFieldNew, iif(m.tlCursor, 128, 10))

			* {fr} Si le nom du champ existe déjà, lui donner un suffixe numérique
			lnSuffix = 0
			do while ascan(laFields, m.lcFieldNew, 1, -1, 1, 2+4) > 0
				lnSuffix = m.lnSuffix + 1
				lcSuffix = transform(m.lnSuffix)
				lcFieldNew = substr(m.lcFieldNew, 1, 10-len(m.lcSuffix)) + m.lcSuffix
			enddo

			* {fr} Renommer le champ
			if m.tlCursor
				laFields[m.lnField, 1] = m.lcFieldNew
			else
				lcAlter = textmerge([<<m.lcAlter>> RENAME COLUMN <<m.lcField>> TO <<m.lcFieldNew>>])
			endif
		endif
	endfor

	* {fr} Si des champs additionnels sont demandés
	if not laEmpty(@taFieldAdd)
		if m.tlCursor
			aAppend(@laFields, @taFieldAdd)
		else
			for lnField = 1 to alen(taFieldAdd, 1)
				lcField = cFieldExp(taFieldAdd[m.lnField, 1], taFieldAdd[m.lnField, 2], taFieldAdd[m.lnField, 3], taFieldAdd[m.lnField, 4], taFieldAdd[m.lnField, 5])
				lcAlter = textmerge([<<m.lcAlter>> ADD COLUMN <<m.lcField>>])
			next
		endif
	endif

	* {fr} Si un curseur a été demandé
	lcAddr = cTableAddress(m.lcResult)
	if m.tlCursor

		local lcCursor, laData[1]

		* {fr} Créer le curseur
		lcCursor = sys(2015)
		create cursor (m.lcCursor) from array laFields

		* {fr} Supprimer les champs inutiles de la table
		alter table (m.lcResult) &lcDelete

		* {fr} Remplir avec les données de la table
		select (m.lcResult)
		scan
			scatter to laData
			insert into (m.lcCursor) from array laData
		endscan
		use

		* {fr} Supprimer la table qui ne sert plus à rien
		delete file (m.lcAddr)

		lcResult = m.lcCursor

	* {fr} Sinon (table)
	else
		alter table (m.lcResult) &lcDelete &lcAlter
	endif

	delete file (forceext(m.lcAddr, 'BAK')) && {fr} Supprime le fichier de sauvegarde
endif

return m.lcResult

*-					* Si le champ est numérique, le passer en caractères et supprimer les espaces en tête
*-					IF laFields[m.lnField, 2] == 'N'
*-						ALTER TABLE (m.lcResult) ALTER COLUMN (m.lcField) C (laFields[m.lnField,3] + 1 + laFields[m.lnField,4])
*-						REPLACE ALL (m.lcField) WITH Ltrim(Evaluate(m.lcField))
*-						laFields[m.lnField, 2] = 'C'
*-					ENDIF

*========================================
procedure XL8Tables && {fr} Importe les feuilles d'un Classeur Excel 97 dans des tables (cf. XL8table())
lparameters ;
  taXL8Table; && @ {fr} Tables crées ou rafraîchies ; Col 1 : Adresse, Col 2 : Rafraîchie (.T./.F.)
, tcXLWBAddr; && {fr} Adresse du MASQUE de classeur Excel contenant les feuille à importer
, tlNonVerifDernVers; && [.F.] {fr} Ne pas prendre la dernière version du classeur Excel
, tlImportForce && [.F.] {fr} Importer même si le classeur est plus ancien que la table
external array taXL8Table
tlNonVerifDernVers = lTrue(m.tlNonVerifDernVers)
tlImportForce = lTrue(m.tlImportForce)

aClear(@m.taXL8Table)

local lcXLWBAddr, llResult, lnResult && {fr} Nombre de tables crées ou rafraîchies
lnResult = 0

* {fr} Si un classeur existe selon le masque spécifié
lcXLWBAddr = iif(m.tlNonVerifDernVers, m.tcXLWBAddr, cFileFreshest(m.tcXLWBAddr))
llResult = file(m.lcXLWBAddr)
assert m.llResult message cAssertMsg(textmerge("Impossible de trouver un classeur XL suivant le masque : <<cLitteral(m.tcXLWBAddr)>>"))
if m.llResult

	* {fr} Ouvrir Excel en automation si pas encore fait
	local loXL
	loXL = vartype(m.poXL) == 'O' and loXL(m.poXL)
	if not m.loXL
		private poXL as Excel.application
		poXL = oXL()
	endif
	llResult = loXL(m.poXL)
	assert m.llResult message "Impossible d'ouvrir Excel en automation"
	if m.llResult

		* {fr} Si le classeur contient au moins une feuille de calcul
		local lnXLWSs, laXLWSs[1]
		lnXLWSs = acXLWSs(@laXLWSs, m.lcXLWBAddr)
		llResult = m.lnXLWSs > 0
		assert m.llResult message "Aucune feuille trouvée dans le classeur" + space(1) + m.lcXLWBAddr
		if m.llResult

			* {fr} Pour chaque feuille de calcul
			local lcXLWS, llUpdate, lcDBFAdr
			for each m.lcXLWS in laXLWSs

				* {fr} Si la feuille peut être importée dans une table
				llUpdate = .f.
				lcDBFAdr = XL8table(m.lcXLWBAddr, m.lcXLWS, @llUpdate, m.tlImportForce)
				if file(m.lcDBFAdr)

					* {fr} Mémoriser l'adresse de la table
					lnResult = m.lnResult + 1
					dimension taXL8Table[m.lnResult, 2]
					taXL8Table[m.lnResult, 1] = m.lcDBFAdr
					taXL8Table[m.lnResult, 2] = m.llUpdate
				endif
			endfor
		endif

		if not m.loXL
			poXL.quit
			release m.poXL
		endif
	endif
endif

return m.lnResult

* =====================================
define class abWord as relation
* =====================================

&& {fr} Read/write
cDefaultFolder = sys(5) + addbs(curdir()) && {fr} Dossier par défaut

&& {fr} Read only
iVersion = 0

&& {fr} Hidden
hidden array aFileConverters[1]
hidden oWord
oWord = .null. && {fr} AS Word.Application

* -------------------------------------
protected procedure init && {fr} Instancie Word.Application
local loExcept, llResult
try
	this.oWord = createobject('Word.Application')
	with m.this.oWord as word.application
		.DisplayAlerts = 0 && {fr} wdAlertsNone
		this.Init_aFileConverters
	endwith
	llResult = .t.
catch to loExcept
endtry

return m.llResult && {fr} si .F., l'objet n'est pas créé

* -------------------------------------
hidden procedure iVersion_Access
return int(val(this.oWord.version)) && 8: Word 97, etc.

* -------------------------------------
hidden procedure Init_aFileConverters && {fr} Tabule les convertisseurs de fichiers
if .FileConverters.count > 0

	local lnConv, loConv as word.FileConverter
	dimension this.aFileConverters[.FileConverters.Count, 5]
	for lnConv = 1 to .FileConverters.count

		loConv = .FileConverters(m.lnConv)
		with loConv as word.FileConverter

			this.aFileConverters[m.lnConv, 1] = .ClassName
			this.aFileConverters[m.lnConv, 2] = .FormatName
			this.aFileConverters[m.lnConv, 3] = .Extensions
			this.aFileConverters[m.lnConv, 4] = iif(.CanOpen, .OpenFormat, wdOpenFormatAuto)
			this.aFileConverters[m.lnConv, 5] = iif(.CanSave, .SaveFormat, wdFormatDocument)
		endwith
	next
endif

* -------------------------------------
procedure FileConvertersDisplay && {fr} Affiche les convertisseurs de fichiers
local lnConv
for lnConv = 1 to alen(m.this.aFileConverters, 1)
	? this.aFileConverters[m.lnConv, 1];
		+ chr(9) + this.aFileConverters[m.lnConv, 2];
		+ chr(9) + this.aFileConverters[m.lnConv, 3];
		+ chr(9) + transform(this.aFileConverters[m.lnConv, 4]);
		+ chr(9) + transform(this.aFileConverters[m.lnConv, 5])
next

* -------------------------------------
protected procedure wdFormat && {fr} Code format d'ouverture / sauvegarde
lparameters ;
  tcClass; && {fr} Classe de conversion de document (cf. this.oDoc)
, tlSave && [.F.] .T.: format de sauvegarde ; .F. : format d'ouverture
tlSave = lTrue(m.tlSave)

local lnConv, lnResult && {fr} Code format

lnResult = iif(m.tlSave, wdFormatDocument, wdOpenFormatAuto) && {fr} Code par défaut
if vartype(m.tcClass) == 'C' and not empty(m.tcClass)

	lnConv = ascan(m.this.aFileConverters, m.tcClass, 1, -1, 1, 15)
	if m.lnConv > 0

		lnResult = this.aFileConverters[m.lnConv, Iif(m.tlSave, 5, 4)]
	endif
endif

return m.lnResult

* -------------------------------------
hidden procedure cFullPath && {fr} Chemin complet d'un fichier
lparameters tcFile
return icase(;
	file(m.tcFile), fullpath(m.tcFile),;
	directory(justpath(m.tcFile)), addbs(fullpath(justpath(m.tcFile))) + justfname(m.tcFile),;
	this.cDefaultFolder + justfname(m.tcFile))

* -------------------------------------
function oDoc && {fr} Ouvre un document et fournit sa référence
lparameters ;
  tcFileSrce; && {fr} Document source
, tcClassSrce; && {fr} Classe de conversion si l'extension est ambiguÃ«
, tcPassWord && [''] {fr} mot de passe à l'ouverture
tcPassWord = iif(vartype(m.tcPassWord) == 'C', m.tcPassWord, space(0))

local llResult, lnFormat, loExcept as exception, loResult as word.document
loResult = .null.
llResult = vartype(m.tcFileSrce) == 'C' and file(m.tcFileSrce)
assert m.llResult message cAssertMsg(textmerge([<<Program()>> - Le fichier <<m.tcFileSrce>> est introuvable]))
if m.llResult

	tcFileSrce = fullpath(m.tcFileSrce)
	lnFormat = this.wdFormat(m.tcClassSrce)
	with this.oWord.Documents as word.Documents

		try && {fr} Abaque > ThN : à cause d'un pb d'installation Word 97, la première ouverture envoie un message d'erreur 'base de registre ...'
			loResult = .open(m.tcFileSrce, .f., .f., .f., m.tcPassWord, '', .f., m.tcPassWord, '', m.lnFormat)
		catch to loExcept
		endtry
		loResult = nvl(m.loResult, .open(m.tcFileSrce, .f., .f., .f., m.tcPassWord, '', .f., m.tcPassWord, '', m.lnFormat))

		* {fr} Masquer le document
		if vartype(m.loResult) == 'O'
			loResult.application.visible = .f.
		endif
	endwith
endif

return m.loResult

* -------------------------------------
hidden function oDocDefault && {fr} Document par défaut
lparameters toDoc as word.document, tnDoc && @ {fr} n° de document

local llResult

toDoc = icase(.f., .null.;
	, vartype(m.toDoc) == 'O', m.toDoc;
	, type('this.oWord.Documents(1)') == 'O', this.oWord.Documents(1);
	, .null.)
llResult = vartype(m.toDoc) == 'O'
assert m.llResult message cAssertMsg(textmerge([<<Program()>> - Aucun document n'est ouvert dans Word ...]))
if m.llResult

	* {fr} Trouver le n° du document
	for tnDoc = 1 to this.oWord.Documents.count
		if this.oWord.Documents(m.tnDoc).fullname == m.toDoc.fullname && {fr} this.oWord.Documents(m.tnDoc) = m.toDoc ne marche pas en automation
			exit
		endif
	next
endif

return m.toDoc

* -------------------------------------
procedure oDocConvert && {fr} Sauvegarde un document dans un autre format (si supporté)
lparameters ;
  tcFileDest; && @ {fr} Adresse du fichier destination
, tcClassDest; && {fr} Classe de conversion si l'extension est ambiguÃ«
, tcPassWord; && [''] {fr} mot de passe
, toDoc && [Documents(1)] {fr} Référence au document source
tcPassWord = iif(vartype(m.tcPassWord) == 'C', m.tcPassWord, space(0))
local loException, lnFormat, llResult

toDoc = this.oDocDefault(m.toDoc)
llResult = vartype(m.toDoc) == 'O'
if m.llResult

	tcFileDest = this.cFullPath(m.tcFileDest)
	lnFormat = this.wdFormat(m.tcClassDest, .t.)

	delete file (m.tcFileDest)
	try
		toDoc.saveas(m.tcFileDest, m.lnFormat, .f., m.tcPassWord)
	catch to loException
	endtry
	llResult = lFile(m.tcFileDest)
	if not m.llResult && {fr} Abaque ThN : Word 97 me fait des misères

		toDoc.saveas(m.tcFileDest, m.lnFormat, .f., m.tcPassWord)
		llResult = lFile(m.tcFileDest)
	endif
endif

return m.llResult

* -------------------------------------
procedure Convert && {fr} Ouvre un document et le convertit dans un autre format (si supporté)
lparameters ;
  tcFileSrce; && {fr} Document source
, tcClassSrce; && {fr} Classe de conversion si l'extension est ambiguÃ«
, tcFileDest; && @ {fr} Adresse du fichier destination
, tcClassDest; && {fr} Classe de conversion si l'extension est ambiguÃ«
, tcPassWord && [''] {fr} mot de passe
local loDoc
loDoc = this.oDoc(m.tcFileSrce, m.tcClassSrce, m.tcPassWord)

return vartype(m.loDoc) == 'O';
 and this.oDocConvert(m.tcFileDest, m.tcClassDest, m.tcPassWord, m.loDoc);
 and nvl(loDoc.close(.f.), .t.) && .F.: no save

* -------------------------------------
procedure UserEdit && {fr} Donne la main à l'utilisateur pour éditer un document
lparameters toDoc as word.document && [Documents(1)] {fr} Référence au document source
local lnDoc, llResult

toDoc = this.oDocDefault(m.toDoc, @lnDoc)
llResult = vartype(m.toDoc) == 'O'
if m.llResult

	* {fr} this.PreventClose && {fr} sinon ça génère des erreurs && {fr} en fait ça marche presque à tous les coups sur Word 97
	toDoc.activate
	with m.this.oWord as word.application

		.ActiveWindow.view.type = 1  && {fr} wdNormalView
		.top = max(.top, 0)
		.visible = .t.
		.activate


* {fr} Afficher un message [Enregistrez et fermez le document pour revenir à la console] && {fr} pas trouvé comment faire :-(

		* {fr} Attendre que l'utilisateur ait fini ses modifications
		do while type(textmerge('.Documents(<<m.lnDoc>>)')) == 'O'
			inkey(.5)
		enddo
	endwith

	if type('this.oWord.Application') == 'O' && {fr} L'utilisateur peut avoir fermé Word par la X
		this.oWord.visible = .f.
	endif
endif

return m.llResult

* -------------------------------------
procedure PreventClose && {fr} Empêche de fermer Word && {fr} Mike Gagnon sur AtoutFox

declare integer FindWindow in user32 string lpClassName, string lpWindowName
declare integer GetSystemMenu in user32 integer hwnd, integer bRevert
declare integer RemoveMenu in user32 integer hMenu, integer nPosition, integer wFlags

local lhWin, lhMenu, lnMenu
lhWin = FindWindow("OPUSApp", 0) &&"OPUSApp" est le nom de la Classe Word
lhMenu = GetSystemMenu(lhWin, 0)
for lnMenu = 6 to 0 step -1
 RemoveMenu(lhMenu, m.lnMenu, 1024) && {fr} MF_BYPOSITION
next

this.oWord.top = max(this.oWord.top, 0) && {fr} on ne peut plus bouger la fenêtre


* {fr} this.oWord.CommandBars('File').Controls('Quit').Enabled = .F. && {fr} ne marche pas

* -------------------------------------
procedure destroy

local loExcept as exception
try && {fr} Type('this.oWord.Documents') == 'O' alors que l'utilisateur a fermé Word ...
	if type('this.oWord.Documents') == 'O'
		if this.oWord.Documents.count > 0
			this.oWord.Documents.close(.f.) && {fr} ferme tous les documents
		endif
		this.oWord.quit
	endif
catch to loExcept
endtry

* =====================================
enddefine && {fr} CLASS abWord
* =====================================
