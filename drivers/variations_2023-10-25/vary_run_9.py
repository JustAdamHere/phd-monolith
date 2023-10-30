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
parameters["mesh_resolution"] = 0.02
parameters["generate_outline_mesh"] = True

# Unused.
parameters["log_cavity_transition"] = False
parameters["artery_length_nominal"] = 0.25

# Problem parameters.
parameters["scaling_L"]   = 0.04     # m
parameters["scaling_U"]   = 0.35     # m/s
parameters["scaling_k"]   = 1e-8     # m^2
parameters["scaling_mu"]  = 4e-3     # Pa s
parameters["scaling_rho"] = 1e3      # kg/m^3
parameters["scaling_D"]   = 1.667e-9 # m^2/s
parameters["scaling_R"]   = 1.667e-2 # m^2/s

# Run type.
parameters["run_type"]      = 'openmp'
parameters["linear_solver"] = 'mumps'
parameters["no_threads"]    = 20

# File handling.
parameters["clean_files"][0] = True  # Output VTKs.
parameters["clean_files"][1] = True  # Output restarts.
parameters["clean_files"][2] = False # Output data files.
parameters["clean_files"][3] = False # Output log files.
parameters["clean_files"][4] = False  # Mesh mshs.
parameters["clean_files"][5] = False  # Mesh VTKs.
parameters["clean_files"][6] = False # Images.

# Output.
parameters["terminal_output"] = True
parameters["verbose_output"]  = False

# Simulation.
parameters["compute_velocity_average"] = True
parameters["compute_mri"]              = False
parameters["compute_permeability"]     = False
parameters["compute_transport"]        = True
parameters["compute_uptake"]           = False
parameters["compute_velocity"]         = True
parameters["compute_velocity_average"] = True




parameters["warn_of_oscillations"] = False



##################
# SIMULATION RUN #
##################
from miscellaneous import output
from miscellaneous import get_transport_reaction_integral, get_velocity_magnitude
from miscellaneous import choose_vessels
import matplotlib.pyplot as plt
import matplotlib.ticker as tick
import numpy as np
import time

# Clean and compile.
velocity_transport.setup(clean=True, terminal_output=True, compile=True, compile_clean=False, run_type=parameters["run_type"], verbose_output=False)

# Storage for all simulations.
all_basal_plate_vessels          = []
all_marginal_sinus_veins         = []
all_septal_wall_veins            = []
all_basal_plate_vessel_positions = []
all_septal_wall_vein_positions   = []
all_transport_reaction_integrals = []
all_velocity_magnitude_integrals = []
all_average_velocities           = []
all_no_veins                     = []

# Sampling parameters.
min_value      = 0.0125
max_value      = 0.07
range_value    = max_value - min_value
no_samples     = 10
no_subsamples  = 1000
parameter_name = "artery_width"

# Set artery and vein padding.
vein_width      = 0.0375
fillet_radius   = 0.01
artery_padding  = parameters["central_cavity_width"]/2 + parameters["central_cavity_transition"]/2 + fillet_radius
vein_padding    = vein_width/2 + fillet_radius
epsilon_padding = 0.001

# Generate parameter means.
parameter_values = np.linspace(min_value, max_value, no_samples)
parameter_diff = np.diff(parameter_values)[0]
output.output(f"Varying {parameter_name} mean between {min_value} and {max_value}, δp = {parameter_diff}", True)

# Initially create the plots.
fig1 = plt.figure(1)
fig2 = plt.figure(2)
fig3 = plt.figure(3)

transport_reaction_integral_plot = fig1.add_subplot(111)
velocity_magnitude_integral_plot = fig2.add_subplot(111)
average_velocity_plot            = fig3.add_subplot(111)

# Incrementally run simulations and generate output.
run_no = 1
for i in range(0, no_subsamples):
  for j in range(0, no_samples):
    parameters["artery_width"] = parameter_values[j]

    # MS selection.
    parameters["marginal_sinus_veins"] = [1, 1]

    no_veins = 6*3

    # Calculate positions of vessels.
    parameters["basal_plate_vessel_positions"], parameters["septal_wall_vein_positions"] = choose_vessels.calculate_vessel_positions(parameters["basal_plate_vessels"], parameters["septal_veins"], parameters["no_placentones"], artery_padding, vein_padding, epsilon_padding)

    # Run the simulation.
    velocity_transport.run(run_no, parameters)

    # Store the integral.
    transport_reaction_integral = run_no/10#get_transport_reaction_integral.get_transport_reaction_integral('velocity-transport', 'placenta', run_no)
    velocity_magnitude_integral = run_no/10#get_velocity_magnitude         .get_velocity_magnitude_integral('velocity-transport', 'placenta', run_no)
    average_velocity            = run_no/10#get_velocity_magnitude         .get_average_velocity           ('dg_velocity-transport',          run_no)

    # Store used parameters.
    all_basal_plate_vessels         .append(parameters["basal_plate_vessels"])
    all_marginal_sinus_veins        .append(parameters["marginal_sinus_veins"])
    all_septal_wall_veins           .append(parameters["septal_veins"])
    all_basal_plate_vessel_positions.append(parameters["basal_plate_vessel_positions"])
    all_septal_wall_vein_positions  .append(parameters["septal_wall_vein_positions"])
    all_transport_reaction_integrals.append(transport_reaction_integral)
    all_velocity_magnitude_integrals.append(velocity_magnitude_integral)
    all_average_velocities          .append(average_velocity)
    all_no_veins                    .append(no_veins)

    # Update run number.
    run_no += 1
  
  # Update averages.
  transport_reaction_integral_average = np.zeros(no_samples)
  velocity_magnitude_integral_average = np.zeros(no_samples)
  average_velocity_average            = np.zeros(no_samples)
  for j in range(0, no_samples):
    for l in range(0, i+1):
      transport_reaction_integral_average[j] += all_transport_reaction_integrals[l*no_samples + j]
      velocity_magnitude_integral_average[j] += all_velocity_magnitude_integrals[l*no_samples + j]
      average_velocity_average           [j] += all_average_velocities          [l*no_samples + j]
    transport_reaction_integral_average[j] /= i+1
    velocity_magnitude_integral_average[j] /= i+1
    average_velocity_average           [j] /= i+1

  # Update plots.
  transport_reaction_integral_plot.plot(parameter_values, transport_reaction_integral_average, '--', color='k')
  velocity_magnitude_integral_plot.plot(parameter_values, velocity_magnitude_integral_average, '--', color='k')
  average_velocity_plot           .plot(parameter_values, average_velocity_average,            '--', color='k')
  for j in range(0, no_samples):
    box_plot_transport_reaction_integrals = []
    box_plot_velocity_magnitude_integrals = []
    box_plot_average_velocities           = []
    for l in range(0, i+1):
      box_plot_transport_reaction_integrals.append(all_transport_reaction_integrals[l*no_samples + j])
      box_plot_velocity_magnitude_integrals.append(all_velocity_magnitude_integrals[l*no_samples + j])
      box_plot_average_velocities          .append(all_average_velocities          [l*no_samples + j])

    transport_reaction_integral_plot.boxplot(box_plot_transport_reaction_integrals, positions=[parameter_values[j]], widths=0.75*parameter_diff, labels=[f'{parameter_values[j]:.2f}'])
    velocity_magnitude_integral_plot.boxplot(box_plot_velocity_magnitude_integrals, positions=[parameter_values[j]], widths=0.75*parameter_diff, labels=[f'{parameter_values[j]:.2f}'])
    average_velocity_plot           .boxplot(box_plot_average_velocities,           positions=[parameter_values[j]], widths=0.75*parameter_diff, labels=[f'{parameter_values[j]:.2f}'])
  
  transport_reaction_integral_plot.set_title(f"Uptake vs {parameter_name}, after {i+1} subsamples")
  velocity_magnitude_integral_plot.set_title(f"Velocity magnitude integral vs {parameter_name}, after {i+1} subsamples")
  average_velocity_plot           .set_title(f"Average velocity vs {parameter_name}, after {i+1} subsamples")

  transport_reaction_integral_plot.ticklabel_format(style="sci", axis='y', scilimits=(-3, -3))
  velocity_magnitude_integral_plot.ticklabel_format(style="sci", axis='y', scilimits=(-3, -3))
  average_velocity_plot           .ticklabel_format(style="sci", axis='y', scilimits=(-3, -3))

  transport_reaction_integral_plot.set_xlim(xmin=min_value-0.5*parameter_diff, xmax=max_value+0.5*parameter_diff)
  velocity_magnitude_integral_plot.set_xlim(xmin=min_value-0.5*parameter_diff, xmax=max_value+0.5*parameter_diff)
  average_velocity_plot           .set_xlim(xmin=min_value-0.5*parameter_diff, xmax=max_value+0.5*parameter_diff)

  # transport_reaction_integral_plot.xaxis.set_major_locator  (tick.MaxNLocator(10, integer=False, prune='both'))
  transport_reaction_integral_plot.xaxis.set_major_formatter(tick.StrMethodFormatter('{x:.3f}'))
  # velocity_magnitude_integral_plot.xaxis.set_major_locator  (tick.MaxNLocator(10, integer=False, prune='both'))
  velocity_magnitude_integral_plot.xaxis.set_major_formatter(tick.StrMethodFormatter('{x:.3f}'))
  # average_velocity_plot           .xaxis.set_major_locator  (tick.MaxNLocator(10, integer=False, prune='both'))
  average_velocity_plot           .xaxis.set_major_formatter(tick.StrMethodFormatter('{x:.3f}'))
  
  transport_reaction_integral_plot.set_xlabel(f"{parameter_name}")
  velocity_magnitude_integral_plot.set_xlabel(f"{parameter_name}")
  average_velocity_plot           .set_xlabel(f"{parameter_name}")

  transport_reaction_integral_plot.set_ylabel("Uptake")
  velocity_magnitude_integral_plot.set_ylabel("Velocity magnitude integral")
  average_velocity_plot           .set_ylabel("Average velocity")

  fig1.savefig(f"./images/transport-reaction-integral_{parameter_name}_{i+1}.png", dpi=300)
  fig2.savefig(f"./images/velocity-magnitude-integral_{parameter_name}_{i+1}.png", dpi=300)
  fig3.savefig(f"./images/average-velocity_{parameter_name}_{i+1}.png",            dpi=300)

  time.sleep(0.1)

  transport_reaction_integral_plot.cla()
  velocity_magnitude_integral_plot.cla()
  average_velocity_plot           .cla()

# Output measured quantities.
from miscellaneous import output
output.output("##########################", True)
output.output(f"Fluxes: {velocity_transport.flux_cache}", True)
output.output(f"Integrals: {velocity_transport.integral_cache}", True)

# Save output.
output.save()