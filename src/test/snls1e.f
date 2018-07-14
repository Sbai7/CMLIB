C
C   DRIVER FOR TESTING CMLIB ROUTINES
C      SNLS1E   SNLS1    SCOV
C      SNSQE    SNSQF   PVALUE
C      SOS
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
      IF(KPRINT.LE.1) CALL XSETF(0)
C   TEST SNLS
      CALL SNLS1Q(KPRINT,IPASS)
      ITEST=ITEST*IPASS
      CALL XSETF(0)
C   TEST SNSQ
      CALL SNSQQK(KPRINT,IPASS)
      ITEST=ITEST*IPASS
C   TEST SOS
      CALL SOSNQX(KPRINT,IPASS)
      ITEST=ITEST*IPASS
C
      IF(KPRINT.GE.1.AND.ITEST.NE.1) WRITE(LUN,2)
2     FORMAT(/' ***** WARNING -- AT LEAST ONE TEST FOR THE SNLS1E,
     1 SUBLIBRARY HAS FAILED ***** ')
      IF(KPRINT.GE.1.AND.ITEST.EQ.1) WRITE(LUN,3)
3     FORMAT(/' ----- THE SNLS1E SUBLIBRARY PASSED ALL TESTS ----- ')
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
      SUBROUTINE SNLS1Q(KPRINT,IPASS)
C
C     THIS SUBROUTINE PERFORMS A QUICK CHECK ON THE SUBROUTINES SNLS1E
C     (AND SNLS1) AND SCOV.
      DIMENSION X(2),FVEC(10),FJAC(10,2),FJROW(2),WA(40),IW(2),ITEST(36)
     *,FJTJ(3)
      EXTERNAL FCN1,FCN2,FCN3
      COMMON /UNIT/ LUN
      COMMON /MSG/ ICNT,ITEST
C
      INFOS=1
      FNORMS=0.11151779E+02
      M=10
      N=2
      LWA=40
      LDFJAC=10
      NPRINT=-1
      IFLAG=1
      ZERO=0.E0
      ONE=1.E0
      TOL=SQRT(40.*R2MACH(4))
      TOL2=SQRT(TOL)
      IF (KPRINT.GE.2) WRITE(LUN,1000)
C
C     OPTION=2, THE FULL JACOBIAN IS STORED AND THE USER PROVIDES THE
C     JACOBIAN.
      IOPT=2
      X(1)=3.E-1
      X(2)=4.E-1
      CALL SNLS1E(FCN2,IOPT,M,N,X,FVEC,TOL,NPRINT,INFO,
     * IW,WA,LWA)
      ICNT=1
      FNORM=ENORM(M,FVEC)
      ITEST(ICNT)=0
      IF ((INFO.EQ.INFOS) .AND. (ABS(FNORM-FNORMS)/FNORMS.LE.TOL))
     * ITEST(ICNT)=1
      IF (KPRINT.EQ.0) GO TO 15
      IF ((KPRINT.GE.2.AND.ITEST(ICNT).NE.1).OR.KPRINT.GE.3)
     * WRITE(LUN,1010) INFOS,FNORMS,INFO,FNORM
      IF((KPRINT.GE.2).OR.(KPRINT.EQ.1.AND.ITEST(ICNT).NE.1))CALL PASS
   15 CONTINUE
C
C     FORM JAC-TRANSPOSE*JAC
      SIGMA=FNORM*FNORM/FLOAT(M-N)
      IFLAG = 2
      CALL FCN2(IFLAG,M,N,X,FVEC,FJAC,LDFJAC)
      DO 10 I=1,3
   10 FJTJ(I)=ZERO
      DO 11 I=1,M
      FJTJ(1)=FJTJ(1)+FJAC(I,1)**2
      FJTJ(2)=FJTJ(2)+FJAC(I,1)*FJAC(I,2)
      FJTJ(3)=FJTJ(3)+FJAC(I,2)**2
   11 CONTINUE
C
C     CALCULATE COVARIANCE MATRIX
      CALL SCOV(FCN2,IOPT,M,N,X,FVEC,FJAC,LDFJAC,INFO,
     *WA(1),WA(N+1),WA(2*N+1),WA(3*N+1))
C
C     FORM JAC-TRANSPOSE*JAC * COVARIANCE MATRIX
C     (SHOULD = SIGMA*I)
      TEMP1=(FJTJ(1)*FJAC(1,1)+FJTJ(2)*FJAC(1,2))/SIGMA
      TEMP2=(FJTJ(1)*FJAC(1,2)+FJTJ(2)*FJAC(2,2))/SIGMA
      TEMP3=(FJTJ(2)*FJAC(1,2)+FJTJ(3)*FJAC(2,2))/SIGMA
      ICNT=5
      ITEST(ICNT)=0
      IF (INFO.EQ.INFOS .AND. ABS(TEMP1-ONE).LT.TOL2 .AND.
     * ABS(TEMP2).LT.TOL2 .AND. ABS(TEMP3-ONE).LT.TOL2)
     *ITEST(ICNT)=1
      IF (KPRINT.EQ.0) GO TO 20
      IF ((KPRINT.GE.2.AND.ITEST(ICNT).NE.1).OR.KPRINT.GE.3)
     * WRITE(LUN,1020) INFOS,INFO,TEMP1,TEMP2,TEMP3
      IF((KPRINT.GE.2).OR.(KPRINT.EQ.1.AND.ITEST(ICNT).NE.1))CALL PASS
C
C     OPTION=1, THE FULL JACOBIAN IS STORED AND THE CODE APPROXIMATES
C     THE JACOBIAN.
20    IOPT=1
      X(1)=3.E-1
      X(2)=4.E-1
      CALL SNLS1E(FCN1,IOPT,M,N,X,FVEC,TOL,NPRINT,INFO,
     * IW,WA,LWA)
      ICNT=2
      FNORM=ENORM(M,FVEC)
      ITEST(ICNT)=0
      IF ((INFO.EQ.INFOS).AND.(ABS(FNORM-FNORMS)/FNORMS.LE.TOL))
     * ITEST(ICNT)=1
      IF (KPRINT.EQ.0) GO TO 25
      IF ((KPRINT.GE.2.AND.ITEST(ICNT).NE.1).OR.KPRINT.GE.3)
     * WRITE(LUN,1010) INFOS,FNORMS,INFO,FNORM
      IF((KPRINT.GE.2).OR.(KPRINT.EQ.1.AND.ITEST(ICNT).NE.1))CALL PASS
   25 CONTINUE
C
C     FORM JAC-TRANSPOSE*JAC
      SIGMA=FNORM*FNORM/FLOAT(M-N)
      IFLAG = 1
      CALL FDJAC3(FCN1,M,N,X,FVEC,FJAC,LDFJAC,IFLAG,ZERO,WA)
      DO 26 I=1,3
   26 FJTJ(I)=ZERO
      DO 27 I=1,M
      FJTJ(1)=FJTJ(1)+FJAC(I,1)**2
      FJTJ(2)=FJTJ(2)+FJAC(I,1)*FJAC(I,2)
      FJTJ(3)=FJTJ(3)+FJAC(I,2)**2
   27 CONTINUE
C
C     CALCULATE COVARIANCE MATRIX
      CALL SCOV(FCN1,IOPT,M,N,X,FVEC,FJAC,LDFJAC,INFO,
     *WA(1),WA(N+1),WA(2*N+1),WA(3*N+1))
C
C     FORM JAC-TRANSPOSE*JAC * COVARIANCE MATRIX
C     (SHOULD = SIGMA*I)
      TEMP1=(FJTJ(1)*FJAC(1,1)+FJTJ(2)*FJAC(1,2))/SIGMA
      TEMP2=(FJTJ(1)*FJAC(1,2)+FJTJ(2)*FJAC(2,2))/SIGMA
      TEMP3=(FJTJ(2)*FJAC(1,2)+FJTJ(3)*FJAC(2,2))/SIGMA
      ICNT=6
      ITEST(ICNT)=0
      IF (INFO.EQ.INFOS .AND. ABS(TEMP1-ONE).LT.TOL2 .AND.
     * ABS(TEMP2).LT.TOL2 .AND. ABS(TEMP3-ONE).LT.TOL2)
     *ITEST(ICNT)=1
      IF (KPRINT.EQ.0) GO TO 30
      IF ((KPRINT.GE.2.AND.ITEST(ICNT).NE.1).OR.KPRINT.GE.3)
     * WRITE(LUN,1020) INFOS,INFO,TEMP1,TEMP2,TEMP3
      IF((KPRINT.GE.2).OR.(KPRINT.EQ.1.AND.ITEST(ICNT).NE.1))CALL PASS
C
C     OPTION=3, THE FULL JACOBIAN IS NOT STORED ONLY THE PRODUCT OF THE
C     JACOBIAN TRANSPOSE AND JACOBIAN IS STORED. THE USER PROVIDES THE
C     THE JACOBIAN ONE ROW AT A TIME.
30    IOPT=3
      X(1)=3.E-1
      X(2)=4.E-1
      CALL SNLS1E(FCN3,IOPT,M,N,X,FVEC,TOL,NPRINT,INFO,
     * IW,WA,LWA)
      ICNT=3
      FNORM=ENORM(M,FVEC)
      ITEST(ICNT)=0
      IF ((INFO.EQ.INFOS).AND.(ABS(FNORM-FNORMS)/FNORMS.LE.TOL))
     * ITEST(ICNT)=1
      IF (KPRINT.EQ.0) GO TO 35
      IF ((KPRINT.GE.2.AND.ITEST(ICNT).NE.1).OR.KPRINT.GE.3)
     * WRITE(LUN,1010) INFOS,FNORMS,INFO,FNORM
      IF((KPRINT.GE.2).OR.(KPRINT.EQ.1.AND.ITEST(ICNT).NE.1))CALL PASS
   35 CONTINUE
C
C     FORM JAC-TRANSPOSE*JAC
      SIGMA=FNORM*FNORM/FLOAT(M-N)
      DO 36 I=1,3
   36 FJTJ(I)=ZERO
      IFLAG=3
      DO 37 I=1,M
      CALL FCN3(IFLAG,M,N,X,FVEC,FJROW,I)
      FJTJ(1)=FJTJ(1)+FJROW(1)**2
      FJTJ(2)=FJTJ(2)+FJROW(1)*FJROW(2)
      FJTJ(3)=FJTJ(3)+FJROW(2)**2
   37 CONTINUE
C
C     CALCULATE COVARIANCE MATRIX
      CALL SCOV(FCN3,IOPT,M,N,X,FVEC,FJAC,LDFJAC,INFO,
     *WA(1),WA(N+1),WA(2*N+1),WA(3*N+1))
C
C     FORM JAC-TRANSPOSE*JAC * COVARIANCE MATRIX
C     (SHOULD = SIGMA*I)
      TEMP1=(FJTJ(1)*FJAC(1,1)+FJTJ(2)*FJAC(1,2))/SIGMA
      TEMP2=(FJTJ(1)*FJAC(1,2)+FJTJ(2)*FJAC(2,2))/SIGMA
      TEMP3=(FJTJ(2)*FJAC(1,2)+FJTJ(3)*FJAC(2,2))/SIGMA
      ICNT=7
      ITEST(ICNT)=0
      IF (INFO.EQ.INFOS .AND. ABS(TEMP1-ONE).LT.TOL2 .AND.
     * ABS(TEMP2).LT.TOL2 .AND. ABS(TEMP3-ONE).LT.TOL2)
     *ITEST(ICNT)=1
      IF (KPRINT.EQ.0) GO TO 40
      IF ((KPRINT.GE.2.AND.ITEST(ICNT).NE.1).OR.KPRINT.GE.3)
     * WRITE(LUN,1020) INFOS,INFO,TEMP1,TEMP2,TEMP3
      IF((KPRINT.GE.2).OR.(KPRINT.EQ.1.AND.ITEST(ICNT).NE.1))CALL PASS
C
C     TEST IMPROPER INPUT PARAMETERS
40    LWA=35
      IOPT=2
      X(1)=3.E-1
      X(2)=4.E-1
      CALL SNLS1E(FCN2,IOPT,M,N,X,FVEC,TOL,NPRINT,INFO,
     * IW,WA,LWA)
      ICNT=4
      ITEST(ICNT)=0
      IF (INFO.EQ.0) ITEST(ICNT)=1
      IF((KPRINT.GE.2).OR.(KPRINT.EQ.1.AND.ITEST(ICNT).NE.1))CALL PASS
      ITEST(8)=1
      IF(KPRINT.LT.3) GO TO 999
      M=0
      CALL SCOV(FCN2,IOPT,M,N,X,FVEC,FJAC,LDFJAC,INFO,
     *WA(1),WA(N+1),WA(2*N+1),WA(3*N+1))
      ICNT=8
      ITEST(ICNT)=0
      IF (INFO.EQ.0) ITEST(ICNT)=1
      IF((KPRINT.GE.2).OR.(KPRINT.EQ.1.AND.ITEST(ICNT).NE.1))CALL PASS
C
C     SET IPASS
999   IPASS=ITEST(1)*ITEST(2)*ITEST(3)*ITEST(4)
      IPASS=IPASS*ITEST(5)*ITEST(6)*ITEST(7)*ITEST(8)
      RETURN
1000  FORMAT('1',' SNLS1E QUICK-CHECK'/)
1010  FORMAT(' EXPECTED VALUE OF INFO AND RESIDUAL NORM',I5,E20.9/
     *       ' RETURNED VALUE OF INFO AND RESIDUAL NORM',I5,E20.9/)
1020  FORMAT(' EXPECTED AND RETURNED VALUE OF INFO',I5,10X,I5/
     *' RETURNED PRODUCT OF (J-TRANS*J)*COVARIANCE MATRIX/SIGMA'/
     *' (SHOULD = THE IDENTITY -- 1.0, 0.0, 1.0)'/3E20.9/)
      END
      SUBROUTINE SNSQQK(KPRINT,IPASS)
C
C     THIS SUBROUTINE PERFORMS A QUICK CHECK ON THE SUBROUTINE SNSQE
C     (AND SNSQ).
      DIMENSION X(2),FVEC(2),FJAC(2,2),WA(19),ITEST(38)
      EXTERNAL SQFCN2,SQJAC2
      COMMON /UNIT/ LUN
      COMMON /MSG/ ICNT,ITEST
C
      INFOS=1
      FNORMS=0.E0
      N=2
      LWA=19
      LDFJAC=2
      NPRINT=-1
      TOL=SQRT(R2MACH(4))
      IF (KPRINT.GE.2) WRITE(LUN,1000)
C
C     OPTION=1, THE USER PROVIDES THE JACOBIAN.
      IOPT=1
      X(1)=-1.2E0
      X(2)=1.E0
      CALL SNSQE(SQFCN2,SQJAC2,IOPT,N,X,FVEC,TOL,NPRINT,INFO,WA,LWA)
      ICNT=1
      FNORM=ENORM(N,FVEC)
      ITEST(ICNT)=0
      IF ((INFO.EQ.INFOS) .AND. (FNORM-FNORMS.LE.TOL)) ITEST(ICNT)=1
      IF (KPRINT.EQ.0) GO TO 20
      IF ((KPRINT.GE.2.AND.ITEST(ICNT).NE.1).OR.KPRINT.GE.3)
     * WRITE(LUN,1010) INFOS,FNORMS,INFO,FNORM
      IF((KPRINT.GE.2).OR.(KPRINT.EQ.1.AND.ITEST(ICNT).NE.1))CALL PASS
C
C     OPTION=2, THE CODE APPROXIMATES THE JACOBIAN.
20    IOPT=2
      X(1)=-1.2E0
      X(2)=1.E0
      CALL SNSQE(SQFCN2,SQJAC2,IOPT,N,X,FVEC,TOL,NPRINT,INFO,WA,LWA)
      ICNT=2
      FNORM=ENORM(N,FVEC)
      ITEST(ICNT)=0
      IF ((INFO.EQ.INFOS) .AND. (FNORM-FNORMS.LE.TOL)) ITEST(ICNT)=1
      IF (KPRINT.EQ.0) GO TO 30
      IF ((KPRINT.GE.2.AND.ITEST(ICNT).NE.1).OR.KPRINT.GE.3)
     * WRITE(LUN,1010) INFOS,FNORMS,INFO,FNORM
      IF((KPRINT.GE.2).OR.(KPRINT.EQ.1.AND.ITEST(ICNT).NE.1))CALL PASS
C
C     TEST INPROPER INPUT PARAMETERS
30    LWA=15
      IOPT=1
      X(1)=-1.2E0
      X(2)=1.E0
      CALL SNSQE(SQFCN2,SQJAC2,IOPT,N,X,FVEC,TOL,NPRINT,INFO,WA,LWA)
      ICNT=3
      ITEST(ICNT)=0
      IF (INFO.EQ.0) ITEST(ICNT)=1
      IF((KPRINT.GE.2).OR.(KPRINT.EQ.1.AND.ITEST(ICNT).NE.1))CALL PASS
C
C     SET IPASS
      IPASS=ITEST(1)*ITEST(2)*ITEST(3)
      IF (KPRINT.GE.1.AND.IPASS.NE.1) WRITE(LUN,1020)
      IF (KPRINT.GE.2.AND.IPASS.EQ.1) WRITE(LUN,1030)
      RETURN
1000  FORMAT('1',' SNSQE QUICK-CHECK'/)
1010  FORMAT(' EXPECTED VALUE OF INFO AND RESIDUAL NORM',I5,E20.5/
     *       ' RETURNED VALUE OF INFO AND RESIDUAL NORM',I5,E20.5/)
 1020 FORMAT(/' ***** WARNING -- SNSQE/SNSQ FAILED SOME TESTS ***** ')
 1030 FORMAT(/'----- SNSQE/SNSQ PASSED ALL TESTS ----- ')
      END
      SUBROUTINE SOSNQX(KPRINT,IPASS)
C
C     THIS SUBROUTINE PERFORMS A QUICK CHECK ON THE SUBROUTINE SOS.
      DIMENSION X(2),FVEC(2),WA(17),ITEST(38),IW(6)
      EXTERNAL SOSFNC
      COMMON /UNIT/ LUN
      COMMON /MSG/ ICNT,ITEST
C
      IFLAGS=3
      FNORMS=0.E0
      N=2
      LWA=17
      LIW=6
      TOLF=SQRT(R2MACH(4))
      RER=SQRT(R2MACH(4))
      AER=0.E0
      IF (KPRINT.GE.2) WRITE(LUN,1000)
C
C     TEST THE CODE WITH PROPER INPUT VLAUES.
      IFLAG=0
      X(1)=-1.2E0
      X(2)=1.E0
      CALL SOS(SOSFNC,N,X,RER,AER,TOLF,IFLAG,WA,LWA,IW,LIW)
      ICNT=1
      FVEC(1)=SOSFNC(X,1)
      FVEC(2)=SOSFNC(X,2)
      FNORM=SNRM2(N,FVEC,1)
      ITEST(ICNT)=0
      IF ((IFLAG.LE.IFLAGS) .AND. (FNORM-FNORMS.LE.RER)) ITEST(ICNT)=1
      IF (KPRINT.EQ.0) GO TO 20
      IF ((KPRINT.GE.2.AND.ITEST(ICNT).NE.1).OR.KPRINT.GE.3)
     * WRITE(LUN,1010) IFLAGS,FNORMS,IFLAG,FNORM
      IF((KPRINT.GE.2).OR.(KPRINT.EQ.1.AND.ITEST(ICNT).NE.1))CALL PASS
C
C     TEST IMPROPER INPUT PARAMETERS
20    LWA=15
      IFLAG=0
      X(1)=-1.2E0
      X(2)=1.E0
      CALL SOS(SOSFNC,N,X,RER,AER,TOLF,IFLAG,WA,LWA,IW,LIW)
      ICNT=2
      ITEST(ICNT)=0
      IF (IFLAG.EQ.9) ITEST(ICNT)=1
      IF((KPRINT.GE.2).OR.(KPRINT.EQ.1.AND.ITEST(ICNT).NE.1))CALL PASS
C
C     SET IPASS
      IPASS=ITEST(1)*ITEST(2)
      IF (KPRINT.GE.1.AND.IPASS.NE.1) WRITE(LUN,1020)
      IF (KPRINT.GE.2.AND.IPASS.EQ.1) WRITE(LUN,1030)
      RETURN
1000  FORMAT('1',' SOS QUICK-CHECK'/)
1010  FORMAT(' EXPECTED VALUE OF IFLAG AND RESIDUAL NORM',I5,E20.5/
     *       ' RETURNED VALUE OF IFLAG AND RESIDUAL NORM',I5,E20.5/)
 1020 FORMAT(/' ***** WARNING -- SOS FAILED SOME TESTS ***** ')
 1030 FORMAT(/' ----- SOS PASSED ALL TESTS ----- ')
      END
      SUBROUTINE PASS
      COMMON /UNIT/ LUN
      COMMON /MSG/ ICNT,ITEST
      DIMENSION ITEST(38)
      IF(ITEST(ICNT).EQ.0) GO TO 10
      WRITE(LUN,100) ICNT
  100 FORMAT(/' TEST NUMBER',I5,'    PASSED')
      RETURN
   10 WRITE(LUN,200) ICNT
  200 FORMAT(/' *****TEST NUMBER',I5,'    FAILED****** ')
      RETURN
      END
      SUBROUTINE FCN1(IFLAG,M,N,X,FVEC,FJAC,LDFJAC)
C
C     SUBROUTINE WHICH EVALUATES THE FUNCTION FOR TEST
C     PROGRAM USED IN QUICK CHECK OF SNLS1E.
C     NUMERICAL APPROXIMATION OF JACOBIAN IS USED.
C
      DIMENSION X(N),FVEC(M)
      DATA TWO/2.E0/
      IF(IFLAG.NE.1) RETURN
      DO 100 I=1,M
      TEMP=FLOAT(I)
      FVEC(I)=TWO+TWO*TEMP-EXP(TEMP*X(1))-EXP(TEMP*X(2))
  100 CONTINUE
      RETURN
      END
      SUBROUTINE FCN2(IFLAG,M,N,X,FVEC,FJAC,LDFJAC)
C
C     SUBROUTINE TO EVALUATE FUNCTION AND FULL JACOBIAN
C     FOR TEST PROBLEM IN QUICK CHECK OF SNLS1E.
C
      DIMENSION X(N),FVEC(M),FJAC(LDFJAC,N)
      DATA TWO/2.E0/
      IF(IFLAG.EQ.0) RETURN
C
C      SHOULD WE EVALUATE FUNCTION OR JACOBIAN
C
      IF(IFLAG.NE.1) GO TO 150
C
C      EVALUATE FUNCTIONS
C
      DO 100 I=1,M
      TEMP=FLOAT(I)
      FVEC(I)=TWO+TWO*TEMP-EXP(TEMP*X(1))-EXP(TEMP*X(2))
  100 CONTINUE
      RETURN
C
C      EVALUATE JACOBIAN
C
150   CONTINUE
      IF(IFLAG.NE.2) RETURN
      DO 200 I=1,M
      TEMP=FLOAT(I)
      FJAC(I,1)=-TEMP*EXP(TEMP*X(1))
      FJAC(I,2)=-TEMP*EXP(TEMP*X(2))
  200 CONTINUE
      RETURN
      END
      SUBROUTINE FCN3(IFLAG,M,N,X,FVEC,FJROW,NROW)
C
C     SUBROUTINE TO EVALUATE THE JACOBIAN, ONE ROW AT A TIME, FOR
C     TEST PROBLEM USED IN QUICK CHECK OF SNLS1E.
      DIMENSION X(N),FVEC(M),FJROW(N)
      DATA TWO/2.E0/
      IF(IFLAG.EQ.0) RETURN
C
C      SHOULD WE EVALUATE FUNCTIONS OR JACOBIAN.
C
      IF(IFLAG.NE.1) GO TO 150
C
C      EVALUATE FUNCTIONS.
C
      DO 100 I=1,M
      TEMP=FLOAT(I)
      FVEC(I)=TWO+TWO*TEMP-EXP(TEMP*X(1))-EXP(TEMP*X(2))
  100 CONTINUE
      RETURN
C
C EVALUATE ONE ROW OF JACOBIAN.
C
150   CONTINUE
      IF(IFLAG.NE.3) RETURN
      TEMP=FLOAT(NROW)
      FJROW(1)=-TEMP*EXP(TEMP*X(1))
      FJROW(2)=-TEMP*EXP(TEMP*X(2))
      RETURN
      END
      FUNCTION SOSFNC(X,K)
C
C     FUNCTION WHICH EVALUATES THE FUNCTIONS, ONE AT A TIME,
C     FOR TEST PROGRAM USED IN QUICK CHECK OF SOS.
      DIMENSION X(2)
      IF (K.EQ.1) SOSFNC=1.E0-X(1)
      IF (K.EQ.2) SOSFNC=1.E1*(X(2)-X(1)**2)
      RETURN
      END
      SUBROUTINE SQFCN2(N,X,FVEC,IFLAG)
C
C     SUBROUTINE WHICH EVALUATES THE FUNCTION FOR TEST
C     PROGRAM USED IN QUICK CHECK OF SNSQE.
      DIMENSION X(N),FVEC(N)
      FVEC(1)=1.E0-X(1)
      FVEC(2)=1.E1*(X(2)-X(1)**2)
      RETURN
      END
      SUBROUTINE SQJAC2(N,X,FVEC,FJAC,LDFJAC,IFLAG)
C
C     SUBROUTINE TO EVALUATE THE FULL JACOBIAN FOR TEST PROBLEM USED
C     IN QUICK CHECK OF SNSQE.
      DIMENSION X(N),FVEC(N),FJAC(LDFJAC,N)
      FJAC(1,1)=-1.E0
      FJAC(1,2)=0.E0
      FJAC(2,1)=-2.E1*X(1)
      FJAC(2,2)=1.E1
      RETURN
      END