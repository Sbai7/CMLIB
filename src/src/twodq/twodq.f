      SUBROUTINE TWODQ(F,N,X,Y,TOL,ICLOSE,MAXTRI,MEVALS,RESULT,
     *  ERROR,NU,ND,NEVALS,IFLAG,DATA,IWORK)
C***BEGIN PROLOGUE  TWODQ
C***DATE WRITTEN   840518   (YYMMDD)
C***REVISION DATE  840518   (YYMMDD)
C***CATEGORY NO.  D1I
C***KEYWORDS  QUADRATURE,TWO DIMENSIONAL,ADAPTIVE,CUBATURE
C***AUTHOR KAHANER,D.K.,N.B.S.
C          RECHARD,O.W.,N.B.S.
C          BARNHILL,ROBERT,UNIV. OF UTAH
C***PURPOSE  To compute the two-dimensional integral of a function
C            F over a region consisting of N triangles.
C***DESCRIPTION
C
C   This subroutine computes the two-dimensional integral of a
C   function F over a region consisting of N triangles.
C   A total error estimate is obtained and compared with a
C   tolerance - TOL - that is provided as input to the subroutine.
C   The error tolerance is treated as either relative or absolute
C   depending on the input value of IFLAG.  A 'Local Quadrature
C   Module' is applied to each input triangle and estimates of the
C   total integral and the total error are computed.  The local
C   quadrature module is either subroutine LQM0 or subroutine
C   LQM1 and the choice between them is determined by the
C   value of the input variable ICLOSE.
C
C   If the total error estimate exceeds the tolerance, the triangle
C   with the largest absolute error is divided into two triangles
C   by a median to its longest side.  The local quadrature module
C   is then applied to each of the subtriangles to obtain new
C   estimates of the integral and the error.  This process is
C   repeated until either (1) the error tolerance is satisfied,
C   (2) the number of triangles generated exceeds the input
C   parameter MAXTRI, (3) the number of integrand evaluations
C   exceeds the input parameter MEVALS, or (4) the subroutine
C   senses that roundoff error is beginning to contaminate
C   the result.
C
C   The user must specify MAXTRI, the maximum number of triangles
C   in the final triangulation of the region, and provide two
C   storage arrays - DATA and IWORK - whose sizes are at least
C   9*MAXTRI and 2*MAXTRI respectively.  The user must also
C   specify MEVALS, the maximum number of function evaluations
C   to be allowed.  This number will be effective in limiting
C   the computation only if it is less than 94*MAXTRI when LQM1
C   is specified or 56*MAXTRI when LQM0 is specified.
C
C   After the subroutine has returned to the calling program
C   with output values, it can be called again with a smaller
C   value of TOL and/or a different value of MEVALS.  The tolerance
C   can also be changed from relative to absolute
C   or vice-versa by changing IFLAG.  Unless
C   the parameters NU and ND are reset to zero the subroutine
C   will restart with the final set of triangles and output
C   values from the previous call.
C
C   ARGUMENTS:
C
C   F function subprogram defining the integrand F(u,v);
C     the actual name for F needs to be declared EXTERNAL
C     by the calling program.
C
C   N the number of input triangles.
C
C   X a 3 by N array containing the abscissae of the vertices
C     of the N triangles.
C
C   Y a 3 by N array containing the ordinates of the vertices
C     of the N triangles
C
C   TOL the desired bound on the error.  If IFLAG=0 on input,
C       TOL is interpreted as a bound on the relative error;
C       if IFLAG=1, the bound is on the absolute error.
C
C   ICLOSE an integer parameter that determines the selection
C          of LQM0 or LQM1.  If ICLOSE=1 then LQM1 is used.
C          Any other value of ICLOSE causes LQM0 to be used.
C          LQM0 uses function values only at interior points of
C          the triangle.  LQM1 is usually more accurate than LQM0
C          but involves evaluating the integrand at more points
C          including some on the boundary of the triangle.  It
C          will usually be better to use LQM1 unless the integrand
C          has singularities on the boundary of the triangle.
C
C   MAXTRI The maximum number of triangles that are allowed
C          to be generated by the computation.
C
C   MEVALS  The maximum number of function evaluations allowed.
C
C   RESULT output of the estimate of the integral.
C
C   ERROR output of the estimate of the absolute value of the
C         total error.
C
C   NU an integer variable used for both input and output.   Must
C      be set to 0 on first call of the subroutine.  Subsequent
C      calls to restart the subroutine should use the previous
C      output value.
C
C   ND an integer variable used for both input and output.  Must
C      be set to 0 on first call of the subroutine.  Subsequent
C      calls to restart the subroutine should use the previous
C      output value.
C
C   NEVALS  The actual number of function evaluations performed.
C
C   IFLAG on input:
C        IFLAG=0 means TOL is a bound on the relative error;
C        IFLAG=1 means TOL is a bound on the absolute error;
C        any other input value for IFLAG causes the subroutine
C        to return immediately with IFLAG set equal to 9.
C
C        on output:
C        IFLAG=0 means normal termination;
C        IFLAG=1 means termination for lack of space to divide
C                another triangle;
C        IFLAG=2 means termination because of roundoff noise
C        IFLAG=3 means termination with relative error <=
C                5.0* machine epsilon;
C        IFLAG=4 means termination because the number of function
C                evaluations has exceeded MEVALS.
C        IFLAG=9 means termination because of error in input flag
C
C   DATA a one dimensional array of length >= 9*MAXTRI
C        passed to the subroutine by the calling program.  It is
C        used by the subroutine to store information
C        about triangles used in the quadrature.
C
C   IWORK  a one dimensional integer array of length >= 2*MAXTRI
C          passed to the subroutine by the calling program.
C          It is used by the subroutine to store pointers
C          to the information in the DATA array.
C
C
C   The information for each triangle is contained in a nine word
C   record consisting of the error estimate, the estimate of the
C   integral, the coordinates of the three vertices, and the area.
C   These records are stored in the DATA array
C   that is passed to the subroutine.  The storage is organized
C   into two heaps of length NU and ND respectively.  The first heap
C   contains those triangles for which the error exceeds
C   epsabs*a/ATOT where epsabs is a bound on the absolute error
C   derived from the input tolerance (which may refer to relative
C   or absolute error), a is the area of the triangle, and ATOT
C   is the total area of all triangles.  The second heap contains
C   those triangles for which the error is less than or equal to
C   epsabs*a/ATOT.  At the top of each heap is the triangle with
C   the largest absolute error.
C
C   Pointers into the heaps are contained in the array IWORK.
C   Pointers to the first heap are contained
C   between IWORK(1) and IWORK(NU).  Pointers to the second
C   heap are contained between IWORK(MAXTRI+1) and
C   IWORK(MAXTRI+ND).  The user thus has access to the records
C   stored in the DATA array through the pointers in IWORK.
C   For example, the following two DO loops will print out
C   the records for each triangle in the two heaps:
C
C     DO 10 I=1,NU
C       PRINT*,(DATA(IWORK(I)+J),J=0,8)
C    10  CONTINUE
C     DO 20 I=1,ND
C       PRINT*,(DATA(IWORK(MAXTRI+I)+J),J=0,8
C    20  CONTINUE
C
C   When the total number of triangles is equal to
C   MAXTRI, the program attempts to remove a triangle from the
C   bottom of the second heap and continue.  If the second heap
C   is empty, the program returns with the current estimates of
C   the integral and the error and with IFLAG set equal to 1.
C   Note that in this case the actual number of triangles
C   processed may exceed MAXTRI and the triangles stored in
C   the DATA array may not constitute a complete triangulation
C   of the region.
C
C   The following sample program will calculate the integral of
C   cos(x+y) over the square (0.,0.),(1.,0.),(1.,1.),(0.,1.) and
C   print out the values of the estimated integral, the estimated
C   error, the number of function evaluations, and IFLAG.
C
C     REAL X(3,2),Y(3,2),DATA(450),RES,ERR
C     INTEGER IWORK(100),NU,ND,NEVALS,IFLAG
C     EXTERNAL F
C     X(1,1)=0.
C     Y(1,1)=0.
C     X(2,1)=1.
C     Y(2,1)=0.
C     X(3,1)=1.
C     Y(3,1)=1.
C     X(1,2)=0.
C     Y(1,2)=0.
C     X(2,2)=1.
C     Y(2,2)=1.
C     X(3,2)=0.
C     Y(3,2)=1.
C     NU=0
C     ND=0
C     IFLAG=1
C     CALL TWODQ(F,2,X,Y,1.E-04,1,50,4000,RES,ERR,NU,ND,
C    *  NEVALS,IFLAG,DATA,IWORK)
C     PRINT*,RES,ERR,NEVALS,IFLAG
C     END
C     FUNCTION F(X,Y)
C     F=COS(X+Y)
C     RETURN
C     END
C
C***REFERENCES  (NONE)
C
C***ROUTINES CALLED  HINITD,HINITU,HPACC,HPDEL,HPINS,LQM0,LQM1,
C                    TRIDV,R1MACH
C***END PROLOGUE  TWODQ
      integer n,iflag,nevals,iclose,nu,nd,mevals,iwork(*),maxtri
      real f,x(3,n),y(3,n),data(*),tol,result,error
      integer rndcnt
      logical full
      real a,r,e,u(3),v(3),node(9),node1(9),node2(9),
     *  epsabs,EMACH,R1MACH,ATOT,fadd,newres,newerr
      save ATOT
      external f,GREATR
      EMACH=R1MACH(4)
c
c      If heaps are empty, apply LQM to each input triangle and
c      place all of the data on the second heap.
c
      if((nu+nd).eq.0) then
      call HINITU(maxtri,9,nu,iwork)
      call HINITD(maxtri,9,nd,iwork(maxtri+1))
      ATOT=0.0
      result=0.0
      error=0.0
      rndcnt=0
      nevals=0
      do 20 i=1,n
        do 10 j=1,3
          u(j)=x(j,i)
          v(j)=y(j,i)
   10     continue
        a=0.5*abs(u(1)*v(2)+u(2)*v(3)+u(3)*v(1)
     1        -u(1)*v(3)-u(2)*v(1)-u(3)*v(2))
        ATOT=ATOT+a
        if(iclose.eq.1) then
          call LQM1(f,u,v,r,e)
          nevals=nevals+47
        else
          call LQM0(f,u,v,r,e)
          nevals=nevals+28
        end if
        result=result+r
        error=error+e
        node(1)=e
        node(2)=r
        node(3)=x(1,i)
        node(4)=y(1,i)
        node(5)=x(2,i)
        node(6)=y(2,i)
        node(7)=x(3,i)
        node(8)=y(3,i)
        node(9)=a
        call HPINS(maxtri,9,data,nd,iwork(maxtri+1),node,GREATR)
  20  continue
      end if
c
c      Check that input tolerance is consistent with
c      machine epsilon.
c
      if(iflag.eq.0) then
        if(tol.le.5.0*EMACH) then
          tol=5.0*EMACH
          fadd=3
        else
          fadd=0
        end if
        epsabs=tol*abs(result)
      else if(iflag.eq.1) then
        if(tol.le.5.0*EMACH*abs(result)) then
          epsabs=5.0*EMACH*abs(result)
        else
          fadd=0
          epsabs=tol
        end if
      else
        iflag=9
        return
      end if
c
c      Adjust the second heap on the basis of the current
c      value of epsabs.
c
   2  if(nd.eq.0) go to 40
        j=nd
   3    if(j.eq.0) go to 40
          call HPACC(maxtri,9,data,nd,iwork(maxtri+1),node,j)
          if(node(1).gt.epsabs*node(9)/ATOT) then
            call HPINS(maxtri,9,data,nu,iwork,node,GREATR)
            call HPDEL(maxtri,9,data,nd,iwork(maxtri+1),GREATR,j)
            if(j.gt.nd) j=j-1
          else
            j=j-1
          endif
        go to 3
c
c      Beginning of main loop from here to end
c
  40  if(nevals.ge.mevals) then
        iflag=4
        return
      end if
      if(error.le.epsabs) then
        if(iflag.eq.0) then
          if(error.le.abs(result)*tol) then
            iflag=fadd
            return
          else
            epsabs=abs(result)*tol
            go to 2
          end if
        else
          if(error.le.tol) then
            iflag=0
            return
          else if(error.le.5.0*EMACH*abs(result)) then
            iflag=3
            return
          else
            epsabs=5.0*EMACH*abs(result)
            go to 2
          end if
        end if
      end if
c
c      If there are too many triangles and second heap
c      is not empty remove bottom triangle from second
c      heap.  If second heap is empty return with iflag
c      set to 1 or 4.
c
      if((nu+nd).ge.maxtri) then
        full=.true.
        if(nd.gt.0) then
          iwork(nu+1)=iwork(maxtri+nd)
          nd=nd-1
        else
          iflag=1
          return
        end if
      else
        full=.false.
      end if
c
c      Find triangle with largest error, divide it in
c      two, and apply LQM to each half.
c
      if(nd.eq.0) then
        call HPACC(maxtri,9,data,nu,iwork,node,1)
        call HPDEL(maxtri,9,data,nu,iwork,GREATR,1)
      else if(nu.eq.0) then
        call HPACC(maxtri,9,data,nd,iwork(maxtri+1),node,1)
        call HPDEL(maxtri,9,data,nd,iwork(maxtri+1),GREATR,1)
      else if(data(iwork(1)).ge.data(iwork(maxtri+1))) then
        if(full) iwork(maxtri+nd+2)=iwork(nu)
        call HPACC(maxtri,9,data,nu,iwork,node,1)
        call HPDEL(maxtri,9,data,nu,iwork,GREATR,1)
      else
        if(full) iwork(nu+2)=iwork(maxtri+nd)
        call HPACC(maxtri,9,data,nd,iwork(maxtri+1),node,1)
        call HPDEL(maxtri,9,data,nd,iwork(maxtri+1),GREATR,1)
      end if
      call tridv(node,node1,node2,0.5,1)
      do 60 j=1,3
        u(j)=node1(2*j+1)
        v(j)=node1(2*j+2)
  60  continue
      if(iclose.eq.1) then
        call LQM1(f,u,v,node1(2),node1(1))
        nevals=nevals+47
      else
        call LQM0(f,u,v,node1(2),node1(1))
        nevals=nevals+28
      end if
      do 70 j=1,3
        u(j)=node2(2*j+1)
        v(j)=node2(2*j+2)
  70  continue
      if(iclose.eq.1) then
        call LQM1(f,u,v,node2(2),node2(1))
        nevals=nevals+47
      else
        call LQM0(f,u,v,node2(2),node2(1))
        nevals=nevals+28
      end if
      newerr=node1(1)+node2(1)
      newres=node1(2)+node2(2)
      if(newerr.gt.0.99*node(1)) then
        if(abs(node(2)-newres).le.1.E-04*abs(newres)) rndcnt=rndcnt+1
      end if
      result=result-node(2)+newres
      error=error-node(1)+newerr
      if(node1(1).gt.node1(9)*epsabs/ATOT) then
        call HPINS(maxtri,9,data,nu,iwork,node1,GREATR)
      else
        call HPINS(maxtri,9,data,nd,iwork(maxtri+1),node1,GREATR)
      end if
      if(node2(1).gt.node2(9)*epsabs/ATOT) then
        call HPINS(maxtri,9,data,nu,iwork,node2,GREATR)
      else
        call HPINS(maxtri,9,data,nd,iwork(maxtri+1),node2,GREATR)
      end if
      if(rndcnt.ge.20) then
        iflag=2
        return
      end if
      if(iflag.eq.0) then
        if(epsabs.lt.0.5*tol*abs(result)) then
          epsabs=tol*abs(result)
          j=nu
   5      if(j.eq.0) go to 40
          call HPACC(maxtri,9,data,nu,iwork,node,j)
          if(node(1).le.epsabs*node(9)/ATOT) then
            call HPINS(maxtri,9,data,nd,iwork(maxtri+1),node,GREATR)
            call HPDEL(maxtri,9,data,nu,iwork,GREATR,j)
            if(j.gt.nu) j=j-1
          else
            j=j-1
          end if
          go to 5
        end if
      end if
      go to 40
      end
