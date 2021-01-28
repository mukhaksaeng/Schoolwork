!=========================================================================================
! decimal_to_binary.f90
! Justin Gabrielle A. Manay
! COMPHY2, Physics Department, De La Salle University
! This program converts a number from decimal to binary.
!=========================================================================================

program decimal_to_binary

    implicit none
    !--------------------------------------------------------------------------------------------
    ! Declare variables
    real*16 :: num, frac, frac_frac
    integer :: rem, whole, frac_whole, i = 1, j = 1, k = 1, l = 1
    integer, dimension(100) :: whole_digits, frac_digits
    !--------------------------------------------------------------------------------------------

    !--------------------------------------------------------------------------------------------
    ! User input
    write(*,*) "Please enter a number in base 10."
    read(*,*) num
    write(*,*) ""
    write(*,"(a10, 2x, f20.10, 2x, a13)") "The number", num, "in binary is: "
    !--------------------------------------------------------------------------------------------

    !--------------------------------------------------------------------------------------------
    ! Separate number into fractional and non-fractional parts
    whole = int(num)
    frac = num - whole
    !--------------------------------------------------------------------------------------------

    !--------------------------------------------------------------------------------------------
    ! This converts the whole part to binary.
    do while(whole /= 0)
      rem = mod(whole, 2)
      whole = whole / 2
      whole_digits(i) = rem
      i = i + 1
    end do
    !--------------------------------------------------------------------------------------------

    !--------------------------------------------------------------------------------------------
    ! This prints out the binary representation of the whole part.
    do while(j < i)
        write(*, "(i1)", advance="no") whole_digits(i - j)
        j = j + 1
    end do
    !--------------------------------------------------------------------------------------------


    !--------------------------------------------------------------------------------------------
    ! This converts the fractional part to binary.
    do while(frac_frac /= 0)
        frac = frac * 2
        frac_whole = int(frac)
        frac_frac = frac - frac_whole
        frac = frac_frac
        frac_digits(k) = frac_whole
        k = k + 1
    end do
    !--------------------------------------------------------------------------------------------

    !--------------------------------------------------------------------------------------------
    ! This prints out the binary representation of the fractional part.
    write(*, "(a1)", advance="no") "."

    do while(l < k)
        write(*, "(i1)", advance="no") frac_digits(l)
        l = l + 1
    end do
    !--------------------------------------------------------------------------------------------

end program decimal_to_binary
