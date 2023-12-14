from programs import velocity_transport_convergence, velocity_transport

# Problem setup.
parameters = velocity_transport_convergence.get_default_run_parameters()

# Clean and compile.
velocity_transport.setup(clean=True, terminal_output=True, compile=True, compile_clean=False, run_type=parameters["run_type"], verbose_output=True, compile_entry='velocity-transport_convergence')

# Run.
velocity_transport_convergence.run(1, parameters)

# Save output.
from miscellaneous import output
output.save()