!================================================================================================
! newton.f90
! Justin Gabrielle A. Manay
! COMPHY2, Physics Department, De La Salle University
! This program calculates the roots of a nonlinear equation using the Newton-Raphson method.
!================================================================================================

program newton

    implicit none

    !--------------------------------------------------------------------------------------------
    ! Declare variables.
    integer :: i = 1
    real*16 :: x, error = 0.5, tol = 1e-10
    real*16, dimension(100) :: x_array
    !--------------------------------------------------------------------------------------------

    !--------------------------------------------------------------------------------------------
    ! User input
    write(*,*) "Please specify your estimate of the root."
    write(*, "(a15)", advance = "no") "estimate = "
    read(*,*) x
    !--------------------------------------------------------------------------------------------

    !--------------------------------------------------------------------------------------------
    ! This implements the Newton-Raphson method.
    ! This also prints out x, f(x), f'(x) and the RAE per iteration.

    ! Check if root is at the estimate.
    if(abs(fx(x)) < tol) then
        write(*,*) "The root is at x = ", x
        call exit
    end if

    write(*,"(a20, 2x, a20, 2x, a20, 2x, a20)") "x", "f(x)", "f'(x)", "error"

    do while(error > tol .or. abs(fx(x)) > tol)

        ! Initialize
        x_array(i) = x

        ! Compute error
        if(i > 1) then
            error = abs((x_array(i) - x_array(i - 1))/x_array(i))
        end if

        ! Print results
        if(i == 1) then
            write(*,"(f20.10, 2x, f20.10, 2x, f20.10, 2x, a20)") x, fx(x), deriv(x), "-"
        else
            write(*,"(f20.10, 2x, f20.10, 2x, f20.10, 2x, f20.10)") x, fx(x), deriv(x), error
        end if

        ! Evaluate new x
        x = x - (fx(x) / deriv(x))

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
    ! These functions specify the nonlinear equation to be solved and its first derivative.
    ! In this case, it is x^3 - 9*x^2 + 36*x - 80. Edit if needed.
    !================================================================================================
        function fx(j) result(fxeval)
            real*16 :: j, fxeval

            fxeval = j**3 - 9*j**2 + 36*j - 80
        end function fx

        function deriv(j) result(deriveval)
            real*16 :: j, deriveval

            deriveval = 3*j**2 - 18*j + 36
        end function deriv

end program newton
