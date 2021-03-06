      SUBROUTINE FCMN(NDATA,XDATA,YDATA,SDDATA,NORD,NBKPT,BKPTIN,
     1   NCONST,XCONST,YCONST,NDERIV,MODE,COEFF,BF,XTEMP,PTEMP,BKPT,G,
     2   MDG,W,MDW,WORK,IWORK)
C***BEGIN PROLOGUE  FCMN
C***REFER TO  FC
C
C     This is a companion subprogram to FC( ).
C     The documentation for FC( ) has more complete
C     usage instructions.
C
C     Revised Dec. 14, 1979.
C     Minor revisions for FXMATH -- January 25, 1980
C***REVISION HISTORY  (YYMMDD)
C   000330  Modified array declarations.  (JEC)
C
C***ROUTINES CALLED  BNDACC,BNDSOL,BSPLVD,BSPLVN,LSEI,SAXPY,SCOPY,SSCAL,
C                    SSORT,XERROR,XERRWV
C***END PROLOGUE  FCMN
      DIMENSION XDATA(NDATA), YDATA(NDATA), SDDATA(NDATA)
      DIMENSION BKPTIN(NBKPT), XCONST(NCONST), YCONST(NCONST)
      DIMENSION NDERIV(NCONST)
      DIMENSION COEFF(*), WORK(*), IWORK(*), BF(NORD,NORD)
      DIMENSION XTEMP(*), PTEMP(*), BKPT(NBKPT)
      DIMENSION G(MDG,*), W(MDW,*)
      DIMENSION PRGOPT(10)
      LOGICAL BAND, NEW, VAR
C***FIRST EXECUTABLE STATEMENT  FCMN
      ASSIGN 10 TO I99998
      GO TO 110
C
C     INITIALIZE-VARIABLES-AND-ANALYZE-INPUT
   10 IF (.NOT.(NEW)) GO TO 30
      ASSIGN 20 TO I99994
      GO TO 340
   20 CONTINUE
C
C     IF(NEW)PROCESS-LEAST-SQUARES-EQUATIONS
   30 IF (.NOT.(BAND)) GO TO 40
      CALL BNDSOL(1, G, MDG, NORD, IP, IR, COEFF, N, RNORM)
      GO TO 100
C
C     CHECK FURTHER FOR SUFFICIENT STORAGE IN WORKING ARRAYS.
   40 IF (.NOT.(IW1.LT.LW)) GO TO 50
      CALL XERRWV( 'FC( ), INSUFF. STORAGE FOR W(*).  CHECK LW=... .',
     1 48, 2, 1, 1, LW, 0, 0, DUMMY, DUMMY)
      MODE = -1
      RETURN
   50 IF (.NOT.(IW2.LT.INTW1)) GO TO 60
      CALL XERRWV( 'FC( ), INSUFF. STORAGE FOR IW(*).  CHECK IW1=... .',
     1 50, 2, 1, 1, INTW1, 0, 0, DUMMY, DUMMY)
      MODE = -1
      RETURN
   60 ASSIGN 70 TO I99987
      GO TO 480
C
C     WRITE-EQUALITY-CONSTRAINTS
   70 ASSIGN 80 TO I99984
      GO TO 600
C
C     TRANSFER-LEAST-SQUARES-DATA
   80 ASSIGN 90 TO I99981
      GO TO 620
C
C     WRITE-INEQUALITY-CONSTRAINTS
   90 CALL LSEI(W, MDW, NEQCON, NP1, NINCON, N, PRGOPT, COEFF, RNORME,
     1 RNORML, MODE, WORK, IWORK)
  100 RETURN
  110 CONTINUE
C
C     TO INITIALIZE-VARIABLES-AND-ANALYZE-INPUT
      IF (1.LE.NORD .AND. NORD.LE.20) GO TO 120
      CALL XERROR( 'FC( ), THE ORDER OF THE B-SPLINE MUST BE 1 THRU 20.'
     1, 51, 2, 1)
      MODE = -1
      RETURN
  120 IF (.NOT.(NBKPT.LT.2*NORD)) GO TO 130
      CALL XERROR( 'FC( ), NUMBER OF KNOTS MUST BE AT LEAST TWICE THE B-
     1SPLINE ORDER.', 65, 2, 1)
      MODE = -1
      RETURN
C
C     SORT THE BREAKPOINTS.
  130 CALL SCOPY(NBKPT, BKPTIN, 1, BKPT, 1)
      CALL SSORT(BKPT, DUMMY, NBKPT, 1)
C
      IF (.NOT.(NDATA.LT.0)) GO TO 140
      CALL XERROR( 'FC( ), THE NUMBER OF DATA POINTS MUST BE NONNEGATIVE
     1.', 53, 2,  1)
      MODE = -1
      RETURN
C
C     SEE IF SUFF. STORAGE HAS BEEN ALLOCATED.
  140 NEQCON = 0
      NINCON = 0
      IF (.NOT.(NCONST.GT.0)) GO TO 210
      DO 200 I=1,NCONST
        L = NDERIV(I)
        ITYPE = L - 4*(L/4)
        IF ((0).NE.(ITYPE)) GO TO 150
        NINCON = NINCON + 1
        GO TO 190
  150   IF ((1).NE.(ITYPE)) GO TO 160
        NINCON = NINCON + 1
        GO TO 190
  160   IF ((2).NE.(ITYPE)) GO TO 170
        NEQCON = NEQCON + 1
        GO TO 190
  170   IF ((3).NE.(ITYPE)) GO TO 180
        NEQCON = NEQCON + 1
  180   CONTINUE
  190   CONTINUE
  200 CONTINUE
C
C     AMOUNT OF STORAGE ALLOCATED FOR W(*),IW(*).
  210 IW1 = IWORK(1)
      IW2 = IWORK(2)
      NB = (NBKPT-NORD+3)*(NORD+1) + 2*MAX0(NDATA,NBKPT) + NBKPT +
     1 NORD**2
      IF (.NOT.(IW1.LT.NB)) GO TO 220
      CALL XERRWV( 'FC( ), INSUFF. STORAGE FOR W(*).  CHECK NB=... .',
     1 48, 2, 1, 1, NB, 0, 0, DUMMY, DUMMY)
      MODE = -1
      RETURN
  220 L = NBKPT - NORD + 1
C
C     COMPUTE THE NUMBER OF VARIABLES.
      N = NBKPT - NORD
      NP1 = L
      LW = NB + (L+NCONST)*L + 2*(NEQCON+L) + (NINCON+L) +
     1 (NINCON+2)*(L+6)
      INTW1 = NINCON + 2*L
      XMIN = BKPT(NORD)
C
C     INDEX OF RIGHT-MOST INTERVAL-DEFINING KNOT.
      LAST = L
      XMAX = BKPT(LAST)
C
C     FIND THE SMALLEST REFERENCED INDEPENDENT
C     VARIABLE VALUE IN ANY CONSTRAINT.
      IF (.NOT.(NCONST.GT.0)) GO TO 240
      DO 230 I=1,NCONST
        XMIN = AMIN1(XMIN,XCONST(I))
        XMAX = AMAX1(XMAX,XCONST(I))
  230 CONTINUE
  240 NORDM1 = NORD - 1
      NORDP1 = NORD + 1
C
      ZERO = 0.E0
      ONE = 1.E0
      NEQCON = 0
      NINCON = 0
      IF ((1).NE.(MODE)) GO TO 250
      BAND = .TRUE.
      VAR = .FALSE.
      NEW = .TRUE.
      GO TO 290
  250 IF ((2).NE.(MODE)) GO TO 260
      BAND = .FALSE.
      VAR = .TRUE.
      NEW = .TRUE.
      GO TO 290
  260 IF ((3).NE.(MODE)) GO TO 270
      BAND = .TRUE.
      VAR = .FALSE.
      NEW = .FALSE.
      GO TO 290
  270 IF ((4).NE.(MODE)) GO TO 280
      BAND = .FALSE.
      VAR = .TRUE.
      NEW = .FALSE.
      GO TO 290
  280 CALL XERROR( 'FC( ), INPUT VALUE OF MODE MUST BE 1-4.', 39, 2, 1)
      MODE = -1
      RETURN
  290 MODE = 0
C
C     DEFINE THE OPTION VECTOR FOR USE IN LSEI( ).
      PRGOPT(1) = 4
C
C     SET THE COVARIANCE MATRIX COMPUTATION FLAG.
      PRGOPT(2) = 1
      IF (.NOT.(VAR)) GO TO 300
      PRGOPT(3) = 1
      GO TO 310
  300 PRGOPT(3) = 0
C
C     INCREASE THE RANK DETERMINATION TOLERANCES
C     FOR BOTH EQUALITY CONSTRAINT EQUATIONS AND
C     LEAST SQUARES EQUATIONS.
  310 PRGOPT(4) = 7
      PRGOPT(5) = 4
      PRGOPT(6) = 1.E-4
C
      PRGOPT(7) = 10
      PRGOPT(8) = 5
      PRGOPT(9) = 1.E-4
C
      PRGOPT(10) = 1
C     TURN OFF WORK ARRAY LENGTH CHECKING IN LSEI( ).
      IWORK(1)=0
      IWORK(2)=0
      BAND = BAND .AND. NCONST.EQ.0
      IF (.NOT.(.NOT.NEW)) GO TO 330
      DO 320 I=1,N
        BAND = BAND .AND. G(I,1).NE.ZERO
  320 CONTINUE
  330 GO TO 720
  340 CONTINUE
C
C     TO PROCESS-LEAST-SQUARES-EQUATIONS
C     SORT DATA AND AN ARRAY OF POINTERS.
      CALL SCOPY(NDATA, XDATA, 1, XTEMP, 1)
      I = 1
  350 IF (.NOT.(I.LE.NDATA)) GO TO 360
      PTEMP(I) = I
      I = I + 1
      GO TO 350
  360 IF (.NOT.(NDATA.GT.0)) GO TO 370
      CALL SSORT(XTEMP, PTEMP, NDATA, 2)
      XMIN = AMIN1(XMIN,XTEMP(1))
      XMAX = AMAX1(XMAX,XTEMP(NDATA))
C
C     FIX BREAKPOINT ARRAY IF NEEDED.
  370 DO 380 I=1,NORD
        BKPT(I) = AMIN1(BKPT(I),XMIN)
  380 CONTINUE
      DO 390 I=LAST,NBKPT
        BKPT(I) = AMAX1(BKPT(I),XMAX)
  390 CONTINUE
C
C     INITIALIZE PARAMETERS OF BANDED MATRIX PROCESSOR, BNDACC( ).
      MT = 0
      IP = 1
      IR = 1
      IDATA = 1
      ILEFT = NORD
  400 IF (.NOT.(IDATA.LE.NDATA)) GO TO 460
C
C     SORTED INDICES ARE IN PTEMP(*).
      L = PTEMP(IDATA)
      XVAL = XDATA(L)
C
C     WHEN INTERVAL CHANGES, PROCESS EQUATIONS IN THE LAST BLOCK.
      IF (.NOT.(XVAL.GE.BKPT(ILEFT+1))) GO TO 430
      INTRVL = ILEFT - NORDM1
      CALL BNDACC(G, MDG, NORD, IP, IR, MT, INTRVL)
      MT = 0
C
C     MOVE POINTER UP TO HAVE BKPT(ILEFT).LE.XVAL, ILEFT.LT.LAST.
  410 IF (.NOT.(XVAL.GE.BKPT(ILEFT+1) .AND. ILEFT.LT.LAST-1)) GO TO 420
      ILEFT = ILEFT + 1
      GO TO 410
  420 CONTINUE
C
C     OBTAIN B-SPLINE FUNCTION VALUE.
  430 CALL BSPLVN(BKPT, NORD, 1, XVAL, ILEFT, BF)
C
C     MOVE ROW INTO PLACE.
      IROW = IR + MT
      MT = MT + 1
      CALL SCOPY(NORD, BF, 1, G(IROW,1), MDG)
      G(IROW,NORDP1) = YDATA(L)
C
C     SCALE DATA IF UNCERTAINTY IS NONZERO.
      IF (.NOT.(SDDATA(L).NE.ZERO)) GO TO 440
      CALL SSCAL(NORDP1, ONE/SDDATA(L), G(IROW,1), MDG)
C
C     WHEN STAGING WORK AREA IS EXHAUSTED, PROCESS ROWS.
  440 IF (.NOT.(IROW.EQ.MDG-1)) GO TO 450
      INTRVL = ILEFT - NORDM1
      CALL BNDACC(G, MDG, NORD, IP, IR, MT, INTRVL)
      MT = 0
  450 IDATA = IDATA + 1
      GO TO 400
C
C     PROCESS LAST BLOCK OF EQUATIONS.
  460 INTRVL = ILEFT - NORDM1
      CALL BNDACC(G, MDG, NORD, IP, IR, MT, INTRVL)
C
C     LAST CALL TO ADJUST BLOCK POSITIONING.
      G(IR,1) = ZERO
      CALL SCOPY(NORDP1, G(IR,1), 0, G(IR,1), MDG)
      CALL BNDACC(G, MDG, NORD, IP, IR, 1, NP1)
      DO 470 I=1,N
        BAND = BAND .AND. G(I,1).NE.ZERO
  470 CONTINUE
      GO TO 730
  480 CONTINUE
C
C     TO WRITE-EQUALITY-CONSTRAINTS
      IDATA = 1
  490 IF (.NOT.(IDATA.LE.NCONST)) GO TO 590
C
C     ANALYZE CONSTRAINT INDICATORS FOR AN EQUALITY CONSTRAINT.
      L = NDERIV(IDATA)
      IDERIV = L/4
      ITYPE = L - 4*IDERIV
      IF ((2).NE.(ITYPE)) GO TO 520
      NEQCON = NEQCON + 1
      ILEFT = NORD
      XVAL = XCONST(IDATA)
  500 IF (.NOT.(XVAL.GE.BKPT(ILEFT+1) .AND. ILEFT.LT.LAST-1)) GO TO 510
      ILEFT = ILEFT + 1
      GO TO 500
  510 CALL BSPLVD(BKPT, NORD, XVAL, ILEFT, BF, IDERIV+1)
      W(NEQCON,1) = ZERO
      CALL SCOPY(N, W(NEQCON,1), 0, W(NEQCON,1), MDW)
      INTRVL = ILEFT - NORDM1
      CALL SCOPY(NORD, BF(1,IDERIV+1), 1, W(NEQCON,INTRVL), MDW)
      W(NEQCON,NP1) = YCONST(IDATA)
      GO TO 580
  520 IF ((3).NE.(ITYPE)) GO TO 570
      NEQCON = NEQCON + 1
      ILEFT = NORD
      XVAL = XCONST(IDATA)
  530 IF (.NOT.(XVAL.GE.BKPT(ILEFT+1) .AND. ILEFT.LT.LAST-1)) GO TO 540
      ILEFT = ILEFT + 1
      GO TO 530
  540 CALL BSPLVD(BKPT, NORD, XVAL, ILEFT, BF, IDERIV+1)
      W(NEQCON,1) = ZERO
      CALL SCOPY(NP1, W(NEQCON,1), 0, W(NEQCON,1), MDW)
      INTRVL = ILEFT - NORDM1
      CALL SCOPY(NORD, BF(1,IDERIV+1), 1, W(NEQCON,INTRVL), MDW)
      ILEFT = NORD
      YVAL = YCONST(IDATA)
  550 IF (.NOT.(YVAL.GE.BKPT(ILEFT+1) .AND. ILEFT.LT.LAST-1)) GO TO 560
      ILEFT = ILEFT + 1
      GO TO 550
  560 CALL BSPLVD(BKPT, NORD, YVAL, ILEFT, BF, IDERIV+1)
      INTRVL = ILEFT - NORDM1
      CALL SAXPY(NORD, -ONE, BF(1,IDERIV+1), 1, W(NEQCON,INTRVL), MDW)
  570 CONTINUE
  580 IDATA = IDATA + 1
      GO TO 490
  590 GO TO 750
  600 CONTINUE
C
C     TO TRANSFER-LEAST-SQUARES-DATA
      DO 610 I=1,NP1
        IROW = I + NEQCON
        W(IROW,1) = ZERO
        CALL SCOPY(N, W(IROW,1), 0, W(IROW,1), MDW)
        CALL SCOPY(MIN0(NP1-I,NORD), G(I,1), MDG, W(IROW,I), MDW)
        W(IROW,NP1) = G(I,NORDP1)
  610 CONTINUE
      GO TO 740
  620 CONTINUE
C
C     TO WRITE-INEQUALITY-CONSTRAINTS
      IDATA = 1
  630 IF (.NOT.(IDATA.LE.NCONST)) GO TO 710
C
C     ANALYZE CONSTRAINT INDICATORS FOR INEQUALITY CONSTRAINTS.
      L = NDERIV(IDATA)
      IDERIV = L/4
      ITYPE = L - 4*IDERIV
      IF ((1).NE.(ITYPE)) GO TO 660
      NINCON = NINCON + 1
      ILEFT = NORD
      XVAL = XCONST(IDATA)
  640 IF (.NOT.(XVAL.GE.BKPT(ILEFT+1) .AND. ILEFT.LT.LAST-1)) GO TO 650
      ILEFT = ILEFT + 1
      GO TO 640
  650 CALL BSPLVD(BKPT, NORD, XVAL, ILEFT, BF, IDERIV+1)
      IROW = NEQCON + NP1 + NINCON
      W(IROW,1) = ZERO
      CALL SCOPY(N, W(IROW,1), 0, W(IROW,1), MDW)
      INTRVL = ILEFT - NORDM1
      CALL SCOPY(NORD, BF(1,IDERIV+1), 1, W(IROW,INTRVL), MDW)
      W(IROW,NP1) = YCONST(IDATA)
      GO TO 700
  660 IF ((0).NE.(ITYPE)) GO TO 690
      NINCON = NINCON + 1
      ILEFT = NORD
      XVAL = XCONST(IDATA)
  670 IF (.NOT.(XVAL.GE.BKPT(ILEFT+1) .AND. ILEFT.LT.LAST-1)) GO TO 680
      ILEFT = ILEFT + 1
      GO TO 670
  680 CALL BSPLVD(BKPT, NORD, XVAL, ILEFT, BF, IDERIV+1)
      IROW = NEQCON + NP1 + NINCON
      W(IROW,1) = ZERO
      CALL SCOPY(N, W(IROW,1), 0, W(IROW,1), MDW)
      INTRVL = ILEFT - NORDM1
      CALL SCOPY(NORD, BF(1,IDERIV+1), 1, W(IROW,INTRVL), MDW)
      W(IROW,NP1) = -YCONST(IDATA)
      CALL SSCAL(NORD, -ONE, W(IROW,INTRVL), MDW)
  690 CONTINUE
  700 IDATA = IDATA + 1
      GO TO 630
  710 GO TO 760
  720 GO TO I99998, (10)
  730 GO TO I99994, (20)
  740 GO TO I99984, (80)
  750 GO TO I99987, (70)
  760 GO TO I99981, (90)
      END
