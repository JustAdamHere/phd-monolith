####################
# SIMULATION SETUP #
####################
from programs import velocity_transport

parameters = velocity_transport.get_default_run_parameters()

# Nominal values of parameters.
parameters["normal_vessel_locations_nominal"] = [[0.2, 0.5, 0.8], [0.2, 0.5, 0.8], [0.2, 0.5, 0.8], [0.2, 0.5, 0.8], [0.2, 0.5, 0.8], [0.2, 0.5, 0.8]]
parameters["basal_plate_vessels"]             = [[1, 1, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]]
parameters["marginal_sinus"]                  = [0, 0]

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
parameters["mesh_resolution"] = 0.1#0.02
# parameters["mesh_resolution"] = [0.1]*8
# parameters["mesh_resolution"][1] = 0.001
# parameters["mesh_resolution"][2] = 0.001

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
parameters["run_type"]      = 'serial'
parameters["linear_solver"] = 'mumps'
parameters["no_threads"]    = 1

# File handling.
#parameters["clean_files"] = [True, True, False, False, True, True, False]
parameters["clean_files"] = [False]*7

# What to compute.
parameters["compute_velocity"]     = True
parameters["compute_transport"]    = False
parameters["compute_permeability"] = True
parameters["compute_uptake"]       = False

##################
# SIMULATION RUN #
##################
import numpy as np

# Clean and compile.
velocity_transport.setup(clean=False, terminal_output=True, compile=True, compile_clean=False, run_type=parameters["run_type"], verbose_output=True)

# Sampling parameters.
min_value      = 0
max_value      = 27
range_value    = max_value - min_value
no_samples     = 28
no_subsamples  = 1000
parameter_name = "number_of_veins"

# Run simulations.
velocity_transport.run(1, parameters)

# Output measured quantities.
from miscellaneous import output
output.output("##########################", True)
output.output(f"Fluxes: {velocity_transport.flux_cache}", True)
output.output(f"Integrals: {velocity_transport.integral_cache}", True)

# Save output.
output.save()