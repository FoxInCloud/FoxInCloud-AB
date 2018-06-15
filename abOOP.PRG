* {fr} abOOP.prg
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
function lContIn && {fr} Un objet se trouve dans un conteneur d'une classe donnée
lparameters ;
  toObject; && {fr} Objet VFP
, tcContClass; && {fr} Classe(s) contenante
, toCont; && @ {fr} Classe(s) contenante

toCont = oContIn(m.toObject, m.tcContClass)

return !isnull(m.toCont)

* ------------------------------------
procedure lContIn_Test && {fr} test unitaire de lContIn()

local loTest as abUnitTest of abDev.prg;
, loCont as container

loTest = newobject('abUnitTest', 'abDev.prg')

loCont = createobject('Container')
with loCont as container
	.addobject('oOpg', 'OptionGroup')
	.oOpg.buttoncount = 2
endwith

m.loTest.Test(.t., m.loCont.oOpg.buttons(2), 'Container')

return m.loTest.Result()

* ========================================
function oContIn && {fr} Conteneur d'une classe donnée où se trouve un objet
lparameters ;
  toObject; && {fr} Objet VFP
, tcContClass && {fr} Classe(s) contenante

local loResult as container, loParent as container

loResult = .null.

if vartype(m.toObject) == 'O' and vartype(m.tcContClass) == 'C'

	loParent = m.toObject
	do while .t.

		if loClass(m.loParent, m.tcContClass)
			loResult = m.loParent
			exit

		else

			if PEMstatus(m.loParent, 'Parent', 5) and type('m.loParent.Parent') == 'O' && {fr} Vartype(m.loParent.Parent) ne marche pas [Parent n'est pas un objet]
				loParent = m.loParent.parent
			else
				exit
			endif
		endif
	enddo
endif

return m.loResult

* ------------------------------------
procedure oContIn_Test && {fr} test unitaire de oContIn()

local loTest as abUnitTest of abDev.prg;
, loCont as container

loTest = newobject('abUnitTest', 'abDev.prg')

loCont = createobject('Container')
with loCont as container
	.addobject('oOpg', 'OptionGroup')
	.oOpg.buttoncount = 2
endwith

m.loTest.Test(m.loCont, m.loCont, 'Container')
m.loTest.Test(m.loCont, m.loCont.oOpg.buttons(2), 'Container')

return m.loTest.Result()

* ========================================
function oFormIn && {fr} Forme où se trouve un objet
lparameters toObject && {fr} Objet VFP

return oContIn(m.toObject, 'Form')

* ========================================
function lFormIn && {fr} Un objet est placé dans une forme
lparameters toObject && {fr} Objet VFP

return not isnull(oFormIn(m.toObject))

* ========================================
function cListItems as String && {fr} Listbox|Combobox.List[] > liste délimitée
lparameters toList as listbox && {fr} Objet Listbox ou ComboBox

local aa[1] as String

return Iif(aListItems(@m.aa, m.toList) > 0;
	, cListOfArray(@m.aa, '|', -1,.T.,.T.,,,,.T.);
	, '';
	)
endfunc

* ========================================
function aListItems && {fr} Listbox|Combobox.List[] > array
lparameters ;
  taItems; && @ {fr} Éléments de .List[]
, toList as listbox && {fr} Objet Listbox ou ComboBox

external array taItems

local lnResult as Integer; && {fr} nombre d'éléments
, llResult;
, lnCol;
, liCol;
, liRow;

&& modify command c:\test\test\Listbox_combobox.list.prg
&& {fr} pour supporter .Sorted, soit sauver dans l'ordre de .itemID, soit sauver les ID
&& ".Sorted is only available if .RowSourceType is set to 0 (None) or 1 (Value)."

lnResult = .null.

llResult = aClear(@m.taItems)
assert m.llResult message cAssertMsg(textmerge([First parameter should contain a reference to an array: <<cLitteral(m.taItems)>>]))
if m.llResult

	llResult = loClass(m.toList, 'Listbox, Combobox')
	assert m.llResult message cAssertMsg(textmerge([Second parameter should contain a reference to a Listbox or ComboBox object: <<cLitteral(m.toList)>>]))
	if m.llResult

		with m.toList as listbox

			lnResult = .listcount
			if m.lnResult > 0

				lnCol = max(evl(.ColumnCount, 1), .boundcolumn)
				dimension taItems[m.lnResult, m.lnCol]

				for liRow = 1 to m.lnResult

					if .t.;
					 and m.liRow = m.lnResult;
					 and empty(.value);
					 and empty(.listitem[m.liRow, 1]);
					 and empty(.listitem[m.liRow, .BoundColumn])

						&& {fr} c'est un élément vide ajouté par VFP quand .Value n'est pas dans .List
					 	lnResult = m.lnResult - 1

					else
						for liCol = 1 to m.lnCol
							taItems[m.liRow, m.liCol] = .list[m.liRow, m.liCol]
						endfor
					endif
				endfor
			endif
		endwith
	endif
endif

return m.lnResult
endfunc

* ------------------------------------
procedure aListItems_Test && {fr} test unitaire de aListItems()

local loTest as abUnitTest of abDev.prg;
, loList as listbox;
, liItem, lcItem;
, laItem[1]

loTest = newobject('abUnitTest', 'abDev.prg')
loList = createobject('Listbox')

with m.loList as listbox
	.ColumnCount = 2
	.boundcolumn = 2
	.clear
	for liItem = 1 to 100
		lcItem = ltrim(str(m.liItem))
		.additem(m.lcItem)
		.list[.NewIndex, 2] = m.lcItem + '_'
	endfor
	.value = '' && {fr} Valeur en dehors de la liste
endwith

loTest.Test(100, @m.laItem, m.loList) && 100 x 2 = .2 ms
loTest.assert(100, m.loList.listcount)

with m.loList as listbox
	.clear()
	.additem('101')
	.list[.NewIndex, 2] = '102'
	.additem('103')
	.list[.NewIndex, 2] = '104'
	.value = '104'
endwith

loTest.Test(2, @m.laItem, m.loList)
loTest.assert(["101","102","103","104"], cListOfArray(@m.laItem,,-1,.t.))

return loTest.Result()

* ========================================
function aItemsList && {en} Sets Listbox|Combobox.List[] from Array 
lparameters ;
  taItems; && @ {fr} Éléments de .List[]
, toList as listbox; && {fr} Objet Listbox ou ComboBox

external array taItems

* modify command c:\test\test\Listbox_combobox.list.prg

local lnResult as integer; && {fr} nombre d'éléments
, llResult as Boolean;
, loForm as form;
, llDS as Boolean, liDS as integer;
, llValue, luValue;
, lcAlias as string, lcField as string, llFldState as Boolean, lnFldState as integer;
, lnCol as integer, liCol as integer;
, liRow as integer;
, lcElt as string;

lnResult = .null.

llResult = ga_Type_IsArray(@m.taItems)
assert m.llResult message cAssertMsg(textmerge([First parameter should contain a reference to an array: <<cLitteral(m.taItems)>>]))
if m.llResult

	llResult = loClass(m.toList, 'Listbox, Combobox')
	assert m.llResult message cAssertMsg(textmerge([Second parameter should contain a reference to a Listbox or ComboBox object: <<cLitteral(m.toList)>>]))
	if m.llResult

		loForm = oFormIn(m.toList)
		llDS = loClass(m.loForm, 'Form')
		if m.llDS
			liDS = set("Datasession")
			set datasession to m.loForm.datasessionid
		endif

		with m.toList as listbox

			lnResult = alen(m.taItems, 1)

			llValue = Type('.value') # 'U'
			if m.llValue
				luValue = .value
			endif
			if m.llDS
				lcField = JustField(.controlsource, @m.lcAlias)
				llFldState = used(m.lcAlias) and cursorgetprop("Buffering", m.lcAlias) > 1
				if m.llFldState
					lnFldState = getfldstate(m.lcField, m.lcAlias)
					llFldState = vartype(m.lnFldState) == 'N'
				endif
			endif

*			.rowsource = '' && 2015-12-07 -- thn -- work around Error 1152 (Cannot access the selected table) -- useless and dangerous - breaks .rowsourcetype = 3 && {fr} SQL-select
			.rowsourcetype = 0 && {en} None
			if .ListCount > 0
				.clear
			endif
*			.ColumnCount = alen(m.taItems, 2) && {en} For a ComboBox or Listbox control, if you set ColumnCount to 0, the first column is displayed based on the RowSource property or on the items added with the AddItem method
			lnCol = alen(m.taItems, 2) && 2016-09-21 thn -- {FiC V 2.22.0-beta.7} {en} do not change .ColumnCount

			do case
			case laEmpty(@m.taItems)
				lnResult = 0

			case m.lnCol <= 1
				for each lcElt in m.taItems
					.additem(transform(m.lcElt)) && {fr} par sécurité
				endfor

			otherwise
				for liRow = 1 to alen(m.taItems, 1)
					.additem(transform(m.taItems[m.liRow, 1]))
					for liCol = 2 to m.lnCol
						.list[.NewIndex, m.liCol] = transform(m.taItems[m.liRow, m.liCol]) && {fr} The AddItem method always inserts a new row into a multicolumn ComboBox or Listbox. After a row has been inserted, columns in that row should be populated using the .List(.NewIndex, nColumn) syntax
					endfor
				endfor
			endcase

			if m.llValue
				.value = m.luValue
			endif
			if m.llFldState
				setfldstate(m.lcField, m.lnFldState, m.lcAlias)
			endif
		endwith

		if m.llDS
			set datasession to m.liDS
		endif
	endif
endif

return m.lnResult
endfunc

* ------------------------------------
procedure aItemsList_Test && {fr} test unitaire de aItemsList()

local loTest as abUnitTest of abDev.prg;
, loList as listbox;
, liRow, lcItem;
, liCol;
, laItem[100,2]

loTest = newobject('abUnitTest', 'abDev.prg')
loList = createobject('Listbox')
with m.loList as listbox
	.rowsourcetype = 5 && {fr} before updating .RowSource, program must reset .RowSourceType to the proper value
	.ColumnCount = 5
	.boundcolumn = 2
endwith

for liRow = 1 to alen(laItem, 1)
	for liCol = 1 to alen(laItem, 2)
		laItem[m.liRow, m.liCol] = padr(c2Words(m.liRow, '_', m.liCol), 7)
	endfor
endfor
loTest.Test(100, @m.laItem, m.loList) && 100 x 2 x 7 = 1 ms en IDE
loTest.assert(100, m.loList.listcount)
loTest.assert('1_2', trim(m.loList.list[1,2]))
loTest.assert('10_2', trim(m.loList.list[10,2]))

for liRow = 1 to alen(laItem, 1)
	for liCol = 1 to alen(laItem, 2)
		laItem[m.liRow, m.liCol] = replicate(laItem[m.liRow, m.liCol], 10) && {fr} Replicate() pour tester si la longueur de la chaîne influence le résultat
	endfor
endfor
loTest.Test(100, @m.laItem, m.loList) && 100 x 2 x 70 = 2 ms en IDE
loTest.assert(100, m.loList.listcount)

return loTest.Result()

* ========================================
function loCont && {fr} Un objet peut en contenir d'autres
lparameters toCont as container && {fr} Objet supposé conteneur

return .t.;
	and lMethod(m.toCont, 'AddObject'); && .AddObject() n'existe que dans les conteneurs ...
	and !PEMstatus(m.toCont, 'AddObject', 4); && {fr} not user defined, donc native ...
	and !m.toCont.baseclass == 'Olecontrol' && {fr} vu le 23/10/13 avec les contrôles DBItech

* ========================================
function nObjectsCont && {fr} Nombre d'objets contenus dans un autre
lparameters toCont && {fr} Objet supposé contenant

* {fr} Si l'objet peut en contenir d'autres,
if loCont(m.toCont)

	local lnResult
	with m.toCont as container

		lnResult = .baseclass
		lnResult = ICase(;
			m.lnResult == 'Pageframe',;
				.pageCount,;
			m.lnResult == 'Grid',;
				.columnCount,;
			inlist(m.lnResult, 'Optiongroup', 'Commandgroup'),;
				.buttonCount,;
			m.lnResult == 'Formset',;
				.formCount,;
				.controlCount;
			)
	endwith
	return m.lnResult
else
	return 0
endif
endfunc

* ========================================
function oObjectCont && {fr} Objet contenu dans un autre d'après son index
lparameters ;
  toCont; && {fr} Objet supposé contenant
, tiObject; && {fr} N° d'objet dans la collection

local loResult as Object; && {fr} Objet contenu
, llResult as Boolean;
, loException as Exception;
, loForm as awFrm of aw;
, liDS as Integer;
, cAliasUsed, nAliasUsed;

loResult = .null.
llResult = Vartype(m.tiObject) == 'N' and Between(m.tiObject, 1, nObjectsCont(m.toCont))
assert m.llResult message cAssertMsg(textmerge("Invalid member number <<m.tiObject>> in <<cLitteral(m.toCont)>>"))
if m.llResult

	with m.toCont as Form

		try

			loResult = .baseclass
			loResult = ICase(;
				m.loResult == 'Grid',;
					Iif(Type('.columns(1)') == 'O', .columns(m.tiObject), .null.),; && 2017-08-22 thn -- {FiC V 2.25.0-beta.8} {en} Type() added
				m.loResult == 'Pageframe',;
					.pages(m.tiObject),; && 2017-08-22 thn -- {FiC V 2.25.0-beta.8} {en} Iif(Type('.pages(1)') == 'O', .pages(m.tiObject), .null.)
				inlist(m.loResult, 'Optiongroup', 'Commandgroup'),;
					.buttons(m.tiObject),; && 2017-08-22 thn -- {FiC V 2.25.0-beta.8} {en} Iif(Type('.buttons(1)') == 'O', .buttons(m.tiObject), .null.)
				m.loResult == 'Formset',;
					.forms(m.tiObject),; && 2017-08-22 thn -- {FiC V 2.25.0-beta.8} {en} Iif(Type('.forms(1)') == 'O', .forms(m.tiObject), .null.)
					.controls(m.tiObject); && 2017-08-22 thn -- {FiC V 2.25.0-beta.8} {en} Iif(Type('.controls(1)') == 'O', .controls(m.tiObject), .null.)
				)

		catch to loException && 2016-03-14 thn -- {en} {FiC V 2.21.0-beta.10} track the "columns is not an object" Error #1924 && Visual FoxPro disregards any THROW statements appearing in a CATCH WHEN lExpression clause.

			if loClass(m.toCont, 'awGrd') && of aw.vcx

				loForm = oFormIn(m.toCont)
				if Vartype(m.loForm) == 'O'
					liDS = Set("Datasession")
					set datasession to m.loForm.DataSessionID
				endif
				
				cAliasUsed = cAliasesUsed(@m.nAliasUsed)
				
				text to loException.userValue textmerge noshow flags 1 pretext 3
			 		.Name: <<.Name>>
			 		.wcID: <<.wcID>>
			 		.RecordSource: <<cL(.recordSource)>> (used: <<used(.recordSource)>>, <<m.nAliasUsed>> alias<<Iif(m.nAliasUsed > 1, 'es', '')>> used in dataSession #<<Set("Datasession")>>: <<m.cAliasUsed>>)
			 		columnID/.ColumnCount: <<m.tiObject>> / <<.ColumnCount>>
			 		.wcRScursor: <<cL(.wcRScursor)>>
			 		.wcPKexpr: <<cL(.wcPKexpr)>>
			 		call stack: <<cCallingModules()>>
				endtext
				
				if !Empty(m.liDS)
					set datasession to m.liDS
				endif
				
				#if .F. && 2016-03-25 thn -- {fr} {FiC V 2.21.0-beta.11}
					L'erreur columns est due à un bug/instabilité dans la vue distante : par ex.  elle est dans aUsed() mais pas Used()
					Je ne sais pas ce qui produit cette instabilité car impossible de reproduire en IDE.
					Ma seule piste pour l'instant est 2 requery() simultanés de la même vue pour le même utilisateur par 2 serveurs ; restent des points inexpliqués :
					- pourquoi dans cette version et pas dans la précédente ? Ce genre de requery() simultanés était déjà possible
					- pourquoi pour le même utilisateur et pas pour des utilisateurs différents (ce qui se produit en permanence)
					Contournement comme suit : pendant une requête AJAX,
					- désactiver F5
					- envoyer un avertissement - le temps que l'utilisateur réponde le risque devrait avoir disparu
				#endif
				
				assert .F. message cAssertMsg(cException(m.loException))
			endif

			* ---------------
			THROW loException
			* ---------------
		 
		endtry
	endwith
endif

return m.loResult
endfunc

* ========================================
function cSys1272thisForm && {fr} Adresse d'un objet dans thisForm
lparameters tuObject && {fr} Objet à analyser ou son adresse

local lcType, lnPeriod, lcResult, llResult

lcResult = ''
lcType = vartype(m.tuObject)
llResult = m.lcType $ 'CO'
assert m.llResult message cAssertMsg(textmerge("Invalid parameter : <<cLitteral(m.tuObject)>>"))
if m.llResult

	llResult = m.lcType == 'C' or lFormIn(m.tuObject)
	assert m.llResult message cAssertMsg(textmerge("Object should be a form or contained in a form : <<cLitteral(m.tuObject)>>"))
	if m.llResult

		lcResult = iif(m.lcType == 'O', sys(1272, m.tuObject), m.tuObject)

		lnPeriod = atc('.', m.lcResult)
		lnPeriod = iif(m.lnPeriod = 0, len(m.lcResult), m.lnPeriod) + 1 && 0 si forme elle-même

		lcResult = c2Words('ThisForm', '.', substr(m.lcResult, m.lnPeriod))
	endif
endif

return m.lcResult

* ========================================
function oPageIn && {fr} Page d'un pageFrame où se trouve un objet
lparameters ;
  toControl as control
local loResult && {fr} Page où se trouve un objet
loResult = .null.

if vartype(m.toControl) == 'O'

	* {fr} Tabuler les parents de l'objet jusqu'au formulaire
	local array laParents[1]
	local lnParents, loParent as object
	lnParents = 0
	loParent = m.toControl
	do while .t.

		loParent = m.loParent.parent
		lnParents = m.lnParents + 1
		dimension laParents[m.lnParents]
		laParents[m.lnParents] = m.loParent

		if lower(m.loParent.baseclass) == 'form'
			exit
		endif
	enddo

	* {fr} Si au moins trois parents et l'avant-dernier parent est un pageframe
	if m.lnParents > 2
		loParent = laParents[m.lnParents-1]
		if proper(m.loParent.baseclass) == 'Pageframe'

			* {fr} La page cherchée est son fils
			loResult = laParents[m.lnParents-2]
		endif
	endif
endif

return m.loResult

* ========================================
function aoSiblings && {fr} Frères d'un objet dans un conteneur [basés sur une classe]
lparameters ;
  taSiblings; && @ {fr} Frères d'un objet dans un conteneur
, toObject; && {fr} Objet
, tcClass; && [toutes] {fr} Classe
, tlTabIndex && [.F.] {fr} tabuler seulement les objets ayant la propriété TabIndex, classer par TabIndex croissant
external array taSiblings

local lnResult as Integer; && {fr} Nombre de frères trouvés
, llResult;
, loParent;
, liSibling, loSibling;

lnResult = 0

* {fr} Si les paramètres sont corrects
llResult = type('taSiblings', 1) == 'A' and vartype(m.toObject) == 'O'
assert m.llResult message cAssertMsg(textmerge("At least one parameter is invalid: <<cLitteral(m.taSiblings)>>, <<cLitteral(m.toObject)>>"))
if m.llResult

* {fr} Si l'objet est dans un conteneur
	loParent = m.toObject.parent
	llResult = loCont(m.loParent)
	assert m.llResult message cAssertMsg(textmerge("Object <<cLitteral(m.toObject)>> should be in a containing object such as form, container, etc."))
	if m.llResult

		tlTabIndex = lTrue(m.tlTabIndex)

		* {fr} Pour chaque objet frère
		for liSibling = 1 to nObjectsCont(m.loParent)
			loSibling = oObjectCont(m.loParent, m.liSibling) && modify command abOOP

			if not m.loSibling == m.toObject;
			 and (empty(m.tcClass) or loClass(m.loSibling, m.tcClass));
			 and (not m.tlTabIndex or lProperty(m.loSibling, 'TabIndex'))

				* {fr} Ajouter au résultat
				lnResult = m.lnResult + 1
				if m.tlTabIndex
					dimension taSiblings[m.lnResult, 2]
					taSiblings[m.lnResult, 1] = m.loSibling
					taSiblings[m.lnResult, 2] = m.loSibling.tabindex
				else
					dimension taSiblings[m.lnResult]
					taSiblings[m.lnResult] = m.loSibling
				endif
			endif
		endfor

		if m.tlTabIndex and m.lnResult > 0
			asort(taSiblings, 2)
		endif
	endif

	if m.lnResult = 0
		aClear(@m.taSiblings)
	endif
endif

return m.lnResult

* ========================================
function oSibling && {fr} Frère d'un objet dans un conteneur selon une classe
lparameters ;
  toObject; && {fr} Objet
, tcClass && {fr} Classe

local laSibling[1]

* {fr} Si l'objet a un frère et un seul selon la classe

return iif(aoSiblings(@m.laSibling, m.toObject, m.tcClass) = 1;
	, laSibling[1];
	, .null.;
	)

* ========================================
function oSiblingTabIndex && {fr} Frère d'un object dans un conteneur selon un différentiel de tabindex
lparameters ;
  toObject; && {fr} Objet
, tnTabIndex && {fr} Différentiel de TabIndex

if empty(m.tnTabIndex)
	return m.toObject
else

	local laSibling[1], lnSibling, liSibling, loSibling, loResult
	lnSibling = aoSiblings(@m.laSibling, m.toObject,, .t.)
	if m.lnSibling > 0

		tnTabIndex = m.toObject.tabindex + m.tnTabIndex
		loResult = .null.
		for liSibling = 1 to m.lnSibling

			loSibling = laSibling[m.liSibling, 1]
			if laSibling[m.liSibling, 2] = m.tnTabIndex

				if m.loSibling.enabled
					loResult = m.loSibling
					exit
				else
					tnTabIndex = m.tnTabIndex + 1
				endif
			endif
		endfor

		return m.loResult

	else
		return .null.
	endif
endif

* ========================================
function lClass && {fr} Une définition de classe existe
lparameters ;
  tcClass; && {fr} Nom de la classe
, toClass; && @ [.NULL.] {fr} Classe instanciée en retour
, tcClassLib; && [''] {fr} Classothèque
, tiResult; && @ {fr} Si la classe ne peut être instanciée, n° de l'erreur
, tcResult && @ {fr} Si la classe ne peut être instanciée, raison de l'échec

toClass = .null.
tcClassLib = evl(m.tcClassLib, '')
tcClassLib = iif(lower(justext(m.tcClassLib)) == 'prg', forceext(m.tcClassLib, 'fxp'), m.tcClassLib) && {fr} When possible, specify the compiled program name (.fxp) when a class is stored in a program file (.prg)
tiResult = 0

local llResult as Boolean;
, abOnError as abOn of abDev.prg;
, loSets as abSetsMaintain of abDev.prg;
, loException as exception;
, loForm as form;

llResult = ga_Type_IsChar(m.tcClass, .t.)
if m.llResult

*assert !Lower(m.tcClass) == 'baseform' && 4 Feb 2014

	tcClass = alltrim(m.tcClass)
	loSets = NewObject('abSetsMaintain', 'abDev.prg';
		, .null.; && && [.null.] {en} type of SETs - .null.: all, .T.: scoped to the dataSession, .F.: global (not scoped to the dataSession)
		, !wlAutomation(); && tlProcClass [.F.] {en} also save Set("Procedure") & Set("Classlib")
		)
	abOnError = NewObject('abOn', 'abDev.prg', '', 'error', '') && 2017-02-15 thn -- {FiC V 2.24.0-beta.6} {fr} 

	try
		try
			toClass = iif(file(m.tcClassLib); && /!\ assez long pour les grilles avec classMember (plusieurs secondes)
				, newobject(m.tcClass, m.tcClassLib, 0);
				, createobject(m.tcClass);
				)
* {fr} toClass = NewObject(m.tcClass, m.tcClassLib, 0) && {fr} passing 0 to the cInApplication parameter allows you to create an instance of a class without raising initialization code (such as code in the Init, Load, Activate, and BeforeOpenTables events)
			&& {fr} THIS FEATURE IS NOT SUPPORTED IN RUNTIME APPLICATIONS
			&& {fr} Une page peut être instanciée en dehors d'un pageFrame
		catch to loException when inlist(m.loException.errorno;
				, 1435; && {fr} Object class is invalid for this container (erreur dans la documentation)
				, 1744; && {fr} Object class is invalid for this container
				, 1736; && {fr} Erreur d'instanciation
				, 1938; && {fr} Objet non contenu dans un Formulaire
				)
			try
				loForm = createobject('Form')
				if file(m.tcClassLib)
					loForm.newobject('lClass', m.tcClass, m.tcClassLib) && {fr} dans VFP 10, il faudrait que la Méthode newObject supporte (,,0)
				else
					loForm.addobject('lClass', m.tcClass)
				endif
				loForm.setall('Visible', .t.)
				toClass = loForm.lClass
			catch to loException
				throw m.loException
			endtry
		catch to loException when m.loException.errorno = 1733 && {fr} The class definition specified in a CREATEOBJECT( ) function cannot be located.
			llResult = .f.
		endtry
	catch to loException
		llResult = .f.
	endtry

	tiResult = icase(m.llResult, 0, m.loException.errorno = 2071, m.loException.uservalue.errorno, m.loException.errorno)
	tcResult = iif(m.llResult, '', cException(iif(m.loException.errorno = 2071, m.loException.uservalue, m.loException)))

else
	tcResult = textmerge(icase(;
		cLangUser() = 'fr', [<<cLitteral(m.tcClass)>> est un nom de classe invalide],; && copy-paste this line to add another language support
												[<<cLitteral(m.tcClass)>> is an invalid class name]; && default: English
	))
endif

return m.llResult
endfunc

* ========================================
function cInheritance && {fr} Héritage d'une méthode d'un objet
lparameters ;
  toObject; && {fr} Objet
, tcPEM;
, lObjAdd; && [.F.] {fr} ajouter le nom de l'objet lui-même

return Iif(Vartype(m.toObject) == 'O' and ga_Type_IsChar(m.tcPEM, .T.) and PEMstatus(m.toObject, m.tcPEM, 5);
	, cClasses(m.toObject, ', ', m.tcPEM, m.lObjAdd);
	, .null.;
	)
endfunc

* ========================================
function cClasses && {fr} Classes d'un objet depuis sa classe de base (uppercase)
lparameters ;
  toObject; && {fr} Objet
, tcSep; && [' '] {fr} séparateur
, tcPEM; && [''] {fr} PEM à ajouter aux noms de classe
, lObjAdd; && [.F.] {fr} ajouter le nom de l'objet lui-même

local aa[1], lPEM

lPEM = ga_Type_IsChar(m.tcPEM, .T.)

return ICase(;
	! Vartype(m.toObject) == 'O',;
		.null.,;
	.T.;
	 and aClass(aa, m.toObject) > 0; && aClass() returns the number of class names in the array. ACLASS( ) returns 0 if the array cannot be created.
 	 and (m.lPEM or aReverse(@m.aa) > 0);
 	 and (!lTrue(m.lObjAdd) or aAdd(@m.aa, Upper(m.toObject.Name)) > 0);
 	 and (!m.lPEM or aMap_Concat(@m.aa, '.' + m.tcPEM) > 0),;
			Trim(cListOfArray(;
			 @m.aa;
			, Iif(vartype(m.tcSep) == 'C' and len(m.tcSep) > 0;
				, m.tcSep;
				, space(1);
				);
			,,,,,;
			,.t.; && m.tlDistinct
			)),;
		'';
		)

* ========================================
function loClasses && {fr} Un objet hérite d'au moins une classe dans une liste (dépréciée par loClass())
lparameters toObject, tcClasses && {fr} Objet, Classe(s)
return loClass(m.toObject, m.tcClasses) && {fr} Rétro compatibilité
endfunc

* ========================================
function loEmpty && {fr} Un objet est de la classe Empty
lparameters toObject && {fr} Objet supposé
return .t.;
	and vartype(m.toObject) == 'O';
	and not lProperty(m.toObject, 'BaseClass');
	and empty(comclassinfo(m.toObject))
endfunc

* ========================================
function loClass && {fr} Un objet hérite d'au moins une classe dans une liste
lparameters ;
  toObject; && {fr} Objet supposé
, tcClasses && {fr} Classe(s) à satisfaire (ou) -class: ne doit pas appartenir à cette classe

local succIncl, succExcl;
, loClass[1], laClass[1], lcClass

if .t.;
 and Vartype(m.toObject) == 'O';
 and Vartype(m.tcClasses) == 'C';
 and AClass(loClass, m.toObject) > 0;
 and ALines(laClass, m.tcClasses, 5, ',', ';') > 0 && 1+4

	succExcl = .T.
	succIncl = .null.
	for each lcClass in laClass
		if leftc(m.lcClass, 1) == '-'
			succExcl = m.succExcl and Empty(ascan(loClass, ltrim(m.lcClass, '-'), 1, -1, 1, 7)) && 1+2+4 = case insensitive, exact on
		else
			succIncl = Nvl(m.succIncl, .F.) or !Empty(ascan(loClass, m.lcClass, 1, -1, 1, 7))
		endif
	endfor
endif

return m.succExcl and Nvl(m.succIncl, .T.)
endfunc

* ------------------------------------------
function loClass_test

&& .1 ms

local loTest as abUnitTest of abDev.prg

loTest = newobject('abUnitTest', 'abDev.prg')

loTest.Test(.t., newobject('awlst', 'aw' + '.vcx'), 'Listbox') && {fr} évite d'embarquer aw.vcx dans un projet ab
loTest.Test(.t., newobject('awfrm', 'aw' + '.vcx'), 'form') && {fr} évite d'embarquer aw.vcx dans un projet ab
loTest.Test(.t., newobject('awfrm', 'aw' + '.vcx'), '-listbox,-textbox') && {fr} évite d'embarquer aw.vcx dans un projet ab
loTest.Test(.t., newobject('awfrm', 'aw' + '.vcx'), '-listbox,-textbox,awFrm') && {fr} évite d'embarquer aw.vcx dans un projet ab
loTest.Test(.f., newobject('awtxt', 'aw' + '.vcx'), 'awtxt,-listbox,-textbox,awFrm') && {fr} évite d'embarquer aw.vcx dans un projet ab

return loTest.Result()
endfunc

* ====================
function loBaseClass && {fr} Un objet VFP est de la classe de base spécifiée
lparameters ;
  toObject; && {fr} Référence à l'objet
, tcBaseClass && {fr} Classe de base

return ;
			vartype(m.toObject) == 'O' ;
	and	vartype(m.tcBaseClass) == 'C' ;
	and	PEMstatus(m.toObject, 'BaseClass', 5) ;
	and	lower(m.toObject.baseclass) == lower(alltrim(m.tcBaseClass))

* ====================
function oClassCont && {fr} Premier objet VFP [d'une classe] dans un conteneur
lparameters ;
  toCont; && {fr} Conteneur
, tcClasses; && [toutes] {fr} Classe(s) filtrante(s)
, tlRecurse; && [.T.] {fr} Récurser dans les conteneurs contenus
, tnConts && @ {fr} Nombre de niveaux de conteneurs

local array laObject[1]

return iif(aoClassCont(@m.laObject, m.toCont, m.tcClasses, m.tlRecurse, m.tnConts) > 0;
	, laObject[1];
	, .null.;
	)

* ====================
function HTMLtabIndex && {en} Collects .TabIndex for HTML
lparameters ;
  oTabIndex as GA_DICTIONARY_CLASS of abGA.prg; && @ {fr} key: Sys(1272, m.oCont) - value : Tabindex
, toForm as Form

local success as Boolean;
, iTabIndex as integer;

success = ga_Dictionary_object(@m.oTabIndex)
if m.success

	iTabIndex = 0
	success = HTMLtabIndex_(m.toForm, @m.oTabIndex, @m.iTabIndex)
endif

return m.success

*----------------------------------------------------
function HTMLtabIndex_ && {en} Collects .TabIndex for HTML - recursive
lparameters ;
  toCont as Container;
, oTabIndex as GA_DICTIONARY_CLASS of abGA.prg;
, iTabIndex as integer

local success as Boolean;
, aoCont[1];
, oCont as Textbox;
, iTabIndex_ as integer

success = .t.

if aoClassCont(@m.aoCont, m.toCont, .f.,,, .t.) > 0 and aColsDel(@m.aoCont, 2) > 0
	for each oCont in m.aoCont foxobject

		iTabIndex = m.iTabIndex + 1
		success = m.oTabIndex.add(sys(1272, m.oCont), m.iTabIndex)
		if m.success and loCont(m.oCont)

			iTabIndex_ = iif(m.oCont.baseclass == 'Page';
				, m.oTabIndex.item(sys(1272, m.oCont.parent));
				, m.iTabIndex;
				)
			success = HTMLtabIndex_(m.oCont, @m.oTabIndex, @m.iTabIndex_)
		endif
		if !m.success
			exit
		endif
	endfor
endif

assert m.success
return m.success

*----------------------------------------------------
procedure HTMLtabIndex_Test

local oTest as abUnitTest of abDev.prg;
, oForm as awFrm of aw.vcx;
, oTabIndex as GA_DICTIONARY_CLASS of abGA.prg;

oTest = newobject('abUnitTest', 'abDev.prg')

do form (addbs(DOS_AWSAMPLES) + 'fic\ficdemo\progs\forms\ecran_2') name oForm noshow
m.oTest.Test(.t., @m.oTabIndex, m.oForm)
*suspend
return m.oTest.Result()

* ====================
function aoClassCont && {fr} Objets VFP [d'une classe] dans un conteneur /!\ récursion descendante
lparameters ;
  taObjects; && @ {fr} Objets trouvés
, toCont; && {fr} Conteneur
, tcClasses; && [toutes] {fr} Classe(s) filtrante(s)
, tlRecurse; && [.T.] {fr} Récurser dans les conteneurs contenus
, tnConts; && @ [0|1] {fr} Nombre de niveaux de conteneurs
, tlTabIndex; && [.F.] {fr} tabuler seulement les objets ayant la propriété TabIndex et TabStop, classer par TabIndex croissant
, tlEnabled; && [.F.] {fr} tabuler seulement les objets ayant la propriété TabIndex et Enabled
, tlAdd && [.F.] {fr} Ajouter au tableau taObjects

external array taObjects
tnConts = iif(vartype(m.tnConts) == 'N' and m.tnConts > 0, m.tnConts, 0)
tlTabIndex = lTrue(m.tlTabIndex)
tlEnabled = lTrue(m.tlEnabled)

local lnResult as Integer; && {fr} Nombre d'objets trouvés
, llResult;
, llClass;
, liObject;
, loObject;

lnResult = 0

* {fr} Si Conteneur
llResult = loCont(m.toCont) && {fr} ASSERT nuisible à la récursion
if m.llResult
	tnConts = m.tnConts + 1

	* {fr} Si tableau
	llResult = type('taObjects', 1) == 'A'
	assert m.llResult message cAssertMsg(textmerge([le premier paramètre (<<cLitteral(@m.taObjects)>>) doit être un tableau]))
	if m.llResult

if Vartype(m.plRecurse) == 'U' and !lTrue(m.tlAdd)
	aClear(@m.taObjects)
	private plRecurse
	plRecurse = .T.
endif

		llClass = vartype(m.tcClasses) == 'C' and not empty(m.tcClasses)

		* {fr} Pour chaque objet contenu
		for liObject = 1 to nObjectsCont(m.toCont)

			loObject = oObjectCont(m.toCont, m.liObject) && modify command abOOP

			* {fr} Si l'objet est de la classe cherchée, ajouter au résultat
			lnResult = iif(!m.llClass or loClass(m.loObject, m.tcClasses);
				, aoAppend(@m.taObjects, m.loObject, m.tlTabIndex, m.tlEnabled);
				, m.lnResult;
				)

			* {fr} Si l'objet est un conteneur et récursion demandée, récurser dedans
			lnResult = iif(pcount() < 4 or !vartype(m.tlRecurse) == 'L' or m.tlRecurse;
				, max(m.lnResult, aoClassCont(@m.taObjects, m.loObject, m.tcClasses, .t., @m.tnConts, m.tlTabIndex, m.tlEnabled, m.tlAdd)); && {fr} aoClassCont() ne travaille que si l'objet est un conteneur
				, m.lnResult;
				)
		endfor
	endif
endif

if m.lnResult > 0 and m.tlTabIndex
	asort(taObjects, 2)
endif

return m.lnResult
endfunc

* ------------------------------------------
function aoClassCont_Test

local loTest as aoClassContTest of aboop.prg, loForm as form, laObject[1]

loTest = createobject('aoClassContTest')

loTest.formOpen(@m.loForm)

loTest.Test(54, @m.laObject, m.loForm) && {fr} toutes les classes

* {fr} aClear(@m.laObject) && {fr} pas de clear car additif
loTest.lSingleTest = .t. && {fr} additif, évite un C0005
loTest.Test(54+5, @m.laObject, m.loForm, 'CheckBox',,,,,.t.) && {fr} filtré, additif

&& {fr} garbage collection
aClear(@m.laObject)
m.loForm.release

return loTest.Result()

* ------------------------------
define class aoClassContTest as abUnitTest of abDev.prg
	procedure formOpen(toForm)
		do form (home() + "tools\ab\abmodule.scx") name m.toForm linked noshow
	enddefine

* ====================
function aoAppend && {fr} Ajoute un objet à un tableau d'objets
lparameters ;
  taObjects; && @ {fr} Objets
, toObject; && {fr} Objet
, tlTabIndex; && [.F.] {fr} tabuler seulement les objets ayant la propriété TabIndex et TabStop
, tlEnabled && [.F.] {fr} tabuler seulement les objets ayant la propriété TabIndex et Enabled
external array taObjects

local lnResult; && {fr} Nombre d'objets
, llResult;
, lPage as Boolean;
, iTabIndex;
, iParent;
, oParent

llResult = type('taObjects', 1) == 'A' and vartype(m.toObject) == 'O'
assert m.llResult message cAssertMsg(textmerge("Invalid parameters"))
if m.llResult

	lnResult = iif(laEmpty(@m.taObjects), 0, alen(taObjects, 1))
	lPage = m.toObject.baseclass = 'Page'

	if .f.;
	 or !m.tlTabIndex;
	 or .t.;
		and (m.lPage or lProperty(m.toObject, 'TabIndex')); && {fr} Applies To: CheckBox | ComboBox | CommandButton | CommandGroup | Container Object | Control Object | EditBox | Form | Grid | Label | ListBox | OLE Bound Control | OLE Container Control | OptionButton | OptionGroup | PageFrame | _SCREEN | Spinner | TextBox
		and (m.lPage or lProperty(m.toObject, 'TabStop') and m.toObject.tabstop); && {fr} Does not apply to Page ! && {fr} Applies To: CheckBox | ComboBox | CommandButton | Container Object | Control Object | EditBox | Form | Grid | ListBox | OLE Bound Control | OLE Container Control | OptionButton | Page | PageFrame | _SCREEN | Spinner | TextBox
		and (!m.tlEnabled or m.toObject.enabled); && {fr} Applies To: CheckBox | Column | ComboBox | CommandButton | CommandGroup | Container | EditBox | Form | Grid | Image (Visual FoxPro) | Label (Visual FoxPro) | Line | ListBox | OLE Bound | OLE Container | OptionButton | OptionGroup | Page | PageFrame | _SCREEN | Shape | Spinner | TextBox | Timer | ToolBar
		and .t. && !loCont(m.toObject) && {fr} and (!lProperty(m.toObject, 'Visible') or m.toObject.Visible)

		lnResult = m.lnResult + 1

		if m.tlTabIndex
			oParent = m.toObject
			iParent = 0
			iTabIndex = 0
			do while vartype(m.oParent) == 'O'
				iTabIndex = m.oParent.tabindex * 20^m.iParent + m.iTabIndex
				oParent = iif(.t.;
				 and type('m.oParent.Parent') == 'O';
				 and lProperty(m.oParent.parent, 'TabIndex');
				 and (!lProperty(m.oParent.parent, 'TabStop') or m.oParent.parent.tabstop);
				 , m.oParent.parent;
				 , .null.;
				 )
				iParent = m.iParent + 1
			enddo
			dimension taObjects[m.lnResult, 2]
			taObjects[m.lnResult, 1] = m.toObject
			taObjects[m.lnResult, 2] = m.iTabIndex && {fr} Iif(m.lPage, 0, m.toObject.Tabindex)
		else
			dimension taObjects[m.lnResult]
			taObjects[m.lnResult] = m.toObject
		endif
	endif

	return m.lnResult
else
	return 0
endif

* ========================================
function cBaseClassOfParent && {fr} Classe de base du parent d'un objet s'il n'est pas orphelin
lparameters toObj

return iif(vartype(m.toObj) == 'O';
		, iif(type('m.toObj.Parent.BaseClass') == 'C';
			, m.toObj.parent.baseclass;
			, '';
			);
		, .null.;
		)

* ========================================
function coFontStyle && {fr} Style de police d'après les propriétés 'Font...' d'un objet
lparameters toObject && {fr} Objet

local llResult, lcResult
lcResult = ''

llResult = .t.;
 and vartype(m.toObject) == 'O';
 and PEMstatus(m.toObject, 'FontName', 5)
if m.llResult

	with m.toObject as label
		lcResult = ;
			iif(.fontbold, 'B', '');
			+ iif(.fontitalic, 'I', '');
			+ iif(.fontoutline, 'O', '');
			+ iif(.fontshadow, 'S', '');
			+ iif(.fontstrikethru, '-', '');
			+ iif(.fontunderline, 'U', '')
	endwith
endif

return m.lcResult

* ========================================
function oFontStyleSet && {fr} Règle les propriétés 'Font...' d'un objet d'après style de police
lparameters ;
  toObject; && {fr} Objet
, tcFontStyle && {fr} Style de police
local llResult && {fr} Mise à jour OK

llResult = vartype(m.toObject) == 'O';
 and PEMstatus(m.toObject, 'FontName', 5);
 and vartype(m.tcFontStyle) == 'C'
if m.llResult
	tcFontStyle = upper(alltrim(m.tcFontStyle))

	with m.toObject as label
		.fontbold = 'B' $ m.tcFontStyle
		.fontitalic = 'I' $ m.tcFontStyle
		.fontoutline = 'O' $ m.tcFontStyle
		.fontshadow = 'S' $ m.tcFontStyle
		.fontstrikethru = '-' $ m.tcFontStyle
		.fontunderline = 'U' $ m.tcFontStyle
	endwith
endif

return m.llResult

* ========================================
function aoParents && {fr} Lignée ascendante d'un objet
lparameters ;
  taParents; && @ {fr} Parent, grand parent, etc.
, toObject; && {fr} Objet
, tlDown && [.F.] {fr} de l'ancêtre au père
external array taParents
tlDown = lTrue(m.tlDown)

local loParent as control, llResult, lnResult

lnResult = 0
llResult = type('taParents', 1) == 'A' and vartype(m.toObject) == 'O'
assert m.llResult message cAssertMsg(textmerge([Invalid Parameters(s) : array <<cLitteral(m.taParents)>> - object <<cLitteral(m.toObject)>>]))
if m.llResult

	loParent = m.toObject
	do while .t.
		if type('m.loParent.Parent') == 'O'

			loParent = m.loParent.parent
			lnResult = m.lnResult + 1
			dimension taParents[m.lnResult]
			taParents[m.lnResult] = m.loParent
		else
			exit
		endif
	enddo
	if m.lnResult > 0 and m.tlDown

		local liParent, laParent[m.lnResult]
		for liParent = m.lnResult to 1 step -1
			laParent[m.lnResult - m.liParent + 1] = taParents[m.liParent]
		endfor
		acopy(laParent, taParents)
	endif
endif

return m.lnResult

* ========================================
function oParentClass && {fr} Premier ascendant d'un objet dérivé d'une classe
lparameters ;
  toObject; && {fr} Objet
, tcClass && {fr} Classe

local laParents[1], loParent, llResult, loResult

loResult = .null.
if vartype(m.toObject) == 'O'

	llResult = aoParents(@m.laParents, m.toObject) > 0
	assert m.llResult message cAssertMsg(textmerge([L'objet <<m.toObject.Name>> n'a aucun parent.]))
	if m.llResult

		for each loParent in laParents foxobject
			if loClass(m.loParent, m.tcClass)
				loResult = m.loParent
				exit
			endif
		endfor
	endif
endif

return m.loResult

* ========================================
function oParentProp && {fr} Premier ascendant d'un objet doté d'une certaine propriété
lparameters ;
  toObject; && {fr} Objet
, tcProp && {fr} Propriété

local laParents[1], loParent, llResult, loResult

loResult = .null.
llResult = vartype(m.toObject) == 'O'
assert m.llResult message cAssertMsg(textmerge([Objet attendu en premier paramètre <<cLitteral(m.toObject)>>]))
if m.llResult

	llResult = aoParents(@m.laParents, m.toObject) > 0
	assert m.llResult message cAssertMsg(textmerge([L'objet <<m.toObject.Name>> n'a aucun parent.]))
	if m.llResult

		for each loParent in laParents foxobject
			if lProperty(m.loParent, m.tcProp)
				loResult = m.loParent
				exit
			endif
		endfor
	endif
endif

return m.loResult

* ========================================
function locObject && {fr} Un objet en contient un autre
lparameters ;
  toCont; && {fr} Objet contenant
, tcObject && {fr} Object contenu

return loCont(m.toCont);
 and vartype(m.tcObject) == 'C';
 and not empty(m.tcObject);
 and type('m.toCont.' + m.tcObject) == 'O';
 and type('m.toCont.' + m.tcObject + '.baseClass') == 'C' && {fr} Après this.RemoveObject('cObject'), VarType(this.cObject) == 'O' (comportement VFP)


* ========================================
function lMember && {fr} Un objet est doté d'un ou plusieurs membre(s)
lparameters ;
  toObject; && {fr} Objet VFP
, tcMember; && {fr} membre(s)
, toMember; && @ {fr} membre

return .t.;
 and vartype(m.toObject) == 'O';
 and vartype(m.tcMember) == 'C';
 and iif(',' $ m.tcMember or ';' $ m.tcMember;
 	, lMembers(m.toObject, m.tcMember);
 	, .t.;
		and PEMstatus(m.toObject, m.tcMember, 5);
		and upper(left(PEMstatus(m.toObject, m.tcMember, 3), 1)) == 'O';
	  and (Pcount() < 3 or varSet(@m.toMember, evaluate('m.toObject.' + m.tcMember)));
	)
endfunc

* ========================================
function lMembers && {fr} Un objet est doté d'un ou plusieurs membre(s)
lparameters ;
  toObject; && {fr} Objet VFP
, tcMember && {fr} membre(s)

local llResult, laMember[1], lcMember

if vartype(m.toObject) == 'O';
 and vartype(m.tcMember) == 'C';
 and alines(laMember, alltrim(m.tcMember), 5, ',', ';') > 0

	llResult = .t.

	for each lcMember in m.laMember
		if !lMember(m.toObject, m.lcMember)
			llResult = .f.
			exit
		endif
	endfor
endif

return m.llResult
endfunc

* ------------------------------------
	procedure lMember_Test && {fr} test unitaire de lMember()

	local loTest as abUnitTest of abDev.prg;
	, oFrm as awFrm of aw.vcx;
	, oImg as awImg of aw.vcx;

	loTest = newobject('abUnitTest', 'abDev.prg')
	oFrm = newobject('awFrm', 'aw'+'.vcx')
	if vartype(m.oFrm) == 'O'

		loTest.Test(.t., m.oFrm, 'WaitPic', @m.oImg)
		loTest.assert(.t., loClass(m.oImg, 'awImg'))
	endif

	return loTest.Result()
	endproc

* ========================================
function lProperty && {fr} Un objet est doté d'une ou plusieurs propriété(s)
lparameters ;
  toObject; && {fr} Objet VFP
, tcProp && {fr} propriété(s)

return .t.;
 and vartype(m.toObject) == 'O';
 and vartype(m.tcProp) == 'C';
 and iif(',' $ m.tcProp or ';' $ m.tcProp;
 	, lProperties(m.toObject, m.tcProp);
 	, .t.;
		and PEMstatus(m.toObject, m.tcProp, 5);
		and upper(left(PEMstatus(m.toObject, m.tcProp, 3), 1)) == 'P';
	)
endfunc

* ========================================
function lProperties && {fr} Un objet est doté d'une ou plusieurs propriété(s)
lparameters ;
  toObject; && {fr} Objet VFP
, tcProp && {fr} propriété(s)

local llResult, laProp[1], lcProp

if vartype(m.toObject) == 'O';
 and vartype(m.tcProp) == 'C';
 and alines(laProp, alltrim(m.tcProp), 5, ',', ';') > 0

	llResult = .t.

	for each lcProp in m.laProp
		if !lProperty(m.toObject, m.lcProp)
			llResult = .f.
			exit
		endif
	endfor
endif

return m.llResult
endfunc

* ========================================
function lPropHidden && {fr} Un objet est doté d'un propriété cachée [PEMstatus(obj, prop, 2) retourne seulement les propriétés PROTECTED]
lparameters ;
  toObject; && {fr} Objet VFP
, tcProp && {fr} propriété

local array laProp[1]

return .t.;
	and aMembers(laProp, m.toObject, 0, 'H')  > 0;
	and ascan(laProp, alltrim(m.tcProp), 1, -1, 1, 7) > 0

* ========================================
function lPropChanged && {fr} Une propriété d'un objet ou classe est changée par une de ses classes parent
lparameters ;
  tObject; && {fr} Objet ou classe VFP
, tcProp as String && {fr} propriété

local success as Boolean;
, lcBaseClass;
, llClass;
, luClass;
, luProp;
, luPropClass;

if Type('m.tObject.BaseClass') == 'C' and ga_Type_IsChar(m.tcProp, .T.)
	lcBaseClass = m.tObject.BaseClass
	do while .T.
		luClass = Icase(;
			!m.llClass,;
				m.tObject,;
			Vartype(m.luClass) == 'O',;
				getPEM(m.luClass, 'Class'),;
				getPEM(m.luClass, 'ParentClass');
				)
		do case
		case !(PEMstatus(m.luClass, m.tcProp, 5) and Upper(Left(PEMstatus(m.luClass, m.tcProp, 3), 1)) == 'P');
			or Vartype(m.luClass) == 'C' and getPEM(m.luClass, 'Class') == m.lcBaseClass
			exit
		case .T.;
		 and varSet(@m.luProp, getPEM(m.luClass, m.tcProp));
		 and varSet(@m.luPropClass, getPEM(getPEM(m.luClass, Iif(Vartype(m.luClass) == 'O', 'Class', 'ParentClass')), m.tcProp)); && 2016-11-25 thn -- {FiC V 2.23.0-beta.5} {en} PEMstatus(m.luClass, m.tcProp, 0) does not seem to work on classes
		 and !luEqual(m.luProp, m.luPropClass)
			success = .T.
			exit
		endcase
		llClass = .T.
	enddo
else
	success = .null.
endif

return m.success
endfunc

* ========================================
function lMethod && {fr} Un objet est doté d'une Méthode ou un Événement
lparameters ;
  toObject as form; && {fr} Objet VFP
, tcMethod as string; && {fr} méthode
, tcEventMethod as string && [any] 'M'ethod or 'E'vent

return .t.;
	and vartype(m.toObject) == 'O';
	and vartype(m.tcMethod) == 'C';
	and not empty(m.tcMethod);
	and lProperty(m.toObject, 'BaseClass'); && {fr} C'est un objet VFP
	and	PEMstatus(m.toObject, m.tcMethod, 5); && {fr} tcMethod existe dans toObject
 	and	upper(left(PEMstatus(m.toObject, m.tcMethod, 3), 1)) $ evl(left(upper(alltrim(evl(m.tcEventMethod, ''))), 1), 'EM'); && {fr} tcMethod est un Événement ou une Méthode
 	and .t.

endfunc

* ------------------------------------
procedure lMethod_Test && {fr} test unitaire de lMethod()

local loTest as abUnitTest of abDev.prg, o

loTest = newobject('abUnitTest', 'abDev.prg')

if .t.;
 and varStore(@m.o, newobject('form'));
 and vartype(m.o) == 'O'

	loTest.Test(.t., m.o, 'Click')
	loTest.Test(.t., m.o, 'Click', 'Event')
	loTest.Test(.f., m.o, 'Click', 'method')
endif

return loTest.Result()

* ========================================
function lEvent && {fr} Un objet est doté d'un Événement
lparameters toObject as form, tcEvent && {fr} Objet VFP && {fr} méthode

return lMethod(m.toObject, m.tcEvent, 'E')

endfunc


#if .f. && {fr} inutile
	local aa[1], i
 	and aMembers(m.aa, m.toObject, 1, 'N') > 0; && {fr} Native members && {fr} il faut vérifier que l'utilisateur n'a pas créé une méthode du même nom qu'un événement
 	and varStore(@m.i, ascan(m.aa, m.tcEvent, 1, -1, 1, 15));
 	and m.i > 0;
 	and	upper(left(m.aa[m.i, 2], 1)) == 'E';
 	and .t.
#endif

* ------------------------------------
procedure lEvent_Test && {fr} test unitaire de lEvent()

local loTest as abUnitTest of abDev.prg;
, cFile;
, o;

loTest = newobject('abUnitTest', 'abDev.prg')

cFile = "lib\vfxobj.vcx" && {fr} avoids build errors

if .t.;
 and file(m.cFile);
 and varStore(@m.o, newobject('cpickalternate', m.cFile, 0));
 and vartype(m.o) == 'O'

	loTest.Test(.t., m.o, 'Click')
	loTest.Test(.f., m.o, 'Valid')
endif

return loTest.Result()

* ========================================
function lMethodImplemented && {fr} Une Méthode ou un Événement est implémenté(e) dans un objet /!\ SUPPORTE SEULEMENT LES CLASSES VISUELLES
lparameters ;
  toObject as object; && {fr} Objet VFP
, tcMethod as string && {fr} méthode

local llResult

if lMethod(m.toObject, m.tcMethod) && {fr} toObject has tcMethod

	llResult = .f.;
		or empty(m.toObject.classlibrary) and m.toObject.class == m.toObject.baseclass;
		or inlist(padr(lower(justext(m.toObject.classlibrary)), 3), 'vcx', 'scx')

	assert m.llResult message cAssertMsg(icase(;
			cLangUser() = 'fr',	[seules les classes visuelles sont supportées],; && copy-paste this line to add another language support
													[only visual classes are supported]; && Default: English
		))

	llResult = iif(m.llResult;
		, PEMstatus(m.toObject, m.tcMethod, 0); && {fr} tcMethod contient du code /!\ SUPPORTE SEULEMENT LES CLASSES VISUELLES
		, .null.; && {fr} don't know
		)
endif

return m.llResult

* ------------------------------------
procedure lMethodImplemented_Test && {fr} test unitaire de lMethodImplemented()

local loTest as abUnitTest of abDev.prg

loTest = newobject('abUnitTest', 'abDev.prg')

loTest.Test(.f., newobject('form'), 'init') && {fr} PEMstatus(,,0) ne marche pas avec une classe programmée PK ?
loTest.Test(.f., newobject('form'), 'foo')

loTest.Test(.t., newobject('awFrm', 'aw'+'.vcx'), 'init') && {fr} évite d'embarquer aw.vcx dans le projet
loTest.Test(.f., newobject('awFrm', 'aw'+'.vcx'), 'wUserAction_Ante') && {fr} method exists but not  && {fr} évite d'embarquer aw.vcx dans le projet

return loTest.Result()
endproc

* ========================================
function lBaseClass && {fr} Une classe est une classe de base VFP
lparameters tcClass && {fr} Classe de base

local laClass[1]
alanguage(laClass, 3)

return ascan(laClass, m.tcClass, 1, -1, 1, 7) > 0

* ========================================
function lBaseClassVisual && {fr} Une classe est une classe de base visuelle VFP
lparameters ;
  tcBaseClass; && {fr} Classe de base
, tlBaseClassMember; && @ {fr} Classe non visuelle qui peut être membre d'un formulaire ou d'un conteneur membre d'un formulaire

local llResult;
, lcBaseClass;
, lcBaseClassMember;

text TO lcBaseClass NOSHOW FLAGS 1
CheckBox
Column
ComboBox
CommandButton
CommandGroup
Container
Control
EditBox
Form
FormSet
Grid
Header
Hyperlink
Image
Label
Line
Listbox
OLEControl
OptionButton
OptionGroup
Page
PageFrame
Separator
Shape
Spinner
TextBox
ToolBar
ENDTEXT

text TO lcBaseClassMember NOSHOW FLAGS 1
Collection
Custom
DataEnvironment
OLEBoundControl
ReportListener
Session
Timer
XMLAdapter
XMLField
XMLTable
ENDTEXT

llResult = lInList(m.tcBaseClass, strtran(m.lcBaseClass, CRLF, ','))
tlBaseClassMember = m.llResult or lInList(m.tcBaseClass, strtran(m.lcBaseClassMember, CRLF, ','))

return m.llResult
endfunc

* ========================================
function oClone && (recursive) {en} Clones an object {fr} Clone un objet
lparameters toObj as collection && {en} as any VFP class

local loResult as collection; && {en} as any VFP class
, llResult as Boolean;
, llClass as Boolean;
, llClassLib as Boolean;
, laProp[1], lcProp, luProp;
, llUserDef as Boolean;
, llArray as Boolean;
, llModif as Boolean;
, liItem, lcKey;
, lnRow, lnCol;

loResult = m.toObj

if vartype(m.toObj) == 'O'

	llClass = type('m.toObj.Class') == 'C'
	llClassLib = m.llClass and !empty(m.toObj.classlibrary)

	loResult = iif(m.llClass;
		, newobject(m.toObj.class, m.toObj.classlibrary);
		, createobject('Empty');
		)
	if aMembers(laProp, m.toObj) > 0
		for each lcProp in laProp

			llResult = .t.

			do case

			case varSet(@m.llUserDef, PEMstatus(m.toObj, m.lcProp, 4)); && user defined
			and (.f.;
			 or PEMstatus(m.toObj, m.lcProp, 1); && {fr} read-only
			 or PEMstatus(m.toObj, m.lcProp, 2); && {fr} protected
			 or m.llClass and !m.llUserDef and ',' + m.lcProp + ',' $ ',BASECLASS,CLASS,CLASSLIBRARY,CONTROLCOUNT,CONTROLS,NAME,OBJECTS,OBJECT,PARENT,PARENTCLASS,';
			 )

			case .t.;
			 and varSet(@m.llUserDef, m.llUserDef and !PEMstatus(m.toObj, m.lcProp, 6)); && {en} property is user defined in object and not in parent class if any
			 and varSet(@m.llModif, PEMstatus(m.toObj, m.lcProp, 0)); && {fr} propriété modifiée
			 and varSet(@m.llArray, type('m.toObj.' + m.lcProp, 1) == 'A');
			 and varSet(@m.luProp, iif(m.llArray, .null., evaluate('m.toObj.' + m.lcProp))); && and setStepOn(Vartype(m.luProp) == 'O')
			 and m.llUserDef;
			 and m.llArray;
			 and .t.

				lnRow = alen(m.toObj.&lcProp, 1)
				lnCol = alen(m.toObj.&lcProp, 2)
				llResult = .t.;
				 and addproperty(;
					  m.loResult;
					, m.lcProp + textmerge(iif(m.lnCol > 0, '[<<m.lnRow>>, <<m.lnCol>>]', '[<<m.lnRow>>]'));
					);
				 and acopy(m.toObj.&lcProp, m.loResult.&lcProp) > 0

			case m.llUserDef or vartype(m.luProp) == 'O'

				llResult = addproperty(;
					  m.loResult;
					, m.lcProp;
					, iif(vartype(m.luProp) == 'O';
						, oClone(m.luProp);
						, m.luProp;
						);
					)

			case m.llModif and m.llArray
				lnRow = alen(m.toObj.&lcProp, 1)
				lnCol = alen(m.toObj.&lcProp, 2)
				do case
				case alen(m.toObj.&lcProp) = alen(m.loResult.&lcProp)
				case empty(m.lnCol)
					dimension m.loResult.&lcProp[m.lnRow]
				otherwise
					dimension m.loResult.&lcProp[m.lnRow, m.lnCol]
				endcase
				llResult = acopy(m.toObj.&lcProp, m.loResult.&lcProp) > 0

			case m.llModif and !(m.llClassLib and luEqual(m.luProp, getPEM(m.toObj.class, m.lcProp)))
				store m.luProp to ('m.loResult.' + m.lcProp)

			case m.llArray && {fr} PEMstatus() does not detect for changes in specific array elements if the array is passed.
				llResult = acopy(m.toObj.&lcProp, m.loResult.&lcProp) > 0

			endcase

			assert m.llResult
		endfor
	endif

	if loBaseClass(m.toObj, 'Collection') and m.toObj.count > 0
		for liItem = 1 to m.toObj.count
			lcKey = m.toObj.getkey(m.liItem)
			luProp = m.toObj.item(m.liItem)
			luProp = iif(vartype(m.luProp) == 'O', oClone(m.luProp), m.luProp)
			llResult = iif(empty(m.lcKey);
				, m.loResult.add(m.luProp);
				, m.loResult.add(m.luProp, m.lcKey);
				)
			assert m.llResult
		endfor
	endif
endif

return m.loResult

* -----------------------------------------
procedure oClone_Test && {fr} oClone() unit test

local loTest as abUnitTest of abDev.prg, loObj
loTest = newobject('abUnitTest', 'abDev.prg')

loObj = createobject('Empty')
oClone_Test_populate(loObj)
loTest.Test(m.loObj, m.loObj)

loObj = newobject('Custom')
oClone_Test_populate(loObj)
loTest.Test(m.loObj, m.loObj)

loObj = newobject('objectOfXML_Test_towBus', 'abOOP.prg') && {fr} As Custom
oClone_Test_populate(loObj)
loTest.Test(m.loObj, m.loObj)

return loTest.Result()

* -----------------------------------------
	function oClone_Test_populate(loObj)

	addproperty(m.loObj, 'string', 'test')
	addproperty(m.loObj, 'boolean', .t.)
	addproperty(m.loObj, 'numeric', 1)
	addproperty(m.loObj, 'date', date())
	addproperty(m.loObj, 'NULL', .null.)
	addproperty(m.loObj, 'array[2,2]')
		m.loObj.array[1] = .t.
		m.loObj.array[2] = 1
		m.loObj.array[3] = 'test'
		m.loObj.array[4] = createobject('Custom')
	addproperty(m.loObj, 'object', createobject('empty'))
	addproperty(m.loObj.object, 'string', 'test')

	return m.loObj

* ========================================
function aClasses && {fr} Classes d'un conteneur et de ses objets contenus
lparameters ;
  taClass; && @ {fr} classes
, toCont as container; && {fr} Classe contenante ou non
, tlRecurse && [.F.] {fr} Récurser dans les conteneurs

external array taClass

local laObj[1], loObj, laClass[1], lnResult
lnResult = 0

if aClear(@m.taClass)

	lnResult = aclass(m.taClass, m.toCont)
	if loCont(m.toCont) and aoClassCont(@m.laObj, m.toCont,, m.tlRecurse) > 0

		for each loObj in m.laObj foxobject
			aclass(laClass, m.loObj)
			lnResult = aAppend(@m.taClass, @m.laClass, .t.)
		endfor
	endif
endif

return m.lnResult

* ========================================
function aClassesClear && {fr} CLEAR CLASS sur un tableau de classes
lparameters taClass && @ {fr} classes
external array taClass

local lcClass, llResult

llResult = type('taClass', 1) == 'A' and not laEmpty(@m.taClass)
if m.llResult
	for each lcClass in taClass
		if not lBaseClass(m.lcClass)
			clear class (m.lcClass)
		endif
	endfor
endif

return m.llResult

* ========================================
function cXMLofObject as string && {en} Object linearized as XML {fr} Objet linéarisé en XML
lparameters ;
  toObj as object; && {en} Source Object {fr} Objet source
, tcResult as string && @ {en} Cumulative result {fr} Résultat (cumulatif)

&& {en} Supports:
&& {en} - nested objects
&& {en} - array properties
&& {en} - collections
&& {en} - class and classlibrary
&& {en} - protected and hidden properties of objects derived from FoxInCloud 'base classes' (aw.vcx!aw*)
&& {en} Only abOOP.prg!objectOfXML() can turn back result XML into an object

&& {fr} supporte les :
&& {fr} - objets imbriqués
&& {fr} - propriétés tableaux
&& {fr} - collections
&& {fr} - class et classlibrary
&& {fr} - les propriétés cachées et protégées des objets dérivés des 'classes de base' FoxInCloud (aw.vcx!aw*)
&& {fr} Seul abOOP.prg!objectOfXML() peut reconstituer l'objet à partir du XML produit

local lcResult as string; && {fr} XML, .null. if error
, cNullDisplay as string; && 2014-06-17 abSet can't be used because cXMLofObject() can be in a replace command - in a replace , .destroy() raises an error 'record is not locked'

cNullDisplay = set("Nulldisplay")
set nulldisplay to && .NULL.

lcResult = cXMLofObject_(m.toObj, @m.tcResult)

if !empty(m.cNullDisplay)
	set nulldisplay to (m.cNullDisplay)
endif

return m.lcResult

* ========================================
function cXMLofObject_ as string && {fr} Objet linéarisé en XML - Privée de cXMLofObject()
&& /!\ récursion à partir de cXMLofObject_uValue()
lparameters ;
  toObj as collection; && {fr} par exemple
, tcResult; && @ {fr} Résultat (cumulatif)

local lcResult as string; && {fr} XML, .null. if error
, llResult as Boolean;
, llEmpty;
, llFIC; && {fr} FoxInCloud object
, laProp[1], lnProp, liProp, lcProp, lcProp_, llProp;
, laPropPH[1]; && {fr} hidden and protected properties
, llPH, llwProp;
, luValue, lcType, lcFile, laValue[1], lnCol, llSafety;
, liItem, lcItem;

llResult = vartype(m.toObj) == 'O'
if m.llResult

	llEmpty = not type('m.toObj.BaseClass') == 'C'

	llResult = .f.;
	 or m.llEmpty;
	 or .t.;
 	  and (.f.;
 			or !inlist(m.toObj.baseclass, 'Dataenvironment', 'Cursoradapter', 'Header');
 			or cResultAdd(@m.tcResult, textmerge(icase(;
				cLangUser() = 'fr',	[La classe de base '<<m.toObj.BaseClass>>' n'est pas supportée],; && copy-paste this line to add another language support
														[Base Class '<<m.toObj.BaseClass>>' is not supported]; && default: English
				)));
			);
	  and (.f.;
 			or nObjectsCont(m.toObj) = 0; && {fr} pas un objet contenant ou aucun objet contenu
 			or cResultAdd(@m.tcResult, textmerge(icase(;
				cLangUser() = 'fr',	[Les objets membres de '<<m.toObj.Name>>' ne sont pas supportés pour l'instant],; && copy-paste this line to add another language support
														[Member objects in '<<m.toObj.Name>>' are not supported for now]; && default: English
				)));
			);
	  and .t.
	if m.llResult

		llFIC = lMethod(m.toObj, 'wPropGet') and lProperty(m.toObj, 'wcPropSave') && {fr} FoxInCloud object
		lcResult = textmerge("<#o#><#c#><<Iif(m.llEmpty, '', m.toObj.Class)>></#c#><#cl#><<Iif(m.llEmpty, '', m.toObj.ClassLibrary)>></#cl#>")
		lnProp = aMembers(laProp, m.toObj, 0, 'GPH') && {fr} public, protected and hidden && {fr} without ", 0, 'GPH')", aMembers() omits protected and hidden properties
		if m.lnProp > 0
			aMembers(laPropPH, m.toObj, 0, 'PH') && {fr} protected and hidden only

			for liProp = 1 to m.lnProp
* {fr} FOR EACH lcProp IN laProp && {fr} exactement le même temps de réponse

				if .t.;
				 and varSet(@m.lcProp, lower(m.laProp[m.liProp])); && {fr} Lower(m.lcProp)
				 and (m.llEmpty or .T.;
				  and PEMstatus(m.toObj, m.lcProp, 0); && {fr} property has changed compared to its parent class && {fr} OK pour les propriétés protégées
				  and cXMLofObject_lPropSave(m.toObj, m.lcProp, m.llFIC);
				  );

					if .t.;
					 and varSet(@m.llPH, ascan(m.laPropPH, m.lcProp) > 0);
					 and varSet(@m.llwProp, m.llPH and m.llFIC);
					 and varSet(@m.llProp, not m.llPH or m.llwProp);
					 and varSet(@m.lcProp_, 'm.toObj.' + m.lcProp);
					 and (.f.;
					 	or m.llProp;
					 	or cResultAdd(@m.tcResult, textmerge(icase(;
							cLangUser() = 'fr',	[La propriété '<<m.lcProp>>' ne peut être traitée car elle est protégée],; && copy-paste this line to add another language support
																	[Property '<<m.lcProp>>' can't be processed because it's protected]; && default: English
							)));
						)

					 	if .f.;
					 	 or (m.llwProp and m.toObj.wPropArray(m.lcProp) or type(m.lcProp_, 1) == 'A');
					 	 or !varSet(@m.luValue, cXMLofObject_uValue(; && avoids else
								  iif(m.llwProp;
								  , m.toObj.wPropGet(m.lcProp);
								  , evaluate(m.lcProp_);
								  );
								,@m.lcType;
								,@m.tcResult;
								))

					 		if m.llwProp
					 			m.toObj.wPropGet(m.lcProp, @m.laValue)
					 		else
					 			lnCol = alen(&lcProp_, 2) && {fr} m.toObj.&lcProp
					 			if m.lnCol > 0
					 				dimension laValue[Alen(&lcProp_, 1), m.lnCol]
					 			else
					 				dimension laValue[Alen(&lcProp_, 1)]
					 			endif
						 		acopy(&lcProp_, laValue)
					 		endif

					 		llProp = alen(m.laValue) < 65000
					 		if .f.;
					 		 or m.llProp;
					 		 or cResultAdd(@m.tcResult, textmerge(icase(;
										cLangUser() = 'fr',	[La propriété '<<m.lcProp>>' ne peut être traitée car c'est un tableau comportant plus de 65.000 éléments],; && copy-paste this line to add another language support
																				[Property '<<m.lcProp>>' can't be processed because it's an array with more than 65,000 elements]; && default: English
									)))
						 		for liItem = 1 to alen(m.laValue)
						 			if vartype(m.laValue[m.liItem]) == 'O'
						 				lcItem = textmerge(icase(;
												cLangUser() = 'fr',	[Les éléments de tableau de type objet ne sont pas supportés - propriété '<<m.lcProp>>', élément # <<m.liItem>>],; && copy-paste this line to add another language support
																						[Object array elements are not supported - property '<<m.lcProp>>', element # <<m.liItem>>]; && default: English
											))
						 				assert .f. message cAssertMsg(m.lcItem)
						 				cResultAdd(@m.tcResult, m.lcItem)
						 				llProp = .f.
						 				exit
						 			endif
						 		endfor
						 		if .t.;
						 		 and m.llProp;
						 		 and varSet(@m.lcType, 'A');
						 		 and varSet(@m.lcFile, evl(m.lcFile, addbs(sys(2023)) + 'temp' + cast(_vfp.processid as m) + '.mem'));
						 		 and varSet(@m.llSafety, set("Safety") == 'ON');
						 		 and .t.
							 		if m.llSafety
							 			set safety off
							 		endif
							 		save to (m.lcFile) all like laValue && {fr} The SAVE TO command does not support saving arrays exceeding 65,000 elements
							 		if m.llSafety
							 			set safety on
							 		endif
							 		luValue = strconv(filetostr(m.lcFile), 13) && {fr} convertit laValue (binaire) en base 64
							 		delete file (m.lcFile)
						 		endif
					 		endif
					 	endif
					endif

					lcResult = m.lcResult + iif(m.llProp;
						, textmerge([<#p#><#n#><<m.lcProp>></#n#><#t#><<m.lcType>></#t#><#v#><<Iif(m.lcType $ 'DT', cL(m.luValue), m.luValue)>></#v#></#p#>]);
						, '';
						)
				endif
			endfor
		endif

		lcResult = m.lcResult + cXMLofObject_colItems(m.toObj, @m.tcResult)
	endif

	assert m.llResult message cAssertMsg(m.tcResult)
endif

return iif(m.llResult;
	, m.lcResult + '</#o#>';
	, .null.;
	)

endfunc

* -----------------------------------------
function cXMLofObject_colItems && {fr} XML des items d'une collection
lparameters ;
  toObj as collection;
, tcResult; && @ {fr} Résultat (cumulatif)

local lcResult as String;
, liItem as Integer;
, luValue as String;
, lcType as String;

lcResult = ''
if loBaseClass(m.toObj, 'Collection') and m.toObj.count > 0
	for liItem = 1 to m.toObj.count
		luValue = cXMLofObject_uValue(m.toObj.item(m.liItem), @m.lcType, @m.tcResult)
		lcResult = m.lcResult + textmerge([<#item#><#key#><<m.toObj.getKey(m.liItem)>></#key#><#type#><<m.lcType>></#type#><#value#><<m.luValue>></#value#></#item#>])
	endfor
endif

return m.lcResult
endfunc

* -----------------------------------------
function cXMLofObject_uValue(tuValue, tcType, tcResult) && [privée de cXMLofObject()] {fr} Valeur d'un type donné

tcType = Vartype(m.tuValue) && Vartype(m.tuValue, .T.)
tcType = iif(m.tcType == 'N' and ga_Type_IsInteger(m.tuValue), 'I', m.tcType)

return iif(m.tcType == 'O';
	, nvl(cXMLofObject_(m.tuValue, @m.tcResult), ''); && /!\ récursion
	, m.tuValue;
	)
endfunc

* -----------------------------------------
function cXMLofObject_lPropSave(toObj, tcProp, llFIC) && [privée de cXMLofObject()] {fr} Propriété modifiable à sauvegarder
local lcProp as string
lcProp = ',' + lower(m.tcProp) + ','
return .t.;
 and !PEMstatus(m.toObj, m.tcProp, 1); && {fr} Read-only
 and !m.lcProp $ ',' + chrtran(lower('wcPropSave,_MemberData,Name'), ' ', '') + ','; && ,dataSession,dataSessionID
 and (!m.llFIC or m.lcProp $ ',' + Lower(chrtran(nvl(m.toObj.wcPropSave, ''), ' ', '')) + ',');

endfunc

* -----------------------------------------
procedure cXMLofObject_Test && {fr} test unitaire de cXMLofObject()

local loTest as abUnitTest of abDev.prg;
, loObj as collection, lcResult

loTest = newobject('abUnitTest', 'abDev.prg')

loObj = createobject('Collection')

addproperty(m.loObj, 'string', 'testValue')
m.loObj.add('testItem1', 'testItem1')
m.loObj.add('testItem2', 'testItem2')

addproperty(m.loObj, 'object', createobject('Collection'))
addproperty(m.loObj.object, 'string', 'testValue')
m.loObj.object.add('testItem1', 'testItem1')
m.loObj.object.add('testItem2', 'testItem2')

addproperty(m.loObj.object, 'object', createobject('Custom'))
addproperty(m.loObj.object.object, 'string', 'testValue')

addproperty(m.loObj.object.object, 'object', createobject('Grid'))
addproperty(m.loObj.object.object.object, 'string', 'testValue')
addproperty(m.loObj.object.object.object, 'array[2]')
m.loObj.object.object.object.array[1] = 'el1'
m.loObj.object.object.object.array[2] = newobject('awcst', 'aw' + '.vcx') && {fr} évite d'embarquer aw.vcx dans un projet ab

lcResult = ''
loTest.Test(.null., m.loObj, @m.lcResult) && .NULL.
? m.lcResult

addproperty(m.loObj.object.object.object, 'array[66000]')
lcResult = ''
loTest.Test(.null., m.loObj, @m.lcResult) && .NULL.
? m.lcResult


loObj = newobject('awfrm', 'aw' + '.vcx') && {fr} évite d'embarquer aw.vcx dans un projet ab
lcResult = ''
loTest.Test(.null., m.loObj, @m.lcResult) && .NULL.
? m.lcResult

loObj = newobject('awgrd', 'aw' + '.vcx') && {fr} évite d'embarquer aw.vcx dans un projet ab
lcResult = ''
loTest.Test(.null., m.loObj, @m.lcResult) && .NULL.
? m.lcResult

loObj.ColumnCount = 2
lcResult = ''
loTest.Test(.null., m.loObj, @m.lcResult) && .NULL.
? m.lcResult

loTest.Test(.null., cXMLofObject_Test_oCastelec(), @m.lcResult) && .NULL.

return loTest.Result()

* -----------------------------------------
procedure cXMLofObject_Test_Castelec
lparameters tnProp

local loResult, lnResult, lcResult

lnResult = seconds()
loResult = cXMLofObject_Test_oCastelec(m.tnProp)
objectOfXML(cXMLofObject(m.loResult), @m.loResult, @m.lcResult)

? nSeconds(m.lnResult), evl(m.lcResult, '')

* -----------------------------------------
procedure cXMLofObject_Test_oCastelec
lparameters tnProp

local liResult, loResult

loResult = createobject('Empty')
for liResult = 1 to evl(m.tnProp, 56) && 1800 propriétés (champs) pour le fomulaire vFacturas, mais 56 utiles
	addproperty(;
		  m.loResult;
		, 'test' + transform(m.liResult);
		, icase(;
			m.liResult % 7 = 0, date(),;
			m.liResult % 5 = 0, 1000,;
			m.liResult % 3 = 0, .t.,;
			m.liResult % 2 = 0, replicate('a', 80),;
			.null.;
			);
		)
endfor

return m.loResult

* ========================================
function lXMLofObject(tcXML, tcResult, lAssert) && {fr} cXMLofObject() a produit ce XML

local llResult, lcResult

llResult = .t.;
	and vartype(m.tcXML) == 'C';
	and leftc(m.tcXML, lenc('<#o#>')) == '<#o#>';
	and rightc(m.tcXML, lenc('</#o#>')) == '</#o#>'

= m.llResult or .t.;
	 and varSet(@m.lcResult, textmerge(icase(;
			cLangUser() = 'fr',	[Ce XML est invalide, probablement car cXMLofObject() a échoué à le construire : <<m.tcXML>>],; && copy-paste this line to add another language support
													[This XML is invalid, probably because cXMLofObject() didn't build it successfully: <<m.tcXML>>]; && default: English
		)));
	 and cResultAdd(@m.tcResult, m.lcResult)

if m.lAssert and !isnull(m.tcXML)
	assert m.llResult message cAssertMsg(m.lcResult)
endif

tcXML = iif(m.llResult;
	, substrc(m.tcXML;
		, len('<#o#>') + 1;
		, len(m.tcXML) - len('<#o#></#o#>');
		);
	, m.tcXML;
	)

return m.llResult
endfunc

* ========================================
function objectOfXML as object && {en} Object from its linearized XML produced by cXMLofObject() {fr} Objet à partir de sa représentation linéarisée en XML par cXMLofObject()
&& /!\ récursive
lparameters ;
  tcXML as string; && {en} XML produced by cXMLofObject() {fr} XML produit par cXMLofObject()
, toResult as object; && [NewObject(class, classlib)] {en} Result object to populate {fr} Objet résultat à peupler
, tcResult as string; && @ {en} Cumulative result {fr} Résultat (cumulatif)

local toResult as object; && {fr} see above
, llResult as Boolean;
, lcResult as string;
, llChild as Boolean;
, lnChild as Integer;
, liChild as Integer;
, loChild as collection; && {fr} objets enfants éventuels
, llObject as Boolean; && @ {en} an object was passed in toResult {fr} Un objet a été passé dans toResult
, llFIC as Boolean; && @ {en} object derives from a FoxinCloud class {fr} L'objet a d'une classe FoxinCloud

&& {en} Support scope: see abOOP.prg!cXMLofObject()
&& {fr} Détails du support : voir abOOP.prg!cXMLofObject()

if empty(m.tcXML)
	return
endif

store 0 to liChild, lnChild

llResult = .T.;
	;
	and lXMLofObject(;
		 @m.tcXML;
		,@m.lcResult;
		, .T.; && .T. : ASSERT m.llResult && {fr} ôte les balises <#o#> initiale et </#o#> terminale
		);
	;
	and objectOfXML_lChild(; && {en} identifies child object patterns in XML [objectOfXML() private] {fr} repère les objets enfants dans le XML [privée de objectOfXML()] 
		  @m.tcXML;
		, @m.lcResult;
		, @m.llChild;
		, @m.lnChild;
		, @m.loChild;
		);
	;
	and objectOfXML_object(; && {en} [objectOfXML() private] retrieves or create a clean source object {fr}  [privée de objectOfXML()] retrouve ou nettoie l'objet source
		  m.tcXML; && {en} XML produced by cXMLofObject() {fr} XML produit par cXMLofObject()
		,@m.toResult; && [NewObject(class, classlib)] {en} Object to populate {fr} Objet à peupler
		,@m.lcResult; && @ {en} Cumulative result {fr} Résultat (cumulatif)
		,@m.llObject; && @ {en} an object was passed {fr} Un objet a été passé
		,@m.llFIC; && @ {en} object derives from a FoxinCloud class {fr} L'objet a d'une classe FoxinCloud
		);
	;
	and objectOfXML_propSet(; && {en} [objectOfXML() private] restores object properties {fr}  [privée de objectOfXML()] restaure les propriétés de l'objet
		  m.tcXML; && {en} XML produced by cXMLofObject() {fr} XML produit par cXMLofObject()
		, m.toResult; && [NewObject(class, classlib)] {en} Object to populate {fr} Objet à peupler
		,@m.lcResult; && @ {en} Cumulative result {fr} Résultat (cumulatif)
		, m.llObject; && {en} an object was passed {fr} Un objet a été passé
		, m.llFIC; && {en} object derives from a FoxinCloud class {fr} L'objet a d'une classe FoxinCloud
		, m.llChild; && {en} object has direct child(ren) {fr} L'objet a des objets enfants
		,@m.liChild; && @ {en} Index of current child object {fr} Index de l'objet enfant courant
		, m.loChild; && {en} Child objects XML {fr} XML des objets enfants
		);
	 ;
	and objectOfXML_colItems(; && {fr} Si Collection, restaure ses membres
			m.tcXML; && {en} XML produced by cXMLofObject() {fr} XML produit par cXMLofObject()
		, m.toResult; && {en} Object to populate {fr} Objet à peupler
		,@m.lcResult; && @ {en} Cumulative result {fr} Résultat (cumulatif)
		, m.llChild; && {en} object has direct child(ren) {fr} L'objet a des objets enfants
		,@m.liChild; && @ {en} Index of current child object {fr} Index de l'objet enfant courant
		, m.loChild; && {en} Child objects XML {fr} XML des objets enfants
		)
	
assert m.liChild = m.lnChild && {fr} tous les objets enfants éventuels ont bien été restaurés

= m.llResult or cResultAdd(@m.tcResult, m.lcResult)

return iif(m.llResult or vartype(m.toResult) == 'O';
	, m.toResult;
	, .null.;
	)
endfunc

* ========================================
procedure objectOfXML_object && [Internal] {en} [objectOfXML() private] retrieves or create a clean source object {fr}  [privée de objectOfXML()] retrouve ou nettoie l'objet source
lparameters ;
  tcXML as string; && {en} XML produced by cXMLofObject() {fr} XML produit par cXMLofObject()
, toResult as object; && [NewObject(class, classlib)] {en} Object to populate {fr} Objet à peupler
, tcResult as string; && @ {en} Cumulative result {fr} Résultat (cumulatif)
, llObject as Boolean; && @ {en} an object was passed {fr} Un objet a été passé
, llFIC as Boolean; && @ {en} object derives from a FoxinCloud class {fr} L'objet a d'une classe FoxinCloud

local llResult as Boolean;
, lcResult as string;
;
, loClass, lcClass, lcClassLib;
, llEmpty;
, laProp[1], lcProp, llProp, luProp, luProp_;

#if .f.
o = createobject('empty')
addproperty(o, 'test')
? PEMstatus(o, 'test', 0) && .T. && {fr} Toutes les propriétés d'un objet Empty étant marquées modifiées, cXMLofObject() les a toutes listées
#endif

* {fr} Recycler l'objet existant en razant ses propriétés ou créer un nouvel objet
lcClass = lower(strextract(m.tcXML, '<#c#>', '</#c#>'))
lcClassLib = lower(strextract(m.tcXML, '<#cl#>', '</#cl#>'))
llEmpty = empty(m.lcClass)

llObject = .t.;
 and vartype(m.toResult) == 'O';
 and (.f.;
  or .t.;
   and m.llEmpty;
   and type('m.toResult.Class') == 'U';
  or .t.;
   and type('m.toResult.Class') == 'C';
   and lower(m.toResult.class) == m.lcClass;
   and lower(m.toResult.classlibrary) == m.lcClassLib;
  )

&& {fr} Voir ce qui est le plus rapide, remettre toutes les propriétés à leur valeur par défaut ou recréer un objet ...
&& {fr} 2015-03-19 thn - si l'objet existe il vaut mieux le conserver car le supprimer/recréer exécute les méthodes .Destroy() et .Init() qui peuvent parfaitement se planter ...
&& {fr} 2014-12-23 thn
&& {fr} - objets empty : recréer systématiquement
&& {fr} - objets dérivés d'une classe :
&& {fr}   . supprimer les propriétés éventuellement ajoutées à l'objet
&& {fr}   . remettre les autres propriétés à la valeur de la classe,

toResult = iCase(;
	m.llEmpty,; && {fr} objets empty : recréer systématiquement
		createobject('Empty'),;
	m.llObject,;
		m.toResult,;
	varSet(@m.loClass, objectOfXML_object_oClass(m.lcClass, m.lcClassLib)),;
		m.loClass,;
		.null.;
	)

assert Vartype(m.toResult) == 'O'

llFIC = lMethod(m.toResult, 'wPropReset') and lProperty(m.toResult, 'wcPropSave') && {en} FoxInCloud object

#if .f.
toResult = createobject('relation')
lcProp = 'test'
? aMembers(aa, m.toResult, 0, 'GPH')
addproperty(m.toResult, m.lcProp, 'test')
? aMembers(aa, m.toResult, 0, 'GPH')
? PEMstatus(m.toResult, m.lcProp, 4) && .T.
? PEMstatus(m.toResult, 'Class', 4) && .F.
suspend
#endif

* {fr} Si un objet a été passé, remettre ses propriétés à leur valeur par défaut
if m.llObject;
 and !m.llEmpty;
 and aMembers(laProp, m.toResult, 0, 'GPH') > 0

	for each lcProp in laProp
		= .f.;
		 	or .t.;
		 		and !PEMstatus(m.toResult, m.lcProp, 4); && {en} not user defined
		 		and ',' + m.lcProp + ',' $ ',BASECLASS,CLASS,CLASSLIBRARY,CONTROLCOUNT,CONTROLS,NAME,OBJECTS,OBJECT,PARENT,PARENTCLASS,';
		 	or .t.;
		 		and  PEMstatus(m.toResult, m.lcProp, 4); && {en} custom property ...
		 		and !PEMstatus(m.toResult, m.lcProp, 6); && ... added to the object (not inherited from the class)
		 		and removeproperty(m.toResult, m.lcProp);
		 	or PEMstatus(m.toResult, m.lcProp, 1); && {en} Read-only
		 	or .t.; && and setStepOn(Lower(m.lcProp) == 'keysort')
			 and PEMstatus(m.toResult, m.lcProp, 0); && {en} modified
			 and varSet(@m.luProp,  getPEM(m.toResult, m.lcProp));
			 and varSet(@m.luProp_, getPEM(m.toResult.Class, m.lcProp)); &&  && 2018-01-10 thn -- {FiC V 2.26.1-beta.1} {en} replaced getPEM(m.loClass, m.lcProp) by getPEM(m.toResult.Class, m.lcProp)
			 and !luEqual(m.luProp, m.luProp_); && {fr} Propriété changée par rapport à la classe
			 and iif(PEMstatus(m.toResult, m.lcProp, 2); && {en} protected property
				, iif(m.llFIC;
					, m.toResult.wPropReset(m.lcProp);
					, .f.;
					);
				, addproperty(m.toResult, m.lcProp, iif(vartype(m.luProp_) == 'O'; && {en} sets property to value in class
					, oClone(m.luProp_);
					, m.luProp_;
					)));
				)
	endfor
endif
endproc

* ========================================
function objectOfXML_object_oClass(lcClass, lcClassLib, loClass) && [Internal] {en} [objectOfXML_object() private] class instance {fr}  [privée de objectOfXML_object()] instance d'une classe
&& 2018-01-10 thn -- {FiC V 2.26.1-beta.1} {en} created
try
	loClass = newobject(m.lcClass, m.lcClassLib, 0)
catch
	loClass = newobject(m.lcClass, m.lcClassLib)
endtry
return m.loClass
endfunc

* ========================================
procedure objectOfXML_lChild as Boolean && [Internal] {en} [objectOfXML() private] identifies child object patterns in XML {fr} [privée de objectOfXML()] repère les objets enfants dans le XML 
lparameters ;
  tcXML as string; && @ {en} XML produced by cXMLofObject() {fr} XML produit par cXMLofObject()
, tcResult as string; && @ {en} Cumulative result {fr} Résultat (cumulatif)
, llChild as Boolean; && @ [.F.] {en} object has direct child(ren) {fr} L'objet a des objets enfants
, lnChild as Integer; && @ {en} [0] Number of direct child objects {fr} Nombre d'objets enfants
, loChild as collection; && @ {en} [.F.] Child objects XML {fr} XML des objets enfants

local llResult as Boolean;
, lcResult as string;
, loRegExpOpen as abRegExp of abTxt.prg;
, loRegExpClose as abRegExp of abTxt.prg;
;
, liChildOpen  as Integer;
, liChildOpen_ as Integer;
, liChildClose as Integer;
, laChild[1];
, lnChildXML as integer;
, lnObject as integer;
, llObjects as Boolean;

lnChild = occurs('<#o#>', m.tcXML) && {fr} au moins une des propriétés de l'objet contient un objet
llChild = m.lnChild > 0
llResult = not m.llChild or m.lnChild = occurs('</#o#>', m.tcXML)
= m.llResult or varSet(@m.lcResult, textmerge(icase(;
	cLangUser() = 'fr',	[Ce XML comporte des balises '<#o#>|</#o#>' dépareillées : <<m.tcXML>>],; && copy-paste this line to add another language support
											[Mismatched '<#o#>|</#o#>' delimiter(s) in XML: <<m.tcXML>>]; && default: English
	)))
assert m.llResult message cAssertMsg(m.lcResult)
if m.llResult and m.llChild

	loRegExpOpen  = abRegExp()
	loRegExpClose = abRegExp()

	llChild = .t.;
	 and m.loRegExpOpen.setup ('<#o#>',  .f., .t., .f.);
	 and m.loRegExpClose.setup('</#o#>', .f., .t., .f.);
	 and varSet(@m.lnObject, m.loRegExpOpen.Execute(m.tcXML));
	 and m.lnObject = m.loRegExpClose.Execute(m.tcXML);
	 and varSet(@m.llObjects, m.lnObject > 1)

assert m.llChild && {fr} should always be OK

	lnChild = 0
	loChild = createobject('Collection')
	for m.liChildOpen = 1 to m.lnObject

		store m.liChildOpen to liChildClose, liChildOpen_
		if m.llObjects and m.liChildOpen < m.lnObject

			* {fr} localiser la balise fermante
			do while .t.
				liChildOpen_ = m.liChildOpen_ + 1
				if m.loRegExpOpen.Matches[m.liChildOpen_, 1] < m.loRegExpClose.Matches[m.liChildClose, 1] && {fr} position
					liChildClose = m.liChildClose + 1
					if m.liChildClose = m.lnObject
						exit
					endif
				else
					exit
				endif
			enddo
		endif

		lnChildXML = 0; && {fr} longueur de la chaîne XML de l'objet enfant
			+ m.loRegExpClose.Matches[m.liChildClose, 1];
			+ lenc(m.loRegExpClose.pattern);
			- m.loRegExpOpen.Matches[m.liChildOpen, 1]

		* ==============================================
		loChild.add(substrc(m.tcXML;
			, m.loRegExpOpen.Matches[m.liChildOpen, 1]; && {fr} index début
			, m.lnChildXML; && {fr} longueur
			))
		lnChild = m.loChild.count
		* ==============================================

		* {fr} Mémoriser le début et la longueur de la chaîne représentant l'objet
		dimension laChild[m.lnChild, 2]
		laChild[m.lnChild, 1] = m.loRegExpOpen.Matches[m.liChildOpen, 1] && {fr} index début
		laChild[m.lnChild, 2] = m.lnChildXML && {fr} longueur

		liChildOpen = m.liChildClose
	endfor

	if m.lnChild > 0
		for liChildOpen = m.lnChild to 1 step -1
			tcXML = stuffc(m.tcXML;
				, laChild[m.liChildOpen, 1]; && {fr} index début
				, laChild[m.liChildOpen, 2]; && {fr} longueur
				, [#object#];
				)
		endfor
	endif
else
	llChild = .F.
	lnChild = 0
endif

return m.llResult or cResultAdd(@m.tcResult, m.lcResult)
endproc

* ========================================
procedure objectOfXML_propSet && [Internal] {en} [objectOfXML() private] restores object properties {fr}  [privée de objectOfXML()] restaure les propriétés de l'objet
lparameters ;
  tcXML as string; && {en} XML produced by cXMLofObject() {fr} XML produit par cXMLofObject()
, toResult as object; && [NewObject(class, classlib)] {en} Object to populate {fr} Objet à peupler
, tcResult as string; && @ {en} Cumulative result {fr} Résultat (cumulatif)
, llObject as Boolean; && {en} an object was passed {fr} Un objet a été passé
, llFIC as Boolean; && {en} object derives from a FoxinCloud class {fr} L'objet a d'une classe FoxinCloud
, llChild as Boolean; && {en} object has direct child(ren) {fr} L'objet a des objets enfants
, liChild as Integer; && @ {en} Index of current child object {fr} Index de l'objet enfant courant
, loChild as collection; && {en} Child objects XML {fr} XML des objets enfants

local llResult as Boolean;
, lcResult as string;
, laProp[1], lcProp, llProp;
, lcType, luValue, laValue[1];
, lcFile;
, llSafety;

if Empty(aStrExtract(@m.laProp, m.tcXML, '<#p#>', '</#p#>'))
	return
endif

llResult = .T.
for each lcProp in laProp

	lcType = strextract(m.lcProp, '<#t#>', '</#t#>')
	luValue = strextract(m.lcProp, '<#v#>', '</#v#>')
	lcProp = strextract(m.lcProp, '<#n#>', '</#n#>') && {fr} en dernier car m.lcProp est recyclée ...
	llProp = .f.;
	 or not lProperty(m.toResult, m.lcProp);
	 or not (.f.;
		or PEMstatus(m.toResult, m.lcProp, 1); && {fr} Read-Only
		or PEMstatus(m.toResult, m.lcProp, 2); && {fr} Protected
		);
	 or m.llFIC && {fr} en dernier!
	lcProp = iif(m.llProp, m.lcProp, icase(;
		cLangUser() = 'fr',	[La propriété '<<m.lcProp>>' ne peut être restaurée car elle est protégée ou en lecture seule],; && copy-paste this line to add another language support
												[Property '<<m.lcProp>>' can't be restored because it's protected or read-only]; && default: English
		))
	= m.llProp or cResultAdd(@m.tcResult, m.lcProp)
	assert m.llProp message cAssertMsg(m.lcProp)

	do case

	case not m.llProp

	case m.lcType == 'C'

		&& {fr} la valeur est déjà dans le bon type
		addproperty(;
			  m.toResult;
			, m.lcProp;
			, m.luValue;
			)

	case m.lcType == 'A'

 		llSafety = set("Safety") == 'ON'
 		if m.llSafety
 			set safety off
 		endif
 		lcFile = evl(m.lcFile, addbs(sys(2023)) + 'temp' + cast(_vfp.processid as m) + '.mem')
 		strtofile(strconv(m.luValue, 14), m.lcFile) && 14: Converts base64 encoded data in cExpression to original unencoded data.
 		if m.llSafety
 			set safety on
 		endif
 		aClear(@m.laValue)
 		restore from (m.lcFile) additive
 		delete file (m.lcFile)
 		addproperty(m.toResult, m.lcProp + textmerge(iif(alen(m.laValue, 2) > 0;
 				, '[<<Alen(m.laValue, 1)>>, <<Alen(m.laValue, 2)>>]';
 				, '[<<Alen(m.laValue)>>]';
 				)))
 		acopy(m.laValue, m.toResult.&lcProp)

	case m.lcType != 'O'
		addproperty(;
			  m.toResult;
			, m.lcProp;
			, uValue(m.luValue, m.lcType);
			)

	otherwise

		llResult = m.luValue == [#object#] and m.llChild
		= m.llResult or varSet(@m.lcResult, textmerge(icase(;
			cLangUser() = 'fr',	[La propriété de type objet '<<m.lcProp>>' n'a pas pu être restaurée],; && copy-paste this line to add another language support
													[Object property '<<m.lcProp>>' could not be restored]; && default: English
			)))
		assert m.llResult message cAssertMsg(m.lcResult)
		if m.llResult
			liChild = m.liChild + 1
			luValue = objectOfXML(; && /!\ récursion
				  m.loChild.item(m.liChild);
				, iif(m.llObject and lProperty(m.toResult, m.lcProp) and Type('m.toResult.' + m.lcProp) == 'O';
					, evaluate('m.toResult.' + m.lcProp);
					, .F.; && {fr} createobject('Empty')
					);
				)
		else
			cResultAdd(@m.tcResult, m.lcResult)
			exit
		endif
		llResult = (.F.;
			or addproperty(;
				  m.toResult;
				, m.lcProp;
				, m.luValue;
				);
			or cResultAdd(@m.tcResult, Textmerge([could not add property '<<m.lcProp>>' to <<m.toResult>>]));
			) and m.llResult
	endcase
endfor

return m.llResult
endproc

* ========================================
procedure objectOfXML_colItems as Boolean && {en} restores collection items from XML built by cXMLofObject() {fr} restaure les éléments d'une collection d'après le XML de cXMLofObject()
lparameters ;
  tcXML as string; && {en} XML produced by cXMLofObject() {fr} XML produit par cXMLofObject()
, toResult as object; && {en} Collection Object to populate {fr} Objet Collection à peupler
, tcResult as string; && @ {en} Cumulative result {fr} Résultat (cumulatif)
, llChild as Boolean; && [compute] {en} object has direct child(ren) {fr} L'objet a des objets enfants
, liChild as Integer; && @ [compute] {en} Index of current child object {fr} Index de l'objet enfant courant
, loChild as collection; && [compute] {en} Child objects XML {fr} XML des objets enfants

local llChild_ as boolean, lnChild as Integer

do case
case !loBaseClass(m.toResult, 'Collection')

case !'<#item#>' $ m.tcXML
	m.toResult.remove(-1) && {fr} If you pass a value of -1, Visual FoxPro removes all items in the collection.

case varSet(@m.llChild_, Pcount() <= 3);
 and m.llChild_;
 and varSet(@m.liChild, 0);
 and !objectOfXML_lChild(;
		@m.tcXML; && @ {en} XML produced by cXMLofObject() {fr} XML produit par cXMLofObject()
	, @m.tcResult; && @ {en} Cumulative result {fr} Résultat (cumulatif)
	, @m.llChild; && @ [.F.] {en} object has direct child(ren) {fr} L'objet a des objets enfants
	, @m.lnChild; && @m.lnChild && @ {en} [0] Number of direct child objects {fr} Nombre d'objets enfants
	, @m.loChild; && @ {en} [.F.] Child objects XML {fr} XML des objets enfants
	)
 
 	return .F.

otherwise

	local llResult as Boolean;
	, loRegExpOpen as abRegExp of abTxt.prg;
	, loRegExpClose as abRegExp of abTxt.prg;
	;
	, liItem, lcItem, lcKey;
	, lcType, luValue;

	loRegExpOpen  = iif(vartype(m.loRegExpOpen)  == 'O', m.loRegExpOpen,  abRegExp())
	loRegExpClose = iif(vartype(m.loRegExpClose) == 'O', m.loRegExpClose, abRegExp())

	llResult = .t.;
	 and m.loRegExpOpen.setup('<#item#>', .f., .t., .f.);
	 and m.loRegExpClose.setup('</#item#>', .f., .t., .f.);
	 and m.loRegExpOpen.Execute(m.tcXML) = m.loRegExpClose.Execute(m.tcXML)
	assert m.llResult message cAssertMsg(textmerge(icase(;
		cLangUser() = 'fr',	[Ce XML comporte des balises '<#item#>|</#item#>' dépareillées : <<m.tcXML>>],; && copy-paste this line to add another language support
												[Mismatched '<#item#>|</#item#>' delimiter(s) in XML: <<m.tcXML>>]; && default: English
		)))
	if m.llResult

	 	toResult.remove(-1) && {fr} If you pass a value of -1, Visual FoxPro removes all items in the collection.
	 	for liItem = 1 to m.loRegExpOpen.nMatches

			lcItem = substrc(m.tcXML;
				, m.loRegExpOpen.Matches[m.liItem, 1];
				, 0;
					+ m.loRegExpClose.Matches[m.liItem, 1];
					+ lenc(m.loRegExpClose.pattern);
					- m.loRegExpOpen.Matches[m.liItem, 1];
				)
			lcKey = strextract(m.lcItem, '<#key#>', '</#key#>')
			lcType = strextract(m.lcItem, '<#type#>', '</#type#>')
			luValue = strextract(m.lcItem, '<#value#>', '</#value#>')
			if m.lcType == 'O'

				llResult = m.luValue == [#object#] and m.llChild
				assert m.llResult message cAssertMsg(textmerge(icase(;
					cLangUser() = 'fr',	[Erreur d'encodage XML d'un objet dans la collection '<<m.toResult.Name>>', clé : '<<m.lcKey>>', index : '<<m.liItem>>'],; && copy-paste this line to add another language support
															[XML encoding error for an object in collection '<<m.toResult.Name>>', key: '<<m.lcKey>>', index: '<<m.liItem>>']; && default: English
					)))
				if m.llResult
					liChild = m.liChild + 1
					luValue = objectOfXML(m.loChild.item(m.liChild)) && /!\ récursion
				else
					exit
				endif
			else
				luValue = uValue(m.luValue, m.lcType)
			endif
			llResult = m.llResult and iif(empty(m.lcKey);
				, m.toResult.add(m.luValue);
				, m.toResult.add(m.luValue, m.lcKey);
				)
			assert m.llResult message cAssertMsg(textmerge(icase(;
				cLangUser() = 'fr',	[La valeur <<cLitteral(m.luValue)>> ne peut être ajoutée à la collection '<<m.toResult.Name>>' avec le clé '<<m.lcKey>>'],; && copy-paste this line to add another language support
														[Could not add <<cLitteral(m.luValue)>> to collection '<<m.toResult.Name>>' with key '<<m.lcKey>>']; && default: English
				)))
			if not m.llResult
				exit
			endif
		endfor
	endif

	assert !m.llChild_ or m.lnChild = m.liChild
	
	return m.llResult
endcase
endproc

* -----------------------------------------
procedure objectOfXML_Test && {en} objectOfXML() unit test {fr} test unitaire de objectOfXML()

* {fr} CLEAR ALL

local loTest as abUnitTest of abDev.prg;
, loObj as collection;
, lcResult as string;

loTest = newobject('abUnitTest', 'abDev.prg')

loObj = createobject('Collection')

addproperty(m.loObj, 'string', 'testValue')
m.loObj.add('testItem1', 'testItem1')
m.loObj.add('testItem2', 'testItem2')

addproperty(m.loObj, 'object', createobject('Collection'))
addproperty(m.loObj.object, 'string', 'testValue')
m.loObj.object.add('testItem1', 'testItem1')
m.loObj.object.add(CreateObject('custom'), 'testItem2') && {fr} m.loObj.object.add('testItem2', 'testItem2')

addproperty(m.loObj.object, 'object', createobject('Custom'))
addproperty(m.loObj.object.object, 'string', 'testValue')

addproperty(m.loObj.object.object, 'object', createobject('Empty'))
addproperty(m.loObj.object.object.object, 'string', 'testValue')
addproperty(m.loObj.object.object.object, 'array[2]')
m.loObj.object.object.object.array[1] = 'el1'
m.loObj.object.object.object.array[2] = 2.5

lcResult = ''
loTest.Test(oClone(m.loObj);
	, cXMLofObject(m.loObj); && {en} XML produced by cXMLofObject() {fr} XML produit par cXMLofObject()
	, m.loObj; && [NewObject(class, classlib)] {en} Object to populate {fr} Objet à peupler
	, @m.lcResult; && @ {en} Cumulative result {fr} Résultat (cumulatif)
	)
? m.lcResult


loObj = createobject('objectOfXML_Test_towBus') && 2015-03-19 http://support.west-wind.com/default.asp?Thread=4B00KYJP3&MsgId=4B00KYJP4
lcResult = ''
loTest.Test(oClone(m.loObj), cXMLofObject(m.loObj), m.loObj, @m.lcResult)
? m.lcResult

return m.loTest.Result()
endproc

* -----------------------------------------
define class objectOfXML_Test_towBus as custom && 2015-03-19 http://support.west-wind.com/default.asp?Thread=4B00KYJP3&MsgId=4B00KYJP4
		cLoggedInUser = "Fred"
		cConnectString = "SQLSTRINGCONNECT('DRIVER=SQL Server Native Client 11.0;SERVER=10.2.50.13;UID=lott;PWD=*******')"
		cMultiDataSet = ''
		nConnectionHandle = 0
		cDefaultShiftStartTime1 = "08:00AM"
		cDefaultShiftStartTime2 = "04:00PM"
		cPathDBC = "data\" && {fr} Changed this assignment because previous value was invalid - Lott - 03/12/2015
		tag = 'test' && property inherited from the class && 2018-01-10 thn -- {FiC V 2.26.1-beta.1} {en} added 
	enddefine

* ========================================
function oObjPropsPublic && {fr} objet avec les propriétés publiques d'un autre objet
lparameters oObj

local Result as object;
, success as Boolean;
, aProp[1];
, aPropRO[1];
, cProp as string;

Result = .null.
if vartype(m.oObj) == 'O' and aMembers(aProp, m.oObj, 0, 'G') > 0
	Result = createobject('Empty')
	for each cProp in aProp
		if !(.f.;
		 or PEMstatus(m.oObj, m.cProp, 1); && {fr} Read-only
		 or m.cProp == 'NAME';
		 )
			success = addproperty(m.Result, m.cProp, evaluate('m.oObj.' + m.cProp))
			assert m.success
		endif
	endfor
endif

return m.Result
endfunc

* ========================================
function cObjAddrNorm(tcObjAddr) && {fr} Adresse d'objet normalisée
return chrtran(strtran(m.tcObjAddr, '->', '.'), ' ', '')

* ========================================
function oPropsDefault && {fr} règle les propriétés d'un objet aux valeur par défaut définies par un autre objet
lparameters oTrgt, oDefault

local Result as object;
, aProp[1] as string;
, cProp as string;
, uProp as Variant;

Result = m.oTrgt
if vartype(m.Result) == 'O' and vartype(m.oDefault) == 'O' and aMembers(aProp, m.oDefault) > 0
	for each cProp in m.aProp
		uProp = evaluate('m.oDefault.' + m.cProp)
		if !lProperty(m.oTrgt, m.cProp) or vartype(evaluate('m.oTrgt.' + m.cProp), .t.) # vartype(m.uProp, .t.)
			addproperty(m.oTrgt, m.cProp, m.uProp)
		endif
	endfor
endif

return m.Result

* -----------------------------------------
procedure oPropsDefault_Test && {fr} test unitaire de oPropsDefault()

local loTest as abUnitTest of abDev.prg;
, oTrgt as object;
, oDefault as object;
, oResult as object;

loTest = newobject('abUnitTest', 'abDev.prg')

ga_Empty_Object_PropertyList(@m.oTrgt, 'prop1,prop2', ',', '1', 2)
ga_Empty_Object_PropertyList(@m.oDefault, 'prop2,prop3', ',', '2', .t.)
ga_Empty_Object_PropertyList(@m.oResult, 'prop1,prop2,prop3', ',', '1', '2', .t.)

loTest.Test(m.oResult, m.oTrgt, m.oDefault)

return m.loTest.Result()
endproc

* -----------------------------------------
function ab_Empty_Object_PropertyList as object && {fr} ga_Empty_Object_PropertyList() et retourne l'objet créé
lparameters	;
  properties; && {fr} up to 16 coma-separated properties
, t01,t02,t03,t04,t05,t06,t07,t08,t09,t10,t11,t12,t13,t14,t15,t15,t16

local obj, cParm

cParm = wcParms(pcount() - 1)

return iif(ga_Empty_Object_PropertyList(@m.obj, m.properties, ',' &cParm);
	, m.obj;
	, .null.;
	)
endfunc

* -----------------------------------------
procedure ab_Empty_Object_PropertyList_Test && {fr} test unitaire de ab_Empty_Object_PropertyList()

local loTest as abUnitTest of abDev.prg;
, oResult as object;

loTest = newobject('abUnitTest', 'abDev.prg')

oResult = createobject('Empty')
addproperty(m.oResult, 'test', 1)

loTest.Test(m.oResult, 'test', 1) && 0,1 ms

return m.loTest.Result()
endproc

* -----------------------------------------
function ab_Collection_ZeroBased_Object as object && {fr} ga_Collection_ZeroBased_Object() et retourne l'objet créé

local obj

return iif(ga_Collection_ZeroBased_Object(@m.obj), m.obj, .null.)
endfunc

* -----------------------------------------
function Sys1272(oControl) && {en} sys(1272) with the right object.Name case
local Sys1271, Result
Result = m.oControl.name
do while type('m.oControl.Parent.Name') == 'C'
	Result = m.oControl.parent.name + '.' + m.Result
	oControl = m.oControl.parent
enddo
return iif(m.oControl.baseclass == 'Form' and varSet(@m.Sys1271, sys(1271, m.oControl)) and vartype(m.Sys1271) == 'C';
	, chrtran(lower(justfname(m.Sys1271)), '.', '_') + substr(m.Result, at_c('.', m.Result));
	, m.Result;
	)
endfunc

* -----------------------------------------
function iBindEventFlag as integer && {fr} option (nFlags) d'un bindEvent()
lparameters oSrce, cEvent, oTrgt, cDelegate

local iBindEventFlag as integer;
, aa[1];
, bb[5];
, iRow as integer

iBindEventFlag = .null.

if aevents(aa, m.oSrce) > 0
	bb[1] = .f. && 1 .T. if second element is the event source, .F. if second element is the event handler
	bb[2] = m.oTrgt && 2 Event handler if you pass the event source to oEventObject
	bb[3] = m.cEvent && 3 Event
	bb[4] = m.cDelegate && 4 Delegate method
	bb[5] = .null. && 5 BindEvent( ) flags - do not search on this
	iRow = aLocate(@m.aa, @m.bb, .t.,, 3)
	iBindEventFlag = iif(m.iRow > 0;
		, m.aa[m.iRow, 5];
		, m.iBindEventFlag;
		)
endif

return m.iBindEventFlag
endfunc

* -----------------------------------------
function lEventBinded as Boolean && {en} a method or event of an object is binded
lparameters ;
  oSrce;
, cEvent;
, oTrgt; && @ [.null.] {en} if bind, target object
, cTrgt; && @ [.null.] {en} if bind, target method

store .null. to oTrgt, cTrgt

local aa[1], bb[5], i

bb = .null.
bb[1] = .f. && 1 .T. if second element is the event source, .F. if second element is the event handler
bb[3] = m.cEvent && 3 Event

return aevents(aa, m.oSrce) > 0;
	and varSet(@m.i, aLocate(@m.aa, @m.bb, .t.));
	and m.i > 0;
	and varSet(@m.oTrgt, m.aa[m.i, 2]); && 2 Event handler if you pass the event source to oEventObject
	and varSet(@m.cTrgt, m.aa[m.i, 4]); && 4 Delegate method
	and .t.

endfunc

* -----------------------------------------
function aMethod as string && {fr} Méthodes d'un objet
lparameters ;
  aMethod as string; && @ {en} Result Array
, oSrce as object; && {en} Object to be analyzed
, lEventsNo as Boolean; && [.F.]
, cFlags as string; && ['']

external array aMethod

local nMethod as integer; && {fr} Number of methods found
, nMember as integer;
, iMember as integer;
, cTypes as string;

nMethod = 0
nMember = aMembers(;
	m.aMethod;
	, m.oSrce;
	, 1; && {fr} Array contains the names of the properties of the object or class, as well as the methods and member objects. The resulting array is two-dimensional with the second column specifying what type of member is listed in the first column. The possible values for the second column are Property, Event, Method, or Object.
	, evl(m.cFlags, '');
	)
if m.nMember > 0
	cTypes = iif(lTrue(m.lEventsNo), 'm', 'EM')
	for iMember = m.nMember to 1 step -1
		if upper(left(m.aMethod[m.iMember, 2], 1)) $ m.cTypes
			nMethod = m.nMethod + 1
		else
			adel(m.aMethod, m.iMember)
		endif
	endfor
	if m.nMethod > 0
		aColDel(@m.aMethod, 2)
		dimension m.aMethod[m.nMethod]
	endif
endif

return m.nMethod
endfunc

* -----------------------------------------
function cPEMcased as string && {fr} Nom de Propriété, Evénement ou Méthode avec la casse définie dans _MemberData
lparameters ;
  oSrce as awFrm of aw.vcx;
, cPEM as string;
, oXMLDOM as MSXML.DOMdocument && [CreateObject('MSXML.DOMdocument')]

local cPEMcased as string;
, cPEM_ as string;
, cXML as string;
, laClass[1] as string;
, cClass as string;
, lClass as Boolean;
, lPEMcased as Boolean;
, oPEMcased as MSXML.IXMLDOMNode;

cPEMcased = evl(m.cPEM, .null.)

if vartype(m.oSrce) == 'O';
 and vartype(m.cPEM) == 'C';
 and PEMstatus(m.oSrce, m.cPEM, 5);
 and aclass(m.laClass, m.oSrce) > 0;

	cXML = iif(PEMstatus(m.oSrce, '_memberdata', 5), getPEM(m.oSrce, '_memberdata'), '')
	for each cClass in m.laClass
		lClass = .f.
		try
			lClass = PEMstatus(m.cClass, '_memberdata', 5)
		catch
		endtry
		cXML = m.cXML + iif(m.lClass, getPEM(m.cClass, '_memberdata'), '')
	endfor
	if !empty(m.cXML)

		oXMLDOM = iif(vartype(m.oXMLDOM) == 'O', m.oXMLDOM, createobject('MSXML.DOMdocument'))
		if m.oXMLDOM.loadxml('<VFPData>' + strtran(strtran(m.cXML, '<VFPData>'), '</VFPData>') + '</VFPData>')

			oPEMcased = m.oXMLDOM.documentElement.selectSingleNode(textmerge('//memberdata[@name = "<<Lower(m.cPEM)>>"]'))
		endif
	endif

	do case
	case vartype(m.oPEMcased) == 'O'
		cPEMcased = evl(m.oPEMcased.getAttribute('display'), m.cPEMcased)

	case lMethod(m.oSrce, m.cPEM)
		cPEM = proper(m.cPEM)
		cPEM = iif(left(m.cPEM, 1) == 'W' and !m.cPEM == 'When'; && {fr} FoxInCloud method
			, 'w' + substr(m.cPEM, 2);
			, m.cPEM;
			)
		cPEMcased = icase(; && {fr} user-friendly case
			left(m.cPEM, 5) == 'Mouse',; && {fr} Len('Mouse') = 5
				'Mouse' + proper(substr(m.cPEM, 6)),;
			m.cPEM == 'Uienable',; && {fr} The UIEnable event does not occur for pages when the form is initially activated
				'UIenable',;
				strtran(strtran(strtran(strtran(strtran(strtran(strtran(strtran(strtran(strtran(strtran(strtran(strtran(m.cPEM;
					, 'Before', 'Before', 1, -1, 1);
					, 'After', 'After', 1, -1, 1);
					, 'Row', 'Row', 1, -1, 1);
					, 'Col', 'Col', 1, -1, 1);
					, 'Change', 'Change', 1, -1, 1);
					, 'Focus', 'Focus', 1, -1, 1);
					, 'Click', 'Click', 1, -1, 1);
					, 'High', 'High', 1, -1, 1);
					, 'Low', 'Low', 1, -1, 1);
					, 'Unload', 'Unload', 1, -1, 1);
					, 'Press', 'Press', 1, -1, 1);
					, 'Form', 'Form', 1, -1, 1);
					, 'Callback', 'Callback', 1, -1, 1);
			)

	endcase
endif

return m.cPEMcased
endfunc

* ------------------------------------
procedure cPEMcased_Test && {fr} test unitaire de cPEMcased()

local loTest as abUnitTest of abDev.prg;
, oXMLDOM as MSXML.DOMdocument; && [CreateObject('MSXML.DOMdocument')]
, oSrce as awFrm of aw.vcx;
, cX as string;
, oDefault as abSet of abDev.prg;

loTest = newobject('abUnitTest', 'abDev.prg')
oXMLDOM = createobject('MSXML.DOMdocument') && {fr} procure un très léger gain d'environ .010 ms

oSrce  = newobject('awFrm', 'aw'+'.vcx') && {fr} évite d'embarquer aw.vcx dans le projet

loTest.Test('ActiveControl', m.oSrce, 'ActiveControl', m.oXMLDOM) && {fr} native property
loTest.Test('wPropSave', m.oSrce, 'wPropSave', m.oXMLDOM) && {fr} custom property

cX = home(1) + "Tools\AB\AW\Samples\FIC\classe\ficSample.vcx"
if file(m.cX)
	set classlib to (m.cX) additive
	oSrce = newobject('ficFrm', m.cX)
	loTest.Test('wPropSave', m.oSrce, 'wPropSave', m.oXMLDOM) && {fr} inherited property
	loTest.Test('Init_SrceCode', m.oSrce, 'Init_SrceCode', m.oXMLDOM)
endif

oDefault = abSet('default', home(1) + 'Tools\AB\AW\Samples\FIC\fictuto\progs\forms\')
cX = 'dataUpdate.scx'
if file(m.cX)
	do form (m.cX) name oSrce noshow
	loTest.Test('cursorRefresh', m.oSrce, 'cursorrefresh', m.oXMLDOM) && {fr} inherited property
endif

cX = 'keyPress.scx'
if file(m.cX)
	do form (m.cX) name oSrce noshow
	loTest.Test('showMessage', m.oSrce, 'showmessage', m.oXMLDOM) && {fr} inherited property
endif

return loTest.Result()
endproc

* ------------------------------------
function cAnchor && {en} .Anchor described
lparameters iAnchor

return Evl(cWords(', ';
	, Iif(BitTest(m.iAnchor, 0), 'Top Absolute', '');
	, Iif(BitTest(m.iAnchor, 1), 'Left Absolute', '');
	, Iif(BitTest(m.iAnchor, 2), 'Bottom Absolute', '');
	, Iif(BitTest(m.iAnchor, 3), 'Right Absolute', '');
	, Iif(BitTest(m.iAnchor, 4), 'Top Relative', '');
	, Iif(BitTest(m.iAnchor, 5), 'Left Relative', '');
	, Iif(BitTest(m.iAnchor, 6), 'Bottom Relative', '');
	, Iif(BitTest(m.iAnchor, 7), 'Right Relative', '');
	, Iif(BitTest(m.iAnchor, 8), 'Horizontal Fixed Size', '');
	, Iif(BitTest(m.iAnchor, 9), 'Vertical Fixed Size', '');
	), 'Top Left')

endfunc

* ------------------------------------
function oPxOf1Fx && {en} x and y multipliers when form is defined in foxels (.ScaleMode = 0)
lparameters oControl

local oPxOf1Fx, oForm

oForm = oFormIn(m.oControl)

if Vartype(m.oForm) == 'O'
	oPxOf1Fx = CreateObject('Empty')
	AddProperty(m.oPxOf1Fx, 'x', Iif(Empty(m.oForm.ScaleMode); && {en} Applies To: Form | _SCREEN | ToolBar && 2016-10-31 thn -- {FiC V 2.23.0-beta.1} {en} added for Foxels support
			, nPixOfFox(1, .F., m.oForm.FontName, m.oForm.FontSize, coFontStyle(m.oForm)); && foxels
			, 1; && pixels
			))
	AddProperty(m.oPxOf1Fx, 'y', Iif(Empty(m.oForm.ScaleMode); && {en} Applies To: Form | _SCREEN | ToolBar && 2016-10-31 thn -- {FiC V 2.23.0-beta.1} {en} added for Foxels support
			, nPixOfFox(1, .T., m.oForm.FontName, m.oForm.FontSize, coFontStyle(m.oForm)); && foxels
			, 1; && pixels
			))
	return m.oPxOf1Fx
else
	return .null.
endif
endfunc

* ------------------------------------
function oDSofForm as DataEnvironment && {en} Reference to the dataEvironment object of a form
lparameters oForm as Form

local oDSofForm as DataEnvironment;
, aa[1];
, iMember;
, oMember;

oDSofForm = .null.

if Vartype(m.oForm) == 'O'
	for iMember = 1 to aMembers(aa, m.oForm, 2)
		oMember = Evaluate('m.oForm.' + m.aa[m.iMember])
		if m.oMember.baseClass == 'Dataenvironment'
			oDSofForm = m.oMember
			exit
		endif
	endfor
endif

return m.oDSofForm
endfunc

* ------------------------------------
function lActivePage as Boolean && {en} A page is active in a pageframe
lparameters oPage as Page

local lActivePage as Boolean;
, iPage as Integer;
, oPgf as PageFrame;

return .T.;
 and loClass(m.oPage, 'page');
 and Type('m.oPage.Parent') == 'O';
 and varSet(@m.oPgf, m.oPage.Parent);
 and m.oPgf.ActivePage = m.oPage.PageOrder

endfunc

* ------------------------------------
function nTreeNodeDesc as Integer && {en} number of descendants of a treeView node
lparameters node as MSComctlLib.INode, tlRecurse

&& 2017-10-27 thn -- {FiC V 2.26.0-beta.1} {en} created

local result
result = 0

do while !IsNull(m.node)
	result = m.result;
		+ Iif(m.tlRecurse, 1, 0);
		+ iif(IsNull(m.node.child);
		, 0;
		, nTreeNodeDesc(m.node.Child, .T.);
		)
	node = Iif(m.tlRecurse, m.node.Next, .null.)
enddo

return m.result
endfunc
