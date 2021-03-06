      SUBROUTINE AIDOUT(MM, M, N, A, CLAB, RLAB, JP, KA, TH, DMNB, NB,
     *                  DMSP, SP, OUNIT)
C
C<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
C
C   PURPOSE
C   -------
C
C      PRINTS OUTPUT FROM AID
C
C   INPUT PARAMETERS
C   ----------------
C
C   MM    INTEGER SCALAR (UNCHANGED ON OUTPUT).
C         THE LEADING DIMENSION OF MATRIX A.  MUST BE AT LEAST M.
C
C   M     INTEGER SCALAR (UNCHANGED ON OUTPUT).
C         THE NUMBER OF OBJECTS.
C
C   N     INTEGER SCALAR (UNCHANGED ON OUTPUT).
C         THE NUMBER OF VARIABLES.
C
C   A     REAL MATRIX WHOSE FIRST DIMENSION MUST BE MM AND SECOND
C            DIMENSION MUST BE AT LEAST M (UNCHANGED ON OUTPUT).
C         THE DATA MATRIX.
C
C   CLAB  VECTOR OF 4-CHARACTER VARIABLES DIMENSIONED AT LEAST N
C            (UNCHANGED ON OUTPUT).
C         ORDERED LABELS OF THE COLUMNS.
C
C   RLAB  VECTOR OF 4-CHARACTER VARIABLES DIMENSIONED AT LEAST M
C            (UNCHANGED ON OUTPUT).
C         ORDERED LABELS OF THE ROWS.
C
C   JP    INTEGER SCALAR (UNCHANGED ON OUTPUT).
C         NUMBER OF VARIABLE TO BE PREDICTED.  MUST BE BETWEEN 1 AND N.
C
C   KA    INTEGER SCALAR (UNCHANGED ON OUTPUT).
C         NUMBER OF CLUSTERS THAT WERE FORMED.
C
C   TH    REAL SCALAR (UNCHANGED ON OUTPUT).
C         THRESHOLD VARIANCE FOR VARIABLES WITHIN CLUSTERS.
C
C   DMNB  INTEGER SCALAR (UNCHANGED ON OUTPUT).
C         THE LEADING DIMENSION OF MATRIX NB.  MUST BE AT LEAST 2.
C
C   NB    INTEGER MATRIX WHOSE FIRST DIMENSION MUST BE DMNB AND SECOND
C            DIMENSION MUST BE AT LEAST KA (UNCHANGED ON OUTPUT).
C         MATRIX DEFINING THE CLUSTERS.
C
C         NB(1,I) IS THE FIRST AND LAST ROWS IN CLUSTER I.
C         NB(2,I) IS THE FIRST AND LAST ROWS IN CLUSTER I.
C
C   DMSP  INTEGER SCALAR (UNCHANGED ON OUTPUT).
C         THE LEADING DIMENSION OF MATRIX SP.  MUST BE AT LEAST 6.
C
C   SP    REAL MATRIX WHOSE FIRST DIMENSION MUST BE DMSP AND SECOND
C            DIMENSION MUST BE AT LEAST KA (UNCHANGED ON OUTPUT).
C         SUMMARY STATISTICS FOR EACH CLUSTER.
C
C         SP(1,I) IS THE SPLITTING VARIABLE FOR CLUSTER I.
C         SP(2,I) IS THE SPLITTING VALUE FOR CLUSTER I.
C         SP(3,I) IS THE REDUCTION IN THE SUM OF SQUARES DUE TO THE
C                 SPLITTING OF CLUSTER I.
C         SP(4,I) IS THE NUMBER OF OBJECTS IN CLUSTER I.
C         SP(5,I) IS THE MEAN OF THE OBJECTS IN CLUSTER I.
C         SP(6,I) IS THE VARIANCE OF THE OBJECTS IN CLUSTER I.
C
C   OUNIT INTEGER SCALAR (UNCHANGED ON OUTPUT).
C         UNIT NUMBER FOR OUTPUT.
C
C   REFERENCES
C   ----------
C
C     HARTIGAN, J. A. (1975).  CLUSTERING ALGORITHMS, JOHN WILEY &
C        SONS, INC., NEW YORK.  PAGE 345.
C
C     SONQUIST, J. A. (1971).  "MULTIVARIATE MODEL BUILDING: THE
C        VALIDATION OF A SEARCH STRATEGY."  INSTITUTE FOR SOCIAL
C        RESEARCH, THE UNIVERSITY OF MICHIGAN, ANN ARBOR, MICH.
C
C<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
C
      INTEGER DMNB, DMSP, OUNIT
      DIMENSION NB(DMNB,*),SP(DMSP,*),A(MM,*)
      CHARACTER*4 CLAB(*), RLAB(*)
C
      WRITE(OUNIT,1) CLAB(JP),TH
    1 FORMAT('1  CLUSTERS OBTAINED IN SPLITTING TO PREDICT VARIABLE   ',
     *A4,/'   USING THRESHOLD ',F12.6)
      WRITE(OUNIT,2) (RLAB(I),I=1,M)
    2 FORMAT('0 ORDERED OBJECTS ',//, 2X, 26(A4, 1X))
      WRITE(OUNIT,3)
    3 FORMAT(//,
     *'  FIRST   LAST    SPLIT       SPLIT        SSQ        COUNT
     *  MEAN      VARIANCE ' ,/,
     *'  OBJECT  OBJECT  VARIABLE    POINT     REDUCTION ')
      DO 10 K=2,KA
         JS=INT(SP(1,K))
         IL=NB(1,K)
         IU=NB(2,K)
         WRITE(OUNIT,4) RLAB(IL),RLAB(IU),CLAB(JS),(SP(I,K),I=2,6)
    4    FORMAT(2X,3(A4,4X),5F12.5)
   10 CONTINUE
      RETURN
      END
