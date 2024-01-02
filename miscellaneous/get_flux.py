def get_fluxes(program, geometry, run_no, no_placentones):
  import pandas as pd

  flux_data = pd.read_csv(f'./output/flux_{program}_{geometry}_{run_no}.dat', sep='\t', header=[0])

  time_step = flux_data.iloc[0]['timestep_no']
  time      = flux_data.iloc[0]['current_time']

  ###################
  # VELOCITY FLUXES #
  ###################
  velocity_cross_flow_fluxes = []
  for i in range(no_placentones-1):
    velocity_cross_flow_fluxes.append(flux_data.iloc[0][f'velocity-crossflow-flux_30{i+1}-30{i+2}'])

  velocity_inlet_fluxes = []
  for i in range(no_placentones):
    velocity_inlet_fluxes.append(flux_data.iloc[0][f'velocity-outflow-flux_11{i+1}'])

  velocity_bp_outlet_fluxes = []
  for i in range(no_placentones):
    velocity_bp_outlet_fluxes.append([flux_data.iloc[0][f'velocity-outflow-flux_{210+2*i+1}'], flux_data.iloc[0][f'velocity-outflow-flux_{210+2*i+2}']])

  velocity_sw_outlet_fluxes = []
  for i in range(no_placentones-1):
    velocity_sw_outlet_fluxes.append([flux_data.iloc[0][f'velocity-outflow-flux_{240+i*10+1}'], flux_data.iloc[0][f'velocity-outflow-flux_{240+i*10+2}'], flux_data.iloc[0][f'velocity-outflow-flux_{240+i*10+3}']])

  velocity_ms_outlet_fluxes = []
  velocity_ms_outlet_fluxes.append(flux_data.iloc[0][f'velocity-outflow-flux_230'])
  velocity_ms_outlet_fluxes.append(flux_data.iloc[0][f'velocity-outflow-flux_231'])

  sum_velocity_flux = flux_data.iloc[0][f'velocity-sum-flux']

  ####################
  # TRANSPORT FLUXES #
  ####################
  transport_cross_flow_fluxes = []
  for i in range(no_placentones-1):
    # transport_cross_flow_fluxes.append(flux_data.iloc[0][f'transport-crossflow-flux_30{i+1}-30{i+2}'])
    transport_cross_flow_fluxes.append(-1)

  transport_inlet_fluxes = []
  for i in range(no_placentones):
    transport_inlet_fluxes.append(flux_data.iloc[0][f'transport-outflow-flux_11{i+1}'])

  transport_bp_outlet_fluxes = []
  for i in range(no_placentones):
    transport_bp_outlet_fluxes.append([flux_data.iloc[0][f'transport-outflow-flux_{210+2*i+1}'], flux_data.iloc[0][f'transport-outflow-flux_{210+2*i+2}']])

  transport_sw_outlet_fluxes = []
  for i in range(no_placentones-1):
    transport_sw_outlet_fluxes.append([flux_data.iloc[0][f'transport-outflow-flux_{240+i*10+1}'], flux_data.iloc[0][f'transport-outflow-flux_{240+i*10+2}'], flux_data.iloc[0][f'transport-outflow-flux_{240+i*10+3}']])

  transport_ms_outlet_fluxes = []
  transport_ms_outlet_fluxes.append(flux_data.iloc[0][f'transport-outflow-flux_230'])
  transport_ms_outlet_fluxes.append(flux_data.iloc[0][f'transport-outflow-flux_231'])

  sum_transport_flux = flux_data.iloc[0][f'transport-sum-flux']

  ##########################
  # PRESSURE ENERGY FLUXES #
  ##########################
  pe_cross_flow_fluxes = []
  for i in range(no_placentones-1):
    # pe_cross_flow_fluxes.append(flux_data.iloc[0][f'pe-crossflow-flux_30{i+1}-30{i+2}'])
    pe_cross_flow_fluxes.append(-1)

  pe_inlet_fluxes = []
  for i in range(no_placentones):
    pe_inlet_fluxes.append(flux_data.iloc[0][f'pe-outflow-flux_11{i+1}'])

  pe_bp_outlet_fluxes = []
  for i in range(no_placentones):
    pe_bp_outlet_fluxes.append([flux_data.iloc[0][f'pe-outflow-flux_{210+2*i+1}'], flux_data.iloc[0][f'pe-outflow-flux_{210+2*i+2}']])

  pe_sw_outlet_fluxes = []
  for i in range(no_placentones-1):
    pe_sw_outlet_fluxes.append([flux_data.iloc[0][f'pe-outflow-flux_{240+i*10+1}'], flux_data.iloc[0][f'pe-outflow-flux_{240+i*10+2}'], flux_data.iloc[0][f'pe-outflow-flux_{240+i*10+3}']])
    
  pe_ms_outlet_fluxes = []
  pe_ms_outlet_fluxes.append(flux_data.iloc[0][f'pe-outflow-flux_230'])
  pe_ms_outlet_fluxes.append(flux_data.iloc[0][f'pe-outflow-flux_231'])

  sum_pe_flux = flux_data.iloc[0][f'pe-sum-flux']

  ##########################
  # KINETIC ENERGY FLUXES #
  ##########################
  ke_cross_flow_fluxes = []
  for i in range(no_placentones-1):
    # ke_cross_flow_fluxes.append(flux_data.iloc[0][f'ke-crossflow-flux_30{i+1}-30{i+2}'])
    ke_cross_flow_fluxes.append(-1)

  ke_inlet_fluxes = []
  for i in range(no_placentones):
    ke_inlet_fluxes.append(flux_data.iloc[0][f'ke-outflow-flux_11{i+1}'])

  ke_bp_outlet_fluxes = []
  for i in range(no_placentones):
    ke_bp_outlet_fluxes.append([flux_data.iloc[0][f'ke-outflow-flux_{210+2*i+1}'], flux_data.iloc[0][f'ke-outflow-flux_{210+2*i+2}']])

  ke_sw_outlet_fluxes = []
  for i in range(no_placentones-1):
    ke_sw_outlet_fluxes.append([flux_data.iloc[0][f'ke-outflow-flux_{240+i*10+1}'], flux_data.iloc[0][f'ke-outflow-flux_{240+i*10+2}'], flux_data.iloc[0][f'ke-outflow-flux_{240+i*10+3}']])
    
  ke_ms_outlet_fluxes = []
  ke_ms_outlet_fluxes.append(flux_data.iloc[0][f'ke-outflow-flux_230'])
  ke_ms_outlet_fluxes.append(flux_data.iloc[0][f'ke-outflow-flux_231'])

  sum_ke_flux = flux_data.iloc[0][f'ke-sum-flux']

  return [time_step, time, velocity_cross_flow_fluxes, velocity_inlet_fluxes, velocity_bp_outlet_fluxes, velocity_sw_outlet_fluxes, velocity_ms_outlet_fluxes, sum_velocity_flux, transport_cross_flow_fluxes, transport_inlet_fluxes, transport_bp_outlet_fluxes, transport_sw_outlet_fluxes, transport_ms_outlet_fluxes, sum_transport_flux, pe_cross_flow_fluxes, pe_inlet_fluxes, pe_bp_outlet_fluxes, pe_sw_outlet_fluxes, pe_ms_outlet_fluxes, sum_pe_flux, ke_cross_flow_fluxes, ke_inlet_fluxes, ke_bp_outlet_fluxes, ke_sw_outlet_fluxes, ke_ms_outlet_fluxes, sum_ke_flux]