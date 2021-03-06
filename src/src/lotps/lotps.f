      SUBROUTINE LOTPS (MODE,NPPR,NPI,XI,YI,FI,NXO,XO,NYO,YO,IWK,NIWK,
     1                  NIWKU,WK,NWK,NWKU,FO,KER)
C***START PROLOGUE LOTPS
C
C     THIS VERSION IS DATED 03/04/82.
C
C                RICHARD FRANKE
C                DEPARTMENT OF MATHEMATICS
C                NAVAL POSTGRADUATE SCHOOL
C                MONTEREY, CALIFORNIA  93940
C                     (408)646-2758 / 2206
C
C
C
C     REFERENCE
C        SMOOTH INTERPOLATION OF SCATTERED DATA BY LOCAL THIN
C        PLATE SPLINES, COMPUTERS AND MATHEMATICS WITH
C        APPLICATIONS 8(1982)???-???+8
C                    OR
C        NAVAL POSTGRADUATE SCHOOL TR#NPS-53-81-002, 1981
C        (AVAILABLE FROM NTIS, AD-A098 232/2)
C
C     ABSTRACT
C        SUBROUTINE LOTPS SERVES AS THE USER INTERFACE FOR A SET OF
C        SUBROUTINES WHICH SOLVE THE SCATTERED DATA INTERPOLATION
C        PROBLEM.  A SMOOTH FUNCTION PASSING THROUGH THE GIVEN POINTS
C        (XI(K),YI(K),FI(K)),K=1,...,NPI IS CONSTRUCTED.
C        THE RESULT RETURNED IS AN ARRAY OF VALUES, FO(I,J), OF THE INT-
C        ERPOLATION FUNCTION AT GRID POINTS, (XO(I),YO(J)),I=1,...,NXO,
C        J=1,...,NYO.
C        THE METHOD USED INVOLVES CONSTRUCTION OF LOCALLY DEFINED 'THIN
C        PLATE SPLINES', WHICH ARE THEN BLENDED TOGETHER SMOOTHLY
C        THROUGH THE USE OF A PARTITION OF UNITY DEFINED ON A
C        RECTANGULAR GRID ON THE PLANE.  THE FUNCTIONS IN THE PARTITION
C        OF UNITY ARE UNIVARIATE PIECEWISE HERMITE CUBIC POLYNOMIALS.
C
C     CAUTIONS
C        THE USER SHOULD BE AWARE THAT FOR SOME DATA THE INTERPOLATION
C        FUNCTION MAY BE ILL-BEHAVED.  SOME INVESTIGATION OF ITS
C        BEHAVIOR FOR THE TYPE OF DATA TO BE INPUT SHOULD BE UNDERTAKEN
C        BEFORE IMBEDDING ANY SCHEME FOR SCATTERED DATA INTERPOLATION
C        INTO ANOTHER PROGRAM.
C
C     DESCRIPTION OF ARGUMENTS
C
C        MODE - INPUT.  INDICATES THE STATUS OF THE CALCULATION.
C                 = 1,  SET UP THE PROBLEM.  COMPUTE THE COEFFICIENTS
C                       FOR THE LOCAL APPROXIMATIONS BY THIN PLATE
C                       SPLINES, AND RETURN THE GRID OF INTERPOLATED
C                       FUNCTION VALUES INDICATED BY NXO, XO, NYO, YO
C                       IN THE ARRAY FO.
C                 = 2,  THIS MODE VALUE IS A CONVENIENCE FOR USERS WHO
C                       WISH TO CALL THE ROUTINE TO EVALUATE THE
C                       SURFACE REPEATEDLY ON DIFFERENT GRIDS OF
C                       POINTS.  A CALL TO LOTPS WITH MODE = 1 HAS
C                       BEEN MADE PREVIOUSLY, NOW CALCULATE
C                       THE GRID OF INTERPOLATED POINTS INDICATED
C                       BY NXO, XO, NYO, YO IN IN THE ARRAY FO.  THE
C                       PROGRAM ASSUMES THAT THE ARRAYS XI, YI, IWK,
C                       AND WK ARE UNCHANGED FROM THE PREVIOUS CALL.
C        NPPR - INPUT.  DESIRED AVERAGE NUMBER OF POINTS PER REGION.
C                       THE SUGGESTED VALUE FOR THE NOVICE USER IS TEN,
C                       WHICH USUALLY GIVES GOOD RESULTS.  THIS PAR-
C                       AMETER HAS TO DO WITH THE LOCAL PROPERTY OF THE
C                       SURFACE.  THE INFLUENCE REGION OF A POINT HAS
C                       AREA WHICH IS ROUGHLY PROPORTIONAL TO NPPR.
C                       UNDER CERTAIN CONDITIONS, SUCH AS TO PRESERVE
C                       ROTATIONAL INVARIANCE, OR TO FORCE CERTAIN
C                       SETS OF POINTS TO BELONG TO THE SAME REGION,
C                       THE USER MAY SPECIFY HIS OWN GRID LINES.
C                       IF THE USER WISHES TO SPECIFY HIS OWN GRID LINES
C                       X TILDA AND Y TILDA, HE MAY DO SO BY SETTING
C                       NPPR = 0 AND SETTING NECESSARY VALUES IN THE
C                       ARRAYS IWK AND WK, AS NOTED BELOW.  DATA WHICH
C                       HAS A POOR DISTRIBUTION OVER THE REGION OF INT-
C                       EREST SHOULD PROBABLY HAVE THE GRID SPECIFIED.
C                       THIS IS ALSO ADVISABLE IF THE X-Y POINTS OCCUR
C                       ALONG LINES.  SEE THE REFERENCE FOR ADDITIONAL
C                       DETAILS.
C        NPI  - INPUT.  NUMBER OF INPUT DATA POINTS.
C        XI   - \
C        YI   - INPUT ARRAYS.  THE DATA POINTS (XI,YI,FI), I=1,...,NPI.
C        FI   - /
C        NXO  - INPUT.  THE NUMBER OF XO VALUES AT WHICH THE INTERP-
C                       OLATION FUNCTION IS TO BE CALCULATED.
C        XO   - INPUT ARRAY.  THE VALUES OF X AT WHICH THE INTERPOLATION
C                       FUNCTION IS TO BE CALCULATED.  THESE SHOULD
C                       BE IN INCREASING ORDER FOR MOST EFFICIENT
C                       EVALUATION, HOWEVER, THEY ONLY NEED TO BE
C                       MONOTONIC.
C        NYO  - INPUT.  THE NUMBER OF YO VALUES AT WHICH THE INTERP-
C                       OLATION FUNCTION IS TO BE CALCULATED.
C        YO   - INPUT ARRAY.  THE VALUES OF Y AT WHICH THE INTERPOLATION
C                       FUNCTION IS TO BE CALCULATED.  THESE SHOULD
C                       BE IN INCREASING ORDER FOR MOST EFFICIENT
C                       EVALUATION, HOWEVER, THEY ONLY NEED TO BE
C                       MONOTONIC.
C        IWK  - INPUT/OUTPUT ARRAY.  THIS ARRAY IS OUTPUT WHEN MODE = 1
C                       AND IS INPUT WHEN MODE = 2.  THIS MUST BE
C                       AN ARRAY DIMENSIONED APPROXIMATELY 7*NPI.  THE
C                       EXACT DIMENSION IS NOT KNOWN A PRIORI, BUT
C                       WILL BE RETURNED AS THE VALUE OF NIWKU.
C                       WHEN NPPR IS INPUT AS ZERO THE USER MUST
C                       SPECIFY THE NUMBER OF VERTICAL GRID LINES (THE
C                       NUMBER OF X TILDA VALUES) IN IWK(1) AND THE
C                       NUMBER OF HORIZONTAL GRID LINES (THE NUMBER OF
C                       Y TILDA VALUES) IN IWK(2).
C        NIWK - INPUT.  ON ENTRY WITH MODE = 1 THIS MUST BE SET TO THE
C                       DIMENSION OF THE ARRAY IWK IN THE CALLING
C                       PROGRAM.
C        NIWKU- OUTPUT.  THE ACTUAL NUMBER OF LOCATIONS NEEDED IN THE
C                       ARRAY IWK.
C        WK   - INPUT/OUTPUT ARRAY.  THIS ARRAY IS OUTPUT WHEN MODE = 1
C                       AND IS INPUT WHEN MODE = 2.  THIS MUST BE AN
C                       ARRAY DIMENSIONED APPROXIMATELY 7*NPI PLUS
C                       THE NUMBER NEEDED TO SET UP AND SOLVE THE SYSTEM
C                       OF EQUATIONS FOR THE LOCAL APPROXIMATIONS.  FOR
C                       NPPR NONZERO THIS WILL BE ABOUT 2.5*NPPR*NPPR
C                       PLUS 11*NPPR.  THE EXACT DIMENSION IS NOT KNOWN
C                       A PRIORI, BUT WILL BE RETURNED AS THE VALUE OF
C                       NWKU.
C                       WHEN NPPR IS INPUT AS ZERO THE USER MUST SPECIFY
C                       THE VALUES OF X TILDA AND Y TILDA AS FOLLOWS.
C                       WK(2), ... , WK(NXG+1) ARE THE NXG (= IWK(1))
C                       X GRID VALUES, X(I) TILDA, IN INCREASING ORDER.
C                       TYPICALLY WK(1) = MIN X(I), ALTHOUGH IT NEED
C                       NOT BE.  WK(1) MUST BE LESS THAN OR EQUAL TO
C                       WK(2), AND SHOULD BE LESS THAN OR EQUAL TO
C                       MIN X(I).  WK(NXG+2) IS USUALLY MAX X(I), AL-
C                       THOUGH IT NEED NOT BE.  WK(NXG+2) MUST BE
C                       GREATER THAN WK(NXG+1), AND SHOULD BE GREATER
C                       THAN OR EQUAL TO MAX X(I).
C                       THE VALUES OF WK(NXG+3), ... , WK(NXG+NYG+4)
C                       ARE THE Y GRID VALUES, Y(I) TILDA, AND MUST
C                       SATISFY DUAL CONDITIONS.
C        NWK  - INPUT.  ON ENTRY WITH MODE = 1 THIS MUST BE SET TO THE
C                       DIMENSION OF THE ARRAY WK IN THE CALLING
C                       PROGRAM.
C        NWKU - OUTPUT.  THE ACTUAL NUMBER OF LOCATIONS NEEDED IN THE
C                       ARRAY WK.
C        FO   - OUTPUT ARRAY.  VALUES OF THE INTERPOLATION FUNCTION AT
C                       THE GRID OF POINTS INDICATED BY NXO, XO, NYO, YO
C                       FO IS ASSUMED TO BE DIMENSIONED (NXO,NYO) IN THE
C                       CALLING PROGRAM.
C        KER  - OUTPUT.  RETURN INDICATOR.
C                 = 0,  NORMAL RETURN.
C                 = NONZERO, ERROR CONDITION ENCOUNTERED.
C
C     ERROR MESSAGES
C        NO. 1   FATAL         SINGULAR MATRIX IN THE CALCULATION OF
C                              LOCAL THIN PLATE SPLINES.  TRY LARGER
C                              VALUE FOR NPPR AND/OR MINPTS.  (MINPTS
C                              IS IN SUBROUTINE LOLIP.)
C        NO. 2   RECOVERABLE   FIRST CALL TO LOTPS MUST BE WITH MODE=1
C        NO. 3   FATAL         PREVIOUS ERROR RETURN FROM SUBROUTINE
C                              LOCAL NOT CORRECTED.
C        NO. 4   FATAL         ARRAY IWK AND/OR WK NOT DIMENSIONED LARGE
C                              ENOUGH.  REDIMENSION AS GIVEN BY NIWKU
C                              AND NWKU.
C        NO. 5   RECOVERABLE   MODE IS OUT OF RANGE.
C
C     SUBROUTINES USED
C
C        THIS PACKAGE:  LOGRD, LOLIP, LOCAL, LOEVL.
C        LINPACK: SGECO, SGESL
C        SLATEC:  SSORT, XERROR
C
C***END PROLOGUE
      DIMENSION XI(NPI), YI(NPI), FI(NPI), IWK(NIWK), WK(NWK),
     1 XO(NXO), YO(NYO), FO(NXO,NYO)
      DATA KERO/-1/
      IF (MODE.LT.1.OR.MODE.GT.2) GO TO 220
      KER = 0
C
C     ON INITIAL ENTRY MODE = 1, THE GRID LINES ARE SET UP,
C     LOCAL INTERPOLATION POINTS ARE DETERMINED AND LOCAL APPROXIMATIONS
C     ARE COMPUTED.
C
      IF (MODE.EQ.2) GO TO 140
      NXGWK = 1
      NPWK = 3
      IF (NPPR.LE.0) GO TO 100
      NXG = SQRT(4.*FLOAT(NPI)/FLOAT(NPPR))-.5
      NXG = MAX0(NXG,1)
      NYG = NXG
      IWK(1) = NXG
      IWK(2) = NYG
      GO TO 120
  100 NXG = IWK(1)
      NYG = IWK(2)
  120 IALWK = NXG+NYG+5
      IABWK = IALWK + 3*NXG*NYG
      NYGWK = NXG+3
      MPWK = NXG*NYG+4
C
      IF(NPPR.LE.0)GO TO 130
      CALL LOGRD(XI,NPI,NXG,WK(NXGWK),WK(IALWK))
      CALL LOGRD(YI,NPI,NYG,WK(NYGWK),WK(IALWK))
  130 CONTINUE
C
C     DETERMINE THE LOCAL INTERPOLATION POINTS FOR THE REGIONS.
      MWK = NWK - MPWK + 1
      CALL LOLIP (NXG,WK(NXGWK),NYG,WK(NYGWK),NPI,XI,YI,IWK(NPWK),
     1IWK(MPWK),MWK,NMAX,WK(IALWK))
      NCFM = IABWK +IWK(MPWK - 1)-1
      NWKU = NCFM + (NMAX+3)*(NMAX+5) - 1
      NIPVT = NXG*NYG+3+IWK(MPWK-1)
      NIWKU = NIPVT + NMAX + 2
      IF (NIWKU.GT.NIWK) GO TO 200
      IF (NWKU.GT.NWK) GO TO 200
C
C     COMPUTE THE LOCAL APPROXIMATIONS.
      CALL LOCAL (XI,YI,FI,NXG,WK(NXGWK),NYG,WK(NYGWK),IWK(NPWK),
     1 IWK(MPWK),WK(IALWK),WK(IABWK),WK(NCFM),IWK(NIPVT),IER)
      KERO = IER
      IF (IER.NE.0) GO TO 160
  140 IF (KERO.NE.0) GO TO 180
C
C     COMPUTE THE FUNCTION VALUES ON THE DESIRED GRID OF POINTS.
C
      CALL LOEVL (XI,YI,IWK(1),WK(NXGWK),IWK(2),WK(NYGWK),IWK(NPWK),
     1 IWK(MPWK),WK(IALWK),WK(IABWK),NXO,XO,NYO,YO,FO)
      RETURN
C
C     ERROR RETURNS
C
  160 KER = IER
      IF(IER.NE.0)CALL XERROR('LOTPS-SINGULAR MATRIX IN LOCAL; INCREAS
     1E NPPR OR SPECIFY OWN GRID LINES',71,1,2)
      RETURN
  180 KER = 3
      IF (KERO.LT.0) GO TO 190
       CALL XERROR('LOTPS-PREVIOUS ERROR FROM SUBROUTINE LOCAL HAS NOT
     1BEEN CORRECTED.',65,3,2)
      RETURN
  190 KER = 2
      CALL XERROR('LOTPS-FIRST CALL TO LOTPS MUST BE WITH MODE = 1',
     1 47,2,1)
      RETURN
  200 KER = 4
      CALL XERROR('LOTPS-WORK ARRAYS IWK AND/OR WK NOT DIMENSIONED LAR
     1GE ENOUGH',60,4,2)
      RETURN
  220 KER = 5
      CALL XERROR('LOTPS-MODE IS OUT OF RANGE.  MUST BE 1 OR 2',43,5,
     1 1)
      RETURN
      END
