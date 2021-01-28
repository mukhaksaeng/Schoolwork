!works only for dataset with 6 values
!edit accordingly (change variable values, dimension allocations) to account for larger dataset

!================================================================================================
! COMPHY3_Spline_Quadratic.f90
! Justin Gabrielle A. Manay
! COMPHY3, Physics Department, De La Salle University
! This program interpolates a piecewise function for a given set of points using the quadratic
! spline method.
!================================================================================================

program spline_quadratic

    implicit none
    !--------------------------------------------------------------------------------------------
    ! Declare variables
    integer :: n, i, j, k, sz, confirmed = 0
    real*16 :: point, prod = 1.0, total = 0.0
    real*16, dimension(6) :: t, v
    real*16, dimension(:), allocatable :: b, c
    real*16, dimension(:,:), allocatable :: a
    !--------------------------------------------------------------------------------------------

    !--------------------------------------------------------------------------------------------
    ! Use quadratic interpolation. Specify length of dataset here
    sz = 6
    n = 3 * (sz - 1)
    !--------------------------------------------------------------------------------------------

    !--------------------------------------------------------------------------------------------
    ! Allocate n
    allocate(a(n, n))
    allocate(b(n))
    allocate(c(n))
    !--------------------------------------------------------------------------------------------

    !--------------------------------------------------------------------------------------------
    ! Specify values for t and v(t)
    t = (/ 0.0, 10.0, 15.0, 20.0, 22.5, 30.0 /)
    v = (/ 0.0, 227.04, 362.78, 517.35, 602.97, 901.67 /)
    !--------------------------------------------------------------------------------------------

    !--------------------------------------------------------------------------------------------
    ! Ask users for interpolation point
    do while(confirmed /= 1)
    point = 0
    write(*,"(a44, 1x)", advance = "no") "At what point would you like to interpolate?"
    read(*,*) point
        if(point < 0 .or. point > 30) then
            write(*,*) "The value is out of range. Try again"
        else
            confirmed = 1
        end if
    end do
    !--------------------------------------------------------------------------------------------

    !--------------------------------------------------------------------------------------------
    ! Construct coefficient matrix
    do i = 1, n
        do j = 1, n
            a(i, j) = 0.0
        end do
    end do

    j = 1
    k = 1
    do i = 1, (sz - 1) * 2
        a(i, j) = t(k) ** 2
        a(i, j + 1) = t(k)
        a(i, j + 2) = 1
        if(mod(i, 2) == 0) then
            j = j + 3
        else
            k = k + 1
        end if
    end do

    j = 1
    do i = 2 * sz - 1, 3 * sz - 4
        a(i, j) = 2 * t(i - 9)
        a(i, j + 1) = 1
        a(i, j + 3) = -2 * t(i - 9)
        a(i, j + 4) = -1
        j = j + 3
    end do

    a(n, 1) = 1

!    do i = 1, n
!        do j = 1, n
!        write(*,*) a(i, j)
!        end do
!        write(*,*)
!    end do
    !--------------------------------------------------------------------------------------------

    !--------------------------------------------------------------------------------------------
    ! Construct constant matrix
    b(1) = v(1)
    b(10) = v(6)

    i = 2
    j = 2
    do while(i <= 9)
        b(i) = v(j)
        b(i + 1) = v(j)
        i = i + 2
        j = j + 1
    end do

!    do i = 1, n
!        write(*,*) b(i)
!    end do
    !--------------------------------------------------------------------------------------------

    c = gaussian(n, a, b)

!    do i = 1, n
!        write(*,*) c(i)
!    end do

    !--------------------------------------------------------------------------------------------
    ! Obtain polynomial and the value of point at polynomial.
    do i = 1, 6
        if(point < t(i)) then
            exit
        else if(point == t(i)) then
            write(*,*) "The value of your chosen point at the interpolating polynomial is: ", v(i)
            stop
        end if
    end do

    j = 1
    j = j + 3 * (i - 2)

    do i = 2, 0, -1
        total = total + c(j) * point ** i
        j = j + 1
    end do

    write(*,"(a67, 1x, f10.5)") "The value of your chosen point at the interpolating polynomial is: ", total
    !--------------------------------------------------------------------------------------------

    contains
    !================================================================================================
    ! This function implements the Gaussian elimination algorithm (with pivoting).
    !================================================================================================
        function gaussian(n, a, b) result(x)
            !--------------------------------------------------------------------------------------------
            ! Declare variables
            integer :: n, i, j, k, l
            real*16 :: c, pivot, store
            real*16, dimension(n, n) :: a
            real*16, dimension(n) :: b, x, s
            !--------------------------------------------------------------------------------------------

            !--------------------------------------------------------------------------------------------
            ! Implement Naive Gaussian algorithm
            ! code for Gaussian elimination w/ pivoting from: https://ww2.odu.edu/~agodunov/computing/programs/book2/Ch06/Gauss_2.f90
            ! step 1: begin forward elimination
            do k = 1, n - 1

                ! scaling
                  do i = k, n
                    s(i) = 0.0
                    do j = k, n
                      s(i) = max(s(i), abs(a(i, j)) )
                    end do
                  end do

                ! "pivoting 1"
                pivot = abs(a(k, k)/s(k))
                  l = k
                  do j = k + 1, n
                    if(abs(a(j, k) / s(j)) > pivot) then
                      pivot = abs(a(j, k) / s(j))
                      l = j
                    end if
                  end do

                ! Check if the system has a singular matrix
                  if(pivot == 0.0) then
                    write(*,*) "The matrix is singular."
                    return
                  end if

                ! "pivoting 2"
                if (l /= k) then
                  do j = k, n
                     store = a(k, j)
                     a(k, j) = a(l, j)
                     a(l, j) = store
                  end do
                  store = b(k)
                  b(k) = b(l)
                  b(l) = store
                end if

                ! elimination (after scaling and pivoting)
                do i = k + 1, n
                    c = a(i, k) / a(k, k)
                    a(i, k) = 0.0
                    b(i) = b(i)- c * b(k)
                    do j = k + 1, n
                        a(i, j) = a(i, j) - c * a(k, j)
                    end do
                end do
            end do

            ! back substitution
            x(n) = b(n) / a(n, n)
            do i = n - 1, 1, -1
               c = 0.0
               do j = i + 1, n
                 c = c + a(i, j) * x(j)
               end do
               x(i) = (b(i) - c) / a(i, i)
            end do
            !--------------------------------------------------------------------------------------------
        end function gaussian

end program spline_quadratic
