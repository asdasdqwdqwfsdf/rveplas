CDOC BEGIN_SUBROUTINE DISO2
CDOC Derivative of a class of isotropic tensor function of one tensor
CDOC
CDOC This function computes the derivative, dY(X)/dX, of a particular
CDOC class of symmetric isotropic tensor valued function of one
CDOC symmetric tensor, Y(X).
CDOC This implementation is restricted to 2-D with one possible
CDOC out-of-plane component (normally needed in axisymmetric problems).
CDOC The class of tensor functions Y(X) is assumed to be defined as
CDOC Y(X)= Sum[y(xi) ei(x)ei], where the scalar function y(xi) defines
CDOC the eigenvalues of the tensor Y and xi the eigenvalues of the
CDOC tensor X. ei are the egenvectors of X (which by definition of
CDOC Y(X), coincide with those of tensor Y) and "(x)" denotes the
CDOC tensor product.
CDOC
CDOC BEGIN_PARAMETERS
CDOC DOUBLE_PRECISION DYDX   <  Matrix of components of the derivative
CDOC C                          (fourth order tensor) dY/dX.
CDOC SYMBOLIC_NAME    DFUNC  >  Symbolic name of the double precision
CDOC C                          function defining the derivative
CDOC C                          dy(x)/dx of the eigenvalues of the
CDOC C                          tensor function.
CDOC SYMBOLIC_NAME    FUNC   >  Symbolic name of the double precision
CDOC C                          function defining the eigenvalues y(x)
CDOC C                          of the tensor fumction.
CDOC LOGICAL          OUTOFP >  Out-of-plane component flag. If set to
CDOC C                          .TRUE. the out-of-plane
CDOC C                          component (normally required in
CDOC C                          axisymmetric problems) is computed.
CDOC C                          The out-of-plane component is not
CDOC C                          computed otherwise.
CDOC DOUBLE_PRECISION X      >  Point (argument) at which the
CDOC C                          derivative is to be computed.
CDOC END_PARAMETERS
CHST
CHST E.de Souza Neto, August 1996: Initial coding
CHST
      SUBROUTINE DISO2
     1(   DYDX       ,DFUNC      ,FUNC       ,OUTOFP     ,X          )
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      EXTERNAL
     1    DFUNC      ,FUNC
      PARAMETER
     1(   MCOMP=4    ,NDIM=2     )
C Arguments
      LOGICAL OUTOFP
      DIMENSION
     1    DYDX(MCOMP,MCOMP) ,X(*)
C Local variables and arrays
      LOGICAL REPEAT
      DIMENSION
     1    DEIGY(NDIM)       ,EIGPRJ(MCOMP,NDIM),EIGX(NDIM)        ,
     2    EIGY(NDIM)        ,FOID(MCOMP,MCOMP)
      DATA
     1    FOID(1,1)     ,FOID(1,2)     ,FOID(1,3)     /
     2    1.0D0         ,0.0D0         ,0.0D0         /
     3    FOID(2,1)     ,FOID(2,2)     ,FOID(2,3)     /
     4    0.0D0         ,1.0D0         ,0.0D0         /
     5    FOID(3,1)     ,FOID(3,2)     ,FOID(3,3)     /
     6    0.0D0         ,0.0D0         ,0.5D0         /
C***********************************************************************
C COMPUTE (AND STORE IN MATRIX FORM) THE DERIVATIVE dY/dX OF AN
C ISOTROPIC TENSOR FUNCTION OF THE TYPE:
C
C                        Y(X) = sum{ y(x_i) E_i }
C
C WHERE Y AND X ARE SYMMETRIC TENSORS, x_i AND E_i ARE, RESPECTIVELY
C THE EIGENVALUES AND EIGENPROJECTIONS OF X, AND y(.) IS A SCALAR
C FUNCTION. THIS ROUTINE IS RESTRICTED TO 2-D TENSORS WITH ONE
C POSSIBLE (TRANSVERSAL) OUT-OF-PLANE COMPONENT.
C
C REFERENCE: Section A.5
C***********************************************************************
C Spectral decomposition of X
      CALL SPDEC2
     1(   EIGPRJ     ,EIGX       ,REPEAT     ,X          )
C In-plane eigenvalues of Y (and derivatives)
      DO 10 IDIR=1,2
        EIGY(IDIR)=FUNC(EIGX(IDIR))
        DEIGY(IDIR)=DFUNC(EIGX(IDIR))
   10 CONTINUE
C
C In-plane components of dY/dX
C ----------------------------
      CALL RVZERO(DYDX,MCOMP*MCOMP)
      IF(REPEAT)THEN
C for repeated in-plane eigenvalues of X
        DO 20 I=1,3
          DYDX(I,I)=DEIGY(1)*FOID(I,I)
   20   CONTINUE
      ELSE
C for distinct in-plane eigenvalues of X
        A1=(EIGY(1)-EIGY(2))/(EIGX(1)-EIGX(2))
        DO 40 I=1,3
          DO 30 J=I,3
            DYDX(I,J)=A1*(FOID(I,J)-EIGPRJ(I,1)*EIGPRJ(J,1)-
     1                EIGPRJ(I,2)*EIGPRJ(J,2))+
     2                DEIGY(1)*EIGPRJ(I,1)*EIGPRJ(J,1)+
     3                DEIGY(2)*EIGPRJ(I,2)*EIGPRJ(J,2)
            IF(I.NE.J)DYDX(J,I)=DYDX(I,J)
   30     CONTINUE
   40   CONTINUE
      ENDIF
C
C Out-of-plane component required
C -------------------------------
      IF(OUTOFP)DYDX(4,4)=DFUNC(X(4))
C
      RETURN
      END
CDOC END_SUBROUTINE DISO2
