!================================================================================================
! COMPHY3_Lagrange_Quadratic.f90
! Justin Gabrielle A. Manay
! COMPHY2, Physics Department, De La Salle University
! This program interpolates the polynomial for a given set of points using the Lagrange method.
! This program only uses two points (quadratic interpolation).
!================================================================================================

program lagrange_quadratic
    implicit none
    !--------------------------------------------------------------------------------------------
    ! Declare variables
    integer :: n, i, j, confirmed
    real*16 :: point, a = 1.0, b = 1.0, total = 0.0
    real*16, dimension(:), allocatable :: t, v
    real*16, dimension(:), allocatable :: t2, v2
    !--------------------------------------------------------------------------------------------

    !--------------------------------------------------------------------------------------------
    ! Use quadratic interpolation
    n = 3
    !--------------------------------------------------------------------------------------------

    !--------------------------------------------------------------------------------------------
    ! Allocate n
    allocate(t2(n))
    allocate(v2(n))
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
    ! Implement Lagrange interpolation
    do i = 1, n
        a = 1.0
        b = 1.0
        do j = 1, n
            if(j /= i) then
                a = a * (point - t2(j))
                b = b * (t2(i) - t2(j))
            end if
        end do
        total = total + v2(i) * (a / b)
    end do
    write(*,"(a67, 1x, f20.10)") "The value of your chosen point at the interpolating polynomial is: ", total
    !--------------------------------------------------------------------------------------------

end program lagrange_quadratic
