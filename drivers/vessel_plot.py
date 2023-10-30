from miscellaneous import run_data, run_no
import numpy as np
import copy

# Import all data from completed runs.
max_run_no  = run_no.get_completed_run_no()
simulations = []
for run_no in range(1, max_run_no+1):
  simulations.append(run_data.class_run_data(run_no))
  
# Varying parameters.
parameter_name      = "number of veins"
parameter_safe_name = "no_veins"
min_value           = 0
max_value           = 27
no_bins             = 28
parameter_values    = np.linspace(min_value, max_value, no_bins)

# Populate the bins.
simulation_bins = [[] for i in range(no_bins)]
for i in range(0, max_run_no):
  run_no = i+1

  no_veins    = simulations[i].get_no_veins()
  no_arteries = simulations[i].get_no_arteries()

  # Check that the number of arteries is 6.
  if (no_arteries == 6):
    simulation_bins[no_veins].append(run_no)

# Setup plots.
import matplotlib.pyplot as plt
fig1 = plt.figure(1)
fig2 = plt.figure(2)

transport_reaction_integral_plot = fig1.add_subplot(111)
velocity_magnitude_integral_plot = fig2.add_subplot(111)

# Get data to plot.
transport_reaction_integrals = [[] for i in range(no_bins)]
velocity_magnitude_integrals = [[] for i in range(no_bins)]
average_transport_reaction_integral = []
average_velocity_magnitude_integral = []
for i in range(0, no_bins):
  for j in range(0, len(simulation_bins[i])):
    run_no = simulation_bins[i][j]
    transport_reaction_integrals[i].append(simulations[run_no-1].transport_reaction_integral)
    velocity_magnitude_integrals[i].append(simulations[run_no-1].velocity_magnitude_integral)
  average_transport_reaction_integral.append(np.mean(transport_reaction_integrals[i]))
  average_velocity_magnitude_integral.append(np.mean(velocity_magnitude_integrals[i]))

# Plot the data.
transport_reaction_integral_plot.boxplot(transport_reaction_integrals, positions=parameter_values, widths=0.75)
velocity_magnitude_integral_plot.boxplot(velocity_magnitude_integrals, positions=parameter_values, widths=0.75)

# Plot the average.
transport_reaction_integral_plot.plot(parameter_values, average_transport_reaction_integral, 'k--')
velocity_magnitude_integral_plot.plot(parameter_values, average_velocity_magnitude_integral, 'k--')

# Style the transport reaction integral plot.
transport_reaction_integral_plot.xaxis.set_major_formatter(plt.FormatStrFormatter('%d'))
transport_reaction_integral_plot.xaxis.set_major_locator  (plt.MaxNLocator(10, integer=True, prune='both'))
transport_reaction_integral_plot.set_ylim(bottom=0)
transport_reaction_integral_plot.ticklabel_format(style="sci", axis='y', scilimits=(-3, -3))
transport_reaction_integral_plot.set_xlabel(f"{parameter_name}")
transport_reaction_integral_plot.set_ylabel("Transport reaction integral")
transport_reaction_integral_plot.set_title(f"Transport reaction integral against {parameter_name}")

# Style the velocity magnitude integral plot.
velocity_magnitude_integral_plot.xaxis.set_major_formatter(plt.FormatStrFormatter('%d'))
velocity_magnitude_integral_plot.xaxis.set_major_locator  (plt.MaxNLocator(10, integer=True, prune='both'))
velocity_magnitude_integral_plot.set_ylim(bottom=0)
velocity_magnitude_integral_plot.ticklabel_format(style="sci", axis='y', scilimits=(-2, -2))
velocity_magnitude_integral_plot.set_xlabel(f"{parameter_name}")
velocity_magnitude_integral_plot.set_ylabel("Velocity magnitude integral")
velocity_magnitude_integral_plot.set_title(f"Velocity magnitude integral against {parameter_name}")

# Save plots.
fig1.savefig(f"images/transport_reaction_integral_{parameter_safe_name}.png", dpi=300)
fig2.savefig(f"images/velocity_magnitude_integral_{parameter_safe_name}.png", dpi=300)

# Print the number of subsamples in each bin.
no_per_bin = [len(simulation_bins[i]) for i in range(0, no_bins)]
print(f"** NUMBER PER BIN **")
print(f"Mean:              {np.mean(no_per_bin)}")
print(f"Median:            {np.median(no_per_bin)}")
print(f"Sandard deviation: {np.std(no_per_bin):.2f}")
print(f"Minimum:           {np.min(no_per_bin)}")
print(f"Maximum:           {np.max(no_per_bin)}")
print(f"{no_per_bin}")