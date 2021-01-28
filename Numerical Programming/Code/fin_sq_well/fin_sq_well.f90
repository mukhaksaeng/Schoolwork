!================================================================================================
! Code_16_fin_sq_well.f90
! Justin Gabrielle A. Manay
! COMPHY2, Physics Department, De La Salle University
! This program computes for the energy spectrum for the odd states of a particle in a 1-D finite square well.
!================================================================================================

program fin_sq_well

    implicit none
    integer :: i, j
    real*16 :: hbar, m, L, v_0, limit, guess, step, x, tol = 1e-3

    !--------------------------------------------------------------------------------------------
    ! Initialize values.
    hbar = 0.1          !hbar (in electron mass . eV . nm^2)
    m = 1               !mass (in electron masses)
    L = 1               !length of well (in nm)
    v_0 = 8             !potential energy/depth of well (in eV)
    !--------------------------------------------------------------------------------------------

    !--------------------------------------------------------------------------------------------
    ! Search for energy eigenvalues using Newton-Raphson.
    i = 0
    limit = 10
    guess = 0.5
    step = 3

    write(*,*) "The first 10 odd states starting from a guess of E = 0.5 are: "
    do while(i < limit)
        do while(abs(fx_odd(guess)) > tol)
            guess = guess - (fx_odd(guess)/deriv_odd(guess))
        end do

        i = i + 1
        write(*,*) i, guess
        guess = guess + step
    end do
    !--------------------------------------------------------------------------------------------

    contains
    !================================================================================================
    ! These functions are necessary to use the Newton-Raphson method.
    !================================================================================================
        function fx_odd(E) result(fxeval)
            real*16 :: E, alpha, beta, fxeval
            alpha = sqrt(2 * m * E)/ hbar
            beta = sqrt(2 * m * (v_0 - E)) / hbar

            fxeval = alpha * cos(alpha * L / 2) + beta * sin(alpha * L / 2)
        end function fx_odd

        function deriv_odd(j) result(deriveval)
            real*16 :: j, deriveval, h
            h = 1e-5

            deriveval = (fx_odd(j) + fx_odd(j + h)) / h
        end function deriv_odd

end program fin_sq_well
