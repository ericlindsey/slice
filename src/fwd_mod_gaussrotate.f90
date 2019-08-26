Module fwd_mod
    Real (kind=8)  :: fwd,sigx,sigy,theta,a,b,c,xo,yo
Contains

  Subroutine fwd_init()
    Use param_mod
    Implicit None
    !write(*,"(a)") "Problem-specific initializations here!"

    !rotated gaussian
    sigx=1.5;
    sigy=0.5;
    theta=30*3.14159265/180;
    a=cos(theta)**2/sigx**2+sin(theta)**2/sigy**2
    b=-sin(2*theta)/(2*sigx**2) + sin(2*theta)**2/(2*sigy**2)
    c=sin(theta)**2/sigx**2+cos(theta)**2/sigy**2
    xo=0;
    yo=2;
  End Subroutine fwd_init

  Subroutine forward(model,fwd)
    Use param_mod
    Implicit None
    Real (kind=8), Dimension(nparam), Intent(In) :: model
    Real (kind=8)  :: fwd
    nforward = nforward + 1
   
    fwd=0.5*(a*(model(1)-xo)**2 - 2*b*(model(1)-xo)*(model(2)-yo) + c*(model(2)-yo)**2)
  End Subroutine forward

  Subroutine write_meanmodel(meanmodel)
    Use param_mod
    Use array_io
    Implicit None
    Real (kind=8),Dimension(nparam,2),Intent(In) :: meanmodel
    Real (kind=8),Dimension(nr,1) :: modelVals
    Real (kind=8)  :: fwd
    Character(len=80) :: fname
    fwd=0.5*(a*(meanmodel(1,1)-xo)**2 - 2*b*(meanmodel(1,1)-xo)*(meanmodel(2,1)-yo) + c*(meanmodel(2,1)-yo)**2)
    print *, "Chi^2/N for mean model:", (a*(meanmodel(1,1)-xo)**2 - 2*b*(meanmodel(1,1)-xo)*(meanmodel(2,1)-yo) + c*(meanmodel(2,1)-yo)**2)/real(nr)
    fname="meanmodel.dat"
    Call writearray(fname,modelVals,nr,1)
  End Subroutine write_meanmodel

End Module fwd_mod
