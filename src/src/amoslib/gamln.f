      FUNCTION GAMLN(X)
C
C     WRITTEN BY D. E. AMOS, SEPTEMBER, 1977.
C
C     REFERENCES
C         SAND-77-1518
C
C         COMPUTER APPROXIMATIONS BY J.F.HART, ET.AL., SIAM SERIES IN
C         APPLIED MATHEMATICS, WILEY, 1968, P.135-136.
C
C         NBS HANDBOOK OF MATHEMATICAL FUNCTIONS, AMS 55, BY
C         M. ABRAMOWITZ AND I.A. STEGUN, DECEMBER. 1955, P.257.
C
C     ABSTRACT
C         GAMLN COMPUTES THE NATURAL LOG OF THE GAMMA FUNCTION FOR
C         X.GT.0. A RATIONAL CHEBYSHEV APPROXIMATION IS USED ON
C         8.LT.X.LT.1000., THE ASYMPTOTIC EXPANSION FOR X.GE.1000. AND
C         A RATIONAL CHEBYSHEV APPROXIMATION ON 2.LT.X.LT.3. FOR
C         0.LT.X.LT.8. AND X NON-INTEGRAL, FORWARD OR BACKWARD
C         RECURSION FILLS IN THE INTERVALS  0.LT.X.LT.2 AND
C         3.LT.X.LT.8. FOR X=1.,2.,...,100., GAMLN IS SET TO
C         NATURAL LOGS OF FACTORIALS.
C
C     DESCRIPTION OF ARGUMENTS
C
C         INPUT
C           X      - X.GT.0
C
C         OUTPUT
C           GAMLN  - NATURAL LOG OF THE GAMMA FUNCTION AT X
C
C     ERROR CONDITIONS
C         IMPROPER INPUT ARGUMENT - A FATAL ERROR
C
C
C
      DIMENSION GLN(100),P(5),Q(2),PCOE(9),QCOE(4)
C
      DATA XLIM1,XLIM2,RTWPIL/    8.  ,  1000.   , 9.18938533204673E-01/
C
      DATA  P              / 7.66345188000000E-04,-5.94095610520000E-04,
     1 7.93643110484500E-04,-2.77777775657725E-03, 8.33333333333169E-02/
C
      DATA  Q              /-2.77777777777778E-03, 8.33333333333333E-02/
C
      DATA PCOE            / 2.97378664481017E-03, 9.23819455902760E-03,
     1 1.09311595671044E-01, 3.98067131020357E-01, 2.15994312846059E+00,
     2 6.33806799938727E+00, 2.07824725317921E+01, 3.60367725300248E+01,
     3 6.20038380071273E+01/
C
      DATA QCOE            / 1.00000000000000E+00,-8.90601665949746E+00,
     1 9.82252110471399E+00, 6.20038380071270E+01/
C
      DATA(GLN(I),I=1,60)  /         2*0.        , 6.93147180559945E-01,
     1 1.79175946922806E+00, 3.17805383034795E+00, 4.78749174278205E+00,
     2 6.57925121201010E+00, 8.52516136106541E+00, 1.06046029027453E+01,
     3 1.28018274800815E+01, 1.51044125730755E+01, 1.75023078458739E+01,
     4 1.99872144956619E+01, 2.25521638531234E+01, 2.51912211827387E+01,
     5 2.78992713838409E+01, 3.06718601060807E+01, 3.35050734501369E+01,
     6 3.63954452080331E+01, 3.93398841871995E+01, 4.23356164607535E+01,
     7 4.53801388984769E+01, 4.84711813518352E+01, 5.16066755677644E+01,
     8 5.47847293981123E+01, 5.80036052229805E+01, 6.12617017610020E+01,
     9 6.45575386270063E+01, 6.78897431371815E+01, 7.12570389671680E+01,
     A 7.46582363488302E+01, 7.80922235533153E+01, 8.15579594561150E+01,
     B 8.50544670175815E+01, 8.85808275421977E+01, 9.21361756036871E+01,
     C 9.57196945421432E+01, 9.93306124547874E+01, 1.02968198614514E+02,
     D 1.06631760260643E+02, 1.10320639714757E+02, 1.14034211781462E+02,
     E 1.17771881399745E+02, 1.21533081515439E+02, 1.25317271149357E+02,
     F 1.29123933639127E+02, 1.32952575035616E+02, 1.36802722637326E+02,
     G 1.40673923648234E+02, 1.44565743946345E+02, 1.48477766951773E+02,
     H 1.52409592584497E+02, 1.56360836303079E+02, 1.60331128216631E+02,
     I 1.64320112263195E+02, 1.68327445448428E+02, 1.72352797139163E+02,
     J 1.76395848406997E+02, 1.80456291417544E+02, 1.84533828861449E+02/
      DATA(GLN(I),I=61,100)/ 1.88628173423672E+02, 1.92739047287845E+02,
     1 1.96866181672890E+02, 2.01009316399282E+02, 2.05168199482641E+02,
     2 2.09342586752537E+02, 2.13532241494563E+02, 2.17736934113954E+02,
     3 2.21956441819130E+02, 2.26190548323728E+02, 2.30439043565777E+02,
     4 2.34701723442818E+02, 2.38978389561834E+02, 2.43268849002983E+02,
     5 2.47572914096187E+02, 2.51890402209723E+02, 2.56221135550010E+02,
     6 2.60564940971863E+02, 2.64921649798553E+02, 2.69291097651020E+02,
     7 2.73673124285694E+02, 2.78067573440366E+02, 2.82474292687630E+02,
     8 2.86893133295427E+02, 2.91323950094270E+02, 2.95766601350761E+02,
     9 3.00220948647014E+02, 3.04686856765669E+02, 3.09164193580147E+02,
     A 3.13652829949879E+02, 3.18152639620209E+02, 3.22663499126726E+02,
     B 3.27185287703775E+02, 3.31717887196928E+02, 3.36261181979198E+02,
     C 3.40815058870799E+02, 3.45379407062267E+02, 3.49954118040770E+02,
     D 3.54539085519441E+02, 3.59134205369575E+02/
C
      IF(X) 90,90,5
   5  NDX=X
      T=X-FLOAT(NDX)
      IF(T.EQ.0.0) GO TO 51
      DX=XLIM1-X
      IF(DX.LT.0.0) GO TO 40
C
C     RATIONAL CHEBYSHEV APPROXIMATION ON 2.LT.X.LT.3 FOR GAMMA(X)
C
      NXM=NDX-2
      PX=PCOE(1)
      DO 10 I=2,9
   10 PX=T*PX+PCOE(I)
      QX=QCOE(1)
      DO 15 I=2,4
   15 QX=T*QX+QCOE(I)
      DGAM=PX/QX
      IF(NXM.GT.0) GO TO 22
      IF(NXM.EQ.0) GO TO 25
C
C     BACKWARD RECURSION FOR 0.LT.X.LT.2
C
      DGAM=DGAM/(1.+T)
      IF(NXM.EQ.-1) GO TO 25
      DGAM=DGAM/T
      GAMLN=ALOG(DGAM)
      RETURN
C
C     FORWARD RECURSION FOR 3.LT.X.LT.8
C
   22 XX=2.+T
      DO 24 I=1,NXM
      DGAM=DGAM*XX
   24 XX=XX+1.
   25 GAMLN=ALOG(DGAM)
      RETURN
C
C     X.GT.XLIM1
C
   40 RX=1./X
      RXX=RX*RX
      IF((X-XLIM2).LT.0.) GO TO 41
      PX=Q(1)*RXX+Q(2)
      GAMLN=PX*RX+(X-.5)*ALOG(X)-X+RTWPIL
      RETURN
C
C     X.LT.XLIM2
C
   41 PX=P(1)
      SUM=(X-.5)*ALOG(X)-X
      DO 42 I=2,5
      PX=PX*RXX+P(I)
   42 CONTINUE
      GAMLN=PX*RX+SUM+RTWPIL
      RETURN
C
C     TABLE LOOK UP FOR INTEGER ARGUMENTS LESS THAN OR EQUAL 100.
C
   51 IF(NDX.GT.100) GO TO 40
      GAMLN=GLN(NDX)
      RETURN
 90   CALL XERROR('GAMLN  ARGUMENT IS LESS THAN OR EQUAL TO ZERO ',
     146,1,2)
      RETURN
      END