      SUBROUTINE CPBFA(ABD,LDA,N,M,INFO)
C***BEGIN PROLOGUE  CPBFA
C***DATE WRITTEN   780814   (YYMMDD)
C***REVISION DATE  820801   (YYMMDD)
C***REVISION HISTORY  (YYMMDD)
C   000330  Modified array declarations.  (JEC)
C***CATEGORY NO.  D2D2
C***KEYWORDS  BANDED,COMPLEX,FACTOR,LINEAR ALGEBRA,LINPACK,MATRIX,
C             POSITIVE DEFINITE
C***AUTHOR  MOLER, C. B., (U. OF NEW MEXICO)
C***PURPOSE  Factors a COMPLEX HERMITIAN POSITIVE DEFINITE matrix (band
C            form)
C***DESCRIPTION
C
C     CPBFA factors a complex Hermitian positive definite matrix
C     stored in band form.
C
C     CPBFA is usually called by CPBCO, but it can be called
C     directly with a saving in time if  RCOND  is not needed.
C
C     On Entry
C
C        ABD     COMPLEX(LDA, N)
C                the matrix to be factored.  The columns of the upper
C                triangle are stored in the columns of ABD and the
C                diagonals of the upper triangle are stored in the
C                rows of ABD .  See the comments below for details.
C
C        LDA     INTEGER
C                the leading dimension of the array  ABD .
C                LDA must be .GE. M + 1 .
C
C        N       INTEGER
C                the order of the matrix  A .
C
C        M       INTEGER
C                the number of diagonals above the main diagonal.
C                0 .LE. M .LT. N .
C
C     On Return
C
C        ABD     an upper triangular matrix  R , stored in band
C                form, so that  A = CTRANS(R)*R .
C
C        INFO    INTEGER
C                = 0  for normal return.
C                = K  if the leading minor of order  K  is not
C                     positive definite.
C
C     Band Storage
C
C           If  A  is a Hermitian positive definite band matrix,
C           the following program segment will set up the input.
C
C                   M = (band width above diagonal)
C                   DO 20 J = 1, N
C                      I1 = MAX0(1, J-M)
C                      DO 10 I = I1, J
C                         K = I-J+M+1
C                         ABD(K,J) = A(I,J)
C                10    CONTINUE
C                20 CONTINUE
C
C     LINPACK.  This version dated 08/14/78 .
C     Cleve Moler, University of New Mexico, Argonne National Lab.
C
C     Subroutines and Functions
C
C     BLAS CDOTC
C     Fortran AIMAG,CMPLX,CONJG,MAX0,REAL,SQRT
C***REFERENCES  DONGARRA J.J., BUNCH J.R., MOLER C.B., STEWART G.W.,
C                 *LINPACK USERS  GUIDE*, SIAM, 1979.
C***ROUTINES CALLED  CDOTC
C***END PROLOGUE  CPBFA
      INTEGER LDA,N,M,INFO
      COMPLEX ABD(LDA,*)
C
      COMPLEX CDOTC,T
      REAL S
      INTEGER IK,J,JK,K,MU
C     BEGIN BLOCK WITH ...EXITS TO 40
C
C
C***FIRST EXECUTABLE STATEMENT  CPBFA
         DO 30 J = 1, N
            INFO = J
            S = 0.0E0
            IK = M + 1
            JK = MAX0(J-M,1)
            MU = MAX0(M+2-J,1)
            IF (M .LT. MU) GO TO 20
            DO 10 K = MU, M
               T = ABD(K,J) - CDOTC(K-MU,ABD(IK,JK),1,ABD(MU,J),1)
               T = T/ABD(M+1,JK)
               ABD(K,J) = T
               S = S + REAL(T*CONJG(T))
               IK = IK - 1
               JK = JK + 1
   10       CONTINUE
   20       CONTINUE
            S = REAL(ABD(M+1,J)) - S
C     ......EXIT
            IF (S .LE. 0.0E0 .OR. AIMAG(ABD(M+1,J)) .NE. 0.0E0)
     1         GO TO 40
            ABD(M+1,J) = CMPLX(SQRT(S),0.0E0)
   30    CONTINUE
         INFO = 0
   40 CONTINUE
      RETURN
      END
