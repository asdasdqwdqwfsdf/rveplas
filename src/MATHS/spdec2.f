CDOC BEGIN_SUBROUTINE SPDEC2
CDOC Closed form spectral decomposition of 2-D symmetric tensors
CDOC
CDOC This routine performs the spectral decomposition of 2-D symmetric
CDOC tensors in closed form. The tensor is passed as argument (stored in
CDOC vector form).
CDOC 
CDOC BEGIN_PARAMETERS
CDOC DOUBLE_PRECISION EIGPRJ <  Matrix with one eigenprojection tensor
CDOC C                          of X stored in each column.
CDOC DOUBLE_PRECISION EIGX   <  Array containing the eigenvalues of X.
CDOC LOGICAL          REPEAT <  Repeated eigenvalues flag. Set to
CDOC C                          .TRUE. if the eigenvalues of X
CDOC C                          are repeated (within a small tolerance).
CDOC DOUBLE_PRECISION X      >  Array containing the components of a
CDOC C                          symmetric tensor.
CDOC END_PARAMETERS
CHST
CHST E.de Souza Neto, May 1996: Initial coding
CHST
      SUBROUTINE SPDEC2
     1(   EIGPRJ     ,EIGX       ,REPEAT     ,X          )
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      PARAMETER
     1(   MCOMP=4    ,NDIM=2     )
      LOGICAL REPEAT
      DIMENSION
     1    EIGPRJ(MCOMP,NDIM)        ,EIGX(NDIM)                ,
     2    X(MCOMP)
      DIMENSION
     1    AUXMTX(NDIM,NDIM)         ,EIGVEC(NDIM,NDIM)
      DATA
     1    R0   ,RP5  ,R1   ,R4   ,SMALL  /
     2    0.0D0,0.5D0,1.0D0,4.0D0,1.D-5  /
C***********************************************************************
C PERFORMS THE CLOSED FORM SPECTRAL DECOMPOSITION OF A
C SYMMETRIC 2-D TENSOR STORED IN VECTOR FORM
C
C REFERENCE: Box A.2
C***********************************************************************
      REPEAT=.FALSE.
C Compute eigenvalues of X
C ------------------------
      TRX=X(1)+X(2)
      B=SQRT((X(1)-X(2))**2+R4*X(3)*X(3))
      EIGX(1)=RP5*(TRX+B)
      EIGX(2)=RP5*(TRX-B)
C Compute eigenprojection tensors
C -------------------------------
      DIFFER=ABS(EIGX(1)-EIGX(2))
      AMXEIG=DMAX1(ABS(EIGX(1)),ABS(EIGX(2)))
      IF(AMXEIG.NE.R0)DIFFER=DIFFER/AMXEIG
      IF(DIFFER.LT.SMALL)THEN
        REPEAT=.TRUE.
C for repeated (or nearly repeated) eigenvalues, re-compute eigenvalues
C and compute eigenvectors using the iterative procedure. In such cases,
C the closed formula for the eigenvectors is singular (or dominated by
C round-off errors)
        AUXMTX(1,1)=X(1)
        AUXMTX(2,2)=X(2)
        AUXMTX(1,2)=X(3)
        AUXMTX(2,1)=AUXMTX(1,2)
        CALL JACOB(AUXMTX,EIGX,EIGVEC,2)
        DO 10 IDIR=1,2
          EIGPRJ(1,IDIR)=EIGVEC(1,IDIR)*EIGVEC(1,IDIR)
          EIGPRJ(2,IDIR)=EIGVEC(2,IDIR)*EIGVEC(2,IDIR)
          EIGPRJ(3,IDIR)=EIGVEC(1,IDIR)*EIGVEC(2,IDIR)
          EIGPRJ(4,IDIR)=R0
 10     CONTINUE
      ELSE
C Use closed formula to compute eigenprojection tensors
        DO 20 IDIR=1,2
          B=EIGX(IDIR)-TRX
          C=R1/(EIGX(IDIR)+B)
          EIGPRJ(1,IDIR)=C*(X(1)+B)
          EIGPRJ(2,IDIR)=C*(X(2)+B)
          EIGPRJ(3,IDIR)=C*X(3)
          EIGPRJ(4,IDIR)=R0
 20     CONTINUE
      ENDIF
      RETURN
      END
CDOC END_SUBROUTINE SPDEC2
