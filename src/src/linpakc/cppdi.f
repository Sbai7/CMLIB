      SUBROUTINE CPPDI(AP,N,DET,JOB)
C***BEGIN PROLOGUE  CPPDI
C***DATE WRITTEN   780814   (YYMMDD)
C***REVISION DATE  820801   (YYMMDD)
C***REVISION HISTORY  (YYMMDD)
C   000330  Modified array declarations.  (JEC)
C***CATEGORY NO.  D2D1B,D3D1B
C***KEYWORDS  COMPLEX,DETERMINANT,FACTOR,INVERSE,LINEAR ALGEBRA,LINPACK,
C             MATRIX,PACKED,POSITIVE DEFINITE
C***AUTHOR  MOLER, C. B., (U. OF NEW MEXICO)
C***PURPOSE  Computes the determinant and inverse of a COMPLEX HERMITIAN
C            POSITIVE DEFINITE matrix using factors from CPPCO or CPPFA.
C***DESCRIPTION
C
C     CPPDI computes the determinant and inverse
C     of a complex Hermitian positive definite matrix
C     using the factors computed by CPPCO or CPPFA .
C
C     On Entry
C
C        AP      COMPLEX (N*(N+1)/2)
C                the output from CPPCO or CPPFA.
C
C        N       INTEGER
C                the order of the matrix  A .
C
C        JOB     INTEGER
C                = 11   both determinant and inverse.
C                = 01   inverse only.
C                = 10   determinant only.
C
C     On Return
C
C        AP      the upper triangular half of the inverse .
C                The strict lower triangle is unaltered.
C
C        DET     REAL(2)
C                determinant of original matrix if requested.
C                Otherwise not referenced.
C                Determinant = DET(1) * 10.0**DET(2)
C                with  1.0 .LE. DET(1) .LT. 10.0
C                or  DET(1) .EQ. 0.0 .
C
C     Error Condition
C
C        A division by zero will occur if the input factor contains
C        a zero on the diagonal and the inverse is requested.
C        It will not occur if the subroutines are called correctly
C        and if CPOCO or CPOFA has set INFO .EQ. 0 .
C
C     LINPACK.  This version dated 08/14/78 .
C     Cleve Moler, University of New Mexico, Argonne National Lab.
C
C     Subroutines and Functions
C
C     BLAS CAXPY,CSCAL
C     Fortran CONJG,MOD,REAL
C***REFERENCES  DONGARRA J.J., BUNCH J.R., MOLER C.B., STEWART G.W.,
C                 *LINPACK USERS  GUIDE*, SIAM, 1979.
C***ROUTINES CALLED  CAXPY,CSCAL
C***END PROLOGUE  CPPDI
      INTEGER N,JOB
      COMPLEX AP(*)
      REAL DET(2)
C
      COMPLEX T
      REAL S
      INTEGER I,II,J,JJ,JM1,J1,K,KJ,KK,KP1,K1
C
C     COMPUTE DETERMINANT
C
C***FIRST EXECUTABLE STATEMENT  CPPDI
      IF (JOB/10 .EQ. 0) GO TO 70
         DET(1) = 1.0E0
         DET(2) = 0.0E0
         S = 10.0E0
         II = 0
         DO 50 I = 1, N
            II = II + I
            DET(1) = REAL(AP(II))**2*DET(1)
C        ...EXIT
            IF (DET(1) .EQ. 0.0E0) GO TO 60
   10       IF (DET(1) .GE. 1.0E0) GO TO 20
               DET(1) = S*DET(1)
               DET(2) = DET(2) - 1.0E0
            GO TO 10
   20       CONTINUE
   30       IF (DET(1) .LT. S) GO TO 40
               DET(1) = DET(1)/S
               DET(2) = DET(2) + 1.0E0
            GO TO 30
   40       CONTINUE
   50    CONTINUE
   60    CONTINUE
   70 CONTINUE
C
C     COMPUTE INVERSE(R)
C
      IF (MOD(JOB,10) .EQ. 0) GO TO 140
         KK = 0
         DO 100 K = 1, N
            K1 = KK + 1
            KK = KK + K
            AP(KK) = (1.0E0,0.0E0)/AP(KK)
            T = -AP(KK)
            CALL CSCAL(K-1,T,AP(K1),1)
            KP1 = K + 1
            J1 = KK + 1
            KJ = KK + K
            IF (N .LT. KP1) GO TO 90
            DO 80 J = KP1, N
               T = AP(KJ)
               AP(KJ) = (0.0E0,0.0E0)
               CALL CAXPY(K,T,AP(K1),1,AP(J1),1)
               J1 = J1 + J
               KJ = KJ + J
   80       CONTINUE
   90       CONTINUE
  100    CONTINUE
C
C        FORM  INVERSE(R) * CTRANS(INVERSE(R))
C
         JJ = 0
         DO 130 J = 1, N
            J1 = JJ + 1
            JJ = JJ + J
            JM1 = J - 1
            K1 = 1
            KJ = J1
            IF (JM1 .LT. 1) GO TO 120
            DO 110 K = 1, JM1
               T = CONJG(AP(KJ))
               CALL CAXPY(K,T,AP(J1),1,AP(K1),1)
               K1 = K1 + K
               KJ = KJ + 1
  110       CONTINUE
  120       CONTINUE
            T = CONJG(AP(JJ))
            CALL CSCAL(J,T,AP(J1),1)
  130    CONTINUE
  140 CONTINUE
      RETURN
      END
