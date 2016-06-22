* {fr} awPublic.prg
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

* =============================================================
function wlWeb as Boolean && {fr} L'application fonctionne en mode Web
lparameters toServer as awServer of awServer.prg && @ {en} server object
return .T.;
 and Vartype(m.goWCserver) == 'O';
 and loClass(m.goWCserver, 'awServer');
 and varSet(@m.toServer, m.goWCserver);
 and .T.
endfunc

* =============================================================
function wlLAN as Boolean && {fr} L'application fonctionne en mode LAN
return !wlWeb()
endfunc

* =============================================================
function wlRequest as Boolean && {fr} L'application fonctionne en mode Web et une requête a été reçue
lparameters toRequest as wwRequest of wwRequest.prg && @ {en} HTTP request object
local toServer as awServer of awServer.prg && @ {en} server object
return .T.;
 and wlWeb(@m.toServer);
 and Vartype(m.toServer.oRequest) == 'O';
 and loClass(m.toServer.oRequest, 'wwRequest');
 and varSet(@m.toRequest, m.toServer.oRequest);
 and .T.
endfunc

* =============================================================
function wlProcess as Boolean && {fr} L'application fonctionne en mode Web et une requête est en cours de traitement
lparameters toProcess as awProcess of awServer.prg && @ {en} FoxInCloud request processing Object
return .T.;
 and Vartype(m.Process) == 'O';
 and loClass(m.Process, 'awProcess');
 and varSet(@m.toProcess, m.Process);
 and .T.
endfunc

* =============================================================
function wlResponse as Boolean && {fr} L'application fonctionne en mode Web et une réponse est disponible
lparameters toResponse as wwResponse of wwResponse.prg && @ {en} HTTP response object
local toProcess as awProcess of awProcess.prg && {en} request processing object
return .T.;
 and wlProcess(@m.toProcess);
 and Vartype(m.toProcess.oResponse) == 'O';
 and loClass(m.toProcess.oResponse, 'wwResponse');
 and varSet(@m.toResponse, m.toProcess.oResponse);
 and .T.
endfunc

* =============================================================
function wlAJAX as Boolean && {fr} L'application fonctionne avec FoxInCloud
lparameters toAJAX as awAJAX of awServer.prg && @ {en} FoxInCloud AJAX request processing Object
toAJAX = .null.

local oProcess as awProcess of awServer.prg

return .F.;
	or .T.;
	 and wlProcess(@m.oProcess);
	 and loClass(m.oProcess.oAJAX, 'awAJAX');
	 and varSet(@m.toAJAX, m.oProcess.oAJAX);
	or .T.;
	 and Vartype(m.AJAX) == 'O'; && {fr} pour awAppHost
	 and loClass(m.AJAX, 'awAJAX');
	 and varSet(@m.toAJAX, m.AJAX);
	or .F.
endfunc

* =============================================================
function wlAppHost && {fr} L'application FoxInCloud a bien démarré
lparameters toAppHost as awAppHost of awAppHost.fxp && @ {en} FoxInCloud Application Host Object

local loServer as awServer of awServer.prg && {fr} FoxInCloud / wConnect server object

toAppHost = ICase(;
	!wlWeb(@m.loServer),;
		m.toAppHost,;
	Vartype(m.loServer.oAppHost) == 'O',; && {fr} and loClass(m.loServer.oAppHost, 'awAppHost')
		m.loServer.oAppHost,;
	Vartype(m.awAppHost) == 'O',; && {fr} and loClass(m.awAppHost, 'awAppHost')
		m.awAppHost,;
		m.toAppHost;
	)

return loClass(m.toAppHost, 'awAppHost')

* =============================================================
function wlSession && {fr} Une session est ouverte pour l'utilisateur courant
lparameters oSession
return Vartype(m.Session) == 'O' AND loClass(m.Session, 'awSession') and varSet(@m.oSession, m.Session)
endfunc

* =============================================================
function wlAdapter && {fr} Fonctionnement depuis l'assistant d'apdaptation
return Lower(JustFname(Sys(16,0))) == Lower('awAdapterStart.app')
endfunc

* =============================================================
function wlAutomation && {fr} Fonctionnement en serveur d'automation
return InList(_VFP.StartMode;
	, 2; && {en} Visual FoxPro was started as an out-of-process .exe automation server
	, 3; && {en} Visual FoxPro was started as an in-process .dll automation server
	, 5; && {en} Visual FoxPro was started as an in-process .dll automation server for multithreaded use
	)
endfunc

* =============================================================
function wlFoxInCloud && {fr} Alias de wlFiC()
lparameters ;
  tlTrial; && @ [.F.] {fr} La version d'essai est installée
, tuVersion && @ [.null.] {fr} N° de la version installée
return wlFIC(@m.tlTrial, @m.tuVersion)
endfunc

* =============================================================
function wlFIC && {fr} Un package FoxInCloud est installé sur cet ordinateur
lparameters ;
  tlTrial; && @ [.F.] {fr} La version d'essai est installée
, tuVersion && @ [.null.] {fr} N° de la version installée
tlTrial = .F.
tuVersion = .null.

LOCAL lcPrg, lcApp, loVersion, llawVersion, lcawSupport, llResult

lcPrg = DOS_AW + 'aw.prg'
llResult = File(m.lcPrg)
IF NOT m.llResult

	lcApp = DOS_AW + 'aw.app'
	STORE File(m.lcApp) TO llResult, tlTrial
ENDIF

IF m.llResult
	TRY
		lcawSupport = 'awSupport.fxp' && {fr} évite une dépendance sur awSupport
		loVersion = Iif(m.tlTrial;
			, NewObject('awVersion', m.lcawSupport, m.lcApp);
			, NewObject('awVersion', m.lcawSupport);
			)
		tuVersion = m.loVersion.cawVersion
		RELEASE loVersion
		CLEAR CLASS awVersion
	CATCH
	ENDTRY
ENDIF

return m.llResult
endfunc

* =============================================================
function wlFICtrial && {fr} Un package FoxInCloud d'essai est installé sur cet ordinateur
lparameters tuVersion && @ [.null.] {fr} N° de la version installée
local llTrial
return wlFIC(@m.llTrial, @m.tuVersion) AND m.llTrial
endfunc

* =============================================================
function wlFICfull && {fr} Un package FoxInCloud complet est installé sur cet ordinateur
lparameters tuVersion && @ [.null.] {fr} N° de la version installée
local llTrial
return wlFIC(@m.llTrial, @m.tuVersion) AND NOT m.llTrial
endfunc

* =============================================================
function wcID && {fr} Identifiant d'un objet HTML selon convention FoxInCloud (alias de cawID)
lparameters ;
  toControl; && {fr} Contrôle
, tcSuffix && [''] {fr} suffixe éventuel
return cawID(m.toControl, m.tcSuffix)
endfunc

* =============================================================
function cawID && {fr} Identifiant d'un objet HTML selon convention FoxInCloud (alias de wcID)
lparameters ;
  toControl; && {fr} Contrôle
, tcSuffix && [''] {fr} suffixe éventuel

return Iif(Vartype(m.toControl) == 'O';
	, Lower(Chrtran(Sys(1272, m.toControl), '.', '-');
		+	Iif(Vartype(m.tcSuffix) == 'C' AND NOT Empty(m.tcSuffix);
			, '_' + Alltrim(m.tcSuffix);
			, '';
			);
		);
	, '';
	)
endfunc

* =============================================================
function cScriptJSfocus && {fr} Javascript pour mettre le focus sur un contrôle
lparameters toControl as awCbo of aw.vcx

if Vartype(m.toControl) == 'O'
	
	local lcID, lcFonction

	lcID = cawID(m.toControl, Iif(.F.;
		or m.toControl.BaseClass == 'Combobox' and Empty(m.toControl.Style);
		or m.toControl.BaseClass == 'Spinner';
		, 'txt';
		, '';
	))

	lcFonction = Chrtran(m.lcID, '-', '_') + '_focus'

&& {fr} http://ablogaboutcode.com/2011/06/14/how-javascript-loading-works-domcontentloaded-and-onload/

	return Textmerge([function <<m.lcFonction>>(){var o = $('<<m.lcID>>'); if(true &];
		+ [& !FoxInCloud.aReqsPend.length &];
		+ [& !FoxInCloud.focusEvent &];
		+ [& o &];
		+ [& typeof o.focus === 'function' &];
		+ [& true) o.focus();};<<m.lcFonction>>.defer();]) && {fr} removed self-executing function (function(){})(); && {fr} Prototype#defer(): Schedules the function to run as soon as the interpreter is idle
else
	return  ''
endif

&& {fr} erreur si exécuté dans un eval()
endfunc	

* =============================================================
function wLastKey && {fr} LastKey() en mode LAN ou Web

local loAJAX as awAJAX of awServer.prg

return ICase(;
	wlLAN(), Lastkey(),;
	wlAJAX(@m.loAJAX), m.loAJAX.nLastKey,;
	0;
	)

* =============================================================
function wGetColor && {fr} GetColor() _SANS RETOUR MODAL_ en mode LAN ou Web
&& _MODAL_ GetColor():
&& {en} - form method: use thisForm.wGetColor()
&& {en} - standalone procedure or function: NOT SUPPORTED
lparameters nDefaultColorNumber

LOCAL lnParm
lnParm = Pcount()

IF wlLAN()
	return ICase(;
		m.lnParm = 0, 	GetColor(),;
										GetColor(m.nDefaultColorNumber);
	)
ELSE
	
	return 0 && {fr} NOT SUPPORTED
ENDIF

* =============================================================
function wGetPict && {fr} GetPict() _SANS RETOUR MODAL_ en mode LAN ou Web
&& _MODAL_ GetPict():
&& {en} - form method: use thisForm.wGetPict()
&& {en} - standalone procedure or function: NOT SUPPORTED
lparameters cFileExtensions, cFileNameCaption, cOpenButtonCaption

LOCAL lnParm
lnParm = Pcount()

IF wlLAN()
	return ICase(;
		m.lnParm = 0, 	GetPict(),;
		m.lnParm = 1, 	GetPict(m.cFileExtensions),;
		m.lnParm = 2, 	GetPict(m.cFileExtensions, m.cFileNameCaption),;
										GetPict(m.cFileExtensions, m.cFileNameCaption, m.cOpenButtonCaption);
	)
ELSE

	return 0 && {fr} NOT SUPPORTED
ENDIF

* =============================================================
function wGetFile && {fr} GetFile() _SANS RETOUR MODAL_ en mode LAN ou Web
&& _MODAL_ GetFile():
&& {en} - form method: use thisForm.wGetFile()
&& {en} - standalone procedure or function: NOT SUPPORTED
lparameters cFileExtensions, cText, cOpenButtonCaption, nButtonType, cTitleBarCaption

LOCAL lnParm
lnParm = Pcount()

IF wlLAN()
	return ICase(;
		m.lnParm = 0, 	GetFile(),;
		m.lnParm = 1, 	GetFile(m.cFileExtensions),;
		m.lnParm = 2, 	GetFile(m.cFileExtensions, m.cText),;
		m.lnParm = 3, 	GetFile(m.cFileExtensions, m.cText, m.cOpenButtonCaption),;
		m.lnParm = 4, 	GetFile(m.cFileExtensions, m.cText, m.cOpenButtonCaption, m.nButtonType),;
										GetFile(m.cFileExtensions, m.cText, m.cOpenButtonCaption, m.nButtonType, m.cTitleBarCaption);
	)
ELSE

	return 0 && {fr} NOT SUPPORTED
ENDIF

* =============================================================
function wLocFile && {fr} LocFile() _SANS RETOUR MODAL_ en mode LAN ou Web
&& _MODAL_ LocFile():
&& {en} - form method: use thisForm.wLocFile()
&& {en} - standalone procedure or function: NOT SUPPORTED
lparameters cFileName, cFileExtensions, cFileNameCaption

LOCAL lnParm
lnParm = Pcount()

IF wlLAN()
	return ICase(;
		m.lnParm = 1, 	LocFile(m.cFileName),;
		m.lnParm = 2, 	LocFile(m.cFileName, m.cFileExtensions),;
										LocFile(m.cFileName, m.cFileExtensions, m.cFileNameCaption);
	)
ELSE

	return '' && {fr} NOT SUPPORTED
ENDIF

* =============================================================
function wPutFile && {fr} PutFile() _SANS RETOUR MODAL_ en mode LAN ou Web
&& _MODAL_ PutFile():
&& {en} - form method: use thisForm.wPutFile()
&& {en} - standalone procedure or function: NOT SUPPORTED
lparameters cCustomText, cFileName, cFileExtensions

LOCAL lnParm
lnParm = Pcount()

IF wlLAN()
	return ICase(;
		m.lnParm = 0, PutFile(),;
		m.lnParm = 1, PutFile(m.cCustomText),;
		m.lnParm = 2, PutFile(m.cCustomText, m.cFileName),;
									PutFile(m.cCustomText, m.cFileName, m.cFileExtensions);
	)
ELSE

	return 0 && {fr} NOT SUPPORTED
ENDIF

* =============================================================
function wInputBox && {fr} InputBox() _SANS RETOUR MODAL_ en mode LAN ou Web
&& _MODAL_ InputBox():
&& {en} - form method: use thisForm.wInputBox()
&& {en} - standalone procedure or function: NOT SUPPORTED
lparameters cInputPrompt, cDialogCaption, cDefaultValue, nTimeout, cTimeoutValue, cCancelValue

LOCAL lnParm
lnParm = Pcount()

IF wlLAN()
	return ICase(;
		m.lnParm = 1, InputBox(m.cInputPrompt),;
		m.lnParm = 2, InputBox(m.cInputPrompt, m.cDialogCaption),;
		m.lnParm = 3, InputBox(m.cInputPrompt, m.cDialogCaption, m.cDefaultValue),;
		m.lnParm = 4, InputBox(m.cInputPrompt, m.cDialogCaption, m.cDefaultValue, m.nTimeout),;
		m.lnParm = 5, InputBox(m.cInputPrompt, m.cDialogCaption, m.cDefaultValue, m.nTimeout, m.cTimeoutValue),;
									InputBox(m.cInputPrompt, m.cDialogCaption, m.cDefaultValue, m.nTimeout, m.cTimeoutValue, m.cCancelValue);
	)
ELSE

	return 0 && {fr} NOT SUPPORTED
ENDIF

* =============================================================
function wMessageBox && {en} MessageBox() _W/O MODAL return_ in LAN or Web mode {fr} MessageBox() _SANS RETOUR MODAL_ en mode LAN ou Web
&& _MODAL_ MessageBox():
&& {en} - form method: use thisForm.wInputBox()
&& {en} - standalone procedure or function: NOT SUPPORTED
lparameters ;
  eMessageText; && {fr} cf. VFP MessageBox()
, nDialogBoxType; && {fr} cf. VFP MessageBox()
, cTitleBarText; && {fr} cf. VFP MessageBox()
, nTimeout; && {fr} cf. VFP MessageBox()
, uParm5 && {fr} in case of abnormal # of parameters wMessageBox('', eMessageText[, nDialogBoxType[, cTitleBarText[, nTimeout]]])
eMessageText = Evl(m.eMessageText, '')

LOCAL lnParm as Integer;
, luTemp as Variant;
, loForm as awFrmMB OF aw.vcx;
, llResult as Boolean;
, loAJAX as awAJAX of awServer.prg


lnParm = Max(1, Pcount())

IF Empty(m.eMessageText) && {fr} abnormal call wMessageBox('', eMessageText[, nDialogBoxType[, cTitleBarText[, nTimeout]]])
	lnParm = Max(1, m.lnParm - 1)
	eMessageText = m.nDialogBoxType
	nDialogBoxType = m.cTitleBarText
	cTitleBarText = m.nTimeout
	nTimeout = m.uParm5
ENDIF

IF m.lnParm >= 3 AND Vartype(m.nDialogBoxType) == 'C' && {fr} dans les anciennes versions de VFP, nDialogBoxType et cTitleBarText peuvent être inversés
	luTemp = m.nDialogBoxType
	nDialogBoxType = m.cTitleBarText
	cTitleBarText = m.luTemp
ENDIF

if Vartype(m.cTitleBarText) == 'N' && {fr} wMessageBox(“Mon beau message avec TimeOut”, 64, 10000)
	nTimeout = m.cTitleBarText
	cTitleBarText = ''
	lnParm = 4
endif

IF wlLAN()

	return ICase(;
		m.lnParm = 1,	MessageBox(m.eMessageText),;
		m.lnParm = 2,	MessageBox(m.eMessageText, m.nDialogBoxType),;
		m.lnParm = 3,	MessageBox(m.eMessageText, m.nDialogBoxType, m.cTitleBarText),;
									MessageBox(m.eMessageText, m.nDialogBoxType, m.cTitleBarText, m.nTimeout);
		)

ELSE

	llResult = wlAJAX(@m.loAJAX) && {fr} requête en cours
	ASSERT m.llResult MESSAGE cAssertMsg(Textmerge(ICase(;
		cLangUser() = 'fr',	[Aucune requête en cours, MessageBox('<<m.eMessageText>>') est ignoré],; && copy-paste this line to add another language support
												[No pending user request, MessageBox('<<m.eMessageText>>') is ignored]; && Default: English
		)))
	IF m.llResult
		
		loForm = CreateObject([wMESSAGEBOX_CLASS]) && {fr} cf. #DEFINE wMESSAGEBOX_CLASS in awPublic.h / awPublic_Override.h
		llResult = loClass(m.loForm, 'awFrmMB')
		ASSERT m.llResult MESSAGE cAssertMsg(Textmerge(ICase(;
			cLangUser() = 'fr',	[Votre classe d'écran de "MessageBox" '<<m.loForm.Class>>' devrait dériver de 'aw.vcx!awFrmMB'],; && copy-paste this line to add another language support
													[Your "MessageBox" form class '<<m.loForm.Class>>' should derive from 'aw.vcx!awFrmMB']; && Default: English
			)))
		IF m.llResult

			IF ICase(;
				m.lnParm = 1,	m.loForm.Init(m.eMessageText),;
				m.lnParm = 2,	m.loForm.Init(m.eMessageText, m.nDialogBoxType),;
				m.lnParm = 3,	m.loForm.Init(m.eMessageText, m.nDialogBoxType, m.cTitleBarText),;
											m.loForm.Init(m.eMessageText, m.nDialogBoxType, m.cTitleBarText, m.nTimeout);
				)
		
				m.loAJAX.DialogAdd(m.loForm)
			ENDIF
		ENDIF
	ENDIF

	return 0 && {fr} pour rester en numérique
ENDIF

* =============================================================
function wWAIT && {fr} Instruction WAIT exécutée seulement en mode interactif
lparameters ;
  tcMsg AS String; && {fr} Message (cMessageText)
, tcClauses AS String; && [''] {fr} Clauses ([WINDOW [AT nRow, nColumn]] [NOWAIT] [TO VarName] [CLEAR | NOCLEAR] [TIMEOUT nSeconds])
, tcResult AS String && @ {fr} Erreur éventuelle

tcMsg = Evl(m.tcMsg, '')
tcClauses = Evl(m.tcClauses, '')

&& {fr} WAIT [cMessageText] [WINDOW [AT nRow, nColumn]] [NOWAIT] [TO VarName] [CLEAR | NOCLEAR] [TIMEOUT nSeconds]

LOCAL loRegExp AS abRegExp OF abTxt.prg;
, lcClauses AS String;
, loException AS Exception;
, llResult AS Boolean;
, luResult AS Variant && {fr} WAIT ... TO luResult

* {fr} Si l'application est en mode interactif
IF NOT InList(Application.StartMode, 2, 3, 5) && {fr} AUTOMATION SERVER - 2: out-of-process .exe; 3: in-process single thread .dll; in-process multi thread .dll

	llResult = Vartype(m.tcMsg) == 'C'
	IF m.llResult
	
		loRegExp = CreateObject('abRegExp')
		loRegExp.IgnoreCase = .T.
		WITH m.loRegExp AS abRegExp OF abTxt.prg
		
			* {fr} Si serveur Web en mode IDE, vérifier que les clauses comportent NOWAIT ou CLEAR pour éviter de le bloquer
			llResult = .F.;
			 OR NOT (wlWeb() AND Application.StartMode > 0); && {fr} Serveur FoxInCloud en mode exe (fichier)
			 OR .Setup('\bNOWA(I(T)?)?\b') AND .Test(m.tcClauses);
			 OR .Setup('\bCLEA(R)?\b') AND .Test(m.tcClauses)
			tcResult = Iif(m.llResult, '', Textmerge(ICase(;
				cLangUser() = 'fr',	[Paramètres de WAIT invalides ... msg: '<<m.tcMsg>>', clauses <<m.tcClauses>>],; && copy-paste this line to add another language support
														[Invalid WAIT parameters ... msg: '<<m.tcMsg>>', clauses <<m.tcClauses>>]; && Default: English
			)))
			
			* {fr} Si TO..., diriger le résultat vers luResult
			lcClauses = Iif(.Setup('\bTO\s+\w+') AND .Execute(m.tcClauses) = 1;
				, .Replace(m.tcClauses, 'TO luResult');
				, m.tcClauses)
		ENDWITH

		* {fr} Si tout va bien, exécuter l'instruction
		IF m.llResult AND wlLAN()
			
			TRY
				IF Empty(m.tcMsg);
				 AND NOT 'WINDOW' $ Upper(m.lcClauses) && {fr} contrib. Luc Gilot && {fr} à remplacer par (loRegExp.Setup('\bWINDO?W?\b') AND loRegExp.Test(m.tcClauses))
					WAIT &lcClauses
				ELSE
					WAIT m.tcMsg &lcClauses
				ENDIF
			CATCH TO loException
				llResult = .F.
				tcResult = cException(m.loException)
			ENDTRY
		ENDIF
	ELSE
		tcResult = Textmerge(ICase(;
			cLangUser() = 'fr',	[Le message <<cLitteral(m.tcMsg)>> est d'un type invalide],; && copy-paste this line to add another language support
													[Message <<cLitteral(m.tcMsg)>> is of an invalid type]; && Default: English
		))
	ENDIF

	ASSERT m.llResult MESSAGE cAssertMsg(m.tcResult)
ENDIF

return Evl(m.luResult, .null.)

* =============================================================
procedure wAddObject && {fr} Ajoute un objet à un conteneur s'il n'y existe pas déjà
&& 3 Feb. 14 - deprecated in favor of aw.vcx!aw*.AddObject()
lparameters ;
  toCont; && {fr} Conteneur auquel il faut ajouter un objet
, tcObject; && {fr} Nom de l'objet à ajouter
, tcClass; && {fr} Classe de l'objet à ajouter
, t01,t02,t03,t04,t05,t06,t07,t08,t09,t10,t11,t12,t13,t14,t15,t16,t17,t18,t19,t20 && @ {fr} paramètres à passer à l'Init() de l'objet

LOCAL llResult as Boolean;
, lnParm, lcParm, loObj, loAJAX as awAJAX

* {fr} Si le conteneur est valide
llResult = loCont(m.toCont)
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge(ICase(;
	cLangUser() = 'fr',	[Le premier paramètre (<<cLitteral(m.toCont)>>) doit être une référence à un objet conteneur],; && copy-paste this line to add another language support
											[First parameter (<<cLitteral(m.toCont)>>) should be a container object reference]; && Default: English
	)))
IF m.llResult

	* {fr} Si les paramètres sont corrects
	lnParm = Pcount() - 3
	llResult = Between(m.lnParm, 0, 20)
	ASSERT m.llResult MESSAGE cAssertMsg(Textmerge(ICase(;
		cLangUser() = 'fr',	[Pas assez ou trop de paramètres],; && copy-paste this line to add another language support
												[Not enough or too many parameters]))) && Default: English
	IF m.llResult
	
		lcParm = wcParms(m.lnParm)
	
		* {fr} Si l'objet existe déjà
		IF locObject(m.toCont, m.tcObject)

			* {fr} Si l'objet peut être initialisé
			loObj = Evaluate('m.toCont.' + m.tcObject)
			lcParm = Substr(m.lcParm, 2) && {fr} ôte la virgule initiale

			* ------------------------------
			llResult = m.loObj.Init(&lcParm)
			* ------------------------------

			llResult = lTrue(m.llResult)
			ASSERT m.llResult MESSAGE cAssertMsg(Textmerge(ICase(;
				cLangUser() = 'fr',	[Échec de l'initialisation de l'objet '<<m.tcObject>>' de classe '<<m.tcClass>>' ; parent: '<<m.toCont.Name>>'],; && copy-paste this line to add another language support
														[Could not initialise object '<<m.tcObject>>' of class '<<m.tcClass>>' in parent '<<m.toCont.Name>>']))) && Default: English
		ELSE

			lcParm = Iif(Lower(m.tcClass) == 'olecontrol';
				, Strtran(m.lcParm, '@m.t01', cLitteral(m.t01)); && {fr} VFP accepts OLEclass only as a literal!!
				, m.lcParm;
				)

			* {fr} Si l'objet peut être ajouté au parent
			* ------------------------------
			llResult = m.toCont.AddObject(m.tcObject, m.tcClass &lcParm);
			 AND locObject(m.toCont, m.tcObject)
			* ------------------------------
			ASSERT m.llResult MESSAGE cAssertMsg(Textmerge(ICase(;
				cLangUser() = 'fr',	[Échec de l'ajout de l'objet '<<m.tcObject>>' de classe '<<m.tcClass>>' au parent '<<m.toCont.Name>>'],; && copy-paste this line to add another language support
														[Could not add object '<<m.tcObject>>' of class '<<m.tcClass>>' to parent '<<m.toCont.Name>>']))) && Default: English
			loObj = Iif(m.llResult, Evaluate('m.toCont.' + m.tcObject), .null.)
		ENDIF
	ENDIF
ENDIF

IF m.llResult

	IF lProperty(m.toCont, 'wlContentDynamic') AND m.toCont.wlContentDynamic && {fr} Si wlContentDynamic, tout le HTML contenu est régénéré à chaque requête
		toCont.wlContentChanged = .T.
	ELSE
		llResult = NOT wlAJAX(@m.loAJAX) OR m.loAJAX.wAddObject(m.toCont, m.loObj) && {fr} AJAX : ajoute l'objet à la page HTML
	ENDIF
ENDIF

return m.llResult

* -----------------------------------------------
procedure wAddObject_Test && {fr} teste wAddObject()

LOCAL loTest AS abUnitTest OF abDev.prg, loCont
loTest = abUnitTest()
loCont = CreateObject('Form')

loTest.Test(.T., m.loCont, 'OLE', 'Olecontrol', 'Shell.Explorer.2') && {fr} Microsoft Internet Explorer
loTest.Assert('Shell.Explorer.2', m.loCont.OLE.OLEclass)

return m.loTest.Result()

* =============================================================
procedure wNewObject && {fr} Ajoute un objet à un conteneur s'il n'y existe pas déjà
&& 3 Feb. 14 - deprecated in favor of aw.vcx!aw*.NewObject()
lparameters ;
  toCont; && {fr} Conteneur auquel il faut ajouter un objet
, tcObject; && {en} Specifies the name used to reference the newly added class or object
, tcClass; && {en} Specifies the class or object from which the new class or object is added
, tcModule; && [''] {en} Specifies a Visual FoxPro class library (.vcx ) or a Visual FoxPro program (.prg, .mpr, .app, .exe, and so on) containing the class or object specified with tcClass; If tcModule is omitted, or is an empty string or the .null. value, Visual FoxPro searches for the class or object in the following order: Visual FoxPro base classes, User-defined class definitions in memory in the order they were loaded, Classes in the current program, Class libraries opened with SET CLASSLIB, Classes in procedure files opened with SET procedure, Classes in the Visual FoxPro program execution chain, The OLE registry if SET OLEOBJECT is ON.
, tcApplication; && [''] {en} Visual FoxPro application (.exe or .app) containing the .vcx visual class library you specify with cClassLibName; ignored if empty string or the .null. value, or if tcModule is omitted.
, t01,t02,t03,t04,t05,t06,t07,t08,t09,t10,t11,t12,t13,t14,t15,t16,t17,t18,t19,t20 && @ {fr} paramètres à passer à l'Init() de l'objet

tcModule = Evl(m.tcModule, '')
tcApplication = Evl(m.tcApplication, '')

LOCAL llResult as Boolean;
, lnParm, lcParm, loObj, loAJAX as awAJAX

* {fr} Si le conteneur est valide
llResult = loCont(m.toCont)
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge(ICase(;
		cLangUser() = 'fr',	[Le premier paramètre (<<cLitteral(m.toCont)>>) doit être une référence à un objet conteneur],; && copy-paste this line to add another language support
												[First parameter (<<cLitteral(m.toCont)>>) should be a container object reference]))) && Default: English
IF m.llResult

	* {fr} Si les paramètres sont corrects
	lnParm = Max(Pcount() - 5, 0)
	llResult = Between(m.lnParm, 0, 20)
	ASSERT m.llResult MESSAGE cAssertMsg(Textmerge(ICase(;
		cLangUser() = 'fr',	[Pas assez ou trop de paramètres],; && copy-paste this line to add another language support
												[Not enough or too many parameters]))) && Default: English
	IF m.llResult

		lcParm = wcParms(m.lnParm)
	
		* {fr} Si l'objet existe déjà
		IF locObject(m.toCont, m.tcObject)

			loObj = Evaluate('m.toCont.' + m.tcObject)
			lcParm = Substr(m.lcParm, 2) && {fr} ôte la virgule initiale

			* {fr} Si l'objet peut être initialisé
			* ------------------------------
			llResult = m.loObj.Init(&lcParm)
			* ------------------------------

			llResult = lTrue(m.llResult)
			ASSERT m.llResult MESSAGE cAssertMsg(Textmerge(ICase(;
				cLangUser() = 'fr',	[Échec de l'initialisation de l'objet '<<m.tcObject>>' de classe '<<m.tcClass>>' ; parent: '<<m.toCont.Name>>'],; && copy-paste this line to add another language support
														[Could not initialise object '<<m.tcObject>>' of class '<<m.tcClass>>' in parent '<<m.toCont.Name>>']))) && Default: English
		ELSE

			lcParm = Iif(Lower(m.tcClass) == 'olecontrol';
				, Strtran(m.lcParm, '@m.t01', cLitteral(m.t01)); && {fr} VFP accepts OLEclass only as a literal!!
				, m.lcParm;
				)

			* {fr} Si l'objet peut être ajouté au parent
			* ------------------------------
			llResult = m.toCont.NewObject(m.tcObject, m.tcClass, m.tcModule, m.tcApplication &lcParm);
 					AND locObject(m.toCont, m.tcObject)
			* ------------------------------

			ASSERT m.llResult MESSAGE cAssertMsg(Textmerge(ICase(;
				cLangUser() = 'fr',	[Échec de l'ajout de l'objet '<<m.tcObject>>' de classe '<<m.tcClass>>' au parent '<<m.toCont.Name>>'],; && copy-paste this line to add another language support
														[Could not add object '<<m.tcObject>>' of class '<<m.tcClass>>' to parent '<<m.toCont.Name>>']))) && Default: English
			loObj = Iif(m.llResult, Evaluate('m.toCont.' + m.tcObject), .null.)
		ENDIF
	ENDIF
ENDIF

IF m.llResult

	IF lProperty(m.toCont, 'wlContentDynamic') AND m.toCont.wlContentDynamic && {fr} Si wlContentDynamic, tout le HTML contenu est régénéré à chaque requête
		toCont.wlContentChanged = .T.
	ELSE
		llResult = NOT wlAJAX(@m.loAJAX) OR m.loAJAX.wAddObject(m.toCont, m.loObj) && {fr} AJAX : envoie l'ordre d'ajouter l'objet à la page HTML
	ENDIF
ENDIF

return m.llResult

* =============================================================
procedure wRemoveObject && {fr} Supprime un objet d'un conteneur s'il existe
&& 3 Feb. 14 - {en} deprecated in favor of aw.vcx!aw*.RemoveObject()
lparameters ;
  toCont AS awCnt OF aw.vcx,; && {fr} Conteneur d'où il faut retirer l'objet
	tcObject && {fr} Nom de l'objet à supprimer

LOCAL llResult, loAJAX as awAJAX of awServer.prg

* {fr} Si le conteneur est valide
llResult = loCont(m.toCont)
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge(ICase(;
		cLangUser() = 'fr',	[Le premier paramètre (<<cLitteral(m.toCont)>>) doit être une référence à un objet conteneur],; && copy-paste this line to add another language support
												[First parameter (<<cLitteral(m.toCont)>>) should be a container object reference]))) && Default: English
IF m.llResult

	* {fr} Si l'objet existe toujours dans le parent
	IF locObject(m.toCont, m.tcObject)

		* {fr} Si le conteneur est dynamique, indiquer que son contenu a changé && {fr} FoxInCloud régénère tout le HTML à chaque changement
		IF lProperty(m.toCont, 'wlContentDynamic') AND m.toCont.wlContentDynamic
			toCont.wlContentChanged = .T.
		ELSE
			= wlAJAX(@m.loAJAX) AND m.loAJAX.wRemoveObject(m.toCont, Evaluate('m.toCont.' + m.tcObject)) && {fr} AJAX: envoit l'ordre de retirer l'objet de la page HTML
		ENDIF

		* {fr} Ôter l'objet
		llResult = toCont.RemoveObject(m.tcObject)
	ENDIF
ENDIF

return m.llResult

* =============================================================
procedure wcPropSaveNotEdit as Boolean && (Web) {fr} Édite la liste de propriétés d'un objet à NE PAS sauvegarder (.wcPropSaveNot)
lparameters ;
  toObj; && {fr} Objet dont la propriété .wcPropSaveNot est à éditer
, tcProps; && {fr} Propriété(s) à ajouter | ôter de la liste
, tlRemove; && [.F.] {fr} .F. : ajouter à la liste, .T. : ôter de  la liste

return wcPropSaveEdit_(;
	  m.toObj;
	,@m.tcProps;
	, m.tlRemove;
	, 'wcPropSaveNot';
	)

endproc

* =============================================================
procedure wcPropSaveEdit as Boolean && (Web) {fr} Édite la liste de propriétés d'un objet à sauvegarder (.wcPropSave)
lparameters ;
  toObj; && {fr} Objet dont la propriété .wcPropSave est à éditer
, tcProps; && {fr} Propriété(s) à ajouter | ôter de la liste
, tlRemove; && [.F.] {fr} .F. : ajouter à la liste, .T. : ôter de  la liste

return wcPropSaveEdit_(;
	  m.toObj;
	,@m.tcProps;
	, m.tlRemove;
	, 'wcPropSave';
	)

endproc

* =============================================================
procedure wcPropSaveEdit_ as Boolean && (Web) {fr} Édite une des 2 listes de propriétés d'un objet à sauvegarder (.wcPropSave ou .wcPropSaveNot)
lparameters ;
  toObj; && {fr} Objet dont la propriété .wcPropSave est à éditer
, tcProps; && {fr} Propriété(s) à ajouter | ôter de la liste
, tlRemove; && [.F.] {fr} .F. : ajouter à la liste, .T. : ôter de  la liste
, tcPropSave; && {fr} Propriété de l'objet à modifier ('wcPropSave' ou 'wcPropSaveNot')

tlRemove = lTrue(m.tlRemove)

LOCAL llResult as Boolean; && {fr} mission accomplie
, laProp[1], lcProp, liProp; && {fr} propriétés indiquées
, laPropSave[1], lnPropSave, lcPropSave; && {fr} propriétés existantes

llResult = .T.;
 and Vartype(m.toObj) == 'O';
 and Vartype(m.tcProps) == 'C';
 and NOT Empty(m.tcProps);
 and Vartype(m.tcPropSave) == 'C';
 and InList(Lower(m.tcPropSave), Lower('wcPropSave'), Lower('wcPropSaveNot'));
 and .T.
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([Invalid parameters(s)]))
IF m.llResult

	* {fr} Si les propriétés indiquées sont valides
	llResult = ALines(laProp, m.tcProps, 1+4, ',', ';') > 0 && trim
	ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([Invalid Properties list '<<m.tcProps>>']))
	IF m.llResult
	
		* {fr} Tabuler la liste existante
		IF .T.;
		 and lProperty(m.toObj, m.tcPropSave);
		 and VarStore(@m.lcPropSave, GetPem(m.toObj, m.tcPropSave));
		 and ga_Type_IsChar(m.lcPropSave, .T.)
			lnPropSave = ALines(laPropSave, m.lcPropSave, 1+4, ',', ';') && {fr} trim
		ELSE
			addProperty(m.toObj, m.tcPropSave, '')
			lnPropSave = 0
		ENDIF
	
		* {fr} Pour chaque propriété indiquée
		FOR EACH lcProp IN laProp
			
				liProp = Ascan(laPropSave, m.lcProp, 1, -1, 1, 7) && 1+2+4
				
				do case
				case m.tlRemove and m.liProp > 0 && {fr} suppression
						lnPropSave = m.lnPropSave - Adel(laPropSave, m.liProp)
				case !m.tlRemove and Empty(m.liProp) && {fr} ajout
						lnPropSave = m.lnPropSave + 1
						DIMENSION laPropSave[m.lnPropSave]
						laPropSave[m.lnPropSave] = m.lcProp
				endcase

&& 2016-05-27 thn -- {FiC V 2.21.1-beta.6} {en} 
*!*				* {fr} Si la propriété existe dans l'objet
*!*				IF lProperty(m.toObj, m.lcProp)
*!*				ELSE
*!*					llResult = .F. && {fr} important de laisser ainsi car une fois que llResult = .F., ne doit plus bouger
*!*				ENDIF
		ENDFOR
		
		* {fr} Remplacer les propriétés à sauvegarder
		WITH m.toObj as awTxt of aw.vcx
			
			lcPropSave = ''
			IF m.lnPropSave > 0
				DIMENSION laPropSave[m.lnPropSave]
				FOR EACH lcProp IN m.laPropSave
					lcPropSave = m.lcPropSave + ', ' + m.lcProp
				ENDFOR
			ENDIF
			store Ltrim(Substr(m.lcPropSave, 2)) to ('.' + m.tcPropSave)
		ENDWITH
	ENDIF
ENDIF

return m.llResult
endproc

* =============================================================
function wActiveForm && {en} _Screen.ActiveForm in both LAN and Web modes

local loAJAX as awAJAX of awServer.prg
	
return ICase(;
	wlLAN() AND Type('_Screen.ActiveForm') == 'O',; && {en} Vartype(_screen.ActiveForm) can give an error "ActiveForm is not an object"
		_Screen.ActiveForm,;
	wlAJAX(@m.loAJAX),;
		m.loAJAX.ActiveForm,; && {en} see awAJAX.ActiveForm_Access() (full licensed user)
		.null.; && {en} we don't know ...
		)

* =============================================================
function wActiveControl && {en} _Screen.ActiveControl in both LAN and Web modes

LOCAL loForm AS awFrm OF aw.vcx, loAJAX as awAJAX of awServer.prg

DO CASE

CASE wlLAN()
	loForm = wActiveForm()
	IF Vartype(m.loForm) == 'O' AND Type('m.loForm.ActiveControl') == 'O'
		return m.loForm.ActiveControl
	ENDIF

CASE wlAJAX(@m.loAJAX)

	return m.loAJAX.oCntl

OTHERWISE

	return .null.

ENDCASE

* =============================================================
function wlUserAnonymous && {fr} L'utilisateur courant est anonyme
local loProcess as awProcess of awServer.prg && {en} FoxInCloud request processing object
return Iif(wlProcess(@m.loProcess);
	, luEqual(m.loProcess.wUserAnonymous, Iif(m.loProcess.wlUserTemp, m.loProcess.wUserTemp, m.loProcess.wUser));
	, .null.; && {en} we don't know ...
	)

* =============================================================
function wcImageURL && {fr} Image URL
lparameters tcImage && {fr} Image Physical Address

local loAJAX as awAJAX of awServer.prg

return Iif(wlAJAX(@m.loAJAX);
	, m.loAJAX.cImageURL(Trim(m.tcImage)); && {fr} Padr(, Lenc(m.tcImage))
	, m.tcImage;
	)

* =============================================================
function wcIISversion && {fr} Version d'IIS selon la version de Windows
lparameters ;
  tlIISprefix; && [.F.] {fr} Ajouter le préfixe 'IIS' (pour webServer.vcx!*)
, tlMajor && [.F.] {fr} Version majeure seulement

LOCAL lnMajor, lnMinor, lcResult

= wcOSversion(@m.lnMajor, @m.lnMinor)

lcResult = ICase(;
	m.lnMajor = 10 AND m.lnMinor = 0, '10.0',; && Windows 10 && {fr} http://www.iis.net/learn/get-started/whats-new-in-iis-10/wildcard-host-header-support
	m.lnMajor = 06 AND m.lnMinor = 3,  '8.5',; && Windows 8.1, Windows Server 2012 R2
	m.lnMajor = 06 AND m.lnMinor = 2,  '8.0',; && Windows 8, Windows Server 2012
	m.lnMajor = 06 AND m.lnMinor = 1,  '7.5',; && Windows 7, Windows Server 2008 R2
	m.lnMajor = 06 AND m.lnMinor = 0,  '7.0',; && Windows Vista, Windows Server 2008
	m.lnMajor = 05 AND m.lnMinor = 2,  '6.0',; && Windows XP 64-Bit Edition, Windows Server 2003, Windows Server 2003 R2
	m.lnMajor = 05 AND m.lnMinor = 1,  '5.1',; && Windows XP Professional
	m.lnMajor = 05 AND m.lnMinor = 0,  '5.0',; && Windows 2000
	m.lnMajor < 4, '4.0',; && Windows NT 4 Option pack {fr} (on oublie les précédents)
	'?.?';
	)

return Iif(NOT Empty(m.lcResult) AND (lTrue(m.tlIISprefix));
	, 'IIS';
	, '';
	) + Iif(lTrue(m.tlMajor);
		, JustStem(m.lcResult);
		, m.lcResult;
		)

* =============================================================
function wcWindowsEdition && {fr} Edition de Windows en clair
lparameters tlWindowsNo && [.F.] {en} omit the leading word 'Windows'

local lnMajor, lnMinor, llWorkStation

= wcOSversion(@m.lnMajor, @m.lnMinor, @m.llWorkStation)

&& {fr} http://www.foxite.com/archives/0000420530.htm
&& {fr} https://msdn.microsoft.com/en-us/library/windows/desktop/ms724832%28v=vs.85%29.aspx
&& {fr} http://fox.wikis.com/wc.dll?Wiki~CurrentVersion
&& {fr} http://fox.wikis.com/wc.dll?Wiki~VFPFunctionOS

return Iif(lTrue(m.tlWindowsNo), '', 'Windows ') + ICase(;
	m.lnMajor = 10 AND m.lnMinor = 0,;
			'10',;
	m.lnMajor = 6 AND m.lnMinor = 3,;
		Iif(m.llWorkStation;
		, '8.1';
		, 'Server 2012 R2';
		),;
	m.lnMajor = 6 AND m.lnMinor = 2,;
		Iif(m.llWorkStation;
		, '8.0';
		, 'Server 2012';
		),;
	m.lnMajor = 6 AND m.lnMinor = 1,;
		Iif(m.llWorkStation;
		, '7';
		, 'Server 2008 R2';
		),;
	m.lnMajor = 6 AND m.lnMinor = 0,;
		Iif(m.llWorkStation;
		, 'Vista';
		, 'Server 2008';
		),;
	m.lnMajor = 5 AND m.lnMinor = 2,;
		Iif(m.llWorkStation;
		, 'XP 64-Bit Edition';
		, 'Server 2003/2003 R2';
		),;
	m.lnMajor = 5 AND m.lnMinor = 1,;
			'XP',;
	m.lnMajor = 5 AND m.lnMinor = 0,;
		Iif(m.llWorkStation;
		, '2000';
		, '2000 server';
		),;
	m.lnMajor = 4,;
		Iif(m.llWorkStation;
		, '95, 98, Millenium';
		, 'NT server';
		),;
	m.lnMajor = 3,;
			'3.xx',;
	m.lnMajor = 2,;
			'2.xx',;
	m.lnMajor = 1,;
			'1.xx',;
			'Version unknown';
	)

* =============================================================
function wcOSversion && {fr} Version de Windows détaillée
lparameters lnMajor, lnMinor, llWorkStation && @

LOCAL lcResult

lcResult = GetWordNum(Os(1), 2) && {fr} Windows Full version, e.g. "Windows 6.01"
lnMajor = Int(Val(GetWordNum(m.lcResult, 1, '.'))) && {fr} Windows Major version
lnMinor = Int(Val(GetWordNum(m.lcResult, 2, '.'))) && {fr} Windows Minor version

llWorkStation = Os(11) = '1'

return m.lcResult

* =============================================================
function wcVFPlanguage

local result

result = Cast(Version(3) as I)

return ICase(;
	m.result = 00, 'English',;
	m.result = 07, 'Russian',;
	m.result = 33, 'French',;
	m.result = 34, 'Spanish',;
	m.result = 39, 'Czech',;
	InList(m.result, 48, 49), 'German',; && 2014-04-11 - Uwe Haberman
	m.result = 55, 'Korean',;
	m.result = 86, 'Simplified Chinese',;
	m.result = 88, 'Traditional Chinese',;
	Version(3) + ' is unknown';
	)

* =============================================================
function wcParms && {fr} Chaîne de paramètres standard pour appel délégué d'une procédure, fonction ou méthode
lparameters ;
  tnParm AS Number; && {fr} Nombre de paramètres
, tlWith AS Boolean; && {fr} Paramètres pour DO ... WITH ... (passés par référence par défaut)
, t01,t02,t03,t04,t05,t06,t07,t08,t09,t10,t11,t12,t13,t14,t15,t16,t17,t18,t19,t20 && [N/A] {fr} nom corrigés des paramètres

tnParm = Iif(Vartype(m.tnParm) == 'N', Int(m.tnParm), 0)

IF m.tnParm > 0

	LOCAL lcResult as String;
	, lcAt as String;
	, lnParm as Integer;
	, liParm as Integer

	lcAt = Iif(m.tlWith, '', '@')
	lnParm = Max(Pcount() - 2, 0)
	lcResult = ''
	FOR liParm = 1 TO m.tnParm
		lcResult = m.lcResult;
			+ ',' + m.lcAt + 'm.';
			+ Iif(m.liParm <= m.lnParm;
				, Evaluate('m.t' + Padl(m.liParm, 2, '0'));
				, 't' + Padl(m.liParm, 2, '0');
				)
	ENDFOR
	return Iif(m.tlWith and !Empty(m.lcResult);
		, 'WITH ' + Substr(m.lcResult, 2);
		, m.lcResult;
		)
else
	return ''
endif

* =============================================================
procedure wReport && {en} REPORT FORM in Web and LAN modes
lparameters ;
  tParm1 AS Character; && {fr} Parameter 1 TBD
, tParm2 AS Character; && {fr} Parameter 2 TBD, and so on
, tParmN AS Character; && {fr} Parameter n TBD
, tcResult AS Character; && @ [''] {en} Returned result: Address of the PDF file generated or error if any
, tcPDFgen AS Character && [Whatever we find first] {en} PDF generator to be used (useful only if several generators are installed)

LOCAL lcReportForm, loResult AS Exception, llResult

IF wlLAN() && {fr} LAN mode, just execute REPORT FORM

	lcReportForm = Textmerge([REPORT FORM <<m.tParm1>>  <<m.tParm2>>  <<m.tParmN>>])
	TRY
		&lcReportForm
		llResult = .T.
	CATCH TO loResult
		tcResult = cException(m.loResult)
	ENDTRY
	
ELSE && {fr} Web mode

	tcPDFgen = Alltrim(Evl(m.tcPDFgen, .null.)) && .null. to work around Set("Exact")

	tcPDFgen = ICase(;
		InList(Lower(m.tcPDFgen), Lower('xFRX'), Lower('FRX2Any'), Lower('FoxyPreviewer')) AND (File(m.tcPDFgen + '.fxp') OR File(m.tcPDFgen + '.app')),;
			m.tcPDFgen,;
		File('xFRX.fxp') OR File('xFRX.app'),;
			'xFRX',;
		File('FRX2Any.fxp') OR File('FRX2Any.app'),; && /!\ don't know exactly how we can detect FRX2Any is installed
			'FRX2Any',;
		File('FoxyPreviewer.fxp') OR File('FoxyPreviewer.app'),;
			'FoxyPreviewer',;
			.null.;
		)
	
	IF IsNull(m.tcPDFgen)

		tcResult = Textmerge([<<Proper(Program())>>() - ] + ICase(;
			cLangUser() = 'fr',	[Aucun générateur de PDF n'a été trouvé],; && copy-paste this line to add another language support
													[No valid PDF generator could be found]; && Default: English
			))
	ELSE
		
		llResult = wReport_&tcPDFgen.(;
			  m.tParm1;
			, m.tParm2;
			, m.tParmN;
			, @m.tcResult;
			)
	ENDIF
ENDIF
	
return m.llResult

* ---------------------------------------
procedure wReport_xFRX && {en} REPORT FORM in Web mode using xFRX
lparameters ;
  tParm1 AS Character; && {fr} Parameter 1 TBD
, tParm2 AS Character; && {fr} Parameter 2 TBD, and so on
, tParmN AS Character; && {fr} Parameter n TBD
, tcResult AS Character && @ [''] {en} Returned result: Address of the PDF file generated or error if any

&& /!\ WIP - Code to be defined

* ---------------------------------------
procedure wReport_FRX2Any && {en} REPORT FORM in Web mode using FRX2ANY
lparameters ;
  tParm1 AS Character; && {fr} Parameter 1 TBD
, tParm2 AS Character; && {fr} Parameter 2 TBD, and so on
, tParmN AS Character; && {fr} Parameter n TBD
, tcResult AS Character && @ [''] {en} Returned result: Address of the PDF file generated or error if any

&& /!\ WIP - Code to be defined

* ---------------------------------------
procedure wReport_FoxyPreviewer && {en} REPORT FORM in Web mode using FoxyPreviewer
lparameters ;
  tParm1 AS Character; && {fr} Parameter 1 TBD
, tParm2 AS Character; && {fr} Parameter 2 TBD, and so on
, tParmN AS Character; && {fr} Parameter n TBD
, tcResult AS Character && @ [''] {en} Returned result: Address of the PDF file generated or error if any

&& /!\ WIP - Code to be defined

* =============================================================
procedure wForm && {en} DO FORM (.scx or class) in Web and LAN modes from an independent procedure such as an 'ON SELECTION' menu snippet {fr} DO FORM (.scx ou classe) en modes Web ou desktop depuis une procédure indépendante comme une option de menu 'ON SELECTION'
&& {en} In Web mode, Form is displayed in a window within current HTML page,
&& {en}   to display Form in a full HTML page, use awPublic.prg!wFormMaster() instead
&& {fr} En mode Web, le formulaire est affiché dans une fenêtre à l'intérieur de la page courante
&& {fr}   pour l'afficher dans une pleine page Web, utiliser awPublic.prg!wFormMaster()
lparameters ;
  tcForm AS String; && {en} eg 'Form.scx' or form class
, tlModal AS Boolean; && [.F.] {en} render as a modal form (returned value not supported)
, t01,t02,t03,t04,t05,t06,t07,t08,t09,t10,t11,t12,t13,t14,t15,t16,t17,t18,t19,t20 && @ {en} parameters to be passed to Form.Init()

LOCAL lcParms as String

lcParms = wcParms(Pcount() - 2)

return wFormShow(wFormNoShow(m.tcForm, @m.tlModal &lcParms), m.tlModal)

* =============================================================
procedure wFormShow && {en} Shows form in Web and LAN modes after wFormNoShow() {fr} Affiche un formulaire en modes Web ou desktop après wFormNoShow()
&& {en} In Web mode, Form is displayed in a window within current HTML page,
&& {en}   to display Form in a full HTML page, use awPublic.prg!wFormMaster() instead
&& {fr} En mode Web, le formulaire est affiché dans une fenêtre à l'intérieur de la page courante
&& {fr}   pour l'afficher dans une pleine page Web, utiliser awPublic.prg!wFormMaster()
lparameters ;
  loForm as awFrm of aw.vcx;
, tlModal AS Boolean; && [.F.] {en} render as a modal form (returned value not supported)

LOCAL success as Boolean;
, loAJAX as awAJAX of awServer.prg; && {en} FoxInCloud AJAX request processing Object

do case

case !loClass(m.loForm, 'awFrm')
	return .f.

case wlLAN() && {fr} desktop mode

	return Iif(lTrue(m.tlModal);
		, m.loForm.Show(1);
		, m.loForm.Show();
		)

case !wlAJAX(@m.loAJAX)

	assert .F. message cAssertMsg(Textmerge(ICase(;
		cLangUser() = 'fr',	[En mode Web, cette fonction ne peut être utilisée que pendant une requête, après que l'application a démarré],; && copy-paste this line to add another language support
												[In web mode, this function can only be called within a request, after application has started]; && Default: English
		)))
	return .f.

otherwise

	return m.loAJAX.dialogAdd(m.loForm) && {fr} a ses assert

endcase

* =============================================================
procedure wFormNoShow as awFrm of aw.vcx && {en} DO FORM ... NOSHOW (.scx or class) in Web and LAN modes from an independent procedure such as an 'ON SELECTION' menu snippet {fr} DO FORM ... NOSHOW (.scx ou classe) en modes Web ou desktop depuis une procédure indépendante comme une option de menu 'ON SELECTION'
&& {en} In Web mode, Form is displayed in a window within current HTML page,
&& {en}   to display Form in a full HTML page, use awPublic.prg!wFormMaster() instead
&& {fr} En mode Web, le formulaire est affiché dans une fenêtre à l'intérieur de la page courante
&& {fr}   pour l'afficher dans une pleine page Web, utiliser awPublic.prg!wFormMaster()
lparameters ;
  tcForm AS String; && {en} eg 'Form.scx' or form class
, tlModal AS Boolean; && [.F.] {en} render as a modal form (returned value not supported)
, t01,t02,t03,t04,t05,t06,t07,t08,t09,t10,t11,t12,t13,t14,t15,t16,t17,t18,t19,t20 && @ {en} parameters to be passed to Form.Init()

tlModal = lTrue(m.tlModal)

LOCAL loForm as awFrm of aw.vcx;
, success as Boolean;
, llSCX as Boolean;
, lnParms as Integer;
, lcParms as String;
, loProcess as awProcess of awServer.prg; && {en} FoxInCloud request processing object
, loSession as awSession of awServer.prg; && {fr} FoxInCloud Session Object
, loAppHost as awAppHost of awAppHost.fxp; && {fr} FoxInCloud Application Host Object
, lcForm as String

lnParms = Pcount() - 2
llSCX = Vartype(m.tcForm) == 'C' and Lower(JustExt(m.tcForm)) == 'scx'

do case

case wlLAN() && {fr} desktop mode

	if m.llSCX && .scx
		lcParms = wcParms(m.lnParms, .T.)
		do form (m.tcForm) name loForm &lcParms noshow
	else
		lcParms = wcParms(m.lnParms)
		loForm = CreateObject(m.tcForm &lcParms)
		m.loForm.Hide
	endif
	success = .T.

case !(wlProcess(@m.loProcess) and wlSession(@m.loSession) and wlAppHost(@m.loAppHost))

	assert .f. message cAssertMsg(Textmerge(ICase(;
		cLangUser() = 'fr',	[En mode Web, cette fonction ne peut être utilisée que pendant une requête, après que l'application a démarré],; && copy-paste this line to add another language support
												[In web mode, this function can only be called within a request, after application has started]; && Default: English
		)))

case .T.;
 and varSet(@m.lcForm, m.loSession.getSessionVar('cForm'));
 and !Empty(m.lcForm);
 and varSet(@m.loForm, m.loAppHost.oFormOfName(m.lcForm));
 and !Vartype(m.loForm) == 'O';
 and m.loProcess.Warning(Textmerge(ICase(;
			cLangUser() = 'fr',	[Le formulaire appelant '<<m.lcForm>>' est introuvable dans l'application],; && copy-paste this line to add another language support
													[Calling form '<<m.lcForm>>' can't be found in application]; && Default: English
			)))

otherwise
	
	lcParms = wcParms(m.lnParms)
	loForm = m.loAppHost.oForm(m.tcForm, m.loForm, m.tlModal &lcParms)

	success = .F.;
 		or Vartype(m.loForm) == 'O';
 		or .T.;
		 and ParmsLit(@m.lcParms &lcParms);
		 and m.loProcess.Warning(c2Words(Textmerge(ICase(;
				cLangUser() = 'fr',	[Le formulaire '<<m.tcForm>>' ne peut être instancié avec les paramètres <<m.lcParms>>],; && copy-paste this line to add another language support
														[Form '<<m.tcForm>>' can't be instantiated with parameters <<m.lcParms>>]; && Default: English
				)), ': ', m.loAppHost.cResult));
		 and .F.;
 		or .F.

endcase

return Iif(m.success;
	, m.loForm;
	, .null.;
	)
endproc

* =============================================================
function wNavigate(URL, newWindow)

local oAJAX as awAJAX of awServer.prg

if wlAJAX(@m.oAJAX)

	m.oAJAX.lURLnextNewWindow = m.oAJAX.lURLnextNewWindow or lTrue(m.newWindow)
	return m.oAJAX.Navigate(m.URL)

else
	return ShellExecute(; && {en} If the function succeeds, it returns a value greater than 32
	      .null.; && {en} integer A handle to the parent window used for displaying a UI or error messages. This value can be NULL if the operation is not associated with a window.
	    , 'open'; && {fr} cOperation string
	    	; && {en} edit: Launches an editor and opens the document for editing. If lpFile is not a document file, the function will fail.
				; && {en} explore: Explores a folder specified by lpFile.
				; && {en} find: Initiates a search beginning in the directory specified by lpDirectory.
				; && {en} open: Opens the item specified by the lpFile parameter. The item can be a file or folder.
				; && {en} print: Prints the file specified by lpFile. If lpFile is not a document file, the function fails.
				; && {en} NULL: The default verb is used, if available. If not, the "open" verb is used. If neither verb is available, the system uses the first verb listed in the registry.
	    , m.URL; && {en} string cFileName file or object on which to execute the specified verb
	    , ''; && {en} string cParameters parameters to be passed to the application
	    , ''; && {en} string cDirectory default (working) directory for the action. If this value is NULL, the current working directory is used
	    , SW_SHOWDEFAULT; && {en} integer nShowWindow how an application is to be displayed when it is opened (see abDev.h)
	   ) > 32

endif
endfunc

* =============================================================
procedure wBackHome
local oAJAX as awAJAX of awServer.prg
return wlAJAX(@m.oAJAX) and m.oAJAX.BackHome()
endproc

* =============================================================
function wFormMaster as awFrm of aw.vcx && {en} DO FORM in Web and LAN modes from an independent procedure such as an 'ON SELECTION' menu snippet
&& {en} In Web mode, displays Form in a full HTML page, not in a window within current HTML page
&& {en} To display Form in a window within current HTML page, use awPublic.prg!wForm() instead
lparameters ;
  tcForm AS Character; && 'Form.scx'
, t01,t02,t03,t04,t05,t06,t07,t08,t09,t10,t11,t12,t13,t14,t15,t16,t17,t18,t19,t20 && @ {fr} paramètres to be passed to Form.Init()

LOCAL luForm as awFrm of aw.vcx; && {en} LAN: reference to form, Web: success
, llResult as Boolean;
, lcParms as String;
, loProcess as awProcess of awServer.prg; && {en} FoxInCloud request processing object
, loAJAX as awAJAX of awServer.prg; && {en} FoxInCloud AJAX request processing Object

luForm = .null.

llResult = Vartype(m.tcForm) == 'C' and File(m.tcForm) and Lower(JustExt(m.tcForm)) == 'scx'
assert m.llResult message cAssertMsg(Textmerge(ICase(;
	cLangUser() = 'fr',	[Le formulaire <<cL(m.tcForm)>> est invalide ou introuvable],; && copy-paste this line to add another language support
											[Form <<cL(m.tcForm)>> is either invalid or can't be found]; && Default: English
	)))
if m.llResult

	IF wlLAN() && {fr} desktop mode

			lcParms = wcParms(Pcount() - 1, .T.)
			DO FORM (m.tcForm) name luForm &lcParms
		
	ELSE && {fr} web mode

		luForm = wlProcess(@m.loProcess) and wlAJAX(@m.loAJAX)
		ASSERT m.luForm MESSAGE cAssertMsg(Textmerge(ICase(;
			cLangUser() = 'fr',	[En mode Web, cette fonction ne peut être utilisée que pendant une requête],; && copy-paste this line to add another language support
													[In web mode, this function can only be called within a request]; && Default: English
			)))
		IF m.luForm
		
			lcParms = wcParms(Pcount() - 1)

			luForm = .F.;
				or m.loAJAX.Navigate(m.tcForm &lcParms);
				or m.loAJAX.Navigate(Textmerge([wFormStandardPage.<<m.loProcess.cScriptMap>>?awForm=<<m.tcForm>>]) &lcParms)

			= !m.luForm and ParmsLit(@m.lcParms &lcParms) and m.loProcess.Warning(Textmerge(ICase(;
				cLangUser() = 'fr',	[Le formulaire '<<m.tcForm>>' ne peut être affiché avec les paramètres <<m.lcParms>>],; && copy-paste this line to add another language support
														[Form '<<m.tcForm>>' can't be displayed with parameters <<m.lcParms>>]; && Default: English
				)))
		endif
	endif
endif

return m.luForm
endfunc

* ---------------------------------------
function wMenu_cDoc && {fr} wMenu() documentation
lparameters cLangUser
cLangUser = Evl(m.cLangUser, cLangUser())

local result as String

do case

case .F. && {fr} m.cLangUser = 'fr' && copy-paste this block to add another language support

	text to result noshow && ===================================================== version française à faire

	endtext && =====================================================

otherwise && Default: English

	text to m.result noshow && =====================================================

To adapt any menu command or function to LAN (desktop) mode and Web mode, pass it as a character string to ''wMenu()'';
(FoxInCloud Adaptation Assistant adapts all your menu instructions that way)

<code lang="vfp">
DEFI POPU myPopup MARGIN	RELA SHADOW  COLOR  W+/B* && {fr} command before adaptation
wMenu('DEFI POPU myPopup MARGIN	RELA SHADOW  COLOR  W+/B* ') && {fr} command after adaptation
&& {fr} note: wMenu() expands standard abbreviated Visual FoxPro keywords and parses any number of spaces or tabs around clauses
</code>

Except ''ON SELECTION'' commands and ''SKIP FOR'' expressions, expressions inside clauses must be expressed as literals;
To convert expressions to literals, simply place your instruction in ''Textmerge()'' and enclose expressions within ''"<<>>"''

<code lang="vfp">
lcPrompt = "Display contents of myFile"
DEFINE BAR 2 OF myPopup  PROMPT m.lcPrompt SKIP FOR !FILE("myFile.ext") && {fr} command before adaptation
wMenu(Textmerge('DEFINE BAR 2 OF myPopup  PROMPT "<<m.lcPrompt>>" SKIP FOR !FILE("myFile.ext")')) && {fr} command after adaptation
</code>

To make it even more simple, you can use the FoxInCloud ''cLitteral()'' function (aliased as ''cL'');
''cLitteral()'' [alias cL()] supports expressions of any type:

<code lang="vfp">
liBar = 2
lcPrompt = "Display contents of myFile"
DEFINE BAR m.liBar OF myPopup  PROMPT m.lcPrompt SKIP FOR !FILE("myFile.ext") && {fr} command before adaptation
wMenu(Textmerge('DEFINE BAR <<cL(m.liBar)>> OF myPopup  PROMPT <<cL(m.lcPrompt)>> SKIP FOR !FILE("myFile.ext")')) && {fr} command after adaptation
</code>


To control whether menu command execution is OK, you can chain your wMenu() command calls with ''.AND.'';
If any error occurs, execution chain will stop on the offending instruction, and the second parameter passed by reference will hold the error message:

<code lang="vfp">
local success, result
success = .T.;
	and wMenu('DEFI POPU myPopup MARGIN RELATIVE SHADOW COLOR  W+/B*', @m.result);
	and wMenu('ON SELECTION BAR 2 OF myPopup loMyForm.myMethod(m.myValue)', @m.result)
assert m.success message m.result
if m.success
	...
endif
</code>
	
Just before executing ACTIVATE commands such as:
<code lang="vfp">
wMenu('ACTIVATE MENU|POPUP ...', @m.result)
wMenu('ON PAD|BAR ... ACTIVATE MENU|POPUP xxx', @m.result)
</code>

for a MENU or POPUP having ''SKIP FOR'' and/or ''ON SELECTION'' clauses relying on variables, e.g.
<code lang="vfp">
wMenu('ON SELECTION BAR 2 OF myPopup loMyForm.myMethod(m.myValue)', @m.result);
wMenu('DEFINE PAD|BAR ... SKIP FOR myFunction(m.myValue)', @m.result)
</code>
(keywords such as ''this'' and ''thisform'' can't be used in ON SELECTION and SKIP FOR clauses as they execute outside of the form's context)

... Make sure to pass by reference an object as second parameter [@m.result], with properties holding any variable required for ''SKIP FOR'' and ''ON SELECTION'' clauses

<code lang="vfp">
local success, result
success = .T.;
	and wMenu('DEFI POPU myPopup MARGIN RELATIVE SHADOW COLOR  W+/B*', @m.result);
	and wMenu('DEFINE BAR 2 OF myPopup PROMPT "xx" SKIP FOR m.myBoolean', @m.result);
	and wMenu('ON SELECTION BAR 2 OF myPopup loMyForm.myMethod(m.myValue)', @m.result);
	;
	and varSet(@m.result, CreateObject('Empty')); && {fr} you create an object which defines the parameters that are required for your ON SELECTION commands and SKIP FOR expressions
	and AddProperty(m.result, 'loMyForm', thisForm);
	and AddProperty(m.result, 'myValue', m.myValue);
	and AddProperty(m.result, 'myBoolean', m.myBoolean);
	and wMenu('ACTIVATE POPUP myPopup ... NOWAIT', @m.result) && {fr} m.result contains: - on call, the 'parameter object' - on return, error message if any, else .null.
assert m.success message m.result
</code>

Please note that, for parameters of type Object, ONLY references to form or form members are supported.
e.g. if you need a reference to an object, make sure that this object is added to any container within the form, or the form itself:

<code lang="vfp">
local loMyObject, success, result
thisForm.AddObject('oObject', 'myCustom', InitParm)
loMyObject = thisForm.oObject
success = .T.;
	and wMenu('DEFI POPU myPopup MARGIN RELATIVE SHADOW COLOR  W+/B*', @m.result);
	and wMenu('ON SELECTION BAR 2 OF myPopup loMyObject.myMethod(m.myValue)', @m.result);
	and varSet(@m.result, CreateObject('Empty')); && {fr} you create an object which defines the parameters that are required for your ON SELECTION commands and SKIP FOR expressions
	and AddProperty(m.result, 'loMyObject', m.loMyObject); && {fr} loMyObject is needed to evaluate some SKIP FOR expression or execute some ON SELECTION command
	and AddProperty(m.result, 'myValue', m.myValue);
	and wMenu('ACTIVATE POPUP myPopup ... NOWAIT', @m.result)
assert m.success message m.result
</code>

if you:
- use the ACTIVATE MENU|POPUP <<b>><<u>>without the NOWAIT clause<</u>><</b>>,
- expect some code to execute <<b>><<u>>after<</u>><</b>> MENU|POPUP gets DEACTIVATEd,

Make sure to:
- move the code located after the ACTIVATE MENU|POPUP command to another method (AKA ''call-back'' method) - this code move is similar to what you already do for code processing the response of a modal form
- add 2 properties to the above-mentioned parameter object:
	. ''woCallBack'': reference to the form member holding the call-back method, = this typically
	. ''wcCallBack'': name of the call-back method, = 'wFormCallBack*' typically

Important:
- if either ''.woCallBack'' or ''.wcCallBack'' is not passed or do not match a valid object and public method, the code you currently have after ''ACTIVATE MENU|POPUP'' *WILL NOT EXECUTE* in Web mode.
- the call-back object (''.woCallBack'') MUST BE a form or a form member.
- make sure not to use ''woCallBack'' or ''wcCallBack'' as variable names as defined above.

<code lang="vfp">
local loMyObject, success, result
thisForm.AddObject('oObject', 'myCustom', InitParm)
loMyObject = thisForm.oObject
success = .T.;
	and wMenu('DEFI POPU myPopup MARGIN RELATIVE SHADOW COLOR  W+/B*', @m.result);
	and wMenu('ON SELECTION BAR 2 OF myPopup loMyObject.myMethod(m.myValue)', @m.result);
	and varSet(@m.result, CreateObject('Empty')); && {fr} you create an object which defines the parameters that are required for your ON SELECTION commands and SKIP FOR expressions
	and AddProperty(m.result, 'loMyObject', m.loMyObject); && {fr} loMyObject is needed to evaluate some SKIP FOR expression or execute some ON SELECTION command
	and AddProperty(m.result, 'myValue', m.myValue);
	and AddProperty(m.result, 'woCallBack', m.this);
	and AddProperty(m.result, 'wcCallBack', 'wFormCallBack'); && {fr} this.wFormCallBack() will execute when myPopup deactivates
	and wMenu('ACTIVATE POPUP myPopup ...', @m.result)
assert m.success message m.result
</code>

''wMenu()'' also executes menu functions:

<code lang="vfp">
&& {fr} function call before adaptation:
? Prmba( "myPopup", 2 )
&& {fr} function call after adaptation:
? wMenu('Prmba( "myPopup", 2 )', @m.result)
</code>

If an error occurs, ''wMenu('menuFunction()', @m.result)'' returns ''.null.'' (In logical tests such as IF, Iif(), case, etc., VFP maps .null. to .F.)

<code lang="vfp">
local lcPrmBar, success
lcPrmBar = wMenu('Prmba( "myPopup", 2 )', @m.result)
success = not IsNull(m.lcPrmBar)
assert m.success message m.result
if m.success
	do something with m.lcPrmBar
endif
</code>

	endtext && =====================================================


endcase

return m.result
endfunc

* =============================================================
procedure wMenu && {en} Executes a menu command / function in LAN (desktop) mode or Web mode
lparameters ;
  tcCmdFunc AS String; && {en} Menu command or function to be executed (parameters must be literals, except ON SELECTION commands and SKIP FOR expressions)
, varsIn_resultOut; && {en} in: {var1Name: var1Value, var2Name: var2Value, ...} - variables referenced in ON SELECTION commands, required to be in scope when ACTIVATEing Menu or Popup; @ out: error if any
, loAppHost as awMenu of awMenu.prg && {en} for FoxInCloud debug only, do not use

local luResult as Variant; && {menu command} success: .T., failure: .F. - {menu function} success: value returned by function, failure: .null.
, llResult AS Boolean;
, lcResult AS String;
, loResult AS Exception;
, llFunc AS Boolean; && @ [.null.] {fr} Function
, lcCmdFuncFound AS String; && @ [.null.] {fr} Command or function Name found in the instruction
, lcCmdFuncNorm AS String; && @ [.null.] {fr} Normalized Command or function Name
, lcLevel AS String; && @ [.null.] {fr} Level ('M'enu or 'Popup')
, llAppHost AS Boolean;
, laVar[1], liVar AS Integer, lcVar As String;

luResult = .null.

llResult = ga_Type_IsChar(m.tcCmdFunc, .T.)
varsIn_resultOut = Iif(m.llResult, m.varsIn_resultOut, Textmerge(['<<m.tcCmdFunc>>' ] + ICase(;
		cLangUser() = 'fr',	[doit être une chaîne de caractères non vide],; && copy-paste this line to add another language support
												[should be a non-empty character string]; && Default: English
		)))
assert m.llResult message cAssertMsg(m.varsIn_resultOut)
if m.llResult

	tcCmdFunc = Ltrim(cInLineCommentStripped(m.tcCmdFunc), ' ', TABUL, '=')

	llResult = lCommentLine(m.tcCmdFunc)
	IF NOT m.llResult

		llResult = wMenu_lValid(m.tcCmdFunc, @m.lcCmdFuncFound, @m.llFunc, @m.lcCmdFuncNorm, @m.lcLevel)
		varsIn_resultOut = Iif(m.llResult, m.varsIn_resultOut, Textmerge(['<<m.tcCmdFunc>>' ] + ICase(;
			cLangUser() = 'fr',	[doit être une commande ou une fonction de menu],; && copy-paste this line to add another language support
													[should be a menu command or function]; && Default: English
			)))
		ASSERT m.llResult MESSAGE cAssertMsg(m.varsIn_resultOut)
		IF m.llResult

			llAppHost = loClass(m.loAppHost, 'awMenu') 
			if !m.llAppHost and wlLAN()
				
					IF Vartype(m.varsIn_resultOut) == 'O'
						FOR liVar = 1 TO AMembers(laVar, m.varsIn_resultOut)
							lcVar = m.laVar[m.liVar]
							LOCAL (m.lcVar)
							STORE Evaluate('m.varsIn_resultOut.' + m.lcVar) TO (m.lcVar)
						ENDFOR
					ENDIF
					IF m.llResult

						* =============================================================
						if Pcount() > 1

							TRY
								IF m.llFunc
									luResult = Evaluate(m.tcCmdFunc)
								ELSE
									luResult = .F.
									&tcCmdFunc
									luResult = .T.
								ENDIF
							CATCH to loResult
								varsIn_resultOut = cException(m.loResult)
								assert .F. message cAssertMsg(m.varsIn_resultOut)
							ENDTRY

						else && {fr} no error handling -------------------------------------

							IF m.llFunc
								luResult = Evaluate(m.tcCmdFunc)
							ELSE
								&tcCmdFunc
							ENDIF
						endif
						* =============================================================
					ENDIF

			else && {fr} wlWeb()

				llResult = m.llAppHost or wlAppHost(@m.loAppHost)
				varsIn_resultOut = Iif(m.llResult, m.varsIn_resultOut, Textmerge(ICase(;
					cLangUser() = 'fr',	[En mode Web, l'application FoxInCloud doit avoir démarré],; && copy-paste this line to add another language support
															[In web mode, the FoxInCloud Application should have started]; && Default: English
					)))
				assert m.llResult MESSAGE cAssertMsg(m.varsIn_resultOut)
				if m.llResult
					
					llResult = m.loAppHost.wMenu_(;
						  @m.luResult; && {fr} résultat, si fonction et succès, retour de la fonction
						, m.tcCmdFunc; && {fr} Command or function to be executed (except for ON SELECTION commands and SKIP FOR expressions, parameters must be literals)
						, m.lcCmdFuncFound; && @ [.null.] {fr} Command or function name found in the instruction
						, m.llFunc; && @ [.null.] {fr} Function
						, m.lcCmdFuncNorm; && @ [.null.] {fr} Normalize()d Command or Function
						, m.lcLevel; && @ [.null.] {fr} Level ('M'enu or 'Popup')
						, @m.varsIn_resultOut; && @ {var1Name: var1Value, var2Name: var2Value, ...} - variables used in ON SELECTION commands, that must be in scope when ACTIVATEing Menu or Popup
						, Set("Datasession"); && [Set("Datasession")] {fr} Datasession where instruction is executed (for define menu / define popup)
						)

					assert m.llResult message cAssertMsg(m.luResult)

					varsIn_resultOut = Iif(.F.;
					 or m.llFunc and m.llResult;
					 or Empty(Nvl(m.luResult, .F.));
						, m.varsIn_resultOut;
						, m.luResult;
						)

					luResult = Iif(m.llFunc;
						, Iif(m.llResult;
							, m.luResult;
							, .null.;
							);
						, m.llResult;
						)
				ENDIF
			ENDIF
		ENDIF
	ENDIF
ENDIF

return m.luResult

* ---------------------------------------
procedure wMenu_lValid && {en} A Menu command or function is supported (2-3 ms)
lparameters ;
  tcCmdFunc AS String; && {en} Command or function to be checked for
, tcCmdFuncFound AS String; && @ [.null.] {en} Command or function Name found in the instruction
, tlFunc AS Boolean; && @ [.null.] {en} tcCmdFunc is a Function call
, tcCmdFuncNorm AS String; && @ [.null.] {en} Normalized Command or Function Name
, tcLevel AS String && @ [.null.] {en} Level ('M'enu or 'Popup')

store .null. to tcCmdFuncFound, tlFunc, tcCmdFuncNorm, tcLevel

LOCAL lcPattern, laPattern[1], llResult

TEXT TO lcPattern NOSHOW FLAGS 1 PRETEXT 7 && modify command awOOPmenu > awMenu_cPatterns()
	(^\bacti(v(a(t(e)?)?)?)?\b\s+\bmenu\b)	ACTIVATE MENU	C	M
	(^\bacti(v(a(t(e)?)?)?)?\b\s+\bpopu(p)?\b)	ACTIVATE POPUP	C	P
	(^\bclea(r)?\b\s+\bmenu(s)?\b)	CLEAR MENUS	C	M
	(^\bclea(r)?\b\s+\bpopu(p(s)?)?\b)	CLEAR POPUPS	C	P
	(^\bdeac(t(i(v(a(t(e)?)?)?)?)?)?\b\s+\bmenu\b)	DEACTIVATE MENU	C	M
	(^\bdeac(t(i(v(a(t(e)?)?)?)?)?)?\b\s+\bpopu(p)?\b)	DEACTIVATE POPUP	C	P
	(^\bdefi(n(e)?)?\b\s+\bbar\b)	DEFINE BAR	C	P
	(^\bdefi(n(e)?)?\b\s+\bmenu\b)	DEFINE MENU	C	M
	(^\bdefi(n(e)?)?\b\s+\bpad\b)	DEFINE PAD	C	M
	(^\bdefi(n(e)?)?\b\s+\bpopu(p)?\b)	DEFINE POPUP	C	P
	(^\bhide\b\s+\bmenu\b)	HIDE MENU	C	M
	(^\bhide\b\s+\bpopu(p)?\b)	HIDE POPUP	C	P
	(^\bmove\b\s+\bpopu(p)?\b)	MOVE POPUP	C	P
	(^\bon\b\s+\bbar\b)	ON BAR	C	P
	(^\bon\b\s+\bpad\b)	ON PAD	C	M
	(^\bon\b\s+\bsele(c(t(i(o(n)?)?)?)?)?\b\s+\bbar\b)	ON SELECTION BAR	C	P
	(^\bon\b\s+\bsele(c(t(i(o(n)?)?)?)?)?\b\s+\bmenu\b)	ON SELECTION MENU	C	M
	(^\bon\b\s+\bsele(c(t(i(o(n)?)?)?)?)?\b\s+\bpad\b)	ON SELECTION PAD	C	M
	(^\bon\b\s+\bsele(c(t(i(o(n)?)?)?)?)?\b\s+\bpopu(p)?\b)	ON SELECTION POPUP	C	P
	(^\bpop\b\s+\bmenu\b)	POP MENU	C	M
	(^\bpop\b\s+\bpopu(p)?\b)	POP POPUP	C	P
	(^\bpush\b\s+\bmenu\b)	PUSH MENU	C	M
	(^\bpush\b\s+\bpopu(p)?\b)	PUSH POPUP	C	P
	(^\brele(a(s(e)?)?)?\b\s+\bbar\b)	RELEASE BAR	C	P
	(^\brele(a(s(e)?)?)?\b\s+\bmenu(s)?\b)	RELEASE MENUS	C	M
	(^\brele(a(s(e)?)?)?\b\s+\bpad\b)	RELEASE PAD	C	M
	(^\brele(a(s(e)?)?)?\b\s+\bpopu(p(s)?)?\b)	RELEASE POPUPS	C	P
	(^\bset\b\s+\bmark\b\s+\bof\b\s+\bbar\b)	SET MARK OF BAR	C	P
	(^\bset\b\s+\bmark\b\s+\bof\b\s+\bmenu\b)	SET MARK OF MENU	C	M
	(^\bset\b\s+\bmark\b\s+\bof\b\s+\bpopu(p)?\b)	SET MARK OF POPUP	C	P
	(^\bset\b\s+\bskip\b\s+\bof\b\s+\bbar\b)	SET SKIP OF BAR	C	P
	(^\bset\b\s+\bskip\b\s+\bof\b\s+\bmenu\b)	SET SKIP OF MENU	C	M
	(^\bset\b\s+\bskip\b\s+\bof\b\s+\bpad\b)	SET SKIP OF PAD	C	M
	(^\bset\b\s+\bskip\b\s+\bof\b\s+\bpopu(p)?\b)	SET SKIP OF POPUP	C	P
	(^\bset\b\s+\bsysm(e(n(u)?)?)?\b)	SET SYSMENU	C	M
	(^\bshow\b\s+\bmenu\b)	SHOW MENU	C	M
	(^\bshow\b\s+\bpopu(p)?\b)	SHOW POPUP	C	P
	(^\bsize\b\s+\bpopu(p)?\b)	SIZE POPUP	C	P
	(\bbar\b)\s*\(	BAR	F	P
	(\bcntb(a(r)?)?\b)\s*\(	CNTBAR	F	P
	(\bcntp(a(d)?)?\b)\s*\(	CNTPAD	F	M
	(\bgetb(a(r)?)?\b)\s*\(	GETBAR	F	P
	(\bgetp(a(d)?)?\b)\s*\(	GETPAD	F	M
	(\bmenu\b)\s*\(	MENU	F	M
	(\bmrkb(a(r)?)?\b)\s*\(	MRKBAR	F	P
	(\bmrkp(a(d)?)?\b)\s*\(	MRKPAD	F	M
	(\bpad\b)\s*\(	PAD	F	M
	(\bpopu(p)?\b)\s*\(	POPUP	F	P
	(\bprmb(a(r)?)?\b)\s*\(	PRMBAR	F	P
	(\bprmp(a(d)?)?\b)\s*\(	PRMPAD	F	M
	(\bprom(p(t)?)?\b)\s*\(	PROMPT	F	
	(\bskpb(a(r)?)?\b)\s*\(	SKPBAR	F	P
	(\bskpp(a(d)?)?\b)\s*\(	SKPPAD	F	M
	(^\bbarp(r(o(m(p(t)?)?)?)?)?\b)	BARPROMPT	V	P
	(^\bon\b\s+\bexit\b\s+\bbar\b)	ON EXIT BAR	V	P
	(^\bon\b\s+\bexit\b\s+\bmenu\b)	ON EXIT MENU	V	M
	(^\bon\b\s+\bexit\b\s+\bpad\b)	ON EXIT PAD	V	M
	(^\bon\b\s+\bexit\b\s+\bpopu(p)?\b)	ON EXIT POPUP	V	P
ENDTEXT

aLinesCols(@m.laPattern, m.lcPattern)
tcCmdFunc = Alltrim(cInLineCommentStripped(m.tcCmdFunc), ' ', TABUL, CR, LF)

WITH abRegExp() AS abRegExp OF abTxt.prg

	llResult = .T.;
		and .setup(cListOfArray(@m.laPattern, '.*$' + CRLF), .T.);
		and .test(m.tcCmdFunc); && {fr} pour .nPattern exact
		and .T.
	if m.llResult
		
		tlFunc = m.laPattern[.nPattern, 3] == 'F'
		tcCmdFuncNorm = m.laPattern[.nPattern, 2]
		tcLevel = m.laPattern[.nPattern, 4]

		llResult = .T.;
			and .setup(m.laPattern[.nPattern, 1], .T.);
			and .execute(m.tcCmdFunc) = 1; && {fr} pour avoir .Matches
			and .T.

		tcCmdFuncFound = Iif(m.llResult, .Matches[3].Item(1), .null.) && $1
	endif
ENDWITH

return m.llResult

* ---------------------------------------
procedure wMenu_lValid_Test && {fr} Teste wMenu_lValid()

LOCAL loTest AS abUnitTest OF abDev.prg;
, lcCmdFuncFound;
, llFunc;
, lcCmdFuncNorm;
, lcLevel

loTest = abUnitTest()

loTest.Test(.T., 'DEFI POPU webconnect MARGIN RELATIVE SHADOW COLOR  W+/B*', @m.lcCmdFuncFound, @m.llFunc, @m.lcCmdFuncNorm, @m.lcLevel)
loTest.Assert('DEFI POPU', m.lcCmdFuncFound)
loTest.Assert(.F., m.llFunc)
loTest.Assert('DEFINE POPUP', m.lcCmdFuncNorm)
loTest.Assert('P', m.lcLevel)

loTest.Test(.T., 'DEFIN BAR 1 OF webconnect PROMPT "Web Connection \<Documentation" SKIP FOR !FILE("wconnect.chm")', @m.lcCmdFuncFound, @m.llFunc, @m.lcCmdFuncNorm, @m.lcLevel)
loTest.Assert('DEFIN BAR', m.lcCmdFuncFound)
loTest.Assert(.F., m.llFunc)
loTest.Assert('DEFINE BAR', m.lcCmdFuncNorm)
loTest.Assert('P', m.lcLevel)

loTest.Test(.T., 'Prmba	(  "myMenu", 12)', @m.lcCmdFuncFound, @m.llFunc, @m.lcCmdFuncNorm, @m.lcLevel)
loTest.Assert('Prmba', m.lcCmdFuncFound)
loTest.Assert(.T., m.llFunc)
loTest.Assert('PRMBAR', m.lcCmdFuncNorm)
loTest.Assert('P', m.lcLevel)

loTest.Test(.T., '				TOTO BAR GETBAR(lcpopup, 10) OF (lcpopup)', @m.lcCmdFuncFound, @m.llFunc, @m.lcCmdFuncNorm, @m.lcLevel)
loTest.Assert('GETBAR', m.lcCmdFuncFound)
loTest.Assert(.T., m.llFunc)
loTest.Assert('GETBAR', m.lcCmdFuncNorm)
loTest.Assert('P', m.lcLevel)

loTest.Test(.T., '   CASE CNTBAR(lcpopup) = 11', @m.lcCmdFuncFound, @m.llFunc, @m.lcCmdFuncNorm, @m.lcLevel)
loTest.Assert('CNTBAR', m.lcCmdFuncFound)
loTest.Assert(.T., m.llFunc)
loTest.Assert('CNTBAR', m.lcCmdFuncNorm)
loTest.Assert('P', m.lcLevel)

loTest.Test(.T., TABUL + 'RELEASE BAR GETBAR(lcpopup, 10) OF (lcpopup)' + CRLF, @m.lcCmdFuncFound, @m.llFunc, @m.lcCmdFuncNorm, @m.lcLevel)
loTest.Assert('RELEASE BAR', m.lcCmdFuncFound)
loTest.Assert(.F., m.llFunc)
loTest.Assert('RELEASE BAR', m.lcCmdFuncNorm)
loTest.Assert('P', m.lcLevel)

return m.loTest.Result()

* ============================================
function waRowSource && {fr} Un contrôle (liste a priori) a .RowSource = '*.waRowSource'
lparameters toList as awLst of aw.vcx, cRowSource
cRowSource = Trim(Evl(m.cRowSource, m.toList.RowSource))
return .T.;
	and m.toList.RowSourceType = 5;
	and Lower(Rightc(m.cRowSource, Len('.waRowSource'))) == Lower('.waRowSource')

* ============================================
function awSets as awSets of awPublic.prg
lparameters result && @ {en} error if any {fr} erreur éventuelle
return CreateObject('awSets', @m.result)

* ------------------------------------------------------------
DEFINE CLASS awSets AS abSets of abDev.prg && {en} Sets FoxInCloud Application Serveur (FAS) Application Environment {fr} Règle l'environnement de l'application dans le Serveur d'Application FoxInCloud (FAS)

protected ;
  wlWeb;
, wlLAN;
, lDevMode;
, lAutomation;
, oConfigApp;
, oAppConfig;

wlWeb = .null. && {en} application runs in Web mode {fr} l'application fonctionne en mode Web
wlLAN = .null. && {en} application runs in LAN (desktop) mode {fr} l'application fonctionne en mode LAN (desktop)
lDevMode = .null. && {en} application runs in the IDE {fr} l'application fonctionne dans l'IDE de VFP
lAutomation = .null. && {en} App works in COM mode {fr} L'application fonctionne en mode COM
oConfigApp = .null. && {en} App configuration object - see xxxServer.prg!xxxAppConfig {fr} Objet de configuration de l'application - voir xxxServer.prg!xxxAppConfig
oAppConfig = .null. && {en} App configuration object - see xxxServer.prg!xxxAppConfig {fr} Objet de configuration de l'application - voir xxxServer.prg!xxxAppConfig

hidden ;
  cPath;
, cDefault;
, cProc;
, cClas;
, cError;
, oISX;
, cIcon;
, cCaption;
, iWindowState;
, oKey as Collection

cDefault = Addbs(Sys(5)) + Curdir()
cPath = Set("Path")
* {fr} cProc = Set("Procedure")
cClas = Set("Classlib")
cError = On('Error')

* ---------------------
procedure Init
lparameters result && @ {en} error if any {fr} erreur éventuelle

on error

* {fr} this.cProc = Strtran(m.this.cProc, cModuleInfo(Sys(16, Program(-1)-1), 'Address'))
&& {fr} NewObject() l'ajoute automatiquement à Set("Procedure")
&& {fr} il faut le garder pour les définitions des classes de colonne et d'en-tête de colonne
set procedure to (m.this.classLibrary) additive
this.cProc = Set("Procedure")

this.wlWeb = wlWeb()
this.wlLAN = not m.this.wlWeb
this.lDevMode = lDevMode()
this.lAutomation = wlAutomation()

this.oISX = abISX()

local loAppHost as awAppHost of awAppHost.prg
if wlAppHost(@m.loAppHost) && modify command awPublic
	store m.loAppHost.oConfigApp to this.oConfigApp, this.oAppConfig
endif

if m.this.wlLAN
	Sys(3050, 1, 512*1024^2)
	Sys(3050, 2, 512*1024^2)
endif

if m.this.lDevMode
	this.cIcon = _Screen.Icon
	this.cCaption = _Screen.Caption
	this.iWindowState = _Screen.WindowState
	this.Set('ASSERTS', 'ON')
	this.Set('CONSOLE', 'OFF')
	this.Set('HELP', Set('HELP')) && 'OFF'
	push menu _mSysMenu  && {fr} set sysmenu save
	push key
endif

return DoDefault(@m.result)
endproc

* ---------------------
procedure Destroy

IF m.this.lDevMode

	WAIT Proper(Program()) + '() ' + ICase(;
		cLangUser() = 'fr',	[restaure votre Environnement de Développement Interactif, veuillez patienter …],; && copy-paste this line to add another language support
												[is restoring your Interactive Development Environment, please wait …]; && default: English
		) WINDOW NOCLEAR NOWAIT

	set default to (this.cDefault)
	
	if not m.this.cPath == Set('Path')
		set path to (m.this.cPath)
	endif

	SetProcClassRestore(m.this.cProc, .F.) && modify command abDev

	SetProcClassRestore(m.this.cClas, .T.) && modify command abDev
	
	local cError
	cError = this.cError
	on error &cError

	pop menu _mSysMenu && {fr} set sysmenu to default
	pop key

	_Screen.Icon = m.this.cIcon
	_Screen.Caption = m.this.cCaption
	_Screen.WindowState = m.this.iWindowState

	wait clear
	
endif

return DoDefault()
endproc

*!*		* ---------------------
*!*		hidden procedure Destroy_cFiles as String
*!*		lparameters tcFiles
*!*		
*!*		local lcResult as String;
*!*		, laFile[1], lcFile, lcFile_;
*!*		, liAlias

*!*		lcResult = ''
*!*		
*!*		if ALines(laFile, m.tcFiles, 5, ',') > 0

*!*			for each lcFile in m.laFile

*!*				liAlias = At_c('ALIAS', m.lcFile)
*!*				lcFile_ = Alltrim(Iif(m.liAlias > 0;
*!*						, Leftc(m.lcFile, m.liAlias-1);
*!*						, m.lcFile;
*!*						);
*!*					, ' ', '"';
*!*					)

*!*				if File(m.lcFile_)
*!*					lcResult = m.lcResult + ', ' + m.lcFile
*!*				endif
*!*			endfor
*!*		endif
*!*		
*!*		return Substr(m.lcResult, 3)

*!*		* ---------------------
*!*		hidden procedure Destroy_Keys

*!*		local success as Boolean;
*!*		, iKey as integer;
*!*		, cCmd as String;
*!*		, oExc as Exception;
*!*		
*!*		success = Vartype(m.this.oKey) == 'O'
*!*		if m.success
*!*			with m.this.oKey as Collection
*!*				if .count > 0
*!*					for iKey = 1 to .count
*!*						cCmd = Textmerge([on key label <<.GetKey(m.iKey)>> <<.Item(m.iKey)>>])
*!*						try
*!*							&cCmd
*!*						catch to oExc
*!*							success = .F.
*!*							assert m.success message cAssertMsg(cException(m.oExc))
*!*							exit
*!*						endtry
*!*					endfor
*!*				endif
*!*			endwith
*!*		endif
*!*		
*!*		return m.success

*!*		* ---------------------
*!*		hidden procedure Init_Keys
*!*		
*!*		local success as Boolean;
*!*		, oKey as Collection;
*!*		
*!*		success = .T.;
*!*		 and ga_Collection_Object(@m.oKey);
*!*		 and this.Init_Keys_alpha(@m.oKey); && {fr} Alpha keys combinations
*!*		 and this.Init_Keys_digit(@m.oKey);
*!*		 and this.Init_Keys_commd(@m.oKey);

*!*		this.oKey = Iif(m.success;
*!*			, m.oKey;
*!*			, .null.;
*!*			)
*!*		
*!*		assert m.success
*!*		return m.success
*!*		endproc

*!*		* ---------------------
*!*		hidden procedure Init_Keys_
*!*		lparameters ;
*!*		  oKey as Collection;
*!*		, cKey as String;
*!*		, lShift as Boolean; && {fr} Include the SHIFT modifier key
*!*		
*!*		lShift = lTrue(m.lShift)
*!*		
*!*		return .T.;
*!*		 and m.this.Init_Keys__(m.oKey, m.cKey, '');
*!*		 and (.F.;
*!*		 	or !m.lShift;
*!*		 	or m.this.Init_Keys__(m.oKey, m.cKey, 'SHIFT');
*!*		 	);
*!*		 and m.this.Init_Keys__(m.oKey, m.cKey, 'CTRL');
*!*		 and m.this.Init_Keys__(m.oKey, m.cKey, 'ALT');
*!*		 and (.F.;
*!*		 	or !m.lShift;
*!*		 	or m.this.Init_Keys__(m.oKey, m.cKey, 'SHIFT+CTRL');
*!*		 	);
*!*		 and (.F.;
*!*		 	or !m.lShift;
*!*		 	or m.this.Init_Keys__(m.oKey, m.cKey, 'SHIFT+ALT');
*!*		 	);
*!*		 and m.this.Init_Keys__(m.oKey, m.cKey, 'CTRL+ALT');
*!*		 and (.F.;
*!*		 	or !m.lShift;
*!*		 	or m.this.Init_Keys__(m.oKey, m.cKey, 'SHIFT+CTRL+ALT');
*!*		 	);

*!*		endproc

*!*		* ---------------------
*!*		hidden procedure Init_Keys__
*!*		lparameters ;
*!*		  oKey as Collection;
*!*		, cKey as String; && {fr} Key label
*!*		, cMod as String; && {fr} Key modifier

*!*		cMod = Evl(m.cMod, '')
*!*		
*!*		cKey = '';
*!*			+ m.cMod;
*!*			+ Iif(Empty(m.cMod), '', '+');
*!*			+ m.cKey
*!*		
*!*		return m.oKey.Add(On('Key', m.cKey), m.cKey) && {fr} Add(sValue, sKey)
*!*		endproc

*!*		* ---------------------
*!*		hidden procedure Init_Keys_alpha
*!*		lparameters oKey as Collection

*!*		local success as Boolean;
*!*		, iKey as Integer;

*!*		success = .T.

*!*		for iKey = 1 to 26
*!*			if !this.Init_Keys_(m.oKey, Chr(0x40 + m.iKey))
*!*				success = .F.
*!*				exit
*!*			endif
*!*		endfor
*!*		
*!*		return m.success
*!*		endproc

*!*		* ---------------------
*!*		hidden procedure Init_Keys_digit
*!*		lparameters oKey as Collection

*!*		local success as Boolean;
*!*		, iKey as Integer;

*!*		success = .T.

*!*		for iKey = 0 to 9
*!*			if !this.Init_Keys_(m.oKey, Chr(0x30 + m.iKey))
*!*				success = .F.
*!*				exit
*!*			endif
*!*		endfor
*!*		
*!*		return m.success
*!*		endproc

*!*		* ---------------------
*!*		hidden procedure Init_Keys_commd
*!*		lparameters oKey as Collection

*!*		local success as Boolean;
*!*		, aKey[1] as String;
*!*		, cKey as String;

*!*		success = m.this.Init_Keys_commd_a(@m.aKey) > 0
*!*		
*!*		if m.success
*!*			for each cKey in m.aKey
*!*				if !m.this.Init_Keys_(;
*!*					  m.oKey;
*!*					, m.cKey;
*!*					, .T.; && {fr} lShift && {fr} Include the SHIFT modifier key
*!*					)
*!*					success = .F.
*!*					exit
*!*				endif
*!*			endfor
*!*		endif
*!*		
*!*		return m.success
*!*		endproc

*!*		* ---------------------
*!*		hidden procedure Init_Keys_commd_a
*!*		lparameters aKey && @
*!*		
*!*		local result as String

*!*		text to result noshow flags 1 pretext 3
*!*	LEFTARROW
*!*	RIGHTARROW
*!*	UPARROW
*!*	DNARROW
*!*	HOME
*!*	END
*!*	PGUP
*!*	PGDN
*!*	DEL
*!*	BACKSPACE
*!*	SPACEBAR
*!*	INS
*!*	TAB
*!*	BACKTAB
*!*	LBRACE
*!*	RBRACE
*!*	ENTER
*!*	F1
*!*	F2
*!*	F3
*!*	F4
*!*	F5
*!*	F6
*!*	F7
*!*	F8
*!*	F9
*!*	F10
*!*	F11
*!*	F12
*!*		endtext
*!*		
*!*		return ALines(m.aKey, m.result)

*!*		endproc
 

* ============================================
ENDDEFINE && {fr} CLASS awSets
* ============================================


* ============================================
DEFINE CLASS awGrc AS Column
* ============================================

headerClass = 'awGrh'
headerClassLibrary = DOS_AB + 'awPublic.prg'

woForm = .null. && {en} LAN: form launched by thisForm.wForm() {fr} LAN : Formulaire lancé par thisForm.wForm()
wcPropSave = '' && [Web] {en} User-state properties to be saved {fr} Propriétés à sauvegarder
wcPropSaveNot = '' && [Web] {en} Custom user state properties NOT to be saved {fr} Propriétés à NE PAS sauvegarder
wcID = '' && {en} HTML 'id' attribute {fr} attribut HTML 'id'
woHTMLGen = .null. && {fr} AS awHTMLGen OF awHTML.prg - {en} awHTMLgen instance {fr} instance de awHTMLgen
wCSSclassAdd = '' && {en} Additional CSS class(es) {fr} Classe(s) CSS additionnelles
wcHTML = .null. && [cf. this.wcHTMLGen()]{en} Object custom HTML {fr} HTML spécifique de l'objet
wcHTMLevents = .null. && {en} HTML events to implement (coma delimited) - .null.: all (default), '': none {fr} Evénements HTML à générer (séparés par ',') - .null.: tous (défaut), '': aucun

wlContentDynamic = .F. && {en} This object's members and/or properties are dynamic - .T. if members or property change at run-time {fr} Le contenu et/ou les propriétés de cet objet sont dynamiques - .T. si les membres ou les propriétés changent à l'exécution

DynamicToolTipText = '' && {en} [Web only, not supported by VFP] Character expression setting ToolTipText for each grid row {fr} Expression caractère définissant le ToolTipText pour chaque ligne de la grille
_MemberData = '<VFPData><memberdata name="dynamictooltiptext" display="DynamicToolTipText" type="property"/></VFPData>'

*!*		*--------------------------------------------
*!*		protected procedure init

&& {fr} Column.init() s'exécute avant l'ajout de ses membres, donc avant Column.*.init()

*!*		local aa[1], obj as TextBox, llTxt

*!*		if aoClassCont(@m.aa, m.this) > 0
*!*			for each obj in m.aa
*!*				llTxt = m.obj.BaseClass == 'Textbox'
*!*				if m.llTxt
*!*					exit
*!*				endif
*!*			endfor
*!*		endif
*!*		
*!*		if not m.llTxt
*!*			this.AddObject('Text1', 'awTxt')
*!*		endif

*--------------------------------------------
procedure Init
lparameters fake_parameter_reminder_class_should_instantiate_standalone
endproc

*--------------------------------------------
procedure wlContentDynamic_Assign(tl)
&& {en} Visual FoxPro treats Access and Assign methods as Protected at run time
IF Vartype(m.tl) == 'L'
	this.wlContentDynamic = m.tl
	this.Parent.wlContentDynamic = m.this.Parent.wlContentDynamic or m.tl
ENDIF
endproc

*--------------------------------------------
procedure ControlSource_Assign(tcCS)
&& {en} Visual FoxPro treats Access and Assign methods as Protected at run time

* {fr} Ajouter l'alias du .ControlSource de la grille si non précisé
this.ControlSource = Iif(NOT (Empty(m.tcCS) OR '.' $ m.tcCS OR Empty(m.this.Parent.RecordSource)) AND Used(m.this.Parent.RecordSource);
	, m.this.Parent.RecordSource + '.' + m.tcCS;
	, m.tcCS;
	)
endproc

*--------------------------------------------
procedure CurrentControl_assign(tcCC)
&& {en} Visual FoxPro treats Access and Assign methods as Protected at run time

this.wlContentDynamic = m.this.wlContentDynamic or ! Lower(m.tcCC) == Lower(this.CurrentControl)
this.CurrentControl = m.tcCC
endproc

*--------------------------------------------
procedure MouseEnter
lparameters nButton, nShift, nXCoord, nYCoord
IF (Type('m.thisForm.wlHTMLgen') == 'L' AND m.thisForm.wlHTMLgen)
	return .F. && {en} default: ignore event in Web mode && {fr} subclass: return <JavaScript> to process on client
ENDIF

&& {fr} subclass: your code here

endproc

*--------------------------------------------
procedure MouseLeave
lparameters nButton, nShift, nXCoord, nYCoord
IF (Type('m.thisForm.wlHTMLgen') == 'L' AND m.thisForm.wlHTMLgen)
	return .F. && {en} default: ignore event in Web mode && {fr} subclass: return <JavaScript> to process on client
ENDIF

&& {fr} subclass: your code here

endproc

*--------------------------------------------
procedure MouseMove
lparameters nButton, nShift, nXCoord, nYCoord
IF (Type('m.thisForm.wlHTMLgen') == 'L' AND m.thisForm.wlHTMLgen)
	return .F. && {en} default: ignore event in Web mode && {fr} subclass: return <JavaScript> to process on client
ENDIF

&& {fr} subclass: your code here

endproc

*--------------------------------------------
procedure MouseWheel
lparameters nButton, nShift, nXCoord, nYCoord
IF (Type('m.thisForm.wlHTMLgen') == 'L' AND m.thisForm.wlHTMLgen)
	return .F. && {en} default: ignore event in Web mode && {fr} subclass: return <JavaScript> to process on client
ENDIF

&& {fr} subclass: your code here

endproc

*--------------------------------------------
procedure Moved
IF (Type('m.thisForm.wlHTMLgen') == 'L' AND m.thisForm.wlHTMLgen)
	return .F. && {en} default: ignore event in Web mode && {fr} subclass: return <JavaScript> to process on client
ENDIF

&& {fr} subclass: your code here
endproc

*--------------------------------------------
procedure Resize
IF (Type('m.thisForm.wlHTMLgen') == 'L' AND m.thisForm.wlHTMLgen)
	return .F. && {en} default: ignore event in Web mode && {fr} subclass: return <JavaScript> to process on client
ENDIF

&& {fr} subclass: your code here

endproc

*--------------------------------------------
procedure Refresh
lparameters move_your_refresh_code_into_this_refresh_, t02,t03,t04,t05,t06,t07,t08,t09,t10,t11,t12,t13,t14,t15,t16,t17,t18,t19,t20
if (Type('m.thisForm.wlPropsRestore') == 'L' AND m.thisForm.wlPropsRestore)
	return
endif

#if .f.

	{en} this.Refresh_() provides a general method where to store .Refresh() code into:
	{en} - supports noDefault (http://support.microsoft.com/kb/156739/en-us "Show Event Calls Refresh Despite noDefault in Subclass")
	{en} - does not execute after FAS restores form properties and data environment
	{en} - images based on aw.vcx!awImg participate in .Refresh_() [not native in VFP]
	{en} ... you keep calling *.Refresh(), and place your code in *.Refresh_()

	{fr} this.Refresh_() procure une méthode générique où placer votre code de .Refresh() :
	{fr} - supporte noDefault (http://support.microsoft.com/kb/156739/en-us "Show Event Calls Refresh Despite noDefault in Subclass")
	{fr} - ne s'exécute pas après que le serveur d'application a rafraîchi les propriétés et les données du formulaire
	{fr} - les images basées sur aw.vcx!awImg participent à .Refresh_() [manque à VFP natif]
	{fr} ... vous continuez à appeler *.Refresh(), et placez votre code dans *.Refresh_()

#endif

local lcParms as String;
, result as Variant;
, oMember as awGrh of awPublic.prg;

lcParms = Substr(wcParms(Pcount(),, 'move_your_refresh_code_into_this_refresh_'), 2)
result = this.Refresh_(&lcParms)

for each oMember in m.this.Controls foxobject
	if lMethod(m.oMember, 'Refresh')
		m.oMember.Refresh && {fr} VFP does not fire members' .refresh()
	endif
endfor

return m.result
endproc

*--------------------------------------------
procedure Refresh_
lparameters void_parameter_reminder_implement_your_Refresh_code_in_this_method
endproc

*-- {en} [Internal, do not overload] PROTECTED or HIDDEN property getter {fr} [Interne, ne pas surcharger] Valeur d'une propriété PROTECTED ou HIDDEN
PROCEDURE wpropget
	LPARAMETERS tcProp, taArray && @ {fr} tcProp is an Array
	EXTERNAL ARRAY taArray
	tcProp = 'm.this.' + m.tcProp
	RETURN Iif(Type(m.tcProp, 1) == 'A';
		, Iif(aClear(@m.taArray); && {fr} taArray is an array
				, Acopy(&tcProp, taArray);
				, 0;
				); && {fr} number of elements in array property
		, &tcProp; && {fr} property value
		)

	&& {fr} sous-classe : exécuter RETURN DoDefault(m.tcProp[, @m.taArray])
	&& {en} sub-class: execute RETURN DoDefault(m.tcProp[, @m.taArray])
ENDPROC


*-- {en} [Internal, do not overload] PROTECTED or HIDDEN property setter {fr} [Interne, ne pas surcharger] Règle la valeur d'une propriété PROTECTED ou HIDDEN
PROCEDURE wPropSet
	LPARAMETERS tcProp, tuValue
	WITH m.this

		tcProp = '.' + m.tcProp
		IF Type(m.tcProp, 1) == 'A'

			LOCAL llResult, lnCols, lnRows
			llResult = Type('m.tuValue', 1) == 'A'
			ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([second parameter <<cLitteral(m.tuValue)>> should be an array!]))
			IF m.llResult

				lnRows = Alen(tuValue, 1)
				lnCols = Alen(tuValue, 2)
				IF lnRows # Alen(&tcProp, 1) OR lnCols # Alen(&tcProp, 2)
					IF m.lnCols > 0
						DIMENSION &tcProp[m.lnRows, m.lnCols]
					ELSE
						DIMENSION &tcProp[m.lnRows]
					ENDIF
				ENDIF
				RETURN Acopy(m.tuValue, &tcProp)
			ELSE
				RETURN 0
			ENDIF
		ELSE
			STORE m.tuValue TO (m.tcProp)
		ENDIF
	ENDWITH

	&& {fr} sous-classe : exécuter RETURN DoDefault(m.tcProp, @m.tuValue)
	&& {en} sub-class: execute RETURN DoDefault(m.tcProp, @m.tuValue)
ENDPROC


*-- {en} [Internal, do not overload] PROTECTED or HIDDEN Array property {fr} [Interne, ne pas surcharger] Une propriété PROTECTED ou HIDDEN est un tableau
PROCEDURE wPropArray
	LPARAMETERS tcProp
	RETURN Type('m.this.' + m.tcProp, 1) == 'A'

	&& {fr} sous-classe : exécuter RETURN DoDefault(m.tcProp)
	&& {en} sub-class: execute RETURN DoDefault(m.tcProp)
ENDPROC


*-- {en} Standard method for processing value returned by modal forms {fr} Méthode standard pour traiter la valeur retournée par les formulaires modaux
PROCEDURE wFormCallBack
	LPARAMETERS tuUserChoice && @ {en} User's choice {fr} Choix de l'utilisateur
	&& {en} processes user choice on modal form {fr} Traite le choix d'un utilisateur sur un écran modal

	&& {en} IMPLEMENT IN SUB-CLASS
	&& {fr} IMPLÉMENTER EN SOUS-CLASSE
ENDPROC


*-- {en} Standard method for processing value returned by modal forms {fr} Méthode standard pour traiter la valeur retournée par les formulaires modaux
PROCEDURE wFormCallBack1
	LPARAMETERS tuUserChoice && @ {en} User's choice {fr} Choix de l'utilisateur
	&& {en} processes user choice on modal form {fr} Traite le choix d'un utilisateur sur un écran modal

	&& {en} IMPLEMENT IN SUB-CLASS
	&& {fr} IMPLÉMENTER EN SOUS-CLASSE
ENDPROC


*-- {en} Standard method for processing value returned by modal forms {fr} Méthode standard pour traiter la valeur retournée par les formulaires modaux
PROCEDURE wFormCallBack2
	LPARAMETERS tuUserChoice && @ {en} User's choice {fr} Choix de l'utilisateur
	&& {en} processes user choice on modal form {fr} Traite le choix d'un utilisateur sur un écran modal

	&& {en} IMPLEMENT IN SUB-CLASS
	&& {fr} IMPLÉMENTER EN SOUS-CLASSE
ENDPROC


*-- {en} Standard method for processing value returned by modal forms {fr} Méthode standard pour traiter la valeur retournée par les formulaires modaux
PROCEDURE wFormCallBack3
	LPARAMETERS tuUserChoice && @ {en} User's choice {fr} Choix de l'utilisateur
	&& {en} processes user choice on modal form {fr} Traite le choix d'un utilisateur sur un écran modal

	&& {en} IMPLEMENT IN SUB-CLASS
	&& {fr} IMPLÉMENTER EN SOUS-CLASSE
ENDPROC


*-- {en} Standard method for processing value returned by modal forms {fr} Méthode standard pour traiter la valeur retournée par les formulaires modaux
PROCEDURE wFormCallBack4
	LPARAMETERS tuUserChoice && @ {en} User's choice {fr} Choix de l'utilisateur
	&& {en} processes user choice on modal form {fr} Traite le choix d'un utilisateur sur un écran modal

	&& {en} IMPLEMENT IN SUB-CLASS
	&& {fr} IMPLÉMENTER EN SOUS-CLASSE
ENDPROC


*-- {en} Standard method for processing value returned by modal forms {fr} Méthode standard pour traiter la valeur retournée par les formulaires modaux
PROCEDURE wFormCallBack5
	LPARAMETERS tuUserChoice && @ {en} User's choice {fr} Choix de l'utilisateur
	&& {en} processes user choice on modal form {fr} Traite le choix d'un utilisateur sur un écran modal

	&& {en} IMPLEMENT IN SUB-CLASS
	&& {fr} IMPLÉMENTER EN SOUS-CLASSE
ENDPROC


*-- {en} Standard method for processing value returned by modal forms {fr} Méthode standard pour traiter la valeur retournée par les formulaires modaux
PROCEDURE wFormCallBack6
	LPARAMETERS tuUserChoice && @ {en} User's choice {fr} Choix de l'utilisateur
	&& {en} processes user choice on modal form {fr} Traite le choix d'un utilisateur sur un écran modal

	&& {en} IMPLEMENT IN SUB-CLASS
	&& {fr} IMPLÉMENTER EN SOUS-CLASSE
ENDPROC


*-- {en} Standard method for processing value returned by modal forms {fr} Méthode standard pour traiter la valeur retournée par les formulaires modaux
PROCEDURE wFormCallBack7
	LPARAMETERS tuUserChoice && @ {en} User's choice {fr} Choix de l'utilisateur
	&& {en} processes user choice on modal form {fr} Traite le choix d'un utilisateur sur un écran modal

	&& {en} IMPLEMENT IN SUB-CLASS
	&& {fr} IMPLÉMENTER EN SOUS-CLASSE
ENDPROC


*-- {en} Standard method for processing value returned by modal forms {fr} Méthode standard pour traiter la valeur retournée par les formulaires modaux
PROCEDURE wFormCallBack8
	LPARAMETERS tuUserChoice && @ {en} User's choice {fr} Choix de l'utilisateur
	&& {en} processes user choice on modal form {fr} Traite le choix d'un utilisateur sur un écran modal

	&& {en} IMPLEMENT IN SUB-CLASS
	&& {fr} IMPLÉMENTER EN SOUS-CLASSE
ENDPROC


*-- {en} Standard method for processing value returned by modal forms {fr} Méthode standard pour traiter la valeur retournée par les formulaires modaux
PROCEDURE wFormCallBack9
	LPARAMETERS tuUserChoice && @ {en} User's choice {fr} Choix de l'utilisateur
	&& {en} processes user choice on modal form {fr} Traite le choix d'un utilisateur sur un écran modal

	&& {en} IMPLEMENT IN SUB-CLASS
	&& {fr} IMPLÉMENTER EN SOUS-CLASSE
ENDPROC


*-- {en} [Internal, do not overload] .ResetToDefault() PROTECTED or HIDDEN property {fr} [Interne, ne pas surcharger] .ResetToDefault() une propriété PROTECTED ou HIDDEN
PROCEDURE wPropReset
	LPARAMETERS tcProp
	RETURN this.wPropArray(m.tcProp) OR this.ResetToDefault(m.tcProp)

	&& {fr} sous-classe : exécuter RETURN DoDefault(m.tcProp)
	&& {en} sub-class: execute RETURN DoDefault(m.tcProp)
ENDPROC


*-- {en} Class Documentation {fr} Documentation de la classe
PROTECTED PROCEDURE wReadMe
	#IF .F.

		{en} For an abstract documentation please see:
		{en} - class description that appears in the project manager lower bar when 'display description/path' is checked
		{en} - this.Comment
		{en} Detailed documentation of this class:

		{fr} Pour une documentation succincte, voir:
		{fr} - la description de la classe qui apparaît dans la barre basse du gestionnaire de projet quand 'afficher la description/chemin' est activé
		{fr} - this.Comment
		{fr} Documentation détaillée de cette classe :

	#ENDIF
ENDPROC

* ============================================
ENDDEFINE && {fr} CLASS awGrc
* ============================================

* ============================================
DEFINE CLASS awGrh AS Header
* ============================================

Caption = "Header"

woForm = .null. && {en} LAN: form launched by thisForm.wForm() {fr} LAN : Formulaire lancé par thisForm.wForm()
wcPropSave = '' && {en} User-state properties saved (web) {fr} Propriétés sauvegardées (web)
wcPropSaveNot = '' && [Web] {en} Custom user state properties NOT to be saved {fr} Propriétés à NE PAS sauvegarder

wcID = '' && {en} HTML 'id' attribute {fr} attribut HTML 'id'
woHTMLGen = .null. && {fr} AS awHTMLGen OF awHTML.prg - {en} awHTMLgen instance {fr} instance de awHTMLgen
wCSSclassAdd = '' && {en} Additional CSS class(es) {fr} Classe(s) CSS additionnelles
wcHTML = .null. && [cf. this.wcHTMLGen()]{en} Object custom HTML {fr} HTML spécifique de l'objet
wcHTMLevents = .null. && {en} HTML events to implement (coma delimited) - .null.: all (default), '': none {fr} Evénements HTML à générer (séparés par ',') - .null.: tous (défaut), '': aucun

*--------------------------------------------
procedure Click
IF (Type('m.thisForm.wlHTMLgen') == 'L' AND m.thisForm.wlHTMLgen)
	return .F. && {en} default: ignore event in Web mode && {fr} subclass: return <JavaScript> to process on client
ENDIF

&& {fr} subclass: your code here

endproc

*--------------------------------------------
procedure RightClick
IF (Type('m.thisForm.wlHTMLgen') == 'L' AND m.thisForm.wlHTMLgen)
	return .F. && {en} default: ignore event in Web mode && {fr} subclass: return <JavaScript> to process on client
ENDIF

&& {fr} subclass: your code here

endproc

*--------------------------------------------
procedure DblClick
IF (Type('m.thisForm.wlHTMLgen') == 'L' AND m.thisForm.wlHTMLgen)
	return .F. && {en} default: ignore event in Web mode && {fr} subclass: return <JavaScript> to process on client
ENDIF

&& {fr} subclass: your code here

endproc

*--------------------------------------------
procedure MiddleClick
IF (Type('m.thisForm.wlHTMLgen') == 'L' AND m.thisForm.wlHTMLgen)
	return .F. && {en} default: ignore event in Web mode && {fr} subclass: return <JavaScript> to process on client
ENDIF

&& {fr} subclass: your code here

endproc

*--------------------------------------------
procedure MouseDown
lparameters nButton, nShift, nXCoord, nYCoord
IF (Type('m.thisForm.wlHTMLgen') == 'L' AND m.thisForm.wlHTMLgen)
	return .F. && {en} default: ignore event in Web mode && {fr} subclass: return <JavaScript> to process on client
ENDIF

&& {fr} subclass: your code here

endproc

*--------------------------------------------
procedure MouseUp
lparameters nButton, nShift, nXCoord, nYCoord
IF (Type('m.thisForm.wlHTMLgen') == 'L' AND m.thisForm.wlHTMLgen)
	return .F. && {en} default: ignore event in Web mode && {fr} subclass: return <JavaScript> to process on client
ENDIF

&& {fr} subclass: your code here

endproc

*--------------------------------------------
procedure MouseEnter
lparameters nButton, nShift, nXCoord, nYCoord
IF (Type('m.thisForm.wlHTMLgen') == 'L' AND m.thisForm.wlHTMLgen)
	return .F. && {en} default: ignore event in Web mode && {fr} subclass: return <JavaScript> to process on client
ENDIF

&& {fr} subclass: your code here

endproc

*--------------------------------------------
procedure MouseLeave
lparameters nButton, nShift, nXCoord, nYCoord
IF (Type('m.thisForm.wlHTMLgen') == 'L' AND m.thisForm.wlHTMLgen)
	return .F. && {en} default: ignore event in Web mode && {fr} subclass: return <JavaScript> to process on client
ENDIF

&& {fr} subclass: your code here

endproc

*--------------------------------------------
procedure MouseMove
lparameters nButton, nShift, nXCoord, nYCoord
IF (Type('m.thisForm.wlHTMLgen') == 'L' AND m.thisForm.wlHTMLgen)
	return .F. && {en} default: ignore event in Web mode && {fr} subclass: return <JavaScript> to process on client
ENDIF

&& {fr} subclass: your code here

endproc

*--------------------------------------------
procedure MouseWheel
lparameters nButton, nShift, nXCoord, nYCoord
IF (Type('m.thisForm.wlHTMLgen') == 'L' AND m.thisForm.wlHTMLgen)
	return .F. && {en} default: ignore event in Web mode && {fr} subclass: return <JavaScript> to process on client
ENDIF

&& {fr} subclass: your code here

endproc

*--------------------------------------------
procedure Refresh
lparameters move_your_refresh_code_into_this_refresh_, t02,t03,t04,t05,t06,t07,t08,t09,t10,t11,t12,t13,t14,t15,t16,t17,t18,t19,t20
if (Type('m.thisForm.wlPropsRestore') == 'L' AND m.thisForm.wlPropsRestore)
	return
endif

#if .f.

	{en} this.Refresh_() provides a general method where to store .Refresh() code into:
	{en} - supports noDefault (http://support.microsoft.com/kb/156739/en-us "Show Event Calls Refresh Despite noDefault in Subclass")
	{en} - does not execute after FAS restores form properties and data environment
	{en} - images based on aw.vcx!awImg participate in .Refresh_() [not native in VFP]
	{en} ... you keep calling *.Refresh(), and place your code in *.Refresh_()

	{fr} this.Refresh_() procure une méthode générique où placer votre code de .Refresh() :
	{fr} - supporte noDefault (http://support.microsoft.com/kb/156739/en-us "Show Event Calls Refresh Despite noDefault in Subclass")
	{fr} - ne s'exécute pas après que le serveur d'application a rafraîchi les propriétés et les données du formulaire
	{fr} - les images basées sur aw.vcx!awImg participent à .Refresh_() [manque à VFP natif]
	{fr} ... vous continuez à appeler *.Refresh(), et placez votre code dans *.Refresh_()

#endif

local lcParms
lcParms = Substr(wcParms(Pcount(),, 'move_your_refresh_code_into_this_refresh_'), 2)

return this.Refresh_(&lcParms)
endproc

&& 2016-05-03 thn -- {FiC V 2.21.1-beta.1} {en} default header caption
&& lparameters void_parameter_reminder_implement_your_Refresh_code_in_this_method
*--------------------------------------------
procedure Refresh_
lparameters void_parameter_reminder_call_dodefault_after_your_code
if GetPem(this, 'Caption') == GetPem(this.Class, 'Caption') and !Empty(this.Parent.ControlSource)
	this.Caption = JustField(this.Parent.ControlSource)
endif

*--------------------------------------------
*-- {en} [Internal, do not overload] PROTECTED or HIDDEN property getter {fr} [Interne, ne pas surcharger] Valeur d'une propriété PROTECTED ou HIDDEN
PROCEDURE wpropget
	LPARAMETERS tcProp, taArray && @ {fr} tcProp is an Array
	EXTERNAL ARRAY taArray
	tcProp = 'm.this.' + m.tcProp
	RETURN Iif(Type(m.tcProp, 1) == 'A';
		, Iif(aClear(@m.taArray); && {fr} taArray is an array
				, Acopy(&tcProp, taArray);
				, 0;
				); && {fr} number of elements in array property
		, &tcProp; && {fr} property value
		)

	&& {fr} sous-classe : exécuter RETURN DoDefault(m.tcProp[, @m.taArray])
	&& {en} sub-class: execute RETURN DoDefault(m.tcProp[, @m.taArray])
ENDPROC


*-- {en} [Internal, do not overload] PROTECTED or HIDDEN property setter {fr} [Interne, ne pas surcharger] Règle la valeur d'une propriété PROTECTED ou HIDDEN
PROCEDURE wPropSet
	LPARAMETERS tcProp, tuValue
	WITH m.this

		tcProp = '.' + m.tcProp
		IF Type(m.tcProp, 1) == 'A'

			LOCAL llResult, lnCols, lnRows
			llResult = Type('m.tuValue', 1) == 'A'
			ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([second parameter <<cLitteral(m.tuValue)>> should be an array!]))
			IF m.llResult

				lnRows = Alen(tuValue, 1)
				lnCols = Alen(tuValue, 2)
				IF lnRows # Alen(&tcProp, 1) OR lnCols # Alen(&tcProp, 2)
					IF m.lnCols > 0
						DIMENSION &tcProp[m.lnRows, m.lnCols]
					ELSE
						DIMENSION &tcProp[m.lnRows]
					ENDIF
				ENDIF
				RETURN Acopy(m.tuValue, &tcProp)
			ELSE
				RETURN 0
			ENDIF
		ELSE
			STORE m.tuValue TO (m.tcProp)
		ENDIF
	ENDWITH

	&& {fr} sous-classe : exécuter RETURN DoDefault(m.tcProp, @m.tuValue)
	&& {en} sub-class: execute RETURN DoDefault(m.tcProp, @m.tuValue)
ENDPROC


*-- {en} [Internal, do not overload] PROTECTED or HIDDEN Array property {fr} [Interne, ne pas surcharger] Une propriété PROTECTED ou HIDDEN est un tableau
PROCEDURE wPropArray
	LPARAMETERS tcProp
	RETURN Type('m.this.' + m.tcProp, 1) == 'A'

	&& {fr} sous-classe : exécuter RETURN DoDefault(m.tcProp)
	&& {en} sub-class: execute RETURN DoDefault(m.tcProp)
ENDPROC


*-- {en} Standard method for processing value returned by modal forms {fr} Méthode standard pour traiter la valeur retournée par les formulaires modaux
PROCEDURE wFormCallBack
	LPARAMETERS tuUserChoice && @ {en} User's choice {fr} Choix de l'utilisateur
	&& {en} processes user choice on modal form {fr} Traite le choix d'un utilisateur sur un écran modal

	&& {en} IMPLEMENT IN SUB-CLASS
	&& {fr} IMPLÉMENTER EN SOUS-CLASSE
ENDPROC


*-- {en} Standard method for processing value returned by modal forms {fr} Méthode standard pour traiter la valeur retournée par les formulaires modaux
PROCEDURE wFormCallBack1
	LPARAMETERS tuUserChoice && @ {en} User's choice {fr} Choix de l'utilisateur
	&& {en} processes user choice on modal form {fr} Traite le choix d'un utilisateur sur un écran modal

	&& {en} IMPLEMENT IN SUB-CLASS
	&& {fr} IMPLÉMENTER EN SOUS-CLASSE
ENDPROC


*-- {en} Standard method for processing value returned by modal forms {fr} Méthode standard pour traiter la valeur retournée par les formulaires modaux
PROCEDURE wFormCallBack2
	LPARAMETERS tuUserChoice && @ {en} User's choice {fr} Choix de l'utilisateur
	&& {en} processes user choice on modal form {fr} Traite le choix d'un utilisateur sur un écran modal

	&& {en} IMPLEMENT IN SUB-CLASS
	&& {fr} IMPLÉMENTER EN SOUS-CLASSE
ENDPROC


*-- {en} Standard method for processing value returned by modal forms {fr} Méthode standard pour traiter la valeur retournée par les formulaires modaux
PROCEDURE wFormCallBack3
	LPARAMETERS tuUserChoice && @ {en} User's choice {fr} Choix de l'utilisateur
	&& {en} processes user choice on modal form {fr} Traite le choix d'un utilisateur sur un écran modal

	&& {en} IMPLEMENT IN SUB-CLASS
	&& {fr} IMPLÉMENTER EN SOUS-CLASSE
ENDPROC


*-- {en} Standard method for processing value returned by modal forms {fr} Méthode standard pour traiter la valeur retournée par les formulaires modaux
PROCEDURE wFormCallBack4
	LPARAMETERS tuUserChoice && @ {en} User's choice {fr} Choix de l'utilisateur
	&& {en} processes user choice on modal form {fr} Traite le choix d'un utilisateur sur un écran modal

	&& {en} IMPLEMENT IN SUB-CLASS
	&& {fr} IMPLÉMENTER EN SOUS-CLASSE
ENDPROC


*-- {en} Standard method for processing value returned by modal forms {fr} Méthode standard pour traiter la valeur retournée par les formulaires modaux
PROCEDURE wFormCallBack5
	LPARAMETERS tuUserChoice && @ {en} User's choice {fr} Choix de l'utilisateur
	&& {en} processes user choice on modal form {fr} Traite le choix d'un utilisateur sur un écran modal

	&& {en} IMPLEMENT IN SUB-CLASS
	&& {fr} IMPLÉMENTER EN SOUS-CLASSE
ENDPROC


*-- {en} Standard method for processing value returned by modal forms {fr} Méthode standard pour traiter la valeur retournée par les formulaires modaux
PROCEDURE wFormCallBack6
	LPARAMETERS tuUserChoice && @ {en} User's choice {fr} Choix de l'utilisateur
	&& {en} processes user choice on modal form {fr} Traite le choix d'un utilisateur sur un écran modal

	&& {en} IMPLEMENT IN SUB-CLASS
	&& {fr} IMPLÉMENTER EN SOUS-CLASSE
ENDPROC


*-- {en} Standard method for processing value returned by modal forms {fr} Méthode standard pour traiter la valeur retournée par les formulaires modaux
PROCEDURE wFormCallBack7
	LPARAMETERS tuUserChoice && @ {en} User's choice {fr} Choix de l'utilisateur
	&& {en} processes user choice on modal form {fr} Traite le choix d'un utilisateur sur un écran modal

	&& {en} IMPLEMENT IN SUB-CLASS
	&& {fr} IMPLÉMENTER EN SOUS-CLASSE
ENDPROC


*-- {en} Standard method for processing value returned by modal forms {fr} Méthode standard pour traiter la valeur retournée par les formulaires modaux
PROCEDURE wFormCallBack8
	LPARAMETERS tuUserChoice && @ {en} User's choice {fr} Choix de l'utilisateur
	&& {en} processes user choice on modal form {fr} Traite le choix d'un utilisateur sur un écran modal

	&& {en} IMPLEMENT IN SUB-CLASS
	&& {fr} IMPLÉMENTER EN SOUS-CLASSE
ENDPROC


*-- {en} Standard method for processing value returned by modal forms {fr} Méthode standard pour traiter la valeur retournée par les formulaires modaux
PROCEDURE wFormCallBack9
	LPARAMETERS tuUserChoice && @ {en} User's choice {fr} Choix de l'utilisateur
	&& {en} processes user choice on modal form {fr} Traite le choix d'un utilisateur sur un écran modal

	&& {en} IMPLEMENT IN SUB-CLASS
	&& {fr} IMPLÉMENTER EN SOUS-CLASSE
ENDPROC


*-- {en} [Internal, do not overload] .ResetToDefault() PROTECTED or HIDDEN property {fr} [Interne, ne pas surcharger] .ResetToDefault() une propriété PROTECTED ou HIDDEN
PROCEDURE wPropReset
	LPARAMETERS tcProp
	RETURN this.wPropArray(m.tcProp) OR this.ResetToDefault(m.tcProp)

	&& {fr} sous-classe : exécuter RETURN DoDefault(m.tcProp)
	&& {en} sub-class: execute RETURN DoDefault(m.tcProp)
ENDPROC


*-- {en} Class Documentation {fr} Documentation de la classe
PROTECTED PROCEDURE wReadMe
	#IF .F.

		{en} For an abstract documentation please see:
		{en} - class description that appears in the project manager lower bar when 'display description/path' is checked
		{en} - this.Comment
		{en} Detailed documentation of this class:

		{fr} Pour une documentation succincte, voir:
		{fr} - la description de la classe qui apparaît dans la barre basse du gestionnaire de projet quand 'afficher la description/chemin' est activé
		{fr} - this.Comment
		{fr} Documentation détaillée de cette classe :

	#ENDIF
ENDPROC

* ============================================
ENDDEFINE && {fr} CLASS awGrh
* ============================================

* ============================================
DEFINE CLASS awSes AS Session
* ============================================
woForm = .null. && {en} LAN: form launched by thisForm.wForm() {fr} LAN : Formulaire lancé par thisForm.wForm()
wcPropSave = '' && {en} User-state properties saved (web) {fr} Propriétés sauvegardées (web)
wcPropSaveNot = '' && [Web] {en} Custom user state properties NOT to be saved {fr} Propriétés à NE PAS sauvegarder

wcID = '' && {en} HTML 'id' attribute {fr} attribut HTML 'id'
woHTMLGen = .null. && {fr} AS awHTMLGen OF awHTML.prg - {en} awHTMLgen instance {fr} instance de awHTMLgen
wCSSclassAdd = '' && {en} Additional CSS class(es) {fr} Classe(s) CSS additionnelles
wcHTML = .null. && [cf. this.wcHTMLGen()]{en} Object custom HTML {fr} HTML spécifique de l'objet
wcHTMLevents = .null. && {en} HTML events to implement (coma delimited) - .null.: all (default), '': none {fr} Evénements HTML à générer (séparés par ',') - .null.: tous (défaut), '': aucun

*-- {en} [Internal, do not overload] PROTECTED or HIDDEN property setter {fr} [Interne, ne pas surcharger] Règle la valeur d'une propriété PROTECTED ou HIDDEN
PROCEDURE wPropSet
	LPARAMETERS tcProp, tuValue
	WITH m.this

		tcProp = '.' + m.tcProp
		IF Type(m.tcProp, 1) == 'A'

			LOCAL llResult, lnCols, lnRows
			llResult = Type('m.tuValue', 1) == 'A'
			ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([second parameter <<cLitteral(m.tuValue)>> should be an array!]))
			IF m.llResult

				lnRows = Alen(tuValue, 1)
				lnCols = Alen(tuValue, 2)
				IF lnRows # Alen(&tcProp, 1) OR lnCols # Alen(&tcProp, 2)
					IF m.lnCols > 0
						DIMENSION &tcProp[m.lnRows, m.lnCols]
					ELSE
						DIMENSION &tcProp[m.lnRows]
					ENDIF
				ENDIF
				RETURN Acopy(m.tuValue, &tcProp)
			ELSE
				RETURN 0
			ENDIF
		ELSE
			STORE m.tuValue TO (m.tcProp)
		ENDIF
	ENDWITH

	&& {fr} sous-classe : exécuter RETURN DoDefault(m.tcProp, @m.tuValue)
	&& {en} sub-class: execute RETURN DoDefault(m.tcProp, @m.tuValue)
ENDPROC


*-- {en} [Internal, do not overload] PROTECTED or HIDDEN Array property {fr} [Interne, ne pas surcharger] Une propriété PROTECTED ou HIDDEN est un tableau
PROCEDURE wPropArray
	LPARAMETERS tcProp
	RETURN Type('m.this.' + m.tcProp, 1) == 'A'

	&& {fr} sous-classe : exécuter RETURN DoDefault(m.tcProp)
	&& {en} sub-class: execute RETURN DoDefault(m.tcProp)
ENDPROC


*-- {en} Standard method for processing value returned by modal forms {fr} Méthode standard pour traiter la valeur retournée par les formulaires modaux
PROCEDURE wFormCallBack
	LPARAMETERS tuUserChoice && @ {en} User's choice {fr} Choix de l'utilisateur
	&& {en} processes user choice on modal form {fr} Traite le choix d'un utilisateur sur un écran modal

	&& {en} IMPLEMENT IN SUB-CLASS
	&& {fr} IMPLÉMENTER EN SOUS-CLASSE
ENDPROC


*-- {en} Standard method for processing value returned by modal forms {fr} Méthode standard pour traiter la valeur retournée par les formulaires modaux
PROCEDURE wFormCallBack1
	LPARAMETERS tuUserChoice && @ {en} User's choice {fr} Choix de l'utilisateur
	&& {en} processes user choice on modal form {fr} Traite le choix d'un utilisateur sur un écran modal

	&& {en} IMPLEMENT IN SUB-CLASS
	&& {fr} IMPLÉMENTER EN SOUS-CLASSE
ENDPROC


*-- {en} Standard method for processing value returned by modal forms {fr} Méthode standard pour traiter la valeur retournée par les formulaires modaux
PROCEDURE wFormCallBack2
	LPARAMETERS tuUserChoice && @ {en} User's choice {fr} Choix de l'utilisateur
	&& {en} processes user choice on modal form {fr} Traite le choix d'un utilisateur sur un écran modal

	&& {en} IMPLEMENT IN SUB-CLASS
	&& {fr} IMPLÉMENTER EN SOUS-CLASSE
ENDPROC


*-- {en} Standard method for processing value returned by modal forms {fr} Méthode standard pour traiter la valeur retournée par les formulaires modaux
PROCEDURE wFormCallBack3
	LPARAMETERS tuUserChoice && @ {en} User's choice {fr} Choix de l'utilisateur
	&& {en} processes user choice on modal form {fr} Traite le choix d'un utilisateur sur un écran modal

	&& {en} IMPLEMENT IN SUB-CLASS
	&& {fr} IMPLÉMENTER EN SOUS-CLASSE
ENDPROC


*-- {en} Standard method for processing value returned by modal forms {fr} Méthode standard pour traiter la valeur retournée par les formulaires modaux
PROCEDURE wFormCallBack4
	LPARAMETERS tuUserChoice && @ {en} User's choice {fr} Choix de l'utilisateur
	&& {en} processes user choice on modal form {fr} Traite le choix d'un utilisateur sur un écran modal

	&& {en} IMPLEMENT IN SUB-CLASS
	&& {fr} IMPLÉMENTER EN SOUS-CLASSE
ENDPROC


*-- {en} Standard method for processing value returned by modal forms {fr} Méthode standard pour traiter la valeur retournée par les formulaires modaux
PROCEDURE wFormCallBack5
	LPARAMETERS tuUserChoice && @ {en} User's choice {fr} Choix de l'utilisateur
	&& {en} processes user choice on modal form {fr} Traite le choix d'un utilisateur sur un écran modal

	&& {en} IMPLEMENT IN SUB-CLASS
	&& {fr} IMPLÉMENTER EN SOUS-CLASSE
ENDPROC


*-- {en} Standard method for processing value returned by modal forms {fr} Méthode standard pour traiter la valeur retournée par les formulaires modaux
PROCEDURE wFormCallBack6
	LPARAMETERS tuUserChoice && @ {en} User's choice {fr} Choix de l'utilisateur
	&& {en} processes user choice on modal form {fr} Traite le choix d'un utilisateur sur un écran modal

	&& {en} IMPLEMENT IN SUB-CLASS
	&& {fr} IMPLÉMENTER EN SOUS-CLASSE
ENDPROC


*-- {en} Standard method for processing value returned by modal forms {fr} Méthode standard pour traiter la valeur retournée par les formulaires modaux
PROCEDURE wFormCallBack7
	LPARAMETERS tuUserChoice && @ {en} User's choice {fr} Choix de l'utilisateur
	&& {en} processes user choice on modal form {fr} Traite le choix d'un utilisateur sur un écran modal

	&& {en} IMPLEMENT IN SUB-CLASS
	&& {fr} IMPLÉMENTER EN SOUS-CLASSE
ENDPROC


*-- {en} Standard method for processing value returned by modal forms {fr} Méthode standard pour traiter la valeur retournée par les formulaires modaux
PROCEDURE wFormCallBack8
	LPARAMETERS tuUserChoice && @ {en} User's choice {fr} Choix de l'utilisateur
	&& {en} processes user choice on modal form {fr} Traite le choix d'un utilisateur sur un écran modal

	&& {en} IMPLEMENT IN SUB-CLASS
	&& {fr} IMPLÉMENTER EN SOUS-CLASSE
ENDPROC


*-- {en} Standard method for processing value returned by modal forms {fr} Méthode standard pour traiter la valeur retournée par les formulaires modaux
PROCEDURE wFormCallBack9
	LPARAMETERS tuUserChoice && @ {en} User's choice {fr} Choix de l'utilisateur
	&& {en} processes user choice on modal form {fr} Traite le choix d'un utilisateur sur un écran modal

	&& {en} IMPLEMENT IN SUB-CLASS
	&& {fr} IMPLÉMENTER EN SOUS-CLASSE
ENDPROC


*-- {en} [Internal, do not overload] .ResetToDefault() PROTECTED or HIDDEN property {fr} [Interne, ne pas surcharger] .ResetToDefault() une propriété PROTECTED ou HIDDEN
PROCEDURE wPropReset
	LPARAMETERS tcProp
	RETURN this.wPropArray(m.tcProp) OR this.ResetToDefault(m.tcProp)

	&& {fr} sous-classe : exécuter RETURN DoDefault(m.tcProp)
	&& {en} sub-class: execute RETURN DoDefault(m.tcProp)
ENDPROC


*-- {en} Class Documentation {fr} Documentation de la classe
PROTECTED PROCEDURE wReadMe
	#IF .F.

		{en} For an abstract documentation please see:
		{en} - class description that appears in the project manager lower bar when 'display description/path' is checked
		{en} - this.Comment
		{en} Detailed documentation of this class:

		{fr} Pour une documentation succincte, voir:
		{fr} - la description de la classe qui apparaît dans la barre basse du gestionnaire de projet quand 'afficher la description/chemin' est activé
		{fr} - this.Comment
		{fr} Documentation détaillée de cette classe :

	#ENDIF
ENDPROC

* ============================================
ENDDEFINE && {fr} CLASS awSes
* ============================================

* -----------------------------------------------------
function cawUserAction && {en} FoxInCloud user action linearized from Request data
lparameters reqData, lError

&& 2016-06-16 thn -- {FiC V 2.21.1-beta.6} {en} created
local result;
, piece;
, iSep

result = ''

if .T. && !m.lError

	piece = cawUserAction_strExtract(m.reqData, '&ObjAddr=', '&', 1, 3)
	iSep = Atc('-', m.piece)
	piece = Iif(Empty(m.iSep), '', '.' + Chrtran(Substr(m.piece, m.iSep + 1), '-', '.'))
	result = c2Words(m.result, ' ', m.piece)

	piece =  Evl(Evl(Evl(Evl('';
		, Proper(cawUserAction_strExtract(m.reqData, '&Event=', '&', 1, 3)));
		, cawUserAction_strExtract(m.reqData, '&Prop=', '&', 1, 3));
		, cawUserAction_strExtract(m.reqData, '&MethAddr=', '&', 1, 3));
		, '')

	piece = ICase(;
		Lower(m.piece) == Lower('InitControlsInet'),;
			'Init',;
		Lower(m.piece) == Lower('focus'),;
			'GotFocus',;
		Lower(m.piece) == Lower('blur'),;
			'Valid',;
		Lower(m.piece) == Lower('change'),;
			'InteractiveChange',;
			m.piece;
		)

	result = m.result + nEvl(m.piece, '.' + m.piece)

	piece = Strtran(URLDecode(cawUserAction_strExtract(m.reqData, '&ValueType=', '&', 1, 3)), 'undefined')
	piece = Iif(Empty(m.piece);
		, '';
		, cL(uValueJS(;
			  URLDecode(cawUserAction_strExtract(m.reqData, '&Value=', '&', 1, 3));
			, m.piece;
			));
		)
	result = c2Words(m.result, '(', nEvl(m.piece, m.piece + ')'))

endif

return Padr(m.result, 100)

* -----------------------------------------------------
function cawUserAction_strExtract
lparameters cSearchExpression, cBeginDelim, cEndDelim, nOccurrence, nFlag 
return Trim(StrExtract(m.cSearchExpression, m.cBeginDelim, Evl(m.cEndDelim, ''), Evl(m.nOccurrence, 1), Evl(m.nFlag, 0)), ' ', CR, LF)

* -----------------------------------------------------
function cawErrorDetail && {en} Error details extracted from user report in the request log
lparameters ;
  error as Boolean;
, queryStr as String;
, nError as Integer; && @ [.null.]

nError = .null.

local result, oRegExp as abRegExp, iMatch, oSubMatch, aa[1]
result = ''
if m.error
	oRegExp = abRegExp('err[^\d]{4,10}(\d{1,4})', 'gi')
	for iMatch = 1 to oRegExp.execute(m.queryStr)
		nError = Cast(m.oRegExp.Matches[m.iMatch, 3].Item(1) as Integer)
		if m.nError # 2071 && Erreur levée par l'utilisateur
			result = GetWordNum(cawUserAction_strExtract(Ltrim(Substr(m.queryStr, m.oRegExp.Matches[m.iMatch, 1] + m.oRegExp.Matches[m.iMatch, 4])), '("', '")'), 1, '-')
			exit
		endif
	endfor
	if Empty(m.result)
		for iMatch = 2 to ALines(aa, m.queryStr)
			if Empty(m.aa[m.iMatch])
				exit
			else
				result = c2Words(m.result, ' - ', cOfLitteral(m.aa[m.iMatch]))
			endif
		endfor
	endif
	if Empty(m.result)
		#if .F.
		 Error:          7
		 Message: Le fichier existe d?j?.
		 Code: 
		 Program: propsreplace
		 Line No:      13235
		 Client: 41.188.43.37
		#endif
		m.oRegExp.setup('^\s*message\s*:\s*(.+)$', 'im')
		if oRegExp.execute(m.queryStr) = 1
			result = m.oRegExp.Matches[1, 3].Item(1)
			m.oRegExp.setup('^\s*error\s*:\s*(\d{1,4})\s*$', 'im')
			if oRegExp.execute(m.queryStr) = 1
				nError = Cast(m.oRegExp.Matches[1, 3].Item(1) as I)
			endif
		endif
	endif
	result = Evl(m.result, m.queryStr)
endif
return Padr(Trim(m.result, CR, LF, ' '), 100)
endfunc

* -----------------------------------------------------
function nawError && {en} Error number extracted from user report in the request log
lparameters ;
  error as Boolean;
, queryStr as String;

local nawError as Integer

cawErrorDetail(m.error, m.queryStr, @m.nawError)

return m.nawError
endfunc

* -----------------------------------------------------
function lLocalHost(cURL) && {en} URL run on localhost
return InList(allTrim(Evl(m.cURL, '')), '127.0.0.1', '::1')
endfunc
