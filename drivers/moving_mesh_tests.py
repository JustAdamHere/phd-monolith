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

parameters["error_on_fail"] = True

velocity_transport.setup(clean=True, terminal_output=True, compile=True, compile_clean=False, run_type=parameters["run_type"], verbose_output=True, compile_entry='velocity-transport')

##################
# SIMULATION RUN #
##################
parameters["geometry"] = "square_zero"
parameters["mesh_velocity_type"] = "zero"
velocity_transport.run(1, parameters)

parameters["geometry"] = "square_constant_up"
parameters["mesh_velocity_type"] = "zero"
velocity_transport.run(2, parameters)

parameters["geometry"] = "square_constant_diagonal"
parameters["mesh_velocity_type"] = "zero"
velocity_transport.run(3, parameters)

parameters["geometry"] = "square_poiseuille"
parameters["mesh_velocity_type"] = "zero"
velocity_transport.run(4, parameters)

parameters["geometry"] = "square_zero"
parameters["mesh_velocity_type"] = "interior"
velocity_transport.run(5, parameters)

# Issues here ->
parameters["geometry"] = "square_constant_up"
parameters["mesh_velocity_type"] = "interior"
velocity_transport.run(6, parameters)

# Issue here ->
parameters["geometry"] = "square_constant_diagonal"
parameters["mesh_velocity_type"] = "interior"
velocity_transport.run(7, parameters)

# Issue here ->
parameters["geometry"] = "square_poiseuille"
parameters["mesh_velocity_type"] = "interior"
velocity_transport.run(8, parameters)

parameters["geometry"] = "square_zero"
parameters["mesh_velocity_type"] = "constant_up"
velocity_transport.run(9, parameters)

parameters["geometry"] = "square_constant_up"
parameters["mesh_velocity_type"] = "constant_up"
velocity_transport.run(10, parameters)

parameters["geometry"] = "square_constant_diagonal"
parameters["mesh_velocity_type"] = "constant_up"
velocity_transport.run(11, parameters)

parameters["geometry"] = "square_poiseuille"
parameters["mesh_velocity_type"] = "constant_up"
velocity_transport.run(12, parameters)

parameters["geometry"] = "square_zero"
parameters["mesh_velocity_type"] = "shear"
velocity_transport.run(13, parameters)

parameters["geometry"] = "square_constant_up"
parameters["mesh_velocity_type"] = "shear"
velocity_transport.run(14, parameters)

parameters["geometry"] = "square_constant_diagonal"
parameters["mesh_velocity_type"] = "shear"
velocity_transport.run(15, parameters)

parameters["geometry"] = "square_poiseuille"
parameters["mesh_velocity_type"] = "shear"
velocity_transport.run(16, parameters)




# parameters["geometry"] = "square_poiseuille"
# parameters["mesh_velocity_type"] = "constant_up"
# velocity_transport.run(12, parameters)

# parameters["geometry"] = "square_zero"
# parameters["mesh_velocity_type"] = "constant_up"
# parameters["moving_mesh"] = True
# parameters["no_time_steps"] = 10
# parameters["final_time"] = 1.0
# velocity_transport.run(9, parameters)

# parameters["geometry"] = "square_zero"
# MOVING MESH: BOTH interior and BOUNDARY, see paper's MH sent
# velocity_transport.run(9, parameters)

# parameters["geometry"] = "square_constant_up"
# # MOVING MESH: BOTH interior and BOUNDARY, see paper's MH sent
# velocity_transport.run(10, parameters)

# parameters["geometry"] = "square_constant_diagonal"
# # MOVING MESH: BOTH interior and BOUNDARY, see paper's MH sent
# velocity_transport.run(11, parameters)

# parameters["geometry"] = "square_poiseuille"
# # MOVING MESH: BOTH interior and BOUNDARY, see paper's MH sent
# velocity_transport.run(12, parameters)

# MORE COMPLICATED SQUEEZING AND STRETCHING