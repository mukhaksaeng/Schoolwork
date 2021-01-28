!================================================================================================
! tolerance.f90
! Justin Gabrielle A. Manay
! COMPHY2, Physics Department, De La Salle University
! This program calculates the number of iterations needed given a pre-set tolerance.
!================================================================================================

program tolerance

    implicit none
    !--------------------------------------------------------------------------------------------
    ! Declare variables
    real*16 :: error = 1.0, tol = 0.0001
    integer :: i
    character(len = 1) :: start_error = "-"
    !--------------------------------------------------------------------------------------------

    !--------------------------------------------------------------------------------------------
    ! Print heading
    write(*,"(a12, 3x, a4, 13x, a4)") "no. of terms", "f(x)", "%RAE"
    write(*,*)
    !--------------------------------------------------------------------------------------------

    !--------------------------------------------------------------------------------------------
    ! This implements the algorithm.
    ! This also prints out the no. of terms, Taylor series approx. and the RAE per iteration.
    do i = 1, 30
        error = abs((taylorexp(i) - taylorexp(i - 1)) / taylorexp(i)) * 100

        if(i == 1) then
            write(*,"(i2, 13x, f12.10, 5x, a1, 10x, i1)") i, taylorexp(i), start_error
        else
            write(*,"(i2, 13x, f12.10, 3x, f10.5, 3x, i1)") i, taylorexp(i), error
        end if

        if(error <= tol) then
           exit
        endif

    end do

    write(*,*) ""
    write(*,"(a35, f12.10, 1x, a1)") "exp(0.1) is approximately equal to ", taylorexp(i), " ."

   contains
    !================================================================================================
    ! This function calculates the factorial of a number.
    !================================================================================================
        function factorial(n) result(factorialeval)
            integer :: n, factorialeval, i

            factorialeval = 1
            do i = 1 , n
                factorialeval = factorialeval * i
            end do

            if(n == 0) then
                factorialeval = 1
            end if

        end function factorial

        function taylorexp(i) result(taylorexpeval)
            real*16 :: taylorexpeval
            integer :: i, count

            count = 0
            taylorexpeval = 0

            do while(count < i)
                taylorexpeval = taylorexpeval + 0.1 ** count / factorial(count)
                count = count + 1
            end do

        end function taylorexp

end program tolerance
