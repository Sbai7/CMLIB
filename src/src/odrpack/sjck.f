*SJCK
      SUBROUTINE SJCK
     +   (FUN,JAC,N,NP,M,X,LDX,BETA,DELTA,LDDELT,XPLUSD,LDXPD,
     +   NETA,NTOL,SS,TT,LDTT,NROW,ISODR,EPSMAC,
     +   PVTEMP,FJACB,LDFJB,FJACX,LDFJX,PARTMP,
     +   MSGB,MSGX,IFLAG)
C***BEGIN PROLOGUE  SJCK
C***REFER TO  SODR,SODRC
C***ROUTINES CALLED  SETAF,SJCKM,SSETN,SXPY
C***DATE WRITTEN   860529   (YYMMDD)
C***REVISION DATE  870204   (YYMMDD)
C***CATEGORY NO.  G2E,I1B1
C***KEYWORDS  ORTHOGONAL DISTANCE REGRESSION,
C             NONLINEAR LEAST SQUARES,
C             ERRORS IN VARIABLES
C***AUTHOR  BOGGS, PAUL T.
C             OPTIMIZATION GROUP/SCIENTIFIC COMPUTING DIVISION
C             NATIONAL BUREAU OF STANDARDS, GAITHERSBURG, MD 20899
C           BYRD, RICHARD H.
C             DEPARTMENT OF COMPUTER SCIENCE
C             UNIVERSITY OF COLORADO, BOULDER, CO 80309
C           DONALDSON, JANET R.
C             OPTIMIZATION GROUP/SCIENTIFIC COMPUTING DIVISION
C             NATIONAL BUREAU OF STANDARDS, BOULDER, CO 80303-3328
C           SCHNABEL, ROBERT B.
C             DEPARTMENT OF COMPUTER SCIENCE
C             UNIVERSITY OF COLORADO, BOULDER, CO 80309
C             AND
C             OPTIMIZATION GROUP/SCIENTIFIC COMPUTING DIVISION
C             NATIONAL BUREAU OF STANDARDS, BOULDER, CO 80303-3328
C***PURPOSE  DRIVER ROUTINE FOR THE DERIVATIVE CHECKING PROCESS
C           (THIS ROUTINE IS MODELED AFTER STARPAC SUBROUTINE DCKCNT)
C***END PROLOGUE  SJCK
C
C  EXTERNALS
C
      EXTERNAL FUN
C        THE NAME OF USER-SUPPLIED ROUTINE FOR COMPUTING THE MODEL.
C        (FOR DETAILS, SEE ODRPACK REFERENCE GUIDE SECTION V.B,
C        ARGUMENT FUN.)
      EXTERNAL JAC
C        THE NAME OF USER-SUPPLIED ROUTINE FOR COMPUTING THE JACOBIANS.
C        (FOR DETAILS, SEE ODRPACK REFERENCE GUIDE SECTION V.B,
C        ARGUMENT JAC.)
C
C  VARIABLE DECLARATIONS (ALPHABETICALLY)
C
      REAL BETA(NP)
C        THE FUNCTION PARAMETERS.
C        (FOR DETAILS, SEE ODRPACK REFERENCE GUIDE.)
      REAL DELTA(LDDELT,M)
C        THE ESTIMATED ERRORS IN THE INDEPENDENT VARIABLES.
      REAL EPSMAC
C        THE VALUE OF MACHINE PRECISION.
      REAL ETA
C        THE RELATIVE NOISE IN THE MODEL.
      REAL FJACB(LDFJB,NP)
C        THE JACOBIAN WITH RESPECT TO BETA.
      REAL FJACX(LDFJX,M)
C        THE JACOBIAN WITH RESPECT TO X.
      INTEGER IFLAG
C        AN INDICATOR VARIABLE, USED PRIMARILY TO DESIGNATE THAT THE
C        USER WISHES THE COMPUTATIONS STOPPED.
      LOGICAL ISODR
C        THE INDICATOR VARIABLE USED TO DESIGNATE WHETHER THE SOLUTION
C        IS TO BE FOUND BY ODR (ISODR=.TRUE.) OR BY OLS (ISODR=.FALSE.).
      LOGICAL ISWRTB
C        THE CONTROL VALUE DETERMINING WHETHER THE DERIVATIVES WRT
C        BETA (ISWRTB=TRUE) OR DELTA(ISWRTB=FALSE) ARE BEING CHECKED.
      INTEGER J
C        AN INDEX VARIABLE.
      INTEGER LDDELT
C        THE LEADING DIMENSION OF ARRAY DELTA.
      INTEGER LDFJB
C        THE LEADING DIMENSION OF ARRAY FJACB.
      INTEGER LDFJX
C        THE LEADING DIMENSION OF ARRAY FJACX.
      INTEGER LDTT
C        THE LEADING DIMENSION OF ARRAY TT.
      INTEGER LDX
C        THE LEADING DIMENSION OF ARRAY X.
      INTEGER LDXPD
C        THE LEADING DIMENSION OF ARRAY XPLUSD.
      INTEGER M
C        THE NUMBER OF COLUMNS OF DATA IN THE INDEPENDENT VARIABLE.
C        (FOR DETAILS, SEE ODRPACK REFERENCE GUIDE.)
      INTEGER MSGB(NP+1)
C        THE ERROR CHECKING RESULTS FOR THE JACOBIAN WRT BETA.
      INTEGER MSGX(M+1)
C        THE ERROR CHECKING RESULTS FOR THE JACOBIAN WRT X.
      INTEGER N
C        THE NUMBER OF OBSERVATIONS.
C        (FOR DETAILS, SEE ODRPACK REFERENCE GUIDE.)
      INTEGER NETA
C        THE NUMBER OF RELIABLE DIGITS IN THE MODEL, EITHER
C        SET BY THE USER OR COMPUTED BY SETAF.
      INTEGER NP
C        THE NUMBER OF FUNCTION PARAMETERS.
C        (FOR DETAILS, SEE ODRPACK REFERENCE GUIDE.)
      INTEGER NROW
C        THE NUMBER OF THE ROW OF THE INDEPENDENT VARIABLE ARRAY
C        AT WHICH THE DERIVATIVE IS CHECKED.
      INTEGER NTOL
C        THE NUMBER OF DIGITS OF AGREEMENT REQUIRED BETWEEN THE
C        NUMERICAL DERIVATIVES AND THE USER SUPPLIED DERIVATIVES,
C        EITHER SET BY THE USER OR COMPUTED FROM NETA.
      REAL ONE
C        THE VALUE 1.0E0.
      REAL PARTMP(NP)
C        THE MODIFIED MODEL PARAMETERS
      REAL PV
C        THE SCALAR IN WHICH THE PREDICTED VALUE FROM THE MODEL FOR
C        ROW   NROW   IS STORED.
      REAL PVTEMP(N)
C        THE PREDICTED VALUE BASED ON THE CURRENT PARAMETER ESTIMATES
      REAL SS(NP)
C        THE SCALE USED FOR THE ESTIMATED BETA'S.
C        (FOR DETAILS, SEE ODRPACK REFERENCE GUIDE.)
      REAL TEN
C        THE VALUE 10.0E0.
      REAL TOL
C        THE AGREEMENT TOLERANCE.
      REAL TT(LDTT,M)
C        THE SCALE USED FOR THE DELTA'S.
C        (FOR DETAILS, SEE ODRPACK REFERENCE GUIDE.)
      REAL TYPJ
C        THE TYPICAL SIZE OF THE J-TH UNKNOWN BETA OR DELTA.
      REAL X(LDX,M)
C        THE INDEPENDENT VARIABLE.
C        (FOR DETAILS, SEE ODRPACK REFERENCE GUIDE.)
      REAL XPLUSD(LDXPD,M)
C        THE ARRAY X + DELTA.
      REAL ZERO
C        THE VALUE 0.0E0.
C
C
      DATA ZERO,ONE,TEN/0.0E0,1.0E0,10.0E0/
C
C
C***FIRST EXECUTABLE STATEMENT  SJCK
C
C
C  COMPUTE XPLUSD = X + DELTA
C
      CALL SXPY(N,M,X,LDX,DELTA,LDDELT,XPLUSD,LDXPD)
C
C  SELECT FIRST ROW OF X + DELTA WHICH CONTAINS NO ZEROS
C
      CALL SSETN(N,M,XPLUSD,LDXPD,NROW)
C
C  SET PARAMETERS NECESSARY FOR THE COMPUTATIONS
C
      IF ((NETA.LT.2) .OR. (NETA.GT.INT(-LOG10(EPSMAC)))) THEN
         CALL SETAF(FUN,N,NP,M,XPLUSD,LDXPD,BETA,ETA,NETA,EPSMAC,
     +              NROW,PARTMP,PVTEMP,IFLAG)
         IF (IFLAG.LT.0) THEN
            RETURN
         END IF
      ELSE
         ETA = TEN**(-NETA)
      END IF
C
      IF ((NTOL.LT.1) .OR. (NTOL.GT.(NETA+1)/2)) THEN
         NTOL = (NETA+3)/4
      END IF
C
      TOL = TEN**(-NTOL)
C
C  COMPUTE PREDICTED VALUE OF MODEL USING CURRENT PARAMETER
C  ESTIMATES, AND COMPUTE USER-SUPPLIED DERIVATIVE VALUES
C
      IFLAG = 0
      CALL FUN(N,NP,M,BETA,XPLUSD,LDXPD,PVTEMP,IFLAG)
      IF (IFLAG.LT.0) THEN
         RETURN
      END IF
      PV = PVTEMP(NROW)
      IFLAG = 0
      CALL JAC(N,NP,M,BETA,XPLUSD,LDXPD,FJACB,LDFJB,
     +         ISODR,FJACX,LDFJX,IFLAG)
      IF (IFLAG.LT.0) THEN
         RETURN
      END IF
C
C  CHECK DERIVATIVES WRT BETA
C
      ISWRTB = .TRUE.
      MSGB(1) = 0
C
      DO 10 J=1,NP
C
         IF (SS(1).GT.ZERO) THEN
            TYPJ = ONE/SS(J)
         ELSE
            TYPJ = ONE/ABS(SS(1))
         END IF
C
C  CHECK DERIVATIVE WRT THE J-TH PARAMETER AT THE NROW-TH ROW
C
         CALL SJCKM(FUN,N,NP,M,XPLUSD,LDXPD,BETA,TYPJ,ETA,TOL,EPSMAC,
     +              J,NROW,PV,FJACB(NROW,J),
     +              PVTEMP,ISWRTB,MSGB,NP+1,IFLAG)
         IF (IFLAG.LT.0) THEN
            RETURN
         END IF
C
   10 CONTINUE
C
C  CHECK DERIVATIVES WRT X
C
      MSGX(1) = 0
C
      IF (ISODR) THEN
         ISWRTB = .FALSE.
         DO 20 J=1,M
C
            IF (TT(1,1).GT.ZERO) THEN
               IF (LDTT.EQ.1) THEN
                  TYPJ = ONE/TT(1,J)
               ELSE
                  TYPJ = ONE/TT(NROW,J)
               END IF
            ELSE
               TYPJ = ABS(ONE/TT(1,1))
            END IF
C
C  CHECK DERIVATIVE WRT THE J-TH COLUMN OF X AT ROW NROW
C
            CALL SJCKM(FUN,N,NP,M,XPLUSD,LDXPD,BETA,TYPJ,ETA,TOL,
     +                 EPSMAC,J,NROW,PV,FJACX(NROW,J),
     +                 PVTEMP,ISWRTB,MSGX,M+1,IFLAG)
            IF (IFLAG.LT.0) THEN
               RETURN
            END IF
C
   20    CONTINUE
      END IF
C
C  PRINT RESULTS IF THEY ARE DESIRED
C
      RETURN
C
      END
