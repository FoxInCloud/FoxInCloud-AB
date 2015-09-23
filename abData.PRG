* abData.prg
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
&& under the terms of an MIT-style license
* It may be used and/or distributed without restriction
* Any substantial improvement must be given for free to the community
* This permission notice shall be entirely included in all copies
&& or substantial portions of the Software
* =====================================================

#INCLUDE AB.H
AB()
return abUnitTests()

* ========================================
FUNCTION cTableAddress	&& Adresse complète d'une table d'après son alias
LPARAMETERS tcAlias && [alias()] Alias d'ouverture de la table
LOCAL llFullPathOff, lcResult

llFullPathOff = Set('FullPath') == 'OFF'
IF m.llFullPathOff
	SET FULLPATH ON
ENDIF

lcResult = ICase(;
	Vartype(m.tcAlias) == 'C' AND Used(m.tcAlias),;
		Dbf(m.tcAlias),;
	Used(),;
		Dbf(),;
		'';
	)

IF m.llFullPathOff
	SET FULLPATH OFF
ENDIF

RETURN m.lcResult

* ========================================
FUNCTION JustField && Champ et alias d'une chaîne de type "[alias.]field" && note: JustExt("field") retourne ""
LPARAMETERS ;
	tcChain,; && Chaîne présumée de type 'alias.field' ou 'field'
	tcAlias && @ Alias en retour

LOCAL llResult, lcResult && Field
STORE '' TO tcAlias, lcResult

llResult = Vartype(m.tcChain) == 'C'
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([Spécification de chaîne invalide : <<cLitteral(m.tcChain)>>]))
IF m.llResult

	tcChain = Upper(Strtran(Chrtran(Alltrim(m.tcChain), ' ', ''), '->', '.'))

	IF Occurs([.], m.tcChain) <= 1 AND Lenc(m.tcChain) < 257 && 2*128 + 1

		IF [.] $ m.tcChain
			tcAlias = JustStem(m.tcChain)
			lcResult = JustExt(m.tcChain)
*!*					2015-05-25 bouffe du temps inutilement
*!*					IF NOT (lVFPName(m.tcAlias) AND lVFPName(m.lcResult))
*!*						STORE '' TO m.tcAlias, m.lcResult
*!*					ENDIF
		ELSE
*!*					lcResult = Iif(lVFPName(m.tcChain), m.tcChain, '')
			lcResult = m.tcChain
		ENDIF
	ENDIF
ENDIF

RETURN m.lcResult

* ========================================
FUNCTION JustField && Champ et alias d'une chaîne de type "[alias.]field" && note: JustExt("field") retourne ""
LPARAMETERS ;
	tcChain,; && Chaîne présumée de type 'alias.field' ou 'field'
	tcAlias && @ [''] Alias en retour

tcAlias = '' && important

local lcChain as String	

lcChain = Strtran(Chrtran(m.tcChain, ' ', ''), '->', '.')

return ICase(;
	Occurs([.], m.lcChain) > 1,;
		'',;
	.T.;
	 and Empty(Occurs([.], m.lcChain));
	 and Chrtran(m.lcChain, VFPOPSEPCARS, '') == m.lcChain;
	 and lVFPName(m.lcChain),;
		m.lcChain,;
	.T.;
	 and Lenc(m.lcChain) < 257; && 2*128 + 1
	 and Chrtran(m.lcChain, VFPOPCARS, '') == m.lcChain;
	 and lVFPName(JustStem(m.lcChain));
	 and lVFPName(JustExt(m.lcChain));
	 and varSet(@m.tcAlias, JustStem(m.lcChain)),;
	 	JustExt(m.lcChain),;
	  '';
	 )
endfunc

* ---------------------
PROCEDURE JustField_Test && Test unitaire de JustField()

LOCAL loTest AS abUnitTest OF abDev.prg, lcChain, lcAlias
loTest = NewObject('abUnitTest', 'abDev.prg')

lcChain = 'toto.tutu.titi'
loTest.Test('', m.lcChain, @m.lcAlias)

lcChain = 'toto.tutu'
loTest.Test('tutu', m.lcChain, @m.lcAlias)
loTest.Assert('toto', m.lcAlias)

lcChain = 'tété.tutu'
loTest.Test('tutu', m.lcChain, @m.lcAlias)
loTest.Assert('tété', m.lcAlias)

lcChain = 'evl(tété.tutu, "")'
loTest.Test('', m.lcChain, @m.lcAlias)

RETURN loTest.Result()


* ========================================
FUNCTION JustTable && Table dans une chaîne de type "Base de données!table"
LPARAMETERS ;
	tcChain,; && Chaîne présumée de type "Base de données!table"
	tcDBC && @ Base de données en retour
LOCAL lnExclam, llResult, lcResult && Table ou toute la chaîne source si elle ne comporte aucun '!'
STORE '' TO lcResult, tcDBC

llResult = Vartype(m.tcChain) == 'C' AND NOT Empty(m.tcChain)
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([Spécification de chaîne invalide : <<cLitteral(m.tcChain)>>]))
IF m.llResult

	lnExclam = Atc('!', m.tcChain)
	IF m.lnExclam > 0
	
		lcResult = Alltrim(Substr(m.tcChain, m.lnExclam+1))
		tcDBC = Alltrim(Substr(m.tcChain, 1, m.lnExclam-1))
	ELSE
		lcResult = Alltrim(m.tcChain)
	ENDIF
ENDIF

RETURN m.lcResult

* ---------------------
PROCEDURE JustTable_Test && Teste JustTable()

LOCAL loTest AS abUnitTest OF abDev.prg
loTest = NewObject('abUnitTest', 'abDev.prg')

loTest.Test('tata', ' tata ')
loTest.Test('tata', ' C:\toto\tutu.xls ! tata')

RETURN loTest.Result()

* =================================================
FUNCTION abSelect && Change la zone de travail Select() et rétablit à destruction
LPARAMETERS ;
	tuSelect,; && [0] Zone de travail / alias à sélectionner, ou table à ouvrir et sélectionner
	tlKeepOpened,; && [.F.] Si la table est ouverte, laisser ouverte en sortie
	tcError && [''] @ Erreur éventuelle

RETURN CreateObject('abSelect', m.tuSelect, m.tlKeepOpened, @m.tcError)

* =================================================
DEFINE CLASS abSelect as GA_LIGHTWEIGHT_CLASS && Change la zone de travail Select() et rétablit à destruction
* =================================================

PROTECTED nSelect,; && Zone de travail initiale
	lTable,; && Table communiquée
	cAlias,; && Alias sous lequel la table est ouverte
	lOpened,; && Table ouverte
	lKeepOpened && Si table ouverte, laisser ouverte

nSelect = .F.
cAlias = ''
lTable = .F.
lOpened = .F.
lKeepOpened = .F.

* ---------------------------------------------------
PROCEDURE Init && Change la zone de travail
LPARAMETERS ;
	tuSelect,; && [0] Zone de travail / alias à sélectionner, ou table à ouvrir et sélectionner
	tlKeepOpened,; && [.F.] Si la table est ouverte, laisser ouverte en sortie
	tcError && [''] @ Erreur éventuelle
tuSelect = Evl(m.tuSelect, 0)

LOCAL lcType, lcTable, llOpened, llResult

lcType = Vartype(m.tuSelect)
llResult = m.lcType == 'C'
IF m.llResult

	llResult = Used(m.tuSelect)
	IF NOT m.llResult

		lcTable = Iif(Vartype(m.tuSelect) == 'C' AND Empty(JustExt(m.tuSelect)), ForceExt(m.tuSelect, 'dbf'), m.tuSelect)

		this.lTable = .F.;
		 OR (NOT Empty(Dbc()) AND Indbc(m.tuSelect, "TABLE"));
		 OR File(m.lcTable);
		 OR File(cDBCTableAddr(m.tuSelect))

		llResult = m.this.lTable
	ENDIF
ENDIF
llResult = m.llResult OR m.lcType == 'N' AND Cast(m.tuSelect AS I) = m.tuSelect AND Between(m.tuSelect, 0, 32767)
tcError = Iif(m.llResult, '', Textmerge([Invalid table, alias or work area <<cLitteral(m.tuSelect)>>]))
ASSERT m.llResult MESSAGE cAssertMsg(m.tcError)
IF m.llResult
	
	* Si référence à une table fournie
	IF m.this.lTable
		this.cAlias = cAlias(m.tuSelect, @m.llOpened,, @m.tcError)
		llResult = Used(m.this.cAlias)
		IF m.llResult
			tuSelect = m.this.cAlias
			this.lOpened = m.llOpened
			this.lKeepOpened = lTrue(m.tlKeepOpened)
		ENDIF
	ENDIF

	IF m.llResult
		this.nSelect = Select(0)
		SELECT (m.tuSelect)
	ENDIF
ENDIF

tcError = Iif(m.llResult, '', m.tcError)

RETURN m.llResult

* ---------------------------------------------------
PROCEDURE Destroy && Rétablit la zone de travail initiale et referme la table si this.Init() l'a ouverte

SELECT (m.this.nSelect)

IF m.this.lOpened AND NOT m.this.lKeepOpened
	USE IN Select(m.this.cAlias)
ENDIF

* =================================================
ENDDEFINE && CLASS abSelect
* =================================================

* ========================================
FUNCTION cDBCTableAddr && Adresse d'une table dans un DBC
LPARAMETERS tcDBCTable && 'DBC!Table'

LOCAL lcTable, lcDBC, loDBC AS abSet, llDBC, llResult, lcResult

lcResult = ''
llResult = Vartype(m.tcDBCTable) == 'C' AND '!' $ m.tcDBCTable
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([Paramètre invalide : <<cLitteral(m.tcDBCTable)>>]))
IF m.llResult
	
	lcTable = JustTable(m.tcDBCTable, @m.lcDBC)
	loDBC = abSet('DATABASE', Set("Database"),,,.T.)
	IF DBused(m.lcDBC)
		SET DATABASE TO (m.lcDBC)
	ELSE
		lcDBC = ForceExt(m.lcDBC, 'dbc')
		llResult = File(m.lcDBC)
		ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([La base de données '<<m.lcDBC>>' est introuvable]))
		IF m.llResult
			OPEN DATABASE (m.lcDBC) SHARED
			llDBC = .T.
		ENDIF
	ENDIF
	IF m.llResult

		llResult = Indbc(m.lcTable, "TABLE")
		ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([La table '<<m.lcTable>>' est introuvable dans le DBC '<<m.lcDBC>>']))
		IF m.llResult
			lcResult = cFileCased(Addbs(JustPath(Dbc())) + DBGetProp(m.lcTable, "TABLE", "Path"), .T.)
		ENDIF
		IF m.llDBC
			CLOSE DATABASES
		ENDIF
	ENDIF
ENDIF

RETURN m.lcResult

* ========================================
FUNCTION cAlias && Alias d'une table
LPARAMETERS ;
	tuTable,; && [Alias()] Table : Alias | Zone | Adresse | [DB!]Table
	tlOpened,; && @ La table a été ouverte, penser à la refermer
	tlExclusive,; && [.F.] Ouvrir la table en exclusif
	tcError,; && @ [''] Erreur éventuelle
	tcAlias; && [default] Alias sous lequel ouvrir la table

tlOpened = .F.
tcAlias = Upper(Iif(ga_Type_IsChar(m.tcAlias, .T.) and lVFPName(m.tcAlias), m.tcAlias, ''))

LOCAL lcResult as String; && Alias sous lequel la table est ouverte
, lcType;
, lcTable, llTable;
, lcDBC, loDBC AS abSet, llDBC;
, lnSelect; && pas de abSelect() pour optimiser
, loException AS Exception;
, llAlias as Boolean;

lcResult = ''

lcType = Vartype(m.tuTable)
tuTable = Iif(m.lcType == 'C', Upper(Alltrim(m.tuTable)), m.tuTable)
llAlias = ga_Type_IsChar(m.tcAlias, .T.)

DO CASE

CASE Empty(m.tuTable) && paramètre vide, alias courant
	lcResult = Alias()

CASE m.lcType == 'N'
	lcResult = Alias(m.tuTable)

CASE !m.lcType == 'C'

CASE Used(m.tuTable); && Alias existant, retourner
 and (!m.llAlias or Upper(m.tuTable) == m.tcAlias)
	lcResult = m.tuTable

otherwise && Sinon (adresse de table sur le disque ou dans une base de données)
		
	DO CASE 

	CASE '!' $ m.tuTable && DB!Table
		lcTable = cDBCTableAddr(m.tuTable)
		STORE File(m.lcTable) TO llTable, llDBC

	CASE NOT Empty(Dbc()) AND Indbc(m.tuTable, "TABLE") && Table d'une base de données
		lcTable = Addbs(JustPath(Dbc())) + DBGetProp(m.tuTable, "TABLE", "Path")
		STORE .T. TO llTable, llDBC

	otherwise && Adresse disque
		lcTable = Iif(Empty(JustExt(m.tuTable)), ForceExt(m.tuTable, 'dbf'), m.tuTable)
		llTable = Iif(Directory(JustPath(m.lcTable)), lFile(m.lcTable), File(m.lcTable))
		IF NOT m.llTable
			lcTable = FullPath(m.lcTable)
			llTable = File(m.lcTable)
		ENDIF

	ENDCASE
	IF m.llTable && la table existe
		
		* Si la table n'est pas ouverte
		lcResult = cAliasUsed(m.lcTable)
		IF Empty(m.lcResult) or (m.llAlias and !m.lcResult == m.tcAlias)
			
			* Ouvrir la table
			lcTable = Iif(m.llDBC, m.tuTable, m.lcTable)
			lnSelect = Select(0)
			tcAlias = Iif(m.llAlias, Iif(Empty(m.lcResult), '', 'again ') + 'alias ' + m.tcAlias, '')
			SELECT 0
			TRY
				use (m.lcTable) shared &tcAlias && shared added 20/06/13
				lcResult = Alias()
				tlOpened = .T.
			CATCH TO loException
				lcResult = cException(m.loException)
				ASSERT .F. MESSAGE cAssertMsg(Textmerge([Impossible d'ouvrir la table '<<m.lcTable>>' : <<m.lcResult>>]))
				cResultAdd(@m.tcError, m.lcResult)
			ENDTRY
			SELECT (m.lnSelect)
		ENDIF
	ELSE
		cResultAdd(@m.tcError, Textmerge(ICase(;
			cLangUser() = 'fr',	[La table <<cL(m.tuTable)>> est introuvable],; && copy-paste this line to add another language support
													[Table <<cL(m.tuTable)>> can't be found]; && Default: English
			)))
	ENDIF
ENDCASE

IF Used(m.lcResult) AND lTrue(m.tlExclusive)
	lcResult = ExclusiveForce(m.lcResult)
ENDIF

RETURN m.lcResult

*========================================
FUNCTION nBufferDirty && {fr} nombre d'enregistrements modifiés dans le tampon d'un alias
LPARAMETERS ;
  tcAlias; && [Alias()]
, tlAll; && [.F.] all modified even if filtered

local nBufferDirty as Integer;
, loRecno as abRecno of abData.prg;
, loFilter as abFilter of abData.prg;
, loOrder as abOrder of abData.prg;
, liRecno as integer;

nBufferDirty = 0

do case
case !lBufferDirty(@m.tcAlias)
case InList(CursorGetProp("Buffering", m.tcAlias), 2, 3) && Row buffering
	nBufferDirty = 1
otherwise

	loRecno = abRecno(m.tcAlias)
	loFilter = Iif(lTrue(m.tlAll), abFilter(m.tcAlias), .null.)
	loOrder = abOrder(, m.tcAlias)
	liRecno = 0
	do while .T.
		liRecno = GetNextModified(m.liRecno, m.tcAlias, .T.)
		if Empty(m.liRecno)
			exit
		endif
		nBufferDirty = m.nBufferDirty + 1
	enddo
endcase

return m.nBufferDirty
endfunc

*========================================
FUNCTION lBufferDirty as Boolean && {fr} Le tampon d'un alias est modifié
LPARAMETERS tcAlias && [Alias()]
tcAlias = Evl(m.tcAlias, Alias())

LOCAL lBufferDirty as Boolean;
, lnRecCount;
, liRecno;
, lcFldState;
, loFilter as abFilter of abData.prg;
, loOrder as abOrder of abData.prg;

do case
 
case .F.;
 or !Used(m.tcAlias);
 or CursorGetProp("Buffering", m.tcAlias) = 1;
 or !varSet(@m.lnRecCount, Reccount(m.tcAlias));
 or Empty(m.lnRecCount);
 or !varSet(@m.liRecno, Recno_(m.tcAlias));
 or !varSet(@m.lBufferDirty, m.liRecno < 0); && added record
 or m.lBufferDirty;
 or !(Between(m.liRecno, 1, m.lnRecCount) or Eof(m.tcAlias));
 or .F.
	
case varSet(@m.lcFldState, GetFldState(-1, m.tcAlias));
 and InList(CursorGetProp("Buffering", m.tcAlias), 2, 3) && Row buffering

	lBufferDirty = !Empty(Chrtran(Nvl(m.lcFldState, ''); && .null. if Eof(m.tcAlias)
		, '1';
		, '';
		))

case !IsNull(m.lcFldState); && .null. if Eof(m.tcAlias)
 and !Empty(Chrtran(m.lcFldState, '1', ''))

	lBufferDirty = .T. && Table buffering, current record modified

otherwise && Table buffering

	loFilter = abFilter(m.tcAlias)
	loOrder = abOrder(, m.tcAlias)
	lBufferDirty = !Empty(GetNextModified(0, m.tcAlias, .T.))
	RecnoSet(m.liRecno, m.tcAlias)

endcase

return m.lBufferDirty
endfunc

* -----------------------------------------------------------------
PROCEDURE lBufferDirty_Test && lBufferDirty() unit test

LOCAL loTest AS lBufferDirty_Test OF abData.prg, liRecno as Integer
loTest = NewObject('lBufferDirty_Test', 'abData.prg')
with m.loTest AS lBufferDirty_Test OF abData.prg
	.Test(.F.) && 1

.use
	.Test(.F.) && 2

	.insert
	.Test(.F.) && 3

.setBuffering(3)

	.Test(.F.) && 4

	.update
	.Test(.T.) && 5

	.skip && Eof()
	.Test(.F.) && 6

	.skip(-1)
	.update
	.Test(.T.) && 7

	.TableUpdate
	.Test(.F.) && 8

.setBuffering(5)

	.insert
	liRecno = .Recno()
	.Test(.T.) && 9
	.assert(m.liRecno, .Recno())

	.skip(-1)
	liRecno = .Recno()
	.Test(.T.) && 10
	.assert(m.liRecno, .Recno())

	.TableUpdate(.T.)
	.update
	.Test(.T.) && 11
	
.use(.T.)
	.Test(.F.) && 12

endwith

return m.loTest.Result()

	* ------------------------------
	DEFINE CLASS lBufferDirty_Test AS abUnitTest OF abDev.prg
	PROCEDURE Use(in)
		if m.in
			use in Select('lBufferDirty_Test')
		else
			create cursor lBufferDirty_Test (lBufferDirty_Test C(10))
		endif
	PROCEDURE insert
		insert into lBufferDirty_Test values ('')
	PROCEDURE setBuffering(setBuffering)
		CursorSetProp("Buffering", Evl(m.setBuffering, 1), 'lBufferDirty_Test')
	PROCEDURE update
		replace in lBufferDirty_Test lBufferDirty_Test with 'lBufferDirty_Test'
	PROCEDURE Skip(skip)
		skip Evl(m.skip, 1) in lBufferDirty_Test
	FUNCTION TableRevert(all)
		return TableRevert(m.all, 'lBufferDirty_Test')
	FUNCTION TableUpdate(all)
		return TableUpdate(m.all, .F., 'lBufferDirty_Test')
	FUNCTION Recno
		return Recno('lBufferDirty_Test')
	ENDDEFINE

* ========================================
FUNCTION lBufferInsert && Un alias tamponné a (au moins) un enregistrement ajouté
LPARAMETERS tcAlias && [courant] Alias à examiner
tcAlias = Evl(m.tcAlias, Alias())

local success as Boolean;
, oRelation as abRelationSrceOff of abData.prg;
, oFilter as abFilter of abData.prg;
, oOrder as abOrder of abData.prg;
, oRecno as abRecno of abData.prg;

do case

case .F.;
 or !Used(m.tcAlias);
 or CursorGetProp("Buffering", m.tcAlias) = 1
	return .F.

case Recno(m.tcAlias) < 0 && Recno() returns negative numbers for records appended in a table buffer
	return .T.

case InList(CursorGetProp("Buffering", m.tcAlias), 2, 3) && row buffering
	return InList(cast(Left(Nvl(GetFldState(-1, m.tcAlias), ''), 1) as I), 3, 4)

otherwise && InList(CursorGetProp("Buffering", m.tcAlias), 4, 5) && table buffering

	oRelation = abRelationSrceOff(m.tcAlias)
	oFilter = abFilter(m.tcAlias)
	oOrder = abOrder(m.tcAlias)
	oRecno = abRecno(m.tcAlias)
	
	go bottom in m.tcAlias
	success = Recno(m.tcAlias) < 0 && Recno() returns negative numbers for records appended in a table buffer
	release oOrder, oFilter, oRecno, oRelation
	return m.success

endcase
endfunc

* ========================================
FUNCTION oAlias && {fr} Caractéristiques d'un alias
LPARAMETERS ;
	tcAlias,; && [Alias()] Alias à analyser
	tcResult && @ Résultat

RETURN CreateObject('oAlias', m.tcAlias, @m.tcResult)

* ========================================
DEFINE CLASS oAlias as Relation && {en} Alias settings {fr} Caractéristiques d'un alias
* ========================================
&& as GA_LIGHTWEIGHT_CLASS (GA_LIGHTWEIGHT_CLASS protects this.cResult)

cDBF = .NULL.
cAlias = .NULL.
lReadonly = .NULL.
lExclusive = .NULL.
cOrder = .NULL.
cFilter = .NULL.
cSetKey1 = .NULL.
cSetKey2 = .NULL.
iBuffering = .NULL.
iRecno = .NULL.
DIMENSION aRelationSrce[1], aRelationTrgt[1]

cResult = ''

* ---------------------------------------------------
PROCEDURE Init && Mémorise les attributs d'un Alias
LPARAMETERS ;
	tcAlias,; && [Alias()] Alias à analyser
	tcResult && @ Résultat
tcAlias = Evl(m.tcAlias, Alias())
tcResult = Evl(m.tcResult, '')

LOCAL loSelect AS abSelect OF abData.prg;
, laRelation[1]

IF Used(m.tcAlias)

	loSelect = abSelect(m.tcAlias)
	WITH m.this AS oAlias OF aData.prg
		.cDBF = FullPath(Dbf())
		.cAlias = m.tcAlias
		.lReadonly = IsReadonly()
		.lExclusive = IsExclusive()
		.cFilter = Filter()
		.cOrder = Order()
		.cSetKey1 = Set("Key", 1)
		.cSetKey2 = Set("Key", 2)
		.iBuffering = CursorGetProp("Buffering")
		.iRecno = Recno_()
		IF aRelationSrce(@m.laRelation) > 0
			DIMENSION .aRelationSrce[Alen(laRelation, 1), Alen(laRelation, 2)]
			Acopy(m.laRelation, .aRelationSrce)
		ENDIF
		IF aRelationTrgt(@m.laRelation) > 0
			DIMENSION .aRelationTrgt[2]
			Acopy(m.laRelation, .aRelationTrgt)
		ENDIF
	ENDWITH
ELSE
	tcResult = Textmerge([oAlias.Init() - ] + ICase(;
		cLangUser() = 'fr',	[L'alias '<<m.tcAlias>>' est introuvable.],; && copy-paste this line to add another language support
												[Alias '<<m.tcAlias>>' can't be found.]; && Default: English
		))
	RETURN .F. && object is not created
ENDIF

* ---------------------------------------------------
PROCEDURE Swap && Ouvre une table sous l'alias initial et lui applique les mêmes attributs
LPARAMETERS ;
	tcDBF,; && table
	tcResult && @ Résultat

LOCAL loSelect AS abSelect OF abData.prg;
, loException AS Exception;
, lcValue1, lcValue2, liValue;
, llResult

WITH m.this AS oAlias OF abData.prg
	
	IF File(m.tcDBF)

		llResult = Used(.cAlias) AND .cDBF == FullPath(m.tcDBF) && fichier inchangé, inutile de changer
		IF NOT m.llResult
		
			TRY
				
				* Fermer l'alias courant
				IF lBufferDirty(.cAlias)
					liValue = TableRevert(.T., .cAlias)
					.cResult = Textmerge(ICase(;
						cLangUser() = 'fr',	[Le tampon de <<.cAlias>> a été vidé, soit <<m.liValue>> enregistrement(s)],; && copy-paste this line to add another language support
																[Buffered data of <<.cAlias>> were discarded, <<m.liValue>> record(s)]; && Default: English
						))
				ENDIF
				USE IN Select(.cAlias)

				* Ouvrir la nouvelle table sous le même alias
				lcValue1 = Iif(.lExclusive, ' EXCLUSIVE', ' SHARED')
				lcValue2 = Iif(.lReadOnly, ' NOUPDATE', '')
				USE (m.tcDBF) IN 0 ALIAS (.cAlias) &lcValue1 &lcValue2
				loSelect = abSelect(.cAlias)
				
				llResult = lTableExpr(.cFilter)
				IF m.llResult

					lcValue1 = .cFilter
					SET FILTER TO &lcValue1

					llResult = Empty(.cOrder) OR lTag(.cOrder)
					IF m.llResult

						SET ORDER TO (.cOrder)
						IF NOT Empty(.cSetKey1)
							lcValue1 = .cSetKey1
							IF Empty(.cSetKey2)
								SET KEY TO &lcValue1
							ELSE
								lcValue2 = .cSetKey2
								SET KEY TO RANGE &lcValue1, &lcValue2
							ENDIF
						ENDIF
						IF Alen(.aRelationSrce) > 1
							FOR liValue = 1 TO Alen(.aRelationSrce, 1)
								lcValue1 = .aRelationSrce[m.liValue, 1]
								lcValue2 = .aRelationSrce[m.liValue, 2]
								llResult = lTableExpr(m.lcValue1)
								IF m.llResult
									llResult = Used(m.lcValue2)
									IF m.llResult
										SET RELATION TO &lcValue1 INTO (m.lcValue2)
									ELSE
										.cResult = Textmerge(ICase(;
											cLangUser() = 'fr',	[L'alias '<<m.lcValue2>>', cible de relation de '<<.cAlias>>', est introuvable],; && copy-paste this line to add another language support
																					[Alias '<<m.lcValue2>>', relation target of '<<.cAlias>>', can't be found]; && Default: English
											))
									ENDIF
								ELSE
									.cResult = Textmerge(ICase(;
										cLangUser() = 'fr',	[L'expression relationnelle '<<m.lcValue1>>' est invalide sur la table '<<m.tcDBF>>'],; && copy-paste this line to add another language support
																				[Relational expression '<<m.lcValue1>>' is invalid on table '<<m.tcDBF>>']; && Default: English
										))
								ENDIF
								IF NOT m.llResult
									EXIT
								ENDIF
							ENDFOR
						ENDIF
						IF m.llResult AND Alen(.aRelationTrgt) > 1
							lcValue1 = .aRelationTrgt[1] && Relational expression
							lcValue2 = .aRelationTrgt[2] && Source Alias
							SET RELATION TO &lcValue1 INTO (.cAlias) IN (m.lcValue2) 
						ENDIF
					ELSE
						.cResult = Textmerge(ICase(;
							cLangUser() = 'fr',	[L'index '<<.cOrder>>' est introuvable dans la table '<<m.tcDBF>>'],; && copy-paste this line to add another language support
																	[Index tagged '<<.cOrder>>' can't be found in table '<<m.tcDBF>>']; && Default: English
							))
					ENDIF
				ELSE
					.cResult = Textmerge(ICase(;
						cLangUser() = 'fr',	[L'expression de filtre '<<.cFilter>>' est invalide sur la table '<<m.tcDBF>>'],; && copy-paste this line to add another language support
																[Filter expression '<<.cFilter>>' is invalid on table '<<m.tcDBF>>']; && Default: English
						))
				ENDIF
				IF m.llResult
					CursorSetProp("Buffering", .iBuffering)
					RecnoSet(.iRecno)
				ELSE
					USE IN Select(.cAlias)
				ENDIF
			CATCH TO loException
				llResult = .F.
				.cResult = cException(m.loException)
			ENDTRY
		ENDIF
	ELSE
		.cResult = Textmerge(ICase(;
			cLangUser() = 'fr',	[Le fichier '<<m.tcDBF>>' est introuvable.],; && copy-paste this line to add another language support
													[File '<<m.tcDBF>>' can't be found.]; && Default: English
			))
	ENDIF
	tcResult = Iif(m.llResult, m.tcResult, .cResult)
ENDWITH

RETURN m.llResult

* ========================================
ENDDEFINE && CLASS oAlias
* ========================================

* ========================================
FUNCTION cAliasUsed && Alias sous lequel une table est ouverte (le premier si plusieurs)
LPARAMETERS ;
	tcTable,; && Adresse de la table
	tlExclusive && @ [.F.] La table est ouverte en exclusif
tlExclusive = .F.

LOCAL lcResult; && Alias
, laUsed[1]

lcResult = ''

* Si la table existe et est ouverte
IF File(m.tcTable) AND aUsed(laUsed, .NULL., m.tcTable) > 0

	lcResult = laUsed[1]
	tlExclusive = IsExclusive(m.lcResult)
ENDIF

RETURN m.lcResult

* ========================================
FUNCTION aUsedDBF && Table *.DBF couramment used() dans cette session de VFP && /!\ d'autres sessions peuvent les utiliser en réseau ...
LPARAMETERS taUsed && @ Fichiers *.DBF couramment used()
EXTERNAL ARRAY taUsed

LOCAL lnDS_, liDS, laDS[1], lnDS, laResult[1], liResult, lcResult, lnResult

lnResult = 0
IF aClear(@m.taUsed)

	lnDS_ = Set("Datasession")
	FOR liDS = 1 TO Asessions(laDS) && don't know how to get the number of datasessions currently open

		lnDS = m.laDS[m.liDS]

		TRY

			aClear(@m.laResult)
			lnResult = aUsed(m.laResult, m.lnDS)
			IF m.lnResult > 0

				SET DATASESSION TO m.lnDS && pour dbf()
				aColDel(@m.laResult, 2)
				DIMENSION laResult[m.lnResult]
				FOR liResult = 1 TO m.lnResult

					lcResult = cFileCased(Dbf(laResult[m.liResult]), .T.)
					IF Empty(m.lcResult)
						Adel(m.laResult, m.liResult)
						lnResult = m.lnResult - 1
					ELSE
						laResult[m.liResult] = m.lcResult
					ENDIF
				ENDFOR
				IF m.lnResult > 0
					DIMENSION laResult[m.lnResult]
					lnResult = aAppend(@m.taUsed, @m.laResult, .T.)
				ENDIF
			ENDIF
		CATCH
		ENDTRY
	ENDFOR
	SET DATASESSION TO m.lnDS_

	lnResult = Iif(laEmpty(@m.taUsed), 0, Alen(m.taUsed))
ENDIF

RETURN m.lnResult

* ========================================
PROCEDURE AliasReuse && Rouvre un alias dans un autre mode
LPARAMETERS ;
	tcAlias,; && Alias
	tcMode,; && [''] 'Exclusive' | 'Shared' | 'Noupdate' | '' (=Set("EXCLUSIVE"))
	tlAgain,; && [.F.] AGAIN
	tcAliasNew && [m.tcAlias] Nouvel Alias

LOCAL lcTable, lcOrder, lcFilter, lcField, lcFields, lcMode, laUsed[1], llAgain, lcAgain;
	, lnSelect, loException AS Exception;
	, llResult

tcAlias = Upper(Evl(m.tcAlias, ''))
IF Used(m.tcAlias)

	tcAliasNew = Upper(Evl(m.tcAliasNew, m.tcAlias))
	llResult = m.tcAlias == m.tcAliasNew OR NOT Used(m.tcAliasNew)
	ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([Impossible de réouvrir l'alias '<<m.tcAlias>>' sous l'alias '<<m.tcAliasNew>>' car il est déjà utilisé]))
	IF m.llResult

		tcMode = Upper(Left(Ltrim(Evl(m.tcMode, '')), 1))
		tlAgain = Iif(lTrue(m.tlAgain) AND NOT m.tcMode == 'E', 'AGAIN', '')
		tcMode = ICase(m.tcMode == 'E', 'EXCLUSIVE', m.tcMode == 'S', 'SHARED', m.tcMode == 'R', 'READONLY', '')
		
		lnSelect = Select(0)
		SELECT (m.tcAlias)

		* Mémoriser l'état de l'alias
		lcTable = cTableAddress()
		lcOrder = Iif(Empty(Order()), '', 'ORDER ' + Order())
		lcFilter = Filter()
		lcField = Set("Fields")
		lcFields = Set("Fields", 1)

		lcMode = ICase(IsExclusive(), 'EXCLUSIVE', IsReadonly(), 'READONLY', 'SHARED')
		llAgain = aUsed(laUsed, .NULL., m.lcTable) > 1 && et encore il faudrait vérifier chaque session de données !
		lcAgain = Iif(m.llAgain, 'AGAIN', '')

		llResult = NOT (m.llAgain AND m.tcMode == 'EXCLUSIVE')
		ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([Impossible de réouvrir l'alias '<<m.tcAlias>>' en exclusif car sa table '<<DisplayPath(cFileCased(m.lcTable), 50)>>' est déjà ouverte]))
		IF m.llResult

			llResult = .F.
			USE && si on reuse par dessus, VFP peut prendre un homonyme
			TRY
				USE (m.lcTable) &tlAgain &tcMode ALIAS (m.tcAliasNew) &lcOrder
				llResult = .T.
			CATCH TO loException
				USE (m.lcTable) &lcAgain &lcMode ALIAS (m.tcAlias) &lcOrder
			ENDTRY
			
			SET FILTER TO &lcFilter
			SET FIELDS TO &lcFields
			SET FIELDS &lcField
		ENDIF
		SELECT (m.lnSelect)
	ENDIF
ENDIF

RETURN m.llResult	

* ========================================
FUNCTION abExclusive && Tente d'ouvrir ou réouvrir une table en exclusif et la remet dans l'état initial au Destroy()
LPARAMETERS tuTable && [Alias()] Alias, zone ou adresse d'une table
RETURN CreateObject('abExclusive', m.tuTable)

* ========================================
DEFINE CLASS abExclusive as GA_LIGHTWEIGHT_CLASS && Tente d'ouvrir ou réouvrir une table en exclusif et la remet dans l'état initial au Destroy()

HIDDEN lUsed, cAlias, cTable, cOrder, cFilter, iRecno, lReadOnly, cFields

* --------------------------
PROCEDURE Init
LPARAMETERS tuTable && [Alias()] Alias, zone ou adresse d'une table

tuTable = Evl(m.tuTable, Alias())
this.lUsed = Vartype(m.tuTable) == 'C' AND Used(m.tuTable)
IF m.this.lUsed
	this.cOrder = Order(m.tuTable)
	this.cFilter = Filter(m.tuTable)
	this.iRecno = Recno_(m.tuTable)
	this.lReadOnly = IsReadonly(m.tuTable)
ENDIF

LOCAL llExclusive, llResult

this.cAlias = ExclusiveForce(m.tuTable, @m.llExclusive)
llResult = Used(m.this.cAlias)
this.cTable = Iif(m.llResult, FullPath(Dbf(m.this.cAlias)), '')

RETURN m.llResult AND NOT m.llExclusive

* --------------------------
PROCEDURE Destroy

USE IN Select(m.this.cAlias)

IF m.this.lUsed

	LOCAL lcFilter
	lcFilter = this.cFilter
	
	USE (m.this.cTable) AGAIN SHARED ALIAS (m.this.cAlias)
	SET ORDER TO (m.this.cOrder) IN (m.this.cAlias)
	SET FILTER TO &lcFilter IN (m.this.cAlias)
	RecnoSet(m.this.iRecno, m.this.cAlias)
ENDIF

ENDDEFINE && CLASS abExclusive 
* ========================================

* ========================================
function lExclusiveForce && Tente d'ouvrir ou réouvrir une table en exclusif
lparameters ;
	tcAlias,;	&& @ Alias
	tuTable,;	&& [Alias()] Alias, zone ou adresse d'une table
	tlExcl && @ L'alias était déjà ouvert en exclusif

tcAlias = ExclusiveForce(m.tuTable, @m.tlExcl)

return Used(m.tcAlias)

* ========================================
PROCEDURE ExclusiveForce && Tente d'ouvrir ou réouvrir une table en exclusif
LPARAMETERS ;
	tuTable,;	&& [Alias()] Alias, zone ou adresse d'une table
	tlExcl && @ L'alias était déjà ouvert en exclusif
tlExcl = .F.

LOCAL lcAlias, llAlias, lcResult	&& Alias sous lequel la table est ouverte en exclusif, vide si impossible d'ouvrir en exclusif

lcResult = ''

* Si l'alias de la table existe
lcAlias = cAlias(m.tuTable, @m.llAlias)
IF Used(m.lcAlias)

	tlExcl = NOT m.llAlias AND IsExclusive(m.lcAlias) && L'alias était déjà ouvert et en exclusif
	lcResult = Iif(IsExclusive(m.lcAlias) OR AliasReuse(m.lcAlias, 'EXCLUSIVE'), m.lcAlias, '')
ENDIF

RETURN m.lcResult

* ========================================
PROCEDURE HeaderFieldsCarry	&& Copie le contenu des champs d'entête dans l'enr. suivant
LPARAMETERS ;
	tuTable,;	&& [Alias()] Alias, zone ou adresse d'une table
	tcFields && [''] Champs d'en-tête
LOCAL llResult

* Si l'alias de la table existe
LOCAL lcAlias, llAlias
lcAlias = cAlias(m.tuTable, @m.llAlias)
llResult = Used(m.lcAlias)
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([Impossible d'ouvrir la table <<cL(m.tuTable)>>]))
IF m.llResult

	* Si des champs sont spécifiés et au moins un existe dans la table
	llResult = lFields(m.tcFields, m.lcAlias, .T.)
	ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([Aucun des champs <<m.tcFields>> n'existe dans la table <<cL(m.tuTable)>>]))
	IF m.llResult
	
		* Tabuler les champs
		LOCAL laFields[1], lnFields, lnField, lcField
		lnFields = ALines(laFields, m.tcFields, 1+4, ',')
	
		* Sélectionner la table sur le 1er enr.
		LOCAL lnSelect
		lnSelect = Select(0)
		SELECT (m.lcAlias)
		LOCATE

		* Initialiser les valeurs des champs d'en-tête
		LOCAL laValues[m.lnFields], luValue
		FOR m.lnField = 1 TO m.lnFields
			laValues[m.lnField] = Evaluate(laFields[m.lnField])
		ENDFOR

		* Pour chaque enregistrement
		SCAN
			SCATTER MEMVAR MEMO
			
			* Pour chaque champ d'en-tête
			FOR m.lnField = 1 TO m.lnFields
				lcField = 'm.' + laFields[m.lnField]
				luValue = Evaluate(m.lcField)
				
				* Si le champ est vide, prendre la valeur d'entête courante
				IF Empty(m.luValue)
					STORE (laValues[m.lnField]) TO (m.lcField)

				* Sinon, mémoriser la valeur d'en-tête
				ELSE
					laValues[m.lnField] = m.luValue
				ENDIF
			ENDFOR
			GATHER MEMVAR MEMO
		ENDSCAN
		SELECT (m.lnSelect)
	ENDIF
ENDIF

IF m.llAlias
	USE IN (m.lcAlias)
ENDIF

RETURN m.llResult

* ========================================
PROCEDURE TableMove && Déplace une table et ses fichiers dépendants dans un autre dossier
LPARAMETERS ;
	tcSrceAddr,; && Adresse actuelle de la table
	tcDestAddr && Adresse cible

LOCAL llResult

* Si le fichier source existe
llResult = lFile(m.tcSrceAddr)
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([le fichier <<m.tcSrceAddr>> est introuvable]))
IF m.llResult

	* Si le dossier de destination existe
	tcDestAddr = JustPath(m.tcDestAddr)
	llResult = Directory(m.tcDestAddr)
	ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([le dossier destination <<m.tcDestAddr>> est introuvable]))
	IF m.llResult
	
		* Si le dossier de destination est différent du dossier source
		llResult = NOT c83Address(m.tcDestAddr) == c83Address(JustPath(m.tcSrceAddr))
		ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([le dossier destination <<m.tcDestAddr>> est identique au dossier source (<<m.tcSrceAddr>>)]))
		IF m.llResult
		
			* Si le fichier source est une table et peut être ouverte en exclusif
			LOCAL lcAlias, llOpened
			lcAlias = ExclusiveForce(cAlias(m.tcSrceAddr, @m.llOpened))
			llResult = Used(m.lcAlias)
			ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([le fichier source <<m.tcSrceAddr>> n'est pas une table ou ne peut pas être ouverte en exclusif]))
			IF m.llResult
			
				* Copier à l'adresse destination
				LOCAL loSelect AS abSelect
				tcDestAddr = ForcePath(JustFname(m.tcSrceAddr), m.tcDestAddr)
				loSelect = abSelect(m.lcAlias)
				COPY TO (m.tcDestAddr) WITH CDX
				
				* Si la table était déjà ouverte, ouvrir la nouvelle à la place
				IF m.llOpened
					USE IN (m.lcAlias)
				ELSE
					USE (m.tcDestAddr) ALIAS (m.lcAlias)
				ENDIF
				
				* Supprimer l'ancienne table, ses fichiers mémo et index éventuels
				ERASE (m.tcSrceAddr)
				ERASE (ForceExt(m.tcSrceAddr, 'FPT'))
				ERASE (ForceExt(m.tcSrceAddr, 'CDX'))

			ELSE
				IF m.llOpened
					USE IN (m.lcAlias)
				ENDIF
			ENDIF
		ENDIF
	ENDIF
ENDIF

RETURN m.llResult

* ========================================
PROCEDURE TablesMerge && Fusionne 2 tables en ajustant la structure de la réceptacle
LPARAMETERS ;
	tuDestTable,; && Alias ou zone ou adresse de la table destination (crée si elle n'existe pas)
	tuSrceTable && [Alias()] Alias ou zone ou adresse de la table source
LOCAL llResult && La fusion a été réalisée

* Si une table destination a été précisée
LOCAL llParms, ;
	lcDestAlias, llDestOpened, llDestCreate, ;
	lcSrceAlias, llSrceOpened, lcSrceAddr
llParms = NOT Empty(m.tuDestTable)
IF m.llParms
	
	* Si la table destination ne peut pas être ouverte, 
	lcDestAlias = cAlias(m.tuDestTable, @m.llDestOpened)
	llParms = Used(m.lcDestAlias)
	IF NOT m.llParms

		* Vérifier qu'elle pourra être créé
		IF Vartype(m.tuDestTable) == 'C'
			tuDestTable = ForceExt(m.tuDestTable, [dbf])
			llDestCreate = Directory(JustPath(m.tuDestTable)) ;
				AND lFileAddress(m.tuDestTable)
			llParms = m.llDestCreate
		ENDIF
	ENDIF

	* Si table Dest OK,
	IF m.llParms

		* Vérifier que la table source est accessible
		lcSrceAlias = cAlias(m.tuSrceTable, @m.llSrceOpened)
		llParms = Used(m.lcSrceAlias)
		lcSrceAddr = cTableAddress(m.lcSrceAlias)
	ENDIF
ENDIF

ASSERT m.llParms MESSAGE "Table source et/ou destination invalide"
IF m.llParms

	LOCAL lnSelect
	lnSelect = Select(0)

	* Si la la table destination n'existe pas,
	IF m.llDestCreate

		* Copier la table source dedans
		SELECT (m.lcSrceAlias)
		COPY TO (m.tuDestTable)
		llResult = .T.
		
	* Sinon (la table destination existe)
	ELSE

		* Lire la structure des deux tables
		LOCAL lnSrce, lnDest
		LOCAL ARRAY laSrce[1], laDest[1]
		lnSrce = AFields(laSrce, m.lcSrceAlias)
		lnDest = AFields(laDest, m.lcDestAlias)
		
		* Pour chaque champ source
		LOCAL lnField, lcField, lnLength1, lnLength2, lnIdx, llAdjust, lnDest1
		lnDest1 = m.lnDest
		FOR m.lnField = 1 TO m.lnSrce
			lcField = laSrce[m.lnField, 1]
			
			* Si le champ existe dans la table destination
			lnIdx = Ascan(laDest, m.lcField, 1, -1, 1, 2+4)
			IF m.lnIdx > 0

				* Si les champs source et destination sont de même type
				IF laDest[m.lnIdx + 1] == laSrce[m.lnField, 2] && same type
					IF laDest[m.lnIdx + 2] < laSrce[m.lnField, 3]
						laDest[m.lnIdx + 2] = laSrce[m.lnField, 3]
						llAdjust = .T.
					ENDIF
					IF laDest[m.lnIdx + 3] < laSrce[m.lnField, 4]
						laDest[m.lnIdx + 3] = laSrce[m.lnField, 4]
						llAdjust = .T.
					ENDIF
				ELSE
					WAIT cModuleInfo(Sys(16));
						+ Space(1) + ICase(;
								cLangUser() = 'fr',	"Champ de types différents dans les 2 tables",; && copy-paste this line to add another language support
																			"The 2 tables have fields of different types"); && Default: English
						+ Space(1) + m.lcField;
					WINDOW NOWAIT
				ENDIF
			
			* Sinon (le champ source n'existe pas dans la destination),
			ELSE

				* Ajouter le champ à la table destination
				lnDest1 = m.lnDest1 + 1
				DIMENSION laDest[m.lnDest1, Alen(laDest,2)]
				LOCAL j
				FOR m.j = 1 TO Alen(laDest,2)
					laDest[m.lnDest1, m.j] = laSrce[m.lnField, m.j]
				ENDFOR
				llAdjust = .T.
			ENDIF
		ENDFOR

		* Ajuster si nécessaire la structure de la table destination
		IF m.llAdjust
			lcDestAlias = ExclusiveForce(m.lcDestAlias)
			llAdjust = Used(m.lcDestAlias)
			ASSERT m.llAdjust MESSAGE "Impossible d'ouvrir la table destination en exclusif"
			IF m.llAdjust
				LOCAL lcAlter
				lcAlter = 'ALTER TABLE ' + m.lcDestAlias
				FOR m.lnField = 1 TO m.lnDest1
					lcAlter = m.lcAlter + Space(1) + ;
						Iif(m.lnField <= m.lnDest, 'ALTER', 'ADD') + Space(1) + ;
						'COLUMN' + Space(1) + ;
						cFieldExp(laDest[m.lnField, 1], laDest[m.lnField, 2], laDest[m.lnField, 3], laDest[m.lnField, 4], NULL)
				ENDFOR
				&lcAlter
				llResult = .T.
			ENDIF
		ELSE
			llResult = .T.
		ENDIF
		
		* Si la structure de la table dest est OK
		IF m.llResult
			* Ajouter le contenu de la source à la destination
			SELECT (m.lcDestAlias)
			APPEND FROM (m.lcSrceAddr)
		ENDIF
	ENDIF
	
	SELECT (m.lnSelect)
ENDIF

* Refermer les tables ouvertes ici
IF m.llDestOpened
	USE IN (m.lcDestAlias)
ENDIF
IF m.llSrceOpened
	USE IN (m.lcSrceAlias)
ENDIF

RETURN m.llResult

* ========================================
FUNCTION lFPT && Une table a un fichier FPT associé (présence d'un champ mémo, Varchar, Varbinary, Blob, etc.)
LPARAMETERS tuTable && Alias ou zone ou adresse d'une table

LOCAL lcAlias, llAlias, llResult

lcAlias = cAlias(m.tuTable, @m.llAlias)

llResult = .T.;
 AND Used(m.lcAlias);
 AND File(ForceExt(Dbf(m.lcAlias), 'FPT'))

IF m.llAlias
	USE IN Select(m.lcAlias)
ENDIF

RETURN m.llResult

* ========================================
FUNCTION lTablesIdem && Deux tables sont identiques : mêmes structure et contenu
LPARAMETERS ;
	tuTable1,; && Alias ou zone ou adresse de la première table
	tuTable2,; && Alias ou zone ou adresse de la seconde table
	tlFieldsOrder && [.F.] Les champs doivent être dans le même ordre
LOCAL llResult && Les tables sont identiques

* Si les spécifications de tables sont valides
LOCAL lcAlias1, lcAlias2, llAlias1, llAlias2
lcAlias1 = cAlias(m.tuTable1, @m.llAlias1)
lcAlias2 = cAlias(m.tuTable2, @m.llAlias2)
llResult = Used(m.lcAlias1) and Used(m.lcAlias2)
ASSERT m.llResult MESSAGE cAssertMsg("Spécifications de tables invalides" + CRLF;
	+ cLitteral(m.tuTable1) + CRLF;
	+ cLitteral(m.tuTable2);
	)
IF m.llResult
	LOCAL llFieldsOrder
	llFieldsOrder = uDefault(m.tlFieldsOrder, .F.)

	* Si les tables ont des structures identiques
	llResult = lFieldsIdem(m.lcAlias1, m.lcAlias2, m.llFieldsOrder)
	IF m.llResult
		
		* Construire l'expression de jointure
		LOCAL lnRecs, lnFields, lnField, lcField, lcJoin
		lnRecs = Reccount(m.lcAlias1)
		lnFields = Fcount(m.lcAlias1)
		lcJoin = ''
		FOR m.lnField = 1 to m.lnFields
			lcField = Field(m.lnField, m.lcAlias1)
			lcJoin = c2Words(m.lcJoin, '.AND.';
					, m.lcAlias1 + [.] + m.lcField + '=' + m.lcAlias2 + [.] + m.lcField)
		ENDFOR

		* Extraire les enregistrements concordants
		LOCAL lnSelect, loAnsi
		lnSelect = Select(0)
		loAnsi = abSet('ANSI', 'ON')
		SELECT * FROM (m.lcAlias1) FULL JOIN (m.lcAlias2) ON &lcJoin INTO CURSOR (Sys(2015))
		llResult = _tally = m.lnRecs

		USE
		RELEASE loAnsi
		SELECT (m.lnSelect)

	ENDIF
ENDIF

IF m.llAlias1
	USE IN Select(m.lcAlias1)
ENDIF
IF m.llAlias2
	USE IN Select(m.lcAlias2)
ENDIF

RETURN m.llResult

* ========================================
FUNCTION lFieldsIdem && Deux tables ont la même structure
LPARAMETERS ;
	tuTable1,; && Alias ou zone ou adresse de la première table
	tuTable2,; && Alias ou zone ou adresse de la seconde table
	tlFieldsOrder && [.F.] Les champs doivent être dans le même ordre
LOCAL llResult && Les tables ont la même structure

* Si les spécifications de tables sont valides
LOCAL lcAlias1, lcAlias2, llAlias1, llAlias2
lcAlias1 = cAlias(m.tuTable1, @m.llAlias1)
lcAlias2 = cAlias(m.tuTable2, @m.llAlias2)
llResult = Used(m.lcAlias1) and Used(m.lcAlias2)
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([<<cCallingModules(.T.)>> - Spécifications de tables invalides : <<cLitteral(m.tuTable1)>> | <<cLitteral(m.tuTable2)>>]))
IF m.llResult

	* Lire les structures des deux tables
	LOCAL ARRAY laFields1[1], laFields2[1]
	LOCAL lnFields1, lnFields2
	lnFields1 = AFields(laFields1, m.lcAlias1)
	lnFields2 = AFields(laFields2, m.lcAlias2)
	
	* Si les tables ont le même nombre de champs
	llResult = m.lnFields1 = m.lnFields2
	IF m.llResult
	
		* Supprimer les colonnes inutiles
		aColsDel(@m.laFields1, 5)
		aColsDel(@m.laFields2, 5)
		
		* Donner sa valeur par défaut au paramètre optionnel
		LOCAL llFieldsOrder
		llFieldsOrder = uDefault(m.tlFieldsOrder, .F.)
		
		* Si les champs doivent être dans le même ordre
		IF m.llFieldsOrder
			
			llResult = laEqual(@m.laFields1, @m.laFields2)
		
		* Sinon (les champs peuvent être dans un ordre différent)
		ELSE
		
			* Pour chaque champ de la première table
			LOCAL lnField1, lcField1, lnField2
			FOR m.lnField1 = 1 TO m.lnFields1
				lcField1 = laFields1[m.lnField1, 1]

				* Si le champ existe dans la deuxième table
				lnField2 = Ascan(laFields2, m.lcField1, 1, -1, 1, 2+4+8)
				llResult = m.lnField2 > 0
				IF m.llResult
				
					* Si les deux champs ont les mêmes caractéristiques
					llResult = ;
								laFields1[m.lnField1, 2] = laFields2[m.lnField2, 2] ;
						AND laFields1[m.lnField1, 3] = laFields2[m.lnField2, 3] ;
						AND laFields1[m.lnField1, 4] = laFields2[m.lnField2, 4]
					IF NOT m.llResult
						EXIT
					ENDIF
				ELSE
					EXIT
				ENDIF
			ENDFOR
		ENDIF
	ENDIF
ENDIF

IF m.llAlias1
	USE IN Select(m.lcAlias1)
ENDIF
IF m.llAlias2
	USE IN Select(m.lcAlias2)
ENDIF

RETURN m.llResult

* ========================================
FUNCTION l2FieldsIdem && deux champs sont de même structure : type[, longueur [décimales]]
LPARAMETERS ;
	tcTableField1,; && 'table.field' du premier champ
	tcTableField2,; && 'table.field' du second champ
	tlNullIgnore,; && [.F.] Ignorer si "Null values allowed"
	tlContains && [.F.] le champ 2 doit pouvoir contenir le champ 1
LOCAL llResult && Les deux champs ont la même structure

LOCAL lcAlias1, lcAlias2, llAlias1, llAlias2, lcField1, lcField2, laFields1[1], laFields2[1], lnField1, lnField2
lcAlias1 = cAlias(JustStem(m.tcTableField1), @m.llAlias1)
lcAlias2 = cAlias(JustStem(m.tcTableField2), @m.llAlias2)
llResult = Used(m.lcAlias1) AND Used(m.lcAlias2)
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([<<cCallingModules(.T.)>> - Paramètres invalides: <<m.tcTableField1>> | <<m.tcTableField2>>]))
IF m.llResult
	
	lcField1 = Upper(JustExt(m.tcTableField1))
	lcField2 = Upper(JustExt(m.tcTableField2))
	llResult = lField(m.lcField1, m.lcAlias1) AND lField(m.lcField2, m.lcAlias2)
	ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([<<cCallingModules(.T.)>> - Les champs <<m.lcField1>> et <<m.lcField2>> doivent appartenir aux tables <<m.lcAlias1>> et <<m.lcAlias2>>]))
	IF m.llResult

		AFields(laFields1, m.lcAlias1)
		AFields(laFields2, m.lcAlias2)
		lnField1 = Ascan(laFields1, m.lcField1, 1, -1, 1, 2+4+8)
		lnField2 = Ascan(laFields2, m.lcField2, 1, -1, 1, 2+4+8)

		tlContains = Iif(Vartype(m.tlContains) == 'L', m.tlContains, .F.)
		llResult = laFields1[m.lnField1, AFIELDS_TYPE] == laFields2[m.lnField2, AFIELDS_TYPE];
			AND (NOT m.tlContains AND laFields1[m.lnField1, AFIELDS_WIDTH] == laFields2[m.lnField2, AFIELDS_WIDTH] OR laFields1[m.lnField1, AFIELDS_WIDTH] <= laFields2[m.lnField2, AFIELDS_WIDTH]);
			AND (NOT m.tlContains AND laFields1[m.lnField1, AFIELDS_PRECISION] == laFields2[m.lnField2, AFIELDS_PRECISION] OR laFields1[m.lnField1, AFIELDS_PRECISION] <= laFields2[m.lnField2, AFIELDS_PRECISION]);
			AND (lTrue(m.tlNullIgnore) OR laFields1[m.lnField1, AFIELDS_NULL] == laFields2[m.lnField2, AFIELDS_NULL])
	ENDIF
ENDIF

IF m.llAlias1
	USE IN (m.lcAlias1)
ENDIF
IF m.llAlias2
	USE IN (m.lcAlias2)
ENDIF

RETURN m.llResult

* -----------------------------------------------------------------
PROCEDURE l2FieldsIdem_Test

LOCAL loTest AS lFields_Test OF abData.prg
loTest = CreateObject('lFields_Test')
loTest.dataopen

loTest.Test(.T., 'TMP1.AAA', 'TMP2.AAA')
loTest.Test(.F., 'TMP1.BBB', 'TMP2.BBB')

RETURN loTest.Result()

* ========================================
PROCEDURE TableOfArray && Construit une table ou un curseur à partir d'un tableau
LPARAMETERS ;
	taArray,; && @ Tableau source
	tuTable,; && [Cursor] Adresse de la table à créer ou, si invalide, ordre de créer un curseur
	tl2D && [.F.] Créer autant de champs que de colonnes dans le tableau
LOCAL lcResult && Adresse de la table ou Alias du curseur
lcResult = ''
EXTERNAL ARRAY taArray

* Si un tableau a bien été passé
LOCAL llResult
llResult = NOT Type('taArray[1]') == 'U'
ASSERT m.llResult MESSAGE cAssertMsg("Spécification de tableau invalide" + CRLF + cLitteral(taArray))
IF m.llResult

	* Si le tableau est non vide
	IF NOT laEmpty(@m.taArray)
	
		* Déterminer si demande de curseur ou de table
		LOCAL llTable
		llTable = Vartype(m.tuTable) == 'C' AND NOT Empty(m.tuTable)
		
		* Si une adresse de table valide a été passée
		IF m.llTable
			LOCAL lcTableAddr
			lcTableAddr = ForceExt(m.tuTable, [dbf])
			llResult = lFileAddress(m.lcTableAddr)
			ASSERT m.llResult MESSAGE cAssertMsg("Spécification d'adresse de table invalide" + CRLF + cLitteral(m.tuTable))
		ENDIF
		
		* si tout va bien jusqu'ici
		IF m.llResult

			* Vérifier les dimensions du tableau
			LOCAL lnRows, lnCols, lnRow, lnCol
			lnRows = Alen(taArray, 1)
			lnCols = Alen(taArray, 2)
			IF m.lnCols = 1
				DIMENSION taArray[m.lnRows]
			ENDIF
			tl2D = lTrue(m.tl2D) AND m.lnCols > 1
		
			* Créer le curseur ou la table
			LOCAL loSelect, lcFields, lcAlias, lcType, lnLen, lnDec
			loSelect = abSelect()
			IF m.tl2D
				lcFields = ''
				FOR lnCol = 1 TO m.lnCols
					lcType = Vartype(taArray[1, m.lnCol])
					lnLen = ICase(.F., '';
						, m.lcType == 'C', 200;
						, m.lcType == 'N', 10;
						, 8;
						)
					lnDec = Iif(m.lcType == 'N', 2, 0)
					lcFields = m.lcFields + cFieldExp(TableOfArray_cField(m.lnCol), m.lcType, m.lnLen, m.lnDec) + ','
				NEXT
				lcFields = '(' + Left(m.lcFields, Len(m.lcFields)-1) + ')'
	 		ELSE
				lcFields = "(NR I, NC I, ET C(1), EV C(254))"
			ENDIF
			lcResult = Iif(m.llTable, m.lcTableAddr, Sys(2015))
			IF m.llTable
				CREATE TABLE (m.lcResult) FREE &lcFields
			ELSE
				CREATE CURSOR (m.lcResult) &lcFields
			ENDIF
			lcAlias = Alias()
			
			* Pour chaque élément du tableau, ajouter à la table
			IF m.lnCols > 1 && tableau à 2 dimensions
				FOR lnRow = 1 TO m.lnRows
					FOR lnCol = 1 TO m.lnCols
						llResult = TableOfArray_EltInsert(@m.taArray, m.lcAlias, m.lnRow, m.lnCol, m.tl2D)
						IF NOT m.llResult
							EXIT
						ENDIF
					ENDFOR
					IF NOT m.llResult
						EXIT
					ENDIF
				ENDFOR
			ELSE && tableau à une dimension
				FOR lnRow = 1 TO m.lnRows
					llResult = TableOfArray_EltInsert(@m.taArray, m.lcAlias, m.lnRow, 0)
					IF NOT m.llResult
						EXIT
					ENDIF
				ENDFOR
			ENDIF

			* Si table, refermer
			IF m.llTable
				USE
			ENDIF
		ENDIF
	ENDIF
ENDIF

RETURN m.lcResult

* ========================================
FUNCTION TableOfArray_cField && [privée de TableOfArray()] Champ standard
LPARAMETERS tnCol
RETURN 'C' + Transform(m.tnCol, '@L 999')
			
* ========================================
PROCEDURE TableOfArray_EltInsert && Ajoute un élément à la table / au curseur
LPARAMETERS ;
	taArray,; && @ Tableau source
	tcAlias,; && Alias de la table
	tnRow,; && N° de ligne
	tnCol,; && N° de colonne (0 si tableau à une dimension)
	tl2D && Créer autant de champs que de colonnes dans le tableau
LOCAL luElt, lcType, lcField, llResult

luElt = Iif(m.tnCol > 0, taArray[m.tnRow, m.tnCol], taArray[m.tnRow])
lcType = Vartype(m.luElt)
llResult = m.lcType $ 'CNDTLY'
ASSERT m.llResult MESSAGE cAssertMsg("Élément d'un type non supporté" + CRLF + cLitteral(m.luElt))
IF m.llResult
	IF m.tl2D
		IF m.tnCol = 1
			APPEND BLANK
		ENDIF
		lcField = TableOfArray_cField(m.tnCol) && Erreur "invalid subscript element" si directement dans le REPLACE
		REPLACE (m.lcField) WITH m.luElt
	ELSE
		INSERT INTO (m.tcAlias) VALUES (m.tnRow, m.tnCol, m.lcType, cLitteral(m.luElt))
	ENDIF
ENDIF

*!*			lcElt = cLitteral(m.luElt)
*!*			IF Len(m.lcElt) > 254
*!*				ALTER TABLE (m.tcAlias) ALTER COLUMN EV M
*!*			ENDIF

RETURN m.llResult

	* ========================================
PROCEDURE ArrayOfTable && Reconstitue un tableau à partir d'une sauvegarde par TableOfArray()
LPARAMETERS ;
	taArray,; && @ Tableau source
	tuTable && Alias ou adresse de la table / du curseur source
EXTERNAL ARRAY taArray
LOCAL lnResult && Nombre de lignes du tableau
lnResult = 0

* Si un tableau a bien été passé
LOCAL llResult
llResult = Type('taArray', 1) == 'U'
ASSERT m.llResult MESSAGE cAssertMsg("Spécification de tableau invalide" + CRLF + cLitteral(taArray))
IF m.llResult

	* Si une table a bien été passée
	LOCAL lcAlias, llAlias
	lcAlias = cAlias(m.tuTable, @m.llAlias)
	llResult = Used(m.lcAlias)
	ASSERT m.llResult MESSAGE cAssertMsg("Spécification de table invalide" + CRLF + cLitteral(m.tuTable))
	IF m.llResult
		
		* Si la table a une structure valide
		IF .T.
		&& à implémenter
		
			* Si la table a des enregistrements
			llResult = Reccount(m.lcAlias) > 0
			ASSERT m.llResult MESSAGE cAssertMsg("La table n'a aucun enregistrement !" + CRLF + cLitteral(m.tuTable))
			IF m.llResult

				* Dimensionner le tableau
				LOCAL ARRAY laFields[1]
				LOCAL llCols
				SELECT Max(NR), Max(NC) FROM (m.lcAlias) INTO ARRAY laFields
				lnResult = laFields[1]
				llCols = laFields[2] > 0
				IF m.llCols
					DIMENSION taArray[m.lnResult, laFields[2]]
				ELSE
					DIMENSION taArray[m.lnResult]
				ENDIF
				RELEASE laFields
				
				* Pour chaque enregistrement
				LOCAL lnSelect
				lnSelect = Select(0)
				SELECT (m.lcAlias)
				SCAN

					* Charger l'élément dans le tableau
					IF m.llCols
						taArray[NR, NC] = Evaluate(EV)
					ELSE
						taArray[NR] = Evaluate(EV)
					ENDIF
				ENDSCAN

				SELECT (m.lnSelect)
			ENDIF
		ENDIF
		IF m.llAlias
			USE IN (m.lcAlias)
		ENDIF
	ENDIF
ENDIF

RETURN m.lnResult

* ========================================
PROCEDURE cFieldsLTrim && Tronque à gauche les champs de type caractère, pour tous les enr.
LPARAMETERS ;
	tcTable,;	&& [Alias()] Alias, zone ou adresse d'une table
	tcFieldsIgnore && [''] Squelette des champs à ignorer
LOCAL llResult

* Si la table est accessible
LOCAL lcAlias, llAlias, loSelect
lcAlias = cAlias(m.tcTable, @m.llAlias)
llResult = Used(m.lcAlias)
IF m.llResult

	loSelect = abSelect(m.lcAlias)
	
	* Si la table était déjà ouverte, mémoriser son état
	IF NOT m.llAlias
		LOCAL lcOrder, lnRecno
		lcOrder = Order()
		lnRecno = Recno_()
		SET ORDER TO && sinon le scan risque de s'achever prématurément
	ENDIF

	* Traiter les champs à ignorer
	tcFieldsIgnore = Iif(Vartype(m.tcFieldsIgnore) == 'C', Upper(m.tcFieldsIgnore), 'c__hd_$') && champ bidon
	
	* Pour chaque enr.
	LOCAL laRec[1], lnField, luValue
	SCAN
		SCATTER TO laRec FIELDS EXCEPT &tcFieldsIgnore

		* Pour chaque champ
		FOR m.lnField = 1 TO Alen(laRec)
			luValue = laRec[m.lnField]

			IF Vartype(m.luValue) == 'C';
			 AND NOT Empty(m.luValue);
			 AND NOT IsNull(m.luValue)

			 	laRec[m.lnField] = Ltrim(m.luValue)
			ENDIF
		ENDFOR

		GATHER FROM laRec FIELDS EXCEPT &tcFieldsIgnore
	ENDSCAN

	* Rétablir la table dans l'état initial
	IF m.llAlias
		USE
	ELSE
		SET ORDER TO (m.lcOrder)
		RecnoSet(m.lnRecno)
	ENDIF
ENDIF

RETURN m.llResult

* ========================================
FUNCTION nField	&& Position d'un champ dans l'alias courant ou spécifié
LPARAMETERS ;
	tcField, ; && Nom du champ dont l'existence est a verifier
	tuTable && [Alias()] Alias ou adresse de la table où l'existence du champ est à verifier
LOCAL lnResult
lnResult = 0

IF Vartype(m.tcField) = 'C' ;
 AND !Empty(m.tcField)

	LOCAL lcAlias, llAlias
	lcAlias = cAlias(m.tuTable, @m.llAlias)
				
	IF Used(m.lcAlias)
		LOCAL lcField, lnField
		lcField = Upper(Alltrim(m.tcField))
		FOR m.lnField = 1 TO Fcount(m.lcAlias)
			IF Field(m.lnField, m.lcAlias) == m.lcField
				lnResult = m.lnField
				EXIT
			ENDIF
		ENDFOR

		IF m.llAlias
			USE IN (m.lcAlias)
		ENDIF
	ENDIF
ENDIF

RETURN m.lnResult

* ========================================
FUNCTION lTag	&& La table courante ou spécifiée a un tag d'index d'un certain nom
LPARAMETERS ;
	tcTag, ; && Nom du tag dont l'existence est à verifier
	tuTable && [Alias()] Alias ou adresse de la table où l'existence du tag est à verifier
LOCAL llResult

* Si un tag a été spécifié
llResult = Vartype(m.tcTag) == 'C' AND NOT Empty(m.tcTag)
 	IF m.llResult

	* Si la table peut être localisée
 	LOCAL lcAlias, llAlias
 	lcAlias = cAlias(m.tuTable, @m.llAlias)
 	llResult = Used(m.lcAlias)
 	ASSERT m.llResult MESSAGE cAssertMsg(Textmerge("Table can't be found: <<cL(m.tuTable)>>"))
 	IF m.llResult

	 	LOCAL lnSelect
		lnSelect = Select(0)
		SELECT (m.lcAlias)

	 	* Si la table comporte des tags d'index
	 	LOCAL lnTags
		lnTags = Tagcount()
		llResult = m.lnTags > 0
		IF m.llResult

		 	* Pour chaque tag de la table
		 	LOCAL lcTag, lnTag
		 	lcTag = Upper(Alltrim(m.tcTag))
			FOR m.lnTag = 1 TO m.lnTags

				* Si le tag est celui spécifié, fini
				llResult = Tag(m.lnTag) == m.lcTag && Tag() result is always uppercase
				IF m.llResult
					EXIT
				ENDIF
			ENDFOR
		ENDIF

		IF m.llAlias
			USE
		ENDIF
		SELECT (m.lnSelect)
 	ENDIF
ENDIF

RETURN m.llResult

* ========================================
FUNCTION lTags	&& La table courante ou spécifiée comporte des tags d'index d'un certain nom
LPARAMETERS ;
	tcTags, ; && Liste des tags dont l'existence est à vérifier
	tuTable,; && [Alias()] Alias ou adresse de la table où l'existence des tags est à vérifier
	tlOneAtLeast &&	[.F.] Au moins un des tags doit être présent
LOCAL llResult

IF Vartype(m.tcTags) == 'C' AND NOT Empty(m.tcTags)
 
	* Si la table peut être localisée
 	LOCAL lcAlias, llAlias
 	lcAlias = cAlias(m.tuTable, @m.llAlias)
 	IF Used(m.lcAlias)

	 	LOCAL llOneAtLeast
	 	llOneAtLeast = Iif(Vartype(m.tlOneAtLeast) == 'L', m.tlOneAtLeast, .F.)
	 	
	 	* Pour chaque tag spécifié
	 	LOCAL ARRAY laTags[1]
	 	LOCAL lcTag
	 	ALines(laTags, Upper(m.tcTags), .T., ',')
	 	FOR EACH lcTag IN laTags
	 	
	 		llResult = Empty(m.lcTag) OR lTag(m.lcTag, m.lcAlias)

			IF m.llResult AND m.llOneAtLeast ; &&	One at least and current exists
				OR ! m.llResult AND ! m.llOneAtLeast &&	All required and current misses
				EXIT
			ENDIF 
	 	ENDFOR

		IF m.llAlias
			USE IN (m.lcAlias)
		ENDIF
 	ENDIF
ENDIF

RETURN m.llResult

* ========================================
FUNCTION cTagOfExpr && Tag d'index d'une table construit sur une expression
LPARAMETERS ;
	tcExpr,; && Expression
	tuTable && [Alias()] Alias ou adresse de la table

LOCAL lcResult;
, llResult;
, lcAlias, llAlias, loSelect as abSelect;
, liTag

lcResult = ''

* Si la table peut être localisée
lcAlias = cAlias(m.tuTable, @m.llAlias)
llResult = Used(m.lcAlias)
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge("Table can't be found: <<cL(m.tuTable)>>"))
IF m.llResult

	* Si un tag a été spécifié
	llResult = lTableExpr(m.tcExpr, m.lcAlias)
 	ASSERT m.llResult MESSAGE cAssertMsg(Textmerge("Expression <<cL(m.tcExpr)>> is invalid on table <<m.lcAlias>>"))
 	IF m.llResult

 		tcExpr = Normalize(m.tcExpr)
 		loSelect = abSelect(m.lcAlias)
 		for liTag = 1 to Tagcount()
 			if m.tcExpr = Normalize(Sys(14, m.liTag, m.lcAlias))
 				lcResult = Tag('', m.liTag)
 			endif
 		endfor
 	ENDIF
	IF m.llAlias
		USE IN (m.lcAlias)
	ENDIF
ENDIF

RETURN m.lcResult

* ========================================
FUNCTION cTagExpr && Expression d'index d'un tag d'une table
LPARAMETERS ;
	tcTag,; && Tag à rechercher
	tuTable && [Alias()] Alias ou adresse de la table

LOCAL lcResult;
, llResult;
, lcAlias, llAlias;
, liTag

lcResult = ''

* Si la table peut être localisée
 	lcAlias = cAlias(m.tuTable, @m.llAlias)
 	llResult = Used(m.lcAlias)
 	ASSERT m.llResult MESSAGE cAssertMsg(Textmerge("Table can't be found: <<cL(m.tuTable)>>"))
 	IF m.llResult

	* Si un tag a été spécifié
	llResult = Vartype(m.tcTag) == 'C' AND NOT Empty(m.tcTag)
 	ASSERT m.llResult MESSAGE cAssertMsg(Textmerge("Invalid Tag specification: <<m.tcTag>>"))
 	IF m.llResult

 		liTag = Tagno(m.tcTag, '', m.lcAlias)
 		llResult = m.liTag > 0
	 	ASSERT m.llResult MESSAGE cAssertMsg(Textmerge("Tag <<m.tcTag>> introuvable dans la table <<cL(m.tuTable)>>"))
	 	IF m.llResult
	 	
	 		lcResult = Normalize(Sys(14, m.liTag, m.lcAlias))
	 	ENDIF
 	ENDIF
	IF m.llAlias
		USE IN (m.lcAlias)
	ENDIF
ENDIF

RETURN m.lcResult

* -----------------------------------------------------------------
PROCEDURE cTagExpr_Test && Teste cTagExpr

LOCAL loTest AS cTagExpr_Test OF abData.prg
loTest = CreateObject('cTagExpr_Test')
IF loTest.DataOpen()

	loTest.Test('CPROGADDR', 'CPROGADDR', 'abUnitTest')
	loTest.Test('UPPER(CCLASS)+UPPER(CNAME)', 'FULLNAME', 'abUnitTest')
ENDIF

RETURN loTest.Result()

	* ------------------------------
	DEFINE CLASS cTagExpr_Test AS abUnitTest OF abDev.prg

	PROCEDURE DataOpen
		LOCAL llResult, lcFile
		lcFile = Home() + 'tools\ab\abmodule.dbf'
		llResult = File(m.lcFile)
		ASSERT m.llResult MESSAGE cAssertMsg(Textmerge("Test File does not exist: <<cLitteral(DisplayPath(m.lcFile, 30))>>"))
		IF m.llResult
			USE (m.lcFile) AGAIN ALIAS abUnitTest
		ENDIF

		RETURN m.llResult

	ENDDEFINE

* ========================================
FUNCTION cTagType && Type d'index d'un tag d'une table (en anglais)
LPARAMETERS ;
	tcTag,; && Tag à rechercher
	tuTable && [Alias()] Alias ou adresse de la table

LOCAL lcAlias, llAlias, lnTag, laTagInfo[1], llResult, lcResult
lcResult = ''

* Si un tag a été spécifié
llResult = Vartype(m.tcTag) == 'C' AND NOT Empty(m.tcTag)
 	ASSERT m.llResult MESSAGE cAssertMsg(Textmerge("Invalid Tag specification: <<m.tcTag>>"))
 	IF m.llResult

	* Si la table peut être localisée
 	lcAlias = cAlias(m.tuTable, @m.llAlias)
 	llResult = Used(m.lcAlias)
 	ASSERT m.llResult MESSAGE cAssertMsg(Textmerge("Table can't be found: <<cL(m.tuTable)>>"))
 	IF m.llResult
 		tuTable = Dbf(m.lcAlias)

 		* Si la table a des indexes
 		llResult = aTagInfoEn(@m.laTagInfo, '', m.lcAlias) > 0 && Normalisé en anglais car cette saloperie de vfp9r*.dll traduit en Français
 		IF m.llResult
	 		tcTag = Upper(Alltrim(m.tcTag))
	 		lnTag = Ascan(laTagInfo, m.tcTag, 1, -1, 1, 2+4+8)
	 		llResult = m.lnTag > 0
 		ENDIF
	 	ASSERT m.llResult MESSAGE cAssertMsg(Textmerge("Tag <<m.tcTag>> introuvable dans la table <<cL(m.tuTable)>>"))
	 	IF m.llResult
	 	
	 		lcResult = laTagInfo[m.lnTag, 2]
	 	ENDIF
 	ENDIF
	IF m.llAlias
		USE IN (m.lcAlias)
	ENDIF
ENDIF

RETURN m.lcResult

* ========================================
FUNCTION cTagPC	&& Premier tag d'index candidat, ou d'index primaire d'une table
LPARAMETERS ;
	tuTable,; && [Alias()] Alias ou adresse de la table où l'existence du tag est à vérifier
	tcTagExp,; && @ [''] Expression de l'index trouvé
	tlTagCand,; && @ [.F.] Index candidat seulement ; @ Un index candidat a été trouvé
	tnTag,; && @ [0] N° du tag d'index trouvé
	tlTagPrim && [.F.] Index primaire seulement
tcTagExp = ''
tlTagCand = lTrue(m.tlTagCand)
tnTag = 0
tlTagPrim = lTrue(m.tlTagPrim)

 	LOCAL llTagPrim, lcAlias, llAlias;
 	, lnTag, liTag, lcTag;
 	, llResult, lcResult && Tag trouvé

lcResult = ''
llTagPrim = NOT m.tlTagCand && Index primaire accepté
tlTagCand = .F. && retour

 	lcAlias = cAlias(m.tuTable, @m.llAlias)
 	llResult = Used(m.lcAlias)
 	ASSERT m.llResult MESSAGE cAssertMsg(Textmerge("Table can't be found: <<cL(m.tuTable)>>"))
 	IF m.llResult

	llResult = .F.

 	* Si la table comporte des tags d'index
	lnTag = Tagcount(Cdx(1, m.lcAlias), m.lcAlias) && le CDX a le même nom que l'alias
	IF m.lnTag > 0

		* Si index candidat autorisé
		IF NOT m.tlTagPrim

			* Chercher le premier index candidat
			FOR liTag = 1 TO m.lnTag
			 	llResult = Candidate(m.liTag, m.lcAlias)
				IF m.llResult
					tlTagCand = .T.
					EXIT
				ENDIF
			ENDFOR
		ENDIF
		
		* Si aucun index candidat trouvé et index primaire accepté
		IF NOT m.llResult AND (m.llTagPrim OR m.tlTagPrim)

		 	* Chercher l'index primaire
			FOR liTag = 1 TO m.lnTag
			 	llResult = Primary(m.liTag, m.lcAlias)
				IF m.llResult
					EXIT
				ENDIF
			ENDFOR
		ENDIF

		* Si index trouvé, lire ses caractéristiques
		IF m.llResult
			lcResult = Tag(m.liTag, m.lcAlias)
			tcTagExp = Sys(14, m.liTag, m.lcAlias)
			tnTag = m.liTag
		ENDIF
	ENDIF
	
	* Si rien de trouvé et clé primaire acceptée, voir si c'est une vue définissant une clé primaire
	IF NOT m.llResult AND llTagPrim

		lcResult = CursorGetProp("KeyFieldList", m.lcAlias) && sans erreur sur une table
		llResult = NOT (Empty(m.lcResult) OR ',' $ m.lcResult)
		STORE Iif(m.llResult, m.lcResult, '') TO lcResult, tcTagExp
	ENDIF

	IF m.llAlias
		USE IN (m.lcAlias)
	ENDIF
ENDIF

RETURN m.lcResult

* ========================================
FUNCTION cTagP	&& Index primaire d'une table (tag, expression)
LPARAMETERS ;
	tuTable,; && [Alias()] Alias ou adresse de la table où l'existence du tag est à verifier
	tcTagExp,; && @ [''] Expression de l'index trouvé
	tnTag && @ [0] N° du tag d'index trouvé

RETURN cTagPC(m.tuTable, @m.tcTagExp, .F., @m.tnTag, .T.)

* ========================================
FUNCTION aTagsPC && Indexes candidats [et primaire] d'une table
LPARAMETERS ;
	taTagsPC,; && @ Indexes candidats [et primaire] : Tag | Expression | Filter Expression
	tuTable,; && [Alias()] Alias ou adresse de la table
	tlTagCand && [.F.] Indexes candidats seulement
EXTERNAL ARRAY taTagsPC
LOCAL lcAlias, llAlias, llResult, lnResult && nombre d'indexs trouvés
lnResult = 0

llResult = Type('taTagsPC', 1) == 'A'
 	ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([Tableau attendu en premier paramètre, <<cLitteral(m.taTagsPC)>> est incorrect]))
 	IF m.llResult
 		aClear(@m.taTagsPC)
	
	lcAlias = cAlias(m.tuTable, @m.llAlias)
 	ASSERT m.llResult MESSAGE cAssertMsg(Textmerge("Table can't be found: <<cL(m.tuTable)>>"))
 	IF m.llResult

	 	* Pour chaque tag d'index candidat [ou primaire]
	 	LOCAL lnTags, laTags[1], lnTag
	 	lnTags = aTagInfo(laTags, '', m.lcAlias) && Tagcount(m.lcAlias, m.lcAlias) Included for compatibility with dBASE
		IF m.lnTags > 0

			tlTagCand = Iif(Vartype(m.tlTagCand) == 'L', m.tlTagCand, .F.)
			FOR lnTag = 1 TO m.lnTags

				IF Candidate(m.lnTag, m.lcAlias);
				 OR (NOT m.tlTagCand AND Primary(m.lnTag, m.lcAlias))
				
					lnResult = m.lnResult + 1
					DIMENSION taTagsPC[m.lnResult, 3]
					taTagsPC[m.lnResult, 1] = laTags[m.lnTag, 1] && Tag
					taTagsPC[m.lnResult, 2] = laTags[m.lnTag, 3] && Expression
					taTagsPC[m.lnResult, 3] = laTags[m.lnTag, 4] && Filter Expression
				ENDIF
			ENDFOR
		ENDIF

		IF m.llAlias
			USE IN (m.lcAlias)
		ENDIF
 	ENDIF
 	ENDIF

RETURN m.lnResult

* ========================================
FUNCTION cSetKeyFilter && Expression de filtre sur Set("Key")
LPARAMETERS tcAlias && [Alias()]
tcAlias = Evl(m.tcAlias, Alias())

LOCAL loSelect AS abSelect OF abData.prg, lcKey1, lcKey2, lcExpr, llChar, lcResult
lcResult = ''

loSelect = NewObject('abSelect', 'abData.prg', '', m.tcAlias)
IF Vartype(m.loSelect) == 'O'
	
	IF NOT Empty(Order())

		lcKey1 = Set("Key", 1)
		lcKey2 = Set("Key", 2)
		IF NOT Empty(m.lcKey1 + m.lcKey2)
			
			* Déterminer le type de l'index
			lcExpr = cExprFieldsPrefixed(cTagExpr(Order()), m.tcAlias, m.tcAlias)
			llChar = Vartype(Evaluate(m.lcExpr)) == 'C'
			lcKey1 = Iif(m.llChar, '"' + m.lcKey1 + '"', m.lcKey1)
			lcKey2 = Iif(m.llChar, '"' + m.lcKey2 + '"', m.lcKey2)
			
			lcResult = Textmerge(Iif(m.lcKey1 == m.lcKey2;
			, [<<m.lcExpr>> = <<m.lcKey1>>]; && Filtre simple
			, [Between(<<m.lcExpr>>, <<m.lcKey1>>, <<m.lcKey2>>)]; && Filtre RANGE
			))
		ENDIF
	ENDIF
ENDIF

RETURN m.lcResult

* ========================================
FUNCTION KeySet && Rétablit Set("Key") dans un Alias
LPARAMETERS ;
	tcAlias,; && [Alias()]
	tcKey,; && Set("Key")
	tcResult && @ Résultat (cumulatif)
tcAlias = Evl(m.tcAlias, Alias())

LOCAL lnSelect, lnKey, lcKey1, lcKey2, llChar, lcKey, llResult

llResult = Used(m.tcAlias)
IF m.llResult

	IF NOT Empty(Order(m.tcAlias))
	 
	 	lnSelect = Select(0)
	 	SELECT (m.tcAlias)
		IF NOT Set("Key") == m.tcKey
			
			* Déterminer le type de l'index
			llChar = Vartype(Evaluate(cTagExpr(Order()))) == 'C'
			lnKey = Atc(',', m.tcKey)
			lcKey1 = Substr(m.tcKey, 1, m.lnKey-1)
			lcKey2 = Ltrim(Substr(m.tcKey, m.lnKey+1))
			lcKey1 = Iif(m.llChar, '"' + m.lcKey1 + '"', m.lcKey1)
			lcKey2 = Iif(m.llChar, '"' + m.lcKey2 + '"', m.lcKey2)
			lcKey  = Textmerge(Iif(m.lcKey1 == m.lcKey2;
				, m.lcKey1; && Filtre simple
				, [RANGE <<m.lcKey1>>, <<m.lcKey2>>]; && Filtre RANGE
				))

			SET KEY TO &lcKey
		ENDIF
	 	SELECT (m.lnSelect)
	ENDIF
ELSE
	cResultAdd(@m.tcResult, Textmerge(ICase(;
			cLangUser() = 'fr',	[l'alias '<<m.tcAlias>>' est introuvable],; && copy-paste this line to add another language support
													[Alias '<<m.tcAlias>>' can't be found]; && Default: English
	)))
ENDIF

RETURN m.llResult

* ========================================
FUNCTION cViewParmOp && Opérateur d'un paramètre d'une vue
LPARAMETERS tcSQL, tcParm

LOCAL loRegExp AS abRegExp OF abTxt.prg

loRegExp = CreateObject('abRegExp')
loRegExp.setup(Textmerge("\b\s*([^\s\r\n]+)\s*\(+\s*\?\s*\b<<m.tcParm>>\b"), .T., .F., .T.)

RETURN Iif(m.loRegExp.Execute(m.tcSQL) = 1, m.loRegExp.Matches[3].Item(1), .NULL.)

* -----------------------------------------------------------------
PROCEDURE cViewParmOp_Test

LOCAL loTest AS abUnitTest OF abDev.prg, lcSQL AS String

loTest = NewObject('abUnitTest', 'abDev.prg')

TEXT TO lcSQL NOSHOW FLAGS 1 PRETEXT 3
	SELECT Users.*;
	 FROM ;
	     ip!users;
	 WHERE  Users.userid = ( ?tuserid )	
ENDTEXT

loTest.Test('=', m.lcSQL, 'tUserID')

TEXT TO lcSQL NOSHOW FLAGS 1 PRETEXT 3
	SELECT Uploadshistory.uniqueid, Uploadshistory.invoice,;
	  Uploadshistory.company, Uploadshistory.division, Uploadshistory.code,;
	  Uploadshistory.acct_num, Uploadshistory.invdate,;
	  Uploadshistory.inv_amtdue, Uploadshistory.shipper,;
	  Uploadshistory.shpaddress, Uploadshistory.consignee,;
	  Uploadshistory.conaddress, Uploadshistory.refnum,;
	  Uploadshistory.glcode, Uploadshistory.dispute, Uploadshistory.approve,;
	  Uploadshistory.pay, Uploadshistory.paydate, Uploadshistory.payref,;
	  Uploadshistory.payamount, Uploadshistory.paynotes,;
	  Uploadshistory.payer_code, Uploadshistory.inv_no, Uploadshistory.dept,;
	  Uploadshistory.acct, Uploadshistory.suffix, Uploadshistory.ibgl,;
	  Uploadshistory.obgl, Uploadshistory.thirdgl, Uploadshistory.glc1,;
	  Uploadshistory.glc2, Uploadshistory.glc3, Uploadshistory.glc4,;
	  Uploadshistory.glc5, Uploadshistory.glc6, Uploadshistory.glc7,;
	  Uploadshistory.glc8, Uploadshistory.status, ;
	  Uploadshistory.statusdate, Uploadshistory.inv_status,;
	  Uploadshistory.paidnotes, Uploadshistory.glcodememo,;
	  Uploadshistory.inv_date+Uploadshistory.terms AS invduedate,;
	  cinvoicestatus(Uploadshistory.inv_status) AS inv_stat,;
	  SPACE(1) AS glcode_so, SPACE(1) AS invoice_so, SPACE(12) AS details,;
	  cpayer(Uploadshistory.payer_code) AS payer, Carriers.name AS carrier,;
	  NVL(Logoweb.logoweb,SPACE(50)) AS logo;
	 FROM ;
	     uploadshistory ;
	    INNER JOIN Carriers ;
	   ON  Carriers.code = Uploadshistory.code ;
	    LEFT OUTER JOIN logoweb ;
	   ON  Carriers.logo = Logoweb.logo;
	 WHERE  not Uploadshistory.excludepay;
	   AND  (  Uploadshistory.company = ( ?thiscompany );
	   AND  Uploadshistory.division LIKE ( ?thisdivision ) );
	 ORDER BY Uploadshistory.division, 44, Uploadshistory.inv_no
ENDTEXT

loTest.Test('LIKE', m.lcSQL, 'thisDivision')

RETURN loTest.Result()

* ========================================
FUNCTION lViewCAD && Un alias est une vue liée à un CursorAdapter
LPARAMETERS ;
	tcAlias,; && [alias courant] alias à analyser
	tlUpdateable,; && [.NULL.] updateable view ; .NULL.: don't care and feedback
	tiDS && [session de données courante] identifiant de la session de données

return lView(;
		tcAlias; && [alias courant] alias à analyser
	, Iif(Pcount() < 2, .null., m.tlUpdateable); && [.NULL.] updateable view ; .NULL.: don't care and feedback
	, tiDS; && [session de données courante] identifiant de la session de données
	, .T.; && [all] View should be linked to a CursorAdapter
	)

endfunc

* ========================================
FUNCTION lViewLocal && Un alias est une vue locale
LPARAMETERS ;
  tcAlias; && [alias courant] alias à analyser
, tlUpdateable; && @ [.NULL.] updateable view ; .NULL.: don't care and feedback
, tiDS; && [session de données courante] identifiant de la session de données
, tlCAD; && @ [.NULL.] View should be linked to a CursorAdapter ; .NULL.: don't care and feedback

tlUpdateable = Iif(Pcount() < 2 OR IsNull(m.tlUpdateable), .NULL., lTrue(m.tlUpdateable))
tlCAD = Iif(Pcount() < 4 OR IsNull(m.tlCAD), .NULL., lTrue(m.tlCAD))

return lView(;
	  m.tcAlias; && [alias courant] alias à analyser
	, @m.tlUpdateable; && [.NULL.] updateable view ; .NULL.: don't care and feedback
	, m.tiDS; && [session de données courante] identifiant de la session de données
	, @m.tlCAD; && [all] View should be linked to a CursorAdapter
	, .F.; && @ [.NULL.] View is remote
	)

endfunc

* ========================================
FUNCTION lViewRemote && Un alias est une vue distante
LPARAMETERS ;
  tcAlias; && [alias courant] alias à analyser
, tlUpdateable; && @ [.NULL.] updateable view ; .NULL.: don't care and feedback
, tiDS; && [session de données courante] identifiant de la session de données
, tlCAD; && @ [.NULL.] View should be linked to a CursorAdapter ; .NULL.: don't care and feedback

tlUpdateable = Iif(Pcount() < 2 OR IsNull(m.tlUpdateable), .NULL., lTrue(m.tlUpdateable))
tlCAD = Iif(Pcount() < 4 OR IsNull(m.tlCAD), .NULL., lTrue(m.tlCAD))

return lView(;
	  m.tcAlias; && [alias courant] alias à analyser
	, @m.tlUpdateable; && [.NULL.] updateable view ; .NULL.: don't care and feedback
	, m.tiDS; && [session de données courante] identifiant de la session de données
	, m.tlCAD; && [all] View should be linked to a CursorAdapter
	, .T.; && @ [.NULL.] View is remote
	)

endfunc

* ========================================
FUNCTION lView && Un alias est une vue
LPARAMETERS ;
  tcAlias; && [alias courant] alias à analyser
, tlUpdateable; && @ [.NULL.] updateable view ; .NULL.: don't care and feedback
, tiDS; && [session de données courante] identifiant de la session de données
, tlCAD; && @ [.NULL.] View should be linked to a CursorAdapter ; .NULL.: don't care and feedback
, tlRemote; && @ [.NULL.] View is remote ; .NULL.: don't care and feedback

tcAlias = Iif(Vartype(m.tcAlias) == 'C' AND NOT Empty(m.tcAlias), m.tcAlias, Alias())

tlUpdateable = Iif(Pcount() < 2 OR IsNull(m.tlUpdateable), .NULL., lTrue(m.tlUpdateable))
tlCAD = Iif(Pcount() < 4 OR IsNull(m.tlCAD), .NULL., lTrue(m.tlCAD))
tlRemote = Iif(Pcount() < 5 OR IsNull(m.tlRemote), .NULL., lTrue(m.tlRemote))

LOCAL llResult;
, liDS, llDS;
, llUpdateable;
, lnSourceType;
, lnSourceType_;
, llCAD;
, llRemote;

liDS = Set("Datasession")
llDS = Vartype(m.tiDS) == 'N';
	AND m.tiDS > 0;
	AND NOT m.liDS = m.tiDS
IF m.llDS
	SET DATASESSION TO m.tiDS
ENDIF

#if .F. && CursorGetProp("SourceType")

1 – The data source is a local SQL view.
101 (1 + 100) - Cursor is created by the CursorFill method.
201 (1 + 200) - Cursor is attached to a CursorAdapter object using the CursorAttach method.

2 – The data source is a remote SQL view.
102 (2 + 100) - Cursor is created by CursorFill.
202 (2 + 200) - Cursor is attached to a CursorAdapter object using CursorAttach.

3 – The data source is a table.
103 (3 + 100) - Cursor is created by CursorFill.
203 (3 + 200) - Cursor is attached to a CursorAdapter object using CursorAttach.

4 - The cursor is based on ADO Recordset and attached to a CursorAdapter object.
104 (4 + 100) - Cursor is created by CursorFill.
204 (4 + 200) - Cursor is attached to a CursorAdapter object using CursorAttach.

#endif

llResult = .T.;
 AND Used(m.tcAlias);
 AND varSet(@m.lnSourceType, CursorGetProp("SourceType", m.tcAlias));
 AND varSet(@m.lnSourceType_, m.lnSourceType%100);
 AND InList(m.lnSourceType_, 1, 2, 4); && 1 - local SQL view ; 2 - remote SQL view ; 3 – table ; 4 - ADO Recordset attached to a CursorAdapter object
 AND varSet(@m.llUpdateable, NOT Empty(CursorGetProp("KeyFieldList", m.tcAlias))); && IsReadonly(m.tcAlias)
 AND Iif(IsNull(m.tlUpdateable), varSet(@m.tlUpdateable, m.llUpdateable), m.tlUpdateable = m.llUpdateable);
 AND varSet(@m.llCAD, Int(m.lnSourceType / 100) > 0);
 AND Iif(IsNull(m.tlCAD), varSet(@m.tlCAD, m.llCAD), m.tlCAD = m.llCAD);
 AND varSet(@m.llRemote, m.lnSourceType_ = 2);
 AND Iif(IsNull(m.tlRemote), varSet(@m.tlRemote, m.llRemote), m.tlRemote = m.llRemote);
 AND .T.

if !m.llResult
	store .null. to tlUpdateable, tlCAD, tlRemote
endif
 
 if m.llDS
	set datasession to m.liDS
endif

return m.llResult

* ========================================
FUNCTION lViewU && Un alias est une vue updateable
LPARAMETERS ;
	tcAlias,; && [alias courant] alias à analyser
	tiDS && [session de données courante] identifiant de la session de données

RETURN lView(m.tcAlias, .T., m.tiDS)

* ========================================
FUNCTION aViews && Aliases des vues dans une session de données
LPARAMETERS ;
	taView,; && @ Aliases des vues locales dans la session de données
	tlUpdateable,; && [.NULL.] vue updateable ; .NULL. don't care
	tiDS && [session de données courante] identifiant de la session de données

EXTERNAL ARRAY taView
tlUpdateable = Iif(Pcount() < 2 OR IsNull(m.tlUpdateable), .NULL.,  lTrue(m.tlUpdateable))

LOCAL lnAlias, llResult, lnResult
lnResult = 0

llResult = Type('taView',1) == 'A'
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([tableau attendu en premier paramètre <<m.taView>>]))
IF m.llResult

	aClear(@m.taView)
	tiDS = Iif(Vartype(m.tiDS) == 'N' AND m.tiDS > 0, m.tiDS, Set("Datasession"))
	lnResult = aUsed(taView, m.tiDS)
	llResult = m.lnResult > 0
*		ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([Aucun alias trouvé dans la session de données <<m.tiDS>>]))
	IF m.llResult

		Asort(m.taView, 2) && sort on work areas
		aColDel(@m.taView, 2) && zones de travail inutiles
		DIMENSION taView[m.lnResult] && une seule dimension suffit
	
		FOR lnAlias = m.lnResult TO 1 STEP -1
		
			IF NOT lView(taView[m.lnAlias], m.tlUpdateable, m.tiDS)
				lnResult = m.lnResult - 1
				Adel(taView, m.lnAlias)
			ENDIF
		ENDFOR
		IF m.lnResult = 0
			aClear(@m.taView)
		ELSE
			DIMENSION taView[m.lnResult]
		ENDIF
	ENDIF
ENDIF

RETURN m.lnResult

* ========================================
FUNCTION aViewsU && Aliases des vues updateable dans une session de données
LPARAMETERS ;
	taView,; && @ Aliases des vues locales updateable dans la session de données
	tiDS && [session de données courante] identifiant de la session de données

RETURN aViews(@m.taView, .T., m.tiDS)

* ========================================
FUNCTION lCursor && Un alias est un curseur
LPARAMETERS ;
	tcAlias,; && [alias courant] alias à analyser
	tlReadWrite,; && [.NULL.] updateable cursor (READWRITE); .NULL.: don't care and feedback
	tiDS && [session de données courante] identifiant de la session de données

tcAlias = Iif(Vartype(m.tcAlias) == 'C' AND NOT Empty(m.tcAlias), m.tcAlias, Alias())
tlReadWrite = Iif(Pcount() < 2 OR IsNull(m.tlReadWrite), .NULL.,  lTrue(m.tlReadWrite))

LOCAL llResult;
, liDS, llDS;
, llAlias;
, llReadWrite;
, lnSourceType;
, lcDBF;

liDS = Set("Datasession")
llDS = Vartype(m.tiDS) == 'N';
	AND m.tiDS > 0;
	AND NOT m.liDS = m.tiDS
IF m.llDS
	SET DATASESSION TO m.tiDS
ENDIF

llAlias = Used(m.tcAlias)
llReadWrite = m.llAlias AND NOT IsReadonly(m.tcAlias)
lnSourceType = Iif(m.llAlias, CursorGetProp("SourceType", m.tcAlias)%100, 0)
lcDBF = Iif(m.llAlias, Dbf(m.tcAlias), '')

llResult = m.llAlias;
	AND;
	  (m.lnSourceType = 2; && remote SQL view
		 		AND Empty(CursorGetProp("SQL", m.tcAlias)); && NO SQL
 		OR;
	 		m.lnSourceType = 3; && Table
	 			AND (NOT File(m.lcDBF); && No table on disk
	 				OR Lower(JustExt(m.lcDBF)) == 'tmp'; && Spécial Win2k : apparemment CREATE CURSOR crée une table sur disque
	 				);
	 		);
	AND (IsNull(m.tlReadWrite) OR Iif(m.tlReadWrite, m.llReadWrite, NOT m.llReadWrite))

tlReadWrite = Iif(IsNull(m.tlReadWrite) AND m.llResult, m.llReadWrite, m.tlReadWrite) && FeedBack
 
IF m.llDS
	SET DATASESSION TO m.liDS
ENDIF

RETURN m.llResult

* -----------------------------------------------------------------
PROCEDURE lCursor_Test && Teste lCursor

LOCAL loTest AS lCursor_Test OF abData.prg

loTest = CreateObject('lCursor_Test')
IF loTest.DataOpen()

	loTest.Test(.F., 'junk')
	loTest.Test(.F., 'customer')
	loTest.Test(.F., 'invoice')
	loTest.Test(.T., 'innerj')
ENDIF

RETURN loTest.Result()

	* ------------------------------
	DEFINE CLASS lCursor_Test AS abUnitTest OF abDev.prg && AS session

	PROCEDURE DataOpen
		LOCAL lcDir
		lcDir = _Samples + 'data\'
		OPEN DATABASE (m.lcDir + 'testData')
		USE testData!customer IN 0
		USE testData!invoice IN 0 NODATA
		DO (m.lcDir + 'innerJ.qpr') && into cursor innerJ
	ENDDEFINE

* ========================================
FUNCTION cCursors && Aliases des curseurs dans une session de données
LPARAMETERS ;
	taCursor,; && @ Aliases des curseurs dans la session de données
	tlReadWrite,; && [.NULL.] curseur READWRITE ; .NULL. don't care
	tiDS && [session de données courante] identifiant de la session de données
tlReadWrite = Iif(Pcount() = 0 OR IsNull(m.tlReadWrite);
	, .NULL.;
	, lTrue(m.tlReadWrite);
	)

RETURN Iif(aCursors(@m.taCursor, m.tlReadWrite, m.tiDS, .T.) > 0;
	, cListOfArray(@m.taCursor);
	, '';
	)

* ========================================
FUNCTION aCursors && Aliases des curseurs dans une session de données
LPARAMETERS ;
	taCursor,; && @ Aliases des curseurs dans la session de données
	tlReadWrite,; && [.NULL.] curseur READWRITE ; .NULL. don't care
	tiDS,; && [session de données courante] identifiant de la session de données
	tlSort && [.T.] Trier les aliases par ordre alphabétique
EXTERNAL ARRAY taCursor
tlReadWrite = Iif(Pcount() < 2 OR IsNull(m.tlReadWrite);
	, .NULL.;
	, lTrue(m.tlReadWrite);
	)

LOCAL liAlias, llResult, lnResult
lnResult = 0

llResult = Type('taCursor', 1) == 'A'
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([tableau attendu en premier paramètre <<m.taCursor>>]))
IF m.llResult

	IF laEmpty(@m.taCursor)

		tiDS = Iif(Vartype(m.tiDS) == 'N' AND m.tiDS > 0, m.tiDS, Set("Datasession"))
		lnResult = aUsed(taCursor, m.tiDS)
		llResult = m.lnResult > 0
*		ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([Aucun alias trouvé dans la session de données <<m.tiDS>>]))
		IF m.llResult
			aColDel(@m.taCursor, 2) && zones de travail inutiles
			DIMENSION taCursor[m.lnResult] && une seule dimension suffit
		ENDIF
	ENDIF
	IF m.llResult
	
		FOR liAlias = m.lnResult TO 1 STEP -1
		
			IF NOT lCursor(taCursor[m.liAlias], m.tlReadWrite, m.tiDS)
				Adel(taCursor, m.liAlias)
				lnResult = m.lnResult - 1
			ENDIF
		ENDFOR
		IF m.lnResult = 0
			aClear(@m.taCursor)
		ELSE
			DIMENSION taCursor[m.lnResult]
			= lTrue(m.tlSort) AND Asort(taCursor) > 0
		ENDIF
	ENDIF
ENDIF

RETURN m.lnResult

* ========================================
FUNCTION lFieldPK	&& Un champ est la clé primaire d'une table
LPARAMETERS ;
	tcField,; && Champ
	tcTable && [Alias()] Table
LOCAL llResult

LOCAL lcAlias, llAlias
lcAlias = cAlias(m.tcTable, @m.llAlias)
llResult = Used(m.lcAlias)
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([Impossible d'ouvrir la table <<m.tcTable>>]))
IF m.llResult

	llResult = lField(m.tcField, m.lcAlias)
	ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([le champ <<m.tcField>> n'appartient pas à la table <<JustStem(CursorGetProp("SourceName", m.lcAlias))>>]))
	IF m.llResult
	
		* Trouver l'index primaire de la table
		LOCAL lcTag, lnTag, lcExpr
		lcTag = cTagPC(m.lcAlias, @m.lcExpr, , @m.lnTag, .T.)

		llResult = NOT Empty(m.lcTag);
		 AND Primary(m.lnTag, m.lcAlias);
		 AND Upper(m.lcExpr) == Upper(m.tcField)
	ENDIF
ENDIF

IF m.llAlias
	USE IN (m.lcAlias)
ENDIF

RETURN m.llResult

* ========================================
FUNCTION lField	&& Un champ existe dans une table
LPARAMETERS ;
	tcField, ; && Nom du champ dont l'existence est a verifier
	tuTable	 && [Alias()] Alias ou adresse de la table où l'existence du champ est à verifier
LOCAL lcAlias, llAlias, llResult

IF Vartype(m.tcField) == 'C'
	lcAlias = Iif(Empty(m.tuTable), Alias(), cAlias(m.tuTable, @m.llAlias)) && optimisation
	IF Used(m.lcAlias) && AND lVFPName(m.tcField)
		llResult = !Empty(Field(m.tcField, m.lcAlias))
		IF m.llAlias
			USE IN (m.lcAlias)
		ENDIF
	ENDIF
ENDIF

RETURN m.llResult

* ========================================
FUNCTION lFieldNull	&& Un champ existe dans l'alias courant ou spécifié et accepte les valeurs NULL
LPARAMETERS ;
	tcField, ; && Nom du champ dont l'existence est a verifier
	tuTable	 && [Alias()] Alias ou adresse de la table où l echamp est à verifier
LOCAL llResult

llResult = Vartype(m.tcField) == 'C' AND NOT Empty(m.tcField)
IF m.llResult

	LOCAL lcAlias, llAlias
	lcAlias = cAlias(m.tuTable, @m.llAlias)
	llResult = Used(m.lcAlias)
	ASSERT m.llResult MESSAGE cAssertMsg(Textmerge("Could not find table <<cLitteral(m.tuTable)>>"))
	IF m.llResult

		LOCAL ARRAY laFields[1]
		AFields(laFields, m.lcAlias)

		LOCAL lnField
		lnField = Ascan(m.laFields, Upper(Alltrim(m.tcField)), 1, -1, 1, 14)
		llResult = m.lnField > 0
		IF m.llResult

			llResult = laFields[m.lnField, 5]
		ENDIF
		IF m.llAlias
			USE IN (m.lcAlias)
		ENDIF
	ENDIF
ENDIF

RETURN m.llResult

* ========================================
FUNCTION lFields	&& Au moins des | tous les champs existent dans l'alias courant ou spécifié
LPARAMETERS ;
	tcFields, ; && Liste de champs dont l'existence est a verifier
	tuTable,; && [Alias()] Alias ou adresse de la table où l'existence du champ est à verifier
	tlOneAtLeast &&	[.F.] Au moins un des champs doit être présent ; si .F. et par référence, premier champ manquant en retour

LOCAL llResult;
, llOneAtLeast;
, lcAlias;
, llAlias;
, laFields[1];
, lcField;
, llField;
, llExit;

* Si une liste de champs est bien précisée
llResult = Vartype(m.tcFields)=='C' AND NOT Empty(m.tcFields)
IF m.llResult

	* Donner leur valeur par défaut aux paramètres optionnels
	llOneAtLeast = uDefault(m.tlOneAtLeast, .F.)
	lcAlias = cAlias(m.tuTable, @m.llAlias)
	llResult = Used(m.lcAlias)
	ASSERT m.llResult MESSAGE cAssertMsg(Textmerge("Could not find table <<cLitteral(m.tuTable)>>"))
	IF m.llResult

		* Tabuler les champs indiqués
		ALines(laFields, m.tcFields, .T., ',')

		* Pour chaque champ
		FOR EACH m.lcField IN laFields
			llField = Empty(m.lcField) OR lField(m.lcField, m.lcAlias)

			IF m.llOneAtLeast
				llResult = m.llField OR m.llResult && passe à vrai dès qu'un champ est trouvé
				llExit = m.llResult
			ELSE
				llResult = m.llField
				IF !m.llResult
					llExit = .T.
					tlOneAtLeast = m.lcField
				ENDIF
			ENDIF

			IF m.llExit
				EXIT
			ENDIF 
		ENDFOR
		
		* Refermer l'alias s'il a été ouvert
		IF m.llAlias
			USE IN (m.lcAlias)
		ENDIF
	ENDIF
ENDIF

RETURN m.llResult

* -----------------------------------------------------------------
PROCEDURE lFields_Test	&& Dit plusieurs champs existe dans l'alias courant ou spécifié

LOCAL loTest AS lFields_Test
loTest = CreateObject('lFields_Test')
loTest.DataOpen()

loTest.Test(.T., 'AAA')
loTest.Test(.F., 'DDD')
loTest.Test(.T., 'AAA,BBB')
loTest.Test(.T., 'AAA,  BBB')
loTest.Test(.T., 'AAA,DDD',, .T.)
loTest.Test(.F., 'AAA,DDD')
loTest.Test(.T., 'AAA,BBB', 'TMP', .F.)
loTest.Test(.F., 'AAA,DDD', 'TMP', .F.)
loTest.Test(.T., 'AAA,DDD', 'TMP', .T.)
loTest.Test(.F., 'EEE,DDD', 'TMP', .T.)

RETURN loTest.Result()

* -----------------------------------
DEFINE CLASS lFields_Test AS abUnitTest OF abDev.prg

PROCEDURE DataOpen
CREATE CURSOR TMP1 (AAA I, BBB D NULL, CCC N(2))
CREATE CURSOR TMP2 (AAA I, BBB D NOT NULL, CCC N(2))

ENDDEFINE && CLASS lFields_Test 

* ========================================
FUNCTION cFieldsNotIn && Champs d'une table ne se trouvant pas dans une autre (utile en cas d'APPEND FROM)
LPARAMETERS ;
  tcTableFrom; && Table dont les champs doivent se trouver dans l'autre
, tcTableIn; && Table cible où chercher les champs
, tcFieldsExclude; && ['WARNING'] Champs à ignorer dans la recherche

LOCAL lcResult as String; && vide = OK
, llResult;
, lcAliasFrom;
, lcAliasIn;
, llTableFrom;
, llTableIn;
, laFieldFrom[1], lnFieldFrom, liFieldFrom, lcFieldFrom;
, laFieldIn[1], lnFieldIn;
, laFieldExclude[1];

lcResult = .null.

* Si les deux tables peuvent être ouvertes
lcAliasFrom = cAlias(m.tcTableFrom, @m.llTableFrom,, @m.lcResult)
lcAliasIn = cAlias(m.tcTableIn, @m.llTableIn,, @m.lcResult)
llResult = Used(m.lcAliasFrom) and Used(m.lcAliasIn)
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge("Au moins une de ces tables est introuvable: <<cL(m.tcTableFrom)>>, <<cL(m.tcTableIn)>>"))
IF m.llResult
	
	* Si les champs de la table From peuvent être Tabulés
	lnFieldFrom = aFieldsShort(@m.lcResult, @m.laFieldFrom, Dbf(m.lcAliasFrom))
	llResult = m.lnFieldFrom > 0 && doit toujours être vrai
	IF m.llResult

		lnFieldIn = aFieldsShort(@m.lcResult, @m.laFieldIn, Dbf(m.lcAliasIn))
		lcResult = ''
		
		* Tabuler les champs à ignorer
		ALines(laFieldExclude, Upper(uDefault(m.tcFieldsExclude, 'WARNING')), 1+4, ',')
	
		* Pour chaque champ de la table From
		FOR liFieldFrom = 1 TO m.lnFieldFrom
			lcFieldFrom = laFieldFrom[m.liFieldFrom, 1]
			
			* Si le champ source est absent de la table cible et ne peut être ignoré, ajouter à la liste
			IF .T.;
			 AND Empty(Ascan(m.laFieldIn, m.lcFieldFrom, 1, -1, 1, 7)) ;
			 AND Empty(Ascan(laFieldExclude, m.lcFieldFrom, 1, -1, 1, 7))

				lcResult = c2Words(m.lcResult, ',', m.lcFieldFrom)
			ENDIF
		ENDFOR
	ENDIF
ENDIF

* Refermer les tables si elles ont été ouvertes
IF m.llTableFrom
	USE IN Select(m.lcAliasFrom)
ENDIF
IF m.llTableIn
	USE IN Select(m.lcAliasIn)
ENDIF

RETURN m.lcResult

* ========================================
FUNCTION aFieldsShort && noms de champs courts
lparameters ;
  result; && @ {fr} résultat (cumulatif)
, taField; && @ {fr} champs
, tcDBF;

external array taField

local lnResult as Integer;
, lcAlias;
, llAlias;
, lcFields;
, lcField;
, liField;

lnResult = 0

lcAlias = cAlias(m.tcDBF, @m.llAlias,, @m.result)
IF Used(m.lcAlias)

  lnResult = Fcount(m.lcAlias)
  DIMENSION taField[m.lnResult]
  FOR liField = 1 TO m.lnResult
  	lcField = Field(m.liField, m.lcAlias)
  	if Lenc(m.lcField) > 10
		  if Empty(m.lcFields)
		  	if IsExclusive(m.lcAlias)
		  		cResultAdd(@m.result, Textmerge([Can't get the short field name of '<<m.lcField>>' in '<<m.tcDBF>>' because it's used Exclusive]))
		  		lnResult = 0
		  		exit
		  	else
				  lcFields = Substr(Left(FileToStr(m.tcDBF), 10^4), 33) && 32*254 < 10^4
		  	endif
		  endif
		  lcField = Trim(Substr(m.lcFields, m.liField * 32 - 31, 10), Chr(0))
  	endif
    taField[m.liField] = m.lcField
  endfor
  if m.llAlias
  	use in (m.lcAlias)
  endif
endif

RETURN m.lnResult
endfunc

* ========================================
FUNCTION cFieldExp && Expression de champ pour instruction CREATE / ALTER TABLE SQL
LPARAMETERS ;
	tcField,; && Nom du champ ; si @ nom valide en retour
	tcType,; && Type de champ selon abréviations VFP C,N,L, etc.
	tuLen,; && Longueur du champ
	tuDec,; && Nombre de décimales en cas de champ numérique
	tuNull && [.F.] Valeurs null acceptées; si type # 'L', pas précisé (SET NULL agit)

LOCAL llResult, lcResult
lcResult = ''

llResult = Vartype(m.tcField) == 'C'
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([Nom de champ invalide : <<cLitteral(m.tcField)>>]))
IF m.llResult
	tcField = cVFPName(m.tcField, 10)
	
	llResult = Vartype(m.tcType) == 'C'
	IF m.llResult
		tcType = Upper(Alltrim(m.tcType))
		llResult = m.tcType $ VFP9_FIELD_TYPES
	ENDIF
	ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([Type de champ non supporté par VFP : <<cLitteral(m.tcType)>>]))
	IF m.llResult

		lcResult = c2Words(m.tcField, Space(1), m.tcType)

		IF NOT m.tcType $ VFP9_FIELD_TYPES_FIXED_LEN ;
		 AND Vartype(m.tuLen) $ 'CN'

			LOCAL lcLen, lcDec
			lcLen = Alltrim(Iif(Vartype(m.tuLen) = 'C', m.tuLen, Str(m.tuLen)))

			IF m.tcType $ VFP9_FIELD_TYPES_WITH_DEC ;
			 AND Vartype(m.tuDec) $ 'CN'
				lcDec = Alltrim(Iif(Vartype(m.tuDec) = 'C', m.tuDec, Str(m.tuDec)))
				lcDec = Iif(Val(m.lcDec) = 0, '', m.lcDec)
			ELSE
				lcDec = ''
			ENDIF
			lcResult = Textmerge([<<m.lcResult>>(<<m.lcLen>><<Iif(Empty(m.lcDec), '', ',' + m.lcDec)>>)])
		ENDIF
		
		IF Vartype(m.tuNull) == 'L'
			lcResult = Textmerge([<<m.lcResult>> <<Iif(m.tuNull, 'NULL', 'NOT NULL')>>])
		ENDIF
	ENDIF
ENDIF

RETURN m.lcResult

* -----------------------------------------------------------------
PROCEDURE cFieldExp_Test

LOCAL loTest
loTest = NewObject('abUnitTest', 'abDev.prg')
loTest.Test('TOTO_EST_U N(5,3)', 'toto est un idiot', 'N', 5, 3)
loTest.Test('TOTO C(5)', 'toto', 'C', 5, 3)

RETURN loTest.Result()

* ========================================
FUNCTION cFieldExpFrom && Expression de champ pour instruction CREATE / ALTER TABLE SQL selon un champ existant
LPARAMETERS ;
	tcField,; && Champ
	tcTable,; && Table
	tlNullIgnore,; && [.F.] Ignorer le réglage SET NULL du champ
	tlNameIgnore && [.F.] Ignorer le nom du champ

LOCAL lcAlias, llAlias, laField[1], lnField, llResult, lcResult

lcResult = ''
lcAlias = cAlias(m.tcTable, @m.llAlias)
llResult = Used(m.lcAlias)
IF m.llResult

	AFields(laField, m.lcAlias)
	lnField = Ascan(laField, Alltrim(m.tcField), 1, -1, 1, 15)
	llResult = m.lnField > 0
	ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([le champ <<m.tcField>> doit appartenir à la table <<m.tcTable>>]))
	IF m.llResult
	
		lcResult = cFieldExp(;
				  Iif(lTrue(m.tlNameIgnore), '', laField[m.lnField, AFIELDS_NAME]);
				, laField[m.lnField, AFIELDS_TYPE];
				, laField[m.lnField, AFIELDS_WIDTH];
				, laField[m.lnField, AFIELDS_PRECISION];
				, Iif(lTrue(m.tlNullIgnore), .NULL., laField[m.lnField, AFIELDS_NULL]);
				)
	ENDIF
ENDIF

IF m.llAlias
	USE IN (m.lcAlias)
ENDIF

RETURN m.lcResult

* -----------------------------------------------------------------
PROCEDURE cFieldExpFrom_Test && Teste cFieldExpFrom()

LOCAL loTest AS FieldExpFrom_Test OF abData.prg
loTest = CreateObject('FieldExpFrom_Test')
loTest.dataOpen()

loTest.Test('UNIQUEID C(10) NOT NULL', 'uniqueId', m.loTest.cAlias)
loTest.Test('TIMESTAMP T NOT NULL', 'timestamp', m.loTest.cAlias)
loTest.Test('USER M NOT NULL', 'user', m.loTest.cAlias)

RETURN loTest.Result()

	* ------------------------------
	DEFINE CLASS FieldExpFrom_Test AS abUnitTest OF abDev.prg
	cAlias = "FoxCodeTest"
	PROCEDURE DataOpen
		USE (_foxcode) IN 0 AGAIN ALIAS (m.this.cAlias)
	ENDDEFINE

* ========================================
FUNCTION cFieldsExpFrom && Expression de champs pour instruction CREATE / ALTER TABLE SQL d'après une table
LPARAMETERS ;
	tuTable,; && [Alias()] Alias ou Zone ou adresse de la table
	tlParenth,; && [.F.] Ajouter les parenthèses autour de l'expression
	tcSep,; && [','] Séparateur entre champs
	tlNullIgnore; && [.F.] Ignorer le réglage SET NULL du champ
	
local result as String;
, cAlias as String;
, lAlias as Boolean;
, laField[1];

result = ''

cAlias = cAlias(m.tuTable, @m.lAlias)
if Used(m.cAlias)

	AFields(laField, m.cAlias)
	result = cFieldsExp(@m.laField, m.tlParenth, m.tcSep, m.tlNullIgnore)
	
	if m.lAlias
		use in (m.cAlias)
	endif
endif

return m.result
endfunc

* ========================================
FUNCTION aFieldsType && Types des champs d'une table
LPARAMETERS ;
  aFieldsType; && @ Tableau en retour
, tuTable; && [Alias()] Alias ou Zone ou adresse de la table

local result as String;
, cAlias as String;
, lAlias as Boolean;

result = ''

cAlias = cAlias(m.tuTable, @m.lAlias)
if Used(m.cAlias)
	
	result = AFields(aFieldsType, m.cAlias)
	
	aColDel(@m.aFieldsType, 1)
	aColsDel(@m.aFieldsType, 2)
	
	dimension m.aFieldsType[m.result]
	
	if m.lAlias
		use in (m.cAlias)
	endif
endif

return m.result
endfunc

* ========================================
FUNCTION cFieldsExp && Expression de champs pour instruction CREATE / ALTER TABLE SQL
LPARAMETERS ;
	taFields,; && @ Définitions de champs selon aFields()
	tlParenth,; && [.F.] Ajouter les parenthèses autour de l'expression
	tcSep,; && [','] Séparateur entre champs
	tlNullIgnore; && [.F.] Ignorer le réglage SET NULL du champ

EXTERNAL ARRAY taFields

LOCAL lcResult as String;
, llResult as Boolean;
, lnCol as Integer;
, liField as Integer;
, lcFieldExp as String

lcResult = ''

llResult = Type('taFields', 1) == 'A'
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([Tableau attendu : <<cLitteral(@m.taFields)>>]))
IF m.llResult

	lnCol = Alen(taFields, 2)
	llResult = m.lnCol >= 4
	ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([Au moins 4 colonnes attendues dans le tableau : <<cLitteral(@m.taFields)>>]))
	IF m.llResult
		
		tcSep = Iif(Vartype(m.tcSep) == 'C' and Len(m.tcSep) > 0, m.tcSep, ',')
		tlNullIgnore = (lTrue(m.tlNullIgnore)) OR m.lnCol = 4
	
		* Pour chaque champ
		FOR liField = 1 TO Alen(taFields, 1)

			lcFieldExp = cFieldExp(;
					taFields[m.liField, 1];
				, taFields[m.liField, 2];
				, taFields[m.liField, 3];
				, taFields[m.liField, 4];
				, Iif(m.tlNullIgnore, 'ignore', taFields[m.liField, 5]);
				)
			IF Empty(m.lcFieldExp)
				llResult = .F.
				EXIT
			ELSE
				lcResult = m.lcResult + m.tcSep + m.lcFieldExp
			ENDIF
		ENDFOR
		lcResult = Substr(m.lcResult, Len(m.tcSep) + 1) && ôte le séparateur initial
	ENDIF
ENDIF

* Si OK, ajouter les parenthèses le cas échéant
RETURN Iif(m.llResult;
	, Iif(lTrue(m.tlParenth), '(' + m.lcResult + ')', m.lcResult);
	, '')

* ========================================
FUNCTION cFields && Champs d'une table répondant à un masque
LPARAMETERS ;
  tuTable; && [Alias()] Alias ou Zone ou adresse de la table
, tcSkeleton; && [All] Masque de nom des champs à lister
, tlExcept; && [.F.] Lister tous les champs SAUF ceux répondant au masque tcSkeleton
, tcDelim; && [','] Séparateur des champs
, tlSort; && [.F.] Trier les champs par ordre alphabétique
, tlLitterals; && [.F.] Lister les champs comme littérals

LOCAL lcResult as String;
, laField[1] as String;

lcResult = ''

IF aFieldsSkeleton(@m.laField, m.tuTable, m.tcSkeleton, m.tlExcept) > 0

	IF m.tlSort
		Asort(laField)
	ENDIF

	lcResult = cListOfArray(@m.laField, m.tcDelim,,m.tlLitterals)
ENDIF

RETURN m.lcResult

* -----------------------------------------------------------------
PROCEDURE cFields_Test

LOCAL loTest
loTest = CreateObject('cFieldsTest')

loTest.Test('UNIQUEID,USER', _foxcode, 'U*') && toutes sessions de données

loTest.DataOpen()
loTest.Test('UNIQUEID,USER', 'FoxCodeTest', 'U*') && dans session de données privée

RETURN loTest.Result()

	* ------------------------------
	DEFINE CLASS cFieldsTest AS abUnitTest OF abDev.prg

	PROCEDURE DataOpen
		USE (_foxcode) IN 0 AGAIN ALIAS FoxCodeTest

	ENDDEFINE

* ========================================
FUNCTION cFieldsMemvar && Champs d'une table répondant à un masque qui sont des variables mémoire
LPARAMETERS ;
	tuTable,; && [Alias()] Alias ou Zone ou adresse de la table
	tcSkeleton,; && [All] Masque de nom des champs à lister
	tlExcept && [.F.] Lister tous les champs SAUF ceux répondant au masque tcSkeleton

LOCAL lnFields, laField[1], lnField, lcField, lcResult
lcResult = ''

lnFields = aFieldsSkeleton(@m.laField, m.tuTable, m.tcSkeleton, m.tlExcept)
IF m.lnFields > 0

	FOR m.lnField = 1 TO m.lnFields
		lcField = laField[m.lnField]
		IF NOT Vartype(m.lcField) == 'U'
			lcResult = c2Words(m.lcResult, ',', m.lcField)
		ENDIF
	ENDFOR
ENDIF

RETURN m.lcResult

* ========================================
FUNCTION aFieldsSkeleton && Champs d'une table répondant à un masque
LPARAMETERS ;
	taFields,; && @ Champs trouvés (1 colonne)
	tuTable,; && [Alias()] Alias ou Zone ou adresse de la table
	tcSkeleton,; && [All] Masque de nom des champs à lister
	tlExcept,; && [.F.] Lister tous les champs SAUF ceux répondant au masque tcSkeleton
	tlColsKeep && [.F.] Garder les colonnes 2 et suivante ; si .F., ne garder que les noms des champs
EXTERNAL ARRAY taFields

LOCAL lcAlias, llAlias, lnSelect, llResult, lnResult && Nombre de champs trouvés
lnResult = 0

* Si la table communiquée est valide
lcAlias = cAlias(m.tuTable, @m.llAlias)
llResult = Used(m.lcAlias)
ASSERT m.llResult MESSAGE cAssertMsg('Invalid required parameter')
IF m.llResult

	* Donner leur valeur par défaut aux paramètres
	tcSkeleton = Evl(m.tcSkeleton, '')
	tlExcept = lTrue(m.tlExcept)
	tlColsKeep = lTrue(m.tlColsKeep)
	
	* Sélectionner l'alias
	lnSelect = Select(0)
	SELECT (m.lcAlias)

	* Si un squelette de champs a été précisé, filtrer sur ces champs
	IF NOT Empty(m.tcSkeleton)
		LOCAL lcSetField, lcSetFields
		tcSkeleton = 'ALL ' + Iif(m.tlExcept, 'EXCEPT ', 'LIKE ') + m.tcSkeleton
		lcSetField = Set('FIELDS')
		lcSetFields = Set('FIELDS', 1)
		SET FIELDS TO && nécessaire car SET FIELDS TO est additif
		SET FIELDS TO &tcSkeleton
	ENDIF
	
	lnResult = AFields(taFields)
	IF m.lnResult > 0 AND NOT m.tlColsKeep
		aColsDel(@m.taFields, 2)
	ENDIF

	* Si un squelette de champs a été précisé, rétablir le filtre de champs antérieur
	IF NOT Empty(m.tcSkeleton)
		SET FIELDS TO &lcSetFields
		SET FIELDS &lcSetField
	ENDIF

	IF m.llAlias
		USE IN (m.lcAlias)
	ENDIF
	SELECT (m.lnSelect)
ENDIF

RETURN m.lnResult

* ========================================
PROCEDURE RecInsert	&& Insère ou ajoute un enregistrement dans une table après l'enregistrement courant
&& Si succès, la table est positionnée sur le NOUVEL ENREGISTREMENT
LPARAMETERS ;
	tuTable, ;	&& [alias()] Alias ou zone de travail de la table où doit être ajouté l'enregistrement
	tlCarry		&& [.F.] Recopier l'enr. courant dans le nouveau (si .F., nouvel enregistrement vide)
LOCAL llResult && un enregistrement a été inséré

* ================================================================
* Date		Par	Action
* --------	---	-----------------------------------------------
* 26/06/01	TN		Création
* 26/09/02	TN		2nd partie INUTILE l'instruction INSERT fait la même chose !!!
* ================================================================

LOCAL lcAlias
lcAlias = cAlias(m.tuTable)
lcAlias = ExclusiveForce(m.lcAlias)
IF Used(m.lcAlias)

	local lnSelect, llBOF, lnNoEnrCour
	lnSelect = select (0)
	Select (m.lcAlias)
	llBOF = Bof()
	lnNoEnrCour = Iif(m.llBOF, 0, recNo ())

	* Si le carry a été demandé, mémoriser l'enregistrement courant
	LOCAL llCarry
	llCarry = uDefault(m.tlCarry, .F.)
	IF m.llCarry
		LOCAL ARRAY laEnrCour[1]
		SCATTER TO laEnrCour
	endIF

	* SI LA TABLE EST SUR LE DERNIER ENREGISTREMENT, AJOUTER UN ENREGISTREMENT À LA FIN
	IF m.lnNoEnrCour = recCount ()		&&	la table est sur le dernier enregistrement : nous n'avons qu'à ajouter un enr.
		if m.llCarry
			APPEND FROM ARRAY laEnrCour
		ELSE
			APPEND BLANK
		ENDIF

	* SINON INSÉRER UN ENREGISTREMENT APRÈS L'ENREGISTREMENT COURANT
	ELSE	&&	la table n'est pas sur le dernier enregistrement : nous devons insérer en passant par un curseur

		* Obtenir l'adresse complète de la table
		* Mémoriser la zone où la table est ouverte pour la rouvrir au même endroit
		local lcAdrTab, lnZoneTab, lcOrder
		lcAdrTab = cTableAddress()
		lnZoneTab = Select(0)		&& nécessaire pour le bon fonctionnement d'un éventuel scan sur la table
		lcOrder = order ()

		* Créer un curseur à l'image de la table source
		local lcNomCurs
		local array laStruTab[1]
		 = aFields (laStruTab)
		use in (m.lcAlias)
		lcNomCurs = 'RecInsert_' + upper (m.lcAlias)
		CREATE CURSOR (m.lcNomCurs) FROM ARRAY laStruTab

		* Remplir le curseur
		SELECT (m.lcNomCurs)
		* Copier la table source dans le Curseur jusqu'à la position mémorisée,
		APPEND FROM (m.lcAdrTab) for recNo () <= m.lnNoEnrCour
		* Ajouter la nouvelle ligne au Curseur
		IF m.llCarry
			APPEND FROM ARRAY laEnrCour
		ELSE
			APPEND BLANK
		ENDIF
		* Copier le reste de la table source dans le Curseur
		APPEND FROM (m.lcAdrTab) for recNo () > m.lnNoEnrCour

		* Mettre à jour et rouvrir la table source
		LOCAL lcRestSafety
		lcRestSafety = 'set safety ' + set ('safety')
		SET SAFETY OFF
		COPY TO (m.lcAdrTab)
		&lcRestSafety
		USE && Supprime le Curseur
		 * Rouvrir la table source dans la même zone que précédemment
		select (m.lnZoneTab)
		USE (m.lcAdrTab) EXCLUSIVE ALIAS (m.lcAlias) ORDER (m.lcOrder)

	endIF 	&&	&&	nous sommes sur le dernier enregistrement

	* Rétablir l'environnement des tables
	go m.lnNoEnrCour + 1	&&	se positionner sur le nouvel enregistrement
	select (m.lnSelect)
	llResult = .T.
ENDIF	&& isExclusive (lcAlias)

RETURN m.llResult

* ========================================
FUNCTION cFieldsCarIndexExp && Expression d'index composite en caractère sur une liste de champs de types quelconques
LPARAMETERS ;
	tcTable,; && [Alias()] Alias, zone ou adresse de la table
	tcIdxFields,;	&& Liste de champs
	tnLength && @ Longueur de la clé d'index composite en caractères

tnLength = 0

LOCAL lcResult;
, lcAlias, llAlias;
, lnSelect;
, lnIdxFields, laIdxFields[1];
, lnMax, lnExc

lcResult = ''

lcAlias = cAlias(m.tcTable, @m.llAlias)
IF Used(m.lcAlias)
	lnSelect = Select(0)
	SELECT (m.lcAlias)

	* Si les champs à indexer existent dans la table
	IF lFields(m.tcIdxFields)

		* Tabuler les champs à indexer
		lnIdxFields = ALines(laIdxFields, m.tcIdxFields, .T., ',')

		* Calculer l'index et sa longueur
		tnLength = aFieldsCarIndexExp(@m.laIdxFields)
		
		* Si l'index a une longueur supérieure au maximum
		lnMax = Iif(InList(Upper(Set('COLLATE')), 'MACHINE', 'UNIQWT'; && Unique Weight
			), 240, 120)
		lnExc = m.tnLength - m.lnMax
		IF m.lnExc > 0
			
			* Calculer la longueur totale des champs caractères réductibles
			LOCAL lnIdxField, lnIdx, lnIdxTot, lnIdxMin, lnIdxTop, lnIdxTopNo
			STORE 0 TO m.lnIdxTot, lnIdxMin, m.lnIdxTop
			FOR m.lnIdxField = 1 TO m.lnIdxFields
				IF laIdxFields[m.lnIdxField, 2] == 'C' ;
				 AND laIdxFields[m.lnIdxField, 3] > 10
					lnIdx = laIdxFields[m.lnIdxField, 3]
					lnIdxTot = m.lnIdxTot + m.lnIdx
					lnIdxMin = m.lnIdxMin + 10
					
					* Détecter le champ plus long
					IF m.lnIdx > m.lnIdxTop
						lnIdxTop = m.lnIdx
						lnIdxTopNo = m.lnIdxField
					ENDIF
				ENDIF
			ENDFOR

			* Si les expressions sur caractères réductibles peuvent absorber l'excédent
			IF m.lnIdxTot - m.lnIdxMin >= m.lnExc
				
				* Si le champ le plus long peut accepter toute la réduction, réduire lui seul
				IF m.lnIdxTop > 80 ;
				 AND m.lnExc < m.lnIdxTop / 2
					lnIdx = m.lnIdxTop - m.lnExc
					laIdxFields[m.lnIdxTopNo, 5] = m.lnIdx
					laIdxFields[m.lnIdxTopNo, 6] = ;
						'Left(' + laIdxFields[m.lnIdxTopNo, 1] + ',' + Transform(m.lnIdx) + ')'
					tnLength = m.tnLength - m.lnExc

				* Sinon, réduire proportionnellement chaque champ réductible
				ELSE
					LOCAL lnReduc
					lnReduc = (m.lnIdxTot - m.lnExc) / m.lnIdxTot
					FOR m.lnIdxField = 1 TO m.lnIdxFields
						IF laIdxFields[m.lnIdxField, 2] == 'C' ;
						 AND laIdxFields[m.lnIdxField, 3] > 10
							lnIdx = Int(laIdxFields[m.lnIdxField, 5] * m.lnReduc)
							tnLength = m.tnLength - laIdxFields[m.lnIdxField, 5] + m.lnIdx
							laIdxFields[m.lnIdxField, 5] = m.lnIdx
							laIdxFields[m.lnIdxField, 6] = ;
								'Upper(Left(' + laIdxFields[m.lnIdxField, 1] + ',' + Transform(m.lnIdx) + '))'
						ENDIF
					ENDFOR
				ENDIF

			ELSE
				tnLength = 0
			ENDIF
		ENDIF
	ENDIF
	IF m.llAlias
		USE
	ENDIF
	SELECT (m.lnSelect)
ENDIF

IF m.tnLength > 0
	lcResult = cListOfArray(@m.laIdxFields, '+', 6)
ENDIF

RETURN m.lcResult

* ========================================
FUNCTION aFieldsCarIndexExp && Expressions d'index caractère sur des champs de types quelconques
LPARAMETERS ;
	taIdxFields && @ Champs à indexer (6 colonnes)
LOCAL lnResult && Longueur de la clé composite caractères
lnResult = 0

EXTERNAL ARRAY taIdxFields

* S'assurer que le tableau a le nombre de colonnes nécessaire
LOCAL lnCols
lnCols = Alen(taIdxFields, 2)
IF m.lnCols < 6
	aColsIns(@m.taIdxFields, m.lnCols, 6 - m.lnCols)
ENDIF

* Tabuler les champs de la table
LOCAL ARRAY laFields[1]
AFields(laFields)

* Pour chaque champ à indexer
LOCAL lnIdxFields, lnIdxField, lcField, lnField, lcType, lnWidth, lnPrec, lcIndexExp, lnIndexExp
lnIdxFields = Alen(taIdxFields, 1)
FOR m.lnIdxField = 1 TO m.lnIdxFields
	lcField = taIdxFields[m.lnIdxField, 1]

	* Lire les caractéristiques du champ
	lnField = Ascan(laFields, m.lcField, 1, -1, 1, 1+2+4+8)
	lcType = laFields[m.lnField, 2]
	lnWidth = laFields[m.lnField, 3]
	lnPrec = laFields[m.lnField, 4]

	* Si l'expression d'indexation peut être construite
	lcIndexExp = cFieldCarIndexExp(m.lcField, m.lcType, m.lnWidth, m.lnPrec)
	IF NOT Empty(m.lcIndexExp)

		* Mémoriser l'expression et sa longueur dans le tableau
		taIdxFields[m.lnIdxField, 2] = m.lcType
		taIdxFields[m.lnIdxField, 3] = m.lnWidth
		taIdxFields[m.lnIdxField, 4] = m.lnPrec

		lnIndexExp = Len(Evaluate(m.lcIndexExp))
		taIdxFields[m.lnIdxField, 5] = m.lnIndexExp

		lcIndexExp = Iif(m.lcType == 'C', 'Upper(' + m.lcIndexExp + ')', m.lcIndexExp)
		taIdxFields[m.lnIdxField, 6] = m.lcIndexExp

		lnResult = m.lnResult + m.lnIndexExp

	* Sinon (type non supporté), sortir et terminer
	ELSE
		lnResult = 0
		EXIT
	ENDIF
ENDFOR

RETURN m.lnResult

* ========================================
FUNCTION cFieldCarIndexExp && Expression d'index en caractère sur un champ de type quelconque
LPARAMETERS ;
	tcField,;	&& Nom du champ
	tcType,; && Type de champ ($ 'CDTNFIYL')
	tnWidth,; && Longueur, partie entière si champ de type N ou F
	tnPrecision && partie décimale si champ de type N ou F
LOCAL lcResult

DO CASE
CASE m.tcType == 'C'
	lcResult = m.tcField
CASE m.tcType == 'D'
	lcResult = 'dtoc(' + m.tcField + ',1)'
CASE m.tcType == 'T'
	lcResult = 'ttoc(' + m.tcField + ',1)'
CASE m.tcType $ 'NF'
	lcResult = 'Str(' + m.tcField + ',' + Transform(m.tnWidth) + ',' + Transform(m.tnPrecision) + ')'
CASE m.tcType == 'I'
	lcResult = 'str(' + m.tcField + ',10)'
CASE m.tcType == 'Y'
	lcResult = 'str(MtoN(' + m.tcField + '),15,4)'
CASE m.tcType == 'L'
	lcResult = 'iif(' + m.tcField + ',"1","0")'
OTHERWISE && M, B ou G : indexation impossible
	lcResult = ''
ENDCASE

RETURN m.lcResult

* ========================================
PROCEDURE FreeTableSlim	&& Table libre : supprime les lignes vides et réduit la largeur des champs caractère au minimum
LPARAMETERS ;
	tuTable,;	&& Alias, zone ou adresse d'une table
	tnLenPercent && [0] Pourcentage de la longueur des champs caractères à ajouter en réserve

LOCAL lcAlias, llAlias, llExclusive, llResult

* Si la table peut être ouverte en exclusif
lcAlias = cAlias(m.tuTable, @m.llAlias, .T.)
llResult = Used(m.lcAlias)
IF m.llResult

	loSelect = abSelect(m.lcAlias)

	* Lire la structure de la table
	LOCAL laFields[1], lnFields, lnField, llMemo
	lnFields = AFields(laFields)
	llMemo = File(ForceExt(Dbf(m.lcAlias), 'FPT'))

	* Initialiser les longueurs mini des champs caractères
	FOR m.lnField = 1 to m.lnFields
		IF laFields[m.lnField, 2] == 'C' && seuls les champs caractères sont redimensionnables
			laFields[m.lnField, 16] = 1	&& Tables comments
		ENDIF
	ENDFOR

	* Pour chaque enregistrement
	LOCAL lnLenFact, luField, llRecEmpty, llPack
	lnLenFact = 1 + Iif(Vartype(m.tnLenPercent) == 'N' AND m.tnLenPercent > 0, m.tnLenPercent, 0) / 100
	SCAN

		* Pour chaque champ
		llRecEmpty = .T.
		FOR m.lnField = 1 to m.lnFields
			luField = Evaluate(laFields[m.lnField,1])
			llRecEmpty = m.llRecEmpty AND (Empty(m.luField) OR IsNull(m.luField))

			* Si champ caractère, mémoriser longueur max. du contenu
			IF laFields[m.lnField, 2] == 'C'
				laFields[m.lnField, 16] = Max(laFields[m.lnField, 16], Int(Len(Rtrim(m.luField)) * m.lnLenFact))
				IF laFields[m.lnField, 16] > 254
					laFields[m.lnField, AFIELDS_TYPE] = 'M'
					laFields[m.lnField, AFIELDS_WIDTH] = 4
					laFields[m.lnField, AFIELDS_PRECISION] = 0
					llMemo = .T.
				ENDIF
			ENDIF
		ENDFOR

		* Si tous les champs sont vides, marquer pour suppression
		IF m.llRecEmpty
			DELETE
			llPack = .T.
		ENDIF
	ENDSCAN
	
	IF m.llPack AND NOT lCursor() && AND Set('Deleted') == 'OFF'
		PACK
		DELETE FILE (ForceExt(cTableAddress(lcAlias), 'BAK'))
	ENDIF

	* Si la structure peut être allégée
	LOCAL llChangeStru
	FOR m.lnField = 1 to m.lnFields
		IF laFields[m.lnField, 2] == 'C'
			llChangeStru = m.llChangeStru OR laFields[m.lnField,16] < laFields[m.lnField,3]
			laFields[m.lnField,3] = laFields[m.lnField,16]
		ENDIF
	ENDFOR
	IF m.llChangeStru

		* Créer une nouvelle table
		LOCAL lcTableAddr, lnSelect, lcAliasNouv, lcTableNouvAddr, lcExclusive
		lcTableAddr = cTableAddress(m.lcAlias)
		lnSelect = Select(m.lcAlias)
		USE
		lcAliasNouv = Sys(2015)
		lcTableNouvAddr = Addbs(JustPath(m.lcTableAddr)) + ForceExt(m.lcAliasNouv, [dbf])
		CREATE TABLE (m.lcTableNouvAddr) FREE FROM ARRAY laFields
		APPEND FROM (m.lcTableAddr)
		USE
		DELETE FILE (m.lcTableAddr)
		RENAME (m.lcTableNouvAddr) TO (m.lcTableAddr)
		IF m.llMemo
			DELETE FILE (ForceExt(m.lcTableAddr, 'FPT'))
			RENAME (ForceExt(m.lcTableNouvAddr, 'FPT')) TO (ForceExt(m.lcTableAddr, 'FPT'))
		ENDIF
		lcExclusive = Iif(m.llExclusive, 'EXCLUSIVE', '')
		USE (m.lcTableAddr) IN m.lnSelect ALIAS (m.lcAlias) &lcExclusive
	ENDIF

	IF m.llAlias
		USE IN (m.lcAlias)
	ENDIF
ENDIF

RETURN m.llResult

* ========================================
PROCEDURE BlankLinesDel && Supprime les enregistrements vides d'une table
LPARAMETERS ;
	tuTable	&& Alias ou adresse d'une table
LOCAL llResult

* Si on peut accéder à la table indiquée
LOCAL lcAlias, llAlias
lcAlias = cAlias(m.tuTable, @m.llAlias)
llResult = Used(m.lcAlias)
ASSERT m.llResult MESSAGE "Impossible d'ouvrir la table indiquée : " + Transform(m.tuTable)
IF m.llResult
	LOCAL lnSelect
	lnSelect = Select(0)
	SELECT (m.lcAlias)

	* Pour chaque enregistrement
	LOCAL lnFields, lnField, llRecEmpty
	lnFields = Fcount()
	SCAN
		
		* Pour chaque champ
		llRecEmpty = .T.
		FOR m.lnField = 1 to m.lnFields
			IF NOT Empty(Evaluate(Field(m.lnField)))
				llRecEmpty = .F.
				EXIT
			ENDIF
		ENDFOR
		
		* Si tous les champs sont vides, supprimer l'enregistrement
		IF m.llRecEmpty
			DELETE
		ENDIF
	ENDSCAN

	* Si la table a été ouverte, refermer
	IF m.llAlias
		USE
	ENDIF
	SELECT (m.lnSelect)
ENDIF

RETURN llResult

* ========================================
PROCEDURE BlankColsDel && Supprime les colonnes vides d'une table
LPARAMETERS ;
	tuTable	&& Alias ou adresse d'une table
LOCAL llResult

* Si on peut accéder à la table indiquée
LOCAL lcAlias, llAlias
lcAlias = cAlias(m.tuTable, @m.llAlias)
llResult = Used(m.lcAlias)
ASSERT m.llResult MESSAGE "Impossible d'ouvrir la table indiquée : " + Transform(m.tuTable)
IF m.llResult
	LOCAL lnSelect
	lnSelect = Select(0)
	SELECT (m.lcAlias)

	* Tabuler les champs de la table
	LOCAL ARRAY laFields[1]
	LOCAL lnFields, lnField, lcField, luField
	lnFields = AFields(laFields)
	aColsDel(@m.laFields, 2)
	aColsIns(@m.laFields, 1, 3) && 1-nom, 2-valeur vide, 3-colonne vide
	
	* Initialiser la valeur vide de chaque champ
	GO BOTTOM
	SKIP && EOF()
	FOR m.lnField = 1 TO m.lnFields
		laFields[m.lnField, 2] = Evaluate(laFields[m.lnField,1])
		laFields[m.lnField, 3] = .T.
	ENDFOR
	
	* Pour chaque enregistrement et chaque champ
	SCAN
		FOR m.lnField = 1 TO m.lnFields
		
			* Basculer si non vide
			laFields[m.lnField, 3] = laFields[m.lnField, 3] ;
			 AND laFields[m.lnField, 2] == Evaluate(laFields[m.lnField,1])
		ENDFOR
	ENDSCAN

	* Si au moins une colonne est vide
	LOCAL lcAlter
	lcAlter = ''
	FOR m.lnField = 1 TO m.lnFields
		IF laFields[m.lnField, 3]
			lcAlter = c2Words(m.lcAlter, Space(1) ;
				, 'DROP COLUMN ' + laFields[m.lnField, 1])
		ENDIF
	ENDFOR
	IF NOT Empty(m.lcAlter)
		
		* Si la table peut être ouverte en exclusif
		lcAlias = ExclusiveForce(m.lcAlias)
		llResult = Used(m.lcAlias)
		IF m.llResult

			* Supprimer les colonnes vides
			ALTER TABLE (m.lcAlias) &lcAlter
		ENDIF
	ENDIF
	
	* Si la table a été ouverte, refermer
	IF m.llAlias
		USE
	ENDIF
	SELECT (m.lnSelect)
ENDIF

RETURN llResult

* ========================================
FUNCTION cTableCheckSum && Checksum du contenu d'une table
LPARAMETERS tuTable && [Alias()] Alias ou Zone ou adresse d'une table

LOCAL lcTableAddr, lcData, loSelect, lnRecno, lnResult, llResult, lcResult
lcResult = ''

* Si la table est définie
tuTable = Evl(m.tuTable, Alias())
llResult = NOT Empty(m.tuTable)
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([Spécification de table invalide : <<cLitteral(m.tuTable)>>]))
IF m.llResult

	* Si la table existe
	lcTableAddr = Iif(Used(m.tuTable), cTableAddress(m.tuTable), m.tuTable)
*		ASSERT m.llResult MESSAGE cAssertMsg(Textmerge('Table can't be found: <<cLitteral(m.lcTableAddr)>>'))
	IF File(m.lcTableAddr);
	 AND NOT IsExclusive(m.tuTable) && 'File access is denied' si la table ouverte en exclusif (curseur, vue, etc.)

		* Calculer le checksum des données seules
		lcData = FileMemo(m.lcTableAddr)
		lcResult = Sys(2007;
			, Substr(FileToStr(m.lcTableAddr), 5) + Iif(File(m.lcData), FileToStr(m.lcData), ''); && à partir du 5ème octet, devrait supporter plus de 16 MO
			, -1; && For CRC32 calculations, Visual FoxPro disregards nSeed
			, 1; && Calculate checksum value using CRC32 checksum algorithm.
			)

	ELSE && curseur ou table ouverte en exclusif

		loSelect = abSelect(m.tuTable)

		IF InList(CursorGetProp("Buffering"), 2, 3) && tampon d'enregistrement, impossible de parcourir la table ... 
			Rand(-1)
			lcResult = Transform(Int(Rand()*10E10)) && ... toujours dire que son contenu a changé
		ELSE
			lnRecno = Recno_()
			lnResult = 0
			SCAN
				lnResult = m.lnResult + Int(Val(Sys(2017, '', -1, 3))) && 3 : Calculate checksum based on current record contents including Memo fields using CRC32
*				lcResult = m.lcResult + Sys(2017, '', -1, 3)
			ENDSCAN
			RecnoSet(m.lnRecno)
			lcResult = Transform(m.lnResult)
		ENDIF
	ENDIF
ENDIF

RETURN m.lcResult

* ========================================
PROCEDURE TableStruCheck && Vérifie la structure d'une table, l'ajuste si nécessaire
LPARAMETERS ;
	tcTable,; && Alias ou adresse de la table
	tcFieldsExp && Expression de description de structure comme dans une commande CREATE TABLE

LOCAL lcAlias, llAlias, laFields[1], lcFieldsExp, lcFieldExp;
	, lcAlter, llResult, lcResult && Alias de la table vérifiée (vide si ajustement impossible)

lcResult = ''

* Si la table est accessible
lcAlias = cAlias(m.tcTable, @m.llAlias)
llResult = Used(m.lcAlias)
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([Alias invalide : <<cLitteral(m.tcTable)>>]))
IF m.llResult
	
	* Si l'Expression de description de structure est valide
	llResult = lFieldsExp(m.tcFieldsExp)
	ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([Spécifications de champs invalide : <<cLitteral(m.tcFieldsExp)>>]))
	IF m.llResult

		lcResult = m.lcAlias
	
		* Si la structure est différente de celle spécifiée
		AFields(laFields, m.lcResult)
		lcFieldsExp = cFieldsExp(@m.laFields)
		llResult = cComparable(m.lcFieldsExp) == cComparable(m.tcFieldsExp)
		IF NOT m.llResult
			
			* Si la table peut être ouverte en exclusif
			lcResult = ExclusiveForce(m.lcResult)
			llResult = Used(m.lcResult)
			ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([Impossible d'ouvrir la table en exclusif : <<cLitteral(cTableAddress(m.lcResult))>>]))
			IF m.llResult

				* Ajuster la structure selon la spec.
				aFieldsExp(@m.laFields, m.tcFieldsExp)
				lcAlter = ''
				FOR EACH m.lcFieldExp IN laFields
					lcAlter = m.lcAlter + ' ALTER COLUMN ' + m.lcFieldExp
				ENDFOR
				ALTER TABLE (m.lcResult)&lcAlter
			ENDIF
		ENDIF
	ENDIF

	IF m.llAlias
		USE IN (m.lcAlias)
	ENDIF
ENDIF

RETURN m.lcResult

* ========================================
PROCEDURE TableFreeCreateOrAdjust && Crée ou ouvre (et ajuste) une table libre selon une spécification de champs et d'indexes
LPARAMETERS ;
	tcTable,; && [cursor] Alias ou adresse de table, vide pour création d'un curseur
	tcAlias,; && @ [JustStem(m.tcTable)||Sys(2015)] Alias de la table, sinon du curseur
	tuFields,; && @array||String Spécification de champs selon aFields(), aLines() ou CREATE/ALTER TABLE
	tuTagInfo,; && @ Spécification d'indexes au format aTagInfo(), tabulées ou délimitées par ';' ou \t -  [Tag, Type, Key, Filter, Order, Collation]
	tlCreated,; && @ [idem] La table a été créée
	tlAdjusted,; && @ [idem] La structure de la table et/ou ses indexes ont été ajustés
	tcResult && @ [''] Résultat
tcResult = ''

LOCAL llResult as Boolean;
, laFields[1],	laTagInfo[1];
, lcAlias, llAlias, llCursor, lcTable, loSelect AS abSelect, loSafety AS abSet, llExclusive;
, lcFields, llFields;
, laTag[1], lnTags, llTags, liTag, llZap, lcTag;

* Tabuler les spécifications de champs et d'indexes
llResult = aFields_(@m.laFields, m.tuFields) > 0
IF m.llResult
	aTagInfo_(@m.laTagInfo, m.tuTagInfo)

	* Ouvrir la table si elle existe
	llCursor = Empty(m.tcTable)
	IF NOT m.llCursor
		lcAlias = cAlias(m.tcTable)
		llAlias = Used(m.lcAlias)
		llCursor = NOT (m.llAlias OR lFileAddress(m.tcTable))
	ENDIF

	loSelect = abSelect(Iif(m.llAlias, m.lcAlias, 0))
	loSafety = abSet('SAFETY', 'OFF')

	* Lire les consignes de champs et d'indexes
	lcFields = TableFreeCreateOrAdjust_cFields(@m.laFields, m.lcAlias)
	llFields = NOT Empty(m.lcFields)
	lnTags = TableFreeCreateOrAdjust_aTags(@m.laTag, @m.laTagInfo, m.lcAlias, @m.llZap)
	llTags = m.lnTags > 0

	* Si la table existe déjà
	IF m.llAlias

		IF m.llFields OR m.llTags
		
			lcAlias = ExclusiveForce(m.lcAlias, @m.llExclusive)
			llResult = Used(m.lcAlias)
			ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([Impossible d'accéder à la table '<<m.tcTable>>' en mode exclusif]))
		ENDIF
		IF m.llResult
			
			* Si la structure doit changer && /!\ supporter ALTER COLUMN ... NULL
			IF m.llFields

				* Supprimer les tags avant de supprimer les champs qui pourraient y être impliqués
				IF m.llTags
					FOR liTag = 1 TO m.lnTags && EACH lcTag IN laTag
						lcTag = laTag[m.liTag]
						IF Upper(Left(m.lcTag, Len('DELE'))) == 'DELE' && DELETE TAG ...
							&lcTag
							Adel(laTag, m.liTag)
						ENDIF
					NEXT
				ENDIF

				wWAIT(;
					Textmerge(ICase(;
						cLangUser() = 'fr',	[Restructuration de la table '<<m.lcAlias>>' en cours (<<cTronc(m.lcFields)>>) NE PAS INTERROMPRE !],; && copy-paste this line to add another language support
																[Modifying structure of table '<<m.lcAlias>>' (<<cTronc(m.lcFields)>>) DO NOT INTERRUPT!]; && Default: English
					));
				, 'WINDOW NOWAIT NOCLEAR')

				ALTER TABLE (m.lcAlias) &lcFields
				wWAIT(, [CLEAR])
				lcTable = cTableAddress(m.lcAlias)
				ERASE (ForceExt(m.lcTable, 'bak'))
				ERASE (ForceExt(m.lcTable, 'tbk'))
				tlAdjusted = .T.
			ENDIF

			SELECT (m.lcAlias) && abSelect(...) plus haut
		ELSE
			tcResult = Textmerge(ICase(;
				cLangUser() = 'fr', [Impossible d'accéder à la table '<<m.tcTable>>' en mode exclusif],; && copy-paste this line to add another language support
														[Could not have an exclusive access to table '<<m.tcTable>>'])) && Default: English
		ENDIF

	* Sinon (table à créer)
	ELSE

		IF m.llCursor
			tcAlias = Evl(m.tcTable, m.tcAlias)
			tcAlias = Iif(Vartype(m.tcAlias) == 'C' AND NOT Empty(m.tcAlias), cVFPName(m.tcAlias), Sys(2015))
			CREATE CURSOR (m.tcAlias) FROM ARRAY laFields
		ELSE
			CREATE TABLE (m.tcTable) FREE FROM ARRAY laFields && Tables in Visual FoxPro are tagged with the code page that was in use when the table was created
		ENDIF
		lcAlias = Alias()
		tlCreated = .T.
	ENDIF
	
	IF m.llResult AND m.llTags
	
		ASSERT NOT m.llZap MESSAGE cAssertMsg(Textmerge([<<Proper(Program())>> va zapper '<<m.lcAlias>>'...<<CRLF>>Presser 'Cancel' pour arrêter le programme<<CRLF>>Presser 'Ignore' pour continuer]))
		IF m.llZap
			ZAP && SELECT plus haut ou CREATE TABLE a sélectionné la table
		ENDIF

		* Créer ou ajuster les indexes
		FOR EACH lcTag IN laTag
			IF Vartype(m.lcTag) == 'C' && a pu être supprimé ci-dessus
				IF m.llAlias
					wWAIT(Textmerge(ICase(;
						cLangUser() = 'fr', [Indexation de la table '<<m.lcAlias>>' en cours (<<cTronc(m.lcTag)>>) NE PAS INTERROMPRE !],; && copy-paste this line to add another language support
																[Indexing table '<<m.lcAlias>>' (<<cTronc(m.lcTag)>>) DO NOT INTERRUPT!])); && Default: English
					, 'WINDOW NOWAIT NOCLEAR')
				ENDIF
				&lcTag
				IF m.llAlias
					wWAIT(, [CLEAR])
				ENDIF
			ENDIF
		ENDFOR
		SET ORDER TO

		REINDEX && ajouté le 27/9 pour éviter un CDX bloat inexpliqué
	ENDIF
	
	* Rouvrir la table selon le Set("Exclusive") courant
	IF m.llResult AND NOT m.llCursor AND NOT m.llExclusive
		tcAlias = Evl(m.tcAlias, m.lcAlias)
		llResult = AliasReuse(m.lcAlias,,, m.tcAlias) && rouvre sous m.lcAlias si Empty(m.tcAlias)
	ENDIF
ELSE
	tcResult = Textmerge(ICase(;
		cLangUser() = 'fr', [<<m.tuFields>> est une spécification de champs invalide pour la table '<<m.tcTable>>'],; && copy-paste this line to add another language support
												[<<m.tuFields>> is an invalid field specification for table '<<m.tcTable>>']; && Default: English
		))
ENDIF

RETURN m.llResult

* ========================================
FUNCTION cIndexCmd && Commande d'indexation d'après les colonnes d'aTagInfo() [Tag, Type, Key, Filter, Order, Collation]
LPARAMETERS ;
	lcTag,; &&	1 Index tag name in a .cdx file or index file name for .idx files
	lcType,; &&	2 Index tag type 
	lcKey,; &&	3 Index key expression
	lcFilter,; &&	4 Filter expression
	lcOrder,; &&	5 Index order as created (Ascending or Descending)
	lcCollate &&	6 Collate sequence

&& When using binary indexes, you cannot use the FOR clause to specify a filter expression or the ASCENDING, DESCENDING, UNIQUE, or CANDIDATE keywords

lcType = Iif(m.lcType == 'REGULAR', '', m.lcType)
lcFilter = Iif(m.lcType == 'BINARY' or Empty(m.lcFilter), '', ' FOR ' + m.lcFilter)
lcOrder = Iif(m.lcType == 'BINARY' or m.lcOrder == 'ASCENDING', '', ' DESCENDING') && ASCENDING par défaut
lcCollate = nEvl(m.lcCollate, Textmerge([ COLLATE '<<m.lcCollate>>']))

RETURN Textmerge([INDEX ON <<m.lcKey>> TAG <<m.lcTag>> <<m.lcType>><<m.lcFilter>><<m.lcOrder>><<m.lcCollate>>])

* ========================================
PROCEDURE TableFreeCreateOrAdjust_aTags && Instructions d'indexation
LPARAMETERS ;
	taResult,; && @ Instructions d'indexation
	taTagInfo,; && @ Spécifications d'index selon aTagInfo() [Tag, Type, Key, Filter, Order, Collation]
	tcAlias,; && Alias, vide si création de la table
	tlZap && @ [.F.] Un index candidat doit être créé
EXTERNAL ARRAY taResult, taTagInfo
tlZap = .F.

LOCAL lcSetCollate;
, tlAlias, tlTagInfo, tnTag;
, llTagInfo, laTagInfo[1], lnTag;
, llTag, lcTag, lcType, lcKey, lcFilter, lcOrder, lcCollate;
, lcSelect;
, lnResult

lnResult = 0
lcSetCollate = Set("Collate")

tlAlias = Used(m.tcAlias)
llTagInfo = m.tlAlias AND aTagInfoEn(@m.laTagInfo, '', m.tcAlias) > 0 && Normalisé en anglais car ces saloperies de vfp9r*.dll localisent en * (ex. fra > français)
tlTagInfo = NOT laEmpty(@m.taTagInfo)
IF m.tlTagInfo
	
	* Pour chaque tag d'index spécifié
	FOR tnTag = 1 TO Alen(taTagInfo, 1)
		
		lcTag 		= taTagInfo[m.tnTag, 1]
		lcType 		= taTagInfo[m.tnTag, 2]
		lcKey 		= taTagInfo[m.tnTag, 3]
		lcFilter 	= taTagInfo[m.tnTag, 4]
		lcOrder 	= taTagInfo[m.tnTag, 5]
		lcCollate	= taTagInfo[m.tnTag, 6]

		* Créer l'index s'il n'existe pas dans la table ou avec des caractéristiques différentes
		llTag = NOT m.llTagInfo
		IF NOT m.llTag

			lnTag = Ascan(laTagInfo, m.lcTag, 1, -1, 1, 15)
			llTag = Empty(m.lnTag) OR NOT (.T.;
								AND	laTagInfo[m.lnTag, 2] == m.lcType;
								AND	laTagInfo[m.lnTag, 3] == m.lcKey;
								AND	laTagInfo[m.lnTag, 4] == m.lcFilter;
								AND	laTagInfo[m.lnTag, 5] == m.lcOrder;
								AND	laTagInfo[m.lnTag, 6] == m.lcCollate;
								)
		ENDIF
		
		* Si l'index doit être créé ou modifié
		IF m.llTag

#if .F.
create cursor Test(test L)
index on test tag test binary
? ATagInfo(aa) && collation = 'machine'
set collate to "GENERAL"
index on test tag test binary
? ATagInfo(aa) && collation = 'machine'
index on test tag test binary collate 'general' && invalid collation sequence
#endif

			lcType = Iif(m.lcType == 'REGULAR', '', m.lcType)
			lcCollate = Iif(m.lcType == 'BINARY', 'MACHINE' , m.lcCollate)
			
			* Si un index candidat doit être créé
			IF m.tlAlias;
			 AND NOT m.tlZap;
			 AND InList(m.lcType, 'CANDIDATE', 'PRIMARY')

				tlZap = NOT lTableExpr(m.lcKey, m.tcAlias)
				IF NOT m.tlZap

					* Vérifier l'absence de doublon
					lcSelect = Iif(Empty(m.lcFilter), '', ' WHERE ' + m.lcFilter)
					tlZap = VFPSelectExecute(Textmerge([SELECT <<m.lcKey>> AS CAND, Count(*) AS _COUNT FROM <<m.tcAlias>> <<m.lcSelect>> GROUP BY CAND HAVING _COUNT > 1])) > 0
					USE && Cursor créé par VFPSelectExecute()
				ENDIF
			ENDIF

			lnResult = m.lnResult + 1
			DIMENSION taResult[m.lnResult]
			taResult[m.lnResult] = cIndexCmd(m.lcTag, m.lcType, m.lcKey, m.lcFilter, m.lcOrder, m.lcCollate)
		ENDIF
	ENDFOR
ENDIF

* Pour chaque tag existant
IF m.llTagInfo
	FOR lnTag = 1 TO Alen(laTagInfo, 1)
		lcTag = laTagInfo[m.lnTag, 1]
	
		* Si le tag n'est pas spécifié, supprimer
		IF NOT m.tlTagInfo OR Ascan(taTagInfo, m.lcTag, 1, -1, 1, 15) = 0

			lnResult = m.lnResult + 1
			DIMENSION taResult[m.lnResult]
			taResult[m.lnResult] = Textmerge([DELETE TAG <<m.lcTag>>])
		ENDIF
	ENDFOR
ENDIF

RETURN m.lnResult

* ========================================
PROCEDURE TableFreeCreateOrAdjust_cFields && Expression de champs
LPARAMETERS ;
	taFieldSpec,; && @ Spécification de champs selon format aFields()
	tcAlias && Alias, vide si création de la table
EXTERNAL ARRAY taFieldSpec

LOCAL lcResult;
, laField[1], lnField, lnFieldSpec, lcField, lcFieldExp

lcResult = ''

* Si la table cible existe
IF Used(m.tcAlias)
	AFields(laField, m.tcAlias)
	
	* Pour chaque champ spécifié
	FOR lnFieldSpec = 1 TO Alen(taFieldSpec, 1)

		lcField = taFieldSpec[m.lnFieldSpec, 1]

		lcFieldExp = cFieldExp(;
			  taFieldSpec[m.lnFieldSpec, 1]; && Name
			, taFieldSpec[m.lnFieldSpec, 2]; && Type
			, taFieldSpec[m.lnFieldSpec, 3]; && Length
			, taFieldSpec[m.lnFieldSpec, 4]; && Decimals
			, taFieldSpec[m.lnFieldSpec, 5]; && NULL
			)
		
		* Si le champ existe dans le table
		lnField = Ascan(laField, m.lcField, 1, -1, 1, 15) && 1+2+4+8
		IF m.lnField > 0
		
			* Si la définition est différente de la spec.
			IF NOT (.T.;
				AND	taFieldSpec[m.lnFieldSpec, 2] == laField[m.lnField, 2]; && Type
				AND	taFieldSpec[m.lnFieldSpec, 3] == laField[m.lnField, 3]; && Length
				AND	taFieldSpec[m.lnFieldSpec, 4] == laField[m.lnField, 4]; && Decimals
				AND	taFieldSpec[m.lnFieldSpec, 5] == laField[m.lnField, 5]; && NULL
				)

				lcResult = Textmerge("<<m.lcResult>> ALTER COLUMN <<m.lcFieldExp>>")
			ENDIF

		* Sinon (le champ n'existe pas dans le table)
		ELSE
			
			* Ajouter l'expression de création de champ
			lcResult = Textmerge("<<m.lcResult>> ADD COLUMN <<m.lcFieldExp>>")
		ENDIF
	ENDFOR
	
	* Pour chaque champ de la table
	FOR lnField = 1 TO Alen(laField, 1)
		lcField = laField[m.lnField, 1]
		
		* Si le champ n'est pas spécifié
		lnFieldSpec = Ascan(taFieldSpec, m.lcField, 1, -1, 1, 15) && 1+2+4+8
		IF m.lnFieldSpec = 0

			* Supprimer
			lcResult = Textmerge("<<m.lcResult>> DROP COLUMN <<m.lcField>>")
		ENDIF
	NEXT

* Sinon (table cible à créer)
ELSE

	lcResult = cFieldsExp(@m.taFieldSpec, .T.)
ENDIF

RETURN m.lcResult

* ========================================
PROCEDURE aFields_ && aFields() d'après un tableau ou une liste ou selon syntaxe CREATE TABLE
LPARAMETERS ;
	taResult,; && @ Résultat selon aFields()
	tuFields && @A|C Spécification de champs dans l'ordre de aFields(), tabulé ou délimité par ';|\t', ou selon syntaxe CREATE TABLE
EXTERNAL ARRAY taResult, tuFields

LOCAL lnCols, lnRow, lnResult && Nombre de champs

#DEFINE aFIELDS_VARTYPES  Replicate('C',2) + Replicate('I',2) + Replicate('L',2) + Replicate('C',10) + Replicate('I',2) && 18 colonnes
#DEFINE aFIELDS_SEPS [,;|]+TABUL

IF aClear(@m.taResult)

	lnResult = 0
	
	DO CASE

	CASE Type('tuFields', 1) == 'A'

		lnResult = Alen(tuFields, 2)

		lnResult = ICase(;
			m.lnResult = 1,;
				aColsDelim(tuFields, aFIELDS_SEPS, aFIELDS_VARTYPES),;
			Between(m.lnResult, 4, 18),;
				m.lnResult,; && AFields() format assumed
				0;
			)

	CASE Vartype(m.tuFields) == 'C'
	
		tuFields = cCommentStripped(cInLineCommentStripped(m.tuFields))
		lnResult = Iif(CRLF $ m.tuFields;
			, aLinesCols(@m.taResult, m.tuFields, aFIELDS_SEPS, aFIELDS_VARTYPES); && TEXT TO tuFields ... ENDTEXT
			, aFieldsDef(@m.taResult, m.tuFields);
			)

	ENDCASE
	
	ASSERT m.lnResult > 0 MESSAGE cAssertMsg(Textmerge([Spécification de champ invalide <<cLitteral(m.tuFields)>>]))
	IF m.lnResult > 0

		* Compléter au format aFields()
		lnCols = Alen(taResult, 2)
		IF m.lnCols < 18
			lnCols = 18 - m.lnCols
			aColsIns(@m.taResult,, m.lnCols,, Rightc(aFIELDS_VARTYPES, m.lnCols))
		ENDIF

		* Donner les valeurs par défaut
		FOR lnRow = 1 TO m.lnResult
			taResult[m.lnRow, 3] = ICase(;
				taResult[m.lnRow, 2] $ VFP9_FIELD_TYPES_FIXED_LEN_1B, 1,; && 'L'
				taResult[m.lnRow, 2] $ VFP9_FIELD_TYPES_FIXED_LEN_4B, 4,; && 'WGIM'
				taResult[m.lnRow, 2] $ VFP9_FIELD_TYPES_FIXED_LEN_8B, 8,; && 'YDTB'
				taResult[m.lnRow, 3];
				)
		ENDFOR
	ENDIF
ELSE

	lnResult = 0
	ASSERT .F. MESSAGE cAssertMsg(Textmerge([Tableau attendu en premier paramètre <<cLitteral(m.taResult)>>]))
ENDIF

RETURN m.lnResult
	
* ========================================
PROCEDURE aTagInfoEn && aTagInfo() avec les données en anglais quel que soit la langue courante de VFP /!\ Français supporté seulement
LPARAMETERS ;
	taResult,; && @ Spécifications d'indexes au format aTagInfo() [1-tag, 2-type, 3-key expression, 4-filter, 5-order, 6-collate]
	tcCDXName,; && [all open cdx and idx] Name of the compound index (.cdx) file to return information for
	tuWAalias && [Alias()] Work Area or alias of the table to return information for
EXTERNAL ARRAY taResult
tcCDXName = Evl(m.tcCDXName, '')
tuWAalias = Evl(m.tuWAalias, Alias())

LOCAL lnResult as Integer; && number of tags
, llResult;
, lcVersion;
, laVersion[1];
, liVersion;
, liTag;
, lcTag 

lnResult = ATagInfo(taResult, m.tcCDXName, m.tuWAalias)
IF m.lnResult > 0
	
*		Version(3)		REGULAR	CANDIDATE	PRIMARY	BINARY	UNIQUE
	text to lcVersion noshow flags 1 pretext 3 && copy and paste from aw.xls!aTagInfo
00	English	regular	candidate	primary	binary	unique
07	Russian					
33	French	régulier	candidat	primaire	binaire	unique
34	Spanish					
39	Czech					
48	German	einfach	potentiell	primär	binary	eindeutig
55	Korean					
86	Simplified Chinese					
88	Traditional Chinese					
	endtext

*!*			aLinesCols(@m.laVersion, Upper(cEuroANSI(m.lcVersion)), TABUL, 'ICCCCCC')
*!*			liVersion = Evl(Ascan(m.laVersion, Cast(Version(3) as I), 1, -1, 1, 8), 1)
*!*				llResult = NOT Empty(m.lcTag)
*!*				ASSERT m.llResult MESSAGE Proper(Program()) + ' - ' + Textmerge(ICase(;
*!*					cLangUser() = 'fr', "Le type d'index '<<taResult[m.liTag, 2]>>' n'est pas supporté",; && copy-paste this line to add another language support
*!*															"Index type '<<taResult[m.liTag, 2]>>' is not supported"))
*!*				IF m.llResult
*!*				ENDIF

	* Normaliser en anglais car vfp9r*.dll localise cette information ...
	FOR liTag = 1 TO m.lnResult

		* Délocaliser le type d'index
		taResult[m.liTag, 2] = ICase(;
			Candidate(m.liTag, m.tuWAalias),;
				'CANDIDATE',;
			Primary(m.liTag, m.tuWAalias),;
				'PRIMARY',;
			Unique(m.liTag, m.tuWAalias),;
				'UNIQUE',;
			taResult[m.liTag, 2] == 'BINARY',; && not localized
				'BINARY',;
				'REGULAR';
			)

		* Délocaliser l'ordre de l'index
		taResult[m.liTag, 5] = Iif(Descending(m.tcCDXName, m.liTag, m.tuWAalias);
			, 'DESCENDING';
			, 'ASCENDING';
			)
	ENDFOR
ENDIF

RETURN m.lnResult
	
* ========================================
PROCEDURE aTagInfo_ && aTagInfo() d'après un tableau ou une liste
LPARAMETERS ;
	taResult,; && @ Spécifications d'indexes au format aTagInfo() [Tag, Type, Key, Filter, Order, Collation]
	tuTagInfo && @ Spécification d'indexes au format aTagInfo(), tabulées ou délimitées  par ';|\t'
EXTERNAL ARRAY taResult, tuTagInfo

#IF .F.
	1 NAME
	2 TYPE ['REGULAR']
	3 KEY EXPRESSION [=TAG NAME] && éviter délimiteur ',' qui peut se trouver dans l'expression
	4 FILTER EXPRESSION ['']
	5 ORDER as created (Ascending or Descending) ['ASCENDING']
	6 COLLATE sequence [Set("Collate")]
#ENDIF
#DEFINE aTAGINFO_SEPS [;|]+TABUL
 
LOCAL lnCols, liTag, lcSetCollate, lnResult && Nombre d'indexes

IF aClear(@m.taResult)

	lnResult = ICase(;
		Type('tuTagInfo', 1) == 'A', ICase(;
			laEmpty(@m.tuTagInfo), 0,;
			Alen(tuTagInfo, 2) <= 1, Min(Acopy(tuTagInfo, taResult), 0) + aColsDelim(@m.taResult, aTAGINFO_SEPS),;
			Between(Alen(tuTagInfo, 2), 3, 6), Min(Acopy(tuTagInfo, taResult), 0) + Alen(taResult, 1),; && tuTagInfo is already in aTagInfo() format
			-1),;
		Vartype(m.tuTagInfo) == 'C', aLinesCols(@m.taResult, cCommentStripped(cInLineCommentStripped(m.tuTagInfo)), aTAGINFO_SEPS),; && TEXT TO tuTagInfo ... ENDTEXT
		-1)

	ASSERT m.lnResult >= 0 MESSAGE cAssertMsg(Textmerge([Spécification d'index invalide <<cLitteral(m.tuTagInfo)>>]))
	lnResult = Max(m.lnResult, 0)
	IF m.lnResult > 0

		* Ajuster au format de aTagInfo()
		lnCols = Alen(taResult, 2)
		IF m.lnCols < 6
			aColsIns(@m.taResult,, 6 - m.lnCols, '')
		ENDIF
		
		* Donner aux expressions et types d'indexes leurs valeurs par défaut
		lcSetCollate = Set("Collate")
		FOR liTag = 1 TO m.lnResult
			taResult[m.liTag, 1] = Upper(Alltrim(taResult[m.liTag, 1]))
			taResult[m.liTag, 2] = Upper(Alltrim(Evl(taResult[m.liTag, 2], 'REGULAR')))
			taResult[m.liTag, 3] = Normalize(Evl(taResult[m.liTag, 3], taResult[m.liTag, 1])) && par défaut expression = tag = champ
			taResult[m.liTag, 4] = Iif(Empty(taResult[m.liTag, 4]), '', Normalize(taResult[m.liTag, 4])) && Normalize('') : Missing expression (Error 152)
			taResult[m.liTag, 5] = Upper(Alltrim(Evl(taResult[m.liTag, 5], 'ASCENDING')))
			taResult[m.liTag, 6] = Upper(Alltrim(Evl(taResult[m.liTag, 6], m.lcSetCollate)))
		ENDFOR
	ENDIF 

ELSE

	lnResult = 0
	ASSERT .F. MESSAGE cAssertMsg(Textmerge([Tableau attendu en premier paramètre <<cLitteral(m.taResult)>>]))
ENDIF


RETURN m.lnResult

* ========================================
FUNCTION aFieldsDef && Définitions de champs selon le format de aFields()
LPARAMETERS ;
	taFieldsDef,; && @ Définitions de champs selon le format de aFields()
	tcFieldsExp && Expression de description de structure comme dans une commande CREATE TABLE
EXTERNAL ARRAY taFieldsDef

LOCAL lnResult as Integer; && Nombre de champs
, llResult as Boolean;
, llSetNULL as Boolean;
, lnField, laFieldExps[1];
, liField, liCol;
, lcField, lcType, lnLen, lnDec, llNULL

lnResult = 0

* Si la spécification de champs est valide
llResult = Vartype(m.tcFieldsExp) == 'C' AND NOT Empty(m.tcFieldsExp)
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([<<Proper(Program())>> - Expression de description de structure invalide : <<cLitteral(m.tcFieldsExp)>>]))
IF m.llResult
	
	* Tabuler les spécifications de champs
	lnField = aFieldsExp(@m.laFieldExps, m.tcFieldsExp)
	llResult = m.lnField > 0
	ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([<<Proper(Program())>> - Expression de description de structure invalide : <<cLitteral(m.tcFieldsExp)>>]))
	IF m.llResult
	
		* Dimensionner le tableau résultat selon format de aFields()
		DIMENSION taFieldsDef[m.lnField, 18]
		llSetNULL = Set("Null") == 'ON'
		
		* Tant que les spécifications de champs sont valides
		FOR m.liField = 1 TO m.lnField

			IF lFieldExp(laFieldExps[m.liField], @m.lcField, @m.lcType, @m.lnLen, @m.lnDec, @m.llNULL)
				taFieldsDef[m.liField, 1] = m.lcField
				taFieldsDef[m.liField, 2] = m.lcType
				taFieldsDef[m.liField, 3] = m.lnLen
				taFieldsDef[m.liField, 4] = m.lnDec
				taFieldsDef[m.liField, 5] = Nvl(m.llNULL, m.llSetNULL)
				FOR liCol = 7 TO 18 && 5 et 6 = .F. (default)
					taFieldsDef[m.liField, m.liCol] = Iif(m.liCol < 17, '', 0)
				ENDFOR
			ELSE
				llResult = .F.
				EXIT
			ENDIF
		ENDFOR
		
		* Si OK, retourner le nombre de champs
		IF m.llResult
			lnResult = m.lnField

		* Sinon (erreur), effacer le tableau résultat
		ELSE
			aClear(@m.taFieldsDef)
		ENDIF
	ENDIF
ENDIF

RETURN m.lnResult

* ========================================
FUNCTION aFieldsExp && Expressions de description de champ (comme dans une commande ALTER TABLE)
LPARAMETERS ;
	taFieldsExp,; && @ Expressions de champs comme dans une commande ALTER TABLE
	tcFieldsExp && Expression de structure comme dans une commande CREATE TABLE
EXTERNAL ARRAY taFieldsExp

LOCAL llResult, lnResult && Nombre de champs
lnResult = 0

* Si l'Expression de structure est valide
llResult = Vartype(m.tcFieldsExp) == 'C' AND NOT Empty(m.tcFieldsExp)
ASSERT m.llResult MESSAGE cAssertMsg("Expression de description de structure invalide : " + cLitteral(m.tcFieldsExp))
IF m.llResult
	
	* Repérer les délimiteurs : ',' qui ne suit pas une parenthèse ouvrante
	LOCAL lnCar, lcCar, laVirgs[1], lnVirgs, llParenth
	lnVirgs = 0
	FOR lnCar = 1 TO Len(m.tcFieldsExp)
		lcCar = Substr(m.tcFieldsExp, m.lnCar, 1)
		DO CASE
		CASE m.lcCar == '('
			llParenth = .T.
		CASE m.lcCar == ')'
			llParenth = .F.
		CASE m.lcCar == ',' AND NOT m.llParenth
			lnVirgs = m.lnVirgs + 1
			DIMENSION laVirgs[m.lnVirgs]
			laVirgs[m.lnVirgs] = m.lnCar
		ENDCASE
	ENDFOR
	
	* Tabuler les expressions valides
	LOCAL lnVirg, lnStart, lnLen, lcFieldExp
	FOR lnVirg = 0 TO m.lnVirgs && piquets et intervalles !

		lnStart = Iif(m.lnVirg = 0, 0, laVirgs[m.lnVirg])  + 1
		lnLen = Iif(m.lnVirg = m.lnVirgs, Len(m.tcFieldsExp)+1, laVirgs[m.lnVirg + 1]) - m.lnStart
		lcFieldExp = Substr(m.tcFieldsExp, m.lnStart, m.lnLen)
		llResult = lFieldExp(m.lcFieldExp)
		ASSERT m.llResult MESSAGE cAssertMsg("Expression de description de champ invalide : " + cLitteral(m.lcFieldExp))
		IF m.llResult

			lnResult = m.lnResult + 1
			DIMENSION taFieldsExp[m.lnResult]
			taFieldsExp[m.lnResult] = m.lcFieldExp
		ELSE

			EXIT
		ENDIF
	ENDFOR
	
	* Si erreur, effacer le tableau résultat
	IF NOT m.llResult
		aClear(@m.taFieldsExp)
		lnResult = 0
	ENDIF
ENDIF

RETURN m.lnResult

* ========================================
FUNCTION aFieldSpecs && Spécifications d'un champ issues de aFields()
LPARAMETERS ;
	taFieldSpecs,; && @ Spécifications d'un champ issues de aFields()
	tcField,; && Champ à examiner
	tcAlias && [Alias courant]

LOCAL llResult, lnResult
lnResult = 0 && nombre de specs rendues

llResult = aClear(@m.taFieldSpecs)
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge(ICase(;
	cLangUser() = 'fr',	[tableau attendu en premier paramètre : <<cLitteral(m.taFieldSpecs)>>],; && copy-paste this line to add another language support
											[first parameter should be an array: <<cLitteral(m.taFieldSpecs)>>]; && Default: English
	)))
IF m.llResult
	
	tcAlias = Iif(Vartype(m.tcAlias) == 'C', m.tcAlias, Alias())
	llResult = Used(m.tcAlias)
	ASSERT m.llResult MESSAGE cAssertMsg(ICase(;
		cLangUser() = 'fr',	[Alias introuvable :],; && copy-paste this line to add another language support
												[Alias can't be found:]; && Default: English
		) + cLitteral(m.tcAlias))
	IF m.llResult
	
		llResult = Vartype(m.tcField) == 'C' AND lField(m.tcField, m.tcAlias)
		ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([Le champ <<m.tcField>> est introuvable dans l'alias <<m.tcAlias>>]))
		IF m.llResult
			tcField = Upper(Alltrim(m.tcField))
		
			LOCAL laFields[1], lnField
			AFields(laFields, m.tcAlias)
			lnField = Ascan(laFields, m.tcField, 1, -1, 1, 2+4)
			lnResult = Alen(laFields, 2)
			DIMENSION taFieldSpecs[m.lnResult]
			Acopy(laFields, taFieldSpecs, m.lnField, m.lnResult, 1)
		ENDIF
	ENDIF
ENDIF

RETURN m.lnResult

* ========================================
FUNCTION lFieldExp && Expression de description de champ valide (comme dans une commande CREATE TABLE)
LPARAMETERS ;
	tcFieldExp,; && Expression de description de champ comme dans une commande CREATE TABLE
	tcField,; && @ [''] Nom du champ
	tcType,; && @ [''] Type du champ
	tnLen,; && @ [0] Longueur du champ
	tnDec,; && @ [0] Décimales du champ
	tlNULL && @ [.NULL.] Le champ accepte les valeurs NULL

tlNULL = .null.

LOCAL lcFieldExp, lnLens, laLens[1], lcNULL, llResult

llResult = Vartype(m.tcFieldExp) == 'C' AND NOT Empty(m.tcFieldExp)
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([Description de champ invalide : <<cLitteral(m.tcFieldExp)>>]))
IF m.llResult
	lcFieldExp = cRepCharDel(Upper(Alltrim(m.tcFieldExp)))

	* Si le champ est d'un type supporté
	tcField = GetWordNum(m.lcFieldExp, 1)
	lcFieldExp = Ltrim(Substr(m.lcFieldExp, Len(m.tcField) + 1))
	tcType = Left(m.lcFieldExp, 1)
	llResult = m.tcType $ VFP9_FIELD_TYPES
	ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([Type de champ invalide : <<cLitteral(m.tcType)>>]))
	IF m.llResult
		lcFieldExp = Ltrim(Substr(m.lcFieldExp, 2))

		* Déterminer si le champ accepte les NULL
		IF Rightc(m.lcFieldExp, Lenc('NULL')) == 'NULL'
			lcNULL = Iif(Rightc(m.lcFieldExp, Lenc('NOT NULL')) == 'NOT NULL', 'NOT NULL', 'NULL')
			tlNULL = m.lcNULL == 'NULL'
			lcFieldExp = Trim(Leftc(m.lcFieldExp, Lenc(m.lcFieldExp) - Lenc(m.lcNULL)))
		ENDIF
		
		* Si la spécification de longueur de champ (len, dec) est pertinente
		llResult = Iif(m.tcType $ VFP9_FIELD_TYPES_FIXED_LEN;
				, Empty(m.lcFieldExp);
				, Substr(m.lcFieldExp, 1, 1) == '(' AND Substr(m.lcFieldExp, Len(m.lcFieldExp), 1) == ')';
				)
		ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([Spécification de longueur de champ '<<m.lcFieldExp>>' invalide pour le type '<<m.tcType>>']))
		IF m.llResult

			* Si la champ a spécification de longueur
			IF m.tcType $ VFP9_FIELD_TYPES_FIXED_LEN

				tnLen = ICase(;
						m.tcType $ VFP9_FIELD_TYPES_FIXED_LEN_1B, 1,;
						m.tcType $ VFP9_FIELD_TYPES_FIXED_LEN_4B, 4,;
						m.tcType $ VFP9_FIELD_TYPES_FIXED_LEN_8B, 8,;
						0;
					)
			ELSE

				lcFieldExp = Substr(m.lcFieldExp, 2, Len(m.lcFieldExp) - 2) && ôte les parenthèses
				
				* Si la spécification de longueur est valide
				lnLens = ALines(laLens, m.lcFieldExp, 1, ',')
				llResult = Iif(m.tcType $ VFP9_FIELD_TYPES_WITH_DEC, InList(m.lnLens, 1, 2), m.lnLens = 1)
				ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([Spécification de longueur de champ  '<<m.lcFieldExp>>' invalide pour le type <<m.tcType>>]))
				IF m.llResult

					tnLen = Val(laLens[1])
					tnDec = Iif(m.lnLens = 2, Val(laLens[2]), 0)
				ENDIF
			ENDIF
		ENDIF
	ENDIF
ENDIF

tcField = Iif(m.llResult, m.tcField, '')
tcType = Iif(m.llResult, m.tcType, '')
tnLen = Evl(m.tnLen, 0)
tnDec = Evl(m.tnDec, 0)
tlNULL = Iif(m.llResult, m.tlNULL, .null.)

RETURN m.llResult

* ========================================
FUNCTION lFieldsExp && Expression de description de champS valide (comme dans une commande CREATE TABLE)
LPARAMETERS tcFieldsExp && Expression de description de champS comme dans une commande CREATE TABLE

LOCAL laFieldsExp[1]

RETURN aFieldsExp(@m.laFieldsExp, m.tcFieldsExp) > 0

* ========================================
FUNCTION caFields && aFields(laFields) linéarisé en caractères
LPARAMETERS tcTable && [Alias()] Alias ou adresse de table

PRIVATE laField
LOCAL lcAlias, llAlias, laField[1], llSafety, lcFile, lcResult

lcResult = ''

lcAlias = cAlias(m.tcTable, @m.llAlias)
IF Used(m.lcAlias)
	
	AFields(laField, m.lcAlias)

	llSafety = Set("Safety") == 'ON'
	IF m.llSafety
		SET SAFETY OFF
	ENDIF

	lcFile = Addbs(Sys(2023)) + 'temp' + Transform(_VFP.processID)+ '.mem' && multi-serveur

	SAVE TO (m.lcFile) ALL LIKE laField

	IF m.llSafety
		SET SAFETY ON
	ENDIF

	lcResult = Strconv(FileToStr(m.lcFile), 13)
	
	DELETE FILE (m.lcFile)
	
	IF m.llAlias
		USE IN (m.lcAlias)
	ENDIF
ENDIF

RETURN m.lcResult

* ========================================
FUNCTION lRelationTrgt && Un alias est cible d'une relation
LPARAMETERS tcAlias && [Alias()]

LOCAL ARRAY laRelation[1]

RETURN aRelationTrgt(@m.laRelation, m.tcAlias) > 0

* ========================================
FUNCTION aRelationTrgt && Relation dont un alias est la cible
LPARAMETERS ; &&  set relation to <Relational Expression> in <Source Alias> into <Target Alias>
	taRelation,; && Relation [Relational Expression, Source Alias]
	tcAlias && [Alias()] relation Target Alias
EXTERNAL ARRAY taRelation
tcAlias = Upper(Evl(m.tcAlias, Alias()))

LOCAL lnResult; && Nombre de relations trouvées - 0 ou 1
, llResult;
, laUsed[1], lnUsed, liUsed, lcUsed;
, laRelation[1], lnRelation, liRelation;

lnResult = 0

llResult = aClear(@m.taRelation)
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge(ICase(;
	cLangUser() = 'fr',	[tableau attendu en premier paramètre : <<cLitteral(m.taRelation)>>],; && copy-paste this line to add another language support
											[first parameter should be an array: <<cLitteral(m.taRelation)>>]; && Default: English
	)))
IF m.llResult AND NOT Empty(m.tcAlias)

	llResult = Used(m.tcAlias)
	ASSERT m.llResult MESSAGE cAssertMsg(ICase(;
		cLangUser() = 'fr',	[Alias introuvable :],; && copy-paste this line to add another language support
												[Alias can't be found:]; && Default: English
		) + cLitteral(m.tcAlias))
	IF m.llResult
		llResult = .F.

		lnUsed = AUsed(m.laUsed)
		FOR liUsed = 1 TO m.lnUsed
			lcUsed = laUsed[m.liUsed, 1]
			lnRelation = aRelationSrce(@m.laRelation, m.lcUsed)
			IF m.lnRelation > 0
				FOR liRelation = 1 TO m.lnRelation
					llResult = m.laRelation[m.liRelation, 2] == m.tcAlias
					IF m.llResult
						lnResult = 1
						DIMENSION taRelation[2]
						taRelation[1] = m.laRelation[m.liRelation, 1]
						taRelation[2] = m.lcUsed
						EXIT
					ENDIF
				ENDFOR
				IF m.llResult
					EXIT
				ENDIF
			ENDIF
		ENDFOR
	ENDIF
ENDIF

RETURN m.lnResult

* ========================================
FUNCTION lRelationSrce && Un alias est source d'une relation
LPARAMETERS tcAlias && [Alias()] Alias à examiner

LOCAL ARRAY laRelation[1]

RETURN  0 < Iif(Pcount() = 1;
	, aRelationSrce(@m.laRelation, m.tcAlias);
	, aRelationSrce(@m.laRelation);
	)

* ========================================
FUNCTION aRelationSrce && Relations dont un alias est la source
LPARAMETERS ;
	taRelation,; && Relations [1- Relational Expression, 2- Target Alias]
	tcAlias,; && [Alias()] Alias à examiner
	tlExtended,; && [.F., .T. if m.tlCascade] Relations [1- Relational Expression, 2- Target Alias, 3- Target Index Expression, 4- Source Alias]
	tlCascade && [.F.] Explore target alias as source alias

EXTERNAL ARRAY taRelation
tcAlias = Iif(Vartype(m.tcAlias) == 'C', Upper(m.tcAlias), Alias())
tlCascade = lTrue(m.tlCascade)
tlExtended = m.tlCascade or lTrue(m.tlExtended)

LOCAL lnResult as Integer; && Nombre de relations trouvées
, llResult;
, lcTarget;
, lcRelation;
, liRelation

lnResult = Iif(!m.tlCascade or laEmpty(@m.taRelation), 0, Alen(m.taRelation, 1))

IF NOT Empty(m.tcAlias)

	llResult = m.tlCascade or aClear(@m.taRelation)
	ASSERT m.llResult MESSAGE cAssertMsg(Textmerge(ICase(;
		cLangUser() = 'fr',	[tableau attendu en premier paramètre : <<cLitteral(m.taRelation)>>],; && copy-paste this line to add another language support
												[first parameter should be an array: <<cLitteral(m.taRelation)>>]; && Default: English
		)))
	IF m.llResult

		llResult = Used(m.tcAlias)
		ASSERT m.llResult MESSAGE cAssertMsg(ICase(;
			cLangUser() = 'fr',	[Alias introuvable :],; && copy-paste this line to add another language support
													[Alias can't be found:]; && Default: English
			) + cLitteral(m.tcAlias))
		IF m.llResult

			liRelation = 1
			DO WHILE .T.
				lcRelation = Relation(m.liRelation, m.tcAlias)
				IF Empty(m.lcRelation)
					EXIT
				ELSE

					lcTarget = Target(m.liRelation, m.tcAlias)
					
					lnResult = m.lnResult + 1
					DIMENSION taRelation[m.lnResult, Iif(m.tlExtended, 4, 2)]
					taRelation[m.lnResult, 1] = m.lcRelation
					taRelation[m.lnResult, 2] = m.lcTarget
					if m.tlExtended
						taRelation[m.lnResult, 3] = cTagExpr(Order(m.lcTarget), m.lcTarget)
						taRelation[m.lnResult, 4] = m.tcAlias
					endif
					if m.tlCascade
						lnResult = aRelationSrce(@m.taRelation, m.lcTarget, m.tlExtended, m.tlCascade)
					endif
					liRelation = m.liRelation + 1
				ENDIF
			ENDDO
		ENDIF
	ENDIF
ENDIF

RETURN m.lnResult

* ------------------
FUNCTION aRelationSrce_Test && Test unitaire de aRelationSrce()

local loTest as aRelationSrce_Test OF abData.prg;
, aRelationSrce[1] && Relations [Relational Expression, Target Alias[, Target Index Expression, Source Alias]]

close tables all

loTest = NewObject('aRelationSrce_Test', 'abData.prg')
loTest.Dataopen

aClear(@m.aRelationSrce)
loTest.Test(1, @m.aRelationSrce, 'customer')
loTest.Assert(m.aRelationSrce[1,1], Upper('customer_id')) && Relational Expression
loTest.Assert(m.aRelationSrce[1,2], Upper('orders')) && Target Alias

aClear(@m.aRelationSrce)
loTest.Test(1, @m.aRelationSrce, 'customer', .T.)
loTest.Assert(m.aRelationSrce[1,3], Upper('customer_id')) && Target Index Expression
loTest.Assert(m.aRelationSrce[1,4], Upper('customer')) && Source Alias

aClear(@m.aRelationSrce)
loTest.Test(2, @m.aRelationSrce, 'customer', .T., .T.)
loTest.Assert(m.aRelationSrce[1,1], Upper('customer_id')) && Relational Expression
loTest.Assert(m.aRelationSrce[1,2], Upper('orders')) && Target Alias
loTest.Assert(m.aRelationSrce[1,3], Upper('customer_id')) && Target Index Expression
loTest.Assert(m.aRelationSrce[1,4], Upper('customer')) && Source Alias

loTest.Assert(m.aRelationSrce[2,1], Upper('order_id')) && Relational Expression
loTest.Assert(m.aRelationSrce[2,2], Upper('order_line_items')) && Target Alias
loTest.Assert(m.aRelationSrce[2,3], Upper('order_id')) && Target Index Expression
loTest.Assert(m.aRelationSrce[2,4], Upper('orders')) && Source Alias

aClear(@m.aRelationSrce)
loTest.Test(5, @m.aRelationSrce, 'awCountry', .T., .T.)

return m.loTest.Result()

	* ------------------------------
	DEFINE CLASS aRelationSrce_Test AS abUnitTest OF abDev.prg

	PROCEDURE DataOpen

		open database (DOS_AWSAMPLES + 'Tastrade\_Data\Tastrade')
		use Tastrade!customer in 0
			use Tastrade!orders in 0 order customer_i
				use Tastrade!order_line_items in 0 order order_id
		
		set relation to customer_id into orders in customer
			set relation to order_id into order_line_items in orders


		open database (DOS_AWSAMPLES + 'FIC\_Data\awSales')
		use awSales!awCountry in 0
			use awSales!awState in 0 order awCountry
				use awSales!awCustomer in 0 order State
			use awSales!awContact in 0 order awCountry
				use awSales!awCont_Skill in 0 order contactID
					use awSales!awSkill in 0 order awSkill

		set relation in awCountry to awCountry into awState
			set relation in awState to awState into awCustomer
		set relation in awCountry to awCountry into awContact additive
			set relation in awContact to contactID into awCont_Skill
				set relation in awCont_Skill to awSkill into awSkill

	ENDDEFINE

* ========================================
FUNCTION cRelationSrceJoins && joins construits d'après les relations dont un alias est la source
LPARAMETERS tcAlias && [Alias()] Alias à examiner

local result as String;
, aa[1] as String;
, nn as Integer;
, i as Integer;

result = ''

nn = aRelationSrce(@m.aa, m.tcAlias, .T., .T.) && [1- Relational Expression, 2- Target Alias, 3- Target Index Expression, 4- Source Alias]
if m.nn > 0
	for i = 1 to m.nn
		result = m.result + Textmerge(" left join <<Lower(m.aa[m.i, 2])>> on <<Lower(m.aa[m.i, 4])>>.<<Lower(m.aa[m.i, 1])>> = <<Lower(m.aa[m.i, 2])>>.<<Lower(m.aa[m.i, 3])>>")
	endfor
endif

return m.result

* ------------------
FUNCTION cRelationSrceJoins_Test && Test unitaire de cRelationSrceJoins()

local loTest as aRelationSrce_Test OF abData.prg;
, cExpected as String

close tables all

loTest = NewObject('aRelationSrce_Test', 'abData.prg')
loTest.Dataopen

loTest.Test([ join orders on customer.customer_id = orders.customer_id join order_line_items on orders.order_id = order_line_items.order_id], 'customer')

text to cExpected noshow flags 1 pretext 15
 join awcontact on awcountry.awcountry = awcontact.awcountry
 join awcont_skill on awcontact.contactid = awcont_skill.contactid
 join awskill on awcont_skill.awskill = awskill.awskill
 join awstate on awcountry.awcountry = awstate.awcountry
 join awcustomer on awstate.awstate = awcustomer.state
endtext
loTest.Test(' ' + m.cExpected, 'awCountry')

return m.loTest.Result()

* ========================================
FUNCTION abRelationSrceOff && Supprime temporairement les relations dont un alias est la source
LPARAMETERS tcAlias
RETURN CreateObject('abRelationSrceOff', m.tcAlias)

* ========================================
DEFINE CLASS abRelationSrceOff as GA_LIGHTWEIGHT_CLASS && Supprime temporairement les relations dont un alias est la source
* ========================================

HIDDEN cAlias, aRelationSrce[1]

* ---------------
PROCEDURE Init
LPARAMETERS tcAlias
tcAlias = Evl(m.tcAlias, Alias())

LOCAL laRelation[1], lnSelect, llResult

llResult = Used(m.tcAlias) AND aRelationSrce(@m.laRelation, m.tcAlias) > 0
IF m.llResult

	this.cAlias = m.tcAlias
	DIMENSION this.aRelationSrce[Alen(laRelation, 1), Alen(laRelation, 2)]
	Acopy(laRelation, this.aRelationSrce)
	lnSelect = Select(0)
	SELECT (m.tcAlias)
	SET RELATION TO
	SELECT (m.lnSelect)
ENDIF

RETURN m.llResult

* ---------------
PROCEDURE Destroy

IF Used(m.this.cAlias)

	LOCAL liRelation, lcExpr, lcTarget, lnRecno

	FOR liRelation = 1 TO Alen(this.aRelationSrce, 1)

		lcTarget = this.aRelationSrce[m.liRelation, 2]
		IF Used(m.lcTarget)
			lcExpr = this.aRelationSrce[m.liRelation, 1]
*				lnRecno = Recno_(m.lcTarget)
			SET RELATION TO &lcExpr INTO (m.lcTarget) IN (m.this.cAlias) ADDITIVE
*				RecnoSet(m.lnRecno, m.lcTarget)
		ENDIF
	ENDFOR
ENDIF

* ========================================
ENDDEFINE && CLASS abRelationOff
* ========================================

* ========================================
FUNCTION iAutoInc && Prochaine clé primaire d'une table
LPARAMETERS ;
	tcAlias,; && [Alias()] Alias
	tcField,; && Champ clé primaire Integer
	tiIncrement && [1] Incrément

local liResult as Integer;
, llUsed;
, laResult[1];
, loDeleted;
, loTalk;
, loRecno;
, lcFilter

liResult = .null.
loDeleted = abSet('DELETED', 'OFF')
loTalk = abSet('TALK', 'OFF')

tcAlias = cAlias(Evl(m.tcAlias, Alias()), @m.llUsed)

do case
case !Used(m.tcAlias)

case Reccount(m.tcAlias) < 1000

	SELECT Max(&tcField) FROM (m.tcAlias) INTO ARRAY laResult && 50 ms pour 14.000 enr.
	liResult = Evl(laResult[1], 0)

case IsExclusive(m.tcAlias) OR Used('_iAutoInc')

		loRecno = abRecno(m.tcAlias)
		lcFilter = Filter(m.tcAlias)

		SET FILTER TO IN (m.tcAlias)
		CALCULATE Max(&tcField) IN (m.tcAlias) TO liResult && 32 ms pour 14.000 enr. avec affichage du résultat, 31 ms sans
		SET FILTER TO &lcFilter IN (m.tcAlias)

otherwise

		USE (Dbf(m.tcAlias)) IN 0 AGAIN SHARED ALIAS _iAutoInc && évite SET FILTER
		CALCULATE Max(&tcField) IN _iAutoInc TO liResult
		USE IN _iAutoInc

endcase

if m.llUsed
	use in (m.tcAlias)
endif

RETURN Nvl(m.liResult, 0) + Evl(m.tiIncrement, 1)

* ========================================
FUNCTION cSelectSQL && Construit une instruction SELECT-SQL à partir de ses clauses
LPARAMETERS ;
	tcSELECT AS String,; && Clause SELECT
	tcFROM AS String,; && Clause FROM
	tcWHERE AS String,; && [''] Clause WHERE
	tcGROUP AS String,; && [''] Clause GROUP BY
	tcHAVING AS String,; && [''] Clause HAVING
	tcUNION AS String,; && [''] Clause UNION
	tcORDER AS String,; && [''] Clause ORDER BY
	tcINTO AS String,; && [''] Clause INTO
	tlBuffering && [.F.] (VFP seulement) Lire les données en mémoire tampon

tcWHERE = Iif(Vartype(m.tcWHERE) == 'C' AND NOT Empty(m.tcWHERE), 		' WHERE ' + m.tcWHERE, '')
tcGROUP = Iif(Vartype(m.tcGROUP) == 'C' AND NOT Empty(m.tcGROUP), 		' GROUP BY ' + m.tcGROUP, '')
tcHAVING = Iif(Vartype(m.tcHAVING) == 'C' AND NOT Empty(m.tcHAVING), 	' HAVING ' + m.tcHAVING, '')
tcUNION = Iif(Vartype(m.tcUNION) == 'C' AND NOT Empty(m.tcUNION), 		' UNION ' + m.tcUNION, '')
tcORDER = Iif(Vartype(m.tcORDER) == 'C' AND NOT Empty(m.tcORDER), 		' ORDER BY ' + m.tcORDER, '')
tcINTO = Iif(Vartype(m.tcINTO) == 'C' AND NOT Empty(m.tcINTO), 				' INTO ' + m.tcINTO, '')
tlBuffering = Iif(Pcount() >= 9 AND Vartype(m.tlBuffering) == 'L';
		, Textmerge([ WITH (BUFFERING = <<m.tlBuffering>>) ]);
		, '')

RETURN Textmerge([SELECT <<m.tcSELECT>> FROM <<m.tcFROM>><<m.tlBuffering>><<m.tcWHERE>><<m.tcGROUP>><<m.tcHAVING>><<m.tcUNION>><<m.tcORDER>><<m.tcINTO>>])

* ========================================
FUNCTION VFPselectExecute && Exécute un SELECT-SQL VFP dans un tableau, une table ou un curseur dont l'alias est sélectionné au retour
LPARAMETERS ;
	tcSelect,; && Intruction SELECT-SQL
	tuDest,; && @ Destination : array OU adresse de table OU nom de curseur [INTO CURSOR Sys(2015)]
	tlReadWrite,; && [.F.] (applicable si curseur) curseur modifiable
	tlNoFilter,; && [.F.] (applicable si curseur) forcer la création d'une table sur disque
	tlThermoNo,; && [.F.] ne pas afficher la barre d'avancement
	tcComment,; && [''] commentaire de debug
	tcResult && @ [''] Résultat

tcResult = ''

LOCAL lnResult; && Nombre d'enregistrements trouvés (_tally)
, llResult;
, lcSelect;
, lcDest;
, loSafety AS abSet of abDev.prg;
, loSQLThermo AS abSQLthermo OF abData.prg;
, llDegugOut;
, lcSelectShow;
, loExcep AS Exception;

lnResult = 0

* Si l'instruction SELECT est valide
lcSelect = m.tcSelect
llResult = lSelectInst(@m.lcSelect) && _VFP.StartMode > 0 OR 
IF m.llResult
	
	* Ajouter la clause de destination
	IF Type('tuDest', 1) == 'A'
		lcDest = 'ARRAY tuDest'
	ELSE
		tuDest = Iif(Vartype(m.tuDest) == 'C', Alltrim(m.tuDest), '')
		IF lFileAddress(m.tuDest)
			lcDest = 'TABLE ' + cLitteral(m.tuDest)
			loSafety = abSet('SAFETY', 'OFF')
		ELSE
			tuDest = Evl(m.tuDest, Sys(2015))
			lcDest = 'CURSOR ' + m.tuDest ;
					+ Iif(lTrue(m.tlReadWrite), ' READWRITE', '');
					+ Iif(lTrue(m.tlNoFilter), ' NOFILTER', '')
		ENDIF
	ENDIF
	lcSelect = m.lcSelect + ' INTO ' + m.lcDest

	* Exécuter le Select
	loSQLThermo = CreateObject('abSQLthermo', m.tlThermoNo)
	llDegugOut = _VFP.StartMode = 0 AND Wexist('Debug Output')
	TRY
		
		* Loger les résultats si demandé
		IF llDegugOut
			lcSelectShow = cSelectInstShow(m.lcSelect)
			tcComment = Iif(Vartype(m.tcComment) == 'C', Space(1) + Alltrim(m.tcComment) + Space(1), '')
			DEBUGOUT Space(1)
			DEBUGOUT Padr(Textmerge([<<Datetime()>> - OPTIMIZE <<Set("Optimize")>> - DELETED <<Set("Deleted")>> - COLLATE '<<Set("Collate")>>' - ANSI '<<Set("ANSI")>>' -<<m.tcComment>>]), 120, '-')
			DEBUGOUT m.lcSelectShow
			DEBUGOUT 'Appelé par', cCallingModules()
			DEBUGOUT Textmerge([L'instruction SELECT fait <<Ltrim(Transform(Len(m.lcSelect), '99 999'))>> caractères, soit <<Int(Len(m.lcSelect)/8192*100)>>% de la limite de 8.192 caractères])
			PRIVATE pcSYS3054
			Sys(3054, 11, 'pcSYS3054')
			LOCAL lnSeconds
			lnSeconds = Seconds()
		ENDIF

		&lcSelect
		lnResult = _tally

		IF llDegugOut
			DEBUGOUT m.pcSYS3054
			tcResult = cQueryPerf(nSeconds(m.lnSeconds), m.lnResult)
		ENDIF

	CATCH TO m.loExcep
		llResult = .F.
		_ClipText = Iif(m.llDegugOut, m.lcSelectShow, _clipText)
		tcResult = [Erreur dans l'instruction Select ] + Iif(llDegugOut, [(dans clip board) ], '') + ": " + cException(m.loExcep)

	FINALLY
		IF llDegugOut
			Sys(3054, 0)
		ENDIF
	ENDTRY
ELSE
	tcResult = [Invalid SELECT instruction ] + cLitteral(m.tcSelect)
ENDIF

DEBUGOUT m.tcResult

ASSERT m.llResult MESSAGE cAssertMsg(m.tcResult)

RETURN m.lnResult

* ========================================
FUNCTION cQueryPerf && Performance d'une requête
LPARAMETERS ;
	tnSecs,; && Nombre de secondes
	tnRecs && Nombre d'enr. trouvés

RETURN cBarsSecs(m.tnSecs) + [ pour trouver ]  + Ltrim(Transform(m.tnRecs, '999 999')) + [ enregistrements]

* ========================================
FUNCTION lSelectInst && Instruction SELECT valide
LPARAMETERS tcSelect && @ Intruction SELECT-SQL présumée

IF Vartype(m.tcSelect) == 'C' AND NOT Empty(m.tcSelect)
	tcSelect = Alltrim(Chrtran(m.tcSelect, ';' + CRLF, Space(1)))
	RETURN 'SELECT ' $ Upper(m.tcSelect) AND ' FROM ' $ Upper(m.tcSelect) && inutile de créer une variable pour ça !
ELSE
	tcSelect = ''
	RETURN .NULL.
ENDIF


* ========================================
FUNCTION cSelectInstShow && Instruction SELECT décomposée sur plusieurs lignes
LPARAMETERS tcSelect && Intruction SELECT-SQL

LOCAL laClauses[1], lcClause, llResult, lcResult

lcResult = ''
llResult = lSelectInst(@m.tcSelect)
IF m.llResult

	lcResult = cRepCharDel(Chrtran(m.tcSelect, Chr(9), Space(1)))
	
	ALines(laClauses, 'FROM,WITH,WHERE,GROUP,INNER,LEFT,RIGHT,FULL,UNION,HAVING,ORDER,INTO', 1, ',')
	FOR EACH lcClause IN laClauses
		lcClause = ' ' + m.lcClause + ' '
	
		lcResult = Strtran(m.lcResult, m.lcClause, ';' + CRLF +  m.lcClause, 1, -1, 1)
	ENDFOR
ENDIF

RETURN m.lcResult

#IF .F. && Regexp qui décompose une instruction SELECT SQL
^\s*
SELECT\s+(?<select>(?:\([^)]*\)|.)+)\s+
FROM\s+(?<from>(?:\([^)]*\)|.)+?)(?:\s+
WHERE\s+(?<where>(?:\([^)]*\)|.)+?))?(?:\s+
GROUP BY\s+(?<groupby>(?:\([^)]*\)|.)+?))?(?:\s+
HAVING\s+(?<having>(?:\([^)]*\)|.)+?))?(?:\s+
ORDER BY\s+(?<orderby>(?:\([^)]*\)|.)+?))?(?:\s+
LIMIT\s+(?<limit>(?:\([^)]*\)|.)+?))?
\s*$
#ENDIF

* =================================================
DEFINE CLASS abSQLthermo AS Custom && Affiche la barre d'avancement SQL sans message parasite
* =================================================

PROTECTED lThermo, cTalk, cNotify, cWindowTalk, cWindowOutput

lThermo = .F.
cTalk = ""
cNotify = ""
cWindowTalk = ""
cWindowOutput = ""
Name = "abSQLthermo"

* ---------------------------------------------------
PROCEDURE Init
LPARAMETERS tlThermoNo && [.F.] ne pas afficher la barre d'avancement

this.cTalk = Set("TALK")
this.cNotify = Set("NOTIFY")

this.lThermo = !(lTrue(m.tlThermoNo));
	AND InList(_vfp.Startmode, 0, 4)

#IF .F. && _vfp.Startmode
	0 development version in an interactive session.
	1 application object
	2 out-of-process .exe automation server.
	3 in-process .dll automation server.
	4 distributable .app or .exe file.
	5 in-process .dll automation server for multithreaded use.
#ENDIF

IF m.this.lThermo

	SET NOTIFY ON 

	* TBV setting talk on makes the next 4 statements echo to console and
	* mess up  the development mode display. Moved.
	* SET TALK ON

	* Direct Talk to an invisible window
	this.cWindowOutput = "W"+SYS(2015)
	DEFINE WINDOW (this.cWindowOutput) FROM -100,-100 TO -10,-10
	this.cWindowTalk = Set("TALK", 1) && retourne "WINDOW xx"

	SET TALK ON	&& TBV
	SET TALK WINDOW (this.cWindowOutput)

ELSE

	SET NOTIFY OFF
	SET TALK OFF

ENDIF

* ---------------------------------------------------
PROCEDURE Destroy

* restore SET NOTIFY et SET TALK
LOCAL lcTalk, lcNotify
lcTalk = m.this.cTalk
lcNotify = m.this.cNotify
SET TALK &lcTalk
SET NOTIFY &lcNotify

IF m.this.lThermo

	LOCAL lcWindowTalk
	lcWindowTalk = this.cWindowTalk
	SET TALK &lcWindowTalk

	RELEASE WINDOW (this.cWindowOutput)
ENDIF


* =================================================
ENDDEFINE && class abSQLthermo
* =================================================

* ========================================
FUNCTION cVarType && Type de variable d'après le type de champ
LPARAMETERS ;
	tcType && Type de champ
LOCAL lcResult, llResult
lcResult = ''

llResult = Vartype(m.tcType) == 'C';
 AND Len(m.tcType) = 1;
 AND m.tcType $ VFP9_FIELD_TYPES && WCYDTBGILMNFQV
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge('Invalid Field Type: <<cLitteral(m.tcType)>>'))
IF m.llResult

	lcResult = ICase(.F., '';
	 , m.tcType $ 'CMV', 'C';
	 , m.tcType $ 'NFBI', 'N';
	 , m.tcType $ 'WQ', 'Q';
	 , m.tcType;
	 )
ENDIF

RETURN m.lcResult

* ========================================
PROCEDURE TablesFieldRename && Renomme un champ dans plusieurs tables
LPARAMETERS ;
	tcTablesSkel,; && Squelette de l'adresse des tables
	tcField,; && Champ à renommer
	tcFieldNew && Nouveau nom du champ
LOCAL lnResult, llResult && Nombre de tables traitées
lnResult = 0

* Si au moins une table répond au squelette
LOCAL ARRAY laTables[1]
LOCAL lnTables
lnTables = aFiles(@m.laTables, m.tcTablesSkel)
llResult = m.lnTables > 0
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge('No table match the specified skeleton: <<cLitteral(m.tcTablesSkel)>>'))
IF m.llResult
	DEBUGOUT Textmerge("Starting renaming field <<m.tcField>> to <<m.tcFieldNew>> in <<m.lnTables>> tables <<cLitteral(m.tcTablesSkel)>> AT <<Datetime()>>")
	
	* Pour chaque table
	LOCAL lcFolder, lnTable, lcTable, lcTableAddr
	lcFolder = Addbs(JustPath(m.tcTablesSkel))
	Asort(laTables)
	FOR m.lnTable = 1 TO m.lnTables
		lcTable = laTables[m.lnTable]
		lcTableAddr = m.lcFolder + m.lcTable

		* Renommer
		llResult = TableFieldRename(m.lcTableAddr, m.tcField, m.tcFieldNew)

		* Faire part du résultat
		lnResult = m.lnResult + Iif(m.llResult, 1, 0)
		DEBUGOUT Textmerge("<<Str(m.lnTable, 3)>> - Field <<m.tcField>> <<Iif(m.llResult, 'renamed to ' + m.tcFieldNew, 'could not be renamed')>> in table <<cLitteral(m.lcTable)>>")
	ENDFOR

	DEBUGOUT Textmerge('Finished renaming field <<m.tcField>> to <<m.tcFieldNew>> in <<m.lnResult>> tables <<cLitteral(m.tcTablesSkel)>> at <<Datetime()>>')
	
ENDIF


RETURN m.lnResult

* ========================================
PROCEDURE TableFieldRename && Renomme un champ dans une table
LPARAMETERS ;
	tcTable,; && Adresse de la table
	tcField,; && Champ à renommer
	tcFieldNew && Nouveau nom du champ
LOCAL llResult && Le champ a été renommé

* Si la table existe
llResult = lFile(m.tcTable)
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge('Table cannot be found: <<cLitteral(m.tcTable)>>'))
IF m.llResult

	* Si les noms sont corrects
	llResult = lVFPName(@m.tcField) AND lVFPName(@m.tcFieldNew)
	ASSERT m.llResult MESSAGE cAssertMsg(Textmerge("Invalid Field names: <<cLitteral(m.tcField)>> / <<cLitteral(m.tcFieldNew)>>"))
	IF m.llResult
	
		* Si la table peut être ouverte en exclusif
		LOCAL lcAlias
		lcAlias = ExclusiveForce(m.tcTable)
		llResult = Used(m.lcAlias)
		ASSERT m.llResult MESSAGE cAssertMsg(Textmerge("Table <<cLitteral(m.tcTable)>> cannot be opened exclusively"))
		IF m.llResult
		
			* Si le champ est dans la table
			llResult = lField(m.tcField, m.lcAlias)
			IF m.llResult
				
				* Si la table a des indexes
				LOCAL laTags[1], lnTags, llTags
				lnTags = ATagInfo(laTags, '', m.lcAlias)
				IF m.lnTags > 0
				
					* Sélectionner la table
					LOCAL loSelect
					loSelect = abSelect(m.lcAlias)
					
					* Pour chaque index
					LOCAL liTag, llKey, llFilter
					FOR m.liTag = m.lnTags TO 1 STEP -1
						
						* Si le champ est dans l'expression d'index ou de filtre && dans ce cas le renommage sera impossible (erreur 1531)
						llKey = m.tcField $ laTags[m.liTag, 3]
						llFilter = m.tcField $ laTags[m.liTag, 4]
						IF m.llKey OR m.llFilter
						
							* Si l'index est primaire, sortir
							llResult = NOT Primary(m.liTag)
							IF NOT m.llResult
								EXIT
							ENDIF
						
						* Sinon, supprimer du tableau
						ELSE
							Adel(laTags, m.liTag)
							lnTags = m.lnTags - 1
						ENDIF
					ENDFOR
				ENDIF
				llTags = m.lnTags > 0
				
				ASSERT m.llResult MESSAGE cAssertMsg(Textmerge("Field <<m.tcField>> cannot be renamed because part of the primary index"))
				IF m.llResult
				
					* Supprimer les indexes le cas échéant
					IF m.llTags
						FOR m.liTag = 1 TO m.lnTags
							DELETE TAG (laTags[m.liTag, 1])
						ENDFOR
					ENDIF

					* Renommer le champ
					ALTER TABLE (m.lcAlias) RENAME COLUMN (m.tcField) TO (m.tcFieldNew)

					* Supprimer la sauvegarde
					DELETE FILE (ForceExt(m.tcTable, 'BAK'))

					* Rétablir les index
					IF m.llTags
						LOCAL lcTag, lcType, lcKey, lcFilter, lcCollate, lcOrder
						FOR m.liTag = 1 TO m.lnTags
							lcTag = Strtran(Upper(laTags[m.liTag, 1]), m.tcField, m.tcFieldNew)
							lcType = laTags[m.liTag, 2]
							lcType = Iif(m.lcType == 'REGULAR', '', m.lcType)
							lcKey = Strtran(Upper(laTags[m.liTag, 3]), m.tcField, m.tcFieldNew)
							lcFilter = Strtran(Upper(laTags[m.liTag, 4]), m.tcField, m.tcFieldNew)
							lcFilter = Iif(Empty(m.lcFilter), '', 'FOR ' + m.lcFilter)
							lcOrder = laTags[m.liTag, 5]
							lcCollate = cLitteral(laTags[m.liTag, 6])
							INDEX ON &lcKey TAG &lcTag COLLATE &lcCollate &lcFilter &lcOrder &lcType ADDITIVE
						ENDFOR
					ENDIF
				ENDIF
			ELSE
				DEBUGOUT Textmerge("Field <<cLitteral(m.tcField)>> is not in table <<cLitteral(m.tcTable)>>")
			ENDIF
			USE IN (m.lcAlias)
		ENDIF
	ENDIF
ENDIF

RETURN m.llResult

*!*		29/07/11 - dépréciée - remplacée par gaDBCTablesTree()
* ========================================
FUNCTION aDBCTablesTree && Tables d'une base de données dans l'ordre de parenté
LPARAMETERS ;
	taTables,; && @ Tables
	tcDBC,; && Base de données
	tcExcludes,;  && Table(s) à exclure
	tlAsc && [.F.] /!\ à developper /!\ Ordonner les tables selon les parentés ascendantes
EXTERNAL ARRAY taTables

LOCAL llResult, lnResult && nombre de tables
lnResult = 0
llResult = Type('taTables', 1) == 'A'
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([tableau attendu en premier paramètre <<cLitteral(m.taTables)>>]))
IF m.llResult

	llResult = Vartype(m.tcDBC) == 'C' AND DBused(m.tcDBC)
	ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([Invalid database specification: <<cLitteral(m.tcDBC)>>]))
	IF m.llResult

		* Tabuler les tables de la base de données
		LOCAL loDB, lnExcludes, laExcludes[1], lnExclude;
		, lnTable, lcTable, lcTableUp, lnTableUp, llTablesUp, llTableUp;
		, lnLevel, laRels[1], lnRels, lnRel

		loDB = abSet('DATABASE', m.tcDBC,,,.T.)
		lnResult = ADBObjects(taTables, "TABLE")
		aColsIns(@m.taTables,,,1) && lnLevel = 1 par défaut
		
		* Tant que des tables parent sont détectées
		tlAsc = Iif(Vartype(m.tlAsc) == 'L', m.tlAsc, .F.) && /!\ à developper /!\ Ordonner les tables selon les parentés ascendantes
		llTablesUp = .T.
		DO WHILE m.llTablesUp

			* Pour chaque table non exclues
			llTablesUp = .F.
			FOR lnTable = 1 TO m.lnResult
				lcTable = taTables[m.lnTable, 1]
				IF Ascan(laExcludes, m.lcTable) = 0

					lnLevel = taTables[m.lnTable, 2] + 1

					* Si la table a des relations ascendantes
					lnRels = aDBCJoinsUp(@m.laRels, m.tcDBC, m.lcTable) && [Table enfant | Table parent | Tag enfant | Tag parent | RI]
					IF m.lnRels > 0
						
						* Pour chaque table parent
						FOR lnRel = 1 TO m.lnRels
							lcTableUp = laRels[m.lnRel, 2]

							* Si aucune relation mutuelle entre la table et sa parente
							IF NOT lDBCTableParent(m.tcDBC, m.lcTableUp, m.lcTable)
								
								* Si le niveau de la table parent est inférieur au courant
								lnTableUp = Ascan(taTables, m.lcTableUp, 1, -1, 1, 15)
								llTableUp = taTables[m.lnTableUp, 2] < m.lnLevel
								IF m.llTableUp

									* Régler la niveau de la table parent
									taTables[m.lnTableUp, 2] = m.lnLevel
									llTablesUp = .T.
								ENDIF
							ENDIF
						ENDFOR
					ENDIF
				ENDIF
			ENDFOR
		ENDDO
		Asort(taTables, 2, -1, 1) && sort descending
	ENDIF
	
	* Supprimer les tables à exclure éventuelles
	lnExcludes = ALines(laExcludes, Upper(Evl(m.tcExcludes, '')), 1+4, ',', ';')
	IF m.lnExcludes > 0
		FOR EACH lcTable IN laExcludes
			lnExclude = Ascan(taTables, m.lcTable, 1, -1, 1, 2+4+8)
			IF m.lnExclude > 0
				Adel(taTables, m.lnExclude)
				lnResult = m.lnResult - 1
			ENDIF
		NEXT
		llResult = m.lnResult > 0
		ASSERT m.llResult MESSAGE cAssertMsg(Textmerge(['<<m.tcExcludes>>' exclut toutes les tables de la BD '<<m.tcDBC>>' !]))
		IF m.llResult
			DIMENSION taTables[m.lnResult, 2]
		ENDIF
	ENDIF

	aColDel(@m.taTables, 2)
ENDIF

RETURN m.lnResult

* ========================================
FUNCTION lDBCTableParent && Une table est parente d'une autre dans une base de données
LPARAMETERS ;
	tcDBC,; && Base de données
	tcTableChild,; && Table enfant
	tcTableParent && Table parent supposée
LOCAL loSet, laJoins[1], llResult

llResult = Vartype(m.tcTableParent) == 'C' AND NOT Empty(m.tcTableParent)
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([spécification de table parent invalide : <<cLitteral(m.tcTableParent)>>]))
IF m.llResult
	tcTableParent = Upper(Alltrim(m.tcTableParent))

	loSet = abSet('DATABASE', m.tcDBC,,,.T.)
	llResult = Indbc(m.tcTableParent, "TABLE")
	ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([la table parent <<m.tcTableParent>> ne fait pas partie de la base de données <<m.tcDBC>>]))
	IF m.llResult
		
		llResult = aDBCJoinsUp(@m.laJoins, m.tcDBC, m.tcTableChild) > 0;
		 AND Ascan(laJoins, m.tcTableParent,1, -1, 2, 6) > 0
	ENDIF
ENDIF

RETURN m.llResult

* ========================================
FUNCTION aDBCJoinsUp && Jointures ascendantes d'une table dans une base de données
LPARAMETERS ;
	taJoins,; && @ Jointures ascendantes : [1-Table enfant | 2-Table parent | 3-Tag enfant | 4-Tag parent | 5-RI]
	tcDBC,; && Base de données
	tcTableChild,; && Table enfant
	tcTablesIgnore,; && [''] Tables parent à ignorer
	tcFKsChild && [toutes] Clés étrangères (tags) enfant à examiner
EXTERNAL ARRAY taJoins

LOCAL laRelations[1], laTablesIgnore[1];
, llResult, lnResult && Nombre de jointures trouvées

lnResult = 0

* Si la base de données est ouverte
llResult = Vartype(m.tcDBC) == 'C' AND DBused(m.tcDBC)
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge("Invalid database specification: <<cLitteral(m.tcDBC)>>"))
IF m.llResult

	IF NOT Set("Database") == Upper(JustStem(m.tcDBC)) && optimisation
		LOCAL loSetDB
		loSetDB = abSet('DATABASE', m.tcDBC,,,.T.)
	ENDIF

	* Si la base de données contient des relations
	llResult = ADBObjects(laRelations, "RELATION") > 0 && all upper case
	ASSERT m.llResult MESSAGE cAssertMsg(Textmerge("No relation in database <<cLitteral(m.tcDBC)>>"))
	IF m.llResult

		* Si la table enfant est dans la base de données
		llResult = Vartype(m.tcTableChild) == 'C' AND Indbc(m.tcTableChild, "TABLE")
		ASSERT m.llResult MESSAGE cAssertMsg(Textmerge("Table <<cLitteral(m.tcTableChild)>> is not in database <<cLitteral(m.tcDBC)>>"))
		IF m.llResult
			tcTableChild = Upper(Alltrim(m.tcTableChild))
			
			* Si le(s) clés étrangères enfant sont valides
			tcFKsChild = Iif(Vartype(m.tcFKsChild) == 'C', m.tcFKsChild, '')
			IF NOT Empty(m.tcFKsChild)
				llResult = lTags(m.tcFKsChild, m.tcDBC + '!' + m.tcTableChild)
				ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([At least one foreign key <<m.tcFKsChild>> does not belong to table <<m.tcTableChild>>]))
				IF m.llResult
				
					* Supprimer les relations sur des tags enfant non spécifiés
					aDBCJoinsUp_FKsChild(@m.laRelations, m.tcTableChild, m.tcFKsChild)
				ENDIF
			ENDIF
			IF m.llResult
			
				* Tabuler les tables parent à ignorer
				tcTablesIgnore = Iif(Vartype(m.tcTablesIgnore) == 'C', m.tcTablesIgnore, '')
				tcTablesIgnore = Upper(c2Words(m.tcTablesIgnore, ',', m.tcTableChild)) && évite une récursion en cas de jointure mutuelle
				ALines(laTablesIgnore, m.tcTablesIgnore, 1, ',')
				
				* Chercher les jointures à partir de la table
				IF aClear(@m.taJoins)
					lnResult = aDBCJoinsUp_1(@m.taJoins, @m.laRelations, m.tcTableChild, @m.laTablesIgnore)
				ENDIF
			ENDIF
		ENDIF
	ENDIF
ENDIF

RETURN m.lnResult

* ========================================
FUNCTION aDBCJoinsUp_FKsChild && [privée de aDBJoinsUp()] - Filtre les relations sur les tags indiqués
LPARAMETERS ;
	taRelations,; && @ Relations
	tcTableChild,; && Table enfant
	tcFKsChild && Clés étrangères (tags) enfant (dans la table enfant)
EXTERNAL ARRAY taRelations

* Si des tags enfants sont à examiner
LOCAL ARRAY laFKsChild[1]
IF ALines(laFKsChild, Upper(m.tcFKsChild), 1+4, ',') > 0
	
	* Pour chaque relation
	LOCAL lnRels, lnRel
	lnRels = Alen(taRelations, 1)
	FOR lnRel = m.lnRels TO 1 STEP -1

		* Si l'enfant de la relation est la table indiquée et le tag enfant ne fait pas partie de ceux retenus
		IF taRelations[m.lnRel, 1] == m.tcTableChild;
		 AND Ascan(laFKsChild, taRelations[m.lnRel, 3], 1, -1, 1, 6) = 0
		
			* Supprimer la relation
			Adel(taRelations, m.lnRel)
			lnRels = lnRels - 1
		ENDIF
	ENDFOR
	
	DIMENSION taRelations[m.lnRels, Alen(taRelations, 2)]
ENDIF

* ========================================
FUNCTION aDBCJoinsUp_1 && (privée de aDBJoinsUp, récursive) Relations ascendantes d'une table
LPARAMETERS ;
	taJoins,; && @ Relations ascendantes : [Table enfant | Table parent | Tag enfant | Tag parent | Vide]
	taRelations,; && @ Relations de la base de données
	tcTableChild,; && Table enfant
	taTablesIgnore && @ Ignorer ces tables parent
EXTERNAL ARRAY taJoins, taRelations, taTablesIgnore

LOCAL lnRel, lnCols, lcTableParent, lnResult && Nombre de tables trouvées

lnResult = Iif(laEmpty(@m.taJoins), 0, Alen(taJoins, 1))
lnCols = Alen(taRelations, 2)
lnRel = 0

* Pour chaque relation dont la table est enfant
DO WHILE .T.

	lnRel = Ascan(taRelations, m.tcTableChild, m.lnRel+1, -1, 1, 14) && 2+4+8
	IF m.lnRel > 0
		
		* Si la table parent n'est pas ignorée et n'a pas encore été rencontrée
		lcTableParent = taRelations[m.lnRel, 2]
		IF NOT m.lcTableParent == tcTableChild; && auto-jointure
		 AND Ascan(taTablesIgnore, m.lcTableParent, 1, -1, 1, 6) = 0; && table ignorée
		 AND Ascan(taJoins, m.lcTableParent, 1, -1, 1, 6) = 0 && relation mutuelle
			
			* Ajouter la relation
			lnResult = m.lnResult + 1
			DIMENSION taJoins[m.lnResult, m.lnCols]
			Acopy(taRelations, taJoins, Aelement(taRelations, m.lnRel, 1), m.lnCols, Aelement(taJoins, m.lnResult, 1))

			* Récurser sur la table parent
			lnResult = aDBCJoinsUp_1(@m.taJoins, @m.taRelations, m.lcTableParent, @m.taTablesIgnore)
		ENDIF
	ELSE
		EXIT
	ENDIF
ENDDO

RETURN m.lnResult

* -----------------------------------------------------------------
PROCEDURE aDBCJoinsUp_Test

PUBLIC ARRAY gaJoins[1] && Pour consultation après test

LOCAL loTest AS aDBCJoins_Test OF abData.prg, llResult
loTest = CreateObject('aDBCJoins_Test')
IF loTest.DataOpen("C:\aDossier\3609 VS CatElec\Interne\Inet\Donnees\VSCAT.DBC") && a un ASSERT

	aClear(@m.gaJoins)
	loTest.Test(10, @m.gaJoins, 'vscat', 'tad_sel')
ENDIF

IF loTest.DataOpen("C:\ADOSSIER\3680 AF INTUICAT\INTERNE\DONNEES\AFVOL.DBC") && a un ASSERT

	aClear(@m.gaJoins)
	loTest.Test(9, @m.gaJoins, 'AFVOL', 'PROGR', 'ZUSER')

	aClear(@m.gaJoins)
	loTest.Test(2, @m.gaJoins, 'AFVOL', 'PROGR', 'ZUSER', 'IATADEP')
ENDIF

RETURN loTest.Result()

* ========================================
FUNCTION aDBCJoinsParent && Jointures dont une table est parent
LPARAMETERS ;
	taJoins,; && @ Jointures: [1-Table enfant | 2-Table parent | 3-Tag enfant | 4-Tag parent | 5-RI]
	tcDBC,; && Base de données
	tcTableParent && Table de départ
EXTERNAL ARRAY taJoins
LOCAL llResult, lnResult && Nombre de relations
lnResult = 0

* Si la base de données est valide
llResult = Vartype(m.tcDBC) == 'C' AND DBused(m.tcDBC)
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([Invalid database specification: <<cLitteral(m.tcDBC)>>]))
IF m.llResult

	IF NOT Set("Database") == Upper(JustStem(m.tcDBC)) && optimisation
		LOCAL loSetDB
		loSetDB = abSet('DATABASE', m.tcDBC,,,.T.)
	ENDIF

	* Si la table parent est dans la base de données
	llResult = Vartype(m.tcTableParent) == 'C' AND Indbc(m.tcTableParent, "TABLE")
	ASSERT m.llResult MESSAGE cAssertMsg(Textmerge("Table <<cLitteral(m.tcTableParent)>> is not in database <<cLitteral(m.tcDBC)>>"))
	IF m.llResult
		tcTableParent = Upper(Alltrim(m.tcTableParent))
	
		* Si la base de données contient des relations
		lnResult = ADBObjects(taJoins,"RELATION") && all upper case
		llResult = m.lnResult > 0
		ASSERT m.llResult MESSAGE cAssertMsg(Textmerge("No relation in database <<cLitteral(m.tcDBC)>>"))
		IF m.llResult
		
			* Pour chaque relation en partant de la fin
			LOCAL lnRel
			FOR lnRel = m.lnResult TO 1 STEP -1
			
				* Si la table parent de la relation n'est pas la table indiquée, supprimer
				IF NOT taJoins[m.lnRel, 2] == m.tcTableParent
					lnResult = m.lnResult - 1
					Adel(taJoins, m.lnRel)
				ENDIF
			ENDFOR
			IF m.lnResult > 0
				DIMENSION taJoins[m.lnResult, 5]
			ENDIF
		ENDIF
	ENDIF
ENDIF

RETURN m.lnResult

* -----------------------------------------------------------------
PROCEDURE aDBCJoinsParent_Test && aDBCJoinsParent() unit test

PUBLIC ARRAY gaJoins[1] && Pour le consulter après test

LOCAL loTest AS aDBCJoins_Test OF abData.prg
loTest = CreateObject('aDBCJoins_Test')
IF loTest.DataOpen("C:\aDossier\3609 VS CatElec\Interne\Inet\Donnees\VSCAT.DBC")

	aClear(@m.gaJoins)
	loTest.Test(2, @m.gaJoins, 'vscat', 'carr')
ENDIF

RETURN m.loTest.Result()

	* ------------------------------
	DEFINE CLASS aDBCJoins_Test AS abUnitTest OF abDev.prg

	PROCEDURE DataOpen
		LPARAMETERS tcDBC && Adresse de la base de données
		LOCAL llResult

		tcDBC = LocFile(m.tcDBC, 'DBC', JustFname(m.tcDBC) + ' ?')
		llResult = File(m.tcDBC)
		ASSERT m.llResult MESSAGE cAssertMsg(Textmerge("Test File does not exist: <<cLitteral(DisplayPath(m.tcDBC, 30))>>"))
		IF m.llResult

			OPEN DATABASE (m.tcDBC)
		ENDIF

		RETURN m.llResult

	ENDDEFINE

* ========================================
FUNCTION aDBCJoinsChild && Jointures dont une table est enfant
LPARAMETERS ;
	taJoins,; && @ [Table enfant | Table parent | Tag enfant | Tag parent | Vide]
	tcDBC,; && Base de données
	tcTableChild,; && Table enfant
	tcTablesIgnore && [''] Ignorer ces tables parent
EXTERNAL ARRAY taJoins
LOCAL llResult, lnResult && Nombre de relations
lnResult = 0

* Si la base de données est valide
llResult = Vartype(m.tcDBC) == 'C' AND DBused(m.tcDBC)
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([Invalid database specification: <<cLitteral(m.tcDBC)>>]))
IF m.llResult

	IF NOT Set("Database") == Upper(JustStem(m.tcDBC)) && optimisation
		LOCAL loSetDB
		loSetDB = abSet('DATABASE', m.tcDBC,,,.T.)
	ENDIF

	* Si la table enfant est dans la base de données
	llResult = Vartype(m.tcTableChild) == 'C' AND Indbc(m.tcTableChild, "TABLE")
	ASSERT m.llResult MESSAGE cAssertMsg(Textmerge("Table <<cLitteral(m.tcTableChild)>> is not in database <<cLitteral(m.tcDBC)>>"))
	IF m.llResult
		tcTableChild = Upper(Alltrim(m.tcTableChild))
	
		* Si la base de données contient des relations
		aClear(@m.taJoins)
		lnResult = ADBObjects(taJoins, "RELATION") && all upper case
		llResult = m.lnResult > 0
		ASSERT m.llResult MESSAGE cAssertMsg(Textmerge("No relation in database <<cLitteral(m.tcDBC)>>"))
		IF m.llResult

			* Tabuler les tables à ignorer éventuelles
			LOCAL lnRel, laTablesIgnore[1]
			ALines(laTablesIgnore, Upper(Iif(Vartype(m.tcTablesIgnore) == 'C', m.tcTablesIgnore, '')), 1, ',')
			
			* Pour chaque relation en partant de la fin
			FOR lnRel = m.lnResult TO 1 STEP -1
			
				* Si la relation est invalide,
				IF NOT taJoins[m.lnRel, 1] == m.tcTableChild ; && la table enfant n'est pas celle spécifiée
				 OR Ascan(laTablesIgnore, taJoins[m.lnRel, 2], 1, -1, 1, 6) > 0 && la table parent est ignorée

					* Supprimer
					Adel(taJoins, m.lnRel)
					lnResult = m.lnResult - 1
				ENDIF
			ENDFOR
			IF m.lnResult > 0
				DIMENSION taJoins[m.lnResult, 5]
			ENDIF
		ENDIF
	ENDIF
ENDIF

RETURN m.lnResult

* -----------------------------------------------------------------
PROCEDURE aDBCJoinsChild_Test

PUBLIC ARRAY gaJoins[1] && Pour le consulter après test

LOCAL loTest AS aDBCJoins_Test OF abData.prg
loTest = CreateObject('aDBCJoins_Test')
IF loTest.DataOpen("C:\aDossier\3609 VS CatElec\Interne\Inet\Donnees\VSCAT.DBC")

	aClear(@m.gaJoins)
	loTest.Test(2, @m.gaJoins, 'vscat', 'dic_ligne')
ENDIF

RETURN loTest.Result()

* ========================================
FUNCTION lTableReadOnly && Un fichier de table est en lecture seule
lparameters tcTable

local llResult as Boolean;
, lcAlias as String;
, llAlias as Boolean

if File(m.tcTable)
	lcAlias = Sys(2015)
	try
		use (m.tcTable) in 0 again shared alias (m.lcAlias)
		llResult = Used(m.lcAlias) and IsReadonly(m.lcAlias)
	catch
	finally
		use in Select(m.lcAlias)
	endtry
endif

return m.llResult

* ========================================
FUNCTION lTableExpr && Une expression est valide sur une table
LPARAMETERS ;
	tc__Expr,; && Expression à vérifier
	tu__Table && [Alias()] table ou alias où vérifier l'expression

LOCAL lo__Select, lc__Alias, ll__Opened;
, lo__Except AS Exception, ll__Result && Evite que les noms des variables locales puissent figurer dans l'expression

ll__Result = Vartype(m.tc__Expr) == 'C'
ASSERT m.ll__Result MESSAGE cAssertMsg(Textmerge("Invalid expression parameter: <<cLitteral(m.tc__Expr)>>"))
IF m.ll__Result

	ll__Result = Empty(m.tc__Expr)
	IF NOT m.ll__Result

		lc__Alias = cAlias(m.tu__Table, @m.ll__Opened)
		ll__Result = Used(m.lc__Alias)
		ASSERT m.ll__Result MESSAGE cAssertMsg(Textmerge("Table <<cLitteral(m.tu__Table)>> can't be found"))
		IF m.ll__Result
			
			lo__Select = abSelect(0) && pour éviter toute confusion avec les champs de la table courante
			TRY
				= Evaluate(cExprFieldsPrefixed(m.tc__Expr, m.lc__Alias, m.lc__Alias))
			CATCH TO lo__Except
				ll__Result = InList(m.lo__Except.ErrorNo, 1929) && error 1929 : "name" can only be used within a method
			ENDTRY

*			ASSERT m.ll__Result MESSAGE cAssertMsg(Textmerge("Expression <<cLitteral(m.tc__Expr)>> is not valid on table <<m.tu__Table>>; error: <<cException(m.lo__Except)>>"))
			IF m.ll__Opened
				USE IN (m.lc__Alias)
			ENDIF
		ENDIF
	ENDIF
ENDIF

RETURN m.ll__Result

* ========================================
FUNCTION cExprFieldsPrefixed && Expression où les noms de champs d'une table sont préfixés (en général par 'm.' ou 'Alias.')
LPARAMETERS ;
	tcFieldsExpr,; && Expression comportant en principe des champs
	tcTable,; && Table où se trouvent les champs ou son alias
	tcPrefix && ['m'] Préfixe à ajouter avant les noms de champs (prefixe.champ)

LOCAL lcResult;
, llResult;
, lcAlias, llAlias;
, lcField;
, laOps[1]

lcResult = ''

llResult = Vartype(m.tcFieldsExpr) == 'C';
 AND Vartype(m.tcTable) == 'C'
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([Invalid Parameters(s)]))
IF m.llResult

	lcResult = Alltrim(m.tcFieldsExpr)
	IF NOT Empty(m.lcResult)

		lcAlias = Iif(Used(m.tcTable), m.tcTable, cAlias(m.tcTable, @m.llAlias))
		llResult = Used(m.lcAlias)
		ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([La table '<<m.tcTable>>' est introuvable]))
		IF m.llResult

			tcPrefix = Iif(Vartype(m.tcPrefix) == 'C', Alltrim(m.tcPrefix), 'm')
			
			* Si l'expression est un champ de la table
			lcField = JustField(m.lcResult)
			IF lField(m.lcField, m.lcAlias)
			
				lcResult = c2Words(m.tcPrefix, [.], m.lcField)

			* Sinon (expression complexe)
			ELSE
				
				* Si le nombre d'opérandes est inférieur au nombre de champs && optimisation
				lcResult = Iif(aOperands(@m.laOps, m.lcResult) < Fcount(m.lcAlias);
					, cExprFieldsPrefixed_Ops(@m.laOps, m.lcResult, m.lcAlias, m.tcPrefix);
					, cExprFieldsPrefixed_Fields(m.lcResult, m.lcAlias, m.tcPrefix);
					)
			ENDIF
		
			IF m.llAlias
				USE IN (m.lcAlias)
			ENDIF
		ENDIF
	ENDIF
ENDIF

RETURN m.lcResult

* -----------------------------------------------------------------
FUNCTION cExprFieldsPrefixed_Ops && cExprFieldsPrefixed() : Algorithme avec parcours des opérandes
LPARAMETERS ;
	taOps,; && @ Opérandes
	tcFieldsExpr,; && Expression comportant en principe des champs
	tcAlias,; && Alias de la table où se trouvent les champs
	tcPrefix && Préfixe à ajouter avant les noms de champs (prefixe.champ)
EXTERNAL ARRAY taOps

LOCAL lcResult;
, llResult;
, lcPrefix;
, lcOp, lnOp;
, lcField, lnField, lcPrefix2, laOccs[1], lnOcc;

* Pour chaque opérande dans l'expression
lcResult = m.tcFieldsExpr
lcPrefix = m.tcPrefix + Iif(Empty(m.tcPrefix), '', '.')
FOR EACH lcOp IN taOps

	* Si l'opérande est préfixé, ôter le préfixe
	lcField = Iif([.] $ m.lcOp, Substr(m.lcOp, Atc([.], m.lcOp)+1), m.lcOp)
	
	* Si l'opérande est un champ de la table
	lcField = Field(m.lcField, m.tcAlias)
	IF NOT Empty(m.lcField)

		* Tabuler les positions des occurrences du champ dans l'expression, de la fin au début
		llResult = anWordIn(@m.laOccs, m.lcResult, m.lcOp, .T., .T.) > 0
		ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([le mot <<cL(m.lcOp)>> devrait se trouver dans <<m.lcResult>>]))
		IF m.llResult

			Asort(laOccs, 1, -1, 1)
			lnOp = Len(m.lcOp)
			lcField = m.lcPrefix + m.lcField
			FOR EACH lnOcc IN laOccs

				* Remplacer dans l'expression avec un préfixe
				lcResult = '';
					+ Substr(m.lcResult, 1, m.lnOcc-1);
					+ m.lcField;
					+ Substr(m.lcResult, m.lnOcc + m.lnOp)
			ENDFOR
		ENDIF
	ENDIF
ENDFOR

* Supprimer les doubles préfixes éventuels (peut arriver si le champ est présent deux fois dans l'expression)
lcPrefix2 = Replicate(m.lcPrefix, 2)
DO WHILE m.lcPrefix2 $ m.lcResult
	lcResult = Strtran(m.lcResult, m.lcPrefix2, m.lcPrefix)
ENDDO

RETURN m.lcResult

* -----------------------------------------------------------------
FUNCTION cExprFieldsPrefixed_Fields && Algorithme avec parcours des champs de la table
LPARAMETERS ;
	tcFieldsExpr,; && Expression comportant en principe des champs
	tcAlias,; && Alias de la table où se trouvent les champs
	tcPrefix && ['m'] Préfixe à ajouter avant les noms de champs (prefixe.champ)

LOCAL lcResult, lcResultU;
, lnField, lcField, lcField_, lnFieldAt;
, lnOccurs, lnOccur;
, lcCarAnte, lcCarPost;
, lnPrefix

lcResult = m.tcFieldsExpr

* Pour chaque champ de la table
lcResultU = Upper(m.lcResult)
FOR lnField = 1 TO Fcount(m.tcAlias)
	
	* Si le champ est dans l'expression
	IF Field(m.lnField, m.tcAlias) $ m.lcResultU

		* Pour chaque occurrence du champ dans l'expression
		lcField = Field(m.lnField, m.tcAlias)
		lnOccurs = Occurs(m.lcField, m.lcResultU)
		FOR m.lnOccur = m.lnOccurs TO 1 STEP -1
			lnFieldAt = Atc(m.lcField, m.lcResultU, m.lnOccur)
		
			* Si le nom du champ est encadré par séparateur ou opérateur
			lcCarAnte = Substr(m.lcResultU, m.lnFieldAt - 1, 1)
			lcCarPost = Substr(m.lcResultU, m.lnFieldAt + Len(m.lcField), 1)
			llResult = (Empty(m.lcCarAnte) OR m.lcCarAnte $ VFPOPSEPCARS);
						 AND (Empty(m.lcCarPost) OR m.lcCarPost $ VFPOPSEPCARS);
						 AND NOT m.lcCarPost == '.'
			IF m.llResult

				* Si le nom du champ est préfixé, ôter le préfixe
				IF m.lcCarAnte == '.'
					llResult = m.lnFieldAt > 2
					ASSERT m.llResult MESSAGE cAssertMsg(Textmerge("Invalid expression: <<cLitteral(m.lcResult)>>"))
					IF m.llResult
						
						FOR lnPrefix = m.lnFieldAt - 2 TO 1 STEP -1
							IF Substr(m.lcResultU, m.lnPrefix, 1) $ VFPOPSEPCARS
								EXIT
							ENDIF
						ENDFOR
						lcResultU = Substr(m.lcResultU, 1, m.lnPrefix) + Substr(m.lcResultU, m.lnFieldAt)
						lcResult = Substr(m.lcResult, 1, m.lnPrefix) + Substr(m.lcResult, m.lnFieldAt)
					ENDIF
				ENDIF
				IF m.llResult
				
					* Précéder le nom de champ du préfixe
					lcField_ = c2Words(m.tcPrefix, '.', m.lcField)
					lcResultU = Strtran(m.lcResultU, m.lcField, m.lcField_, m.lnOccur, 1)
					lcResult = Strtran(m.lcResult, m.lcField, m.lcField_, m.lnOccur, 1, 1)
				ENDIF
			ENDIF
		ENDFOR
	ENDIF
ENDFOR

RETURN m.lcResult

* -----------------------------------------------------------------
PROCEDURE cExprFieldsPrefixed_Test

LOCAL loTest as cExprFieldsPrefixed_Test of abData.prg
loTest = NewObject('cExprFieldsPrefixed_Test', 'abData.prg') && AS abUnitTest OF abDev.prg

loTest.Test('m.ABBREV+m.EXPANDED', 'FoxCode.abbrev+expanded', 'FoxCodeTest')
loTest.Test('m.ABBREV+m.EXPANDED', 'm.abbrev+FoxCode.expanded', 'FoxCodeTest')
loTest.Test('FoxCode.ABBREV+Left(FoxCode.EXPANDED, 10)', 'm.abbrev+Left(FoxCodeTest.expanded, 10)', 'FoxCodeTest', 'FoxCode')

RETURN loTest.Result()

	* ------------------------------
	DEFINE CLASS cExprFieldsPrefixed_Test AS abUnitTest OF abDev.prg
		PROCEDURE init
			USE (_foxcode) IN 0 AGAIN ALIAS FoxCodeTest
			return DoDefault()
		ENDPROC
	ENDDEFINE

* ========================================
FUNCTION cRecContent && Contenu de l'enregistrement courant d'un alias
LPARAMETERS tcAlias && [Alias()] Alias de la table
tcAlias = Evl(m.tcAlias, Alias())

LOCAL liField, lcField;
, llResult, lcResult

lcResult = ''

tcAlias = cAlias(m.tcAlias)
llResult = Used(m.tcAlias)
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge(ICase(;
	cLangUser() = 'fr',	[Alias ou Table introuvable: <<cLitteral(m.tcAlias)>>],; && copy-paste this line to add another language support
											[Alias or table can't be found: <<cLitteral(m.tcAlias)>>]; && Default: English
	)))
IF m.llResult

	* Pour chaque champ de la table
	FOR liField = 1 TO Fcount(m.tcAlias)
		lcField = Field(m.liField, m.tcAlias)
	
		* Ajouter son nom et son contenu au résultat
		lcResult = m.lcResult;
			+ CRLF;
			+ Padr(cTronc(m.lcField, 20), 25, Space(1));
			+ cTronc(cLitteral(Evaluate(m.tcAlias + '.' + m.lcField), .T.), 50)

	ENDFOR
ENDIF

RETURN m.lcResult

* -----------------------------------------------------------------
PROCEDURE cRecContent_Test

USE (_foxcode) IN 0 AGAIN ALIAS FoxCodeTest
SKIP 10
? cRecContent('FoxCodeTest')
USE IN FoxCodeTest

* ========================================
FUNCTION cTableComment && Désignation d'une table d'une base de données
LPARAMETERS tcTable && table

LOCAL lcAlias, llAlias, lcDBC, llDBC, lcDBC_, lcResult

lcResult = Transform(m.tcTable)

lcAlias = cAlias(m.tcTable, @m.llAlias)
IF Used(m.lcAlias)

	* Si la table appartient à une base de données
	lcDBC = CursorGetProp("Database", m.lcAlias)
	IF NOT Empty(m.lcDBC)
	
		* Ouvrir la base de données le cas échéant
		llDBC = DBused(m.lcDBC)
		lcDBC_ = Set("Database")
		IF m.llDBC
			SET DATABASE TO (m.lcDBC)
		ELSE
			OPEN DATABASE (m.lcDBC) SHARED
		ENDIF
		IF Indbc(m.tcTable,"TABLE")

			lcResult = Evl(DBGetProp(m.tcTable, "TABLE", "Comment"), m.lcResult)	
		ENDIF

		IF NOT m.llDBC
			CLOSE DATABASES
		ENDIF
		SET DATABASE TO (m.lcDBC_)
	ENDIF
	IF m.llAlias
		USE IN (m.lcAlias)
	ENDIF
ENDIF

RETURN m.lcResult

* ========================================
*!*		FUNCTION nRecsAcc && Nombre d'enregistrement couramment accessibles dans un alias
*!*		LPARAMETERS tcAlias && [Alias()] Alias à examiner

*!*		LOCAL llTalk, llNotify, lnSelect, lcField, lcFilter, llResult, lnResult

*!*		lnResult = 0

*!*		tcAlias = cAlias(m.tcAlias)
*!*		llResult = Used(m.tcAlias)
*!*		ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([l'alias <<m.tcAlias>> est introuvable]))
*!*		IF m.llResult AND Reccount(m.tcAlias) > 0

*!*			llTalk = Set("Talk") == 'ON'
*!*			IF m.llTalk
*!*				SET TALK OFF && If SET TALK is ON, COUNT displays the record count.
*!*			ENDIF
*!*			llNotify = Set("Notify") == 'ON'
*!*			IF m.llNotify
*!*				SET NOTIFY OFF
*!*			ENDIF
*!*			
*!*			lcField = Field(1, m.tcAlias)
*!*			lcFilter = Filter(m.tcAlias)
*!*			lcFilter = Iif(Empty(m.lcFilter), '', 'WHERE ' + m.lcFilter)
*!*			lnSelect = Select(0)
*!*			SELECT &lcField FROM (m.tcAlias) &lcFilter INTO CURSOR (Sys(2015))
*!*			lnResult = _tally
*!*			USE
*!*			SELECT (m.lnSelect)

*!*	*!* Abandonné pour rien car les problèmes de variables ou mot clé hors scope (this, thisForm, etc.) dans les filtres demeurent avec SELECT ...
*!*	*!*			COUNT TO lnResult
*!*	*!*			&& Respects SET FILTER
*!*	*!*			&& Records marked for deletion are included in the count if Set("Deleted") == "OFF"

*!*			IF m.llTalk
*!*				SET TALK ON
*!*			ENDIF
*!*			IF m.llNotify
*!*				SET NOTIFY ON
*!*			ENDIF
*!*		ENDIF		
*!*		
*!*		RETURN m.lnResult

* ========================================
FUNCTION nRecsAcc && Nombre d'enregistrement couramment accessibles dans un alias
LPARAMETERS tcAlias && [Alias()] Alias à examiner

tcAlias = Evl(m.tcAlias, Alias())

LOCAL lnResult as Integer;
, llResult;
, lcFilter;
, lcOrder;
, lnSelect;
, lcFor;
, lcSelect;
, lcCursor;
, lnSeconds;
, loRecno;
, lcTalk;

lnResult = 0

llResult = Used(m.tcAlias)
ASSERT m.llResult MESSAGE cAssertMsg(ICase(;
	cLangUser() = 'fr',	[Alias introuvable :],; && copy-paste this line to add another language support
											[Alias can't be found:]; && Default: English
	) + cLitteral(m.tcAlias))
IF m.llResult AND Reccount(m.tcAlias) > 0

	lcFilter = Filter(m.tcAlias)
	lcOrder = Order(m.tcAlias)
	IF Empty(m.lcFilter + m.lcOrder)

		RETURN Reccount(m.tcAlias)

	ELSE
		
		lnSelect = Select(0)
		SELECT (m.tcAlias)

		IF InList(CursorGetProp("Buffering"), 2, 3) && tampon d'enregistrement, on ne peut pas modifier Recno()

			lcFor = Iif(Empty(m.lcOrder); && Expression de filtre de l'index courant
				, '';
				, Sys(2021, Int(Val(Sys(21))));
				)

			lcFilter = c2Words(cParenth(m.lcFilter), ' AND ', cParenth(m.lcFor))
			lcSelect = Iif(Empty(m.lcFilter), '', ' WHERE ' + m.lcFilter)
			lcCursor = Sys(2015)
			lcSelect = Textmerge([SELECT <<Field(1, m.tcAlias)>> FROM <<m.tcAlias>><<m.lcSelect>> INTO CURSOR <<m.lcCursor>>])
			lnSeconds = Seconds()
			&lcSelect
			lnResult = _Tally
			USE

			lnSeconds = Int(nSeconds(m.lnSeconds) * 1000)
			ASSERT Empty(m.lcFilter) OR m.lnSeconds < 20 MESSAGE cAssertMsg(Textmerge(ICase(;
				cLangUser() = 'fr',	[Le calcul du nombre d'enregistrements accessible de l'alias <<m.tcAlias>> prend <<m.lnSeconds>> ms ; essayez d'optimiser le filtre "<<m.lcFilter>>"],; && copy-paste this line to add another language support
														[Computing # of records accessibles in alias <<m.tcAlias>> takes <<m.lnSeconds>> ms ; try to optimize filter condition "<<m.lcFilter>>"]; && Default: English
				)))
		
		ELSE

			loRecno = abRecno()

			lcTalk = Set("Talk")
			SET TALK OFF && If SET TALK is ON, COUNT displays the record count.

			COUNT TO lnResult
			&& Respects SET FILTER
			&& Records marked for deletion are included in the count if Set("Deleted") = "OFF"

			SET TALK &lcTalk
		ENDIF

		SELECT (m.lnSelect)
	ENDIF
ENDIF		

RETURN m.lnResult

* ========================================
FUNCTION nRecsAdded && Nombre d'enregistrements ajoutés à un alias tamponné
LPARAMETERS tcAlias && [Alias()] Alias
tcAlias = Evl(m.tcAlias, Alias())

LOCAL lnBuffering, llResult, lnResult
lnResult = 0

llResult = Used(m.tcAlias) 
ASSERT m.llResult MESSAGE cAssertMsg(ICase(;
	cLangUser() = 'fr',	[Alias introuvable :],; && copy-paste this line to add another language support
											[Alias can't be found:]; && Default: English
	) + cLitteral(m.tcAlias))
IF m.llResult

	lnBuffering = CursorGetProp("Buffering", m.tcAlias)
	DO CASE
	CASE m.lnBuffering = 1
	CASE InList(m.lnBuffering, 4, 5) && tampon de table

		LOCAL lnSelect, lcOrder, lcFilter, liRecno

		lnSelect = Select(0)
		SELECT (m.tcAlias) && optimisation

		* Placer l'Alias dans son ordre naturel sans filtrage
		lcOrder = Order()
		SET ORDER TO
		lcFilter = Filter()
		SET FILTER TO
		
		liRecno = Recno_()

		GO BOTTOM
		lnResult = Recno()
		lnResult = Iif(m.lnResult > 0;
			, 0; && aucun enregistrement ajouté
			, Abs(m.lnResult); && le dernier enregistrement ajouté
			)

		RecnoSet(m.liRecno)
		
		SET ORDER TO (m.lcOrder)
		SET FILTER TO &lcFilter
		SELECT (m.lnSelect)
		
	OTHERWISE && tampon d'enregistrement
		lnResult = Iif(Recno(m.tcAlias) < 0, 1, 0) && on ne peut ajouter qu'un enregistrement au plus
	ENDCASE
ENDIF

RETURN m.lnResult

* ========================================
FUNCTION nRecnoAbs && N° absolu d'un enregistrement dans un Alias même en tampon de table avec des enregistrements ajoutés (Recno() < 0)
LPARAMETERS tcAlias && [Alias()] Alias positionné sur l'enregistrement à examiner
tcAlias = Evl(m.tcAlias, Alias())

LOCAL lnRecs, llResult, lnResult

lnResult = 0

llResult = Used(m.tcAlias)
lnRecs = Iif(m.llResult, Reccount(m.tcAlias), 0)
ASSERT m.llResult MESSAGE cAssertMsg(ICase(;
	cLangUser() = 'fr',	[Alias introuvable :],; && copy-paste this line to add another language support
											[Alias can't be found:]; && Default: English
	) + cLitteral(m.tcAlias))
IF m.lnRecs > 0

	lnResult = Recno(m.tcAlias)

	lnResult = ICase(;
		m.lnResult > 0,;
			m.lnResult,;
			m.lnRecs - nRecsAdded(m.tcAlias) - m.lnResult;
		)
	&& 			InList(CursorGetProp("Buffering", m.tcAlias), 2, 3),;&& tampon d'enregistrement
	&&		m.lnRecs + 1,; && un seul enregistrement peut être ajouté
	&&

ENDIF		

RETURN m.lnResult

* -----------------------------------------------------------------
PROCEDURE nRecnoAbs_Test

LOCAL loTest AS nRecnoAbs_Test OF abData.prg
loTest = CreateObject('nRecnoAbs_Test')
loTest.DataOpen()

&& test 1
loTest.DataAdd5
loTest.Test(2, 'Test')
SET DATASESSION TO m.loTest.DataSessionId
loTest.Assert(-1, Recno('Test'))
SET DATASESSION TO 1

&& test 2
loTest.DataAdd3
loTest.Test(2, 'Test')
SET DATASESSION TO m.loTest.DataSessionId
loTest.Assert(2, Recno('Test'))
SET DATASESSION TO 1

RETURN loTest.Result()

	* ------------------------------
	DEFINE CLASS nRecnoAbs_Test AS abUnitTest OF abDev.prg

	PROCEDURE DataOpen
	CREATE CURSOR Test (Test L)
	APPEND BLANK && 1

	PROCEDURE DataAdd5
	IF CursorGetProp("Buffering") > 1
		TableRevert(.T.)
	ENDIF
	CursorSetProp("Buffering", 5)
	APPEND BLANK && 2, -1
	APPEND BLANK && 2, -2
	SKIP -1

	PROCEDURE DataAdd3
	IF CursorGetProp("Buffering") > 1
		TableRevert(.T.)
	ENDIF
	CursorSetProp("Buffering", 3)
	APPEND BLANK && 2, -1

	ENDDEFINE

* ========================================
FUNCTION abOrder(result, cAlias, cOrder, lDesc)
RETURN CreateObject('abOrder', @m.result, m.cAlias, m.cOrder, m.lDesc)

* ========================================
DEFINE CLASS abOrder as GA_LIGHTWEIGHT_CLASS && saves, changes and restores Order()

HIDDEN cAlias, cOrder, lDesc

* -------------------------------
protected procedure Init
lparameters ;
  result; && @
, cAlias;
, cOrder;
, lDesc

LOCAL success, lUsed, oSelect

cAlias = Evl(m.cAlias, Alias())
success = Used(m.cAlias)
if not m.success

	cAlias = cAlias(m.cAlias, @m.lUsed,, @m.result)
	success = Used(m.cAlias)
endif

if m.success

	oSelect = abSelect(m.cAlias)
	this.cAlias = m.cAlias
	this.cOrder = Iif(!m.lUsed, Order(), .NULL.)
	this.lDesc  = Iif(!m.lUsed and !IsNull(Evl(this.cOrder, .null.)), Descending(), .NULL.)
	
	cOrder = Iif(Vartype(m.cOrder) == 'C', m.cOrder, '')
	if Empty(m.cOrder)
		set order to
	else
		success = lTag(m.cOrder)
		if m.success
			lDesc  = Iif(!Empty(m.cOrder) and lTrue(m.lDesc), 'DESCENDING', '')
			set order to &cOrder in (m.cAlias) &lDesc
		endif
	endif
endif

RETURN m.success

* -------------------------------
protected procedure Destroy

if IsNull(m.this.cOrder)
	use in (m.this.cAlias)
else
	local cOrder, cDesc
	cOrder = m.this.cOrder
	if Empty(m.cOrder)
		set order to 0 in (m.this.cAlias)
	else
		cDesc  = Iif(!empty(m.cOrder) and m.this.lDesc, 'DESCENDING', '')
		set order to (m.cOrder) in (m.this.cAlias) &cDesc
	endif
endif

ENDDEFINE && CLASS abOrder
* ========================================

* ========================================
FUNCTION abFilter(cAlias, cFilter, result)
RETURN CreateObject('abFilter', m.cAlias, m.cFilter, @m.result)

* ========================================
DEFINE CLASS abFilter as GA_LIGHTWEIGHT_CLASS && Sauve Filter(<Alias>), USE <Alias> si nécessaire, applique un autre filtre, rétablit en sortie

HIDDEN cAlias, cFilter

* -------------------------------
protected procedure Init(cAlias, cFilter, result)

local success as Boolean;
, lUsed as Boolean

cAlias = Evl(m.cAlias, Alias())
success = Used(m.cAlias)
if not m.success

	cAlias = cAlias(m.cAlias, @m.lUsed,, @m.result)
	success = Used(m.cAlias)
endif

if m.success
	this.cAlias = m.cAlias
	this.cFilter = Iif(m.lUsed, .NULL., Filter(m.cAlias))
	cFilter = Iif(Vartype(m.cFilter) == 'C', m.cFilter, '')
	set filter to &cFilter in (m.cAlias)
endif

return m.success

* -------------------------------
protected procedure Destroy

if IsNull(m.this.cFilter)
	use in (m.this.cAlias)
else
	local lcFilter
	lcFilter = m.this.cFilter
	set filter to &lcFilter in (m.this.cAlias)
endif

ENDDEFINE && CLASS abFilter
* ========================================

* ========================================
FUNCTION abRowBufferSave(tcAlias, tcError) && {en} Saves and restores an Alias' row buffer {fr} Sauve et rétablit le tampon d'enregistrement d'un Alias
RETURN CreateObject('abRowBufferSave', m.tcAlias, @m.tcError)

* ========================================
DEFINE CLASS abRowBufferSave as GA_LIGHTWEIGHT_CLASS && {en} Saves and restores an Alias' buffer {fr} Sauve et rétablit le tampon d'un Alias

hidden cAlias;
, cFldState;
, aBuffer[1];
, lAppended;
, lDeleted;

* -------------------------------
hidden procedure Init
lparameters ;
  tcAlias; && [Alias()] {en} alias to work on
, tcError; && @ && {en} (cumulative) error if any

local success as Boolean;
, oSelect as abSelect of abData.prg;
, cFldState as String;
, iField as Integer;

success = .T.;
 and varSet(@m.oSelect, abSelect(Evl(m.tcAlias, Alias())));
 and (Used() or cResultAdd(Textmerge([Table or Alias <<cL(m.tcAlias)>> can't be found])));
 and (InList(CursorGetProp("Buffering"), 2, 3) or cResultAdd(Textmerge([Alias '<<Alias()>>' should be row buffered])));
 and varSet(@m.cFldState, GetFldState(-1));
 and !Empty(Chrtran(m.cFldState, '1', ''))
if m.success

	this.cAlias = Alias()
	this.cFldState = m.cFldState

	#if .F.
	1 Field has not been modified or deletion status has not changed.
	2 Field has been modified or deletion status has changed.
	3 Field in an appended record has not been modified or deletion status has not changed for the appended record.
	4 Field in an appended record has been modified or deletion status has changed for the appended record.
	#endif

	this.lAppended = '3' $ m.cFldState or '4' $ m.cFldState
	this.lDeleted = Left(m.cFldState, 1) == Iif(m.this.lAppended, '4', '2')
	
	* {en} save the buffer {fr} sauve le buffer
	dimension this.aBuffer[Fcount()]
	for iField = 1 to Fcount()
		this.aBuffer[m.iField] = Evaluate(Field(m.iField))
	endfor

	TableRevert()

	CursorSetProp("Buffering", 5)
	this.reset
endif

return m.success
endproc

* -------------------------------
hidden procedure Reset

if m.this.lAppended
	append blank
endif

for iField = 1 to Fcount()
	if Substr(m.this.cFldState, m.iField + 1, 1) == Iif(m.this.lAppended, '4', '2')
		Replace (Field(m.iField)) with this.aBuffer[m.iField]
	endif
endfor

if m.this.lDeleted
	delete
endif

* -------------------------------
hidden procedure Destroy

local success as Boolean;
, oSelect as abSelect or abData.prg;
, cFldState as String;
, iField as Integer;

if Used(m.this.cAlias)

	oSelect = abSelect(m.this.cAlias)
	TableRevert(.T.)
	CursorSetProp("Buffering", 3)
	this.reset
endif
endproc

ENDDEFINE && CLASS abRowBufferSave
* ========================================

#if .F.
set deleted off
create cursor Test(test I)
CursorSetProp("Buffering", 3)

test = 1
? 1, GetFldState(-1) && .null.

append blank
test = 1
? 2, GetFldState(-1)

delete
? 3, GetFldState(-1)

replace test with 2
? 4, GetFldState(-1)

append blank
? 5, GetFldState(-1)

replace test with 2
? 6, GetFldState(-1)

delete
? 7, GetFldState(-1)

TableRevert()
use
#endif


* -----------------------------------------------------------------
PROCEDURE abRowBufferSave_Test && abRowBufferSave() unit test

LOCAL loTest AS abRowBufferSave_Test OF abData.prg, liRecno as Integer
loTest = NewObject('abRowBufferSave_Test', 'abData.prg')

with m.loTest AS abRowBufferSave_Test OF abData.prg

.use
	.Test() && 1
	.Assert(IsNull(.cFldState()))

.insert
	.Test() && 2
	.Assert(IsNull(.cFldState()))

.setBuffering(3)
.append
	.Test() && 3
	.Assert('33', .cFldState())

.update(2)
	.Test() && 4
	.Assert('34', .cFldState())
	.Assert(2, .Value())

endwith

return m.loTest.Result()

	* ------------------------------
	DEFINE CLASS abRowBufferSave_Test AS abUnitTest OF abDev.prg
	PROCEDURE Use(in)
		if m.in
			use in Select('abRowBufferSave_Test')
		else
			create cursor abRowBufferSave_Test (abRowBufferSave_Test I)
		endif
	PROCEDURE insert
		insert into abRowBufferSave_Test values (0)
	PROCEDURE append
		append blank in abRowBufferSave_Test 
	PROCEDURE setBuffering(setBuffering)
		CursorSetProp("Buffering", Evl(m.setBuffering, 1), 'abRowBufferSave_Test')
	PROCEDURE update(value)
		replace in abRowBufferSave_Test abRowBufferSave_Test with Evl(m.value, 1)
	PROCEDURE Skip(skip)
		skip Evl(m.skip, 1) in abRowBufferSave_Test
	FUNCTION TableRevert(all)
		return TableRevert(m.all, 'abRowBufferSave_Test')
	FUNCTION TableUpdate(all)
		return TableUpdate(m.all, .F., 'abRowBufferSave_Test')
	FUNCTION Recno
		return Recno('abRowBufferSave_Test')
	FUNCTION cFldState
		return Iif(used('abRowBufferSave_Test') and CursorGetProp("Buffering", 'abRowBufferSave_Test') > 1;
			, GetFldState(-1, 'abRowBufferSave_Test');
			, .null.;
			)
	FUNCTION Value
		return abRowBufferSave_Test.abRowBufferSave_Test
	ENDDEFINE


* ========================================
FUNCTION abRecno(tcAlias, tcError) && Sauve et rétablit Recno(<Alias>), USE <Alias> si nécessaire
RETURN CreateObject('abRecno', m.tcAlias, @m.tcError)

* ========================================
DEFINE CLASS abRecno as GA_LIGHTWEIGHT_CLASS && Sauve et rétablit Recno(<Alias>), USE <Alias> si nécessaire

HIDDEN cAlias, iRecno

* -------------------------------
PROCEDURE Init(tcAlias, tcError)

LOCAL llUsed, llResult

tcAlias = Evl(m.tcAlias, Alias())
llResult = Used(m.tcAlias)
if not m.llResult

	tcAlias = cAlias(m.tcAlias, @m.llUsed,, @m.tcError)
	llResult = Used(m.tcAlias)
endif

if m.llResult
	this.cAlias = m.tcAlias
	this.iRecno = Iif(m.llUsed, .NULL., Recno_(m.tcAlias))
endif

RETURN m.llResult

* -------------------------------
PROCEDURE Destroy
if IsNull(m.this.iRecno)
	use in (m.this.cAlias)
else
	RETURN RecnoSet(m.this.iRecno, m.this.cAlias)
endif

ENDDEFINE && CLASS abRecno
* ========================================

* ========================================
PROCEDURE Recno_ && Recno() avec gestion de BOF()
LPARAMETERS tcAlias && [Alias()]
tcAlias = Evl(m.tcAlias, Alias())

IF Used(m.tcAlias)
	RETURN Iif(Bof(m.tcAlias) OR Reccount(m.tcAlias) = 0, 0, Recno(m.tcAlias))
ELSE
	ERROR 13, Transform(m.tcAlias)
	RETURN .NULL.
ENDIF

* ========================================
PROCEDURE RecnoSet as Boolean && Place un alias sur un enregistrement déterminé avec Recno_()
LPARAMETERS ;
	tiRecno,; && n° d'enregistrement
	tcAlias,; && [Alias()]
	tcResult && @ Résultat (cumulatif)
tcAlias = Evl(m.tcAlias, Alias())

LOCAL llResult as Boolean;
, lcResult as String;
, lnResult as Integer;

llResult = .T.;
 AND Vartype(m.tiRecno) == 'N';
 AND Int(m.tiRecno) = m.tiRecno; && integer
 AND Used(m.tcAlias)
lcResult = Iif(m.llResult, '', Textmerge(ICase(;
		cLangUser() = 'fr',	[Paramètre(s) invalide(s): tiRecno=<<cLitteral(m.tiRecno)>>, tcAlias=<<cLitteral(m.tcAlias)>>],; && copy-paste this line to add another language support
												[Invalid Parameter(s): tiRecno=<<cLitteral(m.tiRecno)>>, tcAlias=<<cLitteral(m.tcAlias)>>]; && Default: English
	)))
IF m.llResult

	&& Précaution pour Alias en tampon d'enregistrement :
	&& toujours tester si l'alias est dans la position recherchée avant de changer Recno()
	&& pour éviter de valider le contenu du tampon
	
	lnResult = Iif(.T.;
	 and lViewRemote(m.tcAlias);
	 and CursorGetProp("FetchAsNeeded", m.tcAlias);
	 and CursorGetProp("FetchSize", m.tcAlias) > 0;
		, CursorGetProp("RecordsFetched", m.tcAlias);
		, Reccount(m.tcAlias);
	)
	
	DO CASE

	CASE Empty(m.lnResult) && added 04 Feb 2014
	
	CASE m.tiRecno < 0 AND CursorGetProp("Buffering", m.tcAlias) < 4
		lcResult = Textmerge(ICase(;
				cLangUser() = 'fr',	[Alias '<<m.tcAlias>>' en tampon d'enregistrement non suppporté],; && copy-paste this line to add another language support
														[Alias '<<m.tcAlias>>' in buffering mode not supported]; && Default: English
			))
		llResult = .F.
	
	CASE Between(m.tiRecno, 1, m.lnResult) OR m.tiRecno < 0
		IF NOT Recno(m.tcAlias) = m.tiRecno
			GO m.tiRecno IN (m.tcAlias)
		ENDIF

	CASE m.tiRecno = 0 && BOF()
		IF NOT Bof(m.tcAlias)
			GO TOP IN (m.tcAlias)
			IF NOT Bof(m.tcAlias)
				SKIP -1 IN (m.tcAlias)
			ENDIF
		ENDIF

	OTHERWISE && EOF()
		IF !Eof(m.tcAlias)
			GO BOTTOM IN (m.tcAlias)
			IF NOT Eof(m.tcAlias)
				SKIP IN (m.tcAlias)
			ENDIF
		ENDIF

	ENDCASE
ENDIF

ASSERT m.llResult MESSAGE cAssertMsg(m.lcResult)
cResultAdd(@m.tcResult, m.lcResult)

RETURN m.llResult

* ========================================
procedure EOFset && place un Alias sur eof()
lparameters tcAlias
if ga_Type_IsChar(m.tcAlias) and Used(m.tcAlias)
	go bottom in (m.tcAlias)
	if !Eof(m.tcAlias)
		skip in (m.tcAlias)
	endif
	return Eof(m.tcAlias)
endif
return .F.
endproc

* ========================================
function lBOF as Boolean && Un Alias est sur le premier enregistrement accessible
lparameters tcAlias && [Alias()]

local result as Boolean;
, oRecno as abRecno of abData.prg;

do case
case !Used(Evl(m.tcAlias, Alias()))
case Bof(m.tcAlias)
	result = .T.
case InList(CursorGetProp("Buffering", m.tcAlias), 2, 3) and lBufferDirty(m.tcAlias) && tampon d'enregistrement, on ne peut pas modifier Recno()
	result = .null.
otherwise
	oRecno = abRecno(m.tcAlias)
	skip -1 in (m.tcAlias)
	result = Bof(m.tcAlias)
endcase

return m.result
endfunc

* ========================================
function lEOF as Boolean && Un Alias est sur le premier enregistrement accessible
lparameters tcAlias && [Alias()]

local result as Boolean;
, oRecno as abRecno of abData.prg;

do case
case !Used(Evl(m.tcAlias, Alias()))
case EOF(m.tcAlias)
	result = .T.
case InList(CursorGetProp("Buffering", m.tcAlias), 2, 3) and lBufferDirty(m.tcAlias) && tampon d'enregistrement, on ne peut pas modifier Recno()
	result = .null.
otherwise
	oRecno = abRecno(m.tcAlias)
	skip 1 in (m.tcAlias)
	result = EOF(m.tcAlias)
endcase

return m.result
endfunc

* ========================================
FUNCTION lRecMod && Un enregistrement d'un curseur tamponné a été modifié && à modifier pour tampon d'enregistrement
LPARAMETERS ;
	tcAlias,; && [courant] Alias à examiner
	tnRec && [courant] n° absolu de l'enregistrement a examiner
LOCAL lnRec, llRec, lcRec, lcFldState, llResult	

tcAlias = Iif(Vartype(m.tcAlias) == 'C' AND Used(m.tcAlias), m.tcAlias, Alias())
lnRec = nRecnoAbs(m.tcAlias)
tnRec = Iif(Vartype(m.tnRec) == 'N' AND Between(m.tnRec, 1, Reccount(m.tcAlias)), m.tnRec, m.lnRec)
llResult = m.tnRec = m.lnRec OR InList(CursorGetProp("Buffering", m.tcAlias), 4, 5)
ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([l'alias <<m.tcAlias>> doit être en buffering de table]))
IF m.llResult

	llRec = m.tnRec # m.lnRec
	IF m.llRec
		GO m.tnRec IN (m.tcAlias)
	ENDIF
	
	lcRec = GetFldState(-1, m.tcAlias)
	llResult = Left(m.lcRec, 1) == '1'
	ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([l'enregistrement a été ajouté ; examen impossible]))
	IF m.llResult

		#IF .F.
			Return value  Modification or deletion status  
			1 Field has not been modified or deletion status has not changed.
			2 Field HAS BEEN MODIFIED or deletion status has changed.
			3 Field in an appended record has not been modified or deletion status has not changed for the appended record.
			4 Field in an appended record HAS BEEN MODIFIED or deletion status has changed for the appended record.
			.NULL. At EOF( )
		#ENDIF

		lcRec = Substr(m.lcRec, 2) && ôter le premier caractère
		llResult = '2' $ m.lcRec OR '4' $ m.lcRec
	ENDIF
	
	IF m.llRec
		GO m.lnRec IN (m.tcAlias)
	ENDIF
ENDIF

RETURN m.llResult

* ==============================
FUNCTION lDataSession(tiDS) && Une DataSession est ouverte

LOCAL liDS, llResult

liDS = Set("Datasession")
TRY
	SET DATASESSION TO m.tiDS
	llResult = .T.
CATCH
FINALLY
	SET DATASESSION TO m.liDS
ENDTRY

RETURN m.llResult

* ========================================
FUNCTION cSQLSelectClause && Clause d'une instruction SELECT-SQL
LPARAMETERS ;
	tcSQLSelect,; && @ Instruction SELECT-SQL (@ nécessaire si m.tlDelete)
	tcClause,; && Clause à rechercher
	tlDelete && [.F.] Supprimer la clause de l'instruction
LOCAL laClauses[1], lnClause, lcResult
lcResult = ''

* Si l'instruction présumée contient des clauses
IF aSQLSelectClauses(@m.laClauses, m.tcSQLSelect) > 0

	tcClause = cRepCharDel(m.tcClause)
	lnClause = Ascan(laClauses, Space(1) + Upper(Alltrim(m.tcClause)) + Space(1), 1, -1, 1, 2+4+8)
	IF m.lnClause > 0

		lcResult = laClauses[m.lnClause, 1] + laClauses[m.lnClause, 2]
		IF lTrue(m.tlDelete)

			tcSQLSelect = Strtran(m.tcSQLSelect, m.lcResult, '')
		ENDIF
	ENDIF
ENDIF

RETURN m.lcResult

* ---------------------
PROCEDURE cSQLSelectClause_Test && Teste cSQLSelectClause

LOCAL lcSQLSelect, loTest AS abUnitTest OF abDev.prg
TEXT TO lcSQLSelect NOSHOW PRETEXT 15
	SELECT *, SUM(gg) AS SUM_GG FROM TableBidon
	WHERE xx = 1 AND yy = 'ff'
	GROUP BY 2, name, 4
	HAVING SUM_GG > 20
	ORDER BY NAME, CITY
	INTO ARRAY cc
ENDTEXT
loTest = NewObject('abUnitTest', 'abDev.prg')

loTest.test(' ORDER BY NAME, CITY', m.lcSQLSelect, 'ORDER  BY')

RETURN loTest.Result()

* =================================
function aSQLparm as String && paramètres d'une instruction Select-SQL normalisée par _ga_StringParseBits_Class_.maskStrings()
&& créée pour faciliter les tests
&& see: modify class awfrm of aw.vcx method wViewSetup
lparameters ;
  aSQLparm as String; && @ out
, cSQL as String;

external array aSQLparm

local result as Integer;
, lnString as Integer;
, lnParm as Integer;
, liParm as Integer;
, lcParm as String;
, lia as Integer;

result = Occurs('?', m.cSQL)
if m.result > 0

	cSQL = Strtran(Lower(m.cSQL), '->', '.')

	do while '? ' $ m.cSQL
		cSQL = Strtran(m.cSQL, '? ', '?')
	enddo

	do while '. ' $ m.cSQL
		cSQL = Strtran(m.cSQL, '. ', '.')
	enddo

	do while ' .' $ m.cSQL
		cSQL = Strtran(m.cSQL, ' .', '.')
	enddo

	cSQL = '';
		+ Strtran(Chrtran(m.cSQL; && StrExtract(): If cEndDelim is an empty string STREXTRACT( ) returns a string from nOccurrence of cBeginDelim to the end of cSearchExpression
			, ' ', '~');
			, '?m.', '?');
		+ ')' && makes sure we find the parameter even at the end of the SQL string (see below)

	dimension aSQLparm[m.result]

	lia = 0
	for liParm = 1 to m.result

		lcParm = Substrc(;
			  m.cSQL;
			, At_c('?', m.cSQL, m.liParm) + 1; && right after '?' to the end of the string
			)

		lnString = Lenc(m.lcParm) + 1

		lcParm = Leftc(;
			  m.lcParm;
			, Min(m.lnString;
				, Evl(At_c('~', m.lcParm), m.lnString); && space
				, Evl(At_c(')', m.lcParm), m.lnString); && end of group | parameter list | string
				, Evl(At_c(']', m.lcParm), m.lnString); && end of group | parameter list | string
				, Evl(At_c(',', m.lcParm), m.lnString); && next parameter in list
				, Evl(At_c('+', m.lcParm), m.lnString); && general operator
				, Evl(At_c('-', m.lcParm), m.lnString); && general operator
				, Evl(At_c('$', m.lcParm), m.lnString); && string operator
				, Evl(At_c('>', m.lcParm), m.lnString); && relational operator
				, Evl(At_c('<', m.lcParm), m.lnString); && relational operator
				, Evl(At_c('=', m.lcParm), m.lnString); && relational operator
				, Evl(At_c('#', m.lcParm), m.lnString); && relational operator
				, Evl(At_c('!', m.lcParm), m.lnString); && relational operator (!=)
				, Evl(At_c('*', m.lcParm), m.lnString); && numeric operator
				, Evl(At_c('/', m.lcParm), m.lnString); && numeric operator
				, Evl(At_c('%', m.lcParm), m.lnString); && numeric operator
				, Evl(At_c('^', m.lcParm), m.lnString); && numeric operator
				, Evl(At_c('.and.', m.lcParm), m.lnString); && logical operator
				, Evl(At_c('.or.',  m.lcParm), m.lnString); && logical operator
				) - 1;
			)
		
		if Ascan(m.aSQLparm, m.lcParm, 1, -1, 1, 6) > 0
			result = m.result - 1
		else
			lia = m.lia + 1
			aSQLparm[m.lia] = m.lcParm
		endif
	endfor
	
	dimension m.aSQLparm[m.result]
endif

return m.result
endfunc

* ----------------------
procedure aSQLparm_Test && Test unitaire de aSQLparm()

LOCAL loTest as abUnitTest of abDev.prg;
, laParm[1] as String;
, lcSQL as String;

loTest = NewObject('abUnitTest', 'abDev.prg')

loTest.Test(4;
	, @m.laParm;
	, 'select someField from someTable where someKey = ? thisForm.someProperty and someKey like ? m.someVariable.or.inlist(?m.someVariable, 1,2).or.isnull(?alias.Field) and somefield like ?thisform.pgf.pag.txt.Value'; && string literal in where clause not supported!
	)
loTest.assert(Lower('thisForm.someProperty'), m.laParm[1])
loTest.assert(Lower('someVariable'), m.laParm[2])
loTest.assert(Lower('alias.Field'), m.laParm[3])
loTest.assert(Lower('thisform.pgf.pag.txt.Value'), m.laParm[4])

return loTest.Result()
endproc

* ========================================
function uSQLparmValueDefault && Valeur par défaut d'un paramètre d'une instruction SQL-select selon son opérateur
lparameters ;
  lcSQLselect; && instruction SQL-select obtenue par CursorGetProp("SQL"), sur une seule ligne
, liParm; && index du paramètre

#if .F.
FieldName Comparison Expression | ALL (Subquery) | ANY (Subquery) | SOME (Subquery) 
-OR- 
FieldName [NOT] LIKE cExpression | IS [NOT] NULL | [NOT] BETWEEN Start_Range.AND.End_Range | [NOT] IN Value_Set 
#endif

local result as String;
, i as Integer;
, c as String;
, lDot as Boolean;
, lWord as Boolean;

result = ''

for i = At_c('?', m.lcSQLselect, m.liParm) - 1 to 1 step -1

	c = Upper(Substrc(m.lcSQLselect, m.i, 1))
	do case

	case m.c $ VFPOPCARS + ',' && opérateur ou séparateur
		exit

	case m.c == '.'
		if m.lDot and m.lWord && second point, .AND. par exemple
			exit
		endif
		lDot = .T.

	case m.c $ ' ()' 
		if m.lWord
			exit
		endif

	otherwise
		lWord = .T.
		result = m.c + m.result
	
	endcase
endfor

return ICase(;
	Upper(Alltrim(m.result)) == 'LIKE',;
		'A junk FoxInCloud string _value_ that *for sure* no view parameter will ever match',;
		.NULL.;
	)
endfunc

* ========================================
function aSQLSelectClauses && Clauses d'une instruction SELECT-SQL && d'après une fonction d'Anders Altberg http://www.foxite.com/archives/extract-a-clause-from-sql-0000195322.htm
LPARAMETERS ;
	taClauses,; && @ Clauses en retour [Clause, argument, position début]
	tcSQLSelect && Instruction SELECT-SQL
EXTERNAL ARRAY taClauses
LOCAL lcSQLSelect, lnClause, lcClause, lcDelim1, lcDelim2, lnResult && Nombre de clauses
lnResult = 0
IF Type('taClauses', 1) == 'A' AND Vartype(m.tcSQLSelect) == 'C'
	
	* Tabuler les clauses dans leur ordre d'occurence dans l'instruction
	lnResult = ALines(taClauses, ' WHERE , ORDER BY , GROUP BY , HAVING , INTO ', 0, ',')
	aColsIns(@m.taClauses, 1, 2)
	lcSQLSelect = Upper(m.tcSQLSelect)
	FOR lnClause = m.lnResult TO 1 STEP -1
		taClauses(m.lnClause, 3) = Atc(taClauses(m.lnClause, 1), m.lcSQLSelect)
		IF taClauses(m.lnClause, 3) = 0
			lnResult = m.lnResult - 1
			Adel(taClauses, m.lnClause)
		ENDIF
	NEXT
	IF m.lnResult > 0

		DIMENSION taClauses[m.lnResult, 3]
		Asort(taClauses,3)

		* Pour chaque clause, extraire ses arguments
		FOR lnClause = 1 TO m.lnResult
			lcDelim1 = taClauses(m.lnClause, 1)
			lcDelim2 = Iif(m.lnClause < m.lnResult, taClauses(m.lnClause+1, 1), '')
			taClauses(m.lnClause,2) = StrExtract(m.tcSQLSelect, m.lcDelim1, m.lcDelim2, 1, 3)
		NEXT
	ENDIF
ENDIF

RETURN m.lnResult

* ---------------------
PROCEDURE aSQLSelectClauses_Test && Teste aSQLSelectClauses

LOCAL lcSQLSelect, laClauses[1], loTest AS abUnitTest OF abDev.prg

TEXT TO lcSQLSelect NOSHOW PRETEXT 15
	SELECT *, SUM(gg) AS SUM_GG FROM TableBidon
	WHERE xx = 1 AND yy = 'ff'
	GROUP BY 2, name, 4
	HAVING SUM_GG > 20
	ORDER BY NAME, CITY
	INTO ARRAY cc
ENDTEXT
loTest = NewObject('abUnitTest', 'abDev.prg')

loTest.test(5, @m.laClauses, m.lcSQLSelect)
loTest.assert('2, name, 4', laClauses[2, 2])
loTest.assert('ARRAY cc', laClauses[5, 2])

RETURN loTest.Result()

* ---------------------
PROCEDURE lTableStruIdem && Deux tables ont une structure et des indexes identiques
LPARAMETERS ;
	tcTable1,;
	tcTable2,;
	tcResult && @ résultat

LOCAL lcAlias1, lcAlias2, llAlias1, llAlias2;
, laField1[1], laField2[1];
, laTag1[1], laTag2[1];
, laDelta[1];
, llResult_, llResult && résultat

lcAlias1 = cAlias(m.tcTable1, @m.llAlias1)
lcAlias2 = cAlias(m.tcTable2, @m.llAlias2)

llResult = USED(m.lcAlias1) AND USED(m.lcAlias2)
IF m.llResult
	
	llResult_ = AFIELDS(m.laField1, m.lcAlias1) = AFIELDS(m.laField2, m.lcAlias2)
	= NOT m.llResult_ AND cResultAdd(@m.tcResult, TEXTMERGE([Nombres de champs différents : <<ALEN(m.laField1, 1)>> / <<ALEN(m.laField1, 2)>>]))
	llResult = m.llResult AND m.llResult_
		
	aColsDel(@m.laField1, 6)
	aColsDel(@m.laField2, 6)
	ASORT(m.laField1)
	ASORT(m.laField2)
	llResult_ = laEqual(@m.laField1, @m.laField2,, @m.laDelta)
	= NOT m.llResult_ AND cResultAdd(@m.tcResult, [Définitions de champs différentes : ] + cListOfArray(@m.laDelta,,-1))
	llResult = m.llResult AND m.llResult_

	llResult_ = aTagInfoEn(@m.laTag1, FORCEEXT(m.tcTable1, 'cdx'), m.lcAlias1) = aTagInfoEn(@m.laTag2, FORCEEXT(m.tcTable2, 'cdx'), m.lcAlias2)
	= NOT m.llResult_ AND cResultAdd(@m.tcResult, TEXTMERGE([Nombres d'indexes différents : <<ALEN(m.laTag1, 1)>> / <<ALEN(m.laTag2, 1)>>]))
	llResult = m.llResult AND m.llResult_

	ASORT(m.laTag1)
	ASORT(m.laTag2)
	llResult_ = laEqual(@m.laTag1, @m.laTag2,, @m.laDelta)
	= NOT m.llResult_ AND cResultAdd(@tcResult, [Définitions d'indexes différentes : ] + cListOfArray(@m.laDelta,,-1))
	llResult = m.llResult AND m.llResult_

ELSE
	cResultAdd(@m.tcResult, 'Table(s) introuvable(s)')
ENDIF

IF m.llAlias1
	USE IN (m.lcAlias1)
ENDIF
IF m.llAlias2
	USE IN (m.lcAlias2)
ENDIF

RETURN m.llResult

* ---------------------
FUNCTION Used_ && Un Alias d'une liste est Used()
LPARAMETERS tcAliases

LOCAL laAlias[1], lcAlias, llResult

IF ALines(laAlias, m.tcAliases, 5, ',', ';') > 0
	FOR EACH lcAlias IN laAlias
		llResult = Used(m.lcAlias)
		IF NOT m.llResult
			EXIT
		ENDIF
	ENDFOR
ENDIF

RETURN m.llResult

* ========================================
DEFINE CLASS abDataSyncVFP AS Custom && Synchronise deux tables ou deux bases de données VFP && as custom pour .addObject()
* ========================================

	* RÉGLAGES
	cTimeStampField = 'tMOD' && clé & champ date et heure de dernière modification d'une table ; pris en compte dans le réglage de plSync && 'tMOD' est le standard FoxInCloud
	clSyncField = 'lSYNC' && champ 'enregistrement modifié par synchronisation' normalement présent dans chaque table && 'lSYNC' est le standard FoxInCloud
	lTypesForce = .F. && Forcer les types des champs de la table source vers ceux de la table destination
	lSyncDeleted = .T. && Synchroniser les enregistrements deletés
	lModCheck = .F. && Vérifier que les données ont changé avant de remplacer && évite une mise à jour inutile de la date de modification

	lDebug = .F. && Enrichir les messages d'erreur
	cErrorHeader = '/!\' && en-tête ajouté au résultat en cas d'erreur

	cDBCdest = '' && Adresse de la base de données destination
	cDBCsrce = '' && Adresse de la base de données source
	&& les base de données source et destination peuvent porter le même nom ... l'adresse est nécessaire
	cTablesIgnore = '' && tables à ignorer (cf. this.DBCSync())

	* RÉSULTATS EN LECTURE SEULE
	lResult = .T. && Succès / Échec
	cResult = '' && Texte résultat
	oResult = .NULL. && Objet résultat (par table)
	DIMENSION aResults[1]; && Objets résultats (tables)
		, aResultItems[1] && éléments de l'objet résultat : cf. this.Init_aResultItems()
	cResultCursor = '' && Curseur résultats

	* INTERNES
	PROTECTED lErrorFatal, aDBCdestTables[1], cLangUser

	*---------------------------------------
	PROCEDURE Init
	lparameters ;
	  result; && @
	, cLangUser && [cLangUser()]

	LOCAL llResult;
	, lnResultItem;
	, lcResultItems
	
	this.cLangUser = cLangUser(m.cLangUser)
	
	* Tabuler les éléments l'objet résultat
	llResult = .T.;
		and DoDefault();
		and this.Init_aResultItems()
	IF m.llResult

		* Créer l'objet résultat
		this.oResult = CreateObject('empty') && Résultat d'exécution sous forme d'objet
		FOR lnResultItem = 1 TO Alen(this.aResultItems, 1)
			AddProperty(m.this.oResult, this.aResultItems[m.lnResultItem, 1], this.aResultItems[m.lnResultItem, 2])
		ENDFOR

		* Créer le curseur résultats (qui contiendra un objet résultat par table)
		lcResultItems = ''
		this.cResultCursor = Textmerge([<<m.this.name>>_<<Ttoc(Datetime(),1)>>])
		FOR lnResultItem = 1 TO Alen(this.aResultItems, 1)
			lcResultItems = c2Words(m.lcResultItems, ',', Textmerge("<<this.aResultItems[m.lnResultItem, 1]>> <<this.aResultItems[m.lnResultItem, 3]>>"))
		ENDFOR
		AddProperty(m.this, 'abSelect', abSelect())
		CREATE CURSOR (m.this.cResultCursor) (&lcResultItems)

		this.cDBCsrce = m.this.cDBCsrce && see this.cDBCsrce_Assign()
		this.cDBCdest = m.this.cDBCdest && see this.cDBCdest_Assign()
	ENDIF

	RETURN m.llResult

	*---------------------------------------
	HIDDEN FUNCTION Init_aResultItems && 1-Nom | 2-Valeur par défaut | 3-Type de champ | 4 Description localisée
	
	LOCAL llResult;
	, lcResultItem;
	, lnResultItem;
	, laResultItem[1];
	, liResultItem;
	, laLang[1];
	, liLangUser;
	, llLangUser;
	
	&& /!\ la Description ne doit pas contenir '|'
	TEXT TO lcResultItem NOSHOW FLAGS 1 PRETEXT 1+2 && Field | default value | Type | en | fr | de | es | it | pt
		lResult | .T. | L | Success | Succès
		cResult | '' | M | Result | Résultat
		cTableSrce | '' | C(100) | Source Table | Table source
		cTableDest | '' | C(100) | Destination Table | Table destination
		nRecsSrce | 0 | I | Source Recs | Enr. source
		nRecsAdded | 0 | I | Added | Ajoutés
		nRecsReplaced | 0 | I | Replaced | Remplacés
		nRecsDeleted | 0 | I | Deleted | Supprimés
		nFiles | 0 | I | # Files | Nb Fichiers
		cFiles | '' | M | Files | Fichiers
		nRecsSrceError | 0 | I | Errors | Erreurs
		cRecsSrceErrorNo | '' | C(100) | Erroneous Source records # | No[s] d'enregistrement[s] source avec erreur
		cRecsSrceErrorContent | '' | M | Erroneous Source records contents | Contenu du[es] enregistrement[s] source avec erreur
		cException | '' | M | Exception if any | Exception éventuelle
		lDBCsrce | .F. | L | Srce DBC OK | DBC source OK
		lDBCdest | .F. | L | Dest DBC OK | DBC destination OK
		lTableSrce | .F. | L | Srce Table OK | Table source OK
		lTableDest | .F. | L | Dest Table OK | Table destination OK
		cFieldsMissingSrce | '' | M | Missing fields in Source table | Champs manquants dans la table source
		cFieldsMissingDest | '' | M | Missing fields in Destination table | Champs manquants dans la table destination
		lDestExclusive | .F. | L | Destination table was replaced | Remplacement de la table destination qui a pu être ouverte en exclusif
		lPCtag | .F. | L | Records were compared using a candidate or primary index | Les enregistrements ont été comparés selon un index primaire ou candidat
		lCtag | .F. | L | Records were compared using a candidate index | Les enregistrements ont été comparés selon un index candidat
		cPCtag | '' | C(100) | Primary or candidate index tag in destination table | Nom de l'index primaire ou candidat de la table destination
		cPCexp | '' | C(100) | Primary or candidate index expression in destination table | Expression de l'index primaire ou candidat de la table destination
	ENDTEXT

	lnResultItem = aLinesCols(@m.laResultItem, m.lcResultItem, '|')
	
	liLangUser = 0
	if ALines(laLang, 'en | fr | de | es | it | pt', 5, '|') > 0
		liLangUser = Ascan(laLang, m.this.cLangUser, 1, -1, 1, 7)
		liLangUser = Iif(m.liLangUser > Alen(m.laResultItem, 2)- 3;
			, m.liLangUser;
			, 0;
			)
	endif
	
	llLangUser = m.liLangUser > 0

	FOR liResultItem = 1 TO m.lnResultItem
		laResultItem[m.liResultItem, 1] = Alltrim(m.laResultItem[m.liResultItem, 1])
		laResultItem[m.liResultItem, 2] = Evaluate(Alltrim(m.laResultItem[m.liResultItem, 2])) && valeur par défaut
		laResultItem[m.liResultItem, 3] = Alltrim(m.laResultItem[m.liResultItem, 3])
		laResultItem[m.liResultItem, 4] = Alltrim(Iif(m.llLangUser;
			, Evl(laResultItem[m.liResultItem, m.liLangUser], laResultItem[m.liResultItem, 4]);
			, laResultItem[m.liResultItem, 4];
			))
	endfor

	aColsDel(@m.laResultItem, 5)

	DIMENSION this.aResultItems[m.lnResultItem, 4]
	Acopy(m.laResultItem, this.aResultItems)

	*---------------------------------------
	PROTECTED PROCEDURE Destroy

	USE IN Select(m.this.cResultCursor)

	*---------------------------------------
	protected procedure ResultClear && Raze l'objet résultat

	this.cErrorHeader = Alltrim(Evl(m.this.cErrorHeader, '/!\'))

	this.lResult = .T.
	this.cResult = ''

	LOCAL liResultItem
	FOR liResultItem = 1 TO Alen(this.aResultItems, 1)
		STORE this.aResultItems[m.liResultItem, 2] TO ('m.this.oResult.' + this.aResultItems[m.liResultItem, 1])
	ENDFOR

	*---------------------------------------
	PROTECTED PROCEDURE cResult_Assign
	LPARAMETERS tcResult

	tcResult = Iif(ga_Type_IsChar(m.tcResult), m.tcResult, '?')

	if m.this.lResult
		this.cResult = m.tcResult
	else
		this.cResult = c2Words(;
			  m.this.cResult;
			, CRLF;
			, Textmerge([<<m.this.cErrorHeader>> <<Lower(Program(Program(-1)-1))>> - <<Alltrim(m.tcResult)>>]);
			)
	endif

	*---------------------------------------
	PROTECTED PROCEDURE cResultAdd
	LPARAMETERS tcResult
	
	local llResult

	llResult = m.this.lResult
	this.lResult = .F.
	this.cResult = m.tcResult
	this.lResult = m.llResult
	
	*---------------------------------------
	PROTECTED PROCEDURE oResultFinal && Objet résultat final
	this.oResult.lResult = m.this.lResult
	this.oResult.cResult = m.this.cResult
	RETURN m.this.oResult

	*---------------------------------------
	PROCEDURE cResultFinal && résultat final
	lparameters ;
	  tlSuccess; && [.F.] en cas de succès, seulement le résultat
	, tlPipe && [.F.] séparer les éléments par '|'
	
	tlPipe = Iif(lTrue(m.tlPipe), ' | ', CRLF)

	this.oResultFinal

	LOCAL lcResult, liResultItem, luResultItem

	lcResult = ''
	FOR liResultItem = 1 TO Iif(lTrue(m.tlSuccess) and m.this.oResult.lResult;
	 , 2;
	 , Alen(this.aResultItems, 1);
	 )

		luResultItem = Evaluate('m.this.oResult.' + this.aResultItems[m.liResultItem, 1])

		lcResult = m.lcResult;
			+ m.tlPipe;
			+ this.aResultItems[m.liResultItem, 4] + ': ';
			+ cTronc(Transform(m.luResultItem), 3000, .T.) && cCRLFfix()

	endfor
	
	this.ResultClear

	RETURN Substr(m.lcResult, Len(m.tlPipe) + 1)

	*---------------------------------------
	HIDDEN PROCEDURE cDBCdest_Assign
	LPARAMETERS tcDBC && nom | adresse de la base de données destination

	this.oResult.lDBCdest = this.lDBC(@m.tcDBC)

	IF .T.;
	 AND m.this.oResult.lDBCdest;
	 AND (NOT luEqual(m.this.cDBCdest, m.tcDBC) or lCallingModule('Init'))

		* Nouvelle base de données : tabuler les tables
		LOCAL ARRAY laTables[1]
		this.oResult.lDBCdest = ga_DBCTablesTree(@m.laTables, m.tcDBC) > 0 && aDBCTablesTree(@m.laTables, m.tcDBC) > 0
		IF this.oResult.lDBCdest

			DIMENSION this.aDBCdestTables[Alen(m.laTables)]
			Acopy(laTables, m.this.aDBCdestTables)

			this.cDBCdest = m.tcDBC
		ELSE
			this.cResult = Textmerge(ICase(;
				m.this.cLangUser = 'fr',	[Aucune table trouvée dans la base de données :],; && copy-paste this line to add another language support
																	[No table was found in the database:]; && Default: English"
				) + [ '<<m.tcDBC>>'])
		ENDIF
	ENDIF
	
	this.lResult = m.this.lResult AND this.oResult.lDBCdest
	
	*---------------------------------------
	HIDDEN PROCEDURE cDBCsrce_Assign
	LPARAMETERS tcDBC && nom | adresse de la base de données source

	this.oResult.lDBCsrce = this.lDBC(@m.tcDBC)
	IF m.this.oResult.lDBCsrce

		this.cDBCsrce = m.tcDBC
	ENDIF
	
	this.lResult = m.this.lResult AND this.oResult.lDBCsrce

	*---------------------------------------
	HIDDEN PROCEDURE lDBC as Boolean
	LPARAMETERS tcDBC && @ nom | adresse de la base de données

	local llResult
	
	do case

	case Empty(m.tcDBC)
		llResult = .null.

	case !ga_Type_IsChar(m.tcDBC)
		this.cResult = Textmerge(ICase(;
				m.this.cLangUser = 'fr',	[Spécification de base de données invalide : <<cLitteral(m.tcDBC)>>],; && copy-paste this line to add another language support
																	[Database specification is invalid: <<cLitteral(m.tcDBC)>>]; && Default: English
				))

	case !VarStore(@m.tcDBC, ForceExt(m.tcDBC, 'dbc'))
		this.cResult = ICase(;
				m.this.cLangUser = 'fr',	[Erreur inattendue],; && copy-paste this line to add another language support
																	[Unexpected error]; && Default: English
				)

	case !File(m.tcDBC)
		this.cResult = Textmerge(ICase(;
				m.this.cLangUser = 'fr',	[Base de données introuvable : <<cLitteral(m.tcDBC)>>],; && copy-paste this line to add another language support
																	[This database can't be found: <<cLitteral(m.tcDBC)>>]; && Default: English
				))

	otherwise
		tcDBC = FullPath(m.tcDBC)
		OPEN DATABASE (m.tcDBC)
		llResult = .T.

	endcase

	ASSERT Nvl(m.llResult, .T.) MESSAGE m.this.cResult
	
	RETURN m.llResult

	*---------------------------------------
	PROTECTED FUNCTION aTablesIgnore && Tables à ignorer
	LPARAMETERS ;
		taTablesIgnore,; && @ Tables à ignorer
		tcTablesIgnore && Tables à ignorer
	EXTERNAL ARRAY taTablesIgnore

	tcTablesIgnore = Iif(Vartype(m.tcTablesIgnore) == 'C', m.tcTablesIgnore, '')
	this.cTablesIgnore = Iif(Vartype(m.this.cTablesIgnore) == 'C', m.this.cTablesIgnore, '')
	tcTablesIgnore = Upper(c2Words(m.tcTablesIgnore, ',', m.this.cTablesIgnore))

	RETURN ALines(taTablesIgnore, m.tcTablesIgnore, 1, ',', ';') && peu importent les doublons !

	*---------------------------------------
	PROCEDURE DBCSync && Synchronise deux bases de données VFP
	LPARAMETERS ;
		tcDBCdest,; && [this.cDBCdest] Adresse de la base de données destination
		tcDBCsrce,; && [this.cDBCsrce] Adresse de la base de données source
		tcTablesIgnore,; && [this.cTablesIgnore] Tables à ignorer
		tuFieldsIgnore,; && ['WARNING'] Ignorer si ces champs de la table destination sont absents de la table source ; .T.: aucune vérification de structure
		tlReplace,; && [.F.] Remplacer toute la table destination
		tlCKmatch && [.F.] Matcher les enregistrements sur la première clé candidate de la table destination

	this.ResultClear
	this.cDBCdest = Evl(m.tcDBCdest, m.this.cDBCdest) && cf. this.cDBCdest_assign()
	this.cDBCsrce = Evl(m.tcDBCsrce, m.this.cDBCsrce) && cf. this.cDBCsrce_assign()
	IF m.this.lResult
	
		LOCAL laTablesIgnore[1], lnTables, lnTable, lcTable, llTable;
		, luFieldsIgnore, llReplace, llCandMatch;
		, liResultItem, lcResultItem, lcResult, llResult

		* Tabuler les tables à ignorer
		this.aTablesIgnore(@m.laTablesIgnore, m.tcTablesIgnore)

		* Pour chaque table destination
		lnTables = Alen(m.this.aDBCdestTables)
		DIMENSION this.aResults[m.lnTables]
		lcResult = ''
		FOR m.lnTable = 1 TO m.lnTables

			lcTable = this.aDBCdestTables[m.lnTable]
			this.ResultClear
			
			* Si la table n'est pas à ignorer
			IF Ascan(laTablesIgnore, m.lcTable,1,-1,1,7) = 0
				
				* Si la table est à traiter
				luFieldsIgnore = m.tuFieldsIgnore
				llReplace = m.tlReplace
				llCandMatch = m.tlCKmatch
				IF this.DBCSync_Table_Ante(m.lcTable, @m.luFieldsIgnore, @m.llReplace, @m.llCandMatch)

					* Si les tables peuvent être synchronisées
					llTable = this.TableSync(;
						  Textmerge([<<this.cDBCdest>>!<<m.lcTable>>]);
						, Textmerge([<<this.cDBCsrce>>!<<m.lcTable>>]);
						, m.luFieldsIgnore;
						, m.llReplace;
						, m.llCandMatch;
						)

					this.oResult.lResult = m.llTable

					* Exécuter la méthode shell
					llTable = this.DBCSync_Table_Post(m.lcTable, m.this.oResultFinal())
				ELSE
					this.cResult = Textmerge(ICase(;
						m.this.cLangUser = 'fr',	[La table '<<m.lcTable>>' n'a pas été synchronisée sur ordre de <<m.this.Name>>.DBCSync_Table_Ante()],; && copy-paste this line to add another language support
																			[<<m.this.Name>>.DBCSync_Table_Ante() ordered not to synchronize  '<<m.lcTable>>']; && Default: English
						))
				ENDIF
			ELSE
				this.cResult = Textmerge(ICase(;
					m.this.cLangUser = 'fr',	[La table '<<m.lcTable>>' a été ignorée conformément à la liste '<<m.tcTablesIgnore>>'],; && copy-paste this line to add another language support
																		[Table '<<m.lcTable>>' was ignored as of list '<<m.tcTablesIgnore>>']; && Default: English
					))
			ENDIF
			this.oResult.lResult = m.llTable

			* Enregistrer le résultat pour la table
			this.aResults[m.lnTable] = CreateObject('empty') && Résultat d'exécution sous forme d'objet
			FOR liResultItem = 1 TO Alen(this.aResultItems, 1)
				lcResultItem = this.aResultItems[m.liResultItem, 1]
				AddProperty(this.aResults[m.lnTable], m.lcResultItem, Evaluate('this.oResult.' + m.lcResultItem))
			ENDFOR

			llResult = m.llResult AND m.llTable
			lcResult = c2Words(m.lcResult, CRLF, m.this.cResult)

			* Si erreur fatale, terminé
			IF m.this.lErrorFatal
				EXIT
			ENDIF
		ENDFOR

		* Enregistrer le résultat final
		this.cResult = m.lcResult
		this.lResult = m.llResult
	ENDIF
	
	RETURN m.this.lResult

	*---------------------------------------
	PROTECTED PROCEDURE DBCSync_Table_Ante && méthode shell avant synchronisation
	LPARAMETERS ;
		tcTable,; && Table sur le point d'être synchronisée
		tuFieldsIgnore,; && @ Ignorer si ces champs de la table destination sont absents de la table source ; .T.: aucune vérification de structure
		tlReplace,; && @ Remplacer toute la table destination
		tlCKmatch && @ Matcher les enregistrements sur la première clé candidate de la table destination

	*---------------------------------------
	PROTECTED PROCEDURE DBCSync_Table_Post && méthode shell après synchronisation
	LPARAMETERS ;
		tcTable,; && Table qui vient d'être synchronisée
		toResult && Résultat de la synchronisation
	
	LOCAL llResult
	llResult = DoDefault(m.tcTable, m.toResult)
	IF m.llResult

		* Si le curseur résultat est ouvert
		llResult = Used(m.this.cResultCursor)
		ASSERT m.llResult MESSAGE cAssertMsg(Textmerge(ICase(;
			m.this.cLangUser = 'fr',	[Le curseur résultat '<<m.this.cResultCursor>>' a été refermé par erreur],; && copy-paste this line to add another language support
																[Result Cursor '<<m.this.cResultCursor>>' was mistakenly closed]; && Default: English
			)))
		IF m.llResult

			* Ajouter un enregistrement résultat
			LOCAL loSelect
			loSelect = abSelect(m.this.cResultCursor)
			APPEND BLANK
			GATHER NAME m.toResult MEMO
		ENDIF
	ENDIF
	
	RETURN m.llResult
	
	*---------------------------------------
	PROCEDURE TableSync && Synchronise deux tables VFP
	LPARAMETERS ;
		tcTableDest,; && Table destination (Adresse || Alias || db!Table)
		tcTableSrce,; && Table source  (Adresse || Alias || db!Table)
		tuFieldsIgnore,; && ['WARNING'] Ignorer si ces champs de la table destination sont absents de la table source ; .T.: aucune vérification de structure
		tlReplace,; && [.F.] Remplacer toute la table destination
		tlCKmatch,; && [.F.] Matcher les enregistrements sur la première clé candidate de la table destination
		tnRecs && [all] Nombre d'enregistrements à synchroniser

	this.ResultClear

	LOCAL loSelect as abSelect of abData.prg;
	, lcAliasSrce, llAliasSrce;
	, lcAliasDest, llAliasDest;
	, loException AS Exception

	loSelect = abSelect()

	this.oResult.cTableDest = cTableComment(m.tcTableDest)
	this.oResult.cTableSrce = cTableComment(m.tcTableSrce)
		
	* Si la table destination peut être ouverte && en premier pour l'aliaser sous son nom
	lcAliasDest = cAlias(m.tcTableDest, @m.llAliasDest)
	this.oResult.lTableDest = Used(m.lcAliasDest)
	this.lResult = this.oResult.lTableDest
	IF m.this.lResult
		
		* Si la table source peut être ouverte
		lcAliasSrce = cAlias(m.tcTableSrce, @m.llAliasSrce)
		this.oResult.lTableSrce = Used(m.lcAliasSrce)
		this.lResult = this.oResult.lTableSrce
		IF m.this.lResult

			this.oResult.nRecsSrce = Reccount(m.lcAliasSrce)

			* Si le champs de la Table source sont tous dans la Table destination et réciproquement
			this.lResult = .F.;
			 OR lTrue(m.tuFieldsIgnore) ;
			 OR this.lFieldsMatch(m.lcAliasDest, m.lcAliasSrce, uDefault(m.tuFieldsIgnore, 'WARNING'))
			IF m.this.lResult

				TRY

					* Réaliser la sychronisation
					this.lResult = this.TableSync_(;
						  m.lcAliasDest;
						, m.lcAliasSrce;
						, m.tlReplace;
						, m.tlCKmatch;
						, m.tnRecs;
						)

				CATCH TO loException
					this.lResult = .F.
					this.cResult = cException(m.loException)
					this.oResult.cException = m.this.cResult
				ENDTRY
			ELSE
				* Traité par this.lFieldsMatch()
			ENDIF
		ELSE
			this.cResult = Textmerge(ICase(;
				m.this.cLangUser = 'fr',	[Impossible d'ouvrir la table source <<cLitteral(m.tcTableSrce)>>],; && copy-paste this line to add another language support
																	[Could not open source table <<cLitteral(m.tcTableSrce)>>]; && Default: English
				))
		ENDIF
	ELSE
		this.cResult = Textmerge(ICase(;
			m.this.cLangUser = 'fr',	[Impossible d'ouvrir la table destination <<cLitteral(m.tcTableDest)>>],; && copy-paste this line to add another language support
																[Could not open destination table <<cLitteral(m.tcTableDest)>>]; && Default: English
			))
	ENDIF

	ASSERT m.this.lResult MESSAGE m.this.cResult

	IF m.llAliasDest && après assert pour voir le contenu des tables
		USE IN Select(m.lcAliasDest)
	ENDIF
	IF m.llAliasSrce
		USE IN Select(m.lcAliasSrce)
	ENDIF

	RETURN m.this.lResult

	*---------------------------------------
	HIDDEN FUNCTION lFieldsMatch && Les champs des tables source et destination sont cohérents
	LPARAMETERS ;
		tcAliasDest,; && Alias de la table destination
		tcAliasSrce,; && Alias de la table source
		tcFieldsIgnore && Champs à ignorer

	LOCAL llFieldsSrce, llFieldsDest

	this.oResult.cFieldsMissingSrce = Nvl(cFieldsNotIn(m.tcAliasDest, m.tcAliasSrce, m.tcFieldsIgnore), '?')
	llFieldsSrce = Empty(m.this.oResult.cFieldsMissingSrce)

	this.oResult.cFieldsMissingDest = Nvl(cFieldsNotIn(m.tcAliasSrce, m.tcAliasDest, m.tcFieldsIgnore), '?')
	llFieldsDest = .T. && Empty(m.this.oResult.cFieldsMissingDest)

	this.lResult = m.llFieldsDest AND m.llFieldsSrce

	IF NOT m.this.lResult
	
		LOCAL lcTableSrce, lcTableDest
		lcTableSrce = DisplayPath(cTableAddress(m.tcAliasSrce), 50)
		lcTableDest = DisplayPath(cTableAddress(m.tcAliasDest), 50)

		this.cResult = c2Words(;
			  Iif(m.llFieldsSrce;
				, '';
				, Textmerge(ICase(;
					m.this.cLangUser = 'fr',	[La table destination '<<m.lcTableDest>>' comporte au moins un champ manquant dans la table source '<<m.lcTableSrce>>' : <<cLitteral(m.this.oResult.cFieldsMissingSrce)>>],; && copy-paste this line to add another language support
																		[Destination table '<<m.lcTableDest>>' holds at least one field missing in source table '<<m.lcTableSrce>>': <<cLitteral(m.this.oResult.cFieldsMissingSrce)>>]; && Default: English
					));
				);
			, CRLF;
			, Iif(m.llFieldsDest;
				, '';
				, Textmerge(ICase(;
					m.this.cLangUser = 'fr',	[La table source '<<m.lcTableSrce>>' comporte au moins un champ manquant dans la table destination '<<m.lcTableDest>>' : <<cLitteral(m.this.oResult.cFieldsMissingDest)>>],; && copy-paste this line to add another language support
																		[Source table '<<m.lcTableSrce>>' holds at least one field missing in destination table '<<m.lcTableDest>>': <<cLitteral(m.this.oResult.cFieldsMissingDest)>>]; && Default: English
					));
				);
			)
	ENDIF

	RETURN m.this.lResult
	
	*---------------------------------------
	PROTECTED PROCEDURE TableSync_ && Réalise la synchronisation des tables
	LPARAMETERS ;
		tcAliasDest,; && Alias de la table destination
		tcAliasSrce,; && Alias de la table source
		tlReplace,; && [.F.] Remplacer toute la table destination
		tlCKmatch,; && [.F.] Matcher les enregistrements sur la première clé candidate de la table destination
		tnRecs && [all] Nombre d'enregistrements à synchroniser
	tlReplace = lTrue(m.tlReplace)
	tlCKmatch = lTrue(m.tlCKmatch)
	tnRecs = Iif(Vartype(m.tnRecs) == 'N' AND m.tnRecs > 0, Int(m.tnRecs), 0)

	* Si la table destination a une clé unique (primaire ou candidate)
	LOCAL llCtag, lcPCtag, lcPCexp, lcPCexpMem;
	, llPtag, lcPtag, lcPexp, lcPexpMem, lcPexpDest, lcPCmsg

	llCtag = m.tlCKmatch
	lcPCtag = cTagPC(m.tcAliasDest, @m.lcPCexp, @m.llCtag)
	this.oResult.lPCtag = NOT Empty(m.lcPCtag) AND lTableExpr(m.lcPCexp, m.tcAliasSrce)
	IF this.oResult.lPCtag

		* Calculer l'expression mémoire de la clé
		lcPCexpMem = cExprFieldsPrefixed(m.lcPCexp, m.tcAliasDest, 'm') && expression de recherche de l'enr. à mettre à jour (en mémoire)
		
		* Si la clé est candidate et la table destination a une clé primaire valable sur la table source
		llPtag = NOT m.llCtag
		IF m.llPtag
			lcPtag = m.lcPCtag
			lcPexp = m.lcPCexp
			lcPexpMem = m.lcPCexpMem
		ELSE
			lcPtag = cTagP(m.tcAliasDest, @m.lcPexp)
			llPtag = NOT Empty(m.lcPtag) AND lTableExpr(m.lcPexp, m.tcAliasSrce)
			IF m.llPtag
				lcPexpMem = cExprFieldsPrefixed(m.lcPexp, m.tcAliasDest, 'm')
				lcPexpDest = cExprFieldsPrefixed(m.lcPexp, m.tcAliasDest, m.tcAliasDest)
			ENDIF
		ENDIF

		* Définir si les enr. sont comparés sur clé candidate
		this.oResult.lCtag = NOT m.llPtag OR m.tlCKmatch && les enregistrements sont comparés selon un index candidat
		this.oResult.cPCtag = Iif(m.this.oResult.lCtag, m.lcPCtag, m.lcPtag) && nom de l'index primaire ou candidat de la table destination
		this.oResult.cPCexp = Iif(m.this.oResult.lCtag, m.lcPCexp, m.lcPexp) && expression de l'index primaire ou candidat de la table destination
		lcPCmsg = Textmerge([];
			+ ICase(;
				m.this.cLangUser = 'fr',	[ajout ou remplacement d'enregistrement(s) selon la clé <<Iif(this.oResult.lCtag, 'candidate', 'primaire')>> '<<m.this.oResult.cPCtag>>' (<<m.this.oResult.cPCexp>>)],; && copy-paste this line to add another language support
																	[adding or replacing records based on <<Iif(this.oResult.lCtag, 'candidate', 'primary')>> key '<<m.this.oResult.cPCtag>>' (<<m.this.oResult.cPCexp>>)]; && Default: English
				);
			+ Iif(m.this.oResult.lCtag AND m.llPtag;
				, ICase(;
					m.this.cLangUser = 'fr',	[ et la clé primaire '<<m.lcPtag>>' (<<m.lcPexp>>)],; && copy-paste this line to add another language support
																		[ and primary key '<<m.lcPtag>>' (<<m.lcPexp>>)]; && Default: English
					);
				, '';
				);
			)


	* Sinon (la table destination n'a pas de clé unique)
	ELSE
		IF m.tlCKmatch
			this.lResult = .F.
			lcPCmsg = ICase(;
				m.this.cLangUser = 'fr',	[synchronisation abandonnée : une clé candidate est exigée mais aucune n'est commune à la table source et destination],; && copy-paste this line to add another language support
																	[synchronisation canceled: a candidate key is required but source and destination tables don't share any]; && Default: English
				)
		ELSE
			lcPCmsg = ICase(;
				m.this.cLangUser = 'fr',	[ajout seul (aucune clé primaire ou candidate commune à la table source et destination)],; && copy-paste this line to add another language support
																	[adding records only (source and destination tables share no primary or candidate key)]; && Default: English
				)
		ENDIF
	ENDIF
	lcPCmsg = Iif(m.this.lResult AND m.tlReplace, 'vidée puis ', '') + m.lcPCmsg
	this.cResult = Textmerge(ICase(;
		m.this.cLangUser = 'fr',	[Table destination : '<<Dbf(m.tcAliasDest)>>' - <<m.lcPCmsg>>],; && copy-paste this line to add another language support
															[Destination table: '<<Dbf(m.tcAliasDest)>>' - <<m.lcPCmsg>>]; && Default: English
		))
	IF m.this.lResult

		* Si la table destination doit et peut être remplacée (vidée avant synchronisation)
		IF m.tlReplace
			tcAliasDest = ExclusiveForce(m.tcAliasDest)
			this.lResult = Used(m.tcAliasDest)
			IF m.this.lResult AND Reccount(m.tcAliasDest) > 0
				ZAP IN (m.tcAliasDest)
			ENDIF
			this.oResult.lDestExclusive = m.this.lResult
		ENDIF
		IF m.this.lResult

			* Créer une variable par champ de la table source
			LOCAL lcFields
			lcFields = cFields(m.tcAliasSrce)
			LOCAL &lcFields

			* Si forçage des types ou vérification des modifications
			IF .F.;
			 OR m.this.lTypesForce;
			 OR m.this.lModCheck

				LOCAL laField[1], lnField, liField, lcField

				* Tabuler les champs de la table source présents dans la table destination, et leurs types
				lnField = ALines(laField, Strtran(m.lcFields, ',', ','+',') + ',', 1+2, ',') && un élément vide après chaque champ
				DIMENSION laField[m.lnField, 2]
				FOR liField = m.lnField TO 1 STEP -1
					lcField = laField[m.liField, 1]
					IF lField(m.lcField, m.tcAliasDest)
						laField[m.liField, 2] = Vartype(Evaluate(m.tcAliasDest + '.' + m.lcField), .T.)
					ELSE
						lnField = m.lnField - 1
						Adel(laField, m.liField)
					ENDIF
				ENDFOR
				DIMENSION laField[m.lnField, 2]
			ENDIF
			
			* Créer les variables privées standard FoxInCloud / ZenBuyer
			PRIVATE plSync, pltModKeep, plPKGen
			plSync = .T. && Inhibe le contrôle des droits dans la base zenbuyer
			pltModKeep = .T.; && Inhibe la mise à jour automatique de la date de modification
				 AND Vartype(m.this.cTimeStampField) == 'C';
				 AND lField(m.this.cTimeStampField, m.tcAliasDest);
				 AND lField(m.this.cTimeStampField, m.tcAliasSrce)
			plPKGen = m.tlReplace OR NOT m.llPtag && Générer la PK

			LOCAL loDeleted, loExact, loException AS Exception, llSyncField
			loDeleted = abSet('DELETED', Iif(m.this.lSyncDeleted, 'OFF', 'ON'))
			loExact = abSet('EXACT', 'ON')
			llSyncField = .T.;
				and lField(m.this.clSyncField, m.tcAliasDest);
				and loClass(m.this, 'acDataSyncVFP') && seulement si synchronisation depuis une source distante

			* Si remplacement sans clé unique dans la table destination
			IF m.tlReplace;
			 AND !this.oResult.lPCtag;
			 AND m.tnRecs = 0
			
				* Ajouter tout simplement
				SELECT (m.tcAliasDest)
				* ==============
				TRY
					APPEND FROM Dbf(m.tcAliasSrce)
					IF m.llSyncField
						REPLACE all (m.this.clSyncField) WITH .T.
					ENDIF
				CATCH TO loException
					THROW m.loException
				FINALLY
					this.oResult.nRecsAdded = _Tally
				ENDTRY
				* ==============

			* Sinon (matching sur clé primaire ou candidate)
			ELSE

				* Pour chaque enregistrement de la source
				LOCAL llReplace, llInsert, luValue, llRec, lcRec, lcRecNo, lcRecContent, llDeleted
				SELECT (m.tcAliasSrce)
				SCAN

					llRec = .T. && Résultat de l'enregistrement
					lcRec = '' && Résultat de l'enregistrement
					lcRecno = Transform(Recno(m.tcAliasSrce))
					SCATTER MEMVAR MEMO && FIELDS &lcFields
					
					* Si forçage demandé, ajuster les types des champs en mémoire
					IF m.this.lTypesForce
						FOR liField = 1 TO m.lnField
							luValue = Evaluate('m.' + laField[m.liField, 1])
							IF NOT Vartype(m.luValue, .T.) == laField[m.liField, 2]
								STORE uValue(m.luValue, laField[m.liField, 2]) TO ('m.' + laField[m.liField, 1])
							ENDIF
						ENDFOR
					ENDIF

					* ==============
					TRY

						* Si clé primaire non automatique, chercher l'enregistrement correspondant dans la table destination
						llReplace = this.oResult.lPCtag;
							AND Iif(this.oResult.lCtag;
								, Seek(Evaluate(m.lcPCexpMem), m.tcAliasDest, m.lcPCtag);
								, Seek(Evaluate(m.lcPexpMem), m.tcAliasDest, m.lcPtag))
						llInsert = NOT m.llReplace
								
						* Si l'enregistrement existe
						IF m.llReplace

							* Si comparaison sur clé candidate sans conflit de clé primaire
							llReplace = NOT (this.oResult.lCtag AND m.llPtag) OR luEqual(Evaluate(m.lcPexpMem), Evaluate(m.lcPexpDest))
							IF m.llReplace
							
								* Aligner le statut de suppression
								llDeleted = .F.
								IF Deleted(m.tcAliasSrce)
									IF NOT Deleted(m.tcAliasDest)
										DELETE IN (m.tcAliasDest)
										this.oResult.nRecsDeleted = this.oResult.nRecsDeleted + 1
										llDeleted = .T.
									ENDIF
								ELSE && NOT Deleted(m.tcAliasSrce)
									IF Deleted(m.tcAliasDest)
										RECALL IN (m.tcAliasDest)
									ENDIF
								ENDIF

								* Si vérification des modifications, vérifier la nécessité du remplacement
								IF m.this.lModCheck
									FOR liField = 1 TO m.lnField
										lcField = laField[m.liField, 1]
										llReplace = NOT luEqual(Evaluate('m.' + m.lcField), Evaluate(m.tcAliasDest + '.' + m.lcField))
										IF m.llReplace
											EXIT
										ENDIF
									NEXT
								ENDIF
								
								IF m.llReplace
									
									* Charger l'enregistrement dans la table destination
									SELECT (m.tcAliasDest)
									GATHER MEMVAR MEMO && /!\ conditionner MEMO par nouvelle valeur

									IF NOT m.llDeleted
										this.oResult.nRecsReplaced = m.this.oResult.nRecsReplaced + 1
									ENDIF
								ENDIF

							* Sinon (conflit de clé primaire)
							ELSE
								llRec = .F.
								lcRec = Textmerge(ICase(;
									m.this.cLangUser = 'fr',;
										[]; && copy-paste the 2 following lines to add another language support
										+ [Enregistrement source n° <<m.lcRecno>> : la valeur de la clé candidate <<m.lcPCexp>> (<<Trim(Transform(Evaluate(m.lcPCexpMem)))>>) existe dans la table destination,];
										+ [ mais avec une clé primaire différente : <<Evaluate(m.lcPexpMem)>> dans la table source, <<Evaluate(m.lcPexpDest)>> dans la table destination],;
										[]; && Default: English
										+ [Source record # <<m.lcRecno>>: value of candidate key <<m.lcPCexp>> (<<Trim(Transform(Evaluate(m.lcPCexpMem)))>>) does exist in destination table,];
										+ [ but with a different value of pripary key: <<Evaluate(m.lcPexpMem)>> in source table, <<Evaluate(m.lcPexpDest)>> in destination table];
									))
							ENDIF
							
						ELSE

							INSERT INTO (m.tcAliasDest) FROM MEMVAR
							this.oResult.nRecsAdded = m.this.oResult.nRecsAdded + 1
						ENDIF

					CATCH TO loException

						llRec = .F.
						lcRec = Textmerge(ICase(;
							m.this.cLangUser = 'fr',	[Erreur <<cException(m.loException)>> sur l'enregistrement source n° <<m.lcRecno>>],; && copy-paste this line to add another language support
																				[Error <<cException(m.loException)>> on source record # <<m.lcRecno>>]; && Default: English
							))
					ENDTRY
					* ==============
						
					IF m.llRec

						* Si remplacement ou insersion, indiquer que l'enregistrement a été mis à jour par synchronisation
						IF (m.llReplace OR m.llInsert) AND m.llSyncField
							REPLACE (m.this.clSyncField) WITH .T. IN (m.tcAliasDest)
						ENDIF
						
						* Exécuter la méthode "shell"
						llRec = this.TableSync_Rec(m.tcAliasDest, m.llReplace, m.this.oResult.nRecsAdded, m.this.oResult.nRecsReplaced, m.tcAliasSrce)
						IF NOT m.llRec
							lcRec = Textmerge(ICase(;
								m.this.cLangUser = 'fr',	[Erreur de la méthode shell TableSync_Rec() sur l'enregistrement source n° <<m.lcRecno>>],; && copy-paste this line to add another language support
																					[Error in shell method TableSync_Rec() on source record # <<m.lcRecno>>]; && Default: English
								))
						ENDIF
					ENDIF

					this.lResult = m.this.lResult AND m.llRec
					IF NOT m.llRec
						this.cResult = m.lcRec
						lcRecContent = cRecContent(m.tcAliasSrce)
						IF m.this.lDebug
							this.cResult = Textmerge(ICase(;
								m.this.cLangUser = 'fr',	[L'enregistrement contient : <<m.lcRecContent>>],; && copy-paste this line to add another language support
																					[Record contains: <<m.lcRecContent>>]; && Default: English
								))
						ENDIF
						this.oResult.cRecsSrceErrorNo = c2Words(this.oResult.cRecsSrceErrorNo, ',', m.lcRecno)
						this.oResult.cRecsSrceErrorContent = c2Words(;
							  this.oResult.cRecsSrceErrorContent;
							, CRLF;
							, Textmerge(ICase(;
								m.this.cLangUser = 'fr',	[Contenu de l'enregistrement n° <<m.lcRecno>> : <<m.lcRecContent>>],; && copy-paste this line to add another language support
																					[Record # <<m.lcRecno>> contains: <<m.lcRecContent>>]; && Default: English
								));
							)
						this.oResult.nRecsSrceError = this.oResult.nRecsSrceError + 1
					ENDIF
					
					IF m.tnRecs > 0 AND this.oResult.nRecsAdded >= m.tnRecs
						EXIT
					ENDIF
				ENDSCAN
			ENDIF	

			* Restituer le résultat final
			LOCAL lnIgnored, lcResult
			lnIgnored = this.oResult.nRecsSrce - m.this.oResult.nRecsAdded - m.this.oResult.nRecsReplaced - this.oResult.nRecsDeleted - m.this.oResult.nRecsSrceError
			lcResult = Iif(m.this.oResult.lPCtag;
				, Textmerge(ICase(;
								m.this.cLangUser = 'fr',	[, <<m.this.oResult.nRecsReplaced>> remplacés, <<m.this.oResult.nRecsSrceError>> avec erreur],; && copy-paste this line to add another language support
																					[, <<m.this.oResult.nRecsReplaced>> replaced, <<m.this.oResult.nRecsSrceError>> with error]; && Default: English
								));
				, '';
				)
			lcResult = Textmerge(ICase(;
				m.this.cLangUser = 'fr',	[Table source : '<<Dbf(m.tcAliasSrce)>>' - <<this.oResult.nRecsSrce>> enregistrements, <<m.lnIgnored>> ignorés, <<m.this.oResult.nRecsAdded>> ajoutés<<m.lcResult>>],; && copy-paste this line to add another language support
																	[Source table: '<<Dbf(m.tcAliasSrce)>>' - <<this.oResult.nRecsSrce>> records, <<m.lnIgnored>> ignored, <<m.this.oResult.nRecsAdded>> added<<m.lcResult>>]; && Default: English
				))
			this.cResult =  Iif(m.this.lResult, m.this.cResult + CRLF, '') + m.lcResult
		ELSE
			this.cResult = Textmerge(ICase(;
				m.this.cLangUser = 'fr',	[Impossible d'ouvrir la table destination <<cLitteral(Dbf(m.tcAliasDest))>> en exclusif pour la vider.],; && copy-paste this line to add another language support
																	[Could not gain exclusive access on destination table <<cLitteral(Dbf(m.tcAliasDest))>> in order to zap it.]; && Default: English
				))
		ENDIF
	ENDIF

	RETURN m.this.lResult

	*---------------------------------------
	PROTECTED PROCEDURE TableSync_Rec && Exécuté à chaque enregistrement
	LPARAMETERS ;
		tcAliasDest,; && Alias de la table destination
		tlReplaced,; && L'enregistrement a été remplacé
		tnAdded,; && Nombre d'enregistrements ajoutés
		tnReplaced,; && Nombre d'enregistrements remplacés
		tcAliasSrce && Alias de la table source
		
	&& Implémenter en sous-classe

* ========================================
ENDDEFINE && CLASS abDataSyncVFP
* ========================================

* -------------------------------
procedure tModUpdate && {en} updates record's last modification date-time {fr} Met à jour la date&heure de dernière modification de l'enregistrement
&& {en} required by the a*DataSyncVFP system
&& {en} append to the record rule of each table as illustrated below ...
&& {en} /!\ record rule does not fire when record is deleted
&& {fr} nécessaire au système a*DataSyncVFP
&& {fr} ajouter à la fin de la règle d'enregistrement de chaque table comme indiqué ci-dessous ...
&& {fr} /!\ la règle d'enregistrement ne se déclenche pas lorsque l'enregistrement est supprimé

&& ... [set |,] check xxx() and yyy() and tModUpdate()
lparameters tModField, lSyncField

tModField  = Evl(m.tModField, 'tMOD') && FoxInCloud standard
lSyncField = Evl(m.lSyncField, 'lSYNC') && FoxInCloud standard

* {en} Set record's last modification date-time
* {fr} Régler la date et heure de dernière modification
IF .T.;
 AND !(lTrue(m.pltModKeep)); && pltModKeep : {en} Inhibit record's last modification date-time modification [see abDataSyncVFP.tablesync_()] {fr} Inhiber la mise à jour automatique de la date de modification [cf. abDataSyncVFP.tablesync_()]
 AND ! Empty(Field(m.tModField)) && {en} Field exists in table {fr} Le champ existe dans la table
	replace (m.tModField) with Datetime() && {en} In a table rule, Alias() == alias of the table owning the rule	{fr} dans une règle de table, Alias() == alias de la table dont la règle est exécutée
endif

* {en} Set record was not modified through synchronization
* {fr} Indiquer que l'enregistrement n'a pas été modifié par synchronisation
IF .T.;
 AND !(lTrue(m.plSync)); && plSync : {en} Records are being synchronized [see abDataSyncVFP.tablesync_()] {fr} synchronisation en cours  [cf. abDataSyncVFP.tablesync_()]
 AND ! Empty(Field(m.lSyncField)) && {en} Field exists in table {fr} Le champ existe dans la table
	replace (m.lSyncField) with .F. && {en} In a table rule, Alias() == alias of the table owning the rule	{fr} dans une règle de table, Alias() == alias de la table dont la règle est exécutée
endif

endproc

* =============================================
function cDBsetPropOfTableFields
lparameters tuTable, tcProp

tcProp = Evl(m.tcProp, 'Comment')

local result, cAlias, cDB, lAlias, cTable;
, oSetDB as abSet of abDev.prg;
, laField[1], nField, iField, cField;

result = ''
cAlias = cAlias(m.tuTable, @m.lAlias)
cDB = CursorGetProp("Database", m.cAlias)

if .T.;
 and Used(m.cAlias);
 and !Empty(m.cDB);
 and lInList(m.tcProp, 'Caption, Comment, DefaultValue, DisplayClass, DisplayClassLibrary, Format, InputMask, RuleExpression, RuleText')

	oSetDB = abSet('DATABASE', m.cDB)

	cTable = Proper(CursorGetProp("SourceName", m.cAlias))
	nField = AFields(laField, m.cAlias)
	Asort(laField, 1)
	for iField = 1 to m.nField

		cField = Textmerge("<<m.cTable>>.<<Lower(m.laField[m.iField, 1])>>")
		result = m.result + Textmerge("DBSetProp('<<m.cField>>', 'FIELD', '<<m.tcProp>>', [<<DBgetProp(m.cField, 'FIELD', m.tcProp)>>])") + CRLF
	endfor
	if m.lAlias
		use in (m.cAlias)
	endif
endif
return m.result
endfunc

* =============================================
function cCollationOfCodePage
lparameters uCodePage
uCodePage = Iif(Empty(Pcount()), Alias(), m.uCodePage)
uCodePage = Iif(Vartype(m.uCodePage) == 'C' and Used(m.uCodePage), Cpdbf(m.uCodePage), m.uCodePage)
local cLangUser
cLangUser = cLangUser()
return Upper(ICase(;
	!ga_Type_IsInteger(m.uCodePage),;
		'machine',;
	m.uCodePage = 874,; && Thai Windows
		'thai',;
	m.uCodePage = 895,; && Kamenicky (Czech) MS-DOS
		'czech',;
	m.uCodePage = 932,; && Japanese Windows
		'japanese',;
	m.uCodePage = 936,; && Chinese Simplified (PRC, Singapore) Windows
		'pinyin',;
	m.uCodePage = 949,; && Korean Windows
		'korean',;
	m.uCodePage = 950,; && Traditional Chinese (Hong Kong SAR, Taiwan) Windows
		'stroke',; && Simplified and traditional Chinese 
	m.uCodePage = 1250 and m.cLangUser = 'pl',; && Eastern European Windows
		'polish',;
	m.uCodePage = 1250 and m.cLangUser = 'sk',; && Eastern European Windows
		'slovak',;
	m.uCodePage = 1250 and m.cLangUser = 'cs',; && Eastern European Windows
		'czech',;
	m.uCodePage = 1251,; && Russian Windows
		'russian',;
	m.uCodePage = 1252 and m.cLangUser = 'sv',; && Windows ANSI
		'swefin',;
	m.uCodePage = 1252 and m.cLangUser = 'nl',; && Windows ANSI
		'dutsch',;
	m.uCodePage = 1252,; && Windows ANSI
		'general',;
	m.uCodePage = 1253,; && Greek Windows
		'greek',;
	m.uCodePage = 1254,; && Turkish Windows
		'turkish',;
	m.uCodePage = 1255,; && Hebrew Windows
		'hebrew',;
	m.uCodePage = 1256,; && Arabic Windows
		'arabic',;
		'machine';
	))
endfunc

 

