def run(simulation_no, geometry, artery_location, vein_location_1, vein_location_2, central_cavity_width, central_cavity_transition, pipe_transition, artery_length, mesh_resolution, log_cavity_transition, scaling_L, scaling_U, scaling_mu, scaling_rho, scaling_k, velocity_space = 'DG', terminal_output = True, verbose_output = False, plot = True):

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

	#################
	# GENERATE MESH #
	#################
	output_timer.time(simulation_no, "mesh generation", terminal_output)
	generate_mesh.generate_mesh(simulation_no, geometry, mesh_resolution, artery_location, vein_location_1, vein_location_2, central_cavity_width, central_cavity_transition, artery_length, verbose_output)
	output_timer.time(simulation_no, "mesh generation", terminal_output)

	##################
	# RUN SIMULATION #
	##################
	output_timer.time(simulation_no, "AptoFEM simulation", terminal_output)
	aptofem_simulation(simulation_no, geometry, artery_location, central_cavity_width, central_cavity_transition, pipe_transition, artery_length, log_cavity_transition, scaling_L, scaling_U, scaling_mu, scaling_rho, scaling_k, velocity_space, large_boundary_v_penalisation, terminal_output, verbose_output)
	output_timer.time(simulation_no, "AptoFEM simulation", terminal_output)

	########
	# PLOT #
	########
	from miscellaneous import get_current_run_no
	aptofem_run_no = get_current_run_no.get_current_run_no("velocity-transport")

	if plot:
		output_timer.time(simulation_no, "plotting", terminal_output)

		from plotting import plot_velocity

		for i in range(1, 5):
			for j in range(i, 5):
				plot_velocity.plot(10*i + j, "dg_velocity", geometry, '1', str(10*i + j), '1', '24', '0', '0', geometry, '0', '0', '0', 0, False, True)
				plot_velocity.plot(10*i + j, "dg_velocity", geometry, '1', str(10*i + j), '0', '24', '0', '0', geometry, '0', '0', '0', 0, False, True)

		for i in range (0, 4):
			plot_velocity.plot(i, "dg_velocity", geometry, '1', str(i) + '.vtk', '1', '24', '1', '1', geometry, '0', '0', '0', 0, False, True)
			plot_velocity.plot(i, "dg_velocity", geometry, '1', str(i) + '.vtk', '0', '24', '1', '1', geometry, '0', '0', '0', 0, False, True)

		output_timer.time(simulation_no, "plotting", terminal_output)

def aptofem_simulation(simulation_no, geometry, artery_location, central_cavity_width, central_cavity_transition, pipe_transition, artery_length, log_cavity_transition, scaling_L, scaling_U, scaling_mu, scaling_rho, scaling_k, velocity_space, large_boundary_v_penalisation, terminal_output, verbose_output):

	# Programatically create coefficients. ##
	#  Re 
	velocity_convection_coefficient = scaling_rho*scaling_U*scaling_L/scaling_mu
	# 1/Dar
	velocity_reaction_coefficient   = scaling_L**2/scaling_k

	# Fixed parameters.
	program           = f"velocity-comparison"
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

	# Naive Mesh refinement.
	set_parameter.set_parameter("velocity-transport", geometry, 77, f"no_uniform_refinements_inlet 0")
	set_parameter.set_parameter("velocity-transport", geometry, 78, f"no_uniform_refinements_cavity 0")
	set_parameter.set_parameter("velocity-transport", geometry, 79, f"no_uniform_refinements_everywhere 0")

	# Type of problem.
	set_parameter.set_parameter("velocity-transport", geometry, 81, f"velocity_ss .false.")
	set_parameter.set_parameter("velocity-transport", geometry, 82, f"velocity_ic_from_ss .false.")
	set_parameter.set_parameter("velocity-transport", geometry, 83, f"transport_ic_from_ss .false.")
	set_parameter.set_parameter("velocity-transport", geometry, 84, f"compute_transport .false.")
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
		run_output = subprocess.run([f'./velocity-comparison_{geometry}.out', ], cwd=program_directory, stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=True)
		run_no     = get_current_run_no.get_current_run_no("velocity-transport")
		save_output.save_output(run_output, program, geometry, run_no)
		#output.output(run_output.stdout.decode("utf-8"), verbose_output)
	except subprocess.CalledProcessError as e:
		run_no = get_current_run_no.get_current_run_no(program)
		save_output.save_output(e, program, geometry, run_no)
		raise_error.raise_error(e)

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
			make_output       = subprocess.run(['make', 'comparison'], cwd=program_directory, stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=True)
			save_output.save_output(make_output, f'compile_{program}', 'all', 0)
		except subprocess.CalledProcessError as e:
			output.output(f"## ERROR ##", True)
			output.output(f"Error message: {e.stderr.decode('utf-8')}", True)
			sys.exit(1)
		output_timer.time(0, "compilation", terminal_output)