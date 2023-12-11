class class_run_data:
  def __init__(self, sim_no):
    self.sim_no = sim_no

    self.read_data()

  def read_data(self):
    from miscellaneous import get_transport_reaction_integral, get_velocity_magnitude, get_run_data, parameters_io, get_flux

    self.parameters                    = parameters_io.load_parameters("velocity-transport", "placenta", self.sim_no)

    U = self.parameters["scaling_U"]
    C = 7.3 # mol/m^3 [Serov, 2015]
    L = self.parameters["scaling_L"]
    R = self.parameters["scaling_R"]

    vmi                                         = get_velocity_magnitude.get_velocity_magnitude_integral("velocity-transport", "placenta", self.sim_no)
    self.velocity_magnitude_integral_ivs        = U*vmi[0]
    self.velocity_magnitude_integral_everywhere = U*vmi[1]
    self.transport_reaction_integral            = C*get_transport_reaction_integral.get_transport_reaction_integral("velocity-transport", "placenta", self.sim_no)
    av                                          = get_velocity_magnitude.get_average_velocity("velocity-transport", "placenta", self.sim_no)
    self.average_velocity_ivs                   = U*av[0]
    self.average_velocity_everywhere            = U*av[1]
    # self.slow_velocity_percentage_ivs           = get_velocity_magnitude.get_slow_velocity_percentage("dg_velocity-transport", self.sim_no, self.average_velocity_ivs       , 520          )
    # self.slow_velocity_percentage_everywhere    = get_velocity_magnitude.get_slow_velocity_percentage("dg_velocity-transport", self.sim_no, self.average_velocity_everywhere, 500          )
    # self.slow_velocity_percentage_dellschaft    = get_velocity_magnitude.get_slow_velocity_percentage("dg_velocity-transport", self.sim_no, 0.0005                          , 500, U       )
    # self.fast_velocity_percentage_dellschaft    = get_velocity_magnitude.get_slow_velocity_percentage("dg_velocity-transport", self.sim_no, 0.001                           , 500, U, False)
    svp                                         = get_velocity_magnitude.get_slow_velocity_percentage("velocity-transport", "placenta", self.sim_no)
    self.slow_velocity_percentage_ivs           = svp[0]
    self.slow_velocity_percentage_everywhere    = svp[1]
    self.slow_velocity_percentage_dellschaft    = svp[2]
    self.fast_velocity_percentage_dellschaft    = svp[3]
    self.slow_velocity_perctange_nominal_ivs    = svp[4]
    self.slow_velocity_perctange_nominal_everywhere = svp[5]
    self.run_data                               = get_run_data.get_run_data("velocity-transport", "placenta", self.sim_no, 0)

    flux_data                                   = get_flux.get_flux("velocity-transport", "placenta", self.sim_no, self.parameters["no_placentones"])
    self.velocity_cross_flow_fluxes             = flux_data[2]
    self.velocity_inlet_fluxes                  = flux_data[3]
    self.velocity_bp_outlet_fluxes              = flux_data[4]
    self.velocity_sw_outlet_fluxes              = flux_data[5]
    self.velocity_ms_outlet_fluxes              = flux_data[6]
    self.sum_velocity_flux                      = flux_data[7]
    self.transport_cross_flow_fluxes            = flux_data[8]
    self.transport_inlet_fluxes                 = flux_data[9]
    self.transport_bp_outlet_fluxes             = flux_data[10]
    self.transport_sw_outlet_fluxes             = flux_data[11]
    self.transport_ms_outlet_fluxes             = flux_data[12]
    self.sum_transport_flux                     = flux_data[13]

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