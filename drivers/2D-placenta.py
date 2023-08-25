####################
# SIMULATION SETUP #
####################
# Nominal values of parameters.
artery_location_nominal   = 0.5
vein_location_1_nominal   = 0.2
vein_location_2_nominal   = 0.8

# Geometry measurements.
central_cavity_nominal            = 0.25 # 10mm
central_cavity_transition_nominal = 0.04 # 1.6mm
pipe_transition_nominal           = 0.03 # 1.2mm
artery_width                      = 0.06 # 2.4mm

# Mesh.
mesh_resolution_default = 0.1

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
run_type = 'openmp'

##################
# SIMULATION RUN #
##################
# Clean and compile.
from programs import velocity_transport
velocity_transport.setup(clean=True, terminal_output=True, compile=False, programs_to_compile='nsb-transport_placenta', run_type=run_type)

# Vary mesh resolution.
import matplotlib.pyplot as plt
from plotting import calculate_transport_limits
from plotting import calculate_velocity_limits

# Run simulations.
velocity_transport.run(0, "nsb", "placenta", artery_location_nominal, vein_location_1_nominal, vein_location_2_nominal, central_cavity_nominal, central_cavity_transition_nominal, pipe_transition_nominal, artery_length_nominal, mesh_resolution_default, log_cavity_transition, L, U, mu, rho, k, D, R, terminal_output=True, verbose_output=True, velocity_oscillation_tolerance=1e-4, transport_oscillation_tolerance=1e-1, plot=True, rerun_on_oscillation=False, no_time_steps=0, final_time=0.0, marginal_sinus=[1, 1], no_threads=20, no_placentones=6, run_type=run_type, no_reynold_ramp_steps=10, reynold_ramp_start_ratio=0.1, reynold_ramp_step_base=2, artery_width=artery_width)

# Output measured quantities.
from miscellaneous import output
output.output("##########################", True)
output.output(f"Fluxes: {velocity_transport.flux_cache}", True)
output.output(f"Integrals: {velocity_transport.integral_cache}", True)

# Save output.
output.save()