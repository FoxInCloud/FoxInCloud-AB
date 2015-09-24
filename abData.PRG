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
function cTableAddress	&& Adresse complète d'une table d'après son alias
lparameters tcAlias && [alias()] Alias d'ouverture de la table

local llFullPathOff, lcResult

llFullPathOff = set('FullPath') == 'OFF'
if m.llFullPathOff
	set fullpath on
endif

lcResult = icase(;
	vartype(m.tcAlias) == 'C' and used(m.tcAlias),;
		dbf(m.tcAlias),;
	used(),;
		dbf(),;
		'';
	)

if m.llFullPathOff
	set fullpath off
endif

return m.lcResult

* ========================================
function JustField && Champ et alias d'une chaîne de type "[alias.]field" && note: JustExt("field") retourne ""
lparameters ;
	tcChain,; && Chaîne présumée de type 'alias.field' ou 'field'
	tcAlias && @ Alias en retour

local llResult, lcResult && Field
store '' to tcAlias, lcResult

llResult = vartype(m.tcChain) == 'C'
assert m.llResult message cAssertMsg(textmerge([Spécification de chaîne invalide : <<cLitteral(m.tcChain)>>]))
if m.llResult

	tcChain = upper(strtran(chrtran(alltrim(m.tcChain), ' ', ''), '->', '.'))

	if occurs([.], m.tcChain) <= 1 and lenc(m.tcChain) < 257 && 2*128 + 1

		if [.] $ m.tcChain
			tcAlias = juststem(m.tcChain)
			lcResult = justext(m.tcChain)
*!*					2015-05-25 bouffe du temps inutilement
*!*					IF NOT (lVFPName(m.tcAlias) AND lVFPName(m.lcResult))
*!*						STORE '' TO m.tcAlias, m.lcResult
*!*					ENDIF
		else
*!*					lcResult = Iif(lVFPName(m.tcChain), m.tcChain, '')
			lcResult = m.tcChain
		endif
	endif
endif

return m.lcResult

* ========================================
function JustField && Champ et alias d'une chaîne de type "[alias.]field" && note: JustExt("field") retourne ""
lparameters ;
	tcChain,; && Chaîne présumée de type 'alias.field' ou 'field'
	tcAlias && @ [''] Alias en retour

tcAlias = '' && important

local lcChain as string

lcChain = strtran(chrtran(m.tcChain, ' ', ''), '->', '.')

return icase(;
	occurs([.], m.lcChain) > 1,;
		'',;
	.t.;
	 and empty(occurs([.], m.lcChain));
	 and chrtran(m.lcChain, VFPOPSEPCARS, '') == m.lcChain;
	 and lVFPName(m.lcChain),;
		m.lcChain,;
	.t.;
	 and lenc(m.lcChain) < 257; && 2*128 + 1
	 and chrtran(m.lcChain, VFPOPCARS, '') == m.lcChain;
	 and lVFPName(juststem(m.lcChain));
	 and lVFPName(justext(m.lcChain));
	 and varSet(@m.tcAlias, juststem(m.lcChain)),;
	 	justext(m.lcChain),;
	  '';
	 )
endfunc

* ---------------------
procedure JustField_Test && Test unitaire de JustField()

local loTest as abUnitTest of abDev.prg, lcChain, lcAlias
loTest = newobject('abUnitTest', 'abDev.prg')

lcChain = 'toto.tutu.titi'
loTest.Test('', m.lcChain, @m.lcAlias)

lcChain = 'toto.tutu'
loTest.Test('tutu', m.lcChain, @m.lcAlias)
loTest.assert('toto', m.lcAlias)

lcChain = 'tété.tutu'
loTest.Test('tutu', m.lcChain, @m.lcAlias)
loTest.assert('tété', m.lcAlias)

lcChain = 'evl(tété.tutu, "")'
loTest.Test('', m.lcChain, @m.lcAlias)

return loTest.Result()


* ========================================
function JustTable && Table dans une chaîne de type "Base de données!table"
lparameters ;
	tcChain,; && Chaîne présumée de type "Base de données!table"
	tcDBC && @ Base de données en retour
local lnExclam, llResult, lcResult && Table ou toute la chaîne source si elle ne comporte aucun '!'
store '' to lcResult, tcDBC

llResult = vartype(m.tcChain) == 'C' and not empty(m.tcChain)
assert m.llResult message cAssertMsg(textmerge([Spécification de chaîne invalide : <<cLitteral(m.tcChain)>>]))
if m.llResult

	lnExclam = atc('!', m.tcChain)
	if m.lnExclam > 0

		lcResult = alltrim(substr(m.tcChain, m.lnExclam+1))
		tcDBC = alltrim(substr(m.tcChain, 1, m.lnExclam-1))
	else
		lcResult = alltrim(m.tcChain)
	endif
endif

return m.lcResult

* ---------------------
procedure JustTable_Test && Teste JustTable()

local loTest as abUnitTest of abDev.prg
loTest = newobject('abUnitTest', 'abDev.prg')

loTest.Test('tata', ' tata ')
loTest.Test('tata', ' C:\toto\tutu.xls ! tata')

return loTest.Result()

* =================================================
function abSelect && Change la zone de travail Select() et rétablit à destruction
lparameters ;
	tuSelect,; && [0] Zone de travail / alias à sélectionner, ou table à ouvrir et sélectionner
	tlKeepOpened,; && [.F.] Si la table est ouverte, laisser ouverte en sortie
	tcError && [''] @ Erreur éventuelle

return createobject('abSelect', m.tuSelect, m.tlKeepOpened, @m.tcError)

* =================================================
define class abSelect as GA_LIGHTWEIGHT_CLASS && Change la zone de travail Select() et rétablit à destruction
* =================================================

protected nSelect,; && Zone de travail initiale
	lTable,; && Table communiquée
	cAlias,; && Alias sous lequel la table est ouverte
	lOpened,; && Table ouverte
	lKeepOpened && Si table ouverte, laisser ouverte

nSelect = .f.
cAlias = ''
lTable = .f.
lOpened = .f.
lKeepOpened = .f.

* ---------------------------------------------------
procedure init && Change la zone de travail
lparameters ;
	tuSelect,; && [0] Zone de travail / alias à sélectionner, ou table à ouvrir et sélectionner
	tlKeepOpened,; && [.F.] Si la table est ouverte, laisser ouverte en sortie
	tcError && [''] @ Erreur éventuelle
tuSelect = evl(m.tuSelect, 0)

local lcType, lcTable, llOpened, llResult

lcType = vartype(m.tuSelect)
llResult = m.lcType == 'C'
if m.llResult

	llResult = used(m.tuSelect)
	if not m.llResult

		lcTable = iif(vartype(m.tuSelect) == 'C' and empty(justext(m.tuSelect)), forceext(m.tuSelect, 'dbf'), m.tuSelect)

		this.lTable = .f.;
		 or (not empty(dbc()) and indbc(m.tuSelect, "TABLE"));
		 or file(m.lcTable);
		 or file(cDBCTableAddr(m.tuSelect))

		llResult = m.this.lTable
	endif
endif
llResult = m.llResult or m.lcType == 'N' and cast(m.tuSelect as I) = m.tuSelect and between(m.tuSelect, 0, 32767)
tcError = iif(m.llResult, '', textmerge([Invalid table, alias or work area <<cLitteral(m.tuSelect)>>]))
assert m.llResult message cAssertMsg(m.tcError)
if m.llResult

* Si référence à une table fournie
	if m.this.lTable
		this.cAlias = cAlias(m.tuSelect, @m.llOpened,, @m.tcError)
		llResult = used(m.this.cAlias)
		if m.llResult
			tuSelect = m.this.cAlias
			this.lOpened = m.llOpened
			this.lKeepOpened = lTrue(m.tlKeepOpened)
		endif
	endif

	if m.llResult
		this.nSelect = select(0)
		select (m.tuSelect)
	endif
endif

tcError = iif(m.llResult, '', m.tcError)

return m.llResult

* ---------------------------------------------------
procedure destroy && Rétablit la zone de travail initiale et referme la table si this.Init() l'a ouverte

select (m.this.nSelect)

if m.this.lOpened and not m.this.lKeepOpened
	use in select(m.this.cAlias)
endif

* =================================================
enddefine && CLASS abSelect
* =================================================

* ========================================
function cDBCTableAddr && Adresse d'une table dans un DBC
lparameters tcDBCTable && 'DBC!Table'

local lcTable, lcDBC, loDBC as abSet, llDBC, llResult, lcResult

lcResult = ''
llResult = vartype(m.tcDBCTable) == 'C' and '!' $ m.tcDBCTable
assert m.llResult message cAssertMsg(textmerge([Paramètre invalide : <<cLitteral(m.tcDBCTable)>>]))
if m.llResult

	lcTable = JustTable(m.tcDBCTable, @m.lcDBC)
	loDBC = abSet('DATABASE', set("Database"),,,.t.)
	if dbused(m.lcDBC)
		set database to (m.lcDBC)
	else
		lcDBC = forceext(m.lcDBC, 'dbc')
		llResult = file(m.lcDBC)
		assert m.llResult message cAssertMsg(textmerge([La base de données '<<m.lcDBC>>' est introuvable]))
		if m.llResult
			open database (m.lcDBC) shared
			llDBC = .t.
		endif
	endif
	if m.llResult

		llResult = indbc(m.lcTable, "TABLE")
		assert m.llResult message cAssertMsg(textmerge([La table '<<m.lcTable>>' est introuvable dans le DBC '<<m.lcDBC>>']))
		if m.llResult
			lcResult = cFileCased(addbs(justpath(dbc())) + dbgetprop(m.lcTable, "TABLE", "Path"), .t.)
		endif
		if m.llDBC
			close databases
		endif
	endif
endif

return m.lcResult

* ========================================
function cAlias && Alias d'une table
lparameters ;
	tuTable,; && [Alias()] Table : Alias | Zone | Adresse | [DB!]Table
	tlOpened,; && @ La table a été ouverte, penser à la refermer
	tlExclusive,; && [.F.] Ouvrir la table en exclusif
	tcError,; && @ [''] Erreur éventuelle
	tcAlias; && [default] Alias sous lequel ouvrir la table

tlOpened = .f.
tcAlias = upper(iif(ga_Type_IsChar(m.tcAlias, .t.) and lVFPName(m.tcAlias), m.tcAlias, ''))

local lcResult as string; && Alias sous lequel la table est ouverte
, lcType;
, lcTable, llTable;
, lcDBC, loDBC as abSet, llDBC;
, lnSelect; && pas de abSelect() pour optimiser
, loException as exception;
, llAlias as Boolean;

lcResult = ''

lcType = vartype(m.tuTable)
tuTable = iif(m.lcType == 'C', upper(alltrim(m.tuTable)), m.tuTable)
llAlias = ga_Type_IsChar(m.tcAlias, .t.)

do case

case empty(m.tuTable) && paramètre vide, alias courant
	lcResult = alias()

case m.lcType == 'N'
	lcResult = alias(m.tuTable)

case !m.lcType == 'C'

case used(m.tuTable); && Alias existant, retourner
 and (!m.llAlias or upper(m.tuTable) == m.tcAlias)
	lcResult = m.tuTable

otherwise && Sinon (adresse de table sur le disque ou dans une base de données)

	do case

	case '!' $ m.tuTable && DB!Table
		lcTable = cDBCTableAddr(m.tuTable)
		store file(m.lcTable) to llTable, llDBC

	case not empty(dbc()) and indbc(m.tuTable, "TABLE") && Table d'une base de données
		lcTable = addbs(justpath(dbc())) + dbgetprop(m.tuTable, "TABLE", "Path")
		store .t. to llTable, llDBC

	otherwise && Adresse disque
		lcTable = iif(empty(justext(m.tuTable)), forceext(m.tuTable, 'dbf'), m.tuTable)
		llTable = iif(directory(justpath(m.lcTable)), lFile(m.lcTable), file(m.lcTable))
		if not m.llTable
			lcTable = fullpath(m.lcTable)
			llTable = file(m.lcTable)
		endif

	endcase
	if m.llTable && la table existe

* Si la table n'est pas ouverte
		lcResult = cAliasUsed(m.lcTable)
		if empty(m.lcResult) or (m.llAlias and !m.lcResult == m.tcAlias)

* Ouvrir la table
			lcTable = iif(m.llDBC, m.tuTable, m.lcTable)
			lnSelect = select(0)
			tcAlias = iif(m.llAlias, iif(empty(m.lcResult), '', 'again ') + 'alias ' + m.tcAlias, '')
			select 0
			try
				use (m.lcTable) shared &tcAlias && shared added 20/06/13
				lcResult = alias()
				tlOpened = .t.
			catch to loException
				lcResult = cException(m.loException)
				assert .f. message cAssertMsg(textmerge([Impossible d'ouvrir la table '<<m.lcTable>>' : <<m.lcResult>>]))
				cResultAdd(@m.tcError, m.lcResult)
			endtry
			select (m.lnSelect)
		endif
	else
		cResultAdd(@m.tcError, textmerge(icase(;
			cLangUser() = 'fr',	[La table <<cL(m.tuTable)>> est introuvable],; && copy-paste this line to add another language support
													[Table <<cL(m.tuTable)>> can't be found]; && Default: English
			)))
	endif
endcase

if used(m.lcResult) and lTrue(m.tlExclusive)
	lcResult = ExclusiveForce(m.lcResult)
endif

return m.lcResult

*========================================
function nBufferDirty && {fr} nombre d'enregistrements modifiés dans le tampon d'un alias
lparameters ;
  tcAlias; && [Alias()]
, tlAll; && [.F.] all modified even if filtered

local nBufferDirty as integer;
, loRecno as abRecno of abData.prg;
, loFilter as abFilter of abData.prg;
, loOrder as abOrder of abData.prg;
, liRecno as integer;

nBufferDirty = 0

do case
case !lBufferDirty(@m.tcAlias)
case inlist(cursorgetprop("Buffering", m.tcAlias), 2, 3) && Row buffering
	nBufferDirty = 1
otherwise

	loRecno = abRecno(m.tcAlias)
	loFilter = iif(lTrue(m.tlAll), abFilter(m.tcAlias), .null.)
	loOrder = abOrder(, m.tcAlias)
	liRecno = 0
	do while .t.
		liRecno = getnextmodified(m.liRecno, m.tcAlias, .t.)
		if empty(m.liRecno)
			exit
		endif
		nBufferDirty = m.nBufferDirty + 1
	enddo
endcase

return m.nBufferDirty
endfunc

*========================================
function lBufferDirty as Boolean && {fr} Le tampon d'un alias est modifié
lparameters tcAlias && [Alias()]
tcAlias = evl(m.tcAlias, alias())

local lBufferDirty as Boolean;
, lnRecCount;
, liRecno;
, lcFldState;
, loFilter as abFilter of abData.prg;
, loOrder as abOrder of abData.prg;

do case

case .f.;
 or !used(m.tcAlias);
 or cursorgetprop("Buffering", m.tcAlias) = 1;
 or !varSet(@m.lnRecCount, reccount(m.tcAlias));
 or empty(m.lnRecCount);
 or !varSet(@m.liRecno, Recno_(m.tcAlias));
 or !varSet(@m.lBufferDirty, m.liRecno < 0); && added record
 or m.lBufferDirty;
 or !(between(m.liRecno, 1, m.lnRecCount) or eof(m.tcAlias));
 or .f.

case varSet(@m.lcFldState, getfldstate(-1, m.tcAlias));
 and inlist(cursorgetprop("Buffering", m.tcAlias), 2, 3) && Row buffering

	lBufferDirty = !empty(chrtran(nvl(m.lcFldState, ''); && .null. if Eof(m.tcAlias)
		, '1';
		, '';
		))

case !isnull(m.lcFldState); && .null. if Eof(m.tcAlias)
 and !empty(chrtran(m.lcFldState, '1', ''))

	lBufferDirty = .t. && Table buffering, current record modified

otherwise && Table buffering

	loFilter = abFilter(m.tcAlias)
	loOrder = abOrder(, m.tcAlias)
	lBufferDirty = !empty(getnextmodified(0, m.tcAlias, .t.))
	RecnoSet(m.liRecno, m.tcAlias)

endcase

return m.lBufferDirty
endfunc

* -----------------------------------------------------------------
procedure lBufferDirty_Test && lBufferDirty() unit test

local loTest as lBufferDirty_Test of abData.prg, liRecno as integer
loTest = newobject('lBufferDirty_Test', 'abData.prg')
with m.loTest as lBufferDirty_Test of abData.prg
	.Test(.f.) && 1

.use
	.Test(.f.) && 2

	.insert
	.Test(.f.) && 3

.setBuffering(3)

	.Test(.f.) && 4

	.update
	.Test(.t.) && 5

	.skip && Eof()
	.Test(.f.) && 6

	.skip(-1)
	.update
	.Test(.t.) && 7

	.tableupdate
	.Test(.f.) && 8

.setBuffering(5)

	.insert
	liRecno = .recno()
	.Test(.t.) && 9
	.assert(m.liRecno, .recno())

	.skip(-1)
	liRecno = .recno()
	.Test(.t.) && 10
	.assert(m.liRecno, .recno())

	.tableupdate(.t.)
	.update
	.Test(.t.) && 11

.use(.t.)
	.Test(.f.) && 12

endwith

return m.loTest.Result()

* ------------------------------
define class lBufferDirty_Test as abUnitTest of abDev.prg
	procedure use(in)
		if m.in
			use in select('lBufferDirty_Test')
		else
			create cursor lBufferDirty_Test (lBufferDirty_Test C(10))
		endif
	procedure insert
		insert into lBufferDirty_Test values ('')
	procedure setBuffering(setBuffering)
		cursorsetprop("Buffering", evl(m.setBuffering, 1), 'lBufferDirty_Test')
	procedure update
		replace in lBufferDirty_Test lBufferDirty_Test with 'lBufferDirty_Test'
	procedure skip(skip)
		skip evl(m.Skip, 1) in lBufferDirty_Test
	function tablerevert(all)
		return tablerevert(m.all, 'lBufferDirty_Test')
	function tableupdate(all)
		return tableupdate(m.all, .f., 'lBufferDirty_Test')
	function recno
		return recno('lBufferDirty_Test')
	enddefine

* ========================================
function lBufferInsert && Un alias tamponné a (au moins) un enregistrement ajouté
lparameters tcAlias && [courant] Alias à examiner
tcAlias = evl(m.tcAlias, alias())

local success as Boolean;
, oRelation as abRelationSrceOff of abData.prg;
, oFilter as abFilter of abData.prg;
, oOrder as abOrder of abData.prg;
, oRecno as abRecno of abData.prg;

do case

case .f.;
 or !used(m.tcAlias);
 or cursorgetprop("Buffering", m.tcAlias) = 1
	return .f.

case recno(m.tcAlias) < 0 && Recno() returns negative numbers for records appended in a table buffer
	return .t.

case inlist(cursorgetprop("Buffering", m.tcAlias), 2, 3) && row buffering
	return inlist(cast(left(nvl(getfldstate(-1, m.tcAlias), ''), 1) as I), 3, 4)

otherwise && InList(CursorGetProp("Buffering", m.tcAlias), 4, 5) && table buffering

	oRelation = abRelationSrceOff(m.tcAlias)
	oFilter = abFilter(m.tcAlias)
	oOrder = abOrder(m.tcAlias)
	oRecno = abRecno(m.tcAlias)

	go bottom in m.tcAlias
	success = recno(m.tcAlias) < 0 && Recno() returns negative numbers for records appended in a table buffer
	release oOrder, oFilter, oRecno, oRelation
	return m.success

endcase
endfunc

* ========================================
function oAlias && {fr} Caractéristiques d'un alias
lparameters ;
	tcAlias,; && [Alias()] Alias à analyser
	tcResult && @ Résultat

return createobject('oAlias', m.tcAlias, @m.tcResult)

* ========================================
define class oAlias as relation && {en} Alias settings {fr} Caractéristiques d'un alias
* ========================================
&& as GA_LIGHTWEIGHT_CLASS (GA_LIGHTWEIGHT_CLASS protects this.cResult)

cDBF = .null.
cAlias = .null.
lReadonly = .null.
lExclusive = .null.
cOrder = .null.
cFilter = .null.
cSetKey1 = .null.
cSetKey2 = .null.
iBuffering = .null.
iRecno = .null.
dimension aRelationSrce[1], aRelationTrgt[1]

cResult = ''

* ---------------------------------------------------
procedure init && Mémorise les attributs d'un Alias
lparameters ;
	tcAlias,; && [Alias()] Alias à analyser
	tcResult && @ Résultat
tcAlias = evl(m.tcAlias, alias())
tcResult = evl(m.tcResult, '')

local loSelect as abSelect of abData.prg;
, laRelation[1]

if used(m.tcAlias)

	loSelect = abSelect(m.tcAlias)
	with m.this as oAlias of adata.prg
		.cDBF = fullpath(dbf())
		.cAlias = m.tcAlias
		.lReadonly = isreadonly()
		.lExclusive = isexclusive()
		.cFilter = filter()
		.cOrder = order()
		.cSetKey1 = set("Key", 1)
		.cSetKey2 = set("Key", 2)
		.iBuffering = cursorgetprop("Buffering")
		.iRecno = Recno_()
		if aRelationSrce(@m.laRelation) > 0
			dimension .aRelationSrce[Alen(laRelation, 1), Alen(laRelation, 2)]
			acopy(m.laRelation, .aRelationSrce)
		endif
		if aRelationTrgt(@m.laRelation) > 0
			dimension .aRelationTrgt[2]
			acopy(m.laRelation, .aRelationTrgt)
		endif
	endwith
else
	tcResult = textmerge([oAlias.Init() - ] + icase(;
		cLangUser() = 'fr',	[L'alias '<<m.tcAlias>>' est introuvable.],; && copy-paste this line to add another language support
												[Alias '<<m.tcAlias>>' can't be found.]; && Default: English
		))
	return .f. && object is not created
endif

* ---------------------------------------------------
procedure Swap && Ouvre une table sous l'alias initial et lui applique les mêmes attributs
lparameters ;
	tcDBF,; && table
	tcResult && @ Résultat

local loSelect as abSelect of abData.prg;
, loException as exception;
, lcValue1, lcValue2, liValue;
, llResult

with m.this as oAlias of abData.prg

	if file(m.tcDBF)

		llResult = used(.cAlias) and .cDBF == fullpath(m.tcDBF) && fichier inchangé, inutile de changer
		if not m.llResult

			try

* Fermer l'alias courant
				if lBufferDirty(.cAlias)
					liValue = tablerevert(.t., .cAlias)
					.cResult = textmerge(icase(;
						cLangUser() = 'fr',	[Le tampon de <<.cAlias>> a été vidé, soit <<m.liValue>> enregistrement(s)],; && copy-paste this line to add another language support
																[Buffered data of <<.cAlias>> were discarded, <<m.liValue>> record(s)]; && Default: English
						))
				endif
				use in select(.cAlias)

* Ouvrir la nouvelle table sous le même alias
				lcValue1 = iif(.lExclusive, ' EXCLUSIVE', ' SHARED')
				lcValue2 = iif(.lReadonly, ' NOUPDATE', '')
				use (m.tcDBF) in 0 alias (.cAlias) &lcValue1 &lcValue2
				loSelect = abSelect(.cAlias)

				llResult = lTableExpr(.cFilter)
				if m.llResult

					lcValue1 = .cFilter
					set filter to &lcValue1

					llResult = empty(.cOrder) or lTag(.cOrder)
					if m.llResult

						set order to (.cOrder)
						if not empty(.cSetKey1)
							lcValue1 = .cSetKey1
							if empty(.cSetKey2)
								set key to &lcValue1
							else
								lcValue2 = .cSetKey2
								set key to range &lcValue1, &lcValue2
							endif
						endif
						if alen(.aRelationSrce) > 1
							for liValue = 1 to alen(.aRelationSrce, 1)
								lcValue1 = .aRelationSrce[m.liValue, 1]
								lcValue2 = .aRelationSrce[m.liValue, 2]
								llResult = lTableExpr(m.lcValue1)
								if m.llResult
									llResult = used(m.lcValue2)
									if m.llResult
										set relation to &lcValue1 into (m.lcValue2)
									else
										.cResult = textmerge(icase(;
											cLangUser() = 'fr',	[L'alias '<<m.lcValue2>>', cible de relation de '<<.cAlias>>', est introuvable],; && copy-paste this line to add another language support
																					[Alias '<<m.lcValue2>>', relation target of '<<.cAlias>>', can't be found]; && Default: English
											))
									endif
								else
									.cResult = textmerge(icase(;
										cLangUser() = 'fr',	[L'expression relationnelle '<<m.lcValue1>>' est invalide sur la table '<<m.tcDBF>>'],; && copy-paste this line to add another language support
																				[Relational expression '<<m.lcValue1>>' is invalid on table '<<m.tcDBF>>']; && Default: English
										))
								endif
								if not m.llResult
									exit
								endif
							endfor
						endif
						if m.llResult and alen(.aRelationTrgt) > 1
							lcValue1 = .aRelationTrgt[1] && Relational expression
							lcValue2 = .aRelationTrgt[2] && Source Alias
							set relation to &lcValue1 into (.cAlias) in (m.lcValue2)
						endif
					else
						.cResult = textmerge(icase(;
							cLangUser() = 'fr',	[L'index '<<.cOrder>>' est introuvable dans la table '<<m.tcDBF>>'],; && copy-paste this line to add another language support
																	[Index tagged '<<.cOrder>>' can't be found in table '<<m.tcDBF>>']; && Default: English
							))
					endif
				else
					.cResult = textmerge(icase(;
						cLangUser() = 'fr',	[L'expression de filtre '<<.cFilter>>' est invalide sur la table '<<m.tcDBF>>'],; && copy-paste this line to add another language support
																[Filter expression '<<.cFilter>>' is invalid on table '<<m.tcDBF>>']; && Default: English
						))
				endif
				if m.llResult
					cursorsetprop("Buffering", .iBuffering)
					RecnoSet(.iRecno)
				else
					use in select(.cAlias)
				endif
			catch to loException
				llResult = .f.
				.cResult = cException(m.loException)
			endtry
		endif
	else
		.cResult = textmerge(icase(;
			cLangUser() = 'fr',	[Le fichier '<<m.tcDBF>>' est introuvable.],; && copy-paste this line to add another language support
													[File '<<m.tcDBF>>' can't be found.]; && Default: English
			))
	endif
	tcResult = iif(m.llResult, m.tcResult, .cResult)
endwith

return m.llResult

* ========================================
enddefine && CLASS oAlias
* ========================================

* ========================================
function cAliasUsed && Alias sous lequel une table est ouverte (le premier si plusieurs)
lparameters ;
	tcTable,; && Adresse de la table
	tlExclusive && @ [.F.] La table est ouverte en exclusif
tlExclusive = .f.

local lcResult; && Alias
, laUsed[1]

lcResult = ''

* Si la table existe et est ouverte
if file(m.tcTable) and aused(laUsed, .null., m.tcTable) > 0

	lcResult = laUsed[1]
	tlExclusive = isexclusive(m.lcResult)
endif

return m.lcResult

* ========================================
function aUsedDBF && Table *.DBF couramment used() dans cette session de VFP && /!\ d'autres sessions peuvent les utiliser en réseau ...
lparameters taUsed && @ Fichiers *.DBF couramment used()
external array taUsed

local lnDS_, liDS, laDS[1], lnDS, laResult[1], liResult, lcResult, lnResult

lnResult = 0
if aClear(@m.taUsed)

	lnDS_ = set("Datasession")
	for liDS = 1 to asessions(laDS) && don't know how to get the number of datasessions currently open

		lnDS = m.laDS[m.liDS]

		try

			aClear(@m.laResult)
			lnResult = aused(m.laResult, m.lnDS)
			if m.lnResult > 0

				set datasession to m.lnDS && pour dbf()
				aColDel(@m.laResult, 2)
				dimension laResult[m.lnResult]
				for liResult = 1 to m.lnResult

					lcResult = cFileCased(dbf(laResult[m.liResult]), .t.)
					if empty(m.lcResult)
						adel(m.laResult, m.liResult)
						lnResult = m.lnResult - 1
					else
						laResult[m.liResult] = m.lcResult
					endif
				endfor
				if m.lnResult > 0
					dimension laResult[m.lnResult]
					lnResult = aAppend(@m.taUsed, @m.laResult, .t.)
				endif
			endif
		catch
		endtry
	endfor
	set datasession to m.lnDS_

	lnResult = iif(laEmpty(@m.taUsed), 0, alen(m.taUsed))
endif

return m.lnResult

* ========================================
procedure AliasReuse && Rouvre un alias dans un autre mode
lparameters ;
	tcAlias,; && Alias
	tcMode,; && [''] 'Exclusive' | 'Shared' | 'Noupdate' | '' (=Set("EXCLUSIVE"))
	tlAgain,; && [.F.] AGAIN
	tcAliasNew && [m.tcAlias] Nouvel Alias

local lcTable, lcOrder, lcFilter, lcField, lcFields, lcMode, laUsed[1], llAgain, lcAgain;
	, lnSelect, loException as exception;
	, llResult

tcAlias = upper(evl(m.tcAlias, ''))
if used(m.tcAlias)

	tcAliasNew = upper(evl(m.tcAliasNew, m.tcAlias))
	llResult = m.tcAlias == m.tcAliasNew or not used(m.tcAliasNew)
	assert m.llResult message cAssertMsg(textmerge([Impossible de réouvrir l'alias '<<m.tcAlias>>' sous l'alias '<<m.tcAliasNew>>' car il est déjà utilisé]))
	if m.llResult

		tcMode = upper(left(ltrim(evl(m.tcMode, '')), 1))
		tlAgain = iif(lTrue(m.tlAgain) and not m.tcMode == 'E', 'AGAIN', '')
		tcMode = icase(m.tcMode == 'E', 'EXCLUSIVE', m.tcMode == 'S', 'SHARED', m.tcMode == 'R', 'READONLY', '')

		lnSelect = select(0)
		select (m.tcAlias)

* Mémoriser l'état de l'alias
		lcTable = cTableAddress()
		lcOrder = iif(empty(order()), '', 'ORDER ' + order())
		lcFilter = filter()
		lcField = set("Fields")
		lcFields = set("Fields", 1)

		lcMode = icase(isexclusive(), 'EXCLUSIVE', isreadonly(), 'READONLY', 'SHARED')
		llAgain = aused(laUsed, .null., m.lcTable) > 1 && et encore il faudrait vérifier chaque session de données !
		lcAgain = iif(m.llAgain, 'AGAIN', '')

		llResult = not (m.llAgain and m.tcMode == 'EXCLUSIVE')
		assert m.llResult message cAssertMsg(textmerge([Impossible de réouvrir l'alias '<<m.tcAlias>>' en exclusif car sa table '<<DisplayPath(cFileCased(m.lcTable), 50)>>' est déjà ouverte]))
		if m.llResult

			llResult = .f.
			use && si on reuse par dessus, VFP peut prendre un homonyme
			try
				use (m.lcTable) &tlAgain &tcMode alias (m.tcAliasNew) &lcOrder
				llResult = .t.
			catch to loException
				use (m.lcTable) &lcAgain &lcMode alias (m.tcAlias) &lcOrder
			endtry

			set filter to &lcFilter
			set fields to &lcFields
			set fields &lcField
		endif
		select (m.lnSelect)
	endif
endif

return m.llResult

* ========================================
function abExclusive && Tente d'ouvrir ou réouvrir une table en exclusif et la remet dans l'état initial au Destroy()
lparameters tuTable && [Alias()] Alias, zone ou adresse d'une table
return createobject('abExclusive', m.tuTable)

* ========================================
define class abExclusive as GA_LIGHTWEIGHT_CLASS && Tente d'ouvrir ou réouvrir une table en exclusif et la remet dans l'état initial au Destroy()

hidden lUsed, cAlias, cTable, cOrder, cFilter, iRecno, lReadonly, cFields

* --------------------------
procedure init
lparameters tuTable && [Alias()] Alias, zone ou adresse d'une table

tuTable = evl(m.tuTable, alias())
this.lUsed = vartype(m.tuTable) == 'C' and used(m.tuTable)
if m.this.lUsed
	this.cOrder = order(m.tuTable)
	this.cFilter = filter(m.tuTable)
	this.iRecno = Recno_(m.tuTable)
	this.lReadonly = isreadonly(m.tuTable)
endif

local llExclusive, llResult

this.cAlias = ExclusiveForce(m.tuTable, @m.llExclusive)
llResult = used(m.this.cAlias)
this.cTable = iif(m.llResult, fullpath(dbf(m.this.cAlias)), '')

return m.llResult and not m.llExclusive

* --------------------------
procedure destroy

use in select(m.this.cAlias)

if m.this.lUsed

	local lcFilter
	lcFilter = this.cFilter

	use (m.this.cTable) again shared alias (m.this.cAlias)
	set order to (m.this.cOrder) in (m.this.cAlias)
	set filter to &lcFilter in (m.this.cAlias)
	RecnoSet(m.this.iRecno, m.this.cAlias)
endif

enddefine && CLASS abExclusive
* ========================================

* ========================================
function lExclusiveForce && Tente d'ouvrir ou réouvrir une table en exclusif
lparameters ;
	tcAlias,;	&& @ Alias
	tuTable,;	&& [Alias()] Alias, zone ou adresse d'une table
	tlExcl && @ L'alias était déjà ouvert en exclusif

tcAlias = ExclusiveForce(m.tuTable, @m.tlExcl)

return used(m.tcAlias)

* ========================================
procedure ExclusiveForce && Tente d'ouvrir ou réouvrir une table en exclusif
lparameters ;
	tuTable,;	&& [Alias()] Alias, zone ou adresse d'une table
	tlExcl && @ L'alias était déjà ouvert en exclusif
tlExcl = .f.

local lcAlias, llAlias, lcResult	&& Alias sous lequel la table est ouverte en exclusif, vide si impossible d'ouvrir en exclusif

lcResult = ''

* Si l'alias de la table existe
lcAlias = cAlias(m.tuTable, @m.llAlias)
if used(m.lcAlias)

	tlExcl = not m.llAlias and isexclusive(m.lcAlias) && L'alias était déjà ouvert et en exclusif
	lcResult = iif(isexclusive(m.lcAlias) or AliasReuse(m.lcAlias, 'EXCLUSIVE'), m.lcAlias, '')
endif

return m.lcResult

* ========================================
procedure HeaderFieldsCarry	&& Copie le contenu des champs d'entête dans l'enr. suivant
lparameters ;
	tuTable,;	&& [Alias()] Alias, zone ou adresse d'une table
	tcFields && [''] Champs d'en-tête
local llResult

* Si l'alias de la table existe
local lcAlias, llAlias
lcAlias = cAlias(m.tuTable, @m.llAlias)
llResult = used(m.lcAlias)
assert m.llResult message cAssertMsg(textmerge([Impossible d'ouvrir la table <<cL(m.tuTable)>>]))
if m.llResult

* Si des champs sont spécifiés et au moins un existe dans la table
	llResult = lFields(m.tcFields, m.lcAlias, .t.)
	assert m.llResult message cAssertMsg(textmerge([Aucun des champs <<m.tcFields>> n'existe dans la table <<cL(m.tuTable)>>]))
	if m.llResult

* Tabuler les champs
		local laFields[1], lnFields, lnField, lcField
		lnFields = alines(laFields, m.tcFields, 1+4, ',')

* Sélectionner la table sur le 1er enr.
		local lnSelect
		lnSelect = select(0)
		select (m.lcAlias)
		locate

* Initialiser les valeurs des champs d'en-tête
		local laValues[m.lnFields], luValue
		for m.lnField = 1 to m.lnFields
			laValues[m.lnField] = evaluate(laFields[m.lnField])
		endfor

* Pour chaque enregistrement
		scan
			scatter memvar memo

* Pour chaque champ d'en-tête
			for m.lnField = 1 to m.lnFields
				lcField = 'm.' + laFields[m.lnField]
				luValue = evaluate(m.lcField)

* Si le champ est vide, prendre la valeur d'entête courante
				if empty(m.luValue)
					store (laValues[m.lnField]) to (m.lcField)

* Sinon, mémoriser la valeur d'en-tête
				else
					laValues[m.lnField] = m.luValue
				endif
			endfor
			gather memvar memo
		endscan
		select (m.lnSelect)
	endif
endif

if m.llAlias
	use in (m.lcAlias)
endif

return m.llResult

* ========================================
procedure TableMove && Déplace une table et ses fichiers dépendants dans un autre dossier
lparameters ;
	tcSrceAddr,; && Adresse actuelle de la table
	tcDestAddr && Adresse cible

local llResult

* Si le fichier source existe
llResult = lFile(m.tcSrceAddr)
assert m.llResult message cAssertMsg(textmerge([le fichier <<m.tcSrceAddr>> est introuvable]))
if m.llResult

* Si le dossier de destination existe
	tcDestAddr = justpath(m.tcDestAddr)
	llResult = directory(m.tcDestAddr)
	assert m.llResult message cAssertMsg(textmerge([le dossier destination <<m.tcDestAddr>> est introuvable]))
	if m.llResult

* Si le dossier de destination est différent du dossier source
		llResult = not c83Address(m.tcDestAddr) == c83Address(justpath(m.tcSrceAddr))
		assert m.llResult message cAssertMsg(textmerge([le dossier destination <<m.tcDestAddr>> est identique au dossier source (<<m.tcSrceAddr>>)]))
		if m.llResult

* Si le fichier source est une table et peut être ouverte en exclusif
			local lcAlias, llOpened
			lcAlias = ExclusiveForce(cAlias(m.tcSrceAddr, @m.llOpened))
			llResult = used(m.lcAlias)
			assert m.llResult message cAssertMsg(textmerge([le fichier source <<m.tcSrceAddr>> n'est pas une table ou ne peut pas être ouverte en exclusif]))
			if m.llResult

* Copier à l'adresse destination
				local loSelect as abSelect
				tcDestAddr = forcepath(justfname(m.tcSrceAddr), m.tcDestAddr)
				loSelect = abSelect(m.lcAlias)
				copy to (m.tcDestAddr) with cdx

* Si la table était déjà ouverte, ouvrir la nouvelle à la place
				if m.llOpened
					use in (m.lcAlias)
				else
					use (m.tcDestAddr) alias (m.lcAlias)
				endif

* Supprimer l'ancienne table, ses fichiers mémo et index éventuels
				erase (m.tcSrceAddr)
				erase (forceext(m.tcSrceAddr, 'FPT'))
				erase (forceext(m.tcSrceAddr, 'CDX'))

			else
				if m.llOpened
					use in (m.lcAlias)
				endif
			endif
		endif
	endif
endif

return m.llResult

* ========================================
procedure TablesMerge && Fusionne 2 tables en ajustant la structure de la réceptacle
lparameters ;
	tuDestTable,; && Alias ou zone ou adresse de la table destination (crée si elle n'existe pas)
	tuSrceTable && [Alias()] Alias ou zone ou adresse de la table source
local llResult && La fusion a été réalisée

* Si une table destination a été précisée
local llParms, ;
	lcDestAlias, llDestOpened, llDestCreate, ;
	lcSrceAlias, llSrceOpened, lcSrceAddr
llParms = not empty(m.tuDestTable)
if m.llParms

* Si la table destination ne peut pas être ouverte,
	lcDestAlias = cAlias(m.tuDestTable, @m.llDestOpened)
	llParms = used(m.lcDestAlias)
	if not m.llParms

* Vérifier qu'elle pourra être créé
		if vartype(m.tuDestTable) == 'C'
			tuDestTable = forceext(m.tuDestTable, [dbf])
			llDestCreate = directory(justpath(m.tuDestTable)) ;
				and lFileAddress(m.tuDestTable)
			llParms = m.llDestCreate
		endif
	endif

* Si table Dest OK,
	if m.llParms

* Vérifier que la table source est accessible
		lcSrceAlias = cAlias(m.tuSrceTable, @m.llSrceOpened)
		llParms = used(m.lcSrceAlias)
		lcSrceAddr = cTableAddress(m.lcSrceAlias)
	endif
endif

assert m.llParms message "Table source et/ou destination invalide"
if m.llParms

	local lnSelect
	lnSelect = select(0)

* Si la la table destination n'existe pas,
	if m.llDestCreate

* Copier la table source dedans
		select (m.lcSrceAlias)
		copy to (m.tuDestTable)
		llResult = .t.

* Sinon (la table destination existe)
	else

* Lire la structure des deux tables
		local lnSrce, lnDest
		local array laSrce[1], laDest[1]
		lnSrce = afields(laSrce, m.lcSrceAlias)
		lnDest = afields(laDest, m.lcDestAlias)

* Pour chaque champ source
		local lnField, lcField, lnLength1, lnLength2, lnIdx, llAdjust, lnDest1
		lnDest1 = m.lnDest
		for m.lnField = 1 to m.lnSrce
			lcField = laSrce[m.lnField, 1]

* Si le champ existe dans la table destination
			lnIdx = ascan(laDest, m.lcField, 1, -1, 1, 2+4)
			if m.lnIdx > 0

* Si les champs source et destination sont de même type
				if laDest[m.lnIdx + 1] == laSrce[m.lnField, 2] && same type
					if laDest[m.lnIdx + 2] < laSrce[m.lnField, 3]
						laDest[m.lnIdx + 2] = laSrce[m.lnField, 3]
						llAdjust = .t.
					endif
					if laDest[m.lnIdx + 3] < laSrce[m.lnField, 4]
						laDest[m.lnIdx + 3] = laSrce[m.lnField, 4]
						llAdjust = .t.
					endif
				else
					wait cModuleInfo(sys(16));
						+ space(1) + icase(;
								cLangUser() = 'fr',	"Champ de types différents dans les 2 tables",; && copy-paste this line to add another language support
																			"The 2 tables have fields of different types"); && Default: English
						+ space(1) + m.lcField;
					window nowait
				endif

* Sinon (le champ source n'existe pas dans la destination),
			else

* Ajouter le champ à la table destination
				lnDest1 = m.lnDest1 + 1
				dimension laDest[m.lnDest1, Alen(laDest,2)]
				local j
				for m.j = 1 to alen(laDest,2)
					laDest[m.lnDest1, m.j] = laSrce[m.lnField, m.j]
				endfor
				llAdjust = .t.
			endif
		endfor

* Ajuster si nécessaire la structure de la table destination
		if m.llAdjust
			lcDestAlias = ExclusiveForce(m.lcDestAlias)
			llAdjust = used(m.lcDestAlias)
			assert m.llAdjust message "Impossible d'ouvrir la table destination en exclusif"
			if m.llAdjust
				local lcAlter
				lcAlter = 'ALTER TABLE ' + m.lcDestAlias
				for m.lnField = 1 to m.lnDest1
					lcAlter = m.lcAlter + space(1) + ;
						iif(m.lnField <= m.lnDest, 'ALTER', 'ADD') + space(1) + ;
						'COLUMN' + space(1) + ;
						cFieldExp(laDest[m.lnField, 1], laDest[m.lnField, 2], laDest[m.lnField, 3], laDest[m.lnField, 4], null)
				endfor
				&lcAlter
				llResult = .t.
			endif
		else
			llResult = .t.
		endif

* Si la structure de la table dest est OK
		if m.llResult
* Ajouter le contenu de la source à la destination
			select (m.lcDestAlias)
			append from (m.lcSrceAddr)
		endif
	endif

	select (m.lnSelect)
endif

* Refermer les tables ouvertes ici
if m.llDestOpened
	use in (m.lcDestAlias)
endif
if m.llSrceOpened
	use in (m.lcSrceAlias)
endif

return m.llResult

* ========================================
function lFPT && Une table a un fichier FPT associé (présence d'un champ mémo, Varchar, Varbinary, Blob, etc.)
lparameters tuTable && Alias ou zone ou adresse d'une table

local lcAlias, llAlias, llResult

lcAlias = cAlias(m.tuTable, @m.llAlias)

llResult = .t.;
 and used(m.lcAlias);
 and file(forceext(dbf(m.lcAlias), 'FPT'))

if m.llAlias
	use in select(m.lcAlias)
endif

return m.llResult

* ========================================
function lTablesIdem && Deux tables sont identiques : mêmes structure et contenu
lparameters ;
	tuTable1,; && Alias ou zone ou adresse de la première table
	tuTable2,; && Alias ou zone ou adresse de la seconde table
	tlFieldsOrder && [.F.] Les champs doivent être dans le même ordre
local llResult && Les tables sont identiques

* Si les spécifications de tables sont valides
local lcAlias1, lcAlias2, llAlias1, llAlias2
lcAlias1 = cAlias(m.tuTable1, @m.llAlias1)
lcAlias2 = cAlias(m.tuTable2, @m.llAlias2)
llResult = used(m.lcAlias1) and used(m.lcAlias2)
assert m.llResult message cAssertMsg("Spécifications de tables invalides" + CRLF;
	+ cLitteral(m.tuTable1) + CRLF;
	+ cLitteral(m.tuTable2);
	)
if m.llResult
	local llFieldsOrder
	llFieldsOrder = uDefault(m.tlFieldsOrder, .f.)

* Si les tables ont des structures identiques
	llResult = lFieldsIdem(m.lcAlias1, m.lcAlias2, m.llFieldsOrder)
	if m.llResult

* Construire l'expression de jointure
		local lnRecs, lnFields, lnField, lcField, lcJoin
		lnRecs = reccount(m.lcAlias1)
		lnFields = fcount(m.lcAlias1)
		lcJoin = ''
		for m.lnField = 1 to m.lnFields
			lcField = field(m.lnField, m.lcAlias1)
			lcJoin = c2Words(m.lcJoin, '.AND.';
					, m.lcAlias1 + [.] + m.lcField + '=' + m.lcAlias2 + [.] + m.lcField)
		endfor

* Extraire les enregistrements concordants
		local lnSelect, loAnsi
		lnSelect = select(0)
		loAnsi = abSet('ANSI', 'ON')
		select * from (m.lcAlias1) full join (m.lcAlias2) on &lcJoin into cursor (sys(2015))
		llResult = _tally = m.lnRecs

		use
		release loAnsi
		select (m.lnSelect)

	endif
endif

if m.llAlias1
	use in select(m.lcAlias1)
endif
if m.llAlias2
	use in select(m.lcAlias2)
endif

return m.llResult

* ========================================
function lFieldsIdem && Deux tables ont la même structure
lparameters ;
	tuTable1,; && Alias ou zone ou adresse de la première table
	tuTable2,; && Alias ou zone ou adresse de la seconde table
	tlFieldsOrder && [.F.] Les champs doivent être dans le même ordre
local llResult && Les tables ont la même structure

* Si les spécifications de tables sont valides
local lcAlias1, lcAlias2, llAlias1, llAlias2
lcAlias1 = cAlias(m.tuTable1, @m.llAlias1)
lcAlias2 = cAlias(m.tuTable2, @m.llAlias2)
llResult = used(m.lcAlias1) and used(m.lcAlias2)
assert m.llResult message cAssertMsg(textmerge([<<cCallingModules(.T.)>> - Spécifications de tables invalides : <<cLitteral(m.tuTable1)>> | <<cLitteral(m.tuTable2)>>]))
if m.llResult

* Lire les structures des deux tables
	local array laFields1[1], laFields2[1]
	local lnFields1, lnFields2
	lnFields1 = afields(laFields1, m.lcAlias1)
	lnFields2 = afields(laFields2, m.lcAlias2)

* Si les tables ont le même nombre de champs
	llResult = m.lnFields1 = m.lnFields2
	if m.llResult

* Supprimer les colonnes inutiles
		aColsDel(@m.laFields1, 5)
		aColsDel(@m.laFields2, 5)

* Donner sa valeur par défaut au paramètre optionnel
		local llFieldsOrder
		llFieldsOrder = uDefault(m.tlFieldsOrder, .f.)

* Si les champs doivent être dans le même ordre
		if m.llFieldsOrder

			llResult = laEqual(@m.laFields1, @m.laFields2)

* Sinon (les champs peuvent être dans un ordre différent)
		else

* Pour chaque champ de la première table
			local lnField1, lcField1, lnField2
			for m.lnField1 = 1 to m.lnFields1
				lcField1 = laFields1[m.lnField1, 1]

* Si le champ existe dans la deuxième table
				lnField2 = ascan(laFields2, m.lcField1, 1, -1, 1, 2+4+8)
				llResult = m.lnField2 > 0
				if m.llResult

* Si les deux champs ont les mêmes caractéristiques
					llResult = ;
								laFields1[m.lnField1, 2] = laFields2[m.lnField2, 2] ;
						and laFields1[m.lnField1, 3] = laFields2[m.lnField2, 3] ;
						and laFields1[m.lnField1, 4] = laFields2[m.lnField2, 4]
					if not m.llResult
						exit
					endif
				else
					exit
				endif
			endfor
		endif
	endif
endif

if m.llAlias1
	use in select(m.lcAlias1)
endif
if m.llAlias2
	use in select(m.lcAlias2)
endif

return m.llResult

* ========================================
function l2FieldsIdem && deux champs sont de même structure : type[, longueur [décimales]]
lparameters ;
	tcTableField1,; && 'table.field' du premier champ
	tcTableField2,; && 'table.field' du second champ
	tlNullIgnore,; && [.F.] Ignorer si "Null values allowed"
	tlContains && [.F.] le champ 2 doit pouvoir contenir le champ 1
local llResult && Les deux champs ont la même structure

local lcAlias1, lcAlias2, llAlias1, llAlias2, lcField1, lcField2, laFields1[1], laFields2[1], lnField1, lnField2
lcAlias1 = cAlias(juststem(m.tcTableField1), @m.llAlias1)
lcAlias2 = cAlias(juststem(m.tcTableField2), @m.llAlias2)
llResult = used(m.lcAlias1) and used(m.lcAlias2)
assert m.llResult message cAssertMsg(textmerge([<<cCallingModules(.T.)>> - Paramètres invalides: <<m.tcTableField1>> | <<m.tcTableField2>>]))
if m.llResult

	lcField1 = upper(justext(m.tcTableField1))
	lcField2 = upper(justext(m.tcTableField2))
	llResult = lField(m.lcField1, m.lcAlias1) and lField(m.lcField2, m.lcAlias2)
	assert m.llResult message cAssertMsg(textmerge([<<cCallingModules(.T.)>> - Les champs <<m.lcField1>> et <<m.lcField2>> doivent appartenir aux tables <<m.lcAlias1>> et <<m.lcAlias2>>]))
	if m.llResult

		afields(laFields1, m.lcAlias1)
		afields(laFields2, m.lcAlias2)
		lnField1 = ascan(laFields1, m.lcField1, 1, -1, 1, 2+4+8)
		lnField2 = ascan(laFields2, m.lcField2, 1, -1, 1, 2+4+8)

		tlContains = iif(vartype(m.tlContains) == 'L', m.tlContains, .f.)
		llResult = laFields1[m.lnField1, AFIELDS_TYPE] == laFields2[m.lnField2, AFIELDS_TYPE];
			and (not m.tlContains and laFields1[m.lnField1, AFIELDS_WIDTH] == laFields2[m.lnField2, AFIELDS_WIDTH] or laFields1[m.lnField1, AFIELDS_WIDTH] <= laFields2[m.lnField2, AFIELDS_WIDTH]);
			and (not m.tlContains and laFields1[m.lnField1, AFIELDS_PRECISION] == laFields2[m.lnField2, AFIELDS_PRECISION] or laFields1[m.lnField1, AFIELDS_PRECISION] <= laFields2[m.lnField2, AFIELDS_PRECISION]);
			and (lTrue(m.tlNullIgnore) or laFields1[m.lnField1, AFIELDS_NULL] == laFields2[m.lnField2, AFIELDS_NULL])
	endif
endif

if m.llAlias1
	use in (m.lcAlias1)
endif
if m.llAlias2
	use in (m.lcAlias2)
endif

return m.llResult

* -----------------------------------------------------------------
procedure l2FieldsIdem_Test

local loTest as lFields_Test of abData.prg
loTest = createobject('lFields_Test')
loTest.dataopen

loTest.Test(.t., 'TMP1.AAA', 'TMP2.AAA')
loTest.Test(.f., 'TMP1.BBB', 'TMP2.BBB')

return loTest.Result()

* ========================================
procedure TableOfArray && Construit une table ou un curseur à partir d'un tableau
lparameters ;
	taArray,; && @ Tableau source
	tuTable,; && [Cursor] Adresse de la table à créer ou, si invalide, ordre de créer un curseur
	tl2D && [.F.] Créer autant de champs que de colonnes dans le tableau
local lcResult && Adresse de la table ou Alias du curseur
lcResult = ''
external array taArray

* Si un tableau a bien été passé
local llResult
llResult = not type('taArray[1]') == 'U'
assert m.llResult message cAssertMsg("Spécification de tableau invalide" + CRLF + cLitteral(taArray))
if m.llResult

* Si le tableau est non vide
	if not laEmpty(@m.taArray)

* Déterminer si demande de curseur ou de table
		local llTable
		llTable = vartype(m.tuTable) == 'C' and not empty(m.tuTable)

* Si une adresse de table valide a été passée
		if m.llTable
			local lcTableAddr
			lcTableAddr = forceext(m.tuTable, [dbf])
			llResult = lFileAddress(m.lcTableAddr)
			assert m.llResult message cAssertMsg("Spécification d'adresse de table invalide" + CRLF + cLitteral(m.tuTable))
		endif

* si tout va bien jusqu'ici
		if m.llResult

* Vérifier les dimensions du tableau
			local lnRows, lnCols, lnRow, lnCol
			lnRows = alen(taArray, 1)
			lnCols = alen(taArray, 2)
			if m.lnCols = 1
				dimension taArray[m.lnRows]
			endif
			tl2D = lTrue(m.tl2D) and m.lnCols > 1

* Créer le curseur ou la table
			local loSelect, lcFields, lcAlias, lcType, lnLen, lnDec
			loSelect = abSelect()
			if m.tl2D
				lcFields = ''
				for lnCol = 1 to m.lnCols
					lcType = vartype(taArray[1, m.lnCol])
					lnLen = icase(.f., '';
						, m.lcType == 'C', 200;
						, m.lcType == 'N', 10;
						, 8;
						)
					lnDec = iif(m.lcType == 'N', 2, 0)
					lcFields = m.lcFields + cFieldExp(TableOfArray_cField(m.lnCol), m.lcType, m.lnLen, m.lnDec) + ','
				next
				lcFields = '(' + left(m.lcFields, len(m.lcFields)-1) + ')'
	 		else
				lcFields = "(NR I, NC I, ET C(1), EV C(254))"
			endif
			lcResult = iif(m.llTable, m.lcTableAddr, sys(2015))
			if m.llTable
				create table (m.lcResult) free &lcFields
			else
				create cursor (m.lcResult) &lcFields
			endif
			lcAlias = alias()

* Pour chaque élément du tableau, ajouter à la table
			if m.lnCols > 1 && tableau à 2 dimensions
				for lnRow = 1 to m.lnRows
					for lnCol = 1 to m.lnCols
						llResult = TableOfArray_EltInsert(@m.taArray, m.lcAlias, m.lnRow, m.lnCol, m.tl2D)
						if not m.llResult
							exit
						endif
					endfor
					if not m.llResult
						exit
					endif
				endfor
			else && tableau à une dimension
				for lnRow = 1 to m.lnRows
					llResult = TableOfArray_EltInsert(@m.taArray, m.lcAlias, m.lnRow, 0)
					if not m.llResult
						exit
					endif
				endfor
			endif

* Si table, refermer
			if m.llTable
				use
			endif
		endif
	endif
endif

return m.lcResult

* ========================================
function TableOfArray_cField && [privée de TableOfArray()] Champ standard
lparameters tnCol
return 'C' + transform(m.tnCol, '@L 999')

* ========================================
procedure TableOfArray_EltInsert && Ajoute un élément à la table / au curseur
lparameters ;
	taArray,; && @ Tableau source
	tcAlias,; && Alias de la table
	tnRow,; && N° de ligne
	tnCol,; && N° de colonne (0 si tableau à une dimension)
	tl2D && Créer autant de champs que de colonnes dans le tableau
local luElt, lcType, lcField, llResult

luElt = iif(m.tnCol > 0, taArray[m.tnRow, m.tnCol], taArray[m.tnRow])
lcType = vartype(m.luElt)
llResult = m.lcType $ 'CNDTLY'
assert m.llResult message cAssertMsg("Élément d'un type non supporté" + CRLF + cLitteral(m.luElt))
if m.llResult
	if m.tl2D
		if m.tnCol = 1
			append blank
		endif
		lcField = TableOfArray_cField(m.tnCol) && Erreur "invalid subscript element" si directement dans le REPLACE
		replace (m.lcField) with m.luElt
	else
		insert into (m.tcAlias) values (m.tnRow, m.tnCol, m.lcType, cLitteral(m.luElt))
	endif
endif

*!*			lcElt = cLitteral(m.luElt)
*!*			IF Len(m.lcElt) > 254
*!*				ALTER TABLE (m.tcAlias) ALTER COLUMN EV M
*!*			ENDIF

return m.llResult

* ========================================
procedure ArrayOfTable && Reconstitue un tableau à partir d'une sauvegarde par TableOfArray()
lparameters ;
	taArray,; && @ Tableau source
	tuTable && Alias ou adresse de la table / du curseur source
external array taArray
local lnResult && Nombre de lignes du tableau
lnResult = 0

* Si un tableau a bien été passé
local llResult
llResult = type('taArray', 1) == 'U'
assert m.llResult message cAssertMsg("Spécification de tableau invalide" + CRLF + cLitteral(taArray))
if m.llResult

* Si une table a bien été passée
	local lcAlias, llAlias
	lcAlias = cAlias(m.tuTable, @m.llAlias)
	llResult = used(m.lcAlias)
	assert m.llResult message cAssertMsg("Spécification de table invalide" + CRLF + cLitteral(m.tuTable))
	if m.llResult

* Si la table a une structure valide
		if .t.
&& à implémenter

* Si la table a des enregistrements
			llResult = reccount(m.lcAlias) > 0
			assert m.llResult message cAssertMsg("La table n'a aucun enregistrement !" + CRLF + cLitteral(m.tuTable))
			if m.llResult

* Dimensionner le tableau
				local array laFields[1]
				local llCols
				select max(NR), max(NC) from (m.lcAlias) into array laFields
				lnResult = laFields[1]
				llCols = laFields[2] > 0
				if m.llCols
					dimension taArray[m.lnResult, laFields[2]]
				else
					dimension taArray[m.lnResult]
				endif
				release laFields

* Pour chaque enregistrement
				local lnSelect
				lnSelect = select(0)
				select (m.lcAlias)
				scan

* Charger l'élément dans le tableau
					if m.llCols
						taArray[NR, NC] = evaluate(EV)
					else
						taArray[NR] = evaluate(EV)
					endif
				endscan

				select (m.lnSelect)
			endif
		endif
		if m.llAlias
			use in (m.lcAlias)
		endif
	endif
endif

return m.lnResult

* ========================================
procedure cFieldsLTrim && Tronque à gauche les champs de type caractère, pour tous les enr.
lparameters ;
	tcTable,;	&& [Alias()] Alias, zone ou adresse d'une table
	tcFieldsIgnore && [''] Squelette des champs à ignorer
local llResult

* Si la table est accessible
local lcAlias, llAlias, loSelect
lcAlias = cAlias(m.tcTable, @m.llAlias)
llResult = used(m.lcAlias)
if m.llResult

	loSelect = abSelect(m.lcAlias)

* Si la table était déjà ouverte, mémoriser son état
	if not m.llAlias
		local lcOrder, lnRecno
		lcOrder = order()
		lnRecno = Recno_()
		set order to && sinon le scan risque de s'achever prématurément
	endif

* Traiter les champs à ignorer
	tcFieldsIgnore = iif(vartype(m.tcFieldsIgnore) == 'C', upper(m.tcFieldsIgnore), 'c__hd_$') && champ bidon

* Pour chaque enr.
	local laRec[1], lnField, luValue
	scan
		scatter to laRec fields except &tcFieldsIgnore

* Pour chaque champ
		for m.lnField = 1 to alen(laRec)
			luValue = laRec[m.lnField]

			if vartype(m.luValue) == 'C';
			 and not empty(m.luValue);
			 and not isnull(m.luValue)

			 	laRec[m.lnField] = ltrim(m.luValue)
			endif
		endfor

		gather from laRec fields except &tcFieldsIgnore
	endscan

* Rétablir la table dans l'état initial
	if m.llAlias
		use
	else
		set order to (m.lcOrder)
		RecnoSet(m.lnRecno)
	endif
endif

return m.llResult

* ========================================
function nField	&& Position d'un champ dans l'alias courant ou spécifié
lparameters ;
	tcField, ; && Nom du champ dont l'existence est a verifier
	tuTable && [Alias()] Alias ou adresse de la table où l'existence du champ est à verifier
local lnResult
lnResult = 0

if vartype(m.tcField) = 'C' ;
 and !empty(m.tcField)

	local lcAlias, llAlias
	lcAlias = cAlias(m.tuTable, @m.llAlias)

	if used(m.lcAlias)
		local lcField, lnField
		lcField = upper(alltrim(m.tcField))
		for m.lnField = 1 to fcount(m.lcAlias)
			if field(m.lnField, m.lcAlias) == m.lcField
				lnResult = m.lnField
				exit
			endif
		endfor

		if m.llAlias
			use in (m.lcAlias)
		endif
	endif
endif

return m.lnResult

* ========================================
function lTag	&& La table courante ou spécifiée a un tag d'index d'un certain nom
lparameters ;
	tcTag, ; && Nom du tag dont l'existence est à verifier
	tuTable && [Alias()] Alias ou adresse de la table où l'existence du tag est à verifier
local llResult

* Si un tag a été spécifié
llResult = vartype(m.tcTag) == 'C' and not empty(m.tcTag)
 	if m.llResult

* Si la table peut être localisée
 	local lcAlias, llAlias
 	lcAlias = cAlias(m.tuTable, @m.llAlias)
 	llResult = used(m.lcAlias)
 	assert m.llResult message cAssertMsg(textmerge("Table can't be found: <<cL(m.tuTable)>>"))
 	if m.llResult

	 	local lnSelect
		lnSelect = select(0)
		select (m.lcAlias)

* Si la table comporte des tags d'index
	 	local lnTags
		lnTags = tagcount()
		llResult = m.lnTags > 0
		if m.llResult

* Pour chaque tag de la table
		 	local lcTag, lnTag
		 	lcTag = upper(alltrim(m.tcTag))
			for m.lnTag = 1 to m.lnTags

* Si le tag est celui spécifié, fini
				llResult = tag(m.lnTag) == m.lcTag && Tag() result is always uppercase
				if m.llResult
					exit
				endif
			endfor
		endif

		if m.llAlias
			use
		endif
		select (m.lnSelect)
 	endif
endif

return m.llResult

* ========================================
function lTags	&& La table courante ou spécifiée comporte des tags d'index d'un certain nom
lparameters ;
	tcTags, ; && Liste des tags dont l'existence est à vérifier
	tuTable,; && [Alias()] Alias ou adresse de la table où l'existence des tags est à vérifier
	tlOneAtLeast &&	[.F.] Au moins un des tags doit être présent
local llResult

if vartype(m.tcTags) == 'C' and not empty(m.tcTags)

* Si la table peut être localisée
 	local lcAlias, llAlias
 	lcAlias = cAlias(m.tuTable, @m.llAlias)
 	if used(m.lcAlias)

	 	local llOneAtLeast
	 	llOneAtLeast = iif(vartype(m.tlOneAtLeast) == 'L', m.tlOneAtLeast, .f.)

* Pour chaque tag spécifié
	 	local array laTags[1]
	 	local lcTag
	 	alines(laTags, upper(m.tcTags), .t., ',')
	 	for each lcTag in laTags

	 		llResult = empty(m.lcTag) or lTag(m.lcTag, m.lcAlias)

			if m.llResult and m.llOneAtLeast ; &&	One at least and current exists
				or ! m.llResult and ! m.llOneAtLeast &&	All required and current misses
				exit
			endif
	 	endfor

		if m.llAlias
			use in (m.lcAlias)
		endif
 	endif
endif

return m.llResult

* ========================================
function cTagOfExpr && Tag d'index d'une table construit sur une expression
lparameters ;
	tcExpr,; && Expression
	tuTable && [Alias()] Alias ou adresse de la table

local lcResult;
, llResult;
, lcAlias, llAlias, loSelect as abSelect;
, liTag

lcResult = ''

* Si la table peut être localisée
lcAlias = cAlias(m.tuTable, @m.llAlias)
llResult = used(m.lcAlias)
assert m.llResult message cAssertMsg(textmerge("Table can't be found: <<cL(m.tuTable)>>"))
if m.llResult

* Si un tag a été spécifié
	llResult = lTableExpr(m.tcExpr, m.lcAlias)
 	assert m.llResult message cAssertMsg(textmerge("Expression <<cL(m.tcExpr)>> is invalid on table <<m.lcAlias>>"))
 	if m.llResult

 		tcExpr = normalize(m.tcExpr)
 		loSelect = abSelect(m.lcAlias)
 		for liTag = 1 to tagcount()
 			if m.tcExpr = normalize(sys(14, m.liTag, m.lcAlias))
 				lcResult = tag('', m.liTag)
 			endif
 		endfor
 	endif
	if m.llAlias
		use in (m.lcAlias)
	endif
endif

return m.lcResult

* ========================================
function cTagExpr && Expression d'index d'un tag d'une table
lparameters ;
	tcTag,; && Tag à rechercher
	tuTable && [Alias()] Alias ou adresse de la table

local lcResult;
, llResult;
, lcAlias, llAlias;
, liTag

lcResult = ''

* Si la table peut être localisée
 	lcAlias = cAlias(m.tuTable, @m.llAlias)
 	llResult = used(m.lcAlias)
 	assert m.llResult message cAssertMsg(textmerge("Table can't be found: <<cL(m.tuTable)>>"))
 	if m.llResult

* Si un tag a été spécifié
	llResult = vartype(m.tcTag) == 'C' and not empty(m.tcTag)
 	assert m.llResult message cAssertMsg(textmerge("Invalid Tag specification: <<m.tcTag>>"))
 	if m.llResult

 		liTag = tagno(m.tcTag, '', m.lcAlias)
 		llResult = m.liTag > 0
	 	assert m.llResult message cAssertMsg(textmerge("Tag <<m.tcTag>> introuvable dans la table <<cL(m.tuTable)>>"))
	 	if m.llResult

	 		lcResult = normalize(sys(14, m.liTag, m.lcAlias))
	 	endif
 	endif
	if m.llAlias
		use in (m.lcAlias)
	endif
endif

return m.lcResult

* -----------------------------------------------------------------
procedure cTagExpr_Test && Teste cTagExpr

local loTest as cTagExpr_Test of abData.prg
loTest = createobject('cTagExpr_Test')
if loTest.dataopen()

	loTest.Test('CPROGADDR', 'CPROGADDR', 'abUnitTest')
	loTest.Test('UPPER(CCLASS)+UPPER(CNAME)', 'FULLNAME', 'abUnitTest')
endif

return loTest.Result()

* ------------------------------
define class cTagExpr_Test as abUnitTest of abDev.prg

	procedure dataopen
		local llResult, lcFile
		lcFile = home() + 'tools\ab\abmodule.dbf'
		llResult = file(m.lcFile)
		assert m.llResult message cAssertMsg(textmerge("Test File does not exist: <<cLitteral(DisplayPath(m.lcFile, 30))>>"))
		if m.llResult
			use (m.lcFile) again alias abUnitTest
		endif

		return m.llResult

	enddefine

* ========================================
function cTagType && Type d'index d'un tag d'une table (en anglais)
lparameters ;
	tcTag,; && Tag à rechercher
	tuTable && [Alias()] Alias ou adresse de la table

local lcAlias, llAlias, lnTag, laTagInfo[1], llResult, lcResult
lcResult = ''

* Si un tag a été spécifié
llResult = vartype(m.tcTag) == 'C' and not empty(m.tcTag)
 	assert m.llResult message cAssertMsg(textmerge("Invalid Tag specification: <<m.tcTag>>"))
 	if m.llResult

* Si la table peut être localisée
 	lcAlias = cAlias(m.tuTable, @m.llAlias)
 	llResult = used(m.lcAlias)
 	assert m.llResult message cAssertMsg(textmerge("Table can't be found: <<cL(m.tuTable)>>"))
 	if m.llResult
 		tuTable = dbf(m.lcAlias)

* Si la table a des indexes
 		llResult = aTagInfoEn(@m.laTagInfo, '', m.lcAlias) > 0 && Normalisé en anglais car cette saloperie de vfp9r*.dll traduit en Français
 		if m.llResult
	 		tcTag = upper(alltrim(m.tcTag))
	 		lnTag = ascan(laTagInfo, m.tcTag, 1, -1, 1, 2+4+8)
	 		llResult = m.lnTag > 0
 		endif
	 	assert m.llResult message cAssertMsg(textmerge("Tag <<m.tcTag>> introuvable dans la table <<cL(m.tuTable)>>"))
	 	if m.llResult

	 		lcResult = laTagInfo[m.lnTag, 2]
	 	endif
 	endif
	if m.llAlias
		use in (m.lcAlias)
	endif
endif

return m.lcResult

* ========================================
function cTagPC	&& Premier tag d'index candidat, ou d'index primaire d'une table
lparameters ;
	tuTable,; && [Alias()] Alias ou adresse de la table où l'existence du tag est à vérifier
	tcTagExp,; && @ [''] Expression de l'index trouvé
	tlTagCand,; && @ [.F.] Index candidat seulement ; @ Un index candidat a été trouvé
	tnTag,; && @ [0] N° du tag d'index trouvé
	tlTagPrim && [.F.] Index primaire seulement
tcTagExp = ''
tlTagCand = lTrue(m.tlTagCand)
tnTag = 0
tlTagPrim = lTrue(m.tlTagPrim)

 	local llTagPrim, lcAlias, llAlias;
 	, lnTag, liTag, lcTag;
 	, llResult, lcResult && Tag trouvé

lcResult = ''
llTagPrim = not m.tlTagCand && Index primaire accepté
tlTagCand = .f. && retour

 	lcAlias = cAlias(m.tuTable, @m.llAlias)
 	llResult = used(m.lcAlias)
 	assert m.llResult message cAssertMsg(textmerge("Table can't be found: <<cL(m.tuTable)>>"))
 	if m.llResult

	llResult = .f.

* Si la table comporte des tags d'index
	lnTag = tagcount(cdx(1, m.lcAlias), m.lcAlias) && le CDX a le même nom que l'alias
	if m.lnTag > 0

* Si index candidat autorisé
		if not m.tlTagPrim

* Chercher le premier index candidat
			for liTag = 1 to m.lnTag
			 	llResult = candidate(m.liTag, m.lcAlias)
				if m.llResult
					tlTagCand = .t.
					exit
				endif
			endfor
		endif

* Si aucun index candidat trouvé et index primaire accepté
		if not m.llResult and (m.llTagPrim or m.tlTagPrim)

* Chercher l'index primaire
			for liTag = 1 to m.lnTag
			 	llResult = primary(m.liTag, m.lcAlias)
				if m.llResult
					exit
				endif
			endfor
		endif

* Si index trouvé, lire ses caractéristiques
		if m.llResult
			lcResult = tag(m.liTag, m.lcAlias)
			tcTagExp = sys(14, m.liTag, m.lcAlias)
			tnTag = m.liTag
		endif
	endif

* Si rien de trouvé et clé primaire acceptée, voir si c'est une vue définissant une clé primaire
	if not m.llResult and llTagPrim

		lcResult = cursorgetprop("KeyFieldList", m.lcAlias) && sans erreur sur une table
		llResult = not (empty(m.lcResult) or ',' $ m.lcResult)
		store iif(m.llResult, m.lcResult, '') to lcResult, tcTagExp
	endif

	if m.llAlias
		use in (m.lcAlias)
	endif
endif

return m.lcResult

* ========================================
function cTagP	&& Index primaire d'une table (tag, expression)
lparameters ;
	tuTable,; && [Alias()] Alias ou adresse de la table où l'existence du tag est à verifier
	tcTagExp,; && @ [''] Expression de l'index trouvé
	tnTag && @ [0] N° du tag d'index trouvé

return cTagPC(m.tuTable, @m.tcTagExp, .f., @m.tnTag, .t.)

* ========================================
function aTagsPC && Indexes candidats [et primaire] d'une table
lparameters ;
	taTagsPC,; && @ Indexes candidats [et primaire] : Tag | Expression | Filter Expression
	tuTable,; && [Alias()] Alias ou adresse de la table
	tlTagCand && [.F.] Indexes candidats seulement
external array taTagsPC
local lcAlias, llAlias, llResult, lnResult && nombre d'indexs trouvés
lnResult = 0

llResult = type('taTagsPC', 1) == 'A'
 	assert m.llResult message cAssertMsg(textmerge([Tableau attendu en premier paramètre, <<cLitteral(m.taTagsPC)>> est incorrect]))
 	if m.llResult
 		aClear(@m.taTagsPC)

	lcAlias = cAlias(m.tuTable, @m.llAlias)
 	assert m.llResult message cAssertMsg(textmerge("Table can't be found: <<cL(m.tuTable)>>"))
 	if m.llResult

* Pour chaque tag d'index candidat [ou primaire]
	 	local lnTags, laTags[1], lnTag
	 	lnTags = ataginfo(laTags, '', m.lcAlias) && Tagcount(m.lcAlias, m.lcAlias) Included for compatibility with dBASE
		if m.lnTags > 0

			tlTagCand = iif(vartype(m.tlTagCand) == 'L', m.tlTagCand, .f.)
			for lnTag = 1 to m.lnTags

				if candidate(m.lnTag, m.lcAlias);
				 or (not m.tlTagCand and primary(m.lnTag, m.lcAlias))

					lnResult = m.lnResult + 1
					dimension taTagsPC[m.lnResult, 3]
					taTagsPC[m.lnResult, 1] = laTags[m.lnTag, 1] && Tag
					taTagsPC[m.lnResult, 2] = laTags[m.lnTag, 3] && Expression
					taTagsPC[m.lnResult, 3] = laTags[m.lnTag, 4] && Filter Expression
				endif
			endfor
		endif

		if m.llAlias
			use in (m.lcAlias)
		endif
 	endif
 	endif

return m.lnResult

* ========================================
function cSetKeyFilter && Expression de filtre sur Set("Key")
lparameters tcAlias && [Alias()]
tcAlias = evl(m.tcAlias, alias())

local loSelect as abSelect of abData.prg, lcKey1, lcKey2, lcExpr, llChar, lcResult
lcResult = ''

loSelect = newobject('abSelect', 'abData.prg', '', m.tcAlias)
if vartype(m.loSelect) == 'O'

	if not empty(order())

		lcKey1 = set("Key", 1)
		lcKey2 = set("Key", 2)
		if not empty(m.lcKey1 + m.lcKey2)

* Déterminer le type de l'index
			lcExpr = cExprFieldsPrefixed(cTagExpr(order()), m.tcAlias, m.tcAlias)
			llChar = vartype(evaluate(m.lcExpr)) == 'C'
			lcKey1 = iif(m.llChar, '"' + m.lcKey1 + '"', m.lcKey1)
			lcKey2 = iif(m.llChar, '"' + m.lcKey2 + '"', m.lcKey2)

			lcResult = textmerge(iif(m.lcKey1 == m.lcKey2;
			, [<<m.lcExpr>> = <<m.lcKey1>>]; && Filtre simple
			, [Between(<<m.lcExpr>>, <<m.lcKey1>>, <<m.lcKey2>>)]; && Filtre RANGE
			))
		endif
	endif
endif

return m.lcResult

* ========================================
function keyset && Rétablit Set("Key") dans un Alias
lparameters ;
	tcAlias,; && [Alias()]
	tcKey,; && Set("Key")
	tcResult && @ Résultat (cumulatif)
tcAlias = evl(m.tcAlias, alias())

local lnSelect, lnKey, lcKey1, lcKey2, llChar, lcKey, llResult

llResult = used(m.tcAlias)
if m.llResult

	if not empty(order(m.tcAlias))

	 	lnSelect = select(0)
	 	select (m.tcAlias)
		if not set("Key") == m.tcKey

* Déterminer le type de l'index
			llChar = vartype(evaluate(cTagExpr(order()))) == 'C'
			lnKey = atc(',', m.tcKey)
			lcKey1 = substr(m.tcKey, 1, m.lnKey-1)
			lcKey2 = ltrim(substr(m.tcKey, m.lnKey+1))
			lcKey1 = iif(m.llChar, '"' + m.lcKey1 + '"', m.lcKey1)
			lcKey2 = iif(m.llChar, '"' + m.lcKey2 + '"', m.lcKey2)
			lcKey  = textmerge(iif(m.lcKey1 == m.lcKey2;
				, m.lcKey1; && Filtre simple
				, [RANGE <<m.lcKey1>>, <<m.lcKey2>>]; && Filtre RANGE
				))

			set key to &lcKey
		endif
	 	select (m.lnSelect)
	endif
else
	cResultAdd(@m.tcResult, textmerge(icase(;
			cLangUser() = 'fr',	[l'alias '<<m.tcAlias>>' est introuvable],; && copy-paste this line to add another language support
													[Alias '<<m.tcAlias>>' can't be found]; && Default: English
	)))
endif

return m.llResult

* ========================================
function cViewParmOp && Opérateur d'un paramètre d'une vue
lparameters tcSQL, tcParm

local loRegExp as abRegExp of abTxt.prg

loRegExp = createobject('abRegExp')
loRegExp.setup(textmerge("\b\s*([^\s\r\n]+)\s*\(+\s*\?\s*\b<<m.tcParm>>\b"), .t., .f., .t.)

return iif(m.loRegExp.Execute(m.tcSQL) = 1, m.loRegExp.Matches[3].item(1), .null.)

* -----------------------------------------------------------------
procedure cViewParmOp_Test

local loTest as abUnitTest of abDev.prg, lcSQL as string

loTest = newobject('abUnitTest', 'abDev.prg')

text TO lcSQL NOSHOW FLAGS 1 PRETEXT 3
	SELECT Users.*;
	 FROM ;
	     ip!users;
	 WHERE  Users.userid = ( ?tuserid )
ENDTEXT

loTest.Test('=', m.lcSQL, 'tUserID')

text TO lcSQL NOSHOW FLAGS 1 PRETEXT 3
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

return loTest.Result()

* ========================================
function lViewCAD && Un alias est une vue liée à un CursorAdapter
lparameters ;
	tcAlias,; && [alias courant] alias à analyser
	tlUpdateable,; && [.NULL.] updateable view ; .NULL.: don't care and feedback
	tiDS && [session de données courante] identifiant de la session de données

return lView(;
		tcAlias; && [alias courant] alias à analyser
	, iif(pcount() < 2, .null., m.tlUpdateable); && [.NULL.] updateable view ; .NULL.: don't care and feedback
	, tiDS; && [session de données courante] identifiant de la session de données
	, .t.; && [all] View should be linked to a CursorAdapter
	)

endfunc

* ========================================
function lViewLocal && Un alias est une vue locale
lparameters ;
  tcAlias; && [alias courant] alias à analyser
, tlUpdateable; && @ [.NULL.] updateable view ; .NULL.: don't care and feedback
, tiDS; && [session de données courante] identifiant de la session de données
, tlCAD; && @ [.NULL.] View should be linked to a CursorAdapter ; .NULL.: don't care and feedback

tlUpdateable = iif(pcount() < 2 or isnull(m.tlUpdateable), .null., lTrue(m.tlUpdateable))
tlCAD = iif(pcount() < 4 or isnull(m.tlCAD), .null., lTrue(m.tlCAD))

return lView(;
	  m.tcAlias; && [alias courant] alias à analyser
	, @m.tlUpdateable; && [.NULL.] updateable view ; .NULL.: don't care and feedback
	, m.tiDS; && [session de données courante] identifiant de la session de données
	, @m.tlCAD; && [all] View should be linked to a CursorAdapter
	, .f.; && @ [.NULL.] View is remote
	)

endfunc

* ========================================
function lViewRemote && Un alias est une vue distante
lparameters ;
  tcAlias; && [alias courant] alias à analyser
, tlUpdateable; && @ [.NULL.] updateable view ; .NULL.: don't care and feedback
, tiDS; && [session de données courante] identifiant de la session de données
, tlCAD; && @ [.NULL.] View should be linked to a CursorAdapter ; .NULL.: don't care and feedback

tlUpdateable = iif(pcount() < 2 or isnull(m.tlUpdateable), .null., lTrue(m.tlUpdateable))
tlCAD = iif(pcount() < 4 or isnull(m.tlCAD), .null., lTrue(m.tlCAD))

return lView(;
	  m.tcAlias; && [alias courant] alias à analyser
	, @m.tlUpdateable; && [.NULL.] updateable view ; .NULL.: don't care and feedback
	, m.tiDS; && [session de données courante] identifiant de la session de données
	, m.tlCAD; && [all] View should be linked to a CursorAdapter
	, .t.; && @ [.NULL.] View is remote
	)

endfunc

* ========================================
function lView && Un alias est une vue
lparameters ;
  tcAlias; && [alias courant] alias à analyser
, tlUpdateable; && @ [.NULL.] updateable view ; .NULL.: don't care and feedback
, tiDS; && [session de données courante] identifiant de la session de données
, tlCAD; && @ [.NULL.] View should be linked to a CursorAdapter ; .NULL.: don't care and feedback
, tlRemote; && @ [.NULL.] View is remote ; .NULL.: don't care and feedback

tcAlias = iif(vartype(m.tcAlias) == 'C' and not empty(m.tcAlias), m.tcAlias, alias())

tlUpdateable = iif(pcount() < 2 or isnull(m.tlUpdateable), .null., lTrue(m.tlUpdateable))
tlCAD = iif(pcount() < 4 or isnull(m.tlCAD), .null., lTrue(m.tlCAD))
tlRemote = iif(pcount() < 5 or isnull(m.tlRemote), .null., lTrue(m.tlRemote))

local llResult;
, liDS, llDS;
, llUpdateable;
, lnSourceType;
, lnSourceType_;
, llCAD;
, llRemote;

liDS = set("Datasession")
llDS = vartype(m.tiDS) == 'N';
	and m.tiDS > 0;
	and not m.liDS = m.tiDS
if m.llDS
	set datasession to m.tiDS
endif

#if .f. && CursorGetProp("SourceType")

1 – The data source is a local sql view.
101 (1 + 100) - cursor is created by The cursorfill method.
201 (1 + 200) - cursor is attached to a cursoradapter object using The cursorattach method.

2 – The data source is a remote sql view.
102 (2 + 100) - cursor is created by cursorfill.
202 (2 + 200) - cursor is attached to a cursoradapter object using cursorattach.

3 – The data source is a table.
103 (3 + 100) - cursor is created by cursorfill.
203 (3 + 200) - cursor is attached to a cursoradapter object using cursorattach.

4 - The cursor is based on ADO Recordset and attached to a cursoradapter object.
104 (4 + 100) - cursor is created by cursorfill.
204 (4 + 200) - cursor is attached to a cursoradapter object using cursorattach.

#endif

llResult = .t.;
 and used(m.tcAlias);
 and varSet(@m.lnSourceType, cursorgetprop("SourceType", m.tcAlias));
 and varSet(@m.lnSourceType_, m.lnSourceType%100);
 and inlist(m.lnSourceType_, 1, 2, 4); && 1 - local SQL view ; 2 - remote SQL view ; 3 – table ; 4 - ADO Recordset attached to a CursorAdapter object
 and varSet(@m.llUpdateable, not empty(cursorgetprop("KeyFieldList", m.tcAlias))); && IsReadonly(m.tcAlias)
 and iif(isnull(m.tlUpdateable), varSet(@m.tlUpdateable, m.llUpdateable), m.tlUpdateable = m.llUpdateable);
 and varSet(@m.llCAD, int(m.lnSourceType / 100) > 0);
 and iif(isnull(m.tlCAD), varSet(@m.tlCAD, m.llCAD), m.tlCAD = m.llCAD);
 and varSet(@m.llRemote, m.lnSourceType_ = 2);
 and iif(isnull(m.tlRemote), varSet(@m.tlRemote, m.llRemote), m.tlRemote = m.llRemote);
 and .t.

if !m.llResult
	store .null. to tlUpdateable, tlCAD, tlRemote
endif

 if m.llDS
	set datasession to m.liDS
endif

return m.llResult

* ========================================
function lViewU && Un alias est une vue updateable
lparameters ;
	tcAlias,; && [alias courant] alias à analyser
	tiDS && [session de données courante] identifiant de la session de données

return lView(m.tcAlias, .t., m.tiDS)

* ========================================
function aViews && Aliases des vues dans une session de données
lparameters ;
	taView,; && @ Aliases des vues locales dans la session de données
	tlUpdateable,; && [.NULL.] vue updateable ; .NULL. don't care
	tiDS && [session de données courante] identifiant de la session de données

external array taView
tlUpdateable = iif(pcount() < 2 or isnull(m.tlUpdateable), .null.,  lTrue(m.tlUpdateable))

local lnAlias, llResult, lnResult
lnResult = 0

llResult = type('taView',1) == 'A'
assert m.llResult message cAssertMsg(textmerge([tableau attendu en premier paramètre <<m.taView>>]))
if m.llResult

	aClear(@m.taView)
	tiDS = iif(vartype(m.tiDS) == 'N' and m.tiDS > 0, m.tiDS, set("Datasession"))
	lnResult = aused(taView, m.tiDS)
	llResult = m.lnResult > 0
*		ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([Aucun alias trouvé dans la session de données <<m.tiDS>>]))
	if m.llResult

		asort(m.taView, 2) && sort on work areas
		aColDel(@m.taView, 2) && zones de travail inutiles
		dimension taView[m.lnResult] && une seule dimension suffit

		for lnAlias = m.lnResult to 1 step -1

			if not lView(taView[m.lnAlias], m.tlUpdateable, m.tiDS)
				lnResult = m.lnResult - 1
				adel(taView, m.lnAlias)
			endif
		endfor
		if m.lnResult = 0
			aClear(@m.taView)
		else
			dimension taView[m.lnResult]
		endif
	endif
endif

return m.lnResult

* ========================================
function aViewsU && Aliases des vues updateable dans une session de données
lparameters ;
	taView,; && @ Aliases des vues locales updateable dans la session de données
	tiDS && [session de données courante] identifiant de la session de données

return aViews(@m.taView, .t., m.tiDS)

* ========================================
function lCursor && Un alias est un curseur
lparameters ;
	tcAlias,; && [alias courant] alias à analyser
	tlReadWrite,; && [.NULL.] updateable cursor (READWRITE); .NULL.: don't care and feedback
	tiDS && [session de données courante] identifiant de la session de données

tcAlias = iif(vartype(m.tcAlias) == 'C' and not empty(m.tcAlias), m.tcAlias, alias())
tlReadWrite = iif(pcount() < 2 or isnull(m.tlReadWrite), .null.,  lTrue(m.tlReadWrite))

local llResult;
, liDS, llDS;
, llAlias;
, llReadWrite;
, lnSourceType;
, lcDBF;

liDS = set("Datasession")
llDS = vartype(m.tiDS) == 'N';
	and m.tiDS > 0;
	and not m.liDS = m.tiDS
if m.llDS
	set datasession to m.tiDS
endif

llAlias = used(m.tcAlias)
llReadWrite = m.llAlias and not isreadonly(m.tcAlias)
lnSourceType = iif(m.llAlias, cursorgetprop("SourceType", m.tcAlias)%100, 0)
lcDBF = iif(m.llAlias, dbf(m.tcAlias), '')

llResult = m.llAlias;
	and;
	  (m.lnSourceType = 2; && remote SQL view
		 		and empty(cursorgetprop("SQL", m.tcAlias)); && NO SQL
 		or;
	 		m.lnSourceType = 3; && Table
	 			and (not file(m.lcDBF); && No table on disk
	 				or lower(justext(m.lcDBF)) == 'tmp'; && Spécial Win2k : apparemment CREATE CURSOR crée une table sur disque
	 				);
	 		);
	and (isnull(m.tlReadWrite) or iif(m.tlReadWrite, m.llReadWrite, not m.llReadWrite))

tlReadWrite = iif(isnull(m.tlReadWrite) and m.llResult, m.llReadWrite, m.tlReadWrite) && FeedBack

if m.llDS
	set datasession to m.liDS
endif

return m.llResult

* -----------------------------------------------------------------
procedure lCursor_Test && Teste lCursor

local loTest as lCursor_Test of abData.prg

loTest = createobject('lCursor_Test')
if loTest.dataopen()

	loTest.Test(.f., 'junk')
	loTest.Test(.f., 'customer')
	loTest.Test(.f., 'invoice')
	loTest.Test(.t., 'innerj')
endif

return loTest.Result()

* ------------------------------
define class lCursor_Test as abUnitTest of abDev.prg && AS session

	procedure dataopen
		local lcDir
		lcDir = _Samples + 'data\'
		open database (m.lcDir + 'testData')
		use testData!customer in 0
		use testData!invoice in 0 nodata
		do (m.lcDir + 'innerJ.qpr') && into cursor innerJ
	enddefine

* ========================================
function cCursors && Aliases des curseurs dans une session de données
lparameters ;
	taCursor,; && @ Aliases des curseurs dans la session de données
	tlReadWrite,; && [.NULL.] curseur READWRITE ; .NULL. don't care
	tiDS && [session de données courante] identifiant de la session de données
tlReadWrite = iif(pcount() = 0 or isnull(m.tlReadWrite);
	, .null.;
	, lTrue(m.tlReadWrite);
	)

return iif(aCursors(@m.taCursor, m.tlReadWrite, m.tiDS, .t.) > 0;
	, cListOfArray(@m.taCursor);
	, '';
	)

* ========================================
function aCursors && Aliases des curseurs dans une session de données
lparameters ;
	taCursor,; && @ Aliases des curseurs dans la session de données
	tlReadWrite,; && [.NULL.] curseur READWRITE ; .NULL. don't care
	tiDS,; && [session de données courante] identifiant de la session de données
	tlSort && [.T.] Trier les aliases par ordre alphabétique
external array taCursor
tlReadWrite = iif(pcount() < 2 or isnull(m.tlReadWrite);
	, .null.;
	, lTrue(m.tlReadWrite);
	)

local liAlias, llResult, lnResult
lnResult = 0

llResult = type('taCursor', 1) == 'A'
assert m.llResult message cAssertMsg(textmerge([tableau attendu en premier paramètre <<m.taCursor>>]))
if m.llResult

	if laEmpty(@m.taCursor)

		tiDS = iif(vartype(m.tiDS) == 'N' and m.tiDS > 0, m.tiDS, set("Datasession"))
		lnResult = aused(taCursor, m.tiDS)
		llResult = m.lnResult > 0
*		ASSERT m.llResult MESSAGE cAssertMsg(Textmerge([Aucun alias trouvé dans la session de données <<m.tiDS>>]))
		if m.llResult
			aColDel(@m.taCursor, 2) && zones de travail inutiles
			dimension taCursor[m.lnResult] && une seule dimension suffit
		endif
	endif
	if m.llResult

		for liAlias = m.lnResult to 1 step -1

			if not lCursor(taCursor[m.liAlias], m.tlReadWrite, m.tiDS)
				adel(taCursor, m.liAlias)
				lnResult = m.lnResult - 1
			endif
		endfor
		if m.lnResult = 0
			aClear(@m.taCursor)
		else
			dimension taCursor[m.lnResult]
			= lTrue(m.tlSort) and asort(taCursor) > 0
		endif
	endif
endif

return m.lnResult

* ========================================
function lFieldPK	&& Un champ est la clé primaire d'une table
lparameters ;
	tcField,; && Champ
	tcTable && [Alias()] Table
local llResult

local lcAlias, llAlias
lcAlias = cAlias(m.tcTable, @m.llAlias)
llResult = used(m.lcAlias)
assert m.llResult message cAssertMsg(textmerge([Impossible d'ouvrir la table <<m.tcTable>>]))
if m.llResult

	llResult = lField(m.tcField, m.lcAlias)
	assert m.llResult message cAssertMsg(textmerge([le champ <<m.tcField>> n'appartient pas à la table <<JustStem(CursorGetProp("SourceName", m.lcAlias))>>]))
	if m.llResult

* Trouver l'index primaire de la table
		local lcTag, lnTag, lcExpr
		lcTag = cTagPC(m.lcAlias, @m.lcExpr, , @m.lnTag, .t.)

		llResult = not empty(m.lcTag);
		 and primary(m.lnTag, m.lcAlias);
		 and upper(m.lcExpr) == upper(m.tcField)
	endif
endif

if m.llAlias
	use in (m.lcAlias)
endif

return m.llResult

* ========================================
function lField	&& Un champ existe dans une table
lparameters ;
	tcField, ; && Nom du champ dont l'existence est a verifier
	tuTable	 && [Alias()] Alias ou adresse de la table où l'existence du champ est à verifier
local lcAlias, llAlias, llResult

if vartype(m.tcField) == 'C'
	lcAlias = iif(empty(m.tuTable), alias(), cAlias(m.tuTable, @m.llAlias)) && optimisation
	if used(m.lcAlias) && AND lVFPName(m.tcField)
		llResult = !empty(field(m.tcField, m.lcAlias))
		if m.llAlias
			use in (m.lcAlias)
		endif
	endif
endif

return m.llResult

* ========================================
function lFieldNull	&& Un champ existe dans l'alias courant ou spécifié et accepte les valeurs NULL
lparameters ;
	tcField, ; && Nom du champ dont l'existence est a verifier
	tuTable	 && [Alias()] Alias ou adresse de la table où l echamp est à verifier
local llResult

llResult = vartype(m.tcField) == 'C' and not empty(m.tcField)
if m.llResult

	local lcAlias, llAlias
	lcAlias = cAlias(m.tuTable, @m.llAlias)
	llResult = used(m.lcAlias)
	assert m.llResult message cAssertMsg(textmerge("Could not find table <<cLitteral(m.tuTable)>>"))
	if m.llResult

		local array laFields[1]
		afields(laFields, m.lcAlias)

		local lnField
		lnField = ascan(m.laFields, upper(alltrim(m.tcField)), 1, -1, 1, 14)
		llResult = m.lnField > 0
		if m.llResult

			llResult = laFields[m.lnField, 5]
		endif
		if m.llAlias
			use in (m.lcAlias)
		endif
	endif
endif

return m.llResult

* ========================================
function lFields	&& Au moins des | tous les champs existent dans l'alias courant ou spécifié
lparameters ;
	tcFields, ; && Liste de champs dont l'existence est a verifier
	tuTable,; && [Alias()] Alias ou adresse de la table où l'existence du champ est à verifier
	tlOneAtLeast &&	[.F.] Au moins un des champs doit être présent ; si .F. et par référence, premier champ manquant en retour

local llResult;
, llOneAtLeast;
, lcAlias;
, llAlias;
, laFields[1];
, lcField;
, llField;
, llExit;

* Si une liste de champs est bien précisée
llResult = vartype(m.tcFields)=='C' and not empty(m.tcFields)
if m.llResult

* Donner leur valeur par défaut aux paramètres optionnels
	llOneAtLeast = uDefault(m.tlOneAtLeast, .f.)
	lcAlias = cAlias(m.tuTable, @m.llAlias)
	llResult = used(m.lcAlias)
	assert m.llResult message cAssertMsg(textmerge("Could not find table <<cLitteral(m.tuTable)>>"))
	if m.llResult

* Tabuler les champs indiqués
		alines(laFields, m.tcFields, .t., ',')

* Pour chaque champ
		for each m.lcField in laFields
			llField = empty(m.lcField) or lField(m.lcField, m.lcAlias)

			if m.llOneAtLeast
				llResult = m.llField or m.llResult && passe à vrai dès qu'un champ est trouvé
				llExit = m.llResult
			else
				llResult = m.llField
				if !m.llResult
					llExit = .t.
					tlOneAtLeast = m.lcField
				endif
			endif

			if m.llExit
				exit
			endif
		endfor

* Refermer l'alias s'il a été ouvert
		if m.llAlias
			use in (m.lcAlias)
		endif
	endif
endif

return m.llResult

* -----------------------------------------------------------------
procedure lFields_Test	&& Dit plusieurs champs existe dans l'alias courant ou spécifié

local loTest as lFields_Test
loTest = createobject('lFields_Test')
loTest.dataopen()

loTest.Test(.t., 'AAA')
loTest.Test(.f., 'DDD')
loTest.Test(.t., 'AAA,BBB')
loTest.Test(.t., 'AAA,  BBB')
loTest.Test(.t., 'AAA,DDD',, .t.)
loTest.Test(.f., 'AAA,DDD')
loTest.Test(.t., 'AAA,BBB', 'TMP', .f.)
loTest.Test(.f., 'AAA,DDD', 'TMP', .f.)
loTest.Test(.t., 'AAA,DDD', 'TMP', .t.)
loTest.Test(.f., 'EEE,DDD', 'TMP', .t.)

return loTest.Result()

* -----------------------------------
define class lFields_Test as abUnitTest of abDev.prg

procedure dataopen
create cursor TMP1 (AAA I, BBB D null, CCC n(2))
create cursor TMP2 (AAA I, BBB D not null, CCC n(2))

enddefine && CLASS lFields_Test

* ========================================
function cFieldsNotIn && Champs d'une table ne se trouvant pas dans une autre (utile en cas d'APPEND FROM)
lparameters ;
  tcTableFrom; && Table dont les champs doivent se trouver dans l'autre
, tcTableIn; && Table cible où chercher les champs
, tcFieldsExclude; && ['WARNING'] Champs à ignorer dans la recherche

local lcResult as string; && vide = OK
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
llResult = used(m.lcAliasFrom) and used(m.lcAliasIn)
assert m.llResult message cAssertMsg(textmerge("Au moins une de ces tables est introuvable: <<cL(m.tcTableFrom)>>, <<cL(m.tcTableIn)>>"))
if m.llResult

* Si les champs de la table From peuvent être Tabulés
	lnFieldFrom = aFieldsShort(@m.lcResult, @m.laFieldFrom, dbf(m.lcAliasFrom))
	llResult = m.lnFieldFrom > 0 && doit toujours être vrai
	if m.llResult

		lnFieldIn = aFieldsShort(@m.lcResult, @m.laFieldIn, dbf(m.lcAliasIn))
		lcResult = ''

* Tabuler les champs à ignorer
		alines(laFieldExclude, upper(uDefault(m.tcFieldsExclude, 'WARNING')), 1+4, ',')

* Pour chaque champ de la table From
		for liFieldFrom = 1 to m.lnFieldFrom
			lcFieldFrom = laFieldFrom[m.liFieldFrom, 1]

* Si le champ source est absent de la table cible et ne peut être ignoré, ajouter à la liste
			if .t.;
			 and empty(ascan(m.laFieldIn, m.lcFieldFrom, 1, -1, 1, 7)) ;
			 and empty(ascan(laFieldExclude, m.lcFieldFrom, 1, -1, 1, 7))

				lcResult = c2Words(m.lcResult, ',', m.lcFieldFrom)
			endif
		endfor
	endif
endif

* Refermer les tables si elles ont été ouvertes
if m.llTableFrom
	use in select(m.lcAliasFrom)
endif
if m.llTableIn
	use in select(m.lcAliasIn)
endif

return m.lcResult

* ========================================
function aFieldsShort && noms de champs courts
lparameters ;
  Result; && @ {fr} résultat (cumulatif)
, taField; && @ {fr} champs
, tcDBF;

external array taField

local lnResult as integer;
, lcAlias;
, llAlias;
, lcFields;
, lcField;
, liField;

lnResult = 0

lcAlias = cAlias(m.tcDBF, @m.llAlias,, @m.Result)
if used(m.lcAlias)

  lnResult = fcount(m.lcAlias)
  dimension taField[m.lnResult]
  for liField = 1 to m.lnResult
  	lcField = field(m.liField, m.lcAlias)
  	if lenc(m.lcField) > 10
		  if empty(m.lcFields)
		  	if isexclusive(m.lcAlias)
		  		cResultAdd(@m.Result, textmerge([Can't get the short field name of '<<m.lcField>>' in '<<m.tcDBF>>' because it's used Exclusive]))
		  		lnResult = 0
		  		exit
		  	else
				  lcFields = substr(left(filetostr(m.tcDBF), 10^4), 33) && 32*254 < 10^4
		  	endif
		  endif
		  lcField = trim(substr(m.lcFields, m.liField * 32 - 31, 10), chr(0))
  	endif
    taField[m.liField] = m.lcField
  endfor
  if m.llAlias
  	use in (m.lcAlias)
  endif
endif

return m.lnResult
endfunc

* ========================================
function cFieldExp && Expression de champ pour instruction CREATE / ALTER TABLE SQL
lparameters ;
	tcField,; && Nom du champ ; si @ nom valide en retour
	tcType,; && Type de champ selon abréviations VFP C,N,L, etc.
	tuLen,; && Longueur du champ
	tuDec,; && Nombre de décimales en cas de champ numérique
	tuNull && [.F.] Valeurs null acceptées; si type # 'L', pas précisé (SET NULL agit)

local llResult, lcResult
lcResult = ''

llResult = vartype(m.tcField) == 'C'
assert m.llResult message cAssertMsg(textmerge([Nom de champ invalide : <<cLitteral(m.tcField)>>]))
if m.llResult
	tcField = cVFPName(m.tcField, 10)

	llResult = vartype(m.tcType) == 'C'
	if m.llResult
		tcType = upper(alltrim(m.tcType))
		llResult = m.tcType $ VFP9_FIELD_TYPES
	endif
	assert m.llResult message cAssertMsg(textmerge([Type de champ non supporté par VFP : <<cLitteral(m.tcType)>>]))
	if m.llResult

		lcResult = c2Words(m.tcField, space(1), m.tcType)

		if not m.tcType $ VFP9_FIELD_TYPES_FIXED_LEN ;
		 and vartype(m.tuLen) $ 'CN'

			local lcLen, lcDec
			lcLen = alltrim(iif(vartype(m.tuLen) = 'C', m.tuLen, str(m.tuLen)))

			if m.tcType $ VFP9_FIELD_TYPES_WITH_DEC ;
			 and vartype(m.tuDec) $ 'CN'
				lcDec = alltrim(iif(vartype(m.tuDec) = 'C', m.tuDec, str(m.tuDec)))
				lcDec = iif(val(m.lcDec) = 0, '', m.lcDec)
			else
				lcDec = ''
			endif
			lcResult = textmerge([<<m.lcResult>>(<<m.lcLen>><<Iif(Empty(m.lcDec), '', ',' + m.lcDec)>>)])
		endif

		if vartype(m.tuNull) == 'L'
			lcResult = textmerge([<<m.lcResult>> <<Iif(m.tuNull, 'NULL', 'NOT NULL')>>])
		endif
	endif
endif

return m.lcResult

* -----------------------------------------------------------------
procedure cFieldExp_Test

local loTest
loTest = newobject('abUnitTest', 'abDev.prg')
loTest.Test('TOTO_EST_U N(5,3)', 'toto est un idiot', 'N', 5, 3)
loTest.Test('TOTO C(5)', 'toto', 'C', 5, 3)

return loTest.Result()

* ========================================
function cFieldExpFrom && Expression de champ pour instruction CREATE / ALTER TABLE SQL selon un champ existant
lparameters ;
	tcField,; && Champ
	tcTable,; && Table
	tlNullIgnore,; && [.F.] Ignorer le réglage SET NULL du champ
	tlNameIgnore && [.F.] Ignorer le nom du champ

local lcAlias, llAlias, laField[1], lnField, llResult, lcResult

lcResult = ''
lcAlias = cAlias(m.tcTable, @m.llAlias)
llResult = used(m.lcAlias)
if m.llResult

	afields(laField, m.lcAlias)
	lnField = ascan(laField, alltrim(m.tcField), 1, -1, 1, 15)
	llResult = m.lnField > 0
	assert m.llResult message cAssertMsg(textmerge([le champ <<m.tcField>> doit appartenir à la table <<m.tcTable>>]))
	if m.llResult

		lcResult = cFieldExp(;
				  iif(lTrue(m.tlNameIgnore), '', laField[m.lnField, AFIELDS_NAME]);
				, laField[m.lnField, AFIELDS_TYPE];
				, laField[m.lnField, AFIELDS_WIDTH];
				, laField[m.lnField, AFIELDS_PRECISION];
				, iif(lTrue(m.tlNullIgnore), .null., laField[m.lnField, AFIELDS_NULL]);
				)
	endif
endif

if m.llAlias
	use in (m.lcAlias)
endif

return m.lcResult

* -----------------------------------------------------------------
procedure cFieldExpFrom_Test && Teste cFieldExpFrom()

local loTest as FieldExpFrom_Test of abData.prg
loTest = createobject('FieldExpFrom_Test')
loTest.dataopen()

loTest.Test('UNIQUEID C(10) NOT NULL', 'uniqueId', m.loTest.cAlias)
loTest.Test('TIMESTAMP T NOT NULL', 'timestamp', m.loTest.cAlias)
loTest.Test('USER M NOT NULL', 'user', m.loTest.cAlias)

return loTest.Result()

* ------------------------------
define class FieldExpFrom_Test as abUnitTest of abDev.prg
	cAlias = "FoxCodeTest"
	procedure dataopen
		use (_foxcode) in 0 again alias (m.this.cAlias)
	enddefine

* ========================================
function cFieldsExpFrom && Expression de champs pour instruction CREATE / ALTER TABLE SQL d'après une table
lparameters ;
	tuTable,; && [Alias()] Alias ou Zone ou adresse de la table
	tlParenth,; && [.F.] Ajouter les parenthèses autour de l'expression
	tcSep,; && [','] Séparateur entre champs
	tlNullIgnore; && [.F.] Ignorer le réglage SET NULL du champ

local Result as string;
, cAlias as string;
, lAlias as Boolean;
, laField[1];

Result = ''

cAlias = cAlias(m.tuTable, @m.lAlias)
if used(m.cAlias)

	afields(laField, m.cAlias)
	Result = cFieldsExp(@m.laField, m.tlParenth, m.tcSep, m.tlNullIgnore)

	if m.lAlias
		use in (m.cAlias)
	endif
endif

return m.Result
endfunc

* ========================================
function aFieldsType && Types des champs d'une table
lparameters ;
  aFieldsType; && @ Tableau en retour
, tuTable; && [Alias()] Alias ou Zone ou adresse de la table

local Result as string;
, cAlias as string;
, lAlias as Boolean;

Result = ''

cAlias = cAlias(m.tuTable, @m.lAlias)
if used(m.cAlias)

	Result = afields(aFieldsType, m.cAlias)

	aColDel(@m.aFieldsType, 1)
	aColsDel(@m.aFieldsType, 2)

	dimension m.aFieldsType[m.result]

	if m.lAlias
		use in (m.cAlias)
	endif
endif

return m.Result
endfunc

* ========================================
function cFieldsExp && Expression de champs pour instruction CREATE / ALTER TABLE SQL
lparameters ;
	taFields,; && @ Définitions de champs selon aFields()
	tlParenth,; && [.F.] Ajouter les parenthèses autour de l'expression
	tcSep,; && [','] Séparateur entre champs
	tlNullIgnore; && [.F.] Ignorer le réglage SET NULL du champ

external array taFields

local lcResult as string;
, llResult as Boolean;
, lnCol as integer;
, liField as integer;
, lcFieldExp as string

lcResult = ''

llResult = type('taFields', 1) == 'A'
assert m.llResult message cAssertMsg(textmerge([Tableau attendu : <<cLitteral(@m.taFields)>>]))
if m.llResult

	lnCol = alen(taFields, 2)
	llResult = m.lnCol >= 4
	assert m.llResult message cAssertMsg(textmerge([Au moins 4 colonnes attendues dans le tableau : <<cLitteral(@m.taFields)>>]))
	if m.llResult

		tcSep = iif(vartype(m.tcSep) == 'C' and len(m.tcSep) > 0, m.tcSep, ',')
		tlNullIgnore = (lTrue(m.tlNullIgnore)) or m.lnCol = 4

* Pour chaque champ
		for liField = 1 to alen(taFields, 1)

			lcFieldExp = cFieldExp(;
					taFields[m.liField, 1];
				, taFields[m.liField, 2];
				, taFields[m.liField, 3];
				, taFields[m.liField, 4];
				, iif(m.tlNullIgnore, 'ignore', taFields[m.liField, 5]);
				)
			if empty(m.lcFieldExp)
				llResult = .f.
				exit
			else
				lcResult = m.lcResult + m.tcSep + m.lcFieldExp
			endif
		endfor
		lcResult = substr(m.lcResult, len(m.tcSep) + 1) && ôte le séparateur initial
	endif
endif

* Si OK, ajouter les parenthèses le cas échéant
return iif(m.llResult;
	, iif(lTrue(m.tlParenth), '(' + m.lcResult + ')', m.lcResult);
	, '')

* ========================================
function cFields && Champs d'une table répondant à un masque
lparameters ;
  tuTable; && [Alias()] Alias ou Zone ou adresse de la table
, tcSkeleton; && [All] Masque de nom des champs à lister
, tlExcept; && [.F.] Lister tous les champs SAUF ceux répondant au masque tcSkeleton
, tcDelim; && [','] Séparateur des champs
, tlSort; && [.F.] Trier les champs par ordre alphabétique
, tlLitterals; && [.F.] Lister les champs comme littérals

local lcResult as string;
, laField[1] as string;

lcResult = ''

if aFieldsSkeleton(@m.laField, m.tuTable, m.tcSkeleton, m.tlExcept) > 0

	if m.tlSort
		asort(laField)
	endif

	lcResult = cListOfArray(@m.laField, m.tcDelim,,m.tlLitterals)
endif

return m.lcResult

* -----------------------------------------------------------------
procedure cFields_Test

local loTest
loTest = createobject('cFieldsTest')

loTest.Test('UNIQUEID,USER', _foxcode, 'U*') && toutes sessions de données

loTest.dataopen()
loTest.Test('UNIQUEID,USER', 'FoxCodeTest', 'U*') && dans session de données privée

return loTest.Result()

* ------------------------------
define class cFieldsTest as abUnitTest of abDev.prg

	procedure dataopen
		use (_foxcode) in 0 again alias FoxCodeTest

	enddefine

* ========================================
function cFieldsMemvar && Champs d'une table répondant à un masque qui sont des variables mémoire
lparameters ;
	tuTable,; && [Alias()] Alias ou Zone ou adresse de la table
	tcSkeleton,; && [All] Masque de nom des champs à lister
	tlExcept && [.F.] Lister tous les champs SAUF ceux répondant au masque tcSkeleton

local lnFields, laField[1], lnField, lcField, lcResult
lcResult = ''

lnFields = aFieldsSkeleton(@m.laField, m.tuTable, m.tcSkeleton, m.tlExcept)
if m.lnFields > 0

	for m.lnField = 1 to m.lnFields
		lcField = laField[m.lnField]
		if not vartype(m.lcField) == 'U'
			lcResult = c2Words(m.lcResult, ',', m.lcField)
		endif
	endfor
endif

return m.lcResult

* ========================================
function aFieldsSkeleton && Champs d'une table répondant à un masque
lparameters ;
	taFields,; && @ Champs trouvés (1 colonne)
	tuTable,; && [Alias()] Alias ou Zone ou adresse de la table
	tcSkeleton,; && [All] Masque de nom des champs à lister
	tlExcept,; && [.F.] Lister tous les champs SAUF ceux répondant au masque tcSkeleton
	tlColsKeep && [.F.] Garder les colonnes 2 et suivante ; si .F., ne garder que les noms des champs
external array taFields

local lcAlias, llAlias, lnSelect, llResult, lnResult && Nombre de champs trouvés
lnResult = 0

* Si la table communiquée est valide
lcAlias = cAlias(m.tuTable, @m.llAlias)
llResult = used(m.lcAlias)
assert m.llResult message cAssertMsg('Invalid required parameter')
if m.llResult

* Donner leur valeur par défaut aux paramètres
	tcSkeleton = evl(m.tcSkeleton, '')
	tlExcept = lTrue(m.tlExcept)
	tlColsKeep = lTrue(m.tlColsKeep)

* Sélectionner l'alias
	lnSelect = select(0)
	select (m.lcAlias)

* Si un squelette de champs a été précisé, filtrer sur ces champs
	if not empty(m.tcSkeleton)
		local lcSetField, lcSetFields
		tcSkeleton = 'ALL ' + iif(m.tlExcept, 'EXCEPT ', 'LIKE ') + m.tcSkeleton
		lcSetField = set('FIELDS')
		lcSetFields = set('FIELDS', 1)
		set fields to && nécessaire car SET FIELDS TO est additif
		set fields to &tcSkeleton
	endif

	lnResult = afields(taFields)
	if m.lnResult > 0 and not m.tlColsKeep
		aColsDel(@m.taFields, 2)
	endif

* Si un squelette de champs a été précisé, rétablir le filtre de champs antérieur
	if not empty(m.tcSkeleton)
		set fields to &lcSetFields
		set fields &lcSetField
	endif

	if m.llAlias
		use in (m.lcAlias)
	endif
	select (m.lnSelect)
endif

return m.lnResult

* ========================================
procedure RecInsert	&& Insère ou ajoute un enregistrement dans une table après l'enregistrement courant
&& Si succès, la table est positionnée sur le NOUVEL ENREGISTREMENT
lparameters ;
	tuTable, ;	&& [alias()] Alias ou zone de travail de la table où doit être ajouté l'enregistrement
	tlCarry		&& [.F.] Recopier l'enr. courant dans le nouveau (si .F., nouvel enregistrement vide)
local llResult && un enregistrement a été inséré

* ================================================================
* Date		Par	Action
* --------	---	-----------------------------------------------
* 26/06/01	TN		Création
* 26/09/02	TN		2nd partie INUTILE l'instruction INSERT fait la même chose !!!
* ================================================================

local lcAlias
lcAlias = cAlias(m.tuTable)
lcAlias = ExclusiveForce(m.lcAlias)
if used(m.lcAlias)

	local lnSelect, llBOF, lnNoEnrCour
	lnSelect = select (0)
	select (m.lcAlias)
	llBOF = bof()
	lnNoEnrCour = iif(m.llBOF, 0, recno ())

* Si le carry a été demandé, mémoriser l'enregistrement courant
	local llCarry
	llCarry = uDefault(m.tlCarry, .f.)
	if m.llCarry
		local array laEnrCour[1]
		scatter to laEnrCour
	endif

* SI LA TABLE EST SUR LE DERNIER ENREGISTREMENT, AJOUTER UN ENREGISTREMENT À LA FIN
	if m.lnNoEnrCour = reccount ()		&&	la table est sur le dernier enregistrement : nous n'avons qu'à ajouter un enr.
		if m.llCarry
			append from array laEnrCour
		else
			append blank
		endif

* SINON INSÉRER UN ENREGISTREMENT APRÈS L'ENREGISTREMENT COURANT
	else	&&	la table n'est pas sur le dernier enregistrement : nous devons insérer en passant par un curseur

* Obtenir l'adresse complète de la table
* Mémoriser la zone où la table est ouverte pour la rouvrir au même endroit
		local lcAdrTab, lnZoneTab, lcOrder
		lcAdrTab = cTableAddress()
		lnZoneTab = select(0)		&& nécessaire pour le bon fonctionnement d'un éventuel scan sur la table
		lcOrder = order ()

* Créer un curseur à l'image de la table source
		local lcNomCurs
		local array laStruTab[1]
		 = afields (laStruTab)
		use in (m.lcAlias)
		lcNomCurs = 'RecInsert_' + upper (m.lcAlias)
		create cursor (m.lcNomCurs) from array laStruTab

* Remplir le curseur
		select (m.lcNomCurs)
* Copier la table source dans le Curseur jusqu'à la position mémorisée,
		append from (m.lcAdrTab) for recno () <= m.lnNoEnrCour
* Ajouter la nouvelle ligne au Curseur
		if m.llCarry
			append from array laEnrCour
		else
			append blank
		endif
* Copier le reste de la table source dans le Curseur
		append from (m.lcAdrTab) for recno () > m.lnNoEnrCour

* Mettre à jour et rouvrir la table source
		local lcRestSafety
		lcRestSafety = 'set safety ' + set ('safety')
		set safety off
		copy to (m.lcAdrTab)
		&lcRestSafety
		use && Supprime le Curseur
* Rouvrir la table source dans la même zone que précédemment
		select (m.lnZoneTab)
		use (m.lcAdrTab) exclusive alias (m.lcAlias) order (m.lcOrder)

	endif 	&&	&&	nous sommes sur le dernier enregistrement

* Rétablir l'environnement des tables
	go m.lnNoEnrCour + 1	&&	se positionner sur le nouvel enregistrement
	select (m.lnSelect)
	llResult = .t.
endif	&& isExclusive (lcAlias)

return m.llResult

* ========================================
function cFieldsCarIndexExp && Expression d'index composite en caractère sur une liste de champs de types quelconques
lparameters ;
	tcTable,; && [Alias()] Alias, zone ou adresse de la table
	tcIdxFields,;	&& Liste de champs
	tnLength && @ Longueur de la clé d'index composite en caractères

tnLength = 0

local lcResult;
, lcAlias, llAlias;
, lnSelect;
, lnIdxFields, laIdxFields[1];
, lnMax, lnExc

lcResult = ''

lcAlias = cAlias(m.tcTable, @m.llAlias)
if used(m.lcAlias)
	lnSelect = select(0)
	select (m.lcAlias)

* Si les champs à indexer existent dans la table
	if lFields(m.tcIdxFields)

* Tabuler les champs à indexer
		lnIdxFields = alines(laIdxFields, m.tcIdxFields, .t., ',')

* Calculer l'index et sa longueur
		tnLength = aFieldsCarIndexExp(@m.laIdxFields)

* Si l'index a une longueur supérieure au maximum
		lnMax = iif(inlist(upper(set('COLLATE')), 'MACHINE', 'UNIQWT'; && Unique Weight
			), 240, 120)
		lnExc = m.tnLength - m.lnMax
		if m.lnExc > 0

* Calculer la longueur totale des champs caractères réductibles
			local lnIdxField, lnIdx, lnIdxTot, lnIdxMin, lnIdxTop, lnIdxTopNo
			store 0 to m.lnIdxTot, lnIdxMin, m.lnIdxTop
			for m.lnIdxField = 1 to m.lnIdxFields
				if laIdxFields[m.lnIdxField, 2] == 'C' ;
				 and laIdxFields[m.lnIdxField, 3] > 10
					lnIdx = laIdxFields[m.lnIdxField, 3]
					lnIdxTot = m.lnIdxTot + m.lnIdx
					lnIdxMin = m.lnIdxMin + 10

* Détecter le champ plus long
					if m.lnIdx > m.lnIdxTop
						lnIdxTop = m.lnIdx
						lnIdxTopNo = m.lnIdxField
					endif
				endif
			endfor

* Si les expressions sur caractères réductibles peuvent absorber l'excédent
			if m.lnIdxTot - m.lnIdxMin >= m.lnExc

* Si le champ le plus long peut accepter toute la réduction, réduire lui seul
				if m.lnIdxTop > 80 ;
				 and m.lnExc < m.lnIdxTop / 2
					lnIdx = m.lnIdxTop - m.lnExc
					laIdxFields[m.lnIdxTopNo, 5] = m.lnIdx
					laIdxFields[m.lnIdxTopNo, 6] = ;
						'Left(' + laIdxFields[m.lnIdxTopNo, 1] + ',' + transform(m.lnIdx) + ')'
					tnLength = m.tnLength - m.lnExc

* Sinon, réduire proportionnellement chaque champ réductible
				else
					local lnReduc
					lnReduc = (m.lnIdxTot - m.lnExc) / m.lnIdxTot
					for m.lnIdxField = 1 to m.lnIdxFields
						if laIdxFields[m.lnIdxField, 2] == 'C' ;
						 and laIdxFields[m.lnIdxField, 3] > 10
							lnIdx = int(laIdxFields[m.lnIdxField, 5] * m.lnReduc)
							tnLength = m.tnLength - laIdxFields[m.lnIdxField, 5] + m.lnIdx
							laIdxFields[m.lnIdxField, 5] = m.lnIdx
							laIdxFields[m.lnIdxField, 6] = ;
								'Upper(Left(' + laIdxFields[m.lnIdxField, 1] + ',' + transform(m.lnIdx) + '))'
						endif
					endfor
				endif

			else
				tnLength = 0
			endif
		endif
	endif
	if m.llAlias
		use
	endif
	select (m.lnSelect)
endif

if m.tnLength > 0
	lcResult = cListOfArray(@m.laIdxFields, '+', 6)
endif

return m.lcResult

* ========================================
function aFieldsCarIndexExp && Expressions d'index caractère sur des champs de types quelconques
lparameters ;
	taIdxFields && @ Champs à indexer (6 colonnes)
local lnResult && Longueur de la clé composite caractères
lnResult = 0

external array taIdxFields

* S'assurer que le tableau a le nombre de colonnes nécessaire
local lnCols
lnCols = alen(taIdxFields, 2)
if m.lnCols < 6
	aColsIns(@m.taIdxFields, m.lnCols, 6 - m.lnCols)
endif

* Tabuler les champs de la table
local array laFields[1]
afields(laFields)

* Pour chaque champ à indexer
local lnIdxFields, lnIdxField, lcField, lnField, lcType, lnWidth, lnPrec, lcIndexExp, lnIndexExp
lnIdxFields = alen(taIdxFields, 1)
for m.lnIdxField = 1 to m.lnIdxFields
	lcField = taIdxFields[m.lnIdxField, 1]

* Lire les caractéristiques du champ
	lnField = ascan(laFields, m.lcField, 1, -1, 1, 1+2+4+8)
	lcType = laFields[m.lnField, 2]
	lnWidth = laFields[m.lnField, 3]
	lnPrec = laFields[m.lnField, 4]

* Si l'expression d'indexation peut être construite
	lcIndexExp = cFieldCarIndexExp(m.lcField, m.lcType, m.lnWidth, m.lnPrec)
	if not empty(m.lcIndexExp)

* Mémoriser l'expression et sa longueur dans le tableau
		taIdxFields[m.lnIdxField, 2] = m.lcType
		taIdxFields[m.lnIdxField, 3] = m.lnWidth
		taIdxFields[m.lnIdxField, 4] = m.lnPrec

		lnIndexExp = len(evaluate(m.lcIndexExp))
		taIdxFields[m.lnIdxField, 5] = m.lnIndexExp

		lcIndexExp = iif(m.lcType == 'C', 'Upper(' + m.lcIndexExp + ')', m.lcIndexExp)
		taIdxFields[m.lnIdxField, 6] = m.lcIndexExp

		lnResult = m.lnResult + m.lnIndexExp

* Sinon (type non supporté), sortir et terminer
	else
		lnResult = 0
		exit
	endif
endfor

return m.lnResult

* ========================================
function cFieldCarIndexExp && Expression d'index en caractère sur un champ de type quelconque
lparameters ;
	tcField,;	&& Nom du champ
	tcType,; && Type de champ ($ 'CDTNFIYL')
	tnWidth,; && Longueur, partie entière si champ de type N ou F
	tnPrecision && partie décimale si champ de type N ou F
local lcResult

do case
case m.tcType == 'C'
	lcResult = m.tcField
case m.tcType == 'D'
	lcResult = 'dtoc(' + m.tcField + ',1)'
case m.tcType == 'T'
	lcResult = 'ttoc(' + m.tcField + ',1)'
case m.tcType $ 'NF'
	lcResult = 'Str(' + m.tcField + ',' + transform(m.tnWidth) + ',' + transform(m.tnPrecision) + ')'
case m.tcType == 'I'
	lcResult = 'str(' + m.tcField + ',10)'
case m.tcType == 'Y'
	lcResult = 'str(MtoN(' + m.tcField + '),15,4)'
case m.tcType == 'L'
	lcResult = 'iif(' + m.tcField + ',"1","0")'
otherwise && M, B ou G : indexation impossible
	lcResult = ''
endcase

return m.lcResult

* ========================================
procedure FreeTableSlim	&& Table libre : supprime les lignes vides et réduit la largeur des champs caractère au minimum
lparameters ;
	tuTable,;	&& Alias, zone ou adresse d'une table
	tnLenPercent && [0] Pourcentage de la longueur des champs caractères à ajouter en réserve

local lcAlias, llAlias, llExclusive, llResult

* Si la table peut être ouverte en exclusif
lcAlias = cAlias(m.tuTable, @m.llAlias, .t.)
llResult = used(m.lcAlias)
if m.llResult

	loSelect = abSelect(m.lcAlias)

* Lire la structure de la table
	local laFields[1], lnFields, lnField, llMemo
	lnFields = afields(laFields)
	llMemo = file(forceext(dbf(m.lcAlias), 'FPT'))

* Initialiser les longueurs mini des champs caractères
	for m.lnField = 1 to m.lnFields
		if laFields[m.lnField, 2] == 'C' && seuls les champs caractères sont redimensionnables
			laFields[m.lnField, 16] = 1	&& Tables comments
		endif
	endfor

* Pour chaque enregistrement
	local lnLenFact, luField, llRecEmpty, llPack
	lnLenFact = 1 + iif(vartype(m.tnLenPercent) == 'N' and m.tnLenPercent > 0, m.tnLenPercent, 0) / 100
	scan

* Pour chaque champ
		llRecEmpty = .t.
		for m.lnField = 1 to m.lnFields
			luField = evaluate(laFields[m.lnField,1])
			llRecEmpty = m.llRecEmpty and (empty(m.luField) or isnull(m.luField))

* Si champ caractère, mémoriser longueur max. du contenu
			if laFields[m.lnField, 2] == 'C'
				laFields[m.lnField, 16] = max(laFields[m.lnField, 16], int(len(rtrim(m.luField)) * m.lnLenFact))
				if laFields[m.lnField, 16] > 254
					laFields[m.lnField, AFIELDS_TYPE] = 'M'
					laFields[m.lnField, AFIELDS_WIDTH] = 4
					laFields[m.lnField, AFIELDS_PRECISION] = 0
					llMemo = .t.
				endif
			endif
		endfor

* Si tous les champs sont vides, marquer pour suppression
		if m.llRecEmpty
			delete
			llPack = .t.
		endif
	endscan

	if m.llPack and not lCursor() && AND Set('Deleted') == 'OFF'
		pack
		delete file (forceext(cTableAddress(lcAlias), 'BAK'))
	endif

* Si la structure peut être allégée
	local llChangeStru
	for m.lnField = 1 to m.lnFields
		if laFields[m.lnField, 2] == 'C'
			llChangeStru = m.llChangeStru or laFields[m.lnField,16] < laFields[m.lnField,3]
			laFields[m.lnField,3] = laFields[m.lnField,16]
		endif
	endfor
	if m.llChangeStru

* Créer une nouvelle table
		local lcTableAddr, lnSelect, lcAliasNouv, lcTableNouvAddr, lcExclusive
		lcTableAddr = cTableAddress(m.lcAlias)
		lnSelect = select(m.lcAlias)
		use
		lcAliasNouv = sys(2015)
		lcTableNouvAddr = addbs(justpath(m.lcTableAddr)) + forceext(m.lcAliasNouv, [dbf])
		create table (m.lcTableNouvAddr) free from array laFields
		append from (m.lcTableAddr)
		use
		delete file (m.lcTableAddr)
		rename (m.lcTableNouvAddr) to (m.lcTableAddr)
		if m.llMemo
			delete file (forceext(m.lcTableAddr, 'FPT'))
			rename (forceext(m.lcTableNouvAddr, 'FPT')) to (forceext(m.lcTableAddr, 'FPT'))
		endif
		lcExclusive = iif(m.llExclusive, 'EXCLUSIVE', '')
		use (m.lcTableAddr) in m.lnSelect alias (m.lcAlias) &lcExclusive
	endif

	if m.llAlias
		use in (m.lcAlias)
	endif
endif

return m.llResult

* ========================================
procedure BlankLinesDel && Supprime les enregistrements vides d'une table
lparameters ;
	tuTable	&& Alias ou adresse d'une table
local llResult

* Si on peut accéder à la table indiquée
local lcAlias, llAlias
lcAlias = cAlias(m.tuTable, @m.llAlias)
llResult = used(m.lcAlias)
assert m.llResult message "Impossible d'ouvrir la table indiquée : " + transform(m.tuTable)
if m.llResult
	local lnSelect
	lnSelect = select(0)
	select (m.lcAlias)

* Pour chaque enregistrement
	local lnFields, lnField, llRecEmpty
	lnFields = fcount()
	scan

* Pour chaque champ
		llRecEmpty = .t.
		for m.lnField = 1 to m.lnFields
			if not empty(evaluate(field(m.lnField)))
				llRecEmpty = .f.
				exit
			endif
		endfor

* Si tous les champs sont vides, supprimer l'enregistrement
		if m.llRecEmpty
			delete
		endif
	endscan

* Si la table a été ouverte, refermer
	if m.llAlias
		use
	endif
	select (m.lnSelect)
endif

return llResult

* ========================================
procedure BlankColsDel && Supprime les colonnes vides d'une table
lparameters ;
	tuTable	&& Alias ou adresse d'une table
local llResult

* Si on peut accéder à la table indiquée
local lcAlias, llAlias
lcAlias = cAlias(m.tuTable, @m.llAlias)
llResult = used(m.lcAlias)
assert m.llResult message "Impossible d'ouvrir la table indiquée : " + transform(m.tuTable)
if m.llResult
	local lnSelect
	lnSelect = select(0)
	select (m.lcAlias)

* Tabuler les champs de la table
	local array laFields[1]
	local lnFields, lnField, lcField, luField
	lnFields = afields(laFields)
	aColsDel(@m.laFields, 2)
	aColsIns(@m.laFields, 1, 3) && 1-nom, 2-valeur vide, 3-colonne vide

* Initialiser la valeur vide de chaque champ
	go bottom
	skip && EOF()
	for m.lnField = 1 to m.lnFields
		laFields[m.lnField, 2] = evaluate(laFields[m.lnField,1])
		laFields[m.lnField, 3] = .t.
	endfor

* Pour chaque enregistrement et chaque champ
	scan
		for m.lnField = 1 to m.lnFields

* Basculer si non vide
			laFields[m.lnField, 3] = laFields[m.lnField, 3] ;
			 and laFields[m.lnField, 2] == evaluate(laFields[m.lnField,1])
		endfor
	endscan

* Si au moins une colonne est vide
	local lcAlter
	lcAlter = ''
	for m.lnField = 1 to m.lnFields
		if laFields[m.lnField, 3]
			lcAlter = c2Words(m.lcAlter, space(1) ;
				, 'DROP COLUMN ' + laFields[m.lnField, 1])
		endif
	endfor
	if not empty(m.lcAlter)

* Si la table peut être ouverte en exclusif
		lcAlias = ExclusiveForce(m.lcAlias)
		llResult = used(m.lcAlias)
		if m.llResult

* Supprimer les colonnes vides
			alter table (m.lcAlias) &lcAlter
		endif
	endif

* Si la table a été ouverte, refermer
	if m.llAlias
		use
	endif
	select (m.lnSelect)
endif

return llResult

* ========================================
function cTableCheckSum && Checksum du contenu d'une table
lparameters tuTable && [Alias()] Alias ou Zone ou adresse d'une table

local lcTableAddr, lcData, loSelect, lnRecno, lnResult, llResult, lcResult
lcResult = ''

* Si la table est définie
tuTable = evl(m.tuTable, alias())
llResult = not empty(m.tuTable)
assert m.llResult message cAssertMsg(textmerge([Spécification de table invalide : <<cLitteral(m.tuTable)>>]))
if m.llResult

* Si la table existe
	lcTableAddr = iif(used(m.tuTable), cTableAddress(m.tuTable), m.tuTable)
*		ASSERT m.llResult MESSAGE cAssertMsg(Textmerge('Table can't be found: <<cLitteral(m.lcTableAddr)>>'))
	if file(m.lcTableAddr);
	 and not isexclusive(m.tuTable) && 'File access is denied' si la table ouverte en exclusif (curseur, vue, etc.)

* Calculer le checksum des données seules
		lcData = FileMemo(m.lcTableAddr)
		lcResult = sys(2007;
			, substr(filetostr(m.lcTableAddr), 5) + iif(file(m.lcData), filetostr(m.lcData), ''); && à partir du 5ème octet, devrait supporter plus de 16 MO
			, -1; && For CRC32 calculations, Visual FoxPro disregards nSeed
			, 1; && Calculate checksum value using CRC32 checksum algorithm.
			)

	else && curseur ou table ouverte en exclusif

		loSelect = abSelect(m.tuTable)

		if inlist(cursorgetprop("Buffering"), 2, 3) && tampon d'enregistrement, impossible de parcourir la table ...
			rand(-1)
			lcResult = transform(int(rand()*10E10)) && ... toujours dire que son contenu a changé
		else
			lnRecno = Recno_()
			lnResult = 0
			scan
				lnResult = m.lnResult + int(val(sys(2017, '', -1, 3))) && 3 : Calculate checksum based on current record contents including Memo fields using CRC32
*				lcResult = m.lcResult + Sys(2017, '', -1, 3)
			endscan
			RecnoSet(m.lnRecno)
			lcResult = transform(m.lnResult)
		endif
	endif
endif

return m.lcResult

* ========================================
procedure TableStruCheck && Vérifie la structure d'une table, l'ajuste si nécessaire
lparameters ;
	tcTable,; && Alias ou adresse de la table
	tcFieldsExp && Expression de description de structure comme dans une commande CREATE TABLE

local lcAlias, llAlias, laFields[1], lcFieldsExp, lcFieldExp;
	, lcAlter, llResult, lcResult && Alias de la table vérifiée (vide si ajustement impossible)

lcResult = ''

* Si la table est accessible
lcAlias = cAlias(m.tcTable, @m.llAlias)
llResult = used(m.lcAlias)
assert m.llResult message cAssertMsg(textmerge([Alias invalide : <<cLitteral(m.tcTable)>>]))
if m.llResult

* Si l'Expression de description de structure est valide
	llResult = lFieldsExp(m.tcFieldsExp)
	assert m.llResult message cAssertMsg(textmerge([Spécifications de champs invalide : <<cLitteral(m.tcFieldsExp)>>]))
	if m.llResult

		lcResult = m.lcAlias

* Si la structure est différente de celle spécifiée
		afields(laFields, m.lcResult)
		lcFieldsExp = cFieldsExp(@m.laFields)
		llResult = cComparable(m.lcFieldsExp) == cComparable(m.tcFieldsExp)
		if not m.llResult

* Si la table peut être ouverte en exclusif
			lcResult = ExclusiveForce(m.lcResult)
			llResult = used(m.lcResult)
			assert m.llResult message cAssertMsg(textmerge([Impossible d'ouvrir la table en exclusif : <<cLitteral(cTableAddress(m.lcResult))>>]))
			if m.llResult

* Ajuster la structure selon la spec.
				aFieldsExp(@m.laFields, m.tcFieldsExp)
				lcAlter = ''
				for each m.lcFieldExp in laFields
					lcAlter = m.lcAlter + ' ALTER COLUMN ' + m.lcFieldExp
				endfor
				alter table (m.lcResult)&lcAlter
			endif
		endif
	endif

	if m.llAlias
		use in (m.lcAlias)
	endif
endif

return m.lcResult

* ========================================
procedure TableFreeCreateOrAdjust && Crée ou ouvre (et ajuste) une table libre selon une spécification de champs et d'indexes
lparameters ;
	tcTable,; && [cursor] Alias ou adresse de table, vide pour création d'un curseur
	tcAlias,; && @ [JustStem(m.tcTable)||Sys(2015)] Alias de la table, sinon du curseur
	tuFields,; && @array||String Spécification de champs selon aFields(), aLines() ou CREATE/ALTER TABLE
	tuTagInfo,; && @ Spécification d'indexes au format aTagInfo(), tabulées ou délimitées par ';' ou \t -  [Tag, Type, Key, Filter, Order, Collation]
	tlCreated,; && @ [idem] La table a été créée
	tlAdjusted,; && @ [idem] La structure de la table et/ou ses indexes ont été ajustés
	tcResult && @ [''] Résultat
tcResult = ''

local llResult as Boolean;
, laFields[1],	laTagInfo[1];
, lcAlias, llAlias, llCursor, lcTable, loSelect as abSelect, loSafety as abSet, llExclusive;
, lcFields, llFields;
, laTag[1], lnTags, llTags, liTag, llZap, lcTag;

* Tabuler les spécifications de champs et d'indexes
llResult = aFields_(@m.laFields, m.tuFields) > 0
if m.llResult
	aTagInfo_(@m.laTagInfo, m.tuTagInfo)

* Ouvrir la table si elle existe
	llCursor = empty(m.tcTable)
	if not m.llCursor
		lcAlias = cAlias(m.tcTable)
		llAlias = used(m.lcAlias)
		llCursor = not (m.llAlias or lFileAddress(m.tcTable))
	endif

	loSelect = abSelect(iif(m.llAlias, m.lcAlias, 0))
	loSafety = abSet('SAFETY', 'OFF')

* Lire les consignes de champs et d'indexes
	lcFields = TableFreeCreateOrAdjust_cFields(@m.laFields, m.lcAlias)
	llFields = not empty(m.lcFields)
	lnTags = TableFreeCreateOrAdjust_aTags(@m.laTag, @m.laTagInfo, m.lcAlias, @m.llZap)
	llTags = m.lnTags > 0

* Si la table existe déjà
	if m.llAlias

		if m.llFields or m.llTags

			lcAlias = ExclusiveForce(m.lcAlias, @m.llExclusive)
			llResult = used(m.lcAlias)
			assert m.llResult message cAssertMsg(textmerge([Impossible d'accéder à la table '<<m.tcTable>>' en mode exclusif]))
		endif
		if m.llResult

* Si la structure doit changer && /!\ supporter ALTER COLUMN ... NULL
			if m.llFields

* Supprimer les tags avant de supprimer les champs qui pourraient y être impliqués
				if m.llTags
					for liTag = 1 to m.lnTags && EACH lcTag IN laTag
						lcTag = laTag[m.liTag]
						if upper(left(m.lcTag, len('DELE'))) == 'DELE' && DELETE TAG ...
							&lcTag
							adel(laTag, m.liTag)
						endif
					next
				endif

				wWAIT(;
					textmerge(icase(;
						cLangUser() = 'fr',	[Restructuration de la table '<<m.lcAlias>>' en cours (<<cTronc(m.lcFields)>>) NE PAS INTERROMPRE !],; && copy-paste this line to add another language support
																[Modifying structure of table '<<m.lcAlias>>' (<<cTronc(m.lcFields)>>) DO NOT INTERRUPT!]; && Default: English
					));
				, 'WINDOW NOWAIT NOCLEAR')

				alter table (m.lcAlias) &lcFields
				wWAIT(, [CLEAR])
				lcTable = cTableAddress(m.lcAlias)
				erase (forceext(m.lcTable, 'bak'))
				erase (forceext(m.lcTable, 'tbk'))
				tlAdjusted = .t.
			endif

			select (m.lcAlias) && abSelect(...) plus haut
		else
			tcResult = textmerge(icase(;
				cLangUser() = 'fr', [Impossible d'accéder à la table '<<m.tcTable>>' en mode exclusif],; && copy-paste this line to add another language support
														[Could not have an exclusive access to table '<<m.tcTable>>'])) && Default: English
		endif

* Sinon (table à créer)
	else

		if m.llCursor
			tcAlias = evl(m.tcTable, m.tcAlias)
			tcAlias = iif(vartype(m.tcAlias) == 'C' and not empty(m.tcAlias), cVFPName(m.tcAlias), sys(2015))
			create cursor (m.tcAlias) from array laFields
		else
			create table (m.tcTable) free from array laFields && Tables in Visual FoxPro are tagged with the code page that was in use when the table was created
		endif
		lcAlias = alias()
		tlCreated = .t.
	endif

	if m.llResult and m.llTags

		assert not m.llZap message cAssertMsg(textmerge([<<Proper(Program())>> va zapper '<<m.lcAlias>>'...<<CRLF>>Presser 'Cancel' pour arrêter le programme<<CRLF>>Presser 'Ignore' pour continuer]))
		if m.llZap
			zap && SELECT plus haut ou CREATE TABLE a sélectionné la table
		endif

* Créer ou ajuster les indexes
		for each lcTag in laTag
			if vartype(m.lcTag) == 'C' && a pu être supprimé ci-dessus
				if m.llAlias
					wWAIT(textmerge(icase(;
						cLangUser() = 'fr', [Indexation de la table '<<m.lcAlias>>' en cours (<<cTronc(m.lcTag)>>) NE PAS INTERROMPRE !],; && copy-paste this line to add another language support
																[Indexing table '<<m.lcAlias>>' (<<cTronc(m.lcTag)>>) DO NOT INTERRUPT!])); && Default: English
					, 'WINDOW NOWAIT NOCLEAR')
				endif
				&lcTag
				if m.llAlias
					wWAIT(, [CLEAR])
				endif
			endif
		endfor
		set order to

		reindex && ajouté le 27/9 pour éviter un CDX bloat inexpliqué
	endif

* Rouvrir la table selon le Set("Exclusive") courant
	if m.llResult and not m.llCursor and not m.llExclusive
		tcAlias = evl(m.tcAlias, m.lcAlias)
		llResult = AliasReuse(m.lcAlias,,, m.tcAlias) && rouvre sous m.lcAlias si Empty(m.tcAlias)
	endif
else
	tcResult = textmerge(icase(;
		cLangUser() = 'fr', [<<m.tuFields>> est une spécification de champs invalide pour la table '<<m.tcTable>>'],; && copy-paste this line to add another language support
												[<<m.tuFields>> is an invalid field specification for table '<<m.tcTable>>']; && Default: English
		))
endif

return m.llResult

* ========================================
function cIndexCmd && Commande d'indexation d'après les colonnes d'aTagInfo() [Tag, Type, Key, Filter, Order, Collation]
lparameters ;
	lcTag,; &&	1 Index tag name in a .cdx file or index file name for .idx files
	lcType,; &&	2 Index tag type
	lcKey,; &&	3 Index key expression
	lcFilter,; &&	4 Filter expression
	lcOrder,; &&	5 Index order as created (Ascending or Descending)
	lcCollate &&	6 Collate sequence

&& When using binary indexes, you cannot use the FOR clause to specify a filter expression or the ASCENDING, DESCENDING, UNIQUE, or CANDIDATE keywords

lcType = iif(m.lcType == 'REGULAR', '', m.lcType)
lcFilter = iif(m.lcType == 'BINARY' or empty(m.lcFilter), '', ' FOR ' + m.lcFilter)
lcOrder = iif(m.lcType == 'BINARY' or m.lcOrder == 'ASCENDING', '', ' DESCENDING') && ASCENDING par défaut
lcCollate = nEvl(m.lcCollate, textmerge([ COLLATE '<<m.lcCollate>>']))

return textmerge([INDEX ON <<m.lcKey>> TAG <<m.lcTag>> <<m.lcType>><<m.lcFilter>><<m.lcOrder>><<m.lcCollate>>])

* ========================================
procedure TableFreeCreateOrAdjust_aTags && Instructions d'indexation
lparameters ;
	taResult,; && @ Instructions d'indexation
	taTagInfo,; && @ Spécifications d'index selon aTagInfo() [Tag, Type, Key, Filter, Order, Collation]
	tcAlias,; && Alias, vide si création de la table
	tlZap && @ [.F.] Un index candidat doit être créé
external array taResult, taTagInfo
tlZap = .f.

local lcSetCollate;
, tlAlias, tlTagInfo, tnTag;
, llTagInfo, laTagInfo[1], lnTag;
, llTag, lcTag, lcType, lcKey, lcFilter, lcOrder, lcCollate;
, lcSelect;
, lnResult

lnResult = 0
lcSetCollate = set("Collate")

tlAlias = used(m.tcAlias)
llTagInfo = m.tlAlias and aTagInfoEn(@m.laTagInfo, '', m.tcAlias) > 0 && Normalisé en anglais car ces saloperies de vfp9r*.dll localisent en * (ex. fra > français)
tlTagInfo = not laEmpty(@m.taTagInfo)
if m.tlTagInfo

* Pour chaque tag d'index spécifié
	for tnTag = 1 to alen(taTagInfo, 1)

		lcTag 		= taTagInfo[m.tnTag, 1]
		lcType 		= taTagInfo[m.tnTag, 2]
		lcKey 		= taTagInfo[m.tnTag, 3]
		lcFilter 	= taTagInfo[m.tnTag, 4]
		lcOrder 	= taTagInfo[m.tnTag, 5]
		lcCollate	= taTagInfo[m.tnTag, 6]

* Créer l'index s'il n'existe pas dans la table ou avec des caractéristiques différentes
		llTag = not m.llTagInfo
		if not m.llTag

			lnTag = ascan(laTagInfo, m.lcTag, 1, -1, 1, 15)
			llTag = empty(m.lnTag) or not (.t.;
								and	laTagInfo[m.lnTag, 2] == m.lcType;
								and	laTagInfo[m.lnTag, 3] == m.lcKey;
								and	laTagInfo[m.lnTag, 4] == m.lcFilter;
								and	laTagInfo[m.lnTag, 5] == m.lcOrder;
								and	laTagInfo[m.lnTag, 6] == m.lcCollate;
								)
		endif

* Si l'index doit être créé ou modifié
		if m.llTag

#if .f.
create cursor Test(Test L)
index on Test tag Test binary
? ataginfo(aa) && collation = 'machine'
set collate to "GENERAL"
index on Test tag Test binary
? ataginfo(aa) && collation = 'machine'
index on Test tag Test binary collate 'general' && invalid collation sequence
#endif

			lcType = iif(m.lcType == 'REGULAR', '', m.lcType)
			lcCollate = iif(m.lcType == 'BINARY', 'MACHINE' , m.lcCollate)

* Si un index candidat doit être créé
			if m.tlAlias;
			 and not m.tlZap;
			 and inlist(m.lcType, 'CANDIDATE', 'PRIMARY')

				tlZap = not lTableExpr(m.lcKey, m.tcAlias)
				if not m.tlZap

* Vérifier l'absence de doublon
					lcSelect = iif(empty(m.lcFilter), '', ' WHERE ' + m.lcFilter)
					tlZap = VFPSelectExecute(textmerge([SELECT <<m.lcKey>> AS CAND, Count(*) AS _COUNT FROM <<m.tcAlias>> <<m.lcSelect>> GROUP BY CAND HAVING _COUNT > 1])) > 0
					use && Cursor créé par VFPSelectExecute()
				endif
			endif

			lnResult = m.lnResult + 1
			dimension taResult[m.lnResult]
			taResult[m.lnResult] = cIndexCmd(m.lcTag, m.lcType, m.lcKey, m.lcFilter, m.lcOrder, m.lcCollate)
		endif
	endfor
endif

* Pour chaque tag existant
if m.llTagInfo
	for lnTag = 1 to alen(laTagInfo, 1)
		lcTag = laTagInfo[m.lnTag, 1]

* Si le tag n'est pas spécifié, supprimer
		if not m.tlTagInfo or ascan(taTagInfo, m.lcTag, 1, -1, 1, 15) = 0

			lnResult = m.lnResult + 1
			dimension taResult[m.lnResult]
			taResult[m.lnResult] = textmerge([DELETE TAG <<m.lcTag>>])
		endif
	endfor
endif

return m.lnResult

* ========================================
procedure TableFreeCreateOrAdjust_cFields && Expression de champs
lparameters ;
	taFieldSpec,; && @ Spécification de champs selon format aFields()
	tcAlias && Alias, vide si création de la table
external array taFieldSpec

local lcResult;
, laField[1], lnField, lnFieldSpec, lcField, lcFieldExp

lcResult = ''

* Si la table cible existe
if used(m.tcAlias)
	afields(laField, m.tcAlias)

* Pour chaque champ spécifié
	for lnFieldSpec = 1 to alen(taFieldSpec, 1)

		lcField = taFieldSpec[m.lnFieldSpec, 1]

		lcFieldExp = cFieldExp(;
			  taFieldSpec[m.lnFieldSpec, 1]; && Name
			, taFieldSpec[m.lnFieldSpec, 2]; && Type
			, taFieldSpec[m.lnFieldSpec, 3]; && Length
			, taFieldSpec[m.lnFieldSpec, 4]; && Decimals
			, taFieldSpec[m.lnFieldSpec, 5]; && NULL
			)

* Si le champ existe dans le table
		lnField = ascan(laField, m.lcField, 1, -1, 1, 15) && 1+2+4+8
		if m.lnField > 0

* Si la définition est différente de la spec.
			if not (.t.;
				and	taFieldSpec[m.lnFieldSpec, 2] == laField[m.lnField, 2]; && Type
				and	taFieldSpec[m.lnFieldSpec, 3] == laField[m.lnField, 3]; && Length
				and	taFieldSpec[m.lnFieldSpec, 4] == laField[m.lnField, 4]; && Decimals
				and	taFieldSpec[m.lnFieldSpec, 5] == laField[m.lnField, 5]; && NULL
				)

				lcResult = textmerge("<<m.lcResult>> ALTER COLUMN <<m.lcFieldExp>>")
			endif

* Sinon (le champ n'existe pas dans le table)
		else

* Ajouter l'expression de création de champ
			lcResult = textmerge("<<m.lcResult>> ADD COLUMN <<m.lcFieldExp>>")
		endif
	endfor

* Pour chaque champ de la table
	for lnField = 1 to alen(laField, 1)
		lcField = laField[m.lnField, 1]

* Si le champ n'est pas spécifié
		lnFieldSpec = ascan(taFieldSpec, m.lcField, 1, -1, 1, 15) && 1+2+4+8
		if m.lnFieldSpec = 0

* Supprimer
			lcResult = textmerge("<<m.lcResult>> DROP COLUMN <<m.lcField>>")
		endif
	next

* Sinon (table cible à créer)
else

	lcResult = cFieldsExp(@m.taFieldSpec, .t.)
endif

return m.lcResult

* ========================================
procedure aFields_ && aFields() d'après un tableau ou une liste ou selon syntaxe CREATE TABLE
lparameters ;
	taResult,; && @ Résultat selon aFields()
	tuFields && @A|C Spécification de champs dans l'ordre de aFields(), tabulé ou délimité par ';|\t', ou selon syntaxe CREATE TABLE
external array taResult, tuFields

local lnCols, lnRow, lnResult && Nombre de champs

#define aFIELDS_VARTYPES  replicate('C',2) + replicate('I',2) + replicate('L',2) + replicate('C',10) + replicate('I',2) && 18 colonnes
#define aFIELDS_SEPS [,;|]+TABUL

if aClear(@m.taResult)

	lnResult = 0

	do case

	case type('tuFields', 1) == 'A'

		lnResult = alen(tuFields, 2)

		lnResult = icase(;
			m.lnResult = 1,;
				aColsDelim(tuFields, aFIELDS_SEPS, aFIELDS_VARTYPES),;
			between(m.lnResult, 4, 18),;
				m.lnResult,; && AFields() format assumed
				0;
			)

	case vartype(m.tuFields) == 'C'

		tuFields = cCommentStripped(cInLineCommentStripped(m.tuFields))
		lnResult = iif(CRLF $ m.tuFields;
			, aLinesCols(@m.taResult, m.tuFields, aFIELDS_SEPS, aFIELDS_VARTYPES); && TEXT TO tuFields ... ENDTEXT
			, aFieldsDef(@m.taResult, m.tuFields);
			)

	endcase

	assert m.lnResult > 0 message cAssertMsg(textmerge([Spécification de champ invalide <<cLitteral(m.tuFields)>>]))
	if m.lnResult > 0

* Compléter au format aFields()
		lnCols = alen(taResult, 2)
		if m.lnCols < 18
			lnCols = 18 - m.lnCols
			aColsIns(@m.taResult,, m.lnCols,, rightc(aFIELDS_VARTYPES, m.lnCols))
		endif

* Donner les valeurs par défaut
		for lnRow = 1 to m.lnResult
			taResult[m.lnRow, 3] = icase(;
				taResult[m.lnRow, 2] $ VFP9_FIELD_TYPES_FIXED_LEN_1B, 1,; && 'L'
				taResult[m.lnRow, 2] $ VFP9_FIELD_TYPES_FIXED_LEN_4B, 4,; && 'WGIM'
				taResult[m.lnRow, 2] $ VFP9_FIELD_TYPES_FIXED_LEN_8B, 8,; && 'YDTB'
				taResult[m.lnRow, 3];
				)
		endfor
	endif
else

	lnResult = 0
	assert .f. message cAssertMsg(textmerge([Tableau attendu en premier paramètre <<cLitteral(m.taResult)>>]))
endif

return m.lnResult

* ========================================
procedure aTagInfoEn && aTagInfo() avec les données en anglais quel que soit la langue courante de VFP /!\ Français supporté seulement
lparameters ;
	taResult,; && @ Spécifications d'indexes au format aTagInfo() [1-tag, 2-type, 3-key expression, 4-filter, 5-order, 6-collate]
	tcCDXName,; && [all open cdx and idx] Name of the compound index (.cdx) file to return information for
	tuWAalias && [Alias()] Work Area or alias of the table to return information for
external array taResult
tcCDXName = evl(m.tcCDXName, '')
tuWAalias = evl(m.tuWAalias, alias())

local lnResult as integer; && number of tags
, llResult;
, lcVersion;
, laVersion[1];
, liVersion;
, liTag;
, lcTag

lnResult = ataginfo(taResult, m.tcCDXName, m.tuWAalias)
if m.lnResult > 0

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
	ENDTEXT

*!*			aLinesCols(@m.laVersion, Upper(cEuroANSI(m.lcVersion)), TABUL, 'ICCCCCC')
*!*			liVersion = Evl(Ascan(m.laVersion, Cast(Version(3) as I), 1, -1, 1, 8), 1)
*!*				llResult = NOT Empty(m.lcTag)
*!*				ASSERT m.llResult MESSAGE Proper(Program()) + ' - ' + Textmerge(ICase(;
*!*					cLangUser() = 'fr', "Le type d'index '<<taResult[m.liTag, 2]>>' n'est pas supporté",; && copy-paste this line to add another language support
*!*															"Index type '<<taResult[m.liTag, 2]>>' is not supported"))
*!*				IF m.llResult
*!*				ENDIF

* Normaliser en anglais car vfp9r*.dll localise cette information ...
	for liTag = 1 to m.lnResult

* Délocaliser le type d'index
		taResult[m.liTag, 2] = icase(;
			candidate(m.liTag, m.tuWAalias),;
				'CANDIDATE',;
			primary(m.liTag, m.tuWAalias),;
				'PRIMARY',;
			unique(m.liTag, m.tuWAalias),;
				'UNIQUE',;
			taResult[m.liTag, 2] == 'BINARY',; && not localized
				'BINARY',;
				'REGULAR';
			)

* Délocaliser l'ordre de l'index
		taResult[m.liTag, 5] = iif(descending(m.tcCDXName, m.liTag, m.tuWAalias);
			, 'DESCENDING';
			, 'ASCENDING';
			)
	endfor
endif

return m.lnResult

* ========================================
procedure aTagInfo_ && aTagInfo() d'après un tableau ou une liste
lparameters ;
	taResult,; && @ Spécifications d'indexes au format aTagInfo() [Tag, Type, Key, Filter, Order, Collation]
	tuTagInfo && @ Spécification d'indexes au format aTagInfo(), tabulées ou délimitées  par ';|\t'
external array taResult, tuTagInfo

#if .f.
	1 name
	2 type ['REGULAR']
	3 key expression [=TAG NAME] && éviter délimiteur ',' qui peut se trouver dans l'expression
	4 filter expression ['']
	5 order as created (ascending or descending) ['ASCENDING']
	6 collate sequence [Set("Collate")]
#endif
#define aTAGINFO_SEPS [;|]+TABUL

local lnCols, liTag, lcSetCollate, lnResult && Nombre d'indexes

if aClear(@m.taResult)

	lnResult = icase(;
		type('tuTagInfo', 1) == 'A', icase(;
			laEmpty(@m.tuTagInfo), 0,;
			alen(tuTagInfo, 2) <= 1, min(acopy(tuTagInfo, taResult), 0) + aColsDelim(@m.taResult, aTAGINFO_SEPS),;
			between(alen(tuTagInfo, 2), 3, 6), min(acopy(tuTagInfo, taResult), 0) + alen(taResult, 1),; && tuTagInfo is already in aTagInfo() format
			-1),;
		vartype(m.tuTagInfo) == 'C', aLinesCols(@m.taResult, cCommentStripped(cInLineCommentStripped(m.tuTagInfo)), aTAGINFO_SEPS),; && TEXT TO tuTagInfo ... ENDTEXT
		-1)

	assert m.lnResult >= 0 message cAssertMsg(textmerge([Spécification d'index invalide <<cLitteral(m.tuTagInfo)>>]))
	lnResult = max(m.lnResult, 0)
	if m.lnResult > 0

* Ajuster au format de aTagInfo()
		lnCols = alen(taResult, 2)
		if m.lnCols < 6
			aColsIns(@m.taResult,, 6 - m.lnCols, '')
		endif

* Donner aux expressions et types d'indexes leurs valeurs par défaut
		lcSetCollate = set("Collate")
		for liTag = 1 to m.lnResult
			taResult[m.liTag, 1] = upper(alltrim(taResult[m.liTag, 1]))
			taResult[m.liTag, 2] = upper(alltrim(evl(taResult[m.liTag, 2], 'REGULAR')))
			taResult[m.liTag, 3] = normalize(evl(taResult[m.liTag, 3], taResult[m.liTag, 1])) && par défaut expression = tag = champ
			taResult[m.liTag, 4] = iif(empty(taResult[m.liTag, 4]), '', normalize(taResult[m.liTag, 4])) && Normalize('') : Missing expression (Error 152)
			taResult[m.liTag, 5] = upper(alltrim(evl(taResult[m.liTag, 5], 'ASCENDING')))
			taResult[m.liTag, 6] = upper(alltrim(evl(taResult[m.liTag, 6], m.lcSetCollate)))
		endfor
	endif

else

	lnResult = 0
	assert .f. message cAssertMsg(textmerge([Tableau attendu en premier paramètre <<cLitteral(m.taResult)>>]))
endif


return m.lnResult

* ========================================
function aFieldsDef && Définitions de champs selon le format de aFields()
lparameters ;
	taFieldsDef,; && @ Définitions de champs selon le format de aFields()
	tcFieldsExp && Expression de description de structure comme dans une commande CREATE TABLE
external array taFieldsDef

local lnResult as integer; && Nombre de champs
, llResult as Boolean;
, llSetNULL as Boolean;
, lnField, laFieldExps[1];
, liField, liCol;
, lcField, lcType, lnLen, lnDec, llNULL

lnResult = 0

* Si la spécification de champs est valide
llResult = vartype(m.tcFieldsExp) == 'C' and not empty(m.tcFieldsExp)
assert m.llResult message cAssertMsg(textmerge([<<Proper(Program())>> - Expression de description de structure invalide : <<cLitteral(m.tcFieldsExp)>>]))
if m.llResult

* Tabuler les spécifications de champs
	lnField = aFieldsExp(@m.laFieldExps, m.tcFieldsExp)
	llResult = m.lnField > 0
	assert m.llResult message cAssertMsg(textmerge([<<Proper(Program())>> - Expression de description de structure invalide : <<cLitteral(m.tcFieldsExp)>>]))
	if m.llResult

* Dimensionner le tableau résultat selon format de aFields()
		dimension taFieldsDef[m.lnField, 18]
		llSetNULL = set("Null") == 'ON'

* Tant que les spécifications de champs sont valides
		for m.liField = 1 to m.lnField

			if lFieldExp(laFieldExps[m.liField], @m.lcField, @m.lcType, @m.lnLen, @m.lnDec, @m.llNULL)
				taFieldsDef[m.liField, 1] = m.lcField
				taFieldsDef[m.liField, 2] = m.lcType
				taFieldsDef[m.liField, 3] = m.lnLen
				taFieldsDef[m.liField, 4] = m.lnDec
				taFieldsDef[m.liField, 5] = nvl(m.llNULL, m.llSetNULL)
				for liCol = 7 to 18 && 5 et 6 = .F. (default)
					taFieldsDef[m.liField, m.liCol] = iif(m.liCol < 17, '', 0)
				endfor
			else
				llResult = .f.
				exit
			endif
		endfor

* Si OK, retourner le nombre de champs
		if m.llResult
			lnResult = m.lnField

* Sinon (erreur), effacer le tableau résultat
		else
			aClear(@m.taFieldsDef)
		endif
	endif
endif

return m.lnResult

* ========================================
function aFieldsExp && Expressions de description de champ (comme dans une commande ALTER TABLE)
lparameters ;
	taFieldsExp,; && @ Expressions de champs comme dans une commande ALTER TABLE
	tcFieldsExp && Expression de structure comme dans une commande CREATE TABLE
external array taFieldsExp

local llResult, lnResult && Nombre de champs
lnResult = 0

* Si l'Expression de structure est valide
llResult = vartype(m.tcFieldsExp) == 'C' and not empty(m.tcFieldsExp)
assert m.llResult message cAssertMsg("Expression de description de structure invalide : " + cLitteral(m.tcFieldsExp))
if m.llResult

* Repérer les délimiteurs : ',' qui ne suit pas une parenthèse ouvrante
	local lnCar, lcCar, laVirgs[1], lnVirgs, llParenth
	lnVirgs = 0
	for lnCar = 1 to len(m.tcFieldsExp)
		lcCar = substr(m.tcFieldsExp, m.lnCar, 1)
		do case
		case m.lcCar == '('
			llParenth = .t.
		case m.lcCar == ')'
			llParenth = .f.
		case m.lcCar == ',' and not m.llParenth
			lnVirgs = m.lnVirgs + 1
			dimension laVirgs[m.lnVirgs]
			laVirgs[m.lnVirgs] = m.lnCar
		endcase
	endfor

* Tabuler les expressions valides
	local lnVirg, lnStart, lnLen, lcFieldExp
	for lnVirg = 0 to m.lnVirgs && piquets et intervalles !

		lnStart = iif(m.lnVirg = 0, 0, laVirgs[m.lnVirg])  + 1
		lnLen = iif(m.lnVirg = m.lnVirgs, len(m.tcFieldsExp)+1, laVirgs[m.lnVirg + 1]) - m.lnStart
		lcFieldExp = substr(m.tcFieldsExp, m.lnStart, m.lnLen)
		llResult = lFieldExp(m.lcFieldExp)
		assert m.llResult message cAssertMsg("Expression de description de champ invalide : " + cLitteral(m.lcFieldExp))
		if m.llResult

			lnResult = m.lnResult + 1
			dimension taFieldsExp[m.lnResult]
			taFieldsExp[m.lnResult] = m.lcFieldExp
		else

			exit
		endif
	endfor

* Si erreur, effacer le tableau résultat
	if not m.llResult
		aClear(@m.taFieldsExp)
		lnResult = 0
	endif
endif

return m.lnResult

* ========================================
function aFieldSpecs && Spécifications d'un champ issues de aFields()
lparameters ;
	taFieldSpecs,; && @ Spécifications d'un champ issues de aFields()
	tcField,; && Champ à examiner
	tcAlias && [Alias courant]

local llResult, lnResult
lnResult = 0 && nombre de specs rendues

llResult = aClear(@m.taFieldSpecs)
assert m.llResult message cAssertMsg(textmerge(icase(;
	cLangUser() = 'fr',	[tableau attendu en premier paramètre : <<cLitteral(m.taFieldSpecs)>>],; && copy-paste this line to add another language support
											[first parameter should be an array: <<cLitteral(m.taFieldSpecs)>>]; && Default: English
	)))
if m.llResult

	tcAlias = iif(vartype(m.tcAlias) == 'C', m.tcAlias, alias())
	llResult = used(m.tcAlias)
	assert m.llResult message cAssertMsg(icase(;
		cLangUser() = 'fr',	[Alias introuvable :],; && copy-paste this line to add another language support
												[Alias can't be found:]; && Default: English
		) + cLitteral(m.tcAlias))
	if m.llResult

		llResult = vartype(m.tcField) == 'C' and lField(m.tcField, m.tcAlias)
		assert m.llResult message cAssertMsg(textmerge([Le champ <<m.tcField>> est introuvable dans l'alias <<m.tcAlias>>]))
		if m.llResult
			tcField = upper(alltrim(m.tcField))

			local laFields[1], lnField
			afields(laFields, m.tcAlias)
			lnField = ascan(laFields, m.tcField, 1, -1, 1, 2+4)
			lnResult = alen(laFields, 2)
			dimension taFieldSpecs[m.lnResult]
			acopy(laFields, taFieldSpecs, m.lnField, m.lnResult, 1)
		endif
	endif
endif

return m.lnResult

* ========================================
function lFieldExp && Expression de description de champ valide (comme dans une commande CREATE TABLE)
lparameters ;
	tcFieldExp,; && Expression de description de champ comme dans une commande CREATE TABLE
	tcField,; && @ [''] Nom du champ
	tcType,; && @ [''] Type du champ
	tnLen,; && @ [0] Longueur du champ
	tnDec,; && @ [0] Décimales du champ
	tlNULL && @ [.NULL.] Le champ accepte les valeurs NULL

tlNULL = .null.

local lcFieldExp, lnLens, laLens[1], lcNULL, llResult

llResult = vartype(m.tcFieldExp) == 'C' and not empty(m.tcFieldExp)
assert m.llResult message cAssertMsg(textmerge([Description de champ invalide : <<cLitteral(m.tcFieldExp)>>]))
if m.llResult
	lcFieldExp = cRepCharDel(upper(alltrim(m.tcFieldExp)))

* Si le champ est d'un type supporté
	tcField = getwordnum(m.lcFieldExp, 1)
	lcFieldExp = ltrim(substr(m.lcFieldExp, len(m.tcField) + 1))
	tcType = left(m.lcFieldExp, 1)
	llResult = m.tcType $ VFP9_FIELD_TYPES
	assert m.llResult message cAssertMsg(textmerge([Type de champ invalide : <<cLitteral(m.tcType)>>]))
	if m.llResult
		lcFieldExp = ltrim(substr(m.lcFieldExp, 2))

* Déterminer si le champ accepte les NULL
		if rightc(m.lcFieldExp, lenc('NULL')) == 'NULL'
			lcNULL = iif(rightc(m.lcFieldExp, lenc('NOT NULL')) == 'NOT NULL', 'NOT NULL', 'NULL')
			tlNULL = m.lcNULL == 'NULL'
			lcFieldExp = trim(leftc(m.lcFieldExp, lenc(m.lcFieldExp) - lenc(m.lcNULL)))
		endif

* Si la spécification de longueur de champ (len, dec) est pertinente
		llResult = iif(m.tcType $ VFP9_FIELD_TYPES_FIXED_LEN;
				, empty(m.lcFieldExp);
				, substr(m.lcFieldExp, 1, 1) == '(' and substr(m.lcFieldExp, len(m.lcFieldExp), 1) == ')';
				)
		assert m.llResult message cAssertMsg(textmerge([Spécification de longueur de champ '<<m.lcFieldExp>>' invalide pour le type '<<m.tcType>>']))
		if m.llResult

* Si la champ a spécification de longueur
			if m.tcType $ VFP9_FIELD_TYPES_FIXED_LEN

				tnLen = icase(;
						m.tcType $ VFP9_FIELD_TYPES_FIXED_LEN_1B, 1,;
						m.tcType $ VFP9_FIELD_TYPES_FIXED_LEN_4B, 4,;
						m.tcType $ VFP9_FIELD_TYPES_FIXED_LEN_8B, 8,;
						0;
					)
			else

				lcFieldExp = substr(m.lcFieldExp, 2, len(m.lcFieldExp) - 2) && ôte les parenthèses

* Si la spécification de longueur est valide
				lnLens = alines(laLens, m.lcFieldExp, 1, ',')
				llResult = iif(m.tcType $ VFP9_FIELD_TYPES_WITH_DEC, inlist(m.lnLens, 1, 2), m.lnLens = 1)
				assert m.llResult message cAssertMsg(textmerge([Spécification de longueur de champ  '<<m.lcFieldExp>>' invalide pour le type <<m.tcType>>]))
				if m.llResult

					tnLen = val(laLens[1])
					tnDec = iif(m.lnLens = 2, val(laLens[2]), 0)
				endif
			endif
		endif
	endif
endif

tcField = iif(m.llResult, m.tcField, '')
tcType = iif(m.llResult, m.tcType, '')
tnLen = evl(m.tnLen, 0)
tnDec = evl(m.tnDec, 0)
tlNULL = iif(m.llResult, m.tlNULL, .null.)

return m.llResult

* ========================================
function lFieldsExp && Expression de description de champS valide (comme dans une commande CREATE TABLE)
lparameters tcFieldsExp && Expression de description de champS comme dans une commande CREATE TABLE

local laFieldsExp[1]

return aFieldsExp(@m.laFieldsExp, m.tcFieldsExp) > 0

* ========================================
function caFields && aFields(laFields) linéarisé en caractères
lparameters tcTable && [Alias()] Alias ou adresse de table

private laField
local lcAlias, llAlias, laField[1], llSafety, lcFile, lcResult

lcResult = ''

lcAlias = cAlias(m.tcTable, @m.llAlias)
if used(m.lcAlias)

	afields(laField, m.lcAlias)

	llSafety = set("Safety") == 'ON'
	if m.llSafety
		set safety off
	endif

	lcFile = addbs(sys(2023)) + 'temp' + transform(_vfp.processid)+ '.mem' && multi-serveur

	save to (m.lcFile) all like laField

	if m.llSafety
		set safety on
	endif

	lcResult = strconv(filetostr(m.lcFile), 13)

	delete file (m.lcFile)

	if m.llAlias
		use in (m.lcAlias)
	endif
endif

return m.lcResult

* ========================================
function lRelationTrgt && Un alias est cible d'une relation
lparameters tcAlias && [Alias()]

local array laRelation[1]

return aRelationTrgt(@m.laRelation, m.tcAlias) > 0

* ========================================
function aRelationTrgt && Relation dont un alias est la cible
lparameters ; &&  set relation to <Relational Expression> in <Source Alias> into <Target Alias>
	taRelation,; && Relation [Relational Expression, Source Alias]
	tcAlias && [Alias()] relation Target Alias
external array taRelation
tcAlias = upper(evl(m.tcAlias, alias()))

local lnResult; && Nombre de relations trouvées - 0 ou 1
, llResult;
, laUsed[1], lnUsed, liUsed, lcUsed;
, laRelation[1], lnRelation, liRelation;

lnResult = 0

llResult = aClear(@m.taRelation)
assert m.llResult message cAssertMsg(textmerge(icase(;
	cLangUser() = 'fr',	[tableau attendu en premier paramètre : <<cLitteral(m.taRelation)>>],; && copy-paste this line to add another language support
											[first parameter should be an array: <<cLitteral(m.taRelation)>>]; && Default: English
	)))
if m.llResult and not empty(m.tcAlias)

	llResult = used(m.tcAlias)
	assert m.llResult message cAssertMsg(icase(;
		cLangUser() = 'fr',	[Alias introuvable :],; && copy-paste this line to add another language support
												[Alias can't be found:]; && Default: English
		) + cLitteral(m.tcAlias))
	if m.llResult
		llResult = .f.

		lnUsed = aused(m.laUsed)
		for liUsed = 1 to m.lnUsed
			lcUsed = laUsed[m.liUsed, 1]
			lnRelation = aRelationSrce(@m.laRelation, m.lcUsed)
			if m.lnRelation > 0
				for liRelation = 1 to m.lnRelation
					llResult = m.laRelation[m.liRelation, 2] == m.tcAlias
					if m.llResult
						lnResult = 1
						dimension taRelation[2]
						taRelation[1] = m.laRelation[m.liRelation, 1]
						taRelation[2] = m.lcUsed
						exit
					endif
				endfor
				if m.llResult
					exit
				endif
			endif
		endfor
	endif
endif

return m.lnResult

* ========================================
function lRelationSrce && Un alias est source d'une relation
lparameters tcAlias && [Alias()] Alias à examiner

local array laRelation[1]

return  0 < iif(pcount() = 1;
	, aRelationSrce(@m.laRelation, m.tcAlias);
	, aRelationSrce(@m.laRelation);
	)

* ========================================
function aRelationSrce && Relations dont un alias est la source
lparameters ;
	taRelation,; && Relations [1- Relational Expression, 2- Target Alias]
	tcAlias,; && [Alias()] Alias à examiner
	tlExtended,; && [.F., .T. if m.tlCascade] Relations [1- Relational Expression, 2- Target Alias, 3- Target Index Expression, 4- Source Alias]
	tlCascade && [.F.] Explore target alias as source alias

external array taRelation
tcAlias = iif(vartype(m.tcAlias) == 'C', upper(m.tcAlias), alias())
tlCascade = lTrue(m.tlCascade)
tlExtended = m.tlCascade or lTrue(m.tlExtended)

local lnResult as integer; && Nombre de relations trouvées
, llResult;
, lcTarget;
, lcRelation;
, liRelation

lnResult = iif(!m.tlCascade or laEmpty(@m.taRelation), 0, alen(m.taRelation, 1))

if not empty(m.tcAlias)

	llResult = m.tlCascade or aClear(@m.taRelation)
	assert m.llResult message cAssertMsg(textmerge(icase(;
		cLangUser() = 'fr',	[tableau attendu en premier paramètre : <<cLitteral(m.taRelation)>>],; && copy-paste this line to add another language support
												[first parameter should be an array: <<cLitteral(m.taRelation)>>]; && Default: English
		)))
	if m.llResult

		llResult = used(m.tcAlias)
		assert m.llResult message cAssertMsg(icase(;
			cLangUser() = 'fr',	[Alias introuvable :],; && copy-paste this line to add another language support
													[Alias can't be found:]; && Default: English
			) + cLitteral(m.tcAlias))
		if m.llResult

			liRelation = 1
			do while .t.
				lcRelation = relation(m.liRelation, m.tcAlias)
				if empty(m.lcRelation)
					exit
				else

					lcTarget = target(m.liRelation, m.tcAlias)

					lnResult = m.lnResult + 1
					dimension taRelation[m.lnResult, Iif(m.tlExtended, 4, 2)]
					taRelation[m.lnResult, 1] = m.lcRelation
					taRelation[m.lnResult, 2] = m.lcTarget
					if m.tlExtended
						taRelation[m.lnResult, 3] = cTagExpr(order(m.lcTarget), m.lcTarget)
						taRelation[m.lnResult, 4] = m.tcAlias
					endif
					if m.tlCascade
						lnResult = aRelationSrce(@m.taRelation, m.lcTarget, m.tlExtended, m.tlCascade)
					endif
					liRelation = m.liRelation + 1
				endif
			enddo
		endif
	endif
endif

return m.lnResult

* ------------------
function aRelationSrce_Test && Test unitaire de aRelationSrce()

local loTest as aRelationSrce_Test of abData.prg;
, aRelationSrce[1] && Relations [Relational Expression, Target Alias[, Target Index Expression, Source Alias]]

close tables all

loTest = newobject('aRelationSrce_Test', 'abData.prg')
loTest.dataopen

aClear(@m.aRelationSrce)
loTest.Test(1, @m.aRelationSrce, 'customer')
loTest.assert(m.aRelationSrce[1,1], upper('customer_id')) && Relational Expression
loTest.assert(m.aRelationSrce[1,2], upper('orders')) && Target Alias

aClear(@m.aRelationSrce)
loTest.Test(1, @m.aRelationSrce, 'customer', .t.)
loTest.assert(m.aRelationSrce[1,3], upper('customer_id')) && Target Index Expression
loTest.assert(m.aRelationSrce[1,4], upper('customer')) && Source Alias

aClear(@m.aRelationSrce)
loTest.Test(2, @m.aRelationSrce, 'customer', .t., .t.)
loTest.assert(m.aRelationSrce[1,1], upper('customer_id')) && Relational Expression
loTest.assert(m.aRelationSrce[1,2], upper('orders')) && Target Alias
loTest.assert(m.aRelationSrce[1,3], upper('customer_id')) && Target Index Expression
loTest.assert(m.aRelationSrce[1,4], upper('customer')) && Source Alias

loTest.assert(m.aRelationSrce[2,1], upper('order_id')) && Relational Expression
loTest.assert(m.aRelationSrce[2,2], upper('order_line_items')) && Target Alias
loTest.assert(m.aRelationSrce[2,3], upper('order_id')) && Target Index Expression
loTest.assert(m.aRelationSrce[2,4], upper('orders')) && Source Alias

aClear(@m.aRelationSrce)
loTest.Test(5, @m.aRelationSrce, 'awCountry', .t., .t.)

return m.loTest.Result()

* ------------------------------
define class aRelationSrce_Test as abUnitTest of abDev.prg

	procedure dataopen

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

	enddefine

* ========================================
function cRelationSrceJoins && joins construits d'après les relations dont un alias est la source
lparameters tcAlias && [Alias()] Alias à examiner

local Result as string;
, aa[1] as string;
, nn as integer;
, I as integer;

Result = ''

nn = aRelationSrce(@m.aa, m.tcAlias, .t., .t.) && [1- Relational Expression, 2- Target Alias, 3- Target Index Expression, 4- Source Alias]
if m.nn > 0
	for I = 1 to m.nn
		Result = m.Result + textmerge(" left join <<Lower(m.aa[m.i, 2])>> on <<Lower(m.aa[m.i, 4])>>.<<Lower(m.aa[m.i, 1])>> = <<Lower(m.aa[m.i, 2])>>.<<Lower(m.aa[m.i, 3])>>")
	endfor
endif

return m.Result

* ------------------
function cRelationSrceJoins_Test && Test unitaire de cRelationSrceJoins()

local loTest as aRelationSrce_Test of abData.prg;
, cExpected as string

close tables all

loTest = newobject('aRelationSrce_Test', 'abData.prg')
loTest.dataopen

loTest.Test([ join orders on customer.customer_id = orders.customer_id join order_line_items on orders.order_id = order_line_items.order_id], 'customer')

text to cExpected noshow flags 1 pretext 15
 join awcontact on awcountry.awcountry = awcontact.awcountry
 join awcont_skill on awcontact.contactid = awcont_skill.contactid
 join awskill on awcont_skill.awskill = awskill.awskill
 join awstate on awcountry.awcountry = awstate.awcountry
 join awcustomer on awstate.awstate = awcustomer.state
ENDTEXT
loTest.Test(' ' + m.cExpected, 'awCountry')

return m.loTest.Result()

* ========================================
function abRelationSrceOff && Supprime temporairement les relations dont un alias est la source
lparameters tcAlias
return createobject('abRelationSrceOff', m.tcAlias)

* ========================================
define class abRelationSrceOff as GA_LIGHTWEIGHT_CLASS && Supprime temporairement les relations dont un alias est la source
* ========================================

hidden cAlias, aRelationSrce[1]

* ---------------
procedure init
lparameters tcAlias
tcAlias = evl(m.tcAlias, alias())

local laRelation[1], lnSelect, llResult

llResult = used(m.tcAlias) and aRelationSrce(@m.laRelation, m.tcAlias) > 0
if m.llResult

	this.cAlias = m.tcAlias
	dimension this.aRelationSrce[Alen(laRelation, 1), Alen(laRelation, 2)]
	acopy(laRelation, this.aRelationSrce)
	lnSelect = select(0)
	select (m.tcAlias)
	set relation to
	select (m.lnSelect)
endif

return m.llResult

* ---------------
procedure destroy

if used(m.this.cAlias)

	local liRelation, lcExpr, lcTarget, lnRecno

	for liRelation = 1 to alen(this.aRelationSrce, 1)

		lcTarget = this.aRelationSrce[m.liRelation, 2]
		if used(m.lcTarget)
			lcExpr = this.aRelationSrce[m.liRelation, 1]
*				lnRecno = Recno_(m.lcTarget)
			set relation to &lcExpr into (m.lcTarget) in (m.this.cAlias) additive
*				RecnoSet(m.lnRecno, m.lcTarget)
		endif
	endfor
endif

* ========================================
enddefine && CLASS abRelationOff
* ========================================

* ========================================
function iAutoInc && Prochaine clé primaire d'une table
lparameters ;
	tcAlias,; && [Alias()] Alias
	tcField,; && Champ clé primaire Integer
	tiIncrement && [1] Incrément

local liResult as integer;
, llUsed;
, laResult[1];
, loDeleted;
, loTalk;
, loRecno;
, lcFilter

liResult = .null.
loDeleted = abSet('DELETED', 'OFF')
loTalk = abSet('TALK', 'OFF')

tcAlias = cAlias(evl(m.tcAlias, alias()), @m.llUsed)

do case
case !used(m.tcAlias)

case reccount(m.tcAlias) < 1000

	select max(&tcField) from (m.tcAlias) into array laResult && 50 ms pour 14.000 enr.
	liResult = evl(laResult[1], 0)

case isexclusive(m.tcAlias) or used('_iAutoInc')

		loRecno = abRecno(m.tcAlias)
		lcFilter = filter(m.tcAlias)

		set filter to in (m.tcAlias)
		calculate max(&tcField) in (m.tcAlias) to liResult && 32 ms pour 14.000 enr. avec affichage du résultat, 31 ms sans
		set filter to &lcFilter in (m.tcAlias)

otherwise

		use (dbf(m.tcAlias)) in 0 again shared alias _iAutoInc && évite SET FILTER
		calculate max(&tcField) in _iAutoInc to liResult
		use in _iAutoInc

endcase

if m.llUsed
	use in (m.tcAlias)
endif

return nvl(m.liResult, 0) + evl(m.tiIncrement, 1)

* ========================================
function cSelectSQL && Construit une instruction SELECT-SQL à partir de ses clauses
lparameters ;
	tcSELECT as string,; && Clause SELECT
	tcFROM as string,; && Clause FROM
	tcWHERE as string,; && [''] Clause WHERE
	tcGROUP as string,; && [''] Clause GROUP BY
	tcHAVING as string,; && [''] Clause HAVING
	tcUNION as string,; && [''] Clause UNION
	tcORDER as string,; && [''] Clause ORDER BY
	tcINTO as string,; && [''] Clause INTO
	tlBuffering && [.F.] (VFP seulement) Lire les données en mémoire tampon

tcWHERE = iif(vartype(m.tcWHERE) == 'C' and not empty(m.tcWHERE), 		' WHERE ' + m.tcWHERE, '')
tcGROUP = iif(vartype(m.tcGROUP) == 'C' and not empty(m.tcGROUP), 		' GROUP BY ' + m.tcGROUP, '')
tcHAVING = iif(vartype(m.tcHAVING) == 'C' and not empty(m.tcHAVING), 	' HAVING ' + m.tcHAVING, '')
tcUNION = iif(vartype(m.tcUNION) == 'C' and not empty(m.tcUNION), 		' UNION ' + m.tcUNION, '')
tcORDER = iif(vartype(m.tcORDER) == 'C' and not empty(m.tcORDER), 		' ORDER BY ' + m.tcORDER, '')
tcINTO = iif(vartype(m.tcINTO) == 'C' and not empty(m.tcINTO), 				' INTO ' + m.tcINTO, '')
tlBuffering = iif(pcount() >= 9 and vartype(m.tlBuffering) == 'L';
		, textmerge([ WITH (BUFFERING = <<m.tlBuffering>>) ]);
		, '')

return textmerge([SELECT <<m.tcSELECT>> FROM <<m.tcFROM>><<m.tlBuffering>><<m.tcWHERE>><<m.tcGROUP>><<m.tcHAVING>><<m.tcUNION>><<m.tcORDER>><<m.tcINTO>>])

* ========================================
function VFPSelectExecute && Exécute un SELECT-SQL VFP dans un tableau, une table ou un curseur dont l'alias est sélectionné au retour
lparameters ;
	tcSELECT,; && Intruction SELECT-SQL
	tuDest,; && @ Destination : array OU adresse de table OU nom de curseur [INTO CURSOR Sys(2015)]
	tlReadWrite,; && [.F.] (applicable si curseur) curseur modifiable
	tlNoFilter,; && [.F.] (applicable si curseur) forcer la création d'une table sur disque
	tlThermoNo,; && [.F.] ne pas afficher la barre d'avancement
	tcComment,; && [''] commentaire de debug
	tcResult && @ [''] Résultat

tcResult = ''

local lnResult; && Nombre d'enregistrements trouvés (_tally)
, llResult;
, lcSelect;
, lcDest;
, loSafety as abSet of abDev.prg;
, loSQLThermo as abSQLthermo of abData.prg;
, llDegugOut;
, lcSelectShow;
, loExcep as exception;

lnResult = 0

* Si l'instruction SELECT est valide
lcSelect = m.tcSELECT
llResult = lSelectInst(@m.lcSelect) && _VFP.StartMode > 0 OR
if m.llResult

* Ajouter la clause de destination
	if type('tuDest', 1) == 'A'
		lcDest = 'ARRAY tuDest'
	else
		tuDest = iif(vartype(m.tuDest) == 'C', alltrim(m.tuDest), '')
		if lFileAddress(m.tuDest)
			lcDest = 'TABLE ' + cLitteral(m.tuDest)
			loSafety = abSet('SAFETY', 'OFF')
		else
			tuDest = evl(m.tuDest, sys(2015))
			lcDest = 'CURSOR ' + m.tuDest ;
					+ iif(lTrue(m.tlReadWrite), ' READWRITE', '');
					+ iif(lTrue(m.tlNoFilter), ' NOFILTER', '')
		endif
	endif
	lcSelect = m.lcSelect + ' INTO ' + m.lcDest

* Exécuter le Select
	loSQLThermo = createobject('abSQLthermo', m.tlThermoNo)
	llDegugOut = _vfp.startmode = 0 and wexist('Debug Output')
	try

* Loger les résultats si demandé
		if llDegugOut
			lcSelectShow = cSelectInstShow(m.lcSelect)
			tcComment = iif(vartype(m.tcComment) == 'C', space(1) + alltrim(m.tcComment) + space(1), '')
			debugout space(1)
			debugout padr(textmerge([<<Datetime()>> - OPTIMIZE <<Set("Optimize")>> - DELETED <<Set("Deleted")>> - COLLATE '<<Set("Collate")>>' - ANSI '<<Set("ANSI")>>' -<<m.tcComment>>]), 120, '-')
			debugout m.lcSelectShow
			debugout 'Appelé par', cCallingModules()
			debugout textmerge([L'instruction SELECT fait <<Ltrim(Transform(Len(m.lcSelect), '99 999'))>> caractères, soit <<Int(Len(m.lcSelect)/8192*100)>>% de la limite de 8.192 caractères])
			private pcSYS3054
			sys(3054, 11, 'pcSYS3054')
			local lnSeconds
			lnSeconds = seconds()
		endif

		&lcSelect
		lnResult = _tally

		if llDegugOut
			debugout m.pcSYS3054
			tcResult = cQueryPerf(nSeconds(m.lnSeconds), m.lnResult)
		endif

	catch to m.loExcep
		llResult = .f.
		_cliptext = iif(m.llDegugOut, m.lcSelectShow, _cliptext)
		tcResult = [Erreur dans l'instruction Select ] + iif(llDegugOut, [(dans clip board) ], '') + ": " + cException(m.loExcep)

	finally
		if llDegugOut
			sys(3054, 0)
		endif
	endtry
else
	tcResult = [Invalid SELECT instruction ] + cLitteral(m.tcSELECT)
endif

debugout m.tcResult

assert m.llResult message cAssertMsg(m.tcResult)

return m.lnResult

* ========================================
function cQueryPerf && Performance d'une requête
lparameters ;
	tnSecs,; && Nombre de secondes
	tnRecs && Nombre d'enr. trouvés

return cBarsSecs(m.tnSecs) + [ pour trouver ]  + ltrim(transform(m.tnRecs, '999 999')) + [ enregistrements]

* ========================================
function lSelectInst && Instruction SELECT valide
lparameters tcSELECT && @ Intruction SELECT-SQL présumée

if vartype(m.tcSELECT) == 'C' and not empty(m.tcSELECT)
	tcSELECT = alltrim(chrtran(m.tcSELECT, ';' + CRLF, space(1)))
	return 'SELECT ' $ upper(m.tcSELECT) and ' FROM ' $ upper(m.tcSELECT) && inutile de créer une variable pour ça !
else
	tcSELECT = ''
	return .null.
endif


* ========================================
function cSelectInstShow && Instruction SELECT décomposée sur plusieurs lignes
lparameters tcSELECT && Intruction SELECT-SQL

local laClauses[1], lcClause, llResult, lcResult

lcResult = ''
llResult = lSelectInst(@m.tcSELECT)
if m.llResult

	lcResult = cRepCharDel(chrtran(m.tcSELECT, chr(9), space(1)))

	alines(laClauses, 'FROM,WITH,WHERE,GROUP,INNER,LEFT,RIGHT,FULL,UNION,HAVING,ORDER,INTO', 1, ',')
	for each lcClause in laClauses
		lcClause = ' ' + m.lcClause + ' '

		lcResult = strtran(m.lcResult, m.lcClause, ';' + CRLF +  m.lcClause, 1, -1, 1)
	endfor
endif

return m.lcResult

#if .f. && Regexp qui décompose une instruction SELECT SQL
^\s*
select\s+(?<select>(?:\([^)]*\)|.)+)\s+
from\s+(?<from>(?:\([^)]*\)|.)+?)(?:\s+
where\s+(?<where>(?:\([^)]*\)|.)+?))?(?:\s+
group by\s+(?<groupby>(?:\([^)]*\)|.)+?))?(?:\s+
having\s+(?<having>(?:\([^)]*\)|.)+?))?(?:\s+
order by\s+(?<orderby>(?:\([^)]*\)|.)+?))?(?:\s+
LIMIT\s+(?<LIMIT>(?:\([^)]*\)|.)+?))?
\s*$
#endif

* =================================================
define class abSQLthermo as custom && Affiche la barre d'avancement SQL sans message parasite
* =================================================

protected lThermo, cTalk, cNotify, cWindowTalk, cWindowOutput

lThermo = .f.
cTalk = ""
cNotify = ""
cWindowTalk = ""
cWindowOutput = ""
name = "abSQLthermo"

* ---------------------------------------------------
procedure init
lparameters tlThermoNo && [.F.] ne pas afficher la barre d'avancement

this.cTalk = set("TALK")
this.cNotify = set("NOTIFY")

this.lThermo = !(lTrue(m.tlThermoNo));
	and inlist(_vfp.startmode, 0, 4)

#if .f. && _vfp.Startmode
	0 development version in an interactive session.
	1 application object
	2 out-of-process .exe automation server.
	3 in-process .dll automation server.
	4 distributable .app or .exe file.
	5 in-process .dll automation server for multithreaded use.
#endif

if m.this.lThermo

	set notify on

* TBV setting talk on makes the next 4 statements echo to console and
* mess up  the development mode display. Moved.
* SET TALK ON

* Direct Talk to an invisible window
	this.cWindowOutput = "W"+sys(2015)
	define window (this.cWindowOutput) from -100,-100 to -10,-10
	this.cWindowTalk = set("TALK", 1) && retourne "WINDOW xx"

	set talk on	&& TBV
	set talk window (this.cWindowOutput)

else

	set notify off
	set talk off

endif

* ---------------------------------------------------
procedure destroy

* restore SET NOTIFY et SET TALK
local lcTalk, lcNotify
lcTalk = m.this.cTalk
lcNotify = m.this.cNotify
set talk &lcTalk
set notify &lcNotify

if m.this.lThermo

	local lcWindowTalk
	lcWindowTalk = this.cWindowTalk
	set talk &lcWindowTalk

	release window (this.cWindowOutput)
endif


* =================================================
enddefine && class abSQLthermo
* =================================================

* ========================================
function cVarType && Type de variable d'après le type de champ
lparameters ;
	tcType && Type de champ
local lcResult, llResult
lcResult = ''

llResult = vartype(m.tcType) == 'C';
 and len(m.tcType) = 1;
 and m.tcType $ VFP9_FIELD_TYPES && WCYDTBGILMNFQV
assert m.llResult message cAssertMsg(textmerge('Invalid Field Type: <<cLitteral(m.tcType)>>'))
if m.llResult

	lcResult = icase(.f., '';
	 , m.tcType $ 'CMV', 'C';
	 , m.tcType $ 'NFBI', 'N';
	 , m.tcType $ 'WQ', 'Q';
	 , m.tcType;
	 )
endif

return m.lcResult

* ========================================
procedure TablesFieldRename && Renomme un champ dans plusieurs tables
lparameters ;
	tcTablesSkel,; && Squelette de l'adresse des tables
	tcField,; && Champ à renommer
	tcFieldNew && Nouveau nom du champ
local lnResult, llResult && Nombre de tables traitées
lnResult = 0

* Si au moins une table répond au squelette
local array laTables[1]
local lnTables
lnTables = aFiles(@m.laTables, m.tcTablesSkel)
llResult = m.lnTables > 0
assert m.llResult message cAssertMsg(textmerge('No table match the specified skeleton: <<cLitteral(m.tcTablesSkel)>>'))
if m.llResult
	debugout textmerge("Starting renaming field <<m.tcField>> to <<m.tcFieldNew>> in <<m.lnTables>> tables <<cLitteral(m.tcTablesSkel)>> AT <<Datetime()>>")

* Pour chaque table
	local lcFolder, lnTable, lcTable, lcTableAddr
	lcFolder = addbs(justpath(m.tcTablesSkel))
	asort(laTables)
	for m.lnTable = 1 to m.lnTables
		lcTable = laTables[m.lnTable]
		lcTableAddr = m.lcFolder + m.lcTable

* Renommer
		llResult = TableFieldRename(m.lcTableAddr, m.tcField, m.tcFieldNew)

* Faire part du résultat
		lnResult = m.lnResult + iif(m.llResult, 1, 0)
		debugout textmerge("<<Str(m.lnTable, 3)>> - Field <<m.tcField>> <<Iif(m.llResult, 'renamed to ' + m.tcFieldNew, 'could not be renamed')>> in table <<cLitteral(m.lcTable)>>")
	endfor

	debugout textmerge('Finished renaming field <<m.tcField>> to <<m.tcFieldNew>> in <<m.lnResult>> tables <<cLitteral(m.tcTablesSkel)>> at <<Datetime()>>')

endif


return m.lnResult

* ========================================
procedure TableFieldRename && Renomme un champ dans une table
lparameters ;
	tcTable,; && Adresse de la table
	tcField,; && Champ à renommer
	tcFieldNew && Nouveau nom du champ
local llResult && Le champ a été renommé

* Si la table existe
llResult = lFile(m.tcTable)
assert m.llResult message cAssertMsg(textmerge('Table cannot be found: <<cLitteral(m.tcTable)>>'))
if m.llResult

* Si les noms sont corrects
	llResult = lVFPName(@m.tcField) and lVFPName(@m.tcFieldNew)
	assert m.llResult message cAssertMsg(textmerge("Invalid Field names: <<cLitteral(m.tcField)>> / <<cLitteral(m.tcFieldNew)>>"))
	if m.llResult

* Si la table peut être ouverte en exclusif
		local lcAlias
		lcAlias = ExclusiveForce(m.tcTable)
		llResult = used(m.lcAlias)
		assert m.llResult message cAssertMsg(textmerge("Table <<cLitteral(m.tcTable)>> cannot be opened exclusively"))
		if m.llResult

* Si le champ est dans la table
			llResult = lField(m.tcField, m.lcAlias)
			if m.llResult

* Si la table a des indexes
				local laTags[1], lnTags, llTags
				lnTags = ataginfo(laTags, '', m.lcAlias)
				if m.lnTags > 0

* Sélectionner la table
					local loSelect
					loSelect = abSelect(m.lcAlias)

* Pour chaque index
					local liTag, llKey, llFilter
					for m.liTag = m.lnTags to 1 step -1

* Si le champ est dans l'expression d'index ou de filtre && dans ce cas le renommage sera impossible (erreur 1531)
						llKey = m.tcField $ laTags[m.liTag, 3]
						llFilter = m.tcField $ laTags[m.liTag, 4]
						if m.llKey or m.llFilter

* Si l'index est primaire, sortir
							llResult = not primary(m.liTag)
							if not m.llResult
								exit
							endif

* Sinon, supprimer du tableau
						else
							adel(laTags, m.liTag)
							lnTags = m.lnTags - 1
						endif
					endfor
				endif
				llTags = m.lnTags > 0

				assert m.llResult message cAssertMsg(textmerge("Field <<m.tcField>> cannot be renamed because part of the primary index"))
				if m.llResult

* Supprimer les indexes le cas échéant
					if m.llTags
						for m.liTag = 1 to m.lnTags
							delete tag (laTags[m.liTag, 1])
						endfor
					endif

* Renommer le champ
					alter table (m.lcAlias) rename column (m.tcField) to (m.tcFieldNew)

* Supprimer la sauvegarde
					delete file (forceext(m.tcTable, 'BAK'))

* Rétablir les index
					if m.llTags
						local lcTag, lcType, lcKey, lcFilter, lcCollate, lcOrder
						for m.liTag = 1 to m.lnTags
							lcTag = strtran(upper(laTags[m.liTag, 1]), m.tcField, m.tcFieldNew)
							lcType = laTags[m.liTag, 2]
							lcType = iif(m.lcType == 'REGULAR', '', m.lcType)
							lcKey = strtran(upper(laTags[m.liTag, 3]), m.tcField, m.tcFieldNew)
							lcFilter = strtran(upper(laTags[m.liTag, 4]), m.tcField, m.tcFieldNew)
							lcFilter = iif(empty(m.lcFilter), '', 'FOR ' + m.lcFilter)
							lcOrder = laTags[m.liTag, 5]
							lcCollate = cLitteral(laTags[m.liTag, 6])
							index on &lcKey tag &lcTag collate &lcCollate &lcFilter &lcOrder &lcType additive
						endfor
					endif
				endif
			else
				debugout textmerge("Field <<cLitteral(m.tcField)>> is not in table <<cLitteral(m.tcTable)>>")
			endif
			use in (m.lcAlias)
		endif
	endif
endif

return m.llResult

*!*		29/07/11 - dépréciée - remplacée par gaDBCTablesTree()
* ========================================
function aDBCTablesTree && Tables d'une base de données dans l'ordre de parenté
lparameters ;
	taTables,; && @ Tables
	tcDBC,; && Base de données
	tcExcludes,;  && Table(s) à exclure
	tlAsc && [.F.] /!\ à developper /!\ Ordonner les tables selon les parentés ascendantes
external array taTables

local llResult, lnResult && nombre de tables
lnResult = 0
llResult = type('taTables', 1) == 'A'
assert m.llResult message cAssertMsg(textmerge([tableau attendu en premier paramètre <<cLitteral(m.taTables)>>]))
if m.llResult

	llResult = vartype(m.tcDBC) == 'C' and dbused(m.tcDBC)
	assert m.llResult message cAssertMsg(textmerge([Invalid database specification: <<cLitteral(m.tcDBC)>>]))
	if m.llResult

* Tabuler les tables de la base de données
		local loDB, lnExcludes, laExcludes[1], lnExclude;
		, lnTable, lcTable, lcTableUp, lnTableUp, llTablesUp, llTableUp;
		, lnLevel, laRels[1], lnRels, lnRel

		loDB = abSet('DATABASE', m.tcDBC,,,.t.)
		lnResult = adbobjects(taTables, "TABLE")
		aColsIns(@m.taTables,,,1) && lnLevel = 1 par défaut

* Tant que des tables parent sont détectées
		tlAsc = iif(vartype(m.tlAsc) == 'L', m.tlAsc, .f.) && /!\ à developper /!\ Ordonner les tables selon les parentés ascendantes
		llTablesUp = .t.
		do while m.llTablesUp

* Pour chaque table non exclues
			llTablesUp = .f.
			for lnTable = 1 to m.lnResult
				lcTable = taTables[m.lnTable, 1]
				if ascan(laExcludes, m.lcTable) = 0

					lnLevel = taTables[m.lnTable, 2] + 1

* Si la table a des relations ascendantes
					lnRels = aDBCJoinsUp(@m.laRels, m.tcDBC, m.lcTable) && [Table enfant | Table parent | Tag enfant | Tag parent | RI]
					if m.lnRels > 0

* Pour chaque table parent
						for lnRel = 1 to m.lnRels
							lcTableUp = laRels[m.lnRel, 2]

* Si aucune relation mutuelle entre la table et sa parente
							if not lDBCTableParent(m.tcDBC, m.lcTableUp, m.lcTable)

* Si le niveau de la table parent est inférieur au courant
								lnTableUp = ascan(taTables, m.lcTableUp, 1, -1, 1, 15)
								llTableUp = taTables[m.lnTableUp, 2] < m.lnLevel
								if m.llTableUp

* Régler la niveau de la table parent
									taTables[m.lnTableUp, 2] = m.lnLevel
									llTablesUp = .t.
								endif
							endif
						endfor
					endif
				endif
			endfor
		enddo
		asort(taTables, 2, -1, 1) && sort descending
	endif

* Supprimer les tables à exclure éventuelles
	lnExcludes = alines(laExcludes, upper(evl(m.tcExcludes, '')), 1+4, ',', ';')
	if m.lnExcludes > 0
		for each lcTable in laExcludes
			lnExclude = ascan(taTables, m.lcTable, 1, -1, 1, 2+4+8)
			if m.lnExclude > 0
				adel(taTables, m.lnExclude)
				lnResult = m.lnResult - 1
			endif
		next
		llResult = m.lnResult > 0
		assert m.llResult message cAssertMsg(textmerge(['<<m.tcExcludes>>' exclut toutes les tables de la BD '<<m.tcDBC>>' !]))
		if m.llResult
			dimension taTables[m.lnResult, 2]
		endif
	endif

	aColDel(@m.taTables, 2)
endif

return m.lnResult

* ========================================
function lDBCTableParent && Une table est parente d'une autre dans une base de données
lparameters ;
	tcDBC,; && Base de données
	tcTableChild,; && Table enfant
	tcTableParent && Table parent supposée
local loSet, laJoins[1], llResult

llResult = vartype(m.tcTableParent) == 'C' and not empty(m.tcTableParent)
assert m.llResult message cAssertMsg(textmerge([spécification de table parent invalide : <<cLitteral(m.tcTableParent)>>]))
if m.llResult
	tcTableParent = upper(alltrim(m.tcTableParent))

	loSet = abSet('DATABASE', m.tcDBC,,,.t.)
	llResult = indbc(m.tcTableParent, "TABLE")
	assert m.llResult message cAssertMsg(textmerge([la table parent <<m.tcTableParent>> ne fait pas partie de la base de données <<m.tcDBC>>]))
	if m.llResult

		llResult = aDBCJoinsUp(@m.laJoins, m.tcDBC, m.tcTableChild) > 0;
		 and ascan(laJoins, m.tcTableParent,1, -1, 2, 6) > 0
	endif
endif

return m.llResult

* ========================================
function aDBCJoinsUp && Jointures ascendantes d'une table dans une base de données
lparameters ;
	taJoins,; && @ Jointures ascendantes : [1-Table enfant | 2-Table parent | 3-Tag enfant | 4-Tag parent | 5-RI]
	tcDBC,; && Base de données
	tcTableChild,; && Table enfant
	tcTablesIgnore,; && [''] Tables parent à ignorer
	tcFKsChild && [toutes] Clés étrangères (tags) enfant à examiner
external array taJoins

local laRelations[1], laTablesIgnore[1];
, llResult, lnResult && Nombre de jointures trouvées

lnResult = 0

* Si la base de données est ouverte
llResult = vartype(m.tcDBC) == 'C' and dbused(m.tcDBC)
assert m.llResult message cAssertMsg(textmerge("Invalid database specification: <<cLitteral(m.tcDBC)>>"))
if m.llResult

	if not set("Database") == upper(juststem(m.tcDBC)) && optimisation
		local loSetDB
		loSetDB = abSet('DATABASE', m.tcDBC,,,.t.)
	endif

* Si la base de données contient des relations
	llResult = adbobjects(laRelations, "RELATION") > 0 && all upper case
	assert m.llResult message cAssertMsg(textmerge("No relation in database <<cLitteral(m.tcDBC)>>"))
	if m.llResult

* Si la table enfant est dans la base de données
		llResult = vartype(m.tcTableChild) == 'C' and indbc(m.tcTableChild, "TABLE")
		assert m.llResult message cAssertMsg(textmerge("Table <<cLitteral(m.tcTableChild)>> is not in database <<cLitteral(m.tcDBC)>>"))
		if m.llResult
			tcTableChild = upper(alltrim(m.tcTableChild))

* Si le(s) clés étrangères enfant sont valides
			tcFKsChild = iif(vartype(m.tcFKsChild) == 'C', m.tcFKsChild, '')
			if not empty(m.tcFKsChild)
				llResult = lTags(m.tcFKsChild, m.tcDBC + '!' + m.tcTableChild)
				assert m.llResult message cAssertMsg(textmerge([At least one foreign key <<m.tcFKsChild>> does not belong to table <<m.tcTableChild>>]))
				if m.llResult

* Supprimer les relations sur des tags enfant non spécifiés
					aDBCJoinsUp_FKsChild(@m.laRelations, m.tcTableChild, m.tcFKsChild)
				endif
			endif
			if m.llResult

* Tabuler les tables parent à ignorer
				tcTablesIgnore = iif(vartype(m.tcTablesIgnore) == 'C', m.tcTablesIgnore, '')
				tcTablesIgnore = upper(c2Words(m.tcTablesIgnore, ',', m.tcTableChild)) && évite une récursion en cas de jointure mutuelle
				alines(laTablesIgnore, m.tcTablesIgnore, 1, ',')

* Chercher les jointures à partir de la table
				if aClear(@m.taJoins)
					lnResult = aDBCJoinsUp_1(@m.taJoins, @m.laRelations, m.tcTableChild, @m.laTablesIgnore)
				endif
			endif
		endif
	endif
endif

return m.lnResult

* ========================================
function aDBCJoinsUp_FKsChild && [privée de aDBJoinsUp()] - Filtre les relations sur les tags indiqués
lparameters ;
	taRelations,; && @ Relations
	tcTableChild,; && Table enfant
	tcFKsChild && Clés étrangères (tags) enfant (dans la table enfant)
external array taRelations

* Si des tags enfants sont à examiner
local array laFKsChild[1]
if alines(laFKsChild, upper(m.tcFKsChild), 1+4, ',') > 0

* Pour chaque relation
	local lnRels, lnRel
	lnRels = alen(taRelations, 1)
	for lnRel = m.lnRels to 1 step -1

* Si l'enfant de la relation est la table indiquée et le tag enfant ne fait pas partie de ceux retenus
		if taRelations[m.lnRel, 1] == m.tcTableChild;
		 and ascan(laFKsChild, taRelations[m.lnRel, 3], 1, -1, 1, 6) = 0

* Supprimer la relation
			adel(taRelations, m.lnRel)
			lnRels = lnRels - 1
		endif
	endfor

	dimension taRelations[m.lnRels, Alen(taRelations, 2)]
endif

* ========================================
function aDBCJoinsUp_1 && (privée de aDBJoinsUp, récursive) Relations ascendantes d'une table
lparameters ;
	taJoins,; && @ Relations ascendantes : [Table enfant | Table parent | Tag enfant | Tag parent | Vide]
	taRelations,; && @ Relations de la base de données
	tcTableChild,; && Table enfant
	taTablesIgnore && @ Ignorer ces tables parent
external array taJoins, taRelations, taTablesIgnore

local lnRel, lnCols, lcTableParent, lnResult && Nombre de tables trouvées

lnResult = iif(laEmpty(@m.taJoins), 0, alen(taJoins, 1))
lnCols = alen(taRelations, 2)
lnRel = 0

* Pour chaque relation dont la table est enfant
do while .t.

	lnRel = ascan(taRelations, m.tcTableChild, m.lnRel+1, -1, 1, 14) && 2+4+8
	if m.lnRel > 0

* Si la table parent n'est pas ignorée et n'a pas encore été rencontrée
		lcTableParent = taRelations[m.lnRel, 2]
		if not m.lcTableParent == tcTableChild; && auto-jointure
		 and ascan(taTablesIgnore, m.lcTableParent, 1, -1, 1, 6) = 0; && table ignorée
		 and ascan(taJoins, m.lcTableParent, 1, -1, 1, 6) = 0 && relation mutuelle

* Ajouter la relation
			lnResult = m.lnResult + 1
			dimension taJoins[m.lnResult, m.lnCols]
			acopy(taRelations, taJoins, aelement(taRelations, m.lnRel, 1), m.lnCols, aelement(taJoins, m.lnResult, 1))

* Récurser sur la table parent
			lnResult = aDBCJoinsUp_1(@m.taJoins, @m.taRelations, m.lcTableParent, @m.taTablesIgnore)
		endif
	else
		exit
	endif
enddo

return m.lnResult

* -----------------------------------------------------------------
procedure aDBCJoinsUp_Test

public array gaJoins[1] && Pour consultation après test

local loTest as aDBCJoins_Test of abData.prg, llResult
loTest = createobject('aDBCJoins_Test')
if loTest.dataopen("C:\aDossier\3609 VS CatElec\Interne\Inet\Donnees\VSCAT.DBC") && a un ASSERT

	aClear(@m.gaJoins)
	loTest.Test(10, @m.gaJoins, 'vscat', 'tad_sel')
endif

if loTest.dataopen("C:\ADOSSIER\3680 AF INTUICAT\INTERNE\DONNEES\AFVOL.DBC") && a un ASSERT

	aClear(@m.gaJoins)
	loTest.Test(9, @m.gaJoins, 'AFVOL', 'PROGR', 'ZUSER')

	aClear(@m.gaJoins)
	loTest.Test(2, @m.gaJoins, 'AFVOL', 'PROGR', 'ZUSER', 'IATADEP')
endif

return loTest.Result()

* ========================================
function aDBCJoinsParent && Jointures dont une table est parent
lparameters ;
	taJoins,; && @ Jointures: [1-Table enfant | 2-Table parent | 3-Tag enfant | 4-Tag parent | 5-RI]
	tcDBC,; && Base de données
	tcTableParent && Table de départ
external array taJoins
local llResult, lnResult && Nombre de relations
lnResult = 0

* Si la base de données est valide
llResult = vartype(m.tcDBC) == 'C' and dbused(m.tcDBC)
assert m.llResult message cAssertMsg(textmerge([Invalid database specification: <<cLitteral(m.tcDBC)>>]))
if m.llResult

	if not set("Database") == upper(juststem(m.tcDBC)) && optimisation
		local loSetDB
		loSetDB = abSet('DATABASE', m.tcDBC,,,.t.)
	endif

* Si la table parent est dans la base de données
	llResult = vartype(m.tcTableParent) == 'C' and indbc(m.tcTableParent, "TABLE")
	assert m.llResult message cAssertMsg(textmerge("Table <<cLitteral(m.tcTableParent)>> is not in database <<cLitteral(m.tcDBC)>>"))
	if m.llResult
		tcTableParent = upper(alltrim(m.tcTableParent))

* Si la base de données contient des relations
		lnResult = adbobjects(taJoins,"RELATION") && all upper case
		llResult = m.lnResult > 0
		assert m.llResult message cAssertMsg(textmerge("No relation in database <<cLitteral(m.tcDBC)>>"))
		if m.llResult

* Pour chaque relation en partant de la fin
			local lnRel
			for lnRel = m.lnResult to 1 step -1

* Si la table parent de la relation n'est pas la table indiquée, supprimer
				if not taJoins[m.lnRel, 2] == m.tcTableParent
					lnResult = m.lnResult - 1
					adel(taJoins, m.lnRel)
				endif
			endfor
			if m.lnResult > 0
				dimension taJoins[m.lnResult, 5]
			endif
		endif
	endif
endif

return m.lnResult

* -----------------------------------------------------------------
procedure aDBCJoinsParent_Test && aDBCJoinsParent() unit test

public array gaJoins[1] && Pour le consulter après test

local loTest as aDBCJoins_Test of abData.prg
loTest = createobject('aDBCJoins_Test')
if loTest.dataopen("C:\aDossier\3609 VS CatElec\Interne\Inet\Donnees\VSCAT.DBC")

	aClear(@m.gaJoins)
	loTest.Test(2, @m.gaJoins, 'vscat', 'carr')
endif

return m.loTest.Result()

* ------------------------------
define class aDBCJoins_Test as abUnitTest of abDev.prg

	procedure dataopen
		lparameters tcDBC && Adresse de la base de données
		local llResult

		tcDBC = locfile(m.tcDBC, 'DBC', justfname(m.tcDBC) + ' ?')
		llResult = file(m.tcDBC)
		assert m.llResult message cAssertMsg(textmerge("Test File does not exist: <<cLitteral(DisplayPath(m.tcDBC, 30))>>"))
		if m.llResult

			open database (m.tcDBC)
		endif

		return m.llResult

	enddefine

* ========================================
function aDBCJoinsChild && Jointures dont une table est enfant
lparameters ;
	taJoins,; && @ [Table enfant | Table parent | Tag enfant | Tag parent | Vide]
	tcDBC,; && Base de données
	tcTableChild,; && Table enfant
	tcTablesIgnore && [''] Ignorer ces tables parent
external array taJoins
local llResult, lnResult && Nombre de relations
lnResult = 0

* Si la base de données est valide
llResult = vartype(m.tcDBC) == 'C' and dbused(m.tcDBC)
assert m.llResult message cAssertMsg(textmerge([Invalid database specification: <<cLitteral(m.tcDBC)>>]))
if m.llResult

	if not set("Database") == upper(juststem(m.tcDBC)) && optimisation
		local loSetDB
		loSetDB = abSet('DATABASE', m.tcDBC,,,.t.)
	endif

* Si la table enfant est dans la base de données
	llResult = vartype(m.tcTableChild) == 'C' and indbc(m.tcTableChild, "TABLE")
	assert m.llResult message cAssertMsg(textmerge("Table <<cLitteral(m.tcTableChild)>> is not in database <<cLitteral(m.tcDBC)>>"))
	if m.llResult
		tcTableChild = upper(alltrim(m.tcTableChild))

* Si la base de données contient des relations
		aClear(@m.taJoins)
		lnResult = adbobjects(taJoins, "RELATION") && all upper case
		llResult = m.lnResult > 0
		assert m.llResult message cAssertMsg(textmerge("No relation in database <<cLitteral(m.tcDBC)>>"))
		if m.llResult

* Tabuler les tables à ignorer éventuelles
			local lnRel, laTablesIgnore[1]
			alines(laTablesIgnore, upper(iif(vartype(m.tcTablesIgnore) == 'C', m.tcTablesIgnore, '')), 1, ',')

* Pour chaque relation en partant de la fin
			for lnRel = m.lnResult to 1 step -1

* Si la relation est invalide,
				if not taJoins[m.lnRel, 1] == m.tcTableChild ; && la table enfant n'est pas celle spécifiée
				 or ascan(laTablesIgnore, taJoins[m.lnRel, 2], 1, -1, 1, 6) > 0 && la table parent est ignorée

* Supprimer
					adel(taJoins, m.lnRel)
					lnResult = m.lnResult - 1
				endif
			endfor
			if m.lnResult > 0
				dimension taJoins[m.lnResult, 5]
			endif
		endif
	endif
endif

return m.lnResult

* -----------------------------------------------------------------
procedure aDBCJoinsChild_Test

public array gaJoins[1] && Pour le consulter après test

local loTest as aDBCJoins_Test of abData.prg
loTest = createobject('aDBCJoins_Test')
if loTest.dataopen("C:\aDossier\3609 VS CatElec\Interne\Inet\Donnees\VSCAT.DBC")

	aClear(@m.gaJoins)
	loTest.Test(2, @m.gaJoins, 'vscat', 'dic_ligne')
endif

return loTest.Result()

* ========================================
function lTableReadOnly && Un fichier de table est en lecture seule
lparameters tcTable

local llResult as Boolean;
, lcAlias as string;
, llAlias as Boolean

if file(m.tcTable)
	lcAlias = sys(2015)
	try
		use (m.tcTable) in 0 again shared alias (m.lcAlias)
		llResult = used(m.lcAlias) and isreadonly(m.lcAlias)
	catch
	finally
		use in select(m.lcAlias)
	endtry
endif

return m.llResult

* ========================================
function lTableExpr && Une expression est valide sur une table
lparameters ;
	tc__Expr,; && Expression à vérifier
	tu__Table && [Alias()] table ou alias où vérifier l'expression

local lo__Select, lc__Alias, ll__Opened;
, lo__Except as exception, ll__Result && Evite que les noms des variables locales puissent figurer dans l'expression

ll__Result = vartype(m.tc__Expr) == 'C'
assert m.ll__Result message cAssertMsg(textmerge("Invalid expression parameter: <<cLitteral(m.tc__Expr)>>"))
if m.ll__Result

	ll__Result = empty(m.tc__Expr)
	if not m.ll__Result

		lc__Alias = cAlias(m.tu__Table, @m.ll__Opened)
		ll__Result = used(m.lc__Alias)
		assert m.ll__Result message cAssertMsg(textmerge("Table <<cLitteral(m.tu__Table)>> can't be found"))
		if m.ll__Result

			lo__Select = abSelect(0) && pour éviter toute confusion avec les champs de la table courante
			try
				= evaluate(cExprFieldsPrefixed(m.tc__Expr, m.lc__Alias, m.lc__Alias))
			catch to lo__Except
				ll__Result = inlist(m.lo__Except.errorno, 1929) && error 1929 : "name" can only be used within a method
			endtry

*			ASSERT m.ll__Result MESSAGE cAssertMsg(Textmerge("Expression <<cLitteral(m.tc__Expr)>> is not valid on table <<m.tu__Table>>; error: <<cException(m.lo__Except)>>"))
			if m.ll__Opened
				use in (m.lc__Alias)
			endif
		endif
	endif
endif

return m.ll__Result

* ========================================
function cExprFieldsPrefixed && Expression où les noms de champs d'une table sont préfixés (en général par 'm.' ou 'Alias.')
lparameters ;
	tcFieldsExpr,; && Expression comportant en principe des champs
	tcTable,; && Table où se trouvent les champs ou son alias
	tcPrefix && ['m'] Préfixe à ajouter avant les noms de champs (prefixe.champ)

local lcResult;
, llResult;
, lcAlias, llAlias;
, lcField;
, laOps[1]

lcResult = ''

llResult = vartype(m.tcFieldsExpr) == 'C';
 and vartype(m.tcTable) == 'C'
assert m.llResult message cAssertMsg(textmerge([Invalid Parameters(s)]))
if m.llResult

	lcResult = alltrim(m.tcFieldsExpr)
	if not empty(m.lcResult)

		lcAlias = iif(used(m.tcTable), m.tcTable, cAlias(m.tcTable, @m.llAlias))
		llResult = used(m.lcAlias)
		assert m.llResult message cAssertMsg(textmerge([La table '<<m.tcTable>>' est introuvable]))
		if m.llResult

			tcPrefix = iif(vartype(m.tcPrefix) == 'C', alltrim(m.tcPrefix), 'm')

* Si l'expression est un champ de la table
			lcField = JustField(m.lcResult)
			if lField(m.lcField, m.lcAlias)

				lcResult = c2Words(m.tcPrefix, [.], m.lcField)

* Sinon (expression complexe)
			else

* Si le nombre d'opérandes est inférieur au nombre de champs && optimisation
				lcResult = iif(aOperands(@m.laOps, m.lcResult) < fcount(m.lcAlias);
					, cExprFieldsPrefixed_Ops(@m.laOps, m.lcResult, m.lcAlias, m.tcPrefix);
					, cExprFieldsPrefixed_Fields(m.lcResult, m.lcAlias, m.tcPrefix);
					)
			endif

			if m.llAlias
				use in (m.lcAlias)
			endif
		endif
	endif
endif

return m.lcResult

* -----------------------------------------------------------------
function cExprFieldsPrefixed_Ops && cExprFieldsPrefixed() : Algorithme avec parcours des opérandes
lparameters ;
	taOps,; && @ Opérandes
	tcFieldsExpr,; && Expression comportant en principe des champs
	tcAlias,; && Alias de la table où se trouvent les champs
	tcPrefix && Préfixe à ajouter avant les noms de champs (prefixe.champ)
external array taOps

local lcResult;
, llResult;
, lcPrefix;
, lcOp, lnOp;
, lcField, lnField, lcPrefix2, laOccs[1], lnOcc;

* Pour chaque opérande dans l'expression
lcResult = m.tcFieldsExpr
lcPrefix = m.tcPrefix + iif(empty(m.tcPrefix), '', '.')
for each lcOp in taOps

* Si l'opérande est préfixé, ôter le préfixe
	lcField = iif([.] $ m.lcOp, substr(m.lcOp, atc([.], m.lcOp)+1), m.lcOp)

* Si l'opérande est un champ de la table
	lcField = field(m.lcField, m.tcAlias)
	if not empty(m.lcField)

* Tabuler les positions des occurrences du champ dans l'expression, de la fin au début
		llResult = anWordIn(@m.laOccs, m.lcResult, m.lcOp, .t., .t.) > 0
		assert m.llResult message cAssertMsg(textmerge([le mot <<cL(m.lcOp)>> devrait se trouver dans <<m.lcResult>>]))
		if m.llResult

			asort(laOccs, 1, -1, 1)
			lnOp = len(m.lcOp)
			lcField = m.lcPrefix + m.lcField
			for each lnOcc in laOccs

* Remplacer dans l'expression avec un préfixe
				lcResult = '';
					+ substr(m.lcResult, 1, m.lnOcc-1);
					+ m.lcField;
					+ substr(m.lcResult, m.lnOcc + m.lnOp)
			endfor
		endif
	endif
endfor

* Supprimer les doubles préfixes éventuels (peut arriver si le champ est présent deux fois dans l'expression)
lcPrefix2 = replicate(m.lcPrefix, 2)
do while m.lcPrefix2 $ m.lcResult
	lcResult = strtran(m.lcResult, m.lcPrefix2, m.lcPrefix)
enddo

return m.lcResult

* -----------------------------------------------------------------
function cExprFieldsPrefixed_Fields && Algorithme avec parcours des champs de la table
lparameters ;
	tcFieldsExpr,; && Expression comportant en principe des champs
	tcAlias,; && Alias de la table où se trouvent les champs
	tcPrefix && ['m'] Préfixe à ajouter avant les noms de champs (prefixe.champ)

local lcResult, lcResultU;
, lnField, lcField, lcField_, lnFieldAt;
, lnOccurs, lnOccur;
, lcCarAnte, lcCarPost;
, lnPrefix

lcResult = m.tcFieldsExpr

* Pour chaque champ de la table
lcResultU = upper(m.lcResult)
for lnField = 1 to fcount(m.tcAlias)

* Si le champ est dans l'expression
	if field(m.lnField, m.tcAlias) $ m.lcResultU

* Pour chaque occurrence du champ dans l'expression
		lcField = field(m.lnField, m.tcAlias)
		lnOccurs = occurs(m.lcField, m.lcResultU)
		for m.lnOccur = m.lnOccurs to 1 step -1
			lnFieldAt = atc(m.lcField, m.lcResultU, m.lnOccur)

* Si le nom du champ est encadré par séparateur ou opérateur
			lcCarAnte = substr(m.lcResultU, m.lnFieldAt - 1, 1)
			lcCarPost = substr(m.lcResultU, m.lnFieldAt + len(m.lcField), 1)
			llResult = (empty(m.lcCarAnte) or m.lcCarAnte $ VFPOPSEPCARS);
						 and (empty(m.lcCarPost) or m.lcCarPost $ VFPOPSEPCARS);
						 and not m.lcCarPost == '.'
			if m.llResult

* Si le nom du champ est préfixé, ôter le préfixe
				if m.lcCarAnte == '.'
					llResult = m.lnFieldAt > 2
					assert m.llResult message cAssertMsg(textmerge("Invalid expression: <<cLitteral(m.lcResult)>>"))
					if m.llResult

						for lnPrefix = m.lnFieldAt - 2 to 1 step -1
							if substr(m.lcResultU, m.lnPrefix, 1) $ VFPOPSEPCARS
								exit
							endif
						endfor
						lcResultU = substr(m.lcResultU, 1, m.lnPrefix) + substr(m.lcResultU, m.lnFieldAt)
						lcResult = substr(m.lcResult, 1, m.lnPrefix) + substr(m.lcResult, m.lnFieldAt)
					endif
				endif
				if m.llResult

* Précéder le nom de champ du préfixe
					lcField_ = c2Words(m.tcPrefix, '.', m.lcField)
					lcResultU = strtran(m.lcResultU, m.lcField, m.lcField_, m.lnOccur, 1)
					lcResult = strtran(m.lcResult, m.lcField, m.lcField_, m.lnOccur, 1, 1)
				endif
			endif
		endfor
	endif
endfor

return m.lcResult

* -----------------------------------------------------------------
procedure cExprFieldsPrefixed_Test

local loTest as cExprFieldsPrefixed_Test of abData.prg
loTest = newobject('cExprFieldsPrefixed_Test', 'abData.prg') && AS abUnitTest OF abDev.prg

loTest.Test('m.ABBREV+m.EXPANDED', 'FoxCode.abbrev+expanded', 'FoxCodeTest')
loTest.Test('m.ABBREV+m.EXPANDED', 'm.abbrev+FoxCode.expanded', 'FoxCodeTest')
loTest.Test('FoxCode.ABBREV+Left(FoxCode.EXPANDED, 10)', 'm.abbrev+Left(FoxCodeTest.expanded, 10)', 'FoxCodeTest', 'FoxCode')

return loTest.Result()

* ------------------------------
define class cExprFieldsPrefixed_Test as abUnitTest of abDev.prg
		procedure init
			use (_foxcode) in 0 again alias FoxCodeTest
			return dodefault()
		endproc
	enddefine

* ========================================
function cRecContent && Contenu de l'enregistrement courant d'un alias
lparameters tcAlias && [Alias()] Alias de la table
tcAlias = evl(m.tcAlias, alias())

local liField, lcField;
, llResult, lcResult

lcResult = ''

tcAlias = cAlias(m.tcAlias)
llResult = used(m.tcAlias)
assert m.llResult message cAssertMsg(textmerge(icase(;
	cLangUser() = 'fr',	[Alias ou Table introuvable: <<cLitteral(m.tcAlias)>>],; && copy-paste this line to add another language support
											[Alias or table can't be found: <<cLitteral(m.tcAlias)>>]; && Default: English
	)))
if m.llResult

* Pour chaque champ de la table
	for liField = 1 to fcount(m.tcAlias)
		lcField = field(m.liField, m.tcAlias)

* Ajouter son nom et son contenu au résultat
		lcResult = m.lcResult;
			+ CRLF;
			+ padr(cTronc(m.lcField, 20), 25, space(1));
			+ cTronc(cLitteral(evaluate(m.tcAlias + '.' + m.lcField), .t.), 50)

	endfor
endif

return m.lcResult

* -----------------------------------------------------------------
procedure cRecContent_Test

use (_foxcode) in 0 again alias FoxCodeTest
skip 10
? cRecContent('FoxCodeTest')
use in FoxCodeTest

* ========================================
function cTableComment && Désignation d'une table d'une base de données
lparameters tcTable && table

local lcAlias, llAlias, lcDBC, llDBC, lcDBC_, lcResult

lcResult = transform(m.tcTable)

lcAlias = cAlias(m.tcTable, @m.llAlias)
if used(m.lcAlias)

* Si la table appartient à une base de données
	lcDBC = cursorgetprop("Database", m.lcAlias)
	if not empty(m.lcDBC)

* Ouvrir la base de données le cas échéant
		llDBC = dbused(m.lcDBC)
		lcDBC_ = set("Database")
		if m.llDBC
			set database to (m.lcDBC)
		else
			open database (m.lcDBC) shared
		endif
		if indbc(m.tcTable,"TABLE")

			lcResult = evl(dbgetprop(m.tcTable, "TABLE", "Comment"), m.lcResult)
		endif

		if not m.llDBC
			close databases
		endif
		set database to (m.lcDBC_)
	endif
	if m.llAlias
		use in (m.lcAlias)
	endif
endif

return m.lcResult

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
function nRecsAcc && Nombre d'enregistrement couramment accessibles dans un alias
lparameters tcAlias && [Alias()] Alias à examiner

tcAlias = evl(m.tcAlias, alias())

local lnResult as integer;
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

llResult = used(m.tcAlias)
assert m.llResult message cAssertMsg(icase(;
	cLangUser() = 'fr',	[Alias introuvable :],; && copy-paste this line to add another language support
											[Alias can't be found:]; && Default: English
	) + cLitteral(m.tcAlias))
if m.llResult and reccount(m.tcAlias) > 0

	lcFilter = filter(m.tcAlias)
	lcOrder = order(m.tcAlias)
	if empty(m.lcFilter + m.lcOrder)

		return reccount(m.tcAlias)

	else

		lnSelect = select(0)
		select (m.tcAlias)

		if inlist(cursorgetprop("Buffering"), 2, 3) && tampon d'enregistrement, on ne peut pas modifier Recno()

			lcFor = iif(empty(m.lcOrder); && Expression de filtre de l'index courant
				, '';
				, sys(2021, int(val(sys(21))));
				)

			lcFilter = c2Words(cParenth(m.lcFilter), ' AND ', cParenth(m.lcFor))
			lcSelect = iif(empty(m.lcFilter), '', ' WHERE ' + m.lcFilter)
			lcCursor = sys(2015)
			lcSelect = textmerge([SELECT <<Field(1, m.tcAlias)>> FROM <<m.tcAlias>><<m.lcSelect>> INTO CURSOR <<m.lcCursor>>])
			lnSeconds = seconds()
			&lcSelect
			lnResult = _tally
			use

			lnSeconds = int(nSeconds(m.lnSeconds) * 1000)
			assert empty(m.lcFilter) or m.lnSeconds < 20 message cAssertMsg(textmerge(icase(;
				cLangUser() = 'fr',	[Le calcul du nombre d'enregistrements accessible de l'alias <<m.tcAlias>> prend <<m.lnSeconds>> ms ; essayez d'optimiser le filtre "<<m.lcFilter>>"],; && copy-paste this line to add another language support
														[Computing # of records accessibles in alias <<m.tcAlias>> takes <<m.lnSeconds>> ms ; try to optimize filter condition "<<m.lcFilter>>"]; && Default: English
				)))

		else

			loRecno = abRecno()

			lcTalk = set("Talk")
			set talk off && If SET TALK is ON, COUNT displays the record count.

			count to lnResult
&& Respects SET FILTER
&& Records marked for deletion are included in the count if Set("Deleted") = "OFF"

			set talk &lcTalk
		endif

		select (m.lnSelect)
	endif
endif

return m.lnResult

* ========================================
function nRecsAdded && Nombre d'enregistrements ajoutés à un alias tamponné
lparameters tcAlias && [Alias()] Alias
tcAlias = evl(m.tcAlias, alias())

local lnBuffering, llResult, lnResult
lnResult = 0

llResult = used(m.tcAlias)
assert m.llResult message cAssertMsg(icase(;
	cLangUser() = 'fr',	[Alias introuvable :],; && copy-paste this line to add another language support
											[Alias can't be found:]; && Default: English
	) + cLitteral(m.tcAlias))
if m.llResult

	lnBuffering = cursorgetprop("Buffering", m.tcAlias)
	do case
	case m.lnBuffering = 1
	case inlist(m.lnBuffering, 4, 5) && tampon de table

		local lnSelect, lcOrder, lcFilter, liRecno

		lnSelect = select(0)
		select (m.tcAlias) && optimisation

* Placer l'Alias dans son ordre naturel sans filtrage
		lcOrder = order()
		set order to
		lcFilter = filter()
		set filter to

		liRecno = Recno_()

		go bottom
		lnResult = recno()
		lnResult = iif(m.lnResult > 0;
			, 0; && aucun enregistrement ajouté
			, abs(m.lnResult); && le dernier enregistrement ajouté
			)

		RecnoSet(m.liRecno)

		set order to (m.lcOrder)
		set filter to &lcFilter
		select (m.lnSelect)

	otherwise && tampon d'enregistrement
		lnResult = iif(recno(m.tcAlias) < 0, 1, 0) && on ne peut ajouter qu'un enregistrement au plus
	endcase
endif

return m.lnResult

* ========================================
function nRecnoAbs && N° absolu d'un enregistrement dans un Alias même en tampon de table avec des enregistrements ajoutés (Recno() < 0)
lparameters tcAlias && [Alias()] Alias positionné sur l'enregistrement à examiner
tcAlias = evl(m.tcAlias, alias())

local lnRecs, llResult, lnResult

lnResult = 0

llResult = used(m.tcAlias)
lnRecs = iif(m.llResult, reccount(m.tcAlias), 0)
assert m.llResult message cAssertMsg(icase(;
	cLangUser() = 'fr',	[Alias introuvable :],; && copy-paste this line to add another language support
											[Alias can't be found:]; && Default: English
	) + cLitteral(m.tcAlias))
if m.lnRecs > 0

	lnResult = recno(m.tcAlias)

	lnResult = icase(;
		m.lnResult > 0,;
			m.lnResult,;
			m.lnRecs - nRecsAdded(m.tcAlias) - m.lnResult;
		)
&& 			InList(CursorGetProp("Buffering", m.tcAlias), 2, 3),;&& tampon d'enregistrement
&&		m.lnRecs + 1,; && un seul enregistrement peut être ajouté
&&

endif

return m.lnResult

* -----------------------------------------------------------------
procedure nRecnoAbs_Test

local loTest as nRecnoAbs_Test of abData.prg
loTest = createobject('nRecnoAbs_Test')
loTest.dataopen()

&& test 1
loTest.DataAdd5
loTest.Test(2, 'Test')
set datasession to m.loTest.datasessionid
loTest.assert(-1, recno('Test'))
set datasession to 1

&& test 2
loTest.DataAdd3
loTest.Test(2, 'Test')
set datasession to m.loTest.datasessionid
loTest.assert(2, recno('Test'))
set datasession to 1

return loTest.Result()

* ------------------------------
define class nRecnoAbs_Test as abUnitTest of abDev.prg

	procedure dataopen
	create cursor Test (Test L)
	append blank && 1

	procedure DataAdd5
	if cursorgetprop("Buffering") > 1
		tablerevert(.t.)
	endif
	cursorsetprop("Buffering", 5)
	append blank && 2, -1
	append blank && 2, -2
	skip -1

	procedure DataAdd3
	if cursorgetprop("Buffering") > 1
		tablerevert(.t.)
	endif
	cursorsetprop("Buffering", 3)
	append blank && 2, -1

	enddefine

* ========================================
function abOrder(Result, cAlias, cOrder, lDesc)
return createobject('abOrder', @m.Result, m.cAlias, m.cOrder, m.lDesc)

* ========================================
define class abOrder as GA_LIGHTWEIGHT_CLASS && saves, changes and restores Order()

hidden cAlias, cOrder, lDesc

* -------------------------------
protected procedure init
lparameters ;
  Result; && @
, cAlias;
, cOrder;
, lDesc

local success, lUsed, oSelect

cAlias = evl(m.cAlias, alias())
success = used(m.cAlias)
if not m.success

	cAlias = cAlias(m.cAlias, @m.lUsed,, @m.Result)
	success = used(m.cAlias)
endif

if m.success

	oSelect = abSelect(m.cAlias)
	this.cAlias = m.cAlias
	this.cOrder = iif(!m.lUsed, order(), .null.)
	this.lDesc  = iif(!m.lUsed and !isnull(evl(this.cOrder, .null.)), descending(), .null.)

	cOrder = iif(vartype(m.cOrder) == 'C', m.cOrder, '')
	if empty(m.cOrder)
		set order to
	else
		success = lTag(m.cOrder)
		if m.success
			lDesc  = iif(!empty(m.cOrder) and lTrue(m.lDesc), 'DESCENDING', '')
			set order to &cOrder in (m.cAlias) &lDesc
		endif
	endif
endif

return m.success

* -------------------------------
protected procedure destroy

if isnull(m.this.cOrder)
	use in (m.this.cAlias)
else
	local cOrder, cDesc
	cOrder = m.this.cOrder
	if empty(m.cOrder)
		set order to 0 in (m.this.cAlias)
	else
		cDesc  = iif(!empty(m.cOrder) and m.this.lDesc, 'DESCENDING', '')
		set order to (m.cOrder) in (m.this.cAlias) &cDesc
	endif
endif

enddefine && CLASS abOrder
* ========================================

* ========================================
function abFilter(cAlias, cFilter, Result)
return createobject('abFilter', m.cAlias, m.cFilter, @m.Result)

* ========================================
define class abFilter as GA_LIGHTWEIGHT_CLASS && Sauve Filter(<Alias>), USE <Alias> si nécessaire, applique un autre filtre, rétablit en sortie

hidden cAlias, cFilter

* -------------------------------
protected procedure init(cAlias, cFilter, Result)

local success as Boolean;
, lUsed as Boolean

cAlias = evl(m.cAlias, alias())
success = used(m.cAlias)
if not m.success

	cAlias = cAlias(m.cAlias, @m.lUsed,, @m.Result)
	success = used(m.cAlias)
endif

if m.success
	this.cAlias = m.cAlias
	this.cFilter = iif(m.lUsed, .null., filter(m.cAlias))
	cFilter = iif(vartype(m.cFilter) == 'C', m.cFilter, '')
	set filter to &cFilter in (m.cAlias)
endif

return m.success

* -------------------------------
protected procedure destroy

if isnull(m.this.cFilter)
	use in (m.this.cAlias)
else
	local lcFilter
	lcFilter = m.this.cFilter
	set filter to &lcFilter in (m.this.cAlias)
endif

enddefine && CLASS abFilter
* ========================================

* ========================================
function abRowBufferSave(tcAlias, tcError) && {en} Saves and restores an Alias' row buffer {fr} Sauve et rétablit le tampon d'enregistrement d'un Alias
return createobject('abRowBufferSave', m.tcAlias, @m.tcError)

* ========================================
define class abRowBufferSave as GA_LIGHTWEIGHT_CLASS && {en} Saves and restores an Alias' buffer {fr} Sauve et rétablit le tampon d'un Alias

hidden cAlias;
, cFldState;
, aBuffer[1];
, lAppended;
, lDeleted;

* -------------------------------
hidden procedure init
lparameters ;
  tcAlias; && [Alias()] {en} alias to work on
, tcError; && @ && {en} (cumulative) error if any

local success as Boolean;
, oSelect as abSelect of abData.prg;
, cFldState as string;
, iField as integer;

success = .t.;
 and varSet(@m.oSelect, abSelect(evl(m.tcAlias, alias())));
 and (used() or cResultAdd(textmerge([Table or Alias <<cL(m.tcAlias)>> can't be found])));
 and (inlist(cursorgetprop("Buffering"), 2, 3) or cResultAdd(textmerge([Alias '<<Alias()>>' should be row buffered])));
 and varSet(@m.cFldState, getfldstate(-1));
 and !empty(chrtran(m.cFldState, '1', ''))
if m.success

	this.cAlias = alias()
	this.cFldState = m.cFldState

	#if .f.
	1 field has not been modified or deletion status has not changed.
	2 field has been modified or deletion status has changed.
	3 field in an appended record has not been modified or deletion status has not changed for The appended record.
	4 field in an appended record has been modified or deletion status has changed for The appended record.
	#endif

	this.lAppended = '3' $ m.cFldState or '4' $ m.cFldState
	this.lDeleted = left(m.cFldState, 1) == iif(m.this.lAppended, '4', '2')

* {en} save the buffer {fr} sauve le buffer
	dimension this.aBuffer[Fcount()]
	for iField = 1 to fcount()
		this.aBuffer[m.iField] = evaluate(field(m.iField))
	endfor

	tablerevert()

	cursorsetprop("Buffering", 5)
	this.reset
endif

return m.success
endproc

* -------------------------------
hidden procedure reset

if m.this.lAppended
	append blank
endif

for iField = 1 to fcount()
	if substr(m.this.cFldState, m.iField + 1, 1) == iif(m.this.lAppended, '4', '2')
		replace (field(m.iField)) with this.aBuffer[m.iField]
	endif
endfor

if m.this.lDeleted
	delete
endif

* -------------------------------
hidden procedure destroy

local success as Boolean;
, oSelect as abSelect or abData.prg;
, cFldState as string;
, iField as integer;

if used(m.this.cAlias)

	oSelect = abSelect(m.this.cAlias)
	tablerevert(.t.)
	cursorsetprop("Buffering", 3)
	this.reset
endif
endproc

enddefine && CLASS abRowBufferSave
* ========================================

#if .f.
set deleted off
create cursor Test(Test I)
cursorsetprop("Buffering", 3)

Test = 1
? 1, getfldstate(-1) && .null.

append blank
Test = 1
? 2, getfldstate(-1)

delete
? 3, getfldstate(-1)

replace Test with 2
? 4, getfldstate(-1)

append blank
? 5, getfldstate(-1)

replace Test with 2
? 6, getfldstate(-1)

delete
? 7, getfldstate(-1)

tablerevert()
use
#endif


* -----------------------------------------------------------------
procedure abRowBufferSave_Test && abRowBufferSave() unit test

local loTest as abRowBufferSave_Test of abData.prg, liRecno as integer
loTest = newobject('abRowBufferSave_Test', 'abData.prg')

with m.loTest as abRowBufferSave_Test of abData.prg

.use
	.Test() && 1
	.assert(isnull(.cFldState()))

.insert
	.Test() && 2
	.assert(isnull(.cFldState()))

.setBuffering(3)
.append
	.Test() && 3
	.assert('33', .cFldState())

.update(2)
	.Test() && 4
	.assert('34', .cFldState())
	.assert(2, .value())

endwith

return m.loTest.Result()

* ------------------------------
define class abRowBufferSave_Test as abUnitTest of abDev.prg
	procedure use(in)
		if m.in
			use in select('abRowBufferSave_Test')
		else
			create cursor abRowBufferSave_Test (abRowBufferSave_Test I)
		endif
	procedure insert
		insert into abRowBufferSave_Test values (0)
	procedure append
		append blank in abRowBufferSave_Test
	procedure setBuffering(setBuffering)
		cursorsetprop("Buffering", evl(m.setBuffering, 1), 'abRowBufferSave_Test')
	procedure update(value)
		replace in abRowBufferSave_Test abRowBufferSave_Test with evl(m.value, 1)
	procedure skip(skip)
		skip evl(m.Skip, 1) in abRowBufferSave_Test
	function tablerevert(all)
		return tablerevert(m.all, 'abRowBufferSave_Test')
	function tableupdate(all)
		return tableupdate(m.all, .f., 'abRowBufferSave_Test')
	function recno
		return recno('abRowBufferSave_Test')
	function cFldState
		return iif(used('abRowBufferSave_Test') and cursorgetprop("Buffering", 'abRowBufferSave_Test') > 1;
			, getfldstate(-1, 'abRowBufferSave_Test');
			, .null.;
			)
	function value
		return abRowBufferSave_Test.abRowBufferSave_Test
	enddefine


* ========================================
function abRecno(tcAlias, tcError) && Sauve et rétablit Recno(<Alias>), USE <Alias> si nécessaire
return createobject('abRecno', m.tcAlias, @m.tcError)

* ========================================
define class abRecno as GA_LIGHTWEIGHT_CLASS && Sauve et rétablit Recno(<Alias>), USE <Alias> si nécessaire

hidden cAlias, iRecno

* -------------------------------
procedure init(tcAlias, tcError)

local llUsed, llResult

tcAlias = evl(m.tcAlias, alias())
llResult = used(m.tcAlias)
if not m.llResult

	tcAlias = cAlias(m.tcAlias, @m.llUsed,, @m.tcError)
	llResult = used(m.tcAlias)
endif

if m.llResult
	this.cAlias = m.tcAlias
	this.iRecno = iif(m.llUsed, .null., Recno_(m.tcAlias))
endif

return m.llResult

* -------------------------------
procedure destroy
if isnull(m.this.iRecno)
	use in (m.this.cAlias)
else
	return RecnoSet(m.this.iRecno, m.this.cAlias)
endif

enddefine && CLASS abRecno
* ========================================

* ========================================
procedure Recno_ && Recno() avec gestion de BOF()
lparameters tcAlias && [Alias()]
tcAlias = evl(m.tcAlias, alias())

if used(m.tcAlias)
	return iif(bof(m.tcAlias) or reccount(m.tcAlias) = 0, 0, recno(m.tcAlias))
else
	error 13, transform(m.tcAlias)
	return .null.
endif

* ========================================
procedure RecnoSet as Boolean && Place un alias sur un enregistrement déterminé avec Recno_()
lparameters ;
	tiRecno,; && n° d'enregistrement
	tcAlias,; && [Alias()]
	tcResult && @ Résultat (cumulatif)
tcAlias = evl(m.tcAlias, alias())

local llResult as Boolean;
, lcResult as string;
, lnResult as integer;

llResult = .t.;
 and vartype(m.tiRecno) == 'N';
 and int(m.tiRecno) = m.tiRecno; && integer
 and used(m.tcAlias)
lcResult = iif(m.llResult, '', textmerge(icase(;
		cLangUser() = 'fr',	[Paramètre(s) invalide(s): tiRecno=<<cLitteral(m.tiRecno)>>, tcAlias=<<cLitteral(m.tcAlias)>>],; && copy-paste this line to add another language support
												[Invalid Parameter(s): tiRecno=<<cLitteral(m.tiRecno)>>, tcAlias=<<cLitteral(m.tcAlias)>>]; && Default: English
	)))
if m.llResult

&& Précaution pour Alias en tampon d'enregistrement :
&& toujours tester si l'alias est dans la position recherchée avant de changer Recno()
&& pour éviter de valider le contenu du tampon

	lnResult = iif(.t.;
	 and lViewRemote(m.tcAlias);
	 and cursorgetprop("FetchAsNeeded", m.tcAlias);
	 and cursorgetprop("FetchSize", m.tcAlias) > 0;
		, cursorgetprop("RecordsFetched", m.tcAlias);
		, reccount(m.tcAlias);
	)

	do case

	case empty(m.lnResult) && added 04 Feb 2014

	case m.tiRecno < 0 and cursorgetprop("Buffering", m.tcAlias) < 4
		lcResult = textmerge(icase(;
				cLangUser() = 'fr',	[Alias '<<m.tcAlias>>' en tampon d'enregistrement non suppporté],; && copy-paste this line to add another language support
														[Alias '<<m.tcAlias>>' in buffering mode not supported]; && Default: English
			))
		llResult = .f.

	case between(m.tiRecno, 1, m.lnResult) or m.tiRecno < 0
		if not recno(m.tcAlias) = m.tiRecno
			go m.tiRecno in (m.tcAlias)
		endif

	case m.tiRecno = 0 && BOF()
		if not bof(m.tcAlias)
			go top in (m.tcAlias)
			if not bof(m.tcAlias)
				skip -1 in (m.tcAlias)
			endif
		endif

	otherwise && EOF()
		if !eof(m.tcAlias)
			go bottom in (m.tcAlias)
			if not eof(m.tcAlias)
				skip in (m.tcAlias)
			endif
		endif

	endcase
endif

assert m.llResult message cAssertMsg(m.lcResult)
cResultAdd(@m.tcResult, m.lcResult)

return m.llResult

* ========================================
procedure EOFset && place un Alias sur eof()
lparameters tcAlias
if ga_Type_IsChar(m.tcAlias) and used(m.tcAlias)
	go bottom in (m.tcAlias)
	if !eof(m.tcAlias)
		skip in (m.tcAlias)
	endif
	return eof(m.tcAlias)
endif
return .f.
endproc

* ========================================
function lBOF as Boolean && Un Alias est sur le premier enregistrement accessible
lparameters tcAlias && [Alias()]

local Result as Boolean;
, oRecno as abRecno of abData.prg;

do case
case !used(evl(m.tcAlias, alias()))
case bof(m.tcAlias)
	Result = .t.
case inlist(cursorgetprop("Buffering", m.tcAlias), 2, 3) and lBufferDirty(m.tcAlias) && tampon d'enregistrement, on ne peut pas modifier Recno()
	Result = .null.
otherwise
	oRecno = abRecno(m.tcAlias)
	skip -1 in (m.tcAlias)
	Result = bof(m.tcAlias)
endcase

return m.Result
endfunc

* ========================================
function lEOF as Boolean && Un Alias est sur le premier enregistrement accessible
lparameters tcAlias && [Alias()]

local Result as Boolean;
, oRecno as abRecno of abData.prg;

do case
case !used(evl(m.tcAlias, alias()))
case eof(m.tcAlias)
	Result = .t.
case inlist(cursorgetprop("Buffering", m.tcAlias), 2, 3) and lBufferDirty(m.tcAlias) && tampon d'enregistrement, on ne peut pas modifier Recno()
	Result = .null.
otherwise
	oRecno = abRecno(m.tcAlias)
	skip 1 in (m.tcAlias)
	Result = eof(m.tcAlias)
endcase

return m.Result
endfunc

* ========================================
function lRecMod && Un enregistrement d'un curseur tamponné a été modifié && à modifier pour tampon d'enregistrement
lparameters ;
	tcAlias,; && [courant] Alias à examiner
	tnRec && [courant] n° absolu de l'enregistrement a examiner
local lnRec, llRec, lcRec, lcFldState, llResult

tcAlias = iif(vartype(m.tcAlias) == 'C' and used(m.tcAlias), m.tcAlias, alias())
lnRec = nRecnoAbs(m.tcAlias)
tnRec = iif(vartype(m.tnRec) == 'N' and between(m.tnRec, 1, reccount(m.tcAlias)), m.tnRec, m.lnRec)
llResult = m.tnRec = m.lnRec or inlist(cursorgetprop("Buffering", m.tcAlias), 4, 5)
assert m.llResult message cAssertMsg(textmerge([l'alias <<m.tcAlias>> doit être en buffering de table]))
if m.llResult

	llRec = m.tnRec # m.lnRec
	if m.llRec
		go m.tnRec in (m.tcAlias)
	endif

	lcRec = getfldstate(-1, m.tcAlias)
	llResult = left(m.lcRec, 1) == '1'
	assert m.llResult message cAssertMsg(textmerge([l'enregistrement a été ajouté ; examen impossible]))
	if m.llResult

		#if .f.
			return value  Modification or deletion status
			1 field has not been modified or deletion status has not changed.
			2 field has been modified or deletion status has changed.
			3 field in an appended record has not been modified or deletion status has not changed for The appended record.
			4 field in an appended record has been modified or deletion status has changed for The appended record.
			.null. at eof( )
		#endif

		lcRec = substr(m.lcRec, 2) && ôter le premier caractère
		llResult = '2' $ m.lcRec or '4' $ m.lcRec
	endif

	if m.llRec
		go m.lnRec in (m.tcAlias)
	endif
endif

return m.llResult

* ==============================
function lDataSession(tiDS) && Une DataSession est ouverte

local liDS, llResult

liDS = set("Datasession")
try
	set datasession to m.tiDS
	llResult = .t.
catch
finally
	set datasession to m.liDS
endtry

return m.llResult

* ========================================
function cSQLSelectClause && Clause d'une instruction SELECT-SQL
lparameters ;
	tcSQLSelect,; && @ Instruction SELECT-SQL (@ nécessaire si m.tlDelete)
	tcClause,; && Clause à rechercher
	tlDelete && [.F.] Supprimer la clause de l'instruction
local laClauses[1], lnClause, lcResult
lcResult = ''

* Si l'instruction présumée contient des clauses
if aSQLSelectClauses(@m.laClauses, m.tcSQLSelect) > 0

	tcClause = cRepCharDel(m.tcClause)
	lnClause = ascan(laClauses, space(1) + upper(alltrim(m.tcClause)) + space(1), 1, -1, 1, 2+4+8)
	if m.lnClause > 0

		lcResult = laClauses[m.lnClause, 1] + laClauses[m.lnClause, 2]
		if lTrue(m.tlDelete)

			tcSQLSelect = strtran(m.tcSQLSelect, m.lcResult, '')
		endif
	endif
endif

return m.lcResult

* ---------------------
procedure cSQLSelectClause_Test && Teste cSQLSelectClause

local lcSQLSelect, loTest as abUnitTest of abDev.prg
text TO lcSQLSelect NOSHOW PRETEXT 15
	SELECT *, SUM(gg) AS SUM_GG FROM TableBidon
	WHERE xx = 1 AND yy = 'ff'
	GROUP BY 2, name, 4
	HAVING SUM_GG > 20
	ORDER BY NAME, CITY
	INTO ARRAY cc
ENDTEXT
loTest = newobject('abUnitTest', 'abDev.prg')

loTest.Test(' ORDER BY NAME, CITY', m.lcSQLSelect, 'ORDER  BY')

return loTest.Result()

* =================================
function aSQLparm as string && paramètres d'une instruction Select-SQL normalisée par _ga_StringParseBits_Class_.maskStrings()
&& créée pour faciliter les tests
&& see: modify class awfrm of aw.vcx method wViewSetup
lparameters ;
  aSQLparm as string; && @ out
, cSQL as string;

external array aSQLparm

local Result as integer;
, lnString as integer;
, lnParm as integer;
, liParm as integer;
, lcParm as string;
, lia as integer;

Result = occurs('?', m.cSQL)
if m.Result > 0

	cSQL = strtran(lower(m.cSQL), '->', '.')

	do while '? ' $ m.cSQL
		cSQL = strtran(m.cSQL, '? ', '?')
	enddo

	do while '. ' $ m.cSQL
		cSQL = strtran(m.cSQL, '. ', '.')
	enddo

	do while ' .' $ m.cSQL
		cSQL = strtran(m.cSQL, ' .', '.')
	enddo

	cSQL = '';
		+ strtran(chrtran(m.cSQL; && StrExtract(): If cEndDelim is an empty string STREXTRACT( ) returns a string from nOccurrence of cBeginDelim to the end of cSearchExpression
			, ' ', '~');
			, '?m.', '?');
		+ ')' && makes sure we find the parameter even at the end of the SQL string (see below)

	dimension aSQLparm[m.result]

	lia = 0
	for liParm = 1 to m.Result

		lcParm = substrc(;
			  m.cSQL;
			, at_c('?', m.cSQL, m.liParm) + 1; && right after '?' to the end of the string
			)

		lnString = lenc(m.lcParm) + 1

		lcParm = leftc(;
			  m.lcParm;
			, min(m.lnString;
				, evl(at_c('~', m.lcParm), m.lnString); && space
				, evl(at_c(')', m.lcParm), m.lnString); && end of group | parameter list | string
				, evl(at_c(']', m.lcParm), m.lnString); && end of group | parameter list | string
				, evl(at_c(',', m.lcParm), m.lnString); && next parameter in list
				, evl(at_c('+', m.lcParm), m.lnString); && general operator
				, evl(at_c('-', m.lcParm), m.lnString); && general operator
				, evl(at_c('$', m.lcParm), m.lnString); && string operator
				, evl(at_c('>', m.lcParm), m.lnString); && relational operator
				, evl(at_c('<', m.lcParm), m.lnString); && relational operator
				, evl(at_c('=', m.lcParm), m.lnString); && relational operator
				, evl(at_c('#', m.lcParm), m.lnString); && relational operator
				, evl(at_c('!', m.lcParm), m.lnString); && relational operator (!=)
				, evl(at_c('*', m.lcParm), m.lnString); && numeric operator
				, evl(at_c('/', m.lcParm), m.lnString); && numeric operator
				, evl(at_c('%', m.lcParm), m.lnString); && numeric operator
				, evl(at_c('^', m.lcParm), m.lnString); && numeric operator
				, evl(at_c('.and.', m.lcParm), m.lnString); && logical operator
				, evl(at_c('.or.',  m.lcParm), m.lnString); && logical operator
				) - 1;
			)

		if ascan(m.aSQLparm, m.lcParm, 1, -1, 1, 6) > 0
			Result = m.Result - 1
		else
			lia = m.lia + 1
			aSQLparm[m.lia] = m.lcParm
		endif
	endfor

	dimension m.aSQLparm[m.result]
endif

return m.Result
endfunc

* ----------------------
procedure aSQLparm_Test && Test unitaire de aSQLparm()

local loTest as abUnitTest of abDev.prg;
, laParm[1] as string;
, lcSQL as string;

loTest = newobject('abUnitTest', 'abDev.prg')

loTest.Test(4;
	, @m.laParm;
	, 'select someField from someTable where someKey = ? thisForm.someProperty and someKey like ? m.someVariable.or.inlist(?m.someVariable, 1,2).or.isnull(?alias.Field) and somefield like ?thisform.pgf.pag.txt.Value'; && string literal in where clause not supported!
	)
loTest.assert(lower('thisForm.someProperty'), m.laParm[1])
loTest.assert(lower('someVariable'), m.laParm[2])
loTest.assert(lower('alias.Field'), m.laParm[3])
loTest.assert(lower('thisform.pgf.pag.txt.Value'), m.laParm[4])

return loTest.Result()
endproc

* ========================================
function uSQLparmValueDefault && Valeur par défaut d'un paramètre d'une instruction SQL-select selon son opérateur
lparameters ;
  lcSQLSelect; && instruction SQL-select obtenue par CursorGetProp("SQL"), sur une seule ligne
, liParm; && index du paramètre

#if .f.
FieldName Comparison expression | all (Subquery) | any (Subquery) | some (Subquery)
-or-
FieldName [NOT] like cExpression | is [NOT] null | [NOT] between Start_Range.and.End_Range | [NOT] in Value_Set
#endif

local Result as string;
, I as integer;
, C as string;
, lDot as Boolean;
, lWord as Boolean;

Result = ''

for I = at_c('?', m.lcSQLSelect, m.liParm) - 1 to 1 step -1

	C = upper(substrc(m.lcSQLSelect, m.I, 1))
	do case

	case m.C $ VFPOPCARS + ',' && opérateur ou séparateur
		exit

	case m.C == '.'
		if m.lDot and m.lWord && second point, .AND. par exemple
			exit
		endif
		lDot = .t.

	case m.C $ ' ()'
		if m.lWord
			exit
		endif

	otherwise
		lWord = .t.
		Result = m.C + m.Result

	endcase
endfor

return icase(;
	upper(alltrim(m.Result)) == 'LIKE',;
		'A junk FoxInCloud string _value_ that *for sure* no view parameter will ever match',;
		.null.;
	)
endfunc

* ========================================
function aSQLSelectClauses && Clauses d'une instruction SELECT-SQL && d'après une fonction d'Anders Altberg http://www.foxite.com/archives/extract-a-clause-from-sql-0000195322.htm
lparameters ;
	taClauses,; && @ Clauses en retour [Clause, argument, position début]
	tcSQLSelect && Instruction SELECT-SQL
external array taClauses
local lcSQLSelect, lnClause, lcClause, lcDelim1, lcDelim2, lnResult && Nombre de clauses
lnResult = 0
if type('taClauses', 1) == 'A' and vartype(m.tcSQLSelect) == 'C'

* Tabuler les clauses dans leur ordre d'occurence dans l'instruction
	lnResult = alines(taClauses, ' WHERE , ORDER BY , GROUP BY , HAVING , INTO ', 0, ',')
	aColsIns(@m.taClauses, 1, 2)
	lcSQLSelect = upper(m.tcSQLSelect)
	for lnClause = m.lnResult to 1 step -1
		taClauses(m.lnClause, 3) = atc(taClauses(m.lnClause, 1), m.lcSQLSelect)
		if taClauses(m.lnClause, 3) = 0
			lnResult = m.lnResult - 1
			adel(taClauses, m.lnClause)
		endif
	next
	if m.lnResult > 0

		dimension taClauses[m.lnResult, 3]
		asort(taClauses,3)

* Pour chaque clause, extraire ses arguments
		for lnClause = 1 to m.lnResult
			lcDelim1 = taClauses(m.lnClause, 1)
			lcDelim2 = iif(m.lnClause < m.lnResult, taClauses(m.lnClause+1, 1), '')
			taClauses(m.lnClause,2) = strextract(m.tcSQLSelect, m.lcDelim1, m.lcDelim2, 1, 3)
		next
	endif
endif

return m.lnResult

* ---------------------
procedure aSQLSelectClauses_Test && Teste aSQLSelectClauses

local lcSQLSelect, laClauses[1], loTest as abUnitTest of abDev.prg

text TO lcSQLSelect NOSHOW PRETEXT 15
	SELECT *, SUM(gg) AS SUM_GG FROM TableBidon
	WHERE xx = 1 AND yy = 'ff'
	GROUP BY 2, name, 4
	HAVING SUM_GG > 20
	ORDER BY NAME, CITY
	INTO ARRAY cc
ENDTEXT
loTest = newobject('abUnitTest', 'abDev.prg')

loTest.Test(5, @m.laClauses, m.lcSQLSelect)
loTest.assert('2, name, 4', laClauses[2, 2])
loTest.assert('ARRAY cc', laClauses[5, 2])

return loTest.Result()

* ---------------------
procedure lTableStruIdem && Deux tables ont une structure et des indexes identiques
lparameters ;
	tcTable1,;
	tcTable2,;
	tcResult && @ résultat

local lcAlias1, lcAlias2, llAlias1, llAlias2;
, laField1[1], laField2[1];
, laTag1[1], laTag2[1];
, laDelta[1];
, llResult_, llResult && résultat

lcAlias1 = cAlias(m.tcTable1, @m.llAlias1)
lcAlias2 = cAlias(m.tcTable2, @m.llAlias2)

llResult = used(m.lcAlias1) and used(m.lcAlias2)
if m.llResult

	llResult_ = afields(m.laField1, m.lcAlias1) = afields(m.laField2, m.lcAlias2)
	= not m.llResult_ and cResultAdd(@m.tcResult, textmerge([Nombres de champs différents : <<ALEN(m.laField1, 1)>> / <<ALEN(m.laField1, 2)>>]))
	llResult = m.llResult and m.llResult_

	aColsDel(@m.laField1, 6)
	aColsDel(@m.laField2, 6)
	asort(m.laField1)
	asort(m.laField2)
	llResult_ = laEqual(@m.laField1, @m.laField2,, @m.laDelta)
	= not m.llResult_ and cResultAdd(@m.tcResult, [Définitions de champs différentes : ] + cListOfArray(@m.laDelta,,-1))
	llResult = m.llResult and m.llResult_

	llResult_ = aTagInfoEn(@m.laTag1, forceext(m.tcTable1, 'cdx'), m.lcAlias1) = aTagInfoEn(@m.laTag2, forceext(m.tcTable2, 'cdx'), m.lcAlias2)
	= not m.llResult_ and cResultAdd(@m.tcResult, textmerge([Nombres d'indexes différents : <<ALEN(m.laTag1, 1)>> / <<ALEN(m.laTag2, 1)>>]))
	llResult = m.llResult and m.llResult_

	asort(m.laTag1)
	asort(m.laTag2)
	llResult_ = laEqual(@m.laTag1, @m.laTag2,, @m.laDelta)
	= not m.llResult_ and cResultAdd(@tcResult, [Définitions d'indexes différentes : ] + cListOfArray(@m.laDelta,,-1))
	llResult = m.llResult and m.llResult_

else
	cResultAdd(@m.tcResult, 'Table(s) introuvable(s)')
endif

if m.llAlias1
	use in (m.lcAlias1)
endif
if m.llAlias2
	use in (m.lcAlias2)
endif

return m.llResult

* ---------------------
function Used_ && Un Alias d'une liste est Used()
lparameters tcAliases

local laAlias[1], lcAlias, llResult

if alines(laAlias, m.tcAliases, 5, ',', ';') > 0
	for each lcAlias in laAlias
		llResult = used(m.lcAlias)
		if not m.llResult
			exit
		endif
	endfor
endif

return m.llResult

* ========================================
define class abDataSyncVFP as custom && Synchronise deux tables ou deux bases de données VFP && as custom pour .addObject()
* ========================================

* RÉGLAGES
	cTimeStampField = 'tMOD' && clé & champ date et heure de dernière modification d'une table ; pris en compte dans le réglage de plSync && 'tMOD' est le standard FoxInCloud
	clSyncField = 'lSYNC' && champ 'enregistrement modifié par synchronisation' normalement présent dans chaque table && 'lSYNC' est le standard FoxInCloud
	lTypesForce = .f. && Forcer les types des champs de la table source vers ceux de la table destination
	lSyncDeleted = .t. && Synchroniser les enregistrements deletés
	lModCheck = .f. && Vérifier que les données ont changé avant de remplacer && évite une mise à jour inutile de la date de modification

	lDebug = .f. && Enrichir les messages d'erreur
	cErrorHeader = '/!\' && en-tête ajouté au résultat en cas d'erreur

	cDBCdest = '' && Adresse de la base de données destination
	cDBCsrce = '' && Adresse de la base de données source
&& les base de données source et destination peuvent porter le même nom ... l'adresse est nécessaire
	cTablesIgnore = '' && tables à ignorer (cf. this.DBCSync())

* RÉSULTATS EN LECTURE SEULE
	lResult = .t. && Succès / Échec
	cResult = '' && Texte résultat
	oResult = .null. && Objet résultat (par table)
	dimension aResults[1]; && Objets résultats (tables)
		, aResultItems[1] && éléments de l'objet résultat : cf. this.Init_aResultItems()
	cResultCursor = '' && Curseur résultats

* INTERNES
	protected lErrorFatal, aDBCdestTables[1], cLangUser

*---------------------------------------
	procedure init
	lparameters ;
	  Result; && @
	, cLangUser && [cLangUser()]

	local llResult;
	, lnResultItem;
	, lcResultItems

	this.cLangUser = cLangUser(m.cLangUser)

* Tabuler les éléments l'objet résultat
	llResult = .t.;
		and dodefault();
		and this.Init_aResultItems()
	if m.llResult

* Créer l'objet résultat
		this.oResult = createobject('empty') && Résultat d'exécution sous forme d'objet
		for lnResultItem = 1 to alen(this.aResultItems, 1)
			addproperty(m.this.oResult, this.aResultItems[m.lnResultItem, 1], this.aResultItems[m.lnResultItem, 2])
		endfor

* Créer le curseur résultats (qui contiendra un objet résultat par table)
		lcResultItems = ''
		this.cResultCursor = textmerge([<<m.this.name>>_<<Ttoc(Datetime(),1)>>])
		for lnResultItem = 1 to alen(this.aResultItems, 1)
			lcResultItems = c2Words(m.lcResultItems, ',', textmerge("<<this.aResultItems[m.lnResultItem, 1]>> <<this.aResultItems[m.lnResultItem, 3]>>"))
		endfor
		addproperty(m.this, 'abSelect', abSelect())
		create cursor (m.this.cResultCursor) (&lcResultItems)

		this.cDBCsrce = m.this.cDBCsrce && see this.cDBCsrce_Assign()
		this.cDBCdest = m.this.cDBCdest && see this.cDBCdest_Assign()
	endif

	return m.llResult

*---------------------------------------
	hidden function Init_aResultItems && 1-Nom | 2-Valeur par défaut | 3-Type de champ | 4 Description localisée

	local llResult;
	, lcResultItem;
	, lnResultItem;
	, laResultItem[1];
	, liResultItem;
	, laLang[1];
	, liLangUser;
	, llLangUser;

&& /!\ la Description ne doit pas contenir '|'
	text TO lcResultItem NOSHOW FLAGS 1 PRETEXT 1+2 && Field | default value | Type | en | fr | de | es | it | pt
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
	if alines(laLang, 'en | fr | de | es | it | pt', 5, '|') > 0
		liLangUser = ascan(laLang, m.this.cLangUser, 1, -1, 1, 7)
		liLangUser = iif(m.liLangUser > alen(m.laResultItem, 2)- 3;
			, m.liLangUser;
			, 0;
			)
	endif

	llLangUser = m.liLangUser > 0

	for liResultItem = 1 to m.lnResultItem
		laResultItem[m.liResultItem, 1] = alltrim(m.laResultItem[m.liResultItem, 1])
		laResultItem[m.liResultItem, 2] = evaluate(alltrim(m.laResultItem[m.liResultItem, 2])) && valeur par défaut
		laResultItem[m.liResultItem, 3] = alltrim(m.laResultItem[m.liResultItem, 3])
		laResultItem[m.liResultItem, 4] = alltrim(iif(m.llLangUser;
			, evl(laResultItem[m.liResultItem, m.liLangUser], laResultItem[m.liResultItem, 4]);
			, laResultItem[m.liResultItem, 4];
			))
	endfor

	aColsDel(@m.laResultItem, 5)

	dimension this.aResultItems[m.lnResultItem, 4]
	acopy(m.laResultItem, this.aResultItems)

*---------------------------------------
	protected procedure destroy

	use in select(m.this.cResultCursor)

*---------------------------------------
	protected procedure ResultClear && Raze l'objet résultat

	this.cErrorHeader = alltrim(evl(m.this.cErrorHeader, '/!\'))

	this.lResult = .t.
	this.cResult = ''

	local liResultItem
	for liResultItem = 1 to alen(this.aResultItems, 1)
		store this.aResultItems[m.liResultItem, 2] to ('m.this.oResult.' + this.aResultItems[m.liResultItem, 1])
	endfor

*---------------------------------------
	protected procedure cResult_Assign
	lparameters tcResult

	tcResult = iif(ga_Type_IsChar(m.tcResult), m.tcResult, '?')

	if m.this.lResult
		this.cResult = m.tcResult
	else
		this.cResult = c2Words(;
			  m.this.cResult;
			, CRLF;
			, textmerge([<<m.this.cErrorHeader>> <<Lower(Program(Program(-1)-1))>> - <<Alltrim(m.tcResult)>>]);
			)
	endif

*---------------------------------------
	protected procedure cResultAdd
	lparameters tcResult

	local llResult

	llResult = m.this.lResult
	this.lResult = .f.
	this.cResult = m.tcResult
	this.lResult = m.llResult

*---------------------------------------
	protected procedure oResultFinal && Objet résultat final
	this.oResult.lResult = m.this.lResult
	this.oResult.cResult = m.this.cResult
	return m.this.oResult

*---------------------------------------
	procedure cResultFinal && résultat final
	lparameters ;
	  tlSuccess; && [.F.] en cas de succès, seulement le résultat
	, tlPipe && [.F.] séparer les éléments par '|'

	tlPipe = iif(lTrue(m.tlPipe), ' | ', CRLF)

	this.oResultFinal

	local lcResult, liResultItem, luResultItem

	lcResult = ''
	for liResultItem = 1 to iif(lTrue(m.tlSuccess) and m.this.oResult.lResult;
	 , 2;
	 , alen(this.aResultItems, 1);
	 )

		luResultItem = evaluate('m.this.oResult.' + this.aResultItems[m.liResultItem, 1])

		lcResult = m.lcResult;
			+ m.tlPipe;
			+ this.aResultItems[m.liResultItem, 4] + ': ';
			+ cTronc(transform(m.luResultItem), 3000, .t.) && cCRLFfix()

	endfor

	this.ResultClear

	return substr(m.lcResult, len(m.tlPipe) + 1)

*---------------------------------------
	hidden procedure cDBCdest_Assign
	lparameters tcDBC && nom | adresse de la base de données destination

	this.oResult.lDBCdest = this.lDBC(@m.tcDBC)

	if .t.;
	 and m.this.oResult.lDBCdest;
	 and (not luEqual(m.this.cDBCdest, m.tcDBC) or lCallingModule('Init'))

* Nouvelle base de données : tabuler les tables
		local array laTables[1]
		this.oResult.lDBCdest = ga_DBCTablesTree(@m.laTables, m.tcDBC) > 0 && aDBCTablesTree(@m.laTables, m.tcDBC) > 0
		if this.oResult.lDBCdest

			dimension this.aDBCdestTables[Alen(m.laTables)]
			acopy(laTables, m.this.aDBCdestTables)

			this.cDBCdest = m.tcDBC
		else
			this.cResult = textmerge(icase(;
				m.this.cLangUser = 'fr',	[Aucune table trouvée dans la base de données :],; && copy-paste this line to add another language support
																	[No table was found in the database:]; && Default: English"
				) + [ '<<m.tcDBC>>'])
		endif
	endif

	this.lResult = m.this.lResult and this.oResult.lDBCdest

*---------------------------------------
	hidden procedure cDBCsrce_Assign
	lparameters tcDBC && nom | adresse de la base de données source

	this.oResult.lDBCsrce = this.lDBC(@m.tcDBC)
	if m.this.oResult.lDBCsrce

		this.cDBCsrce = m.tcDBC
	endif

	this.lResult = m.this.lResult and this.oResult.lDBCsrce

*---------------------------------------
	hidden procedure lDBC as Boolean
	lparameters tcDBC && @ nom | adresse de la base de données

	local llResult

	do case

	case empty(m.tcDBC)
		llResult = .null.

	case !ga_Type_IsChar(m.tcDBC)
		this.cResult = textmerge(icase(;
				m.this.cLangUser = 'fr',	[Spécification de base de données invalide : <<cLitteral(m.tcDBC)>>],; && copy-paste this line to add another language support
																	[Database specification is invalid: <<cLitteral(m.tcDBC)>>]; && Default: English
				))

	case !VarStore(@m.tcDBC, forceext(m.tcDBC, 'dbc'))
		this.cResult = icase(;
				m.this.cLangUser = 'fr',	[Erreur inattendue],; && copy-paste this line to add another language support
																	[Unexpected error]; && Default: English
				)

	case !file(m.tcDBC)
		this.cResult = textmerge(icase(;
				m.this.cLangUser = 'fr',	[Base de données introuvable : <<cLitteral(m.tcDBC)>>],; && copy-paste this line to add another language support
																	[This database can't be found: <<cLitteral(m.tcDBC)>>]; && Default: English
				))

	otherwise
		tcDBC = fullpath(m.tcDBC)
		open database (m.tcDBC)
		llResult = .t.

	endcase

	assert nvl(m.llResult, .t.) message m.this.cResult

	return m.llResult

*---------------------------------------
	protected function aTablesIgnore && Tables à ignorer
	lparameters ;
		taTablesIgnore,; && @ Tables à ignorer
		tcTablesIgnore && Tables à ignorer
	external array taTablesIgnore

	tcTablesIgnore = iif(vartype(m.tcTablesIgnore) == 'C', m.tcTablesIgnore, '')
	this.cTablesIgnore = iif(vartype(m.this.cTablesIgnore) == 'C', m.this.cTablesIgnore, '')
	tcTablesIgnore = upper(c2Words(m.tcTablesIgnore, ',', m.this.cTablesIgnore))

	return alines(taTablesIgnore, m.tcTablesIgnore, 1, ',', ';') && peu importent les doublons !

*---------------------------------------
	procedure DBCSync && Synchronise deux bases de données VFP
	lparameters ;
		tcDBCdest,; && [this.cDBCdest] Adresse de la base de données destination
		tcDBCsrce,; && [this.cDBCsrce] Adresse de la base de données source
		tcTablesIgnore,; && [this.cTablesIgnore] Tables à ignorer
		tuFieldsIgnore,; && ['WARNING'] Ignorer si ces champs de la table destination sont absents de la table source ; .T.: aucune vérification de structure
		tlReplace,; && [.F.] Remplacer toute la table destination
		tlCKmatch && [.F.] Matcher les enregistrements sur la première clé candidate de la table destination

	this.ResultClear
	this.cDBCdest = evl(m.tcDBCdest, m.this.cDBCdest) && cf. this.cDBCdest_assign()
	this.cDBCsrce = evl(m.tcDBCsrce, m.this.cDBCsrce) && cf. this.cDBCsrce_assign()
	if m.this.lResult

		local laTablesIgnore[1], lnTables, lnTable, lcTable, llTable;
		, luFieldsIgnore, llReplace, llCandMatch;
		, liResultItem, lcResultItem, lcResult, llResult

* Tabuler les tables à ignorer
		this.aTablesIgnore(@m.laTablesIgnore, m.tcTablesIgnore)

* Pour chaque table destination
		lnTables = alen(m.this.aDBCdestTables)
		dimension this.aResults[m.lnTables]
		lcResult = ''
		for m.lnTable = 1 to m.lnTables

			lcTable = this.aDBCdestTables[m.lnTable]
			this.ResultClear

* Si la table n'est pas à ignorer
			if ascan(laTablesIgnore, m.lcTable,1,-1,1,7) = 0

* Si la table est à traiter
				luFieldsIgnore = m.tuFieldsIgnore
				llReplace = m.tlReplace
				llCandMatch = m.tlCKmatch
				if this.DBCSync_Table_Ante(m.lcTable, @m.luFieldsIgnore, @m.llReplace, @m.llCandMatch)

* Si les tables peuvent être synchronisées
					llTable = this.TableSync(;
						  textmerge([<<this.cDBCdest>>!<<m.lcTable>>]);
						, textmerge([<<this.cDBCsrce>>!<<m.lcTable>>]);
						, m.luFieldsIgnore;
						, m.llReplace;
						, m.llCandMatch;
						)

					this.oResult.lResult = m.llTable

* Exécuter la méthode shell
					llTable = this.DBCSync_Table_Post(m.lcTable, m.this.oResultFinal())
				else
					this.cResult = textmerge(icase(;
						m.this.cLangUser = 'fr',	[La table '<<m.lcTable>>' n'a pas été synchronisée sur ordre de <<m.this.Name>>.DBCSync_Table_Ante()],; && copy-paste this line to add another language support
																			[<<m.this.Name>>.DBCSync_Table_Ante() ordered not to synchronize  '<<m.lcTable>>']; && Default: English
						))
				endif
			else
				this.cResult = textmerge(icase(;
					m.this.cLangUser = 'fr',	[La table '<<m.lcTable>>' a été ignorée conformément à la liste '<<m.tcTablesIgnore>>'],; && copy-paste this line to add another language support
																		[Table '<<m.lcTable>>' was ignored as of list '<<m.tcTablesIgnore>>']; && Default: English
					))
			endif
			this.oResult.lResult = m.llTable

* Enregistrer le résultat pour la table
			this.aResults[m.lnTable] = createobject('empty') && Résultat d'exécution sous forme d'objet
			for liResultItem = 1 to alen(this.aResultItems, 1)
				lcResultItem = this.aResultItems[m.liResultItem, 1]
				addproperty(this.aResults[m.lnTable], m.lcResultItem, evaluate('this.oResult.' + m.lcResultItem))
			endfor

			llResult = m.llResult and m.llTable
			lcResult = c2Words(m.lcResult, CRLF, m.this.cResult)

* Si erreur fatale, terminé
			if m.this.lErrorFatal
				exit
			endif
		endfor

* Enregistrer le résultat final
		this.cResult = m.lcResult
		this.lResult = m.llResult
	endif

	return m.this.lResult

*---------------------------------------
	protected procedure DBCSync_Table_Ante && méthode shell avant synchronisation
	lparameters ;
		tcTable,; && Table sur le point d'être synchronisée
		tuFieldsIgnore,; && @ Ignorer si ces champs de la table destination sont absents de la table source ; .T.: aucune vérification de structure
		tlReplace,; && @ Remplacer toute la table destination
		tlCKmatch && @ Matcher les enregistrements sur la première clé candidate de la table destination

*---------------------------------------
	protected procedure DBCSync_Table_Post && méthode shell après synchronisation
	lparameters ;
		tcTable,; && Table qui vient d'être synchronisée
		toResult && Résultat de la synchronisation

	local llResult
	llResult = dodefault(m.tcTable, m.toResult)
	if m.llResult

* Si le curseur résultat est ouvert
		llResult = used(m.this.cResultCursor)
		assert m.llResult message cAssertMsg(textmerge(icase(;
			m.this.cLangUser = 'fr',	[Le curseur résultat '<<m.this.cResultCursor>>' a été refermé par erreur],; && copy-paste this line to add another language support
																[Result Cursor '<<m.this.cResultCursor>>' was mistakenly closed]; && Default: English
			)))
		if m.llResult

* Ajouter un enregistrement résultat
			local loSelect
			loSelect = abSelect(m.this.cResultCursor)
			append blank
			gather name m.toResult memo
		endif
	endif

	return m.llResult

*---------------------------------------
	procedure TableSync && Synchronise deux tables VFP
	lparameters ;
		tcTableDest,; && Table destination (Adresse || Alias || db!Table)
		tcTableSrce,; && Table source  (Adresse || Alias || db!Table)
		tuFieldsIgnore,; && ['WARNING'] Ignorer si ces champs de la table destination sont absents de la table source ; .T.: aucune vérification de structure
		tlReplace,; && [.F.] Remplacer toute la table destination
		tlCKmatch,; && [.F.] Matcher les enregistrements sur la première clé candidate de la table destination
		tnRecs && [all] Nombre d'enregistrements à synchroniser

	this.ResultClear

	local loSelect as abSelect of abData.prg;
	, lcAliasSrce, llAliasSrce;
	, lcAliasDest, llAliasDest;
	, loException as exception

	loSelect = abSelect()

	this.oResult.cTableDest = cTableComment(m.tcTableDest)
	this.oResult.cTableSrce = cTableComment(m.tcTableSrce)

* Si la table destination peut être ouverte && en premier pour l'aliaser sous son nom
	lcAliasDest = cAlias(m.tcTableDest, @m.llAliasDest)
	this.oResult.lTableDest = used(m.lcAliasDest)
	this.lResult = this.oResult.lTableDest
	if m.this.lResult

* Si la table source peut être ouverte
		lcAliasSrce = cAlias(m.tcTableSrce, @m.llAliasSrce)
		this.oResult.lTableSrce = used(m.lcAliasSrce)
		this.lResult = this.oResult.lTableSrce
		if m.this.lResult

			this.oResult.nRecsSrce = reccount(m.lcAliasSrce)

* Si le champs de la Table source sont tous dans la Table destination et réciproquement
			this.lResult = .f.;
			 or lTrue(m.tuFieldsIgnore) ;
			 or this.lFieldsMatch(m.lcAliasDest, m.lcAliasSrce, uDefault(m.tuFieldsIgnore, 'WARNING'))
			if m.this.lResult

				try

* Réaliser la sychronisation
					this.lResult = this.TableSync_(;
						  m.lcAliasDest;
						, m.lcAliasSrce;
						, m.tlReplace;
						, m.tlCKmatch;
						, m.tnRecs;
						)

				catch to loException
					this.lResult = .f.
					this.cResult = cException(m.loException)
					this.oResult.cException = m.this.cResult
				endtry
			else
* Traité par this.lFieldsMatch()
			endif
		else
			this.cResult = textmerge(icase(;
				m.this.cLangUser = 'fr',	[Impossible d'ouvrir la table source <<cLitteral(m.tcTableSrce)>>],; && copy-paste this line to add another language support
																	[Could not open source table <<cLitteral(m.tcTableSrce)>>]; && Default: English
				))
		endif
	else
		this.cResult = textmerge(icase(;
			m.this.cLangUser = 'fr',	[Impossible d'ouvrir la table destination <<cLitteral(m.tcTableDest)>>],; && copy-paste this line to add another language support
																[Could not open destination table <<cLitteral(m.tcTableDest)>>]; && Default: English
			))
	endif

	assert m.this.lResult message m.this.cResult

	if m.llAliasDest && après assert pour voir le contenu des tables
		use in select(m.lcAliasDest)
	endif
	if m.llAliasSrce
		use in select(m.lcAliasSrce)
	endif

	return m.this.lResult

*---------------------------------------
	hidden function lFieldsMatch && Les champs des tables source et destination sont cohérents
	lparameters ;
		tcAliasDest,; && Alias de la table destination
		tcAliasSrce,; && Alias de la table source
		tcFieldsIgnore && Champs à ignorer

	local llFieldsSrce, llFieldsDest

	this.oResult.cFieldsMissingSrce = nvl(cFieldsNotIn(m.tcAliasDest, m.tcAliasSrce, m.tcFieldsIgnore), '?')
	llFieldsSrce = empty(m.this.oResult.cFieldsMissingSrce)

	this.oResult.cFieldsMissingDest = nvl(cFieldsNotIn(m.tcAliasSrce, m.tcAliasDest, m.tcFieldsIgnore), '?')
	llFieldsDest = .t. && Empty(m.this.oResult.cFieldsMissingDest)

	this.lResult = m.llFieldsDest and m.llFieldsSrce

	if not m.this.lResult

		local lcTableSrce, lcTableDest
		lcTableSrce = displaypath(cTableAddress(m.tcAliasSrce), 50)
		lcTableDest = displaypath(cTableAddress(m.tcAliasDest), 50)

		this.cResult = c2Words(;
			  iif(m.llFieldsSrce;
				, '';
				, textmerge(icase(;
					m.this.cLangUser = 'fr',	[La table destination '<<m.lcTableDest>>' comporte au moins un champ manquant dans la table source '<<m.lcTableSrce>>' : <<cLitteral(m.this.oResult.cFieldsMissingSrce)>>],; && copy-paste this line to add another language support
																		[Destination table '<<m.lcTableDest>>' holds at least one field missing in source table '<<m.lcTableSrce>>': <<cLitteral(m.this.oResult.cFieldsMissingSrce)>>]; && Default: English
					));
				);
			, CRLF;
			, iif(m.llFieldsDest;
				, '';
				, textmerge(icase(;
					m.this.cLangUser = 'fr',	[La table source '<<m.lcTableSrce>>' comporte au moins un champ manquant dans la table destination '<<m.lcTableDest>>' : <<cLitteral(m.this.oResult.cFieldsMissingDest)>>],; && copy-paste this line to add another language support
																		[Source table '<<m.lcTableSrce>>' holds at least one field missing in destination table '<<m.lcTableDest>>': <<cLitteral(m.this.oResult.cFieldsMissingDest)>>]; && Default: English
					));
				);
			)
	endif

	return m.this.lResult

*---------------------------------------
	protected procedure TableSync_ && Réalise la synchronisation des tables
	lparameters ;
		tcAliasDest,; && Alias de la table destination
		tcAliasSrce,; && Alias de la table source
		tlReplace,; && [.F.] Remplacer toute la table destination
		tlCKmatch,; && [.F.] Matcher les enregistrements sur la première clé candidate de la table destination
		tnRecs && [all] Nombre d'enregistrements à synchroniser
	tlReplace = lTrue(m.tlReplace)
	tlCKmatch = lTrue(m.tlCKmatch)
	tnRecs = iif(vartype(m.tnRecs) == 'N' and m.tnRecs > 0, int(m.tnRecs), 0)

* Si la table destination a une clé unique (primaire ou candidate)
	local llCtag, lcPCtag, lcPCexp, lcPCexpMem;
	, llPtag, lcPtag, lcPexp, lcPexpMem, lcPexpDest, lcPCmsg

	llCtag = m.tlCKmatch
	lcPCtag = cTagPC(m.tcAliasDest, @m.lcPCexp, @m.llCtag)
	this.oResult.lPCtag = not empty(m.lcPCtag) and lTableExpr(m.lcPCexp, m.tcAliasSrce)
	if this.oResult.lPCtag

* Calculer l'expression mémoire de la clé
		lcPCexpMem = cExprFieldsPrefixed(m.lcPCexp, m.tcAliasDest, 'm') && expression de recherche de l'enr. à mettre à jour (en mémoire)

* Si la clé est candidate et la table destination a une clé primaire valable sur la table source
		llPtag = not m.llCtag
		if m.llPtag
			lcPtag = m.lcPCtag
			lcPexp = m.lcPCexp
			lcPexpMem = m.lcPCexpMem
		else
			lcPtag = cTagP(m.tcAliasDest, @m.lcPexp)
			llPtag = not empty(m.lcPtag) and lTableExpr(m.lcPexp, m.tcAliasSrce)
			if m.llPtag
				lcPexpMem = cExprFieldsPrefixed(m.lcPexp, m.tcAliasDest, 'm')
				lcPexpDest = cExprFieldsPrefixed(m.lcPexp, m.tcAliasDest, m.tcAliasDest)
			endif
		endif

* Définir si les enr. sont comparés sur clé candidate
		this.oResult.lcTag = not m.llPtag or m.tlCKmatch && les enregistrements sont comparés selon un index candidat
		this.oResult.cPCtag = iif(m.this.oResult.lcTag, m.lcPCtag, m.lcPtag) && nom de l'index primaire ou candidat de la table destination
		this.oResult.cPCexp = iif(m.this.oResult.lcTag, m.lcPCexp, m.lcPexp) && expression de l'index primaire ou candidat de la table destination
		lcPCmsg = textmerge([];
			+ icase(;
				m.this.cLangUser = 'fr',	[ajout ou remplacement d'enregistrement(s) selon la clé <<Iif(this.oResult.lCtag, 'candidate', 'primaire')>> '<<m.this.oResult.cPCtag>>' (<<m.this.oResult.cPCexp>>)],; && copy-paste this line to add another language support
																	[adding or replacing records based on <<Iif(this.oResult.lCtag, 'candidate', 'primary')>> key '<<m.this.oResult.cPCtag>>' (<<m.this.oResult.cPCexp>>)]; && Default: English
				);
			+ iif(m.this.oResult.lcTag and m.llPtag;
				, icase(;
					m.this.cLangUser = 'fr',	[ et la clé primaire '<<m.lcPtag>>' (<<m.lcPexp>>)],; && copy-paste this line to add another language support
																		[ and primary key '<<m.lcPtag>>' (<<m.lcPexp>>)]; && Default: English
					);
				, '';
				);
			)


* Sinon (la table destination n'a pas de clé unique)
	else
		if m.tlCKmatch
			this.lResult = .f.
			lcPCmsg = icase(;
				m.this.cLangUser = 'fr',	[synchronisation abandonnée : une clé candidate est exigée mais aucune n'est commune à la table source et destination],; && copy-paste this line to add another language support
																	[synchronisation canceled: a candidate key is required but source and destination tables don't share any]; && Default: English
				)
		else
			lcPCmsg = icase(;
				m.this.cLangUser = 'fr',	[ajout seul (aucune clé primaire ou candidate commune à la table source et destination)],; && copy-paste this line to add another language support
																	[adding records only (source and destination tables share no primary or candidate key)]; && Default: English
				)
		endif
	endif
	lcPCmsg = iif(m.this.lResult and m.tlReplace, 'vidée puis ', '') + m.lcPCmsg
	this.cResult = textmerge(icase(;
		m.this.cLangUser = 'fr',	[Table destination : '<<Dbf(m.tcAliasDest)>>' - <<m.lcPCmsg>>],; && copy-paste this line to add another language support
															[Destination table: '<<Dbf(m.tcAliasDest)>>' - <<m.lcPCmsg>>]; && Default: English
		))
	if m.this.lResult

* Si la table destination doit et peut être remplacée (vidée avant synchronisation)
		if m.tlReplace
			tcAliasDest = ExclusiveForce(m.tcAliasDest)
			this.lResult = used(m.tcAliasDest)
			if m.this.lResult and reccount(m.tcAliasDest) > 0
				zap in (m.tcAliasDest)
			endif
			this.oResult.lDestExclusive = m.this.lResult
		endif
		if m.this.lResult

* Créer une variable par champ de la table source
			local lcFields
			lcFields = cFields(m.tcAliasSrce)
			local &lcFields

* Si forçage des types ou vérification des modifications
			if .f.;
			 or m.this.lTypesForce;
			 or m.this.lModCheck

				local laField[1], lnField, liField, lcField

* Tabuler les champs de la table source présents dans la table destination, et leurs types
				lnField = alines(laField, strtran(m.lcFields, ',', ','+',') + ',', 1+2, ',') && un élément vide après chaque champ
				dimension laField[m.lnField, 2]
				for liField = m.lnField to 1 step -1
					lcField = laField[m.liField, 1]
					if lField(m.lcField, m.tcAliasDest)
						laField[m.liField, 2] = vartype(evaluate(m.tcAliasDest + '.' + m.lcField), .t.)
					else
						lnField = m.lnField - 1
						adel(laField, m.liField)
					endif
				endfor
				dimension laField[m.lnField, 2]
			endif

* Créer les variables privées standard FoxInCloud / ZenBuyer
			private plSync, pltModKeep, plPKGen
			plSync = .t. && Inhibe le contrôle des droits dans la base zenbuyer
			pltModKeep = .t.; && Inhibe la mise à jour automatique de la date de modification
				 and vartype(m.this.cTimeStampField) == 'C';
				 and lField(m.this.cTimeStampField, m.tcAliasDest);
				 and lField(m.this.cTimeStampField, m.tcAliasSrce)
			plPKGen = m.tlReplace or not m.llPtag && Générer la PK

			local loDeleted, loExact, loException as exception, llSyncField
			loDeleted = abSet('DELETED', iif(m.this.lSyncDeleted, 'OFF', 'ON'))
			loExact = abSet('EXACT', 'ON')
			llSyncField = .t.;
				and lField(m.this.clSyncField, m.tcAliasDest);
				and loClass(m.this, 'acDataSyncVFP') && seulement si synchronisation depuis une source distante

* Si remplacement sans clé unique dans la table destination
			if m.tlReplace;
			 and !this.oResult.lPCtag;
			 and m.tnRecs = 0

* Ajouter tout simplement
				select (m.tcAliasDest)
* ==============
				try
					append from dbf(m.tcAliasSrce)
					if m.llSyncField
						replace all (m.this.clSyncField) with .t.
					endif
				catch to loException
					throw m.loException
				finally
					this.oResult.nRecsAdded = _tally
				endtry
* ==============

* Sinon (matching sur clé primaire ou candidate)
			else

* Pour chaque enregistrement de la source
				local llReplace, llInsert, luValue, llRec, lcRec, lcRecNo, lcRecContent, llDeleted
				select (m.tcAliasSrce)
				scan

					llRec = .t. && Résultat de l'enregistrement
					lcRec = '' && Résultat de l'enregistrement
					lcRecNo = transform(recno(m.tcAliasSrce))
					scatter memvar memo && FIELDS &lcFields

* Si forçage demandé, ajuster les types des champs en mémoire
					if m.this.lTypesForce
						for liField = 1 to m.lnField
							luValue = evaluate('m.' + laField[m.liField, 1])
							if not vartype(m.luValue, .t.) == laField[m.liField, 2]
								store uValue(m.luValue, laField[m.liField, 2]) to ('m.' + laField[m.liField, 1])
							endif
						endfor
					endif

* ==============
					try

* Si clé primaire non automatique, chercher l'enregistrement correspondant dans la table destination
						llReplace = this.oResult.lPCtag;
							and iif(this.oResult.lcTag;
								, seek(evaluate(m.lcPCexpMem), m.tcAliasDest, m.lcPCtag);
								, seek(evaluate(m.lcPexpMem), m.tcAliasDest, m.lcPtag))
						llInsert = not m.llReplace

* Si l'enregistrement existe
						if m.llReplace

* Si comparaison sur clé candidate sans conflit de clé primaire
							llReplace = not (this.oResult.lcTag and m.llPtag) or luEqual(evaluate(m.lcPexpMem), evaluate(m.lcPexpDest))
							if m.llReplace

* Aligner le statut de suppression
								llDeleted = .f.
								if deleted(m.tcAliasSrce)
									if not deleted(m.tcAliasDest)
										delete in (m.tcAliasDest)
										this.oResult.nRecsDeleted = this.oResult.nRecsDeleted + 1
										llDeleted = .t.
									endif
								else && NOT Deleted(m.tcAliasSrce)
									if deleted(m.tcAliasDest)
										recall in (m.tcAliasDest)
									endif
								endif

* Si vérification des modifications, vérifier la nécessité du remplacement
								if m.this.lModCheck
									for liField = 1 to m.lnField
										lcField = laField[m.liField, 1]
										llReplace = not luEqual(evaluate('m.' + m.lcField), evaluate(m.tcAliasDest + '.' + m.lcField))
										if m.llReplace
											exit
										endif
									next
								endif

								if m.llReplace

* Charger l'enregistrement dans la table destination
									select (m.tcAliasDest)
									gather memvar memo && /!\ conditionner MEMO par nouvelle valeur

									if not m.llDeleted
										this.oResult.nRecsReplaced = m.this.oResult.nRecsReplaced + 1
									endif
								endif

* Sinon (conflit de clé primaire)
							else
								llRec = .f.
								lcRec = textmerge(icase(;
									m.this.cLangUser = 'fr',;
										[]; && copy-paste the 2 following lines to add another language support
										+ [Enregistrement source n° <<m.lcRecno>> : la valeur de la clé candidate <<m.lcPCexp>> (<<Trim(Transform(Evaluate(m.lcPCexpMem)))>>) existe dans la table destination,];
										+ [ mais avec une clé primaire différente : <<Evaluate(m.lcPexpMem)>> dans la table source, <<Evaluate(m.lcPexpDest)>> dans la table destination],;
										[]; && Default: English
										+ [Source record # <<m.lcRecno>>: value of candidate key <<m.lcPCexp>> (<<Trim(Transform(Evaluate(m.lcPCexpMem)))>>) does exist in destination table,];
										+ [ but with a different value of pripary key: <<Evaluate(m.lcPexpMem)>> in source table, <<Evaluate(m.lcPexpDest)>> in destination table];
									))
							endif

						else

							insert into (m.tcAliasDest) from memvar
							this.oResult.nRecsAdded = m.this.oResult.nRecsAdded + 1
						endif

					catch to loException

						llRec = .f.
						lcRec = textmerge(icase(;
							m.this.cLangUser = 'fr',	[Erreur <<cException(m.loException)>> sur l'enregistrement source n° <<m.lcRecno>>],; && copy-paste this line to add another language support
																				[Error <<cException(m.loException)>> on source record # <<m.lcRecno>>]; && Default: English
							))
					endtry
* ==============

					if m.llRec

* Si remplacement ou insersion, indiquer que l'enregistrement a été mis à jour par synchronisation
						if (m.llReplace or m.llInsert) and m.llSyncField
							replace (m.this.clSyncField) with .t. in (m.tcAliasDest)
						endif

* Exécuter la méthode "shell"
						llRec = this.TableSync_Rec(m.tcAliasDest, m.llReplace, m.this.oResult.nRecsAdded, m.this.oResult.nRecsReplaced, m.tcAliasSrce)
						if not m.llRec
							lcRec = textmerge(icase(;
								m.this.cLangUser = 'fr',	[Erreur de la méthode shell TableSync_Rec() sur l'enregistrement source n° <<m.lcRecno>>],; && copy-paste this line to add another language support
																					[Error in shell method TableSync_Rec() on source record # <<m.lcRecno>>]; && Default: English
								))
						endif
					endif

					this.lResult = m.this.lResult and m.llRec
					if not m.llRec
						this.cResult = m.lcRec
						lcRecContent = cRecContent(m.tcAliasSrce)
						if m.this.lDebug
							this.cResult = textmerge(icase(;
								m.this.cLangUser = 'fr',	[L'enregistrement contient : <<m.lcRecContent>>],; && copy-paste this line to add another language support
																					[Record contains: <<m.lcRecContent>>]; && Default: English
								))
						endif
						this.oResult.cRecsSrceErrorNo = c2Words(this.oResult.cRecsSrceErrorNo, ',', m.lcRecNo)
						this.oResult.cRecsSrceErrorContent = c2Words(;
							  this.oResult.cRecsSrceErrorContent;
							, CRLF;
							, textmerge(icase(;
								m.this.cLangUser = 'fr',	[Contenu de l'enregistrement n° <<m.lcRecno>> : <<m.lcRecContent>>],; && copy-paste this line to add another language support
																					[Record # <<m.lcRecno>> contains: <<m.lcRecContent>>]; && Default: English
								));
							)
						this.oResult.nRecsSrceError = this.oResult.nRecsSrceError + 1
					endif

					if m.tnRecs > 0 and this.oResult.nRecsAdded >= m.tnRecs
						exit
					endif
				endscan
			endif

* Restituer le résultat final
			local lnIgnored, lcResult
			lnIgnored = this.oResult.nRecsSrce - m.this.oResult.nRecsAdded - m.this.oResult.nRecsReplaced - this.oResult.nRecsDeleted - m.this.oResult.nRecsSrceError
			lcResult = iif(m.this.oResult.lPCtag;
				, textmerge(icase(;
								m.this.cLangUser = 'fr',	[, <<m.this.oResult.nRecsReplaced>> remplacés, <<m.this.oResult.nRecsSrceError>> avec erreur],; && copy-paste this line to add another language support
																					[, <<m.this.oResult.nRecsReplaced>> replaced, <<m.this.oResult.nRecsSrceError>> with error]; && Default: English
								));
				, '';
				)
			lcResult = textmerge(icase(;
				m.this.cLangUser = 'fr',	[Table source : '<<Dbf(m.tcAliasSrce)>>' - <<this.oResult.nRecsSrce>> enregistrements, <<m.lnIgnored>> ignorés, <<m.this.oResult.nRecsAdded>> ajoutés<<m.lcResult>>],; && copy-paste this line to add another language support
																	[Source table: '<<Dbf(m.tcAliasSrce)>>' - <<this.oResult.nRecsSrce>> records, <<m.lnIgnored>> ignored, <<m.this.oResult.nRecsAdded>> added<<m.lcResult>>]; && Default: English
				))
			this.cResult =  iif(m.this.lResult, m.this.cResult + CRLF, '') + m.lcResult
		else
			this.cResult = textmerge(icase(;
				m.this.cLangUser = 'fr',	[Impossible d'ouvrir la table destination <<cLitteral(Dbf(m.tcAliasDest))>> en exclusif pour la vider.],; && copy-paste this line to add another language support
																	[Could not gain exclusive access on destination table <<cLitteral(Dbf(m.tcAliasDest))>> in order to zap it.]; && Default: English
				))
		endif
	endif

	return m.this.lResult

*---------------------------------------
	protected procedure TableSync_Rec && Exécuté à chaque enregistrement
	lparameters ;
		tcAliasDest,; && Alias de la table destination
		tlReplaced,; && L'enregistrement a été remplacé
		tnAdded,; && Nombre d'enregistrements ajoutés
		tnReplaced,; && Nombre d'enregistrements remplacés
		tcAliasSrce && Alias de la table source

&& Implémenter en sous-classe

* ========================================
enddefine && CLASS abDataSyncVFP
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

tModField  = evl(m.tModField, 'tMOD') && FoxInCloud standard
lSyncField = evl(m.lSyncField, 'lSYNC') && FoxInCloud standard

* {en} Set record's last modification date-time
* {fr} Régler la date et heure de dernière modification
if .t.;
 and !(lTrue(m.pltModKeep)); && pltModKeep : {en} Inhibit record's last modification date-time modification [see abDataSyncVFP.tablesync_()] {fr} Inhiber la mise à jour automatique de la date de modification [cf. abDataSyncVFP.tablesync_()]
 and ! empty(field(m.tModField)) && {en} Field exists in table {fr} Le champ existe dans la table
	replace (m.tModField) with datetime() && {en} In a table rule, Alias() == alias of the table owning the rule	{fr} dans une règle de table, Alias() == alias de la table dont la règle est exécutée
endif

* {en} Set record was not modified through synchronization
* {fr} Indiquer que l'enregistrement n'a pas été modifié par synchronisation
if .t.;
 and !(lTrue(m.plSync)); && plSync : {en} Records are being synchronized [see abDataSyncVFP.tablesync_()] {fr} synchronisation en cours  [cf. abDataSyncVFP.tablesync_()]
 and ! empty(field(m.lSyncField)) && {en} Field exists in table {fr} Le champ existe dans la table
	replace (m.lSyncField) with .f. && {en} In a table rule, Alias() == alias of the table owning the rule	{fr} dans une règle de table, Alias() == alias de la table dont la règle est exécutée
endif

endproc

* =============================================
function cDBsetPropOfTableFields
lparameters tuTable, tcProp

tcProp = evl(m.tcProp, 'Comment')

local Result, cAlias, cDB, lAlias, cTable;
, oSetDB as abSet of abDev.prg;
, laField[1], nField, iField, cField;

Result = ''
cAlias = cAlias(m.tuTable, @m.lAlias)
cDB = cursorgetprop("Database", m.cAlias)

if .t.;
 and used(m.cAlias);
 and !empty(m.cDB);
 and lInList(m.tcProp, 'Caption, Comment, DefaultValue, DisplayClass, DisplayClassLibrary, Format, InputMask, RuleExpression, RuleText')

	oSetDB = abSet('DATABASE', m.cDB)

	cTable = proper(cursorgetprop("SourceName", m.cAlias))
	nField = afields(laField, m.cAlias)
	asort(laField, 1)
	for iField = 1 to m.nField

		cField = textmerge("<<m.cTable>>.<<Lower(m.laField[m.iField, 1])>>")
		Result = m.Result + textmerge("DBSetProp('<<m.cField>>', 'FIELD', '<<m.tcProp>>', [<<DBgetProp(m.cField, 'FIELD', m.tcProp)>>])") + CRLF
	endfor
	if m.lAlias
		use in (m.cAlias)
	endif
endif
return m.Result
endfunc

* =============================================
function cCollationOfCodePage
lparameters uCodePage
uCodePage = iif(empty(pcount()), alias(), m.uCodePage)
uCodePage = iif(vartype(m.uCodePage) == 'C' and used(m.uCodePage), cpdbf(m.uCodePage), m.uCodePage)
local cLangUser
cLangUser = cLangUser()
return upper(icase(;
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
