* VFP
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
#UNDEFINE true && Javascript literal
#UNDEFINE false && Javascript literal

* FoxInCloud public
#INCLUDE awPublic.h && en dernier car inclut 'awPublic_Override.h'

* {en} Override any constant in 'awPublic_override.h' (never replaced with new version install)
* {fr} Surcharger toute constante dans 'awPublic_override.h' (jamais remplacé par l'installation d'une nouvelle version)
