class class_run_data:
  def __init__(self, sim_no):
    self.sim_no = sim_no

    self.read_data()

  def read_data(self):
    from miscellaneous import get_transport_reaction_integral, get_velocity_magnitude, get_run_data, parameters_io

    self.transport_reaction_integral = get_transport_reaction_integral.get_transport_reaction_integral("velocity-transport", "placenta", self.sim_no)
    self.velocity_magnitude_integral = get_velocity_magnitude.get_velocity_magnitude_integral("velocity-transport", "placenta", self.sim_no)
    self.run_data                    = get_run_data.get_run_data("velocity-transport", "placenta", self.sim_no, 0)
    self.parameters                  = parameters_io.load_parameters("velocity-transport", "placenta", self.sim_no)

    self.flux                        = self.get_file_contents("flux_velocity-transport_placenta")
    
  def get_file_contents(self, name, extension="dat"):
    file = open(f"./output/{name}_{self.sim_no}.{extension}", "r")
    lines = file.readlines()
    file.close()
    return lines
  
  def get_no_veins(self):
    import copy, numpy as np

    # Calculate number of veins.
    basal_plate_veins = copy.deepcopy(self.parameters["basal_plate_vessels"])
    for j in range(0, self.parameters["no_placentones"]):
      del basal_plate_veins[j][1]
    septal_wall_veins = self.parameters["septal_veins"]

    no_veins = int(np.count_nonzero(basal_plate_veins) + np.count_nonzero(septal_wall_veins))

    return no_veins
  
  def get_no_areries(self):
    import copy, numpy as np
    
    # Calculate number of arteries.
    basal_plate_arteries = copy.deepcopy(self.parameters["basal_plate_vessels"])
    for j in range(0, self.parameters["no_placentones"]):
      del basal_plate_arteries[j][2]
      del basal_plate_arteries[j][0]

    no_arteries = int(np.count_nonzero(basal_plate_arteries))

    return no_arteries