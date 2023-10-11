flux_cache = []
integral_cache = []

def get_default_run_parameters():
	return {
		'artery_length'                  : 0.25,
		'artery_width'                   : 0.06,
		'artery_width_sm'                : 0.0125,
		'basal_plate_vessel_positions'   : [[0.2, 0.5, 0.8], [0.2, 0.5, 0.8], [0.2, 0.5, 0.8], [0.2, 0.5, 0.8], [0.2, 0.5, 0.8], [0.2, 0.5, 0.8]],
		'basal_plate_vessels'            : [[1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1]],
		'central_cavity_height'          : 0.5,
		'central_cavity_transition'      : 0.12,
		'central_cavity_width'           : 0.25,
		'clean_files'                    : [False, False, False, False, False, False, False],
		'compute_mri'                    : False,
		'compute_permeability'           : True,
		'compute_transport'              : True,
		'compute_uptake'                 : True,
		'compute_velocity'               : True,
		'equal_wall_heights'             : False,
		'error_on_fail'                  : True,
		'extra_text'                     : '',
		'final_time'                     : 0.0,
		'generate_outline_mesh'          : False,
		'geometry'                       : 'placenta',
		'large_boundary_v_penalisation'  : False,
		'linear_solver'                  : 'mumps',
		'log_cavity_transition'          : False,
		'marginal_sinus'                 : [1, 1],
		'mesh_resolution'                : 0.1,
		'moving_mesh'                    : False,
		'no_placentones'                 : 6,
		'no_reynold_ramp_steps'          : 1,
		'no_threads'                     : 20,
		'no_time_steps'                  : 0,
		'oscillation_detection'          : True,
		'pipe_transition'                : 0.03,
		'plot'                           : False,
		'rerun_on_oscillation'           : False,
		'reynold_ramp_start_ratio'       : 0.1,
		'reynold_ramp_step_base'         : 2,
		'run_type'                       : 'openmp',
		'scaling_D'                      : 1.667e-09,
		'scaling_L'                      : 0.04,
		'scaling_R'                      : 0.01667,
		'scaling_U'                      : 0.35,
		'scaling_k'                      : 1e-08,
		'scaling_mu'                     : 0.004,
		'scaling_rho'                    : 1000.0,
		'septal_veins'                   : [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]],
		'septal_wall_vein_positions'     : [[0.5, 0.5, 0.5], [0.5, 0.5, 0.5], [0.5, 0.5, 0.5], [0.5, 0.5, 0.5], [0.5, 0.5, 0.5]],
		'terminal_output'                : True,
		'transport_ic_from_ss'           : True,
		'transport_oscillation_tolerance': 0.1,
		'velocity_ic_from_ss'            : True,
		'velocity_model'                 : 'nsb',
		'velocity_oscillation_tolerance' : 0.01,
		'velocity_space'                 : 'DG',
		'verbose_output'                 : False,
		'vessel_fillet_radius'           : 0.01,
		'wall_height_ratio'              : 1.0
	}

def run(simulation_no, p):
	assert(p["velocity_model"] in ['nsb'       , 'ns-nsb'       , 'ns-b'    , 's-b'])
	assert(p["run_type"      ] in ['serial'    , 'openmp'       , 'mpi'            ])
	assert(p["geometry"      ] in ['placentone', 'placentone-3d', 'placenta'       ])

	program = "velocity-transport"

	if (p["no_time_steps"] == 0):
		velocity_ss                 = True
		transport_ss                = True
	else:
		velocity_ss                 = False
		transport_ss                = False
	large_boundary_v_penalisation = False

	from miscellaneous import output
	from miscellaneous import parameters_io

	parameters_io.save_parameters(p, program, p["geometry"], simulation_no)

	output.output( "##########################", p["terminal_output"])
	output.output(f"Running simulation # {simulation_no}... {p['extra_text']}", p["terminal_output"], flush=True)
	output.output( "##########################", p["terminal_output"])

	from meshes import generate_mesh
	from miscellaneous import output_timer

	run_simulation = True
	while(run_simulation):
		#################
		# GENERATE MESH #
		#################
		output_timer.time(simulation_no, "mesh generation", p["terminal_output"], clear_existing=True)
		generate_mesh.generate_mesh(simulation_no, p["geometry"], p["mesh_resolution"], p["central_cavity_width"], p["central_cavity_height"], p["central_cavity_transition"], p["artery_length"], p["verbose_output"], p["basal_plate_vessels"], p["septal_veins"], p["marginal_sinus"], p["wall_height_ratio"], p["artery_width"], p["artery_width_sm"], p["no_placentones"], p["vessel_fillet_radius"], p["basal_plate_vessel_positions"], p["septal_wall_vein_positions"], p["equal_wall_heights"], p["generate_outline_mesh"])
		output_timer.time(simulation_no, "mesh generation", p["terminal_output"])

		##################
		# RUN SIMULATION #
		##################
		output_timer.time(simulation_no, "AptoFEM simulation", p["terminal_output"], clear_existing=True)
		result = aptofem_simulation(simulation_no, p["velocity_model"], p["geometry"], p["central_cavity_width"], p["central_cavity_height"], p["central_cavity_transition"], p["pipe_transition"], p["artery_length"], p["artery_width_sm"], p["log_cavity_transition"], p["scaling_L"], p["scaling_U"], p["scaling_mu"], p["scaling_rho"], p["scaling_k"], p["scaling_D"], p["scaling_R"], p["velocity_space"], velocity_ss, p["velocity_ic_from_ss"], p["transport_ic_from_ss"], p["compute_velocity"], p["compute_transport"], p["compute_permeability"], p["compute_uptake"], p["large_boundary_v_penalisation"], p["moving_mesh"], p["terminal_output"], p["verbose_output"], p["error_on_fail"], p["no_time_steps"], p["final_time"], p["no_placentones"], p["no_threads"], p["run_type"], p["no_reynold_ramp_steps"], p["reynold_ramp_start_ratio"], p["reynold_ramp_step_base"], p["linear_solver"], p["wall_height_ratio"], p["basal_plate_vessel_positions"])
		if (result == False):
			return False
		else:
			aptofem_run_no, velocity_dofs, transport_dofs, newton_residual, newton_iterations = result
		output_timer.time(simulation_no, "AptoFEM simulation", p["terminal_output"], f".\n  aptofem_run_no = {aptofem_run_no}, velocity_dofs = {velocity_dofs:,}, transport_dofs = {transport_dofs:,}, newton_iterations = {newton_iterations}, newton_residual = {newton_residual:.4e}")

		from plotting import calculate_velocity_limits
		from plotting import calculate_transport_limits

		########################
		# WARN OF OSCILLATIONS #
		########################
		if (p["oscillation_detection"]):
			velocity_oscillations  = calculate_velocity_limits .calculate_limits("dg_velocity",  p["geometry"], aptofem_run_no, p["velocity_oscillation_tolerance"],  p["terminal_output"])
			transport_oscillations = calculate_transport_limits.calculate_limits("dg_transport", p["geometry"], aptofem_run_no, p["transport_oscillation_tolerance"], p["terminal_output"])

			if (p["rerun_on_oscillation"] and (velocity_oscillations or transport_oscillations)):
				h /= 2
				output.output(f"!! Rerunning simulation due to oscillations !!", p["terminal_output"])
				output.output(f"!! New mesh resolution: {h} !!", p["terminal_output"])
				run_simulation = True
			else:
				run_simulation = False
		else:
			run_simulation = False

	########
	# PLOT #
	########
	from miscellaneous import get_current_run_no
	aptofem_run_no = get_current_run_no.get_current_run_no("velocity-transport")

	if p["plot"]:
		output_timer.time(simulation_no, "plotting", p["terminal_output"])

		from plotting import plot_velocity
		from plotting import plot_transport

		if (velocity_ss):
			mesh_no = '*'
		else:
			mesh_no = '0'

		if (p["compute_velocity"]):
			plot_velocity.plot(simulation_no,  "dg_velocity",  p["geometry"], str(aptofem_run_no), mesh_no, '1', '24', '1', '1', p["geometry"], '24', '0.0', '0.01', 25, False, velocity_ss)
			plot_velocity.plot(simulation_no,  "dg_velocity",  p["geometry"], str(aptofem_run_no), mesh_no, '0', '24', '1', '1', p["geometry"], '24', '0.0', '0.01', 25, False, velocity_ss)

		if (p["compute_transport"]):
			plot_transport.plot(simulation_no, "dg_transport", p["geometry"], str(aptofem_run_no), mesh_no, '0', '24', p["geometry"], '24', '0.0', '0.01', 25, False, transport_ss)

		output_timer.time(simulation_no, "plotting", p["terminal_output"])

	from plotting import calculate_flux

	##################
	# CALCULATE FLUX #
	##################
	if (p["compute_transport"]):
		flux_uptake = calculate_flux.calculate_transport_flux(aptofem_run_no, p["geometry"])
		flux_cache.append(flux_uptake)

	###############################
	# CALCULATE REACTION INTEGRAL #
	###############################
	if (p["compute_transport"]):
		from miscellaneous import get_transport_reaction_integral

		reaction_integral = get_transport_reaction_integral.get_transport_reaction_integral(program, p["geometry"], aptofem_run_no)
		integral_cache.append(reaction_integral)

	#################
	# CALCULATE MRI #
	#################
	if (p["compute_mri"]):
		output_timer.time(simulation_no, "MRI calculations", p["terminal_output"])

		from mri_code import calculate_mri

		calculate_mri.calculate_mri(aptofem_run_no, p["geometry"], p["no_threads"])

		output_timer.time(simulation_no, "MRI calculations", p["terminal_output"])

	########################
	# CLEAN UP LARGE FILES #
	########################
	from miscellaneous import clean_directory

	if (p["clean_files"][0]):
		clean_directory.clean_directory('./output/', file_extension='vtk',      mode='delete')
	if (p["clean_files"][1]):
		clean_directory.clean_directory('./output/', file_extension='internal', mode='delete')
	if (p["clean_files"][2]):
		clean_directory.clean_directory('./output/', file_extension='dat',      mode='delete')
	if (p["clean_files"][3]):
		clean_directory.clean_directory('./output/', file_extension='txt',      mode='delete')
	if (p["clean_files"][4]):
		clean_directory.clean_directory('./meshes/', file_extension='msh',      mode='delete')
	if (p["clean_files"][5]):
		clean_directory.clean_directory('./meshes/', file_extension='vtk',      mode='delete')
	if (p["clean_files"][6]):
		clean_directory.clean_directory('./images/', file_extension='png',      mode='delete')

	#######
	# END #
	#######
	return True

def aptofem_simulation(simulation_no, velocity_model, geometry, central_cavity_width, central_cavity_height, central_cavity_transition, pipe_transition, artery_length, artery_width_sm, log_cavity_transition, scaling_L, scaling_U, scaling_mu, scaling_rho, scaling_k, scaling_D, scaling_R, velocity_space, velocity_ss, velocity_ic_from_ss, transport_ic_from_ss, compute_velocity, compute_transport, compute_permeability, compute_uptake, large_boundary_v_penalisation, moving_mesh, terminal_output, verbose_output, error_on_fail, no_time_steps, final_time, no_placentones, no_threads, run_type, no_reynold_ramp_steps, reynold_ramp_start_ratio, reynold_ramp_step_base, linear_solver, wall_height_ratio, basal_plate_vessel_positions):

	# Programatically create coefficients. ##
	#  Re 
	velocity_convection_coefficient = scaling_rho*scaling_U*scaling_L/scaling_mu
	# 1/Dar
	velocity_reaction_coefficient   = scaling_L**2/scaling_k
	# 1/Pe
	transport_diffusion_coefficient = scaling_D/(scaling_U*scaling_L)
	# Dam
	transport_reaction_coefficient  = scaling_R*scaling_L/scaling_U

	# Fixed parameters.
	program           = f"velocity-transport"
	program_directory = f"programs/velocity-transport/"

	from miscellaneous import set_parameter

	# Number of threads.
	import os
	if (run_type == 'openmp'):
		os.environ["OMP_NUM_THREADS"] = f"{no_threads}"
		set_parameter.set_parameter("velocity-transport", geometry, 7, f"aptofem_no_openmp_threads {no_threads}")
	else:
		os.environ["OMP_NUM_THREADS"] = "1"

	# Set mesh.
	set_parameter.set_parameter("velocity-transport", geometry, 13, f"mesh_file_name mesh_{simulation_no}.msh")
	set_parameter.set_parameter("velocity-transport", geometry, 14, f"mesh_file_dir ../../meshes/")

	# Set velocity space.
	set_parameter.update_parameter("velocity-transport", geometry, 19, 10, 11, f"{velocity_space}")

	# Set problem parameters (only some here for now).
	set_parameter.set_parameter("velocity-transport", geometry, 64, f"velocity_diffusion_coefficient {1.0}")
	set_parameter.set_parameter("velocity-transport", geometry, 65, f"velocity_convection_coefficient {velocity_convection_coefficient:.4e}")
	set_parameter.set_parameter("velocity-transport", geometry, 66, f"velocity_reaction_coefficient {velocity_reaction_coefficient:.4e}")
	set_parameter.set_parameter("velocity-transport", geometry, 67, f"velocity_pressure_coefficient {1.0}")
	set_parameter.set_parameter("velocity-transport", geometry, 68, f"velocity_time_coefficient {1.0}")
	set_parameter.set_parameter("velocity-transport", geometry, 69, f"velocity_forcing_coefficient {1.0}")

	set_parameter.set_parameter("velocity-transport", geometry, 71, f"transport_diffusion_coefficient {transport_diffusion_coefficient:.4e}")
	set_parameter.set_parameter("velocity-transport", geometry, 72, f"transport_convection_coefficient {1.0}")
	set_parameter.set_parameter("velocity-transport", geometry, 73, f"transport_reaction_coefficient {transport_reaction_coefficient:.4e}")
	set_parameter.set_parameter("velocity-transport", geometry, 74, f"transport_time_coefficient {1.0}")
	set_parameter.set_parameter("velocity-transport", geometry, 75, f"transport_forcing_coefficient {1.0}")

	# Naive Mesh refinement.
	set_parameter.set_parameter("velocity-transport", geometry, 77, f"no_uniform_refinements_inlet 0")
	set_parameter.set_parameter("velocity-transport", geometry, 78, f"no_uniform_refinements_cavity 0")
	set_parameter.set_parameter("velocity-transport", geometry, 79, f"no_uniform_refinements_everywhere 0")

	# Type of problem.
	set_parameter.set_parameter("velocity-transport", geometry, 81, f"velocity_ss .{str(velocity_ss).lower()}.")
	set_parameter.set_parameter("velocity-transport", geometry, 82, f"velocity_ic_from_ss .{str(velocity_ic_from_ss).lower()}.")
	set_parameter.set_parameter("velocity-transport", geometry, 83, f"transport_ic_from_ss .{str(transport_ic_from_ss).lower()}.")
	set_parameter.set_parameter("velocity-transport", geometry, 84, f"compute_velocity .{str(compute_velocity).lower()}.")
	set_parameter.set_parameter("velocity-transport", geometry, 85, f"compute_transport .{str(compute_transport).lower()}.")
	set_parameter.set_parameter("velocity-transport", geometry, 86, f"compute_permeability .{str(compute_permeability).lower()}.")
	set_parameter.set_parameter("velocity-transport", geometry, 87, f"compute_uptake .{str(compute_uptake).lower()}.")
	set_parameter.set_parameter("velocity-transport", geometry, 88, f"large_boundary_v_penalisation .{str(large_boundary_v_penalisation).lower()}.")
	set_parameter.set_parameter("velocity-transport", geometry, 89, f"moving_mesh .{str(moving_mesh).lower()}.")

	# Re ramping.
	set_parameter.set_parameter("velocity-transport", geometry, 90, f"no_reynold_ramp_steps {no_reynold_ramp_steps}")
	set_parameter.set_parameter("velocity-transport", geometry, 91, f"reynold_ramp_start_ratio {reynold_ramp_start_ratio}")
	set_parameter.set_parameter("velocity-transport", geometry, 92, f"reynold_ramp_step_base {reynold_ramp_step_base}")

	# Number of placentones (only relevant for placenta mesh).
	set_parameter.set_parameter("velocity-transport", geometry, 94, f"no_placentones {no_placentones}")

	# Structural parameters.
	set_parameter.set_parameter("velocity-transport", geometry, 98, f"central_cavity_transition {central_cavity_transition}")
	set_parameter.set_parameter("velocity-transport", geometry, 99, f"pipe_transition {pipe_transition}")
	set_parameter.set_parameter("velocity-transport", geometry, 100, f"artery_length {artery_length}")
	set_parameter.set_parameter("velocity-transport", geometry, 101, f"artery_width_sm {artery_width_sm}")
	set_parameter.set_parameter("velocity-transport", geometry, 102, f"log_cavity_transition .{str(log_cavity_transition).lower()}.")
	set_parameter.set_parameter("velocity-transport", geometry, 103, f"wall_height_ratio {wall_height_ratio:.4e}")

	# Parameters per-placentone.
	if (type(central_cavity_width) == list):
		central_cavity_widths = central_cavity_width
	else:
		central_cavity_widths = [central_cavity_width] * no_placentones

	if (type(central_cavity_height) == list):
		central_cavity_heights = central_cavity_height
	else:
		central_cavity_heights = [central_cavity_height] * no_placentones
		
	for i in range(no_placentones):
		set_parameter.set_parameter("velocity-transport", geometry, 105+i, f"central_cavity_width_{i+1} {central_cavity_widths[i]:.4e}")
		set_parameter.set_parameter("velocity-transport", geometry, 113+i, f"central_cavity_height_{i+1} {central_cavity_heights[i]:.4e}")
		set_parameter.set_parameter("velocity-transport", geometry, 121+i, f"vein_location_{i+1}1 {basal_plate_vessel_positions[i][0]:.4e}")
		set_parameter.set_parameter("velocity-transport", geometry, 129+i, f"artery_location_{i+1} {basal_plate_vessel_positions[i][1]:.4e}")
		set_parameter.set_parameter("velocity-transport", geometry, 137+i, f"vein_location_{i+1}2 {basal_plate_vessel_positions[i][2]:.4e}")

	# Setup time dependence.
	set_parameter.set_parameter("velocity-transport", geometry, 151, f"dirk_final_time {final_time:.4e}")
	set_parameter.set_parameter("velocity-transport", geometry, 152, f"dirk_number_of_timesteps {no_time_steps}")

	# Linear solver.
	set_parameter.set_parameter("velocity-transport", geometry, 169, f"linear_solver {linear_solver}")
	set_parameter.set_parameter("velocity-transport", geometry, 188, f"linear_solver {linear_solver}")

	from miscellaneous import get_current_run_no, save_output, output, raise_error, get_dofs, get_newton_residual, get_newton_iterations
	import subprocess
	import sys

	# Run AptoFEM simulation.
	run_no = get_current_run_no.get_current_run_no(program) + 1 # +1 as the program hasn't run yet.
	run_commands = [f'./velocity-transport.out', f'{velocity_model}', f'{geometry}']
	if (run_type == 'mpi'):
		run_commands = ['mpirun', '-n', f'{no_threads}'] + run_commands
	run_process = subprocess.Popen(run_commands, cwd=program_directory, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

	# Display last line of output to screen, and write lines to file.
	line_truncation = 123
	if (verbose_output):
		end = '\r\n'
	else:
		end = '\r'
	run_output = open(f"./output/{program}_{geometry}_{run_no}.txt", "w")
	output.output("", terminal_output)
	while run_process.poll() is None:
		line = run_process.stdout.readline().decode('utf-8').rstrip('\r\n')
		output.output(f">>> {line[:line_truncation]:<{line_truncation}}", terminal_output, end='')
		if (len(line) > line_truncation):
			output.output("...", terminal_output, end=end)
		else:
			output.output("", terminal_output, end=end)
		run_output.write(line + '\n')
	run_output.close()
	output.output("", terminal_output, end='\x1b[1A\rStarting AptoFEM simulation... ')

	# Possibly return an error.
	if (run_process.returncode != 0):
		if (error_on_fail):
			raise_error.raise_error(run_process.stderr.read().decode('utf-8'))
		else:
			return False

	# Get simulation DoFs and Newton results.
	from miscellaneous import get_run_data
	velocity_dofs, transport_dofs, newton_residual, newton_iteration = get_run_data.get_run_data(program, geometry, run_no, 0)
	
	return run_no, velocity_dofs, transport_dofs, newton_residual, newton_iteration

# def convergence():
# 	return run_no, velocity_dofs, transport_dofs, newton_residual, newton_iteration

def setup(clean, terminal_output, compile=True, compile_clean=True, run_type='openmp', verbose_output=False):
	from miscellaneous import output

	output.output("##########################", terminal_output)
	output.output("🔨 Setting up simulations...", terminal_output)
	output.output("##########################", terminal_output)

	program           = "velocity-transport"
	program_directory = f"programs/{program}/"

	from miscellaneous import output, set_run_numbers, clean_directory

	if clean:
		# Clean outputs.
		output.output("Cleaning output directory", terminal_output, end="... ", flush=True)
		no_files = clean_directory.clean_directory('output')
		output.output(f"Cleaned {no_files} output files.", terminal_output)

		# Clean images.
		output.output("Cleaning images directory", terminal_output, end="... ", flush=True)
		no_files = clean_directory.clean_directory('images')
		output.output(f"Cleaned {no_files} image files.", terminal_output)

		# Clean meshes.
		output.output("Cleaning meshes directory", terminal_output, end="... ", flush=True)
		no_files = clean_directory.clean_directory('meshes', '.msh')
		output.output(f"Cleaned {no_files} mesh files.", terminal_output)

		# Reset run numbers for ALL programs.
		set_run_numbers.set_run_numbers(0, program)
		output.output("Set run numbers to 0.", terminal_output)
	else:
		output.output("Skipping cleaning.", terminal_output)

	import subprocess, sys
	from miscellaneous import output_timer, save_output, choose_make_type

	if (compile_clean):
		make_clean_process = subprocess.run(['make', 'cleanall'], cwd=program_directory, stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=True)

	# Compile programs.
	if (compile):
		output_timer.time(0, "compilation", terminal_output)
		choose_make_type.choose_make_type(run_type, program)

		make_process = subprocess.Popen(['make', 'velocity-transport'], cwd=program_directory, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

		# Display last line of output to screen, and write lines to file.
		line_truncation = 120
		if (verbose_output):
			end = '\r\n'
		else:
			end = '\r'
		make_output = open(f"./output/compile_velocity-transport.txt", "w")
		output.output("", terminal_output)
		while make_process.poll() is None:
			line = make_process.stdout.readline().decode('utf-8').rstrip('\r\n')
			if (line != ""):
				output.output(f">>> {line[:line_truncation]:<{line_truncation}}", terminal_output, end='')
				if (len(line) > line_truncation):
					output.output("...", terminal_output, end=end)
				else:
					output.output("", terminal_output, end=end)
				make_output.write(line + '\n')
		make_output.close()
		output.output("", terminal_output, end='\x1b[1A\rStarting compilation... ')

		# Possibly return an error.
		from miscellaneous import raise_error
		if (make_process.returncode != 0):
			raise_error.raise_error(make_process.stderr.read().decode('utf-8'))
			
		output_timer.time(0, "compilation", terminal_output)