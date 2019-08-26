Module calc_mod
  Implicit None

Contains

  Subroutine calc_stats(models,meanmodel)
    Use array_io
    Use param_mod
    Implicit None
    Real (kind=8), Dimension(:,:),Intent(In) :: models
    Real (kind=8), Dimension(nparam,2),Intent(Out) :: meanmodel
    Integer :: i,j,k,m,n,marg2d_id
    Integer, Dimension(nparam) :: modelindex
    Real (kind=8),Dimension(naxis,nparam) :: margs1d,axis_scales
    Real (kind=8),Dimension(nparam*(nparam-1)/2,naxis,naxis) :: margs2d
    Real (kind=8),Dimension(naxis*naxis,3) :: margs2dxyz
    Character (len=80) :: fname, fid1,fid2,nstr,fmt
    Real (kind=8), Dimension(nparam) :: means,vars,dx
    Real (kind=8), Dimension(nparam,nparam) :: covars,corrs

    write(*,"(a)") "Calculating marginal pdfs..."

    ! masrgs2d is a large 3D array. With too many parameters, allocating it here 
    ! may fail, causing a seg fault if you have too many parameters. 
    ! Example command on linux to fix this:
    !   limit stacksize 15993872; unlimit datasize
    margs1d=0
    margs2d=0
    dx(:)=(p_lims(:,2)-p_lims(:,1))/real(naxis) 

    !Calculate 1-D and 2-D marginals
    Do i=1,npoints
      Do j=1,nparam
        !convert model value to an index (binning)
        !caution: bin must be centered
        modelindex(j) = min(naxis,max(1,FLOOR((models(i,j)-p_lims(j,1))/dx(j))+1))
        ! 1D marginal pdf
        margs1d(modelindex(j),j) = models(i,nparam+1) + margs1d(modelindex(j),j)
        ! 2D marginal pdf
        If (j>1) Then
          Do k=1,j-1
            !Careful: counting 2d marginals is tricky
            ! for each j, there were (j-1)*(j-2)/2 marginals already calculated
            ! so each marginal (j,k) can be given a unique ID:
            marg2d_id = k + (j-1)*(j-2)/2
            margs2d(marg2d_id,modelindex(j),modelindex(k)) = models(i,nparam+1) + &
                margs2d(marg2d_id,modelindex(j),modelindex(k))
          End Do
        End If
      End Do
    End Do

    !normalize
    Do j=1,nparam
      margs1d(:,j) = margs1d(:,j)/(sum(margs1d(:,j))*dx(j))
      Do k=1,j-1
        marg2d_id = k + (j-1)*(j-2)/2
        margs2d(marg2d_id,:,:) = margs2d(marg2d_id,:,:)/(sum(margs2d(marg2d_id,:,:))*dx(j)*dx(k))
      End Do
    End Do

    !Calculate means, variances, and write out the arrays
    ! first, write out a list of the (midpoints of) the axis bins
    fname = "axis_scales.dat"
    Do i=1,naxis
      Do j=1,nparam
        axis_scales(i,j) = p_lims(j,1) + &
          (i-0.5)*(p_lims(j,2)-p_lims(j,1))/naxis
      End Do
    End Do
    Call writearray(fname, axis_scales, naxis, nparam)

    !Calculate means, variances, and write out the arrays
    ! 1D: all one file, columns are the parameters in order
    fname = "margs1D.dat"
    Call writearray(fname, margs1d, naxis, nparam)
    
    Do i=1,nparam
      means(i)=get_mean(axis_scales(:,i),margs1D(:,i),dx(i)) 
      vars(i)=get_variance(axis_scales(:,i),margs1D(:,i),dx(i),means(i))
      corrs(i,i)=1
    End Do

    ! 2D: one file for each marginal, id represents param 
    ! increasing across (rows,columns).
    Do i=1,nparam*(nparam-1)/2
      !have to invert the indexing method above... sloppy method here
      j=2
      Do While (i > j*(j-1)/2)
        j=j+1
      End Do
      k = i - (j-1)*(j-2)/2
      write(fid1,"(i8)") j
      write(fid2,"(i8)") k
      fname = "marg2d"//trim(adjustl(fid1))//trim(adjustl(fid2))//".dat"
      Call writearray(fname, margs2d(i,:,:), naxis, naxis) 
      covars(j,k)=get_covariance(axis_scales(:,j),axis_scales(:,k), &
        margs2d(i,:,:),dx(j),dx(k),naxis,naxis,means(j),means(k))
      corrs(j,k)=covars(j,k)/sqrt(vars(j)*vars(k))
      corrs(k,j)=corrs(j,k)
      !also write margs2dxyz
      !note, j are y-indices, k  are x-indices. (eg. 'marg2d21' has j=2,k=1 and plots as p(2)=y and p(1)=x.)
      Do m=1,naxis
        !want x-values varying fastest for gnuplot
        margs2dxyz(1+(m-1)*naxis:m*naxis,1) = axis_scales(:,k) !x value (repeats entire axis each m)
        margs2dxyz(1+(m-1)*naxis:m*naxis,2) = axis_scales(m,j) !y values (constant for each m)
        Do n=1,naxis
          margs2dxyz((m-1)*naxis+n-1,3) = margs2d(i,m,n) !check this
        End Do
      End Do
      fname = "marg2d."//trim(adjustl(fid1))//"."//trim(adjustl(fid2))//".xyz"
      Call writearray(fname, margs2dxyz, naxis*naxis,3) 
    End Do
    
    print *
    print "(a)", "Param  Mean      Std Dev    Name"
    Do i=1,nparam
      print "(i4,2f10.4,a,a)",i,means(i),sqrt(vars(i)),"    ",trim(names(i))
    End Do
    print *
    print "(a)", "Correlation Matrix"
    write(nstr,"(i8)") nparam
    fmt="(4x,"//trim(adjustl(nstr))//"i8)"
    !print correlation matrix 
    print fmt, (i,i=1,nparam)
    fmt="(i4,"//trim(adjustl(nstr))//"f8.4)"
    Do i=1,nparam
       print fmt,i,(corrs(i,j),j=1,nparam)
    End Do
    print *
    fname ="correlations.dat"
    Call writearray(fname, corrs, nparam, nparam) 
    !print means and stdevs for each parameter
    meanmodel(:,1)=means
    meanmodel(:,2)=sqrt(vars)
    fname="means_stds.dat"
    Call writearray(fname, meanmodel, nparam, 2) 
  End Subroutine calc_stats

  Subroutine write_all_models(models)
    Use array_io
    Use param_mod
    Implicit None
    Real (kind=8),Dimension(:,:),Intent(In) :: models
    Character(len=80) :: fname
    fname="models.dat"
    print "(2a)", "Writing all models to file ",fname
    Call writearray(fname, models, npoints, nparam+1)
  End Subroutine write_all_models
  
  Function get_mean(x,px,dx)
    Implicit None
    Real (kind=8):: get_mean,dx,val
    Real(kind=8), Dimension(:) :: x,px
    val=sum(x*px)*dx
    get_mean=val
  End Function get_mean

  Function get_variance(x,px,dx,mean)
    Implicit None
    Real (kind=8):: get_variance,dx,mean,val
    Real(kind=8), Dimension(:) :: x,px
    val=sum((x-mean)**2*px)*dx
    get_variance=val
  End Function get_variance
  
  Function get_covariance(x,y,pxy,dx,dy,nx,ny,meanx,meany)
    Implicit None
    Real (kind=8):: get_covariance,dx,dy,meanx,meany,val
     Real(kind=8), Dimension(:) :: x,y
    Real(kind=8), Dimension(:,:) :: pxy
    Integer :: nx,ny,i,j
    val=0
    Do j=1,ny
       Do i=1,nx
          val=val+x(i)*y(j)*pxy(i,j)*dx*dy
       End Do
    End Do
    val=val-meanx*meany
    get_covariance=val
  End Function get_covariance

End Module calc_mod
