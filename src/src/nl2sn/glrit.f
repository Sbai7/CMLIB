      SUBROUTINE GLRIT(D, G, IV, LIV, LV, P, PS, V, X, Y)
C
C  ***  CARRY OUT NL2SOL-LIKE ITERATIONS FOR GENERALIZED LINEAR   ***
C  ***  REGRESSION PROBLEMS (AND OTHERS OF SIMILAR STRUCTURE)     ***
C
C  ***  PARAMETER DECLARATIONS  ***
C
      INTEGER LIV, LV, P, PS
      INTEGER IV(LIV)
      REAL D(P), G(P), V(LV), X(P), Y(P)
C
C--------------------------  PARAMETER USAGE  --------------------------
C
C D.... SCALE VECTOR.
C IV... INTEGER VALUE ARRAY.
C LIV.. LENGTH OF IV.  MUST BE AT LEAST 80.
C LH... LENGTH OF H = P*(P+1)/2.
C LV... LENGTH OF V.  MUST BE AT LEAST P*(3*P + 19)/2 + 7.
C G.... GRADIENT AT X (WHEN IV(1) = 2).
C HC... GAUSS-NEWTON HESSIAN AT X (WHEN IV(1) = 2).
C P.... NUMBER OF PARAMETERS (COMPONENTS IN X).
C PS... NUMBER OF NONZERO ROWS AND COLUMNS IN S.
C V.... FLOATING-POINT VALUE ARRAY.
C X.... PARAMETER VECTOR.
C Y.... PART OF YIELD VECTOR (WHEN IV(1)= 2, SCRATCH OTHERWISE).
C
C  ***  DISCUSSION  ***
C
C        GLRIT PERFORMS NL2SOL-LIKE ITERATIONS FOR A VARIETY OF
C     REGRESSION PROBLEMS THAT ARE SIMILAR TO NONLINEAR LEAST-SQUARES
C     IN THAT THE HESSIAN IS THE SUM OF TWO TERMS, A READILY-COMPUTED
C     FIRST-ORDER TERM AND A SECOND-ORDER TERM.  THE CALLER SUPPLIES
C     THE FIRST-ORDER TERM OF THE HESSIAN IN HC (LOWER TRIANGLE, STORED
C     COMPACTLY BY ROWS), AND GLRIT BUILDS AN APPROXIMATION, S, TO THE
C     SECOND-ORDER TERM.  THE CALLER ALSO PROVIDES THE FUNCTION VALUE,
C     GRADIENT, AND PART OF THE YIELD VECTOR USED IN UPDATING S.  GLRIT
C     DECIDES DYNAMICALLY WHETHER OR NOT TO USE S WHEN CHOOSING THE
C     NEXT STEP TO TRY...  THE HESSIAN APPROXIMATION USED IS EITHER HC
C     ALONE (GAUSS-NEWTON MODEL) OR HC + S (AUGMENTED MODEL).
C     IF PS .LT. P, THEN ROWS AND COLUMNS PS+1...P OF S ARE KEPT
C     CONSTANT.  THEY WILL BE ZERO UNLESS THE CALLER SETS IV(INITS) TO
C     1 OR 2 AND SUPPLIES NONZERO VALUES FOR THEM.
C
C        FOR UPDATING S, GLRIT ASSUMES THAT THE GRADIENT HAS THE FORM
C     OF A SUM OVER I OF RHO(I,X)*GRAD(R(I,X)), WHERE GRAD DENOTES THE
C     GRADIENT WITH RESPECT TO X.  THE TRUE SECOND-ORDER TERM THEN IS
C     THE SUM OVER I OF RHO(I,X)*HESSIAN(R(I,X)).  IF X = X0 + STEP,
C     THEN WE WISH TO UPDATE S SO THAT S*STEP IS THE SUM OVER I OF
C     RHO(I,X)*(GRAD(R(I,X)) - GRAD(R(I,X0))).  THE CALLER MUST SUPPLY
C     PART OF THIS IN Y, NAMELY THE SUM OVER I OF
C     RHO(I,X)*GRAD(R(I,X0)), WHEN CALLING GLRIT WITH IV(1) = 2 AND
C     IV(MODE) = 0 (WHERE MODE = 38).  G THEN CONTANS THE OTHER PART,
C     SO THAT THE DESIRED YIELD VECTOR IS G - Y.  IF PS .LT. P, THEN
C     THE ABOVE DISCUSSION APPLIES ONLY TO THE FIRST PS COMPONENTS OF
C     GRAD(R(I,X)), STEP, AND Y.
C
C        PARAMETERS IV, P, V, AND X ARE THE SAME AS THE CORRESPONDING
C     ONES TO NL2SOL (WHICH SEE), EXCEPT THAT V CAN BE SHORTER
C     (SINCE THE PART OF V THAT NL2SOL USES FOR STORING D, J, AND R IS
C     NOT NEEDED).  MOREOVER, COMPARED WITH NL2SOL, IV(1) MAY HAVE THE
C     TWO ADDITIONAL OUTPUT VALUES 1 AND 2, WHICH ARE EXPLAINED BELOW,
C     AS IS THE USE OF IV(TOOBIG) AND IV(NFGCAL).  THE VALUES IV(D),
C     IV(J), AND IV(R), WHICH ARE OUTPUT VALUES FROM NL2SOL (AND
C     NL2SNO), ARE NOT REFERENCED BY GLRIT OR THE SUBROUTINES IT CALLS.
C
C        WHEN GLRIT IS FIRST CALLED, I.E., WHEN GLRIT IS CALLED WITH
C     IV(1) = 0 OR 12, V(F), G, AND HC NEED NOT BE INITIALIZED.  TO
C     OBTAIN THESE STARTING VALUES, GLRIT RETURNS FIRST WITH IV(1) = 1,
C     THEN WITH IV(1) = 2, WITH IV(MODE) = -1 IN BOTH CASES.  ON
C     SUBSEQUENT RETURNS WITH IV(1) = 2, IV(MODE) = 0 IMPLIES THAT
C     Y MUST ALSO BE SUPPLIED.  (NOTE THAT Y IS USED FOR SCRATCH -- ITS
C     INPUT CONTENTS ARE LOST.  BY CONTRAST, HC IS NEVER CHANGED.)
C     ONCE CONVERGENCE HAS BEEN OBTAINED, IV(COVREQ) AND IV(COVPRT) MAY
C     IMPLY THAT A FINITE-DIFFERENCE HESSIAN SHOULD BE COMPUTED FOR USE
C     IN COMPUTING A COVARIANCE MATRIX.  IN THIS CASE GLRIT WILL MAKE A
C     NUMBER OF RETURNS WITH IV(1) = 1 OR 2 AND IV(MODE) POSITIVE.
C     WHEN IV(MODE) IS POSITIVE, Y SHOULD NOT BE CHANGED.
C
C IV(1) = 1 MEANS THE CALLER SHOULD SET V(F) (I.E., V(10)) TO F(X), THE
C             FUNCTION VALUE AT X, AND CALL GLRIT AGAIN, HAVING CHANGED
C             NONE OF THE OTHER PARAMETERS.  AN EXCEPTION OCCURS IF F(X)
C             CANNOT BE EVALUATED (E.G. IF OVERFLOW WOULD OCCUR), WHICH
C             MAY HAPPEN BECAUSE OF AN OVERSIZED STEP.  IN THIS CASE
C             THE CALLER SHOULD SET IV(TOOBIG) = IV(2) TO 1, WHICH WILL
C             CAUSE GLRIT TO IGNORE V(F) AND TRY A SMALLER STEP.  NOTE
C             THAT THE CURRENT FUNCTION EVALUATION COUNT IS AVAILABLE
C             IN IV(NFCALL) = IV(6).  THIS MAY BE USED TO IDENTIFY
C             WHICH COPY OF SAVED INFORMATION SHOULD BE USED IN COM-
C             PUTING G, HC, AND Y THE NEXT TIME GLRIT RETURNS WITH
C             IV(1) = 2.  SEE MLPIT FOR AN EXAMPLE OF THIS.
C IV(1) = 2 MEANS THE CALLER SHOULD SET G TO G(X), THE GRADIENT OF F AT
C             X.  THE CALLER SHOULD ALSO SET HC TO THE GAUSS-NEWTON
C             HESSIAN AT X.  IF IV(MODE) = 0, THEN THE CALLER SHOULD
C             ALSO COMPUTE THE PART OF THE YIELD VECTOR DESCRIBED ABOVE.
C             THE CALLER SHOULD THEN CALL GLRIT AGAIN (WITH IV(1) = 2).
C             THE CALLER MAY ALSO CHANGE D AT THIS TIME, BUT SHOULD NOT
C             CHANGE X.  NOTE THAT IV(NFGCAL) = IV(7) CONTAINS THE
C             VALUE THAT IV(NFCALL) HAD DURING THE RETURN WITH
C             IV(1) = 1 IN WHICH X HAD THE SAME VALUE AS IT NOW HAS.
C             IV(NFGCAL) IS EITHER IV(NFCALL) OR IV(NFCALL) - 1.  MLPIT
C             IS AN EXAMPLE WHERE THIS INFORMATION IS USED.  IF G OR HC
C             CANNOT BE EVALUATED AT X, THEN THE CALLER MAY SET
C             IV(NFGCAL) TO 0, IN WHICH CASE GLRIT WILL RETURN WITH
C             IV(1) = 15.
C
C  ***  GENERAL  ***
C
C     CODED BY DAVID M. GAY.
C     THIS SUBROUTINE WAS WRITTEN IN CONNECTION WITH RESEARCH
C     SUPPORTED IN PART BY D.O.E. GRANT EX-76-A-01-2295 TO MIT/CCREMS.
C
C        (SEE NL2SOL FOR REFERENCES.)
C
C+++++++++++++++++++++++++++  DECLARATIONS  ++++++++++++++++++++++++++++
C
C  ***  LOCAL VARIABLES  ***
C
      INTEGER DUMMY, DIG1, G01, H1, HC1, I, IPIV1, J, K, L, LMAT1,
     1        LSTGST, PP1O2, QTR1, RMAT1, STEP1, STPMOD, S1, TEMP1,
     2        TEMP2, W1, X01
      REAL E, STTSST, T, T1
C
C     ***  CONSTANTS  ***
C
      REAL HALF, NEGONE, ONE, ZERO
C
C  ***  INTRINSIC FUNCTIONS  ***
C/+
      INTEGER IABS
      REAL  ABS
C/
C  ***  EXTERNAL FUNCTIONS AND SUBROUTINES  ***
C
      EXTERNAL ASSST,  FDHES, GQTST, ITSUM, LMSTEP, LSQUAR,
     1         LTVMUL, LVMUL, PARCK, SLUPDT, SLVMUL, STOPX, VAXPY,
     2          VSCOPY
      LOGICAL STOPX
C
C ASSST.... ASSESSES CANDIDATE STEP.
C FDHES.... COMPUTE FINITE-DIFFERENCE HESSIAN (FOR COVARIANCE).
C GQTST.... COMPUTES GOLDFELD-QUANDT-TROTTER STEP (AUGMENTED MODEL).
C ITSUM.... PRINTS ITERATION SUMMARY AND INFO ON INITIAL AND FINAL X.
C LMSTEP... COMPUTES LEVENBERG-MARQUARDT STEP (GAUSS-NEWTON MODEL).
C LSQUAR... COMPUTES L * L**T FROM LOWER TRIANGULAR MATRIX L.
C LTVMUL... COMPUTES L**T * V, V = VECTOR, L = LOWER TRIANGULAR MATRIX.
C LVMUL.... COMPUTES L * V, V = VECTOR, L = LOWER TRIANGULAR MATRIX.
C PARCK.... CHECK VALIDITY OF IV AND V INPUT COMPONENTS.
C SLUPDT... PERFORMS QUASI-NEWTON UPDATE ON COMPACTLY STORED LOWER TRI-
C             ANGLE OF A SYMMETRIC MATRIX.
C STOPX.... RETURNS .TRUE. IF THE BREAK KEY HAS BEEN PRESSED.
C VAXPY.... COMPUTES SCALAR TIMES ONE VECTOR PLUS ANOTHER.
C VSCOPY... SETS ALL ELEMENTS OF A VECTOR TO A SCALAR.
C
C  ***  SUBSCRIPTS FOR IV AND V  ***
C
      INTEGER CNVCOD, COSMIN, COVMAT, COVPRT, COVREQ, DGNORM, DIG,
     1        DSTNRM, F, FDH, FDIF, FUZZ, F0, GTSTEP, H, HC, IERR,
     2        INCFAC, INITS, IPIVOT, IRC, KAGQT, KALM, LMAT, LMAX0,
     3        LMAXS, MODE, MODEL, MXFCAL, MXITER, NEXTV, NFCALL, NFGCAL,
     4        NFCOV, NGCOV, NGCALL, NITER, NVSAVE, PHMXFC, PREDUC, QTR,
     5        RADFAC, RADINC, RADIUS, RAD0, RDREQ, REGD, RMAT, S, SIZE,
     6        STEP, STGLIM, STLSTG, STPPAR, SUSED, SWITCH, TOOBIG,
     7        TUNER4, TUNER5, VNEED, VSAVE, W, WSCALE, XIRC, X0
C
C  ***  IV SUBSCRIPT VALUES  ***
C
C/6
C     DATA CNVCOD/55/, COVMAT/26/, COVPRT/14/, COVREQ/15/, DIG/37/,
C    1     FDH/74/, H/56/, HC/71/, IERR/75/, INITS/25/, IPIVOT/76/,
C    2     IRC/29/, KAGQT/33/, KALM/34/, LMAT/42/, MODE/35/, MODEL/5/,
C    3     MXFCAL/17/, MXITER/18/, NEXTV/47/, NFCALL/6/, NFGCAL/7/,
C    4     NFCOV/52/, NGCOV/53/, NGCALL/30/, NITER/31/, QTR/77/,
C    5     RADINC/8/, RDREQ/57/, REGD/67/, RMAT/78/, S/62/, STEP/40/,
C    6     STGLIM/11/, STLSTG/41/, SUSED/64/, SWITCH/12/, TOOBIG/2/,
C    7     VNEED/4/, VSAVE/60/, W/65/, XIRC/13/, X0/43/
C/7
      PARAMETER (CNVCOD=55, COVMAT=26, COVPRT=14, COVREQ=15, DIG=37,
     1           FDH=74, H=56, HC=71, IERR=75, INITS=25, IPIVOT=76,
     2           IRC=29, KAGQT=33, KALM=34, LMAT=42, MODE=35, MODEL=5,
     3           MXFCAL=17, MXITER=18, NEXTV=47, NFCALL=6, NFGCAL=7,
     4           NFCOV=52, NGCOV=53, NGCALL=30, NITER=31, QTR=77,
     5           RADINC=8, RDREQ=57, REGD=67, RMAT=78, S=62, STEP=40,
     6           STGLIM=11, STLSTG=41, SUSED=64, SWITCH=12, TOOBIG=2,
     7           VNEED=4, VSAVE=60, W=65, XIRC=13, X0=43)
C/
C
C  ***  V SUBSCRIPT VALUES  ***
C
C/6
C     DATA COSMIN/47/, DGNORM/1/, DSTNRM/2/, F/10/, FDIF/11/, FUZZ/45/,
C    1     F0/13/, GTSTEP/4/, INCFAC/23/, LMAX0/35/, LMAXS/36/,
C    2     NVSAVE/9/, PHMXFC/21/, PREDUC/7/, RADFAC/16/, RADIUS/8/,
C    3     RAD0/9/, SIZE/55/, STPPAR/5/, TUNER4/29/, TUNER5/30/,
C    4     WSCALE/56/
C/7
      PARAMETER (COSMIN=47, DGNORM=1, DSTNRM=2, F=10, FDIF=11, FUZZ=45,
     1           F0=13, GTSTEP=4, INCFAC=23, LMAX0=35, LMAXS=36,
     2           NVSAVE=9, PHMXFC=21, PREDUC=7, RADFAC=16, RADIUS=8,
     3           RAD0=9, SIZE=55, STPPAR=5, TUNER4=29, TUNER5=30,
     4           WSCALE=56)
C/
C
C
C/6
C     DATA HALF/0.5E+0/, NEGONE/-1.E+0/, ONE/1.E+0/, ZERO/0.E+0/
C/7
      PARAMETER (HALF=0.5E+0, NEGONE=-1.E+0, ONE=1.E+0, ZERO=0.E+0)
C/
C
C+++++++++++++++++++++++++++++++  BODY  ++++++++++++++++++++++++++++++++
C
      I = IV(1)
      IF (I .EQ. 1) GO TO 40
      IF (I .EQ. 2) GO TO 50
C
      IV(VNEED) = IV(VNEED) + P*(3*P + 19)/2 + 7
      CALL PARCK(1, D, IV, LIV, LV, P, V)
      I = IV(1) - 2
      IF (I .GT. 12) GO TO 999
      GO TO (260, 260, 260, 260, 260, 260, 140, 90, 140, 10, 10, 20), I
C
C  ***  STORAGE ALLOCATION  ***
C
 10   PP1O2 = P * (P + 1) / 2
      IV(S) = IV(LMAT) + PP1O2
      IV(X0) = IV(S) + PP1O2
      IV(STEP) = IV(X0) + P
      IV(STLSTG) = IV(STEP) + P
      IV(DIG) = IV(STLSTG) + P
      IV(W) = IV(DIG) + P
      IV(H) = IV(W) + 4*P + 7
      IV(NEXTV) = IV(H) + PP1O2
      IF (IV(1) .NE. 13) GO TO 20
         IV(1) = 14
         GO TO 999
C
C  ***  INITIALIZATION  ***
C
 20   IV(NITER) = 0
      IV(NFCALL) = 1
      IV(NGCALL) = 1
      IV(NFGCAL) = 1
      IV(MODE) = -1
      IV(STGLIM) = 2
      IV(TOOBIG) = 0
      IV(CNVCOD) = 0
      IV(COVMAT) = 0
      IV(NFCOV) = 0
      IV(NGCOV) = 0
      IV(RADINC) = 0
      V(RAD0) = ZERO
      V(STPPAR) = ZERO
      V(RADIUS) = V(LMAX0) / (ONE + V(PHMXFC))
C
C  ***  SET INITIAL MODEL AND S MATRIX  ***
C
      IV(MODEL) = 1
      IF (IV(S) .LT. 0) GO TO 999
      IF (IV(INITS) .EQ. 2) IV(MODEL) = 2
      S1 = IV(S)
      IF (IV(INITS) .EQ. 0) CALL VSCOPY(PP1O2, V(S1), ZERO)
      IV(1) = 1
      J = IV(IPIVOT)
      IF (J .LE. 0) GO TO 999
      DO 30 I = 1, P
         IV(J) = I
         J = J + 1
 30      CONTINUE
      GO TO 999
C
C  ***  NEW FUNCTION VALUE  ***
C
 40   IF (IV(MODE) .EQ. 0) GO TO 260
      IF (IV(MODE) .GT. 0) GO TO 440
C
      IV(1) = 2
      IF (IV(TOOBIG) .EQ. 0) GO TO 999
         IV(1) = 63
         GO TO 999
C
C  ***  MAKE SURE GRADIENT COULD BE COMPUTED  ***
C
 50   IF (IV(NFGCAL) .NE. 0) GO TO 60
         IV(1) = 65
         GO TO 999
C
C  ***  NEW GRADIENT  ***
C
 60   IV(KALM) = -1
      IV(KAGQT) = -1
      IF (IV(MODE) .GT. 0) GO TO 440
      IF (IV(HC) .LE. 0 .AND. IV(RMAT) .LE. 0) GO TO 500
C
C  ***  COMPUTE  D**-1 * GRADIENT  ***
C
      DIG1 = IV(DIG)
      K = DIG1
      DO 70 I = 1, P
         V(K) = G(I) / D(I)
         K = K + 1
 70      CONTINUE
      V(DGNORM) = SNRM2(P,V(DIG1),1)
C
      IF (IV(CNVCOD) .NE. 0) GO TO 430
      IF (IV(MODE) .EQ. 0) GO TO 360
      IV(1) = 2
      IV(MODE) = 0
C
C
C-----------------------------  MAIN LOOP  -----------------------------
C
C
C  ***  PRINT ITERATION SUMMARY, CHECK ITERATION LIMIT  ***
C
 80   CALL ITSUM(D, G, IV, LIV, LV, P, V, X)
 90   K = IV(NITER)
      IF (K .LT. IV(MXITER)) GO TO 100
         IV(1) = 10
         GO TO 999
 100  IV(NITER) = K + 1
C
C  ***  UPDATE RADIUS  ***
C
      IF (K .EQ. 0) GO TO 120
      STEP1 = IV(STEP)
      DO 110 I = 1, P
         V(STEP1) = D(I) * V(STEP1)
         STEP1 = STEP1 + 1
 110     CONTINUE
      STEP1 = IV(STEP)
      V(RADIUS) = V(RADFAC) * SNRM2(P,V(STEP1),1)
C
C  ***  INITIALIZE FOR START OF NEXT ITERATION  ***
C
 120  X01 = IV(X0)
      V(F0) = V(F)
      IV(IRC) = 4
      IV(H) = -IABS(IV(H))
      IV(SUSED) = IV(MODEL)
C
C     ***  COPY X TO X0  ***
C
      CALL SCOPY(P,X,1,V(X01),1)
C
C  ***  CHECK STOPX AND FUNCTION EVALUATION LIMIT  ***
C
 130  IF (.NOT. STOPX(DUMMY)) GO TO 150
         IV(1) = 11
         GO TO 160
C
C     ***  COME HERE WHEN RESTARTING AFTER FUNC. EVAL. LIMIT OR STOPX.
C
 140  IF (V(F) .GE. V(F0)) GO TO 150
         V(RADFAC) = ONE
         K = IV(NITER)
         GO TO 100
C
 150  IF (IV(NFCALL) .LT. IV(MXFCAL) + IV(NFCOV)) GO TO 170
         IV(1) = 9
 160     IF (V(F) .GE. V(F0)) GO TO 999
C
C        ***  IN CASE OF STOPX OR FUNCTION EVALUATION LIMIT WITH
C        ***  IMPROVED V(F), EVALUATE THE GRADIENT AT X.
C
              IV(CNVCOD) = IV(1)
              GO TO 350
C
C. . . . . . . . . . . . .  COMPUTE CANDIDATE STEP  . . . . . . . . . .
C
 170  STEP1 = IV(STEP)
      W1 = IV(W)
      H1 = IV(H)
      T1 = ONE
      IF (IV(MODEL) .EQ. 2) GO TO 200
         T1 = ZERO
C
C        ***  COMPUTE LEVENBERG-MARQUARDT STEP IF POSSIBLE...
C
         RMAT1 = IV(RMAT)
         IF (RMAT1 .LE. 0) GO TO 200
         QTR1 = IV(QTR)
         IF (QTR1 .LE. 0) GO TO 200
         IPIV1 = IV(IPIVOT)
         CALL LMSTEP(D, G, IV(IERR), IV(IPIV1), IV(KALM), P, V(QTR1),
     1               V(RMAT1),V(STEP1), V, V(W1))
C        *** H IS STORED IN THE END OF W AND HAS JUST BEEN OVERWRITTEN,
C        *** SO WE MARK IT INVALID...
         IV(H) = -IABS(H1)
C        *** EVEN IF H WERE STORED ELSEWHERE, IT WOULD BE NECESSARY TO
C        *** MARK INVALID THE INFORMATION GQTST MAY HAVE STORED IN V...
         IV(KAGQT) = -1
         GO TO 250
C
 200  IF (H1 .GT. 0) GO TO 240
C
C     ***  SET H TO  D**-1 * (HC + T1*S) * D**-1.  ***
C
         H1 = -H1
         IV(H) = H1
         IV(FDH) = 0
         J = IV(HC)
         IF (J .GT. 0) GO TO 210
            J = H1
            RMAT1 = IV(RMAT)
            CALL LSQUAR(P, V(H1), V(RMAT1))
 210     S1 = IV(S)
         DO 230 I = 1, P
              T = ONE / D(I)
              DO 220 K = 1, I
                   V(H1) = T * (V(J) + T1*V(S1)) / D(K)
                   J = J + 1
                   H1 = H1 + 1
                   S1 = S1 + 1
 220               CONTINUE
 230          CONTINUE
         H1 = IV(H)
         IV(KAGQT) = -1
C
C  ***  COMPUTE ACTUAL GOLDFELD-QUANDT-TROTTER STEP  ***
C
 240  DIG1 = IV(DIG)
      LMAT1 = IV(LMAT)
      CALL GQTST(D, V(DIG1), V(H1), IV(KAGQT), V(LMAT1), P, V(STEP1),
     1            V, V(W1))
      IF (IV(KALM) .GT. 0) IV(KALM) = 0
C
C
C  ***  COMPUTE F(X0 + STEP)  ***
C
 250  IF (IV(IRC) .EQ. 6) GO TO 260
      X01 = IV(X0)
      STEP1 = IV(STEP)
      CALL VAXPY(P, X, ONE, V(STEP1), V(X01))
      IV(NFCALL) = IV(NFCALL) + 1
      IV(1) = 1
      IV(TOOBIG) = 0
      GO TO 999
C
C. . . . . . . . . . . . .  ASSESS CANDIDATE STEP  . . . . . . . . . . .
C
 260  STEP1 = IV(STEP)
      LSTGST = IV(STLSTG)
      X01 = IV(X0)
      CALL ASSST(D, IV, P, V(STEP1), V(LSTGST), V, X, V(X01))
C
C  ***  IF NECESSARY, SWITCH MODELS AND/OR RESTORE R  ***
C
      IF (IV(SWITCH) .EQ. 0) GO TO 270
         IV(H) = -IABS(IV(H))
         IV(SUSED) = IV(SUSED) + 2
         L = IV(VSAVE)
         CALL SCOPY(NVSAVE,V(L),1,V,1)
 270  L = IV(IRC) - 4
      STPMOD = IV(MODEL)
      IF (L .GT. 0) GO TO (290,300,310,310,310,310,310,310,420,360), L
C
C  ***  DECIDE WHETHER TO CHANGE MODELS  ***
C
      E = V(PREDUC) - V(FDIF)
      S1 = IV(S)
      CALL SLVMUL(P, Y, V(S1), V(STEP1))
      STTSST = HALF * SDOT(P, V(STEP1),1,Y,1)
      IF (IV(MODEL) .EQ. 1) STTSST = -STTSST
      IF ( ABS(E + STTSST) * V(FUZZ) .GE.  ABS(E)) GO TO 280
C
C     ***  SWITCH MODELS  ***
C
         IV(MODEL) = 3 - IV(MODEL)
         IF (-2 .LT. L) GO TO 320
              IV(H) = -IABS(IV(H))
              IV(SUSED) = IV(SUSED) + 2
              L = IV(VSAVE)
              CALL SCOPY(NVSAVE,V,1,V(L),1)
              GO TO 130
C
 280  IF (-3 .LT. L) GO TO 320
C
C     ***  RECOMPUTE STEP WITH DECREASED RADIUS  ***
C
         V(RADIUS) = V(RADFAC) * V(DSTNRM)
         GO TO 130
C
C  ***  RECOMPUTE STEP, SAVING V VALUES AND R IF NECESSARY  ***
C
 290  V(RADIUS) = V(RADFAC) * V(DSTNRM)
      GO TO 130
C
C  ***  COMPUTE STEP OF LENGTH V(LMAXS) FOR SINGULAR CONVERGENCE TEST
C
 300  V(RADIUS) = V(LMAXS)
      GO TO 170
C
C  ***  CONVERGENCE OR FALSE CONVERGENCE  ***
C
 310  IV(CNVCOD) = L
      IF (V(F) .GE. V(F0)) GO TO 430
         IF (IV(XIRC) .EQ. 14) GO TO 430
              IV(XIRC) = 14
C
C. . . . . . . . . . . .  PROCESS ACCEPTABLE STEP  . . . . . . . . . . .
C
 320  IV(COVMAT) = 0
      IV(REGD) = 0
C
C  ***  SEE WHETHER TO SET V(RADFAC) BY GRADIENT TESTS  ***
C
      IF (IV(IRC) .NE. 3) GO TO 350
         STEP1 = IV(STEP)
         TEMP1 = IV(STLSTG)
         TEMP2 = IV(X0)
C
C     ***  SET  TEMP1 = HESSIAN * STEP  FOR USE IN GRADIENT TESTS  ***
C
         HC1 = IV(HC)
         IF (HC1 .LE. 0) GO TO 330
              CALL SLVMUL(P, V(TEMP1), V(HC1), V(STEP1))
              GO TO 340
 330     RMAT1 = IV(RMAT)
         CALL LTVMUL(P, V(TEMP1), V(RMAT1), V(STEP1))
         CALL LVMUL(P, V(TEMP1), V(RMAT1), V(TEMP1))
C
 340     IF (STPMOD .EQ. 1) GO TO 350
              S1 = IV(S)
              CALL SLVMUL(P, V(TEMP2), V(S1), V(STEP1))
              CALL VAXPY(P, V(TEMP1), ONE, V(TEMP2), V(TEMP1))
C
C  ***  SAVE OLD GRADIENT AND COMPUTE NEW ONE  ***
C
 350  IV(NGCALL) = IV(NGCALL) + 1
      G01 = IV(W)
      CALL SCOPY(P,G,1,V(G01),1)
      IV(1) = 2
      GO TO 999
C
C  ***  INITIALIZATIONS -- G0 = G - G0, ETC.  ***
C
 360  G01 = IV(W)
      CALL VAXPY(P, V(G01), NEGONE, V(G01), G)
      STEP1 = IV(STEP)
      TEMP1 = IV(STLSTG)
      TEMP2 = IV(X0)
      IF (IV(IRC) .NE. 3) GO TO 390
C
C  ***  SET V(RADFAC) BY GRADIENT TESTS  ***
C
C     ***  SET  TEMP1 = D**-1 * (HESSIAN * STEP  +  (G(X0) - G(X)))  ***
C
         K = TEMP1
         L = G01
         DO 370 I = 1, P
              V(K) = (V(K) - V(L)) / D(I)
              K = K + 1
              L = L + 1
 370          CONTINUE
C
C        ***  DO GRADIENT TESTS  ***
C
         IF (SNRM2(P,V(TEMP1),1) .LE. V(DGNORM) * V(TUNER4))  GO TO 380
              IF (SDOT(P, G,1, V(STEP1),1)
     1                  .GE. V(GTSTEP) * V(TUNER5))  GO TO 390
 380               V(RADFAC) = V(INCFAC)
C
C  ***  COMPUTE Y VECTOR NEEDED FOR UPDATING S  ***
C
 390  CALL VAXPY(P, Y, NEGONE, Y, G)
C
C  ***  DETERMINE SIZING FACTOR V(SIZE)  ***
C
C     ***  SET TEMP1 = S * STEP  ***
      S1 = IV(S)
      CALL SLVMUL(P, V(TEMP1), V(S1), V(STEP1))
C
      T1 =  ABS(SDOT(P, V(STEP1),1,V(TEMP1),1))
      T =  ABS(SDOT(P, V(STEP1),1, Y,1))
      V(SIZE) = ONE
      IF (T .LT. T1) V(SIZE) = T / T1
C
C  ***  SET G0 TO WCHMTD CHOICE OF FLETCHER AND AL-BAALI  ***
C
      HC1 = IV(HC)
      IF (HC1 .LE. 0) GO TO 400
         CALL SLVMUL(P, V(G01), V(HC1), V(STEP1))
         GO TO 410
C
 400  RMAT1 = IV(RMAT)
      CALL LTVMUL(P, V(G01), V(RMAT1), V(STEP1))
      CALL LVMUL(P, V(G01), V(RMAT1), V(G01))
C
 410  CALL VAXPY(P, V(G01), ONE, Y, V(G01))
C
C  ***  UPDATE S  ***
C
      CALL SLUPDT(V(S1), V(COSMIN), PS, V(SIZE), V(STEP1), V(TEMP1),
     1            V(TEMP2), V(G01), V(WSCALE), Y)
      IV(1) = 2
      GO TO 80
C
C. . . . . . . . . . . . . .  MISC. DETAILS  . . . . . . . . . . . . . .
C
C  ***  BAD PARAMETERS TO ASSESS  ***
C
 420  IV(1) = 64
      GO TO 999
C
C
C  ***  CONVERGENCE OBTAINED -- SEE WHETHER TO COMPUTE COVARIANCE  ***
C
 430  IF (IV(COVREQ) .EQ. 0 .AND. IV(COVPRT) .EQ. 0 .AND.
     1                            IV(RDREQ) .LE. 0) GO TO 490
      IF (IV(FDH) .NE. 0) GO TO 490
      IF (IV(CNVCOD) .GE. 7) GO TO 490
      IF (IABS(IV(COVREQ)) .GE. 3) GO TO 470
C
C  ***  COMPUTE FINITE-DIFFERENCE HESSIAN FOR COMPUTING COVARIANCE  ***
C
 440  CALL FDHES(D, G, I, IV, LIV, LV, P, V, X)
      GO TO (450, 460, 490), I
 450  IV(NFCOV) = IV(NFCOV) + 1
      IV(NFCALL) = IV(NFCALL) + 1
      IV(1) = 1
      GO TO 999
C
 460  IV(NGCOV) = IV(NGCOV) + 1
      IV(NGCALL) = IV(NGCALL) + 1
      IV(NFGCAL) = IV(NFCALL) + IV(NGCOV)
      IV(1) = 2
      GO TO 999
C
 470  H1 = IABS(IV(H))
      IV(FDH) = H1
      IV(H) = -H1
      HC1 = IV(HC)
      IF (HC1 .LE. 0) GO TO 480
           CALL SCOPY(P*(P+1)/2,V(HC1),1,V(H1),1)
           GO TO 490
 480  RMAT1 = IV(RMAT)
      CALL LSQUAR(P, V(H1), V(RMAT1))
C
 490  IV(MODE) = 0
      IV(1) = IV(CNVCOD)
      IV(CNVCOD) = 0
      GO TO 999
C
C  ***  SPECIAL RETURN FOR MISSING HESSIAN INFORMATION -- BOTH
C  ***  IV(HC) .LE. 0 AND IV(RMAT) .LE. 0
C
 500  IV(1) = 1400
C
 999  RETURN
C
C  ***  LAST CARD OF GLRIT FOLLOWS  ***
      END