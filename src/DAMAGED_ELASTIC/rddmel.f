CDOC BEGIN_SUBROUTINE RDDMEL
CDOC Read data for damaged elastic/crack closure model.
CDOC
CDOC This routine reads from the data file and echos to the results file
CDOC the material parameters necessary for the isotropically damaged
CDOC isotropic elastic model accounting for partial microcrack/void
CDOC closure effects (quasi-unilateral conditions) under compressive
CDOC stresses.
CDOC
CDOC BEGIN_PARAMETERS
CDOC INTEGER          NTYPE  >  Stress state type flag.
CDOC DOUBLE_PRECISION RPROPS <  Array of real material properties.
CDOC LOGICAL          UNSYM  <  Unsymmetric tangent stiffness flag.
CDOC END_PARAMETERS
CHST
CHST E.de Souza Neto, July 2001: Initial coding
CHST
CHST E.de Souza Neto, October 2008: Dimensioning checks included
CHST
CHST E.de Souza Neto, April 2011: I/O error message added
CHST
      SUBROUTINE RDDMEL
     1(   NTYPE      ,MRPROP     ,MRSTAV     ,RPROPS     ,UNSYM      )
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      LOGICAL UNSYM
      PARAMETER( NRPROP=7  ,NRSTAV=4 )
      DIMENSION
     1    RPROPS(*)
      DATA R0   ,RP5  ,R1   ,R2   ,R3   /
     1     0.0D0,0.5D0,1.0D0,2.0D0,3.0D0/
C***********************************************************************
C READ AND ECHO MATERIAL PROPERTIES FOR ISOTROPICALLY DAMAGED ISOTROPIC
C ELASTIC MATERIAL MODEL WITH PARTIAL MICROCRACK/VOID CLOSURE EFFECTS
C
C REFERENCE: Section 12.6.1
C***********************************************************************
 1000 FORMAT(' DAMAGED ELASTIC material (damaged HENCKY material in',
     1       ' large strains)'/
     2       ' with partial microcrack closure effect'/)
 1010 FORMAT(
     1' Mass density ...................................... =',G15.6/
     2' Young''s modulus ................................... =',G15.6/
     3' Poisson''s ratio ................................... =',G15.6/
     4' Damage constant (D) ............................... =',G15.6/
     5' Crack closure parameter (h) ....................... =',G15.6)
C
C Check that required stress state type is implemented
C
      IF(NTYPE.NE.2.AND.NTYPE.NE.3)CALL ERRPRT('ED0173')
C
C Set unsymmetric tangent stiffness flag
C
      UNSYM=.FALSE.
C
C Read and echo material properties
C
      WRITE(16,1000)
      READ(15,*,ERR=100,END=100)DENSE
      READ(15,*,ERR=100,END=100)YOUNG,POISS
      READ(15,*,ERR=100,END=100)DAMAGE,HFACT
      WRITE(16,1010)DENSE,YOUNG,POISS,DAMAGE,HFACT
C Perform checks
      IF(YOUNG.LT.R0)CALL ERRPRT('ED0174')
      IF(POISS.LE.-R1.AND.POISS.GE.RP5)CALL ERRPRT('ED0175')
      IF(DAMAGE.LT.R0.OR.DAMAGE.GE.R1)CALL ERRPRT('ED0176')
      IF(HFACT.LT.R0.OR.HFACT.GT.R1)CALL ERRPRT('ED0177')
C
C Check dimensioning
C
      IF(NRPROP.GT.MRPROP)CALL ERRPRT('ED0193')
      IF(NRSTAV.GT.MRSTAV)CALL ERRPRT('ED0194')
C
C Set vector of real material properties
C
      GMODU=YOUNG/(R2*(R1+POISS))
      BULK=YOUNG/(R3*(R1-R2*POISS))
      RPROPS(1)=DENSE
      RPROPS(2)=YOUNG
      RPROPS(3)=POISS
      RPROPS(4)=DAMAGE
      RPROPS(5)=HFACT
      RPROPS(6)=GMODU
      RPROPS(7)=BULK
C
C Issue message and abort program execution in case of I/O error
      GOTO 200
  100 CALL ERRPRT('ED0202')
  200 CONTINUE
C
      RETURN
      END
CDOC END_SUBROUTINE RDDMEL
