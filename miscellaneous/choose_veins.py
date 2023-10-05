import numpy as np
from scipy.stats import truncnorm

def calculate_max_min_no_veins(no_placentones):
  min_value = 0
  max_value = 4
  min_veins = np.array((no_placentones)*[min_value])
  max_veins = np.array([max_value-1] + (no_placentones-2)*[max_value] + [max_value-1]) # Reduce veins by 1 for marginal sinuses.

  return min_veins, max_veins

def calculate_max_min_no_arteries(no_placentones):
  min_value = 0
  max_value = 1
  min_arteries = np.array((no_placentones)*[min_value])
  max_arteries = np.array((no_placentones)*[max_value])

  return min_arteries, max_arteries

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

#####
# Function to calculate the number of veins in each placentone using a truncated normal distribution.
# Inputs:
#  no_veins_range: (2) range of possible number of veins
#  mean:           mean of the distribution
#  std:            standard deviation of the distribution
#  no_placentones: number of placentones
# Returns:
#  no_veins: number of veins in each placentone
#####
def calculate_no_veins(mean, std, no_placentones):
  min_veins, max_veins = calculate_max_min_no_veins(no_placentones)

  # Sample centred around the mean.
  no_veins = np.zeros(no_placentones)
  for i in range(no_placentones):
    # Define cut off values at 0 and 4 (or 3).
    a, b = (min_veins[i] - mean) / std, (max_veins[i] - mean) / std
    no_veins[i] = np.round(truncnorm.rvs(a, b, loc=mean, scale=std))

  return no_veins

#####
# Function to calculate the number of arteries in each placentone using a truncated normal distribution. Importantly, this function ensures that at least 1 artery is enabled.
# Inputs:
#  mean:           mean of the distribution
#  std:            standard deviation of the distribution
#  no_placentones: number of placentones
# Returns:
#  no_arteries: number of arteries in each placentone
####
def calculate_no_arteries(mean, std, no_placentones):
  # min_arteries, max_arteries = calculate_max_min_no_arteries(no_placentones)

  # # Sample centred around the mean/4.
  # no_arteries = np.zeros(no_placentones)
  # for i in range(no_placentones):
  #   # Define cut off values at 0 and 1.
  #   a, b = (min_arteries[i] - mean/4) / std, (max_arteries[i] - mean/4) / std
  #   no_arteries[i] = np.round(truncnorm.rvs(a, b, loc=mean/4, scale=std/4))

  # # Randomly turn on an artery if none are turned on.
  # if (np.sum(no_arteries) == 0):
  #   no_arteries[np.random.randint(0, no_placentones)] = 1
  
  # return no_arteries

  return np.ones(no_placentones)

####
# Function to calculate position of vessels.
# Inputs:
#  a:  minimum value with restrictions added
#  b:  maximum value with restrictions added
# Returns:
#  x:   number between 0 and 1 (perhaps with some additional restriction to avoid clashes with other vessels), representing the position of the vessel along the surface.
####
def calculate_vessel_position(a, b):
  # print(f"calculate_vessel_position: a={a}, b={b}, a_min = {np.max([a, 0])}, b_min = {np.min([b, 1])}")
  # return 
  x = np.random.uniform(a, b)
  return x

####
# Function to turn on/off the veins.
#  no_veins:       number of veins in each placentone
#  no_arteries:    number of arteries in each placentone
#  no_placentones: number of placentones
# Returns:
#  basal_plate_vessels:  enabled veins the basal_plate vessels (including arteries)
#  marginal_sinus_veins: enabled veins the marginal sinus veins
#  septal_wall_veins:    enabled veins the septal wall veins
####
def calculate_vessel_enabled(no_veins, no_arteries, no_placentones):
  from random import sample

  # Initialise vein locations, with arteries turned on.
  basal_plate_vessels  = np.array([[0, 0, 0]]*no_placentones)
  marginal_sinus_veins = np.array([1, 1])
  septal_wall_veins    = np.array([[0, 0, 0]]*(no_placentones-1))

  # Decide where the veins will be located in each placentone.
  for j in range(0, no_placentones):
    # Sample vein locations, with no repeats.
    #  pos = 0: septal wall left (if applicable)
    #  pos = 1: basal plate left
    #  pos = 2: basal plate right
    #  pos = 3: septal wall right (if applicable)
    vein_locations = sample(range(4), int(no_veins[j]))

    # Turn on the veins.
    for k in range(len(vein_locations)):
      vein_location = vein_locations[k]

      match vein_location:
        case 0:
          if (j != 0):
            septal_wall_veins[j-1, 2] = 1
        case 1:
          basal_plate_vessels[j, 0] = 1
        case 2:
          basal_plate_vessels[j, 2] = 1  
        case 3:
          if (j != no_placentones-1):
            septal_wall_veins[j, 0] = 1

    # Turn on the arteries.
    if no_arteries[j] == 1:
      basal_plate_vessels[j, 1] = 1

  return basal_plate_vessels.tolist(), marginal_sinus_veins.tolist(), septal_wall_veins.tolist()

####
# Function to calculate the positions of the veins.
# Inputs:
#  basal_plate_vessels:  enabled veins the basal_plate vessels (including arteries)
#  septal_wall_veins:    enabled veins the septal wall veins
#  no_placentones:       number of placentones
#  artery_padding:       padding between the artery and another vessel/wall
#  vein_padding:         padding between a vein and another vessel/wall
#  placentone_widths:    (6) widths of the placentones
#  septal_wall_lengths:  (5 x 3) lengths of the septal walls
# Returns:
#  basal_plate_vessel_positions:  positions of the veins
#  septal_wall_vein_positions:    positions of the septal wall veins
###
def calculate_vein_positions(basal_plate_vessels, septal_wall_veins, no_placentones, artery_padding, vein_padding):
  placentone_widths   = calculate_placentone_widths(no_placentones)
  septal_wall_lengths = calculate_septal_wall_lengths(no_placentones)

  basal_plate_vessel_positions = np.array([[0, 0, 0]]*no_placentones, dtype=float)
  septal_wall_vein_positions   = np.array([[0, 0, 0]]*(no_placentones-1), dtype=float)

  # Loop over all walls.
  for k in range(no_placentones-1):
    for j in range(3):
      if (septal_wall_veins[k][j] == 1):
        septal_wall_vein_positions[k, j] = calculate_vessel_position(0 + vein_padding/septal_wall_lengths[k, j], 1 - vein_padding/septal_wall_lengths[k, j])
  
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
        basal_plate_vessel_positions[k, 0] = calculate_vessel_position(vein_limited_range[0], vein_limited_range[1])
      case [0, 0, 1]:
        # 1st: Calculate vein position.
        vein_limited_range                 = [0 + vein_padding/placentone_widths[k], 1 - vein_padding/placentone_widths[k]]
        basal_plate_vessel_positions[k, 2] = calculate_vessel_position(vein_limited_range[0], vein_limited_range[1])
      case [1, 0, 1]:
        # Decide which vein will be generated first.
        first_vein = np.random.randint(2)

        match first_vein:
          case 0:
            # 1st: Calculate left vein position.
            vein_limited_range                 = [0 + vein_padding/placentone_widths[k], 1 - vein_padding/placentone_widths[k]]
            basal_plate_vessel_positions[k, 0] = calculate_vessel_position(vein_limited_range[0], vein_limited_range[1])

            # 2nd: Calculate right vein position.
            vein_limited_range                 = [basal_plate_vessel_positions[k, 0] + vein_padding/placentone_widths[k], 1 - vein_padding/placentone_widths[k]]
            basal_plate_vessel_positions[k, 2] = calculate_vessel_position(vein_limited_range[0], vein_limited_range[1])
          case 1:
            # 1st: Calculate right vein position.
            vein_limited_range                 = [0 + vein_padding/placentone_widths[k], 1 - vein_padding/placentone_widths[k]]
            basal_plate_vessel_positions[k, 2] = calculate_vessel_position(vein_limited_range[0], vein_limited_range[1])

            # 2nd: Calculate left vein position.
            vein_limited_range                 = [0 + vein_padding/placentone_widths[k], basal_plate_vessel_positions[k, 2] - vein_padding/placentone_widths[k]]
            basal_plate_vessel_positions[k, 0] = calculate_vessel_position(vein_limited_range[0], vein_limited_range[1])
      case [0, 1, 0]:
        # 1st: Calculate artery position.
        artery_limited_range               = [0 + (periphery_artery_left_offset + artery_padding/placentone_widths[k]), 1 - (artery_padding/placentone_widths[k] + periphery_artery_right_offset)]
        basal_plate_vessel_positions[k, 1] = calculate_vessel_position(artery_limited_range[0], artery_limited_range[1])
      case [0, 1, 1]:
        # 1st: Calculate artery position.
        artery_limited_range               = [0 + (periphery_artery_left_offset + artery_padding/placentone_widths[k]), 1 - (artery_padding/placentone_widths[k] + 2*vein_padding/placentone_widths[k] + periphery_artery_right_offset)]
        basal_plate_vessel_positions[k, 1] = calculate_vessel_position(artery_limited_range[0], artery_limited_range[1])

        # 2nd: Calculate vein position.
        vein_limited_range                 = [basal_plate_vessel_positions[k, 1] + artery_padding/placentone_widths[k] + vein_padding/placentone_widths[k], 1 - vein_padding/placentone_widths[k]]
        basal_plate_vessel_positions[k, 2] = calculate_vessel_position(vein_limited_range[0], vein_limited_range[1])
      case [1, 1, 0]:
        # 1st: Calculate artery position.
        artery_limited_range               = [0 + (periphery_artery_left_offset + artery_padding/placentone_widths[k] + 2*vein_padding/placentone_widths[k]), 1 - (artery_padding/placentone_widths[k] + periphery_artery_right_offset)]
        basal_plate_vessel_positions[k, 1] = calculate_vessel_position(artery_limited_range[0], artery_limited_range[1])

        # 2nd: Calculate vein position.
        vein_limited_range                 = [0 + vein_padding/placentone_widths[k], basal_plate_vessel_positions[k, 1] - (artery_padding/placentone_widths[k] + vein_padding/placentone_widths[k])]
        basal_plate_vessel_positions[k, 0] = calculate_vessel_position(vein_limited_range[0], vein_limited_range[1])
      case [1, 1, 1]:
        # 1st: Calculate artery position.
        artery_limited_range               = [0 + (periphery_artery_left_offset + artery_padding/placentone_widths[k] + 2*vein_padding/placentone_widths[k]), 1 - (artery_padding/placentone_widths[k] + 2*vein_padding/placentone_widths[k] + periphery_artery_right_offset)]
        basal_plate_vessel_positions[k, 1] = calculate_vessel_position(artery_limited_range[0], artery_limited_range[1])

        # 2nd: Calculate left vein position.
        vein_limited_range                 = [0 + vein_padding/placentone_widths[k], basal_plate_vessel_positions[k, 1] - (artery_padding/placentone_widths[k] + vein_padding/placentone_widths[k])]
        basal_plate_vessel_positions[k, 0] = calculate_vessel_position(vein_limited_range[0], vein_limited_range[1])

        # 3rd: Calculate right vein position.
        vein_limited_range                 = [basal_plate_vessel_positions[k, 1] + artery_padding/placentone_widths[k] + vein_padding/placentone_widths[k], 1 - vein_padding/placentone_widths[k]]
        basal_plate_vessel_positions[k, 2] = calculate_vessel_position(vein_limited_range[0], vein_limited_range[1])

  return basal_plate_vessel_positions.tolist(), septal_wall_vein_positions.tolist()