####################
# SIMULATION SETUP #
####################
from programs import velocity_transport

parameters = velocity_transport.get_default_run_parameters()

# Output.
parameters["terminal_output"] = True
parameters["verbose_output"]  = False
parameters["plot"]            = True

# Mesh resolution.
parameters["mesh_resolution"] = 0.02

# Simulation.
parameters["compute_permeability"       ] = True
parameters["compute_transport"          ] = True
parameters["compute_uptake"             ] = True
parameters["compute_velocity"           ] = True
parameters["compute_velocity_average"   ] = True
parameters["compute_velocity_sample"    ] = True
parameters["run_mesh_generation"        ] = True
parameters["run_aptofem_simulation"     ] = True
parameters["run_set_aptofem_parameters" ] = True
parameters["oscillation_detection"      ] = True

# File handling.
parameters["compress_output"] = False
parameters["clean_files"][0]  = False # Output VTKs.
parameters["clean_files"][1]  = False # Output restarts.
parameters["clean_files"][2]  = False # Output data files.
parameters["clean_files"][3]  = False # Output log files.
parameters["clean_files"][4]  = False # Mesh mshs.
parameters["clean_files"][5]  = False # Mesh VTKs.
parameters["clean_files"][6]  = False # Images.

# Reruns.
parameters["error_on_fail"           ] = True
parameters["rerun_with_reynold_steps"] = False

# Run type.
parameters["run_type"]      = 'openmp'
parameters["linear_solver"] = 'mumps'
parameters["no_threads"]    = 20

##################
# SIMULATION RUN #
##################
# Clean and compile.
velocity_transport.setup(clean=True, terminal_output=True, compile=True, compile_clean=False, run_type=parameters["run_type"], verbose_output=True)

# Run simulations.
parameters["velocity_model"] = "s-b"
parameters["geometry"]       = "placentone"
velocity_transport.run(1, parameters)

parameters["velocity_model"] = "ns-b"
parameters["geometry"]       = "placentone"
velocity_transport.run(2, parameters)

parameters["velocity_model"] = "ns-nsb"
parameters["geometry"]       = "placentone"
velocity_transport.run(3, parameters)

parameters["velocity_model"] = "nsb"
parameters["geometry"]       = "placentone"
velocity_transport.run(4, parameters)

parameters["velocity_model"] = "s-b"
parameters["geometry"]       = "placenta"
velocity_transport.run(5, parameters)

parameters["velocity_model"] = "ns-b"
parameters["geometry"]       = "placenta"
velocity_transport.run(6, parameters)

parameters["velocity_model"] = "ns-nsb"
parameters["geometry"]       = "placenta"
velocity_transport.run(7, parameters)

parameters["velocity_model"] = "nsb"
parameters["geometry"]       = "placenta"
velocity_transport.run(8, parameters)

# Save output.
from miscellaneous import output
output.save()