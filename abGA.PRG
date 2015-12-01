* =====================================================
* (c) SARL Abaque, 66 rue Michel Ange - 75016 Paris - France
* contact@FoxInCloud.com - http://foxincloud.com/ - +33 9 53 41 90 90
* -----------------------------------------------------
* Ce logiciel est distribué sous licence MIT, tel quel, sans aucune garantie
* Il peut être utilisé et/ou redistribué sans restriction
* Toute modification doit être reversée à la communauté
* La présente mention doit être intégralement reproduite dans toute copie même partielle
* -----------------------------------------------------
* This software is distributed under the terms of a MIT-style license, AS IS, without any warranty 
* It may be used and/or distributed without restriction
* Any substantial improvement must be given for free to the community
* This permission notice shall be entirely included in all copies or substantial portions of the Software
* =====================================================
* (c) Gregory Adam 
* Last build: 10/05/2015 12:58:46 by ThierryNivelet

&& ga_Collection
* Gregory Adam 2010
*_______________________________________________________________________________
#include ga_.h

*_______________________________________________________________________________
function ga_Collection_Object(obj)

	return ga_Object_Create(@m.obj, GA_COLLECTION_CLASS)

endfunc

*_______________________________________________________________________________
function ga_Collection_ZeroBased_Object(obj)

	return ga_Object_Create(@m.obj, GA_COLLECTION_ZEROBASED_CLASS)

endfunc

*_______________________________________________________________________________
function ga_Collection_Naked_Object(obj)

	return ga_Object_Create(@m.obj, GA_COLLECTION_NAKED_CLASS )

endfunc
*_______________________________________________________________________________

*===============================================================================
*===============================================================================
*===============================================================================
define class GA_COLLECTION_ZEROBASED_CLASS	as GA_COLLECTION_CLASS

	FirstIndex =0
	LastIndex = 0
*_______________________________________________________________________________
function LastIndex_Access()
	
	return m.this.Count-1
endfunc
*_______________________________________________________________________________
function Item(n)

	nodefault
	
	return iif( ga_Type_IsInteger(m.n);
				, Collection::Item(m.n+1);
				, Collection::Item(m.n) ;
				)

endfunc 
*_______________________________________________________________________________
function GetKey(n)

	nodefault
	
	return	Iif( ;
				 ga_Type_IsInteger(m.n), Collection::GetKey(m.n+1), ;
				 Collection::GetKey(m.n) - 1;
				)
endfunc
*_______________________________________________________________________________
function Remove(n)
	
	nodefault
	
	return iif( ;
				 ga_Type_IsInteger(m.n), Collection::Remove(m.n+1), ;
				 Collection::Remove(m.n) ;
				)
				
endfunc
*_______________________________________________________________________________
function TryGetIndex(key, index)

	index = m.this.GetKey(m.key)	

	return (m.index > -1)  && zero based

endfunc
*_______________________________________________________________________________
enddefine
*===============================================================================
*===============================================================================
*===============================================================================

*===============================================================================
*===============================================================================
*===============================================================================
define class GA_COLLECTION_CLASS	as Collection
	
	FirstIndex =1
	LastIndex = 0
	
*_______________________________________________________________________________
function LastIndex_Access()
	
	return m.this.Count
endfunc
*_______________________________________________________________________________


protected function Init()

	local success
	success = true
	
	do case
	case !m.success
	
	case !DoDefault()
		assert false
		success = false
		
	endcase

	return m.success

endfunc
*_______________________________________________________________________________
protected function Destroy()

	=m.this.Clear()
	
	try
		=unbindevents(m.this)
	
	catch
		assert false
	endtry
	
	return DoDefault()
endfunc
*_______________________________________________________________________________
function Clear()
	
	=Collection::Remove(-1)

endfunc
*_______________________________________________________________________________
function IsKeyed()
	
	return !empty(m.this.Count) and !empty(len(Collection::getKey(1)))

endfunc
*_______________________________________________________________________________
function Empty()
	
	return empty(m.this.Count)
	
endfunc

*_______________________________________________________________________________
function Add(sValue, sKey)
	
	NODEFAULT
	
	local success, oException
	success = true
	
	do case
	case pcount() = 1
		
		try
			if(!DoDefault(m.sValue) )
				assert false
				success = false
			endif
		catch to oException
			assert false
			success = false
		endtry
		
	otherwise

		try
			if(!DoDefault(m.sValue, m.sKey) )
				assert false
				success = false
			endif
		catch to oException
			assert false
			success = false
		endtry
			
	endcase
	
	return m.success
	
endfunc
*_______________________________________________________________________________
function AddKeyValue(key, value)

	local success
	success = true
	
	do case
	case !m.success
	
	case !inlist(pcount(), 2)
		assert false
		success = false

	
	case !m.this.Add(m.value, m.key)
		assert false
		success = false
	
	endcase
	
	return m.success
	
endfunc
*_______________________________________________________________________________
function TryGetValue(ItemOrKey, sValue)

	local success
	success = true
	
	try
		sValue = m.this.Item(m.ItemOrKey)
	
	catch
		&& assert false
		success = false
	
	endtry
	
	return m.success
	
endfunc
*_______________________________________________________________________________
function TryGetIndex(key, index)

	index = m.this.GetKey(m.key)	

	return (m.index > 0) 
	
endfunc

*_______________________________________________________________________________
function AddArray(aa)
	external array aa

	local success
	success = true

	local i

	for i = 1 to Alen(m.aa)
	
		if( !m.this.Add(m.aa[m.i]) )

			assert false
			success = false
			exit
		endif
	endfor
	
	return m.success
	
endfunc

*_______________________________________________________________________________
function AddSeparatedString(s, sep, stringSplitOptions)

	local success
	success = true
	
	local aa[1], naa
	
	do case
	case !m.success
	
	case !inlist(pcount(), 3)
		assert false
		success = false
	
	case !ga_String_SplitToArray(@m.aa, @m.naa, m.s, m.sep, m.stringSplitOptions)
		assert false
		success = false
	
	case !this.AddArray(@m.aa)
		assert false
		success = false
	
	endcase
	
	return m.success
	
endfunc
*_______________________________________________________________________________
function InitWithSeparatedString(s, sep, stringSplitOptions)

	local success
	success = true
	
	do case
	case !m.success
	
	case !inlist(pcount(), 3)
		assert false
		success = false
	
	case !m.this.Clear()
		assert false
		success = false
	
	case !m.this.AddSeparatedString(@m.s, m.sep, m.stringSplitOptions)
		assert false
		success = false
	
	endcase
	
	return m.success
	
endfunc
*_______________________________________________________________________________
function AppendCollection(obj, reverse)

	local success
	success = true
	
	local i, item
	
	do case
	case !m.success
	
	case m.obj.Empty()
	
	case !m.reverse
		
		do case
		case !m.obj.IsKeyed()
			with m.this
				for each item in obj foxobject
					if( !.Add(m.item) )
						assert false
						success = false
						exit
					endif
				endfor
			endwith
			
		&& keyed
		otherwise
			with m.obj
			
				for i = .FirstIndex to .LastIndex
					
					if( !m.this.Add(.Item[m.i], .GetKey(m.i)) )
						assert false
						success = false
						exit
					endif
			
				endfor
			endwith
			
		endcase
	
	&& reverse
	otherwise
		do case
		case !m.obj.IsKeyed()
			with m.this
				for i = m.obj.LastIndex to m.obj.FirstIndex step -1
					if( !.Add(m.obj.item[m.i]) )
						assert false
						success = false
						exit
					endif
				endfor
			endwith
			
		&& keyed
		otherwise
			with m.obj
			
				for i = .LastIndex to .FirstIndex  step -1
					
					if( !m.this.Add(.Item[m.i], .GetKey(m.i)) )
						assert false
						success = false
						exit
					endif
			
				endfor
			endwith
			
		endcase
	endcase
	
	return m.success
	
endfunc
*_______________________________________________________________________________
function DeleteTail()

	do case
	
	case empty(m.this.Count)
		return false
	
	otherwise
		return Collection::Remove(m.this.Count)
	
	endcase
	
endfunc

*_______________________________________________________________________________
function ToArray(arrayName, nElements)

	external array arrayName
	
	local success
	success = true
	
	do case

	case !Type('arrayName', 1) == 'A'
		success = false
		assert false
		GA_ERROR_FUNCTION_ARGUMENT_INCORRECT
	
	otherwise
		
		dime arrayName[ max(1, m.this.Count) ]

		local content

		nElements = 0
		for each content in m.this foxobject
			nElements = m.nElements + 1
			arrayName[ m.nElements  ] = m.content 
		endfor
		
	endcase
	
	return m.success
endfunc
*_______________________________________________________________________________
function ToSeparatedString(sOut, sep)
	sep = Iif(ga_Type_IsChar(m.sep) and Lenc(m.sep) > 0, m.sep, ',')

	local success
	success = true
	
	do case
	case !m.success
	
	case !ga_Type_IsChar(@m.sep, false)
		assert false
		success = false
		GA_ERROR_FUNCTION_ARGUMENT_INCORRECT

	otherwise

		local s

		sOut = ''
		for each s in m.this foxobject
			sOut = m.sOut + m.sep + transf(m.s)
		endfor
		sOut = substr(m.sOut, 1 + len(m.sep))
	
	endcase
	
	return m.success
	
endfunc
*_______________________________________________________________________________
function Display()

	acti screen
	local key, value
	
	do case
	case !m.this.isKeyed()
		for each value in m.this foxobject
			? '(', m.value, ')'
		
		endfor
	
	otherwise
		local i
		for i = 1 to m.this.Count
			?'<' + Collection::getkey(m.i) + '> (', Collection::Item(m.i), ')'
		endfor
	
	endcase
		
endfunc
*_______________________________________________________________________________
enddefine
*===============================================================================
*===============================================================================
*===============================================================================


*===============================================================================
*===============================================================================
*===============================================================================
&& zero based, no keys
define class GA_COLLECTION_NAKED_CLASS as Collection

	protected 	BaseClass, Class, ClassLibrary, ;
				Comment, KeySort, Name, ;
				Parent, ParentClass, Tag

	protected AddProperty

	hidden	ReadExpression, ReadMethod, ;
			ResetToDefault, SaveAsClass, ;
			WriteExpression, WriteMethod

*_______________________________________________________________________________
function Add(value)

	nodefault
	return Collection::Add(m.value)

endfunc
*_______________________________________________________________________________
protected function Clear()
	
	=Collection::Remove(-1)

endfunc
*_______________________________________________________________________________
protected function Destroy()

	=m.this.Clear()
	
	try
		=unbindevents(m.this)
	catch
		assert false
	endtry
	
	return DoDefault()
endfunc
*_______________________________________________________________________________
protected function GetKey(n)

	nodefault
	return Collection::GetKey(m.n+1)
endfunc
*_______________________________________________________________________________
function InsertBefore(x, beforeIndex)

	do case
	case empty(m.beforeIndex)
		
		return iif( ;
					empty(m.this.Count), ;
					Collection::Add(m.x), ;
					Collection::Add(m.x, , 1) ;
					)
	case m.beforeIndex == m.this.Count
		return Collection::Add(m.x)
	
	otherwise
		return Collection::Add(m.x, , m.beforeIndex + 1)
	
	endcase
endfunc
*_______________________________________________________________________________
function Item(n)

	nodefault
	return Collection::Item(m.n+1) 

endfunc 
*_______________________________________________________________________________
protected function Remove(n)
	
	nodefault
	return Collection::Remove(m.n+1)
	
endfunc
*_______________________________________________________________________________
*_______________________________________________________________________________
enddefine
*===============================================================================
*===============================================================================
*===============================================================================
&& ga_Custom
* Gregory Adam 2012
*_______________________________________________________________________________
#include ga_.h
*_______________________________________________________________________________


*===============================================================================
*===============================================================================
*===============================================================================
define class GA_CUSTOM_CLASS as Custom
	
	ShowCreateDestroy = false
	
	nResult	= 0
	cResult = ''
	
	protected _nResult, _cResult
	_nResult = 0
	_cResult = ''
	
*_______________________________________________________________________________
protected function Init()

	local success
	success = true
	
	do case
	case !m.success
	
	case !DoDefault()
		assert false
		success = false
	
	case m.this.ShowCreateDestroy and !m.this.ga_Debug_Show(m.this.Name, 'Init')
		assert false
		success = false
		
	endcase
	
	return m.success
	
endfunc
*_______________________________________________________________________________
*_______________________________________________________________________________
protected function Destroy()
	
	= m.this.ShowCreateDestroy and m.this.ga_Debug_Show(m.this.Name, 'Destroy')
	return DoDefault()
endfunc
*_______________________________________________________________________________
function ga_Debug_Show(s1, s2)

	acti screen
	? transf(ttoc(datetime(),1), '@R ####/##/## ##:##:##'), ' ', m.s1, ' ', m.s2
endfunc
*_______________________________________________________________________________
protected function SetResult(n, s)
	
	this._nResult = m.n
	this._cResult = iif(pcount() <= 1, '', transf(m.s))
	
endfunc
*_______________________________________________________________________________
protected function SetResultExtended(n, s)
	
	this._nResult = m.n
	this._cResult = GA_CALLING_FUNCTION + ': ' +  iif(pcount() <= 1, '', transf(m.s))
	
endfunc
*_______________________________________________________________________________
protected function SetResultFromError()
	
	local aa[1]
	=aerror(aa)
	this._nResult = m.aa[1]
	this._cResult = GA_CALLING_FUNCTION + ': ' +  m.aa[2]
	
endfunc
*_______________________________________________________________________________

protected function SetResultFromObject(obj)
	
	=m.this.ClearResult()
	
	do case
	case !ga_Type_IsObject(m.obj)
		assert false
	
	case !pemStatus(m.obj, 'nResult', 5) or !pemStatus(m.obj, 'cResult', 5)
		assert false
	
	otherwise
		this._nResult = m.obj.nResult
		this._cResult = m.obj.cResult
	
	endcase
	
endfunc
*_______________________________________________________________________________
protected function ClearResult()
	
	this._nResult = GA_ERROR_NONE
	this._cResult = ''
endfunc
*_______________________________________________________________________________
protected function nResult_assign()

	GA_ERROR_READONLY_PROPERTY, 'nResult'

endfunc
*_______________________________________________________________________________
protected function nResult_access()

	return m.this._nResult

endfunc
*_______________________________________________________________________________
protected function cResult_assign()

	GA_ERROR_READONLY_PROPERTY, 'cResult'

endfunc
*_______________________________________________________________________________
protected function cResult_access()

	return m.this._cResult

endfunc
*_______________________________________________________________________________
protected function TryEvalMethod(s, methodName)
	
	local success
	success = true
	
	do case
	case !m.success
	
	case !ga_type_isChar(@m.methodName, true)
		assert false
		success = false
	
	case !pemstatus(m.this, m.methodName, 5)
		assert false
		success = false
	
	otherwise
		try
			if (!evaluate('m.this.' + m.methodName+ '(@m.s)') )
				assert false
				success = false
			endif
		catch
			assert false
			success = false
		endtry
	
	endcase
	
	return m.success

endfunc	
*_______________________________________________________________________________
protected function TryEvalMethodToArray(aa, naa, methodName)
	
	external array aa
	
	local success
	success = true
	
	local s
	
	do case
	case !m.success
	
	case !m.this.TryEvalMethod(@m.s, m.methodName)
		assert false
		success = false
	
	case !ga_String_SplitToArray(@m.aa, @m.naa, @m.s, GA_STRING_CRLF, GA_STRING_SPLIT_FLAG_ALLTRIM_INCLUDEEMPTYLASTELEMENT)
		assert false
		success = false
	
	endcase
	
	return m.success

endfunc	
*_______________________________________________________________________________
protected function TryEvalMethodToQueue(lineQueueObj, methodName)
	
	local success
	success = true
	
	local s

	do case
	case !m.success
	
	case !m.this.TryEvalMethod(@m.s, m.methodName)
		assert false
		success = false
	
	case !ga_String_GetLinesQueue(@m.lineQueueObj, @m.s, GA_STRING_SPLIT_FLAG_ALLTRIM_INCLUDEEMPTYLASTELEMENT)
		assert false
		success = false
	
	endcase
	
	return m.success

endfunc	
*_______________________________________________________________________________
enddefine
*===============================================================================
*===============================================================================
*===============================================================================

*===============================================================================
*===============================================================================
*===============================================================================
define class GA_CUSTOM_NAKED_CLASS as Custom

	protected	Application, BaseClass, Class, ;
				ClassLibrary, Comment, ControlCount, Controls, ;
				Height, HelpContextId, Left, ;
				Name, Objects, Parent, ;
				ParentClass, Picture, Tag, Top, WhatsThisHelpId, Width
	
	protected AddObject, AddProperty, NewObject
	
	hidden	ReadExpression, ReadMethod, ;
			ResetToDefault, SaveAsClass, ShowWhatsThis, ;
			WriteExpression, WriteMethod
*_______________________________________________________________________________	
protected function Destroy()
	
	try
		=unbindevents(m.this)
	catch
		assert false
	endtry

	return DoDefault()
endfunc
*_______________________________________________________________________________
enddefine
*===============================================================================
*===============================================================================
*===============================================================================
&& ga_DBCTablesTree 
&& Gregory Adam 2011

*===============================================================================
#include ga_.h
*_______________________________________________________________________________
FUNCTION ga_DBCTablesTree && Tables d'une base de données dans l'ordre de parenté
	LPARAMETERS ;
		taTable,; && @ Tables en retour
		tcDBC,; && Base de données
		tcExcludes,;  && Table(s) à exclure
		tlAsc && [.F.] /!\ à developper /!\ Ordonner les tables selon les parentés ascendantes
	EXTERNAL ARRAY taTable
	
	LOCAL llResult, lnResult && nombre de tables

	llResult = true
	lnResult = 0
	
	do case
	case NOT Type('taTable', 1) == 'A'

		llResult = false
		ASSERT m.llResult MESSAGE Textmerge([<<Program()>> - tableau attendu en premier paramètre <<cLitteral(m.taTable)>>])
	
	case NOT (Vartype(m.tcDBC) == 'C' AND DBused(m.tcDBC))

		llResult = false
		ASSERT false MESSAGE Textmerge([<<Program()>> - Invalid database specification: <<cLitteral(m.tcDBC)>>])
	
	OTHERWISE
	
		local loDB AS abSet OF abDev.prg;
		, obj AS ga_TopologicalSort OF ABGA.prg;
		, i, lcTable, childTable, parentTable;
		, laExcludes[1], lnExcludes;
		, laRelation[1], lnRelations
		
		loDB = abSet('DATABASE', m.tcDBC,,,.T.)
		lnExcludes = ALines(laExcludes, Upper(Evl(m.tcExcludes, Space(0))), 1+4, ',', ';')
		lnResult = ADBObjects(taTable, "TABLE")

		= ga_TopologicalSort_Object(@m.obj)
	
		for i = 1 to m.lnResult 
			
			lcTable  = m.taTable[m.i]
			
			do case
			case !m.llResult
			
			case !empty(ascan(laExcludes, m.lcTable) )
				loop
			
			case !m.obj.AddArc(m.lcTable)
				llResult = false
				assert false
			endcase
		endfor
	endcase
	
	do case
	case !m.llResult
	
	otherwise
		lnRelations = ADBObjects(laRelation, "RELATION")
		
		for i = 1 to m.lnRelations 
			
			childTable	= m.laRelation[m.i, 1]
			parentTable = m.laRelation[m.i, 2]
		
			do case
			case !m.llResult
			
			case m.childTable == m.parentTable
				loop
				
			case !empty(ascan(laExcludes, m.childTable))
				loop
			
			case !empty(ascan(laExcludes, m.parentTable))
				loop
			
			case !m.obj.AddArc(m.childTable, m.parentTable)
				assert false
				llResult = false
				
			endcase
		endfor
	
	endcase
	
	do case
	case !m.llResult
	
	otherwise
		lnResult = m.obj.Sort(@m.taTable)
	
	endcase
	
	return m.lnResult
endfunc

*_______________________________________________________________________________
&& ga_Date
* Gregory Adam 2012
*_______________________________________________________________________________
#include ga_.h

*_______________________________________________________________________________
function ga_Date_To_ISO(d)
	
	return  Transform(dtos(m.d), '@R ####-##-##')

endfunc

*_______________________________________________________________________________
function ga_DateTime_To_ISO(dt)
	
	return  Transform(ttoc(m.dt, 1), '@R ####-##-##T##:##:##')

endfunc
*_______________________________________________________________________________
&& ga_Dictionary
* Gregory Adam 2010
*_______________________________________________________________________________
#include ga_.h

*_______________________________________________________________________________
function ga_Dictionary_object(obj)

	return ga_Object_Create(@m.obj, GA_DICTIONARY_CLASS)

endfunc
*_______________________________________________________________________________
function ga_Dictionary_Integer_object(obj)

	return ga_Object_Create(@m.obj, GA_DICTIONARY_INTEGER_CLASS)

endfunc
*_______________________________________________________________________________
function ga_Dictionary_Naked_object(obj)

	return ga_Object_Create(@m.obj, GA_DICTIONARY_NAKED_CLASS)

endfunc
*_______________________________________________________________________________
function ga_Dictionary_Naked_Integer_object(obj)

	return ga_Object_Create(@m.obj, GA_DICTIONARY_NAKED_INTEGER_CLASS)

endfunc
*_______________________________________________________________________________


*===============================================================================
*===============================================================================
*===============================================================================
define class GA_DICTIONARY_CLASS as GA_COLLECTION_CLASS
	&&KeySort = 2
	
*_______________________________________________________________________________
function Add(key, value)

	NoDefault

	local success
	success = true

	do case
	case !m.success
	
	case !inlist(pcount(), 2)
		assert false
		success = false
	
	otherwise
		try
			if !Collection::Add(m.value, m.key)
				assert false
				success = false
			endif
		catch
			assert false
			success = false
		endtry

	endcase
	
	return m.success
	
endfunc

*_______________________________________________________________________________
function AddKeyValue(key, value)
return this.Add(m.key, m.value)

*_______________________________________________________________________________
function Remove(key)

	NoDefault
	
	local success
	success = true
	
	do case
	case !m.success
	
	case !m.this.TryGetValue(m.key)
		assert false
		success = false
		
	case !Collection::Remove(m.key)
		assert false
		success = false
	
	endcase
	
	return m.success
		
endfunc
*_______________________________________________________________________________
function TryGetValue(key, value)

	local success
	success = true
	
	do case
	case !m.success
	
	case !ga_Type_IsChar(m.key, true)
		assert false
		success = false
	
	case !DoDefault(m.key, @m.value)
		success = false
	
	endcase
	
	return m.success
	
endfunc
*_______________________________________________________________________________
function ContainsKey(key)
	
	if( !ga_Type_IsChar(m.key, true) )
		assert false
		success = false
	
	else
		return !empty(m.this.GetKey(m.key))
	endif
	
endfunc
*_______________________________________________________________________________
function AppendFromDictionary(dictFrom)

	local success
	success = true
	
	local i
	with m.dictFrom
		for i = 1 to .Count
			
			if( !m.this.Add(.GetKey(m.i), .Item(m.i)) )
				assert false
				success = false
				exit
			endif
		endfor
	endwith
			
	return m.success
	
endfunc
*_______________________________________________________________________________
function GetIntersection(intersectionDictObj, otherdictObj)

	local success
	success = true
	
	do case
	case !m.success
	
	case !ga_Type_IsDictionary(m.otherdictObj)
		assert false
		success = false
		
	case !ga_Dictionary_Object(@m.intersectionDictObj)
		assert false
		success = false
	
	case empty(m.this.Count) or empty(m.otherdictObj.Count)
		&& no intersection possible
		
	case !m.this.AddToIntersection(m.intersectionDictObj, m.this, m.otherdictObj)
		assert false
		success = false

	endcase
	
	return m.success
	
endfunc
*_______________________________________________________________________________
protected function AddToIntersection(intersectionDictObj, dict1Obj, dict2Obj)

	local success
	success = true

	
	local i, sKey
	for i = 1 to m.dict1Obj.Count
		
		sKey = m.dict1Obj.GetKey(m.i)
		
		do case
		case !m.success
			exit
		
		case empty(m.dict2Obj.GetKey(m.sKey ))
			loop
		
		case !m.intersectionDictObj.Add(m.sKey, m.sKey)
			assert false
			success = false
		endcase
	endfor
		
	return m.success
	
endfunc
*_______________________________________________________________________________
function KeysToString(s, unSorted)
	
	local success
	success = true

	local aa[1], naa, x
	s = ''
	
	do case
	case !m.success
	
	case !m.unSorted and !m.this.KeysToSortedArray(@m.aa, @m.naa)
		assert false
		success = false

	case m.unSorted and !m.this.KeysToArray(@m.aa, @m.naa)
		assert false
		success = false
		
	case empty(m.naa)
	
	otherwise
		for each x in m.aa foxobject
			s = m.s + ' ' + m.x
		endfor
		
		s = substr(m.s, 2)
	
	endcase
	
	return m.success
	
endfunc
*_______________________________________________________________________________
function KeysToArray(aa, naa)

	local success
	success = true
	
	naa = m.this.Count
	dime aa[ max(1, m.naa) ]
	
	local i
	for i = 1 to m.naa
		store m.this.GetKey(m.i) to aa[m.i]
	endfor
	
	return m.success
	
endfunc
*_______________________________________________________________________________
function KeysToSortedArray(aa, naa)
	
	local success
	success = true
	
	do case
	case !m.success
	
	case !m.this.KeysToArray(@m.aa, @m.naa)
		assert false
		success = false
	
	case empty(m.naa)
	
	case asort(aa) < 1
		assert false
		success = false
	
	endcase
	
	return m.success
	
endfunc
*_______________________________________________________________________________
enddefine
*===============================================================================
*===============================================================================
*===============================================================================

*===============================================================================
*===============================================================================
*===============================================================================
define class GA_DICTIONARY_INTEGER_CLASS as GA_DICTIONARY_CLASS 

*_______________________________________________________________________________
function Item(n)

	nodefault
	return Collection::Item(bintoc(m.n))

endfunc 
*_______________________________________________________________________________
function Add(key, value)

	NoDefault
	
	local success
	success = true
	
	do case
	case !m.success
	
	case !inlist(pcount(), 2)
		assert false
		success = false
	
	case !ga_type_IsInteger(@m.key)
		assert false
		success = false
		
	otherwise
		try
			if( !Collection::Add(m.value, bintoc(m.key)) )
				assert false
				success = false
			endif
		catch
			assert false
			success = false
		
		endtry
	endcase
	
	return m.success
	
endfunc
*_______________________________________________________________________________
function Remove(key)

	NoDefault
	
	local success
	success = true
	
	do case
	case !m.success
	
	case !ga_type_IsInteger(@m.key)
		assert false
		success = false
		
		
	case !m.this.TryGetValue(m.key)
		assert false
		success = false
		
	case !Collection::Remove(bintoc(m.key))
		assert false
		success = false
	
	endcase
	
	return m.success
		
endfunc
*_______________________________________________________________________________
function TryGetValue(key, value )

	local success
	success = true
	
	do case
	case !m.success
	
	case !ga_type_IsInteger(@m.key)
		assert false
		success = false
	
	otherwise
		
		try
			Value = m.this.Item(m.key)
		
		catch
			&& assert false
			success = false
		
		endtry
	
	endcase
	
	return m.success
	
endfunc
*_______________________________________________________________________________
function TryGetIndex(key, index)

	index = m.this.GetKey(bintoc(m.key))	

	return !empty(m.index)
	
endfunc
*_______________________________________________________________________________
function ContainsKey(key)
	
	if(  !ga_type_IsInteger(@m.key) )
		assert false
		success = false
	
	else
		return !empty(m.this.GetKey(bintoc(m.key)))
	endif
	
endfunc
*_______________________________________________________________________________
enddefine
*===============================================================================
*===============================================================================
*===============================================================================

*===============================================================================
*===============================================================================
*===============================================================================
&& keys
define class GA_DICTIONARY_NAKED_CLASS as Collection

	protected BaseClass, Class, ClassLibrary, ;
				Comment, KeySort, Name, ;
				Parent, ParentClass, Tag
	
	protected AddProperty
	
	hidden	ReadExpression, ReadMethod, ;
			ResetToDefault, SaveAsClass, ;
			WriteExpression, WriteMethod

*_______________________________________________________________________________
function Add(key, value )
	nodefault
	
	if( pcount() <> 2 )
		GA_ERROR_TOO_FEW_ARGUMENTS
		return false
	endif
		
	return Collection::Add(m.value, m.key)

endfunc
*_______________________________________________________________________________
protected function Clear()
	
	=Collection::Remove(-1)

endfunc
*_______________________________________________________________________________
protected function Destroy()

	=m.this.Clear()
	
	try
		=unbindevents(m.this)
	
	catch
		assert false
	endtry
	
	return DoDefault()
endfunc
*_______________________________________________________________________________
protected function GetKey(n)

	nodefault
	return iif( ;
				ga_type_IsInteger(m.n), ;
				Collection::GetKey(m.n+1), ;
				Collection::GetKey(m.n)-1 ;
			)
endfunc
*_______________________________________________________________________________
function Item(n)

	nodefault
	return iif( ;
				ga_type_IsInteger(m.n), ;
				Collection::Item(m.n+1), ;
				Collection::Item(m.n) ;
			)

endfunc 
*_______________________________________________________________________________
protected function Remove(n)
	
	nodefault
	return iif( ;
				ga_type_IsInteger(m.n), ;
				Collection::Remove(m.n+1), ;
				Collection::Remove(m.n) ;
			)
	
endfunc
*_______________________________________________________________________________
function TryGetValue(key, value)
	
	if( !ga_Type_IsChar(@m.key, true) )
		GA_ERROR_FUNCTION_ARGUMENT_INCORRECT
	endif
	
	if( !(Collection::GetKey(m.key) > 0) )
		return false
	else
		value = Collection::Item(m.key)
	endif
endfunc
*_______________________________________________________________________________
function ContainsKey(key)
	
	if( !ga_Type_IsChar(@m.key, true) )
		GA_ERROR_FUNCTION_ARGUMENT_INCORRECT
		return false
	endif
	
	return  (Collection::GetKey(m.key) > 0)
	
endfunc
*_______________________________________________________________________________
enddefine
*===============================================================================
*===============================================================================
*===============================================================================


*===============================================================================
*===============================================================================
*===============================================================================
&& keys, integer.  Disadvantage: cannot use item(int) as numeric index
define class GA_DICTIONARY_NAKED_INTEGER_CLASS as GA_DICTIONARY_NAKED_CLASS 

	

*_______________________________________________________________________________
function Add(key, value )
	nodefault
	
	if( pcount() <> 2 )
		GA_ERROR_TOO_FEW_ARGUMENTS
		return false
	endif

	return Collection::Add(m.value, bintoc(m.key))

endfunc
*_______________________________________________________________________________
protected function GetKey(n)

	nodefault
	return iif( ;
				ga_type_IsInteger(m.n), ;
				Collection::GetKey(m.n+1), ;
				Collection::GetKey(m.n) -1 ;
			)
endfunc
*_______________________________________________________________________________
function Item(n)

	nodefault
	return Collection::Item(bintoc(m.n))
	

endfunc 
*_______________________________________________________________________________
protected function Remove(n)
	
	nodefault
	return Collection::Remove(bintoc(m.n))
	
endfunc
*_______________________________________________________________________________
function TryGetValue(key, value)
	
	
	if( !(Collection::GetKey(bintoc(m.key)) > 0) )
		return false
	else
		value = Collection::Item(bintoc(m.key))
	endif
endfunc
*_______________________________________________________________________________
function ContainsKey(key)
	
	
	return  (Collection::GetKey(bintoc(m.key)) > 0)
	
endfunc
*_______________________________________________________________________________
enddefine
*===============================================================================
*===============================================================================
*===============================================================================


&& ga_LightWeight
* Gregory Adam 2011
*_______________________________________________________________________________
#include ga_.h
*_______________________________________________________________________________
*===============================================================================
*===============================================================================
*===============================================================================
define class GA_LIGHTWEIGHT_CLASS as Relation
	
	protected junk;
	; && native properties
	, Application;
	, ChildAlias;
	, ChildOrder;
	, Comment;
	, OneToMany;
	, ParentAlias;
	, RelationalExpr;
	, Tag;
	; && native events
	, Init;
	, Error;
	, Destroy;
	; && native methods
	; && , AddProperty && If .AddProperty() is marked as Hidden or Protected, AddProperty() does not create the new property and returns False (.F.). This protects the original class design.
	, ReadExpression;
	, ReadMethod;
	, ResetToDefault;
	, WriteExpression 

	DataSessionId = set('DataSession')
	
	nResult	= 0
	cResult = ''
	
	protected _nResult, _cResult
	_nResult = 0
	_cResult = ''

*_______________________________________________________________________________
protected function Destroy()
	
	try
		=unbindevents(m.this)
	
	catch
		assert false
	endtry
	
	return DoDefault()
endfunc
*_______________________________________________________________________________
protected function SetResult(n, s)
	
	this._nResult = Evl(m.n, 0)
	this._cResult = Transform(iif(pcount() <= 1, Evl(this._nResult, ''), m.s))
	
endfunc
*_______________________________________________________________________________
protected function SetResultFromObject(obj)
	
	=m.this.ClearResult()
	
	do case
	case !ga_Type_IsObject(m.obj)
		assert false
	
	case !pemStatus(m.obj, 'nResult', 5) or !pemStatus(m.obj, 'cResult', 5)
		assert false
	
	otherwise
		this._nResult = m.obj.nResult
		this._cResult = m.obj.cResult
	endcase

endfunc

*_______________________________________________________________________________
protected function SetResultExtended(n, s)
	
	this._nResult = m.n
	this._cResult = GA_CALLING_FUNCTION + ': ' + iif(pcount() <= 1, '', transf(m.s))
	
endfunc
*_______________________________________________________________________________
protected function SetResultFromError()
	
	local aa[1]
	=aerror(aa)
	this._nResult = m.aa[1]
	this._cResult = GA_CALLING_FUNCTION + ': ' +  m.aa[2]
	
endfunc
*_______________________________________________________________________________
protected function ClearResult()
	
	this._nResult = GA_ERROR_NONE
	this._cResult = ''

endfunc
*_______________________________________________________________________________
protected function nResult_assign(nResult)

	GA_ERROR_READONLY_PROPERTY, 'nResult'

endfunc
*_______________________________________________________________________________
protected function nResult_access()

	return m.this._nResult

endfunc
*_______________________________________________________________________________
protected function cResult_assign(cResult)

	GA_ERROR_READONLY_PROPERTY, 'cResult'

endfunc
*_______________________________________________________________________________
protected function cResult_access()

	return m.this._cResult

endfunc
*_______________________________________________________________________________
protected function TryEvalMethod(s, methodName)
	
	local success
	success = true
	
	do case
	case !m.success
	
	case !ga_type_isChar(@m.methodName, true)
		assert false
		success = false
	
	case !pemstatus(m.this, m.methodName, 5)
		assert false
		success = false
	
	otherwise
		try
			if(!evaluate('m.this.' + m.methodName+ '(@m.s)'))
				assert false
				success = false
			endif
		catch
			assert false
			success = false
		endtry
	
	endcase
	
	return m.success

endfunc	
*_______________________________________________________________________________
protected function TryEvalMethodToArray(aa, naa, methodName)
	
	external array aa
	
	local success
	success = true
	
	local s
	
	do case
	case !m.success
	
	case !m.this.TryEvalMethod(@m.s, m.methodName)
		assert false
		success = false
	
	case !ga_String_SplitToArray(@m.aa, @m.naa, @m.s, GA_STRING_CRLF, GA_STRING_SPLIT_FLAG_ALLTRIM_INCLUDEEMPTYLASTELEMENT)
		assert false
		success = false
	
	endcase
	
	return m.success

endfunc	
*_______________________________________________________________________________
protected function TryEvalMethodToQueue(lineQueueObj, methodName)
	
	local success
	success = true
	
	local s
	
	do case
	case !m.success
	
	case !m.this.TryEvalMethod(@m.s, m.methodName)
		assert false
		success = false
	
	case !ga_String_GetLinesQueue(@m.lineQueueObj, @m.s, GA_STRING_SPLIT_FLAG_ALLTRIM_INCLUDEEMPTYLASTELEMENT)
		assert false
		success = false
	
	endcase
	
	return m.success

endfunc	
*_______________________________________________________________________________
enddefine 
*===============================================================================
*===============================================================================
*===============================================================================
 
*===============================================================================
*===============================================================================
*===============================================================================
define class GA_LIGHTWEIGHT_NAKED_CLASS as Relation

	protected	Application, BaseClass, ChildAlias, ChildOrder, Class, ;
				ClassLibrary, Comment, Name, OneToMany, Parent, ;
				ParentAlias, ParentClass, RelationalExpr, Tag
	
	protected AddProperty
	
	hidden	ReadExpression, ReadMethod, ;
			ResetToDefault, SaveAsClass, ;
			WriteExpression, WriteMethod
*_______________________________________________________________________________	
protected function Destroy()
	
	try
		=unbindevents(m.this)
	
	catch
		assert false
	endtry
	
	return DoDefault()
endfunc
*_______________________________________________________________________________	
enddefine 
*===============================================================================
*===============================================================================
*===============================================================================


*_______________________________________________________________________________
function tn_fileCreate_Object(obj, file, handle)
	return ga_Object_Create(;
					@m.obj, ;
					'_tn_fileCreate_class_', ;
					m.file, ;
					@m.handle;
			)
*===============================================================================
*===============================================================================
*===============================================================================
define class _tn_fileCreate_class_ as GA_LIGHTWEIGHT_CLASS

	handle = -1

	*_______________________________________________________________________________
	protected function init(file, handle)

	store Iif(ga_Type_IsChar(m.file, true);
		, Fcreate(m.file);
		, -1;
		);
		to this.handle, m.handle 

	return DoDefault() and m.handle <> -1

	*_______________________________________________________________________________
	protected function destroy
	return DoDefault() and Fclose(m.this.handle)

enddefine && class _tn_fileCreate_class_
*===============================================================================
*===============================================================================
*===============================================================================

*_______________________________________________________________________________
function tn_fileOpen_Object(obj, file, handle)
	return ga_Object_Create(;
				@m.obj, ;
				'_tn_fileOpen_class_', ;
				m.file, ;
				@m.handle;
				)

*===============================================================================
*===============================================================================
*===============================================================================
define class _tn_fileOpen_class_ as GA_LIGHTWEIGHT_CLASS

	handle = -1

	*_______________________________________________________________________________
	protected function init(file, handle)

	store Iif(ga_Type_IsChar(m.file, true) and File(m.file);
		, Fopen(m.file);
		, -1;
		);
		to this.handle, m.handle 

	return DoDefault() and m.handle <> -1

	*_______________________________________________________________________________
	protected function destroy
	return DoDefault() and Fclose(m.this.handle)

enddefine && class _tn_fileOpen_class_
*===============================================================================
*===============================================================================
*===============================================================================
&& ga_number
* Gregory Adam 2012
*_______________________________________________________________________________
#include ga_.h
*_______________________________________________________________________________
function ga_Number_ToString(n)

	return strtran(transf(m.n), set('point'), '.')

endfunc
*_______________________________________________________________________________
&& ga_Object
* Gregory Adam 2010
*_______________________________________________________________________________
#include ga_.h
*_______________________________________________________________________________
*_______________________________________________________________________________

function ga_Object_Create(obj, classname, GA_PARAMETERLIST_08 )
	
	return ga_Object_Create_np(@m.obj, m.classname, pcount()-2, GA_PARAMETERLIST_08_REF)

endfunc
*_______________________________________________________________________________
function ga_Object_Create_np(obj, classname, np, GA_PARAMETERLIST_08)

	local success
	success = true
	
	obj = null
	
	if( GA_ISRUNTIME )
		try
			
			do case
			case inlist(m.np, 0)
				obj = CreateObject(m.classname)
			
			case inlist(m.np, 1)
				obj = CreateObject(m.classname, @m.p01)
			
			case inlist(m.np, 2)
				obj = CreateObject(m.classname, @m.p01, @m.p02)
			
			case inlist(m.np, 3)
				obj = CreateObject(m.classname, @m.p01, @m.p02, @m.p03)
			
			case inlist(m.np, 4)
				obj = CreateObject(m.classname, GA_PARAMETERLIST_04_REF)
			
			case inlist(m.np, 5)
				obj = CreateObject(m.classname, GA_PARAMETERLIST_04_REF, @m.p05)
			
			case inlist(m.np, 6)
				obj = CreateObject(m.classname, GA_PARAMETERLIST_04_REF, @m.p05, @m.p06)
			
			case inlist(m.np, 7)
				obj = CreateObject(m.classname, GA_PARAMETERLIST_04_REF, @m.p05, @m.p06, @m.p07)
			
			case inlist(m.np, 8)
				obj = CreateObject(m.classname, GA_PARAMETERLIST_08_REF)
			
			case m.np < 0
				assert false
				success = false
			
			otherwise
				assert false
				success = false
			
			endcase
		
		catch
			if( !GA_ISRUNTIME  )
				=aerror(pp)
			endif
			
			assert false
			success = false
		
		endtry

	else

		do case
		case inlist(m.np, 0)
			obj = CreateObject(m.classname)
		
		case inlist(m.np, 1)
			obj = CreateObject(m.classname, @m.p01)
		
		case inlist(m.np, 2)
			obj = CreateObject(m.classname, @m.p01, @m.p02)
		
		case inlist(m.np, 3)
			obj = CreateObject(m.classname, @m.p01, @m.p02, @m.p03)
		
		case inlist(m.np, 4)
			obj = CreateObject(m.classname, GA_PARAMETERLIST_04_REF)
		
		case inlist(m.np, 5)
			obj = CreateObject(m.classname, GA_PARAMETERLIST_04_REF, @m.p05)
		
		case inlist(m.np, 6)
			obj = CreateObject(m.classname, GA_PARAMETERLIST_04_REF, @m.p05, @m.p06)
		
		case inlist(m.np, 7)
			obj = CreateObject(m.classname, GA_PARAMETERLIST_04_REF, @m.p05, @m.p06, @m.p07)
		
		case inlist(m.np, 8)
			obj = CreateObject(m.classname, GA_PARAMETERLIST_08_REF)
		
		case m.np < 0
			assert false
			success = false
		
		otherwise
			assert false
			success = false
		
		endcase
	endif
	
	do case
	case !m.success
	
	case !inlist(vartype(m.obj), T_OBJECT)
		assert false
		success = false
	
	endcase
	
	return m.success
	
endfunc
*_______________________________________________________________________________
function ga_Object_Create_Property()
	lparameters	parentObj, ;
				propertyname, ;
				classname, ;
				GA_PARAMETERLIST_08
	
	local obj, success
	success = true
	
	do case
	
	case !ga_Object_Create_np(@m.obj, m.classname, pcount()-3, GA_PARAMETERLIST_08_REF)
		assert false
		success = false
	
	otherwise

		try
			success = AddProperty(m.parentObj, m.propertyname, m.obj)
		catch
			success = false
		endtry
		assert m.success
	endcase
	
	return m.success
	
endfunc
*_______________________________________________________________________________
function ga_Empty_Object(obj)
	
	obj = createobject('Empty')

endfunc
*_______________________________________________________________________________
function ga_Empty_Object_PropertyList
		lparameters	obj, ;
					propertyList, ;
					propertySeparator, ;
					GA_PARAMETERLIST_16

	local success
	success = true
	
	local i, aa[1], naa
	
	do case
	case !m.success
	
	case !ga_Empty_Object(@m.obj)
		assert false
		success = false
		
	case !ga_Object_AddPropertyList( ;
				m.obj, ;
				@m.propertyList, ;
				@m.propertySeparator, ;
				pcount() - 3, ;
				GA_PARAMETERLIST_16_REF ;
			)
		assert false
		success = false

	endcase
	
	return m.success

endfunc
*_______________________________________________________________________________
function ga_Object_AddPropertyList
		lparameters	obj, ;
					propertyList, ;
					propertySeparator, ;
					nValues, ;
					GA_PARAMETERLIST_16
					
	local success
	success = true
	
	local i, aa[1], naa
	
	do case
	case !m.success
	
	case !ga_String_SplitToArray(;
				@m.aa, ;
				@naa, ;
				m.propertyList, ;
				m.propertySeparator, ;
				GA_STRING_SPLIT_FLAG_ALLTRIM_STRIPEMPTY ;
			)
	otherwise
		for i = 1 to min(m.naa, nValues)
			
			do case
			case !m.success
				exit
			
			case !AddProperty( ;
						m.obj, ;
						m.aa[m.i], ;
						eval('m.p' + padl(m.i, 2, '0')) ;
					) 
				assert false
				success = false
			endcase
		endfor
		
		
		for i = m.i to m.naa
			
			do case
			case !m.success
				exit
			
			case !AddProperty( ;
						m.obj, ;
						m.aa[m.i], ;
						null ;
					) 
				assert false
				success = false
			endcase
		endfor
		
	endcase
	
	return m.success

endfunc
*_______________________________________________________________________________
function ga_Object_TryGetPem(obj, name , value)
	
	local failed
	try
		value = getpem(m.obj, m.name)
	
	catch
		failed = true
	
	endtry
	
	return !m.failed

endfunc
*_______________________________________________________________________________
#if false
	Dictionary
		- Name
		- Value
		- IsArray
#endif
function ga_Object_GetPems(dictObj, obj, cflags, whichOnes)
	
	local success
	success = true
	
	local aa[1], naa
	
	do case
	case !m.success
	
	case !ga_Type_IsObject(m.obj)
		assert false
		success = false
		
	case !ga_Type_IsChar(m.cflags)
		assert false
		success = false
	
	case !ga_Type_IsInteger(m.whichOnes)
		assert false
		success = false
	
	case !ga_Dictionary_Object(@m.dictObj)
		assert false
		success = false
		
	otherwise
		try
			naa = amembers(aa, m.obj, 1, m.cflags)
		
		catch
			success = false

		endtry
	
	endcase
	
	&& if obj is enumerable has a property Count, add it
	do case
	case !m.success
	
	case !ga_Type_IsEnumerable(@m.obj)
	
	case !pemStatus(m.obj, 'Count', 5)
	
	otherwise
		naa = m.naa + 1
		dime aa[m.naa, 2]
		aa[m.naa, 1] = 'COUNT'
		aa[m.naa, 2] = 'Property'
		
		=asort(aa)
	endcase
	
	
	do case
	case !m.success
	
	otherwise
		local 	i, propName, propType, propValue, xType, ;
				xObj, isArray
		
		for i = 1 to m.naa
			propname = proper(m.aa[m.i, 1])
			propType = m.aa[m.i, 2]
			
			isEnumerable 	= false
			isArray			= false
				
			xType = icase( ;
						;
						inlist(m.propType, 'Property'), ga_OBJECT_GETPEM_Property, ;
						inlist(m.propType, 'Event'), ga_OBJECT_GETPEM_Event, ;
						inlist(m.propType, 'Method'), ga_OBJECT_GETPEM_Method, ;
						inlist(m.propType, 'Object'), ga_OBJECT_GETPEM_Property ;
					)
			
			do case
			case inlist(m.propName, 'Controls', 'Columns', 'Objects', 'Pages')
				loop
				
			case !ga_Object_TryGetPem(m.obj, propName, @m.propValue)
				loop
			
			case empty(bitand(m.xType, m.whichOnes))
				loop
		
			case !empty(bitand(m.xType, ga_OBJECT_GETPEM_Property))
			
				isArray = inlist(type('m.obj.&propName', 1), T_ARRAY) 
				&& is it Enumerable ?
			
			 endcase
			 
			 do case
			 case !m.success
			 
			 case !ga_Empty_Object_PropertyList( ;
						@m.xObj, ;
						'Name, Value, IsArray', ;
						',',; 
						proper(m.propName), ;
						m.propValue, ;
						m.IsArray ;
					)
					assert false
					success = false
				
			case m.isArray and !ga_Object_CopyArrayProperty(m.obj, m.propName, m.xObj, 'Value')
				assert false
				success = false
			
			case !m.dictObj.Add(proper(m.propName), m.xObj)
				assert false
				success = false
			
			endcase
			
			
		endfor
		
		
	endcase
	
	return m.success

endfunc
*_______________________________________________________________________________
function ga_Object_CopyArrayProperty(objFrom, propFrom, objTo, propTo)

	local success
	success = true
	
	do case
	case !m.success
	
	case !ga_Type_IsObject(m.objFrom)
		assert false
		success = false
	
	case !ga_Type_IsChar(m.propFrom, true)
		assert false
		success = false

	case !ga_Type_IsObject(m.objTo)
		assert false
		success = false
	
	case !ga_Type_IsChar(m.propTo, true)
		assert false
		success = false
	
	case !inlist(type('m.objFrom.&propFrom', 1), T_ARRAY)
		assert false
		success = false
		
	otherwise
		local nRows, nCols
		
		nRows = alen(m.objFrom.&propFrom, 1)
		nCols = alen(m.objFrom.&propFrom, 2)
	
		
		do case
		case	 pemstatus(m.objTo, m.propTo, 5) ;
			and	!inlist(type('m.objTo.&propTo', 1), T_ARRAY) ;
			and !RemoveProperty(m.objTo, m.propTo)
			
			assert false
			success = false
			
		case empty(m.nCols) and !AddProperty(m.objTo, m.propTo + '[' + transf(m.nRows) + ']')
			assert false
			success = false
			
		case !empty(m.nCols) and !AddProperty(m.objTo, m.propTo + '[' + transf(m.nRows) + ',' + transf(m.nCols) + ']')
			assert false
			success = false
		
		endcase
		
		=acopy(m.objFrom.&propFrom, m.objTo.&propTo)
	
	endcase	
		
	return m.success

endfunc
*_______________________________________________________________________________
function ga_Object_GetArrayProperty(aa, obj, propname)

	local success
	success = true
	
	do case
	case !m.success
	
	case !ga_Type_IsObject(m.obj)
		assert false
		success = false
	
	case !ga_Type_IsChar(m.propname, true)
		assert false
		success = false

	case !inlist(type('m.obj.&propName', 1), T_ARRAY) 
		assert false
		success = false
	
	otherwise
		local nRows, nCols
		
		nRows = alen(m.obj.&propName, 1)
		nCols = alen(m.obj.&propName, 2)
		
		do case
		case empty(m.nCols)
			dime aa[ m.nRows ]
			
		otherwise
			dime aa[ m.nRows, m.nCols ]
		
		endcase
		
		=acopy(m.obj.&propName, aa)
	
	endcase
	
	return m.success

endfunc
*_______________________________________________________________________________
function ga_Object_HasMethod(obj, methodname)
	
	local success
	success = true
	
	do case
	case !m.success
	
	case !ga_Type_IsObject(m.obj)
		assert false
		success = false
	
	case !ga_Type_IsChar(m.methodname, true)
		assert false
		success = false

	case !pemstatus(m.obj, m.methodname, 5)
		assert false
		success = false
	
	case !( pemstatus(m.obj, m.methodname, 3) == 'Method')
		assert false
		success = false
	
	case pemstatus(m.obj, m.methodname, 2)
		assert false
		success = false
		
	endcase
	
	return m.success

endfunc
*_______________________________________________________________________________
function ga_Object_HasProperty(obj, propertyname)
	
	local success
	success = true
	
	do case
	case !m.success
	
	case !ga_Type_IsObject(m.obj)
		assert false
		success = false
	
	case !ga_Type_IsChar(m.propertyname, true)
		assert false
		success = false

	case !pemstatus(m.obj, m.propertyname, 5)
		assert false
		success = false
	
	case !( pemstatus(m.obj, m.propertyname, 3) == 'Property')
		assert false
		success = false
	
	case pemstatus(m.obj, m.propertyname, 2)
		assert false
		success = false
		
	endcase
	
	return m.success

endfunc
*_______________________________________________________________________________
&& ga_ParameterClasses
* Gregory Adam 2012
*_______________________________________________________________________________
#include ga_.h
*_______________________________________________________________________________
#if false
	restrictions
	
	- Define Popup
		(1) Prompt files like '*.dbf'
			like argument must be an expression
		
		(2) Color  ColorPairList
				ColorPairList :
					rgb(2, 330,,,)  all arguments must be numeric constants
					also parsed is style G/W*, B/W*,,,,W+/GR
#endif

*_______________________________________________________________________________
function ga_Parameter_Popup_Define_Object(obj, cResult)
	
	local success
	success = true

	cResult = ''
	
	do case
	case !m.success
	
	case !ga_Object_create(@m.obj, 'ga_parameters_Popup_Define')
		cResult = 'Error instantiating ga_parameters_Popup_Define'
		assert false
		success = false
	
	endcase
	
	return m.success

endfunc
*_______________________________________________________________________________
#if false
	restrictions
	
	- Define bar
		(1) Color  ColorPairList
				ColorPairList :
					rgb(2, 330,,,)  all arguments must be numeric constants
					also parsed is style G/W*, B/W*,,,,W+/GR
					
#endif
*_______________________________________________________________________________
function ga_Parameter_Bar_Define_Object(obj, cResult)
	
	local success
	success = true
	
	cResult = ''
	
	do case
	case !m.success
	
	case !ga_Object_create(@m.obj, 'ga_parameters_Bar_Define')
		cResult = 'Error instantiating ga_parameters_Bar_Define'
		assert false
		success = false
	
	endcase
	
	return m.success

endfunc

*===============================================================================
*===============================================================================
*===============================================================================
&& ga_Queue
* Gregory Adam 2010
*_______________________________________________________________________________
#include ga_.h

*_______________________________________________________________________________
function ga_Queue_Object(obj)

	return ga_Object_Create(@m.obj, GA_QUEUE_CLASS)
	
endfunc
*_______________________________________________________________________________
#if false
function ga_Queue_Object_Need(obj)

	return iif(ga_Type_IsObjectOfClass(m.obj, GA_QUEUE_CLASS), ;
				m.obj.Clear(), ;
				ga_Queue_Object(@m.obj) ;
			)
endfunc
#endif
*_______________________________________________________________________________
*===============================================================================
*===============================================================================
*===============================================================================
define class GA_QUEUE_CLASS	as GA_COLLECTION_CLASS
	
*_______________________________________________________________________________
function Enqueue(p)

	return !empty(pcount()) and m.this.Add(m.p)

endfunc
*_______________________________________________________________________________
function Dequeue(p)
	
	do case

	case empty(pcount()) or empty(m.this.Count)
		return false
	
	otherwise
		p = m.this.Item(1)
		return m.this.Remove(1)

	endcase
endfunc

*_______________________________________________________________________________
function Peek(p)

	do case

	case empty(pcount()) or empty(m.this.Count)
		return false
	
	otherwise
		p =  m.this.Item(1)
		
	endcase
	
	return true

endfunc
*_______________________________________________________________________________
#if false
function Peek2(p)

	do case
	case empty(pcount()) or m.this.Count < 2
		return false
	
	otherwise
		p =  m.this.Item(2)
		
	endcase
	
	return true

endfunc
#endif
*_______________________________________________________________________________
enddefine
*===============================================================================
*===============================================================================
*===============================================================================
&& ga_Session
* Gregory Adam 2010
*_______________________________________________________________________________
#include ga_.h
*_______________________________________________________________________________
*_______________________________________________________________________________
*===============================================================================
*===============================================================================
*===============================================================================
define class GA_SESSION_CLASS	as Session

*_______________________________________________________________________________
protected function Init()

	local success
	success = true
	
	do case
	case !m.success
	
	case !DoDefault()
		assert false
		success = false
	
	case !m.this.Set(true)
		assert false
		success = false
		
	endcase

	return m.success

endfunc
*_______________________________________________________________________________
*_______________________________________________________________________________
protected function Destroy()

	try
		=unbindevents(m.this)
	
	catch
		assert false
	endtry
	
	return DoDefault()
endfunc
*_______________________________________________________________________________
protected function Set(setTalkOff)

	set Ansi On
	set Autosave On
	set blocksize to 0
	set Carry Off
	set Century On
	set Collate to 'Machine'
	Set Confirm On
	&& set Database to (set('Database'))
	set date DMY
	set Deleted On
	set Exact On
	set Exclusive Off
	set Fixed Off
	set hours to 24
	set Lock Off
	set mark to '/'
	set memowidth to 100
	set Multilocks On
	set near on
	set Null Off
	set reprocess to automatic
	set Safety Off
	set Seconds On
	set Sysformats Off
	
	if( m.setTalkOff)
		set Talk Off
	else
		set Talk On
	endif
	set Unique Off
	set point to '.'
	set separator to ','
	set Decimals to 2
	
	local c, r, d, w
	w = 10
	c = year(date()) + m.w
	r = transf(mod(m.c,100))
	c = transf(int((m.c-100)/100))
	d = m.c + ' rollover ' + m.r
	set century to &d	

endfunc
*_______________________________________________________________________________
enddefine
*===============================================================================
*===============================================================================
*===============================================================================
&& ga_Stack
* Gregory Adam 2010
*_______________________________________________________________________________
#include ga_.h

*_______________________________________________________________________________
function ga_Stack_Object(obj)
	return ga_Object_Create(@m.obj, GA_STACK_CLASS)
endfunc

*===============================================================================
*===============================================================================
*===============================================================================
define class GA_STACK_CLASS	as Collection
	
*_______________________________________________________________________________
protected function Destroy()

	=m.this.Clear()
	
	try
		=unbindevents(m.this)
	
	catch
		assert false
	endtry
	
	return DoDefault()
endfunc
*_______________________________________________________________________________
function Clear()
	
	=Collection::Remove(-1)

endfunc
*_______________________________________________________________________________
function Empty()
	
	return empty(m.this.Count)
	
endfunc
*_______________________________________________________________________________
&& 2.44 sec for 17337 times
function Push(p)

	return m.this.Add(m.p)
endfunc
*_______________________________________________________________________________
&& .16 sec for 17337 times
function Pop(p)
	
	if( !empty(m.this.Count))
		p =  m.this.Item(m.this.Count)
		=m.this.Remove(m.this.Count)
	else
		return false
	endif
	
endfunc
*_______________________________________________________________________________
function Peek(p)

	if( !empty(m.this.Count))
		p =  m.this.Item(m.this.Count)
		=m.this.Remove(m.this.Count)
	else
		return false
	endif


endfunc
*_______________________________________________________________________________
enddefine
*===============================================================================
*===============================================================================
*===============================================================================
&& ga_String
* Gregory Adam 2011
*_______________________________________________________________________________
#include ga_.h

*_______________________________________________________________________________
function ga_String_SplitToArray(aa, naa, s, separator, nflags)

	external array aa
	
	local success
	success = true
	
	do case
	case !m.success
	
	case pcount() < 5
		assert false
		success = false

	case !ga_Type_IsArray(@m.aa)
		assert false
		success = false
	
	case !ga_Type_IsChar(@m.s, false)
		assert false
		success = false
	
	case !ga_Type_IsChar(@m.separator, true)
		assert false
		success = false
	
	case !ga_Type_IsInteger(m.nflags)
		assert false
		success = false
	
	case empty(len(m.s))
		naa = 0
		
	otherwise
		naa = alines( ;
					aa, ;
					m.s, ;
					bitand( ;
							m.nflags, ;
							bitnot( ;
								bitor( ;
										ga_STRING_SPLIT_FLAG_TOLOWERCASE, ;
										ga_STRING_SPLIT_FLAG_EVALELEMENTS ;
									) ;
								) ;
						), ;
					m.separator ;
				)
	endcase
	
	local i, x
	
	do case
	case !m.success
	
	** alines() only trims space chars()
	case empty(bitand(m.nflags, GA_STRING_SPLIT_FLAG_ALLTRIM))
	
	case empty(bitand(m.nflags, GA_STRING_SPLIT_FLAG_STRIPEMPYELEMENTS))
		for i = m.naa to 1 step -1
			store ga_String_ALLTRIM_WhiteSpace(m.aa[m.i]) to aa[m.i]
		endfor

	otherwise
	
		for i = m.naa to 1 step -1
			
			store ga_String_ALLTRIM_WhiteSpace(m.aa[m.i]) to aa[m.i]
			
			if( empty(len(m.aa[m.i])) )
				=adel(aa, m.i)
				naa = m.naa - 1
			endif
		endfor
	endcase
			
	do case
	case !m.success
	
	case empty(bitand(m.nflags, ga_STRING_SPLIT_FLAG_TOLOWERCASE))
	
	otherwise
	
		for i = 1 to m.naa
			store lower(m.aa[m.i]) to aa[m.i]
		endfor
	endcase
	
	do case
	case !m.success
	
	case empty(bitand(m.nflags, GA_STRING_SPLIT_FLAG_EVALELEMENTS))
	
	otherwise
		
		for i = 1 to m.naa
			
			do case
			case !m.success
				exit
			
			case !ga_String_TryEval(@m.x, m.aa[m.i])
				assert false
				success = false
			
			otherwise
				store m.x to aa[m.i]
			
			endcase
			
		endfor
	endcase
	
	do case
	case !m.success
	
	case m.naa == alen(aa)
	
	otherwise
		dime aa[ max(1, m.naa) ]
	
	endcase
			
	return m.success
	
endfunc

*_______________________________________________________________________________
function ga_String_TryEval(returnvalue, sExpr)
		
	local success
	success = true
	
	do case
	case !m.success
	
	otherwise
		try
			returnvalue = eval(m.sExpr)
		
		catch
			assert false
			success = false
		
		endtry
	endcase
	
	return m.success
	
endfunc

*_______________________________________________________________________________
function ga_String_LTRIM_WhiteSpace(s)
	return ltrim(m.s, 0, GA_BYTE_WHITESPACE_LIST )
endfunc

*_______________________________________________________________________________
function ga_String_RTRIM_WhiteSpace(s)
	return rtrim(m.s, 0, GA_BYTE_WHITESPACE_LIST )
endfunc

*_______________________________________________________________________________
function ga_String_ALLTRIM_WhiteSpace(s)
	return alltrim(m.s, 0, GA_BYTE_WHITESPACE_LIST )
endfunc

*_______________________________________________________________________________
function ga_String_WhiteSpace_Trim(s, options)

	do case
	case m.options == ga_STRING_WHITESPACE_NOTRIM
	 
	case bitand(m.options, ga_STRING_WHITESPACE_ALLTRIM) == ga_STRING_WHITESPACE_ALLTRIM
		s = alltrim(m.s,  1, GA_BYTE_WHITESPACE_LIST )
	
	case !empty(bitand(m.options, ga_STRING_WHITESPACE_LTRIM))
		s = ltrim(m.s,  1, GA_BYTE_WHITESPACE_LIST )
	
	case !empty(bitand(m.options, ga_STRING_WHITESPACE_RTRIM))
		s = rtrim(m.s,  1, GA_BYTE_WHITESPACE_LIST )
		
	otherwise
		error 'To implement'
	
	endcase
	
endfunc

*_______________________________________________________________________________
function ga_String_FirstWhiteSpaceCharIndex(s)

	&&also return ga_String_IndexOfAny(m.s, ga_STRING_WHITESPACE)
	return at(' ',  ;
			chrtran( ;
					m.s, ;
					ga_STRING_WHITESPACE, ;
					replicate(' ', len(ga_STRING_WHITESPACE)) ;
					) ;
			)
endfunc

*_______________________________________________________________________________
function ga_String_IndexOfAny(s, anystring)

	return at( ;
			left(m.anystring, 1), ;
			chrtran( ;
					m.s, ;
					m.anystring, ;
					Replicate(left(m.anystring, 1), len(m.anystring)) ;
					) ;
			)
endfunc

*_______________________________________________________________________________
function ga_String_ExtractKeyValuePairs(dictObj, s)
	
	local success
	success = true
	
	do case
	case !m.success
	
	case !ga_Type_IsChar(@m.s, false)
		assert false
		success = false
		
	case !ga_Dictionary_Object(@m.dictObj)
		assert false
		success = false
	
	otherwise
		s = ga_String_ALLTRIM_WhiteSpace(@m.s)
		
		local key, value, n
		
		do while m.success and !empty(len(m.s))
			
			do case
			case empty(at('=', m.s))
				assert false
				success = false
			
			otherwise
				key = getwordnum(m.s, 1, '=')
				s = ga_String_LTRIM_WhiteSpace(ltrim(ga_String_LTRIM_WhiteSpace(substr(m.s, len(m.key)+1)), 1, '='))
				
				key = ga_String_RTRIM_WhiteSpace(m.key)
				
			endcase
			
			do case
			case !m.success
			
			case empty(len(m.s))
				assert false
				success = false
			
			case left(m.s, 1) == '"'
				if( empty(at('"', substr(m.s, 2))) )
					assert false
					success = false
				else
		
					value = substr(m.s, 2, at('"', substr(m.s, 2)) -1)
					s = substr(m.s, 3 + len(m.value))
				endif
			
			otherwise
				n = evl(ga_String_FirstWhiteSpaceCharIndex(m.s), len(m.s)+1)
				value = left(m.s, m.n-1)
				s = substr(m.s, m.n+1)
			
			endcase
			
			do case
			case !m.success
			
			case !m.dictObj.Add(m.key, m.value)
				assert false
				success = false
			
			otherwise
				s = ga_String_LTRIM_WhiteSpace(m.s)
			
			endcase
		enddo
	endcase
	
	return m.success

endfunc

*_______________________________________________________________________________
function ga_String_ToHex(s)
	return strconv(m.s, 15) && encoded hex binary
endfunc

*_______________________________________________________________________________
function ga_String_Xml_Encode(sOut, s)

	sOut = strtran(rtrim(m.s),	'&', '&amp;' )
	sOut = strtran(m.sOut, '<', '&lt;' )
	sOut = strtran(m.sOut, '>', '&gt;' )
	sOut = strtran(m.sOut, "'", '&apos;' )
	sOut = strtran(m.sOut, '"', '&quot;' )
				
endfunc
*_______________________________________________________________________________
function ga_String_LTrim_Word(s)

	local n
	n = ga_String_FirstWhiteSpaceCharIndex(@m.s)
	
	if( !empty(m.n) )
		s = substr(m.s, m.n + 1)
	endif
	
	return ga_String_LTRIM_WhiteSpace(@m.s)

endfunc
*_______________________________________________________________________________
function ga_String_ToArg(s)

	if( empty(at("'", m.s)) )
		return "'" + m.s + "'"
	endif
	if( empty(at('"', m.s)) )
		return '"' + m.s + '"'
	endif
	if( empty(at(']', m.s)) )
		return '[' + m.s + ']'
	endif
	
	assert false
	return null
	
endfunc
*_______________________________________________________________________________
function ga_String_GetLinesQueue(lineQueueObj, s, splitOptions)
	
	local success
	success = true
	
	do case
	case !m.success
	
	case !ga_Queue_Object(@m.lineQueueObj)
		assert false
		success = false
	
	case !m.lineQueueObj.AddSeparatedString(@m.s, GA_STRING_CRLF, m.splitOptions)
		assert false
		success = false
	
	endcase
	
	return m.success
					
endfunc
*_______________________________________________________________________________
function ga_String_GetLinesSpacedPartsQueue(lineQueueObj, s, splitOptions)

	local success
	success = true
	
	local obj
	
	do case
	case !m.success
	
	case !ga_String_GetLinesQueue(@m.lineQueueObj, @m.s, m.splitOptions)
		assert false
		success = false
	
	otherwise
		
		local i
		for i = 1 to m.lineQueueObj.Count
			
			do case
			case !m.success
				exit
				
			case !m.lineQueueObj.Dequeue(@m.s)
				assert false
				success = false
			
			case !ga_Collection_Object(@m.obj)
				assert false
				success = false
			
			case !m.obj.AddSeparatedString(strtran(m.s, ' ', chr(GA_BYTE_HT)), chr(GA_BYTE_HT), GA_STRING_SPLIT_FLAG_ALLTRIM_STRIPEMPTY)
				assert false
				success = false
			
			case !m.lineQueueObj.Enqueue(m.obj)
				assert false
				success = false
			
			endcase
		endfor
	endcase
	
	return m.success
					
endfunc

*_______________________________________________________________________________
function ga_String_ToByteQueue(queueObj, s)
	
	local success
	success = true
	
	do case
	case !m.success
	
	case !ga_Type_IsChar(@m.s, false)
		assert false
		success = false
		
	case !ga_Queue_Object(@m.queueObj)
		assert false
		success = false
	
	otherwise
		
		local i
		for i = 1 to len(m.s)
			
			if( !m.queueObj.Enqueue(asc(substr(m.s, m.i, 1))))
				assert false
				success = false
			endif
		
		endfor
	endcase
	
	return m.success

endfunc
*_______________________________________________________________________________
&& ga_TopologicalSort
* Gregory Adam 2010
*_______________________________________________________________________________
#include ga_.h

*_______________________________________________________________________________
function ga_TopologicalSort_Object(obj)
	return ga_Object_Create(@m.obj, GA_TOPOLOGICALSORT_CLASS)
endfunc

*===============================================================================
*===============================================================================
*===============================================================================
define class GA_TOPOLOGICALSORT_CLASS as GA_SESSION_CLASS
	
	protected Nodes
	Nodes	= null
	
*_______________________________________________________________________________
protected function init()

	local success
	success = true
	
	local obj
	

	
	do case
	case !m.success
	
	case !ga_Collection_object(@m.obj)
		assert false
		success = false
		
	case !DoDefault()
		assert false
		success = false
		
	case !m.this.AddProperty('Nodes', m.obj)
		assert false
		success = false
	
	case !m.this.Clear()
		assert false
		success = false
		
	endcase
		
	return m.success
	
endfunc
*_______________________________________________________________________________
function Clear()

	local success
	success = true
	
	do case
	case !m.success
	
	case !m.this.Nodes.Clear()
		assert false
		success = false
	
	otherwise
		use in (select('NodeCursor2'))
		
		create cursor NodeCursor ;
		(	Visited		L		default false, ;	&& Circular Info
			Id			I		check (Id > 0) error 'Id >0' default 0, ;
			InDegree	I		check (InDegree >= 0) error 'InDegree >= 0' default 0 ;
		)
		
		index on Id tag Id candidate
		
		create cursor RelationCursor ;
		(	Predecessor	I	check (Predecessor>0), ;
			Successor	I	check (Successor>0) ;
		)
	
	
		index on bintoc(Predecessor) + bintoc(Successor) tag Id candidate

	endcase
	
	return m.success
endfunc
*_______________________________________________________________________________
function AddArc(successor, predecessor)

	
	local success
	success = true
	
	local successorId, predecessorId
	
	with m.this
		do case
		case !m.success
		
		case empty(pCount())
			assert false
			success = false
		
		case !.GetId(m.successor, @m.successorId)
			assert false
			success = false
		
		case inlist(pcount(), 1) or isnull(m.predecessor)
		
		case m.successor == m.predecessor
			assert false message 'Cycle'
			success = false
			
		case !.GetId(m.predecessor, @m.predecessorId)
			assert false
			success = false
		
		case indexseek(	bintoc(m.predecessorId) + bintoc(m.successorId), ;
						false, ;
						'RelationCursor', ;
						'Id' ;
					)
		
		case	(NodeCursor.Id <> m.successorId) ;
			and	!seek(m.successorId, 'NodeCursor')
			
			assert false
			success = false
		
		otherwise
			repl InDegree with InDegree + 1 in NodeCursor
			
			insert into RelationCursor ;
			(	Predecessor, ;
				Successor ;
			) values ;
			(	m.predecessorId, ;
				m.successorId ;
			)
		
		endcase
	
	endwith
	
	return m.success

endfunc
*_______________________________________________________________________________
protected function GetId(node, id)

	local success
	success = true
	
	do case
	case !m.success
	
	case .Nodes.TryGetIndex(transf(m.node), @m.id)
		&& ok
	
	case !.Nodes.AddKeyValue(transf(m.node), m.node)
		assert false
		success = false
	
	otherwise
		insert into NodeCursor ;
		(	Visited, ;
			Id, ;
			InDegree ;
		) values ;
		(	false, ;
			.Nodes.Count, ;
			0 ;
		)
		
		id = NodeCursor.Id
	endcase

	
	return m.success

endfunc
*_______________________________________________________________________________
#if false
	n = Sort(@m.aa)
	
	n: >= 0	: ok, n = # of elements in aa
	n: <0	: error, there is a cycle,  abs(n) = # of elements in aa
#endif
function Sort(aa)

	external array aa
	
	local success
	success = true
	
	local queueObj, n
	
	n = 1
	
	do case
	case !m.success

	&& cycles
	case !m.this.SortToQueue( @m.queueobj)
		success = false
	
	endcase
	
	do case
	case !ga_Type_IsObject(m.queueobj)
	
	case !m.queueobj.ToArray(@m.aa, @m.n)
		assert false
		success = false
	
	endcase
	
	return iif(m.success, m.n, -m.n)

endfunc
*_______________________________________________________________________________
function SortToQueue( queueobj)

	local success
	success = true
	
	local outputQueueObj, processQueueObj, n
	
	
	do case
	case !m.success
	
	case !ga_Queue_Object(@m.outputQueueObj)
		assert false
		success = false
	
	case !ga_Queue_Object(@m.processQueueObj)
		assert false
		success = false
	
	case !m.this.BuildProcessQueue(@m.processQueueObj)
		assert false
		success = false
	
	case !m.this.BuildOutputQueue(m.processQueueObj, m.outputQueueObj)
		assert false
		success = false
	
	case m.outputQueueObj.Count == m.this.Nodes.Count
		&& ok
		queueobj = m.outputQueueObj
		
	case !m.this.BuildCycleInfo(m.outputQueueObj)
		assert false
		success = false
	
	otherwise
		&& contains at least one cycle
		success = false
		queueobj = m.outputQueueObj
	
	endcase
	
	=m.this.Clear()
	
	return m.success

endfunc
*_______________________________________________________________________________
protected function BuildProcessQueue(processQueueObj)

	
	local success
	success = true
	
	do case
	case !m.success
	
	otherwise
		select NodeCursor 
		
		with m.processQueueObj
			scan all for (InDegree == 0) while m.success
				success = .Enqueue(Id)
			
			endscan
		
		endwith
		
	
	endcase
	
	return m.success

endfunc
*_______________________________________________________________________________
protected function BuildOutputQueue(processQueueObj, outputQueueObj)

	local success
	success = true
	
	local nodeId, nodeValue
	
	select RelationCursor
	
	do while m.success and m.processQueueObj.Dequeue(@m.nodeId)
	
		do case
		case !m.this.Nodes.TryGetValue(m.nodeId, @m.nodeValue)
			assert false
			success = false
		
		case !m.outputQueueObj.Enqueue(m.nodeValue)
			assert false
			success = false
		
		otherwise
			=seek(bintoc(m.nodeId))
			
			scan rest while m.success and (Predecessor == m.nodeId)
				
				do case
				case !seek(RelationCursor.Successor, 'NodeCursor')
					assert false
					success = false
				
				case	(NodeCursor.InDegree == 1) ;
					and !m.processQueueObj.Enqueue(NodeCursor.Id)
					
					assert false
					success = false
				
				otherwise
					repl InDegree with InDegree - 1 in NodeCursor
					
				endcase
				
			
			endscan
		endcase
		
	enddo

	return m.success

endfunc
*_______________________________________________________________________________
protected function BuildCycleInfo(queueObj)

	local success
	success = true
	
	do case
	case !m.success
	
	case !m.queueObj.Clear()
		assert false
		success = false
		
	otherwise
		select NodeCursor
		
		&& (1) Delete all Nodes that have been processed
		delete from NodeCursor ;
			where	( InDegree == 0 )
		
		update NodeCursor ;
			set InDegree = 0
		
		
		&& (2) for each node that has not been processed
		&&		place predecessor in InDegree of Successor
		use (dbf('NodeCursor')) again in 0 order Id alias NodeCursor2
		
		scan all while m.success
			
			select RelationCursor
			=seek(bintoc(NodeCursor.Id))
			
			scan rest while m.success and (Predecessor == NodeCursor.Id)
				
				do case
				case !seek(RelationCursor.Successor, 'NodeCursor2')
					assert false
					success = false
				
				case empty(NodeCursor2.InDegree)
					repl InDegree with NodeCursor.Id in NodeCursor2
				
				endcase
			
			endscan && RelationCursor
		
			select NodeCursor
		endscan && NodeCursor
	
	endcase
	
	
	do case
	case !m.success
	
	otherwise
	&& (3) position on first Id that was not output
		locate for InDegree <> 0
		if( !Found() )
			assert false
			success = false
		endif
	
	endcase
	
	
	do case
	case !m.success
	
	otherwise
		&& (4)  mark Predecessors with TRUE Visited fields
		local nextId, nodeValue
		
		nextId = Id
		
		do while m.success and seek(m.nextId) and !Visited
			replace Visited with true
			nextId = InDegree
		
		enddo
	
		&& (5) output 
		nextId = Id
		
		do while m.success and seek(m.nextId) and Visited
		
			replace Visited with false
			nextId = InDegree
			
			do case
			case !m.this.Nodes.TryGetValue(Id, @m.nodeValue)
				assert false
				success = false
			
			case !m.queueObj.Enqueue(m.nodeValue)
				assert false
				success = false
			
			endcase
		
		enddo
	
	endcase
	
	return m.success

endfunc
*_______________________________________________________________________________
enddefine
*===============================================================================
*===============================================================================
*===============================================================================

&& ga_Type
* Gregory Adam 2010
*_______________________________________________________________________________
#include ga_.h
*_______________________________________________________________________________
*_______________________________________________________________________________
*_______________________________________________________________________________
function ga_Type_IsObject(s)
	
	return 	inlist(vartype(m.s), T_OBJECT)

endfunc
*_______________________________________________________________________________
function ga_Type_IsObjectOfBaseClass(s, baseclassname)

	return 	inlist(vartype(m.s), T_OBJECT) ;
		and	( pemstatus(m.s, 'BaseClass', 5) );
		and	( lower(m.s.BaseClass) == lower(m.baseclassname) )
		
	
endfunc
*_______________________________________________________________________________
function ga_Type_IsObjectOfClass(s, classname)

	return 	inlist(vartype(m.s), T_OBJECT) ;
		and	( pemstatus(m.s, 'Class', 5) );
		and	( lower(m.s.Class) == lower(m.classname) )
		
	
endfunc
*_______________________________________________________________________________
function ga_Type_IsChar(s, needFilled)

	return 	inlist(vartype(m.s), T_CHARACTER, T_MEMO) ;
		and not(ga_Type_IsLogical(m.needFilled) and m.needFilled and empty(len(m.s)))
	
endfunc
*_______________________________________________________________________________
function ga_Type_IsLogical(s)

	return 	inlist(vartype(m.s), T_LOGICAL)

endfunc
*_______________________________________________________________________________
function ga_Type_IsCurrency(s)

	return 	inlist(vartype(m.s), T_CURRENCY)

endfunc
*_______________________________________________________________________________
function ga_Type_IsDate(s)

	return 	inlist(vartype(m.s), T_DATE)

endfunc
*_______________________________________________________________________________
function ga_Type_IsDateTime(s)

	return 	inlist(vartype(m.s), T_DATETIME)

endfunc
*_______________________________________________________________________________
function ga_Type_IsNumeric(s)

	return 	inlist(vartype(m.s), T_NUMERIC, T_DOUBLE, 'F', 'I')

endfunc
*_______________________________________________________________________________
function ga_Type_IsInteger(s)

	return ga_Type_IsNumeric(m.s) and empty(mod(m.s, 1))

endfunc
*_______________________________________________________________________________
function ga_Type_IsPositiveInteger(s)
	
	return ga_Type_IsInteger(m.s) and ( m.s > 0 )

endfunc
*_______________________________________________________________________________
function ga_Type_IsNonNegativeInteger(s)
	
	return ga_Type_IsInteger(m.s) and ( m.s >= 0 )

endfunc
*_______________________________________________________________________________
function ga_Type_IsNegativeInteger(s)
	
	return ga_Type_IsInteger(m.s) and ( m.s < 0 )

endfunc
*_______________________________________________________________________________
function ga_type_IsIntegerBetween(i, n1, n2)

	return ga_Type_IsInteger(m.i) and between(m.i, m.n1, m.n2)

endfunc
*_______________________________________________________________________________
function ga_Type_IsArray(aa)
	
	return inlist(type('m.aa', 1), 'A')
	
endfunc
*_______________________________________________________________________________
function ga_Type_IsCollection(obj)

	return	ga_Type_IsObjectOfBaseClass(m.obj, 'Collection')
endfunc
*_______________________________________________________________________________
function ga_Type_IsNakedCollection(obj)

	return	ga_Object_HasMethod(m.obj, 'Item') ;
		and	ga_Object_HasProperty(m.obj, 'Count')
endfunc
*_______________________________________________________________________________
function ga_Type_IsDictionary(obj)

	return	ga_Type_IsObjectOfClass(m.obj, GA_DICTIONARY_CLASS	)
endfunc
*_______________________________________________________________________________
function ga_Type_IsNakedDictionary(obj)

	return	ga_Type_IsNakedCollection(@m.obj) ;
		and	ga_Object_HasMethod(m.obj, 'TryGetValue') ;
		and	ga_Object_HasMethod(m.obj, 'ContainsKey')
endfunc
*_______________________________________________________________________________
function ga_Type_IsEnumerable(obj)
	
	local isEnum, x

	try
		for each x in m.obj foxobject && obj : a Visual FoxPro array, an OLE array, a Visual FoxPro collection, or an OLE collection.
*			isEnum = true
			exit
		endfor
		isEnum = true
	catch
	endtry

	return m.isEnum
endfunc
*_______________________________________________________________________________
function ga_type_IsWindowName(s)

	return ga_type_IsChar(m.s, true) ;
		and	( isalpha(m.s) or (left(m.s, 1) == '_')) 

endfunc
*_______________________________________________________________________________
&& ga_Byte
* Gregory Adam 2011
*_______________________________________________________________________________
#include ga_.h
*_______________________________________________________________________________
function ga_byte_IsHex(b)

	return  between(m.b, GA_BYTE_0, GA_BYTE_9) ;
		or	between(m.b, GA_BYTE_a_LOWER, GA_BYTE_f_LOWER) ;
		or 	between(m.b, GA_BYTE_a_UPPER, GA_BYTE_f_UPPER)
endfunc
*_______________________________________________________________________________
function ga_byte_IsAlphaNumeric(b)

	return  between(m.b, GA_BYTE_0, GA_BYTE_9) ;
		or	between(m.b, GA_BYTE_a_LOWER, GA_BYTE_z_LOWER) ;
		or 	between(m.b, GA_BYTE_a_UPPER, GA_BYTE_z_UPPER)
endfunc
*_______________________________________________________________________________
&& ga_memory
* Gregory Adam 2011
*_______________________________________________________________________________
#include ga_.h

*_______________________________________________________________________________
function memory_defined(lMemo)
	
	local a123456789012345, aa, bb, cFile

	a123456789012345 = ''
	a123456789012345 = Null
	
	aa = ''
	aa = Null
	
	bb = $123456789.12

	if Pcount() > 0
		create cursor xx(xx M NOCPTRANS )
		save to memo xx
		=MemFileShow(xx.xx, 'Mem_Defined')
	else
		cFile = FullPath('..\tmp\mem.txt')
		delete file (m.cFile)
		save to (m.cFile)
		=MemFileShow(m.cFile, 'Mem_Defined')
	endif

endfunc

*_______________________________________________________________________________
function Mem_Defined (VariableType, VariableName, VariableScope, VariableValue, VariableRow, VariableCol)

	local s
	
	do case
	&& array declaration
	case VariableType = 'A'
		s = VariableScope + ' ' + VariableName + '[' + ltrim(str(VariableRow,18,0))
		if( !empty(VariableCol) )
			s = s + ', ' + ltrim(str(VariableCol,18,0))
		endif
		s = s + ' ]'
		?s
	
	&& normal variable
	case empty(VariableRow)
		s = VariableType + ': ' + VariableScope + ' ' + VariableName
		? s, VariableValue
	
	&& array element
	otherwise
		s = VariableType + ': ' + VariableName + '[' + ltrim(str(VariableRow,18,0))
		if( !empty(VariableCol) )
			s = s + ', ' + ltrim(str(VariableCol,18,0))
		endif
		s = s + ' ]'
		? s, VariableValue
	endcase
endfunc

*_______________________________________________________________________________
function memory_public && variables PUBLIC
	lparameters nPublic
	nPublic = Evl(m.nPublic, 500)

	result = ''

	local iPublic, cPublics, cFile
	
	cPublics = ''
	for iPublic = 1 to m.nPublic
		cPublics = m.cPublics;
			+ ',Public';
			+ Padl(m.iPublic, 3, '0');
			+ Iif(m.iPublic%10 = 0, '[10]', '')
	endfor
	cPublics = Substr(m.cPublics, 2)

	public &cPublics

	store 10 to &cPublics

	Public001 = CreateObject('Empty') && pas sauvegardée
	&& >> l'utilisateur doit déclarer à awAppHost les variables PUBLIC de type Objet

	cFile = FullPath('..\tmp\mem.txt')
	delete file (m.cFile)

	addProperty(_Screen, 'nSecs1', Seconds())
	save to (m.cFile) all except result && Object type variables cannot be saved to a variable file or memo field. does not support saving arrays exceeding 65,000 elements.
	addProperty(_Screen, 'nSecs1', Seconds() - _Screen.nSecs1)

	addProperty(_Screen, 'nSecs2', Seconds())
	MemFileShow(m.cFile, 'Mem_Public')
	addProperty(_Screen, 'nSecs2', Seconds() - _Screen.nSecs2)

	addProperty(_Screen, 'nSecs3', Seconds())
	restore from (m.cFile) additive
	addProperty(_Screen, 'nSecs3', Seconds() - _Screen.nSecs3)
	
	clear
	? Substr(m.result, 2); && _Screen.result
		, m.nPublic, 'variables';
		, _Screen.nSecs1 + _Screen.nSecs2 + _Screen.nSecs3; && 500 : 130 ms
		, _Screen.nSecs1; && 500 : 020 ms
		, _Screen.nSecs2; && 500 : 100 ms
		, _Screen.nSecs3 && 500 : 010 ms

	cPublics = Chrtran(m.cPublics, '[10]', '')
	release &cPublics
	removeProperty(_Screen, 'nSecs1')
	removeProperty(_Screen, 'nSecs2')
	removeProperty(_Screen, 'nSecs3')

endfunc

*_______________________________________________________________________________
function Mem_Public
	lparameters VariableType, VariableName, VariableScope, VariableValue, VariableRow, VariableCol

	result = m.result + Iif(.T.;
		and m.VariableScope == 'Public';
		and not ',' + m.VariableName $ m.result;
		, ',' + m.VariableName;
		, '';
		)
endfunc


*_______________________________________________________________________________
*	00-10	char[11] upper(name) '\0 terminated
*	11-11	char Type, if lower(): extended name, except 0 (Null)
*	12-15 	length strings > 254 ( type H)
*	16-16	Length (including \0 for strings)
*	17-17	precision for numeric
*	20-23 ??
*	24-24	0x00 = Private/public, 0x01 = local
*	25-25	constant : 0x03
*	26-31 ?
&& case extended name
*	32-33	len Name if extended name
*	34-...	name
*	..-..	Value
&& otherwise
*	32 -	Value
*
* aug 09 2003	: corrected currency values, stored in 64 bit

#ifndef	TRUE
	#define TRUE	.T.
	#define	FALSE	.F.
#endif

#ifndef VOID
	#define	DWORD	Long
	#define	WORD	Short
	#define Size_T	DWORD
	#define T_HANDLE	Integer
	#define BOOL	Integer
	#define POINTER	Integer
	#define LPCVOID	POINTER
	#define VOID
	#define	CHAR	String
	#define	UCHAR	integer
	
	#define	HKEY	Long
	#define LPCTSTR	String @
	#define LPTSTR	String @
	#define	REGSAM	integer
	#define	PHKEY	HKEY @
	#define	LPDWORD	DWORD @
	#define LPBYTE	String @
	#define	PFILETIME string @
#endif

#define	FAILURE	(-1)

#define EOF_MEMFILE	0x1A

*_______________________________________________________________________________
function MemFileShow(FileName, FunctionName)
	
	local m.success
	success = TRUE

	local junk;
	, fd, FileOffset, c, buf, n;
	, sDate, sCentury, sDecimals;
	, FunctionStatement;
	, OffsetValue;
	, HaveArray;
	, nRows, nCols;
	, VariableRow;
	, VariableCol;
	, VariableType;
	, VariableName;
	, VariableLength;
	, VariableDecimals;
	, VariableScope;
	, VariableValue
	
	fd = fopen(FileName, F_READONLY)
	
	do case

	case m.fd > 0 && mem file
		FileOffset = 0

	case vartype(FileName) == T_CHARACTER && field or variable containing the mem
		fd = FileName
		FileOffset = 2	&& find 0x4d0f in front

	otherwise
		assert FALSE
		return FALSE
	endcase

	sDate = set('Date')
	sCentury = Set('Century')
	sDecimals = set('Decimals')
	set date ymd
	set century on
	set asserts on

	FunctionStatement = FunctionName + '(m.VariableType, m.VariableName, m.VariableScope, m.VariableValue, m.VariableRow, m.VariableCol)'
	VariableRow = 0
	VariableCol = 0

	do while m.success

		c = fgetc_at(m.fd, m.FileOffset)
		
		do case
		case (m.c == FAILURE)
			assert FALSE
			success = FALSE
			
		case (m.c == EOF_MEMFILE)
			do case
			case vartype(m.fd) == T_CHARACTER
				assert m.FileOffset+1 == len(m.fd)
			otherwise
				assert feof(m.fd)
			endcase
			* =====
			exit
			* =====

		otherwise
			do case
			case vartype(m.fd) == T_CHARACTER
				assert m.FileOffset+1 <> len(m.fd)
			otherwise
				assert !feof(m.fd)
			endcase
	
		endcase
		
		&& VariableType
		do case
		case !m.success
		otherwise
			VariableType = upper(chr(fgetc_at(m.fd, m.FileOffset+11)))
		endcase
		
		&& VariableName
		do case
		case !m.success
		case !empty(m.c) && isUpper(chr(m.VariableType))
			OffsetValue = 0
			VariableName = strtran(fread_at(m.fd, m.FileOffset, 10), chr(0))
		otherwise
			OffsetValue = CharToBin(fread_at(m.fd, m.FileOffset+32, 2)) + 2
			VariableName = fread_at(m.fd, m.FileOffset+34, m.OffsetValue - 2)
		endcase
		
		&& VariableScope
		c = fgetc_at(m.fd, m.FileOffset+24)
		do case
		case !m.success
		case m.c == FAILURE
			assert FALSE
			success = FALSE
		case m.c = 0x00
			VariableScope = 'Public'
		case m.c = 0x01
			VariableScope = 'Local'
		otherwise
			assert FALSE
			success = FALSE
		endcase
		
		do case
		case !m.success
		otherwise
			VariableLength = fgetc_at(m.fd, m.FileOffset+16)
			VariableDecimals = fgetc_at(m.fd, m.FileOffset+17)
		endcase
		
		do case
		case !m.success
		case fgetc_at(m.fd, m.FileOffset+24) = 0x03
			assert FALSE
			success = FALSE
		endcase
		
		&& m.VariableValue
		do case
		case inlist(m.VariableType, '0')
			assert m.VariableLength = 1
			VariableType = fread_at(m.fd, m.FileOffset+32+m.OffsetValue, 1)
			do case
			case inlist(m.VariableType, T_CHARACTER)
				VariableValue = ''
			case inlist(m.VariableType, T_LOGICAL)
				VariableValue = FALSE
			case inlist(m.VariableType, T_NUMERIC)
				VariableValue = 0
			case inlist(m.VariableType, T_DATE)
				VariableValue = {}
			case inlist(m.VariableType, T_DATETIME)
				VariableValue = dtot({})
			case inlist(m.VariableType, T_CURRENCY)
				VariableValue = $0
			otherwise
				assert FALSE
				success = FALSE
			endcase
			
			VariableValue = Null
			

		case inlist(m.VariableType, T_CHARACTER)	&& len <= 254, ie <=255 \0 included
			VariableValue = fread_at(m.fd, m.FileOffset +32 + m.OffsetValue, m.VariableLength - 1)
		

		case inlist(m.VariableType, 'H')	&& Character (Huge ??)
			VariableLength = CharToBin(fread_at(m.fd, m.FileOffset+12, 4))
			VariableValue = fread_at(m.fd, m.FileOffset +32 + m.OffsetValue, m.VariableLength - 1)
			

		case inlist(m.VariableType, T_LOGICAL)
			assert m.VariableLength = 1
			
			c = fgetc_at(m.fd, m.FileOffset+32+m.OffsetValue)
			do case
			case m.c == FAILURE
				assert FALSE
				success = FALSE
			case m.c == 0x00
				VariableValue = FALSE
			case m.c == 0x01
				VariableValue = TRUE
			otherwise
				assert FALSE
			endcase
		

		case inlist(m.VariableType, T_NUMERIC)
			declare	VOID RtlMoveMemory in win32api Double @Dest, Char @Src, Size_T BytesToCopy
			&& 1			: 0a 00
			&& 1.1		: 0c 01
			&& 1.12		: 0d 02
			&& 1.123	: 0e 03
			&& 1.1234	: 0f 04
			&& 1/3		: 0d 02 depends on set decimals when division was done
			c = fread_at(m.fd, m.FileOffset + 32 + m.OffsetValue, 8)
			set decimals to (VariableDecimals)
			VariableValue = 10^(-VariableDecimals) 
			VariableLength = 8
			=RtlMoveMemory(@m.VariableValue, @m.c, m.VariableLength)
			

		case inlist(m.VariableType, T_DATE)
			declare	VOID	RtlMoveMemory in win32api Double @Dest, Char @Src, Size_T BytesToCopy
			set decimals to 0
			c = fread_at(m.fd, m.FileOffset +32 + m.OffsetValue, 8)
			VariableValue = 0
			VariableLength = 8
			=RtlMoveMemory(@m.VariableValue, @m.c, m.VariableLength )
			c = m.VariableValue
			do case
			case empty(m.c)
				VariableValue = {}
			otherwise
				VariableValue = sys(10, int(m.c))
				VariableValue = date(;
										val(left(m.VariableValue,4)), ;
										val(substr(m.VariableValue,6,2)), ;
										val(substr(m.VariableValue,9,2)) ;
									)
			endcase
	

		case inlist(m.VariableType, T_DATETIME)
			declare	VOID	RtlMoveMemory in win32api Double @Dest, Char @Src, Size_T BytesToCopy
			set decimals to 18
			c = fread_at(m.fd, m.FileOffset +32 + m.OffsetValue, 8)
			VariableValue = 10^(-10)
			VariableLength = 8
			=RtlMoveMemory(@m.VariableValue, @m.c, m.VariableLength )
			c = m.VariableValue
			do case
			case empty(m.c)
				VariableValue = dtot({})
			otherwise
				VariableValue = sys(10, int(m.c))
				VariableValue = dateTime(;
											val(left(m.VariableValue,4)), ;
											val(substr(m.VariableValue,6,2)), ;
											val(substr(m.VariableValue,9,2)) ;
										) + round( mod(m.c,1) * 86400, 0)
			endcase


		case inlist(m.VariableType, T_CURRENCY)
			declare	VOID	RtlMoveMemory in win32api double @Dest, Char @Src, Size_T BytesToCopy
			declare integer sprintf in msvcrt.dll string@, string@, double
			
			VariableValue = 0.00
			VariableLength = 8
			
			c = fread_at(m.fd, m.FileOffset +32 + m.OffsetValue, 8)
			=RtlMoveMemory(@m.VariableValue, @m.c, m.VariableLength )
			buf = space(32)
			n = sprintf(@m.buf, "%I64d", m.VariableValue)
			buf = '$' + stuff(left(m.buf, m.n), m.n-3, 0, '.')
			
			VariableValue = val(m.buf)
	
		case inlist(m.VariableType, 'A')	&& array declaration
			assert !m.HaveArray
			
			VariableRow = CharToBin(fread_at(m.fd, m.FileOffset +32 + m.OffsetValue + 0, 2))
			VariableCol = CharToBin(fread_at(m.fd, m.FileOffset +32 + m.OffsetValue + 2, 2))
			HaveArray = TRUE
			nRows = Null
			nCols = 0
			VariableLength = 4

		otherwise
			assert FALSE
			success = FALSE
		endcase
		
		do case
		case !m.success
		
		otherwise
			=Eval(m.FunctionStatement)
			FileOffset = m.FileOffset + 32 + m.OffsetValue + m.VariableLength
		endcase
		
		if m.HaveArray
			do case
			case isnull(m.nRows) && just after declaration
				nRows = m.VariableRow 
				nCols = m.VariableCol 
				VariableRow = 1
				VariableCol = iif(empty(m.nCols), 0, 1)
			
			case (m.nRows = m.VariableRow) and (m.nCols = m.VariableCol) && entire array done
				VariableRow = 0
				VariableCol = 0
				HaveArray = FALSE
			
			case empty(m.nCols) && one dimensional array
				VariableRow = m.VariableRow + 1
			
			otherwise && two dimensional array
				VariableCol = m.VariableCol + 1
				if(m.VariableCol > m.nCols)
					VariableCol = 1
					VariableRow = m.VariableRow + 1
				endif
			endcase
		endif
	enddo
	
	if( vartype(m.fd) == T_NUMERIC )
		=fclose(m.fd)
	endif
	
	set date (sDate)
	set Century &sCentury
	set Decimals to (sDecimals)

	return m.success
endfunc

*_______________________________________________________________________________
function	fgetc_at(fd, Offset)
	
	return ICase(;
		vartype(m.fd) == T_CHARACTER,;
			asc(substr(m.fd, m.Offset+1, 1)),;
		m.Offset <> fseek(m.fd, m.Offset, 0),;
			FAILURE,;
			asc(fread(m.fd, 1));
		)
	
endfunc

*_______________________________________________________________________________
function	fread_at(fd, Offset, nBytes)

	return ICase(;
		vartype(m.fd) == T_CHARACTER,;
			substr(m.fd, m.Offset+1, m.nBytes),;
		m.Offset <> fseek(m.fd, m.Offset, 0),;
			FAILURE,;
			fread(m.fd, m.nBytes);
		)

endfunc

************************************************************************
FUNCTION CharToBin
******************
*** Function: Converts a DWORD value in binary string form back into
***      a numeric value
***   Pass: tcWord -  Binary string value (from a structure?)
***  Return: numeric value of binary string
*************************************************************************
LPARAMETER tcWord

 LOCAL i, lnWord

 lnWord = 0
 FOR i = 1 TO LEN(m.tcWord)
  lnWord = m.lnWord + (ASC(SUBSTR(m.tcWord, m.i, 1)) * (2 ^ (8 * (m.i - 1))))
 ENDFOR

RETURN m.lnWord
&& ga_RegEx
* Gregory Adam 2010
*_______________________________________________________________________________
#include ga_.h

*_______________________________________________________________________________
function ga_Regex_Object(obj, global, ignoreCase, pattern, multiLine)

	return ga_Object_Create(;
					@m.obj, ;
					GA_REGEX_CLASS, ;
					m.global, ;
					m.ignoreCase, ;
					m.pattern, ;
					m.multiLine ;
			)

endfunc

*===============================================================================
*===============================================================================
*===============================================================================
define class GA_REGEX_CLASS as GA_LIGHTWEIGHT_CLASS

	protected	RegexObj
	
	RegexObj	= null
	
	Global		= false		&& with assign
	IgnoreCase	= false		&& with assign
	Pattern		= ''		&& with assign
	MultiLine	= false		&& with assign
	
*_______________________________________________________________________________
protected function Init(global, ignoreCase, pattern, multiLine)

	local success
	success = true
	
	local obj
	
	do case
	case !m.success
	
	case !DoDefault()
		assert false
		success = false
	
	case !ga_Object_Create(@m.obj, REGEX_CLASS)
		assert false
		success = false
	
	otherwise
		this.RegexObj	= m.obj
		
		try
			this.Global		= m.global
			this.IgnoreCase	= m.ignoreCase
			this.Pattern	= evl(m.pattern, m.this.Pattern)
			this.MultiLine	= m.multiLine
		catch
			assert false
			success = false
		
		endtry
		
	endcase

	return m.success
	
endfunc
*_______________________________________________________________________________
protected function Destroy()

	store null to ;
		this.RegexObj
	
	return DoDefault()
	
endfunc
*_______________________________________________________________________________
protected function Global_Assign(global)

	do case
	case !ga_Type_IsLogical(m.global)
		GA_ERROR_FUNCTION_ARGUMENT_INCORRECT, 'Global'
	
	otherwise
		store m.global to this.Global, m.this.RegexObj.Global
	
	endcase
	
endfunc
*_______________________________________________________________________________
protected function IgnoreCase_Assign(ignoreCase)

	do case
	case !ga_Type_IsLogical(m.ignoreCase)
		ga_ERROR_FUNCTION_ARGUMENT_INCORRECT, 'IgnoreCase'
	
	otherwise
		store m.ignoreCase to this.IgnoreCase, m.this.RegexObj.IgnoreCase
	
	endcase
	
endfunc
*_______________________________________________________________________________
protected function Pattern_Assign(pattern)

	do case
	case !ga_Type_IsChar(m.pattern)
		ga_ERROR_FUNCTION_ARGUMENT_INCORRECT, 'Pattern'
	
	otherwise
		store m.pattern to this.Pattern, m.this.RegexObj.Pattern
	
	endcase
	
endfunc
*_______________________________________________________________________________
protected function MultiLine_Assign(multiLine)

	do case
	case !ga_Type_IsLogical(m.multiLine)
		ga_ERROR_FUNCTION_ARGUMENT_INCORRECT, 'MultiLine'
	
	otherwise
		store m.multiLine to this.MultiLine, m.this.RegexObj.MultiLine
	
	endcase
	
endfunc
*_______________________________________________________________________________
function Test(s)
	
	return m.this.RegexObj.Test(@m.s)

endfunc
*_______________________________________________________________________________
function Execute(s)

	return m.this.RegexObj.Execute(@m.s)

endfunc
*_______________________________________________________________________________
function GetMatches(matchesObj, s)
	
	matchesObj = m.this.RegexObj.Execute(@m.s)
	
endfunc
*_______________________________________________________________________________
function GetMatchQueue(matchQueueObj, s, reverse)

	local success
	success = true
	
	do case
	case !m.success
	
	case !ga_Type_IsLogical(@m.reverse)
		assert false
		success = false
		
	case !ga_Queue_Object(@m.matchQueueObj)
		assert false
		success = false
	
	otherwise
		local i, matchesObj, matchObj
		matchesObj = m.this.RegexObj.Execute(@m.s)
		
		do case
		case !m.reverse
			for each matchObj in m.matchesObj
				
				if( !m.matchQueueObj.Enqueue(m.matchObj) )
					assert false
					success = false
					exit
				endif
			endfor
			
		otherwise
			with m.matchesObj
				for i = .Count -1 to 0 step -1
					if( !m.matchQueueObj.Enqueue(.Item[m.i]) )
						success = false
						exit
					endif
				endfor
			endwith
		endcase
		
	endcase
		
	return m.success

endfunc
*_______________________________________________________________________________
function Replace(s, replacement)
	
	return m.this.RegexObj.Replace(m.s, m.replacement)
endfunc
*_______________________________________________________________________________
enddefine
*===============================================================================
*===============================================================================
*===============================================================================
&& ga_StringParse
* Gregory Adam 2010
*_______________________________________________________________________________
#include ga_.h

&& thn 28/10/13 - refactored .MaskParentheses()
&& thn 28/10/13 - added 3rd parameter in .MaskParentheses(@m.masked, m.origin, funcParms)
		&& funcParms && [.F.] keep function parameters separated by ','
*_______________________________________________________________________________
function ga_StringParse_Test

local success as Boolean;
, obj;
, nSecond as Number;
, nTest as Number;
, masked as String;

nSecond = Seconds()

success = ga_StringParse_Object(@m.obj);
	and m.obj.MaskStrings(;
		  @m.masked;
		, 'hello("[") + ["""""""""""] ' + "+ '[]'";
		);
	and m.masked;
		==[hello(~~~) + ~~~~~~~~~~~~~ + ~~~~];
	and m.obj.MaskStrings(;
		  @m.masked;
		, "func('titi \' titi', 3, 'toto \' toto')";
		, .T.;
		);
	and m.masked;
		=="func(~~~~~~~~~~~~~~, 3, ~~~~~~~~~~~~~~)";
	and .T.

nTest = 1

return Textmerge([<<m.success>>, <<(Seconds()-m.nSecond)*1000/m.nTest>> ms.])

*_______________________________________________________________________________
function ga_StringParse_Object(obj)
	return ga_Object_Create(@m.obj, GA_STRINGPARSE_CLASS)
endfunc

*===============================================================================
*===============================================================================
*===============================================================================
define class GA_STRINGPARSE_CLASS as GA_LIGHTWEIGHT_CLASS
	
	protected RegexStringStart
 	
	RegexStringStart = .null.

*_______________________________________________________________________________
protected function Init()

	local success, obj
	success = true
	
	do case
	
	case !DoDefault()
		assert false
		success = false
	
	case !ga_Regex_Object(@m.obj, false, false, '[[' + ["'] + ']', false) && pattern = '[["']'
		assert false
		success = false
	
	case !m.this.AddProperty('RegexStringStart', m.obj)
		assert false
		success = false
	
	endcase

	return m.success
endfunc

*_______________________________________________________________________________
protected function Destroy()

	store null to this.RegexStringStart
	
	return DoDefault()
endfunc

*_______________________________________________________________________________
function MaskStrings(masked, origin, JSstring)

	local success;
	, RegexStringStart;
	, matchesObj, matchObj, v, c, s, o, n

	success = true
	RegexStringStart = m.this.RegexStringStart
	
	do case
	
	case !ga_Type_IsChar(@m.origin)
		assert false
		success = false
		GA_ERROR_FUNCTION_ARGUMENT_INCORRECT
		
	otherwise

		JSstring = ga_Type_IsLogical(m.JSstring) and m.JSstring
		masked = m.origin

		do while m.success ;
			and	m.RegexStringStart.GetMatches(@m.matchesObj, m.masked) ;
			and	m.matchesObj.Count > 0 && 0 ou 1 car le pattern est !global
		
*!*				if m.matchesObj.Count <> 1 && thn 2014-09-02 - cas impossible
*!*					assert false
*!*					success = false
*!*					exit
*!*				endif
			
			matchObj = m.matchesObj.Item(0)
			v = m.matchObj.Value
			c = iif(m.v == '[', ']', m.v)
			s = substrc(m.masked, m.matchObj.FirstIndex+2) && FirstIndex is 0-based
			o = 1
			do while .T.
				n = at_c(m.c, m.s, m.o)
				if .F.;
				 or m.n <= 1;
				 or !(m.JSstring and Substrc(m.s, m.n-1, 1) == '\') && Substrc('toto', 0, 1) fonctionne
					exit
				else
					o = m.o + 1
				endif
			enddo
		
			if Empty(m.n)
				assert false message [String delimiter mismatch]
				success = false
				exit
				
			else
				n = 1 + m.n && include start delimiter
				masked = stuffc( ;
						m.masked, ;
						m.matchObj.FirstIndex+1, ; && FirstIndex is 0-based
						m.n, ;
						replicate('~', m.n) ;
						) 

			endif
		enddo
	endcase
	
	return m.success
endfunc

*_______________________________________________________________________________
function MaskParentheses as Boolean
lparameters ;
  masked; && @ masked statement
, origin; && @ original statement
, funcParms && [.F.] keep function parameters separated by ',' && thn added 28/10/13

&& see ga_StringParse_Test() at bof()

	local success as Boolean
	success = true
	
	do case
	
	case !ga_Type_IsChar(@m.origin)
		assert false
		success = false
		GA_ERROR_FUNCTION_ARGUMENT_INCORRECT
		
	otherwise

		local l, c, iOpen, nOpen, iClose, s_repl

		masked = m.origin
		l = lenc(m.masked)
		store 0 to iOpen, nOpen, iClose

		do while m.success and (m.iOpen <= m.l)

			iOpen = m.iOpen + 1
			c = substrc(m.masked, m.iOpen, 1)
			
			do case
			case m.c $ '(['

				s_repl = ''
				nOpen = 1
				iClose = m.iOpen
				
				do while m.success and (m.iClose <= m.l)

					iClose = m.iClose + 1
					c = substrc(m.masked, m.iClose, 1)
					
					do case
					case m.c $ '(['
						nOpen = m.nOpen + 1
						s_repl = m.s_repl + '~'
					
					case m.c $ ')]'

						nOpen = m.nOpen - 1
						if Empty(m.nOpen)

							masked = stuffc(;
								  m.masked;
								, m.iOpen + 1;
								, m.iClose - m.iOpen - 1;
								, Iif(m.funcParms;
									, m.s_repl;
									, replicate('~', m.iClose - m.iOpen - 1);
									);
								)
							iOpen = m.iClose
							exit
						else
							s_repl = m.s_repl + '~'
						endif
						
					case m.funcParms and m.c == ','
						s_repl = m.s_repl + ','
					
					case m.funcParms
						s_repl = m.s_repl + '~'
					endcase
				enddo
				
				do case

				case m.nOpen <> 0
					assert false message 'Parentheses mismatch'
					success = false

				case m.funcParms
					masked = Leftc(m.masked, m.iClose)
					origin = Leftc(m.origin, m.iClose)
					exit
				endcase
				
			case m.c $ ')]'
				assert false message 'Parentheses mismatch'
				success = false
				
			otherwise
				loop

			endcase
		enddo
	endcase

	return m.success
	
endfunc

*_______________________________________________________________________________
function MaskParentheses_old(masked, origin)
&& utilisé par modify command ga_doformstatementparser GA_DOFORMSTATEMENTPARSER_CLASS.DoFormTransform_Analyse()

	local success
	success = true
	
	do case
	
	case !ga_Type_IsChar(@m.origin)
		assert false
		success = false
		GA_ERROR_FUNCTION_ARGUMENT_INCORRECT
		
	otherwise
		masked = m.origin
		
		local nOpen, nClose
		
		do while m.success
			
			nOpen = ratc('(', m.masked)
			
			if( empty(m.nOpen) )
				exit
			endif
			
			nClose = 1 + at_c(')', substrc(m.masked, m.nOpen+1))
			
			if( m.nClose == 1 )
				assert false
				success = false
			
			else
				masked = stuffc(m.masked, m.nOpen, m.nClose, repl('~', m.nClose))
				
			endif
			
		enddo
		
		do case
		case !m.success
		
		case !empty(at_c(')', m.masked))
			assert false
			success = false
		
		endcase
		
	endcase
	
	return m.success
	
endfunc


*_______________________________________________________________________________
enddefine
*===============================================================================
*===============================================================================
*===============================================================================
&& md5Bits
&& (c) Gregory Adam 2008
*_______________________________________________________________________________
#include ga_.h

&& MakeOut() va intégrer ce prg dans un autre, aucune instruction ici !

*---------------------------------------------------------------------------
function md5_test
local obj, Digest

if( !md5Bits_Object(@m.obj) )
  ? 'probleme Version windows'
  return
endif

&& usage # 1
=m.obj.DigestString("message digest", @m.Digest)
? ath(m.Digest) && f96b697d7cb7938d525a2f31aaf161d0

&& usage # 2
=m.obj.Update("message ")
=m.obj.Update("digest")
=m.obj.Final(@m.Digest)
? ath(m.Digest) && f96b697d7cb7938d525a2f31aaf161d0

*---------------------------------------------------------------------------
function md5Bits_Object(obj)

	obj = null
	try
		obj = CreateObject(MD5BITS_CLASS) && see ga_.h
	endtry
	
	return inlist(vartype(m.obj), T_OBJECT)
endfunc

*---------------------------------------------------------------------------
#define MD5STRUCTLENGTH	(104) &&  2*4 + 4*4 + 64 + 16
#define MD5_FILEREAD_BUFSIZ	(8192)
#define TESTSUITE_COMPILE	FALSE
*===============================================================================

*-------------------------------------------------------------------------------
#if FALSE
	functions
		- Update(string)
		- Final(@m.Digest)

		- DigestString(string, @m.Digest)
		- DigestFile(FileName, @m.Digest)
#endif

#if TESTSUITE_COMPILE
function md5_tests()
	local obj
	assert md5Bits_Object(@m.obj)
	assert m.obj.TestSuite()
endfunc
#endif

*-------------------------------------------------------------------------------
function ath(s)	&& ascii to hex
	return strconv(m.s, 15)
endfunc

*--------------------------------------------------------------------------------
function hta(s)	&& hex to ascii
	return strconv(m.s, 16)
endfunc
*--------------------------------------------------------------------------------

*===============================================================================
define class MD5BITS_CLASS as GA_LIGHTWEIGHT_CLASS
	
	md5struct = space(MD5STRUCTLENGTH)
	
*-------------------------------------------------------------------------------
protected function init()

	local Success
	Success = TRUE
	
	do case
	case !m.Success
	
	case !DoDefault()
		assert FALSE
		Success = FALSE
	
	case !m.this.Declares()
		assert FALSE
		Success = FALSE
		
	case !m.this.md5_init()
		assert FALSE
		Success = FALSE
		
	endcase
		
	return m.Success
endfunc
*-------------------------------------------------------------------------------
protected function md5_init()
	
	local md5struct
	store m.this.md5struct to md5struct
	= md5init(@m.md5struct)
	store m.md5struct to this.md5struct
endfunc
*--------------------------------------------------------------------------------
function Update(s)
	
	local md5struct
	store m.this.md5struct to md5struct
	=md5Update(@m.md5struct, @m.s, len(m.s))
	store m.md5struct to this.md5struct
	
endfunc
*--------------------------------------------------------------------------------
function final(Digest)
	
	local md5struct
	store m.this.md5struct to md5struct
	=MD5Final(@m.md5struct)
	
	Digest = substr(m.md5struct, 89)
	=m.this.md5_init()
endfunc
*-------------------------------------------------------------------------------
function DigestString(s, Digest)
	
	return m.this.Update(@m.s) and m.this.Final(@m.Digest)
endfunc
*-------------------------------------------------------------------------------
function DigestFile(FileName, Digest)
	
	with m.this
		local fd, i, FileSize
		
		fd = fopen(m.FileName)
		
		if( m.fd < 0 ) 
			return FALSE
		endif
		
		
		FileSize = fseek(m.fd, 0, 2)
		=fseek(m.fd, 0, 0)
		
		
		for i = 1 to int(m.FileSize /MD5_FILEREAD_BUFSIZ)
			if( !.update(fread(m.fd, MD5_FILEREAD_BUFSIZ)) )
				assert FALSE
				=fclose(m.fd)
				return FALSE
			endif
		endfor
		
		=empty(mod(m.FileSize, MD5_FILEREAD_BUFSIZ)) or .update(fread(m.fd, MD5_FILEREAD_BUFSIZ))
		
		=fclose(m.fd)
		
		= .final(@m.Digest)
	
	
	endwith
endfunc
*--------------------------------------------------------------------------------
protected function Declares()
	
	local Success
	Success = TRUE
	
	try
		declare MD5Init in Cryptdll.dll ;
			string @Context
			
		declare MD5Update in Cryptdll.dll ;
			string @Context, ;
			string @Input, ;
			long inputlen 
		
		declare MD5Final in Cryptdll.dll ;
			string @Context

	catch
		assert FALSE
		Success = FALSE
	
	endtry 
	return m.Success

endfunc
*--------------------------------------------------------------------------------
*-------------------------------------------------------------------------------

*--------------------------------------------------------------------------------
#if TESTSUITE_COMPILE
*--------------------------------------------------------------------------------
function TestSuite()
	
	Local Success
	Success = TRUE
	
	with m.this
	
		do case
		case !m.Success
#if TRUE		
		case !.TestString("", "d41d8cd98f00b204e9800998ecf8427e")
			assert FALSE
			Success = FALSE
			
		case !.TestString("a", "0cc175b9c0f1b6a831c399e269772661")
			assert FALSE
			Success = FALSE
			
		case !.TestString("abc", "900150983cd24fb0d6963f7d28e17f72")
			assert FALSE
			Success = FALSE
		
		case !.TestString("message digest", "f96b697d7cb7938d525a2f31aaf161d0")
			assert FALSE
			Success = FALSE
		
		case !.TestString("abcdefghijklmnopqrstuvwxyz", "c3fcd3d76192e4007dfb496cca67e13b")
			assert FALSE
			Success = FALSE
#endif		
		case !.TestString("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789", ;
							 "d174ab98d277d9f5a5611c2c9f419d9f")
			assert FALSE
			Success = FALSE
		
		case !.TestString("12345678901234567890123456789012345678901234567890123456789012345678901234567890", ;
				"57edf4a22be3c955ac49da2e2107b67a")
		
			assert FALSE
			Success = FALSE
		
		endcase
	
	endwith
	
	return m.Success
endfunc
*--------------------------------------------------------------------------------
function TestString(Input, Output)

	local Digest
	
	=this.DigestString(Input, @Digest)
	Digest = ath(m.Digest)
	
	acti screen
	do case
	case upper(m.Digest) == upper(m.Output)
		? 'OK', Input, output
		
		return TRUE
	otherwise
		? 'Fail', Input
		? 'exp ', upper(Output)
		? 'got ', upper(Digest)

		return FALSE
	endcase
endfunc
*--------------------------------------------------------------------------------
#endif
enddefine
*===============================================================================
*===============================================================================
*===============================================================================
