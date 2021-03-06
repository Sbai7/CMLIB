      SUBROUTINE DERKF(F,NEQ,T,Y,TOUT,INFO,RTOL,ATOL,IDID,RWORK,LRW,
     1   IWORK,LIW,RPAR,IPAR)
C***BEGIN PROLOGUE  DERKF
C***DATE WRITTEN   800501   (YYMMDD)
C***REVISION DATE  820801   (YYMMDD)
C***REVISION HISTORY  (YYMMDD)
C   000330  Modified array declarations.  (JEC)
C
C***CATEGORY NO.  I1A1A
C***KEYWORDS  DEPAC,INITIAL VALUE,ODE,ORDINARY DIFFERENTIAL EQUATIONS,
C             RKF,RUNGE-KUTTA METHODS
C***AUTHOR  WATTS, H. A., (SNLA)
C           SHAMPINE, L. F., (SNLA)
C***PURPOSE  DERKF solves initial value problems in ordinary
C            differential equations.
C***DESCRIPTION
C
C   This is the Runge-Kutta code in the package of differential equation
C   solvers DEPAC, consisting of the codes DERKF, DEABM, and DEBDF.
C   Design of the package was by L. F. Shampine and H. A. Watts.
C   It is documented in
C        SAND-79-2374 , DEPAC - Design of a User Oriented Package of ODE
C                              Solvers.
C   DERKF is a driver for a modification of the code RKF45 written by
C             H. A. Watts and L. F. Shampine
C             Sandia Laboratories
C             Albuquerque, New Mexico 87185
C
C **********************************************************************
C **             DEPAC PACKAGE OVERVIEW           **
C **************************************************
C
C        You have a choice of three differential equation solvers from
C        DEPAC.  The following brief descriptions are meant to aid you
C        in choosing the most appropriate code for your problem.
C
C        DERKF is a fifth order Runge-Kutta code.  It is the simplest of
C        the three choices, both algorithmically and in the use of the
C        code.  DERKF is primarily designed to solve non-stiff and mild-
C        ly stiff differential equations when derivative evaluations are
C        not expensive.  It should generally not be used to get high
C        accuracy results nor answers at a great many specific points.
C        Because DERKF has very low overhead costs, it will usually
C        result in the least expensive integration when solving
C        problems requiring a modest amount of accuracy and having
C        equations that are not costly to evaluate.  DERKF attempts to
C        discover when it is not suitable for the task posed.
C
C        DEABM is a variable order (one through twelve) Adams code.
C        Its complexity lies somewhere between that of DERKF and DEBDF.
C        DEABM is primarily designed to solve non-stiff and mildly stiff
C        differential equations when derivative evaluations are
C        expensive, high accuracy results are needed or answers at
C        many specific points are required.  DEABM attempts to discover
C        when it is not suitable for the task posed.
C
C        DEBDF is a variable order (one through five) backward
C        differentiation formula code.  It is the most complicated of
C        the three choices.  DEBDF is primarily designed to solve stiff
C        differential equations at crude to moderate tolerances.
C        If the problem is very stIff at all, DERKF and DEABM will be
C        quite inefficient compared to DEBDF.  However, DEBDF will be
C        inefficient compared to DERKF and DEABM on non-stiff problems
C        because it uses much more storage, has a much larger overhead,
C        and the low order formulas will not give high accuracies
C        efficiently.
C
C        The concept of stiffness cannot be described in a few words.
C        If you do not know the problem to be stiff, try either DERKF
C        or DEABM.  Both of these codes will inform you of stiffness
C        when the cost of solving such problems becomes important.
C
C **********************************************************************
C ** ABSTRACT **
C **************
C
C   Subroutine DERKF uses a Runge-Kutta-Fehlberg (4,5) method to
C   integrate a system of NEQ first order ordinary differential
C   equations of the form
C                         DU/DX = F(X,U)
C   when the vector Y(*) of initial values for U(*) at X=T is given.
C   The subroutine integrates from T to TOUT. It is easy to continue the
C   integration to get results at additional TOUT.  This is the interval
C   mode of operation.  It is also easy for the routine to return with
C   the solution at each intermediate step on the way to TOUT.  This is
C   the intermediate-output mode of operation.
C
C   DERKF uses subprograms DERKFS, DEFEHL, HSTART, VNORM, R1MACH, and
C   the error handling routine XERRWV.  The only machine dependent
C   parameters to be assigned appear in R1MACH.
C
C **********************************************************************
C ** DESCRIPTION OF THE ARGUMENTS TO DERKF (AN OVERVIEW) **
C *********************************************************
C
C   The parameters are
C
C      F -- This is the name of a subroutine which you provide to
C             define the differential equations.
C
C      NEQ -- This is the number of (first order) differential
C             equations to be integrated.
C
C      T -- This is a value of the independent variable.
C
C      Y(*) -- This array contains the solution components at T.
C
C      TOUT -- This is a point at which a solution is desired.
C
C      INFO(*) -- The basic task of the code is to integrate the
C             differential equations from T to TOUT and return an
C             answer at TOUT.  INFO(*) is an integer array which is used
C             to communicate exactly how you want this task to be
C             carried out.
C
C      RTOL, ATOL -- These quantities represent relative and absolute
C             error tolerances which you provide to indicate how
C             accurately you wish the solution to be computed.  You may
C             choose them to be both scalars or else both vectors.
C
C      IDID -- This scalar quantity is an indicator reporting what
C             the code did.  You must monitor this integer variable to
C             decide what action to take next.
C
C      RWORK(*), LRW -- RWORK(*) is a real work array of length LRW
C             which provides the code with needed storage space.
C
C      IWORK(*), LIW -- IWORK(*) is an integer work array of length LIW
C             which provides the code with needed storage space.
C
C      RPAR, IPAR -- These are real and integer parameter arrays which
C             you can use for communication between your calling
C             program and the F subroutine.
C
C  Quantities which are used as input items are
C             NEQ, T, Y(*), TOUT, INFO(*),
C             RTOL, ATOL, LRW and LIW.
C
C  Quantities which may be altered by the code are
C             T, Y(*), INFO(1), RTOL, ATOL,
C             IDID, RWORK(*) and IWORK(*).
C
C **********************************************************************
C ** INPUT -- WHAT TO DO ON THE FIRST CALL TO DERKF **
C ****************************************************
C
C   The first call of the code is defined to be the start of each new
C   problem.  Read through the descriptions of all the following items,
C   provide sufficient storage space for designated arrays, set
C   appropriate variables for the initialization of the problem, and
C   give information about how you want the problem to be solved.
C
C
C      F -- Provide a subroutine of the form
C                               F(X,U,UPRIME,RPAR,IPAR)
C             to define the system of first order differential equations
C             which is to be solved.  For the given values of X and the
C             vector  U(*)=(U(1),U(2),...,U(NEQ)) , the subroutine must
C             evaluate the NEQ components of the system of differential
C             equations  DU/DX=F(X,U)  and store the derivatives in the
C             array UPRIME(*), that is,  UPRIME(I) = * DU(I)/DX *  for
C             equations I=1,...,NEQ.
C
C             Subroutine F must not alter X or U(*).  You must declare
C             the name F in an external statement in your program that
C             calls DERKF.  You must dimension U and UPRIME in F.
C
C             RPAR and IPAR are real and integer parameter arrays which
C             you can use for communication between your calling program
C             and subroutine F.  They are not used or altered by DERKF.
C             If you do not need RPAR or IPAR, ignore these parameters
C             by treating them as dummy arguments.  If you do choose to
C             use them, dimension them in your calling program and in F
C             as arrays of appropriate length.
C
C      NEQ -- Set it to the number of differential equations.
C             (NEQ .GE. 1)
C
C      T -- Set it to the initial point of the integration.
C             You must use a program variable for T because the code
C             changes its value.
C
C      Y(*) -- Set this vector to the initial values of the NEQ solution
C             components at the initial point.  You must dimension Y at
C             least NEQ in your calling program.
C
C      TOUT -- Set it to the first point at which a solution
C             is desired.  You can take TOUT = T, in which case the code
C             will evaluate the derivative of the solution at T and
C             return.  Integration either forward in T  (TOUT .GT. T) or
C             backward in T  (TOUT .LT. T)  is permitted.
C
C             The code advances the solution from T to TOUT using
C             step sizes which are automatically selected so as to
C             achieve the desired accuracy.  If you wish, the code will
C             return with the solution and its derivative following
C             each intermediate step (intermediate-output mode) so that
C             you can monitor them, but you still must provide TOUT in
C             accord with the basic aim of the code.
C
C             The first step taken by the code is a critical one
C             because it must reflect how fast the solution changes near
C             the initial point.  The code automatically selects an
C             initial step size which is practically always suitable for
C             the problem. by using the fact that the code will not step
C             past TOUT in the first step, you could, if necessary,
C             restrict the length of the initial step size.
C
C             For some problems it may not be permissible to integrate
C             past a point TSTOP because a discontinuity occurs there
C             or the solution or its derivative is not defined beyond
C             TSTOP.  Since DERKF will never step past a TOUT point,
C             you need only make sure that no TOUT lies beyond TSTOP.
C
C      INFO(*) -- Use the INFO array to give the code more details about
C             how you want your problem solved.  This array should be
C             dimensioned of length 15 to accomodate other members of
C             DEPAC or possible future extensions, though DERKF uses
C             only the first three entries.  You must respond to all of
C             the following items which are arranged as questions.  The
C             simplest use of the code corresponds to answering all
C             questions as YES ,i.e. setting all entries of INFO to 0.
C
C        INFO(1) -- This parameter enables the code to initialize
C               itself.  You must set it to indicate the start of every
C               new problem.
C
C            **** Is this the first call for this problem ...
C                  YES -- Set INFO(1) = 0
C                   NO -- Not applicable here.
C                         See below for continuation calls.  ****
C
C        INFO(2) -- How much accuracy you want of your solution
C               is specified by the error tolerances RTOL and ATOL.
C               The simplest use is to take them both to be scalars.
C               To obtain more flexibility, they can both be vectors.
C               The code must be told your choice.
C
C            **** Are both error tolerances RTOL, ATOL scalars ...
C                  YES -- Set INFO(2) = 0
C                         and input scalars for both RTOL and ATOL
C                   NO -- Set INFO(2) = 1
C                         and input arrays for both RTOL and ATOL ****
C
C        INFO(3) -- The code integrates from T in the direction
C               of TOUT by steps.  If you wish, it will return the
C               computed solution and derivative at the next
C               intermediate step (the intermediate-output mode).
C               This is a good way to proceed if you want to see the
C               behavior of the solution.  If you must have solutions at
C               a great many specific TOUT points, this code is
C               inefficient.  The code DEABM in DEPAC handles this task
C               more efficiently.
C
C            **** Do you want the solution only at
C                 TOUT (and not at the next intermediate step) ...
C                  YES -- Set INFO(3) = 0
C                   NO -- Set INFO(3) = 1 ****
C
C      RTOL, ATOL -- You must assign relative (RTOL) and absolute (ATOL)
C             error tolerances to tell the code how accurately you want
C             the solution to be computed.  They must be defined as
C             program variables because the code may change them.  You
C             have two choices --
C                  Both RTOL and ATOL are scalars. (INFO(2)=0)
C                  Both RTOL and ATOL are vectors. (INFO(2)=1)
C             In either case all components must be non-negative.
C
C             The tolerances are used by the code in a local error test
C             at each step which requires roughly that
C                     ABS(LOCAL ERROR) .LE. RTOL*ABS(Y)+ATOL
C             for each vector component.
C             (More specifically, a maximum norm is used to measure
C             the size of vectors, and the error test uses the average
C             of the magnitude of the solution at the beginning and end
C             of the step.)
C
C             The true (global) error is the difference between the true
C             solution of the initial value problem and the computed
C             approximation.  Practically all present day codes,
C             including this one, control the local error at each step
C             and do not even attempt to control the global error
C             directly.  Roughly speaking, they produce a solution Y(T)
C             which satisfies the differential equations with a
C             residual R(T),    DY(T)/DT = F(T,Y(T)) + R(T)   ,
C             and, almost always, R(T) is bounded by the error
C             tolerances.  Usually, but not always, the true accuracy of
C             the computed Y is comparable to the error tolerances. This
C             code will usually, but not always, deliver a more accurate
C             solution if you reduce the tolerances and integrate again.
C             By comparing two such solutions you can get a fairly
C             reliable idea of the true error in the solution at the
C             bigger tolerances.
C
C             Setting ATOL=0.0 results in a pure relative error test on
C             that component.  Setting RTOL=0.0 yields a pure absolute
C             error test on that component.  A mixed test with non-zero
C             RTOL and ATOL corresponds roughly to a relative error
C             test when the solution component is much bigger than ATOL
C             and to an absolute error test when the solution component
C             is smaller than the threshold ATOL.
C
C             Proper selection of the absolute error control parameters
C             ATOL  requires you to have some idea of the scale of the
C             solution components.  To acquire this information may mean
C             you will have to solve the problem more than once.  In
C             the absence of scale information, you should ask for some
C             relative accuracy in all the components (by setting  RTOL
C             values non-zero) and perhaps impose extremely small
C             absolute error tolerances to protect against the danger of
C             a solution component becoming zero.
C
C             The code will not attempt to compute a solution at an
C             accuracy unreasonable for the machine being used.  It will
C             advise you if you ask for too much accuracy and inform
C             you as to the maximum accuracy it believes possible.
C             If you want relative accuracies smaller than about
C             10**(-8), you should not ordinarily use DERKF.  The code
C             DEABM in DEPAC obtains stringent accuracies more
C             efficiently.
C
C      RWORK(*) -- Dimension this real work array of length LRW in your
C             calling program.
C
C      LRW -- Set it to the declared length of the RWORK array.
C             You must have  LRW .GE. 33+7*NEQ
C
C      IWORK(*) -- Dimension this integer work array of length LIW in
C             your calling program.
C
C      LIW -- Set it to the declared length of the IWORK array.
C             You must have  LIW .GE. 33
C
C      RPAR, IPAR -- These are parameter arrays, of real and integer
C             type, respectively.  You can use them for communication
C             between your program that calls DERKF and the  F
C             subroutine.  They are not used or altered by DERKF.  If
C             you do not need RPAR or IPAR, ignore these parameters by
C             treating them as dummy arguments.  If you do choose to use
C             them, dimension them in your calling program and in F as
C             arrays of appropriate length.
C
C **********************************************************************
C ** OUTPUT -- AFTER ANY RETURN FROM DERKF **
C *******************************************
C
C   The principal aim of the code is to return a computed solution at
C   TOUT, although it is also possible to obtain intermediate results
C   along the way.  To find out whether the code achieved its goal
C   or if the integration process was interrupted before the task was
C   completed, you must check the IDID parameter.
C
C
C      T -- The solution was successfully advanced to the
C             output value of T.
C
C      Y(*) -- Contains the computed solution approximation at T.
C             You may also be interested in the approximate derivative
C             of the solution at T.  It is contained in
C             RWORK(21),...,RWORK(20+NEQ).
C
C      IDID -- Reports what the code did
C
C                         *** Task Completed ***
C                   reported by positive values of IDID
C
C             IDID = 1 -- A step was successfully taken in the
C                       intermediate-output mode.  The code has not
C                       yet reached TOUT.
C
C             IDID = 2 -- The integration to TOUT was successfully
C                       completed (T=TOUT) by stepping exactly to TOUT.
C
C                         *** Task Interrupted ***
C                   reported by negative values of IDID
C
C             IDID = -1 -- A large amount of work has been expended.
C                       (500 steps attempted)
C
C             IDID = -2 -- The error tolerances are too stringent.
C
C             IDID = -3 -- The local error test cannot be satisfied
C                       because you specified a zero component in ATOL
C                       and the corresponding computed solution
C                       component is zero.  Thus, a pure relative error
C                       test is impossible for this component.
C
C             IDID = -4 -- The problem appears to be stiff.
C
C             IDID = -5 -- DERKF is being used very inefficiently
C                       because the natural step size is being
C                       restricted by too frequent output.
C
C             IDID = -6,-7,..,-32  -- not applicable for this code but
C                       used by other members of DEPAC or possible
C                       future extensions.
C
C                         *** Task Terminated ***
C                   reported by the value of IDID=-33
C
C             IDID = -33 -- The code has encountered trouble from which
C                       it cannot recover.  A message is printed
C                       explaining the trouble and control is returned
C                       to the calling program.  For example, this
C                       occurs when invalid input is detected.
C
C      RTOL, ATOL -- These quantities remain unchanged except when
C             IDID = -2.  In this case, the error tolerances have been
C             increased by the code to values which are estimated to be
C             appropriate for continuing the integration.  However, the
C             reported solution at T was obtained using the input values
C             of RTOL and ATOL.
C
C      RWORK, IWORK -- Contain information which is usually of no
C             interest to the user but necessary for subsequent calls.
C             However, you may find use for
C
C             RWORK(11)--which contains the step size H to be
C                        attempted on the next step.
C
C             RWORK(12)--If the tolerances have been increased by the
C                        code (IDID = -2) , they were multiplied by the
C                        value in RWORK(12).
C
C             RWORK(20+i)--which contains the approximate derivative
C                        of the solution component Y(I).  In DERKF, it
C                        is always obtained by calling subroutine F to
C                        evaluate the differential equation using T and
C                        Y(*).
C
C **********************************************************************
C ** INPUT -- WHAT TO DO TO CONTINUE THE INTEGRATION **
C **             (CALLS AFTER THE FIRST)             **
C *****************************************************
C
C        This code is organized so that subsequent calls to continue the
C        integration involve little (if any) additional effort on your
C        part.  You must monitor the IDID parameter to determine
C        what to do next.
C
C        Recalling that the principal task of the code is to integrate
C        from T to TOUT (the interval mode), usually all you will need
C        to do is specify a new TOUT upon reaching the current TOUT.
C
C        Do not alter any quantity not specifically permitted below,
C        in particular do not alter NEQ, T, Y(*), RWORK(*), IWORK(*) or
C        the differential equation in subroutine F.  Any such alteration
C        constitutes a new problem and must be treated as such, i.e.
C        you must start afresh.
C
C        You cannot change from vector to scalar error control or vice
C        versa (INFO(2)) but you can change the size of the entries of
C        RTOL, ATOL.  Increasing a tolerance makes the equation easier
C        to integrate.  Decreasing a tolerance will make the equation
C        harder to integrate and should generally be avoided.
C
C        You can switch from the intermediate-output mode to the
C        interval mode (INFO(3)) or vice versa at any time.
C
C        The parameter INFO(1) is used by the code to indicate the
C        beginning of a new problem and to indicate whether integration
C        is to be continued.  You must input the value  INFO(1) = 0
C        when starting a new problem.  You must input the value
C        INFO(1) = 1  if you wish to continue after an interrupted task.
C        Do not set  INFO(1) = 0  on a continuation call unless you
C        want the code to restart at the current T.
C
C                         *** Following a Completed Task ***
C         If
C             IDID = 1, call the code again to continue the integration
C                     another step in the direction of TOUT.
C
C             IDID = 2, define a new TOUT and call the code again.
C                     TOUT must be different from T.  You cannot change
C                     the direction of integration without restarting.
C
C                         *** Following an Interrupted Task ***
C                     To show the code that you realize the task was
C                     interrupted and that you want to continue, you
C                     must take appropriate action and reset INFO(1) = 1
C         If
C             IDID = -1, the code has attempted 500 steps.
C                     If you want to continue, set INFO(1) = 1 and
C                     call the code again.  An additional 500 steps
C                     will be allowed.
C
C             IDID = -2, the error tolerances RTOL, ATOL have been
C                     increased to values the code estimates appropriate
C                     for continuing.  You may want to change them
C                     yourself.  If you are sure you want to continue
C                     with relaxed error tolerances, set INFO(1)=1 and
C                     call the code again.
C
C             IDID = -3, a solution component is zero and you set the
C                     corresponding component of ATOL to zero.  If you
C                     are sure you want to continue, you must first
C                     alter the error criterion to use positive values
C                     for those components of ATOL corresponding to zero
C                     solution components, then set INFO(1)=1 and call
C                     the code again.
C
C             IDID = -4, the problem appears to be stiff.  It is very
C                     inefficient to solve such problems with DERKF.
C                     Code DEBDF in DEPAC handles this task efficiently.
C                     If you are absolutely sure you want to continue
C                     with DERKF, set INFO(1)=1 and call the code again.
C
C             IDID = -5, you are using DERKF very inefficiently by
C                     choosing output points TOUT so close together that
C                     the step size is repeatedly forced to be rather
C                     smaller than necessary.  If you are willing to
C                     accept solutions at the steps chosen by the code,
C                     a good way to proceed is to use the intermediate-
C                     output mode (setting INFO(3)=1).  If you must have
C                     solutions at so many specific TOUT points, the
C                     code DEABM in DEPAC handles this task efficiently.
C                     If you want to continue with DERKF, set INFO(1)=1
C                     and call the code again.
C
C             IDID = -6,-7,..,-32  --- cannot occur with this code but
C                     used by other members of DEPAC or possible future
C                     extensions.
C
C                         *** Following a Terminated Task ***
C         If
C             IDID = -33, you cannot continue the solution of this
C                     problem.  An attempt to do so will result in your
C                     run being terminated.
C***REFERENCES  SHAMPINE L.F., WATTS H.A., *DEPAC - DESIGN OF A USER
C                 ORIENTED PACKAGE OF ODE SOLVERS*, SAND79-2374, SANDIA
C                 LABORATORIES, 1979.
C               SHAMPINE L.F., WATTS H.A.,*PRACTICAL SOLUTION OF
C                 ORDINARY DIFFERENTIAL EQUATIONS BY RUNGE-KUTTA
C                 METHODS*, SAND76-0585, SANDIA LABORATORIES, 1976.
C***ROUTINES CALLED  DERKFS,XERRWV
C***END PROLOGUE  DERKF
C
C
      LOGICAL STIFF,NONSTF
C
      DIMENSION Y(NEQ),INFO(15),RTOL(*),ATOL(*),RWORK(LRW),IWORK(LIW),
     1          RPAR(*),IPAR(*)
C
      EXTERNAL F
C
C.......................................................................
C
C  INITIALIZE A COUNTER FOR MONITORING AN INFINITE LOOP PITFALL
C
      DATA INFLOP/0/
C
C.......................................................................
C
C     CHECK FOR AN APPARENT INFINITE LOOP
C
C***FIRST EXECUTABLE STATEMENT  DERKF
      IF (INFLOP .LT. 5) GO TO 5
      IF (T .NE. RWORK(21+NEQ)) GO TO 5
      CALL XERRWV( 'DERKF -- AN APPARENT INFINITE LOOP HAS BEEN DETECTED
     1.  YOU HAVE MADE           REPEATED CALLS AT  T = (R1) AND INTEGRA
     2TION HAS NOT ADVANCED.         CHECK THE WAY YOU HAVE SET PARAMETE
     3RS FOR THE CALL TO THE             CODE, PARTICULARLY INFO(1).', 2
     446,13,2,0,0,0,1,T,0.)
      RETURN
C
C     CHECK LRW AND LIW FOR SUFFICIENT STORAGE ALLOCATION
C
    5 IDID=0
      IF (LRW .GE. 30+7*NEQ) GO TO 10
      CALL XERRWV(  'DERKF -- LENGTH OF RWORK ARRAY MUST BE AT LEAST  30
     1 + 7*NEQ.  YOU HAVE         CALLED THE CODE WITH  LRW = (I1).',
     2112,1,1,1,LRW,0,0,0.,0.)
      IDID=-33
C
   10 IF (LIW .GE. 30) GO TO 25
      CALL XERRWV( 'DERKF -- LENGTH OF IWORK ARRAY MUST BE AT LEAST  30.
     1  YOU HAVE CALLED          THE CODE WITH  LIW = (I1).',          1
     205,2,1,1,LIW,0,0,0.,0.)
      IDID=-33
C
C     COMPUTE INDICES FOR THE SPLITTING OF THE RWORK ARRAY
C
   25 KH=11
      KTF=12
      KYP=21
      KTSTAR=KYP+NEQ
      KF1=KTSTAR+1
      KF2=KF1+NEQ
      KF3=KF2+NEQ
      KF4=KF3+NEQ
      KF5=KF4+NEQ
      KYS=KF5+NEQ
      KTO=KYS+NEQ
      KDI=KTO+1
      KU=KDI+1
      KRER=KU+1
C
C **********************************************************************
C     THIS INTERFACING ROUTINE MERELY RELIEVES THE USER OF A LONG
C     CALLING LIST VIA THE SPLITTING APART OF TWO WORKING STORAGE
C     ARRAYS. IF THIS IS NOT COMPATIBLE WITH THE USERS COMPILER,
C     HE MUST USE DERKFS DIRECTLY.
C **********************************************************************
C
      RWORK(KTSTAR)=T
      IF (INFO(1) .EQ. 0) GO TO 50
      STIFF = (IWORK(25) .EQ. 0)
      NONSTF = (IWORK(26) .EQ. 0)
C
   50 CALL DERKFS(F,NEQ,T,Y,TOUT,INFO,RTOL,ATOL,IDID,RWORK(KH),
     1           RWORK(KTF),RWORK(KYP),RWORK(KF1),RWORK(KF2),RWORK(KF3),
     2           RWORK(KF4),RWORK(KF5),RWORK(KYS),RWORK(KTO),RWORK(KDI),
     3           RWORK(KU),RWORK(KRER),IWORK(21),IWORK(22),IWORK(23),
     4           IWORK(24),STIFF,NONSTF,IWORK(27),IWORK(28),RPAR,IPAR)
C
      IWORK(25)=1
      IF (STIFF) IWORK(25)=0
      IWORK(26)=1
      IF (NONSTF) IWORK(26)=0
C
      IF (IDID .NE. (-2)) INFLOP=INFLOP+1
      IF (T .NE. RWORK(KTSTAR)) INFLOP=0
C
      RETURN
      END
