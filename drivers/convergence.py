from programs import velocity_transport_convergence, velocity_transport

# Problem setup.
parameters = velocity_transport_convergence.get_default_run_parameters()
parameters["verbose_output"] = True
parameters["no_threads"]     = 1
parameters["scaling_D"] = 1.0
parameters["scaling_L"] = 1.0
parameters["scaling_R"] = 1.0
parameters["scaling_U"] = 1.0
parameters["scaling_k"] = 1.0
parameters["scaling_mu"] = 1.0
parameters["scaling_rho"] = 1.0

# Clean and compile.
velocity_transport.setup(clean=True, terminal_output=True, compile=True, compile_clean=False, run_type=parameters["run_type"], verbose_output=True, compile_entry='velocity-transport_convergence')

# Run the simulations.
parameters["geometry"] = "square_analytic"

parameters["final_time"]      = 0.0
parameters["no_time_steps"]   = 0
parameters["test_type"]       = "ss_velocity_space"
parameters["mesh_resolution"] = 2
parameters["moving_mesh"]     = False
velocity_transport_convergence.run(1, parameters)

parameters["final_time"]      = 1.0e-3
parameters["no_time_steps"]   = 10
parameters["test_type"]       = "velocity_space"
parameters["mesh_resolution"] = 2
parameters["moving_mesh"]     = False
velocity_transport_convergence.run(2, parameters)

parameters["final_time"]      = 1.0
parameters["no_time_steps"]   = 2
parameters["test_type"]       = "velocity_time"
parameters["mesh_resolution"] = 0.1
parameters["moving_mesh"]     = False
velocity_transport_convergence.run(3, parameters)

parameters["final_time"]         = 1e-1
parameters["no_time_steps"]      = 10
parameters["test_type"]          = "mm_velocity_space"
parameters["mesh_resolution"]    = 2
parameters["moving_mesh"]        = True
parameters["mesh_velocity_type"] = "constant_up"
velocity_transport_convergence.run(4, parameters)

parameters["geometry"] = "square_constant_diagonal"

parameters["final_time"]         = 1.0
parameters["no_time_steps"]      = 2
parameters["test_type"]          = "mm_velocity_time"
parameters["mesh_resolution"]    = 0.1
parameters["moving_mesh"]        = True
parameters["mesh_velocity_type"] = "constant_up"
velocity_transport_convergence.run(5, parameters)

# Save output.
from miscellaneous import output
output.save()