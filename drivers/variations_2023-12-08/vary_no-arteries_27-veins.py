from miscellaneous import run_data, run_no
import numpy as np
import copy

# Import all data from completed runs.
max_run_no  = 1000#run_no.get_completed_run_no()
simulations = run_data.import_simulations(max_run_no)
  
# Varying parameters.
parameter_name      = "number of arteries (27 veins)"
parameter_safe_name = "no-arteries-27-veins"
min_value           = 1
max_value           = 6
no_bins             = 6
parameter_values    = np.linspace(min_value, max_value, no_bins)

# Populate the bins.
simulation_bins = [[] for i in range(no_bins)]
for i in range(0, max_run_no):
  run_no = i+1

  no_veins    = simulations[i].get_no_veins()
  no_arteries = simulations[i].get_no_arteries()

  if (no_veins == 27):
    simulation_bins[no_arteries-1].append(run_no)

# Plot the data.
import plot_quantities
plot_quantities.plot(simulations, simulation_bins, parameter_values, parameter_name, parameter_safe_name)