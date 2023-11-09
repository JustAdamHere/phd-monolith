from miscellaneous import run_data, run_no, output_timer
import numpy as np
import copy

# Import all data from completed runs.
max_run_no  = run_no.get_completed_run_no()
simulations = run_data.import_simulations(max_run_no)
  
# Varying parameters.
parameter_name      = "ratio of veins to arteries"
parameter_safe_name = "ratio-of-veins-to-arteries"
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
from plotting import setup_plots

# TRI: Transport Reaction Integral
# VMI: Velocity Magnitude Integral
# SVP: Slow Velocity Percentage
fig_tri, ax_tri = setup_plots.setup(1)
fig_vmi, ax_vmi = setup_plots.setup(2)
fig_svp, ax_svp = setup_plots.setup(3)

# Get data to plot.
data_tri, data_vmi, data_svp, avg_tri, avg_vmi, avg_svp = setup_plots.get_data(no_bins, simulation_bins, simulations)

# Plot data.
setup_plots.plot(ax_tri, parameter_values, data_tri, avg_tri)
setup_plots.plot(ax_vmi, parameter_values, data_vmi, avg_vmi)
setup_plots.plot(ax_svp, parameter_values, data_svp, avg_svp)

# Style plots.
setup_plots.style(ax_tri, parameter_name, "Transport Reaction Integral", y_scilimits=[-3, -3])
setup_plots.style(ax_vmi, parameter_name, "Velocity Magnitude Integral", y_scilimits=[-2, -2])
setup_plots.style(ax_svp, parameter_name, "Slow Velocity Percentage",    y_scilimits=None)

# Save plots.
fig_tri.savefig(f"images/transport-reaction-integral_{parameter_safe_name}.png", dpi=300)
fig_vmi.savefig(f"images/velocity-magnitude-integral_{parameter_safe_name}.png", dpi=300)
fig_svp.savefig(f"images/slow-velocity-percentage_{parameter_safe_name}.png",    dpi=300)

# Print the number of subsamples in each bin.
no_per_bin = [len(simulation_bins[i]) for i in range(0, no_bins)]
print(f"  ** NUMBER PER BIN **")
print(f"  Mean:    {np.mean(no_per_bin)}")
print(f"  Median:  {np.median(no_per_bin)}")
print(f"  Std:     {np.std(no_per_bin):.2f}")
print(f"  Minimum: {np.min(no_per_bin)}")
print(f"  Maximum: {np.max(no_per_bin)}")
print(f"  {no_per_bin}")