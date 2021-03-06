      SUBROUTINE XDPQNU(NU1,NU2,MU,THETA,ID,PQA,IPQA)
C***BEGIN PROLOGUE  XDPQNU
C***REFER TO  XDLEGF
C***ROUTINES CALLED  XDADD, XDADJ, XDPSI
C***COMMON BLOCKS    XDBLK1
C***DATE WRITTEN   820728   (YYMMDD)
C***REVISION DATE  871119   (YYMMDD)
C***CATEGORY NO.  C3A2,C9
C***KEYWORDS  LEGENDRE FUNCTIONS
C***AUTHOR  SMITH, JOHN M. (NBS AND GEORGE MASON UNIVERSITY)
C***PURPOSE  TO COMPUTE THE VALUES OF LEGENDRE FUNCTIONS FOR XDLEGF.
C        SUBROUTINE XDPQNU CALCULATES INITIAL VALUES OF P OR Q
C        USING POWER SERIES.  THEN XDPQNU PERFORMS FORWARD NU-WISE
C        RECURRENCE TO OBTAIN P(-MU,NU,X), Q(0,NU,X), OR Q(1,NU,X).
C        THE FORWARD NU-WISE RECURRENCE IS STABLE FOR P FOR ALL
C        VALUES OF MU, AND IS STABLE FOR Q FOR MU=0 OR 1.
C***REFERENCES  OLVER AND SMITH,J.COMPUT.PHYSICS,51(1983),N0.3,502-518.
C***END PROLOGUE  XDPQNU
      DOUBLE PRECISION A,NU,NU1,NU2,PQ,PQA,XDPSI,R,THETA,W,X,X1,X2,XS,
     1 Y,Z
      DOUBLE PRECISION DI,DMU,PQ1,PQ2,FACTMU,FLOK
      DIMENSION PQA(*),IPQA(*)
      COMMON /XDBLK1/ NBITSF
C
C        J0, IPSIK, AND IPSIX ARE INITIALIZED IN THIS SUBROUTINE.
C        J0 IS THE NUMBER OF TERMS USED IN SERIES EXPANSION
C        IN SUBROUTINE XDPQNU.
C        IPSIK, IPSIX ARE VALUES OF K AND X RESPECTIVELY
C        USED IN THE CALCULATION OF THE XDPSI FUNCTION.
C
C***FIRST EXECUTABLE STATEMENT   XDPQNU
      J0=NBITSF
      IPSIK=1+(NBITSF/10)
      IPSIX=5*IPSIK
      IPQ=0
C        FIND NU IN INTERVAL [-.5,.5) IF ID=2  ( CALCULATION OF Q )
      NU=DMOD(NU1,1.D0)
      IF(NU.GE..5D0) NU=NU-1.D0
C        FIND NU IN INTERVAL (-1.5,-.5] IF ID=1,3, OR 4  ( CALCULATION O
      IF(ID.NE.2.AND.NU.GT.-.5D0) NU=NU-1.D0
C        CALCULATE MU FACTORIAL
      K=MU
      DMU=DBLE(FLOAT(MU))
      IF(MU.LE.0) GO TO 60
      FACTMU=1.D0
      IF=0
      DO 50 I=1,K
      FACTMU=FACTMU*DBLE(FLOAT(I))
   50 CALL XDADJ(FACTMU,IF)
   60 IF(K.EQ.0) FACTMU=1.D0
      IF(K.EQ.0) IF=0
C
C        X=COS(THETA)
C        Y=SIN(THETA/2)**2=(1-X)/2=.5-.5*X
C        R=TAN(THETA/2)=SQRT((1-X)/(1+X)
C
      X=DCOS(THETA)
      Y=DSIN(THETA/2.D0)**2
      R=DTAN(THETA/2.D0)
C
C        USE ASCENDING SERIES TO CALCULATE TWO VALUES OF P OR Q
C        FOR USE AS STARTING VALUES IN RECURRENCE RELATION.
C
      PQ2=0.0D0
      DO 100 J=1,2
      IPQ1=0
      IF(ID.EQ.2) GO TO 80
C
C        SERIES FOR P ( ID = 1, 3, OR 4 )
C        P(-MU,NU,X)=1./FACTORIAL(MU)*SQRT(((1.-X)/(1.+X))**MU)
C                *SUM(FROM 0 TO J0-1)A(J)*(.5-.5*X)**J
C
      IPQ=0
      PQ=1.D0
      A=1.D0
      IA=0
      DO 65 I=2,J0
      DI=DBLE(FLOAT(I))
      A=A*Y*(DI-2.D0-NU)*(DI-1.D0+NU)/((DI-1.D0+DMU)*(DI-1.D0))
      CALL XDADJ(A,IA)
      IF(A.EQ.0.D0) GO TO 66
      CALL XDADD(PQ,IPQ,A,IA,PQ,IPQ)
   65 CONTINUE
   66 CONTINUE
      IF(MU.LE.0) GO TO 90
      X2=R
      X1=PQ
      K=MU
      DO 77 I=1,K
      X1=X1*X2
   77 CALL XDADJ(X1,IPQ)
      PQ=X1/FACTMU
      IPQ=IPQ-IF
      CALL XDADJ(PQ,IPQ)
      GO TO 90
C
C        Z=-LN(R)=.5*LN((1+X)/(1-X))
C
   80 Z=-DLOG(R)
      W=XDPSI(NU+1.D0,IPSIK,IPSIX)
      XS=1.D0/DSIN(THETA)
C
C        SERIES SUMMATION FOR Q ( ID = 2 )
C        Q(0,NU,X)=SUM(FROM 0 TO J0-1)((.5*LN((1+X)/(1-X))
C    +XDPSI(J+1,IPSIK,IPSIX)-XDPSI(NU+1,IPSIK,IPSIX)))*A(J)*(.5-.5*X)**J
C
C        Q(1,NU,X)=-SQRT(1./(1.-X**2))+SQRT((1-X)/(1+X))
C             *SUM(FROM 0 T0 J0-1)(-NU*(NU+1)/2*LN((1+X)/(1-X))
C                 +(J-NU)*(J+NU+1)/(2*(J+1))+NU*(NU+1)*
C     (XDPSI(NU+1,IPSIK,IPSIX)-XDPSI(J+1,IPSIK,IPSIX))*A(J)*(.5-.5*X)**J
C
C        NOTE, IN THIS LOOP K=J+1
C
      PQ=0.D0
      IPQ=0
      IA=0
      A=1.D0
      DO 85 K=1,J0
      FLOK=DBLE(FLOAT(K))
      IF(K.EQ.1) GO TO 81
      A=A*Y*(FLOK-2.D0-NU)*(FLOK-1.D0+NU)/((FLOK-1.D0+DMU)*(FLOK-1.D0))
      CALL XDADJ(A,IA)
   81 CONTINUE
      IF(MU.GE.1) GO TO 83
      X1=(XDPSI(FLOK,IPSIK,IPSIX)-W+Z)*A
      IX1=IA
      CALL XDADD(PQ,IPQ,X1,IX1,PQ,IPQ)
      GO TO 85
   83 X1=(NU*(NU+1.D0)*(Z-W+XDPSI(FLOK,IPSIK,IPSIX))+(NU-FLOK+1.D0)
     1  *(NU+FLOK)/(2.D0*K))*A
      IX1=IA
      CALL XDADD(PQ,IPQ,X1,IX1,PQ,IPQ)
   85 CONTINUE
      IF(MU.GE.1) PQ=-R*PQ
      IXS=0
      IF(MU.GE.1) CALL XDADD(PQ,IPQ,-XS,IXS,PQ,IPQ)
      IF(J.EQ.2) MU=-MU
      IF(J.EQ.2) DMU=-DMU
   90 IF(J.EQ.1) PQ2=PQ
      IF(J.EQ.1) IPQ2=IPQ
      NU=NU+1.D0
  100 CONTINUE
      K=0
      IF(NU-1.5D0.LT.NU1) GO TO 120
      K=K+1
      PQA(K)=PQ2
      IPQA(K)=IPQ2
      IF(NU.GT.NU2+.5D0) RETURN
  120 PQ1=PQ
      IPQ1=IPQ
      IF(NU.LT.NU1+.5D0) GO TO 130
      K=K+1
      PQA(K)=PQ
      IPQA(K)=IPQ
      IF(NU.GT.NU2+.5D0) RETURN
C
C        FORWARD NU-WISE RECURRENCE FOR F(MU,NU,X) FOR FIXED MU
C        USING
C        (NU+MU+1)*F(MU,NU,X)=(2.*NU+1)*F(MU,NU,X)-(NU-MU)*F(MU,NU-1,X)
C        WHERE F(MU,NU,X) MAY BE P(-MU,NU,X) OR IF MU IS REPLACED
C        BY -MU THEN F(MU,NU,X) MAY BE Q(MU,NU,X).
C        NOTE, IN THIS LOOP, NU=NU+1
C
  130 X1=(2.D0*NU-1.D0)/(NU+DMU)*X*PQ1
      X2=(NU-1.D0-DMU)/(NU+DMU)*PQ2
      CALL XDADD(X1,IPQ1,-X2,IPQ2,PQ,IPQ)
      CALL XDADJ(PQ,IPQ)
      NU=NU+1.D0
      PQ2=PQ1
      IPQ2=IPQ1
      GO TO 120
C
C
      END
