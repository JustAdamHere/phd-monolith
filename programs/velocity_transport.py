flux_cache = []
integral_cache = []

def run(simulation_no, velocity_model, geometry, artery_location, vein_location_1, vein_location_2, central_cavity_width, central_cavity_height, central_cavity_transition, pipe_transition, artery_length, mesh_resolution, log_cavity_transition, scaling_L, scaling_U, scaling_mu, scaling_rho, scaling_k, scaling_D, scaling_R, velocity_space = 'DG', terminal_output = True, verbose_output = False, velocity_oscillation_tolerance = 1e-2, transport_oscillation_tolerance = 1e-1, plot = True, rerun_on_oscillation = False, normal_vessels=[[1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1]], septal_veins=[[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]], marginal_sinus = [1, 1], error_on_fail=True, extra_text='', wall_height_ratio=1, artery_width=0.06, no_time_steps=0, final_time=0.0, no_placentones=6, no_threads=20, run_type='openmp', no_reynold_ramp_steps = 1, reynold_ramp_start_ratio = 0.1, reynold_ramp_step_base = 2, linear_solver='mumps', velocity_ic_from_ss=True, transport_ic_from_ss=True, moving_mesh=False, artery_width_sm=0.0125):

	assert(velocity_model in ['nsb', 'ns-nsb', 'ns-b', 's-b'])
	assert(run_type in ['serial', 'openmp', 'mpi'])
	assert(geometry in ['placentone', 'placentone-3d', 'placenta'])

	program = "velocity-transport"

	if (no_time_steps == 0):
		velocity_ss                 = True
	else:
		velocity_ss                 = False
	transport_ss                  = True
	compute_transport             = True
	large_boundary_v_penalisation = False

	from miscellaneous import output

	output.output( "##########################", terminal_output)
	output.output(f"Running simulation # {simulation_no}... {extra_text}", terminal_output, flush=True)
	output.output( "##########################", terminal_output)

	from meshes import generate_mesh
	from miscellaneous import output_timer

	run_simulation = True
	while(run_simulation):
		#################
		# GENERATE MESH #
		#################
		output_timer.time(simulation_no, "mesh generation", terminal_output, clear_existing=True)
		generate_mesh.generate_mesh(simulation_no, geometry, mesh_resolution, artery_location, vein_location_1, vein_location_2, central_cavity_width, central_cavity_height, central_cavity_transition, artery_length, verbose_output, normal_vessels, septal_veins, marginal_sinus, wall_height_ratio, artery_width, artery_width_sm, no_placentones)
		output_timer.time(simulation_no, "mesh generation", terminal_output)

		##################
		# RUN SIMULATION #
		##################
		output_timer.time(simulation_no, "AptoFEM simulation", terminal_output, clear_existing=True)
		result = aptofem_simulation(simulation_no, velocity_model, geometry, artery_location, central_cavity_width, central_cavity_height, central_cavity_transition, pipe_transition, artery_length, artery_width_sm, log_cavity_transition, scaling_L, scaling_U, scaling_mu, scaling_rho, scaling_k, scaling_D, scaling_R, velocity_space, velocity_ss, velocity_ic_from_ss, transport_ic_from_ss, compute_transport, large_boundary_v_penalisation, moving_mesh, terminal_output, verbose_output, error_on_fail, no_time_steps, final_time, no_placentones, no_threads, run_type, no_reynold_ramp_steps, reynold_ramp_start_ratio, reynold_ramp_step_base, linear_solver)
		if (result == False):
			return False
		else:
			aptofem_run_no, velocity_dofs, transport_dofs, newton_residual, newton_iterations = result
		output_timer.time(simulation_no, "AptoFEM simulation", terminal_output, f".\n  aptofem_run_no = {aptofem_run_no}, velocity_dofs = {velocity_dofs:,}, transport_dofs = {transport_dofs:,}, newton_iterations = {newton_iterations}, newton_residual = {newton_residual:.4e}")

		from plotting import calculate_velocity_limits
		from plotting import calculate_transport_limits

		########################
		# WARN OF OSCILLATIONS #
		########################
		velocity_oscillations  = calculate_velocity_limits .calculate_limits("dg_velocity",  geometry, aptofem_run_no, velocity_oscillation_tolerance,  terminal_output)
		transport_oscillations = calculate_transport_limits.calculate_limits("dg_transport", geometry, aptofem_run_no, transport_oscillation_tolerance, terminal_output)

		if (rerun_on_oscillation and (velocity_oscillations or transport_oscillations)):
			h /= 2
			output.output(f"!! Rerunning simulation due to oscillations !!", terminal_output)
			output.output(f"!! New mesh resolution: {h} !!", terminal_output)
			run_simulation = True
		else:
			run_simulation = False

	########
	# PLOT #
	########
	from miscellaneous import get_current_run_no
	aptofem_run_no = get_current_run_no.get_current_run_no("velocity-transport")

	if plot:
		output_timer.time(simulation_no, "plotting", terminal_output)

		from plotting import plot_velocity
		from plotting import plot_transport

		if (velocity_ss):
			mesh_no = '*'
		else:
			mesh_no = '0'

		plot_velocity.plot(simulation_no,  "dg_velocity",  geometry, str(aptofem_run_no), mesh_no, '1', '24', '1', '1', geometry, '24', '0.0', '0.01', 25, False, velocity_ss)
		plot_velocity.plot(simulation_no,  "dg_velocity",  geometry, str(aptofem_run_no), mesh_no, '0', '24', '1', '1', geometry, '24', '0.0', '0.01', 25, False, velocity_ss)
		plot_transport.plot(simulation_no, "dg_transport", geometry, str(aptofem_run_no), mesh_no, '0', '24', geometry, '24', '0.0', '0.01', 25, False, transport_ss)

		output_timer.time(simulation_no, "plotting", terminal_output)

	from plotting import calculate_flux

	##################
	# CALCULATE FLUX #
	##################
	flux_uptake = calculate_flux.calculate_transport_flux(aptofem_run_no, geometry)
	flux_cache.append(flux_uptake)

	from miscellaneous import get_transport_reaction_integral

	###############################
	# CALCULATE REACTION INTEGRAL #
	###############################
	reaction_integral = get_transport_reaction_integral.get_transport_reaction_integral(program, geometry, aptofem_run_no)
	integral_cache.append(reaction_integral)

	return True

def aptofem_simulation(simulation_no, velocity_model, geometry, artery_location, central_cavity_width, central_cavity_height, central_cavity_transition, pipe_transition, artery_length, artery_width_sm, log_cavity_transition, scaling_L, scaling_U, scaling_mu, scaling_rho, scaling_k, scaling_D, scaling_R, velocity_space, velocity_ss, velocity_ic_from_ss, transport_ic_from_ss, compute_transport, large_boundary_v_penalisation, moving_mesh, terminal_output, verbose_output, error_on_fail, no_time_steps, final_time, no_placentones, no_threads, run_type, no_reynold_ramp_steps, reynold_ramp_start_ratio, reynold_ramp_step_base, linear_solver):

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
	set_parameter.set_parameter("velocity-transport", geometry, 84, f"compute_transport .{str(compute_transport).lower()}.")
	set_parameter.set_parameter("velocity-transport", geometry, 85, f"large_boundary_v_penalisation .{str(large_boundary_v_penalisation).lower()}.")
	set_parameter.set_parameter("velocity-transport", geometry, 86, f"moving_mesh .{str(moving_mesh).lower()}.")

	# Re ramping.
	set_parameter.set_parameter("velocity-transport", geometry, 87, f"no_reynold_ramp_steps {no_reynold_ramp_steps}")
	set_parameter.set_parameter("velocity-transport", geometry, 88, f"reynold_ramp_start_ratio {reynold_ramp_start_ratio}")
	set_parameter.set_parameter("velocity-transport", geometry, 89, f"reynold_ramp_step_base {reynold_ramp_step_base}")

	# Number of placentones (only relevant for placenta mesh).
	set_parameter.set_parameter("velocity-transport", geometry, 91, f"no_placentones {no_placentones}")

	# Structural parameters.
	# set_parameter.set_parameter("velocity-transport", geometry, 93, f"artery_location {artery_location:.4f}")
	# set_parameter.set_parameter("velocity-transport", geometry, 93, f"central_cavity_width {central_cavity_width}")
	# set_parameter.set_parameter("velocity-transport", geometry, 94, f"central_cavity_height {central_cavity_height}")
	set_parameter.set_parameter("velocity-transport", geometry, 93, f"central_cavity_transition {central_cavity_transition}")
	set_parameter.set_parameter("velocity-transport", geometry, 94, f"pipe_transition {pipe_transition}")
	set_parameter.set_parameter("velocity-transport", geometry, 95, f"artery_length {artery_length}")
	set_parameter.set_parameter("velocity-transport", geometry, 96, f"artery_width_sm {artery_width_sm}")
	set_parameter.set_parameter("velocity-transport", geometry, 97, f"log_cavity_transition .{str(log_cavity_transition).lower()}.")

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
		set_parameter.set_parameter("velocity-transport", geometry, 99+i, f"central_cavity_width_{i+1} {central_cavity_widths[i]}")
		set_parameter.set_parameter("velocity-transport", geometry, 107+i, f"central_cavity_height_{i+1} {central_cavity_heights[i]}")
		set_parameter.set_parameter("velocity-transport", geometry, 115+i, f"vein_location_{i+1}1 {0.2}")
		set_parameter.set_parameter("velocity-transport", geometry, 123+i, f"artery_location_{i+1} {0.5}")
		set_parameter.set_parameter("velocity-transport", geometry, 131+i, f"vein_location_{i+1}2 {0.8}")

	# Setup time dependence.
	set_parameter.set_parameter("velocity-transport", geometry, 145, f"dirk_final_time {final_time}")
	set_parameter.set_parameter("velocity-transport", geometry, 146, f"dirk_number_of_timesteps {no_time_steps}")

	# Linear solver.
	set_parameter.set_parameter("velocity-transport", geometry, 163, f"linear_solver {linear_solver}")
	set_parameter.set_parameter("velocity-transport", geometry, 182, f"linear_solver {linear_solver}")

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
	line_truncation = 120
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

	# TODO: only true for steady-state 0 time-steps with DG.
	velocity_dofs   = -1
	transport_dofs  = -1
	newton_residual = -1
	newton_iteration= -1
	# if (velocity_space == 'DG' and (velocity_model == 'nsb' or velocity_model == 'ns-b')):
	# 	velocity_dofs   = get_dofs.get_velocity_dofs (program, geometry, run_no)
	# 	transport_dofs  = get_dofs.get_transport_dofs(program, geometry, run_no)
	# 	newton_residual = get_newton_residual.get_newton_residual(program, geometry, run_no)
	# 	newton_iteration= get_newton_iterations.get_newton_iterations(program, geometry, run_no)

	return run_no, velocity_dofs, transport_dofs, newton_residual, newton_iteration

# def convergence():
# 	return run_no, velocity_dofs, transport_dofs, newton_residual, newton_iteration

def setup(clean, terminal_output, compile=True, compile_clean=False, run_type='openmp', verbose_output=False):
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