      SUBROUTINE SGEIR(A,LDA,N,V,ITASK,IND,WORK,IWORK)
C***BEGIN PROLOGUE  SGEIR
C***DATE WRITTEN   800430   (YYMMDD)
C***REVISION DATE  820801   (YYMMDD)
C***REVISION HISTORY  (YYMMDD)
C   000330  Modified array declarations.  (JEC)
C***CATEGORY NO.  D2A1
C***KEYWORDS  GENERAL SYSTEM OF LINEAR EQUATIONS,LINEAR EQUATIONS
C***AUTHOR  VOORHEES, E., (LANL)
C***PURPOSE  SGEIR solves a GENERAL single precision real
C            NXN system of linear equations.  Iterative
C            refinement is used to obtain an error
C            estimate.
C***DESCRIPTION
C
C    Subroutine SGEIR solves a general NxN system of single
C    precision linear equations using LINPACK subroutines SGEFA and
C    SGESL.  One pass of iterative refinement is used only to obtain
C    an estimate of the accuracy.  That is, if A is an NxN real
C    matrix and if X and B are real N-vectors, then SGEIR solves
C    the equation
C
C                          A*X=B.
C
C    The matrix A is first factored into upper and lower tri-
C    angular matrices U and L using partial pivoting.  These
C    factors and the pivoting information are used to calculate
C    the solution, X.  Then the residual vector is found and
C    used to calculate an estimate of the relative error, IND.
C    IND estimates the accuracy of the solution only when the
C    input matrix and the right hand side are represented
C    exactly in the computer and does not take into account
C    any errors in the input data.
C
C    If the equation A*X=B is to be solved for more than one vector
C    B, the factoring of A does not need to be performed again and
C    the option to solve only (ITASK .GT. 1) will be faster for
C    the succeeding solutions.  In this case, the contents of A,
C    LDA, N, WORK, and IWORK must not have been altered by the
C    user following factorization (ITASK=1).  IND will not be
C    changed by SGEIR in this case.
C
C  Argument Description ***
C
C    A      REAL(LDA,N)
C             the doubly subscripted array with dimension (LDA,N)
C             which contains the coefficient matrix.  A is not
C             altered by the routine.
C    LDA    INTEGER
C             the leading dimension of the array A.  LDA must be great-
C             er than or equal to N.  (terminal error message IND=-1)
C    N      INTEGER
C             the order of the matrix A.  The first N elements of
C             the array A are the elements of the first column of
C             matrix A.  N must be greater than or equal to 1.
C             (terminal error message IND=-2)
C    V      REAL(N)
C             on entry, the singly subscripted array(vector) of di-
C               mension N which contains the right hand side B of a
C               system of simultaneous linear equations A*X=B.
C             on return, V contains the solution vector, X .
C    ITASK  INTEGER
C             If ITASK=1, the matrix A is factored and then the
C               linear equation is solved.
C             If ITASK .GT. 1, the equation is solved using the existing
C               factored matrix A (stored in WORK).
C             If ITASK .LT. 1, then terminal error message IND=-3 is
C               printed.
C    IND    INTEGER
C             GT. 0  IND is a rough estimate of the number of digits
C                     of accuracy in the solution, X.  IND=75 means
C                     that the solution vector X is zero.
C             LT. 0  see error message corresponding to IND below.
C    WORK   REAL(N*(N+1))
C             a singly subscripted array of dimension at least N*(N+1).
C    IWORK  INTEGER(N)
C             a singly subscripted array of dimension at least N.
C
C  Error Messages Printed ***
C
C    IND=-1  terminal   N is greater than LDA.
C    IND=-2  terminal   N is less than one.
C    IND=-3  terminal   ITASK is less than one.
C    IND=-4  terminal   The matrix A is computationally singular.
C                         A solution has not been computed.
C    IND=-10 warning    The solution has no apparent significance.
C                         The solution may be inaccurate or the matrix
C                         A may be poorly scaled.
C
C               Note-  The above terminal(*fatal*) error messages are
C                      designed to be handled by XERRWV in which
C                      LEVEL=1 (recoverable) and IFLAG=2 .  LEVEL=0
C                      for warning error messages from XERROR.  Unless
C                      the user provides otherwise, an error message
C                      will be printed followed by an abort.
C***REFERENCES  SUBROUTINE SGEIR WAS DEVELOPED BY GROUP C-3, LOS ALAMOS
C                 SCIENTIFIC LABORATORY, LOS ALAMOS, NM 87545.
C                 THE LINPACK SUBROUTINES USED BY SGEIR ARE DESCRIBED IN
C                 DETAIL IN THE *LINPACK USERS GUIDE* PUBLISHED BY
C                 THE SOCIETY FOR INDUSTRIAL AND APPLIED MATHEMATICS
C                 (SIAM) DATED 1979.
C***ROUTINES CALLED  R1MACH,SASUM,SCOPY,SDSDOT,SGEFA,SGESL,XERROR,
C                    XERRWV
C***END PROLOGUE  SGEIR
C
      INTEGER LDA,N,ITASK,IND,IWORK(N),INFO,J
      REAL A(LDA,N),V(N),WORK(N,*),XNORM,DNORM,SDSDOT,SASUM,R1MACH
C***FIRST EXECUTABLE STATEMENT  SGEIR
      IF (LDA.LT.N)  GO TO 101
      IF (N.LE.0)  GO TO 102
      IF (ITASK.LT.1) GO TO 103
      IF (ITASK.GT.1) GO TO 20
C     MOVE MATRIX A TO WORK
      DO 10 J=1,N
        CALL SCOPY(N,A(1,J),1,WORK(1,J),1)
   10 CONTINUE
C
C     FACTOR MATRIX A INTO LU
      CALL SGEFA(WORK,N,N,IWORK,INFO)
C
C     CHECK FOR COMPUTATIONALLY SINGULAR MATRIX
      IF (INFO.NE.0)  GO TO 104
C
C     SOLVE WHEN FACTORING COMPLETE
   20 CONTINUE
C     MOVE VECTOR B TO WORK
      CALL SCOPY(N,V(1),1,WORK(1,N+1),1)
      CALL SGESL(WORK,N,N,IWORK,V,0)
C
C     FORM NORM OF X0
      XNORM=SASUM(N,V(1),1)
      IF(XNORM.NE.0.0) GO TO 30
      IND=75
      RETURN
   30 CONTINUE
C
C     COMPUTE  RESIDUAL
      DO 40 J=1,N
        WORK(J,N+1)=SDSDOT(N,-WORK(J,N+1),A(J,1),LDA,V,1)
   40 CONTINUE
C
C     SOLVE A*DELTA=R
      CALL SGESL(WORK,N,N,IWORK,WORK(1,N+1),0)
C
C     FORM NORM OF DELTA
      DNORM=SASUM(N,WORK(1,N+1),1)
C
C     COMPUTE IND (ESTIMATE OF NO. OF SIGNIFICANT DIGITS)
      IND=-INT(ALOG10(AMAX1(R1MACH(4),DNORM/XNORM)))
C
C     CHECK FOR IND GREATER THAN ZERO
      IF (IND.GT.0)  RETURN
      IND=-10
      CALL XERROR( 'SGEIR ERROR (IND=-10) -- SOLUTION MAY HAVE NO SIGNIF
     1ICANCE',58,-10,0)
      RETURN
C
C     IF LDA.LT.N, IND=-1, TERMINAL XERRWV MESSAGE
  101 IND=-1
      CALL XERRWV( 'SGEIR ERROR (IND=-1) -- LDA=I1 IS LESS THAN N=I2',
     148,-1,1,2,LDA,N,0,0,0)
      RETURN
C
C     IF N.LT.1, IND=-2, TERMINAL XERRWV MESSAGE
  102 IND=-2
      CALL XERRWV( 'SGEIR ERROR (IND=-2) -- N=I1 IS LESS THAN 1',
     143,-2,1,1,N,0,0,0,0)
      RETURN
C
C     IF ITASK.LT.1, IND=-3, TERMINAL XERRWV MESSAGE
  103 IND=-3
      CALL XERRWV( 'SGEIR ERROR (IND=-3) -- ITASK=I1 IS LESS THAN 1',
     147,-3,1,1,ITASK,0,0,0,0)
      RETURN
C
C     IF SINGULAR MATRIX, IND=-4, TERMINAL XERRWV MESSAGE
  104 IND=-4
      CALL XERRWV( 'SGEIR ERROR (IND=-4) -- SINGULAR MATRIX A - NO SOLUT
     1ION',55,-4,1,0,0,0,0,0,0)
      RETURN
C
      END
