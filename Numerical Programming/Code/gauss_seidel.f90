program gauss_seidel

    implicit none

    ! Declare variables

    integer :: n, i, j, k
    real*16 :: mat_sum, store2
    real*16, dimension(:, :), allocatable :: a
    real*16, dimension(:), allocatable :: b, x, store1
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

        write(*,*) "Please confirm. Y/N"
        read(*,*) confirmed
    end do

    confirmed = "N"
    do while(confirmed /= "Y")
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

    ! initial solution
    confirmed = "N"
    do while(confirmed /= "Y")
        write(*,"(a15, 1x, i2, 1x, a10)") "Please specify", n, "constants."
        write(*,*) "These are your initial solutions."

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

    ! Make matrix diagonally dominant

    ! Debug: Check if matrix cannot be diagonally dominant.

    do i = 1, n
        mat_sum = sum(abs(a(i,:)))
        do j = 1, n
            if(mat_sum - abs(a(i,j)) <= abs(a(i,j))) then
                store1 = a(i,:)
                a(i,:) = a(j,:)
                a(j,:) = store1

                store2 = b(i)
                b(i) = b(j)
                b(j) = store2
            endif
        end do
    end do



!    do i = 1, n
!        do j = 1, n
!            write(*,"(f10.5, 3x)", advance = "no") a(i,j)
!        end do
!        write(*,*)
!    end do
!
!    do i = 1, n
!        write(*,"(f10.5)") b(i)
!    end do

    ! Implement Gauss-Seidel algorithm


end program gauss_seidel
