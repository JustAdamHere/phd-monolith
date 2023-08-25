####################
# SIMULATION SETUP #
####################
# Nominal values of parameters.
artery_location_nominal   = 0.5
vein_location_1_nominal   = 0.2
vein_location_2_nominal   = 0.8

# Geometry measurements.
central_cavity_nominal            = 0.25 # 10mm
central_cavity_transition_nominal = 0.04 # 1.6mm
pipe_transition_nominal           = 0.03 # 1.2mm
artery_width_nominal              = 0.06 # 2.4mm
wall_height_ratio_nominal         = 1.0

# Mesh.
mesh_resolution_default = 0.1

# Unused.
log_cavity_transition = False
artery_length_nominal = 0.25   # 10mm

# Problem parameters.
L   = 0.04     # m
U   = 0.35     # m/s
k   = 1e-8     # m^2
mu  = 4e-3     # Pa s
rho = 1e3      # kg/m^3
D   = 1.667e-9 # m^2/s
R   = 1.667e-2 # m^2/s

# Run type.
run_type = 'openmp'

##################
# SIMULATION RUN #
##################
# Clean and compile.
from programs import velocity_transport
velocity_transport.setup(clean=True, terminal_output=True, compile=False, programs_to_compile='nsb-transport_placenta', run_type=run_type)

import matplotlib.pyplot as plt
import numpy as np

# Sampling parameters.
min_value     = 0.13
max_value     = 0.28
range_value   = max_value - min_value
no_samples    = 10
no_subsamples = 20
variance      = range_value/(7*no_samples) # Gives +-3 variance with padding of 1x variance. #0.03
parameter_nominal = central_cavity_nominal
parameter_name = "central_cavity_width"

#############################
# VARY CENTRAL CAVITY WIDTH #
#############################
import psutil
from miscellaneous import select_no_threads

# Run simulations.
no_threads = 30
run_no = 0
ε = 0.001
parameter_means = np.linspace(min_value, max_value, no_samples)
print(f"Varying wall height ratio mean between {parameter_means[0]} and {parameter_means[-1]}.")

integral = []
parameters = []
for i in range(0, no_samples):
  parameter_mean = parameter_means[i]

  for j in range(0, no_subsamples):
    success = False
    while not success:
      central_cavity_width = np.random.normal(parameter_mean, variance)

      no_threads = select_no_threads.select_no_threads(no_threads, psutil.getloadavg()[1], 40, 8)

      success = velocity_transport.run(run_no, "nsb", "placenta", artery_location_nominal, vein_location_1_nominal, vein_location_2_nominal, central_cavity_width, central_cavity_transition_nominal, pipe_transition_nominal, artery_length_nominal, mesh_resolution_default, log_cavity_transition, L, U, mu, rho, k, D, R, terminal_output=True, verbose_output=False, velocity_oscillation_tolerance=1e-4, transport_oscillation_tolerance=1e-1, plot=False, rerun_on_oscillation=False, error_on_fail=False, no_time_steps=0, final_time=0.0, normal_vessels=[[1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1]], marginal_sinus=[1, 1], no_threads=no_threads, no_placentones=6, run_type=run_type, no_reynold_ramp_steps=5, reynold_ramp_start_ratio=0.5, reynold_ramp_step_base=2, artery_width=artery_width_nominal, wall_height_ratio=1.0, extra_text=f"central_cavity_width: {central_cavity_width}, no_threads: {no_threads}")
    parameters.append(central_cavity_width)
    integral.append(velocity_transport.integral_cache[-1])
    run_no += 1

# from miscellaneous import get_transport_reaction_integral

# for i in range(0, no_samples):
#   for j in range(0, no_subsamples):
#     run_no = i*no_subsamples+j
#     aptofem_run_no = run_no + 1
#     reaction_integral = get_transport_reaction_integral.get_transport_reaction_integral('velocity-transport', 'placenta', aptofem_run_no)
#     integral.append(reaction_integral)

# integral = [0.00101311, 0.00102349, 0.00102263, 0.00101165, 0.00101737, 0.00101804,
#  0.00101703, 0.00101536, 0.00101367, 0.00101299, 0.00101406, 0.00101535,
#  0.00101712, 0.00101544, 0.00101463, 0.00101291, 0.00102031, 0.00101541,
#  0.00101059, 0.00101403, 0.00100657, 0.00100706, 0.00100672, 0.00100461,
#  0.00100717, 0.00100759, 0.00100674, 0.00100774, 0.00100463, 0.00100583,
#  0.00100502, 0.00100806, 0.00100541, 0.00100832, 0.00100382, 0.00100675,
#  0.00100798, 0.00100763, 0.00100628, 0.00100816, 0.00099907, 0.00100115,
#  0.00099812, 0.00099873, 0.00099916, 0.00100292, 0.00099762, 0.00099711,
#  0.00100053, 0.00100275, 0.00099763, 0.00100058, 0.00099762, 0.00100045,
#  0.00100009, 0.00100499, 0.00099769, 0.00099901, 0.00100216, 0.00099988,
#  0.00098835, 0.00099662, 0.00098958, 0.00098806, 0.00099804, 0.00099059,
#  0.00099809, 0.00099676, 0.00099702, 0.00099876, 0.0009963,  0.00099831,
#  0.00099999, 0.00099817, 0.00099875, 0.00099541, 0.0009906,  0.00098956,
#  0.00099482, 0.00099641, 0.00098849, 0.0009875,  0.00098579, 0.00098549,
#  0.00098821, 0.00098309, 0.00098754, 0.00098991, 0.00098843, 0.00098739,
#  0.00098652, 0.00098575, 0.00098968, 0.00098909, 0.00098679, 0.00098577,
#  0.00098503, 0.00098847, 0.00098676, 0.00098669, 0.00097681, 0.00097965,
#  0.00098085, 0.00097948, 0.00098094, 0.00098114, 0.00098049, 0.00097965,
#  0.00098112, 0.00097989, 0.00098082, 0.00097782, 0.00098006, 0.00098112,
#  0.00098087, 0.00098222, 0.00097996, 0.0009808,  0.00097765, 0.00098063,
#  0.00097558, 0.00097285, 0.00097546, 0.00097462, 0.00097391, 0.00097597,
#  0.00098105, 0.00097464, 0.00098113, 0.00098137, 0.00097403, 0.0009824,
#  0.00097539, 0.00097652, 0.0009766,  0.0009811,  0.00097605, 0.00097486,
#  0.00098157, 0.00098065, 0.00097687, 0.00098369, 0.00097439, 0.00097675,
#  0.00097755, 0.0009732,  0.00097558, 0.00098185, 0.00097316, 0.00097743,
#  0.00097848, 0.00097748, 0.0009745,  0.00097425, 0.00097705, 0.00097491,
#  0.00097793, 0.0009738,  0.00097793, 0.0009754,  0.00097707, 0.00097539,
#  0.00097719, 0.00097525, 0.0009769,  0.00097705, 0.00097792, 0.00097663,
#  0.00097671, 0.00097839, 0.00098045, 0.00097771, 0.00097782, 0.00097792,
#  0.00097806, 0.00097809, 0.00098029, 0.00097839, 0.00097772, 0.00097594,
#  0.00097528, 0.00097547, 0.00097771, 0.00097758, 0.00097383, 0.0009787,
#  0.00097903, 0.00097469, 0.00097793, 0.00097872, 0.00097838, 0.00098002,
#  0.00097675, 0.00097575, 0.00097628, 0.00097792, 0.00097986, 0.00097486,
#  0.00097783, 0.00097547]
# wall_height_ratios = [0.1310372119716954, 0.07658644140020801, 0.07369623540746419, 0.17503608150059385, 0.11689463582346664, 0.0660401226774961, 0.13707479829655367, 0.1122408970455464, 0.12735176862956693, 0.09820206333073074, 0.0990658803338598, 0.10254673706608149, 0.06567088740199273, 0.11460617159093246, 0.05459123900610445, 0.11015715350997184, 0.08041205879724606, 0.11820516180127165, 0.01640712928920235, 0.11054013208359958, 0.3336446023412086, 0.31574452897458405, 0.3162759531294226, 0.3303041995227989, 0.35900620223136065, 0.3103582615506614, 0.3212230916300735, 0.3389371828857192, 0.3239840267712308, 0.3551948885203993, 0.35944364012780927, 0.31961856815143974, 0.38369627715056964, 0.28955470782075277, 0.3292029425299967, 0.3411613442461517, 0.2689034841538933, 0.3102797843745428, 0.35684620577210474, 0.31200471446597206, 0.5599740846573238, 0.5118796473604333, 0.5760347536513567, 0.6072117206175018, 0.5893105133290808, 0.5382702018437504, 0.5933602001475321, 0.6145105154776123, 0.5424700379162738, 0.5154102630506323, 0.5078467167406274, 0.5545544509072508, 0.5080778316930941, 0.5466281044391444, 0.5533455322172622, 0.5355762077223953, 0.5782960292653605, 0.5751562867854642, 0.5262166126229079, 0.5739397442316712, 0.8629925049201732, 0.7696073067645958, 0.8310007742092455, 0.8391206885922327, 0.8179479908509472, 0.8285050412040221, 0.819429800744068, 0.7859413094091359, 0.8116070529069271, 0.7742770479407028, 0.7924925672047544, 0.8212400212649987, 0.7409600237744697, 0.7780990236039717, 0.7439122774315722, 0.7620853515502528, 0.8289458049118335, 0.8546248877357584, 0.8056613440851094, 0.7842877482990911, 1.0523156243890055, 1.0309713009537484, 1.0933865306886534, 1.029628412766607, 0.989018663862586, 1.1086993959298914, 1.0530196316802003, 1.049195494482243, 1.0516147616465732, 1.055838682065931, 1.0051359446491241, 1.0416036334625274, 1.0501616242609284, 1.0188101628110136, 1.0472897519145856, 1.0116835396887343, 1.0129866743903935, 1.0519971775980304, 1.0876032887292975, 1.0456620688912908, 1.2846726892834632, 1.2591230127826993, 1.274261946614633, 1.260491996116842, 1.2490526574589536, 1.2561243787635588, 1.2268835806168479, 1.2643004725899585, 1.2730914363855046, 1.2918215804681008, 1.330796282648074, 1.2880595823703105, 1.2564979923536923, 1.2729470060735755, 1.2543391494630272, 1.3236077985821173, 1.3132343521051244, 1.239435225234331, 1.2802998240360792, 1.2765842022558096, 1.4827090713768476, 1.4519398607055405, 1.4713631024598122, 1.4938968568074653, 1.490019912560853, 1.5200014972110978, 1.5409104062324894, 1.4938703416709767, 1.5428398531235514, 1.5273760314625946, 1.4888457041216743, 1.5365071023415204, 1.4697395521629069, 1.5067624852465475, 1.474391117686159, 1.5260958432987308, 1.4583691003909451, 1.5010590894421765, 1.5414235144006934, 1.5251929562023283, 1.7420834477243081, 1.7687829235879604, 1.7624287660319822, 1.737592997800935, 1.7187746999413305, 1.6730058576520055, 1.6883349336886448, 1.7750905176224936, 1.6704220084241153, 1.7196536049435927, 1.743009901988125, 1.7306209154347414, 1.7618872237350736, 1.8228491885388607, 1.7369030628453903, 1.679855159495565, 1.7147916692221716, 1.666532298048291, 1.7143935060003699, 1.7453724860979118, 1.9914902932344762, 1.9513114601114594, 1.91498736531325, 1.9505977660238247, 1.8963815176177123, 1.901695823486855, 1.9846049547275804, 2.0104514363927177, 1.9331410483552058, 1.9840016812636225, 1.9937489375314092, 1.9830161368710542, 1.9843066563050782, 1.9808822436956344, 1.9423615337252182, 1.9986556612415887, 1.9653379429321192, 1.916082860251242, 1.9924336537722627, 1.9893318057979565, 2.164733759034071, 2.149319512470553, 2.255040242772517, 2.1991871891958623, 2.1866092431441437, 2.2423730695499016, 2.2053470625406573, 2.1699337478348237, 2.200587629713752, 2.213728617023617, 2.2643387959571677, 2.245936312484145, 2.1922483135141575, 2.1636011176681307, 2.1673243135152944, 2.146282365415912, 2.2458089590861827, 2.1910271515871336, 2.1948242728726894, 2.1790394340258943]

integral = np.array(integral)
integral_average = integral.reshape([no_samples, no_subsamples]).mean(axis=1)

cmap = plt.get_cmap('tab10')

import scipy.stats as stats

# Plot.
plt.plot(parameter_means, integral_average, '--', color='k')
for i in range(0, no_samples):
  plt.boxplot(integral[i*no_subsamples:(i+1)*no_subsamples], positions=[parameter_means[i]], widths=6*variance, labels=[f'{parameter_means[i]:.2f}'])

  # Plot normal distribution on each mean.
  normal_x = np.linspace(parameter_means[i] - 3*variance, parameter_means[i] + 3*variance, 100)
  plt.plot(normal_x, 0.1*(integral_average.max()-integral_average.min())*stats.norm.pdf(normal_x, parameter_means[i], variance)/stats.norm.pdf(parameter_means[i], parameter_means[i], variance) + integral_average.min() - 0.2*(integral_average.max() - integral_average.min()), color='k', alpha=0.5)
  plt.scatter(parameters[i*no_subsamples:(i+1)*no_subsamples], 0.1*(integral_average.max()-integral_average.min())*stats.norm.pdf(parameters[i*no_subsamples:(i+1)*no_subsamples], parameter_means[i], variance)/stats.norm.pdf(parameter_means[i], parameter_means[i], variance) + integral_average.min() - 0.2*(integral_average.max() - integral_average.min()), color='k', s=0.1)
#plt.vlines(parameter_nominal, 0, 0.1, color='k', linestyle='-')
plt.xlabel(f"{parameter_name}")
plt.ylabel("Integral")
plt.title(f"Varying {parameter_name}")
plt.xlim([min_value - 4*variance, max_value + 4*variance])
#plt.ylim([0.0003, 0.0013])
plt.savefig(f"./images/vary_{parameter_name}.png", dpi=300)

# Output measured quantities.
from miscellaneous import output
output.output("##########################", True)
# output.output(f"Fluxes: {velocity_transport.flux_cache}", True)
output.output(f"Integrals: {integral}", True)
output.output(f"parameters: {parameters}", True)

# Save output.
output.save()