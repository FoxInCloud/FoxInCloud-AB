* FoxInCloud constants
* ====================

#DEFINE V_2_21
&& {en} Compile to this version; to step back to previous version:
&& {fr} Compiler à cette version ; pour revenir à la version précédente :
&& 1- modify file awPublic_override.h:
&& {en} 2- add this line:
&& {fr} 2- ajouter cette ligne :
*	#UNDEF	V_2_21
&& {en} 3- compile project:
&& {fr} 3- compiler le projet :
*	do atPJcompile with 'V_2_21'

#DEFINE wMESSAGEBOX_CLASS		awFrmMB
&& {fr} Classe de formulaire de MessageBox()
&& {fr} Utilisé en dehors du contexte d'un formulaire
&& {fr} cf. awPublic.prg!wMessageBox()

&& {en} MessageBox() form class
&& {en} Used outside of a form
&& {en} see awPublic.prg!wMessageBox()

#DEFINE wINPUTBOX_CLASS			awFrmIB
&& {fr} Classe de formulaire de InputBox()
&& {fr} Utilisé en dehors du contexte d'un formulaire
&& {fr} cf. awPublic.prg!wInputBox()

&& {en} InputBox() form class
&& {en} Used outside of a form
&& {en} see awPublic.prg!wInputBox()

#DEFINE wGETCOLOR_CLASS			awFrmGC
&& {fr} Classe de formulaire de GetColor()
&& {fr} Utilisé en dehors du contexte d'un formulaire
&& {fr} cf. awPublic.prg!wGetColor()

&& {en} GetColor() form class
&& {en} Used outside of a form
&& {en} see awPublic.prg!wGetColor()

#DEFINE wGETPICT_CLASS			awFrmGP
&& {fr} Classe de formulaire de GetPict()
&& {fr} Utilisé en dehors du contexte d'un formulaire
&& {fr} cf. awPublic.prg!wGetPict()

&& {en} GetPict() form class
&& {en} Used outside of a form
&& {en} see awPublic.prg!wGetPict()

#DEFINE wGETFILE_CLASS			awFrmGF
&& {fr} Classe de formulaire de GetFile()
&& {fr} Utilisé en dehors du contexte d'un formulaire
&& {fr} cf. awPublic.prg!wGetFile()

&& {en} GetFile() form class
&& {en} Used outside of a form
&& {en} see awPublic.prg!wGetFile()

* =======================================================
#IF File('awPublic_override.h')
	#INCLUDE awPublic_override.h
#ENDIF
* =======================================================
&& {fr} Surcharge pour l'application FoxInCloud
&& {fr} awPublic_override.h n'est jamais remplacé lors des mises à jour FoxInCloud

&& {en} Overload(s) for FoxInCloud Application
&& {en} awPublic_override.h is never replaced when FoxInCloud is updated
