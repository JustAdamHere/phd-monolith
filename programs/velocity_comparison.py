def run(simulation_no, p):

	program = "velocity-transport"

	if (p["no_time_steps"] == 0):
		velocity_ss                 = True
		transport_ss                = True
	else:
		velocity_ss                 = False
		transport_ss                = False
	large_boundary_v_penalisation = False

	from miscellaneous import output

	output.output( "##########################", p["terminal_output"])
	output.output(f"Running simulation # {simulation_no}...", p["terminal_output"], flush=True)
	output.output( "##########################", p["terminal_output"])

	from meshes import generate_mesh
	from miscellaneous import output_timer

	#################
	# GENERATE MESH #
	#################
	output_timer.time(simulation_no, "mesh generation", p["terminal_output"])
	generate_mesh.generate_mesh(simulation_no, p["geometry"], p["mesh_resolution"], p["central_cavity_width"], p["central_cavity_height"], p["central_cavity_transition"], p["artery_length"], p["verbose_output"], p["basal_plate_vessels"], p["septal_veins"], p["marginal_sinus"], p["wall_height_ratio"], p["artery_width"], p["artery_width_sm"], p["no_placentones"], p["vessel_fillet_radius"], p["basal_plate_vessel_positions"], p["septal_wall_vein_positions"], p["equal_wall_heights"], p["generate_outline_mesh"])
	output_timer.time(simulation_no, "mesh generation", p["terminal_output"])

	##################
	# RUN SIMULATION #
	##################
	from programs import velocity_transport
	output_timer.time(simulation_no, "AptoFEM set parameters", p["terminal_output"], clear_existing=True)
	velocity_transport.set_aptofem_parameters(simulation_no, p["velocity_model"], p["geometry"], p["central_cavity_width"], p["central_cavity_height"], p["central_cavity_transition"], p["pipe_transition"], p["artery_length"], p["artery_width_sm"], p["log_cavity_transition"], p["scaling_L"], p["scaling_U"], p["scaling_mu"], p["scaling_rho"], p["scaling_k"], p["scaling_D"], p["scaling_R"], p["velocity_space"], velocity_ss, p["velocity_ic_from_ss"], p["transport_ic_from_ss"], p["compute_velocity"], p["compute_transport"], p["compute_permeability"], p["compute_uptake"], p["large_boundary_v_penalisation"], p["moving_mesh"], p["terminal_output"], p["verbose_output"], p["error_on_fail"], p["no_time_steps"], p["final_time"], p["no_placentones"], p["no_threads"], p["run_type"], p["no_reynold_ramp_steps"], p["reynold_ramp_start_ratio"], p["reynold_ramp_step_base"], p["linear_solver"], p["wall_height_ratio"], p["basal_plate_vessel_positions"], p["rerun_with_reynold_steps"])
	output_timer.time(simulation_no, "AptoFEM set parameters", p["terminal_output"])

	output_timer.time(simulation_no, "AptoFEM simulation", p["terminal_output"])
	result = aptofem_simulation(simulation_no, p["velocity_model"], p["geometry"], p["terminal_output"], p["verbose_output"], p["error_on_fail"], p["no_threads"], p["run_type"])
	output_timer.time(simulation_no, "AptoFEM simulation", p["terminal_output"])

	########
	# PLOT #
	########
	from miscellaneous import get_current_run_no
	aptofem_run_no = get_current_run_no.get_current_run_no("velocity-transport")

	if p["plot"]:
		output_timer.time(simulation_no, "plotting", p["terminal_output"])

		from plotting import plot_velocity

		for i in range(1, 5):
			for j in range(i, 5):
				plot_velocity.plot(10*i + j, "dg_velocity", p["geometry"], '1', str(10*i + j), '1', '24', '0', '0', p["geometry"], '0', '0', '0', 0, False, True)
				plot_velocity.plot(10*i + j, "dg_velocity", p["geometry"], '1', str(10*i + j), '0', '24', '0', '0', p["geometry"], '0', '0', '0', 0, False, True)

		for i in range (1, 5):
			plot_velocity.plot(i, "dg_velocity", p["geometry"], '1', str(i) + '.vtk', '1', '24', '1', '1', p["geometry"], '0', '0', '0', 0, False, True)
			plot_velocity.plot(i, "dg_velocity", p["geometry"], '1', str(i) + '.vtk', '0', '24', '1', '1', p["geometry"], '0', '0', '0', 0, False, True)

		output_timer.time(simulation_no, "plotting", p["terminal_output"])

def aptofem_simulation(simulation_no, velocity_model, geometry, terminal_output, verbose_output, error_on_fail, no_threads, run_type):
	# Fixed parameters.
	program           = f"velocity-transport"
	program_directory = f"programs/velocity-transport/"

	from miscellaneous import get_current_run_no, save_output, output, raise_error
	import subprocess
	import sys

	# Run AptoFEM simulation.
	run_no = get_current_run_no.get_current_run_no(program) + 1 # +1 as the program hasn't run yet.
	run_commands = [f'./velocity-comparison.out', f'{geometry}']
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
		if (error_on_fail):
			raise_error.raise_error(run_process.stderr.read())
		else:
			return False
	
	return True

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
		# Create object and module directories
		from pathlib import Path
		try:
			Path(f'./programs/{program}/.obj').mkdir(exist_ok=True)
			Path(f'./programs/{program}/.mod').mkdir(exist_ok=True)
		except OSError as e:
			print(f"Error: {e.strerror}.")
			exit()

		output_timer.time(0, "compilation", terminal_output)
		choose_make_type.choose_make_type(run_type, program)

		make_process = subprocess.Popen(['make', 'velocity-comparison'], cwd=program_directory, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

		# Display last line of output to screen, and write lines to file.
		line_truncation = 120
		if (verbose_output):
			end = '\r\n'
		else:
			end = '\r'
		make_output = open(f"./output/compile_velocity-comparison.txt", "w")
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