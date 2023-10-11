####################
# SIMULATION SETUP #
####################
from programs import velocity_transport

parameters = velocity_transport.get_default_run_parameters()

# Nominal values of parameters.
parameters["normal_vessel_locations_nominal"] = [[0.2, 0.5, 0.8], [0.2, 0.5, 0.8], [0.2, 0.5, 0.8], [0.2, 0.5, 0.8], [0.2, 0.5, 0.8], [0.2, 0.5, 0.8]]

# Geometry measurements (Zak).
# central_cavity_width_nominal      = 2*0.1
# central_cavity_height_nominal     = [2*0.0974, 2*0.2210, 2*0.2924, 2*0.2924, 2*0.2210, 2*0.0974]
# central_cavity_transition_nominal = 0.01
# pipe_transition_nominal           = 0.03 
# artery_width                      = 0.025*2
# artery_width_sm                   = 0.05

# Geometry measurements.
parameters["central_cavity_width_nominal"]      = 0.25   # 10mm
parameters["central_cavity_height_nominal"]     = 0.50   # 20mm
parameters["central_cavity_transition_nominal"] = 0.12#0.04   # 1.6mm
parameters["pipe_transition_nominal"]           = 0.03   # 1.2mm
parameters["vessel_fillet_radius"]              = 0.01
parameters["artery_width"]                      = 0.06   # 2.4mm
parameters["artery_width_sm"]                   = 0.0125 # 0.5mm
parameters["no_placentones"]                    = 6

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
parameters["mesh_resolution"] = 1#0.02

# Unused.
parameters["log_cavity_transition"] = False
parameters["artery_length_nominal"] = 0.25 # 2mm

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
parameters["no_threads"]    = 20

##################
# SIMULATION RUN #
##################
import numpy as np

# Clean and compile.
from programs import velocity_transport
velocity_transport.setup(clean=True, terminal_output=True, compile=True, compile_clean=False, run_type=parameters["run_type"], verbose_output=True)

# Run simulations.
velocity_transport.run(1, parameters)

# Output measured quantities.
from miscellaneous import output
output.output("##########################", True)
output.output(f"Fluxes: {velocity_transport.flux_cache}", True)
output.output(f"Integrals: {velocity_transport.integral_cache}", True)

# Save output.
output.save()