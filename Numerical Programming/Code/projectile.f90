!================================================================================================
! projectile.f90
! Justin Gabrielle A. Manay
! COMPHY2, Physics Department, De La Salle University
! This program plots the trajectory of a projectile computed using Euler's method.
! Assumptions:
! - projectile is thrown from the ground
! - projectile is thrown with initial velocity specified by user
! - air resistance is present and drag coefficient is specified by user
!================================================================================================

program projectile

    implicit none
    !--------------------------------------------------------------------------------------------
    ! Declare variables
    integer :: i = 1
    real*16 :: drag, step, v_0, theta, mass, PI, g = 9.8
    real*16, dimension(5000) :: time_array, x_array, y_array, vx_array, vy_array
    !--------------------------------------------------------------------------------------------

    !--------------------------------------------------------------------------------------------
    ! User input
    write(*,*) "Please specify the following values: "

    write(*,"(a28, 1x)", advance = "no") "initial velocity (in m/s) = "
    read(*,*) v_0

    write(*,"(a30, 1x)", advance = "no") "angle of throw (in degrees) = "
    read(*,*) theta

    ! Convert to radians
    PI = 4 * atan(1.0)
    theta = theta / 180 * PI

    write(*,"(a28, 1x)", advance = "no") "drag coefficient (in 1/m) = "
    read(*,*) drag

    write(*,"(a29, 1x)", advance = "no") "mass of projectile (in kg) = "
    read(*,*) mass

    write(*,"(a19, 1x)", advance = "no") "time step (in s) = "
    read(*,*) step
    !--------------------------------------------------------------------------------------------

    !--------------------------------------------------------------------------------------------
    ! Initialize arrays
    time_array(1) = 0
    x_array(1) = 0
    y_array(1) = 0
    vx_array(1) = v_0 * cos(theta)
    vy_array(1) = v_0 * sin(theta)
    !--------------------------------------------------------------------------------------------

    !--------------------------------------------------------------------------------------------
    ! Implement Euler's method, write to .csv file
    open(1, file = "plot.dat", status = "new")
    write(1,*) "time,x,y"
    write(1,*) ""
    write(1,*) time_array(i), ",", x_array(i), ",", y_array(i)

    do while(0 == 0)
        time_array(i + 1) = time_array(i) + step

        x_array(i + 1) = x_array(i) + vx_array(i) * step
        y_array(i + 1) = y_array(i) + vy_array(i) * step

        vx_array(i + 1) = vx_array(i) - (drag * v_0 * vx_array(i) / mass) * step
        vy_array(i + 1) = vy_array(i) - (g + (drag * v_0 * vy_array(i) / mass)) * step

        write(1,*) time_array(i + 1), ",", x_array(i + 1), ",", y_array(i + 1)

        if(y_array(i + 1) <= 0) then
            stop
        end if

        i = i + 1
    end do

    close(1)
    !--------------------------------------------------------------------------------------------

end program projectile
