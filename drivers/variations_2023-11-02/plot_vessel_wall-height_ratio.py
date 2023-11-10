from miscellaneous import run_data, run_no, output_timer
import numpy as np
import copy

# Import all data from completed runs.
max_run_no  = run_no.get_completed_run_no()
simulations = run_data.import_simulations(max_run_no)
  
# Varying parameters.
parameter_name      = "wall height ratio"
parameter_safe_name = "wall-height-ratio"
min_value           = 1.0/3.0
max_value           = 2.0
no_bins             = 10
parameter_values    = np.linspace(min_value, max_value, no_bins)

db            = (max_value - min_value)/(no_bins-1)
integer_ticks = db.is_integer()

# Populate the bins.
simulation_bins = [[] for i in range(no_bins)]
for i in range(0, max_run_no):
  run_no = i+1

  bin_no = int(np.floor((no_bins)*(simulations[i].parameters["wall_height_ratio"] - min_value)/(max_value - min_value)))
  if (bin_no == no_bins):
    bin_no -= 1
  simulation_bins[bin_no].append(run_no)

# Setup plots.
import matplotlib.pyplot as plt
from plotting import setup_plots

# TRI: Transport Reaction Integral
# VMI: Velocity Magnitude Integral
# SVP: Slow Velocity Percentage
# FVP: Fast Velocity Percentage
fig_tri           , ax_tri            = setup_plots.setup(1)
fig_vmi           , ax_vmi            = setup_plots.setup(2)
fig_svp_ivs       , ax_svp_ivs        = setup_plots.setup(3)
fig_svp_everywhere, ax_svp_everywhere = setup_plots.setup(4)
fig_svp_dellschaft, ax_svp_dellschaft = setup_plots.setup(5)
fig_fvp_dellschaft, ax_fvp_dellschaft = setup_plots.setup(6)

# Get data to plot.
data_tri, data_vmi, data_svp_ivs, data_svp_everywhere, data_svp_dellschaft, data_fvp_dellschaft, avg_tri, avg_vmi, avg_svp_ivs, avg_svp_everywhere, avg_svp_dellschaft, avg_fvp_dellschaft = setup_plots.get_data(no_bins, simulation_bins, simulations)

# Plot data.
setup_plots.plot(ax_tri           , parameter_values, data_tri           , avg_tri           , 0.75*db)
setup_plots.plot(ax_vmi           , parameter_values, data_vmi           , avg_vmi           , 0.75*db)
setup_plots.plot(ax_svp_ivs       , parameter_values, data_svp_ivs       , avg_svp_ivs       , 0.75*db)
setup_plots.plot(ax_svp_everywhere, parameter_values, data_svp_everywhere, avg_svp_everywhere, 0.75*db)
setup_plots.plot(ax_svp_dellschaft, parameter_values, data_svp_dellschaft, avg_svp_dellschaft, 0.75*db)
setup_plots.plot(ax_fvp_dellschaft, parameter_values, data_fvp_dellschaft, avg_fvp_dellschaft, 0.75*db)

# Style plots.
setup_plots.style(ax_tri           , parameter_name, "Transport Reaction Integral"          , y_scilimits=[-3, -3], integer_ticks=integer_ticks, xlim=[min_value-0.5*db, max_value+0.5*db])
setup_plots.style(ax_vmi           , parameter_name, "Velocity Magnitude Integral"          , y_scilimits=[-2, -2], integer_ticks=integer_ticks, xlim=[min_value-0.5*db, max_value+0.5*db])
setup_plots.style(ax_svp_ivs       , parameter_name, "Slow Velocity Percentage (IVS)"       , y_scilimits=None    , integer_ticks=integer_ticks, xlim=[min_value-0.5*db, max_value+0.5*db], y_top=100)
setup_plots.style(ax_svp_everywhere, parameter_name, "Slow Velocity Percentage (everywhere)", y_scilimits=None    , integer_ticks=integer_ticks, xlim=[min_value-0.5*db, max_value+0.5*db], y_top=100)
setup_plots.style(ax_svp_dellschaft, parameter_name, "Slow Velocity Percentage (Dellschaft)", y_scilimits=None    , integer_ticks=integer_ticks, xlim=[min_value-0.5*db, max_value+0.5*db], y_top=100)
setup_plots.style(ax_fvp_dellschaft, parameter_name, "Fast Velocity Percentage (Dellschaft)", y_scilimits=None    , integer_ticks=integer_ticks, xlim=[min_value-0.5*db, max_value+0.5*db], y_top=100)

# Save plots.
fig_tri           .savefig(f"images/transport-reaction-integral_{parameter_safe_name}.png"        , dpi=300)
fig_vmi           .savefig(f"images/velocity-magnitude-integral_{parameter_safe_name}.png"        , dpi=300)
fig_svp_ivs       .savefig(f"images/slow-velocity-percentage_IVS_{parameter_safe_name}.png"       , dpi=300)
fig_svp_everywhere.savefig(f"images/slow-velocity-percentage_everywhere_{parameter_safe_name}.png", dpi=300)
fig_svp_dellschaft.savefig(f"images/slow-velocity-percentage_Dellschaft_{parameter_safe_name}.png", dpi=300)
fig_fvp_dellschaft.savefig(f"images/fast-velocity-percentage_Dellschaft_{parameter_safe_name}.png", dpi=300)

# Print the number of subsamples in each bin.
no_per_bin = [len(simulation_bins[i]) for i in range(0, no_bins)]
print(f"  ** NUMBER PER BIN **")
print(f"  Mean:    {np.mean(no_per_bin)}")
print(f"  Median:  {np.median(no_per_bin)}")
print(f"  Std:     {np.std(no_per_bin):.2f}")
print(f"  Minimum: {np.min(no_per_bin)}")
print(f"  Maximum: {np.max(no_per_bin)}")
print(f"  {no_per_bin}")