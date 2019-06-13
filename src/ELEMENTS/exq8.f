CDOC BEGIN_SUBROUTINE EXQ8
CDOC Gauss point-node extrapolation matrix for element type QUAD8
CDOC
CDOC This routine sets the coefficients matrix for extrapolation of
CDOC fields from Gauss point values to nodal values for element type
CDOC QUAD8: Standard isoparametric 8-noded quadrilateral.
CDOC
CDOC BEGIN_PARAMETERS
CDOC INTEGER          NGAUSP >  Number of Gauss points.
CDOC DOUBLE_PRECISION EXMATX <  Extrapolation matrix.
CDOC END_PARAMETERS
CHST
CHST E.de Souza Neto, August 1996: Initial coding
CHST
      SUBROUTINE EXQ8
     1(   NGAUSP     ,EXMATX     )
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      PARAMETER(NNODE=8)
      DIMENSION EXMATX(NNODE,NGAUSP)
      DATA R0    ,RP5   ,R1    /
     1     0.0D0 ,0.5D0 ,1.0D0 /
      DATA
     1    A4               ,B4                 ,C4                 /
     2    1.866025404D0    ,-0.5D0             ,0.133974596D0      /
      DATA
     1    A5               ,B5                 ,C5                 /
     2    1.290994449D0    ,-0.290994449D0     ,0.645497224D0      /
      DATA
     1    A9               ,B9                 ,C9                 ,
     2    D9               ,E9                 ,F9                 ,
     3    G9               ,H9                 ,P9                 /
     4    2.186939819D0    ,0.277777778D0      ,0.035282404D0      ,
     5    1.478830558D0    ,0.187836109D0      ,-0.985887039D0     ,
     6    -0.125224073D0   ,0.444444444D0      ,-0.666666667D0     /
C***********************************************************************
C SET COEFFICIENTS MATRIX (EXMATX) FOR EXTRAPOLATION FROM GAUSS POINTS
C TO NODES FOR ELEMENT TYPE 'QUAD_8' (STANDARD 8-NODED QUADRILATERAL)
C
C REFERENCE: Section 5.6.1
C            E Hinton & JS Campbel. Local and global Smoothing of
C            discontinuous finite element functions using a least
C            squares method. Int. J. Num. meth. Engng., 8:461-480, 1974.
C            E Hinton & DRJ Owen. An introduction to finite element
C            computations. Pineridge Press, Swansea, 1979.
C***********************************************************************
      IF(NGAUSP.EQ.1)THEN
        EXMATX(1,1)=R1
        EXMATX(2,1)=R1
        EXMATX(3,1)=R1
        EXMATX(4,1)=R1
        EXMATX(5,1)=R1
        EXMATX(6,1)=R1
        EXMATX(7,1)=R1
        EXMATX(8,1)=R1
      ELSEIF(NGAUSP.EQ.4)THEN
        EXMATX(1,1)=A4         
        EXMATX(1,2)=B4         
        EXMATX(1,3)=B4         
        EXMATX(1,4)=C4         
        EXMATX(2,1)=RP5*(A4+B4)
        EXMATX(2,2)=RP5*(B4+C4)
        EXMATX(2,3)=RP5*(B4+A4)
        EXMATX(2,4)=RP5*(C4+B4)
        EXMATX(3,1)=B4
        EXMATX(3,2)=C4
        EXMATX(3,3)=A4
        EXMATX(3,4)=B4
        EXMATX(4,1)=RP5*(B4+C4)
        EXMATX(4,2)=RP5*(C4+B4)
        EXMATX(4,3)=RP5*(A4+B4)
        EXMATX(4,4)=RP5*(B4+A4)
        EXMATX(5,1)=C4
        EXMATX(5,2)=B4
        EXMATX(5,3)=B4
        EXMATX(5,4)=A4
        EXMATX(6,1)=RP5*(C4+B4)
        EXMATX(6,2)=RP5*(B4+A4)
        EXMATX(6,3)=RP5*(B4+C4)
        EXMATX(6,4)=RP5*(A4+B4)
        EXMATX(7,1)=B4
        EXMATX(7,2)=A4
        EXMATX(7,3)=C4
        EXMATX(7,4)=B4
        EXMATX(8,1)=RP5*(B4+A4)
        EXMATX(8,2)=RP5*(A4+B4)
        EXMATX(8,3)=RP5*(C4+B4)
        EXMATX(8,4)=RP5*(B4+C4)
      ELSEIF(NGAUSP.EQ.5)THEN
        EXMATX(1,1)=A5
        EXMATX(1,2)=R0
        EXMATX(1,3)=R0
        EXMATX(1,4)=R0
        EXMATX(1,5)=B5
        EXMATX(2,1)=C5
        EXMATX(2,2)=R0
        EXMATX(2,3)=C5
        EXMATX(2,4)=R0
        EXMATX(2,5)=B5
        EXMATX(3,1)=R0
        EXMATX(3,2)=R0
        EXMATX(3,3)=A5
        EXMATX(3,4)=R0
        EXMATX(3,5)=B5
        EXMATX(4,1)=R0
        EXMATX(4,2)=R0
        EXMATX(4,3)=C5
        EXMATX(4,4)=C5
        EXMATX(4,5)=B5
        EXMATX(5,1)=R0
        EXMATX(5,2)=R0
        EXMATX(5,3)=R0
        EXMATX(5,4)=A5
        EXMATX(5,5)=B5
        EXMATX(6,1)=R0
        EXMATX(6,2)=C5
        EXMATX(6,3)=R0
        EXMATX(6,4)=C5
        EXMATX(6,5)=B5
        EXMATX(7,1)=R0
        EXMATX(7,2)=A5
        EXMATX(7,3)=R0
        EXMATX(7,4)=R0
        EXMATX(7,5)=B5
        EXMATX(8,1)=C5
        EXMATX(8,2)=C5
        EXMATX(8,3)=R0
        EXMATX(8,4)=R0
        EXMATX(8,5)=B5
      ELSEIF(NGAUSP.EQ.9)THEN
        EXMATX(1,1)=A9
        EXMATX(1,2)=F9
        EXMATX(1,3)=B9
        EXMATX(1,4)=F9
        EXMATX(1,5)=H9
        EXMATX(1,6)=G9
        EXMATX(1,7)=B9
        EXMATX(1,8)=G9
        EXMATX(1,9)=C9
        EXMATX(2,1)=R0
        EXMATX(2,2)=R0
        EXMATX(2,3)=R0
        EXMATX(2,4)=D9
        EXMATX(2,5)=P9
        EXMATX(2,6)=E9
        EXMATX(2,7)=R0
        EXMATX(2,8)=R0
        EXMATX(2,9)=R0
        EXMATX(3,1)=B9
        EXMATX(3,2)=G9
        EXMATX(3,3)=C9
        EXMATX(3,4)=F9
        EXMATX(3,5)=H9
        EXMATX(3,6)=G9
        EXMATX(3,7)=A9
        EXMATX(3,8)=F9
        EXMATX(3,9)=B9
        EXMATX(4,1)=R0
        EXMATX(4,2)=E9
        EXMATX(4,3)=R0
        EXMATX(4,4)=R0
        EXMATX(4,5)=P9
        EXMATX(4,6)=R0
        EXMATX(4,7)=R0
        EXMATX(4,8)=D9
        EXMATX(4,9)=R0
        EXMATX(5,1)=C9
        EXMATX(5,2)=G9
        EXMATX(5,3)=B9
        EXMATX(5,4)=G9
        EXMATX(5,5)=H9
        EXMATX(5,6)=F9
        EXMATX(5,7)=B9
        EXMATX(5,8)=F9
        EXMATX(5,9)=A9
        EXMATX(6,1)=R0
        EXMATX(6,2)=R0
        EXMATX(6,3)=R0
        EXMATX(6,4)=E9
        EXMATX(6,5)=P9
        EXMATX(6,6)=D9
        EXMATX(6,7)=R0
        EXMATX(6,8)=R0
        EXMATX(6,9)=R0
        EXMATX(7,1)=B9
        EXMATX(7,2)=F9
        EXMATX(7,3)=A9
        EXMATX(7,4)=G9
        EXMATX(7,5)=H9
        EXMATX(7,6)=F9
        EXMATX(7,7)=C9
        EXMATX(7,8)=G9
        EXMATX(7,9)=B9
        EXMATX(8,1)=R0
        EXMATX(8,2)=D9
        EXMATX(8,3)=R0
        EXMATX(8,4)=R0
        EXMATX(8,5)=P9
        EXMATX(8,6)=R0
        EXMATX(8,7)=R0
        EXMATX(8,8)=E9
        EXMATX(8,9)=R0
      ENDIF
C
      RETURN
      END
CDOC END_SUBROUTINE EXQ8
