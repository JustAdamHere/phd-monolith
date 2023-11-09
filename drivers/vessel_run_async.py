def main():
  ####################
  # SIMULATION SETUP #
  ####################
  # Register termination signal to save output so far.
  import signal
  from miscellaneous import output
  signal.signal(signal.SIGINT, output.end_execution)

  # Import default simulation parameters.
  from programs import velocity_transport
  parameters = velocity_transport.get_default_run_parameters()

  # Geometry measurements.
  parameters["central_cavity_width"]      = 0.25
  parameters["central_cavity_height"]     = 0.50
  parameters["central_cavity_transition"] = 0.12
  parameters["pipe_transition"]           = 0.03
  parameters["vessel_fillet_radius"]      = 0.01
  parameters["artery_width"]              = 0.06
  parameters["artery_width_sm"]           = 0.0125
  parameters["no_placentones"]            = 6

  # Mesh resolution.
  parameters["mesh_resolution"] = 1#0.02

  # Unused.
  parameters["log_cavity_transition"] = False
  parameters["artery_length"] = 0.25

  # Problem parameters.
  parameters["scaling_L"]   = 0.04     # m
  parameters["scaling_U"]   = 0.35     # m/s
  parameters["scaling_k"]   = 1e-8     # m^2
  parameters["scaling_mu"]  = 4e-3     # Pa s
  parameters["scaling_rho"] = 1e3      # kg/m^3
  parameters["scaling_D"]   = 1.667e-9 # m^2/s
  parameters["scaling_R"]   = 1.667e-2 # m^2/s

  # Run type.
  parameters["run_type"]      = 'serial'
  parameters["linear_solver"] = 'mumps'
  parameters["no_threads"]    = 1

  # File handling.
  parameters["clean_files"][0] = False  # Output VTKs.
  parameters["clean_files"][1] = True  # Output restarts.
  parameters["clean_files"][2] = False # Output data files.
  parameters["clean_files"][3] = False # Output log files.
  parameters["clean_files"][4] = True  # Mesh mshs.
  parameters["clean_files"][5] = True  # Mesh VTKs.
  parameters["clean_files"][6] = False # Images.

  # Output.
  parameters["terminal_output"] = False
  parameters["verbose_output"]  = False
  parameters["plot"]            = True

  # Simulation.
  parameters["compute_mri"]              = False
  parameters["compute_permeability"]     = False
  parameters["compute_transport"]        = True
  parameters["compute_uptake"]           = False
  parameters["compute_velocity"]         = True
  parameters["compute_velocity_average"] = True
  parameters["compute_velocity_sample"]  = True

  ##################
  # SIMULATION RUN #
  ##################
  from miscellaneous import output
  from miscellaneous import choose_vessels

  # Clean and compile.
  velocity_transport.setup(clean=False, terminal_output=True, compile=True, compile_clean=False, run_type=parameters["run_type"], verbose_output=False)

  # Resume simulation numbers.
  from miscellaneous import run_no, select_no_threads, set_run_numbers
  sim_no = run_no.get_completed_run_no()
  set_run_numbers.set_run_numbers(sim_no, program="velocity-transport")

  # Run all processes in parallel.
  import asyncio
  asyncio.run(run_all(2, parameters))

  # Save output.
  output.save()

async def run_all(max_concurrent, parameters):
  import asyncio

  # sim_no = 1

  # run_simulations = True
  # while (run_simulations):
  #   tasks = []
  #   for i in range(sim_no, sim_no + max_concurrent):
  #     tasks.append(asyncio.create_task(run_single(i, parameters)))

  #   await asyncio.gather(*tasks)

  #   sim_no += max_concurrent

  #   run_simulations = False

  # sim_no = 1
  # async with asyncio.TaskGroup() as tg:
  #   for i in range(sim_no, sim_no + max_concurrent):
  #     asyncio.to_thread(run_single(i, parameters)))
  #     # tg.create_task(run_single_test(i, i*2))

  # await asyncio.gather(asyncio.to_thread(run_single, 1, parameters), asyncio.to_thread(run_single, 2, parameters))

  # task1 = asyncio.to_thread(run_single, 1, parameters)
  # task2 = asyncio.to_thread(run_single, 2, parameters)





  # task1 = asyncio.to_thread(run_single_test, 1, 1)
  # task2 = asyncio.to_thread(run_single_test, 2, 2)

  # await asyncio.gather(task1, task2)

  parameters["terminal_output"] = False

  sim_no = 1

  tasks = []
  for i in range(sim_no, sim_no + max_concurrent):
    #tasks.append(asyncio.to_thread(run_single_test, i, 2))
    tasks.append(asyncio.to_thread(run_single, i, parameters, i))

  await asyncio.gather(*tasks)

def run_single_test(sim_no, delay):
  print(f"Simulation {sim_no} started...")
  # import asyncio
  # await asyncio.sleep(delay)
  import time
  time.sleep(delay)
  print(f"Simulation {sim_no} finished.")

def run_single(sim_no, parameters, delay):
  import time
  time.sleep(delay)

  from programs import velocity_transport
  from miscellaneous import select_no_threads, choose_vessels

  # Set artery and vein padding.
  vein_width      = 0.0375
  fillet_radius   = 0.01
  artery_padding  = parameters["central_cavity_width"]/2 + parameters["central_cavity_transition"]/2 + fillet_radius
  vein_padding    = vein_width/2 + fillet_radius
  epsilon_padding = 0.001

  # Select number of vessels turned on.
  no_veins                = choose_vessels.calculate_no_veins   (parameters["no_placentones"])
  no_marginal_sinus_veins = 2#choose_vessels.calculate_no_ms      ()
  no_arteries             = choose_vessels.calculate_no_arteries(parameters["no_placentones"])

  # Select which of these vessels are turned on.
  parameters["basal_plate_vessels"], parameters["marginal_sinus"], parameters["septal_veins"] = choose_vessels.calculate_vessel_enabled(no_veins, no_arteries, no_marginal_sinus_veins, parameters["no_placentones"])

  # Select positions of vessels (note marginal sinus is fixed).
  parameters["basal_plate_vessel_positions"], parameters["septal_wall_vein_positions"] = choose_vessels.calculate_vessel_positions(parameters["basal_plate_vessels"], parameters["septal_veins"], parameters["no_placentones"], artery_padding, vein_padding, epsilon_padding)

  # Read in number of threads.
  parameters["no_threads"] = select_no_threads.read_no_threads(20)

  # Run the simulation.
  velocity_transport.run(sim_no, parameters)

main()