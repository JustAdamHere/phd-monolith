def plot_others(simulations, simulation_bins, parameter_values, parameter_name, parameter_safe_name, subfolder=None):
  import numpy as np

  print(f"\rPlotting simulations...", end="")

  assert(len(parameter_values) == 3)
  assert(len(simulation_bins) == 3)
  assert(len(simulations) == 3)

  # Setup plots.
  from plotting import setup_plots
  fig, axes = setup_plots.setup_megaplot(1, 8, 3, figsize=(10, 18))

  # Get data to plot.
  data = np.zeros(3, dtype=object)
  for j in range(3):
    data[j] = setup_plots.get_data(len(simulation_bins[j]), simulation_bins[j], simulations[j])

  # Patches for legends.
  import matplotlib.patches as mpatches
  max_no_patches = 4
  handles = []
  for i in range(max_no_patches):
    handles.append(mpatches.Patch(color=f"C{i}"))

  # AXES 1: Velocity magnitude integrals.
  for j in range(3):
    axes[0][j].plot(parameter_values[j], data[j]["q50"]["velocity_magnitude_integral"], linestyle="dashed", color=f"C0")
    axes[0][j].fill_between(parameter_values[j], data[j]["q25"]["velocity_magnitude_integral"], data[j]["q75"]["velocity_magnitude_integral"], alpha=0.2, color=f"C0")

  # AXES 2: Slow velocity percentages.
  for j in range(3):
    axes[1][j].plot(parameter_values[j], data[j]["q50"]["slow_velocity_percentage_ivs"], linestyle="dashed", color="C0")
    axes[1][j].plot(parameter_values[j], data[j]["q50"]["slow_velocity_percentage_everywhere"], linestyle="dashed", color="C1")
    axes[1][j].plot(parameter_values[j], data[j]["q50"]["slow_velocity_percentage_dellschaft"], linestyle="dashed", color="C2")
    axes[1][j].plot(parameter_values[j], data[j]["q50"]["slow_velocity_percentage_nominal_everywhere"], linestyle="dashed", color="C3")
    axes[1][j].fill_between(parameter_values[j], data[j]["q25"]["slow_velocity_percentage_ivs"], data[j]["q75"]["slow_velocity_percentage_ivs"], alpha=0.2, color="C0")
    axes[1][j].fill_between(parameter_values[j], data[j]["q25"]["slow_velocity_percentage_everywhere"], data[j]["q75"]["slow_velocity_percentage_everywhere"], alpha=0.2, color="C1")
    axes[1][j].fill_between(parameter_values[j], data[j]["q25"]["slow_velocity_percentage_dellschaft"], data[j]["q75"]["slow_velocity_percentage_dellschaft"], alpha=0.2, color="C2")
    axes[1][j].fill_between(parameter_values[j], data[j]["q25"]["slow_velocity_percentage_nominal_everywhere"], data[j]["q75"]["slow_velocity_percentage_nominal_everywhere"], alpha=0.2, color="C3")
    axes[1][j].legend(handles=handles[0:4], labels=["IVS", "everywhere", "Dellschaft", "nominal everywhere"])

  # AXES 3: Velocity flux through different veins.
  for j in range(3):
    axes[2][j].plot(parameter_values[j], data[j]["q50"]["velocity_percentage_basal_plate"], linestyle="dashed", color="C0")
    axes[2][j].plot(parameter_values[j], data[j]["q50"]["velocity_percentage_septal_wall"], linestyle="dashed", color="C1")
    axes[2][j].plot(parameter_values[j], data[j]["q50"]["velocity_percentage_marginal_sinus"], linestyle="dashed", color="C2")
    axes[2][j].fill_between(parameter_values[j], data[j]["q25"]["velocity_percentage_basal_plate"], data[j]["q75"]["velocity_percentage_basal_plate"], alpha=0.2, color="C0")
    axes[2][j].fill_between(parameter_values[j], data[j]["q25"]["velocity_percentage_septal_wall"], data[j]["q75"]["velocity_percentage_septal_wall"], alpha=0.2, color="C1")
    axes[2][j].fill_between(parameter_values[j], data[j]["q25"]["velocity_percentage_marginal_sinus"], data[j]["q75"]["velocity_percentage_marginal_sinus"], alpha=0.2, color="C2")
    axes[2][j].legend(handles=handles[0:3], labels=["basal plate", "septal wall", "marginal sinus"])

  # AXES 4: Cross-flux velocity.
  for j in range(3):
    axes[3][j].plot(parameter_values[j], data[j]["q50"]["velocity_cross_flow_flux"], linestyle="dashed", color=f"C0")
    axes[3][j].fill_between(parameter_values[j], data[j]["q25"]["velocity_cross_flow_flux"], data[j]["q75"]["velocity_cross_flow_flux"], alpha=0.2, color=f"C0")

  # AXES 5: Transport reaction integral.
  for j in range(3):
    axes[4][j].plot(parameter_values[j], data[j]["q50"]["transport_reaction_integral"], linestyle="dashed", color=f"C0")
    axes[4][j].fill_between(parameter_values[j], data[j]["q25"]["transport_reaction_integral"], data[j]["q75"]["transport_reaction_integral"], alpha=0.2, color=f"C0")

  # AXES 6: Concentration flux through different veins.
  for j in range(3):
    axes[5][j].plot(parameter_values[j], data[j]["q50"]["transport_percentage_basal_plate"], linestyle="dashed", color="C0")
    axes[5][j].plot(parameter_values[j], data[j]["q50"]["transport_percentage_septal_wall"], linestyle="dashed", color="C1")
    axes[5][j].plot(parameter_values[j], data[j]["q50"]["transport_percentage_marginal_sinus"], linestyle="dashed", color="C2")
    axes[5][j].fill_between(parameter_values[j], data[j]["q25"]["transport_percentage_basal_plate"], data[j]["q75"]["transport_percentage_basal_plate"], alpha=0.2, color="C0")
    axes[5][j].fill_between(parameter_values[j], data[j]["q25"]["transport_percentage_septal_wall"], data[j]["q75"]["transport_percentage_septal_wall"], alpha=0.2, color="C1")
    axes[5][j].fill_between(parameter_values[j], data[j]["q25"]["transport_percentage_marginal_sinus"], data[j]["q75"]["transport_percentage_marginal_sinus"], alpha=0.2, color="C2")
    axes[5][j].legend(handles=handles[0:3], labels=["basal plate", "septal wall", "marginal sinus"])

  # AXES 7: Kinetic energy flux difference.
  for j in range(3):
    axes[6][j].plot(parameter_values[j], data[j]["q50"]["kinetic_energy_flux"], linestyle="dashed", color=f"C0")
    axes[6][j].fill_between(parameter_values[j], data[j]["q25"]["kinetic_energy_flux"], data[j]["q75"]["kinetic_energy_flux"], alpha=0.2, color=f"C0")  

  # AXES 8: Total energy flux difference.
  for j in range(3):
    axes[7][j].plot(parameter_values[j], data[j]["q50"]["total_energy_flux"], linestyle="dashed", color=f"C0")
    axes[7][j].fill_between(parameter_values[j], data[j]["q25"]["total_energy_flux"], data[j]["q75"]["total_energy_flux"], alpha=0.2, color=f"C0")

  # Style plots.
  setup_plots.style(fig, axes[0][0], None, r"$\bar{v}$", y_scilimits=[-3, -3] , y_bottom=0, y_top=1e-2, integer_ticks=False)
  setup_plots.style(fig, axes[1][0], None, r"$v_\text{slow}(V_\text{threshold})$", y_scilimits=None , y_top=102, integer_ticks=False)
  setup_plots.style(fig, axes[2][0], None, r"$\frac{v_\text{flux}(S)}{v_\text{flux}(\Gamma_\text{in})}$ (%)", y_scilimits=None , y_top=102, integer_ticks=False)
  setup_plots.style(fig, axes[3][0], None, r"$v_\text{cross}$", y_scilimits=[-3, -3] , y_bottom=0, y_top=2e-2, integer_ticks=False)
  setup_plots.style(fig, axes[4][0], None, r"$\bar{c}$", y_scilimits=[-3, -3], y_bottom=0, y_top=2e-3, integer_ticks=False)
  setup_plots.style(fig, axes[5][0], None, r"$\frac{C_\text{flux}(S)}{C_\text{flux}(\Gamma_\text{in})}$ (%)", y_scilimits=None , y_top=102, integer_ticks=False)
  setup_plots.style(fig, axes[6][0], None, r"$E_\text{kinetic}(\Gamma_\text{in}) - E_\text{kinetic}(\Gamma_\text{out})$", y_scilimits=[2, 2], y_bottom=0, y_top=1e2, integer_ticks=False, max_major_ticks=4)
  setup_plots.style(fig, axes[7][0], parameter_name[0], r"$E_\text{total}(\Gamma_\text{in}) - E_\text{total}(\Gamma_\text{out})$", y_scilimits=[3, 3], y_bottom=0, y_top=3e3, integer_ticks=False, max_major_ticks=4, y_labelpad=25)

  setup_plots.style(fig, axes[0][1], None, None, y_scilimits=[-3, -3], y_bottom=0, y_top=1e-2, integer_ticks=True, max_major_ticks=4)
  setup_plots.style(fig, axes[1][1], None, None, y_scilimits=None , y_top=102, integer_ticks=True, max_major_ticks=4)
  setup_plots.style(fig, axes[2][1], None, None, y_scilimits=None , y_top=102, integer_ticks=True, max_major_ticks=4)
  setup_plots.style(fig, axes[3][1], None, None, y_scilimits=[-3, -3], y_bottom=0, y_top=2e-2, integer_ticks=True, max_major_ticks=4)
  setup_plots.style(fig, axes[4][1], None, None, y_scilimits=[-3, -3], y_bottom=0, y_top=2e-3, integer_ticks=True, max_major_ticks=4)
  setup_plots.style(fig, axes[5][1], None, None, y_scilimits=None , y_top=102, integer_ticks=True, max_major_ticks=4)
  setup_plots.style(fig, axes[6][1], None, None, y_scilimits=[2, 2], y_bottom=0, y_top=1e2, integer_ticks=True, max_major_ticks=4)
  setup_plots.style(fig, axes[7][1], parameter_name[1], None, y_scilimits=[3, 3], y_bottom=0, y_top=3e3, integer_ticks=True, max_major_ticks=4)

  setup_plots.style(fig, axes[0][2], None, None, y_scilimits=[-3, -3], y_bottom=0, y_top=1e-2, integer_ticks=False, max_major_ticks=4)
  setup_plots.style(fig, axes[1][2], None, None, y_scilimits=None , y_top=102, integer_ticks=False, max_major_ticks=4)
  setup_plots.style(fig, axes[2][2], None, None, y_scilimits=None , y_top=102, integer_ticks=False, max_major_ticks=4)
  setup_plots.style(fig, axes[3][2], None, None, y_scilimits=[-3, -3], y_bottom=0, y_top=2e-2, integer_ticks=False, max_major_ticks=4)
  setup_plots.style(fig, axes[4][2], None, None, y_scilimits=[-3, -3], y_bottom=0, y_top=2e-3, integer_ticks=False, max_major_ticks=4)
  setup_plots.style(fig, axes[5][2], None, None, y_scilimits=None , y_top=102, integer_ticks=False, max_major_ticks=4)
  setup_plots.style(fig, axes[6][2], None, None, y_scilimits=[2, 2], y_bottom=0, y_top=1e2, integer_ticks=False, max_major_ticks=4)
  setup_plots.style(fig, axes[7][2], parameter_name[2], None, y_scilimits=[3, 3], y_bottom=0, y_top=3e3, integer_ticks=False, max_major_ticks=4)

  # Decide where to save plots.
  if subfolder == None:
    images_folder = "images"
  else:
    images_folder = f"images/{subfolder}"

  # Save.
  fig.savefig(f"{images_folder}/mega_{parameter_safe_name[0]}_{parameter_safe_name[1]}_{parameter_safe_name[2]}.png", dpi=300)

  # Done.
  print(f"\rPlotting simulations... Done.", end="\r\n")

def plot_vessels(simulations, simulation_bins, parameter_values, parameter_name, parameter_safe_name, subfolder=None):
  import numpy as np

  print(f"\rPlotting simulations...", end="")
  no_bins = len(simulation_bins[0][0])

  assert(len(parameter_values) == 3)
  assert(len(simulation_bins) == 3)
  assert(len(simulation_bins[0]) == 2)
  assert(len(simulation_bins[1]) == 2)
  assert(len(simulation_bins[2]) == 1)

  # Setup plots.
  from plotting import setup_plots
  fig, axes = setup_plots.setup_megaplot(1, 8, 3, figsize=(10, 18))
  fig_mini, axes_mini = setup_plots.setup_megaplot(2, 2, 3, figsize=(10, 6))

  # Get data to plot.
  data = np.zeros((2, 3), dtype=object)
  for j in range(3):
    for i in range(2):
      # TODO: Real nasty hack to make this run. To fix.
      if not (j == 2 and i > 0):
        data[i, j] = setup_plots.get_data(len(simulation_bins[j][i]), simulation_bins[j][i], simulations)

  # Patches for legends.
  import matplotlib.patches as mpatches
  max_no_patches = 4
  handles = []
  for i in range(max_no_patches):
    handles.append(mpatches.Patch(color=f"C{i}"))

  # AXES 1: Velocity magnitude integrals.
  for j in range(3):
    for i in range(2):
      if not (j == 2 and i > 0):
        axes[0][j].plot(parameter_values[j], data[i, j]["q50"]["velocity_magnitude_integral"], linestyle="dashed", color=f"C{i}")
        axes[0][j].fill_between(parameter_values[j], data[i, j]["q25"]["velocity_magnitude_integral"], data[i, j]["q75"]["velocity_magnitude_integral"], alpha=0.2, color=f"C{i}")
    axes_mini[0][j].plot(parameter_values[j], data[0, j]["q50"]["velocity_magnitude_integral"], linestyle="dashed", color=f"C0")
    axes_mini[0][j].fill_between(parameter_values[j], data[0, j]["q25"]["velocity_magnitude_integral"], data[0, j]["q75"]["velocity_magnitude_integral"], alpha=0.2, color=f"C0")
    
  axes[0][0].legend(handles=handles[0:2], labels=["any veins", "27 veins"])
  axes[0][1].legend(handles=handles[0:2], labels=["any arteries", "6 arteries"])

  # AXES 2: Slow velocity percentages.
  for j in range(3):
    axes[1][j].plot(parameter_values[j], data[0, j]["q50"]["slow_velocity_percentage_ivs"], linestyle="dashed", color="C0")
    axes[1][j].plot(parameter_values[j], data[0, j]["q50"]["slow_velocity_percentage_everywhere"], linestyle="dashed", color="C1")
    axes[1][j].plot(parameter_values[j], data[0, j]["q50"]["slow_velocity_percentage_dellschaft"], linestyle="dashed", color="C2")
    axes[1][j].plot(parameter_values[j], data[0, j]["q50"]["slow_velocity_percentage_nominal_everywhere"], linestyle="dashed", color="C3")
    axes[1][j].fill_between(parameter_values[j], data[0, j]["q25"]["slow_velocity_percentage_ivs"], data[0, j]["q75"]["slow_velocity_percentage_ivs"], alpha=0.2, color="C0")
    axes[1][j].fill_between(parameter_values[j], data[0, j]["q25"]["slow_velocity_percentage_everywhere"], data[0, j]["q75"]["slow_velocity_percentage_everywhere"], alpha=0.2, color="C1")
    axes[1][j].fill_between(parameter_values[j], data[0, j]["q25"]["slow_velocity_percentage_dellschaft"], data[0, j]["q75"]["slow_velocity_percentage_dellschaft"], alpha=0.2, color="C2")
    axes[1][j].fill_between(parameter_values[j], data[0, j]["q25"]["slow_velocity_percentage_nominal_everywhere"], data[0, j]["q75"]["slow_velocity_percentage_nominal_everywhere"], alpha=0.2, color="C3")
    axes[1][j].legend(handles=handles[0:4], labels=["IVS", "everywhere", "Dellschaft", "nominal"])

  # AXES 3: Velocity flux through different veins.
  for j in range(3):
    axes[2][j].plot(parameter_values[j], data[0, j]["q50"]["velocity_percentage_basal_plate"], linestyle="dashed", color="C0")
    axes[2][j].plot(parameter_values[j], data[0, j]["q50"]["velocity_percentage_septal_wall"], linestyle="dashed", color="C1")
    axes[2][j].plot(parameter_values[j], data[0, j]["q50"]["velocity_percentage_marginal_sinus"], linestyle="dashed", color="C2")
    axes[2][j].fill_between(parameter_values[j], data[0, j]["q25"]["velocity_percentage_basal_plate"], data[0, j]["q75"]["velocity_percentage_basal_plate"], alpha=0.2, color="C0")
    axes[2][j].fill_between(parameter_values[j], data[0, j]["q25"]["velocity_percentage_septal_wall"], data[0, j]["q75"]["velocity_percentage_septal_wall"], alpha=0.2, color="C1")
    axes[2][j].fill_between(parameter_values[j], data[0, j]["q25"]["velocity_percentage_marginal_sinus"], data[0, j]["q75"]["velocity_percentage_marginal_sinus"], alpha=0.2, color="C2")
    axes[2][j].legend(handles=handles[0:3], labels=["basal plate", "septal wall", "marginal sinus"])

  # AXES 4: Cross-flux velocity.
  for j in range(3):
    for i in range(2):
      if not (j == 2 and i > 0):
        axes[3][j].plot(parameter_values[j], data[i, j]["q50"]["velocity_cross_flow_flux"], linestyle="dashed", color=f"C{i}")
        axes[3][j].fill_between(parameter_values[j], data[i, j]["q25"]["velocity_cross_flow_flux"], data[i, j]["q75"]["velocity_cross_flow_flux"], alpha=0.2, color=f"C{i}")
  axes[3][0].legend(handles=handles[0:2], labels=["any veins", "27 veins"])
  axes[3][1].legend(handles=handles[0:2], labels=["any arteries", "6 arteries"])

  # AXES 5: Transport reaction integral.
  for j in range(3):
    for i in range(2):
      if not (j == 2 and i > 0):
        axes[4][j].plot(parameter_values[j], data[i, j]["q50"]["transport_reaction_integral"], linestyle="dashed", color=f"C{i}")
        axes[4][j].fill_between(parameter_values[j], data[i, j]["q25"]["transport_reaction_integral"], data[i, j]["q75"]["transport_reaction_integral"], alpha=0.2, color=f"C{i}")
    axes_mini[1][j].plot(parameter_values[j], data[0, j]["q50"]["transport_reaction_integral"], linestyle="dashed", color=f"C0")
    axes_mini[1][j].fill_between(parameter_values[j], data[0, j]["q25"]["transport_reaction_integral"], data[0, j]["q75"]["transport_reaction_integral"], alpha=0.2, color=f"C0")
  axes[4][0].legend(handles=handles[0:2], labels=["any veins", "27 veins"])
  axes[4][1].legend(handles=handles[0:2], labels=["any arteries", "6 arteries"])

  # AXES 6: Concentration flux through different veins.
  for j in range(3):
    axes[5][j].plot(parameter_values[j], data[0, j]["q50"]["transport_percentage_basal_plate"], linestyle="dashed", color="C0")
    axes[5][j].plot(parameter_values[j], data[0, j]["q50"]["transport_percentage_septal_wall"], linestyle="dashed", color="C1")
    axes[5][j].plot(parameter_values[j], data[0, j]["q50"]["transport_percentage_marginal_sinus"], linestyle="dashed", color="C2")
    axes[5][j].fill_between(parameter_values[j], data[0, j]["q25"]["transport_percentage_basal_plate"], data[0, j]["q75"]["transport_percentage_basal_plate"], alpha=0.2, color="C0")
    axes[5][j].fill_between(parameter_values[j], data[0, j]["q25"]["transport_percentage_septal_wall"], data[0, j]["q75"]["transport_percentage_septal_wall"], alpha=0.2, color="C1")
    axes[5][j].fill_between(parameter_values[j], data[0, j]["q25"]["transport_percentage_marginal_sinus"], data[0, j]["q75"]["transport_percentage_marginal_sinus"], alpha=0.2, color="C2")
    axes[5][j].legend(handles=handles[0:3], labels=["basal plate", "septal wall", "marginal sinus"])

  # AXES 7: Kinetic energy flux difference.
  for j in range(3):
    for i in range(2):
      if not (j == 2 and i > 0):
        axes[6][j].plot(parameter_values[j], data[i, j]["q50"]["kinetic_energy_flux"], linestyle="dashed", color=f"C{i}")
        axes[6][j].fill_between(parameter_values[j], data[i, j]["q25"]["kinetic_energy_flux"], data[i, j]["q75"]["kinetic_energy_flux"], alpha=0.2, color=f"C{i}")
  axes[6][0].legend(handles=handles[0:2], labels=["any veins", "27 veins"])
  axes[6][1].legend(handles=handles[0:2], labels=["any arteries", "6 arteries"])

  # AXES 8: Total energy flux difference.
  for j in range(3):
    for i in range(2):
      if not (j == 2 and i > 0):
        axes[7][j].plot(parameter_values[j], data[i, j]["q50"]["total_energy_flux"], linestyle="dashed", color=f"C{i}")
        axes[7][j].fill_between(parameter_values[j], data[i, j]["q25"]["total_energy_flux"], data[i, j]["q75"]["total_energy_flux"], alpha=0.2, color=f"C{i}")
  axes[7][0].legend(handles=handles[0:2], labels=["any veins", "27 veins"])
  axes[7][1].legend(handles=handles[0:2], labels=["any arteries", "6 arteries"])

  # Plot indiviudal simulations on mini axes.
  simulation_nos = [11, 28, 29, 100]
  colours = ["tab:orange", "tab:purple", "tab:green", "tab:red"]
  for i in range(4):
    sim_no = simulation_nos[i]

    no_arteries = simulations[sim_no-1].get_no_arteries()
    no_veins = simulations[sim_no-1].get_no_veins()

    axes_mini[0][0].plot(no_arteries,          simulations[sim_no-1].velocity_magnitude_integral_ivs, 'x', markersize=10, linewidth=3, color=colours[i])
    axes_mini[0][1].plot(no_veins,             simulations[sim_no-1].velocity_magnitude_integral_ivs, 'x', markersize=10, linewidth=3, color=colours[i])
    axes_mini[0][2].plot(no_veins/no_arteries, simulations[sim_no-1].velocity_magnitude_integral_ivs, 'x', markersize=10, linewidth=3, color=colours[i])

    axes_mini[1][0].plot(no_arteries,          simulations[sim_no-1].transport_reaction_integral,     'x', markersize=10, linewidth=3, color=colours[i])
    axes_mini[1][1].plot(no_veins,             simulations[sim_no-1].transport_reaction_integral,     'x', markersize=10, linewidth=3, color=colours[i])
    axes_mini[1][2].plot(no_veins/no_arteries, simulations[sim_no-1].transport_reaction_integral,     'x', markersize=10, linewidth=3, color=colours[i])

  # Style plots.
  setup_plots.style(fig, axes[0][0], None, r"$\bar{v}$", y_scilimits=[-3, -3] , y_bottom=0, y_top=1e-2, integer_ticks=True)
  setup_plots.style(fig, axes[1][0], None, r"$v_\text{slow}(V_\text{threshold})$", y_scilimits=None , y_top=102, integer_ticks=True)
  setup_plots.style(fig, axes[2][0], None, r"$\frac{v_\text{flux}(S)}{v_\text{flux}(\Gamma_\text{in})}$ (%)", y_scilimits=None , y_top=102, integer_ticks=True)
  setup_plots.style(fig, axes[3][0], None, r"$v_\text{cross}$", y_scilimits=[-3, -3] , y_bottom=0, y_top=2e-2, integer_ticks=True)
  setup_plots.style(fig, axes[4][0], None, r"$\bar{c}$", y_scilimits=[-3, -3], y_bottom=0, y_top=2e-3, integer_ticks=True)
  setup_plots.style(fig, axes[5][0], None, r"$\frac{C_\text{flux}(S)}{C_\text{flux}(\Gamma_\text{in})}$ (%)", y_scilimits=None , y_top=102, integer_ticks=True)
  setup_plots.style(fig, axes[6][0], None, r"$E_\text{kinetic}(\Gamma_\text{in}) - E_\text{kinetic}(\Gamma_\text{out})$", y_scilimits=[2, 2], y_bottom=0, y_top=1e2, integer_ticks=True, max_major_ticks=4)
  setup_plots.style(fig, axes[7][0], parameter_name[0], r"$E_\text{total}(\Gamma_\text{in}) - E_\text{total}(\Gamma_\text{out})$", y_scilimits=[3, 3], y_bottom=0, y_top=1.5e3, integer_ticks=True, max_major_ticks=4, y_labelpad=25)

  setup_plots.style(fig, axes[0][1], None, None, y_scilimits=[-3, -3], y_bottom=0, y_top=1e-2, integer_ticks=True, max_major_ticks=4)
  setup_plots.style(fig, axes[1][1], None, None, y_scilimits=None , y_top=102, integer_ticks=True, max_major_ticks=4)
  setup_plots.style(fig, axes[2][1], None, None, y_scilimits=None , y_top=102, integer_ticks=True, max_major_ticks=4)
  setup_plots.style(fig, axes[3][1], None, None, y_scilimits=[-3, -3], y_bottom=0, y_top=2e-2, integer_ticks=True, max_major_ticks=4)
  setup_plots.style(fig, axes[4][1], None, None, y_scilimits=[-3, -3], y_bottom=0, y_top=2e-3, integer_ticks=True, max_major_ticks=4)
  setup_plots.style(fig, axes[5][1], None, None, y_scilimits=None , y_top=102, integer_ticks=True, max_major_ticks=4)
  setup_plots.style(fig, axes[6][1], None, None, y_scilimits=[2, 2], y_bottom=0, y_top=1e2, integer_ticks=True, max_major_ticks=4)
  setup_plots.style(fig, axes[7][1], parameter_name[1], None, y_scilimits=[3, 3], y_bottom=0, y_top=1.5e3, integer_ticks=True, max_major_ticks=4)

  setup_plots.style(fig, axes[0][2], None, None, y_scilimits=[-3, -3], y_bottom=0, y_top=1e-2, integer_ticks=True, max_major_ticks=4)
  setup_plots.style(fig, axes[1][2], None, None, y_scilimits=None , y_top=102, integer_ticks=True, max_major_ticks=4)
  setup_plots.style(fig, axes[2][2], None, None, y_scilimits=None , y_top=102, integer_ticks=True, max_major_ticks=4)
  setup_plots.style(fig, axes[3][2], None, None, y_scilimits=[-3, -3], y_bottom=0, y_top=2e-2, integer_ticks=True, max_major_ticks=4)
  setup_plots.style(fig, axes[4][2], None, None, y_scilimits=[-3, -3], y_bottom=0, y_top=2e-3, integer_ticks=True, max_major_ticks=4)
  setup_plots.style(fig, axes[5][2], None, None, y_scilimits=None , y_top=102, integer_ticks=True, max_major_ticks=4)
  setup_plots.style(fig, axes[6][2], None, None, y_scilimits=[2, 2], y_bottom=0, y_top=1e2, integer_ticks=True, max_major_ticks=4)
  setup_plots.style(fig, axes[7][2], parameter_name[2], None, y_scilimits=[3, 3], y_bottom=0, y_top=1.5e3, integer_ticks=True, max_major_ticks=4)

  setup_plots.style(fig_mini, axes_mini[0][0], None, r"$\bar{v}$", y_scilimits=[-3, -3] , y_bottom=0, y_top=1e-2, integer_ticks=True)
  setup_plots.style(fig_mini, axes_mini[1][0], parameter_name[0], r"$\bar{c}$", y_scilimits=[-3, -3], y_bottom=0, y_top=2e-3, integer_ticks=True)

  setup_plots.style(fig_mini, axes_mini[0][1], None, None, y_scilimits=[-3, -3], y_bottom=0, y_top=1e-2, integer_ticks=True, max_major_ticks=4)
  setup_plots.style(fig_mini, axes_mini[1][1], parameter_name[1], None, y_scilimits=[-3, -3], y_bottom=0, y_top=2e-3, integer_ticks=True, max_major_ticks=4)

  setup_plots.style(fig_mini, axes_mini[0][2], None, None, y_scilimits=[-3, -3], y_bottom=0, y_top=1e-2, integer_ticks=True, max_major_ticks=4)
  setup_plots.style(fig_mini, axes_mini[1][2], parameter_name[2], None, y_scilimits=[-3, -3], y_bottom=0, y_top=2e-3, integer_ticks=True, max_major_ticks=4)

  # Decide where to save plots.
  if subfolder == None:
    images_folder = "images"
  else:
    images_folder = f"images/{subfolder}"

  # Save.
  fig.savefig(f"{images_folder}/mega_{parameter_safe_name[0]}_{parameter_safe_name[1]}_{parameter_safe_name[2]}.png", dpi=300)
  fig_mini.savefig(f"{images_folder}/mega-mini_{parameter_safe_name[0]}_{parameter_safe_name[1]}_{parameter_safe_name[2]}.png", dpi=300)

  # Done.
  print(f"\rPlotting simulations... Done.", end="\r\n")

  # Print number of subsamples in each bin.
  from tabulate import tabulate
  rows = []
  for j in range(3):
    for i in range(2):
      if not (j == 2 and i > 0):
        no_per_bin = [len(simulation_bins[j][i][k]) for k in range(0, len(simulation_bins[j][i]))]
        no_simulations = sum(no_per_bin)
        rows.append([parameter_name[j], no_simulations, np.mean(no_per_bin), np.median(no_per_bin), np.std(no_per_bin), np.min(no_per_bin), np.max(no_per_bin), no_per_bin])
  print(tabulate(rows, headers=["Name", "#", "Mean", "Median", "Std", "Minimum", "Maximum", "Number per bin"], tablefmt="rounded_outline", floatfmt=".2f"))