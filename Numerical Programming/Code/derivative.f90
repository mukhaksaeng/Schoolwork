program derivative

    implicit none
    real :: stepsize = 0.20, error = 0.0, tol = 0.1, true
    integer :: count = 0
    character(len = 3) :: within = "no"
    character(len = 1) :: start_error = "-"

    write(*,"(a2, 9x, a8, 4x, a4, 10x, a11)") "h", "estimate", "%RAE", "within tol?"
    write(*,*) ""

    do while(within == "no" .and. count < 9)
        true = 3.5 * exp(0.5*2)
        if(stepsize == 0.20) then
            error = 100
        else
            error = abs((diffquot(stepsize) - diffquot(stepsize + 0.02))/diffquot(stepsize)) * 100
        end if

        if (error <= tol) then
            within = "yes"
        else
            within = "no"
        end if

        if(count == 0) then
            write(*,"(f8.5, 3x, f8.5, 2x, a5, 9x, a5)") stepsize, diffquot(stepsize), start_error, within
        else
            write(*,"(f8.5, 3x, f8.5, 3x, f10.5, 3x, a5)") stepsize, diffquot(stepsize), error, within
        end if

        stepsize = stepsize - 0.02
        count = count + 1
    end do

    write(*,*), ""

    if(count == 9) then
        write(*,*) "The total number of iterations for a step size of 0.02 is 0."
    else
        write(*,"(a57, 2x, i1, a1)") "The total number of iterations for a step size of 0.02 is", count, "."
    end if

    contains
        function fx(i) result(fxeval)
            real :: fxeval, i

            fxeval = 7 * exp(0.5 * i)
        end function fx

        function diffquot(step) result(diffquoteval)
            real :: step, diffquoteval

            diffquoteval = (fx(2.00 + step) - fx(2.00)) / step
        end function diffquot

end program derivative
