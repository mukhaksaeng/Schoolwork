import numpy as np
import matplotlib.pyplot as plt

# NOTES: 
# - This takes too long to run.
# - 1000 time steps not enough for Jupiter and Saturn orbits

# Initialize values
GM = 4 * np.pi**2
radius_vals = [0.72, 1, 1.52, 5.2, 9.54]
planets = ["Venus", "Earth", "Mars", "Jupiter", "Saturn"]
time_step = 0.01
limit = 1000

# Write to file
def runge_kutta_2nd(radius, x_init, y_init, vx_init, vy_init, time_step, limit):
    for i in range(limit):
        time_array = [0]
        x_array = [x_init]
        y_array = [y_init]
        vx_array = [vx_init]
        vy_array = [vy_init]

        file = open("solarsystem_rungekutta.csv", "w+")
        
        file.write("time,x,y,vx,vy\n")
        file.write("\n")
    
        for i in range(limit):
            file.write(str(time_array[i]) + "," + str(x_array[i]) + "," + str(y_array[i]) + "," + str(vx_array[i]) + "," + str(vy_array[i]) + "\n")
            
            time_array.append(time_array[i] + time_step)
            
            radius = np.sqrt(x_array[i]**2 + y_array[i]**2)
            
            k_y = y_array[i] + time_step * 0.5 * vy_array[i]
            k_vy = vy_array[i] + 0.5 * time_step * y_array[i] * (-GM / radius ** 3)

            y_array.append(y_array[i] + k_vy * time_step)
            vy_array.append(vy_array[i] + (-GM * k_y * time_step) / radius ** 3)
            
            k_x = x_array[i] + time_step * 0.5 * vx_array[i]
            k_vx = vx_array[i] + 0.5 * time_step * x_array[i] * (-GM / radius ** 3)

            x_array.append(x_array[i] + k_vx * time_step)                        
            vx_array.append(vx_array[i] + (-GM * k_x * time_step) / radius ** 3)
            
    return [time_array, x_array, y_array, vx_array, vy_array]

# Call 2nd order Runge-Kutta function
fig = plt.figure(figsize=(10,7))
ax1 = fig.add_subplot(1, 1, 1)
for i in range(len(radius_vals)):
    x_init = radius_vals[i]
    y_init = 0
    vx_init = 0
    vy_init = np.sqrt(GM / radius_vals[i])
    result = runge_kutta_2nd(radius_vals[i], x_init, y_init, vx_init, vy_init, time_step, limit)
    plt.plot(result[1], result[2])
    plt.ylabel("y")
    plt.xlabel("x")
    plt.title(planets[i]) 
    plt.show()