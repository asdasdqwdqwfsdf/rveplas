CDOC BEGIN_SUBROUTINE FRONT
CDOC Frontal solver
CDOC
CDOC Assembles and solves the global system of linear algebraic finite
CDOC element equilibrium equations by the frontal method. For non-linear
CDOC problems, assembles and solves the corresponding linearised (or
CDOC approximately linearised system of) equations.
CDOC
CDOC BEGIN_PARAMETERS
CDOC DOUBLE_PRECISION DTIME  >  Time increment.
CDOC INTEGER          IITER  >  Current equilibrium iteration number.
CDOC INTEGER          KRESL  >  Equation resolution index.
CDOC INTEGER          IFNEG  <  Signum (+1/-1) of the determinant of the
CDOC C                          stiffness matrix.
CDOC INTEGER          KUNLD  <> Unloading flag.
CDOC DOUBLE_PRECISION MXFRON >  Maximum frontwidth encountered in the
CDOC C                          system of linear finite element
CDOC C                          equations.
CDOC LOGICAL          UNSYM  >  Stiffness matrix unsymmetry flag.
CDOC LOGICAL          INCCUT <  Load increment cutting flag.
CDOC END_PARAMETERS
CDOC
      SUBROUTINE FRONT
     1(   DTIME      ,IITER      ,KRESL     ,IFNEG      ,KUNLD      ,
     2    MXFRON     ,UNSYM      ,INCCUT    )
C
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
C Hyplas global database
      INCLUDE '../../MAXDIM.INC'
      INCLUDE '../../MATERIAL.INC'
      INCLUDE '../../ELEMENTS.INC'
      INCLUDE '../../GLBDBASE.INC'
C Common block of arrays used only by the frontal solver. This common
C block is firstly defined in HYPLAS main program
      COMMON / FRONTA /
     1    EQRHS(MTOTV,2)     ,EQROW(MFRON,MTOTV) ,EQCOL(MFRON,MTOTV) ,
     2    DECAY(MFRON)       ,GLOAD(MFRON,2)     ,VECRV(MFRON,2)     ,
     3    LOCEL(MEVAB,MELEM) ,NACVA(MFRON,MELEM) ,NAMEV(MTOTV)       ,
     4    NDEST(MEVAB,MELEM) ,NPIVO(MTOTV)       ,NFRON(MELEM)
C Arguments
      LOGICAL UNSYM, INCCUT
C Local arrays and variables
      DIMENSION
     1    ESTIF(MEVAB,MEVAB)
      DIMENSION
     1    GSTIF(MFRON*MFRON),LACVA(MFRON)
C Numerical constants
      DATA R0,R2,E5,E10/0.0D0,2.0D0,1.0D5,1.0D10/
C***********************************************************************
C ASSEMBLES AND SOLVES THE GLOBAL SYSTEM OF LINEAR ALGEBRAIC FINITE
C ELEMENT EQUILIBRIUM EQUATIONS (LINEARISED EQUILIBRIUM EQUATIONS FOR
C NON-LINEAR PROBLEMS) BY THE FRONTAL METHOD
C
C REFERENCE: Section 5.4.4
C***********************************************************************
 1010 FORMAT(//' Zero pivot encountered for variable no.',
     1I5,' of value',G14.6/)
 1020 FORMAT(//' *** WARNING ***'/' Diagonal decay of',G14.6,
     1' for variable no.',I5/
     2' probable mechanism or flying structure'//)
 1030 FORMAT(//' *** WARNING ***'/' Diagonal decay of',G14.6,
     1' for variable no.',I5/
     2' roundoff errors likely'//)
C Initialise increment cutting flag
      INCCUT=.FALSE.
C Decide solution required
      IF(NALGO.LT.0.AND.IITER.EQ.1.AND.KRESL.EQ.2)THEN
        NRHS=0
        MODE=0
      ELSE IF(NALGO.LT.0.AND.IITER.EQ.1.AND.KRESL.EQ.1)THEN
        NRHS=1
        MODE=2
      ELSE IF(NALGO.LT.0.AND.IITER.GT.1.AND.KRESL.EQ.1)THEN
        NRHS=2
        MODE=3
      ELSE IF(NALGO.LT.0.AND.IITER.GT.1.AND.KRESL.EQ.2)THEN
        NRHS=1
        MODE=1
      ELSE
        NRHS=1
        MODE=1
      ENDIF
      IF(MODE.EQ.0)GOTO 900
C Frontal stiffness (GSTIF)
C Start by initializing everything that matters to zero
      IF(IITER.GT.1)KUNLD=0
      IF(KRESL.EQ.1)THEN
        IF(.NOT.UNSYM)THEN
          MSTIF=(MXFRON*(MXFRON+1))/2
          DO 150 ISTIF=1,MSTIF
            GSTIF(ISTIF)=R0
  150     CONTINUE
        ENDIF
      ENDIF
      DO 160 IFRON=1,MXFRON
        DO 152 IRHS=1,NRHS
          GLOAD(IFRON,IRHS)=R0
          VECRV(IFRON,IRHS)=R0
  152   CONTINUE
        IF(KRESL.EQ.1)THEN
          DECAY(IFRON)=R0
          IF(UNSYM)THEN
            DO 155 JFRON=1,MXFRON
            GSTIF((IFRON-1)*MXFRON+JFRON)=R0
  155       CONTINUE
          ENDIF
          DO 156 IBUFA=1,NTOTV
            EQROW(IFRON,IBUFA)=R0
            EQCOL(IFRON,IBUFA)=R0
  156     CONTINUE
        ENDIF
  160 CONTINUE
      IF(KRESL.EQ.1)IFNEG=1
      NBUFA=0
      NVARB=0
C
C Main element assembly-reduction loop
C ====================================
      KELVA=0
      DO 320 IELEM=1,NELEM
      IGRUP=IGRPID(IELEM)
      IELIDN=IELTID(IGRUP)
      NNODE=IELPRP(3,IELIDN)
      NEVAB=IELPRP(5,IELIDN)
      IF(KRESL.GT.1) GOTO 400
      IF(IELEM.EQ.1)THEN
        NFRON(IELEM)=0
        DO 161 IFRON=1,MXFRON
          NACVA(IFRON,IELEM)=0
  161   CONTINUE
      ELSE
        NFRON(IELEM)=NFRON(IELEM-1)
        DO 162 IFRON=1,MXFRON
          NACVA(IFRON,IELEM)=LACVA(IFRON)
  162   CONTINUE
      ENDIF
C
C Call element interface routine for computation of element stiffness
C -------------------------------------------------------------------
      CALL ELEIST
     1(   DTIME      ,ESTIF      ,IELEM      ,KUNLD      ,UNSYM      )
C
C transform the stiffness matrix into the local nodal coordinate system
C for prescribed displacements at an angle (for 2-D only)
      DO 168 INODE=1,NNODE
        LNODE=IABS(LNODS(IELEM,INODE))
        DO 167 IVFIX=1,NVFIX
          IF(NOFIX(IVFIX).EQ.LNODE)THEN
            IF(ANGLE(IVFIX).EQ.R0)GOTO 168
            C=COS(ANGLE(IVFIX))
            S=SIN(ANGLE(IVFIX))
            IEVAB=(INODE-1)*NDOFN+1
            JEVAB=IEVAB+1
            DO 165 KEVAB=1,NEVAB
              GASHI= C*ESTIF(IEVAB,KEVAB)+S*ESTIF(JEVAB,KEVAB)
              GASHJ=-S*ESTIF(IEVAB,KEVAB)+C*ESTIF(JEVAB,KEVAB)
              ESTIF(IEVAB,KEVAB)=GASHI
              ESTIF(JEVAB,KEVAB)=GASHJ
  165       CONTINUE
            DO 166 KEVAB=1,NEVAB
              GASHI= ESTIF(KEVAB,IEVAB)*C+ESTIF(KEVAB,JEVAB)*S
              GASHJ=-ESTIF(KEVAB,IEVAB)*S+ESTIF(KEVAB,JEVAB)*C
              ESTIF(KEVAB,IEVAB)=GASHI
              ESTIF(KEVAB,JEVAB)=GASHJ
  166       CONTINUE
            GOTO 168
          ENDIF
  167   CONTINUE
  168 CONTINUE
C
      DO 175 INODE=1,NNODE
        DO 170 IDOFN=1,NDOFN
          IEVAB=(IDOFN-1)*NNODE+INODE
          NPOSI=(INODE-1)*NDOFN+IDOFN
          IPOIN=IABS(LNODS(IELEM,INODE))
          LOCEL(NPOSI,IELEM)=
     1        SIGN(MASTER(NDOFN*(IPOIN-1)+IDOFN),LNODS(IELEM,IEVAB))
  170   CONTINUE
  175 CONTINUE
C
C Start by looking for existing destinations
      KEVAB=0
      DO 210 IEVAB=1,NEVAB
        NIKNO=IABS(LOCEL(IEVAB,IELEM))
        KEXIS=0
        DO 180 IFRON=1,NFRON(IELEM)
          IF(NIKNO.NE.NACVA(IFRON,IELEM)) GOTO 180
          KEVAB=KEVAB+1
          KEXIS=1
          NDEST(KEVAB,IELEM)=IFRON
  180   CONTINUE
        IF(KEXIS.NE.0) GOTO 210
C
C Now seek new empty places for destination vector
        DO 190 IFRON=1,MXFRON
          IF(NACVA(IFRON,IELEM).NE.0) GOTO 190
          NACVA(IFRON,IELEM)=NIKNO
          KEVAB=KEVAB+1
          NDEST(KEVAB,IELEM)=IFRON
          GOTO 200
  190   CONTINUE
C
C The new places may demand an increase in current frontwidth
  200   IF(NDEST(KEVAB,IELEM).GT.NFRON(IELEM)) NFRON(IELEM)=
     1                                         NDEST(KEVAB,IELEM)
  210 CONTINUE
  400 CONTINUE
      LFRON=NFRON(IELEM)
      DO 205 IFRON=1,MXFRON
        LACVA(IFRON)=NACVA(IFRON,IELEM)
  205 CONTINUE
C Assemble element loads in local nodal coordinate system if node has
C prescribed displacements at an angle (for 2-D only)
      DO 215 INODE=1,NNODE
        IEVAB=(INODE-1)*NDOFN
        LNODE=IABS(LNODS(IELEM,INODE))
        DO 211 IVFIX=1,NVFIX
          IF(NOFIX(IVFIX).EQ.LNODE.AND.ANGLE(IVFIX).NE.R0)THEN
            C=COS(ANGLE(IVFIX))
            S=SIN(ANGLE(IVFIX))
            IEVAB=IEVAB+1
            JEVAB=IEVAB+1
            IDEST=NDEST(IEVAB,IELEM)
            JDEST=NDEST(JEVAB,IELEM)
            IF(MODE.EQ.1)THEN
              GLOAD(IDEST,1)=GLOAD(IDEST,1)+
     1                       C*ELOAD(IEVAB,IELEM)+S*ELOAD(JEVAB,IELEM)
              GLOAD(JDEST,1)=GLOAD(JDEST,1)-
     1                       S*ELOAD(IEVAB,IELEM)+C*ELOAD(JEVAB,IELEM)
            ELSE IF(MODE.EQ.2)THEN
              GLOAD(IDEST,1)=GLOAD(IDEST,1)+
     1                       C*RLOAD(IEVAB,IELEM)+S*RLOAD(JEVAB,IELEM)
              GLOAD(JDEST,1)=GLOAD(JDEST,1)-
     1                       S*RLOAD(IEVAB,IELEM)+C*RLOAD(JEVAB,IELEM)
            ELSE IF(MODE.EQ.3)THEN
              GLOAD(IDEST,1)=GLOAD(IDEST,1)+
     1                       C*RLOAD(IEVAB,IELEM)+S*RLOAD(JEVAB,IELEM)
              GLOAD(JDEST,1)=GLOAD(JDEST,1)-
     1                       S*RLOAD(IEVAB,IELEM)+C*RLOAD(JEVAB,IELEM)
              GLOAD(IDEST,2)=GLOAD(IDEST,2)+
     1                       C*ELOAD(IEVAB,IELEM)+S*ELOAD(JEVAB,IELEM)
              GLOAD(JDEST,2)=GLOAD(JDEST,2)-
     1                       S*ELOAD(IEVAB,IELEM)+C*ELOAD(JEVAB,IELEM)
            ENDIF
            GOTO 215
          ENDIF
  211   CONTINUE
        DO 212 IDOFN=1,NDOFN
          IEVAB=IEVAB+1
          IDEST=NDEST(IEVAB,IELEM)
          IF(MODE.EQ.1)THEN
            GLOAD(IDEST,1)=GLOAD(IDEST,1)+ELOAD(IEVAB,IELEM)
          ELSE IF(MODE.EQ.2)THEN
            GLOAD(IDEST,1)=GLOAD(IDEST,1)+RLOAD(IEVAB,IELEM)
          ELSE IF(MODE.EQ.3)THEN
            GLOAD(IDEST,1)=GLOAD(IDEST,1)+RLOAD(IEVAB,IELEM)
            GLOAD(IDEST,2)=GLOAD(IDEST,2)+ELOAD(IEVAB,IELEM)
          ENDIF
  212   CONTINUE
  215 CONTINUE
C
C Assemble the element stiffnesses - but not in resolution
      IF(KRESL.GT.1) GOTO 402
      DO 220 IEVAB=1,NEVAB
        IDEST=NDEST(IEVAB,IELEM)
        IF(UNSYM)THEN
          LEVAB=NEVAB
        ELSE
          LEVAB=IEVAB
        ENDIF
        DO 222 JEVAB=1,LEVAB
          JDEST=NDEST(JEVAB,IELEM)
          IF(UNSYM)THEN
            NGESH=(IDEST-1)*MXFRON+JDEST
          ELSE
            IF((IDEST.EQ.JDEST).AND.(IEVAB.NE.JEVAB))
     1        ESTIF(IEVAB,JEVAB)=R2*ESTIF(IEVAB,JEVAB)
            NGASH=NFUNC(IDEST,JDEST)
            NGISH=NFUNC(JDEST,IDEST)
            IF(JDEST.GE.IDEST)NGESH=NGASH
            IF(JDEST.LT.IDEST)NGESH=NGISH
          ENDIF
          GSTIF(NGESH)=GSTIF(NGESH)+ESTIF(IEVAB,JEVAB)
  222   CONTINUE
C If diagonal term modified evaluate contribution to diagonal decay
        DECAY(IDEST)=DECAY(IDEST)+GSTIF(NGESH)*GSTIF(NGESH)
  220 CONTINUE
  402 CONTINUE
C
C Re-examine each element node, to enquire which can be eliminated
      DO 310 IEVAB=1,NEVAB
      NIKNO=-LOCEL(IEVAB,IELEM)
      IF(NIKNO.LE.0) GOTO 310
C
C Find positions of variables ready for elimination
      DO 300 IFRON=1,LFRON
        IF(LACVA(IFRON).NE.NIKNO) GOTO 300
        NBUFA=NBUFA+1
        NVARB=NVARB+1
C
C Extract the coefficients of the new equation for elimination
        IF(KRESL.GT.1) GOTO 404
        DO 230 JFRON=1,MXFRON
          IF(UNSYM)THEN
            NLOCA=(IFRON-1)*MXFRON+JFRON
          ELSE
            IF(IFRON.LT.JFRON) NLOCA=NFUNC(IFRON,JFRON)
            IF(IFRON.GE.JFRON) NLOCA=NFUNC(JFRON,IFRON)
          ENDIF
          EQROW(JFRON,NBUFA)=GSTIF(NLOCA)
          GSTIF(NLOCA)=R0
          IF(UNSYM)THEN
            NLOCA=(JFRON-1)*MXFRON+IFRON
            EQCOL(JFRON,NBUFA)=GSTIF(NLOCA)
            GSTIF(NLOCA)=R0
          ENDIF
  230   CONTINUE
  404   CONTINUE
C
C ...and extract the corresponding right hand sides
        DO 235 IRHS=1,NRHS
          EQRHS(NVARB,IRHS)=GLOAD(IFRON,IRHS)
          GLOAD(IFRON,IRHS)=R0
  235   CONTINUE
        KELVA=KELVA+1
        NAMEV(NVARB)=NIKNO
        NPIVO(NVARB)=IFRON
C
C Deal with pivot
        PIVOT=EQROW(IFRON,NBUFA)
        IF(KRESL.EQ.1.AND.PIVOT.LT.R0)THEN
          IFNEG=-1*IFNEG
        ENDIF
C
C Enquire whether present variable is free or prescribed
        IF(IFFIX(NIKNO).EQ.0) GOTO 250
C
C Deal with a prescribed nodal displacement
        DO 240 JFRON=1,LFRON
          IF(JFRON.EQ.IFRON)GOTO 240
          IF(.NOT.UNSYM)EQCOL(JFRON,NBUFA)=EQROW(JFRON,NBUFA)
          DO 237 IRHS=1,NRHS
            GLOAD(JFRON,IRHS)=GLOAD(JFRON,IRHS)-
     1                        FIXED(NIKNO,IRHS)*EQCOL(JFRON,NBUFA)
  237     CONTINUE
  240   CONTINUE
        GOTO 280
C
C Eliminate a free variable - Deal with the right hand side first
  250   CONTINUE
        IF(KRESL.EQ.1)THEN
          IF(PIVOT.EQ.R0)THEN
            WRITE(16,1010) NIKNO,PIVOT
            CALL ERRPRT('WE0008')
            INCCUT=.TRUE.
            GOTO 900
          ENDIF
C Check diagonal decay
          DECAY(IFRON)=SQRT(DECAY(IFRON))/PIVOT
          IF(ABS(DECAY(IFRON)).GE.E10)THEN
C Print warning of mechanism or flying structure
            WRITE(16,1020)DECAY(IFRON),NIKNO
          ELSE IF(ABS(DECAY(IFRON)).GE.E5)THEN
C Print warning of roundoff errors
            WRITE(16,1030)DECAY(IFRON),NIKNO
          ENDIF
        ENDIF
        DO 270 JFRON=1,LFRON
          IF(JFRON.EQ.IFRON)GOTO 270
          IF(.NOT.UNSYM)EQCOL(JFRON,NBUFA)=EQROW(JFRON,NBUFA)
          DO 255 IRHS=1,NRHS
            GLOAD(JFRON,IRHS)=GLOAD(JFRON,IRHS)-EQCOL(JFRON,NBUFA)*
     1                                          EQRHS(NVARB,IRHS)/PIVOT
  255     CONTINUE
C
C Now deal with the coefficients in core
          IF(KRESL.GT.1) GOTO 418
          IF(EQCOL(JFRON,NBUFA).EQ.R0) GOTO 270
          CUREQ=EQCOL(JFRON,NBUFA)
          IF(UNSYM)THEN
            NJFRON=LFRON
          ELSE
            NLOCA=NFUNC(0,JFRON)
            NJFRON=JFRON
          ENDIF
          DO 260 KFRON=1,NJFRON
            IF(KFRON.EQ.IFRON)GOTO 260
            IF(UNSYM)THEN
              NGASH=(JFRON-1)*MXFRON+KFRON
            ELSE
              NGASH=KFRON+NLOCA
            ENDIF
            GSTIF(NGASH)=GSTIF(NGASH)-CUREQ*EQROW(KFRON,NBUFA)/PIVOT
  260     CONTINUE
C If diagonal term modified evaluate contribution to diagonal decay
          DECAY(JFRON)=DECAY(JFRON)+GSTIF(NGASH)*GSTIF(NGASH)
  418     CONTINUE
  270   CONTINUE
  280   CONTINUE
C
C Record the new vacant space, and reduce frontwidth if possible
        LACVA(IFRON)=0
C Initialize diagonal decay
        DECAY(IFRON)=R0
        GOTO 290
C
C Complete the element loop in the forward elimination
C
  300 CONTINUE
  290 IF(LACVA(LFRON).NE.0) GOTO 310
      LFRON=LFRON-1
      IF(LFRON.GT.0) GOTO 290
  310 CONTINUE
  320 CONTINUE
C
C Back-substitution phase. Loop backwards through variables
C =========================================================
      DO 340 IELVA=1,KELVA
C
C Prepare to back-substitute from the current equation
        IFRON=NPIVO(NVARB)
        NIKNO=NAMEV(NVARB)
        PIVOT=EQROW(IFRON,NBUFA)
        DO 325 IRHS=1,NRHS
          IF(IFFIX(NIKNO).NE.0) VECRV(IFRON,IRHS)=FIXED(NIKNO,IRHS)
  325   CONTINUE
        IF(IFFIX(NIKNO).EQ.0)SEQROW=EQROW(IFRON,NBUFA)
        IF(IFFIX(NIKNO).EQ.0)EQROW(IFRON,NBUFA)=R0
C
C Back-substitute in the current equation
        DO 331 JFRON=1,MXFRON
          DO 330 IRHS=1,NRHS
            EQRHS(NVARB,IRHS)=EQRHS(NVARB,IRHS)-
     1                        VECRV(JFRON,IRHS)*EQROW(JFRON,NBUFA)
  330     CONTINUE
  331   CONTINUE
        IF(IFFIX(NIKNO).EQ.0) EQROW(IFRON,NBUFA)=SEQROW
C
C Put the final values where they belong
        DO 335 IRHS=1,NRHS
          IF(IFFIX(NIKNO).EQ.0)VECRV(IFRON,IRHS)=EQRHS(NVARB,IRHS)/PIVOT
          IF(IFFIX(NIKNO).NE.0)FIXED(NIKNO,IRHS)=-EQRHS(NVARB,IRHS)
  335   CONTINUE
        NBUFA=NBUFA-1
        NVARB=NVARB-1
        IF(MODE.EQ.1)THEN
          DITER(NIKNO)=VECRV(IFRON,1)
        ELSE IF(MODE.EQ.2)THEN
          DTANG(NIKNO)=VECRV(IFRON,1)
        ELSE IF(MODE.EQ.3)THEN
          DTANG(NIKNO)=VECRV(IFRON,1)
          DITER(NIKNO)=VECRV(IFRON,2)
        ENDIF
  340 CONTINUE
C Copy displacements of master degrees of freedom to slaves
      DO 530 ITOTV=1,NTOTV
        IF(MODE.EQ.1)THEN
          DITER(ITOTV)=DITER(MASTER(ITOTV))
        ELSE IF(MODE.EQ.2)THEN
          DTANG(ITOTV)=DTANG(MASTER(ITOTV))
        ELSE IF(MODE.EQ.3)THEN
          DTANG(ITOTV)=DTANG(MASTER(ITOTV))
          DITER(ITOTV)=DITER(MASTER(ITOTV))
        ENDIF
  530 CONTINUE
C Transform local nodal displacements back to global values for
C prescribed displacements at an angle (for 2-D only)
      DO 370 IPOIN=1,NPOIN
        ISVAB=(IPOIN-1)*NDOFN
        DO 360 IVFIX=1,NVFIX
          IF(NOFIX(IVFIX).EQ.IPOIN.AND.ANGLE(IVFIX).NE.R0)THEN
            C=COS(ANGLE(IVFIX))
            S=SIN(ANGLE(IVFIX))
            ISVAB=ISVAB+1
            JSVAB=ISVAB+1
            IF(MODE.EQ.1)THEN
              GASHI= C*DITER(ISVAB)-S*DITER(JSVAB)
              GASHJ= S*DITER(ISVAB)+C*DITER(JSVAB)
              DITER(ISVAB)=GASHI
              DITER(JSVAB)=GASHJ
            ELSE IF(MODE.EQ.2)THEN
              GASHI= C*DTANG(ISVAB)-S*DTANG(JSVAB)
              GASHJ= S*DTANG(ISVAB)+C*DTANG(JSVAB)
              DTANG(ISVAB)=GASHI
              DTANG(JSVAB)=GASHJ
            ELSE IF(MODE.EQ.3)THEN
              GASHI= C*DTANG(ISVAB)-S*DTANG(JSVAB)
              GASHJ= S*DTANG(ISVAB)+C*DTANG(JSVAB)
              DTANG(ISVAB)=GASHI
              DTANG(JSVAB)=GASHJ
              GASHI= C*DITER(ISVAB)-S*DITER(JSVAB)
              GASHJ= S*DITER(ISVAB)+C*DITER(JSVAB)
              DITER(ISVAB)=GASHI
              DITER(JSVAB)=GASHJ
            ENDIF
            GOTO 370
          ENDIF
  360   CONTINUE
  370 CONTINUE
  900 CONTINUE
      RETURN
      END
CDOC END_SUBROUTINE FRONT
