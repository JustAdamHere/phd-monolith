class class_run_data:
  def __init__(self, sim_no):
    self.sim_no = sim_no

    self.read_data()

  def read_data(self):
    from miscellaneous import get_transport_reaction_integral, get_velocity_magnitude, get_run_data, parameters_io

    self.parameters                    = parameters_io.load_parameters("velocity-transport", "placenta", self.sim_no)

    U = self.parameters["scaling_U"]
    C = 7.3 # mol/m^3 [Serov, 2015]
    L = self.parameters["scaling_L"]
    R = self.parameters["scaling_R"]

    vmi                                         = get_velocity_magnitude.get_velocity_magnitude_integral("velocity-transport", "placenta", self.sim_no)
    self.velocity_magnitude_integral_ivs        = vmi[0]
    self.velocity_magnitude_integral_everywhere = vmi[1]
    self.transport_reaction_integral            = get_transport_reaction_integral.get_transport_reaction_integral("velocity-transport", "placenta", self.sim_no)
    svp                                         = get_velocity_magnitude.get_slow_velocity_percentage("dg_velocity-transport", self.sim_no)
    self.slow_velocity_percentage_ivs           = svp[0]
    self.slow_velocity_percentage_everywhere    = svp[1]
    # self.slow_velocity_percentage_dellschaft    = get_velocity_magnitude.get_slow_velocity_percentage   ("dg_velocity-transport", self.sim_no, U, 0.0005**2)[1]
    # self.fast_velocity_percentage_dellschaft    = get_velocity_magnitude.get_slow_velocity_percentage   ("dg_velocity-transport", self.sim_no, U, 0.001**2,  False)[1]
    av                                          = get_velocity_magnitude.get_average_velocity("dg_velocity-transport", self.sim_no)
    self.average_velocity_ivs                   = av[0]
    self.average_velocity_everywhere            = av[1]
    self.run_data                               = get_run_data.get_run_data("velocity-transport", "placenta", self.sim_no, 0)

    self.flux                                   = self.get_file_contents("flux_velocity-transport_placenta")

    # print(f"\nAverage velocity: {self.average_velocity_ivs}")
    # print(f"VMI IVS: {self.velocity_magnitude_integral_ivs}")
    # print(f"VMI everywhere: {self.velocity_magnitude_integral_everywhere}")
    # print(f"SVP IVS: {self.slow_velocity_percentage_ivs}")
    # print(f"SVP everywhere: {self.slow_velocity_percentage_everywhere}")
    # print()
    
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
  
  def get_no_arteries(self):
    import copy, numpy as np
    
    # Calculate number of arteries.
    basal_plate_arteries = copy.deepcopy(self.parameters["basal_plate_vessels"])
    for j in range(0, self.parameters["no_placentones"]):
      del basal_plate_arteries[j][2]
      del basal_plate_arteries[j][0]

    no_arteries = int(np.count_nonzero(basal_plate_arteries))

    return no_arteries
  
def import_simulations(max_run_no):
  simulations = []
  for run_no in range(1, max_run_no+1):
    print(f"\rImporting simulation {run_no}/{max_run_no}...", end="")
    simulations.append(class_run_data(run_no))
  print(f"\rImporting simulation {max_run_no}/{max_run_no}... Done.", end="\r\n")

  return simulations