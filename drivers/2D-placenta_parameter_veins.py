####################
# SIMULATION SETUP #
####################
# Nominal values of parameters.
vessel_locations_nominal = [[0.2, 0.5, 0.8], [0.2, 0.5, 0.8], [0.2, 0.5, 0.8], [0.2, 0.5, 0.8], [0.2, 0.5, 0.8], [0.2, 0.5, 0.8]]

# Geometry measurements (Zak).
# central_cavity_width_nominal      = 2*0.1
# central_cavity_height_nominal     = [2*0.0974, 2*0.2210, 2*0.2924, 2*0.2924, 2*0.2210, 2*0.0974]
# central_cavity_transition_nominal = 0.01
# pipe_transition_nominal           = 0.03 
# artery_width                      = 0.025*2
# artery_width_sm                   = 0.05

# Geometry measurements.
central_cavity_width_nominal      = 0.25   # 10mm
central_cavity_height_nominal     = 0.50   # 20mm
central_cavity_transition_nominal = 0.12#0.04   # 1.6mm
pipe_transition_nominal           = 0.03   # 1.2mm
vessel_fillet_radius              = 0.01
artery_width                      = 0.06   # 2.4mm
artery_width_sm                   = 0.0125 # 0.5mm
no_placentones                    = 6

# Mesh resolution (Zak).
# mesh_resolution = [
#   0.12,  # h_background
#   0.005, # h_vein_top
#   0.005, # h_vein_bottom
#   0.01/2,  # h_artery_top
#   0.01/5,  # h_artery_middle
#   0.01/5,  # h_artery_bottom
#   0.03/4,  # h_cavity_inner
#   0.03/3   # h_cavity_outer
# ]

# Mesh resolution.
mesh_resolution = 0.02

# Unused.
log_cavity_transition = False
artery_length_nominal = 0.25 # 2mm

# Problem parameters.
L   = 0.04     # m
U   = 0.35     # m/s
k   = 1e-8     # m^2
mu  = 4e-3     # Pa s
rho = 1e3      # kg/m^3
D   = 1.667e-9 # m^2/s
R   = 1.667e-2 # m^2/s

# Run type.
run_type      = 'mpi'
linear_solver = 'mumps'
no_threads    = 20

####################
# SIMULATION SETUP #
####################
import numpy as np

# Register termination signal to save output so far.
import signal
from miscellaneous import output
signal.signal(signal.SIGINT, output.end_execution)

# Clean and compile.
from programs import velocity_transport
velocity_transport.setup(clean=True, terminal_output=True, compile=True, compile_clean=False, run_type=run_type, verbose_output=True)

# Sampling parameters.
min_value      = 0
max_value      = 27
range_value    = max_value - min_value
no_samples     = 28
no_subsamples  = 1000
parameter_name = "number of veins"

##################
# SIMULATION RUN #
##################
from miscellaneous import output
from miscellaneous import get_transport_reaction_integral
from miscellaneous import choose_vessels
import matplotlib.pyplot as plt

# Generate parameter means.
parameter_values = np.linspace(min_value, max_value, no_samples)
output.output(f"Varying {parameter_name} between {min_value} and {max_value}", True)

# Storage for all simulations.
all_basal_plate_vessels          = []
all_marginal_sinus_veins         = []
all_septal_wall_veins            = []
all_basal_plate_vessel_positions = []
all_septal_wall_vein_positions   = []
all_transport_reaction_integrals = []
all_no_veins                     = []

# Set artery and vein padding.
vein_width      = 0.0375
fillet_radius   = 0.01
artery_padding  = central_cavity_width_nominal/2 + central_cavity_transition_nominal/2 + fillet_radius
vein_padding    = vein_width/2 + fillet_radius
epsilon_padding = 0.001

# Incrementally run simulations and generate output.
run_no = 0
for i in range(0, no_subsamples):
  for j in range(0, no_samples):
    no_veins = int(parameter_values[j])

    # Calculate number of veins in each placentone and which to turn on.
    no_arteries    = choose_vessels.calculate_no_arteries   (no_placentones)
    vein_locations = choose_vessels.calculate_vessel_enabled(no_veins, no_arteries, no_placentones)

    basal_plate_vessels  = vein_locations[0]
    marginal_sinus_veins = vein_locations[1]
    septal_wall_veins    = vein_locations[2]

    # Calculate positions of vessels.
    basal_plate_vessel_positions, septal_wall_vein_positions = choose_vessels.calculate_vessel_positions(basal_plate_vessels, septal_wall_veins, no_placentones, artery_padding, vein_padding, epsilon_padding)

    # Run the simulation.
    velocity_transport.run(run_no, "nsb", "placenta", central_cavity_width_nominal, central_cavity_height_nominal, central_cavity_transition_nominal, pipe_transition_nominal, artery_length_nominal, mesh_resolution, log_cavity_transition, L, U, mu, rho, k, D, R, terminal_output=True, verbose_output=False, velocity_oscillation_tolerance=1e-4, transport_oscillation_tolerance=1e-1, plot=False, rerun_on_oscillation=False, no_time_steps=0, final_time=1.0, no_threads=no_threads, no_placentones=no_placentones, run_type=run_type, no_reynold_ramp_steps=1, reynold_ramp_start_ratio=0.2, reynold_ramp_step_base=2, artery_width=artery_width, artery_width_sm=artery_width_sm, linear_solver=linear_solver, moving_mesh=False, compute_velocity=True, compute_transport=True, compute_permeability=True, compute_uptake=True, vessel_fillet_radius=vessel_fillet_radius, wall_height_ratio=1.0, oscillation_detection=False, basal_plate_vessels=basal_plate_vessels, marginal_sinus=marginal_sinus_veins, septal_veins=septal_wall_veins, basal_plate_vessel_positions=basal_plate_vessel_positions, septal_wall_vein_positions=septal_wall_vein_positions)

    # Update run number.
    run_no += 1

    # Store the integral.
    integral = get_transport_reaction_integral.get_transport_reaction_integral('velocity-transport', 'placenta', run_no)

    # Store used parameters.
    all_basal_plate_vessels         .append(basal_plate_vessels)
    all_marginal_sinus_veins        .append(marginal_sinus_veins)
    all_septal_wall_veins           .append(septal_wall_veins)
    all_basal_plate_vessel_positions.append(basal_plate_vessel_positions)
    all_septal_wall_vein_positions  .append(septal_wall_vein_positions)
    all_transport_reaction_integrals.append(integral)
    all_no_veins                    .append(no_veins)
  
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
output.output("##########################", True)
output.output(f"Fluxes: {velocity_transport.flux_cache}", True)
output.output(f"Integrals: {velocity_transport.integral_cache}", True)

# Save output.
output.save()

