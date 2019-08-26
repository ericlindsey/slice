Program grid
  Use calc_mod
  Use fwd_mod
  Use grid_mod
  Use param_mod
  Implicit None
  Integer :: startt,endt,rate
  Real (kind=8), Dimension(:,:), Allocatable :: models,meanmodel
  Character(len=80) :: fname
  Call system_clock(count=startt, count_rate=rate)
  !Program Initializations
  call getarg(0,fname)
  if (iargc().lt.1) then
    print *, "Usage: ",trim(fname), " slice.param"
    stop
  else
    call getarg(1,fname)
  end if
  write(*,"(a,a)") "Param file: ", trim(fname)
  Call read_parameters(fname)
  npoints=naxis ** nparam
  Allocate(models(npoints,nparam+1))
  Allocate(meanmodel(nparam,2))

  ! User Initializations
  Call fwd_init()

  !Main loop
  Call grid_search(models)

  !Output results
  Call calc_stats(models,meanmodel)
  Call write_meanmodel(meanmodel)
  if (is_write == 1) then
    Call write_all_models(models)
  end if
  
  ! Compute Run time
  Call system_clock(count=endt)
  write(*,"(f10.2,' seconds elapsed.')")1.0*(endt-startt)/rate
End Program grid
