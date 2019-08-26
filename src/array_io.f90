Module array_io
 !read and write arrays of Double precision data to a file.
 !readarray dynamically allocates the array based on the number of rows
 !and columns in the data (based on the first non-comment line.)
 !Eric Lindsey, 5/2012

Contains

  Subroutine readarray( fname, array, nrows, ncols )
    Implicit None
    Character (len=80), Intent (In) :: fname
    Real (kind=8), Dimension(:,:),Allocatable,Intent(Out) :: array
    Integer, Intent(Out) :: nrows, ncols
    Character (len=180) :: line
    Integer :: i,j,iunit,st
    !open file
    call get_unit(iunit)
    open(unit=iunit,file=fname,status="old",iostat=st)
    If(st/=0) then
       print *,"Error: readarray: cannot read file ",trim(fname)
       stop
    End If
    !read array dimensions: extra pass thru file...
    nrows=0
    Do
      read(unit=iunit,iostat=st,fmt='(a)') line
      line=adjustl(line)
      If ( st /= 0 ) exit
      If ( len_trim ( line ) == 0 ) cycle
      If ( line(1:1) == '#' ) cycle
      nrows=nrows+1
      If (nrows == 1) then !compute ncols from the first row of data.
        call s_word_count(line,ncols)
      End If
    End Do
    rewind(unit=iunit)
    If (nrows < 1 .or. ncols < 1) then
      print *, "Error: readarray: file contains no data"
      stop
    End If
    allocate(array(nrows,ncols))
    !read data
    i=1
    Do
      read(unit=iunit,iostat=st,fmt='(a)') line
      line=adjustl(line)
      If ( st /= 0 ) exit
      If ( len_trim ( line ) == 0 ) cycle
      If ( line(1:1) == '#' ) cycle
      read(line,*,iostat=st) (array(i,j), j=1,ncols)
      i=i+1
    End Do
    close(unit=iunit)
  End Subroutine readarray

  Subroutine writearray(fname, array, nrows, ncols)
    Implicit None
    Character (len=80),Intent(In) :: fname
    Integer,Intent(In) :: nrows, ncols
    Real (kind=8), Dimension(:,:),Intent(In) :: array
    Integer i,j,iunit,st
    Character(len=80) :: fmtStr
    write(fmtStr,"(a,i4,a)") "(", ncols, "e22.14)"
    call get_unit(iunit)
    open(unit=iunit,file=fname,status="replace",iostat=st)
    If(st/=0) then
       print *,"Error: writearray: cannot write file ",trim(fname)
       stop
    End If
    Do i = 1, nrows
       write(unit=iunit,iostat=st,fmt=fmtStr) array(i,:)
       If(st < 0) exit
    End Do
    close(unit=iunit)
  End Subroutine writearray

  Subroutine get_unit ( iunit )
  !*****************************************************************************80
  !! GET_UNIT returns a free FORTRAN unit number.
  !  Discussion:
  !    A "free" FORTRAN unit number is a value between 1 and 99 which
  !    is not currently associated with an I/O device.  A free FORTRAN unit
  !    number is needed in order to open a file with the OPEN command.
  !
  !    If IUNIT = 0, then no free FORTRAN unit could be found, although
  !    all 99 units were checked (except for units 5, 6 and 9, which
  !    are commonly reserved for console I/O).
  !
  !    Otherwise, IUNIT is a value between 1 and 99, representing a
  !    free FORTRAN unit.  Note that GET_UNIT assumes that units 5 and 6
  !    are special, and will never return those values.
  !  Licensing:
  !    This code is distributed under the GNU LGPL license.
  !  Modified:
  !    26 October 2008
  !  Author:
  !    John Burkardt
  !  Parameters:
  !    Output, integer ( kind = 4 ) IUNIT, the free unit number.
  !
    implicit none
    integer ( kind = 4 ) i
    integer ( kind = 4 ) ios
    integer ( kind = 4 ) iunit
    logical lopen
    iunit = 0
    Do i = 1, 99
      If ( i /= 5 .and. i /= 6 .and. i /= 9 ) then
        inquire ( unit = i, opened = lopen, iostat = ios )
        If ( ios == 0 ) then
          If ( .not. lopen ) then
            iunit = i
            return
          End If
        End If
      End If
    End Do
    return
  End Subroutine get_unit

  Subroutine s_word_count ( s, nword )
  !*****************************************************************************80
  !! S_WORD_COUNT counts the number of "words" in a string.
  !  Licensing:
  !    This code is distributed under the GNU LGPL license.
  !  Modified:
  !    14 April 1999
  !  Author:
  !    John Burkardt
  !  Parameters:
  !    Input, character ( len = * ) S, the string to be examined.
  !    Output, integer ( kind = 4 ) NWORD, the number of "words" in the string.
  !    Words are presumed to be separated by one or more blanks.
  !
    implicit none
    logical blank
    integer ( kind = 4 ) i
    integer ( kind = 4 ) lens
    integer ( kind = 4 ) nword
    character ( len = * )  s
    nword = 0
    lens = len ( s )
    If ( lens <= 0 ) then
      return
    End If
    blank = .true.
    Do i = 1, lens
      If ( s(i:i) == ' ' ) then
        blank = .true.
      Else If ( blank ) then
        nword = nword + 1
        blank = .false.
      End If
    End Do
    return
  End Subroutine s_word_count
End Module array_io
