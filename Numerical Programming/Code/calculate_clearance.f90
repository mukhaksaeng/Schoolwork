program calculate_clearance
    implicit none
    real :: clear1, clear2

    clear1 = 12.363 * (6.0150e-6 * (-108 - 80) + 6.1496e-9 * ((-108)**2/2 - 80**2/2) - 1.2278e-11 * ((-108)**3/3 - 80**3/3))
    clear2 = 12.363 * (6.0150e-6 * (-321 - 80) + 6.1496e-9 * ((-321)**2/2 - 80**2/2) - 1.2278e-11 * ((-321)**3/3 - 80**3/3))

    print*, "Cooling the steel turnion to -108", char(248), "F will lead to a clearance of", clear1, " in."
    print*, "Cooling the steel turnion to -321", char(248), "F will lead to a clearance of", clear2, " in."

end program calculate_clearance
