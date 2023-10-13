def edit_driver(geometry, line, value):
	import os

	acp_filename = f'./mri_code/driver_2D_{geometry}.m'

	arn_file    = open(acp_filename, 'r')
	arn_content = arn_file .readlines()
	arn_file    .close()
	arn_content[line-1] = f'{value}\n'
	arn_file    = open(acp_filename, 'w')
	arn_file    .writelines(arn_content)
	arn_file    .close()

def calculate_mri(aptofem_run_no, geometry, no_threads):
  import subprocess
  from miscellaneous import save_output, raise_error

  # Set run number and number of threads.
  edit_driver(geometry, 9,  f"aptofem_run_no = {aptofem_run_no};")
  edit_driver(geometry, 12, f"no_threads = {no_threads};")

  try:
    run_output = subprocess.run(['matlab', '-nodisplay', '-r', f"run('driver_2D_{geometry}.m')"], cwd='./mri_code/', stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=True)
    # run_output = subprocess.run(['matlab', '-nodisplay', '-r', f"run('driver_2D_{geometry}.m'); exit;"], cwd='./mri_code/', stdout=None, stderr=None, check=True)
    save_output.save_output(run_output, "mri", geometry, aptofem_run_no)
  except subprocess.CalledProcessError as e:
    save_output.save_output(e, "mri", geometry, aptofem_run_no)
    raise_error.raise_error(f"Error running MRI code: {e}")