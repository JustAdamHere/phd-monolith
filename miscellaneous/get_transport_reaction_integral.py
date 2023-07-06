def get_transport_reaction_integral(run_no, geometry):
  import pandas as pd

  integral_data = pd.read_csv(f'./output/transport-reaction-integral_dg_nsku_{geometry}_{run_no}.dat', sep='\t', header=[0])

  time_step = integral_data.iloc[0]['Time step']
  integral  = integral_data.iloc[0]['Integral']

  return integral
