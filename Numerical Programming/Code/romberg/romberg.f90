!================================================================================================
! COMPHY3_Romberg.f90
! Justin Gabrielle A. Manay
! COMPHY3, Physics Department, De La Salle University
! This program computes for the integral of a function using the Romberg method.
!================================================================================================

program romberg

    implicit none
    !--------------------------------------------------------------------------------------------
    ! Declare variables
    integer :: n, i, j
    real*16 :: a = 1.0, b = 0.0, dist, te, rte
    real*16, dimension(:,:), allocatable :: rom
    !--------------------------------------------------------------------------------------------

    !--------------------------------------------------------------------------------------------
    ! Specify number of segments.
    write(*,*) "Please specify the order of extrapolation."
    write(*, "(a4, 1x)", advance = "no") "n = "
    read(*,*) n

    allocate(rom(n + 1, n + 1))
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
    do j = 1, n + 1
        do i = 1, n + 1
            rom(i, j) = 0.0
        end do
    end do

    rom(1, 1) = trapezoid(1, a, b)

    do i = 2, n + 1
        rom(1, i) = trapezoid(2 ** (i - 1), a, b)
    end do

    do j = 2, n + 1
        do i = 1, n - j + 2
            rom(j, i) = rom(j - 1, i + 1) + ((rom(j - 1, i + 1) - rom(j - 1, i)) / (4 ** (j - 1) - 1))
        end do
    end do

!    do j = 1, n + 1
!        do i = 1, n + 1
!            write(*,*) rom(i, j)
!        end do
!        write(*,*)
!    end do

    dist = rom(n + 1, 1)

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

        function trapezoid(n, a, b) result(dist)
            !--------------------------------------------------------------------------------------------
            ! Declare variables
            integer :: n, i
            real*16 :: a, b, h, dist
            real*16, dimension(n + 1) :: f
            !--------------------------------------------------------------------------------------------

            !--------------------------------------------------------------------------------------------
            ! Compute for integral.
            h = (b - a) / n
            f(1) = fx(a)

            do i = 2, n + 1
                f(i) = fx(a + (i - 1) * h)
            end do

            dist = (h/2) * (f(1) + f(n + 1))

            do i = 2, n
                dist = dist + h * f(i)
            end do
            !--------------------------------------------------------------------------------------------
        end function trapezoid

end program romberg
