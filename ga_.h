&& ga_.h
&& (c) Gregory Adam 2011
*_______________________________________________________________________________
#ifndef _ab_ga_h
	#define _ab_ga_h

*_______________________________________________________________________________
&& #include	ac.h
#include FoxPro.h
*_______________________________________________________________________________
#define true	.t.
#define false	.f.

#define GA_ISRUNTIME	empty(Version(2))
*_______________________________________________________________________________
#define GA_EXECUTING_FUNCTION	Lower(program(program(-1))) + '()'
#define GA_CALLING_FUNCTION		Lower(program(program(-1)-1)) + '()'
*_______________________________________________________________________________
#define ga_FOXINCLOUD_LOCATION	_screen._FoxInCloud
*_______________________________________________________________________________
&& ga_BaseError.h
&& Gregory Adam 2011
*_______________________________________________________________________________

*_______________________________________________________________________________
#define	GA_ERROR_NONE				0

*_______________________________________________________________________________
#define	GA_ERRORBASE_GENERAL						0x00001000
#define	GA_ERRORBASE_Type							0x00002000
#define	GA_ERRORBASE_DoFormStatementParser			0x00003000
#define GA_ERRORBASE_NAMEBITS						0x00004100
#define	GA_ERRORBASE_FormPropertyModifiers			0x00004200
#define	GA_ERRORBASE_StringParseBits				0x00004300
#define	GA_ERRORBASE_StatementParser				0x00004400


*_______________________________________________________________________________
*_______________________________________________________________________________
* ga_Byte.h
* Gregory Adam 2011
*_______________________________________________________________________________


#define GA_BOM_UNICODE			(chr(0xff) + chr(0xfe))
#define GA_BOM_UNICODE_LENGTH	2

#define GA_BOM_UTF8				(chr(0xef) + chr(0xbb) + chr(0xbf))
#define GA_BOM_UTF8_LENGTH		3

#define GA_BYTE_MINVALUE			0
#define GA_BYTE_MAXVALUE			0xff
*_______________________________________________________________________________

#define	GA_BYTE_NONE			(-1)

#define	GA_BYTE_a_LOWER		0x61
#define	GA_BYTE_b_LOWER		0x62
#define	GA_BYTE_c_LOWER		0x63
#define GA_BYTE_d_LOWER		0x64
#define	GA_BYTE_e_LOWER		0x65
#define GA_BYTE_f_LOWER		0x66
#define GA_BYTE_g_LOWER		0x67
#define GA_BYTE_h_LOWER		0x68
#define GA_BYTE_i_LOWER		0x69
#define GA_BYTE_j_LOWER		0x6a
#define GA_BYTE_k_LOWER		0x6b
#define GA_BYTE_l_LOWER		0x6c
#define GA_BYTE_m_LOWER		0x6d
#define GA_BYTE_n_LOWER		0x6e
#define GA_BYTE_o_LOWER		0x6f
#define GA_BYTE_p_LOWER		0x70
#define GA_BYTE_q_LOWER		0x71
#define	GA_BYTE_r_LOWER		0x72
#define	GA_BYTE_s_LOWER		0x73
#define	GA_BYTE_t_LOWER		0x74
#define	GA_BYTE_u_LOWER		0x75
#define GA_BYTE_v_LOWER		0x76
#define GA_BYTE_w_LOWER		0x77
#define GA_BYTE_x_LOWER		0x78
#define GA_BYTE_z_LOWER		0x7a

#define	GA_BYTE_a_UPPER		0x41
#define	GA_BYTE_b_UPPER		0x42
#define	GA_BYTE_c_UPPER		0x43
#define GA_BYTE_d_UPPER 	0x44
#define	GA_BYTE_e_UPPER		0x45
#define	GA_BYTE_f_UPPER		0x46
#define	GA_BYTE_g_UPPER		0x47
#define	GA_BYTE_h_UPPER		0x48
#define	GA_BYTE_i_UPPER		0x49
#define	GA_BYTE_j_UPPER		0x4a
#define	GA_BYTE_k_UPPER		0x4b
#define	GA_BYTE_l_UPPER		0x4c
#define	GA_BYTE_m_UPPER		0x4d
#define GA_BYTE_n_UPPER		0x4e
#define GA_BYTE_o_UPPER		0x4f
#define GA_BYTE_p_UPPER		0x50
#define GA_BYTE_q_UPPER		0x51
#define	GA_BYTE_r_UPPER		0x52
#define	GA_BYTE_s_UPPER		0x53
#define	GA_BYTE_t_UPPER		0x54
#define	GA_BYTE_u_UPPER		0x55
#define GA_BYTE_v_UPPER		0x76
#define GA_BYTE_w_UPPER		0x57
#define GA_BYTE_x_UPPER		0x58
#define GA_BYTE_z_UPPER		0x5a

#define	GA_BYTE_z_CTRL		0x1a

#define GA_BYTE_BS			0x08	&& BackSpace
#define GA_BYTE_HT			0x09	&& horizontal TAB
#define	GA_BYTE_NL			0x0a
#define	GA_BYTE_VT			0x0b	&& vertical TAB
#define	GA_BYTE_FF			0x0c
#define GA_BYTE_CR			0x0d

#define	GA_BYTE_SPACE				0x20
#define	GA_BYTE_EXCLAMATIONMARK		0x21
#define	GA_BYTE_DOUBLEQUOTE			0x22
#define GA_BYTE_HASH				0x23
#define GA_BYTE_DOLLAR				0x24
#define GA_BYTE_PERCENT				0x25

#define	GA_BYTE_QUOTE			0x27
#define GA_BYTE_PARENS_LEFT		0x28
#define GA_BYTE_PARENS_RIGHT	0x29

#define	GA_BYTE_STAR			0x2a
#define	GA_BYTE_PLUS			0x2b
#define GA_BYTE_COMMA			0x2c
#define GA_BYTE_HYPHEN		0x2d
#define GA_BYTE_DOT			0x2e

#define	GA_BYTE_0				0x30
#define	GA_BYTE_1				0x31
#define	GA_BYTE_2				0x32
#define	GA_BYTE_3				0x33
#define	GA_BYTE_4				0x34
#define	GA_BYTE_5				0x35
#define	GA_BYTE_6				0x36

#define	GA_BYTE_7				0x37
#define	GA_BYTE_8				0x38
#define	GA_BYTE_9				0x39

#define	GA_BYTE_SEMICOLON		0x3b
#define	GA_BYTE_LESSTHANSIGN	0x3c
#define	GA_BYTE_EQUALSIGN		0x3d
#define	GA_BYTE_GREATERTHANSIGN	0x3e
#define GA_BYTE_QUESTIONMARK	0x3f

#define GA_BYTE_BRACKET_LEFT	0x5b
#define GA_BYTE_BACKSLASH		0x5c	&& BackSlash
#define GA_BYTE_BRACKET_RIGHT	0x5d
#define GA_BYTE_CARET			0x5e
#define GA_BYTE_UNDERSCORE		0x5f

#define GA_BYTE_BRACE_LEFT		0x7b
#define GA_BYTE_BAR_VERTICAL	0x7c
#define GA_BYTE_BRACE_RIGHT		0x7d

*_______________________________________________________________________________
*_______________________________________________________________________________
#define GA_WHITE_SPACE_CHAR_LIST	GA_BYTE_HT, GA_BYTE_NL, GA_BYTE_VT, GA_BYTE_FF, GA_BYTE_CR, GA_BYTE_SPACE

#define GA_BYTE_WHITESPACE_LIST	chr(GA_BYTE_HT), chr(GA_BYTE_NL), chr(GA_BYTE_VT), chr(GA_BYTE_FF), chr(GA_BYTE_CR), chr(GA_BYTE_SPACE)

* ga_Classes.h
* Gregory Adam 2011
*_______________________________________________________________________________

* thn - 12/06/13
* pour trouver les cas d'utilisation d'une classe,
* chercher les occurences de la fonction de création définie en tête du .prg correspondant

#define REGEX_CLASS			'VBScript.RegExp'

#define GA_COLLECTION_CLASS				'_ga_Collection_Class_' && as Collection
#define GA_COLLECTION_NAKED_CLASS		'_ga_Collection_Naked_Class_'

#define GA_STACK_CLASS	'_ga_Stack_Class_' && as Collection

#define GA_CUSTOM_CLASS			'_ga_Custom_Class_'
#define GA_CUSTOM_NAKED_CLASS	'_ga_Custom_Naked_Class_'

#define GA_SESSION_CLASS		'_ga_Session_Class_'
#define GA_LIGHTWEIGHT_CLASS		'_ga_LightWeight_Class_'
#define GA_LIGHTWEIGHT_NAKED_CLASS	'_ga_LightWeight_Naked_Class_'

#define GA_CODEPAGEBITS_CLASS	'_ga_CodeBits_Class_'

#define GA_DOFORMSTATEMENTPARSER_CLASS	'_ga_DoFormStatementParser_Class_' && as GA_LIGHTWEIGHT_CLASS
#define GA_FORMPROPERTYMODIFIERS_CLASS	'_ga_FormPropertyModifiers_Class_' && as GA_LIGHTWEIGHT_CLASS
#define GA_TOPOLOGICALSORT_CLASS	'_ga_TopologicalSort_Class_' && as GA_SESSION_CLASS

#define GA_NAMEBITS_CLASS	'_ga_NameBits_Class_' && as GA_LIGHTWEIGHT_CLASS

#define GA_COLLECTION_ZEROBASED_CLASS	'_ga_Collection_ZeroBased_Class_'
#define GA_DICTIONARY_CLASS					'_ga_Dictionary_Class_' &&  as GA_COLLECTION_CLASS
#define GA_DICTIONARY_NAKED_CLASS			'_ga_Dictionary_Naked_Class_'
#define GA_DICTIONARY_INTEGER_CLASS			'_ga_dictionary_integer_Class_'
#define GA_DICTIONARY_NAKED_INTEGER_CLASS	'_ga_Dictionary_Naked_IntegerClass_'

#define GA_QUEUE_CLASS	'_ga_Queue_Class' && as GA_COLLECTION_CLASS

#define GA_REGEX_CLASS	'_ga_RegEx_Class' && as GA_LIGHTWEIGHT_CLASS
#define GA_REGEX_GROUP_CLASS	'_ga_RegEx_Group_Class' && unused
#define GA_REGEX_GROUPDICTIONARY_CLASS	'_ga_RegEx_GroupDictionary_Class' && as GA_DICTIONARY_NAKED_INTEGER_CLASS 
#define GA_REGEX_MATCH_CLASS	'_ga_RegEx_Match_Class' &&  as GA_CUSTOM_NAKED_CLASS
#define GA_REGEX_MATCHESCOLLECTION_CLASS	'_ga_RegEx_MatchesCollection_Class' &&  as GA_COLLECTION_NAKED_CLASS

#define GA_REGEXPATTERN_TOOLS_CLASS	'_ga_Regex_Pattern_Tools_Class_' &&  as GA_REGEXPATTERN_READER_CLASS
#define GA_REGEXPATTERN_READER_CLASS	'_ga_Regex_Pattern_Reader_Class_'

#define GA_REGEXPLUS_CLASS	'_ga_Regex_Plus_Class' && as GA_LIGHTWEIGHT_CLASS

#define GA_REGEXPOOL_CLASS	'_ga_RegexPool_Class_' && as GA_LIGHTWEIGHT_CLASS

#define GA_MENUBITS_BASE_CLASS	'_ga_MenuBits_Base_Class_'
#define GA_MENUBITS_POPUP_CLASS	'_ga_MenuBits_Popup_Class_'

#define GA_STRINGPARSE_CLASS		'_ga_StringParse_Class_' && as GA_LIGHTWEIGHT_CLASS
#define GA_STRINGPARSEBITS_CLASS	'_ga_StringParseBits_Class_' && as GA_STRINGPARSE_CLASS

#define GA_STATEMENTCLAUSE_CLASS	'_ga_StatementClause_Class_'
#define GA_STATEMENTCLAUSEPOOL_CLASS	'_ga_StatementClausePool_Class_'

#define GA_STATEMENTPOOL_CLASS	'_ga_StatementPool_Class_'
#define GA_STATEMENTPARSER_CLASS	'_ga_StatementParser_Class_'
#define GA_STATEMENTPARSERPOOL_CLASS '_ga_StatementParserPool_Class_'
#define GA_STATEMENTPARSERPOOL_MENU_CLASS	'_ga_StatementParserPool_Menu_Class_'

#define GA_STATEMENTINDENTOR_CLASS	'_ga_StatementIndentor_Class_' && as GA_LIGHTWEIGHT_CLASS

#define MD5BITS_CLASS	'md5Bits'
&& ga_Debug.h
* Gregory Adam 2011
*_______________________________________________________________________________
#define GA_DEBUG_GRAMMARDUMP_FILE	'd:\tmp\parse\4_grammar_ll1_Prepared.xml'

#define GA_DEBUG
&& ga_Error.h
* Gregory Adam 2011

*_______________________________________________________________________________
#define GA_ERROR_FUNCTION_NOT_IMPLEMENTED		error 1999

#define GA_ERROR_READONLY_PROPERTY				error 1740

#define GA_ERROR_FUNCTION_ARGUMENT_INCORRECT	error 11

#define GA_ERROR_FILE_CANNOT_OPEN				error 101

#define GA_ERROR_TOO_FEW_ARGUMENTS				error 1229

*_______________________________________________________________________________

#define GA_ERROR_GENERAL_LOGIC					-(GA_ERRORBASE_GENERAL + 0x01)
* ga_File.h
* Gregory Adam 2012
*_______________________________________________________________________________
#define GA_FILE_FD_NOT_OPEN		(-1)
*_______________________________________________________________________________
#define GA_FILE_OPEN_READONLY	0
#define GA_FILE_OPEN_WRITEONLY	1
#define GA_FILE_OPEN_READWRITE	2
#define GA_FILE_OPEN_CREATE		3
*_______________________________________________________________________________
#define GA_FILE_IOBLOCKSIZE		16384
&& ga_FormPropertyModifiers.h
* Gregory Adam 2011
*_______________________________________________________________________________
#define ga_FormPropertyModifiers_error_RootHasMoreThanOneName	-(GA_ERRORBASE_FormPropertyModifiers+1)
#define ga_FormPropertyModifiers_error_MemberAlreadyDefined		-(GA_ERRORBASE_FormPropertyModifiers+2)
#define ga_FormPropertyModifiers_error_ClassAlreadyDefined		-(GA_ERRORBASE_FormPropertyModifiers+3)
#define ga_FormPropertyModifiers_error_ClassIsBaseClass			-(GA_ERRORBASE_FormPropertyModifiers+4)
#define ga_FormPropertyModifiers_error_ClassHierarchyContainsCycles	-(GA_ERRORBASE_FormPropertyModifiers+5)



#define ga_FormPropertyModifiers_error_UsedAsPropertyAndObject	-(GA_ERRORBASE_FormPropertyModifiers+0x10)
#define ga_FormPropertyModifiers_error_ObjectAlreadyFinalized	(GA_ERRORBASE_FormPropertyModifiers+0x11)
#define ga_FormPropertyModifiers_error_ObjectNotFinalized	(GA_ERRORBASE_FormPropertyModifiers+0x12)
#define ga_FormPropertyModifiers_error_UndefinedMembers		(GA_ERRORBASE_FormPropertyModifiers+0x13)
#define ga_FormPropertyModifiers_error_UndefinedClasses		(GA_ERRORBASE_FormPropertyModifiers+0x14)
* ga_DoFormStatementParser_error.h
* Gregory Adam 2011
*_______________________________________________________________________________
#define GA_DoFormStatementParser_error_NONE							GA_ERROR_NONE
#define GA_DoFormStatementParser_error_StatementIsNotAString		(GA_ERRORBASE_DoFormStatementParser+1)
#define GA_DoFormStatementParser_error_BadStringTermination			(GA_ERRORBASE_DoFormStatementParser+2)
#define GA_DoFormStatementParser_error_UnMatchedParentheses			(GA_ERRORBASE_DoFormStatementParser+3)
#define GA_DoFormStatementParser_error_CannotParse					-(GA_ERRORBASE_DoFormStatementParser+4)
#define GA_DoFormStatementParser_error_CannotFind_Do_form			(GA_ERRORBASE_DoFormStatementParser+5)
#define GA_DoFormStatementParser_error_CannotFind_FormName			(GA_ERRORBASE_DoFormStatementParser+6)
#define GA_DoFormStatementParser_error_ParseError					(GA_ERRORBASE_DoFormStatementParser+7)
#define GA_DoFormStatementParser_error_Linked_Without_Name			(GA_ERRORBASE_DoFormStatementParser+8)
#define GA_DoFormStatementParser_error_Linked_NOREAD_Clause			(GA_ERRORBASE_DoFormStatementParser+9)

* ga_MenuBits.h
* Gregory Adam 2012
*_______________________________________________________________________________
#define GA_MENUBITS_LOCATION		ga_FOXINCLOUD_LOCATION._Menu
#define GA_MENUBITS_POPUP_LOCATION	GA_MENUBITS_LOCATION.Popup
&& ga_NameBits.h
* Gregory Adam 2011
*_______________________________________________________________________________
#define GA_NameBits_Nomalize_Options_NONE							0

	
#define GA_NameBits_Nomalize_Options_MultiPart_Needed				2

#define GA_NameBits_Nomalize_Options_RequireFullyQualified			4
#define GA_NameBits_Nomalize_Options_MustStartWith_ThisOrThisform	8



#define GA_NameBits_Nomalize_Options_ToQueue						0x10

*_______________________________________________________________________________

&& BadName

#define GA_NameBits_error_NotAName						-(GA_ERRORBASE_NAMEBITS+1)

&& need at least two parts, ie thisform.Value
#define GA_NameBits_error_MultiPart_Name_Needed			-(GA_ERRORBASE_NAMEBITS+2)

&& cannot contain this, thisform or parent
#define GA_NameBits_error_RequireFullyQualifiedName		-(GA_ERRORBASE_NAMEBITS+3)
#define GA_NameBits_error_NameContains_This_Thisform	-(GA_ERRORBASE_NAMEBITS+4)

&& thisform.Parent or this.Thisform
#define GA_NameBits_error_ReferenceAboveRoot			-(GA_ERRORBASE_NAMEBITS+5)

#define GA_NameBits_error_PropertyDoesNotStart_This_Thisform	-(GA_ERRORBASE_NAMEBITS+6)
* ga_Object.h
* Gregory Adam 2012
*_______________________________________________________________________________

#define ga_OBJECT_GETPEM_Property		1  && includes objects
#define ga_OBJECT_GETPEM_Event			2
#define ga_OBJECT_GETPEM_Method			4
*_______________________________________________________________________________
&& ga_Parameters.h
&& Gregory Adam 2011
*_______________________________________________________________________________
&& parameters
#define GA_PARAMETERLIST_04		p01, p02, p03, p04
#define GA_PARAMETERLIST_08		GA_PARAMETERLIST_04, p05, p06, p07, p08
#define GA_PARAMETERLIST_12		GA_PARAMETERLIST_08, p09, p10, p11, p12
#define GA_PARAMETERLIST_16		GA_PARAMETERLIST_12, p13, p14, p15, p16
#define GA_PARAMETERLIST_20		GA_PARAMETERLIST_16, p17, p18, p19, p20
#define GA_PARAMETERLIST_24		GA_PARAMETERLIST_20, p21, p22, p23, p24

#define GA_PARAMETERLIST_04_M		m.p01, m.p02, m.p03, m.p04

#define GA_PARAMETERLIST_08_M		GA_PARAMETERLIST_04_M, ;
										m.p05, m.p06, m.p07, m.p08
#define GA_PARAMETERLIST_12_M		GA_PARAMETERLIST_08_M, ;
										m.p09, m.p10, m.p11, m.p12
#define GA_PARAMETERLIST_16_M		GA_PARAMETERLIST_12_M, ;
										m.p13, m.p14, m.p15, m.p16
#define GA_PARAMETERLIST_20_M		GA_PARAMETERLIST_16_M, ;
										m.p17, m.p18, m.p19, m.p20
#define GA_PARAMETERLIST_24_M		GA_PARAMETERLIST_20, ;
										m.p21, m.p22, m.p23, m.p24

#define GA_PARAMETERLIST_04_REF		@m.p01, @m.p02, @m.p03, @m.p04

#define GA_PARAMETERLIST_08_REF		GA_PARAMETERLIST_04_REF, ;
										@m.p05, @m.p06, @m.p07, @m.p08
#define GA_PARAMETERLIST_12_REF		GA_PARAMETERLIST_08_REF, ;
										@m.p09, @m.p10, @m.p11, @m.p12
#define GA_PARAMETERLIST_16_REF		GA_PARAMETERLIST_12_REF, ;
										@m.p13, @m.p14, @m.p15, @m.p16
#define GA_PARAMETERLIST_20_REF		GA_PARAMETERLIST_16_REF, ;
										@m.p17, @m.p18, @m.p19, @m.p20
#define GA_PARAMETERLIST_24_REF		GA_PARAMETERLIST_20_REF, ;
										@m.p21, @m.p22, @m.p23, @m.p24

* ga_RegexPatternReader.h
* Gregory Adam 2012
*_______________________________________________________________________________
#if false
	indicate bit numbers
	do not use bit 31
#endif
#define GA_REGEXPATTERN_FLAG_SPECIAL		30

#define GA_REGEXPATTERN_FLAG_CHARGROUP		29

#define GA_REGEXPATTERN_FLAG_ESCAPED		28
#define GA_REGEXPATTERN_FLAG_DIGITS			27  && octal or backreference
#define GA_REGEXPATTERN_FLAG_HEX			26
#define GA_REGEXPATTERN_FLAG_UNICODE		25
#define GA_REGEXPATTERN_FLAG_CONTROLCHAR	24


#define GA_REGEXPATTERN_FLAG_PARENS_LEFT	23
#define GA_REGEXPATTERN_FLAG_PARENS_RIGHT	22


#define GA_REGEXPATTERN_FLAG_ADDED			21	&& when LeftParens/rightparens Set
#define GA_REGEXPATTERN_FLAG_LOOKAHEAD		20	&& when LeftParens Set
#define GA_REGEXPATTERN_FLAG_LOOKBEHIND		19	&& when LeftParens Set
#define GA_REGEXPATTERN_FLAG_NAMEDGROUP		18	&& when LeftParens Set

*_______________________________________________________________________________
* ga_StatementParser_error.h
* Gregory Adam 2011
*_______________________________________________________________________________
#define ga_StatementParser_error_NONE						GA_ERROR_NONE
#define ga_StatementParser_error_StatementNotCharExpr	-(GA_ERRORBASE_StatementParser+1)
#define ga_StatementParser_error_InitFailed				-(GA_ERRORBASE_StatementParser+2)
#define ga_StatementParser_error_CannotParse			-(GA_ERRORBASE_StatementParser+3)
#define ga_StatementParser_error_Substitution			-(GA_ERRORBASE_StatementParser+4)
* ga_StatementPool.h
* Gregory Adam 2012
*_______________________________________________________________________________
&& flags = bit number

#define	GA_STATEMENTPOOL_FLAGS_MANDATORY	0  && optional if not set
* ga_String.h
* Gregory Adam 2011
*_______________________________________________________________________________

#define GA_STRING_WHITESPACE	(chr(0x20) + chr(0x9))

#define GA_STRING_CRLF			(chr(0x0d) + chr(0x0a))
*_______________________________________________________________________________

#define GA_STRING_SPLIT_FLAG_NOTRIM								0
#define GA_STRING_SPLIT_FLAG_ALLTRIM							1
#define GA_STRING_SPLIT_FLAG_INCLUDEEMPTYLASTELEMENT			2
#define GA_STRING_SPLIT_FLAG_STRIPEMPYELEMENTS					4
#define GA_STRING_SPLIT_FLAG_IGNORECASE							8
#define GA_STRING_SPLIT_FLAG_TOLOWERCASE						0x80000000
#define GA_STRING_SPLIT_FLAG_EVALELEMENTS						0x40000000


#define GA_STRING_SPLIT_FLAG_ALLTRIM_INCLUDEEMPTYLASTELEMENT	3
#define GA_STRING_SPLIT_FLAG_ALLTRIM_STRIPEMPTY					5
#define GA_STRING_SPLIT_FLAG_ALLTRIM_STRIPEMPTY_TOLOWER			bitor( GA_STRING_SPLIT_FLAG_ALLTRIM_STRIPEMPTY, ;
																		GA_STRING_SPLIT_FLAG_TOLOWERCASE ;
																	)

#define GA_STRING_WHITESPACE_NOTRIM								0
#define GA_STRING_WHITESPACE_LTRIM								1
#define GA_STRING_WHITESPACE_RTRIM								2
#define GA_STRING_WHITESPACE_ALLTRIM							3
&& ga_StringParseBits.h
* Gregory Adam 2011
*_______________________________________________________________________________
#define GA_StringParseBits_error_NotAName			-(GA_ERRORBASE_StringParseBits+1)
#define GA_StringParseBits_error_InValidClassName	-(GA_ERRORBASE_StringParseBits+2)
* ga_Type.h
* Gregory Adam 2012
*_______________________________________________________________________________

#undefine	T_INTEGER
#define		T_INTEGER	'I'

#undefine	T_VARCHAR
#define		T_VARCHAR	'V'

#define		T_ARRAY		'A'
*_______________________________________________________________________________
#define INTEGER_MAXVALUE	0x7fffffff
#define INTEGER_MINVALUE	(-INTEGER_MAXVALUE)
*_______________________________________________________________________________
#define ARRAY_MAX_ELEMENTS	INTEGER_MAXVALUE
*_______________________________________________________________________________
#define GA_TYPE_ERROR_NotCharExpression		-(GA_ERRORBASE_Type+1)
#define GA_TYPE_ERROR_NotNumeric		-(GA_ERRORBASE_Type+1)
*_______________________________________________________________________________

#endif
*_______________________________________________________________________________
#undefine GA_DEBUG
