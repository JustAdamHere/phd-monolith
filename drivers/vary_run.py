####################
# SIMULATION SETUP #
####################
# Register termination signal to save output so far.
import signal
from miscellaneous import output
signal.signal(signal.SIGINT, output.end_execution)

# Import default simulation parameters.
from programs import velocity_transport
parameters = velocity_transport.get_default_run_parameters()

# Nominal values of parameters.
parameters["normal_vessel_locations_nominal"] = [[0.2, 0.5, 0.8], [0.2, 0.5, 0.8], [0.2, 0.5, 0.8], [0.2, 0.5, 0.8], [0.2, 0.5, 0.8], [0.2, 0.5, 0.8]]

# Geometry measurements.
parameters["central_cavity_width_nominal"]      = 0.25
parameters["central_cavity_height_nominal"]     = 0.50
parameters["central_cavity_transition_nominal"] = 0.12
parameters["pipe_transition_nominal"]           = 0.03
parameters["vessel_fillet_radius"]              = 0.01
parameters["artery_width"]                      = 0.06
parameters["artery_width_sm"]                   = 0.0125
parameters["no_placentones"]                    = 6

# Mesh resolution.
parameters["mesh_resolution"] = 1#0.02

# Unused.
parameters["log_cavity_transition"] = False
parameters["artery_length_nominal"] = 0.25

# Problem parameters.
parameters["L"]   = 0.04     # m
parameters["U"]   = 0.35     # m/s
parameters["k"]   = 1e-8     # m^2
parameters["mu"]  = 4e-3     # Pa s
parameters["rho"] = 1e3      # kg/m^3
parameters["D"]   = 1.667e-9 # m^2/s
parameters["R"]   = 1.667e-2 # m^2/s

# Run type.
parameters["run_type"]      = 'openmp'
parameters["linear_solver"] = 'mumps'
parameters["no_threads"]    = 1

# File handling.
parameters["clean_files"] = [True, True, False, False, True, True, False]

##################
# SIMULATION RUN #
##################
from miscellaneous import output
from miscellaneous import get_transport_reaction_integral
from miscellaneous import choose_vessels
import matplotlib.pyplot as plt
import numpy as np

# Clean and compile.
velocity_transport.setup(clean=True, terminal_output=True, compile=True, compile_clean=False, run_type=parameters["run_type"], verbose_output=False)

# Storage for all simulations.
all_basal_plate_vessels          = []
all_marginal_sinus_veins         = []
all_septal_wall_veins            = []
all_basal_plate_vessel_positions = []
all_septal_wall_vein_positions   = []
all_transport_reaction_integrals = []
all_no_veins                     = []

# Sampling parameters.
min_value      = 0
max_value      = 27
range_value    = max_value - min_value
no_samples     = 28
no_subsamples  = 1000
parameter_name = "number_of_veins"

# Set artery and vein padding.
vein_width      = 0.0375
fillet_radius   = 0.01
artery_padding  = parameters["central_cavity_width"]/2 + parameters["central_cavity_transition"]/2 + fillet_radius
vein_padding    = vein_width/2 + fillet_radius
epsilon_padding = 0.001

# Generate parameter means.
parameter_values = np.linspace(min_value, max_value, no_samples)
output.output(f"Varying {parameter_name} mean between {min_value} and {max_value}", True)

# Incrementally run simulations and generate output.
run_no = 1
for i in range(0, no_subsamples):
  for j in range(0, no_samples):
    no_veins = int(parameter_values[j])

    # Calculate number of veins in each placentone and which to turn on.
    no_arteries    = 1
    vein_locations = choose_vessels.calculate_vessel_enabled(no_veins, no_arteries, parameters["no_placentones"])

    parameters["basal_plate_vessels"]  = vein_locations[0]
    parameters["marginal_sinus_veins"] = vein_locations[1]
    parameters["septal_wall_veins"]    = vein_locations[2]

    # Calculate positions of vessels.
    parameters["basal_plate_vessel_positions"], parameters["septal_wall_vein_positions"] = choose_vessels.calculate_vessel_positions(parameters["basal_plate_vessels"], parameters["septal_wall_veins"], parameters["no_placentones"], artery_padding, vein_padding, epsilon_padding)

    # Run the simulation.
    velocity_transport.run(run_no, parameters)

    # Store the integral.
    integral = get_transport_reaction_integral.get_transport_reaction_integral('velocity-transport', 'placenta', run_no)

    # Store used parameters.
    all_basal_plate_vessels         .append(parameters["basal_plate_vessels"])
    all_marginal_sinus_veins        .append(parameters["marginal_sinus_veins"])
    all_septal_wall_veins           .append(parameters["septal_wall_veins"])
    all_basal_plate_vessel_positions.append(parameters["basal_plate_vessel_positions"])
    all_septal_wall_vein_positions  .append(parameters["septal_wall_vein_positions"])
    all_transport_reaction_integrals.append(integral)
    all_no_veins                    .append(no_veins)

    # Update run number.
    run_no += 1
  
  # Update averages.
  integral_average = np.zeros(no_samples)
  for j in range(0, no_samples):
    for l in range(0, i+1):
      integral_average[j] += all_transport_reaction_integrals[l*no_samples + j]
    integral_average[j] /= i+1

  # Update plots.
  plt.plot(parameter_values, integral_average, '--', color='k')
  for j in range(0, no_samples):
    box_plot_integrals = []
    for l in range(0, i+1):
      box_plot_integrals.append(all_transport_reaction_integrals[l*no_samples + j])
    plt.boxplot(box_plot_integrals, positions=[parameter_values[j]], widths=0.75, labels=[f'{parameter_values[j]:.2f}'])
  plt.title(f"Uptake vs {parameter_name}, after {i+1} subsamples")
  plt.xlabel(f"{parameter_name}")
  plt.ylabel("Uptake")
  plt.xlim([min_value, max_value])
  plt.savefig(f"./images/vary_{parameter_name}_{i+1}.png", dpi=300)
  plt.clf()

# Output measured quantities.
from miscellaneous import output
output.output("##########################", True)
output.output(f"Fluxes: {velocity_transport.flux_cache}", True)
output.output(f"Integrals: {velocity_transport.integral_cache}", True)

# Save output.
output.save()