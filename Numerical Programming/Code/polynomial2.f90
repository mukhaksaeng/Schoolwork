!================================================================================================
! polynomial.f90
! Justin Gabrielle A. Manay
! COMPHY2, Physics Department, De La Salle University
! This program interpolates the polynomial for a given set of points using the direct method.
!================================================================================================

program polynomial

    implicit none
    !--------------------------------------------------------------------------------------------
    ! Declare variables
    integer :: n, i, j
    real*16 :: point, total = 0.0
    real*16, dimension(:,:), allocatable :: a
    real*16, dimension(:), allocatable :: x, y, coeff
    character :: confirmed
    !--------------------------------------------------------------------------------------------

    !--------------------------------------------------------------------------------------------
    ! Ask user to specify the number of data points
    write(*,"(a29, 1x)", advance = "no") "How many points do you have?"
    read(*,*) n
    !--------------------------------------------------------------------------------------------

    !--------------------------------------------------------------------------------------------
    ! Allocate n
    allocate(x(n))
    allocate(y(n))
    allocate(coeff(n))
    allocate(a(n,n))
    !--------------------------------------------------------------------------------------------

    !--------------------------------------------------------------------------------------------
    ! Ask users to specify values
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
    ! Obtain polynomial and the value of point at polynomial.
    write(*,*)
    write(*,*) "y = "
    do i = 1, n
        write(*,*)coeff(i), "* x ^", (i - 1), " + "
    end do
    !--------------------------------------------------------------------------------------------

    contains
    !================================================================================================
    ! This function implements the Naive Gaussian elimination algorithm.
    !================================================================================================
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

end program polynomial
