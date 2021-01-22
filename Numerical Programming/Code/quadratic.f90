!================================================================================================
! quadratic.f90
! Justin Gabrielle A. Manay
! COMPHY2, Physics Department, De La Salle University
! This program calculates the roots of a quadratic equation of the form a*x^2 + b*x + c = 0
!================================================================================================

program quadratic

    implicit none

    !--------------------------------------------------------------------------------------------
    ! Declare variables
    complex :: a, b, c, r1, r2
    !--------------------------------------------------------------------------------------------

    !--------------------------------------------------------------------------------------------
    ! User input
    write(*,*) "The quadratic equation is of the form a*x^2 + b*x + c"
    write(*,*) "Please specify your values for a, b and c in the form (real part, complex part)"
    write(*,*) "For example, (2,3) for 2 + 3*i"
    write(*, "(a4)", advance = "no") "a = "
    read(*,*) a
    write(*, "(a4)", advance = "no") "b = "
    read(*,*) b
    write(*, "(a4)", advance = "no") "c = "
    read(*,*) c
    write(*,*)
    !--------------------------------------------------------------------------------------------

    !--------------------------------------------------------------------------------------------
    ! Apply the quadratic formula
    r1 = (-b + sqrt(b ** 2 - 4.0 * a * c))/(2.0 *a)
    r2 = (-b - sqrt(b ** 2 - 4.0 * a * c))/(2.0 *a)
    !--------------------------------------------------------------------------------------------

    !--------------------------------------------------------------------------------------------
    ! Print out results
    write(*,*) "The roots of the above quadratic equation are: "

    if(imag(r1) < 0) then
        write(*,"(f10.5, 1x, a1, 1x, f10.5, 1x, a2)") real(r1), "-", -imag(r1), "*i"
    else
        write(*,"(f10.5, 1x, a1, 1x, f10.5, 1x, a2)") real(r1), "+", imag(r1), "*i"
    end if

    if(imag(r2) < 0) then
        write(*,"(f10.5, 1x, a1, 1x, f10.5, 1x, a2)") real(r2), "-", -imag(r2), "*i"
    else
        write(*,"(f10.5, 1x, a1, 1x, f10.5, 1x, a2)") real(r2), "+", imag(r2), "*i"
    end if
    !--------------------------------------------------------------------------------------------

end program quadratic
