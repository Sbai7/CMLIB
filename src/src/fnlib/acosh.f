 
      FUNCTION ACOSH(X)
C***BEGIN PROLOGUE  ACOSH
C***DATE WRITTEN   770401   (YYMMDD)
C***REVISION DATE  820801   (YYMMDD)
C***CATEGORY NO.  C4C
C***KEYWORDS  ACOSH,ARC HYPERBOLIC COSINE,ELEMENTARY FUNCTION
C***AUTHOR  FULLERTON, W., (LANL)
C***PURPOSE  Compute the arc hyperbolic Cosine.
C***DESCRIPTION
C
C ACOSH(X) computes the arc hyperbolic cosine of X.
C***REFERENCES  (NONE)
C***ROUTINES CALLED  R1MACH,XERROR
C***END PROLOGUE  ACOSH
      DATA ALN2 / 0.6931471805 5994530942E0/
      DATA XMAX /0./
C***FIRST EXECUTABLE STATEMENT  ACOSH
      IF (XMAX.EQ.0.) XMAX = 1.0/SQRT(R1MACH(3))
C
      IF (X.LT.1.0) CALL XERROR ( 'ACOSH   X LESS THAN 1', 21, 1, 2)
C
      IF (X.LT.XMAX) ACOSH = ALOG (X + SQRT(X*X-1.0))
      IF (X.GE.XMAX) ACOSH = ALN2 + ALOG(X)
C
      RETURN
      END