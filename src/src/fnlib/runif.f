      FUNCTION RUNIF(T,N)
C***BEGIN PROLOGUE  RUNIF
C***DATE WRITTEN   770401   (YYMMDD)
C***REVISION DATE  820801   (YYMMDD)
C***REVISION HISTORY  (YYMMDD)
C   000330  Modified array declarations.  (JEC)
C***CATEGORY NO.  L6A21
C***KEYWORDS  RANDOM NUMBER,SPECIAL FUNCTION,UNIFORM
C***AUTHOR  FULLERTON, W., (LANL)
C***PURPOSE  A portable random number genaerator.
C***DESCRIPTION
C
C This random number generator is portable among a wide variety of
C computers.  It generates a random number between 0.0 and 1.0 accord-
C ing to the algorithm presented by Bays and Durham (TOMS, 2, 59,
C 1976).  The motivation for using this scheme, which resembles the
C Maclaren-Marsaglia method, is to greatly increase the period of the
C random sequence.  If the period of the basic generator (RAND) is P,
C then the expected mean period of the sequence generated by RUNIF is
C given by   new mean P = SQRT (PI*FACTORIAL(N)/(8*P)),
C where FACTORIAL(N) must be much greater than P in this asymptotic
C formula.  Generally, N should be around 32 if P=4.E6 as for RAND.
C
C             Input Argument --
C N      IABS(N) is the number of random numbers in an auxiliary table.
C        Note though that IABS(N)+1 is the number of items in array T.
C        If N is positive and differs from its value in the previous
C        invocation, then the table is initialized for the new value of
C        N.  If N is negative, IABS(N) is the number of items in an
C        auxiliary table, but the tables are now assumed already to
C        be initialized.  This option enables the user to save the
C        table T at the end of a long computer run and to restart with
C        the same sequence.  Normally, RUNIF would be called at most
C        once with negative N.  Subsequent invocations would have N
C        positive and of the correct magnitude.
C
C             Input and Output Argument  --
C T      an array of IABS(N)+1 random numbers from a previous invocation
C        of RUNIF.  Whenever N is positive and differs from the old
C        N, the table is initialized.  The first IABS(N) numbers are the
C        table discussed in the reference, and the N+1 -st value is Y.
C        This array may be saved in order to restart a sequence.
C
C             Output Value --
C RUNIF  a random number between 0.0 and 1.0.
C***REFERENCES  (NONE)
C***ROUTINES CALLED  RAND
C***END PROLOGUE  RUNIF
      DIMENSION T(*)
      EXTERNAL RAND
      DATA NOLD /-1/
C***FIRST EXECUTABLE STATEMENT  RUNIF
      IF (N.EQ.NOLD) GO TO 20
C
      NOLD = IABS(N)
      FLOATN = NOLD
      IF (N.LT.0) DUMMY = RAND (T(NOLD+1))
      IF (N.LT.0) GO TO 20
C
      DO 10 I=1,NOLD
        T(I) = RAND (0.)
 10   CONTINUE
      T(NOLD+1) = RAND (0.)
C
 20   J = T(NOLD+1)*FLOATN + 1.
      T(NOLD+1) = T(J)
      RUNIF = T(J)
      T(J) = RAND (0.)
C
      RETURN
      END
