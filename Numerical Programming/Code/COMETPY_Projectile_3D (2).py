"""
COMETPY_Projectile_3D uses the Euler method to simulate a 3D-projectile thrown into the air
at an angle theta. The projectile has a radius = 0.0364, mass = 0.0143 and drag 
coefficient = 0.52. The density of air is given to be 1225.

The program outputs the trajectory of the projectile with and without the effects of spin.

All physical quantities are in standard units unless otherwise stated.
"""

import numpy as np 
import matplotlib.pyplot as plt
import matplotlib.patches as patches

# Initialize values
drag = 0.52
density = 1.225
v_0 = 42.5
theta = 20 #Use 10 degrees instead of 0 degrees
radius = 0.0364
mass = 0.143

area = np.pi * radius ** 2
time_step = 0.01

# Write to file
file = open("2Dprojectile.csv", "w+")

def euler(drag, lift, density, v_0, theta, area, mass, time_step):
    g = 9.8
    time_array = [0]
    x_array = [0]
    y_array = [0]
    vx_array = [v_0 * np.cos(theta / 180 * np.pi)]
    vy_array = [v_0 * np.sin(theta / 180 * np.pi)]
    
    i = 0

    file.write("time,x,y\n")
    file.write("\n")
    file.write(str(time_array[i]) + "," + str(x_array[i]) + "," + str(y_array[i]) + "\n")

    while y_array[i] >= 0:
        file.write(str(time_array[i]) + "," + str(x_array[i]) + "," + str(y_array[i]) + "\n")
        
        time_array.append(time_array[i] + time_step)

        x_array.append(x_array[i] + vx_array[i] * time_step)
        y_array.append(y_array[i] + vy_array[i] * time_step)

        vx_array.append(vx_array[i] - ((drag * density * area * vx_array[i] ** 2 + lift * density * area * vy_array[i] ** 2) / mass) * time_step)
        vy_array.append(vy_array[i] - (g + (drag * density * area * vy_array[i] ** 2 - lift * density * area * vx_array[i] ** 2) / mass) * time_step)        
        
        i = i + 1
        
#        print(x_array[i], "\t", y_array[i])
    
    return [x_array, y_array, vx_array, vy_array]

# Plot trajectory
fig = plt.figure(figsize=(10,7))
ax1 = fig.add_subplot(1, 1, 1)
result_nospin = euler(drag, 0, density, v_0, theta, area, mass, time_step)
result_spin = euler(drag, 0.22, density, v_0, theta, area, mass, time_step)
ax1.plot(result_nospin[0], result_nospin[1])
ax1.plot(result_spin[0], result_spin[1])
ax1.set_ylabel("y")
ax1.set_xlabel("x")
ax1.set_title("Trajectory", fontsize = 12) 
blue_patch = patches.Patch(color='blue', label='no spin')
orange_patch = patches.Patch(color='orange', label='with spin, $C_{L} = 0.22$')
ax1.legend(handles=[blue_patch, orange_patch], loc='best', fontsize = 12)

result_spin_x = result_spin[0]
result_spin_vx = result_spin[2]
result_spin_vy = result_spin[3]
for i in range(len(result_spin_x)):
    if(result_spin_x[i] - 18.4 <= 0.01):
        idx = i
print("height at 18.4 m: ", result_spin[1][idx], " m")
print("velocity at 18.4 m: ", np.sqrt(result_spin[2][idx] ** 2 + result_spin[3][idx] ** 2), " m/s")