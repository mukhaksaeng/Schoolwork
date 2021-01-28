!================================================================================================
! COMPHY3_Multiple_Segment_Simpsons_1_3.f90
! Justin Gabrielle A. Manay
! COMPHY3, Physics Department, De La Salle University
! This program computes for the integral of a function using the (multiple-segment) Simpson's 1/3 rule.
!================================================================================================

program multiple_simpsons_1_3

    implicit none
    !--------------------------------------------------------------------------------------------
    ! Declare variables
    integer :: n = 5, i
    real*16 :: a = 1.0, b = 0.0, h,  dist, te, rte
    real*16, dimension(:), allocatable :: f
    !--------------------------------------------------------------------------------------------

    !--------------------------------------------------------------------------------------------
    ! Specify number of segments.
    do while(mod(n, 2) /=  0)
        write(*,*) "Please specify the number of segments (needs to be even)"
        write(*, "(a4, 1x)", advance = "no") "n = "
        read(*,*) n
    end do

    allocate(f(n + 1))
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
    h = (b - a) / n
    f(1) = fx(a)
!    write(*,*) f(1)

    do i = 2, n + 1
        f(i) = fx(a + (i - 1) * h)
!        write(*,*) f(i)
    end do

    dist = (h/3) * (f(1) + f(n + 1))

    do i = 2, n
        if(mod(i, 2) /= 0) then
            dist = dist + (2 * h / 3) * f(i)
        else
            dist = dist + (4 * h / 3) * f(i)
        end if
    end do

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

end program multiple_simpsons_1_3
