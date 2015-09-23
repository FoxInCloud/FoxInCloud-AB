# Rules to contribute to FoxInCloud-AB

- all modifications MUST be back compatible
- module & parameter documentation: in-line comment at the end of the definition line:

```xBase
FUNCTION aChars && {fr} Tabule les caractères d'une chaîne {en} splits characters of a string into an array
LPARAMETERS ;
  taResult; && @ {fr} Résultat {en} Result
, tcString && {fr} Chaîne à splitter {en} String to be splitted
```

- coma first: when an instructions splits on several lines, typically a `function` call, make sure to place the coma between 2 parameters at the beginning of next line (see above example)
- localization: starts with '{<2-letter ISO 639-1 language code>}' - see https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes
```xBase
FUNCTION aChars && {fr} Tabule les caractères d'une chaîne {en} splits characters of a string into an array
```
- `function` name start with a lower-cased 1-letter prefix indicating the type returned; eg. `function lWordIn as Boolean`
- `procedure` name starts with the name of element the procedure works on; eg. `procedureTableFreeCreateOrAdjust`
- `procedure` always return success indicator: `.T.` if task could be completed successfully, `.F.` otherwise
- `function` that could not, for any reason, calculate the result returns `.null.`
- preferably, procedure's 1rst parameter is the result passed by `@`reference
- intellisense: we prefer commands in lower case, native functions in MixedCase
- we tend to get away from hungarian notation
- always declare local variables and use lparameters (and not parameters)
- when reading the contents of a variable, always prefix the variable name by 'm.'; never use 'm.' when assigning

```xBase
foo = m.bar && foo is assigned, no 'm.' - bar is read, use 'm.'
store m.bar to foo
```

Please make sure to read some existing code before starting your own modifications!
