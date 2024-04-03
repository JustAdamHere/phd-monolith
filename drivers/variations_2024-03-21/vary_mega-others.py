from miscellaneous import run_data, run_no
import numpy as np
import copy

max_run_no = 1000

# Import all data from completed runs.
output_location_artery_width       = "../../Monolith-1/output/"
output_location_oxygen_diffusivity = "../../Monolith-2/output/"
output_location_oxygen_uptake      = "../../Monolith-3/output/"
output_location_permeability       = "../../Monolith-4/output/"
output_location_vein_width         = "../../Monolith-5/output/"
output_location_wall_height        = "../../Monolith-6/output/"
images_location = None
simulations = [[] for i in range(6)]
simulations[0] = run_data.import_simulations(max_run_no, output_location_artery_width)
simulations[1] = run_data.import_simulations(max_run_no, output_location_oxygen_diffusivity)
simulations[2] = run_data.import_simulations(max_run_no, output_location_oxygen_uptake)
simulations[3] = run_data.import_simulations(max_run_no, output_location_permeability)
simulations[4] = run_data.import_simulations(max_run_no, output_location_vein_width)
simulations[5] = run_data.import_simulations(max_run_no, output_location_wall_height)
  
# Varying parameters.
parameter_name      = [r"$2r_a$ (mm)", r"$D$ (mm$^2$/s)", r"$R$ (1/s)", r"$k$ ($\log_{10}$) (mm$^2$)", r"$2r_v$ (mm)", r"$h/h_0$"]
parameter_safe_name = ["artery_width", "oxygen_diffusivity", "oxygen_uptake", "permeability", "vein_width", "wall_height_ratio"]
artery_width_values       = np.linspace(0.0125, 0.075, 10)*1000*0.04
oxygen_diffusivity_values = np.linspace(0.1*1.667e-9, 5*1.667e-9, 10)
oxygen_uptake_values      = np.linspace(0.1*1.667e-2, 5*1.667e-2, 10)
permeability_values       = np.linspace(-10, -6, 10)
vein_width_values         = np.linspace(0.025, 0.075, 10)*1000*0.04
wall_height_values        = np.linspace((0.0375+2*0.01)/0.1725 + 0.001, 2.0, 10)
parameter_values = [artery_width_values, oxygen_diffusivity_values, oxygen_uptake_values, permeability_values, vein_width_values, wall_height_values]

bins_artery_width = [[] for i in range(len(artery_width_values))]
for i in range(0, max_run_no):
  run_no = i+1

  bin_no = int(np.floor((len(artery_width_values))*(simulations[0][i].parameters["artery_width"]*1000*0.04 - artery_width_values[0])/(artery_width_values[-1] - artery_width_values[0])))
  if (bin_no == len(artery_width_values)):
    bin_no -= 1

  bins_artery_width[bin_no].append(run_no)

bins_oxygen_diffusivity = [[] for i in range(len(oxygen_diffusivity_values))]
for i in range(0, max_run_no):
  run_no = i+1

  bin_no = int(np.floor((len(oxygen_diffusivity_values))*(simulations[1][i].parameters["scaling_D"] - oxygen_diffusivity_values[0])/(oxygen_diffusivity_values[-1] - oxygen_diffusivity_values[0])))
  if (bin_no == len(oxygen_diffusivity_values)):
    bin_no -= 1

  bins_oxygen_diffusivity[bin_no].append(run_no)

bins_oxygen_uptake = [[] for i in range(len(oxygen_uptake_values))]
for i in range(0, max_run_no):
  run_no = i+1

  bin_no = int(np.floor((len(oxygen_uptake_values))*(simulations[2][i].parameters["scaling_R"] - oxygen_uptake_values[0])/(oxygen_uptake_values[-1] - oxygen_uptake_values[0])))
  if (bin_no == len(oxygen_uptake_values)):
    bin_no -= 1

  bins_oxygen_uptake[bin_no].append(run_no)

bins_permeability = [[] for i in range(len(permeability_values))]
for i in range(0, max_run_no):
  run_no = i+1

  bin_no = int(np.floor((len(permeability_values))*(np.log10(simulations[3][i].parameters["scaling_k"]) - permeability_values[0])/(permeability_values[-1] - permeability_values[0])))
  if (bin_no == len(permeability_values)):
    bin_no -= 1
  bins_permeability[bin_no].append(run_no)

bins_vein_width = [[] for i in range(len(vein_width_values))]
for i in range(0, max_run_no):
  run_no = i+1

  bin_no = int(np.floor((len(vein_width_values))*(simulations[4][i].parameters["vein_width"]*1000*0.04 - vein_width_values[0])/(vein_width_values[-1] - vein_width_values[0])))
  if (bin_no == len(vein_width_values)):
    bin_no -= 1

  bins_vein_width[bin_no].append(run_no)

bins_wall_height = [[] for i in range(len(wall_height_values))]
for i in range(0, max_run_no):
  run_no = i+1

  bin_no = int(np.floor((len(wall_height_values))*(simulations[5][i].parameters["wall_height_ratio"] - wall_height_values[0])/(wall_height_values[-1] - wall_height_values[0])))
  if (bin_no == len(wall_height_values)):
    bin_no -= 1
  bins_wall_height[bin_no].append(run_no)

# Plot the data.
import plot_mega
bins = [bins_artery_width, bins_oxygen_diffusivity, bins_oxygen_uptake, bins_permeability, bins_vein_width, bins_wall_height]
plot_mega.plot_others(simulations, bins, parameter_values, parameter_name, parameter_safe_name, images_location, plot_outliers=True)