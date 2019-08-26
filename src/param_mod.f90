
Module param_mod
  
  Integer :: nwalk,nsteps,nburn,nparam,naxis
  Integer :: iseed,is_write,nforward,npoints
  Real (kind=8) :: width
  Real (kind=8), Dimension(:,:), Allocatable :: p_lims
  Character(len=80), Dimension(:),Allocatable :: names
Contains
  
  Subroutine read_parameters(fname)
    ! Reads in the necessary parameters from "slice.param"
    Implicit None
    Character(len=80),Intent(In) :: fname
    Character(len=180) :: line
    Integer :: fid,st,i
    fid=10
    open(unit=fid,file=fname,status="old",iostat=st)
    if(st /= 0) then
      print *,"Error: read param file."
      stop
    end if
    call getdata(fid,line)
    read(line,*) nwalk
    call getdata(fid,line)
    read(line,*) nsteps
    call getdata(fid,line)
    read(line,*) nburn
    call getdata(fid,line)
    read(line,*) naxis
    call getdata(fid,line)
    read(line,*) iseed
    call getdata(fid,line)
    read(line,*) width
    call getdata(fid,line)
    read(line,*) is_write
    call getdata(fid,line)
    read(line,*) nparam
    Allocate(p_lims(1:nparam,1:2))
    Allocate(names(1:nparam))
    do i=1,nparam
      call getdata(fid,line)
      read(line,*) p_lims(i,1),p_lims(i,2),names(i)
    end do
    If (nburn < 0) Then
       nburn = nsteps
    End If
    if (iseed < 0) then
      call system_clock(count=iseed)
    end if
    write(*,"(a,i12)") "Random seed was: ",iseed
    close(unit=10)
  End Subroutine read_parameters
  
  Subroutine getdata(fid,line)
    Implicit None
    Integer :: fid,st,i
    Character (len=180) :: line
    Character (len=1) :: chr
    !this subroutine skips over blank lines and comment lines starting with "#".
    !First implemented in Potsdam, Feb, 1999
    !modified: Potsdam, Nov, 2001, by R. Wang
    !modified and converted to F90 by E. Lindsey, Nov. 2011
    chr='#'
    do while (chr.eq.'#')
      read(unit=fid,iostat=st,fmt='(a)') line
      if(st /= 0) then
        print *,"Error: getdata: read error ",st
        stop
      end if
      i=1
      chr=line(1:1)
      do while (chr.eq.' ')
        i=i+1
        if(i.gt.180) then
          !line was blank
          chr='#'
        else
          chr=line(i:i)
        end if
      end do
    end do
  End Subroutine getdata

End Module param_mod

