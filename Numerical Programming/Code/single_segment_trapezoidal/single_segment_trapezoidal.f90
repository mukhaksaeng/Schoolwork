!================================================================================================
! COMPHY3_Single_Segment_Trapezoidal.f90
! Justin Gabrielle A. Manay
! COMPHY3, Physics Department, De La Salle University
! This program computes for the integral of a function using trapezoidal rule.
!================================================================================================

program polynomial

    implicit none
    !--------------------------------------------------------------------------------------------
    ! Declare variables
    real*16 :: a, b, dist, te, rte
    !--------------------------------------------------------------------------------------------

    !--------------------------------------------------------------------------------------------
    ! Specify values for a and b
    do while(b < a)
        write(*,*) "Please specify values for a and b, a <= b."
        write(*, "(a4, 1x)", advance = "no") "a = "
        read(*,*) a
        write(*, "(a4, 1x)", advance = "no") "b = "
        read(*,*) b
    end do
    !--------------------------------------------------------------------------------------------

    !--------------------------------------------------------------------------------------------
    ! Compute for integral.
    dist = ((fx(a) + fx(b)) / 2) * (b - a)
    write(*, "(a37, 1x, f20.10, 1x, a7)", advance = "no") "The distance covered by the rocket is", dist, "meters."
    write(*,*)

    te = (integ_fx(b) - integ_fx(a)) - dist
    rte = abs((dist - (integ_fx(b) - integ_fx(a))) / (integ_fx(b) - integ_fx(a))) * 100
    write(*,"(a17, 1x, f20.10)", advance = "no") "The true value is", integ_fx(b) - integ_fx(a)
    write(*,*)

    write(*,"(a17, 1x, f20.10)", advance = "no") "The true error is", te
    write(*,*)

    write(*,"(a26, 1x, f20.10, 1x, a2)", advance = "no") "The relative true error is", rte, "%."
    !--------------------------------------------------------------------------------------------

    contains
        function fx(a) result(fx_eval)
            !--------------------------------------------------------------------------------------------
            ! Declare variables
            real*16 :: a, fx_eval
            !--------------------------------------------------------------------------------------------

            !--------------------------------------------------------------------------------------------
            ! Specify function
            fx_eval = 2000 * log(140000/(140000 - 2100 * a)) - 9.8 * a
            !--------------------------------------------------------------------------------------------
        end function fx

        function integ_fx(a) result(integ_fx_eval)
            !--------------------------------------------------------------------------------------------
            ! Declare variables
            real*16 :: a, integ_fx_eval
            !--------------------------------------------------------------------------------------------

            !--------------------------------------------------------------------------------------------
            ! Specify function
            integ_fx_eval = (2000 * a - 133333) * log(66.6667 / (66.6667 - a)) + (2000 - 4.9 * a) * a
            !--------------------------------------------------------------------------------------------
        end function integ_fx

end program polynomial

