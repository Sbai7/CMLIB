      FUNCTION EI(X)
C***BEGIN PROLOGUE  EI
C***DATE WRITTEN   770401   (YYMMDD)
C***REVISION DATE  820801   (YYMMDD)
C***CATEGORY NO.  C5
C***KEYWORDS  EXPONENTIAL INTEGRAL,SPECIAL FUNCTION
C***AUTHOR  FULLERTON, W., (LANL)
C***PURPOSE  Computes the exponential integral EI(X).
C***DESCRIPTION
C
C EI(X) calculates the single precision exponential integral for
C positive, single precision argument X.  The Cauchy principal
C value is returned for negative X.  If principal values are used
C everywhere, then for all X
C
C     EI(X) = -E1(-X)
C or
C     E1(X) = -EI(-X).
C***REFERENCES  (NONE)
C***ROUTINES CALLED  E1
C***END PROLOGUE  EI
C***FIRST EXECUTABLE STATEMENT  EI
      EI = -E1(-X)
C
      RETURN
      END
