####################
# SIMULATION SETUP #
####################
from programs import velocity_transport

parameters = velocity_transport.get_default_run_parameters()

parameters["moving_mesh"]   = True
parameters["no_time_steps"] = 1
parameters["final_time"]    = 0.1

parameters["verbose_output"] = True

parameters["mesh_resolution"] = 1

##################
# SIMULATION RUN #
##################
import numpy as np

# Clean and compile.
velocity_transport.setup(clean=False, terminal_output=True, compile=True, compile_clean=False, run_type=parameters["run_type"], verbose_output=True)

# Run simulations.
velocity_transport.run(1, parameters)

# Output measured quantities.
from miscellaneous import output
output.output("##########################", True)
output.output(f"Fluxes: {velocity_transport.flux_cache}", True)
output.output(f"Integrals: {velocity_transport.integral_cache}", True)

# Save output.
output.save()