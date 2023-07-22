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
mesh_resolution_default = 0.05

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
velocity_transport.setup(clean=True, terminal_output=True, compile=True, programs_to_compile='nsb-transport_placenta')
run_no = 0

import matplotlib.pyplot as plt
import numpy as np

# Sampling parameters.
no_samples    = 10
no_subsamples = 3
variance      = 0.01

#############################
# VARY CENTRAL CAVITY WIDTH #
#############################
# Run simulations.
ε = 0.001
# central_cavity_width_means = np.linspace((artery_width_nominal + central_cavity_transition_nominal)/2 + 3*variance, 0.3 - central_cavity_transition_nominal/ - 3*variance, no_samples)
central_cavity_width_means = np.linspace(artery_width_nominal + central_cavity_transition_nominal + variance + ε, 0.3, no_samples)
print(f"Varying cavity width mean between {central_cavity_width_means[0]} and {central_cavity_width_means[-1]}.")

integral = []
central_cavity_widths = []
for i in range(0, no_samples):
    central_cavity_width_mean = central_cavity_width_means[i]

    for j in range(0, no_subsamples):
        success = False
        while not success:
          central_cavity_width = np.random.uniform(central_cavity_width_mean - variance, central_cavity_width_mean + variance)

          success = velocity_transport.run(run_no, "nsb", "placenta", artery_location_nominal, vein_location_1_nominal, vein_location_2_nominal, central_cavity_width, central_cavity_transition_nominal, pipe_transition_nominal, artery_length_nominal, mesh_resolution_default, log_cavity_transition, L, U, mu, rho, k, D, R, terminal_output=True, verbose_output=False, velocity_oscillation_tolerance=1e-4, transport_oscillation_tolerance=1e-1, plot=False, rerun_on_oscillation=False, normal_vessels=[[1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1]], error_on_fail=False, extra_text=f"Central cavity width: {central_cavity_width}")
        run_no += 1
        central_cavity_widths.append(central_cavity_width)

    integral.append(np.average(velocity_transport.integral_cache[run_no-no_subsamples:run_no]))

# Plot.
plt.plot(central_cavity_width_means, integral, 'x-', color='blue')
plt.plot(central_cavity_widths, velocity_transport.integral_cache[0:no_samples*no_subsamples], 'x', color='blue', alpha=0.5)
# for i in range(0, no_samples):
#   for j in range(0, no_subsamples):
#     plt.plot(central_cavity_widths, velocity_transport.integral_cache[i*no_subsamples+j], 'x', color='blue', alpha=0.5)
plt.xlabel("Central cavity width mean")
plt.ylabel("Integral")
plt.ylim([0, 1.1*max(velocity_transport.integral_cache[0:no_samples*no_subsamples])])
plt.savefig("./images/vary_central_cavity_width.png")

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
output.output(f"Fluxes: {velocity_transport.flux_cache}", True)
output.output(f"Integrals: {velocity_transport.integral_cache}", True)
output.output(f"Central cavity widths: {central_cavity_widths}", True)

# Save output.
output.save()