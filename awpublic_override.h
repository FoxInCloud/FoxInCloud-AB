* {en} Client override of awPublic.h
* {en} Never replaced when FoxInCloud is updated
* {en} sample use case below: redefine messabeBox class used by awPublic.prg!wMessageBox()
* {en} recompile source files after any change

* {fr} Surcharges client de awPublic.h
* {fr} Jamais remplacées par mises à jour FoxInCloud
* {fr} Exemple d'utilisation ci-après : redéfinir la classe de messageBox utilisée par awPublic.prg!wMessageBox()
* {fr} Toujours recompiler les fichiers source après une modification

&& #UNDEF	wMESSAGEBOX_CLASS
&& #DEFINE	wMESSAGEBOX_CLASS	xxxFrmMB

#UNDEF	V_2_21
&& {en} compile the project after any change: 
&& {fr} compiler le projet après tout changement :
*  do atPJcompile with 'V_2_21'
