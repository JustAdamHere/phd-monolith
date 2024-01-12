####################
# SIMULATION SETUP #
####################
from programs import velocity_comparison, velocity_transport

parameters = velocity_transport.get_default_run_parameters()

parameters["verbose_output"] = True
parameters["no_placentones"] = 1
parameters["geometry"]       = 'placentone'

parameters["no_threads"] = 20

parameters["mesh_resolution"] = 0.02

parameters["plot"] = True

##################
# SIMULATION RUN #
##################
# Clean and compile.
# velocity_transport.setup(clean=False, terminal_output=True, compile=True, compile_clean=False, run_type=parameters["run_type"], verbose_output=True)
velocity_comparison.setup(clean=False, terminal_output=True, compile=True, compile_clean=False, run_type=parameters["run_type"], verbose_output=True)

# Run simulations.
# velocity_transport.run(1, parameters)
velocity_comparison.run(1, parameters)