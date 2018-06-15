* {fr} abDev.prg
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

* =================================================
define class cusBatchLog as custom && {fr} Trace un processus répétitif dans un tableau à l'écran
* =================================================

&& {fr} Valeurs initiales
alConsole = .f.
alFooter = .f.
acScreenFont = .null.
anScreenFontSize = .null.

* -------------------------------
&& {fr} Contenu des lignes du tableau de compte rendu
#define  L_cHEADER		1 && Texte de l'en-tête de la colonne
#define  L_uVALUE	 		2 && {fr} Ligne courante : contenu original de la cellule
#define  L_cTYPE	 		3 && {fr} Ligne courante : type du contenu original
#define  L_cDISPLAY		4 && {fr} Ligne courante : contenu affiché (en caractères bien sûr)
#define  L_lBORDER		5 && {fr} La colonne est délimitée par des barres verticales
#define  L_nWIDTH			6 && {fr} Largeur utilisable pour affichage dans la colonne (foxels)
#define  L_cID				7 && {fr} Identifiant de la colonne
#define  L_nSUM				8 && {fr} Cumul de la donnée si elle est numérique
#define  L_lSUM				9 && {fr} Sommer / moyenner la donnée en fin d'état si elle est numérique
#define  L_cFORMAT		10 && {fr} Format pour Transform()
#define  L_COUNT 			L_cFORMAT
* -------------------------------
dimension aaLog[;
				L_COUNT; && {fr} une ligne par caractéristique
			, 1] && {fr} une colonne par colonne de log

anCols = 0

acLine = '' && {fr} Contenu de la ligne courante
anLine = 0 && {fr} N° de la ligne courante
anDataLines = 0 && {fr} Nombre de lignes contenant des données

acWarnings = '' && {fr} Avertissements déjà émis
anWarnings = 0  && {fr} Avertissements déjà émis

* {fr} Adresses des fichiers
acTxtLogAddr = ''
acWarnTxtLogAddr = ''
acDBFlogAddr = ''
acDBFlogAlias = ''

alParentPjFiles = .f. && {fr} Parent object has a reference to project files collection
alDocumentView = .f.
alDataSession = .f.
alProjectManager = .f.

* -------------------------------------------------
procedure Init && {fr} Ouvre les fichiers de compte-rendu et vide la fenêtre VFP
lparameters ;
  tuTxtLog; && [.T.] {fr} Nom, dossier ou adresse du fichier de compte-rendu texte, .T. : automatique
, tuDBFlog; && [.T.] {fr} Nom, dossier ou adresse du fichier de la table de compte-rendu, .T. : automatique
, tlFooter; && [.T.] {fr} Produire une ligne de totaux / moyennes en fin de CR
, tlConsole; && [.T.] {fr} Afficher le compte rendu à l'écran s'il est visible

local lnParms, luTxtLog, luDBFlog, llResult

lnParms = pcount()

* {en} Determine if Parent object holds a reference to a project files collection
this.alParentPjFiles = type('this.parent.aoPjFiles') == 'O' and not isNull(this.parent.aoPjFiles)

* {en} Init/Open log files
luTxtLog = iif(m.lnParms>=1 and vartype(m.tuTxtLog) $ 'CL', m.tuTxtLog, .t.)
luDBFlog = iif(m.lnParms>=2 and vartype(m.tuDBFlog) $ 'CL', m.tuDBFlog, .t.)
llResult = this.init_Logs(m.luTxtLog, m.luDBFlog)
assert m.llResult message cAssertMsg(textmerge([Échec de la création des fichiers de compte-rendu]))

* {fr} Déterminer si une ligne de totaux / moyennes doit être produite en fin de log
this.alFooter = m.lnParms < 3 or lTrue(m.tlFooter)

* {fr} Déterminer si les sorties doivent être envoyées à l'écran
this.alConsole = (m.lnParms < 4 or lTrue(m.tlConsole));
	and inlist(_vfp.startmode, 0, 1, 4);
	and vartype(_screen) == 'O' ;
	and _screen.visible
if m.this.alConsole

	this.acScreenFont = _screen.fontname
	this.anScreenFontSize = _screen.fontsize
	_screen.fontname = "Courier New"
	_screen.fontsize = 10
	hide window all
	activate screen
	clear
endif

return m.llResult

* -------------------------------------------------
procedure init_Logs && {fr} Ouvre les fichiers de compte-rendu
lparameters ;
  tuTxtLog; && [.T.] {fr} Nom ou adresse du fichier de compte-rendu texte, .T. pour automatique
, tuDBFlog; && [.T.] {fr} Nom ou adresse du fichier de la table de compte-rendu, .T. pour automatique

local lcLogAddr, lcResult, llResultTXT, llResultDBF

* {fr} Si une adresse de log peut être bâtie
lcLogAddr = this.cLogPathStem(m.tuTxtLog)
llResultTXT = !empty(m.lcLogAddr)
if m.llResultTXT

	* {fr} Ouvrir ou créer les fichiers de log
	this.acTxtLogAddr = lower(forceext(m.lcLogAddr, EXT_LOG))
	this.acWarnTxtLogAddr = lower(forceext(m.lcLogAddr , EXT_LOG_WARN))
	this.LogCheck(m.this.acTxtLogAddr)
	this.LogCheck(m.this.acWarnTxtLogAddr)

	lcResult = 'Starting log on '+ transform(datetime())
	lcResult = CRLF2 + m.lcResult + CRLF + replicate('=', len(m.lcResult))
	llResultTXT = strtofile(m.lcResult, this.acTxtLogAddr, .t.) > 0
	llResultTXT = strtofile(m.lcResult, this.acWarnTxtLogAddr, .t.) > 0 and m.llResultTXT
endif

* {fr} Open/Init table log
lcLogAddr = this.cLogPathStem(m.tuDBFlog)
llResultDBF = !empty(m.lcLogAddr)
if m.llResultDBF
	this.acDBFlogAlias = cVFPname(juststem(m.lcLogAddr))
	this.acDBFlogAddr = forceext(m.lcLogAddr, 'dbf')
	use in select(this.acDBFlogAlias)
	this.LogCheck(this.acDBFlogAddr)
	llResultDBF = file(this.acDBFlogAddr)
	if m.llResultDBF
		use (this.acDBFlogAddr) in 0 shared alias (this.acDBFlogAlias)
	endif
endif

return m.llResultTXT or m.llResultDBF

* -------------------------------------------------
procedure destroy && {fr} Ferme les fichiers de log et rétablit la fenêtre VFP

* {fr} Faire le pied du tableau
this.FooterCreate()

* {en} Close log table
use in select(this.acDBFlogAlias)

* {en} Show windows hidden AT init()
show window all
show window all && {fr} parfois il reste des fenêtres invisibles

* {en} Restore screen font
_screen.fontname = this.acScreenFont
_screen.fontsize = this.anScreenFontSize

if m.this.alConsole

	* {fr} Si l'utilisateur souhaite voir les avertissements
	local lcS, lcBe
	lcS = Iif(m.this.anWarnings > 1, 's', '')
	if not empty(m.this.acWarnings);
	 and 6 = messagebox(;
				Textmerge([<<m.this.anWarnings>> ] + ICase(;
					cLangUser() = 'fr',	[avertissement<<m.lcS>> <<Iif(m.this.anWarnings > 1, 'ont', 'a')>> été enregistré<<m.lcS>>] + CRLF2 + "Voulez-vous le<<m.lcS>> voir ?",; && copy-paste this line to add another language support
															[warning<<m.lcS>> <<Iif(m.this.anWarnings > 1, 'were', 'was')>>  recorded] + CRLF2 + "Do you want to see <<Iif(m.this.anWarnings > 1, 'them', 'it')>>?"; && default: English
				));
			, 4+32;
			, icase(;
					cLangUser() = 'fr',	"Fin de traitement",; && copy-paste this line to add another language support
															"End of processing"; && default: English
				);
			, 5000;
			)

	 	* {fr} Copier les avertissements dans un fichier texte temporaire
	 	local lcFile, loSafety
	 	lcFile = forcepath(m.this.acWarnTxtLogAddr, sys(2023))
	 	loSafety = abSet('SAFETY', 'OFF')
	 	strtofile(m.this.acWarnings, m.lcFile)
	 	release loSafety

	 	* {fr} Afficher dans une fenêtre d'édition
	 	modify file (m.lcFile) nowait
	 	activate window (justfname(m.lcFile))
	endif
endif

* -------------------------------------------------
procedure LogCheck && {fr} Vérifie qu'un fichier de compte-rendu est accessible en écriture
lparameters tcLogAddr && {fr} Adresse du fichier de compte-rendu

if file(m.tcLogAddr)

	* {fr} Ajouter le fichier au projet
	if this.alParentPjFiles
		ProjectFileAdd(m.tcLogAddr, this.parent.aoPjFiles)
	endif

	local lnHandle, lcWindow
	lnHandle = 0
	lcWindow = justfname(m.tcLogAddr)
	do while .t.
		lnHandle = fopen(m.tcLogAddr, 1) && 1 : write buffered
		if m.lnHandle = -1

			if wexist(m.lcWindow)
				release windows (m.lcWindow)
				exit

			else
				if 2 = messagebox('';
							+ "Le fichier de log " + m.tcLogAddr + " est actuellement ouvert." + CRLF;
							+ "Veuillez le refermer et cliquer sur Réessayer." + CRLF;
							+ "Cliquez sur 'Annuler' pour continuer sans écrire dans le log";
						, 5+16)
					exit
				endif
			endif
		else
			exit
		endif
	enddo

	fclose(m.lnHandle)
endif

* -------------------------------------------------
protected procedure cLogPathStem && {fr} Adresse d'un fichier de compte-rendu sans l'extension
lparameters tuLog; && [.T.] {fr} Nom ou adresse du fichier de compte-rendu, .T. pour automatique

local lcResult, lcSys16;
, lcLogPath, lcLogPathAuto;
, lcLogStem, lcLogStemAuto

lcResult = ''
lcSys16 = sys(16,1)
if !empty(m.lcSys16)

	lcLogPathAuto = addbs(cModuleInfo(m.lcSys16, 'Path'))
	lcLogStemAuto = cModuleInfo(m.lcSys16, 'Name')
	store '' to m.lcLogPath, m.lcLogStem

	do case

	case ga_Type_IsChar(m.tuLog, .T.)

		lcLogPath = addbs(justpath(m.tuLog))
		lcLogPath = iif(directory(m.lcLogPath), m.lcLogPath, m.lcLogPathAuto)

		lcLogStem = cFileName(juststem(m.tuLog))
		lcLogStem = iif(lFileName(m.lcLogStem), m.lcLogStem, m.lcLogStemAuto)

	case lTrue(m.tuLog)
		lcLogPath = lcLogPathAuto
		lcLogStem = lcLogStemAuto

	endcase
	lcResult = addbs(m.lcLogPath) + m.lcLogStem
endif

return m.lcResult

* -------------------------------------------------
procedure ColAdd && {fr} Ajoute une colonne à la fin de la table de compte-rendu
lparameters ;
  tcHeader; && [''] {fr} Contenu de l'en-tête de la colonne
, tnColWidth; && [Header width || 10] {fr} Largeur de la colonne en foxels
, tlNoLeftBar;	 && [.F.] {fr} Ne pas délimiter les colonnes par une barre verticale
, tcID; && [tcHeader] {fr} Identifiant de la colonne
, tlSum; && [.F.] {fr} Si la donnée est numérique, en fin d'état : .T.: Sommer, .F.: Moyenner, .NULL.: ne rien faire
, tcFormat; && [''] {fr} Format pour Transform()

local lnResult && {fr} Numéro de la colonne ajoutée
lnResult = 0

if m.this.anLine = 0 && {fr} possible only if no line was displayed yet

 	lnResult = this.aColAdd()

 	local lcHeader, lnColWidth
 	lcHeader = uDefault(m.tcHeader, '')
 	lnColWidth = uDefault(m.tnColWidth, max(10, len(m.lcHeader)))

	this.aaLog[L_cHEADER, m.lnResult] = m.lcHeader
	this.aaLog[L_uVALUE, m.lnResult] = .null.
	this.aaLog[L_cTYPE, m.lnResult] = ''
	this.aaLog[L_nWIDTH, m.lnResult] = m.lnColWidth
	this.aaLog[L_cDISPLAY, m.lnResult] = space(m.lnColWidth)
	this.aaLog[L_lBORDER, m.lnResult] = not uDefault(m.tlNoLeftBar, .f.)
	this.aaLog[L_cID, m.lnResult] = uDefault(m.tcID, m.lcHeader)
	this.aaLog[L_nSUM, m.lnResult] = 0
	this.aaLog[L_lSUM, m.lnResult] = iif(vartype(m.tlSum) $ 'LX', m.tlSum, .f.)
	this.aaLog[L_cFORMAT, m.lnResult] = evl(m.tcFormat, '')

	* {fr} Si affichage à l'écran (console)
	if m.this.alConsole

		* {fr} Calculer la largeur totale du tableau en caractères
		local lnCol, lnTableWidth
		lnTableWidth = 0
		for m.lnCol = 1 to m.lnResult
			lnTableWidth = m.lnTableWidth + this.aaLog[L_nWIDTH, m.lnCol] + iif(this.aaLog[L_lBORDER, m.lnCol], 1, 0)
		endfor
		lnTableWidth = m.lnTableWidth + 1 && {fr} right border

		* {fr} Tant que le tableau est plus large que l'écran, réduire la police de l'écran
		do while m.lnTableWidth * fontmetric(6, _screen.fontname, _screen.fontsize) > _screen.viewportwidth ;
				and _screen.fontsize > 5
			_screen.fontsize = _screen.fontsize - 1
		enddo
	endif
endif

this.anCols = m.lnResult

return m.lnResult

* -------------------------------------------------
procedure aColAdd && {fr} Ajoute une colonne au tableau de compte-rendu
local lnResult && {fr} Numéro de la colonne ajoutée
 	lnResult = alen(this.aaLog, 2)

if not vartype(this.aaLog[1]) = 'L' && {fr} La première colonne n'est plus disponible

 	local array laCopy[L_COUNT, m.lnResult]

 	acopy(this.aaLog, m.laCopy)
 		aColsIns(@m.laCopy)

 	lnResult = m.lnResult + 1
 		dimension this.aaLog[L_COUNT, m.lnResult]
 	acopy(m.laCopy, this.aaLog)
 	endif

 	return m.lnResult

* -------------------------------------------------
procedure nCol && {fr} Numéro de colonne d'après son identifiant
lparameters ;
  tcColID && {fr} Identifiant de la colonne

local lnResult && {fr} Numéro de la colonne
lnResult = 0

if vartype(m.tcColID) == 'C' and not empty(m.tcColID)

	lnResult = ascan(this.aaLog, m.tcColID, 1, -1, -1, 1+2+4)
	lnResult = asubscript(this.aaLog, m.lnResult, 2)
endif

return m.lnResult

* -------------------------------------------------
procedure nColWidthTotal && {fr} Largeur totale d'un colonne du compte-rendu (avec gouttières)
lparameters tnCol && {fr} Numéro de colonne

local lnColWidth, lnResult

lnResult = 0

if vartype(m.tnCol) = 'N' ;
 and between(m.tnCol, 1, alen(this.aaLog, 2))

	lnColWidth = this.aaLog [L_nWIDTH, m.tnCol]
	lnResult = iif(vartype(m.lnColWidth) == 'N' and m.lnColWidth > 0;
			 , 1 + m.lnColWidth; && {fr} gouttière avant
			 , 0;
			 )
endif

return m.lnResult

* -------------------------------------------------
procedure CellFill && {fr} Remplit une cellule du compte-rendu
lparameters ;
  tuCol; && {fr} Numéro ou ID de la colonne
, tuContent; && [''] {fr} Contenu à placer dans la colonne
, tlExpand; && [.F.] {fr} Si le contenu est plus large que la colonne, déborder sur les colonnes de droite
, tlNoDisplay; && [.F.] {fr} Différer l'affichage de la ligne (pour gagner du temps lorsque plusieurs modifications successives de la ligne)
, tcFormat; && [''] {fr} Format d'affichage

local lnCols, lcType, lnCol, llResult

* {fr} Si la définition de colonne est valide
lnCols = alen(this.aaLog, 2)
lcType = vartype(m.tuCol)
do case
	case m.lcType == 'N'
		lnCol = m.tuCol
		llResult = m.tuCol <= m.lnCols
	case m.lcType == 'C'
		lnCol = this.nCol(m.tuCol)
		llResult = m.lnCol > 0
endcase
assert m.llResult message cAssertMsg(textmerge([Spécification de colonne invalide <<cLitteral(m.tuCol)>>]))
if m.llResult

	local luContent, llExpand, llNoDisplay, lcFormat, lcContent, lnColWidth

	* {fr} Donner leur valeur par défaut aux paramètres optionnels
	luContent = iif(pcount() >= 2, m.tuContent, '')
 	llExpand = lTrue(m.tlExpand)
	llNoDisplay = lTrue(m.tlNoDisplay)
	lcFormat = iif(pcount() >= 5 and vartype(m.tcFormat) == 'C', m.tcFormat, '')
	lcFormat = evl(m.lcFormat, this.aaLog[L_cFORMAT, m.lnCol])

 		* {fr} Si la colonne a une largeur positive
 		lnColWidth = this.aaLog[L_nWIDTH, m.lnCol]
 		llResult = m.lnColWidth > 0
 	if m.llResult

 		* {fr} Charger la données originale dans la cellule
 		this.aaLog[L_uVALUE, m.lnCol] = m.luContent
 		this.aaLog[L_cTYPE, m.lnCol] = vartype(m.luContent)

 		* {fr} Si la donnée est numérique, cumuler
 		if this.aaLog[L_cTYPE, m.lnCol] == 'N'
 			this.aaLog[L_nSUM, m.lnCol] = this.aaLog[L_nSUM, m.lnCol] + m.luContent
 		endif

		* {fr} Si la colonne peut déborder
		lcContent = transform(m.luContent, m.lcFormat)
	 	if m.llExpand and m.lnCol < m.lnCols

	 		local lnColX, lnColWidthX
	 		lnColWidthX = m.lnColWidth
	 		for m.lnColX = m.lnCol + 1 to alen(this.aaLog, 2)
			 	lnColWidthX = m.lnColWidthX + this.nColWidthTotal(m.lnColX)
	 		endfor
	 		lnColWidth = min(len(m.lcContent), m.lnColWidthX)
	 	endif

 		* {fr} Charger l'affichage dans la cellule
 		this.aaLog[L_cDISPLAY, m.lnCol] = ;
 				this.cCellContent(m.tuContent, m.lnColWidth, m.llExpand, m.lcFormat)

		llResult = m.llNoDisplay or this.LineDisplay()
 	endif
endif

return m.llResult

* -------------------------------------------------
procedure cCellContent && {fr} Contenu d'une cellule du tableau de compte-rendu, ajusté à la taille de la cellule
lparameters ;
  tuContent; && {fr} Contenu à placer dans la colonne
, tnColWidth; && {fr} Largeur de la colonne en foxels
, tlExpand; && [.F.] {fr} Si le contenu est plus large que la colonne, déborder sur les colonnes de droite
, tcFormat; && [''] {fr} Format de présentation

tlExpand = lTrue(m.tlExpand)
tcFormat = evl(m.tcFormat, '')

 	local lcType, lcResult

 	lcType = vartype(m.tuContent)
 	if m.lcType $ 'CNYLDT'

 	lcResult = transform(m.tuContent, m.tcFormat)

 	* {fr} Manage position in column, trim if necessary
 	do case

 	case m.lcType $ 'NY'
		lcResult = iif(m.tlExpand;
			, this.cColJustified(m.lcResult, m.tnColWidth); && {fr} gauche
			, padl(m.lcResult, m.tnColWidth, space(1)); && {fr} Aligner à droite avec un Space(1)
			)

 	case m.lcType = 'L'
		lcResult = iif(m.tlExpand;
				, this.cColJustified(m.lcResult, m.tnColWidth); && {fr} à gauche
				, padl(m.lcResult, m.tnColWidth/2+2, space(1)); && {fr} centrer
				)

 	otherwise
		* {fr} Aligner à gauche en tentant de préserver les espaces en tête
		lcResult = this.cColJustified(m.lcResult, m.tnColWidth)
	endcase

	lcResult = padr(m.lcResult, m.tnColWidth, space(1))
else
 	lcResult = ''
endif

 	return m.lcResult

* -------------------------------------------------
function cColJustified && {fr} Justifie le contenu d'une cellule dans la largeur de la colonne
lparameters ;
  tcContent ; && {fr} Contenu à placer dans la colonne
, tnColWidth && {fr} Largeur de la colonne en foxels

local lcResult

lcResult = m.tcContent
if lenc(m.lcResult) > m.tnColWidth

	lcResult = rtrim(m.lcResult)
	if lenc(m.lcResult) > m.tnColWidth

		lcResult = ltrim(m.lcResult)
		if lenc(m.lcResult) > m.tnColWidth

			lcResult = leftc(m.lcResult, m.tnColWidth-1) + POINTSUSP
		endif
	endif
endif

return m.lcResult

* -------------------------------------------------
procedure LineFill && {fr} Écrit une nouvelle ligne à l'écran
lparameters tuContent

local lnResult && {fr} Position de la fin de ligne

lnResult = 0
if this.LineFeed()
	this.acLine = transform(m.tuContent)
	if m.this.alConsole
		activate screen
		?? m.this.acLine at 0
	endif
	lnResult = len(m.this.acLine)
endif

return m.lnResult

* -------------------------------------------------
procedure LineAppend && {fr} Ajoute un contenu à la ligne courante et affiche le résultat
lparameters ;
  tuContent ; && {fr} Contenu à placer dans la colonne
, tnPosition && [fin de ligne] {fr} Position où le contenu est ajouté

local lnLine, lnResult && {fr} Position où le contenu a été ajouté

this.acLine = alltrim(this.acLine)
lnLine = len(this.acLine)
lnResult = iif(vartype(m.tnPosition)=='N', m.tnPosition, m.lnLine)
this.acLine = left(this.acLine, m.lnResult) + ;
							space(iif(empty(m.this.acLine), 0, 1)) + ;
							transform(m.tuContent)

* {fr} Compléter avec des espaces pour superposer la ligne précédente
if m.lnLine > len(this.acLine)
	this.acLine = padr(this.acLine, m.lnLine, space(1))
endif

if m.this.alConsole
	activate screen
	?? m.this.acLine at 0
endif

return m.lnResult

* -------------------------------------------------
procedure LineDisplay && {fr} Affiche le contenu de l'en-tête ou de la ligne courante
lparameters tlHeader && [.F.] {fr} Afficher l'en-tête du tableau
tlHeader = lTrue(m.tlHeader)

local lcLineOut, lnDisplayWidth;
, lnCol, lnColsWidth, lnColWidth;
, lcCellDisplay, llLeftBar, llResult

* {fr} Pour chaque colonne
lcLineOut = ''
store 0 to m.lnDisplayWidth, m.lnColsWidth
for m.lnCol = 1 to alen(this.aaLog, 2)

	lcCellDisplay = iif(m.tlHeader;
			, this.cCellContent(this.aaLog[L_cHEADER, m.lnCol], this.aaLog[L_nWIDTH, m.lnCol]);
			, this.aaLog[L_cDISPLAY, m.lnCol];
			)
	llLeftBar = this.aaLog[L_lBORDER, m.lnCol]
	lnColWidth = 1 + this.aaLog[L_nWIDTH, m.lnCol]
	llResult = ;
			vartype(m.lcCellDisplay) == 'C' ;
		and	vartype(m.llLeftBar) == 'L' ;
		and	vartype(m.lnColWidth) == 'N'
	assert m.llResult message cAssertMsg(textmerge([La table de log est mal remplie.]))
	if m.llResult

		do case
		case m.lnDisplayWidth = m.lnColsWidth && {fr} start current column
			lcLineOut = m.lcLineOut + iif(m.llLeftBar, '|', space(1)) + m.lcCellDisplay
		case m.lnDisplayWidth >= m.lnColsWidth + m.lnColWidth && {fr} Beyond current column
		otherwise && {fr} inside current column
			lcLineOut = padr(m.lcLineOut, m.lnColsWidth + m.lnColWidth, space(1))
		endcase
		lnColsWidth = m.lnColsWidth + m.lnColWidth
		lnDisplayWidth = len(m.lcLineOut)
	else
		exit
	endif
endfor

if m.llResult
	this.acLine = m.lcLineOut + iif(m.llLeftBar, '|', '')
	this.lineShow(m.tlHeader)
endif

return m.llResult

* -------------------------------------------------
procedure lineShow && {fr} Affiche la ligne courante à l'écran
lparameters tlHeader && [.F.] {fr} Afficher l'en-tête

if m.this.alConsole

	activate screen
*!*			?? '' AT 0 && {fr} bug de TEXT TO m.lcResult TEXTMERGE NOSHOW
	?? space(1) at 0 && {fr} bug de TEXT TO m.lcResult TEXTMERGE NOSHOW

	if lTrue(m.tlHeader)
		?
	endif
	?? m.this.acLine at 0
endif

* -------------------------------------------------
procedure LineFeed && {fr} Vide la ligne courante pour en commencer une nouvelle
lparameters ;
  tlSepLine ; && [.F.] {fr} Tracer une ligne séparatrice après la nouvelle ligne
, tlDataLine && [.F.] {fr} La nouvelle ligne contient des données vivantes

local lcLine, llResult

* {fr} Update line count
if this.anCols > 0
	this.anLine = this.anLine + 1
	this.anDataLines = this.anDataLines + iif(lTrue(m.tlDataLine), 1, 0)
endif

* {fr} Flush and clear current line
llResult = this.LineFlush()
llResult = this.LineClear() and m.llResult

* {fr} Move to ENDFOR line, with separation line if required
if lTrue(m.tlSepLine)
	lcLine = this.cSepLine()
	strtofile(CRLF + m.lcLine, this.acTxtLogAddr, .t.)
else
	lcLine = space(1)
endif
if m.this.alConsole
	activate screen
	? m.lcLine
endif

return m.llResult

* -------------------------------------------------
procedure LineFlush && {fr} Sauve la ligne courante dans les fichiers de compte-rendu

local llResult
llResult = .t.

* {fr} Ajouter au log texte
if not empty(this.acTxtLogAddr) and not empty(this.acLine)
	llResult = strtofile(CRLF + this.acLine, this.acTxtLogAddr, .t.) > 0
endif

* {fr} Ajouter au log table
if not empty(this.acDBFlogAddr)
	llResult = used(this.acDBFlogAlias) or this.DBFlogCreate()
	if m.llResult
		llResult = this.DBFlogAppend()
	endif
endif

return m.llResult

* -------------------------------------------------
procedure LineClear && {fr} Efface la ligne courante

local lnCol, lnWidth
for m.lnCol = 1 to alen(this.aaLog, 2)
	lnWidth = this.aaLog[L_nWIDTH, m.lnCol]
	lnWidth = iif(vartype(m.lnWidth)=='N', m.lnWidth, 0)
	this.aaLog[L_cDISPLAY, m.lnCol] = space(m.lnWidth)
	this.aaLog[L_uVALUE, m.lnCol] = .null.
endfor

this.acLine = ''

* -------------------------------------------------
procedure Warning && {fr} Affiche un avertissement dans une fenêtre "WAIT WINDOW", ajoute au compte-rendu des avertissements si nouveau
lparameters ;
  tcWarning as String; && {en} warning, empty for a new line {fr} Avertissement, vide pour nouvelle ligne
, lAppendNot as Boolean; && [.F.] {en} do not log warning {fr} Ne pas ajouter l'avertissement au compte-rendu
, lCallingAddNot as Boolean; && [.F.] {en} do not add calling program name as header {fr} ne pas ajouter le nom du programme appelant en-tête

local llResult as Boolean;
, llWarnNew;
, lcWarning;
, lcCallingModule;


* {fr} Si avertissement non vide
if .t.;
 and vartype(m.tcWarning) == 'C';
 and not empty(m.tcWarning)

	tcWarning = alltrim(m.tcWarning)

	* {fr} Si nouvel avertissement
	lcCallingModule = cTronc(lower(cCallingModule()), 20)
	lcWarning = Iif(lTrue(m.lCallingAddNot), '', padr(m.lcCallingModule, 20) ) + m.tcWarning
	llWarnNew = not upper(Chrtran(m.lcWarning, '0123456789', '')) $ upper(Chrtran(m.this.acWarnings, '0123456789', '')) && {fr} comparer en ignorant les chiffres
	if m.llWarnNew

	* {fr} Display warning
		wait window cTronc('Module ' + m.lcCallingModule + ' : ' + m.tcWarning, 254) nowait
	*			?? Chr(7)
	endif

else && {fr} blank line

	* {fr} Clear warning
	wait clear
	llWarnNew = .t.
	lcWarning = ''

endif

* {fr} If requested, Append Warning to Log
if m.llWarnNew and not (lTrue(m.lAppendNot))

	lcWarning = CRLF + m.lcWarning
	this.acWarnings = m.this.acWarnings + m.lcWarning
	this.anWarnings = m.this.anWarnings + 1
	llResult = strtofile(m.lcWarning, m.this.acWarnTxtLogAddr, .t.) > 0
else
	llResult = .t.
endif

return m.llResult

* -------------------------------------------------
function cSepLine && {fr} Ligne séparatrice horizontale
lparameters tlLeftBars && [.F.] {fr} Tracer une barre verticale au début de la nouvelle ligne

local lnCol, lnColWidth, llLeftBar, lcResult

lcResult = ''
for m.lnCol = 1 to alen(this.aaLog, 2)

	llLeftBar = m.tlLeftBars and this.aaLog[L_lBORDER, m.lnCol]
	lnColWidth = this.nColWidthTotal(m.lnCol)
	llResult = 	vartype(m.lnColWidth) = 'N' and m.lnColWidth > 0
	if m.llResult

		lcResult = m.lcResult + ;
						iif(m.llLeftBar, '|', '-') + ;
						replicate('-', m.lnColWidth - 1)
	else
		exit
	endif
endfor

return iif(m.llResult, m.lcResult + iif(m.llLeftBar, '|', '-'), '')

* -------------------------------------------------
procedure DBFlogCreate && {fr} Crée la table de compte-rendu

local lcFields, lnCol;
, lcFieldName, lcFieldType, lnFieldLength, lcFieldExp;
, lnSelect, llResult

if m.this.anCols > 0

	lcFields = ''
	for m.lnCol = 1 to this.anCols
		lcFieldName = cVFPname (this.aaLog[L_cHEADER, m.lnCol], 10)
		lcFieldType = uDefault(alltrim(this.aaLog[L_cTYPE, m.lnCol]), 'C')
		lcFieldType = evl(m.lcFieldType, 'C')
		lnFieldLength = this.aaLog[L_nWIDTH, m.lnCol]
		lcFieldExp = cFieldExp(m.lcFieldName, m.lcFieldType, m.lnFieldLength,,.t.)
		llResult = not empty(m.lcFieldExp)
		if m.llResult
			lcFields = c2Words(m.lcFields, ',', m.lcFieldExp)
		else
			exit
		endif
	endfor
	if m.llResult

		lcFields = '(' + m.lcFields + ')'
		lnSelect = select(0)
		create table (this.acDBFlogAddr) free &lcFields
		use
		this.LogCheck(this.acDBFlogAddr)
		use (this.acDBFlogAddr) alias (this.acDBFlogAlias) exclusive
		select (m.lnSelect)
	endif
endif

return m.llResult

* -------------------------------------------------
procedure DBFlogAppend && {fr} Sauve la ligne courante du tableau dans la table de compte-rendu

local lnCols, llResult

lnCols = alen(this.aaLog, 2)
llResult = m.lnCols > 0 and used(this.acDBFlogAlias)
if m.llResult

	* {fr} Tabuler les champs de la table de log
	local array laFields[1]
	afields(laFields, this.acDBFlogAlias)

	* {fr} Pour chaque colonne
	local llAllEmpty, lnCol, lcFieldName, luFieldValue, lcFieldType, lnFieldLength, lcFieldExp, lnField, lcAlter
	llAllEmpty = .t.
	lcAlter = ''
	for lnCol = 1 to m.lnCols

		* {fr} Déterminer les caractéristiques du champ pouvant contenir la donnée
		lcFieldName = cVFPname(this.aaLog[L_cID, m.lnCol], 10)
		luFieldValue = this.aaLog[L_uVALUE, m.lnCol]
		lcFieldType = this.aaLog[L_cTYPE, m.lnCol]
		lnFieldLength = this.aaLog[L_nWIDTH, m.lnCol]
		if vartype(m.lcFieldType) = 'C' ;
		 and not empty(m.lcFieldType) ;
		 and vartype(m.lnFieldLength) = 'N' ;
		 and not empty(m.lnFieldLength)
			lcFieldExp = cFieldExp(m.lcFieldName, m.lcFieldType, m.lnFieldLength,,.t.)
			lnField = ascan(laFields, m.lcFieldName, 1, -1, 1, 1+2+4+8)

			* {fr} Si le champ n'existe pas
			if m.lnField = 0

				lcAlter = lcAlter + ' ADD COLUMN ' + m.lcFieldExp

			* {fr} Sinon (le champ existe)
			else

				* {fr} Si le champ n'est pas de le bonne taille ou type
				if not m.lcFieldType $ VFP7_FIELD_TYPES_FIXED_LEN ;
				 and laFields[m.lnField, 3] < m.lnFieldLength ;
				 or not laFields[m.lnField, 2] == m.lcFieldType

					lcAlter = lcAlter + ' ALTER COLUMN ' + m.lcFieldExp
				endif
			endif

			llAllEmpty = m.llAllEmpty and (empty(m.luFieldValue) or isNull(m.luFieldValue))
		endif

		local (m.lcFieldName)
		store m.luFieldValue to (m.lcFieldName) && {fr} pour GATHER MEMVAR plus loin
	endfor

	* {fr} S'il faut changer la structure de la table
	if not empty(m.lcAlter)
		llResult = used(ExclusiveForce(this.acDBFlogAlias))
		if m.llResult
			lcAlter = 'ALTER TABLE ' + cLitteral(this.acDBFlogAlias) + m.lcAlter
			&lcAlter
			use in (this.acDBFlogAlias)
			use (this.acDBFlogAddr) in 0 shared alias (this.acDBFlogAlias)
		endif
	endif

	if m.llResult and not m.llAllEmpty

		local loSelect
		loSelect = createobject('abSelect', this.acDBFlogAlias)
		append blank
		gather memvar
	endif
endif

return m.llResult

* -------------------------------------------------
procedure FooterCreate && {fr} Crée un pied de tableau avec totaux ou moyennes

* {fr} En cas d'interruption anormale, vider la ligne en cours
if not empty(m.this.acLine)
	this.LineFeed
endif

* {fr} Si au moins une ligne de données
if m.this.anCols * m.this.anDataLines > 0

	* {fr} Tracer une ligne pour fermer le tableau
	this.acLine = this.cSepLine()
	this.lineShow()

	* {fr} Si un pied de tableau a été demandé
	if m.this.alFooter
		this.LineFeed()

		local lnCol, lnSum, luSum, llFooter, llTitle

		* {fr} Pour chaque colonne
		for m.lnCol = 1 to this.anCols
			lnSum = this.aaLog[L_nSUM, m.lnCol]
			luSum = this.aaLog[L_lSUM, m.lnCol]

			* {fr} Si la colonne contient un total et qu'un bilan est demandé
			if m.lnSum > 0 and not isNull(m.luSum) && .NULL.: ne rien faire, ni total ni moyenne
				this.CellFill(m.lnCol, m.lnSum / iif(m.luSum, 1, m.this.anDataLines))
				llFooter = .t.
			else
				if not m.llTitle
					llTitle = this.CellFill(;
							m.lnCol;
						, textmerge(icase(;
								cLangUser() = 'fr',	[Totaux / moyennes des <<m.this.anDataLines>> lignes],; && copy-paste this line to add another language support
																		[Total / averages of <<m.this.anDataLines>> lines]; && default: English
							));
						, .t.;
						)
				endif
			endif
		endfor

		* {fr} Si le pied d'état a été créé, le sortir
		if m.llFooter
			this.LineFeed(.t.)
		endif
	endif
endif

* -------------------
enddefine && {fr} CLASS cusBatchLog as Custom

* -----------------------------------------------------
procedure cusBatchLog_Test
local lcSys16
lcSys16 = sys(16,1)
? m.lcSys16
local loBatchLog, lnPos
loBatchLog = createobject('cusBatchLog', addbs(sys(2023)) + 'test')
with m.loBatchLog
	.LineFill('Ceci va commencer le test ...')
	lnPos = .LineAppend('Première étape')
	wait 'Test de cusBatchLog en cours ...' window timeout 3
	.LineAppend('OK', m.lnPos)
	.ColAdd('First column', 18)
	.ColAdd('Second column', 25)
	.ColAdd('Third column', 15, .t.)
	.ColAdd('Fourth column', 15)
	.LineFeed(.t.)
	.LineDisplay(.t.)
	.LineFeed(.t.)
	.CellFill(1, datetime())
	.CellFill(2, 'Thierry Nivelet')
	.CellFill(3, 524.25)
	.CellFill(4, .f.)
	.LineFeed(.t.)
	.CellFill(1, datetime())
	.CellFill(2, 'Thierry Nivelet is a poor developper', .t.)
	.CellFill(3, 524.25)
	.CellFill(4, .f.)
	.LineFeed(.t.)
	.Warning('Warning test OK')
endwith

* ========================================
function cModuleInfo && {fr} Nom, Chemin ou Adresse d'un module d'après Sys(16)
lparameters ;
  tcSys16; && {fr} Chaîne obtenue par Sys(16)
, tcInfo; && ['N'] {N}ame, {A}ddress, {P}ath, {O}bject, {S}ys16, {L}ignée, {F}ull lignée
, tlCase && [.F.] {fr} Respecter la casse sur disque

tcInfo = iif(vartype(m.tcInfo) = 'C' and not empty(m.tcInfo), upper(left(ltrim(m.tcInfo), 1)), 'N')
tcInfo = iif(m.tcInfo $ 'NAPSOLF', m.tcInfo, 'N')
tlCase = lTrue(m.tlCase)

local llProc, lcAddr, lcProc, laMembers[1], lnMembers, llMethod;
, llResult, lcResult

lcResult = ''

* {fr} Si le paramètre requis est valide
llResult = vartype(m.tcSys16) = 'C'
assert m.llResult message cAssertMsg(textmerge([Invalid Sys(16) Information : <<cLitteral(m.tcSys16)>>]))
if m.llResult and not upper(left(m.tcSys16, 2)) == 'ON' && {fr} ON ...

 	* {fr} Repérer le nom de la procédure et l'adresse du fichier dans la chaine sys(16)
 	llProc = left(upper(m.tcSys16), lenc('PROCEDURE ')) == 'PROCEDURE '
 	lcAddr = iif(m.llProc;
 		, substr(m.tcSys16, atc(' ', m.tcSys16, 2) + 1); && {fr} GetWordNum() ne fonctionne pas si l'adresse contient des espaces
 		, m.tcSys16;
 		)
 	lcAddr = iif(m.tlCase, cFileCased(m.lcAddr), m.lcAddr)
 	lcProc = iif(m.llProc, getwordnum(m.tcSys16, 2), juststem(m.lcAddr))
 	llMethod = '.' $ m.lcProc
 	if m.llMethod
	 	lnMembers = alines(laMembers, m.lcProc, 1, '.')
 	else
 		llResult = not m.tcInfo $ 'OLF'
		assert m.llResult message cAssertMsg(textmerge([Invalid Information Type Specification : '<<m.tcInfo>>']))
 	endif
 	if m.llResult

	 	return icase(;
	 		m.tcInfo == 'N',; && {fr} Procedure name (with object name if method)
		 		iif(m.llMethod;
		 			, laMembers[m.lnMembers-1] + iif(empty(laMembers[m.lnMembers-1]) or empty(laMembers[m.lnMembers]), '', '.') + laMembers[m.lnMembers];
		 			, m.lcProc;
		 			),;
		 	m.tcInfo == 'A',; && {fr} Procedure file address
		 		m.lcAddr,;
		 	m.tcInfo == 'P',; && {fr} Procedure file path
		 		addbs(justpath(m.lcAddr)),;
		 	m.tcInfo == 'S',; && {fr} Procedure file address
		 		m.tcSys16,;
		 	m.tcInfo == 'O',; && {fr} Object name
		 		laMembers[m.lnMembers-1],;
		 	m.tcInfo == 'L',; && {fr} Lignée des objets
		 		leftc(m.lcProc, ratc('.', m.lcProc)-1),;
		 	m.tcInfo == 'F',; && {fr} Lignée complète de la méthode
		 		m.lcProc,;
		 		'';
		 	)
 	endif
endif

return m.lcResult

* ------------------------------------
procedure cModuleInfo_Test && {fr} Test cModuleInfo()
&& {fr} cf 'cModuleInfo_Test.prg' pour test par programme

local loUnitTest as abUnitTest of abDev.prg, lcSys16, loClassTest
loUnitTest = newobject('abUnitTest', 'abDev.prg')
lcSys16 = sys(16) && {fr} module courant

loUnitTest.Test('CMODULEINFO_TEST', m.lcSys16, 'Name')
loUnitTest.Test(upper(DOS_AB), m.lcSys16, 'Path')
loUnitTest.Test(upper(DOS_AB) + 'ABDEV.FXP', m.lcSys16, 'Address')

loClassTest = createobject('cusModuleInfo_Test', m.loUnitTest)

return loUnitTest.result()

* --------------------------------------
define class cusModuleInfo_Test as custom && {fr} Teste cModuleInfo() au sein d'une classe
		procedure init
		lparameters toUnitTest
		local lcSys16
		lcSys16 = sys(16) && {fr} module courant
		toUnitTest.Test('CUSMODULEINFO_TEST.INIT', m.lcSys16, 'Name')
		toUnitTest.Test(upper(DOS_AB), m.lcSys16, 'Path')
		toUnitTest.Test(upper(DOS_AB) + 'ABDEV.FXP', m.lcSys16, 'Address')
	enddefine

* ========================================
function cCallingModule && {fr} Nom du module appelant (programme, procédure, méthode, ...)
lparameters ;
  tcAddress; && @ [''] {fr} Adresse du fichier où se trouve le module appelant
, tnStackUp && [0] {fr} nombre de niveaux avant le module appelant

local lnLevelHere, lcSys16, lcResult

lcResult = ''

* {fr} Si ce module est appelé par un module appelé
lnLevelHere = program(-1) && {en} current program level
if m.lnLevelHere > 2

	lcSys16 = sys(16, m.lnLevelHere - 2 - abs(evl(m.tnStackUp, 0)))

	tcAddress = cModuleInfo(m.lcSys16, 'Address')
	lcResult = cModuleInfo(m.lcSys16, 'Name')
endif

return m.lcResult

* ------------------------------------
procedure cCallingModule_Test

local loUnitTest as abUnitTest of abDev.prg;
, lcSys16, lcSys16module, lcSys16address;
, lcModule, lcAddress;
, loTest as cCallingModule_Test3 of abDev.prg;

loUnitTest = newobject('abUnitTest', 'abDev.prg')

lcSys16 = sys(16)
lcSys16module = upper(cModuleInfo(m.lcSys16, 'Name'))
lcSys16address = upper(cModuleInfo(m.lcSys16, 'Address'))

lcModule = cCallingModule_Test1(@m.lcAddress)

? upper(m.lcModule) == m.lcSys16module
? upper(m.lcAddress) == m.lcSys16address


lcModule = cCallingModule_Test2(@m.lcAddress, -1)

? upper(m.lcModule) == m.lcSys16module
? upper(m.lcAddress) == m.lcSys16address

loTest = newobject('cCallingModule_Test3', 'abDev.prg')
lcModule = loTest.Test(@m.lcAddress, -1)

? upper(m.lcModule) == m.lcSys16module
? upper(m.lcAddress) == m.lcSys16address

	* ------------------------------------
	procedure cCallingModule_Test1
	lparameters tcAddress, tnStackUp
	return cCallingModule(@m.tcAddress, m.tnStackUp)

	* ------------------------------------
	procedure cCallingModule_Test2
	lparameters tcAddress, tnStackUp
	return cCallingModule_Test1(@m.tcAddress, m.tnStackUp)

	* ------------------------------------
	define class cCallingModule_Test3 as relation
		procedure Test
		lparameters tcAddress, tnStackUp
		return cCallingModule_Test1(@m.tcAddress, m.tnStackUp)
		enddefine

* ========================================
function cCallingModules && {en} Calling Modules {fr} Modules appelants
lparameters ;
  tlCurrent; && [.F.] {en} Include current module's name {fr} Inclure le nom du module courant
, tcInfo; && [Name] {en} 'Name', 'Address', 'Path', 'Object' or 'Line up'
, tlLineNum; && [.F.] {en} Add Line number in the object source file

tcInfo = Upper(Left(Ltrim(Evl(m.tcInfo, 'Name')), 1))
tlLineNum = lTrue(m.tlLineNum)

local lcResult;
, aa[1]; && [1- Call Stack Level, 2- Current program filename, 3- Module or Object name, 4- Module or Object Source filename, 5- Line number in the object source file, 6- Source line contents]
, liStack, lnStack;
, lnDigit;
, llWeb;

lcResult = ''

lnStack = Iif(m.tlLineNum;
  , AStackInfo(aa); && The value returned is the number of program levels or rows of the returned array.
  , program(-1);
  ) - iif(lTrue(m.tlCurrent), 1, 2)
lnDigit = ICase(m.lnStack < 10, 1, m.lnStack < 100, 2, 3)
llWeb = wlWeb()

for liStack = 1 to m.lnStack
	lcResult = m.lcResult;
		+ ' > ';
		+ padl(m.liStack, m.lnDigit, '0');
		+ Iif(llWeb, '&#160;', Chr(160));
		+ Iif(m.tlLineNum;
		  , m.aa[m.liStack, Iif(m.tcInfo == 'N', 3, 2)];
		  , cModuleInfo(Sys(16, m.liStack), m.tcInfo);
		  );
		+ Iif(m.tlLineNum;
		  , ' (' + Transform(Evl(m.aa[m.liStack, 5], 'N/A')) + ')';
		  , '';
		  );
		+ ''
endfor

return Lower(Ltrim(m.lcResult, ' ', '>'))
endfunc

* ========================================
function lCallingModule && {fr} Un module appelle le module appelant cette fonction
lparameters ;
  tcModule; && {fr} Module: [class][.]procedure
, tlModules; && [.F.] && {fr} appel depuis lCallingModules()

local llResult as Boolean;
, liLevelBase as integer;
, liLevelHere as integer;
, liLevel as integer;
, lcLevel as string;
, llMethod as Boolean;
, llClassMethod as Boolean;

if vartype(m.tcModule) == 'C' and not empty(m.tcModule)

	* {fr} Si ce module est appelé par un module appelé
	liLevelHere = program(-1) && {en} current program level
	liLevelBase = 2 + iif(lTrue(m.tlModules), 1, 0)
	if m.liLevelHere > m.liLevelBase

		tcModule = upper(alltrim(m.tcModule))
		llMethod = leftc(m.tcModule, 1) == '.'
		llClassMethod = !m.llMethod and '.' $ m.tcModule

		for m.liLevel = m.liLevelHere - m.liLevelBase to 1 step -1
			lcLevel = program(m.liLevel)

			if m.tcModule == ICase(;
				m.llMethod,;
					'.' + justext(m.lcLevel),;
				m.llClassMethod,;
					m.lcLevel,;
				'.' $ m.lcLevel,;
					justext(m.lcLevel),;
					 m.lcLevel;
				)
				llResult = .t.
				exit
			endif
		endfor
	endif
endif

return m.llResult

* ========================================
function lCallingModules && {fr} Plusieurs modules appellent le module appelant cette fonction
lparameters ;
  tcModules; && {fr} Modules
, tlOR; && [.F.] {fr} Au moins un module appelle le module

tlOR = lTrue(m.tlOR)

local laModules[1], lcModule, llResult
llResult = vartype(m.tcModules) == 'C' and alines(laModules, upper(m.tcModules), 1+4, ',', ';') > 0
if m.llResult

	for each lcModule in laModules

		if m.tlOR
			llResult = lCallingModule(m.lcModule, .t.)
			if m.llResult
				exit
			endif
		else
			llResult = lCallingModule(m.lcModule, .t.) and m.llResult
			if not m.llResult
				exit
			endif
		endif
	endfor
endif

return m.llResult

* ========================================
function lUserEventCalling && {fr} Un événement utilisateur appelle cette fonction
lparameters tcClassStart && {fr} Classe à partir de laquelle chercher dans la pile d'appel si elle s'y trouve

local success as Boolean;
, laStack[1] as string;
, lnStack as integer;
, liStack as integer;
, lClassStart as Boolean;
, lcEvent as string;
, liEvent as integer;

lnStack = astackinfo(m.laStack)
if m.lnStack > 0 && {fr} should always be .T.

	tcClassStart = lower(evl(m.tcClassStart, ''))
	lClassStart = !empty(m.tcClassStart)
	for liStack = m.lnStack to 1 step -1
		if m.lClassStart and lower(getwordnum(laStack[m.liStack, 3], 1, '.')) == m.tcClassStart
* {fr} liStack = Aelement(m.laStack, m.liStack, 3)
			exit
		endif
		laStack[m.liStack, 3] = getwordnum(laStack[m.liStack, 3], getwordcount(laStack[m.liStack, 3], '.'), '.') && {fr} Module or Object name
	endfor
	liStack = evl(m.liStack, 1)
	text to lcEvent noshow flags 1 pretext 3 && {fr} could be rearranged for optimization (most frequent events first)
		Activate
		Afterdock
		AfterRowColChange
		BeforeDock
		BeforeRowColChange
		Click
		DblClick
		Deleted
		DownClick
		DragDrop
		DragOver
		DropDown
		GotFocus
		InteractiveChange
		KeyPress
		LostFocus
		MiddleClick
		MouseDown
		MouseEnter
		MouseLeave
		MouseMove
		MouseUp
		MouseWheel
		Moved
		OLECompleteDrag
		OLEDragOver
		OLEGiveFeedback
		OLESetData
		OLEStartDrag
		OnMoveItem
		QueryUnload
		RangeHigh
		RangeLow
		Resize
		RightClick
		Scrolled
		Timer
		UnDock
		UpClick
		Valid
		When
	ENDTEXT
	for liEvent = 1 to getwordcount(m.lcEvent, CRLF)
		if ascan(m.laStack, getwordnum(m.lcEvent, m.liEvent, CRLF), m.liStack, -1, 3, 7) > 0
			success = .t.
			exit
		endif
	endfor
endif

return m.success

* ------------------------------------
procedure lUserEventCalling_Test && {fr} Teste lUserEventCalling()

local loUnitTest as abUnitTest of abDev.prg
loUnitTest = newobject('abUnitTest', 'abDev.prg')

loUnitTest.Test(.f.)
loUnitTest.Test(.f., 'abUnitTest')

return m.loUnitTest.result()

* ========================================
function uDefault && {fr} Valeur par défaut d'un paramètre /!\ .T. non supporté
lparameters ;
  tuParm; && {fr} Paramètre dont il faut régler la valeur par défaut
, tuDefault && {fr} Valeur par défaut /!\ .T. non supporté

local lcType, luResult
luResult = .null.

* {fr} Si deux paramètres ont été passés
if pcount() = 2

	* {fr} Si la valeur par défaut est supportée
	lcType = vartype(m.tuDefault)
	if not (m.lcType == 'L' and m.tuDefault)

		* {fr} Si le paramètre est du type de la valeur par défaut, le retourner, sinon retourner la valeur par défaut
		luResult = iif(vartype(m.tuParm) == m.lcType, m.tuParm, m.tuDefault)
	else
		assert .f. message cAssertMsg(textmerge([<<Proper(Program())>> ne supporte pas la valeur par défaut .T. comme second paramètre]))
	endif
endif

return m.luResult

* ------------------------------------
procedure uDefault_Test && {fr} Teste uDefault()

local loUnitTest as abUnitTest of abDev.prg
loUnitTest = newobject('abUnitTest', 'abDev.prg')

loUnitTest.Test('Name', .f., 'Name')
loUnitTest.Test('Name', 0, 'Name')
loUnitTest.Test('Name', createobject('form'), 'Name')

local loAsserts as abSet of abDev.prg
loAsserts = abSet('Asserts', 'OFF')
loUnitTest.Test(.null., 0, .t.)

return loUnitTest.result()

* ==================================
define class abMachineInfo as GA_LIGHTWEIGHT_CLASS of abGA.prg && {fr} Informations sur la machine : processeur, mémoire, etc.

* {fr} Système
nOEMid = 0
nPageSize = 0
nAppAddrMin = 0
nAppAddrMax = 0
nProcessorMask = 0
nProcessors = 0
nProcessorType = 0
cProcessorName = ''
nAllocationGranularity = 0
nReserved = 0

* {fr} Mémoire
nMemLoad = 0
nMemPhysTot = 0
nMemPhysAvail = 0
nPageFileTot = 0
nPageFileAvail = 0
nMemVirtualTot = 0
nMemVirtualAvail = 0

* {fr} Processeur
nAddressWidth = 0
nArchitecture = 0
nAvailability = 0
nCpuStatus = 0
nCurrentClockSpeed = 0
nDataWidth = 0
cDescription = ''
cDeviceID = ''
nExtClock = 0
nFamily = 0
nL2CacheSize = 0
nL2CacheSpeed = 0
nLevel = 0
nLoadPercentage = 0
cManufacturer = ''
nMaxClockSpeed = 0
cProcessorFullName = ''
cPNPDeviceID = ''
cProcessorID = ''
nProcessorType = 0
nRevision = 0
cRole = ''
cSocketDesignation = ''
nStatusInfo = 0
cStepping = ''
cUniqueId = ''
nUpgradeMethod = 0
cVersion = ''
nVoltageCaps = 0

* ------------------------------------
procedure Init
lparameters tlAllInfo
if lTrue(m.tlAllInfo)
	this.SystemInfo
	this.ProcessorInfo
	this.MemoryInfo
endif
return DoDefault()

* ------------------------------------
procedure SystemInfo && {fr} Peuple les informations système

 local lcSysInfo

 declare GetSystemInfo in win32API string @lcSystemInfo
 lcSysInfo = space(36)
 GetSystemInfo(@m.lcSysInfo)

 this.nOEMid = StrToLong(left(m.lcSysInfo, 4))
 this.nPageSize = StrToLong(substr(m.lcSysInfo, 5, 4))
 this.nAppAddrMin = StrToLong(substr(m.lcSysInfo, 9, 4))
 this.nAppAddrMax = StrToLong(substr(m.lcSysInfo, 13, 4))
 this.nProcessorMask = StrToLong(substr(m.lcSysInfo, 17, 4))
 this.nProcessors = int(StrToLong(substr(m.lcSysInfo, 21, 4)))
 this.nProcessorType = StrToLong(substr(m.lcSysInfo, 25, 4))
 this.nAllocationGranularity = StrToLong(substr(m.lcSysInfo, 29, 4))
 this.nReserved = StrToLong(substr(m.lcSysInfo, 33, 4))

 #define PROCESSOR_INTEL_386 386
 #define PROCESSOR_INTEL_486 486
 #define PROCESSOR_INTEL_PENTIUM 586
 #define PROCESSOR_MIPS_R4000 4000
 #define PROCESSOR_ALPHA_21064 21064
 do case
 case this.nProcessorType = PROCESSOR_INTEL_386
    this.cProcessorName = "INTEL 386"
 case this.nProcessorType = PROCESSOR_INTEL_486
    this.cProcessorName = "INTEL 486"
 case this.nProcessorType = PROCESSOR_INTEL_PENTIUM
    this.cProcessorName = "INTEL Pentium"
 case this.nProcessorType = PROCESSOR_MIPS_R4000
    this.cProcessorName = "MIPS R4000"
 case this.nProcessorType = PROCESSOR_ALPHA_21064
    this.cProcessorName = "ALPHA 21064"
 endcase
endproc

* ------------------------------------
procedure MemoryInfo && {fr} Peuple les informations mémoire

 local lcMemStat

 declare GlobalMemoryStatusEx in win32API string @lcMemStat && 2017-12-14 -- http://www.tek-tips.com/viewthread.cfm?qid=1443657
 lcMemStat = longToStr(64) + Replicate(Chr(0), 60)
 GlobalMemoryStatusEx(@m.lcMemStat)

 this.nMemLoad = StrToDlong(substr(m.lcMemStat, 5, 4))
 this.nMemPhysTot = StrToDlong(substr(m.lcMemStat, 9, 8))
 this.nMemPhysAvail = StrToDlong(substr(m.lcMemStat, 17, 8))
 this.nPageFileTot = StrToDlong(substr(m.lcMemStat, 25, 8))
 this.nPageFileAvail = StrToDlong(substr(m.lcMemStat, 33, 8))
 this.nMemVirtualTot = StrToDlong(substr(m.lcMemStat, 41, 8))
 this.nMemVirtualAvail = StrToDlong(substr(m.lcMemStat, 49, 8)) && 57
endproc

* ------------------------------------
procedure ProcessorInfo && {fr} Peuple les informations sur le processeur

local loWMIService, loItems, loItem
loWMIService = getobject("winmgmts:\\.\root\cimv2")
loItems = loWMIService.ExecQuery("Select * from Win32_Processor")

for each loItem in loItems
	this.nAddressWidth = loItem.AddressWidth
	this.nArchitecture = loItem.Architecture
	this.nAvailability = loItem.Availability
	this.nCpuStatus = loItem.CpuStatus
	this.nCurrentClockSpeed = loItem.CurrentClockSpeed
	this.nDataWidth = loItem.DataWidth
	this.cDescription = alltrim(loItem.description)
	this.cDeviceID = alltrim(loItem.DeviceID)
	this.nExtClock = loItem.ExtClock
	this.nFamily = loItem.Family
	this.nL2CacheSize = loItem.L2CacheSize
	this.nL2CacheSpeed = loItem.L2CacheSpeed
	this.nLevel = loItem.level
	this.nLoadPercentage = loItem.LoadPercentage
	this.cManufacturer = alltrim(loItem.Manufacturer)
	this.nMaxClockSpeed = loItem.MaxClockSpeed
	this.cProcessorFullName = alltrim(loItem.name)
	this.cPNPDeviceID = loItem.PNPDeviceID
	this.cProcessorID = alltrim(loItem.ProcessorId)
	this.nProcessorType = loItem.ProcessorType
	this.nRevision = loItem.Revision
	this.cRole = alltrim(loItem.Role)
	this.cSocketDesignation = alltrim(loItem.SocketDesignation)
	this.nStatusInfo = loItem.StatusInfo
	this.cStepping = alltrim(loItem.Stepping)
	this.cUniqueId = alltrim(loItem.UniqueId)
	this.nUpgradeMethod = loItem.UpgradeMethod
	this.cVersion = alltrim(loItem.version)
	this.nVoltageCaps = loItem.VoltageCaps
endfor
endproc

enddefine && {fr} CLASS abMachineInfo

* ==================================
procedure abMachineInfo_Test && {fr} Teste abMachineInfo

local lnSeconds, loMI as abMachineInfo of abDev.prg
loMI = createobject('abMachineInfo')

#define MEM_DISP_FORMAT '9 999 999 999'

lnSeconds = seconds()
loMI.SystemInfo()
lnSeconds = seconds() - m.lnSeconds
messagebox(;
	"Informations Système:" + CR + ;
	"- Identifiant OEM: " + transform(m.loMI.nOEMid) + CR + ;
  "- Taille de page : " + transform(m.loMI.nPageSize) + CR + ;
  "- Adresse application minimum : " + transform(m.loMI.nAppAddrMin, MEM_DISP_FORMAT) + CR +;
  "- Adresse application maximum : " + transform(m.loMI.nAppAddrMax, MEM_DISP_FORMAT) + CR + ;
  "- Masque de processeur: " + transform(m.loMI.nProcessorMask) + CR + ;
  "- Nombre de processeurs: " + transform(m.loMI.nProcessors) + CR + ;
  "- Nom du processeur : " + m.loMI.cProcessorName + CR + ;
  "- Granularité d'allocation (NDR?): " + transform(m.loMI.nAllocationGranularity) + CR + ;
  + CR + "Temps d'exécution : " + transform(m.lnSeconds) + " secondes" ;
 ,64)

lnSeconds = seconds()
loMI.MemoryInfo()
lnSeconds = seconds() - m.lnSeconds
messagebox(;
	"Informations Mémoire:" + CR + ;
  "- Mémoire utilisée : " + transform(m.loMI.nMemLoad) + '%' + CR + ;
  "- Mémoire physique totale : " + transform(m.loMI.nMemPhysTot, MEM_DISP_FORMAT) + " octets" + CR + ;
  "- Mémoire physique disponible : " + transform(m.loMI.nMemPhysAvail, MEM_DISP_FORMAT) + " octets" + CR + ;
  "- Mémoire paginée totale : " + transform(m.loMI.nPageFileTot, MEM_DISP_FORMAT) + " octets" + CR + ;
  "- Mémoire paginée disponible : " + transform(m.loMI.nPageFileAvail, MEM_DISP_FORMAT) + " octets" + CR + ;
  "- Mémoire virtuelle totale : " + transform(m.loMI.nMemVirtualTot, MEM_DISP_FORMAT) + " octets" + CR + ;
  "- Mémoire virtuelle disponible : " + transform(m.loMI.nMemVirtualAvail, MEM_DISP_FORMAT) + " octets" + CR + ;
  + CR + "Temps d'exécution : " + transform(m.lnSeconds) + " secondes" ;
 ,64)

lnSeconds = seconds()
loMI.ProcessorInfo()
lnSeconds = seconds() - m.lnSeconds
 messagebox(;
	"- Address Width : " + transform(m.loMI.nAddressWidth) + CR + ;
	"- Architecture : " + transform(m.loMI.nArchitecture) + CR + ;
	"- Availability : " + transform(m.loMI.nAvailability) + CR + ;
	"- CPU Status : " + transform(m.loMI.nCpuStatus) + CR + ;
	"- Current Clock Speed : " + transform(m.loMI.nCurrentClockSpeed) + CR + ;
	"- Data Width : " + transform(m.loMI.nDataWidth) + CR + ;
	"- Description : " + transform(m.loMI.cDescription) + CR + ;
	"- Device ID : " + transform(m.loMI.cDeviceID) + CR + ;
	"- Ext Clock : " + transform(m.loMI.nExtClock) + CR + ;
	"- Family : " + transform(m.loMI.nFamily) + CR + ;
	"- L2 Cache Size : " + transform(m.loMI.nL2CacheSize) + CR + ;
	"- L2 Cache Speed : " + transform(m.loMI.nL2CacheSpeed) + CR + ;
	"- Level : " + transform(m.loMI.nLevel) + CR + ;
	"- Load Percentage : " + transform(m.loMI.nLoadPercentage) + CR + ;
	"- Manufacturer : " + transform(m.loMI.cManufacturer) + CR + ;
	"- Maximum Clock Speed : " + transform(m.loMI.nMaxClockSpeed) + CR + ;
	"- Processor Full Name : " + transform(m.loMI.cProcessorFullName) + CR + ;
	"- PNP Device ID : " + transform(m.loMI.cPNPDeviceID) + CR + ;
	"- Processor Id : " + transform(m.loMI.cProcessorID) + CR + ;
	"- Processor Type : " + transform(m.loMI.nProcessorType) + CR + ;
	"- Revision : " + transform(m.loMI.nRevision) + CR + ;
	"- Role : " + transform(m.loMI.cRole) + CR + ;
	"- Socket Designation : " + transform(m.loMI.cSocketDesignation) + CR + ;
	"- Status Information : " + transform(m.loMI.nStatusInfo) + CR + ;
	"- Stepping : " + transform(m.loMI.cStepping) + CR + ;
	"- Unique Id : " + transform(m.loMI.cUniqueId) + CR + ;
	"- Upgrade Method : " + transform(m.loMI.nUpgradeMethod) + CR + ;
	"- Version : " + transform(m.loMI.cVersion) + CR + ;
	"- Voltage Caps : " + transform(m.loMI.nVoltageCaps)+ CR + ;
  + CR + "Temps d'exécution : " + transform(m.lnSeconds) + " secondes" ;
 ,64)

* ------------------------------------
function LongToStr && {fr} Représentation ASCII d'un entier 32 bits positif
lparameters tnLongVal && {fr} Entier 32 bits positif

local i, lnLongVal, lcResult

lcResult = ''
lnLongVal = m.tnLongVal
for i = 24 to 0 step -8
  lcResult = chr(int(m.lnLongVal/(2^m.i))) + m.lcResult
  lnLongVal = mod(m.lnLongVal, (2^m.i))
endfor

return lcResult

* ------------------------------------
function StrToLong && {fr} Entier 32 bits positif d'après sa représentation ASCII
lparameters tcLongStr && {fr} Représentation ASCII d'un entier 32 bits positif

local lnResult, i, lcLongStr
lnResult = 0
lcLongStr = m.tcLongStr
for i = 0 to 24 step 8
   lnResult = m.lnResult + (asc(m.lcLongStr) * (2^m.i))
   lcLongStr = right(m.lcLongStr, len(m.lcLongStr) - 1)
endfor

return lnResult

* ------------------------------------
function StrTodLong && {fr} Entier 64 bits positif d'après sa représentation ASCII
lparameters tcLongStr && {fr} Représentation ASCII d'un entier 64 bits positif

&& 2017-12-14 -- http://www.tek-tips.com/viewthread.cfm?qid=1443657
Local lnResult, lnPos
lnResult = 0
for lnPos = 8 TO 1 STEP -1
	lnResult = 256*m.lnResult + Asc(Substr(m.tcLongStr, m.lnPos,1))
next

return m.lnResult

* ------------------------------------
function cBarsSecs && {fr} Une barre pour 50 ms
lparameters tnSeconds && {fr} Nombre de secondes obtenu par différence de seconds()

if vartype(m.tnSeconds) == 'N' and m.tnSeconds >= 0
 	tnSeconds = m.tnSeconds * 1000 && {fr} ms

 	local lcBars
 	lcBars = replicate('=', min(int(m.tnSeconds / 50), 100)) && 1 barre = 50 ms, 5 secs max
 	return m.lcBars;
 		+ space(iif(empty(m.lcBars), 0, 1));
 		+ iif(m.tnSeconds = 0, '< 1', ltrim(transform(m.tnSeconds, '99 999')));
 		+ " ms"
else

	return ''
endif

* ------------------------------------
procedure ProjectFilesInclude && {fr} Change l'inclusion de fichiers dans le projet courant
lparameters ;
  tcFileMask; && [*.*] {fr} Expression régulière indiquant le masque de fichier à traiter
, tlInclude; && [.T.] .T.: Inclure, .F.: Exclure, .NULL. : Inverser
, tnResult; && @ {fr} Nombre de fichiers traités

tnResult = 0

local loProject, loProjectFiles, loRegExp as abRegExp of abTxt.prg, llResult

* {fr} Si un projet est actif
loProject = _vfp.activeproject
llResult = vartype(m.loProject) == 'O'
if m.llResult

	* {fr} Si le projet contient des fichiers
	loProjectFiles = m.loProject.files
	llResult = m.loProjectFiles.count > 0
	if m.llResult

		* {fr} Créer un objet 'Regular Expression'
		loRegExp = createobject('abRegExp')
		llResult = vartype(m.loRegExp) == 'O'
		if m.llResult

			* {fr} Donner leur valeur par défaut aux paramètres
			local lcCarsNot, lcFileMask, llInclude, loFile as file
			lcCarsNot = CAR_INT_DS_NOM_FICH
			lcFileMask = alltrim(uDefault(m.tcFileMask, textmerge('[^<<m.lcCarsNot>>]+\.[^<<m.lcCarsNot>>]+')))
			llInclude = iif(pcount() >=2 and vartype(m.tlInclude) $ 'LX', m.tlInclude, .t.)

			* {fr} Pour chaque fichier
			loRegExp.setup(m.lcFileMask, .t.)
			for each loFile in m.loProjectFiles

				* {fr} Si le nom du fichier correspond au masque
				if loRegExp.Test(justfname(m.loFile.name))

					* {fr} Changer son inclusion
					loFile.Exclude = not iif(isNull(m.llInclude), m.loFile.Exclude, m.llInclude)
					tnResult = m.tnResult + 1
				endif
			endfor
		endif
	endif
endif

return m.llResult

* ------------------------------------
procedure ProjectFilesRemove && {fr} Ôte des fichiers du projet courant
lparameters ;
  tcFileRegEx; && [*.*] {fr} Expression régulière indiquant le masque de fichier à traiter
, tnResult; && @ {fr} Nombre de fichiers traités
, tcFileType; && [''] {fr} déplacer vers cette section

tnResult = 0

local llResult;
, loProject as Project, loProjectFiles;
, loRegExp as abRegExp of abTxt.prg;
, lcCarsNot, lcFileMask, llInclude, loFile as file

* {fr} Si un projet est actif
loProject = _vfp.activeproject
llResult = vartype(m.loProject) == 'O'
if m.llResult

	* {fr} Si le projet contient des fichiers
	loProjectFiles = m.loProject.files
	llResult = m.loProjectFiles.count > 0
	if m.llResult

		* {fr} Créer un objet 'Regular Expression'
		loRegExp = abRegExp()
		llResult = vartype(m.loRegExp) == 'O'
		if m.llResult

			* {fr} Donner leur valeur par défaut aux paramètres
			lcCarsNot = CAR_INT_DS_NOM_FICH
			lcFileMask = alltrim(uDefault(m.tcFileRegEx, textmerge('[^<<m.lcCarsNot>>]+\.[^<<m.lcCarsNot>>]+')))
			llInclude = iif(pcount() >=2 and vartype(m.tlInclude) $ 'LX', m.tlInclude, .t.)
			tcFileType = Iif(ga_Type_IsChar(tcFileType, .T.) and varSet(@m.tcFileType, Alltrim(m.tcFileType)) and InList(m.tcFileType, FILETYPE_DATABASE,FILETYPE_FREETABLE,FILETYPE_QUERY,FILETYPE_FORM,FILETYPE_REPORT,FILETYPE_LABEL,FILETYPE_CLASSLIB,FILETYPE_PROGRAM,FILETYPE_APILIB,FILETYPE_APPLICATION,FILETYPE_MENU,FILETYPE_TEXT,FILETYPE_OTHER); && see foxpro.h
				, m.tcFileType;
				, .null.;
				)

			* {fr} Pour chaque fichier
			loRegExp.setup(m.lcFileMask, .t.)
			for each loFile in m.loProjectFiles

				* {fr} Si le nom du fichier correspond au masque
				if loRegExp.Test(justfname(m.loFile.name))

					if IsNull(m.tcFileType)
						* {fr} ôter le fichier
						loFile.remove
					else
						loFile.Type = m.tcFileType
					endif
					tnResult = m.tnResult + 1
				endif
			endfor
		endif
	endif
endif

return m.llResult


*========================================
function cVFPname	&& {fr} Nom valide pour VFP, avec longueur limitée si nécessaire
lparameters ;
  tcVFPname ; && {fr} Nom VFP à valider
, tnLength && [len(tcVFPname)] {fr} Longueur maximale du nom (par ex. 10 pour un nom de champ de table libre)

local lcResult
lcResult = ''

if vartype(m.tcVFPname) = 'C' ;
 and not empty(m.tcVFPname)

	* {fr} Remove accents
	local lcVFPname
	lcVFPname = cEuroANSI(alltrim(m.tcVFPname))

	* {fr} Start with '_' if first is a digit
	lcVFPname = iif(isdigit(m.lcVFPname), '_', '') + m.lcVFPname

	* {fr} Turn characters neither digit or letter to '_'
	local lnCar, lcCar
	for m.lnCar = 1 to len(m.lcVFPname)
		lcCar = substrc(m.lcVFPname, m.lnCar, 1)
		lcCar = iif(isdigit(m.lcCar) or isalpha(m.lcCar), m.lcCar, '_')
		lcResult = m.lcResult + upper(m.lcCar)
	endfor

	* {fr} Remove duplicate underscores
	lcResult = cRepCharDel(m.lcResult, '_')
	lcResult = iif(m.lcResult == '_', '', m.lcResult)

	* {fr} Trim right is required
	if vartype(m.tnLength) = 'N' ;
	 and m.tnLength > 0
		lcResult = leftc(m.lcResult, m.tnLength)
	endif
endif

return m.lcResult

* -----------------------------------------------------------------
procedure cVFPname_Test

local loUnitTest as abUnitTest of abDev.prg
loUnitTest = newobject('abUnitTest', 'abDev.prg')

loUnitTest.Test('_150', '150')
loUnitTest.Test('_CARTABLE_POIRE', '%cartable/poiré')
loUnitTest.Test('_2CARTABLE_POIRE', '2cartable.poiré')
loUnitTest.Test('_2CARTABLE_POIRE', '2cartable.:poiré')
loUnitTest.Test(leftc('_2CARTABLE_POIRE', 9), '2cartable.:poiré', 9)

return loUnitTest.result()

*========================================
function lVFPname	&& {fr} Nom valide pour VFP
lparameters tcVFPname && @ {fr} Nom VFP à valider

local llResult
#if .f.
use only letters, underscores, and numbers.
begin the name with a letter or underscore.
use 1 to 128 characters, except for field names in free tables and index tags — those can be 10 characters at most.
Avoid words reserved by visual foxpro.
#endif

llResult = vartype(m.tcVFPname) == 'C';
 and not empty(m.tcVFPname);
 and (left(m.tcVFPname, 1) == '_' or isalpha(m.tcVFPname));
 and empty(chrtran(upper(cEuroANSI(m.tcVFPname)), '_0123456789ABCDEFGHIJKLMONPQRSTUVWXYZ', ''));
 and len(m.tcVFPname) <= 128

if m.llResult
	tcVFPname = upper(m.tcVFPname)
endif

return m.llResult

* ====================
function lProcLine && {fr} Ligne de code VFP définissant une procédure / fonction
lparameters tcCodeLine && {fr} Ligne de code VFP

local llResult;
, lcCodeLine, lcWord1, lcWord2

llResult = vartype(m.tcCodeLine) == 'C'
assert m.llResult message cAssertMsg(textmerge([Invalid parameter type]))
if m.llResult

	lcCodeLine = upper(m.tcCodeLine)
	lcWord1 = left(getwordnum(m.lcCodeLine, 1), 4)
	return .F.;
		or m.lcWord1 $ 'PROC|FUNC';
		or m.lcWord1 $ 'PROT|HIDD' and left(getwordnum(m.lcCodeLine, 2), 4) $ 'PROC|FUNC'

endif

return m.llResult
endfunc

* ====================
function cProcType && {fr} Type de procédure / fonction défini dans une ligne
lparameters tcCodeLine && {fr} Ligne de code VFP

local lcCodeLine, lnProc, lnFunc, llParm, lcResult && 'P' ou 'F' ou vide si impossible de le définir

lcResult = ''
llParm = vartype(m.tcCodeLine) == 'C'
assert m.llParm message cAssertMsg(textmerge([Invalid parameter type]))
if m.llParm and lProcLine(m.tcCodeLine)

	lcCodeLine = ltrim(upper(m.tcCodeLine))
	lnProc = atc('PROC', m.lcCodeLine)
	lnFunc = atc('FUNC', m.lcCodeLine)

	lcResult = iif(m.lnProc > 0 and m.lnFunc > 0, iif(m.lnProc < m.lnFunc, 'P', 'F'), ;
									iif(m.lnProc > 0, 'P', 'F'))
endif

return m.lcResult

* ====================
function lCommandLine && {fr} Ligne de code VFP contenant une commande
lparameters tcCodeLine && {fr} Ligne de code VFP

local llResult

llResult = vartype(m.tcCodeLine) == 'C'
assert m.llResult message cAssertMsg(textmerge([Invalid parameter type]))
if m.llResult

	llResult = ;
			not lCommentLine(m.tcCodeLine) ;
		and not left(getwordnum(m.tcCodeLine, 1), 1) == '#' && {fr} directive de compilation
endif

return m.llResult

* ====================
function lCommentLine && {fr} Ligne de commentaire VFP
lparameters tcCodeLine && {fr} Ligne de code VFP
local llResult && {fr} c'est une ligne de commentaire

llResult = vartype(m.tcCodeLine) == 'C'
assert m.llResult message cAssertMsg(textmerge([Invalid parameter type]))
if m.llResult

	local lcWord1
	lcWord1 = getwordnum(m.tcCodeLine, 1)
	llResult = ;
					empty(m.tcCodeLine) ;
				or left(m.lcWord1, 1) == '*' ;
				or left(m.lcWord1, 2) == replicate('&', 2)
endif

return m.llResult

* ====================
function lSeparatorLine && {fr} Ligne de commentaire de séparation
lparameters tcCodeLine && {fr} Ligne de code VFP
local llResult && {fr} c'est une ligne de séparation

* {fr} Si le paramètre est correct
llResult = vartype(m.tcCodeLine) == 'C'
assert m.llResult message cAssertMsg(textmerge([Invalid parameter type]))
if m.llResult

	* {fr} si c'est une ligne de commentaire
	llResult = lCommentLine(m.tcCodeLine)
	if m.llResult

		* {fr} Si la ligne n'est pas vide
		llResult = empty(m.tcCodeLine)
		if not m.llResult

			* {fr} Si la ligne ne comporte aucune lettre ou chiffre
			local lnCar, lcCar
			for m.lnCar = 1 to lenc(m.tcCodeLine)
				lcCar = substrc(m.tcCodeLine, m.lnCar, 1)
				llResult = not (isalpha(m.lcCar) or isdigit(m.lcCar))
				if not m.llResult
					exit
				endif
			endfor
		endif
	endif
endif

return m.llResult

* ====================
function cLineComment && {fr} Commentaire dans une ligne de code
lparameters tcCodeLine && {fr} Ligne de code ; si @, retournée sans commentaire ni espaces

local lcResult; && {fr} Commentaire dans la ligne de code
, llResult;
, lnAt, lnAt_;

lcResult = ''

* {fr} Si la ligne de code est valide
tcCodeLine = cCodeLineClean(m.tcCodeLine) && {fr} Ligne de code sans caractères parasites
llResult = not isNull(m.tcCodeLine)
assert m.llResult message cAssertMsg(textmerge([Line de code invalide : <<m.tcCodeLine>>]))
if m.llResult

	* {fr} Si la ligne comporte un commentaire
	lnAt = at_c('*', Ltrim(m.tcCodeLine))
	if m.lnAt = 1
		lnAt_ = m.lnAt + 1
	else
		lnAt = at_c(replicate('&', 2), m.tcCodeLine)
		if m.lnAt > 0
			lnAt_ = m.lnAt + 2
		endif
	endif
	if m.lnAt > 0

		* {fr} Extraire le commentaire et le supprimer
		lcResult = m.tcCodeLine
		lcResult = alltrim(substrc(m.lcResult, m.lnAt_))
		lcResult = upper(substrc(m.lcResult, 1, 1)) + substrc(m.lcResult, 2) && {fr} capitalise le premier caractère
		tcCodeLine = substrc(m.tcCodeLine, 1, m.lnAt - 1) && {fr} Ligne sans le commentaire
	endif
endif

return m.lcResult

* --------------------
procedure cLineComment_Test && {fr} Teste cLineComment

local loUnitTest as abUnitTest of abDev.prg
loUnitTest = newobject('abUnitTest', 'abDev.prg')

local lcLine
lcLine = '      Procedure test ' + replicate('&', 2) + '   test réussi'
loUnitTest.Test('Test réussi', @m.lcLine)
loUnitTest.Assert('Procedure test', m.lcLine)

lcLine = '* Procedure test ' + replicate('&', 2) + '   test réussi'
loUnitTest.Test('Procedure test ' + replicate('&', 2) + ' test réussi', @m.lcLine)
loUnitTest.Assert('', m.lcLine)

return loUnitTest.result()

* ====================
function cCodeLineClean && {fr} Ligne de code sans caractères parasites
lparameters tcCodeLine && {fr} Ligne de code

local llResult

llResult = vartype(m.tcCodeLine)=='C'
assert m.llResult message cAssertMsg(textmerge([Function argument type is invalid : <<m.tcCodeLine>>]))
if m.llResult

	return	cRepCharDel(; && {fr} supprime les espaces répétés
						chrtran(ltrim(m.tcCodeLine), chr(9), space(1)); && {fr} remplace les tabs par des espaces
					)
else
	return .null.
endif

* ====================
function cCommentStripped && {fr} Code sans commentaires
lparameters ;
  tcInsts; && {fr} Instructions
, tlInLineCommentKeep

local laInst[1], lcInst, lcInst_, llCRLF;
, llResult, lcResult

lcResult = ''

llResult = vartype(m.tcInsts) == 'C'
assert m.llResult message cAssertMsg(textmerge([Invalid code block: <<m.tcInsts>>]))
if m.llResult

	if alines(laInst, m.tcInsts) > 0 && {fr} garder les espaces en début et fin de ligne

		llCRLF = rightc(m.tcInsts, 2) == CRLF
		for each lcInst in m.laInst

			lcInst_ = ltrim(m.lcInst, space(1), chr(9))
			lcResult = m.lcResult + iif(left(m.lcInst_, 1) == '*' or left(m.lcInst_, 2) == '&'+'&' or upper(left(m.lcInst_, 5)) == 'NOTE ';
				, '';
				, iif(m.tlInLineCommentKeep, m.lcInst, cInLineCommentStripped(m.lcInst)) + CRLF;
				)
		endfor

		lcResult = iif(m.llCRLF;
			, m.lcResult;
			, rtrim(m.lcResult, CR, LF);
			)
	endif
endif

return m.lcResult

* ====================
function cInLineCommentStripped && {fr} Instructions sans commentaire de ligne
lparameters ;
  tcInsts as string; && {fr} Instructions
, tcComment as string && @ {fr} Commentaires trouvés

tcComment = ''

local lcResult;
, llResult;
, liComment;
, liCR

lcResult = ''

* {fr} Si code valide
llResult = vartype(m.tcInsts) == 'C'
assert m.llResult message cAssertMsg(textmerge([Invalid Code: <<cL(m.tcInsts)>>]))
if m.llResult

	lcResult = m.tcInsts

	do while .t.

		liComment = at_c(replicate('&', 2), m.lcResult)
		if m.liComment > 0

			liCR = at_c(CR, substrc(m.lcResult, m.liComment))

			tcComment = m.tcComment;
				+ iif(empty(m.tcComment), '', CRLF);
				+ iif(m.liCR > 0;
					, substrc(m.tcInsts, m.liComment, m.liCR - m.liComment);
					, substrc(m.tcInsts, m.liComment);
					);

			lcResult = '';
				+ rtrim(substrc(m.lcResult, 1, m.liComment - 1), space(1), TABUL);
				+ iif(m.liCR > 0, substrc(m.lcResult, m.liComment + m.liCR-1), '')
		else
			exit
		endif
	enddo
endif

return m.lcResult

* ----------------------------
procedure cInLineCommentStripped_Test && {fr} Teste cInLineCommentStripped()

local loUnitTest as abUnitTest of abDev.prg, lcCode, lcComment, lcExpected

loUnitTest = newobject('abUnitTest', 'abDev.prg')

lcCode = [Moved &] + [& Occurs when an object is moved to a new position or a container object's Top or Left property settings have been changed programmatically]
loUnitTest.Test('Moved', m.lcCode, @m.lcComment)
loUnitTest.assert([&] + [& Occurs when an object is moved to a new position or a container object's Top or Left property settings have been changed programmatically], m.lcComment)

text TO lcCode NOSHOW FLAGS 1 PRETEXT 3
	MouseWheel && {fr} Occurs ...
	Moved && {fr} Occurs when an object is moved to a new position or a container object's Top or Left property settings have been changed programmatically
	OLECompleteDrag && {fr} Occurs ...
ENDTEXT

text TO lcExpected NOSHOW FLAGS 1 PRETEXT 3
	MouseWheel
	Moved
	OLECompleteDrag
ENDTEXT

loUnitTest.Test(m.lcExpected, m.lcCode)

return loUnitTest.result()

* ====================
function aInLineCommentsStripped && {fr} Lignes de code sans commentaires de ligne
lparameters taCodeLines && @ {fr} Lignes de code
external array taCodeLines

local lnCodeLine, llResult, lnResult
lnResult = 0

llResult = type('m.taCodeLines[1]') == 'C' and alen(m.taCodeLines, 2) = 0
assert m.llResult message program() + ' - Code Lines expected: ' + cLitteral(m.taCodeLines)
if m.llResult

	lnResult = alen(taCodeLines)
	for m.lnCodeLine = 1 to m.lnResult
		taCodeLines[m.lnCodeLine] = cInLineCommentStripped(taCodeLines[m.lnCodeLine])
	endfor
endif

return m.lnResult

* =================================================
function abON as abON of abDev.prg && {en} Saves and restores ON ...
lparameters ;
  tcSetting; && {fr} ON ... to be set
, tvValueNew && {fr} Value to set

return createobject('abON', m.tcSetting, m.tvValueNew)

* =================================================
define class abON as GA_LIGHTWEIGHT_CLASS of abGA.prg && {fr} Saves and restores ON ...
* =================================================

cSetting = ''
vValueOld = .null.

* ------------------------------------
procedure init
lparameters ;
  tcSetting; && {fr} ON ... to be set
, tvValueNew && {fr} Value to set

local llResult

try
	this.cSetting = m.tcSetting
	this.vValueOld = on(m.tcSetting)
	on &tcSetting &tvValueNew
	llResult = .t.
catch
endtry

return m.llResult

* ------------------------------------
procedure destroy

local lcSetting, lcValue

lcSetting = m.this.cSetting
lcValue = m.this.vValueOld

on &lcSetting &lcValue

* =================================================
enddefine && {fr} CLASS abOn
* =================================================

* =================================================
function labSet as Boolean && {en} abSet object created
lparameters ;
  toObj as abSet of abDev.prg,; && @ {en} abSet Object back
	tcSetting; && {en} Setting to perform
, tvValueNew; && {en} Value to set, .T. to toggle ON - OFF
, tnSetting; && {en} Setting number when appropriate for tcSetting, as of 2nd parameter of set()
, tlChangeAlways; && [.F.] {en} Change setting even if required value is current
, tlSupported && [.F.] {en} assume setting is supported (optimization)

toObj = abSet(m.tcSetting, m.tvValueNew, m.tnSetting, m.tlChangeAlways, m.tlSupported)

return vartype(m.toObj) == 'O'
endfunc

* =================================================
function abSet as abSet of abDev.prg && {en} abSet object
lparameters ;
  tcSetting; && {en} Setting to perform
, tvValueNew; && {en} Value to set, .T. to toggle ON - OFF
, tnSetting; && {en} Setting number when appropriate for tcSetting, as of 2nd parameter of set()
, tlChangeAlways; && [.F.] {en} Change setting even if required value is current
, tlSupported && [.F.] {en} assume setting is supported (optimization)

return createobject('abSet', m.tcSetting, m.tvValueNew, m.tnSetting, m.tlChangeAlways, m.tlSupported)

* =================================================
define class abSet as GA_LIGHTWEIGHT_CLASS of abGA.prg && {fr} Saves and restores SET ...
* =================================================

cSetting  = ''
cParm2    = ''
nSetting  = .null.
vValueOld = .null.
vValueNew = .null.
lOnOff = .f.

* ------------------------------------
protected procedure init && {en} If valid and supported, performs required environment setting
lparameters ;
  tcSetting; && {en} Setting to perform
, tvValueNew; && {en} Value to set, .T. to toggle ON <> OFF
, tnSetting; && {en} Setting number when appropriate for tcSetting, as of 2nd parameter of set(), eg Set("Alternate", 1) for FileName
, tlChangeAlways; && [.F.] {en} Change setting even if required value is current
, tlSupported && [.F.] {en} assume setting is supported (optimization)

if IsNull(m.tcSetting) && 2016-08-18 thn -- {en} added for just using this.set()
	this.cSetting = m.tcSetting
	return
endif

local success as Boolean;
, lnSetting;
, lvValueCur;
, lcTypeCur;
, lcTypeNew;
, llToggle

lnSetting = vartype(m.tnSetting) == 'N'

* {fr} If parameters are valid
success = ga_Type_IsChar(m.tcSetting, .t.)
assert m.success message cAssertMsg(textmerge([Invalid setting <<cLitteral(m.tcSetting)>>]))
if m.success

	success = .f.;
		or !m.lnSetting;
		or ga_Type_IsInteger(m.tnSetting) and between(m.tnSetting, 1, 4)
	assert m.success message cAssertMsg(textmerge([Invalid value <<cLitteral(m.tnSetting)>>]))
	if m.success

		tcSetting = upper(alltrim(m.tcSetting))
		this.nSetting = iif(m.lnSetting, m.tnSetting, .null.)
		this.cParm2 = iif(m.lnSetting, ',' + transform(m.tnSetting), '')

		* {fr} If setting is OK
		success = .t.;
			and (.f.;
				or lTrue(m.tlSupported);
				or vartype(m.tvValueNew) == 'C' and inlist(upper(alltrim(m.tvValueNew)), 'ON', 'OFF');
				or this.lSupported(m.tcSetting, m.this.cParm2); && {fr} supported
				);
			and this.get(@m.lvValueCur, m.tcSetting, m.this.cParm2) && {fr} current value can be read
		if m.success

			* {fr} If required value is valid
			lcTypeCur = vartype(m.lvValueCur)
			lcTypeNew = vartype(m.tvValueNew)
			llToggle = m.lcTypeNew == 'L' and m.tvValueNew
			success = m.llToggle or m.lcTypeNew == m.lcTypeCur
			assert m.success message cAssertMsg(textmerge([For setting '<<m.tcSetting>>', value <<cLitteral(m.tvValueNew)>> should be of type '<<m.lcTypeCur>>']))
			if m.success

				* {fr} Adjust value when appropriate
				tvValueNew = iif(m.tcSetting == 'DEFAULT', addbs(fullpath(m.tvValueNew)), m.tvValueNew)

				* {fr} If setting must be changed
				if .f.;
				 or m.llToggle;
				 or lTrue(m.tlChangeAlways);
				 or !luEqual(m.lvValueCur, m.tvValueNew,, .t.)

					this.lOnOff = m.lcTypeCur == 'C' and (m.lvValueCur == 'ON' or m.lvValueCur == 'OFF')

					* {fr} Toggle value if asked and appropriate
					if m.llToggle and m.this.lOnOff
						tvValueNew = iif(m.lvValueCur = 'ON', 'OFF', 'ON')
					endif

					* {fr} If new setting can be performed
					success = this.set(m.tcSetting, m.tvValueNew)
				endif
				if m.success

					* {fr} Persist current values to properties
					this.cSetting = m.tcSetting
					this.vValueOld = m.lvValueCur
					this.vValueNew = m.tvValueNew
				endif
			endif
		endif
	endif
endif

return m.success

* ------------------------------------
hidden function get && {fr} état courant d'un SET
lparameters lvResult, tcSetting, lcParm2

local llError, loError as exception

try
	lvResult = iif(m.tcSetting == 'DEFAULT';
		, set('DEFAULT') + curdir();
		, evaluate("Set('" + m.tcSetting + "'" + m.lcParm2 + ")");
		)

catch to loError
	llError = .t.
	assert .f. message cAssertMsg(textmerge([The requested setting cannot be read: <<"Set('" + m.tcSetting + "'" + m.lcParm2 + ")">> : <<cException(m.loError)>>]))

endtry

return !m.llError

* ------------------------------------
function set && {en} Saves current environment setting and changes to new value
&& {fr} public car appelé par abSets.Set()
lparameters ;
  tcSetting; && {en} Setting to work on - upper case, trimmed
, tvValueNew; && {en} Value to set

local llResult as Boolean;
, lcResult as string;
, lcSetting as string;

llResult = .t.
lcResult = ''
lcSetting = upper(left(m.tcSetting, 4))

do case

case m.this.lOnOff
	set &tcSetting &tvValueNew

case m.lcSetting == 'TEXT' and m.this.nSetting = 1
	tvValueNew = '"' + stuffc(m.tvValueNew, len(m.tvValueNew)/2 + 1, 0, '","') + '"'
	set textmerge delimiters to &tvValueNew

case m.lcSetting == 'PROC'
	llResult = setProcedure(m.tvValueNew)

otherwise
	llResult = this.Set_(;
		  m.tcSetting;
		, m.tvValueNew;
		, @m.lcResult;
		)

endcase

assert m.llResult message cAssertMsg(textmerge([Unable to do the following setting : SET <<m.tcSetting>> <<m.tvValueNew>><<nEvl(m.lcResult, ': ' + m.lcResult)>>]))

this.vValueNew = iif(m.llResult, m.tvValueNew, .null.)

return m.llResult
endfunc

* ------------------------------------
hidden function Set_ && {en} Changes setting to new value
lparameters ;
  tcSetting; && {en} Setting to work on
, tvValueNew; && {en} Value to set
, result; && @ {en}

local llResult as Boolean;
, loResult as exception;
, lcValue as string

lcValue = iif(vartype(m.tvValueNew) == 'C';
	, iif(m.tcSetting == 'PATH'; && 21/10/12 - SET PATH does not support literal
		, m.tvValueNew;
		, iif("'" $ m.tvValueNew, '"' + rtrim(m.tvValueNew) + '"', "'" + rtrim(m.tvValueNew) + "'");
		);
	, transform(m.tvValueNew);
	)

try
	set &tcSetting &lcValue
	llResult = .t.
catch to m.loResult

	try
		set &tcSetting &tvValueNew
		llResult = .t.
	catch to m.loResult

		try
			set &tcSetting to (&lcValue)
			llResult = .t.
		catch to m.loResult

			try
				set &tcSetting to &lcValue
				llResult = .t.
			catch to m.loResult

				try
					set &tcSetting to &tvValueNew
					llResult = .t.
				catch to m.loResult
				endtry
			endtry
		endtry
	endtry
endtry

result = Iif(m.llResult, m.result, cException(m.loResult))
return m.llResult
endfunc

* ------------------------------------
protected function lSupported && {en} Requested environment setting is supported
lparameters ;
  tcSetting; && {en} Setting to work on
, lcParm2 && {en} Second parameter of set()

tcSetting = upper(alltrim(m.tcSetting))
lcParm2 = alltrim(m.lcParm2, ' ', ',')

local llResult as Boolean;
, lcUnsupported;
, lcUntested;
, laResult[1];
, lnResult;
, liResult;
, loResult as exception

&& {fr} Reprocess && {fr} strange options

lcUnsupported = ''; && 2015-11-04 thn TEXT ... ENDTEXT removed (should have been done much earlier)
+ [Century, , 3] + CRLF;
+ [Clock, , 1] + CRLF; && {fr} does not restore properly
+ [Color] + CRLF; && {fr} Included for backward compatibility
+ [Date, , 1] + CRLF;
+ [Echo] + CRLF; && {fr} Included for backward compatibility
+ [Fields, , 1] + CRLF;
+ [Order] + CRLF; && {fr} unable to restore
+ [Printer, , 2] + CRLF;
+ [Printer, , 3] + CRLF;
+ [Skip] + CRLF;
+ [Status Bar] + CRLF; && {fr} Problem with space between 'Status' and 'Bar' ...
+ [Topic, .T., 1] + CRLF; && {fr} unable to restore
+ [View] + CRLF; && {fr} unable to restore


lcUntested  = ''; && {fr} Untested sets && 2015-11-04 thn TEXT ... ENDTEXT removed (should have been done much earlier)
+ [Help, , 1] + CRLF;
+ [Help, , 2] + CRLF;
+ [Help, , 3] + CRLF;
+ [Key, , 1] + CRLF;
+ [Key, , 2] + CRLF;
+ [Textmerge, , 4] + CRLF;
+ [Topic, , 1] + CRLF;
+ [Step] + CRLF;
+ [Display] + CRLF; && {fr} Included for backward compatibility
+ [Filter] + CRLF;
+ [Helpfilter] + CRLF;
+ [Pdsetup] + CRLF;
+ [Relation] + CRLF;

&&	textmerge, , 1 && {fr} unable to restore - set textmerge delimiters to ...

try && {fr} aLinesCols() may not be in scope

	if lProperty(_screen, 'abSet_aSupported')
		lnResult = alen(_screen.abSet_aSupported, 1)
		dimension laResult[m.lnResult, Alen(_screen.abSet_aSupported, 2)]
		acopy(_screen.abSet_aSupported, laResult)
	else
		lnResult = aLinesCols(; && {fr} very long ! - to be optimized
			  @m.laResult;
			, upper(chrtran(cInLineCommentStripped(m.lcUnsupported + CRLF + m.lcUntested), space(1), ''));
			, ',';
			, 'CLC';
			)
		asort(m.laResult, 1)
		addproperty(_screen, 'abSet_aSupported[1]')
		dimension _screen.abSet_aSupported[m.lnResult, Alen(laResult, 2)]
		acopy(laResult, _screen.abSet_aSupported)
	endif
	for liResult = 1 to m.lnResult

		llResult = not (m.tcSetting == m.laResult[m.liResult, 1] and m.lcParm2 == m.laResult[m.liResult, 3])
		if not m.llResult
			exit
		endif
	endfor
	assert m.llResult message cAssertMsg(textmerge([this setting is not supported: <<m.tcSetting>> <<m.lcParm2>>]))

catch to loResult
	llResult = .t. && {fr} assume setting is supported
endtry

return m.llResult

* ------------------------------------
hidden function destroy && {en} Restores setting to its original value

local lvValue

return IsNull(m.this.cSetting); && 2016-08-18 thn -- {en} added for just using this.set()
	or .t.;
		and this.get(@m.lvValue, m.this.cSetting, m.this.cParm2);
		and (.f.;
			or m.lvValue == m.this.vValueOld; && {fr} lvValue et this.vValueOld sont obtenus par this.Get() donc sont de même type et casse
			or this.set(m.this.cSetting, m.this.vValueOld);
			)

* =================================================
enddefine
* =================================================

* ------------------------------------
procedure abSet1 && {fr} Règle un set pour test
lparameters ;
  tcSetting; && {en} Setting to perform
, tvValueNew; && {en} Value to set, .T. to toggle ON - OFF
, tnSetting; && {en} Setting number when appropriate for tcSetting, as of 2nd parameter of set()
, tlChangeAlways; && [.T.] {en} Change setting even if required value is current
, tlSupported && [.F.] {en} assume setting is supported

local loSet

return labSet(;
		@m.loSet;
	, m.tcSetting;
	, m.tvValueNew;
	, m.tnSetting;
	, m.tlChangeAlways;
	, m.tlSupported;
	)

* ------------------------------------
procedure abSet1_Test && {fr} Teste le réglage d'un set pour mesurer le temps d'exécution

local loUnitTest as abUnitTest of abDev.prg, loAsserts as abSet
loUnitTest = newobject('abUnitTest', 'abDev.prg')
loAsserts = abSet('ASSERTS', 'OFF') && {fr} pour les settings non supportés

loUnitTest.Test(.t., 'Deleted', 'ON',,,.t.)
loUnitTest.Test(.t., 'Exact', 'ON')
loUnitTest.Test(.t., 'Ansi', 'ON')
loUnitTest.Test(.t., 'Asserts', 'ON')
loUnitTest.Test(.t., 'Safety', 'OFF')
loUnitTest.Test(.t., 'Notify', 'OFF')
loUnitTest.Test(.t., 'Talk', 'OFF')
loUnitTest.Test(.t., 'NullDisplay', '-')
loUnitTest.Test(.t., 'Datasession', 2)

loUnitTest.Test(.f., 'Skip', 'TO cALIAS')

return loUnitTest.result()

* ------------------------------------
procedure abSet_Tests && {en} Tests the abSet Class

local llResult;
, lcResult, lnSeconds;
, loSelect as abSelect, loTalk as abSet, loStatusBar as abSet, loAsserts as abSet;
, lcTestFile, laPrinters[1], loSession as session;
, laSets[1], lnSets, lcSet, llSet, loSet as abSet of abDev.prg;
, lnFailed;
, lcSetting, lvValueOld, lvValueNew, lcParm2;
, llRestore

loSelect = abSelect()
loTalk = abSet('Talk', 'OFF')
loStatusBar = abSet('Status Bar', 'OFF')
loAsserts = abSet('Asserts', 'OFF')

* {fr} Prepare test resources
lcTestFile = sys(2023) + 'abSet.txt'
aprinters(m.laPrinters)

open database (_samples + 'Tastrade\Data\tastrade.dbc')
use in select('customer')
use tastrade!customer shared order COMPANY_NA
set database to

loSession = createobject('session')

lnSeconds = seconds()
lcResult = ''
lnFailed = 0
store .t. to m.llResult, m.llSet, m.llRestore

* {fr} For each test Set
lnSets = abSet_Tests_aVFPsets(@m.laSets)
for each m.lcSet in m.laSets

	lcSet = cInLineCommentStripped(m.lcSet)

	* {fr} If Setting object can be instanciated
	loSet = abSet(&lcSet)
	llSet = vartype(m.loSet) == 'O' and not isNull(m.loSet)
	if m.llSet

		* {fr} Memorize old values
		lcSetting = m.loSet.cSetting
		lvValueOld = m.loSet.vValueOld
		lcParm2 = m.loSet.cParm2
	else
		store '' to m.lcSetting, m.lvValueOld, m.lcParm2
	endif


* {fr} Check new value was correctly SET

	* {fr} Release Setting object to restore original setting
	loSet = .null.

	* {fr} Check old value was correctly restored
	if m.llSet
		lvValueNew = evaluate('Set("' + m.lcSetting + '"' + m.lcParm2 + ')')
		lvValueNew = iif(upper(m.lcSetting) == 'DEFAULT', m.lvValueNew + curdir(), m.lvValueNew)
		lvValueNew = iif(upper(m.lcSetting) == 'PATH', chrtran(m.lvValueNew, ['"], ''), m.lvValueNew)
		llRestore = m.lvValueOld == m.lvValueNew
		llSet = m.llRestore
	endif

	clear

	* {fr} Save any Error
	if not m.llSet
		lnFailed = m.lnFailed + 1
		lcResult = m.lcResult + CRLF + '- ' + ;
			iif(m.llRestore, ;
				"Unable to set" + replicate('.', 5) + m.lcSet, ;
				"Unable to restore" + replicate('.', 3) + m.lcSetting + ', '  + left(transform(m.lvValueOld), 50) + m.lcParm2)
		llResult = .f.
	endif
endfor

use
close databases

* {fr} Display result
lcResult = iif(m.llResult, ;
		'Congratulation, the ' + transform(m.lnSets) + ' Tested Sets Worked !', ;
		transform(m.lnFailed) + ' of ' + transform(m.lnSets) + ' Set' + iif(m.lnFailed > 1, 's', '') + ' did not work :' + ;
			CRLF + m.lcResult + ;
			CRLF + CRLF + "This message is copied to the clipboard for later check.")

lcResult = m.lcResult + ;
	CRLF + CRLF + "Average execution time : " + transform((seconds()-m.lnSeconds)/m.lnSets * 1000) + " ms" + ;
	CRLF + CRLF + "Thank you for testing abSet class." + ;
	CRLF + "Please check out http://foxincloud.com/"

_cliptext = m.lcResult
messagebox(m.lcResult, 64)

return m.llResult

* ------------------------------------
procedure abSet_Tests_aVFPsets && {en} Tested Sets
lparameters aVFPsets && @ {en} Array where tested sets should be stored
external array aVFPsets

local lnResult; && {fr} Number of Tested Sets
, lnVersion;
, lcSets, lcSetsVFP7, lcSetsVFP8, lcSetsVFP9

lnResult = 0

text TO m.lcSetsVFP7 NOSHOW && {fr} SET, .T. on "ON/OFF"-type Settings to toggle, TO ...
	'Textmerge', '<<>>' , 1 && {fr} throws an error because not supported
	'Aternate', m.lcTestFile, 1 && {fr} throws an error because misspelled ('Aternate' instead of 'Alternate')
	'Alternate', .T.
	'Alternate', m.lcTestFile, 1
	'Ansi', .T.
	'Asserts', .T.
	'Autosave', .T.
	'Bell', .T.
	'Bell', m.lcTestFile, 1
	'Blocksize', 50
	'BrowseIME', .T.
	'Carry', .T.
	'Century', .T.
	'Century', 20, 1
	'Century', 50, 2
	'ClassLib', Home() + 'ffc\_base.vcx' && {fr} should exist !
	'Clock', .T.
	'Collate', 'MACHINE'
	'Compatible', .T.
	'Compatible', 'PROMPT', 1
	'Confirm', .T.
	'Console', .T.
	'Coverage', m.lcTestFile, 1
	'CpCompile', 1252
	'Cpdialog', .T.
	'Currency', 'LEFT'
	'Currency', '€', 1
	'Cursor', .T.
	'Database', 'tastrade'
	'Datasession', m.loSession.DataSessionId && {fr} objet créé plus haut
	'Date', 'FRENCH'
	'Debug', .T.
	'Debugout', .T.
	'Decimals', 10
	'Default', Home()
	'Deleted', .T.
	'Delimiters', ';',1
	'Delimiters', .T.
	'Development', .T.
	'Device', 'SCREEN'
	'Escape', .T.
	'Eventlist', 'Init'
	'Eventtracking', .T.
	'Eventtracking', m.lcTestFile,1
	'Exact', .T.
	'Exclusive', .T.
	'Fdow', 1
	'Fields', .T.
	'Fields', 'LOCAL', 2
	'Fixed', .T.
	'Fullpath', .T.
	'Fweek', 1
	'Headings', .T.
	'Help', .T.
	'Hours', 24
	'Key', 'ALFKI'
	'Keycomp', 'DOS'
	'Library', Home() + 'foxTools.fll'
	'Lock', .T.
	'Logerrors', .T.
	'Mackey', 'F1'
	'Margin', 30
	'Mark', .T.
	'Memowidth', 30
	'Message', 'abSet is Cool !', 1
	'Message', 150
	'Message', 50
	'Mouse', .T.
	'Mouse', 2,1
	'Multilocks', .T.
	'Near', .T.
	'Nocptrans', 'customer_id'
	'Notify', .T.
	'Null', .T.
	'NullDisplay', 'Rien'
	'Odometer', 200
	'Oleobject', .T.
	'Optimize', .T.
	'Palette', .T.
	'Path', .T.
	'Point', .T.
	'Printer', .T.
	'Printer', laPrinters[1], 1
	'Procedure', Home() + 'vfpxtab.prg'
	'Readborder', .T.
	'Refresh', 10
	'Refresh', 2,1
	'Reprocess', 2
	'Resource', .T.
	'Resource', Sys(2005), 1
	'Safety', .T.
	'Seconds', .T.
	'Separator', '-'
	'Space', .T.
	'Status', .T.
	'Status Bar', .T.
	'Strictdate', 2
	'Sysformats', .T.
	'Sysmenu', 'OFF'
	'Talk', .T.
	'Talk', 'WINDOW', 1
	'Textmerge', m.lcTestFile, 2
	'Textmerge', .T.
	'Textmerge', 'SHOW', 3
	'Trbetween', .T.
	'Typeahead', 50
	'Udfparms', 'REFERENCE'
	'Unique', .T.
ENDTEXT

text TO m.lcSetsVFP8 NOSHOW
	'EngineBehavior', 70
	'TableValidate', 8
	'AutoincError', .T.
ENDTEXT

text TO m.lcSetsVFP9 NOSHOW
	'ReportBehavior', 80
	'SQLBuffering', .T.
	'TablePrompt', .T.
	'VarCharMapping', .T.
ENDTEXT

lnVersion = version(5)

lcSets = '';
	+ m.lcSetsVFP7;
	+ iif(m.lnVersion >= 800, CRLF + m.lcSetsVFP8, '');
	+ iif(m.lnVersion >= 900, CRLF + m.lcSetsVFP9, '')
lcSets = strtran(m.lcSets, CRLF2, CRLF)

lnResult = alines(m.aVFPsets, m.lcSets)

return m.lnResult

* ===========================================
define class abSets as GA_LIGHTWEIGHT_CLASS of abGA.prg && {fr} Règle plusieurs Sets et les restaure à la destruction && {fr} Custom pour pouvoir être .AddObjected(), mais impossible dans awAppHost as session
* ===========================================

protected lSupported, lInit

lSupported = .f. && {fr} assume abSet supports all the settings required
lInit = .t. && {fr} all settings were successful && {fr} See in this.Set() why default is .T.

*---------------------------------------------------------------------------
procedure init
lparameters result && @ {en} error if any {fr} erreur éventuelle

#if .f. && {fr} Sample implementation
with m.this as abSets of abDev.prg
	.set('EngineBehavior', 70)
	.set('Deleted', 'ON')
	.set('Exact', 'ON')
	.set('Ansi', 'ON')
	.set('Palette', 'OFF')
	.set('Asserts', 'ON')
	.set('Safety', 'OFF')
	.set('Notify', 'OFF')
	.set('Talk', 'OFF')
endwith
#endif && {fr} Sample implementation

return m.this.lInit && {fr} always keep this instruction and/or call dodefault() in sub-class!

*---------------------------------------------------------------------------
protected procedure set && {fr} Effectue un réglage d'environnement
lparameters ;
  tcSetting; && {fr} Nom du SET à régler
, tvValueNew; && {fr} Valeur à régler
, tnSetting; && {en} Setting number when appropriate for tcSetting, as of 2nd parameter of set()
, tlChangeAlways; && [.T.] {en} Change setting even if required value is current
, tlSupported; && [this.lSupported] {en} assume abSet() supports this setting

local success as Boolean;
, loExact as abSet of abDev.prg;
, lcProp as string;
, loProp as abSet of abDev.prg;

* {fr} Si le Set est défini
success = not empty(m.tcSetting)
assert m.success
if m.success

	tcSetting = iif(ga_Type_IsChar(m.tcSetting, .t.), upper(m.tcSetting), '')

	tlSupported = iif(pcount() >= 5;
		, lTrue(m.tlSupported);
		, m.this.lSupported;
		)

	loExact = abSet('EXACT', 'OFF')

	lcProp = chrtran(m.tcSetting, ' ', '')
	lcProp = 'o';
		+ iif(inlist(m.lcProp, upper('Auto'), upper('color'), upper('event'), upper('status'));
			, m.lcProp;
			, left(m.lcProp, 4);
			);
		+ iif(empty(m.tnSetting), '', cast(m.tnSetting as m))

	loExact = .null.

	do case

	case !lProperty(m.this, m.lcProp)
		success = .t.;
			and addproperty(m.this, m.lcProp, abSet(m.tcSetting, m.tvValueNew, m.tnSetting, m.tlChangeAlways, m.tlSupported));
			and vartype(getpem(m.this, m.lcProp)) == 'O'

	case .t.;
	 and varSet(@m.loProp, evaluate('m.this.' + m.lcProp));
	 and m.loProp.vValueNew # m.tvValueNew

		success = m.loProp.set(m.tcSetting, m.tvValueNew)

	endcase
endif

this.lInit = m.this.lInit and m.success

assert m.success message cAssertMsg(textmerge(icase(;
	cLangUser() = 'fr',	[Le réglage de SET <<m.tcSetting>> à la valeur <<cL(m.tvValueNew)>> a échoué.],; && copy-paste this line to add another language support
											[Setting <<m.tcSetting>> to value <<cL(m.tvValueNew)>> failed.]; && default: English
	)))

return m.success

* ===========================================
enddefine && {fr} CLASS abSets
* ===========================================

* ===========================================
function abSetsMaintain && {fr} Sauve les sets critiques et les restore s'ils ont changé
lparameters ;
  tlSetsType; && [.null.] {en} type of SETs - .null.: all, .T.: scoped to the dataSession, .F.: global (not scoped to the dataSession)
, tlProcClass; && [.F.] {en} also save Set("Procedure") & Set("Classlib")

return createobject('abSetsMaintain';
	, Iif(Pcount() > 0, m.tlSetsType, .null.); && [.null.] {en} SETs .T.: scoped to the dataSession, .F.: global, .null.: all
	, m.tlProcClass;
	)
endfunc

* ------------------------------------
procedure abSetsMaintain_Test && {fr} abSetsMaintain() unit test

local loUnitTest as abUnitTest of abDev.prg, loResult
loUnitTest = newobject('abUnitTest', 'abDev.prg')
loResult = newobject('abSetsMaintain', 'abDev.prg')

*loUnitTest.coverageSet(.T.)
loUnitTest.Test(.null.) && 1 ms

* {fr} loUnitTest.coverageSet(.F.)

return m.loUnitTest.result()
endproc

* ===========================================
define class abSetsMaintain as GA_LIGHTWEIGHT_CLASS of abGA.prg && {fr} Sauve les sets critiques et les restore s'ils ont changé
* ===========================================

hidden aSet[1], nSets

*---------------------------------------------------------------------------
protected procedure init
lparameters ;
  tlSetsType; && [.null.] {en} type of SETs - .null.: all, .T.: scoped to the dataSession, .F.: global (not scoped to the dataSession)
, tlProcClass; && [.F.] {en} also save Set("Procedure") & Set("Classlib")

local success as Boolean;
, laSet[1];
, liSet;

this.nSets = aVFPsetsValue(; && see below
	 @m.laSet;
	, Iif(Pcount() > 0, m.tlSetsType, .null.); && [.null.] {en} SETs .T.: scoped to the dataSession, .F.: global, .null.: all
	, m.tlProcClass;
	)

success = m.this.nSets > 0
if m.success

	dimension this.aSet[m.this.nSets, Alen(m.laSet, 2)]
	acopy(m.laSet, this.aSet)
endif

return m.success
endproc

*---------------------------------------------------------------------------
procedure set as Boolean && {en} perform a SETting
lparameters lcSet, lnSet, luSet

&& {fr} Public car appelé par modify command awPublic > awSets.Set()
local aa[1], liSet

do case

case .F.;
or empty(m.lnSet) and (.F.;
 or .T.;
   and vartype(m.luSet) == 'C';
   and (.F.;
	  or InList(m.luSet, 'ON', 'OFF', 'AUTOMATIC');
	  or InList(m.lcSet, 'DATE', 'CLOCK');
	  or m.lcSet == 'CURRENCY' and InList(m.luSet, 'RIGHT', 'LEFT');
	  );
 or InList(m.lcSet, 'ENGINEBEHAVIOR', 'REPORTBEHAVIOR') and varSet(@m.luSet, Cast(m.luSet as M));
 );
or m.lnSet = 2 and m.lcSet == 'FIELDS'
	set &lcSet &luSet

case m.lcSet == 'TEXTMERGE'
	do case
	case m.lnSet = 1 && {fr} cLeftDelimiter and cRightDelimiter
		luSet = '"' + stuffc(m.luSet, len(m.luSet)/2 + 1, 0, '","') + '"'
		set textmerge delimiters to &luSet
	case m.lnSet = 2 and Empty(m.luSet) && {fr} cFileName
		set textmerge to
	case m.lnSet = 2 && {fr} cFileName
		set textmerge to (m.luSet)
	case m.lnSet = 3 && {fr} SHOW/NOSHOW
		set textmerge to &luSet
	endcase

case inlist(m.lcSet, 'CENTURY', 'MOUSE', 'REFRESH', 'UDFPARMS') && 2016-08-18 thn -- {en} , 'FIELDS', 'NOCPTRANS' removed http://support.west-wind.com/Thread4PC0SHQLT.wwt?rl=1#4PH0Q7H4B
	luSet = Cast(m.luSet as M)
	set &lcSet to &luSet

case inlist(m.lcSet, 'PROCEDURE', 'CLASSLIB') && 2016-08-18 thn -- {en} added
	SetProcClassRestore(m.luSet, m.lcSet == 'CLASSLIB') && modify command abDev - see below

case Empty(m.luSet) and Vartype(m.luSet) == 'C'
	set &lcSet to

case m.lcSet == 'LIBRARY'
	set library to
	for liSet = 1 to ALines(aa, m.luSet, 5, ',')
		set library to (m.aa[m.liSet]) additive
	endfor

otherwise
	set &lcSet to (m.luSet)

endcase

endproc

*---------------------------------------------------------------------------
protected procedure destroy

local liSet, lcSet, luSet, lnSet

for liSet = 1 to this.nSets

	if !this.aSet[m.liSet, 3] == uVFPsetValue(this.aSet[m.liSet, 1], this.aSet[m.liSet, 2]); && {en} restore only if different
		or .F. && .T. tests all restores

		this.set(;
			this.aSet[m.liSet, 1];
		, this.aSet[m.liSet, 2];
		, this.aSet[m.liSet, 3];
		)

	endif
endfor
endproc

* ===========================================
enddefine && {fr} CLASS abSetsMaintain
* ===========================================


* ========================================
function lSetClasslib && {fr} Un jeu de Set("Classlib") est dans le Set("Classlib") courant
lparameters tcSetClasslib && {fr} Jeu de Set("Classlib")

local laClasslib[1], lcClasslib, lcSetClasslib, llResult

llResult = alines(laClasslib, m.tcSetClasslib, 5, ',') = 0
if not m.llResult

	lcSetClasslib = set("Classlib")

	for each lcClasslib in laClasslib

		llResult = m.lcClasslib $ m.lcSetClasslib
		if not m.llResult
			exit
		endif
	endfor
endif

return m.llResult

* ========================================
function lSetProcedure && {fr} Un jeu de Set("Procedure") est dans le Set("Procedure") courant
lparameters tcSetProcedure && {fr} Jeu de Set("Procedure")

local laProcedure[1], lcProcedure, lcSetProc, llResult

llResult = alines(laProcedure, m.tcSetProcedure, 5, ',') = 0
if not m.llResult

	lcSetProc = set("Procedure")

	for each lcProcedure in laProcedure

		llResult = m.lcProcedure $ m.lcSetProc
		if not m.llResult
			exit
		endif
	endfor
endif

return m.llResult

* ========================================
function cFuncCallParmAdd && {fr} Ajoute un paramètre à un appel de fonction
lparameters ;
  tcFuncCall; && {fr} Chaîne contenant un appel de fonction
, tcParm && {fr} Chaîne à ajouter comme paramètre (ex. '@MonParm') /!\ non vérifié
local llResult, lcResult
lcResult = ''

llResult = vartype(m.tcFuncCall) == 'C'
if m.llResult
	lcResult = alltrim(m.tcFuncCall)
	llResult = right(m.lcResult, 1) == ')'
	if m.llResult

		llResult = vartype(m.tcParm) == 'C' and not empty(m.tcParm)
		if m.llResult

			local lcParm
			lcParm = alltrim(m.tcParm)
			lcParm = iif(left(m.lcParm, 1) == ',', '', ',') + m.lcParm
			lcResult = left(m.lcResult, len(m.lcResult) - 1) + m.lcParm + ')'
		endif
	endif
endif

return m.lcResult

* ------------------------------------
procedure cFuncCallParmAdd_Test && {fr} Teste cFuncCallParmAdd()

local loUnitTest as abUnitTest of abDev.prg
loUnitTest = newobject('abUnitTest', 'abDev.prg')

loUnitTest.Test('myFunc(toto,m.lcTest)', ' myFunc(toto)', 'm.lcTest')

return loUnitTest.result()

* ========================================
function cException && {fr} Message d'exception standard
lparameters toException as exception && {fr} Objet exception

local lcResult;
, lcUserValue;
, lcMessage;
, lcLine;

lcResult = ''

if type('m.toException.BaseClass') == 'C';
	and m.toException.BaseClass == 'Exception'

	with m.toException as exception

		lcResult = '"' + .LineContents + '"'
		lcResult = iif(Empty(_vfp.StartMode);
			, textmerge(icase(;
					cLangUser() = 'fr',	[(<<Iif('...' $ .LineContents, 'code source N/D', m.lcResult)>>)],; && copy-paste this line to add another language support
															[(<<Iif('...' $ .LineContents, 'source code N/A', m.lcResult)>>)]; && default: English
				));
			, '';
			)
		lcUserValue = ICase(;
			type('.userValue.BaseClass') == 'C' and .userValue.BaseClass == 'Exception',;
				cException(.userValue),;
			Vartype(.userValue) == 'C' and CR $ .userValue,;
				CRLF + Ltrim(.userValue, CR, LF, ' '),;
				Cast(.userValue as M);
			)
		lcMessage = Trim(.Message, ',', ' ', '.') && "Erreur levée par l'utilisateur, ."

		lcMessage = m.lcMessage + Iif(Empty(m.lcMessage) or Empty(m.lcUserValue), '', ' - ') + m.lcUserValue && c2Words() may not be available
		lcLine = Iif(Vartype(.LineNo) == 'N', Ltrim(Transform(.LineNo, '999,999')), .LineNo)

		lcResult = c2Words(;
			  textmerge(icase(;
				cLangUser() = 'fr',	[Méthode ou procédure <<.Procedure>>() : erreur n° <<.ErrorNo>> ("<<m.lcMessage>>") à la ligne n° <<m.lcLine>>],; && copy-paste this line to add another language support
														[Method or procedure <<.Procedure>>(): error #<<.ErrorNo>> ("<<m.lcMessage>>") at code line #<<m.lcLine>>]; && default: English
				));
			, ' ';
			, m.lcResult;
			)
	endwith
endif

return m.lcResult
endfunc

* ------------------------------------
procedure cException_Test && {fr} Teste cException()

local loUnitTest as abUnitTest of abDev.prg;
, lcCmd;
, loException as exception;
, lcResult

loUnitTest = newobject('abUnitTest', 'abDev.prg')
try
	lcCmd = 'crash'
	&lcCmd
catch to loException
	lcResult = "Une exception s'est produite :";
	+ CRLF + "> Méthode : " + m.loException.procedure ;
	+ CRLF + "> Erreur n° : " + transform(m.loException.errorno) ;
	+ CRLF + "> Erreur : " + m.loException.message ;
	+ CRLF + "> Ligne de code n° : " + transform(m.loException.lineno) ;
	+ CRLF + "> Ligne de code : " + m.loException.linecontents
finally
	loUnitTest.Test(m.lcResult, m.loException)
endtry

return loUnitTest.result()

* ---------------------------------------------------
procedure FilesCompile && {fr} Compile des fichiers d'après un squelette
lparameters ;
  tcFilesSkeleton; && {fr} Squelette d'adresse de fichiers
, tcFilesFailed && @ [''] {fr} Fichiers dont la compilation a échoué
tcFilesFailed = ''

local lnFiles, laFiles[1], llResult, lnResult && {fr} Nombre de fichiers compilés avec succès
lnResult = 0

* {fr} S'il existe au moins un fichier répondant au masque spécifié
lnFiles = aFiles(@m.laFiles, m.tcFilesSkeleton)
llResult = m.lnFiles > 0
assert m.llResult message cAssertMsg(textmerge([No file match the specified skeleton: <<cLitteral(m.tcFilesSkeleton)>>]))
if m.llResult

	local lcFolderAddr, loProc, loClass, lnFile, lcFile, lnFilesFailed, laFilesFailed[1]
	lcFolderAddr = addbs(justpath(m.tcFilesSkeleton))

	* {fr} Sauver les set car COMPILE ferme automatiquement les fichiers
	loProc = abSet('PROCEDURE', set("Procedure"),,, .t.)
	loClass = abSet('CLASSLIB', set("ClassLib"),,, .t.)

	debugout space(1)
	debugout replicate('=', 50)
	debugout "Compiling", transform(m.lnFiles), 'files in', m.lcFolderAddr

	* {fr} Pour chaque fichier
	lnFilesFailed = 0
	for lnFile = 1 to m.lnFiles
		lcFile = laFiles[m.lnFile, 1]

		* {fr} Compiler le fichier
		llResult = FileCompile(m.lcFolderAddr + m.lcFile)

		* {fr} Si succès, compter
		if m.llResult
			lnResult = m.lnResult + 1
		* {fr} Sinon, tabuler
		else
			lnFilesFailed = lnFilesFailed + 1
			dimension laFilesFailed[m.lnFilesFailed]
			laFilesFailed[m.lnFilesFailed] = m.lcFile
		endif
	endfor

	release loProc, loClass && {fr} Rétablit les SET

	debugout transform(m.lnResult), "files compiled out of", transform(m.lnFiles)
	debugout replicate('=', 50)

	* {fr} Si échec(s), lister les fichiers
	if m.lnFilesFailed > 0
		tcFilesFailed = cListOfArray(@m.laFilesFailed)
	endif
endif

return m.lnResult

* ---------------------------------------------------
procedure FileCompile && {fr} Compile un fichier
lparameters ;
  tcFileAddr; && {fr} Adresse du fichier
, tcResult; && @ [''] {fr} Résultat de la compilation
, tcClause; && [''] {fr} Clauses de compilation (pour *.prg)
, tnResult && @ [0] {fr} nombre d'erreurs de compilation

tcResult = ''
tcClause = evl(m.tcClause, '')
tnResult = 0

local llResult;
, loLogErrors as abSet of abDev.prg;
, loNotify as abSet of abDev.prg;
, lcExt;
, llInSet;

llResult = file(m.tcFileAddr)
tcResult = textmerge([Le fichier à compiler '<<m.tcFileAddr>>' est introuvable])
assert m.llResult message cAssertMsg(m.tcResult)
if m.llResult

	loLogErrors = abSet('LOGERRORS', 'ON')
	loNotify = abSet('NOTIFY', 'OFF') && {fr} supprime le thermomètre d'avancement

	* {fr} Tenter la compilation
	tcFileAddr = fullpath(m.tcFileAddr) && upper()
	lcExt = justext(m.tcFileAddr)
	try

		do case

		case inlist(m.lcExt, 'PRG', 'QPR', 'MPR')
			llInSet = forceext(m.tcFileAddr, icase(m.lcExt == 'PRG', 'FXP', m.lcExt == 'QPR', 'QPX', 'MPX')) $ set("Procedure")
			compile (m.tcFileAddr) &tcClause
			if m.llInSet
				set procedure to (m.tcFileAddr) additive
			endif

		case m.lcExt == 'VCX'
			clear classlib (m.tcFileAddr) && {fr} par sécurité && 2017-11-24 thn -- {fr} mais ça ne marche pas : 16:51:57 - (004) Compiling 'c:\work_foxincloud\common\foxpro\vfpclasses\tlcclasses.vcx' - acoop.fxp!Awadapter.filescompile() - FAILURE: Filecompile() - Method or procedure filecompile(): error #3 ("File is in use") at code line #3,331 ("compile classlib (m.tcFileAddr)") - File 'TLCCLASSES.VCX'
			compile classlib (m.tcFileAddr)

		case m.lcExt == 'SCX'
			compile form (m.tcFileAddr)

	 	case m.lcExt == 'FRX'
			compile report (m.tcFileAddr)

	 	case m.lcExt == 'LBX'
			compile label (m.tcFileAddr)

		case m.lcExt == 'DBC'
			loSet = abSet('DATABASE', '',,, .t.)
			compile database (m.tcFileAddr)

		case inlist(m.lcExt, 'INI', 'TXT', 'LOG', 'H')

		otherwise
			tcResult = textmerge(icase(;
				cLangUser() = 'fr',	[La compilation du fichier '<<JustFname(m.tcFileAddr)>>' n'est pas supportée],; && copy-paste this line to add another language support
														[Compiling file '<<JustFname(m.tcFileAddr)>>' is not supported]; && default: English
				))
			llResult = .f.
		endcase

*- Inutile car COMPILE fait le PACK
*-				IF InList(m.lcExt, 'SCX', 'VCX', 'FRX', 'LBX', 'DBX') && {fr} le code source est dans une table
*-					PACK (m.tcFileAddr)
*-				ENDIF

		if m.llResult
			tcResult = forceext(m.tcFileAddr, 'err')
			llResult = not file(m.tcResult)
			tnResult = iif(m.llResult, 0, evl(occurs('Error in line', filetostr(m.tcResult)), 1))
			tcResult = iif(m.llResult;
				, icase(;
						cLangUser() = 'fr',	[sans erreur],; && copy-paste this line to add another language support
																[successfully]; && default: English
					);
				, icase(;
						cLangUser() = 'fr',	[avec erreur(s) : ],; && copy-paste this line to add another language support
																[with error(s): ]; && default: English
					) + CRLF + filetostr(m.tcResult);
				)
			tcResult = textmerge(icase(;
					cLangUser() = 'fr',	[Fichier '<<JustFname(m.tcFileAddr)>>' compilé <<m.tcResult>>],; && copy-paste this line to add another language support
															[File '<<JustFname(m.tcFileAddr)>>' compiled <<m.tcResult>>]; && default: English
				))
		endif

	catch to m.loException

		llResult = .f.
		tcResult = '';
			+ cException(m.loException);
			+ ' - ';
			+ textmerge(icase(;
					cLangUser() = 'fr',	[Fichier '<<JustFname(m.tcFileAddr)>>'],; && copy-paste this line to add another language support
															[File '<<JustFname(m.tcFileAddr)>>']; && default: English
				));
			+ iif(empty(m.tcClause), '', ' - ' + m.tcClause)

		?? chr(7)
	endtry

	tcResult = iif(empty(m.tcResult), '', textmerge([<<Proper(Program())>>() - <<m.tcResult>>]))
	debugout m.tcResult
endif

return m.llResult
endproc

* ========================================
procedure ProcEmpty && {fr} Sert à mesurer le temps moyen d'appel d'une procédure
lparameters ;
  Parm1; && {fr} Bidon
, Parm2; && {fr} Bidon
, Parm3; && {fr} Bidon
, Parm4; && {fr} Bidon
, Parm5; && {fr} Bidon
, Parm6 && {fr} Bidon
local llResult
llResult = .t.
uDefault(m.Parm1, 'bidon')
return m.llResult

* ------------------------------------
procedure ProcEmpty_Test && {fr} Teste ProcEmpty()

local loUnitTest as abUnitTest of abDev.prg
loUnitTest = newobject('abUnitTest', 'abDev.prg')

loUnitTest.Test(.t.)
loUnitTest.Test(.t., 2, 'bidon', .f., date())

return loUnitTest.result()

* ========================================
function cPWRand && {fr} Mot de passe aléatoire sûr selon indications Windows
lparameters tnLength && [8] {fr} Nombre de caractères

local lcResult, lcCars, lnCars, lnCar

&& {fr} Passwords must contain characters from three of the following five categories:
lcCars = '';
	+ 'ABCDEFGHIKKLMNOPQRSTUVWXYZ'; && {fr} Uppercase characters of European languages (A through Z, with diacritic marks, Greek and Cyrillic characters)
	+ 'abcdefghikklmnopqrstuvwxyz'; && {fr} Lowercase characters of European languages (a through z, sharp-s, with diacritic marks, Greek and Cyrillic characters)
	+ '0123456789'; && {fr} Base 10 digits (0 through 9)
	+ '!@#$%&*_-+=/|\(){}[];"' + ['<>,.?]; && {fr} Nonalphanumeric characters && ^~`: removed those difficult to type or conflicting with usual syntax
	+ '' && {fr} Any Unicode character that is categorized as an alphabetic character but is not uppercase or lowercase. This includes Unicode characters from Asian languages.

lnCars = len(m.lcCars)
lcResult = ''

rand(-1) && {fr} To achieve the most random sequence of numbers, issue RAND( ) initially with a negative argument and then issue RAND( ) without an argument.
for lnCar = 1 to iif(vartype(m.tnLength) = 'N' and m.tnLength > 0, m.tnLength, 8)
	lcResult = m.lcResult + substr(m.lcCars, min(max(int(rand() * m.lnCars), 1), m.lnCars), 1)
endfor

return m.lcResult

* -------------------------------------------------------------
function cPWRand_Test && {fr} Teste cPWRand

? sys(16)
? cPWRand()
? cPWRand(15)

* ========================================
function abProject as abProject of abDev.prg && {fr} ouvre un projet et le referme automatiquement
lparameters ;
  tcPJX; && {fr} Adresse du projet
, tcResult; && @ {fr} Résultat en cas d'échec

return CreateObject('abProject', m.tcPJX, @m.tcResult)
endfunc

* ========================================
define class abProject as GA_LIGHTWEIGHT_CLASS of abGA.prg && {fr} ouvre un projet et le referme automatiquement

oProject = .null. && {fr} Référence au projet
lOpened = .f. && {fr} Le projet a été ouvert - .NULL. le projet a été créé

* ----------------
protected procedure init
lparameters ;
  tcPJX; && {fr} Adresse du projet
, tcResult && @ {fr} Résultat en cas d'échec

local lOpened

this.oProject = oProject(m.tcPJX, @m.tcResult, @m.lOpened)
this.lOpened = m.lOpened

return vartype(m.this.oProject) == 'O'
endProc

* ----------------
protected procedure destroy
if Nvl(m.this.lOpened, .T.)
	this.oProject.close
endif
endProc

enddefine && {fr} CLASS abProject
* ========================================

* ========================================
function lProject && {fr} Un projet est ouvert
lparameters tcPJX && {fr} Nom du projet

local success as Boolean;
, oProject as project

if _vfp.projects.count > 0
	tcPJX = lower(justfname(forceext(m.tcPJX, 'pjx')))
	for each oProject in _vfp.projects foxobject
		if lower(justfname(m.oProject.name)) == m.tcPJX
			success = .t.
			exit
		endif
	endfor
endif

return m.success

* ========================================
function oProject && {fr} Référence à un projet (ouvert ou créé)
lparameters ;
  tuPJX; && {fr} Adresse du projet
, result; && @ {fr} Résultat (cumulatif)
, tlOpened; && @ [.F.] {fr} Le projet a été ouvert - .NULL. le projet a été créé

tlOpened = .f.

local loResult as project;
, loProject as project;
, llResult as Boolean;
, loException as exception;

loResult = .null.

do case
case Type('m.tuPJX.BaseClass') == 'C' and m.tuPJX.BaseClass == 'Project'
	loResult = m.tuPJX

case vartype(m.tuPJX) == 'C'

	tuPJX = iif(empty(justext(m.tuPJX)), forceext(m.tuPJX, 'pjx'), m.tuPJX)
	if lower(justext(m.tuPJX)) == 'pjx'

	 	if file(m.tuPJX)
		 	tuPJX = fullpath(m.tuPJX)

			* {fr} Si le projet n'est pas déjà ouvert
			llResult = _vfp.projects.count > 0
			if m.llResult
				llResult = .f.
				for each loProject in _vfp.projects foxobject
					if fullpath(m.loProject.name) == m.tuPJX
						llResult = .t.
						loResult = m.loProject && {fr} after EXIT, FOR EACH resets loProject to .F.
						exit
					endif
				endfor
			endif
	 	else
	 		create project (m.tuPJX) nowait noshow noprojecthook save
	 		if Type('_VFP.ActiveProject') == 'O'
	 			loResult = _VFP.ActiveProject
		 		llResult = .T.
		 		tlOpened = .null.
		 	endif
	 	endif
		if not m.llResult

			* {fr} Ouvrir le projet
			try
				ignoreAll() && modify command abDev
				modify project (m.tuPJX) save nowait noshow noprojecthook
				keyboard '' clear
				loResult = _vfp.activeproject
				tlOpened = iif(isNull(m.tlOpened), m.tlOpened, .t.)
			catch to loException when m.loException.ErrorNo = 1705 && {en} File Access is denied
				cResultAdd(@m.result, cException(m.loException) + ' - ' + ICase(;
					cLangUser() = 'fr',	[Conseil : fermez toutes les autres instances de VFP où le projet a pu être ouvert],; && copy-paste this line to add another language support
															[Hint: close all instances of VFP IDE where project can have been open.]; && default: English
					))
			catch to loException
				cResultAdd(@m.result, cException(m.loException))
			endtry
		endif
	else
		cResultAdd(@m.result, textmerge([Invalid project file extension : <<cLitteral(m.tuPJX)>>]))
	endif
otherwise
	cResultAdd(@m.result, textmerge([Invalid project specification : <<cLitteral(m.tuPJX)>>]))
endcase

return m.loResult
endproc

* ========================================
procedure IgnoreAll && {fr} pré-sélectionne l'option 'tout' dans un dialogue à venir tel que ASSERT ou la localisation d'un fichier à l'ouverture d'un projet
lparameters tlWarning as Boolean && [.F.] {fr} au cas où la pré-sélection automatique ne fonctionne pas, demander à l'utilisateur de le faire lui-même
&& {en} contribution by Bob Pierce during FoxInCloud training '15 at Phoenix AZ

if lTrue(m.tlWarning)
	MessageBox(ICase(;
		cLangUser() = 'fr',;
			''; && copy-paste this line to add another language support
			        + [Le programme va maintenant réaliser une action pouvant provoquer une ou plusieurs erreurs ...];
			+ CRLF2 + [Le programme va tenter de prévenir ces erreurs ...];
			+ CRLF2 + [Toutefois, si un message d'erreur s'ouvre, tel qu'une recherche de fichier manquant, ou un dialogue de type ASSERT,];
			+ CRLF2 + [merci de cliquer :] + Replicate(Chr(160), 5) + ['IGNORER TOUT'] + Replicate(Chr(160), 5) + [Merci];
			,;
			''; && default: English
			        + [Program will now perform a task that can raise some error(s) ...];
			+ CRLF2 + [Program will try to avoid/prevent those errors...];
			+ CRLF2 + [However, if an error message pops up, such as 'Locate File' or ASSERT type error box,];
			+ CRLF2 + [please click:] + Replicate(Chr(160), 5) + ['IGNORE ALL'] + Replicate(Chr(160), 5) + [Thank you];
	), 64;
	, ICase(;
		cLangUser() = 'fr',	'Ignorer toutes les erreurs à venir',; && copy-paste this line to add another language support
												'Ignore all coming errors'; && default: English
		);
	, 20000;
	)
endif

local lcVersion3 as String

lcVersion3 = Version(3)

keyboard '{alt+'; && {en} You can fill the keyboard buffer with up to 128 characters. Once the keyboard buffer is full, additional characters are ignored.
	+ ICase(;
		m.lcVersion3 == '33',	't',; && {fr} French - 'tout'
		m.lcVersion3 == '34',	't',; && {fr} Spanish - 'todas'
		m.lcVersion3 == '49',	'a',; && {fr} German - 'alle'
			'a'; && English - 'all' (Default)
		);
	+ '}' plain clear

&& 2016-02-08 thn -- {en} in interactive scenario, always clear the keyboard buffer when no longer useful, eg:
&& keyboard '' clear
endproc

#if .F.
KEYBOARD "TEST KB BUFFER" CLEAR
cReadKBB = ''
DO WHILE .T.
	nChar = INKEY()
	IF nChar <> 0
		cReadKBB = m.cReadKBB + CHR(nChar)
	else
		exit
	endif
enddo
? cReadKBB 
#endif

* ========================================
procedure ProjectClose && {fr} Ferme un projet
lparameters tcProject && {fr} Nom du projet tel qu'il apparaît dans sa barre de titre

local loProject as project, lcProject, llResult, lcResult && {fr} Adresse du projet pour le réouvrir ultérieurement

lcResult = ''
llResult = vartype(m.tcProject) == 'C' and not empty(m.tcProject)
assert m.llResult message cAssertMsg(textmerge([Invalid project specification : <<cLitteral(m.tcProject)>>]))
if m.llResult and _vfp.projects.count > 0

	* {fr} Pour chaque projet ouvert
	tcProject = upper(alltrim(m.tcProject))
	for each m.loProject in _vfp.projects
		lcProject = m.loProject.name

		* {fr} si c'est le projet cherché
		if upper(juststem(m.lcProject)) == m.tcProject

			* {fr} Fermer
			loProject.close
			lcResult = m.lcProject
			exit
		endif
	endfor
endif

return m.lcResult

* ========================================
function abProjectsClose as abProjectsClose of abDev.prg && {fr} Ferme les projets à .Init(), les rouvre à .Destroy()
lparameters tuFolderExclude && {en} Folders where projects should remain open, .T.: leave projects in curdir() open
return createobject('abProjectsClose', m.tuFolderExclude)

* ========================================
define class abProjectsClose as GA_LIGHTWEIGHT_CLASS of abGA.prg && {fr} Ferme les projets à .Init(), les rouvre à .Destroy()
* ========================================

	hidden aProject[1]

	* ---------------
	procedure init
	lparameters tuFolderExclude && {en} Folders where projects should remain open, .T.: leave projects in curdir() open

	local result, iProject, oProject as project, cProject, aFolderExclude[1]
	
	for iProject = 1 to ALines(aFolderExclude, ICase(lTrue(m.tuFolderExclude), Sys(5) + Curdir(), ga_Type_IsChar(m.tuFolderExclude, .T.), m.tuFolderExclude, ''), 5, ',')
		m.aFolderExclude[m.iProject] = Addbs(m.aFolderExclude[m.iProject])
	endfor

	for iProject = iif(lDevMode(), _vfp.projects.count, 0) to 1 step -1
		oProject = _vfp.projects(m.iProject)
		cProject = m.oProject.name
		if Empty(Ascan(m.aFolderExclude, Addbs(JustPath(m.cProject)), 1, -1, 1, 7))

			result = Evl(m.result, 0) + 1
			dimension this.aProject[m.result]
			this.aProject[m.result] = m.cProject
			oProject.close
		endif
	endfor

	return m.result
	endproc

	* ---------------
	procedure destroy

	local iProject, oProject as Project

	oProject = Iif(Type('_VFP.ActiveProject') == 'O', _VFP.ActiveProject, .null.)

	for iProject = Alen(this.aProject) to 1 step -1 && 1 to Alen(this.aProject) && 
		modify project (this.aProject[m.iProject]) nowait
	endfor

	if !IsNull(m.oProject)
		m.oProject.refresh
	endif
	endproc

* ========================================
enddefine && {fr} CLASS abProjectsClose
* ========================================

* ========================================
define class abDBCsClose as GA_LIGHTWEIGHT_CLASS of abGA.prg && {fr} Init() ferme les bases de données, Destroy() les rouvre
* ========================================

	hidden aDBCs[1], nDBCs, cDBCCur

* ---------------
	procedure init

	this.nDBCs = adatabases(this.aDBCs) && [nom | adresse]

	if this.nDBCs > 0
		this.cDBCCur = dbc()

		local lnDBC
		for lnDBC = 1 to this.nDBCs
			set database to (this.aDBCs[m.lnDBC, 1]) && {fr} nom
			close databases
		endfor
	endif

* ---------------
	procedure destroy

	if this.nDBCs > 0

		local lnDBC
		for lnDBC = 1 to this.nDBCs
			open database (this.aDBCs[m.lnDBC, 2]) && {fr} adresse
		endfor
		if file(this.cDBCCur)
			set database to (m.this.cDBCCur)
		endif
	endif

* ========================================
enddefine && {fr} CLASS abDBCsClose
* ========================================


* ========================================
function nFColor && {fr} Couleur d'avant plan
lparameters tcFColor && {fr} Chaîne selon format "RRR,GGG,BBB"
local lnResult
lnResult = 0 && {fr} black

if vartype(m.tcFColor) == 'C' and occurs(',', m.tcFColor) = 2
	local array laFColors[1]
	alines(laFColors, m.tcFColor, 1, ',')
	lnResult = rgb(val(laFColors[1]), val(laFColors[2]), val(laFColors[3]))
endif

return m.lnResult

* ========================================
function nBColor && {fr} Couleur d'arrière plan
lparameters tcBColor && {fr} Chaîne selon format "RRR,GGG,BBB"

local lnResult
lnResult = rgb(255, 255, 255) && {fr} white

if vartype(m.tcBColor) == 'C' and occurs(',', m.tcBColor) = 2
	local array laBColors[1]
	alines(laBColors, m.tcBColor, 1, ',')
	lnResult = rgb(val(laBColors[1]), val(laBColors[2]), val(laBColors[3]))
endif

return m.lnResult

* =================================================
function abISX && {fr} Arrête et redémarre ISX (nécessaire en développement de formulaires)
return createobject('abISX')

* =================================================
define class abISX as GA_LIGHTWEIGHT_CLASS of abGA.prg && {fr} Arrête et redémarre ISX (nécessaire en développement de formulaires)
* =================================================
hidden lISX, cISX

lISX = file('ISX.fxp')

* ------------------------------------
procedure init && {fr} Désactive ISX


* {fr} return .F.

if m.this.lISX and lDevMode() && {fr} lDevMode() par sécurité, évite un WAIT en unattended server mode
	this.cISX = fullpath('ISX.fxp')
	local lcISX
	lcISX = "ISX('QUIT')" && {fr} évite d'embarquer ISX dans le projet
	&lcISX
else
	return .f.
endif

* ------------------------------------
procedure destroy && {fr} Résactive ISX
local lcISX
lcISX = 'DO "' + m.this.cISX + '"' && {fr} évite d'embarquer ISX dans le projet
&lcISX

* =================================================
enddefine && {fr} CLASS abISX
* =================================================

* ------------------------------------
function uValue && {fr} Valeur convertie selon le varType spécifié (AKA coercition de type)
lparameters ;
  tuValue; && {fr} Valeur source
, tcTypeDest && {fr} Type de valeur attendu selon codification de la fonction VFP varType()

&& /!\ pourrait être simplifiée et optimisée avec Cast()

local luResult;
, llResult;
, lcTypeSrce;
, lcTypeDest;

luResult = .null.

#if .f. && {fr} Vartype() VFP9
	C && {fr} Character, Memo, Varchar, Varchar (Binary)
	D && {fr} Date
	G && {fr} General
	L && {fr} Logical
	n && {fr} Numeric, Float, Double, or Integer
	O && {fr} Object
	Q && {fr} Blob, Varbinary
	t && {fr} DateTime
	U && {fr} Unknown or variable does not exist
	X && .NULL.
	Y && {fr} Currency
	I && {fr} Integer && {fr} support additionnel
#endif

llResult = vartype(m.tcTypeDest) == 'C'
if m.llResult
	lcTypeDest = upper(alltrim(m.tcTypeDest))
	llResult = len(m.lcTypeDest) = 1 and m.lcTypeDest $ 'CDGLNOQTUXYI'
endif
assert m.llResult message cAssertMsg(textmerge("Spécification de type non supportée : <<cLitteral(m.tcTypeDest)>>"))
if m.llResult

	lcTypeSrce = vartype(m.tuValue)
	llResult = m.lcTypeSrce $ 'CNYLDTX'
	assert m.llResult message cAssertMsg(textmerge("Type de valeur non supportée : <<cLitteral(m.lcTypeSrce)>>"))
	if m.llResult

		if m.lcTypeDest == m.lcTypeSrce
			luResult = m.tuValue
		else

			do case

			case m.lcTypeSrce == 'C'
				tuValue = upper(alltrim(m.tuValue))
				if m.lcTypeDest $ 'YNI'

					* {fr} Normaliser le point décimal éventuel, supprimer les séparateurs de milliers
					local lcPoint, lcSeparator, lcChars
					lcPoint = set("Point")
					lcSeparator = set("Separator")
					lcChars = m.lcSeparator + space(1) + set("Currency", 1) + '$'
					tuValue = iif(m.lcSeparator == '.';
						, chrtran(m.tuValue, m.lcChars, '');
						, chrtran(m.tuValue, '.' + m.lcChars, m.lcPoint);
						)
					assert occurs(m.lcPoint, m.tuValue) <= 1 message cAssertMsg(textmerge([Plus d'un séparateur décimal dans le nombre <<m.tuValue>>]))
				endif
				luResult = icase(;
					m.lcTypeDest == 'N', val(m.tuValue),;
					m.lcTypeDest == 'Y', ntom(val(m.tuValue)),;
					m.lcTypeDest == 'I', int(val(m.tuValue)),;
					m.lcTypeDest == 'L', icase(;
						inlist(m.tuValue, 'T', '.T.', 'VRAI', 'TRUE'),;
							.t.,;
						empty(m.tuValue) or inlist(m.tuValue, 'F', '.F.', 'FAUX', 'FALSE'),;
							.f.,;
							evaluate(m.tuValue);
							),;
					m.lcTypeDest $ 'DT', iif(left(m.tuValue, 1) = '{', evaluate(m.tuValue), uValue_TD(m.tuValue, m.lcTypeDest)),;
					.null.)
				if m.lcTypeDest $ 'DT' && {fr} Ctod() et Ctot() peuvent produire un résultat invalide
					try
						dtoc(m.luResult)
					catch
						luResult = iif(m.lcTypeDest == 'D', {}, {/:})
					endtry
				endif

			case m.lcTypeSrce == 'N'
				luResult = icase(;
					m.lcTypeDest == 'C', transform(m.tuValue),;
					m.lcTypeDest == 'I', int(m.tuValue),;
					m.lcTypeDest == 'Y', ntom(m.tuValue),;
					m.lcTypeDest == 'L', m.tuValue != 0,;
					.null.)

			case m.lcTypeSrce $ 'DT'
				luResult = icase(;
					m.lcTypeDest == 'C', cLitteral(m.tuValue),; && {fr} mieux que Cast()
					m.lcTypeDest == 'D', ttod(m.tuValue),;
					m.lcTypeDest == 'T', dtot(m.tuValue),;
					.null.)

			case m.lcTypeSrce == 'L'
				luResult = icase(;
					m.lcTypeDest == 'C', cLitteral(m.tuValue),;
					m.lcTypeDest $ 'NI', iif(m.tuValue, 1, 0),;
					.null.)

			case m.lcTypeSrce == 'Y'
				luResult = icase(;
					m.lcTypeDest == 'C', transform(m.tuValue),;
					m.lcTypeDest == 'N', mton(m.tuValue),;
					m.lcTypeDest == 'I', int(mton(m.tuValue)),;
					m.lcTypeDest == 'L', not m.tuValue = ntom(0),;
					.null.)

			case m.lcTypeSrce == 'X'
				luResult = uEmpty(m.lcTypeDest)

			otherwise
				luResult = .null.
			endcase
		endif
	endif
endif

return m.luResult

* ------------------------------------
function uValue_TD && {fr} date[-heure] d'après une valeur quelconque
lparameters ;
  tuValue; && {fr} Valeur source
, tcTypeDest; && {fr} Type de valeur attendu selon codification de la fonction VFP varType()

local cMark, lCentury;
, lDate, cDate, cTime;
, liDay, liMonth, liYear

cMark = evl(set("Mark"), '/')
lDate = m.tcTypeDest = 'D'

tuValue = strtran(strtran(strtran(strtran(chrtran(cRepCharDel(alltrim(m.tuValue));
	, '-', m.cMark); && iPhone
	, ' ' + m.cMark, m.cMark);
	, m.cMark + ' ', m.cMark);
	, ' :', ':');
	, ': ', ':');

do case

case !vartype(m.tuValue) == 'C';
 or occurs(m.cMark, m.tuValue) # 2; && 2015-06-16 - {en} default values in case m.tuValue is not a date, eg. "boto" - contributor Gilles Lajot-Sarthou
 or empty(chrtran(m.tuValue, m.cMark+':APM', ''))
	return iif(m.tcTypeDest = 'D', {/}, {/:}) && {en} empty date[-time] {fr} date[-time] vide

case leftc(m.tuValue, 1) == '{' and rightc(m.tuValue, 1) == '}' && {fr} litteral
	return evaluate(m.tuValue)

case 2 # Occurs(m.cMark, m.tuValue)
	assert .F.
	return .null.

case !iDayMonthYear(@m.liDay, @m.liMonth, @m.liYear) && modify command abDate

case varSet(@m.lCentury, 4 = len(getwordnum(m.tuValue, m.liYear, m.cMark))) and m.lCentury

	cDate = getwordnum(m.tuValue, 1)
	liYear = getwordnum(m.cDate, m.liYear, m.cMark)
	liYear = evl(Cast(Iif(Lenc(m.liYear) > 4, rtrim(m.liYear, '0'), m.liYear) as I), year(date())) && {en} year
	liMonth = getwordnum(m.cDate, m.liMonth, m.cMark)
	liMonth = Min(Max(evl(Cast(Iif(Lenc(m.liMonth) > 2, rtrim(m.liMonth, '0'), m.liMonth) as I), month(date())), 1), 12) && {en} month
	liDay = getwordnum(m.cDate, m.liDay, m.cMark)
	liDay = Min(Max(evl(Cast(Iif(Lenc(m.liDay) > 2, rtrim(m.liDay, '0'), m.liDay) as I), day(date())), 1), ICase(; && {en} day
		m.liMonth = 2, 28,;
		InList(m.liMonth, 1, 3, 5, 7, 8, 10, 12), 31,;
		30;
		))

	cTime = getwordnum(m.tuValue, 2)
	
	return Iif(m.lDate;
		, date(m.liYear, m.liMonth, m.liDay);
		, datetime(m.liYear, m.liMonth, m.liDay;
		  , Cast(getwordnum(m.cTime, 1, ':') as I); && {en} hour
		  , Cast(getwordnum(m.cTime, 2, ':') as I); && {fr} minute
		  , Cast(getwordnum(m.cTime, 3, ':') as I); && {en} second
		  );
		)

otherwise
	return Iif(m.lDate, Ctod(m.tuValue), Ctot(m.tuValue))

endcase
endfunc

#if .F.
	liYear = Iif(m.liYear >= 100; && Specifies the year returned in the year 2000-compliant Date value. nYear can be a value from 100 to 9999
		, m.liYear;
		, (Set("Century", 1) + Iif( m.liYear >= Set("Century", 2), 0, 1))* 100 + m.liYear;
		)
#endif

* -----------------------------------------------------------------
procedure uValue_Test && {fr} Teste uValue()

local loUnitTest as abUnitTest of abDev.prg
loUnitTest = newobject('uValue_Test', 'abDev.prg')

loUnitTest.Test(1421.5, '1 421,5', 'N')
loUnitTest.Test(1421.5, '1 421.5', 'N')
* {fr} loUnitTest.Test(1421.5, '1,421.5', 'N') && {fr} échec
loUnitTest.Test($1421.5, '$    1 421.5', 'Y')
loUnitTest.Test(1421, '1 421.5', 'I')

loUnitTest.Test(.t., 'T', 'L')
loUnitTest.Test(.t., 2, 'L')
loUnitTest.Test({}, '23/09/194', 'D') && {fr} date invalide && {fr} ajouté le 15/05/09

loUnitTest.Test({/}, 'boto', 'D') && 2015-06-16 - contributor Gilles Lajot-Sarthou

loUnitTest.Test({^2018-02-01}, '01/020/2018', 'D') && 2018-02-21 thn -- {fr} Méthode ou procédure uValue_td() : erreur n° 11 ("Valeur, type ou nombre d'arguments de fonction, non valide") ? la ligne n° 4,020; Paramètres reçus : Valeur : "01/020/2018"

return loUnitTest.result()

define class uValue_Test as abUnitTest of abDev.prg
		procedure init
		dodefault()
		set separator to chr(160)
		set point to ','
	enddefine

* =================================================
function luEqual && {fr} Deux valeurs sont égales en tenant compte des .NULL.
lparameters ;
  tu1; && {fr} Valeur 1, par référence si Array
, tu2; && {fr} Valeur 2, par référence si Array
, tlStrict; && [.F.] {fr} comparaison de chaînes stricte
, tlCaseIgnore && [.F.] {fr} ignorer la casse
tlStrict = lTrue(m.tlStrict)
tlCaseIgnore = lTrue(m.tlCaseIgnore)

local lcType1, lcType2

lcType1 = type('tu1', 1)
lcType1 = iif(m.lcType1 == 'A', m.lcType1, vartype(m.tu1))
tu1 = iif(m.lcType1 == 'C' and m.tlCaseIgnore, lower(m.tu1), m.tu1)

lcType2 = type('tu2', 1)
lcType2 = iif(m.lcType2 == 'A', m.lcType2, vartype(m.tu2))
tu2 = iif(m.lcType2 == 'C' and m.tlCaseIgnore, lower(m.tu2), m.tu2)

return m.lcType1 == m.lcType2;
	and	(m.lcType1 == 'X';
			or icase(;
				m.lcType1 == 'O', luEqual_Object(m.tu1, m.tu2),;
				m.lcType1 == 'A', laEqual(@m.tu1, @m.tu2),;
				m.lcType1 == 'C' and not m.tlStrict, trim(m.tu1) == trim(m.tu2),;
			 	m.tu1 == m.tu2;
			 	);
		 	)

* --------------------
function luEqual_Object	&& {fr} Deux objets sont identiques
lparameters ;
  tu1; && {fr} objet 1
, tu2 && {fr} objet 2

local laProp[1], lcProp, liItem, la1[1], la2[1], llResult

llResult = m.tu1 = m.tu2 && {fr} référence au même objet
if not m.llResult

	llResult = amembers(laProp, m.tu2) + amembers(laProp, m.tu1) = 0
	if not m.llResult

		for each lcProp in laProp

			llResult = .f.;
			 or inlist(m.lcProp, 'PARENT', 'CONTROLS', 'OBJECTS', 'PAGES', 'COLUMNS');
			 or .t.;
			  and pemstatus(m.tu2, m.lcProp, 5); && {fr} extent
			  and not pemstatus(m.tu1, m.lcProp, 2); && {fr} protected
			  and not pemstatus(m.tu2, m.lcProp, 2); && {fr} protected
				and iif(type('m.tu1.' + m.lcProp, 1) == 'A';
					, .t.;
						and type('m.tu2.' + m.lcProp, 1) == 'A';
						and acopy(m.tu1.&lcProp, la1) = acopy(m.tu2.&lcProp, la2);
						and laEqual(@m.la1, @m.la2);
					, luEqual(getpem(m.tu1, m.lcProp), getpem(m.tu2, m.lcProp));
					)
			if not m.llResult
				exit
			endif
		endfor
	endif

	if m.llResult and loBaseClass(m.tu1, 'Collection')
		llResult = loBaseClass(m.tu2, 'Collection') and m.tu1.count = m.tu2.count
		if m.llResult and  m.tu1.count > 0
			for liItem = 1 to m.tu1.count
				llResult = .t.;
					and luEqual(m.tu1.item(m.liItem), m.tu2.item(m.liItem));
					and m.tu1.getkey(m.liItem) == m.tu2.getkey(m.liItem)
				if not m.llResult
					exit
				endif
			endfor
		endif
	endif
endif

return m.llResult

* --------------------
procedure luEqual_Test && {fr} Teste luEqual

local loUnitTest as abUnitTest of abDev.prg
loUnitTest = newobject('abUnitTest', 'abDev.prg')

loUnitTest.Test(.t., .null., .null.)
loUnitTest.Test(.f., .null., 2)
loUnitTest.Test(.f., 2, .null.)
loUnitTest.Test(.f., 3, 2)
loUnitTest.Test(.f., 3, '2')
loUnitTest.Test(.t., 2, 2)
loUnitTest.Test(.t., 'toto', 'toto')
loUnitTest.Test(.f., 'toto', 'tot')
loUnitTest.Test(.f., 'TOTO ', 'toto', .t., .t.)
loUnitTest.Test(.t., 'TOTO ', 'toto', , .t.)

return loUnitTest.result()

* =================================================
function cSetPath(tlSort) && {fr} Set("Path") bien présenté

local laResult[1]

alines(laResult, set("Path"), 1, ',', ';')
if m.tlSort
	asort(laResult)
endif

return cListOfArray(@m.laResult, CRLF)
endfunc

* =================================================
function cSetProc(tlSort) && {fr} Set("Procedure") bien présenté

local laResult[1]

alines(laResult, set("Procedure"), 1, ',', ';')
if m.tlSort
	asort(laResult)
endif

return cListOfArray(@m.laResult, CRLF)

* =================================================
function cSetClass(tlSort) && {fr} Set("Classlib") bien présenté

local laResult[1]

alines(laResult, set("Classlib"), 1, ',', ';')
if m.tlSort
	asort(laResult)
endif

return cListOfArray(@m.laResult, CRLF)

* =================================================
function cMBcmdCaption && {fr} Label d'un bouton d'une messageBox() d'après son type
lparameters ;
  tiType; && [1] {fr} Type selon doc messageBox()
, tcLang; && [cLangUser()] {fr} Langue
, tlHotKey && [.F.] {fr} souligner la lettre de raccourci
tiType = int(evl(nvl(m.tiType, 0), 1)) && {fr} OK par défaut
tcLang = cLangUser(m.tcLang)

return iif(lTrue(m.tlHotKey), '\<', '');
	+	icase(;
			m.tiType = 1, 'OK',;
			m.tiType = 2, icase(;
        m.tcLang = 'fr',	'Annuler',; && copy-paste this line to add another language support
        m.tcLang = 'es',	'Cancelar',; && copy-paste this line to add another language support
                          'Cancel'),; && default: English
			m.tiType = 3, icase(;
        m.tcLang = 'fr',	'Abandonner',; && copy-paste this line to add another language support
        m.tcLang = 'es',	'Abortar',; && copy-paste this line to add another language support
                          'Abort'),; && default: English
			m.tiType = 4, icase(;
        m.tcLang = 'fr',	'Réessayer',; && copy-paste this line to add another language support
        m.tcLang = 'es',	'Reintentar',; && copy-paste this line to add another language support
                         	'Retry'),; && default: English
			m.tiType = 5, icase(;
        m.tcLang = 'fr',	'Ignorer',; && copy-paste this line to add another language support
        m.tcLang = 'es',	'Ignorar',; && copy-paste this line to add another language support
                          'Ignore'),; && default: English
			m.tiType = 6, icase(;
        m.tcLang = 'fr',	'Oui',; && copy-paste this line to add another language support
        m.tcLang = 'es',	'Sí',; && copy-paste this line to add another language support
                          'Yes'),; && default: English
			m.tiType = 7, icase(;
        m.tcLang = 'fr',	'Non',; && copy-paste this line to add another language support
        m.tcLang = 'es',	'No',; && copy-paste this line to add another language support
                          'No'),; && default: English
			'??';
		)

* =================================================
function nDialogBoxTypeParms && {fr} Composantes du paramètre 'nDialogBoxType' d'une messageBox()
lparameters ;
  nDialogBoxType; && {fr} cf. messageBox()
, tnButtons; && @ (0-5) boutons à afficher
, tnIcon; && @ (16,32,48 ou 64) icône à afficher
, tnDefault && @ (0,256,512) Bouton actif par défaut

tnButtons = bitand(m.nDialogBoxType, bitset(bitset(bitset(0, 0),1),2))
tnButtons = iif(between(m.tnButtons, 0, 5), m.tnButtons, 0)

tnIcon = bitand(m.nDialogBoxType, bitset(bitset(bitset(0, 4),5),6))
tnIcon = iif(inlist(m.tnIcon, 16,32,48,64), m.tnIcon, 0)

tnDefault = bitand(m.nDialogBoxType, bitset(bitset(0, 8),9))
tnDefault = iif(inlist(m.tnDefault, 256, 512), m.tnDefault, 0)

return m.nDialogBoxType

* --------------------
procedure nDialogBoxTypeParms_Test && {fr} Teste nDialogBoxTypeParms()

local loUnitTest as abUnitTest of abDev.prg
loUnitTest = newobject('abUnitTest', 'abDev.prg')

local lnDialogBoxType; && {fr} cf. messageBox()
, lnButtons; && @ (0-5) boutons à afficher
, lnIcon; && @ (16,32,48 ou 64) icône à afficher
, lnDefault && @ (0,256,512) Bouton actif par défaut

lnDialogBoxType = 5
loUnitTest.Test(m.lnDialogBoxType, m.lnDialogBoxType, @m.lnButtons, @m.lnIcon, @m.lnDefault)
loUnitTest.assert(5, m.lnButtons)
loUnitTest.assert(0, m.lnIcon)
loUnitTest.assert(0, m.lnDefault)

lnDialogBoxType = 5+32
loUnitTest.Test(m.lnDialogBoxType, m.lnDialogBoxType, @m.lnButtons, @m.lnIcon, @m.lnDefault)
loUnitTest.assert(5, m.lnButtons)
loUnitTest.assert(32, m.lnIcon)
loUnitTest.assert(0, m.lnDefault)

lnDialogBoxType = 5+32+256
loUnitTest.Test(m.lnDialogBoxType, m.lnDialogBoxType, @m.lnButtons, @m.lnIcon, @m.lnDefault)
loUnitTest.assert(5, m.lnButtons)
loUnitTest.assert(32, m.lnIcon)
loUnitTest.assert(256, m.lnDefault)


lnDialogBoxType = 7+32+256
loUnitTest.Test(m.lnDialogBoxType, m.lnDialogBoxType, @m.lnButtons, @m.lnIcon, @m.lnDefault)
loUnitTest.assert(0, m.lnButtons)
loUnitTest.assert(32, m.lnIcon)
loUnitTest.assert(256, m.lnDefault)

* =================================================
function nScreenDockOffset && {fr} Nombre de colonnes où commence la partie gauche du _Screen du fait des fenêtres dockées à gauche
lparameters tlRows && [.F.] {fr} décalage ; .T.: vertical (rows), .F.: horizontal (cols)
tlRows = lTrue(m.tlRows)

local laDock[1], lnDocks, lnDock, lnResult

lnResult = 0
lnDocks = adockstate(laDock, 1) &&
if m.lnDocks > 0
	for m.lnDock = 1 to m.lnDocks
		if laDock[m.lnDock, 2] = 1;
		 and laDock[m.lnDock, 3] = iif(m.tlRows;
		 	, 0; && {fr} top
		 	, 1); && {fr} left
		 and laDock[m.lnDock, 4] = _screen.caption

			lnResult = m.lnResult + iif(m.tlRows, wrows(laDock[m.lnDock, 1]), wcols(laDock[m.lnDock, 1]))
		endif
	endfor
endif

return m.lnResult

* =================================================
function cABuserDataPath && {fr} Adresse standard du dossier où résident les données AB

local lcResult

lcResult = home(7) + 'AB\' && {en} FoxInCloud subdirectory in the user's Visual FoxPro Application Data directory
if not directory(m.lcResult)
	md (m.lcResult)
endif

return m.lcResult

* ===========================
function cABmoduleTestAddr && {fr} Adresse du fichier de test d'un module
lparameters tcModule
local lcPrevious, lcResult
lcResult = cABuserDataPath() + forceext(m.tcModule, 'tst')

* {fr} Si le fichier est à l'ancienne adresse, déplacer dans la nouvelle
lcPrevious = DOS_AB + forceext(m.tcModule, 'tst')
if lFile(m.lcPrevious)
	FileMove(m.lcPrevious, m.lcResult)
endif

return m.lcResult

* ===========================
function oLocalized && {fr} Objet avec chaînes localisées dans propriétés nommées selon la langue
lparameters ;
  oLocal; && @ {fr} Au moins un contenu localisé a été trouvé
, tcString; && {fr} Chaîne à localiser

if !ga_Type_IsChar(m.tcString, .T.)
	return .F.
endif

local success;
, iLang, cLang, cCont

oLocal = Iif(Vartype(m.oLocal) == 'O', m.oLocal, CreateObject('Empty'))
success = .F.
for iLang = 1 to GetWordCount(SUPPORTED_LANG, ',') && SUPPORTED_LANG: modify file abDev.h
	cLang = GetWordNum(SUPPORTED_LANG, m.iLang, ',')
	cCont = cLocalized(m.tcString, m.cLang, .T.)
	do case
	case !Empty(m.cCont)
		AddProperty(m.oLocal, m.cLang, m.cCont)
		success = .T.
	case !lProperty(m.oLocal, m.cLang)
		AddProperty(m.oLocal, m.cLang, '')
	endcase
endfor

return m.success
endfunc

* ===========================
function cLocalized && {fr} Chaîne localisée
lparameters ;
  tcString; && {fr} Chaîne à localiser
, tcLangUser; && [cLangUser()] {fr} Langue de l'utilisateur
, tlDefNo; && [.F.] {fr} Ne pas servir de valeur défaut

&& see also: modify command abTxt > abLocalized()

if Atc('{', m.tcString) != Atc('}', m.tcString) - 3 && not localized
	return m.tcString
endif

local result as string;
, lcEN as string;

tlDefNo = lTrue(m.tlDefNo)
lcEN = cLocalized_cLang(m.tcString, 'en')

tcLangUser = iif(ga_Type_IsChar(m.tcLangUser, .t.);
	 and varSet(@m.tcLangUser, Lower(Alltrim(m.tcLangUser)));
	 and lenc(m.tcLangUser) = 2;
	 and IsAlpha(m.tcLangUser);
	 and IsAlpha(Substr(m.tcLangUser, 2));
	, m.tcLangUser;
	, cLangUser();
	)

result = cLocalized_cLang(m.tcString, m.tcLangUser)

result = c2Words(;
	  Evl(Left(m.tcString, at_c('{', m.tcString)-1), ''); && {en} before the first localization tag {??}
	, ' ';
	, alltrim(Iif(lTrue(m.tlDefNo), m.result, Evl(m.result, m.lcEN)), CR, LF, ' ', chr(9));
	)

return Iif(m.tlDefNo, m.result, Evl(m.result, m.tcString))
endfunc

* ===========================
function cLocalized_cLang && {fr} Mention d'une chaîne dans une langue donnée
lparameters tcString, tcLang

local result as String;
, iAt as Integer;
, iOc as Integer;
, iNext as Integer;

iAt = atcc('{' + m.tcLang + '}', m.tcString)
result = Iif(m.iAt > 0, substrc(m.tcString, m.iAt + 4), '')

iNext = 0
iOc = 1
do while .T.
	iAt = Atcc('{', m.result, m.iOc)
	do case
	case Empty(m.iAt)
		exit
	case .T.;
	 and isAlpha(Substr(m.result, m.iAt + 1, 1));
	 and isAlpha(Substr(m.result, m.iAt + 2, 1));
	 and Substr(m.result, m.iAt + 3, 1) == '}'
		iNext = m.iAt
		exit
	otherwise
		iOc = m.iOc + 1
	endcase
enddo

return Alltrim(Iif(m.iNext > 1, Leftc(m.result, m.iNext-1), m.result))
endfunc

* ------------------------------------
procedure cLocalized_Test && {fr} Teste cLocalized()

local loUnitTest as abUnitTest of abDev.prg
loUnitTest = newobject('abUnitTest', 'abDev.prg')

loUnitTest.Test([@ formulaire où s'est produit l'événement], [@ {en} requested form {fr} formulaire où s'est produit l'événement], 'fr')
loUnitTest.Test([requested form], [ {en} requested form {fr} formulaire où s'est produit l'événement], 'en')
loUnitTest.Test([requested form], [ {fr} {en} requested form], 'fr') && {fr} fr est vide, alors on prend l'anglais
loUnitTest.Test([test], [test {fr} formulaire où s'est produit l'événement], 'es') && {fr} ni es ni en disponible, on ne prend que l'en-ête

return m.loUnitTest.result()
endproc

* -----------------------------------
function cLangUser && {fr} Code langue de l'utilisateur courant
lparameters ;
  tuLocale; && @ [.F.] {fr} Code langue avec locale (genre 'fr-fr') ou langue forcée

local lcResult as String;
, lcType;
, llForce;
, loShell as wScript.shell

lcType = Vartype(m.tuLocale)
llForce = m.lcType == 'C' and !Empty(m.tuLocale)

do case
case !m.llForce;
 and type('_Screen.cLangUser') == 'C';
 and !empty(_screen.cLangUser)

	tuLocale = _screen.cLangUser
	return m.tuLocale

case !m.llForce

	declare integer GetUserDefaultUILanguage in win32API
	loShell = createobject('wScript.Shell')

	lcResult = alltrim(getwordnum('';
		+ loShell.RegRead("HKLM\Software\Classes\MIME\Database\RFC1766\";
		+ right(transform(GetUserDefaultUILanguage(), '@0'), 4));
		, 1, ';'))

	lcResult = iif(m.lcType == 'L' and m.tuLocale;
		, m.lcResult + iif('-' $ m.lcResult, '', '-' + m.lcResult);
		, left(m.lcResult, 2);
		)

otherwise

	lcResult = alltrim(m.tuLocale)

endcase

store lower(m.lcResult) to lcResult, tuLocale
addproperty(_screen, 'cLangUser', m.lcResult)

return m.lcResult
endfunc

* =====================================================
procedure abUnitTests && {fr} Teste les modules (abUnitTest) du programme appelant

local success;
, lcSys16, lcProcFile, lcProcName;
, lcProcs, lnProc, laProc[1], liProc, lcProc, lcProcU;
, lnProcPrinc, lnProcTest

success = .t.

lcSys16 = sys(16, program(-1) -1) && {fr} calling procedure
lcProcFile = cModuleInfo(m.lcSys16, 'Address', .t.)
lcProcName = cModuleInfo(m.lcSys16, 'Name', .t.)
lcProcs = forceext(m.lcProcFile, 'txt')
strtofile('', m.lcProcs) && {fr} vide la liste

* {fr} Tabuler les éléments contenus dans le fichier source
lnProc = aprocinfo(laProc, forceext(m.lcProcFile, 'PRG')) && 0 (default) - Populates the array with all document information.

* {fr} Si au moins un élément,
if m.lnProc > 0

	asort(m.laProc, 1, -1, 0, 1)

	* {fr} Pour chaque élément
	store 0 to m.lnProcPrinc, m.lnProcTest
	for m.liProc = 1 to m.lnProc

		* {fr} Si l'élément est une procédure
		if upper(laProc[m.liProc, 3]) = 'PROCEDURE'
			lcProc = laProc[m.liProc, 1]
			lcProcU = upper(m.lcProc)

			* {fr} Si procédure principale, lister
			if not '_' $ m.lcProc
				lnProcPrinc = m.lnProcPrinc + 1
				strtofile(str(m.lnProcPrinc, 2) + '-' + m.lcProc + CRLF, m.lcProcs, 1)
			endif

			* {fr} Si procédure de test, exécuter
			if .t.;
			 and rightc(m.lcProcU, lenc('_TEST')) == '_TEST' ;
			 and not m.lcProcU == m.lcProcName && {fr} this procedure
			 	?
			 	lnProcTest = m.lnProcTest + 1
				wait window textmerge("<<m.lcProcFile>>!<<m.lcProc>>() [<<m.lnProcTest>>]") at 10, 10 nowait noclear
				success = evaluate(m.lcProc + '()') and m.success
			endif
		endif
	endfor
	wait clear
endif

return m.success

* =============================================
function abUnitTest && {fr} Objet abUnitTest
lparameters ;
  tcModule; && [Module appelant sans le suffixe '_test'] {fr} Nom du module à tester
, tcAddress && [Adresse du code source du module appelant] {fr} Adresse contenant le répertoire où créer le Compte-rendu de test
return createobject('abUnitTest', m.tcModule, m.tcAddress)
endfunc

* =============================================
define class abUnitTest as session
* =============================================

lSingleTest = .f. && {fr} exécuter seulement une fois && {fr} cas où la fonction à tester produit un résultat cumulatif et/ou des tableaux

protected ;
  lResult;
, nTest; && {fr} Nombre de tests réalisés sur le module
, aTest[1,1]; && {fr} Résultats des tests
, cModule; && {fr} Nom du module à tester
, cAddress; && {fr} Adresse du fichier contenant le module à tester
, oObject; && {fr} Référence à l'objet si le module est une méthode
, lResult; && {fr} Résultat des tests ; .T. si tous réussis
, lResultOut; && {fr} Les résultats des tests ont été sortis
, cResultAddr; && {fr} Adresse du fichier de résultats
, lCoverage; && {fr} Enclenche le Coverage lors du test
, cCoverageAddr; && {fr} Adresse du Fichier de Coverage

nTest = 0 && {fr} Nombre de tests réalisés
lResult = .t. && {fr} Résultat des testes (.T. tant qu'aucun test n'est réalisé)

* -----------------------------------
procedure init
lparameters ;
  tcModule; && [Module appelant sans le suffixe '_test'] {fr} Nom du module à tester
, tcAddress; && [Adresse du code source du module appelant] {fr} Adresse contenant le répertoire où créer le Compte-rendu de test

set sysformats on
set multilocks on

this.addproperty('oEscape', abSet('ESCAPE', 'ON'))
this.addproperty('oAsserts', abSet('ASSERTS', 'ON'))

local lcModule, lcAddress, llResult

* {fr} Si le nom du module n'est pas précisé, prendre le défaut
llResult = vartype(m.tcModule) == 'C' and not empty(m.tcModule)
if m.llResult
	lcModule = m.tcModule
	lcAddress = m.tcAddress
else
	lcModule = evl(this.cModuleDefault(cCallingModule(@m.lcAddress)), this.cModuleDefault(cCallingModule(@m.lcAddress, -1)))
	llResult = not empty(m.lcModule)
endif

* {fr} Si le nom du module est défini, vérifier son existence
if m.llResult

	llResult = this.ModuleSet(m.lcModule, m.lcAddress)

	* {fr} Si le module est exécutable, régler la session de données
	if m.llResult
		set memowidth to wcols(wontop()) && {fr} Fenêtre résultats du test
	endif
endif

if directory(DOS_AB)

	* {fr} S'il existe des fichiers de test ou de coverage à l'ancienne adresse, déplacer à la nouvelle
	local laFiles[1], lcFile
	if aFiles(@m.laFiles, DOS_AB + '*.tst') > 0
		for each lcFile in laFiles
			FileMove(DOS_AB + m.lcFile, cABmoduleTestAddr(juststem(m.lcFile)))
		endfor
	endif
	if aFiles(@m.laFiles, DOS_AB + '*.cov') > 0
		for each lcFile in laFiles
			FileMove(DOS_AB + m.lcFile, cABuserDataPath() + m.lcFile)
		endfor
	endif
endif

return m.llResult

* -----------------------------------
procedure EnvSet && {fr} Règle l'environnement de la session de données privée avant le(s) test(s)
lparameters tcEnvCommand && {fr} Commande d'environnement
if ga_Type_IsChar(m.tcEnvCommand, .T.)
	&tcEnvCommand
	return .T.
endif
return .F.
endproc

* -----------------------------------
procedure ModuleSet && {fr} Définit le nom et l'adresse du module à tester
lparameters ;
  tcModule; && [Module appelant sans le suffixe '_test'] {fr} Nom du module à tester
, tcAddress && [Adresse du code source du module] {fr} Répertoire où créer le fichier de CR de test
local llResult

* {fr} Si le module est spécifié correctement
local lcModule, lcAddress
lcModule = evl(m.tcModule, cCallingModule(@m.lcAddress))
lcAddress = cFileCased(evl(m.tcAddress, m.lcAddress))
llResult = not empty(m.lcModule) and file(m.lcAddress)
assert m.llResult message cAssertMsg(textmerge([le nom et/ou l'adresse de module est incorrect]))
if m.llResult

	* {fr} Si le module existe
	local lnError, lcError, loAsserts
	lnError = 0
	lcError = on('ERROR')
	on error m.lnError = error() && {fr} this.ModuleSet_nError(cModuleInfo(Sys(16)))
	loAsserts = abSet('ASSERTS', 'OFF')
	evaluate(m.lcModule + "(this, 'junk', Date(), 0, .F.)")
	on error &lcError
	release loAsserts
	llResult = not m.lnError = 1 && {fr} file not found
	assert m.llResult message cAssertMsg(textmerge([le module " + m.lcModule + " ne peut être exécuté.]))
	if m.llResult

		* {fr} Mémoriser le nom du module
		this.cAddress = m.lcAddress
		this.cModule  = m.lcModule

		* {fr} Définir l'adresse de son fichier résultats
		this.cResultAddr = cABmoduleTestAddr(m.lcModule)
		this.cCoverageAddr = forceext(this.cResultAddr, 'cov.log')
	else
		store '' to this.cModule, this.cResultAddr, this.cCoverageAddr
	endif
endif

return m.llResult

* -----------------------------------
hidden function ModuleSet_nError && {fr} N° d'erreur rencontrée lors de la tentative d'exécution du module
lparameters ;
  tcProc && {fr} Nom de la procédure où retourner en cas d'erreur

return && {fr} TO ModuleSet

* -----------------------------------
hidden function cModuleDefault && {fr} Nom du module à tester d'après le nom du module appelant
lparameters tcCallingModule && {fr} Se termine normalement par '_Test'

local lcTest, lnTest, lcResult
lcResult = ''

if vartype(m.tcCallingModule) == 'C'

	tcCallingModule = juststem(upper(alltrim(m.tcCallingModule)))
	lcTest = '_TEST'
	lnTest = len(m.lcTest)
	if right(m.tcCallingModule, m.lnTest) == m.lcTest

		lcResult = left(m.tcCallingModule, len(m.tcCallingModule) - m.lnTest)
	endif
endif

return m.lcResult

* -----------------------------------
procedure CoverageSet && {fr} Démarre / arrête l'enregistrement des temps d'exécution pendant le test
lparameters tlCoverage && [.F.] {fr} démarrer / arrêter l'enregistrement pendant le test

this.lCoverage = lTrue(m.tlCoverage)

* -----------------------------------
procedure CoverageClear && {fr} Efface le fichier de coverage

delete file (m.this.cCoverageAddr)

* -----------------------------------
procedure Test && {fr} Teste le module
lparameters ;
  tuExpected; && @ {fr} Résultat attendu retourné par le module testé - .NULL. : résultat attendu inconnu
, tuParm01,tuParm02,tuParm03,tuParm04,tuParm05,tuParm06,tuParm07,tuParm08,tuParm09,tuParm10,tuParm11,tuParm12,tuParm13,tuParm14 && @ {fr} paramètres passés au module testé

local luResult as Variant; && {fr} résultat du test
, lnParm;
, lcParms;
, liParm;
, luParm;
, lnElapsed;
, laStatus1[1];
, laStatus2[1];

luResult = .null.

* {fr} Si le module est bien défini
if empty(this.cModule)
	return .f.
else

	* {fr} Bâtir la chaine des paramètres à passer au module
	lnParm = max(pcount() - 1, 0)
	lcParms = this.Test_cParms(m.lnParm) && {fr} liste des paramètres à passert au module testé

	#define NCOLSFIXES 8 && /!\ utilisé par this.Test_aTestsDim()

	* {fr} Ajuster le tableau de résultats de tests
	this.nTest = this.nTest + 1
	this.Test_aTestsDim(m.lnParm)
	this.aTest[m.this.nTest, NCOLSFIXES] = m.lnParm && {fr} Nombre de paramètres passés (peut varier d'un test à l'autre)

	if m.lnParm > 0
		for liParm = 1 to m.lnParm
			luParm = evaluate(this.Test_cParm(m.liParm)) && {fr} Valeur du paramètre
			this.aTest[m.this.nTest, NCOLSFIXES + m.liParm] = iif(vartype(m.luParm) == 'C';
				, '"' + m.luParm + '"';
				, cLitteral(m.luParm);
				)
		endfor
	endif

* {fr} Exécuter le test
* ===========================
	luResult = this.Test_Exec(; && {fr} si le résultat est objet, littéral de cet objet
		  m.lcParms;
		, @m.lnElapsed;
		, @m.laStatus1;
		, @m.laStatus2;
		, @m.tuParm01;
		, @m.tuParm02;
		, @m.tuParm03;
		, @m.tuParm04;
		, @m.tuParm05;
		, @m.tuParm06;
		, @m.tuParm07;
		, @m.tuParm08;
		, @m.tuParm09;
		, @m.tuParm10;
		, @m.tuParm11;
		, @m.tuParm12;
		, @m.tuParm13;
		, @m.tuParm14;
		)
* ===========================

	* {fr} Tabuler le résultat du test
	local lcStatus
	this.aTest[m.this.nTest, 1] = this.lCoverage && {fr} Coverage ON
	this.aTest[m.this.nTest, 2] = m.lnElapsed && {fr} Temps d'exécution (non significatif si COVERAGE)
	this.aTest[m.this.nTest, 3] = empty(pcount()) or isNull(m.tuExpected) or luEqual(iif(vartype(m.tuExpected ) == 'O', cL(m.tuExpected), m.tuExpected), m.luResult) && {fr} Valeur produite = valeur attendue && {fr} Empty(m.tuExpected) OR
	this.aTest[m.this.nTest, 4] = m.tuExpected && {fr} Résultat attendu
	this.aTest[m.this.nTest, 5] = m.luResult && {fr} Résultat produit
	this.aTest[m.this.nTest, 6] = this.lStatus(@m.laStatus1, @m.laStatus2, @m.lcStatus) && {fr} Environnement modifié ?
	this.aTest[m.this.nTest, 7] = m.lcStatus && {fr} Modification d'environnement éventuelle
endif

return m.luResult

* -----------------------------------
procedure assert && {fr} Teste une valeur (par exemple élément d'un tableau résultat)
lparameters ;
  tuExpected; && @ {fr} Résultat attendu
, tuObtained; && @ {fr} Valeur obtenue

if pcount() >= 2

	this.aTest[m.this.nTest, 3] = luEqual(@m.tuExpected, @m.tuObtained) && {fr} Valeur produite == valeur attendue

	assert m.this.aTest[m.this.nTest, 3] message cAssertMsg(textmerge(icase(;
		cLangUser() = 'fr',	[Échec d'assertion au test n° <<m.this.nTest>> - résultat attendu: <<cL(m.tuExpected)>>, obtenu: <<cL(m.tuObtained)>>],; && copy-paste this line to add another language support
		 										[Assertion failed at test # <<m.this.nTest>> - result expected: <<cL(m.tuExpected)>>, obtained: <<cL(m.tuObtained)>>]; && Default: English
		)))

else

	this.aTest[m.this.nTest, 3] = cast(m.tuExpected as L)

	assert m.this.aTest[m.this.nTest, 3] message cAssertMsg(textmerge(icase(;
		cLangUser() = 'fr',	[Échec d'assertion au test n° <<m.this.nTest>>],; && copy-paste this line to add another language support
		 										[Assertion failed at test # <<m.this.nTest>>]; && Default: English
		)))

endif

return m.this.aTest[m.this.nTest, 3]

* -----------------------------------
hidden function Test_cParm && {fr} Nom d'un paramètre selon sa position
lparameters tiParm && {fr} Position du paramètre

return 'tuParm' + padl(m.tiParm, 2, '0')

* -----------------------------------
hidden procedure Test_cParms && {fr} Liste de paramètres à passer au module testé
lparameters ;
  tnParms && {fr} Nombre de paramètres passés à this.test()

local lcResult && {fr} Liste de paramètres
lcResult = ''

if m.tnParms > 0

	* {fr} Pour chaque paramètre passé
	local liParm, lcParm
	for liParm = 1 to m.tnParms

		* {fr} Reconstituer le nom du paramètre
		lcParm = '@' + this.Test_cParm(m.liParm)

		* {fr} Ajouter au résultat en passant par référence
		lcResult = c2Words(m.lcResult, ',', m.lcParm)
	endfor
endif

return m.lcResult

* -----------------------------------
hidden procedure Test_Exec && {fr} Exécute le test du module
lparameters ;
  tcParms; && {fr} Chaîne de paramètres à passer au module testé
, tnElapsed; && @ {fr} Temps d'exécution en millisecondes
, taStatus1; && @ {fr} Environnement avant exécution du test
, taStatus2; && @ {fr} Environnement après exécution du test
, tuParm01,tuParm02,tuParm03,tuParm04,tuParm05,tuParm06,tuParm07,tuParm08,tuParm09,tuParm10,tuParm11,tuParm12,tuParm13,tuParm14

external array taStatus1, taStatus2

local luResult as Variant; && {fr} Résultat du module testé
, lnParm, liParm, lcParm, lcParm_;
, lnRows, lnCols;
, lcArray;
, lnAttempt;
, liAttempt;
, lnSeconds;

* {fr} Sauvegarder les paramètres
lnParm = pcount() - 4
for liParm = 1 to m.lnParm
	lcParm = this.Test_cParm(m.liParm)
	lcParm_ = m.lcParm + '_'
	if type(m.lcParm, 1) == 'A'
		lnRows = alen(&lcParm, 1)
		lnCols = alen(&lcParm, 2)
		lcArray = m.lcParm_ + textmerge(iif(m.lnCols > 0, '[<<m.lnRows>>,<<m.lnCols>>]', '[<<m.lnRows>>]'))
		local array &lcArray
		acopy(&lcParm, &lcParm_)
	else
		local (m.lcParm_)
		store evaluate(m.lcParm) to (m.lcParm_)
	endif
endfor

lnAttempt = 1
do while .t.

	* {fr} Si c'est le premier test
	if m.lnAttempt = 1

		* {fr} Mémoriser l'environnement VFP AVANT l'exécution
		this.aStatus(@m.taStatus1)

		* {fr} Si le coverage a été demandé, le démarrer
		if m.this.lCoverage
			local lcCoverage
			lcCoverage = set('COVERAGE', 1)
			set coverage to (m.this.cCoverageAddr) additive
		endif
	endif

	tnElapsed = 0 && see https://www.sweetpotatosoftware.com/blog/index.php/2005/06/29/execution-time-for-vfp/ and http://fox.wikis.com/wc.dll?Wiki~csnwHighResTimer
	for liAttempt = 1 to m.lnAttempt

		* {fr} Restaurer les paramètres
		for liParm = 1 to m.lnParm
			lcParm = this.Test_cParm(m.liParm)
			lcParm_ = m.lcParm + '_'
			if type(m.lcParm_, 1) == 'A'
				lnRows = alen(&lcParm_, 1)
				lnCols = alen(&lcParm_, 2)
				lcArray = m.lcParm + textmerge(iif(m.lnCols > 0, '[<<m.lnRows>>,<<m.lnCols>>]', '[<<m.lnRows>>]'))
				dimension &lcArray
				acopy(&lcParm_, &lcParm)
			else
				store evaluate(m.lcParm_) to (m.lcParm)
			endif
		endfor

		* {fr} Exécuter la procédure / fonction
		* ===========================================================
		lnSeconds = seconds()
		luResult = evaluate(this.cModule + '(' + m.tcParms + ')')
		tnElapsed = m.tnElapsed + nMS(m.lnSeconds) && {fr} millisecondes
		* ===========================================================

	endfor

	luResult = iif(vartype(m.luResult) == 'O'; && {fr} exécute .Destroy()
		, cL(m.luResult);
		, m.luResult;
		)

	* {fr} Si c'est le premier test
	if m.lnAttempt = 1

		* {fr} Si le coverage a été demandé, l'arrêter
		if this.lCoverage
			set coverage to &lcCoverage
		endif

		* {fr} Mémoriser l'environnement VFP après l'exécution
		this.aStatus(@m.taStatus2)
	endif

	* {fr} Si le temps d'exécution est significatif, terminer
	if .f.;
	 or m.this.lCoverage;  && {fr} avec Coverage, une seule exécution
	 or m.this.lSingleTest; && {fr} simple test demandé
	 or m.tnElapsed > 2 && && {fr} millisecondes (précision au moins 5%)

		exit

	* {fr} sinon, répéter le test
	else
		lnAttempt = m.lnAttempt * 10
	endif
enddo

tnElapsed = m.tnElapsed / m.lnAttempt


* {fr} this.lSingleTest = .F.

return m.luResult

* -----------------------------------
hidden procedure Test_aTestsDim && {fr} Dimensionne le tableau des résultats pour recevoir ceux du dernier test
lparameters tnParms && {fr} Nombre de paramètres passés pour le test courant

local lnCols
lnCols = alen(this.aTest, 2)

* {fr} Ajouter une nouvelle LIGNE au tableau de test
dimension this.aTest[m.this.nTest, m.lnCols]

* {fr} Si nouveaux paramètres,
local lnColsParms
lnColsParms = NCOLSFIXES + m.tnParms
if m.lnColsParms > m.lnCols

	* {fr} Ajouter le nombre de COLONNES nécessaires au tableau résultat
	local array laTests[1]
	acopy(this.aTest, m.laTests)
	aColsIns(@m.laTests, m.lnCols, m.lnColsParms - m.lnCols)
	dimension this.aTest[m.this.nTest, m.lnColsParms]
	acopy(m.laTests, this.aTest)
endif

* -----------------------------------
procedure result

if not this.lResultOut
	this.ResultOut()
endif

return this.lResult

* -----------------------------------
hidden procedure ResultOut && {fr} Sort le résultat des test à l'écran et dans le log de test

local lcResult, llResult

lcResult = this.cResult()
llResult = not empty(m.lcResult)
assert m.llResult message cAssertMsg("Aucun résultat de test à sortir !")
if m.llResult

	llResult = strtofile(m.lcResult, m.this.cResultAddr, .t.) > 0
	assert m.llResult message cAssertMsg(textmerge([Impossible d'écrire les résultats dans le fichier <<cLitteral(m.this.cResultAddr)>>]))
	? m.lcResult
	debugout m.lcResult

	this.lResultOut = m.llResult
endif

return m.llResult

* -----------------------------------
hidden function cResult && {fr} Résultat de test(s)

local lcResult;
, lnCoverage, lnElapsed, lnElapsedMin, lnElapsedMax, lnElapsedAvg, lnSuccess;
, lnTest, lnCoverageLess, lcCoverage, lnFailure;

lcResult = ''

* {fr} Si le module est défini
if .t.;
 and vartype(this.cModule) == 'C' ;
 and not empty(this.cModule)

	* {fr} Si des tests ont été réalisés sur le module
	if m.this.nTest > 0

		* {fr} Pour chaque test réalisé
		lnElapsedMin = 10^10
		store 0 to m.lnCoverage, m.lnElapsedMax, m.lnElapsedAvg, m.lnSuccess
		for lnTest = 1 to this.nTest

			* {fr} Synthétiser les résultats
			if this.aTest[m.lnTest, 1] && {fr} les temps d'exécution avec COVERAGE ON ne sont pas significatifs
				lnCoverage = m.lnCoverage + 1
			else
				lnElapsed = uDefault(this.aTest[m.lnTest, 2], 0)
				lnElapsedMin = min(m.lnElapsedMin, m.lnElapsed)
				lnElapsedMax = max(m.lnElapsedMax, m.lnElapsed)
				lnElapsedAvg = m.lnElapsedAvg + m.lnElapsed
			endif
			lnSuccess = m.lnSuccess + ;
				iif(this.aTest[m.lnTest, 3] and this.aTest[m.lnTest, 6], 1, 0)
		endfor

		* {fr} Rectifier le temps moyen en cas de coverage sur certains tests
		lnCoverageLess = this.nTest - m.lnCoverage
		if m.lnCoverageLess > 0
			lnElapsedAvg = m.lnElapsedAvg / m.lnCoverageLess
		endif
		lcCoverage = Iif(m.lnCoverage > 0, [ dans '] + m.this.cCoverageAddr + ['], '')

		* {fr} Compter les échecs
		lnFailure = this.nTest - m.lnSuccess

		text TO m.lcResult TEXTMERGE NOSHOW FLAGS 1
===========================================
<<Datetime()>>
Module : <<DisplayPath(m.this.cAddress, 50)>>!<<this.cModule>>()
Résultats de <<m.this.nTest>> test<<Iif(this.nTest = 1, '', 's')>> dont <<m.lnCoverage>> avec coverage<<m.lcCoverage>>
<<Iif(m.lnCoverageLess > 0, "Temps d'exécution sans coverage Mini | Moyen | Maxi : " + this.cMS(m.lnElapsedMin) + '|' + this.cMS(m.lnElapsedAvg) + '|' + this.cMS(m.lnElapsedMax), '')>>

		ENDTEXT

		* {fr} Si au moins un test a réussi
		if m.lnSuccess > 0

			text TO m.lcResult ADDITIVE TEXTMERGE NOSHOW FLAGS 1
---------------------------------------------
<<m.lnSuccess>> <<Iif(m.lnSuccess = 1, "test réalisé", "tests réalisés")>> avec succès

			ENDTEXT
		endif

		* {fr} Si au moins un test a échoué
		this.lResult = m.lnFailure = 0
		if not this.lResult
			text TO m.lcResult ADDITIVE TEXTMERGE NOSHOW FLAGS 1
---------------------------------------------
<<m.lnFailure>> <<Iif(m.lnFailure = 1, "test a échoué", "tests ont échoué")>> :

			ENDTEXT

			local lnParms, liParm, lcParms;
			, llString, liString, lcString

			* {fr} Pour chaque test échoué
			for lnTest = 1 to this.nTest
				do case

				* {fr} Cas où l'échec est dû à un mauvais résultat
				case not m.this.aTest[m.lnTest, 3]

					* {fr} S'il y en a des paramètres, lister leurs valeurs sous forme de constantes
					lnParms = this.aTest[m.lnTest, NCOLSFIXES]
					lcParms = ''
					if m.lnParms > 0
						for liParm = 1 to m.lnParms
							lcParms = m.lcParms + CRLF;
								+ chr(9) + '  ' + transform(m.liParm) + '. ' + this.aTest[m.lnTest, NCOLSFIXES + m.liParm]
						endfor
					endif

					llString = vartype(this.aTest[m.lnTest, 4]) == 'C'
					lcString = ''
					for liString = 1 to iif(m.llString, lenc(this.aTest[m.lnTest, 4]), 0)
						lcString = substrc(m.this.aTest[m.lnTest, 4], m.liString, 1)
						if not m.lcString == substrc(m.this.aTest[m.lnTest, 5], m.liString, 1)
							lcString = textmerge([Différence au caractère <<m.liString>> (<<cL(m.lcString)>>) du résultat attendu]) + CRLF
							exit
						endif
					endfor

					* {fr} écrire le n° de test, les résultats attendus et obtenus, les paramètres
					local lcType
					lcType = vartype(this.aTest[m.lnTest, 5])
					text TO m.lcResult ADDITIVE TEXTMERGE NOSHOW FLAGS  1

- Test n° : <<m.lnTest>>
	Resultats :
	- attendu:	<<Iif(m.llString, '"' + this.aTest[m.lnTest, 4] + '"', cLitteral(this.aTest[m.lnTest, 4]))>>
	- obtenu :	<<ICase(m.lcType == 'C' and Lower(Leftc(this.aTest[m.lnTest, 5], Len('Object '))) == Lower('Object '), this.aTest[m.lnTest, 5], m.lcType == 'C', '"' + this.aTest[m.lnTest, 5] + '"', cLitteral(this.aTest[m.lnTest, 5]))>>
	<<m.lcString>><<m.lnParms>> paramètres passés<<Iif(m.lnParms > 0, ' :', '')>><<m.lcParms>>

					ENDTEXT

				* {fr} Cas où l'échec est dû à une modification d'environnement
				case not this.aTest[m.lnTest, 6]

					* {fr} écrire la variable d'environnement modifiée
					text TO m.lcResult ADDITIVE TEXTMERGE NOSHOW

- Test n° <<m.lnTest>>
	L'environnement VFP a changé comme suit :
		<<this.aTest[m.lnTest, 7]>>

					ENDTEXT

				endcase
			endfor
text TO m.lcResult ADDITIVE TEXTMERGE NOSHOW
===========================================

ENDTEXT
		endif

	else
		lcResult = "Aucun test n'a été réalisé sur le module" + space(1) + this.cModule
	endif
endif

return m.lcResult

* -----------------------------------
hidden function cMS && {fr} Temps en avec unité millisecondes
lparameters tnMS && {fr} Temps en millisecondes
return space(1) + ltrim(transform(m.tnMS, '9,999.999  ms'))

* -----------------------------------
hidden function aStatus && {fr} Environnement Visual FoxPro
lparameters taStatus && @ {fr} Tableau de statut

local lnStatus, lcStatus, laUsed[1], lnResult && {fr} Nombre d'éléments d'environnement

* {fr} Tabuler les éléments de statut
lnResult = alines(m.taStatus, this.cStatus(), .t.)
aColsIns(@m.taStatus) && {fr} ajoute une colonne pour les résultats

* {fr} Pour chaque élément de statut valide
for lnStatus = 1 to m.lnResult

	lcStatus = m.taStatus[m.lnStatus, 1]
	if not lCommentLine(m.lcStatus)

		* {fr} Évaluer
		try
			taStatus[m.lnStatus, 2] = evaluate(m.lcStatus)
		catch
		endtry
	endif
endfor

return m.lnResult

external procedure lCommentLine && {fr} dans abModuleDir.prg

* -----------------------------------
hidden function cStatus && {fr} Environnement Visual FoxPro
local lcResult

text TO m.lcResult NOSHOW PRETEXT 1+2+4

* {fr} Nombre de tables ouvertes
AUsed(laUsed)

* {fr} Zone de travail courante
Select(0)
Alias()
Recno()
Order()
Filter()
Relation(1)
Relation(2)
Relation(3)
Relation(4)
Relation(5)
Target(1)
Target(2)
Target(3)
Target(4)
Target(5)

* {fr} Sets
Set("Alternate")
Set("Alternate",1)
Set("Ansi")
Set("Asserts")
Set("Autosave")
Set("Bell")
Set("Bell",1)
Set("Blocksize")
Set("Browseime")
Set("Carry")
Set("Century")
Set("Century",1)
Set("Century",2)
Set("Century",3)
Set("Classlib")
Set("Clock")
Set("Clock",1)
Set("Collate")
Set("Color")
Set("Compatible")
Set("Compatible",1)
Set("Confirm")
Set("Console")
Set("Coverage", 1)
Set("Cpcompile", 1)
Set("Cpdialog")
Set("Currency")
Set("Currency", 1)
Set("Cursor")
Set("Database")
Set("Datasession")
Set("Date")
Set("Date",1)
Set("Debug")
Set("Debugout")
Set("Decimals")
Set("Default")
Set("Deleted")
Set("Delimiters")
Set("Delimiters",1)
Set("Development")
Set("Device")
Set("Display")
Set("Echo")
Set("Escape")
Set("Eventlist")
Set("Eventtracking")
Set("Eventtracking",1)
Set("Exact")
Set("Exclusive")
Set("Fdow")
Set("Fields")
Set("Fields",1)
Set("Fields",2)
Set("Filter")
Set("Fixed")
Set("Fullpath")
* {fr} Set("Function") && {fr} je ne sais pas comment ça marche
Set("Fweek")
Set("Headings")
Set("Help")
Set("Help",1)
Set("Help",2)
Set("Help",3)
Set("Helpfilter")
Set("Hours")
Set("Key")
Set("Key",1)
Set("Key",2)
Set("Keycomp")
Set("Library")
Set("Lock")
Set("Logerrors")
Set("Mackey")
Set("Margin")
Set("Mark")
Set("Memowidth")
Set("Message")
Set("Message",1)
Set("Mouse")
Set("Mouse",1)
Set("Multilocks")
Set("Near")
Set("Nocptrans")
Set("Notify")
Set(".NULL.")
Set("Nulldisplay")
Set("Odometer")
Set("Oleobject")
Set("Optimize")
Set("Order")
Set("Palette")
Set("Path")
Set("Pdsetup")
Set("Point")
Set("Printer")
Set("Printer",1)
Set("Printer",2)
Set("Printer",3)
Set("Procedure")
Set("Readborder")
Set("Refresh")
Set("Refresh",1)
Set("Reprocess")
Set("Resource")
Set("Resource",1)
Set("Safety")
Set("Seconds")
Set("Skip")
Set("Space")
Set("Status")
Set("Status Bar")
Set("Step")
Set("Strictdate")
Set("Sysformats")
Set("Sysmenu")
Set("Talk")
Set("Talk",1)
Set("Textmerge")
Set("Textmerge",1)
Set("Textmerge",2)
Set("Textmerge",3)
Set("Textmerge",4)
Set("Topic")
Set("Topic",1)
Set("Trbetween")
Set("Typeahead")
Set("Udfparms")
Set("Unique")
Set("View")
ENDTEXT

return m.lcResult

* -----------------------------------
hidden function lStatus && {fr} Compare deux environnements VFP
lparameters ;
  taStatus1; && @ {fr} Tableau de statut 1 (créé par this.aStatus())
, taStatus2; && @ {fr} Tableau de statut 2 (créé par this.aStatus())
, tcModifs && @ {fr} Éléments d'environnement ayant évolué (si m.llResult = .F.)

local llResult && {fr} L'environnement VFP est identique
llResult = .null.
tcModifs = ''

* {fr} Si le statut a bien été tabulé après test
local lnStatusCount
lnStatusCount = alen(m.taStatus1, 1)
if alen(m.taStatus2, 1) = m.lnStatusCount

	* {fr} Pour chaque élément d'environnement
	local lnStatus, llStatus
	llResult = .t.
	for lnStatus = 1 to m.lnStatusCount

		* {fr} Si l'élément n'a pas la même valeur dans les 2 tableaux
		llStatus = m.taStatus1[m.lnStatus, 2] == m.taStatus2[m.lnStatus, 2]
		if not m.llStatus

			* {fr} Ajouter la modification au message retourné
			tcModifs = c2Words(m.tcModifs, CRLF, ;
				taStatus1[m.lnStatus, 1] + ;
				space(1) + '-' + space(1) + 'avant Test : ' + cLitteral(m.taStatus1[m.lnStatus, 2]) + ;
				space(1) + '-' + space(1) + 'après Test : ' + cLitteral(m.taStatus2[m.lnStatus, 2]))
			llResult = .f.
		endif
	endfor
endif

return m.llResult

* -----------------------------------
procedure destroy

* {fr} Sortir le résultat si ça n'a pas été fait
if not this.lResultOut
	this.ResultOut()
endif

* {fr} Fermer proprement les Aliases ouverts pour le(s) test(s)
local laAlias[1], lcAlias
if aused(m.laAlias) > 0
	for each lcAlias in laAlias
		use in (m.lcAlias)
	endfor
endif

* =============================================
enddefine && {fr} CLASS abUnitTest
* =============================================

* -----------------------------------
function FooTest && {fr} Bidon pour démontrer la classe de test abUnitTest
lparameters tuFoo

local lcType, luResult
lcType = vartype(m.tuFoo)

do case

case m.lcType == 'C' && {fr} échec car changement de Set("Deleted")
	local lcDeleted
	lcDeleted = set("Deleted")
	lcDeleted = iif(m.lcDeleted == 'ON', 'OFF', 'ON')
	set deleted &lcDeleted
	luResult = m.tuFoo

case m.lcType == 'N'
	luResult = 2 * m.tuFoo

case m.lcType == 'L'
	luResult = not m.tuFoo

case m.lcType == 'D'
	luResult = m.tuFoo + 10

otherwise
	luResult = .f.
endcase

return m.luResult

* ========================================
function nPixOfFox && {en} Pixels of a Foxels measurement
lparameter ;
  tnFoxels; && {en} foxels to convert
, tlVertical; && [.F.] {en} convert horizontal/vertical coordinates
, tcFontName; && [current font for the active output window] {en} font name
, tnFontSize; && [current font for the active output window] {en} font size
, tcFontStyle; && ['N'ormal] {en} font style

return Nvl(Evl(m.tnFoxels, 0), 0) * fontmetric(;
	  iif(lTrue(m.tlVertical), 1, 6);
	, evl(m.tcFontName, wfont(1));
	, evl(m.tnFontSize, wfont(2));
	, evl(m.tcFontStyle, 'N');
	)
endfunc

* ========================================
function nFoxOfPix && {en} Foxels of a Pixels measurement
lparameter ;
  tnPixels; && {en} pixels to convert
, tlVertical; && [.F.] {en} convert horizontal/vertical coordinates
, tcFontName; && [current font for the active output window] {en} font name
, tnFontSize; && [current font for the active output window] {en} font size
, tcFontStyle; && ['N'ormal] {en} font style

return Nvl(Evl(m.tnPixels, 0), 0) / fontmetric(;
	  iif(lTrue(m.tlVertical), 1, 6);
	, evl(m.tcFontName, wfont(1));
	, evl(m.tnFontSize, wfont(2));
	, evl(m.tcFontStyle, 'N');
	)

endfunc
*------------------------------------
function Fox2Pix && {en} pixels of foxels && courtesy Sergey Berezniker http://www.berezniker.com/content/pages/visual-foxpro/pixels-and-foxels
lparameters ;
  tnFoxels; && {en} foxels to convert
, tlVertical; && [.F.] {en} vertical coordinates
, tcFontName; && [current font for the active output window] {en} font name
, tnFontSize; && [current font for the active output window] {en} font size
, tcFontStyle; && ['N'] {en} font style

return Iif(Pcount() < 4;
	, m.tnFoxels * Fontmetric(Iif(lTrue(m.tlVertical), 1, 6));
	, m.tnFoxels * Fontmetric(Iif(lTrue(m.tlVertical), 1, 6), m.tcFontName, m.tnFontSize, Evl(m.tcFontStyle, 'N'));
	)
endfunc

*------------------------------------
function Pix2Fox && {en} foxels of pixels && courtesy Sergey Berezniker http://www.berezniker.com/content/pages/visual-foxpro/pixels-and-foxels
lparameters ;
  tnPixels; && {fr} pixels to convert
, tlVertical; && [.F.] {en} vertical coordinates
, tcFontName; && [current font for the active output window] {en} font name
, tnFontSize; && [current font for the active output window] {en} font size
, tcFontStyle; && ['N'] {en} font style

local lnResult, llResult

lnResult = Iif(Pcount() < 4;
	, m.tnPixels / Fontmetric(Iif(lTrue(m.tlVertical), 1, 6));
	, m.tnPixels / Fontmetric(Iif(lTrue(m.tlVertical), 1, 6), m.tcFontName, m.tnFontSize, Evl(m.tcFontStyle, 'N'));
	)

llResult = between(m.lnResult, -32768+1, 32767-1) && 19/12/13 - Invalid coordinates (Error 1959) Coordinate values must be greater than -32768 and less than 32767
assert m.llResult message cAssertMsg(textmerge([<<m.lnResult>> from: <<m.tnPixels>>px <<Iif(m.tlVertical, 'Vertical', 'Horizontal')>>, Font: <<Evl(m.tcFontName, .null.)>> <<Evl(m.tnFontSize, .null.)>>pt "<<Evl(m.tcFontStyle, 'N')>>"]))

return iif(m.llResult;
	, m.lnResult;
	, .null.;
	)
endfunc

* ==============================
function cExprEval && {fr} Expression pour évaluer une expression
lparameters tcExpr && {fr} Expression

local laOp[1], lcOp, lcOpU, lcExpr, lcResult
store '' to lcExpr, lcResult

* {fr} Pour chaque opérande de l'expression
if alines(laOp, m.tcExpr, 1, '+') > 0
	for each lcOp in laOp

		* {fr} Si l'opérande est un Chr()
		lcOpU = chrtran(upper(m.lcOp), space(1), '')
		if left(m.lcOpU, 4) == 'CHR(' or inlist(m.lcOpU, 'CR', 'CRLF')

			* {fr} Ajouter les opérandes accumulés au résultat
			lcResult = cWords('+', m.lcResult, cExprEval_cOp(m.lcExpr), m.lcOp)
			lcExpr = ''
		else
			lcExpr = c2Words(m.lcExpr, '+', m.lcOp)
		endif
	endfor
	lcResult = c2Words(m.lcResult, '+', cExprEval_cOp(m.lcExpr))
endif

return m.lcResult

* -----------------------------
function cExprEval_cOp && {fr} Adapte un opérande d'une expression
lparameters tcOp && {fr} Opérande

return iif(empty(m.tcOp), '', textmerge([cLitteral(Evaluate(<<cLitteral(m.tcOp)>>))]))

* ==============================
function uEval && {fr} Expression évaluée si possible
lparameters tcExpr

local luResult

try
	luResult = evaluate(m.tcExpr)
catch
	luResult = m.tcExpr
endtry

return m.luResult

* ==============================
function cIndented && {fr} Texte indenté
lparameters ;
  tcCode; && {fr} Texte à indenter
, tcIndent; && [tab] {fr} Caractère(s) d'indentation
, tlEmptyDel; && [.F.] {fr} Supprimer les lignes vides
, tcCharEOL && [''] {fr} Caractère de fin de ligne

tcCode = iif(vartype(m.tcCode) == 'C', m.tcCode, '')
tcIndent = iif(vartype(m.tcIndent) == 'C' and lenc(m.tcIndent) > 0, m.tcIndent, chr(9)) && {fr} Evl() ne marche pas sur space() et tab
tlEmptyDel = lTrue(m.tlEmptyDel)
tcCharEOL = evl(m.tcCharEOL, '')

return '';
	+ m.tcIndent;
	+ trim(;
	   icase(;
			CRLF $ m.tcCode,;
				strtran(strtran(iif(m.tlEmptyDel, cRepCharsDel(m.tcCode, CRLF), m.tcCode);
					, m.tcCharEOL + CRLF, m.tcCharEOL + CRLF + m.tcIndent);
					, CRLF + m.tcIndent + CRLF, CRLF2),;
			CR $ m.tcCode,;
				strtran(strtran(iif(m.tlEmptyDel, cRepCharDel(m.tcCode, CR), m.tcCode);
					, m.tcCharEOL + CR, m.tcCharEOL + CR + m.tcIndent);
					, CR + m.tcIndent + CR, CR2),;
				strtran(strtran(iif(m.tlEmptyDel, cRepCharDel(m.tcCode, LF), m.tcCode); && {fr} LF $ m.tcCode, memo par exemple
					, m.tcCharEOL + LF, m.tcCharEOL + LF + m.tcIndent);
					, LF + m.tcIndent + LF, LF2);
			);
		, cRepCharDel(m.tcIndent);
		)
endfunc

* ==============================
function cIndentedNo && {fr} Texte non indenté
lparameters tcCode

&& /!\ to do : adapter au multi-lignes

return ltrim(icase(;
		CRLF $ m.tcCode,;
			strtran(strtran(m.tcCode, CRLF + TABUL, CRLF), CRLF + space(1), CRLF),;
		CR $ m.tcCode,;
			strtran(strtran(m.tcCode, CR + TABUL, CR), CR + space(1), CR),;
			strtran(strtran(m.tcCode, LF + TABUL, LF), LF + space(1), LF); && {fr} memo par exemple
		), TABUL, space(1))

* ==============================
function cCommented && {fr} Instruction(s) commentée(s)
lparameters ;
  tcCode; && {fr} Instruction(s)
, tcCom; && [* ] {fr} caractère de commentaire
, tlEmptyDel && [.F.] {fr} Supprimer les lignes vides

tcCom = evl(m.tcCom, '* ')
tlEmptyDel = lTrue(m.tlEmptyDel)

return iif(empty(m.tcCode);
	, '';
	, strtran(strtran(strtran('';
			+ m.tcCom;
			+ trim(icase(;
					CRLF $ m.tcCode,;
						strtran(iif(m.tlEmptyDel, cRepCharsDel(m.tcCode, CRLF), m.tcCode), CRLF, CRLF + m.tcCom),;
					CR $ m.tcCode,;
						strtran(iif(m.tlEmptyDel, cRepCharDel(m.tcCode, CR), m.tcCode), CR, CR + m.tcCom),;
						strtran(iif(m.tlEmptyDel, cRepCharDel(m.tcCode, LF), m.tcCode), LF, LF + m.tcCom); && {fr} memo par exemple
					), m.tcCom); && ? Trim('totu', 'tu') && 'to'
		, m.tcCom + CRLF, CRLF); && {fr} les lignes vides ne sont pas commentées
		, m.tcCom + CR, CR); && {fr} les lignes vides ne sont pas commentées
		, m.tcCom + LF, LF); && {fr} les lignes vides ne sont pas commentées
	)

* ==============================
function lDevMode && {fr} Mode développement
return _vfp.startmode = 0;
 and not inlist(lower(justext(cModuleInfo(sys(16, 0), 'Address'))), 'app', 'exe')
endfunc

* ==============================
function lDevModeAB && {fr} Mode développement Abaque
return lDevMode() and File('az.prg')
endfunc

* ===================================================================
function cAssertMsg && {fr} MESSAGE pour ASSERT limité à 120 caractères sous les IDE non-US
lparameters tcMsg && @ {fr} message - si @, retour enrichi
tcMsg = ltrim(evl(nvl(m.tcMsg, ''), 'empty message?'))

local lcProgram

lcProgram = proper(program(program(-1)-1)) && {fr} back compat.

?? chr(7) && {fr} ding && ?? pour ne pas ajouter une ligne à la fenêtre qui a le focus

tcMsg = cTronc('';
    + iif(lower(left(m.tcMsg, len(m.lcProgram))) == lower(m.lcProgram);
			, '';
			, cResultHeader(-2);
			);
	  + m.tcMsg;
	, iif(version(3) == '00'; && 00 - English - 14/06/12 - crédit Francis Faure - http://www.atoutfox.org/nntp.asp?ID=0000009184
		, 254; && {fr} http://www.atoutfox.org/nntp.asp?ID=0000009201
		, 120;
		);
	, .t.; && {fr} split on a word end
	)

return m.tcMsg
endfunc

* =============================================
define class abVoid as custom
	procedure init
	return .f.
enddefine && {fr} CLASS abVoid

* =============================================
procedure lSetProcedure && {en} a Set("Procedure") is in current Set("Procedure")
lparameters tcSetProcedure && {fr} Set("Procedure") antérieur
return setProcedure(m.tcSetProcedure, .t.)

* =============================================
procedure setProcedure && {en} Restores previous Set("Procedure")
lparameters ;
  tcSetPro_; && {fr} Set("Procedure") antérieur
, tlCheck; && [.F.] {fr} Vérifier si Set("Procedure") antérieur est dans Set("Procedure") courant
, tlAdditive; && [.F.] {fr} Ajouter tcSetPro_ à Set("Procedure") courant

tlCheck = lTrue(m.tlCheck)
tlAdditive = lTrue(m.tlAdditive)

local llResult as Boolean;
, laSetProc[1];
, lnSetProc;
, laSetPro_[1];
, lnSetPro_;
, llProcedure;
, liProcedure;
, lcProcedure;

llResult = .t.
lnSetPro_ = alines(laSetPro_, upper(m.tcSetPro_), 5, ',')
lnSetProc = alines(laSetProc, set("Procedure"), 5, ',')

do case

case m.tlCheck
	for each lcProcedure in m.laSetPro_
		if empty(ascan(m.laSetProc, m.lcProcedure, 1, -1, 1, 6))
			llResult = .f.
			exit
		endif
	endfor

case empty(m.lnSetPro_) and !m.tlAdditive
	set procedure to

otherwise

	if m.lnSetPro_ > 0
		for liProcedure = 1 to lnSetPro_
			laSetPro_[m.liProcedure] = fullpath(alltrim(laSetPro_[m.liProcedure], '"'))
		endfor
	endif

	if m.lnSetProc > 0
		for liProcedure = 1 to m.lnSetProc
			laSetProc[m.liProcedure] = fullpath(alltrim(laSetProc[m.liProcedure], '"'))
		endfor
	endif

	if m.lnSetPro_ > 0
		for each lcProcedure in m.laSetPro_
			if file(m.lcProcedure) and empty(ascan(m.laSetProc, m.lcProcedure, 1, -1, 1, 6))
				set procedure to (m.lcProcedure) additive
			endif
		endfor
	endif

	if m.lnSetProc > 0 and !m.tlAdditive
		for each lcProcedure in laSetProc
			if empty(ascan(laSetPro_, m.lcProcedure, 1, -1, 1, 6))
				release procedure (m.lcProcedure)
			endif
		endfor
	endif

endcase

return m.llResult

* ========================================
procedure SetProcClassRestore as Boolean && {en} restores Set("Classlib") or Set("Procedure") to a previous value
lparameters ;
  tcSetAnte as string; && {en} previous Set("Classlib") or Set("Procedure")
, tlClassLib as Boolean; && [.F.] {en} tcSetAnte is Set("Classlib")

tlClassLib = lTrue(m.tlClassLib)

local success as Boolean;
, laFileAnte[1];
, laFilePost[1];
, lcThisFile as string;
, lcFile as string

success = .t.

if .t.;
 and alines(laFileAnte, m.tcSetAnte, 5, ',') > 0;
 and alines(laFilePost, set(iif(m.tlClassLib, "Classlib", "Procedure")), 5, ',') > 0;

	lcThisFile = cModuleInfo(sys(16), 'Address')

	* {fr} Remove unused files
	for each lcFile in m.laFilePost
		try
			do case
			case ascan(m.laFileAnte, m.lcFile, 1, -1, 1, 7) > 0
				&& {fr} in previous Set()
			case m.tlClassLib
				lcFile = iif(' IN ' $ m.lcFile;
					, '';
						+ ltrim(substrc(m.lcFile, at_c(' ALIAS ', m.lcFile)));
						+ substrc(m.lcFile;
							, at_c(' IN ', m.lcFile);
							, at_c(' ALIAS ', m.lcFile) - at_c(' IN ', m.lcFile);
							);
					, m.lcFile;
					)
				release classlib &lcFile
			case cOfLitteral(m.lcFile) == m.lcThisFile
				&& {fr} do not remove this file, we currently use it
			otherwise
				release procedure &lcFile
			endcase
		catch
		endtry
	endfor

	* {fr} Add previous files no longer in Set("Classlib") or Set("Procedure")
	for each lcFile in m.laFileAnte
		try
			do case
			case ascan(m.laFilePost, m.lcFile, 1, -1, 1, 7) > 0
				&& {fr} already in Set()
			case !file(alltrim(iif(m.tlClassLib;
				, trim(substrc(m.lcFile, 1, at_c('ALIAS', m.lcFile)-1));
				, m.lcFile;
				), '"', "'"))
				&& {fr} File can't be found
			case m.tlClassLib
				set classlib to &lcFile additive
			otherwise
				set procedure to &lcFile additive
			endcase
		catch
		endtry
	endfor

endif

return m.success

* =============================================
function cResultAdd && {fr} Ajoute une entrée à un résultat cumulatif
lparameters ;
  tcResult; && @ {fr} résultat cumulatif
, tuItem; && {fr} élément à ajouter au résultat - type 'N': attend Seconds() pour trace temps d'exécution {en} element to be added to result - type 'N': assumes Seconds() for execution time tracking
, tlLine; && [.F.] {fr} Sauter une ligne au lieu de 2
, tlPrepend; && [.F.] {fr} Ajouter au début
, tnStackMinus; && [0] {fr} nombre de niveaux de pile à retrancher - .T.: ne pas ajouter l'en-tête
, tlDateTime; && [.F.] {en} add date-time header
, tlFullStack; && [.F.] {en} add full call stack

tcResult = iif(vartype(m.tcResult) == 'C', m.tcResult, '')

tuItem = iif(vartype(m.tuItem) == 'N' and m.tuItem > 0;
	, icase(;
		cLangUser() = 'fr',	[terminé en],; && copy-paste this line to add another language support
												[completed in]; && default: English
		) + ' ' + cSeconds(@m.tuItem);
	, m.tuItem;
	)

if .t.;
 and ga_Type_IsChar(m.tuItem, .t.);
 and not m.tuItem $ m.tcResult

	tuItem = alltrim(m.tuItem, CR, LF)

	local lcHeader as string

	lcHeader = iif(empty(m.tnStackMinus) or vartype(m.tnStackMinus) == 'N';
		, cResultHeader(- 2 - abs(evl(m.tnStackMinus, 0)), m.tlDateTime);
		, '';
		)

	tuItem = iif(leftc(m.tuItem, lenc(m.lcHeader)) == m.lcHeader, '', m.lcHeader) + m.tuItem
	
	tlFullStack = Iif(lTrue(m.tlFullStack), cCallingModules(,, .T.), '')

	tcResult = ICase(;
		Lenc(m.tcResult) + Lenc(m.tuItem) + Lenc(m.tlFullStack) > VFP_VAR_SIZE_MAX,;
			Trim(m.tcResult, '.') + '...',;
		lTrue(m.tlPrepend),;
			cWords(iif(m.tlLine, CRLF, CRLF2), m.tuItem, m.tcResult, m.tlFullStack),;
			cWords(iif(m.tlLine, CRLF, CRLF2), m.tcResult, m.tuItem, m.tlFullStack);
		  )

endif
return .f. && {fr} impératif
endfunc

* ===================================================================
function cResultHeader && {fr} En-tête standard d'un résultat
lparameters ;
  tnStackOffset; && [-1]
, tlDateTime; && [.F.] {en} add date-time header

local lnStack, lcSys16

tnStackOffset = evl(m.tnStackOffset, -1)
assert m.tnStackOffset < 0
tnStackOffset = iif(m.tnStackOffset < 0, m.tnStackOffset, -1)

lnStack = program(-1) + m.tnStackOffset
assert m.lnStack > 0
lnStack = max(m.lnStack, 1)

lcSys16 = sys(16, m.lnStack)

return '';
		+ iif(lTrue(m.tlDateTime), transform(datetime()) + ' - ', '');
		+ lower(justfname(cModuleInfo(m.lcSys16, 'Address')));
		+ '!';
		+ proper(cModuleInfo(m.lcSys16, 'Name'));
		+ [() - ]
endfunc

* =============================================
function lUserAnAdmin as Variant && {en} Current user is a member of the Administrators group (does not mean user has elevated priviledges)
lparameters result as string && @

local success as Variant

try

	declare integer IsUserAnAdmin in Shell32

	#if .f.
		IsUserAnAdmin function && {fr} http://msdn.microsoft.com/en-us/library/bb776463.aspx
		Minimum supported client: windows XP [desktop apps only]
		Minimum supported server: windows server 2003 [desktop apps only]
		end of client support: windows Vista && {fr} because of UAC I guess - looks good on Windows 7!
		end of server support: windows server 2008
	#endif

	success = IsUserAnAdmin() # 0
catch
	success = .null. && {fr} IsUserAnAdmin() is not supported, we don't know
endtry

result = iif(isNull(m.success);
	, textmerge('';
		+ [<<Proper(Program())>>() ];
		+ icase(;
				cLangUser() = 'fr',	[n'a pu déterminer si le compte utilisateur courant '<<GetEnv("USERNAME")>>' est un administrateur car],; && copy-paste this line to add another language support
														[could not determine whether current user account '<<GetEnv("USERNAME")>>' is an administrator because]; && Default: English
				);
		+ ' ';
		+ iif(lUAC(); && {fr} Windows > Vista / Server 2008 - end of support of lUserAnAdmin()/IsUserAnAdmin() function according to http://msdn.microsoft.com/en-us/library/bb776463.aspx
			, icase(;
					cLangUser() = 'fr',	[Shell32!IsUserAnAdmin() n'est plus supporté sur <<wcWindowsEdition()>>],; && copy-paste this line to add another language support
															[Shell32!IsUserAnAdmin() is no longer supported on <<wcWindowsEdition()>>]; && Default: English
					);
			, icase(;
					cLangUser() = 'fr',	[<<wcWindowsEdition()>> est trop ancien pour supporter Shell32!IsUserAnAdmin()],; && copy-paste this line to add another language support
															[<<wcWindowsEdition()>> is too old to support Shell32!IsUserAnAdmin()]; && Default: English
					);
			);
		);
	, '';
	)

return m.success

* =============================================
function lUAC as Boolean && {en} Current Windows version supports UAC
return val(getwordnum(os(1), 2)) > 6.0
endfunc

* ========================================
procedure ProceduresAdd && {fr} Ajoute des fichiers prg au Set("Procedure")
lparameters tcPrgMask && [*.prg] {fr} Masque de fichier prg

local lcPrgMask, laPrgs[1], lnPrgs, lnPrg, lnResult && {fr} Nombre de fichiers prg ajoutés

lnResult = 0
lcPrgMask = iif(vartype(m.tcPrgMask)=='C' and not empty(m.tcPrgMask), m.tcPrgMask, '*.prg')
lnPrgs = adir(laPrgs, m.lcPrgMask)
if m.lnPrgs > 0
	for lnPrg = 1 to m.lnPrgs
		lnResult = m.lnResult + iif(ProcedureAdd(laPrgs[m.lnPrg, 1]), 1, 0)
	endfor
endif

return m.lnResult
endproc

* ========================================
procedure ProcedureRemove && {fr} ôte un fichier prg de Set("Procedure") s'il y est
lparameters tcPrg && {fr} fichier prg
return ProcedureAdd(m.tcPrg, .T.)
endproc

* ========================================
procedure ProcedureAdd && {fr} Ajoute un fichier prg à Set("Procedure") s'il n'y est déjà
lparameters ;
  tcPrg; && {fr} fichier prg
, tlRemove; && [.F.] {fr} Ôter de Set("Procedure")

local llResult; && {fr} le fichier a été ajouté ou ôté selon la demande
, llProc;

if vartype(m.tcPrg) == 'C' and file(m.tcPrg) and inlist(upper(justext(m.tcPrg)), 'PRG', 'FXP')

	tlRemove = lTrue(m.tlRemove)
	tcPrg = fullpath(forceext(m.tcPrg, 'FXP'))
	llProc = '"' + m.tcPrg + '"' $ set("Procedure")

	do case
	case !m.tlRemove and !m.llProc
		set procedure to (m.tcPrg) additive
		return .T.
	case m.tlRemove and m.llProc
		release procedure (m.tcPrg)
		return .T.
	endcase
endif
return .F.
endproc

* ========================================
procedure ClassLibRemove && {fr} Ôte un fichier vcx de Set("ClassLib") s'il y est
lparameters tcVCX && {fr} fichier vcx
return ClassLibAdd(m.tcVCX, .t.)
endproc

* ========================================
procedure ClassLibAdd && {fr} Ajoute un fichier vcx à Set("ClassLib") s'il n'y est déjà
lparameters ;
  tcVCX; && {fr} fichier(s) vcx
, tlRemove && [.F.] RELEASE CLASSLIB

local llResult; && {fr} le fichier a été ajouté ou retiré
, laVCX[1], lcVCX;
, llSet

if .t.;
 and vartype(m.tcVCX) == 'C';
 and alines(laVCX, m.tcVCX, 5, ',', ';') > 0
 
	tlRemove = lTrue(m.tlRemove)
 	for each lcVCX in m.laVCX

		llSet = ' ALIAS ' + Upper(JustStem(m.lcVCX)) + ',' $ set("Classlib") + ','
		do case
		case m.tlRemove and m.llSet
			release classlib (m.lcVCX)
			llResult = .t.
		case !m.tlRemove and !m.llSet and file(ForceExt(m.lcVCX, 'vcx'))
			set classlib to (m.lcVCX) additive
			llResult = .t.
		endcase
 	endfor
endif

return m.llResult
endproc

* ========================================
function Sys3 && {fr} Sys(3) unique même sur une machine rapide
local Sys3
Sys3 = sys(3)
do while m.Sys3 == sys(3)
enddo
return m.Sys3
endfunc

* ========================================
function Sys2015 && {fr} Sys(2015) unique même sur une machine rapide - alias de cSys2015Unique()
local Sys2015
Sys2015 = sys(2015)
do while m.Sys2015 == sys(2015)
enddo
return m.Sys2015
endfunc

* ========================================
function cSys2015Unique && {fr} Sys(2015) unique même sur une machine rapide - alias de Sys2015()
return Sys2015()
endfunc

* ========================================
procedure varStore(out, in) as Boolean && {fr} assigne une variable - alias de varSet()
store m.in to out
endproc

* =============================================
procedure varSet(out, in) as Boolean && {fr} assigne une variable - alias de varStore()
store m.in to out && {fr} http://blogs.msdn.com/b/calvin_hsia/archive/2004/12/14/301282.aspx - Calvin: the STORE command doesn't do as much as the "x=y" command. More in a future blog.
endproc

* =============================================
procedure varSetC(out, in) as String && {fr} assigne une variable et retourne une chaine vide
store m.in to out
return ''
endproc

* =============================================
procedure varSetF(out, in) as Boolean && {fr} assigne une variable et retourne .F.
store m.in to out
return .F.
endproc

* =============================================
function iInc(int, inc) as integer && {fr} incrémente une variable
int = m.int + evl(m.inc, 1)
return m.int
endproc

* =============================================
procedure setStepOn(condition as Boolean) as Boolean && {en} execute SET STEP ON within a Boolean expression
if (cast(Nvl(m.condition, .F.) as L) or empty(pcount())) && and lDevMode() useless
	set step on
endif
endproc

* =============================================
function abCoverage && {fr} Lance un historique d'exécution && {fr} Alias de oCoverage()
lparameters ;
  condition as Boolean; && [.T.] {fr} condition pour lancer le coverage
, lAdditive as Boolean; && [.F.] {en} Add to the same file
, lProduction as Boolean; && [.F.] {fr} Forcer le Coverage en mode production

return iif(empty(pcount());
	, oCoverage();
	, oCoverage(m.condition, m.lAdditive, m.lProduction);
	)

endfunc

* =============================================
function oCoverage && {fr} Lance un historique d'exécution
lparameters ;
  condition as Boolean; && [.T.] {fr} condition pour lancer le coverage
, lAdditive as Boolean; && [.F.] {en} Add to the same file
, lProduction as Boolean; && [.F.] {fr} Forcer le Coverage en mode production

* {fr} loCoverage = oCoverage([condition]) && {en} Starts log {fr} Commence l'historique
* 	--<{en} code you want to trace {fr} Code que vous voulez tracer >--

* {fr} loCoverage = .null. && {en} Stops log {fr} Arrête l'historique

if .t.;
 and (empty(pcount()) or lTrue(m.condition));
 and (lDevMode() or lTrue(m.lProduction))

	lAdditive = lTrue(m.lAdditive)

	local lcFile as string

	lcFile = '';
		+ lower(cModuleInfo(sys(16,1), 'Address')); && {fr} main program
		+ '_' + lower(cModuleInfo(sys(16, program(-1)-1), 'Name'));
		+ iif(m.lAdditive;
			, '';
			, '_' + TtocSep(, '-');
			);
		+ '.cov.log'

	if m.lAdditive
		strtofile(CRLF + ttoc(datetime()) + ' ' + replicate('-', 50), m.lcFile, .t.)
	endif

	return abSet('COVERAGE';
			, '"' + m.lcFile + '"';
				+ iif(m.lAdditive, ' ADDITIVE', '');
			,,,.t.)

endif
endfunc

* =============================================
function RC4(cTexte, cClef) && {en} RC4 encryption

*!*    Objet : Implémention en VisualFoxPro de l'algorithme de cryptage RC4
*!*    Auteur : C.Chenavier
*!*    Version : 1.00 - 12/03/2006
*!*    RC4 signifie Rivest Cipher 4
*!*    Il a été conçu en 1987 par Ron Rivest de RSA Security.
*!*    Attention, le nom "RC4" est une marque déposée.
*!*    Algorithme : http://en.wikipedia.org/wiki/RC4
*!*    Les tests ont été réalisés grâce à l'article:
*!*    http://en.wikisource.org/wiki/RC4_test_vectors
*!*
*!*    Exemples de test :
*!*    c = "0000000000000000"
*!*    a = RC4(STRCONV(c,16),STRCONV(c,16))
*!*    Info(STRCONV(a,15)="DE188941A3375D3A")
*!*
*!*    c = "0123456789abcdef"
*!*    a = RC4(STRCONV(c,16),STRCONV(c,16))
*!*    Info(STRCONV(a,15)="75B7878099E0C596")
*!*
*!*    c = "0000000000000000"
*!*    k = "0123456789abcdef"
*!*    a = RC4(STRCONV(c,16),STRCONV(k,16))
*!*    Info(STRCONV(a,15)="7494C2E7104B0879")
*!*
*!*    c = "00000000000000000000"
*!*    k = "ef012345"
*!*    a = RC4(STRCONV(c,16),STRCONV(k,16))
*!*    Info(STRCONV(a,15)="D6A141A7EC3C38DFBD61")
*!*
*!*    c = "123456789abcdef0123456789abcdef0123456789abcdef012345678"
*!*    k = "0123456789abcdef"
*!*    a = RC4(STRCONV(c,16),STRCONV(k,16))
*!*    Info(STRCONV(a,15)="66A0949F8AF7D6891F7F832BA833C00C892EBE30143CE28740011ECF")

local i, J, K, nLongClef, nInt, cResult
local array aInt(256)

for i = 1 to 256
    aInt(i) = i-1
endfor

J = 0
m.nLongClef = len(m.cClef)
for i = 1 to 256
    J = bitand(J + aInt(i) + asc(substr(m.cClef, mod(i-1,m.nLongClef)+1, 1)), 255)
    m.nInt = aInt(i)
    aInt(i) = aInt(J+1)
    aInt(J+1) = m.nInt
endfor

i = 1
J = 0
m.cResult = ''
for K = 1 to len(m.cTexte)
    i = bitand(i, 255) + 1
    J = bitand(J + aInt(i), 255)
    m.nInt = aInt(i)
    aInt(i) = aInt(J+1)
    aInt(J+1) = m.nInt
    m.cResult = m.cResult + chr(bitxor(asc(substr(m.cTexte, K, 1)), ;
                                       aInt(bitand(aInt(i) + m.nInt, 255)+1)))
endfor

return m.cResult
endfunc

* =============================================
function cObjectCamelCase && {fr} Nom ou adresse d'objet où les abréviations des classes sont en casse mixte
lparameters cObject
return strtran(strtran(strtran(strtran(strtran(strtran(strtran(strtran(strtran(strtran(strtran(strtran(strtran(strtran(strtran(strtran(strtran(strtran(strtran(strtran(strtran(strtran(strtran(strtran(strtran(strtran(strtran(strtran(strtran(strtran(strtran(strtran(strtran(strtran(strtran(strtran(strtran(strtran(strtran(m.cObject;
, 'cad', 'Cad', 1, -1, 1);
, 'cbo', 'Cbo', 1, -1, 1);
, 'chk', 'Chk', 1, -1, 1);
, 'cmd', 'Cmd', 1, -1, 1);
, 'cmg', 'Cmg', 1, -1, 1);
, 'cnt', 'Cnt', 1, -1, 1);
, 'col', 'Col', 1, -1, 1);
, 'ctl', 'Ctl', 1, -1, 1);
, 'cur', 'Cur', 1, -1, 1);
, 'dte', 'Dte', 1, -1, 1);
, 'edt', 'Edt', 1, -1, 1);
, 'frm', 'Frm', 1, -1, 1);
, 'frs', 'Frs', 1, -1, 1);
, 'grc', 'Grc', 1, -1, 1);
, 'grd', 'Grd', 1, -1, 1);
, 'grh', 'Grh', 1, -1, 1);
, 'hpl', 'Hpl', 1, -1, 1);
, 'img', 'Img', 1, -1, 1);
, 'lbl', 'Lbl', 1, -1, 1);
, 'lin', 'Lin', 1, -1, 1);
, 'lst', 'Lst', 1, -1, 1);
, 'olb', 'Olb', 1, -1, 1);
, 'ole', 'Ole', 1, -1, 1);
, 'opg', 'Opg', 1, -1, 1);
, 'opt', 'Opt', 1, -1, 1);
, 'pag', 'Pag', 1, -1, 1);
, 'pgf', 'Pgf', 1, -1, 1);
, 'prj', 'Prj', 1, -1, 1);
, 'rel', 'Rel', 1, -1, 1);
, 'rpt', 'Rpt', 1, -1, 1);
, 'sep', 'Sep', 1, -1, 1);
, 'shp', 'Shp', 1, -1, 1);
, 'spn', 'Spn', 1, -1, 1);
, 'tbr', 'Tbr', 1, -1, 1);
, 'tmr', 'Tmr', 1, -1, 1);
, 'txt', 'Txt', 1, -1, 1);
, 'xad', 'Xad', 1, -1, 1);
, 'xfd', 'Xfd', 1, -1, 1);
, 'xtb', 'Xtb', 1, -1, 1);

endfunc

* =============================================
function nEvl(uValue, notEmpty, typeForce) && {en} substitute value instead of not empty value
return icase(;
	!empty(m.uValue),;
		m.notEmpty,;
	lTrue(m.typeForce),;
		uEmpty(vartype(m.notEmpty)),;
		m.uValue;
	)
endfunc

* =============================================
function nNvl && {en} substitute value instead of a not null value
lparameters value, substitute
return iif(isNull(m.value), m.value, m.substitute)
endfunc

* =============================================
function isNullOrEmpty && {en} null or empty value
lparameters value
return !vartype(m.value) == 'O' and empty(nvl(m.value, .f.))
endfunc
* --------------------------------------------
function isEmptyOrNull && {en} empty or null value
lparameters value
return isNullOrEmpty(m.value)
endfunc

* =============================================
function ENvl && {en} substitute for an empty or null value
lparameters value, substitute
return iif(isNullOrEmpty(m.value), m.substitute, m.value)
endfunc

* =============================================
function nENvl && {en} substitute value instead of not empty and not null value
lparameters value, substitute
return iif(isNullOrEmpty(m.value), m.value, m.substitute)
endfunc

* =============================================
function EvlNull && {en} turns empty value into .null.
lparameters value
return iif(!vartype(m.value) == 'O' and empty(m.value), .null., m.value)
endfunc

* =============================================
function lTrue && {en} a value is .T.
lparameters value 
return Vartype(m.value) == 'L' and m.value
endfunc

#if .F. && regexp to replace in code
/\(?vartype\s*\(\s*((?:m\.)?\w+)\s*\)\s*=(?:=)?\s*['"]L['"]\s+\.?and\.?\s+\1\)?/gim > lTrue($1)
iiflTrue > iif(lTrue
#endif

* =============================================
function lFalse && {en} a value is .F.
lparameters value
return vartype(m.value) == 'L' and !m.value
endfunc

#if .f. && https://raw.githubusercontent.com/npm/node-semver/master/semver.js
#endif

* =============================
function cSemVer as String && {en} SemVer of a version string
lparameters ;
  result as string; && @ {fr} résultat (cumulatif)
, version as string; && {fr} version à analyser
, loose as Boolean; && [.F.]

local oSemVer as abSemVer of abDev.prg

oSemVer = abSemVer(;
	 @m.result;
	, m.version;
	, m.loose;
	)

return Iif(labSemVer(m.oSemVer);
	, m.oSemVer.version;
	, .null.;
	)
endfunc

* =============================
function cSemVerMMP as String && {en} SemVer major.minor.patch (without prereleases)
lparameters ;
  result as string; && @ {fr} résultat (cumulatif)
, version as string; && {fr} version à analyser
, loose as Boolean; && [.F.]

local oSemVer as abSemVer of abDev.prg

oSemVer = abSemVer(;
	 @m.result;
	, m.version;
	, m.loose;
	)

return Iif(labSemVer(m.oSemVer);
	, m.oSemVer.versionMMP;
	, .null.;
	)
endfunc

* =============================
function abSemVer as abSemVer of abDev.prg && {en} abSemVer object from a version string
lparameters ;
  result as string; && @ {fr} résultat (cumulatif)
, version as string; && {fr} version à analyser
, loose as Boolean; && [.F.]

if vartype(m.version) # 'C' && 2 parameters
	loose = m.version
	version = m.result
endif

return CreateObject('abSemVer', @m.result, m.version, m.loose) && Evl(, .null.) && 2017-04-24 thn -- {FiC V 2.25.0-beta.4} {en} all similar functions should do the same
endfunc

* -----------------
function labSemVer && {fr} c'est un objet de la classe abSemVer
lparameters oSemVer as Variant
return loClass(m.oSemVer, 'abSemVer')
endfunc

* -----------------
function iSemVerMMP && {fr} ordre de classement de versions SemVer sur majeur-mineur-patch (ignorant les pre-releases)
lparameters ;
  result as string; && @ {fr} résultat (cumulatif)
, version as string; && {fr} version à analyser
, loose as Boolean; && [.F.]

local oSemVer as abSemVer

oSemVer = abSemVer(@m.result, m.version, m.loose)

return Iif(labSemVer(m.oSemVer);
	, m.oSemVer.versionMMPint;
	, .null.;
	)
endfunc

* =============================
define class abSemVer as GA_LIGHTWEIGHT_CLASS of abGA.prg && {en} Implements Semantic Versioning 2.0.0 http://semver.org/ - inspired by https://github.com/npm/node-semver/
* =============================

MAX_LENGTH = 256
MAX_SAFE_INTEGER = 2^31 - 1 && {fr} VFP limitation

oPattern = .null. && {fr} CreateObject('Empty') && {en} statement is not valid is a class definition
oRegExpr = .null.

tildeTrimReplace = '$1~'
caretTrimReplace = '$1^'
comparatorTrimReplace = '$1$2$3'

loose = .null.
raw = .null.
version = .null.

&& {en} these are numbers
major = .null.
minor = .null.
patch = .null.

dimension prerelease[1], build[1]
prerelease = .null. && {en} array of prerelease(s) identifier(s) and number(s), keep as lower case
build = .null. && {en} array of build numbers

&& {en} FoxInCloud extensions
&& {en} these are actually logical
lMajor = .null. && {en} major release
lMinor = .null. && {en} minor release
lPatch = .null. && {en} patch release
lPreRelease = .null. && {en} pre-release (beta)
versionMMP = .null. && {en} version Major.Minor.Path (without prerelease(s))
versionMMPint = .null. && {en} version Major.Minor.Path in integer
versionIS = .null. && {en} version for InstallShield

* -----------------
procedure Init
lparameters ;
  result as string; && @ {fr} résultat (cumulatif)
, version as string; && {fr} version à analyser
, loose as Boolean; && [.F.]

local success as Boolean;
, cResult as string;

success = this.Init_(@m.cResult, m.version, m.loose)

* assert m.success message cAssertMsg(m.cResult)
= m.success or cResultAdd(@m.result, m.cResult)

return m.success
endproc

* -----------------
hidden procedure Init_
lparameters ;
  result as string; && @ {fr} résultat (cumulatif)
, version as string; && [this.raw] {fr} version à analyser
, loose as Boolean; && [.F.]

local success as Boolean;
, oRegExp as abRegExp of abTxt.prg;
, oSubMatch as collection;
, cPreReleases as string;
, nPreRelease as integer;
, iPreRelease as integer;
, cPreRelease as string;
, oRegExpNum as abRegExp of abTxt.prg;

do case
case !this.Init_RegExp(@m.result)
	return m.success
case this.lSemVer(m.version)
 loose   = m.version.loose
 version = m.version.version
case !ga_Type_IsChar(m.version, .t.)
	return cResultAdd(@m.result, [Invalid version: ] + cL(m.version))
endcase

store lTrue(m.loose) to loose, this.loose
store alltrim(Iif(m.loose, cEuroANSI(m.version), m.version)) to this.raw, version

if lenc(m.version) > this.MAX_LENGTH
  return cResultAdd(@m.result, textmerge([version <<cL(m.version)>> is longer than <<this.MAX_LENGTH>> characters]))
endif

oRegExp = iif(m.loose, this.oRegExpr.loose, this.oRegExpr.full)

if empty(m.oRegExp.execute(m.version))
  return cResultAdd(@m.result, textmerge([Invalid version: <<m.version>>]))
endif

oSubMatch = m.oRegExp.matches[3]

&& {en} these are actually numbers
this.major = cast(m.oSubMatch.item(1) as i) && .Item() évite les erreur de project manager
this.minor = cast(m.oSubMatch.item(2) as i)
this.patch = cast(m.oSubMatch.item(3) as i)

do case
case !between(m.this.major, 0, this.MAX_SAFE_INTEGER)
  return cResultAdd(@m.result, textmerge([Invalid major version: <<m.this.major>>]))
case !between(m.this.minor, 0, this.MAX_SAFE_INTEGER)
  return cResultAdd(@m.result, textmerge([Invalid minor version: <<m.this.minor>>]))
case !between(m.this.patch, 0, this.MAX_SAFE_INTEGER)
  return cResultAdd(@m.result, textmerge([Invalid patch version: <<m.this.patch>>]))
endcase

this.lMajor = empty(m.this.minor) && {en} major release
this.lMinor = !this.lMajor and empty(m.this.patch) && {en} minor release
this.lPatch = m.this.patch > 0 && {en} patch release

&& {en} pre-release; http://semver.org/
&& {en} A pre-release version MAY be denoted by appending a hyphen and a series of dot separated identifiers immediately following the patch version;
&& {en} pre-release identifiers:
&& {en} - MUST comprise only ASCII alphanumerics and hyphen [0-9A-Za-z-].
&& {en} - MUST NOT be empty.
&& {en} Numeric identifiers MUST NOT include leading zeroes.
&& {en} Pre-release versions have a lower precedence than the associated normal version.
&& {en} A pre-release version indicates that the version is unstable and might not satisfy the intended compatibility requirements as denoted by its associated normal version.
&& {en} Examples: 1.0.0-alpha, 1.0.0-alpha.1, 1.0.0-0.3.7, 1.0.0-x.7.z.92.
cPreReleases = m.oSubMatch.item(4)
this.lPreRelease = !empty(m.cPreReleases)
if m.this.lPreRelease
	oRegExpNum = abRegExp('^[0-9]+$')
	nPreRelease = getwordcount(m.cPreReleases, '.')
	if m.loose and m.nPreRelease = 1 and IsDigit(Rightc(m.cPreReleases, 1)) && 2015-09-25 thn back compat.: allow for missing dot between prerelease type and number
		iPreRelease = Lenc(m.cPreReleases)
		do while m.iPreRelease >= 0
			if !IsDigit(Substr(m.cPreReleases, m.iPreRelease))
				cPreReleases = '';
					+ Evl(Leftc(m.cPreReleases, m.iPreRelease), 'beta'); && 2015-09-25 thn InstallShield support: prerelease must be a number
					+ '.';
					+ Cast(Cast(Substr(m.cPreReleases, m.iPreRelease + 1) as I) as  m) && {en} removes leading 0 if any
				nPreRelease = 2
				exit
			endif
			m.iPreRelease = m.iPreRelease - 1
		enddo
	endif
	dimension this.prerelease[m.nPreRelease]
	for iPreRelease = 1 to m.nPreRelease
		cPreRelease = getwordnum(m.cPreReleases, m.iPreRelease, '.')
		this.prerelease[m.iPreRelease] = iif(m.oRegExpNum.Test(m.cPreRelease);
			, cast(m.cPreRelease as I);
			, lower(cEuroANSI(m.cPreRelease)); && _cliptext = cl(lower(cEuroANSI('Bêta'))) >> "beta"
			)
	endfor
endif

this.format
endproc

* -----------------
procedure format && {en} format version as String

this.versionMMPint = Int(0;
	+ m.this.major * 10^6;
	+ m.this.minor * 10^3;
	+ m.this.patch;
	)

store '';
	      + cast(m.this.major as m);
	+ '.' + cast(m.this.minor as m);
	+ '.' + cast(m.this.patch as m);
 to this.versionMMP, this.versionIS, this.version

this.lPreRelease = !isNull(m.this.prerelease)
if m.this.lPreRelease

	local aPreRelease[1]
	acopy(this.prerelease, aPreRelease)
	this.version = this.version + '-' + cListOfArray(@m.aPreRelease, '.',,,.t.)
	this.versionIS = this.versionIS + Iif(m.this.lBeta(), '.' + Cast(m.this.nBeta() as m), '')
endif

return this.version
endproc

* -----------------
hidden procedure Init_RegExp && {en} Initializes Regular Expressions are used for tokenizing, validating and parsing abSemVer version strings
lparameters result as string; && @ {fr} résultat (cumulatif)

this.oPattern = createobject('Empty')
this.oRegExpr = createobject('Empty')

&& ## Numeric Identifier
&& {en} A single `0`, or a non-zero digit followed by zero or more digits.

addproperty(this.oPattern, 'NUMERICIDENTIFIER', '0|[1-9]\d*')
addproperty(this.oPattern, 'NUMERICIDENTIFIERLOOSE', '[0-9]+')

&& ## Non-numeric Identifier
&& {en} Zero or more digits, followed by a letter or hyphen, and then zero or
&& {en} more letters, digits, or hyphens.

addproperty(this.oPattern, 'NONNUMERICIDENTIFIER', '\d*[a-zA-Z-][a-zA-Z0-9-]*')

&& ## Main Version
&& {en} Three dot-separated numeric identifiers.

addproperty(this.oPattern, 'MAINVERSION', '';
	+ '(' + this.oPattern.NUMERICIDENTIFIER + ')\.';
	+ '(' + this.oPattern.NUMERICIDENTIFIER + ')\.';
	+ '(' + this.oPattern.NUMERICIDENTIFIER + ')';
	)

addproperty(this.oPattern, 'MAINVERSIONLOOSE', '';
	+ '(' + this.oPattern.NUMERICIDENTIFIERLOOSE + ')\.';
	+ '(' + this.oPattern.NUMERICIDENTIFIERLOOSE + ')(?:\.'; && {en} thn 2015-09-25 {en} back compat.: allow for patch figure missing (eg. '2.20beta')
	+ '(' + this.oPattern.NUMERICIDENTIFIERLOOSE + '))?';
	)

&& ## Pre-release Version Identifier
&& {en} A numeric identifier, or a non-numeric identifier.

addproperty(this.oPattern, 'PRERELEASEIDENTIFIER', '(?:' + this.oPattern.NUMERICIDENTIFIER + '|' + this.oPattern.NONNUMERICIDENTIFIER + ')')
addproperty(this.oPattern, 'PRERELEASEIDENTIFIERLOOSE', '(?:' + this.oPattern.NUMERICIDENTIFIERLOOSE + '|' + this.oPattern.NONNUMERICIDENTIFIER + ')')

&& ## Pre-release Version
&& {en} Hyphen, followed by one or more dot-separated pre-release version identifiers.

addproperty(this.oPattern, 'PRERELEASE', '(?:-(' + this.oPattern.PRERELEASEIDENTIFIER + '(?:\.' + this.oPattern.PRERELEASEIDENTIFIER + ')*))')
addproperty(this.oPattern, 'PRERELEASELOOSE', '(?:[-\. ]?(' + this.oPattern.PRERELEASEIDENTIFIERLOOSE + '(?:\.' + this.oPattern.PRERELEASEIDENTIFIERLOOSE + ')*))') && 2015-09-25 thn InstallShield support: prerelease is a number separated by '.' from main version

&& ## Build Metadata Identifier
&& {en} Any combination of digits, letters, or hyphens.

addproperty(this.oPattern, 'BUILDIDENTIFIER', '[0-9A-Za-z-]+')

&& ## Build Metadata
&& {en} Plus sign, followed by one or more period-separated build metadata identifiers.

addproperty(this.oPattern, 'BUILD', '(?:\+(' + this.oPattern.BUILDIDENTIFIER + '(?:\.' + this.oPattern.BUILDIDENTIFIER + ')*))')

&& ## Full Version String
&& {en} A main version, followed optionally by a pre-release version and build metadata.

&& {en} Note that the only major, minor, patch, and pre-release sections of
&& {en} the version string are capturing groups.  The build metadata is not a
&& {en} capturing group, because it should not ever be used in version
&& {en} comparison.

FULLPLAIN = 'v?' + this.oPattern.MAINVERSION + this.oPattern.PRERELEASE + '?' + this.oPattern.build + '?'

addproperty(this.oPattern, 'FULL', '^' + FULLPLAIN + '$')

&& {en} like full, but allows v1.2.3 and =1.2.3, which people do sometimes.
&& {en} also, 1.0.0alpha1 (prerelease without the hyphen) which is pretty common in the npm registry.
LOOSEPLAIN = '[v=\s]*';
	+ this.oPattern.MAINVERSIONLOOSE;
	+ this.oPattern.PRERELEASELOOSE + '?';
	+ this.oPattern.BUILD + '?'

addproperty(this.oPattern, 'LOOSE', '^' + LOOSEPLAIN + '$')

addproperty(this.oPattern, 'GTLT', '((?:<|>)?=?)')

&& {en} Something like "2.*" or "1.2.x".
&& {en} Note that "x.x" is a valid xRange identifer, meaning "any version"
&& {en} Only the first item is strictly required.
addproperty(this.oPattern, 'XRANGEIDENTIFIERLOOSE', this.oPattern.NUMERICIDENTIFIERLOOSE + '|x|X|\*')
addproperty(this.oPattern, 'XRANGEIDENTIFIER', this.oPattern.NUMERICIDENTIFIER + '|x|X|\*')

addproperty(this.oPattern, 'XRANGEPLAIN', '';
	+ '[v=\s]*(' + this.oPattern.XRANGEIDENTIFIER + ')';
	+ '(?:\.(' + this.oPattern.XRANGEIDENTIFIER + ')';
	+ '(?:\.(' + this.oPattern.XRANGEIDENTIFIER + ')';
	+ '(?:' + this.oPattern.PRERELEASE + ')?';
	+ this.oPattern.build + '?';
	+ ')?)?';
	)

addproperty(this.oPattern, 'XRANGEPLAINLOOSE', '';
	+ '[v=\s]*(' + this.oPattern.XRANGEIDENTIFIERLOOSE + ')';
	+ '(?:\.(' + this.oPattern.XRANGEIDENTIFIERLOOSE + ')';
	+ '(?:\.(' + this.oPattern.XRANGEIDENTIFIERLOOSE + ')';
	+ '(?:' + this.oPattern.PRERELEASELOOSE + ')?';
	+ this.oPattern.build + '?';
	+ ')?)?';
	)

addproperty(this.oPattern, 'XRANGE', '^' + this.oPattern.GTLT + '\s*' + this.oPattern.XRANGEPLAIN + '$')
addproperty(this.oPattern, 'XRANGELOOSE', '^' + this.oPattern.GTLT + '\s*' + this.oPattern.XRANGEPLAINLOOSE + '$')

&& {en} Tilde ranges.
&& {en} Meaning is "reasonably at or greater than"
addproperty(this.oPattern, 'LONETILDE', '(?:~>?)')

addproperty(this.oPattern, 'TILDETRIM', '(\s*)' + this.oPattern.LONETILDE + '\s+')
addproperty(this.oRegExpr, 'TILDETRIM', abRegExp(this.oPattern.TILDETRIM, 'g'))

addproperty(this.oPattern, 'TILDE', '^' + this.oPattern.LONETILDE + this.oPattern.XRANGEPLAIN + '$')
addproperty(this.oPattern, 'TILDELOOSE', '^' + this.oPattern.LONETILDE + this.oPattern.XRANGEPLAINLOOSE + '$')

&& {en} Caret ranges.
&& {en} Meaning is "at least and backwards compatible with"
addproperty(this.oPattern, 'LONECARET', '(?:\^)')

addproperty(this.oPattern, 'CARETTRIM', '(\s*)' + this.oPattern.LONECARET + '\s+')
addproperty(this.oRegExpr, 'CARETTRIM', abRegExp(this.oPattern.CARETTRIM, 'g'))

addproperty(this.oPattern, 'CARET', '^' + this.oPattern.LONECARET + this.oPattern.XRANGEPLAIN + '$')
addproperty(this.oPattern, 'CARETLOOSE', '^' + this.oPattern.LONECARET + this.oPattern.XRANGEPLAINLOOSE + '$')

&& {en} A simple gt/lt/eq thing, or just "" to indicate "any version"
addproperty(this.oPattern, 'COMPARATORLOOSE', '^' + this.oPattern.GTLT + '\s*(' + LOOSEPLAIN + ')$|^$')
addproperty(this.oPattern, 'COMPARATOR', '^' + this.oPattern.GTLT + '\s*(' + FULLPLAIN + ')$|^$')


&& {en} An expression to strip any whitespace between the gtlt and the thing
&& {en} it modifies, so that `> 1.2.3` ==> `>1.2.3`
addproperty(this.oPattern, 'COMPARATORTRIM', '(\s*)' + this.oPattern.GTLT + '\s*(' + LOOSEPLAIN + '|' + this.oPattern.XRANGEPLAIN + ')')

&& {en} this one has to use the /g flag
addproperty(this.oRegExpr, 'COMPARATORTRIM', abRegExp(this.oPattern.COMPARATORTRIM, 'g'))

&& {en} Something like `1.2.3 - 1.2.4`
&& {en} Note that these all use the loose form, because they'll be
&& {en} checked against either the strict or loose comparator form
&& {en} later.
addproperty(this.oPattern, 'HYPHENRANGE', '^\s*(' + this.oPattern.XRANGEPLAIN + ')' + '\s+-\s+' + '(' + this.oPattern.XRANGEPLAIN + ')' + '\s*$')

addproperty(this.oPattern, 'HYPHENRANGELOOSE', '^\s*(' + this.oPattern.XRANGEPLAINLOOSE + ')' + '\s+-\s+' + '(' + this.oPattern.XRANGEPLAINLOOSE + ')' + '\s*$')

&& {en} Star ranges basically just allow anything at all.
addproperty(this.oPattern, 'STAR', '(<|>)?=?\s*\*')

local aPattern[1], cPattern
if amember(aPattern, this.oPattern) > 0
	for each cPattern in m.aPattern
		if !lProperty(this.oRegExpr, m.cPattern)
			addproperty(m.this.oRegExpr, m.cPattern, abRegExp(evaluate('this.oPattern.' + m.cPattern)))
		endif
	endfor
endif

endproc

* -----------------
protected function lSemVer && {fr} c'est un objet de la classe abSemVer
lparameters other as Variant && {fr} autre version
return labSemVer(m.other)
endfunc

* -----------------
protected function oSemVer && {fr} objet de la classe abSemVer
lparameters other as Variant && {fr} autre version
return iif(this.lSemVer(m.other);
	, m.other;
	, abSemVer(m.other, m.this.loose);
	)
endfunc

* -----------------
function compare && {fr} compare cette version avec une autre
lparameters other as Variant && {fr} autre version
return evl(this.compareMain(@m.other), this.comparePre(@m.other))
endfunc

* -----------------
function compareMinor && {fr} compare cette version avec une autre jusqu'à la version mineure en ignorant les patches et les pre-release
lparameters other as Variant && {fr} autre version
other = this.oSemVer(m.other)
return iif(this.lSemVer(m.other);
	, evl(;
		  this.compareIdentifiers(this.major, m.other.major);
		, this.compareIdentifiers(this.minor, m.other.minor));
	, .null.;
	)
endfunc

* -----------------
function compareMain && {fr} compare les versions principales
lparameters other as Variant && {fr} autre version

other = this.oSemVer(m.other)
return iif(this.lSemVer(m.other);
	, evl(evl(;
		  this.compareIdentifiers(this.major, m.other.major);
		, this.compareIdentifiers(this.minor, m.other.minor));
		, this.compareIdentifiers(this.patch, m.other.patch));
	, .null.;
	)
endfunc

* -----------------
protected function comparePre && {fr} compare les versions de pre-release (beta etc.)
lparameters other as Variant && {fr} autre version

local comparePre as integer;
, iPreRelease as integer;
, nPreRelThis as integer;
, nPreRelOther as integer;
, uPreRelThis as Variant;
, uPreRelOther as Variant;

comparePre = .null.

other = this.oSemVer(m.other)
if this.lSemVer(m.other)

  * {en} NOT having a prerelease is > having one
  do case
  case !m.this.lPreRelease and !m.other.lPreRelease
    return 0
  case !m.this.lPreRelease and m.other.lPreRelease
    return 1
  case m.this.lPreRelease and !m.other.lPreRelease
    return -1
  endcase

	nPreRelThis  = alen(m.this.prerelease)
	nPreRelOther = alen(m.other.prerelease)

	for iPreRelease = 1 to max(m.nPreRelThis, m.nPreRelOther)
		do case
		case m.iPreRelease > m.nPreRelOther
			return +1
		case m.iPreRelease > m.nPreRelThis
			return -1
		case .t.;
		 and varSet(@m.uPreRelThis, m.this.prerelease[m.iPreRelease]);
		 and varSet(@m.uPreRelOther, m.other.prerelease[m.iPreRelease]);
		 and vartype(m.uPreRelThis) == vartype(m.uPreRelOther);
		 and m.uPreRelThis == m.uPreRelOther;
		 and .t.
			loop
		otherwise
			return this.compareIdentifiers(m.uPreRelThis, m.uPreRelOther)
		endcase
	endfor
	return 0
else
	return .null.
endif

endfunc

* -----------------
protected function compareIdentifiers(a, b) && {fr} compare les versions principales
return icase(;
	vartype(m.a) == 'N' and vartype(m.b) <> 'N',;
		+1,;
	vartype(m.a) <> 'N' and vartype(m.b) == 'N',;
		-1,;
	m.a > m.b,;
		+1,;
	m.a < m.b,;
		-1,;
    0;
   )
endfunc

* -----------------
hidden function iBeta
return ascan(m.this.prerelease, 'beta')
endfunc

* -----------------
function lBeta(iBeta) && {en} beta prerelease
iBeta = this.iBeta()
return m.iBeta > 0
endfunc

* -----------------
function nBeta && {fr} si beta prerelease, n° de beta
local iBeta
return iif(this.lBeta(@m.iBeta) and alen(this.prerelease) > m.iBeta and vartype(this.prerelease[m.iBeta + 1]) == 'N';
	, this.prerelease[m.iBeta + 1];
	, .null.;
	)
endfunc

* -----------------
function GT(other as Variant) && {fr} cette version est supérieure à une autre
return this.compare(m.other) > 0
endfunc

* -----------------
function GTE(other as Variant) && {fr} cette version est supérieure ou égale à une autre
return this.compare(m.other) >= 0
endfunc

* -----------------
function LT(other as Variant) && {fr} cette version est inférieure à une autre
return this.compare(m.other) < 0
endfunc

* -----------------
function LTE(other as Variant) && {fr} cette version est inférieure ou égale à une autre
return this.compare(m.other) <= 0
endfunc

* -----------------
function EQ(other as Variant) && {fr} cette version est égale à une autre
return empty(this.compare(m.other))
endfunc

* -----------------
function NEQ(other as Variant) && {fr} cette version est différente d'une autre
return !empty(this.compare(m.other))
endfunc

* -----------------
function minorGT(other as Variant) && {fr} cette version est supérieure à une autre, au niveau mineur
return this.compareMinor(m.other) > 0
endfunc

* -----------------
function minorGTE(other as Variant) && {fr} cette version est supérieure ou égale à une autre, au niveau mineur
return this.compareMinor(m.other) >= 0
endfunc

* -----------------
function minorLT(other as Variant) && {fr} cette version est inférieure à une autre, au niveau mineur
return this.compareMinor(m.other) < 0
endfunc

* -----------------
function minorLTE(other as Variant) && {fr} cette version est inférieure ou égale à une autre, au niveau mineur
return this.compareMinor(m.other) <= 0
endfunc

* -----------------
function minorEQ(other as Variant) && {fr} cette version est égale à une autre, au niveau mineur
return empty(this.compareMinor(m.other))
endfunc

* -----------------
function minorNEQ(other as Variant) && {fr} cette version est différente d'une autre, au niveau mineur
return !empty(this.compareMinor(m.other))
endfunc

* -----------------
function inspect && {en} readable version
return '<SemVer "' + this.version + '">'
endfunc

* -----------------
hidden function prereleaseClear
dimension this.prerelease[1]
this.prerelease = .null.
this.lPreRelease = .f.

* -----------------
function inc && {en} increment version
lparameters ;
  release; && [''] {en} type of release
, Identifier; && ['beta'] {en} if m.release = 'pre..' pre-release identifier such as 'beta'

release    = evl(m.release, '')
Identifier = evl(m.Identifier, 'beta')

local success as Boolean;
, iPreRelease as integer;
, nPreRelease as integer;

success = .t.

do case

case !ga_Type_IsChar(m.release, .t.)
	success = .f.

case !varSet(@m.release, lower(cEuroANSI(alltrim(m.release))))

&& {en} premajor will bump the version up to the next major release, and immediately down to pre-release.
&& {en} preminor and prepatch work the same way.
case m.release == 'premajor'
	this.major = this.major + 1
	store 0 to this.minor, this.patch
	this.prereleaseClear
	success = this.inc('pre', m.Identifier)

case m.release == 'preminor'
	this.minor = this.minor + 1
	this.patch = 0
	this.prereleaseClear
	success = this.inc('pre', m.Identifier)

case m.release == 'prepatch' && {en} If this is already a prerelease, it'll bump to the next version
	this.prereleaseClear && {en} drop any prereleases that might already exist, since they are not relevant at this point.
	success = .t.;
	 and this.inc('patch');
	 and this.inc('pre', m.Identifier)

case m.release == 'prerelease'
	success = .t.;
	 and (m.this.lPreRelease or this.inc('patch')); && {en} If input is a non-prerelease version, this acts the same as a prepatch.
	 and this.inc('pre', m.Identifier)


case m.release == 'major'
&& {en} If this is a pre-major version, bump up to the same major version, else increment major.
&& 1.0.0-5 bumps to 1.0.0
&& 1.1.0 bumps to 2.0.0
  if this.minor > 0 or this.patch > 0 or !m.this.lPreRelease
	  this.major = this.major + 1
  endif
	store 0 to this.minor, this.patch
  this.prereleaseClear

case m.release == 'minor'
&& {en} If this is a pre-minor version, bump up to the same minor version, else increment minor.
&& 1.2.0-5 bumps to 1.2.0
&& 1.2.1 bumps to 1.3.0
  if this.patch > 0 or !m.this.lPreRelease
    this.minor = this.minor + 1
  endif
  this.patch = 0
  this.prereleaseClear

case m.release == 'patch'
&& {en} If this is not a pre-release version, it will increment the patch: 1.2.0 patches to 1.2.1
&& {en} If it is a pre-release it will bump up to the same patch version: 1.2.0-5 patches to 1.2.0
  if !m.this.lPreRelease
    this.patch = this.patch + 1
  endif
  this.prereleaseClear

case m.release == 'pre' and lCallingModule('inc') && && {en} This probably shouldn't be used publicly because 1.0.0 "pre" would become 1.0.0-0 which is the wrong direction.

	if !m.this.lPreRelease
		store 0 to this.prerelease, nPreRelease
	else
&& 1.2.0-beta.1 bumps to 1.2.0-beta.2
		nPreRelease = alen(m.this.prerelease)
		for iPreRelease = m.nPreRelease to 1 step -1
			if vartype(m.this.prerelease[m.iPreRelease]) == 'N'
				this.prerelease[m.iPreRelease] = m.this.prerelease[m.iPreRelease] + 1
				exit
			endif
		endfor
		if empty(m.iPreRelease) && {en} didn't increment anything
			nPreRelease = m.nPreRelease + 1 && {fr} JS Array.push() ajoute un ou plusieurs éléments à la fin d'un tableau et retourne la nouvelle taille du tableau.
			dimension this.prerelease[m.nPreRelease]
			this.prerelease[m.nPreRelease] = 0
		endif
	endif

&& 1.2.0-beta.fooblz or 1.2.0-beta bump to 1.2.0-beta.0
	do case
	case !ga_Type_IsChar(m.Identifier, .t.)
	case !varSet(@m.Identifier, lower(cEuroANSI(alltrim(m.Identifier))))
	case .f.;
	 or !luEqual(this.prerelease[1], m.Identifier, .t.);
	 or alen(this.prerelease) < 2;
	 or !vartype(this.prerelease[2]) == 'N'
		dimension this.prerelease[2]
		this.prerelease[1] = m.Identifier
		this.prerelease[2] = 0
	endcase

otherwise
	success = .f.

endcase

assert m.success message textmerge([<<cL(m.release)>> is an invalid release verb])

this.format
this.raw = this.version

return m.success
endfunc

* =============================
enddefine && CLASS abSemVer
* =============================

* -----------------
function abSemVer_test && {fr} teste la classe abSemVer
lparameters nTest && @ {en} number of tests ran

local success as Boolean;
, unitTest as Boolean;
, oUnitTest as abUnitTest of abDev.prg;
, oAsserts as abSet of abDev.prg;
, oSemVer as abSemVer of abDev.prg;

* {fr} oUnitTest = abUnitTest()
oAsserts  = abSet('ASSERTS', 'ON')
success = .t.
nTest = 0

&& {fr} InstallShield support: prerelease is a number separated by '.' from main version
success = cSemVer('2.20.0.1', .T.) == '2.20.0-beta.1' and m.success
nTest = m.nTest + 1

&& {fr} back compat.: allow for missing dot between prerelease type and number
success = cSemVer('2.20beta1', .T.) == '2.20.0-beta.1' and m.success
nTest = m.nTest + 1

&& {fr} back compat.: allow for missing dot between prerelease type and number
success = cSemVer('2.20 beta1', .T.) == '2.20.0-beta.1' and m.success
nTest = m.nTest + 1

&& {fr} back compat.: allow for accented characters
success = cSemVer('2.20 bêta1', .T.) == '2.20.0-beta.1' and m.success
nTest = m.nTest + 1

&& {fr} major: 1.0.0-5 bumps to 1.0.0
success = abSemVer_test_inc('1.0.0-5', '1.0.0', 'major') and m.success
nTest = m.nTest + 1

&& {fr} major: 1.1.0 bumps to 2.0.0
success = abSemVer_test_inc('1.1.0', '2.0.0', 'major') and m.success
nTest = m.nTest + 1

&& {fr} prerelease: 1.2.0-beta.1 bumps to 1.2.0-beta.2
success = abSemVer_test_inc('1.2.0-beta.1', '1.2.0-beta.2', 'prerelease') and m.success
nTest = m.nTest + 1

&& {fr} minor: 1.2.0-5 bumps to 1.2.0
success = abSemVer_test_inc('1.2.0-5', '1.2.0', 'minor') and m.success
nTest = m.nTest + 1

&& {fr} minor: 1.2.1 bumps to 1.3.0
success = abSemVer_test_inc('1.2.1', '1.3.0', 'minor') and m.success
nTest = m.nTest + 1

&& {fr} patch: 1.2.1 bumps to 1.2.2
success = abSemVer_test_inc('1.2.1', '1.2.2', 'patch') and m.success
nTest = m.nTest + 1

&& {fr} patch: 1.2.1-beta bumps to 1.2.1
success = abSemVer_test_inc('1.2.1-beta', '1.2.1', 'patch') and m.success
nTest = m.nTest + 1

&& {fr} prepatch: If this is already a prerelease, it'll bump to the next version
success = abSemVer_test_inc('1.2.1-beta', '1.2.2-beta.0', 'prepatch') and m.success
nTest = m.nTest + 1

&& {fr} prepatch:
success = abSemVer_test_inc('1.2.1', '1.2.2-beta.0', 'prepatch') and m.success
nTest = m.nTest + 1

&& {fr} prerelease on previous case:
success = abSemVer_test_inc('1.2.2-beta.0', '1.2.2-beta.1', 'prerelease') and m.success
nTest = m.nTest + 1

#if .F. && {fr} select > right click > 'execute selection' > paste below
AB()
nTest = 0
_cliptext = nEvl(varSet(@m.nTest, 0), '') + textmerge([&]+[& <<Datetime()>> - abSemVer_test(): <<abSemVer_test(@m.nTest)>> - <<m.nTest>> tests] + chr(13))
#endif

&& 18/09/15 10:44:13 - abSemVer_test(): .T. - 10 tests
&& 24/09/15 15:53:59 - abSemVer_test(): .T. - 11 tests
&& 24/09/15 15:57:42 - abSemVer_test(): .T. - 12 tests
&& 13/10/15 18:23:42 - abSemVer_test(): .T. - 13 tests
&& 13/10/15 18:28:56 - abSemVer_test(): .T. - 14 tests

return m.success
endfunc

* -----------------
function abSemVer_test_inc && {fr} teste abSemVer.inc() qui est la méthode la plus délicate
lparameters ;
  versionFrom;
, versionTo;
, release; && ['patch'] {en} type of release
, Identifier; && [''] {en} if m.release = 'pre..' pre-release identifier such as 'beta'

local success as Boolean;
, oSemVer as abSemVer of abDev.prg;

oSemVer = abSemVer(m.versionFrom)
success = m.oSemVer.inc(m.release, m.Identifier) and m.oSemVer.version == m.versionTo

assert m.success
return m.success
endfunc

* -----------------
function cSemVerInc && {fr} Incrémente une version mineure ou patch abSemVer
lparameters version

version = Evl(m.version, '2.21.1') && , '2.21.0'

return; && copy next line, then execute ? AB(), cSemVerIncExprToXL_fr(), _cliptext, then paste into Excel cell
Iif(Val(Substr(m.version, At(".", m.version, 2)+1, 10))=0, Left(m.version, At(".", m.version, 1)) + Ltrim(Str(Val(Substr(m.version, At(".", m.version, 1)+1, At(".", m.version, 2)-At(".", m.version, 1)-1))+1, 3)) + ".0", Left(m.version, At(".", m.version, 2)) + Ltrim(Str(Val(Substr(m.version, At(".", m.version, 2)+1, 10))+1, 3)))
endfunc

* -----------------
procedure cSemVerIncExprToXL_fr && {fr} Formule Excel incrémentant une version abSemVer mineure ou patch
_cliptext = '=' + Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(_cliptext;
	, '".", m.version, 2', '".", m.version, At(".", m.version, 1)+1', 1, -1, 1);
	, ',', ';');
	, '; 3', '; "###"', 1, -1, 1);
	, ' + ', '&', 1, -1, 1);
	, 'Iif', 'si', 1, -1, 1);
	, 'Empty', 'estvide', 1, -1, 1);
	, 'Val', 'cNUM', 1, -1, 1);
	, 'Substr', 'stxt', 1, -1, 1);
	, 'Str', 'texte', 1, -1, 1);
	, 'm.version', 'LC(-23)', 1, -1, 1);
	, 'at', 'cherche', 1, -1, 1);
	, 'ltrim', 'supprespace', 1, -1, 1);
	, 'left', 'gauche', 1, -1, 1);

* -----------------
procedure UTF8fix1252 && {fr} corrige les caractères accentués dans un fichier converti par erreur en UTF8
lparameters tcSrce

local success as Boolean;
, result as String;
, lFile as Boolean;

success = .T.

lFile = File(m.tcSrce)
result = Iif(m.lFile, FileToStr(m.tcSrce), m.tcSrce)

result = Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(m.result;
	, 'Ã ', 'à');
	, 'Ã©', 'é');
	, 'Ã‰', 'É');
	, 'Ã¨', 'è');
	, 'Ãª', 'ê');
	, 'Ã®', 'î');
	, 'Ã»', 'ù');
	, 'Ã¹', 'û');
	, 'Ã§', 'ç');
	, 'Ã´', 'ô');
	, 'Â°', '°');

&& ? Strconv(Substr(m.european, 128),9)
&& {fr} for each character in Substr(m.european, 128), text = strtran(text Strconv(char, 9), char)

if m.lFile
	success = StrToFile(m.result, FullPath(m.tcSrce)) > 0
else
	tcSrce = m.result
endif

return m.success
endproc

#if .F.
; {en} To be properly visible in the browser, this file is encoded in UTF8
; {en} Please use an UTF8-aware text editor such as notePad++, subime text or PSPad
; {fr} Pour être visible dans le navigateur, ce fichier est encodé en UTF8
; {fr} Veuillez l'éditer avec un logiciel sensible à l'UTF8 comme notePad++, subime text ou PSPad

#endif

* -----------------
function caError && {fr} version textuelle plus compréhensible de aError()
lparameters errNum && @ {en} [0] error number out

local result as String;
, nError as Integer;
, iError as Integer;
, aa[1];

result = ''
nError = AError(aa)
errNum = m.aa[1]

do case
case Empty(m.nError)
	errNum = 0

case m.errNum = 1526 && {en} When an ODBC error numbered 1526 occurs, the array contains one or more rows, one row for each ODBC error.
	for iError = 1 to m.nError
		text to result textmerge noshow additive flags 1 pretext 3
			ODBC error # 1526
			Error message: <<m.aa[m.iError, 2]>>
			ODBC error message: <<m.aa[m.iError, 3]>>
			ODBC SQL state: <<m.aa[m.iError, 4]>>
			Error number from the ODBC data source: <<m.aa[m.iError, 5]>>
			ODBC connection handle: <<m.aa[m.iError, 6]>>

		endtext
	endfor

case InList(m.errNum, 1427, 1429) && {en} When OLE errors numbered 1427 or 1429 occur, the array contains one row. The following table describes the contents of each element
		text to result textmerge noshow flags 1 pretext 3
			OLE error  #  <<m.errNum>>
			Visual FoxPro error message: <<m.aa[2]>>
			OLE error message: <<m.aa[3]>>
			Application: <<m.aa[4]>>
			Application's Help file: <<m.aa[5]>>
			Application's Help context ID: <<m.aa[6]>>
			OLE 2.0 exception number: <<m.aa[7]>>
		endtext
 
otherwise
		text to result textmerge noshow flags 1 pretext 3
			Error(): <<m.errNum>>
			Message(): <<m.aa[2]>>
			Error parameters if any: <<m.aa[3]>>
			Work area: <<m.aa[4]>>
			Trigger failed: <<ICase(m.aa[5] = 1, 'Insert', m.aa[5] = 2, 'Update', m.aa[5] = 3, 'Delete', 'N/A')>>
		endtext
	
endcase
return m.result
endfunc

* -----------------
function CPUutilisation as Number && {fr} Pourcentage d'utilisation du CPU
&& http://msdn2.microsoft.com/en-us/library/aa394597.aspx
&& http://www.atoutfox.org/articles.asp?ACTION=FCONSULTER&ID=0000000428
&& (c) Anatole Baudoin
local result, oWmi, oProcessor, nN1,nD1, nN2,nD2
result = .null.
try && 2016-01-25 thn -- {en} added to prevent bugs when "file can't be opened"
	oWmi = GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")
	oProcessor = m.oWmi.Get("Win32_PerfRawData_PerfOS_Processor.Name='_Total'")
	if Vartype(m.oProcessor) == 'O' && 2016-01-15 thn -- {en} protection
		nN1 = Val(m.oProcessor.PercentProcessorTime)
		nD1 = Val(m.oProcessor.TimeStamp_Sys100NS)
		Sleep(100) && modify command ab
		oProcessor = m.oWmi.Get("Win32_PerfRawData_PerfOS_Processor.Name='_Total'")
		nN2 = Val(m.oProcessor.PercentProcessorTime)
		nD2 = Val(m.oProcessor.TimeStamp_Sys100NS)
		result = Max(0, (1 - ((m.nN2 - m.nN1) / (m.nD2 - m.nD1))) * 100)
	endif
catch
	result = .null.
endtry
return m.result
endfunc

* -----------------
function cInst1Line as String && {fr} Instruction sur une seule ligne (par ex. pour macro-substitution)
lparameters cInst
return cRepCharDel(Chrtran(cInLineCommentStripped(m.cInst), ';'+Chr(13)+Chr(10), Space(3)))
endfunc

* -----------------
function lIP as Boolean && {fr} a string represents an Internet Protocol address
lparameters cIP
local abRegExp as abRegExp of abTxt.prg
return ga_Type_IsChar(m.cIP, .T.);
 and varSet(@m.abRegExp, abRegExp());
 and loClass(m.abRegExp, 'abRegExp');
 and m.abRegExp.setup("(?:\d{1,3}\.){3}\d{1,3}", .F., .F., .F.);
 and m.abRegExp.test(m.cIP)
endfunc

* -----------------
function dWordOfInt && {en} DWORD from an integer
lparameters nValue && integer (unsigned)
return Chr(Mod(m.nValue,256)) + Chr(Int(m.nValue/256)) && binary string
endfunc

* -----------------
function abPathAdd(cPath) && {en} abPathAdd object
return CreateObject('abPathAdd', m.cPath)
endfunc
* -----------------
define class abPathAdd as GA_LIGHTWEIGHT_CLASS of abGA.prg && {fr} ajoute un élément à Set('Path') et l'ôte au .destroy()
hidden cPath
procedure init(cPath)
this.cPath = FullPath(m.cPath)
return Nvl(PathAdd(this.cPath), .F.)
procedure destroy
return PathRemove(this.cPath)
enddefine

* -----------------
function abProcAdd(cProc) && {en} abProcAdd object
return CreateObject('abProcAdd', m.cProc)
* -----------------
define class abProcAdd as GA_LIGHTWEIGHT_CLASS of abGA.prg && {fr} ajoute un élément à Set('Procedure') et l'ôte au .destroy()
hidden cProc
procedure init(cProc)
this.cProc = FullPath(ForceExt(m.cProc, 'fxp'))
return Nvl(ProcedureAdd(this.cProc), .F.)
procedure destroy
return ProcedureRemove(this.cProc)
enddefine

* -----------------
function abWait(cMsg) && {en} abWait object
return CreateObject('abWait', m.cMsg)
* -----------------
define class abWait as GA_LIGHTWEIGHT_CLASS of abGA.prg
procedure init(cMsg)
return wWAIT(Evl(m.cMsg, ''), 'window nowait noclear')
procedure destroy
wWAIT('', 'clear')
enddefine && class abWait

* ========================================
function tProjectVCXlastModified && {en} most recent last modification date of vcx in a project
lparameters ;
  cPJX; && [_VFP.ActiveProject] {en} project
, lExcluded; && [.F.] {en} also take into account excluded vcx
, cFileLastModified; && @ [.null.] {en} file that was last modified in the whole project (taking *.?ct into account)

local tResult as datetime;
, lActiveProject as Boolean;
, lProjectOpen as Boolean;
, oFile as File;
, tFile as datetime;

store .null. to tResult, cFileLastModified

lActiveProject = Type('_VFP.ActiveProject') == 'O'

lProjectOpen = ga_Type_IsChar(m.cPJX, .T.);
	and File(m.cPJX);
	and Lower(JustExt(m.cPJX)) == Lower('pjx');
	and !(m.lActiveProject and Lower(_VFP.ActiveProject.Name) == Lower(FullPath(m.cPJX)))
if m.lProjectOpen
	ignoreAll() && modify command abDev
	modify project (m.cPJX) nowait noshow noprojecthook
	keyboard '' clear
	lActiveProject = .T.
endif

if m.lActiveProject
	lExcluded = lTrue(m.lExcluded)
	for each oFile in _VFP.ActiveProject.Files foxobject
		if (m.lExcluded or !m.oFile.Exclude);
		 and Lower(JustExt(m.oFile.Name)) == Lower('vcx');
		 and varSet(@m.tFile, tFile(m.oFile.Name, .T.));
		 and m.tFile > Nvl(m.tResult, {/:})
			tResult = m.tFile
			cFileLastModified = m.oFile.Name
		endif
	endfor
endif

if m.lProjectOpen
	_VFP.ActiveProject.Close
endif

return m.tResult
endfunc

*!*  Objet : Implémention en VisualFoxPro de l'algorithme de hachage SHA1
*!*  Auteur : C.Chenavier
*!*  Version : 1.00 - 15/11/2004
*!*  Les tests ont été réalisés avec le programme HashCalc : http://www.slavasoft.com

*!*  SHA signifie "Secure Hash Algorithm"
*!*  On utilise souvent le terme SHA-1 pour noter la version
*!*  SHA est une fonction de hachage qui produit des empreintes de 160 bits,
*!*  contrairement à MD5 qui produit des empreintes de 128 bits.
*!*  Cette fonction de hachage a été développée conjointement par la NSA et le NIST
*!*  pour être le standard des fonctions de hachage (FIPS PUB 180-1).
*!*  SHA est basé sur MD4 et est réputé plus sûr que MD5.
*!*  SHA fonctionne sur des messages dont la taille est inférieure à 2^64 bits
*!*  et travaille sur des blocs de 512 bits.

*!* ---------- SHA-1 TEST SUITE ----------
*!*  SHA-1("") = da39a3ee5e6b4b0d3255bfef95601890afd80709, ok
*!*  SHA-1("a") = 86f7e437faa5a7fce15d1ddcb9eaeaea377667b8, ok
*!*  SHA-1("abc") = a9993e364706816aba3e25717850c26c9cd0d89d, ok
*!*  SHA-1("message digest") = c12252ceda8be8994d5fa0290a47231c1d16aae3, ok
*!*  SHA-1(a..z) = 32d10c7b8cf96570ca04ce37f2a19d84240d3a89, ok
*!*  SHA-1(A..Za..z0..9) = 761c457bf73b14d27e9e9265c46f4b4dda11f940, ok
*!*  SHA-1(8 times "1234567890") = 50abf5706a150990a08b2c5ea40fa0e585554732, ok

*!*  Exemples de test :
*!*  MessageBox(SHA1("")="da39a3ee5e6b4b0d3255bfef95601890afd80709")
*!*  MessageBox(SHA1("a")="86f7e437faa5a7fce15d1ddcb9eaeaea377667b8")
*!*  MessageBox(SHA1("abc")="a9993e364706816aba3e25717850c26c9cd0d89d")
*!*  MessageBox(SHA1("message digest")="c12252ceda8be8994d5fa0290a47231c1d16aae3")
*!*  MessageBox(SHA1("abcdefghijklmnopqrstuvwxyz")="32d10c7b8cf96570ca04ce37f2a19d84240d3a89")
*!*  MessageBox(SHA1("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789")="761c457bf73b14d27e9e9265c46f4b4dda11f940")
*!*  MessageBox(SHA1(REPLICATE("1234567890",8))="50abf5706a150990a08b2c5ea40fa0e585554732")
*!*  MessageBox(SHA1("ceci est un test")="71438dc237b45f04759c41e1b2d34f42a46318f3")

* ---------------------------------------------
FUNCTION SHA1 && {en} RSA-SHA1 digital signature
LPARAMETERS cMessage

PRIVATE HO, H1, H2, H3, H4
LOCAL nNbBlocs, nHigh, nLow

H0 = 0x67452301
H1 = 0xEFCDAB89
H2 = 0x98BADCFE
H3 = 0x10325476
H4 = 0xC3D2E1F0

nNbBlocs = LEN(m.cMessage) / 64

** Si au départ, la taille du message n'est pas un multiple de 512,
** alors l'algorithme complète le message en ajoutant un 1 et
** autant de 0 que nécessaires et les 8 derniers octets servent
** à stocker la longueur du message.

nLen = LEN(m.cMessage)
nReste = MOD(m.nLen, 64)
IF m.nReste > 0 OR m.nLen = 0
	nNbBlocs = m.nNbBlocs + 1
	IF m.nReste > 55
		cMessage = m.cMessage + CHR(2^7) + REPLICATE(CHR(0), (64 - m.nReste) + 55)
		nNbBlocs = m.nNbBlocs + 1
	ELSE
		cMessage = m.cMessage + CHR(2^7) + REPLICATE(CHR(0), (55 - m.nReste))
	ENDIF
	nHigh = (m.nLen*8) / 2^32
	nLow = MOD(m.nLen*8, 2^32)
	cMessage = m.cMessage + CHR(BITAND(BITRSHIFT(m.nHigh, 24), 0xFF)) ; && 56
		+ CHR(BITAND(BITRSHIFT(m.nHigh, 16), 0xFF)) ; && 57
		+ CHR(BITAND(BITRSHIFT(m.nHigh, 8), 0xFF)) ; && 58
		+ CHR(BITAND(m.nHigh, 0xFF)) ; && 59
		+ CHR(BITAND(BITRSHIFT(m.nLow, 24), 0xFF)) ; && 60
		+ CHR(BITAND(BITRSHIFT(m.nLow, 16), 0xFF)) ; && 61
		+ CHR(BITAND(BITRSHIFT(m.nLow, 8), 0xFF)) ; && 62
		+ CHR(BITAND(m.nLow, 0xFF)) && 63
ENDIF

FOR I = 1 TO m.nNbBlocs
	DO SHA1_ProcessBloc WITH SUBSTR(m.cMessage, 1 + 64*(I-1), 64)
ENDFOR

RETURN Lower(SUBSTR(TRANSFORM(H0,"@0"),3) + ;
		SUBSTR(TRANSFORM(H1,"@0"),3) + ;
		SUBSTR(TRANSFORM(H2,"@0"),3) + ;
		SUBSTR(TRANSFORM(H3,"@0"),3) + ;
		SUBSTR(TRANSFORM(H4,"@0"),3);
		)

* ---------------------------------------------
PROCEDURE SHA1_ProcessBloc && [Internal] {en} SHA1() private
LPARAMETERS cBloc

LOCAL I, A, B, C, D, E, nTemp
LOCAL ARRAY W[80]

** Pour chaque bloc de 512 bits, on divise le bloc en 16 mots de 32 bits
** et on les affecte respectivement à W1, W2...W16.
FOR I = 1 TO 16
		II = m.I - 1
		W[I] = BITLSHIFT(ASC(SUBSTR(m.cBloc, m.II * 4 + 1, 1)), 24) + ;
		BITLSHIFT(ASC(SUBSTR(m.cBloc, m.II * 4 + 2, 1)), 16) + ;
		BITLSHIFT(ASC(SUBSTR(m.cBloc, m.II * 4 + 3, 1)), 8) + ;
		ASC(SUBSTR(m.cBloc, m.II * 4 + 4, 1))
ENDFOR

** Pour I variant de 17 à 80, on affecte les mots Wi de la manière suivante :
** Wi = Wi-3 XOR Wi-8 XOR Wi-14 XOR Wi-16
FOR I = 17 TO 80
		W[i] = BitLRotate(1, BITXOR(W[i-3], W[i-8], W[i-14], W[i-16]))
ENDFOR

A = H0
B = H1
C = H2
D = H3
E = H4

** Pour I variant de 1 à 80 et avec Sn un décalage circulaire gauche de n bits,
** on effectue les calculs suivants :
FOR I = 1 TO 20
		nTemp = BitLRotate(5, A) + BITOR(BITAND(B, C), BITAND(BITNOT(B), D)) + ;
		E + W[i] + 0x5A827999
		E = D
		D = C
		C = BitLRotate(30, B)
		B = A
		A = m.nTemp
ENDFOR

FOR I = 21 TO 40
		nTemp = BitLRotate(5, A) + BITXOR(B, C, D) + E + W[i] + 0x6ED9EBA1
		E = D
		D = C
		C = BitLRotate(30, B)
		B = A
		A = m.nTemp
ENDFOR

FOR I = 41 TO 60
		nTemp = BitLRotate(5, A) + BITOR(BITAND(B, C), BITAND(B, D), BITAND(C, D)) + ;
		E + W[i] + 0x8F1BBCDC
		E = D
		D = C
		C = BitLRotate(30, B)
		B = A
		A = m.nTemp
ENDFOR

FOR I = 61 TO 80
		nTemp = BitLRotate(5, A) + BITXOR(B, C, D) + E + W[i] + 0xCA62C1D6
		E = D
		D = C
		C = BitLRotate(30, B)
		B = A
		A = m.nTemp
ENDFOR

H0 = H0 + A
H1 = H1 + B
H2 = H2 + C
H3 = H3 + D
H4 = H4 + E
endfunc

* ---------------------------------------------
FUNCTION BitLRotate && {en} rotates bits around
LPARAMETERS nBits, nWord
RETURN BITLSHIFT(m.nWord, m.nBits) + BITRSHIFT(m.nWord, (32 - (m.nBits)))
endfunc

* ---------------------------------------------
function nOfcDWord && {en} Number from a Signed DWORD or Integer binary string
lparameters tcDWord, tlSigned

local i, nOfcDWord

nOfcDWord = 0
FOR i = 1 TO LEN(m.tcDWord)
  nOfcDWord = m.nOfcDWord + (Asc(Substr(m.tcDWord, m.i, 1)) * (2 ^ (8 * (m.i - 1))))
ENDFOR

IF m.tlSigned and nOfcDWord > 0x80000000
  nOfcDWord = nOfcDWord - 1 - 0xFFFFFFFF
ENDIF

return m.nOfcDWord
endfunc

* ---------------------------------------------
function aVFPsets && {en} VFP Sets
lparameters ;
  aVFPsets; && @ {en} VFP Sets
, tlSetsType; && [.null.] {en} type of SETs .T.: scoped to the dataSession, .F.: global, .null.: all
, tlProcClass; && [.F.] {en} add Set("Procedure") & Set("Classlib")
, tlUnSupported; && [.F.] {en} add sets for which auto-restore is not supported

external array aVFPsets
tlSetsType = Iif(Pcount()>=2 and Vartype(m.tlSetsType) $ 'LX', m.tlSetsType, .null.)
tlUnSupported = lTrue(m.tlUnSupported)

local cSets
cSets = ''

if lTrue(Nvl(m.tlSetsType, .T.)) && scoped to the datasession
text to cSets textmerge noshow flags 1 pretext 3
	<<m.cSets>>
	ANSI
	AUTOINCERROR
	AUTOSAVE
	BLOCKSIZE
	CARRY
	CENTURY
	COLLATE
	CURRENCY
	DATABASE
	DATE
	DECIMALS
	DELETED
	EXACT
	EXCLUSIVE
	FIELDS
	FIXED
	HOURS
	LOCK
	MARK
	MEMOWIDTH
	MULTILOCKS
	NEAR
	NULL
	POINT
	REFRESH
	REPROCESS
	SAFETY
	SECONDS
	SYSFORMATS
	TALK
	UNIQUE

	CENTURY, 1
	CURRENCY, 1
	FIELDS, 2
	REFRESH, 1
endtext
if m.tlUnSupported
text to cSets textmerge noshow flags 1 pretext 3
	<<m.cSets>>
	date, 1 && Date Ordering: 0 – MDY, 1 – DMY, 2 – YMD
	century, 2 && ROLLOVER nYear
	century, 3 && System Regional Calendar setting
	fields, 1 && FieldName1, FieldName2, ... && 2016-08-18 thn -- {en} removed http://support.west-wind.com/Thread4PC0SHQLT.wwt?rl=1#4PH0Q7H4B
	reprocess, 1 && System session setting
	reprocess, 2 && Current session setting type: 0 means attempts, 1 means seconds
	reprocess, 3 && System session setting type: 0 means attempts, 1 means seconds
	talk, 1 && WINDOW, NOWINDOW or WindowName
endtext
endif
endif

if lFalse(Nvl(m.tlSetsType, .F.)) && not scoped to the datasession -- aka global
text to cSets textmerge noshow flags 1 pretext 3
	<<m.cSets>>
	ALTERNATE
	ASSERTS
	BELL
	BROWSEIME
	CLOCK
	COMPATIBLE
	CONSOLE
	COVERAGE
	CPDIALOG
	DATASESSION
	DEFAULT
	DELIMITERS
	ENGINEBEHAVIOR
	ESCAPE
	FDOW
	FULLPATH
	FWEEK
	HELP
	LIBRARY
	MESSAGE
	MOUSE
	NOTIFY
	NULLDISPLAY
	ODOMETER
	OPTIMIZE
	PATH
	PRINTER
	REPORTBEHAVIOR
	RESOURCE
	SEPARATOR
	SPACE
	SQLBUFFERING
	STATUS
	STATUS BAR
	STRICTDATE
	SYSMENU
	TABLEPROMPT
	TABLEVALIDATE
	TEXTMERGE
	TEXTMERGE, 1
	TEXTMERGE, 2
	TEXTMERGE, 3
	UDFPARMS

	ALTERNATE, 1
	BELL, 1
	COVERAGE, 1
	MOUSE, 1
	RESOURCE, 1
	DELIMITERS, 1
	MESSAGE, 1
	HELP, 1
endtext
if m.tlUnSupported
text to cSets textmerge noshow flags 1 pretext 3
	<<m.cSets>>
	compatible, 1 && PROMPT or NOPROMPT (determines whether Visual FoxPro displays a dialog box when you open a dBASE table containing a memo field)
	notify, 1 && current value of SET NOTIFY CURSOR
	nocptrans && 2016-08-18 thn -- {en} removed http://support.west-wind.com/Thread4PC0SHQLT.wwt?rl=1#4PH0Q7H4B
	textmerge, 4 && Evaluate source of TEXT ... ENDTEXT call and return TEXTMERGE nesting level
endtext
endif
endif

cSets = Trim(cInLineCommentStripped(m.cSets), CR, LF) + CRLF + iif(lTrue(m.tlProcClass);
	, '';
		+ 'PROCEDURE' + CRLF;
		+ 'CLASSLIB' + CRLF;
	, '';
	)

return ALines(m.aVFPsets, Upper(m.cSets), 5)
endfunc

*---------------------------------------------------------------------------
function uVFPsetValue as Variant && {en} current value of a SET
lparameters lcSet, lnSet

return icase(;
		m.lcSet == 'DEFAULT',;
			set(m.lcSet) + curdir(),;
		empty(m.lnSet),;
			set(m.lcSet),;
			set(m.lcSet, m.lnSet);
		)

endfunc

* ---------------------------------------------
function aVFPsetsValue && {en} Array of VFP Sets and their Value - use outside of textmerge()
lparameters ;
  aVFPsetsValue; && @ {en} [SET, specifier, value]
, tlSetsType; && [.null.] {en} type of SETs .T.: scoped to the dataSession, .F.: global, .null.: all
, tlProcClass; && [.F.] {en} add Set("Procedure") & Set("Classlib")
, tlUnSupported; && [.F.] {en} add sets for which auto-restore is not supported

external array aVFPsetsValue
tlSetsType = Iif(Pcount()>=2 and Vartype(m.tlSetsType) $ 'LX', m.tlSetsType, .null.)

local result as Integer; && number of sets
, liSet as Integer;

result = aVFPsets(; && see below
	 @m.aVFPsetsValue;
	, m.tlSetsType; && [.null.] {en} SETs .T.: scoped to the dataSession, .F.: global, .null.: all
	, m.tlProcClass;
	, m.tlUnSupported;
	)
if m.result > 0

	aColsIns(@m.aVFPsetsValue, 1, 2)

	for liSet = 1 to m.result

		aVFPsetsValue[m.liSet, 2] = evl(int(val(getwordnum(m.aVFPsetsValue[m.liSet, 1], 2, ','))), 0)
		aVFPsetsValue[m.liSet, 1] = alltrim(getwordnum(m.aVFPsetsValue[m.liSet, 1], 1, ','))
		aVFPsetsValue[m.liSet, 3] = uVFPsetValue(aVFPsetsValue[m.liSet, 1], aVFPsetsValue[m.liSet, 2])
	endfor
endif

return m.result
endfunc

* ---------------------------------------------
function cVFPsetsValue && {en} String of VFP Sets and their Value - use outside of textmerge()
lparameters ;
  tcSeparator; && [', '] {en} SETs separator
, tlSetsType; && [.null.] {en} type of SETs .T.: scoped to the dataSession, .F.: global, .null.: all
, tlProcClass; && [.F.] {en} add Set("Procedure") & Set("Classlib")
, tlUnSupported; && [.F.] {en} add sets for which auto-restore is not supported

tlSetsType = Iif(Pcount()>=2 and Vartype(m.tlSetsType) $ 'LX', m.tlSetsType, .null.)

local result as String;
, aa[1]; && @ {en} [SET, specifier, value]
, loSelect as abSelect of abData.prg;
, luSet as String;
, liSet as Integer;
, lcSet1 as Integer;

result = ''
if aVFPsetsValue(@m.aa, m.tlSetsType, m.tlProcClass, m.tlUnSupported) > 0

	* {en} sort on columns # 1, 2
	loSelect = abSelect(0)
	create cursor _cVFPsetsValue_ (cSet varchar(30), iSet I, nSet I NULL, mSet M NULL)
	index on cSet + Str(iSet) tag cVFPsets
	for liSet = 1 to Alen(m.aa, 1)
		luSet = m.aa[m.liSet, 3]
		insert into _cVFPsetsValue_ values (;
			  m.aa[m.liSet, 1];
			, m.aa[m.liSet, 2];
			, Iif(Vartype(m.luSet) == 'N', m.luSet, .null.);
			, Iif(Vartype(m.luSet) == 'C', m.luSet, .null.);
			)
	endfor
	liSet = 0
	scan
		liSet = m.liSet + 1
	  aa[m.liSet, 1] = cSet
		aa[m.liSet, 2] = iSet
		aa[m.liSet, 3] = Nvl(nSet, mSet)
	endscan
	use

	tcSeparator = Iif(ga_Type_IsChar(m.tcSeparator, .T.), m.tcSeparator, ', ')
	for liSet = 1 to Alen(m.aa, 1)
		lcSet1 = Cast(Evl(m.aa[m.liSet, 2], '') as M) 
		result = m.result;
			+ m.tcSeparator;
			+ 'Set("';
			+ m.aa[m.liSet, 1];
			+ nEvl(m.lcSet1, '", ' + m.lcSet1) + Iif(Empty(m.lcSet1), '"', '');
			+ ') = ';
			+ cL(m.aa[m.liSet, 3]);
			+ ''
	endfor

	result = Substrc(m.result, Lenc(m.tcSeparator) + 1)
endif

return m.result
endfunc

* ========================================
function nProjectFiles && {en} number of files in a project matching search criteria
lparameters ;
  tuPJX as Project; && @ {en} Project address or object
, tcFileSkel as String; && @ [all] File skeleton; @ files found
, tcFileType as String; && [all] see modify file foxpro.h > "File Object Type Property" 
, tlExclude as Boolean; && [.null.] Excluded from project

local array aa[1]
return aProjectFiles(; && {en} number of files in a project matching search criteria
	 @m.aa; && @ {en} 
	, m.tuPJX; && @ {en} Project address or object
	,@m.tcFileSkel; && @ [all] {en} File skeleton; @ files found
	, m.tcFileType; && [all] {en} see modify file foxpro.h > "File Object Type Property" 
	, m.tlExclude; && [.null.] {en} Excluded from project
	)
endfunc

* ========================================
function aProjectFiles && {en} files in a project matching search criteria
lparameters ;
  aProjectFiles; && @ {en} Files in project
, tuPJX as Project; && @ {en} Project address or object
, tcFileSkel as String; && @ [all] {en} File skeleton; @ files found
, tcFileType as String; && [all] {en} see modify file foxpro.h > "File Object Type Property" 
, tlExclude as Boolean; && [.null.] {en} Excluded from project

local result as Integer;
, success as Boolean;
, oFile as File;
, lFile as Boolean;
, cFilesFound as String;
, cPJX as String;

result = 0

tuPJX = oProject(m.tuPJX)
success = Vartype(m.tuPJX) == 'O'
assert m.success
if m.success

	cPJX = m.tuPJX.Name

	tcFileSkel = Iif(ga_Type_IsChar(m.tcFileSkel, .T.), m.tcFileSkel, .null.)
	tcFileType = Iif(.T.;
	 and ga_Type_IsChar(m.tcFileType, .T.);
	 and varSet(@m.tcFileType, Alltrim(m.tcFileType));
	 and Lenc(m.tcFileType) = 1;
	 and InList(m.tcFileType; && modify file foxpro.h > "File Object Type Property" 
		, FILETYPE_DATABASE;          && Database (.DBC)
		, FILETYPE_FREETABLE;         && Free table (.DBF)
		, FILETYPE_QUERY;             && Query (.QPR)
		, FILETYPE_FORM;              && Form (.SCX)
		, FILETYPE_REPORT;            && Report (.FRX)
		, FILETYPE_LABEL;             && Label (.LBX)
		, FILETYPE_CLASSLIB;          && Class Library (.VCX)
		, FILETYPE_PROGRAM;           && Program (.PRG)
		, FILETYPE_APILIB;            && API Library (.FLL)
		, FILETYPE_APPLICATION;       && Application (.APP)
		, FILETYPE_MENU;              && Menu (.MNX)
		, FILETYPE_TEXT;              && Text (.TXT, .H., etc.)
		, FILETYPE_OTHER;             && Other file types not enumerated above
		);
		, m.tcFileType;
		, .null.;
		)
	tlExclude = Iif(Pcount() >= 4 and Vartype(m.tlExclude) == 'L', m.tlExclude, .null.)

	cFilesFound = ''
	for each oFile as File in m.tuPJX.Files foxobject

		lFile = .T.;
		 and (IsNull(m.tcFileSkel) or Likec(m.tcFileSkel, JustFname(m.oFile.Name)));
		 and (IsNull(m.tcFileType) or m.oFile.Type == m.tcFileType);
		 and (IsNull(m.tlExclude)  or m.oFile.Exclude = m.tlExclude)

		result = m.result + Iif(m.lFile, 1, 0)
		if m.lFile
			dimension m.aProjectFiles[m.result]
			aProjectFiles[m.result] = m.oFile.Name
		endif
		cFilesFound = m.cFilesFound + Iif(m.lFile;
			, ', ' + sys(2014, m.oFile.Name, m.cPJX); && 2016-11-09 thn -- {en} FullPath(m.oFile.Name, m.cPJX) does not work
			, '';
			)

	endfor
	tcFileSkel = Ltrim(Substr(m.cFilesFound, 2))
endif

return m.result
endfunc

#if .F.
_cliptext = ''
for each file in _VFP.ActiveProject.Files foxobject
	_cliptext = _cliptext + Chr(13) + m.file.name 
endfor
_cliptext = Ltrim(_cliptext, Chr(13))
? _cliptext
#endif