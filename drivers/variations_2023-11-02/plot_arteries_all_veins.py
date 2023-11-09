from miscellaneous import run_data, run_no, output_timer
import numpy as np
import copy

# Import all data from completed runs.
max_run_no  = run_no.get_completed_run_no()
simulations = run_data.import_simulations(max_run_no)
  
# Varying parameters.
parameter_name      = "number of arteries (all veins)"
parameter_safe_name = "no-arteries-all-veins"
min_value           = 1
max_value           = 6
no_bins             = 6
parameter_values    = np.linspace(min_value, max_value, no_bins)

# Populate the bins.
simulation_bins = [[] for i in range(no_bins)]
for i in range(0, max_run_no):
  run_no = i+1

  no_veins    = simulations[i].get_no_veins()
  no_arteries = simulations[i].get_no_arteries()

  #if (no_veins == 27):
  if (True):
    simulation_bins[no_arteries-1].append(run_no)

# Setup plots.
import matplotlib.pyplot as plt
from plotting import setup_plots

# TRI: Transport Reaction Integral
# VMI: Velocity Magnitude Integral
# SVP: Slow Velocity Percentage
fig_tri, ax_tri = setup_plots.setup(1)
fig_vmi, ax_vmi = setup_plots.setup(2)
fig_svp_i, ax_svp_i = setup_plots.setup(3)
fig_svp_e, ax_svp_e = setup_plots.setup(4)

# Get data to plot.
data_tri, data_vmi, data_svp_i, data_svp_e, avg_tri, avg_vmi, avg_svp_i, avg_svp_e = setup_plots.get_data(no_bins, simulation_bins, simulations)

# Plot data.
setup_plots.plot(ax_tri, parameter_values, data_tri, avg_tri)
setup_plots.plot(ax_vmi, parameter_values, data_vmi, avg_vmi)
setup_plots.plot(ax_svp_i, parameter_values, data_svp_i, avg_svp_i)
setup_plots.plot(ax_svp_e, parameter_values, data_svp_e, avg_svp_e)

# Style plots.
setup_plots.style(ax_tri, parameter_name, "Transport Reaction Integral", y_scilimits=[-3, -3])
setup_plots.style(ax_vmi, parameter_name, "Velocity Magnitude Integral", y_scilimits=[-2, -2])
setup_plots.style(ax_svp_i, parameter_name, "Slow Velocity Percentage (IVS)",    y_scilimits=None)
setup_plots.style(ax_svp_e, parameter_name, "Slow Velocity Percentage (everywhere)",    y_scilimits=None)

# Save plots.
fig_tri.savefig(f"images/transport-reaction-integral_{parameter_safe_name}.png", dpi=300)
fig_vmi.savefig(f"images/velocity-magnitude-integral_{parameter_safe_name}.png", dpi=300)
fig_svp_i.savefig(f"images/slow-velocity-percentage_IVS_{parameter_safe_name}.png",  dpi=300)
fig_svp_e.savefig(f"images/slow-velocity-percentage_everywhere_{parameter_safe_name}.png",  dpi=300)

# Print the number of subsamples in each bin.
no_per_bin = [len(simulation_bins[i]) for i in range(0, no_bins)]
print(f"  ** NUMBER PER BIN **")
print(f"  Mean:    {np.mean(no_per_bin)}")
print(f"  Median:  {np.median(no_per_bin)}")
print(f"  Std:     {np.std(no_per_bin):.2f}")
print(f"  Minimum: {np.min(no_per_bin)}")
print(f"  Maximum: {np.max(no_per_bin)}")
print(f"  {no_per_bin}")