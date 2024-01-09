def plot(simulations, simulation_bins, parameter_values, parameter_name, parameter_safe_name):
  print(f"\rPlotting simulations...", end="")
  no_bins = len(simulation_bins)

  # Setup plots.
  import numpy as np
  from plotting import setup_plots

  # TRI: Transport Reaction Integral
  # VMI: Velocity Magnitude Integral
  # SVP: Slow Velocity Percentage
  # FVP: Fast Velocity Percentage
  # CFF: Cross Flow Flux
  # OFF: Out Flow Flux
  fig_tri           , ax_tri            = setup_plots.setup(1)
  fig_vmi           , ax_vmi            = setup_plots.setup(2)
  fig_svp_ivs       , ax_svp_ivs        = setup_plots.setup(3)
  fig_svp_everywhere, ax_svp_everywhere = setup_plots.setup(4)
  fig_svp_dellschaft, ax_svp_dellschaft = setup_plots.setup(5)
  fig_fvp_dellschaft, ax_fvp_dellschaft = setup_plots.setup(6)
  fig_vel_cff       , ax_vel_cff        = setup_plots.setup(8)
  fig_tra_cff       , ax_tra_cff        = setup_plots.setup(9)
  fig_vel_off       , ax_vel_off        = setup_plots.setup(10)
  fig_tra_off       , ax_tra_off        = setup_plots.setup(11)
  fig_te_off        , ax_te_off         = setup_plots.setup(12)
  fig_ke_off        , ax_ke_off         = setup_plots.setup(13)

  # Get data to plot.
  data_tri, data_vmi, data_svp_ivs, data_svp_everywhere, data_svp_dellschaft, data_fvp_dellschaft, data_vel_cff, data_tra_cff, avg_tri, avg_vmi, avg_svp_ivs, avg_svp_everywhere, avg_svp_dellschaft, avg_fvp_dellschaft, avg_vel_cff, avg_tra_cff = setup_plots.get_data(no_bins, simulation_bins, simulations)

  # Plot data.
  setup_plots.plot(ax_tri           , parameter_values, data_tri           , avg_tri           )
  setup_plots.plot(ax_vmi           , parameter_values, data_vmi           , avg_vmi           )
  setup_plots.plot(ax_svp_ivs       , parameter_values, data_svp_ivs       , avg_svp_ivs       )
  setup_plots.plot(ax_svp_everywhere, parameter_values, data_svp_everywhere, avg_svp_everywhere)
  setup_plots.plot(ax_svp_dellschaft, parameter_values, data_svp_dellschaft, avg_svp_dellschaft)
  setup_plots.plot(ax_fvp_dellschaft, parameter_values, data_fvp_dellschaft, avg_fvp_dellschaft)
  setup_plots.plot(ax_vel_cff       , parameter_values, data_vel_cff       , avg_vel_cff       )
  setup_plots.plot(ax_tra_cff       , parameter_values, data_tra_cff       , avg_tra_cff       )

  # Style plots.
  setup_plots.style(fig_tri            , ax_tri            , parameter_name, r"$E_r ~ \text{(M}/\text{m}^3\text{)}$"  , y_scilimits=[-3, -3])
  setup_plots.style(fig_vmi            , ax_vmi            , parameter_name, r"$E_v ~ \text{(m}/\text{s)}$"           , y_scilimits=[-3, -3])
  setup_plots.style(fig_svp_ivs        , ax_svp_ivs        , parameter_name, r"$E_s(U_\text{avg})$ (IVS)"             , y_scilimits=None , y_top=100)
  setup_plots.style(fig_svp_everywhere , ax_svp_everywhere , parameter_name, r"$E_s(U_\text{avg})$ (everywhere)"      , y_scilimits=None , y_top=100)
  setup_plots.style(fig_svp_dellschaft , ax_svp_dellschaft , parameter_name, r"$E_s(0.0005)$ (everywhere)"            , y_scilimits=None , y_top=100)
  setup_plots.style(fig_fvp_dellschaft , ax_fvp_dellschaft , parameter_name, r"$1-E_s(0.001)$ (everywhere)"           , y_scilimits=None , y_top=100)
  setup_plots.style(fig_vel_cff        , ax_vel_cff        , parameter_name, r"$E_{\text{cross},\vec{u}}"             , y_scilimits=[-3, -3])
  setup_plots.style(fig_tra_cff        , ax_tra_cff        , parameter_name, r"$E_{\text{cross},c}$"                  , y_scilimits=[-3, -3])

  # Save plots.
  fig_tri           .savefig(f"images/transport-reaction-integral_{parameter_safe_name}.png"        , dpi=300)
  fig_vmi           .savefig(f"images/velocity-magnitude-integral_{parameter_safe_name}.png"        , dpi=300)
  fig_svp_ivs       .savefig(f"images/slow-velocity-percentage_IVS_{parameter_safe_name}.png"       , dpi=300)
  fig_svp_everywhere.savefig(f"images/slow-velocity-percentage_everywhere_{parameter_safe_name}.png", dpi=300)
  fig_svp_dellschaft.savefig(f"images/slow-velocity-percentage_Dellschaft_{parameter_safe_name}.png", dpi=300)
  fig_fvp_dellschaft.savefig(f"images/fast-velocity-percentage_Dellschaft_{parameter_safe_name}.png", dpi=300)
  fig_vel_cff       .savefig(f"images/velocity-cross-flow-flux_{parameter_safe_name}.png"           , dpi=300)
  fig_tra_cff       .savefig(f"images/transport-cross-flow-flux_{parameter_safe_name}.png"          , dpi=300)

  # Done.
  print(f"\rPlotting simulations... Done.", end="\r\n")

  # Print the number of subsamples in each bin.
  from tabulate import tabulate
  no_per_bin = [len(simulation_bins[i]) for i in range(0, no_bins)]
  no_simulations = sum(no_per_bin)
  print(tabulate([[parameter_name, no_simulations, np.mean(no_per_bin), np.median(no_per_bin), np.std(no_per_bin), np.min(no_per_bin), np.max(no_per_bin), no_per_bin]], headers=["Name", "#Simulations", "Mean", "Median", "Std", "Minimum", "Maximum", "Number per bin"], tablefmt="rounded_outline", floatfmt=".2f"))