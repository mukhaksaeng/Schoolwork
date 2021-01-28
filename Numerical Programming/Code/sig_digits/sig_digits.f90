program sig_digits

    implicit none
    real*16 :: error, true
    integer :: i
    character(len = 1) :: start_error = "-"

    write(*,"(a12, 4x, a4, 7x, a4, 8x, a9)") "no. of terms", "f(x)", "%RAE", "no. of SD"
    write(*,*)

    do i = 1, 30
        true = exp(0.7)
        error = abs((taylorexp(i) - taylorexp(i - 1)) / taylorexp(i)) * 100

        if(i == 1) then
            write(*,"(i2, 13x, f20.10, 5x, a1, 10x, i1)") i, taylorexp(i), start_error, sig_counter(error)
        else
            write(*,"(i2, 13x, f20.10, 3x, f10.5, 3x, i1)") i, taylorexp(i), error, sig_counter(error)
        end if

        if(sig_counter(error) >= 9) then
           exit
        endif

    end do

    write(*,*) ""
    write(*,"(a76, i2, 1x, a1)") "The number of Maclaurin series terms that will give 5 significant digits is ", i, " ."

   contains
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

        function sig_counter(error) result(sd)
            integer :: sd
            real*16 :: error, tol

            sd = 0
            tol = 50

            do while(error <= tol)
                sd = sd + 1
                tol = tol / 10
            end do

        end function sig_counter

end program sig_digits
