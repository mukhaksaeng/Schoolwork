import pandas as pd
import numpy as np

######## 2016 Dataset

# Load dataset
lfs_2016 = pd.read_csv("lfsoct16-puf.csv", usecols = ["PUFREG", "PUFHHNUM", "PUFHHSIZE", "PUFURB2K10", "PUFC04_SEX", "PUFC05_AGE", "PUFC06_MSTAT", "PUFC07_GRADE", "PUFC14_PROCC", "PUFC16_PKB", "PUFC17_NATEM", "PUFC19_PHOURS", "PUFC25_PBASIC"])
#print(len(lfs_2016), "before dropping NaN")

# Change "." value to NaN
lfs_2016 = lfs_2016.replace(".", np.nan)

# Delete all row with any NaN values
lfs_2016 = lfs_2016.dropna(axis = 0)

# Reset indices
lfs_2016 = lfs_2016.reset_index(drop = True)

# Change column names
lfs_2016.rename(columns = {"PUFHHNUM" : "hhnum"}, inplace = True)
lfs_2016.rename(columns = {"PUFREG" : "region"}, inplace = True)
lfs_2016.rename(columns = {"PUFHHSIZE" : "hhsize"}, inplace = True)
lfs_2016.rename(columns = {"PUFURB2K10" : "urb"}, inplace = True)
lfs_2016.rename(columns = {"PUFC04_SEX" : "sex"}, inplace = True)
lfs_2016.rename(columns = {"PUFC05_AGE" : "age"}, inplace = True)
lfs_2016.rename(columns = {"PUFC06_MSTAT" : "mstat"}, inplace = True)
lfs_2016.rename(columns = {"PUFC07_GRADE" : "grade"}, inplace = True)
lfs_2016.rename(columns = {"PUFC14_PROCC" : "procc"}, inplace = True)
lfs_2016.rename(columns = {"PUFC16_PKB" : "sector"}, inplace = True)
lfs_2016.rename(columns = {"PUFC17_NATEM" : "natem"}, inplace = True)
lfs_2016.rename(columns = {"PUFC19_PHOURS" : "hours"}, inplace = True)
lfs_2016.rename(columns = {"PUFC25_PBASIC" : "wage"}, inplace = True)
#print(lfs_2016.head())

# For grade, limit study to categories: no grade completed, primary, secondary, tertiary
#lfs_grades = lfs_2016.groupby("grade")["grade"].count()
#print(lfs_grades)

# Convert grade to int
lfs_2016["grade"] = lfs_2016["grade"].apply(lambda x: int(x))

# no grade completed = 0
lfs_2016.loc[lfs_2016["grade"] == 0, "grade_completed"] = 0

# primary = 1
elem_idx = [1, 2, 10, 110, 120, 130, 140, 150, 160, 170]
lfs_2016.loc[lfs_2016["grade"].isin(elem_idx), "grade_completed"] = 1

# secondary = 2
hs_idx = [210, 220, 230, 240, 250, 410, 420, 430, 440, 450, 460, 470, 480, 490, 500, 510, 520]
lfs_2016.loc[lfs_2016["grade"].isin(hs_idx), "grade_completed"] = 2

# non-tertiary = 3
voc_idx = [310, 320, 601, 608, 609, 614, 621, 622, 631, 632, 634, 642, 644, 648, 652, 654, 658, 662, 664, 672, 676, 681, 684, 685, 686, 689]
lfs_2016.loc[lfs_2016["grade"].isin(voc_idx), "grade_completed"] = 3

# tertiary = 4
col_idx = [710, 720, 730, 740, 750, 760, 801, 814, 821, 822, 831, 832, 834, 838, 842, 844, 846, 848, 852, 854, 858, 862, 864, 872, 876, 881, 884, 885, 886, 889]
lfs_2016.loc[lfs_2016["grade"].isin(col_idx), "grade_completed"] = 4

# Drop all the others
lfs_2016 = lfs_2016.dropna(axis = 0)

# Reset indices
lfs_2016 = lfs_2016.reset_index(drop = True)

# Convert grade to int
lfs_2016["grade_completed"] = lfs_2016["grade_completed"].apply(lambda x: int(x))

# Generate variables (grade)
# baseline: no grade completed
lfs_2016["elem_grad"] = lfs_2016["grade_completed"].apply(lambda x: 1 if (x == 1 or x == 2 or x == 3 or x == 4) else 0)
lfs_2016["hs_grad"] = lfs_2016["grade_completed"].apply(lambda x: 1 if (x == 2 or x == 3 or x == 4) else 0)
lfs_2016["voc_grad"] = lfs_2016["grade_completed"].apply(lambda x: 1 if x == 3 else 0)
lfs_2016["col_grad"] = lfs_2016["grade_completed"].apply(lambda x: 1 if x == 4 else 0)

# Compute years of experience as follows: age - years of schooling - 6
grade_list = [[0], [1], [2], [10], [110, 410], [120, 420], [130, 430], [140, 440], [150, 450], [160, 170, 460], [210, 470, 310], [220, 480, 320, 601, 608, 609, 614, 621, 622, 631, 632, 634, 642, 644, 648, 662, 664, 672, 676, 681, 684, 685, 686, 689], [230, 490, 652, 654, 658], [240, 250, 500], [710, 510], [720, 520], [730], [740, 801, 814, 821, 822, 831, 832, 834, 838, 842, 844, 846, 848, 862, 864, 872, 876, 881, 884, 885, 886, 889], [750, 852, 854, 858], [760]]

for i in range(len(lfs_2016)):
    for idx in range(len(grade_list)):
        if lfs_2016.loc[i, "grade"] in grade_list[idx]:
            lfs_2016.loc[i, "years_school"] = idx

lfs_2016["exp"] = lfs_2016["age"] - lfs_2016["years_school"]

# Convert mstat to int
lfs_2016["mstat"] = lfs_2016["mstat"].apply(lambda x: int(x))

# Delete all rows with mstat = 6 (unknown)
lfs_2016 = lfs_2016.drop(lfs_2016[lfs_2016["mstat"] == 6].index)
#print(len(lfs_2016), "after dropping NaN")

# Reset indices
lfs_2016 = lfs_2016.reset_index(drop = True)

# Generate variables (mstat)
# baseline: single
lfs_2016["married"] = lfs_2016["mstat"].apply(lambda x: 1 if x == 2 else 0)
lfs_2016["widowed"] = lfs_2016["mstat"].apply(lambda x: 1 if x == 3 else 0)
lfs_2016["separated"] = lfs_2016["mstat"].apply(lambda x: 1 if x == 4 else 0)
lfs_2016["annulled"] = lfs_2016["mstat"].apply(lambda x: 1 if x == 5 else 0)

# Generate variables (urban/rural)
# baseline: urban
lfs_2016["rural"] = lfs_2016["urb"].apply(lambda x: 1 if x == 2 else 0)

# Generate variables (sex)
# baseline: male
lfs_2016["female"] = lfs_2016["sex"].apply(lambda x: 1 if x == 2 else 0)

# Generate variables (sqexp)
lfs_2016["sqexp"] = lfs_2016["exp"].apply(lambda x: x ** 2)

# Generate variables (logwage)
lfs_2016["wage"] = lfs_2016["wage"].apply(lambda x: int(x))

lfs_2016["logwage"] = lfs_2016["wage"].apply(lambda x: np.log(x))

# Generate variables (region)
# baseline: Luzon
lfs_2016["region"] = lfs_2016["region"].apply(lambda x: int(x))

visayas_ind = [6, 7, 8]
mindanao_ind = [9, 10, 11, 12, 16, 15]

lfs_2016["visayas"] = lfs_2016["region"].apply(lambda x: 1 if x in visayas_ind else 0)
lfs_2016["mindanao"] = lfs_2016["region"].apply(lambda x: 1 if x in mindanao_ind else 0)
            
# Generate variables (primocc)
# baseline: elementary occupations
lfs_2016["procc"] = lfs_2016["procc"].apply(lambda x: int(x))

manager_ind = [11, 12, 13, 14]
professional_ind = [21, 22, 23, 24, 25, 26]
technician_ind = [31, 32, 33, 34, 35]
clerical_ind = [41, 42, 43, 44]
service_ind = [51, 52, 53, 54]
skilled_ind = [61, 62, 63]
craft_ind = [71, 72, 73, 74, 75]
plant_machine_ind = [81, 82, 83]
armed_forces_ind = [1, 2, 3]

lfs_2016["manager"] = lfs_2016["procc"].apply(lambda x: 1 if x in manager_ind else 0)
lfs_2016["professional"] = lfs_2016["procc"].apply(lambda x: 1 if x in professional_ind else 0)
lfs_2016["technician"] = lfs_2016["procc"].apply(lambda x: 1 if x in technician_ind else 0)
lfs_2016["clerical"] = lfs_2016["procc"].apply(lambda x: 1 if x in clerical_ind else 0)
lfs_2016["service"] = lfs_2016["procc"].apply(lambda x: 1 if x in service_ind else 0)
lfs_2016["skilled"] = lfs_2016["procc"].apply(lambda x: 1 if x in skilled_ind else 0)
lfs_2016["craft"] = lfs_2016["procc"].apply(lambda x: 1 if x in craft_ind else 0)
lfs_2016["plant_machine"] = lfs_2016["procc"].apply(lambda x: 1 if x in plant_machine_ind else 0)
lfs_2016["armed_forces"] = lfs_2016["procc"].apply(lambda x: 1 if x in armed_forces_ind else 0)
                        
# Generate variables (natem)
# baseline: permanent
lfs_2016["natem"] = lfs_2016["natem"].apply(lambda x: int(x))

lfs_2016["short_term"] = lfs_2016["natem"].apply(lambda x: 1 if x == 2 else 0)
lfs_2016["diff_emp"] = lfs_2016["natem"].apply(lambda x: 1 if x == 3 else 0)

# Generate variables (sector)
# baseline: agriculture
lfs_2016["sector"] = lfs_2016["procc"].apply(lambda x: int(x))

industry_ind = [i for i in range(5, 44)]
services_ind = [i for i in range(45, 100)]

lfs_2016["industry"] = lfs_2016["sector"].apply(lambda x: 1 if x in industry_ind else 0)
lfs_2016["services"] = lfs_2016["sector"].apply(lambda x: 1 if x in services_ind else 0)

# Generate variable (hours)
lfs_2016["hours"] = lfs_2016["hours"].apply(lambda x: int(x))

# Print dataset
#print(lfs_2016)

# Year dummies
lfs_2016["yr_2017"] = 0

# Export to .csv
lfs_2016.to_csv("LFS2016_cleaned.csv")

######## 2017 Dataset

# Load dataset
lfs_2017 = pd.read_csv("lfsoct17-puf.csv", usecols = ["PUFREG", "PUFHHNUM", "PUFHHSIZE", "PUFURB2K10", "PUFC04_SEX", "PUFC05_AGE", "PUFC06_MSTAT", "PUFC07_GRADE", "PUFC14_PROCC", "PUFC16_PKB", "PUFC17_NATEM", "PUFC19_PHOURS", "PUFC25_PBASIC"])
#print(len(lfs_2017), "before dropping NaN")

# Change "." value to NaN
lfs_2017 = lfs_2017.replace(".", np.nan)

# Delete all row with any NaN values
lfs_2017 = lfs_2017.dropna(axis = 0)

# Reset indices
lfs_2017 = lfs_2017.reset_index(drop = True)

# Change column names
lfs_2017.rename(columns = {"PUFHHNUM" : "hhnum"}, inplace = True)
lfs_2017.rename(columns = {"PUFREG" : "region"}, inplace = True)
lfs_2017.rename(columns = {"PUFHHSIZE" : "hhsize"}, inplace = True)
lfs_2017.rename(columns = {"PUFURB2K10" : "urb"}, inplace = True)
lfs_2017.rename(columns = {"PUFC04_SEX" : "sex"}, inplace = True)
lfs_2017.rename(columns = {"PUFC05_AGE" : "age"}, inplace = True)
lfs_2017.rename(columns = {"PUFC06_MSTAT" : "mstat"}, inplace = True)
lfs_2017.rename(columns = {"PUFC07_GRADE" : "grade"}, inplace = True)
lfs_2017.rename(columns = {"PUFC14_PROCC" : "procc"}, inplace = True)
lfs_2017.rename(columns = {"PUFC16_PKB" : "sector"}, inplace = True)
lfs_2017.rename(columns = {"PUFC17_NATEM" : "natem"}, inplace = True)
lfs_2017.rename(columns = {"PUFC19_PHOURS" : "hours"}, inplace = True)
lfs_2017.rename(columns = {"PUFC25_PBASIC" : "wage"}, inplace = True)
#print(lfs_2017.head())

# For grade, limit study to categories: no grade completed, primary, secondary, tertiary
#lfs_grades = lfs_2017.groupby("grade")["grade"].count()
#print(lfs_grades)

# Convert grade to int
lfs_2017["grade"] = lfs_2017["grade"].apply(lambda x: int(x))

# no grade completed = 0
lfs_2017.loc[lfs_2017["grade"] == 0, "grade_completed"] = 0

# primary = 1
elem_idx = [1, 2, 10, 110, 120, 130, 140, 150, 160, 170]
lfs_2017.loc[lfs_2017["grade"].isin(elem_idx), "grade_completed"] = 1

# secondary = 2
hs_idx = [210, 220, 230, 240, 250, 410, 420, 430, 440, 450, 460, 470, 480, 490, 500, 510, 520]
lfs_2017.loc[lfs_2017["grade"].isin(hs_idx), "grade_completed"] = 2

# non-tertiary = 3
voc_idx = [310, 320, 601, 608, 609, 614, 621, 622, 631, 632, 634, 642, 644, 648, 652, 654, 658, 662, 664, 672, 676, 681, 684, 685, 686, 689]
lfs_2017.loc[lfs_2017["grade"].isin(voc_idx), "grade_completed"] = 3

# tertiary = 4
col_idx = [710, 720, 730, 740, 750, 760, 801, 814, 821, 822, 831, 832, 834, 838, 842, 844, 846, 848, 852, 854, 858, 862, 864, 872, 876, 881, 884, 885, 886, 889]
lfs_2017.loc[lfs_2017["grade"].isin(col_idx), "grade_completed"] = 4

# Drop all the others
lfs_2017 = lfs_2017.dropna(axis = 0)

# Reset indices
lfs_2017 = lfs_2017.reset_index(drop = True)

# Convert grade to int
lfs_2017["grade_completed"] = lfs_2017["grade_completed"].apply(lambda x: int(x))

# Generate variables (grade)
# baseline: no grade completed
lfs_2017["elem_grad"] = lfs_2017["grade_completed"].apply(lambda x: 1 if (x == 1 or x == 2 or x == 3 or x == 4) else 0)
lfs_2017["hs_grad"] = lfs_2017["grade_completed"].apply(lambda x: 1 if (x == 2 or x == 3 or x == 4) else 0)
lfs_2017["voc_grad"] = lfs_2017["grade_completed"].apply(lambda x: 1 if x == 3 else 0)
lfs_2017["col_grad"] = lfs_2017["grade_completed"].apply(lambda x: 1 if x == 4 else 0)

# Compute years of experience as follows: age - years of schooling - 6
grade_list = [[0], [1], [2], [10], [110, 410], [120, 420], [130, 430], [140, 440], [150, 450], [160, 170, 460], [210, 470, 310], [220, 480, 320, 601, 608, 609, 614, 621, 622, 631, 632, 634, 642, 644, 648, 662, 664, 672, 676, 681, 684, 685, 686, 689], [230, 490, 652, 654, 658], [240, 250, 500], [710, 510], [720, 520], [730], [740, 801, 814, 821, 822, 831, 832, 834, 838, 842, 844, 846, 848, 862, 864, 872, 876, 881, 884, 885, 886, 889], [750, 852, 854, 858], [760]]

for i in range(len(lfs_2017)):
    for idx in range(len(grade_list)):
        if lfs_2017.loc[i, "grade"] in grade_list[idx]:
            lfs_2017.loc[i, "years_school"] = idx

lfs_2017["exp"] = lfs_2017["age"] - lfs_2017["years_school"]

# Convert mstat to int
lfs_2017["mstat"] = lfs_2017["mstat"].apply(lambda x: int(x))

# Delete all rows with mstat = 6 (unknown)
lfs_2017 = lfs_2017.drop(lfs_2017[lfs_2017["mstat"] == 6].index)
#print(len(lfs_2017), "after dropping NaN")

# Reset indices
lfs_2017 = lfs_2017.reset_index(drop = True)

# Generate variables (mstat)
# baseline: single
lfs_2017["married"] = lfs_2017["mstat"].apply(lambda x: 1 if x == 2 else 0)
lfs_2017["widowed"] = lfs_2017["mstat"].apply(lambda x: 1 if x == 3 else 0)
lfs_2017["separated"] = lfs_2017["mstat"].apply(lambda x: 1 if x == 4 else 0)
lfs_2017["annulled"] = lfs_2017["mstat"].apply(lambda x: 1 if x == 5 else 0)

# Generate variables (urban/rural)
# baseline: urban
lfs_2017["rural"] = lfs_2017["urb"].apply(lambda x: 1 if x == 2 else 0)

# Generate variables (sex)
# baseline: male
lfs_2017["female"] = lfs_2017["sex"].apply(lambda x: 1 if x == 2 else 0)

# Generate variables (sqexp)
lfs_2017["sqexp"] = lfs_2017["exp"].apply(lambda x: x ** 2)

# Generate variables (logwage)
lfs_2017["wage"] = lfs_2017["wage"].apply(lambda x: int(x))

lfs_2017["logwage"] = lfs_2017["wage"].apply(lambda x: np.log(x))

# Generate variables (region)
# baseline: Luzon
lfs_2017["region"] = lfs_2017["region"].apply(lambda x: int(x))

visayas_ind = [6, 7, 8]
mindanao_ind = [9, 10, 11, 12, 16, 15]

lfs_2017["visayas"] = lfs_2017["region"].apply(lambda x: 1 if x in visayas_ind else 0)
lfs_2017["mindanao"] = lfs_2017["region"].apply(lambda x: 1 if x in mindanao_ind else 0)
            
# Generate variables (primocc)
# baseline: elementary occupations
lfs_2017["procc"] = lfs_2017["procc"].apply(lambda x: int(x))

manager_ind = [11, 12, 13, 14]
professional_ind = [21, 22, 23, 24, 25, 26]
technician_ind = [31, 32, 33, 34, 35]
clerical_ind = [41, 42, 43, 44]
service_ind = [51, 52, 53, 54]
skilled_ind = [61, 62, 63]
craft_ind = [71, 72, 73, 74, 75]
plant_machine_ind = [81, 82, 83]
armed_forces_ind = [1, 2, 3]

lfs_2017["manager"] = lfs_2017["procc"].apply(lambda x: 1 if x in manager_ind else 0)
lfs_2017["professional"] = lfs_2017["procc"].apply(lambda x: 1 if x in professional_ind else 0)
lfs_2017["technician"] = lfs_2017["procc"].apply(lambda x: 1 if x in technician_ind else 0)
lfs_2017["clerical"] = lfs_2017["procc"].apply(lambda x: 1 if x in clerical_ind else 0)
lfs_2017["service"] = lfs_2017["procc"].apply(lambda x: 1 if x in service_ind else 0)
lfs_2017["skilled"] = lfs_2017["procc"].apply(lambda x: 1 if x in skilled_ind else 0)
lfs_2017["craft"] = lfs_2017["procc"].apply(lambda x: 1 if x in craft_ind else 0)
lfs_2017["plant_machine"] = lfs_2017["procc"].apply(lambda x: 1 if x in plant_machine_ind else 0)
lfs_2017["armed_forces"] = lfs_2017["procc"].apply(lambda x: 1 if x in armed_forces_ind else 0)
                        
# Generate variables (natem)
# baseline: permanent
lfs_2017["natem"] = lfs_2017["natem"].apply(lambda x: int(x))

lfs_2017["short_term"] = lfs_2017["natem"].apply(lambda x: 1 if x == 2 else 0)
lfs_2017["diff_emp"] = lfs_2017["natem"].apply(lambda x: 1 if x == 3 else 0)

# Generate variables (sector)
# baseline: agriculture
lfs_2017["sector"] = lfs_2017["procc"].apply(lambda x: int(x))

industry_ind = [i for i in range(5, 44)]
services_ind = [i for i in range(45, 100)]

lfs_2017["industry"] = lfs_2017["sector"].apply(lambda x: 1 if x in industry_ind else 0)
lfs_2017["services"] = lfs_2017["sector"].apply(lambda x: 1 if x in services_ind else 0)

# Generate variable (hours)
lfs_2017["hours"] = lfs_2017["hours"].apply(lambda x: int(x))

# Print dataset
#print(lfs_2017)

# Year dummies
lfs_2017["yr_2017"] = 1

# Export to .csv
lfs_2017.to_csv("LFS2017_cleaned.csv")

# Merge both datasets
lfs_merged = lfs_2017.append(lfs_2016, ignore_index = True)

# Export to .csv
lfs_merged.to_csv("LFS_merged.csv")