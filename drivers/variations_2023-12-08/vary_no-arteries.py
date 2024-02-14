from miscellaneous import run_data, run_no
import numpy as np
import copy

# Import all data from completed runs.
output_location = None
images_location = None
no_arteries_all_veins_simulations = run_data.import_simulations(50, output_location)
no_arteries_27_veins_simulations  = run_data.import_simulations(50, output_location)
  
# Varying parameters.
parameter_name      = ["number of arteries", "number of veins"]
parameter_safe_name = "no-arteries"
min_value           = 1
max_value           = 6
no_bins             = 6
parameter_values    = np.linspace(min_value, max_value, no_bins)

# Populate the bins.
simulation_bins_all_veins = [[] for i in range(no_bins)]
for i in range(0, 50):
  run_no = i+1

  no_veins    = no_arteries_all_veins_simulations[i].get_no_veins()
  no_arteries = no_arteries_all_veins_simulations[i].get_no_arteries()

  if True:
    simulation_bins_all_veins[no_arteries-1].append(run_no)

simulation_bins_27_veins = [[] for i in range(no_bins)]
for i in range(0, 50):
  run_no = i+1

  no_veins    = no_arteries_27_veins_simulations[i].get_no_veins()
  no_arteries = no_arteries_27_veins_simulations[i].get_no_arteries()

  # if (no_veins == 27):
  if (no_veins > 2):
    simulation_bins_27_veins[no_arteries-1].append(run_no)

# Plot the data.
import plot_mega
plot_mega.plot([no_arteries_all_veins_simulations, no_arteries_27_veins_simulations], [simulation_bins_all_veins, simulation_bins_27_veins], parameter_values, parameter_name, parameter_safe_name, images_location)
# plot_quantities.plot_mega(no_arteries_27_veins_simulations,  simulation_bins_27_veins,  parameter_values, parameter_name, parameter_safe_name, images_location)