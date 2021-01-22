import numpy as np
import matplotlib.pyplot as plt

def decimal_to_binary(num):
    
    digits = []
    
    while num >= 1:
        digits.append(num % 2)
        num = num // 2
    
    if len(digits) < 8:
        digits = [0 for i in range(8 - len(digits))] + digits[::-1]
    else:
        digits = digits[::-1]
    
    return "".join(map(str, digits))

def eca(list_init, rule):
    
    list_new = []
    
    rule = decimal_to_binary(rule)
    rule_dict = {"111" : rule[0], "110" : rule[1], "101" : rule[2], "100" : rule[3], "011" : rule[4], "010" : rule[5], "001" : rule[6], "000" : rule[7]}

#    Treat list_init as cyclic
    list_init = list_init[-1 : ] + list_init + list_init[0 : 1]
    
    for i in range(len(list_init) - 2):
        list_new.append(int(rule_dict["".join(map(str, list_init[i : i + 3]))]))
    
    #list_new = list_init[0 : 1] + list_new + list_init[-1 : ]
    
    return list_new

def eca_matrix(rule, length = 101, width = 100):
    eca_matrix = [[0 for i in range(width)] for j in range(length)]
    
#    eca_matrix[0] = [0 for i in range(width // 2)] + [1] + [0 for i in range(width // 2)]

#    Randomize list_init    
    np.random.seed(100)
    eca_matrix[0] = [np.random.randint(0, 2) for i in range(width)]
    
    for i in range(1, length):
        eca_matrix[i] = eca(eca_matrix[i - 1], rule)

    return eca_matrix            

# MODIFICATION: Choose between one and two steps to the left and between one and two steps to the right with bias bias, towards the immediate neighbors.
def eca_modified(list_init, rule, bias):

    list_new = []
    
    rule = decimal_to_binary(rule)
    rule_dict = {"111" : rule[0], "110" : rule[1], "101" : rule[2], "100" : rule[3], "011" : rule[4], "010" : rule[5], "001" : rule[6], "000" : rule[7]}
    
#    Treat list_init as cyclic
    list_init = list_init[len(list_init) - 2 : ] + list_init + list_init[0 : 2]
    
    for i in range(2, len(list_init) - 2):
        before = [list_init[i - 2], list_init[i - 1]]
        after = [list_init[i + 2], list_init[i + 1]]
        list_new.append(int(rule_dict["".join(map(str, [before[np.random.binomial(1, bias)], list_init[i], after[np.random.binomial(1, bias)]]))]))
        
    #list_new = list_init[0 : 2] + list_new + list_init[len(list_init) - 2 : ]
    
    return list_new

def eca_modified_matrix(rule, bias, length = 101, width = 100):
    eca_matrix = [[0 for i in range(width)] for j in range(length)]
    
#    eca_matrix[0] = [0 for i in range(width // 2)] + [1] + [0 for i in range(width // 2)]
    
#    Randomize list_init    
    np.random.seed(100)
    eca_matrix[0] = [np.random.randint(0, 2) for i in range(width)]
    
    for i in range(1, length):
        eca_matrix[i] = eca_modified(eca_matrix[i - 1], rule, bias)
        
    return eca_matrix

def eca_plot(matrix, rule):
    
    plt.imshow(matrix, vmin = 0, vmax = 1, cmap = "binary")
    plt.title('Elementary Cellular Automata Rule ' + str(rule))
    plt.show()
    
# ECA Characterization

def kinetic_energy(matrix):
    
    total_flips_ave = 0
    
    for row in range(1, len(matrix)):
        
        total_flips = 0
        for column in range(len(matrix[row])):
            total_flips += abs(matrix[row][column] - matrix[row - 1][column])
    
        total_flips_ave += total_flips / len(matrix)
    
    kinetic_energy = total_flips_ave / len(matrix[0])
    
    return kinetic_energy

def spatial_entropy(matrix):
    
#    length = len(matrix[0])
#    norm_const = (length / 8) * np.log(1 / length)
    norm_const = 1
    
    spatial_entropy = 0
    
    for row in range(len(matrix) - 1):
        
        shannon_entropy = 0
        prob_dict = {"111" : 0, "110" : 0, "101" : 0, "100" : 0, "011" : 0, "010" : 0, "001" : 0, "000" : 0}
        cyclic_row = matrix[row][-1 : ] + matrix[row] + matrix[row][0 : 1]
            
        for column in range(len(cyclic_row) - 2):
            triplet = "".join(map(str, cyclic_row[column : column + 3]))
            prob_dict[triplet] += 1 / len(matrix[0])

        for prob in prob_dict.values():
            if prob == 0:
                continue
            else:
                shannon_entropy += prob * np.log(prob)       
                
        spatial_entropy += -norm_const * shannon_entropy / len(matrix)     
        
    return spatial_entropy
    
fig, ax1 = plt.subplots(figsize = (20, 20), nrows = 16, ncols = 16)

for i in range(256):
    row_num = i // 16
    col_num = i % 16
    ax1[row_num, col_num].imshow(eca_matrix(i), vmin = 0, vmax = 1, cmap = "binary")
    ax1[row_num, col_num].set_title(str(i))

plt.show()

kinetic_energy_vals = []
spatial_entropy_vals = []      
kinetic_energy_vals_equal = []
spatial_entropy_vals_equal = []

for i in range(256):
    kinetic_energy_vals.append(kinetic_energy(eca_matrix(i)))
    spatial_entropy_vals.append(spatial_entropy(eca_matrix(i)))
    kinetic_energy_vals_equal.append(kinetic_energy(eca_modified_matrix(i, 0.5)))
    spatial_entropy_vals_equal.append(spatial_entropy(eca_modified_matrix(i, 0.5)))

plt.plot(spatial_entropy_vals, kinetic_energy_vals, ls = "", marker = "o")
plt.title("ECA")
plt.xlabel("spatial entropy")
plt.ylabel("kinetic energy")
plt.show()

plt.plot(spatial_entropy_vals_equal, kinetic_energy_vals_equal, ls = "", marker = "o")
plt.title("ECA, Bias = 0.5")
plt.xlabel("spatial entropy")
plt.ylabel("kinetic energy")
plt.show()

for i in range(256):
    kinetic_energy_diff = [kinetic_energy_vals[i] - kinetic_energy_vals_equal[i] for i in range(256)]
    spatial_entropy_diff = [spatial_entropy_vals[i] - spatial_entropy_vals_equal[i] for i in range(256)]

plt.plot(spatial_entropy_diff, kinetic_energy_diff, ls = "", marker = "o")
plt.title("ECA Default and Modified Rule Differences")
plt.xlabel("spatial entropy")
plt.ylabel("kinetic energy")
plt.show()

# Runs very slowly because of nested for loop. Comment out to check plot.

#bias_list = np.arange(0.1, 1, 0.1)
#
#fig, ax2 = plt.subplots(figsize = (15, 9), nrows = 3, ncols = 3)
#plt.setp(ax2.flat, xlabel = "spatial entropy", ylabel= "kinetic energy")

#for i in range(len(bias_list)):
#    kinetic_energy_modified_vals = []
#    spatial_entropy_modified_vals = []  
#    for j in range(256):
#        kinetic_energy_modified_vals.append(kinetic_energy(eca_modified_matrix(j, bias_list[i])))
#        spatial_entropy_modified_vals.append(spatial_entropy(eca_modified_matrix(j, bias_list[i])))
#    
#    row_num = i // 3
#    col_num = i % 3
#    ax2[row_num, col_num].plot(spatial_entropy_modified_vals, kinetic_energy_modified_vals, ls = "", marker = "o")
#    ax2[row_num, col_num].set_title("Modified ECA, Bias: " + str(bias_list[i]))
#
#plt.show()