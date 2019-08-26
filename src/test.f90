Module fwd_mod
    Integer :: nr, nc
    Real (kind=8), Dimension(:), Allocatable :: dat,xdata,weights
Contains

  !Load problem-specific parameters and initializations here
  Subroutine fwd_init()
    Use param_mod
    Use array_io
    Implicit None
    Character (len=80):: fname,datfile
    Character (len=180):: line
    Real (kind=8), Dimension(:,:), Allocatable :: input_data
    Integer :: fid,st
    fid=10
    fname="fwd.param"
    open(unit=fid,file=fname,status="old",iostat=st)
    if(st /= 0) then
      print *,"Error: read fwd.param file."
      stop
    end if
    call getdata(fid,line)
    read(line,"(a)") datfile
    call readarray(datfile,input_data,nr,nc)
    !in this example, "datfile" contains x,y,sigma values for use in line-fitting
    !your problem may require any number of data columns, or other information
    Allocate(xdata(nr),dat(nr),weights(nr))
    if (nc<2 .or. nc>3) then
       print *, "Incorrect number of columns in ",fname,". Exiting."
       stop
    else if(nc == 2) then
       print *, "Warning: ",fname," should contain 3 columns (x,y,sigma)"
       print *, "Assuming uniform uncertainties"
       weights = 1
    else 
      !Warning: if weights are too small, all forward models will evaluate to zero
      !this problem gets even worse if you have a lot of data
      weights(:)=max(0.1,input_data(:,3)) 
    end if
    xdata(:)=input_data(:,1)
    dat(:)=input_data(:,2)
  End Subroutine fwd_init

  !Implement or call your forward model here
  !Input: model(nparam): vector of input parameters
  !Output: values(nr): vector of model values to compare with dat(nr).
  Subroutine calc_model(model,values)
    Use param_mod
    Implicit None
    Real (kind=8), Dimension(nparam), Intent(In) :: model
    Real (kind=8), Dimension(nr), Intent(Out) :: values
    !line-fitting example: y = b + m*x
    values=model(1) + model(2)*xdata
  End Subroutine calc_model

  !shouldn't need to edit below here
  !unless you want to use the full data covariance matrix
  !or change the data norm from L2
  Subroutine forward(model,fwd)
    Use param_mod
    Implicit None
    Real (kind=8), Dimension(nparam), Intent(In) :: model
    Real (kind=8), Dimension(nr) :: values
    Real (kind=8)  :: fwd
    nforward = nforward + 1
    call calc_model(model,values)
    fwd=exp(-0.5*sum(((values-dat)/weights)**2))
    !fwd=exp(-0.5*sum(model**2))
  End Subroutine forward

  Subroutine write_meanmodel(meanmodel)
    Use param_mod
    Use array_io
    Implicit None
    Real (kind=8),Dimension(nparam,2),Intent(In) :: meanmodel
    Real (kind=8),Dimension(nr,1) :: modelVals
    Real (kind=8),Dimension(nr) :: values
    Real (kind=8)  :: misf
    Character(len=80) :: fname
    call calc_model(meanmodel,modelVals(:,1))
    values(:)=modelVals(:,1) !annoying array re-dimension
    ! note, the following definition comes from forward().
    ! change it if you change your statistics type.
    misf=sum(((values-dat)/weights)**2)/real(nr)
    print *, "Misfit/N for mean model:", misf
    fname="meanmodel.dat"
    Call writearray(fname,modelVals,nr,1)
  End Subroutine write_meanmodel
  
End Module fwd_mod
