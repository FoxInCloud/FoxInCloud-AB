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
DEFINE CLASS cusBatchLog AS Custom && Trace un processus répétitif dans un tableau à l'écran
* =================================================

* Valeurs initiales
alConsole = .F.
alFooter = .F.
acScreenFont = .NULL.
anScreenFontSize = .NULL.

* -------------------------------
 && Contenu des lignes du tableau de compte rendu
#DEFINE  L_cHEADER		1 && Texte de l'en-tête de la colonne
#DEFINE  L_uVALUE	 		2 && Ligne courante : contenu original de la cellule
#DEFINE  L_cTYPE	 		3 && Ligne courante : type du contenu original
#DEFINE  L_cDISPLAY		4 && Ligne courante : contenu affiché (en caractères bien sûr)
#DEFINE  L_lBORDER		5 && La colonne est délimitée par des barres verticales
#DEFINE  L_nWIDTH			6 && Largeur utilisable pour affichage dans la colonne (foxels)
#DEFINE  L_cID				7 && Identifiant de la colonne
#DEFINE  L_nSUM				8 && Cumul de la donnée si elle est numérique
#DEFINE  L_lSUM				9 && Sommer / moyenner la donnée en fin d'état si elle est numérique
#DEFINE  L_cFORMAT		10 && Format pour Transform()
#DEFINE  L_COUNT 			L_cFORMAT
* -------------------------------
DIMENSION aaLog[;
				L_COUNT; && une ligne par caractéristique
			, 1] && une colonne par colonne de log

anCols = 0

acLine = Space(0) && Contenu de la ligne courante
anLine = 0 && N° de la ligne courante
anDataLines = 0 && Nombre de lignes contenant des données

acWarnings = Space(0) && Avertissements déjà émis

* Adresses des fichiers
acTxtLogAddr = Space(0)
acWarnTxtLogAddr = Space(0)
acDBFlogAddr = Space(0)
acDBFlogAlias = Space(0)

alParentPjFiles = .F. && Parent object has a reference to project files collection
alDocumentView = .F.
alDataSession = .F.
alProjectManager = .F.

* -------------------------------------------------
PROCEDURE Init && Ouvre les fichiers de compte-rendu et vide la fenêtre VFP
LPARAMETERS ;
	tuTxtLog,; && [.T.] Nom, dossier ou adresse du fichier de compte-rendu texte, .T. : automatique
	tuDBFlog,; && [.T.] Nom, dossier ou adresse du fichier de la table de compte-rendu, .T. : automatique
	tlFooter,; && [.T.] Produire une ligne de totaux / moyennes en fin de CR
	tlConsole && [.T.] Afficher le compte rendu à l'écran (s'il est visible)

LOCAL lnParms, luTxtLog, luDBFlog, llResult

lnParms = Pcount()

* Determine if Parent object has a reference to a project files collection
this.alParentPjFiles = Type('this.parent.aoPjFiles') == 'O' AND NOT IsNull(this.parent.aoPjFiles)

* Init/Open log files
luTxtLog = Iif(m.lnParms>=1 AND Vartype(m.tuTxtLog) $ 'CL', m.tuTxtLog, .T.)
luDBFlog = Iif(m.lnParms>=2 AND Vartype(m.tuDBFlog) $ 'CL', m.tuDBFlog, .T.)
llResult = this.init_Logs(m.luTxtLog, m.luDBFlog)
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([Échec de la création des fichiers de compte-rendu]))

* Déterminer si une ligne de totaux / moyennes doit être produite en fin de log
this.alFooter = m.lnParms < 3 OR lTrue(m.tlFooter)

* Déterminer si les sorties doivent être envoyées à l'écran
this.alConsole = (m.lnParms < 4 OR lTrue(m.tlConsole));
	AND InList(_VFP.StartMode, 0, 1, 4);
	AND Vartype(_screen) == 'O' ;
	AND _screen.Visible
IF m.this.alConsole

	this.acScreenFont = _screen.FontName
	this.anScreenFontSize = _screen.FontSize
	_screen.FontName = "Courier New"
	_screen.FontSize = 10
	HIDE WINDOW ALL
	ACTIVATE SCREEN
	CLEAR
ENDIF	

RETURN m.llResult

* -------------------------------------------------
PROCEDURE Init_Logs && Ouvre les fichiers de compte-rendu
LPARAMETERS ;
	tuTxtLog, ; && [.T.] Nom ou adresse du fichier de compte-rendu texte, .T. pour automatique
	tuDBFlog && [.T.] Nom ou adresse du fichier de la table de compte-rendu, .T. pour automatique

LOCAL lcLogAddr, lcResult, llResultTXT, llResultDBF

* Si une adresse de log peut être bâtie
lcLogAddr = this.cLogPathStem(m.tuTxtLog)
llResultTXT = !Empty(m.lcLogAddr)
IF m.llResultTXT

	* Ouvrir ou créer les fichiers de log
	this.acTxtLogAddr = Lower(ForceExt(m.lcLogAddr, EXT_LOG))
	this.acWarnTxtLogAddr = Lower(ForceExt(m.lcLogAddr , EXT_LOG_WARN))
	this.LogCheck(m.this.acTxtLogAddr)
	this.LogCheck(m.this.acWarnTxtLogAddr)

	lcResult = 'Starting log on '+ Transform(Datetime())
	lcResult = CRLF2 + m.lcResult + CRLF + Replicate('=', Len(m.lcResult))
	llResultTXT = StrToFile(m.lcResult, this.acTxtLogAddr, .T.) > 0
	llResultTXT = StrToFile(m.lcResult, this.acWarnTxtLogAddr, .T.) > 0 AND m.llResultTXT
ENDIF

* Open/Init table log
lcLogAddr = this.cLogPathStem(m.tuDBFlog)
llResultDBF = !Empty(m.lcLogAddr)
IF m.llResultDBF
	this.acDBFlogAlias = cVFPname(JustStem(m.lcLogAddr))
	this.acDBFlogAddr = ForceExt(m.lcLogAddr, 'dbf')
	USE IN Select(this.acDBFlogAlias)
	this.LogCheck(this.acDBFlogAddr)
	llResultDBF = File(this.acDBFlogAddr)
	IF m.llResultDBF
		USE (this.acDBFlogAddr) IN 0 SHARED ALIAS (this.acDBFlogAlias)
	ENDIF
ENDIF

RETURN m.llResultTXT OR m.llResultDBF

* -------------------------------------------------
PROCEDURE Destroy && Ferme les fichiers de log et rétablit la fenêtre VFP

* Faire le pied du tableau
this.FooterCreate()

* Close log table
USE IN Select(this.acDBFlogAlias)

* Show windows hidden AT init()
SHOW WINDOW ALL
SHOW WINDOW ALL && parfois il reste des fenêtres invisibles

* Restore screen font
_screen.FontName = this.acScreenFont
_screen.FontSize = this.anScreenFontSize

IF m.this.alConsole

	* Si l'utilisateur souhaite voir les avertissements
	IF NOT Empty(m.this.acWarnings) ;
	 AND 6 = MessageBox(;
				ICase(;
					cLangUser() = 'fr',	"Voulez-vous voir les avertissements ?",; && copy-paste this line to add another language support
															"Some warning occurred, do you want them displayed?";
				);
			, 4+32;
			, ICase(;
					cLangUser() = 'fr',	"Fin de traitement",; && copy-paste this line to add another language support
															"End of processing";
				);
			, 5000;
			)
	 
	 	* Copier les avertissements dans un fichier texte temporaire
	 	LOCAL lcFile, loSafety
	 	lcFile = ForcePath(m.this.acWarnTxtLogAddr, Sys(2023))
	 	loSafety = abSet('SAFETY', 'OFF')
	 	StrToFile(m.this.acWarnings, m.lcFile)
	 	RELEASE loSafety

	 	* Afficher dans une fenêtre d'édition
	 	MODIFY FILE (m.lcFile) NOWAIT
	 	ACTIVATE WINDOW (JustFname(m.lcFile))
	ENDIF
ENDIF

* -------------------------------------------------
PROCEDURE LogCheck && Vérifie qu'un fichier de compte-rendu est accessible en écriture
LPARAMETERS tcLogAddr && Adresse du fichier de compte-rendu

IF File(m.tcLogAddr)

	* Ajouter le fichier au projet
	IF this.alParentPjFiles
		ProjectFileAdd(m.tcLogAddr, this.parent.aoPjFiles)
	ENDIF

	LOCAL lnHandle, lcWindow
	lnHandle = 0
	lcWindow = JustFname(m.tcLogAddr)
	DO WHILE .T.
		lnHandle = Fopen(m.tcLogAddr, 1) && 1 : write buffered
		IF m.lnHandle = -1

			IF Wexist(m.lcWindow)
				RELEASE WINDOWS (m.lcWindow)
				EXIT

			ELSE
				IF 2 = MessageBox('';
							+ "Le fichier de log " + m.tcLogAddr + " est actuellement ouvert." + CRLF;
							+ "Veuillez le refermer et cliquer sur Réessayer." + CRLF;
							+ "Cliquez sur 'Annuler' pour continuer sans écrire dans le log";
						, 5+16)
					EXIT
				ENDIF
			ENDIF
		ELSE
			EXIT
		ENDIF
	ENDDO

	Fclose(m.lnHandle)
ENDIF

* -------------------------------------------------
PROCEDURE cLogPathStem && Adresse d'un fichier de compte-rendu sans l'extension
LPARAMETERS tuLog && [.T.] Nom ou adresse du fichier de compte-rendu texte, .T. pour automatique

LOCAL lcSys16, lcResult

lcResult = Space(0)
lcSys16 = Sys(16,0)
IF NOT Empty(m.lcSys16)

	LOCAL lcLogPathAuto, lcLogStemAuto, lcLogPath, lcLogStem

	lcLogPathAuto = Addbs(cModuleInfo(m.lcSys16, 'Path'))
	lcLogStemAuto = cModuleInfo(m.lcSys16, 'Name')
	STORE Space(0) TO m.lcLogPath, m.lcLogStem

	DO CASE

	CASE Vartype(m.tuLog) = 'C' AND ! Empty(m.tuLog)

		lcLogPath = Addbs(JustPath(m.tuLog))
		lcLogPath = Iif(Directory(m.lcLogPath), m.lcLogPath, m.lcLogPathAuto)

		lcLogStem = JustStem(m.tuLog)
		lcLogStem = cFileName(m.lcLogStem)
		lcLogStem = Iif(lFileName(m.lcLogStem), m.lcLogStem, m.lcLogStemAuto)

	CASE Vartype(m.tuLog) = 'L' AND m.tuLog
		lcLogPath = lcLogPathAuto
		lcLogStem = lcLogStemAuto

	ENDCASE
	lcResult = Addbs(m.lcLogPath) + m.lcLogStem
ENDIF

RETURN m.lcResult

* -------------------------------------------------
PROCEDURE ColAdd && Ajoute une colonne à la fin de la table de compte-rendu
LPARAMETERS ;
	tcHeader,; && [''] Contenu de l'en-tête de la colonne
	tnColWidth,; && [Header width || 10] Largeur de la colonne en foxels
	tlNoLeftBar,;	 && [.F.] Ne pas délimiter les colonnes par une barre verticale
	tcID,; && [tcHeader] Identifiant de la colonne
	tlSum,; && [.F.] Si la donnée est numérique, en fin d'état : .T.: Sommer, .F.: Moyenner, .NULL.: ne rien faire
	tcFormat && [''] Format pour Transform()

LOCAL lnResult && Numéro de la colonne ajoutée
lnResult = 0

IF m.this.anLine = 0 && possible only if no line was displayed yet

 	lnResult = this.aColAdd()

 	LOCAL lcHeader, lnColWidth
 	lcHeader = uDefault(m.tcHeader, Space(0))
 	lnColWidth = uDefault(m.tnColWidth, Max(10, Len(m.lcHeader)))

	this.aaLog[L_cHEADER, m.lnResult] = m.lcHeader
	this.aaLog[L_uVALUE, m.lnResult] = .NULL.
	this.aaLog[L_cTYPE, m.lnResult] = ''
	this.aaLog[L_nWIDTH, m.lnResult] = m.lnColWidth
	this.aaLog[L_cDISPLAY, m.lnResult] = Space(m.lnColWidth)
	this.aaLog[L_lBORDER, m.lnResult] = NOT uDefault(m.tlNoLeftBar, .F.)
	this.aaLog[L_cID, m.lnResult] = uDefault(m.tcID, m.lcHeader)
	this.aaLog[L_nSUM, m.lnResult] = 0
	this.aaLog[L_lSUM, m.lnResult] = Iif(Vartype(m.tlSum) $ 'LX', m.tlSum, .F.)
	this.aaLog[L_cFORMAT, m.lnResult] = Evl(m.tcFormat, '')
	
	* Si affichage à l'écran (console)
	IF m.this.alConsole

		* Calculer la largeur totale du tableau en caractères
		LOCAL lnCol, lnTableWidth
		lnTableWidth = 0
		FOR m.lnCol = 1 TO m.lnResult
			lnTableWidth = m.lnTableWidth + this.aaLog[L_nWIDTH, m.lnCol] + Iif(this.aaLog[L_lBORDER, m.lnCol], 1, 0)
		ENDFOR
		lnTableWidth = m.lnTableWidth + 1 && right border

		* Tant que le tableau est plus large que l'écran, réduire la police de l'écran
		DO WHILE m.lnTableWidth * Fontmetric(6, _screen.FontName, _screen.FontSize) > _screen.ViewPortWidth ;
				AND _screen.FontSize > 5
			_screen.FontSize = _screen.FontSize - 1
		ENDDO
	ENDIF
ENDIF

this.anCols = m.lnResult

RETURN m.lnResult

* -------------------------------------------------
PROCEDURE aColAdd && Ajoute une colonne au tableau de compte-rendu
LOCAL lnResult && Numéro de la colonne ajoutée
 	lnResult = Alen(this.aaLog, 2)

IF NOT Vartype(this.aaLog[1]) = 'L' && La première colonne n'est plus disponible

 	LOCAL ARRAY laCopy[L_COUNT, m.lnResult]

 	Acopy(this.aaLog, m.laCopy)
 		aColsIns(@m.laCopy)

 	lnResult = m.lnResult + 1
 		DIMENSION this.aaLog[L_COUNT, m.lnResult]
 	Acopy(m.laCopy, this.aaLog)
 	ENDIF

 	RETURN m.lnResult

* -------------------------------------------------
PROCEDURE nCol && Numéro de colonne d'après son identifiant
LPARAMETERS ;
	tcColID && Identifiant de la colonne
LOCAL lnResult && Numéro de la colonne
lnResult = 0

LOCAL llResult
llResult = Vartype(m.tcColID) == 'C' and not Empty(m.tcColID)
IF m.llResult

	lnResult = Ascan(this.aaLog, m.tcColID, 1, -1, -1, 1+2+4)
	lnResult = Asubscript(this.aaLog, m.lnResult, 2)
ENDIF

 	RETURN m.lnResult

* -------------------------------------------------
PROCEDURE nColWidthTotal && Largeur totale d'un colonne du compte-rendu (avec gouttières)
LPARAMETERS tnCol && Numéro de colonne

LOCAL lnColWidth, lnResult

lnResult = 0

IF Vartype(m.tnCol) = 'N' ;
 AND Between(m.tnCol, 1, Alen(this.aaLog, 2))

	lnColWidth = this.aaLog [L_nWIDTH, m.tnCol]
	lnResult = Iif(Vartype(m.lnColWidth) == 'N' AND m.lnColWidth > 0;
			 , 1 + m.lnColWidth; && gouttière avant
			 , 0;
			 )
ENDIF

RETURN m.lnResult

* -------------------------------------------------
PROCEDURE CellFill && Remplit une cellule du compte-rendu
LPARAMETERS ;
	tuCol,; && Numéro ou ID de la colonne
	tuContent,; && [''] Contenu à placer dans la colonne
	tlExpand,; && [.F.] Si le contenu est plus large que la colonne, déborder sur les colonnes de droite
	tlNoDisplay,; && [.F.] Différer l'affichage de la ligne (pour gagner du temps lorsque plusieurs modifications successives de la ligne)
	tcFormat && [''] Format d'affichage

LOCAL lnCols, lcType, lnCol, llResult

* Si la définition de colonne est valide
lnCols = Alen(this.aaLog, 2)
lcType = Vartype(m.tuCol)
DO CASE
	CASE m.lcType == 'N'
		lnCol = m.tuCol
		llResult = m.tuCol <= m.lnCols
	CASE m.lcType == 'C'
		lnCol = this.nCol(m.tuCol)
		llResult = m.lnCol > 0
ENDCASE
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([Spécification de colonne invalide <<cLitteral(m.tuCol)>>]))
IF m.llResult

	LOCAL luContent, llExpand, llNoDisplay, lcFormat, lcContent, lnColWidth

	* Donner leur valeur par défaut aux paramètres optionnels
	luContent = Iif(Pcount() >= 2, m.tuContent, Space(0))
 	llExpand = lTrue(m.tlExpand)
	llNoDisplay = lTrue(m.tlNoDisplay)
	lcFormat = Iif(Pcount() >= 5 AND Vartype(m.tcFormat) == 'C', m.tcFormat, Space(0))
	lcFormat = Evl(m.lcFormat, this.aaLog[L_cFORMAT, m.lnCol])
	
	* Si la colonne a une largeur positive
 		lnColWidth = this.aaLog[L_nWIDTH, m.lnCol]
 		llResult = m.lnColWidth > 0
 	IF m.llResult

		* Charger la données originale dans la cellule
 		this.aaLog[L_uVALUE, m.lnCol] = m.luContent
 		this.aaLog[L_cTYPE, m.lnCol] = Vartype(m.luContent)
 		
 		* Si la donnée est numérique, cumuler
 		IF this.aaLog[L_cTYPE, m.lnCol] == 'N'
 			this.aaLog[L_nSUM, m.lnCol] = this.aaLog[L_nSUM, m.lnCol] + m.luContent
 		ENDIF

		* Si la colonne peut déborder
		lcContent = Transform(m.luContent, m.lcFormat)
	 	IF m.llExpand AND m.lnCol < m.lnCols

	 		LOCAL lnColX, lnColWidthX
	 		lnColWidthX = m.lnColWidth
	 		FOR m.lnColX = m.lnCol + 1 TO Alen(this.aaLog, 2)
			 	lnColWidthX = m.lnColWidthX + this.nColWidthTotal(m.lnColX)
	 		ENDFOR
	 		lnColWidth = Min(Len(m.lcContent), m.lnColWidthX)
	 	ENDIF 

		* Charger l'affichage dans la cellule
 		this.aaLog[L_cDISPLAY, m.lnCol] = ;
 				this.cCellContent(m.tuContent, m.lnColWidth, m.llExpand, m.lcFormat)

		llResult = m.llNoDisplay OR this.LineDisplay()
 	ENDIF
ENDIF

RETURN m.llResult

* -------------------------------------------------
PROCEDURE cCellContent && Contenu d'une cellule du tableau de compte-rendu, ajusté à la taille de la cellule
LPARAMETERS ;
	tuContent,; && Contenu à placer dans la colonne
	tnColWidth,; && Largeur de la colonne en foxels
	tlExpand,; && [.F.] Si le contenu est plus large que la colonne, déborder sur les colonnes de droite
	tcFormat && [''] Format de présentation
tlExpand = lTrue(m.tlExpand)
tcFormat = Evl(m.tcFormat, '')

 	LOCAL lcType, lcResult

 	lcType = Vartype(m.tuContent)
 	IF m.lcType $ 'CNYLDT'

 	lcResult = Transform(m.tuContent, m.tcFormat)

 	* Manage position in column, trim if necessary
 	DO CASE

 	CASE m.lcType $ 'NY'
		lcResult = Iif(m.tlExpand;
			, this.cColJustified(m.lcResult, m.tnColWidth); && gauche
			, Padl(m.lcResult, m.tnColWidth, Space(1)); && Aligner à droite avec un Space(1)
			)

 	CASE m.lcType = 'L'
		lcResult = Iif(m.tlExpand;
				, this.cColJustified(m.lcResult, m.tnColWidth); && à gauche
				, Padl(m.lcResult, m.tnColWidth/2+2, Space(1)); && centrer
				)

 	OTHERWISE
		* Aligner à gauche en tentant de préserver les espaces en tête
		lcResult = this.cColJustified(m.lcResult, m.tnColWidth)
	ENDCASE

	lcResult = Padr(m.lcResult, m.tnColWidth, Space(1))
ELSE
 	lcResult = Space(0)
ENDIF

 	RETURN m.lcResult

* -------------------------------------------------
FUNCTION cColJustified && Justifie le contenu d'une cellule dans la largeur de la colonne
LPARAMETERS ;
	tcContent, ; && Contenu à placer dans la colonne
	tnColWidth && Largeur de la colonne en foxels

LOCAL lcResult

lcResult = m.tcContent
IF Lenc(m.lcResult) > m.tnColWidth

	lcResult = Rtrim(m.lcResult)
	IF Lenc(m.lcResult) > m.tnColWidth

		lcResult = Ltrim(m.lcResult)
		IF Lenc(m.lcResult) > m.tnColWidth

			lcResult = Leftc(m.lcResult, m.tnColWidth-1) + POINTSUSP
		ENDIF
	ENDIF
ENDIF

RETURN m.lcResult

* -------------------------------------------------
PROCEDURE LineFill && Écrit une nouvelle ligne à l'écran
LPARAMETERS tuContent

LOCAL lnResult && Position de la fin de ligne 

lnResult = 0
IF this.LineFeed()
	this.acLine = Transform(m.tuContent)
	IF m.this.alConsole
		ACTIVATE SCREEN
		?? m.this.acLine AT 0
	ENDIF
	lnResult = Len(m.this.acLine)
ENDIF

RETURN m.lnResult

* -------------------------------------------------
PROCEDURE LineAppend && Ajoute un contenu à la ligne courante et affiche le résultat
LPARAMETERS ;
	tuContent, ; && Contenu à placer dans la colonne
	tnPosition && [fin de ligne] Position où le contenu est ajouté

LOCAL lnLine, lnResult && Position où le contenu a été ajouté

this.acLine = Alltrim(this.acLine)
lnLine = Len(this.acLine)
lnResult = Iif(vartype(m.tnPosition)=='N', m.tnPosition, m.lnLine)
this.acLine = Left(this.acLine, m.lnResult) + ;
							Space(Iif(Empty(m.this.acLine), 0, 1)) + ;
							Transform(m.tuContent)

* Compléter avec des espaces pour superposer la ligne précédente
IF m.lnLine > Len(this.acLine)
	this.acLine = Padr(this.acLine, m.lnLine, Space(1))								
ENDIF

IF m.this.alConsole
	ACTIVATE SCREEN
	?? m.this.acLine AT 0
ENDIF

RETURN m.lnResult

* -------------------------------------------------
PROCEDURE LineDisplay && Affiche le contenu de l'en-tête ou de la ligne courante
LPARAMETERS tlHeader && [.F.] Afficher l'en-tête du tableau
tlHeader = lTrue(m.tlHeader)

LOCAL lcLineOut, lnDisplayWidth;
, lnCol, lnColsWidth, lnColWidth;
, lcCellDisplay, llLeftBar, llResult


* Pour chaque colonne
lcLineOut = Space(0)
STORE 0 TO m.lnDisplayWidth, m.lnColsWidth
FOR m.lnCol = 1 TO Alen(this.aaLog, 2)

	lcCellDisplay = Iif(m.tlHeader;
			, this.cCellContent(this.aaLog[L_cHEADER, m.lnCol], this.aaLog[L_nWIDTH, m.lnCol]);
			, this.aaLog[L_cDISPLAY, m.lnCol];
			)
	llLeftBar = this.aaLog[L_lBORDER, m.lnCol]
	lnColWidth = 1 + this.aaLog[L_nWIDTH, m.lnCol]
	llResult = ;
			Vartype(m.lcCellDisplay) == 'C' ;
		AND	Vartype(m.llLeftBar) == 'L' ;
		AND	Vartype(m.lnColWidth) == 'N'
	ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([La table de log est mal remplie.]))
	IF m.llResult

		DO CASE
		CASE m.lnDisplayWidth = m.lnColsWidth && start current column
			lcLineOut = m.lcLineOut + Iif(m.llLeftBar, '|', Space(1)) + m.lcCellDisplay
		CASE m.lnDisplayWidth >= m.lnColsWidth + m.lnColWidth && Beyond current column
		OTHERWISE && inside current column
			lcLineOut = Padr(m.lcLineOut, m.lnColsWidth + m.lnColWidth, Space(1))
		ENDCASE
		lnColsWidth = m.lnColsWidth + m.lnColWidth
		lnDisplayWidth = Len(m.lcLineOut)
	ELSE
		EXIT
	ENDIF
ENDFOR

IF m.llResult
	this.acLine = m.lcLineOut + Iif(m.llLeftBar, '|', Space(0))
	this.lineShow(m.tlHeader)
ENDIF

RETURN m.llResult
	
* -------------------------------------------------
PROCEDURE LineShow && Affiche la ligne courante à l'écran
LPARAMETERS tlHeader && [.F.] Afficher l'en-tête

IF m.this.alConsole

	ACTIVATE SCREEN
*!*			?? Space(0) AT 0 && bug de TEXT TO m.lcResult TEXTMERGE NOSHOW
	?? Space(1) AT 0 && bug de TEXT TO m.lcResult TEXTMERGE NOSHOW

	IF lTrue(m.tlHeader)
		?
	ENDIF
	?? m.this.acLine AT 0
ENDIF
	
* -------------------------------------------------
PROCEDURE LineFeed && Vide la ligne courante pour en commencer une nouvelle
LPARAMETERS ;
	tlSepLine, ; && [.F.] Tracer une ligne séparatrice après la nouvelle ligne
	tlDataLine && [.F.] La nouvelle ligne contient des données vivantes

LOCAL lcLine, llResult

* Update line count
IF this.anCols > 0
	this.anLine = this.anLine + 1
	this.anDataLines = this.anDataLines + Iif(lTrue(m.tlDataLine), 1, 0)
ENDIF

* Flush and clear current line
llResult = this.LineFlush()
llResult = this.LineClear() AND m.llResult

* Move to ENDFOR line, with separation line if required
IF lTrue(m.tlSepLine)
	lcLine = this.cSepLine()
	StrToFile(CRLF + m.lcLine, this.acTxtLogAddr, .T.)
ELSE
	lcLine = Space(1)
ENDIF
IF m.this.alConsole
	ACTIVATE SCREEN
	? m.lcLine
ENDIF

RETURN m.llResult

* -------------------------------------------------
PROCEDURE LineFlush && Sauve la ligne courante dans les fichiers de compte-rendu

LOCAL llResult
llResult = .T.

* Ajouter au log texte
IF NOT empty(this.acTxtLogAddr) AND NOT Empty(this.acLine)
	llResult = StrToFile(CRLF + this.acLine, this.acTxtLogAddr, .T.) > 0
ENDIF

* Ajouter au log table
IF NOT Empty(this.acDBFlogAddr)
	llResult = Used(this.acDBFlogAlias) OR this.DBFlogCreate()
	IF m.llResult
		llResult = this.DBFlogAppend()
	ENDIF
ENDIF

RETURN m.llResult

* -------------------------------------------------
PROCEDURE LineClear && Efface la ligne courante

LOCAL lnCol, lnWidth
FOR m.lnCol = 1 TO Alen(this.aaLog, 2)
	lnWidth = this.aaLog[L_nWIDTH, m.lnCol]
	lnWidth = Iif(Vartype(m.lnWidth)=='N', m.lnWidth, 0)
	this.aaLog[L_cDISPLAY, m.lnCol] = Space(m.lnWidth)
	this.aaLog[L_uVALUE, m.lnCol] = .NULL.
ENDFOR

this.acLine = Space(0)

* -------------------------------------------------
PROCEDURE Warning && Affiche un avertissement dans une fenêtre "WAIT WINDOW", ajoute au compte-rendu des avertissements si nouveau
LPARAMETERS ;
	tcWarning,; && Avertissement, vide pour nouvelle ligne
	tlAppendNot && [.F.] Ne pas ajouter l'avertissement au compte-rendu

LOCAL llWarnNew, lcWarning, lcCallingModule, llResult

* Si avertissement non vide
IF .T.;
 and Vartype(m.tcWarning) == 'C';
 and not Empty(m.tcWarning)

	tcWarning = Alltrim(m.tcWarning)

	* Si nouvel avertissement
	lcCallingModule = cTronc(Lower(cCallingModule()), 20)
	lcWarning = Padr(m.lcCallingModule, 20) + m.tcWarning
	llWarnNew = NOT Upper(m.lcWarning) $ Upper(m.this.acWarnings)
	IF m.llWarnNew

		* Display warning
		WAIT WINDOW cTronc('Module ' + m.lcCallingModule + ' : ' + m.tcWarning, 254) NOWAIT
*			?? Chr(7)
	ENDIF

ELSE && blank line

	* Clear warning
	WAIT CLEAR
	llWarnNew = .T.
	lcWarning = Space(0)

ENDIF

* Append Warning to Log if requested
IF m.llWarnNew;
 AND not (lTrue(m.tlAppendNot))

	lcWarning = CRLF + m.lcWarning
	this.acWarnings = m.this.acWarnings + m.lcWarning
	llResult = StrToFile(m.lcWarning, m.this.acWarnTxtLogAddr, .T.) > 0
ELSE
	llResult = .T.
ENDIF

RETURN m.llResult

* -------------------------------------------------
FUNCTION cSepLine && Ligne séparatrice horizontale
LPARAMETERS tlLeftBars && [.F.] Tracer une barre verticale au début de la nouvelle ligne

LOCAL lnCol, lnColWidth, llLeftBar, lcResult

lcResult = Space(0)
FOR m.lnCol = 1 TO Alen(this.aaLog, 2)

	llLeftBar = m.tlLeftBars AND this.aaLog[L_lBORDER, m.lnCol]
	lnColWidth = this.nColWidthTotal(m.lnCol)
	llResult = 	Vartype(m.lnColWidth) = 'N' AND m.lnColWidth > 0
	IF m.llResult

		lcResult = m.lcResult + ;
						Iif(m.llLeftBar, '|', '-') + ;
						Replicate('-', m.lnColWidth - 1)
	ELSE
		EXIT
	ENDIF
ENDFOR

RETURN Iif(m.llResult, m.lcResult + Iif(m.llLeftBar, '|', '-'), Space(0))

* -------------------------------------------------
PROCEDURE DBFlogCreate && Crée la table de compte-rendu

LOCAL lcFields, lnCol;
, lcFieldName, lcFieldType, lnFieldLength, lcFieldExp;
, lnSelect, llResult

IF m.this.anCols > 0

	lcFields = Space(0)
	FOR m.lnCol = 1 TO this.anCols
		lcFieldName = cVFPname (this.aaLog[L_cHEADER, m.lnCol], 10)
		lcFieldType = uDefault(Alltrim(this.aaLog[L_cTYPE, m.lnCol]), 'C')
		lcFieldType = Evl(m.lcFieldType, 'C')
		lnFieldLength = this.aaLog[L_nWIDTH, m.lnCol]
		lcFieldExp = cFieldExp(m.lcFieldName, m.lcFieldType, m.lnFieldLength,,.T.)
		llResult = NOT Empty(m.lcFieldExp)
		IF m.llResult
			lcFields = c2Words(m.lcFields, ',', m.lcFieldExp)
		ELSE
			EXIT
		ENDIF
	ENDFOR
	IF m.llResult

		lcFields = '(' + m.lcFields + ')'
		lnSelect = Select(0)
		CREATE TABLE (this.acDBFlogAddr) FREE &lcFields
		USE
		this.LogCheck(this.acDBFlogAddr)
		USE (this.acDBFlogAddr) ALIAS (this.acDBFlogAlias) EXCLUSIVE
		SELECT (m.lnSelect)
	ENDIF
ENDIF

RETURN m.llResult

* -------------------------------------------------
PROCEDURE DBFlogAppend && Sauve la ligne courante du tableau dans la table de compte-rendu

LOCAL lnCols, llResult

lnCols = Alen(this.aaLog, 2)
llResult = m.lnCols > 0 AND Used(this.acDBFlogAlias)
IF m.llResult

	* Tabuler les champs de la table de log
	LOCAL ARRAY laFields[1]
	AFields(laFields, this.acDBFlogAlias)
	
	* Pour chaque colonne
	LOCAL llAllEmpty, lnCol, lcFieldName, luFieldValue, lcFieldType, lnFieldLength, lcFieldExp, lnField, lcAlter
	llAllEmpty = .T.
	lcAlter = Space(0)
	FOR lnCol = 1 TO m.lnCols

		* Déterminer les caractéristiques du champ pouvant contenir la donnée
		lcFieldName = cVFPname(this.aaLog[L_cID, m.lnCol], 10)
		luFieldValue = this.aaLog[L_uVALUE, m.lnCol]
		lcFieldType = this.aaLog[L_cTYPE, m.lnCol]
		lnFieldLength = this.aaLog[L_nWIDTH, m.lnCol]
		IF Vartype(m.lcFieldType) = 'C' ;
		 AND NOT Empty(m.lcFieldType) ;
		 AND Vartype(m.lnFieldLength) = 'N' ;
		 AND NOT Empty(m.lnFieldLength)
			lcFieldExp = cFieldExp(m.lcFieldName, m.lcFieldType, m.lnFieldLength,,.T.)
			lnField = Ascan(laFields, m.lcFieldName, 1, -1, 1, 1+2+4+8)
			
			* Si le champ n'existe pas
			IF m.lnField = 0

				lcAlter = lcAlter + ' ADD COLUMN ' + m.lcFieldExp

			* Sinon (le champ existe)
			ELSE

				* Si le champ n'est pas de le bonne taille ou type
				IF NOT m.lcFieldType $ VFP7_FIELD_TYPES_FIXED_LEN ;
				 AND laFields[m.lnField, 3] < m.lnFieldLength ;
				 OR NOT laFields[m.lnField, 2] == m.lcFieldType
					
					lcAlter = lcAlter + ' ALTER COLUMN ' + m.lcFieldExp
				ENDIF 
			ENDIF

			llAllEmpty = m.llAllEmpty AND (Empty(m.luFieldValue) OR IsNull(m.luFieldValue))
		ENDIF

		LOCAL (m.lcFieldName)
		STORE m.luFieldValue TO (m.lcFieldName) && pour GATHER MEMVAR plus loin
	ENDFOR

	* S'il faut changer la structure de la table
	IF NOT Empty(m.lcAlter)
		llResult = Used(ExclusiveForce(this.acDBFlogAlias))
		IF m.llResult
			lcAlter = 'ALTER TABLE ' + cLitteral(this.acDBFlogAlias) + m.lcAlter
			&lcAlter
			USE IN (this.acDBFlogAlias)
			USE (this.acDBFlogAddr) IN 0 SHARED ALIAS (this.acDBFlogAlias)
		ENDIF
	ENDIF

	IF m.llResult AND NOT m.llAllEmpty

		LOCAL loSelect
		loSelect = CreateObject('abSelect', this.acDBFlogAlias)
		APPEND BLANK
		GATHER MEMVAR
	ENDIF
ENDIF

RETURN m.llResult

* -------------------------------------------------
PROCEDURE FooterCreate && Crée un pied de tableau avec totaux ou moyennes

* En cas d'interruption anormale, vider la ligne en cours
IF NOT Empty(m.this.acLine)
	this.LineFeed
ENDIF

* Si au moins une ligne de données
IF m.this.anCols * m.this.anDataLines > 0

	* Tracer une ligne pour fermer le tableau
	this.acLine = this.cSepLine()
	this.LineShow()

	* Si un pied de tableau a été demandé
	IF m.this.alFooter
		this.LineFeed()

		LOCAL lnCol, lnSum, luSum, llFooter, llTitle

		* Pour chaque colonne
		FOR m.lnCol = 1 TO this.anCols
			lnSum = this.aaLog[L_nSUM, m.lnCol]
			luSum = this.aaLog[L_lSUM, m.lnCol]

			* Si la colonne contient un total et qu'un bilan est demandé
			IF m.lnSum > 0 AND NOT IsNull(m.luSum) && .NULL.: ne rien faire, ni total ni moyenne
				this.CellFill(m.lnCol, m.lnSum / Iif(m.luSum, 1, m.this.anDataLines))
				llFooter = .T.
			ELSE
				IF NOT m.llTitle
					llTitle = this.CellFill(;
							m.lnCol;
						, Textmerge(ICase(;
								cLangUser() = 'fr',	[Totaux / moyennes des <<m.this.anDataLines>> lignes],; && copy-paste this line to add another language support
																		[Total / averages of <<m.this.anDataLines>> lines];
							));
						, .T.;
						)
				ENDIF
			ENDIF
		ENDFOR
		
		* Si le pied d'état a été créé, le sortir
		IF m.llFooter
			this.LineFeed(.T.)
		ENDIF
	ENDIF
ENDIF

* -------------------
ENDDEFINE && CLASS cusBatchLog as Custom

* -----------------------------------------------------
PROCEDURE cusBatchLog_Test
LOCAL lcSys16
lcSys16 = Sys(16,0)
? m.lcSys16
LOCAL loBatchLog, lnPos
loBatchLog = CreateObject('cusBatchLog', Addbs(Sys(2023)) + 'test')
WITH m.loBatchLog
	.LineFill('Ceci va commencer le test ...')
	lnPos = .lineAppend('Première étape')
	WAIT 'Test de cusBatchLog en cours ...' WINDOW TIMEOUT 3
	.lineAppend('OK', m.lnPos)
	.ColAdd('First column', 18)
	.ColAdd('Second column', 25)
	.ColAdd('Third column', 15, .T.)
	.ColAdd('Fourth column', 15)
	.LineFeed(.T.)
	.LineDisplay(.T.)
	.LineFeed(.T.)
	.cellFill(1, Datetime())
	.cellFill(2, 'Thierry Nivelet')
	.cellFill(3, 524.25)
	.cellFill(4, .F.)
	.LineFeed(.T.)
	.cellFill(1, Datetime())
	.cellFill(2, 'Thierry Nivelet is a poor developper', .T.)
	.cellFill(3, 524.25)
	.cellFill(4, .F.)
	.LineFeed(.T.)
	.Warning('Warning test OK')
ENDWITH

* ========================================
FUNCTION cModuleInfo && Nom, Chemin ou Adresse d'un module d'après Sys(16)
LPARAMETERS ;
	tcSys16,; && Chaîne obtenue par Sys(16)
	tcInfo,; && ['N'] {N}ame, {A}ddress, {P}ath, {O}bject, {S}ys16, {L}ignée, {F}ull lignée
	tlCase && [.F.] Respecter la casse sur disque

tcInfo = Iif(Vartype(m.tcInfo) = 'C' AND NOT Empty(m.tcInfo), Upper(Left(Ltrim(m.tcInfo), 1)), 'N')
tcInfo = Iif(m.tcInfo $ 'NAPSOLF', m.tcInfo, 'N')
tlCase = lTrue(m.tlCase)

LOCAL llProc, lcAddr, lcProc, laMembers[1], lnMembers, llMethod;
, llResult, lcResult

lcResult = Space(0)

* Si le paramètre requis est valide
llResult = Vartype(m.tcSys16) = 'C'
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([Invalid Sys(16) Information : <<cLitteral(m.tcSys16)>>]))
IF m.llResult AND NOT Upper(Left(m.tcSys16, 2)) == 'ON' && ON ...

	* Repérer le nom de la procédure et l'adresse du fichier dans la chaine sys(16)
 	llProc = Left(Upper(m.tcSys16), Lenc('PROCEDURE ')) == 'PROCEDURE '
 	lcAddr = Iif(m.llProc;
 		, Substr(m.tcSys16, Atc(' ', m.tcSys16, 2) + 1); && GetWordNum() ne fonctionne pas si l'adresse contient des espaces
 		, m.tcSys16;
 		)
 	lcAddr = Iif(m.tlCase, cFileCased(m.lcAddr), m.lcAddr)
 	lcProc = Iif(m.llProc, GetWordNum(m.tcSys16, 2), JustStem(m.lcAddr))
 	llMethod = '.' $ m.lcProc
 	IF m.llMethod
	 	lnMembers = ALines(laMembers, m.lcProc, 1, '.')
 	ELSE
 		llResult = NOT m.tcInfo $ 'OLF'
		ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([Invalid Information Type Specification : '<<m.tcInfo>>']))
 	ENDIF
 	IF m.llResult

	 	RETURN ICase(;
	 		m.tcInfo == 'N',; && Procedure name (with object name if method)
		 		Iif(m.llMethod;
		 			, laMembers[m.lnMembers-1] + Iif(Empty(laMembers[m.lnMembers-1]) OR Empty(laMembers[m.lnMembers]), '', '.') + laMembers[m.lnMembers];
		 			, m.lcProc;
		 			),;
		 	m.tcInfo == 'A',; && Procedure file address
		 		m.lcAddr,;
		 	m.tcInfo == 'P',; && Procedure file path
		 		Addbs(JustPath(m.lcAddr)),;
		 	m.tcInfo == 'S',; && Procedure file address
		 		m.tcSys16,;
		 	m.tcInfo == 'O',; && Object name
		 		laMembers[m.lnMembers-1],;
		 	m.tcInfo == 'L',; && Lignée des objets
		 		Leftc(m.lcProc, Ratc('.', m.lcProc)-1),;
		 	m.tcInfo == 'F',; && Lignée complète de la méthode
		 		m.lcProc,;
		 		'';
		 	)
 	ENDIF
ENDIF

RETURN m.lcResult

* ------------------------------------
PROCEDURE cModuleInfo_Test && Test cModuleInfo()
&& cf 'cModuleInfo_Test.prg' pour test par programme

LOCAL loUnitTest as abUnitTest OF abDev.prg, lcSys16, loClassTest
loUnitTest = NewObject('abUnitTest', 'abDev.prg')
lcSys16 = Sys(16) && module courant

loUnitTest.Test('CMODULEINFO_TEST', m.lcSys16, 'Name')
loUnitTest.Test(Upper(DOS_AB), m.lcSys16, 'Path')
loUnitTest.Test(Upper(DOS_AB) + 'ABDEV.FXP', m.lcSys16, 'Address')

loClassTest = CreateObject('cusModuleInfo_Test', m.loUnitTest)
		
RETURN loUnitTest.Result()

	* --------------------------------------
	DEFINE CLASS cusModuleInfo_Test as Custom && Teste cModuleInfo() au sein d'une classe
		PROCEDURE Init
		LPARAMETERS toUnitTest
		LOCAL lcSys16
		lcSys16 = Sys(16) && module courant
		toUnitTest.Test('CUSMODULEINFO_TEST.INIT', m.lcSys16, 'Name')
		toUnitTest.Test(Upper(DOS_AB), m.lcSys16, 'Path')
		toUnitTest.Test(Upper(DOS_AB) + 'ABDEV.FXP', m.lcSys16, 'Address')
	ENDDEFINE

* ========================================
FUNCTION cCallingModule && Nom du module appelant (programme, procédure, méthode, ...)
LPARAMETERS ;
	tcAddress,; && [''] @ Adresse du fichier où se trouve le module appelant
	tnStackUp && [0] nombre de niveaux avant le module appelant

LOCAL lnLevelHere, lcSys16, lcResult

lcResult = Space(0)

* Si ce module est appelé par un module appelé
lnLevelHere = Program(-1) && current program level
IF m.lnLevelHere > 2

	lcSys16 = Sys(16, m.lnLevelHere - 2 - Abs(Evl(m.tnStackUp, 0)))

	tcAddress = cModuleInfo(m.lcSys16, 'Address')
	lcResult = cModuleInfo(m.lcSys16, 'Name')
ENDIF

RETURN m.lcResult

* ------------------------------------
PROCEDURE cCallingModule_Test

LOCAL loUnitTest as abUnitTest of abDev.prg
loUnitTest = NewObject('abUnitTest', 'abDev.prg')

LOCAL lcSys16, lcSys16module, lcSys16address;
, lcModule, lcAddress;
, loTest as cCallingModule_Test3 of abDev.prg;

lcSys16 = Sys(16)
lcSys16module = Upper(cModuleInfo(m.lcSys16, 'Name'))
lcSys16address = Upper(cModuleInfo(m.lcSys16, 'Address'))

lcModule = cCallingModule_Test1(@m.lcAddress)

? Upper(m.lcModule) == m.lcSys16module
? Upper(m.lcAddress) == m.lcSys16address


lcModule = cCallingModule_Test2(@m.lcAddress, -1)

? Upper(m.lcModule) == m.lcSys16module
? Upper(m.lcAddress) == m.lcSys16address


loTest = NewObject('cCallingModule_Test3', 'abDev.prg')

lcModule = loTest.Test(@m.lcAddress, -1)

? Upper(m.lcModule) == m.lcSys16module
? Upper(m.lcAddress) == m.lcSys16address

	* ------------------------------------
	PROCEDURE cCallingModule_Test1
	LPARAMETERS tcAddress, tnStackUp
	RETURN cCallingModule(@m.tcAddress, m.tnStackUp)

	* ------------------------------------
	PROCEDURE cCallingModule_Test2
	LPARAMETERS tcAddress, tnStackUp
	RETURN cCallingModule_Test1(@m.tcAddress, m.tnStackUp)

	* ------------------------------------
	define class cCallingModule_Test3 as Relation
	procedure test
	lparameters tcAddress, tnStackUp
	RETURN cCallingModule_Test1(@m.tcAddress, m.tnStackUp)
	enddefine

* ========================================
FUNCTION cCallingModules && Modules appelants
LPARAMETERS ;
	tlCurrent,; && [.F.] Inclure le nom du module courant
	tcInfo && [Name] 'Name', 'Address', 'Path', 'Object' ou 'Lignée'

tlCurrent = lTrue(m.tlCurrent)

LOCAL lnLevelHere, lnLevel, lcResult
lcResult = Space(0)

* Si cCallingModules est appelé par un module appelé
lnLevelHere = Program(-1) && current program level
IF m.lnLevelHere > Iif(m.tlCurrent, 1, 2)

	FOR m.lnLevel = 1 TO m.lnLevelHere - Iif(m.tlCurrent, 1, 2)
		lcResult = c2Words(m.lcResult, ' > ', Textmerge("<<m.lnLevel>>.<<Chr(160)>><<cModuleInfo(Sys(16, m.lnLevel), m.tcInfo)>>"))
	ENDFOR
ENDIF

RETURN Lower(m.lcResult)

* ========================================
FUNCTION lCallingModule && Un module appelle le module appelant cette fonction
LPARAMETERS ;
	tcModule,; && Module: [class][.]procedure
	tlModules && [.F.] && appel depuis lCallingModules()

LOCAL llResult as Boolean;
, liLevelBase as Integer;
, liLevelHere as Integer;
, liLevel as Integer;
, lcLevel as String;
, llMethod as Boolean;
, llClassMethod as Boolean;

IF Vartype(m.tcModule) == 'C' AND NOT Empty(m.tcModule)

	* Si ce module est appelé par un module appelé
	liLevelHere = Program(-1) && current program level
	liLevelBase = 2 + Iif(lTrue(m.tlModules), 1, 0)
	IF m.liLevelHere > m.liLevelBase

		tcModule = Upper(Alltrim(m.tcModule))
		llMethod = Leftc(m.tcModule, 1) == '.'
		llClassMethod = !m.llMethod and '.' $ m.tcModule

		FOR m.liLevel = m.liLevelHere - m.liLevelBase TO 1 STEP -1
			lcLevel = Program(m.liLevel)

			IF m.tcModule == ICase(;
				m.llMethod,;
					'.' + JustExt(m.lcLevel),;
				m.llClassMethod,;
					m.lcLevel,;
				'.' $ m.lcLevel,;
					JustExt(m.lcLevel),;
					 m.lcLevel;
				)
				llResult = .T.
				EXIT
			ENDIF
		ENDFOR
	ENDIF
ENDIF

RETURN m.llResult

* ========================================
FUNCTION lCallingModules && Plusieurs modules appellent le module appelant cette fonction
LPARAMETERS ;
	tcModules,; && Modules
	tlOR && [.F.] Au moins un module appelle le module
tlOR = lTrue(m.tlOR)

LOCAL laModules[1], lcModule, llResult
llResult = Vartype(m.tcModules) == 'C' AND ALines(laModules, Upper(m.tcModules), 1+4, ',', ';') > 0
IF m.llResult

	FOR EACH lcModule IN laModules

		IF m.tlOR
			llResult = lCallingModule(m.lcModule, .T.)
			IF m.llResult
				EXIT
			ENDIF
		ELSE
			llResult = lCallingModule(m.lcModule, .T.) AND m.llResult
			IF NOT m.llResult
				EXIT
			ENDIF
		ENDIF
	ENDFOR
ENDIF

RETURN m.llResult

* ========================================
FUNCTION lUserEventCalling && Un événement utilisateur appelle cette fonction
lparameters tcClassStart && Classe à partir de laquelle chercher dans la pile d'appel si elle s'y trouve

local success as Boolean;
, laStack[1] as String;
, lnStack as Integer;
, liStack as Integer;
, lClassStart as Boolean;
, lcEvent as String;
, liEvent as Integer;

lnStack = AStackInfo(m.laStack)
if m.lnStack > 0 && should always be .T.

	tcClassStart = Lower(Evl(m.tcClassStart, ''))
	lClassStart = !Empty(m.tcClassStart)
	for liStack = m.lnStack to 1 step -1
		if m.lClassStart and Lower(GetWordNum(laStack[m.liStack, 3], 1, '.')) == m.tcClassStart
*				liStack = Aelement(m.laStack, m.liStack, 3)
			exit
		endif
		laStack[m.liStack, 3] = GetWordNum(laStack[m.liStack, 3], GetWordCount(laStack[m.liStack, 3], '.'), '.') && Module or Object name
	endfor
	liStack = Evl(m.liStack, 1)
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
	endtext
	for liEvent = 1 to GetWordCount(m.lcEvent, CRLF)
		if Ascan(m.laStack, GetWordNum(m.lcEvent, m.liEvent, CRLF), m.liStack, -1, 3, 7) > 0
			success = .T.
			exit
		endif
	endfor
endif

return m.success

* ------------------------------------
PROCEDURE lUserEventCalling_Test && Teste lUserEventCalling()

LOCAL loUnitTest as abUnitTest of abDev.prg
loUnitTest = NewObject('abUnitTest', 'abDev.prg')

loUnitTest.Test(.F.)
loUnitTest.Test(.F., 'abUnitTest')
		
RETURN m.loUnitTest.Result()

* ========================================
FUNCTION uDefault && Valeur par défaut d'un paramètre /!\ .T. non supporté
LPARAMETERS ;
	tuParm,; && Paramètre dont il faut régler la valeur par défaut
	tuDefault && Valeur par défaut /!\ .T. non supporté

LOCAL lcType, luResult
luResult = .NULL.

* Si deux paramètres ont été passés
IF Pcount() = 2

	* Si la valeur par défaut est supportée
	lcType = Vartype(m.tuDefault)
	IF NOT (m.lcType == 'L' AND m.tuDefault)
	
		* Si le paramètre est du type de la valeur par défaut, le retourner, sinon retourner la valeur par défaut
		luResult = Iif(Vartype(m.tuParm) == m.lcType, m.tuParm, m.tuDefault)
	ELSE
		ASSERT .F. MESSAGE cAssertMsg(Textmerge([<<Proper(Program())>> ne supporte pas la valeur par défaut .T. comme second paramètre]))
	ENDIF
ENDIF

RETURN m.luResult

* ------------------------------------
PROCEDURE uDefault_Test && Teste uDefault()

LOCAL loUnitTest as abUnitTest of abDev.prg
loUnitTest = NewObject('abUnitTest', 'abDev.prg')

loUnitTest.Test('Name', .F., 'Name')
loUnitTest.Test('Name', 0, 'Name')
loUnitTest.Test('Name', CreateObject('form'), 'Name')

LOCAL loAsserts as abSet of abDev.prg
loAsserts = abSet('Asserts', 'OFF')
loUnitTest.Test(.NULL., 0, .T.)
		
RETURN loUnitTest.Result()

* ==================================
DEFINE CLASS abMachineInfo as GA_LIGHTWEIGHT_CLASS of abGA.prg && Informations sur la machine : processeur, mémoire, etc.

* Système
nOEMid = 0
nPageSize = 0
nAppAddrMin = 0
nAppAddrMax = 0
nProcessorMask = 0
nProcessors = 0
nProcessorType = 0
cProcessorName = Space(0)
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
PROCEDURE SystemInfo && Peuple les informations système

 DECLARE GetSystemInfo IN win32api STRING @lcSystemInfo
 LOCAL lcSysInfo
 m.lcSysInfo = SPACE(36)
 GetSystemInfo(@m.lcSysInfo)
 
 this.nOEMid = StrToLong(LEFT(m.lcSysInfo, 4))
 this.nPageSize = StrToLong(SUBSTR(m.lcSysInfo, 5, 4))
 this.nAppAddrMin = StrToLong(SUBSTR(m.lcSysInfo, 9, 4))
 this.nAppAddrMax = StrToLong(SUBSTR(m.lcSysInfo, 13, 4))
 this.nProcessorMask = StrToLong(SUBSTR(m.lcSysInfo, 17, 4))
 this.nProcessors = Int(StrToLong(SUBSTR(m.lcSysInfo, 21, 4)))
 this.nProcessorType = StrToLong(SUBSTR(m.lcSysInfo, 25, 4))
 this.nAllocationGranularity = StrToLong(SUBSTR(m.lcSysInfo, 29, 4))
 this.nReserved = StrToLong(SUBSTR(m.lcSysInfo, 33, 4))

 #DEFINE PROCESSOR_INTEL_386 386
 #DEFINE PROCESSOR_INTEL_486 486
 #DEFINE PROCESSOR_INTEL_PENTIUM 586
 #DEFINE PROCESSOR_MIPS_R4000 4000
 #DEFINE PROCESSOR_ALPHA_21064 21064
 DO CASE
 CASE this.nProcessorType = PROCESSOR_INTEL_386
    this.cProcessorName = "INTEL 386"
 CASE this.nProcessorType = PROCESSOR_INTEL_486
    this.cProcessorName = "INTEL 486"
 CASE this.nProcessorType = PROCESSOR_INTEL_PENTIUM
    this.cProcessorName = "INTEL Pentium"
 CASE this.nProcessorType = PROCESSOR_MIPS_R4000
    this.cProcessorName = "MIPS R4000"
 CASE this.nProcessorType = PROCESSOR_ALPHA_21064
    this.cProcessorName = "ALPHA 21064"
 ENDCASE

* ------------------------------------
PROCEDURE MemoryInfo && Peuple les informations mémoire

 DECLARE GlobalMemoryStatus IN win32api STRING @lcMemStat
 LOCAL lcMemStat
 m.lcMemStat = LongToStr(32) + REPLICATE(CHR(0), 28)
 GlobalMemoryStatus(@m.lcMemStat)

 this.nMemLoad = StrToLong(SUBSTR(m.lcMemStat, 5, 4))
 this.nMemPhysTot = StrToLong(SUBSTR(m.lcMemStat, 9, 4))
 this.nMemPhysAvail = StrToLong(SUBSTR(m.lcMemStat, 13, 4))
 this.nPageFileTot = StrToLong(SUBSTR(m.lcMemStat, 17, 4))
 this.nPageFileAvail = StrToLong(SUBSTR(m.lcMemStat, 21, 4))
 this.nMemVirtualTot = StrToLong(SUBSTR(m.lcMemStat, 25, 4))
 this.nMemVirtualAvail = StrToLong(SUBSTR(m.lcMemStat, 29, 4))

* ------------------------------------
PROCEDURE ProcessorInfo && Peuple les informations sur le processeur

LOCAL loWMIService, loItems, loItem
loWMIService = Getobject("winmgmts:\\.\root\cimv2")
loItems = loWMIService.ExecQuery("Select * from Win32_Processor")

For Each loItem In loItems
	this.nAddressWidth = loItem.AddressWidth
	this.nArchitecture = loItem.Architecture
	this.nAvailability = loItem.Availability
	this.nCpuStatus = loItem.CpuStatus
	this.nCurrentClockSpeed = loItem.CurrentClockSpeed
	this.nDataWidth = loItem.DataWidth
	this.cDescription = Alltrim(loItem.Description)
	this.cDeviceID = Alltrim(loItem.DeviceID)
	this.nExtClock = loItem.ExtClock
	this.nFamily = loItem.Family
	this.nL2CacheSize = loItem.L2CacheSize
	this.nL2CacheSpeed = loItem.L2CacheSpeed
	this.nLevel = loItem.Level
	this.nLoadPercentage = loItem.LoadPercentage
	this.cManufacturer = Alltrim(loItem.Manufacturer)
	this.nMaxClockSpeed = loItem.MaxClockSpeed
	this.cProcessorFullName = Alltrim(loItem.Name)
	this.cPNPDeviceID = loItem.PNPDeviceID
	this.cProcessorID = Alltrim(loItem.ProcessorId)
	this.nProcessorType = loItem.ProcessorType
	this.nRevision = loItem.Revision
	this.cRole = Alltrim(loItem.Role)
	this.cSocketDesignation = Alltrim(loItem.SocketDesignation)
	this.nStatusInfo = loItem.StatusInfo
	this.cStepping = Alltrim(loItem.Stepping)
	this.cUniqueId = Alltrim(loItem.UniqueId)
	this.nUpgradeMethod = loItem.UpgradeMethod
	this.cVersion = Alltrim(loItem.Version)
	this.nVoltageCaps = loItem.VoltageCaps
ENDFOR
 
ENDDEFINE && CLASS abMachineInfo

* ==================================
PROCEDURE abMachineInfo_Test && Teste abMachineInfo

LOCAL lnSeconds, loMI as abMachineInfo of abDev.prg
loMI = CreateObject('abMachineInfo')

#DEFINE MEM_DISP_FORMAT '9 999 999 999'

lnSeconds = Seconds()
loMI.systemInfo()
lnSeconds = Seconds() - m.lnSeconds
MessageBox(;
	"Informations Système:" + CR + ;
	"- Identifiant OEM: " + Transform(m.loMI.nOEMid) + CR + ;
  "- Taille de page : " + Transform(m.loMI.nPageSize) + CR + ;
  "- Adresse application minimum : " + Transform(m.loMI.nAppAddrMin, MEM_DISP_FORMAT) + CR +;
  "- Adresse application maximum : " + Transform(m.loMI.nAppAddrMax, MEM_DISP_FORMAT) + CR + ;
  "- Masque de processeur: " + Transform(m.loMI.nProcessorMask) + CR + ;
  "- Nombre de processeurs: " + Transform(m.loMI.nProcessors) + CR + ;
  "- Nom du processeur : " + m.loMI.cProcessorName + CR + ;
  "- Granularité d'allocation (NDR?): " + Transform(m.loMI.nAllocationGranularity) + CR + ;
  + CR + "Temps d'exécution : " + Transform(m.lnSeconds) + " secondes" ;
 ,64)

lnSeconds = Seconds()
loMI.memoryInfo()
lnSeconds = Seconds() - m.lnSeconds
MessageBox(;
	"Informations Mémoire:" + CR + ;
  "- Mémoire utilisée : " + Transform(m.loMI.nMemLoad) + '%' + CR + ;
  "- Mémoire physique totale : " + Transform(m.loMI.nMemPhysTot, MEM_DISP_FORMAT) + " octets" + CR + ;
  "- Mémoire physique disponible : " + Transform(m.loMI.nMemPhysAvail, MEM_DISP_FORMAT) + " octets" + CR + ;
  "- Mémoire paginée totale : " + Transform(m.loMI.nPageFileTot, MEM_DISP_FORMAT) + " octets" + CR + ;
  "- Mémoire paginée disponible : " + Transform(m.loMI.nPageFileAvail, MEM_DISP_FORMAT) + " octets" + CR + ;
  "- Mémoire virtuelle totale : " + Transform(m.loMI.nMemVirtualTot, MEM_DISP_FORMAT) + " octets" + CR + ;
  "- Mémoire virtuelle disponible : " + Transform(m.loMI.nMemVirtualAvail, MEM_DISP_FORMAT) + " octets" + CR + ;
  + CR + "Temps d'exécution : " + Transform(m.lnSeconds) + " secondes" ;
 ,64)

lnSeconds = Seconds()
loMI.processorInfo()
lnSeconds = Seconds() - m.lnSeconds
 MessageBox(;
	"- Address Width : " + Transform(m.loMI.nAddressWidth) + CR + ;
	"- Architecture : " + Transform(m.loMI.nArchitecture) + CR + ;
	"- Availability : " + Transform(m.loMI.nAvailability) + CR + ;
	"- CPU Status : " + Transform(m.loMI.nCpuStatus) + CR + ;
	"- Current Clock Speed : " + Transform(m.loMI.nCurrentClockSpeed) + CR + ;
	"- Data Width : " + Transform(m.loMI.nDataWidth) + CR + ;
	"- Description : " + Transform(m.loMI.cDescription) + CR + ;
	"- Device ID : " + Transform(m.loMI.cDeviceID) + CR + ;
	"- Ext Clock : " + Transform(m.loMI.nExtClock) + CR + ;
	"- Family : " + Transform(m.loMI.nFamily) + CR + ;
	"- L2 Cache Size : " + Transform(m.loMI.nL2CacheSize) + CR + ;
	"- L2 Cache Speed : " + Transform(m.loMI.nL2CacheSpeed) + CR + ;
	"- Level : " + Transform(m.loMI.nLevel) + CR + ;
	"- Load Percentage : " + Transform(m.loMI.nLoadPercentage) + CR + ;
	"- Manufacturer : " + Transform(m.loMI.cManufacturer) + CR + ;
	"- Maximum Clock Speed : " + Transform(m.loMI.nMaxClockSpeed) + CR + ;
	"- Processor Full Name : " + Transform(m.loMI.cProcessorFullName) + CR + ;
	"- PNP Device ID : " + Transform(m.loMI.cPNPDeviceID) + CR + ;
	"- Processor Id : " + Transform(m.loMI.cProcessorID) + CR + ;
	"- Processor Type : " + Transform(m.loMI.nProcessorType) + CR + ;
	"- Revision : " + Transform(m.loMI.nRevision) + CR + ;
	"- Role : " + Transform(m.loMI.cRole) + CR + ;
	"- Socket Designation : " + Transform(m.loMI.cSocketDesignation) + CR + ;
	"- Status Information : " + Transform(m.loMI.nStatusInfo) + CR + ;
	"- Stepping : " + Transform(m.loMI.cStepping) + CR + ;
	"- Unique Id : " + Transform(m.loMI.cUniqueId) + CR + ;
	"- Upgrade Method : " + Transform(m.loMI.nUpgradeMethod) + CR + ;
	"- Version : " + Transform(m.loMI.cVersion) + CR + ;
	"- Voltage Caps : " + Transform(m.loMI.nVoltageCaps)+ CR + ;
  + CR + "Temps d'exécution : " + Transform(m.lnSeconds) + " secondes" ;
 ,64)

* ------------------------------------
 FUNCTION LongToStr && Représentation ASCII d'un entier 32 bits positif
 LPARAMETERS tnLongVal && Entier 32 bits positif

 LOCAL i, lnLongVal, lcResult

 lcResult = Space(0)
 lnLongVal = m.tnLongVal
 FOR i = 24 TO 0 STEP -8
    lcResult = Chr(Int(m.lnLongVal/(2^m.i))) + m.lcResult
    lnLongval = Mod(m.lnLongVal, (2^m.i))
 ENDFOR

 RETURN lcResult

* ------------------------------------
FUNCTION StrToLong && Entier 32 bits positif d'après sa représentation ASCII
LPARAMETERS tcLongStr && Représentation ASCII d'un entier 32 bits positif

LOCAL i, lcLongStr, lnResult
lnResult = 0
lcLongStr = m.tcLongStr
FOR i = 0 TO 24 STEP 8
   lnResult = m.lnResult + (Asc(m.lcLongStr) * (2^m.i))
   lcLongStr = Right(m.lcLongStr, Len(m.lcLongStr) - 1)
ENDFOR

RETURN lnResult 

* ------------------------------------
FUNCTION cBarsSecs && Une barre pour 50 ms
LPARAMETERS tnSeconds && Nombre de secondes obtenu par différence de seconds()

IF Vartype(m.tnSeconds) == 'N' AND m.tnSeconds >= 0
 	tnSeconds = m.tnSeconds * 1000 && ms

 	LOCAL lcBars
 	lcBars = Replicate('=', Min(Int(m.tnSeconds / 50), 100)) && 1 barre = 50 ms, 5 secs max
 	RETURN m.lcBars;
 		+ Space(Iif(Empty(m.lcBars), 0, 1));
 		+ Iif(m.tnSeconds = 0, '< 1', Ltrim(Transform(m.tnSeconds, '99 999')));
 		+ " ms"
ELSE

	RETURN Space(0)
ENDIF

* ------------------------------------
PROCEDURE ProjectFilesInclude && Change l'inclusion de fichiers dans le projet courant
LPARAMETERS ;
	tcFileMask,; && [*.*] Expression régulière indiquant le masque de fichier à traiter
	tlInclude,; && [.T.] .T.: Inclure, .F.: Exclure, .NULL. : Inverser
	tnResult && @ Nombre de fichiers traités
tnResult = 0

LOCAL loProject, loProjectFiles, loRegExp as abRegExp OF abTxt.prg, llResult

* Si un projet est actif
loProject = _vfp.Activeproject
llResult = Vartype(m.loProject) == 'O'
IF m.llResult
	
	* Si le projet contient des fichiers
	loProjectFiles = m.loProject.Files
	llResult = m.loProjectFiles.count > 0
	IF m.llResult

		* Créer un objet 'Regular Expression'
		loRegExp = CreateObject('abRegExp')
		llResult = Vartype(m.loRegExp) == 'O'
		IF m.llResult

			* Donner leur valeur par défaut aux paramètres
			LOCAL lcCarsNot, lcFileMask, llInclude, loFile as File
			lcCarsNot = CAR_INT_DS_NOM_FICH
			lcFileMask = Alltrim(uDefault(m.tcFileMask, Textmerge('[^<<m.lcCarsNot>>]+\.[^<<m.lcCarsNot>>]+')))
			llInclude = Iif(Pcount() >=2 AND Vartype(m.tlInclude) $ 'LX', m.tlInclude, .T.)
			
			* Pour chaque fichier
			loRegExp.Setup(m.lcFileMask, .T.)
			FOR EACH loFile IN m.loProjectFiles
			
				* Si le nom du fichier correspond au masque
				IF loRegExp.test(JustFname(m.loFile.Name))
				
					* Changer son inclusion
					loFile.Exclude = Iif(IsNull(m.llInclude), NOT m.loFile.Exclude, m.llInclude)
					tnResult = m.tnResult + 1
				ENDIF
			ENDFOR
		ENDIF
	ENDIF
ENDIF

RETURN m.llResult

* ------------------------------------
PROCEDURE ProjectFilesRemove && Ôte des fichiers du projet courant
LPARAMETERS ;
	tcFileMask,; && [*.*] Expression régulière indiquant le masque de fichier à traiter
	tnResult && @ Nombre de fichiers traités
tnResult = 0

LOCAL loProject, loProjectFiles, loRegExp as abRegExp OF abTxt.prg, llResult

* Si un projet est actif
loProject = _vfp.Activeproject
llResult = Vartype(m.loProject) == 'O'
IF m.llResult
	
	* Si le projet contient des fichiers
	loProjectFiles = m.loProject.Files
	llResult = m.loProjectFiles.count > 0
	IF m.llResult

		* Créer un objet 'Regular Expression'
		loRegExp = CreateObject('abRegExp')
		llResult = Vartype(m.loRegExp) == 'O'
		IF m.llResult

			* Donner leur valeur par défaut aux paramètres
			LOCAL lcCarsNot, lcFileMask, llInclude, loFile AS File
			lcCarsNot = CAR_INT_DS_NOM_FICH
			lcFileMask = Alltrim(uDefault(m.tcFileMask, Textmerge('[^<<m.lcCarsNot>>]+\.[^<<m.lcCarsNot>>]+')))
			llInclude = Iif(Pcount() >=2 AND Vartype(m.tlInclude) $ 'LX', m.tlInclude, .T.)
			
			* Pour chaque fichier
			loRegExp.Setup(m.lcFileMask, .T.)
			FOR EACH loFile IN m.loProjectFiles
			
				* Si le nom du fichier correspond au masque
				IF loRegExp.test(JustFname(m.loFile.Name))
				
					* öter le fichier
					loFile.Remove
					tnResult = m.tnResult + 1
				ENDIF
			ENDFOR
		ENDIF
	ENDIF
ENDIF

RETURN m.llResult


*========================================
FUNCTION cVFPname	&& Nom valide pour VFP, avec longueur limitée si nécessaire
LPARAMETERS ;
	tcVFPname, ; && Nom VFP à valider
	tnLength && [len(tcVFPname)] Longueur maximale du nom (par ex. 10 pour un nom de champ de table libre)
LOCAL lcResult
lcResult = space(0)

IF Vartype(m.tcVFPname) = 'C' ;
 AND NOT Empty(m.tcVFPname)
	
	* Remove accents
	LOCAL lcVFPname
	lcVFPname = cEuroANSI(Alltrim(m.tcVFPname)) 

	* Start with '_' if first is a digit
	lcVFPname = Iif(IsDigit(m.lcVFPname), '_', Space(0)) + m.lcVFPname

	* Turn characters neither digit or letter to '_'
	LOCAL lnCar, lcCar
	FOR m.lnCar = 1 TO Len(m.lcVFPname)
		lcCar = Substrc(m.lcVFPname, m.lnCar, 1)
		lcCar = Iif(isDigit(m.lcCar) or IsAlpha(m.lcCar), m.lcCar, '_')
		lcResult = m.lcResult + Upper(m.lcCar)
	ENDFOR

	* Remove duplicate underscores
	lcResult = cRepCharDel(m.lcResult, '_')
	lcResult = Iif(m.lcResult == '_', Space(0), m.lcResult)
	
	* Trim right is required
	IF Vartype(m.tnLength) = 'N' ;
	 AND m.tnLength > 0
		lcResult = Leftc(m.lcResult, m.tnLength)
	ENDIF
ENDIF

RETURN m.lcResult

* -----------------------------------------------------------------
PROCEDURE cVFPname_Test

LOCAL loUnitTest as abUnitTest OF abDev.prg
loUnitTest = NewObject('abUnitTest', 'abDev.prg')

loUnitTest.Test('_150', '150')
loUnitTest.Test('_CARTABLE_POIRE', '%cartable/poiré')
loUnitTest.Test('_2CARTABLE_POIRE', '2cartable.poiré')
loUnitTest.Test('_2CARTABLE_POIRE', '2cartable.:poiré')
loUnitTest.Test(Leftc('_2CARTABLE_POIRE', 9), '2cartable.:poiré', 9)

RETURN loUnitTest.Result()

*========================================
FUNCTION lVFPname	&& Nom valide pour VFP
LPARAMETERS tcVFPname && @ Nom VFP à valider

LOCAL llResult
#if .F.
Use only letters, underscores, and numbers.
Begin the name with a letter or underscore.
Use 1 to 128 characters, except for field names in free tables and index tags — those can be 10 characters at most.
Avoid words reserved by Visual FoxPro.
#endif

llResult = Vartype(m.tcVFPname) == 'C';
 AND NOT Empty(m.tcVFPname);
 AND (Left(m.tcVFPname, 1) == '_' or IsAlpha(m.tcVFPname));
 AND Empty(Chrtran(Upper(cEuroANSI(m.tcVFPname)), '_0123456789ABCDEFGHIJKLMONPQRSTUVWXYZ', ''));
 AND Len(m.tcVFPname) <= 128

IF m.llResult
	tcVFPname = Upper(m.tcVFPname)
ENDIF

RETURN m.llResult
 
* ====================
FUNCTION lProcLine && Ligne de code VFP définissant une procédure / fonction
LPARAMETERS tcCodeLine && Ligne de code VFP

LOCAL lcCodeLine, lcWord1, lcWord2, llResult

llResult = Vartype(m.tcCodeLine) == 'C'
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([Invalid parameter type]))
IF m.llResult

	lcCodeLine = Upper(m.tcCodeLine)
	lcWord1 = Left(GetWordNum(m.lcCodeLine, 1), 4)
	lcWord2 = Left(GetWordNum(m.lcCodeLine, 2), 4)

	llResult = m.lcWord1 $ 'PROC,FUNC' ;
				OR m.lcWord1 $ 'PROT,HIDD' AND m.lcWord2 $ 'PROC,FUNC'
ENDIF

RETURN m.llResult

* ====================
FUNCTION cProcType && Type de procédure / fonction défini dans une ligne
LPARAMETERS tcCodeLine && Ligne de code VFP

LOCAL lcCodeLine, lnProc, lnFunc, llParm, lcResult && 'P' ou 'F' ou vide si impossible de le définir

lcResult = Space(0)
llParm = Vartype(m.tcCodeLine) == 'C'
ASSERT m.llParm MESSAGE cAssertMsg(Textmerge([Invalid parameter type]))
IF m.llParm AND lProcLine(m.tcCodeLine)

	lcCodeLine = Ltrim(Upper(m.tcCodeLine))
	lnProc = Atc('PROC', m.lcCodeLine)
	lnFunc = Atc('FUNC', m.lcCodeLine)

	lcResult = Iif(m.lnProc > 0 AND m.lnFunc > 0, Iif(m.lnProc < m.lnFunc, 'P', 'F'), ;
									Iif(m.lnProc > 0, 'P', 'F'))
ENDIF

RETURN m.lcResult

* ====================
FUNCTION lCommandLine && Ligne de code VFP contenant une commande
LPARAMETERS tcCodeLine && Ligne de code VFP

LOCAL llResult

llResult = Vartype(m.tcCodeLine) == 'C'
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([Invalid parameter type]))
IF m.llResult

	llResult = ;
			NOT lCommentLine(m.tcCodeLine) ;
		AND NOT Left(GetWordNum(m.tcCodeLine, 1), 1) == '#' && directive de compilation
ENDIF

RETURN m.llResult

* ====================
FUNCTION lCommentLine && Ligne de commentaire VFP
LPARAMETERS tcCodeLine && Ligne de code VFP
LOCAL llResult && c'est une ligne de commentaire

llResult = Vartype(m.tcCodeLine) == 'C'
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([Invalid parameter type]))
IF m.llResult

	LOCAL lcWord1
	lcWord1 = GetWordNum(m.tcCodeLine, 1)
	llResult = ;
					Empty(m.tcCodeLine) ;
				OR Left(m.lcWord1, 1) == '*' ;
				OR Left(m.lcWord1, 2) == Replicate('&', 2)
ENDIF

RETURN m.llResult

* ====================
FUNCTION lSeparatorLine && Ligne de commentaire de séparation 
LPARAMETERS tcCodeLine && Ligne de code VFP
LOCAL llResult && c'est une ligne de séparation

* Si le paramètre est correct
llResult = Vartype(m.tcCodeLine) == 'C'
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([Invalid parameter type]))
IF m.llResult

	* si c'est une ligne de commentaire
	llResult = lCommentLine(m.tcCodeLine)
	IF m.llResult
	
		* Si la ligne n'est pas vide
		llResult = Empty(m.tcCodeLine)
		IF NOT m.llResult
		
			* Si la ligne ne comporte aucune lettre ou chiffre
			LOCAL lnCar, lcCar
			FOR m.lnCar = 1 TO Lenc(m.tcCodeLine)
				lcCar = Substrc(m.tcCodeLine, m.lnCar, 1)
				llResult = NOT (IsAlpha(m.lcCar) or IsDigit(m.lcCar))
				IF NOT m.llResult
					EXIT
				ENDIF
			ENDFOR
		ENDIF
	ENDIF
ENDIF

RETURN m.llResult

* ====================
FUNCTION cLineComment && Commentaire dans une ligne de code
LPARAMETERS tcCodeLine && Ligne de code ; si @, retournée sans commentaire ni espaces

LOCAL lcResult; && Commentaire dans la ligne de code
, llResult;
, lnAt, lnAt1;

lcResult = Space(0)

* Si la ligne de code est valide
tcCodeLine = cCodeLineClean(m.tcCodeLine) && Ligne de code sans caractères parasites
llResult = NOT IsNull(m.tcCodeLine)
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([Line de code invalide : <<m.tcCodeLine>>]))
IF m.llResult
	
	* Si la ligne comporte un commentaire
	lnAt = At_c('*', m.tcCodeLine)
	IF m.lnAt > 0
		lnAt1 = m.lnAt + 1
	ELSE
		lnAt = At_c(Replicate('&', 2), m.tcCodeLine)
		IF m.lnAt > 0
			lnAt1 = m.lnAt + 2
		ENDIF
	ENDIF
	IF m.lnAt > 0
	
		* Extraire le commentaire et le supprimer
		lcResult = m.tcCodeLine
		lcResult = Alltrim(Substrc(m.lcResult, m.lnAt1))
		lcResult = Upper(Substrc(m.lcResult, 1, 1)) + Substrc(m.lcResult, 2) && capitalise le premier caractère
		tcCodeLine = Substrc(m.tcCodeLine, 1, m.lnAt - 1) && Ligne sans le commentaire
	ENDIF
ENDIF

RETURN m.lcResult

* --------------------
PROCEDURE cLineComment_Test && Teste cLineComment

LOCAL loUnitTest as abUnitTest OF abDev.prg
loUnitTest = NewObject('abUnitTest', 'abDev.prg')

LOCAL lcLine
lcLine = '      Procedure test ' + Replicate('&', 2) + '   test réussi'
loUnitTest.Test('Test réussi', m.lcLine)

lcLine = '* Procedure test ' + Replicate('&', 2) + '   test réussi'
loUnitTest.Test('Procedure test ' + Replicate('&', 2) + ' test réussi', m.lcLine)

RETURN loUnitTest.Result()

* ====================
FUNCTION cCodeLineClean && Ligne de code sans caractères parasites
LPARAMETERS tcCodeLine && Ligne de code

LOCAL llResult

llResult = Vartype(m.tcCodeLine)=='C'
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([Function argument type is invalid : <<m.tcCodeLine>>]))
IF m.llResult

	RETURN	cRepCharDel(; && supprime les espaces répétés
						Chrtran(Ltrim(m.tcCodeLine), Chr(9), Space(1)); && remplace les tabs par des espaces
					)
ELSE
	RETURN .NULL.
ENDIF

* ====================
FUNCTION cCommentStripped && Code sans commentaires
LPARAMETERS ;
	tcInsts; && Instructions
, tlInLineCommentKeep

LOCAL laInst[1], lcInst, lcInst_, llCRLF;
, llResult, lcResult

lcResult = Space(0)

llResult = Vartype(m.tcInsts) == 'C'
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([Invalid code block: <<m.tcInsts>>]))
IF m.llResult
	
	IF ALines(laInst, m.tcInsts) > 0 && garder les espaces en début et fin de ligne
		
		llCRLF = Rightc(m.tcInsts, 2) == CRLF
		FOR EACH lcInst IN m.laInst

			lcInst_ = Ltrim(m.lcInst, Space(1), Chr(9))
			lcResult = m.lcResult + Iif(Left(m.lcInst_, 1) == '*' OR Left(m.lcInst_, 2) == '&'+'&' OR Upper(Left(m.lcInst_, 5)) == 'NOTE ';
				, Space(0);
				, Iif(m.tlInLineCommentKeep, m.lcInst, cInLineCommentStripped(m.lcInst)) + CRLF;
				)
		ENDFOR

		lcResult = Iif(m.llCRLF;
			, m.lcResult;
			, Rtrim(m.lcResult, CR, LF);
			)
	ENDIF
ENDIF

RETURN m.lcResult

* ====================
FUNCTION cInLineCommentStripped && Instructions sans commentaire de ligne
LPARAMETERS ;
	tcInsts as String,; && Instructions
	tcComment as String && @ Commentaires trouvés

tcComment = ''

LOCAL lcResult;
, llResult;
, liComment;
, liCR

lcResult = ''

* Si code valide
llResult = Vartype(m.tcInsts) == 'C'
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([Invalid Code: <<cL(m.tcInsts)>>]))
IF m.llResult

	lcResult = m.tcInsts

	DO WHILE .T.

		liComment = At_c(Replicate('&', 2), m.lcResult)
		IF m.liComment > 0

			liCR = At_c(CR, Substrc(m.lcResult, m.liComment))

			tcComment = m.tcComment;
				+ Iif(Empty(m.tcComment), '', CRLF);
				+ Iif(m.liCR > 0;
					, Substrc(m.tcInsts, m.liComment, m.liCR - m.liComment);
					, Substrc(m.tcInsts, m.liComment);
					);
			
			lcResult = '';
				+ Rtrim(Substrc(m.lcResult, 1, m.liComment - 1), Space(1), TABUL);
				+ Iif(m.liCR > 0, Substrc(m.lcResult, m.liComment + m.liCR-1), '')
		ELSE
			EXIT
		ENDIF
	ENDDO
ENDIF

RETURN m.lcResult

* ----------------------------
PROCEDURE cInLineCommentStripped_Test && Teste cInLineCommentStripped()

LOCAL loUnitTest AS abUnitTest of abDev.prg, lcCode, lcComment, lcExpected

loUnitTest = NewObject('abUnitTest', 'abDev.prg')

lcCode = [Moved &] + [& Occurs when an object is moved to a new position or a container object's Top or Left property settings have been changed programmatically]
loUnitTest.Test('Moved', m.lcCode, @m.lcComment)
loUnitTest.assert([&] + [& Occurs when an object is moved to a new position or a container object's Top or Left property settings have been changed programmatically], m.lcComment)

TEXT TO lcCode NOSHOW FLAGS 1 PRETEXT 3
	MouseWheel && Occurs ...
	Moved && Occurs when an object is moved to a new position or a container object's Top or Left property settings have been changed programmatically
	OLECompleteDrag && Occurs ...
ENDTEXT

TEXT TO lcExpected NOSHOW FLAGS 1 PRETEXT 3
	MouseWheel
	Moved
	OLECompleteDrag
ENDTEXT

loUnitTest.Test(m.lcExpected, m.lcCode)
		
RETURN loUnitTest.Result()

* ====================
FUNCTION aInLineCommentsStripped && Lignes de code sans commentaires de ligne
LPARAMETERS taCodeLines && @ Lignes de code
EXTERNAL ARRAY taCodeLines

LOCAL lnCodeLine, llResult, lnResult
lnResult = 0

llResult = Type('m.taCodeLines[1]') == 'C' AND Alen(m.taCodeLines, 2) = 0
ASSERT m.llResult MESSAGE Program() + ' - Code Lines expected: ' + cLitteral(m.taCodeLines)
IF m.llResult

	lnResult = Alen(taCodeLines)
	FOR m.lnCodeLine = 1 TO m.lnResult
		taCodeLines[m.lnCodeLine] = cInLineCommentStripped(taCodeLines[m.lnCodeLine])
	ENDFOR
ENDIF

RETURN m.lnResult

* =================================================
FUNCTION abON as abON of abDev.prg && Saves and restores ON ...
LPARAMETERS ;
	tcSetting,; && ON ... to be set
	tvValueNew && Value to set

RETURN CreateObject('abON', m.tcSetting, m.tvValueNew)

* =================================================
DEFINE CLASS abON as GA_LIGHTWEIGHT_CLASS of abGA.prg && Saves and restores ON ...
* =================================================

cSetting = Space(0)
vValueOld = .NULL.

* ------------------------------------
PROCEDURE Init
LPARAMETERS ;
	tcSetting,; && ON ... to be set
	tvValueNew && Value to set

LOCAL llResult

TRY
	this.cSetting = m.tcSetting
	this.vValueOld = On(m.tcSetting)
	ON &tcSetting &tvValueNew
	llResult = .T.
CATCH
ENDTRY

RETURN m.llResult

* ------------------------------------
PROCEDURE Destroy

LOCAL lcSetting, lcValue

lcSetting = m.this.cSetting
lcValue = m.this.vValueOld

ON &lcSetting &lcValue

* =================================================
ENDDEFINE && CLASS abOn
* =================================================

* =================================================
FUNCTION labSet as Boolean
LPARAMETERS ;
	toObj as abSet of abDev.prg,; && @ abSet Object back
	tcSetting,; && Setting to perform
	tvValueNew,; && Value to set, .T. to toggle ON - OFF
	tnSetting,; && Setting number when appropriate for tcSetting, as of 2nd parameter of set()
	tlChangeAlways,; && [.F.] Change setting even if required value is current
	tlSupported && [.F.] assume setting is supported (optimization)

toObj = abSet(m.tcSetting, m.tvValueNew, m.tnSetting, m.tlChangeAlways, m.tlSupported)

RETURN Vartype(m.toObj) == 'O'

* =================================================
FUNCTION abSet as abSet of abDev.prg
LPARAMETERS ;
	tcSetting,; && Setting to perform
	tvValueNew,; && Value to set, .T. to toggle ON - OFF
	tnSetting,; && Setting number when appropriate for tcSetting, as of 2nd parameter of set()
	tlChangeAlways,; && [.F.] Change setting even if required value is current
	tlSupported && [.F.] assume setting is supported (optimization)

RETURN CreateObject('abSet', m.tcSetting, m.tvValueNew, m.tnSetting, m.tlChangeAlways, m.tlSupported)

* =================================================
DEFINE CLASS abSet as GA_LIGHTWEIGHT_CLASS of abGA.prg && Saves and restores SET ...
* =================================================

cSetting  = ''
cParm2    = ''
nSetting  = .null.
vValueOld = .null.
vValueNew = .null.
lOnOff = .F.

* ------------------------------------
protected procedure Init && If valid and supported, performs required environment setting
LPARAMETERS ;
	tcSetting,; && Setting to perform
	tvValueNew,; && Value to set, .T. to toggle ON <> OFF
	tnSetting,; && Setting number when appropriate for tcSetting, as of 2nd parameter of set(), eg Set("Alternate", 1) for FileName
	tlChangeAlways,; && [.F.] Change setting even if required value is current
	tlSupported && [.F.] assume setting is supported (optimization)

LOCAL success as Boolean;
, lnSetting;
, lvValueCur;
, lcTypeCur;
, lcTypeNew;
, llToggle

lnSetting = Vartype(m.tnSetting) == 'N'

* If parameters are valid
success = ga_Type_IsChar(m.tcSetting, .T.)
ASSERT m.success MESSAGE cAssertMsg(Textmerge([Invalid setting <<cLitteral(m.tcSetting)>>]))
IF m.success

	success = .F.;
		or !m.lnSetting;
		or ga_Type_IsInteger(m.tnSetting) and Between(m.tnSetting, 1, 4)
	ASSERT m.success MESSAGE cAssertMsg(Textmerge([Invalid value <<cLitteral(m.tnSetting)>>]))
	IF m.success

		tcSetting = Upper(Alltrim(m.tcSetting))
		this.nSetting = Iif(m.lnSetting, m.tnSetting, .null.)
		this.cParm2 = Iif(m.lnSetting, ',' + Transform(m.tnSetting), '')

		* If setting is OK
		success = .T.;
			and (.F.;
				OR lTrue(m.tlSupported);
				OR Vartype(m.tvValueNew) == 'C' AND InList(Upper(Alltrim(m.tvValueNew)), 'ON', 'OFF');
				OR this.lSupported(m.tcSetting, m.this.cParm2); && supported
				);
			and this.Get(@m.lvValueCur, m.tcSetting, m.this.cParm2) && current value can be read
		IF m.success

			* If required value is valid
			lcTypeCur = Vartype(m.lvValueCur)
			lcTypeNew = Vartype(m.tvValueNew)
			llToggle = m.lcTypeNew == 'L' AND m.tvValueNew
			success = m.llToggle OR m.lcTypeNew == m.lcTypeCur
			ASSERT m.success MESSAGE cAssertMsg(Textmerge([For setting '<<m.tcSetting>>', value <<cLitteral(m.tvValueNew)>> should be of type '<<m.lcTypeCur>>']))
			IF m.success
				
				* Adjust value when appropriate
				tvValueNew = Iif(m.tcSetting == 'DEFAULT', Addbs(Fullpath(m.tvValueNew)), m.tvValueNew)
					
				* If setting must be changed
				IF .F.;
				 OR m.llToggle;
				 OR lTrue(m.tlChangeAlways);
				 OR !luEqual(m.lvValueCur, m.tvValueNew,, .T.)
					
					this.lOnOff = m.lcTypeCur == 'C' AND (m.lvValueCur == 'ON' or m.lvValueCur == 'OFF')

					* Toggle value if asked and appropriate
					IF m.llToggle AND m.this.lOnOff
						tvValueNew = Iif(m.lvValueCur = 'ON', 'OFF', 'ON')
					ENDIF

					* If new setting can be performed
					success = this.Set(m.tcSetting, m.tvValueNew)
				ENDIF
				IF m.success
					
					* Persist current values to properties
					this.cSetting = m.tcSetting
					this.vValueOld = m.lvValueCur
					this.vValueNew = m.tvValueNew
				ENDIF
			ENDIF
		ENDIF
	endif
ENDIF

RETURN m.success

* ------------------------------------
HIDDEN FUNCTION Get && état courant d'un SET
lparameters lvResult, tcSetting, lcParm2

local llError, loError as Exception

TRY
	lvResult = Iif(m.tcSetting == 'DEFAULT';
		, Set('DEFAULT') + Curdir();
		, Evaluate("Set('" + m.tcSetting + "'" + m.lcParm2 + ")");
		)

CATCH TO loError
	llError = .T.
	ASSERT .F. MESSAGE cAssertMsg(Textmerge([The requested setting cannot be read: <<"Set('" + m.tcSetting + "'" + m.lcParm2 + ")">> : <<cException(m.loError)>>]))

ENDTRY

return !m.llError

* ------------------------------------
FUNCTION Set && Saves current environment setting and changes to new value
&& public car appelé par awSets.Set()
LPARAMETERS ;
	tcSetting,; && Setting to work on - upper case, trimmed
	tvValueNew && Value to set

LOCAL llResult as Boolean;
, lcSetting as String

llResult = .T.
lcSetting = Upper(Left(m.tcSetting, 4))

do case

case m.this.lOnOff
	set &tcSetting &tvValueNew

case m.lcSetting == 'TEXT' and m.this.nSetting = 1
	tvValueNew = '"' + Stuffc(m.tvValueNew, Len(m.tvValueNew)/2 + 1, 0, '","') + '"'
	set textmerge delimiters to &tvValueNew
	
case m.lcSetting == 'PROC'
	llResult = setProcedure(m.tvValueNew)

otherwise
	llResult = this.Set_(;
		  m.tcSetting;
		, m.tvValueNew;
		)

endcase

ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([Unable to do the following setting : SET <<m.tcSetting>> <<m.tvValueNew>>]))

this.vValueNew = Iif(m.llResult, m.tvValueNew, .null.)

RETURN m.llResult

* ------------------------------------
HIDDEN FUNCTION Set_ && Changes setting to new value
LPARAMETERS ;
	tcSetting,; && Setting to work on
	tvValueNew && Value to set

LOCAL llResult as Boolean;
, loResult as Exception;
, lcValue as String

lcValue = Iif(Vartype(m.tvValueNew) == 'C';
	, Iif(m.tcSetting == 'PATH'; && 21/10/12 - SET PATH does not support literal
		, m.tvValueNew;
		, Iif("'" $ m.tvValueNew, '"' + Rtrim(m.tvValueNew) + '"', "'" + Rtrim(m.tvValueNew) + "'");
		);
	, Transform(m.tvValueNew);
	)

TRY
	SET &tcSetting &lcValue
	llResult = .T.
CATCH to m.loResult

	TRY
		SET &tcSetting &tvValueNew
		llResult = .T.
	CATCH to m.loResult

		TRY
			SET &tcSetting TO (&lcValue)
			llResult = .T.
		CATCH to m.loResult

			TRY
				SET &tcSetting TO &lcValue
				llResult = .T.
			CATCH to m.loResult

				TRY
					SET &tcSetting TO &tvValueNew
					llResult = .T.
				CATCH to m.loResult
				ENDTRY
			ENDTRY
		ENDTRY
	ENDTRY
ENDTRY

RETURN m.llResult

* ------------------------------------
HIDDEN FUNCTION lSupported && Requested environment setting is supported
LPARAMETERS ;
	tcSetting,; && Setting to work on
	lcParm2 && Second parameter of set()

tcSetting = Upper(Alltrim(m.tcSetting))
lcParm2 = Alltrim(m.lcParm2, ' ', ',')

LOCAL llResult as Boolean;
, lcUnsupported;
, lcUntested;
, laResult[1];
, lnResult;
, liResult;
, loResult AS Exception

&&	Reprocess && strange options

TEXT TO m.lcUnsupported NOSHOW FLAGS 1 PRETEXT 3 && Unsupported (or ill-tested) sets
	Century, , 3
	Clock, , 1 && does not restore properly
	Color && Included for backward compatibility
	Date, , 1
	Echo && Included for backward compatibility
	Fields, , 1
	Order && unable to restore
	Printer, , 2
	Printer, , 3
	Skip
	Status Bar && Problem with space between 'Status' and 'Bar' ...
	Topic, .T., 1 && unable to restore
	View && unable to restore
ENDTEXT
TEXT TO m.lcUntested NOSHOW FLAGS 1 PRETEXT 3 && Untested sets
	Help, , 1
	Help, , 2
	Help, , 3
	Key, , 1
	Key, , 2
	Textmerge, , 4
	Topic, , 1
	Step
	Display && Included for backward compatibility
	Filter
	Helpfilter
	Pdsetup
	Relation
endtext

#if .F.
	Textmerge, , 1 && unable to restore - set textmerge delimiters to ...
#endif

TRY && aLinesCols() may not be in scope
	
	if lProperty(_screen, 'abSet_aSupported')
		lnResult = Alen(_screen.abSet_aSupported, 1)
		dimension laResult[m.lnResult, Alen(_screen.abSet_aSupported, 2)]
		Acopy(_screen.abSet_aSupported, laResult)
	else
		lnResult = aLinesCols(; && very long ! - to be optimized
			  @m.laResult;
			, Upper(Chrtran(cInLineCommentStripped(m.lcUnsupported + CRLF + m.lcUntested), Space(1), Space(0)));
			, ',';
			, 'CLC';
			)
		Asort(m.laResult, 1)
		AddProperty(_screen, 'abSet_aSupported[1]')
		dimension _screen.abSet_aSupported[m.lnResult, Alen(laResult, 2)]
		Acopy(laResult, _screen.abSet_aSupported)
	endif
	FOR liResult = 1 TO m.lnResult

		llResult = NOT (m.tcSetting == m.laResult[m.liResult, 1] AND m.lcParm2 == m.laResult[m.liResult, 3])
		IF NOT m.llResult
			EXIT
		ENDIF
	ENDFOR
	ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([this setting is not supported: <<m.tcSetting>> <<m.lcParm2>>]))

CATCH TO loResult
	llResult = .T. && assume setting is supported
ENDTRY

RETURN m.llResult

* ------------------------------------
hidden function Destroy && Restores setting to its original value

local lvValue

return .T.;
	and this.Get(@m.lvValue, m.this.cSetting, m.this.cParm2);
	and (.F.;
		or m.lvValue == m.this.vValueOld; && lvValue et this.vValueOld sont obtenus par this.Get() donc sont de même type et casse
		or this.Set(m.this.cSetting, m.this.vValueOld);
		)

* =================================================
ENDDEFINE
* =================================================

* ------------------------------------
PROCEDURE abSet1 && Règle un set pour test
LPARAMETERS ;
	tcSetting,; && Setting to perform
	tvValueNew,; && Value to set, .T. to toggle ON - OFF
	tnSetting,; && Setting number when appropriate for tcSetting, as of 2nd parameter of set()
	tlChangeAlways,; && [.T.] Change setting even if required value is current
	tlSupported && [.F.] assume setting is supported

local loSet

RETURN labSet(;
		@m.loSet;
	, m.tcSetting;
	, m.tvValueNew;
	, m.tnSetting;
	, m.tlChangeAlways;
	, m.tlSupported;
	)

* ------------------------------------
PROCEDURE abSet1_Test && Teste le réglage d'un set pour mesurer le temps d'exécution

LOCAL loUnitTest as abUnitTest of abDev.prg, loAsserts as abSet
loUnitTest = NewObject('abUnitTest', 'abDev.prg')
loAsserts = abSet('ASSERTS', 'OFF') && pour les settings non supportés

loUnitTest.Test(.T., 'Deleted', 'ON',,,.T.)
loUnitTest.Test(.T., 'Exact', 'ON')
loUnitTest.Test(.T., 'Ansi', 'ON')
loUnitTest.Test(.T., 'Asserts', 'ON')
loUnitTest.Test(.T., 'Safety', 'OFF')
loUnitTest.Test(.T., 'Notify', 'OFF')
loUnitTest.Test(.T., 'Talk', 'OFF')
loUnitTest.Test(.T., 'NullDisplay', '-')
loUnitTest.Test(.T., 'Datasession', 2)

loUnitTest.Test(.F., 'Skip', 'TO cALIAS')
		
RETURN loUnitTest.Result()

* ------------------------------------
PROCEDURE abSet_Tests && Tests the abSet Class

LOCAL llResult;
, lcResult, lnSeconds;
, loSelect as abSelect, loTalk as abSet, loStatusBar as abSet, loAsserts as abSet;
, lcTestFile, laPrinters[1], loSession as Session;
, laSets[1], lnSets, lcSet, llSet, loSet as abSet OF abDev.prg;
, lnFailed;
, lcSetting, lvValueOld, lvValueNew, lcParm2;
, llRestore

loSelect = abSelect()
loTalk = abSet('Talk', 'OFF')
loStatusBar = abSet('Status Bar', 'OFF')
loAsserts = abSet('Asserts', 'OFF')

* Prepare test resources
lcTestFile = Sys(2023) + 'abSet.txt'
APrinters(m.laPrinters)

OPEN DATABASE (_samples + 'Tastrade\Data\tastrade.dbc')
USE IN Select('customer')
USE tastrade!customer SHARED ORDER COMPANY_NA
SET DATABASE TO

loSession = CreateObject('session')
	
lnSeconds = Seconds()
lcResult = ''
lnFailed = 0
STORE .T. TO m.llResult, m.llSet, m.llRestore

* For each test Set
lnSets = abSet_Tests_aSets(@m.laSets)
FOR EACH m.lcSet IN m.laSets

	lcSet = cInLineCommentStripped(m.lcSet)

	* If Setting object can be instanciated
	loSet = abSet(&lcSet)
	llSet = Vartype(m.loSet) == 'O' AND NOT IsNull(m.loSet)
	IF m.llSet
	
		* Memorize old values
		lcSetting = m.loSet.cSetting
		lvValueOld = m.loSet.vValueOld
		lcParm2 = m.loSet.cParm2
	ELSE
		STORE Space(0) TO m.lcSetting, m.lvValueOld, m.lcParm2
	ENDIF

	* Check new value was correctly SET

	* Release Setting object to restore original setting
	loSet = .NULL.

	* Check old value was correctly restored
	IF m.llSet
		lvValueNew = Evaluate('Set("' + m.lcSetting + '"' + m.lcParm2 + ')')
		lvValueNew = Iif(Upper(m.lcSetting) == 'DEFAULT', m.lvValueNew + Curdir(), m.lvValueNew)
		lvValueNew = Iif(Upper(m.lcSetting) == 'PATH', Chrtran(m.lvValueNew, ['"], Space(0)), m.lvValueNew)
		llRestore = m.lvValueOld == m.lvValueNew
		llSet = m.llRestore
	endif
	
	clear

	* Save any Error
	IF NOT m.llSet
		lnFailed = m.lnFailed + 1
		lcResult = m.lcResult + CRLF + '- ' + ;
			Iif(m.llRestore, ;
				"Unable to set" + Replicate('.', 5) + m.lcSet, ;
				"Unable to restore" + Replicate('.', 3) + m.lcSetting + ', '  + Left(Transform(m.lvValueOld), 50) + m.lcParm2) 
		llResult = .F.
	ENDIF
ENDFOR

USE
CLOSE DATABASES

* Display result
lcResult = Iif(m.llResult, ;
		'Congratulation, the ' + Transform(m.lnSets) + ' Tested Sets Worked !', ;
		Transform(m.lnFailed) + ' of ' + Transform(m.lnSets) + ' Set' + Iif(m.lnFailed > 1, 's', '') + ' did not work :' + ;
			CRLF + m.lcResult + ;
			CRLF + CRLF + "This message is copied to the clipboard for later check.")

lcResult = m.lcResult + ;
	CRLF + CRLF + "Average execution time : " + Transform((Seconds()-m.lnSeconds)/m.lnSets * 1000) + " ms" + ;
	CRLF + CRLF + "Thank you for testing abSet class." + ;
	CRLF + "Please check out http://foxincloud.com/"
	
_cliptext = m.lcResult
MessageBox(m.lcResult, 64)

RETURN m.llResult

* ------------------------------------
PROCEDURE abSet_Tests_aSets && Tested Sets
LPARAMETERS taSets && @ Array where tested sets should be stored
EXTERNAL ARRAY taSets

LOCAL lnResult; && Number of Tested Sets
, lnVersion;
, lcSets, lcSetsVFP7, lcSetsVFP8, lcSetsVFP9

lnResult = 0

TEXT TO m.lcSetsVFP7 NOSHOW && SET, .T. on "ON/OFF"-type Settings to toggle, TO ...
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

TEXT TO m.lcSetsVFP8 NOSHOW
	'EngineBehavior', 70
	'TableValidate', 8
	'AutoincError', .T.
ENDTEXT

TEXT TO m.lcSetsVFP9 NOSHOW
	'ReportBehavior', 80
	'SQLBuffering', .T.
	'TablePrompt', .T.
	'VarCharMapping', .T.
ENDTEXT

lnVersion = Version(5)

lcSets = '';
	+ m.lcSetsVFP7;
	+ Iif(m.lnVersion >= 800, CRLF + m.lcSetsVFP8, Space(0));
	+ Iif(m.lnVersion >= 900, CRLF + m.lcSetsVFP9, Space(0))
lcSets = Strtran(m.lcSets, CRLF2, CRLF)

lnResult = ALines(m.taSets, m.lcSets)

RETURN m.lnResult

* ===========================================
DEFINE CLASS abSets as GA_LIGHTWEIGHT_CLASS of abGA.prg && Règle plusieurs Sets et les restaure à la destruction && Custom pour pouvoir être .AddObjected(), mais impossible dans awAppHost as session
* ===========================================

PROTECTED lSupported, lInit

lSupported = .F. && assume abSet supports all the settings required
lInit = .T. && all settings were successful && See in this.Set() why default is .T.

*---------------------------------------------------------------------------
PROCEDURE Init
lparameters result && @ {en} error if any {fr} erreur éventuelle

#if .F. && Sample implementation
WITH m.this as abSets of abDev.prg
	.Set('EngineBehavior', 70)
	.Set('Deleted', 'ON')
	.Set('Exact', 'ON')
	.Set('Ansi', 'ON')
	.Set('Palette', 'OFF')
	.Set('Asserts', 'ON')
	.Set('Safety', 'OFF')
	.Set('Notify', 'OFF')
	.Set('Talk', 'OFF')
ENDWITH
#endif && Sample implementation

RETURN m.this.lInit && always keep this instruction and/or call dodefault() in sub-class!

*---------------------------------------------------------------------------
PROTECTED PROCEDURE Set && Effectue un réglage d'environnement
LPARAMETERS ;
	tcSetting,; && Nom du SET à régler
	tvValueNew,; && Valeur à régler
	tnSetting,; && Setting number when appropriate for tcSetting, as of 2nd parameter of set()
	tlChangeAlways,; && [.T.] Change setting even if required value is current
	tlSupported && [this.lSupported] assume abSet() supports this setting

LOCAL success as Boolean;
, loExact as abSet of abDev.prg;
, lcProp as String;
, loProp as abSet of abDev.prg;

* Si le Set est défini
success = NOT Empty(m.tcSetting)
assert m.success
IF m.success

	tcSetting = Iif(ga_Type_IsChar(m.tcSetting, .T.), Upper(m.tcSetting), '')

	tlSupported = Iif(Pcount() >= 5;
		, lTrue(m.tlSupported);
		, m.this.lSupported;
		)

	loExact = abSet('EXACT', 'OFF')

	lcProp = Chrtran(m.tcSetting, ' ', '')
	lcProp = 'o';
		+ Iif(InList(m.lcProp, Upper('Auto'), Upper('color'), Upper('event'), Upper('status'));
			, m.lcProp;
			, Left(m.lcProp, 4);
			);
		+ Iif(Empty(m.tnSetting), '', Cast(m.tnSetting as M))

	loExact = .null.

	do case

	case !lProperty(m.this, m.lcProp)
		success = .T.;
			and AddProperty(m.this, m.lcProp, abSet(m.tcSetting, m.tvValueNew, m.tnSetting, m.tlChangeAlways, m.tlSupported));
			and Vartype(GetPem(m.this, m.lcProp)) == 'O'

	case .T.;
	 and varSet(@m.loProp, Evaluate('m.this.' + m.lcProp));
	 and m.loProp.vValueNew # m.tvValueNew
	
		success = m.loProp.set(m.tcSetting, m.tvValueNew)

	endcase
endif

this.lInit = m.this.lInit AND m.success

assert m.success message cAssertMsg(Textmerge(ICase(;
	cLangUser() = 'fr',	[Le réglage de SET <<m.tcSetting>> à la valeur <<cL(m.tvValueNew)>> a échoué.],; && copy-paste this line to add another language support
											[Setting <<m.tcSetting>> to value <<cL(m.tvValueNew)>> failed.];
	)))

RETURN m.success

* ===========================================
ENDDEFINE && CLASS abSets
* ===========================================

* ===========================================
function abSetsMaintain && Sauve les sets critiques et les restore s'ils ont changé
return CreateObject('abSetsMaintain')

* ------------------------------------
PROCEDURE abSetsMaintain_Test && Test abSetsMaintain()

LOCAL loUnitTest as abUnitTest OF abDev.prg, loResult
loUnitTest = NewObject('abUnitTest', 'abDev.prg')
loResult = NewObject('abSetsMaintain', 'abDev.prg')

*loUnitTest.coverageSet(.T.)
loUnitTest.Test(.null.) && 1 ms
*loUnitTest.coverageSet(.F.)

return m.loUnitTest.Result()

* ===========================================
DEFINE CLASS abSetsMaintain as GA_LIGHTWEIGHT_CLASS of abGA.prg && Sauve les sets critiques et les restore s'ils ont changé
* ===========================================

hidden aSet[1], nSets

*---------------------------------------------------------------------------
protected procedure Init
lparameters tlProcClass && [.F.] also save Set("Procedure") & Set("Classlib")

local success as Boolean;
, lcSets, lnSets, laSet[1], liSet

#if .F.
	COMPATIBLE, 1
	CENTURY, 2
	REPROCESS, 1
	REPROCESS, 2
	REPROCESS, 3
	TALK, 1
	TEXTMERGE, 4
	NOTIFY, 1
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
endtext

lcSets = m.lcSets + Iif(m.tlProcClass;
	, CRLF;
		+ 'PROCEDURE' + CRLF;
		+ 'CLASSLIB' + CRLF;
	, '';
	)

store aLines(m.laSet, m.lcSets, 5) to lnSets, this.nSets
success = m.lnSets > 0
if m.success

	aColsIns(@m.laSet, 1, 2)
	
	for liSet = 1 to m.lnSets

		laSet[m.liSet, 2] = Evl(Int(Val(GetWordNum(m.laSet[m.liSet, 1], 2, ','))), '')
		laSet[m.liSet, 1] = Alltrim(GetWordNum(m.laSet[m.liSet, 1], 1, ','))
		laSet[m.liSet, 3] = this.uSet(laSet[m.liSet, 1], laSet[m.liSet, 2])
		
	endfor
	
	dimension this.aSet[m.lnSets, 3]
	Acopy(m.laSet, this.aSet)

endif

return m.success

*---------------------------------------------------------------------------
protected procedure uSet
lparameters lcSet, lnSet

return ICase(;
		m.lcSet == 'DEFAULT',;
			Set(m.lcSet) + Curdir(),;
		Empty(m.lnSet),;
			Set(m.lcSet),;
			Set(m.lcSet, m.lnSet);
		)

*---------------------------------------------------------------------------
protected procedure Destroy

local liSet, lcSet, luSet, lnSet

for liSet = 1 to this.nSets

	if !this.aSet[m.liSet, 3] == this.uSet(this.aSet[m.liSet, 1], this.aSet[m.liSet, 2])

		lcSet = this.aSet[m.liSet, 1]
		lnSet = this.aSet[m.liSet, 2]
		luSet = this.aSet[m.liSet, 3]

		do case

		case Empty(m.lnSet) and Vartype(m.luSet) == 'C' and m.luSet $ 'ON,OFF'
			set &lcSet &luSet

		case m.lcSet == 'TEXTMERGE'
			do case
			case m.lnSet = 1 && cLeftDelimiter and cRightDelimiter
				luSet = '"' + Stuffc(m.luSet, Len(m.luSet)/2 + 1, 0, '","') + '"'
				set textmerge delimiters to &luSet
			case m.lnSet = 2 && cFileName
				set textmerge to (m.luSet)
			case m.lnSet = 3 && SHOW/NOSHOW
				set textmerge to &luSet
			endcase
		
		case InList(m.lcSet, 'CENTURY', 'FIELDS', 'MOUSE', 'REFRESH', 'NOCPTRANS')
			set &lcSet to &luSet

		otherwise
			set &lcSet to (m.luSet)

		endcase
	endif
endfor


* ===========================================
ENDDEFINE && CLASS abSetsMaintain
* ===========================================


* ========================================
FUNCTION lSetClasslib && Un jeu de Set("Classlib") est dans le Set("Classlib") courant
LPARAMETERS tcSetClasslib && Jeu de Set("Classlib")

LOCAL laClasslib[1], lcClasslib, lcSetClasslib, llResult

llResult = ALines(laClasslib, m.tcSetClasslib, 5, ',') = 0
IF NOT m.llResult
	
	lcSetClasslib = Set("Classlib")

	FOR EACH lcClasslib IN laClasslib

		llResult = m.lcClasslib $ m.lcSetClasslib
		IF NOT m.llResult
			EXIT
		ENDIF
	ENDFOR
ENDIF

RETURN m.llResult

* ========================================
FUNCTION lSetProcedure && Un jeu de Set("Procedure") est dans le Set("Procedure") courant
LPARAMETERS tcSetProcedure && Jeu de Set("Procedure")

LOCAL laProcedure[1], lcProcedure, lcSetProc, llResult

llResult = ALines(laProcedure, m.tcSetProcedure, 5, ',') = 0
IF NOT m.llResult

	lcSetProc = Set("Procedure")

	FOR EACH lcProcedure IN laProcedure

		llResult = m.lcProcedure $ m.lcSetProc
		IF NOT m.llResult
			EXIT
		ENDIF
	ENDFOR
ENDIF

RETURN m.llResult

* ========================================
FUNCTION cFuncCallParmAdd && Ajoute un paramètre à un appel de fonction
LPARAMETERS ;
	tcFuncCall,; && Chaîne contenant un appel de fonction
	tcParm && Chaîne à ajouter comme paramètre (ex. '@MonParm') /!\ non vérifié
LOCAL llResult, lcResult
lcResult = Space(0)

llResult = Vartype(m.tcFuncCall) == 'C'
IF m.llResult
	lcResult = Alltrim(m.tcFuncCall)
	llResult = Right(m.lcResult, 1) == ')'
	IF m.llResult
	
		llResult = Vartype(m.tcParm) == 'C' AND NOT Empty(m.tcParm)
		IF m.llResult
		
			LOCAL lcParm
			lcParm = Alltrim(m.tcParm)
			lcParm = Iif(Left(m.lcParm, 1) == ',', Space(0), ',') + m.lcParm
			lcResult = Left(m.lcResult, Len(m.lcResult) - 1) + m.lcParm + ')'
		ENDIF
	ENDIF
ENDIF

RETURN m.lcResult

* ------------------------------------
PROCEDURE cFuncCallParmAdd_Test && Teste cFuncCallParmAdd()

LOCAL loUnitTest as abUnitTest of abDev.prg
loUnitTest = NewObject('abUnitTest', 'abDev.prg')

loUnitTest.Test('myFunc(toto,m.lcTest)', ' myFunc(toto)', 'm.lcTest')
		
RETURN loUnitTest.Result()

* ========================================
FUNCTION cException && Message d'exception standard
LPARAMETERS toException as Exception && Objet exception

LOCAL lcResult, luUserValue

lcResult = ''

IF Vartype(m.toException) == 'O' AND Type('m.toException.BaseClass') == 'C' and m.toException.BaseClass == 'Exception'

	WITH m.toException AS Exception
		
		lcResult = cLitteral(.LineContents)
		lcResult = Iif(_VFP.StartMode = 0;
			, Textmerge(ICase(;
					cLangUser() = 'fr',	[ (<<Iif('...' $ .LineContents, 'code source N/D', m.lcResult)>>)],; && copy-paste this line to add another language support
															[ (<<Iif('...' $ .LineContents, 'source code N/A', m.lcResult)>>)];
				));
			, Space(0);
			)
		luUserValue = Iif(Vartype(.UserValue) == 'O' AND Proper(.UserValue.BaseClass) == 'Exception', cException(.UserValue), .UserValue)
		lcResult = Textmerge(ICase(;
			cLangUser() = 'fr',	[Méthode ou procédure <<.Procedure>>() : erreur n° <<.ErrorNo>> ("<<c2Words(.Message,' - ', m.luUserValue)>>") à la ligne n° <<.LineNo>><<m.lcResult>>],; && copy-paste this line to add another language support
													[Method or procedure <<.Procedure>>(): error #<<.ErrorNo>> ("<<c2Words(.Message,' - ', m.luUserValue)>>") at code line #<<.LineNo>><<m.lcResult>>];
			))
	ENDWITH
ENDIF

RETURN m.lcResult

* ------------------------------------
PROCEDURE cException_Test && Teste cException()

LOCAL loUnitTest AS abUnitTest of abDev.prg, lcCmd, loException as Exception, lcResult

loUnitTest = NewObject('abUnitTest', 'abDev.prg')
TRY
	lcCmd = 'crash'
	&lcCmd
CATCH TO loException
	lcResult = "Une exception s'est produite :";
	+ CRLF + "> Méthode : " + m.loException.Procedure ;
	+ CRLF + "> Erreur n° : " + Transform(m.loException.ErrorNo) ;
	+ CRLF + "> Erreur : " + m.loException.Message ;
	+ CRLF + "> Ligne de code n° : " + Transform(m.loException.LineNo) ;
	+ CRLF + "> Ligne de code : " + m.loException.LineContents
FINALLY
	loUnitTest.Test(m.lcResult, m.loException)
ENDTRY 
	
RETURN loUnitTest.Result()

* ---------------------------------------------------
PROCEDURE FilesCompile && Compile des fichiers d'après un squelette
LPARAMETERS ;
	tcFilesSkeleton,; && Squelette d'adresse de fichiers
	tcFilesFailed && @ [''] Fichiers dont la compilation a échoué
tcFilesFailed = Space(0)

LOCAL lnFiles, laFiles[1], llResult, lnResult && Nombre de fichiers compilés avec succès
lnResult = 0

* S'il existe au moins un fichier répondant au masque spécifié
lnFiles = aFiles(@m.laFiles, m.tcFilesSkeleton)
llResult = m.lnFiles > 0
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([No file match the specified skeleton: <<cLitteral(m.tcFilesSkeleton)>>]))
IF m.llResult

	LOCAL lcFolderAddr, loProc, loClass, lnFile, lcFile, lnFilesFailed, laFilesFailed[1]
	lcFolderAddr = Addbs(JustPath(m.tcFilesSkeleton))
	
	* Sauver les set car COMPILE ferme automatiquement les fichiers
	loProc = abSet('PROCEDURE', Set("Procedure"),,, .T.)
	loClass = abSet('CLASSLIB', Set("ClassLib"),,, .T.)

	DEBUGOUT Space(1)
	DEBUGOUT Replicate('=', 50)
	DEBUGOUT "Compiling", Transform(m.lnFiles), 'files in', m.lcFolderAddr

	* Pour chaque fichier
	lnFilesFailed = 0
	FOR lnFile = 1 TO m.lnFiles
		lcFile = laFiles[m.lnFile, 1]
		
		* Compiler le fichier
		llResult = FileCompile(m.lcFolderAddr + m.lcFile)
		
		* Si succès, compter
		IF m.llResult
			lnResult = m.lnResult + 1
		* Sinon, tabuler
		ELSE
			lnFilesFailed = lnFilesFailed + 1
			DIMENSION laFilesFailed[m.lnFilesFailed]
			laFilesFailed[m.lnFilesFailed] = m.lcFile
		ENDIF
	ENDFOR
	
	RELEASE loProc, loClass && Rétablit les SET

	DEBUGOUT Transform(m.lnResult), "files compiled out of", Transform(m.lnFiles)
	DEBUGOUT Replicate('=', 50)
	
	* Si échec(s), lister les fichiers
	IF m.lnFilesFailed > 0
		tcFilesFailed = cListOfArray(@m.laFilesFailed)
	ENDIF
ENDIF

RETURN m.lnResult

* ---------------------------------------------------
PROCEDURE FileCompile && Compile un fichier
LPARAMETERS ;
	tcFileAddr,; && Adresse du fichier
	tcResult,; && @ [''] Résultat de la compilation
	tcClause,; && [''] Clauses de compilation (pour *.prg)
	tnResult && [0] @ nombre d'erreurs de compilation
tcResult = ''
tcClause = Evl(m.tcClause, Space(0))
tnResult = 0

LOCAL llResult;
, loLogErrors as abSet of abDev.prg;
, loNotify as abSet of abDev.prg;
, lcExt;
, llInSet;

llResult = File(m.tcFileAddr)
tcResult = Textmerge([Le fichier à compiler '<<m.tcFileAddr>>' est introuvable])
ASSERT m.llResult MESSAGE cAssertMsg(m.tcResult)
IF m.llResult

	loLogErrors = abSet('LOGERRORS', 'ON')
	loNotify = abSet('NOTIFY', 'OFF') && supprime le thermomètre d'avancement

	* Tenter la compilation
	tcFileAddr = FullPath(m.tcFileAddr)
	lcExt = JustExt(m.tcFileAddr)
	TRY

		DO CASE

		CASE InList(m.lcExt, 'PRG', 'QPR', 'MPR')
			llInSet = ForceExt(m.tcFileAddr, ICase(m.lcExt == 'PRG', 'FXP', m.lcExt == 'QPR', 'QPX', 'MPX')) $ Set("Procedure")
			COMPILE (m.tcFileAddr) &tcClause
			if m.llInSet
				set procedure to (m.tcFileAddr) additive
			endif

		CASE m.lcExt = 'VCX'
			CLEAR CLASSLIB (m.tcFileAddr) && par sécurité
			COMPILE CLASSLIB (m.tcFileAddr)

		CASE m.lcExt = 'SCX'
			COMPILE FORM (m.tcFileAddr)

	 	CASE m.lcExt = 'FRX'
			COMPILE REPORT (m.tcFileAddr)

	 	CASE m.lcExt = 'LBX'
			COMPILE LABEL (m.tcFileAddr)

		CASE m.lcExt = 'DBC'
			loSet = abSet('DATABASE', '',,, .T.)
			COMPILE DATABASE (m.tcFileAddr)

		CASE InList(m.lcExt, 'INI', 'TXT', 'LOG', 'H')

		OTHERWISE
			tcResult = Textmerge(ICase(;
				cLangUser() = 'fr',	[La compilation du fichier '<<JustFname(m.tcFileAddr)>>' n'est pas supportée],; && copy-paste this line to add another language support
														[Compiling file '<<JustFname(m.tcFileAddr)>>' is not supported]; && default: English
				))
			llResult = .F.
		ENDCASE

*- Inutile car COMPILE fait le PACK
*-				IF InList(m.lcExt, 'SCX', 'VCX', 'FRX', 'LBX', 'DBX') && le code source est dans une table
*-					PACK (m.tcFileAddr)
*-				ENDIF

		IF m.llResult
			tcResult = ForceExt(m.tcFileAddr, 'err')
			llResult = NOT File(m.tcResult)
			tnResult = Iif(m.llResult, 0, Evl(Occurs('Error in line', FileToStr(m.tcResult)), 1))
			tcResult = Iif(m.llResult;
				, ICase(;
						cLangUser() = 'fr',	[sans erreur],; && copy-paste this line to add another language support
																[successfully]; && default: English
					);
				, ICase(;
						cLangUser() = 'fr',	[avec erreur(s) : ],; && copy-paste this line to add another language support
																[with error(s): ]; && default: English
					) + CRLF + FileToStr(m.tcResult);
				)
			tcResult = Textmerge(ICase(;
					cLangUser() = 'fr',	[Fichier '<<JustFname(m.tcFileAddr)>>' compilé <<m.tcResult>>],; && copy-paste this line to add another language support
															[File '<<JustFname(m.tcFileAddr)>>' compiled <<m.tcResult>>]; && default: English
				))
		ENDIF
		
	CATCH TO m.loException

		llResult = .F.
		tcResult = '';
			+ cException(m.loException);
			+ ' - ';
			+ Textmerge(ICase(;
					cLangUser() = 'fr',	[Fichier '<<JustFname(m.tcFileAddr)>>'],; && copy-paste this line to add another language support
															[File '<<JustFname(m.tcFileAddr)>>']; && default: English
				));
			+ Iif(Empty(m.tcClause), Space(0), ' - ' + m.tcClause)
				
		?? Chr(7)
	ENDTRY

	tcResult = Iif(Empty(m.tcResult), '', Textmerge([[<<Proper(Program())>>() - <<m.tcResult>>]))
	DEBUGOUT m.tcResult
ENDIF

RETURN m.llResult

* ========================================
PROCEDURE ProcEmpty && Sert à mesurer le temps moyen d'appel d'une procédure
LPARAMETERS ;
	Parm1,; && Bidon
	Parm2,; && Bidon
	Parm3,; && Bidon
	Parm4,; && Bidon
	Parm5,; && Bidon
	Parm6 && Bidon
LOCAL llResult
llResult = .T.
uDefault(m.Parm1, 'bidon')
RETURN m.llResult

* ------------------------------------
PROCEDURE ProcEmpty_Test && Teste ProcEmpty()

LOCAL loUnitTest AS abUnitTest OF abDev.prg
loUnitTest = NewObject('abUnitTest', 'abDev.prg')

loUnitTest.test(.T.)
loUnitTest.test(.T., 2, 'bidon', .F., date())

RETURN loUnitTest.Result()

* ========================================
FUNCTION cPWRand && Mot de passe aléatoire sûr selon indications Windows
LPARAMETERS tnLength && [8] Nombre de caractères

LOCAL lcResult, lcCars, lnCars, lnCar

&& Passwords must contain characters from three of the following five categories:
lcCars = '';
	+ 'ABCDEFGHIKKLMNOPQRSTUVWXYZ'; && Uppercase characters of European languages (A through Z, with diacritic marks, Greek and Cyrillic characters)
	+ 'abcdefghikklmnopqrstuvwxyz'; && Lowercase characters of European languages (a through z, sharp-s, with diacritic marks, Greek and Cyrillic characters)
	+ '0123456789'; && Base 10 digits (0 through 9)
	+ '!@#$%&*_-+=/|\(){}[];"' + ['<>,.?]; && Nonalphanumeric characters && ^~`: removed those difficult to type or conflicting with usual syntax
	+ '' && Any Unicode character that is categorized as an alphabetic character but is not uppercase or lowercase. This includes Unicode characters from Asian languages.

lnCars = Len(m.lcCars)
lcResult = ''

Rand(-1) && To achieve the most random sequence of numbers, issue RAND( ) initially with a negative argument and then issue RAND( ) without an argument. 
FOR lnCar = 1 TO Iif(Vartype(m.tnLength) = 'N' AND m.tnLength > 0, m.tnLength, 8)
	lcResult = m.lcResult + Substr(m.lcCars, Min(Max(Int(Rand() * m.lnCars), 1), m.lnCars), 1)
ENDFOR

RETURN m.lcResult

* -------------------------------------------------------------
FUNCTION cPWRand_Test && Teste cPWRand

? Sys(16)
? cPWRand()
? cPWRand(15)

* ========================================
DEFINE CLASS abProject as GA_LIGHTWEIGHT_CLASS of abGA.prg && ouvre un projet et le referme automatiquement

oProject = .NULL. && Référence au projet
lOpened = .F. && Le projet a été ouvert - .NULL. le projet a été créé

* ----------------
PROTECTED PROCEDURE Init
LPARAMETERS ;
	tcPJX,; && Adresse du projet
	tcResult && @ Résultat en cas d'échec

LOCAL llOpened, llResult

this.oProject = oProject(m.tcPJX, @m.tcResult, @m.llOpened)
this.lOpened = m.llOpened

RETURN Vartype(m.this.oProject) == 'O'

* ----------------
PROTECTED PROCEDURE Destroy

IF m.this.lOpened OR IsNull(m.this.lOpened)
	this.oProject.Close
ENDIF

ENDDEFINE && CLASS abProject
* ========================================

* ========================================
FUNCTION lProject && Un projet est ouvert
LPARAMETERS tcPJX && Nom du projet

local success as Boolean;
, oProject as Project

if _VFP.Projects.Count > 0
	tcPJX = Lower(JustFname(ForceExt(m.tcPJX, 'pjx')))
	for each oProject in _VFP.Projects foxobject
		if Lower(JustFname(m.oProject.Name)) == m.tcPJX
			success = .T.
			exit
		endif
	endfor
endif

return m.success

* ========================================
FUNCTION oProject && Référence à un projet (ouvert ou créé)
LPARAMETERS ;
	tcPJX,; && Adresse du projet
	tcResult,; && @ Résultat en cas d'erreur
	tlOpened && @ Le projet a été ouvert - .NULL. le projet a été créé
tcResult = Space(0)
tlOpened = .F.

LOCAL loResult AS Project;
, loProject AS Project;
, llResult as Boolean;
, loException as Exception

loResult = .NULL.

IF Vartype(m.tcPJX) == 'C'

	tcPJX = Iif(Empty(JustExt(m.tcPJX)), ForceExt(m.tcPJX, 'pjx'), m.tcPJX)
	IF Lower(JustExt(m.tcPJX)) == 'pjx'
	 
	 	IF File(m.tcPJX)
		 	tcPJX = FullPath(m.tcPJX)

			* Si le projet n'est pas déjà ouvert
			llResult = _VFP.Projects.Count > 0
			IF m.llResult
				llResult = .F.
				FOR EACH loProject IN _VFP.Projects foxobject
					IF FullPath(m.loProject.Name) == m.tcPJX
						llResult = .T.
						loResult = m.loProject && after EXIT, FOR EACH resets loProject to .F.
						EXIT
					ENDIF
				ENDFOR
			ENDIF
	 	ELSE
	 		tlOpened = .NULL.
	 	ENDIF
		IF NOT m.llResult
			
			* Ouvrir le projet
			TRY && évite les erreurs à l'ouverture tel que les fichiers non trouvés && en fait non ça n'empêche pas l'erreur
				MODIFY PROJECT (m.tcPJX) SAVE NOWAIT NOSHOW NOPROJECTHOOK
				loResult = _VFP.ActiveProject
				tlOpened = Iif(IsNull(m.tlOpened), m.tlOpened, .T.)
			CATCH TO loException
				loResult = .NULL.
				tcResult = cException(m.loException)
			ENDTRY
		ENDIF
	ELSE
		tcResult = Textmerge([<<Proper(Program())>>() - Invalid project file extension : <<cLitteral(m.tcPJX)>>])
	ENDIF
ELSE
	tcResult = Textmerge([<<Proper(Program())>>() - Invalid project specification : <<cLitteral(m.tcPJX)>>])
ENDIF

RETURN m.loResult

* ========================================
PROCEDURE ProjectClose && Ferme un projet
LPARAMETERS tcProject && Nom du projet tel qu'il apparaît dans sa barre de titre

LOCAL loProject as Project, lcProject, llResult, lcResult && Adresse du projet pour le réouvrir ultérieurement

lcResult = Space(0)
llResult = Vartype(m.tcProject) == 'C' AND NOT Empty(m.tcProject)
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([Invalid project specification : <<cLitteral(m.tcProject)>>]))
IF m.llResult AND _vfp.Projects.Count > 0

	* Pour chaque projet ouvert
	tcProject = Upper(Alltrim(m.tcProject))
	FOR EACH m.loProject IN _vfp.Projects
		lcProject = m.loProject.Name
	
		* si c'est le projet cherché
		IF Upper(JustStem(m.lcProject)) == m.tcProject
			
			* Fermer
			loProject.Close
			lcResult = m.lcProject
			EXIT
		ENDIF
	ENDFOR
ENDIF

RETURN m.lcResult

* ========================================
FUNCTION abProjectsClose as abProjectsClose of abDev.prg && Ferme les projets à .Init(), les rouvre à .Destroy()
RETURN CreateObject('abProjectsClose')

* ========================================
DEFINE CLASS abProjectsClose as GA_LIGHTWEIGHT_CLASS of abGA.prg && Ferme les projets à .Init(), les rouvre à .Destroy()
* ========================================

	HIDDEN aProjects[1], nProjects

	* ---------------
	PROCEDURE Init

	this.nProjects = Iif(lDevMode();
		, _VFP.Projects.Count;
		, 0;
		)

	IF Empty(m.this.nProjects)
		return .F.
	endif

	LOCAL lnProject, loProject as project

	DIMENSION this.aProjects[m.this.nProjects]

	FOR lnProject = m.this.nProjects TO 1 STEP -1
		loProject = _vfp.Projects(m.lnProject)
		this.aProjects[m.lnProject] = m.loProject.Name
		loProject.Close
	ENDFOR

	* ---------------
	PROCEDURE Destroy

	IF m.this.nProjects > 0
		LOCAL lnProject
		FOR lnProject = m.this.nProjects TO 1 STEP -1
			MODIFY PROJECT (this.aProjects[m.lnProject]) NOWAIT
		ENDFOR
	ENDIF

* ========================================
ENDDEFINE && CLASS abProjectsClose
* ========================================

* ========================================
DEFINE CLASS abDBCsClose as GA_LIGHTWEIGHT_CLASS of abGA.prg && Init() ferme les bases de données, Destroy() les rouvre
* ========================================

	HIDDEN aDBCs[1], nDBCs, cDBCCur

	* ---------------
	PROCEDURE Init

	this.nDBCs = ADatabases(this.aDBCs) && [nom | adresse]

	IF this.nDBCs > 0
		this.cDBCCur = Dbc()

		LOCAL lnDBC
		FOR lnDBC = 1 TO this.nDBCs
			SET DATABASE TO (this.aDBCs[m.lnDBC, 1]) && nom
			CLOSE DATABASES
		ENDFOR
	ENDIF

	* ---------------
	PROCEDURE Destroy

	IF this.nDBCs > 0

		LOCAL lnDBC
		FOR lnDBC = 1 TO this.nDBCs
			OPEN DATABASE (this.aDBCs[m.lnDBC, 2]) && adresse
		ENDFOR
		IF File(this.cDBCCur)
			SET DATABASE TO (m.this.cDBCCur)
		ENDIF
	ENDIF

* ========================================
ENDDEFINE && CLASS abDBCsClose 
* ========================================


* ========================================
FUNCTION nFColor && Couleur d'avant plan
LPARAMETERS tcFColor && Chaîne selon format "RRR,GGG,BBB"
LOCAL lnResult
lnResult = 0 && black

IF Vartype(m.tcFColor) == 'C' AND Occurs(',', m.tcFColor) = 2
	LOCAL ARRAY laFColors[1]
	ALines(laFColors, m.tcFColor, 1, ',')
	lnResult = Rgb(Val(laFColors[1]), Val(laFColors[2]), Val(laFColors[3]))
ENDIF

RETURN m.lnResult

* ========================================
FUNCTION nBColor && Couleur d'arrière plan
LPARAMETERS tcBColor && Chaîne selon format "RRR,GGG,BBB"

LOCAL lnResult
lnResult = Rgb(255, 255, 255) && white

IF Vartype(m.tcBColor) == 'C' AND Occurs(',', m.tcBColor) = 2
	LOCAL ARRAY laBColors[1]
	ALines(laBColors, m.tcBColor, 1, ',')
	lnResult = Rgb(Val(laBColors[1]), Val(laBColors[2]), Val(laBColors[3]))
ENDIF

RETURN m.lnResult

* =================================================
function abISX && Arrête et redémarre ISX (nécessaire en développement de formulaires)
return CreateObject('abISX')

* =================================================
DEFINE CLASS abISX as GA_LIGHTWEIGHT_CLASS of abGA.prg && Arrête et redémarre ISX (nécessaire en développement de formulaires)
* =================================================
HIDDEN lISX, cISX

lISX = File('ISX.fxp')

* ------------------------------------
PROCEDURE Init && Désactive ISX

*	return .F.

IF m.this.lISX and lDevMode() && lDevMode() par sécurité, évite un WAIT en unattended server mode
	this.cISX = FullPath('ISX.fxp')
	LOCAL lcISX
	lcISX = "ISX('QUIT')" && évite d'embarquer ISX dans le projet
	&lcISX
else
	return .F.
ENDIF

* ------------------------------------
PROCEDURE Destroy && Résactive ISX
LOCAL lcISX
lcISX = 'DO "' + m.this.cISX + '"' && évite d'embarquer ISX dans le projet
&lcISX

* =================================================
ENDDEFINE && CLASS abISX
* =================================================

* ------------------------------------
FUNCTION uValue && Valeur convertie selon le varType spécifié (AKA coercition de type)
LPARAMETERS ;
	tuValue,; && Valeur source
 	tcTypeDest && Type de valeur attendu selon codification de la fonction VFP varType()

&& /!\ pourrait être simplifiée et optimisée avec Cast()

LOCAL luResult;
, llResult;
, lcTypeSrce;
, lcTypeDest;

luResult = .NULL.

#IF .F. && Vartype() VFP9
	C && Character, Memo, Varchar, Varchar (Binary)
	D && Date 
	G && General 
	L && Logical 
	N && Numeric, Float, Double, or Integer
	O && Object
	Q && Blob, Varbinary
	T && DateTime 
	U && Unknown or variable does not exist
	X && .NULL.
	Y && Currency
	I && Integer && support additionnel
#ENDIF

llResult = Vartype(m.tcTypeDest) == 'C'
IF m.llResult
	lcTypeDest = Upper(Alltrim(m.tcTypeDest))
	llResult = Len(m.lcTypeDest) = 1 AND m.lcTypeDest $ 'CDGLNOQTUXYI'
ENDIF
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge("Spécification de type non supportée : <<cLitteral(m.tcTypeDest)>>"))
IF m.llResult

	lcTypeSrce = Vartype(m.tuValue)
	llResult = m.lcTypeSrce $ 'CNYLDTX'
	ASSERT m.llResult MESSAGE cAssertMsg(Textmerge("Type de valeur non supportée : <<cLitteral(m.lcTypeSrce)>>"))
	IF m.llResult
	
		IF m.lcTypeDest == m.lcTypeSrce
			luResult = m.tuValue
		ELSE

			DO CASE

			CASE m.lcTypeSrce == 'C'
				tuValue = Upper(Alltrim(m.tuValue))
				IF m.lcTypeDest $ 'YNI'

					* Normaliser le point décimal éventuel, supprimer les séparateurs de milliers
					LOCAL lcPoint, lcSeparator, lcChars
					lcPoint = Set("Point")
					lcSeparator = Set("Separator")
					lcChars = m.lcSeparator + Space(1) + Set("Currency", 1) + '$'
					tuValue = Iif(m.lcSeparator == '.';
						, Chrtran(m.tuValue, m.lcChars, '');
						, Chrtran(m.tuValue, '.' + m.lcChars, m.lcPoint);
						)
					ASSERT Occurs(m.lcPoint, m.tuValue) <= 1 MESSAGE cAssertMsg(Textmerge([Plus d'un séparateur décimal dans le nombre <<m.tuValue>>]))
				ENDIF
				luResult = ICase(;
					m.lcTypeDest == 'N', Val(m.tuValue),;
					m.lcTypeDest == 'Y', Ntom(Val(m.tuValue)),;
					m.lcTypeDest == 'I', Int(Val(m.tuValue)),;
					m.lcTypeDest == 'L', ICase(InList(m.tuValue, 'T', '.T.', 'VRAI', 'TRUE'), .T., Empty(m.tuValue) OR InList(m.tuValue, 'F', '.F.', 'FAUX', 'FALSE'), .F., Evaluate(m.tuValue)),;
					m.lcTypeDest $ 'DT', Iif(Left(m.tuValue, 1) = '{', Evaluate(m.tuValue), uValue_TD(m.tuValue, m.lcTypeDest)),;
					.NULL.)
				IF m.lcTypeDest $ 'DT' && Ctod() et Ctot() peuvent produire un résultat invalide
					TRY
						Dtoc(m.luResult)
					CATCH
						luResult = Iif(m.lcTypeDest == 'D', {}, {/:})
					ENDTRY
				ENDIF

			CASE m.lcTypeSrce == 'N'
				luResult = ICase(;
					m.lcTypeDest == 'C', Transform(m.tuValue),;
					m.lcTypeDest == 'I', Int(m.tuValue),;
					m.lcTypeDest == 'Y', Ntom(m.tuValue),;
					m.lcTypeDest == 'L', m.tuValue != 0,;
					.NULL.)	

			CASE m.lcTypeSrce $ 'DT'
				luResult = ICase(;
					m.lcTypeDest == 'C', cLitteral(m.tuValue),; && mieux que Cast()
					m.lcTypeDest == 'D', Ttod(m.tuValue),;
					m.lcTypeDest == 'T', Dtot(m.tuValue),;
					.NULL.)	

			CASE m.lcTypeSrce == 'L'
				luResult = ICase(;
					m.lcTypeDest == 'C', cLitteral(m.tuValue),;
					m.lcTypeDest $ 'NI', Iif(m.tuValue, 1, 0),;
					.NULL.)	
			
			CASE m.lcTypeSrce == 'Y'
				luResult = ICase(;
					m.lcTypeDest == 'C', Transform(m.tuValue),;
					m.lcTypeDest == 'N', Mton(m.tuValue),;
					m.lcTypeDest == 'I', Int(Mton(m.tuValue)),;
					m.lcTypeDest == 'L', NOT m.tuValue = Ntom(0),;
					.NULL.)	

			CASE m.lcTypeSrce == 'X'
				luResult = uEmpty(m.lcTypeDest)

			OTHERWISE
				luResult = .NULL.
			ENDCASE
		ENDIF
	ENDIF
ENDIF

RETURN m.luResult

* ------------------------------------
FUNCTION uValue_TD
LPARAMETERS ;
  tuValue; && Valeur source
, tcTypeDest; && Type de valeur attendu selon codification de la fonction VFP varType()

local cMark, lCentury, cDate, cTime

cMark = Evl(Set("Mark"), '/')

tuValue = Strtran(Strtran(Strtran(Strtran(Chrtran(cRepCharDel(Alltrim(m.tuValue));
	, '-', m.cMark); && iPhone
	, ' ' + m.cMark, m.cMark);
	, m.cMark + ' ', m.cMark);
	, ' :', ':');
	, ': ', ':');

lCentury = Len(GetWordNum(m.tuValue, 1, '/')) = 4 && YYYY/MM/DD assumed

do case

case !Vartype(m.tuValue) == 'C';
 or Occurs(m.cMark, m.tuValue) # 2; && 2015-06-16 - {en} default values in case m.tuValue is not a date, eg. "boto" - contributor Gilles Lajot-Sarthou
 or Empty(Chrtran(m.tuValue, m.cMark+':APM', ''))
	return Iif(m.tcTypeDest = 'D', {/}, {/:}) && {en} empty date[-time] {fr} date[-time] vide

case Left(m.tuValue, 1) == '{' and Right(m.tuValue, 1) == '}' && litteral
	return Evaluate(m.tuValue)

case m.lCentury and m.tcTypeDest = 'D' && 
	cDate = m.tuValue
	return Date(;
		  Evl(Int(Val(GetWordNum(m.cDate, 1, m.cMark))), Year(Date())); && year
		, Evl(Int(Val(GetWordNum(m.cDate, 2, m.cMark))), Month(Date())); && month
		, Evl(Int(Val(GetWordNum(m.cDate, 3, m.cMark))), Day(Date())); && day
		)

case m.lCentury && m.tcTypeDest = 'T'
	cDate = GetWordNum(m.tuValue, 1)
	cTime = GetWordNum(m.tuValue, 2)
	return Datetime(;
		  Evl(Int(Val(GetWordNum(m.cDate, 1, m.cMark))), Year(Date())); && year
		, Evl(Int(Val(GetWordNum(m.cDate, 2, m.cMark))), Month(Date())); && month
		, Evl(Int(Val(GetWordNum(m.cDate, 3, m.cMark))), Day(Date())); && day
		, Int(Val(GetWordNum(m.cTime, 1, ':'))); && hour
		, Int(Val(GetWordNum(m.cTime, 2, ':'))); && minute
		, Int(Val(GetWordNum(m.cTime, 3, ':'))); && seconds
		)

case m.tcTypeDest = 'D'
	return Ctod(m.tuValue)

otherwise
	return Ctot(m.tuValue)

endcase
endfunc

* -----------------------------------------------------------------
PROCEDURE uValue_Test && Teste uValue()

LOCAL loUnitTest AS abUnitTest OF abDev.prg
loUnitTest = NewObject('uValue_Test', 'abDev.prg')

loUnitTest.Test(1421.5, '1 421,5', 'N')
loUnitTest.Test(1421.5, '1 421.5', 'N')
* loUnitTest.Test(1421.5, '1,421.5', 'N') && échec
loUnitTest.Test($1421.5, '$    1 421.5', 'Y')
loUnitTest.Test(1421, '1 421.5', 'I')

loUnitTest.Test(.T., 'T', 'L')
loUnitTest.Test(.T., 2, 'L')
loUnitTest.Test({}, '23/09/194', 'D') && date invalide && ajouté le 15/05/09

loUnitTest.Test({/}, 'boto', 'D') && 2015-06-16 - contributor Gilles Lajot-Sarthou

RETURN loUnitTest.Result()

	DEFINE CLASS uValue_Test AS abUnitTest OF abDev.prg
		PROCEDURE Init
		DoDefault()
		SET SEPARATOR TO Chr(160)
		SET POINT TO ','
	ENDDEFINE

* =================================================
FUNCTION luEqual && Deux valeurs sont égales en tenant compte des .NULL.
LPARAMETERS ;
	tu1,; && Valeur 1, par référence si Array
	tu2,; && Valeur 2, par référence si Array
	tlStrict,; && [.F.] comparaison de chaînes stricte
	tlCaseIgnore && [.F.] ignorer la casse
tlStrict = lTrue(m.tlStrict)
tlCaseIgnore = lTrue(m.tlCaseIgnore)

LOCAL lcType1, lcType2

lcType1 = Type('tu1', 1)
lcType1 = Iif(m.lcType1 == 'A', m.lcType1, Vartype(m.tu1))
tu1 = Iif(m.lcType1 == 'C' and m.tlCaseIgnore, Lower(m.tu1), m.tu1)

lcType2 = Type('tu2', 1)
lcType2 = Iif(m.lcType2 == 'A', m.lcType2, Vartype(m.tu2))
tu2 = Iif(m.lcType2 == 'C' and m.tlCaseIgnore, Lower(m.tu2), m.tu2)

RETURN m.lcType1 == m.lcType2;
	AND	(m.lcType1 == 'X';
			OR ICase(;
				m.lcType1 == 'O', luEqual_Object(m.tu1, m.tu2),;
				m.lcType1 == 'A', laEqual(@m.tu1, @m.tu2),;
				m.lcType1 == 'C' AND NOT m.tlStrict, Trim(m.tu1) == Trim(m.tu2),;
			 	m.tu1 == m.tu2;
			 	);
		 	)

* --------------------
FUNCTION luEqual_Object	&& Deux objets sont identiques
LPARAMETERS ;
	tu1,; && objet 1
	tu2 && objet 2

LOCAL laProp[1], lcProp, liItem, la1[1], la2[1], llResult

llResult = m.tu1 = m.tu2 && référence au même objet
IF NOT m.llResult 

	llResult = AMembers(laProp, m.tu2) + AMembers(laProp, m.tu1) = 0
	IF NOT m.llResult
		
		FOR EACH lcProp IN laProp

			llResult = .F.;
			 OR InList(m.lcProp, 'PARENT', 'CONTROLS', 'OBJECTS', 'PAGES', 'COLUMNS');
			 OR .T.;
			  AND PemStatus(m.tu2, m.lcProp, 5); && extent
			  AND NOT PemStatus(m.tu1, m.lcProp, 2); && protected
			  AND NOT PemStatus(m.tu2, m.lcProp, 2); && protected
				AND Iif(Type('m.tu1.' + m.lcProp, 1) == 'A';
					, .T.;
						AND Type('m.tu2.' + m.lcProp, 1) == 'A';
						AND Acopy(m.tu1.&lcProp, la1) = Acopy(m.tu2.&lcProp, la2);
						AND laEqual(@m.la1, @m.la2);
					, luEqual(GetPem(m.tu1, m.lcProp), GetPem(m.tu2, m.lcProp));
					)
			IF NOT m.llResult
				EXIT
			ENDIF
		ENDFOR
	ENDIF

	IF m.llResult AND loBaseClass(m.tu1, 'Collection')
		llResult = loBaseClass(m.tu2, 'Collection') AND m.tu1.Count = m.tu2.Count
		IF m.llResult AND  m.tu1.Count > 0
			FOR liItem = 1 TO m.tu1.Count
				llResult = .T.;
					AND luEqual(m.tu1.Item(m.liItem), m.tu2.Item(m.liItem));
					AND m.tu1.getKey(m.liItem) == m.tu2.GetKey(m.liItem)
				IF NOT m.llResult
					EXIT
				ENDIF
			ENDFOR
		ENDIF
	ENDIF
ENDIF

RETURN m.llResult

* --------------------
PROCEDURE luEqual_Test && Teste luEqual

LOCAL loUnitTest as abUnitTest OF abDev.prg
loUnitTest = NewObject('abUnitTest', 'abDev.prg')

loUnitTest.test(.T., .NULL., .NULL.)
loUnitTest.test(.F., .NULL., 2)
loUnitTest.test(.F., 2, .NULL.)
loUnitTest.test(.F., 3, 2)
loUnitTest.test(.F., 3, '2')
loUnitTest.test(.T., 2, 2)
loUnitTest.test(.T., 'toto', 'toto')
loUnitTest.test(.F., 'toto', 'tot')
loUnitTest.test(.F., 'TOTO ', 'toto', .T., .T.)
loUnitTest.test(.T., 'TOTO ', 'toto', , .T.)

RETURN loUnitTest.Result()

* =================================================
FUNCTION cSetPath(tlSort) && Set("Path") bien présenté

LOCAL laResult[1]

ALines(laResult, Set("Path"), 1, ',', ';')
IF m.tlSort
	Asort(laResult)
ENDIF

RETURN cListOfArray(@m.laResult, CRLF)

* =================================================
FUNCTION cSetProc(tlSort) && Set("Procedure") bien présenté

LOCAL laResult[1]

ALines(laResult, Set("Procedure"), 1, ',', ';')
IF m.tlSort
	Asort(laResult)
ENDIF

RETURN cListOfArray(@m.laResult, CRLF)

* =================================================
FUNCTION cSetClass(tlSort) && Set("Classlib") bien présenté

LOCAL laResult[1]

ALines(laResult, Set("Classlib"), 1, ',', ';')
IF m.tlSort
	Asort(laResult)
ENDIF

RETURN cListOfArray(@m.laResult, CRLF)

* =================================================
FUNCTION cMBcmdCaption && Label d'un bouton d'une messageBox() d'après son type
LPARAMETERS ;
	tiType,; && [1] Type selon doc messageBox()
	tcLang,; && [cLangUser()] Langue
	tlHotKey && [.F.] souligner la lettre de raccourci
tiType = Int(Evl(Nvl(m.tiType, 0), 1)) && OK par défaut
tcLang = cLangUser(m.tcLang)

RETURN Iif(lTrue(m.tlHotKey), '\<', '');
	+	ICase(;
			m.tiType = 1, 'OK',;
			m.tiType = 2, ICase(;
        m.tcLang = 'fr',	'Annuler',; && copy-paste this line to add another language support
        m.tcLang = 'es',	'Cancelar',; && copy-paste this line to add another language support
                          'Cancel'),;
			m.tiType = 3, ICase(;
        m.tcLang = 'fr',	'Abandonner',; && copy-paste this line to add another language support
        m.tcLang = 'es',	'Abortar',; && copy-paste this line to add another language support
                          'Abort'),;
			m.tiType = 4, ICase(;
        m.tcLang = 'fr',	'Réessayer',; && copy-paste this line to add another language support
        m.tcLang = 'es',	'Reintentar',; && copy-paste this line to add another language support
                         	'Retry'),;
			m.tiType = 5, ICase(;
        m.tcLang = 'fr',	'Ignorer',; && copy-paste this line to add another language support
        m.tcLang = 'es',	'Ignorar',; && copy-paste this line to add another language support
                          'Ignore'),;
			m.tiType = 6, ICase(;
        m.tcLang = 'fr',	'Oui',; && copy-paste this line to add another language support
        m.tcLang = 'es',	'Sí',; && copy-paste this line to add another language support
                          'Yes'),;
			m.tiType = 7, ICase(;
        m.tcLang = 'fr',	'Non',; && copy-paste this line to add another language support
        m.tcLang = 'es',	'No',; && copy-paste this line to add another language support
                          'No'),;
			'??';
		)

* =================================================
FUNCTION nDialogBoxTypeParms && Composantes du paramètre 'nDialogBoxType' d'une messageBox()
LPARAMETERS ;
	nDialogBoxType,; && cf. messageBox()
	tnButtons,; && @ (0-5) boutons à afficher
	tnIcon,; && @ (16,32,48 ou 64) icône à afficher
	tnDefault && @ (0,256,512) Bouton actif par défaut

tnButtons = Bitand(m.nDialogBoxType, Bitset(Bitset(Bitset(0, 0),1),2))
tnButtons = Iif(Between(m.tnButtons, 0, 5), m.tnButtons, 0)

tnIcon = Bitand(m.nDialogBoxType, Bitset(Bitset(Bitset(0, 4),5),6))
tnIcon = Iif(InList(m.tnIcon, 16,32,48,64), m.tnIcon, 0)

tnDefault = Bitand(m.nDialogBoxType, Bitset(Bitset(0, 8),9))
tnDefault = Iif(InList(m.tnDefault, 256, 512), m.tnDefault, 0)

RETURN m.nDialogBoxType

* --------------------
PROCEDURE nDialogBoxTypeParms_Test && Teste nDialogBoxTypeParms()

LOCAL loUnitTest as abUnitTest OF abDev.prg
loUnitTest = NewObject('abUnitTest', 'abDev.prg')

LOCAL lnDialogBoxType,; && cf. messageBox()
	lnButtons,; && @ (0-5) boutons à afficher
	lnIcon,; && @ (16,32,48 ou 64) icône à afficher
	lnDefault && @ (0,256,512) Bouton actif par défaut

lnDialogBoxType = 5
loUnitTest.test(m.lnDialogBoxType, m.lnDialogBoxType, @m.lnButtons, @m.lnIcon, @m.lnDefault)
loUnitTest.assert(5, m.lnButtons)
loUnitTest.assert(0, m.lnIcon)
loUnitTest.assert(0, m.lnDefault)

lnDialogBoxType = 5+32
loUnitTest.test(m.lnDialogBoxType, m.lnDialogBoxType, @m.lnButtons, @m.lnIcon, @m.lnDefault)
loUnitTest.assert(5, m.lnButtons)
loUnitTest.assert(32, m.lnIcon)
loUnitTest.assert(0, m.lnDefault)

lnDialogBoxType = 5+32+256
loUnitTest.test(m.lnDialogBoxType, m.lnDialogBoxType, @m.lnButtons, @m.lnIcon, @m.lnDefault)
loUnitTest.assert(5, m.lnButtons)
loUnitTest.assert(32, m.lnIcon)
loUnitTest.assert(256, m.lnDefault)


lnDialogBoxType = 7+32+256
loUnitTest.test(m.lnDialogBoxType, m.lnDialogBoxType, @m.lnButtons, @m.lnIcon, @m.lnDefault)
loUnitTest.assert(0, m.lnButtons)
loUnitTest.assert(32, m.lnIcon)
loUnitTest.assert(256, m.lnDefault)

* =================================================
FUNCTION nScreenDockOffset && Nombre de colonnes où commence la partie gauche du _Screen du fait des fenêtres dockées à gauche
LPARAMETERS tlRows && [.F.] décalage ; .T.: vertical (rows), .F.: horizontal (cols)
tlRows = lTrue(m.tlRows)

LOCAL laDock[1], lnDocks, lnDock, lnResult

lnResult = 0
lnDocks = ADockState(laDock, 1) && 
IF m.lnDocks > 0
	FOR m.lnDock = 1 TO m.lnDocks
		IF laDock[m.lnDock, 2] = 1;
		 AND laDock[m.lnDock, 3] = Iif(m.tlRows;
		 	, 0; && top
		 	, 1); && left
		 AND laDock[m.lnDock, 4] = _Screen.Caption

			lnResult = m.lnResult + Iif(m.tlRows, Wrows(laDock[m.lnDock, 1]), Wcols(laDock[m.lnDock, 1]))
		ENDIF
	ENDFOR
ENDIF

RETURN m.lnResult

* =================================================
FUNCTION cABuserDataPath && Adresse standard du dossier où résident les données AB

LOCAL lcResult

lcResult = Home(7) + 'AB\' && Visual FoxPro subdirectory in the user's Visual FoxPro Application Data directory
IF NOT Directory(m.lcResult)
	MD (m.lcResult)
ENDIF

RETURN m.lcResult

* ===========================
FUNCTION cABmoduleTestAddr && Adresse du fichier de test d'un module
LPARAMETERS tcModule
LOCAL lcPrevious, lcResult
lcResult = cABuserDataPath() + ForceExt(m.tcModule, 'tst')

* Si le fichier est à l'ancienne adresse, déplacer dans la nouvelle
lcPrevious = DOS_AB + ForceExt(m.tcModule, 'tst')
IF lFile(m.lcPrevious)
	FileMove(m.lcPrevious, m.lcResult)
ENDIF

RETURN m.lcResult

* ===========================
function cLocalized && Chaîne localisée
lparameters ;
  tcString; && Chaîne à localiser
, tcLangUser; && [cLangUser()] Langue de l'utilisateur

local result as String;
, liLangUser as Integer;
, liEN as Integer;

tcLangUser = Iif(ga_Type_IsChar(m.tcLangUser, .T.) and Lenc(m.tcLangUser) = 2, m.tcLangUser, cLangUser())

liLangUser = At_c('{' + m.tcLangUser + '}', m.tcString)
liEN = At_c('{en}', m.tcString)

result = ICase(;
	m.liLangUser > 0,;
		Substrc(m.tcString, m.liLangUser + 4),;
	m.liEN > 0,;
		Substrc(m.tcString, m.liEN + 4),;
		m.tcString;
	)

return Alltrim(Iif(m.liEN + m.liLangUser > 0;
	, Leftc(m.result, Evl(At_c('{', m.result), Lenc(m.result)+1)-1);
	, m.result;
	), CR, LF, ' ', Chr(9))
endfunc

* ------------------------------------
PROCEDURE cLocalized_Test && Teste cLocalized()

LOCAL loUnitTest as abUnitTest of abDev.prg
loUnitTest = NewObject('abUnitTest', 'abDev.prg')

loUnitTest.Test([formulaire où s'est produit l'événement], [ {en} requested form {fr} formulaire où s'est produit l'événement], 'fr')
loUnitTest.Test([requested form], [ {en} requested form {fr} formulaire où s'est produit l'événement], 'en')
		
RETURN m.loUnitTest.Result()


* -----------------------------------
FUNCTION cLangUser && Code langue de l'utilisateur courant
LPARAMETERS tuLocale && [.F.] @ Code langue avec locale (genre 'fr-fr') ou langue forcée

LOCAL lcType, llForce, loShell AS wScript.Shell, lcLang, lcResult

lcType = Vartype(m.tuLocale)

llForce = m.lcType == 'C' AND NOT Empty(m.tuLocale)

IF .T.;
 and not m.llForce;
 and Type('_Screen.cLangUser') == 'C';
 and NOT Empty(_Screen.cLangUser)

	tuLocale = _Screen.cLangUser
	RETURN _Screen.cLangUser

ELSE

	IF m.llForce

		lcResult = Alltrim(m.tuLocale)

	ELSE
		
		DECLARE INTEGER GetUserDefaultUILanguage IN Win32API
		loShell = CreateObject('wScript.Shell')

		lcResult = Alltrim(GetWordNum('';
			+ loShell.RegRead("HKLM\Software\Classes\MIME\Database\RFC1766\";
			+ Right(Transform(GetUserDefaultUILanguage(), '@0'), 4));
			, 1, ';'))

		lcResult = Iif(m.lcType == 'L' AND m.tuLocale;
			, m.lcResult + Iif('-' $ m.lcResult, '', '-' + m.lcResult);
			, Left(m.lcResult, 2);
			)

	ENDIF
	
	store Lower(m.lcResult) to lcResult, tuLocale
	AddProperty(_Screen, 'cLangUser', m.lcResult)

	RETURN m.lcResult
ENDIF

* =====================================================
procedure abUnitTests && Teste les modules (abUnitTest) du programme appelant

LOCAL success;
, lcSys16, lcProcFile, lcProcName;
, lcProcs, lnProc, laProc[1], liProc, lcProc, lcProcU;
, lnProcPrinc, lnProcTest

success = .T.

lcSys16 = Sys(16, Program(-1) -1) && calling procedure
lcProcFile = cModuleInfo(m.lcSys16, 'Address', .T.)
lcProcName = cModuleInfo(m.lcSys16, 'Name', .T.)
lcProcs = ForceExt(m.lcProcFile, 'txt')
StrToFile(Space(0), m.lcProcs) && vide la liste

* Tabuler les éléments contenus dans le fichier source
lnProc = aProcInfo(laProc, ForceExt(m.lcProcFile, 'PRG')) && 0 (default) - Populates the array with all document information.

* Si au moins un élément,
IF m.lnProc > 0

	Asort(m.laProc, 1, -1, 0, 1)

	* Pour chaque élément
	STORE 0 TO m.lnProcPrinc, m.lnProcTest
	FOR m.liProc = 1 TO m.lnProc

		* Si l'élément est une procédure
		IF Upper(laProc[m.liProc, 3]) = 'PROCEDURE'
			lcProc = laProc[m.liProc, 1]
			lcProcU = Upper(m.lcProc)

			* Si procédure principale, lister
			IF NOT '_' $ m.lcProc
				lnProcPrinc = m.lnProcPrinc + 1
				StrToFile(str(m.lnProcPrinc, 2) + '-' + m.lcProc + CRLF, m.lcProcs, 1)
			ENDIF
		
			* Si procédure de test, exécuter
			IF .T.;
			 AND Rightc(m.lcProcU, Lenc('_TEST')) == '_TEST' ;
			 AND NOT m.lcProcU == m.lcProcName && this procedure
			 	? 
			 	lnProcTest = m.lnProcTest + 1
				wait window Textmerge("<<m.lcProcFile>>!<<m.lcProc>>() [<<m.lnProcTest>>]") AT 10, 10 nowait noclear
				success = Evaluate(m.lcProc + '()') and m.success
			ENDIF
		ENDIF
	endfor
	wait clear
endif

return m.success

* =============================================
function abUnitTest && Objet abUnitTest
lparameters ;
	tcModule,; && [Module appelant sans le suffixe '_test'] Nom du module à tester
	tcAddress && [Adresse du code source du module appelant] Adresse contenant le répertoire où créer le Compte-rendu de test
return CreateObject('abUnitTest', m.tcModule, m.tcAddress)
endfunc

* =============================================
DEFINE CLASS abUnitTest AS Session
* =============================================

lSingleTest = .F. && exécuter seulement une fois && cas où la fonction à tester produit un résultat cumulatif et/ou des tableaux

PROTECTED nTest, lResult
nTest = 0 && Nombre de tests réalisés
lResult = .T. && Résultat des testes (.T. tant qu'aucun test n'est réalisé)

HIDDEN ;
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
PROCEDURE Init
LPARAMETERS ;
	tcModule,; && [Module appelant sans le suffixe '_test'] Nom du module à tester
	tcAddress && [Adresse du code source du module appelant] Adresse contenant le répertoire où créer le Compte-rendu de test

SET SYSFORMATS ON
SET MULTILOCKS ON

this.AddProperty('oEscape', abSet('ESCAPE', 'ON'))
this.AddProperty('oAsserts', abSet('ASSERTS', 'ON'))

LOCAL lcModule, lcAddress, llResult

* Si le nom du module n'est pas précisé, prendre le défaut
llResult = Vartype(m.tcModule) == 'C' AND NOT Empty(m.tcModule)
IF m.llResult
	lcModule = m.tcModule
	lcAddress = m.tcAddress
ELSE
	lcModule = Evl(this.cModuleDefault(cCallingModule(@m.lcAddress)), this.cModuleDefault(cCallingModule(@m.lcAddress, -1)))
	llResult = NOT Empty(m.lcModule)
ENDIF

* Si le nom du module est défini, vérifier son existence
IF m.llResult

	llResult = this.ModuleSet(m.lcModule, m.lcAddress)

	* Si le module est exécutable, régler la session de données
	IF m.llResult
		SET MEMOWIDTH TO Wcols(Wontop()) && Fenêtre résultats du test
	ENDIF
ENDIF

IF Directory(DOS_AB)
	
	* S'il existe des fichiers de test ou de coverage à l'ancienne adresse, déplacer à la nouvelle
	LOCAL laFiles[1], lcFile
	IF aFiles(@m.laFiles, DOS_AB + '*.tst') > 0
		FOR EACH lcFile IN laFiles
			FileMove(DOS_AB + m.lcFile, cABmoduleTestAddr(JustStem(m.lcFile)))
		ENDFOR
	ENDIF
	IF aFiles(@m.laFiles, DOS_AB + '*.cov') > 0
		FOR EACH lcFile IN laFiles
			FileMove(DOS_AB + m.lcFile, cABuserDataPath() + m.lcFile)
		ENDFOR
	ENDIF
ENDIF

RETURN m.llResult

* -----------------------------------
PROCEDURE EnvSet && Règle l'environnement de la session de données privée avant le(s) test(s)
LPARAMETERS ;
	tcEnvCommand && Commande d'environnement

IF Vartype(m.tcEnvCommand) == 'C'
	&tcEnvCommand
ENDIF

* -----------------------------------
PROCEDURE ModuleSet && Définit le nom et l'adresse du module à tester
LPARAMETERS ;
	tcModule,; && [Module appelant sans le suffixe '_test'] Nom du module à tester
	tcAddress && [Adresse du code source du module] Répertoire où créer le fichier de CR de test
LOCAL llResult

* Si le module est spécifié correctement
LOCAL lcModule, lcAddress
lcModule = Evl(m.tcModule, cCallingModule(@m.lcAddress))
lcAddress = cFileCased(Evl(m.tcAddress, m.lcAddress))
llResult = NOT Empty(m.lcModule) AND File(m.lcAddress)
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([le nom et/ou l'adresse de module est incorrect]))
IF m.llResult
		
	* Si le module existe
	LOCAL lnError, lcError, loAsserts
	lnError = 0
	lcError = On('ERROR')
	ON ERROR m.lnError = Error() && this.ModuleSet_nError(cModuleInfo(Sys(16)))
	loAsserts = abSet('ASSERTS', 'OFF')
	Evaluate(m.lcModule + "(this, 'junk', Date(), 0, .F.)")
	ON ERROR &lcError
	RELEASE loAsserts
	llResult = NOT m.lnError = 1 && file not found
	ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([le module " + m.lcModule + " ne peut être exécuté.]))
	IF m.llResult
		
		* Mémoriser le nom du module
		this.cAddress = m.lcAddress
		this.cModule  = m.lcModule
		
		* Définir l'adresse de son fichier résultats
		this.cResultAddr = cABmoduleTestAddr(m.lcModule)
		this.cCoverageAddr = ForceExt(this.cResultAddr, 'cov.log')
	ELSE
		STORE Space(0) TO this.cModule, this.cResultAddr, this.cCoverageAddr
	ENDIF
ENDIF

RETURN m.llResult

* -----------------------------------
HIDDEN FUNCTION ModuleSet_nError && N° d'erreur rencontrée lors de la tentative d'exécution du module
LPARAMETERS ;
	tcProc && Nom de la procédure où retourner en cas d'erreur

RETURN && TO ModuleSet

* -----------------------------------
HIDDEN FUNCTION cModuleDefault && Nom du module à tester d'après le nom du module appelant
LPARAMETERS tcCallingModule && Se termine normalement par '_Test'

LOCAL lcTest, lnTest, lcResult
lcResult = Space(0)

IF Vartype(m.tcCallingModule) == 'C'

	tcCallingModule = JustStem(Upper(Alltrim(m.tcCallingModule)))
	lcTest = '_TEST'
	lnTest = Len(m.lcTest)
	IF Right(m.tcCallingModule, m.lnTest) == m.lcTest

		lcResult = Left(m.tcCallingModule, Len(m.tcCallingModule) - m.lnTest)
	ENDIF
ENDIF

RETURN m.lcResult

* -----------------------------------
PROCEDURE CoverageSet && Démarre / arrête l'enregistrement des temps d'exécution pendant le test
LPARAMETERS tlCoverage && [.F.] démarrer / arrêter l'enregistrement pendant le test

this.lCoverage = lTrue(m.tlCoverage)

* -----------------------------------
PROCEDURE CoverageClear && Efface le fichier de coverage

DELETE FILE (m.this.cCoverageAddr)

* -----------------------------------
PROCEDURE Test && Teste le module
LPARAMETERS ;
	tuExpected,; && @ Résultat attendu retourné par le module testé - .NULL. : résultat attendu inconnu
	tuParm01,tuParm02,tuParm03,tuParm04,tuParm05,tuParm06,tuParm07,tuParm08,tuParm09,tuParm10,tuParm11,tuParm12,tuParm13,tuParm14 && @ paramètres passés au module testé

LOCAL luResult as Variant; && résultat du test
, lnParm;
, lcParms;
, liParm;
, luParm;
, lnElapsed;
, laStatus1[1];
, laStatus2[1];

luResult = .NULL.
	
* Si le module est bien défini
IF Empty(this.cModule)
	return .F.
else
	
	* Bâtir la chaine des paramètres à passer au module
	lnParm = Max(Pcount() - 1, 0)
	lcParms = this.Test_cParms(m.lnParm) && liste des paramètres à passert au module testé

	#DEFINE NCOLSFIXES 8 && /!\ utilisé par this.Test_aTestsDim()

	* Ajuster le tableau de résultats de tests
	this.nTest = this.nTest + 1
	this.Test_aTestsDim(m.lnParm)
	this.aTest[m.this.nTest, NCOLSFIXES] = m.lnParm && Nombre de paramètres passés (peut varier d'un test à l'autre)

	IF m.lnParm > 0
		FOR liParm = 1 TO m.lnParm
			luParm = Evaluate(this.Test_cParm(m.liParm)) && Valeur du paramètre
			this.aTest[m.this.nTest, NCOLSFIXES + m.liParm] = Iif(Vartype(m.luParm) == 'C';
				, '"' + m.luParm + '"';
				, cLitteral(m.luParm);
				)
		ENDFOR
	ENDIF
	
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
	LOCAL lcStatus
	this.aTest[m.this.nTest, 1] = this.lCoverage && Coverage ON
	this.aTest[m.this.nTest, 2] = m.lnElapsed && Temps d'exécution (non significatif si COVERAGE)
	this.aTest[m.this.nTest, 3] = Empty(Pcount()) or IsNull(m.tuExpected) or luEqual(Iif(Vartype(m.tuExpected ) == 'O', cL(m.tuExpected), m.tuExpected), m.luResult) && Valeur produite = valeur attendue && Empty(m.tuExpected) OR
	this.aTest[m.this.nTest, 4] = m.tuExpected && Résultat attendu
	this.aTest[m.this.nTest, 5] = m.luResult && Résultat produit
	this.aTest[m.this.nTest, 6] = this.lStatus(@m.laStatus1, @m.laStatus2, @m.lcStatus) && Environnement modifié ?
	this.aTest[m.this.nTest, 7] = m.lcStatus && Modification d'environnement éventuelle
ENDIF

return m.luResult

* -----------------------------------
PROCEDURE Assert && Teste une valeur (par exemple élément d'un tableau résultat)
LPARAMETERS ;
	tuExpected,; && @ Résultat attendu
	tuValue && @ Valeur à tester

if Pcount() >= 2

	this.aTest[m.this.nTest, 3] = luEqual(@m.tuExpected, @m.tuValue) && Valeur produite == valeur attendue

	ASSERT m.this.aTest[m.this.nTest, 3] MESSAGE cAssertMsg(Textmerge(ICase(;
		cLangUser() = 'fr',	[Échec d'assertion au test n° <<m.this.nTest>> - résultat attendu: <<cL(m.tuExpected)>>, obtenu: <<cL(m.tuValue)>>],; && copy-paste this line to add another language support
		 										[Assertion failed at test # <<m.this.nTest>> - result expected: <<cL(m.tuExpected)>>, obtained: <<cL(m.tuValue)>>]; && Default: English
		)))

else

	this.aTest[m.this.nTest, 3] = Cast(m.tuExpected as L)

	ASSERT m.this.aTest[m.this.nTest, 3] MESSAGE cAssertMsg(Textmerge(ICase(;
		cLangUser() = 'fr',	[Échec d'assertion au test n° <<m.this.nTest>>],; && copy-paste this line to add another language support
		 										[Assertion failed at test # <<m.this.nTest>>]; && Default: English
		)))

endif

return m.this.aTest[m.this.nTest, 3]

* -----------------------------------
HIDDEN FUNCTION Test_cParm && Nom d'un paramètre selon sa position
LPARAMETERS tiParm && Position du paramètre

RETURN 'tuParm' + Padl(m.tiParm, 2, '0')

* -----------------------------------
HIDDEN PROCEDURE Test_cParms && Liste de paramètres à passer au module testé
LPARAMETERS ;
	tnParms && Nombre de paramètres passés à this.test()

LOCAL lcResult && Liste de paramètres
lcResult = Space(0)

IF m.tnParms > 0
	
	* Pour chaque paramètre passé
	LOCAL liParm, lcParm
	FOR liParm = 1 TO m.tnParms

		* Reconstituer le nom du paramètre
		lcParm = '@' + this.Test_cParm(m.liParm)

		* Ajouter au résultat en passant par référence
		lcResult = c2Words(m.lcResult, ',', m.lcParm)
	ENDFOR
ENDIF

RETURN m.lcResult

* -----------------------------------
HIDDEN PROCEDURE Test_Exec && Exécute le test du module
LPARAMETERS ;
	tcParms,; && Chaîne de paramètres à passer au module testé
	tnElapsed,; && @ Temps d'exécution en millisecondes
	taStatus1,; && @ Environnement avant exécution du test
	taStatus2,; && @ Environnement après exécution du test
	tuParm01,tuParm02,tuParm03,tuParm04,tuParm05,tuParm06,tuParm07,tuParm08,tuParm09,tuParm10,tuParm11,tuParm12,tuParm13,tuParm14

EXTERNAL ARRAY taStatus1, taStatus2

LOCAL luResult as Variant; && Résultat du module testé
, lnParm, liParm, lcParm, lcParm_;
, lnRows, lnCols;
, lcArray;
, lnAttempt;
, liAttempt;
, lnSeconds;

* Sauvegarder les paramètres
lnParm = Pcount() - 4
FOR liParm = 1 TO m.lnParm
	lcParm = this.Test_cParm(m.liParm)
	lcParm_ = m.lcParm + '_'
	IF Type(m.lcParm, 1) == 'A'
		lnRows = Alen(&lcParm, 1)
		lnCols = Alen(&lcParm, 2)
		lcArray = m.lcParm_ + Textmerge(Iif(m.lnCols > 0, '[<<m.lnRows>>,<<m.lnCols>>]', '[<<m.lnRows>>]'))
		LOCAL ARRAY &lcArray
		Acopy(&lcParm, &lcParm_)
	ELSE
		LOCAL (m.lcParm_)
		STORE Evaluate(m.lcParm) TO (m.lcParm_)
	ENDIF
ENDFOR

lnAttempt = 1
DO WHILE .T.

	* Si c'est le premier test
	IF m.lnAttempt = 1

		* Mémoriser l'environnement VFP AVANT l'exécution
		this.aStatus(@m.taStatus1)

		* Si le coverage a été demandé, le démarrer
		IF m.this.lCoverage
			LOCAL lcCoverage
			lcCoverage = Set('COVERAGE', 1)
			SET COVERAGE TO (m.this.cCoverageAddr) ADDITIVE
		ENDIF
	ENDIF

	tnElapsed = 0
	FOR liAttempt = 1 TO m.lnAttempt
		
		* Restaurer les paramètres
		FOR liParm = 1 TO m.lnParm
			lcParm = this.Test_cParm(m.liParm)
			lcParm_ = m.lcParm + '_'
			IF Type(m.lcParm_, 1) == 'A'
				lnRows = Alen(&lcParm_, 1)
				lnCols = Alen(&lcParm_, 2)
				lcArray = m.lcParm + Textmerge(Iif(m.lnCols > 0, '[<<m.lnRows>>,<<m.lnCols>>]', '[<<m.lnRows>>]'))
				DIMENSION &lcArray
				Acopy(&lcParm_, &lcParm)
			ELSE
				STORE Evaluate(m.lcParm_) TO (m.lcParm)
			ENDIF
		ENDFOR

		* Exécuter la procédure / fonction
		* ===========================================================
		lnSeconds = Seconds()
		luResult = Evaluate(this.cModule + '(' + m.tcParms + ')')
		tnElapsed = m.tnElapsed + nMS(m.lnSeconds) && millisecondes
		* ===========================================================

	ENDFOR

	luResult = Iif(Vartype(m.luResult) == 'O'; && exécute .Destroy()
		, cL(m.luResult);
		, m.luResult;
		)

	* Si c'est le premier test
	IF m.lnAttempt = 1

		* Si le coverage a été demandé, l'arrêter
		IF this.lCoverage
			SET COVERAGE TO &lcCoverage
		ENDIF

		* Mémoriser l'environnement VFP après l'exécution
		this.aStatus(@m.taStatus2)
	ENDIF

	* Si le temps d'exécution est significatif, terminer
	IF .F.;
	 OR m.this.lCoverage;  && avec Coverage, une seule exécution
	 OR m.this.lSingleTest; && simple test demandé
	 OR m.tnElapsed > 2 && && millisecondes (précision au moins 5%)

		EXIT

	* sinon, répéter le test
	ELSE
		lnAttempt = m.lnAttempt * 10 
	ENDIF
ENDDO

tnElapsed = m.tnElapsed / m.lnAttempt

*this.lSingleTest = .F.

RETURN m.luResult

* -----------------------------------
HIDDEN PROCEDURE Test_aTestsDim && Dimensionne le tableau des résultats pour recevoir ceux du dernier test
LPARAMETERS tnParms && Nombre de paramètres passés pour le test courant

LOCAL lnCols
lnCols = Alen(this.aTest, 2)

* Ajouter une nouvelle LIGNE au tableau de test
DIMENSION this.aTest[m.this.nTest, m.lnCols]

* Si nouveaux paramètres,
LOCAL lnColsParms
lnColsParms = NCOLSFIXES + m.tnParms
IF m.lnColsParms > m.lnCols

	* Ajouter le nombre de COLONNES nécessaires au tableau résultat
	LOCAL ARRAY laTests[1]
	Acopy(this.aTest, m.laTests)
	aColsIns(@m.laTests, m.lnCols, m.lnColsParms - m.lnCols)
	DIMENSION this.aTest[m.this.nTest, m.lnColsParms]
	Acopy(m.laTests, this.aTest)
ENDIF

* -----------------------------------
PROCEDURE Result

IF NOT this.lResultOut
	this.ResultOut()
ENDIF

RETURN this.lResult

* -----------------------------------
HIDDEN PROCEDURE ResultOut && Sort le résultat des test à l'écran et dans le log de test

LOCAL lcResult, llResult

lcResult = this.cResult()
llResult = NOT Empty(m.lcResult)
ASSERT m.llResult MESSAGE cAssertMsg("Aucun résultat de test à sortir !")
IF m.llResult
	
	llResult = StrToFile(m.lcResult, m.this.cResultAddr, .T.) > 0
	ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([Impossible d'écrire les résultats dans le fichier <<cLitteral(m.this.cResultAddr)>>]))
	? m.lcResult
	debugout m.lcResult

	this.lResultOut = m.llResult
ENDIF

RETURN m.llResult

* -----------------------------------
HIDDEN FUNCTION cResult && Résultat de test(s)

LOCAL lcResult
lcResult = Space(0)

* Si le module est défini
IF .T.;
 AND Vartype(this.cModule) == 'C' ;
 AND NOT Empty(this.cModule)

	* Si des tests ont été réalisés sur le module
	IF m.this.nTest > 0

		* Pour chaque test réalisé
		LOCAL lnCoverage, lnElapsed, lnElapsedMin, lnElapsedMax, lnElapsedAvg, lnSuccess
		lnElapsedMin = 10^10
		STORE 0 TO m.lnCoverage, m.lnElapsedMax, m.lnElapsedAvg, m.lnSuccess
		LOCAL lnTest
		FOR lnTest = 1 TO this.nTest

			* Synthétiser les résultats
			IF this.aTest[m.lnTest, 1] && les temps d'exécution avec COVERAGE ON ne sont pas significatifs
				lnCoverage = m.lnCoverage + 1
			ELSE
				lnElapsed = uDefault(this.aTest[m.lnTest, 2], 0)
				lnElapsedMin = Min(m.lnElapsedMin, m.lnElapsed)
				lnElapsedMax = Max(m.lnElapsedMax, m.lnElapsed)
				lnElapsedAvg = m.lnElapsedAvg + m.lnElapsed
			ENDIF
			lnSuccess = m.lnSuccess + ;
				Iif(this.aTest[m.lnTest, 3] AND this.aTest[m.lnTest, 6], 1, 0)
		ENDFOR

		* Rectifier le temps moyen en cas de coverage sur certains tests
		LOCAL lnCoverageLess
		lnCoverageLess = this.nTest - m.lnCoverage
		IF m.lnCoverageLess > 0
			lnElapsedAvg = m.lnElapsedAvg / m.lnCoverageLess
		ENDIF

		* Compter les échecs
		LOCAL lnFailure
		lnFailure = this.nTest - m.lnSuccess

		TEXT TO m.lcResult TEXTMERGE NOSHOW FLAGS 1
===========================================
<<Datetime()>>
Module : <<DisplayPath(m.this.cAddress, 50)>>!<<this.cModule>>() 
Résultats de <<m.this.nTest>> test<<Iif(this.nTest = 1, Space(0), 's')>> dont <<m.lnCoverage>> avec coverage dans '<<m.this.cCoverageAddr>>'
<<Iif(m.lnCoverageLess > 0, "Temps d'exécution sans coverage Mini | Moyen | Maxi : " + this.cMS(m.lnElapsedMin) + '|' + this.cMS(m.lnElapsedAvg) + '|' + this.cMS(m.lnElapsedMax), Space(0))>> 

		ENDTEXT

		* Si au moins un test a réussi
		IF m.lnSuccess > 0

			TEXT TO m.lcResult ADDITIVE TEXTMERGE NOSHOW FLAGS 1
---------------------------------------------
<<m.lnSuccess>> <<Iif(m.lnSuccess = 1, "test réalisé", "tests réalisés")>> avec succès

			ENDTEXT
		ENDIF

		* Si au moins un test a échoué
		this.lResult = m.lnFailure = 0
		IF NOT this.lResult
			TEXT TO m.lcResult ADDITIVE TEXTMERGE NOSHOW FLAGS 1
---------------------------------------------
<<m.lnFailure>> <<Iif(m.lnFailure = 1, "test a échoué", "tests ont échoué")>> :

			ENDTEXT
			
			LOCAL lnParms, liParm, lcParms;
			, llString, lnString, liString, lcString

			* Pour chaque test échoué
			FOR lnTest = 1 TO this.nTest
				DO CASE
				
				* Cas où l'échec est dû à un mauvais résultat
				CASE NOT m.this.aTest[m.lnTest, 3]

					* S'il y en a des paramètres, lister leurs valeurs sous forme de constantes
					lnParms = this.aTest[m.lnTest, NCOLSFIXES]
					lcParms = Space(0)
					IF m.lnParms > 0
						FOR liParm = 1 TO m.lnParms
							lcParms = m.lcParms + CRLF;
								+ Chr(9) + '  ' + Transform(m.liParm) + '. ' + this.aTest[m.lnTest, NCOLSFIXES + m.liParm]
						ENDFOR
					ENDIF
					
					llString = Vartype(this.aTest[m.lnTest, 4]) == 'C'
					lcString = Space(0)
					lnString = Iif(m.llString, Lenc(this.aTest[m.lnTest, 4]), 0)
					IF m.lnString > 0
						FOR liString = 1 TO m.lnString
							lcString = Substrc(m.this.aTest[m.lnTest, 4], m.liString, 1)
							IF NOT m.lcString == Substrc(m.this.aTest[m.lnTest, 5], m.liString, 1)
								lcString = Textmerge([Différence au caractère <<m.liString>> ('<<m.lcString>>') du résultat attendu]) + CRLF
								EXIT
							ENDIF
						ENDFOR
					ENDIF

					* écrire le n° de test, les résultats attendus et obtenus, les paramètres
					local lcType
					lcType = Vartype(this.aTest[m.lnTest, 5])
					TEXT TO m.lcResult ADDITIVE TEXTMERGE NOSHOW FLAGS 1
- Test n° : <<Transform(m.lnTest)>>
	Resultats : 
	- attendu:	<<Iif(m.llString, '"' + this.aTest[m.lnTest, 4] + '"', cLitteral(this.aTest[m.lnTest, 4]))>>
	- obtenu :	<<ICase(m.lcType == 'C' and Lower(Leftc(this.aTest[m.lnTest, 5], Len('Object '))) == Lower('Object '), this.aTest[m.lnTest, 5], m.lcType == 'C', '"' + this.aTest[m.lnTest, 5] + '"', cLitteral(this.aTest[m.lnTest, 5]))>>
	<<m.lcString>><<m.lnParms>> paramètres passés<<Iif(m.lnParms > 0, ' :', '')>><<m.lcParms>>

					ENDTEXT

				* Case où l'échec est dû à une modification d'environnement
				CASE NOT this.aTest[m.lnTest, 6]

					* écrire la variable d'environnement modifiée
					TEXT TO m.lcResult ADDITIVE TEXTMERGE NOSHOW
- Test n° <<m.lnTest>>
	L'environnement VFP a changé comme suit :
		<<this.aTest[m.lnTest, 7]>>

					ENDTEXT

				ENDCASE
			ENDFOR
TEXT TO m.lcResult ADDITIVE TEXTMERGE NOSHOW
===========================================

ENDTEXT
		ENDIF

	ELSE
		lcResult = "Aucun test n'a été réalisé sur le module" + Space(1) + this.cModule
	ENDIF
ENDIF

RETURN m.lcResult

* -----------------------------------
HIDDEN FUNCTION cMS && Temps en avec unité millisecondes
LPARAMETERS tnMS && Temps en millisecondes
RETURN Space(1) + Ltrim(Transform(m.tnMS, '9,999.999  ms'))

* -----------------------------------
HIDDEN FUNCTION aStatus && Environnement Visual FoxPro
LPARAMETERS taStatus && @ Tableau de statut

LOCAL lnStatus, lcStatus, laUsed[1], lnResult && Nombre d'éléments d'environnement

* Tabuler les éléments de statut
lnResult = ALines(m.taStatus, this.cStatus(), .T.)
aColsIns(@m.taStatus) && ajoute une colonne pour les résultats

* Pour chaque élément de statut valide
FOR lnStatus = 1 TO m.lnResult

	lcStatus = m.taStatus[m.lnStatus, 1]
	IF NOT lCommentLine(m.lcStatus)

		* Évaluer
		TRY
			taStatus[m.lnStatus, 2] = Evaluate(m.lcStatus)
		CATCH
		ENDTRY
	ENDIF
ENDFOR

RETURN m.lnResult

EXTERNAL PROCEDURE lCommentLine && dans abModuleDir.prg

* -----------------------------------
HIDDEN FUNCTION cStatus && Environnement Visual FoxPro
LOCAL lcResult

TEXT TO m.lcResult NOSHOW PRETEXT 1+2+4

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

RETURN m.lcResult

* -----------------------------------
HIDDEN FUNCTION lStatus && Compare deux environnements VFP
LPARAMETERS ;
	taStatus1,; && @ Tableau de statut 1 (créé par this.aStatus())
	taStatus2,; && @ Tableau de statut 2 (créé par this.aStatus())
	tcModifs && @ Éléments d'environnement ayant évolué (si m.llResult = .F.)

LOCAL llResult && L'environnement VFP est identique
llResult = .NULL.
tcModifs = Space(0)

* Si le statut a bien été tabulé après test
LOCAL lnStatusCount
lnStatusCount = Alen(m.taStatus1, 1)
IF Alen(m.taStatus2, 1) = m.lnStatusCount
	
	* Pour chaque élément d'environnement
	LOCAL lnStatus, llStatus
	llResult = .T.
	FOR lnStatus = 1 TO m.lnStatusCount

		* Si l'élément n'a pas la même valeur dans les 2 tableaux
		llStatus = m.taStatus1[m.lnStatus, 2] == m.taStatus2[m.lnStatus, 2]
		IF NOT m.llStatus
			
			* Ajouter la modification au message retourné
			tcModifs = c2Words(m.tcModifs, CRLF, ;
				taStatus1[m.lnStatus, 1] + ;
				Space(1) + '-' + Space(1) + 'avant Test : ' + cLitteral(m.taStatus1[m.lnStatus, 2]) + ;
				Space(1) + '-' + Space(1) + 'après Test : ' + cLitteral(m.taStatus2[m.lnStatus, 2]))
			llResult = .F.
		ENDIF
	ENDFOR
ENDIF

RETURN m.llResult

* -----------------------------------
PROCEDURE Destroy

* Sortir le résultat si ça n'a pas été fait
IF NOT this.lResultOut
	this.ResultOut()
ENDIF

* Fermer proprement les Aliases ouverts pour le(s) test(s)
LOCAL laAlias[1], lcAlias
IF AUsed(m.laAlias) > 0
	FOR each lcAlias in laAlias
		USE IN (m.lcAlias)
	ENDFOR
ENDIF

* =============================================
ENDDEFINE && CLASS abUnitTest
* =============================================

* -----------------------------------
FUNCTION FooTest && Bidon pour démontrer la classe de test abUnitTest
LPARAMETERS tuFoo

LOCAL lcType, luResult
lcType = Vartype(m.tuFoo)

DO CASE

CASE m.lcType == 'C' && échec car changement de Set("Deleted")
	LOCAL lcDeleted
	lcDeleted = Set("Deleted")
	lcDeleted = Iif(m.lcDeleted == 'ON', 'OFF', 'ON')
	SET DELETED &lcDeleted
	luResult = m.tuFoo
	
CASE m.lcType == 'N'
	luResult = 2 * m.tuFoo

CASE m.lcType == 'L'
	luResult = NOT m.tuFoo

CASE m.lcType == 'D'
	luResult = m.tuFoo + 10

OTHERWISE
	luResult = .F.
ENDCASE

RETURN m.luResult

*------------------------------------
FUNCTION Fox2Pix && foxels to pixels && courtesy Sergey Berezniker http://www.berezniker.com/content/pages/visual-foxpro/pixels-and-foxels
LPARAMETERS ;
	tnFoxels,; && foxels to convert
	tlVertical,; && vertical coordinates
	tcFontName,; && [current form's] font name
	tnFontSize && [current form's] font size
 
RETURN Iif(Pcount() >= 4;
	, m.tnFoxels * Fontmetric(Iif(m.tlVertical, 1, 6), m.tcFontName, m.tnFontSize);
	, m.tnFoxels * Fontmetric(Iif(m.tlVertical, 1, 6));
	)
 
*------------------------------------
FUNCTION Pix2Fox && pixels to foxels && courtesy Sergey Berezniker http://www.berezniker.com/content/pages/visual-foxpro/pixels-and-foxels
LPARAMETERS ;
	tnPixels,; && pixels to convert
	tlVertical,; && vertical coordinates
	tcFontName,; && [current form's] font name
	tnFontSize && [current form's] font size

local lnResult, llResult

lnResult = Iif(Pcount() >= 4;
	, m.tnPixels / Fontmetric(Iif(m.tlVertical, 1, 6), m.tcFontName, m.tnFontSize);
	, m.tnPixels / Fontmetric(Iif(m.tlVertical, 1, 6));
	)
	
llResult = Between(m.lnResult, -32768+1, 32767-1) && 19/12/13 - Invalid coordinates (Error 1959) Coordinate values must be greater than -32768 and less than 32767
assert m.llResult message cAssertMsg(Textmerge([<<m.lnResult>> from: <<m.tnPixels>>px <<Iif(m.tlVertical, 'Vertical', 'Horizontal')>>, Font: <<Evl(m.tcFontName, .null.)>> <<Evl(m.tnFontSize, .null.)>>pt]))

RETURN Iif(m.llResult;
	, m.lnResult;
	, 0;
	)

* ==============================
FUNCTION cExprEval && Expression pour évaluer une expression
LPARAMETERS tcExpr && Expression

LOCAL laOp[1], lcOp, lcOpU, lcExpr, lcResult
STORE Space(0) TO lcExpr, lcResult

* Pour chaque opérande de l'expression
IF ALines(laOp, m.tcExpr, 1, '+') > 0
	FOR EACH lcOp IN laOp
		
		* Si l'opérande est un Chr()
		lcOpU = Chrtran(Upper(m.lcOp), Space(1), Space(0))
		IF Left(m.lcOpU, 4) == 'CHR(' OR InList(m.lcOpU, 'CR', 'CRLF')

			* Ajouter les opérandes accumulés au résultat
			lcResult = cWords('+', m.lcResult, cExprEval_cOp(m.lcExpr), m.lcOp)
			lcExpr = Space(0)
		ELSE
			lcExpr = c2Words(m.lcExpr, '+', m.lcOp)
		ENDIF
	ENDFOR
	lcResult = c2Words(m.lcResult, '+', cExprEval_cOp(m.lcExpr))
ENDIF

RETURN m.lcResult

* -----------------------------
FUNCTION cExprEval_cOp && Adapte un opérande d'une expression
LPARAMETERS tcOp && Opérande

RETURN Iif(Empty(m.tcOp), Space(0), Textmerge([cLitteral(Evaluate(<<cLitteral(m.tcOp)>>))]))

* ==============================
FUNCTION uEval && Expression évaluée si possible
LPARAMETERS tcExpr

LOCAL luResult

TRY
	luResult = Evaluate(m.tcExpr)
CATCH
	luResult = m.tcExpr
ENDTRY

RETURN m.luResult

* ==============================
FUNCTION cIndented && Texte indenté
LPARAMETERS ;
	tcCode,; && Texte à indenter
	tcIndent,; && [tab] Caractère(s) d'indentation
	tlEmptyDel,; && [.F.] Supprimer les lignes vides
	tcCharEOL && [''] Caractère de fin de ligne
tcCode = Iif(Vartype(m.tcCode) == 'C', m.tcCode, '')
tcIndent = Iif(Vartype(m.tcIndent) == 'C' AND Lenc(m.tcIndent) > 0, m.tcIndent, Chr(9)) && Evl() ne marche pas sur space() et tab
tlEmptyDel = lTrue(m.tlEmptyDel)
tcCharEOL = Evl(m.tcCharEOL, Space(0))

RETURN '';
	+ m.tcIndent;
	+ Trim(;
	   ICase(;
			CRLF $ m.tcCode,;
				Strtran(Strtran(Iif(m.tlEmptyDel, cRepCharsDel(m.tcCode, CRLF), m.tcCode);
					, m.tcCharEOL + CRLF, m.tcCharEOL + CRLF + m.tcIndent);
					, CRLF + m.tcIndent + CRLF, CRLF2),;
			CR $ m.tcCode,;
				Strtran(Strtran(Iif(m.tlEmptyDel, cRepCharDel(m.tcCode, CR), m.tcCode);
					, m.tcCharEOL + CR, m.tcCharEOL + CR + m.tcIndent);
					, CR + m.tcIndent + CR, CR2),;
				Strtran(Strtran(Iif(m.tlEmptyDel, cRepCharDel(m.tcCode, LF), m.tcCode); && LF $ m.tcCode, memo par exemple
					, m.tcCharEOL + LF, m.tcCharEOL + LF + m.tcIndent);
					, LF + m.tcIndent + LF, LF2);
			);
		, cRepCharDel(m.tcIndent);
		)

* ==============================
FUNCTION cIndentedNo && Texte non indenté && /!\ à modifier pour fonctionner en multi-lignes
LPARAMETERS tcCode

RETURN Ltrim(ICase(;
		CRLF $ m.tcCode,;
			Strtran(Strtran(m.tcCode, CRLF + TABUL, CRLF), CRLF + Space(1), CRLF),;
		CR $ m.tcCode,;
			Strtran(Strtran(m.tcCode, CR + TABUL, CR), CR + Space(1), CR),;
			Strtran(Strtran(m.tcCode, LF + TABUL, LF), LF + Space(1), LF); && memo par exemple
		), TABUL, Space(1))

* ==============================
FUNCTION cCommented && Instruction(s) commentée(s)
LPARAMETERS ;
	tcCode,; && Instruction(s)
	tcCom,; && [* ] caractère de commentaire
	tlEmptyDel && [.F.] Supprimer les lignes vides
tcCom = Evl(m.tcCom, '* ')
tlEmptyDel = lTrue(m.tlEmptyDel)

RETURN Iif(Empty(m.tcCode);
	, '';
	, Strtran(Strtran(Strtran('';
			+ m.tcCom;
			+ Trim(ICase(;
					CRLF $ m.tcCode,;
						Strtran(Iif(m.tlEmptyDel, cRepCharsDel(m.tcCode, CRLF), m.tcCode), CRLF, CRLF + m.tcCom),;
					CR $ m.tcCode,;
						Strtran(Iif(m.tlEmptyDel, cRepCharDel(m.tcCode, CR), m.tcCode), CR, CR + m.tcCom),;
						Strtran(Iif(m.tlEmptyDel, cRepCharDel(m.tcCode, LF), m.tcCode), LF, LF + m.tcCom); && memo par exemple
					), m.tcCom); && ? Trim('totu', 'tu') && 'to'
		, m.tcCom + CRLF, CRLF); && les lignes vides ne sont pas commentées
		, m.tcCom + CR, CR); && les lignes vides ne sont pas commentées
		, m.tcCom + LF, LF); && les lignes vides ne sont pas commentées
	)

* ==============================
FUNCTION lDevMode && Mode développement
RETURN _VFP.StartMode = 0;
 AND NOT InList(Lower(JustExt(cModuleInfo(Sys(16, 0), 'Address'))), 'app', 'exe')

* ===================================================================
FUNCTION cAssertMsg && MESSAGE pour ASSERT limité à 120 caractères sous les IDE non-US
LPARAMETERS tcMsg
tcMsg = Ltrim(Evl(Nvl(m.tcMsg, ''), 'empty message?'))

LOCAL lcProgram

lcProgram = Proper(Program(Program(-1)-1)) && back compat.

?? Chr(7) && ding && ?? pour ne pas ajouter une ligne à la fenêtre qui a le focus

RETURN cTronc('';
    + Iif(Lower(Left(m.tcMsg, Len(m.lcProgram))) == Lower(m.lcProgram);
			, '';
			, cResultHeader(-2);
			);
	  + m.tcMsg;
	, Iif(Version(3) == '00'; && 00 - English - 14/06/12 - crédit Francis Faure - http://www.atoutfox.org/nntp.asp?ID=0000009184
		, 254; && http://www.atoutfox.org/nntp.asp?ID=0000009201
		, 120;
		);
	, .T.; && split on a word end
	)

* =============================================
DEFINE CLASS abVoid AS Custom
	PROCEDURE init
	RETURN .F.
ENDDEFINE && CLASS abVoid

* =============================================
PROCEDURE lSetProcedure && a Set("Procedure") is in current Set("Procedure")
LPARAMETERS tcSetProcedure && Set("Procedure") antérieur
RETURN setProcedure(m.tcSetProcedure, .T.)

* =============================================
PROCEDURE setProcedure && Restores previous Set("Procedure")
LPARAMETERS ;
	tcSetPro_,; && Set("Procedure") antérieur
	tlCheck,; && [.F.] Vérifier si Set("Procedure") antérieur est dans Set("Procedure") courant
	tlAdditive && [.F.] Ajouter tcSetPro_ à Set("Procedure") courant

tlCheck = lTrue(m.tlCheck)
tlAdditive = lTrue(m.tlAdditive)

LOCAL llResult as Boolean;
, laSetProc[1];
, lnSetProc;
, laSetPro_[1];
, lnSetPro_;
, llProcedure;
, liProcedure;
, lcProcedure;

llResult = .T.
lnSetPro_ = ALines(laSetPro_, Upper(m.tcSetPro_), 5, ',')
lnSetProc = ALines(laSetProc, Set("Procedure"), 5, ',')

do case

case m.tlCheck
	for each lcProcedure in m.laSetPro_
		if Empty(Ascan(m.laSetProc, m.lcProcedure, 1, -1, 1, 6))
			llResult = .F.
			exit
		endif
	endfor

case Empty(m.lnSetPro_) and !m.tlAdditive
	set procedure to

otherwise

	if m.lnSetPro_ > 0
		for liProcedure = 1 to lnSetPro_
			laSetPro_[m.liProcedure] = FullPath(Alltrim(laSetPro_[m.liProcedure], '"'))
		endfor
	endif

	if m.lnSetProc > 0
		for liProcedure = 1 to m.lnSetProc
			laSetProc[m.liProcedure] = FullPath(Alltrim(laSetProc[m.liProcedure], '"'))
		endfor
	endif	

	if m.lnSetPro_ > 0
		for each lcProcedure in m.laSetPro_
			if File(m.lcProcedure) and Empty(Ascan(m.laSetProc, m.lcProcedure, 1, -1, 1, 6))
				set procedure to (m.lcProcedure) additive
			endif
		endfor
	endif

	if m.lnSetProc > 0 and !m.tlAdditive
		for each lcProcedure in laSetProc
			if Empty(Ascan(laSetPro_, m.lcProcedure, 1, -1, 1, 6))
				release procedure (m.lcProcedure)
			endif
		endfor
	endif

endcase

RETURN m.llResult

* ========================================
procedure SetProcClassRestore as Boolean && restores Set("Classlib") or Set("Procedure") to a previous value
lparameters ;
  tcSetAnte as String; && previous Set("Classlib") or Set("Procedure")
, tlClassLib as Boolean && [.F.] tcSetAnte is Set("Classlib")

tlClassLib = lTrue(m.tlClassLib)

local success as Boolean;
, laFileAnte[1];
, laFilePost[1];
, lcThisFile as String;
, lcFile as String

success = .T.

if .T.;
 and ALines(laFileAnte, m.tcSetAnte, 5, ',') > 0;
 and ALines(laFilePost, Set(Iif(m.tlClassLib, "Classlib", "Procedure")), 5, ',') > 0;

	lcThisFile = cModuleInfo(Sys(16), 'Address')
	
	* Remove unused files
	for each lcFile in m.laFilePost
		try
			do case
			case Ascan(m.laFileAnte, m.lcFile, 1, -1, 1, 7) > 0
				&& in previous Set()
			case m.tlClassLib
				lcFile = Iif(' IN ' $ m.lcFile;
					, '';
						+ Ltrim(Substrc(m.lcFile, At_c(' ALIAS ', m.lcFile)));
						+ Substrc(m.lcFile;
							, At_c(' IN ', m.lcFile);
							, At_c(' ALIAS ', m.lcFile) - At_c(' IN ', m.lcFile);
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
			case Ascan(m.laFilePost, m.lcFile, 1, -1, 1, 7) > 0
				&& already in Set()
			case !File(alltrim(Iif(m.tlClassLib;
				, Trim(Substrc(m.lcFile, 1, At_c('ALIAS', m.lcFile)-1));
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
FUNCTION cResultAdd && Ajoute une entrée à un résultat cumulatif
LPARAMETERS ;
  tcResult; && @ résultat cumulatif
, tuItem; && élément à ajouter au résultat - type 'N': assumes Seconds() for execution time tracking
, tlLine; && [.F.] Sauter une ligne au lieu de 2
, tlPrepend; && [.F.] Ajouter au début
, tnStackMinus; && [0] nombre de niveaux de pile à retrancher - .T.: ne pas ajouter l'en-tête
, tlDateTime; && [.F.] add date-time header

tcResult = Iif(Vartype(m.tcResult) == 'C', m.tcResult, '')

tuItem = Iif(Vartype(m.tuItem) == 'N' and m.tuItem > 0;
	, ICase(;
		cLangUser() = 'fr',	[terminé en],; && copy-paste this line to add another language support
												[completed in];
		) + ' ' + cSeconds(@m.tuItem);
	, m.tuItem;
	)

if .T.;
 and ga_Type_IsChar(m.tuItem, .T.);
 and not m.tuItem $ m.tcResult

	tuItem = Alltrim(m.tuItem, CR, LF)
	
	local lcHeader as String

	lcHeader = Iif(Empty(m.tnStackMinus) or Vartype(m.tnStackMinus) == 'N';
		, cResultHeader(- 2 - Abs(Evl(m.tnStackMinus, 0)), m.tlDateTime);
		, '';
		)

	tuItem = '';
		+ Iif(Left(m.tuItem, Lenc(m.lcHeader)) == m.lcHeader, '', m.lcHeader);
		+ m.tuItem

	tcResult = '';
		+ Iif(lTrue(m.tlPrepend);
		  , c2Words(m.tuItem, Iif(m.tlLine, CRLF, CRLF2), m.tcResult);
		  , c2Words(m.tcResult, Iif(m.tlLine, CRLF, CRLF2), m.tuItem);
		  )

endif

RETURN .F. && impératif

* ===================================================================
FUNCTION cResultHeader && En-tête standard d'un résultat
LPARAMETERS ;
  tnStackOffset; && [-1]
, tlDateTime; && [.F.] add date-time header

LOCAL lnStack, lcSys16

tnStackOffset = Evl(m.tnStackOffset, -1)
assert m.tnStackOffset < 0
tnStackOffset = Iif(m.tnStackOffset < 0, m.tnStackOffset, -1)

lnStack = Program(-1) + m.tnStackOffset
assert m.lnStack > 0
lnStack = Max(m.lnStack, 1)

lcSys16 = Sys(16, m.lnStack)

RETURN '';
		+ Iif(lTrue(m.tlDateTime), Transform(Datetime()) + ' - ', '');
		+ Lower(JustFname(cModuleInfo(m.lcSys16, 'Address')));
		+ '!';
		+ Proper(cModuleInfo(m.lcSys16, 'Name'));
		+ [() - ]

* =============================================
FUNCTION lUserAnAdmin As Variant && Current User is an administrator
lparameters result as String && @

LOCAL success As Variant

TRY

	DECLARE Integer IsUserAnAdmin IN Shell32

	#if .F.
		IsUserAnAdmin function && http://msdn.microsoft.com/en-us/library/bb776463.aspx
		Minimum supported client: Windows XP [desktop apps only]
		Minimum supported server: Windows Server 2003 [desktop apps only]
		End of client support: Windows Vista && because of UAC I guess - looks good on Windows 7!
		End of server support: Windows Server 2008
	#endif
	
	success = IsUserAnAdmin() # 0
CATCH
	success = .NULL. && IsUserAnAdmin() not supported, we don't know
ENDTRY

result = Iif(IsNull(m.success);
	, Textmerge('';
		+ [<<Proper(Program())>>() ];
		+ ICase(;
				cLangUser() = 'fr',	[n'a pu déterminer si le compte utilisateur courant '<<GetEnv("USERNAME")>>' est un administrateur car],; && copy-paste this line to add another language support
														[could not determine whether current user account '<<GetEnv("USERNAME")>>' is an administrator because]; && Default: English
				);
		+ ' ';
		+ Iif(lUAC(); && Windows > Vista / Server 2008 - end of support of lUserAnAdmin()/IsUserAnAdmin() function according to http://msdn.microsoft.com/en-us/library/bb776463.aspx
			, ICase(;
					cLangUser() = 'fr',	[Shell32!IsUserAnAdmin() n'est plus supporté sur <<wcWindowsEdition()>>],; && copy-paste this line to add another language support
															[Shell32!IsUserAnAdmin() is no longer supported on <<wcWindowsEdition()>>]; && Default: English
					);
			, ICase(;
					cLangUser() = 'fr',	[<<wcWindowsEdition()>> est trop ancien pour supporter Shell32!IsUserAnAdmin()],; && copy-paste this line to add another language support
															[<<wcWindowsEdition()>> is too old to support Shell32!IsUserAnAdmin()]; && Default: English
					);
			);
		);
	, '';
	)

RETURN m.success

* =============================================
FUNCTION lUAC As Boolean && Current Windows version supports UAC
return Val(GetWordNum(Os(1), 2)) > 6.0
endfunc

* ========================================
PROCEDURE ProceduresAdd && Ajoute des fichiers prg au Set("Procedure")
LPARAMETERS tcPrgMask && [*.prg] Masque de fichier prg

LOCAL lcPrgMask, laPrgs[1], lnPrgs, lnPrg, lnResult && Nombre de fichiers prg ajoutés

lnResult = 0
lcPrgMask = Iif(Vartype(m.tcPrgMask)=='C' AND NOT Empty(m.tcPrgMask), m.tcPrgMask, '*.prg')
lnPrgs = ADir(laPrgs, m.lcPrgMask)
IF m.lnPrgs > 0
	FOR lnPrg = 1 TO m.lnPrgs
		lnResult = m.lnResult + Iif(ProcedureAdd(laPrgs[m.lnPrg, 1]), 1, 0)
	ENDFOR
ENDIF

RETURN m.lnResult
endproc

* ========================================
PROCEDURE ProcedureAdd && Ajoute un fichier prg à Set("Procedure") s'il n'y est déjà
LPARAMETERS ;
	tcPrg,; && fichier prg
	tlRemove && [.F.] Ôter de Set("Procedure")

LOCAL llResult && le fichier a été ajouté ou ôté selon la demande
IF Vartype(m.tcPrg) == 'C' AND File(m.tcPrg) AND InList(Upper(JustExt(m.tcPrg)), 'PRG', 'FXP')

	tcPrg = FullPath(ForceExt(m.tcPrg, 'FXP'))
	tlRemove = lTrue(m.tlRemove)

	IF '"' + m.tcPrg + '"' $ Set("Procedure")
		IF m.tlRemove
			RELEASE PROCEDURE (m.tcPrg)
			llResult = .T.
		ENDIF
	ELSE
		IF NOT m.tlRemove
			SET PROCEDURE TO (m.tcPrg) ADDITIVE
			llResult = .T.
		ENDIF
	ENDIF
ENDIF

RETURN m.llResult

* ========================================
PROCEDURE ClassLibRemove && Ôte un fichier vcx de Set("ClassLib") s'il y est
LPARAMETERS tcVCX && fichier vcx

RETURN ClassLibAdd(m.tcVCX, .T.)

* ========================================
PROCEDURE ClassLibAdd && Ajoute un fichier vcx à Set("ClassLib") s'il n'y est déjà
LPARAMETERS ;
	tcVCX,; && fichier(s) vcx
	tlRemove && [.F.] RELEASE CLASSLIB

LOCAL laVCX[1], lcVCX, llSet, lcAlias, llResult && le fichier a été ajouté ou retiré

IF .T.;
 and Vartype(m.tcVCX) == 'C';
 and ALines(laVCX, m.tcVCX, 5, ',', ';') > 0
 
 	FOR EACH lcVCX IN m.laVCX

		lcAlias = Upper(JustStem(m.lcVCX))
		llSet = ' ALIAS ' + m.lcAlias + ',' $ Set("Classlib") + ','
		IF lTrue(m.tlRemove)
			IF m.llSet
				RELEASE CLASSLIB (m.lcVCX)
				llResult = .T.
			ENDIF
		ELSE
			IF NOT m.llSet AND File(m.lcVCX)
				SET CLASSLIB TO (m.lcVCX) ADDITIVE
				llResult = .T.
			ENDIF
		ENDIF
 	ENDFOR
ENDIF

RETURN m.llResult
endproc

* ========================================
function Sys3 && Sys(3) unique même sur une machine rapide
local Sys3
Sys3 = Sys(3)
do while m.Sys3 == Sys(3)
enddo
return m.Sys3
endfunc

* ========================================
function Sys2015 && Sys(2015) unique même sur une machine rapide - alias de cSys2015Unique()
local Sys2015
Sys2015 = Sys(2015)
do while m.Sys2015 == Sys(2015)
enddo
return m.Sys2015
endfunc

* ========================================
function cSys2015Unique && Sys(2015) unique même sur une machine rapide - alias de Sys2015()
return Sys2015()
endfunc

* ========================================
procedure varStore(out, in) As Boolean && assigne une variable - alias de varSet()
store m.in to out && http://blogs.msdn.com/b/calvin_hsia/archive/2004/12/14/301282.aspx - Calvin: the STORE command doesn't do as much as the "x=y" command. More in a future blog.
endproc

* =============================================
procedure varSet(out, in) As Boolean && assigne une variable - alias de varStore()
store m.in to out && http://blogs.msdn.com/b/calvin_hsia/archive/2004/12/14/301282.aspx - Calvin: the STORE command doesn't do as much as the "x=y" command. More in a future blog.
endproc

* =============================================
function iInc(int, inc) As Integer && incrémente une variable
int = m.int + Evl(m.inc, 1)
return m.int
endproc

* =============================================
procedure setStepOn(condition as Boolean) As Boolean
if (Cast(m.condition as L) or Empty(Pcount())) && and lDevMode() useless
	set step on
endif
endproc

* =============================================
function abCoverage && Lance un historique d'exécution && Alias de oCoverage()
lparameters ;
  condition as Boolean; && [.T.] {fr} condition pour lancer le coverage
, lAdditive as Boolean; && [.F.] {en} Add to the same file
, lProduction as Boolean; && [.F.] {fr} Forcer le Coverage en mode production

return Iif(Empty(Pcount());
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

if .T.;
 and (Empty(Pcount()) or lTrue(m.condition));
 and (lDevMode() OR lTrue(m.lProduction))
 
	lAdditive = lTrue(m.lAdditive)

	LOCAL lcFile as String

	lcFile = '';
		+ Lower(cModuleInfo(Sys(16,0), 'Address')); && root program
		+ '_' + Lower(cModuleInfo(Sys(16, Program(-1)-1), 'Name'));
		+ Iif(m.lAdditive;
			, '';
			, '_' + TtocSep(, '-');
			);
		+ '.cov.log'

	IF m.lAdditive
		StrToFile(CRLF + Ttoc(Datetime()) + ' ' + Replicate('-', 50), m.lcFile, .T.)
	ENDIF

	RETURN abSet('COVERAGE';
			, '"' + m.lcFile + '"';
				+ Iif(m.lAdditive, ' ADDITIVE', '');
			,,,.T.)

endif
endfunc

* =============================================
FUNCTION RC4(cTexte, cClef)

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

LOCAL I, J, K, nLongClef, nInt, cResult
LOCAL ARRAY aInt(256)

FOR I = 1 TO 256
    aInt(I) = I-1
ENDFOR

J = 0
M.nLongClef = LEN(M.cClef)
FOR I = 1 TO 256
    J = BITAND(J + aInt(I) + ASC(SUBSTR(M.cClef, MOD(I-1,M.nLongClef)+1, 1)), 255)
    M.nInt = aInt(I)
    aInt(I) = aInt(J+1)
    aInt(J+1) = M.nInt
ENDFOR

I = 1
J = 0
M.cResult = ''
FOR K = 1 TO LEN(M.cTexte)
    I = BITAND(I, 255) + 1
    J = BITAND(J + aInt(I), 255)
    M.nInt = aInt(I)
    aInt(I) = aInt(J+1)
    aInt(J+1) = M.nInt
    M.cResult = M.cResult + CHR(BITXOR(ASC(SUBSTR(M.cTexte, K, 1)), ;
                                       aInt(BITAND(aInt(I) + M.nInt, 255)+1)))
ENDFOR

RETURN M.cResult
endfunc

* =============================================
function cObjectCamelCase && Nom ou adresse d'objet où les abréviations des classes sont en casse mixte
lparameters cObject
return Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(m.cObject;
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
return ICase(!Empty(m.uValue), m.notEmpty, lTrue(m.typeForce), uEmpty(Vartype(m.notEmpty)), m.uValue)
endfunc

* =============================================
function nNvl && substitute value instead of a not null value
lparameters value, substitute
return Iif(IsNull(m.value), m.value, m.substitute)
endfunc

* =============================================
function isNullOrEmpty && null or empty value
lparameters value
return !Vartype(m.value) == 'O' and Empty(Nvl(m.value, .F.))
endfunc
* --------------------------------------------
function isEmptyOrNull && empty or null value
lparameters value
return isNullOrEmpty(m.value)
endfunc

* =============================================
function ENvl && substitute value instead of an empty or null value
lparameters value, substitute
return Iif(isNullOrEmpty(m.value), m.substitute, m.value)
endfunc

* =============================================
function nENvl && substitute value instead of not empty and not null value
lparameters value, substitute
return Iif(isNullOrEmpty(m.value), m.value, m.substitute)
endfunc

* =============================================
function EvlNull && turns empty value into .null.
lparameters value
return Iif(!Vartype(m.value) == 'O' and Empty(m.value), .null., m.value)
endfunc

* =============================================
function lTrue && a value is .T.
lparameters value
return lTrue(m.value)
endfunc
* =============================================
function lFalse && a value is .F.
lparameters value
return Vartype(m.value) == 'L' and !m.value
endfunc

#if .F. && https://raw.githubusercontent.com/npm/node-semver/master/semver.js

exports = module.exports = SemVer;

// The debug function is excluded entirely from the minified version.
/* nomin */ var debug;
/* nomin */ if (typeof process === 'object' &&
    /* nomin */ process.env &&
    /* nomin */ process.env.NODE_DEBUG &&
    /* nomin */ /\bsemver\b/i.test(process.env.NODE_DEBUG))
  /* nomin */ debug = function() {
    /* nomin */ var args = Array.prototype.slice.call(arguments, 0);
    /* nomin */ args.unshift('SEMVER');
    /* nomin */ console.log.apply(console, args);
    /* nomin */ };
/* nomin */ else
  /* nomin */ debug = function() {};

// Note: this is the semver.org version of the spec that it implements
// Not necessarily the package version of this code.
exports.SEMVER_SPEC_VERSION = '2.0.0';

var MAX_LENGTH = 256;
var MAX_SAFE_INTEGER = Number.MAX_SAFE_INTEGER || 9007199254740991;

// The actual regexps go on exports.re
var re = exports.re = [];
var src = exports.src = [];
var R = 0;

// The following Regular Expressions can be used for tokenizing,
// validating, and parsing SemVer version strings.

// ## Numeric Identifier
// A single `0`, or a non-zero digit followed by zero or more digits.

var NUMERICIDENTIFIER = R++;
src[NUMERICIDENTIFIER] = '0|[1-9]\\d*';
var NUMERICIDENTIFIERLOOSE = R++;
src[NUMERICIDENTIFIERLOOSE] = '[0-9]+';


// ## Non-numeric Identifier
// Zero or more digits, followed by a letter or hyphen, and then zero or
// more letters, digits, or hyphens.

var NONNUMERICIDENTIFIER = R++;
src[NONNUMERICIDENTIFIER] = '\\d*[a-zA-Z-][a-zA-Z0-9-]*';


// ## Main Version
// Three dot-separated numeric identifiers.

var MAINVERSION = R++;
src[MAINVERSION] = '(' + src[NUMERICIDENTIFIER] + ')\\.' +
                   '(' + src[NUMERICIDENTIFIER] + ')\\.' +
                   '(' + src[NUMERICIDENTIFIER] + ')';

var MAINVERSIONLOOSE = R++;
src[MAINVERSIONLOOSE] = '(' + src[NUMERICIDENTIFIERLOOSE] + ')\\.' +
                        '(' + src[NUMERICIDENTIFIERLOOSE] + ')\\.' +
                        '(' + src[NUMERICIDENTIFIERLOOSE] + ')';

// ## Pre-release Version Identifier
// A numeric identifier, or a non-numeric identifier.

var PRERELEASEIDENTIFIER = R++;
src[PRERELEASEIDENTIFIER] = '(?:' + src[NUMERICIDENTIFIER] +
                            '|' + src[NONNUMERICIDENTIFIER] + ')';

var PRERELEASEIDENTIFIERLOOSE = R++;
src[PRERELEASEIDENTIFIERLOOSE] = '(?:' + src[NUMERICIDENTIFIERLOOSE] +
                                 '|' + src[NONNUMERICIDENTIFIER] + ')';


// ## Pre-release Version
// Hyphen, followed by one or more dot-separated pre-release version
// identifiers.

var PRERELEASE = R++;
src[PRERELEASE] = '(?:-(' + src[PRERELEASEIDENTIFIER] +
                  '(?:\\.' + src[PRERELEASEIDENTIFIER] + ')*))';

var PRERELEASELOOSE = R++;
src[PRERELEASELOOSE] = '(?:-?(' + src[PRERELEASEIDENTIFIERLOOSE] +
                       '(?:\\.' + src[PRERELEASEIDENTIFIERLOOSE] + ')*))';

// ## Build Metadata Identifier
// Any combination of digits, letters, or hyphens.

var BUILDIDENTIFIER = R++;
src[BUILDIDENTIFIER] = '[0-9A-Za-z-]+';

// ## Build Metadata
// Plus sign, followed by one or more period-separated build metadata
// identifiers.

var BUILD = R++;
src[BUILD] = '(?:\\+(' + src[BUILDIDENTIFIER] +
             '(?:\\.' + src[BUILDIDENTIFIER] + ')*))';


// ## Full Version String
// A main version, followed optionally by a pre-release version and
// build metadata.

// Note that the only major, minor, patch, and pre-release sections of
// the version string are capturing groups.  The build metadata is not a
// capturing group, because it should not ever be used in version
// comparison.

var FULL = R++;
var FULLPLAIN = 'v?' + src[MAINVERSION] +
                src[PRERELEASE] + '?' +
                src[BUILD] + '?';

src[FULL] = '^' + FULLPLAIN + '$';

// like full, but allows v1.2.3 and =1.2.3, which people do sometimes.
// also, 1.0.0alpha1 (prerelease without the hyphen) which is pretty
// common in the npm registry.
var LOOSEPLAIN = '[v=\\s]*' + src[MAINVERSIONLOOSE] +
                 src[PRERELEASELOOSE] + '?' +
                 src[BUILD] + '?';

var LOOSE = R++;
src[LOOSE] = '^' + LOOSEPLAIN + '$';

var GTLT = R++;
src[GTLT] = '((?:<|>)?=?)';

// Something like "2.*" or "1.2.x".
// Note that "x.x" is a valid xRange identifer, meaning "any version"
// Only the first item is strictly required.
var XRANGEIDENTIFIERLOOSE = R++;
src[XRANGEIDENTIFIERLOOSE] = src[NUMERICIDENTIFIERLOOSE] + '|x|X|\\*';
var XRANGEIDENTIFIER = R++;
src[XRANGEIDENTIFIER] = src[NUMERICIDENTIFIER] + '|x|X|\\*';

var XRANGEPLAIN = R++;
src[XRANGEPLAIN] = '[v=\\s]*(' + src[XRANGEIDENTIFIER] + ')' +
                   '(?:\\.(' + src[XRANGEIDENTIFIER] + ')' +
                   '(?:\\.(' + src[XRANGEIDENTIFIER] + ')' +
                   '(?:' + src[PRERELEASE] + ')?' +
                   src[BUILD] + '?' +
                   ')?)?';

var XRANGEPLAINLOOSE = R++;
src[XRANGEPLAINLOOSE] = '[v=\\s]*(' + src[XRANGEIDENTIFIERLOOSE] + ')' +
                        '(?:\\.(' + src[XRANGEIDENTIFIERLOOSE] + ')' +
                        '(?:\\.(' + src[XRANGEIDENTIFIERLOOSE] + ')' +
                        '(?:' + src[PRERELEASELOOSE] + ')?' +
                        src[BUILD] + '?' +
                        ')?)?';

var XRANGE = R++;
src[XRANGE] = '^' + src[GTLT] + '\\s*' + src[XRANGEPLAIN] + '$';
var XRANGELOOSE = R++;
src[XRANGELOOSE] = '^' + src[GTLT] + '\\s*' + src[XRANGEPLAINLOOSE] + '$';

// Tilde ranges.
// Meaning is "reasonably at or greater than"
var LONETILDE = R++;
src[LONETILDE] = '(?:~>?)';

var TILDETRIM = R++;
src[TILDETRIM] = '(\\s*)' + src[LONETILDE] + '\\s+';
re[TILDETRIM] = new RegExp(src[TILDETRIM], 'g');
var tildeTrimReplace = '$1~';

var TILDE = R++;
src[TILDE] = '^' + src[LONETILDE] + src[XRANGEPLAIN] + '$';
var TILDELOOSE = R++;
src[TILDELOOSE] = '^' + src[LONETILDE] + src[XRANGEPLAINLOOSE] + '$';

// Caret ranges.
// Meaning is "at least and backwards compatible with"
var LONECARET = R++;
src[LONECARET] = '(?:\\^)';

var CARETTRIM = R++;
src[CARETTRIM] = '(\\s*)' + src[LONECARET] + '\\s+';
re[CARETTRIM] = new RegExp(src[CARETTRIM], 'g');
var caretTrimReplace = '$1^';

var CARET = R++;
src[CARET] = '^' + src[LONECARET] + src[XRANGEPLAIN] + '$';
var CARETLOOSE = R++;
src[CARETLOOSE] = '^' + src[LONECARET] + src[XRANGEPLAINLOOSE] + '$';

// A simple gt/lt/eq thing, or just "" to indicate "any version"
var COMPARATORLOOSE = R++;
src[COMPARATORLOOSE] = '^' + src[GTLT] + '\\s*(' + LOOSEPLAIN + ')$|^$';
var COMPARATOR = R++;
src[COMPARATOR] = '^' + src[GTLT] + '\\s*(' + FULLPLAIN + ')$|^$';


// An expression to strip any whitespace between the gtlt and the thing
// it modifies, so that `> 1.2.3` ==> `>1.2.3`
var COMPARATORTRIM = R++;
src[COMPARATORTRIM] = '(\\s*)' + src[GTLT] +
                      '\\s*(' + LOOSEPLAIN + '|' + src[XRANGEPLAIN] + ')';

// this one has to use the /g flag
re[COMPARATORTRIM] = new RegExp(src[COMPARATORTRIM], 'g');
var comparatorTrimReplace = '$1$2$3';


// Something like `1.2.3 - 1.2.4`
// Note that these all use the loose form, because they'll be
// checked against either the strict or loose comparator form
// later.
var HYPHENRANGE = R++;
src[HYPHENRANGE] = '^\\s*(' + src[XRANGEPLAIN] + ')' +
                   '\\s+-\\s+' +
                   '(' + src[XRANGEPLAIN] + ')' +
                   '\\s*$';

var HYPHENRANGELOOSE = R++;
src[HYPHENRANGELOOSE] = '^\\s*(' + src[XRANGEPLAINLOOSE] + ')' +
                        '\\s+-\\s+' +
                        '(' + src[XRANGEPLAINLOOSE] + ')' +
                        '\\s*$';

// Star ranges basically just allow anything at all.
var STAR = R++;
src[STAR] = '(<|>)?=?\\s*\\*';

// Compile to actual regexp objects.
// All are flag-free, unless they were created above with a flag.
for (var i = 0; i < R; i++) {
  debug(i, src[i]);
  if (!re[i])
    re[i] = new RegExp(src[i]);
}

exports.parse = parse;
function parse(version, loose) {
  if (version instanceof SemVer)
    return version;

  if (typeof version !== 'string')
    return null;

  if (version.length > MAX_LENGTH)
    return null;

  var r = loose ? re[LOOSE] : re[FULL];
  if (!r.test(version))
    return null;

  try {
    return new SemVer(version, loose);
  } catch (er) {
    return null;
  }
}

exports.valid = valid;
function valid(version, loose) {
  var v = parse(version, loose);
  return v ? v.version : null;
}


exports.clean = clean;
function clean(version, loose) {
  var s = parse(version.trim().replace(/^[=v]+/, ''), loose);
  return s ? s.version : null;
}

exports.SemVer = SemVer;

function SemVer(version, loose) {
  if (version instanceof SemVer) {
    if (version.loose === loose)
      return version;
    else
      version = version.version;
  } else if (typeof version !== 'string') {
    throw new TypeError('Invalid Version: ' + version);
  }

  if (version.length > MAX_LENGTH)
    throw new TypeError('version is longer than ' + MAX_LENGTH + ' characters')

  if (!(this instanceof SemVer))
    return new SemVer(version, loose);

  debug('SemVer', version, loose);
  this.loose = loose;
  var m = version.trim().match(loose ? re[LOOSE] : re[FULL]);

  if (!m)
    throw new TypeError('Invalid Version: ' + version);

  this.raw = version;

  // these are actually numbers
  this.major = +m[1];
  this.minor = +m[2];
  this.patch = +m[3];

  if (this.major > MAX_SAFE_INTEGER || this.major < 0)
    throw new TypeError('Invalid major version')

  if (this.minor > MAX_SAFE_INTEGER || this.minor < 0)
    throw new TypeError('Invalid minor version')

  if (this.patch > MAX_SAFE_INTEGER || this.patch < 0)
    throw new TypeError('Invalid patch version')

  // numberify any prerelease numeric ids
  if (!m[4])
    this.prerelease = [];
  else
    this.prerelease = m[4].split('.').map(function(id) {
      if (/^[0-9]+$/.test(id)) {
        var num = +id
        if (num >= 0 && num < MAX_SAFE_INTEGER)
          return num
      }
      return id;
    });

  this.build = m[5] ? m[5].split('.') : [];
  this.format();
}

SemVer.prototype.format = function() {
  this.version = this.major + '.' + this.minor + '.' + this.patch;
  if (this.prerelease.length)
    this.version += '-' + this.prerelease.join('.');
  return this.version;
};

SemVer.prototype.inspect = function() {
  return '<SemVer "' + this + '">';
};

SemVer.prototype.toString = function() {
  return this.version;
};

SemVer.prototype.compare = function(other) {
  debug('SemVer.compare', this.version, this.loose, other);
  if (!(other instanceof SemVer))
    other = new SemVer(other, this.loose);

  return this.compareMain(other) || this.comparePre(other);
};

SemVer.prototype.compareMain = function(other) {
  if (!(other instanceof SemVer))
    other = new SemVer(other, this.loose);

  return compareIdentifiers(this.major, other.major) ||
         compareIdentifiers(this.minor, other.minor) ||
         compareIdentifiers(this.patch, other.patch);
};

SemVer.prototype.comparePre = function(other) {
  if (!(other instanceof SemVer))
    other = new SemVer(other, this.loose);

  // NOT having a prerelease is > having one
  if (this.prerelease.length && !other.prerelease.length)
    return -1;
  else if (!this.prerelease.length && other.prerelease.length)
    return 1;
  else if (!this.prerelease.length && !other.prerelease.length)
    return 0;

  var i = 0;
  do {
    var a = this.prerelease[i];
    var b = other.prerelease[i];
    debug('prerelease compare', i, a, b);
    if (a === undefined && b === undefined)
      return 0;
    else if (b === undefined)
      return 1;
    else if (a === undefined)
      return -1;
    else if (a === b)
      continue;
    else
      return compareIdentifiers(a, b);
  } while (++i);
};

// preminor will bump the version up to the next minor release, and immediately
// down to pre-release. premajor and prepatch work the same way.
SemVer.prototype.inc = function(release, identifier) {
  switch (release) {
    case 'premajor':
      this.prerelease.length = 0;
      this.patch = 0;
      this.minor = 0;
      this.major++;
      this.inc('pre', identifier);
      break;
    case 'preminor':
      this.prerelease.length = 0;
      this.patch = 0;
      this.minor++;
      this.inc('pre', identifier);
      break;
    case 'prepatch':
      // If this is already a prerelease, it will bump to the next version
      // drop any prereleases that might already exist, since they are not
      // relevant at this point.
      this.prerelease.length = 0;
      this.inc('patch', identifier);
      this.inc('pre', identifier);
      break;
    // If the input is a non-prerelease version, this acts the same as
    // prepatch.
    case 'prerelease':
      if (this.prerelease.length === 0)
        this.inc('patch', identifier);
      this.inc('pre', identifier);
      break;

    case 'major':
      // If this is a pre-major version, bump up to the same major version.
      // Otherwise increment major.
      // 1.0.0-5 bumps to 1.0.0
      // 1.1.0 bumps to 2.0.0
      if (this.minor !== 0 || this.patch !== 0 || this.prerelease.length === 0)
        this.major++;
      this.minor = 0;
      this.patch = 0;
      this.prerelease = [];
      break;
    case 'minor':
      // If this is a pre-minor version, bump up to the same minor version.
      // Otherwise increment minor.
      // 1.2.0-5 bumps to 1.2.0
      // 1.2.1 bumps to 1.3.0
      if (this.patch !== 0 || this.prerelease.length === 0)
        this.minor++;
      this.patch = 0;
      this.prerelease = [];
      break;
    case 'patch':
      // If this is not a pre-release version, it will increment the patch.
      // If it is a pre-release it will bump up to the same patch version.
      // 1.2.0-5 patches to 1.2.0
      // 1.2.0 patches to 1.2.1
      if (this.prerelease.length === 0)
        this.patch++;
      this.prerelease = [];
      break;
    // This probably shouldn't be used publicly.
    // 1.0.0 "pre" would become 1.0.0-0 which is the wrong direction.
    case 'pre':
      if (this.prerelease.length === 0)
        this.prerelease = [0];
      else {
        var i = this.prerelease.length;
        while (--i >= 0) {
          if (typeof this.prerelease[i] === 'number') {
            this.prerelease[i]++;
            i = -2;
          }
        }
        if (i === -1) // didn't increment anything
          this.prerelease.push(0);
      }
      if (identifier) {
        // 1.2.0-beta.1 bumps to 1.2.0-beta.2,
        // 1.2.0-beta.fooblz or 1.2.0-beta bumps to 1.2.0-beta.0
        if (this.prerelease[0] === identifier) {
          if (isNaN(this.prerelease[1]))
            this.prerelease = [identifier, 0];
        } else
          this.prerelease = [identifier, 0];
      }
      break;

    default:
      throw new Error('invalid increment argument: ' + release);
  }
  this.format();
  this.raw = this.version;
  return this;
};

exports.inc = inc;
function inc(version, release, loose, identifier) {
  if (typeof(loose) === 'string') {
    identifier = loose;
    loose = undefined;
  }

  try {
    return new SemVer(version, loose).inc(release, identifier).version;
  } catch (er) {
    return null;
  }
}

exports.diff = diff;
function diff(version1, version2) {
  if (eq(version1, version2)) {
    return null;
  } else {
    var v1 = parse(version1);
    var v2 = parse(version2);
    if (v1.prerelease.length || v2.prerelease.length) {
      for (var key in v1) {
        if (key === 'major' || key === 'minor' || key === 'patch') {
          if (v1[key] !== v2[key]) {
            return 'pre'+key;
          }
        }
      }
      return 'prerelease';
    }
    for (var key in v1) {
      if (key === 'major' || key === 'minor' || key === 'patch') {
        if (v1[key] !== v2[key]) {
          return key;
        }
      }
    }
  }
}

exports.compareIdentifiers = compareIdentifiers;

var numeric = /^[0-9]+$/;
function compareIdentifiers(a, b) {
  var anum = numeric.test(a);
  var bnum = numeric.test(b);

  if (anum && bnum) {
    a = +a;
    b = +b;
  }

  return (anum && !bnum) ? -1 :
         (bnum && !anum) ? 1 :
         a < b ? -1 :
         a > b ? 1 :
         0;
}

exports.rcompareIdentifiers = rcompareIdentifiers;
function rcompareIdentifiers(a, b) {
  return compareIdentifiers(b, a);
}

exports.major = major;
function major(a, loose) {
  return new SemVer(a, loose).major;
}

exports.minor = minor;
function minor(a, loose) {
  return new SemVer(a, loose).minor;
}

exports.patch = patch;
function patch(a, loose) {
  return new SemVer(a, loose).patch;
}

exports.compare = compare;
function compare(a, b, loose) {
  return new SemVer(a, loose).compare(b);
}

exports.compareLoose = compareLoose;
function compareLoose(a, b) {
  return compare(a, b, true);
}

exports.rcompare = rcompare;
function rcompare(a, b, loose) {
  return compare(b, a, loose);
}

exports.sort = sort;
function sort(list, loose) {
  return list.sort(function(a, b) {
    return exports.compare(a, b, loose);
  });
}

exports.rsort = rsort;
function rsort(list, loose) {
  return list.sort(function(a, b) {
    return exports.rcompare(a, b, loose);
  });
}

exports.gt = gt;
function gt(a, b, loose) {
  return compare(a, b, loose) > 0;
}

exports.lt = lt;
function lt(a, b, loose) {
  return compare(a, b, loose) < 0;
}

exports.eq = eq;
function eq(a, b, loose) {
  return compare(a, b, loose) === 0;
}

exports.neq = neq;
function neq(a, b, loose) {
  return compare(a, b, loose) !== 0;
}

exports.gte = gte;
function gte(a, b, loose) {
  return compare(a, b, loose) >= 0;
}

exports.lte = lte;
function lte(a, b, loose) {
  return compare(a, b, loose) <= 0;
}

exports.cmp = cmp;
function cmp(a, op, b, loose) {
  var ret;
  switch (op) {
    case '===':
      if (typeof a === 'object') a = a.version;
      if (typeof b === 'object') b = b.version;
      ret = a === b;
      break;
    case '!==':
      if (typeof a === 'object') a = a.version;
      if (typeof b === 'object') b = b.version;
      ret = a !== b;
      break;
    case '': case '=': case '==': ret = eq(a, b, loose); break;
    case '!=': ret = neq(a, b, loose); break;
    case '>': ret = gt(a, b, loose); break;
    case '>=': ret = gte(a, b, loose); break;
    case '<': ret = lt(a, b, loose); break;
    case '<=': ret = lte(a, b, loose); break;
    default: throw new TypeError('Invalid operator: ' + op);
  }
  return ret;
}

exports.Comparator = Comparator;
function Comparator(comp, loose) {
  if (comp instanceof Comparator) {
    if (comp.loose === loose)
      return comp;
    else
      comp = comp.value;
  }

  if (!(this instanceof Comparator))
    return new Comparator(comp, loose);

  debug('comparator', comp, loose);
  this.loose = loose;
  this.parse(comp);

  if (this.semver === ANY)
    this.value = '';
  else
    this.value = this.operator + this.semver.version;

  debug('comp', this);
}

var ANY = {};
Comparator.prototype.parse = function(comp) {
  var r = this.loose ? re[COMPARATORLOOSE] : re[COMPARATOR];
  var m = comp.match(r);

  if (!m)
    throw new TypeError('Invalid comparator: ' + comp);

  this.operator = m[1];
  if (this.operator === '=')
    this.operator = '';

  // if it literally is just '>' or '' then allow anything.
  if (!m[2])
    this.semver = ANY;
  else
    this.semver = new SemVer(m[2], this.loose);
};

Comparator.prototype.inspect = function() {
  return '<SemVer Comparator "' + this + '">';
};

Comparator.prototype.toString = function() {
  return this.value;
};

Comparator.prototype.test = function(version) {
  debug('Comparator.test', version, this.loose);

  if (this.semver === ANY)
    return true;

  if (typeof version === 'string')
    version = new SemVer(version, this.loose);

  return cmp(version, this.operator, this.semver, this.loose);
};


exports.Range = Range;
function Range(range, loose) {
  if ((range instanceof Range) && range.loose === loose)
    return range;

  if (!(this instanceof Range))
    return new Range(range, loose);

  this.loose = loose;

  // First, split based on boolean or ||
  this.raw = range;
  this.set = range.split(/\s*\|\|\s*/).map(function(range) {
    return this.parseRange(range.trim());
  }, this).filter(function(c) {
    // throw out any that are not relevant for whatever reason
    return c.length;
  });

  if (!this.set.length) {
    throw new TypeError('Invalid SemVer Range: ' + range);
  }

  this.format();
}

Range.prototype.inspect = function() {
  return '<SemVer Range "' + this.range + '">';
};

Range.prototype.format = function() {
  this.range = this.set.map(function(comps) {
    return comps.join(' ').trim();
  }).join('||').trim();
  return this.range;
};

Range.prototype.toString = function() {
  return this.range;
};

Range.prototype.parseRange = function(range) {
  var loose = this.loose;
  range = range.trim();
  debug('range', range, loose);
  // `1.2.3 - 1.2.4` => `>=1.2.3 <=1.2.4`
  var hr = loose ? re[HYPHENRANGELOOSE] : re[HYPHENRANGE];
  range = range.replace(hr, hyphenReplace);
  debug('hyphen replace', range);
  // `> 1.2.3 < 1.2.5` => `>1.2.3 <1.2.5`
  range = range.replace(re[COMPARATORTRIM], comparatorTrimReplace);
  debug('comparator trim', range, re[COMPARATORTRIM]);

  // `~ 1.2.3` => `~1.2.3`
  range = range.replace(re[TILDETRIM], tildeTrimReplace);

  // `^ 1.2.3` => `^1.2.3`
  range = range.replace(re[CARETTRIM], caretTrimReplace);

  // normalize spaces
  range = range.split(/\s+/).join(' ');

  // At this point, the range is completely trimmed and
  // ready to be split into comparators.

  var compRe = loose ? re[COMPARATORLOOSE] : re[COMPARATOR];
  var set = range.split(' ').map(function(comp) {
    return parseComparator(comp, loose);
  }).join(' ').split(/\s+/);
  if (this.loose) {
    // in loose mode, throw out any that are not valid comparators
    set = set.filter(function(comp) {
      return !!comp.match(compRe);
    });
  }
  set = set.map(function(comp) {
    return new Comparator(comp, loose);
  });

  return set;
};

// Mostly just for testing and legacy API reasons
exports.toComparators = toComparators;
function toComparators(range, loose) {
  return new Range(range, loose).set.map(function(comp) {
    return comp.map(function(c) {
      return c.value;
    }).join(' ').trim().split(' ');
  });
}

// comprised of xranges, tildes, stars, and gtlt's at this point.
// already replaced the hyphen ranges
// turn into a set of JUST comparators.
function parseComparator(comp, loose) {
  debug('comp', comp);
  comp = replaceCarets(comp, loose);
  debug('caret', comp);
  comp = replaceTildes(comp, loose);
  debug('tildes', comp);
  comp = replaceXRanges(comp, loose);
  debug('xrange', comp);
  comp = replaceStars(comp, loose);
  debug('stars', comp);
  return comp;
}

function isX(id) {
  return !id || id.toLowerCase() === 'x' || id === '*';
}

// ~, ~> --> * (any, kinda silly)
// ~2, ~2.x, ~2.x.x, ~>2, ~>2.x ~>2.x.x --> >=2.0.0 <3.0.0
// ~2.0, ~2.0.x, ~>2.0, ~>2.0.x --> >=2.0.0 <2.1.0
// ~1.2, ~1.2.x, ~>1.2, ~>1.2.x --> >=1.2.0 <1.3.0
// ~1.2.3, ~>1.2.3 --> >=1.2.3 <1.3.0
// ~1.2.0, ~>1.2.0 --> >=1.2.0 <1.3.0
function replaceTildes(comp, loose) {
  return comp.trim().split(/\s+/).map(function(comp) {
    return replaceTilde(comp, loose);
  }).join(' ');
}

function replaceTilde(comp, loose) {
  var r = loose ? re[TILDELOOSE] : re[TILDE];
  return comp.replace(r, function(_, M, m, p, pr) {
    debug('tilde', comp, _, M, m, p, pr);
    var ret;

    if (isX(M))
      ret = '';
    else if (isX(m))
      ret = '>=' + M + '.0.0 <' + (+M + 1) + '.0.0';
    else if (isX(p))
      // ~1.2 == >=1.2.0- <1.3.0-
      ret = '>=' + M + '.' + m + '.0 <' + M + '.' + (+m + 1) + '.0';
    else if (pr) {
      debug('replaceTilde pr', pr);
      if (pr.charAt(0) !== '-')
        pr = '-' + pr;
      ret = '>=' + M + '.' + m + '.' + p + pr +
            ' <' + M + '.' + (+m + 1) + '.0';
    } else
      // ~1.2.3 == >=1.2.3 <1.3.0
      ret = '>=' + M + '.' + m + '.' + p +
            ' <' + M + '.' + (+m + 1) + '.0';

    debug('tilde return', ret);
    return ret;
  });
}

// ^ --> * (any, kinda silly)
// ^2, ^2.x, ^2.x.x --> >=2.0.0 <3.0.0
// ^2.0, ^2.0.x --> >=2.0.0 <3.0.0
// ^1.2, ^1.2.x --> >=1.2.0 <2.0.0
// ^1.2.3 --> >=1.2.3 <2.0.0
// ^1.2.0 --> >=1.2.0 <2.0.0
function replaceCarets(comp, loose) {
  return comp.trim().split(/\s+/).map(function(comp) {
    return replaceCaret(comp, loose);
  }).join(' ');
}

function replaceCaret(comp, loose) {
  debug('caret', comp, loose);
  var r = loose ? re[CARETLOOSE] : re[CARET];
  return comp.replace(r, function(_, M, m, p, pr) {
    debug('caret', comp, _, M, m, p, pr);
    var ret;

    if (isX(M))
      ret = '';
    else if (isX(m))
      ret = '>=' + M + '.0.0 <' + (+M + 1) + '.0.0';
    else if (isX(p)) {
      if (M === '0')
        ret = '>=' + M + '.' + m + '.0 <' + M + '.' + (+m + 1) + '.0';
      else
        ret = '>=' + M + '.' + m + '.0 <' + (+M + 1) + '.0.0';
    } else if (pr) {
      debug('replaceCaret pr', pr);
      if (pr.charAt(0) !== '-')
        pr = '-' + pr;
      if (M === '0') {
        if (m === '0')
          ret = '>=' + M + '.' + m + '.' + p + pr +
                ' <' + M + '.' + m + '.' + (+p + 1);
        else
          ret = '>=' + M + '.' + m + '.' + p + pr +
                ' <' + M + '.' + (+m + 1) + '.0';
      } else
        ret = '>=' + M + '.' + m + '.' + p + pr +
              ' <' + (+M + 1) + '.0.0';
    } else {
      debug('no pr');
      if (M === '0') {
        if (m === '0')
          ret = '>=' + M + '.' + m + '.' + p +
                ' <' + M + '.' + m + '.' + (+p + 1);
        else
          ret = '>=' + M + '.' + m + '.' + p +
                ' <' + M + '.' + (+m + 1) + '.0';
      } else
        ret = '>=' + M + '.' + m + '.' + p +
              ' <' + (+M + 1) + '.0.0';
    }

    debug('caret return', ret);
    return ret;
  });
}

function replaceXRanges(comp, loose) {
  debug('replaceXRanges', comp, loose);
  return comp.split(/\s+/).map(function(comp) {
    return replaceXRange(comp, loose);
  }).join(' ');
}

function replaceXRange(comp, loose) {
  comp = comp.trim();
  var r = loose ? re[XRANGELOOSE] : re[XRANGE];
  return comp.replace(r, function(ret, gtlt, M, m, p, pr) {
    debug('xRange', comp, ret, gtlt, M, m, p, pr);
    var xM = isX(M);
    var xm = xM || isX(m);
    var xp = xm || isX(p);
    var anyX = xp;

    if (gtlt === '=' && anyX)
      gtlt = '';

    if (xM) {
      if (gtlt === '>' || gtlt === '<') {
        // nothing is allowed
        ret = '<0.0.0';
      } else {
        // nothing is forbidden
        ret = '*';
      }
    } else if (gtlt && anyX) {
      // replace X with 0
      if (xm)
        m = 0;
      if (xp)
        p = 0;

      if (gtlt === '>') {
        // >1 => >=2.0.0
        // >1.2 => >=1.3.0
        // >1.2.3 => >= 1.2.4
        gtlt = '>=';
        if (xm) {
          M = +M + 1;
          m = 0;
          p = 0;
        } else if (xp) {
          m = +m + 1;
          p = 0;
        }
      } else if (gtlt === '<=') {
        // <=0.7.x is actually <0.8.0, since any 0.7.x should
        // pass.  Similarly, <=7.x is actually <8.0.0, etc.
        gtlt = '<'
        if (xm)
          M = +M + 1
        else
          m = +m + 1
      }

      ret = gtlt + M + '.' + m + '.' + p;
    } else if (xm) {
      ret = '>=' + M + '.0.0 <' + (+M + 1) + '.0.0';
    } else if (xp) {
      ret = '>=' + M + '.' + m + '.0 <' + M + '.' + (+m + 1) + '.0';
    }

    debug('xRange return', ret);

    return ret;
  });
}

// Because * is AND-ed with everything else in the comparator,
// and '' means "any version", just remove the *s entirely.
function replaceStars(comp, loose) {
  debug('replaceStars', comp, loose);
  // Looseness is ignored here.  star is always as loose as it gets!
  return comp.trim().replace(re[STAR], '');
}

// This function is passed to string.replace(re[HYPHENRANGE])
// M, m, patch, prerelease, build
// 1.2 - 3.4.5 => >=1.2.0 <=3.4.5
// 1.2.3 - 3.4 => >=1.2.0 <3.5.0 Any 3.4.x will do
// 1.2 - 3.4 => >=1.2.0 <3.5.0
function hyphenReplace($0,
                       from, fM, fm, fp, fpr, fb,
                       to, tM, tm, tp, tpr, tb) {

  if (isX(fM))
    from = '';
  else if (isX(fm))
    from = '>=' + fM + '.0.0';
  else if (isX(fp))
    from = '>=' + fM + '.' + fm + '.0';
  else
    from = '>=' + from;

  if (isX(tM))
    to = '';
  else if (isX(tm))
    to = '<' + (+tM + 1) + '.0.0';
  else if (isX(tp))
    to = '<' + tM + '.' + (+tm + 1) + '.0';
  else if (tpr)
    to = '<=' + tM + '.' + tm + '.' + tp + '-' + tpr;
  else
    to = '<=' + to;

  return (from + ' ' + to).trim();
}


// if ANY of the sets match ALL of its comparators, then pass
Range.prototype.test = function(version) {
  if (!version)
    return false;

  if (typeof version === 'string')
    version = new SemVer(version, this.loose);

  for (var i = 0; i < this.set.length; i++) {
    if (testSet(this.set[i], version))
      return true;
  }
  return false;
};

function testSet(set, version) {
  for (var i = 0; i < set.length; i++) {
    if (!set[i].test(version))
      return false;
  }

  if (version.prerelease.length) {
    // Find the set of versions that are allowed to have prereleases
    // For example, ^1.2.3-pr.1 desugars to >=1.2.3-pr.1 <2.0.0
    // That should allow `1.2.3-pr.2` to pass.
    // However, `1.2.4-alpha.notready` should NOT be allowed,
    // even though it's within the range set by the comparators.
    for (var i = 0; i < set.length; i++) {
      debug(set[i].semver);
      if (set[i].semver === ANY)
        continue;

      if (set[i].semver.prerelease.length > 0) {
        var allowed = set[i].semver;
        if (allowed.major === version.major &&
            allowed.minor === version.minor &&
            allowed.patch === version.patch)
          return true;
      }
    }

    // Version has a -pre, but it's not one of the ones we like.
    return false;
  }

  return true;
}

exports.satisfies = satisfies;
function satisfies(version, range, loose) {
  try {
    range = new Range(range, loose);
  } catch (er) {
    return false;
  }
  return range.test(version);
}

exports.maxSatisfying = maxSatisfying;
function maxSatisfying(versions, range, loose) {
  return versions.filter(function(version) {
    return satisfies(version, range, loose);
  }).sort(function(a, b) {
    return rcompare(a, b, loose);
  })[0] || null;
}

exports.validRange = validRange;
function validRange(range, loose) {
  try {
    // Return '*' instead of '' so that truthiness works.
    // This will throw if it's invalid anyway
    return new Range(range, loose).range || '*';
  } catch (er) {
    return null;
  }
}

// Determine if version is less than all the versions possible in the range
exports.ltr = ltr;
function ltr(version, range, loose) {
  return outside(version, range, '<', loose);
}

// Determine if version is greater than all the versions possible in the range.
exports.gtr = gtr;
function gtr(version, range, loose) {
  return outside(version, range, '>', loose);
}

exports.outside = outside;
function outside(version, range, hilo, loose) {
  version = new SemVer(version, loose);
  range = new Range(range, loose);

  var gtfn, ltefn, ltfn, comp, ecomp;
  switch (hilo) {
    case '>':
      gtfn = gt;
      ltefn = lte;
      ltfn = lt;
      comp = '>';
      ecomp = '>=';
      break;
    case '<':
      gtfn = lt;
      ltefn = gte;
      ltfn = gt;
      comp = '<';
      ecomp = '<=';
      break;
    default:
      throw new TypeError('Must provide a hilo val of "<" or ">"');
  }

  // If it satisifes the range it is not outside
  if (satisfies(version, range, loose)) {
    return false;
  }

  // From now on, variable terms are as if we're in "gtr" mode.
  // but note that everything is flipped for the "ltr" function.

  for (var i = 0; i < range.set.length; ++i) {
    var comparators = range.set[i];

    var high = null;
    var low = null;

    comparators.forEach(function(comparator) {
      if (comparator.semver === ANY) {
        comparator = new Comparator('>=0.0.0')
      }
      high = high || comparator;
      low = low || comparator;
      if (gtfn(comparator.semver, high.semver, loose)) {
        high = comparator;
      } else if (ltfn(comparator.semver, low.semver, loose)) {
        low = comparator;
      }
    });

    // If the edge version comparator has a operator then our version
    // isn't outside it
    if (high.operator === comp || high.operator === ecomp) {
      return false;
    }

    // If the lowest version comparator has an operator and our version
    // is less than it then it isn't higher than the range
    if ((!low.operator || low.operator === comp) &&
        ltefn(version, low.semver)) {
      return false;
    } else if (low.operator === ecomp && ltfn(version, low.semver)) {
      return false;
    }
  }
  return true;
}

#endif

* =============================
function abSemVer as abSemVer of abDev.prg
lparameters ;
  result as String; && @ résultat (cumulatif)
, version as String; && version à analyser
, loose as Boolean; && [.F.]

if Pcount() <= 2 or Vartype(m.version) # 'C'
	loose = m.version
	version = m.result
endif

return CreateObject('abSemVer', @m.result, m.version, m.loose)
endfunc

* -----------------
function labSemVer && c'est un objet de la classe abSemVer
lparameters oSemVer as Variant
return loClass(m.oSemVer, 'abSemVer')
endfunc

* =============================
DEFINE CLASS abSemVer as GA_LIGHTWEIGHT_CLASS of abGA.prg && Implements Semantic Versioning 2.0.0 http://semver.org/ - inspired by https://github.com/npm/node-semver/
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

* -----------------
procedure Init
lparameters ;
  result as String; && @ résultat (cumulatif)
, version as String; && version à analyser
, loose as Boolean; && [.F.]

local success as Boolean;
, cResult as String;

success = this.Init_(@m.cResult, m.version, m.loose)

assert m.success message cAssertMsg(m.cResult)
= m.success or cResultAdd(@m.result, m.cResult)

return m.success
endproc

* -----------------
hidden procedure Init_
lparameters ;
  result as String; && @ résultat (cumulatif)
, version as String; && [this.raw] version à analyser
, loose as Boolean; && [.F.]

loose = lTrue(m.loose)

local success as Boolean;
, oRegExp as abRegExp of abTxt.prg;
, oSubMatch as Collection;
, cPreReleases as String;
, nPreRelease as Integer;
, iPreRelease as Integer;
, cPreRelease as String;
, oRegExpNum as abRegExp of abTxt.prg;

do case
case !this.Init_RegExp(@m.result)
	return m.success
case this.lSemVer(m.version)
 loose   = m.version.loose
 version = m.version.version
case !ga_Type_IsChar(m.version, .T.)
	return cResultAdd(@m.result, [Invalid version: ] + cL(m.version))
endcase

store alltrim(m.version) to this.raw, version
this.loose = m.loose

if lenc(m.version) > this.MAX_LENGTH
  return cResultAdd(@m.result, Textmerge([version <<cL(m.version)>> is longer than <<this.MAX_LENGTH>> characters]))
endif

oRegExp = Iif(m.loose, this.oRegExpr.LOOSE, this.oRegExpr.FULL)

if Empty(m.oRegExp.execute(m.version))
  return cResultAdd(@m.result, Textmerge([Invalid version: <<m.version>>]))
endif

oSubMatch = m.oRegExp.matches[3]

&& these are actually numbers
this.major = Cast(m.oSubMatch.Item(1) as I) && .Item() évite les erreur de project manager
this.minor = Cast(m.oSubMatch.Item(2) as I)
this.patch = Cast(m.oSubMatch.Item(3) as I)

do case
case !Between(m.this.major, 0, this.MAX_SAFE_INTEGER)
  return cResultAdd(@m.result, Textmerge([Invalid major version: <<m.this.major>>]))
case !Between(m.this.minor, 0, this.MAX_SAFE_INTEGER)
  return cResultAdd(@m.result, Textmerge([Invalid minor version: <<m.this.minor>>]))
case !Between(m.this.patch, 0, this.MAX_SAFE_INTEGER)
  return cResultAdd(@m.result, Textmerge([Invalid patch version: <<m.this.patch>>]))
endcase

this.lMajor = Empty(m.this.minor) && major release
this.lMinor = !this.lMajor and Empty(m.this.patch) && minor release
this.lPatch = !Empty(m.this.patch) && patch release

&& pre-release; http://semver.org/
&& A pre-release version MAY be denoted by appending a hyphen and a series of dot separated identifiers immediately following the patch version; identifiers:
&& - MUST comprise only ASCII alphanumerics and hyphen [0-9A-Za-z-].
&& - MUST NOT be empty.
&& Numeric identifiers MUST NOT include leading zeroes.
&& Pre-release versions have a lower precedence than the associated normal version.
&& A pre-release version indicates that the version is unstable and might not satisfy the intended compatibility requirements as denoted by its associated normal version.
&& Examples: 1.0.0-alpha, 1.0.0-alpha.1, 1.0.0-0.3.7, 1.0.0-x.7.z.92.
cPreReleases = m.oSubMatch.Item(4)
this.lPreRelease = !Empty(m.cPreReleases)
if m.this.lPreRelease
	oRegExpNum = abRegExp('^[0-9]+$')
	nPreRelease = GetWordCount(m.cPreReleases, '.')
	dimension this.prerelease[m.nPreRelease]
	for iPreRelease = 1 to m.nPreRelease
		cPreRelease = GetWordNum(m.cPreReleases, m.iPreRelease, '.')
		this.prerelease[m.iPreRelease] = Iif(m.oRegExpNum.test(m.cPreRelease);
			, Cast(m.cPreRelease as I);
			, Lower(m.cPreRelease);
			)
	endfor
endif

this.format
endproc

* -----------------
procedure format

local cPreReleases, aPreRelease[1]

this.lPreRelease = !IsNull(m.this.prerelease)
if m.this.lPreRelease
	Acopy(this.prerelease, aPreRelease)
	cPreReleases = '-' + cListOfArray(@m.aPreRelease, '.',,,.T.)
endif

this.version = '';
	      + Cast(m.this.major as M);
	+ '.' + Cast(m.this.minor as M);
	+ '.' + Cast(m.this.patch as M);
	+ Evl(m.cPreReleases, '')

return this.version
endproc

* -----------------
hidden procedure Init_RegExp && Initializes Regular Expressions are used for tokenizing, validating and parsing abSemVer version strings
lparameters result as String; && @ résultat (cumulatif)

this.oPattern = CreateObject('Empty')
this.oRegExpr = CreateObject('Empty')

&& ## Numeric Identifier
&& A single `0`, or a non-zero digit followed by zero or more digits.

addProperty(this.oPattern, 'NUMERICIDENTIFIER', '0|[1-9]\d*')
addProperty(this.oPattern, 'NUMERICIDENTIFIERLOOSE', '[0-9]+')

&& ## Non-numeric Identifier
&& Zero or more digits, followed by a letter or hyphen, and then zero or
&& more letters, digits, or hyphens.

addProperty(this.oPattern, 'NONNUMERICIDENTIFIER', '\d*[a-zA-Z-][a-zA-Z0-9-]*')

&& ## Main Version
&& Three dot-separated numeric identifiers.

addProperty(this.oPattern, 'MAINVERSION', '';
	+ '(' + this.oPattern.NUMERICIDENTIFIER + ')\.';
	+ '(' + this.oPattern.NUMERICIDENTIFIER + ')\.';
	+ '(' + this.oPattern.NUMERICIDENTIFIER + ')';
	)

addProperty(this.oPattern, 'MAINVERSIONLOOSE', '';
	+ '(' + this.oPattern.NUMERICIDENTIFIERLOOSE + ')\.';
	+ '(' + this.oPattern.NUMERICIDENTIFIERLOOSE + ')\.';
	+ '(' + this.oPattern.NUMERICIDENTIFIERLOOSE + ')';
	)

&& ## Pre-release Version Identifier
&& A numeric identifier, or a non-numeric identifier.

addProperty(this.oPattern, 'PRERELEASEIDENTIFIER', '(?:' + this.oPattern.NUMERICIDENTIFIER + '|' + this.oPattern.NONNUMERICIDENTIFIER + ')')
addProperty(this.oPattern, 'PRERELEASEIDENTIFIERLOOSE', '(?:' + this.oPattern.NUMERICIDENTIFIERLOOSE + '|' + this.oPattern.NONNUMERICIDENTIFIER + ')')

&& ## Pre-release Version
&& Hyphen, followed by one or more dot-separated pre-release version identifiers.

addProperty(this.oPattern, 'prerelease', '(?:-(' + this.oPattern.PRERELEASEIDENTIFIER + '(?:\.' + this.oPattern.PRERELEASEIDENTIFIER + ')*))')
addProperty(this.oPattern, 'PRERELEASELOOSE', '(?:-?(' + this.oPattern.PRERELEASEIDENTIFIERLOOSE + '(?:\.' + this.oPattern.PRERELEASEIDENTIFIERLOOSE + ')*))')

&& ## Build Metadata Identifier
&& Any combination of digits, letters, or hyphens.

addProperty(this.oPattern, 'BUILDIDENTIFIER', '[0-9A-Za-z-]+')

&& ## Build Metadata
&& Plus sign, followed by one or more period-separated build metadata
&& identifiers.

addProperty(this.oPattern, 'BUILD', '(?:\+(' + this.oPattern.BUILDIDENTIFIER + '(?:\.' + this.oPattern.BUILDIDENTIFIER + ')*))')

&& ## Full Version String
&& A main version, followed optionally by a pre-release version and
&& build metadata.

&& Note that the only major, minor, patch, and pre-release sections of
&& the version string are capturing groups.  The build metadata is not a
&& capturing group, because it should not ever be used in version
&& comparison.

FULLPLAIN = 'v?' + this.oPattern.MAINVERSION + this.oPattern.prerelease + '?' + this.oPattern.BUILD + '?'

addProperty(this.oPattern, 'FULL', '^' + FULLPLAIN + '$')

&& like full, but allows v1.2.3 and =1.2.3, which people do sometimes.
&& also, 1.0.0alpha1 (prerelease without the hyphen) which is pretty common in the npm registry.
LOOSEPLAIN = '[v=\s]*';
	+ this.oPattern.MAINVERSIONLOOSE;
	+ this.oPattern.PRERELEASELOOSE + '?';
	+ this.oPattern.BUILD + '?'

addProperty(this.oPattern, 'LOOSE', '^' + LOOSEPLAIN + '$')

addProperty(this.oPattern, 'GTLT', '((?:<|>)?=?)')

&& Something like "2.*" or "1.2.x".
&& Note that "x.x" is a valid xRange identifer, meaning "any version"
&& Only the first item is strictly required.
addProperty(this.oPattern, 'XRANGEIDENTIFIERLOOSE', this.oPattern.NUMERICIDENTIFIERLOOSE + '|x|X|\*')
addProperty(this.oPattern, 'XRANGEIDENTIFIER', this.oPattern.NUMERICIDENTIFIER + '|x|X|\*')

addProperty(this.oPattern, 'XRANGEPLAIN', '';
	+ '[v=\s]*(' + this.oPattern.XRANGEIDENTIFIER + ')';
	+ '(?:\.(' + this.oPattern.XRANGEIDENTIFIER + ')';
	+ '(?:\.(' + this.oPattern.XRANGEIDENTIFIER + ')';
	+ '(?:' + this.oPattern.prerelease + ')?';
	+ this.oPattern.BUILD + '?';
	+ ')?)?';
	)

addProperty(this.oPattern, 'XRANGEPLAINLOOSE', '';
	+ '[v=\s]*(' + this.oPattern.XRANGEIDENTIFIERLOOSE + ')';
	+ '(?:\.(' + this.oPattern.XRANGEIDENTIFIERLOOSE + ')';
	+ '(?:\.(' + this.oPattern.XRANGEIDENTIFIERLOOSE + ')';
	+ '(?:' + this.oPattern.PRERELEASELOOSE + ')?';
	+ this.oPattern.BUILD + '?';
	+ ')?)?';
	)

addProperty(this.oPattern, 'XRANGE', '^' + this.oPattern.GTLT + '\s*' + this.oPattern.XRANGEPLAIN + '$')
addProperty(this.oPattern, 'XRANGELOOSE', '^' + this.oPattern.GTLT + '\s*' + this.oPattern.XRANGEPLAINLOOSE + '$')

&& Tilde ranges.
&& Meaning is "reasonably at or greater than"
addProperty(this.oPattern, 'LONETILDE', '(?:~>?)')

addProperty(this.oPattern, 'TILDETRIM', '(\s*)' + this.oPattern.LONETILDE + '\s+')
addProperty(this.oRegExpr, 'TILDETRIM', abRegExp(this.oPattern.TILDETRIM, 'g'))

addProperty(this.oPattern, 'TILDE', '^' + this.oPattern.LONETILDE + this.oPattern.XRANGEPLAIN + '$')
addProperty(this.oPattern, 'TILDELOOSE', '^' + this.oPattern.LONETILDE + this.oPattern.XRANGEPLAINLOOSE + '$')

&& Caret ranges.
&& Meaning is "at least and backwards compatible with"
addProperty(this.oPattern, 'LONECARET', '(?:\^)')

addProperty(this.oPattern, 'CARETTRIM', '(\s*)' + this.oPattern.LONECARET + '\s+')
addProperty(this.oRegExpr, 'CARETTRIM', abRegExp(this.oPattern.CARETTRIM, 'g'))

addProperty(this.oPattern, 'CARET', '^' + this.oPattern.LONECARET + this.oPattern.XRANGEPLAIN + '$')
addProperty(this.oPattern, 'CARETLOOSE', '^' + this.oPattern.LONECARET + this.oPattern.XRANGEPLAINLOOSE + '$')

&& A simple gt/lt/eq thing, or just "" to indicate "any version"
addProperty(this.oPattern, 'COMPARATORLOOSE', '^' + this.oPattern.GTLT + '\s*(' + LOOSEPLAIN + ')$|^$')
addProperty(this.oPattern, 'COMPARATOR', '^' + this.oPattern.GTLT + '\s*(' + FULLPLAIN + ')$|^$')


&& An expression to strip any whitespace between the gtlt and the thing
&& it modifies, so that `> 1.2.3` ==> `>1.2.3`
addProperty(this.oPattern, 'COMPARATORTRIM', '(\s*)' + this.oPattern.GTLT + '\s*(' + LOOSEPLAIN + '|' + this.oPattern.XRANGEPLAIN + ')')

&& this one has to use the /g flag
addProperty(this.oRegExpr, 'COMPARATORTRIM', abRegExp(this.oPattern.COMPARATORTRIM, 'g'))

&& Something like `1.2.3 - 1.2.4`
&& Note that these all use the loose form, because they'll be
&& checked against either the strict or loose comparator form
&& later.
addProperty(this.oPattern, 'HYPHENRANGE', '^\s*(' + this.oPattern.XRANGEPLAIN + ')' + '\s+-\s+' + '(' + this.oPattern.XRANGEPLAIN + ')' + '\s*$')

addProperty(this.oPattern, 'HYPHENRANGELOOSE', '^\s*(' + this.oPattern.XRANGEPLAINLOOSE + ')' + '\s+-\s+' + '(' + this.oPattern.XRANGEPLAINLOOSE + ')' + '\s*$')

&& Star ranges basically just allow anything at all.
addProperty(this.oPattern, 'STAR', '(<|>)?=?\s*\*')

local aPattern[1], cPattern
if aMember(aPattern, this.oPattern) > 0
	for each cPattern in m.aPattern
		if !lProperty(this.oRegExpr, m.cPattern)
			AddProperty(m.this.oRegExpr, m.cPattern, abRegExp(Evaluate('this.oPattern.' + m.cPattern)))
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
return Iif(this.lSemVer(m.other);
	, m.other;
	, abSemVer(m.other, m.this.loose);
	)
endfunc

* -----------------
function compare && compare cette version avec une autre
lparameters other as Variant && autre version
return Evl(this.compareMain(@m.other), this.comparePre(@m.other))
endfunc

* -----------------
function compareMain && compare les versions principales
lparameters other as Variant && autre version

other = this.oSemVer(m.other)
return Iif(this.lSemVer(m.other);
	, Evl(Evl(;
		  this.compareIdentifiers(this.major, m.other.major);
		, this.compareIdentifiers(this.minor, m.other.minor));
		, this.compareIdentifiers(this.patch, m.other.patch));
	, .null.;
	)
endfunc

* -----------------
protected function comparePre && compare les versions de pre-release (beta etc.)
lparameters other as Variant && autre version

local comparePre as Integer;
, iPreRelease as Integer;
, nPreRelThis as Integer;
, nPreRelOther as Integer;
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
	
	nPreRelThis  = Alen(m.this.prerelease)
	nPreRelOther = Alen(m.other.prerelease)
	
	for iPreRelease = 1 to max(m.nPreRelThis, m.nPreRelOther)
		do case
		case m.iPreRelease > m.nPreRelOther
			return +1
		case m.iPreRelease > m.nPreRelThis
			return -1
		case .T.;
		 and varSet(@m.uPreRelThis, m.this.prerelease[m.iPreRelease]);
		 and varSet(@m.uPreRelOther, m.other.prerelease[m.iPreRelease]);
		 and Vartype(m.uPreRelThis) == Vartype(m.uPreRelOther);
		 and m.uPreRelThis == m.uPreRelOther;
		 and .T.
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
return iCase(;
	Vartype(m.a) == 'N' and Vartype(m.b) <> 'N',;
		+1,;
	Vartype(m.a) <> 'N' and Vartype(m.b) == 'N',;
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
return Ascan(m.this.prerelease, 'beta')
endfunc

* -----------------
function lBeta(iBeta) && beta prerelease
iBeta = this.iBeta()
return m.iBeta > 0
endfunc

* -----------------
function nBeta && si beta prerelease, n° de beta
local iBeta
return Iif(this.lBeta(@m.iBeta) and Alen(this.prerelease) > m.iBeta and Vartype(this.prerelease[m.iBeta + 1]) == 'N';
	, this.prerelease[m.iBeta + 1];
	, .null.;
	)
endfunc

* -----------------
function gt(other as Variant) && cette version est supérieure à une autre
return this.compare(m.other) > 0
endfunc

* -----------------
function gte(other as Variant) && cette version est supérieure ou égale à une autre
return this.compare(m.other) >= 0
endfunc

* -----------------
function lt(other as Variant) && cette version est inférieure à une autre
return this.compare(m.other) < 0
endfunc

* -----------------
function lte(other as Variant) && cette version est inférieure ou égale à une autre
return this.compare(m.other) <= 0
endfunc

* -----------------
function eq(other as Variant) && cette version est égale à une autre
return Empty(this.compare(m.other))
endfunc

* -----------------
function neq(other as Variant) && cette version est égale à une autre
return !Empty(this.compare(m.other))
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
, identifier; && ['beta'] if m.release = 'pre..' pre-release identifier such as 'beta'

release    = Evl(m.release, '')
identifier = Evl(m.identifier, 'beta')

local success as Boolean;
, iPreRelease as Integer;
, nPreRelease as Integer;

success = .T.

do case

case !ga_Type_IsChar(m.release, .T.)
	success = .F.
		
case !varSet(@m.release, Lower(cEuroANSI(Alltrim(m.release))))

&& premajor will bump the version up to the next major release, and immediately down to pre-release.
&& preminor and prepatch work the same way.
case m.release == 'premajor'
	this.major = this.major + 1 
	store 0 to this.minor, this.patch
	this.prereleaseClear
	success = this.inc('pre', m.identifier)

case m.release == 'preminor'
	this.minor = this.minor + 1
	this.patch = 0
	this.prereleaseClear
	success = this.inc('pre', m.identifier)
      
case m.release == 'prepatch' && If this is already a prerelease, it'll bump to the next version
	this.prereleaseClear && drop any prereleases that might already exist, since they are not relevant at this point.
	success = .T.;
	 and this.inc('patch');
	 and this.inc('pre', m.identifier)

case m.release == 'prerelease'
	success = .T.;
	 and (m.this.lPreRelease or this.inc('patch')); && If input is a non-prerelease version, this acts the same as a prepatch.
	 and this.inc('pre', m.identifier)


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
		nPreRelease = aLen(m.this.prerelease)
		for iPreRelease = m.nPreRelease to 1 step -1
			if Vartype(m.this.prerelease[m.iPreRelease]) == 'N'
				this.prerelease[m.iPreRelease] = m.this.prerelease[m.iPreRelease] + 1
				exit
			endif
		endfor
		if Empty(m.iPreRelease) && didn't increment anything
			nPreRelease = m.nPreRelease + 1 && JS Array.push() ajoute un ou plusieurs éléments à la fin d'un tableau et retourne la nouvelle taille du tableau.
			dimension this.prerelease[m.nPreRelease]
			this.prerelease[m.nPreRelease] = 0
		endif
	endif
	
  && 1.2.0-beta.fooblz or 1.2.0-beta bump to 1.2.0-beta.0
	do case
	case !ga_Type_IsChar(m.identifier, .T.)
	case !varSet(@m.identifier, Lower(cEuroANSI(Alltrim(m.identifier))))
	case .F.;
	 or !luEqual(this.prerelease[1], m.identifier, .T.);
	 or Alen(this.prerelease) < 2;
	 or !Vartype(this.prerelease[2]) == 'N'
		dimension this.prerelease[2]
		this.prerelease[1] = m.identifier
		this.prerelease[2] = 0
	endcase

otherwise
	success = .F.

endcase

assert m.success message Textmerge([<<cL(m.release)>> is an invalid release verb])

this.format
this.raw = this.version

return m.success
endfunc

* =============================
ENDDEFINE && CLASS abSemVer
* =============================

* -----------------
function abSemVer_test && teste la classe abSemVer
lparameters nTest && @ number for tests ran

local success as boolean;
, unitTest as boolean;
, oUnitTest as abUnitTest of abDev.prg;
, oAsserts as abSet of abDev.prg;
, oSemVer as abSemVer of abDev.prg;

* oUnitTest = abUnitTest()
oAsserts  = abSet('ASSERTS', 'ON')
success = .T.
nTest = 0

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

#if .F.
AB()
nTest = 0
_cliptext = nEvl(varSet(@m.nTest, 0), '') + Textmerge([&]+[& <<Datetime()>> - abSemVer_test(): <<abSemVer_test(@m.nTest)>> - <<m.nTest>> tests] + Chr(13))
#endif

&& 18/09/15 10:44:13 - abSemVer_test(): .T. - 10 tests

return m.success
endfunc

* -----------------
function abSemVer_test_inc && teste abSemVer.inc() qui est la méthode la plus délicate
lparameters ;
  versionFrom;
, versionTo;
, release; && ['patch'] type of release
, identifier; && [''] if m.release = 'pre..' pre-release identifier such as 'beta'

local success as boolean;
, oSemVer as abSemVer of abDev.prg;

oSemVer = abSemVer(m.versionFrom)
success = m.oSemVer.inc(m.release, m.identifier) and m.oSemVer.version == m.versionTo

assert m.success
return m.success
endfunc
