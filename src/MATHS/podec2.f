CDOC BEGIN_SUBROUTINE PODEC2
CDOC Polar decomposition of 2-D tensors
CDOC
CDOC This routine performs the right polar decomposition of 2-D
CDOC tensors:   F = R U, where R is a rotation (orthogonal tensor)
CDOC and U is a symmetric tensor.
CDOC 
CDOC BEGIN_PARAMETERS
CDOC DOUBLE_PRECISION F      >  2-D tensor to be decomposed.
CDOC C                          Dimension 2x2.
CDOC DOUBLE_PRECISION R      <  Rotation matrix resulting from the polar
CDOC C                          decomposition. Dimension 2x2.
CDOC DOUBLE_PRECISION U      <  Right symmetric tensor resulting from
CDOC C                          the polar decomposition. Dimension 2x2.
CDOC END_PARAMETERS
CHST
CHST E.de Souza Neto, November 1998: Initial coding
CHST
      SUBROUTINE PODEC2
     1(   F          ,R          ,U          )
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      PARAMETER
     1(   NDIM=2     )
C Arguments
      DIMENSION
     1    F(NDIM,NDIM)       ,R(NDIM,NDIM)       ,U(NDIM,NDIM)
C Local variables and arrays
      LOGICAL DUMMY
      DIMENSION
     1    C(NDIM,NDIM)       ,CVEC(4)            ,EIGPRJ(4,NDIM)     ,
     2    EIGC(NDIM)         ,UM1(NDIM,NDIM)     ,UM1VEC(3)          ,
     3    UVEC(3)
      DATA
     1    R1   /
     2    1.0D0/
C***********************************************************************
C PERFORMS THE RIGHT POLAR DECOMPOSITION OF A 2-D TENSOR
C
C REFERENCE: Section 2.2.9
C***********************************************************************
C                T
C Compute  C := F  F
C -------------------
      CALL RVZERO(C,NDIM*NDIM)
      DO 30 I=1,NDIM
        DO 20 J=1,NDIM
          DO 10 K=1,NDIM
            C(I,J)=C(I,J)+F(K,I)*F(K,J)
   10     CONTINUE
   20   CONTINUE
   30 CONTINUE
C Perform spectral decomposition of C
C -----------------------------------
      CVEC(1)=C(1,1)
      CVEC(2)=C(2,2)
      CVEC(3)=C(1,2)
      CALL SPDEC2(EIGPRJ     ,EIGC       ,DUMMY      ,CVEC       )
C
C                 1/2         -1
C Compute  U := (C)    and   U
C ------------------------------
C assemble in vector form
      CALL RVZERO(UVEC,3)
      CALL RVZERO(UM1VEC,3)
      DO 50 IDIM=1,NDIM
        UEIG=SQRT(EIGC(IDIM))
        UM1EIG=R1/UEIG
        DO 40 ICOMP=1,3
          UVEC(ICOMP)=UVEC(ICOMP)+UEIG*EIGPRJ(ICOMP,IDIM)
          UM1VEC(ICOMP)=UM1VEC(ICOMP)+UM1EIG*EIGPRJ(ICOMP,IDIM)
   40   CONTINUE
   50 CONTINUE
C and matrix form
      U(1,1)=UVEC(1)
      U(2,2)=UVEC(2)
      U(1,2)=UVEC(3)
      U(2,1)=UVEC(3)
      UM1(1,1)=UM1VEC(1)
      UM1(2,2)=UM1VEC(2)
      UM1(1,2)=UM1VEC(3)
      UM1(2,1)=UM1VEC(3)
C                           -1
C Compute rotation  R := F U
C ----------------------------
      CALL RVZERO(R,NDIM*NDIM)
      DO 80 I=1,NDIM
        DO 70 J=1,NDIM
          DO 60 K=1,NDIM
            R(I,J)=R(I,J)+F(I,K)*UM1(K,J)
   60     CONTINUE
   70   CONTINUE
   80 CONTINUE
C
      RETURN
      END
CDOC END_SUBROUTINE PODEC2
