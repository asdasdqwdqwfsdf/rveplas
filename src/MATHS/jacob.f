CDOC BEGIN_SUBROUTINE JACOB
CDOC Jacobi procedure for spectral decomposition of a symmetric matrix
CDOC
CDOC This routine uses the Jacobi iterative procedure for the spectral
CDOC decomposition (decomposition into eigenvalues and eigenvectors)
CDOC of a symmetric matrix.
CDOC
CDOC BEGIN_PARAMETERS
CDOC DOUBLE_PRECISION A      <> Matrix to be decomposed.
CDOC DOUBLE_PRECISION D      <  Array containing eigenvalues of A.
CDOC DOUBLE_PRECISION V      <  Matrix containing one eigenvector of
CDOC C                          A in each column.
CDOC INTEGER          N      >  Dimension of A.
CDOC END_PARAMETERS
CDOC
      SUBROUTINE JACOB(A,D,V,N)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      PARAMETER (MJITER=50,NMAX=100)
      DIMENSION
     1    A(N,N)     ,D(N)      ,V(N,N)
      DIMENSION
     1    B(NMAX)    ,Z(NMAX)
      DATA R0   ,RP2  ,RP5  ,R1   ,R100   /
     1     0.0D0,0.2D0,0.5D0,1.0D0,100.0D0/
      DATA TOLER  /
     1     1.0D-12/
C***********************************************************************
C JACOBI ITERATIVE PROCEDURE FOR SPECTRAL DECOMPOSITION OF A
C N-DIMENSIONAL SYMMETRIC MATRIX
C
C REFERENCE: WH Press, SA Teukolsky, WT Vetting & BP Flannery. Numerical
C            recipes in FORTRAN: The art of scientific computing. 2nd
C            Edn., Cambridge University Press, 1992.
C***********************************************************************
      IF(N.GT.NMAX)THEN
        CALL ERRPRT('EI0025')
      ENDIF
      DO 20 IP=1,N
        DO 10 IQ=1,N
          V(IP,IQ)=R0
   10   CONTINUE
        V(IP,IP)=R1
   20 CONTINUE
      DO 30 IP=1,N
        B(IP)=A(IP,IP)
        D(IP)=B(IP)
        Z(IP)=R0
   30 CONTINUE
      DO 130 I=1,MJITER
        SM=R0
        DO 50 IP=1,N-1
          DO 40 IQ=IP+1,N
            SM=SM+ABS(A(IP,IQ))
   40     CONTINUE
   50   CONTINUE
        IF(SM.LT.TOLER)GOTO 999
        IF(I.LT.4)THEN
          TRESH=RP2*SM/DBLE(N**2)
        ELSE
          TRESH=R0
        ENDIF
        DO 110 IP=1,N-1
          DO 100 IQ=IP+1,N
            G=R100*ABS(A(IP,IQ))
            IF((I.GT.4).AND.(ABS(D(IP))+G.EQ.ABS(D(IP)))
     1         .AND.(ABS(D(IQ))+G.EQ.ABS(D(IQ))))THEN
              A(IP,IQ)=R0
            ELSE IF(ABS(A(IP,IQ)).GT.TRESH)THEN
              H=D(IQ)-D(IP)
              IF(ABS(H)+G.EQ.ABS(H))THEN
                T=A(IP,IQ)/H
              ELSE
                THETA=RP5*H/A(IP,IQ)
                T=R1/(ABS(THETA)+SQRT(R1+THETA**2))
                IF(THETA.LT.R0)T=-T
              ENDIF
              C=R1/SQRT(R1+T**2)
              S=T*C
              TAU=S/(R1+C)
              H=T*A(IP,IQ)
              Z(IP)=Z(IP)-H
              Z(IQ)=Z(IQ)+H
              D(IP)=D(IP)-H
              D(IQ)=D(IQ)+H
              A(IP,IQ)=R0
              DO 60 J=1,IP-1
                G=A(J,IP)
                H=A(J,IQ)
                A(J,IP)=G-S*(H+G*TAU)
                A(J,IQ)=H+S*(G-H*TAU)
   60         CONTINUE
              DO 70 J=IP+1,IQ-1
                G=A(IP,J)
                H=A(J,IQ)
                A(IP,J)=G-S*(H+G*TAU)
                A(J,IQ)=H+S*(G-H*TAU)
   70         CONTINUE
              DO 80 J=IQ+1,N
                G=A(IP,J)
                H=A(IQ,J)
                A(IP,J)=G-S*(H+G*TAU)
                A(IQ,J)=H+S*(G-H*TAU)
   80         CONTINUE
              DO 90 J=1,N
                G=V(J,IP)
                H=V(J,IQ)
                V(J,IP)=G-S*(H+G*TAU)
                V(J,IQ)=H+S*(G-H*TAU)
   90         CONTINUE
            ENDIF
  100     CONTINUE
  110   CONTINUE
        DO 120 IP=1,N
          B(IP)=B(IP)+Z(IP)
          D(IP)=B(IP)
          Z(IP)=R0
  120   CONTINUE
  130 CONTINUE
      CALL ERRPRT('EE0005')
  999 CONTINUE
      RETURN
      END
CDOC END_SUBROUTINE JACOB
