* abOOP.prg
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
FUNCTION lContIn && Un objet se trouve dans un conteneur d'une classe donnée 
LPARAMETERS ;
  toObject; && Objet VFP
, tcContClass; && Classe(s) contenante
, toCont; && @ Classe(s) contenante

toCont = oContIn(m.toObject, m.tcContClass)

RETURN !IsNull(m.toCont)

* ------------------------------------
PROCEDURE lContIn_Test && test unitaire de lContIn()

LOCAL loTest AS abUnitTest OF abDev.prg;
, loCont AS Container

loTest = NewObject('abUnitTest', 'abDev.prg')

loCont = CreateObject('Container')
WITH loCont AS Container
	.AddObject('oOpg', 'OptionGroup')
	.oOpg.ButtonCount = 2
ENDWITH

m.loTest.Test(.T., m.loCont.oOpg.Buttons(2), 'Container')

RETURN m.loTest.Result()

* ========================================
FUNCTION oContIn && Conteneur d'une classe donnée où se trouve un objet
LPARAMETERS ;
	toObject,; && Objet VFP
	tcContClass && Classe(s) contenante

LOCAL loResult as Container, loParent as Container

loResult = .null.

IF Vartype(m.toObject) == 'O' AND Vartype(m.tcContClass) == 'C'

	loParent = m.toObject
	DO WHILE .T.

		IF loClass(m.loParent, m.tcContClass)
			loResult = m.loParent
			EXIT

		ELSE

			IF PemStatus(m.loParent, 'Parent', 5) AND Type('m.loParent.Parent') == 'O' && Vartype(m.loParent.Parent) ne marche pas [Parent n'est pas un objet]
				loParent = m.loParent.Parent
			ELSE
				EXIT
			ENDIF
		ENDIF
	ENDDO
ENDIF

RETURN m.loResult

* ------------------------------------
PROCEDURE oContIn_Test && test unitaire de oContIn()

LOCAL loTest AS abUnitTest OF abDev.prg;
, loCont AS Container

loTest = NewObject('abUnitTest', 'abDev.prg')

loCont = CreateObject('Container')
WITH loCont AS Container
	.AddObject('oOpg', 'OptionGroup')
	.oOpg.ButtonCount = 2
ENDWITH

m.loTest.Test(m.loCont, m.loCont, 'Container')
m.loTest.Test(m.loCont, m.loCont.oOpg.Buttons(2), 'Container')

RETURN m.loTest.Result()

* ========================================
FUNCTION oFormIn && Forme où se trouve un objet
LPARAMETERS toObject && Objet VFP

RETURN oContIn(m.toObject, 'Form')

* ========================================
FUNCTION lFormIn && Un objet est placé dans une forme
LPARAMETERS toObject && Objet VFP

RETURN NOT IsNull(oFormIn(m.toObject))

* ========================================
FUNCTION aListItems && Listbox|Combobox.List[] > array
LPARAMETERS ;
	taItems,; && @ Éléments de .List[]
	toList as Listbox && Objet Listbox ou ComboBox
EXTERNAL ARRAY taItems

LOCAL lnCol, liCol, liRow;
, llResult, lnResult && nombre d'éléments

&& modify command c:\test\test\Listbox_combobox.list.prg
&& pour supporter .Sorted, soit sauver dans l'ordre de .itemID, soit sauver les ID
&& .Sorted is only available if the RowSourceType property is set to 0 (None) or 1 (Value).

lnResult = .null.

llResult = aClear(@m.taItems)
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([First parameter should contain a reference to an array: <<cLitteral(m.taItems)>>]))
IF m.llResult

	llResult = loClass(m.toList, 'Listbox, Combobox')
	ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([Second parameter should contain a reference to a Listbox or ComboBox object: <<cLitteral(m.toList)>>]))
	IF m.llResult
	
		WITH m.toList as Listbox

			lnResult = .ListCount
			IF m.lnResult > 0

				lnCol = Max(Evl(.ColumnCount, 1), .BoundColumn)
				DIMENSION taItems[m.lnResult, m.lnCol]

				FOR liRow = 1 TO m.lnResult

					IF .T.;
					 AND m.liRow = m.lnResult;
					 AND Empty(.Value);
					 AND Empty(.ListItem[m.liRow, 1]);
					 AND Empty(.ListItem[m.liRow, .BoundColumn])
					 
					 	&& c'est un élément vide ajouté par VFP quand .Value n'est pas dans .List
					 	lnResult = m.lnResult - 1

					ELSE
						FOR liCol = 1 TO m.lnCol
							taItems[m.liRow, m.liCol] = .List[m.liRow, m.liCol]
						ENDFOR
					ENDIF
				ENDFOR
			ENDIF
		ENDWITH 
	ENDIF
ENDIF

RETURN m.lnResult

* ------------------------------------
PROCEDURE aListItems_Test && test unitaire de aListItems()

LOCAL loTest AS abUnitTest OF abDev.prg;
, loList as Listbox;
, liItem, lcItem;
, laItem[1]

loTest = NewObject('abUnitTest', 'abDev.prg')
loList = CreateObject('Listbox')

WITH m.loList as Listbox
	.ColumnCount = 2
	.BoundColumn = 2
	.Clear
	FOR liItem = 1 TO 100
		lcItem = Ltrim(Str(m.liItem))
		.AddItem(m.lcItem)
		.List[.NewIndex, 2] = m.lcItem + '_'
	ENDFOR
	.Value = '' && Valeur en dehors de la liste
ENDWITH
loTest.Test(100, @m.laItem, m.loList) && 100 x 2 = .2 ms
loTest.Assert(100, m.loList.ListCount)

WITH m.loList as Listbox
	.Clear()
	.AddItem('101')
	.List[.NewIndex, 2] = '102'
	.AddItem('103')
	.List[.NewIndex, 2] = '104'
	.Value = '104'
ENDWITH
loTest.Test(2, @m.laItem, m.loList)
loTest.Assert(["101","102","103","104"], cListOfArray(@m.laItem,,-1,.T.))

RETURN loTest.Result()

* ========================================
FUNCTION aItemsList && array > Listbox|Combobox.List[]
LPARAMETERS ;
	taItems,; && @ Éléments de .List[]
	toList as Listbox && Objet Listbox ou ComboBox
EXTERNAL ARRAY taItems

* modify command c:\test\test\Listbox_combobox.list.prg

LOCAL llResult as Boolean;
, loForm as Form, liDS as Integer, llDS as Boolean;
, lcAlias as String, lcField as String, llFldState as Boolean, lnFldState as Integer, luValue;
, liCol as Integer;
, liRow as Integer;
, lcElt as String;
, lnResult as Integer && nombre d'éléments

lnResult = .null.

llResult = ga_Type_IsArray(@m.taItems)
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([First parameter should contain a reference to an array: <<cLitteral(m.taItems)>>]))
IF m.llResult

	llResult = loClass(m.toList, 'Listbox, Combobox')
	ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([Second parameter should contain a reference to a Listbox or ComboBox object: <<cLitteral(m.toList)>>]))
	IF m.llResult
	
		loForm = oFormIn(m.toList)
		llDS = loClass(m.loForm, 'Form')
		if m.llDS
			liDS = Set("Datasession")
			set datasession to m.loForm.DataSessionId
		endif
	
		WITH m.toList as Listbox
		
			lnResult = Alen(m.taItems, 1)

			luValue = .Value
			if m.llDS
				lcField = JustField(.ControlSource, @m.lcAlias)
				llFldState = Used(m.lcAlias) and CursorGetProp("Buffering", m.lcAlias) > 1
				if m.llFldState
					lnFldState = getFldState(m.lcField, m.lcAlias)
					llFldState = Vartype(m.lnFldState) == 'N'
				endif
			endif

			.RowSourceType = 0 && None
			.Clear
			.ColumnCount = Alen(m.taItems, 2) && For a ComboBox or Listbox control, if you set ColumnCount to 0, the first column is displayed based on the RowSource property or on the items added with the AddItem method

			do case
			case laEmpty(@m.taItems)
				lnResult = 0

			case .ColumnCount <= 1
				for each lcElt in m.taItems
					.AddItem(Transform(m.lcElt)) && par sécurité
				endfor

			otherwise
				for liRow = 1 to Alen(m.taItems, 1)
					.AddItem(Transform(m.taItems[m.liRow, 1]))
					for liCol = 2 to .ColumnCount
						.List[.NewIndex, m.liCol] = Transform(m.taItems[m.liRow, m.liCol]) && The AddItem method always inserts a new row into a multicolumn ComboBox or Listbox. After a row has been inserted, columns in that row should be populated using the .List(.NewIndex, nColumn) syntax
					endfor
				endfor
			endcase

			.Value = m.luValue
			if m.llFldState
				SetFldState(m.lcField, m.lnFldState, m.lcAlias)
			endif
		endwith 
		
		if m.llDS
			set datasession to m.liDS
		endif
	endif
endif

return m.lnResult

* ------------------------------------
PROCEDURE aItemsList_Test && test unitaire de aItemsList()

LOCAL loTest AS abUnitTest OF abDev.prg;
, loList as Listbox;
, liRow, lcItem;
, liCol;
, laItem[100,2]

loTest = NewObject('abUnitTest', 'abDev.prg')
loList = CreateObject('Listbox')
WITH m.loList as Listbox
	.RowSourceType = 5 && before updating .RowSource, program must reset .RowSourceType to the proper value
	.ColumnCount = 5
	.BoundColumn = 2
ENDWITH

FOR liRow = 1 TO Alen(laItem, 1)
	for liCol = 1 to Alen(laItem, 2)
		laItem[m.liRow, m.liCol] = Padr(c2Words(m.liRow, '_', m.liCol), 7)
	endfor
ENDFOR
loTest.Test(100, @m.laItem, m.loList) && 100 x 2 x 7 = 1 ms en IDE
loTest.Assert(100, m.loList.ListCount)
loTest.Assert('1_2', Trim(m.loList.List[1,2]))
loTest.Assert('10_2', Trim(m.loList.List[10,2]))

FOR liRow = 1 TO Alen(laItem, 1)
	for liCol = 1 to Alen(laItem, 2)
		laItem[m.liRow, m.liCol] = Replicate(laItem[m.liRow, m.liCol], 10) && Replicate() pour tester si la longueur de la chaîne influence le résultat
	endfor
ENDFOR
loTest.Test(100, @m.laItem, m.loList) && 100 x 2 x 70 = 2 ms en IDE
loTest.Assert(100, m.loList.ListCount)

RETURN loTest.Result()

* ========================================
FUNCTION loCont && Un objet peut en contenir d'autres
LPARAMETERS toCont as Container && Objet supposé conteneur

RETURN .T.;
	and lMethod(m.toCont, 'AddObject'); && .AddObject() n'existe que dans les conteneurs ...
	and !PemStatus(m.toCont, 'AddObject', 4); && not user defined, donc native ...
	and !m.toCont.BaseClass == 'Olecontrol' && vu le 23/10/13 avec les contrôles DBItech

* ========================================
FUNCTION nObjectsCont && Nombre d'objets contenus dans un autre
LPARAMETERS toCont && Objet supposé contenant

* Si l'objet peut en contenir d'autres,
IF loCont(m.toCont)

	LOCAL lnResult
	WITH m.toCont AS Container

		lnResult = ICase(;
			.BaseClass == 'Pageframe',;
				.PageCount,;
			.BaseClass == 'Grid',;
				.ColumnCount,;
			.BaseClass == 'Formset',;
				.FormCount,;
			InList(.BaseClass, 'Optiongroup', 'Commandgroup'),;
				.ButtonCount,;
				.ControlCount;
			)
	ENDWITH
	RETURN m.lnResult
ELSE
	RETURN 0
ENDIF

* ========================================
FUNCTION oObjectCont && Objet contenu dans un autre d'après son index (sauf Grid)
LPARAMETERS ;
	toCont,; && Objet supposé contenant
	tnObject && N° d'objet dans la collection

LOCAL llResult, loResult && Objet contenu

loResult = .NULL.
llResult = .T.;
	AND Vartype(m.tnObject) == 'N';
	AND m.tnObject > 0;
	AND m.tnObject <= nObjectsCont(m.toCont)
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge("Invalid object number <<m.tnObject>> in <<cLitteral(m.toCont)>>"))
IF m.llResult

	WITH m.toCont

		LOCAL lcBaseClass
		lcBaseClass = Proper(.BaseClass)

		loResult = ICase(;
			m.lcBaseClass == 'Pageframe',;
				.Pages(m.tnObject),;
			m.lcBaseClass == 'Grid',;
				.Columns(m.tnObject),;
			m.lcBaseClass == 'Formset',;
				.Forms(m.tnObject),;
			InList(m.lcBaseClass, 'Optiongroup', 'Commandgroup'),;
				.Buttons(m.tnObject),;
				.Controls(m.tnObject);
			)
	ENDWITH
ENDIF

RETURN m.loResult

* ========================================
FUNCTION cSys1272thisForm && Adresse d'un objet dans thisForm
LPARAMETERS tuObject && Objet à analyser ou son adresse

LOCAL lcType, lnPeriod, lcResult, llResult

lcResult = Space(0)
lcType = Vartype(m.tuObject)
llResult = m.lcType $ 'CO'
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge("Invalid parameter : <<cLitteral(m.tuObject)>>"))
IF m.llResult

	llResult = m.lcType == 'C' OR lFormIn(m.tuObject)
	ASSERT m.llResult MESSAGE cAssertMsg(Textmerge("Object should be a form or contained in a form : <<cLitteral(m.tuObject)>>"))
	IF m.llResult

		lcResult = Iif(m.lcType == 'O', Sys(1272, m.tuObject), m.tuObject)

		lnPeriod = Atc('.', m.lcResult)
		lnPeriod = Iif(m.lnPeriod = 0, Len(m.lcResult), m.lnPeriod) + 1 && 0 si forme elle-même

		lcResult = c2Words('ThisForm', '.', Substr(m.lcResult, m.lnPeriod))
	ENDIF
ENDIF

RETURN m.lcResult

* ========================================
FUNCTION oPageIn && Page d'un pageFrame où se trouve un objet
LPARAMETERS ;
	toControl as Control
LOCAL loResult && Page où se trouve un objet
loResult = .NULL.

IF Vartype(m.toControl) == 'O'

	* Tabuler les parents de l'objet jusqu'au formulaire
	LOCAL ARRAY laParents[1]
	LOCAL lnParents, loParent as Object
	lnParents = 0
	loParent = m.toControl
	DO WHILE .T.
		
		loParent = m.loParent.parent
		lnParents = m.lnParents + 1
		DIMENSION laParents[m.lnParents]
		laParents[m.lnParents] = m.loParent
		
		IF Lower(m.loParent.BaseClass) == 'form'
			EXIT
		ENDIF
	ENDDO
	
	* Si au moins trois parents et l'avant-dernier parent est un pageframe
	IF m.lnParents > 2
		loParent = laParents[m.lnParents-1]
		IF Proper(m.loParent.baseClass) == 'Pageframe'

			* La page cherchée est son fils
			loResult = laParents[m.lnParents-2]
		ENDIF
	ENDIF
ENDIF

RETURN m.loResult

* ========================================
FUNCTION aoSiblings && Frères d'un objet dans un conteneur [basés sur une classe]
LPARAMETERS ;
	taSiblings,; && @ Frères d'un objet dans un conteneur
	toObject,; && Objet
	tcClass,; && [toutes] Classe
	tlTabIndex && [.F.] tabuler seulement les objets ayant la propriété TabIndex, classer par TabIndex croissant
EXTERNAL ARRAY taSiblings

LOCAL loParent, lnSibling, loSibling, llResult, lnResult && Nombre de frères trouvés
lnResult = 0

* Si les paramètres sont corrects
llResult = Type('taSiblings', 1) == 'A' AND Vartype(m.toObject) == 'O'
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge("At least one parameter is invalid: <<cLitteral(m.taSiblings)>>, <<cLitteral(m.toObject)>>"))
IF m.llResult

	* Si l'objet est dans un conteneur
	loParent = m.toObject.Parent
	llResult = loCont(m.loParent)
	ASSERT m.llResult MESSAGE cAssertMsg(Textmerge("Object <<cLitteral(m.toObject)>> should be in a containing object such as form, container, etc."))
	IF m.llResult

		tlTabIndex = Vartype(m.tlTabIndex) == 'L' AND m.tlTabIndex
		
		* Pour chaque objet frère
		FOR m.lnSibling = 1 TO nObjectsCont(m.loParent)
			loSibling = oObjectCont(m.loParent, m.lnSibling)

			IF NOT m.loSibling == m.toObject;
			 AND (Empty(m.tcClass) OR loClass(m.loSibling, m.tcClass));
			 AND (NOT m.tlTabIndex OR lProperty(m.loSibling, 'TabIndex'))
				
				* Ajouter au résultat
				lnResult = m.lnResult + 1
				IF m.tlTabIndex
					DIMENSION taSiblings[m.lnResult, 2]
					taSiblings[m.lnResult, 1] = m.loSibling
					taSiblings[m.lnResult, 2] = m.loSibling.TabIndex
				ELSE
					DIMENSION taSiblings[m.lnResult]
					taSiblings[m.lnResult] = m.loSibling
				ENDIF
			ENDIF
		ENDFOR
		
		IF m.tlTabIndex AND m.lnResult > 0
			Asort(taSiblings, 2)
		ENDIF
	ENDIF

	IF m.lnResult = 0
		aClear(@m.taSiblings)
	ENDIF
ENDIF

RETURN m.lnResult

* ========================================
FUNCTION oSibling && Frère d'un objet dans un conteneur selon une classe
LPARAMETERS ;
	toObject,; && Objet
	tcClass && Classe

LOCAL laSibling[1]

* Si l'objet a un frère et un seul selon la classe

RETURN Iif(aoSiblings(@m.laSibling, m.toObject, m.tcClass) = 1;
	, laSibling[1];
	, .NULL.;
	)

* ========================================
FUNCTION oSiblingTabIndex && Frère d'un object dans un conteneur selon un différentiel de tabindex
LPARAMETERS ;
	toObject,; && Objet
	tnTabIndex && Différentiel de TabIndex

IF Empty(m.tnTabIndex)
	RETURN m.toObject
ELSE

	LOCAL laSibling[1], lnSibling, liSibling, loSibling, loResult
	lnSibling = aoSiblings(@m.laSibling, m.toObject,, .T.)
	IF m.lnSibling > 0

		tnTabIndex = m.toObject.TabIndex + m.tnTabIndex
		loResult = .NULL.
		FOR liSibling = 1 TO m.lnSibling

			loSibling = laSibling[m.liSibling, 1]
			IF laSibling[m.liSibling, 2] = m.tnTabIndex

				IF m.loSibling.Enabled
					loResult = m.loSibling
					EXIT
				ELSE
					tnTabIndex = m.tnTabIndex + 1
				ENDIF
			ENDIF
		ENDFOR

		RETURN m.loResult

	ELSE
		RETURN .NULL.
	ENDIF
ENDIF

* ========================================
FUNCTION lClass && Une définition de classe existe
LPARAMETERS ;
	tcClass,; && Nom de la classe
	toClass,; && @ [.NULL.] Classe instanciée en retour
	tcClassLib,; && [''] Classothèque
	tiResult,; && @ Si la classe ne peut être instanciée, n° de l'erreur
	tcResult && @ Si la classe ne peut être instanciée, raison de l'échec

toClass = .NULL.
tcClassLib = Evl(m.tcClassLib, Space(0))
tcClassLib = Iif(Lower(JustExt(m.tcClassLib)) == 'prg', ForceExt(m.tcClassLib, 'fxp'), m.tcClassLib) && When possible, specify the compiled program name (.fxp) when a class is stored in a program file (.prg)
tiResult = 0

LOCAL llResult as Boolean;
, loSets as abSetsMaintain of abdev.prg;
, loException as Exception;
, loForm as Form

llResult = ga_Type_IsChar(m.tcClass, .T.)
IF m.llResult

*assert !Lower(m.tcClass) == 'baseform' && 4 Feb 2014

	tcClass = Alltrim(m.tcClass)
	loSets = NewObject('abSetsMaintain', 'abdev.prg')

	TRY
		TRY
			toClass = Iif(File(m.tcClassLib); && /!\ assez long pour les grilles avec classMember (plusieurs secondes)
				, NewObject(m.tcClass, m.tcClassLib, 0);
				, CreateObject(m.tcClass);
				)
*			toClass = NewObject(m.tcClass, m.tcClassLib, 0) && passing 0 to the cInApplication parameter allows you to create an instance of a class without raising initialization code (such as code in the Init, Load, Activate, and BeforeOpenTables events)
			&& THIS FEATURE IS NOT SUPPORTED IN RUNTIME APPLICATIONS
			&& Une page peut être instanciée en dehors d'un pageFrame
		CATCH TO loException WHEN InList(m.loException.ErrorNo;
				, 1435; && Object class is invalid for this container (erreur dans la documentation)
				, 1744; && Object class is invalid for this container
				, 1736; && Erreur d'instanciation
				, 1938; && Objet non contenu dans un Formulaire
				)
			TRY
				loForm = CreateObject('Form')
				IF File(m.tcClassLib)
					loForm.NewObject('lClass', m.tcClass, m.tcClassLib) && dans VFP 10, il faudrait que la Méthode newObject supporte (,,0)
				ELSE
					loForm.AddObject('lClass', m.tcClass)
				ENDIF
				loForm.SetAll('Visible', .T.)
				toClass = loForm.lClass
			CATCH TO loException
				THROW m.loException
			ENDTRY
		CATCH TO loException WHEN m.loException.ErrorNo = 1733 && The class definition specified in a CREATEOBJECT( ) function cannot be located.
			llResult = .F.
		ENDTRY
	CATCH TO loException
		llResult = .F.
	ENDTRY

	tiResult = ICase(m.llResult, 0, m.loException.ErrorNo = 2071, m.loException.UserValue.ErrorNo, m.loException.ErrorNo)
	tcResult = Iif(m.llResult, Space(0), cException(Iif(m.loException.ErrorNo = 2071, m.loException.UserValue, m.loException)))

ELSE
	tcResult = Textmerge(ICase(;
		cLangUser() = 'fr', [<<cLitteral(m.tcClass)>> est un nom de classe invalide],; && copy-paste this line to add another language support
												[<<cLitteral(m.tcClass)>> is an invalid class name];
	))
ENDIF

RETURN m.llResult

* ========================================
FUNCTION cClasses && Classes d'un objet depuis sa classe de base (uppercase)
LPARAMETERS toObject, tcSep && Objet, [' '] séparateur

IF Vartype(m.toObject) == 'O'
	LOCAL ARRAY laClass[1]
	AClass(laClass, m.toObject)
	aReverse(@m.laClass)
	tcSep = Iif(Vartype(m.tcSep) == 'C' AND Len(m.tcSep) > 0, m.tcSep, Space(1))
	RETURN Trim(cListOfArray(@m.laClass, m.tcSep,,,,,,.T.))
ELSE
	RETURN .NULL.
ENDIF

* ========================================
FUNCTION loClasses && /!\ 12/02/09 - dépréciée, utiliser loClass()
LPARAMETERS toObject, tcClasses && Objet, Classe(s)
RETURN loClass(m.toObject, m.tcClasses) && Rétro compatibilité

* ========================================
FUNCTION loEmpty && Un objet est de la classe Empty
LPARAMETERS toObject && Objet supposé
RETURN .T.;
	AND Vartype(m.toObject) == 'O';
	AND NOT lProperty(m.toObject, 'BaseClass');
	AND Empty(ComClassInfo(m.toObject))

* ========================================
FUNCTION loClass && Un objet hérite d'au moins une classe dans une liste
LPARAMETERS ;
	toObject,; && Objet supposé
	tcClasses && Classe(s) à satisfaire (ou) ; -class ne doit pas appartenir à cette classe

LOCAL loClass[1], laClass[1], lcClass

IF .T.;
 AND Vartype(m.toObject) == 'O';
 AND Vartype(m.tcClasses) == 'C';
 AND AClass(loClass, m.toObject) > 0;
 AND ALines(laClass, m.tcClasses, 5, ',', ';') > 0 && 1+4

	FOR EACH lcClass IN laClass
		IF Iif(Leftc(m.lcClass, 1) == '-';
			, Empty(Ascan(loClass, Ltrim(m.lcClass, '-'), 1, -1, 1, 7)); && 1+2+4 = case insensitive, exact on
			, Ascan(loClass, m.lcClass, 1, -1, 1, 7) > 0;
			)
			RETURN .T.
		ENDIF
	ENDFOR
ENDIF

RETURN .F.
endfunc

* ------------------------------------------
FUNCTION loClass_test

LOCAL loTest AS abUnitTest OF abDev.prg

loTest = NewObject('abUnitTest', 'abDev.prg')

loTest.Test(.T., NewObject('awlst', 'aw' + '.vcx'), 'Listbox') && évite d'embarquer aw.vcx dans un projet ab
loTest.Test(.T., NewObject('awfrm', 'aw' + '.vcx'), 'form') && évite d'embarquer aw.vcx dans un projet ab

RETURN loTest.Result()

* ====================
FUNCTION loBaseClass && Un objet VFP est de la classe de base spécifiée
LPARAMETERS ;
	toObject,; && Référence à l'objet
	tcBaseClass && Classe de base

RETURN ;
			Vartype(m.toObject) == 'O' ;
	AND	Vartype(m.tcBaseClass) == 'C' ;
	AND	PemStatus(m.toObject, 'BaseClass', 5) ;
	AND	Lower(m.toObject.BaseClass) == Lower(Alltrim(m.tcBaseClass))

* ====================
FUNCTION oClassCont && Premier objet VFP [d'une classe] dans un conteneur
LPARAMETERS ;
	toCont,; && Conteneur
	tcClasses,; && [toutes] Classe(s) filtrante(s)
	tlRecurse,; && [.T.] Récurser dans les conteneurs contenus
	tnConts && @ Nombre de niveaux de conteneurs

LOCAL ARRAY laObject[1]

RETURN Iif(aoClassCont(@m.laObject, m.toCont, m.tcClasses, m.tlRecurse, m.tnConts) > 0;
	, laObject[1];
	, .NULL.;
	)

* ====================
FUNCTION HTMLtabIndex && Collects .TabIndex for HTML
lparameters ;
  oTabIndex as GA_DICTIONARY_CLASS of abGA.prg; && @ key: Sys(1272, m.oCont) - value : Tabindex
, toForm as awFrm of aw.vcx

local success as Boolean;
, iTabIndex as Integer;

success = ga_Dictionary_object(@m.oTabIndex)
if m.success

	iTabIndex = 0
	success = HTMLtabIndex_(m.toForm, @m.oTabIndex, @m.iTabIndex)
endif

return m.success

*----------------------------------------------------
FUNCTION HTMLtabIndex_ && Collects .TabIndex for HTML - recursive
lparameters ;
  toCont as awCnt of aw.vcx;
, oTabIndex as GA_DICTIONARY_CLASS of abGA.prg;
, iTabIndex as Integer

local success as Boolean;
, aoCont[1];
, oCont as awTxt of aw.vcx;
, iTabIndex_ as Integer

success = .T.

if aoClassCont(@m.aoCont, m.toCont, .F.,,, .T.) > 0 and aColsDel(@m.aoCont, 2) > 0
	for each oCont in m.aoCont foxobject

		iTabIndex = m.iTabIndex + 1
		success = m.oTabIndex.add(Sys(1272, m.oCont), m.iTabIndex)
		if m.success and loCont(m.oCont)

			iTabIndex_ = Iif(m.oCont.BaseClass == 'Page';
				, m.oTabIndex.Item(Sys(1272, m.oCont.Parent));
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

oTest = NewObject('abUnitTest', 'abDev.prg')

do form (Addbs(DOS_AWSAMPLES) + 'fic\ficdemo\progs\forms\ecran_2') name oForm noshow
m.oTest.test(.T., @m.oTabIndex, m.oForm)
*suspend
return m.oTest.Result()

* ====================
FUNCTION aoClassCont && Objets VFP [d'une classe] dans un conteneur /!\ récursion descendante
LPARAMETERS ;
	taObjects,; && @ Objets trouvés
	toCont,; && Conteneur
	tcClasses,; && [toutes] Classe(s) filtrante(s)
	tlRecurse,; && [.T.] Récurser dans les conteneurs contenus
	tnConts,; && @ [0|1] Nombre de niveaux de conteneurs
	tlTabIndex,; && [.F.] tabuler seulement les objets ayant la propriété TabIndex et TabStop, classer par TabIndex croissant
	tlEnabled,; && [.F.] tabuler seulement les objets ayant la propriété TabIndex et Enabled
	tlAdd && Ajouter au tableau existant

EXTERNAL ARRAY taObjects
tnConts = Iif(Vartype(m.tnConts) == 'N' AND m.tnConts > 0, m.tnConts, 0)
tlTabIndex = Vartype(m.tlTabIndex) == 'L' AND m.tlTabIndex
tlEnabled = Vartype(m.tlEnabled) == 'L' AND m.tlEnabled

LOCAL llClass, lnObject, loObject, llResult, lnResult && Nombre d'objets trouvés

lnResult = 0

* Si Conteneur
llResult = loCont(m.toCont) && ASSERT nuisible à la récursion
IF m.llResult
	tnConts = m.tnConts + 1

	* Si tableau
	llResult = Type('taObjects', 1) == 'A'
	ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([le premier paramètre (<<cLitteral(@m.taObjects)>>) doit être un tableau]))
	IF m.llResult

		IF Vartype(m.plRecurse) == 'U' AND NOT (Vartype(m.tlAdd) == 'L' AND m.tlAdd)
			aClear(@m.taObjects)
			PRIVATE plRecurse
			plRecurse = .T.
		ENDIF

		llClass = Vartype(m.tcClasses) == 'C' AND NOT Empty(m.tcClasses)
		
		* Pour chaque objet contenu
		FOR lnObject = 1 TO nObjectsCont(m.toCont)
			loObject = oObjectCont(m.toCont, m.lnObject)
			
			* Si l'objet est de la classe cherchée, ajouter au résultat
			lnResult = Iif(!m.llClass OR loClass(m.loObject, m.tcClasses);
				, aoAppend(@m.taObjects, m.loObject, m.tlTabIndex, m.tlEnabled);
				, m.lnResult;
				)

			* Si l'objet est un conteneur et récursion demandée, récurser dedans
			lnResult = Iif(Pcount() < 4 OR !Vartype(m.tlRecurse) == 'L' OR m.tlRecurse;
				, Max(m.lnResult, aoClassCont(@m.taObjects, m.loObject, m.tcClasses, .T., @m.tnConts, m.tlTabIndex, m.tlEnabled, m.tlAdd)); && aoClassCont() ne travaille que si l'objet est un conteneur
				, m.lnResult;
				)
		ENDFOR
	ENDIF
ENDIF

IF m.lnResult > 0 AND m.tlTabIndex
	Asort(taObjects, 2)
ENDIF

RETURN m.lnResult

* ------------------------------------------
FUNCTION aoClassCont_Test

LOCAL loTest AS aoClassContTest OF aboop.prg, loForm AS Form, laObject[1]

loTest = CreateObject('aoClassContTest')

loTest.formOpen(@m.loForm)

loTest.test(54, @m.laObject, m.loForm) && toutes les classes

* aClear(@m.laObject) && pas de clear car additif
loTest.lSingleTest = .T. && additif, évite un C0005
loTest.test(54+5, @m.laObject, m.loForm, 'CheckBox',,,,,.T.) && filtré, additif

&& garbage collection
aClear(@m.laObject)
m.loForm.Release

RETURN loTest.Result()

	* ------------------------------
	DEFINE CLASS aoClassContTest as abUnitTest OF abDev.prg
	PROCEDURE FormOpen(toForm)
		DO FORM (Home() + "tools\ab\abmodule.scx") NAME m.toForm LINKED NOSHOW
	ENDDEFINE

* ====================
FUNCTION aoAppend && Ajoute un objet à un tableau d'objets
LPARAMETERS ;
	taObjects,; && @ Objets
	toObject,; && Objet
	tlTabIndex,; && [.F.] tabuler seulement les objets ayant la propriété TabIndex et TabStop
	tlEnabled && [.F.] tabuler seulement les objets ayant la propriété TabIndex et Enabled
EXTERNAL ARRAY taObjects

LOCAL lnResult; && Nombre d'objets
, llResult;
, lPage as Boolean;
, iTabIndex;
, iParent;
, oParent

llResult = Type('taObjects', 1) == 'A' AND Vartype(m.toObject) == 'O'
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge("Invalid parameters"))
IF m.llResult

	lnResult = Iif(laEmpty(@m.taObjects), 0, Alen(taObjects, 1))
	lPage = m.toObject.BaseClass = 'Page'

	IF .F.;
	 or !m.tlTabIndex;
	 or .T.;
		and (m.lPage or lProperty(m.toObject, 'TabIndex')); && Applies To: CheckBox | ComboBox | CommandButton | CommandGroup | Container Object | Control Object | EditBox | Form | Grid | Label | ListBox | OLE Bound Control | OLE Container Control | OptionButton | OptionGroup | PageFrame | _SCREEN | Spinner | TextBox
		and (m.lPage or lProperty(m.toObject, 'TabStop') and m.toObject.TabStop); && Does not apply to Page ! && Applies To: CheckBox | ComboBox | CommandButton | Container Object | Control Object | EditBox | Form | Grid | ListBox | OLE Bound Control | OLE Container Control | OptionButton | Page | PageFrame | _SCREEN | Spinner | TextBox
		and (!m.tlEnabled OR m.toObject.Enabled); && Applies To: CheckBox | Column | ComboBox | CommandButton | CommandGroup | Container | EditBox | Form | Grid | Image (Visual FoxPro) | Label (Visual FoxPro) | Line | ListBox | OLE Bound | OLE Container | OptionButton | OptionGroup | Page | PageFrame | _SCREEN | Shape | Spinner | TextBox | Timer | ToolBar
		and .T. && !loCont(m.toObject) && and (!lProperty(m.toObject, 'Visible') or m.toObject.Visible)

		lnResult = m.lnResult + 1

		IF m.tlTabIndex
			oParent = m.toObject
			iParent = 0
			iTabIndex = 0
			do while Vartype(m.oParent) == 'O'
				iTabIndex = m.oParent.TabIndex * 20^m.iParent + m.iTabIndex
				oParent = Iif(.T.;
				 and Type('m.oParent.Parent') == 'O';
				 and lProperty(m.oParent.Parent, 'TabIndex');
				 and (!lProperty(m.oParent.Parent, 'TabStop') or m.oParent.Parent.TabStop);
				 , m.oParent.Parent;
				 , .null.;
				 )
				iParent = m.iParent + 1
			enddo
			DIMENSION taObjects[m.lnResult, 2]
			taObjects[m.lnResult, 1] = m.toObject
			taObjects[m.lnResult, 2] = m.iTabIndex && Iif(m.lPage, 0, m.toObject.Tabindex)
		ELSE
			DIMENSION taObjects[m.lnResult]
			taObjects[m.lnResult] = m.toObject
		ENDIF
	ENDIF

	RETURN m.lnResult
ELSE

	RETURN 0
ENDIF

* ========================================
function cBaseClassOfParent && Classe de base du parent d'un objet s'il n'est pas orphelin
lparameters toObj

return Iif(Vartype(m.toObj) == 'O';
		, Iif(Type('m.toObj.Parent.BaseClass') == 'C';
			, m.toObj.Parent.BaseClass;
			, '';
			);
		, .null.;
		)

* ========================================
FUNCTION coFontStyle && Style de police d'après les propriétés 'Font...' d'un objet
LPARAMETERS toObject && Objet

LOCAL llResult, lcResult
lcResult = Space(0)

llResult = .T.;
 and Vartype(m.toObject) == 'O';
 AND PemStatus(m.toObject, 'FontName', 5)
IF m.llResult

	WITH m.toObject as Label
		lcResult = ;
			Iif(.FontBold, 'B', Space(0));
			+ Iif(.FontItalic, 'I', Space(0));
			+ Iif(.FontOutline, 'O', Space(0));
			+ Iif(.FontShadow, 'S', Space(0));
			+ Iif(.FontStrikethru, '-', Space(0));
			+ Iif(.FontUnderline, 'U', Space(0))
	ENDWITH
ENDIF

RETURN m.lcResult

* ========================================
FUNCTION oFontStyleSet && Règle les propriétés 'Font...' d'un objet d'après style de police
LPARAMETERS ;
	toObject,; && Objet
	tcFontStyle && Style de police
LOCAL llResult && Mise à jour OK

llResult = Vartype(m.toObject) == 'O';
 AND PemStatus(m.toObject, 'FontName', 5);
 AND Vartype(m.tcFontStyle) == 'C'
IF m.llResult
	tcFontStyle = Upper(Alltrim(m.tcFontStyle))

	WITH m.toObject as Label
		.FontBold = 'B' $ m.tcFontStyle
		.FontItalic = 'I' $ m.tcFontStyle
		.FontOutline = 'O' $ m.tcFontStyle
		.FontShadow = 'S' $ m.tcFontStyle
		.FontStrikethru = '-' $ m.tcFontStyle
		.FontUnderline = 'U' $ m.tcFontStyle
	ENDWITH
ENDIF

RETURN m.llResult

* ========================================
FUNCTION aoParents && Lignée ascendante d'un objet
LPARAMETERS ;
	taParents,; && @ Parent, grand parent, etc.
	toObject,; && Objet
	tlDown && [.F.] de l'ancêtre au père
EXTERNAL ARRAY taParents
tlDown = Vartype(m.tlDown) == 'L' AND m.tlDown

LOCAL loParent as Control, llResult, lnResult

lnResult = 0
llResult = Type('taParents', 1) == 'A' AND Vartype(m.toObject) == 'O'
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([Invalid Parameters(s) : array <<cLitteral(m.taParents)>> - object <<cLitteral(m.toObject)>>]))
IF m.llResult

	loParent = m.toObject
	DO WHILE .T.
		IF Type('m.loParent.Parent') == 'O'
			
			loParent = m.loParent.Parent
			lnResult = m.lnResult + 1
			DIMENSION taParents[m.lnResult]
			taParents[m.lnResult] = m.loParent
		ELSE
			EXIT
		ENDIF
	ENDDO
	IF m.lnResult > 0 AND m.tlDown

		LOCAL liParent, laParent[m.lnResult]
		FOR liParent = m.lnResult TO 1 STEP -1
			laParent[m.lnResult - m.liParent + 1] = taParents[m.liParent]
		ENDFOR
		Acopy(laParent, taParents)
	ENDIF
ENDIF

RETURN m.lnResult

* ========================================
FUNCTION oParentClass && Premier ascendant d'un objet dérivé d'une classe
LPARAMETERS ;
	toObject,; && Objet
	tcClass && Classe

LOCAL laParents[1], loParent, llResult, loResult

loResult = .NULL.
IF Vartype(m.toObject) == 'O'

	llResult = aoParents(@m.laParents, m.toObject) > 0
	ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([L'objet <<m.toObject.Name>> n'a aucun parent.]))
	IF m.llResult
	
		FOR EACH loParent IN laParents foxobject
			IF loClass(m.loParent, m.tcClass)
				loResult = m.loParent
				EXIT
			ENDIF
		ENDFOR
	ENDIF
ENDIF

RETURN m.loResult

* ========================================
FUNCTION oParentProp && Premier ascendant d'un objet doté d'une certaine propriété
LPARAMETERS ;
	toObject,; && Objet
	tcProp && Propriété

LOCAL laParents[1], loParent, llResult, loResult

loResult = .NULL.
llResult = Vartype(m.toObject) == 'O'
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([Objet attendu en premier paramètre <<cLitteral(m.toObject)>>]))
IF m.llResult

	llResult = aoParents(@m.laParents, m.toObject) > 0
	ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([L'objet <<m.toObject.Name>> n'a aucun parent.]))
	IF m.llResult
	
		FOR EACH loParent IN laParents foxobject
			IF lProperty(m.loParent, m.tcProp)
				loResult = m.loParent
				EXIT
			ENDIF
		ENDFOR
	ENDIF
ENDIF

RETURN m.loResult

* ========================================
FUNCTION locObject && Un objet en contient un autre
LPARAMETERS ;
	toCont,; && Objet contenant
	tcObject && Object contenu

RETURN loCont(m.toCont);
 AND Vartype(m.tcObject) == 'C';
 AND NOT Empty(m.tcObject);
 AND Type('m.toCont.' + m.tcObject) == 'O';
 AND Type('m.toCont.' + m.tcObject + '.baseClass') == 'C' && Après this.RemoveObject('cObject'), VarType(this.cObject) == 'O' (comportement VFP)


* ========================================
FUNCTION lMember && Un objet est doté d'un ou plusieurs membre(s)
LPARAMETERS ;
	toObject,; && Objet VFP
	tcMember,; && membre(s)
	toMember && @ membre

return .T.;
 and Vartype(m.toObject) == 'O';
 and Vartype(m.tcMember) == 'C';
 and Iif(',' $ m.tcMember or ';' $ m.tcMember;
 	, lMembers(m.toObject, m.tcMember);
 	, .T.;
		and PemStatus(m.toObject, m.tcMember, 5);
		and Upper(Left(PemStatus(m.toObject, m.tcMember, 3), 1)) == 'O';
	  and varSet(@m.toMember, Evaluate('m.toObject.' + m.tcMember));
	)
endfunc

* ========================================
FUNCTION lMembers && Un objet est doté d'un ou plusieurs membre(s)
LPARAMETERS ;
	toObject,; && Objet VFP
	tcMember && membre(s)

LOCAL llResult, laMember[1], lcMember

IF Vartype(m.toObject) == 'O';
 and Vartype(m.tcMember) == 'C';
 and ALines(laMember, Alltrim(m.tcMember), 5, ',', ';') > 0

	llResult = .T.

	for each lcMember IN m.laMember
		if !lMember(m.toObject, m.lcMember)
			llResult = .F.
			exit
		endif
	endfor
endif

return m.llResult
endfunc

	* ------------------------------------
	PROCEDURE lMember_Test && test unitaire de lMember()

	LOCAL loTest as abUnitTest OF abDev.prg;
	, oFrm as awFrm of aw.vcx;
	, oImg as awImg of aw.vcx;

	loTest = NewObject('abUnitTest', 'abDev.prg')
	oFrm = NewObject('awFrm', 'aw.vcx')
	if Vartype(m.oFrm) == 'O'
		
		loTest.Test(.T., m.oFrm, 'WaitPic', @m.oImg)
		loTest.Assert(.T., loClass(m.oImg, 'awImg'))
	endif

	return loTest.Result()
	endproc

* ========================================
FUNCTION lProperty && Un objet est doté d'une ou plusieurs propriété(s)
LPARAMETERS ;
	toObject,; && Objet VFP
	tcProp && propriété(s)

return .T.;
 and Vartype(m.toObject) == 'O';
 and Vartype(m.tcProp) == 'C';
 and Iif(',' $ m.tcProp or ';' $ m.tcProp;
 	, lProperties(m.toObject, m.tcProp);
 	, .T.;
		AND PemStatus(m.toObject, m.tcProp, 5);
		AND Upper(Left(PemStatus(m.toObject, m.tcProp, 3), 1)) == 'P';
	)
endfunc

* ========================================
FUNCTION lProperties && Un objet est doté d'une ou plusieurs propriété(s)
LPARAMETERS ;
	toObject,; && Objet VFP
	tcProp && propriété(s)

LOCAL llResult, laProp[1], lcProp

IF Vartype(m.toObject) == 'O';
 and Vartype(m.tcProp) == 'C';
 and ALines(laProp, Alltrim(m.tcProp), 5, ',', ';') > 0

	llResult = .T.

	for each lcProp IN m.laProp
		if !lProperty(m.toObject, m.lcProp)
			llResult = .F.
			exit
		endif
	endfor
endif

return m.llResult
endfunc

* ========================================
FUNCTION lPropHidden && Un objet est doté d'un propriété cachée [PemStatus(obj, prop, 2) ne retourne que les propriétés PROTECTED]
LPARAMETERS ;
	toObject,; && Objet VFP
	tcProp && propriété

LOCAL ARRAY laProp[1]

RETURN .T.;
	AND AMembers(laProp, m.toObject, 0, 'H')  > 0;
	AND Ascan(laProp, Alltrim(m.tcProp), 1, -1, 1, 7) > 0

* ========================================
FUNCTION lMethod && Un objet est doté d'une Méthode ou un Événement 
LPARAMETERS ;
	toObject as Form,; && Objet VFP
	tcMethod as String,; && méthode
	tcEventMethod as String && [any] 'M'ethod or 'E'vent

RETURN .T.;
	and Vartype(m.toObject) == 'O';
	and Vartype(m.tcMethod) == 'C';
	and NOT Empty(m.tcMethod);
	and lProperty(m.toObject, 'BaseClass'); && C'est un objet VFP
	and	PemStatus(m.toObject, m.tcMethod, 5); && tcMethod existe dans toObject
 	and	Upper(Left(PemStatus(m.toObject, m.tcMethod, 3), 1)) $ Evl(Left(Upper(Alltrim(Evl(m.tcEventMethod, ''))), 1), 'EM'); && tcMethod est un Événement ou une Méthode
 	and .T.

endfunc

* ------------------------------------
PROCEDURE lMethod_Test && test unitaire de lMethod()

LOCAL loTest as abUnitTest OF abDev.prg, o

loTest = NewObject('abUnitTest', 'abDev.prg')
	
if .T.;
 and varStore(@m.o, NewObject('form'));
 and Vartype(m.o) == 'O'
	
	loTest.Test(.T., m.o, 'Click')
	loTest.Test(.T., m.o, 'Click', 'Event')
	loTest.Test(.F., m.o, 'Click', 'method')
endif

RETURN loTest.Result()

* ========================================
FUNCTION lEvent && Un objet est doté d'un Événement
LPARAMETERS toObject AS form, tcEvent && Objet VFP && méthode

return lMethod(m.toObject, m.tcEvent, 'E')

endfunc


#if .F. && inutile
	local aa[1], i
 	and AMembers(m.aa, m.toObject, 1, 'N') > 0; && Native members && il faut vérifier que l'utilisateur n'a pas créé une méthode du même nom qu'un événement
 	and varStore(@m.i, Ascan(m.aa, m.tcEvent, 1, -1, 1, 15));
 	and m.i > 0;
 	and	Upper(Left(m.aa[m.i, 2], 1)) == 'E';
 	and .T.
#endif

* ------------------------------------
PROCEDURE lEvent_Test && test unitaire de lEvent()

LOCAL loTest as abUnitTest OF abDev.prg;
, cFile;
, o;

loTest = NewObject('abUnitTest', 'abDev.prg')

cFile = "lib\vfxobj.vcx" && avoids build errors
	
if .T.;
 and File(m.cFile);
 and varStore(@m.o, NewObject('cpickalternate', m.cFile, 0));
 and Vartype(m.o) == 'O'
	
	loTest.Test(.T., m.o, 'Click')
	loTest.Test(.F., m.o, 'Valid')
endif
		
RETURN loTest.Result()

* ========================================
FUNCTION lMethodImplemented && Une Méthode ou un Événement est implémenté(e) dans un objet /!\ SUPPORTE SEULEMENT LES CLASSES VISUELLES
LPARAMETERS ;
  toObject as Object; && Objet VFP
, tcMethod as String && méthode

LOCAL llResult

llResult = lMethod(m.toObject, m.tcMethod) && toObject has tcMethod
IF m.llResult

	llResult = .F.;
		OR Empty(m.toObject.ClassLibrary) AND m.toObject.Class == m.toObject.BaseClass;
		OR InList(Padr(Lower(JustExt(m.toObject.ClassLibrary)), 3), 'vcx', 'scx')

	ASSERT m.llResult MESSAGE cAssertMsg(ICase(;
			cLangUser() = 'fr',	[seules les classes visuelles sont supportées],; && copy-paste this line to add another language support
													[only visual classes are supported]; && Default: English
		))

	llResult = Iif(m.llResult;
		, PemStatus(m.toObject, m.tcMethod, 0); && tcMethod contient du code /!\ SUPPORTE SEULEMENT LES CLASSES VISUELLES
		, .NULL.; && don't know
		)
ENDIF

RETURN m.llResult

* ------------------------------------
procedure lMethodImplemented_Test && test unitaire de lMethodImplemented()

local loTest as abUnitTest OF abDev.prg

loTest = NewObject('abUnitTest', 'abDev.prg')

loTest.Test(.F., NewObject('form'), 'init') && PemStatus(,,0) ne marche pas avec une classe programmée PK ?
loTest.Test(.F., NewObject('form'), 'foo')

loTest.Test(.T., NewObject('awFrm', 'aw'+'.vcx'), 'init') && évite d'embarquer aw.vcx dans le projet
loTest.Test(.F., NewObject('awFrm', 'aw'+'.vcx'), 'wUserAction_Ante') && method exists but not  && évite d'embarquer aw.vcx dans le projet

return loTest.Result()
endproc

* ========================================
FUNCTION lBaseClass && Une classe est une classe de base VFP
LPARAMETERS tcClass && Classe de base

LOCAL laClass[1]
ALanguage(laClass, 3)

RETURN Ascan(laClass, m.tcClass, 1, -1, 1, 7) > 0

* ========================================
FUNCTION lBaseClassVisual && Une classe est une classe de base visuelle VFP
LPARAMETERS ;
	tcClass,; && Classe de base
	tlFormMemberClass && @ Classe non visuelle qui peut être membre d'un formulaire ou d'un conteneur membre d'un formulaire

LOCAL lcBaseClass, lcFormMemberClass, llResult

TEXT TO lcBaseClass NOSHOW FLAGS 1
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

TEXT TO lcFormMemberClass NOSHOW FLAGS 1
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

llResult = lInList(m.tcClass, Strtran(m.lcBaseClass, CRLF, ','))
tlFormMemberClass = m.llResult OR lInList(m.tcClass, Strtran(m.lcFormMemberClass, CRLF, ','))

RETURN m.llResult

* ========================================
FUNCTION oClone && /!\ recursive {en} Clones an object {fr} Clone un objet
LPARAMETERS toObj AS Collection && or whatever

LOCAL loResult AS Collection; && or whatever
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

IF Vartype(m.toObj) == 'O'

	llClass = Type('m.toObj.Class') == 'C'
	llClassLib = m.llClass and !Empty(m.toObj.ClassLibrary)
	
	loResult = Iif(m.llClass;
		, NewObject(m.toObj.Class, m.toObj.ClassLibrary);
		, CreateObject('Empty');
		)
	IF AMembers(laProp, m.toObj) > 0
		for each lcProp IN laProp

			llResult = .T.
			
			do case

			case varSet(@m.llUserDef, PemStatus(m.toObj, m.lcProp, 4)) and (.F.;
			 OR PemStatus(m.toObj, m.lcProp, 1); && read-only
			 OR PemStatus(m.toObj, m.lcProp, 2); && protected
			 OR m.llClass and !m.llUserDef and ',' + m.lcProp + ',' $ ',BASECLASS,CLASS,CLASSLIBRARY,CONTROLCOUNT,CONTROLS,NAME,OBJECTS,OBJECT,PARENT,PARENTCLASS,';
			 )

			case .T.;
			 and varSet(@m.llUserDef, m.llUserDef and !PemStatus(m.toObj, m.lcProp, 6)); && user defined in object and not in parent class if any
			 and varSet(@m.llModif, PemStatus(m.toObj, m.lcProp, 0)); && propriété modifiée
			 and varSet(@m.llArray, Type('m.toObj.' + m.lcProp, 1) == 'A');
			 and varSet(@m.luProp, Iif(m.llArray, .null., Evaluate('m.toObj.' + m.lcProp))); && and setStepOn(Vartype(m.luProp) == 'O')
			 and m.llUserDef;
			 and m.llArray;
			 and .T.

				lnRow = Alen(m.toObj.&lcProp, 1)
				lnCol = Alen(m.toObj.&lcProp, 2)
				llResult = .T.;
				 AND AddProperty(;
					  m.loResult;
					, m.lcProp + Textmerge(Iif(m.lnCol > 0, '[<<m.lnRow>>, <<m.lnCol>>]', '[<<m.lnRow>>]'));
					);
				 AND Acopy(m.toObj.&lcProp, m.loResult.&lcProp) > 0

			case m.llUserDef or Vartype(m.luProp) == 'O'

				llResult = AddProperty(;
					  m.loResult;
					, m.lcProp;
					, Iif(Vartype(m.luProp) == 'O';
						, oClone(m.luProp);
						, m.luProp;
						);
					)

			case m.llModif and m.llArray
				lnRow = Alen(m.toObj.&lcProp, 1)
				lnCol = Alen(m.toObj.&lcProp, 2)
				do case
				case Alen(m.toObj.&lcProp) = Alen(m.loResult.&lcProp)
				case Empty(m.lnCol)
					dimension m.loResult.&lcProp[m.lnRow]
				otherwise
					dimension m.loResult.&lcProp[m.lnRow, m.lnCol]
				endcase
				llResult = Acopy(m.toObj.&lcProp, m.loResult.&lcProp) > 0
			
			case m.llModif and !(m.llClassLib and luEqual(m.luProp, GetPem(m.toObj.Class, m.lcProp)))
				store m.luProp to ('m.loResult.' + m.lcProp)
			
			case m.llArray && PemStatus() does not detect for changes in specific array elements if the array is passed.
				llResult = Acopy(m.toObj.&lcProp, m.loResult.&lcProp) > 0

			endcase

			assert m.llResult
		ENDFOR
	ENDIF

	IF loBaseClass(m.toObj, 'Collection') AND m.toObj.Count > 0
		FOR liItem = 1 TO m.toObj.Count
			lcKey = m.toObj.GetKey(m.liItem)
			luProp = m.toObj.Item(m.liItem)
			luProp = Iif(Vartype(m.luProp) == 'O', oClone(m.luProp), m.luProp)
			llResult = Iif(Empty(m.lcKey);
				, m.loResult.add(m.luProp);
				, m.loResult.add(m.luProp, m.lcKey);
				)
			ASSERT m.llResult
		ENDFOR
	ENDIF
ENDIF

RETURN m.loResult

* -----------------------------------------
PROCEDURE oClone_Test && oClone() unit test

LOCAL loTest as abUnitTest OF abDev.prg, loObj
loTest = NewObject('abUnitTest', 'abDev.prg')

loObj = CreateObject('Empty')
oClone_Test_populate(loObj)
loTest.Test(m.loObj, m.loObj)

loObj = NewObject('Custom')
oClone_Test_populate(loObj)
loTest.Test(m.loObj, m.loObj)

loObj = NewObject('objectOfXML_Test_towBus', 'abOOP.prg') && As Custom
oClone_Test_populate(loObj)
loTest.Test(m.loObj, m.loObj)

RETURN loTest.Result()

	* -----------------------------------------
	FUNCTION oClone_Test_populate(loObj)
	
	AddProperty(m.loObj, 'string', 'test')
	AddProperty(m.loObj, 'boolean', .T.)
	AddProperty(m.loObj, 'numeric', 1)
	AddProperty(m.loObj, 'date', Date())
	AddProperty(m.loObj, 'NULL', .NULL.)
	AddProperty(m.loObj, 'array[2,2]')
		m.loObj.array[1] = .T.
		m.loObj.array[2] = 1
		m.loObj.array[3] = 'test'
		m.loObj.array[4] = CreateObject('Custom')
	AddProperty(m.loObj, 'object', CreateObject('empty'))
	AddProperty(m.loObj.object, 'string', 'test')
	
	return m.loObj

* ========================================
FUNCTION aClasses && Classes d'un conteneur et de ses objets contenus
LPARAMETERS ;
	taClass,; && @ classes
	toCont AS Container,; && Classe contenante ou non
	tlRecurse && [.F.] Récurser dans les conteneurs

EXTERNAL ARRAY taClass

LOCAL laObj[1], loObj, laClass[1], lnResult
lnResult = 0

IF aClear(@m.taClass)

	lnResult = AClass(m.taClass, m.toCont)
	IF loCont(m.toCont) AND aoClassCont(@m.laObj, m.toCont,, m.tlRecurse) > 0

		FOR EACH loObj IN m.laObj foxobject
			AClass(laClass, m.loObj)
			lnResult = aAppend(@m.taClass, @m.laClass, .T.)
		ENDFOR
	ENDIF
ENDIF

RETURN m.lnResult

* ========================================
FUNCTION aClassesClear && CLEAR CLASS sur un tableau de classes
LPARAMETERS taClass && @ classes
EXTERNAL ARRAY taClass

LOCAL lcClass, llResult

llResult = Type('taClass', 1) == 'A' AND NOT laEmpty(@m.taClass)
IF m.llResult
	FOR EACH lcClass IN taClass
		IF NOT lBaseClass(m.lcClass)
			CLEAR CLASS (m.lcClass)
		ENDIF
	ENDFOR
ENDIF

RETURN m.llResult

* ========================================
FUNCTION cXMLofObject as String && {en} Object linearized as XML {fr} Objet linéarisé en XML
LPARAMETERS ;
  toObj as Object; && {en} Source Object {fr} Objet source
, tcResult as String && @ {en} Cumulative result {fr} Résultat (cumulatif)

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

local lcResult as String; && XML, .null. if error
, cNullDisplay as String; && 2014-06-17 abSet can't be used because cXMLofObject() can be in a replace command - in a replace , .destroy() raises an error 'record is not locked'

cNullDisplay = Set("Nulldisplay")
set nulldisplay to && .NULL.

lcResult = cXMLofObject_(m.toObj, @m.tcResult)

if !Empty(m.cNullDisplay)
	set nulldisplay to (m.cNullDisplay)
endif

return m.lcResult

* ========================================
FUNCTION cXMLofObject_ as String && Objet linéarisé en XML - Privée de cXMLofObject()
&& /!\ récursion à partir de cXMLofObject_uValue()
LPARAMETERS ;
  toObj AS Collection; && par exemple
, tcResult && @ Résultat (cumulatif)

LOCAL lcResult as String; && XML, .null. if error
, llResult as Boolean;
, llEmpty;
, llFIC; && FoxInCloud object
, laProp[1], lnProp, liProp, lcProp, lcProp_, llProp;
, laPropPH[1]; && hidden and protected properties
, llPH, llwProp;
, luValue, lcType, lcFile, laValue[1], lnCol, llSafety;
, liItem, lcItem;

llResult = Vartype(m.toObj) == 'O'
IF m.llResult

	llEmpty = NOT Type('m.toObj.BaseClass') == 'C'

	llResult = .F.;
	 OR m.llEmpty;
	 OR .T.;
 	  and (.F.;
 	  	or !InList(m.toObj.BaseClass, 'Dataenvironment', 'Cursoradapter', 'Header');
 	  	or cResultAdd(@m.tcResult, Textmerge(ICase(;
				cLangUser() = 'fr',	[La classe de base '<<m.toObj.BaseClass>>' n'est pas supportée],; && copy-paste this line to add another language support
														[Base Class '<<m.toObj.BaseClass>>' is not supported];
				)));
			);
	  and (.F.;
 	  	or nObjectsCont(m.toObj) = 0; && pas un objet contenant ou aucun objet contenu
 	  	or cResultAdd(@m.tcResult, Textmerge(ICase(;
				cLangUser() = 'fr',	[Les objets membres de '<<m.toObj.Name>>' ne sont pas supportés pour l'instant],; && copy-paste this line to add another language support
														[Member objects in '<<m.toObj.Name>>' are not supported for now];
				)));
			);
	  and .T.
	IF m.llResult

		llFIC = lMethod(m.toObj, 'wPropGet') and lProperty(m.toObj, 'wcPropSave') && FoxInCloud object
		lcResult = Textmerge("<#o#><#c#><<Iif(m.llEmpty, '', m.toObj.Class)>></#c#><#cl#><<Iif(m.llEmpty, '', m.toObj.ClassLibrary)>></#cl#>")
		lnProp = AMembers(laProp, m.toObj, 0, 'GPH') && public, protected and hidden && without ", 0, 'GPH')", AMembers() omits protected and hidden properties
		IF m.lnProp > 0
			AMembers(laPropPH, m.toObj, 0, 'PH') && protected and hidden only

			FOR liProp = 1 TO m.lnProp
*				FOR EACH lcProp IN laProp && exactement le même temps de réponse

				IF .T.;
				 and varSet(@m.lcProp, Lower(m.laProp[m.liProp])); && Lower(m.lcProp)
				 and (m.llEmpty OR PemStatus(m.toObj, m.lcProp, 0)); && property has changed compared to its parent class && OK pour les propriétés protégées
				 and cXMLofObject_lPropSave(m.toObj, m.lcProp, m.llFIC);
					
					IF .T.;
					 and varSet(@m.llPH, Ascan(m.laPropPH, m.lcProp) > 0);
					 and varSet(@m.llwProp, m.llPH AND m.llFIC);
					 and varSet(@m.llProp, NOT m.llPH OR m.llwProp);
					 and varSet(@m.lcProp_, 'm.toObj.' + m.lcProp);
					 and (.F.;
					 	or m.llProp;
					 	or cResultAdd(@m.tcResult, Textmerge(ICase(;
							cLangUser() = 'fr',	[La propriété '<<m.lcProp>>' ne peut être traitée car elle est protégée],; && copy-paste this line to add another language support
																	[Property '<<m.lcProp>>' can't be processed because it's protected];
							)));
						)
					 	
					 	IF .F.;
					 	 or (m.llwProp and m.toObj.wPropArray(m.lcProp) or Type(m.lcProp_, 1) == 'A');
					 	 or !varSet(@m.luValue, cXMLofObject_uValue(;
								  Iif(m.llwProp;
								  , m.toObj.wPropGet(m.lcProp);
								  , Evaluate(m.lcProp_);
								  );
								, @m.lcType;
								, @m.tcResult;
								))

					 		IF m.llwProp
					 			m.toObj.wPropGet(m.lcProp, @m.laValue)
					 		ELSE
					 			lnCol = Alen(&lcProp_, 2) && m.toObj.&lcProp
					 			IF m.lnCol > 0
					 				DIMENSION laValue[Alen(&lcProp_, 1), m.lnCol]
					 			ELSE
					 				DIMENSION laValue[Alen(&lcProp_, 1)]
					 			ENDIF
						 		Acopy(&lcProp_, laValue)
					 		ENDIF

					 		llProp = Alen(m.laValue) < 65000
					 		IF .F.;
					 		 or m.llProp;
					 		 or cResultAdd(@m.tcResult, Textmerge(ICase(;
										cLangUser() = 'fr',	[La propriété '<<m.lcProp>>' ne peut être traitée car c'est un tableau comportant plus de 65.000 éléments],; && copy-paste this line to add another language support
																				[Property '<<m.lcProp>>' can't be processed because it's an array with more than 65,000 elements];
									)))
						 		FOR liItem = 1 TO Alen(m.laValue)
						 			IF Vartype(m.laValue[m.liItem]) == 'O'
						 				lcItem = Textmerge(ICase(;
												cLangUser() = 'fr',	[Les éléments de tableau de type objet ne sont pas supportés - propriété '<<m.lcProp>>', élément # <<m.liItem>>],; && copy-paste this line to add another language support
																						[Object array elements are not supported - property '<<m.lcProp>>', element # <<m.liItem>>];
											))
						 				ASSERT .F. MESSAGE cAssertMsg(m.lcItem)
						 				cResultAdd(@m.tcResult, m.lcItem)
						 				llProp = .F.
						 				exit
						 			ENDIF
						 		ENDFOR
						 		IF .T.;
						 		 and m.llProp;
						 		 and varSet(@m.lcType, 'A');
						 		 and varSet(@m.lcFile, Evl(m.lcFile, Addbs(Sys(2023)) + 'temp' + Cast(_VFP.processID as M) + '.mem'));
						 		 and varSet(@m.llSafety, Set("Safety") == 'ON');
						 		 and .T.
							 		if m.llSafety
							 			set safety OFF
							 		endif
							 		SAVE TO (m.lcFile) ALL LIKE laValue && The SAVE TO command does not support saving arrays exceeding 65,000 elements
							 		if m.llSafety
							 			set safety ON
							 		endif
							 		luValue = Strconv(FileToStr(m.lcFile), 13) && convertit laValue (binaire) en base 64
							 		delete file (m.lcFile)
						 		ENDIF
					 		ENDIF
					 	ENDIF
					ENDIF

					lcResult = m.lcResult + Iif(m.llProp;
						, Textmerge([<#p#><#n#><<m.lcProp>></#n#><#t#><<m.lcType>></#t#><#v#><<Iif(m.lcType $ 'DT', cL(m.luValue), m.luValue)>></#v#></#p#>]);
						, '';
						)
				ENDIF
			ENDFOR
		ENDIF
		IF loBaseClass(m.toObj, 'Collection') AND m.toObj.Count > 0
			FOR liItem = 1 TO m.toObj.Count
				luValue = cXMLofObject_uValue(m.toObj.Item(m.liItem), @m.lcType, @m.tcResult)
				lcResult = m.lcResult + Textmerge([<#item#><#key#><<m.toObj.getKey(m.liItem)>></#key#><#type#><<m.lcType>></#type#><#value#><<m.luValue>></#value#></#item#>])
			ENDFOR
		ENDIF
	endif
	
	assert m.llResult message cAssertMsg(m.tcResult)
ENDIF

RETURN Iif(m.llResult;
	, m.lcResult + '</#o#>';
	, .NULL.;
	)

endfunc

* -----------------------------------------
FUNCTION cXMLofObject_uValue(tuValue, tcType, tcResult) && [privée de cXMLofObject()] Valeur d'un type donné

tcType = Vartype(m.tuValue) && Vartype(m.tuValue, .T.)
tcType = Iif(m.tcType == 'N' and ga_Type_IsInteger(m.tuValue), 'I', m.tcType)

RETURN Iif(m.tcType == 'O';
	, Nvl(cXMLofObject_(m.tuValue, @m.tcResult), ''); && /!\ récursion
	, m.tuValue;
	)
endfunc

* -----------------------------------------
FUNCTION cXMLofObject_lPropSave(toObj, tcProp, llFiC) && [privée de cXMLofObject()] Propriété modifiable à sauvegarder
local lcProp as String
lcProp = ',' + Lower(m.tcProp) + ','
return .T.;
 and !PemStatus(m.toObj, m.tcProp, 1); && Read-only
 and !m.lcProp $ ',' + Chrtran(Lower('wcPropSave,_MemberData,Name'), ' ', '') + ','; && ,dataSession,dataSessionID
 and (!m.llFiC or m.lcProp $ ',' + Chrtran(Nvl(m.toObj.wcPropSave, ''), ' ', '') + ',');

endfunc

* -----------------------------------------
PROCEDURE cXMLofObject_Test && test unitaire de cXMLofObject()

LOCAL loTest as abUnitTest OF abDev.prg;
, loObj AS Collection, lcResult

loTest = NewObject('abUnitTest', 'abDev.prg')

loObj = CreateObject('Collection')

AddProperty(m.loObj, 'string', 'testValue')
m.loObj.Add('testItem1', 'testItem1')
m.loObj.Add('testItem2', 'testItem2')

AddProperty(m.loObj, 'object', CreateObject('Collection'))
AddProperty(m.loObj.object, 'string', 'testValue')
m.loObj.object.Add('testItem1', 'testItem1')
m.loObj.object.Add('testItem2', 'testItem2')

AddProperty(m.loObj.object, 'object', CreateObject('Custom'))
AddProperty(m.loObj.object.object, 'string', 'testValue')

AddProperty(m.loObj.object.object, 'object', CreateObject('Grid'))
AddProperty(m.loObj.object.object.object, 'string', 'testValue')
AddProperty(m.loObj.object.object.object, 'array[2]')
m.loObj.object.object.object.array[1] = 'el1'
m.loObj.object.object.object.array[2] = NewObject('awcst', 'aw' + '.vcx') && évite d'embarquer aw.vcx dans un projet ab

lcResult = ''
loTest.Test(.NULL., m.loObj, @m.lcResult) && .NULL.
? m.lcResult

AddProperty(m.loObj.object.object.object, 'array[66000]')
lcResult = ''
loTest.Test(.NULL., m.loObj, @m.lcResult) && .NULL.
? m.lcResult


loObj = NewObject('awfrm', 'aw' + '.vcx') && évite d'embarquer aw.vcx dans un projet ab
lcResult = ''
loTest.Test(.NULL., m.loObj, @m.lcResult) && .NULL.
? m.lcResult

loObj = NewObject('awgrd', 'aw' + '.vcx') && évite d'embarquer aw.vcx dans un projet ab
lcResult = ''
loTest.Test(.NULL., m.loObj, @m.lcResult) && .NULL.
? m.lcResult

loObj.ColumnCount = 2
lcResult = ''
loTest.Test(.NULL., m.loObj, @m.lcResult) && .NULL.
? m.lcResult

loTest.Test(.NULL., cXMLofObject_Test_oCastelec(), @m.lcResult) && .NULL.

RETURN loTest.Result()

* -----------------------------------------
PROCEDURE cXMLofObject_Test_Castelec
LPARAMETERS tnProp

LOCAL loResult, lnResult, lcResult

lnResult = Seconds()
loResult = cXMLofObject_Test_oCastelec(m.tnProp)
objectOfXML(cXMLofObject(m.loResult), @m.loResult, @m.lcResult)

? nSeconds(m.lnResult), Evl(m.lcResult, '')

* -----------------------------------------
PROCEDURE cXMLofObject_Test_oCastelec
LPARAMETERS tnProp

LOCAL liResult, loResult

loResult = CreateObject('Empty')
FOR liResult = 1 TO Evl(m.tnProp, 56) && 1800 propriétés (champs) pour le fomulaire vFacturas, mais 56 utiles
	AddProperty(;
		  m.loResult;
		, 'test' + Transform(m.liResult);
		, ICase(;
			m.liResult % 7 = 0, Date(),;
			m.liResult % 5 = 0, 1000,;
			m.liResult % 3 = 0, .T.,;
			m.liResult % 2 = 0, Replicate('a', 80),;
			.NULL.;
			);
		)
ENDFOR

RETURN m.loResult

* ========================================
FUNCTION lXMLofObject(tcXML, tcResult, lAssert) && cXMLofObject() a produit ce XML

LOCAL llResult, lcResult

llResult = .T.;
	AND Vartype(m.tcXML) == 'C';
	AND Leftc(m.tcXML, Lenc('<#o#>')) == '<#o#>';
	AND Rightc(m.tcXML, Lenc('</#o#>')) == '</#o#>'

= m.llResult OR .T.;
	 and varSet(@m.lcResult, Textmerge(ICase(;
			cLangUser() = 'fr',	[Ce XML est invalide, probablement car cXMLofObject() a échoué à le construire : <<m.tcXML>>],; && copy-paste this line to add another language support
													[This XML is invalid, probably because cXMLofObject() didn't build it successfully: <<m.tcXML>>];
		)));
	 and cResultAdd(@m.tcResult, m.lcResult)

if m.lAssert and !IsNull(m.tcXML)
	assert m.llResult message cAssertMsg(m.lcResult)
endif

tcXML = Iif(m.llResult;
	, Substrc(m.tcXML;
		, Len('<#o#>') + 1;
		, Len(m.tcXML) - Len('<#o#></#o#>');
		);
	, m.tcXML;
	)

RETURN m.llResult

* ========================================
FUNCTION objectOfXML as Object && {en} Object from its linearized XML produced by cXMLofObject() {fr} Objet à partir de sa représentation linéarisée en XML par cXMLofObject()
&& /!\ récursive
LPARAMETERS ;
	tcXML as String; && {en} XML produced by cXMLofObject() {fr} XML produit par cXMLofObject()
,	toResult as Object; && [NewObject(class, classlib)] {en} Object to populate {fr} Objet à peupler
, tcResult as String && @ {en} Cumulative result {fr} Résultat (cumulatif)

&& {en} Support scope: see abOOP.prg!cXMLofObject()
&& {fr} Détails du support : voir abOOP.prg!cXMLofObject()

LOCAL toResult as Object; && object, .null. if error
, llResult as Boolean;
, lcResult as String;
, lcXML as String; && copy required for 
, loRegExpOpen AS abRegExp OF abTxt.prg;
, loRegExpClose AS abRegExp OF abTxt.prg;
, lnObject as Integer, llObjects as Boolean;
, llNested, lnNested, liNestOpen, liNestOpen_, liNestClose; && objets inclus dans cet objet
, loNested AS Collection, aNested[1], nNested;
, lcClass, lcClassLib, loClass;
, llObject, llEmpty, llFiC;
, laProp[1], lcProp, llProp, luProp, luProp_;
, lcType, luValue, laValue[1], lcFile;
, liItem, lcItem, lcKey

do case
case Empty(m.tcXML)
	llResult = .T.

case !lXMLofObject(@m.tcXML, @m.lcResult, .T.) && .T. : ASSERT m.llResult

otherwise
	
	lnNested = Occurs('<#o#>', m.tcXML) && au moins une des propriétés de l'objet contient un objet
	llNested = m.lnNested > 0
	llResult = NOT m.llNested OR m.lnNested = Occurs('</#o#>', m.tcXML)
	lcResult = Textmerge(ICase(;
		cLangUser() = 'fr',	[Ce XML comporte des balises '<#o#>|</#o#>' dépareillées : <<m.tcXML>>],; && copy-paste this line to add another language support
												[Mismatched '<#o#>|</#o#>' delimiter(s) in XML: <<m.tcXML>>];
		))
	ASSERT m.llResult MESSAGE cAssertMsg(m.lcResult)
	IF m.llResult
	
		IF m.llNested

			loRegExpOpen  = abRegExp()
			loRegExpClose = abRegExp()

			llNested = .T.;
			 AND m.loRegExpOpen.setup ('<#o#>',  .F., .T., .F.);
			 AND m.loRegExpClose.setup('</#o#>', .F., .T., .F.);
			 AND varSet(@m.lnObject, m.loRegExpOpen.Execute(m.tcXML));
			 AND m.lnObject = m.loRegExpClose.Execute(m.tcXML);
			 AND varSet(@m.llObjects, m.lnObject > 1)

			ASSERT m.llNested && should always be OK

			loNested = CreateObject('Collection')
			FOR m.liNestOpen = 1 TO m.lnObject

				store m.liNestOpen to liNestClose, liNestOpen_
				IF m.llObjects and m.liNestOpen < m.lnObject

					* localiser la balise fermante
					DO WHILE .T.
						liNestOpen_ = m.liNestOpen_ + 1
						IF m.loRegExpOpen.Matches[m.liNestOpen_, 1] < m.loRegExpClose.Matches[m.liNestClose, 1] && position
							liNestClose = m.liNestClose + 1
							IF m.liNestClose = m.lnObject
								EXIT
							ENDIF
						ELSE
							EXIT
						ENDIF
					ENDDO
				ENDIF

				lnNested = 0; && longueur de la chaîne XML de l'objet
					+ m.loRegExpClose.Matches[m.liNestClose, 1];
					+ Lenc(m.loRegExpClose.Pattern);
					- m.loRegExpOpen.Matches[m.liNestOpen, 1]

				loNested.Add(Substrc(m.tcXML;
					, m.loRegExpOpen.Matches[m.liNestOpen, 1];
					, m.lnNested;
					))

				* Mémoriser le début et la longueur de la chaîne représentant l'objet
				nNested = Iif(laEmpty(@m.aNested), 0, Alen(m.aNested, 1)) + 1
				dimension aNested[m.nNested, 2]
				aNested[m.nNested, 1] = m.loRegExpOpen.Matches[m.liNestOpen, 1]
				aNested[m.nNested, 2] = m.lnNested
				
				liNestOpen = m.liNestClose
			endfor
			
			if m.nNested > 0
				for liNestOpen = m.nNested to 1 step -1
					tcXML = Stuffc(m.tcXML;
						, aNested[m.liNestOpen, 1];
						, aNested[m.liNestOpen, 2];
						, [#object#];
						)
				endfor
			endif
		endif

#IF .F.
o = CreateObject('empty')
AddProperty(o, 'test')
? PemStatus(o, 'test', 0) && .T.
&& Toutes les propriétés d'un objet Empty étant marquées modifiées, cXMLofObject() les a listées
#ENDIF

		* Recycler l'objet existant en razant ses propriétés ou créer un nouvel objet
		lcClass = Lower(StrExtract(m.tcXML, '<#c#>', '</#c#>'))
		lcClassLib = Lower(StrExtract(m.tcXML, '<#cl#>', '</#cl#>'))
		llEmpty = Empty(m.lcClass)

		llObject = .T.;
		 AND Vartype(m.toResult) == 'O';
		 AND (.F.;
		  OR .T.;
		   AND m.llEmpty;
		   AND Type('m.toResult.Class') == 'U';
		  OR .T.;
		   AND Type('m.toResult.Class') == 'C';
		   AND Lower(m.toResult.Class) == m.lcClass;
		   AND Lower(m.toResult.ClassLibrary) == m.lcClassLib;
		  )

		&& Voir ce qui est le plus rapide, remettre toutes les propriétés à leur valeur par défaut ou recréer un objet ...
		&& 2015-03-19 thn - si l'objet existe il vaut mieux le conserver car le supprimer/recréer exécuterait les méthodes .Destroy() et .Init() qui peuvent parfaitement se planter ...
		&& 2014-12-23 thn
		&& - objets empty : recréer systématiquement
		&& - objets dérivés d'une classe : 
		&&   . supprimer les propriétés éventuellement ajoutées à l'objet
		&&   . remettre les autres propriétés à la valeur de la classe,
		
		if m.llObject and !m.llEmpty
			try
				loClass = NewObject(m.lcClass, m.lcClassLib)
			catch
				loClass = NewObject(m.lcClass, m.lcClassLib, 0)
			endtry
		endif
		
		toResult = ICase(;
			m.llEmpty,; && objets empty : recréer systématiquement
				CreateObject('Empty'),;
			m.llObject,;
				m.toResult,;
				m.loClass;
			)

		llFIC = lMethod(m.toResult, 'wPropReset') and lProperty(m.toResult, 'wcPropSave') && FoxInCloud object

#if .F.
toResult = CreateObject('relation')
lcProp = 'test'
? AMembers(aa, m.toResult, 0, 'GPH')
AddProperty(m.toresult, m.lcprop, 'test')
? AMembers(aa, m.toResult, 0, 'GPH')
? PemStatus(m.toResult, m.lcProp, 4) && .T.
? PemStatus(m.toResult, 'Class', 4) && .F.
suspend
#endif

		IF m.llObject; && un objet a été passé
		 and !m.llEmpty;
		 and AMembers(laProp, m.toResult, 0, 'GPH') > 0

			FOR EACH lcProp IN laProp
				= .F.;
				 	or .T.;
				 		and !PemStatus(m.toResult, m.lcProp, 4); && not user defined
				 		and ',' + m.lcProp + ',' $ ',BASECLASS,CLASS,CLASSLIBRARY,CONTROLCOUNT,CONTROLS,NAME,OBJECTS,OBJECT,PARENT,PARENTCLASS,';
				 	or .T.;
				 		and PemStatus(m.toResult, m.lcProp, 4); && custom property ...
				 		and !PemStatus(m.toResult, m.lcProp, 6); && ... added to the object (not inherited from the class)
				 		and RemoveProperty(m.toResult, m.lcProp);
				 	or PemStatus(m.toResult, m.lcProp, 1); && Read-only
				 	or .T.; && and setStepOn(Lower(m.lcProp) == 'keysort')
					 and PemStatus(m.toResult, m.lcProp, 0); && modified
					 and varSet(@m.luProp, GetPem(m.toResult, m.lcProp));
					 and varSet(@m.luProp_, GetPem(m.loClass, m.lcProp)); && GetPem(m.toResult.Class, m.lcProp)
					 and !luEqual(m.luProp, m.luProp_); && Propriété changée par rapport à la classe
					 and Iif(PemStatus(m.toResult, m.lcProp, 2); && protected property
						, Iif(m.llFiC;
							, m.toResult.wPropReset(m.lcProp);
							, .F.;
							);
						, AddProperty(m.toResult, m.lcProp, Iif(Vartype(m.luProp_) == 'O'; && sets property to value in class
							, oClone(m.luProp_);
							, m.luProp_;
							)));
						)
			ENDFOR
		ENDIF
		
		* Restaurer les propriétés sauvées par cXMLofObject()
		IF 0 < aStrExtract(@m.laProp, m.tcXML, '<#p#>', '</#p#>')

			liNestOpen = 0
			FOR EACH lcProp IN laProp

				lcType = StrExtract(m.lcProp, '<#t#>', '</#t#>')
				luValue = StrExtract(m.lcProp, '<#v#>', '</#v#>')
				lcProp = StrExtract(m.lcProp, '<#n#>', '</#n#>') && en dernier car m.lcProp est recyclée ...
				llProp = .F.;
				 OR NOT lProperty(m.toResult, m.lcProp);
				 OR NOT (.F.;
					OR PemStatus(m.toResult, m.lcProp, 1); && Read-Only
					OR PemStatus(m.toResult, m.lcProp, 2); && Protected
					);
				 OR m.llFiC && en dernier!
				lcProp = Iif(m.llProp, m.lcProp, ICase(;
					cLangUser() = 'fr',	[La propriété '<<m.lcProp>>' ne peut être restaurée car elle est protégée ou en lecture seule],; && copy-paste this line to add another language support
															[Property '<<m.lcProp>>' can't be restored because it's protected or read-only];
					))
				= m.llProp OR cResultAdd(@m.lcResult, m.lcProp)
				ASSERT m.llProp MESSAGE cAssertMsg(m.lcProp)

				DO CASE

				CASE NOT m.llProp

				CASE m.lcType == 'C'

					&& la valeur est déjà dans le bon type
					AddProperty(;
						  m.toResult;
						, m.lcProp;
						, m.luValue;
						)

				CASE m.lcType == 'A'
					
			 		llSafety = Set("Safety") == 'ON'
			 		if m.llSafety
			 			set safety OFF
			 		endif
			 		lcFile = Evl(m.lcFile, Addbs(Sys(2023)) + 'temp' + Cast(_VFP.processID as M) + '.mem')
			 		StrToFile(Strconv(m.luValue, 14), m.lcFile) && 14: Converts base64 encoded data in cExpression to original unencoded data.
			 		if m.llSafety
			 			set safety ON
			 		endif
			 		aClear(@m.laValue)
			 		restore from (m.lcFile) additive
			 		delete file (m.lcFile)
			 		AddProperty(m.toResult, m.lcProp + Textmerge(Iif(Alen(m.laValue, 2) > 0;
			 				, '[<<Alen(m.laValue, 1)>>, <<Alen(m.laValue, 2)>>]';
			 				, '[<<Alen(m.laValue)>>]';
			 				)))
			 		Acopy(m.laValue, m.toResult.&lcProp)

				CASE m.lcType != 'O'
					AddProperty(;
						  m.toResult;
						, m.lcProp;
						, uValue(m.luValue, m.lcType);
						)

				OTHERWISE

					llResult = m.luValue == [#object#]
					lcResult = Textmerge(ICase(;
						cLangUser() = 'fr',	[La propriété de type objet '<<m.lcProp>>' n'a pas pu être restaurée],; && copy-paste this line to add another language support
																[Object property '<<m.lcProp>>' could not be restored];
						))
					ASSERT m.llResult MESSAGE cAssertMsg(m.lcResult)
					IF m.llResult
						liNestOpen = m.liNestOpen + 1
						luValue = objectOfXML(; && /!\ récursion
							  m.loNested.Item(m.liNestOpen);
							, Iif(m.llObject and lProperty(m.toResult, m.lcProp);
								, Evaluate('m.toResult.' + m.lcProp);
								, CreateObject('Empty');
								);
							)
					ELSE
						EXIT
					ENDIF
					AddProperty(;
						  m.toResult;
						, m.lcProp;
						, m.luValue;
						)
				ENDCASE
			ENDFOR
		ENDIF

		* Si Collection, restaurer ses membres
		IF m.llResult;
		 AND loBaseClass(m.toResult, 'Collection');
		 AND '<#item#>' $ m.tcXML
		 
			loRegExpOpen  = Iif(Vartype(m.loRegExpOpen)  == 'O', m.loRegExpOpen,  abRegExp())
			loRegExpClose = Iif(Vartype(m.loRegExpClose) == 'O', m.loRegExpClose, abRegExp())

			llResult = .T.;
			 AND m.loRegExpOpen.setup('<#item#>', .F., .T., .F.);
			 AND m.loRegExpClose.setup('</#item#>', .F., .T., .F.);
			 AND m.loRegExpOpen.Execute(m.tcXML) = m.loRegExpClose.Execute(m.tcXML)
			lcResult = Textmerge(ICase(;
				cLangUser() = 'fr',	[Ce XML comporte des balises '<#item#>|</#item#>' dépareillées : <<m.tcXML>>],; && copy-paste this line to add another language support
														[Mismatched '<#item#>|</#item#>' delimiter(s) in XML: <<m.tcXML>>];
				))
			ASSERT m.llResult MESSAGE cAssertMsg(m.lcResult)
			IF m.llResult

			 	toResult.Remove(-1) && If you pass a value of -1, Visual FoxPro removes all items in the collection.
			 	liNestOpen = 0
			 	FOR liItem = 1 TO m.loRegExpOpen.nMatches

			 		lcItem = Substrc(m.tcXML;
						, m.loRegExpOpen.Matches[m.liItem, 1];
						, 0;
							+ m.loRegExpClose.Matches[m.liItem, 1];
							+ Lenc(m.loRegExpClose.Pattern);
							- m.loRegExpOpen.Matches[m.liItem, 1];
						)
					lcKey = StrExtract(m.lcItem, '<#key#>', '</#key#>')
					lcType = StrExtract(m.lcItem, '<#type#>', '</#type#>')
					luValue = StrExtract(m.lcItem, '<#value#>', '</#value#>')
					IF m.lcType == 'O'

						llResult = m.luValue == [#object#]
						lcResult = Textmerge(ICase(;
							cLangUser() = 'fr',	[Erreur d'encodage XML d'un objet dans la collection '<<m.toResult.Name>>', clé : '<<m.lcKey>>', index : '<<m.liItem>>'],; && copy-paste this line to add another language support
																	[XML encoding error for an object in collection '<<m.toResult.Name>>', key: '<<m.lcKey>>', index: '<<m.liItem>>'];
							))
						ASSERT m.llResult MESSAGE cAssertMsg(m.lcResult)
						IF m.llResult
							liNestOpen = m.liNestOpen + 1
							luValue = objectOfXML(m.loNested.Item(m.liNestOpen))
						ELSE
							EXIT
						ENDIF
					ELSE
						luValue = uValue(m.luValue, m.lcType)
					ENDIF
					llResult = m.llResult AND Iif(Empty(m.lcKey);
						, m.toResult.Add(m.luValue);
						, m.toResult.Add(m.luValue, m.lcKey);
						)
					lcResult = Textmerge(ICase(;
						cLangUser() = 'fr',	[La valeur <<cLitteral(m.luValue)>> ne peut être ajoutée à la collection '<<m.toResult.Name>>' avec le clé '<<m.lcKey>>'],; && copy-paste this line to add another language support
																[Could not add <<cLitteral(m.luValue)>> to collection '<<m.toResult.Name>>' with key '<<m.lcKey>>'];
						))
					ASSERT m.llResult MESSAGE cAssertMsg(m.lcResult)
					IF NOT m.llResult
						EXIT
					endif
			 	ENDFOR
			ENDIF
		ENDIF
	ENDIF
endcase

= m.llResult OR cResultAdd(@m.tcResult, m.lcResult)

RETURN Iif(m.llResult OR Vartype(m.toResult) == 'O';
	, m.toResult;
	, .NULL.;
	)

* -----------------------------------------
PROCEDURE objectOfXML_Test && {en} objectOfXML() unit test {fr} test unitaire de objectOfXML()

*	CLEAR ALL

LOCAL loTest as abUnitTest OF abDev.prg;
, loObj as Collection;
, lcResult as String;

loTest = NewObject('abUnitTest', 'abDev.prg')

loObj = CreateObject('Collection')

AddProperty(m.loObj, 'string', 'testValue')
m.loObj.Add('testItem1', 'testItem1')
m.loObj.Add('testItem2', 'testItem2')

AddProperty(m.loObj, 'object', CreateObject('Collection'))
AddProperty(m.loObj.object, 'string', 'testValue')
m.loObj.object.Add('testItem1', 'testItem1')
m.loObj.object.Add('testItem2', 'testItem2')

AddProperty(m.loObj.object, 'object', CreateObject('Custom'))
AddProperty(m.loObj.object.object, 'string', 'testValue')

AddProperty(m.loObj.object.object, 'object', CreateObject('Empty'))
AddProperty(m.loObj.object.object.object, 'string', 'testValue')
AddProperty(m.loObj.object.object.object, 'array[2]')
m.loObj.object.object.object.array[1] = 'el1'
m.loObj.object.object.object.array[2] = 2.5

lcResult = ''
loTest.Test(oClone(m.loObj);
	, cXMLofObject(m.loObj); && {en} XML produced by cXMLofObject() {fr} XML produit par cXMLofObject()
	, m.loObj; && [NewObject(class, classlib)] {en} Object to populate {fr} Objet à peupler
	, @m.lcResult; && @ {en} Cumulative result {fr} Résultat (cumulatif)
	)
? m.lcResult


loObj = NewObject('objectOfXML_Test_towBus', 'abOOP.prg') && 2015-03-19 http://www.west-wind.com/wwThreads/default.asp?Thread=4B00KYJP3&MsgId=4B00KYJP4
lcResult = ''
loTest.Test(oClone(m.loObj), cXMLofObject(m.loObj), m.loObj, @m.lcResult)
? m.lcResult

return m.loTest.Result()
endproc

	* -----------------------------------------
	define class objectOfXML_Test_towBus As Custom && 2015-03-19 http://www.west-wind.com/wwThreads/default.asp?Thread=4B00KYJP3&MsgId=4B00KYJP4
		cLoggedInUser = "Fred"
		cConnectString = "SQLSTRINGCONNECT('DRIVER=SQL Server Native Client 11.0;SERVER=10.2.50.13;UID=lott;PWD=*******')"
		cMultiDataSet = ''
		nConnectionHandle = 0
		cDefaultShiftStartTime1 = "08:00AM"
		cDefaultShiftStartTime2 = "04:00PM"
		cPathDBC = "data\"	&& Changed this assignment because previous value was invalid - Lott - 03/12/2015
	enddefine

* ========================================
FUNCTION oObjPropsPublic
lparameters oObj

local result as Object;
, success as Boolean;
, aProp[1];
, aPropRO[1];
, cProp as String;

result = .null.
if Vartype(m.oObj) == 'O' and AMembers(aProp, m.oObj, 0, 'G') > 0
	result = CreateObject('Empty')
	for each cProp in aProp
		if !(.F.;
		 or PemStatus(m.oObj, m.cProp, 1); && Read-only
		 or m.cProp == 'NAME';
		 )
			success = AddProperty(m.result, m.cProp, Evaluate('m.oObj.' + m.cProp))
			assert m.success
		endif
	endfor
endif

return m.result

* ========================================
FUNCTION cObjAddrNorm(tcObjAddr) && Adresse d'objet normalisée
RETURN Chrtran(Strtran(m.tcObjAddr, '->', '.'), ' ', '')

* ========================================
FUNCTION nPixOfFox && Pixels of a Foxels measurement
LPARAMETER ;
  tnFoxels; && foxels to convert
, tlVertical; && [.F.] convert horizontal/vertical coordinates
, tcFontName; && [active output window]
, tnFontSize; && [active output window]
, tcFontStyle && [normal]

tlVertical = Iif(Vartype(m.tlVertical) == 'L' and m.tlVertical, 1, 6)
 
RETURN Evl(m.tnFoxels, 0) * Iif(Pcount() > 1;
	, Fontmetric(;
		  m.tlVertical;
		, Evl(m.tcFontName, Wfont(1));
		, Evl(m.tnFontSize, Wfont(2));
		, Evl(m.tcFontStyle, 'N');
		);
	, Fontmetric(m.tlVertical);
	)
 
* ========================================
FUNCTION nFoxOfPix && Foxels of a Pixels measurement
LPARAMETER ;
  tnPixels; && pixels to convert
, tlVertical; && [.F.] convert horizontal/vertical coordinates
, tcFontName; && [active output window]
, tnFontSize; && [active output window]
, tcFontStyle && [normal]

tlVertical = Iif(Vartype(m.tlVertical) == 'L' and m.tlVertical, 1, 6)

RETURN Evl(m.tnPixels, 0) / Iif(Pcount() > 1;
	, Fontmetric(;
		  m.tlVertical;
		, Evl(m.tcFontName, Wfont(1));
		, Evl(m.tnFontSize, Wfont(2));
		, Evl(m.tcFontStyle, 'N');
		);
	, Fontmetric(m.tlVertical);
	)

* ========================================
function oPropsDefault && règle les propriétés d'un objet aux valeur par défaut définies par un autre objet
lparameters oTrgt, oDefault

local result as Object;
, aProp[1] as String;
, cProp as String;
, uProp as Variant;

result = m.oTrgt
if Vartype(m.result) == 'O' and Vartype(m.oDefault) == 'O' and AMembers(aProp, m.oDefault) > 0
	for each cProp in m.aProp
		uProp = Evaluate('m.oDefault.' + m.cProp)
		if !lProperty(m.oTrgt, m.cProp) or Vartype(Evaluate('m.oTrgt.' + m.cProp), .T.) # Vartype(m.uProp, .T.)
			AddProperty(m.oTrgt, m.cProp, m.uProp)
		endif
	endfor
endif

return m.result

* -----------------------------------------
procedure oPropsDefault_Test && test unitaire de oPropsDefault()

LOCAL loTest as abUnitTest OF abDev.prg;
, oTrgt AS Object;
, oDefault AS Object;
, oResult AS Object;

loTest = NewObject('abUnitTest', 'abDev.prg')

ga_Empty_Object_PropertyList(@m.oTrgt, 'prop1,prop2', ',', '1', 2)
ga_Empty_Object_PropertyList(@m.oDefault, 'prop2,prop3', ',', '2', .T.)
ga_Empty_Object_PropertyList(@m.oResult, 'prop1,prop2,prop3', ',', '1', '2', .T.)

loTest.Test(m.oResult, m.oTrgt, m.oDefault)

return m.loTest.result()
endproc

* -----------------------------------------
function ab_Empty_Object_PropertyList as Object && ga_Empty_Object_PropertyList() et retourne l'objet créé
lparameters	;
  properties; && up to 16 coma-separated properties
, t01,t02,t03,t04,t05,t06,t07,t08,t09,t10,t11,t12,t13,t14,t15,t15,t16


local obj, cParm

cParm = wcParms(Pcount() - 1)

return Iif(ga_Empty_Object_PropertyList(@m.obj, m.properties, ',' &cParm);
	, m.obj;
	, .null.;
	)

endfunc

* -----------------------------------------
procedure ab_Empty_Object_PropertyList_Test && test unitaire de ab_Empty_Object_PropertyList()

LOCAL loTest as abUnitTest OF abDev.prg;
, oResult AS Object;

loTest = NewObject('abUnitTest', 'abDev.prg')

oResult = CreateObject('Empty')
AddProperty(m.oResult, 'test', 1)

loTest.Test(m.oResult, 'test', 1) && 0,1 ms

return m.loTest.result()
endproc

* -----------------------------------------
function ab_Collection_ZeroBased_Object as Object && ga_Collection_ZeroBased_Object() et retourne l'objet créé

local obj

return Iif(ga_Collection_ZeroBased_Object(@m.obj), m.obj, .null.)
endfunc

* -----------------------------------------
function Sys1272(oControl) && sys(1272) with the right object.Name case
local Sys1271, result
result = m.oControl.Name
do while Type('m.oControl.Parent.Name') == 'C'
	result = m.oControl.Parent.Name + '.' + m.result
	oControl = m.oControl.Parent
enddo
return Iif(m.oControl.BaseClass == 'Form' and varSet(@m.Sys1271, Sys(1271, m.oControl)) and Vartype(m.Sys1271) == 'C';
	, Chrtran(Lower(JustFname(m.Sys1271)), '.', '_') + Substr(m.result, At_c('.', m.result));
	, m.result;
	)
endfunc

* -----------------------------------------
function iBindEventFlag as Integer && 
lparameters oSrce, cEvent, oTrgt, cDelegate

local iBindEventFlag as Integer;
, aa[1];
, bb[5];
, iRow as Integer

iBindEventFlag = .null.

if AEvents(aa, m.oSrce) > 0
	bb[1] = .F. && 1 .T. if second element is the event source, .F. if second element is the event handler
	bb[2] = m.oTrgt && 2 Event handler if you pass the event source to oEventObject
	bb[3] = m.cEvent && 3 Event
	bb[4] = m.cDelegate && 4 Delegate method
	bb[5] = .null. && 5 BindEvent( ) flags - do not search on this
	iRow = aLocate(@m.aa, @m.bb, .T.,, 3)
	iBindEventFlag = Iif(m.iRow > 0;
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
bb[1] = .F. && 1 .T. if second element is the event source, .F. if second element is the event handler
bb[3] = m.cEvent && 3 Event

return AEvents(aa, m.oSrce) > 0;
	and varSet(@m.i, aLocate(@m.aa, @m.bb, .T.));
	and m.i > 0;
	and varSet(@m.oTrgt, m.aa[m.i, 2]); && 2 Event handler if you pass the event source to oEventObject
	and varSet(@m.cTrgt, m.aa[m.i, 4]); && 4 Delegate method
	and .T.
	
endfunc

* -----------------------------------------
function aMethod as String && Méthodes d'un objet
lparameters ;
  aMethod as String; && @ Result Array
, oSrce as Object; && Object to be analyzed
, lEventsNo as Boolean; && [.F.] Just 
, cFlags as String; && ['']

external array aMethod

local result as Integer; && Number of methods found
, nMember as Integer;
, iMember as Integer;
, cTypes as String;

result = 0
nMember = AMembers(;
	m.aMethod;
	, m.oSrce;
	, 1; && Array contains the names of the properties of the object or class, as well as the methods and member objects. The resulting array is two-dimensional with the second column specifying what type of member is listed in the first column. The possible values for the second column are Property, Event, Method, or Object. 
	, Evl(m.cFlags, '');
	)
if m.nMember > 0
	cTypes = Iif(Vartype(m.lEventsNo) == 'L' and m.lEventsNo, 'M', 'EM')
	for iMember = m.nMember to 1 step -1
		if Upper(Left(m.aMethod[m.iMember, 2], 1)) $ m.cTypes
			result = m.result + 1
		else
			Adel(m.aMethod, m.iMember)
		endif
	endfor
	if m.result > 0
		aColDel(@m.aMethod, 2)
		dimension m.aMethod[m.result]
	endif
endif

return m.result

endfunc

* -----------------------------------------
function cPEMcased as String && Nom de Propriété, Evénement ou Méthode avec la casse définie dans _MemberData
lparameters ;
  oSrce as awFrm of aw.vcx;
, cPEM as String;
, oXMLDOM as MSXML.DOMdocument && [CreateObject('MSXML.DOMdocument')]

local cPEMcased AS String;
, cPEM_ as String;
, cXML AS String;
, laClass[1] AS String;
, cClass AS String;
, lClass AS Boolean;
, lPEMcased AS Boolean;
, oPEMcased AS MSXML.IXMLDOMNode;

cPEMcased = Evl(m.cPEM, .null.)

if Vartype(m.oSrce) == 'O';
 and Vartype(m.cPEM) == 'C';
 and PemStatus(m.oSrce, m.cPEM, 5);
 and AClass(m.laClass, m.oSrce) > 0;

	cXML = Iif(PemStatus(m.oSrce, '_memberdata', 5), GetPem(m.oSrce, '_memberdata'), '')
	for each cClass in m.laClass
		lClass = .F.
		try
			lClass = PemStatus(m.cClass, '_memberdata', 5)
		catch
		endtry
		cXML = m.cXML + Iif(m.lClass, GetPem(m.cClass, '_memberdata'), '')
	endfor
	if !Empty(m.cXML)
		
		oXMLDOM = Iif(Vartype(m.oXMLDOM) == 'O', m.oXMLDOM, CreateObject('MSXML.DOMdocument'))
		if m.oXMLDOM.loadXML('<VFPData>' + Strtran(Strtran(m.cXML, '<VFPData>'), '</VFPData>') + '</VFPData>')

			oPEMcased = m.oXMLDOM.documentElement.selectSingleNode(Textmerge('//memberdata[@name = "<<Lower(m.cPEM)>>"]'))
		endif
	endif

	do case
	case Vartype(m.oPEMcased) == 'O'
		cPEMcased = Evl(m.oPEMcased.getAttribute('display'), m.cPEMcased)

	case lMethod(m.oSrce, m.cPEM)
		cPEM = Proper(m.cPEM)
		cPEM = Iif(Left(m.cPEM, 1) == 'W' and !m.cPEM == 'When'; && FoxInCloud method
			, 'w' + Substr(m.cPEM, 2);
			, m.cPEM;
			)
		cPEMcased = ICase(; && user-friendly case 
			Left(m.cPEM, 5) == 'Mouse',; && Len('Mouse') = 5
				'Mouse' + Proper(Substr(m.cPEM, 6)),;
			m.cPEM == 'Uienable',; && The UIEnable event does not occur for pages when the form is initially activated
				'UIenable',;
				Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(Strtran(m.cPEM;
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
procedure cPEMcased_Test && test unitaire de cPEMcased()

local loTest as abUnitTest OF abDev.prg;
, oXMLDOM as MSXML.DOMdocument; && [CreateObject('MSXML.DOMdocument')]
, oSrce as awFrm of aw.vcx;
, cX as String;
, oDefault as abSet of abDev.prg;

loTest = NewObject('abUnitTest', 'abDev.prg')
oXMLDOM = CreateObject('MSXML.DOMdocument') && procure un très léger gain d'environ .010 ms

oSrce  = NewObject('awFrm', 'aw'+'.vcx') && évite d'embarquer aw.vcx dans le projet

loTest.Test('ActiveControl', m.oSrce, 'ActiveControl', m.oXMLDOM) && native property
loTest.Test('wPropSave', m.oSrce, 'wPropSave', m.oXMLDOM) && custom property

cX = Home(1) + "Tools\AB\AW\Samples\FIC\classe\ficSample.vcx"
if File(m.cX)
	set classlib to (m.cX) additive
	oSrce = NewObject('ficFrm', m.cX)
	loTest.Test('wPropSave', m.oSrce, 'wPropSave', m.oXMLDOM) && inherited property
	loTest.Test('Init_SrceCode', m.oSrce, 'Init_SrceCode', m.oXMLDOM)
endif

oDefault = abSet('default', Home(1) + 'Tools\AB\AW\Samples\FIC\fictuto\progs\forms\')
cX = 'dataUpdate.scx'
if File(m.cX)
	do form (m.cX) name oSrce noshow
	loTest.Test('cursorRefresh', m.oSrce, 'cursorrefresh', m.oXMLDOM) && inherited property
endif

cX = 'keyPress.scx'
if File(m.cX)
	do form (m.cX) name oSrce noshow
	loTest.Test('showMessage', m.oSrce, 'showmessage', m.oXMLDOM) && inherited property
endif

return loTest.Result()
endproc
