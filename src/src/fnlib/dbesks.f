      SUBROUTINE DBESKS(XNU,X,NIN,BK)
C***BEGIN PROLOGUE  DBESKS
C***DATE WRITTEN   770601   (YYMMDD)
C***REVISION DATE  820801   (YYMMDD)
C***REVISION HISTORY  (YYMMDD)
C   000330  Modified array declarations.  (JEC)
C***CATEGORY NO.  C10B3
C***KEYWORDS  BESSEL FUNCTION,DOUBLE PRECISION,FRACTIONAL ORDER,
C             MODIFIED BESSEL FUNCTION,SEQUENCE,SPECIAL FUNCTION,
C             THIRD KIND
C***AUTHOR  FULLERTON, W., (LANL)
C***PURPOSE  Computes a d.p. sequence of modified Bessel functions of
C            the third kind of fractional order.
C***DESCRIPTION
C
C DBESKS computes a sequence of modified Bessel functions of the third
C kind of order XNU + I at X, where X .GT. 0, XNU lies in (-1,1),
C and I = 0, 1, ... , NIN - 1, if NIN is positive and I = 0, 1, ... ,
C NIN + 1, if NIN is negative.  On return, the vector BK(.) contains
C the results at X for order starting at XNU.  XNU, X, and BK are
C double precision.  NIN is an integer.
C***REFERENCES  (NONE)
C***ROUTINES CALLED  D1MACH,DBSKES,XERROR
C***END PROLOGUE  DBESKS
      DOUBLE PRECISION XNU, X, BK(*), EXPXI, XMAX, D1MACH
      DATA XMAX / 0.D0 /
C***FIRST EXECUTABLE STATEMENT  DBESKS
      IF (XMAX.EQ.0.D0) XMAX = -DLOG (D1MACH(1))
C
      IF (X.GT.XMAX) CALL XERROR ( 'DBESKS  X SO BIG BESSEL K UNDERFLOWS
     1', 36, 1, 2)
C
      CALL DBSKES (XNU, X, NIN, BK)
C
      EXPXI = DEXP (-X)
      N = IABS (NIN)
      DO 20 I=1,N
        BK(I) = EXPXI * BK(I)
 20   CONTINUE
C
      RETURN
      END
