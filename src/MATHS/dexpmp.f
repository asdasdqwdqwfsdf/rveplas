CDOC BEGIN_SUBROUTINE DEXPMP
CDOC Derivative of exponential map for general three-dimensional tensors
CDOC
CDOC This routine computes the derivative of the exponential of a
CDOC generally unsymmetric three-dimensional tensor.
CDOC It uses the series definition of the tensor exponential.
CDOC The exponential map itself is implemented in subroutine EXPMAP.
CDOC 
CDOC BEGIN_PARAMETERS
CDOC DOUBLE_PRECISION DEXPX  <  Derivative of the exponential map at X.
CDOC C                          This derivative is a fourth order
CDOC C                          tensor stored here as a 4-index array.
CDOC LOGICAL          NOCONV <  Logical convergence flag. Set to
CDOC C                          .TRUE. if the series fail to converge
CDOC C                          Set to .FALSE. otherwise.
CDOC DOUBLE_PRECISION X      >  Tensor at which exponential derivative
CDOC C                          is to be computed.
CDOC END_PARAMETERS
CHST
CHST E.de Souza Neto, December 1998: Initial coding
CHST
      SUBROUTINE DEXPMP
     1(   DEXPX      ,NOCONV     ,X          )
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      PARAMETER
     1(   NDIM=3     ,NDIM2=9    ,NDIM4=81   ,MAXN=100   )
C Arguments
      LOGICAL  NOCONV
      DIMENSION
     1    DEXPX(NDIM,NDIM,NDIM,NDIM),X(NDIM,NDIM)
C Local arrays and variables
C...matrix of powers of X
      DIMENSION
     1    R1DFAC(MAXN)       ,XMATX(NDIM,NDIM,0:MAXN)
C...initialise identity matrix: X to the power 0
      DATA
     1    XMATX(1,1,0)  ,XMATX(1,2,0)  ,XMATX(1,3,0)  /
     2    1.D0          ,0.D0          ,0.D0          /
     3    XMATX(2,1,0)  ,XMATX(2,2,0)  ,XMATX(2,3,0)  /
     4    0.D0          ,1.D0          ,0.D0          /
     5    XMATX(3,1,0)  ,XMATX(3,2,0)  ,XMATX(3,3,0)  /
     6    0.D0          ,0.D0          ,1.D0          /
      DATA
     1    R0   ,RP5  ,R1   ,TOL    ,OVER    ,UNDER   /
     2    0.0D0,0.5D0,1.0D0,1.0D-10,1.0D+100,1.0D-100/
C***********************************************************************
C COMPUTES THE DERIVATIVE OF THE EXPONENTIAL OF A (GENERALLY
C UNSYMMETRIC) 3-D TENSOR. USES THE SERIES REPRESENTATION OF THE TENSOR
C EXPONENTIAL.
C
C REFERENCE: Section B.2
C            Box B.2
C***********************************************************************
C Initialise convergence flag
      NOCONV=.FALSE.
C X to the power 1
      DO 20 I=1,NDIM
        DO 10 J=1,NDIM
          XMATX(I,J,1)=X(I,J)
   10   CONTINUE
   20 CONTINUE
C Zero remaining powers of X
      CALL RVZERO(XMATX(1,1,2),NDIM*NDIM*(MAXN-1))
C Compute X square
      DO 50 I=1,NDIM
        DO 40 J=1,NDIM
          DO 30 K=1,NDIM
            XMATX(I,J,2)=XMATX(I,J,2)+X(I,K)*X(K,J)
   30     CONTINUE
   40   CONTINUE
   50 CONTINUE
C Compute principal invariants of X
      C1=X(1,1)+X(2,2)+X(3,3)
      C2=RP5*(C1*C1-(XMATX(1,1,2)+XMATX(2,2,2)+XMATX(3,3,2)))
      C3=X(1,1)*X(2,2)*X(3,3)+X(1,2)*X(2,3)*X(3,1)+
     1   X(1,3)*X(2,1)*X(3,2)-X(1,2)*X(2,1)*X(3,3)-
     2   X(1,1)*X(2,3)*X(3,2)-X(1,3)*X(2,2)*X(3,1)
C Compute X to the powers 3,4,...,NMAX using recursive formula
      R1DFAC(1)=R1
      R1DFAC(2)=RP5
      DO 80 N=3,MAXN
        R1DFAC(N)=R1DFAC(N-1)/DBLE(N)
        DO 70 I=1,NDIM
          DO 60 J=1,NDIM
            XMATX(I,J,N)=C1*XMATX(I,J,N-1)-C2*XMATX(I,J,N-2)+
     1                   C3*XMATX(I,J,N-3)
   60     CONTINUE
   70   CONTINUE
        XNNORM=SQRT(SCAPRD(XMATX(1,1,N),XMATX(1,1,N),NDIM2))
C...check number of terms required for series convergence
        IF(XNNORM.GT.OVER.OR.(XNNORM.LT.UNDER.AND.XNNORM.GT.R0)
     1                                  .OR.R1DFAC(N).LT.UNDER)THEN
C...numbers are to small or too big: Exit without computing derivative
          NOCONV=.TRUE.
          GOTO 999
        ELSEIF(XNNORM*R1DFAC(N).LT.TOL)THEN
C...series will converge with NMAX terms:
C   Carry on to derivative computation
          NMAX=N
          GOTO 90
        ENDIF
   80 CONTINUE
C...series will not converge for the currently prescribed tolerance
C   with the currently prescribed maximum number of terms MAXN:
C   Exit without computing derivative
      NOCONV=.TRUE.
      GOTO 999
   90 CONTINUE
C Compute the derivative of exponential map
      CALL RVZERO(DEXPX,NDIM4)
      DO 150 I=1,NDIM
        DO 140 J=1,NDIM
          DO 130 K=1,NDIM
            DO 120 L=1,NDIM
              DO 110 N=1,NMAX
                DO 100 M=1,N
                  DEXPX(I,J,K,L)=DEXPX(I,J,K,L)+
     1                           R1DFAC(N)*XMATX(I,K,M-1)*XMATX(L,J,N-M)
  100           CONTINUE
  110         CONTINUE
  120       CONTINUE
  130     CONTINUE
  140   CONTINUE
  150 CONTINUE
C
  999 CONTINUE
      RETURN
      END
CDOC END_SUBROUTINE DEXPMP
