from miscellaneous import run_data, run_no
import numpy as np
import copy

# Import all data from completed runs.
max_run_no  = 1000#run_no.get_completed_run_no()
#output_location = None
output_location = "output_2024-01-16 154829 (before fixing avg flow and adding signed cross flow)"
#images_location = None
images_location = "images_2024-01-16 154830 (before fixing avg flow and adding signed cross flow)"
simulations = run_data.import_simulations(max_run_no, output_location)
  
# Varying parameters.
parameter_name      = "number of veins (6 arteries)"
parameter_safe_name = "no-veins-6-arteries"
min_value           = 0
max_value           = 27
no_bins             = 28
parameter_values    = np.linspace(min_value, max_value, no_bins)

# Populate the bins.
simulation_bins = [[] for i in range(no_bins)]
for i in range(0, max_run_no):
  run_no = i+1

  no_veins    = simulations[i].get_no_veins()
  no_arteries = simulations[i].get_no_arteries()

  if (no_arteries == 6):
    simulation_bins[no_veins-1].append(run_no)

# Plot the data.
import plot_quantities
plot_quantities.plot(simulations, simulation_bins, parameter_values, parameter_name, parameter_safe_name, images_location)