      SUBROUTINE DENSTY(I1, I2, J1, J2, DMF, F, P, A)
C
C<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
C
C   PURPOSE
C   -------
C
C     FINDS FREQUENCY AND AREA FOR A BLOCK
C
C   DESCRIPTION
C   -----------
C
C   1.  THE ROUTINE RETURNS THE NUMBER OF CELLS IN THE BLOCK IN THE
C       VARIABLE A AND RETURNS THE TOTAL FREQUENCY OF THE CELLS IN THE
C       BLOCK IN THE VARIABLE P.
C
C   INPUT PARAMETERS
C   ----------------
C
C   I1   INTEGER SCALAR (UNCHANGED ON OUTPUT)
C        THE FIRST ROW OF THE BLOCK.
C
C   I2   INTEGER SCALAR (UNCHANGED ON OUTPUT)
C        THE SECOND ROW OF THE BLOCK.
C
C   J1   INTEGER SCALAR (UNCHANGED ON OUTPUT)
C        THE FIRST COLUMN OF THE BLOCK.
C
C   J2   INTEGER SCALAR (UNCHANGED ON OUTPUT)
C        THE SECOND COLUMN OF THE BLOCK.
C
C   DMF   INTEGER SCALAR (UNCHANGED ON OUTPUT).
C         THE FIRST DIMENSION OF THE MATRIX F.  MUST BE AT LEAST I2.
C
C   F     REAL MATRIX WHOSE FIRST DIMENSION MUST BE DMF AND WHOSE
C            SECOND DIMENSION MUST BE AT LEAST J2 (UNCHANGED ON OUTPUT).
C         CONTINGENCY TABLE BETWEEN THE TWO VARIABLES.
C
C   OUTPUT PARAMETERS
C   -----------------
C
C   P     REAL SCALAR.
C         THE TOTAL BLOCK FREQUENCY.
C
C   A     REAL SCALAR.
C         THE TOTAL BLOCK AREA.
C
C   REFERENCE
C   ---------
C
C     HARTIGAN, J. A. (1975).  CLUSTERING ALGORITHMS, JOHN WILEY &
C        SONS, INC., NEW YORK.  PAGE 51.
C
C<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
C
      INTEGER DMF
      DIMENSION F(DMF,*)
C
      A=0.
      P=0.
      DO 10 I=I1,I2
         DO 10 J=J1,J2
            IF(F(I,J).GE.0.) THEN
               A=A+1.
               P=P+F(I,J)
            ENDIF
   10 CONTINUE
      RETURN
      END
