!================================================================================================
! COMPHY3_Newton_Divided_Linear.f90
! Justin Gabrielle A. Manay
! COMPHY3, Physics Department, De La Salle University
! This program interpolates the polynomial for a given set of points using Newton's divided difference
! method.
! This program only uses three points (quadratic interpolation).
!================================================================================================

program ndd_quadratic

    implicit none
    !--------------------------------------------------------------------------------------------
    ! Declare variables
    integer :: n, i, j, confirmed = 0
    real*16 :: point, prod = 1.0, total = 0.0
    real*16, dimension(6) :: t, v
    real*16, dimension(:), allocatable :: t2, v2, coeff
    !--------------------------------------------------------------------------------------------

    !--------------------------------------------------------------------------------------------
    ! Use quadratic interpolation
    n = 3
    !--------------------------------------------------------------------------------------------

    !--------------------------------------------------------------------------------------------
    ! Allocate n
    allocate(t2(n))
    allocate(v2(n))
    allocate(coeff(n))
    !--------------------------------------------------------------------------------------------

    !--------------------------------------------------------------------------------------------
    ! Specify values for t and v(t)
    t = (/ 0.0, 10.0, 15.0, 20.0, 22.5, 30.0 /)
    v = (/ 0.0, 227.04, 362.78, 517.35, 602.97, 901.67 /)
    !--------------------------------------------------------------------------------------------

    !--------------------------------------------------------------------------------------------
    ! Ask users for interpolation point
    do while(confirmed /= 1)
    point = 0
    write(*,"(a44, 1x)", advance = "no") "At what point would you like to interpolate?"
    read(*,*) point
        if(point < 0 .or. point > 30) then
            write(*,*) "The value is out of range. Try again"
        else
            confirmed = 1
        end if
    end do
    !--------------------------------------------------------------------------------------------

    !--------------------------------------------------------------------------------------------
    ! Find appropriate values
    do i = 1, 6
        if(point <= t(i)) then
            if(i == 6) then
                t2(1) = t(i - 2)
                t2(2) = t(i - 1)
                t2(3) = t(i)
                v2(1) = v(i - 2)
                v2(2) = v(i - 1)
                v2(3) = v(i)
!                write(*,*) i - 2, i - 1, i
            else if(i == 2) then
                t2(1) = t(i - 1)
                t2(2) = t(i)
                t2(3) = t(i + 1)
                v2(1) = v(i - 1)
                v2(2) = v(i)
                v2(3) = v(i + 1)
!                write(*,*) i - 1, i, i + 1
            else
                if(t(i - 1) - t(i) <= t(i + 1) - t(i)) then
                    if(t(i - 2) - t(i) <= t(i + 1) - t(i)) then
                        t2(1) = t(i - 2)
                        t2(2) = t(i - 1)
                        t2(3) = t(i)
                        v2(1) = v(i - 2)
                        v2(2) = v(i - 1)
                        v2(3) = v(i)
!                        write(*,*) i - 2, i - 1, i
                    else
                        t2(1) = t(i - 1)
                        t2(2) = t(i)
                        t2(3) = t(i + 1)
                        v2(1) = v(i - 1)
                        v2(2) = v(i)
                        v2(3) = v(i + 1)
!                        write(*,*) i - 1, i, i + 1
                    end if
                else
                    if(t(i + 2) - t(i) <= t(i + 1) - t(i)) then
                        t2(1) = t(i)
                        t2(2) = t(i + 1)
                        t2(3) = t(i + 2)
                        v2(1) = v(i)
                        v2(2) = v(i + 1)
                        v2(3) = v(i + 2)
!                        write(*,*) i, i + 1, i + 2
                    else
                        t2(1) = t(i - 1)
                        t2(2) = t(i)
                        t2(3) = t(i + 1)
                        v2(1) = v(i - 1)
                        v2(2) = v(i)
                        v2(3) = v(i + 1)
!                        write(*,*) i - 1, i, i + 1
                    end if
                end if
            exit
            end if
        else if(point == t(i)) then
            !floating point error
            write(*,*) "The value of your chosen point at the interpolating polynomial is: ", v(i)
            stop
        end if
    end do
    !--------------------------------------------------------------------------------------------

    !--------------------------------------------------------------------------------------------
    ! Implement Newton's divided difference formula
    coeff = ndd(n, t2, v2)
    !--------------------------------------------------------------------------------------------

    !--------------------------------------------------------------------------------------------
    ! Obtain polynomial and the value of point at polynomial.
    do i = n, 1, -1
        prod = 1.0
        do j = 1, i - 1
            prod = prod * (point - t2(j))
        end do
        total = total + coeff(i) * prod
    end do
    write(*,"(a67, 1x, f10.5)") "The value of your chosen point at the interpolating polynomial is: ", total
    !--------------------------------------------------------------------------------------------

    contains
    !================================================================================================
    ! This function implements Newton's divided difference formula for a general number of points.
    !================================================================================================
        function ndd(n, x, y) result(coeff)
            !--------------------------------------------------------------------------------------------
            ! Declare variables
            integer :: n, i, j
            real*16, dimension(:), allocatable :: x, y, coeff
            real*16, dimension(:,:), allocatable :: div_diff
            !--------------------------------------------------------------------------------------------

            !--------------------------------------------------------------------------------------------
            ! Allocate n
            allocate(coeff(n))
            allocate(div_diff(n, n))
            !--------------------------------------------------------------------------------------------

            !--------------------------------------------------------------------------------------------
            ! Compute for the divided differences, storing them in array div_diff
            do i = 1, n
                div_diff(i, 1) = y(i)
            end do

            do i = 2, n
                do j = 2, i
                    div_diff(i, j) = (div_diff(i, j - 1) - div_diff(i - 1, j - 1))/(x(i) - x(i - j + 1))
                end do
            end do
            !--------------------------------------------------------------------------------------------

            !--------------------------------------------------------------------------------------------
            ! Obtain the coefficients from div_diff, storing them in array coeff
            do i = 1, n
                coeff(i) = div_diff(i, i)
            end do
            !--------------------------------------------------------------------------------------------

        end function ndd

end program ndd_quadratic

