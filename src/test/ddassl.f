C
C   DRIVER FOR TESTING CMLIB ROUTINES
C     DDASSL
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
      CALL XSETF(1)
      CALL XERMAX(1000)
C   TEST DDASSL
      CALL DDASQX(KPRINT,IPASS)
      ITEST=ITEST*IPASS
C
      IF(KPRINT.GE.1.AND.ITEST.NE.1) WRITE(LUN,2)
2     FORMAT(/' ***** WARNING -- AT LEAST ONE TEST FOR SUBLIBRARY DDASSL
     1HAS FAILED ***** ')
      IF(KPRINT.GE.1.AND.ITEST.EQ.1) WRITE(LUN,3)
3     FORMAT(/' ----- SUBLIBRARY DDASSL PASSED ALL TESTS ----- ')
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
      SUBROUTINE DDASQX(KPRINT,IPASS)
C-----------------------------------------------------------------------
C demonstration program for ddassl.
C this is the march 15, 1983 version.
C this version is in double precision.
C
C
C ddassl is used to solve two simple problems,
C one with a full jacobian, the other with a banded jacobian,
C with the 2 appropriate values of info(5) in each case.
C if the errors are too large, or other difficulty occurs,
C a warning message is printed.  all output is on unit lout = 6.
C-----------------------------------------------------------------------
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
      COMMON/UNIT/LUN
      EXTERNAL RES1, JAC1, RES2, JAC2
      DIMENSION Y(25), RWORK(550), IWORK(45), YPRIME(25), DELTA(25)
      DIMENSION INFO(15)
      INTEGER IPASS,KPRINT
      DATA  TOUT1/1.0D0/, DTOUT/1.0D0/
C
      IPASS=1
      NERR = 0
      ITOL = 1
      RTOL = 0.0D0
      ATOL = 1.0D-6
      LRW = 550
      LIW = 45
C
C first problem
C
      NEQ = 2
      NOUT = 10
      IF(KPRINT .GT. 2)WRITE (LUN,110) NEQ,RTOL,ATOL
 110  FORMAT(/////
     1  1X,53H PROBLEM 1..   LINEAR DIFFERENTIAL/ALGEBRAIC SYSTEM../
     2  1X,20H X1DOT + 10.0*X1 = 0/
     3  1X,25H X1(0) = 1.0, X2(0) = 0.0/
     4  1X,6H NEQ =,I2/
     5  1X,7H RTOL =,E10.1,9H   ATOL =,E10.1//)
C
      DO 190 J190 = 1,2
      DO 115 I = 1,15
115     INFO(I) = 0
      IF(J190 .EQ. 2) INFO(5) = 1
      IF (KPRINT .GT. 2)WRITE (LUN,120) INFO(5)
 120  FORMAT(////1X,10H INFO(5) =,I3///
     1  6X,1HT,15X,2HX1,14X,2HX2,11X,2HNQ,6X,1HH,12X//)
      T = 0.0D0
      Y(1) = 1.0D0
      Y(2) = 0.0D0
      YPRIME(1) = -10.0D0
      YPRIME(2) =  10.0D0
      TOUT = TOUT1
      ERO = 0.0D0
      DO 170 IOUT = 1,NOUT
        CALL DDASSL(RES1,NEQ,T,Y,YPRIME,TOUT,INFO,RTOL,ATOL,IDID,
     1     RWORK,LRW,IWORK,LIW,RPAR,IPAR,JAC1)
        HU = RWORK(7)
        NQU = IWORK(8)
        IF (KPRINT .GT. 2)WRITE (LUN,140) T,Y(1),Y(2),NQU,HU
 140    FORMAT(1X,E15.5,E16.5,E16.5,I6,E14.3)
        IF (IDID .LT. 0) GO TO 175
        IOPAR = IOUT - 2*(IOUT/2)
        IF (IOPAR .NE. 0) GO TO 170
        YT1 = DEXP(-10.0D0*T)
        YT2 = 1.0D0 - YT1
        ER1 = DABS(YT1 - Y(1))
        ER2 = DABS(YT2 - Y(2))
        ER = DMAX1(ER1,ER2)
        ERO = DMAX1(ERO,ER)
        IF (ER .LT. 1000.0D0) GO TO 170
        IF(KPRINT.GE.2) WRITE (LUN,150)
 150    FORMAT(//1X,41H WARNING.. ERROR EXCEEDS 1000 * TOLERANCE//)
        NERR = NERR + 1
        IPASS=2
 170    TOUT = TOUT + DTOUT
 175  CONTINUE
      IF (IDID .LT. 0) NERR = NERR + 1
      NST = IWORK(11)
      NFE = IWORK(12)
      NJE = IWORK(13)
      IF (KPRINT .GT. 2)WRITE (LUN,180) NST,NFE,NJE,ERO
 180  FORMAT(//1X,32H FINAL STATISTICS FOR THIS RUN../
     1  1X,18H NUMBER OF STEPS =,I5/
     2  1X,18H NUMBER OF F-S   =,I5/
     4  1X,18H NUMBER OF J-S   =,I5/
     5  1X,16H ERROR OVERRUN =,E10.2)
 190  CONTINUE
C
C second problem
C
      NEQ = 25
      ML = 5
      MU = 0
      IWORK(1) = ML
      IWORK(2) = MU
      MBAND = ML + MU + 1
      NOUT = 5
      IF(KPRINT .GT. 2)WRITE (LUN,210) NEQ,ML,MU,RTOL,ATOL
 210  FORMAT(1H1/1X,33H DEMONSTRATION PROGRAM FOR DDASSL////
     1  1X,33H PROBLEM 2.. YDOT = A * Y , WHERE,
     2  39H  A IS A BANDED LOWER TRIANGULAR MATRIX/
     2  1X,32H  DERIVED FROM 2-D ADVECTION PDE/
     3  1X,6H NEQ =,I3,7H   ML =,I2,7H   MU =,I2/
     4  1X,7H RTOL =,E10.1,9H   ATOL =,E10.1//)
      DO 290 J290 = 1,2
      DO 215 I = 1,15
 215    INFO(I) = 0
      INFO(6) = 1
      IF(J290 .EQ. 2) INFO(5) = 1
      IF (KPRINT .GT. 2)WRITE (LUN,220) INFO(5)
 220  FORMAT(////1X,10H INFO(5) =,I3///
     1  6X,1HT,13X,8HMAX.ERR.,5X,2HNQ,6X,1HH//)
      T = 0.0D0
      DO 230 I = 2,NEQ
 230    Y(I) = 0.0D0
      Y(1) = 1.0D0
      DO 235 I = 1,NEQ
 235    DELTA(I) = 0.0D0
      CALL RES2(T,Y,DELTA,YPRIME,IRES,RPAR,IPAR)
      ITASK = 1
      ISTATE = 1
      TOUT = 0.01D0
      ERO = 0.0D0
      DO 270 IOUT = 1,NOUT
        CALL DDASSL(RES2,NEQ,T,Y,YPRIME,TOUT,INFO,RTOL,ATOL,IDID,
     1     RWORK,LRW,IWORK,LIW,RPAR,IPAR,JAC2)
        CALL EDIT2(Y,T,ERM)
        HU = RWORK(7)
        NQU = IWORK(8)
        IF (KPRINT .GT. 2)WRITE (LUN,240) T,ERM,NQU,HU
 240    FORMAT(1X,E15.5,E14.3,I6,E14.3)
        IF (IDID .LT. 0) GO TO 275
        ER = ERM/ATOL
        ERO = DMAX1(ERO,ER)
        IF (ER .LE. 1000.0D0) GO TO 270
        IF(KPRINT.GE.2) WRITE (LUN,150)
        IPASS=2
        NERR = NERR + 1
 270    TOUT = TOUT*10.0D0
 275  CONTINUE
      IF (IDID .LT. 0) NERR = NERR + 1
      NST = IWORK(11)
      NFE = IWORK(12)
      NJE = IWORK(13)
      IF (KPRINT .GT. 2)WRITE (LUN,180) NST,NFE,NJE,ERO
 290  CONTINUE
      IF(NERR .EQ. 0) GOTO 310
      IF(KPRINT.GE.1) WRITE (LUN,300) NERR
      IF(KPRINT.GE.1) WRITE(LUN,295)
 295  FORMAT(/,' ** TEST FOR DDASSL FAILED ** ')
 300  FORMAT(////1X,31H NUMBER OF ERRORS ENCOUNTERED =,I3)
      GOTO 900
310   IF(KPRINT.GE.2) WRITE(LUN,320)
320   FORMAT(' ** TEST FOR DDASSL PASSED ** ')
900   RETURN
      END
      SUBROUTINE RES1(T,Y,YPRIME,DELTA,IRES,RPAR,IPAR)
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
      DIMENSION Y(*),YPRIME(*),DELTA(*)
      DELTA(1) = YPRIME(1) + 10.0D0*Y(1)
      DELTA(2) = Y(2) + Y(1) - 1.0D0
      RETURN
      END
      SUBROUTINE JAC1(T,Y,YPRIME,PD,CJ,RPAR,IPAR)
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
      DIMENSION Y(*),YPRIME(*),PD(2,*)
      PD(1,1) = CJ + 10.0D0
      PD(1,2) = 0.0D0
      PD(2,1) = 1.0D0
      PD(2,2) = 1.0D0
      RETURN
      END
      SUBROUTINE RES2(T,Y,YPRIME,DELTA,IRES,RPAR,IPAR)
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
      DIMENSION Y(*),YPRIME(*),DELTA(*)
      DATA ALPH1/1.0D0/, ALPH2/1.0D0/, NG/5/
      DO 10 J = 1,NG
      DO 10 I = 1,NG
        K = I + (J - 1)*NG
        D = -2.0D0*Y(K)
        IF (I .NE. 1) D = D + Y(K-1)*ALPH1
        IF (J .NE. 1) D = D + Y(K-NG)*ALPH2
 10     DELTA(K) = D - YPRIME(K)
      RETURN
      END
      SUBROUTINE JAC2(T,Y,YPRIME,PD,CJ,RPAR,IPAR)
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
      DIMENSION Y(*), PD(11,*), YPRIME(*)
      DATA ALPH1/1.0D0/, ALPH2/1.0D0/, NG/5/
      DATA ML/5/, MU/0/, NEQ/25/
      MBAND = ML + MU + 1
      MBAND1 = MBAND + 1
      MBAND2 = MBAND + 2
      MBAND3 = MBAND + 3
      MBAND4 = MBAND + 4
      MBAND5 = MBAND + 5
      DO 10 J = 1,NEQ
        PD(MBAND,J) = -2.0D0 - CJ
        PD(MBAND1,J) = ALPH1
        PD(MBAND2,J) = 0.0D0
        PD(MBAND3,J) = 0.0D0
        PD(MBAND4,J) = 0.0D0
 10     PD(MBAND5,J) = ALPH2
      DO 20 J = 1,NEQ,NG
 20     PD(MBAND1,J) = 0.0D0
      RETURN
      END
      SUBROUTINE EDIT2 (Y, T, ERM)
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
      DIMENSION Y(25)
      DATA ALPH1/1.0D0/, ALPH2/1.0D0/, NG/5/
      ERM = 0.0D0
      IF (T .EQ. 0.0D0) RETURN
      EX = 0.0D0
      IF (T .LE. 30.0D0) EX = DEXP(-2.0D0*T)
      A2 = 1.0D0
      DO 60 J = 1,NG
        A1 = 1.0D0
        DO 50 I = 1,NG
          K = I + (J - 1)*NG
          YT = T**(I+J-2)*EX*A1*A2
          ER = DABS(Y(K)-YT)
          ERM = DMAX1(ERM,ER)
          A1 = A1*ALPH1/DBLE(I)
 50       CONTINUE
        A2 = A2*ALPH2/DBLE(J)
 60     CONTINUE
      RETURN
      END
