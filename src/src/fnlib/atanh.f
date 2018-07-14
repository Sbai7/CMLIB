      FUNCTION ATANH(X)
C***BEGIN PROLOGUE  ATANH
C***DATE WRITTEN   770401   (YYMMDD)
C***REVISION DATE  820801   (YYMMDD)
C***CATEGORY NO.  C4C
C***KEYWORDS  ARC HYPERBOLIC TANGENT,ATANH,ELEMENTARY FUNCTION
C***AUTHOR  FULLERTON, W., (LANL)
C***PURPOSE  Compute the arc hyperbolic Tangent.
C***DESCRIPTION
C
C ATANH(X) computes the arc hyperbolic tangent of X.
C
C Series for ATNH       on the interval  0.          to  2.50000D-01
C                                        with weighted error   6.70E-18
C                                         log weighted error  17.17
C                               significant figures required  16.01
C                                    decimal places required  17.76
C***REFERENCES  (NONE)
C***ROUTINES CALLED  CSEVL,INITS,R1MACH,XERROR
C***END PROLOGUE  ATANH
      DIMENSION ATNHCS(15)
      DATA ATNHCS( 1) /    .0943951023 93195492E0 /
      DATA ATNHCS( 2) /    .0491984370 55786159E0 /
      DATA ATNHCS( 3) /    .0021025935 22455432E0 /
      DATA ATNHCS( 4) /    .0001073554 44977611E0 /
      DATA ATNHCS( 5) /    .0000059782 67249293E0 /
      DATA ATNHCS( 6) /    .0000003505 06203088E0 /
      DATA ATNHCS( 7) /    .0000000212 63743437E0 /
      DATA ATNHCS( 8) /    .0000000013 21694535E0 /
      DATA ATNHCS( 9) /    .0000000000 83658755E0 /
      DATA ATNHCS(10) /    .0000000000 05370503E0 /
      DATA ATNHCS(11) /    .0000000000 00348665E0 /
      DATA ATNHCS(12) /    .0000000000 00022845E0 /
      DATA ATNHCS(13) /    .0000000000 00001508E0 /
      DATA ATNHCS(14) /    .0000000000 00000100E0 /
      DATA ATNHCS(15) /    .0000000000 00000006E0 /
      DATA NTERMS, DXREL, SQEPS /0, 0., 0./
C***FIRST EXECUTABLE STATEMENT  ATANH
      IF (NTERMS.NE.0) GO TO 10
      NTERMS = INITS (ATNHCS, 15, 0.1*R1MACH(3))
      DXREL = SQRT (R1MACH(4))
      SQEPS = SQRT (3.0*R1MACH(3))
C
 10   Y = ABS(X)
      IF (Y.GE.1.0) CALL XERROR ( 'ATANH   ABS(X) GE 1', 19, 2, 2)
C
      IF (1.0-Y.LT.DXREL) CALL XERROR ( 'ATANH   ANSWER LT HALF PRECISIO
     1N BECAUSE ABS(X) TOO NEAR 1', 58, 1, 1)
C
      ATANH = X
      IF (Y.GT.SQEPS .AND. Y.LE.0.5) ATANH = X*(1.0 + CSEVL (8.*X*X-1.,
     1  ATNHCS, NTERMS))
      IF (Y.GT.0.5) ATANH = 0.5*ALOG((1.0+X)/(1.0-X))
C
      RETURN
      END