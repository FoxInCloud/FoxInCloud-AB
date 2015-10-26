* abFile.prg
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

* ========================================
procedure ReadOnlyClear	&& Supprime l'attribut 'lecture seule' des fichiers d'un dossier
lparameters ;
	tcFolder,; && Adresse du dossier
	tcFileSkel && [*.*] masque de fichiers à traiter

local lnResult && nombre de fichiers traités
lnResult = 0

* Si le dossier existe
if vartype(m.tcFolder) == 'C' and lDir(m.tcFolder)

	local loFiler as filer.FileUtil, loFile, lnAttrib

* Régler le masque à sa valeur par défaut
	tcFileSkel = iif(vartype(m.tcFileSkel) == 'C' and not empty(m.tcFileSkel), m.tcFileSkel, '*.*')

* Créer un objet "filer" pour la recherche et la modification des attributs
	loFiler = createobject('Filer.FileUtil') && dans VFP\tools\filer\Filer.dll

* Charger les fichiers répondant au masque
	loFiler.SearchPath = m.tcFolder
	loFiler.FileExpression = m.tcFileSkel
	loFiler.find (0) && Charge la collection de fichiers

* Supprimer les attributs 'read-only' éventuels
	for each loFile in m.loFiler.files
		lnAttrib = m.loFile.attr
		if mod(m.lnAttrib, 2) > 0 && uneven = read only
			loFile.attr = m.lnAttrib - 1
			lnResult = m.lnResult + 1
		endif
	endfor
endif

return m.lnResult

* ========================================
procedure tFileSet && règle la date et heure d'un fichier
lparameters ;
  result as string; && @ result
, cFile as string;
, tFile as datetime

local success;
, oException as exception;
, oShell as shell.application;
, oFolder;
, oFile

if .t.;
 and (vartype(m.cFile) == 'C' or cResultAdd(@m.result, textmerge([<<m.cFile>> is expected as a String])));
 and (file(m.cFile) or cResultAdd(@m.result, textmerge([File '<<m.cFile>>' can't be found])));
 and (vartype(m.tFile) $ 'DT' or cResultAdd(@m.result, textmerge([<<m.tFile>> is expected as a Date or DateTime])));
 and (!empty(m.tFile) or cResultAdd(@m.result, textmerge([<<m.tFile>> is expected not Empty()])))

	try
		oShell = createobject("Shell.Application")
		if vartype(m.oShell) == 'O'

			oFolder = m.oShell.NameSpace(justpath(fullpath(m.cFile)))
			if vartype(m.oFolder) == 'O'

				oFile = m.oFolder.ParseName(justfname(m.cFile))
				if vartype(m.oFile) == 'O'

					m.oFile.ModifyDate = m.tFile
					success = .t.
				endif
			endif
		endif
	catch to oException
		cResultAdd(@m.result, cException(m.oException))
	endtry
endif

release oFile, oFolder, oShell

=!m.success and cResultAdd(@m.result, textmerge([Could not set Datetime of file <<cL(m.cFile)>> to <<cL(m.tFile)>>]))

return m.success

* -------------------------------
procedure tFileSet_Test	&& Teste tFileSet()

local loTest as abUnitTest of abDev.prg;
, lcFile as string;
, ltFile as datetime

loTest = newobject('abUnitTest', 'abDev.prg')
lcFile = addbs(sys(2023)) + 'tFileSet_Test.txt'

strtofile('tFileSet_Test', m.lcFile)
ltFile = datetime() - 100

loTest.Test(.t., '', m.lcFile, m.ltFile)
loTest.assert(m.ltFile, fdate(m.lcFile, 1))

return m.loTest.result()

* ========================================
procedure PathCreate as Boolean && Crée un chemin de dossiers
lparameters ;
	tcPath,; && Chemin
	tcError,; && [''] @ Détails de l'erreur éventuelle
	tcMessage && [''] @ Message d'erreur éventuel

local llResult as Boolean;
, lcPath;
, lnPath;
, loException as exception

tcPath = iif(empty(justext(m.tcPath)), m.tcPath, justpath(m.tcPath)) && Supprime le nom de fichier éventuel

do case
case lDir(m.tcPath) && le dossier existe déjà
	return

case !lFullPath(m.tcPath)
	return cResultAdd(@m.tcError, textmerge(icase(;
			cLangUser() = 'fr',	['<<m.tcPath>>' devrait être une adresse complète de fichier ou de dossier],; && copy-paste this line to add another language support
													['<<m.tcPath>>' should be a complete file or folder address];
			)))

otherwise

	try

* Pour chaque dossier dans le chemin
		lcPath = upper(getwordnum(m.tcPath, 1, '\')) && disk letter
		for lnPath = 2 to getwordcount(m.tcPath, '\')
			lcPath = m.lcPath + '\' + getwordnum(m.tcPath, m.lnPath, '\')

* Si le dossier n'existe pas, créer
			if not lDir(m.lcPath) && {V1.11} Directory(m.lcPath) ne marche pas pour <user>\appdata\
				md (m.lcPath)
			endif
		endfor
		llResult = .t.

	catch to loException

		llResult = cResultAdd(@m.tcError, cException(m.loException))
		tcMessage = m.loException.message
		assert .f. message m.tcError
		debugout m.tcError
	endtry

	return m.llResult

endcase

endproc

* ========================================
procedure FilesCopy && Copie des fichiers d'un dossier [et ses sous-dossiers] dans un autre dossier
lparameters ;
  tcFileSkels; && Masques de fichiers à traiter
, tcFolderSrce; && Adresse du dossier où sont les fichiers
, tcFolderDest; && Adresse du dossier destination
, tlSubFolders; && [.F.] Chercher dans les sous-dossiers source
, tcSubFoldersExcl; && [space(0)] Sous-dossiers source à exclure de la recherche (séparés par ',')
, tlKeepExisting; && [.F.] Ne pas remplacer si existe déjà - .NULL. ou autre, ignorer
, tcResult; && [''] @ Détail de l'erreur éventuelle
, tnResult; && [0] @ Nombre de fichiers copiés

local lcResult as string

tcFolderSrce = addbs(cFileCased(m.tcFolderSrce, .t.))
tcFolderDest = addbs(iif(directory(m.tcFolderDest), cFileCased(m.tcFolderDest, .t.), m.tcFolderDest))

tnResult = FilesProc(;
	  m.tcFolderSrce; && Adresses des dossiers où les fichiers sont à chercher
	, 'FileCopy'; && Procédure à appliquer à chaque fichier trouvé (son premier paramètre est l'adresse du fichier)
	, m.tcFileSkels; && ['*.*'] Masques de fichiers à traiter (séparés par ',')
	, m.tlSubFolders; && [.F.] Chercher dans les sous-dossiers
	, m.tcSubFoldersExcl; && [space(0)] Sous-dossiers à exclure de la recherche (séparés par ',')
	, textmerge([Stuffc(m.tcFileSrce, 1, Lenc(<<cL(m.tcFolderSrce)>>), <<cL(m.tcFolderDest)>>)]); && Nouvelle adresse (can contain wildcard characters) && @ 2ème paramètre à passer à la procédure (le premier est l'adresse du fichier)
	, @m.lcResult; && [''] @ Détails de l'erreur éventuelle && @ 3ème paramètre à passer à la procédure
	, ; && [''] @ Message d'erreur éventuel && @ 4eme paramètre à passer à la procédure
	, lTrue(m.tlKeepExisting); && [.F.] Ne pas remplacer si existe déjà - .NULL. ou autre, ignorer
	)

return empty(m.lcResult) or cResultAdd(@m.tcResult, m.lcResult)

* ========================================
procedure FileCopy && Copie un fichier en créant le(s) dossier(s) si nécessaire
lparameters ;
	tcFileSrce,; && Adresse actuelle (can contain wildcard characters)
	tcFileDest,; && Nouvelle adresse (can contain wildcard characters)
	tcError,; && [''] @ Détails de l'erreur éventuelle
	tcMessage,; && [''] @ Message d'erreur éventuel
	tlKeepExisting && [.F.] Ne pas remplacer si existe déjà - .NULL. ou autre, ignorer

local llResult; && le fichier a été copié
, lcResult as string;
, lcFileSrce as string;
, lcFileDest as string; && pour éviter remplacement (FilesProc() passe par référence)
, loException as exception;

* Si le fichier existe
lcFileSrce = justfname(m.tcFileSrce)
llResult = '*' $ m.lcFileSrce or '?' $ m.lcFileSrce or lFile(m.tcFileSrce)
if m.llResult

	try

		lcFileDest = iif(lFullPath(m.tcFileDest,, .t.);
			, m.tcFileDest;
			, evaluate(m.tcFileDest); && support des expressions pour FilesCopy()
			)
*? m.lcFileDest
* Si le chemin destination existe ou peut être créé
		llResult = PathCreate(m.lcFileDest, @m.lcResult, @m.tcMessage)
		if m.llResult

			lcFileDest = iif(lDir(m.lcFileDest), forcepath(m.tcFileSrce, m.lcFileDest), m.lcFileDest)
			llResult = not lower(m.tcFileSrce) == lower(m.lcFileDest)
			if m.llResult

				llResult = lTrue(m.tlKeepExisting) and lFile(m.lcFileDest)
				if m.llResult

					store textmerge(icase(;
						cLangUser() = 'fr', 	[Le fichier destination existait en date du <<Fdate(m.lcFileDest, 1)>>, il n'a pas été remplacé],; && copy-paste this line to add another language support
																	[Destination file existed as of <<Fdate(m.lcFileDest, 1)>>, it was not remplaced];
						)) to tcMessage

				else

					copy file (m.tcFileSrce) to (m.lcFileDest) && changes name to lower case
					llResult = .t.

*!*							llResult = Empty(CopyFile(m.tcFileSrce, m.tcFileDest, 0)) && preserves case but ... does not work!
				endif

			else

				lcResult = icase(;
					cLangUser() = 'fr', 	[Les fichier source et destination sont identiques],; && copy-paste this line to add another language support
																[Source and destination files are the same];
					)
			endif
		else
&& PathCreate() returns errors
		endif
	catch to loException
		llResult = .f.
		lcResult = cException(m.loException)
		tcMessage = m.loException.message
	endtry
else
	lcResult = textmerge(icase(;
		cLangUser() = 'fr', 	[Le fichier source '<<m.tcFileSrce>>' est introuvable],; && copy-paste this line to add another language support
													[Source file '<<m.tcFileSrce>>' can't be found];
		))
endif
assert m.llResult message cAssertMsg(textmerge(icase(; && DisplayPath(, 40) does not work with wildcards
		cLangUser() = 'fr',	[Erreur en copiant '<<m.tcFileSrce>>' dans '<<Evl(m.lcFileDest, m.tcFileDest)>>' :],; && copy-paste this line to add another language support
												[Error while copying '<<m.tcFileSrce>>' into '<<Evl(m.lcFileDest, m.tcFileDest)>>':];
		)) + [ ] + m.lcResult)
llResult = m.llResult or cResultAdd(@m.tcError, m.lcResult)

return m.llResult

* ========================================
function CopyFile(tcFileName, tcCopyFileName, tnFailIfExists) && http://www.berezniker.com/content/pages/visual-foxpro/copy-move-rename-file-preserving-destination-name-case
declare long CopyFile in WIN32API string SourceFileName, string DestFileName, long bFailIfExists
return CopyFile(m.tcFileName, m.tcCopyFileName, m.tnFailIfExists)

* ========================================
procedure FileMove && Déplace un ou plusieurs fichier(s) en créant le(s) dossier(s) si nécessaire
lparameters ;
	tcFileSrce, ; && Adresse actuelle (can contain wildcard characters)
	tcFileDest,; && Nouvelle adresse (can contain wildcard characters)
	tlCopyForce,; && [.F.] Toujours copier (pas de RENAME, donc potentiellement plus lent)
	tcResult && @ Résultat
tcResult = space(0)

local loException as exception, llResult

llResult = lFiles(m.tcFileSrce)
assert m.llResult message cAssertMsg(textmerge([<<Program()>> - Le fichier '<<m.tcFileSrce>>' n'existe pas]))
if m.llResult

	llResult = PathCreate(m.tcFileDest, @tcResult)
	if m.llResult

		try
			if lFiles(m.tcFileDest) or lTrue(m.tlCopyForce)

			 	delete file (m.tcFileDest) && évite que le fichier copié hérite
			 	copy file (m.tcFileSrce) to (m.tcFileDest)
				if lFiles(m.tcFileDest) && assure que le fichier a été copié avant de supprimer la source
					delete file (m.tcFileSrce)
				endif
			else

&& When you issue RENAME, FileName2 cannot already exist and FileName1 must exist and cannot be open.
				rename (m.tcFileSrce) to (m.tcFileDest) && déplace le fichier && If the file extensions are not included, the default extension .dbf is assumed
&& RENAME moves the file and keeps its security profile
			endif

		catch to loException
			llResult = .f.
			tcResult = cException(m.loException)
		endtry
	endif

	assert m.llResult message cAssertMsg(textmerge([<<Program()>> - Erreur en déplaçant '<<m.tcFileSrce>>' dans '<<m.tcFileDest>>' : <<m.tcResult>>]))
endif

return m.llResult

* ========================================
procedure FileStrTran && Remplace une chaîne dans un fichier selon StrTran()
lparameters ;
	tcFile,; && fichier où chercher
	cExpressionSought,; && chaîne à remplacer
	cReplacement,; && [''] chaîne remplaçante
	nStartOccurrence,; && [1] première occurrence à traiter
	nNumberOfOccurrences,; && [-1, all] && nombre d'occurrences à traiter
	nFlags && [0] réglages selon StrTran()

if file(m.tcFile) and vartype(m.cExpressionSought) == 'C'

	local lcFile
	lcFile = filetostr(m.tcFile)

	return .f.;
		 or empty(m.lcFile);
		 or strtofile(;
					strtran(;
						m.lcFile;
					, m.cExpressionSought;
					,	evl(m.cReplacement, '');
					, evl(m.nStartOccurrence, 1);
					,	evl(m.nNumberOfOccurrences, -1);
					,	evl(m.nFlags, 0);
					);
				, m.tcFile;
				) > 0

else
	return .null.
endif

* ========================================
function lDir && Un dossier existe
lparameters tcDir, tlStrict && Adresse du dossier ; supporte wildcard
local array laTemp[1]
return .T.;
 and vartype(m.tcDir) == 'C';
 and not empty(m.tcDir);
 and Iif(lTrue(m.tlStrict);
	 , adir(laTemp, addbs(m.tcDir), 'DHS') >= 1; && Directory, Hidden, System
	 , directory(m.tcDir);
	 )

* ========================================
function lDirEmpty && Un dossier existe et est vide
lparameters tcDir && Adresse du dossier ; supporte wildcard
local laTemp[1]

return lDir(m.tcDir);
 and adir(laTemp, forcepath('*.*', m.tcDir), [DHS]) = 2;
 and laTemp[1,1] == '.';
 and laTemp[2,1] == '..'

* ========================================
function lFile && Un fichier existe (plus rapide et précis que File() car ne cherche pas dans le PATH)
lparameters ;
	tcFileAddr,; && Adresse du fichier dont il faut vérifier l'existence, complète ou dans Curdir()
	tnSize,; && @ [0] Taille en octets - .T.: identifier fichiers multiples
	ttModified,; && @ [Datetime(1900,1,1,0,0,0)] Date et Heure de Dernière modification
	tcAttribs && @ [''] Attributs

local llResult, laFile[1], lnFile, llFiles

if ga_Type_IsChar(m.tcFileAddr, .t.) && Vartype(m.tcFileAddr) == 'C'

	lnFile = adir(laFile, m.tcFileAddr, 'HS') && , 1 inutile
	llFiles = lTrue(m.tnSize)
	llResult = iif(m.llFiles, m.lnFile > 0, m.lnFile = 1)
	if m.llResult and not m.llFiles and pcount() > 1

		tnSize = m.laFile[1, 2]
		ttModified = tDateCTime(m.laFile[1, 3], m.laFile[1, 4])
		tcAttribs = m.laFile[1, 5]
	endif
endif

if not (m.llResult or m.llFiles)
	tnSize = 0
	ttModified = datetime(1900,1,1,0,0,0)
	tcAttribs = ''
endif

return m.llResult

* -------------------------------
procedure lFile_Test	&& Teste lFile

local loTest as abUnitTest
loTest = newobject('abUnitTest', 'abDev.prg')

local lcFileAddr, lnSize, ltModified, lcAttribs
lcFileAddr = getfile()
loTest.Test(.t., m.lcFileAddr, @lnSize, @ltModified, @lcAttribs)
? "Taille, date et attributs du fichier", m.lcFileAddr, CRLF, m.lnSize, m.ltModified, m.lcAttribs


* ========================================
function lFiles && Un ou plusieurs fichiers existent selon un masque
lparameters tcFileAddrSkeleton && Masque de l'adresse des fichiers dont il faut vérifier l'existence

local laFiles[1]

return aFiles(@m.laFiles, m.tcFileAddrSkeleton) > 0

* ========================================
function aFiles && Fichiers selon un masque d'adresse
lparameters ;
	taFiles,; && @ Noms des Fichiers
	tcFileAddrSkeleton && Masque de l'adresse des fichiers

local llResult, lnResult && Nombre de fichiers trouvés

lnResult = 0

llResult = lFileAddrSkeleton(m.tcFileAddrSkeleton) and aClear(@m.taFiles)
assert m.llResult message cAssertMsg(textmerge([Invalid File skeleton specification : <<cLitteral(m.tcFileAddrSkeleton)>>]))
if m.llResult

	lnResult = adir(m.taFiles, m.tcFileAddrSkeleton, '', 1)
	if m.lnResult > 0

		aColsDel(@taFiles, 2) && retourne les seuls noms des fichiers
	endif
endif

return m.lnResult

external array taFiles

* ========================================
function aFiles_ && Fichiers selon un ou plusieurs masque dans un dossier [et ses sous-dossiers]
lparameters ;
  taFiles; && @ Addresses des Fichiers
, tcFileSkels; && Masques de fichiers à traiter
, tcFolder; && Adresse du dossier où les fichiers sont à chercher
, tlSubFolders; && [.F.] Chercher dans les sous-dossiers
, tcSubFoldersExcl && [space(0)] Sous-dossiers à exclure de la recherche (séparés par ',')

local lnResult as integer;
, llResult as Boolean;
, laFiles[1] as string;
, lnFiles as integer;
, liFile  as integer;
, laFolder[1] as string;
, lcFolder as string;
, laFileSkel[1] as string;
, lcFileSkel as string;

lnResult = 0

if .t.;
 and aClear(@m.taFiles);
 and alines(m.laFileSkel, m.tcFileSkels, 5, ',', ';') > 0

	if m.tlSubFolders and aSubFolders(; && Sous-dossiers d'un dossier /!\ Récursive
			  @m.laFolder; && @ taSubFolders Sous-dossiers selon aDir()
			, m.tcFolder; && tcFolder [dossier courant] Adresse du dossier où rechercher les sous-dossiers
			, m.tcSubFoldersExcl; && tcFoldersExcl [''] sous-dossiers à exclure et/ou masque des fichiers attendus dans les dossiers à inclure
			, .t.; && tvRecurse [.F.] Récurser dans les sous-sous-dossiers etc., si N, nombre de niveaux de récursion
			, .t.; && tlAddrOnly [.F.] Ne garder que les adresses des dossiers (supprimer date, taille, etc.)
			) > 0
		aPush(@m.laFolder, m.tcFolder)
	else
		laFolder = m.tcFolder
	endif

	for each lcFolder in m.laFolder
		for each lcFileSkel in m.laFileSkel
			lcFolder = addbs(m.lcFolder)
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
function lFileAddrSkeleton && Squelette d'adresse de fichier valide
lparameters ;
	tcFileAddrSkeleton && Masque de l'adresse des fichiers à vérifier

if vartype(m.tcFileAddrSkeleton) == 'C';
 and not empty(m.tcFileAddrSkeleton);
 and lDir(justpath(m.tcFileAddrSkeleton))

	tcFileAddrSkeleton = addbs(fullpath(justpath(m.tcFileAddrSkeleton))) + justfname(m.tcFileAddrSkeleton)

	local lcStem, lcExt

	lcStem = juststem(m.tcFileAddrSkeleton)
	lcExt = justext(m.tcFileAddrSkeleton)

	return lFileAddress(m.tcFileAddrSkeleton);
		or	'?' $ m.lcStem ;
		or	'*' $ m.lcStem ;
		or	'?' $ m.lcExt ;
		or	'*' $ m.lcExt
else
	return .f.
endif

* ========================================
function lFileExclusive && Un fichier peut être ouvert en exclusif
lparameters ;
	tcFileAddr && Adresse du fichier dont il faut vérifier l'accès exclusif
local lnHandle, llResult

if vartype(m.tcFileAddr) == 'C' and not empty(m.tcFileAddr)

	llResult = lFileAddress(m.tcFileAddr)
	assert m.llResult message cAssertMsg(textmerge([<<Program()>> - Invalid file specification: <<cLitteral(m.tcFileAddr)>>]))
	if m.llResult

		lnHandle = fopen(m.tcFileAddr, 12) && 12 : Read and Write unbuffered
		llResult = m.lnHandle > 0
		if m.llResult

			fclose(m.lnHandle)
		endif
	endif
endif

return m.llResult

* ========================================
function lFileFresher	&& Un fichier est plus récent qu'un autre
lparameters ;
	tcFile1Addr,; && Adresse du fichier de base
	tcFile2Addr && Adresse du fichier à comparer

* Si les deux fichiers existent
return iif(vartype(m.tcFile1Addr)=='C';
	 and lFile(fullpath(m.tcFile1Addr));
	 and vartype(m.tcFile2Addr)=='C';
	 and lFile(fullpath(m.tcFile2Addr));
 , fdate(m.tcFile2Addr, 1) > fdate(m.tcFile1Addr, 1);
 , .null.;
 )

* ========================================
procedure FilesDir && Répertorie des fichiers dans un dossier [et ses sous-dossiers]
lparameters ;
	tcFileSkels,; && Masques de fichiers à traiter
	tcFolders,; && Adresse du dossier où les fichiers sont à chercher
	tlSubFolders,; && [.F.] Chercher dans les sous-dossiers
	tcSubFoldersExcl,; && [space(0)] Sous-dossiers à exclure de la recherche (séparés par ',')
	tcTable,; && @ Répertoire de fichiers : table ou curseur ; si vide, nouveau curseur ; Alias en retour
	tcFieldsExtra,; && [aucun] spécifications de champs à ajouter à la table
	tcTagsExtra && [aucun] spécifications d'index à ajouter à la table (cf. aTagInfo_())

local loDeleted as abSet, lnResult as integer && Nombre de fichers répertoriés, -1 si erreur

tcTable = FilesDirCursor(m.tcTable, m.tcFieldsExtra)

loDeleted = abSet('DELETED', 'OFF')
delete all in (m.tcTable) && cf. FileDir()

lnResult = iif(used(m.tcTable);
	, FilesProc(m.tcFolders, 'FileDir', m.tcFileSkels, m.tlSubFolders, m.tcSubFoldersExcl, m.tcTable);
	, -1)

return m.lnResult

* ========================================
procedure FilesDirCursor && Ouvre ou crée une table ou un curseur d'inventaire de fichiers
lparameters ;
	tcTable,; && @ Table ou curseur pour répertoire de fichiers ; si vide, nouveau curseur
	tcFieldsExtra,; && [aucun] spécifications de champs à ajouter à la table
	tcTagsExtra,; && [aucun] spécifications d'index à ajouter à la table (cf. aTagInfo_())
	tcAlias && @ [JustStem(m.tcTable)] Alias d'ouverture

local llResult as Boolean

llResult = TableFreeCreateOrAdjust(;
			evl(m.tcTable, sys(2015));
		,	@m.tcAlias;
		,	FilesDirCursor_cFields(m.tcFieldsExtra);
		,	FilesDirCursor_cTags(m.tcTagsExtra);
		)

assert m.llResult message cAssertMsg(textmerge([<<Program()>> - le curseur ou la table '<<m.tcTable>>' ne peut être ouvert ou créé]))

return iif(m.llResult, m.tcAlias, space(0))

* ========================================
function FilesDirCursor_cFields && Champs de la table ou curseur d'inventaire de fichiers
lparameters tcFieldsExtra && [aucun] spécifications de champs à ajouter à la table

return c2Words(;
					[FILEDIR I, cNAME C(106), cSTEM C(100), cEXT C(5), mADDR M, nBYTES I NULL, tMOD T, tDIR T, CHECKSUM C(12) NULL]; && 100 est largement suffisant pour Abaque
				,	',';
				,	evl(m.tcFieldsExtra, space(0));
				)

* ========================================
function FilesDirCursor_cTags && Indexes de la table ou curseur d'inventaire de fichiers
lparameters tcTagsExtra && [aucun] spécifications d'index à ajouter à la table (cf. aTagInfo_())

local lcResult
text TO lcResult TEXTMERGE NOSHOW FLAGS 1 PRETEXT 3 && selon aTagInfo() && && Tag; Type; Key; Filter; Order; Collation
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

return m.lcResult

* ========================================
function cFilesDirCursorCKexpr && Expression de clé candidate sur une table d'inventaire de fichiers
lparameters tcAddr
return textmerge([Padr(Upper(Rtrim(<<m.tcAddr>>)), 200)])

* ========================================
procedure FileDir && Répertorie un fichier
lparameters ;
	tcFile,; && Addresse du fichier
	tcAlias,; && Répertoire de fichiers
	tcError && @ Erreur en retour (cumulative)
tcFile = alltrim(m.tcFile)

local loDeleted as abSet, loException as exception, lnBytes, ltFile, lcCheckSum, llResult

llResult = file(m.tcFile)
if m.llResult

	loDeleted = abSet('DELETED', 'OFF')
	lnBytes = nFileSize(m.tcFile, .t.) && < 1 ms
	ltFile = tFile(m.tcFile, .t.)
	lcCheckSum = iif(m.lnBytes < VFP_VAR_SIZE_MAX, cFileCheckSum(m.tcFile, .t.), .null.)

	try


		if seek(evaluate(cFilesDirCursorCKexpr('m.tcFile')), m.tcAlias, 'FILECK')

			recall in (m.tcAlias)

			if not lower(evaluate(m.tcAlias + '.mAddr')) == lower(m.tcFile) && évite le MEMO bloat
				replace in (m.tcAlias);
					mAddr with m.tcFile
			endif

			if evaluate(m.tcAlias + '.nBYTES') # m.lnBytes;
			 or evaluate(m.tcAlias + '.tMOD') # m.ltFile;
			 or not luEqual(evaluate(m.tcAlias + '.CHECKSUM'), m.lcCheckSum)

				replace in (m.tcAlias);
					nBYTES with m.lnBytes;
					tMOD with m.ltFile;
					CHECKSUM with m.lcCheckSum;
					tDIR with datetime()

			endif

		else

			insert into (m.tcAlias) (; && After executing the INSERT command, Visual FoxPro sets the record pointer on the new record
					  FileDir;
					, cNAME;
					, cSTEM;
					, cEXT;
					, mAddr;
					, nBYTES;
					, tMOD;
					, tDIR;
					, CHECKSUM;
					);
			 values (;
			 			iAutoInc(m.tcAlias, 'FILEDIR');
					,	upper(justfname(m.tcFile));
					,	upper(juststem(m.tcFile));
					,	upper(justext(m.tcFile));
					,	m.tcFile;
					,	m.lnBytes;
					,	m.ltFile;
					,	datetime();
					, m.lcCheckSum;
					)
		endif

	catch to loException

		llResult = cResultAdd(@m.tcError, cException(m.loException))
	endtry
endif

return m.llResult

*==============================================
function FileMemo(tcFile) && Fichier mémo associé à un fichier-table VFP

local lcExt

lcExt = lower(justext(m.tcFile))

return icase(;
	m.lcExt == 'vcx',;
		forceext(m.tcFile, 'vct'),;
	m.lcExt == 'scx',;
		 forceext(m.tcFile, 'sct'),;
	m.lcExt == 'mnx',;
		 forceext(m.tcFile, 'mnt'),;
	m.lcExt == 'frx',;
		 forceext(m.tcFile, 'frt'),;
	m.lcExt == 'lbx',;
		 forceext(m.tcFile, 'lbt'),;
	m.lcExt == 'pjx',;
		 forceext(m.tcFile, 'pjt'),;
	m.lcExt == 'dbc',;
		 forceext(m.tcFile, 'dct'),;
	.t.;
	and inlist(m.lcExt, 'dbf', 'vmx'); && 'vmx' pour Visual Fox Extend
	and lFPT(m.tcFile),;
		forceext(m.tcFile, 'fpt'),;
		'';
	)

*==============================================
function FileIndex(tcFile) && Fichier index associé à un fichier-table VFP

local lcExt

lcExt = lower(justext(m.tcFile))
return icase(;
	m.lcExt == 'dbc', forceext(m.tcFile, 'dcx'),;
	m.lcExt == 'dbf', icase(;
		lFile(forceext(m.tcFile, 'cdx')), forceext(m.tcFile, 'cdx'),;
		lFile(forceext(m.tcFile, 'idx')), forceext(m.tcFile, 'idx'),;
		space(0)),;
	m.lcExt == 'mnx', forceext(m.tcFile, 'mpr'),; && just a workaround
	space(0);
)

*==============================================
function tFile && Date et heure de dernière modification d'un fichier et/ou de ses fichiers liés
lparameters ;
	tcFile,; && Fichier
	tlMemo && [.F.] Tenir compte du fichier memo associé éventuel

tcFile = fullpath(m.tcFile)
tlMemo = iif(lTrue(m.tlMemo), FileMemo(m.tcFile), space(0))

local ltResult

try
	ltResult = icase(;
		!lFile(m.tcFile),; && File() peut répondre .T. et Fdate() ne trouve pas le fichier
			{/:},;
		lFile(m.tlMemo),;
			max(fdate(m.tcFile, 1), fdate(m.tlMemo, 1)),;
			fdate(m.tcFile, 1); && 1: last modification DateTime
			)
catch && erreur 'file not found' dans certains cas inexpliquables
	ltResult = {/:}
endtry

return m.ltResult

*==============================================
function cFileSizeTotal && Taille d'un fichier et de ses fichiers associés
lparameters tcFile && Fichier

return cFileSize(;
	  @m.tcFile;
	, .t.; && tlMemo Tenir compte du fichier memo associé éventuel
	, .t.; && tlCDX Tenir compte du fichier CDX associé éventuel
	)

*==============================================
function cFileSize && Taille d'un fichier
lparameters ;
	tcFile,; && Fichier
	tlMemo,; && [.F.] Tenir compte du fichier memo associé éventuel @ le fichier memo existe
	tlCDX && [.F.] Tenir compte du fichier CDX associé éventuel @ le fichier CDX existe

local result

result = nFileSize(@m.tcFile, @m.tlMemo, @m.tlCDX)

return icase(;
	not vartype(m.result) == 'N',;
		m.result,;
	m.result >= 1024^3,;
		ltrim(transform(m.result/1024^3, '9,999.9 GB')),;
	m.result >= 1024^2,;
		ltrim(transform(m.result/1024^2, '9,999.9 MB')),;
	m.result > 1024,;
		ltrim(transform(m.result/1024, '9,999.9 kB')),;
		ltrim(transform(m.result, '9,999 B'));
	)

*==============================================
function cMB && Valeur en Méga Octets
lparameters ;
  tnSize;
, tcLangUser && [cLangUser()] Langue de l'utilisateur

tcLangUser = cLangUser(m.tcLangUser)

return '';
	+ ltrim(transform(m.tnSize/2^20, '999.99'));
	+ ' ';
	+ icase(;
		m.tcLangUser = 'fr', 	'MO',; && copy-paste this line to add another language support
													'MB'; && default: English
		)

*==============================================
function cGB && Valeur en Giga Octets
lparameters ;
  tnSize;
, tcLangUser && [cLangUser()] Langue de l'utilisateur

tcLangUser = cLangUser(m.tcLangUser)

return '';
	+ ltrim(transform(m.tnSize/2^30, '999.99'));
	+ ' ';
	+ icase(;
		m.tcLangUser = 'fr', 	'GO',; && copy-paste this line to add another language support
													'GB'; && default: English
		)

*==============================================
function cFileSizeMB && Taille d'un fichier en Méga Octets
lparameters ;
	tcFile,; && Fichier
	tlMemo,; && [.F.] Tenir compte du fichier memo associé éventuel
	tcLangUser && [cLangUser()] Langue de l'utilisateur

return cMB(nFileSize(m.tcFile, m.tlMemo))

*==============================================
function nFileSizeTotal && Taille d'un fichier et de ses fichiers associés
lparameters tcFile && Fichier

return nFileSize(;
	  @m.tcFile;
	, .t.; && tlMemo Tenir compte du fichier memo associé éventuel
	, .t.; && tlCDX Tenir compte du fichier CDX associé éventuel
	)

*==============================================
function nFileSize && Taille d'un fichier en octets
lparameters ;
	tcFile,; && Fichier
	tlMemo,; && [.F.] @ Ajouter la taille du fichier memo associé éventuel @ le fichier memo existe
	tlCDX && [.F.] @ Ajouter la taille du fichier CDX associé éventuel @ le fichier CDX existe

local lnResult; &&  && Taille du fichier en octets
, lcMemo;
, lcCDX;
, llCompatible;
, lnMemoWidth;
, lHandle;
, llResult

* If file can be found
llResult = vartype(m.tcFile) == 'C' and file(m.tcFile)
assert m.llResult message cAssertMsg(textmerge([<<Program()>> - Invalid File Address Specification: <<m.tcFile>>]))
if m.llResult

	if lTrue(m.tlMemo)
		lcMemo = FileMemo(m.tcFile)
		tlMemo = not empty(m.lcMemo) && @ feedback
	endif

	if lTrue(m.tlCDX)
		lcCDX = forceext(m.tcFile, 'cdx')
		tlCDX = file(m.lcCDX) && @ feedback
	endif

	try
		llCompatible = set("Compatible") == 'OFF'
		if m.llCompatible
			lnMemoWidth = set("Memowidth")
			set compatible on
		endif
		lnResult = 0;
			+ fsize(m.tcFile);
			+ iif(m.tlMemo, fsize(m.lcMemo), 0);
			+ iif(m.tlCDX, fsize(m.lcCDX), 0)
	catch
		llResult = .f.
	finally
		if m.llCompatible and set("Compatible") == 'ON'
			set memowidth to m.lnMemoWidth
			set compatible off
		endif
	endtry

	if !m.llResult

		lHandle = fopen(justfname(m.tcFile), 10)
		llResult = lHandle # -1
		if m.llResult

			lnResult = fseek(m.lHandle, 0, 2)
			fclose(m.lHandle)
			lnResult = m.lnResult;
				+ iif(m.tlMemo, nFileSize(m.lcMemo), 0);
				+ iif(m.tlCDX, nFileSize(m.lcCDX), 0)

		else

&& probably an included file
			try
				lnResult = 0;
					+ len(filetostr(m.tcFile));
					+ iif(m.tlMemo, len(filetostr(m.lcMemo)), 0);
					+ iif(m.tlCDX, len(filetostr(m.lcCDX)), 0)
				llResult = m.lnResult > 0

				tcFile = iif(m.llResult;
					, cFileCased(iif(wlAutomation();
						, _vfp.servername;
						, cModuleInfo(sys(16,0), 'Address');
						)) + '!' + justfname(m.tcFile);
					, m.tcFile;
					)
			catch
			endtry
		endif
	endif
endif

return iif(m.llResult, m.lnResult, .null.)

*----------------------------------------
procedure nFileSize_Test && teste nFileSize()

local loTest as abUnitTest of abDev.prg;
, lcFile;
, lnFile

loTest = newobject('abUnitTest', 'abDev.prg')

lcFile = sys(2023) + 'nFileSize_Test.txt'
lnFile = 10000
strtofile(replicate('a', m.lnFile), m.lcFile)
loTest.Test(m.lnFile, m.lcFile)
erase (m.lcFile)

loTest.Test(.null., cModuleInfo(sys(16), 'Address')) && file can't be accessed

return loTest.result()

*========================================
function cFileCheckSum && Checksum du contenu d'un fichier avec, le cas échéant, son fichier lié
lparameters ;
	tcFile,; && Fichier
	tlMemo,; && [.F.] Inclure le memo associé éventuel
	tnPadr && [none] Longueur à padder
tcFile = evl(m.tcFile, '')
tlMemo = lTrue(m.tlMemo)

local tnFile, lcFile, llFile, lnFile, llResult, lcResult

lcResult = .null.

if file(m.tcFile)

	tnFile = nFileSize(m.tcFile)
	llResult = not isnull(m.tnFile) && la taille du fichier a pu être calculée
	if m.llResult

		llResult = m.tnFile < VFP_VAR_SIZE_MAX
		assert m.llResult message cAssertMsg(textmerge([<<Proper(Program())>>() - ] + icase(;
			cLangUser() = 'fr',	[La taille du fichier '<<JustFname(m.tcFile)>>' excède la limite VFP de 16 Mo],; && copy-paste this line to add another language support
													[Size of file '<<JustFname(m.tcFile)>>' exceeds the VFP 16 Mb limitation];
		)))
		if .t.;
		 and m.llResult;
		 and vartype(m.tlMemo) == 'L';
		 and m.tlMemo

			lcFile = FileMemo(m.tcFile)
			llFile = file(m.lcFile)
			if m.llFile

				lnFile = nFileSize(m.lcFile)
				llResult = not isnull(m.lnFile) && la taille du fichier a pu être calculée
				if m.llResult

					llResult = m.lnFile < VFP_VAR_SIZE_MAX
					assert m.llResult message cAssertMsg(textmerge([<<Proper(Program())>>() - ] + icase(;
						cLangUser() = 'fr',	[La taille du fichier '<<JustFname(m.lcFile)>>' dépasse la limite VFP de 16 Mo],; && copy-paste this line to add another language support
																[Size of file '<<JustFname(m.lcFile)>>' exceeds the VFP 16 Mb limitation];
					)))
					if m.llResult

						llResult = m.tnFile + m.lnFile < VFP_VAR_SIZE_MAX
						assert m.llResult message cAssertMsg(textmerge([<<Proper(Program())>>() - ] + icase(;
							cLangUser() = 'fr',	[La taille des fichiers '<<JustFname(m.tcFile)>>' et '<<JustFname(m.lcFile)>>' dépasse la limite VFP de 16 Mo],; && copy-paste this line to add another language support
																	[Size of files '<<JustFname(m.tcFile)>>' and '<<JustFname(m.lcFile)>>' exceeds the VFP 16 Mb limitation];
						)))
					endif
				endif
			endif
		endif
	endif
	if m.llResult

		lcResult = sys(2007;
			, filetostr(m.tcFile) + iif(m.llFile, filetostr(m.lcFile), space(0));
			, -1; && nSeed : Specifies a numeric seed value of 0 that is used to calculate the checksum and is included for backward compatibility. Passing a value of -1 for nSeed uses the default system value of 0. For CRC32 calculations, Visual FoxPro disregards nSeed.
			, 1; && CRC32 - For CRC32 calculations, Visual FoxPro disregards nSeed
			)
	endif
endif

return iif(m.llResult and vartype(m.tnPadr) == 'N' and m.tnPadr > 0;
	, padr(m.lcResult, m.tnPadr);
	, m.lcResult;
	)

* ========================================
procedure FilesRename && Renomme des fichiers dans un dossier [et ses sous-dossiers]
lparameters ;
	tcFileSkels,; && Masques de fichiers à traiter (séparés par ',')
	tcFileNew,; && Nouveau nom
	tcFolders,; && Adresses des dossiers où les fichiers sont à chercher
	tlSubFolders,; &&	[.F.] Chercher dans les sous-dossiers
	tcSubFoldersExcl && [space(0)] Sous-dossiers à exclure de la recherche (séparés par ',')

return iif(lFileSkeleton(m.tcFileSkels) and m.tcFileSkels # [*.*];
	, FilesProc(m.tcFolders, 'FileRename', m.tcFileSkels, m.tlSubFolders, m.tcSubFoldersExcl, m.tcFileNew);
	, 0)

* ========================================
procedure FileRename && Renomme un fichier
lparameters ;
	tcFile,; && Addresse du fichier à renommer
	tcFileNew && Nouveau nom
tcFileNew = forcepath(m.tcFileNew, justpath(m.tcFile))

local llResult

llResult = not lFile(m.tcFileNew)
assert m.llResult message cAssertMsg(textmerge([<<Program()>> - Impossible de renommer <<m.tcFile>> en <<m.tcFileNew>> car ce fichier existe déjà]))
if m.llResult
	rename (m.tcFile) to (m.tcFileNew)
endif

return m.llResult

* ========================================
procedure FilesDelete && Alias de FilesDel()
lparameters ;
	tcFileSkels,; && Masques de fichiers à traiter
	tcFolders,; && Adresse du dossier où sont les fichiers
	tlSubFolders,; && [.F.] Chercher dans les sous-dossiers
	tcSubFoldersExcl,; && [space(0)] Sous-dossiers à exclure de la recherche (séparés par ',')
	tlRecycle,; && [.F.] Placer les fichiers supprimés dans la corbeille
	tlDirsEmptyDel,; && [.F.] Supprimer les dossiers vides
	tcError && [''] @ Détail de l'erreur éventuelle

return FilesDel(;
		m.tcFileSkels;
	,	m.tcFolders;
	,	m.tlSubFolders;
	,	m.tcSubFoldersExcl;
	,	m.tlRecycle;
	,	m.tlDirsEmptyDel;
	,	@m.tcError;
	)

* ========================================
procedure FilesDel && Supprime des fichiers dans un dossier [et ses sous-dossiers]
lparameters ;
	tcFileSkels,; && Masques de fichiers à traiter
	tcFolders,; && Adresse du dossier où sont les fichiers
	tlSubFolders,; && [.F.] Chercher dans les sous-dossiers
	tcSubFoldersExcl,; && [space(0)] Sous-dossiers à exclure de la recherche (séparés par ',')
	tlRecycle,; && [.F.] Placer les fichiers supprimés dans la corbeille
	tlDirsEmptyDel,; && [.F.] Supprimer les dossiers vides
	tcResult,; && [''] @ Détail de l'erreur éventuelle
	tnResult; && [0] @ Nombre de fichiers copiés

tlRecycle = lTrue(m.tlRecycle)

local llResult as Boolean;
, lcResult as string

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

llResult = empty(m.lcResult) or cResultAdd(@m.tcResult, m.lcResult)

* Supprimer les répertoires vides résiduels
if m.llResult and lTrue(m.tlDirsEmptyDel)

	local laFolders[1], lcFolder, laSubFolders[1], lcSubFolder
	alines(laFolders, m.tcFolders, 1, ',', ';')
	for each lcFolder in m.laFolders
		if m.tlSubFolders and aSubFolders(@m.laSubFolders, m.lcFolder, m.tcSubFoldersExcl, .t., .t.) > 0
			for each lcSubFolder in m.laSubFolders
				if lDirEmpty(m.lcSubFolder)
					rd (m.lcSubFolder)
				endif
			endfor
		endif
		try
			if lDirEmpty(m.lcFolder)
				rd (m.lcFolder)
			endif
		catch
		endtry
	endfor
endif

return m.llResult

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
procedure FileDel && Supprime un fichier
lparameters ;
	tcFile,; && Addresse du fichier à supprimer
	tlRecycle,; && [.F.] Placer les fichiers dans la corbeille
	tlDirsEmptyDel,; && [.F.] Supprimer les dossiers vides
	tcResult && [''] @ Détail de l'erreur éventuelle, cumulative

local lcRecycle;
, lcPath;
, loException as exception;
, llResult

try

	lcRecycle = iif(lTrue(m.tlRecycle), 'RECYCLE', '')

	if inlist(lower(justext(m.tcFile)), 'fxp', 'prg') and upper(forceext(m.tcFile, 'fxp')) $ set("Procedure")
		release procedure (m.tcFile)
	endif

	delete file (m.tcFile) &lcRecycle

	lcPath = justpath(m.tcFile)
	if lTrue(m.tlDirsEmptyDel) and lDirEmpty(m.lcPath)
		rd (m.lcPath)
	endif

	llResult = .t.

catch to loException

	loException = cException(m.loException)
	llResult = cResultAdd(@m.tcResult, m.loException)
	assert m.llResult message cAssertMsg(textmerge([Erreur en supprimant '<<m.tcFile>>' : <<m.loException>>]))

endtry

return m.llResult


* ========================================
procedure FilesProc && Applique une procédure à tous les fichiers d'un dossier [et de ses sous-dossiers] - jusqu'à 5 paramètres peuvent être passés à la procédure
lparameters ;
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

tcFileSkels = iif(vartype(m.tcFileSkels) == 'C', alltrim(m.tcFileSkels), [*.*])
tlSubFolders = lTrue(m.tlSubFolders)
tcSubFoldersExcl = iif(m.tlSubFolders and vartype(m.tcSubFoldersExcl)=='C', upper(m.tcSubFoldersExcl), space(0))

local llResult, lnResult && Nombre de fichiers traités
lnResult = 0

* Si les paramètres requis sont valides
llResult = vartype(m.tcFolders)=='C' and not empty(m.tcFolders);
			 and vartype(m.tcProc) == 'C' and not empty(m.tcProc) && comment vérifier que la procédure est accessible ?
assert m.llResult message cAssertMsg(textmerge([<<Program()>> - Les dossiers <<cLitteral(@tcFolders)>> ou la procédure <<cLitteral(@tcProc)>> est invalide]))
if m.llResult

	local laSkels[1], lnSkels, lcSkel, lnDocs, laDocs[1], laDocsSkel[1], laSubFolders[1], lnSubFolders, lnSubFolder
	lnSkels = alines(laSkels, m.tcFileSkels, .t., ',')

* Pour chaque dossier
	local laFolders[1], lcFolder
	alines(laFolders, m.tcFolders, 1, [,], [;])
	for each lcFolder in laFolders

* Si le dossier existe
		llResult = lDir(m.lcFolder)
		assert m.llResult message cAssertMsg(textmerge([<<Program()>> - le dossier '<<m.lcFolder>>' n'existe pas]))
		if m.llResult
			lcFolder = addbs(cFileCased(fullpath(m.lcFolder)))
			aClear(@m.laDocs)
			lnDocs = 0

* Tabuler les fichiers situés dans le dossier et répondant au(x) masque(s)
			for each lcSkel in laSkels
				if adir(laDocsSkel,  m.lcFolder + m.lcSkel, '', 1) > 0 && pas de dossier && capitalization on disk
					lnDocs = aAppend(@m.laDocs, @m.laDocsSkel)
				endif
			endfor
			asort(laDocs, 1, -1, 0, 1) && ascending, case insensitive

* Si recherche dans les sous-dossiers demandée,
			if m.tlSubFolders

* Si sous-dossier(s) dans le dossier
				lnSubFolders = aSubFolders(@m.laSubFolders, m.lcFolder, m.tcSubFoldersExcl)
				if m.lnSubFolders > 0

* Supprimer l'adresse du dossier de départ && par cohérence avec le aDir() ci-dessus
					for lnSubFolder = 1 to m.lnSubFolders
						laSubFolders[m.lnSubFolder, 1] = strtran(laSubFolders[m.lnSubFolder, 1], m.lcFolder, space(0), 1, -1, 1)
					endfor
					asort(laSubFolders, 1, -1, 0, 1) && ascending, case insensitive

* Ajouter les sous-dossiers AVANT les documents
					lnDocs = aAppend(@m.laDocs, @m.laSubFolders,, .t.)
				endif
			endif

* Si le dossier comporte des documents
			if m.lnDocs > 0

* Préparer la chaine de paramètres à passer à la procédure
				local lcProcParms, lnProcParms, lnProcParm
				lnProcParms = pcount() - 5; && les paramètres commencent en 6è position
																+ 1 && les n° de paramètres commencent à 2
				lcProcParms = space(0)
				if m.lnProcParms >= 2
					for lnProcParm = 2 to m.lnProcParms
						lcProcParms = textmerge([<<m.lcProcParms>>, @m.tuProcParm<<Padl(m.lnProcParm, 2, '0')>>])
					endfor
				endif

* Pour chaque "document" (fichier ou sous-dossier)
				local lnDoc, lcDoc, lcDocAddr, llDoc
				for lnDoc = 1 to m.lnDocs
					lcDoc = laDocs[m.lnDoc, 1]
					lcDocAddr = m.lcFolder + m.lcDoc

* Si dossier exploitable, récurser le cas échéant
					if 'D' $ upper(laDocs[m.lnDoc, 5])

						if m.tlSubFolders and not inlist(m.lcDoc, '.', '..')
						 	lnResult = m.lnResult + ; && récursion
						 		evaluate('FilesProc(m.lcDocAddr, m.tcProc, m.tcFileSkels, m.tlSubFolders, m.tcSubFoldersExcl' + m.lcProcParms + ')')
						endif

* Sinon (fichier), appliquer la procédure indiquée
					else

						llDoc = evaluate(textmerge([<<m.tcProc>>(m.lcDocAddr <<m.lcProcParms>>)]))
						lnResult = m.lnResult + iif(m.llDoc, 1, 0)
					endif
				endfor
			endif
		endif
	endfor
endif

return m.lnResult

* -------------------------------
procedure FilesProc_Test && Teste FilesProc()

local loTest as abUnitTest
loTest = newobject('abUnitTest', 'abDev.prg')
loTest.Test(, getdir(curdir(),'',"Où sont les fichiers Excel à traiter ?", 16), ;
						'FilesProc_Test_Proc', '*.xls', .t., '', date())

return loTest.result()

* ------------------------------------
	procedure FilesProc_Test_Proc	&& Procédure appelée par FilesProc_Test()
	lparameters ;
		tcFile,;
		tuParm

* Afficher l'adresse du fichier et le paramètre
	? cFileCased(m.tcFile), ' -- paramètre :', transform(m.tuParm)

* ========================================
function cFileSubFolders && Fichier dans un dossier ou un des ses sous-dossiers
lparameters ;
	tcFile,; && Adresse du fichier
	tcFoldersExcl,; && [''] sous-dossiers à exclure et/ou masque des fichiers attendus dans les dossiers à inclure
	tvRecurse && [.F.] Récurser dans les sous-sous-dossiers etc., si N, nombre de niveaux de récursion

local laFolders[1], lcFolder, lcFile, llResult, lcResult

lcResult = space(0)
llResult = file(m.tcFile)
if m.llResult
	lcResult = cFileCased(m.tcFile, .t.)
else
	lcFile = justfname(m.tcFile)
	if aSubFolders(@m.laFolders, justpath(m.tcFile), m.tcFoldersExcl, m.tvRecurse, .t.) > 0
		for each lcFolder in laFolders
			lcFolder = addbs(m.lcFolder) + m.lcFile
			if file(m.lcFolder)
				lcResult = cFileCased(m.lcFolder, .t.)
				exit
			endif
		endfor
	endif
endif

return m.lcResult

* ========================================
function aSubFolders && Sous-dossiers d'un dossier /!\ Récursive
lparameters ;
	taSubFolders,; && @ Sous-dossiers selon aDir()
	tcFolder,; && [dossier courant] Adresse du dossier où rechercher les sous-dossiers
	tcFoldersExcl,; && [''] sous-dossiers à exclure et/ou masque des fichiers attendus dans les dossiers à inclure
	tvRecurse,; && [.F.] Récurser dans les sous-sous-dossiers etc., si N, nombre de niveaux de récursion
	tlAddrOnly && [.F.] Ne garder que les adresses des dossiers (supprimer date, taille, etc.)
external array taSubFolders && pour le gestionnaire de projet
tcFolder = addbs(fullpath(evl(m.tcFolder, space(0))))
tcFoldersExcl = iif(vartype(m.tcFoldersExcl) == 'C', m.tcFoldersExcl, space(0))

local lcTypeRecurse, llRecurse, llFirst, lcDefault;
, laFolders[1], lnFolder, lcFolder, llFolder, lcPath, lnSubFolders, lnFileSkel;
, llResult, lnResult && Nombre de sous-dossiers trouvés

lcTypeRecurse = vartype(m.tvRecurse)
tvRecurse = iif(m.lcTypeRecurse == 'N' and m.tvRecurse > 0, m.tvRecurse, m.lcTypeRecurse == 'L' and m.tvRecurse)
lnResult = 0

* Si les paramètres requis sont valides
llResult = type('taSubFolders', 1) == 'A' && aClear() est fait plus loin à la première récursion
assert m.llResult message cAssertMsg(textmerge([<<Program()>> - Le premier paramètre <<cLitteral(taSubFolders)>> doit être un tableau]))
if m.llResult

	llResult = lDir(m.tcFolder, .t.)
*		ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([<<Program()>> - Le dossier '<<m.tcFolder>>' est introuvable]))
	if m.llResult

* Si première récursion && optimisation
		if vartype(m.pnFoldersExcl) == 'U'

			tcFolder = cFileCased(m.tcFolder)
			aClear(@taSubFolders) && Vide le résultat
* Tabuler les dossiers à exclure et/ou les masques de fichiers à trouver dans les dossiers
			private pnFoldersExcl, paFoldersExcl, pnFileSkel, paFileSkel, pnRecurse
			dimension paFoldersExcl[1], paFileSkel[1]
			pnFoldersExcl = alines(paFoldersExcl, m.tcFoldersExcl, 1+4, [,], [;])
			pnFileSkel = 0
			if m.pnFoldersExcl > 0

				for lnFolder = m.pnFoldersExcl to 1 step -1
					lcFolder = paFoldersExcl[m.lnFolder]

					if lFileSkeleton(m.lcFolder)
						pnFoldersExcl = m.pnFoldersExcl - 1
						adel(paFoldersExcl, m.lnFolder)
						pnFileSkel = m.pnFileSkel + 1
						dimension paFileSkel[m.pnFileSkel]
						paFileSkel[m.pnFileSkel] = m.lcFolder
					endif
				endfor
				if m.pnFoldersExcl > 0
					dimension paFoldersExcl[m.pnFoldersExcl]
				endif
			endif
			llFirst = .t.
			pnRecurse = 1
		else
			pnRecurse = m.pnRecurse + 1
		endif

* Pour chaque sous-dossier
		lcDefault = sys(5) + curdir()
		set default to (m.tcFolder)
		lnResult = adir(laFolders, space(0), 'D', 1) && space(0) makes aDir() return Folders
		set default to (m.lcDefault)

		llRecurse = iif(m.lcTypeRecurse == 'N', m.pnRecurse < m.tvRecurse, m.tvRecurse)
		lnSubFolders = 0
		for lnFolder = m.lnResult to 1 step -1
			lcFolder = laFolders[m.lnFolder, 1]
			lcPath = m.tcFolder + addbs(m.lcFolder)

* Si bidon ou exclus, supprimer
			llFolder = not (inlist(m.lcFolder, '.', '..'); && bidon
				 or m.pnFoldersExcl > 0 and ascan(paFoldersExcl, m.lcFolder, 1, -1, 1, 1+2+4) > 0; && exclus
				)
			if m.llFolder

* Si récursion demandée, compter les sous-dossiers
				lnSubFolders = m.lnSubFolders + iif(m.llRecurse;
					, aSubFolders(@taSubFolders, m.lcPath, m.tcFoldersExcl, m.tvRecurse, m.tlAddrOnly);
					, 0)

				if m.pnFileSkel > 0
					llFolder = .f.
					for lnFileSkel = 1 to m.pnFileSkel
						llFolder = m.llFolder or lFiles(m.lcPath + m.paFileSkel[m.lnFileSkel])
					endfor
				endif
			endif

* Si le dossier est OK, ajouter à la liste sinon supprimer
			if m.llFolder
				laFolders[m.lnFolder, 1] = m.lcPath
			else
				adel(laFolders, m.lnFolder)
				lnResult = m.lnResult - 1
			endif
		endfor

* Si des dossiers ont été trouvés
		if m.lnResult > 0
			dimension laFolders[m.lnResult, Alen(laFolders, 2)]

* Si demandé, supprimer les colonnes superflues
			if lTrue(m.tlAddrOnly)
				aColsDel(@m.laFolders, 2)
				dimension laFolders[Alen(m.laFolders)]
			endif

* Ajouter les dossiers au résultat
			aAppend(@taSubFolders, @m.laFolders,, .t.) && bottom up
		endif

		lnResult = m.lnResult + m.lnSubFolders
		pnRecurse = m.pnRecurse - 1
		if m.pnRecurse = 1 and m.lnResult > 0
			asort(taSubFolders, 1, -1, -1, 1)
		endif
	endif
endif

return m.lnResult

* ========================================
function cFolder && Dossier d'une addresse
lparameters tcAddress && adresse

local lcPath, lcResult

lcResult = space(0)
if vartype(m.tcAddress) == 'C' and not empty(m.tcAddress)
	lcPath = justpath(m.tcAddress)
	lcResult = substr(m.lcPath, ratc('\', m.lcPath)+1)
endif

return m.lcResult

* ========================================
function cFolders && Dossiers d'une liste d'addresses
lparameters tcAddresses && Adresses

local laAddress[1], lnAddress, lcResult

lcResult = space(0)
if vartype(m.tcAddresses) == 'C' and not empty(m.tcAddresses)

	for lnAddress = 1 to alines(laAddress, m.tcAddresses, 1, ',', ';', CRLF, CR, LF)
		laAddress[m.lnAddress] = cFolder(laAddress[m.lnAddress])
	endfor
	lcResult = cListOfArray(@m.laAddress)
endif

return m.lcResult

* ========================================
function cFiles && Fichiers selon un masque
lparameters ;
	tcSkeleton,; && masque de fichiers
	tcSep,; && [,] séparateur de liste
	tlRecurse && [.F.] Explorer les sous-dossiers éventuels
tcSep = evl(m.tcSep, [,])
local laFiles[1], lcFolder, lcResult
lcResult = space(0)
if lFileAddrSkeleton(m.tcSkeleton)

	adir(laFiles, m.tcSkeleton, '', 1)
	lcResult = cListOfArray(@m.laFiles, m.tcSep, 1)

* Si dossiers contenus
	if lTrue(m.tlRecurse);
	 and aClear(@m.laFiles);
	 and aSubFolders(@m.laFiles, justpath(m.tcSkeleton), '', .t., .t.) > 0

		for each lcFolder in laFiles
			lcResult = c2Words(m.lcResult, m.tcSep, cFiles(addbs(m.lcFolder) + justfname(m.tcSkeleton), m.tcSep, m.tlRecurse))
		endfor
	endif
endif

return m.lcResult

* ========================================
function cFileAddressOK	&& Adresse de fichier possible dans un dossier (ajoute un suffixe au stem du fichier si nécessaire)
lparameters tcFileAddr	&& Adresse de fichier à vérifier

local lcPath, lcStem, lcExt, lcStemNew, lnTrial, lcResult

lcResult = space(0)

if vartype(m.tcFileAddr) == 'C'
	lcPath = addbs(justpath(m.tcFileAddr))

	if lDir(m.lcPath) ;
	 and lFileAddress(m.tcFileAddr)
		lcResult = m.tcFileAddr

		if file(m.lcResult)
			lcStem = juststem(m.lcResult)
			lcExt = justext(m.lcResult)

* Ajouter un suffixe au Stem si le fichier existe déjà
			lnTrial = 0
			do while file(m.lcResult)
				lnTrial = lnTrial + 1
				if lnTrial > 26	&& les 26 lettres sont déjà utilisées
					lcResult = space(0)
					exit
				endif
				lcStemNew = m.lcStem + chr(96 + m.lnTrial)	&& a, b, c, etc.
				lcResult = m.lcPath + m.lcStemNew + '.' + m.lcExt
			enddo
		endif
	endif
endif

return m.lcResult

* ========================================
function lFileName && Une chaîne de caractère peut être admise comme nom de fichier
lparameters tcFileName && nom de fichier à analyser

return .t.;
 and vartype(m.tcFileName) = 'C';
 and !empty(juststem(m.tcFileName));
 and chrtran(m.tcFileName, CAR_INT_DS_NOM_FICH, space(0)) == m.tcFileName

* ========================================
function lFileSkeleton && Squelette de nom de fichier valide
lparameters ;
	tcFileSqueleton && Squelette de nom de fichier

return vartype(m.tcFileSqueleton) = 'C';
 and !empty(m.tcFileSqueleton);
 and ('*' $ m.tcFileSqueleton or '?' $ m.tcFileSqueleton);
 and chrtran(m.tcFileSqueleton, chrtran(CAR_INT_DS_NOM_FICH, "?*", space(0)), space(0)) == m.tcFileSqueleton

* ========================================
function cFileName && Chaîne de caractère admissible comme nom de fichier
lparameters tcFileName && nom de fichier à analyser

local lnPeriod, lcStem, lcExt, lcResult

lcResult = space(0)
if vartype(m.tcFileName) == 'C'

	lnPeriod = ratc('.', m.tcFileName)
	lcExt = iif(m.lnPeriod > 0, substr(m.tcFileName, m.lnPeriod + 1), space(0))
	lcStem = iif(m.lnPeriod > 0, substr(m.tcFileName, 1, m.lnPeriod-1), m.tcFileName)
	if not empty(m.lcStem)

		lcStem = chrtran(m.lcStem, CAR_INT_DS_NOM_FICH, replicate('_', len(CAR_INT_DS_NOM_FICH)))
		lcStem = cRepCharDel(m.lcStem, '_')
		lcResult = forceext(m.lcStem, m.lcExt)
	endif
endif

return m.lcResult

* ========================================
procedure cFileName_Test	&& Teste cFileName()

local loTest as abUnitTest of abDev.prg
loTest = newobject('abUnitTest', 'abDev.prg')

loTest.Test( "n_importe quoi.txt", "n:importe quoi.txt")
loTest.Test( "20070529 12_30_02 Maint.csv", "20070529 12:30:02 Maint.csv")
return loTest.result()

* ========================================
function cFileCased && Adresse d'un fichier || dossier avec sa casse originale && Tracy Pearson / http://fox.wikis.com/wc.dll?Wiki~MixedCaseFilePath~VFP
lparameters ;
	tcFile,; && Adresse du fichier
	tlFullPath && [.F.] Donner l'adresse complète

local lnWord, llBS, lcFile, laFiles[1], llResult, lcResult

lcResult = space(0)
if vartype(m.tcFile) == 'C' and (file(m.tcFile) or lDir(m.tcFile))

	llBS = rightc(rtrim(m.tcFile), 1) == '\'
	lcFile = fullpath(m.tcFile)
	lcResult = iif(left(m.lcFile, 2) == '\\', '\\', space(0)); && network drive
	 	+ upper(getwordnum(m.lcFile, 1, '\'))

* Pour chaque dossier dans le chemin, et le fichier
	for lnWord = 2 to getwordcount(m.lcFile, '\')

		lcResult = m.lcResult + '\'
		dimension laFiles[1] && aClear() peut être indisponible
		laFiles[1] = .f. && Dans VFP localisé en espagnol, laFiles = .F. fait perdre à laFiles son type 'Array'

		llResult = adir(laFiles, m.lcResult + getwordnum(m.lcFile, m.lnWord, '\'), [HSD], 1) > 0 && 1 : Display represents original Case in names
		if m.llResult
			lcResult = m.lcResult + laFiles[1,1]
		else
			exit
		endif
	endfor

	if m.llResult
		if not (lTrue(m.tlFullPath)) and not '~' $ m.tcFile
			lcResult = rightc(m.lcResult, len(m.tcFile)) && au cas où l'adresse indiquée était partielle
		endif
		if m.llBS
			lcResult = addbs(m.lcResult)
		endif
	else
		lcResult = m.lcFile
	endif
endif

return m.lcResult

* ========================================
procedure cFileCased_Test	&& Teste cFileCased()

local loTest as abUnitTest of abDev.prg
loTest = newobject('abUnitTest', 'abDev.prg')

loTest.Test( "AB\abfile.prg", "ab\abFile.prg")
loTest.Test( "C:\Program Files\VFP9\Tools\AB\abfile.prg", "ab\abFile.prg", .t.)

return loTest.result()

* ========================================
function lPath && Une chaîne de caractère peut être admise comme adresse complète ou relative
lparameters ;
  tcPath;	&& Adresse à analyser
, tlSkeleton && [.F.] L'adresse peut être un masque de fichiers

return .t.;
	and vartype(m.tcPath) == 'C';
	and not empty(m.tcPath);
	and m.tcPath == chrtran(m.tcPath; && aucun caractère interdit
			, iif(lTrue(m.tlSkeleton);
				, chrtran(CAR_INT_DS_ADR_FICH, '?*', '');
				, CAR_INT_DS_ADR_FICH;
				) + CRLF + TABUL;
			, '';
			)

* ========================================
function lFullPath && Une chaîne de caractère peut être admise comme adresse complète
lparameters ;
	tcPath,; && Adresse à analyser
	tlDrive,; && [.F.] Le lecteur doit exister
	tlSkeleton && [.F.] L'adresse peut être un masque de fichiers

tlDrive = lTrue(m.tlDrive)

return .t.;
	and lPath(m.tcPath, m.tlSkeleton);
	and (.f.;
		or (.t.; && lecteur mappé
			and isalpha(justdrive(m.tcPath));
			and substr(m.tcPath, 2, 2) == ':\';
			and (not m.tlDrive or directory(justdrive(m.tcPath)));
			);
		or (.t.;
			and left(m.tcPath, 2) == '\\'; && lecteur réseau
			and (.f.;
				or not m.tlDrive;
				or directory(left(m.tcPath, at_c('\', m.tcPath, 3)));
				or directory(left(m.tcPath, at_c('\', m.tcPath, 4)));
				);
			);
		)

* ========================================
function lFileAddress	&& Adresse de fichier valide
lparameters tcFileAddr	&& Adresse de fichier à analyser

return .t.;
	and lFullPath(m.tcFileAddr);
	and lFileName(justfname(m.tcFileAddr))

* ========================================
procedure lFileAddress_Test	&& Teste lFileAddress()

local loTest as abUnitTest of abDev.prg
loTest = newobject('abUnitTest', 'abDev.prg')

loTest.Test(.f., "n'importe quoi")
loTest.Test(.t., "J:\aDossier\3592 VD Vignettes\Client\prop15Ecl.pdf")
loTest.Test(.t., "J:\aDossier\3592 VD Vignettes\Client\prop15\Ecl.pdf")
loTest.Test(.f., "J:\aDossier\3592 VD Vignettes\Client\prop15|Ecl.pdf")

return loTest.result()

* ========================================*******************************
function c83Address && Version courte (8.3) de l'adresse d'un fichier/dossier EXISTANT
lparameter tcPath && Adresse supposée longue (> 8.3)

local lcResult;
, lnResult;
, lnLength, lcShortName, llPath

lcResult = space(0)

* Si le fichier ou le dossier existe
if vartype(m.tcPath) == 'C'

	tcPath = upper(alltrim(m.tcPath))
	llPath = lDir(m.tcPath)
	if not m.llPath && ce doit être une adresse de fichier
		local array laFiles[1]
		llPath = adir(laFiles, m.tcPath) = 1 && file() ne fonctionne pas avec les adresses courtes
	endif
	if m.llPath

* Lire l'adresse courte
		declare integer GetShortPathName in Win32API;
		  string @lpszLongPath,	;
		  string @lpszShortPath,;
		  integer cchBuffer
		lnLength = 260
		lcShortName = space (m.lnLength)
		lnResult = GetShortPathName(@m.tcPath, @m.lcShortName, m.lnLength)

		lcResult = iif(m.lnResult > 0;
			, left (m.lcShortName, m.lnResult); && la conversion a réussi
			, m.tcPath; && la conversion a échoué : l'adresse spécifiée est 8.3
			)
	endif
endif

return m.lcResult

* ========================================
function cFileFreshest && Adresse de la dernière version d'un fichier d'après son n° de version (suffixe de la racine du nom)
lparameters ;
	tcFileAddrSkel,; && Masque d'adresse du fichier à trouver (sans n° de version)
	tnVersion && @ n° de la version la plus récente
local lcResult
lcResult = space(0)
tnVersion = 0

* Si le chemin existe
if vartype(m.tcFileAddrSkel)='C' ;
 and ! empty(m.tcFileAddrSkel)

	local lcPath
	lcPath = addbs(justpath(tcFileAddrSkel))
	if empty(m.lcPath) or lDir(m.lcPath)

* Lire la racine du nom sans le n° de version éventuel
		local lcStem, lcExt
		lcStem = upper(juststem(m.tcFileAddrSkel))
		lcExt = upper(justext(m.tcFileAddrSkel))
		do while val(right(m.lcStem, 1)) # 0
			lcStem = left(m.lcStem, len(m.lcStem)-1)
		enddo

* Si au moins un fichier a la même racine de nom
		local lcSkel, lnFiles
		local array laFiles[1]
		lcSkel = m.lcStem + iif (right (m.lcStem, 1) = '*', space(0), '*') + '.' + m.lcExt
		lnFiles = adir(laFiles, m.lcPath + m.lcSkel)
		if m.lnFiles > 0

* Pour chaque fichier trouvé,
			local lnFile, lcSuffixe
			for lnFile = m.lnFiles to 1 step -1

* Lire le suffixe du stem du fichier
				lcSuffixe = strtran(upper(juststem(laFiles[lnFile, 1])), m.lcStem, space(0))	&&	élimine la 'racine'
				lcSuffixe = chrtran(m.lcSuffixe, ' _-', space(0))	&&	élimine d'éventuels caractères de séparation

* Si le suffixe n'est composé que de chiffres ou est vide (fichier original)
				if lDigits(m.lcSuffixe) ;
				 or empty(m.lcSuffixe)

* Stocker le numéro de version dans la deuxième colonne du tableau (à la place de la taille)
					laFiles[lnFile, 2] = val(m.lcSuffixe)

* Sinon, supprimer le fichier de la liste
				else
					adel(laFiles, m.lnFile)
					lnFiles = m.lnFiles - 1
				endif
			endfor

* Si au moins un fichier est valide
			if m.lnFiles > 0

* Ignoer les fichiers invalides
				dimension laFiles[m.lnFiles, Alen(laFiles, 2)]

* Trier les fichiers valides par n° de version croissant
				asort(laFiles, 2)	&&	Trie sur la deuxième colonne

* Le dernier fichier est celui cherché
				lcResult = m.lcPath + laFiles[m.lnFiles, 1]
				tnVersion = laFiles[m.lnFiles, 2]
			endif
		endif
	endif
endif

return m.lcResult

* ========================================-----
function oProjectFiles && Collection Files d'un projet
lparameters ;
	toProject	&& [Projet courant] Référence à un objet projet ou à sa collection 'Files'
local loResult
loResult = null

local loResult
do case

case type('m.toProject.baseClass') == 'C' ;
 and lower(m.toProject.baseclass) == 'project'
	loResult = m.toProject.files

case type('m.toProject.parent.baseClass') == 'C' ;
 and lower(m.toProject.parent.baseclass) == 'project'
	loResult = m.toProject

otherwise
	if type('application.activeProject') == 'O'
		loResult = application.activeproject.files
	endif
endcase

return m.loResult

* ========================================-----
procedure ProjectFileAdd && Ajoute un fichier à un projet ouvert s'il n'y est déjà
lparameters ;
	tcFileAddr,; && Adresse complète du fichier à ajouter au projet
	toProject,;	&& [Projet courant] Référence à un objet projet ou à sa collection 'Files'
	tlInclude && [.F.] Inclure au projet
local llResult

* Si une adresse de fichier valide a bien été passée
llResult = vartype(m.tcFileAddr) = 'C' and lFile(m.tcFileAddr)
assert m.llResult message program() + CRLF + "Adresse de fichier invalide : " + transform(m.tcFileAddr)
if m.llResult

* Si un projet et sa collection de fichiers peuvent être trouvés
	local loFiles
	loFiles = oProjectFiles(m.toProject)
	llResult = not isnull(m.loFiles)
	assert m.llResult message program() + CRLF + "Aucun projet courant ou spec de projet invalide : " + transform(m.toProject)
	if m.llResult

* Si le fichier n'est pas déjà dans le projet
		local lcFileAddr, loFile, llFile
		lcFileAddr = c83Address(m.tcFileAddr)
		for each loFile in m.loFiles
			llFile = justext(m.loFile.name) == justext(m.tcFileAddr) ; && to save time
			 				and c83Address(m.loFile.name) == m.lcFileAddr
			if m.llFile
				exit
			endif
		endfor
		if ! m.llFile

* Si le ficher est une table ouverte, mémoriser comment elle est ouverte
&& l'ajout d'une table au projet provoque sa fermeture !
			local llUsed
			if upper(justext(m.tcFileAddr)) = 'DBF'

				local lnUsedCount
				local array laUsed[1]
				lnUsedCount = aused(laUsed)
				if m.lnUsedCount > 0

					local lnUsed, lcAlias
					for lnUsed = 1 to m.lnUsedCount

						lcAlias = laUsed[m.lnUsed, 1] && column 1 contains aliases
						llUsed = c83Address(cTableAddress(m.lcAlias)) == m.lcFileAddr
						if llUsed

&& à passer en procédure ...
							local lcExclusive, lcOrder
							lcExclusive = iif(isexclusive(m.lcAlias), 'EXCLUSIVE', space(0))
							lcOrder = order(m.lcAlias)
							lcOrder = iif(empty(m.lcOrder), space(0), 'ORDER ') + m.lcOrder
&& ... à passer en procédure
							use in (m.lcAlias)
							exit
						endif
					endfor
				endif
			endif

* Ajouter le fichier au projet
			local llInclude, loFile
			llInclude = uDefault(m.tlInclude, .f.)
			loFile = m.loFiles.add(m.tcFileAddr)
			loFile.Exclude = not m.llInclude

* Si le ficher est une table ouverte, rouvrir comme précédemment
			if m.llUsed
				use (m.tcFileAddr) in 0 alias(m.lcAlias) &lcExclusive &lcOrder
			endif
		endif
	endif
endif

return m.llResult

*==============================================
function nFileLines && Nombre de lignes dans un fichier
lparameters ;
	tcFileAddr && Addresse du fichier
local llResult, lnResult &&  && Taille du fichier en octets
lnResult = 0

* If file can be found
llResult = vartype(m.tcFileAddr) == 'C' and file(m.tcFileAddr)
assert m.llResult message program() + CRLF + "Invalid File Address Specification: " + transform(m.tcFileAddr)
if m.llResult

	lnResult = occurs(LF, filetostr(m.tcFileAddr))
endif

return m.lnResult

* ========================================
procedure FilesExtChange && Change l'extension de fichiers dans un dossier [et ses sous-dossiers]
lparameters ;
	tcFoldAddr,; && Adresse complète du dossier
	tcExtOld,; && Ancienne extension
	tcExtNew,; && Nouvelle extention
	tlSubFolders,; && [.F.] Chercher aussi dans les sous-dossiers
	tcSubFoldsExcl && [space(0)] Sous-dossiers à exclure de la recherche (séparés par ',')
local lnResult && nombre de fichiers traités
lnResult = 0

local llResult
llResult = vartype(m.tcFoldAddr) == 'C' and lDir(m.tcFoldAddr)
assert m.llResult message program() + CRLF + "Dossier introuvable" + CRLF + cLitteral(m.tcFoldAddr)
if m.llResult

	llResult = not (empty(m.tcExtOld) or empty(m.tcExtNew))
	assert m.llResult message program() + CRLF + "Extension(s) invalides" + CRLF + cLitteral(m.tcExtOld) + CRLF + cLitteral(m.tcExtNew)
	if m.llResult

		local llSubFolders, lcSubFoldsExcl
		llSubFolders = uDefault(m.tlSubFolders, .f.)
		lcSubFoldsExcl = uDefault(m.tcSubFoldsExcl, space(0))

		lnResult = FilesProc(m.tcFoldAddr, 'FileExtChange', '*.' + alltrim(m.tcExtOld), m.llSubFolders, m.lcSubFoldsExcl, alltrim(m.tcExtNew))
	endif
endif

return m.lnResult

* ========================================
procedure FileExtChange && Change l'extension de fichiers dans un dossier [et ses sous-dossiers]
lparameters ;
	tcFileAddr,; && Adresse du fichier
	tcExtNew && Nouvelle extension
local llResult

llResult = vartype(m.tcFileAddr) == 'C' and file(m.tcFileAddr)
assert m.llResult message program() + CRLF + "Fichier introuvable" + CRLF + cLitteral(m.tcFileAddr)
if m.llResult

	llResult = not empty(m.tcExtNew)
	assert m.llResult message program() + CRLF + "Extension invalide" + CRLF + cLitteral(m.tcExtNew)
	if m.llResult

		local lcFileAddrNew
		lcFileAddrNew = forceext(m.tcFileAddr, m.tcExtNew)
		llResult = not lFile(m.lcFileAddrNew)
		assert m.llResult message program() + CRLF + "Le nouveau fichier existe déjà" + CRLF + cLitteral(m.lcFileAddrNew)
		if m.llResult

			rename (m.tcFileAddr) to (m.lcFileAddrNew)
		endif
	endif
endif

return m.llResult

* ========================================
function cSpecialFolderPath && Chemin des dossiers spéciaux
lparameters tiSpecialFolderID && cf. abFile.h
local lcResult
lcResult = space(255)

declare SHGetSpecialFolderPath in SHELL32.dll;
	long hWndOwner,;
	string @lcResult,;
	long  nWhichFolder

SHGetSpecialFolderPath(0, @lcResult, m.tiSpecialFolderID)

lcResult = rtrim(m.lcResult)

return left(m.lcResult, len(m.lcResult)-1)

* ========================================
function FullPath_ && FullPath() amélioré
lparameters tcFile1, tcFile2
return iif(empty(m.tcFile1), space(0), fullpath(m.tcFile1, m.tcFile2))

* ========================================
function ForceStem && Modifie la racine d'une adresse de fichier
lparameters tcFile, tcStem
return addbs(justpath(m.tcFile)) + m.tcStem + '.' + justext(m.tcFile) && {V1.11} ForceExt() ne fonctionne pas si la racine du nom de fichier comporte un '.'

* ========================================
procedure SetPathFull && Change les chemins relatifs dans Set("Path") en chemins absolus

local laSetPath[1], lnSetPath, liSetPath;
, lcPath, lcRest

lnSetPath = alines(laSetPath, set("Path"), 5, ';')
if m.lnSetPath > 0

	for liSetPath = m.lnSetPath to 1 step -1
		lcPath = upper(m.laSetPath[m.liSetPath])
		if directory(m.lcPath)
			if not m.lcPath == fullpath(m.lcPath)
				laSetPath[m.liSetPath] = fullpath(m.lcPath)
			endif
		else
			adel(laSetPath, m.liSetPath)
			lnSetPath = m.lnSetPath - 1
		endif
	endfor

	if m.lnSetPath > 0
		dimension laSetPath[m.lnSetPath]
		lnSetPath = aDistinct(@m.laSetPath)
	endif
	set path to
	if m.lnSetPath > 0
		lcPath = cListOfArray(@m.laSetPath, ';')
		do while .t.
			lcPath = cTronc(m.lcPath, 4095, .t., @m.lcRest, .t., ';')
			set path to (m.lcPath) additive && When using the ADDITIVE parameter, paths must be included either as a quoted string or valid expression. If you use macro substitution, it must be properly quoted as in following examples
			if empty(m.lcRest)
				exit
			else
				lcPath = m.lcRest
			endif
		enddo
	endif
endif

* ========================================
function ForceDrive && change la lettre du disque dans une adresse de fichier
lparameters ;
	tcFile,;
	tcDrive

local llResult, liResult, lcResult
lcResult = m.tcFile

llResult = .t.;
	and vartype(m.tcFile) == 'C';
	and not empty(m.tcFile);
	and vartype(m.tcDrive) == 'C';
	and not empty(m.tcDrive)
assert m.llResult
if m.llResult

	liResult = evl(at_c(':\', m.tcFile), at_c('\\', m.tcFile))
	llResult = m.liResult > 0
	assert m.llResult
	if m.llResult

		lcResult = stuffc(m.tcFile, 1, m.liResult-1, alltrim(m.tcDrive, ' ', ':', '\'))
	endif
endif

return m.lcResult

* ========================================
function lFileWritable && Wait for a given delay until a file can be accessed
lparameters cFile, nMS && [Between(m.nMS, 50 ms, 5000 ms)]

local success;
, nSeconds;
, handle

if file(m.cFile)
	declare Sleep in win32API integer nMS
	nSeconds = seconds()
	nMS = min(max(evl(m.nMS, 0), 50), 5000)
	do while nMS(m.nSeconds) < m.nMS
		handle = fopen(m.cFile)
		if m.handle > -1
			success = fclose(m.handle)
			exit
		else
			Sleep(m.nMS / 10)
		endif
	enddo
	nMS = nMS(m.nSeconds) && feedback
	return m.success
else
	return .t.
endif
