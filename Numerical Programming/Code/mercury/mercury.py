"""
mercury uses the 2nd order Runge Kutta method to simulate Mercury's orbit.
The program outputs the orbit after a certain period of time.

All physical quantities are in standard units unless otherwise stated.
"""

import numpy as np
import matplotlib.pyplot as plt

# Initialize values
GM = 4 * np.pi**2
radius = 0.39
eccentricity = 0.206

x_init = (1 + eccentricity) * radius
y_init = 0
vx_init = 0
vy_init = np.sqrt((GM / radius) * ((1 - eccentricity) / (1 + eccentricity)))
time_step = 0.01
limit = 1000
alpha = 0.0008

# Write to file
def runge_kutta_2nd(alpha, radius, x_init, y_init, vx_init, vy_init, time_step, limit):
    for i in range(limit):
        time_array = [0]
        x_array = [x_init]
        y_array = [y_init]
        vx_array = [vx_init]
        vy_array = [vy_init]
        correction = 1 + alpha / radius ** 2

        file = open("solarsystem_rungekutta.csv", "w+")
        
        file.write("time,x,y,vx,vy\n")
        file.write("\n")
    
        for i in range(limit):
            file.write(str(time_array[i]) + "," + str(x_array[i]) + "," + str(y_array[i]) + "," + str(vx_array[i]) + "," + str(vy_array[i]) + "\n")
            
            time_array.append(time_array[i] + time_step)
            
            radius = np.sqrt(x_array[i]**2 + y_array[i]**2)
            
            k_y = y_array[i] + time_step * 0.5 * vy_array[i]
            k_vy = vy_array[i] + 0.5 * time_step * y_array[i] * correction * (-GM / radius ** 3)

            y_array.append(y_array[i] + k_vy * time_step)
            vy_array.append(vy_array[i] + correction * (-GM * k_y * time_step) / radius ** 3)
            
            k_x = x_array[i] + time_step * 0.5 * vx_array[i]
            k_vx = vx_array[i] + 0.5 * time_step * x_array[i] * correction * (-GM / radius ** 3)

            x_array.append(x_array[i] + k_vx * time_step)                        
            vx_array.append(vx_array[i] + correction * (-GM * k_x * time_step) / radius ** 3)
            
    return [time_array, x_array, y_array, vx_array, vy_array]

# Call 2nd order Runge-Kutta function
fig = plt.figure(figsize=(10,7))
ax1 = fig.add_subplot(1, 1, 1)
result = runge_kutta_2nd(alpha, radius, x_init, y_init, vx_init, vy_init, time_step, limit)
ax1.plot(result[1], result[2])

ax1.set_ylabel("y")
ax1.set_xlabel("x")
ax1.set_title("Mercury") 