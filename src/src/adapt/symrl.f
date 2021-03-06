      SUBROUTINE SYMRL(S, CENTER, HWIDTH, F, MINORD, MAXORD, INTVLS,
     * INTCLS, NUMSMS, WEGHTS, FULSMS, FAIL)
C  MULTIDIMENSIONAL FULLY SYMMETRIC RULE INTEGRATION SUBROUTINE
C
C   THIS SUBROUTINE COMPUTES A SEQUENCE OF FULLY SYMMETRIC RULE
C   APPROXIMATIONS TO A FULLY SYMMETRIC MULTIPLE INTEGRAL.
C   WRITTEN BY A. GENZ, MATHEMATICAL INSTITUTE, UNIVERSITY OF KENT,
C   CANTERBURY, KENT CT2 7NF, ENGLAND
C
C**************  PARAMETERS FOR SYMRL  ********************************
C*****INPUT PARAMETERS
C  S       INTEGER NUMBER OF VARIABLES, MUST EXCEED 0 BUT NOT EXCEED 20
C  F       EXTERNALLY DECLARED USER DEFINED REAL FUNCTION INTEGRAND.
C          IT MUST HAVE PARAMETERS (S,X), WHERE X IS A REAL ARRAY
C          WITH DIMENSION S.
C  MINORD  INTEGER MINIMUM ORDER PARAMETER.  ON ENTRY MINORD SPECIFIES
C          THE CURRENT HIGHEST ORDER APPROXIMATION TO THE INTEGRAL,
C          AVAILABLE IN THE ARRAY INTVLS.  FOR THE FIRST CALL OF SYMRL
C          MINORD SHOULD BE SET TO 0.  OTHERWISE A PREVIOUS CALL IS
C          ASSUMED THAT COMPUTED INTVLS(1), ... , INTVLS(MINORD).
C          ON EXIT MINORD IS SET TO MAXORD.
C  MAXORD  INTEGER MAXIMUM ORDER PARAMETER, MUST BE GREATER THAN MINORD
C          AND NOT EXCEED 20. THE SUBROUTINE COMPUTES INTVLS(MINORD+1),
C          INTVLS(MINORD+2),..., INTVLS(MAXORD).
C  G       REAL ARRAY OF DIMENSION(MAXORD) OF GENERATORS.
C          ALL GENERATORS MUST BE DISTINCT AND NONNEGATIVE.
C  NUMSMS  INTEGER LENGTH OF ARRAY FULSMS, MUST BE AT LEAST THE SUM OF
C          THE NUMBER OF DISTINCT PARTITIONS OF LENGTH AT MOST S
C          OF THE INTEGERS 0,1,...,MAXORD-1.  AN UPPER BOUND FOR NUMSMS
C          WHEN S+MAXORD IS LESS THAN 19 IS 200
C******OUTPUT PARAMETERS
C  INTVLS  REAL ARRAY OF DIMENSION(MAXORD).  UPON SUCCESSFUL EXIT
C          INTVLS(1), INTVLS(2),..., INTVLS(MAXORD) ARE APPROXIMATIONS
C          TO THE INTEGRAL.  INTVLS(D+1) WILL BE AN APPROXIMATION OF
C          POLYNOMIAL DEGREE 2D+1.
C  INTCLS  INTEGER TOTAL NUMBER OF F VALUES NEEDED FOR INTVLS(MAXORD)
C  WEGHTS  REAL WORKING STORAGE ARRAY WITH DIMENSION (NUMSMS). ON EXIT
C          WEGHTS(J) CONTAINS THE WEIGHT FOR FULSMS(J).
C  FULSMS  REAL WORKING STORAGE ARRAY WITH DIMENSION (NUMSMS). ON EXIT
C          FULSMS(J) CONTAINS THE FULLY SYMMETRIC BASIC RULE SUM
C          INDEXED BY THE JTH S-PARTITION OF THE INTEGERS
C          0,1,...,MAXORD-1.
C  FAIL    INTEGER FAILURE OUTPUT PARAMETER
C          FAIL=0 FOR SUCCESSFUL TERMINATION OF THE SUBROUTINE
C          FAIL=1 WHEN NUMSMS IS TOO SMALL FOR THE SUBROUTINE TO
C                  CONTINUE.  IN THIS CASE WEGHTS(1), WEGHTS(2), ...,
C                  WEGHTS(NUMSMS), FULSMS(1), FULSMS(2), ...,
C                  FULSMS(NUMSMS) AND INTVLS(1), INTVLS(2),...,
C                  INTVLS(J) ARE RETURNED, WHERE J IS MAXIMUM VALUE OF
C                  MAXORD COMPATIBLE WITH THE GIVEN VALUE OF NUMSMS.
C          FAIL=2 WHEN PARAMETERS S,MINORD, MAXORD OR G ARE OUT OF
C                  RANGE
C***********************************************************************
      EXTERNAL F
C***  FOR DOUBLE PRECISION CHANGE REAL TO DOUBLE PRECISION
C      IN THE NEXT STATEMENT
      INTEGER D, I, FAIL, K(20), INTCLS, PRTCNT, L, M(20), MAXORD,
     * MINORD, MODOFM, NUMSMS, S, SUMCLS
      REAL INTVLS(MAXORD), CENTER(S), HWIDTH(S), GISQRD, GLSQRD,
     * INTMPA, INTMPB, INTVAL, ONE, FULSMS(NUMSMS), WEGHTS(NUMSMS),
     * TWO, MOMTOL, MOMNKN, MOMPRD(20,20), MOMENT(20), ZERO, G(20)
C       PATTERSON GENERATORS
      DATA G(1), G(2) /0.0000000000000000,0.7745966692414833/
      DATA G(3), G(4) /0.9604912687080202,0.4342437493468025/
      DATA G(5), G(6) /0.9938319632127549,0.8884592328722569/
      DATA G(7), G(8) /0.6211029467372263,0.2233866864289668/
      DATA G(9), G(10), G(11), G(12) /0.1, 0.2, 0.3, 0.4/
C
C***  PARAMETER CHECKING AND INITIALISATION
      FAIL = 2
      MAXRDM = 20
      MAXS = 20
      IF (S.GT.MAXS .OR. S.LT.1) RETURN
      IF (MINORD.LT.0 .OR. MINORD.GE.MAXORD) RETURN
      IF (MAXORD.GT.MAXRDM) RETURN
      ZERO = 0
      ONE = 1
      TWO = 2
      MOMTOL = ONE
   10 MOMTOL = MOMTOL/TWO
      IF (MOMTOL+ONE.GT.ONE) GO TO 10
      HUNDRD = 100
      MOMTOL = HUNDRD*TWO*MOMTOL
      D = MINORD
      IF (D.EQ.0) INTCLS = 0
C***  CALCULATE MOMENTS AND MODIFIED MOMENTS
      DO 20 L=1,MAXORD
        FLOATL = L + L - 1
        MOMENT(L) = TWO/FLOATL
   20 CONTINUE
      IF (MAXORD.EQ.1) GO TO 50
      DO 40 L=2,MAXORD
        INTMPA = MOMENT(L-1)
        GLSQRD = G(L-1)**2
        DO 30 I=L,MAXORD
          INTMPB = MOMENT(I)
          MOMENT(I) = MOMENT(I) - GLSQRD*INTMPA
          INTMPA = INTMPB
   30   CONTINUE
        IF (MOMENT(L)**2.LT.(MOMTOL*MOMENT(1))**2) MOMENT(L) = ZERO
   40 CONTINUE
   50 DO 70 L=1,MAXORD
        IF (G(L).LT.ZERO) RETURN
        MOMNKN = ONE
        MOMPRD(L,1) = MOMENT(1)
        IF (MAXORD.EQ.1) GO TO 70
        GLSQRD = G(L)**2
        DO 60 I=2,MAXORD
          IF (I.LE.L) GISQRD = G(I-1)**2
          IF (I.GT.L) GISQRD = G(I)**2
          IF (GLSQRD.EQ.GISQRD) RETURN
          MOMNKN = MOMNKN/(GLSQRD-GISQRD)
          MOMPRD(L,I) = MOMNKN*MOMENT(I)
   60   CONTINUE
   70 CONTINUE
      FAIL = 1
C
C***  BEGIN LOOP FOR EACH D
C      FOR EACH D FIND ALL DISTINCT PARTITIONS M WITH MOD(M))=D
C
   80 PRTCNT = 0
      INTVAL = ZERO
      MODOFM = 0
      CALL NXPRT(PRTCNT, S, M)
   90 IF (PRTCNT.GT.NUMSMS) RETURN
C
C***  CALCULATE WEIGHT FOR PARTITION M AND FULLY SYMMETRIC SUMS
C***     WHEN NECESSARY
C
      IF (D.EQ.MODOFM) WEGHTS(PRTCNT) = ZERO
      IF (D.EQ.MODOFM) FULSMS(PRTCNT) = ZERO
      FULWGT = WHT(S,MOMENT,M,K,MODOFM,D,MAXRDM,MOMPRD)
      SUMCLS = 0
      IF (WEGHTS(PRTCNT).EQ.ZERO .AND. FULWGT.NE.ZERO) FULSMS(PRTCNT) =
     * FLSM(S, CENTER, HWIDTH, MOMENT, M, K, MAXORD, G, F, SUMCLS)
      INTCLS = INTCLS + SUMCLS
      INTVAL = INTVAL + FULWGT*FULSMS(PRTCNT)
      WEGHTS(PRTCNT) = WEGHTS(PRTCNT) + FULWGT
      CALL NXPRT(PRTCNT, S, M)
      IF (M(1).GT.MODOFM) MODOFM = MODOFM + 1
      IF (MODOFM.LE.D) GO TO 90
C
C***  END LOOP FOR EACH D
      IF (D.GT.0) INTVAL = INTVLS(D) + INTVAL
      INTVLS(D+1) = INTVAL
      D = D + 1
      IF (D.LT.MAXORD) GO TO 80
C
C***  SET FAILURE PARAMETER AND RETURN
      FAIL = 0
      MINORD = MAXORD
      RETURN
      END
