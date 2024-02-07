####################
# SIMULATION SETUP #
####################
from programs import velocity_transport
parameters = velocity_transport.get_default_run_parameters()

parameters["verbose_output"] = False

parameters["mesh_resolution"] = 0.1

parameters["run_type"]      = 'openmp'
parameters["linear_solver"] = 'mumps'
parameters["no_threads"]    = 1

parameters["moving_mesh"]   = True
parameters["no_time_steps"] = 10
parameters["final_time"]    = 1.0

parameters["error_on_fail"] = False

parameters['scaling_D']   = 1.0
parameters['scaling_L']   = 1.0
parameters['scaling_R']   = 1.0
parameters['scaling_U']   = 1.0
parameters['scaling_k']   = 1.0
parameters['scaling_mu']  = 1.0
parameters['scaling_rho'] = 1.0

parameters["newton_tolerance"] = 1e-10

parameters["compute_error_norms"] = True

velocity_transport.setup(clean=True, terminal_output=True, compile=True, compile_clean=False, run_type=parameters["run_type"], verbose_output=True, compile_entry='velocity-transport')

##################
# SIMULATION RUN #
##################
parameters["geometry"] = "square_zero"
parameters["mesh_velocity_type"] = "etienne2009"
velocity_transport.run(1, parameters)

parameters["geometry"] = "square_constant_up"
parameters["mesh_velocity_type"] = "etienne2009"
velocity_transport.run(2, parameters)

parameters["geometry"] = "square_constant_diagonal"
parameters["mesh_velocity_type"] = "etienne2009"
velocity_transport.run(3, parameters)

parameters["geometry"] = "square_shear"
parameters["mesh_velocity_type"] = "etienne2009"
velocity_transport.run(4, parameters)

parameters["geometry"] = "square_poiseuille"
parameters["mesh_velocity_type"] = "etienne2009"
velocity_transport.run(5, parameters)

parameters["geometry"] = "square_analytic"
parameters["mesh_velocity_type"] = "etienne2009"
velocity_transport.run(6, parameters)