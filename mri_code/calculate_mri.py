def calculate_mri(run_no, geometry, no_threads, terminal_output, verbose_output, u1, u2, x):
  import subprocess
  from miscellaneous import save_output, raise_error, output

  try:
    run_commands = ["matlab", "-nosplash", "-nodesktop", "-batch", f"parpool(20);run_no={run_no};U_1={u1};U_2={u2};X={x};driver_2D_{geometry}"]
    run_process = subprocess.Popen(run_commands, cwd='./mri_code/', stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    output.display_run_output(run_process, f"mri_{geometry}", terminal_output, verbose_output, "Starting MRI calculations...")
  except subprocess.CalledProcessError as e:
    raise_error.raise_error(f"Error running MRI code: {e}")