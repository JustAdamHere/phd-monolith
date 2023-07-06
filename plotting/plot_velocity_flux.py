def plot(geometry, run_no, septa):
  import numpy as np
  import pandas as pd
  import matplotlib.pyplot as plt
  import matplotlib.image as mpimg

  ###########################
  ## LOCATION CALCULATIONS ##
  ###########################
  #image_dimensions = [5131, 1098]
  image_dimensions = [4718, 1045]

  # Domain parameters.
  placenta_width   = image_dimensions[0]
  placentone_width = (image_dimensions[0]/255.0)*40.0
  wall_width       = 0.075*placentone_width
  pipe_width       = 0.05*placentone_width
  wall_height      = 0.6*placentone_width

  # Geometry parameters.
  centre          = [placenta_width/2, (2*(placenta_width/2)**2)**0.5]
  radius          = centre[1]
  placenta_height = centre[1] - centre[0]

  # Inlet and outlet locations
  location = np.zeros((6, 3, 2)) # 6 placentones x 3 pipes x 2 dimensions

  for i in range(6):
    location[i][0][0] = (placentone_width + wall_width)*i + 0.2*placentone_width
    location[i][1][0] = (placentone_width + wall_width)*i + 0.5*placentone_width
    location[i][2][0] = (placentone_width + wall_width)*i + 0.8*placentone_width

    location[i][0][1] = image_dimensions[1] - (centre[1] - (radius**2 - (location[i][0][0] - centre[0])**2)**0.5)
    location[i][1][1] = image_dimensions[1] - (centre[1] - (radius**2 - (location[i][1][0] - centre[0])**2)**0.5)
    location[i][2][1] = image_dimensions[1] - (centre[1] - (radius**2 - (location[i][2][0] - centre[0])**2)**0.5)

  # Corner outlets.
  location_corner = np.zeros((2, 2)) # 2 outlets x 2 dimensions

  # Walls.
  location_walls_left_top     = np.zeros((5, 2)) # 5 walls x 2 dimensions
  location_walls_left_bottom  = np.zeros((5, 2)) # 5 walls x 2 dimensions
  location_walls_right_top    = np.zeros((5, 2)) # 5 walls x 2 dimensions
  location_walls_right_bottom = np.zeros((5, 2)) # 5 walls x 2 dimensions

  for i in range(5):
    location_walls_left_bottom [i][0] = (placentone_width + wall_width)*i + placentone_width
    location_walls_right_bottom[i][0] = (placentone_width + wall_width)*i + placentone_width + wall_width
    location_walls_left_bottom [i][1] = image_dimensions[1] - (centre[1] - (radius**2 - (location_walls_left_bottom [i][0] - centre[0])**2)**0.5)
    location_walls_right_bottom[i][1] = image_dimensions[1] - (centre[1] - (radius**2 - (location_walls_right_bottom[i][0] - centre[0])**2)**0.5)

    theta1 = np.arctan((location_walls_left_bottom[i][1]  - centre[1])/(location_walls_left_bottom[i][0]  - centre[0]))
    theta2 = np.arctan((location_walls_right_bottom[i][1] - centre[1])/(location_walls_right_bottom[i][0] - centre[0]))

    if (location_walls_left_bottom[i][0]  >= placenta_width/2):
      theta1 -= np.pi
    if (location_walls_right_bottom[i][0] >= placenta_width/2):
      theta2 -= np.pi

    location_walls_left_top[i][0]  = location_walls_left_bottom[i][0]  + wall_height*np.cos(theta1)
    location_walls_left_top[i][1]  = location_walls_left_bottom[i][1]  - wall_height*np.sin(theta1)
    location_walls_right_top[i][0] = location_walls_right_bottom[i][0] + wall_height*np.cos(theta2)
    location_walls_right_top[i][1] = location_walls_right_bottom[i][1] - wall_height*np.sin(theta2)

  # Septa outlets.
  if (septa):
    location_septa = np.zeros((4, 2)) # 4 outlets x 2 dimensions

    location_septa[0] = (location_walls_right_bottom[3] + 0.5*(location_walls_right_top[3] - location_walls_right_bottom[3]))
    location_septa[1] = (location_walls_right_bottom[4] + 0.2*(location_walls_right_top[4] - location_walls_right_bottom[4]))
    location_septa[2] = (location_walls_right_bottom[1] + 0.8*(location_walls_right_top[1] - location_walls_right_bottom[1]))
    location_septa[3] = (location_walls_left_bottom [0] + 0.5*(location_walls_left_top [0] - location_walls_left_bottom [0]))

  # Placentone separators.
  location_separator_bottom = np.zeros((5, 2)) # 5 walls x 2 dimensions
  location_separator_top    = np.zeros((5, 2)) # 5 walls x 2 dimensions

  for i in range(5):
    location_separator_bottom[i] = (location_walls_left_top[i] + location_walls_right_top[i])/2

    if (location_separator_bottom[i][0] == centre[0]):
      theta = 0
    else:
      theta = np.arctan((image_dimensions[1] - (location_separator_bottom[i][0] - centre[0]))/(location_separator_bottom[i][1] - centre[1]))

    location_separator_top[i][1] = 0
    location_separator_top[i][0] = (location_separator_top[i][1] - location_separator_bottom[i][1])*np.tan(theta) + location_separator_bottom[i][0]

  # Crossflow locations.
  location_crossflow = np.zeros((5, 2)) # 5 walls x 2 dimensions

  for i in range(5):
    location_crossflow[i] = (location_separator_bottom[i] + location_separator_top[i])/2

  #################
  ## DATA IMPORT ##
  #################
  flux_data = pd.read_csv(f'./output/flux_dg_nsku_{geometry}_{run_no}.dat', sep='\t', header=[0])

  flux_placentone_12 = flux_data.iloc[0]['Placentone 1 to 2']
  flux_placentone_23 = flux_data.iloc[0]['Placentone 2 to 3']
  flux_placentone_34 = flux_data.iloc[0]['Placentone 3 to 4']
  flux_placentone_45 = flux_data.iloc[0]['Placentone 4 to 5']
  flux_placentone_56 = flux_data.iloc[0]['Placentone 5 to 6']

  flux_in_1 = flux_data.iloc[0]['Inlet 1']
  flux_in_2 = flux_data.iloc[0]['Inlet 2']
  flux_in_3 = flux_data.iloc[0]['Inlet 3']
  flux_in_4 = flux_data.iloc[0]['Inlet 4']
  flux_in_5 = flux_data.iloc[0]['Inlet 5']
  flux_in_6 = flux_data.iloc[0]['Inlet 6']

  flux_out_1l = flux_data.iloc[0]['Outlet 1L']
  flux_out_1r = flux_data.iloc[0]['Outlet 1R']
  flux_out_2l = flux_data.iloc[0]['Outlet 2L']
  flux_out_2r = flux_data.iloc[0]['Outlet 2R']
  flux_out_3l = flux_data.iloc[0]['Outlet 3L']
  flux_out_3r = flux_data.iloc[0]['Outlet 3R']
  flux_out_4l = flux_data.iloc[0]['Outlet 4L']
  flux_out_4r = flux_data.iloc[0]['Outlet 4R']
  flux_out_5l = flux_data.iloc[0]['Outlet 5L']
  flux_out_5r = flux_data.iloc[0]['Outlet 5R']
  flux_out_6l = flux_data.iloc[0]['Outlet 6L']
  flux_out_6r = flux_data.iloc[0]['Outlet 6R']

  flux_cornerl = flux_data.iloc[0]['Corner L']
  flux_cornerr = flux_data.iloc[0]['Corner R']

  if (septa):
    flux_septa1 = flux_data.iloc[0]['Septa 1']
    flux_septa2 = flux_data.iloc[0]['Septa 2']
    flux_septa3 = flux_data.iloc[0]['Septa 3']
    flux_septa4 = flux_data.iloc[0]['Septa 4']
  else:
    flux_septa1 = 0
    flux_septa2 = 0
    flux_septa3 = 0
    flux_septa4 = 0

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

  print(f"Placentone 1: {placentone1_total}")
  print(f"Placentone 2: {placentone2_total}")
  print(f"Placentone 3: {placentone3_total}")
  print(f"Placentone 4: {placentone4_total}")
  print(f"Placentone 5: {placentone5_total}")
  print(f"Placentone 6: {placentone6_total}")

  ###########################
  ## PLOTTING CALCULATIONS ##
  ###########################
  average_inflow = (flux_in_1 + flux_in_2 + flux_in_3 + flux_in_4 + flux_in_5 + flux_in_6)/6

  dx = average_inflow
  dy = average_inflow

  ######################
  ## IMAGE ANNOTATION ##
  ######################
  img = mpimg.imread(f'./images/meshandsoln_dg_nsku_{geometry}_{run_no}_velocity-log.png')

  plt.figure(figsize=(23,5))

  plt.imshow(img)
  plt.axis('off')

  #plt.annotate('Test text', xy=(100, 100), xytext=(200, 200), arrowprops=dict(alpha=0.5, fc='r', ec='r', headwidth=10, frac=0.5/1))
  #plt.arrow(100, 100, 100, 100)
  #plt.annotate('Test text', xy=(200, 200), xytext=(200, 200))

  plt.text(location[0][1][0], location[0][1][1], '{0:.2f}%'.format(100*flux_in_1/average_inflow),   horizontalalignment='center', color='white').set_bbox(dict(facecolor='blue', alpha=0.8, edgecolor='white'))
  plt.text(location[1][1][0], location[1][1][1], '{0:.2f}%'.format(100*flux_in_2/average_inflow),   horizontalalignment='center', color='white').set_bbox(dict(facecolor='blue', alpha=0.8, edgecolor='white'))
  plt.text(location[2][1][0], location[2][1][1], '{0:.2f}%'.format(100*flux_in_3/average_inflow),   horizontalalignment='center', color='white').set_bbox(dict(facecolor='blue', alpha=0.8, edgecolor='white'))
  plt.text(location[3][1][0], location[3][1][1], '{0:.2f}%'.format(100*flux_in_4/average_inflow),   horizontalalignment='center', color='white').set_bbox(dict(facecolor='blue', alpha=0.8, edgecolor='white'))
  plt.text(location[4][1][0], location[4][1][1], '{0:.2f}%'.format(100*flux_in_5/average_inflow),   horizontalalignment='center', color='white').set_bbox(dict(facecolor='blue', alpha=0.8, edgecolor='white'))
  plt.text(location[5][1][0], location[5][1][1], '{0:.2f}%'.format(100*flux_in_6/average_inflow),   horizontalalignment='center', color='white').set_bbox(dict(facecolor='blue', alpha=0.8, edgecolor='white'))

  plt.savefig(f'./images/meshandsoln_dg_nsku_{geometry}_{run_no}_velocity-log_flux-in.png', transparent=True, dpi=300)

  plt.text(location[0][0][0], location[0][0][1], '{0:.2f}%'.format(100*flux_out_1l/average_inflow), horizontalalignment='center', color='white').set_bbox(dict(facecolor='red',  alpha=0.8, edgecolor='white'))
  plt.text(location[0][2][0], location[0][2][1], '{0:.2f}%'.format(100*flux_out_1r/average_inflow), horizontalalignment='center', color='white').set_bbox(dict(facecolor='red',  alpha=0.8, edgecolor='white'))
  plt.text(location[1][0][0], location[1][0][1], '{0:.2f}%'.format(100*flux_out_2l/average_inflow), horizontalalignment='center', color='white').set_bbox(dict(facecolor='red',  alpha=0.8, edgecolor='white'))
  plt.text(location[1][2][0], location[1][2][1], '{0:.2f}%'.format(100*flux_out_2r/average_inflow), horizontalalignment='center', color='white').set_bbox(dict(facecolor='red',  alpha=0.8, edgecolor='white'))
  plt.text(location[2][0][0], location[2][0][1], '{0:.2f}%'.format(100*flux_out_3l/average_inflow), horizontalalignment='center', color='white').set_bbox(dict(facecolor='red',  alpha=0.8, edgecolor='white'))
  plt.text(location[2][2][0], location[2][2][1], '{0:.2f}%'.format(100*flux_out_3r/average_inflow), horizontalalignment='center', color='white').set_bbox(dict(facecolor='red',  alpha=0.8, edgecolor='white'))
  plt.text(location[3][0][0], location[3][0][1], '{0:.2f}%'.format(100*flux_out_4l/average_inflow), horizontalalignment='center', color='white').set_bbox(dict(facecolor='red',  alpha=0.8, edgecolor='white'))
  plt.text(location[3][2][0], location[3][2][1], '{0:.2f}%'.format(100*flux_out_4r/average_inflow), horizontalalignment='center', color='white').set_bbox(dict(facecolor='red',  alpha=0.8, edgecolor='white'))
  plt.text(location[4][0][0], location[4][0][1], '{0:.2f}%'.format(100*flux_out_5l/average_inflow), horizontalalignment='center', color='white').set_bbox(dict(facecolor='red',  alpha=0.8, edgecolor='white'))
  plt.text(location[4][2][0], location[4][2][1], '{0:.2f}%'.format(100*flux_out_5r/average_inflow), horizontalalignment='center', color='white').set_bbox(dict(facecolor='red',  alpha=0.8, edgecolor='white'))
  plt.text(location[5][0][0], location[5][0][1], '{0:.2f}%'.format(100*flux_out_6l/average_inflow), horizontalalignment='center', color='white').set_bbox(dict(facecolor='red',  alpha=0.8, edgecolor='white'))
  plt.text(location[5][2][0], location[5][2][1], '{0:.2f}%'.format(100*flux_out_6r/average_inflow), horizontalalignment='center', color='white').set_bbox(dict(facecolor='red',  alpha=0.8, edgecolor='white'))

  if (septa):
    plt.text(location_septa[0][0], location_septa[0][1], '{0:.2f}%'.format(100*flux_septa1/average_inflow), horizontalalignment='center', color='white').set_bbox(dict(facecolor='red', alpha=0.8, edgecolor='white'))
    plt.text(location_septa[1][0], location_septa[1][1], '{0:.2f}%'.format(100*flux_septa2/average_inflow), horizontalalignment='center', color='white').set_bbox(dict(facecolor='red', alpha=0.8, edgecolor='white'))
    plt.text(location_septa[2][0], location_septa[2][1], '{0:.2f}%'.format(100*flux_septa3/average_inflow), horizontalalignment='center', color='white').set_bbox(dict(facecolor='red', alpha=0.8, edgecolor='white'))
    plt.text(location_septa[3][0], location_septa[3][1], '{0:.2f}%'.format(100*flux_septa4/average_inflow), horizontalalignment='center', color='white').set_bbox(dict(facecolor='red', alpha=0.8, edgecolor='white'))

  plt.savefig(f'./images/meshandsoln_dg_nsku_{geometry}_{run_no}_velocity-log_flux-in-out.png', transparent=True, dpi=300)

  plt.text(0,              pipe_width, '{0:.2f}%'.format(100*flux_cornerl/average_inflow), horizontalalignment='center', color='white').set_bbox(dict(facecolor='red', alpha=0.8, edgecolor='white'))
  plt.text(placenta_width, pipe_width, '{0:.2f}%'.format(100*flux_cornerr/average_inflow), horizontalalignment='center', color='white').set_bbox(dict(facecolor='red', alpha=0.8, edgecolor='white'))

  plt.savefig(f'./images/meshandsoln_dg_nsku_{geometry}_{run_no}_velocity-log_flux-in-out-corner.png', transparent=True, dpi=300)

  plt.text(location_crossflow[0][0], location_crossflow[0][1], '{0:.2f}%'.format(100*flux_placentone_12/average_inflow), fontsize=24, horizontalalignment='center', color='white').set_bbox(dict(facecolor='green', alpha=0.8, edgecolor='white'))
  plt.text(location_crossflow[1][0], location_crossflow[1][1], '{0:.2f}%'.format(100*flux_placentone_23/average_inflow), fontsize=24, horizontalalignment='center', color='white').set_bbox(dict(facecolor='green', alpha=0.8, edgecolor='white'))
  plt.text(location_crossflow[2][0], location_crossflow[2][1], '{0:.2f}%'.format(100*flux_placentone_34/average_inflow), fontsize=24, horizontalalignment='center', color='white').set_bbox(dict(facecolor='green', alpha=0.8, edgecolor='white'))
  plt.text(location_crossflow[3][0], location_crossflow[3][1], '{0:.2f}%'.format(100*flux_placentone_45/average_inflow), fontsize=24, horizontalalignment='center', color='white').set_bbox(dict(facecolor='green', alpha=0.8, edgecolor='white'))
  plt.text(location_crossflow[4][0], location_crossflow[4][1], '{0:.2f}%'.format(100*flux_placentone_56/average_inflow), fontsize=24, horizontalalignment='center', color='white').set_bbox(dict(facecolor='green', alpha=0.8, edgecolor='white'))

  plt.savefig(f'./images/meshandsoln_dg_nsku_{geometry}_{run_no}_velocity-log_flux-in-out-corner-cross.png', transparent=True, dpi=300)

  #plt.show()