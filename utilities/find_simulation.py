from miscellaneous import run_data, run_no
import numpy as np
import copy

# Import all data from completed runs.
output_location = None
images_location = None
simulations = run_data.import_simulations(1300, output_location)
  
target = [[6, 27], [5, 3], [2, 24], [1, 1]]
found  = [[] for i in range(len(target))]

for i in range(0, 1300):
  run_no = i+1

  no_veins    = simulations[i].get_no_veins()
  no_arteries = simulations[i].get_no_arteries()
  no_vessels  = [no_arteries, no_veins]

  for j in range(len(target)):
    if no_vessels == target[j]:
      found[j].append(run_no)

print(f"Target: {target}")
print(f"Found:  {found}")

# [6, 27]: 90
# [5, 3]: 122
# [2, 24]: 444
# [1, 1]: 70