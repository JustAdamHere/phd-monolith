def get_default_run_parameters():
	parameters_dictionary =  {
		'clean_files'                      : [False, False, False, False, False, False, False],
		'error_on_fail'                    : True,
		'extra_text'                       : '',
		'final_time'                       : 0.0,
		'geometry'                         : 'square',
		'linear_solver'                    : 'mumps',
		'mesh_resolution'                  : 1,
		'moving_mesh'                      : False,
		'no_threads'                       : 1,
		'no_time_steps'                    : 0,
		'plot'                             : False,
		'problem_dim'                      : 2,
		'run_type'                         : 'openmp',
		'terminal_output'                  : True,
		'transport_convection_coefficient' : 1.0,
		'transport_diffusion_coefficient'  : 1.0,
		'transport_forcing_coefficient'    : 1.0,
		'transport_reaction_coefficient'   : 1.0,
		'transport_time_coefficient'       : 1.0,
		'velocity_convection_coefficient'  : 1.0,
		'velocity_diffusion_coefficient'   : 1.0,
		'velocity_forcing_coefficient'     : 1.0,
		'velocity_pressure_coefficient'    : 1.0,
		'velocity_reaction_coefficient'    : 1.0,
		'velocity_time_coefficient'        : 1.0,
		'velocity_model'                   : 'nsb',
		'velocity_space'                   : 'DG',
		'verbose_output'                   : True
	}

	return parameters_dictionary

def run(simulation_no, p):
	if (set(p.keys()) != set(get_default_run_parameters().keys())):
		unexpected_keys = set(p.keys()) - set(get_default_run_parameters().keys())
		missing_keys 	  = set(get_default_run_parameters().keys()) - set(p.keys())
		error_string = f"Incorrect parameters in velocity_transport_convergence.run(). Unexpected keys found: {unexpected_keys}. Missing keys: {missing_keys}"
		raise ValueError(error_string)
	
	assert(p["velocity_model" ] in ['nsb'        , 'ns-nsb'        , 'ns-b'     , 's-b'  ])
	assert(p["run_type"       ] in ['serial'     , 'openmp'        , 'mpi'               ])
	assert(p["geometry"       ] in ['placentone' , 'placentone-3d' , 'placenta', 'square'])

	from miscellaneous import output, output_timer
	output.output( "##########################", p["terminal_output"])
	output.output(f"Running simulation # {simulation_no}... {p['extra_text']}", p["terminal_output"], flush=True)
	output.output( "##########################", p["terminal_output"])

	#################
	# GENERATE MESH #
	#################
	from meshes import generate_mesh
	output_timer.time(simulation_no, "mesh generation", p["terminal_output"])
	generate_mesh.generate_simple_mesh(simulation_no, p["geometry"], p["mesh_resolution"])
	output_timer.time(simulation_no, "mesh generation", p["terminal_output"])

	##################
	# RUN SIMULATION #
	##################
	output_timer.time(simulation_no, "AptoFEM simulation", p["terminal_output"])
	result = aptofem_simple_simulation(simulation_no, p["velocity_model"], p["geometry"], p["velocity_diffusion_coefficient"], p["velocity_convection_coefficient"], p["velocity_reaction_coefficient"], p["velocity_pressure_coefficient"], p["velocity_time_coefficient"], p["velocity_forcing_coefficient"], p["transport_diffusion_coefficient"], p["transport_convection_coefficient"], p["transport_reaction_coefficient"], p["transport_time_coefficient"], p["transport_forcing_coefficient"], p["verbose_output"], p["terminal_output"], p["final_time"], p["no_time_steps"], p["no_threads"], p["run_type"], p["linear_solver"], p["problem_dim"], p["error_on_fail"])
	output_timer.time(simulation_no, "AptoFEM simulation", p["terminal_output"])

def aptofem_simple_simulation(simulation_no, velocity_model, geometry, velocity_diffusion_coefficient, velocity_convection_coefficient, velocity_reaction_coefficient, velocity_pressure_coefficient, velocity_time_coefficient, velocity_forcing_coefficient, transport_diffusion_coefficient, transport_convection_coefficient, transport_reaction_coefficient, transport_time_coefficient, transport_forcing_coefficient, verbose_output, terminal_output, final_time, no_time_steps, no_threads, run_type, linear_solver, problem_dim, error_on_fail):
	from miscellaneous import set_parameter, set_run_numbers, output, raise_error
	import subprocess

	# Fixed.
	program           = "velocity-transport_convergence"
	program_directory = f"programs/velocity-transport/"

	# Set run no.
	set_run_numbers.set_run_numbers(simulation_no-1, "velocity-transport")

	# Number of threads.
	import os
	if (run_type == 'openmp'):
		os.environ["OMP_NUM_THREADS"] = f"{no_threads}"
		set_parameter.set_parameter("velocity-transport", 7, f"aptofem_no_openmp_threads {no_threads}")
	else:
		os.environ["OMP_NUM_THREADS"] = "1"

	# Set mesh.
	set_parameter.set_parameter("velocity-transport", 13, f"problem_dim {problem_dim}")
	set_parameter.set_parameter("velocity-transport", 15, f"mesh_file_name mesh_{simulation_no}.msh")
	set_parameter.set_parameter("velocity-transport", 16, f"mesh_file_dir ../../meshes/")

	# Set finite element space.
	velocity_space_order     = 'q,2,2,1'
	transport_space_order    = 'q,1'
	permeability_space_order = 'q,1'
	uptake_space_order       = 'q,1'
	space_region_ids         = '300'

	set_parameter.set_parameter("velocity-transport", 21, f"fe_space DG({velocity_space_order};region={space_region_ids})")
	set_parameter.set_parameter("velocity-transport", 24, f"fe_space DG({transport_space_order};region={space_region_ids})")
	set_parameter.set_parameter("velocity-transport", 27, f"fe_space DG({permeability_space_order};region={space_region_ids})")
	set_parameter.set_parameter("velocity-transport", 30, f"fe_space DG({uptake_space_order};region={space_region_ids})")

	# Set problem parameters (only some here for now).
	set_parameter.set_parameter("velocity-transport", 66, f"velocity_diffusion_coefficient {velocity_diffusion_coefficient:.4e}")
	set_parameter.set_parameter("velocity-transport", 67, f"velocity_convection_coefficient {velocity_convection_coefficient:.4e}")
	set_parameter.set_parameter("velocity-transport", 68, f"velocity_reaction_coefficient {velocity_reaction_coefficient:.4e}")
	set_parameter.set_parameter("velocity-transport", 69, f"velocity_pressure_coefficient {velocity_pressure_coefficient:.4e}")
	set_parameter.set_parameter("velocity-transport", 70, f"velocity_time_coefficient {velocity_time_coefficient:.4e}")
	set_parameter.set_parameter("velocity-transport", 71, f"velocity_forcing_coefficient {velocity_forcing_coefficient:.4e}")

	set_parameter.set_parameter("velocity-transport", 73, f"transport_diffusion_coefficient {transport_diffusion_coefficient:.4e}")
	set_parameter.set_parameter("velocity-transport", 74, f"transport_convection_coefficient {transport_convection_coefficient:.4e}")
	set_parameter.set_parameter("velocity-transport", 75, f"transport_reaction_coefficient {transport_reaction_coefficient:.4e}")
	set_parameter.set_parameter("velocity-transport", 76, f"transport_time_coefficient {transport_time_coefficient:.4e}")
	set_parameter.set_parameter("velocity-transport", 77, f"transport_forcing_coefficient {transport_forcing_coefficient:.4e}")

	# Time dependence.
	set_parameter.set_parameter("velocity-transport", 153, f"dirk_final_time {final_time:.4e}")
	set_parameter.set_parameter("velocity-transport", 154, f"dirk_number_of_timesteps {no_time_steps}")

	# Error when Newton solver doesn't converge.
	set_parameter.set_parameter("velocity-transport", 166, f"newton_terminate_on_fail .{str(error_on_fail).lower()}.")

	# Linear solver.
	set_parameter.set_parameter("velocity-transport", 171, f"linear_solver {linear_solver}")
	set_parameter.set_parameter("velocity-transport", 190, f"linear_solver {linear_solver}")

	# Set velocity solution variables depending on problem dimension.
	if (problem_dim == 2):
		set_parameter.set_parameter("velocity-transport", 214, f"variable_1 u")
		set_parameter.set_parameter("velocity-transport", 215, f"variable_2 v")
		set_parameter.set_parameter("velocity-transport", 216, f"variable_3 p")
		set_parameter.set_parameter("velocity-transport", 217, f"")

		set_parameter.set_parameter("velocity-transport", 226, f"variable_1 u")
		set_parameter.set_parameter("velocity-transport", 227, f"variable_2 v")
		set_parameter.set_parameter("velocity-transport", 228, f"variable_3 p")
		set_parameter.set_parameter("velocity-transport", 229, f"")
	elif (problem_dim == 3):
		set_parameter.set_parameter("velocity-transport", 214, f"variable_1 u")
		set_parameter.set_parameter("velocity-transport", 215, f"variable_2 v")
		set_parameter.set_parameter("velocity-transport", 216, f"variable_3 w")
		set_parameter.set_parameter("velocity-transport", 217, f"variable_4 p")

		set_parameter.set_parameter("velocity-transport", 226, f"variable_1 u")
		set_parameter.set_parameter("velocity-transport", 227, f"variable_2 v")
		set_parameter.set_parameter("velocity-transport", 228, f"variable_3 w")
		set_parameter.set_parameter("velocity-transport", 229, f"variable_4 p")
	else:
		raise ValueError(f"Unknown problem dimension: {problem_dim}")	
	
	# Run AptoFEM simulation.
	run_commands = [f'./velocity-transport_convergence.out', f'{velocity_model}', f'ss_velocity_space', '5']
	if (run_type == 'mpi'):
		run_commands = ['mpirun', '-n', f'{no_threads}'] + run_commands
	run_process = subprocess.Popen(run_commands, cwd=program_directory, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

	# Display last line of output to screen, and write lines to file.
	line_truncation = 123
	if (verbose_output):
		end = '\r\n'
	else:
		end = '\r'
	run_output = open(f"./output/{program}_{geometry}_{simulation_no}.txt", "w")
	output.output("", terminal_output)
	while run_process.poll() is None:
		line = run_process.stdout.readline().decode('utf-8').rstrip('\r\n')
		if (line != ""):
			output.output(f">>> {line[:line_truncation]:<{line_truncation}}", terminal_output, end='')
			if (len(line) > line_truncation):
				output.output("...", terminal_output, end=end)
			else:
				output.output("", terminal_output, end=end)
			run_output.write(line + '\n')
	run_output.close()
	if (verbose_output):
		output.output("", terminal_output, end='\rStarting AptoFEM simulation... ')
	else:
		output.output("", terminal_output, end='\x1b[1A\rStarting AptoFEM simulation... ')

	# Possibly return an error.
	if (run_process.poll() != 0):
		raise_error.raise_error(run_process.stderr.read())

	errors = []
	
	return simulation_no, errors