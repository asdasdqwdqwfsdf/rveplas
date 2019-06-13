CDOC BEGIN_SUBROUTINE CHECK2
CDOC Performs further checks on the input data.
CDOC
CDOC BEGIN_PARAMETERS
CDOC INTEGER          MXFRON <  Maximum frontwidth encountered in the
CDOC C                          solution of the linear finite element
CDOC C                          equation system.
CDOC END_PARAMETERS
      SUBROUTINE CHECK2(MXFRON)
C
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
C
C Hyplas database: Global parameters and common blocks
      INCLUDE '../MAXDIM.INC'
      INCLUDE '../MATERIAL.INC'
      INCLUDE '../ELEMENTS.INC'
      INCLUDE '../GLBDBASE.INC'
C Local array
      DIMENSION
     1    NDFRO(MELEM)
C***********************************************************************
C PERFORMS FURTHER CHECKS ON THE INPUT DATA
C***********************************************************************
 1010 FORMAT(/' Check why node',I4,' never appears')
 1020 FORMAT(//' Maximum frontwidth encountered =',I5)
      DO 10 IELEM=1,NELEM
        NDFRO(IELEM)=0
   10 CONTINUE
C Check against two identical nodal coordinates
      IREPCO=0
      DO 40 IPOIN=2,NPOIN
        KPOIN=IPOIN-1
        DO 30 JPOIN=1,KPOIN
          DO 20 IDIME=1,NDIME
            IF(COORD(IDIME,IPOIN,1).NE.COORD(IDIME,JPOIN,1))GOTO 30
   20     CONTINUE
          IREPCO=IREPCO+1
   30   CONTINUE
   40 CONTINUE
C... send warning message if there are nodes with identical coordinates
      IF(IREPCO.NE.0)CALL ERRPRT('WD0001')
C Check for invalid node numbers in connectivity list
      DO 70 IELEM=1,NELEM
        IGRUP=IGRPID(IELEM)
        IELIDN=IELTID(IGRUP)
        NNODE=IELPRP(3,IELIDN)
        DO 60 INODE=1,NNODE
          IF(LNODS(IELEM,INODE).LE.0.OR.LNODS(IELEM,INODE).GT.NPOIN)
     1    CALL ERRPRT('ED0038')
   60   CONTINUE
   70 CONTINUE
C Change the sign of the last appearance of each degree of freedom
C (only for frontal solver)
      IF(NSOLVE.EQ.1)THEN
        DO 90 IELEM=1,NELEM
          IGRUP=IGRPID(IELEM)
          IELIDN=IELTID(IGRUP)
          NNODE=IELPRP(3,IELIDN)
          DO 80 INODE=1,NNODE
            DO 75 IDOFN=2,NDOFN
              LNODS(IELEM,NNODE*(IDOFN-1)+INODE)=
     1                         LNODS(IELEM,INODE)+NPOIN*(IDOFN-1)
   75       CONTINUE
   80     CONTINUE
   90   CONTINUE
        DO 150 ITOTV=1,NTOTV
          KSTAR=0
          DO 130 IELEM=1,NELEM
            IGRUP=IGRPID(IELEM)
            IELIDN=IELTID(IGRUP)
            NNODE=IELPRP(3,IELIDN)
            KZERO=0
            DO 120 INODE=1,NNODE
              DO 110 IDOFN=1,NDOFN
                IEVAB=(IDOFN-1)*NNODE+INODE
                IPOIN=IABS(LNODS(IELEM,INODE))
                IF(MASTER(NDOFN*(IPOIN-1)+IDOFN).NE.ITOTV)GOTO 110
                KZERO=KZERO+1
                IF(KSTAR.NE.0)GOTO 100
                KSTAR=IELEM
                NDFRO(IELEM)=NDFRO(IELEM)+1
  100           CONTINUE
                LELEM=IELEM
                LEVAB=IEVAB
  110         CONTINUE
  120       CONTINUE
  130     CONTINUE
          IF(KSTAR.EQ.0)GOTO 150
          IF(LELEM.LT.NELEM)NDFRO(LELEM+1)=NDFRO(LELEM+1)-1
          LNODS(LELEM,LEVAB)=-LNODS(LELEM,LEVAB)
  150   CONTINUE
      ENDIF
      
      
C Check for any repetition of a node number within an element
      DO 200 IPOIN=1,NPOIN
        KSTAR=0
        DO 170 IELEM=1,NELEM
          IGRUP=IGRPID(IELEM)
          IELIDN=IELTID(IGRUP)
          NNODE=IELPRP(3,IELIDN)
          KZERO=0
          DO 160 INODE=1,NNODE
            IF(IABS(LNODS(IELEM,INODE)).NE.IPOIN)GOTO 160
            KZERO=KZERO+1
            IF(KZERO.GT.1)CALL ERRPRT('ED0039')
            IF(KSTAR.EQ.0)KSTAR=IELEM
  160     CONTINUE
  170   CONTINUE
C Check that coordinates for an unused node have not been specified
        IF(KSTAR.EQ.0)THEN
          WRITE(16,1010)IPOIN
          CALL ERRPRT('ED0040')
        ENDIF
  200 CONTINUE
C Calculate the largest frontwidth
      MXFRON=0
      IF(NSOLVE.EQ.1)THEN
        NFRONT=0
        DO 210 IELEM=1,NELEM
          NFRONT=NFRONT+NDFRO(IELEM)
          IF(NFRONT.GT.MXFRON)MXFRON=NFRONT
  210   CONTINUE
        WRITE(16,1020)MXFRON
        IF(MXFRON.GT.MFRON)CALL ERRPRT('ED0041')
      ENDIF
C Check data for nodes with prescribed displacements
      DO 230 IVFIX=1,NVFIX
        IF(NOFIX(IVFIX).LE.0.OR.NOFIX(IVFIX).GT.NPOIN)THEN
          CALL ERRPRT('ED0042')
        ENDIF
        KVFIX=IVFIX-1
        DO 220 JVFIX=1,KVFIX
          IF(IVFIX.NE.1.AND.NOFIX(IVFIX).EQ.NOFIX(JVFIX))THEN
            CALL ERRPRT('ED0043')
          ENDIF
  220   CONTINUE
  230 CONTINUE
      RETURN
      END
CDOC END_SUBROUTINE CHECK2
