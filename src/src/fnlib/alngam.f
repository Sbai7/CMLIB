      FUNCTION ALNGAM(X)
C***BEGIN PROLOGUE  ALNGAM
C***DATE WRITTEN   770601   (YYMMDD)
C***REVISION DATE  820801   (YYMMDD)
C***CATEGORY NO.  C7A
C***KEYWORDS  GAMMA FUNCTION,LOGARITHM,SPECIAL FUNCTION
C***AUTHOR  FULLERTON, W., (LANL)
C***PURPOSE  Computes the log of the absolute value of the Gamma
C            function
C***DESCRIPTION
C
C ALNGAM(X) computes the logarithm of the absolute value of the
C gamma function at X.
C***REFERENCES  (NONE)
C***ROUTINES CALLED  GAMMA,R1MACH,R9LGMC,XERROR
C***END PROLOGUE  ALNGAM
      EXTERNAL GAMMA
      DATA SQ2PIL / 0.9189385332 0467274E0/
      DATA SQPI2L / 0.2257913526 4472743E0/
      DATA PI     / 3.1415926535 8979324E0/
      DATA XMAX, DXREL / 0., 0. /
C***FIRST EXECUTABLE STATEMENT  ALNGAM
      IF (XMAX.NE.0.) GO TO 10
      XMAX = R1MACH(2)/ALOG(R1MACH(2))
      DXREL = SQRT (R1MACH(4))
C
 10   Y = ABS(X)
      IF (Y.GT.10.0) GO TO 20
C
C ALOG (ABS (GAMMA(X))) FOR  ABS(X) .LE. 10.0
C
      ALNGAM = ALOG (ABS (GAMMA(X)))
      RETURN
C
C ALOG (ABS (GAMMA(X))) FOR ABS(X) .GT. 10.0
C
 20   IF (Y.GT.XMAX) CALL XERROR ( 'ALNGAM  ABS(X) SO BIG ALNGAM OVERFLO
     1WS', 38, 2, 2)
C
      IF (X.GT.0.) ALNGAM = SQ2PIL + (X-0.5)*ALOG(X) - X + R9LGMC(Y)
      IF (X.GT.0.) RETURN
C
      SINPIY = ABS (SIN(PI*Y))
      IF (SINPIY.EQ.0.) CALL XERROR ( 'ALNGAM  X IS A NEGATIVE INTEGER',
     1  31, 3, 2)
C
      IF (ABS((X-AINT(X-0.5))/X).LT.DXREL) CALL XERROR ( 'ALNGAM  ANSWER
     1 LT HALF PRECISION BECAUSE X TOO NEAR NEGATIVE INTEGER', 68, 1, 1)
C
      ALNGAM = SQPI2L + (X-0.5)*ALOG(Y) - X - ALOG(SINPIY) - R9LGMC(Y)
      RETURN
C
      END
