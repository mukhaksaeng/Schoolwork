!================================================================================================
! Code_5_polynomial.f90
! Justin Gabrielle A. Manay
! COMPHY2, Physics Department, De La Salle University
! This program interpolates the polynomial for a given set of points using the direct method.
!================================================================================================

program polynomial

    implicit none
    !--------------------------------------------------------------------------------------------
    ! Declare variables
    integer :: i, j, confirmed = 0, n
    real*16 :: point, total = 0.0
    real*16, dimension(6) :: t, v
    real*16, dimension(:,:), allocatable :: a
    real*16, dimension(:), allocatable :: coeff, t2, v2
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
    ! Ask if linear or quadratic interpolation is to be used
    write(*,"(a62, 1x)", advance = "no") "What method would you like to use? (1) linear or (2) quadratic"
    read(*,*) n
    n = n + 1
    !--------------------------------------------------------------------------------------------

    !--------------------------------------------------------------------------------------------
    ! Allocate n
    allocate(coeff(n))
    allocate(t2(n))
    allocate(v2(n))
    allocate(a(n, n))
    !--------------------------------------------------------------------------------------------

    !--------------------------------------------------------------------------------------------
    ! Find appropriate values
    if(n == 2) then
        do i = 1, 6
            if(point <= t(i)) then
                t2(1) = t(i - 1)
                t2(2) = t(i)
                v2(1) = v(i - 1)
                v2(2) = v(i)
                exit
            end if
        end do

    else if(n == 3) then
        do i = 1, 6
            if(point <= t(i)) then
                t2(1) = t(i - 1)
                t2(2) = t(i)
                t2(3) = t(i + 1)
                v2(1) = v(i - 1)
                v2(2) = v(i)
                v2(3) = v(i + 1)
                exit
            end if
        end do

    end if
    !--------------------------------------------------------------------------------------------

    !--------------------------------------------------------------------------------------------
    ! Fill matrix a
    do i = 1, n
        do j = 1, n
            a(i, 1) = 1
            a(i, j) = t2(i) ** (j - 1)
        end do
    end do

!    do i = 1, n
!        do j = 1, n
!            write(*,*) a(i,j)
!        end do
!    end do
    !--------------------------------------------------------------------------------------------

    coeff = gaussian(n, a, v2)

    !--------------------------------------------------------------------------------------------
    ! Obtain polynomial and the value of point at polynomial.
    write(*,*)
    do i = 1, n
        total = total + coeff(i) * point ** (i - 1)
    end do
    write(*,"(a67, 1x, f10.5)") "The value of your chosen point at the interpolating polynomial is: ", total
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
