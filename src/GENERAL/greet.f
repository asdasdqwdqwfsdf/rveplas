CDOC BEGIN_SUBROUTINE GREET
CDOC Prints HYPLAS greeting message on the standard output
CDOC
      SUBROUTINE GREET
 1000 FORMAT(//////////////////,
     1'  __________________________________________________________',
     2'______________ '/
     3' |_|_|_|_|_|_|_|_|_|_|_|_|_|_|_|                            ',
     4'              |'/
     5' |_|_|_|_|_|_|_|_|_|_|                                      ',
     6'              |'/
     7' |_|_|_|_|_|_|                                              ',
     8'              |'/
     9' |_|_|_|_|                                                  ',
     O'              |'/
     1' |_|_|_|                 H Y P L A S    version 4.0.1       ',
     2'              |'/
     3' |_|_|                  =============================       ',
     4'              |'/
     5' |_|_|                                                      ',
     6'             _|'/
     7' |_|_|                                                      ',
     8'            |_|')
 1010 FORMAT(
     1' |_|_|_                                                     ',
     2'            |_|'/
     3' |_|_|_|_     SMALL AND LARGE STRAIN FINITE ELEMENT ANALYSIS',
     4'           _|_|'/
     5' |_|_|_|_|   OF HYPERELASTIC AND VISCO-ELASTO-PLASTIC SOLIDS',
     6'          |_|_|'/
     7' |_|_|_|_|_                                                 ',
     8'       _ _|_|_|'/
     9' |_|_|_|_|_|                                                ',
     O'     _|_|_|_|_|'/
     1' |_|_|_|_|_|_ _                                             ',
     2' _ _|_|_|_|_|_|'/
     3' |_|_|_|_|_|_|_|____________________________________________',
     4'|_|_|_|_|_|_|_|')
 1020 FORMAT(
     1' |                                                      ,   ',
     2'              |'/
     3' |    Copyright (c) 1996-2015   EA de Souza Neto, D Peric & ',
     4'DRJ Owen      |'/
     5' |__________________________________________________________',
     6'______________|'/
     7' |                                                          ',
     8'              |'/
     9' |    Companion to the textbook:                            ',
     O'              |'/
     1' |    EA de Souza Neto, D Peric & DRJ Owen. Computational Me',
     2'thods for     |'/
     3' |    Plasticity: Theory and Applications. Wiley, Chichester',
     4', 2008.       |'/
     3' |__________________________________________________________',
     4'______________|'///)
      WRITE(*,1000)
      WRITE(*,1010)
      WRITE(*,1020)
      RETURN
      END
CDOC END_SUBROUTINE GREET
