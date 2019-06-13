CDOC BEGIN_SUBROUTINE RSQ8
CDOC Read input and set properties for element type QUAD8
CDOC
CDOC This routine reads data from the input data file and sets the
CDOC element properties arrays for elements type QUAD8: Standard
CDOC isoparametric 8-noded quadrilateral for plane strain, plane stress
CDOC and axisymmetric analysis. It also echoes
CDOC the properties to the results file and sets the unsymmetric
CDOC tangent stiffness flag.
CDOC
CDOC BEGIN_PARAMETERS
CDOC INTEGER          IELPRP <  Array of integer element properties.
CDOC INTEGER          NDATF  >  Data file unit identifier.
CDOC INTEGER          NRESF  >  Results file unit identifier.
CDOC DOUBLE_PRECISION RELPRP <  Array of real element properties.
CDOC LOGICAL          UNSYM  <  Unsymmetric tangent stiffness flag.
CDOC END_PARAMETERS
CHST
CHST E.de Souza Neto, July 1996: Initial coding
CHST
CHST E.de Souza Neto, April 2011: I/O error message added
CHST
      SUBROUTINE RSQ8
     1(   IELPRP     ,NDATF      ,NRESF      ,RELPRP     ,UNSYM      )
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      PARAMETER
     1(   MGAUSP=9   ,MNODEG=3   ,NDIME=2    ,NDOFEL=16  ,NEDGEL=4   ,
     2    NGAUSB=2   ,NNODE=8    )
      LOGICAL UNSYM
      DIMENSION
     1    IELPRP(*)          ,RELPRP(*)
      DIMENSION
     1    NORDEB(NNODE,NEDGEL),POSGP(2,MGAUSP)   ,POSGPB(NGAUSB)     ,
     2    WEIGP(MGAUSP)      ,WEIGPB(NGAUSB)
C***********************************************************************
C READ INPUT DATA AND SET PROPERTIES FOR ELEMENT TYPE 'QUAD_8'
C (STANDARD ISOPARAMETRIC 8-NODED QUADRILATERAL)
C
C REFERENCE: Section 4.1.3
C***********************************************************************
 1000 FORMAT(' QUAD_8 (standard 8-noded quadrilateral)'/
     1       ' Integration rule: ',I2,' gauss points')
C
C Read number of gauss points for domain integration
C --------------------------------------------------
      READ(NDATF,*,ERR=100,END=100)NGAUSP
      WRITE(NRESF,1000)NGAUSP
      IF(NGAUSP.NE.1.AND.NGAUSP.NE.4.AND.
     1   NGAUSP.NE.5.AND.NGAUSP.NE.9)THEN
        CALL ERRPRT('ED0008')
      ENDIF
C Set element integer properties (stored in vector IELPRP)
C --------------------------------------------------------
C total number of nodes and gauss points for domain integration
      IELPRP(3)=NNODE
      IELPRP(4)=NGAUSP
C number of degrees of freedom of the element
      IELPRP(5)=NDOFEL
C number of edges of the element
      IELPRP(6)=NEDGEL
C maximum number of nodes per edge
      IELPRP(7)=MNODEG
C number of gauss points for boundary integration
      IELPRP(8)=NGAUSB
C node numbering order on boundaries (set correspondance between local
C element node numbers and "edge" node numbering for boundary
C integration)
      NORDEB(1,1)=1
      NORDEB(2,1)=2
      NORDEB(3,1)=3
      NORDEB(4,1)=0
      NORDEB(5,1)=0
      NORDEB(6,1)=0
      NORDEB(7,1)=0
      NORDEB(8,1)=0
    
      NORDEB(1,2)=0
      NORDEB(2,2)=0
      NORDEB(3,2)=1
      NORDEB(4,2)=2
      NORDEB(5,2)=3
      NORDEB(6,2)=0
      NORDEB(7,2)=0
      NORDEB(8,2)=0
      
      NORDEB(1,3)=0
      NORDEB(2,3)=0
      NORDEB(3,3)=0
      NORDEB(4,3)=0
      NORDEB(5,3)=1
      NORDEB(6,3)=2
      NORDEB(7,3)=3
      NORDEB(8,3)=0
      
      NORDEB(1,4)=3
      NORDEB(2,4)=0
      NORDEB(3,4)=0
      NORDEB(4,4)=0
      NORDEB(5,4)=0
      NORDEB(6,4)=0
      NORDEB(7,4)=1
      NORDEB(8,4)=2
      IPOS=9
      DO 20 IEDGEL=1,NEDGEL
        DO 10 INODE=1,NNODE
          IELPRP(IPOS)=NORDEB(INODE,IEDGEL)
          IPOS=IPOS+1
   10   CONTINUE
   20 CONTINUE
C Set element real properties (stored in vector RELPRP)
C -----------------------------------------------------
C gaussian constants for domain integration
      CALL GAUS2D
     1(  'QUA'       ,NGAUSP     ,POSGP      ,WEIGP      )
      IPOS=1
      DO 30 IGAUSP=1,NGAUSP
        RELPRP(IPOS)=POSGP(1,IGAUSP)
        RELPRP(IPOS+1)=POSGP(2,IGAUSP)
        IPOS=IPOS+NDIME
   30 CONTINUE
      IPOS=NGAUSP*NDIME+1
      DO 40 IGAUSP=1,NGAUSP
        RELPRP(IPOS)=WEIGP(IGAUSP)
        IPOS=IPOS+1
   40 CONTINUE
C set matrix of coefficients for extrapolation from gauss points to
C nodes
      IPOS=NGAUSP*NDIME+NGAUSP+1
      CALL EXQ8
     1(   NGAUSP     ,RELPRP(IPOS))
C gaussian constants for boundary integration (intergration over edges)
      CALL GAUS1D
     1(   NGAUSB     ,POSGPB     ,WEIGPB     )
      IPOS=NGAUSP*NDIME+NGAUSP+NGAUSP*NNODE+1
      DO 50 IGAUSB=1,NGAUSB
        RELPRP(IPOS)=POSGPB(IGAUSB)
        IPOS=IPOS+1
   50 CONTINUE
      IPOS=NGAUSP*NDIME+NGAUSP+NGAUSP*NNODE+NGAUSB+1
      DO 60 IGAUSB=1,NGAUSB
        RELPRP(IPOS)=WEIGPB(IGAUSB)
        IPOS=IPOS+1
   60 CONTINUE
C Set unsymmetric solver flag
C ---------------------------
      UNSYM=.FALSE.
C
      GOTO 200
C Issue error message and abort program execution in case of I/O error
  100 CALL ERRPRT('ED0207')
C
  200 CONTINUE
      RETURN
      END
CDOC END_SUBROUTINE RSQ8
