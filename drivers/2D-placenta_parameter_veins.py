#####
# Function to calculate the number of veins in each placentone.
#  
# Returns:
#  no_veins: number of veins in each placentone
#####
def calculate_no_veins(min_value, max_value, mean, std, no_placentones):
  # Define cut off values at 0+σ and 4-σ.
  a, b = (min_value - parameter_means[i]) / std, (max_value - parameter_means[i]) / std

  # Sample centred around the mean.
  #  Note we keep sampling until the entire placenta we have at least 1 vein.
  no_veins = np.zeros(no_placentones)
  while np.sum(no_veins) == 0:
    no_veins = np.round(truncnorm.rvs(a, b, loc=parameter_means[i], scale=std, size=no_placentones))

  return no_veins

####
# Function to select locations of the veins.
#  no_veins: number of veins in each placentone
# Returns:
#  normal_vessels:       locations of the normal vessels (including arteries)
#  marginal_sinus_veins: locations of the marginal sinus veins
#  septal_wall_veins:    locations of the septal wall veins
####
def calculate_vein_locations(no_veins):
  from random import sample
  # Initialise vein locations, with arteries turned on.
  normal_vessels       = np.array([[0, 1, 0]]*no_placentones)
  marginal_sinus_veins = np.array([0, 0])
  septal_wall_veins    = np.array([[0, 0, 0]]*(no_placentones-1))

  # Decide where the veins will be located in each placentone.
  for j in range(0, no_placentones):
    # Sample vein locations, with no repeats.
    #  pos = 0: ms/septal wall left
    #  pos = 1: basal plate left
    #  pos = 2: basal plate right
    #  pos = 3: ms/septal wall right
    vein_locations = sample(range(4), int(no_veins[j]))

    for k in range(len(vein_locations)):
      vein_location = vein_locations[k]

      if vein_location == 0:
        if (j == 0):
          marginal_sinus_veins[0] = 1
        else:
          septal_wall_veins[j-1][2] = 1
      elif vein_location == 1:
        normal_vessels[j][0] = 1
      elif vein_location == 2:
        normal_vessels[j][2] = 1
      elif vein_location == 3:
        if (j == no_placentones-1):
          marginal_sinus_veins[1] = 1
        else:
          septal_wall_veins[j][0] = 1

  return normal_vessels.tolist(), marginal_sinus_veins.tolist(), septal_wall_veins.tolist()

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
mesh_resolution = 0.01

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

# Clean and compile.
from programs import velocity_transport
velocity_transport.setup(clean=True, terminal_output=True, compile=True, compile_clean=False, run_type=run_type, verbose_output=True)

# Sampling parameters.
min_value     = 0
max_value     = 4
range_value   = max_value - min_value
no_samples    = 9
no_subsamples = 20
std           = range_value/(2*(no_samples-1))
parameter_nominal = 2
parameter_name = "veins"

##################
# SIMULATION RUN #
##################
from miscellaneous import output

run_no = 0
parameter_means = np.linspace(min_value + std, max_value - std, no_samples)
output.output(f"Varying {parameter_name} mean between {min_value}+σ and {max_value}-σ, σ={std}", True)

# Generate vein locations.
from scipy.stats import truncnorm
all_normal_vessels       = []
all_septal_wall_veins    = []
all_marginal_sinus_veins = []
for i in range(0, no_samples):
  mean = parameter_means[i]

  for j in range(0, no_subsamples):
    # Calculate number of veins in each placentone and their locations.
    no_veins       = calculate_no_veins(min_value, max_value, mean, std, no_placentones)
    vein_locations = calculate_vein_locations(no_veins)

    # Add these selections to the list of all selections.
    all_normal_vessels      .append(vein_locations[0])
    all_marginal_sinus_veins.append(vein_locations[1])
    all_septal_wall_veins   .append(vein_locations[2])

# Run simulations.
for i in range(0, no_samples*no_subsamples):
  velocity_transport.run(i, "nsb", "placenta", vessel_locations_nominal, central_cavity_width_nominal, central_cavity_height_nominal, central_cavity_transition_nominal, pipe_transition_nominal, artery_length_nominal, mesh_resolution, log_cavity_transition, L, U, mu, rho, k, D, R, terminal_output=True, verbose_output=False, velocity_oscillation_tolerance=1e-4, transport_oscillation_tolerance=1e-1, plot=False, rerun_on_oscillation=False, no_time_steps=0, final_time=1.0, no_threads=no_threads, no_placentones=no_placentones, run_type=run_type, no_reynold_ramp_steps=1, reynold_ramp_start_ratio=0.2, reynold_ramp_step_base=2, artery_width=artery_width, artery_width_sm=artery_width_sm, linear_solver=linear_solver, moving_mesh=False, compute_velocity=True, compute_transport=True, compute_permeability=True, compute_uptake=True, vessel_fillet_radius=vessel_fillet_radius, wall_height_ratio=1.0, oscillation_detection=False, normal_vessels=all_normal_vessels[i], marginal_sinus=all_marginal_sinus_veins[i], septal_veins=all_septal_wall_veins[i])

# Store the integrals outputted.
from miscellaneous import get_transport_reaction_integral
integral = np.zeros(no_samples*no_subsamples)
for i in range(no_samples*no_subsamples):
  integral[i] = get_transport_reaction_integral.get_transport_reaction_integral('velocity-transport', 'placenta', i+1)
integral_average = integral.reshape([no_samples, no_subsamples]).mean(axis=1)

# Plotting. 
import matplotlib.pyplot as plt
plt.plot(parameter_means, integral_average, '--', color='k')
for i in range(0, no_samples):
  plt.boxplot(integral[i*no_subsamples:(i+1)*no_subsamples], positions=[parameter_means[i]], widths=0.75*std, labels=[f'{parameter_means[i]:.2f}'])

plt.xlabel(f"{parameter_name} mean")
plt.ylabel("Uptake")
plt.title(f"Uptake vs {parameter_name} mean")
plt.xlim([min_value, max_value])
plt.savefig(f"./images/vary_{parameter_name}.png", dpi=300)

# Output measured quantities.
output.output("##########################", True)
output.output(f"Fluxes: {velocity_transport.flux_cache}", True)
output.output(f"Integrals: {velocity_transport.integral_cache}", True)

# Save output.
output.save()

