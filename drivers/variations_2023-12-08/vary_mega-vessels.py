from miscellaneous import run_data, run_no
import numpy as np
import copy

# Import all data from completed runs.
output_location = None
images_location = None
simulations = run_data.import_simulations(1400, output_location)
  
# Varying parameters.
parameter_name      = ["number of arteries", "number of veins", "veins to arteries ratio"]
parameter_safe_name = ["no-arteries", "no-veins", "veins-to-arteries"]
artery_values       = np.linspace(1, 6,  6)
vein_values         = np.linspace(0, 27, 28)
ratio_values        = np.linspace(0, 6, 7)
parameter_values    = [artery_values, vein_values, ratio_values]


bins_no_arteries_all_veins = [[] for i in range(len(artery_values))]
for i in range(0, 1000):
  run_no = i+1

  no_veins    = simulations[i].get_no_veins()
  no_arteries = simulations[i].get_no_arteries()

  if i < 1000:
    bins_no_arteries_all_veins[no_arteries-1].append(run_no)

bins_no_arteries_27_veins = [[] for i in range(len(artery_values))]
for i in range(0, 1400):
  run_no = i+1

  no_veins    = simulations[i].get_no_veins()
  no_arteries = simulations[i].get_no_arteries()

  if (no_veins == 27) and (i < 1000 or (1000 <= i and i < 1100)):
    bins_no_arteries_27_veins[no_arteries-1].append(run_no)

bins_no_veins_all_arteries = [[] for i in range(len(vein_values))]
for i in range(0, 1000):
  run_no = i+1

  no_veins    = simulations[i].get_no_veins()
  no_arteries = simulations[i].get_no_arteries()

  if i < 1000:
    bins_no_veins_all_arteries[no_veins].append(run_no)

bins_no_veins_6_arteries = [[] for i in range(len(vein_values))]
for i in range(0, 1400):
  run_no = i+1

  no_veins    = simulations[i].get_no_veins()
  no_arteries = simulations[i].get_no_arteries()

  if (no_arteries == 6) and (i < 1000 or (1200 <= i and i < 1300)):
    bins_no_veins_6_arteries[no_veins].append(run_no)

bins_veins_to_arteries = [[] for i in range(len(ratio_values))]
for i in range(0, 1000):
  run_no = i+1

  no_veins    = simulations[i].get_no_veins()
  no_arteries = simulations[i].get_no_arteries()

  if (no_veins == 0):
    continue

  ratio = float(no_arteries)/float(no_veins)

  bin_no = int(np.floor((len(ratio_values)-1)*(ratio - ratio_values[0])/(ratio_values[-1] - ratio_values[0])))
  if (bin_no == len(ratio_values)):
    bin_no -= 1
  bins_veins_to_arteries[bin_no].append(run_no)

# Plot the data.
import plot_mega
bins = [[bins_no_arteries_all_veins, bins_no_arteries_27_veins], [bins_no_veins_all_arteries, bins_no_veins_6_arteries], [bins_veins_to_arteries]]

# print(f"Zero veins simulations: {bins[1][0][0]}")
# print(f"1 vein simulations: {bins[1][0][1]}")
# print(f"10 veins simulations: {bins[1][0][10]}")
# print(f"27 veins simulations: {bins[1][0][27]}")

plot_mega.plot_vessels(simulations, bins, parameter_values, parameter_name, parameter_safe_name, images_location)