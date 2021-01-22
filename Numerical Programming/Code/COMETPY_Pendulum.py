"""
COMETPY_Pendulum uses the Euler, Euler-Cromer and Verlet method to simulate a pendulum with length 1, angle of
deviation = 0.1 and angular speed = 0.

The program outputs the angle of deviation of the projectile with and without the effects of spin.

All physical quantities are in standard units unless otherwise stated.
"""

import matplotlib.pyplot as plt

# Initialize values
g = 9.8
l = 1
theta_init = 0.1 #in radians
omega_init = 0

time_step = 0.05
#limit = 230
limit = 1000

# Implement Euler
def euler(l, theta_init, omega_init, time_step, limit):
    time_array = [0]
    theta_array = [theta_init]
    omega_array = [omega_init]

    file = open("pendulum_euler.csv", "w+")
    
    file.write("time,theta,omega\n")
    file.write("\n")

    for i in range(limit):
        file.write(str(time_array[i]) + "," + str(theta_array[i]) + "," + str(omega_array[i]) + "\n")
        
        time_array.append(time_array[i] + time_step)

        omega_array.append(omega_array[i] - (g/l)* theta_array[i] * time_step)
        theta_array.append(theta_array[i] + omega_array[i] * time_step)
    
    return [time_array, theta_array, omega_array]

# Implement Euler-Cromer
def euler_cromer(l, theta_init, omega_init, time_step, limit):
    time_array = [0]
    theta_array = [theta_init]
    omega_array = [omega_init]
    
    file = open("pendulum_euler_cromer.csv", "w+")

    file.write("time,theta,omega\n")
    file.write("\n")

    for i in range(limit):
        file.write(str(time_array[i]) + "," + str(theta_array[i]) + "," + str(omega_array[i]) + "\n")
        
        time_array.append(time_array[i] + time_step)

        omega_array.append(omega_array[i] - (g/l)* theta_array[i] * time_step)
        theta_array.append(theta_array[i] + omega_array[i + 1] * time_step)
    
    return [time_array, theta_array, omega_array]

# Implement Verlet
def verlet(l, theta_init, omega_init, time_step, limit):
    time_array = [0, time_step]
    theta_array = [theta_init, theta_init + omega_init * time_step]
    
    file = open("pendulum_verlet.csv", "w+")

    file.write("time,theta\n")
    file.write("\n")
    file.write(str(time_array[0]) + "," + str(theta_array[0]) + "\n")

    for i in range(1, limit):
        file.write(str(time_array[i]) + "," + str(theta_array[i]) + "\n")
        
        time_array.append(time_array[i] + time_step)

        theta_array.append(2 * theta_array[i] - theta_array[i - 1] - (g/l) * time_step ** 2 * theta_array[i])
    
    return [time_array, theta_array]

# Call the functions and create the plots
fig = plt.figure(figsize=(10,7))
ax1 = fig.add_subplot(1, 1, 1)
result_euler = euler(l, theta_init, omega_init, time_step, limit)
result_euler_cromer = euler_cromer(l, theta_init, omega_init, time_step, limit)
result_verlet = verlet(l, theta_init, omega_init, time_step, limit)
#plt.plot(result_euler[0], result_euler[1], label = "Euler")
plt.plot(result_euler_cromer[0], result_euler_cromer[1], label= "Euler-Cromer")
plt.plot(result_verlet[0], result_verlet[1], label = "Verlet")
plt.ylabel("$\\theta$")
plt.xlabel("time")
plt.title("Pendulum") 
plt.legend()