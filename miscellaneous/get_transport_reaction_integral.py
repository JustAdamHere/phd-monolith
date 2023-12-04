def get_transport_reaction_integral(program, geometry, run_no):
  import pandas as pd
  from miscellaneous import get_velocity_magnitude

  integral_data = pd.read_csv(f'./output/transport-reaction-integral_{program}_{geometry}_{run_no}.dat', sep='\t', header=[0])

  time_step = integral_data.iloc[0]['Time step']
  integral  = integral_data.iloc[0]['Integral']

  one_ivs, one_everywhere = get_velocity_magnitude.get_one_integral(program, geometry, run_no)

  return integral/one_everywhere
