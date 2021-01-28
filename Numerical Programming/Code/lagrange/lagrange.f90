!================================================================================================
! lagrange.f90
! Justin Gabrielle A. Manay
! COMPHY2, Physics Department, De La Salle University
! This program interpolates the polynomial for a given set of points using the Lagrange method.
!================================================================================================

program lagrange
    implicit none
    !--------------------------------------------------------------------------------------------
    ! Declare variables
    integer :: n, i, j
    real*16 :: point, a = 1.0, b = 1.0, total = 0.0
    real*16, dimension(:), allocatable :: x, y
    character :: confirmed
    !--------------------------------------------------------------------------------------------

    !--------------------------------------------------------------------------------------------
    ! Ask user to specify number of data points
    write(*,"(a29, 1x)", advance = "no") "How many points do you have?"
    read(*,*) n
    !--------------------------------------------------------------------------------------------

    !--------------------------------------------------------------------------------------------
    ! Allocate n
    allocate(x(n))
    allocate(y(n))
    !--------------------------------------------------------------------------------------------

    !--------------------------------------------------------------------------------------------
    ! User input
    do while(confirmed /= "Y")
        write(*,*)
        write(*,"(a15, 1x, i2, 1x, a10)") "Please specify", n, "constants."
        write(*,*) "These are the values of your INDEPENDENT variables."

        do i = 1, n
            read(*,*) x(i)
        end do

        write(*,*) "Your list of independent variable values is:"
        do i = 1, n
            write(*,"(f10.5)") x(i)
        end do

        write(*,*) "Please confirm. Y/N"
        read(*,*) confirmed
    end do

    confirmed = "N"
    do while(confirmed /= "Y")
        write(*,*)
        write(*,"(a15, 1x, i2, 1x, a10)") "Please specify", n, "constants."
        write(*,*) "These are the values of your DEPENDENT variables."

        do i = 1, n
            read(*,*) y(i)
        end do

        write(*,*) "Your list of dependent variable values is:"
        write(*,"(a10, 2x, a10)") "x", "y"
        do i = 1, n
            write(*,"(f10.5, 2x, f10.5)") x(i), y(i)
        end do

        write(*,*) "Please confirm. Y/N"
        read(*,*) confirmed
    end do

    write(*,"(a44, 1x)", advance = "no") "At what point would you like to interpolate?"
    read(*,*) point
    !--------------------------------------------------------------------------------------------

    !--------------------------------------------------------------------------------------------
    ! Implement Lagrange interpolation
    do i = 1, n
        a = 1.0
        b = 1.0
        do j = 1, n
            if(j /= i) then
                a = a * (point - x(j))
                b = b * (x(i) - x(j))
            end if
        end do
        total = total + y(i) * (a / b)
    end do
    write(*,"(a67, 1x, f20.10)") "The value of your chosen point at the interpolating polynomial is: ", total
    !--------------------------------------------------------------------------------------------

end program lagrange
