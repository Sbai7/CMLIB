      SUBROUTINE FACTRB ( W, IPIVOT, D, NROW, NCOL, LAST, IFLAG )
C  ADAPTED FROM P.132 OF *ELEMENTARY NUMER.ANALYSIS* BY CONTE-DE BOOR
C
C  CONSTRUCTS A PARTIAL PLU FACTORIZATION, CORRESPONDING TO STEPS 1,...,
C   L A S T   IN GAUSS ELIMINATION, FOR THE MATRIX  W  OF ORDER
C   ( N R O W ,  N C O L ), USING PIVOTING OF SCALED ROWS.
C
C  PARAMETERS
C    W       CONTAINS THE (NROW,NCOL) MATRIX TO BE PARTIALLY FACTORED
C            ON INPUT, AND THE PARTIAL FACTORIZATION ON OUTPUT.
C    IPIVOT  AN INTEGER ARRAY OF LENGTH NROW CONTAINING A RECORD OF THE
C            PIVOTING STRATEGY USED. ROW IPIVOT(I) IS USED DURING THE
C            I-TH ELIMINATION STEP, I=1,...,LAST.
C    D       A WORK ARRAY OF LENGTH NROW USED TO STORE ROW SIZES
C            TEMPORARILY.
C    NROW    NUMBER OF ROWS OF W.
C    NCOL    NUMBER OF COLUMNS OF W.
C    LAST    NUMBER OF ELIMINATION STEPS TO BE CARRIED OUT.
C    IFLAG   ON OUTPUT, EQUALS IFLAG ON INPUT TIMES (-1)**(NUMBER OF
C            ROW INTERCHANGES DURING THE FACTORIZATION PROCESS), IN
C            CASE NO ZERO PIVOT WAS ENCOUNTERED.
C            OTHERWISE, IFLAG = 0 ON OUTPUT.
C
      INTEGER IPIVOT(NROW),NCOL,LAST,IFLAG, I,IPIVI,IPIVK,J,K,KP1
      REAL W(NROW,NCOL),D(NROW), AWIKDI,COLMAX,RATIO,ROWMAX
C  INITIALIZE IPIVOT, D
      DO 10 I=1,NROW
         IPIVOT(I) = I
         ROWMAX = 0.
         DO 9 J=1,NCOL
    9       ROWMAX = AMAX1(ROWMAX, ABS(W(I,J)))
         IF (ROWMAX .EQ. 0.)            GO TO 999
   10    D(I) = ROWMAX
C GAUSS ELIMINATION WITH PIVOTING OF SCALED ROWS, LOOP OVER K=1,.,LAST
      K = 1
C        AS PIVOT ROW FOR K-TH STEP, PICK AMONG THE ROWS NOT YET USED,
C        I.E., FROM ROWS IPIVOT(K),...,IPIVOT(NROW), THE ONE WHOSE K-TH
C        ENTRY (COMPARED TO THE ROW SIZE) IS LARGEST. THEN, IF THIS ROW
C        DOES NOT TURN OUT TO BE ROW IPIVOT(K), REDEFINE IPIVOT(K) AP-
C        PROPRIATELY AND RECORD THIS INTERCHANGE BY CHANGING THE SIGN
C        OF  I F L A G .
   11    IPIVK = IPIVOT(K)
         IF (K .EQ. NROW)               GO TO 21
         J = K
         KP1 = K+1
         COLMAX = ABS(W(IPIVK,K))/D(IPIVK)
C              FIND THE (RELATIVELY) LARGEST PIVOT
         DO 15 I=KP1,NROW
            IPIVI = IPIVOT(I)
            AWIKDI = ABS(W(IPIVI,K))/D(IPIVI)
            IF (AWIKDI .LE. COLMAX)     GO TO 15
               COLMAX = AWIKDI
               J = I
   15       CONTINUE
         IF (J .EQ. K)                  GO TO 16
         IPIVK = IPIVOT(J)
         IPIVOT(J) = IPIVOT(K)
         IPIVOT(K) = IPIVK
         IFLAG = -IFLAG
   16    CONTINUE
C        IF PIVOT ELEMENT IS TOO SMALL IN ABSOLUTE VALUE, DECLARE
C        MATRIX TO BE NONINVERTIBLE AND QUIT.
         IF (ABS(W(IPIVK,K))+D(IPIVK) .LE. D(IPIVK))
     *                                  GO TO 999
C        OTHERWISE, SUBTRACT THE APPROPRIATE MULTIPLE OF THE PIVOT
C        ROW FROM REMAINING ROWS, I.E., THE ROWS IPIVOT(K+1),...,
C        IPIVOT(NROW), TO MAKE K-TH ENTRY ZERO. SAVE THE MULTIPLIER IN
C        ITS PLACE.
         DO 20 I=KP1,NROW
            IPIVI = IPIVOT(I)
            W(IPIVI,K) = W(IPIVI,K)/W(IPIVK,K)
            RATIO = -W(IPIVI,K)
            DO 20 J=KP1,NCOL
   20          W(IPIVI,J) = RATIO*W(IPIVK,J) + W(IPIVI,J)
         K = KP1
C        CHECK FOR HAVING REACHED THE NEXT BLOCK.
         IF (K .LE. LAST)               GO TO 11
                                        RETURN
C     IF  LAST  .EQ. NROW , CHECK NOW THAT PIVOT ELEMENT IN LAST ROW
C     IS NONZERO.
   21 IF( ABS(W(IPIVK,NROW))+D(IPIVK) .GT. D(IPIVK) )
     *                                  RETURN
C                   SINGULARITY FLAG SET
  999 IFLAG = 0
                                        RETURN
      END
