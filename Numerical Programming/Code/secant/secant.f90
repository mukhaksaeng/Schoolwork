!================================================================================================
! secant.f90
! Justin Gabrielle A. Manay
! COMPHY2, Physics Department, De La Salle University
! This program calculates the roots of a nonlinear equation using the secant method.
!================================================================================================

program secant

    implicit none
    !--------------------------------------------------------------------------------------------
    ! Declare variables
    integer :: i = 2
    real*16 :: x, error = 0.5, tol = 1e-5
    real*16, dimension(100) :: x_array
    !--------------------------------------------------------------------------------------------

    !--------------------------------------------------------------------------------------------
    ! User input
    write(*,*) "Please specify two estimates of the root."
    write(*, "(a15)", advance = "no") "estimate = "
    read(*,*) x
    x_array(1) = x

    ! Check if root is at the estimate.
    if(abs(fx(x)) < tol) then
        write(*,*) "The root is at x = ", x
        call exit
    end if

    write(*, "(a15)", advance = "no") "estimate = "
    read(*,*) x
    x_array(2) = x

    ! Check if root is at the estimate.
    if(abs(fx(x)) < tol) then
        write(*,*) "The root is at x = ", x
        call exit
    end if
    !--------------------------------------------------------------------------------------------

    !--------------------------------------------------------------------------------------------
    ! Print results
    ! This implements the secant method.
    ! This also prints out x, f(x), f'(x) and the RAE per iteration.
    write(*,"(a20, 2x, a20, 2x, a20)") "x", "f(x)", "error"
    write(*,"(f20.10, 2x, f20.10, 2x, a20)") x_array(1), fx(x_array(1)), "-"

    do while(error > tol .or. abs(fx(x)) > tol)
        ! Initialize
        x_array(i) = x

        ! Compute error
        if(i > 1) then
            error = abs((x_array(i) - x_array(i - 1))/x_array(i))
        end if

        ! Print results
        write(*,"(f20.10, 2x, f20.10, 2x, f20.10)") x, fx(x), error

        ! Evaluate new x
        x = (x_array(i - 1) * fx(x_array(i)) - x_array(i) * fx(x_array(i - 1)))/(fx(x_array(i)) - fx(x_array(i - 1)))

        ! Update counter
        i = i + 1

    end do
    !--------------------------------------------------------------------------------------------

    !--------------------------------------------------------------------------------------------
    ! Print out root
    write(*,*)
    write(*,*) "The root is at x = ", x
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

end program secant
