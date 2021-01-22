!================================================================================================
! bisection.f90
! Justin Gabrielle A. Manay
! COMPHY2, Physics Department, De La Salle University
! This program calculates the roots of a nonlinear equation using the bisection method.
!================================================================================================

program bisection

    implicit none

    !--------------------------------------------------------------------------------------------
    ! Declare variables
    integer :: i = 1
    real*16 :: x_l = 1.0, x_u = 1.0, x_mid, error = 0.5, tol = 1e-10
    real*16, dimension(100) :: x_mid_array
    !--------------------------------------------------------------------------------------------

    !--------------------------------------------------------------------------------------------
    ! User input
    do while(fx(x_l) * fx(x_u) > 0)
        write(*,*) "Please specify the upper and lower limit of the interval you wish to examine."
        write(*, "(a15)", advance = "no") "lower limit = "
        read(*,*) x_l
        write(*, "(a15)", advance = "no") "upper limit = "
        read(*,*) x_u

        ! Check if root is at the endpoints.
        if(abs(fx(x_l)) < tol) then
            write(*,*) "The root is at x = ", x_l
            call exit
        else if(abs(fx(x_u)) < tol) then
            write(*,*) "The root is at x = ", x_u
            call exit
        end if

        ! Check if there is a root in the interval
        if(fx(x_l) * fx(x_u) > 0) then
            write(*,*) "The root does not exist between these two values. Try again"
            write(*,*)
        end if

    end do
    !--------------------------------------------------------------------------------------------


    !--------------------------------------------------------------------------------------------
    ! This implements the bisection method.
    ! This also prints out x_l, x_u, x_mid and the RAE per iteration.
    write(*,"(a20, 2x, a20, 2x, a20, 2x, a20)") "x_l", "x_u", "x_mid", "error"

    do while(error > tol)

        ! Evaluate midpoint
        x_mid = (x_l + x_u) / 2.0
        x_mid_array(i) = x_mid

        ! Compute error
        if(i > 1) then
            error = abs((x_mid_array(i) - x_mid_array(i - 1))/x_mid_array(i))
        end if

        ! Print results
        if(i == 1) then
            write(*,"(f20.10, 2x, f20.10, 2x, f20.10, 2x, a20)") x_l, x_u, x_mid, "-"
        else
            write(*,"(f20.10, 2x, f20.10, 2x, f20.10, 2x, f20.10)") x_l, x_u, x_mid, error
        end if

        ! Determine if root is at midpoint
        if(abs(fx(x_mid)) < tol) then
            write(*,*)
            write(*,*) "The root is at x = ", x_mid
            stop
        end if

        ! Evaluate limits
        if(fx(x_u) * fx(x_mid) < 0) then
            x_l = x_mid
        else
            x_u = x_mid
        end if

        ! Update counter
        i = i + 1

    end do
    !--------------------------------------------------------------------------------------------

    !--------------------------------------------------------------------------------------------
    ! Print out root
    write(*,*)
    write(*,*) "The root is at x = ", x_mid
    !--------------------------------------------------------------------------------------------

    contains
    !================================================================================================
    ! This function specifies the nonlinear equation to be solved. In this case, it is
    ! x^3 - 9*x^2 + 36*x - 80. Edit if needed.
    !================================================================================================
        function fx(j) result(fxeval)
            real*16 :: j, fxeval

            fxeval = j**3 - 9*j**2 + 36*j - 80
        end function fx

end program bisection
