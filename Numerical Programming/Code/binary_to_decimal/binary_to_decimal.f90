!=========================================================================================
! binary_to_decimal.f90
! Justin Gabrielle A. Manay
! COMPHY2, Physics Department, De La Salle University
! This program converts a number from binary to decimal.
!=========================================================================================
program binary_to_decimal

    implicit none

    !--------------------------------------------------------------------------------------------
    ! Declare variables
    real*16 :: num, frac, dec_frac = 0
    integer :: whole, digit, frac_digit, dec_whole = 0, i = 0, j = 1
    !--------------------------------------------------------------------------------------------

    !--------------------------------------------------------------------------------------------
    ! User input, Print output
    write(*,*) "Please enter a number in base 2."
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
      digit = mod(whole, 10)
      whole = whole / 10
      dec_whole = dec_whole + digit * 2 ** i
      i = i + 1
    end do
    !--------------------------------------------------------------------------------------------

    !--------------------------------------------------------------------------------------------
    ! This converts the fractional part to binary.
    do while(frac /= 0)
      frac = frac * 10
      frac_digit = int(frac)
      frac = frac - frac_digit
      dec_frac = dec_frac + real(frac_digit) * 2.0 ** -j
      j = j + 1
    end do
    !--------------------------------------------------------------------------------------------

    write(*, "(f30.10)", advance="no") dec_whole + dec_frac

end program binary_to_decimal
