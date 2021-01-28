!================================================================================================
! COMPHY3_Linear_regression.f90
! Justin Gabrielle A. Manay
! COMPHY3, Physics Department, De La Salle University
! This program uses linear regression to determine the (linear) function passing through a given
! set of points .
!================================================================================================

program linreg

    implicit none
    !--------------------------------------------------------------------------------------------
    ! Declare variables
    integer :: i, confirmed = 0, n
    real*16 :: point, sum_x = 0, sum_x2 = 0, sum_y = 0, sum_y2 = 0, sum_xy = 0, m, b, num
    real*16, dimension(6) :: t, v
    !--------------------------------------------------------------------------------------------

    !--------------------------------------------------------------------------------------------
    ! Specify values for t and v(t)
    t = (/ 0.0, 10.0, 15.0, 20.0, 22.5, 30.0 /)
    v = (/ 0.0, 227.04, 362.78, 517.35, 602.97, 901.67 /)
    n = 6
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
    ! Find regression equation
    do i = 1, n
        sum_x = sum_x + t(i)
        sum_x2 = sum_x2 + t(i) * t(i)
        sum_y = sum_y + v(i)
        sum_y2 = sum_y2 + v(i) * v(i)
        sum_xy = sum_xy + t(i) * v(i)
    end do

    m = (n * sum_xy  -  sum_x * sum_y) / (n * sum_x2 - sum_x ** 2)
    b = (sum_y * sum_x2  -  sum_x * sum_xy) / (n * sum_x2  -  sum_x ** 2)
    !--------------------------------------------------------------------------------------------

    !--------------------------------------------------------------------------------------------
    ! Obtain polynomial and the value of point at polynomial.
    num = m * point + b
    write(*,"(a67, 1x, f10.5)") "The value of your chosen point at the interpolating polynomial is: ", num
    !--------------------------------------------------------------------------------------------

end program linreg
