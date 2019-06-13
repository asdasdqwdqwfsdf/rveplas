CDOC BEGIN_SUBROUTINE EXPMAP
CDOC Exponential map for general three-dimensional tensors
CDOC
CDOC This routine computes the exponential of a generally unsymmetric
CDOC three-dimensional tensor. It uses the series definition of the
CDOC tensor exponential
CDOC 
CDOC BEGIN_PARAMETERS
CDOC DOUBLE_PRECISION EXPX   <  Tensor exponential of X.
CDOC LOGICAL          NOCONV <  Logical convergence flag. Set to
CDOC C                          .TRUE. if the series fail to converge.
CDOC C                          Set to .FALSE. otherwise.
CDOC DOUBLE_PRECISION X      >  Tensor whose exponential is to be
CDOC C                          computed.
CDOC END_PARAMETERS
CHST
CHST E.de Souza Neto, Sept 1998: Initial coding
CHST
      SUBROUTINE EXPMAP
     1(   EXPX       ,NOCONV     ,X          )
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      PARAMETER
     1(   NDIM=3     ,NDIM2=9    )
C Arguments
      LOGICAL  NOCONV
      DIMENSION
     1    EXPX(NDIM,NDIM)           ,X(NDIM,NDIM)
C Local arrays and variables
      DIMENSION
     1    XN(NDIM,NDIM)     ,XNM1(NDIM,NDIM)     ,XNM2(NDIM,NDIM)     ,
     2    XNM3(NDIM,NDIM)   ,X2(NDIM,NDIM)
      DATA
     1    R0   ,RP5  ,R1   ,R2   ,TOL    ,OVER    ,UNDER   /
     2    0.0D0,0.5D0,1.0D0,2.0D0,1.0D-10,1.0D+100,1.0D-100/
      DATA
     1    NMAX / 100 /
C***********************************************************************
C COMPUTES THE EXPONENTIAL OF A (GENERALLY UNSYMMETRIC) 3-D TENSOR. USES
C THE SERIES REPRESENTATION OF THE TENSOR EXPONENTIAL
C
C REFERENCE: Section B.1
C            Box B.1
C***********************************************************************
C Initialise series convergence flag
      NOCONV=.FALSE.
C Compute X square
      CALL RVZERO(X2,NDIM2)
      DO 30 I=1,NDIM
        DO 20 J=1,NDIM
          DO 10 K=1,NDIM
            X2(I,J)= X2(I,J)+X(I,K)*X(K,J)
   10     CONTINUE
   20   CONTINUE
   30 CONTINUE
C Compute principal invariants of X
      C1=X(1,1)+X(2,2)+X(3,3)
      C2=RP5*(C1*C1-(X2(1,1)+X2(2,2)+X2(3,3)))
      C3=X(1,1)*X(2,2)*X(3,3)+X(1,2)*X(2,3)*X(3,1)+
     1   X(1,3)*X(2,1)*X(3,2)-X(1,2)*X(2,1)*X(3,3)-
     2   X(1,1)*X(2,3)*X(3,2)-X(1,3)*X(2,2)*X(3,1)
C Start computation of exponential using its series definition
C ============================================================
      DO 50 I=1,NDIM
        DO 40 J=1,NDIM
          XNM1(I,J)=X2(I,J)
          XNM2(I,J)=X(I,J)
   40   CONTINUE
   50 CONTINUE
      XNM3(1,1)=R1
      XNM3(1,2)=R0
      XNM3(1,3)=R0
      XNM3(2,1)=R0
      XNM3(2,2)=R1
      XNM3(2,3)=R0
      XNM3(3,1)=R0
      XNM3(3,2)=R0
      XNM3(3,3)=R1
C Add first three terms of series
C -------------------------------
      DO 70 I=1,NDIM
        DO 60 J=1,NDIM
          EXPX(I,J)=RP5*XNM1(I,J)+XNM2(I,J)+XNM3(I,J)
   60   CONTINUE
   70 CONTINUE
C Add remaining terms (with X to the powers 3 to NMAX)
C ----------------------------------------------------
      FACTOR=R2
      DO 140 N=3,NMAX
C Use recursive formula to obtain X to the power N
        DO 90 I=1,NDIM
          DO 80 J=1,NDIM
            XN(I,J)=C1*XNM1(I,J)-C2*XNM2(I,J)+C3*XNM3(I,J)
   80     CONTINUE
   90   CONTINUE
C Update factorial
        FACTOR=DBLE(N)*FACTOR
        R1DFAC=R1/FACTOR
C Add Nth term of the series
        DO 110 I=1,NDIM
          DO 100 J=1,NDIM
            EXPX(I,J)=EXPX(I,J)+R1DFAC*XN(I,J)
  100     CONTINUE
  110   CONTINUE
C Check convergence of series
        XNNORM=SQRT(SCAPRD(XN(1,1),XN(1,1),NDIM2))
        IF(XNNORM.GT.OVER.OR.(XNNORM.LT.UNDER.AND.XNNORM.GT.R0)
     1                                     .OR.R1DFAC.LT.UNDER)THEN
C...first check possibility of overflow or underflow.
C...numbers are to small or too big: Break (unconverged) loop and exit
          NOCONV=.TRUE.
          GOTO 999
        ELSEIF(XNNORM*R1DFAC.LT.TOL)THEN
C...converged: Break series summation loop and exit with success
          GOTO 999
        ENDIF 
        DO 130 I=1,NDIM
          DO 120 J=1,NDIM
            XNM3(I,J)=XNM2(I,J)
            XNM2(I,J)=XNM1(I,J)
            XNM1(I,J)=XN(I,J)
  120     CONTINUE
  130   CONTINUE
  140 CONTINUE
C Re-set convergence flag if series did not converge
      NOCONV=.TRUE.
C
  999 CONTINUE
      RETURN
      END
CDOC END_SUBROUTINE EXPMAP
