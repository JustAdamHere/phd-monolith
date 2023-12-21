def get_velocity_magnitude_integral(program, geometry, run_no):
  import pandas as pd

  integral_data = pd.read_csv(f'./output/velocity-magnitude-integral_{program}_{geometry}_{run_no}.dat', sep='\t', header=[0])

  time_step           = integral_data.iloc[0]['Time step']
  integral_ivs        = integral_data.iloc[0]['Integral velocity magnitude (IVS)']
  integral_everywhere = integral_data.iloc[0]['Integral velocity magnitude (everywhere)']

  return integral_ivs, integral_everywhere

def get_one_integral(program, geometry, run_no):
  import pandas as pd

  integral_data = pd.read_csv(f'./output/one-integral_{program}_{geometry}_{run_no}.dat', sep='\t', header=[0])

  time_step           = integral_data.iloc[0]['Time step']
  integral_ivs        = integral_data.iloc[0]['Integral one (IVS)']
  integral_everywhere = integral_data.iloc[0]['Integral one (everywhere)']

  return integral_ivs, integral_everywhere

def calculate_average_velocity(aptofem_run_no, geometry):
  import subprocess
  from miscellaneous import save_output, raise_error

  try:
    # Create object and module directories
    from pathlib import Path
    try:
      Path(f'./programs/evaluate-solution/.obj').mkdir(exist_ok=True)
      Path(f'./programs/evaluate-solution/.mod').mkdir(exist_ok=True)
    except OSError as e:
      print(f"Error: {e.strerror}.")
      exit()

    subprocess.run(['make'], cwd='./programs/evaluate-solution/', stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=False)
    run_output = subprocess.run(['./evaluate-solution_bb.out', 'nsb', geometry, 'dg_velocity-transport', str(aptofem_run_no), 'n', 'y', '250', '250'], cwd='./programs/evaluate-solution/', stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=True)
    save_output.save_output(run_output, "average-velocity", geometry, aptofem_run_no)
  except subprocess.CalledProcessError as e:
    save_output.save_output(e, "average-velocity", geometry, aptofem_run_no)
    raise_error.raise_error(f"Error running average velocity evaluation: {e}")

    return False

  return True

def get_average_velocity(program, geometry, run_no):
  vmi_ivs, vmi_everywhere = get_velocity_magnitude_integral(program, geometry, run_no)
  one_ivs, one_everywhere = get_one_integral               (program, geometry, run_no)

  return vmi_ivs/one_ivs, vmi_everywhere/one_everywhere

def output_solution(aptofem_run_no, geometry):
  import subprocess
  from miscellaneous import save_output, raise_error

  try:
    # Create object and module directories
    from pathlib import Path
    try:
      Path(f'./programs/evaluate-solution/.obj').mkdir(exist_ok=True)
      Path(f'./programs/evaluate-solution/.mod').mkdir(exist_ok=True)
    except OSError as e:
      print(f"Error: {e.strerror}.")
      exit()
            
    subprocess.run(['make'], cwd='./programs/evaluate-solution/', stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=False)
    run_output = subprocess.run(['./evaluate-solution_bb.out', 'nsb', geometry, 'dg_velocity-transport', str(aptofem_run_no), 'y', 'n', '250', '250'], cwd='./programs/evaluate-solution/', stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=True)
    save_output.save_output(run_output, "average-velocity", geometry, aptofem_run_no)
  except subprocess.CalledProcessError as e:
    save_output.save_output(e, "average-velocity", geometry, aptofem_run_no)
    raise_error.raise_error(f"Error running average velocity evaluation: {e}")

    return False

  return True

def get_solution(program, run_no):
  import pandas as pd

  solution_data = pd.read_csv(f'./output/mri-solution_{program}_{run_no}.dat', delim_whitespace=True, skiprows=[0], on_bad_lines='skip', header=None)

  u           = solution_data[0]
  v           = solution_data[1]
  x           = solution_data[2]
  y           = solution_data[3]
  element_nos = solution_data[4]
  no_points   = len(element_nos)

  del solution_data

  return no_points, u, v, x, y, element_nos

def get_slow_velocity_percentage(program, geometry, run_no):
  import pandas as pd

  integral_data = pd.read_csv(f'./output/slow-velocity-integral_{program}_{geometry}_{run_no}.dat', sep='\t', header=[0])

  time_step              = integral_data.iloc[0]['Time step']
  svp_ivs                = integral_data.iloc[0]['Integral slow velocity (IVS)']
  svp_everywhere         = integral_data.iloc[0]['Integral slow velocity (everywhere)']
  svp_dellschaft         = integral_data.iloc[0]['Integral slow velocity (everywhere, 0.0005)']
  fvp_dellschaft         = integral_data.iloc[0]['Integral fast velocity (everywhere, 0.001)']
  svp_nominal_ivs        = integral_data.iloc[0]['Integral slow velocity (IVS, nominal)']
  svp_nominal_everywhere = integral_data.iloc[0]['Integral slow velocity (everywhere, nominal)']

  one_ivs, one_everywhere = get_one_integral(program, geometry, run_no)

  return 100*svp_ivs/one_ivs, 100*svp_everywhere/one_everywhere, 100*svp_dellschaft/one_everywhere, 100*fvp_dellschaft/one_everywhere, 100*svp_nominal_ivs/one_ivs, 100*svp_nominal_everywhere/one_everywhere