* abFile.prg
* =====================================================
* (c) Abaque SARL, 66 rue Michel Ange - 75016 Paris - France
* contact@FoxInCloud.com - http://www.FoxInCloud.com/ - +33 9 53 41 90 90
* -----------------------------------------------------
* Ce logiciel est distribué sous licence MIT, tel quel, sans aucune garantie
* Il peut être utilisé et/ou redistribué sans restriction
* Toute modification doit être reversée à la communauté
* La présente mention doit être intégralement reproduite
&& dans toute copie même partielle
* -----------------------------------------------------
* This software is distributed under the terms of a MIT-style license, AS IS, without any warranty 
* It may be used and/or distributed without restriction
* Any substantial improvement must be given for free to the community
* This permission notice shall be entirely included in all copies
&& or substantial portions of the Software
* =====================================================

#INCLUDE AB.H
AB()
return abUnitTests()

* ========================================
PROCEDURE ReadOnlyClear	&& Supprime l'attribut 'lecture seule' des fichiers d'un dossier
LPARAMETERS ;
	tcFolder,; && Adresse du dossier
	tcFileSkel && [*.*] masque de fichiers à traiter

LOCAL lnResult && nombre de fichiers traités
lnResult = 0

* Si le dossier existe
IF Vartype(m.tcFolder) == 'C' AND lDir(m.tcFolder)

	LOCAL loFiler AS Filer.FileUtil, loFile, lnAttrib

	* Régler le masque à sa valeur par défaut
	tcFileSkel = Iif(Vartype(m.tcFileSkel) == 'C' AND NOT Empty(m.tcFileSkel), m.tcFileSkel, '*.*')

	* Créer un objet "filer" pour la recherche et la modification des attributs
	loFiler = CreateObject('Filer.FileUtil') && dans VFP\tools\filer\Filer.dll

	* Charger les fichiers répondant au masque
	loFiler.SearchPath = m.tcFolder
	loFiler.FileExpression = m.tcFileSkel
	loFiler.Find (0) && Charge la collection de fichiers

	* Supprimer les attributs 'read-only' éventuels
	FOR EACH loFile IN m.loFiler.Files
		lnAttrib = m.loFile.attr
		IF Mod(m.lnAttrib, 2) > 0 && uneven = read only
			loFile.attr = m.lnAttrib - 1
			lnResult = m.lnResult + 1
		ENDIF
	ENDFOR
ENDIF

RETURN m.lnResult

* ========================================
procedure tFileSet && règle la date et heure d'un fichier
lparameters ;
  result as String; && @ result
, cFile as String;
, tFile as Datetime

local success;
, oException as Exception;
, oShell as Shell.Application;
, oFolder;
, oFile

if .T.;
 and (Vartype(m.cFile) == 'C' or cResultAdd(@m.result, Textmerge([<<m.cFile>> is expected as a String])));
 and (File(m.cFile) or cResultAdd(@m.result, Textmerge([File '<<m.cFile>>' can't be found])));
 and (Vartype(m.tFile) $ 'DT' or cResultAdd(@m.result, Textmerge([<<m.tFile>> is expected as a Date or DateTime])));
 and (!Empty(m.tFile) or cResultAdd(@m.result, Textmerge([<<m.tFile>> is expected not Empty()])))

	try
		oShell = CreateObject("Shell.Application")
		if Vartype(m.oShell) == 'O'

			oFolder = m.oShell.NameSpace(JustPath(FullPath(m.cFile)))
			if Vartype(m.oFolder) == 'O'

				oFile = m.oFolder.ParseName(JustFname(m.cFile))
				if Vartype(m.oFile) == 'O'

					m.oFile.ModifyDate = m.tFile
					success = .T.
				endif
			endif
		endif
	catch to oException
		cResultAdd(@m.result, cException(m.oException))
	endtry
endif

release oFile, oFolder, oShell

=!m.success and cResultAdd(@m.result, Textmerge([Could not set Datetime of file <<cL(m.cFile)>> to <<cL(m.tFile)>>]))

return m.success

* -------------------------------
PROCEDURE tFileSet_Test	&& Teste tFileSet()

LOCAL loTest as abUnitTest of abDev.prg;
, lcFile as String;
, ltFile as Datetime

loTest = NewObject('abUnitTest', 'abDev.prg')
lcFile = Addbs(Sys(2023)) + 'tFileSet_Test.txt'

StrToFile('tFileSet_Test', m.lcFile)
ltFile = Datetime() - 100

loTest.Test(.T., '', m.lcFile, m.ltFile)
loTest.Assert(m.ltFile, Fdate(m.lcFile, 1))

return m.loTest.Result()

* ========================================
PROCEDURE PathCreate as Boolean && Crée un chemin de dossiers
LPARAMETERS ;
	tcPath,; && Chemin
	tcError,; && [''] @ Détails de l'erreur éventuelle
	tcMessage && [''] @ Message d'erreur éventuel

LOCAL llResult as Boolean;
, lcPath;
, lnPath;
, loException AS Exception

tcPath = Iif(Empty(JustExt(m.tcPath)), m.tcPath, JustPath(m.tcPath)) && Supprime le nom de fichier éventuel

do case
case lDir(m.tcPath) && le dossier existe déjà
	return

case !lFullPath(m.tcPath)
	return cResultAdd(@m.tcError, Textmerge(ICase(;
			cLangUser() = 'fr',	['<<m.tcPath>>' devrait être une adresse complète de fichier ou de dossier],; && copy-paste this line to add another language support
													['<<m.tcPath>>' should be a complete file or folder address];
			)))

otherwise

	TRY

		* Pour chaque dossier dans le chemin
		lcPath = Upper(GetWordNum(m.tcPath, 1, '\')) && disk letter
		for lnPath = 2 TO GetWordCount(m.tcPath, '\')
			lcPath = m.lcPath + '\' + GetWordNum(m.tcPath, m.lnPath, '\')
			
			* Si le dossier n'existe pas, créer
			IF NOT lDir(m.lcPath) && {V1.11} Directory(m.lcPath) ne marche pas pour <user>\appdata\
				MD (m.lcPath)
			ENDIF
		endfor
		llResult = .T.

	CATCH TO loException

		llResult = cResultAdd(@m.tcError, cException(m.loException))
		tcMessage = m.loException.Message
		ASSERT .F. MESSAGE m.tcError
		DEBUGOUT m.tcError
	ENDTRY

	return m.llResult

endcase

endproc

* ========================================
PROCEDURE FilesCopy && Copie des fichiers d'un dossier [et ses sous-dossiers] dans un autre dossier
LPARAMETERS ;
  tcFileSkels; && Masques de fichiers à traiter
, tcFolderSrce; && Adresse du dossier où sont les fichiers
, tcFolderDest; && Adresse du dossier destination
, tlSubFolders; && [.F.] Chercher dans les sous-dossiers source
, tcSubFoldersExcl; && [space(0)] Sous-dossiers source à exclure de la recherche (séparés par ',')
, tlKeepExisting; && [.F.] Ne pas remplacer si existe déjà - .NULL. ou autre, ignorer
, tcResult; && [''] @ Détail de l'erreur éventuelle
, tnResult; && [0] @ Nombre de fichiers copiés

local lcResult as String

tcFolderSrce = Addbs(cFileCased(m.tcFolderSrce, .T.))
tcFolderDest = Addbs(Iif(Directory(m.tcFolderDest), cFileCased(m.tcFolderDest, .T.), m.tcFolderDest))

tnResult = FilesProc(;
	  m.tcFolderSrce; && Adresses des dossiers où les fichiers sont à chercher
	, 'FileCopy'; && Procédure à appliquer à chaque fichier trouvé (son premier paramètre est l'adresse du fichier)
	, m.tcFileSkels; && ['*.*'] Masques de fichiers à traiter (séparés par ',')
	, m.tlSubFolders; && [.F.] Chercher dans les sous-dossiers
	, m.tcSubFoldersExcl; && [space(0)] Sous-dossiers à exclure de la recherche (séparés par ',')
	, Textmerge([Stuffc(m.tcFileSrce, 1, Lenc(<<cL(m.tcFolderSrce)>>), <<cL(m.tcFolderDest)>>)]); && Nouvelle adresse (can contain wildcard characters) && @ 2ème paramètre à passer à la procédure (le premier est l'adresse du fichier)
	, @m.lcResult; && [''] @ Détails de l'erreur éventuelle && @ 3ème paramètre à passer à la procédure
	, ; && [''] @ Message d'erreur éventuel && @ 4eme paramètre à passer à la procédure
	, Vartype(m.tlKeepExisting) == 'L' and m.tlKeepExisting; && [.F.] Ne pas remplacer si existe déjà - .NULL. ou autre, ignorer
	)

return Empty(m.lcResult) or cResultAdd(@m.tcResult, m.lcResult)

* ========================================
PROCEDURE FileCopy && Copie un fichier en créant le(s) dossier(s) si nécessaire
LPARAMETERS ;
	tcFileSrce,; && Adresse actuelle (can contain wildcard characters)
	tcFileDest,; && Nouvelle adresse (can contain wildcard characters)
	tcError,; && [''] @ Détails de l'erreur éventuelle
	tcMessage,; && [''] @ Message d'erreur éventuel
	tlKeepExisting && [.F.] Ne pas remplacer si existe déjà - .NULL. ou autre, ignorer

LOCAL llResult; && le fichier a été copié
, lcResult as String;
, lcFileSrce as String;
, lcFileDest as String; && pour éviter remplacement (FilesProc() passe par référence)
, loException AS Exception;

* Si le fichier existe
lcFileSrce = JustFname(m.tcFileSrce)
llResult = '*' $ m.lcFileSrce or '?' $ m.lcFileSrce or lFile(m.tcFileSrce)
IF m.llResult

	TRY

		lcFileDest = Iif(lFullpath(m.tcFileDest,, .T.);
			, m.tcFileDest;
			, Evaluate(m.tcFileDest); && support des expressions pour FilesCopy()
			)
*? m.lcFileDest
		* Si le chemin destination existe ou peut être créé
		llResult = PathCreate(m.lcFileDest, @m.lcResult, @m.tcMessage)
		IF m.llResult

			lcFileDest = Iif(lDir(m.lcFileDest), ForcePath(m.tcFileSrce, m.lcFileDest), m.lcFileDest)
			llResult = NOT Lower(m.tcFileSrce) == Lower(m.lcFileDest)
			IF m.llResult

				llResult = Vartype(m.tlKeepExisting) == 'L' AND m.tlKeepExisting AND lFile(m.lcFileDest)
				IF m.llResult

					STORE Textmerge(ICase(;
						cLangUser() = 'fr', 	[Le fichier destination existait en date du <<Fdate(m.lcFileDest, 1)>>, il n'a pas été remplacé],; && copy-paste this line to add another language support
																	[Destination file existed as of <<Fdate(m.lcFileDest, 1)>>, it was not remplaced];
						)) TO tcMessage
					
				ELSE

					COPY FILE (m.tcFileSrce) TO (m.lcFileDest) && changes name to lower case
					llResult = .T.
					
*!*							llResult = Empty(CopyFile(m.tcFileSrce, m.tcFileDest, 0)) && preserves case but ... does not work!
				ENDIF

			ELSE

				lcResult = ICase(;
					cLangUser() = 'fr', 	[Les fichier source et destination sont identiques],; && copy-paste this line to add another language support
																[Source and destination files are the same];
					)
			ENDIF
		ELSE
			&& PathCreate() returns errors
		ENDIF
	CATCH TO loException
		llResult = .F.
		lcResult = cException(m.loException)
		tcMessage = m.loException.Message
	ENDTRY
ELSE
	lcResult = Textmerge(ICase(;
		cLangUser() = 'fr', 	[Le fichier source '<<m.tcFileSrce>>' est introuvable],; && copy-paste this line to add another language support
													[Source file '<<m.tcFileSrce>>' can't be found];
		))
ENDIF
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge(ICase(; && DisplayPath(, 40) does not work with wildcards
		cLangUser() = 'fr',	[Erreur en copiant '<<m.tcFileSrce>>' dans '<<Evl(m.lcFileDest, m.tcFileDest)>>' :],; && copy-paste this line to add another language support
												[Error while copying '<<m.tcFileSrce>>' into '<<Evl(m.lcFileDest, m.tcFileDest)>>':];
		)) + [ ] + m.lcResult)
llResult = m.llResult or cResultAdd(@m.tcError, m.lcResult)

RETURN m.llResult

* ========================================
FUNCTION CopyFile(tcFileName, tcCopyFileName, tnFailIfExists) && http://www.berezniker.com/content/pages/visual-foxpro/copy-move-rename-file-preserving-destination-name-case
DECLARE Long CopyFile IN WIN32API String SourceFileName, String DestFileName, Long bFailIfExists
RETURN CopyFile(m.tcFileName, m.tcCopyFileName, m.tnFailIfExists)

* ========================================
PROCEDURE FileMove && Déplace un ou plusieurs fichier(s) en créant le(s) dossier(s) si nécessaire
LPARAMETERS ;
	tcFileSrce, ; && Adresse actuelle (can contain wildcard characters)
	tcFileDest,; && Nouvelle adresse (can contain wildcard characters)
	tlCopyForce,; && [.F.] Toujours copier (pas de RENAME, donc potentiellement plus lent)
	tcResult && @ Résultat
tcResult = Space(0)

LOCAL loException AS Exception, llResult

llResult = lFiles(m.tcFileSrce)
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([<<Program()>> - Le fichier '<<m.tcFileSrce>>' n'existe pas]))
IF m.llResult

	llResult = PathCreate(m.tcFileDest, @tcResult)
	IF m.llResult

		TRY
			IF lFiles(m.tcFileDest) OR Vartype(m.tlCopyForce) == 'L' AND m.tlCopyForce

			 	DELETE FILE (m.tcFileDest) && évite que le fichier copié hérite
			 	COPY FILE (m.tcFileSrce) TO (m.tcFileDest)
				IF lFiles(m.tcFileDest) && assure que le fichier a été copié avant de supprimer la source
					DELETE FILE (m.tcFileSrce)
				ENDIF
			ELSE

				&& When you issue RENAME, FileName2 cannot already exist and FileName1 must exist and cannot be open.
				RENAME (m.tcFileSrce) TO (m.tcFileDest) && déplace le fichier && If the file extensions are not included, the default extension .dbf is assumed
				&& RENAME moves the file and keeps its security profile
			ENDIF

		CATCH TO loException
			llResult = .F.
			tcResult = cException(m.loException)
		ENDTRY
	ENDIF

	ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([<<Program()>> - Erreur en déplaçant '<<m.tcFileSrce>>' dans '<<m.tcFileDest>>' : <<m.tcResult>>]))
ENDIF

RETURN m.llResult

* ========================================
PROCEDURE FileStrTran && Remplace une chaîne dans un fichier selon StrTran()
LPARAMETERS ;
	tcFile,; && fichier où chercher
	cExpressionSought,; && chaîne à remplacer
	cReplacement,; && [''] chaîne remplaçante
	nStartOccurrence,; && [1] première occurrence à traiter
	nNumberOfOccurrences,; && [-1, all] && nombre d'occurrences à traiter
	nFlags && [0] réglages selon StrTran()

IF File(m.tcFile) AND Vartype(m.cExpressionSought) == 'C'

	LOCAL lcFile
	lcFile = FileToStr(m.tcFile)
	
	RETURN .F.;
		 OR Empty(m.lcFile);
		 OR StrToFile(;
					Strtran(;
						m.lcFile;
					, m.cExpressionSought;
					,	Evl(m.cReplacement, '');
					, Evl(m.nStartOccurrence, 1);
					,	Evl(m.nNumberOfOccurrences, -1);
					,	Evl(m.nFlags, 0);
					);
				, m.tcFile;
				) > 0

ELSE
	RETURN .NULL.
ENDIF

* ========================================
FUNCTION lDir && Un dossier existe
LPARAMETERS tcDir, tlStrict && Adresse du dossier ; supporte wildcard
LOCAL ARRAY laTemp[1]
RETURN Vartype(m.tcDir) == 'C';
 AND NOT Empty(m.tcDir);
 AND (NOT m.tlStrict AND Directory(m.tcDir) OR ADir(laTemp, Addbs(m.tcDir), 'DHS') >= 1) && Directory, Hidden, System

* ========================================
FUNCTION lDirEmpty && Un dossier existe et est vide
LPARAMETERS tcDir && Adresse du dossier ; supporte wildcard
LOCAL laTemp[1]

RETURN lDir(m.tcDir);
 AND ADir(laTemp, ForcePath('*.*', m.tcDir), [DHS]) = 2;
 AND laTemp[1,1] == '.';
 AND laTemp[2,1] == '..'

* ========================================
FUNCTION lFile && Un fichier existe (plus rapide et précis que File() car ne cherche pas dans le PATH)
LPARAMETERS ;
	tcFileAddr,; && Adresse du fichier dont il faut vérifier l'existence, complète ou dans Curdir()
	tnSize,; && @ [0] Taille en octets - .T.: identifier fichiers multiples
	ttModified,; && @ [Datetime(1900,1,1,0,0,0)] Date et Heure de Dernière modification
	tcAttribs && @ [''] Attributs

LOCAL llResult, laFile[1], lnFile, llFiles

if ga_Type_IsChar(m.tcFileAddr, .T.) && Vartype(m.tcFileAddr) == 'C'

	lnFile = ADir(laFile, m.tcFileAddr, 'HS') && , 1 inutile
	llFiles = Vartype(m.tnSize) == 'L' AND m.tnSize
	llResult = Iif(m.llFiles, m.lnFile > 0, m.lnFile = 1)
	IF m.llResult AND NOT m.llFiles and Pcount() > 1

		tnSize = m.laFile[1, 2]
		ttModified = tDateCTime(m.laFile[1, 3], m.laFile[1, 4])
		tcAttribs = m.laFile[1, 5]
	ENDIF
ENDIF

IF NOT (m.llResult OR m.llFiles)
	tnSize = 0
	ttModified = Datetime(1900,1,1,0,0,0)
	tcAttribs = ''
ENDIF

RETURN m.llResult

* -------------------------------
PROCEDURE lFile_Test	&& Teste lFile

LOCAL loTest as abUnitTest
loTest = NewObject('abUnitTest', 'abDev.prg')

LOCAL lcFileAddr, lnSize, ltModified, lcAttribs
lcFileAddr = GetFile()
loTest.Test(.T., m.lcFileAddr, @lnSize, @ltModified, @lcAttribs)
? "Taille, date et attributs du fichier", m.lcFileAddr, CRLF, m.lnSize, m.ltModified, m.lcAttribs


* ========================================
FUNCTION lFiles && Un ou plusieurs fichiers existent selon un masque
LPARAMETERS tcFileAddrSkeleton && Masque de l'adresse des fichiers dont il faut vérifier l'existence

LOCAL laFiles[1]

RETURN aFiles(@m.laFiles, m.tcFileAddrSkeleton) > 0

* ========================================
FUNCTION aFiles && Fichiers selon un masque d'adresse
LPARAMETERS ;
	taFiles,; && @ Noms des Fichiers
	tcFileAddrSkeleton && Masque de l'adresse des fichiers

LOCAL llResult, lnResult && Nombre de fichiers trouvés

lnResult = 0

llResult = lFileAddrSkeleton(m.tcFileAddrSkeleton) and aClear(@m.taFiles)
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([Invalid File skeleton specification : <<cLitteral(m.tcFileAddrSkeleton)>>]))
IF m.llResult

	lnResult = ADir(m.taFiles, m.tcFileAddrSkeleton, '', 1)
	IF m.lnResult > 0

		aColsDel(@taFiles, 2) && retourne les seuls noms des fichiers
	ENDIF
ENDIF

RETURN m.lnResult

EXTERNAL ARRAY taFiles

* ========================================
FUNCTION aFiles_ && Fichiers selon un ou plusieurs masque dans un dossier [et ses sous-dossiers]
LPARAMETERS ;
  taFiles; && @ Addresses des Fichiers
, tcFileSkels; && Masques de fichiers à traiter
, tcFolder; && Adresse du dossier où les fichiers sont à chercher
, tlSubFolders; && [.F.] Chercher dans les sous-dossiers
, tcSubFoldersExcl && [space(0)] Sous-dossiers à exclure de la recherche (séparés par ',')

local lnResult as Integer;
, llResult as Boolean;
, laFiles[1] as String;
, lnFiles as Integer;
, liFile  as Integer;
, laFolder[1] as String;
, lcFolder as String;
, laFileSkel[1] as String;
, lcFileSkel as String;

lnResult = 0

if .T.;
 and aClear(@m.taFiles);
 and ALines(m.laFileSkel, m.tcFileSkels, 5, ',', ';') > 0
	
	if m.tlSubFolders and aSubFolders(; && Sous-dossiers d'un dossier /!\ Récursive
			  @m.laFolder; && @ taSubFolders Sous-dossiers selon aDir()
			, m.tcFolder; && tcFolder [dossier courant] Adresse du dossier où rechercher les sous-dossiers
			, m.tcSubFoldersExcl; && tcFoldersExcl [''] sous-dossiers à exclure et/ou masque des fichiers attendus dans les dossiers à inclure
			, .T.; && tvRecurse [.F.] Récurser dans les sous-sous-dossiers etc., si N, nombre de niveaux de récursion
			, .T.; && tlAddrOnly [.F.] Ne garder que les adresses des dossiers (supprimer date, taille, etc.)
			) > 0
		aPush(@m.laFolder, m.tcFolder)
	else
		laFolder = m.tcFolder
	endif

	for each lcFolder in m.laFolder
		for each lcFileSkel in m.laFileSkel
			lcFolder = Addbs(m.lcFolder)
			lnFiles = aFiles(@m.laFiles, m.lcFolder + m.lcFileSkel)
			if m.lnFiles > 0
				lnResult = m.lnResult + m.lnFiles
				for liFile = 1 to m.lnFiles
					laFiles[m.liFile] = m.lcFolder + laFiles[m.liFile]
				endfor
				= aAppend(@m.taFiles, @m.laFiles)
			endif
		endfor
	endfor
endif

return m.lnResult

* ========================================
FUNCTION lFileAddrSkeleton && Squelette d'adresse de fichier valide
LPARAMETERS ;
	tcFileAddrSkeleton && Masque de l'adresse des fichiers à vérifier

IF Vartype(m.tcFileAddrSkeleton) == 'C';
 AND NOT Empty(m.tcFileAddrSkeleton);
 AND lDir(JustPath(m.tcFileAddrSkeleton))

	tcFileAddrSkeleton = Addbs(FullPath(JustPath(m.tcFileAddrSkeleton))) + JustFname(m.tcFileAddrSkeleton)
	
	LOCAL lcStem, lcExt

	lcStem = JustStem(m.tcFileAddrSkeleton)
	lcExt = JustExt(m.tcFileAddrSkeleton)

	RETURN lFileAddress(m.tcFileAddrSkeleton);
		OR	'?' $ m.lcStem ;
		OR	'*' $ m.lcStem ;
		OR	'?' $ m.lcExt ;
		OR	'*' $ m.lcExt
ELSE
	RETURN .F.
ENDIF

* ========================================
FUNCTION lFileExclusive && Un fichier peut être ouvert en exclusif
LPARAMETERS ;
	tcFileAddr && Adresse du fichier dont il faut vérifier l'accès exclusif
LOCAL lnHandle, llResult

IF Vartype(m.tcFileAddr) == 'C' AND NOT Empty(m.tcFileAddr)

	llResult = lFileAddress(m.tcFileAddr)
	ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([<<Program()>> - Invalid file specification: <<cLitteral(m.tcFileAddr)>>]))
	IF m.llResult
	
		lnHandle = Fopen(m.tcFileAddr, 12) && 12 : Read and Write unbuffered
		llResult = m.lnHandle > 0
		IF m.llResult

			Fclose(m.lnHandle)
		ENDIF
	ENDIF
ENDIF

RETURN m.llResult

* ========================================
FUNCTION lFileFresher	&& Un fichier est plus récent qu'un autre
LPARAMETERS ;
	tcFile1Addr,; && Adresse du fichier de base
	tcFile2Addr && Adresse du fichier à comparer

* Si les deux fichiers existent
RETURN Iif(Vartype(m.tcFile1Addr)=='C';
	 AND lFile(FullPath(m.tcFile1Addr));
	 AND Vartype(m.tcFile2Addr)=='C';
	 AND lFile(FullPath(m.tcFile2Addr));
 , Fdate(m.tcFile2Addr, 1) > Fdate(m.tcFile1Addr, 1);
 , .NULL.;
 )

* ========================================
PROCEDURE FilesDir && Répertorie des fichiers dans un dossier [et ses sous-dossiers]
LPARAMETERS ;
	tcFileSkels,; && Masques de fichiers à traiter
	tcFolders,; && Adresse du dossier où les fichiers sont à chercher
	tlSubFolders,; && [.F.] Chercher dans les sous-dossiers
	tcSubFoldersExcl,; && [space(0)] Sous-dossiers à exclure de la recherche (séparés par ',')
	tcTable,; && @ Répertoire de fichiers : table ou curseur ; si vide, nouveau curseur ; Alias en retour
	tcFieldsExtra,; && [aucun] spécifications de champs à ajouter à la table
	tcTagsExtra && [aucun] spécifications d'index à ajouter à la table (cf. aTagInfo_())

LOCAL loDeleted as abSet, lnResult as Integer && Nombre de fichers répertoriés, -1 si erreur

tcTable = FilesDirCursor(m.tcTable, m.tcFieldsExtra)

loDeleted = abSet('DELETED', 'OFF')
DELETE ALL IN (m.tcTable) && cf. FileDir()

lnResult = Iif(Used(m.tcTable);
	, FilesProc(m.tcFolders, 'FileDir', m.tcFileSkels, m.tlSubFolders, m.tcSubFoldersExcl, m.tcTable);
	, -1)

RETURN m.lnResult

* ========================================
PROCEDURE FilesDirCursor && Ouvre ou crée une table ou un curseur d'inventaire de fichiers
LPARAMETERS ;
	tcTable,; && @ Table ou curseur pour répertoire de fichiers ; si vide, nouveau curseur
	tcFieldsExtra,; && [aucun] spécifications de champs à ajouter à la table
	tcTagsExtra,; && [aucun] spécifications d'index à ajouter à la table (cf. aTagInfo_())
	tcAlias && @ [JustStem(m.tcTable)] Alias d'ouverture

LOCAL llResult as Boolean

llResult = TableFreeCreateOrAdjust(;
			Evl(m.tcTable, Sys(2015));
		,	@m.tcAlias;
		,	FilesDirCursor_cFields(m.tcFieldsExtra);
		,	FilesDirCursor_cTags(m.tcTagsExtra);
		)	

ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([<<Program()>> - le curseur ou la table '<<m.tcTable>>' ne peut être ouvert ou créé]))

RETURN Iif(m.llResult, m.tcAlias, Space(0))

* ========================================
FUNCTION FilesDirCursor_cFields && Champs de la table ou curseur d'inventaire de fichiers
LPARAMETERS tcFieldsExtra && [aucun] spécifications de champs à ajouter à la table

RETURN c2Words(;
					[FILEDIR I, cNAME C(106), cSTEM C(100), cEXT C(5), mADDR M, nBYTES I NULL, tMOD T, tDIR T, CHECKSUM C(12) NULL]; && 100 est largement suffisant pour Abaque
				,	',';
				,	Evl(m.tcFieldsExtra, Space(0));
				)

* ========================================
FUNCTION FilesDirCursor_cTags && Indexes de la table ou curseur d'inventaire de fichiers
LPARAMETERS tcTagsExtra && [aucun] spécifications d'index à ajouter à la table (cf. aTagInfo_())

LOCAL lcResult
TEXT TO lcResult TEXTMERGE NOSHOW FLAGS 1 PRETEXT 3 && selon aTagInfo() && && Tag; Type; Key; Filter; Order; Collation
	FILEDIR;CANDIDATE;;;;MACHINE
	FILECK;CANDIDATE; <<cFilesDirCursorCKexpr('mADDR')>>;;;MACHINE
	cNAME;;;;;MACHINE
	cSTEM;;;;;MACHINE
	cEXT;;;;;MACHINE
	nBYTES;;;;;MACHINE
	tMOD;;;;;MACHINE
	tDIR;;;;;MACHINE
	DELETD;BINARY;Deleted()
	<<Evl(m.tcTagsExtra, Space(0))>>
ENDTEXT

RETURN m.lcResult

* ========================================
FUNCTION cFilesDirCursorCKexpr && Expression de clé candidate sur une table d'inventaire de fichiers
LPARAMETERS tcAddr
RETURN Textmerge([Padr(Upper(Rtrim(<<m.tcAddr>>)), 200)])

* ========================================
PROCEDURE FileDir && Répertorie un fichier
LPARAMETERS ;
	tcFile,; && Addresse du fichier
	tcAlias,; && Répertoire de fichiers
	tcError && @ Erreur en retour (cumulative)
tcFile = Alltrim(m.tcFile)

LOCAL loDeleted as abSet, loException AS Exception, lnBytes, ltFile, lcCheckSum, llResult

llResult = File(m.tcFile)
IF m.llResult

	loDeleted = abSet('DELETED', 'OFF')
	lnBytes = nFileSize(m.tcFile, .T.) && < 1 ms
	ltFile = tFile(m.tcFile, .T.)
	lcCheckSum = Iif(m.lnBytes < VFP_VAR_SIZE_MAX, cFileCheckSum(m.tcFile, .T.), .NULL.)

	TRY


		IF Seek(Evaluate(cFilesDirCursorCKexpr('m.tcFile')), m.tcAlias, 'FILECK')
		
			RECALL IN (m.tcAlias)

			IF NOT Lower(Evaluate(m.tcAlias + '.mAddr')) == Lower(m.tcFile) && évite le MEMO bloat
				REPLACE IN (m.tcAlias);
					mAddr WITH m.tcFile
			ENDIF

			IF Evaluate(m.tcAlias + '.nBYTES') # m.lnBytes;
			 OR Evaluate(m.tcAlias + '.tMOD') # m.ltFile;
			 OR NOT luEqual(Evaluate(m.tcAlias + '.CHECKSUM'), m.lcCheckSum)

				REPLACE IN (m.tcAlias);
					nBYTES WITH m.lnBytes;
					tMOD WITH m.ltFile;
					CHECKSUM WITH m.lcCheckSum;
					tDIR WITH Datetime()
					
			ENDIF

		ELSE

			INSERT INTO (m.tcAlias) (; && After executing the INSERT command, Visual FoxPro sets the record pointer on the new record
					  FILEDIR;
					, cNAME;
					, cSTEM;
					, cEXT;
					, mADDR;
					, nBYTES;
					, tMOD;
					, tDIR;
					, CHECKSUM;
					);
			 VALUES (;
			 			iAutoInc(m.tcAlias, 'FILEDIR');
					,	Upper(JustFname(m.tcFile));
					,	Upper(JustStem(m.tcFile));
					,	Upper(JustExt(m.tcFile));
					,	m.tcFile;
					,	m.lnBytes;
					,	m.ltFile;
					,	Datetime();
					, m.lcCheckSum;
					)
		ENDIF

	CATCH TO loException

		llResult = cResultAdd(@m.tcError, cException(m.loException))
	ENDTRY
ENDIF

RETURN m.llResult

*==============================================
FUNCTION FileMemo(tcFile) && Fichier mémo associé à un fichier-table VFP

LOCAL lcExt

lcExt = Lower(JustExt(m.tcFile))

RETURN ICase(;
	m.lcExt == 'vcx',;
		ForceExt(m.tcFile, 'vct'),;
	m.lcExt == 'scx',;
		 ForceExt(m.tcFile, 'sct'),;
	m.lcExt == 'mnx',;
		 ForceExt(m.tcFile, 'mnt'),;
	m.lcExt == 'frx',;
		 ForceExt(m.tcFile, 'frt'),;
	m.lcExt == 'lbx',;
		 ForceExt(m.tcFile, 'lbt'),;
	m.lcExt == 'pjx',;
		 ForceExt(m.tcFile, 'pjt'),;
	m.lcExt == 'dbc',;
		 ForceExt(m.tcFile, 'dct'),;
	.T.;
	and InList(m.lcExt, 'dbf', 'vmx'); && 'vmx' pour Visual Fox Extend
	and lFPT(m.tcFile),;
		ForceExt(m.tcFile, 'fpt'),;
		'';
	)

*==============================================
FUNCTION FileIndex(tcFile) && Fichier index associé à un fichier-table VFP

LOCAL lcExt

lcExt = Lower(JustExt(m.tcFile))
RETURN ICase(;
	m.lcExt == 'dbc', ForceExt(m.tcFile, 'dcx'),;
	m.lcExt == 'dbf', ICase(;
		lFile(ForceExt(m.tcFile, 'cdx')), ForceExt(m.tcFile, 'cdx'),;
		lFile(ForceExt(m.tcFile, 'idx')), ForceExt(m.tcFile, 'idx'),;
		Space(0)),;
	m.lcExt == 'mnx', ForceExt(m.tcFile, 'mpr'),; && just a workaround
	Space(0);
)

*==============================================
FUNCTION tFile && Date et heure de dernière modification d'un fichier et/ou de ses fichiers liés
LPARAMETERS ;
	tcFile,; && Fichier
	tlMemo && [.F.] Tenir compte du fichier memo associé éventuel

tcFile = FullPath(m.tcFile)
tlMemo = Iif(Vartype(m.tlMemo) == 'L' AND m.tlMemo, FileMemo(m.tcFile), Space(0))

local ltResult

try
	ltResult = ICase(;
		!lFile(m.tcFile),; && File() peut répondre .T. et Fdate() ne trouve pas le fichier
			{/:},;
		lFile(m.tlMemo),;
			Max(Fdate(m.tcFile, 1), Fdate(m.tlMemo, 1)),;
			Fdate(m.tcFile, 1); && 1: last modification DateTime
			)
catch && erreur 'file not found' dans certains cas inexpliquables
	ltResult = {/:}
endtry

RETURN m.ltResult

*==============================================
FUNCTION cFileSizeTotal && Taille d'un fichier et de ses fichiers associés
LPARAMETERS tcFile && Fichier

return cFileSize(;
	  @m.tcFile;
	, .T.; && tlMemo Tenir compte du fichier memo associé éventuel
	, .T.; && tlCDX Tenir compte du fichier CDX associé éventuel
	)

*==============================================
FUNCTION cFileSize && Taille d'un fichier
LPARAMETERS ;
	tcFile,; && Fichier
	tlMemo,; && [.F.] Tenir compte du fichier memo associé éventuel @ le fichier memo existe
	tlCDX && [.F.] Tenir compte du fichier CDX associé éventuel @ le fichier CDX existe

local result

result = nFileSize(@m.tcFile, @m.tlMemo, @m.tlCDX)

return Icase(;
	not Vartype(m.result) == 'N',;
		m.result,;
	m.result >= 1024^3,;
		Ltrim(Transform(m.result/1024^3, '9,999.9 GB')),;
	m.result >= 1024^2,;
		Ltrim(Transform(m.result/1024^2, '9,999.9 MB')),;
	m.result > 1024,;
		Ltrim(Transform(m.result/1024, '9,999.9 kB')),;
		Ltrim(Transform(m.result, '9,999 B'));
	)

*==============================================
FUNCTION cMB && Valeur en Méga Octets
lparameters ;
  tnSize;
, tcLangUser && [cLangUser()] Langue de l'utilisateur

tcLangUser = cLangUser(m.tcLangUser)

return '';
	+ Ltrim(Transform(m.tnSize/2^20, '999.99'));
	+ ' ';
	+ ICase(;
		m.tcLangUser = 'fr', 	'MO',; && copy-paste this line to add another language support
													'MB'; && default: English
		)

*==============================================
FUNCTION cGB && Valeur en Giga Octets
lparameters ;
  tnSize;
, tcLangUser && [cLangUser()] Langue de l'utilisateur

tcLangUser = cLangUser(m.tcLangUser)

return '';
	+ Ltrim(Transform(m.tnSize/2^30, '999.99'));
	+ ' ';
	+ ICase(;
		m.tcLangUser = 'fr', 	'GO',; && copy-paste this line to add another language support
													'GB'; && default: English
		)

*==============================================
FUNCTION cFileSizeMB && Taille d'un fichier en Méga Octets
LPARAMETERS ;
	tcFile,; && Fichier
	tlMemo,; && [.F.] Tenir compte du fichier memo associé éventuel
	tcLangUser && [cLangUser()] Langue de l'utilisateur

return cMB(nFileSize(m.tcFile, m.tlMemo))

*==============================================
FUNCTION nFileSizeTotal && Taille d'un fichier et de ses fichiers associés
LPARAMETERS tcFile && Fichier

return nFileSize(;
	  @m.tcFile;
	, .T.; && tlMemo Tenir compte du fichier memo associé éventuel
	, .T.; && tlCDX Tenir compte du fichier CDX associé éventuel
	)

*==============================================
FUNCTION nFileSize && Taille d'un fichier en octets
LPARAMETERS ;
	tcFile,; && Fichier
	tlMemo,; && [.F.] @ Ajouter la taille du fichier memo associé éventuel @ le fichier memo existe
	tlCDX && [.F.] @ Ajouter la taille du fichier CDX associé éventuel @ le fichier CDX existe

LOCAL lnResult; &&  && Taille du fichier en octets
, lcMemo;
, lcCDX;
, llCompatible;
, lnMemoWidth;
, lHandle;
, llResult

* If file can be found
llResult = Vartype(m.tcFile) == 'C' AND File(m.tcFile)
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([<<Program()>> - Invalid File Address Specification: <<m.tcFile>>]))
IF m.llResult

	IF Vartype(m.tlMemo) == 'L' AND m.tlMemo
		lcMemo = FileMemo(m.tcFile)
		tlMemo = NOT Empty(m.lcMemo) && @ feedback
	endif

	if Vartype(m.tlCDX) == 'L' and m.tlCDX
		lcCDX = ForceExt(m.tcFile, 'cdx')
		tlCDX = File(m.lcCDX) && @ feedback
	endif
	
	try
		llCompatible = Set("Compatible") == 'OFF'
		if m.llCompatible
			lnMemoWidth = Set("Memowidth")
			set compatible on
		endif
		lnResult = 0;
			+ Fsize(m.tcFile);
			+ Iif(m.tlMemo, Fsize(m.lcMemo), 0);
			+ Iif(m.tlCDX, Fsize(m.lcCDX), 0)
	catch
		llResult = .F.
	finally
		if m.llCompatible and Set("Compatible") == 'ON'
			set memowidth to m.lnMemoWidth
			set compatible off
		endif
	endtry
	
	if !m.llResult

		lHandle = Fopen(JustFname(m.tcFile), 10)
		llResult = lHandle # -1
		IF m.llResult

			lnResult = Fseek(m.lHandle, 0, 2)
			Fclose(m.lHandle)
			lnResult = m.lnResult;
				+ Iif(m.tlMemo, nFileSize(m.lcMemo), 0);
				+ Iif(m.tlCDX, nFileSize(m.lcCDX), 0)

		else

			&& probably an included file
			try
				lnResult = 0;
					+ Len(FileToStr(m.tcFile));
					+ Iif(m.tlMemo, Len(FileToStr(m.lcMemo)), 0);
					+ Iif(m.tlCDX, Len(FileToStr(m.lcCDX)), 0)
				llResult = m.lnResult > 0

				tcFile = Iif(m.llResult;
					, cFileCased(Iif(wlAutomation();
						, _VFP.Servername;
						, cModuleInfo(Sys(16,0), 'Address');
						)) + '!' + JustFname(m.tcFile);
					, m.tcFile;
					)
			catch
			endtry
		endif
	endif
endif

RETURN Iif(m.llResult, m.lnResult, .NULL.)

*----------------------------------------
PROCEDURE nFileSize_Test && teste nFileSize()

LOCAL loTest as abUnitTest OF abDev.prg;
, lcFile;
, lnFile

loTest = NewObject('abUnitTest', 'abDev.prg')

lcFile = Sys(2023) + 'nFileSize_Test.txt'
lnFile = 10000
StrToFile(Replicate('a', m.lnFile), m.lcFile)
loTest.test(m.lnFile, m.lcFile)
ERASE (m.lcFile)

loTest.test(.NULL., cModuleInfo(Sys(16), 'Address')) && file can't be accessed

RETURN loTest.result()

*========================================
FUNCTION cFileCheckSum && Checksum du contenu d'un fichier avec, le cas échéant, son fichier lié
LPARAMETERS ;
	tcFile,; && Fichier
	tlMemo,; && [.F.] Inclure le memo associé éventuel
	tnPadr && [none] Longueur à padder
tcFile = Evl(m.tcFile, '')
tlMemo = Vartype(m.tlMemo) == 'L' AND m.tlMemo

LOCAL tnFile, lcFile, llFile, lnFile, llResult, lcResult

lcResult = .NULL.

IF File(m.tcFile)

	tnFile = nFileSize(m.tcFile)
	llResult = NOT IsNull(m.tnFile) && la taille du fichier a pu être calculée
	IF m.llResult

		llResult = m.tnFile < VFP_VAR_SIZE_MAX
		ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([<<Proper(Program())>>() - ] + ICase(;
			cLangUser() = 'fr',	[La taille du fichier '<<JustFname(m.tcFile)>>' excède la limite VFP de 16 Mo],; && copy-paste this line to add another language support
													[Size of file '<<JustFname(m.tcFile)>>' exceeds the VFP 16 Mb limitation];
		)))
		IF .T.;
		 AND m.llResult;
		 AND Vartype(m.tlMemo) == 'L';
		 AND m.tlMemo

			lcFile = FileMemo(m.tcFile)
			llFile = File(m.lcFile)
			IF m.llFile

				lnFile = nFileSize(m.lcFile)
				llResult = NOT IsNull(m.lnFile) && la taille du fichier a pu être calculée
				IF m.llResult

					llResult = m.lnFile < VFP_VAR_SIZE_MAX
					ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([<<Proper(Program())>>() - ] + ICase(;
						cLangUser() = 'fr',	[La taille du fichier '<<JustFname(m.lcFile)>>' dépasse la limite VFP de 16 Mo],; && copy-paste this line to add another language support
																[Size of file '<<JustFname(m.lcFile)>>' exceeds the VFP 16 Mb limitation];
					)))
					IF m.llResult

						llResult = m.tnFile + m.lnFile < VFP_VAR_SIZE_MAX
						ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([<<Proper(Program())>>() - ] + ICase(;
							cLangUser() = 'fr',	[La taille des fichiers '<<JustFname(m.tcFile)>>' et '<<JustFname(m.lcFile)>>' dépasse la limite VFP de 16 Mo],; && copy-paste this line to add another language support
																	[Size of files '<<JustFname(m.tcFile)>>' and '<<JustFname(m.lcFile)>>' exceeds the VFP 16 Mb limitation];
						)))
					ENDIF
				ENDIF
			ENDIF
		ENDIF
	ENDIF
	IF m.llResult

		lcResult = Sys(2007;
			, FileToStr(m.tcFile) + Iif(m.llFile, FileToStr(m.lcFile), Space(0));
			, -1; && nSeed : Specifies a numeric seed value of 0 that is used to calculate the checksum and is included for backward compatibility. Passing a value of -1 for nSeed uses the default system value of 0. For CRC32 calculations, Visual FoxPro disregards nSeed.
			, 1; && CRC32 - For CRC32 calculations, Visual FoxPro disregards nSeed
			)
	ENDIF
ENDIF

RETURN Iif(m.llResult and Vartype(m.tnPadr) == 'N' AND m.tnPadr > 0;
	, Padr(m.lcResult, m.tnPadr);
	, m.lcResult;
	)

* ========================================
PROCEDURE FilesRename && Renomme des fichiers dans un dossier [et ses sous-dossiers]
LPARAMETERS ;
	tcFileSkels,; && Masques de fichiers à traiter (séparés par ',')
	tcFileNew,; && Nouveau nom
	tcFolders,; && Adresses des dossiers où les fichiers sont à chercher
	tlSubFolders,; &&	[.F.] Chercher dans les sous-dossiers
	tcSubFoldersExcl && [space(0)] Sous-dossiers à exclure de la recherche (séparés par ',')

RETURN Iif(lFileSkeleton(m.tcFileSkels) AND m.tcFileSkels # [*.*];
	, FilesProc(m.tcFolders, 'FileRename', m.tcFileSkels, m.tlSubFolders, m.tcSubFoldersExcl, m.tcFileNew);
	, 0)

* ========================================
PROCEDURE FileRename && Renomme un fichier
LPARAMETERS ;
	tcFile,; && Addresse du fichier à renommer
	tcFileNew && Nouveau nom
tcFileNew = ForcePath(m.tcFileNew, JustPath(m.tcFile))

LOCAL llResult

llResult = NOT lFile(m.tcFileNew)
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([<<Program()>> - Impossible de renommer <<m.tcFile>> en <<m.tcFileNew>> car ce fichier existe déjà]))
IF m.llResult
	RENAME (m.tcFile) TO (m.tcFileNew)
ENDIF

RETURN m.llResult

* ========================================
PROCEDURE FilesDelete && Alias de FilesDel()
LPARAMETERS ;
	tcFileSkels,; && Masques de fichiers à traiter
	tcFolders,; && Adresse du dossier où sont les fichiers
	tlSubFolders,; && [.F.] Chercher dans les sous-dossiers
	tcSubFoldersExcl,; && [space(0)] Sous-dossiers à exclure de la recherche (séparés par ',')
	tlRecycle,; && [.F.] Placer les fichiers supprimés dans la corbeille
	tlDirsEmptyDel,; && [.F.] Supprimer les dossiers vides
	tcError && [''] @ Détail de l'erreur éventuelle

RETURN FilesDel(;
		m.tcFileSkels;
	,	m.tcFolders;
	,	m.tlSubFolders;
	,	m.tcSubFoldersExcl;
	,	m.tlRecycle;
	,	m.tlDirsEmptyDel;
	,	@m.tcError;
	)

* ========================================
PROCEDURE FilesDel && Supprime des fichiers dans un dossier [et ses sous-dossiers]
LPARAMETERS ;
	tcFileSkels,; && Masques de fichiers à traiter
	tcFolders,; && Adresse du dossier où sont les fichiers
	tlSubFolders,; && [.F.] Chercher dans les sous-dossiers
	tcSubFoldersExcl,; && [space(0)] Sous-dossiers à exclure de la recherche (séparés par ',')
	tlRecycle,; && [.F.] Placer les fichiers supprimés dans la corbeille
	tlDirsEmptyDel,; && [.F.] Supprimer les dossiers vides
	tcResult,; && [''] @ Détail de l'erreur éventuelle
	tnResult; && [0] @ Nombre de fichiers copiés

tlRecycle = Vartype(m.tlRecycle) == 'L' AND m.tlRecycle

LOCAL llResult as Boolean;
, lcResult as String

tnResult = FilesProc(;
	  m.tcFolders;
	, 'FileDel';
	, m.tcFileSkels;
	, m.tlSubFolders;
	, m.tcSubFoldersExcl;
	, m.tlRecycle;
	, m.tlDirsEmptyDel;
	, @m.lcResult;
	)

llResult = Empty(m.lcResult) or cResultAdd(@m.tcResult, m.lcResult)

* Supprimer les répertoires vides résiduels
IF m.llResult AND Vartype(m.tlDirsEmptyDel) == 'L' AND m.tlDirsEmptyDel

	LOCAL laFolders[1], lcFolder, laSubFolders[1], lcSubFolder
	ALines(laFolders, m.tcFolders, 1, ',', ';')
	FOR EACH lcFolder IN m.laFolders
		IF m.tlSubFolders AND aSubFolders(@m.laSubFolders, m.lcFolder, m.tcSubFoldersExcl, .T., .T.) > 0
			FOR EACH lcSubFolder IN m.laSubFolders
				IF lDirEmpty(m.lcSubFolder)
					RD (m.lcSubFolder)
				ENDIF
			ENDFOR
		endif
		try
			IF lDirEmpty(m.lcFolder)
				RD (m.lcFolder)
			ENDIF
		catch
		endtry
	ENDFOR
ENDIF
	
RETURN m.llResult

*!*		* ========================================
*!*		PROCEDURE FileDelete && Supprime un fichier && alias de FileDel() && abandonné à cause d'un conflit avec FileDelete.exe de web connect
*!*		LPARAMETERS ;
*!*			tcFile,; && Addresse du fichier à supprimer
*!*			tlRecycle,; && [.F.] Placer les fichiers dans la corbeille
*!*			tlDirsEmptyDel,; && [.F.] Supprimer les dossiers vides
*!*			tcError && [''] @ Détail de l'erreur éventuelle
*!*		
*!*		RETURN FileDel(m.tcFile, m.tlRecycle, m.tlDirsEmptyDel, @m.tcError)

* ========================================
PROCEDURE FileDel && Supprime un fichier
LPARAMETERS ;
	tcFile,; && Addresse du fichier à supprimer
	tlRecycle,; && [.F.] Placer les fichiers dans la corbeille
	tlDirsEmptyDel,; && [.F.] Supprimer les dossiers vides
	tcResult && [''] @ Détail de l'erreur éventuelle, cumulative

LOCAL lcRecycle;
, lcPath;
, loException AS Exception;
, llResult

TRY

	lcRecycle = Iif(Vartype(m.tlRecycle) == 'L' AND m.tlRecycle, 'RECYCLE', '')

	IF InList(Lower(JustExt(m.tcFile)), 'fxp', 'prg') AND Upper(ForceExt(m.tcFile, 'fxp')) $ Set("Procedure")
		RELEASE PROCEDURE (m.tcFile)
	ENDIF

	DELETE FILE (m.tcFile) &lcRecycle

	lcPath = JustPath(m.tcFile)
	IF Vartype(m.tlDirsEmptyDel) == 'L' AND m.tlDirsEmptyDel AND lDirEmpty(m.lcPath)
		RD (m.lcPath)
	ENDIF

	llResult = .T.

CATCH TO loException

	loException = cException(m.loException)
	llResult = cResultAdd(@m.tcResult, m.loException)
	ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([Erreur en supprimant '<<m.tcFile>>' : <<m.loException>>]))

ENDTRY

RETURN m.llResult


* ========================================
PROCEDURE FilesProc && Applique une procédure à tous les fichiers d'un dossier [et de ses sous-dossiers] - jusqu'à 5 paramètres peuvent être passés à la procédure
LPARAMETERS ;
	tcFolders,; && Adresses des dossiers où les fichiers sont à chercher
	tcProc,; && Procédure à appliquer à chaque fichier trouvé (son premier paramètre est l'adresse du fichier)
	tcFileSkels,; && ['*.*'] Masques de fichiers à traiter (séparés par ',')
	tlSubFolders,; &&	[.F.] Chercher dans les sous-dossiers
	tcSubFoldersExcl,; && [space(0)] Sous-dossiers à exclure de la recherche (séparés par ',')
	tuProcParm02,; && @ 2ème paramètre à passer à la procédure (le premier est l'adresse du fichier)
	tuProcParm03,; && @ 3ème paramètre à passer à la procédure
	tuProcParm04,; && @ 4eme paramètre à passer à la procédure
	tuProcParm05,; && @ 5ème paramètre à passer à la procédure
	tuProcParm06,; && @ 6ème paramètre à passer à la procédure
	tuProcParm07,; && @ 7ème paramètre à passer à la procédure
	tuProcParm08,; && @ 8ème paramètre à passer à la procédure
	tuProcParm09,; && @ 9ème paramètre à passer à la procédure
	tuProcParm10,; && @ xème paramètre à passer à la procédure
	tuProcParm11,; && @ xème paramètre à passer à la procédure
	tuProcParm12,; && @ xème paramètre à passer à la procédure
	tuProcParm13,; && @ xème paramètre à passer à la procédure
	tuProcParm14,; && @ xème paramètre à passer à la procédure
	tuProcParm15,; && @ xème paramètre à passer à la procédure
	tuProcParm16,; && @ xème paramètre à passer à la procédure
	tuProcParm17,; && @ xème paramètre à passer à la procédure
	tuProcParm18,; && @ xème paramètre à passer à la procédure
	tuProcParm19   && @ xème paramètre à passer à la procédure
	&& on pourrait passer jusqu'à 19 paramètres à la procédure ...

tcFileSkels = Iif(Vartype(m.tcFileSkels) == 'C', Alltrim(m.tcFileSkels), [*.*])
tlSubFolders = Vartype(m.tlSubFolders) == 'L' AND m.tlSubFolders
tcSubFoldersExcl = Iif(m.tlSubFolders AND Vartype(m.tcSubFoldersExcl)=='C', Upper(m.tcSubFoldersExcl), Space(0))

LOCAL llResult, lnResult && Nombre de fichiers traités
lnResult = 0

* Si les paramètres requis sont valides
llResult = Vartype(m.tcFolders)=='C' AND NOT Empty(m.tcFolders);
			 AND Vartype(m.tcProc) == 'C' AND NOT Empty(m.tcProc) && comment vérifier que la procédure est accessible ?
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([<<Program()>> - Les dossiers <<cLitteral(@tcFolders)>> ou la procédure <<cLitteral(@tcProc)>> est invalide]))
IF m.llResult

	LOCAL laSkels[1], lnSkels, lcSkel, lnDocs, laDocs[1], laDocsSkel[1], laSubFolders[1], lnSubFolders, lnSubFolder
	lnSkels = ALines(laSkels, m.tcFileSkels, .T., ',')
	
	* Pour chaque dossier
	LOCAL laFolders[1], lcFolder
	ALines(laFolders, m.tcFolders, 1, [,], [;])
	FOR EACH lcFolder IN laFolders

		* Si le dossier existe
		llResult = lDir(m.lcFolder)
		ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([<<Program()>> - le dossier '<<m.lcFolder>>' n'existe pas]))
		IF m.llResult
			lcFolder = Addbs(cFileCased(FullPath(m.lcFolder)))
			aClear(@m.laDocs)
			lnDocs = 0
			
			* Tabuler les fichiers situés dans le dossier et répondant au(x) masque(s)
			FOR EACH lcSkel IN laSkels
				IF ADir(laDocsSkel,  m.lcFolder + m.lcSkel, '', 1) > 0 && pas de dossier && capitalization on disk
					lnDocs = aAppend(@m.laDocs, @m.laDocsSkel)
				ENDIF
			ENDFOR
			Asort(laDocs, 1, -1, 0, 1) && ascending, case insensitive

			* Si recherche dans les sous-dossiers demandée,
			IF m.tlSubFolders

				* Si sous-dossier(s) dans le dossier
				lnSubFolders = aSubFolders(@m.laSubFolders, m.lcFolder, m.tcSubFoldersExcl)
				IF m.lnSubFolders > 0

					* Supprimer l'adresse du dossier de départ && par cohérence avec le aDir() ci-dessus
					FOR lnSubFolder = 1 TO m.lnSubFolders
						laSubFolders[m.lnSubFolder, 1] = Strtran(laSubFolders[m.lnSubFolder, 1], m.lcFolder, Space(0), 1, -1, 1)
					ENDFOR
					Asort(laSubFolders, 1, -1, 0, 1) && ascending, case insensitive

					* Ajouter les sous-dossiers AVANT les documents
					lnDocs = aAppend(@m.laDocs, @m.laSubFolders,, .T.)
				ENDIF
			ENDIF

			* Si le dossier comporte des documents
			IF m.lnDocs > 0

				* Préparer la chaine de paramètres à passer à la procédure
				LOCAL lcProcParms, lnProcParms, lnProcParm
				lnProcParms = Pcount() - 5; && les paramètres commencent en 6è position
																+ 1 && les n° de paramètres commencent à 2
				lcProcParms = Space(0)
				IF m.lnProcParms >= 2
					FOR lnProcParm = 2 TO m.lnProcParms
						lcProcParms = Textmerge([<<m.lcProcParms>>, @m.tuProcParm<<Padl(m.lnProcParm, 2, '0')>>])
					ENDFOR
				ENDIF

				* Pour chaque "document" (fichier ou sous-dossier)
				LOCAL lnDoc, lcDoc, lcDocAddr, llDoc
				FOR lnDoc = 1 to m.lnDocs
					lcDoc = laDocs[m.lnDoc, 1]
					lcDocAddr = m.lcFolder + m.lcDoc

					* Si dossier exploitable, récurser le cas échéant
					IF 'D' $ Upper(laDocs[m.lnDoc, 5])

						IF m.tlSubFolders AND NOT InList(m.lcDoc, '.', '..')
						 	lnResult = m.lnResult + ; && récursion
						 		Evaluate('FilesProc(m.lcDocAddr, m.tcProc, m.tcFileSkels, m.tlSubFolders, m.tcSubFoldersExcl' + m.lcProcParms + ')')
						ENDIF

					* Sinon (fichier), appliquer la procédure indiquée
					ELSE

						llDoc = Evaluate(Textmerge([<<m.tcProc>>(m.lcDocAddr <<m.lcProcParms>>)]))
						lnResult = m.lnResult + Iif(m.llDoc, 1, 0)
					ENDIF
				ENDFOR
			ENDIF
		ENDIF
	ENDFOR
ENDIF

RETURN m.lnResult

* -------------------------------
PROCEDURE FilesProc_Test && Teste FilesProc()

LOCAL loTest AS abUnitTest
loTest = NewObject('abUnitTest', 'abDev.prg')
loTest.Test(, GetDir(Curdir(),'',"Où sont les fichiers Excel à traiter ?", 16), ;
						'FilesProc_Test_Proc', '*.xls', .T., '', Date())

RETURN loTest.Result()

	* ------------------------------------
	PROCEDURE FilesProc_Test_Proc	&& Procédure appelée par FilesProc_Test()
	LPARAMETERS ;
		tcFile,;
		tuParm

	* Afficher l'adresse du fichier et le paramètre
	? cFileCased(m.tcFile), ' -- paramètre :', Transform(m.tuParm)

* ========================================
FUNCTION cFileSubFolders && Fichier dans un dossier ou un des ses sous-dossiers
LPARAMETERS ;
	tcFile,; && Adresse du fichier
	tcFoldersExcl,; && [''] sous-dossiers à exclure et/ou masque des fichiers attendus dans les dossiers à inclure
	tvRecurse && [.F.] Récurser dans les sous-sous-dossiers etc., si N, nombre de niveaux de récursion

LOCAL laFolders[1], lcFolder, lcFile, llResult, lcResult

lcResult = Space(0)
llResult = File(m.tcFile)
IF m.llResult
	lcResult = cFileCased(m.tcFile, .T.)
ELSE
	lcFile = JustFname(m.tcFile)
	IF aSubFolders(@m.laFolders, JustPath(m.tcFile), m.tcFoldersExcl, m.tvRecurse, .T.) > 0
		FOR EACH lcFolder IN laFolders
			lcFolder = Addbs(m.lcFolder) + m.lcFile
			IF File(m.lcFolder)
				lcResult = cFileCased(m.lcFolder, .T.)
				EXIT
			ENDIF
		ENDFOR
	ENDIF
ENDIF

RETURN m.lcResult

* ========================================
FUNCTION aSubFolders && Sous-dossiers d'un dossier /!\ Récursive
LPARAMETERS ;
	taSubFolders,; && @ Sous-dossiers selon aDir()
	tcFolder,; && [dossier courant] Adresse du dossier où rechercher les sous-dossiers
	tcFoldersExcl,; && [''] sous-dossiers à exclure et/ou masque des fichiers attendus dans les dossiers à inclure
	tvRecurse,; && [.F.] Récurser dans les sous-sous-dossiers etc., si N, nombre de niveaux de récursion
	tlAddrOnly && [.F.] Ne garder que les adresses des dossiers (supprimer date, taille, etc.)
EXTERNAL ARRAY taSubFolders && pour le gestionnaire de projet
tcFolder = Addbs(FullPath(Evl(m.tcFolder, Space(0))))
tcFoldersExcl = Iif(Vartype(m.tcFoldersExcl) == 'C', m.tcFoldersExcl, Space(0))

LOCAL lcTypeRecurse, llRecurse, llFirst, lcDefault;
, laFolders[1], lnFolder, lcFolder, llFolder, lcPath, lnSubFolders, lnFileSkel;
, llResult, lnResult && Nombre de sous-dossiers trouvés

lcTypeRecurse = Vartype(m.tvRecurse)
tvRecurse = Iif(m.lcTypeRecurse == 'N' AND m.tvRecurse > 0, m.tvRecurse, m.lcTypeRecurse == 'L' AND m.tvRecurse)
lnResult = 0

* Si les paramètres requis sont valides
llResult = Type('taSubFolders', 1) == 'A' && aClear() est fait plus loin à la première récursion
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([<<Program()>> - Le premier paramètre <<cLitteral(taSubFolders)>> doit être un tableau]))
IF m.llResult

	llResult = lDir(m.tcFolder, .T.)
*		ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([<<Program()>> - Le dossier '<<m.tcFolder>>' est introuvable]))
	IF m.llResult

		* Si première récursion && optimisation
		IF Vartype(m.pnFoldersExcl) == 'U'

			tcFolder = cFileCased(m.tcFolder)
			aClear(@taSubFolders) && Vide le résultat
			* Tabuler les dossiers à exclure et/ou les masques de fichiers à trouver dans les dossiers
			PRIVATE pnFoldersExcl, paFoldersExcl, pnFileSkel, paFileSkel, pnRecurse
			DIMENSION paFoldersExcl[1], paFileSkel[1]
			pnFoldersExcl = ALines(paFoldersExcl, m.tcFoldersExcl, 1+4, [,], [;])
			pnFileSkel = 0
			IF m.pnFoldersExcl > 0

				FOR lnFolder = m.pnFoldersExcl TO 1 STEP -1
					lcFolder = paFoldersExcl[m.lnFolder]

					IF lFileSkeleton(m.lcFolder)
						pnFoldersExcl = m.pnFoldersExcl - 1
						Adel(paFoldersExcl, m.lnFolder)
						pnFileSkel = m.pnFileSkel + 1
						DIMENSION paFileSkel[m.pnFileSkel]
						paFileSkel[m.pnFileSkel] = m.lcFolder
					ENDIF
				ENDFOR
				IF m.pnFoldersExcl > 0
					DIMENSION paFoldersExcl[m.pnFoldersExcl]
				ENDIF
			ENDIF
			llFirst = .T.
			pnRecurse = 1
		ELSE
			pnRecurse = m.pnRecurse + 1
		ENDIF

		* Pour chaque sous-dossier
		lcDefault = Sys(5) + Curdir()
		SET DEFAULT TO (m.tcFolder)
		lnResult = ADir(laFolders, Space(0), 'D', 1) && space(0) makes aDir() return Folders
		SET DEFAULT TO (m.lcDefault)

		llRecurse = Iif(m.lcTypeRecurse == 'N', m.pnRecurse < m.tvRecurse, m.tvRecurse)
		lnSubFolders = 0
		FOR lnFolder = m.lnResult TO 1 STEP -1
			lcFolder = laFolders[m.lnFolder, 1]
			lcPath = m.tcFolder + Addbs(m.lcFolder)

			* Si bidon ou exclus, supprimer
			llFolder = NOT (InList(m.lcFolder, '.', '..'); && bidon
				 OR m.pnFoldersExcl > 0 AND Ascan(paFoldersExcl, m.lcFolder, 1, -1, 1, 1+2+4) > 0; && exclus
				)
			IF m.llFolder

				* Si récursion demandée, compter les sous-dossiers
				lnSubFolders = m.lnSubFolders + Iif(m.llRecurse;
					, aSubFolders(@taSubFolders, m.lcPath, m.tcFoldersExcl, m.tvRecurse, m.tlAddrOnly);
					, 0)

				IF m.pnFileSkel > 0
					llFolder = .F.
					FOR lnFileSkel = 1 TO m.pnFileSkel
						llFolder = m.llFolder OR lFiles(m.lcPath + m.paFileSkel[m.lnFileSkel])
					ENDFOR
				ENDIF
			ENDIF

			* Si le dossier est OK, ajouter à la liste sinon supprimer
			IF m.llFolder
				laFolders[m.lnFolder, 1] = m.lcPath
			ELSE
				Adel(laFolders, m.lnFolder)
				lnResult = m.lnResult - 1
			ENDIF
		ENDFOR
		
		* Si des dossiers ont été trouvés
		IF m.lnResult > 0
			DIMENSION laFolders[m.lnResult, Alen(laFolders, 2)]

			* Si demandé, supprimer les colonnes superflues
			IF Vartype(m.tlAddrOnly) == 'L' AND m.tlAddrOnly
				aColsDel(@m.laFolders, 2)
				dimension laFolders[Alen(m.laFolders)]
			ENDIF

			* Ajouter les dossiers au résultat
			aAppend(@taSubFolders, @m.laFolders,, .T.) && bottom up
		ENDIF

		lnResult = m.lnResult + m.lnSubFolders
		pnRecurse = m.pnRecurse - 1
		IF m.pnRecurse = 1 AND m.lnResult > 0
			Asort(taSubFolders, 1, -1, -1, 1)
		ENDIF
	ENDIF
ENDIF

RETURN m.lnResult

* ========================================
FUNCTION cFolder && Dossier d'une addresse
LPARAMETERS tcAddress && adresse

LOCAL lcPath, lcResult

lcResult = Space(0)
IF Vartype(m.tcAddress) == 'C' AND NOT Empty(m.tcAddress)
	lcPath = JustPath(m.tcAddress)
	lcResult = Substr(m.lcPath, Ratc('\', m.lcPath)+1)
ENDIF

RETURN m.lcResult

* ========================================
FUNCTION cFolders && Dossiers d'une liste d'addresses
LPARAMETERS tcAddresses && Adresses

LOCAL laAddress[1], lnAddress, lcResult

lcResult = Space(0)
IF Vartype(m.tcAddresses) == 'C' AND NOT Empty(m.tcAddresses)

	FOR lnAddress = 1 TO ALines(laAddress, m.tcAddresses, 1, ',', ';', CRLF, CR, LF)
		laAddress[m.lnAddress] = cFolder(laAddress[m.lnAddress])
	ENDFOR
	lcResult = cListOfArray(@m.laAddress)
ENDIF

RETURN m.lcResult

* ========================================
FUNCTION cFiles && Fichiers selon un masque
LPARAMETERS ;
	tcSkeleton,; && masque de fichiers
	tcSep,; && [,] séparateur de liste
	tlRecurse && [.F.] Explorer les sous-dossiers éventuels
tcSep = Evl(m.tcSep, [,])
LOCAL laFiles[1], lcFolder, lcResult
lcResult = Space(0)
IF lFileAddrSkeleton(m.tcSkeleton)

	ADir(laFiles, m.tcSkeleton, '', 1)
	lcResult = cListOfArray(@m.laFiles, m.tcSep, 1)
	
	* Si dossiers contenus
	IF Vartype(m.tlRecurse) == 'L' AND m.tlRecurse;
	 AND aClear(@m.laFiles);
	 AND aSubFolders(@m.laFiles, JustPath(m.tcSkeleton), '', .T., .T.) > 0

		FOR EACH lcFolder IN laFiles
			lcResult = c2Words(m.lcResult, m.tcSep, cFiles(Addbs(m.lcFolder) + JustFname(m.tcSkeleton), m.tcSep, m.tlRecurse))
		ENDFOR
	ENDIF
ENDIF

RETURN m.lcResult

* ========================================
FUNCTION cFileAddressOK	&& Adresse de fichier possible dans un dossier (ajoute un suffixe au stem du fichier si nécessaire)
LPARAMETERS tcFileAddr	&& Adresse de fichier à vérifier

LOCAL lcPath, lcStem, lcExt, lcStemNew, lnTrial, lcResult

lcResult = Space(0)

IF Vartype(m.tcFileAddr) == 'C'
	lcPath = Addbs(JustPath(m.tcFileAddr))

	IF lDir(m.lcPath) ;
	 AND lFileAddress(m.tcFileAddr)
		lcResult = m.tcFileAddr

		IF File(m.lcResult)
			lcStem = JustStem(m.lcResult)
			lcExt = JustExt(m.lcResult)

			* Ajouter un suffixe au Stem si le fichier existe déjà
			lnTrial = 0
			DO WHILE File(m.lcResult)
				lnTrial = lnTrial + 1
				IF lnTrial > 26	&& les 26 lettres sont déjà utilisées
					lcResult = space(0)
					EXIT
				ENDIF
				lcStemNew = m.lcStem + Chr(96 + m.lnTrial)	&& a, b, c, etc.
				lcResult = m.lcPath + m.lcStemNew + '.' + m.lcExt
			ENDDO
		ENDIF
	ENDIF
ENDIF

RETURN m.lcResult

* ========================================
FUNCTION lFileName && Une chaîne de caractère peut être admise comme nom de fichier
LPARAMETERS tcFileName && nom de fichier à analyser

RETURN .T.;
 AND Vartype(m.tcFileName) = 'C';
 AND !Empty(JustStem(m.tcFileName));
 AND Chrtran(m.tcFileName, CAR_INT_DS_NOM_FICH, Space(0)) == m.tcFileName

* ========================================
FUNCTION lFileSkeleton && Squelette de nom de fichier valide
LPARAMETERS ;
	tcFileSqueleton && Squelette de nom de fichier 

RETURN Vartype(m.tcFileSqueleton) = 'C';
 AND !Empty(m.tcFileSqueleton);
 AND ('*' $ m.tcFileSqueleton OR '?' $ m.tcFileSqueleton);
 AND Chrtran(m.tcFileSqueleton, Chrtran(CAR_INT_DS_NOM_FICH, "?*", Space(0)), Space(0)) == m.tcFileSqueleton

* ========================================
FUNCTION cFileName && Chaîne de caractère admissible comme nom de fichier
LPARAMETERS tcFileName && nom de fichier à analyser

LOCAL lnPeriod, lcStem, lcExt, lcResult

lcResult = Space(0)
IF Vartype(m.tcFileName) == 'C'

	lnPeriod = Ratc('.', m.tcFileName)
	lcExt = Iif(m.lnPeriod > 0, Substr(m.tcFileName, m.lnPeriod + 1), Space(0))
	lcStem = Iif(m.lnPeriod > 0, Substr(m.tcFileName, 1, m.lnPeriod-1), m.tcFileName)
	IF NOT Empty(m.lcStem)
		
		lcStem = Chrtran(m.lcStem, CAR_INT_DS_NOM_FICH, Replicate('_', Len(CAR_INT_DS_NOM_FICH)))
		lcStem = cRepCharDel(m.lcStem, '_')
		lcResult = ForceExt(m.lcStem, m.lcExt)
	ENDIF
ENDIF

RETURN m.lcResult

* ========================================
PROCEDURE cFileName_Test	&& Teste cFileName()

LOCAL loTest as abUnitTest OF abDev.prg
loTest = NewObject('abUnitTest', 'abDev.prg')

loTest.Test( "n_importe quoi.txt", "n:importe quoi.txt")
loTest.Test( "20070529 12_30_02 Maint.csv", "20070529 12:30:02 Maint.csv")
RETURN loTest.Result()

* ========================================
FUNCTION cFileCased && Adresse d'un fichier || dossier avec sa casse originale && Tracy Pearson / http://fox.wikis.com/wc.dll?Wiki~MixedCaseFilePath~VFP
LPARAMETERS ;
	tcFile,; && Adresse du fichier
	tlFullPath && [.F.] Donner l'adresse complète

LOCAL lnWord, llBS, lcFile, laFiles[1], llResult, lcResult

lcResult = Space(0)
IF Vartype(m.tcFile) == 'C' AND (File(m.tcFile) OR lDir(m.tcFile))

	llBS = Rightc(Rtrim(m.tcFile), 1) == '\'
	lcFile = FullPath(m.tcFile)
	lcResult = Iif(Left(m.lcFile, 2) == '\\', '\\', Space(0)); && network drive
	 	+ Upper(GetWordNum(m.lcFile, 1, '\'))

	* Pour chaque dossier dans le chemin, et le fichier
	FOR lnWord = 2 TO GetWordCount(m.lcFile, '\')

		lcResult = m.lcResult + '\'
		DIMENSION laFiles[1] && aClear() peut être indisponible
		laFiles[1] = .F. && Dans VFP localisé en espagnol, laFiles = .F. fait perdre à laFiles son type 'Array'

		llResult = ADir(laFiles, m.lcResult + GetWordNum(m.lcFile, m.lnWord, '\'), [HSD], 1) > 0 && 1 : Display represents original Case in names
		IF m.llResult
			lcResult = m.lcResult + laFiles[1,1]
		ELSE
			EXIT
		ENDIF
	ENDFOR
	
	IF m.llResult
		IF NOT (Vartype(m.tlFullPath) == 'L' AND m.tlFullPath) AND NOT '~' $ m.tcFile
			lcResult = Rightc(m.lcResult, Len(m.tcFile)) && au cas où l'adresse indiquée était partielle
		ENDIF
		IF m.llBS
			lcResult = Addbs(m.lcResult)
		ENDIF
	ELSE
		lcResult = m.lcFile
	ENDIF
ENDIF

RETURN m.lcResult

* ========================================
PROCEDURE cFileCased_Test	&& Teste cFileCased()

LOCAL loTest as abUnitTest OF abDev.prg
loTest = NewObject('abUnitTest', 'abDev.prg')

loTest.Test( "AB\abfile.prg", "ab\abFile.prg")
loTest.Test( "C:\Program Files\VFP9\Tools\AB\abfile.prg", "ab\abFile.prg", .T.)

RETURN loTest.Result()

* ========================================
FUNCTION lPath && Une chaîne de caractère peut être admise comme adresse complète ou relative
LPARAMETERS ;
  tcPath;	&& Adresse à analyser
, tlSkeleton && [.F.] L'adresse peut être un masque de fichiers

RETURN .T.;
	AND Vartype(m.tcPath) == 'C';
	AND NOT Empty(m.tcPath);
	AND m.tcPath == Chrtran(m.tcPath; && aucun caractère interdit
			, Iif(Vartype(m.tlSkeleton) == 'L' and m.tlSkeleton;
				, Chrtran(CAR_INT_DS_ADR_FICH, '?*', '');
				, CAR_INT_DS_ADR_FICH;
				) + CRLF + TABUL;
			, '';
			)

* ========================================
FUNCTION lFullPath && Une chaîne de caractère peut être admise comme adresse complète
LPARAMETERS ;
	tcPath,; && Adresse à analyser
	tlDrive,; && [.F.] Le lecteur doit exister
	tlSkeleton && [.F.] L'adresse peut être un masque de fichiers
	
tlDrive = Vartype(m.tlDrive) == 'L' AND m.tlDrive

RETURN .T.;
	AND lPath(m.tcPath, m.tlSkeleton);
	AND (.F.;
		OR (.T.; && lecteur mappé
			AND isAlpha(JustDrive(m.tcPath));
			AND Substr(m.tcPath, 2, 2) == ':\';
			AND (NOT m.tlDrive OR Directory(JustDrive(m.tcPath)));
			);
		OR (.T.;
			AND Left(m.tcPath, 2) == '\\'; && lecteur réseau
			AND (.F.;
				OR NOT m.tlDrive;
				OR Directory(Left(m.tcPath, At_c('\', m.tcPath, 3)));
				OR Directory(Left(m.tcPath, At_c('\', m.tcPath, 4)));
				);
			);
		)

* ========================================
FUNCTION lFileAddress	&& Adresse de fichier valide
LPARAMETERS tcFileAddr	&& Adresse de fichier à analyser

RETURN .T.;
	AND lFullPath(m.tcFileAddr);
	AND lFileName(JustFname(m.tcFileAddr))

* ========================================
PROCEDURE lFileAddress_Test	&& Teste lFileAddress()

LOCAL loTest as abUnitTest OF abDev.prg
loTest = NewObject('abUnitTest', 'abDev.prg')

loTest.Test(.F., "n'importe quoi")
loTest.Test(.T., "J:\aDossier\3592 VD Vignettes\Client\prop15Ecl.pdf")
loTest.Test(.T., "J:\aDossier\3592 VD Vignettes\Client\prop15\Ecl.pdf")
loTest.Test(.F., "J:\aDossier\3592 VD Vignettes\Client\prop15|Ecl.pdf")

RETURN loTest.Result()

* ========================================*******************************
FUNCTION c83Address && Version courte (8.3) de l'adresse d'un fichier/dossier EXISTANT
LPARAMETER tcPath && Adresse supposée longue (> 8.3)

LOCAL lcResult;
, lnResult;
, lnLength, lcShortName, llPath

lcResult = Space(0)

* Si le fichier ou le dossier existe
IF Vartype(m.tcPath) == 'C'

	tcPath = Upper(Alltrim(m.tcPath))
	llPath = lDir(m.tcPath)
	IF NOT m.llPath && ce doit être une adresse de fichier
		LOCAL ARRAY laFiles[1]
		llPath = ADir(laFiles, m.tcPath) = 1 && file() ne fonctionne pas avec les adresses courtes
	ENDIF
	IF m.llPath

		* Lire l'adresse courte
		DECLARE INTEGER GetShortPathName IN Win32API;
		  STRING @lpszLongPath,	;
		  STRING @lpszShortPath,;
		  INTEGER cchBuffer
		lnLength = 260
		lcShortName = SPACE (m.lnLength)
		lnResult = GetShortPathName(@m.tcPath, @m.lcShortName, m.lnLength)

		lcResult = Iif(m.lnResult > 0;
			, LEFT (m.lcShortName, m.lnResult); && la conversion a réussi
			, m.tcPath; && la conversion a échoué : l'adresse spécifiée est 8.3
			)
	ENDIF
ENDIF

RETURN m.lcResult

* ========================================
FUNCTION cFileFreshest && Adresse de la dernière version d'un fichier d'après son n° de version (suffixe de la racine du nom)
LPARAMETERS ;
	tcFileAddrSkel,; && Masque d'adresse du fichier à trouver (sans n° de version)
	tnVersion && @ n° de la version la plus récente
LOCAL lcResult
lcResult = Space(0)
tnVersion = 0

* Si le chemin existe
IF Vartype(m.tcFileAddrSkel)='C' ;
 AND ! Empty(m.tcFileAddrSkel)

	LOCAL lcPath
	lcPath = Addbs(JustPath(tcFileAddrSkel))
	If Empty(m.lcPath) OR lDir(m.lcPath)

		* Lire la racine du nom sans le n° de version éventuel
		LOCAL lcStem, lcExt
		lcStem = Upper(JustStem(m.tcFileAddrSkel))
		lcExt = Upper(JustExt(m.tcFileAddrSkel))
		DO WHILE Val(Right(m.lcStem, 1)) # 0
			lcStem = Left(m.lcStem, Len(m.lcStem)-1)
		ENDDO

		* Si au moins un fichier a la même racine de nom
		LOCAL lcSkel, lnFiles
		LOCAL ARRAY laFiles[1]
		lcSkel = m.lcStem + IIF (right (m.lcStem, 1) = '*', space(0), '*') + '.' + m.lcExt
		lnFiles = ADir(laFiles, m.lcPath + m.lcSkel)
		IF m.lnFiles > 0
			
			* Pour chaque fichier trouvé,
			LOCAL lnFile, lcSuffixe
			FOR lnFile = m.lnFiles TO 1 STEP -1

				* Lire le suffixe du stem du fichier
				lcSuffixe = Strtran(Upper(JustStem(laFiles[lnFile, 1])), m.lcStem, space(0))	&&	élimine la 'racine'
				lcSuffixe = Chrtran(m.lcSuffixe, ' _-', space(0))	&&	élimine d'éventuels caractères de séparation

				* Si le suffixe n'est composé que de chiffres ou est vide (fichier original)
				IF lDigits(m.lcSuffixe) ;
				 OR Empty(m.lcSuffixe)

					* Stocker le numéro de version dans la deuxième colonne du tableau (à la place de la taille)
					laFiles[lnFile, 2] = Val(m.lcSuffixe)
				
				* Sinon, supprimer le fichier de la liste
				ELSE
					Adel(laFiles, m.lnFile)
					lnFiles = m.lnFiles - 1
				ENDIF
			ENDFOR

			* Si au moins un fichier est valide
			IF m.lnFiles > 0
			
				* Ignoer les fichiers invalides
				DIMENSION laFiles[m.lnFiles, Alen(laFiles, 2)]

				* Trier les fichiers valides par n° de version croissant
				Asort(laFiles, 2)	&&	Trie sur la deuxième colonne

				* Le dernier fichier est celui cherché
				lcResult = m.lcPath + laFiles[m.lnFiles, 1]
				tnVersion = laFiles[m.lnFiles, 2]
			ENDIF
		ENDIF
	ENDIF
ENDIF

RETURN m.lcResult

* ========================================-----
FUNCTION oProjectFiles && Collection Files d'un projet
LPARAMETERS ;
	toProject	&& [Projet courant] Référence à un objet projet ou à sa collection 'Files'
LOCAL loResult
loResult = NULL

LOCAL loResult
DO CASE

CASE Type('m.toProject.baseClass') == 'C' ;
 AND Lower(m.toProject.baseClass) == 'project'
	loResult = m.toProject.files

CASE Type('m.toProject.parent.baseClass') == 'C' ;
 AND Lower(m.toProject.parent.baseClass) == 'project'
	loResult = m.toProject

OTHERWISE
	IF Type('application.activeProject') == 'O'
		loResult = application.activeProject.files
	ENDIF
ENDCASE

RETURN m.loResult

* ========================================-----
PROCEDURE ProjectFileAdd && Ajoute un fichier à un projet ouvert s'il n'y est déjà
LPARAMETERS ;
	tcFileAddr,; && Adresse complète du fichier à ajouter au projet
	toProject,;	&& [Projet courant] Référence à un objet projet ou à sa collection 'Files'
	tlInclude && [.F.] Inclure au projet
LOCAL llResult

* Si une adresse de fichier valide a bien été passée
llResult = Vartype(m.tcFileAddr) = 'C' AND lFile(m.tcFileAddr)
ASSERT m.llResult MESSAGE Program() + CRLF + "Adresse de fichier invalide : " + Transform(m.tcFileAddr)
IF m.llResult
	
	* Si un projet et sa collection de fichiers peuvent être trouvés
	LOCAL loFiles
	loFiles = oProjectFiles(m.toProject)
	llResult = NOT IsNull(m.loFiles)
	ASSERT m.llResult MESSAGE Program() + CRLF + "Aucun projet courant ou spec de projet invalide : " + Transform(m.toProject)
	IF m.llResult

		* Si le fichier n'est pas déjà dans le projet
		LOCAL lcFileAddr, loFile, llFile
		lcFileAddr = c83Address(m.tcFileAddr)
		FOR EACH loFile in m.loFiles
			llFile = JustExt(m.loFile.name) == JustExt(m.tcFileAddr) ; && to save time
			 				AND c83Address(m.loFile.name) == m.lcFileAddr
			IF m.llFile
				EXIT
			ENDIF
		ENDFOR
		IF ! m.llFile

			* Si le ficher est une table ouverte, mémoriser comment elle est ouverte
			&& l'ajout d'une table au projet provoque sa fermeture !
			LOCAL llUsed
			IF Upper(JustExt(m.tcFileAddr)) = 'DBF'

				LOCAL lnUsedCount
				LOCAL ARRAY laUsed[1]
				lnUsedCount = AUsed(laUsed)
				IF m.lnUsedCount > 0

					LOCAL lnUsed, lcAlias
					FOR lnUsed = 1 TO m.lnUsedCount

						lcAlias = laUsed[m.lnUsed, 1] && column 1 contains aliases
						llUsed = c83Address(cTableAddress(m.lcAlias)) == m.lcFileAddr
						IF llUsed

							&& à passer en procédure ...
							LOCAL lcExclusive, lcOrder
							lcExclusive = Iif(IsExclusive(m.lcAlias), 'EXCLUSIVE', Space(0))
							lcOrder = Order(m.lcAlias)
							lcOrder = Iif(Empty(m.lcOrder), Space(0), 'ORDER ') + m.lcOrder
							&& ... à passer en procédure
							USE IN (m.lcAlias)
							EXIT
						ENDIF
					ENDFOR
				ENDIF
			ENDIF

			* Ajouter le fichier au projet
			LOCAL llInclude, loFile
			llInclude = uDefault(m.tlInclude, .F.)
			loFile = m.loFiles.add(m.tcFileAddr)
			loFile.Exclude = not m.llInclude

			* Si le ficher est une table ouverte, rouvrir comme précédemment
			IF m.llUsed
				USE (m.tcFileAddr) in 0 Alias(m.lcAlias) &lcExclusive &lcOrder
			ENDIF
		ENDIF
	ENDIF
ENDIF

RETURN m.llResult

*==============================================
FUNCTION nFileLines && Nombre de lignes dans un fichier
LPARAMETERS ;
	tcFileAddr && Addresse du fichier
LOCAL llResult, lnResult &&  && Taille du fichier en octets
lnResult = 0

* If file can be found
llResult = Vartype(m.tcFileAddr) == 'C' AND File(m.tcFileAddr)
ASSERT m.llResult MESSAGE Program() + CRLF + "Invalid File Address Specification: " + Transform(m.tcFileAddr)
IF m.llResult
	
	lnResult = Occurs(LF, FileToStr(m.tcFileAddr))
ENDIF

RETURN m.lnResult

* ========================================
PROCEDURE FilesExtChange && Change l'extension de fichiers dans un dossier [et ses sous-dossiers]
LPARAMETERS ;
	tcFoldAddr,; && Adresse complète du dossier
	tcExtOld,; && Ancienne extension
	tcExtNew,; && Nouvelle extention
	tlSubFolders,; && [.F.] Chercher aussi dans les sous-dossiers
	tcSubFoldsExcl && [space(0)] Sous-dossiers à exclure de la recherche (séparés par ',')
LOCAL lnResult && nombre de fichiers traités
lnResult = 0

LOCAL llResult
llResult = Vartype(m.tcFoldAddr) == 'C' AND lDir(m.tcFoldAddr)
ASSERT m.llResult MESSAGE Program() + CRLF + "Dossier introuvable" + CRLF + cLitteral(m.tcFoldAddr)
IF m.llResult

	llResult = NOT (Empty(m.tcExtOld) OR Empty(m.tcExtNew))
	ASSERT m.llResult MESSAGE Program() + CRLF + "Extension(s) invalides" + CRLF + cLitteral(m.tcExtOld) + CRLF + cLitteral(m.tcExtNew)
	IF m.llResult
	
		LOCAL llSubFolders, lcSubFoldsExcl
		llSubFolders = uDefault(m.tlSubFolders, .F.)
		lcSubFoldsExcl = uDefault(m.tcSubFoldsExcl, Space(0))
		
		lnResult = FilesProc(m.tcFoldAddr, 'FileExtChange', '*.' + Alltrim(m.tcExtOld), m.llSubFolders, m.lcSubFoldsExcl, Alltrim(m.tcExtNew))
	ENDIF
ENDIF

RETURN m.lnResult

* ========================================
PROCEDURE FileExtChange && Change l'extension de fichiers dans un dossier [et ses sous-dossiers]
LPARAMETERS ;
	tcFileAddr,; && Adresse du fichier
	tcExtNew && Nouvelle extension
LOCAL llResult

llResult = Vartype(m.tcFileAddr) == 'C' and File(m.tcFileAddr)
ASSERT m.llResult MESSAGE Program() + CRLF + "Fichier introuvable" + CRLF + cLitteral(m.tcFileAddr)
IF m.llResult

	llResult = not Empty(m.tcExtNew)
	ASSERT m.llResult MESSAGE Program() + CRLF + "Extension invalide" + CRLF + cLitteral(m.tcExtNew)
	IF m.llResult
	
		LOCAL lcFileAddrNew
		lcFileAddrNew = ForceExt(m.tcFileAddr, m.tcExtNew)
		llResult = NOT lFile(m.lcFileAddrNew)
		ASSERT m.llResult MESSAGE Program() + CRLF + "Le nouveau fichier existe déjà" + CRLF + cLitteral(m.lcFileAddrNew)
		IF m.llResult
			
			RENAME (m.tcFileAddr) TO (m.lcFileAddrNew)
		ENDIF
	ENDIF
ENDIF

RETURN m.llResult

* ========================================
FUNCTION cSpecialFolderPath && Chemin des dossiers spéciaux
LPARAMETERS tiSpecialFolderID && cf. abFile.h
LOCAL lcResult
lcResult = Space(255)

DECLARE SHGetSpecialFolderPath IN SHELL32.DLL;
	LONG hWndOwner,;
	STRING @lcResult,;
	LONG  nWhichFolder

SHGetSpecialFolderPath(0, @lcResult, m.tiSpecialFolderID)

lcResult = Rtrim(m.lcResult)

RETURN Left(m.lcResult, Len(m.lcResult)-1)

* ========================================
FUNCTION FullPath_ && FullPath() amélioré
LPARAMETERS tcFile1, tcFile2
RETURN Iif(Empty(m.tcFile1), Space(0), FullPath(m.tcFile1, m.tcFile2))

* ========================================
FUNCTION ForceStem && Modifie la racine d'une adresse de fichier
LPARAMETERS tcFile, tcStem
RETURN Addbs(JustPath(m.tcFile)) + m.tcStem + '.' + JustExt(m.tcFile) && {V1.11} ForceExt() ne fonctionne pas si la racine du nom de fichier comporte un '.'

* ========================================
PROCEDURE SetPathFull && Change les chemins relatifs dans Set("Path") en chemins absolus

LOCAL laSetPath[1], lnSetPath, liSetPath;
, lcPath, lcRest

lnSetPath = ALines(laSetPath, Set("Path"), 5, ';')
IF m.lnSetPath > 0

	FOR liSetPath = m.lnSetPath TO 1 STEP -1
		lcPath = Upper(m.laSetPath[m.liSetPath])
		IF Directory(m.lcPath) 
			IF NOT m.lcPath == FullPath(m.lcPath)
				laSetPath[m.liSetPath] = FullPath(m.lcPath)
			ENDIF
		ELSE
			Adel(laSetPath, m.liSetPath)
			lnSetPath = m.lnSetPath - 1
		ENDIF
	ENDFOR
	
	IF m.lnSetPath > 0
		DIMENSION laSetPath[m.lnSetPath]
		lnSetPath = aDistinct(@m.laSetPath)
	ENDIF
	SET PATH TO
	IF m.lnSetPath > 0
		lcPath = cListOfArray(@m.laSetPath, ';')
		do while .T.
			lcPath = cTronc(m.lcPath, 4095, .T., @m.lcRest, .T., ';')
			SET PATH to (m.lcPath) additive && When using the ADDITIVE parameter, paths must be included either as a quoted string or valid expression. If you use macro substitution, it must be properly quoted as in following examples
			if Empty(m.lcRest)
				exit
			else
				lcPath = m.lcRest
			endif
		enddo
	ENDIF
ENDIF

* ========================================
function ForceDrive && change la lettre du disque dans une adresse de fichier
lparameters ;
	tcFile,;
	tcDrive

local llResult, liResult, lcResult
lcResult = m.tcFile

llResult = .T.;
	and Vartype(m.tcFile) == 'C';
	and not Empty(m.tcFile);
	and Vartype(m.tcDrive) == 'C';
	and not Empty(m.tcDrive)
assert m.llResult
if m.llResult

	liResult = Evl(At_c(':\', m.tcFile), At_c('\\', m.tcFile))
	llResult = m.liResult > 0
	assert m.llResult
	if m.llResult
		
		lcResult = Stuffc(m.tcFile, 1, m.liResult-1, Alltrim(m.tcDrive, ' ', ':', '\'))
	endif
endif

return m.lcResult

* ========================================
function lFileWritable && Wait for a given delay until a file can be accessed
lparameters cFile, nMS && [Between(m.nMS, 50 ms, 5000 ms)]

local success;
, nSeconds;
, handle

if File(m.cFile)
	declare Sleep in win32API integer nMS
	nSeconds = Seconds()
	nMS = Min(Max(Evl(m.nMS, 0), 50), 5000)
	do while nMS(m.nSeconds) < m.nMS
		handle = Fopen(m.cFile)
		if m.handle > -1
			success = Fclose(m.handle)
			exit
		else
			Sleep(m.nMS / 10)
		endif
	enddo
	nMS = nMS(m.nSeconds) && feedback
	return m.success
else
	return .T.
endif
