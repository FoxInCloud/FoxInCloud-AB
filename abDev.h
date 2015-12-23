* {fr} Constantes de développement
#DEFINE VFPOPCARS	'!$+-/*%^<>=#' && {fr} opérateurs
#DEFINE VFPSEPCARS	' .,()[]!' + Chr(9) && {fr} Caractères de séparation (avec tabulateur)
#DEFINE VFPOPSEPCARS	VFPOPCARS + VFPSEPCARS
#DEFINE VFPOPSEPCARSLIST	"'!','$','+','-','/','*','%','^','<','>','=','#',' ',',','(',')','[',']'"

#DEFINE VFP_VAR_SIZE_MAX	16777184

* {en} Tools Folders
#DEFINE DOS_TOOLS			Home(1) + 'Tools\'
#DEFINE DOS_AB			DOS_TOOLS + 'AB\'
&& {fr} Iif(File('ab.prg'), addbs(justpath(fullpath('ab.prg'))), Home(1) + 'Tools\AB\')
#DEFINE DOS_ABGRAPHICS  DOS_AB + 'Graphics\'
#DEFINE DOS_AB_TEMP		DOS_AB + '_Temp\'
#DEFINE DOS_AC			DOS_AB + 'AC\'
#DEFINE DOS_AT			DOS_AB + 'AT\'

#DEFINE DOS_AW			DOS_AB + 'AW\'
#DEFINE DOS_AWAPP		DOS_AW + 'App\'
#DEFINE DOS_AWSCRIPTS	DOS_AW + 'Scripts\'
#DEFINE DOS_AWSAMPLES	DOS_AW + 'Samples\'
#DEFINE DOS_AWSAMPLES_	DOS_AW + 'Samples_\'

#DEFINE DOS_WC			DOS_AB + 'WC\'
#DEFINE DOS_WC_CLASSES	DOS_WC + 'Classes\'
#DEFINE DOS_FFC			Home(1) + 'FFC\'

* {fr} Dossiers à exclure des traitements batch
#DEFINE FOLDERS_EXCLUDE	'save,_save,old,_old,bak,back,_back,tmp,_tmp,temp,_temp,ancien,_ancien,anciens,_anciens,sauve,_sauve';
	 + ',source,_source,script,scripts,image,images,screenshots,doc,docs,test'

*!*	declare integer ShellExecute IN Shell32.dll; && {fr} If the function succeeds, it returns a value greater than 32
*!*		  integer nWinHandle; && {fr} A handle to the parent window used for displaying a UI or error messages. This value can be NULL if the operation is not associated with a window.
*!*		, string cOperation;
*!*		  ; && {en} edit: Launches an editor and opens the document for editing. If lpFile is not a document file, the function will fail.
*!*		  ; && {en} explore: Explores a folder specified by lpFile.
*!*		  ; && {en} find: Initiates a search beginning in the directory specified by lpDirectory.
*!*		  ; && {en} open: Opens the item specified by the lpFile parameter. The item can be a file or folder.
*!*		  ; && {en} print: Prints the file specified by lpFile. If lpFile is not a document file, the function fails.
*!*		  ; && {en} NULL: The default verb is used, if available. If not, the "open" verb is used. If neither verb is available, the system uses the first verb listed in the registry.
*!*		, string cFileName; && {en} file or object on which to execute the specified verb
*!*		, string cParameters; && {en} parameters to be passed to the application
*!*		, string cDirectory; && {en} default (working) directory for the action. If this value is NULL, the current working directory is used
*!*		, integer nShowWindow && {en} how an application is to be displayed when it is opened (see abDev.h)
#DEFINE SW_HIDE 0
#DEFINE SW_SHOWNORMAL 1
#DEFINE SW_SHOWMINIMIZED 2
#DEFINE SW_SHOWMAXIMIZED 3
#DEFINE SW_SHOWNOACTIVATE 4
#DEFINE SW_SHOW 5
#DEFINE SW_MINIMIZE 6
#DEFINE SW_SHOWMINNOACTIVE 7
#DEFINE SW_SHOWNA 8
#DEFINE SW_RESTORE 9
#DEFINE SW_SHOWDEFAULT 10


&& {fr} contribution Gregory Adam : http://www.atoutfox.org/nntp.asp?ID=0000015802
&& declare short GetKeyState in User32 integer vKey
#define VK_LSHIFT	(0xA0) && {en} Left SHIFT key
#define VK_RSHIFT	(0xA1) && {en} Right SHIFT key
#define VK_LBUTTON	(0x01) && {en} Left mouse button
#define VK_RBUTTON	(0x02) && {en} Right mouse button
#define VK_LCONTROL	(0xA2) && {en} Left CONTROL key
#define VK_RCONTROL	(0xA3) && {en} Right CONTROL key

#define VK_LSHIFT_DOWN	bitTest(GetKeyState(VK_LSHIFT), 31)
#define VK_RSHIFT_DOWN	bitTest(GetKeyState(VK_RSHIFT), 31)
#define VK_SHIFT_DOWN	VK_LSHIFT_DOWN or VK_RSHIFT_DOWN
