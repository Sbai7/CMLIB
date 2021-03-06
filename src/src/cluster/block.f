      SUBROUTINE BLOCK(MM, M, N, D, CLAB, RLAB, TITLE, KC, DMNB, NB,
     *                 IERR, OUNIT)
C
C<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
C
C   PURPOSE
C   -------
C
C      PRINTS OUTLINES OF BLOCKS OVER A DISTANCE MATRIX
C
C   DESCRIPTION
C   -----------
C
C   1.  THERE EXISTS AN ORDERING OF THE ROWS OF THE BLOCK SUCH THAT
C       EVERY BLOCK CONSISTS OF A SET OF OBJECTS CONTIGUOUS IN THAT
C       ORDER.  THE ALGORITHM IS GIVEN ON PAGE 156 OF THE FIRST
C       REFERENCE.  THE ROW OBJECTS ARE STORED IN THE VECTOR RLAB IN
C       SUCH AN ORDER.  SIMILARLY, THE COLUMNS CAN BE ORDERED WHICH IS
C       STORED IN THE CLAB ARRAY.
C
C   2.  THIS ORDERING OF THE OBJECTS ALLOWS THE BLOCKS TO BE NAMED BY
C       GIVING THE LOCATION OF THE FIRST AND LAST ROW AND COLUMN IN THE
C       ARRAY FOR EACH BLOCK.  THE FIRST TWO COLUMNS OF THE NB ARRAY
C       STORE THE FIRST AND LAST ROWS IN EACH BLOCK AND THE THIRD AND
C       FOURTH COLUMNS STORE THE FIRST AND LAST COLUMNS IN EACH BLOCK
C
C   3.  THE FINAL BLOCK DIAGRAM PRINTS THE ROW LABELS AND THE COLUMN
C       LABELS AND THE DISTANCE MATRIX WHERE EACH VALUE IS MULTIPLIED
C       BY 10.  THE HORIZONTAL BOUNDARIES OF THE BLOCKS ARE REPRESENTED
C       BY DASHES AND THE VERTICAL BOUNDARIES BY QUOTE MARKS.  COMMAS
C       REPRESENT THE CORNERS OF THE BLOCKS.
C
C   INPUT PARAMETERS
C   ----------------
C
C   MM    INTEGER SCALAR (UNCHANGED ON OUTPUT).
C         THE LEADING DIMENSION OF MATRIX D.
C
C   M     INTEGER SCALAR (UNCHANGED ON OUTPUT).
C         THE NUMBER OF OBJECTS.
C
C   N     INTEGER SCALAR (UNCHANGED ON OUTPUT).
C         THE NUMBER OF VARIABLES.
C
C   D     REAL MATRIX WHOSE FIRST DIMENSION MUST BE MM AND SECOND
C            DIMENSION MUST BE AT LEAST M (UNCHANGED ON OUTPUT).
C         THE MATRIX OF DISTANCES.
C
C         D(I,J) = DISTANCE FROM CASE I TO CASE J
C
C   CLAB  VECTOR OF 4-CHARACTER VARIABLES DIMENSIONED AT LEAST N
C            (UNCHANGED ON OUTPUT).
C         ORDERED LABELS OF THE COLUMNS.
C
C   RLAB  VECTOR OF 4-CHARACTER VARIABLES DIMENSIONED AT LEAST M
C            (UNCHANGED ON OUTPUT).
C         ORDERED LABELS OF THE ROWS.
C
C   TITLE 10-CHARACTER VARIABLE (UNCHANGED ON OUTPUT).
C         TITLE OF THE DATA SET.
C
C   KC    INTEGER SCALAR (UNCHANGED ON OUTPUT).
C         THE NUMBER OF BLOCKS.
C
C   DMNB  INTEGER SCALAR (UNCHANGED ON OUTPUT).
C         THE LEADING DIMENSION OF MATRIX NB.  MUST BE AT LEAST 4.
C
C   NB    REAL MATRIX WHOSE FIRST DIMENSION MUST BE DMNB AND SECOND
C            DIMENSION MUST BE AT LEAST KC (UNCHANGED ON OUTPUT).
C         THE MATRIX DEFINING THE BOUNDARIES OF THE BLOCKS.
C
C         NB(1,I) IS 1 + THE FIRST ROW IN BLOCK I
C         NB(2,I) IS 1 + THE LAST ROW IN BLOCK I
C         NB(3,I) IS 1 + THE FIRST COLUMN IN BLOCK I
C         NB(4,I) IS 1 + THE LAST COLUMN IN BLOCK I
C
C   OUNIT INTEGER SCALAR (UNCHANGED ON OUTPUT).
C         UNIT NUMBER FOR OUTPUT.
C
C   OUTPUT PARAMETER
C   ----------------
C
C   IERR  INTEGER SCALAR.
C         ERROR FLAG.
C
C         IERR = 0, NO ERRORS WERE DETECTED DURING EXECUTION
C
C         IERR = 2, EITHER THE FIRST AND LAST CASES OR THE CLUSTER
C                   DIAMETER FOR A CLUSTER IS OUT OF BOUNDS.  THE
C                   CLUSTER AND ITS BOUNDARIES ARE PRINTED ON UNIT
C                   OUNIT.  EXECUTION WILL CONTINUE WITH QUESTIONABLE
C                   RESULTS FOR THAT CLUSTER.
C
C   REFERENCES
C   ----------
C
C     HARTIGAN, J. A. (1975).  CLUSTERING ALGORITHMS, JOHN WILEY &
C        SONS, INC., NEW YORK.  PAGE 168.
C
C     HARTIGAN, J. A. (1975) PRINTER GRAPHICS FOR CLUSTERING. JOURNAL OF
C        STATISTICAL COMPUTATION AND SIMULATION. VOLUME 4,PAGES 187-213.
C
C<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
C
      INTEGER DMNB, OUNIT
      DIMENSION D(MM,*), NB(DMNB,*), IA(26)
      CHARACTER*4 CLAB(*), RLAB(*), DD, AE(26)
      CHARACTER*10 TITLE
      CHARACTER*1 DASH,DITTO,COMMA,BLANK,STAR,DOT,AA(26)
      DATA DD/'----'/
      DATA DASH,DITTO,COMMA,BLANK,STAR,DOT/'-','''',',',' ','*','.'/
C
C     CHECK BOUNDARY ARRAY NB
C
      IF (OUNIT .LE. 0) RETURN
      DO 10 K=1,KC
         IF(NB(1,K).LT.2.OR.NB(1,K).GT.NB(2,K).OR.NB(2,K).GT.M .OR.
     *      NB(3,K).LT.2.OR.NB(3,K).GT.NB(4,K).OR.NB(4,K).GT.N) THEN
            WRITE(OUNIT,1) K
            WRITE(OUNIT,6) (NB(I,K)-1,I=1,4)
            IERR = 2
         ENDIF
   10 CONTINUE
    1 FORMAT(' BAD BOUNDARY IN BLOCK ',I3)
    6 FORMAT(' BOUNDARIES ARE ', 4I5)
C
      JPP=(N-2)/25+1
      DO 80 JP=1,JPP
         JLP=25*(JP-1)+1
         JUP=25*JP+1
         IF(JUP.GT.N-1) JUP=N-1
         JR=JUP-JLP+1
C
C     WRITE TITLES
C
         WRITE(OUNIT,2) TITLE
    2    FORMAT('1 BLOCKED ARRAY ',A10)
C
C     WRITE OUT ARRAY ONE LINE AT A TIME
C
         WRITE(OUNIT,3)(CLAB(J),J=JLP,JUP)
    3    FORMAT(10X,25(1X,A4))
         DO 80 I=1,M
            I1=I-1
            DO 20 L=1,26
               AE(L)=BLANK
   20          AA(L)=BLANK
            IF (I .NE. 1) THEN
C
C     FILL IN DISTANCES
C
               DO 30 J=JLP,JUP
   30             IA(J-JLP+1)=INT(D(I1,J)*10.)
C
C     FILL IN VERTICAL BOUNDARIES
C
               DO 40 K=1,KC
                  IF(NB(2,K).GE.I.AND.NB(1,K).LE.I) THEN
                     JL=NB(3,K)-1
                     JU=NB(4,K)
                     IF(JL.GE.JLP.AND.JL.LE.JUP) AA(JL-JLP+1)=DITTO
                     IF(JU.GE.JLP.AND.JU.LE.JUP) AA(JU-JLP+1)=DITTO
                     IF(JU.EQ.JLP+JR) AA(JR+1)=DITTO
                  ENDIF
   40          CONTINUE
               WRITE(OUNIT,4) RLAB(I1),(AA(J),IA(J),J=1,JR),AA(JR+1)
    4          FORMAT(1X,A4,5X,25(A1,I4),A1)
C
C     FILL IN HORIZONTAL BOUNDARIES
C
            ENDIF
            DO 60 K=1,KC
               IF(NB(1,K).EQ.I+1.OR.NB(2,K).EQ.I) THEN
                  JL=NB(3,K)-1
                  JU=NB(4,K)
                  J1=JL-JLP+1
                  J2=JU-JLP+1
                  IF(J1.LE.0) J1=1
                  IF(J2.GT.26) J2=26
                  IF(J1.LE.26.AND.J2.GT.0) THEN
                     DO 50 J=J1,J2
                        IF(J.NE.J2) AE(J)=DD
   50                   IF(AA(J).EQ.BLANK) AA(J)=DASH
                     IF(NB(1,K).EQ.I+1) THEN
                        AA(J1)=COMMA
                        AA(J2)=COMMA
                     ENDIF
                  ENDIF
               ENDIF
   60       CONTINUE
            WRITE(OUNIT,5)(AA(J),AE(J),J=1,JR),AA(JR+1)
    5       FORMAT(10X,25(A1,A4),A1)
   70    CONTINUE
   80 CONTINUE
      RETURN
      END
