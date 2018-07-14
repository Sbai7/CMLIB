C
C   DRIVER FOR TESTING CMLIB ROUTINES
C      QAG   QAGI   QAGP   QAGS   QAWC   QAWF   QAWO   QAWS   QNG
C
C    ONE INPUT DATA CARD IS REQUIRED
C         READ(LIN,1) KPRINT,TIMES
C    1    FORMAT(I1,E10.0)
C
C     KPRINT = 0   NO PRINTING
C              1   NO PRINTING FOR PASSED TESTS, SHORT MESSAGE
C                  FOR FAILED TESTS
C              2   PRINT SHORT MESSAGE FOR PASSED TESTS, FULLER
C                  INFORMATION FOR FAILED TESTS
C              3   PRINT COMPLETE QUICK-CHECK RESULTS
C
C                ***IMPORTANT NOTE***
C         ALL QUICK CHECKS USE ROUTINES R2MACH AND D2MACH
C         TO SET THE ERROR TOLERANCES.
C     TIMES IS A CONSTANT MULTIPLIER THAT CAN BE USED TO SCALE THE
C     VALUES OF R1MACH AND D1MACH SO THAT
C               R2MACH(I) = R1MACH(I) * TIMES   FOR I=3,4,5
C               D2MACH(I) = D1MACH(I) * TIMES   FOR I=3,4,5
C     THIS MAKES IT EASILY POSSIBLE TO CHANGE THE ERROR TOLERANCES
C     USED IN THE QUICK CHECKS.
C     IF TIMES .LE. 0.0 THEN TIMES IS DEFAULTED TO 1.0
C
C              ***END NOTE***
C
      COMMON/UNIT/LUN
      COMMON/MSG/ICNT,JTEST(38)
      COMMON/XXMULT/TIMES
      LUN=I1MACH(2)
      LIN=I1MACH(1)
      ITEST=1
C
C     READ KPRINT,TIMES PARAMETERS FROM DATA CARD..
C
      READ(LIN,1) KPRINT,TIMES
1     FORMAT(I1,E10.0)
      IF(TIMES.LE.0.) TIMES=1.
      CALL XSETUN(LUN)
      CALL XSETF(-1)
      CALL XERMAX(1000)
      IF(KPRINT.LE.2) CALL XERMAX(0)
C  TEST QUADPACK ROUTINES
      CALL QADTST(KPRINT,IPASS)
      ITEST=ITEST*IPASS
C
      IF(KPRINT.GE.1.AND.ITEST.NE.1) WRITE(LUN,2)
2     FORMAT(/' ***** WARNING -- AT LEAST ONE TEST FOR QUAKPKS,
     1 SUBLIBRARY FAILED ***** ')
      IF(KPRINT.GE.1.AND.ITEST.EQ.1) WRITE(LUN,3)
3     FORMAT(/' ----- QUADPKS SUBLIBRARY PASSED ALL TESTS ----- ')
            END
      DOUBLE PRECISION FUNCTION D2MACH(I)
      DOUBLE PRECISION D1MACH
      COMMON/XXMULT/TIMES
      D2MACH=D1MACH(I)
      IF(I.EQ.1.OR. I.EQ.2) RETURN
      D2MACH = D2MACH * DBLE(TIMES)
      RETURN
      END
      REAL FUNCTION R2MACH(I)
      COMMON/XXMULT/TIMES
      R2MACH=R1MACH(I)
      IF(I.EQ.1.OR. I.EQ.2) RETURN
      R2MACH = R2MACH * TIMES
      RETURN
      END
      SUBROUTINE QADTST(KPRINT,IPASS)
C***BEGIN PROLOGUE
C***CALLING PROGRAM FOR QUICK CHECK ROUTINES CQNG, CQAG,
C    CQAGS, CQAGP, CQAGI, CQAWO, CQAWF AND CQAWS
C***AUTHOR           JERALD GROSS
C                     NATIONAL BUREAU OF STANDARDS
C***DESCRIPTION
C..........................................................
C
C  THIS PROGRAM CALLS THE QUICK CHECK ROUTINES FOR QUADPACK
C  INTEGRATORS QNG, QAG, QAGS, QAGP, QAGI, QAWO, QAWF
C  AND QAWS
C  KPRINT SPECIFIES THE AMOUNT OF PRINTING TO BE DONE BY
C  EACH QUICK CHECK ROUTINE
C  IPASS IS OUTPUT FROM EACH QUICK CHECK ROUTINE AND IS 1
C  WHEN ALL THE TESTS IN THE QUICK CHECK ROUTINE PASSED, 0
C  OTHERWISE.
C  FLAG IS 1 WHEN ALL THE TESTS PASS FOR EACH QUICK
C  ROUTINE, 0 OTHERWISE.
C
C..........................................................
C***END PROLOGUE
C
      COMMON/MSG/ICNT,ITEST(38)
      COMMON/UNIT/LUN
      INTEGER IPASS,LUN,KPRINT,FLAG
      FLAG = 1
      IF(KPRINT.GT.2) WRITE (LUN,5)
    5 FORMAT(' ********',/,' NOTE- (QUADPACK SINGLE PRECISION TESTS)',
     X /,' THIS ROUTINE TESTS VARIOUS QUADPACK OPTIONS AND PRINTS',
     X /,' SOME ERROR DIAGNOSTICS IN SUBROUTINE XERROR.  THERE ',/,
     X ' SHOULD BE 38 ABNORMAL RETURN MESSAGES.  THE LAST LINE OF ',
     X /,' OUTPUT SHOULD BE-ALL QUADPACK QUICK CHECK ROUTINES PASSED-',
     X /,' (IMMEDIATELY FOLLOWING THE LAST ABNORMAL RETURN MESSAGE).',
     X /,' ANY OTHER FINAL LINE INDICATES AN ERROR.',/,' ********')
      CALL CQNG(LUN,KPRINT,IPASS)
      IF (IPASS.NE.0) GO TO 10
        IF(KPRINT.GE.1) WRITE(LUN,15)
   15   FORMAT(' SOME TEST(S) IN CQNG FAILED')
        FLAG = 0
   10 CONTINUE
      CALL CQAG(LUN,KPRINT,IPASS)
      IF (IPASS.NE.0) GO TO 20
        IF(KPRINT.GE.1) WRITE(LUN,25)
   25   FORMAT(' SOME TEST(S) IN CQAG FAILED')
        FLAG = 0
   20 CONTINUE
      CALL CQAGS(LUN,KPRINT,IPASS)
      IF (IPASS.NE.0) GO TO 30
        IF(KPRINT.GE.1) WRITE(LUN,35)
   35   FORMAT(' SOME TEST(S) IN CQAGS FAILED')
        FLAG = 0
   30 CONTINUE
      CALL CQAGP(LUN,KPRINT,IPASS)
      IF (IPASS.NE.0) GO TO 40
        IF(KPRINT.GE.1) WRITE(LUN,45)
   45   FORMAT(' SOME TEST(S) IN CQAGP FAILED')
        FLAG = 0
   40 CONTINUE
      CALL CQAGI(LUN,KPRINT,IPASS)
      IF (IPASS.NE.0) GO TO 50
        IF(KPRINT.GE.1) WRITE(LUN,55)
   55   FORMAT(' SOME TEST(S) IN CQAGI FAILED')
        FLAG = 0
   50 CONTINUE
      CALL CQAWO(LUN,KPRINT,IPASS)
      IF (IPASS.NE.0) GO TO 60
        IF(KPRINT.GE.1) WRITE(LUN,65)
   65   FORMAT(' SOME TEST(S) IN CQAWO FAILED')
        FLAG = 0
   60 CONTINUE
      CALL CQAWF(LUN,KPRINT,IPASS)
      IF (IPASS.NE.0) GO TO 70
        IF(KPRINT.GE.1) WRITE(LUN,75)
   75   FORMAT(' SOME TEST(S) IN CQAWF FAILED')
        FLAG = 0
   70 CONTINUE
      CALL CQAWS(LUN,KPRINT,IPASS)
      IF (IPASS.NE.0) GO TO 80
        IF(KPRINT.GE.1) WRITE(LUN,85)
   85   FORMAT(' SOME TEST(S) IN CQAWS FAILED')
        FLAG = 0
   80 CONTINUE
      CALL CQAWC(LUN,KPRINT,IPASS)
      IF (IPASS.NE.0) GO TO 90
        IF(KPRINT.GE.1) WRITE(LUN,95)
   95   FORMAT(' SOME TEST(S) IN CQAWC FAILED')
        FLAG = 0
   90 CONTINUE
      IPASS=FLAG
      IF(KPRINT.GT.1.AND.IPASS.EQ.1)WRITE(LUN,104)
      IF(KPRINT.NE.0.AND.IPASS.EQ.0)WRITE(LUN,105)
104   FORMAT(' ***** ALL QUADPACK ROUTINES PASSED ***** ')
  105 FORMAT(' ***** SOME QUADPACK TESTS FAILED ***** ')
      RETURN
      END
      SUBROUTINE CQAG(KO,KPRINT,IPASS)
C
C SUBROUTINES OR FUNCTIONS NEEDED- R2MACH,QAG,F1G,F2G,F3G,CPRIN
C
C FOR FURTHER DOCUMENTATION SEE ROUTINE CQPDOC
C
      REAL A,ABSERR,B,R2MACH,EPMACH,EPSABS,EPSREL,ERROR,EXACT1,
     *  EXACT2,EXACT3,F1G,F2G,F3G,PI,RESULT,UFLOW,WORK
      INTEGER IER,IP,IPASS,IWORK,KEY,KPRINT,LAST,LENW,LIMIT,
     *  NEVAL
      DIMENSION IERV(2),IWORK(100),WORK(400)
      EXTERNAL F1G,F2G,F3G
      DATA PI/0.31415926535897932E+01/
      DATA EXACT1/0.1154700538379252E+01/
      DATA EXACT2/0.11780972450996172E+00/
      DATA EXACT3/0.1855802E+02/
C
C TEST ON IER = 0
C
      IPASS = 1
      LIMIT = 100
      LENW = LIMIT*4
      EPSABS = 0.0E+00
      EPMACH = R2MACH(4)
      KEY = 6
      EPSREL = AMAX1(SQRT(EPMACH),0.1E-07)
      A = 0.0E+00
      B = 0.1E+01
      CALL QAG(F1G,A,B,EPSABS,EPSREL,KEY,RESULT,ABSERR,NEVAL,IER,
     *  LIMIT,LENW,LAST,IWORK,WORK)
      IERV(1) = IER
      IP = 0
      ERROR = ABS(EXACT1-RESULT)
      IF(IER.EQ.0.AND.ERROR.LE.ABSERR.AND.ABSERR.LE.EPSREL*ABS(EXACT1))
     *  IP = 1
      IF(IP.EQ.0) IPASS = 0
      CALL CPRIN(KO,0,KPRINT,IP,EXACT1,RESULT,ABSERR,NEVAL,IERV,1)
C
C TEST ON IER = 1
C
      LIMIT = 1
      LENW = LIMIT*4
      B = PI*0.2E+01
      CALL QAG(F2G,A,B,EPSABS,EPSREL,KEY,RESULT,ABSERR,NEVAL,IER,
     *  LIMIT,LENW,LAST,IWORK,WORK)
      IERV(1) = IER
      IP = 0
      IF(IER.EQ.1) IP = 1
      IF(IP.EQ.0) IPASS = 0
      CALL CPRIN(KO,1,KPRINT,IP,EXACT2,RESULT,ABSERR,NEVAL,IERV,1)
C
C TEST ON IER = 2 OR 1
C
      UFLOW = R2MACH(1)
      LIMIT = 100
      LENW = LIMIT*4
      CALL QAG(F2G,A,B,UFLOW,0.0E+00,KEY,RESULT,ABSERR,NEVAL,IER,
     *  LIMIT,LENW,LAST,IWORK,WORK)
      IERV(1) = IER
      IERV(2) = 1
      IP = 0
      IF(IER.EQ.2.OR.IER.EQ.1) IP = 1
      IF(IP.EQ.0) IPASS = 0
      CALL CPRIN(KO,2,KPRINT,IP,EXACT2,RESULT,ABSERR,NEVAL,IERV,2)
C
C TEST ON IER = 3 OR 1
C
      B = 0.1E+01
      CALL QAG(F3G,A,B,EPSABS,EPSREL,1,RESULT,ABSERR,NEVAL,IER,
     *  LIMIT,LENW,LAST,IWORK,WORK)
      IERV(1) = IER
      IERV(2) = 1
      IP = 0
      IF(IER.EQ.3.OR.IER.EQ.1) IP = 1
      IF(IP.EQ.0) IPASS = 0
      CALL CPRIN(KO,3,KPRINT,IP,EXACT3,RESULT,ABSERR,NEVAL,IERV,2)
C
C TEST ON IER = 6
C
      LENW = 1
      CALL QAG(F1G,A,B,EPSABS,EPSREL,KEY,RESULT,ABSERR,NEVAL,IER,
     *  LIMIT,LENW,LAST,IWORK,WORK)
      IERV(1) = IER
      IP = 0
      IF(IER.EQ.6.AND.RESULT.EQ.0.0E+00.AND.ABSERR.EQ.0.0E+00.AND.
     *  NEVAL.EQ.0.AND.LAST.EQ.0) IP = 1
      IF(IP.EQ.0) IPASS = 0
      CALL CPRIN(KO,6,KPRINT,IP,EXACT1,RESULT,ABSERR,NEVAL,IERV,1)
      RETURN
      END
      SUBROUTINE CQAGI(KO,KPRINT,IPASS)
C
C SUBROUTINES OR FUNCTIONS NEEDED- R2MACH,QAGI,T0,T1,T2,T3,T4,T5,CPRIN,
C                                  F0S,F1S,F2S,F3S,F4S,F5S
C
C FOR FURTHER DOCUMENTATION SEE ROUTINE CQPDOC
C
      REAL ABSERR,BOUND,R2MACH,EPMACH,EPSABS,
     *  EPSREL,ERROR,EXACT0,EXACT1,EXACT2,EXACT3,EXACT4,
     *  OFLOW,RESULT,T0,T1,T2,T3,T4,T5,UFLOW,WORK
      INTEGER IER,IP,IPASS,IWORK,KO,KPRINT,LAST,LENW,LIMIT,NEVAL
      DIMENSION WORK(800),IWORK(200),IERV(4)
      EXTERNAL T0,T1,T2,T3,T4,T5
      DATA EXACT0/2.0E+00/,EXACT1/0.115470066904E1/
      DATA EXACT2/0.909864525656E-02/
      DATA EXACT3/0.31415926535897932E+01/
      DATA EXACT4/0.19984914554328673E+04/
C
C TEST ON IER = 0
C
      IPASS = 1
      LIMIT = 200
      LENW = LIMIT*4
      EPSABS = 0.0E+00
      EPMACH = R2MACH(4)
      EPSREL = AMAX1(SQRT(EPMACH),0.1E-07)
      BOUND = 0.0E+00
      INF = 1
      CALL QAGI(T0,BOUND,INF,EPSABS,EPSREL,RESULT,ABSERR,NEVAL,IER,
     *  LIMIT,LENW,LAST,IWORK,WORK)
      ERROR = ABS(RESULT-EXACT0)
      IERV(1) = IER
      IP = 0
      IF(IER.EQ.0.AND.ERROR.LE.ABSERR.AND.ABSERR.LE.EPSREL*ABS(EXACT0))
     *  IP = 1
      IF(IP.EQ.0) IPASS = 0
      CALL CPRIN(KO,0,KPRINT,IP,EXACT0,RESULT,ABSERR,NEVAL,IERV,1)
C
C TEST ON IER = 1
C
      CALL QAGI(T1,BOUND,INF,EPSABS,EPSREL,RESULT,ABSERR,NEVAL,IER,
     *  1,4,LAST,IWORK,WORK)
      IERV(1) = IER
      IP = 0
      IF(IER.EQ.1) IP = 1
      IF(IP.EQ.0) IPASS = 0
      CALL CPRIN(KO,1,KPRINT,IP,EXACT1,RESULT,ABSERR,NEVAL,IERV,1)
C
C TEST ON IER = 2 OR 4 OR 1
C
      UFLOW = R2MACH(1)
      A = 0.1E+00
      CALL QAGI(T2,BOUND,INF,UFLOW,0.0E+00,RESULT,ABSERR,NEVAL,IER,
     *  LIMIT,LENW,LAST,IWORK,WORK)
      IERV(1) = IER
      IERV(2) = 4
      IERV(3) = 1
      IP = 0
      IF(IER.EQ.2.OR.IER.EQ.4.OR.IER.EQ.1) IP = 1
      IF(IP.EQ.0) IPASS = 0
      CALL CPRIN(KO,2,KPRINT,IP,EXACT2,RESULT,ABSERR,NEVAL,IERV,3)
C
C TEST ON IER = 3 OR 4 OR 1
C
      A = 0.0E+00
      B = 0.5E+01
      CALL QAGI(T3,BOUND,INF,UFLOW,0.0E+00,RESULT,ABSERR,NEVAL,IER,
     *  LIMIT,LENW,LAST,IWORK,WORK)
      IERV(1) = IER
      IERV(2) = 4
      IERV(3) = 1
      IP = 0
      IF(IER.EQ.3.OR.IER.EQ.4.OR.IER.EQ.1) IP = 1
      IF(IP.EQ.0) IPASS = 0
      CALL CPRIN(KO,3,KPRINT,IP,EXACT3,RESULT,ABSERR,NEVAL,IERV,3)
C
C TEST ON IER = 4 OR 3 OR 1
C
      B = 0.1E+01
      CALL QAGI(T4,BOUND,INF,EPSABS,EPSREL,RESULT,ABSERR,NEVAL,IER,
     *  LIMIT,LENW,LAST,IWORK,WORK)
      IERV(1) = IER
      IERV(2) = 3
      IERV(3) = 1
      IERV(4)=2
      IP = 0
      IF(IER.EQ.4.OR.IER.EQ.3.OR.IER.EQ.1.OR.IER.EQ.2) IP = 1
      IF(IP.EQ.0) IPASS = 0
      CALL CPRIN(KO,4,KPRINT,IP,EXACT4,RESULT,ABSERR,NEVAL,IERV,4)
C
C TEST ON IER = 5
C
      OFLOW = R2MACH(2)
      CALL QAGI(T5,BOUND,INF,EPSABS,EPSREL,RESULT,ABSERR,NEVAL,IER,
     *  LIMIT,LENW,LAST,IWORK,WORK)
      IERV(1) = IER
      IP = 0
      IF(IER.EQ.5) IP = 1
      IF(IP.EQ.0) IPASS = 0
      CALL CPRIN(KO,5,KPRINT,IP,OFLOW,RESULT,ABSERR,NEVAL,IERV,1)
C
C TEST ON IER = 6
C
      CALL QAGI(T1,BOUND,INF,EPSABS,0.0E+00,RESULT,ABSERR,NEVAL,IER,
     *  LIMIT,LENW,LAST,IWORK,WORK)
      IERV(1) = IER
      IP = 0
      IF(IER.EQ.6.AND.RESULT.EQ.0.0E+00.AND.ABSERR.EQ.0.0E+00.AND.
     *  NEVAL.EQ.0.AND.LAST.EQ.0) IP = 1
      IF(IP.EQ.0) IPASS = 0
      CALL CPRIN(KO,6,KPRINT,IP,EXACT1,RESULT,ABSERR,NEVAL,IERV,1)
      RETURN
      END
      SUBROUTINE CQAGP(KO,KPRINT,IPASS)
C
C SUBROUTINES OR FUNCTIONS NEEDED- R2MACH,QAGP,F1P,F2P,F3P,F4P,CPRIN
C
C FOR FURTHER DOCUMENTATION SEE ROUTINE CQPDOC
C
      REAL A,ABSERR,B,R2MACH,EPMACH,EPSABS,EPSREL,ERROR,EXACT1,
     *  EXACT2,EXACT3,F1P,F2P,F3P,F4P,OFLOW,POINTS,P1,P2,RESULT,
     *  UFLOW,WORK
      INTEGER IER,IP,IPASS,IWORK,KO,KPRINT,LAST,LENIW,LENW,LIMIT,
     *  NEVAL,NPTS2
      DIMENSION IERV(4),IWORK(205),POINTS(5),WORK(405)
      EXTERNAL F1P,F2P,F3P,F4P
      DATA EXACT1/0.4285277667368085E+01/
      DATA EXACT2/0.909864525656E-2/
      DATA EXACT3/0.31415926535897932E+01/
      DATA P1/0.1428571428571428E+00/
      DATA P2/0.6666666666666667E+00/
C
C TEST ON IER = 0
C
      IPASS = 1
      NPTS2 = 4
      LIMIT = 100
      LENIW = LIMIT*2+NPTS2
      LENW = LIMIT*4+NPTS2
      EPSABS = 0.0E+00
      EPMACH = R2MACH(4)
      EPSREL = AMAX1(SQRT(EPMACH),0.1E-07)
      A = 0.0E+00
      B = 0.1E+01
      POINTS(1) = P1
      POINTS(2) = P2
      CALL QAGP(F1P,A,B,NPTS2,POINTS,EPSABS,EPSREL,RESULT,ABSERR,NEVAL,
     *  IER,LENIW,LENW,LAST,IWORK,WORK)
      ERROR = ABS(RESULT-EXACT1)
      IERV(1) = IER
      IP = 0
      IF(IER.EQ.0.AND.ERROR.LE.EPSREL*ABS(EXACT1)) IP = 1
      IF(IP.EQ.0) IPASS = 0
      CALL CPRIN(KO,0,KPRINT,IP,EXACT1,RESULT,ABSERR,NEVAL,IERV,1)
C
C TEST ON IER = 1
C
      LENIW = 10
      LENW = LENIW*2-NPTS2
      CALL QAGP(F1P,A,B,NPTS2,POINTS,EPSABS,EPSREL,RESULT,ABSERR,NEVAL,
     *  IER,LENIW,LENW,LAST,IWORK,WORK)
      IERV(1) = IER
      IP = 0
      IF(IER.EQ.1) IP = 1
      IF(IP.EQ.0) IPASS = 0
      CALL CPRIN(KO,1,KPRINT,IP,EXACT1,RESULT,ABSERR,NEVAL,IERV,1)
C
C TEST ON IER = 2, 4, 1 OR 3
C
      NPTS2 = 3
      POINTS(1) = 0.1E+00
      LENIW = LIMIT*2+NPTS2
      LENW = LIMIT*4+NPTS2
      UFLOW = R2MACH(1)
      A = 0.1E+00
      CALL QAGP(F2P,A,B,NPTS2,POINTS,UFLOW,0.0E+00,RESULT,ABSERR,NEVAL,
     *  IER,LENIW,LENW,LAST,IWORK,WORK)
      IERV(1) = IER
      IERV(2) = 4
      IERV(3) = 1
      IERV(4) = 3
      IP = 0
      IF(IER.EQ.2.OR.IER.EQ.4.OR.IER.EQ.1.OR.IER.EQ.3) IP = 1
      IF(IP.EQ.0) IPASS = 0
      CALL CPRIN(KO,2,KPRINT,IP,EXACT2,RESULT,ABSERR,NEVAL,IERV,4)
C
C TEST ON IER = 3 OR 4 OR 1 OR 2
C
      NPTS2 = 2
      LENIW = LIMIT*2+NPTS2
      LENW = LIMIT*4+NPTS2
      A = 0.0E+00
      B = 0.5E+01
      CALL QAGP(F3P,A,B,NPTS2,POINTS,UFLOW,0.0E+00,RESULT,ABSERR,NEVAL,
     *  IER,LENIW,LENW,LAST,IWORK,WORK)
      IERV(1) = IER
      IERV(2) = 4
      IERV(3) = 1
      IERV(4)=2
      IP = 0
      IF(IER.EQ.3.OR.IER.EQ.4.OR.IER.EQ.1.OR.IER.EQ.2) IP = 1
      IF(IP.EQ.0) IPASS = 0
      CALL CPRIN(KO,3,KPRINT,IP,EXACT3,RESULT,ABSERR,NEVAL,IERV,4)
C
C TEST ON IER = 5
C
      B = 0.1E+01
      CALL QAGP(F4P,A,B,NPTS2,POINTS,EPSABS,EPSREL,RESULT,ABSERR,NEVAL,
     *  IER,LENIW,LENW,LAST,IWORK,WORK)
      IERV(1) = IER
      IP = 0
      IF(IER.EQ.5) IP = 1
      IF(IP.EQ.0) IPASS = 0
      OFLOW = R2MACH(2)
      CALL CPRIN(KO,5,KPRINT,IP,OFLOW,RESULT,ABSERR,NEVAL,IERV,1)
C
C TEST ON IER = 6
C
      NPTS2 = 5
      LENIW = LIMIT*2+NPTS2
      LENW = LIMIT*4+NPTS2
      POINTS(1) = P1
      POINTS(2) = P2
      POINTS(3) = 0.3E+01
      CALL QAGP(F1P,A,B,NPTS2,POINTS,EPSABS,EPSREL,RESULT,ABSERR,NEVAL,
     *  IER,LENIW,LENW,LAST,IWORK,WORK)
      IERV(1) = IER
      IP = 0
      IF(IER.EQ.6.AND.RESULT.EQ.0.0E+00.AND.ABSERR.EQ.0.0E+00.AND.
     *  NEVAL.EQ.0.AND.LAST.EQ.0) IP = 1
      IF(IP.EQ.0) IPASS = 0
      CALL CPRIN(KO,6,KPRINT,IP,EXACT1,RESULT,ABSERR,NEVAL,IERV,1)
      RETURN
      END
      SUBROUTINE CQAGS(KO,KPRINT,IPASS)
C
C SUBROUTINES OR FUNCTIONS NEEDED- R2MACH,QAGS,F0S,F1S,F2S,F3S,F4S,F5S,
C                                  CPRIN
C
C FOR FURTHER DOCUMENTATION SEE ROUTINE CQPDOC
C
      REAL A,ABSERR,B,R2MACH,EPMACH,EPSABS,
     *  EPSREL,ERROR,EXACT0,EXACT1,EXACT2,EXACT3,EXACT4,
     *  F0S,F1S,F2S,F3S,F4S,F5S,OFLOW,RESULT,UFLOW,WORK
      INTEGER IER,IP,IPASS,IWORK,KPRINT,LAST,LENW,LIMIT,NEVAL
      DIMENSION IERV(4),IWORK(200),WORK(800)
      EXTERNAL F0S,F1S,F2S,F3S,F4S,F5S
      DATA EXACT0/0.2E+01/
      DATA EXACT1/0.115470066904E+01/
      DATA EXACT2/0.909864525656E-02/
      DATA EXACT3/0.31415926535897932E+01/
      DATA EXACT4/0.19984914554328673E+04/
C
C TEST ON IER = 0
C
      IPASS = 1
      LIMIT = 200
      LENW = LIMIT*4
      EPSABS = 0.0E+00
      EPMACH = R2MACH(4)
      EPSREL = AMAX1(SQRT(EPMACH),0.1E-07)
      A = 0.0E+00
      B = 0.1E+01
      CALL QAGS(F0S,A,B,EPSABS,EPSREL,RESULT,ABSERR,NEVAL,IER,
     *  LIMIT,LENW,LAST,IWORK,WORK)
      ERROR = ABS(RESULT-EXACT0)
      IERV(1) = IER
      IP = 0
      IF(IER.EQ.0.AND.ERROR.LE.ABSERR.AND.ABSERR.LE.EPSREL*ABS(EXACT0))
     *  IP = 1
      IF(IP.EQ.0) IPASS = 0
      CALL CPRIN(KO,0,KPRINT,IP,EXACT0,RESULT,ABSERR,NEVAL,IERV,1)
C
C TEST ON IER = 1
C
      CALL QAGS(F1S,A,B,EPSABS,EPSREL,RESULT,ABSERR,NEVAL,IER,
     *  1,4,LAST,IWORK,WORK)
      IERV(1) = IER
      IP = 0
      IF(IER.EQ.1) IP = 1
      IF(IP.EQ.0) IPASS = 0
      CALL CPRIN(KO,1,KPRINT,IP,EXACT1,RESULT,ABSERR,NEVAL,IERV,1)
C
C TEST ON IER = 2 OR 4 OR 1
C
      UFLOW = R2MACH(1)
      A = 0.1E+00
      CALL QAGS(F2S,A,B,UFLOW,0.0E+00,RESULT,ABSERR,NEVAL,IER,
     *  LIMIT,LENW,LAST,IWORK,WORK)
      IERV(1) = IER
      IERV(2) = 4
      IERV(3) = 1
      IP = 0
      IF(IER.EQ.2.OR.IER.EQ.4.OR.IER.EQ.1) IP = 1
      IF(IP.EQ.0) IPASS = 0
      CALL CPRIN(KO,2,KPRINT,IP,EXACT2,RESULT,ABSERR,NEVAL,IERV,3)
C
C TEST ON IER = 3 OR 4 OR 1 OR 2
C
      A = 0.0E+00
      B = 0.5E+01
      CALL QAGS(F3S,A,B,UFLOW,0.0E+00,RESULT,ABSERR,NEVAL,IER,
     *  LIMIT,LENW,LAST,IWORK,WORK)
      IERV(1) = IER
      IERV(2) = 4
      IERV(3) = 1
      IERV(4) = 2
      IP = 0
      IF(IER.EQ.3.OR.IER.EQ.4.OR.IER.EQ.1.OR.IER.EQ.2) IP = 1
      IF(IP.EQ.0) IPASS = 0
      CALL CPRIN(KO,3,KPRINT,IP,EXACT3,RESULT,ABSERR,NEVAL,IERV,4)
C
C TEST ON IER = 4 OR 3 OR 1 OR 0
C
      B = 0.1E+01
       EPSREL=1.E-4
      CALL QAGS(F4S,A,B,EPSABS,EPSREL,RESULT,ABSERR,NEVAL,IER,
     *  LIMIT,LENW,LAST,IWORK,WORK)
C      IER=4
      IERV(1) = IER
      IERV(2) = 3
      IERV(3) = 1
      IERV(4) = 0
      IP = 0
      IF(IER.EQ.4.OR.IER.EQ.3.OR.IER.EQ.1.OR.IER.EQ.0) IP = 1
      IF(IP.EQ.0) IPASS = 0
      CALL CPRIN(KO,4,KPRINT,IP,EXACT4,RESULT,ABSERR,NEVAL,IERV,4)
C
C TEST ON IER = 5
C
      OFLOW = R2MACH(2)
      CALL QAGS(F5S,A,B,EPSABS,EPSREL,RESULT,ABSERR,NEVAL,IER,
     *  LIMIT,LENW,LAST,IWORK,WORK)
      IERV(1) = IER
      IP = 0
      IF(IER.EQ.5) IP = 1
      IF(IP.EQ.0) IPASS = 0
      CALL CPRIN(KO,5,KPRINT,IP,OFLOW,RESULT,ABSERR,NEVAL,IERV,1)
C
C TEST ON IER = 6
C
      CALL QAGS(F1S,A,B,EPSABS,0.0E+00,RESULT,ABSERR,NEVAL,IER,
     *  LIMIT,LENW,LAST,IWORK,WORK)
      IERV(1) = IER
      IP = 0
      IF(IER.EQ.6.AND.RESULT.EQ.0.0E+00.AND.ABSERR.EQ.0.0E+00.AND.
     *  NEVAL.EQ.0.AND.LAST.EQ.0) IP = 1
      IF(IP.EQ.0) IPASS = 0
      CALL CPRIN(KO,6,KPRINT,IP,EXACT1,RESULT,ABSERR,NEVAL,IERV,1)
      RETURN
      END
      SUBROUTINE CQAWC(KO,KPRINT,IPASS)
C
C SUBROUTINES OR FUNCTIONS NEEDED- R2MACH,QAWC,F0O,CPRIN
C FOR FURTHER DOCUMENTATION SEE ROUTINE CQPDOC
C
      REAL A,ABSERR,B,R2MACH,EPMACH,EPSABS,
     *  EPSREL,ERROR,EXACT0,EXACT1,F0C,F1C,C,
     *  RESULT,UFLOW,WORK
      INTEGER IER,IP,IPASS,IWORK,KPRINT,LAST,LENW,LIMIT,NEVAL
      DIMENSION WORK(800),IWORK(200),IERV(2)
      EXTERNAL F0C,F1C
      DATA EXACT0/-0.6284617285065624E+03/
      DATA EXACT1/0.1855802E+01/
C
C TEST ON IER = 0
C
      IPASS = 1
      C = 0.5E+00
      A = -1.0E+00
      B = 1.0E+00
      LIMIT = 200
      LENW = LIMIT*4
      EPSABS = 0.0E+00
      EPMACH = R2MACH(4)
      EPSREL = AMAX1(SQRT(EPMACH),0.1E-07)
      CALL QAWC(F0C,A,B,C,EPSABS,EPSREL,RESULT,ABSERR,
     *  NEVAL,IER,LIMIT,LENW,LAST,IWORK,WORK)
      IERV(1) = IER
      IP = 0
      ERROR = ABS(EXACT0-RESULT)
      IF(IER.EQ.0.AND.ERROR.LE.ABSERR.AND.ABSERR.LE.EPSREL*ABS(EXACT0))
     *  IP = 1
      IF(IP.EQ.0) IPASS = 0
      CALL CPRIN(KO,0,KPRINT,IP,EXACT0,RESULT,ABSERR,NEVAL,IERV,1)
C
C TEST ON IER = 1
C
      CALL QAWC(F0C,A,B,C,EPSABS,EPSREL,RESULT,ABSERR,
     *  NEVAL,IER,1,4,LAST,IWORK,WORK)
      IERV(1) = IER
      IP = 0
      IF(IER.EQ.1) IP = 1
      IF(IP.EQ.0) IPASS = 0
      CALL CPRIN(KO,1,KPRINT,IP,EXACT0,RESULT,ABSERR,NEVAL,IERV,1)
C
C TEST ON IER = 2 OR 1
C
      UFLOW = R2MACH(1)
      CALL QAWC(F0C,A,B,C,UFLOW,0.0E+00,RESULT,ABSERR,
     *  NEVAL,IER,LIMIT,LENW,LAST,IWORK,WORK)
      IERV(1) = IER
      IERV(2) = 1
      IP = 0
      IF(IER.EQ.2.OR.IER.EQ.1) IP = 1
      IF(IP.EQ.0) IPASS = 0
      CALL CPRIN(KO,2,KPRINT,IP,EXACT0,RESULT,ABSERR,NEVAL,IERV,2)
C
C TEST ON IER = 3 OR 1
C
      CALL QAWC(F1C,0.0E+00,B,C,UFLOW,0.0E+00,RESULT,ABSERR,
     *  NEVAL,IER,LIMIT,LENW,LAST,IWORK,WORK)
      IERV(1) = IER
      IERV(2) = 1
      IP = 0
      IF(IER.EQ.3.OR.IER.EQ.1) IP = 1
      IF(IP.EQ.0) IPASS = 0
      CALL CPRIN(KO,3,KPRINT,IP,EXACT1,RESULT,ABSERR,NEVAL,IERV,2)
C
C TEST ON IER = 6
C
      EPSABS = 0.0E+00
      EPSREL = 0.0E+00
      CALL QAWC(F0C,A,B,C,EPSABS,EPSREL,RESULT,ABSERR,
     *  NEVAL,IER,LIMIT,LENW,LAST,IWORK,WORK)
      IERV(1) = IER
      IP = 0
      IF(IER.EQ.6) IP = 1
      IF(IP.EQ.0) IPASS = 0
      CALL CPRIN(KO,6,KPRINT,IP,EXACT0,RESULT,ABSERR,NEVAL,IERV,1)
      RETURN
      END
      SUBROUTINE CQAWF(KO,KPRINT,IPASS)
C
C SUBROUTINES OR FUNCTIONS NEEDED- R2MACH,QAWF,F0F,CPRIN
C
C FOR FURTHER DOCUMENTATION SEE ROUTINE CQPDOC
C
      REAL A,ABSERR,R2MACH,EPSABS,EPMACH,
     *  ERROR,EXACT0,F0F,F1F,OMEGA,PI,RESULT,UFLOW,WORK
      INTEGER IER,IP,IPASS,KPRINT,LENW,LIMIT,LIMLST,LST,NEVAL
      DIMENSION IERV(3),IWORK(450),WORK(1425)
      EXTERNAL F0F,F1F
      DATA EXACT0/0.1422552162575912E+01/
      DATA PI/0.31415926535897932E+01/
C
C TEST ON IER = 0
C
      IPASS = 1
      MAXP1 = 21
      LIMLST = 50
      LIMIT = 200
      LENIW = LIMIT*2+LIMLST
      LENW = LENIW*2+MAXP1*25
      EPMACH = R2MACH(4)
      EPSABS = AMAX1(SQRT(EPMACH),0.1E-02)
      A = 0.0E+00
      OMEGA = 0.8E+01
      INTEGR = 2
      CALL QAWF(F0F,A,OMEGA,INTEGR,EPSABS,RESULT,ABSERR,NEVAL,
     *  IER,LIMLST,LST,LENIW,MAXP1,LENW,IWORK,WORK)
      IERV(1) = IER
      IP = 0
      ERROR = ABS(EXACT0-RESULT)
      IF(IER.EQ.0.AND.ERROR.LE.ABSERR.AND.ABSERR.LE.EPSABS)
     *  IP = 1
      IF(IP.EQ.0) IPASS = 0
      CALL CPRIN(KO,0,KPRINT,IP,EXACT0,RESULT,ABSERR,NEVAL,IERV,1)
C
C TEST ON IER = 1
C
      LIMLST = 3
      LENIW = 403
      LENW = LENIW*2+MAXP1*25
      CALL QAWF(F0F,A,OMEGA,INTEGR,EPSABS,RESULT,ABSERR,NEVAL,
     *  IER,LIMLST,LST,LENIW,MAXP1,LENW,IWORK,WORK)
      IERV(1) = IER
      IP = 0
      IF(IER.EQ.1) IP = 1
      IF(IP.EQ.0) IPASS = 0
      CALL CPRIN(KO,1,KPRINT,IP,EXACT0,RESULT,ABSERR,NEVAL,IERV,1)
C
C TEST ON IER = 3 OR 4 OR 1
C
      LIMLST = 50
      LENIW = LIMIT*2+LIMLST
      LENW = LENIW*2+MAXP1*25
      UFLOW = R2MACH(1)
      CALL QAWF(F1F,A,0.0E+00,1,UFLOW,RESULT,ABSERR,NEVAL,
     *  IER,LIMLST,LST,LENIW,MAXP1,LENW,IWORK,WORK)
      IERV(1) = IER
      IERV(2) = 4
      IERV(3) = 1
      IP = 0
      IF(IER.EQ.3.OR.IER.EQ.4.OR.IER.EQ.1) IP = 1
      IF(IP.EQ.0) IPASS = 0
      CALL CPRIN(KO,3,KPRINT,IP,PI,RESULT,ABSERR,NEVAL,IERV,3)
C
C TEST ON IER = 6
C
      LIMLST = 50
      LENIW = 20
      CALL QAWF(F0F,A,OMEGA,INTEGR,EPSABS,RESULT,ABSERR,NEVAL,
     *  IER,LIMLST,LST,LENIW,MAXP1,LENW,IWORK,WORK)
      IERV(1) = IER
      IP = 0
      IF(IER.EQ.6) IP = 1
      IF(IP.EQ.0) IPASS = 0
      CALL CPRIN(KO,6,KPRINT,IP,EXACT0,RESULT,ABSERR,NEVAL,IERV,1)
C
C TEST ON IER = 7
C
      LIMLST = 50
      LENIW = 52
      LENW = LENIW*2+MAXP1*25
      CALL QAWF(F0F,A,OMEGA,INTEGR,EPSABS,RESULT,ABSERR,NEVAL,
     *  IER,LIMLST,LST,LENIW,MAXP1,LENW,IWORK,WORK)
      IERV(1) = IER
      IP = 0
      IF(IER.EQ.7) IP = 1
      IF(IP.EQ.0) IPASS = 0
      CALL CPRIN(KO,7,KPRINT,IP,EXACT0,RESULT,ABSERR,NEVAL,IERV,1)
      RETURN
      END
      SUBROUTINE CQAWO(KO,KPRINT,IPASS)
C
C SUBROUTINES OR FUNCTIONS NEEDED- R2MACH,QAWO,F0O,F1O,F2O,CPRIN
C
C FOR FURTHER DOCUMENTATION SEE ROUTINE CQPDOC
C
      REAL A,ABSERR,B,EPMACH,EPSABS,
     *  EPSREL,ERROR,EXACT0,F0O,F1O,F2O,
     *  OFLOW,OMEGA,PI,RESULT,R2MACH,UFLOW,WORK
      INTEGER IER,IERV,INTEGR,IP,IPASS,IWORK,KO,KPRINT,LAST,LENW,
     *  MAXP1,NEVAL
      DIMENSION WORK(1325),IWORK(400),IERV(4)
      EXTERNAL F0O,F1O,F2O
      DATA EXACT0/0.1042872789432789E+05/
      DATA PI/0.31415926535897932E+01/
C
C TEST ON IER = 0
C
      IPASS = 1
      MAXP1 = 21
      LENIW = 400
      LENW = LENIW*2+MAXP1*25
      EPSABS = 0.0E+00
      EPMACH = R2MACH(4)
      EPSREL = AMAX1(SQRT(EPMACH),0.1E-07)
      A = 0.0E+00
      B = PI
      OMEGA = 0.1E+01
      INTEGR = 2
      CALL QAWO(F0O,A,B,OMEGA,INTEGR,EPSABS,EPSREL,RESULT,ABSERR,NEVAL,
     *  IER,LENIW,MAXP1,LENW,LAST,IWORK,WORK)
      IERV(1) = IER
      IP = 0
      ERROR = ABS(EXACT0-RESULT)
      IF(IER.EQ.0.AND.ERROR.LE.ABSERR.AND.ABSERR.LE.EPSREL*ABS(EXACT0))
     *  IP = 1
      IF(IP.EQ.0) IPASS = 0
      CALL CPRIN(KO,0,KPRINT,IP,EXACT0,RESULT,ABSERR,NEVAL,IERV,1)
C
C TEST ON IER = 1
C
      LENIW = 2
      LENW = LENIW*2+MAXP1*25
      CALL QAWO(F0O,A,B,OMEGA,INTEGR,EPSABS,EPSREL,RESULT,ABSERR,NEVAL,
     *  IER,LENIW,MAXP1,LENW,LAST,IWORK,WORK)
      IERV(1) = IER
      IP = 0
      IF(IER.EQ.1) IP = 1
      IF(IP.EQ.0) IPASS = 0
      CALL CPRIN(KO,1,KPRINT,IP,EXACT0,RESULT,ABSERR,NEVAL,IERV,1)
C
C TEST ON IER = 2 OR 4 OR 1
C
      UFLOW = R2MACH(1)
      LENIW = 400
      LENW = LENIW*2+MAXP1*25
      CALL QAWO(F0O,A,B,OMEGA,INTEGR,UFLOW,0.0E+00,RESULT,ABSERR,NEVAL,
     *  IER,LENIW,MAXP1,LENW,LAST,IWORK,WORK)
      IERV(1) = IER
      IERV(2) = 4
      IERV(3) = 1
      IP = 0
      IF(IER.EQ.2.OR.IER.EQ.4.OR.IER.EQ.1) IP = 1
      IF(IP.EQ.0) IPASS = 0
      CALL CPRIN(KO,2,KPRINT,IP,EXACT0,RESULT,ABSERR,NEVAL,IERV,3)
C
C TEST ON IER = 3 OR 4 OR 1
C
      B = 0.5E+01
      OMEGA = 0.0E+00
      INTEGR = 1
      CALL QAWO(F1O,A,B,OMEGA,INTEGR,UFLOW,0.0E+00,RESULT,ABSERR,NEVAL,
     *  IER,LENIW,MAXP1,LENW,LAST,IWORK,WORK)
      IERV(1) = IER
      IERV(2) = 4
      IERV(3) = 1
      IP = 0
      IF(IER.EQ.3.OR.IER.EQ.4.OR.IER.EQ.1) IP = 1
      IF(IP.EQ.0) IPASS = 0
      CALL CPRIN(KO,3,KPRINT,IP,PI,RESULT,ABSERR,NEVAL,IERV,3)
C
C TEST ON IER = 5
C
      B = 0.1E+01
      OFLOW = R2MACH(2)
      CALL QAWO(F2O,A,B,OMEGA,INTEGR,EPSABS,EPSREL,RESULT,ABSERR,NEVAL,
     *  IER,LENIW,MAXP1,LENW,LAST,IWORK,WORK)
      IERV(1) = IER
      IP = 0
      IF(IER.EQ.5) IP = 1
      IF(IP.EQ.0) IPASS = 0
      CALL CPRIN(KO,5,KPRINT,IP,OFLOW,RESULT,ABSERR,NEVAL,IERV,1)
C
C TEST ON IER = 6
C
      INTEGR = 3
      CALL QAWO(F0O,A,B,OMEGA,INTEGR,EPSABS,EPSREL,RESULT,ABSERR,NEVAL,
     *  IER,LENIW,MAXP1,LENW,LAST,IWORK,WORK)
      IERV(1) = IER
      IP = 0
      IF(IER.EQ.6.AND.RESULT.EQ.0.0E+00.AND.ABSERR.EQ.0.0E+00.AND.
     *  NEVAL.EQ.0.AND.LAST.EQ.0) IP = 1
      IF(IP.EQ.0) IPASS = 0
      CALL CPRIN(KO,6,KPRINT,IP,EXACT0,RESULT,ABSERR,NEVAL,IERV,1)
      RETURN
      END
      SUBROUTINE CQAWS(KO,KPRINT,IPASS)
C
C SUBROUTINES OR FUNCTIONS NEEDED- R2MACH,QAWS,F0WS,F1WS,F2WS,CPRIN
C FOR FUTHER DOCUMENTATION SEE ROUTINE CQPDOC
C
      REAL A,ABSERR,B,R2MACH,EPMACH,EPSABS,
     *  EPSREL,ERROR,EXACT0,EXACT1,F0WS,F1WS,ALFA,BETA,
     *  RESULT,UFLOW,WORK
      INTEGER IER,IP,IPASS,IWORK,KPRINT,LAST,LENW,LIMIT,NEVAL,INTEGR
      DIMENSION WORK(800),IWORK(200),IERV(2)
      EXTERNAL F0WS,F1WS
      DATA EXACT0/0.5350190569223644E+00/
      DATA EXACT1/0.1998491554328673E+04/
C
C TEST ON IER = 0
C
      IPASS = 1
      ALFA = -0.5E+00
      BETA = -0.5E+00
      INTEGR = 1
      A = 0.0E+00
      B = 0.1E+01
      LIMIT = 200
      LENW = LIMIT*4
      EPSABS = 0.0E+00
      EPMACH = R2MACH(4)
      EPSREL = AMAX1(SQRT(EPMACH),0.1E-07)
      CALL QAWS(F0WS,A,B,ALFA,BETA,INTEGR,EPSABS,EPSREL,RESULT,ABSERR,
     *  NEVAL,IER,LIMIT,LENW,LAST,IWORK,WORK)
      IERV(1) = IER
      IP = 0
      ERROR = ABS(EXACT0-RESULT)
      IF(IER.EQ.0.AND.ERROR.LE.EPSREL*ABS(EXACT0))
     *  IP = 1
      IF(IP.EQ.0) IPASS = 0
      CALL CPRIN(KO,0,KPRINT,IP,EXACT0,RESULT,ABSERR,NEVAL,IERV,1)
C
C TEST ON IER = 1
C
      CALL QAWS(F0WS,A,B,ALFA,BETA,INTEGR,EPSABS,EPSREL,RESULT,ABSERR,
     *  NEVAL,IER,2,8,LAST,IWORK,WORK)
      IERV(1) = IER
      IP = 0
      IF(IER.EQ.1) IP = 1
      IF(IP.EQ.0) IPASS = 0
      CALL CPRIN(KO,1,KPRINT,IP,EXACT0,RESULT,ABSERR,NEVAL,IERV,1)
C
C TEST ON IER = 2 OR 1
C
      UFLOW = R2MACH(1)
      CALL QAWS(F0WS,A,B,ALFA,BETA,INTEGR,UFLOW,0.0E+00,RESULT,ABSERR,
     *  NEVAL,IER,LIMIT,LENW,LAST,IWORK,WORK)
      IERV(1) = IER
      IERV(2) = 1
      IP = 0
      IF(IER.EQ.2.OR.IER.EQ.1) IP = 1
      IF(IP.EQ.0) IPASS = 0
      CALL CPRIN(KO,2,KPRINT,IP,EXACT0,RESULT,ABSERR,NEVAL,IERV,2)
C
C TEST ON IER = 3 OR 1
C
      CALL QAWS(F1WS,A,B,ALFA,BETA,INTEGR,EPSABS,EPSREL,RESULT,ABSERR,
     *  NEVAL,IER,LIMIT,LENW,LAST,IWORK,WORK)
      IERV(1) = IER
      IERV(2) = 1
      IP = 0
      IF(IER.EQ.3.OR.IER.EQ.1) IP = 1
      IF(IP.EQ.0) IPASS = 0
      CALL CPRIN(KO,3,KPRINT,IP,EXACT1,RESULT,ABSERR,NEVAL,IERV,2)
C
C TEST ON IER = 6
C
      INTEGR = 0
      CALL QAWS(F1WS,A,B,ALFA,BETA,INTEGR,EPSABS,EPSREL,RESULT,ABSERR,
     *  NEVAL,IER,LIMIT,LENW,LAST,IWORK,WORK)
      IERV(1) = IER
      IP = 0
      IF(IER.EQ.6) IP = 1
      IF(IP.EQ.0) IPASS = 0
      CALL CPRIN(KO,6,KPRINT,IP,EXACT0,RESULT,ABSERR,NEVAL,IERV,1)
      RETURN
      END
      SUBROUTINE CQNG(KO,KPRINT,IPASS)
C
C SUBROUTINES OR FUNCTIONS NEEDED- R2MACH,QNG,F1N,F2N,CPRIN
C
C FOR FURTHER DOCUMENTATION SEE ROUTINE CQPDOC
C
      REAL A,ABSERR,B,R2MACH,EPMACH,EPSABS,EPSREL,EXACT1,ERROR,
     *  EXACT2,F1N,F2N,RESULT,UFLOW
      INTEGER IER,IERV,IP,IPASS,KPRINT,NEVAL
      DIMENSION IERV(1)
      EXTERNAL F1N,F2N
      DATA EXACT1/0.7281029132255818E+00/
      DATA EXACT2/0.1E+02/
C
C TEST ON IER = 0
C
      IPASS = 1
      EPSABS = 0.0E+00
      EPMACH = R2MACH(4)
      UFLOW = R2MACH(1)
      EPSREL = AMAX1(SQRT(EPMACH),0.1E-07)
      A = 0.0E+00
      B = 0.1E+01
      CALL QNG(F1N,A,B,EPSABS,EPSREL,RESULT,ABSERR,NEVAL,IER)
      IERV(1) = IER
      IP = 0
      ERROR = ABS(EXACT1-RESULT)
      IF(IER.EQ.0.AND.ERROR.LE.ABSERR.AND.ABSERR.LE.EPSREL*ABS(EXACT1))
     *  IP = 1
      IF(IP.EQ.0) IPASS = 0
      IF(KPRINT.NE.0) CALL CPRIN(KO,0,KPRINT,IP,EXACT1,RESULT,ABSERR,
     *  NEVAL,IERV,1)
C
C TEST ON IER = 1
C
      CALL QNG(F2N,A,B,UFLOW,0.0E+00,RESULT,ABSERR,NEVAL,IER)
      IERV(1) = IER
      IP = 0
      IF(IER.EQ.1) IP = 1
      IF(IP.EQ.0) IPASS = 0
      IF(KPRINT.NE.0) CALL CPRIN(KO,1,KPRINT,IP,EXACT2,RESULT,ABSERR,
     *  NEVAL,IERV,1)
C
C TEST ON IER = 6
C
      EPSABS = 0.0E+00
      EPSREL = 0.0E+00
      CALL QNG(F1N,A,B,EPSABS,0.0E+00,RESULT,ABSERR,NEVAL,IER)
      IERV(1) = IER
      IP = 0
      IF(IER.EQ.6.AND.RESULT.EQ.0.0E+00.AND.ABSERR.EQ.0.0E+00.AND.
     *  NEVAL.EQ.0) IP = 1
      IF(IP.EQ.0) IPASS = 0
      IF(KPRINT.NE.0) CALL CPRIN(KO,6,KPRINT,IP,EXACT1,RESULT,ABSERR,
     *  NEVAL,IERV,1)
      RETURN
      END
      REAL FUNCTION F4S(X)
      REAL X
      IF(X.EQ..33E+00) GO TO 10
      F4S = ABS(X-0.33E+00)**(-0.999E+00)
      RETURN
   10   F4S=R2MACH(2)*0.
        RETURN
      END
      REAL FUNCTION F5S(X)
      REAL X
      F5S = 0.0E+00
      IF(X.NE.0.0E+00) F5S = 1.0E+00/(X*SQRT(X))
      RETURN
      END
      REAL FUNCTION T0(X)
      REAL A,B,F0S,X,X1,Y
      A = 0.0E+00
      B = 0.1E+01
      X1 = X+0.1E+01
      Y = (B-A)/X1+A
      T0 = (B-A)*F0S(Y)/X1/X1
      RETURN
      END
      REAL FUNCTION T1(X)
      REAL A,B,F1S,X,X1,Y
      A = 0.0E+00
      B = 0.1E+01
      X1 = X+0.1E+01
      Y = (B-A)/X1+A
      T1 = (B-A)*F1S(Y)/X1/X1
      RETURN
      END
      REAL FUNCTION T2(X)
      REAL A,B,F2S,X,X1,Y
      A = 0.1E+00
      B = 0.1E+01
      X1 = X+0.1E+01
      Y = (B-A)/X1+A
      T2 = (B-A)*F2S(Y)/X1/X1
      RETURN
      END
      REAL FUNCTION T3(X)
      REAL A,B,F3S,X,X1,Y
      A = 0.0E+00
      B = 0.5E+01
      X1 = X+0.1E+01
      Y = (B-A)/X1+A
      T3 = (B-A)*F3S(Y)/X1/X1
      RETURN
      END
      REAL FUNCTION T4(X)
      REAL A,B,F4S,X,X1,Y
      A = 0.0E+00
      B = 0.1E+01
      X1 = X+0.1E+01
      Y = (B-A)/X1+A
      T4 = (B-A)*F4S(Y)/X1/X1
      RETURN
      END
      REAL FUNCTION T5(X)
      REAL A,B,F5S,X,X1,Y
      A = 0.0E+00
      B = 0.1E+01
      X1 = X+0.1E+01
      Y = (B-A)/X1+A
      T5 = (B-A)*F5S(Y)/X1/X1
      RETURN
      END
      REAL FUNCTION F2N(X)
      REAL X
      F2N=X**(-0.9E+00)
      RETURN
      END
      REAL FUNCTION F2O(X)
      REAL X
      F2O = 0.0E+00
      IF(X.NE.0.0E+00) F2O = 0.1E+01/(X*X*SQRT(X))
      RETURN
      END
      REAL FUNCTION F2P(X)
      REAL X
      F2P = SIN(0.314159E+03*X)/(0.314159E+01*X)
      RETURN
      END
      REAL FUNCTION F2S(X)
      REAL X
      F2S = 0.1E+03
      IF(X.NE.0.0E+00) F2S = SIN(0.314159E+03*X)/(0.314159E+01*X)
      RETURN
      END
      REAL FUNCTION F3G(X)
      REAL X
      F3G = ABS(X-0.33E+00)**(-0.9E+00)
      RETURN
      END
      REAL FUNCTION F3P(X)
      REAL X
      F3P = 0.1E+01
      IF(X.GT.0.31415926535897932E+01) F3P = 0.0E+00
      RETURN
      END
      REAL FUNCTION F3S(X)
      REAL X
      F3S = 0.1E+01
      IF(X.GT.0.31415926535897932E+01) F3S = 0.0E+00
      RETURN
      END
      REAL FUNCTION F4P(X)
      REAL X
      F4P = 0.0E+00
      IF(X.GT.0.0E+00) F4P = 0.1E+01/(X*SQRT(X))
      RETURN
      END
      SUBROUTINE CPRIN(KO,NUM1,KPRINT,IP,EXACT,RESULT,ABSERR,NEVAL,
     *  IERV,LIERV)
C
C***BEGIN PROLOGUE   CPRIN
C***CPRIN ROUTINE FOR QUADPACK QUICK CHECKS, 04.01.81
C***AUTHORS          ROBERT PIESSENS AND ELISE DE DONCKER
C                    APPL. MATH. AND PROGR. DIV.- K.U.LEUVEN
C***DESCRIPTION
C.....................................................................
C
C  THIS PROGRAM IS CALLED BY THE (SINGLE PRECISION) QUADPACK QUICK
C  CHECK ROUTINES, FOR PRINTING OUT THEIR MESSAGES.
C
C.....................................................................
C***END PROLOGUE
C
      REAL ABSERR,ERROR,EXACT,RESULT
      INTEGER IER,IERV,IP,KO,KPRINT,LIERV,NEVAL,NUM1
      DIMENSION IERV(LIERV)
      IER = IERV(1)
      ERROR = ABS(EXACT-RESULT)
      IF(KPRINT-2) 10,20,40
10    IF(IP.EQ.1) GO TO 999
      GO TO 999
20    IF(IP.EQ.1) GO TO 30
      WRITE(KO,900) NUM1
      IF(NUM1.EQ.0) WRITE(KO,901)
      IF(NUM1.GT.0) WRITE(KO,902) NUM1
      IF(LIERV.GT.1) WRITE(KO,903) (IERV(K),K=2,LIERV)
      IF(NUM1.EQ.6) WRITE(KO,904)
      WRITE(KO,905)
      WRITE(KO,906)
      IF(NUM1.NE.5) WRITE(KO,907) EXACT,RESULT,ERROR,ABSERR,IER,NEVAL
      IF(NUM1.EQ.5) WRITE(KO,910) RESULT,ABSERR,IER,NEVAL
      GO TO 999
30    WRITE(KO,908) NUM1
      GO TO 999
40    IF(IP.EQ.1) WRITE(KO,908) NUM1
      IF(NUM1.EQ.0) WRITE(KO,901)
      IF(NUM1.GT.0) WRITE(KO,902) NUM1
      IF(LIERV.GT.1) WRITE(KO,903) (IERV(K),K=2,LIERV)
      IF(NUM1.EQ.6) WRITE(KO,904)
      WRITE(KO,905)
      WRITE(KO,906)
      IF(NUM1.NE.5) WRITE(KO,907) EXACT,RESULT,ERROR,ABSERR,IER,NEVAL
      IF(NUM1.EQ.5) WRITE(KO,910) RESULT,ABSERR,IER,NEVAL
900   FORMAT(' TEST ON IER = ',I1,' FAILED.')
901   FORMAT(' WE MUST HAVE IER = 0, ERROR.LE.ABSERR AND,
     *   ABSERR.LE.MAX(EPSABS,EPSREL*ABS(EXACT))')
902   FORMAT(' WE MUST HAVE IER = ',I1)
903   FORMAT(' OR IER =    ',8(I1,2X))
904   FORMAT(' RESULT, ABSERR, NEVAL AND EVENTUALLY LAST SHOULD,
     *   BE ZERO')
905   FORMAT(' WE HAVE  ')
906   FORMAT(' ',6X,'EXACT',11X,'RESULT',6X,'ERROR',4X,'ABSERR',
     *  4X,'IER     NEVAL'/
     *  ' ',42X,'(EST.ERR.)(FLAG)(NO F-EVAL)')
907   FORMAT(' ',2(E15.7,1X),2(E9.2,1X),I4,4X,I6)
908   FORMAT(' TEST ON IER = ',I2,' PASSED')
910   FORMAT(5X,'INFINITY',4X,E15.7,11X,E9.2,I5,4X,I6)
999   RETURN
      END
      REAL FUNCTION F1C(X)
      REAL ABS,X
      F1C = 0.0E+00
      IF(X.NE.0.33E+00) F1C = (X-0.5E+00)*ABS(X-0.33E+00)**(-0.9E+00)
      RETURN
      END
      REAL FUNCTION F1F(X)
      REAL X,X1,Y
      X1 = X+0.1E+01
      F1F = 0.5E+01/X1/X1
      Y = 0.5E+01/X1
      IF(Y.GT.0.31415926535897932E+01) F1F = 0.0E+00
      RETURN
      END
      REAL FUNCTION F1G(X)
      REAL PI,X
      DATA PI/0.31415926535897932E+01/
      F1G = 0.2E+01/(0.2E+01+SIN(0.1E+02*PI*X))
      RETURN
      END
      REAL FUNCTION F1N(X)
      REAL X
      F1N=0.1E+01/(X**4+X**2+0.1E+01)
      RETURN
      END
      REAL FUNCTION F1O(X)
      REAL X
      F1O = 0.1E+01
      IF(X.GT.0.31415926535897932E+01) F1O = 0.0E+00
      RETURN
      END
      REAL FUNCTION F1P(X)
      REAL ALFA1,ALFA2,P1,P2,X,D1,D2
C  P1 = 1/7, P2 = 2/3
      DATA P1/0.1428571428571428E+00/
      DATA P2/0.6666666666666667E+00/
      ALFA1 = -0.25E0
      ALFA2 = -0.5E0
      D1=ABS(X-P1)
      D2=ABS(X-P2)
      F1P = 0.0E+00
      IF(D1.NE.0.0E+00.AND.D2.NE.0.0E+00) F1P = D1**ALFA1+D2**ALFA2
      RETURN
      END
      REAL FUNCTION F1S(X)
      REAL X
      F1S = 0.2E+01/(0.2E+01+SIN(0.314159E+02*X))
      RETURN
      END
      REAL FUNCTION F1WS(X)
      REAL ABS,X
      F1WS = ABS(X-0.33E+00)**(-0.999E+00)
      RETURN
      END
      REAL FUNCTION F2G(X)
      REAL X
      F2G = X*SIN(0.3E+02*X)*COS(0.5E+02*X)
      RETURN
      END
      REAL FUNCTION F0C(X)
      REAL X
      F0C = 1.D0/(X*X+1.E-4)
      RETURN
      END
      REAL FUNCTION F0F(X)
      REAL X
      F0F = 0.0E+00
      IF(X.NE.0.0E+00) F0F = SIN(0.5E+02*X)/(X*SQRT(X))
      RETURN
      END
      REAL FUNCTION F0O(X)
      REAL X
      F0O = (0.2E+01*SIN(X))**14
      RETURN
      END
      REAL FUNCTION F0S(X)
      REAL X
      F0S = 0.0E+00
      IF(X.NE.0.0E+00) F0S = 0.1E+01/SQRT(X)
      RETURN
      END
      REAL FUNCTION F0WS(X)
      REAL SIN,X
      F0WS  = SIN(0.1E+02*X)
      RETURN
      END