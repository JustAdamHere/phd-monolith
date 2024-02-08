####################
# SIMULATION SETUP #
####################
from programs import velocity_transport

parameters = velocity_transport.get_default_run_parameters()

# Simulation.
parameters["compute_mri"                ] = True
parameters["compute_permeability"       ] = False
parameters["compute_transport"          ] = False
parameters["compute_uptake"             ] = False
parameters["compute_velocity"           ] = False
parameters["compute_velocity_average"   ] = False
parameters["compute_velocity_sample"    ] = False
parameters["run_mesh_generation"        ] = False
parameters["run_aptofem_simulation"     ] = False
parameters["run_set_aptofem_parameters" ] = False
parameters["oscillation_detection"      ] = False

# MRI.
parameters["mri_simple_flow"] = True
parameters["geometry"] = 'shear_0_01_test'

# Output.
parameters["terminal_output"] = True
parameters["verbose_output"]  = True

##################
# SIMULATION RUN #
##################
# Clean and compile.
velocity_transport.setup(clean=True, terminal_output=True, compile=True, compile_clean=False, run_type=parameters["run_type"], verbose_output=True)

# Run simulations.
velocity_transport.run(1, parameters)

# Save output.
from miscellaneous import output
output.save()