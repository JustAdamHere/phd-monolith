from miscellaneous import run_data, run_no
import numpy as np
import copy

# Import all data from completed runs.
max_run_no  = run_no.get_completed_run_no()
simulations = []
for run_no in range(1, max_run_no+1):
  print(f"\rImporting simulation {run_no}/{max_run_no}...", end="")
  simulations.append(run_data.class_run_data(run_no))
print(f"\rImporting simulation {max_run_no}/{max_run_no}... Done.", end="\r\n")
  
# Varying parameters.
parameter_name      = "ratio of arteries to veins"
parameter_safe_name = "ratio-of-arteries-to-veins"
min_value           = 0
max_value           = 6.0
no_bins             = 7
parameter_values    = np.linspace(min_value, max_value, no_bins)

# Populate the bins.
simulation_bins = [[] for i in range(no_bins)]
for i in range(0, max_run_no):
  run_no = i+1

  no_veins    = simulations[i].get_no_veins()
  no_arteries = simulations[i].get_no_arteries()

  if (no_veins == 0):
    continue

  ratio = float(no_arteries)/float(no_veins)

  bin_no = int(np.floor((no_bins-1)*(ratio - min_value)/(max_value - min_value)))
  simulation_bins[bin_no].append(run_no)

# Setup plots.
import matplotlib.pyplot as plt
fig1 = plt.figure(1)
fig2 = plt.figure(2)
fig3 = plt.figure(3)

transport_reaction_integral_plot = fig1.add_subplot(111)
velocity_magnitude_integral_plot = fig2.add_subplot(111)
slow_velocity_percentage_plot    = fig3.add_subplot(111)

# Get data to plot.
transport_reaction_integrals = [[] for i in range(no_bins)]
velocity_magnitude_integrals = [[] for i in range(no_bins)]
slow_velocity_percentages    = [[] for i in range(no_bins)]
average_transport_reaction_integral = []
average_velocity_magnitude_integral = []
average_slow_velocity_percentage    = []
for i in range(0, no_bins):
  for j in range(0, len(simulation_bins[i])):
    run_no = simulation_bins[i][j]
    transport_reaction_integrals[i].append(simulations[run_no-1].transport_reaction_integral)
    velocity_magnitude_integrals[i].append(simulations[run_no-1].velocity_magnitude_integral)
    slow_velocity_percentages   [i].append(simulations[run_no-1].slow_velocity_percentage)
  if (len(simulation_bins[i]) > 0):
    average_transport_reaction_integral.append(np.mean(transport_reaction_integrals[i]))
    average_velocity_magnitude_integral.append(np.mean(velocity_magnitude_integrals[i]))
    average_slow_velocity_percentage   .append(np.mean(slow_velocity_percentages   [i]))
  else:
    average_transport_reaction_integral.append(float('nan'))
    average_velocity_magnitude_integral.append(float('nan'))
    average_slow_velocity_percentage   .append(float('nan'))

# Plot the data.
transport_reaction_integral_plot.boxplot(transport_reaction_integrals, positions=parameter_values, widths=0.75)
velocity_magnitude_integral_plot.boxplot(velocity_magnitude_integrals, positions=parameter_values, widths=0.75)
slow_velocity_percentage_plot   .boxplot(slow_velocity_percentages,    positions=parameter_values, widths=0.75)

# Plot the average.
transport_reaction_integral_plot.plot(parameter_values, average_transport_reaction_integral, 'k--')
velocity_magnitude_integral_plot.plot(parameter_values, average_velocity_magnitude_integral, 'k--')
slow_velocity_percentage_plot   .plot(parameter_values, average_slow_velocity_percentage,    'k--')

# Style the transport reaction integral plot.
transport_reaction_integral_plot.xaxis.set_major_formatter(plt.FormatStrFormatter('%d'))
transport_reaction_integral_plot.xaxis.set_major_locator  (plt.MaxNLocator(10, integer=True, prune='both'))
transport_reaction_integral_plot.set_ylim(bottom=0)
transport_reaction_integral_plot.ticklabel_format(style="sci", axis='y', scilimits=(-3, -3))
transport_reaction_integral_plot.set_xlabel(f"{parameter_name}")
transport_reaction_integral_plot.set_ylabel("Transport reaction integral")
transport_reaction_integral_plot.set_title(f"Transport reaction integral\nagainst {parameter_name}")

# Style the velocity magnitude integral plot.
velocity_magnitude_integral_plot.xaxis.set_major_formatter(plt.FormatStrFormatter('%d'))
velocity_magnitude_integral_plot.xaxis.set_major_locator  (plt.MaxNLocator(10, integer=True, prune='both'))
velocity_magnitude_integral_plot.set_ylim(bottom=0)
velocity_magnitude_integral_plot.ticklabel_format(style="sci", axis='y', scilimits=(-2, -2))
velocity_magnitude_integral_plot.set_xlabel(f"{parameter_name}")
velocity_magnitude_integral_plot.set_ylabel("Velocity magnitude integral")
velocity_magnitude_integral_plot.set_title(f"Velocity magnitude integral\nagainst {parameter_name}")

# Style the slow velocity plot.
slow_velocity_percentage_plot.xaxis.set_major_formatter(plt.FormatStrFormatter('%d'))
slow_velocity_percentage_plot.xaxis.set_major_locator  (plt.MaxNLocator(10, integer=True, prune='both'))
slow_velocity_percentage_plot.set_ylim(bottom=0)
slow_velocity_percentage_plot.set_xlabel(f"{parameter_name}")
slow_velocity_percentage_plot.set_ylabel("Slow velocity percentage")
slow_velocity_percentage_plot.set_title(f"Slow velocity percentage\nagainst {parameter_name}")

# Save plots.
fig1.savefig(f"images/transport-reaction-integral_{parameter_safe_name}.png", dpi=300)
fig2.savefig(f"images/velocity-magnitude-integral_{parameter_safe_name}.png", dpi=300)
fig3.savefig(f"images/slow-velocity-percentage_{parameter_safe_name}.png",    dpi=300)

# Print the number of subsamples in each bin.
no_per_bin = [len(simulation_bins[i]) for i in range(0, no_bins)]
print(f"** NUMBER PER BIN **")
print(f"Mean:    {np.mean(no_per_bin)}")
print(f"Median:  {np.median(no_per_bin)}")
print(f"Std:     {np.std(no_per_bin):.2f}")
print(f"Minimum: {np.min(no_per_bin)}")
print(f"Maximum: {np.max(no_per_bin)}")
print(f"{no_per_bin}")