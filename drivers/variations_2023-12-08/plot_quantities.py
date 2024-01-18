def plot(simulations, simulation_bins, parameter_values, parameter_name, parameter_safe_name, subfolder=None):
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
  fig_velocity_magnitude_integral                , ax_velocity_magnitude_integral                 = setup_plots.setup(1 )
  fig_slow_velocity_percentage_ivs               , ax_slow_velocity_percentage_ivs                = setup_plots.setup(2 )
  fig_slow_velocity_percentage_everywhere        , ax_slow_velocity_percentage_everywhere         = setup_plots.setup(3 )
  fig_slow_velocity_percentage_dellschaft        , ax_slow_velocity_percentage_dellschaft         = setup_plots.setup(4 )
  fig_fast_velocity_percentage_dellschaft        , ax_fast_velocity_percentage_dellschaft         = setup_plots.setup(5 )
  fig_slow_velocity_percentage_nominal_everywhere, ax_slow_velocity_percentage_nominal_everywhere = setup_plots.setup(6 )
  fig_transport_reaction_integral                , ax_transport_reaction_integral                 = setup_plots.setup(7 )
  fig_kinetic_energy_flux                        , ax_kinetic_energy_flux                         = setup_plots.setup(8 )
  fig_total_energy_flux                          , ax_total_energy_flux                           = setup_plots.setup(9 )
  fig_velocity_cross_flow_flux                   , ax_velocity_cross_flow_flux                    = setup_plots.setup(10)
  fig_transport_flux                             , ax_transport_flux                              = setup_plots.setup(11)

  # Get data to plot.
  data = setup_plots.get_data(no_bins, simulation_bins, simulations)

  # Plot data.
  setup_plots.plot(ax_velocity_magnitude_integral                 , parameter_values, data['data']['velocity_magnitude_integral']                 , data['averages']['velocity_magnitude_integral']                 )
  setup_plots.plot(ax_slow_velocity_percentage_ivs                , parameter_values, data['data']['slow_velocity_percentage_ivs']                , data['averages']['slow_velocity_percentage_ivs']                )
  setup_plots.plot(ax_slow_velocity_percentage_everywhere         , parameter_values, data['data']['slow_velocity_percentage_everywhere']         , data['averages']['slow_velocity_percentage_everywhere']         )
  setup_plots.plot(ax_slow_velocity_percentage_dellschaft         , parameter_values, data['data']['slow_velocity_percentage_dellschaft']         , data['averages']['slow_velocity_percentage_dellschaft']         )
  setup_plots.plot(ax_fast_velocity_percentage_dellschaft         , parameter_values, data['data']['fast_velocity_percentage_dellschaft']         , data['averages']['fast_velocity_percentage_dellschaft']         )
  setup_plots.plot(ax_slow_velocity_percentage_nominal_everywhere , parameter_values, data['data']['slow_velocity_percentage_nominal_everywhere'] , data['averages']['slow_velocity_percentage_nominal_everywhere'] )
  setup_plots.plot(ax_transport_reaction_integral                 , parameter_values, data['data']['transport_reaction_integral']                 , data['averages']['transport_reaction_integral']                 )
  setup_plots.plot(ax_kinetic_energy_flux                         , parameter_values, data['data']['kinetic_energy_flux']                         , data['averages']['kinetic_energy_flux']                         )
  setup_plots.plot(ax_total_energy_flux                           , parameter_values, data['data']['total_energy_flux']                           , data['averages']['total_energy_flux']                           )
  setup_plots.plot(ax_velocity_cross_flow_flux                    , parameter_values, data['data']['velocity_cross_flow_flux']                    , data['averages']['velocity_cross_flow_flux']                    )
  setup_plots.plot(ax_transport_flux                              , parameter_values, data['data']['transport_flux']                              , data['averages']['transport_flux']                              )

  # Style plots.
  setup_plots.style(fig_velocity_magnitude_integral                 , ax_velocity_magnitude_integral                 , parameter_name, r"$E_v ~ \text{(m}/\text{s)}$"                                        , y_scilimits=[-3  , -     3  ])
  setup_plots.style(fig_slow_velocity_percentage_ivs                , ax_slow_velocity_percentage_ivs                , parameter_name, r"$E_s(U_\text{avg})$ (IVS) \%"                                       , y_scilimits=None , y_top=100 )
  setup_plots.style(fig_slow_velocity_percentage_everywhere         , ax_slow_velocity_percentage_everywhere         , parameter_name, r"$E_s(U_\text{avg})$ (everywhere) \%"                                , y_scilimits=None , y_top=100 )
  setup_plots.style(fig_slow_velocity_percentage_dellschaft         , ax_slow_velocity_percentage_dellschaft         , parameter_name, r"$E_s(0.0005)$ (everywhere) \%"                                      , y_scilimits=None , y_top=100 )
  setup_plots.style(fig_fast_velocity_percentage_dellschaft         , ax_fast_velocity_percentage_dellschaft         , parameter_name, r"$1-E_s(0.001)$ (everywhere) \%"                                     , y_scilimits=None , y_top=100 )
  setup_plots.style(fig_slow_velocity_percentage_nominal_everywhere , ax_slow_velocity_percentage_nominal_everywhere , parameter_name, r"$E_s(U_\text{nom})$ (everywhere) \%"                                , y_scilimits=None , y_top=100 )
  setup_plots.style(fig_transport_reaction_integral                 , ax_transport_reaction_integral                 , parameter_name, r"$E_r ~ \text{(}\text{s}^{-1}\text{)}$"                              , y_scilimits=[-4  , -     4  ])
  setup_plots.style(fig_kinetic_energy_flux                         , ax_kinetic_energy_flux                         , parameter_name, r"$E_{\text{K}}$"                                                     , y_scilimits=[-4  , -     4  ])
  setup_plots.style(fig_total_energy_flux                           , ax_total_energy_flux                           , parameter_name, r"$E_{\text{T}}$"                                                     , y_scilimits=[ 4  ,       4  ])
  setup_plots.style(fig_velocity_cross_flow_flux                    , ax_velocity_cross_flow_flux                    , parameter_name, r"$E_{\text{c}}(\Omega_i \cap \Omega_{i+1})$"                         , y_scilimits=[-2  , -     2  ])
  setup_plots.style(fig_transport_flux                              , ax_transport_flux                              , parameter_name, r"$E_{\text{F}}(\Gamma_\text{in}) - E_{\text{F}}(\Gamma_\text{out})$" , y_scilimits=[-1  , -     1  ])

  # Decide where to save plots.
  if subfolder == None:
    images_folder = "images"
  else:
    images_folder = f"images/{subfolder}"

  # Save plots.
  fig_velocity_magnitude_integral                 .savefig(f"{images_folder}/velocity-magnitude-integral_{parameter_safe_name}.png"                 , dpi=300)
  fig_slow_velocity_percentage_ivs                .savefig(f"{images_folder}/slow-velocity-percentage_IVS_{parameter_safe_name}.png"                , dpi=300)
  fig_slow_velocity_percentage_everywhere         .savefig(f"{images_folder}/slow-velocity-percentage_everywhere_{parameter_safe_name}.png"         , dpi=300)
  fig_slow_velocity_percentage_dellschaft         .savefig(f"{images_folder}/slow-velocity-percentage_Dellschaft_{parameter_safe_name}.png"         , dpi=300)
  fig_fast_velocity_percentage_dellschaft         .savefig(f"{images_folder}/fast-velocity-percentage_Dellschaft_{parameter_safe_name}.png"         , dpi=300)
  fig_slow_velocity_percentage_nominal_everywhere .savefig(f"{images_folder}/slow-velocity-percentage_nominal-everywhere_{parameter_safe_name}.png" , dpi=300)
  fig_transport_reaction_integral                 .savefig(f"{images_folder}/transport-reaction-integral_{parameter_safe_name}.png"                 , dpi=300)
  fig_kinetic_energy_flux                         .savefig(f"{images_folder}/kinetic-energy-flux_{parameter_safe_name}.png"                         , dpi=300)
  fig_total_energy_flux                           .savefig(f"{images_folder}/total-energy-flux_{parameter_safe_name}.png"                           , dpi=300)
  fig_velocity_cross_flow_flux                    .savefig(f"{images_folder}/velocity-cross-flow-flux_{parameter_safe_name}.png"                    , dpi=300)
  fig_transport_flux                              .savefig(f"{images_folder}/transport-flux_{parameter_safe_name}.png"                              , dpi=300)

  # Done.
  print(f"\rPlotting simulations... Done.", end="\r\n")

  # Print the number of subsamples in each bin.
  from tabulate import tabulate
  no_per_bin = [len(simulation_bins[i]) for i in range(0, no_bins)]
  no_simulations = sum(no_per_bin)
  print(tabulate([[parameter_name, no_simulations, np.mean(no_per_bin), np.median(no_per_bin), np.std(no_per_bin), np.min(no_per_bin), np.max(no_per_bin), no_per_bin]], headers=["Name", "#", "Mean", "Median", "Std", "Minimum", "Maximum", "Number per bin"], tablefmt="rounded_outline", floatfmt=".2f"))