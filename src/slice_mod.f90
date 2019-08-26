Module slice_mod
  
  Real (kind=8),Private :: fwd

Contains

  Subroutine num_forwards()
    Use param_mod
    Implicit None
    Integer :: nstep
    nstep = nwalk*(nsteps+nburn)*nparam
    write (*,"(a,f12.4)") "Ratio of forwards/steps:", &
         real(nforward)/real(nstep)
  End Subroutine num_forwards
  
  Subroutine slice_walks(models)
    Use param_mod
    Implicit None
    Real (kind=8),Dimension(:,:) :: models
    Real (kind=8),Dimension(nparam) :: point
    Integer :: walknum,i,j,iten,debug
    debug=0
    !find 10 percent marks
    iten=int(ceiling(nwalk/10.0))
    write(*,"(a)") "Starting walks:"
    Do walknum=1,nwalk
      ! starting point
      point=random_point()
      ! first steps dropped due to burn-in; keep all steps if burn=0
      If (nburn > 0) then
        Do i=1,nburn
          Do j=1,nparam
            point=next_point(point,j,p_lims(j,1),p_lims(j,2),0)
          End Do
        End Do
      End If
      Do i=1,nsteps
        Do j=1,nparam
          point=next_point(point,j,p_lims(j,1),p_lims(j,2),0)
          models(nsteps*(walknum-1)+i,j)=real(point(j))
        End Do
        ! for slice, we don't track the value of fwd (thogh we could), 
        ! the extra column is needed to make calc_stats compatible with grid search.
        models(nsteps*(walknum-1)+i,nparam+1) = 1.0d0
      End Do
      If (mod(walknum,iten) == 0) write(*,"(a,i6,a4,i6,a2,i3,a7)"), &
        'Finished walk ',walknum,' of ',nwalk,': ',int(real(walknum)/real(nwalk)*100), &
        '% done.'
    End Do
    write(*,"(a)"),'Done!'
  End Subroutine slice_walks

  Function random_point()
    !Generates a random (n-D) point inside the specified bounds
    Use fwd_mod
    Use param_mod
    Use rand_mod
    Implicit None
    Real (kind=8),Dimension(nparam) :: random_point,point
    Real (kind=8) :: random
    Integer :: i
    Do i=1,nparam
       ! each parameter gets a random real in (min,max)
       random=rand()
       point(i) = p_lims(i,1) + &
         random*(p_lims(i,2)-p_lims(i,1))
    End Do
    Call forward(point,fwd)
    random_point=point
  End Function random_point
    
  Function next_point(point,xindex,xmin,xmax,debug)
    Use fwd_mod
    Use param_mod
    Use rand_mod
    Implicit None
    Integer,Intent(In) :: xindex,debug
    Real (kind=8),Intent(In) :: xmin,xmax
    Real (kind=8),Dimension(nparam) :: point, new_point, next_point
    Real (kind=8) :: y,xl,xr,xnew,xold,random

    !Note: this function updates only one dimension, but it still needs the
    !  whole (n-D) point in order to call the forward model
    new_point = point
    xold=point(xindex)

    !Step 1. Generate a random vertical height y between 0 and fwd(x0).
    !note, fwd is already known from the last iteration.

    ! We are working with the (negative) log of the pdf here; fwd=-log(p(x)).
    ! So, we need y distributed such that e^(-y) is distributed uniformly
    ! on [0,p(x)]. Thus, y has an exponential distribution, plus an additional constant (prove it yourself!)
    ! rand_exp=(-1/k)*log(1-rand_normal)
    random=rand()
    ! could also be: y = fwd - log(random)
    y = fwd - 1.0d0*log(1.0d0-random)

    !Step 2. Determine horizontal interval xl-xr to sample from.
    !        Starts with a random interval containing x.
    !call random_number(random)
    random=rand()
    if (random < 0.5) then
       random=rand()
       xl = max(xmin,point(xindex) - random*width)
       xr = min(xmax,xl + width)
    else
       random=rand()
       xr = min(xmax,point(xindex) + random*width)
       xl = max(xmin,xr - width)
    end if

    ! Step the sides out in units of width until fwd is worse (larger -- recall we took the negative logarithm of the pdf) than y.
    new_point(xindex)=xr
    Call forward(new_point,fwd)
    do while (fwd < y)
       xr = xr + width
       if (xr > xmax) then
          xr=xmax
          exit
       end if
       new_point(xindex)=xr
       Call forward(new_point,fwd)
    end do
    new_point(xindex)=xl
    Call forward(new_point,fwd)
    do while (fwd < y)
       xl = xl - width
       if (xl < xmin) then
          xl=xmin
          exit
       end if
       new_point(xindex)=xl
       Call forward(new_point,fwd)
    end do

    !Step 3. Draw a random point in the range xl-xr.  If fwd(x)
    !        is greater than y, narrow the range and try again.
    random=rand()
    if (random < 0.5) then
       random=rand()
       xnew = xl + random*(xr-xl)
    else
       random=rand()
       xnew = xr - random*(xr-xl)
    end if
    new_point(xindex)=xnew
    Call forward(new_point,fwd)
    do while (fwd > y)
       if (xnew < xold) then
          xl=xnew
       else 
          xr=xnew
       end if
       random=rand()

       if (random < 0.5) then
          random=rand()
          xnew = xl + random*(xr-xl)
       else
          random=rand()
          xnew = xr - random*(xr-xl)
       end if
       new_point(xindex)=xnew
       Call forward(new_point,fwd)
    end do
    next_point=new_point
  End Function next_point

End Module slice_mod
