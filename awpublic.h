* {fr} FoxInCloud constants
* ====================

&& {en} To step back to previous MAJOR or MINOR version (does not apply to patches):
&& {fr} Pour revenir à la version MAJEURE ou MINEURE précédente (ne s'applique pas aux correctifs) :
&& 1- modify file awPublic_override.h:
&& 2- {en} add these lines (uncommented):
&& 2- {fr} ajouter ces lignes (sans commentaire) :
#IFNDEF	PREVIOUS_FIC_VERSION
*!*	#DEFINE	PREVIOUS_FIC_VERSION
#ENDIF
&& 3- {en} make sure you run VFP / FiC studio as an Administrator
&& 3- {fr} assurez-vous d'exécuter VFP / FiC studio en tant qu'Administrateur
&& 4- {en} compile project:
&& 4- {fr} compiler le projet :
* do atPJcompile with 'PREVIOUS_FIC_VERSION'

#DEFINE wMESSAGEBOX_CLASS		awFrmMB
&& 2017-02-02 thn -- {FiC V 2.24.0-beta.5} {en} deprecated by xxxServer.cFrmMBclass
&& {fr} Classe de formulaire de MessageBox()
&& {fr} Utilisé en dehors du contexte d'un formulaire
&& {fr} cf. awPublic.prg!wMessageBox()
&& {en} MessageBox() form class
&& {en} Used outside of a form
&& {en} see awPublic.prg!wMessageBox()

#DEFINE wINPUTBOX_CLASS			awFrmIB
&& 2017-02-02 thn -- {FiC V 2.24.0-beta.5} {en} deprecated by xxxServer.cFrmIBclass
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



&& {fr} FoxInCloud development
#IF File('awPublic_override_ab.h')
	#INCLUDE awPublic_override_ab.h
#ENDIF
