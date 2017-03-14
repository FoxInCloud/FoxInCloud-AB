* {fr} ab.prg
* =====================================================
* (c) Abaque SARL, 66 rue Michel Ange - 75016 Paris - France
* contact@FoxInCloud.com - http://foxincloud.com/ - +33 9 53 41 90 90
*  -----------------------------------------------------
* {fr} Ce logiciel est distribué sous GNU General Public License, tel quel, sans aucune garantie
* {fr} Il peut être utilisé et/ou redistribué sans restriction
* {fr} Toute modification doit être reversée à la communauté
* {fr} La présente mention doit être intégralement reproduite dans toute copie même partielle
*  -----------------------------------------------------
* {en} This software is distributed under the terms of GNU General Public License, AS IS, without any warranty
* {en} It can be used and/or distributed without restriction
* {en} Any modification or improvement must be given for free to the community
* {en} This permission notice shall be entirely included in all copies or substantial portions of the Software
* =====================================================

* =====================================================
* {fr} Pour disposer des modules inclus dans ab*.prg, exécuter ce programme
* {en} To use modules in ab*.prg from your app, just execute this program
* =====================================================

#if File('AB.h') && 2016-02-25 thn -- {en} after FAA adapt, compilation must succeed although pathes are not yet set
	#include AB.h
#endif

LPARAMETERS ;
  tlClear; && [.F.] {fr} Supprimer les références de Set("Procedure") et Set("Classlib")
, tlAppExe; && [.F.] {fr} Le programme principal est un app ou un exe
, tlGAno && [.F.] RELEASE PROCEDURE abga

local lcFXPs
lcFXPs = cABprgs(.T.)

* {fr} Si suppression des ressources
IF Vartype(m.tlClear) == 'L' and m.tlClear && lTrue() indisponible

	IF '\ab.fxp' $ Lower(Set("Procedure"))
		RELEASE PROCEDURE &lcFXPs

		IF '\aw.vcx' $ Lower(Set("Classlib"))
			RELEASE CLASSLIB AW
		ENDIF
	ENDIF

* {fr} Sinon, installation des ressources
ELSE
	
	IF NOT (Vartype(m.tlAppExe) == 'L' and m.tlAppExe) && lTrue() indisponible
		local lcDirAB, lcDirA_
		set path to (Home(1)) additive && {fr} VFP
		set path to (Home(1) + 'FFC\') additive
		set path to (Home(1) + 'Tools\') additive
		lcDirAB = Addbs(JustPath(Sys(16)))
		set path to (m.lcDirAB) additive && {fr} dossier du présent programme
*!*				lcDirA_ = m.lcDirAB + 'at\'
*!*				if Directory(m.lcDirA_)
*!*					set path to (m.lcDirA_) additive 
*!*				endif
		lcDirA_ = m.lcDirAB + 'aw\'
		if Directory(m.lcDirA_)
			set path to (m.lcDirA_) additive 
		endif
	ENDIF

	* {fr} Si ce n'est pas un serveur d'automation
	&& {en} VFP implicitly performs a SET PROCEDURE and a SET CLASSLIB to the entire server by default when you instantiate an .exe or .dll COM server
	IF NOT InList(_VFP.StartMode;
		, 2; && {en} VFP was started as an out-of-process .exe automation server
		, 3; && {en} VFP was started as an in-process .dll automation server
		, 5; && {en} VFP was started as an in-process .dll automation server for multithreaded use
		)

		SET PROCEDURE TO &lcFXPs ADDITIVE
			
		IF lTrue(m.tlGAno)
			RELEASE PROCEDURE abGA
		ENDIF

		declare short GetKeyState in User32.dll; && modify file abDev.h
			integer vKey

		declare integer ShellExecute IN Shell32.dll; && {en} If the function succeeds, it returns a value greater than 32
	      integer nWinHandle; && {en} A handle to the parent window used for displaying a UI or error messages. This value can be NULL if the operation is not associated with a window.
	    , string cOperation;
	    	; && {en} edit: Launches an editor and opens the document for editing. If lpFile is not a document file, the function will fail.
				; && {en} explore: Explores a folder specified by lpFile.
				; && {en} find: Initiates a search beginning in the directory specified by lpDirectory.
				; && {en} open: Opens the item specified by the lpFile parameter. The item can be a file or folder.
				; && {en} print: Prints the file specified by lpFile. If lpFile is not a document file, the function fails.
				; && {en} NULL: The default verb is used, if available. If not, the "open" verb is used. If neither verb is available, the system uses the first verb listed in the registry.
	    , string cFileName; && {en} file or object on which to execute the specified verb
	    , string cParameters; && {en} parameters to be passed to the application
	    , string cDirectory; && {en} default (working) directory for the action. If this value is NULL, the current working directory is used
	    , integer nShowWindow && {en} how an application is to be displayed when it is opened (see abDev.h)

		IF .T.;
		 and File('aw.vcx'); && {fr} exclu d'awAdapter.pjx/app
		 and ! '\AW.VCX' $ Set("Classlib")
			LOCAL lcAW
			lcAW = 'aw.vcx' && {fr} évite d'embarquer aw.vcx dans le projet
			SET CLASSLIB TO (m.lcAW) ADDITIVE
		ENDIF
	ENDIF

	declare Sleep in win32API Integer && 2016-03-24 thn -- {en} added
	
	SET COMPATIBLE OFF && {fr} Très important pour array = <value> (abArray.prg et autres)
ENDIF

* --------------------------------------------------
PROCEDURE AB_test && {fr} teste AB()

LOCAL loTest as abUnitTest OF abDev.prg
loTest = NewObject('abUnitTest', 'abDev.prg')

loTest.Test(.T.)

RETURN loTest.Result()

* --------------------------------------------------
PROCEDURE AB_Tests && {fr} teste les modules de la classe AB

local success as Boolean;
, loAsserts as abSet of abDev.prg;
, laPrg[1], lcPrg

success = aABprgs(laPrg) > 0
if m.success

	CLEAR
	loAsserts = abSet('ASSERTS', 'OFF')
	for each lcPrg in m.laPrg
		success = Evaluate(JustStem(m.lcPrg) + '()') and m.success
	endfor
endif

wait clear
return m.success
endproc

* =================================
function aABprgs(aABprgs, lFXPs) && {fr} fichiers *.prg|fxp de la classe ab
external array aABprgs
return ALines(aABprgs, cABprgs(m.lFXPs), 5, ',')
endfunc

* =================================
FUNCTION cABprgs(lFXPs) && {fr} fichiers *.prg|fxp de la classe ab

local lcResult

lcResult = 'ab.prg';
	+	', abArray.prg';
	+	', abData.prg';
	+	', abDate.prg';
	+	', abDev.prg';
	+	', abFile.prg';
	+	', abGA.prg';
	+	', abOffice.prg';
	+	', abOOP.prg';
	+	', abTxt.prg';
	+	', awPublic.prg';
	;
	+	Iif(File('abModule.prg'), ', abModule.prg', '');

return Iif(Vartype(m.lFXPs) == 'L' and m.lFXPs; && {fr} lTrue() indisponible
	, Strtran(m.lcResult, '.prg', '.fxp');
	, m.lcResult;
	)

external procedure ab.prg; && {fr} for project manager
	, abArray.prg;
	, abData.prg;
	, abDate.prg;
	, abDev.prg;
	, abFile.prg;
	, abGA.prg;
	, abOffice.prg;
	, abOOP.prg;
	, abTxt.prg;
	, awPublic.prg

endfunc

* =================================
FUNCTION cABhs && {fr} fichiers *.h de la classe ab

return 'ab.h';
	+	', abDev.h';
	+	', abData.h';
	+	', abFile.h';
	+	', abOffice.h';
	+	', abTxt.h';
	+	', awPublic.h';
	+	', ga_.h'; && {fr} pour ga*.prg

* =================================
function aABsrce(aABsrce) && {fr} fichiers source de la classe ab
external array aABsrce
return ALines(aABsrce, cWords(',', cABhs(), cABprgs()), 5, ',')
endfunc

* =================================
FUNCTION cABothers && {fr} autres fichiers de la classe ab

return ' aw.vcx';
		+	', aw.vct';
		+	', awGenMenu.prg';
		+	', european.mem'; && {fr} nécessaire
		+	', Graphics\aw.ico';
		+	', Graphics\indicator_remembermilk_orange.gif';
		+	', Graphics\exclamation64.png';
		+	', Graphics\info64.png';
		+	', Graphics\question64.png';
		+	', Graphics\standby64.png';
		+	', Graphics\folder.png';
		+	', Graphics\folder_image.png';
		+	', Graphics\folder_table.png';
		+	', Graphics\arrows-gray-gray.png';
		+	', Graphics\arrows-black-gray.png';
		+	', Graphics\arrows-gray-black.png';
		+	', Graphics\arrowdoubleleft.png';
		+	', Graphics\arrowdoubleright.png';
		+	', Graphics\refreshblue32.png';
		+	', Graphics\prefirst.png';
		+	', Graphics\prelast.png';
		+	', Graphics\preprev.png';
		+	', Graphics\prenext.png';


* =================================
FUNCTION aABfile && {fr} Fichiers de la classe ab
LPARAMETERS aABfile && @ {fr} Fichiers de la classe ab
external array aABfile

RETURN Iif(aClear(@m.aABfile);
	, ALines(aABfile;
		, cWords(',', cABhs(), cABprgs(), cABothers());
		, 1;
		, ',';
		);
	, 0)


* =================================
#IF .F. && {fr} copier coller dans modify command awOOP.prg > awAdapter.Adapt_abSrceCopy()

EXTERNAL FILE; && {fr} pour avoir le code source même si l'app est encrypté
			ab.h;
		, abdev.h;
		, abdata.h;
		, abfile.h;
		, abOffice.h;
		, abtxt.h;
		, awPublic.h;
		, ga_.h; && {fr} pour ga*.prg
		;
		, ab.prg;
		, abArray.prg;
		, abData.prg;
		, abDate.prg;
		, abDev.prg;
		, abFile.prg;
		, abGA.prg;
		, abOffice.prg;
		, abOOP.prg;
		, abTxt.prg;
		, awPublic.prg;
		;
		, awCopy.vcx; && {fr} pour éviter conflit de nom avec class designer
		, awCopy.vct; && {fr} pour éviter conflit de nom avec class designer
		, european.mem; && {fr} nécessaire
		, Graphics\aw.ico;
		, Graphics\exclamation64.png;
		, Graphics\indicator_remembermilk_orange.gif;
		, Graphics\info64.png;
		, Graphics\question64.png;
		, Graphics\standby64.png;
		, Graphics\folder.png;
		, Graphics\folder_image.png;
		, Graphics\folder_table.png;
		, Graphics\arrows-gray-gray.png;
		, Graphics\arrows-black-gray.png;
		, Graphics\arrows-gray-black.png;
		, Graphics\arrowdoubleleft.png;
		, Graphics\arrowdoubleright.png;
		, Graphics\refreshblue32.png;
		, Graphics\prefirst.png;
		, Graphics\prelast.png;
		, Graphics\preprev.png;
		, Graphics\prenext.png;

#ENDIF
* ========================================
PROCEDURE PathesRemove && {fr} Retire des dossiers du Set('Path')
LPARAMETERS ;
  taFolder; && @ {fr} Dossiers
, tlRelative && [.F.] {fr} Supprimer en relatif au dossier par défaut

RETURN PathesAdd(@m.taFolder, .T., m.tlRelative)

* ========================================
PROCEDURE PathRemove && {fr} Retire un dossier du Set('Path') - 9 ms
LPARAMETERS ;
  tcFolder; && {fr} Dossier @: Addbs(FullPath(m.tcFolder)) si existant
, tlRelative && [.F.] {fr} Supprimer en relatif au dossier par défaut

RETURN PathAdd(m.tcFolder, .T., m.tlRelative)

* ========================================
PROCEDURE PathesAdd && {fr} Ajoute des dossier à Set('Path')
LPARAMETERS ;
  taFolder; && @ {fr} Dossiers
, tlRemove; && [.F.] {fr} Supprimer du path
, tlRelative; && [.F.] {fr} Ajouter en relatif au dossier par défaut
, tlPrepend && [.F.] {fr} Ajouter au début de Set('PATH')
EXTERNAL ARRAY taFolder

LOCAL lcFolder, lnResult

lnResult = 0

IF Type('taFolder', 1) == 'A'

	FOR EACH lcFolder IN m.taFolder

		lnResult = m.lnResult + Iif(PathAdd(;
				m.lcFolder;
			, m.tlRemove;
			, m.tlRelative;
			, m.tlPrepend;
			), 1, 0)

	ENDFOR
ENDIF

RETURN m.lnResult

* ========================================
PROCEDURE PathAdd && {fr} Set('Path') : ajoute / supprime un dossier - 1-3 ms
LPARAMETERS ;
  tcFolder; && {fr} Dossier @: Addbs(FullPath(m.tcFolder)) si existant
, tlRemove; && [.F.] {fr} Supprimer du path
, tlRelative; && [.F.] {fr} Ajouter en relatif au dossier par défaut
, tlPrepend; && [.F.] {fr} Ajouter au début de Set('PATH')

LOCAL llResult; && {fr} Le dossier a été ajouté/retiré à Set('Path')
, llFolder;
, lcPath, laPath[1], lnPath

IF Vartype(m.tcFolder) == 'C'
	tlRemove = lTrue(m.tlRemove) && AND m.llFolder && 2016-05-27 thn -- {FiC V 2.21.1-beta.6} {en} 

	tcFolder = Addbs(Iif(lTrue(m.tlRelative);
			, '.\' + Sys(2014, m.tcFolder); && {fr} Minimum Path to current directory
			, FullPath(m.tcFolder);
			))

	ALines(laPath, Set("Path"), 1, ';')
	llFolder = Ascan(laPath, m.tcFolder, 1, -1, 1, 6) > 0 && {fr} le dossier demandé est dans Set('Path') && tous upper()

	IF m.tlRemove and m.llFolder OR !m.llFolder and Directory(m.tcFolder)

		lcPath = cListOfArray(@m.laPath, ';',,,,,,.T.) + ';'
		lcPath = ICase(;
			m.tlRemove,;
				Strtran(m.lcPath, m.tcFolder + ';'),;
			lTrue(m.tlPrepend),;
				m.tcFolder + ';' + m.lcPath,;
				m.lcPath + m.tcFolder + ';';
			)
		lnPath = Lenc(m.lcPath)
		llResult = m.lnPath <= 4095 && {fr} SET PATH is limited to a maximum of 4095 characters
		ASSERT m.llResult MESSAGE cAssertMsg(Textmerge(ICase(;
			cLangUser() = 'fr',	[Path trop long (<<m.lnPath>> caractères > 4095 limite), impossible de le régler SET PATH TO <<cTronc(m.lcPath)>>],; && copy-paste this line to add another language support
													[Path is too long (<<m.lnPath>> characters > 4095 limitation), cannot SET PATH TO <<cTronc(m.lcPath)>>];
			)))
		IF m.llResult
* assert !'"' $ m.lcPath
			SET PATH TO (Leftc(m.lcPath, Lenc(m.lcPath)-1)) && {fr} ôte le ';' final
		ELSE
			llResult = .null.
		ENDIF
	ENDIF
ENDIF

RETURN m.llResult

* --------------------------------------------------
PROCEDURE PathAdd_test && {fr} teste PathAdd()

LOCAL loTest as abUnitTest OF abDev.prg
loTest = NewObject('abUnitTest', 'abDev.prg')

loTest.Test(.F., cModuleInfo(Sys(16), 'Path'))
loTest.Test(.F., 'toto')

RETURN loTest.Result()

* ========================================
PROCEDURE PathAddSubFolders && {fr} Ajoute un dossier et ses sous-dossiers au Set('Path')
LPARAMETERS ;
  tcFolder; && {fr} Dossier @: Addbs(FullPath(m.tcFolder)) si existant
, tnLevel; && [1] {fr} Profondeur des sous-dossiers
, tcFoldersExcl; && [''] {fr} sous-dossiers à exclure ou masque des fichiers attendus dans les dossiers à inclure
, tlRemove; && [.F.] {fr} Supprimer du path
, tlRelative && [.F.] {fr} Ajouter en relatif au dossier par défaut
tnLevel = Evl(m.tnLevel, 1)

LOCAL llResult, laFolder[1], lcFolder

llResult = !IsNull(PathAdd(@m.tcFolder, m.tlRemove, m.tlRelative))
IF m.llResult and aSubFolders(@m.laFolder, m.tcFolder, m.tcFoldersExcl, m.tnLevel, .T.) > 0
	FOR EACH lcFolder IN laFolder
		if IsNull(PathAdd(m.lcFolder, m.tlRemove, m.tlRelative))
			llResult = .F.
			exit
		endif
	endfor
endif

ASSERT m.llResult MESSAGE cAssertMsg(Textmerge(ICase(;
	cLangUser() = 'fr',	[Echec, la profondeur de l'arborescence (<<m.tnLevel>>) est peut-être trop élevée],; && copy-paste this line to add another language support
											[Failure, directory depth (<<m.tnLevel>>) may be too high];
	)))

RETURN m.llResult
endproc

* =================================
FUNCTION abPathesAdd && {fr} Ajoute des dossiers à Set('Path') et rétablit Set('Path') au .Destroy()
LPARAMETERS ;
  tvFolders; && {fr} Dossier(s) - @ tableau (array) ou liste délimitée
, tlRelative; && [.F.] {fr} Ajouter en relatif au dossier par défaut
, tlPrepend; && [.F.] {fr} Ajouter au début de Set('PATH')
, tcResult && @ [''] {fr} Erreur éventuelle

RETURN CreateObject('abPathesAdd', @m.tvFolders, m.tlRelative, m.tlPrepend, @m.tcResult)

* =================================
DEFINE CLASS abPathesAdd AS Relation && {fr} Ajoute des dossiers à Set('Path') et rétablit Set('Path') au .Destroy()

HIDDEN cPath
cPath = Set("Path")	

* ---------------------------------
PROCEDURE Init
LPARAMETERS ;
  tvFolders; && {fr} Dossier(s) - @ tableau (array) ou liste délimitée
, tlRelative; && [.F.] {fr} Ajouter en relatif au dossier par défaut
, tlPrepend; && [.F.] {fr} Ajouter au début de Set('PATH')
, tcResult && @ [''] {fr} Erreur éventuelle

LOCAL laFolder[1], llResult

llResult = .T.

DO CASE
CASE Type('tvFolders', 1) == 'A'
	Acopy(tvFolders, laFolder)
CASE Vartype(m.tvFolders) == 'C'
	ALines(laFolder, m.tvFolders, 5, ',', ';')
OTHERWISE
	llResult = .F.
ENDCASE
IF m.llResult

	llResult = NOT laEmpty(@m.laFolder)
	IF m.llResult

		RETURN PathesAdd(;
				@m.laFolder;
			, ; && {fr} m.tlRemove
			, m.tlRelative;
			, m.tlPrepend;
			) > 0
	ENDIF
ENDIF

tcResult = Textmerge(ICase(;
	cLangUser() = 'fr',	[Spécification de dossiers invalide : <<cLitteral(m.tvFolders)>>],; && copy-paste this line to add another language support
											[Invalid folders specification: <<cLitteral(m.tvFolders)>>];
	))

RETURN .F.

* ---------------------------------
PROCEDURE Destroy

SET PATH TO (m.this.cPath)

ENDDEFINE && {fr} CLASS abPathesAdd
* =================================

* =================================
DEFINE CLASS abPathAddSubFolders AS abPathesAdd OF ab.prg

* ---------------------------------
PROCEDURE Init
LPARAMETERS ;
  tcFolder; && {fr} Dossier @: Addbs(FullPath(m.tcFolder)) si existant
, tnLevel; && [1] {fr} Profondeur des sous-dossiers
, tcFoldersExcl; && [''] {fr} sous-dossiers à exclure ou masque des fichiers attendus dans les dossiers à inclure ou masque des fichiers attendus dans les dossiers à inclure
, tlRemove; && [.F.] {fr} Supprimer du path
, tlRelative && [.F.] {fr} Ajouter en relatif au dossier par défaut

RETURN PathAddSubFolders(;
		m.tcFolder;
	, m.tnLevel;
	, m.tcFoldersExcl;
	, m.tlRemove;
	, m.tlRelative;
	)

ENDDEFINE && {fr} CLASS abPathAddSubFolders
* =================================

* =================================
FUNCTION nUnit	&& {fr} Unité d'un nombre
LPARAMETERS tn && {fr} Nombre
RETURN Int(m.tn) - Int(m.tn/10) * 10

* ---------------------------------
PROCEDURE nUnit_Test
LOCAL loTest AS abUnitTest
loTest = NewObject('abUnitTest', 'abDev.prg')

loTest.Test(2, 002.2)
loTest.Test(2, 052.0)
loTest.Test(2, 052.2)

RETURN loTest.Result()

* =================================
FUNCTION nDiz	&& {fr} Dizaine d'un nombre
LPARAMETERS tn && {fr} Nombre
RETURN nUnit(Int(m.tn/10))

* ---------------------------------
PROCEDURE nDiz_Test

LOCAL loTest AS abUnitTest
loTest = NewObject('abUnitTest', 'abDev.prg')

loTest.Test(0, 002)
loTest.Test(5, 052)
loTest.Test(5, 252)

RETURN loTest.Result()

* =================================
FUNCTION nCent && {fr} Centaine d'un nombre
LPARAMETERS tn && {fr} Nombre
RETURN nUnit(Int(m.tn/100))

* ---------------------------------
PROCEDURE nCent_Test

LOCAL loTest AS abUnitTest
loTest = NewObject('abUnitTest', 'abDev.prg')

loTest.Test(0, 0052)
loTest.Test(0, 1052)
loTest.Test(2, 0252)
loTest.Test(2, 5252)

RETURN loTest.Result()

* =================================
FUNCTION nR_nG_nB && {fr} Composants R G et B d'une couleur (merci Mike Gagnon)
LPARAMETERS ;
  nRGB; && {fr} Valeur RGB
, nR; && @ {fr} Composante Rouge
, nG; && @ {fr} Composante Verte
, nB && @ {fr} Composante Bleue

nR = Bitand(0xff, m.nRGB)
nG = Bitand(0xff, Bitrshift(m.nRGB, 8))
nB = Bitand(0xff, Bitrshift(m.nRGB, 16))

* =================================
FUNCTION cRGB && {fr} Composants "R,G,B" d'une couleur
LPARAMETERS nRGB && {fr} Valeur RGB

LOCAL nR; && @ {fr} Composante Rouge
, nG; && @ {fr} Composante Verte
, nB && @ {fr} Composante Bleue

nR_nG_nB(m.nRGB, @m.nR, @m.nG, @m.nB)

RETURN cWords(',', lTrim(Str(m.nR)), lTrim(Str(m.nG)), lTrim(Str(m.nB)))

* =================================
FUNCTION cRGBhex && {fr} RGB en #hex
LPARAMETERS nRGB && {fr} Valeur RGB
return '#' + Right(Transform(m.nRGB, '@0'), 6)

* =================================
FUNCTION cRGBhex_ && {fr} RGB en #hex
lparameters ;
  nR; && @ {fr} Composante Rouge
, nG; && @ {fr} Composante Verte
, nB && @ {fr} Composante Bleue

return cRGBhex(Rgb(m.nR, m.nG, m.nB))

******************************************************************************************
FUNCTION ImgSpecs && {fr} Propriétés d'une image
LPARAMETERS ;
  tcImgAddr; && {fr} Adresse de l'image
, tnXmm; && @ {fr} Largeur en mm
, tnYmm; && @ {fr} Hauteur en mm
, tnXPix; && @ {fr} Largeur en pixels
, tnYPix; && @ {fr} Hauteur en pixels
, tnXRes; && @ {fr} Résolution X en pixels
, tnYRes; && @ {fr} Résolution Y en pixels
, tnImgType; && @ {fr} Type de l'image - 0: inconnu | 1: trait ou CMJN | 2: NG 4 bits | 3: NG 8 bits | 4: Palette 4 bits | 5: Palette 8 bits | 6: 24 bits RGB | 7:24 bits BGR
, tcImgType && @ {fr} Type de l'image en clair

RETURN .T.;
	AND lFile(m.tcImgAddr);
	AND Iif(Version(5) >= 900;
		, ImgSpecsGDIPlus(m.tcImgAddr, @tnXmm, @tnYmm, @tnXPix, @tnYPix, @tnXRes, @tnYRes, @tnImgType, @tcImgType);
		, ImgSpecsKodak(m.tcImgAddr, @tnXmm, @tnYmm, @tnXPix, @tnYPix, @tnXRes, @tnYRes, @tnImgType, @tcImgType);
		)

******************************************************************************************
FUNCTION ImgSpecsKodak && {fr} Propriétés de l'image avec le contrôle ActiveX Imaging.AdminCtrl.1
LPARAMETERS ;
  tcImgAddr; && {fr} Adresse de l'image
, tnXmm; && @ {fr} Largeur en mm
, tnYmm; && @ {fr} Hauteur en mm
, tnXPix; && @ {fr} Largeur en pixels
, tnYPix; && @ {fr} Hauteur en pixels
, tnXRes; && @ {fr} Résolution X en pixels
, tnYRes; && @ {fr} Résolution Y en pixels
, tnImgType; && @ {fr} Type de l'image - 0: inconnu | 1: trait ou CMJN | 2: NG 4 bits | 3: NG 8 bits | 4: Palette 4 bits | 5: Palette 8 bits | 6: 24 bits RGB | 7:24 bits BGR
, tcImgType && @ {fr} Type de l'image en clair

LOCAL lcExt, llResult

* {fr} Si l'extension de l'image est valide
lcExt = Upper(JustExt(m.tcImgAddr))
llResult = Len(m.lcExt) = 3 AND m.lcExt $ 'BMP,JPG,JPE,TIF,PCX,GIF'
ASSERT m.llResult MESSAGE Program() + " - Extension non supportée : " + cLitteral(m.lcExt)
IF m.llResult

	* {fr} Si le contrôle Activex peut être instancié (dans un formulaire car impossible d'instancier dans une variable)
	LOCAL loFooForm
	loFooForm = CreateObject('Form')
	llResult = loFooForm.addObject('oleFooCtrl', 'oleControl','Imaging.AdminCtrl.1')
	ASSERT m.llResult MESSAGE Program() + " - Impossible d'instancier le contrôle Imaging.AdminCtrl.1"
	IF m.llResult
		WITH m.loFooForm.oleFooCtrl as Imaging.AdminCtrl.1

			* {fr} Si l'image peut être lue
			LOCAL lcError
			lcError = On('ERROR')
			ON ERROR m.llResult = .F.
			.Image = m.tcImgAddr
			ON ERROR &lcError
			ASSERT m.llResult MESSAGE Program() + " - Impossible d'ouvrir l'image " + cLitteral(m.tcImgAddr)
			IF m.llResult

				* {fr} Si les propriétés de l'image sont valides (retour de l'activeX)
				tnXPix = .ImageWidth
				tnYPix = .ImageHeight
				llResult = Vartype(m.tnXPix) == 'N' AND Vartype(m.tnYPix) == 'N' AND m.tnXPix > 0 AND m.tnYPix > 0
				ASSERT m.llResult MESSAGE Program() + " - L'image ne semble avoir aucun pixel" + cLitteral(m.tcImgAddr)
				IF m.llResult

					tnXRes = .ImageResolutionX
					tnYRes = .ImageResolutionY
					tnXmm = (m.tnXPix/m.tnXRes)*25.4
					tnYmm = (m.tnYPix/m.tnYRes)*25.4
					tnImgType = .PageType
					tcImgType = cImgTypeKodak(m.tnImgType)
				ENDIF
			ENDIF
		ENDWITH
	ENDIF
ENDIF

RETURN m.llResult

******************************************************************************************
FUNCTION cImgTypeKodak && {fr} Type d'image Kodak en clair
LPARAMETERS tnImgType && {fr} Code Type d'image Kodak
LOCAL lcResult
lcResult = "Type d'image non numérique"

IF Vartype(m.tnImgType) == 'N'
	DO CASE
	Case m.tnImgType = 0
		lcResult = 'Inconnu'
	Case m.tnImgType = 1
		lcResult = 'Trait ou CMJN'
	Case m.tnImgType = 2
		lcResult = '16 niveaux de gris'
	Case m.tnImgType = 3
		lcResult = '256 niveaux de gris'
	Case m.tnImgType = 4
		lcResult = '16 couleurs'
	Case m.tnImgType = 5
		lcResult = '256 couleurs'
	Case m.tnImgType = 6
		lcResult = '16 millions de couleurs RVB'
	Case m.tnImgType = 7
		lcResult =  '16 millions de couleurs BVR'
	OTHERWISE
		lcResult = "Non supporté par le contrôle Kodak : " + Transform(m.tnImgType)
	ENDCASE
ENDIF

RETURN m.lcResult

******************************************************************************************
FUNCTION ImgSpecsGDIPlus && {fr} Propriétés de l'image avec GDI+
LPARAMETERS ;
  tcImgAddr; && {fr} Adresse de l'image
, tnXmm; && @ {fr} Largeur en mm
, tnYmm; && @ {fr} Hauteur en mm
, tnXPix; && @ {fr} Largeur en pixels
, tnYPix; && @ {fr} Hauteur en pixels
, tnXRes; && @ {fr} Résolution X en pixels
, tnYRes; && @ {fr} Résolution Y en pixels
, tnImgType; && @ {fr} Type de l'image - 0: inconnu | 1: trait ou CMJN | 2: NG 4 bits | 3: NG 8 bits | 4: Palette 4 bits | 5: Palette 8 bits | 6: 24 bits RGB | 7:24 bits BGR
, tcImgType && @ {fr} Type de l'image en clair

LOCAL loGDI AS gpImage OF _GDIplus.vcx, llResult

* {fr} Si le fichier existe
llResult = Vartype(m.tcImgAddr) == 'C' AND File(m.tcImgAddr)
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge(ICase(;
	cLangUser() = 'fr',	[L'image '<<m.tcImgAddr>>' est introuvable],; && copy-paste this line to add another language support
											[Could not find image '<<m.tcImgAddr>>']; && default: English
)))
IF m.llResult

	* {fr} Si le contrôle GDI+ peut être instancié
	loGDI = NewObject('gpImage', '_GDIplus.vcx')
	llResult = Vartype(m.loGDI) == 'O'
	ASSERT m.llResult MESSAGE cAssertMsg(Textmerge(ICase(;
			cLangUser() = 'fr',	[Impossible de créer l'objet GDI+],; && copy-paste this line to add another language support
													[Could not create GDI+ object]; && default: English
		)))

	IF m.llResult
		WITH loGDI as gpImage OF _GDIplus.vcx

			* {fr} Si l'image peut être ouverte
			tcImgAddr = cFileCased(m.tcImgAddr, .T.)
			llResult = .CreateFromFile(m.tcImgAddr)
			ASSERT m.llResult MESSAGE cAssertMsg(Textmerge(ICase(;
				cLangUser() = 'fr',	[GDI+ n'a pas pu décoder l'image '<<m.tcImgAddr>>'],; && copy-paste this line to add another language support
														[GDI+ could not read image '<<m.tcImgAddr>>']; && default: English
			)))
			IF m.llResult

				* {fr} Si les propriétés de l'image sont valides
				tnXPix = .ImageWidth
				tnYPix = .ImageHeight
				llResult = Vartype(m.tnXPix) == 'N' AND Vartype(m.tnYPix) == 'N' AND m.tnXPix > 0 AND m.tnYPix > 0
				ASSERT m.llResult MESSAGE cAssertMsg(Textmerge(ICase(;
					cLangUser() = 'fr',	[L'image '<<m.tcImgAddr>>' ne semble avoir aucun pixel],; && copy-paste this line to add another language support
															[No pixel found in Image '<<m.tcImgAddr>>']; && default: English
					)))
				IF m.llResult

					tnXRes = .HorizontalResolution
					tnYRes = .VerticalResolution
					tnXmm = (m.tnXPix/m.tnXRes)*25.4
					tnYmm = (m.tnYPix/m.tnYRes)*25.4
					tnImgType = .pixelFormat
					tcImgType = cImgTypeGDIPlus(m.tnImgType)
				ENDIF
			ENDIF
		ENDWITH
	ENDIF
ENDIF

RETURN m.llResult

******************************************************************************************
FUNCTION cImgTypeGDIPlus && {fr} Type d'image GDI+ en clair
LPARAMETERS tnImgType && {fr} Code Type d'image GDI+

LOCAL lcResult
lcResult = "Type d'image non numérique"

IF Vartype(m.tnImgType) == 'N'
	lcResult = ICase(.F., ''; && modify file Home(1) + "ffc\gdiplus.h"
		, m.tnImgType =	GDIplus_pixelFormat_Indexed, 'Indexé avec palette';
		, m.tnImgType =	GDIplus_pixelFormat_GDI, 'GDI';
		, m.tnImgType =	GDIplus_pixelFormat_Alpha, 'Couche Alpha';
		, m.tnImgType =	GDIplus_pixelFormat_PAlpha, 'Couche Alpha pré-multipliée';
		, m.tnImgType =	GDIplus_pixelFormat_Extended, 'Étendu 16 bits par couche';
		, m.tnImgType =	GDIplus_pixelFormat_Canonical, 'Canonique';
		, m.tnImgType =	GDIplus_pixelFormat_1bppIndexed, 'N&B indexé';
		, m.tnImgType =	GDIplus_pixelFormat_4bppIndexed, '16 niveaux de gris';
		, m.tnImgType =	GDIplus_pixelFormat_8bppIndexed, '256 niveaux de gris';
		, m.tnImgType =	GDIplus_pixelFormat_16bppGrayScale, '65536 niveaux de gris';
		, m.tnImgType =	GDIplus_pixelFormat_16bppRGB555, 'RGB 65536 couleurs 555';
		, m.tnImgType =	GDIplus_pixelFormat_16bppRGB565, 'RGB 65536 couleurs 565';
		, m.tnImgType =	GDIplus_pixelFormat_16bppARGB1555, 'RGB 65536 couleurs avec couche Alpha';
		, m.tnImgType =	GDIplus_pixelFormat_24bppRGB, 'RGB 16777216 couleurs avec couche Alpha';
		, m.tnImgType =	GDIplus_pixelFormat_32bppRGB, 'RGB 4294967296 couleurs';
		, m.tnImgType =	GDIplus_pixelFormat_32bppARGB, 'RGB 4294967296 couleurs avec couche Alpha';
		, m.tnImgType =	GDIplus_pixelFormat_32bppPARGB, 'RGB 4294967296 couleurs avec couche Alpha pré-multipliée';
		, m.tnImgType =	GDIplus_pixelFormat_48bppRGB, 'RGB 48 bits';
		, m.tnImgType =	GDIplus_pixelFormat_64bppPARGB, 'RGB 64 bits avec couche Alpha pré-multipliée';
		, "Non supporté par le contrôle GDI+ : " + Transform(m.tnImgType))
ENDIF

RETURN m.lcResult

******************************************************************************************
function ImgCropToRatio && {en} adapted from http://weblogs.foxite.com/vfpimaging/2006/05/25/crop-images-with-gdi/
lparameters ;
  result; && @ {en} result
, cImgSrce;
, cImgDest; && @ 
, tnWH && [1] {en} Width / Height ratio

cImgDest = ForceExt(Evl(m.cImgDest, m.cImgSrce), 'png')
tnWH = Evl(m.tnWH, 1) && {fr} square

local success as Boolean;
, oImage as gpImage of _GDIplus.vcx;
, oCropped as GPbitmap of _GDIplus.vcx;
, nWidth;
, nHeight;
, lW;
, x, y;
, nHandle

oImage = NewObject("gpImage", "_GDIplus.vcx")
oCropped = NewObject("GPbitmap", "_GDIplus.vcx")

success = .F.;
 or File(m.cImgSrce) and oImage.CreateFromFile(m.cImgSrce);
 or cResultAdd(@m.result, Textmerge([could not open image '<<m.cImgSrce>>']))
if m.success
	
	nWidth = m.oImage.imageWidth
	nHeight = m.oImage.imageHeight

	lW = m.nWidth / m.nHeight > m.tnWH && {fr} width must be adjusted

	nWidth = Iif(m.lW;
		, m.nHeight * m.tnWH;
		, m.nWidth;
		)
	x = Iif(m.lW;
		, (m.oImage.imageWidth - m.nWidth) / 2;
		, 0;
		)

	nHeight = Iif(m.lW;
		, m.nHeight;
		, m.nWidth / m.tnWH;
		)
	y = Iif(m.lW;
		, 0;
		, (m.oImage.ImageHeight - m.nHeight) / 2;
		)

	* {fr} gpstatus wingdipapi GdipCloneBitmapAreaI
	* (int x, int y, int width, int height, pixelFormat format, GPbitmap *srcbitmap, GPbitmap **dstbitmap)
	declare long GdipCloneBitmapAreaI in GDIplus.dll ;
	   long x, long y, long nwidth, long nheight, ;
	   long pixelFormat, long srcbitmap, long @dstbitmap

	nHandle = 0
	= GdipCloneBitmapAreaI(m.x, m.y, m.nWidth, m.nHeight, m.oImage.pixelFormat, m.oImage.getHandle(), @m.nHandle)

	success = .T.;
	 and (Vartype(m.nHandle) == 'N' or cResultAdd(@m.result, Textmerge([GdipCloneBitmapAreaI() failed to crop '<<m.cImgSrce>>' from x=<<m.x>>, y=<<m.y>> by w=<<m.nWidth>>px, h=<<m.nHeight>>px])));
	 and (m.oCropped.setHandle(m.nHandle) or cResultAdd(@m.result, Textmerge([Could not copy cropped image into destination image])));
	 and (m.oCropped.SaveToFile(m.cImgDest, 'image/png') or cResultAdd(@m.result, Textmerge([Could not save cropped image into '<<m.cImgDest>>' as png])))
endif

assert m.success message cAssertMsg(m.result)

return m.success

endfunc

******************************************************************************************
function ImgResize && {en} adapted from http://weblogs.foxite.com/vfpimaging/2006/02/06/resize-images-with-vfp9-and-gdi/
lparameters ;
  result; && @ {en} result
, cImgSrce;
, cImgDest; && @ [overwrite cImgSrce]
, tnWidth; && {fr} pixels
, tnHeight; && [isometric] {fr} pixels
, tlBox; && [.F.] {en} image should fit inside a box of tnWidth x tnHeight

cImgSrce = Evl(m.cImgSrce, '')

local success as Boolean;
, oImage as gpImage of _GDIplus.vcx;
, oResized as gpImage of _GDIplus.vcx;
, qFormat;
, nRatio as number;

oImage = NewObject('gpImage', '_GDIplus.vcx')

success = .T.;
 and (File(m.cImgSrce) or cResultAdd(@m.result, Textmerge([image '<<m.cImgSrce>>' can't be found])));
 and (Vartype(m.tnWidth) == 'N' and m.tnWidth > 0 or cResultAdd(@m.result, Textmerge([width '<<m.tnWidth>>' should be defined])));
 and (m.oImage.CreateFromFile(m.cImgSrce) or cResultAdd(@m.result, Textmerge([could not open image '<<m.cImgSrce>>'])));
 and varStore(@m.cImgDest, Evl(m.cImgDest, m.cImgSrce));
 and .T.
if m.success && {fr} and m.tnWidth < m.oImage.ImageWidth
	
	if lTrue(m.tlBox)
		
		success = .F.;
			or Vartype(m.tnHeight) == 'N' and m.tnHeight > 0;
			or cResultAdd(@m.result, Textmerge([To fit image '<<m.cImgSrce>>' in a box, you need to specify the box height in pixels.]))
		if m.success

			nRatio = Iif(m.oImage.ImageWidth / m.oImage.ImageHeight > m.tnWidth / m.tnHeight;
				, m.tnWidth / m.oImage.ImageWidth;
				, m.tnHeight / m.oImage.ImageHeight;
				)
			tnWidth = m.oImage.ImageWidth * m.nRatio
			tnHeight = m.oImage.ImageHeight * m.nRatio
		endif
	else
		tnHeight = Evl(m.tnHeight, m.tnWidth * m.oImage.ImageHeight / m.oImage.ImageWidth)
	endif
	
	success = m.success;
	 and varSet(@m.oResized, m.oImage.getThumbNailImage(Int(m.tnWidth), Int(m.tnHeight)));
	 and (.F.;
		or Vartype(m.oResized) == 'O';
		or cResultAdd(@m.result, Textmerge([ThumbNailImage could not be generated with these dimensions: width = <<Int(m.tnWidth)>> px, height = <<Int(m.tnHeight)>> px]));
		);
	 and (.F.;
		or m.oResized.saveToFile(m.cImgDest, m.oImage.GetEncoderCLSID(m.oImage.RawFormat));
		or cResultAdd(@m.result, Textmerge([Resized image '<<m.cImgDest>>' could not be created]));
		);
	and .T.
endif

assert m.success message cAssertMsg(m.result)
return success

endfunc

******************************************************************************************
function ImgResizeBox && {en} Resize an image so that it fits in a box
lparameters ;
  result; && @ {fr} result
, cImgSrce; && {en} source image
, cImgDest; && @ [overwrite cImgSrce] {en} destination image
, tnWidth; && {fr} pixels max
, tnHeight; && {fr} pixels max

return ImgResize(;
	  @m.result;
	, m.cImgSrce;
	, @m.cImgDest;
	, m.tnWidth;
	, m.tnHeight;
	, .T.;
	)
endfunc

* ? varSet(@m.result, '') and ImgDownsizeBox(@m.result, 'C:\aDossier\3724 MCTG\Client\Recu\STI FIC IPWeb\Graphics\sti_logo_v2.png', 'C:\aDossier\3724 MCTG\Client\Recu\STI FIC IPWeb\Graphics\sti_logo_v2_300_200.png', 300, 100), m.result


* -------------------------------------------------------------
FUNCTION nMMofPX && {fr} Dimension mm papier de pixels écran
LPARAMETERS tnPix && {fr} Nombre de pixels écran
RETURN Iif(Vartype(m.tnPix)=='N' AND m.tnPix > 0;
	, m.tnPix / 96 * 25.4; && 96 pixels/pouce (standard Windows) et 25.4 mm/pouce
	, 0;
	)

* -------------------------------------------------------------
FUNCTION nPXofMM && {fr} Pixels écran de mm papier
LPARAMETERS tnMM && {fr} Dimension en mm papier
RETURN Int(Iif(Vartype(m.tnMM)== 'N' AND m.tnMM > 0;
	, m.tnMM / 25.4 * 96; && 96 pixels/pouce (standard Windows) et 25.4 mm/pouce
	, 0;
	))

* -------------------------------------------------------------
FUNCTION nPXofPt && {fr} Pixels écran de point CSS
LPARAMETERS tnPt && {fr} Dimension en points
RETURN Int(Iif(Vartype(m.tnPt)== 'N' AND m.tnPt > 0;
	, Round(m.tnPt / 72 * 90, 1); && 72 pt /pouce, 96 pixels/pouce (standard Windows) ramené à 90 pour ajuster
	, 0;
	))
