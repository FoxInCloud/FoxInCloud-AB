* abDev.prg
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

* =================================================
define class cusBatchLog as custom && Trace un processus répétitif dans un tableau à l'écran
* =================================================

* Valeurs initiales
alConsole = .f.
alFooter = .f.
acScreenFont = .null.
anScreenFontSize = .null.

* -------------------------------
&& Contenu des lignes du tableau de compte rendu
#define  L_cHEADER		1 && Texte de l'en-tête de la colonne
#define  L_uVALUE	 		2 && Ligne courante : contenu original de la cellule
#define  L_cTYPE	 		3 && Ligne courante : type du contenu original
#define  L_cDISPLAY		4 && Ligne courante : contenu affiché (en caractères bien sûr)
#define  L_lBORDER		5 && La colonne est délimitée par des barres verticales
#define  L_nWIDTH			6 && Largeur utilisable pour affichage dans la colonne (foxels)
#define  L_cID				7 && Identifiant de la colonne
#define  L_nSUM				8 && Cumul de la donnée si elle est numérique
#define  L_lSUM				9 && Sommer / moyenner la donnée en fin d'état si elle est numérique
#define  L_cFORMAT		10 && Format pour Transform()
#define  L_COUNT 			L_cFORMAT
* -------------------------------
dimension aaLog[;
				L_COUNT; && une ligne par caractéristique
			, 1] && une colonne par colonne de log

anCols = 0

acLine = space(0) && Contenu de la ligne courante
anLine = 0 && N° de la ligne courante
anDataLines = 0 && Nombre de lignes contenant des données

acWarnings = '' && Avertissements déjà émis
anWarnings = 0  && Avertissements déjà émis

* Adresses des fichiers
acTxtLogAddr = space(0)
acWarnTxtLogAddr = space(0)
acDBFlogAddr = space(0)
acDBFlogAlias = space(0)

alParentPjFiles = .f. && Parent object has a reference to project files collection
alDocumentView = .f.
alDataSession = .f.
alProjectManager = .f.

* -------------------------------------------------
procedure init && Ouvre les fichiers de compte-rendu et vide la fenêtre VFP
lparameters ;
	tuTxtLog,; && [.T.] Nom, dossier ou adresse du fichier de compte-rendu texte, .T. : automatique
	tuDBFlog,; && [.T.] Nom, dossier ou adresse du fichier de la table de compte-rendu, .T. : automatique
	tlFooter,; && [.T.] Produire une ligne de totaux / moyennes en fin de CR
	tlConsole && [.T.] Afficher le compte rendu à l'écran (s'il est visible)

local lnParms, luTxtLog, luDBFlog, llResult

lnParms = pcount()

* Determine if Parent object has a reference to a project files collection
this.alParentPjFiles = type('this.parent.aoPjFiles') == 'O' and not isNull(this.parent.aoPjFiles)

* Init/Open log files
luTxtLog = iif(m.lnParms>=1 and vartype(m.tuTxtLog) $ 'CL', m.tuTxtLog, .t.)
luDBFlog = iif(m.lnParms>=2 and vartype(m.tuDBFlog) $ 'CL', m.tuDBFlog, .t.)
llResult = this.init_Logs(m.luTxtLog, m.luDBFlog)
assert m.llResult message cAssertMsg(textmerge([Échec de la création des fichiers de compte-rendu]))

* Déterminer si une ligne de totaux / moyennes doit être produite en fin de log
this.alFooter = m.lnParms < 3 or lTrue(m.tlFooter)

* Déterminer si les sorties doivent être envoyées à l'écran
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
procedure init_Logs && Ouvre les fichiers de compte-rendu
lparameters ;
	tuTxtLog, ; && [.T.] Nom ou adresse du fichier de compte-rendu texte, .T. pour automatique
	tuDBFlog && [.T.] Nom ou adresse du fichier de la table de compte-rendu, .T. pour automatique

local lcLogAddr, lcResult, llResultTXT, llResultDBF

* Si une adresse de log peut être bâtie
lcLogAddr = this.cLogPathStem(m.tuTxtLog)
llResultTXT = !empty(m.lcLogAddr)
if m.llResultTXT

	* Ouvrir ou créer les fichiers de log
	this.acTxtLogAddr = lower(forceext(m.lcLogAddr, EXT_LOG))
	this.acWarnTxtLogAddr = lower(forceext(m.lcLogAddr , EXT_LOG_WARN))
	this.LogCheck(m.this.acTxtLogAddr)
	this.LogCheck(m.this.acWarnTxtLogAddr)

	lcResult = 'Starting log on '+ transform(datetime())
	lcResult = CRLF2 + m.lcResult + CRLF + replicate('=', len(m.lcResult))
	llResultTXT = strtofile(m.lcResult, this.acTxtLogAddr, .t.) > 0
	llResultTXT = strtofile(m.lcResult, this.acWarnTxtLogAddr, .t.) > 0 and m.llResultTXT
endif

* Open/Init table log
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
procedure destroy && Ferme les fichiers de log et rétablit la fenêtre VFP

* Faire le pied du tableau
this.FooterCreate()

* Close log table
use in select(this.acDBFlogAlias)

* Show windows hidden AT init()
show window all
show window all && parfois il reste des fenêtres invisibles

* Restore screen font
_screen.fontname = this.acScreenFont
_screen.fontsize = this.anScreenFontSize

if m.this.alConsole

	* Si l'utilisateur souhaite voir les avertissements
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

	 	* Copier les avertissements dans un fichier texte temporaire
	 	local lcFile, loSafety
	 	lcFile = forcepath(m.this.acWarnTxtLogAddr, sys(2023))
	 	loSafety = abSet('SAFETY', 'OFF')
	 	strtofile(m.this.acWarnings, m.lcFile)
	 	release loSafety

	 	* Afficher dans une fenêtre d'édition
	 	modify file (m.lcFile) nowait
	 	activate window (justfname(m.lcFile))
	endif
endif

* -------------------------------------------------
procedure LogCheck && Vérifie qu'un fichier de compte-rendu est accessible en écriture
lparameters tcLogAddr && Adresse du fichier de compte-rendu

if file(m.tcLogAddr)

	* Ajouter le fichier au projet
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
procedure cLogPathStem && Adresse d'un fichier de compte-rendu sans l'extension
lparameters tuLog && [.T.] Nom ou adresse du fichier de compte-rendu texte, .T. pour automatique

local lcSys16, lcResult

lcResult = space(0)
lcSys16 = sys(16,0)
if not empty(m.lcSys16)

	local lcLogPathAuto, lcLogStemAuto, lcLogPath, lcLogStem

	lcLogPathAuto = addbs(cModuleInfo(m.lcSys16, 'Path'))
	lcLogStemAuto = cModuleInfo(m.lcSys16, 'Name')
	store space(0) to m.lcLogPath, m.lcLogStem

	do case

	case vartype(m.tuLog) = 'C' and ! empty(m.tuLog)

		lcLogPath = addbs(justpath(m.tuLog))
		lcLogPath = iif(directory(m.lcLogPath), m.lcLogPath, m.lcLogPathAuto)

		lcLogStem = juststem(m.tuLog)
		lcLogStem = cFileName(m.lcLogStem)
		lcLogStem = iif(lFileName(m.lcLogStem), m.lcLogStem, m.lcLogStemAuto)

	case vartype(m.tuLog) = 'L' and m.tuLog
		lcLogPath = lcLogPathAuto
		lcLogStem = lcLogStemAuto

	endcase
	lcResult = addbs(m.lcLogPath) + m.lcLogStem
endif

return m.lcResult

* -------------------------------------------------
procedure ColAdd && Ajoute une colonne à la fin de la table de compte-rendu
lparameters ;
	tcHeader,; && [''] Contenu de l'en-tête de la colonne
	tnColWidth,; && [Header width || 10] Largeur de la colonne en foxels
	tlNoLeftBar,;	 && [.F.] Ne pas délimiter les colonnes par une barre verticale
	tcID,; && [tcHeader] Identifiant de la colonne
	tlSum,; && [.F.] Si la donnée est numérique, en fin d'état : .T.: Sommer, .F.: Moyenner, .NULL.: ne rien faire
	tcFormat && [''] Format pour Transform()

local lnResult && Numéro de la colonne ajoutée
lnResult = 0

if m.this.anLine = 0 && possible only if no line was displayed yet

 	lnResult = this.aColAdd()

 	local lcHeader, lnColWidth
 	lcHeader = uDefault(m.tcHeader, space(0))
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

	* Si affichage à l'écran (console)
	if m.this.alConsole

		* Calculer la largeur totale du tableau en caractères
		local lnCol, lnTableWidth
		lnTableWidth = 0
		for m.lnCol = 1 to m.lnResult
			lnTableWidth = m.lnTableWidth + this.aaLog[L_nWIDTH, m.lnCol] + iif(this.aaLog[L_lBORDER, m.lnCol], 1, 0)
		endfor
		lnTableWidth = m.lnTableWidth + 1 && right border

		* Tant que le tableau est plus large que l'écran, réduire la police de l'écran
		do while m.lnTableWidth * fontmetric(6, _screen.fontname, _screen.fontsize) > _screen.viewportwidth ;
				and _screen.fontsize > 5
			_screen.fontsize = _screen.fontsize - 1
		enddo
	endif
endif

this.anCols = m.lnResult

return m.lnResult

* -------------------------------------------------
procedure aColAdd && Ajoute une colonne au tableau de compte-rendu
local lnResult && Numéro de la colonne ajoutée
 	lnResult = alen(this.aaLog, 2)

if not vartype(this.aaLog[1]) = 'L' && La première colonne n'est plus disponible

 	local array laCopy[L_COUNT, m.lnResult]

 	acopy(this.aaLog, m.laCopy)
 		aColsIns(@m.laCopy)

 	lnResult = m.lnResult + 1
 		dimension this.aaLog[L_COUNT, m.lnResult]
 	acopy(m.laCopy, this.aaLog)
 	endif

 	return m.lnResult

* -------------------------------------------------
procedure nCol && Numéro de colonne d'après son identifiant
lparameters ;
	tcColID && Identifiant de la colonne
local lnResult && Numéro de la colonne
lnResult = 0

local llResult
llResult = vartype(m.tcColID) == 'C' and not empty(m.tcColID)
if m.llResult

	lnResult = ascan(this.aaLog, m.tcColID, 1, -1, -1, 1+2+4)
	lnResult = asubscript(this.aaLog, m.lnResult, 2)
endif

 	return m.lnResult

* -------------------------------------------------
procedure nColWidthTotal && Largeur totale d'un colonne du compte-rendu (avec gouttières)
lparameters tnCol && Numéro de colonne

local lnColWidth, lnResult

lnResult = 0

if vartype(m.tnCol) = 'N' ;
 and between(m.tnCol, 1, alen(this.aaLog, 2))

	lnColWidth = this.aaLog [L_nWIDTH, m.tnCol]
	lnResult = iif(vartype(m.lnColWidth) == 'N' and m.lnColWidth > 0;
			 , 1 + m.lnColWidth; && gouttière avant
			 , 0;
			 )
endif

return m.lnResult

* -------------------------------------------------
procedure CellFill && Remplit une cellule du compte-rendu
lparameters ;
	tuCol,; && Numéro ou ID de la colonne
	tuContent,; && [''] Contenu à placer dans la colonne
	tlExpand,; && [.F.] Si le contenu est plus large que la colonne, déborder sur les colonnes de droite
	tlNoDisplay,; && [.F.] Différer l'affichage de la ligne (pour gagner du temps lorsque plusieurs modifications successives de la ligne)
	tcFormat && [''] Format d'affichage

local lnCols, lcType, lnCol, llResult

* Si la définition de colonne est valide
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

	* Donner leur valeur par défaut aux paramètres optionnels
	luContent = iif(pcount() >= 2, m.tuContent, space(0))
 	llExpand = lTrue(m.tlExpand)
	llNoDisplay = lTrue(m.tlNoDisplay)
	lcFormat = iif(pcount() >= 5 and vartype(m.tcFormat) == 'C', m.tcFormat, space(0))
	lcFormat = evl(m.lcFormat, this.aaLog[L_cFORMAT, m.lnCol])

 		* Si la colonne a une largeur positive
 		lnColWidth = this.aaLog[L_nWIDTH, m.lnCol]
 		llResult = m.lnColWidth > 0
 	if m.llResult

 		* Charger la données originale dans la cellule
 		this.aaLog[L_uVALUE, m.lnCol] = m.luContent
 		this.aaLog[L_cTYPE, m.lnCol] = vartype(m.luContent)

 		* Si la donnée est numérique, cumuler
 		if this.aaLog[L_cTYPE, m.lnCol] == 'N'
 			this.aaLog[L_nSUM, m.lnCol] = this.aaLog[L_nSUM, m.lnCol] + m.luContent
 		endif

		* Si la colonne peut déborder
		lcContent = transform(m.luContent, m.lcFormat)
	 	if m.llExpand and m.lnCol < m.lnCols

	 		local lnColX, lnColWidthX
	 		lnColWidthX = m.lnColWidth
	 		for m.lnColX = m.lnCol + 1 to alen(this.aaLog, 2)
			 	lnColWidthX = m.lnColWidthX + this.nColWidthTotal(m.lnColX)
	 		endfor
	 		lnColWidth = min(len(m.lcContent), m.lnColWidthX)
	 	endif

 		* Charger l'affichage dans la cellule
 		this.aaLog[L_cDISPLAY, m.lnCol] = ;
 				this.cCellContent(m.tuContent, m.lnColWidth, m.llExpand, m.lcFormat)

		llResult = m.llNoDisplay or this.LineDisplay()
 	endif
endif

return m.llResult

* -------------------------------------------------
procedure cCellContent && Contenu d'une cellule du tableau de compte-rendu, ajusté à la taille de la cellule
lparameters ;
	tuContent,; && Contenu à placer dans la colonne
	tnColWidth,; && Largeur de la colonne en foxels
	tlExpand,; && [.F.] Si le contenu est plus large que la colonne, déborder sur les colonnes de droite
	tcFormat && [''] Format de présentation
tlExpand = lTrue(m.tlExpand)
tcFormat = evl(m.tcFormat, '')

 	local lcType, lcResult

 	lcType = vartype(m.tuContent)
 	if m.lcType $ 'CNYLDT'

 	lcResult = transform(m.tuContent, m.tcFormat)

 	* Manage position in column, trim if necessary
 	do case

 	case m.lcType $ 'NY'
		lcResult = iif(m.tlExpand;
			, this.cColJustified(m.lcResult, m.tnColWidth); && gauche
			, padl(m.lcResult, m.tnColWidth, space(1)); && Aligner à droite avec un Space(1)
			)

 	case m.lcType = 'L'
		lcResult = iif(m.tlExpand;
				, this.cColJustified(m.lcResult, m.tnColWidth); && à gauche
				, padl(m.lcResult, m.tnColWidth/2+2, space(1)); && centrer
				)

 	otherwise
		* Aligner à gauche en tentant de préserver les espaces en tête
		lcResult = this.cColJustified(m.lcResult, m.tnColWidth)
	endcase

	lcResult = padr(m.lcResult, m.tnColWidth, space(1))
else
 	lcResult = space(0)
endif

 	return m.lcResult

* -------------------------------------------------
function cColJustified && Justifie le contenu d'une cellule dans la largeur de la colonne
lparameters ;
	tcContent, ; && Contenu à placer dans la colonne
	tnColWidth && Largeur de la colonne en foxels

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
procedure LineFill && Écrit une nouvelle ligne à l'écran
lparameters tuContent

local lnResult && Position de la fin de ligne

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
procedure LineAppend && Ajoute un contenu à la ligne courante et affiche le résultat
lparameters ;
	tuContent, ; && Contenu à placer dans la colonne
	tnPosition && [fin de ligne] Position où le contenu est ajouté

local lnLine, lnResult && Position où le contenu a été ajouté

this.acLine = alltrim(this.acLine)
lnLine = len(this.acLine)
lnResult = iif(vartype(m.tnPosition)=='N', m.tnPosition, m.lnLine)
this.acLine = left(this.acLine, m.lnResult) + ;
							space(iif(empty(m.this.acLine), 0, 1)) + ;
							transform(m.tuContent)

* Compléter avec des espaces pour superposer la ligne précédente
if m.lnLine > len(this.acLine)
	this.acLine = padr(this.acLine, m.lnLine, space(1))
endif

if m.this.alConsole
	activate screen
	?? m.this.acLine at 0
endif

return m.lnResult

* -------------------------------------------------
procedure LineDisplay && Affiche le contenu de l'en-tête ou de la ligne courante
lparameters tlHeader && [.F.] Afficher l'en-tête du tableau
tlHeader = lTrue(m.tlHeader)

local lcLineOut, lnDisplayWidth;
, lnCol, lnColsWidth, lnColWidth;
, lcCellDisplay, llLeftBar, llResult


* Pour chaque colonne
lcLineOut = space(0)
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
		case m.lnDisplayWidth = m.lnColsWidth && start current column
			lcLineOut = m.lcLineOut + iif(m.llLeftBar, '|', space(1)) + m.lcCellDisplay
		case m.lnDisplayWidth >= m.lnColsWidth + m.lnColWidth && Beyond current column
		otherwise && inside current column
			lcLineOut = padr(m.lcLineOut, m.lnColsWidth + m.lnColWidth, space(1))
		endcase
		lnColsWidth = m.lnColsWidth + m.lnColWidth
		lnDisplayWidth = len(m.lcLineOut)
	else
		exit
	endif
endfor

if m.llResult
	this.acLine = m.lcLineOut + iif(m.llLeftBar, '|', space(0))
	this.lineShow(m.tlHeader)
endif

return m.llResult

* -------------------------------------------------
procedure lineShow && Affiche la ligne courante à l'écran
lparameters tlHeader && [.F.] Afficher l'en-tête

if m.this.alConsole

	activate screen
*!*			?? Space(0) AT 0 && bug de TEXT TO m.lcResult TEXTMERGE NOSHOW
	?? space(1) at 0 && bug de TEXT TO m.lcResult TEXTMERGE NOSHOW

	if lTrue(m.tlHeader)
		?
	endif
	?? m.this.acLine at 0
endif

* -------------------------------------------------
procedure LineFeed && Vide la ligne courante pour en commencer une nouvelle
lparameters ;
	tlSepLine, ; && [.F.] Tracer une ligne séparatrice après la nouvelle ligne
	tlDataLine && [.F.] La nouvelle ligne contient des données vivantes

local lcLine, llResult

* Update line count
if this.anCols > 0
	this.anLine = this.anLine + 1
	this.anDataLines = this.anDataLines + iif(lTrue(m.tlDataLine), 1, 0)
endif

* Flush and clear current line
llResult = this.LineFlush()
llResult = this.LineClear() and m.llResult

* Move to ENDFOR line, with separation line if required
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
procedure LineFlush && Sauve la ligne courante dans les fichiers de compte-rendu

local llResult
llResult = .t.

* Ajouter au log texte
if not empty(this.acTxtLogAddr) and not empty(this.acLine)
	llResult = strtofile(CRLF + this.acLine, this.acTxtLogAddr, .t.) > 0
endif

* Ajouter au log table
if not empty(this.acDBFlogAddr)
	llResult = used(this.acDBFlogAlias) or this.DBFlogCreate()
	if m.llResult
		llResult = this.DBFlogAppend()
	endif
endif

return m.llResult

* -------------------------------------------------
procedure LineClear && Efface la ligne courante

local lnCol, lnWidth
for m.lnCol = 1 to alen(this.aaLog, 2)
	lnWidth = this.aaLog[L_nWIDTH, m.lnCol]
	lnWidth = iif(vartype(m.lnWidth)=='N', m.lnWidth, 0)
	this.aaLog[L_cDISPLAY, m.lnCol] = space(m.lnWidth)
	this.aaLog[L_uVALUE, m.lnCol] = .null.
endfor

this.acLine = space(0)

* -------------------------------------------------
procedure Warning && Affiche un avertissement dans une fenêtre "WAIT WINDOW", ajoute au compte-rendu des avertissements si nouveau
lparameters ;
  tcWarning; && Avertissement, vide pour nouvelle ligne
, lAppendNot; && [.F.] Ne pas ajouter l'avertissement au compte-rendu
, lCallingAddNot as Boolean; && [.F.] {en} do not add calling program name as header {fr} ne pas ajouter le nom du programme appelant en-tête

local llWarnNew, lcWarning, lcCallingModule, llResult

* Si avertissement non vide
if .t.;
 and vartype(m.tcWarning) == 'C';
 and not empty(m.tcWarning)

	tcWarning = alltrim(m.tcWarning)

	* Si nouvel avertissement
	lcCallingModule = cTronc(lower(cCallingModule()), 20)
	lcWarning = Iif(lTrue(m.lCallingAddNot), '', padr(m.lcCallingModule, 20) ) + m.tcWarning
	llWarnNew = not upper(m.lcWarning) $ upper(m.this.acWarnings)
	if m.llWarnNew

	* Display warning
		wait window cTronc('Module ' + m.lcCallingModule + ' : ' + m.tcWarning, 254) nowait
	*			?? Chr(7)
	endif

else && blank line

	* Clear warning
	wait clear
	llWarnNew = .t.
	lcWarning = space(0)

endif

* If requested, Append Warning to Log
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
function cSepLine && Ligne séparatrice horizontale
lparameters tlLeftBars && [.F.] Tracer une barre verticale au début de la nouvelle ligne

local lnCol, lnColWidth, llLeftBar, lcResult

lcResult = space(0)
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

return iif(m.llResult, m.lcResult + iif(m.llLeftBar, '|', '-'), space(0))

* -------------------------------------------------
procedure DBFlogCreate && Crée la table de compte-rendu

local lcFields, lnCol;
, lcFieldName, lcFieldType, lnFieldLength, lcFieldExp;
, lnSelect, llResult

if m.this.anCols > 0

	lcFields = space(0)
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
procedure DBFlogAppend && Sauve la ligne courante du tableau dans la table de compte-rendu

local lnCols, llResult

lnCols = alen(this.aaLog, 2)
llResult = m.lnCols > 0 and used(this.acDBFlogAlias)
if m.llResult

	* Tabuler les champs de la table de log
	local array laFields[1]
	afields(laFields, this.acDBFlogAlias)

	* Pour chaque colonne
	local llAllEmpty, lnCol, lcFieldName, luFieldValue, lcFieldType, lnFieldLength, lcFieldExp, lnField, lcAlter
	llAllEmpty = .t.
	lcAlter = space(0)
	for lnCol = 1 to m.lnCols

		* Déterminer les caractéristiques du champ pouvant contenir la donnée
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

			* Si le champ n'existe pas
			if m.lnField = 0

				lcAlter = lcAlter + ' ADD COLUMN ' + m.lcFieldExp

			* Sinon (le champ existe)
			else

				* Si le champ n'est pas de le bonne taille ou type
				if not m.lcFieldType $ VFP7_FIELD_TYPES_FIXED_LEN ;
				 and laFields[m.lnField, 3] < m.lnFieldLength ;
				 or not laFields[m.lnField, 2] == m.lcFieldType

					lcAlter = lcAlter + ' ALTER COLUMN ' + m.lcFieldExp
				endif
			endif

			llAllEmpty = m.llAllEmpty and (empty(m.luFieldValue) or isNull(m.luFieldValue))
		endif

		local (m.lcFieldName)
		store m.luFieldValue to (m.lcFieldName) && pour GATHER MEMVAR plus loin
	endfor

	* S'il faut changer la structure de la table
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
procedure FooterCreate && Crée un pied de tableau avec totaux ou moyennes

* En cas d'interruption anormale, vider la ligne en cours
if not empty(m.this.acLine)
	this.LineFeed
endif

* Si au moins une ligne de données
if m.this.anCols * m.this.anDataLines > 0

	* Tracer une ligne pour fermer le tableau
	this.acLine = this.cSepLine()
	this.lineShow()

	* Si un pied de tableau a été demandé
	if m.this.alFooter
		this.LineFeed()

		local lnCol, lnSum, luSum, llFooter, llTitle

		* Pour chaque colonne
		for m.lnCol = 1 to this.anCols
			lnSum = this.aaLog[L_nSUM, m.lnCol]
			luSum = this.aaLog[L_lSUM, m.lnCol]

			* Si la colonne contient un total et qu'un bilan est demandé
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

		* Si le pied d'état a été créé, le sortir
		if m.llFooter
			this.LineFeed(.t.)
		endif
	endif
endif

* -------------------
enddefine && CLASS cusBatchLog as Custom

* -----------------------------------------------------
procedure cusBatchLog_Test
local lcSys16
lcSys16 = sys(16,0)
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
function cModuleInfo && Nom, Chemin ou Adresse d'un module d'après Sys(16)
lparameters ;
	tcSys16,; && Chaîne obtenue par Sys(16)
	tcInfo,; && ['N'] {N}ame, {A}ddress, {P}ath, {O}bject, {S}ys16, {L}ignée, {F}ull lignée
	tlCase && [.F.] Respecter la casse sur disque

tcInfo = iif(vartype(m.tcInfo) = 'C' and not empty(m.tcInfo), upper(left(ltrim(m.tcInfo), 1)), 'N')
tcInfo = iif(m.tcInfo $ 'NAPSOLF', m.tcInfo, 'N')
tlCase = lTrue(m.tlCase)

local llProc, lcAddr, lcProc, laMembers[1], lnMembers, llMethod;
, llResult, lcResult

lcResult = space(0)

* Si le paramètre requis est valide
llResult = vartype(m.tcSys16) = 'C'
assert m.llResult message cAssertMsg(textmerge([Invalid Sys(16) Information : <<cLitteral(m.tcSys16)>>]))
if m.llResult and not upper(left(m.tcSys16, 2)) == 'ON' && ON ...

 	* Repérer le nom de la procédure et l'adresse du fichier dans la chaine sys(16)
 	llProc = left(upper(m.tcSys16), lenc('PROCEDURE ')) == 'PROCEDURE '
 	lcAddr = iif(m.llProc;
 		, substr(m.tcSys16, atc(' ', m.tcSys16, 2) + 1); && GetWordNum() ne fonctionne pas si l'adresse contient des espaces
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
	 		m.tcInfo == 'N',; && Procedure name (with object name if method)
		 		iif(m.llMethod;
		 			, laMembers[m.lnMembers-1] + iif(empty(laMembers[m.lnMembers-1]) or empty(laMembers[m.lnMembers]), '', '.') + laMembers[m.lnMembers];
		 			, m.lcProc;
		 			),;
		 	m.tcInfo == 'A',; && Procedure file address
		 		m.lcAddr,;
		 	m.tcInfo == 'P',; && Procedure file path
		 		addbs(justpath(m.lcAddr)),;
		 	m.tcInfo == 'S',; && Procedure file address
		 		m.tcSys16,;
		 	m.tcInfo == 'O',; && Object name
		 		laMembers[m.lnMembers-1],;
		 	m.tcInfo == 'L',; && Lignée des objets
		 		leftc(m.lcProc, ratc('.', m.lcProc)-1),;
		 	m.tcInfo == 'F',; && Lignée complète de la méthode
		 		m.lcProc,;
		 		'';
		 	)
 	endif
endif

return m.lcResult

* ------------------------------------
procedure cModuleInfo_Test && Test cModuleInfo()
&& cf 'cModuleInfo_Test.prg' pour test par programme

local loUnitTest as abUnitTest of abDev.prg, lcSys16, loClassTest
loUnitTest = newobject('abUnitTest', 'abDev.prg')
lcSys16 = sys(16) && module courant

loUnitTest.Test('CMODULEINFO_TEST', m.lcSys16, 'Name')
loUnitTest.Test(upper(DOS_AB), m.lcSys16, 'Path')
loUnitTest.Test(upper(DOS_AB) + 'ABDEV.FXP', m.lcSys16, 'Address')

loClassTest = createobject('cusModuleInfo_Test', m.loUnitTest)

return loUnitTest.result()

* --------------------------------------
define class cusModuleInfo_Test as custom && Teste cModuleInfo() au sein d'une classe
		procedure init
		lparameters toUnitTest
		local lcSys16
		lcSys16 = sys(16) && module courant
		toUnitTest.Test('CUSMODULEINFO_TEST.INIT', m.lcSys16, 'Name')
		toUnitTest.Test(upper(DOS_AB), m.lcSys16, 'Path')
		toUnitTest.Test(upper(DOS_AB) + 'ABDEV.FXP', m.lcSys16, 'Address')
	enddefine

* ========================================
function cCallingModule && Nom du module appelant (programme, procédure, méthode, ...)
lparameters ;
	tcAddress,; && [''] @ Adresse du fichier où se trouve le module appelant
	tnStackUp && [0] nombre de niveaux avant le module appelant

local lnLevelHere, lcSys16, lcResult

lcResult = space(0)

* Si ce module est appelé par un module appelé
lnLevelHere = program(-1) && current program level
if m.lnLevelHere > 2

	lcSys16 = sys(16, m.lnLevelHere - 2 - abs(evl(m.tnStackUp, 0)))

	tcAddress = cModuleInfo(m.lcSys16, 'Address')
	lcResult = cModuleInfo(m.lcSys16, 'Name')
endif

return m.lcResult

* ------------------------------------
procedure cCallingModule_Test

local loUnitTest as abUnitTest of abDev.prg
loUnitTest = newobject('abUnitTest', 'abDev.prg')

local lcSys16, lcSys16module, lcSys16address;
, lcModule, lcAddress;
, loTest as cCallingModule_Test3 of abDev.prg;

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
function cCallingModules && Modules appelants
lparameters ;
	tlCurrent,; && [.F.] Inclure le nom du module courant
	tcInfo && [Name] 'Name', 'Address', 'Path', 'Object' ou 'Lignée'

tlCurrent = lTrue(m.tlCurrent)

local lnLevelHere, lnLevel, lcResult
lcResult = space(0)

* Si cCallingModules est appelé par un module appelé
lnLevelHere = program(-1) && current program level
if m.lnLevelHere > iif(m.tlCurrent, 1, 2)

	for m.lnLevel = 1 to m.lnLevelHere - iif(m.tlCurrent, 1, 2)
		lcResult = c2Words(m.lcResult, ' > ', textmerge("<<m.lnLevel>>.<<Chr(160)>><<cModuleInfo(Sys(16, m.lnLevel), m.tcInfo)>>"))
	endfor
endif

return lower(m.lcResult)

* ========================================
function lCallingModule && Un module appelle le module appelant cette fonction
lparameters ;
	tcModule,; && Module: [class][.]procedure
	tlModules && [.F.] && appel depuis lCallingModules()

local llResult as Boolean;
, liLevelBase as integer;
, liLevelHere as integer;
, liLevel as integer;
, lcLevel as string;
, llMethod as Boolean;
, llClassMethod as Boolean;

if vartype(m.tcModule) == 'C' and not empty(m.tcModule)

	* Si ce module est appelé par un module appelé
	liLevelHere = program(-1) && current program level
	liLevelBase = 2 + iif(lTrue(m.tlModules), 1, 0)
	if m.liLevelHere > m.liLevelBase

		tcModule = upper(alltrim(m.tcModule))
		llMethod = leftc(m.tcModule, 1) == '.'
		llClassMethod = !m.llMethod and '.' $ m.tcModule

		for m.liLevel = m.liLevelHere - m.liLevelBase to 1 step -1
			lcLevel = program(m.liLevel)

			if m.tcModule == icase(;
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
function lCallingModules && Plusieurs modules appellent le module appelant cette fonction
lparameters ;
	tcModules,; && Modules
	tlOR && [.F.] Au moins un module appelle le module
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
function lUserEventCalling && Un événement utilisateur appelle cette fonction
lparameters tcClassStart && Classe à partir de laquelle chercher dans la pile d'appel si elle s'y trouve

local success as Boolean;
, laStack[1] as string;
, lnStack as integer;
, liStack as integer;
, lClassStart as Boolean;
, lcEvent as string;
, liEvent as integer;

lnStack = astackinfo(m.laStack)
if m.lnStack > 0 && should always be .T.

	tcClassStart = lower(evl(m.tcClassStart, ''))
	lClassStart = !empty(m.tcClassStart)
	for liStack = m.lnStack to 1 step -1
		if m.lClassStart and lower(getwordnum(laStack[m.liStack, 3], 1, '.')) == m.tcClassStart
*				liStack = Aelement(m.laStack, m.liStack, 3)
			exit
		endif
		laStack[m.liStack, 3] = getwordnum(laStack[m.liStack, 3], getwordcount(laStack[m.liStack, 3], '.'), '.') && Module or Object name
	endfor
	liStack = evl(m.liStack, 1)
	text to lcEvent noshow flags 1 pretext 3 && could be rearranged for optimization (most frequent events first)
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
procedure lUserEventCalling_Test && Teste lUserEventCalling()

local loUnitTest as abUnitTest of abDev.prg
loUnitTest = newobject('abUnitTest', 'abDev.prg')

loUnitTest.Test(.f.)
loUnitTest.Test(.f., 'abUnitTest')

return m.loUnitTest.result()

* ========================================
function uDefault && Valeur par défaut d'un paramètre /!\ .T. non supporté
lparameters ;
	tuParm,; && Paramètre dont il faut régler la valeur par défaut
	tuDefault && Valeur par défaut /!\ .T. non supporté

local lcType, luResult
luResult = .null.

* Si deux paramètres ont été passés
if pcount() = 2

	* Si la valeur par défaut est supportée
	lcType = vartype(m.tuDefault)
	if not (m.lcType == 'L' and m.tuDefault)

		* Si le paramètre est du type de la valeur par défaut, le retourner, sinon retourner la valeur par défaut
		luResult = iif(vartype(m.tuParm) == m.lcType, m.tuParm, m.tuDefault)
	else
		assert .f. message cAssertMsg(textmerge([<<Proper(Program())>> ne supporte pas la valeur par défaut .T. comme second paramètre]))
	endif
endif

return m.luResult

* ------------------------------------
procedure uDefault_Test && Teste uDefault()

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
define class abMachineInfo as GA_LIGHTWEIGHT_CLASS of abGA.prg && Informations sur la machine : processeur, mémoire, etc.

* Système
nOEMid = 0
nPageSize = 0
nAppAddrMin = 0
nAppAddrMax = 0
nProcessorMask = 0
nProcessors = 0
nProcessorType = 0
cProcessorName = space(0)
nAllocationGranularity = 0
nReserved = 0

* Mémoire
nMemLoad = 0
nMemPhysTot = 0
nMemPhysAvail = 0
nPageFileTot = 0
nPageFileAvail = 0
nMemVirtualTot = 0
nMemVirtualAvail = 0

* Processeur
nAddressWidth = 0
nArchitecture = 0
nAvailability = 0
nCpuStatus = 0
nCurrentClockSpeed = 0
nDataWidth = 0
cDescription = space(0)
cDeviceID = space(0)
nExtClock = 0
nFamily = 0
nL2CacheSize = 0
nL2CacheSpeed = 0
nLevel = 0
nLoadPercentage = 0
cManufacturer = space(0)
nMaxClockSpeed = 0
cProcessorFullName = space(0)
cPNPDeviceID = space(0)
cProcessorID = space(0)
nProcessorType = 0
nRevision = 0
cRole = space(0)
cSocketDesignation = space(0)
nStatusInfo = 0
cStepping = space(0)
cUniqueId = space(0)
nUpgradeMethod = 0
cVersion = space(0)
nVoltageCaps = 0

* ------------------------------------
procedure SystemInfo && Peuple les informations système

 declare GetSystemInfo in win32api string @lcSystemInfo
 local lcSysInfo
 m.lcSysInfo = space(36)
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

* ------------------------------------
procedure MemoryInfo && Peuple les informations mémoire

 declare GlobalMemoryStatus in win32api string @lcMemStat
 local lcMemStat
 m.lcMemStat = LongToStr(32) + replicate(chr(0), 28)
 GlobalMemoryStatus(@m.lcMemStat)

 this.nMemLoad = StrToLong(substr(m.lcMemStat, 5, 4))
 this.nMemPhysTot = StrToLong(substr(m.lcMemStat, 9, 4))
 this.nMemPhysAvail = StrToLong(substr(m.lcMemStat, 13, 4))
 this.nPageFileTot = StrToLong(substr(m.lcMemStat, 17, 4))
 this.nPageFileAvail = StrToLong(substr(m.lcMemStat, 21, 4))
 this.nMemVirtualTot = StrToLong(substr(m.lcMemStat, 25, 4))
 this.nMemVirtualAvail = StrToLong(substr(m.lcMemStat, 29, 4))

* ------------------------------------
procedure ProcessorInfo && Peuple les informations sur le processeur

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

enddefine && CLASS abMachineInfo

* ==================================
procedure abMachineInfo_Test && Teste abMachineInfo

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
 function LongToStr && Représentation ASCII d'un entier 32 bits positif
 lparameters tnLongVal && Entier 32 bits positif

 local i, lnLongVal, lcResult

 lcResult = space(0)
 lnLongVal = m.tnLongVal
 for i = 24 to 0 step -8
    lcResult = chr(int(m.lnLongVal/(2^m.i))) + m.lcResult
    lnLongVal = mod(m.lnLongVal, (2^m.i))
 endfor

 return lcResult

* ------------------------------------
function StrToLong && Entier 32 bits positif d'après sa représentation ASCII
lparameters tcLongStr && Représentation ASCII d'un entier 32 bits positif

local i, lcLongStr, lnResult
lnResult = 0
lcLongStr = m.tcLongStr
for i = 0 to 24 step 8
   lnResult = m.lnResult + (asc(m.lcLongStr) * (2^m.i))
   lcLongStr = right(m.lcLongStr, len(m.lcLongStr) - 1)
endfor

return lnResult

* ------------------------------------
function cBarsSecs && Une barre pour 50 ms
lparameters tnSeconds && Nombre de secondes obtenu par différence de seconds()

if vartype(m.tnSeconds) == 'N' and m.tnSeconds >= 0
 	tnSeconds = m.tnSeconds * 1000 && ms

 	local lcBars
 	lcBars = replicate('=', min(int(m.tnSeconds / 50), 100)) && 1 barre = 50 ms, 5 secs max
 	return m.lcBars;
 		+ space(iif(empty(m.lcBars), 0, 1));
 		+ iif(m.tnSeconds = 0, '< 1', ltrim(transform(m.tnSeconds, '99 999')));
 		+ " ms"
else

	return space(0)
endif

* ------------------------------------
procedure ProjectFilesInclude && Change l'inclusion de fichiers dans le projet courant
lparameters ;
	tcFileMask,; && [*.*] Expression régulière indiquant le masque de fichier à traiter
	tlInclude,; && [.T.] .T.: Inclure, .F.: Exclure, .NULL. : Inverser
	tnResult && @ Nombre de fichiers traités
tnResult = 0

local loProject, loProjectFiles, loRegExp as abRegExp of abTxt.prg, llResult

* Si un projet est actif
loProject = _vfp.activeproject
llResult = vartype(m.loProject) == 'O'
if m.llResult

	* Si le projet contient des fichiers
	loProjectFiles = m.loProject.files
	llResult = m.loProjectFiles.count > 0
	if m.llResult

		* Créer un objet 'Regular Expression'
		loRegExp = createobject('abRegExp')
		llResult = vartype(m.loRegExp) == 'O'
		if m.llResult

			* Donner leur valeur par défaut aux paramètres
			local lcCarsNot, lcFileMask, llInclude, loFile as file
			lcCarsNot = CAR_INT_DS_NOM_FICH
			lcFileMask = alltrim(uDefault(m.tcFileMask, textmerge('[^<<m.lcCarsNot>>]+\.[^<<m.lcCarsNot>>]+')))
			llInclude = iif(pcount() >=2 and vartype(m.tlInclude) $ 'LX', m.tlInclude, .t.)

			* Pour chaque fichier
			loRegExp.setup(m.lcFileMask, .t.)
			for each loFile in m.loProjectFiles

				* Si le nom du fichier correspond au masque
				if loRegExp.Test(justfname(m.loFile.name))

					* Changer son inclusion
					loFile.Exclude = iif(isNull(m.llInclude), not m.loFile.Exclude, m.llInclude)
					tnResult = m.tnResult + 1
				endif
			endfor
		endif
	endif
endif

return m.llResult

* ------------------------------------
procedure ProjectFilesRemove && Ôte des fichiers du projet courant
lparameters ;
	tcFileMask,; && [*.*] Expression régulière indiquant le masque de fichier à traiter
	tnResult && @ Nombre de fichiers traités
tnResult = 0

local loProject, loProjectFiles, loRegExp as abRegExp of abTxt.prg, llResult

* Si un projet est actif
loProject = _vfp.activeproject
llResult = vartype(m.loProject) == 'O'
if m.llResult

	* Si le projet contient des fichiers
	loProjectFiles = m.loProject.files
	llResult = m.loProjectFiles.count > 0
	if m.llResult

		* Créer un objet 'Regular Expression'
		loRegExp = createobject('abRegExp')
		llResult = vartype(m.loRegExp) == 'O'
		if m.llResult

			* Donner leur valeur par défaut aux paramètres
			local lcCarsNot, lcFileMask, llInclude, loFile as file
			lcCarsNot = CAR_INT_DS_NOM_FICH
			lcFileMask = alltrim(uDefault(m.tcFileMask, textmerge('[^<<m.lcCarsNot>>]+\.[^<<m.lcCarsNot>>]+')))
			llInclude = iif(pcount() >=2 and vartype(m.tlInclude) $ 'LX', m.tlInclude, .t.)

			* Pour chaque fichier
			loRegExp.setup(m.lcFileMask, .t.)
			for each loFile in m.loProjectFiles

				* Si le nom du fichier correspond au masque
				if loRegExp.Test(justfname(m.loFile.name))

					* öter le fichier
					loFile.remove
					tnResult = m.tnResult + 1
				endif
			endfor
		endif
	endif
endif

return m.llResult


*========================================
function cVFPname	&& Nom valide pour VFP, avec longueur limitée si nécessaire
lparameters ;
	tcVFPname, ; && Nom VFP à valider
	tnLength && [len(tcVFPname)] Longueur maximale du nom (par ex. 10 pour un nom de champ de table libre)
local lcResult
lcResult = space(0)

if vartype(m.tcVFPname) = 'C' ;
 and not empty(m.tcVFPname)

	* Remove accents
	local lcVFPname
	lcVFPname = cEuroANSI(alltrim(m.tcVFPname))

	* Start with '_' if first is a digit
	lcVFPname = iif(isdigit(m.lcVFPname), '_', space(0)) + m.lcVFPname

	* Turn characters neither digit or letter to '_'
	local lnCar, lcCar
	for m.lnCar = 1 to len(m.lcVFPname)
		lcCar = substrc(m.lcVFPname, m.lnCar, 1)
		lcCar = iif(isdigit(m.lcCar) or isalpha(m.lcCar), m.lcCar, '_')
		lcResult = m.lcResult + upper(m.lcCar)
	endfor

	* Remove duplicate underscores
	lcResult = cRepCharDel(m.lcResult, '_')
	lcResult = iif(m.lcResult == '_', space(0), m.lcResult)

	* Trim right is required
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
function lVFPname	&& Nom valide pour VFP
lparameters tcVFPname && @ Nom VFP à valider

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
function lProcLine && Ligne de code VFP définissant une procédure / fonction
lparameters tcCodeLine && Ligne de code VFP

local lcCodeLine, lcWord1, lcWord2, llResult

llResult = vartype(m.tcCodeLine) == 'C'
assert m.llResult message cAssertMsg(textmerge([Invalid parameter type]))
if m.llResult

	lcCodeLine = upper(m.tcCodeLine)
	lcWord1 = left(getwordnum(m.lcCodeLine, 1), 4)
	lcWord2 = left(getwordnum(m.lcCodeLine, 2), 4)

	llResult = m.lcWord1 $ 'PROC,FUNC' ;
				or m.lcWord1 $ 'PROT,HIDD' and m.lcWord2 $ 'PROC,FUNC'
endif

return m.llResult

* ====================
function cProcType && Type de procédure / fonction défini dans une ligne
lparameters tcCodeLine && Ligne de code VFP

local lcCodeLine, lnProc, lnFunc, llParm, lcResult && 'P' ou 'F' ou vide si impossible de le définir

lcResult = space(0)
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
function lCommandLine && Ligne de code VFP contenant une commande
lparameters tcCodeLine && Ligne de code VFP

local llResult

llResult = vartype(m.tcCodeLine) == 'C'
assert m.llResult message cAssertMsg(textmerge([Invalid parameter type]))
if m.llResult

	llResult = ;
			not lCommentLine(m.tcCodeLine) ;
		and not left(getwordnum(m.tcCodeLine, 1), 1) == '#' && directive de compilation
endif

return m.llResult

* ====================
function lCommentLine && Ligne de commentaire VFP
lparameters tcCodeLine && Ligne de code VFP
local llResult && c'est une ligne de commentaire

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
function lSeparatorLine && Ligne de commentaire de séparation
lparameters tcCodeLine && Ligne de code VFP
local llResult && c'est une ligne de séparation

* Si le paramètre est correct
llResult = vartype(m.tcCodeLine) == 'C'
assert m.llResult message cAssertMsg(textmerge([Invalid parameter type]))
if m.llResult

	* si c'est une ligne de commentaire
	llResult = lCommentLine(m.tcCodeLine)
	if m.llResult

		* Si la ligne n'est pas vide
		llResult = empty(m.tcCodeLine)
		if not m.llResult

			* Si la ligne ne comporte aucune lettre ou chiffre
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
function cLineComment && Commentaire dans une ligne de code
lparameters tcCodeLine && Ligne de code ; si @, retournée sans commentaire ni espaces

local lcResult; && Commentaire dans la ligne de code
, llResult;
, lnAt, lnAt1;

lcResult = space(0)

* Si la ligne de code est valide
tcCodeLine = cCodeLineClean(m.tcCodeLine) && Ligne de code sans caractères parasites
llResult = not isNull(m.tcCodeLine)
assert m.llResult message cAssertMsg(textmerge([Line de code invalide : <<m.tcCodeLine>>]))
if m.llResult

	* Si la ligne comporte un commentaire
	lnAt = at_c('*', m.tcCodeLine)
	if m.lnAt > 0
		lnAt1 = m.lnAt + 1
	else
		lnAt = at_c(replicate('&', 2), m.tcCodeLine)
		if m.lnAt > 0
			lnAt1 = m.lnAt + 2
		endif
	endif
	if m.lnAt > 0

		* Extraire le commentaire et le supprimer
		lcResult = m.tcCodeLine
		lcResult = alltrim(substrc(m.lcResult, m.lnAt1))
		lcResult = upper(substrc(m.lcResult, 1, 1)) + substrc(m.lcResult, 2) && capitalise le premier caractère
		tcCodeLine = substrc(m.tcCodeLine, 1, m.lnAt - 1) && Ligne sans le commentaire
	endif
endif

return m.lcResult

* --------------------
procedure cLineComment_Test && Teste cLineComment

local loUnitTest as abUnitTest of abDev.prg
loUnitTest = newobject('abUnitTest', 'abDev.prg')

local lcLine
lcLine = '      Procedure test ' + replicate('&', 2) + '   test réussi'
loUnitTest.Test('Test réussi', m.lcLine)

lcLine = '* Procedure test ' + replicate('&', 2) + '   test réussi'
loUnitTest.Test('Procedure test ' + replicate('&', 2) + ' test réussi', m.lcLine)

return loUnitTest.result()

* ====================
function cCodeLineClean && Ligne de code sans caractères parasites
lparameters tcCodeLine && Ligne de code

local llResult

llResult = vartype(m.tcCodeLine)=='C'
assert m.llResult message cAssertMsg(textmerge([Function argument type is invalid : <<m.tcCodeLine>>]))
if m.llResult

	return	cRepCharDel(; && supprime les espaces répétés
						chrtran(ltrim(m.tcCodeLine), chr(9), space(1)); && remplace les tabs par des espaces
					)
else
	return .null.
endif

* ====================
function cCommentStripped && Code sans commentaires
lparameters ;
	tcInsts; && Instructions
, tlInLineCommentKeep

local laInst[1], lcInst, lcInst_, llCRLF;
, llResult, lcResult

lcResult = space(0)

llResult = vartype(m.tcInsts) == 'C'
assert m.llResult message cAssertMsg(textmerge([Invalid code block: <<m.tcInsts>>]))
if m.llResult

	if alines(laInst, m.tcInsts) > 0 && garder les espaces en début et fin de ligne

		llCRLF = rightc(m.tcInsts, 2) == CRLF
		for each lcInst in m.laInst

			lcInst_ = ltrim(m.lcInst, space(1), chr(9))
			lcResult = m.lcResult + iif(left(m.lcInst_, 1) == '*' or left(m.lcInst_, 2) == '&'+'&' or upper(left(m.lcInst_, 5)) == 'NOTE ';
				, space(0);
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
function cInLineCommentStripped && Instructions sans commentaire de ligne
lparameters ;
	tcInsts as string,; && Instructions
	tcComment as string && @ Commentaires trouvés

tcComment = ''

local lcResult;
, llResult;
, liComment;
, liCR

lcResult = ''

* Si code valide
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
procedure cInLineCommentStripped_Test && Teste cInLineCommentStripped()

local loUnitTest as abUnitTest of abDev.prg, lcCode, lcComment, lcExpected

loUnitTest = newobject('abUnitTest', 'abDev.prg')

lcCode = [Moved &] + [& Occurs when an object is moved to a new position or a container object's Top or Left property settings have been changed programmatically]
loUnitTest.Test('Moved', m.lcCode, @m.lcComment)
loUnitTest.assert([&] + [& Occurs when an object is moved to a new position or a container object's Top or Left property settings have been changed programmatically], m.lcComment)

text TO lcCode NOSHOW FLAGS 1 PRETEXT 3
	MouseWheel && Occurs ...
	Moved && Occurs when an object is moved to a new position or a container object's Top or Left property settings have been changed programmatically
	OLECompleteDrag && Occurs ...
ENDTEXT

text TO lcExpected NOSHOW FLAGS 1 PRETEXT 3
	MouseWheel
	Moved
	OLECompleteDrag
ENDTEXT

loUnitTest.Test(m.lcExpected, m.lcCode)

return loUnitTest.result()

* ====================
function aInLineCommentsStripped && Lignes de code sans commentaires de ligne
lparameters taCodeLines && @ Lignes de code
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
function abON as abON of abDev.prg && Saves and restores ON ...
lparameters ;
	tcSetting,; && ON ... to be set
	tvValueNew && Value to set

return createobject('abON', m.tcSetting, m.tvValueNew)

* =================================================
define class abON as GA_LIGHTWEIGHT_CLASS of abGA.prg && Saves and restores ON ...
* =================================================

cSetting = space(0)
vValueOld = .null.

* ------------------------------------
procedure init
lparameters ;
	tcSetting,; && ON ... to be set
	tvValueNew && Value to set

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
enddefine && CLASS abOn
* =================================================

* =================================================
function labSet as Boolean
lparameters ;
	toObj as abSet of abDev.prg,; && @ abSet Object back
	tcSetting,; && Setting to perform
	tvValueNew,; && Value to set, .T. to toggle ON - OFF
	tnSetting,; && Setting number when appropriate for tcSetting, as of 2nd parameter of set()
	tlChangeAlways,; && [.F.] Change setting even if required value is current
	tlSupported && [.F.] assume setting is supported (optimization)

toObj = abSet(m.tcSetting, m.tvValueNew, m.tnSetting, m.tlChangeAlways, m.tlSupported)

return vartype(m.toObj) == 'O'

* =================================================
function abSet as abSet of abDev.prg
lparameters ;
	tcSetting,; && Setting to perform
	tvValueNew,; && Value to set, .T. to toggle ON - OFF
	tnSetting,; && Setting number when appropriate for tcSetting, as of 2nd parameter of set()
	tlChangeAlways,; && [.F.] Change setting even if required value is current
	tlSupported && [.F.] assume setting is supported (optimization)

return createobject('abSet', m.tcSetting, m.tvValueNew, m.tnSetting, m.tlChangeAlways, m.tlSupported)

* =================================================
define class abSet as GA_LIGHTWEIGHT_CLASS of abGA.prg && Saves and restores SET ...
* =================================================

cSetting  = ''
cParm2    = ''
nSetting  = .null.
vValueOld = .null.
vValueNew = .null.
lOnOff = .f.

* ------------------------------------
protected procedure init && If valid and supported, performs required environment setting
lparameters ;
	tcSetting,; && Setting to perform
	tvValueNew,; && Value to set, .T. to toggle ON <> OFF
	tnSetting,; && Setting number when appropriate for tcSetting, as of 2nd parameter of set(), eg Set("Alternate", 1) for FileName
	tlChangeAlways,; && [.F.] Change setting even if required value is current
	tlSupported && [.F.] assume setting is supported (optimization)

local success as Boolean;
, lnSetting;
, lvValueCur;
, lcTypeCur;
, lcTypeNew;
, llToggle

lnSetting = vartype(m.tnSetting) == 'N'

* If parameters are valid
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

		* If setting is OK
		success = .t.;
			and (.f.;
				or lTrue(m.tlSupported);
				or vartype(m.tvValueNew) == 'C' and inlist(upper(alltrim(m.tvValueNew)), 'ON', 'OFF');
				or this.lSupported(m.tcSetting, m.this.cParm2); && supported
				);
			and this.get(@m.lvValueCur, m.tcSetting, m.this.cParm2) && current value can be read
		if m.success

			* If required value is valid
			lcTypeCur = vartype(m.lvValueCur)
			lcTypeNew = vartype(m.tvValueNew)
			llToggle = m.lcTypeNew == 'L' and m.tvValueNew
			success = m.llToggle or m.lcTypeNew == m.lcTypeCur
			assert m.success message cAssertMsg(textmerge([For setting '<<m.tcSetting>>', value <<cLitteral(m.tvValueNew)>> should be of type '<<m.lcTypeCur>>']))
			if m.success

				* Adjust value when appropriate
				tvValueNew = iif(m.tcSetting == 'DEFAULT', addbs(fullpath(m.tvValueNew)), m.tvValueNew)

				* If setting must be changed
				if .f.;
				 or m.llToggle;
				 or lTrue(m.tlChangeAlways);
				 or !luEqual(m.lvValueCur, m.tvValueNew,, .t.)

					this.lOnOff = m.lcTypeCur == 'C' and (m.lvValueCur == 'ON' or m.lvValueCur == 'OFF')

					* Toggle value if asked and appropriate
					if m.llToggle and m.this.lOnOff
						tvValueNew = iif(m.lvValueCur = 'ON', 'OFF', 'ON')
					endif

					* If new setting can be performed
					success = this.set(m.tcSetting, m.tvValueNew)
				endif
				if m.success

					* Persist current values to properties
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
hidden function get && état courant d'un SET
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
function set && Saves current environment setting and changes to new value
&& public car appelé par awSets.Set()
lparameters ;
	tcSetting,; && Setting to work on - upper case, trimmed
	tvValueNew && Value to set

local llResult as Boolean;
, lcSetting as string

llResult = .t.
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
		)

endcase

assert m.llResult message cAssertMsg(textmerge([Unable to do the following setting : SET <<m.tcSetting>> <<m.tvValueNew>>]))

this.vValueNew = iif(m.llResult, m.tvValueNew, .null.)

return m.llResult

* ------------------------------------
hidden function Set_ && Changes setting to new value
lparameters ;
	tcSetting,; && Setting to work on
	tvValueNew && Value to set

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

return m.llResult

* ------------------------------------
hidden function lSupported && Requested environment setting is supported
lparameters ;
	tcSetting,; && Setting to work on
	lcParm2 && Second parameter of set()

tcSetting = upper(alltrim(m.tcSetting))
lcParm2 = alltrim(m.lcParm2, ' ', ',')

local llResult as Boolean;
, lcUnsupported;
, lcUntested;
, laResult[1];
, lnResult;
, liResult;
, loResult as exception

&&	Reprocess && strange options

lcUnsupported = ''; && 2015-11-04 thn TEXT ... ENDTEXT removed (should have been done much earlier)
+ [Century, , 3] + CRLF;
+ [Clock, , 1] + CRLF; && does not restore properly
+ [Color] + CRLF; && Included for backward compatibility
+ [Date, , 1] + CRLF;
+ [Echo] + CRLF; && Included for backward compatibility
+ [Fields, , 1] + CRLF;
+ [Order] + CRLF; && unable to restore
+ [Printer, , 2] + CRLF;
+ [Printer, , 3] + CRLF;
+ [Skip] + CRLF;
+ [Status Bar] + CRLF; && Problem with space between 'Status' and 'Bar' ...
+ [Topic, .T., 1] + CRLF; && unable to restore
+ [View] + CRLF; && unable to restore


lcUntested  = ''; && Untested sets && 2015-11-04 thn TEXT ... ENDTEXT removed (should have been done much earlier)
+ [Help, , 1] + CRLF;
+ [Help, , 2] + CRLF;
+ [Help, , 3] + CRLF;
+ [Key, , 1] + CRLF;
+ [Key, , 2] + CRLF;
+ [Textmerge, , 4] + CRLF;
+ [Topic, , 1] + CRLF;
+ [Step] + CRLF;
+ [Display] + CRLF; && Included for backward compatibility
+ [Filter] + CRLF;
+ [Helpfilter] + CRLF;
+ [Pdsetup] + CRLF;
+ [Relation] + CRLF;

&&	textmerge, , 1 && unable to restore - set textmerge delimiters to ...

try && aLinesCols() may not be in scope

	if lProperty(_screen, 'abSet_aSupported')
		lnResult = alen(_screen.abSet_aSupported, 1)
		dimension laResult[m.lnResult, Alen(_screen.abSet_aSupported, 2)]
		acopy(_screen.abSet_aSupported, laResult)
	else
		lnResult = aLinesCols(; && very long ! - to be optimized
			  @m.laResult;
			, upper(chrtran(cInLineCommentStripped(m.lcUnsupported + CRLF + m.lcUntested), space(1), space(0)));
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
	llResult = .t. && assume setting is supported
endtry

return m.llResult

* ------------------------------------
hidden function destroy && Restores setting to its original value

local lvValue

return .t.;
	and this.get(@m.lvValue, m.this.cSetting, m.this.cParm2);
	and (.f.;
		or m.lvValue == m.this.vValueOld; && lvValue et this.vValueOld sont obtenus par this.Get() donc sont de même type et casse
		or this.set(m.this.cSetting, m.this.vValueOld);
		)

* =================================================
enddefine
* =================================================

* ------------------------------------
procedure abSet1 && Règle un set pour test
lparameters ;
	tcSetting,; && Setting to perform
	tvValueNew,; && Value to set, .T. to toggle ON - OFF
	tnSetting,; && Setting number when appropriate for tcSetting, as of 2nd parameter of set()
	tlChangeAlways,; && [.T.] Change setting even if required value is current
	tlSupported && [.F.] assume setting is supported

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
procedure abSet1_Test && Teste le réglage d'un set pour mesurer le temps d'exécution

local loUnitTest as abUnitTest of abDev.prg, loAsserts as abSet
loUnitTest = newobject('abUnitTest', 'abDev.prg')
loAsserts = abSet('ASSERTS', 'OFF') && pour les settings non supportés

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
procedure abSet_Tests && Tests the abSet Class

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

* Prepare test resources
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

* For each test Set
lnSets = abSet_Tests_aSets(@m.laSets)
for each m.lcSet in m.laSets

	lcSet = cInLineCommentStripped(m.lcSet)

	* If Setting object can be instanciated
	loSet = abSet(&lcSet)
	llSet = vartype(m.loSet) == 'O' and not isNull(m.loSet)
	if m.llSet

		* Memorize old values
		lcSetting = m.loSet.cSetting
		lvValueOld = m.loSet.vValueOld
		lcParm2 = m.loSet.cParm2
	else
		store space(0) to m.lcSetting, m.lvValueOld, m.lcParm2
	endif


* Check new value was correctly SET

	* Release Setting object to restore original setting
	loSet = .null.

	* Check old value was correctly restored
	if m.llSet
		lvValueNew = evaluate('Set("' + m.lcSetting + '"' + m.lcParm2 + ')')
		lvValueNew = iif(upper(m.lcSetting) == 'DEFAULT', m.lvValueNew + curdir(), m.lvValueNew)
		lvValueNew = iif(upper(m.lcSetting) == 'PATH', chrtran(m.lvValueNew, ['"], space(0)), m.lvValueNew)
		llRestore = m.lvValueOld == m.lvValueNew
		llSet = m.llRestore
	endif

	clear

	* Save any Error
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

* Display result
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
procedure abSet_Tests_aSets && Tested Sets
lparameters taSets && @ Array where tested sets should be stored
external array taSets

local lnResult; && Number of Tested Sets
, lnVersion;
, lcSets, lcSetsVFP7, lcSetsVFP8, lcSetsVFP9

lnResult = 0

text TO m.lcSetsVFP7 NOSHOW && SET, .T. on "ON/OFF"-type Settings to toggle, TO ...
	'Textmerge', '<<>>' , 1 && throws an error because not supported
	'Aternate', m.lcTestFile, 1 && throws an error because misspelled ('Aternate' instead of 'Alternate')
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
	'ClassLib', Home() + 'ffc\_base.vcx' && should exist !
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
	'Datasession', m.loSession.DataSessionId && objet créé plus haut
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
	+ iif(m.lnVersion >= 800, CRLF + m.lcSetsVFP8, space(0));
	+ iif(m.lnVersion >= 900, CRLF + m.lcSetsVFP9, space(0))
lcSets = strtran(m.lcSets, CRLF2, CRLF)

lnResult = alines(m.taSets, m.lcSets)

return m.lnResult

* ===========================================
define class abSets as GA_LIGHTWEIGHT_CLASS of abGA.prg && Règle plusieurs Sets et les restaure à la destruction && Custom pour pouvoir être .AddObjected(), mais impossible dans awAppHost as session
* ===========================================

protected lSupported, lInit

lSupported = .f. && assume abSet supports all the settings required
lInit = .t. && all settings were successful && See in this.Set() why default is .T.

*---------------------------------------------------------------------------
procedure init
lparameters result && @ {en} error if any {fr} erreur éventuelle

#if .f. && Sample implementation
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
#endif && Sample implementation

return m.this.lInit && always keep this instruction and/or call dodefault() in sub-class!

*---------------------------------------------------------------------------
protected procedure set && Effectue un réglage d'environnement
lparameters ;
	tcSetting,; && Nom du SET à régler
	tvValueNew,; && Valeur à régler
	tnSetting,; && Setting number when appropriate for tcSetting, as of 2nd parameter of set()
	tlChangeAlways,; && [.T.] Change setting even if required value is current
	tlSupported && [this.lSupported] assume abSet() supports this setting

local success as Boolean;
, loExact as abSet of abDev.prg;
, lcProp as string;
, loProp as abSet of abDev.prg;

* Si le Set est défini
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
enddefine && CLASS abSets
* ===========================================

* ===========================================
function abSetsMaintain && Sauve les sets critiques et les restore s'ils ont changé
return createobject('abSetsMaintain')

* ------------------------------------
procedure abSetsMaintain_Test && Test abSetsMaintain()

local loUnitTest as abUnitTest of abDev.prg, loResult
loUnitTest = newobject('abUnitTest', 'abDev.prg')
loResult = newobject('abSetsMaintain', 'abDev.prg')

*loUnitTest.coverageSet(.T.)
loUnitTest.Test(.null.) && 1 ms

* loUnitTest.coverageSet(.F.)

return m.loUnitTest.result()

* ===========================================
define class abSetsMaintain as GA_LIGHTWEIGHT_CLASS of abGA.prg && Sauve les sets critiques et les restore s'ils ont changé
* ===========================================

hidden aSet[1], nSets

*---------------------------------------------------------------------------
protected procedure init
lparameters tlProcClass && [.F.] also save Set("Procedure") & Set("Classlib")

local success as Boolean;
, lcSets, lnSets, laSet[1], liSet

#if .f.
	compatible, 1
	century, 2
	reprocess, 1
	reprocess, 2
	reprocess, 3
	talk, 1
	textmerge, 4
	notify, 1
#endif

text to lcSets noshow flags 1 pretext 3
	ALTERNATE
	ANSI
	ASSERTS
	AUTOINCERROR
	AUTOSAVE
	BLOCKSIZE
	BROWSEIME
	CARRY
	CENTURY
	COLLATE
	COMPATIBLE
	CONSOLE
	COVERAGE
	CPDIALOG
	CURRENCY
	DATABASE
	DATASESSION
	DATE
	DECIMALS
	DEFAULT
	DELETED
	DELIMITERS
	ENGINEBEHAVIOR
	ESCAPE
	EXACT
	EXCLUSIVE
	FDOW
	FIELDS
	FIXED
	FULLPATH
	FWEEK
	HOURS
	LIBRARY
	LOCK
	MEMOWIDTH
	MESSAGE
	MOUSE
	MULTILOCKS
	NEAR
	NOTIFY
	NULL
	NULLDISPLAY
	ODOMETER
	OPTIMIZE
	PATH
	POINT
	PRINTER
	REFRESH
	REPORTBEHAVIOR
	REPROCESS
	RESOURCE
	SAFETY
	SECONDS
	SEPARATOR
	SPACE
	SQLBUFFERING
	STATUS
	STRICTDATE
	SYSFORMATS
	SYSMENU
	TABLEPROMPT
	TABLEVALIDATE
	TALK
	TEXTMERGE
	TEXTMERGE, 1
	TEXTMERGE, 2
	TEXTMERGE, 3
	UDFPARMS
	UNIQUE

	CENTURY, 1
	FIELDS, 1
	MOUSE, 1
	REFRESH, 1
	NOCPTRANS

	ALTERNATE, 1
	BELL, 1
	COVERAGE, 1
	RESOURCE, 1
	CURRENCY, 1
	DELIMITERS, 1
	MESSAGE, 1
ENDTEXT

lcSets = m.lcSets + iif(m.tlProcClass;
	, CRLF;
		+ 'PROCEDURE' + CRLF;
		+ 'CLASSLIB' + CRLF;
	, '';
	)

store alines(m.laSet, m.lcSets, 5) to lnSets, this.nSets
success = m.lnSets > 0
if m.success

	aColsIns(@m.laSet, 1, 2)

	for liSet = 1 to m.lnSets

		laSet[m.liSet, 2] = evl(int(val(getwordnum(m.laSet[m.liSet, 1], 2, ','))), '')
		laSet[m.liSet, 1] = alltrim(getwordnum(m.laSet[m.liSet, 1], 1, ','))
		laSet[m.liSet, 3] = this.uset(laSet[m.liSet, 1], laSet[m.liSet, 2])

	endfor

	dimension this.aSet[m.lnSets, 3]
	acopy(m.laSet, this.aSet)

endif

return m.success

*---------------------------------------------------------------------------
protected procedure uset
lparameters lcSet, lnSet

return icase(;
		m.lcSet == 'DEFAULT',;
			set(m.lcSet) + curdir(),;
		empty(m.lnSet),;
			set(m.lcSet),;
			set(m.lcSet, m.lnSet);
		)

*---------------------------------------------------------------------------
protected procedure destroy

local liSet, lcSet, luSet, lnSet

for liSet = 1 to this.nSets

	if !this.aSet[m.liSet, 3] == this.uset(this.aSet[m.liSet, 1], this.aSet[m.liSet, 2])

		lcSet = this.aSet[m.liSet, 1]
		lnSet = this.aSet[m.liSet, 2]
		luSet = this.aSet[m.liSet, 3]

		do case

		case empty(m.lnSet) and vartype(m.luSet) == 'C' and m.luSet $ 'ON,OFF'
			set &lcSet &luSet

		case m.lcSet == 'TEXTMERGE'
			do case
			case m.lnSet = 1 && cLeftDelimiter and cRightDelimiter
				luSet = '"' + stuffc(m.luSet, len(m.luSet)/2 + 1, 0, '","') + '"'
				set textmerge delimiters to &luSet
			case m.lnSet = 2 && cFileName
				set textmerge to (m.luSet)
			case m.lnSet = 3 && SHOW/NOSHOW
				set textmerge to &luSet
			endcase

		case inlist(m.lcSet, 'CENTURY', 'FIELDS', 'MOUSE', 'REFRESH', 'NOCPTRANS')
			set &lcSet to &luSet

		otherwise
			set &lcSet to (m.luSet)

		endcase
	endif
endfor


* ===========================================
enddefine && CLASS abSetsMaintain
* ===========================================


* ========================================
function lSetClasslib && Un jeu de Set("Classlib") est dans le Set("Classlib") courant
lparameters tcSetClasslib && Jeu de Set("Classlib")

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
function lSetProcedure && Un jeu de Set("Procedure") est dans le Set("Procedure") courant
lparameters tcSetProcedure && Jeu de Set("Procedure")

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
function cFuncCallParmAdd && Ajoute un paramètre à un appel de fonction
lparameters ;
	tcFuncCall,; && Chaîne contenant un appel de fonction
	tcParm && Chaîne à ajouter comme paramètre (ex. '@MonParm') /!\ non vérifié
local llResult, lcResult
lcResult = space(0)

llResult = vartype(m.tcFuncCall) == 'C'
if m.llResult
	lcResult = alltrim(m.tcFuncCall)
	llResult = right(m.lcResult, 1) == ')'
	if m.llResult

		llResult = vartype(m.tcParm) == 'C' and not empty(m.tcParm)
		if m.llResult

			local lcParm
			lcParm = alltrim(m.tcParm)
			lcParm = iif(left(m.lcParm, 1) == ',', space(0), ',') + m.lcParm
			lcResult = left(m.lcResult, len(m.lcResult) - 1) + m.lcParm + ')'
		endif
	endif
endif

return m.lcResult

* ------------------------------------
procedure cFuncCallParmAdd_Test && Teste cFuncCallParmAdd()

local loUnitTest as abUnitTest of abDev.prg
loUnitTest = newobject('abUnitTest', 'abDev.prg')

loUnitTest.Test('myFunc(toto,m.lcTest)', ' myFunc(toto)', 'm.lcTest')

return loUnitTest.result()

* ========================================
function cException && Message d'exception standard
lparameters toException as exception && Objet exception

local lcResult, luUserValue

lcResult = ''

if vartype(m.toException) == 'O' and type('m.toException.BaseClass') == 'C' and m.toException.baseclass == 'Exception'

	with m.toException as exception

		lcResult = cLitteral(.linecontents)
		lcResult = iif(_vfp.startmode = 0;
			, textmerge(icase(;
					cLangUser() = 'fr',	[ (<<Iif('...' $ .LineContents, 'code source N/D', m.lcResult)>>)],; && copy-paste this line to add another language support
															[ (<<Iif('...' $ .LineContents, 'source code N/A', m.lcResult)>>)]; && default: English
				));
			, space(0);
			)
		luUserValue = iif(vartype(.uservalue) == 'O' and proper(.uservalue.baseclass) == 'Exception', cException(.uservalue), .uservalue)
		lcResult = textmerge(icase(;
			cLangUser() = 'fr',	[Méthode ou procédure <<.Procedure>>() : erreur n° <<.ErrorNo>> ("<<c2Words(.Message,' - ', m.luUserValue)>>") à la ligne n° <<.LineNo>><<m.lcResult>>],; && copy-paste this line to add another language support
													[Method or procedure <<.Procedure>>(): error #<<.ErrorNo>> ("<<c2Words(.Message,' - ', m.luUserValue)>>") at code line #<<.LineNo>><<m.lcResult>>]; && default: English
			))
	endwith
endif

return m.lcResult

* ------------------------------------
procedure cException_Test && Teste cException()

local loUnitTest as abUnitTest of abDev.prg, lcCmd, loException as exception, lcResult

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
procedure FilesCompile && Compile des fichiers d'après un squelette
lparameters ;
	tcFilesSkeleton,; && Squelette d'adresse de fichiers
	tcFilesFailed && @ [''] Fichiers dont la compilation a échoué
tcFilesFailed = space(0)

local lnFiles, laFiles[1], llResult, lnResult && Nombre de fichiers compilés avec succès
lnResult = 0

* S'il existe au moins un fichier répondant au masque spécifié
lnFiles = aFiles(@m.laFiles, m.tcFilesSkeleton)
llResult = m.lnFiles > 0
assert m.llResult message cAssertMsg(textmerge([No file match the specified skeleton: <<cLitteral(m.tcFilesSkeleton)>>]))
if m.llResult

	local lcFolderAddr, loProc, loClass, lnFile, lcFile, lnFilesFailed, laFilesFailed[1]
	lcFolderAddr = addbs(justpath(m.tcFilesSkeleton))

	* Sauver les set car COMPILE ferme automatiquement les fichiers
	loProc = abSet('PROCEDURE', set("Procedure"),,, .t.)
	loClass = abSet('CLASSLIB', set("ClassLib"),,, .t.)

	debugout space(1)
	debugout replicate('=', 50)
	debugout "Compiling", transform(m.lnFiles), 'files in', m.lcFolderAddr

	* Pour chaque fichier
	lnFilesFailed = 0
	for lnFile = 1 to m.lnFiles
		lcFile = laFiles[m.lnFile, 1]

		* Compiler le fichier
		llResult = FileCompile(m.lcFolderAddr + m.lcFile)

		* Si succès, compter
		if m.llResult
			lnResult = m.lnResult + 1
		* Sinon, tabuler
		else
			lnFilesFailed = lnFilesFailed + 1
			dimension laFilesFailed[m.lnFilesFailed]
			laFilesFailed[m.lnFilesFailed] = m.lcFile
		endif
	endfor

	release loProc, loClass && Rétablit les SET

	debugout transform(m.lnResult), "files compiled out of", transform(m.lnFiles)
	debugout replicate('=', 50)

	* Si échec(s), lister les fichiers
	if m.lnFilesFailed > 0
		tcFilesFailed = cListOfArray(@m.laFilesFailed)
	endif
endif

return m.lnResult

* ---------------------------------------------------
procedure FileCompile && Compile un fichier
lparameters ;
	tcFileAddr,; && Adresse du fichier
	tcResult,; && @ [''] Résultat de la compilation
	tcClause,; && [''] Clauses de compilation (pour *.prg)
	tnResult && [0] @ nombre d'erreurs de compilation
tcResult = ''
tcClause = evl(m.tcClause, space(0))
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
	loNotify = abSet('NOTIFY', 'OFF') && supprime le thermomètre d'avancement

	* Tenter la compilation
	tcFileAddr = fullpath(m.tcFileAddr)
	lcExt = justext(m.tcFileAddr)
	try

		do case

		case inlist(m.lcExt, 'PRG', 'QPR', 'MPR')
			llInSet = forceext(m.tcFileAddr, icase(m.lcExt == 'PRG', 'FXP', m.lcExt == 'QPR', 'QPX', 'MPX')) $ set("Procedure")
			compile (m.tcFileAddr) &tcClause
			if m.llInSet
				set procedure to (m.tcFileAddr) additive
			endif

		case m.lcExt = 'VCX'
			clear classlib (m.tcFileAddr) && par sécurité
			compile classlib (m.tcFileAddr)

		case m.lcExt = 'SCX'
			compile form (m.tcFileAddr)

	 	case m.lcExt = 'FRX'
			compile report (m.tcFileAddr)

	 	case m.lcExt = 'LBX'
			compile label (m.tcFileAddr)

		case m.lcExt = 'DBC'
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
*-				IF InList(m.lcExt, 'SCX', 'VCX', 'FRX', 'LBX', 'DBX') && le code source est dans une table
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
			+ iif(empty(m.tcClause), space(0), ' - ' + m.tcClause)

		?? chr(7)
	endtry

	tcResult = iif(empty(m.tcResult), '', textmerge([[<<Proper(Program())>>() - <<m.tcResult>>]))
	debugout m.tcResult
endif

return m.llResult

* ========================================
procedure ProcEmpty && Sert à mesurer le temps moyen d'appel d'une procédure
lparameters ;
	Parm1,; && Bidon
	Parm2,; && Bidon
	Parm3,; && Bidon
	Parm4,; && Bidon
	Parm5,; && Bidon
	Parm6 && Bidon
local llResult
llResult = .t.
uDefault(m.Parm1, 'bidon')
return m.llResult

* ------------------------------------
procedure ProcEmpty_Test && Teste ProcEmpty()

local loUnitTest as abUnitTest of abDev.prg
loUnitTest = newobject('abUnitTest', 'abDev.prg')

loUnitTest.Test(.t.)
loUnitTest.Test(.t., 2, 'bidon', .f., date())

return loUnitTest.result()

* ========================================
function cPWRand && Mot de passe aléatoire sûr selon indications Windows
lparameters tnLength && [8] Nombre de caractères

local lcResult, lcCars, lnCars, lnCar

&& Passwords must contain characters from three of the following five categories:
lcCars = '';
	+ 'ABCDEFGHIKKLMNOPQRSTUVWXYZ'; && Uppercase characters of European languages (A through Z, with diacritic marks, Greek and Cyrillic characters)
	+ 'abcdefghikklmnopqrstuvwxyz'; && Lowercase characters of European languages (a through z, sharp-s, with diacritic marks, Greek and Cyrillic characters)
	+ '0123456789'; && Base 10 digits (0 through 9)
	+ '!@#$%&*_-+=/|\(){}[];"' + ['<>,.?]; && Nonalphanumeric characters && ^~`: removed those difficult to type or conflicting with usual syntax
	+ '' && Any Unicode character that is categorized as an alphabetic character but is not uppercase or lowercase. This includes Unicode characters from Asian languages.

lnCars = len(m.lcCars)
lcResult = ''

rand(-1) && To achieve the most random sequence of numbers, issue RAND( ) initially with a negative argument and then issue RAND( ) without an argument.
for lnCar = 1 to iif(vartype(m.tnLength) = 'N' and m.tnLength > 0, m.tnLength, 8)
	lcResult = m.lcResult + substr(m.lcCars, min(max(int(rand() * m.lnCars), 1), m.lnCars), 1)
endfor

return m.lcResult

* -------------------------------------------------------------
function cPWRand_Test && Teste cPWRand

? sys(16)
? cPWRand()
? cPWRand(15)

* ========================================
define class abProject as GA_LIGHTWEIGHT_CLASS of abGA.prg && ouvre un projet et le referme automatiquement

oProject = .null. && Référence au projet
lOpened = .f. && Le projet a été ouvert - .NULL. le projet a été créé

* ----------------
protected procedure init
lparameters ;
	tcPJX,; && Adresse du projet
	tcResult && @ Résultat en cas d'échec

local llOpened, llResult

this.oProject = oProject(m.tcPJX, @m.tcResult, @m.llOpened)
this.lOpened = m.llOpened

return vartype(m.this.oProject) == 'O'

* ----------------
protected procedure destroy

if m.this.lOpened or isNull(m.this.lOpened)
	this.oProject.close
endif

enddefine && CLASS abProject
* ========================================

* ========================================
function lProject && Un projet est ouvert
lparameters tcPJX && Nom du projet

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
function oProject && Référence à un projet (ouvert ou créé)
lparameters ;
	tcPJX,; && Adresse du projet
	result,; && @ Résultat (cumulatif)
	tlOpened && @ [.F.] Le projet a été ouvert - .NULL. le projet a été créé

tlOpened = .f.

local loResult as project;
, loProject as project;
, llResult as Boolean;
, loException as exception;

loResult = .null.

if vartype(m.tcPJX) == 'C'

	tcPJX = iif(empty(justext(m.tcPJX)), forceext(m.tcPJX, 'pjx'), m.tcPJX)
	if lower(justext(m.tcPJX)) == 'pjx'

	 	if file(m.tcPJX)
		 	tcPJX = fullpath(m.tcPJX)

			* Si le projet n'est pas déjà ouvert
			llResult = _vfp.projects.count > 0
			if m.llResult
				llResult = .f.
				for each loProject in _vfp.projects foxobject
					if fullpath(m.loProject.name) == m.tcPJX
						llResult = .t.
						loResult = m.loProject && after EXIT, FOR EACH resets loProject to .F.
						exit
					endif
				endfor
			endif
	 	else
	 		tlOpened = .null.
	 	endif
		if not m.llResult

			* Ouvrir le projet
			try
				ignoreAll() && modify command abDev
				modify project (m.tcPJX) save nowait noshow noprojecthook
				loResult = _vfp.activeproject
				tlOpened = iif(isNull(m.tlOpened), m.tlOpened, .t.)
			catch to loException when m.loException.ErrorNo = 1705 && File Access is denied
				cResultAdd(@m.result, cException(m.loException) + ' - ' + ICase(;
					cLangUser() = 'fr',	[Conseil : fermez toutes les autres instances de VFP où le projet a pu être ouvert],; && copy-paste this line to add another language support
															[Hint: close all instances of VFP IDE where project can have been open.]; && default: English
					))
			catch to loException
				cResultAdd(@m.result, cException(m.loException))
			endtry
		endif
	else
		cResultAdd(@m.result, textmerge([Invalid project file extension : <<cLitteral(m.tcPJX)>>]))
	endif
else
	cResultAdd(@m.result, textmerge([Invalid project specification : <<cLitteral(m.tcPJX)>>]))
endif

return m.loResult

* ========================================
procedure IgnoreAll && sélectionne automatiquement l'option 'tout' dans un dialogue tel que ASSERT
&& contribution by Bob Pierce during FoxInCloud training '15 at Phoenix AZ

local lcVersion3 as String

lcVersion3 = Version(3)

keyboard '';
	+ '{alt+';
	+ ICase(;
		m.lcVersion3 == '33',	't',; && French - 'tout'
		m.lcVersion3 == '34',	't',; && Spanish - 'todas'
		m.lcVersion3 == '49',	'a',; && German - 'alle'
			'a'; && Default: English - 'all'
		);
		+ '}'

endproc

* ========================================
procedure ProjectClose && Ferme un projet
lparameters tcProject && Nom du projet tel qu'il apparaît dans sa barre de titre

local loProject as project, lcProject, llResult, lcResult && Adresse du projet pour le réouvrir ultérieurement

lcResult = space(0)
llResult = vartype(m.tcProject) == 'C' and not empty(m.tcProject)
assert m.llResult message cAssertMsg(textmerge([Invalid project specification : <<cLitteral(m.tcProject)>>]))
if m.llResult and _vfp.projects.count > 0

	* Pour chaque projet ouvert
	tcProject = upper(alltrim(m.tcProject))
	for each m.loProject in _vfp.projects
		lcProject = m.loProject.name

		* si c'est le projet cherché
		if upper(juststem(m.lcProject)) == m.tcProject

			* Fermer
			loProject.close
			lcResult = m.lcProject
			exit
		endif
	endfor
endif

return m.lcResult

* ========================================
function abProjectsClose as abProjectsClose of abDev.prg && Ferme les projets à .Init(), les rouvre à .Destroy()
return createobject('abProjectsClose')

* ========================================
define class abProjectsClose as GA_LIGHTWEIGHT_CLASS of abGA.prg && Ferme les projets à .Init(), les rouvre à .Destroy()
* ========================================

	hidden aProjects[1], nProjects

* ---------------
	procedure init

	this.nProjects = iif(lDevMode();
		, _vfp.projects.count;
		, 0;
		)

	if empty(m.this.nProjects)
		return .f.
	endif

	local lnProject, loProject as project

	dimension this.aProjects[m.this.nProjects]

	for lnProject = m.this.nProjects to 1 step -1
		loProject = _vfp.projects(m.lnProject)
		this.aProjects[m.lnProject] = m.loProject.name
		loProject.close
	endfor

* ---------------
	procedure destroy

	if m.this.nProjects > 0
		local lnProject
		for lnProject = m.this.nProjects to 1 step -1
			modify project (this.aProjects[m.lnProject]) nowait
		endfor
	endif

* ========================================
enddefine && CLASS abProjectsClose
* ========================================

* ========================================
define class abDBCsClose as GA_LIGHTWEIGHT_CLASS of abGA.prg && Init() ferme les bases de données, Destroy() les rouvre
* ========================================

	hidden aDBCs[1], nDBCs, cDBCCur

* ---------------
	procedure init

	this.nDBCs = adatabases(this.aDBCs) && [nom | adresse]

	if this.nDBCs > 0
		this.cDBCCur = dbc()

		local lnDBC
		for lnDBC = 1 to this.nDBCs
			set database to (this.aDBCs[m.lnDBC, 1]) && nom
			close databases
		endfor
	endif

* ---------------
	procedure destroy

	if this.nDBCs > 0

		local lnDBC
		for lnDBC = 1 to this.nDBCs
			open database (this.aDBCs[m.lnDBC, 2]) && adresse
		endfor
		if file(this.cDBCCur)
			set database to (m.this.cDBCCur)
		endif
	endif

* ========================================
enddefine && CLASS abDBCsClose
* ========================================


* ========================================
function nFColor && Couleur d'avant plan
lparameters tcFColor && Chaîne selon format "RRR,GGG,BBB"
local lnResult
lnResult = 0 && black

if vartype(m.tcFColor) == 'C' and occurs(',', m.tcFColor) = 2
	local array laFColors[1]
	alines(laFColors, m.tcFColor, 1, ',')
	lnResult = rgb(val(laFColors[1]), val(laFColors[2]), val(laFColors[3]))
endif

return m.lnResult

* ========================================
function nBColor && Couleur d'arrière plan
lparameters tcBColor && Chaîne selon format "RRR,GGG,BBB"

local lnResult
lnResult = rgb(255, 255, 255) && white

if vartype(m.tcBColor) == 'C' and occurs(',', m.tcBColor) = 2
	local array laBColors[1]
	alines(laBColors, m.tcBColor, 1, ',')
	lnResult = rgb(val(laBColors[1]), val(laBColors[2]), val(laBColors[3]))
endif

return m.lnResult

* =================================================
function abISX && Arrête et redémarre ISX (nécessaire en développement de formulaires)
return createobject('abISX')

* =================================================
define class abISX as GA_LIGHTWEIGHT_CLASS of abGA.prg && Arrête et redémarre ISX (nécessaire en développement de formulaires)
* =================================================
hidden lISX, cISX

lISX = file('ISX.fxp')

* ------------------------------------
procedure init && Désactive ISX


* return .F.

if m.this.lISX and lDevMode() && lDevMode() par sécurité, évite un WAIT en unattended server mode
	this.cISX = fullpath('ISX.fxp')
	local lcISX
	lcISX = "ISX('QUIT')" && évite d'embarquer ISX dans le projet
	&lcISX
else
	return .f.
endif

* ------------------------------------
procedure destroy && Résactive ISX
local lcISX
lcISX = 'DO "' + m.this.cISX + '"' && évite d'embarquer ISX dans le projet
&lcISX

* =================================================
enddefine && CLASS abISX
* =================================================

* ------------------------------------
function uValue && Valeur convertie selon le varType spécifié (AKA coercition de type)
lparameters ;
	tuValue,; && Valeur source
 	tcTypeDest && Type de valeur attendu selon codification de la fonction VFP varType()

&& /!\ pourrait être simplifiée et optimisée avec Cast()

local luResult;
, llResult;
, lcTypeSrce;
, lcTypeDest;

luResult = .null.

#if .f. && Vartype() VFP9
	C && Character, Memo, Varchar, Varchar (Binary)
	D && Date
	G && General
	L && Logical
	n && Numeric, Float, Double, or Integer
	O && Object
	Q && Blob, Varbinary
	t && DateTime
	U && Unknown or variable does not exist
	X && .NULL.
	y && Currency
	i && Integer && support additionnel
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

					* Normaliser le point décimal éventuel, supprimer les séparateurs de milliers
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
					m.lcTypeDest == 'L', icase(inlist(m.tuValue, 'T', '.T.', 'VRAI', 'TRUE'), .t., empty(m.tuValue) or inlist(m.tuValue, 'F', '.F.', 'FAUX', 'FALSE'), .f., evaluate(m.tuValue)),;
					m.lcTypeDest $ 'DT', iif(left(m.tuValue, 1) = '{', evaluate(m.tuValue), uValue_TD(m.tuValue, m.lcTypeDest)),;
					.null.)
				if m.lcTypeDest $ 'DT' && Ctod() et Ctot() peuvent produire un résultat invalide
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
					m.lcTypeDest == 'C', cLitteral(m.tuValue),; && mieux que Cast()
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
function uValue_TD
lparameters ;
  tuValue; && Valeur source
, tcTypeDest; && Type de valeur attendu selon codification de la fonction VFP varType()

local cMark, lCentury, cDate, cTime

cMark = evl(set("Mark"), '/')

tuValue = strtran(strtran(strtran(strtran(chrtran(cRepCharDel(alltrim(m.tuValue));
	, '-', m.cMark); && iPhone
	, ' ' + m.cMark, m.cMark);
	, m.cMark + ' ', m.cMark);
	, ' :', ':');
	, ': ', ':');

lCentury = len(getwordnum(m.tuValue, 1, '/')) = 4 && YYYY/MM/DD assumed

do case

case !vartype(m.tuValue) == 'C';
 or occurs(m.cMark, m.tuValue) # 2; && 2015-06-16 - {en} default values in case m.tuValue is not a date, eg. "boto" - contributor Gilles Lajot-Sarthou
 or empty(chrtran(m.tuValue, m.cMark+':APM', ''))
	return iif(m.tcTypeDest = 'D', {/}, {/:}) && {en} empty date[-time] {fr} date[-time] vide

case left(m.tuValue, 1) == '{' and right(m.tuValue, 1) == '}' && litteral
	return evaluate(m.tuValue)

case m.lCentury and m.tcTypeDest = 'D' &&
	cDate = m.tuValue
	return date(;
		  evl(int(val(getwordnum(m.cDate, 1, m.cMark))), year(date())); && year
		, evl(int(val(getwordnum(m.cDate, 2, m.cMark))), month(date())); && month
		, evl(int(val(getwordnum(m.cDate, 3, m.cMark))), day(date())); && day
		)

case m.lCentury && m.tcTypeDest = 'T'
	cDate = getwordnum(m.tuValue, 1)
	cTime = getwordnum(m.tuValue, 2)
	return datetime(;
		  evl(int(val(getwordnum(m.cDate, 1, m.cMark))), year(date())); && year
		, evl(int(val(getwordnum(m.cDate, 2, m.cMark))), month(date())); && month
		, evl(int(val(getwordnum(m.cDate, 3, m.cMark))), day(date())); && day
		, int(val(getwordnum(m.cTime, 1, ':'))); && hour
		, int(val(getwordnum(m.cTime, 2, ':'))); && minute
		, int(val(getwordnum(m.cTime, 3, ':'))); && seconds
		)

case m.tcTypeDest = 'D'
	return ctod(m.tuValue)

otherwise
	return ctot(m.tuValue)

endcase
endfunc

* -----------------------------------------------------------------
procedure uValue_Test && Teste uValue()

local loUnitTest as abUnitTest of abDev.prg
loUnitTest = newobject('uValue_Test', 'abDev.prg')

loUnitTest.Test(1421.5, '1 421,5', 'N')
loUnitTest.Test(1421.5, '1 421.5', 'N')
* loUnitTest.Test(1421.5, '1,421.5', 'N') && échec
loUnitTest.Test($1421.5, '$    1 421.5', 'Y')
loUnitTest.Test(1421, '1 421.5', 'I')

loUnitTest.Test(.t., 'T', 'L')
loUnitTest.Test(.t., 2, 'L')
loUnitTest.Test({}, '23/09/194', 'D') && date invalide && ajouté le 15/05/09

loUnitTest.Test({/}, 'boto', 'D') && 2015-06-16 - contributor Gilles Lajot-Sarthou

return loUnitTest.result()

define class uValue_Test as abUnitTest of abDev.prg
		procedure init
		dodefault()
		set separator to chr(160)
		set point to ','
	enddefine

* =================================================
function luEqual && Deux valeurs sont égales en tenant compte des .NULL.
lparameters ;
	tu1,; && Valeur 1, par référence si Array
	tu2,; && Valeur 2, par référence si Array
	tlStrict,; && [.F.] comparaison de chaînes stricte
	tlCaseIgnore && [.F.] ignorer la casse
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
function luEqual_Object	&& Deux objets sont identiques
lparameters ;
	tu1,; && objet 1
	tu2 && objet 2

local laProp[1], lcProp, liItem, la1[1], la2[1], llResult

llResult = m.tu1 = m.tu2 && référence au même objet
if not m.llResult

	llResult = amembers(laProp, m.tu2) + amembers(laProp, m.tu1) = 0
	if not m.llResult

		for each lcProp in laProp

			llResult = .f.;
			 or inlist(m.lcProp, 'PARENT', 'CONTROLS', 'OBJECTS', 'PAGES', 'COLUMNS');
			 or .t.;
			  and pemstatus(m.tu2, m.lcProp, 5); && extent
			  and not pemstatus(m.tu1, m.lcProp, 2); && protected
			  and not pemstatus(m.tu2, m.lcProp, 2); && protected
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
procedure luEqual_Test && Teste luEqual

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
function cSetPath(tlSort) && Set("Path") bien présenté

local laResult[1]

alines(laResult, set("Path"), 1, ',', ';')
if m.tlSort
	asort(laResult)
endif

return cListOfArray(@m.laResult, CRLF)

* =================================================
function cSetProc(tlSort) && Set("Procedure") bien présenté

local laResult[1]

alines(laResult, set("Procedure"), 1, ',', ';')
if m.tlSort
	asort(laResult)
endif

return cListOfArray(@m.laResult, CRLF)

* =================================================
function cSetClass(tlSort) && Set("Classlib") bien présenté

local laResult[1]

alines(laResult, set("Classlib"), 1, ',', ';')
if m.tlSort
	asort(laResult)
endif

return cListOfArray(@m.laResult, CRLF)

* =================================================
function cMBcmdCaption && Label d'un bouton d'une messageBox() d'après son type
lparameters ;
	tiType,; && [1] Type selon doc messageBox()
	tcLang,; && [cLangUser()] Langue
	tlHotKey && [.F.] souligner la lettre de raccourci
tiType = int(evl(nvl(m.tiType, 0), 1)) && OK par défaut
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
function nDialogBoxTypeParms && Composantes du paramètre 'nDialogBoxType' d'une messageBox()
lparameters ;
	nDialogBoxType,; && cf. messageBox()
	tnButtons,; && @ (0-5) boutons à afficher
	tnIcon,; && @ (16,32,48 ou 64) icône à afficher
	tnDefault && @ (0,256,512) Bouton actif par défaut

tnButtons = bitand(m.nDialogBoxType, bitset(bitset(bitset(0, 0),1),2))
tnButtons = iif(between(m.tnButtons, 0, 5), m.tnButtons, 0)

tnIcon = bitand(m.nDialogBoxType, bitset(bitset(bitset(0, 4),5),6))
tnIcon = iif(inlist(m.tnIcon, 16,32,48,64), m.tnIcon, 0)

tnDefault = bitand(m.nDialogBoxType, bitset(bitset(0, 8),9))
tnDefault = iif(inlist(m.tnDefault, 256, 512), m.tnDefault, 0)

return m.nDialogBoxType

* --------------------
procedure nDialogBoxTypeParms_Test && Teste nDialogBoxTypeParms()

local loUnitTest as abUnitTest of abDev.prg
loUnitTest = newobject('abUnitTest', 'abDev.prg')

local lnDialogBoxType,; && cf. messageBox()
	lnButtons,; && @ (0-5) boutons à afficher
	lnIcon,; && @ (16,32,48 ou 64) icône à afficher
	lnDefault && @ (0,256,512) Bouton actif par défaut

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
function nScreenDockOffset && Nombre de colonnes où commence la partie gauche du _Screen du fait des fenêtres dockées à gauche
lparameters tlRows && [.F.] décalage ; .T.: vertical (rows), .F.: horizontal (cols)
tlRows = lTrue(m.tlRows)

local laDock[1], lnDocks, lnDock, lnResult

lnResult = 0
lnDocks = adockstate(laDock, 1) &&
if m.lnDocks > 0
	for m.lnDock = 1 to m.lnDocks
		if laDock[m.lnDock, 2] = 1;
		 and laDock[m.lnDock, 3] = iif(m.tlRows;
		 	, 0; && top
		 	, 1); && left
		 and laDock[m.lnDock, 4] = _screen.caption

			lnResult = m.lnResult + iif(m.tlRows, wrows(laDock[m.lnDock, 1]), wcols(laDock[m.lnDock, 1]))
		endif
	endfor
endif

return m.lnResult

* =================================================
function cABuserDataPath && Adresse standard du dossier où résident les données AB

local lcResult

lcResult = home(7) + 'AB\' && Visual FoxPro subdirectory in the user's Visual FoxPro Application Data directory
if not directory(m.lcResult)
	md (m.lcResult)
endif

return m.lcResult

* ===========================
function cABmoduleTestAddr && Adresse du fichier de test d'un module
lparameters tcModule
local lcPrevious, lcResult
lcResult = cABuserDataPath() + forceext(m.tcModule, 'tst')

* Si le fichier est à l'ancienne adresse, déplacer dans la nouvelle
lcPrevious = DOS_AB + forceext(m.tcModule, 'tst')
if lFile(m.lcPrevious)
	FileMove(m.lcPrevious, m.lcResult)
endif

return m.lcResult

* ===========================
function cLocalized && Chaîne localisée
lparameters ;
  tcString; && Chaîne à localiser
, tcLangUser; && [cLangUser()] Langue de l'utilisateur

local result as string;
, liLangUser as integer;
, liEN as integer;

tcLangUser = iif(ga_Type_IsChar(m.tcLangUser, .t.) and lenc(m.tcLangUser) = 2, m.tcLangUser, cLangUser())

liLangUser = at_c('{' + m.tcLangUser + '}', m.tcString)
liEN = at_c('{en}', m.tcString)

result = icase(;
	m.liLangUser > 0,;
		substrc(m.tcString, m.liLangUser + 4),;
	m.liEN > 0,;
		substrc(m.tcString, m.liEN + 4),;
		m.tcString;
	)

return alltrim(iif(m.liEN + m.liLangUser > 0;
	, leftc(m.result, evl(at_c('{', m.result), lenc(m.result)+1)-1);
	, m.result;
	), CR, LF, ' ', chr(9))
endfunc

* ------------------------------------
procedure cLocalized_Test && Teste cLocalized()

local loUnitTest as abUnitTest of abDev.prg
loUnitTest = newobject('abUnitTest', 'abDev.prg')

loUnitTest.Test([formulaire où s'est produit l'événement], [ {en} requested form {fr} formulaire où s'est produit l'événement], 'fr')
loUnitTest.Test([requested form], [ {en} requested form {fr} formulaire où s'est produit l'événement], 'en')

return m.loUnitTest.result()


* -----------------------------------
function cLangUser && Code langue de l'utilisateur courant
lparameters tuLocale && [.F.] @ Code langue avec locale (genre 'fr-fr') ou langue forcée

local lcType, llForce, loShell as wScript.shell, lcLang, lcResult

lcType = vartype(m.tuLocale)

llForce = m.lcType == 'C' and not empty(m.tuLocale)

if .t.;
 and not m.llForce;
 and type('_Screen.cLangUser') == 'C';
 and not empty(_screen.cLangUser)

	tuLocale = _screen.cLangUser
	return _screen.cLangUser

else

	if m.llForce

		lcResult = alltrim(m.tuLocale)

	else

		declare integer GetUserDefaultUILanguage in Win32API
		loShell = createobject('wScript.Shell')

		lcResult = alltrim(getwordnum('';
			+ loShell.RegRead("HKLM\Software\Classes\MIME\Database\RFC1766\";
			+ right(transform(GetUserDefaultUILanguage(), '@0'), 4));
			, 1, ';'))

		lcResult = iif(m.lcType == 'L' and m.tuLocale;
			, m.lcResult + iif('-' $ m.lcResult, '', '-' + m.lcResult);
			, left(m.lcResult, 2);
			)

	endif

	store lower(m.lcResult) to lcResult, tuLocale
	addproperty(_screen, 'cLangUser', m.lcResult)

	return m.lcResult
endif

* =====================================================
procedure abUnitTests && Teste les modules (abUnitTest) du programme appelant

local success;
, lcSys16, lcProcFile, lcProcName;
, lcProcs, lnProc, laProc[1], liProc, lcProc, lcProcU;
, lnProcPrinc, lnProcTest

success = .t.

lcSys16 = sys(16, program(-1) -1) && calling procedure
lcProcFile = cModuleInfo(m.lcSys16, 'Address', .t.)
lcProcName = cModuleInfo(m.lcSys16, 'Name', .t.)
lcProcs = forceext(m.lcProcFile, 'txt')
strtofile(space(0), m.lcProcs) && vide la liste

* Tabuler les éléments contenus dans le fichier source
lnProc = aprocinfo(laProc, forceext(m.lcProcFile, 'PRG')) && 0 (default) - Populates the array with all document information.

* Si au moins un élément,
if m.lnProc > 0

	asort(m.laProc, 1, -1, 0, 1)

	* Pour chaque élément
	store 0 to m.lnProcPrinc, m.lnProcTest
	for m.liProc = 1 to m.lnProc

		* Si l'élément est une procédure
		if upper(laProc[m.liProc, 3]) = 'PROCEDURE'
			lcProc = laProc[m.liProc, 1]
			lcProcU = upper(m.lcProc)

			* Si procédure principale, lister
			if not '_' $ m.lcProc
				lnProcPrinc = m.lnProcPrinc + 1
				strtofile(str(m.lnProcPrinc, 2) + '-' + m.lcProc + CRLF, m.lcProcs, 1)
			endif

			* Si procédure de test, exécuter
			if .t.;
			 and rightc(m.lcProcU, lenc('_TEST')) == '_TEST' ;
			 and not m.lcProcU == m.lcProcName && this procedure
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
function abUnitTest && Objet abUnitTest
lparameters ;
	tcModule,; && [Module appelant sans le suffixe '_test'] Nom du module à tester
	tcAddress && [Adresse du code source du module appelant] Adresse contenant le répertoire où créer le Compte-rendu de test
return createobject('abUnitTest', m.tcModule, m.tcAddress)
endfunc

* =============================================
define class abUnitTest as session
* =============================================

lSingleTest = .f. && exécuter seulement une fois && cas où la fonction à tester produit un résultat cumulatif et/ou des tableaux

protected nTest, lResult
nTest = 0 && Nombre de tests réalisés
lResult = .t. && Résultat des testes (.T. tant qu'aucun test n'est réalisé)

hidden ;
	cModule,; && Nom du module à tester
	cAddress,; && Adresse du fichier contenant le module à tester
	oObject,; && Référence à l'objet si le module est une méthode
	lResult,; && Résultat des tests ; .T. si tous réussis
	lResultOut,; && Les résultats des tests ont été sortis
	cResultAddr,; && Adresse du fichier de résultats
	lCoverage,; && Enclenche le Coverage lors du test
	cCoverageAddr,; && Adresse du Fichier de Coverage
	nTest,; && Nombre de tests réalisés sur le module
	aTest[1,1] && Résultats des tests

* -----------------------------------
procedure init
lparameters ;
	tcModule,; && [Module appelant sans le suffixe '_test'] Nom du module à tester
	tcAddress && [Adresse du code source du module appelant] Adresse contenant le répertoire où créer le Compte-rendu de test

set sysformats on
set multilocks on

this.addproperty('oEscape', abSet('ESCAPE', 'ON'))
this.addproperty('oAsserts', abSet('ASSERTS', 'ON'))

local lcModule, lcAddress, llResult

* Si le nom du module n'est pas précisé, prendre le défaut
llResult = vartype(m.tcModule) == 'C' and not empty(m.tcModule)
if m.llResult
	lcModule = m.tcModule
	lcAddress = m.tcAddress
else
	lcModule = evl(this.cModuleDefault(cCallingModule(@m.lcAddress)), this.cModuleDefault(cCallingModule(@m.lcAddress, -1)))
	llResult = not empty(m.lcModule)
endif

* Si le nom du module est défini, vérifier son existence
if m.llResult

	llResult = this.ModuleSet(m.lcModule, m.lcAddress)

	* Si le module est exécutable, régler la session de données
	if m.llResult
		set memowidth to wcols(wontop()) && Fenêtre résultats du test
	endif
endif

if directory(DOS_AB)

	* S'il existe des fichiers de test ou de coverage à l'ancienne adresse, déplacer à la nouvelle
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
procedure EnvSet && Règle l'environnement de la session de données privée avant le(s) test(s)
lparameters ;
	tcEnvCommand && Commande d'environnement

if vartype(m.tcEnvCommand) == 'C'
	&tcEnvCommand
endif

* -----------------------------------
procedure ModuleSet && Définit le nom et l'adresse du module à tester
lparameters ;
	tcModule,; && [Module appelant sans le suffixe '_test'] Nom du module à tester
	tcAddress && [Adresse du code source du module] Répertoire où créer le fichier de CR de test
local llResult

* Si le module est spécifié correctement
local lcModule, lcAddress
lcModule = evl(m.tcModule, cCallingModule(@m.lcAddress))
lcAddress = cFileCased(evl(m.tcAddress, m.lcAddress))
llResult = not empty(m.lcModule) and file(m.lcAddress)
assert m.llResult message cAssertMsg(textmerge([le nom et/ou l'adresse de module est incorrect]))
if m.llResult

	* Si le module existe
	local lnError, lcError, loAsserts
	lnError = 0
	lcError = on('ERROR')
	on error m.lnError = error() && this.ModuleSet_nError(cModuleInfo(Sys(16)))
	loAsserts = abSet('ASSERTS', 'OFF')
	evaluate(m.lcModule + "(this, 'junk', Date(), 0, .F.)")
	on error &lcError
	release loAsserts
	llResult = not m.lnError = 1 && file not found
	assert m.llResult message cAssertMsg(textmerge([le module " + m.lcModule + " ne peut être exécuté.]))
	if m.llResult

		* Mémoriser le nom du module
		this.cAddress = m.lcAddress
		this.cModule  = m.lcModule

		* Définir l'adresse de son fichier résultats
		this.cResultAddr = cABmoduleTestAddr(m.lcModule)
		this.cCoverageAddr = forceext(this.cResultAddr, 'cov.log')
	else
		store space(0) to this.cModule, this.cResultAddr, this.cCoverageAddr
	endif
endif

return m.llResult

* -----------------------------------
hidden function ModuleSet_nError && N° d'erreur rencontrée lors de la tentative d'exécution du module
lparameters ;
	tcProc && Nom de la procédure où retourner en cas d'erreur

return && TO ModuleSet

* -----------------------------------
hidden function cModuleDefault && Nom du module à tester d'après le nom du module appelant
lparameters tcCallingModule && Se termine normalement par '_Test'

local lcTest, lnTest, lcResult
lcResult = space(0)

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
procedure CoverageSet && Démarre / arrête l'enregistrement des temps d'exécution pendant le test
lparameters tlCoverage && [.F.] démarrer / arrêter l'enregistrement pendant le test

this.lCoverage = lTrue(m.tlCoverage)

* -----------------------------------
procedure CoverageClear && Efface le fichier de coverage

delete file (m.this.cCoverageAddr)

* -----------------------------------
procedure Test && Teste le module
lparameters ;
	tuExpected,; && @ Résultat attendu retourné par le module testé - .NULL. : résultat attendu inconnu
	tuParm01,tuParm02,tuParm03,tuParm04,tuParm05,tuParm06,tuParm07,tuParm08,tuParm09,tuParm10,tuParm11,tuParm12,tuParm13,tuParm14 && @ paramètres passés au module testé

local luResult as Variant; && résultat du test
, lnParm;
, lcParms;
, liParm;
, luParm;
, lnElapsed;
, laStatus1[1];
, laStatus2[1];

luResult = .null.

* Si le module est bien défini
if empty(this.cModule)
	return .f.
else

	* Bâtir la chaine des paramètres à passer au module
	lnParm = max(pcount() - 1, 0)
	lcParms = this.Test_cParms(m.lnParm) && liste des paramètres à passert au module testé

	#define NCOLSFIXES 8 && /!\ utilisé par this.Test_aTestsDim()

	* Ajuster le tableau de résultats de tests
	this.nTest = this.nTest + 1
	this.Test_aTestsDim(m.lnParm)
	this.aTest[m.this.nTest, NCOLSFIXES] = m.lnParm && Nombre de paramètres passés (peut varier d'un test à l'autre)

	if m.lnParm > 0
		for liParm = 1 to m.lnParm
			luParm = evaluate(this.Test_cParm(m.liParm)) && Valeur du paramètre
			this.aTest[m.this.nTest, NCOLSFIXES + m.liParm] = iif(vartype(m.luParm) == 'C';
				, '"' + m.luParm + '"';
				, cLitteral(m.luParm);
				)
		endfor
	endif

* Exécuter le test
* ===========================
	luResult = this.Test_Exec(; && si le résultat est objet, littéral de cet objet
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

	* Tabuler le résultat du test
	local lcStatus
	this.aTest[m.this.nTest, 1] = this.lCoverage && Coverage ON
	this.aTest[m.this.nTest, 2] = m.lnElapsed && Temps d'exécution (non significatif si COVERAGE)
	this.aTest[m.this.nTest, 3] = empty(pcount()) or isNull(m.tuExpected) or luEqual(iif(vartype(m.tuExpected ) == 'O', cL(m.tuExpected), m.tuExpected), m.luResult) && Valeur produite = valeur attendue && Empty(m.tuExpected) OR
	this.aTest[m.this.nTest, 4] = m.tuExpected && Résultat attendu
	this.aTest[m.this.nTest, 5] = m.luResult && Résultat produit
	this.aTest[m.this.nTest, 6] = this.lStatus(@m.laStatus1, @m.laStatus2, @m.lcStatus) && Environnement modifié ?
	this.aTest[m.this.nTest, 7] = m.lcStatus && Modification d'environnement éventuelle
endif

return m.luResult

* -----------------------------------
procedure assert && Teste une valeur (par exemple élément d'un tableau résultat)
lparameters ;
	tuExpected,; && @ Résultat attendu
	tuValue && @ Valeur à tester

if pcount() >= 2

	this.aTest[m.this.nTest, 3] = luEqual(@m.tuExpected, @m.tuValue) && Valeur produite == valeur attendue

	assert m.this.aTest[m.this.nTest, 3] message cAssertMsg(textmerge(icase(;
		cLangUser() = 'fr',	[Échec d'assertion au test n° <<m.this.nTest>> - résultat attendu: <<cL(m.tuExpected)>>, obtenu: <<cL(m.tuValue)>>],; && copy-paste this line to add another language support
		 										[Assertion failed at test # <<m.this.nTest>> - result expected: <<cL(m.tuExpected)>>, obtained: <<cL(m.tuValue)>>]; && Default: English
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
hidden function Test_cParm && Nom d'un paramètre selon sa position
lparameters tiParm && Position du paramètre

return 'tuParm' + padl(m.tiParm, 2, '0')

* -----------------------------------
hidden procedure Test_cParms && Liste de paramètres à passer au module testé
lparameters ;
	tnParms && Nombre de paramètres passés à this.test()

local lcResult && Liste de paramètres
lcResult = space(0)

if m.tnParms > 0

	* Pour chaque paramètre passé
	local liParm, lcParm
	for liParm = 1 to m.tnParms

		* Reconstituer le nom du paramètre
		lcParm = '@' + this.Test_cParm(m.liParm)

		* Ajouter au résultat en passant par référence
		lcResult = c2Words(m.lcResult, ',', m.lcParm)
	endfor
endif

return m.lcResult

* -----------------------------------
hidden procedure Test_Exec && Exécute le test du module
lparameters ;
	tcParms,; && Chaîne de paramètres à passer au module testé
	tnElapsed,; && @ Temps d'exécution en millisecondes
	taStatus1,; && @ Environnement avant exécution du test
	taStatus2,; && @ Environnement après exécution du test
	tuParm01,tuParm02,tuParm03,tuParm04,tuParm05,tuParm06,tuParm07,tuParm08,tuParm09,tuParm10,tuParm11,tuParm12,tuParm13,tuParm14

external array taStatus1, taStatus2

local luResult as Variant; && Résultat du module testé
, lnParm, liParm, lcParm, lcParm_;
, lnRows, lnCols;
, lcArray;
, lnAttempt;
, liAttempt;
, lnSeconds;

* Sauvegarder les paramètres
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

	* Si c'est le premier test
	if m.lnAttempt = 1

		* Mémoriser l'environnement VFP AVANT l'exécution
		this.aStatus(@m.taStatus1)

		* Si le coverage a été demandé, le démarrer
		if m.this.lCoverage
			local lcCoverage
			lcCoverage = set('COVERAGE', 1)
			set coverage to (m.this.cCoverageAddr) additive
		endif
	endif

	tnElapsed = 0
	for liAttempt = 1 to m.lnAttempt

		* Restaurer les paramètres
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

* Exécuter la procédure / fonction
* ===========================================================
		lnSeconds = seconds()
		luResult = evaluate(this.cModule + '(' + m.tcParms + ')')
		tnElapsed = m.tnElapsed + nMS(m.lnSeconds) && millisecondes
* ===========================================================

	endfor

	luResult = iif(vartype(m.luResult) == 'O'; && exécute .Destroy()
		, cL(m.luResult);
		, m.luResult;
		)

	* Si c'est le premier test
	if m.lnAttempt = 1

		* Si le coverage a été demandé, l'arrêter
		if this.lCoverage
			set coverage to &lcCoverage
		endif

		* Mémoriser l'environnement VFP après l'exécution
		this.aStatus(@m.taStatus2)
	endif

	* Si le temps d'exécution est significatif, terminer
	if .f.;
	 or m.this.lCoverage;  && avec Coverage, une seule exécution
	 or m.this.lSingleTest; && simple test demandé
	 or m.tnElapsed > 2 && && millisecondes (précision au moins 5%)

		exit

	* sinon, répéter le test
	else
		lnAttempt = m.lnAttempt * 10
	endif
enddo

tnElapsed = m.tnElapsed / m.lnAttempt


* this.lSingleTest = .F.

return m.luResult

* -----------------------------------
hidden procedure Test_aTestsDim && Dimensionne le tableau des résultats pour recevoir ceux du dernier test
lparameters tnParms && Nombre de paramètres passés pour le test courant

local lnCols
lnCols = alen(this.aTest, 2)

* Ajouter une nouvelle LIGNE au tableau de test
dimension this.aTest[m.this.nTest, m.lnCols]

* Si nouveaux paramètres,
local lnColsParms
lnColsParms = NCOLSFIXES + m.tnParms
if m.lnColsParms > m.lnCols

	* Ajouter le nombre de COLONNES nécessaires au tableau résultat
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
hidden procedure ResultOut && Sort le résultat des test à l'écran et dans le log de test

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
hidden function cResult && Résultat de test(s)

local lcResult
lcResult = space(0)

* Si le module est défini
if .t.;
 and vartype(this.cModule) == 'C' ;
 and not empty(this.cModule)

	* Si des tests ont été réalisés sur le module
	if m.this.nTest > 0

		* Pour chaque test réalisé
		local lnCoverage, lnElapsed, lnElapsedMin, lnElapsedMax, lnElapsedAvg, lnSuccess
		lnElapsedMin = 10^10
		store 0 to m.lnCoverage, m.lnElapsedMax, m.lnElapsedAvg, m.lnSuccess
		local lnTest
		for lnTest = 1 to this.nTest

			* Synthétiser les résultats
			if this.aTest[m.lnTest, 1] && les temps d'exécution avec COVERAGE ON ne sont pas significatifs
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

		* Rectifier le temps moyen en cas de coverage sur certains tests
		local lnCoverageLess
		lnCoverageLess = this.nTest - m.lnCoverage
		if m.lnCoverageLess > 0
			lnElapsedAvg = m.lnElapsedAvg / m.lnCoverageLess
		endif

		* Compter les échecs
		local lnFailure
		lnFailure = this.nTest - m.lnSuccess

		text TO m.lcResult TEXTMERGE NOSHOW FLAGS 1
===========================================
<<Datetime()>>
Module : <<DisplayPath(m.this.cAddress, 50)>>!<<this.cModule>>()
Résultats de <<m.this.nTest>> test<<Iif(this.nTest = 1, Space(0), 's')>> dont <<m.lnCoverage>> avec coverage dans '<<m.this.cCoverageAddr>>'
<<Iif(m.lnCoverageLess > 0, "Temps d'exécution sans coverage Mini | Moyen | Maxi : " + this.cMS(m.lnElapsedMin) + '|' + this.cMS(m.lnElapsedAvg) + '|' + this.cMS(m.lnElapsedMax), Space(0))>>

		ENDTEXT

		* Si au moins un test a réussi
		if m.lnSuccess > 0

			text TO m.lcResult ADDITIVE TEXTMERGE NOSHOW FLAGS 1
---------------------------------------------
<<m.lnSuccess>> <<Iif(m.lnSuccess = 1, "test réalisé", "tests réalisés")>> avec succès

			ENDTEXT
		endif

		* Si au moins un test a échoué
		this.lResult = m.lnFailure = 0
		if not this.lResult
			text TO m.lcResult ADDITIVE TEXTMERGE NOSHOW FLAGS 1
---------------------------------------------
<<m.lnFailure>> <<Iif(m.lnFailure = 1, "test a échoué", "tests ont échoué")>> :

			ENDTEXT

			local lnParms, liParm, lcParms;
			, llString, liString, lcString

			* Pour chaque test échoué
			for lnTest = 1 to this.nTest
				do case

				* Cas où l'échec est dû à un mauvais résultat
				case not m.this.aTest[m.lnTest, 3]

					* S'il y en a des paramètres, lister leurs valeurs sous forme de constantes
					lnParms = this.aTest[m.lnTest, NCOLSFIXES]
					lcParms = space(0)
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

					* écrire le n° de test, les résultats attendus et obtenus, les paramètres
					local lcType
					lcType = vartype(this.aTest[m.lnTest, 5])
					text TO m.lcResult ADDITIVE TEXTMERGE NOSHOW FLAGS 1
- Test n° : <<Transform(m.lnTest)>>
	Resultats :
	- attendu:	<<Iif(m.llString, '"' + this.aTest[m.lnTest, 4] + '"', cLitteral(this.aTest[m.lnTest, 4]))>>
	- obtenu :	<<ICase(m.lcType == 'C' and Lower(Leftc(this.aTest[m.lnTest, 5], Len('Object '))) == Lower('Object '), this.aTest[m.lnTest, 5], m.lcType == 'C', '"' + this.aTest[m.lnTest, 5] + '"', cLitteral(this.aTest[m.lnTest, 5]))>>
	<<m.lcString>><<m.lnParms>> paramètres passés<<Iif(m.lnParms > 0, ' :', '')>><<m.lcParms>>

					ENDTEXT

				* Cas où l'échec est dû à une modification d'environnement
				case not this.aTest[m.lnTest, 6]

					* écrire la variable d'environnement modifiée
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
hidden function cMS && Temps en avec unité millisecondes
lparameters tnMS && Temps en millisecondes
return space(1) + ltrim(transform(m.tnMS, '9,999.999  ms'))

* -----------------------------------
hidden function aStatus && Environnement Visual FoxPro
lparameters taStatus && @ Tableau de statut

local lnStatus, lcStatus, laUsed[1], lnResult && Nombre d'éléments d'environnement

* Tabuler les éléments de statut
lnResult = alines(m.taStatus, this.cStatus(), .t.)
aColsIns(@m.taStatus) && ajoute une colonne pour les résultats

* Pour chaque élément de statut valide
for lnStatus = 1 to m.lnResult

	lcStatus = m.taStatus[m.lnStatus, 1]
	if not lCommentLine(m.lcStatus)

		* Évaluer
		try
			taStatus[m.lnStatus, 2] = evaluate(m.lcStatus)
		catch
		endtry
	endif
endfor

return m.lnResult

external procedure lCommentLine && dans abModuleDir.prg

* -----------------------------------
hidden function cStatus && Environnement Visual FoxPro
local lcResult

text TO m.lcResult NOSHOW PRETEXT 1+2+4

* Nombre de tables ouvertes
AUsed(laUsed)

* Zone de travail courante
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

* Sets
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
* Set("Function") && je ne sais pas comment ça marche
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
hidden function lStatus && Compare deux environnements VFP
lparameters ;
	taStatus1,; && @ Tableau de statut 1 (créé par this.aStatus())
	taStatus2,; && @ Tableau de statut 2 (créé par this.aStatus())
	tcModifs && @ Éléments d'environnement ayant évolué (si m.llResult = .F.)

local llResult && L'environnement VFP est identique
llResult = .null.
tcModifs = space(0)

* Si le statut a bien été tabulé après test
local lnStatusCount
lnStatusCount = alen(m.taStatus1, 1)
if alen(m.taStatus2, 1) = m.lnStatusCount

	* Pour chaque élément d'environnement
	local lnStatus, llStatus
	llResult = .t.
	for lnStatus = 1 to m.lnStatusCount

		* Si l'élément n'a pas la même valeur dans les 2 tableaux
		llStatus = m.taStatus1[m.lnStatus, 2] == m.taStatus2[m.lnStatus, 2]
		if not m.llStatus

			* Ajouter la modification au message retourné
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

* Sortir le résultat si ça n'a pas été fait
if not this.lResultOut
	this.ResultOut()
endif

* Fermer proprement les Aliases ouverts pour le(s) test(s)
local laAlias[1], lcAlias
if aused(m.laAlias) > 0
	for each lcAlias in laAlias
		use in (m.lcAlias)
	endfor
endif

* =============================================
enddefine && CLASS abUnitTest
* =============================================

* -----------------------------------
function FooTest && Bidon pour démontrer la classe de test abUnitTest
lparameters tuFoo

local lcType, luResult
lcType = vartype(m.tuFoo)

do case

case m.lcType == 'C' && échec car changement de Set("Deleted")
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

*------------------------------------
function Fox2Pix && foxels to pixels && courtesy Sergey Berezniker http://www.berezniker.com/content/pages/visual-foxpro/pixels-and-foxels
lparameters ;
	tnFoxels,; && foxels to convert
	tlVertical,; && vertical coordinates
	tcFontName,; && [current form's] font name
	tnFontSize && [current form's] font size

return iif(pcount() >= 4;
	, m.tnFoxels * fontmetric(iif(m.tlVertical, 1, 6), m.tcFontName, m.tnFontSize);
	, m.tnFoxels * fontmetric(iif(m.tlVertical, 1, 6));
	)

*------------------------------------
function Pix2Fox && pixels to foxels && courtesy Sergey Berezniker http://www.berezniker.com/content/pages/visual-foxpro/pixels-and-foxels
lparameters ;
	tnPixels,; && pixels to convert
	tlVertical,; && vertical coordinates
	tcFontName,; && [current form's] font name
	tnFontSize && [current form's] font size

local lnResult, llResult

lnResult = iif(pcount() >= 4;
	, m.tnPixels / fontmetric(iif(m.tlVertical, 1, 6), m.tcFontName, m.tnFontSize);
	, m.tnPixels / fontmetric(iif(m.tlVertical, 1, 6));
	)

llResult = between(m.lnResult, -32768+1, 32767-1) && 19/12/13 - Invalid coordinates (Error 1959) Coordinate values must be greater than -32768 and less than 32767
assert m.llResult message cAssertMsg(textmerge([<<m.lnResult>> from: <<m.tnPixels>>px <<Iif(m.tlVertical, 'Vertical', 'Horizontal')>>, Font: <<Evl(m.tcFontName, .null.)>> <<Evl(m.tnFontSize, .null.)>>pt]))

return iif(m.llResult;
	, m.lnResult;
	, 0;
	)

* ==============================
function cExprEval && Expression pour évaluer une expression
lparameters tcExpr && Expression

local laOp[1], lcOp, lcOpU, lcExpr, lcResult
store space(0) to lcExpr, lcResult

* Pour chaque opérande de l'expression
if alines(laOp, m.tcExpr, 1, '+') > 0
	for each lcOp in laOp

		* Si l'opérande est un Chr()
		lcOpU = chrtran(upper(m.lcOp), space(1), space(0))
		if left(m.lcOpU, 4) == 'CHR(' or inlist(m.lcOpU, 'CR', 'CRLF')

			* Ajouter les opérandes accumulés au résultat
			lcResult = cWords('+', m.lcResult, cExprEval_cOp(m.lcExpr), m.lcOp)
			lcExpr = space(0)
		else
			lcExpr = c2Words(m.lcExpr, '+', m.lcOp)
		endif
	endfor
	lcResult = c2Words(m.lcResult, '+', cExprEval_cOp(m.lcExpr))
endif

return m.lcResult

* -----------------------------
function cExprEval_cOp && Adapte un opérande d'une expression
lparameters tcOp && Opérande

return iif(empty(m.tcOp), space(0), textmerge([cLitteral(Evaluate(<<cLitteral(m.tcOp)>>))]))

* ==============================
function uEval && Expression évaluée si possible
lparameters tcExpr

local luResult

try
	luResult = evaluate(m.tcExpr)
catch
	luResult = m.tcExpr
endtry

return m.luResult

* ==============================
function cIndented && Texte indenté
lparameters ;
	tcCode,; && Texte à indenter
	tcIndent,; && [tab] Caractère(s) d'indentation
	tlEmptyDel,; && [.F.] Supprimer les lignes vides
	tcCharEOL && [''] Caractère de fin de ligne
tcCode = iif(vartype(m.tcCode) == 'C', m.tcCode, '')
tcIndent = iif(vartype(m.tcIndent) == 'C' and lenc(m.tcIndent) > 0, m.tcIndent, chr(9)) && Evl() ne marche pas sur space() et tab
tlEmptyDel = lTrue(m.tlEmptyDel)
tcCharEOL = evl(m.tcCharEOL, space(0))

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
				strtran(strtran(iif(m.tlEmptyDel, cRepCharDel(m.tcCode, LF), m.tcCode); && LF $ m.tcCode, memo par exemple
					, m.tcCharEOL + LF, m.tcCharEOL + LF + m.tcIndent);
					, LF + m.tcIndent + LF, LF2);
			);
		, cRepCharDel(m.tcIndent);
		)

* ==============================
function cIndentedNo && Texte non indenté && /!\ à modifier pour fonctionner en multi-lignes
lparameters tcCode

return ltrim(icase(;
		CRLF $ m.tcCode,;
			strtran(strtran(m.tcCode, CRLF + TABUL, CRLF), CRLF + space(1), CRLF),;
		CR $ m.tcCode,;
			strtran(strtran(m.tcCode, CR + TABUL, CR), CR + space(1), CR),;
			strtran(strtran(m.tcCode, LF + TABUL, LF), LF + space(1), LF); && memo par exemple
		), TABUL, space(1))

* ==============================
function cCommented && Instruction(s) commentée(s)
lparameters ;
	tcCode,; && Instruction(s)
	tcCom,; && [* ] caractère de commentaire
	tlEmptyDel && [.F.] Supprimer les lignes vides
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
						strtran(iif(m.tlEmptyDel, cRepCharDel(m.tcCode, LF), m.tcCode), LF, LF + m.tcCom); && memo par exemple
					), m.tcCom); && ? Trim('totu', 'tu') && 'to'
		, m.tcCom + CRLF, CRLF); && les lignes vides ne sont pas commentées
		, m.tcCom + CR, CR); && les lignes vides ne sont pas commentées
		, m.tcCom + LF, LF); && les lignes vides ne sont pas commentées
	)

* ==============================
function lDevMode && Mode développement
return _vfp.startmode = 0;
 and not inlist(lower(justext(cModuleInfo(sys(16, 0), 'Address'))), 'app', 'exe')

* ===================================================================
function cAssertMsg && MESSAGE pour ASSERT limité à 120 caractères sous les IDE non-US
lparameters tcMsg
tcMsg = ltrim(evl(nvl(m.tcMsg, ''), 'empty message?'))

local lcProgram

lcProgram = proper(program(program(-1)-1)) && back compat.

?? chr(7) && ding && ?? pour ne pas ajouter une ligne à la fenêtre qui a le focus

return cTronc('';
    + iif(lower(left(m.tcMsg, len(m.lcProgram))) == lower(m.lcProgram);
			, '';
			, cResultHeader(-2);
			);
	  + m.tcMsg;
	, iif(version(3) == '00'; && 00 - English - 14/06/12 - crédit Francis Faure - http://www.atoutfox.org/nntp.asp?ID=0000009184
		, 254; && http://www.atoutfox.org/nntp.asp?ID=0000009201
		, 120;
		);
	, .t.; && split on a word end
	)

* =============================================
define class abVoid as custom
	procedure init
	return .f.
enddefine && CLASS abVoid

* =============================================
procedure lSetProcedure && a Set("Procedure") is in current Set("Procedure")
lparameters tcSetProcedure && Set("Procedure") antérieur
return setProcedure(m.tcSetProcedure, .t.)

* =============================================
procedure setProcedure && Restores previous Set("Procedure")
lparameters ;
	tcSetPro_,; && Set("Procedure") antérieur
	tlCheck,; && [.F.] Vérifier si Set("Procedure") antérieur est dans Set("Procedure") courant
	tlAdditive && [.F.] Ajouter tcSetPro_ à Set("Procedure") courant

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
procedure SetProcClassRestore as Boolean && restores Set("Classlib") or Set("Procedure") to a previous value
lparameters ;
  tcSetAnte as string; && previous Set("Classlib") or Set("Procedure")
, tlClassLib as Boolean && [.F.] tcSetAnte is Set("Classlib")

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

	* Remove unused files
	for each lcFile in m.laFilePost
		try
			do case
			case ascan(m.laFileAnte, m.lcFile, 1, -1, 1, 7) > 0
&& in previous Set()
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
&& do not remove this file, we currently use it
			otherwise
				release procedure &lcFile
			endcase
		catch
		endtry
	endfor

	* Add previous files no longer in Set("Classlib") or Set("Procedure")
	for each lcFile in m.laFileAnte
		try
			do case
			case ascan(m.laFilePost, m.lcFile, 1, -1, 1, 7) > 0
&& already in Set()
			case !file(alltrim(iif(m.tlClassLib;
				, trim(substrc(m.lcFile, 1, at_c('ALIAS', m.lcFile)-1));
				, m.lcFile;
				), '"', "'"))
&& File can't be found
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
function cResultAdd && Ajoute une entrée à un résultat cumulatif
lparameters ;
  tcResult; && @ résultat cumulatif
, tuItem; && élément à ajouter au résultat - type 'N': assumes Seconds() for execution time tracking
, tlLine; && [.F.] Sauter une ligne au lieu de 2
, tlPrepend; && [.F.] Ajouter au début
, tnStackMinus; && [0] nombre de niveaux de pile à retrancher - .T.: ne pas ajouter l'en-tête
, tlDateTime; && [.F.] add date-time header

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

	tuItem = '';
		+ iif(left(m.tuItem, lenc(m.lcHeader)) == m.lcHeader, '', m.lcHeader);
		+ m.tuItem

	tcResult = '';
		+ iif(lTrue(m.tlPrepend);
		  , c2Words(m.tuItem, iif(m.tlLine, CRLF, CRLF2), m.tcResult);
		  , c2Words(m.tcResult, iif(m.tlLine, CRLF, CRLF2), m.tuItem);
		  )

endif

return .f. && impératif

* ===================================================================
function cResultHeader && En-tête standard d'un résultat
lparameters ;
  tnStackOffset; && [-1]
, tlDateTime; && [.F.] add date-time header

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

* =============================================
function lUserAnAdmin as Variant && Current user is a member of the Administrators group
lparameters result as string && @

local success as Variant

try

	declare integer IsUserAnAdmin in Shell32

	#if .f.
		IsUserAnAdmin function && http://msdn.microsoft.com/en-us/library/bb776463.aspx
		Minimum supported client: windows XP [desktop apps only]
		Minimum supported server: windows server 2003 [desktop apps only]
		end of client support: windows Vista && because of UAC I guess - looks good on Windows 7!
		end of server support: windows server 2008
	#endif

	success = IsUserAnAdmin() # 0
catch
	success = .null. && IsUserAnAdmin() is not supported, we don't know
endtry

result = iif(isNull(m.success);
	, textmerge('';
		+ [<<Proper(Program())>>() ];
		+ icase(;
				cLangUser() = 'fr',	[n'a pu déterminer si le compte utilisateur courant '<<GetEnv("USERNAME")>>' est un administrateur car],; && copy-paste this line to add another language support
														[could not determine whether current user account '<<GetEnv("USERNAME")>>' is an administrator because]; && Default: English
				);
		+ ' ';
		+ iif(lUAC(); && Windows > Vista / Server 2008 - end of support of lUserAnAdmin()/IsUserAnAdmin() function according to http://msdn.microsoft.com/en-us/library/bb776463.aspx
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
function lUAC as Boolean && Current Windows version supports UAC
return val(getwordnum(os(1), 2)) > 6.0
endfunc

* ========================================
procedure ProceduresAdd && Ajoute des fichiers prg au Set("Procedure")
lparameters tcPrgMask && [*.prg] Masque de fichier prg

local lcPrgMask, laPrgs[1], lnPrgs, lnPrg, lnResult && Nombre de fichiers prg ajoutés

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
procedure ProcedureAdd && Ajoute un fichier prg à Set("Procedure") s'il n'y est déjà
lparameters ;
	tcPrg,; && fichier prg
	tlRemove && [.F.] Ôter de Set("Procedure")

local llResult && le fichier a été ajouté ou ôté selon la demande
if vartype(m.tcPrg) == 'C' and file(m.tcPrg) and inlist(upper(justext(m.tcPrg)), 'PRG', 'FXP')

	tcPrg = fullpath(forceext(m.tcPrg, 'FXP'))
	tlRemove = lTrue(m.tlRemove)

	if '"' + m.tcPrg + '"' $ set("Procedure")
		if m.tlRemove
			release procedure (m.tcPrg)
			llResult = .t.
		endif
	else
		if not m.tlRemove
			set procedure to (m.tcPrg) additive
			llResult = .t.
		endif
	endif
endif

return m.llResult

* ========================================
procedure ClassLibRemove && Ôte un fichier vcx de Set("ClassLib") s'il y est
lparameters tcVCX && fichier vcx

return ClassLibAdd(m.tcVCX, .t.)

* ========================================
procedure ClassLibAdd && Ajoute un fichier vcx à Set("ClassLib") s'il n'y est déjà
lparameters ;
	tcVCX,; && fichier(s) vcx
	tlRemove && [.F.] RELEASE CLASSLIB

local laVCX[1], lcVCX, llSet, lcAlias, llResult && le fichier a été ajouté ou retiré

if .t.;
 and vartype(m.tcVCX) == 'C';
 and alines(laVCX, m.tcVCX, 5, ',', ';') > 0

 	for each lcVCX in m.laVCX

		lcAlias = upper(juststem(m.lcVCX))
		llSet = ' ALIAS ' + m.lcAlias + ',' $ set("Classlib") + ','
		if lTrue(m.tlRemove)
			if m.llSet
				release classlib (m.lcVCX)
				llResult = .t.
			endif
		else
			if not m.llSet and file(m.lcVCX)
				set classlib to (m.lcVCX) additive
				llResult = .t.
			endif
		endif
 	endfor
endif

return m.llResult
endproc

* ========================================
function Sys3 && Sys(3) unique même sur une machine rapide
local Sys3
Sys3 = sys(3)
do while m.Sys3 == sys(3)
enddo
return m.Sys3
endfunc

* ========================================
function Sys2015 && Sys(2015) unique même sur une machine rapide - alias de cSys2015Unique()
local Sys2015
Sys2015 = sys(2015)
do while m.Sys2015 == sys(2015)
enddo
return m.Sys2015
endfunc

* ========================================
function cSys2015Unique && Sys(2015) unique même sur une machine rapide - alias de Sys2015()
return Sys2015()
endfunc

* ========================================
procedure varStore(out, in) as Boolean && assigne une variable - alias de varSet()
store m.in to out && http://blogs.msdn.com/b/calvin_hsia/archive/2004/12/14/301282.aspx - Calvin: the STORE command doesn't do as much as the "x=y" command. More in a future blog.
endproc

* =============================================
procedure varSet(out, in) as Boolean && assigne une variable - alias de varStore()
store m.in to out && http://blogs.msdn.com/b/calvin_hsia/archive/2004/12/14/301282.aspx - Calvin: the STORE command doesn't do as much as the "x=y" command. More in a future blog.
endproc

* =============================================
function iInc(int, inc) as integer && incrémente une variable
int = m.int + evl(m.inc, 1)
return m.int
endproc

* =============================================
procedure setStepOn(condition as Boolean) as Boolean
if (cast(m.condition as L) or empty(pcount())) && and lDevMode() useless
	set step on
endif
endproc

* =============================================
function abCoverage && Lance un historique d'exécution && Alias de oCoverage()
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
function oCoverage && Lance un historique d'exécution
lparameters ;
  condition as Boolean; && [.T.] {fr} condition pour lancer le coverage
, lAdditive as Boolean; && [.F.] {en} Add to the same file
, lProduction as Boolean; && [.F.] {fr} Forcer le Coverage en mode production

* loCoverage = oCoverage([condition]) && {en} Starts log {fr} Commence l'historique
* 	--<{en} code you want to trace {fr} Code que vous voulez tracer >--

* loCoverage = .null. && {en} Stops log {fr} Arrête l'historique

if .t.;
 and (empty(pcount()) or lTrue(m.condition));
 and (lDevMode() or lTrue(m.lProduction))

	lAdditive = lTrue(m.lAdditive)

	local lcFile as string

	lcFile = '';
		+ lower(cModuleInfo(sys(16,0), 'Address')); && root program
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
function RC4(cTexte, cClef)

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
function cObjectCamelCase && Nom ou adresse d'objet où les abréviations des classes sont en casse mixte
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
function nEvl(uValue, notEmpty, typeForce) && substitute value instead of not empty value
return icase(;
	!empty(m.uValue),;
		m.notEmpty,;
	lTrue(m.typeForce),;
		uEmpty(vartype(m.notEmpty)),;
		m.uValue;
	)
endfunc

* =============================================
function nNvl && substitute value instead of a not null value
lparameters value, substitute
return iif(isNull(m.value), m.value, m.substitute)
endfunc

* =============================================
function isNullOrEmpty && null or empty value
lparameters value
return !vartype(m.value) == 'O' and empty(nvl(m.value, .f.))
endfunc
* --------------------------------------------
function isEmptyOrNull && empty or null value
lparameters value
return isNullOrEmpty(m.value)
endfunc

* =============================================
function envl && substitute value instead of an empty or null value
lparameters value, substitute
return iif(isNullOrEmpty(m.value), m.substitute, m.value)
endfunc

* =============================================
function nENvl && substitute value instead of not empty and not null value
lparameters value, substitute
return iif(isNullOrEmpty(m.value), m.value, m.substitute)
endfunc

* =============================================
function EvlNull && turns empty value into .null.
lparameters value
return iif(!vartype(m.value) == 'O' and empty(m.value), .null., m.value)
endfunc

* =============================================
function lTrue && a value is .T.
lparameters value && if @, .T./.F.
value = vartype(m.value) == 'L' and m.value
return m.value
endfunc
* =============================================
function lFalse && a value is .F.
lparameters value && if @, .T./.F.
value = vartype(m.value) == 'L' and !m.value
return m.value
endfunc

#if .f. && https://raw.githubusercontent.com/npm/node-semver/master/semver.js

#endif

* =============================
function cSemVer as String && {en} SemVer of a version string
lparameters ;
  result as string; && @ résultat (cumulatif)
, version as string; && version à analyser
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
  result as string; && @ résultat (cumulatif)
, version as string; && version à analyser
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
  result as string; && @ résultat (cumulatif)
, version as string; && version à analyser
, loose as Boolean; && [.F.]

if vartype(m.version) # 'C'
	loose = m.version
	version = m.result
endif

return createobject('abSemVer', @m.result, m.version, m.loose)
endfunc

* -----------------
function labSemVer && c'est un objet de la classe abSemVer
lparameters oSemVer as Variant
return loClass(m.oSemVer, 'abSemVer')
endfunc

* -----------------
function iSemVerMMP && ordre de classement de versions SemVer sur majeur-mineur-patch (ignorant les pre-releases)
lparameters ;
  result as string; && @ résultat (cumulatif)
, version as string; && version à analyser
, loose as Boolean; && [.F.]

local oSemVer as abSemVer

oSemVer = abSemVer(@m.result, m.version, m.loose)

return Iif(labSemVer(m.oSemVer);
	, m.oSemVer.versionMMPint;
	, .null.;
	)
endfunc

* =============================
define class abSemVer as GA_LIGHTWEIGHT_CLASS of abGA.prg && Implements Semantic Versioning 2.0.0 http://semver.org/ - inspired by https://github.com/npm/node-semver/
* =============================

MAX_LENGTH = 256
MAX_SAFE_INTEGER = 2^31 - 1 && VFP limitation

oPattern = .null. && CreateObject('Empty') && statement is not valid is a class definition
oRegExpr = .null.

tildeTrimReplace = '$1~'
caretTrimReplace = '$1^'
comparatorTrimReplace = '$1$2$3'

loose = .null.
raw = .null.
version = .null.

&& these are actually numbers
major = .null.
minor = .null.
patch = .null.

dimension prerelease[1], build[1]
prerelease = .null. && array of prerelease(s) identifier(s) and number(s) && keep as lower case
build = .null. && array of build numbers

&& FoxInCloud extensions
&& these are actually logical
lMajor = .null. && major release
lMinor = .null. && minor release
lPatch = .null. && patch release
lPreRelease = .null. && pre-release (beta)
versionMMP = .null. && version Major.Minor.Path (without prerelease(s))
versionMMPint = .null. && version Major.Minor.Path in integer
versionIS = .null. && version for InstallShield

* -----------------
procedure Init
lparameters ;
  result as string; && @ résultat (cumulatif)
, version as string; && version à analyser
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
  result as string; && @ résultat (cumulatif)
, version as string; && [this.raw] version à analyser
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

&& these are actually numbers
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

this.lMajor = empty(m.this.minor) && major release
this.lMinor = !this.lMajor and empty(m.this.patch) && minor release
this.lPatch = m.this.patch > 0 && patch release

&& pre-release; http://semver.org/
&& A pre-release version MAY be denoted by appending a hyphen and a series of dot separated identifiers immediately following the patch version; identifiers:
&& - MUST comprise only ASCII alphanumerics and hyphen [0-9A-Za-z-].
&& - MUST NOT be empty.
&& Numeric identifiers MUST NOT include leading zeroes.
&& Pre-release versions have a lower precedence than the associated normal version.
&& A pre-release version indicates that the version is unstable and might not satisfy the intended compatibility requirements as denoted by its associated normal version.
&& Examples: 1.0.0-alpha, 1.0.0-alpha.1, 1.0.0-0.3.7, 1.0.0-x.7.z.92.
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
					+ Cast(Cast(Substr(m.cPreReleases, m.iPreRelease + 1) as I) as  m) && removes leading 0 if any
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
procedure format

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
hidden procedure Init_RegExp && Initializes Regular Expressions are used for tokenizing, validating and parsing abSemVer version strings
lparameters result as string; && @ résultat (cumulatif)

this.oPattern = createobject('Empty')
this.oRegExpr = createobject('Empty')

&& ## Numeric Identifier
&& A single `0`, or a non-zero digit followed by zero or more digits.

addproperty(this.oPattern, 'NUMERICIDENTIFIER', '0|[1-9]\d*')
addproperty(this.oPattern, 'NUMERICIDENTIFIERLOOSE', '[0-9]+')

&& ## Non-numeric Identifier
&& Zero or more digits, followed by a letter or hyphen, and then zero or
&& more letters, digits, or hyphens.

addproperty(this.oPattern, 'NONNUMERICIDENTIFIER', '\d*[a-zA-Z-][a-zA-Z0-9-]*')

&& ## Main Version
&& Three dot-separated numeric identifiers.

addproperty(this.oPattern, 'MAINVERSION', '';
	+ '(' + this.oPattern.NUMERICIDENTIFIER + ')\.';
	+ '(' + this.oPattern.NUMERICIDENTIFIER + ')\.';
	+ '(' + this.oPattern.NUMERICIDENTIFIER + ')';
	)

addproperty(this.oPattern, 'MAINVERSIONLOOSE', '';
	+ '(' + this.oPattern.NUMERICIDENTIFIERLOOSE + ')\.';
	+ '(' + this.oPattern.NUMERICIDENTIFIERLOOSE + ')(?:\.'; && thn 2015-09-25 back compat.: allow for patch figure missing (eg. '2.20beta')
	+ '(' + this.oPattern.NUMERICIDENTIFIERLOOSE + '))?';
	)

&& ## Pre-release Version Identifier
&& A numeric identifier, or a non-numeric identifier.

addproperty(this.oPattern, 'PRERELEASEIDENTIFIER', '(?:' + this.oPattern.NUMERICIDENTIFIER + '|' + this.oPattern.NONNUMERICIDENTIFIER + ')')
addproperty(this.oPattern, 'PRERELEASEIDENTIFIERLOOSE', '(?:' + this.oPattern.NUMERICIDENTIFIERLOOSE + '|' + this.oPattern.NONNUMERICIDENTIFIER + ')')

&& ## Pre-release Version
&& Hyphen, followed by one or more dot-separated pre-release version identifiers.

addproperty(this.oPattern, 'PRERELEASE', '(?:-(' + this.oPattern.PRERELEASEIDENTIFIER + '(?:\.' + this.oPattern.PRERELEASEIDENTIFIER + ')*))')
addproperty(this.oPattern, 'PRERELEASELOOSE', '(?:[-\. ]?(' + this.oPattern.PRERELEASEIDENTIFIERLOOSE + '(?:\.' + this.oPattern.PRERELEASEIDENTIFIERLOOSE + ')*))') && 2015-09-25 thn InstallShield support: prerelease is a number separated by '.' from main version

&& ## Build Metadata Identifier
&& Any combination of digits, letters, or hyphens.

addproperty(this.oPattern, 'BUILDIDENTIFIER', '[0-9A-Za-z-]+')

&& ## Build Metadata
&& Plus sign, followed by one or more period-separated build metadata
&& identifiers.

addproperty(this.oPattern, 'BUILD', '(?:\+(' + this.oPattern.BUILDIDENTIFIER + '(?:\.' + this.oPattern.BUILDIDENTIFIER + ')*))')

&& ## Full Version String
&& A main version, followed optionally by a pre-release version and
&& build metadata.

&& Note that the only major, minor, patch, and pre-release sections of
&& the version string are capturing groups.  The build metadata is not a
&& capturing group, because it should not ever be used in version
&& comparison.

FULLPLAIN = 'v?' + this.oPattern.MAINVERSION + this.oPattern.PRERELEASE + '?' + this.oPattern.build + '?'

addproperty(this.oPattern, 'FULL', '^' + FULLPLAIN + '$')

&& like full, but allows v1.2.3 and =1.2.3, which people do sometimes.
&& also, 1.0.0alpha1 (prerelease without the hyphen) which is pretty common in the npm registry.
LOOSEPLAIN = '[v=\s]*';
	+ this.oPattern.MAINVERSIONLOOSE;
	+ this.oPattern.PRERELEASELOOSE + '?';
	+ this.oPattern.BUILD + '?'

addproperty(this.oPattern, 'LOOSE', '^' + LOOSEPLAIN + '$')

addproperty(this.oPattern, 'GTLT', '((?:<|>)?=?)')

&& Something like "2.*" or "1.2.x".
&& Note that "x.x" is a valid xRange identifer, meaning "any version"
&& Only the first item is strictly required.
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

&& Tilde ranges.
&& Meaning is "reasonably at or greater than"
addproperty(this.oPattern, 'LONETILDE', '(?:~>?)')

addproperty(this.oPattern, 'TILDETRIM', '(\s*)' + this.oPattern.LONETILDE + '\s+')
addproperty(this.oRegExpr, 'TILDETRIM', abRegExp(this.oPattern.TILDETRIM, 'g'))

addproperty(this.oPattern, 'TILDE', '^' + this.oPattern.LONETILDE + this.oPattern.XRANGEPLAIN + '$')
addproperty(this.oPattern, 'TILDELOOSE', '^' + this.oPattern.LONETILDE + this.oPattern.XRANGEPLAINLOOSE + '$')

&& Caret ranges.
&& Meaning is "at least and backwards compatible with"
addproperty(this.oPattern, 'LONECARET', '(?:\^)')

addproperty(this.oPattern, 'CARETTRIM', '(\s*)' + this.oPattern.LONECARET + '\s+')
addproperty(this.oRegExpr, 'CARETTRIM', abRegExp(this.oPattern.CARETTRIM, 'g'))

addproperty(this.oPattern, 'CARET', '^' + this.oPattern.LONECARET + this.oPattern.XRANGEPLAIN + '$')
addproperty(this.oPattern, 'CARETLOOSE', '^' + this.oPattern.LONECARET + this.oPattern.XRANGEPLAINLOOSE + '$')

&& A simple gt/lt/eq thing, or just "" to indicate "any version"
addproperty(this.oPattern, 'COMPARATORLOOSE', '^' + this.oPattern.GTLT + '\s*(' + LOOSEPLAIN + ')$|^$')
addproperty(this.oPattern, 'COMPARATOR', '^' + this.oPattern.GTLT + '\s*(' + FULLPLAIN + ')$|^$')


&& An expression to strip any whitespace between the gtlt and the thing
&& it modifies, so that `> 1.2.3` ==> `>1.2.3`
addproperty(this.oPattern, 'COMPARATORTRIM', '(\s*)' + this.oPattern.GTLT + '\s*(' + LOOSEPLAIN + '|' + this.oPattern.XRANGEPLAIN + ')')

&& this one has to use the /g flag
addproperty(this.oRegExpr, 'COMPARATORTRIM', abRegExp(this.oPattern.COMPARATORTRIM, 'g'))

&& Something like `1.2.3 - 1.2.4`
&& Note that these all use the loose form, because they'll be
&& checked against either the strict or loose comparator form
&& later.
addproperty(this.oPattern, 'HYPHENRANGE', '^\s*(' + this.oPattern.XRANGEPLAIN + ')' + '\s+-\s+' + '(' + this.oPattern.XRANGEPLAIN + ')' + '\s*$')

addproperty(this.oPattern, 'HYPHENRANGELOOSE', '^\s*(' + this.oPattern.XRANGEPLAINLOOSE + ')' + '\s+-\s+' + '(' + this.oPattern.XRANGEPLAINLOOSE + ')' + '\s*$')

&& Star ranges basically just allow anything at all.
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
protected function lSemVer && c'est un objet de la classe abSemVer
lparameters other as Variant && autre version
return labSemVer(m.other)
endfunc

* -----------------
protected function oSemVer && objet de la classe abSemVer
lparameters other as Variant && autre version
return iif(this.lSemVer(m.other);
	, m.other;
	, abSemVer(m.other, m.this.loose);
	)
endfunc

* -----------------
function compare && compare cette version avec une autre
lparameters other as Variant && autre version
return evl(this.compareMain(@m.other), this.comparePre(@m.other))
endfunc

* -----------------
function compareMinor && compare cette version avec une autre jusqu'à la version mineure en ignorant les patches et les pre-release
lparameters other as Variant && autre version
other = this.oSemVer(m.other)
return iif(this.lSemVer(m.other);
	, evl(;
		  this.compareIdentifiers(this.major, m.other.major);
		, this.compareIdentifiers(this.minor, m.other.minor));
	, .null.;
	)
endfunc

* -----------------
function compareMain && compare les versions principales
lparameters other as Variant && autre version

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
protected function comparePre && compare les versions de pre-release (beta etc.)
lparameters other as Variant && autre version

local comparePre as integer;
, iPreRelease as integer;
, nPreRelThis as integer;
, nPreRelOther as integer;
, uPreRelThis as Variant;
, uPreRelOther as Variant;

comparePre = .null.

other = this.oSemVer(m.other)
if this.lSemVer(m.other)

  * NOT having a prerelease is > having one
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
protected function compareIdentifiers(a, b) && compare les versions principales
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
protected function iBeta
return ascan(m.this.prerelease, 'beta')
endfunc

* -----------------
function lBeta(iBeta) && beta prerelease
iBeta = this.iBeta()
return m.iBeta > 0
endfunc

* -----------------
function nBeta && si beta prerelease, n° de beta
local iBeta
return iif(this.lBeta(@m.iBeta) and alen(this.prerelease) > m.iBeta and vartype(this.prerelease[m.iBeta + 1]) == 'N';
	, this.prerelease[m.iBeta + 1];
	, .null.;
	)
endfunc

* -----------------
function GT(other as Variant) && cette version est supérieure à une autre
return this.compare(m.other) > 0
endfunc

* -----------------
function GTE(other as Variant) && cette version est supérieure ou égale à une autre
return this.compare(m.other) >= 0
endfunc

* -----------------
function LT(other as Variant) && cette version est inférieure à une autre
return this.compare(m.other) < 0
endfunc

* -----------------
function LTE(other as Variant) && cette version est inférieure ou égale à une autre
return this.compare(m.other) <= 0
endfunc

* -----------------
function EQ(other as Variant) && cette version est égale à une autre
return empty(this.compare(m.other))
endfunc

* -----------------
function NEQ(other as Variant) && cette version est différente d'une autre
return !empty(this.compare(m.other))
endfunc

* -----------------
function minorGT(other as Variant) && cette version est supérieure à une autre, au niveau mineur
return this.compareMinor(m.other) > 0
endfunc

* -----------------
function minorGTE(other as Variant) && cette version est supérieure ou égale à une autre, au niveau mineur
return this.compareMinor(m.other) >= 0
endfunc

* -----------------
function minorLT(other as Variant) && cette version est inférieure à une autre, au niveau mineur
return this.compareMinor(m.other) < 0
endfunc

* -----------------
function minorLTE(other as Variant) && cette version est inférieure ou égale à une autre, au niveau mineur
return this.compareMinor(m.other) <= 0
endfunc

* -----------------
function minorEQ(other as Variant) && cette version est égale à une autre, au niveau mineur
return empty(this.compareMinor(m.other))
endfunc

* -----------------
function minorNEQ(other as Variant) && cette version est différente d'une autre, au niveau mineur
return !empty(this.compareMinor(m.other))
endfunc

* -----------------
function inspect
return '<SemVer "' + this.version + '">'
endfunc

* -----------------
protected function prereleaseClear
dimension this.prerelease[1]
this.prerelease = .null.
this.lPreRelease = .f.

* -----------------
function inc
lparameters ;
  release; && [''] type of release
, Identifier; && ['beta'] if m.release = 'pre..' pre-release identifier such as 'beta'

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

&& premajor will bump the version up to the next major release, and immediately down to pre-release.
&& preminor and prepatch work the same way.
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

case m.release == 'prepatch' && If this is already a prerelease, it'll bump to the next version
	this.prereleaseClear && drop any prereleases that might already exist, since they are not relevant at this point.
	success = .t.;
	 and this.inc('patch');
	 and this.inc('pre', m.Identifier)

case m.release == 'prerelease'
	success = .t.;
	 and (m.this.lPreRelease or this.inc('patch')); && If input is a non-prerelease version, this acts the same as a prepatch.
	 and this.inc('pre', m.Identifier)


case m.release == 'major'
&& If this is a pre-major version, bump up to the same major version, else increment major.
&& 1.0.0-5 bumps to 1.0.0
&& 1.1.0 bumps to 2.0.0
  if this.minor > 0 or this.patch > 0 or !m.this.lPreRelease
	  this.major = this.major + 1
  endif
	store 0 to this.minor, this.patch
  this.prereleaseClear

case m.release == 'minor'
&& If this is a pre-minor version, bump up to the same minor version, else increment minor.
&& 1.2.0-5 bumps to 1.2.0
&& 1.2.1 bumps to 1.3.0
  if this.patch > 0 or !m.this.lPreRelease
    this.minor = this.minor + 1
  endif
  this.patch = 0
  this.prereleaseClear

case m.release == 'patch'
&& If this is not a pre-release version, it will increment the patch: 1.2.0 patches to 1.2.1
&& If it is a pre-release it will bump up to the same patch version: 1.2.0-5 patches to 1.2.0
  if !m.this.lPreRelease
    this.patch = this.patch + 1
  endif
  this.prereleaseClear

case m.release == 'pre' and lCallingModule('inc') && && This probably shouldn't be used publicly because 1.0.0 "pre" would become 1.0.0-0 which is the wrong direction.

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
		if empty(m.iPreRelease) && didn't increment anything
			nPreRelease = m.nPreRelease + 1 && JS Array.push() ajoute un ou plusieurs éléments à la fin d'un tableau et retourne la nouvelle taille du tableau.
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
function abSemVer_test && teste la classe abSemVer
lparameters nTest && @ number for tests ran

local success as Boolean;
, unitTest as Boolean;
, oUnitTest as abUnitTest of abDev.prg;
, oAsserts as abSet of abDev.prg;
, oSemVer as abSemVer of abDev.prg;

* oUnitTest = abUnitTest()
oAsserts  = abSet('ASSERTS', 'ON')
success = .t.
nTest = 0

&& InstallShield support: prerelease is a number separated by '.' from main version
success = cSemVer('2.20.0.1', .T.) == '2.20.0-beta.1' and m.success
nTest = m.nTest + 1

&& back compat.: allow for missing dot between prerelease type and number
success = cSemVer('2.20beta1', .T.) == '2.20.0-beta.1' and m.success
nTest = m.nTest + 1

&& back compat.: allow for missing dot between prerelease type and number
success = cSemVer('2.20 beta1', .T.) == '2.20.0-beta.1' and m.success
nTest = m.nTest + 1

&& back compat.: allow for accented characters
success = cSemVer('2.20 bêta1', .T.) == '2.20.0-beta.1' and m.success
nTest = m.nTest + 1

&& major: 1.0.0-5 bumps to 1.0.0
success = abSemVer_test_inc('1.0.0-5', '1.0.0', 'major') and m.success
nTest = m.nTest + 1

&& major: 1.1.0 bumps to 2.0.0
success = abSemVer_test_inc('1.1.0', '2.0.0', 'major') and m.success
nTest = m.nTest + 1

&& prerelease: 1.2.0-beta.1 bumps to 1.2.0-beta.2
success = abSemVer_test_inc('1.2.0-beta.1', '1.2.0-beta.2', 'prerelease') and m.success
nTest = m.nTest + 1

&& minor: 1.2.0-5 bumps to 1.2.0
success = abSemVer_test_inc('1.2.0-5', '1.2.0', 'minor') and m.success
nTest = m.nTest + 1

&& minor: 1.2.1 bumps to 1.3.0
success = abSemVer_test_inc('1.2.1', '1.3.0', 'minor') and m.success
nTest = m.nTest + 1

&& patch: 1.2.1 bumps to 1.2.2
success = abSemVer_test_inc('1.2.1', '1.2.2', 'patch') and m.success
nTest = m.nTest + 1

&& patch: 1.2.1-beta bumps to 1.2.1
success = abSemVer_test_inc('1.2.1-beta', '1.2.1', 'patch') and m.success
nTest = m.nTest + 1

&& prepatch: If this is already a prerelease, it'll bump to the next version
success = abSemVer_test_inc('1.2.1-beta', '1.2.2-beta.0', 'prepatch') and m.success
nTest = m.nTest + 1

&& prepatch:
success = abSemVer_test_inc('1.2.1', '1.2.2-beta.0', 'prepatch') and m.success
nTest = m.nTest + 1

&& prerelease on previous case:
success = abSemVer_test_inc('1.2.2-beta.0', '1.2.2-beta.1', 'prerelease') and m.success
nTest = m.nTest + 1

#if .F. && select > right click > 'execute selection' > paste below
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
function abSemVer_test_inc && teste abSemVer.inc() qui est la méthode la plus délicate
lparameters ;
  versionFrom;
, versionTo;
, release; && ['patch'] type of release
, Identifier; && [''] if m.release = 'pre..' pre-release identifier such as 'beta'

local success as Boolean;
, oSemVer as abSemVer of abDev.prg;

oSemVer = abSemVer(m.versionFrom)
success = m.oSemVer.inc(m.release, m.Identifier) and m.oSemVer.version == m.versionTo

assert m.success
return m.success
endfunc

* -----------------
procedure UTF8fix1252 && corrige les caractères accentués dans un fichier converti par erreur en UTF8
lparameters tcSrce

local success as Boolean;
, result as String;
, lFile as Boolean;

success = .T.

lFile = File(m.tcSrce)
result = Iif(m.lFile, FileToStr(m.tcSrce), m.tcSrce)

result = Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(m.result;
	, 'Ã ', 'à');
	, 'Ã©', 'é');
	, 'Ã‰', 'É');
	, 'Ã¨', 'è');
	, 'Ãª', 'ê');
	, 'Ã®', 'î');
	, 'Ã»', 'ù');
	, 'Ã¹', 'û');
	, 'Ã§', 'ç');
	
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