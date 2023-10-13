def get_velocity_magnitude_integral(program, geometry, run_no):
  import pandas as pd

  integral_data = pd.read_csv(f'./output/velocity-magnitude-integral_{program}_{geometry}_{run_no}.dat', sep='\t', header=[0])

  time_step = integral_data.iloc[0]['Time step']
  integral  = integral_data.iloc[0]['Integral velocity magnitude']

  return integral

def get_average_velocity(program, run_no):
  with open(f'./output/average-velocity_{program}_{run_no}.dat', 'r') as file:
    content = file.readlines()

    average_velocity = float(content[0])

  return average_velocity

def calculate_average_velocity(aptofem_run_no, geometry):
  import subprocess
  from miscellaneous import save_output, raise_error

  try:
    subprocess.run(['make'], cwd='./programs/evaluate-solution/', stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=False)
    run_output = subprocess.run(['./evaluate-solution_bb.out', 'nsb', geometry, 'dg_velocity-transport', str(aptofem_run_no), 'n', 'y', '1000', '1000'], cwd='./programs/evaluate-solution/', stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=True)
    save_output.save_output(run_output, "average-velocity", geometry, aptofem_run_no)
  except subprocess.CalledProcessError as e:
    save_output.save_output(e, "average-velocity", geometry, aptofem_run_no)
    raise_error.raise_error(f"Error running average velocity evaluation: {e}")

    return False

  return True