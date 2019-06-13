CDOC BEGIN_SUBROUTINE INCREM
CDOC Increments the applied external load for fixed load increments.
CDOC
CDOC This routine increments the applied external (proportional) load,
CDOC sets the global unloading flag KUNLD and outputs the current load
CDOC increment parameters to the results output file, when HYPLAS is
CDOC running under the fixed load increments option. 
CDOC
CDOC BEGIN_PARAMETERS
CDOC INTEGER          IINCS  >  Current load increment number.
CDOC DOUBLE_PRECISION TFACT  <> Total load factor.
CDOC DOUBLE_PRECISION TOLER  <> Equilibrium convergence tolerance.
CDOC DOUBLE_PRECISION TTIME  <> Total time.
CDOC INTEGER          MITER  >  Maximum permissible number of
CDOC C                          equilibrium iterations.
CDOC INTEGER          NOUTP  >  Printing output flag.
CDOC DOUBLE_PRECISION DFACT  >  Incremental load factor.
CDOC DOUBLE_PRECISION DFOLD  <  Stores the incremental load factor of
CDOC DOUBLE_PRECISION DTIME  >  Time increment.
CDOC INTEGER          KUNLD  <  Unloading flag.
CDOC END_PARAMETERS
CDOC
      SUBROUTINE INCREM
     1(   IINCS      ,TFACT      ,TOLER      ,TTIME     ,MITER      ,
     2    NOUTP      ,DFACT      ,DFOLD      ,DTIME     ,KUNLD      )
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
C Hyplas global database
      INCLUDE '../MAXDIM.INC'
      INCLUDE '../MATERIAL.INC'
      INCLUDE '../ELEMENTS.INC'
      INCLUDE '../GLBDBASE.INC'
C Arguments
      DIMENSION NOUTP(5)
C Numerical constants
      DATA R0   ,RP01  /
     1     0.0D0,0.01D0/
C***********************************************************************
C INCREMENTS THE APPLIED EXTERNAL LOAD, SETS GLOBAL UNLOADING FLAG AND
C OUTPUTS CURRENT INCREMENT PARAMETERS TO RESULTS FILE (FOR FIXED LOAD
C INCREMENTS OPTION)
C
C REFERENCE: Figure 5.2
C***********************************************************************
 1000 FORMAT(////' INCREMENT NUMBER',I5/
     1           ' =====================')
 1010 FORMAT(//' Current time .................... = ',G15.6/
     1         ' Total load factor ............... = ',G15.6/
     2         ' Time increment .................. = ',G15.6/
     3         ' Incremental load factor ......... = ',G15.6/
     4         ' Convergence tolerence ........... = ',G15.6/
     5         ' Max. No. of iterations .......... = ',I5)
 1020 FORMAT(/ ' Output control flags for results'/
     1         '        ( 0 - No, 1 - Yes )',/,
     2         ' Displacements...................... = ',I3/
     3         ' Reactions.......................... = ',I3/
     4         ' State variables at gauss points.... = ',I3/
     5         ' State variables at nodes........... = ',I3/
     6         ' Output to re-start file............ = ',I3)
C
C Output current increment parameters to results file
C ---------------------------------------------------
C
c      WRITE(16,1000)IINCS
C
      IF(TOLER.EQ.R0)TOLER=RP01
      TFACT=TFACT+DFACT
      TTIME=TTIME+DTIME
C
c      WRITE(16,1010)TTIME,TFACT,DTIME,DFACT,TOLER,MITER
c      WRITE(16,1020)(NOUTP(I),I=1,5)
C
C Increment forces
C ----------------
C New out-of-balance force := out-of-balance force at the end of the
C previous (converged) load increment + current external load increment
      DO 20 IELEM=1,NELEM
        IGRUP =IGRPID(IELEM)
        IELIDN=IELTID(IGRUP)
        NEVAB =IELPRP(5,IELIDN)
        DO 10 IEVAB=1,NEVAB
          ELOAD(IEVAB,IELEM)=ELOAD(IEVAB,IELEM)+RLOAD(IEVAB,IELEM)*DFACT
   10   CONTINUE
   20 CONTINUE
C
C Increment prescribed displacements
C ----------------------------------
C
      DO 40 ITOTV=1,NTOTV
        DO 30 IRHS=1,2
          FIXED(ITOTV,IRHS)=R0
   30   CONTINUE
   40 CONTINUE
      DO 60 IVFIX=1,NVFIX
        NLOCA=(NOFIX(IVFIX)-1)*NDOFN
        DO 50 IDOFN=1,NDOFN
          NGASH=NLOCA+IDOFN
          FIXED(NGASH,1)=PRESC(IVFIX,IDOFN)*DFACT
   50   CONTINUE
   60 CONTINUE
C
C Set unloading (load reversal) global flag
C -----------------------------------------
C
      KUNLD=0
      IF(IINCS.GT.1)THEN
        IF((DFOLD*DFACT).LT.R0)KUNLD=1
      ENDIF
      DFOLD=DFACT
C
      RETURN
      END
CDOC END_SUBROUTINE INCREM
