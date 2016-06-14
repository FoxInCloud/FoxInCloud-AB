&& {en} already #DEFINEd in wConnect.h
&& {fr} Déjà définies dans wConnect.h
#IFDEF CR
	#UNDEFINE CR
#ENDIF
#DEFINE CR			Chr(13) 

#IFNDEF LF
	#DEFINE LF		 	Chr(10)
#ENDIF

#IFNDEF CRLF
	#DEFINE CRLF		CR+LF
#ENDIF

&& {en} Special Characters
&& {fr} Caractères spéciaux
#DEFINE	CR2			 	CR+CR
#DEFINE	LF2		 		LF+LF
#DEFINE	CRLF2		 	CRLF+CRLF
#DEFINE	CRLF3		 	CRLF+CRLF+CRLF
#DEFINE	LFCR		 	LF+CR
#DEFINE	LFCR2		 	LFCR+LFCR

#DEFINE	TABUL			Chr(9) 
#DEFINE	TABUL2			TABUL+TABUL
#DEFINE	POINTSUSP		Chr(133)
#DEFINE	NON_XML			Chr(0)+Chr(1)+Chr(2)+Chr(3)+Chr(4)+Chr(5)+Chr(6)+Chr(7)+Chr(8) + Chr(11)+Chr(12) + Chr(14)+Chr(15)+Chr(16)+Chr(17)+Chr(18)+Chr(19)+Chr(20)+Chr(21)+Chr(22)+Chr(23)+Chr(24)+Chr(25)+Chr(26)+Chr(27)+Chr(28)+Chr(29)+Chr(30)+Chr(31)
#DEFINE	NON_PRINTABLE	NON_XML + Chr(9)+Chr(10)+Chr(13)+Chr(160)
#DEFINE	CARS_SEPAR		Chr(33)+Chr(34)+Chr(35)+Chr(36)+Chr(37)+Chr(38)+Chr(39)+Chr(40)+Chr(41)+Chr(42)+Chr(43)+Chr(44)+Chr(45)+Chr(46)+Chr(47)+Chr(58)+Chr(59)+Chr(60)+Chr(61)+Chr(62)+Chr(63)+Chr(64)+Chr(123)+Chr(124)+Chr(125)+Chr(126)+Chr(168)+Chr(169)+Chr(170)+Chr(171)+Chr(172)+Chr(176)+Chr(242)+Chr(246)

&& {fr} HTML
#DEFINE NBSPC '&nbsp;'
#DEFINE _EURO '&euro;'
#DEFINE _ENSP '&ensp;'
#DEFINE _MDASH '&mdash;'
#DEFINE BRK [<br>]
#DEFINE BRK2 BRK + BRK
#DEFINE BRKCRLF BRK + CRLF
