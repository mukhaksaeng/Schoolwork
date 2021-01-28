!================================================================================================
! fin_sq_well.f90
! Justin Gabrielle A. Manay
! COMPHY2, Physics Department, De La Salle University
! This program computes for the energy spectrum of a particle in a 1-D finite square well.
!================================================================================================

program fin_sq_well

    implicit none
    integer :: i
    real*16 :: mass, L, v_0, E1, E2, increment, PI, hbar, limit
    real*16, dimension(30) :: root_array

    PI = 4 * atan(1.0)
    hbar = 6.63e-34/(2*PI)

    write(*,*) "Please specify the following quantities for the finite square well: "

    write(*,"(a15, 1x)", advance = "no") "mass (in kg) = "
    read(*,*) mass

    write(*,"(a24, 1x)", advance = "no") "length of well (in m) = "
    read(*,*) L

    write(*,"(a23, 1x)", advance = "no") "depth of well (in J) = "
    read(*,*) v_0

    limit = 100

!    do i = 1,100000
!        E1= -v_0 + i * 0.0001
!        write(*,*) E1, fx_even(mass, L, v_0, E1), fx_odd(mass, L, v_0, E1)
!    end do

    !--------------------------------------------------------------------------------------------
    ! Search for energy eigenvalues.
    i = 0
    E1 = -9.9999

    do while(i <= limit)
        increment = 0.0001
        E2 = E1 + increment

!        if(fx_even(mass, L, v_0, E1) * fx_even(mass, L, v_0, E2) < 0) then
!            i = i + 1
!            write(*,*) i, bisection(E1, E2, fx_even)
!        end if

        if(fx_odd(mass, L, v_0, E1) * fx_odd(mass, L, v_0, E2) < 0) then
            i = i + 1
            write(*,*) i, bisection(E1, E2)
        end if

        E1 = E1 + increment
    end do
    !--------------------------------------------------------------------------------------------

    contains
    !================================================================================================
    ! These functions specify the nonlinear equations to be solved, and the bisection method.
    !================================================================================================
        function fx_even(mass, L, v_0, E) result(fxeval)
            real*16 :: mass, L, v_0, E, k, kappa, fxeval
            k = sqrt(2 * mass * (E + v_0)) / hbar
            kappa = sqrt(-2 * mass * E) / hbar

            fxeval = sin(k * L / 2) - (kappa / k) * cos(k * L / 2)
        end function fx_even

        function fx_odd(mass, L, v_0, E) result(fxeval)
            real*16 :: mass, L, v_0, E, k, kappa, fxeval
            k = sqrt(2 * mass * (E + v_0)) / hbar
            kappa = sqrt(-2 * mass * E) / hbar

            fxeval = sin(k * L / 2) + (kappa / k) * cos(k * L / 2)
        end function fx_odd

        function bisection(x_l, x_u) result(root)
            integer :: i = 1
            real*16 :: x_l, x_u, x_mid, tol = 1e-5, error, root
            real*16, dimension(100) :: x_mid_array

            ! Check if root is at the endpoints.
            if(abs(fx_odd(mass, L, v_0, x_l)) < tol) then
                root = x_l
                stop
            else if(abs(fx_odd(mass, L, v_0, x_l)) < tol) then
                root = x_u
                stop
            end if

            !--------------------------------------------------------------------------------------------
            ! This implements the bisection method.
            ! This also prints out x_l, x_u, x_mid and the RAE per iteration.
            do while(error > tol)

                ! Evaluate midpoint
                x_mid = (x_l + x_u) / 2.0
                x_mid_array(i) = x_mid

                ! Compute error
                if(i > 1) then
                    error = abs((x_mid_array(i) - x_mid_array(i - 1))/x_mid_array(i))
                end if

                ! Determine if root is at midpoint
                if(abs(fx_odd(mass, L, v_0, x_mid)) <= tol) then
                    root = x_mid
                    stop
                end if

                ! Evaluate limits
                if(fx_odd(mass, L, v_0, x_u) * fx_odd(mass, L, v_0, x_mid) < 0) then
                    x_l = x_mid

                else
                    x_u = x_mid

                end if

                ! Update counter
                i = i + 1

            end do

            root = x_mid
            !--------------------------------------------------------------------------------------------
        end function bisection

end program fin_sq_well
