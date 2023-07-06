def calculate_sum_fluxes(run_no, geometry):
	import numpy as np
	import pandas as pd
	import matplotlib.pyplot as plt
	import matplotlib.image as mpimg

	septa = False

	#################
	## DATA IMPORT ##
	#################
	flux_data = pd.read_csv(f'./output/flux_dg_nsku_{geometry}_{run_no}.dat', sep='\t', header=[0])

	time_step = flux_data.iloc[0]['Time step']
	time      = flux_data.iloc[0]['Time']

	flux_sum_velocity  = flux_data.iloc[0]['Sum velocity flux']
	flux_sum_transport = flux_data.iloc[0]['Sum transport flux']

	return float(flux_sum_velocity), float(flux_sum_transport)

def calculate_transport_flux(run_no, geometry):
	import numpy as np
	import pandas as pd
	import matplotlib.pyplot as plt
	import matplotlib.image as mpimg

	septa = False

	#################
	## DATA IMPORT ##
	#################
	flux_data = pd.read_csv(f'./output/flux_dg_nsku_{geometry}_{run_no}.dat', sep='\t', header=[0])

	time_step = flux_data.iloc[:]['Time step']
	time      = flux_data.iloc[:]['Time']

	flux_placentone_12 = flux_data.iloc[:]['Placentone 1 to 2']
	flux_placentone_23 = flux_data.iloc[:]['Placentone 2 to 3']
	flux_placentone_34 = flux_data.iloc[:]['Placentone 3 to 4']
	flux_placentone_45 = flux_data.iloc[:]['Placentone 4 to 5']
	flux_placentone_56 = flux_data.iloc[:]['Placentone 5 to 6']

	flux_in_1 = flux_data.iloc[:]['Inlet 1']
	flux_in_2 = flux_data.iloc[:]['Inlet 2']
	flux_in_3 = flux_data.iloc[:]['Inlet 3']
	flux_in_4 = flux_data.iloc[:]['Inlet 4']
	flux_in_5 = flux_data.iloc[:]['Inlet 5']
	flux_in_6 = flux_data.iloc[:]['Inlet 6']

	flux_out_1l = flux_data.iloc[:]['Outlet 1L']
	flux_out_1r = flux_data.iloc[:]['Outlet 1R']
	flux_out_2l = flux_data.iloc[:]['Outlet 2L']
	flux_out_2r = flux_data.iloc[:]['Outlet 2R']
	flux_out_3l = flux_data.iloc[:]['Outlet 3L']
	flux_out_3r = flux_data.iloc[:]['Outlet 3R']
	flux_out_4l = flux_data.iloc[:]['Outlet 4L']
	flux_out_4r = flux_data.iloc[:]['Outlet 4R']
	flux_out_5l = flux_data.iloc[:]['Outlet 5L']
	flux_out_5r = flux_data.iloc[:]['Outlet 5R']
	flux_out_6l = flux_data.iloc[:]['Outlet 6L']
	flux_out_6r = flux_data.iloc[:]['Outlet 6R']

	flux_cornerl = flux_data.iloc[:]['Corner L']
	flux_cornerr = flux_data.iloc[:]['Corner R']

	if (septa):
		flux_septa1 = flux_data.iloc[:]['Septa 1']
		flux_septa2 = flux_data.iloc[:]['Septa 2']
		flux_septa3 = flux_data.iloc[:]['Septa 3']
		flux_septa4 = flux_data.iloc[:]['Septa 4']
	else:
		flux_septa1 = 0
		flux_septa2 = 0
		flux_septa3 = 0
		flux_septa4 = 0

	flux_in_1_transport = flux_data.iloc[:]['Inlet 1 transport']
	flux_in_2_transport = flux_data.iloc[:]['Inlet 2 transport']
	flux_in_3_transport = flux_data.iloc[:]['Inlet 3 transport']
	flux_in_4_transport = flux_data.iloc[:]['Inlet 4 transport']
	flux_in_5_transport = flux_data.iloc[:]['Inlet 5 transport']
	flux_in_6_transport = flux_data.iloc[:]['Inlet 6 transport']

	flux_out_1l_transport = flux_data.iloc[:]['Outlet 1L transport']
	flux_out_1r_transport = flux_data.iloc[:]['Outlet 1R transport']
	flux_out_2l_transport = flux_data.iloc[:]['Outlet 2L transport']
	flux_out_2r_transport = flux_data.iloc[:]['Outlet 2R transport']
	flux_out_3l_transport = flux_data.iloc[:]['Outlet 3L transport']
	flux_out_3r_transport = flux_data.iloc[:]['Outlet 3R transport']
	flux_out_4l_transport = flux_data.iloc[:]['Outlet 4L transport']
	flux_out_4r_transport = flux_data.iloc[:]['Outlet 4R transport']
	flux_out_5l_transport = flux_data.iloc[:]['Outlet 5L transport']
	flux_out_5r_transport = flux_data.iloc[:]['Outlet 5R transport']
	flux_out_6l_transport = flux_data.iloc[:]['Outlet 6L transport']
	flux_out_6r_transport = flux_data.iloc[:]['Outlet 6R transport']

	flux_cornerl_transport = flux_data.iloc[:]['Corner L transport']
	flux_cornerr_transport = flux_data.iloc[:]['Corner R transport']

	flux_sum_velocity  = flux_data.iloc[:]['Sum velocity flux']
	flux_sum_transport = flux_data.iloc[:]['Sum transport flux']

	#####################
	## SANITY CHECKING ##
	#####################
	if (septa):
		placentone1_total = flux_in_1 + flux_out_1l + flux_out_1r + flux_septa4 + flux_cornerl +  flux_placentone_12
	else:
		placentone1_total = flux_in_1 + flux_out_1l + flux_out_1r +               flux_cornerl +  flux_placentone_12
	placentone2_total   = flux_in_2 + flux_out_2l + flux_out_2r +                              -flux_placentone_12 + flux_placentone_23
	if (septa):
		placentone3_total = flux_in_3 + flux_out_3l + flux_out_3r + flux_septa3 +                -flux_placentone_23 + flux_placentone_34
	else:
		placentone3_total = flux_in_3 + flux_out_3l + flux_out_3r +                              -flux_placentone_23 + flux_placentone_34
	placentone4_total   = flux_in_4 + flux_out_4l + flux_out_4r +                              -flux_placentone_34 + flux_placentone_45
	if (septa):
		placentone5_total = flux_in_5 + flux_out_5l + flux_out_5r + flux_septa1 +                -flux_placentone_45 + flux_placentone_56
	else:
		placentone5_total = flux_in_5 + flux_out_5l + flux_out_5r +                              -flux_placentone_45 + flux_placentone_56
	if (septa):
		placentone6_total = flux_in_6 + flux_out_6l + flux_out_6r + flux_septa2 + flux_cornerr + -flux_placentone_56
	else:
		placentone6_total = flux_in_6 + flux_out_6l + flux_out_6r +               flux_cornerr + -flux_placentone_56

	# print(f"\nNet gain at timestep 0:")
	# print(f"Placentone 1: {placentone1_total[0]}")
	# print(f"Placentone 2: {placentone2_total[0]}")
	# print(f"Placentone 3: {placentone3_total[0]}")
	# print(f"Placentone 4: {placentone4_total[0]}")
	# print(f"Placentone 5: {placentone5_total[0]}")
	# print(f"Placentone 6: {placentone6_total[0]}")

	# print(f"\nNet gain at timestep 1:")
	# print(f"Placentone 1: {placentone1_total[1]}")
	# print(f"Placentone 2: {placentone2_total[1]}")
	# print(f"Placentone 3: {placentone3_total[1]}")
	# print(f"Placentone 4: {placentone4_total[1]}")
	# print(f"Placentone 5: {placentone5_total[1]}")
	# print(f"Placentone 6: {placentone6_total[1]}")

	total_transport_in  = flux_in_1_transport    + flux_in_2_transport   + flux_in_3_transport   + flux_in_4_transport   + flux_in_5_transport   + flux_in_6_transport
	total_transport_out = flux_out_1l_transport  + flux_out_2l_transport + flux_out_3l_transport + flux_out_4l_transport + flux_out_5l_transport + flux_out_6l_transport + \
												flux_out_1r_transport  + flux_out_2r_transport + flux_out_3r_transport + flux_out_4r_transport + flux_out_5r_transport + flux_out_6r_transport + \
												flux_cornerl_transport + flux_cornerr_transport

	# Be super careful of the signs here.
	total_transport_uptake = - total_transport_in - total_transport_out

	return total_transport_uptake[0]

def calculate_velocity_flux(run_no, geometry):
	import numpy as np
	import pandas as pd
	import matplotlib.pyplot as plt
	import matplotlib.image as mpimg

	septa = False

	#################
	## DATA IMPORT ##
	#################
	flux_data = pd.read_csv(f'./output/flux_dg_nsku_{geometry}_{run_no}.dat', sep='\t', header=[0])

	time_step = flux_data.iloc[:]['Time step']
	time      = flux_data.iloc[:]['Time']

	flux_placentone_12 = flux_data.iloc[:]['Placentone 1 to 2']
	flux_placentone_23 = flux_data.iloc[:]['Placentone 2 to 3']
	flux_placentone_34 = flux_data.iloc[:]['Placentone 3 to 4']
	flux_placentone_45 = flux_data.iloc[:]['Placentone 4 to 5']
	flux_placentone_56 = flux_data.iloc[:]['Placentone 5 to 6']

	flux_in_1 = flux_data.iloc[:]['Inlet 1']
	flux_in_2 = flux_data.iloc[:]['Inlet 2']
	flux_in_3 = flux_data.iloc[:]['Inlet 3']
	flux_in_4 = flux_data.iloc[:]['Inlet 4']
	flux_in_5 = flux_data.iloc[:]['Inlet 5']
	flux_in_6 = flux_data.iloc[:]['Inlet 6']

	flux_out_1l = flux_data.iloc[:]['Outlet 1L']
	flux_out_1r = flux_data.iloc[:]['Outlet 1R']
	flux_out_2l = flux_data.iloc[:]['Outlet 2L']
	flux_out_2r = flux_data.iloc[:]['Outlet 2R']
	flux_out_3l = flux_data.iloc[:]['Outlet 3L']
	flux_out_3r = flux_data.iloc[:]['Outlet 3R']
	flux_out_4l = flux_data.iloc[:]['Outlet 4L']
	flux_out_4r = flux_data.iloc[:]['Outlet 4R']
	flux_out_5l = flux_data.iloc[:]['Outlet 5L']
	flux_out_5r = flux_data.iloc[:]['Outlet 5R']
	flux_out_6l = flux_data.iloc[:]['Outlet 6L']
	flux_out_6r = flux_data.iloc[:]['Outlet 6R']

	flux_cornerl = flux_data.iloc[:]['Corner L']
	flux_cornerr = flux_data.iloc[:]['Corner R']

	if (septa):
		flux_septa1 = flux_data.iloc[:]['Septa 1']
		flux_septa2 = flux_data.iloc[:]['Septa 2']
		flux_septa3 = flux_data.iloc[:]['Septa 3']
		flux_septa4 = flux_data.iloc[:]['Septa 4']
	else:
		flux_septa1 = 0
		flux_septa2 = 0
		flux_septa3 = 0
		flux_septa4 = 0

	flux_in_1_transport = flux_data.iloc[:]['Inlet 1 transport']
	flux_in_2_transport = flux_data.iloc[:]['Inlet 2 transport']
	flux_in_3_transport = flux_data.iloc[:]['Inlet 3 transport']
	flux_in_4_transport = flux_data.iloc[:]['Inlet 4 transport']
	flux_in_5_transport = flux_data.iloc[:]['Inlet 5 transport']
	flux_in_6_transport = flux_data.iloc[:]['Inlet 6 transport']

	flux_out_1l_transport = flux_data.iloc[:]['Outlet 1L transport']
	flux_out_1r_transport = flux_data.iloc[:]['Outlet 1R transport']
	flux_out_2l_transport = flux_data.iloc[:]['Outlet 2L transport']
	flux_out_2r_transport = flux_data.iloc[:]['Outlet 2R transport']
	flux_out_3l_transport = flux_data.iloc[:]['Outlet 3L transport']
	flux_out_3r_transport = flux_data.iloc[:]['Outlet 3R transport']
	flux_out_4l_transport = flux_data.iloc[:]['Outlet 4L transport']
	flux_out_4r_transport = flux_data.iloc[:]['Outlet 4R transport']
	flux_out_5l_transport = flux_data.iloc[:]['Outlet 5L transport']
	flux_out_5r_transport = flux_data.iloc[:]['Outlet 5R transport']
	flux_out_6l_transport = flux_data.iloc[:]['Outlet 6L transport']
	flux_out_6r_transport = flux_data.iloc[:]['Outlet 6R transport']

	flux_cornerl_transport = flux_data.iloc[:]['Corner L transport']
	flux_cornerr_transport = flux_data.iloc[:]['Corner R transport']

	#####################
	## SANITY CHECKING ##
	#####################
	if (septa):
		placentone1_total = flux_in_1 + flux_out_1l + flux_out_1r + flux_septa4 + flux_cornerl +  flux_placentone_12
	else:
		placentone1_total = flux_in_1 + flux_out_1l + flux_out_1r +               flux_cornerl +  flux_placentone_12
	placentone2_total   = flux_in_2 + flux_out_2l + flux_out_2r +                              -flux_placentone_12 + flux_placentone_23
	if (septa):
		placentone3_total = flux_in_3 + flux_out_3l + flux_out_3r + flux_septa3 +                -flux_placentone_23 + flux_placentone_34
	else:
		placentone3_total = flux_in_3 + flux_out_3l + flux_out_3r +                              -flux_placentone_23 + flux_placentone_34
	placentone4_total   = flux_in_4 + flux_out_4l + flux_out_4r +                              -flux_placentone_34 + flux_placentone_45
	if (septa):
		placentone5_total = flux_in_5 + flux_out_5l + flux_out_5r + flux_septa1 +                -flux_placentone_45 + flux_placentone_56
	else:
		placentone5_total = flux_in_5 + flux_out_5l + flux_out_5r +                              -flux_placentone_45 + flux_placentone_56
	if (septa):
		placentone6_total = flux_in_6 + flux_out_6l + flux_out_6r + flux_septa2 + flux_cornerr + -flux_placentone_56
	else:
		placentone6_total = flux_in_6 + flux_out_6l + flux_out_6r +               flux_cornerr + -flux_placentone_56

	# print(f"\nNet gain at timestep 0:")
	# print(f"Placentone 1: {placentone1_total[0]}")
	# print(f"Placentone 2: {placentone2_total[0]}")
	# print(f"Placentone 3: {placentone3_total[0]}")
	# print(f"Placentone 4: {placentone4_total[0]}")
	# print(f"Placentone 5: {placentone5_total[0]}")
	# print(f"Placentone 6: {placentone6_total[0]}")

	# print(f"\nNet gain at timestep 1:")
	# print(f"Placentone 1: {placentone1_total[1]}")
	# print(f"Placentone 2: {placentone2_total[1]}")
	# print(f"Placentone 3: {placentone3_total[1]}")
	# print(f"Placentone 4: {placentone4_total[1]}")
	# print(f"Placentone 5: {placentone5_total[1]}")
	# print(f"Placentone 6: {placentone6_total[1]}")

	# total_transport_in  = flux_in_1_transport    + flux_in_2_transport   + flux_in_3_transport   + flux_in_4_transport   + flux_in_5_transport   + flux_in_6_transport
	# total_transport_out = flux_out_1l_transport  + flux_out_2l_transport + flux_out_3l_transport + flux_out_4l_transport + flux_out_5l_transport + flux_out_6l_transport + \
	# 											flux_out_1r_transport  + flux_out_2r_transport + flux_out_3r_transport + flux_out_4r_transport + flux_out_5r_transport + flux_out_6r_transport + \
	# 											flux_cornerl_transport + flux_cornerr_transport

	# Be super careful of the signs here.
	# total_transport_uptake = - total_transport_in - total_transport_out

	return placentone1_total[0]

	##############
	## PLOTTING ##
	##############
	# import matplotlib.pyplot as plt

	# fix, ax = plt.subplots(1, 1, figsize=(10, 10))

	# ax.plot(time[1:], total_transport_uptake[1:], 'b-', label='Total transport uptake')
	# ax.plot(time[1:], -total_transport_in[1:], 'r-', label='Total transport in')
	# ax.plot(time[1:], total_transport_out[1:], 'g-', label='Total transport out')

	# ax.set_xlabel('Time (s)')
	# ax.set_ylabel('Oxygen concentration (nondimensional)')
	# ax.set_title('Transport uptake through time')

	# ax.legend()

	# # Save figure.
	# plt.savefig('./images/transport_uptake.png')