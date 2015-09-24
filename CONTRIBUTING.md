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
- localization language code: '{<2-letter ISO 639-1 language code>}' - see https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes
- localized comment: starts with '{language code>}'
```xBase
FUNCTION aChars && {fr} Tabule les caractères d'une chaîne {en} splits characters of a string into an array
```
- localized message: copy and paste iCase() line or case block, 
```xBase
FUNCTION aChars && {fr} Tabule les caractères d'une chaîne {en} splits characters of a string into an array
```
- `function` name start with a lower-cased 1-letter prefix indicating the type returned; eg. `function lWordIn as Boolean`
- `procedure` name starts with the name of element the procedure works on; eg. `procedureTableFreeCreateOrAdjust`
- `procedure` always return success indicator: `.T.` if task could be completed successfully, `.F.` otherwise
- `function` that could not, for any reason, calculate the result returns `.null.`
- preferably, procedure's 1rst parameter is the result passed by `@`reference
- caps: commands in lower case, native functions in MixedCase
- beautifier:
  - capitalization:
    - keywords: lowercase (can't make a difference between commands and functions like in Intellisense Manager),
    - symbols: match first occurrence.
  - indentation:
    - tab == space(2)
    - comments: yes
    - continuation line: no, do it manually
    - extra indent beneath: NO
- try to get away from hungarian notation:
  - llResult > success
  - lcResult > result
- always declare local variables and use **`lparameters`** (as opposed to `parameters`)
- when reading the contents of a variable, always prefix the variable name by 'm.'; never use 'm.' when assigning:
```xBase
&& foo is assigned: no 'm.'
&& bar is read: use 'm.'
local foo bar
foo = m.bar
store m.bar to foo
```

Please make sure to read some existing code before starting your own modifications!
