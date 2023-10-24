####################
# SIMULATION SETUP #
####################
from programs import velocity_transport

parameters = velocity_transport.get_default_run_parameters()

parameters["moving_mesh"]   = True
parameters["no_time_steps"] = 1
parameters["final_time"]    = 0.5

parameters["verbose_output"] = True

parameters["mesh_resolution"] = 0.05

parameters["compute_permeability"] = True
parameters["compute_transport"] = False
parameters["compute_uptake"] = False
parameters["compute_velocity"] = False

# File handling.
parameters["clean_files"][0] = False  # Output VTKs.
parameters["clean_files"][1] = True  # Output restarts.
parameters["clean_files"][2] = True # Output data files.
parameters["clean_files"][3] = False # Output log files.
parameters["clean_files"][4] = True  # Mesh mshs.
parameters["clean_files"][5] = True  # Mesh VTKs.
parameters["clean_files"][6] = True # Images.

##################
# SIMULATION RUN #
##################
import numpy as np

# Clean and compile.
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