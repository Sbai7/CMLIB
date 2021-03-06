      SUBROUTINE BESYNU(X,FNU,N,Y)
C***BEGIN PROLOGUE  BESYNU
C***REFER TO  BESY
C
C     Written by D. E. Amos, May, 1980
C
C     References
C         On The Numerical Evaluation of The Ordinary Bessel Function
C         of The Second Kind by N.M. Temme, J. COMP. PHYSICS, 21,
C         1976, PP. 343-350.
C
C         On The Numerical Evaluation of The Modified Bessel Function
C         of The Third Kind by N.M. Temme, J. COMP. PHYSICS, 19, 1975,
C         PP. 324-337
C
C     Abstract
C         BESYNU computes N member sequences of Y Bessel functions
C         Y/SUB(FNU+I-1)/(X), I=1,N for non-negative orders FNU and
C         positive X. Equations of the references are implemented on
C         small orders DNU for Y/SUB(DNU)/(X) and Y/SUB(DNU+1)/(X).
C         Forward recursion with the three term recursion relation
C         generates higher orders FNU+I-1, I=1,...,N.
C
C         To start the recursion FNU is normalized to the interval
C         -0.5.LE.DNU.LT.0.5. A special form of the power series is
C         implemented on 0.LT.X.LE.X1 while the Miller algorithm for the
C         K Bessel function in terms of the confluent hypergeometric
C         function U(FNU+0.5,2*FNU+1,I*X) is implemented on X1.LT.X.LE.X
C         Here I is the complex number SQRT(-1.).
C         For X.GT.X2, the asymptotic expansion for large X is used.
C         When FNU is a half odd integer, a special formula for
C         DNU=-0.5 and DNU+1.0=0.5 is used to start the recursion.
C
C         BESYNU assumes that a significant digit SINH(X) function is
C         available.
C
C         BESYNU calls GAMMA,SINH,COSH,I1MACH,R1MACH,XERROR
C
C     Description of Arguments
C
C         Input
C           X      - X.GT.0.0E0
C           FNU    - Order of initial Y function, FNU.GE.0.0E0
C           N      - Number of members of the sequence, N.GE.1
C
C         Output
C           Y      - A vector whose first N components contain values
C                    for the sequence Y(I)=Y/SUB(FNU+I-1), I=1,N.
C
C     Error Conditions
C         Improper input arguments - a fatal error
C         Overflow - a fatal error
C***ROUTINES CALLED  GAMMA,R1MACH,XERROR
C***END PROLOGUE  BESYNU
      EXTERNAL GAMMA
C
      INTEGER I, INU, J, K, KK, N, NN
      REAL A, AK, ARG, A1, A2, BK, CB, CBK, CC, CCK, CK, COEF, CPT,
     1 CP1, CP2, CS, CS1, CS2, CX, DNU, DNU2, ETEST, ETX, F, FC, FHS,
     2 FK, FKS, FLRX, FMU, FN, FNU, FX, G, G1, G2, HPI, P, PI, PT, Q,
     3 RB, RBK, RCK, RELB, RPT, RP1, RP2, RS, RS1, RS2, RTHPI, RX, S,
     4 SA, SB, SMU, SS, ST, S1, S2, TB, TM, TOL, T1, T2, X, X1, X2, Y
      REAL GAMMA, R1MACH, SINH, COSH
      DIMENSION A(120), RB(120), CB(120), Y(*), CC(8)
      SAVE X1, X2, PI, RTHPI, HPI, CC
      DATA X1, X2 / 3.0E0, 20.0E0 /
      DATA PI,RTHPI        / 3.14159265358979E+00, 7.97884560802865E-01/
      DATA HPI             / 1.57079632679490E+00/
      DATA CC(1), CC(2), CC(3), CC(4), CC(5), CC(6), CC(7), CC(8)
     1                     / 5.77215664901533E-01,-4.20026350340952E-02,
     2-4.21977345555443E-02, 7.21894324666300E-03,-2.15241674114900E-04,
     3-2.01348547807000E-05, 1.13302723200000E-06, 6.11609500000000E-09/
C***FIRST EXECUTABLE STATEMENT  BESYNU
      AK = R1MACH(3)
      TOL = AMAX1(AK,1.0E-15)
      IF (X.LE.0.0E0) GO TO 270
      IF (FNU.LT.0.0E0) GO TO 280
      IF (N.LT.1) GO TO 290
      RX = 2.0E0/X
      INU = INT(FNU+0.5E0)
      DNU = FNU - FLOAT(INU)
      IF (ABS(DNU).EQ.0.5E0) GO TO 260
      DNU2 = 0.0E0
      IF (ABS(DNU).LT.TOL) GO TO 10
      DNU2 = DNU*DNU
   10 CONTINUE
      IF (X.GT.X1) GO TO 120
C
C     SERIES FOR X.LE.X1
C
      A1 = 1.0E0 - DNU
      A2 = 1.0E0 + DNU
      T1 = 1.0E0/GAMMA(A1)
      T2 = 1.0E0/GAMMA(A2)
      IF (ABS(DNU).GT.0.1E0) GO TO 40
C     SERIES FOR F0 TO RESOLVE INDETERMINACY FOR SMALL ABS(DNU)
      S = CC(1)
      AK = 1.0E0
      DO 20 K=2,8
        AK = AK*DNU2
        TM = CC(K)*AK
        S = S + TM
        IF (ABS(TM).LT.TOL) GO TO 30
   20 CONTINUE
   30 G1 = -(S+S)
      GO TO 50
   40 CONTINUE
      G1 = (T1-T2)/DNU
   50 CONTINUE
      G2 = T1 + T2
      SMU = 1.0E0
      FC = 1.0E0/PI
      FLRX = ALOG(RX)
      FMU = DNU*FLRX
      TM = 0.0E0
      IF (DNU.EQ.0.0E0) GO TO 60
      TM = SIN(DNU*HPI)/DNU
      TM = (DNU+DNU)*TM*TM
      FC = DNU/SIN(DNU*PI)
      IF (FMU.NE.0.0E0) SMU = SINH(FMU)/FMU
   60 CONTINUE
      F = FC*(G1*COSH(FMU)+G2*FLRX*SMU)
      FX = EXP(FMU)
      P = FC*T1*FX
      Q = FC*T2/FX
      G = F + TM*Q
      AK = 1.0E0
      CK = 1.0E0
      BK = 1.0E0
      S1 = G
      S2 = P
      IF (INU.GT.0 .OR. N.GT.1) GO TO 90
      IF (X.LT.TOL) GO TO 80
      CX = X*X*0.25E0
   70 CONTINUE
      F = (AK*F+P+Q)/(BK-DNU2)
      P = P/(AK-DNU)
      Q = Q/(AK+DNU)
      G = F + TM*Q
      CK = -CK*CX/AK
      T1 = CK*G
      S1 = S1 + T1
      BK = BK + AK + AK + 1.0E0
      AK = AK + 1.0E0
      S = ABS(T1)/(1.0E0+ABS(S1))
      IF (S.GT.TOL) GO TO 70
   80 CONTINUE
      Y(1) = -S1
      RETURN
   90 CONTINUE
      IF (X.LT.TOL) GO TO 110
      CX = X*X*0.25E0
  100 CONTINUE
      F = (AK*F+P+Q)/(BK-DNU2)
      P = P/(AK-DNU)
      Q = Q/(AK+DNU)
      G = F + TM*Q
      CK = -CK*CX/AK
      T1 = CK*G
      S1 = S1 + T1
      T2 = CK*(P-AK*G)
      S2 = S2 + T2
      BK = BK + AK + AK + 1.0E0
      AK = AK + 1.0E0
      S = ABS(T1)/(1.0E0+ABS(S1)) + ABS(T2)/(1.0E0+ABS(S2))
      IF (S.GT.TOL) GO TO 100
  110 CONTINUE
      S2 = -S2*RX
      S1 = -S1
      GO TO 160
  120 CONTINUE
      COEF = RTHPI/SQRT(X)
      IF (X.GT.X2) GO TO 210
C
C     MILLER ALGORITHM FOR X1.LT.X.LE.X2
C
      ETEST = COS(PI*DNU)/(PI*X*TOL)
      FKS = 1.0E0
      FHS = 0.25E0
      FK = 0.0E0
      RCK = 2.0E0
      CCK = X + X
      RP1 = 0.0E0
      CP1 = 0.0E0
      RP2 = 1.0E0
      CP2 = 0.0E0
      K = 0
  130 CONTINUE
      K = K + 1
      FK = FK + 1.0E0
      AK = (FHS-DNU2)/(FKS+FK)
      PT = FK + 1.0E0
      RBK = RCK/PT
      CBK = CCK/PT
      RPT = RP2
      CPT = CP2
      RP2 = RBK*RPT - CBK*CPT - AK*RP1
      CP2 = CBK*RPT + RBK*CPT - AK*CP1
      RP1 = RPT
      CP1 = CPT
      RB(K) = RBK
      CB(K) = CBK
      A(K) = AK
      RCK = RCK + 2.0E0
      FKS = FKS + FK + FK + 1.0E0
      FHS = FHS + FK + FK
      PT = AMAX1(ABS(RP1),ABS(CP1))
      FC = (RP1/PT)**2 + (CP1/PT)**2
      PT = PT*SQRT(FC)*FK
      IF (ETEST.GT.PT) GO TO 130
      KK = K
      RS = 1.0E0
      CS = 0.0E0
      RP1 = 0.0E0
      CP1 = 0.0E0
      RP2 = 1.0E0
      CP2 = 0.0E0
      DO 140 I=1,K
        RPT = RP2
        CPT = CP2
        RP2 = (RB(KK)*RPT-CB(KK)*CPT-RP1)/A(KK)
        CP2 = (CB(KK)*RPT+RB(KK)*CPT-CP1)/A(KK)
        RP1 = RPT
        CP1 = CPT
        RS = RS + RP2
        CS = CS + CP2
        KK = KK - 1
  140 CONTINUE
      PT = AMAX1(ABS(RS),ABS(CS))
      FC = (RS/PT)**2 + (CS/PT)**2
      PT = PT*SQRT(FC)
      RS1 = (RP2*(RS/PT)+CP2*(CS/PT))/PT
      CS1 = (CP2*(RS/PT)-RP2*(CS/PT))/PT
      FC = HPI*(DNU-0.5E0) - X
      P = COS(FC)
      Q = SIN(FC)
      S1 = (CS1*Q-RS1*P)*COEF
      IF (INU.GT.0 .OR. N.GT.1) GO TO 150
      Y(1) = S1
      RETURN
  150 CONTINUE
      PT = AMAX1(ABS(RP2),ABS(CP2))
      FC = (RP2/PT)**2 + (CP2/PT)**2
      PT = PT*SQRT(FC)
      RPT = DNU + 0.5E0 - (RP1*(RP2/PT)+CP1*(CP2/PT))/PT
      CPT = X - (CP1*(RP2/PT)-RP1*(CP2/PT))/PT
      CS2 = CS1*CPT - RS1*RPT
      RS2 = RPT*CS1 + RS1*CPT
      S2 = (RS2*Q+CS2*P)*COEF/X
C
C     FORWARD RECURSION ON THE THREE TERM RECURSION RELATION
C
  160 CONTINUE
      CK = (DNU+DNU+2.0E0)/X
      IF (N.EQ.1) INU = INU - 1
      IF (INU.GT.0) GO TO 170
      IF (N.GT.1) GO TO 190
      S1 = S2
      GO TO 190
  170 CONTINUE
      DO 180 I=1,INU
        ST = S2
        S2 = CK*S2 - S1
        S1 = ST
        CK = CK + RX
  180 CONTINUE
      IF (N.EQ.1) S1 = S2
  190 CONTINUE
      Y(1) = S1
      IF (N.EQ.1) RETURN
      Y(2) = S2
      IF (N.EQ.2) RETURN
      DO 200 I=3,N
        Y(I) = CK*Y(I-1) - Y(I-2)
        CK = CK + RX
  200 CONTINUE
      RETURN
C
C     ASYMPTOTIC EXPANSION FOR LARGE X, X.GT.X2
C
  210 CONTINUE
      NN = 2
      IF (INU.EQ.0 .AND. N.EQ.1) NN = 1
      DNU2 = DNU + DNU
      FMU = 0.0E0
      IF (ABS(DNU2).LT.TOL) GO TO 220
      FMU = DNU2*DNU2
  220 CONTINUE
      ARG = X - HPI*(DNU+0.5E0)
      SA = SIN(ARG)
      SB = COS(ARG)
      ETX = 8.0E0*X
      DO 250 K=1,NN
        S1 = S2
        T2 = (FMU-1.0E0)/ETX
        SS = T2
        RELB = TOL*ABS(T2)
        T1 = ETX
        S = 1.0E0
        FN = 1.0E0
        AK = 0.0E0
        DO 230 J=1,13
          T1 = T1 + ETX
          AK = AK + 8.0E0
          FN = FN + AK
          T2 = -T2*(FMU-FN)/T1
          S = S + T2
          T1 = T1 + ETX
          AK = AK + 8.0E0
          FN = FN + AK
          T2 = T2*(FMU-FN)/T1
          SS = SS + T2
          IF (ABS(T2).LE.RELB) GO TO 240
  230   CONTINUE
  240   S2 = COEF*(S*SA+SS*SB)
        FMU = FMU + 8.0E0*DNU + 4.0E0
        TB = SA
        SA = -SB
        SB = TB
  250 CONTINUE
      IF (NN.GT.1) GO TO 160
      S1 = S2
      GO TO 190
C
C     FNU=HALF ODD INTEGER CASE
C
  260 CONTINUE
      COEF = RTHPI/SQRT(X)
      S1 = COEF*SIN(X)
      S2 = -COEF*COS(X)
      GO TO 160
C
C
  270 CALL XERROR( 'IN BESYNU, X NOT GREATER THAN ZERO', 34, 2, 1)
      RETURN
  280 CALL XERROR( 'IN BESYNU, FNU NOT ZERO OR POSITIVE', 35, 2, 1)
      RETURN
  290 CALL XERROR( 'IN BESYNU, N NOT GREATER THAN 0', 31, 2, 1)
      RETURN
      END
