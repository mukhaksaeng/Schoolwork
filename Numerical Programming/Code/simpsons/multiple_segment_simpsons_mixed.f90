!================================================================================================
! COMPHY3_Multiple_Segment_Simpsons_Mixed.f90
! Justin Gabrielle A. Manay
! COMPHY3, Physics Department, De La Salle University
! This program computes for the integral of a function using the (multiple-segment) Simpson's 3/8 rule.
!================================================================================================

program multiple_simpsons_mixed

    implicit none
    !--------------------------------------------------------------------------------------------
    ! Declare variables
    integer :: n = 100, n_1, n_2, i
    real*16 :: a = 1.0, b = 0.0, h,  dist, te, rte
    real*16, dimension(:), allocatable :: f_1_3, f_3_8
    !--------------------------------------------------------------------------------------------

    !--------------------------------------------------------------------------------------------
    ! Specify number of segments.
    write(*,*) "Please specify the number of segments."
    write(*, "(a4, 1x)", advance = "no") "n = "
    read(*,*) n
    !--------------------------------------------------------------------------------------------

    !--------------------------------------------------------------------------------------------
    ! Allocate number of segments.
    if(mod(n, 3)== 0) then
        n_1 = 0
        n_2 = 2
    else if(mod(n, 3) == 1) then
        n_1 = 4
        n_2 = n - 4
    else
        n_1 = 2
        n_2 = n - 2
    end if

!    write(*,*) n_1
!    write(*,*) n_2

    allocate(f_1_3(n_1 + 1))
    allocate(f_3_8(n_2 + 1))
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
    ! Compute for integral using Simpson's 1/3.
    h = (b - a) / n
    f_1_3(1) = fx(a)
    write(*,*) f_1_3(1)

    do i = 2, n_1 + 1
        f_1_3(i) = fx(a + (i - 1) * h)
        write(*,*) f_1_3(i)
    end do

    dist = (h/3) * (f_1_3(1) + f_1_3(n_1 + 1))

    do i = 2, n_1
        if(mod(i - 1, 2) == 0) then
            dist = dist + (2 * h / 3) * f_1_3(i)
        else
            dist = dist + (4 * h / 3) * f_1_3(i)
        end if
    end do

!    write(*, "(a37, 1x, f20.10, 1x, a7)", advance = "no") "The distance covered by the rocket is", dist, "meters."
!    write(*,*)
    !--------------------------------------------------------------------------------------------

    !--------------------------------------------------------------------------------------------
    ! Compute for integral using Simpson's 3/8.
    do i = 1, n_2 + 1
        f_3_8(i) = fx(a + (n_1 + i - 1) * h)
        write(*,*) f_3_8(i)
    end do

    dist = dist + (3 * h / 8) * (f_3_8(1) + f_3_8(n_2 + 1))

    do i = 2, n_2
        if(mod(i - 1, 3) == 0) then
            dist = dist + (3 * h / 4) * f_3_8(i)
        else
            dist = dist + (9 * h / 8) * f_3_8(i)
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

end program multiple_simpsons_mixed
