CDOC BEGIN_SUBROUTINE RDDP
CDOC Read data for the Drucker-Prager material model.
CDOC
CDOC This routine reads from the data file and echos to the results
CDOC file the material parameters necessary for the
CDOC Drucker-Prager elasto-plastic model with piece-wise linear
CDOC isotropic hardening.
CDOC It also sets the array of real properties and some components of
CDOC the array of integer material properties. These arrays are used by
CDOC subroutines SUDP and CTDP.
CDOC It also sets the unsymmetric tangent stiffness flag.
CDOC
CDOC BEGIN_PARAMETERS
CDOC INTEGER          IPROPS <  Array of integer material properties.
CDOC INTEGER          MIPROP >  Dimension of the global array of integer
CDOC C                          material properties.
CDOC INTEGER          MLALGV >  Dimension of the global array of logical
CDOC C                          algorithmic variables.
CDOC DOUBLE_PRECISION MRALGV >  Dimension of the global array of real
CDOC C                          algorithmic variables.
CDOC INTEGER          MRPROP >  Dimension of the global array of real
CDOC C                          material variables.
CDOC INTEGER          MRSTAV >  Dimension of the global array of real
CDOC C                          state variables.
CDOC DOUBLE_PRECISION RPROPS <  Array of real material properties.
CDOC LOGICAL          UNSYM  <  Unsymmetric tangent stiffness flag.
CDOC END_PARAMETERS
CHST
CHST E.de Souza Neto, June 1996: Initial coding
CHST
CHST E.de Souza Neto, October 2008: Dimensioning checks included
CHST
CHST E.de Souza Neto, April 2011: I/O error message added
CHST
      SUBROUTINE RDDP
     1(   IPROPS     ,MIPROP     ,MLALGV     ,MRALGV     ,MRPROP     ,
     2    MRSTAV     ,RPROPS     ,UNSYM      )
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      LOGICAL UNSYM
      PARAMETER( IPHARD=7  ,NIPROP=3  ,NLALGV=3  ,NRALGV=3  ,NRSTAV=7 )
      DIMENSION
     1    IPROPS(*)          ,RPROPS(*)
      DATA R0   ,R1   ,R2   ,R3   ,R6   ,R9   ,R12   ,R90   ,R180   / 
     1     0.0D0,1.0D0,2.0D0,3.0D0,6.0D0,9.0D0,12.0D0,90.0D0,180.0D0/
C***********************************************************************
C READ AND ECHO MATERIAL PROPERTIES FOR DRUCKER-PRAGER TYPE
C ELASTO-PLASTIC MATERIAL WITH ASSOCIATIVE/NON-ASSOCIATIVE FLOW
C RULE AND NON-LINEAR ISOTROPIC HARDENING
C
C REFERENCE:  Section 8.3
C***********************************************************************
 1000 FORMAT(' Elasto-plastic with DRUCKER-PRAGER yield criterion'/)
 1100 FORMAT(
     1' Mass density ...................................... =',G15.6/
     2' Young''s modulus ................................... =',G15.6/
     3' Poisson''s ratio ................................... =',G15.6/
     4' Friction angle  (degrees) ......................... =',G15.6/
     5' Dilatancy angle (degrees) ......................... =',G15.6)
 1200 FORMAT(/
     1'  Friction and dilatancy angles coincide ->',
     2 ' ASSOCIATIVE flow')
 1300 FORMAT(/
     1'  Friction and dilatancy angles are distinct ->',
     2 ' NON-ASSOCIATIVE flow')
 1350 FORMAT(/
     1'  OUTER EDGES match with Mohr-Coulomb criterion selected')
 1360 FORMAT(/
     1'  INNER EDGES match with Mohr-Coulomb criterion selected')
 1370 FORMAT(/
     1'  PLANE STRAIN match with Mohr-Coulomb criterion selected')
 1380 FORMAT(/
     1'  UNIAXIAL COMPRESSION and UNIAXIAL TENSION match with',/,
     2'  Mohr-Coulomb criterion selected')
 1390 FORMAT(/
     1'  BIAXIAL COMPRESSION and BIAXIAL TENSION match with',/,
     2'  Mohr-Coulomb criterion selected')
 1400 FORMAT(/
     1' Number of points on hardening curve ............... =',I3//
     2'           Epstn            cohesion'/)
 1500 FORMAT(2(5X,G15.6))
C
C Read and echo some of the real properties
      WRITE(16,1000)
      READ(15,*,ERR=100,END=100)DENSE
      READ(15,*,ERR=100,END=100)YOUNG,POISS,PHI,PSI,IFLAG
      WRITE(16,1100)DENSE,YOUNG,POISS,PHI,PSI
C Check validity if some material properties
      IF(YOUNG.LT.R0)THEN
        CALL ERRPRT('ED0114')
      ENDIF
      IF(PHI.LT.R0.OR.PHI.GE.R90.OR.PSI.LT.R0.OR.PSI.GE.R90)THEN
        CALL ERRPRT('ED0115')
      ENDIF
C Check friction and dilatancy angles
      IF(PHI.EQ.PSI)THEN
        WRITE(16,1200)
      ELSE
        WRITE(16,1300)
      ENDIF
C Echo selected approximation of Mohr-Coulomb criterion
C and set related material constants
      ROOT3=SQRT(R3)
      RADEG=ACOS(-R1)/R180
      PHIRAD=PHI*RADEG
      SINPHI=SIN(PHIRAD)
      COSPHI=COS(PHIRAD)
      TANPHI=TAN(PHIRAD)
      PSIRAD=PSI*RADEG
      SINPSI=SIN(PSIRAD)
      TANPSI=TAN(PSIRAD)
      IF(IFLAG.EQ.0)THEN
C Outer edge match with Mohr-Coulomb criterion
        WRITE(16,1350)
        DENOMA=ROOT3*(R3-SINPHI)
        DENOMB=ROOT3*(R3-SINPSI)
        ETA=R6*SINPHI/DENOMA
        XI=R6*COSPHI/DENOMA
        ETABAR=R6*SINPSI/DENOMB
      ELSEIF(IFLAG.EQ.1)THEN
C Inner edge match with Mohr-Coulomb criterion
        WRITE(16,1360)
!         DENOMA=ROOT3*(R3+SINPHI)
!         DENOMB=ROOT3*(R3+SINPSI)
!         ETA=R6*SINPHI/DENOMA
!         XI=R6*COSPHI/DENOMA
!         ETABAR=R6*SINPSI/DENOMB
        XI=1
        ETA=TANPHI/ROOT3
        ETABAR=TANPSI/ROOT3
       
       
      ELSEIF(IFLAG.EQ.2)THEN
C Plane strain match with Mohr-Coulomb criterion
        WRITE(16,1370)
        DENOMA=SQRT(R9+R12*TANPHI**2)
        DENOMB=SQRT(R9+R12*TANPSI**2)
        ETA=R3*TANPHI/DENOMA
        XI=R3/DENOMA
        ETABAR=R3*TANPSI/DENOMB
      ELSEIF(IFLAG.EQ.3)THEN
C Match Mohr-Coulomb criterion in uniaxial compression and uniaxial
C tension
        WRITE(16,1380)
        ETA=R3*SINPHI/ROOT3
        XI=R2*COSPHI/ROOT3
        ETABAR=R3*SINPSI/ROOT3
      ELSEIF(IFLAG.EQ.4)THEN
C Match Mohr-Coulomb criterion in biaxial compression and biaxial
C tension
        WRITE(16,1390)
        ETA=R3*SINPHI/(R2*ROOT3)
        XI=R2*COSPHI/ROOT3
        ETABAR=R3*SINPSI/(R2*ROOT3)
      ELSE
        CALL ERRPRT('ED0116')
      ENDIF
C Hardening curve
      READ(15,*,ERR=100,END=100)NHARD
      WRITE(16,1400)NHARD
      IF(NHARD.LT.2)THEN
        CALL ERRPRT('ED0117')
      ENDIF
C Check dimensions of IPROPS
      IF(MIPROP.LT.NIPROP)CALL ERRPRT('ED0189')
      IPROPS(3)=NHARD
C Check dimensions of RPROPS
      NRPROP=IPHARD+NHARD*2-1
      IF(NRPROP.GT.MRPROP)CALL ERRPRT('ED0188')
C Store real properties in RPROPS
      RPROPS(1)=DENSE
      RPROPS(2)=YOUNG
      RPROPS(3)=POISS
      RPROPS(4)=ETA
      RPROPS(5)=XI
      RPROPS(6)=ETABAR
      DO 10 IHARD=1,NHARD
        READ(15,*,ERR=100,END=100)RPROPS(IPHARD+IHARD*2-2),
     1                            RPROPS(IPHARD+IHARD*2-1)
        WRITE(16,1500)RPROPS(IPHARD+IHARD*2-2),
     1                RPROPS(IPHARD+IHARD*2-1)
   10 CONTINUE
C
C Check dimension of RSTAVA, LALGVA and RALGVA
C
      IF(NRSTAV.GT.MRSTAV)CALL ERRPRT('ED0190')
      IF(NLALGV.GT.MLALGV)CALL ERRPRT('ED0191')
      IF(NRALGV.GT.MRALGV)CALL ERRPRT('ED0192')
C
C Set unsymmetric tangent stiffness flag
      IF(PHI.EQ.PSI)THEN
        UNSYM=.FALSE.
      ELSE
        UNSYM=.TRUE.
      ENDIF
C
      GOTO 200
C Issue message and abort program execution in case of I/O error
  100 CALL ERRPRT('ED0203')
C
  200 CONTINUE
      RETURN
      END
CDOC END_SUBROUTINE RDDP
