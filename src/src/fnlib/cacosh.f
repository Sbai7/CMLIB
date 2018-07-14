      COMPLEX FUNCTION CACOSH(Z)
C***BEGIN PROLOGUE  CACOSH
C***DATE WRITTEN   770401   (YYMMDD)
C***REVISION DATE  820801   (YYMMDD)
C***CATEGORY NO.  C4C
C***KEYWORDS  ARC HYPERBOLIC COSINE,COMPLEX,ELEMENTARY FUNCTION
C***AUTHOR  FULLERTON, W., (LANL)
C***PURPOSE  Computes the complex arc hyperbolic Cosine.
C***DESCRIPTION
C
C CACOSH(Z) calculates the complex arc hyperbolic cosine of Z.
C***REFERENCES  (NONE)
C***ROUTINES CALLED  CACOS
C***END PROLOGUE  CACOSH
      COMPLEX Z, CI, CACOS
      DATA CI /(0.,1.)/
C***FIRST EXECUTABLE STATEMENT  CACOSH
      CACOSH = CI*CACOS(Z)
C
      RETURN
      END