!================================================================================================
! lagrange_deriv.f90
! Justin Gabrielle A. Manay
! COMPHY2, Physics Department, De La Salle University
! This program calculates the derivative at a given point using the Lagrange polynomial.
!================================================================================================

program lagrange_deriv

    implicit none
    !--------------------------------------------------------------------------------------------
    ! Declare variables
    integer :: n, i, j, k, l, choice
    real*16 :: point, num = 1.0, den = 1.0, total = 0.0, l_i, l_j
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

    write(*,"(a52, 1x)", advance = "no") "At what point would you like to find the derivative?"
    read(*,*) point
    !--------------------------------------------------------------------------------------------

    !--------------------------------------------------------------------------------------------
    ! Ask user if first or second derivative will be computed
    write(*,*) "Would you like to compute the (1) first or (2) second derivative?"
    read(*,*) choice
    !--------------------------------------------------------------------------------------------

    !--------------------------------------------------------------------------------------------
    ! Implement Lagrange differentiation
    if(choice == 1) then
        do i = 1, n
            l_i = 0

            do j = 1, n
                if(j /= i) then

                    num = 1
                    do k = 1, n
                        if((k /= i) .and. (k /= j)) then
                            num = num * (point - x(k))
                        end if
                    end do

                    den = 1
                    do k = 1, n
                        if(k /= i) then
                            den = den * (x(i) - x(k))
                        end if
                    end do

                    l_i = l_i + (num / den)

                end if
            end do
            total = total + y(i) * l_i
        end do

    else if(choice == 2) then
        do i = 1, n
            l_i = 0

            do j = 1, n
                l_j = 0

                do k = 1, n
                    if((k /= i) .and. (k /= j)) then
                        num = 1
                        do l = 1, n
                            if((l /= i) .and. (l /= j) .and. (l /= k)) then
                                num = num * (point - x(l))
                            end if
                        end do

                        den = 1
                        do l = 1, n
                            if((l /= i) .and. (l /= j)) then
                                den = den * (x(i) - x(l))
                            end if
                        end do

                        l_j = l_j + (num / den)

                    end if
                end do

                if(j /= i) then
                    l_i = l_i + l_j / (x(i) - x(j))
                end if
            end do

            total = total + y(i) * l_i
        end do

    else
        write(*,*) "Try again. Please enter either 1 or 2."

    end if

    write(*,"(a57, 1x, f20.10)") "The value of the derivative at your chosen point is: ", total
    !--------------------------------------------------------------------------------------------

end program lagrange_deriv
