def get_fluxes(program, geometry, run_no, no_placentones):
  import pandas as pd

  flux_data = pd.read_csv(f'./output/flux_{program}_{geometry}_{run_no}.dat', sep='\t', header=[0])

  time_step = flux_data.iloc[0]['Time step']
  time      = flux_data.iloc[0]['Time']

  ###################
  # VELOCITY FLUXES #
  ###################
  velocity_cross_flow_fluxes = []
  for i in range(no_placentones-1):
    velocity_cross_flow_fluxes.append(flux_data.iloc[i][f'velocity-crossflow-flux_30{i+1}-30{i+2}'])

  velocity_inlet_fluxes = []
  for i in range(no_placentones):
    velocity_inlet_fluxes.append(flux_data.iloc[i][f'velocity-outflow-flux_11{i+1}'])

  velocity_bp_outlet_fluxes = []
  for i in range(no_placentones):
    velocity_bp_outlet_fluxes.append([flux_data.iloc[i][f'velocity-outflow-flux_{210+2*i+1}'], flux_data.iloc[i][f'velocity-outflow-flux_{210+2*i+2}']])

  # TODO: fix septal fluxes in main program.
  velocity_sw_outlet_fluxes = []
  for i in range(no_placentones-1):
    velocity_sw_outlet_fluxes.append([flux_data.iloc[i][f'velocity-outflow-flux_{240+i*10+1}'], flux_data.iloc[i][f'velocity-outflow-flux_{240+i*10+2}'], flux_data.iloc[i][f'velocity-outflow-flux_{240+i*10+3}']])

  # TODO: fix ms fluxes names in main program.
  velocity_ms_outlet_fluxes = []
  velocity_ms_outlet_fluxes.append(flux_data.iloc[0][f'velocity-outflow-flux_230'])
  velocity_ms_outlet_fluxes.append(flux_data.iloc[0][f'velocity-outflow-flux_231'])

  sum_velocity_flux = flux_data.iloc[0][f'velocity_sum-flux']

  ####################
  # TRANSPORT FLUXES #
  ####################
  transport_cross_flow_fluxes = []
  for i in range(no_placentones-1):
    transport_cross_flow_fluxes.append(flux_data.iloc[i][f'transport-crossflow-flux_30{i+1}-30{i+2}'])

  transport_inlet_fluxes = []
  for i in range(no_placentones):
    transport_inlet_fluxes.append(flux_data.iloc[i][f'transport-outflow-flux_11{i+1}'])

  transport_bp_outlet_fluxes = []
  for i in range(no_placentones):
    transport_bp_outlet_fluxes.append([flux_data.iloc[i][f'transport-outflow-flux_{210+2*i+1}'], flux_data.iloc[i][f'transport-outflow-flux_{210+2*i+2}']])

  # TODO: fix septal fluxes in main program.
  transport_sw_outlet_fluxes = []
  for i in range(no_placentones-1):
    transport_sw_outlet_fluxes.append([flux_data.iloc[i][f'transport-outflow-flux_{240+i*10+1}'], flux_data.iloc[i][f'transport-outflow-flux_{240+i*10+2}'], flux_data.iloc[i][f'transport-outflow-flux_{240+i*10+3}']])

  # TODO: fix ms fluxes names in main program.
  transport_ms_outlet_fluxes = []
  transport_ms_outlet_fluxes.append(flux_data.iloc[0][f'transport-outflow-flux_230'])
  transport_ms_outlet_fluxes.append(flux_data.iloc[0][f'transport-outflow-flux_231'])

  sum_transport_flux = flux_data.iloc[0][f'transport_sum-flux']

  return [time_step, time, velocity_cross_flow_fluxes, velocity_inlet_fluxes, velocity_bp_outlet_fluxes, velocity_sw_outlet_fluxes, velocity_ms_outlet_fluxes, sum_velocity_flux, transport_cross_flow_fluxes, transport_inlet_fluxes, transport_bp_outlet_fluxes, transport_sw_outlet_fluxes, transport_ms_outlet_fluxes, sum_transport_flux]