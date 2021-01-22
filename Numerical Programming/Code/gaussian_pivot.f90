program gaussian_pivot

    implicit none

    ! Declare variables

    integer :: n, i, j, k
    real*16, dimension(:, :), allocatable :: a
    real*16, dimension(:), allocatable :: b, x
    character :: confirmed

    ! Ask user to specify n of matrix

    write(*,"(a47)", advance = "no") "How many unknowns will there be in the system? "
    read(*,*) n

    ! Allocate n

    allocate(a(n, n))
    allocate(b(n))
    allocate(x(n))

    ! Ask user to specify values

    do while(confirmed /= "Y")
        write(*,*)
        write(*,"(a33, 1x, i2, 1x, a1, i2, 1x, a7)") "Please specify the values of your", n, "x", n, "matrix."
        write(*,*) "These are the coefficients in your system of linear equations."
        do i = 1, n
            do j = 1, n
                read(*,*) a(i,j)
            end do
        end do

        write(*,*) "The matrix you created is:"
        do i = 1, n
            do j = 1, n
                write(*,"(f10.5, 3x)", advance = "no") a(i,j)
            end do
            write(*,*)
        end do

        write(*,*)
        write(*,*) "Please confirm. Y/N"
        read(*,*) confirmed
    end do

    confirmed = "N"
    do while(confirmed /= "Y")
        write(*,*)
        write(*,"(a15, 1x, i2, 1x, a10)") "Please specify", n, "constants."
        write(*,*) "These are the constants in your system of linear equations."

        do i = 1, n
            read(*,*) b(i)
        end do

        write(*,*) "The matrix you created is:"
        do i = 1, n
            write(*,"(f10.5)") b(i)
        end do

        write(*,*) "Please confirm. Y/N"
        read(*,*) confirmed
    end do

    ! Implement Naive Gaussian algorithm

    ! Elimination
    do k = 1, n-1
        do i = k+1, n
            a(i, k) = a(i, k) / a(k, k)
        end do

        do j = k+1, n
            do i = k+1, n
                a(i, j) = a(i, j) - a(i, k) * a(k, j)
            end do
        end do
    end do

    ! Back substitution
    do i = 1, n
        do j = 1, i-1
            b(i) = b(i) - a(i, j) * b(j)
        end do
    end do

    do i = n, 1, -1
        do j = i+1, n
            b(i) = b(i) - a(i, j) * b(j)
        end do

        b(i) = b(i) / a(i, i)
    end do

    write(*,*)
    write(*,*) "The solution to the system you specified is: "
    do i = 1, n
        write(*,"(f10.5)") b(i)
    end do

end program gaussian_pivot
