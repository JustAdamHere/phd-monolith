####################
# SIMULATION SETUP #
####################
# Nominal values of parameters.
artery_location_nominal   = 0.5
vein_location_1_nominal   = 0.2
vein_location_2_nominal   = 0.8

# Geometry measurements.
central_cavity_nominal    = 0.25         # 10mm
central_cavity_transition_nominal = 0.05 # 2mm
pipe_transition_nominal   = 0.03         # 2mm
artery_length_nominal     = 0.05         # 2mm

# Mesh.
mesh_resolution_default = 0.05

# Unused.
log_cavity_transition = False

# Problem parameters.
L   = 0.04     # m
U   = 0.4 # m/s
k   = 1e-8     # m^2
mu  = 4e-3     # Pa s
rho = 1e3      # kg/m^3
D   = 1.667e-9 # m^2/s
R   = 1.667e-2 # m^2/s

##################
# SIMULATION RUN #
##################
# Clean and compile.
from programs import velocity_transport
velocity_transport.setup(clean=True, terminal_output=True, compile=True, programs_to_compile='nsb-transport_placenta')

# Vary mesh resolution.
import matplotlib.pyplot as plt
from plotting import calculate_transport_limits
from plotting import calculate_velocity_limits

# Run simulation.
velocity_transport.run(0, "nsb", "placenta", artery_location_nominal, vein_location_1_nominal, vein_location_2_nominal, central_cavity_nominal, central_cavity_transition_nominal, pipe_transition_nominal, artery_length_nominal, mesh_resolution_default, log_cavity_transition, L, U, mu, rho, k, D, R, terminal_output=True, verbose_output=False, velocity_oscillation_tolerance=1e-4, transport_oscillation_tolerance=1e-1, plot=True, rerun_on_oscillation=False, normal_vessels=[[0, 1, 1], [1, 1, 0], [1, 1, 0], [0, 1, 1], [1, 1, 0], [0, 1, 1]])
# Compute MRI quantities.
# TODO: MAKE THIS NICE.
import subprocess
from miscellaneous import save_output
try:
  run_output = subprocess.run(['matlab', '-nodisplay', '-r', "run('driver_2D_placenta.m'); exit;"], cwd='./mri_code/', stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=True)
  save_output.save_output(run_output, "mri", "placenta", 0)
except subprocess.CalledProcessError as e:
  save_output.save_output(e, "mri", "placenta", 0)

# Output measured quantities.
from miscellaneous import output
output.output("##########################", True)
output.output(f"Fluxes: {velocity_transport.flux_cache}", True)
output.output(f"Integrals: {velocity_transport.integral_cache}", True)

# Save output.
output.save()