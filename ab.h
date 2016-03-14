* VFP
* {en} requires: set path to (home(1)) additive
* {en} to set all pathes: do ab
#INCLUDE FoxPro.h
#INCLUDE ffc\GDIplus.H

* Abaque
#INCLUDE abData.h
#INCLUDE abDev.h
#INCLUDE abFile.h
#INCLUDE abOffice.h
#INCLUDE abTxt.h

* Gregory Adam
#INCLUDE GA_.h
#UNDEFINE true && {fr} Javascript literal
#UNDEFINE false && {fr} Javascript literal

* FoxInCloud public
#INCLUDE awPublic.h && {fr} en dernier car inclut 'awPublic_Override.h'

* {en} Override any constant in 'awPublic_override.h' (never replaced with by a new version of FoxInCloud install)
* {fr} Surcharger toute constante dans 'awPublic_override.h' (jamais remplacé par l'installation d'une nouvelle version de FoxInCloud)
