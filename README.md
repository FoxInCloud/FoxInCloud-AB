# FoxInCloud-AB
FoxInCloud public layer for Visual FoxPro 9+

Over 1,000 general-purpose procedures and functions that any VFP deleloper can use for his/her own application(s).

Categorized by scope: Array, Data, Date, Development, Text, etc.

More details on http://foxincloud.com/OpenSource.php

## How to install

Just download and copy this package anywhere you want;  
however, if you plan to use FoxInCloud in the future, the recommended location is:
```foxpro
home(1) + 'tools\ab\'
```

## How to use

Somewhere in your initialization process, add:
```foxpro
set path to <where your FoxInCloud-AB package is installed> additive
do ab
```

Then use the classes, procedures and functions in your code as usual

## Wanna contribute?

Areas you may want to contribute:
- improve and/or extend code base
- localize documentation comments

For detailed information, see CONTRIBUTING.md @ https://github.com/FoxInCloud/FoxInCloud-AB/blob/master/CONTRIBUTING.md
