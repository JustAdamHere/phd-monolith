def get_velocity_magnitude_integral(program, geometry, run_no):
  import pandas as pd

  integral_data = pd.read_csv(f'./output/velocity-magnitude-integral_{program}_{geometry}_{run_no}.dat', sep='\t', header=[0])

  time_step           = integral_data.iloc[0]['Time step']
  integral_ivs        = integral_data.iloc[0]['Integral velocity magnitude (IVS)']
  integral_everywhere = integral_data.iloc[0]['Integral velocity magnitude (everywhere)']

  return integral_ivs, integral_everywhere

  # time_step           = integral_data.iloc[0]['Time step']
  # integral_ivs        = integral_data.iloc[0]['Integral velocity magnitude']

  # return integral_ivs, 0

def get_average_velocity(program, run_no):
  with open(f'./output/average-velocity_{program}_{run_no}.dat', 'r') as file:
    content = file.readlines()

    average_velocity_IVS        = float(content[0])
    average_velocity_everywhere = float(content[1])

  return average_velocity_IVS, average_velocity_everywhere

  # with open(f'./output/average-velocity_{program}_{run_no}.dat', 'r') as file:
  #   content = file.readlines()

  #   average_velocity_IVS        = float(content[0])

  # return average_velocity_IVS, 0

def calculate_average_velocity(aptofem_run_no, geometry):
  import subprocess
  from miscellaneous import save_output, raise_error

  try:
    subprocess.run(['make'], cwd='./programs/evaluate-solution/', stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=False)
    run_output = subprocess.run(['./evaluate-solution_bb.out', 'nsb', geometry, 'dg_velocity-transport', str(aptofem_run_no), 'n', 'y', '250', '250'], cwd='./programs/evaluate-solution/', stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=True)
    save_output.save_output(run_output, "average-velocity", geometry, aptofem_run_no)
  except subprocess.CalledProcessError as e:
    save_output.save_output(e, "average-velocity", geometry, aptofem_run_no)
    raise_error.raise_error(f"Error running average velocity evaluation: {e}")

    return False

  return True

def output_solution(aptofem_run_no, geometry):
  import subprocess
  from miscellaneous import save_output, raise_error

  try:
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

# def get_slow_velocity_percentage(program, run_no, average_2=None):
#   if (average_2 == None):
#     average_2 = (get_average_velocity(program, run_no)[0])**2

#   no_points, u, v, x, y, element_nos = get_solution(program, run_no)

#   slow_velocity_counter_ivs        = 0
#   slow_velocity_counter_everywhere = 0
#   ivs_points_counter               = 0
#   everywhere_points_counter        = 0
#   for i in range(no_points):
#     if (element_nos[i] > 0):
#       velocity_magnitude_2 = (u[i]**2 + v[i]**2)

#       if (500 <= element_nos[i] and element_nos[i] <= 519):
#         everywhere_points_counter += 1

#         if (velocity_magnitude_2 < average_2):
#           slow_velocity_counter_everywhere += 1
#       elif ((300 <= element_nos[i] and element_nos[i] <= 399) or
#           (520 <= element_nos[i] and element_nos[i] <= 599)):        
#         everywhere_points_counter += 1
#         ivs_points_counter        += 1
#         if (velocity_magnitude_2 < average_2):
#           slow_velocity_counter_ivs        += 1
#           slow_velocity_counter_everywhere += 1

#   del u, v, x, y, element_nos
  
#   slow_velocity_percentage_ivs        = 100*slow_velocity_counter_ivs       /ivs_points_counter
#   slow_velocity_percentage_everywhere = 100*slow_velocity_counter_everywhere/everywhere_points_counter

#   return slow_velocity_percentage_ivs, slow_velocity_percentage_everywhere

def get_slow_velocity_percentage(program, run_no, average, minimum_region_id, U=1.0, less_than=True, fraction=1.0):
  no_points, u, v, x, y, element_nos = get_solution(program, run_no)

  slow_velocity_counter   = 0
  placenta_points_counter = 0
  for i in range(no_points):
    if (element_nos[i] > 0):
      velocity_magnitude = U*(u[i]**2 + v[i]**2)**0.5
      
      placenta_points_counter += 1

      if ((300 <= element_nos[i] and element_nos[i] <= 399) or
          (minimum_region_id <= element_nos[i] and element_nos[i] <= 529)):
        if (less_than):
          if (velocity_magnitude < fraction*average):
            slow_velocity_counter += 1
        else:
          if (velocity_magnitude > fraction*average):
            slow_velocity_counter += 1


  del u, v, x, y, element_nos
  
  slow_velocity_percentage = 100*slow_velocity_counter/placenta_points_counter

  return slow_velocity_percentage

