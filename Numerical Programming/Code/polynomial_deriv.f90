!================================================================================================
! polynomial_deriv.f90
! Justin Gabrielle A. Manay
! COMPHY2, Physics Department, De La Salle University
! This program calculates the derivative at a given point using the polynomial method.
!================================================================================================

program polynomial_deriv

    implicit none
    !--------------------------------------------------------------------------------------------
    ! Declare variables
    integer :: n, i, j, choice
    real*16 :: point, total = 0.0
    real*16, dimension(:,:), allocatable :: a
    real*16, dimension(:), allocatable :: x, y, coeff
    character :: confirmed
    !--------------------------------------------------------------------------------------------

    write(*,"(a29, 1x)", advance = "no") "How many points do you have?"
    read(*,*) n

    !--------------------------------------------------------------------------------------------
    ! Allocate n
    allocate(x(n))
    allocate(y(n))
    allocate(coeff(n))
    allocate(a(n,n))
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
    ! Fill matrix a
    do i = 1, n
        do j = 1, n
            a(i, 1) = 1
            a(i, j) = x(i) ** (j - 1)
        end do
    end do
    !--------------------------------------------------------------------------------------------

    coeff = gaussian(n, a, y)

    !--------------------------------------------------------------------------------------------
    ! Ask user if first or second derivative will be computed
    write(*,*) "Would you like to compute the (1) first or (2) second derivative?"
    read(*,*) choice
    !--------------------------------------------------------------------------------------------

    !--------------------------------------------------------------------------------------------
    ! Compute for derivatives
    if(choice == 1) then
        do i = 1, n
            total = total + coeff(i) * (i - 1) * point ** (i - 2)
        end do
    else if(choice == 2) then
        do i = 1, n
            total = total + coeff(i) * (i - 1) * (i - 2) * point ** (i - 3)
        end do
    else
        write(*,*) "Try again. Please enter either 1 or 2."
    end if

    write(*,"(a57, 1x, f20.10)") "The value of the derivative at your chosen point is: ", total
    !--------------------------------------------------------------------------------------------

    contains
        function gaussian(n, a, b) result(x)
            !--------------------------------------------------------------------------------------------
            ! Declare variables
            integer :: n, i, j, k
            real*16 :: total
            real*16, dimension(n, n) :: a
            real*16, dimension(n) :: b, x
            !--------------------------------------------------------------------------------------------

            ! Implement Naive Gaussian algorithm

            !--------------------------------------------------------------------------------------------
            ! Forward elimination
            do k = 1, n - 1
                do i = k + 1, n
                    a(i, k) = a(i, k) / a(k, k)

                    do j = k + 1, n
                        a(i, j) = a(i, j) - a(i, k) * a(k, j)
                    end do

                    b(i) = b(i) - a(i, k) * b(k)
                end do
            end do
            !--------------------------------------------------------------------------------------------

            !--------------------------------------------------------------------------------------------
            ! Back substitution
            x(n) = b(n) / a(n, n)

            do i = n - 1, 1, -1
                total = b(i)
                do j = i + 1, n
                    total = total - a(i, j) * x(j)
                end do

                x(i) = total / a(i, i)
            end do
            !--------------------------------------------------------------------------------------------
        end function gaussian

end program polynomial_deriv
