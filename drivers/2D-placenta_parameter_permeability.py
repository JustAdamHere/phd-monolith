####################
# SIMULATION SETUP #
####################
# Nominal values of parameters.
artery_location_nominal   = 0.5
vein_location_1_nominal   = 0.2
vein_location_2_nominal   = 0.8

# Geometry measurements.
central_cavity_nominal            = 0.25   # 10mm
central_cavity_transition_nominal = 0.05   # 2mm
pipe_transition_nominal           = 0.03   # 2mm
artery_length_nominal             = 0.05   # 2mm
artery_width_nominal              = 0.0625 # 2.5mm

# Mesh.
mesh_resolution_default = 0.15

# Unused.
log_cavity_transition = False

# Problem parameters.
L   = 0.04     # m
U   = 0.1 # m/s
k   = 1e-8     # m^2
mu  = 4e-3     # Pa s
rho = 1e3      # kg/m^3
D   = 1.667e-9 # m^2/s
R   = 1.667e-2 # m^2/s

##################
# SIMULATION RUN #
##################
# Clean and compile.
from programs import velocity_transport
# velocity_transport.setup(clean=True, terminal_output=True, compile=False, programs_to_compile='nsb-transport_placenta')
run_no = 0

import matplotlib.pyplot as plt
import numpy as np

# Sampling parameters.
no_samples    = 10
no_subsamples = 20
variance      = 0.05

#############################
# VARY CENTRAL CAVITY WIDTH #
#############################
# Run simulations.
ε = 0.001
# central_cavity_width_means = np.linspace(artery_width_nominal + central_cavity_transition_nominal + variance + ε, 0.3, no_samples)
permeability_means = np.linspace(-6, -10, no_samples)
print(f"Varying permeability mean between 10^{permeability_means[0]} and 10^{permeability_means[-1]}.")

integral = []
permeabilities = []
# for i in range(0, no_samples):
#     permeability_mean = permeability_means[i]

#     for j in range(0, no_subsamples):
#         success = False
#         while not success:
#           permeability = np.random.normal(permeability_mean, variance)

#           success = velocity_transport.run(run_no, "nsb", "placenta", artery_location_nominal, vein_location_1_nominal, vein_location_2_nominal, central_cavity_nominal, central_cavity_transition_nominal, pipe_transition_nominal, artery_length_nominal, mesh_resolution_default, log_cavity_transition, L, U, mu, rho, 10**permeability, D, R, terminal_output=True, verbose_output=False, velocity_oscillation_tolerance=1e-4, transport_oscillation_tolerance=1e-1, plot=False, rerun_on_oscillation=False, normal_vessels=[[1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1]], error_on_fail=False, extra_text=f"Permeability: 10^{permeability}")
#         permeabilities.append(permeability)
#         integral.append(velocity_transport.integral_cache[-1])
#         run_no += 1

# from miscellaneous import get_transport_reaction_integral

# for i in range(0, no_samples):
#   for j in range(0, no_subsamples):
#     run_no = i*no_subsamples+j
#     aptofem_run_no = run_no + 1
#     reaction_integral = get_transport_reaction_integral.get_transport_reaction_integral('velocity-transport', 'placenta', aptofem_run_no)
#     integral.append(reaction_integral)

integral = [0.00120092, 0.00119808, 0.00120912, 0.00119206, 0.00120541, 0.0012123,
 0.00119618, 0.00122264, 0.00120549, 0.00120754, 0.00120933, 0.00121932,
 0.00120612, 0.00119242, 0.00119706, 0.00119036, 0.00120311, 0.00120194,
 0.00119896, 0.00118485, 0.00110338, 0.00109968, 0.0011081,  0.00109889,
 0.00109035, 0.00109485, 0.00112231, 0.00108942, 0.00109637, 0.00109939,
 0.001099,   0.0010988,  0.00109913, 0.00111418, 0.0010985,  0.00110168,
 0.00108476, 0.00110935, 0.00108715, 0.00111618, 0.00104827, 0.00103685,
 0.00104507, 0.00104293, 0.00103237, 0.00103661, 0.00103888, 0.00104321,
 0.00104314, 0.00103636, 0.0010395,  0.00104446, 0.00104336, 0.00104242,
 0.00103456, 0.0010478,  0.00103843, 0.00103669, 0.00104046, 0.00103794,
 0.00100764, 0.00100894, 0.00101502, 0.0010053,  0.00100821, 0.00101247,
 0.00100743, 0.00100878, 0.00100814, 0.00100732, 0.00101074, 0.00101119,
 0.00100421, 0.00100445, 0.00100842, 0.0010088,  0.00100872, 0.00100967,
 0.00100883, 0.00100567, 0.00099044, 0.00099401, 0.00099064, 0.00099438,
 0.00099091, 0.00099252, 0.00098985, 0.00098625, 0.00099182, 0.00099208,
 0.00099478, 0.00099082, 0.00099424, 0.00098889, 0.00099014, 0.00099127,
 0.0009877,  0.0009867,  0.00098718, 0.00098915, 0.00097184, 0.00096485,
 0.00096635, 0.00096897, 0.00096915, 0.00097127, 0.00097106, 0.00096892,
 0.00096467, 0.00096915, 0.00096642, 0.00096503, 0.00096799, 0.00097171,
 0.00096823, 0.00096874, 0.00096529, 0.00097025, 0.00097047, 0.00096691,
 0.00091945, 0.00091907, 0.00091649, 0.0009015,  0.00090462, 0.00092418,
 0.00091722, 0.00090259, 0.00090973, 0.0009199,  0.00091089, 0.00091748,
 0.00092385, 0.00091312, 0.00091692, 0.00091548, 0.00091583, 0.00092177,
 0.00092953, 0.00089901, 0.00078163, 0.00081505, 0.00079951, 0.00078525,
 0.00077812, 0.00081788, 0.00080322, 0.000797,   0.00084554, 0.00081643,
 0.00079167, 0.00080701, 0.00081537, 0.00083652, 0.00080625, 0.00078608,
 0.00078928, 0.00083658, 0.00081083, 0.00079444, 0.00059091, 0.00061198,
 0.00062227, 0.00059763, 0.00062933, 0.00057732, 0.00058931, 0.0006305,
 0.00062329, 0.00062756, 0.00060522, 0.00061793, 0.00056128, 0.00059324,
 0.00058923, 0.00061834, 0.00059782, 0.00061096, 0.00059762, 0.00057723,
 0.00037506, 0.00041324, 0.00036814, 0.00036781, 0.00035416, 0.00036434,
 0.00033568, 0.00035439, 0.00038349, 0.00034631, 0.00033156, 0.00035324,
 0.00035606, 0.00038375, 0.00037627, 0.00033937, 0.00039234, 0.00037161,
 0.00033505, 0.0003817, ]
permeabilities = [-5.9983821402538275, -6.009939494038544, -5.9653029371221775, -6.034509147676609, -5.980271820315127, -5.95249649796329, -6.01767725821581, -5.911065371267589, -5.979923947485941, -5.971660462476332, -5.964477177113188, -5.924338117077625, -5.977392765100922, -6.032994080585471, -6.01408925795297, -6.041454055542014, -5.98952958638197, -5.994261460185095, -6.0063584899320634, -6.064155066817351, -6.438799132036752, -6.458934983424328, -6.4137954485993385, -6.463286019988092, -6.511772651341749, -6.485894555160606, -6.341818468807582, -6.517214785301868, -6.477309799866443, -6.460535553058743, -6.4626916958665985, -6.463798517210623, -6.461997131294428, -6.38243545405783, -6.465471303216886, -6.448005249452488, -6.545042638110892, -6.407287169489323, -6.530691599535073, -6.3722618133213205, -6.809117314220447, -6.91942079325695, -6.838082739926657, -6.858229174184404, -6.96875576676023, -6.9220172159489035, -6.898344190086138, -6.855571411698066, -6.856253014594515, -6.924629996210513, -6.891988391638388, -6.843721061358841, -6.854122066127618, -6.863148642997673, -6.944125534329992, -6.8132793587703455, -6.902960560317875, -6.921144095552459, -6.882391456608047, -6.907967704056142, -7.350407152484534, -7.323596866786431, -7.21051216432707, -7.400932369737569, -7.338521659263858, -7.255704020147659, -7.354791744997884, -7.326801830528877, -7.340010580726043, -7.356966223698921, -7.2880641005243705, -7.279562621427533, -7.4256507270189465, -7.420230391619853, -7.334142841483981, -7.326341299996314, -7.328065063306264, -7.308971956667789, -7.325801577791005, -7.39265887405253, -7.778208564765708, -7.684007675621313, -7.772907079515001, -7.674265616026784, -7.765894802286859, -7.723652619466993, -7.79320951769143, -7.882702308246779, -7.742143923470857, -7.735265374201357, -7.6633886887089, -7.768190297724101, -7.6780442207797455, -7.817814405049561, -7.785766429499475, -7.756679560351459, -7.847599607897795, -7.871866133592804, -7.860317580734544, -7.8112566190296375, -8.164439837155841, -8.264081037584289, -8.244149167728693, -8.207548031669063, -8.20499731376311, -8.173272161173742, -8.176604563186597, -8.208305979108655, -8.26637638851537, -8.204978862540916, -8.243258012479808, -8.261742041679792, -8.221595107282713, -8.166586772567364, -8.218139004695015, -8.210881126940365, -8.258305675666541, -8.18883728678329, -8.185612783517213, -8.236643235418546, -8.655636199839384, -8.657964844830792, -8.673289633655553, -8.75495027536948, -8.73892781188316, -8.626118919675944, -8.669013592299194, -8.749412868369891, -8.711633823369455, -8.652911255690368, -8.70524482003708, -8.667464406116041, -8.628261787924135, -8.692741513797106, -8.670755333859997, -8.679203659234743, -8.677170715227978, -8.641348652130812, -8.590671777678459, -8.767459433588703, -9.1784757868164, -9.084521997357946, -9.129666456902019, -9.168838248213818, -9.18770578028804, -9.07600420111972, -9.119129488014861, -9.136704208934125, -8.986684801688503, -9.080389837068314, -9.151443951957368, -9.1082368127216, -9.08356231628463, -9.017179908806316, -9.11041584263413, -9.166617812699911, -9.157966516523793, -9.016976569489803, -9.09705865000699, -9.143807447403292, -9.58843777830116, -9.54891053541856, -9.52927161991058, -9.575914869718265, -9.515682374759253, -9.613534549217205, -9.591410336602282, -9.513397846265836, -9.527303970216764, -9.51909061605255, -9.561671181734543, -9.537582391030888, -9.642835797315009, -9.584098697199876, -9.5915603326433, -9.53680660743788, -9.575552804173851, -9.550838380972166, -9.575931171863578, -9.613711210961762, -9.974566757703784, -9.90581244800249, -9.987224873716249, -9.987842691504541, -10.012982874883988, -9.994220413176985, -10.04759341917965, -10.012579345966572, -9.959252923221046, -10.027604773460814, -10.055379838759846, -10.014692051886373, -10.009490486116503, -9.958780548666857, -9.972373036369348, -10.04062553489008, -9.943246120433159, -9.980881929760308, -10.0487897191476, -9.96247861946192]

integral = np.array(integral)
integral_average = integral.reshape([no_samples, no_subsamples]).mean(axis=1)

cmap = plt.get_cmap('tab10')

import scipy.stats as stats

# Plot.
plt.plot(permeability_means, integral_average, '--', color='k')
for i in range(0, no_samples):
  plt.boxplot(integral[i*no_subsamples:(i+1)*no_subsamples], positions=[permeability_means[i]], widths=0.2, labels=[f'{permeability_means[i]:.2f}'])

  # Plot normal distribution on each mean.
  # normal_x = np.linspace(permeability_means[i] - 3*variance, permeability_means[i] + 3*variance, 100)
  # plt.plot(normal_x, 0.1*(integral_average.max()-integral_average.min())*stats.norm.pdf(normal_x, permeability_means[i], variance)/stats.norm.pdf(permeability_means[i], permeability_means[i], variance) + integral_average.min() - 0.2*(integral_average.max() - integral_average.min()), color='k', alpha=0.5)
  # plt.scatter(permeabilities[i*no_subsamples:(i+1)*no_subsamples], 0.1*(integral_average.max()-integral_average.min())*stats.norm.pdf(permeabilities[i*no_subsamples:(i+1)*no_subsamples], permeability_means[i], variance)/stats.norm.pdf(permeability_means[i], permeability_means[i], variance) + integral_average.min() - 0.2*(integral_average.max() - integral_average.min()), color='k', s=0.1)
plt.vlines(-8, 0.0003, 0.0013, color='k', linestyle='-')
plt.xlabel("Permeability (log)")
plt.ylabel("Integral")
plt.title("Varying permeability")
plt.ylim([0.0003, 0.0013])
plt.savefig("./images/vary_permeability_fixed-y.png", dpi=300)

########################################
# VARY CENTRAL CAVITY TRANSITION WIDTH #
########################################

# Vary permeability.

# Vary artery width.

# Vary vein width.

# Vary number of arteries.

# Vary number of veins (less).

# Vary number of veins (more).






# Output measured quantities.
from miscellaneous import output
output.output("##########################", True)
# output.output(f"Fluxes: {velocity_transport.flux_cache}", True)
output.output(f"Integrals: {integral}", True)
output.output(f"Permeabilities: {permeabilities}", True)

# Save output.
output.save()