CDOC BEGIN_SUBROUTINE SWDP
CDOC Initialise/switch state variables for the Drucker-Prager material
CDOC
CDOC This initialises and switches state variables (between current and
CDOC previous values) for the Drucker-Prager elasto-plastic material
CDOC model.
CDOC
CDOC BEGIN_PARAMETERS
CDOC INTEGER          MODE   >  Initialisation/Switching mode.
CDOC INTEGER          NTYPE  >  Stress state type flag.
CDOC DOUBLE_PRECISION LALGVC <> Array of logical algorithmic variables
CDOC C                          at Gauss point. Current values.
CDOC DOUBLE_PRECISION LALGVL <> Array of logical algorithmic variables
CDOC C                          at Gauss point. Last converged
CDOC C                          (equilibrium) values.
CDOC DOUBLE_PRECISION RALGVC <> Array of real algorithmic variables at
CDOC C                          Gauss point. Current values.
CDOC DOUBLE_PRECISION RSTAVC <> Array of real state variables at Gauss
CDOC C                          point. Current values.
CDOC DOUBLE_PRECISION RSTAVL <> Array of real state variables at Gauss
CDOC C                          point. Last converged (equilibrium)
CDOC C                          values.
CDOC DOUBLE_PRECISION STRESC <> Array of stress (Cauchy in large strain)
CDOC C                          components. Current values.
CDOC DOUBLE_PRECISION STRESL <> Array of stress (Cauchy in large strain)
CDOC C                          components. Last converged (equilibrium)
CDOC C                          values.
CDOC END_PARAMETERS
CHST
CHST E.de Souza Neto, July      1999: Initial coding
CHST
CHST E.de Souza Neto, October   2008: Unused arguments removed
CHST
      SUBROUTINE SWDP
     1(   MODE       ,NTYPE      ,LALGVC     ,LALGVL     ,RALGVC     ,
     2    RSTAVC     ,RSTAVL     ,STRESC     ,STRESL     )
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
C Arguments
      LOGICAL
     1    LALGVC             ,LALGVL
      DIMENSION
     1    LALGVC(*)          ,LALGVL(*)          ,RALGVC(*)          ,
     2    RSTAVC(*)          ,RSTAVL(*)          ,STRESC(*)          ,
     3    STRESL(*)
      DATA R0   /
     1     0.0D0/
C***********************************************************************
C INITIALISE/SWITCH DATA FOR THE DRUCKER-PRAGER MATERIAL MODEL
C
C    MODE=0:   Initialises the relevant data.
C
C    MODE=1:   Assigns current values of the state variables to
C              converged solution (when the current iteration
C              satisfies the convergence criterion).
C
C    MODE=2:   Assigns the last converged solution to current state
C              variables values (when a new iteration is required by
C              the iterative process).
C
C    MODE=3:   Assigns the last converged solution to current state
C              variables values (when increment cutting is required).
C***********************************************************************
C
      IF(NTYPE.EQ.1)THEN
        NSTRE=4
        NRSTAV=5
        NRALGV=3
      ELSEIF(NTYPE.EQ.2.OR.NTYPE.EQ.3)THEN
        NSTRE=4
        NRSTAV=5
        NRALGV=2
      ELSEIF(NTYPE.EQ.4)THEN  
        NSTRE=6
        NRSTAV=7
        NRALGV=2
      ENDIF
      NLALGV=3
C
      IF(MODE.EQ.0)THEN
C Initialisation mode
C ===================
        CALL RVZERO(STRESC,NSTRE)
        CALL RVZERO(RALGVC,NRALGV)
        DO 10 I=1,NLALGV
          LALGVC(I)=.FALSE.
   10   CONTINUE
C RSTAVA stores the infinitesimal egineering elastic strain tensor
C (engineering logarithmic strains in large strains) and the effective
C plastic strain
        CALL RVZERO(RSTAVC,NRSTAV)
      ELSE
C Switching modes
C ===============
        IF(MODE.EQ.1)THEN
          DO 20 I=1,NSTRE
            STRESL(I)=STRESC(I)
   20     CONTINUE
          DO 30 I=1,NRSTAV
            RSTAVL(I)=RSTAVC(I)
   30     CONTINUE
          DO 40 I=1,NLALGV
            LALGVL(I)=LALGVC(I)
   40     CONTINUE
C Zero plastic multipliers before starting a new increment
          RALGVC(1)=R0
          RALGVC(2)=R0
          IF(NTYPE.EQ.1)THEN
C Reset elastic trial thickness strain to the current (converged) value
C of the elastic thickness strain (used by the nested iteration plane
C stress algorithm only)
            RALGVC(3)=RSTAVC(4)
          ENDIF
        ELSEIF(MODE.EQ.2.OR.MODE.EQ.3)THEN
          DO 50 I=1,NSTRE
            STRESC(I)=STRESL(I)
   50     CONTINUE
          DO 60 I=1,NRSTAV
            RSTAVC(I)=RSTAVL(I)
   60     CONTINUE
          DO 70 I=1,NLALGV
            LALGVC(I)=LALGVL(I)
   70     CONTINUE
          IF(MODE.EQ.3)THEN
C Zero plastic multipliers before starting a new increment
            RALGVC(1)=R0
            RALGVC(2)=R0
            IF(NTYPE.EQ.1)THEN
C Reset elastic trial thickness strain to the last converged value of
C the elastic thickness strain (used by the nested iteration plane
C stress algorithm only)
              RALGVC(3)=RSTAVL(4)
            ENDIF
          ENDIF
        ENDIF
      ENDIF
      RETURN
      END
CDOC END_SUBROUTINE SWDP
