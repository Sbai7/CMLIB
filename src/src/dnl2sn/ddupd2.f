      SUBROUTINE DDUPD2(D, DR, IV, LIV, LV, N, NB, NN, N1, P, V)
C
C  ***  UPDATE SCALE VECTOR D FOR DNL2IT  ***
C
C  ***  PARAMETER DECLARATIONS  ***
C
      INTEGER LIV, LV, N, NB, NN, N1, P
      INTEGER IV(LIV)
      DOUBLE PRECISION D(P), DR(N,P,NN), V(LV)
C     DIMENSION V(*)
C
C  ***  LOCAL VARIABLES  ***
C
      INTEGER D0, I, JCN0, JCN1, JCNI, JTOL0, JTOLI, K, L, SII
      DOUBLE PRECISION T, VDFAC
C
C     ***  CONSTANTS  ***
C
      DOUBLE PRECISION ZERO
C
C  ***  INTRINSIC FUNCTIONS  ***
C/+
      DOUBLE PRECISION DABS, DMAX1, DSQRT
C/
C  ***  EXTERNAL SUBROUTINE  ***
C
      EXTERNAL DVSCPY
C
C DVSCPY... SETS ALL COMPONENTS OF A VECTOR TO A SCALAR.
C
C  ***  SUBSCRIPTS FOR IV AND V  ***
C
      INTEGER DFAC, DTYPE, JCN, JTOL, NITER, S
C/6
      DATA DFAC/41/, DTYPE/16/, JCN/66/, JTOL/59/, NITER/31/, S/62/
C/7
C     PARAMETER (DFAC=41, DTYPE=16, JCN=66, JTOL=59, NITER=31, S=62)
C/
C
C/6
      DATA ZERO/0.D+0/
C/7
C     PARAMETER (ZERO=0.D+0)
C/
C
C-------------------------------  BODY  --------------------------------
C
      IF (IV(DTYPE) .NE. 1 .AND. IV(NITER) .GT. 0) GO TO 999
      JCN1 = IV(JCN)
      JCN0 = IABS(JCN1) - 1
      IF (JCN1 .LT. 0) GO TO 10
         IV(JCN) = -JCN1
         CALL DVSCPY(P, V(JCN1), ZERO)
 10   DO 40 L = 1, NN
         DO 30 I = 1, P
              JCNI = JCN0 + I
              T  = V(JCNI)
              DO 20 K = 1, N
 20                T = DMAX1(T, DABS(DR(K,I,L)))
              V(JCNI) = T
 30           CONTINUE
 40      CONTINUE
      IF (N1 .LT. NB) GO TO 999
      VDFAC = V(DFAC)
      JTOL0 = IV(JTOL) - 1
      D0 = JTOL0 + P
      SII = IV(S) - 1
      DO 50 I = 1, P
         SII = SII + I
         JCNI = JCN0 + I
         T = V(JCNI)
         IF (V(SII) .GT. ZERO) T = DMAX1(DSQRT(V(SII)), T)
         JTOLI = JTOL0 + I
         D0 = D0 + 1
         IF (T .LT. V(JTOLI)) T = DMAX1(V(D0), V(JTOLI))
         D(I) = DMAX1(VDFAC*D(I), T)
 50      CONTINUE
C
 999  RETURN
C  ***  LAST CARD OF DDUPD2 FOLLOWS  ***
      END
