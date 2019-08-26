Module rand_mod
  Integer :: jseed=123456789, ifrst=0, nextn

Contains

  Subroutine srand(iseed)
  ! This subroutine sets the integer seed to be used with the
  ! companion RAND function to the value of ISEED.  A flag is 
  ! set to indicate that the sequence of pseudo-random numbers 
  ! for the specified seed should start from the beginning.
    jseed=iseed
    ifrst=0
    Return
  End Subroutine srand

  Function rand()
  ! This function returns a pseudo-random number for each invocation.
  ! It is a FORTRAN 77 adaptation of the "Integer Version 2" minimal 
  ! standard number generator whose Pascal code appears in the article:
  !   Park, Steven K. and Miller, Keith W., "Random Number Generators: 
  !   Good Ones are Hard to Find", Communications of the ACM, 
  !   October, 1988.
    Real (kind=8) ::rand
    Integer, Parameter :: mplier=16807,modlus=2147483647,mobymp=127773,momdmp=2836
    Integer :: hvlue,lvlue,testv

    If (ifrst == 0) Then
       nextn=jseed
       ifrst=1
    End If
    hvlue = nextn/mobymp
    lvlue = mod(nextn,mobymp)
    testv = mplier*lvlue - momdmp*hvlue
    If (testv > 0) Then
        nextn=testv
    Else
        nextn = testv + modlus
    End If
    rand = dble(nextn)/dble(modlus)
    return
  End Function rand

End module rand_mod
