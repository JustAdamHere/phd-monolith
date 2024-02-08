def calculate_mri(aptofem_run_no, geometry, no_threads, terminal_output, verbose_output):
  import subprocess
  from miscellaneous import save_output, raise_error, output

  run_commands = ["matlab", "-nosplash", "-nodesktop", "-batch", f"driver_2D_{geometry}"]
  run_process = subprocess.Popen(run_commands, cwd='./mri_code/', stdout=subprocess.PIPE, stderr=subprocess.PIPE)
  output.display_run_output(run_process, f"mri_{geometry}", terminal_output, verbose_output, "Starting MRI simulations...")

  # try:
  #   #run_commands = ['matlab', '-noddesktop', '-r', f"run('driver_2D_{geometry}.m')"]
  #   run_commands = ["matlab", "-nosplash", "-nodesktop", "-batch", f"driver_2D_{geometry}"]
  #   run_process = subprocess.Popen(run_commands, cwd='./mri_code/', stdout=subprocess.PIPE, stderr=subprocess.PIPE)
  #   output.display_run_output(run_process, f"mri_{geometry}", terminal_output, verbose_output, "Starting MRI simulations...")
  # except subprocess.CalledProcessError as e:
  #   save_output.save_output(e, "mri", geometry, aptofem_run_no)
  #   raise_error.raise_error(f"Error running MRI code: {e}")