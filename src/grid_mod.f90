Module grid_mod
  
  Real (kind=8),Private :: fwd

Contains

  Subroutine grid_search(models)
    Use param_mod
    Use fwd_mod
    Implicit None
    Real (kind=8),Dimension(:,:) :: models
    Real (kind=8),Dimension(nparam) :: point,dparam
    Integer :: i,j,iten,inc,rem
    !find 10 percent marks
    iten=int(ceiling(npoints/10.0))
    !calculate dx values
    dparam(:)=(p_lims(:,2)-p_lims(:,1))/real(naxis) 
    write(*,"(a)") "Starting search:"
    Call first(point,dparam)
    Do i=1,npoints
      Call forward(point,fwd)
      fwd=exp(-fwd) !convert from log(pdf) to pdf
      !update models and fwd value
      models(i,1:nparam)=point(:)
      models(i,nparam+1)=fwd
      If (mod(i,iten) == 0) write(*,"(a,i6,a4,i6,a2,i3,a7)"),'Finished step ',&
        i,' of ',npoints,': ',int(real(i)/real(npoints)*100), '% done.'
      Call next(point,dparam)
    End Do
  End Subroutine grid_search

  Subroutine first(point,dparam)
    Use param_mod
    Implicit None
    Real(kind=8), Dimension(nparam), Intent(Out) :: point
    Real(kind=8), Dimension(nparam), Intent(In) :: dparam
    Integer :: i
    Do i=1,nparam
      !use values centered in each cell
      point(i)=p_lims(i,1)+dparam(i)/2.0d0
    End Do
  End Subroutine first

  Subroutine next(point,dparam)
    Use param_mod
    Implicit None
    Real(kind=8), Dimension(nparam), Intent(InOut) :: point
    Real(kind=8), Dimension(nparam), Intent(In) :: dparam
    Real(kind=8) :: dx
    Integer :: i
    point(1)=point(1)+dparam(1)
    Do i=1,nparam-1
      If(point(i)>p_lims(i,2)) Then
        point(i)=p_lims(i,1) + dparam(i)/2.0d0
        point(i+1)=point(i+1) + dparam(i+1)
      End If
    End Do
  End Subroutine next

End Module grid_mod
