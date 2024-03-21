from miscellaneous import run_data, run_no
import numpy as np
import copy

# Import all data from completed runs.
output_location_artery_width = "../../Monolith-1/output/"
output_location_permeability = "../../Monolith-2/output/"
output_location_wall_height  = "../../Monolith-3/output/"
images_location = None
simulations = [[] for i in range(3)]
simulations[0] = run_data.import_simulations(1000, output_location_artery_width)
simulations[1] = run_data.import_simulations(1000, output_location_permeability)
simulations[2] = run_data.import_simulations(1000, output_location_wall_height)
  
# Varying parameters.
parameter_name      = ["artery width", "permeability ($\log_{10}$)", "wall height ratio"]
parameter_safe_name = ["artery_width", "permeability", "wall_height_ratio"]
artery_width_values = np.linspace(0.0125, 0.075, 10)
permeability_values = np.linspace(-10, -6, 10)
wall_height_values  = np.linspace((0.0375+2*0.01)/0.1725 + 0.001, 2.0, 10)
parameter_values    = [artery_width_values, permeability_values, wall_height_values]


bins_artery_width = [[] for i in range(len(artery_width_values))]
for i in range(0, 1000):
  run_no = i+1

  bin_no = int(np.floor((len(artery_width_values))*(simulations[0][i].parameters["artery_width"] - artery_width_values[0])/(artery_width_values[-1] - artery_width_values[0])))
  if (bin_no == len(artery_width_values)):
    bin_no -= 1

  bins_artery_width[bin_no].append(run_no)

bins_permeability = [[] for i in range(len(permeability_values))]
for i in range(0, 1000):
  run_no = i+1

  bin_no = int(np.floor((len(permeability_values))*(np.log10(simulations[1][i].parameters["scaling_k"]) - permeability_values[0])/(permeability_values[-1] - permeability_values[0])))
  if (bin_no == len(permeability_values)):
    bin_no -= 1
  bins_permeability[bin_no].append(run_no)

bins_wall_height = [[] for i in range(len(wall_height_values))]
for i in range(0, 1000):
  run_no = i+1

  bin_no = int(np.floor((len(wall_height_values))*(simulations[2][i].parameters["wall_height_ratio"] - wall_height_values[0])/(wall_height_values[-1] - wall_height_values[0])))
  if (bin_no == len(wall_height_values)):
    bin_no -= 1
  bins_wall_height[bin_no].append(run_no)

# Plot the data.
import plot_mega
bins = [bins_artery_width, bins_permeability, bins_wall_height]
plot_mega.plot_others(simulations, bins, parameter_values, parameter_name, parameter_safe_name, images_location)