* {fr} Constantes de développement
#define VFPOPCARS	'!$+-/*%^<>=#' && {fr} opérateurs
#define VFPSEPCARS	' .,()[]!' + Chr(9) && {fr} Caractères de séparation (avec tabulateur)
#define VFPOPSEPCARS	VFPOPCARS + VFPSEPCARS
#define VFPOPSEPCARSLIST	"'!','$','+','-','/','*','%','^','<','>','=','#',' ',',','(',')','[',']'"

#define VFP_VAR_SIZE_MAX	16777184

* {en} Tools Folders
#define DOS_FFC			Home(1) + 'FFC\'
#define DOS_TOOLS			Home(1) + 'Tools\'
#define DOS_AB			DOS_TOOLS + 'AB\'
#define DOS_ABGRAPHICS  DOS_AB + 'Graphics\'
#define DOS_AB_TEMP		DOS_AB + '_Temp\'
#define DOS_AC			DOS_AB + 'AC\'
#define DOS_AT			DOS_AB + 'AT\'
#define DOS_AU			DOS_AB + 'AU\'
	#define DOS_FOXCHARTS			DOS_AU + 'FoxCharts\Source\'
#define DOS_AW			DOS_AB + 'AW\'
#define DOS_AZ			DOS_AB + 'AZ\'

#define DOS_AWAPP		DOS_AW + 'App\'
#define DOS_AWSCRIPTS	DOS_AW + 'Scripts\'
#define DOS_AW_SOURCE	DOS_AW + '_Source\'

#define DOS_AWSAMPLES	DOS_AW + 'Samples\'
	#define DOS_AWSAMPLES_DATA	 DOS_AWSAMPLES + '_Data\'
	#define DOS_AWSAMPLES_FIC_CLASS	 DOS_AWSAMPLES + 'FIC\classe\'

	#define DOS_AWSAMPLES_TASTRADE DOS_AWSAMPLES + 'Tastrade\'
	#define DOS_AWSAMPLES_TASTRADE_ORIGINAL	DOS_AWSAMPLES_TASTRADE + '_Original\'
	#define DOS_AWSAMPLES_TASTRADE_ADAPTED	DOS_AWSAMPLES_TASTRADE + 'Adapted\'
	#define DOS_AWSAMPLES_TASTRADE_ADAPTED_PROG	DOS_AWSAMPLES_TASTRADE_ADAPTED + 'progs\'
	#define DOS_AWSAMPLES_FIC_TUTO	DOS_AWSAMPLES + 'FIC\FICtuto\'
	#define DOS_AWSAMPLES_FIC_TUTO_PROG 	DOS_AWSAMPLES_FIC_TUTO + 'progs\'
	#define DOS_AWSAMPLES_FIC_TUTO_FORM 	DOS_AWSAMPLES_FIC_TUTO + 'progs\forms\'
	#define DOS_AWSAMPLES_FIC_DEMO	DOS_AWSAMPLES + 'FIC\FICdemo\'
	#define DOS_AWSAMPLES_FIC_DEMO_PROG	DOS_AWSAMPLES_FIC_DEMO + 'progs\'

#define DOS_AWSAMPLES_	DOS_AW + 'Samples_\' && GLS

#define DOS_WC			DOS_AB + 'WC\'
#define DOS_WC_CLASSES	DOS_WC + 'Classes\'

#define DOS_USER_APPDATA_AB			home(7) + 'AB\'
#define DOS_USER_APPDATA_AW			DOS_USER_APPDATA_AB + 'AW\'

* {fr} Dossiers à exclure des traitements batch
#define FOLDERS_EXCLUDE	'save,_save,old,_old,bak,back,_back,tmp,_tmp,temp,_temp,ancien,_ancien,anciens,_anciens,sauve,_sauve';
	 + ',src,source,_source,script,scripts,image,images,screenshots,doc,docs,test,_gsData_,.git,test,tests'

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
#define SW_HIDE 0
#define SW_SHOWNORMAL 1
#define SW_SHOWMINIMIZED 2
#define SW_SHOWMAXIMIZED 3
#define SW_SHOWNOACTIVATE 4
#define SW_SHOW 5
#define SW_MINIMIZE 6
#define SW_SHOWMINNOACTIVE 7
#define SW_SHOWNA 8
#define SW_RESTORE 9
#define SW_SHOWDEFAULT 10


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
