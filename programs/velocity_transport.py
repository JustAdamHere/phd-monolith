flux_cache = []
integral_cache = []

def run(simulation_no, velocity_model, geometry, artery_location, vein_location_1, vein_location_2, central_cavity_width, central_cavity_transition, pipe_transition, artery_length, mesh_resolution, log_cavity_transition, scaling_L, scaling_U, scaling_mu, scaling_rho, scaling_k, scaling_D, scaling_R, velocity_space = 'DG', terminal_output = True, verbose_output = False, velocity_oscillation_tolerance = 1e-2, transport_oscillation_tolerance = 1e-1, plot = True, rerun_on_oscillation = False):

	program = "velocity-transport"

	velocity_ss                   = True
	transport_ss                  = True
	velocity_ic_from_ss           = True
	transport_ic_from_ss          = True
	compute_transport             = True
	large_boundary_v_penalisation = False

	from miscellaneous import output

	output.output( "##########################", terminal_output)
	output.output(f"Running simulation # {simulation_no}...", terminal_output, flush=True)
	output.output( "##########################", terminal_output)

	from meshes import generate_mesh
	from miscellaneous import output_timer

	run_simulation = True
	h = mesh_resolution
	while(run_simulation):
		#################
		# GENERATE MESH #
		#################
		output_timer.time(simulation_no, "mesh generation", terminal_output, clear_existing=True)
		generate_mesh.generate_mesh(simulation_no, geometry, h, artery_location, vein_location_1, vein_location_2, central_cavity_width, central_cavity_transition, artery_length, verbose_output)
		output_timer.time(simulation_no, "mesh generation", terminal_output)

		##################
		# RUN SIMULATION #
		##################
		output_timer.time(simulation_no, "AptoFEM simulation", terminal_output, clear_existing=True)
		aptofem_run_no, velocity_dofs, transport_dofs, newton_residual, newton_iterations = aptofem_simulation(simulation_no, velocity_model, geometry, artery_location, central_cavity_width, central_cavity_transition, pipe_transition, artery_length, log_cavity_transition, scaling_L, scaling_U, scaling_mu, scaling_rho, scaling_k, scaling_D, scaling_R, velocity_space, velocity_ss, velocity_ic_from_ss, transport_ic_from_ss, compute_transport, large_boundary_v_penalisation, terminal_output, verbose_output)
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

		plot_velocity.plot(simulation_no,  "dg_velocity",  geometry, str(aptofem_run_no), '0', '1', '24', '1', '1', geometry, '0', '0', '0', 0, False, velocity_ss)
		plot_velocity.plot(simulation_no,  "dg_velocity",  geometry, str(aptofem_run_no), '0', '0', '24', '1', '1', geometry, '0', '0', '0', 0, False, velocity_ss)
		plot_transport.plot(simulation_no, "dg_transport", geometry, str(aptofem_run_no), '0', '0', '24', geometry, '0', '0', '0', 0, False, transport_ss)

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

def aptofem_simulation(simulation_no, velocity_model, geometry, artery_location, central_cavity_width, central_cavity_transition, pipe_transition, artery_length, log_cavity_transition, scaling_L, scaling_U, scaling_mu, scaling_rho, scaling_k, scaling_D, scaling_R, velocity_space, velocity_ss, velocity_ic_from_ss, transport_ic_from_ss, compute_transport, large_boundary_v_penalisation, terminal_output, verbose_output):

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

	# Structural parameters.
	set_parameter.set_parameter("velocity-transport", geometry, 87, f"artery_location {artery_location:.4f}")
	set_parameter.set_parameter("velocity-transport", geometry, 88, f"central_cavity_width {central_cavity_width}")
	set_parameter.set_parameter("velocity-transport", geometry, 89, f"central_cavity_transition {central_cavity_transition}")
	set_parameter.set_parameter("velocity-transport", geometry, 90, f"pipe_transition {pipe_transition}")
	set_parameter.set_parameter("velocity-transport", geometry, 91, f"artery_length {artery_length}")
	set_parameter.set_parameter("velocity-transport", geometry, 92, f"log_cavity_transition .{str(log_cavity_transition).lower()}.")

	# Manually set timesteps to 0.
	set_parameter.set_parameter("velocity-transport", geometry, 100, f"dirk_final_time 0.0")
	set_parameter.set_parameter("velocity-transport", geometry, 101, f"dirk_number_of_timesteps 0")

	from miscellaneous import get_current_run_no, save_output, output, raise_error, get_dofs, get_newton_residual, get_newton_iterations
	import subprocess
	import sys

	# Run AptoFEM simulation.
	run_no = -1
	try:
		run_output = subprocess.run([f'./{velocity_model}-transport_{geometry}.out', ], cwd=program_directory, stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=True)
		run_no     = get_current_run_no.get_current_run_no("velocity-transport")
		save_output.save_output(run_output, program, geometry, run_no)
		#output.output(run_output.stdout.decode("utf-8"), verbose_output)
	except subprocess.CalledProcessError as e:
		run_no = get_current_run_no.get_current_run_no(program)
		save_output.save_output(e, program, geometry, run_no)
		raise_error.raise_error(e)

	# TODO: only true for steady-state 0 time-steps with DG.
	if (velocity_space == 'DG'):
		velocity_dofs   = get_dofs.get_velocity_dofs (program, geometry, run_no)
		transport_dofs  = get_dofs.get_transport_dofs(program, geometry, run_no)
		newton_residual = get_newton_residual.get_newton_residual(program, geometry, run_no)
		newton_iteration= get_newton_iterations.get_newton_iterations(program, geometry, run_no)
	else:
		velocity_dofs   = -1
		transport_dofs  = -1
		newton_residual = -1
		newton_iteration= -1

	return run_no, velocity_dofs, transport_dofs, newton_residual, newton_iteration

# def convergence():
# 	return run_no, velocity_dofs, transport_dofs, newton_residual, newton_iteration

def setup(clean, terminal_output, compile=True):
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
	from miscellaneous import output_timer, save_output

	# Compile programs.
	if (compile):
		output_timer.time(0, "compilation", terminal_output)
		try:
			#make_clean_output = subprocess.run(['make', 'cleanall'], cwd=program_directory, stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=True)
			# make_output       = subprocess.run(['make', 'all'], cwd=program_directory, stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=True)
			make_output       = subprocess.run(['make', 'nsb-transport_placenta'], cwd=program_directory, stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=True)
			save_output.save_output(make_output, f'compile_{program}', 'all', 0)
		except subprocess.CalledProcessError as e:
			output.output(f"## ERROR ##", True)
			output.output(f"Error message: {e.stderr.decode('utf-8')}", True)
			sys.exit(1)
		output_timer.time(0, "compilation", terminal_output)