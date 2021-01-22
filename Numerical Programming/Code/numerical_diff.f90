!================================================================================================
! numerical_diff.f90
! Justin Gabrielle A. Manay
! COMPHY2, Physics Department, De La Salle University
! This program calculates the derivative at a given point using the forward, backward and central
! difference approximation methods.
!================================================================================================
program numerical_diff

    implicit none
    !--------------------------------------------------------------------------------------------
    ! Declare variables
    real*16 :: num, step, diff
    integer :: choice1, choice2
    !--------------------------------------------------------------------------------------------

    !--------------------------------------------------------------------------------------------
    ! User input
    write(*,*) "Given the function f(x) = 2000*ln(14x10^4/(14x10^4 - 2100*i)) - 9.8*i,"

    write(*,*) "Choose a value at which to evaluate the 1st/2nd derivative of f(x): "
    read(*,*)  num

    write(*,*) "Choose a step size: "
    read(*, *) step

    write(*,*) "Choose a method: "
    write(*,*) "(1) forward difference"
    write(*,*) "(2) backward difference"
    write(*,*) "(3) central difference"
    read(*,*) choice1

    write(*,*) "Would you like to compute the (1) first or (2) second derivative?"
    read(*,*) choice2
    !--------------------------------------------------------------------------------------------

    !--------------------------------------------------------------------------------------------
    ! Implement forward, central and backward difference methods.
    if(choice2 == 1) then
        if(choice1 == 1) then
            diff = (fx(num + step) - fx(num))/step
        elseif(choice1 == 2) then
            diff = (fx(num) - fx(num - step))/step
        elseif(choice1 == 3) then
            diff = (fx(num + step) - fx(num - step))/(2 * step)
        else
            write(*,*) "Try again. Please enter 1, 2 or 3."
        end if

        write(*,"(a30, 1x, f20.10, 1x, a4, f20.10, a2)") "The derivative of f(x) at x = ", num, " is ", diff, " ."
        write(*,"(a37, f20.10, a2)") "The actual value of the derivative is", deriv(num), " ."

    elseif(choice2 == 2) then
        if(choice1 == 1) then
            diff = (fx(num + 2 * step) - 2 * fx(num + step) + fx(num))/step ** 2
        elseif(choice1 == 2) then
            diff = (fx(num) - 2 * fx(num - step) + fx(num - 2 * step))/step ** 2
        elseif(choice1 == 3) then
            diff = (fx(num + step) - 2 * fx(num) + fx(num - step))/step ** 2
        else
            write(*,*) "Try again. Please enter 1, 2 or 3."
        end if

        write(*,"(a30, 1x, f20.10, 1x, a4, f20.10, a2)") "The derivative of f(x) at x = ", num, " is ", diff, " ."
        write(*,"(a37, f20.10, a2)") "The actual value of the derivative is", deriv2(num), " ."

    else
        write(*,*) "Try again. Please enter either 1 or 2."

    end if
    !--------------------------------------------------------------------------------------------

    contains
    !================================================================================================
    ! This function specifies the function whose derivative is to be found and its first and second
    ! derivatives. In this case, it is 2000 * log(14e4/(14e4 - 2100 * i)) - 9.8 * i. Edit if needed.
    !================================================================================================
        function fx(i) result(fxeval)
            real*16 :: fxeval, i

            fxeval = 2000 * log(14e4/(14e4 - 2100 * i)) - 9.8 * i
        end function fx

        function deriv(i) result(deriveval)
            real*16 :: deriveval, i

            deriveval = (-4040 - 29.4 * i) / (-200 + 3 * i)
        end function deriv

        function deriv2(i) result(deriv2eval)
            real*16 :: deriv2eval, i

            deriv2eval = 18000/(-200 + 3 * i) ** 2
        end function deriv2

end program numerical_diff
