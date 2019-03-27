* {fr} abFile.prg
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

* ========================================
procedure ReadOnlyClear && {fr} Supprime l'attribut 'lecture seule' des fichiers d'un dossier
lparameters ;
  tcFolder; && {fr} Adresse du dossier
, tcFileSkel; && [*.*] {fr} squelette de fichiers à traiter

local lnResult; && {fr} nombre de fichiers traités
, loFiler as filer.FileUtil;
, loFile;
, lnAttrib;

lnResult = 0

if vartype(m.tcFolder) == 'C' and directory(m.tcFolder)

	loFiler = CreateObject('Filer.FileUtil') && {fr} home(1) + '\tools\filer\Filer.dll'
	loFiler.SearchPath = m.tcFolder
	loFiler.FileExpression = Iif(ga_Type_IsChar(m.tcFileSkel, .T.), m.tcFileSkel, '*.*')

	* {fr} Supprimer les attributs 'read-only' éventuels
	loFiler.find(0) && {fr} Charge la collection de fichiers
	for each loFile in m.loFiler.files
		if mod(m.loFile.attr, 2) > 0 && {fr} uneven = read only
			loFile.attr = m.loFile.attr - 1
			lnResult = m.lnResult + 1
		endif
	endfor
endif

return m.lnResult
endproc

* ========================================
procedure FileReadOnlySet && {fr} Règle l'attribut 'lecture seule' d'un fichier
lparameters ;
  tcFile;
, tlReadOnly; && [.null.] {en} .null.: read, .F.: set read-write, .T.: set read-only

local success as Boolean;
, llGet;
, oFSO  as "Scripting.FileSystemObject";
, oFile as "Scripting.File";

tlReadOnly = Iif(Pcount()> 1, m.tlReadOnly, .null.)
llGet = IsNull(m.tlReadOnly)
success = Iif(m.llGet, .null., .F.)
if File(Evl(m.tcFile, ''))

	oFSO = CreateObject("Scripting.FileSystemObject")
	if Vartype(m.oFSO) == 'O'

		* Define constants for file attributes
		#DEFINE FA_READONLY 	1	&& Read-only file.
	 
		oFile = oFSO.GetFile(FullPath(m.tcFile)) && lcFile is the name of the file

		do case
		case m.llGet
			success = BITAND(m.oFile.Attributes, FA_READONLY) > 0
		case lTrue(m.tlReadOnly)
			oFile.Attributes = BITOR(m.oFile.Attributes, FA_READONLY) && set the read-only flag
			success = .T.
		otherwise
			oFile.Attributes = BITAND(m.oFile.Attributes, BITNOT(FA_READONLY)) && remove the read-only flag
			success = .T.
		endcase
		* oFile.Attributes = BITXOR(oFile.Attributes, FA_READONLY) && Flip read-only flag
	endif
endif

return m.success
endproc

* -----------------------
procedure FileReadOnlySet_Test

local loTest as abUnitTest of abDev.prg
loTest = newobject('abUnitTest', 'abDev.prg')

loTest.Test(.T., Home(1) + 'genMenu.prg', .T.)
loTest.Test(.T., Home(1) + 'genMenu.prg', .F.)

return loTest.result()
endproc


* ========================================
function FileReadOnlyGet && {fr} Lit l'attribut 'lecture seule' d'un fichier
lparameters tcFile
return FileReadOnlySet(m.tcFile, .null.)
endfunc

* -----------------------
procedure FileReadOnlyGet_Test

local loTest as abUnitTest of abDev.prg
loTest = newobject('abUnitTest', 'abDev.prg')

loTest.Test(.F., Home(1) + 'genMenu.prg')

return loTest.result()
endproc

* ========================================
procedure tFileSet && {fr} règle la date et heure d'un fichier
lparameters ;
  result as String; && @ {en} result (cumulative)
, cFile as String; && {en} file full address
, tFile as datetime; && @ [datetime()] {en} date-time to be set
, iType as Integer; && [1] {fr} type de date-heure (additive): 1 dernière modification, 2 dernier accès, 4 création
, lGMT as Boolean; && [.F.] {fr} la date-heure indiquée est GMT

return .t.;
 and (vartype(m.cFile) == 'C' or cResultAdd(@m.result, textmerge([<<cL(m.cFile)>> is expected as a String])));
 and (file(m.cFile) or cResultAdd(@m.result, textmerge([File '<<m.cFile>>' can't be found])));
 and (.F.;
 	or !vartype(m.tFile) $ 'DT' and varSet(@m.tFile, Datetime());
 	or !empty(m.tFile);
 	or cResultAdd(@m.result, textmerge([<<cL(m.tFile)>> is expected as not Empty(date or date-time)]));
 	);
 and tFileSet_(;
 	 @m.result;
 	, m.cFile;
 	, m.tFile;
 	, m.iType;
 	, m.lGMT;
	);
 and .T.

* =============================================================
function tFileSet_ && {fr} change la date-heure d'un fichier
lparameters ;
  result as String; && @ {en} result (cumulative)
, cFile as String; && {fr} fichier
, tFile as DateTime; && [datetime()] {fr} nouvelle date-heure
, iType as Integer; && [1] {fr} type de date-heure (additive): 1 dernière modification, 2 dernier accès, 4 création
, lGMT as Boolean; && [.F.] {fr} la date-heure indiquée est GMT

&& Courtesy Mr Olivier Hamou -- http://www.atoutfox.org/nntp.asp?ID=0000017371

local nResult;
, cResult;
, lcBuff;
, hFile;
, cSysTime;
, cFileTime;

declare Integer OpenFile in kernel32;
  String lpFileName;
, String @lpReOpenBuff;
, Integer wStyle

declare Integer SystemTimeToFileTime IN kernel32;
  String lpSystemTime;
, String @lpFileTime

declare Integer LocalFileTimeToFileTime IN kernel32;
  String lpLocalFileTime;
, String @lpFileTime

declare Integer SetFileTime IN kernel32;
  Integer hFile;
, String lpCreationTime;
, String lpLastAccessTime;
, String lpLastWriteTime

declare Integer CloseHandle IN kernel32;
  Integer hObject

declare Integer GetLastError IN Win32API 

lcBuff = Repli(Chr(0), 250)
cFile = Iif(lFullPath(m.cFile), m.cFile, FullPath(m.cFile))
hFile = OpenFile(;
	  m.cFile;
	, @m.lcBuff; && A pointer to the OFSTRUCT structure (https://msdn.microsoft.com/en-us/library/windows/desktop/aa365282(v=vs.85).aspx) that receives information about a file when it is first opened. The structure can be used in subsequent calls to the OpenFile function to see an open file.
	, 0x00000001; && Opens a file for write access only
	)
IF hFile = -1 && failed to open
  return cResultAdd(@m.result, textmerge([kernel32 OpenFile() ] + ICase(;
		cLangUser() = 'fr',	[n'a pas pu accéder à '<<m.cFile>>' ; code d'erreur :],; && copy-paste this line to add another language support
												[could not access '<<m.cFile>>'; error code:]; && default: English
	  ) + [ <<GetLastError()>>]))
  
ENDIF

tFile = Evl(m.tFile, Datetime())
tFile = m.tFile - Iif(lTrue(m.lGMT), nGMToffsetMin()*60, 0)

cSysTime = '';
+ DwordOfInt(Year(m.tFile)); && modify command abDev
+ DwordOfInt(Month(m.tFile));
+ DwordOfInt(Dow(m.tFile,0));
+ DwordOfInt(Day(m.tFile));
+ DwordOfInt(Hour(m.tFile));
+ DwordOfInt(Minute(m.tFile));
+ DwordOfInt(Sec(m.tFile));
+ Replicate(Chr(0), 4)

cFileTime = Replicate(Chr(0), 8)

* converting SYSTEMTIME data to FILETIME
= SystemTimeToFileTime(m.cSysTime, @m.cFileTime)

* in case your local time is different from UTC
= LocalFileTimeToFileTime(m.cFileTime, @m.cFileTime)

iType = Evl(m.iType, 1)
iType = Iif(ga_Type_IsInteger(m.iType), m.iType, 0)

nResult = SetFileTime(;
	  m.hFile;
	, Iif(Bittest(m.iType, 2), m.cFileTime, 0); && création
	, Iif(Bittest(m.iType, 1), m.cFileTime, 0); && dernier accès
	, Iif(Bittest(m.iType, 0), m.cFileTime, 0); && dernière modification
	)

= CloseHandle(m.hFile) && important

cResult = cWords(', ';
	, Iif(Bittest(m.iType, 2), ICase(;
		cLangUser() = 'fr',	[création],; && copy-paste this line to add another language support
												[creation]; && default: English
	  ), '');
	, Iif(Bittest(m.iType, 1), ICase(;
		cLangUser() = 'fr',	[dernier accès],; && copy-paste this line to add another language support
												[last access]; && default: English
	  ), '');
	, Iif(Bittest(m.iType, 0), ICase(;
		cLangUser() = 'fr',	[dernière modification],; && copy-paste this line to add another language support
												[last modification]; && default: English
	  ), '');
	)

cResult = Stuffc(m.cResult, rAtc(',', m.cResult), 1, ' ' + ICase(;
		cLangUser() = 'fr',	[et],; && copy-paste this line to add another language support
												[and]; && default: English
	  ))

RETURN !Empty(m.nResult) or cResultAdd(@m.result, textmerge([kernel32 SetFileTime() ] + ICase(;
		cLangUser() = 'fr',	[n'a pas pu changer la date-heure de <<m.cResult>> pour '<<m.cFile>>' en <<m.tFile>> ; code d'erreur :],; && copy-paste this line to add another language support
												[could not change <<m.cResult>> date-time of '<<m.cFile>>' to <<m.tFile>>; error code:]; && default: English
	  ) + [ <<GetLastError()>>]))

ENDFUNC

* -------------------------------
procedure tFileSet_Test && {fr} Teste tFileSet()

local loTest as abUnitTest of abDev.prg;
, result as String;
, lcFile as String;
, ltFile as datetime

loTest = newobject('abUnitTest', 'abDev.prg')
lcFile = addbs(sys(2023)) + 'tFileSet_Test.txt'

strtofile('tFileSet_Test', m.lcFile)
ltFile = datetime() - 100

loTest.Test(.T., @m.result, m.lcFile, m.ltFile)
loTest.assert(m.ltFile, Fdate(m.lcFile, 1))

return m.loTest.result()

* ========================================
procedure PathCreate as Boolean && {fr} Crée un chemin de dossiers
lparameters ;
  tcPath; && {fr} Chemin
, result; && @ [''] {fr} Détails de l'erreur éventuelle
, tcMessage && @ [''] {fr} Message d'erreur éventuel

local success as Boolean;
, lcPath;
, liPath;
, loException as exception

tcPath = iif(empty(justext(m.tcPath)), m.tcPath, justpath(m.tcPath)) && {fr} Supprime le nom de fichier éventuel

do case
case lDir(m.tcPath, .T.) && {fr} le dossier existe déjà
	return

case !lFullPath(m.tcPath)
	return cResultAdd(@m.result, textmerge(['<<m.tcPath>>' ] + icase(;
		cLangUser() = 'fr',	[devrait être une adresse complète de fichier ou de dossier],; && copy-paste this line to add another language support
												[should be a complete file or folder address]; && default: English
		)))

otherwise

	try

		* {fr} Pour chaque dossier dans le chemin
		lcPath = upper(getwordnum(m.tcPath, 1, '\')) && {fr} disk letter
		for liPath = 2 to getwordcount(m.tcPath, '\')
			lcPath = m.lcPath + '\' + getwordnum(m.tcPath, m.liPath, '\')

			* {fr} Si le dossier n'existe pas, créer
			if !lDir(m.lcPath, .T.) && {V1.11} Directory(m.lcPath) ne marche pas pour <user>\appdata\
				md (m.lcPath) && case sensitive
			endif
		endfor

		success = .T.

	catch to loException

		success = cResultAdd(@m.result, cException(m.loException))
		tcMessage = m.loException.message
		assert m.success message m.tcMessage

	endtry

	return m.success
endcase
endproc

* ========================================
procedure FilesCopy && {fr} Copie des fichiers d'un dossier [et ses sous-dossiers] dans un autre dossier
lparameters ;
  tcFileSkels; && ['*.*'] {fr} Masques de fichiers à traiter
, tcFolderSrce; && {fr} Adresse du dossier où sont les fichiers
, tcFolderDest; && {fr} Adresse du dossier destination
, tlSubFolders; && [.F.] {fr} Traiter les fichiers dans les sous-dossiers source
, tcSubFoldersExcl; && [''] {fr} Sous-dossiers source à exclure de la recherche (séparés par ',')
, tlKeepExisting; && [.F.] {fr} Ne pas remplacer si existe déjà - .NULL. ou autre, ignorer
, tcResult; && @ [''] {fr} Détail de l'erreur éventuelle
, tnResult; && @ [0] {fr} Nombre de fichiers copiés

local lcResult as String

tcFolderSrce = addbs(cFileCased(m.tcFolderSrce, .t.))
tcFolderDest = addbs(iif(directory(m.tcFolderDest), cFileCased(m.tcFolderDest, .t.), m.tcFolderDest))

tnResult = FilesProc(;
	  m.tcFolderSrce; && {fr} Adresses des dossiers où les fichiers sont à chercher
	, 'FileCopy'; && {fr} Procédure à appliquer à chaque fichier trouvé (son premier paramètre est l'adresse du fichier)
	, m.tcFileSkels; && ['*.*'] {fr} Masques de fichiers à traiter (séparés par ',')
	, m.tlSubFolders; && [.F.] {fr} Traiter les fichiers dans les sous-dossiers
	, m.tcSubFoldersExcl; && [m.tlSubFolders, ''] {fr} Sous-dossiers à exclure (séparés par ',')
	, textmerge([Stuffc(m.tcFileSrce, 1, Lenc(<<cL(m.tcFolderSrce)>>), <<cL(m.tcFolderDest)>>)]); && {fr} Nouvelle adresse (can contain wildcard characters) && @ 2ème paramètre à passer à la procédure (le premier est l'adresse du fichier)
	, @m.lcResult; && @ [''] {fr} Détails de l'erreur éventuelle && @ 3ème paramètre à passer à la procédure
	, ; && @ [''] {fr} Message d'erreur éventuel && @ 4eme paramètre à passer à la procédure
	, lTrue(m.tlKeepExisting); && [.F.] {fr} Ne pas remplacer si existe déjà - .NULL. ou autre, ignorer
	)

return empty(m.lcResult) or cResultAdd(@m.tcResult, m.lcResult)
endproc

* ========================================
procedure FileCopy && {fr} Copie un fichier en créant le(s) dossier(s) si nécessaire
lparameters ;
  tcFileSrce; && {fr} Adresse actuelle (can contain wildcard characters)
, tcFileDest; && {fr} Nouvelle adresse (can contain wildcard characters)
, tcError; && @ [''] {fr} Détails de l'erreur éventuelle
, tcMessage; && @ [''] {fr} Message d'erreur éventuel
, tlKeepExisting; && [.F.] {fr} Ne pas remplacer si existe déjà - .NULL. ou autre, ignorer
, tnAgeMaxSec; && [any] {fr} si m.tlKeepExisting, âge maximum du fichier en secondes

local llResult; && {fr} le fichier a été copié
, lcResult as String;
, lcFileSrce as String;
, lcFileDest as String; && {fr} pour éviter remplacement (FilesProc() passe par référence)
, ltFileDest as datetime;
, loException as exception;

* {fr} Si le fichier existe
lcFileSrce = justfname(m.tcFileSrce)
llResult = '*' $ m.lcFileSrce or '?' $ m.lcFileSrce or lFile(m.tcFileSrce)
if m.llResult

	try

		* {fr} Si le chemin destination existe ou peut être créé
		lcFileDest = iif(lFullPath(m.tcFileDest,, .t.);
			, m.tcFileDest;
			, evaluate(m.tcFileDest); && {fr} support des expressions pour FilesCopy()
			)
		llResult = PathCreate(m.lcFileDest, @m.lcResult, @m.tcMessage)
		if m.llResult

			lcFileDest = Iif(lDir(m.lcFileDest, .T.);
				, forcepath(m.tcFileSrce, m.lcFileDest);
				, m.lcFileDest;
				)
			llResult = not lower(m.tcFileSrce) == lower(m.lcFileDest)
			if m.llResult

				llResult = lTrue(m.tlKeepExisting);
				 and lFile(m.lcFileDest);
				 and varSet(@m.tnAgeMaxSec, Iif(Vartype(m.tnAgeMaxSec) == 'N', m.tnAgeMaxSec, .null.));
				 and varSet(@m.ltFileDest, tFile(m.lcFileDest));
				 and (IsNull(m.tnAgeMaxSec) or (Datetime() - m.ltFileDest <= abs(m.tnAgeMaxSec)))
				if m.llResult

					store textmerge(icase(;
						cLangUser() = 'fr', 	[Le fichier destination '<<m.lcFileDest>>' existait en date du <<m.ltFileDest>>, il n'a pas été remplacé],; && copy-paste this line to add another language support
																	[Destination file '<<m.lcFileDest>>' existed as of <<m.ltFileDest>>, it was not remplaced]; && default: English
						)) to tcMessage

				else

					copy file (m.tcFileSrce) to (m.lcFileDest) && {en} changes name to lower case
					llResult = .t.

*!*							llResult = Empty(CopyFile(m.tcFileSrce, m.tcFileDest, 0)) && {en} preserves case but ... does not work!
				endif

			else

				lcResult = icase(;
					cLangUser() = 'fr', 	[Les fichier source et destination sont identiques],; && copy-paste this line to add another language support
																[Source and destination files are the same]; && default: English
					)
			endif
		else
&& {fr} PathCreate() returns errors
		endif
	catch to loException
		llResult = .f.
		lcResult = cException(m.loException)
		tcMessage = Textmerge([copy file ('<<m.tcFileSrce>>') to ('<<m.lcFileDest>>'): <<m.loException.message>>])
	endtry
else
	lcResult = textmerge(icase(;
		cLangUser() = 'fr', 	[Le fichier source '<<m.tcFileSrce>>' est introuvable],; && copy-paste this line to add another language support
													[Source file '<<m.tcFileSrce>>' can't be found]; && default: English
		))
endif
assert m.llResult message cAssertMsg(textmerge(icase(; && {fr} DisplayPath() does not work with wildcards
		cLangUser() = 'fr',	[Erreur en copiant '<<m.tcFileSrce>>' dans '<<Evl(m.lcFileDest, m.tcFileDest)>>' :],; && copy-paste this line to add another language support
												[Error while copying '<<m.tcFileSrce>>' into '<<Evl(m.lcFileDest, m.tcFileDest)>>':]; && default: English
		)) + [ ] + m.lcResult)
llResult = m.llResult or cResultAdd(@m.tcError, m.lcResult)

return m.llResult
endproc

* ========================================
function CopyFile(tcFileName, tcCopyFileName, tnFailIfExists) && {en} Win32 API copy file, preserves case
&& http://www.berezniker.com/content/pages/visual-foxpro/copy-move-rename-file-preserving-destination-name-case
declare long CopyFile in WIN32API String SourceFileName, String DestFileName, long bFailIfExists
return CopyFile(m.tcFileName, m.tcCopyFileName, m.tnFailIfExists)
endfunc

* ========================================
function MoveFile(tcFileName, tcNewFileName) && {en} Win32 API move file, preserves case
&& http://www.berezniker.com/content/pages/visual-foxpro/copy-move-rename-file-preserving-destination-name-case
declare long MoveFile IN WIN32API String SourceFileName, String DestFileName
return MoveFile(tcFileName, tcNewFileName)
endfunc

* ========================================
procedure FileMove && {fr} Déplace un ou plusieurs fichier(s) en créant le(s) dossier(s) si nécessaire
lparameters ;
  tcFileSrce ; && {fr} Adresse actuelle (can contain wildcard characters)
, tcFileDest; && {fr} Nouvelle adresse (can contain wildcard characters)
, tlCopyForce; && [.F.] {fr} Toujours copier (pas de RENAME, donc potentiellement plus lent)
, tcResult; && @ {fr} Résultat

tcResult = ''

local llResult as Boolean;
, loException as exception;
, lcExt as String;
, llWild as Boolean;

llResult = lFiles(m.tcFileSrce)
assert m.llResult message cAssertMsg(textmerge([Le fichier '<<m.tcFileSrce>>' n'existe pas]))
if m.llResult

	llResult = PathCreate(m.tcFileDest, @m.tcResult)
	if m.llResult

		lcExt = JustExt(m.tcFileSrce)
		llWild = '?' $ m.lcExt or '*' $ m.lcExt

		try
			if lFiles(m.tcFileDest) or lTrue(m.tlCopyForce)

			 	delete file (m.tcFileDest) && {fr} évite que le fichier copié hérite
			 	if m.llWild
				 	copy file (m.tcFileSrce) to (m.tcFileDest)
			 	else
				 	llResult = !Empty(CopyFile(cFileCased(m.tcFileSrce), m.tcFileDest, 0))
			 	endif
				if lFiles(m.tcFileDest) && {fr} assure que le fichier a été copié avant de supprimer la source
					delete file (m.tcFileSrce)
				endif

			else

				&& {en} When you issue RENAME, FileName2 cannot already exist and FileName1 must exist and cannot be open.
				&& {en} RENAME moves the file and keeps its security profile
				&& {en} If the file extensions are not included, the default extension .dbf is assumed
				* 
			 	if m.llWild
				 	rename (m.tcFileSrce) to (m.tcFileDest) && {fr} déplace le(s) fichier(s)
			 	else
				 	llResult = !Empty(MoveFile(cFileCased(m.tcFileSrce), m.tcFileDest))
			 	endif
			endif

		catch to loException
			llResult = .f.
			tcResult = cException(m.loException)
		endtry
	endif

	assert m.llResult message cAssertMsg(textmerge([Erreur en déplaçant '<<m.tcFileSrce>>' dans '<<m.tcFileDest>>' : <<m.tcResult>>]))
endif

return m.llResult
endproc

* ========================================
procedure FileStrTran && {fr} Remplace une chaîne dans un fichier selon StrTran()
lparameters ;
  tcFile; && {fr} fichier où chercher
, cExpressionSought; && {fr} chaîne à remplacer
, cReplacement; && [''] {fr} chaîne remplaçante
, nStartOccurrence; && [1] {fr} première occurrence à traiter
, nNumberOfOccurrences; && [-1, all] && {fr} nombre d'occurrences à traiter
, nFlags && [0] {fr} réglages selon StrTran()

if file(m.tcFile) and vartype(m.cExpressionSought) == 'C'

	local lcFile
	lcFile = filetostr(m.tcFile)

	return .f.;
		 or empty(m.lcFile);
		 or strtofile(;
					strtran(;
						m.lcFile;
					, m.cExpressionSought;
					, evl(m.cReplacement, '');
					, evl(m.nStartOccurrence, 1);
					, evl(m.nNumberOfOccurrences, -1);
					, evl(m.nFlags, 0);
					);
				, m.tcFile;
				) > 0

else
	return .null.
endif

* ========================================
function lDir && {fr} Un dossier existe
lparameters tcDir, tlStrict && {fr} Adresse du dossier ; supporte wildcard
local array laTemp[1]
return .T.;
 and vartype(m.tcDir) == 'C';
 and not empty(m.tcDir);
 and Iif(lTrue(m.tlStrict);
	 , adir(laTemp, addbs(m.tcDir), 'DHS') >= 1; && {fr} Directory, Hidden, System
	 , directory(m.tcDir);
	 )

* ========================================
function lDirEmpty && {fr} Un dossier existe et est vide
lparameters tcDir && {fr} Adresse du dossier ; supporte wildcard
local laTemp[1]

return lDir(m.tcDir, .T.);
 and adir(laTemp, forcepath('*.*', m.tcDir), [DHS]) = 2;
 and laTemp[1,1] == '.';
 and laTemp[2,1] == '..'

* ========================================
function lFile && {fr} Un fichier existe (plus rapide et précis que File() car ne cherche pas dans le PATH)
lparameters ;
  tcFileAddr; && {fr} Adresse du fichier dont il faut vérifier l'existence, complète ou dans Curdir()
, tnSize; && @ [0] {fr} Taille en octets - .T.: identifier fichiers multiples
, ttModified; && @ [Datetime(1900,1,1,0,0,0)] {fr} Date et Heure de Dernière modification
, tcAttribs; && @ [''] {fr} Attributs
, tcFound; && @ [''] {fr} Fichier trouvé (tcFileAddr est un squelette de fichier)

local llResult;
, laFile[1];
, lnFile;
, llFiles;

if ga_Type_IsChar(m.tcFileAddr, .t.)

	lnFile = adir(laFile, m.tcFileAddr, 'HS') && , 1 inutile && ? ADir(aa, '..\*.prg') fonctionne

	llFiles = lTrue(m.tnSize)
	llResult = iif(m.llFiles;
		, m.lnFile > 0;
		, m.lnFile = 1;
		)
	if m.llResult and not m.llFiles and Pcount() > 1

		tcFound = m.laFile[1, 1]
		tnSize = m.laFile[1, 2]
		ttModified = tDateCTime(m.laFile[1, 3], m.laFile[1, 4])
		tcAttribs = m.laFile[1, 5]
	endif
endif

if not (m.llResult or m.llFiles)
	tcFound = .null.
	tnSize = 0
	ttModified = datetime(1900,1,1,0,0,0)
	tcAttribs = ''
endif

return m.llResult

* -------------------------------
procedure lFile_Test && {fr} Teste lFile

local loTest as abUnitTest
loTest = newobject('abUnitTest', 'abDev.prg')

local lcFileAddr, lnSize, ltModified, lcAttribs
lcFileAddr = getfile()
loTest.Test(.t., m.lcFileAddr, @lnSize, @ltModified, @lcAttribs)
? "Taille, date et attributs du fichier", m.lcFileAddr, CRLF, m.lnSize, m.ltModified, m.lcAttribs


* ========================================
function lFiles && {fr} Un ou plusieurs fichiers existent selon un squelette
lparameters tcFileAddrSkeleton && {fr} squelette de l'adresse des fichiers dont il faut vérifier l'existence
local laFiles[1]

return aFiles(@m.laFiles, m.tcFileAddrSkeleton) > 0
endfunc

* ========================================
function aFiles && {fr} Fichiers selon un squelette d'adresse
lparameters ;
  taFiles; && @ {fr} Noms des Fichiers
, tcFileAddrSkeleton; && {fr} squelette de l'adresse des fichiers

local llResult, lnResult && {fr} Nombre de fichiers trouvés

lnResult = 0

llResult = lFileAddrSkeleton(m.tcFileAddrSkeleton) and aClear(@m.taFiles)
assert m.llResult message cAssertMsg(textmerge([Invalid File skeleton specification : <<cLitteral(m.tcFileAddrSkeleton)>>]))
if m.llResult

	lnResult = adir(m.taFiles, m.tcFileAddrSkeleton, '', 1)
	if m.lnResult > 0

		aColsDel(@taFiles, 2) && {fr} retourne les seuls noms des fichiers
	endif
endif

return m.lnResult

external array taFiles
endfunc

* ========================================
function aFiles_ && {fr} Fichiers selon un ou plusieurs squelette dans un dossier [et ses sous-dossiers]
lparameters ;
  taFiles; && @ {fr} Adresses des Fichiers
, tcFileSkels; && {fr} Masques de fichiers à traiter
, tcFolder; && {fr} Adresse du dossier où les fichiers sont à chercher
, tlSubFolders; && [.F.] {fr} Traiter les fichiers dans les sous-dossiers
, tcSubFoldersExcl && [m.tlSubFolders, ''] {fr} Sous-dossiers à exclure (séparés par ',')

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

if aClear(@m.taFiles) and alines(m.laFileSkel, m.tcFileSkels, 5, ',', ';') > 0

	if m.tlSubFolders and 0 < aSubFolders(; && {fr} Sous-dossiers d'un dossier /!\ Récursive
			  @m.laFolder; && @ {fr} taSubFolders Sous-dossiers selon aDir()
			, m.tcFolder; && {fr} tcFolder [dossier courant] Adresse du dossier où rechercher les sous-dossiers
			, m.tcSubFoldersExcl; && {fr} tcFoldersExcl [''] sous-dossiers à exclure et/ou squelette des fichiers attendus dans les dossiers à inclure
			, .t.; && {fr} tvRecurse [.F.] Récurser dans les sous-sous-dossiers etc., si N, nombre de niveaux de récursion
			, .t.; && {fr} tlAddrOnly [.F.] Ne garder que les adresses des dossiers (supprimer date, taille, etc.)
			)
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
endfunc

* ----------------------------------------------
procedure aFiles__Test && {fr} Teste aFiles_()

local loTest as abUnitTest of abDev.prg, aa[1]
loTest = newobject('abUnitTest', 'abDev.prg')

loTest.Test(7, @m.aa, '*.pjx', DOS_AWSAMPLES, .T.)
&& 1- FIC\FicDemo\ficdemo.pjx
&& 2- FIC\FicTuto\fictuto.pjx
&& 3- Tastrade\Adapted\fttprod.pjx
&& 4- Tastrade\Adapted\ftttest.pjx
&& 5- Tastrade\Adapted\tastradeFIC.pjx
&& 6- Tastrade\Sandbox\tastradefic.pjx
&& 7- Tastrade\_Original\tastradeFIC.pjx

_cliptext = '&' + '& ' + Strtran(cListOfArray(@m.aa, CRLF + '&' + '& '), DOS_AWSAMPLES,'',1,-1,1)

return loTest.result()
endproc

* ========================================
function cSubFolderFileSkelsMax && {fr} sous-dossier qui contient le plus de fichiers répondant à un ou plusieurs masque(s)
lparameters ;
  tcFileSkels; && {fr} masque(s) de fichiers à chercher
, tcFolder; && [dossier courant] {fr} Adresse du dossier où rechercher les fichiers
, tcFoldersExcl; && [''] {fr} sous-dossiers à exclure

tcFolder = cFileCased(Evl(m.tcFolder, Sys(5) + Curdir()))

local lcResult;
, lnFolder, lnFolder_;
, laFolder[1], liFolder, lcFolder;
, laFile[1];

lcResult = ''
lnFolder_ = 0
for liFolder = 1 to aSubFolders(@m.laFolder, m.tcFolder,,, .T.)
	lcFolder = m.laFolder[m.liFolder]
	lnFolder = aFiles_(@m.laFile, m.tcFileSkels, m.lcFolder, .T., m.tcFoldersExcl)
	lcResult = Iif(m.lnFolder > m.lnFolder_, m.lcFolder, m.lcResult)
	lnFolder_ = Max(m.lnFolder, m.lnFolder_)
endfor

return m.lcResult
endfunc

* ----------------------------------------------
procedure cSubFolderFileSkelsMax_Test && {fr} Teste cSubFolderFileSkelsMax()

local loTest as abUnitTest of abDev.prg, lcFolder
loTest = newobject('abUnitTest', 'abDev.prg')

lcFolder = DOS_AWSAMPLES + 'Tastrade\_Original\'

loTest.Test(m.lcFolder + 'Class\', '*.vcx', m.lcFolder)
loTest.Test(m.lcFolder + 'Form\', '*.scx', m.lcFolder)

return loTest.result()
endproc

* ========================================
function lFileAddrSkeleton && {fr} Squelette d'adresse de fichier valide
lparameters tcFileAddrSkeleton && {fr} squelette de l'adresse des fichiers à vérifier

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
function lFileExclusive && {fr} Un fichier peut être ouvert en exclusif
lparameters tcFileAddr && {fr} Adresse du fichier dont il faut vérifier l'accès exclusif

local lnHandle, llResult

if vartype(m.tcFileAddr) == 'C' and not empty(m.tcFileAddr)

	llResult = lFileAddress(m.tcFileAddr)
	assert m.llResult message cAssertMsg(textmerge([Invalid file specification: <<cLitteral(m.tcFileAddr)>>]))
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
function lFileFresher && {fr} Un fichier est plus récent qu'un autre
lparameters ;
  tcFile1Addr; && {fr} Adresse du fichier de base
, tcFile2Addr && {fr} Adresse du fichier à comparer

* {fr} Si les deux fichiers existent
return iif(vartype(m.tcFile1Addr)=='C';
	 and lFile(fullpath(m.tcFile1Addr));
	 and vartype(m.tcFile2Addr)=='C';
	 and lFile(fullpath(m.tcFile2Addr));
 , fdate(m.tcFile2Addr, 1) > fdate(m.tcFile1Addr, 1);
 , .null.;
 )

* ========================================
procedure FilesDir && {en} Stores files found in a folder [and sub-folders optionally] into a table {fr} Répertorie des fichiers dans un dossier [et ses sous-dossiers]
lparameters ;
  tcFileSkels; && ['*.*'] {en} Files skeletons to find {fr} Masques de fichiers à traiter
, tcFolders; && {en} Folder where to find {fr} Adresse du dossier où les fichiers sont à chercher
, tlSubFolders; && [.F.] {en} search in sub-folders {fr} Traiter les fichiers dans les sous-dossiers
, tcSubFoldersExcl; && [m.tlSubFolders, ''] {en} sub-folders to exclude from the search {fr} Sous-dossiers à exclure (séparés par ',')
, tcTable; && @ {en} Result table name where files found are registered {fr} Table répertoire de fichiers : table ou curseur ; si vide, nouveau curseur ; Alias en retour
, tcFieldsExtra; && [aucun] {en} Additional fields to the table {fr} spécifications de champs à ajouter à la table
, tcTagsExtra; && [aucun] {en} Additional indexes to the table {fr} spécifications d'index à ajouter à la table (cf. aTagInfo_())
, tlChecksumSizeNo; && [.F.] {en} do not compute file's checksum and size {fr} ne pas calculer le checksum et la taille des fichiers
, tlWaitWindow; && [.F.] {en} display a wait window {fr} afficher une fenêtre d'avancement
, tcProc; && [FileDir] {en} procedure processing file -- make sure to call FileDir() {fr} procédure traitant le fichier qui doit appeler FileDir()

local lnResult as Integer; && {en} number of files found, -1 if error {fr} Nombre de fichers répertoriés, -1 si erreur
, loDeleted as abSet of abDev.prg;
, aFolder[1], nFolder, cFolder;

lnResult = -1

private plWaitWindow
plWaitWindow = lTrue(m.tlWaitWindow)

tcTable = FilesDirCursor(m.tcTable, m.tcFieldsExtra, m.tcTagsExtra)
if used(m.tcTable)

	loDeleted = abSet('DELETED', 'OFF')

	if ALines(aFolder, Upper(m.tcFolders), 5, ',', ';') > 0
		for each cFolder in m.aFolder
			nFolder = Lenc(m.cFolder)
			delete in (m.tcTable) for Upper(Leftc(mAddr, m.nFolder)) == m.cFolder && {fr} cf. FileDir()
		endfor
	endif

	lnResult = FilesProc(;
		  m.tcFolders;
		, Iif(ga_Type_IsChar(m.tcProc, .T.), m.tcProc, 'FileDir');
		, m.tcFileSkels;
		, m.tlSubFolders;
		, m.tcSubFoldersExcl;
		, m.tcTable;
		, m.tlChecksumSizeNo; && [.F.] {en} do not compute file's checksum and size {fr} ne pas calculer le checksum et la taille des fichiers
		)
endif

return m.lnResult
endproc

* ========================================
procedure FilesDirCursor && {fr} Ouvre ou crée une table ou un curseur d'inventaire de fichiers
lparameters ;
  tcTable; && @ {fr} Table ou curseur pour répertoire de fichiers ; si vide, nouveau curseur
, tcFieldsExtra; && [aucun] {fr} spécifications de champs à ajouter à la table
, tcTagsExtra; && [aucun] {fr} spécifications d'index à ajouter à la table (cf. aTagInfo_())
, tcAlias; && @ [JustStem(m.tcTable)] {fr} Alias d'ouverture
, tlCreated; && @ [idem] {fr} La table a été créée
, tlAdjusted; && @ [idem] {fr} La structure de la table et/ou ses indexes ont été ajustés
, tcResult; && @ {fr} Résultat

local llResult as Boolean

llResult = TableFreeCreateOrAdjust(; && modify command abData
			evl(m.tcTable, sys(2015));
		,@m.tcAlias;
		, FilesDirCursor_cFields(m.tcFieldsExtra);
		, FilesDirCursor_cTags(m.tcTagsExtra);
		,@m.tlCreated; && @ [idem] {fr} La table a été créée
		,@m.tlAdjusted; && @ [idem] {fr} La structure de la table et/ou ses indexes ont été ajustés
		,@m.tcResult; && @ [''] {fr} Résultat
		)

assert m.llResult message cAssertMsg(textmerge([le curseur ou la table '<<m.tcTable>>' ne peut être ouvert ou créé]))

return iif(m.llResult, m.tcAlias, '')
endproc

* ========================================
function FilesDirCursor_cFields && {fr} Champs de la table ou curseur d'inventaire de fichiers
lparameters tcFieldsExtra && [aucun] {fr} spécifications de champs à ajouter à la table

return c2Words(;
					  [FILEDIR I];
				+ [, cNAME V(200)];
				+ [, cSTEM V(200)];
				+ [, cEXT V(10)]; && 'sqlite'
				+ [, mADDR M]; && max Windows file name length: 260 && https://msdn.microsoft.com/en-us/library/windows/desktop/aa365247(v=vs.85).aspx
				+ [, nBYTES B(0) NULL];
				+ [, CHECKSUM C(12) NULL];
				+ [, lMOD L];
				+ [, tMOD T NULL];
				+ [, tDIR T];
				, ',';
				, evl(m.tcFieldsExtra, '');
				)
endfunc

* ========================================
function FilesDirCursor_cTags && {fr} Indexes de la table ou curseur d'inventaire de fichiers
lparameters tcTagsExtra && [aucun] {fr} spécifications d'index à ajouter à la table (cf. aTagInfo_())

local lcResult
text TO lcResult TEXTMERGE NOSHOW FLAGS 1 PRETEXT 3 && {fr} selon aTagInfo() && && {fr} Tag; Type; Key; Filter; Order; Collation
	FILEDIR;CANDIDATE;;;;MACHINE
	FILECK;CANDIDATE;<<cFilesDirCursorCKexpr('mADDR')>>;;;MACHINE
	cNAME;;;;;MACHINE
	cSTEM;;;;;MACHINE
	cEXT;;;;;MACHINE
	nBYTES;;;;;MACHINE
	tMOD;;;;;MACHINE
	tDIR;;;;;MACHINE
	DELETD;BINARY;Deleted()
	<<Evl(m.tcTagsExtra, '')>>
ENDTEXT

return m.lcResult

* ========================================
function cFilesDirCursorCKexpr && {fr} Expression de clé candidate sur une table d'inventaire de fichiers
lparameters tcAddr
return textmerge([Padr(Upper(Rightc(Rtrim(<<m.tcAddr>>), 200)), 200)])
endfunc

* ========================================
procedure FileDir && {fr} Répertorie un fichier
lparameters ;
  tcFile as String; && {fr} Adresse du fichier
, tcAlias as String; && {fr} Répertoire de fichiers
, tlChecksumSizeNo; && [.F.] {en} do not compute file's checksum and size {fr} ne pas calculer le checksum et la taille des fichiers
, tcError as String; && @ {fr} Erreur en retour (cumulative)

tcFile = alltrim(m.tcFile)

local llResult as Boolean;
, llDeleted as Boolean;
, loException as exception;
, lnBytes;
, ltFile;
, lcCheckSum;

llResult = file(m.tcFile, 1) && 1 allows you to check for hidden or system files
if m.llResult or cResultAdd(@m.tcError, Textmerge(Iif(Lenc(m.tcFile) >= 260; && https://msdn.microsoft.com/en-us/library/windows/desktop/aa365247(v=vs.85).aspx
	, [File '<<m.tcFile>>' can't be processed as its path length (<<Lenc(m.tcFile)>>) reaches or exceeds the limit of 260 characters];
	, [File '<<m.tcFile>>' can't be found on disk];
	)))

	llDeleted = Set('DELETED') == 'ON'
	if m.llDeleted
		set deleted off
	endif

	tlChecksumSizeNo = lTrue(m.tlChecksumSizeNo)
	ltFile = tFile(m.tcFile, .T.)
	lnBytes = Iif(m.tlChecksumSizeNo;
		, -1;
		, nFileSize(m.tcFile); && nFileSize(m.tcFile, .t.) && < 1 ms
		)
	lcCheckSum = Iif(!m.tlChecksumSizeNo and m.lnBytes < VFP_VAR_SIZE_MAX;
		, cFileCheckSum(m.tcFile, .T.);
		, .null.;
		)

	try

		if seek(evaluate(cFilesDirCursorCKexpr('m.tcFile')), m.tcAlias, 'FILECK')

			recall in (m.tcAlias)
			replace in (m.tcAlias);
				lMOD with .F.

			if not evaluate(m.tcAlias + '.mAddr') == m.tcFile && {fr} évite le MEMO bloat
				replace in (m.tcAlias);
					mAddr with m.tcFile;
					lMOD with .T.;

			endif

			if evaluate(m.tcAlias + '.nBYTES') # m.lnBytes;
			 or evaluate(m.tcAlias + '.tMOD') # m.ltFile;
			 or not luEqual(evaluate(m.tcAlias + '.CHECKSUM'), m.lcCheckSum)

				replace in (m.tcAlias);
					nBYTES with m.lnBytes;
					tMOD with m.ltFile;
					CHECKSUM with m.lcCheckSum;
					tDIR with datetime();
					lMOD with .T.;

			endif

		else

			insert into (m.tcAlias) (; && {fr} After executing the INSERT command, Visual FoxPro sets the record pointer on the new record
					  FileDir;
					, cNAME;
					, cSTEM;
					, cEXT;
					, mAddr;
					, nBYTES;
					, tMOD;
					, tDIR;
					, CHECKSUM;
					, lMOD;
					);
			 values (;
			 			iAutoInc(m.tcAlias, 'FILEDIR');
					, upper(justfname(m.tcFile));
					, upper(juststem(m.tcFile));
					, upper(justext(m.tcFile));
					, m.tcFile;
					, m.lnBytes;
					, m.ltFile;
					, datetime();
					, m.lcCheckSum;
					, .T.;
					)
		endif

	catch to loException
		llResult = cResultAdd(@m.tcError, cException(m.loException))
	endtry
	if m.llDeleted
		set deleted on
	endif
endif

return m.llResult
endproc

* ==============================================
function FileMemo(tcFile) && {fr} Fichier mémo associé à un fichier-table VFP

local lcExt

lcExt = Lower(JustExt(m.tcFile))

return ICase(;
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
	.t.;
	 and InList(m.lcExt, 'dbf', 'vmx'); && 'vmx' pour Visual Fox Extend
	 and lFPT(m.tcFile),; && modify command abData
		ForceExt(m.tcFile, 'fpt'),;
		'';
	)

* ==============================================
function FileIndex(tcFile) && {fr} Fichier index associé à un fichier-table VFP

local lcExt

lcExt = lower(justext(m.tcFile))
return icase(;
	m.lcExt == 'dbc', forceext(m.tcFile, 'dcx'),;
	m.lcExt == 'dbf', icase(;
		lFile(forceext(m.tcFile, 'cdx')), forceext(m.tcFile, 'cdx'),;
		lFile(forceext(m.tcFile, 'idx')), forceext(m.tcFile, 'idx'),;
		''),;
	m.lcExt == 'mnx', forceext(m.tcFile, 'mpr'),; && {fr} just a workaround
	'';
)
endfunc

* ==============================================
function tFile && {fr} Date et heure de dernière modification d'un fichier et/ou de ses fichiers liés
lparameters ;
  tcFile; && {fr} Fichier
, tlMemo; && [.F.] {fr} Prendre en compte le fichier memo associé éventuel

local tFile as Datetime

*!*	local sys2450 as Integer
*!*	sys2450 = Cast(Sys(2450) as I)
*!*	Sys(2450, 0)

* {fr} tcFile = fullpath(m.tcFile) && {fr} lFile() supporte les chemins relatifs
tlMemo = iif(lTrue(m.tlMemo), FileMemo(m.tcFile), '')

return Iif(File(m.tlMemo);
	, max(tFile_(m.tcFile), tFile_(m.tlMemo));
	, tFile_(m.tcFile);
	)

*!*	Aussi incroyable que ça puisse paraître, fdate() appelé depuis une fonction cherche dans set('path') au lieu d'aller à l'adresse indiquée
*!*	try
*!*		tFile = ICase(;
*!*			!lFile(m.tcFile),; && {fr} File() peut répondre .T. et Fdate() ne trouve pas le fichier
*!*				{/:},;
*!*			lFile(m.tlMemo),;
*!*				max(fdate(m.tcFile, 1), fdate(m.tlMemo, 1)),;
*!*				fdate(m.tcFile, 1); && 1: last modification DateTime
*!*				)
*!*	catch && {fr} erreur 'file not found' si le fichier est inclus dans l'exe
*!*		tFile = tFile_(m.tcFile, m.tlMemo) && {fr} alternative
*!*	endtry
*!*	Sys(2450, m.sys2450)
*!*	return m.tFile

endfunc

* ==============================================
function tFile_ && {fr} Date et heure de dernière modification d'un fichier et/ou de ses fichiers liés /!\ privée de tFile()
lparameters tcFile && {fr} Fichier

LOCAL laFile[1], ldDate

IF ADir(laFile, FullPath(m.tcFile)) # 1
	RETURN {/:}
ELSE
	ldDate = m.laFile[3]
	RETURN EVALUATE('';
		+ "{^";
		+ Cast(YEAR(m.ldDate) as M);
		+ "-";
		+ Cast(MONTH(m.ldDate) as M);
		+ "-";
		+ Cast(DAY(m.ldDate) as M);
		+ " " ;
		+ m.laFile[4]; && time
		+ "}";
		)
ENDIF   
endfunc

* ==============================================
function cFileSizeTotal && {fr} Taille d'un fichier et de ses fichiers associés, formatté avec unité
lparameters tcFile && {fr} Fichier

return cFileSize(;
	  @m.tcFile;
	, .t.; && {fr} tlMemo Tenir compte du fichier memo associé éventuel
	, .t.; && {fr} tlCDX Tenir compte du fichier CDX associé éventuel
	)

* ==============================================
function cFileSize && {fr} Taille d'un fichier formattée avec unité
lparameters ;
  tcFile; && {fr} Fichier
, tlMemo; && [.F.] {fr} Tenir compte du fichier memo associé éventuel @ le fichier memo existe
, tlCDX && [.F.] {fr} Tenir compte du fichier CDX associé éventuel @ le fichier CDX existe

local result

result = nFileSize(@m.tcFile, @m.tlMemo, @m.tlCDX)

return icase(;
	not vartype(m.result) == 'N',;
		'N/A',;
	m.result >= 1024^3,;
		ltrim(transform(m.result/1024^3, '9,999.9' + Chr(160) + 'GB')),;
	m.result >= 1024^2,;
		ltrim(transform(m.result/1024^2, '9,999.9' + Chr(160) + 'MB')),;
	m.result > 1024,;
		ltrim(transform(m.result/1024, '9,999.9' + Chr(160) + 'kB')),;
		ltrim(transform(m.result, '9,999' + Chr(160) + 'B'));
	)

* ==============================================
function cMB && {fr} Valeur en Méga Octets
lparameters ;
  tnSize;
, tcLangUser; && [cLangUser()] {fr} Langue de l'utilisateur
, tlHTML; && [.F.] {en} to be included in HTML

tcLangUser = cLangUser(m.tcLangUser)

return '';
	+ ltrim(transform(m.tnSize/2^20, '999.99'));
	+ Chr(160); && Iif(lTrue(m.tlHTML), '&nbsp;', ' ')
	+ icase(;
		m.tcLangUser = 'fr', 	'MO',; && copy-paste this line to add another language support
													'MB'; && default: English
		)

* ==============================================
function cGB && {fr} Valeur en Giga Octets
lparameters ;
  tnSize;
, tcLangUser; && [cLangUser()] {fr} Langue de l'utilisateur
, tlHTML; && [.F.] {en} to be included in HTML

tcLangUser = cLangUser(m.tcLangUser)

return '';
	+ ltrim(transform(m.tnSize/2^30, '999.99'));
	+ Chr(160); && Iif(lTrue(m.tlHTML), '&nbsp;', ' ')
	+ icase(;
		m.tcLangUser = 'fr', 	'GO',; && copy-paste this line to add another language support
													'GB'; && default: English
		)
endfunc

* ==============================================
function cFileSizeMB && {fr} Taille d'un fichier en Méga Octets
lparameters ;
  tcFile; && {fr} Fichier
, tlMemo; && [.F.] {fr} Tenir compte du fichier memo associé éventuel
, tcLangUser && [cLangUser()] {fr} Langue de l'utilisateur

return cMB(nFileSize(m.tcFile, m.tlMemo))
endfunc

* ==============================================
function nFileSizeTotal && {fr} Taille d'un fichier et de ses fichiers associés
lparameters tcFile && {fr} Fichier

return nFileSize(;
	  @m.tcFile;
	, .t.; && {fr} tlMemo Tenir compte du fichier memo associé éventuel
	, .t.; && {fr} tlCDX Tenir compte du fichier CDX associé éventuel
	)
endfunc

* ==============================================
function nFileSize && {fr} Taille d'un fichier en octets
lparameters ;
  tcFile; && {fr} Fichier
, tlMemo; && @ [.F.] {fr} Ajouter la taille du fichier memo associé éventuel @ le fichier memo existe
, tlCDX;  && @ [.F.] {fr} Ajouter la taille du fichier CDX associé éventuel @ le fichier CDX existe
, result;  && @ [''] {fr} erreur éventuelle

local lnResult; &&  && {fr} Taille du fichier en octets
, llResult;
, lcMemo;
, lcCDX;
, llCompatible;
, lnMemoWidth;
, lHandle;

* {en} If file can be found
llResult = vartype(m.tcFile) == 'C' and file(m.tcFile)
assert m.llResult message cAssertMsg(textmerge([Invalid File Address Specification: <<m.tcFile>>]))
if m.llResult

	if lTrue(m.tlMemo)
		lcMemo = FileMemo(m.tcFile)
		tlMemo = !empty(m.lcMemo) && @ feedback
	endif

	if lTrue(m.tlCDX)
		lcCDX = forceext(m.tcFile, 'cdx')
		tlCDX = file(m.lcCDX) && @ feedback
	endif

	try
		llCompatible = set("Compatible") == 'OFF'
		if m.llCompatible
			lnMemoWidth = set("Memowidth")
			set compatible db4 && on && 2017-11-16 thn -- {FiC V 2.26.0-beta.3} {en} workaround error "too many parameters"
		endif

#if .F. && for files larger than 2 GB
o = CreateObject('scripting.filesystemobject')
ofile = o.GetFile(m.tcFile)
ofile.Size
#endif
		
		* ======================================
		lnResult = 0;
			+ fsize(m.tcFile);
			+ iif(m.tlMemo, fsize(m.lcMemo), 0);
			+ iif(m.tlCDX, fsize(m.lcCDX), 0)
		* ======================================

	catch to result
		result = cException(m.result)
		llResult = .f.
	finally
		if m.llCompatible and set("Compatible") == 'ON'
			set memowidth to m.lnMemoWidth
			set compatible off
		endif
	endtry

	if !m.llResult

		lHandle = fopen(justfname(m.tcFile), 10)
		llResult = m.lHandle # -1
		if m.llResult

			lnResult = fseek(m.lHandle, 0, 2)
			fclose(m.lHandle)
			lnResult = m.lnResult;
				+ iif(m.tlMemo, nFileSize(m.lcMemo), 0);
				+ iif(m.tlCDX, nFileSize(m.lcCDX), 0)

		else

&& {fr} probably an included file
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

result = Iif(m.llResult, '', m.result)
return iif(m.llResult, m.lnResult, .null.)
endfunc

*----------------------------------------
procedure nFileSize_Test && {fr} teste nFileSize()

local loTest as abUnitTest of abDev.prg;
, lcFile;
, lnFile

loTest = newobject('abUnitTest', 'abDev.prg')

lcFile = sys(2023) + 'nFileSize_Test.txt'
lnFile = 10000
strtofile(replicate('a', m.lnFile), m.lcFile)
loTest.Test(m.lnFile, m.lcFile)
erase (m.lcFile)

loTest.Test(.null., cModuleInfo(sys(16), 'Address')) && {fr} file can't be accessed

return loTest.result()

* ========================================
function cFileCheckSum && {fr} Checksum du contenu d'un fichier avec, le cas échéant, son fichier lié
lparameters ;
  tcFile; && {fr} Fichier
, tlMemo; && [.F.] {fr} Inclure le memo associé éventuel
, tnPadr; && [none] {fr} Longueur à padder

tcFile = evl(m.tcFile, '')
tlMemo = lTrue(m.tlMemo)

local lcResult;
, llResult;
, tnFile;
, lcFile, llFile, lnFile

lcResult = .null.

if file(m.tcFile)

	tnFile = nFileSize(m.tcFile)
	llResult = not isnull(m.tnFile) && {fr} la taille du fichier a pu être calculée
	if m.llResult

		llResult = m.tnFile < VFP_VAR_SIZE_MAX
		assert m.llResult message cAssertMsg(Textmerge(icase(;
			cLangUser() = 'fr',	[La taille du fichier '<<JustFname(m.tcFile)>>' excède la limite VFP de 16 Mo],; && copy-paste this line to add another language support
													[Size of file '<<JustFname(m.tcFile)>>' exceeds the VFP 16 Mb limitation]; && default: English
		)))
		if .t.;
		 and m.llResult;
		 and vartype(m.tlMemo) == 'L';
		 and m.tlMemo

			lcFile = FileMemo(m.tcFile)
			llFile = file(m.lcFile)
			if m.llFile

				lnFile = nFileSize(m.lcFile)
				llResult = not isnull(m.lnFile) && {fr} la taille du fichier a pu être calculée
				if m.llResult

					llResult = m.lnFile < VFP_VAR_SIZE_MAX
					assert m.llResult message cAssertMsg(Textmerge(icase(;
						cLangUser() = 'fr',	[La taille du fichier '<<JustFname(m.lcFile)>>' dépasse la limite VFP de 16 Mo],; && copy-paste this line to add another language support
																[Size of file '<<JustFname(m.lcFile)>>' exceeds the VFP 16 Mb limitation]; && default: English
					)))
					if m.llResult

						llResult = m.tnFile + m.lnFile < VFP_VAR_SIZE_MAX
						assert m.llResult message cAssertMsg(Textmerge(icase(;
							cLangUser() = 'fr',	[La taille des fichiers '<<JustFname(m.tcFile)>>' et '<<JustFname(m.lcFile)>>' dépasse la limite VFP de 16 Mo],; && copy-paste this line to add another language support
																	[Size of files '<<JustFname(m.tcFile)>>' and '<<JustFname(m.lcFile)>>' exceeds the VFP 16 Mb limitation]; && default: English
						)))
					endif
				endif
			endif
		endif
	endif
	if m.llResult

		lcResult = sys(2007;
			, filetostr(m.tcFile) + iif(m.llFile, filetostr(m.lcFile), '');
			, -1; && {fr} nSeed : Specifies a numeric seed value of 0 that is used to calculate the checksum and is included for backward compatibility. Passing a value of -1 for nSeed uses the default system value of 0. For CRC32 calculations, Visual FoxPro disregards nSeed.
			, 1; && {fr} CRC32 - For CRC32 calculations, Visual FoxPro disregards nSeed
			)
	endif
endif

return iif(m.llResult and vartype(m.tnPadr) == 'N' and m.tnPadr > 0;
	, padr(m.lcResult, m.tnPadr);
	, m.lcResult;
	)
endfunc

* ========================================
procedure FilesRename && {fr} Renomme des fichiers dans un dossier [et ses sous-dossiers]
lparameters ;
  tcFileSkels; && {fr} Masques de fichiers à traiter (séparés par ',')
, tcFileNew; && {fr} Nouveau nom
, tcFolders; && {fr} Adresses des dossiers où les fichiers sont à chercher
, tlSubFolders; &&	[.F.] {fr} Traiter les fichiers dans les sous-dossiers
, tcSubFoldersExcl && [m.tlSubFolders, ''] {fr} Sous-dossiers à exclure (séparés par ',')

return iif(lFileSkeleton(m.tcFileSkels) and m.tcFileSkels # [*.*];
	, FilesProc(m.tcFolders, 'FileRename', m.tcFileSkels, m.tlSubFolders, m.tcSubFoldersExcl, m.tcFileNew);
	, 0)

* ========================================
procedure FileRename && {fr} Renomme un fichier
lparameters ;
  tcFile; && {fr} Adresse du fichier à renommer
, tcFileNew && {fr} Nouveau nom
tcFileNew = forcepath(m.tcFileNew, justpath(m.tcFile))

local llResult

llResult = lFileSkeleton(m.tcFileNew) or !lFile(m.tcFileNew)
assert m.llResult message cAssertMsg(textmerge([Impossible de renommer <<m.tcFile>> en <<m.tcFileNew>> car ce fichier existe déjà]))
if m.llResult
	rename (m.tcFile) to (m.tcFileNew)
endif

return m.llResult

* ========================================
procedure FilesDelete && {fr} Alias de FilesDel()
lparameters ;
  tcFileSkels; && {fr} Masques de fichiers à traiter
, tcFolders; && {fr} Adresses des dossiers où sont les fichiers
, tlSubFolders; && [.F.] {fr} Traiter les fichiers dans les sous-dossiers
, tcSubFoldersExcl; && [m.tlSubFolders, ''] {fr} Sous-dossiers à exclure de la recherche (séparés par ',')
, tlRecycle; && [.F.] {fr} Placer les fichiers supprimés dans la corbeille
, tlFolderEmptyDel; && [.F.] {fr} Supprimer les dossiers vides
, tcError; && @ [''] {fr} Détail de l'erreur éventuelle

return FilesDel(;
		m.tcFileSkels;
	, m.tcFolders;
	, m.tlSubFolders;
	, m.tcSubFoldersExcl;
	, m.tlRecycle;
	, m.tlFolderEmptyDel;
	, @m.tcError;
	)

* ========================================
procedure FilesDel && {fr} Supprime des fichiers dans un dossier [et ses sous-dossiers]
lparameters ;
  tcFileSkels; && {fr} Masques de fichiers à traiter
, tcFolders; && {fr} Adresses des dossiers où sont les fichiers
, tlSubFolders; && [.F.] {fr} Traiter les fichiers dans les sous-dossiers
, tcSubFoldersExcl; && [m.tlSubFolders, ''] {fr} Sous-dossiers à exclure (séparés par ',')
, tlRecycle; && [.F.] {fr} Placer les fichiers supprimés dans la corbeille
, tlFolderEmptyDel; && [.F.] {fr} Supprimer les dossiers vides
, tcResult; && @ [''] {fr} Détail de l'erreur éventuelle
, tnResult; && @ [0] {fr} Nombre de fichiers copiés

tlSubFolders = lTrue(m.tlSubFolders)
tlRecycle = lTrue(m.tlRecycle)

local llResult as Boolean;
, lcResult as String;
, laFolders[1], lcFolder;
, laSubFolders[1], lcSubFolder, liSubFolder

tnResult = FilesProc(;
	  m.tcFolders;
	, 'FileDel';
	, m.tcFileSkels;
	, m.tlSubFolders;
	, m.tcSubFoldersExcl;
	, m.tlRecycle;
	, m.tlFolderEmptyDel;
	,@m.lcResult;
	)

llResult = empty(m.lcResult) or cResultAdd(@m.tcResult, m.lcResult)

* {fr} Supprimer les répertoires vides résiduels (Windows cache les fichiers / dossiers: FileDel() ne voit pas toujours bien si le dossier est vide)
if m.llResult and lTrue(m.tlFolderEmptyDel) and alines(laFolders, m.tcFolders, 1, ',', ';') > 0

	for each lcFolder in m.laFolders
		if m.tlSubFolders
			for liSubFolder = aSubFolders(@m.laSubFolders, m.lcFolder, m.tcSubFoldersExcl, .t., .t.) to 1 step -1
				lcSubFolder = m.laSubFolders[m.liSubFolder]
				if lDirEmpty(m.lcSubFolder)
					rd (m.lcSubFolder)
				endif
			endfor
		endif
		try
			if lDirEmpty(m.lcFolder) && !m.tlFolderEmptyRootKeep and && [.F.] {fr} Garder les dossiers racines même si vides && impossible de 
				rd (m.lcFolder)
			endif
		catch
		endtry
	endfor
endif

return m.llResult
endproc

*!*		* ========================================
*!*		PROCEDURE FileDelete && {fr} Supprime un fichier && {fr} alias de FileDel() && {fr} abandonné à cause d'un conflit avec FileDelete.exe de web connect
*!*		LPARAMETERS ;
*!*			tcFile,; && {fr} Adresse du fichier à supprimer
*!*			tlRecycle,; && [.F.] {fr} Placer les fichiers dans la corbeille
*!*			tlFolderEmptyDel,; && [.F.] {fr} Supprimer les dossiers vides
*!*			tcError && @ [''] {fr} Détail de l'erreur éventuelle
*!*
*!*		RETURN FileDel(m.tcFile, m.tlRecycle, m.tlFolderEmptyDel, @m.tcError)

* ========================================
procedure FileDel && {fr} Supprime un fichier
lparameters ;
  tcFile; && {fr} Adresse du fichier à supprimer
, tlRecycle; && [.F.] {fr} Placer les fichiers dans la corbeille
, tlFolderEmptyDel; && [.F.] {fr} Supprimer les dossiers vides
, tcResult && @ [''] {fr} Détail de l'erreur éventuelle, cumulative

local llResult;
, lcRecycle;
, lcPath;
, loException as exception;

try

	lcRecycle = iif(lTrue(m.tlRecycle), 'RECYCLE', '')

	if inlist(lower(justext(m.tcFile)), 'fxp', 'prg') and upper(forceext(m.tcFile, 'fxp')) $ set("Procedure")
		release procedure (m.tcFile)
	endif

	delete file (m.tcFile) &lcRecycle

	lcPath = JustPath(m.tcFile)
	if lTrue(m.tlFolderEmptyDel) and lDirEmpty(m.lcPath)
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
procedure FilesProc && {fr} Applique une procédure à tous les fichiers d'un dossier [et de ses sous-dossiers] - jusqu'à 19 paramètres peuvent être passés à la procédure
lparameters ;
  tcFolders; && {fr} Adresses des dossiers où les fichiers sont à chercher
, tcProc; && {fr} Procédure à appliquer à chaque fichier trouvé (son premier paramètre est l'adresse du fichier)
, tcFileSkels; && ['*.*'] {fr} Masques de fichiers à traiter (séparés par ',')
, tlSubFolders; &&	[.F.] {fr} Traiter les fichiers dans les sous-dossiers
, tcSubFoldersExcl; && [m.tlSubFolders, ''] {fr} Sous-dossiers à exclure (séparés par ',')
, tuProcParm02; && @ 2ème paramètre à passer à la procédure (le premier est l'adresse du fichier)
, tuProcParm03; && @ 3ème paramètre à passer à la procédure
, tuProcParm04; && @ 4eme paramètre à passer à la procédure
, tuProcParm05; && @ 5ème paramètre à passer à la procédure
, tuProcParm06; && @ 6ème paramètre à passer à la procédure
, tuProcParm07; && @ 7ème paramètre à passer à la procédure
, tuProcParm08; && @ 8ème paramètre à passer à la procédure
, tuProcParm09; && @ 9ème paramètre à passer à la procédure
, tuProcParm10; && @ {fr} xème paramètre à passer à la procédure
, tuProcParm11; && @ {fr} xème paramètre à passer à la procédure
, tuProcParm12; && @ {fr} xème paramètre à passer à la procédure
, tuProcParm13; && @ {fr} xème paramètre à passer à la procédure
, tuProcParm14; && @ {fr} xème paramètre à passer à la procédure
, tuProcParm15; && @ {fr} xème paramètre à passer à la procédure
, tuProcParm16; && @ {fr} xème paramètre à passer à la procédure
, tuProcParm17; && @ {fr} xème paramètre à passer à la procédure
, tuProcParm18; && @ {fr} xème paramètre à passer à la procédure
, tuProcParm19   && @ {fr} xème paramètre à passer à la procédure
&& {fr} on pourrait passer jusqu'à 19 paramètres à la procédure ...

tcFileSkels = iif(vartype(m.tcFileSkels) == 'C', alltrim(m.tcFileSkels), [*.*])
tlSubFolders = lTrue(m.tlSubFolders)
tcSubFoldersExcl = iif(m.tlSubFolders and vartype(m.tcSubFoldersExcl)=='C', upper(m.tcSubFoldersExcl), '')

local lnResult; && {fr} Nombre de fichiers traités
, llResult;
, llWaitWindow as Boolean;
, laSkels[1], lnSkels, lcSkel;
, lnDocs, laDocs[1], laDocsSkel[1];
, lnDoc, lcDoc, lcDocAddr, llDoc;
, laFolders[1], lcFolder;
, laSubFolders[1], lnSubFolders, lnSubFolder;
, lcProcParms, liProcParm;
, lnOdometer as Integer;

lnResult = 0
llWaitWindow = Vartype(m.plWaitWindow) == 'L' and m.plWaitWindow
lnOdometer = Set("Odometer")
if !Vartype(m.pnFilesProc) == 'N'
	private pnFilesProc
	pnFilesProc = 0
endif

* {fr} Si les paramètres requis sont valides
llResult = ga_Type_IsChar(m.tcFolders, .T.) and ga_Type_IsChar(m.tcProc, .T.) && {fr} comment vérifier que la procédure est accessible ?
assert m.llResult message cAssertMsg(textmerge([Les dossiers <<cLitteral(@tcFolders)>> ou la procédure <<cLitteral(@m.tcProc)>> est invalide]))
if m.llResult

	lnSkels = alines(laSkels, m.tcFileSkels, .t., ',')

	* {fr} Pour chaque dossier
	alines(laFolders, m.tcFolders, 1, [,], [;])
	for each lcFolder in laFolders

	* {fr} Si le dossier existe
		llResult = lDir(m.lcFolder, .T.)
		assert m.llResult message cAssertMsg(textmerge([le dossier '<<m.lcFolder>>' n'existe pas]))
		if m.llResult

			lcFolder = addbs(cFileCased(fullpath(m.lcFolder)))
			aClear(@m.laDocs)
			lnDocs = 0

			* {fr} Tabuler les fichiers situés dans le dossier et répondant au(x) squelette(s)
			If m.llWaitWindow
				wait cTronc("Getting a directory of files in folder " + cL(m.lcFolder), 250) window nowait noclear timeout 2
			endif
			for each lcSkel in laSkels
				if adir(laDocsSkel,  m.lcFolder + m.lcSkel, '', 1) > 0 && {fr} pas de dossier && {en} 1: capitalization on disk
					lnDocs = aAppend(@m.laDocs, @m.laDocsSkel)
				endif
			endfor
			asort(laDocs, 1, -1, 0, 1) && {fr} ascending, case insensitive

			* {fr} Si recherche dans les sous-dossiers demandée,
			if m.tlSubFolders

				If m.llWaitWindow
					wait cTronc("Reading subfolders of " + cL(m.lcFolder), 250) window nowait noclear timeout 2
				endif

				* {fr} Si sous-dossier(s) dans le dossier
				lnSubFolders = aSubFolders(@m.laSubFolders, m.lcFolder, m.tcSubFoldersExcl)
				if m.lnSubFolders > 0

					* {fr} Supprimer l'adresse du dossier de départ && {fr} par cohérence avec le aDir() ci-dessus
					for lnSubFolder = 1 to m.lnSubFolders
						laSubFolders[m.lnSubFolder, 1] = strtran(laSubFolders[m.lnSubFolder, 1], m.lcFolder, '', 1, -1, 1) && 1 - Search is case-insensitive and replacement is performed with exact cReplacement text.
					endfor
					asort(laSubFolders, 1, -1, 0, 1) && {fr} ascending, case insensitive

					* {fr} Ajouter les sous-dossiers AVANT les documents
					lnDocs = aAppend(@m.laDocs, @m.laSubFolders,, .t.)
				endif
			endif

			* {fr} Si le dossier comporte des documents
			if m.lnDocs > 0

				* {fr} Préparer la chaine de paramètres à passer à la procédure
				lcProcParms = ''
				for liProcParm = 2 to pcount();
						- 5; && {fr} les paramètres commencent en 6è position
						+ 1 && {fr} les n° de paramètres commencent à 2
					lcProcParms = textmerge([<<m.lcProcParms>>, @m.tuProcParm<<Padl(m.liProcParm, 2, '0')>>])
				endfor

				* {fr} Pour chaque "document" (fichier ou sous-dossier)
				for lnDoc = 1 to m.lnDocs
					lcDoc = laDocs[m.lnDoc, 1]
					lcDocAddr = m.lcFolder + m.lcDoc

					* {fr} Si dossier exploitable, récurser le cas échéant
					if 'D' $ upper(laDocs[m.lnDoc, 5])

						if m.tlSubFolders and !inlist(m.lcDoc, '.', '..')
						 	lnResult = m.lnResult; && {fr} récursion
						 		+ evaluate('FilesProc(m.lcDocAddr, m.tcProc, m.tcFileSkels, m.tlSubFolders, m.tcSubFoldersExcl' + m.lcProcParms + ')')
						endif

					* {fr} Sinon (fichier), appliquer la procédure indiquée
					else
						
						* ========================================================================
						llDoc = Evaluate(Textmerge([<<m.tcProc>>(m.lcDocAddr <<m.lcProcParms>>)]))
						* ========================================================================
						
						lnResult = m.lnResult + iif(m.llDoc, 1, 0)
						pnFilesProc = m.pnFilesProc + iif(m.llDoc, 1, 0)
						If m.llWaitWindow and (m.pnFilesProc < m.lnOdometer or Empty(m.pnFilesProc%m.lnOdometer))
							wait cTronc("File # " + Ltrim(Transform(m.pnFilesProc, '999,999')) + ': ' + m.lcDocAddr, 250) window nowait noclear timeout 2 && The length of cMessageText can be up to 255 characters
						endif
					endif
				endfor
			endif
		endif
	endfor
endif

return m.lnResult
endproc

* -------------------------------
procedure FilesProc_Test && {fr} Teste FilesProc()

local loTest as abUnitTest of abDev.prg
loTest = newobject('abUnitTest', 'abDev.prg')
loTest.Test(, getdir(curdir(),'',"Où sont les fichiers Excel à traiter ?", 16), ;
						'FilesProc_Test_Proc', '*.xls', .t., '', date())

return loTest.result()
endproc

* ------------------------------------
	procedure FilesProc_Test_Proc && {fr} Procédure appelée par FilesProc_Test()
	lparameters ;
		tcFile;
, tuParm

	* {fr} Afficher l'adresse du fichier et le paramètre
	? cFileCased(m.tcFile), ' -- paramètre :', transform(m.tuParm)

* ========================================
function cFileSubFolders && {fr} Fichier dans un dossier ou un des ses sous-dossiers
lparameters ;
  tcFile; && {fr} Fichier
, tcFoldersExcl; && [''] {fr} sous-dossiers à exclure et/ou squelette des fichiers attendus dans les dossiers à inclure
, tvRecurse && [.F.] {fr} Récurser dans les sous-sous-dossiers etc., si N, nombre de niveaux de récursion

local laFolders[1], lcFolder, lcFile, llResult, lcResult

lcResult = ''
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
endfunc

* ========================================
function aSubFolders && {fr} Sous-dossiers d'un dossier /!\ Récursive
lparameters ;
  taSubFolders; && @ {fr} Sous-dossiers selon aDir()
, tcFolder; && [dossier courant] {fr} Adresse du dossier où rechercher les sous-dossiers
, tcFoldersExcl; && [''] {fr} sous-dossiers à exclure et/ou squelette des fichiers attendus dans les dossiers à inclure
, tvRecurse; && [.F.] {fr} Récurser dans les sous-sous-dossiers etc., si N, nombre de niveaux de récursion
, tlAddrOnly; && [.F.] {fr} Ne garder que les adresses des dossiers (supprimer date, taille, etc.)

external array taSubFolders && {fr} pour le gestionnaire de projet
tcFolder = addbs(fullpath(evl(m.tcFolder, '')))
tcFoldersExcl = iif(vartype(m.tcFoldersExcl) == 'C', Lower(m.tcFoldersExcl), '')

local lnResult; && {fr} Nombre de sous-dossiers trouvés
, llResult;
, lcTypeRecurse, llRecurse, llFirst, lcDefault;
, laFolders[1], lnFolder, lcFolder, llFolder, lcPath, lnSubFolders, lnFileSkel;

lcTypeRecurse = vartype(m.tvRecurse)
tvRecurse = iif(m.lcTypeRecurse == 'N' and m.tvRecurse > 0;
	, m.tvRecurse;
	, m.lcTypeRecurse == 'L' and m.tvRecurse;
	)
lnResult = 0

* {fr} Si les paramètres requis sont valides
llResult = type('taSubFolders', 1) == 'A' && {fr} aClear() est fait plus loin à la première récursion
assert m.llResult message cAssertMsg(textmerge([Le premier paramètre <<cLitteral(taSubFolders)>> doit être un tableau]))
if m.llResult

	llResult = lDir(m.tcFolder, .t.)
	* {fr} ASSERT m.llResult MESSAGE cAssertMsg(textmerge([Le dossier '<<m.tcFolder>>' est introuvable]))
	if m.llResult

		* {fr} Si première récursion && {fr} optimisation
		if vartype(m.pnFoldersExcl) == 'U'

			tcFolder = cFileCased(m.tcFolder)
			aClear(@m.taSubFolders) && {fr} Vide le résultat
			* {fr} Tabuler les dossiers à exclure et/ou les masques de fichiers à trouver dans les dossiers
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

		* {fr} Pour chaque sous-dossier
		lcDefault = sys(5) + curdir()
		set default to (m.tcFolder)
		lnResult = ADir(laFolders, '', 'D', 1) && '' makes aDir() return Folders && {en} 1: capitalization on disk
		set default to (m.lcDefault)

		llRecurse = iif(m.lcTypeRecurse == 'N', m.pnRecurse < m.tvRecurse, m.tvRecurse)
		lnSubFolders = 0
		for lnFolder = m.lnResult to 1 step -1

			lcFolder = laFolders[m.lnFolder, 1]
			lcPath = m.tcFolder + addbs(m.lcFolder)

			* {fr} Si bidon ou exclus, supprimer
			llFolder = not (.F.;
				 or inlist(m.lcFolder, '.', '..'); && {fr} bidon
				 or m.pnFoldersExcl > 0 and aSubFolders_lExcluded(@m.paFoldersExcl, m.lcFolder); && {fr} exclus
				)
			if m.llFolder

				* {fr} Si récursion demandée, compter les sous-dossiers
				lnSubFolders = m.lnSubFolders + iif(m.llRecurse;
					, aSubFolders(@m.taSubFolders, m.lcPath, m.tcFoldersExcl, m.tvRecurse, m.tlAddrOnly);
					, 0)

				if m.pnFileSkel > 0
					llFolder = .f.
					for lnFileSkel = 1 to m.pnFileSkel
						llFolder = m.llFolder or lFiles(m.lcPath + m.paFileSkel[m.lnFileSkel])
					endfor
				endif
			endif

			* {fr} Si le dossier est OK, ajouter à la liste sinon supprimer
			if m.llFolder
				laFolders[m.lnFolder, 1] = m.lcPath
			else
				adel(laFolders, m.lnFolder)
				lnResult = m.lnResult - 1
			endif
		endfor

		* {fr} Si des dossiers ont été trouvés
		if m.lnResult > 0
			dimension laFolders[m.lnResult, Alen(laFolders, 2)]

			* {fr} Si demandé, supprimer les colonnes superflues
			if lTrue(m.tlAddrOnly)
				aColsDel(@m.laFolders, 2)
				dimension laFolders[Alen(m.laFolders)]
			endif

			* {fr} Ajouter les dossiers au résultat
			aAppend(@m.taSubFolders, @m.laFolders,, .t.) && {fr} bottom up
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
function aSubFolders_lExcluded && {fr} Un sous-dossiers répond à un des masques d'exclusion /!\ privée de aSubFolders()
lparameters ;
  aFoldersExcl; && @ {fr} Sous-dossiers selon aDir()
, lcFolder; && [dossier courant] {fr} Adresse du dossier où rechercher les sous-dossiers

external array aFoldersExcl
local cFoldersExcl
lcFolder = Lower(Alltrim(m.lcFolder)) && {fr} aFoldersExcl[] is lower case
for each cFoldersExcl in m.aFoldersExcl
	if Like(m.cFoldersExcl, m.lcFolder)
		return .T.
	endif
endfor
return .F.
endfunc

* ========================================
function cFolder && {fr} Dossier d'une Adresse
lparameters tcAddress && {fr} adresse

local lcResult, lcPath

lcResult = ''

if ga_Type_IsChar(m.tcAddress, .T.)
	lcPath = justpath(m.tcAddress)
	lcResult = substr(m.lcPath, ratc('\', m.lcPath)+1)
endif

return m.lcResult
endfunc

* ========================================
function cFolders && {fr} Dossiers d'une liste d'Adresses
lparameters tcAdresses && {fr} Adresses

local laAddress[1], lnAddress, lcResult

lcResult = ''
if vartype(m.tcAdresses) == 'C' and not empty(m.tcAdresses)

	for lnAddress = 1 to alines(laAddress, m.tcAdresses, 1, ',', ';', CRLF, CR, LF)
		laAddress[m.lnAddress] = cFolder(laAddress[m.lnAddress])
	endfor
	lcResult = cListOfArray(@m.laAddress)
endif

return m.lcResult

* ========================================
function cFiles && {fr} Fichiers selon un squelette
lparameters ;
  tcSkeleton; && {fr} squelette de fichiers
, tcSep; && [,] {fr} séparateur de liste
, tlRecurse && [.F.] {fr} Explorer les sous-dossiers éventuels

tcSep = evl(m.tcSep, [,])

local lcResult, laFiles[1], lcFolder
lcResult = ''

if lFileAddrSkeleton(m.tcSkeleton)

	adir(laFiles, m.tcSkeleton, '', 1) && {en} 1: capitalization on disk
	lcResult = cListOfArray(@m.laFiles, m.tcSep, 1)

	* {fr} Si dossiers contenus
	if lTrue(m.tlRecurse);
	 and aClear(@m.laFiles);
	 and aSubFolders(@m.laFiles, justpath(m.tcSkeleton), '', .t., .t.) > 0

		for each lcFolder in laFiles
			lcResult = c2Words(m.lcResult, m.tcSep, cFiles(addbs(m.lcFolder) + justfname(m.tcSkeleton), m.tcSep, m.tlRecurse))
		endfor
	endif
endif

return m.lcResult
endfunc

* ========================================
function cFileAddressOK && {fr} Adresse de fichier possible dans un dossier (ajoute un suffixe au stem du fichier si nécessaire)
lparameters tcFileAddr && {fr} Adresse de fichier à vérifier

local lcPath, lcStem, lcExt, lcStemNew, lnTrial, lcResult

lcResult = ''

if vartype(m.tcFileAddr) == 'C'
	lcPath = addbs(justpath(m.tcFileAddr))

	if lDir(m.lcPath) ;
	 and lFileAddress(m.tcFileAddr)
		lcResult = m.tcFileAddr

		if file(m.lcResult)
			lcStem = juststem(m.lcResult)
			lcExt = justext(m.lcResult)

			* {fr} Ajouter un suffixe au Stem si le fichier existe déjà
			lnTrial = 0
			do while file(m.lcResult)
				lnTrial = lnTrial + 1
				if lnTrial > 26 && {fr} les 26 lettres sont déjà utilisées
					lcResult = ''
					exit
				endif
				lcStemNew = m.lcStem + chr(96 + m.lnTrial) && {fr} a, b, c, etc.
				lcResult = m.lcPath + m.lcStemNew + '.' + m.lcExt
			enddo
		endif
	endif
endif

return m.lcResult

* ========================================
function lFileName && {fr} Une chaîne de caractère peut être admise comme nom de fichier
lparameters tcFileName && {fr} nom de fichier à analyser

return .t.;
 and vartype(m.tcFileName) = 'C';
 and !empty(juststem(m.tcFileName));
 and Lenc(m.tcFileName) <= 255; && "Individual components of a filename (i.e. each subdirectory along the path, and the final filename) are limited to 255 characters" && {fr} http://stackoverflow.com/questions/265769/maximum-filename-length-in-ntfs-windows-xp-and-windows-vista
 and chrtran(m.tcFileName, CAR_INT_DS_NOM_FICH, '') == m.tcFileName

* ========================================
function lFileSkeleton && {fr} Squelette de nom de fichier valide
lparameters tcFileSqueleton && {fr} Squelette de nom de fichier

return vartype(m.tcFileSqueleton) = 'C';
 and !empty(m.tcFileSqueleton);
 and !empty(JustExt(m.tcFileSqueleton)); && ? JustExt('toto.*') && '*'
 and ('*' $ m.tcFileSqueleton or '?' $ m.tcFileSqueleton);
 and chrtran(m.tcFileSqueleton, chrtran(CAR_INT_DS_NOM_FICH, "?*", ''), '') == m.tcFileSqueleton
endfunc

* ========================================
function cFileName && {fr} Chaîne de caractère admissible comme nom de fichier
lparameters tcFileName && {fr} nom de fichier à analyser

local lnPeriod, lcStem, lcExt, lcResult

lcResult = ''
if vartype(m.tcFileName) == 'C'

	lnPeriod = ratc('.', m.tcFileName)
	lcExt = iif(m.lnPeriod > 0, Substrc(m.tcFileName, m.lnPeriod + 1), '')
	lcStem = iif(m.lnPeriod > 0, Leftc(m.tcFileName, m.lnPeriod-1), m.tcFileName)
	if not empty(m.lcStem)

		lcResult = cRepCharDel(chrtran(m.lcStem, CAR_INT_DS_NOM_FICH, replicate('_', len(CAR_INT_DS_NOM_FICH))), '_');
			+ nEvl(m.lcExt, '.' + m.lcExt)
	endif
endif

return m.lcResult

* ----------------------------------------------
procedure cFileName_Test && {fr} Teste cFileName()

local loTest as abUnitTest of abDev.prg
loTest = newobject('abUnitTest', 'abDev.prg')

loTest.Test( "n_importe quoi.txt", "n:importe quoi.txt")
loTest.Test( "20070529 12_30_02 Maint.csv", "20070529 12:30:02 Maint.csv")
return loTest.result()

* ========================================
function cFileCased && {fr} Adresse d'un fichier || dossier avec sa casse originale && {fr} Tracy Pearson / http://fox.wikis.com/wc.dll?Wiki~MixedCaseFilePath~VFP
lparameters ;
  tcFile; && {fr} Adresse du fichier
, tlFullPath; && [.F.] {fr} Donner l'adresse complète

local lcResult;
, llResult;
, liWord, lcWord;
, llBS;
, lcFile, laFiles[1]

lcResult = ''

if vartype(m.tcFile) == 'C' and (file(m.tcFile) or directory(m.tcFile))

	llBS = rightc(rtrim(m.tcFile), 1) == '\'
	lcFile = Iif(lFullPath(m.tcFile, .T.);
		, m.tcFile;
		, fullpath(m.tcFile);
		)

	* {fr} Pour chaque dossier dans le chemin, et le fichier
	lcResult = '';
		+ iif(leftc(m.lcFile, 2) == '\\', '\\', ''); && {fr} network drive
	 	+ upper(getwordnum(m.lcFile, 1, '\')) && _cliptext = cL(getwordnum('\\server\c', 1, '\')) && "server"
	llResult = .T.
	for liWord = 2 to GetWordCount(m.lcFile, '\')

		lcWord = getwordnum(m.lcFile, m.liWord, '\')
		do case
		case m.lcWord == '.' && 2016-02-24 thn -- {en} added
		case m.lcWord == '..' && 2016-02-24 thn -- {en} added
			lcResult = Leftc(m.lcResult, Ratc('\', m.lcResult)-1)
		case varSet(@m.lcResult, m.lcResult + '\') and adir(laFiles, m.lcResult + m.lcWord, [HSD], 1) > 0 && {en} 1: capitalization on disk
			lcResult = m.lcResult + laFiles[1]
		otherwise
			llResult = .F.
			exit
		endcase
	endfor

	if m.llResult
		if not lTrue(m.tlFullPath) and not '~' $ m.tcFile
			lcResult = rightc(m.lcResult, lenc(m.tcFile)) && {fr} au cas où l'adresse indiquée était partielle
		endif
		if m.llBS
			lcResult = addbs(m.lcResult)
		else
			lcResult = ForceExt(m.lcResult, Lower(JustExt(m.lcResult))) && {fr} force l'extension en minuscules
		endif
	else
		lcResult = m.lcFile
	endif
endif

return m.lcResult
endfunc

* ========================================
procedure cFileCased_Test && {fr} Teste cFileCased()

local loTest as abUnitTest of abDev.prg
loTest = newobject('abUnitTest', 'abDev.prg')

loTest.Test("AB\abFile.PRG", "ab\abFile.prg")
loTest.Test(Home(1) + "Tools\AB\abFile.PRG", "ab\abFile.prg", .t.)
loTest.Test(Home(1) + "Tools", DOS_AB + "..", .t.)
loTest.Test(Home(1) + "Tools\", DOS_AB + "..\", .t.)
loTest.Test(Home(1) + "", DOS_AB + "..\..\", .t.)

return loTest.result()

* ========================================
function lPath && {fr} Une chaîne de caractère peut être admise comme adresse complète ou relative
lparameters ;
  tcPath; && {fr} Adresse à analyser
, tlSkeleton && [.F.] {fr} L'adresse peut être un squelette de fichiers

return .t.;
	and vartype(m.tcPath) == 'C';
	and not empty(m.tcPath);
	and m.tcPath == chrtran(m.tcPath; && {fr} aucun caractère interdit
			, iif(lTrue(m.tlSkeleton);
				, chrtran(CAR_INT_DS_ADR_FICH, '?*', '');
				, CAR_INT_DS_ADR_FICH;
				) + CRLF + TABUL;
			, '';
			)

* ========================================
function lFullPath && {fr} Une chaîne de caractère peut être admise comme adresse complète
lparameters ;
  tcPath; && {fr} Adresse à analyser
, tlDrive; && [.F.] {fr} Le lecteur doit exister
, tlSkeleton && [.F.] {fr} L'adresse peut être un squelette de fichiers

tlDrive = lTrue(m.tlDrive)

return .t.;
	and lPath(m.tcPath, m.tlSkeleton);
	and (.f.;
		or (.t.; && {fr} lecteur mappé
			and isalpha(justdrive(m.tcPath));
			and substr(m.tcPath, 2, 2) == ':\';
			and (not m.tlDrive or directory(justdrive(m.tcPath)));
			);
		or (.t.;
			and left(m.tcPath, 2) == '\\'; && {fr} lecteur réseau
			and (.f.;
				or not m.tlDrive;
				or directory(left(m.tcPath, at_c('\', m.tcPath, 3)));
				or directory(left(m.tcPath, at_c('\', m.tcPath, 4)));
				);
			);
		)

* ========================================
function lFileAddress && {fr} Adresse de fichier valide
lparameters tcFileAddr && {fr} Adresse de fichier à analyser

return .t.;
	and lFullPath(m.tcFileAddr);
	and lFileName(justfname(m.tcFileAddr))

* ========================================
procedure lFileAddress_Test && {fr} Teste lFileAddress()

local loTest as abUnitTest of abDev.prg
loTest = newobject('abUnitTest', 'abDev.prg')

loTest.Test(.f., "n'importe quoi")
loTest.Test(.t., "J:\aDossier\3592 VD Vignettes\Client\prop15Ecl.pdf")
loTest.Test(.t., "J:\aDossier\3592 VD Vignettes\Client\prop15\Ecl.pdf")
loTest.Test(.f., "J:\aDossier\3592 VD Vignettes\Client\prop15|Ecl.pdf")

return loTest.result()

* ========================================*******************************
function c83address && {fr} Version courte (8.3) de l'adresse d'un fichier/dossier EXISTANT
lparameter tcPath && {fr} Adresse supposée longue (> 8.3)

local lcResult;
, lnResult;
, lnLength, lcShortName, llPath

lcResult = ''

* {fr} Si le fichier ou le dossier existe
if vartype(m.tcPath) == 'C'

	tcPath = upper(alltrim(m.tcPath))
	llPath = lDir(m.tcPath, .T.)
	if not m.llPath && {fr} ce doit être une adresse de fichier
		local array laFiles[1]
		llPath = adir(laFiles, m.tcPath) = 1 && {fr} file() ne fonctionne pas avec les adresses courtes
	endif
	if m.llPath

		* {fr} Lire l'adresse courte
		declare Integer GetShortPathName in Win32API;
		  String @lpszLongPath,;
		  String @lpszShortPath,;
		  Integer cchBuffer
		lnLength = 260
		lcShortName = space (m.lnLength)
		lnResult = GetShortPathName(@m.tcPath, @m.lcShortName, m.lnLength)

		lcResult = iif(m.lnResult > 0;
			, left (m.lcShortName, m.lnResult); && {fr} la conversion a réussi
			, m.tcPath; && {fr} la conversion a échoué : l'adresse spécifiée est 8.3
			)
	endif
endif

return m.lcResult
endfunc

* ========================================
function cFileFreshest && {fr} Adresse de la dernière version d'un fichier d'après son n° de version (suffixe de la racine du nom)
lparameters ;
  tcFileAddrSkel; && {fr} squelette d'adresse du fichier à trouver (sans n° de version)
, tnVersion; && @ {fr} n° de la version la plus récente

local lcResult;
, lcPath;
, lcStem, lcExt;
, lcSkel;
, lnFile, laFiles[1], liFile;
, lcSuffixe;

lcResult = ''
tnVersion = 0

* {fr} Si le chemin existe
if vartype(m.tcFileAddrSkel)='C' ;
 and ! empty(m.tcFileAddrSkel)

	lcPath = addbs(justpath(tcFileAddrSkel))
	if empty(m.lcPath) or lDir(m.lcPath, .T.)

		* {fr} Lire la racine du nom sans le n° de version éventuel
		lcStem = upper(juststem(m.tcFileAddrSkel))
		lcExt = upper(justext(m.tcFileAddrSkel))
		do while val(right(m.lcStem, 1)) # 0
			lcStem = left(m.lcStem, len(m.lcStem)-1)
		enddo

		* {fr} Si au moins un fichier a la même racine de nom
		lcSkel = m.lcStem + iif (right (m.lcStem, 1) = '*', '', '*') + '.' + m.lcExt
		lnFile = adir(laFiles, m.lcPath + m.lcSkel)
		if m.lnFile > 0

			* {fr} Pour chaque fichier trouvé,
			for liFile = m.lnFile to 1 step -1

				* {fr} Lire le suffixe du stem du fichier
				lcSuffixe = strtran(upper(juststem(laFiles[m.liFile, 1])), m.lcStem, '') && {fr} élimine la 'racine'
				lcSuffixe = chrtran(m.lcSuffixe, ' _-', '') && {fr} élimine d'éventuels caractères de séparation

				* {fr} Si le suffixe n'est composé que de chiffres ou est vide (fichier original)
				if lDigits(m.lcSuffixe) ;
				 or empty(m.lcSuffixe)

					* {fr} Stocker le numéro de version dans la deuxième colonne du tableau (à la place de la taille)
					laFiles[m.liFile, 2] = val(m.lcSuffixe)

				* {fr} Sinon, supprimer le fichier de la liste
				else
					adel(laFiles, m.liFile)
					lnFile = m.lnFile - 1
				endif
			endfor

			* {fr} Si au moins un fichier est valide
			if m.lnFile > 0

				* {fr} Ignoer les fichiers invalides
				dimension laFiles[m.lnFile, Alen(laFiles, 2)]

				* {fr} Trier les fichiers valides par n° de version croissant
				asort(laFiles, 2) && {fr} Trie sur la deuxième colonne

				* {fr} Le dernier fichier est celui cherché
				lcResult = m.lcPath + laFiles[m.lnFile, 1]
				tnVersion = laFiles[m.lnFile, 2]
			endif
		endif
	endif
endif

return m.lcResult

* ========================================-----
function oProjectFiles && {fr} Collection Files d'un projet
lparameters toProject && [Projet courant] {fr} Référence à un objet projet ou à sa collection 'Files'

return ICase(;
	type('m.toProject.baseClass') == 'C';
	 and lower(m.toProject.baseclass) == 'project',;
		m.toProject.files,;
	type('m.toProject.parent.baseClass') == 'C';
	 and lower(m.toProject.parent.baseclass) == 'project',;
		m.toProject,;
	type('application.activeProject') == 'O',;
	application.activeProject.files,;
		.null.;
	)

endfunc

* ========================================-----
procedure ProjectFileAdd && {fr} Ajoute un fichier à un projet ouvert s'il n'y est déjà
lparameters ;
  tcFileAddr; && {fr} Adresse complète du fichier à ajouter au projet
, toProject; && [Projet courant] {fr} Référence à un objet projet ou à sa collection 'Files'
, tlInclude; && [.F.] {fr} Inclure au projet

local llResult

* {fr} Si une adresse de fichier valide a bien été passée
llResult = vartype(m.tcFileAddr) = 'C' and lFile(m.tcFileAddr)
assert m.llResult message program() + CRLF + "Adresse de fichier invalide : " + transform(m.tcFileAddr)
if m.llResult

	* {fr} Si un projet et sa collection de fichiers peuvent être trouvés
	local loFiles
	loFiles = oProjectFiles(m.toProject)
	llResult = not isnull(m.loFiles)
	assert m.llResult message program() + CRLF + "Aucun projet courant ou spec de projet invalide : " + transform(m.toProject)
	if m.llResult

		* {fr} Si le fichier n'est pas déjà dans le projet
		local lcFileAddr, loFile, llFile
		lcFileAddr = c83Address(m.tcFileAddr)
		for each loFile in m.loFiles
			llFile = justext(m.loFile.name) == justext(m.tcFileAddr) ; && {fr} to save time
			 				and c83Address(m.loFile.name) == m.lcFileAddr
			if m.llFile
				exit
			endif
		endfor
		if ! m.llFile

* {fr} Si le ficher est une table ouverte, mémoriser comment elle est ouverte
&& {fr} l'ajout d'une table au projet provoque sa fermeture !
			local llUsed
			if upper(justext(m.tcFileAddr)) = 'DBF'

				local lnUsedCount
				local array laUsed[1]
				lnUsedCount = aused(laUsed)
				if m.lnUsedCount > 0

					local lnUsed, lcAlias
					for lnUsed = 1 to m.lnUsedCount

						lcAlias = laUsed[m.lnUsed, 1] && {fr} column 1 contains aliases
						llUsed = c83Address(cTableAddress(m.lcAlias)) == m.lcFileAddr
						if llUsed

&& {fr} à passer en procédure ...
							local lcExclusive, lcOrder
							lcExclusive = iif(isexclusive(m.lcAlias), 'EXCLUSIVE', '')
							lcOrder = order(m.lcAlias)
							lcOrder = iif(empty(m.lcOrder), '', 'ORDER ') + m.lcOrder
&& ... à passer en procédure
							use in (m.lcAlias)
							exit
						endif
					endfor
				endif
			endif

			* {fr} Ajouter le fichier au projet
			local llInclude, loFile
			llInclude = uDefault(m.tlInclude, .f.)
			loFile = m.loFiles.add(m.tcFileAddr)
			loFile.Exclude = not m.llInclude

			* {fr} Si le ficher est une table ouverte, rouvrir comme précédemment
			if m.llUsed
				use (m.tcFileAddr) in 0 alias(m.lcAlias) &lcExclusive &lcOrder
			endif
		endif
	endif
endif

return m.llResult

* ==============================================
function nFileLines && {fr} Nombre de lignes dans un fichier
lparameters ;
  tcFileAddr && {fr} Adresse du fichier
local llResult, lnResult &&  && {fr} Taille du fichier en octets
lnResult = 0

* {fr} If file can be found
llResult = vartype(m.tcFileAddr) == 'C' and file(m.tcFileAddr)
assert m.llResult message program() + CRLF + "Invalid File Address Specification: " + transform(m.tcFileAddr)
if m.llResult

	lnResult = occurs(LF, filetostr(m.tcFileAddr))
endif

return m.lnResult

* ========================================
function nFileSize_Folder && {fr} Taille des fichiers dans un dossier
lparameters ;
  tcFolders; && {fr} Adresses des dossiers où les fichiers sont à chercher
, tlSubFolders; && [.F.] {fr} Traiter les fichiers dans les sous-dossiers
, tcSubFoldersExcl; && [m.tlSubFolders, ''] {fr} Sous-dossiers à exclure (séparés par ',')
, tcFileSkels; && ['*.*'] {fr} Masques de fichiers à traiter (séparés par ',')
, tnFile; && @ {fr} nombre de fichiers trouvés

local result
store 0 to result, tnFile

if Pcount() = 2 and !',' $ m.tcFolders and !';' $ m.tcFolders and m.tlSubFolders

	with CreateObject('Scripting.FileSystemObject') as Scripting.FileSystemObject
		with .GetFolder(m.tcFolders)
			result = .Size
		endwith
	endwith

else

	FilesProc(; && {fr} Applique une procédure à tous les fichiers d'un dossier [et de ses sous-dossiers] - jusqu'à 19 paramètres peuvent être passés à la procédure
		  m.tcFolders; && tcFolders {fr} Adresses des dossiers où les fichiers sont à chercher
		, 'nFileSize_Folder_File'; && tcProc {fr} Procédure à appliquer à chaque fichier trouvé (son premier paramètre est l'adresse du fichier)
		, m.tcFileSkels; && tcFileSkels ['*.*'] {fr} Masques de fichiers à traiter (séparés par ',')
		, m.tlSubFolders; &&	tlSubFolders [.F.] {fr} Traiter les fichiers dans les sous-dossiers
		, m.tcSubFoldersExcl; && tcSubFoldersExcl [m.tlSubFolders, ''] {fr} Sous-dossiers à exclure (séparés par ',')
		,@m.result; && tuProcParm02 @ 2ème paramètre à passer à la procédure (le premier est l'adresse du fichier)
		,@m.tnFile; && tuProcParm03 @ 3ème paramètre à passer à la procédure
		)

endif

return m.result
endfunc

* ========================================
function nFileSize_Folder_File && {fr} (privée de nFileSize_Folder()) Taille d'un fichier dans un dossier
lparameters ;
  tcFile; && {fr} Adresses des dossiers où les fichiers sont à chercher
, nFileSize_Folder; && @ {fr} Taille des fichiers dans un dossier
, tnFile; && @ {fr} nombre de fichiers trouvés

nFileSize_Folder = m.nFileSize_Folder + nFileSize(m.tcFile)
tnFile = m.tnFile + 1
endfunc

* ========================================
procedure FilesExtChange && {fr} Change l'extension de fichiers dans un dossier [et ses sous-dossiers]
lparameters ;
  tcFoldAddr; && {fr} Adresse complète du dossier
, tcExtOld; && {fr} Ancienne extension
, tcExtNew; && {fr} Nouvelle extention
, tlSubFolders; && [.F.] {fr} Chercher aussi dans les sous-dossiers
, tcSubFoldsExcl && [m.tlSubFolders, ''] {fr} Sous-dossiers à exclure (séparés par ',')
local lnResult && {fr} nombre de fichiers traités
lnResult = 0

local llResult
llResult = vartype(m.tcFoldAddr) == 'C' and directory(m.tcFoldAddr)
assert m.llResult message program() + CRLF + "Dossier introuvable" + CRLF + cLitteral(m.tcFoldAddr)
if m.llResult

	llResult = not (empty(m.tcExtOld) or empty(m.tcExtNew))
	assert m.llResult message program() + CRLF + "Extension(s) invalides" + CRLF + cLitteral(m.tcExtOld) + CRLF + cLitteral(m.tcExtNew)
	if m.llResult

		local llSubFolders, lcSubFoldsExcl
		llSubFolders = uDefault(m.tlSubFolders, .f.)
		lcSubFoldsExcl = uDefault(m.tcSubFoldsExcl, '')

		lnResult = FilesProc(m.tcFoldAddr, 'FileExtChange', '*.' + alltrim(m.tcExtOld), m.llSubFolders, m.lcSubFoldsExcl, alltrim(m.tcExtNew))
	endif
endif

return m.lnResult

* ========================================
procedure FileExtChange && {fr} Change l'extension de fichiers dans un dossier [et ses sous-dossiers]
lparameters ;
  tcFileAddr; && {fr} Adresse du fichier
, tcExtNew && {fr} Nouvelle extension
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
function cSpecialFolderPath && {fr} Chemin des dossiers spéciaux
lparameters tiSpecialFolderID && {fr} cf. abFile.h
local lcResult
lcResult = space(255)

declare SHGetSpecialFolderPath in SHELL32.dll;
	long hWndOwner;
, String @lcResult,;
	long  nWhichFolder

SHGetSpecialFolderPath(0, @lcResult, m.tiSpecialFolderID)

lcResult = rtrim(m.lcResult)

return left(m.lcResult, len(m.lcResult)-1)

* ========================================
function FullPath_ && {fr} FullPath() amélioré
lparameters tcFile1, tcFile2
return iif(empty(m.tcFile1), '', fullpath(m.tcFile1, m.tcFile2))

* ========================================
function ForceStem && {fr} Modifie la racine d'une adresse de fichier
lparameters tcFile, tcStem
return addbs(justpath(m.tcFile)) + m.tcStem + '.' + justext(m.tcFile) && {V1.11} ForceExt() ne fonctionne pas si la racine du nom de fichier comporte un '.'

* ========================================
procedure SetPathFull && {fr} Change les chemins relatifs dans Set("Path") en chemins absolus

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
			set path to (m.lcPath) additive && {fr} When using the ADDITIVE parameter, paths must be included either as a quoted String or valid expression. If you use macro substitution, it must be properly quoted as in following examples
			if empty(m.lcRest)
				exit
			else
				lcPath = m.lcRest
			endif
		enddo
	endif
endif

* ========================================
function ForceDrive && {fr} change la lettre du disque dans une adresse de fichier
lparameters ;
  tcFile;
, tcDrive

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
function lFileWritable && {en} Wait for a given delay until a file can be accessed (about 2 ms)
lparameters ;
	cFile; && {en} file to be accessed exclusively
, nMS; && @ [50 ms] {en} wait delay to gain write access to file -- Between(m.nMS, 50 ms, 5000 ms); @: nMS elapsed
, nAttempt; && [10] {en} number of attempts to access

local success as Boolean;
, nSeconds;
, nSleepMS;
, hFile;
, cFileFPT, lFileFPT, hFileFPT;
, cFileCDX, lFileCDX, hFileCDX;

nSeconds = seconds()
if ga_Type_IsChar(m.cFile, .T.) and file(m.cFile) and !Used(cAliasUsed(m.cFile))

	nMS = min(max(Iif(ga_Type_isPositiveInteger(m.nMS), m.nMS, 0), 50), 5000)
	nAttempt = Iif(ga_Type_isPositiveInteger(m.nAttempt), m.nAttempt, 10)
	nSleepMS = Max(Int(m.nMS / m.nAttempt), 10) && minimum 10 ms between attempts
	cFile = FullPath(m.cFile)

	cFileFPT = FileMemo(m.cFile)
	lFileFPT = File(m.cFileFPT)

	cFileCDX = FileIndex(m.cFile)
	lFileCDX = File(m.cFileCDX)

	do while nMS(m.nSeconds) < m.nMS
		hFile = fopen(m.cFile, 2)
		hFileFPT = Iif(m.lFileFPT, fopen(m.cFileFPT, 2), -1)
		hFileCDX = Iif(m.lFileCDX, fopen(m.cFileCDX, 2), -1)
		success = .T.;
		 and m.hFile > -1;
		 and (!m.lFileFPT or m.hFileFPT > -1);
		 and (!m.lFileCDX or m.hFileCDX > -1)
		Fclose(m.hFile)
		Fclose(m.hFileFPT)
		Fclose(m.hFileCDX)
		if m.success
			exit
		else
			Sleep(m.nSleepMS) && modify command ab
		endif
	enddo
else
	success = .T.
endif

nMS = nMS(m.nSeconds) && feedback
return m.success
endfunc

* -------------------------------
procedure lFileWritable_Test && {fr} Teste lFileWritable()

local loTest as abUnitTest of abDev.prg
loTest = newobject('abUnitTest', 'abDev.prg')

loTest.test(.T., 'awCopy.cdx')
loTest.test(.T., Home(1) + 'Tools\AB\WC\wwRequestLog.dbf')

return loTest.result()
endproc

* ========================================
function cFileTimeStampName && {en} Name of a file with a time stamp
lparameters ;
	cFileAddr as String; && {en} File Address
, lSeconds as Boolean; && [.F.] {en} add seconds to time stamp
, lSkeleton as Boolean; && [.F.] {en} Skeleton of file name

lSeconds = lTrue(m.lSeconds)
local lnLen
lnLen = 12 + Iif(m.lSeconds, 2, 0)
return ForceExt('';
	  + JustStem(m.cFileAddr);
	  + '_';
	  + Transform(Iif(lTrue(m.lSkeleton), Replicate('?', m.lnLen), Left(Ttoc(Datetime(), 1), m.lnLen));
	  	, '@R 9999-99-99_99-99' + Iif(m.lSeconds, '-99', ''));
	, Lower(JustExt(m.cFileAddr));
	)
endfunc

* ========================================
function cFileTimeStampSaveAddr && {en} Address of a file saved with a time stamp
lparameters ;
	cFileAddr as String; && {en} File Address
, lSeconds as Boolean; && [.F.] {en} add seconds to time stamp
, lSkeleton as Boolean; && [.F.] {en} Skeleton of file name

local cFileTimeStampSaveAddr, cLangUser

cLangUser = cLangUser()

cFileTimeStampSaveAddr = Addbs(JustPath(m.cFileAddr)) + '_'
cFileTimeStampSaveAddr = m.cFileTimeStampSaveAddr + ICase(;
	Directory(m.cFileTimeStampSaveAddr + 'Save'), 'Save',;
	Directory(m.cFileTimeStampSaveAddr + 'Sauve'), 'Sauve',;
	Directory(m.cFileTimeStampSaveAddr + 'Old'), 'Old',;
		ICase(;
			m.cLangUser = 'fr',	'Sauve',;&& copy-paste this line to add another language support
			m.cLangUser = 'de',	'Speich',;&& copy-paste this line to add another language support
			m.cLangUser = 'es',	'Salvo',;&& copy-paste this line to add another language support
			m.cLangUser = 'it',	'Salva',;&& copy-paste this line to add another language support
			m.cLangUser = 'pt',	'Salva',;&& copy-paste this line to add another language support
													'Save'; && default: English
		);
	)

return Addbs(m.cFileTimeStampSaveAddr) + cFileTimeStampName(m.cFileAddr, m.lSeconds, m.lSkeleton)
endfunc

* ========================================
function FileTimeStampSave && {en} File saved with a time stamp
lparameters ;
  result as String; && @ {en} result (cumulative)
, cFileAddr as String; && {en} Source File Address
, lSeconds as Boolean; && [.F.] {en} add seconds to time stamp
, cFileAddrSave; && @ {en} Saved File Address
, nFileHistory; && [all] {en} Number of files to be kept as history

local success as Boolean;
, aFileHistory[1]; && {en} History of files
, iFileHistory; && {en} History File
, cFileHistory; && {en} History File
, cFilePath;

cFileAddrSave = cFileTimeStampSaveAddr(m.cFileAddr, m.lSeconds)
success = FileCopy(m.cFileAddr, m.cFileAddrSave, m.result)
if m.success and ga_type_isPositiveInteger(m.nFileHistory) and ADir(m.aFileHistory, cFileTimeStampSaveAddr(m.cFileAddr, m.lSeconds, .T.)) > m.nFileHistory

	aColsDel(@m.aFileHistory, 2)
	Asort(m.aFileHistory)
	cFilePath = Addbs(JustPath(m.cFileAddrSave))
	for iFileHistory = Alen(m.aFileHistory) - m.nFileHistory to 1 step -1
		success = FileDel(m.cFilePath + m.aFileHistory[m.iFileHistory],,, @m.result) and m.success
	endfor
	assert m.success
endif

return m.success
endfunc

* ========================================
function abFopen(tcFile) && {en} abFopen Object
return CreateObject('abFopen', m.tcFile)
endfunc

* ========================================
define class abFopen as GA_LIGHTWEIGHT_CLASS
iHandle = .F.
procedure init
	lparameters tcFile
	this.iHandle = Fopen(m.tcFile)
	return this.iHandle
endproc
procedure destroy
	if Vartype(this.iHandle) == 'N'
		return Fclose(this.iHandle)
	endif
endproc
enddefine
* ========================================


* ==============================================
function tFolder && {fr} Date et heure de dernière modification des fichiers d'un dossier
lparameters tcFolder && {fr} Dossier

local tResult as Datetime;
, laFile[1];
, liFile;
, lcTime;

tResult = .null.

if ga_Type_IsChar(m.tcFolder, .T.) and Directory(m.tcFolder) and ADir(laFile, Addbs(m.tcFolder) + '*.*') > 0
	for liFile = 1 to Alen(laFile, 1)
		tResult = laFile[m.liFile, 3]
		lcTime  = laFile[m.liFile, 4]
		laFile[m.liFile, 3] = Datetime(Year(m.tResult), Month(m.tResult), Day(m.tResult), Cast(GetWordNum(m.lcTime, 1, ':') as I), Cast(GetWordNum(m.lcTime, 2, ':') as I), Cast(GetWordNum(m.lcTime, 3, ':') as I))
	endfor
	Asort(m.laFile, 3, -1, 1)
	tResult = m.laFile[1, 3]
endif

return m.tResult
endfunc