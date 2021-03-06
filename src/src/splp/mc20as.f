      SUBROUTINE MC20AS(NC, MAXA, A, INUM, JPTR, JNUM, JDISP)
C***BEGIN PROLOGUE  MC20AS
C***REFER TO  SPLP
C     THIS SUBPROGRAM IS A SLIGHT MODIFICATION OF A SUBPROGRAM
C     FROM THE C. 1979 AERE HARWELL LIBRARY.  THE NAME OF THE
C     CORRESPONDING HARWELL CODE CAN BE OBTAINED BY DELETING
C     THE FINAL LETTER =S= IN THE NAMES USED HERE.
C     REVISED SEP. 13, 1979.
C
C     ROYALTIES HAVE BEEN PAID TO AERE-UK FOR USE OF THEIR CODES
C     IN THE PACKAGE GIVEN HERE.  ANY PRIMARY USAGE OF THE HARWELL
C     SUBROUTINES REQUIRES A ROYALTY AGREEMENT AND PAYMENT BETWEEN
C     THE USER AND AERE-UK.  ANY USAGE OF THE SANDIA WRITTEN CODES
C     SPLP( ) (WHICH USES THE HARWELL SUBROUTINES) IS PERMITTED.
C***ROUTINES CALLED  (NONE)
C***END PROLOGUE  MC20AS
      INTEGER INUM(MAXA), JNUM(MAXA)
      REAL A(MAXA)
      DIMENSION JPTR(NC)
C***FIRST EXECUTABLE STATEMENT  MC20AS
      NULL = -JDISP
C**      CLEAR JPTR
      DO 10 J=1,NC
         JPTR(J) = 0
   10 CONTINUE
C**      COUNT THE NUMBER OF ELEMENTS IN EACH COLUMN.
      DO 20 K=1,MAXA
         J = JNUM(K) + JDISP
         JPTR(J) = JPTR(J) + 1
   20 CONTINUE
C**      SET THE JPTR ARRAY
      K = 1
      DO 30 J=1,NC
         KR = K + JPTR(J)
         JPTR(J) = K
         K = KR
   30 CONTINUE
C
C**      REORDER THE ELEMENTS INTO COLUMN ORDER.  THE ALGORITHM IS AN
C        IN-PLACE SORT AND IS OF ORDER MAXA.
      DO 50 I=1,MAXA
C        ESTABLISH THE CURRENT ENTRY.
         JCE = JNUM(I) + JDISP
         IF (JCE.EQ.0) GO TO 50
         ACE = A(I)
         ICE = INUM(I)
C        CLEAR THE LOCATION VACATED.
         JNUM(I) = NULL
C        CHAIN FROM CURRENT ENTRY TO STORE ITEMS.
         DO 40 J=1,MAXA
C        CURRENT ENTRY NOT IN CORRECT POSITION.  DETERMINE CORRECT
C        POSITION TO STORE ENTRY.
            LOC = JPTR(JCE)
            JPTR(JCE) = JPTR(JCE) + 1
C        SAVE CONTENTS OF THAT LOCATION.
            ACEP = A(LOC)
            ICEP = INUM(LOC)
            JCEP = JNUM(LOC)
C        STORE CURRENT ENTRY.
            A(LOC) = ACE
            INUM(LOC) = ICE
            JNUM(LOC) = NULL
C        CHECK IF NEXT CURRENT ENTRY NEEDS TO BE PROCESSED.
            IF (JCEP.EQ.NULL) GO TO 50
C        IT DOES.  COPY INTO CURRENT ENTRY.
            ACE = ACEP
            ICE = ICEP
            JCE = JCEP + JDISP
   40    CONTINUE
C
   50 CONTINUE
C
C**      RESET JPTR VECTOR.
      JA = 1
      DO 60 J=1,NC
         JB = JPTR(J)
         JPTR(J) = JA
         JA = JB
   60 CONTINUE
      RETURN
      END
