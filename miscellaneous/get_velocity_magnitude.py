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