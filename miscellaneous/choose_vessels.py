import numpy as np
from random import sample, randint

def calculate_max_min_no_veins(no_placentones):
  min_value = 0
  max_value = no_placentones*2 + (no_placentones-1)*3

  return min_value, max_value

def calculate_max_min_no_arteries(no_placentones):
  min_value = 1
  max_value = no_placentones

  return min_value, max_value

def calculate_placentone_widths(no_placentones):
  if (no_placentones == 6):
    r = np.sqrt(29)/4 - 0.5

    placentone_widths = np.array([1*r**2, 1*r, 1, 1, 1*r, 1*r**2])
  elif (no_placentones == 7):
    r = 0.815957986

    placentone_widths = np.array([1*r**3, 1*r**2, 1*r, 1, 1*r, 1*r**2, 1*r**3])
    
  return placentone_widths

def calculate_septal_wall_lengths(no_placentones):
  septal_wall_lengths = 0.1725*np.ones((no_placentones-1, 3))

  if (no_placentones == 6):
    septal_wall_lengths[0, 1] = 2*0.0395358887166
    septal_wall_lengths[1, 1] = 2*0.0356895848567
    septal_wall_lengths[2, 1] = 2*0.0361966717127
    septal_wall_lengths[3, 1] = 2*0.0356895848567
    septal_wall_lengths[4, 1] = 2*0.0395358887166

    septal_wall_lengths[1, 0] = 0.35175
    septal_wall_lengths[1, 2] = 0.35175
    septal_wall_lengths[3, 0] = 0.35175
    septal_wall_lengths[3, 2] = 0.35175
  elif (no_placentones == 7):
    raise ValueError("Septal wall lengths not implemented for 7 placentones.")

  return septal_wall_lengths

def calculate_no_arteries(no_placentones):
  min_arteries, max_arteries = calculate_max_min_no_arteries(no_placentones)

  return int(randint(min_arteries, max_arteries))

def calculate_no_veins(no_placentones):
  min_veins, max_veins = calculate_max_min_no_veins(no_placentones)

  return int(randint(min_veins, max_veins))

def calculate_vessel_position(a, b, ε):
  x = np.random.uniform(a + ε, b - ε)
  return x

def calculate_vessel_enabled(no_veins, no_arteries, no_placentones):
  # Initialise vein locations, with marginal sinuses turned on.
  basal_plate_vessels  = np.array([[0, 0, 0]]*no_placentones)
  marginal_sinus_veins = np.array([1, 1])
  septal_wall_veins    = np.array([[0, 0, 0]]*(no_placentones-1))

  # Decide where the arteries will be located in each placentone.
  min_arteries, max_arteries = calculate_max_min_no_arteries(no_placentones)
  min_veins, max_veins       = calculate_max_min_no_veins   (no_placentones)
  artery_locations           = sample(range(max_arteries),  no_arteries)
  vein_locations             = sample(range(max_veins),     no_veins)

  for artery in artery_locations:
    basal_plate_vessels[artery, 1] = 1

  for vein in vein_locations:
    # vein = 0, 1 basal plate veins in placentone 1.
    # vein = 2, 3 basal plate veins in placentone 2.
    # ...
    # vein = 10, 11 basal plate veins in placentone 6.
    # ---
    # vein = 12, 13, 14 septal wall veins on wall 1.
    # vein = 15, 16, 17 septal wall veins on wall 2.
    # ...
    # vein = 24, 25, 26 septal wall veins on wall 5.

    # Basal plate vein.
    if (vein < no_placentones*2):
      placentone_no = vein // 2
      pos_no        = vein % 2

      if (pos_no == 1):
        pos_no = 2

      basal_plate_vessels[placentone_no, pos_no] = 1
    # Septal wall vein.
    else:
      wall_no = (vein - no_placentones*2) // 3
      pos_no  = (vein - no_placentones*2) % 3

      septal_wall_veins[wall_no, pos_no] = 1

  return basal_plate_vessels.tolist(), marginal_sinus_veins.tolist(), septal_wall_veins.tolist()

def calculate_vessel_positions(basal_plate_vessels, septal_wall_veins, no_placentones, artery_padding, vein_padding, epsilon_padding):
  placentone_widths   = calculate_placentone_widths(no_placentones)
  septal_wall_lengths = calculate_septal_wall_lengths(no_placentones)

  basal_plate_vessel_positions = np.array([[0, 0, 0]]*no_placentones, dtype=float)
  septal_wall_vein_positions   = np.array([[0, 0, 0]]*(no_placentones-1), dtype=float)

  # Loop over all walls.
  for k in range(no_placentones-1):
    for j in range(3):
      if (septal_wall_veins[k][j] == 1):
        septal_wall_vein_positions[k, j] = calculate_vessel_position(0 + vein_padding/septal_wall_lengths[k, j], 1 - vein_padding/septal_wall_lengths[k, j], epsilon_padding)
  
  # Loop over all placentones.
  for k in range(no_placentones):
    if (k == 0):
      periphery_artery_left_offset  = 0.38-artery_padding/placentone_widths[k]
      periphery_artery_right_offset = 0
    elif (k == no_placentones-1):
      periphery_artery_left_offset  = 0
      periphery_artery_right_offset = 0.38-artery_padding/placentone_widths[k]
    else:
      periphery_artery_left_offset  = 0
      periphery_artery_right_offset = 0

    match basal_plate_vessels[k]:
      case [1, 0, 0]:
        # 1st: Calculate vein position.
        vein_limited_range                 = [0 + vein_padding/placentone_widths[k], 1 - vein_padding/placentone_widths[k]]
        basal_plate_vessel_positions[k, 0] = calculate_vessel_position(vein_limited_range[0], vein_limited_range[1], epsilon_padding)
      case [0, 0, 1]:
        # 1st: Calculate vein position.
        vein_limited_range                 = [0 + vein_padding/placentone_widths[k], 1 - vein_padding/placentone_widths[k]]
        basal_plate_vessel_positions[k, 2] = calculate_vessel_position(vein_limited_range[0], vein_limited_range[1], epsilon_padding)
      case [1, 0, 1]:
        # Decide which vein will be generated first.
        first_vein = np.random.randint(2)

        match first_vein:
          case 0:
            # 1st: Calculate left vein position.
            vein_limited_range                 = [0 + vein_padding/placentone_widths[k], 1 - 3*vein_padding/placentone_widths[k]]
            basal_plate_vessel_positions[k, 0] = calculate_vessel_position(vein_limited_range[0], vein_limited_range[1], epsilon_padding)

            # 2nd: Calculate right vein position.
            vein_limited_range                 = [basal_plate_vessel_positions[k, 0] + 2*vein_padding/placentone_widths[k], 1 - vein_padding/placentone_widths[k]]
            basal_plate_vessel_positions[k, 2] = calculate_vessel_position(vein_limited_range[0], vein_limited_range[1], epsilon_padding)
          case 1:
            # 1st: Calculate right vein position.
            vein_limited_range                 = [0 + 3*vein_padding/placentone_widths[k], 1 - vein_padding/placentone_widths[k]]
            basal_plate_vessel_positions[k, 2] = calculate_vessel_position(vein_limited_range[0], vein_limited_range[1], epsilon_padding)

            # 2nd: Calculate left vein position.
            vein_limited_range                 = [0 + vein_padding/placentone_widths[k], basal_plate_vessel_positions[k, 2] - 2*vein_padding/placentone_widths[k]]
            basal_plate_vessel_positions[k, 0] = calculate_vessel_position(vein_limited_range[0], vein_limited_range[1], epsilon_padding)
      case [0, 1, 0]:
        # 1st: Calculate artery position.
        artery_limited_range               = [0 + (periphery_artery_left_offset + artery_padding/placentone_widths[k]), 1 - (artery_padding/placentone_widths[k] + periphery_artery_right_offset)]
        basal_plate_vessel_positions[k, 1] = calculate_vessel_position(artery_limited_range[0], artery_limited_range[1], epsilon_padding)
      case [0, 1, 1]:
        # 1st: Calculate artery position.
        artery_limited_range               = [0 + (periphery_artery_left_offset + artery_padding/placentone_widths[k]), 1 - (artery_padding/placentone_widths[k] + 2*vein_padding/placentone_widths[k] + periphery_artery_right_offset)]
        basal_plate_vessel_positions[k, 1] = calculate_vessel_position(artery_limited_range[0], artery_limited_range[1], epsilon_padding)

        # 2nd: Calculate vein position.
        vein_limited_range                 = [basal_plate_vessel_positions[k, 1] + artery_padding/placentone_widths[k] + vein_padding/placentone_widths[k], 1 - vein_padding/placentone_widths[k]]
        basal_plate_vessel_positions[k, 2] = calculate_vessel_position(vein_limited_range[0], vein_limited_range[1], epsilon_padding)
      case [1, 1, 0]:
        # 1st: Calculate artery position.
        artery_limited_range               = [0 + (periphery_artery_left_offset + artery_padding/placentone_widths[k] + 2*vein_padding/placentone_widths[k]), 1 - (artery_padding/placentone_widths[k] + periphery_artery_right_offset)]
        basal_plate_vessel_positions[k, 1] = calculate_vessel_position(artery_limited_range[0], artery_limited_range[1], epsilon_padding)

        # 2nd: Calculate vein position.
        vein_limited_range                 = [0 + vein_padding/placentone_widths[k], basal_plate_vessel_positions[k, 1] - (artery_padding/placentone_widths[k] + vein_padding/placentone_widths[k])]
        basal_plate_vessel_positions[k, 0] = calculate_vessel_position(vein_limited_range[0], vein_limited_range[1], epsilon_padding)
      case [1, 1, 1]:
        # 1st: Calculate artery position.
        artery_limited_range               = [0 + (periphery_artery_left_offset + artery_padding/placentone_widths[k] + 2*vein_padding/placentone_widths[k]), 1 - (artery_padding/placentone_widths[k] + 2*vein_padding/placentone_widths[k] + periphery_artery_right_offset)]
        basal_plate_vessel_positions[k, 1] = calculate_vessel_position(artery_limited_range[0], artery_limited_range[1], epsilon_padding)

        # 2nd: Calculate left vein position.
        vein_limited_range                 = [0 + vein_padding/placentone_widths[k], basal_plate_vessel_positions[k, 1] - (artery_padding/placentone_widths[k] + vein_padding/placentone_widths[k])]
        basal_plate_vessel_positions[k, 0] = calculate_vessel_position(vein_limited_range[0], vein_limited_range[1], epsilon_padding)

        # 3rd: Calculate right vein position.
        vein_limited_range                 = [basal_plate_vessel_positions[k, 1] + artery_padding/placentone_widths[k] + vein_padding/placentone_widths[k], 1 - vein_padding/placentone_widths[k]]
        basal_plate_vessel_positions[k, 2] = calculate_vessel_position(vein_limited_range[0], vein_limited_range[1], epsilon_padding)

  return basal_plate_vessel_positions.tolist(), septal_wall_vein_positions.tolist()