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
log_cavity_transition     = False

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
from programs import velocity_comparison
velocity_comparison.setup(clean=True, terminal_output=True, compile=True)

# Run simulation.
velocity_comparison.run(0, "placentone", artery_location_nominal, vein_location_1_nominal, vein_location_2_nominal, central_cavity_nominal, central_cavity_transition_nominal, pipe_transition_nominal, artery_length_nominal, mesh_resolution_default, log_cavity_transition, L, U, mu, rho, k, terminal_output=True, verbose_output=False, plot=True)

from miscellaneous import output

# Save output.
output.save()