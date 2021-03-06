      SUBROUTINE DNL2RD(DR, IV, L, LIV, LV, N, NN, P, R, RD1, RD2, V)
C
C  ***  COMPUTE REGRESSION DIAGNOSTIC AND DEFAULT COVARIANCE MATRIX FOR
C       DNL2IT  ***
C
C  ***  PARAMETERS  ***
C
      INTEGER LIV, LV, N, NN, P
      INTEGER IV(LIV)
C/6
      DOUBLE PRECISION DR(N,P,NN), L(*), R(N,NN), RD1(N,NN),
     1             RD2(N,NN), V(LV)
C     DIMENSI0N L(P*(P+1)/2)
C/7
C     DOUBLE PRECISION DR(N,P,NN), L(P*(P+1)/2), R(N,NN), RD1(N,NN),
C    1             RD2(N,NN), V(LV)
C/
C
C  ***  CODED BY DAVID M. GAY (WINTER 1982)  ***
C
C***REVISION HISTORY  (YYMMDD)
C   000330  Modified array declarations.  (JEC)
C
C  ***  EXTERNAL FUNCTIONS AND SUBROUTINES  ***
C
      EXTERNAL  DLIVMU, DLITVM, DLTVMU, DOPRDS, DVAXPY,
     1         DVSCPY
      DOUBLE PRECISION DDOT, DNRM2
C
C  ***  LOCAL VARIABLES  ***
C
      LOGICAL D1, D2
      INTEGER COV, I, J, K, LH, M, STEP1
      DOUBLE PRECISION A, S, T
C
C  ***  CONSTANTS  ***
C
      DOUBLE PRECISION NEGONE, ONE, ONEV(1), ZERO
C
C  ***  INTRINSIC FUNCTIONS  ***
C/+
      INTEGER IABS
      DOUBLE PRECISION DSQRT
C/
C
C  ***  IV SUBSCRIPTS  ***
C
      INTEGER D, FDH, MODE, RDREQ, STEP
C/6
      DATA D/27/, FDH/74/, MODE/35/, RDREQ/57/, STEP/40/
C/7
C     PARAMETER (D=27, FDH=74, MODE=35, RDREQ=57, STEP=40)
C/
C/6
      DATA NEGONE/-1.D+0/, ONE/1.D+0/, ZERO/0.D+0/
C/7
C     PARAMETER (NEGONE=-1.D+0, ONE=1.D+0, ZERO=0.D+0)
C/
      DATA ONEV(1)/1.D+0/
C
C++++++++++++++++++++++++++++++++  BODY  +++++++++++++++++++++++++++++++
C
      STEP1 = IV(STEP)
      I = IV(RDREQ)
      IF (I .LE. 0) GO TO 40
      D1 = I .EQ. 1 .OR. I .GE. 3
      D2 = I .GE. 2
      IF (D1) CALL DVSCPY(NN*N, RD1, NEGONE)
      IF (D2) CALL DVSCPY(NN*N, RD2, NEGONE)
      DO 30 K = 1, NN
         DO 20 I = 1, N
            A = R(I,K)**2
            M = STEP1
            DO 10 J = 1, P
               V(M) = DR(I,J,K)
               M = M + 1
 10            CONTINUE
            CALL DLIVMU(P, V(STEP1), L, V(STEP1))
            S = DDOT(P, V(STEP1),1,V(STEP1),1)
            T = ONE - S
            IF (T .LE. ZERO) GO TO 20
            A = A * S / T
            IF (D1) RD1(I,K) = DSQRT(A)
            IF (D2) RD2(I,K) = DSQRT(A / T)
 20         CONTINUE
 30      CONTINUE
C
 40   IF (IV(MODE) - P .LT. 2) GO TO 999
C
C  ***  COMPUTE DEFAULT COVARIANCE MATRIX  ***
C
      LH = P*(P+1)/2
      COV = IABS(IV(FDH))
      DO 70 K = 1, NN
         DO 60 I = 1, N
            M = STEP1
            DO 50 J = 1, P
               V(M) = DR(I,J,K)
               M = M + 1
 50            CONTINUE
            CALL DLIVMU(P, V(STEP1), L, V(STEP1))
            CALL DLITVM(P, V(STEP1), L, V(STEP1))
            CALL DOPRDS(1, LH, P, V(COV), ONEV, V(STEP1), V(STEP1))
 60         CONTINUE
 70      CONTINUE
C
 999  RETURN
C  ***  LAST CARD OF DNL2RD FOLLOWS  ***
      END
