# FoxInCloud-AB
FoxInCloud public layer for Visual FoxPro 9+

About 1,000 general-purpose procedures and functions that any VFP deleloper can use for his/her own application(s).

Categorized by scope: Array, Data, Date, Development, Text, etc.

More details on http://foxincloud.com/OpenSource.php

Areas you may want to contribute:
- improve code
- localize documentation comments

Rules:
- all modifications MUST be back compatible
- module & parameter documentation: in-line comment at the end of the definition line
- localization: starts with '{<2-letter ISO 639-1 language code>}' - see https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes
- function name start with a lower-cased 1-letter prefix indicating the type returned; eg. lWordIn()
- procedure name starts with the name of element the procedure works on; eg. TableFreeCreateOrAdjust()
- procedure always return success indicator: .T. if task could be completed successfully, .F. otherwise
- function that could not, for any reason, calculate the result returns .null.
- preferably, procedure's 1rst parameter is the result passed by @reference
