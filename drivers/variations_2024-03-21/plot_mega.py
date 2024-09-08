def plot_others(simulations, simulation_bins, parameter_values, parameter_name, parameter_safe_name, subfolder=None, plot_outliers=False):
  import numpy as np

  print(f"\rPlotting simulations...", end="")

  no_parameters = 7

  assert(len(parameter_values) == no_parameters)
  assert(len(simulation_bins) == no_parameters)
  assert(len(simulations) == no_parameters)

  # Setup plots.
  from plotting import setup_plots
  fig1, axes1 = setup_plots.setup_megaplot(1, 4, 3, figsize=(10, 12))
  fig2, axes2 = setup_plots.setup_megaplot(2, 4, 4, figsize=(13, 12))
  fig3, axes3 = setup_plots.setup_megaplot(3, 4, 3, figsize=(10, 12))
  fig4, axes4 = setup_plots.setup_megaplot(4, 4, 4, figsize=(13, 12))
  figs = [fig1, fig2, fig3, fig4]
  axes = [axes1, axes2, axes3, axes4]

  # Get data to plot.
  data = np.zeros(no_parameters, dtype=object)
  for j in range(no_parameters):
    data[j] = setup_plots.get_data(len(simulation_bins[j]), simulation_bins[j], simulations[j])

  # Patches for legends.
  import matplotlib.patches as mpatches
  max_no_patches = 4
  handles = []
  for i in range(max_no_patches):
    handles.append(mpatches.Patch(color=f"C{i}"))
  handles.append(mpatches.Patch(color="black"))

  ## The following loops are looped with:
  # i \in {0, 1}: splits the graphs into the first 4 measures and last 4 measures.
  # j \in {0, 1, 2, 3}: selects which parameter is being plotted on x-axis.

  # AXES 1: Velocity magnitude integrals.
  for i in range(2):
    for j in range(4):
      if (i, j) == (1, 0) or (i, j) == (1, 1) or (i, j) == (0, 3):
        continue

      if plot_outliers:
        for k in range(len(data[3*i+j]["outside_iqr"]["velocity_magnitude_integral"])):
          for l in range(len(data[3*i+j]["outside_iqr"]["velocity_magnitude_integral"][k])):
            axes[i][0][j].scatter(parameter_values[3*i+j][k], data[3*i+j]["outside_iqr"]["velocity_magnitude_integral"][k][l], marker=".", color=f"C0", alpha=1.0/10)

      axes[i][0][j].plot(parameter_values[3*i+j], data[3*i+j]["q50"]["velocity_magnitude_integral"], linestyle="dashed", color=f"C0")
      axes[i][0][j].fill_between(parameter_values[3*i+j], data[3*i+j]["q25"]["velocity_magnitude_integral"], data[3*i+j]["q75"]["velocity_magnitude_integral"], alpha=0.2, color=f"C0")

  # AXES 2: Slow velocity percentages.
  for i in range(2):
    for j in range(4):
      if (i, j) == (1, 0) or (i, j) == (1, 1) or (i, j) == (0, 3):
        continue

      if plot_outliers:
        for k in range(len(data[3*i+j]["outside_iqr"]["slow_velocity_percentage_ivs"])):
          for l in range(len(data[3*i+j]["outside_iqr"]["slow_velocity_percentage_ivs"][k])):
            axes[i][1][j].scatter(parameter_values[3*i+j][k], data[3*i+j]["outside_iqr"]["slow_velocity_percentage_ivs"][k][l], marker=".", color=f"C0", alpha=1.0/10)
        for k in range(len(data[3*i+j]["outside_iqr"]["slow_velocity_percentage_everywhere"])):
          for l in range(len(data[3*i+j]["outside_iqr"]["slow_velocity_percentage_everywhere"][k])):
            axes[i][1][j].scatter(parameter_values[3*i+j][k], data[3*i+j]["outside_iqr"]["slow_velocity_percentage_everywhere"][k][l], marker=".", color=f"C1", alpha=1.0/10)
        for k in range(len(data[3*i+j]["outside_iqr"]["slow_velocity_percentage_nominal_everywhere"])):
          for l in range(len(data[3*i+j]["outside_iqr"]["slow_velocity_percentage_nominal_everywhere"][k])):
            axes[i][1][j].scatter(parameter_values[3*i+j][k], data[3*i+j]["outside_iqr"]["slow_velocity_percentage_nominal_everywhere"][k][l], marker=".", color=f"C2", alpha=1.0/10)
        for k in range(len(data[3*i+j]["outside_iqr"]["slow_velocity_percentage_dellschaft"])):
          for l in range(len(data[3*i+j]["outside_iqr"]["slow_velocity_percentage_dellschaft"][k])):
            axes[i][1][j].scatter(parameter_values[3*i+j][k], data[3*i+j]["outside_iqr"]["slow_velocity_percentage_dellschaft"][k][l], marker=".", color=f"C3", alpha=1.0/10)
      axes[i][1][j].plot(parameter_values[3*i+j], data[3*i+j]["q50"]["slow_velocity_percentage_ivs"], linestyle="dashed", color="C0")
      axes[i][1][j].plot(parameter_values[3*i+j], data[3*i+j]["q50"]["slow_velocity_percentage_everywhere"], linestyle="dashed", color="C1")
      axes[i][1][j].plot(parameter_values[3*i+j], data[3*i+j]["q50"]["slow_velocity_percentage_nominal_everywhere"], linestyle="dashed", color="C2")
      axes[i][1][j].plot(parameter_values[3*i+j], data[3*i+j]["q50"]["slow_velocity_percentage_dellschaft"], linestyle="dashed", color="C3")
      axes[i][1][j].fill_between(parameter_values[3*i+j], data[3*i+j]["q25"]["slow_velocity_percentage_ivs"], data[3*i+j]["q75"]["slow_velocity_percentage_ivs"], alpha=0.2, color="C0")
      axes[i][1][j].fill_between(parameter_values[3*i+j], data[3*i+j]["q25"]["slow_velocity_percentage_everywhere"], data[3*i+j]["q75"]["slow_velocity_percentage_everywhere"], alpha=0.2, color="C1")
      axes[i][1][j].fill_between(parameter_values[3*i+j], data[3*i+j]["q25"]["slow_velocity_percentage_nominal_everywhere"], data[3*i+j]["q75"]["slow_velocity_percentage_nominal_everywhere"], alpha=0.2, color="C2")
      axes[i][1][j].fill_between(parameter_values[3*i+j], data[3*i+j]["q25"]["slow_velocity_percentage_dellschaft"], data[3*i+j]["q75"]["slow_velocity_percentage_dellschaft"], alpha=0.2, color="C3")
      axes[i][1][j].legend(handles=handles[0:4], labels=[r"$V_\text{threshold} = \bar{v}(\Omega_\text{IVS})$", r"$V_\text{threshold} = \bar{v}(\Omega)$", r"$V_\text{threshold} = 0.0026$", r"$V_\text{threshold} = 0.0005$"], loc="upper left")

  # AXES 3: Velocity flux through different veins.
  for i in range(2):
    for j in range(4):
      if (i, j) == (1, 0) or (i, j) == (1, 1) or (i, j) == (0, 3):
        continue

      if plot_outliers:
        for k in range(len(data[3*i+j]["outside_iqr"]["velocity_percentage_basal_plate"])):
          for l in range(len(data[3*i+j]["outside_iqr"]["velocity_percentage_basal_plate"][k])):
            axes[i][2][j].scatter(parameter_values[3*i+j][k], data[3*i+j]["outside_iqr"]["velocity_percentage_basal_plate"][k][l], marker=".", color=f"C0", alpha=1.0/10)
        # for k in range(len(data[3*i+j]["outside_iqr"]["velocity_percentage_septal_wall"])):
        #   for l in range(len(data[3*i+j]["outside_iqr"]["velocity_percentage_septal_wall"][k])):
        #     axes[i][2][j].scatter(parameter_values[3*i+j][k], data[3*i+j]["outside_iqr"]["velocity_percentage_septal_wall"][k][l], marker=".", color=f"C1", alpha=1.0/10)
        for k in range(len(data[3*i+j]["outside_iqr"]["velocity_percentage_marginal_sinus"])):
          for l in range(len(data[3*i+j]["outside_iqr"]["velocity_percentage_marginal_sinus"][k])):
            axes[i][2][j].scatter(parameter_values[3*i+j][k], data[3*i+j]["outside_iqr"]["velocity_percentage_marginal_sinus"][k][l], marker=".", color=f"C2", alpha=1.0/10)
      axes[i][2][j].plot(parameter_values[3*i+j], data[3*i+j]["q50"]["velocity_percentage_basal_plate"], linestyle="dashed", color="C0")
      # axes[i][2][j].plot(parameter_values[3*i+j], data[3*i+j]["q50"]["velocity_percentage_septal_wall"], linestyle="dashed", color="C1")
      axes[i][2][j].plot(parameter_values[3*i+j], data[3*i+j]["q50"]["velocity_percentage_marginal_sinus"], linestyle="dashed", color="C2")
      axes[i][2][j].fill_between(parameter_values[3*i+j], data[3*i+j]["q25"]["velocity_percentage_basal_plate"], data[3*i+j]["q75"]["velocity_percentage_basal_plate"], alpha=0.2, color="C0")
      # axes[i][2][j].fill_between(parameter_values[3*i+j], data[3*i+j]["q25"]["velocity_percentage_septal_wall"], data[3*i+j]["q75"]["velocity_percentage_septal_wall"], alpha=0.2, color="C1")
      axes[i][2][j].fill_between(parameter_values[3*i+j], data[3*i+j]["q25"]["velocity_percentage_marginal_sinus"], data[3*i+j]["q75"]["velocity_percentage_marginal_sinus"], alpha=0.2, color="C2")
      axes[i][2][j].legend(handles=[handles[0], handles[2]], labels=[r"$S = \Gamma_\text{out,bp}$", r"$S = \Gamma_\text{out,ms}$"], loc="center left")

  # AXES 4: Cross-flux velocity.
  for i in range(2):
    for j in range(4):
      if (i, j) == (1, 0) or (i, j) == (1, 1) or (i, j) == (0, 3):
        continue

      if plot_outliers:
        for k in range(len(data[3*i+j]["outside_iqr"]["velocity_cross_flow_flux"])):
          for l in range(len(data[3*i+j]["outside_iqr"]["velocity_cross_flow_flux"][k])):
            axes[i][3][j].scatter(parameter_values[3*i+j][k], data[3*i+j]["outside_iqr"]["velocity_cross_flow_flux"][k][l], marker=".", color=f"C0", alpha=1.0/10)
      axes[i][3][j].plot(parameter_values[3*i+j], data[3*i+j]["q50"]["velocity_cross_flow_flux"], linestyle="dashed", color=f"C0")
      axes[i][3][j].fill_between(parameter_values[3*i+j], data[3*i+j]["q25"]["velocity_cross_flow_flux"], data[3*i+j]["q75"]["velocity_cross_flow_flux"], alpha=0.2, color=f"C0")

  # AXES 5: Transport reaction integral.
  for i in range(2):
    for j in range(4):
      if (i, j) == (0, 3):
        continue

      if plot_outliers:
        for k in range(len(data[3*i+j]["outside_iqr"]["transport_reaction_integral"])):
          for l in range(len(data[3*i+j]["outside_iqr"]["transport_reaction_integral"][k])):
            axes[i+2][0][j].scatter(parameter_values[3*i+j][k], data[3*i+j]["outside_iqr"]["transport_reaction_integral"][k][l], marker=".", color=f"C0", alpha=1.0/10)

      axes[i+2][0][j].plot(parameter_values[3*i+j], data[3*i+j]["q50"]["transport_reaction_integral"], linestyle="dashed", color=f"C0")
      axes[i+2][0][j].fill_between(parameter_values[3*i+j], data[3*i+j]["q25"]["transport_reaction_integral"], data[3*i+j]["q75"]["transport_reaction_integral"], alpha=0.2, color=f"C0")

  # AXES 6: Concentration flux through different veins.
  for i in range(2):
    for j in range(4):
      if (i, j) == (0, 3):
        continue

      if plot_outliers:
        for k in range(len(data[3*i+j]["outside_iqr"]["transport_percentage_basal_plate"])):
          for l in range(len(data[3*i+j]["outside_iqr"]["transport_percentage_basal_plate"][k])):
            axes[i+2][1][j].scatter(parameter_values[3*i+j][k], data[3*i+j]["outside_iqr"]["transport_percentage_basal_plate"][k][l], marker=".", color=f"C0", alpha=1.0/10)
        # for k in range(len(data[3*i+j]["outside_iqr"]["transport_percentage_septal_wall"])):
        #   for l in range(len(data[3*i+j]["outside_iqr"]["transport_percentage_septal_wall"][k])):
        #     axes[i+2][1][j].scatter(parameter_values[3*i+j][k], data[3*i+j]["outside_iqr"]["transport_percentage_septal_wall"][k][l], marker=".", color=f"C1", alpha=1.0/10)
        for k in range(len(data[3*i+j]["outside_iqr"]["transport_percentage_marginal_sinus"])):
          for l in range(len(data[3*i+j]["outside_iqr"]["transport_percentage_marginal_sinus"][k])):
            axes[i+2][1][j].scatter(parameter_values[3*i+j][k], data[3*i+j]["outside_iqr"]["transport_percentage_marginal_sinus"][k][l], marker=".", color=f"C2", alpha=1.0/10)

      axes[i+2][1][j].plot(parameter_values[3*i+j], data[3*i+j]["q50"]["transport_percentage_basal_plate"], linestyle="dashed", color="C0")
      # axes[i+2][1][j].plot(parameter_values[3*i+j], data[3*i+j]["q50"]["transport_percentage_septal_wall"], linestyle="dashed", color="C1")
      axes[i+2][1][j].plot(parameter_values[3*i+j], data[3*i+j]["q50"]["transport_percentage_marginal_sinus"], linestyle="dashed", color="C2")
      # axes[i+2][1][j].plot(parameter_values[3*i+j], data[3*i+j]["q50"]["transport_percentage_basal_plate"] + data[3*i+j]["q50"]["transport_percentage_septal_wall"] + data[3*i+j]["q50"]["transport_percentage_marginal_sinus"], linestyle="dashed", color="black")
      axes[i+2][1][j].fill_between(parameter_values[3*i+j], data[3*i+j]["q25"]["transport_percentage_basal_plate"], data[3*i+j]["q75"]["transport_percentage_basal_plate"], alpha=0.2, color="C0")
      # axes[i+2][1][j].fill_between(parameter_values[3*i+j], data[3*i+j]["q25"]["transport_percentage_septal_wall"], data[3*i+j]["q75"]["transport_percentage_septal_wall"], alpha=0.2, color="C1")
      axes[i+2][1][j].fill_between(parameter_values[3*i+j], data[3*i+j]["q25"]["transport_percentage_marginal_sinus"], data[3*i+j]["q75"]["transport_percentage_marginal_sinus"], alpha=0.2, color="C2")
      axes[i+2][1][j].legend(handles=[handles[0], handles[2]], labels=[r"$S = \Gamma_\text{out,bp}$", r"$S = \Gamma_\text{out,ms}$"], loc="center left")

  # AXES 7: Kinetic energy flux difference.
  for i in range(2):
    for j in range(4):
      if (i, j) == (1, 0) or (i, j) == (1, 1) or (i, j) == (0, 3):
        continue

      if plot_outliers:
        for k in range(len(data[3*i+j]["outside_iqr"]["kinetic_energy_flux"])):
          for l in range(len(data[3*i+j]["outside_iqr"]["kinetic_energy_flux"][k])):
            axes[i+2][2][j].scatter(parameter_values[3*i+j][k], data[3*i+j]["data"]["kinetic_energy_flux"][k][l], marker=".", color=f"C0", alpha=1.0/10)

      axes[i+2][2][j].plot(parameter_values[3*i+j], data[3*i+j]["q50"]["kinetic_energy_flux"], linestyle="dashed", color=f"C0")
      axes[i+2][2][j].fill_between(parameter_values[3*i+j], data[3*i+j]["q25"]["kinetic_energy_flux"], data[3*i+j]["q75"]["kinetic_energy_flux"], alpha=0.2, color=f"C0")  

  # AXES 8: Total energy flux difference.
  for i in range(2):
    for j in range(4):
      if (i, j) == (1, 0) or (i, j) == (1, 1) or (i, j) == (0, 3):
        continue

      if plot_outliers:
        for k in range(len(data[3*i+j]["outside_iqr"]["total_energy_flux"])):
          for l in range(len(data[3*i+j]["outside_iqr"]["total_energy_flux"][k])):
            axes[i+2][3][j].scatter(parameter_values[3*i+j][k], data[3*i+j]["data"]["total_energy_flux"][k][l], marker=".", color=f"C0", alpha=1.0/10)

      axes[i+2][3][j].plot(parameter_values[3*i+j], data[3*i+j]["q50"]["total_energy_flux"], linestyle="dashed", color=f"C0")
      axes[i+2][3][j].fill_between(parameter_values[3*i+j], data[3*i+j]["q25"]["total_energy_flux"], data[3*i+j]["q75"]["total_energy_flux"], alpha=0.2, color=f"C0")

  # Style plots.
  setup_plots.style(fig1, axes1[0][0], None, r"$\bar{v}$", y_scilimits=[-3, -3] , y_bottom=0, y_top=1e-2, integer_ticks=False, max_major_ticks=2, max_minor_ticks=6, y_max_minor_ticks=11)
  setup_plots.style(fig1, axes1[1][0], None, r"$v_\text{slow}(V_\text{threshold})$ (%)", y_scilimits=None, y_bottom=0, y_top=70, integer_ticks=False, max_major_ticks=2, max_minor_ticks=6, y_max_minor_ticks=8)
  setup_plots.style(fig1, axes1[2][0], None, r"$\frac{v_\text{flux}(S)}{v_\text{flux}(\Gamma_\text{in})}$ (%)", y_scilimits=None , y_bottom=0, y_top=102, integer_ticks=False, max_major_ticks=2, max_minor_ticks=6, y_max_minor_ticks=11)
  setup_plots.style(fig1, axes1[3][0], parameter_name[0], r"$v_\text{cross}$", y_scilimits=[-3, -3] , y_bottom=0, y_top=3e-3, integer_ticks=False, max_major_ticks=2, max_minor_ticks=6, y_max_minor_ticks=7)
  setup_plots.style(fig3, axes3[0][0], None, r"$\bar{c}$", y_scilimits=[-3, -3], y_bottom=0, y_top=1.2e-3, integer_ticks=False, max_major_ticks=2, max_minor_ticks=6, y_max_minor_ticks=13)
  setup_plots.style(fig3, axes3[1][0], None, r"$\frac{C_\text{flux}(S)}{C_\text{flux}(\Gamma_\text{in})}$ (%)", y_scilimits=None , y_bottom=0, y_top=102, integer_ticks=False, max_major_ticks=2, max_minor_ticks=6, y_max_minor_ticks=11)
  setup_plots.style(fig3, axes3[2][0], None, r"$\frac{E_\text{kinetic}(\Gamma_\text{in}) - E_\text{kinetic}(\Gamma_\text{out})}{E_\text{kinetic}(\Gamma_\text{in})}$", y_scilimits=None, y_bottom=0.6, y_top=1.02, integer_ticks=False, max_major_ticks=2, max_minor_ticks=6)
  setup_plots.style(fig3, axes3[3][0], parameter_name[0], r"$\frac{E_\text{total}(\Gamma_\text{in}) - E_\text{total}(\Gamma_\text{out})}{E_\text{total}(\Gamma_\text{in})}$", y_scilimits=None, y_bottom=0.95, y_top=1.001, integer_ticks=False, max_major_ticks=2, max_minor_ticks=6, y_max_minor_ticks=6)

  setup_plots.style(fig1, axes1[0][1], None, None, y_scilimits=[-3, -3], y_bottom=0, y_top=1e-2, integer_ticks=False, max_major_ticks=2, max_minor_ticks=5, y_max_minor_ticks=11)
  setup_plots.style(fig1, axes1[1][1], None, None, y_scilimits=None , y_bottom=0, y_top=70, integer_ticks=False, max_major_ticks=2, max_minor_ticks=5, y_max_minor_ticks=8)
  setup_plots.style(fig1, axes1[2][1], None, None, y_scilimits=None , y_bottom=0, y_top=102, integer_ticks=False, max_major_ticks=2, max_minor_ticks=5, y_max_minor_ticks=11)
  setup_plots.style(fig1, axes1[3][1], parameter_name[1], None, y_scilimits=[-3, -3], y_bottom=0, y_top=3e-3, integer_ticks=False, max_major_ticks=2, max_minor_ticks=5, y_max_minor_ticks=7)
  setup_plots.style(fig3, axes3[0][1], None, None, y_scilimits=[-3, -3], y_bottom=0, y_top=1.2e-3, integer_ticks=False, max_major_ticks=2, max_minor_ticks=5, y_max_minor_ticks=13)
  setup_plots.style(fig3, axes3[1][1], None, None, y_scilimits=None , y_bottom=0, y_top=102, integer_ticks=False, max_major_ticks=2, max_minor_ticks=5, y_max_minor_ticks=11)
  setup_plots.style(fig3, axes3[2][1], None, None, y_scilimits=None, y_bottom=0.6, y_top=1.02, integer_ticks=False, max_major_ticks=2, max_minor_ticks=5)
  setup_plots.style(fig3, axes3[3][1], parameter_name[1], None, y_scilimits=None, y_bottom=0.95, y_top=1.001, integer_ticks=False, max_major_ticks=2, max_minor_ticks=5, y_max_minor_ticks=6)

  setup_plots.style(fig1, axes1[0][2], None, None, y_scilimits=[-3, -3], y_bottom=0, y_top=1e-2, integer_ticks=False, max_major_ticks=2, max_minor_ticks=4, y_max_minor_ticks=11)
  setup_plots.style(fig1, axes1[1][2], None, None, y_scilimits=None , y_bottom=0, y_top=70, integer_ticks=False, max_major_ticks=2, max_minor_ticks=4, y_max_minor_ticks=8)
  setup_plots.style(fig1, axes1[2][2], None, None, y_scilimits=None , y_bottom=0, y_top=102, integer_ticks=False, max_major_ticks=2, max_minor_ticks=4, y_max_minor_ticks=11)
  setup_plots.style(fig1, axes1[3][2], parameter_name[2], None, y_scilimits=[-3, -3], y_bottom=0, y_top=3e-3, integer_ticks=False, max_major_ticks=2, max_minor_ticks=4, y_max_minor_ticks=7)
  setup_plots.style(fig3, axes3[0][2], None, None, y_scilimits=[-3, -3], y_bottom=0, y_top=1.2e-3, integer_ticks=False, max_major_ticks=2, max_minor_ticks=4, y_max_minor_ticks=13)
  setup_plots.style(fig3, axes3[1][2], None, None, y_scilimits=None , y_bottom=0, y_top=102, integer_ticks=False, max_major_ticks=2, max_minor_ticks=4, y_max_minor_ticks=11)
  setup_plots.style(fig3, axes3[2][2], None, None, y_scilimits=None, y_bottom=0.6, y_top=1.02, integer_ticks=False, max_major_ticks=2, max_minor_ticks=4)
  setup_plots.style(fig3, axes3[3][2], parameter_name[2], None, y_scilimits=None, y_bottom=0.95, y_top=1.001, integer_ticks=False, max_major_ticks=2, max_minor_ticks=4, y_max_minor_ticks=6)

  setup_plots.style(fig2, axes2[0][0], None, r"$\bar{v}$", y_scilimits=[-3, -3], y_bottom=0, y_top=1e-2, integer_ticks=False, max_major_ticks=2, max_minor_ticks=0, y_max_minor_ticks=0)
  setup_plots.style(fig2, axes2[1][0], None, r"$v_\text{slow}(V_\text{threshold})$ (%)", y_scilimits=None , y_bottom=0, y_top=70, integer_ticks=False, max_major_ticks=2, max_minor_ticks=0, y_max_minor_ticks=0)
  setup_plots.style(fig2, axes2[2][0], None, r"$\frac{v_\text{flux}(S)}{v_\text{flux}(\Gamma_\text{in})}$ (%)", y_scilimits=None , y_bottom=0, y_top=102, integer_ticks=False, max_major_ticks=2, max_minor_ticks=0, y_max_minor_ticks=0)
  setup_plots.style(fig2, axes2[3][0], parameter_name[3], r"$v_\text{cross}$", y_scilimits=[-3, -3], y_bottom=0, y_top=3e-3, integer_ticks=False, max_major_ticks=2, max_minor_ticks=0, y_max_minor_ticks=0)
  setup_plots.style(fig4, axes4[0][0], None, r"$\bar{c}$", y_scilimits=[-3, -3], y_bottom=0, y_top=1.2e-3, integer_ticks=False, max_major_ticks=2, max_minor_ticks=10, y_max_minor_ticks=13)
  setup_plots.style(fig4, axes4[1][0], None, r"$\frac{C_\text{flux}(S)}{C_\text{flux}(\Gamma_\text{in})}$ (%)", y_scilimits=None , y_bottom=0, y_top=102, integer_ticks=False, max_major_ticks=2, max_minor_ticks=10, y_max_minor_ticks=11)
  setup_plots.style(fig4, axes4[2][0], None, r"$\frac{E_\text{kinetic}(\Gamma_\text{in}) - E_\text{kinetic}(\Gamma_\text{out})}{E_\text{kinetic}(\Gamma_\text{in})}$", y_scilimits=None, y_bottom=0.6, y_top=1.02, integer_ticks=False, max_major_ticks=2, max_minor_ticks=0, y_max_minor_ticks=0)
  setup_plots.style(fig4, axes4[3][0], parameter_name[3], r"$\frac{E_\text{total}(\Gamma_\text{in}) - E_\text{total}(\Gamma_\text{out})}{E_\text{total}(\Gamma_\text{in})}$", y_scilimits=None, y_bottom=0.95, y_top=1.001, integer_ticks=False, max_major_ticks=2, max_minor_ticks=0, y_max_minor_ticks=0)

  setup_plots.style(fig2, axes2[0][1], None, None, y_scilimits=[-3, -3], y_bottom=0, y_top=1e-2, integer_ticks=False, max_major_ticks=2, max_minor_ticks=0, y_max_minor_ticks=0)
  setup_plots.style(fig2, axes2[1][1], None, None, y_scilimits=None , y_bottom=0, y_top=70, integer_ticks=False, max_major_ticks=2, max_minor_ticks=0, y_max_minor_ticks=0)
  setup_plots.style(fig2, axes2[2][1], None, None, y_scilimits=None , y_bottom=0, y_top=102, integer_ticks=False, max_major_ticks=2, max_minor_ticks=0, y_max_minor_ticks=0)
  setup_plots.style(fig2, axes2[3][1], parameter_name[4], None, y_scilimits=[-3, -3], y_bottom=0, y_top=3e-3, integer_ticks=False, max_major_ticks=2, max_minor_ticks=0, y_max_minor_ticks=0)
  setup_plots.style(fig4, axes4[0][1], None, None, y_scilimits=[-3, -3], y_bottom=0, y_top=1.2e-3, integer_ticks=False, max_major_ticks=2, max_minor_ticks=10, y_max_minor_ticks=0)
  setup_plots.style(fig4, axes4[1][1], None, None, y_scilimits=None , y_bottom=0, y_top=102, integer_ticks=False, max_major_ticks=2, max_minor_ticks=10, y_max_minor_ticks=0)
  setup_plots.style(fig4, axes4[2][1], None, None, y_scilimits=None, y_bottom=0.6, y_top=1.02, integer_ticks=False, max_major_ticks=2, max_minor_ticks=0, y_max_minor_ticks=0)
  setup_plots.style(fig4, axes4[3][1], parameter_name[4], None, y_scilimits=None, y_bottom=0.95, y_top=1.001, integer_ticks=False, max_major_ticks=2, max_minor_ticks=0, y_max_minor_ticks=0)

  setup_plots.style(fig2, axes2[0][2], None, None, y_scilimits=[-3, -3], y_bottom=0, y_top=1e-2, integer_ticks=True, max_major_ticks=5, y_max_minor_ticks=11)
  setup_plots.style(fig2, axes2[1][2], None, None, y_scilimits=None , y_bottom=0, y_top=70, integer_ticks=True, max_major_ticks=5, y_max_minor_ticks=8)
  setup_plots.style(fig2, axes2[2][2], None, None, y_scilimits=None , y_bottom=0, y_top=102, integer_ticks=True, max_major_ticks=5, y_max_minor_ticks=11)
  setup_plots.style(fig2, axes2[3][2], parameter_name[5], None, y_scilimits=[-3, -3], y_bottom=0, y_top=3e-3, integer_ticks=True, max_major_ticks=5, y_max_minor_ticks=7)
  setup_plots.style(fig4, axes4[0][2], None, None, y_scilimits=[-3, -3], y_bottom=0, y_top=1.2e-3, integer_ticks=True, max_major_ticks=5, y_max_minor_ticks=13)
  setup_plots.style(fig4, axes4[1][2], None, None, y_scilimits=None , y_bottom=0, y_top=102, integer_ticks=True, max_major_ticks=5, y_max_minor_ticks=11)
  setup_plots.style(fig4, axes4[2][2], None, None, y_scilimits=None, y_bottom=0.6, y_top=1.02, integer_ticks=True, max_major_ticks=5)
  setup_plots.style(fig4, axes4[3][2], parameter_name[5], None, y_scilimits=None, y_bottom=0.95, y_top=1.001, integer_ticks=True, max_major_ticks=5, y_max_minor_ticks=6)

  setup_plots.style(fig2, axes2[0][3], None, None, y_scilimits=[-3, -3], y_bottom=0, y_top=1e-2, integer_ticks=False, max_major_ticks=3, max_minor_ticks=11, y_max_minor_ticks=0)
  setup_plots.style(fig2, axes2[1][3], None, None, y_scilimits=None , y_bottom=0, y_top=70, integer_ticks=False, max_major_ticks=3, max_minor_ticks=11, y_max_minor_ticks=0)
  setup_plots.style(fig2, axes2[2][3], None, None, y_scilimits=None , y_bottom=0, y_top=102, integer_ticks=False, max_major_ticks=3, max_minor_ticks=11, y_max_minor_ticks=0)
  setup_plots.style(fig2, axes2[3][3], parameter_name[6], None, y_scilimits=[-3, -3], y_bottom=0, y_top=3e-3, integer_ticks=False, max_major_ticks=3, max_minor_ticks=11, y_max_minor_ticks=0)
  setup_plots.style(fig4, axes4[0][3], None, None, y_scilimits=[-3, -3], y_bottom=0, y_top=1.2e-3, integer_ticks=False, max_major_ticks=3, max_minor_ticks=11, y_max_minor_ticks=13)
  setup_plots.style(fig4, axes4[1][3], None, None, y_scilimits=None , y_bottom=0, y_top=102, integer_ticks=False, max_major_ticks=3, max_minor_ticks=11, y_max_minor_ticks=11)
  setup_plots.style(fig4, axes4[2][3], None, None, y_scilimits=None, y_bottom=0.6, y_top=1.02, integer_ticks=False, max_major_ticks=3, max_minor_ticks=11, y_max_minor_ticks=0)
  setup_plots.style(fig4, axes4[3][3], parameter_name[6], None, y_scilimits=None, y_bottom=0.95, y_top=1.001, integer_ticks=False, max_major_ticks=3, max_minor_ticks=11, y_max_minor_ticks=0)

  # Hide irrelevant plots.
  import matplotlib.pyplot as plt
  for i in [0, 1, 2, 3]:
    for j in [0, 1]:
      plt.setp(axes2[i][j].spines.values(), visible=False)
      plt.setp(axes2[i][j].get_xticklabels(), visible=False)
      plt.setp(axes2[i][j].get_yticklabels(), visible=False)
      axes2[i][j].set_xticks([])
      axes2[i][j].set_yticks([])
      axes2[i][j].annotate("No variation", xy=(0.5, 0.5), xycoords="axes fraction", ha="center", va="center", fontsize=12)
  for i in [2, 3]:
    for j in [0, 1]:
      plt.setp(axes4[i][j].spines.values(), visible=False)
      plt.setp(axes4[i][j].get_xticklabels(), visible=False)
      plt.setp(axes4[i][j].get_yticklabels(), visible=False)
      axes4[i][j].set_xticks([])
      axes4[i][j].set_yticks([])
      axes4[i][j].annotate("No variation", xy=(0.5, 0.5), xycoords="axes fraction", ha="center", va="center", fontsize=12)

  # Decide where to save plots.
  if subfolder == None:
    images_folder = "images"
  else:
    images_folder = f"images/{subfolder}"

  # Save.
  fig1.savefig(f"{images_folder}/mega1_{parameter_safe_name[0]}_{parameter_safe_name[1]}_{parameter_safe_name[2]}.png", dpi=300)
  fig3.savefig(f"{images_folder}/mega2_{parameter_safe_name[0]}_{parameter_safe_name[1]}_{parameter_safe_name[2]}.png", dpi=300)
  fig2.savefig(f"{images_folder}/mega1_{parameter_safe_name[3]}_{parameter_safe_name[4]}_{parameter_safe_name[5]}_{parameter_safe_name[6]}.png", dpi=300)
  fig4.savefig(f"{images_folder}/mega2_{parameter_safe_name[3]}_{parameter_safe_name[4]}_{parameter_safe_name[5]}_{parameter_safe_name[6]}.png", dpi=300)

  # Done.
  print(f"\rPlotting simulations... Done.", end="\r\n")

  # Print number of subsamples in each bin.
  from tabulate import tabulate
  rows = []
  for j in range(no_parameters):
    no_per_bin = [len(simulation_bins[j][k]) for k in range(0, len(simulation_bins[j]))]
    no_simulations = sum(no_per_bin)
    rows.append([parameter_name[j], no_simulations, np.mean(no_per_bin), np.median(no_per_bin), np.std(no_per_bin), np.min(no_per_bin), np.max(no_per_bin), no_per_bin])
  print(tabulate(rows, headers=["Name", "#", "Mean", "Median", "Std", "Minimum", "Maximum", "Number per bin"], tablefmt="rounded_outline", floatfmt=".2f"))

def plot_vessels(simulations, simulation_bins, parameter_values, parameter_name, parameter_safe_name, subfolder=None, plot_outliers=False):
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
  figs = [[] for i in range(5)]
  axes = [[] for i in range(5)]
  figs[0], axes[0] = setup_plots.setup_megaplot(1, 2, 3, figsize=(10, 6))
  figs[1], axes[1] = setup_plots.setup_megaplot(2, 1, 3, figsize=(10, 4))
  figs[2], axes[2] = setup_plots.setup_megaplot(3, 2, 3, figsize=(10, 6))
  figs[3], axes[3] = setup_plots.setup_megaplot(4, 1, 3, figsize=(10, 3))
  figs[4], axes[4] = setup_plots.setup_megaplot(5, 2, 3, figsize=(10, 6))

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
  handles.append(mpatches.Patch(color="black"))

  # AXES 1: Velocity magnitude integrals.
  for j in range(3):
    for i in range(2):
      if not (j == 2 and i > 0):
        if plot_outliers:
          for k in range(len(data[i, j]["outside_iqr"]["velocity_magnitude_integral"])):
            for l in range(len(data[i, j]["outside_iqr"]["velocity_magnitude_integral"][k])):
              axes[0][0][j].scatter(parameter_values[j][k], data[i, j]["outside_iqr"]["velocity_magnitude_integral"][k][l], marker=".", color=f"C{i}", alpha=1.0/10)

        axes[0][0][j].plot(parameter_values[j], data[i, j]["q50"]["velocity_magnitude_integral"], linestyle="dashed", color=f"C{i}")
        axes[0][0][j].fill_between(parameter_values[j], data[i, j]["q25"]["velocity_magnitude_integral"], data[i, j]["q75"]["velocity_magnitude_integral"], alpha=0.2, color=f"C{i}")
    # if plot_outliers:
    #   for k in range(len(data[0, j]["outside_iqr"]["velocity_magnitude_integral"])):
    #     for l in range(len(data[0, j]["outside_iqr"]["velocity_magnitude_integral"][k])):
    #       axes_mini[0][j].scatter(parameter_values[j][k], data[0, j]["outside_iqr"]["velocity_magnitude_integral"][k][l], marker=".", color=f"C0", alpha=1.0/10)
    # axes_mini[0][j].plot(parameter_values[j], data[0, j]["q50"]["velocity_magnitude_integral"], linestyle="dashed", color=f"C0")
    # axes_mini[0][j].fill_between(parameter_values[j], data[0, j]["q25"]["velocity_magnitude_integral"], data[0, j]["q75"]["velocity_magnitude_integral"], alpha=0.2, color=f"C0")
    
  axes[0][0][0].legend(handles=handles[0:2], labels=[r"any $N_\text{V}$", r"$N_\text{V} = 27$"])
  axes[0][0][1].legend(handles=handles[0:2], labels=[r"any $N_\text{A}$", r"$N_\text{A} = 6$"])

  # AXES 2: Slow velocity percentages.
  for j in range(3):
    if plot_outliers:
      for k in range(len(data[0, j]["outside_iqr"]["slow_velocity_percentage_ivs"])):
        for l in range(len(data[0, j]["outside_iqr"]["slow_velocity_percentage_ivs"][k])):
          axes[1][0][j].scatter(parameter_values[j][k], data[0, j]["outside_iqr"]["slow_velocity_percentage_ivs"][k][l], marker=".", color=f"C0", alpha=1.0/10)
      for k in range(len(data[0, j]["outside_iqr"]["slow_velocity_percentage_everywhere"])):
        for l in range(len(data[0, j]["outside_iqr"]["slow_velocity_percentage_everywhere"][k])):
          axes[1][0][j].scatter(parameter_values[j][k], data[0, j]["outside_iqr"]["slow_velocity_percentage_everywhere"][k][l], marker=".", color=f"C1", alpha=1.0/10)
      for k in range(len(data[0, j]["outside_iqr"]["slow_velocity_percentage_nominal_everywhere"])):
        for l in range(len(data[0, j]["outside_iqr"]["slow_velocity_percentage_nominal_everywhere"][k])):
          axes[1][0][j].scatter(parameter_values[j][k], data[0, j]["outside_iqr"]["slow_velocity_percentage_nominal_everywhere"][k][l], marker=".", color=f"C2", alpha=1.0/10)
      for k in range(len(data[0, j]["outside_iqr"]["slow_velocity_percentage_dellschaft"])):
        for l in range(len(data[0, j]["outside_iqr"]["slow_velocity_percentage_dellschaft"][k])):
          axes[1][0][j].scatter(parameter_values[j][k], data[0, j]["outside_iqr"]["slow_velocity_percentage_dellschaft"][k][l], marker=".", color=f"C3", alpha=1.0/10)
    axes[1][0][j].plot(parameter_values[j], data[0, j]["q50"]["slow_velocity_percentage_ivs"], linestyle="dashed", color="C0")
    axes[1][0][j].plot(parameter_values[j], data[0, j]["q50"]["slow_velocity_percentage_everywhere"], linestyle="dashed", color="C1")
    axes[1][0][j].plot(parameter_values[j], data[0, j]["q50"]["slow_velocity_percentage_nominal_everywhere"], linestyle="dashed", color="C2")
    axes[1][0][j].plot(parameter_values[j], data[0, j]["q50"]["slow_velocity_percentage_dellschaft"], linestyle="dashed", color="C3")
    axes[1][0][j].fill_between(parameter_values[j], data[0, j]["q25"]["slow_velocity_percentage_ivs"], data[0, j]["q75"]["slow_velocity_percentage_ivs"], alpha=0.2, color="C0")
    axes[1][0][j].fill_between(parameter_values[j], data[0, j]["q25"]["slow_velocity_percentage_everywhere"], data[0, j]["q75"]["slow_velocity_percentage_everywhere"], alpha=0.2, color="C1")
    axes[1][0][j].fill_between(parameter_values[j], data[0, j]["q25"]["slow_velocity_percentage_nominal_everywhere"], data[0, j]["q75"]["slow_velocity_percentage_nominal_everywhere"], alpha=0.2, color="C2")
    axes[1][0][j].fill_between(parameter_values[j], data[0, j]["q25"]["slow_velocity_percentage_dellschaft"], data[0, j]["q75"]["slow_velocity_percentage_dellschaft"], alpha=0.2, color="C3")
  axes[1][0][1].legend(handles=handles[0:4], labels=[r"$V_\text{threshold} = \bar{v}(\Omega_\text{IVS})$", r"$V_\text{threshold} = \bar{v}(\Omega)$", r"$V_\text{threshold} = 0.0026$", r"$V_\text{threshold} = 0.0005$"], bbox_to_anchor=(-(2.25-1)/2, 1.05, 2.25, 0.2), loc="lower center", mode="expand", ncol=2, fontsize=14)

  # AXES 3: Velocity flux through different veins.
  for j in range(3):
    if plot_outliers:
      for k in range(len(data[0, j]["outside_iqr"]["velocity_percentage_basal_plate"])):
        for l in range(len(data[0, j]["outside_iqr"]["velocity_percentage_basal_plate"][k])):
          axes[2][0][j].scatter(parameter_values[j][k], data[0, j]["outside_iqr"]["velocity_percentage_basal_plate"][k][l], marker=".", color=f"C0", alpha=1.0/10)
      for k in range(len(data[0, j]["outside_iqr"]["velocity_percentage_septal_wall"])):
        for l in range(len(data[0, j]["outside_iqr"]["velocity_percentage_septal_wall"][k])):
          axes[2][0][j].scatter(parameter_values[j][k], data[0, j]["outside_iqr"]["velocity_percentage_septal_wall"][k][l], marker=".", color=f"C1", alpha=1.0/10)
      for k in range(len(data[0, j]["outside_iqr"]["velocity_percentage_marginal_sinus"])):
        for l in range(len(data[0, j]["outside_iqr"]["velocity_percentage_marginal_sinus"][k])):
          axes[2][0][j].scatter(parameter_values[j][k], data[0, j]["outside_iqr"]["velocity_percentage_marginal_sinus"][k][l], marker=".", color=f"C2", alpha=1.0/10)
    axes[2][0][j].plot(parameter_values[j], data[0, j]["q50"]["velocity_percentage_basal_plate"], linestyle="dashed", color="C0")
    axes[2][0][j].plot(parameter_values[j], data[0, j]["q50"]["velocity_percentage_septal_wall"], linestyle="dashed", color="C1")
    axes[2][0][j].plot(parameter_values[j], data[0, j]["q50"]["velocity_percentage_marginal_sinus"], linestyle="dashed", color="C2")
    axes[2][0][j].fill_between(parameter_values[j], data[0, j]["q25"]["velocity_percentage_basal_plate"], data[0, j]["q75"]["velocity_percentage_basal_plate"], alpha=0.2, color="C0")
    axes[2][0][j].fill_between(parameter_values[j], data[0, j]["q25"]["velocity_percentage_septal_wall"], data[0, j]["q75"]["velocity_percentage_septal_wall"], alpha=0.2, color="C1")
    axes[2][0][j].fill_between(parameter_values[j], data[0, j]["q25"]["velocity_percentage_marginal_sinus"], data[0, j]["q75"]["velocity_percentage_marginal_sinus"], alpha=0.2, color="C2")
  axes[2][0][1].legend(handles=handles[0:3], labels=[r"$S = \Gamma_\text{out,bp}$", r"$S = \Gamma_\text{out,sw}$", r"$S = \Gamma_\text{out,ms}$"], bbox_to_anchor=(-(2.25-1)/2, 1.05, 2.25, 0.2), loc="lower center", mode="expand", ncol=3, fontsize=14)

  # AXES 4: Cross-flux velocity.
  for j in range(3):
    for i in range(2):
      if not (j == 2 and i > 0):
        if plot_outliers:
          for k in range(len(data[i, j]["outside_iqr"]["velocity_cross_flow_flux"])):
            for l in range(len(data[i, j]["outside_iqr"]["velocity_cross_flow_flux"][k])):
              axes[3][0][j].scatter(parameter_values[j][k], data[i, j]["outside_iqr"]["velocity_cross_flow_flux"][k][l], marker=".", color=f"C{i}", alpha=1.0/10)

        axes[3][0][j].plot(parameter_values[j], data[i, j]["q50"]["velocity_cross_flow_flux"], linestyle="dashed", color=f"C{i}")
        axes[3][0][j].fill_between(parameter_values[j], data[i, j]["q25"]["velocity_cross_flow_flux"], data[i, j]["q75"]["velocity_cross_flow_flux"], alpha=0.2, color=f"C{i}")
  axes[3][0][0].legend(handles=handles[0:2], labels=[r"any $N_\text{V}$", r"$N_\text{V} = 27$"])
  axes[3][0][1].legend(handles=handles[0:2], labels=[r"any $N_\text{A}$", r"$N_\text{A} = 6$"])

  # AXES 5: Transport reaction integral.
  for j in range(3):
    for i in range(2):
      if not (j == 2 and i > 0):
        if plot_outliers:
          for k in range(len(data[i, j]["outside_iqr"]["transport_reaction_integral"])):
            for l in range(len(data[i, j]["outside_iqr"]["transport_reaction_integral"][k])):
              axes[0][1][j].scatter(parameter_values[j][k], data[i, j]["outside_iqr"]["transport_reaction_integral"][k][l], marker=".", color=f"C{i}", alpha=1.0/10)

        axes[0][1][j].plot(parameter_values[j], data[i, j]["q50"]["transport_reaction_integral"], linestyle="dashed", color=f"C{i}")
        axes[0][1][j].fill_between(parameter_values[j], data[i, j]["q25"]["transport_reaction_integral"], data[i, j]["q75"]["transport_reaction_integral"], alpha=0.2, color=f"C{i}")
    # if plot_outliers:
    #   for k in range(len(data[0, j]["outside_iqr"]["transport_reaction_integral"])):
    #     for l in range(len(data[0, j]["outside_iqr"]["transport_reaction_integral"][k])):
    #       axes_mini[1][j].scatter(parameter_values[j][k], data[0, j]["outside_iqr"]["transport_reaction_integral"][k][l], marker=".", color=f"C0", alpha=1.0/10)
    # axes_mini[1][j].plot(parameter_values[j], data[0, j]["q50"]["transport_reaction_integral"], linestyle="dashed", color=f"C0")
    # axes_mini[1][j].fill_between(parameter_values[j], data[0, j]["q25"]["transport_reaction_integral"], data[0, j]["q75"]["transport_reaction_integral"], alpha=0.2, color=f"C0")
  axes[0][1][0].legend(handles=handles[0:2], labels=[r"any $N_\text{V}$", r"$N_\text{V} = 27$"], loc="lower right")
  axes[0][1][1].legend(handles=handles[0:2], labels=[r"any $N_\text{A}$", r"$N_\text{A} = 6$"], loc="lower left")

  # AXES 6: Concentration flux through different veins.
  for j in range(3):
    if plot_outliers:
      for k in range(len(data[0, j]["outside_iqr"]["transport_percentage_basal_plate"])):
        for l in range(len(data[0, j]["outside_iqr"]["transport_percentage_basal_plate"][k])):
          axes[2][1][j].scatter(parameter_values[j][k], data[0, j]["outside_iqr"]["transport_percentage_basal_plate"][k][l], marker=".", color=f"C0", alpha=1.0/10)
      for k in range(len(data[0, j]["outside_iqr"]["transport_percentage_septal_wall"])):
        for l in range(len(data[0, j]["outside_iqr"]["transport_percentage_septal_wall"][k])):
          axes[2][1][j].scatter(parameter_values[j][k], data[0, j]["outside_iqr"]["transport_percentage_septal_wall"][k][l], marker=".", color=f"C1", alpha=1.0/10)
      for k in range(len(data[0, j]["outside_iqr"]["transport_percentage_marginal_sinus"])):
        for l in range(len(data[0, j]["outside_iqr"]["transport_percentage_marginal_sinus"][k])):
          axes[2][1][j].scatter(parameter_values[j][k], data[0, j]["outside_iqr"]["transport_percentage_marginal_sinus"][k][l], marker=".", color=f"C2", alpha=1.0/10)
    axes[2][1][j].plot(parameter_values[j], data[0, j]["q50"]["transport_percentage_basal_plate"], linestyle="dashed", color="C0")
    axes[2][1][j].plot(parameter_values[j], data[0, j]["q50"]["transport_percentage_septal_wall"], linestyle="dashed", color="C1")
    axes[2][1][j].plot(parameter_values[j], data[0, j]["q50"]["transport_percentage_marginal_sinus"], linestyle="dashed", color="C2")
    # axes[2][1][j].plot(parameter_values[j], data[0, j]["q50"]["transport_percentage_basal_plate"] + data[0, j]["q50"]["transport_percentage_septal_wall"] + data[0, j]["q50"]["transport_percentage_marginal_sinus"], linestyle="dashed", color="black")
    axes[2][1][j].fill_between(parameter_values[j], data[0, j]["q25"]["transport_percentage_basal_plate"], data[0, j]["q75"]["transport_percentage_basal_plate"], alpha=0.2, color="C0")
    axes[2][1][j].fill_between(parameter_values[j], data[0, j]["q25"]["transport_percentage_septal_wall"], data[0, j]["q75"]["transport_percentage_septal_wall"], alpha=0.2, color="C1")
    axes[2][1][j].fill_between(parameter_values[j], data[0, j]["q25"]["transport_percentage_marginal_sinus"], data[0, j]["q75"]["transport_percentage_marginal_sinus"], alpha=0.2, color="C2")
    # axes[2][1][j].legend(handles=[handles[0], handles[1], handles[2]], labels=[r"$S = \Gamma_\text{out,bp}$", r"$S = \Gamma_\text{out,sw}$", r"$S = \Gamma_\text{out,ms}$"], loc='upper right')

  # AXES 7: Kinetic energy flux difference.
  for j in range(3):
    for i in range(2):
      if not (j == 2 and i > 0):
        if plot_outliers:
          for k in range(len(data[i, j]["outside_iqr"]["kinetic_energy_flux"])):
            for l in range(len(data[i, j]["outside_iqr"]["kinetic_energy_flux"][k])):
              axes[4][0][j].scatter(parameter_values[j][k], data[i, j]["data"]["kinetic_energy_flux"][k][l], marker=".", color=f"C{i}", alpha=1.0/10)

        axes[4][0][j].plot(parameter_values[j], data[i, j]["q50"]["kinetic_energy_flux"], linestyle="dashed", color=f"C{i}")
        axes[4][0][j].fill_between(parameter_values[j], data[i, j]["q25"]["kinetic_energy_flux"], data[i, j]["q75"]["kinetic_energy_flux"], alpha=0.2, color=f"C{i}")
      if (j == 0):
        analytic_parameter_values = np.linspace(1, 6, 100)
        N_a = analytic_parameter_values
        N_v = 27
        # k_1 = N_a/(6*(1+3*N_v))
        # k_1/= (2/3)
        # k_2 = (N_a - 3*N_v*k_1)/12
        # k_2/= 144 # Why is this needed?!
        # analytical_curve = 1 - (9*N_v*k_1**2 + 144*k_2**2)/(N_a)
        k_1 = N_a/(3*(2+N_v))
        k_2 = k_1/4
        analytical_curve = (N_a - 3*N_v*k_1**2 - 12*k_2**2)/N_a
      elif (j == 1):
        analytic_parameter_values = np.linspace(0, 27, 100)
        N_a = 6
        N_v = analytic_parameter_values
        # k_1 = N_a/(6*(1+3*N_v))
        # k_1/= (2/3)
        # k_2 = (N_a - 3*N_v*k_1)/12
        # k_2/= 144 # Why is this needed?!
        # analytical_curve = 1 - (9*N_v*k_1**2 + 144*k_2**2)/(N_a)
        k_1 = N_a/(3*(2+N_v))
        k_2 = k_1/4
        analytical_curve = (N_a - 3*N_v*k_1**2 - 12*k_2**2)/N_a
      if (j != 2):
        ...
        # axes[4][0][j].plot(analytic_parameter_values, analytical_curve, linestyle="dotted", color=f"k")
  # axes[4][0][0].legend(handles=[handles[0], handles[1], handles[4]], labels=[r"any $N_\text{V}$", r"$N_\text{V} = 27$", r"$\Phi(N_\text{A}, 27)$"], loc="lower right")
  # axes[4][0][1].legend(handles=[handles[0], handles[1], handles[4]], labels=[r"any $N_\text{A}$", r"$N_\text{A} = 6$", r"$\Phi(6, N_\text{V})$"], loc="lower right")
  axes[4][0][0].legend(handles=[handles[0], handles[1]], labels=[r"any $N_\text{V}$", r"$N_\text{V} = 27$"], loc="lower right")
  axes[4][0][1].legend(handles=[handles[0], handles[1]], labels=[r"any $N_\text{A}$", r"$N_\text{A} = 6$"], loc="lower right")

  # AXES 8: Total energy flux difference.
  for j in range(3):
    for i in range(2):
      if not (j == 2 and i > 0):
        if plot_outliers:
          for k in range(len(data[i, j]["outside_iqr"]["total_energy_flux"])):
            for l in range(len(data[i, j]["outside_iqr"]["total_energy_flux"][k])):
              axes[4][1][j].scatter(parameter_values[j][k], data[i, j]["data"]["total_energy_flux"][k][l], marker=".", color=f"C{i}", alpha=1.0/10)

        axes[4][1][j].plot(parameter_values[j], data[i, j]["q50"]["total_energy_flux"], linestyle="dashed", color=f"C{i}")
        axes[4][1][j].fill_between(parameter_values[j], data[i, j]["q25"]["total_energy_flux"], data[i, j]["q75"]["total_energy_flux"], alpha=0.2, color=f"C{i}")
  axes[4][1][0].legend(handles=handles[0:2], labels=[r"any $N_\text{V}$", r"$N_\text{V} = 27$"], loc="lower right")
  axes[4][1][1].legend(handles=handles[0:2], labels=[r"any $N_\text{A}$", r"$N_\text{A} = 6$"], loc="lower right")

  # Plot indiviudal simulations on mini axes.
  simulation_nos = [90, 70, 122, 444]
  colours = ["tab:pink", "tab:purple", "tab:green", "tab:red"]
  for i in range(4):
    sim_no = simulation_nos[i]

    no_arteries = simulations[sim_no-1].get_no_arteries()
    no_veins = simulations[sim_no-1].get_no_veins()

    axes[0][0][0].plot(no_arteries,          simulations[sim_no-1].velocity_magnitude_integral_ivs, 'X', markersize=10, linewidth=3, color=colours[i], markeredgecolor='white')
    axes[0][0][1].plot(no_veins,             simulations[sim_no-1].velocity_magnitude_integral_ivs, 'X', markersize=10, linewidth=3, color=colours[i], markeredgecolor='white')
    axes[0][0][2].plot(no_veins/no_arteries, simulations[sim_no-1].velocity_magnitude_integral_ivs, 'X', markersize=10, linewidth=3, color=colours[i], markeredgecolor='white')

    axes[0][1][0].plot(no_arteries,          simulations[sim_no-1].transport_reaction_integral,     'X', markersize=10, linewidth=3, color=colours[i], markeredgecolor='white')
    axes[0][1][1].plot(no_veins,             simulations[sim_no-1].transport_reaction_integral,     'X', markersize=10, linewidth=3, color=colours[i], markeredgecolor='white')
    axes[0][1][2].plot(no_veins/no_arteries, simulations[sim_no-1].transport_reaction_integral,     'X', markersize=10, linewidth=3, color=colours[i], markeredgecolor='white')

  # Style plots column-wise.
  setup_plots.style(figs[0], axes[0][0][0], None, r"$\bar{v}(\Omega_\text{IVS})$", y_scilimits=[-3, -3] , y_bottom=0, y_top=1e-2, integer_ticks=True, y_max_minor_ticks=11, y_max_major_ticks=6)
  setup_plots.style(figs[0], axes[0][1][0], parameter_name[0], r"$\bar{c}$", y_scilimits=[-4, -4], y_bottom=0, y_top=5e-4, integer_ticks=True, y_max_minor_ticks=11, y_max_major_ticks=6)
  setup_plots.style(figs[1], axes[1][0][0], parameter_name[0], r"$v_\text{slow}(V_\text{threshold})$ (%)", y_scilimits=None , y_top=42, integer_ticks=True, y_max_minor_ticks=9, y_max_major_ticks=5)
  setup_plots.style(figs[2], axes[2][0][0], None, r"$\frac{v_\text{flux}(S)}{v_\text{flux}(\Gamma_\text{in})}$ (%)", y_scilimits=None , y_top=102, integer_ticks=True, y_max_minor_ticks=11, y_max_major_ticks=6)
  setup_plots.style(figs[2], axes[2][1][0], parameter_name[0], r"$\frac{C_\text{flux}(S)}{C_\text{flux}(\Gamma_\text{in})}$ (%)", y_scilimits=None , y_top=102, integer_ticks=True, y_max_minor_ticks=11, y_max_major_ticks=6)
  setup_plots.style(figs[3], axes[3][0][0], parameter_name[0], r"$v_\text{cross}$", y_scilimits=[-3, -3] , y_bottom=0, y_top=2e-2, integer_ticks=True, y_max_minor_ticks=9)
  setup_plots.style(figs[4], axes[4][0][0], None, r"$\frac{E_\text{kinetic}(\Gamma_\text{in}) - E_\text{kinetic}(\Gamma_\text{out})}{E_\text{kinetic}(\Gamma_\text{in})}$", y_scilimits=None, y_bottom=0.6, y_top=1.02, integer_ticks=True)
  setup_plots.style(figs[4], axes[4][1][0], parameter_name[0], r"$\frac{E_\text{total}(\Gamma_\text{in}) - E_\text{total}(\Gamma_\text{out})}{E_\text{total}(\Gamma_\text{in})}$", y_scilimits=[0, 0], y_bottom=0.95, y_top=1.001, integer_ticks=True, y_max_minor_ticks=6)

  setup_plots.style(figs[0], axes[0][0][1], None, None, y_scilimits=[-3, -3], y_bottom=0, y_top=1e-2, integer_ticks=True, max_major_ticks=4, y_max_minor_ticks=11, y_max_major_ticks=6)
  setup_plots.style(figs[0], axes[0][1][1], parameter_name[1], None, y_scilimits=[-4, -4], y_bottom=0, y_top=5e-4, integer_ticks=True, max_major_ticks=4, y_max_minor_ticks=11, y_max_major_ticks=6)
  setup_plots.style(figs[1], axes[1][0][1], parameter_name[1], None, y_scilimits=None , y_top=42, integer_ticks=True, max_major_ticks=4, y_max_minor_ticks=9, y_max_major_ticks=5)
  setup_plots.style(figs[2], axes[2][0][1], None, None, y_scilimits=None , y_top=102, integer_ticks=True, max_major_ticks=4, y_max_minor_ticks=11, y_max_major_ticks=6)
  setup_plots.style(figs[2], axes[2][1][1], parameter_name[1], None, y_scilimits=None , y_top=102, integer_ticks=True, max_major_ticks=4, y_max_minor_ticks=11, y_max_major_ticks=6)
  setup_plots.style(figs[3], axes[3][0][1], parameter_name[1], None, y_scilimits=[-3, -3], y_bottom=0, y_top=2e-2, integer_ticks=True, max_major_ticks=4, y_max_minor_ticks=9)
  setup_plots.style(figs[4], axes[4][0][1], None, None, y_scilimits=None, y_bottom=0.6, y_top=1.02, integer_ticks=True, max_major_ticks=4)
  setup_plots.style(figs[4], axes[4][1][1], parameter_name[1], None, y_scilimits=[0, 0], y_bottom=0.95, y_top=1.001, integer_ticks=True, max_major_ticks=4, y_max_minor_ticks=6)

  setup_plots.style(figs[0], axes[0][0][2], None, None, y_scilimits=[-3, -3], y_bottom=0, y_top=1e-2, integer_ticks=True, max_major_ticks=4, y_max_minor_ticks=11, y_max_major_ticks=6)
  setup_plots.style(figs[0], axes[0][1][2], parameter_name[2], None, y_scilimits=[-4, -4], y_bottom=0, y_top=5e-4, integer_ticks=True, max_major_ticks=4, y_max_minor_ticks=11, y_max_major_ticks=6)
  setup_plots.style(figs[1], axes[1][0][2], parameter_name[2], None, y_scilimits=None , y_top=42, integer_ticks=True, max_major_ticks=4, y_max_minor_ticks=9, y_max_major_ticks=5)
  setup_plots.style(figs[2], axes[2][0][2], None, None, y_scilimits=None , y_top=102, integer_ticks=True, max_major_ticks=4, y_max_minor_ticks=11, y_max_major_ticks=6)
  setup_plots.style(figs[2], axes[2][1][2], parameter_name[2], None, y_scilimits=None , y_top=102, integer_ticks=True, max_major_ticks=4, y_max_minor_ticks=11, y_max_major_ticks=6)
  setup_plots.style(figs[3], axes[3][0][2], parameter_name[2], None, y_scilimits=[-3, -3], y_bottom=0, y_top=2e-2, integer_ticks=True, max_major_ticks=4, y_max_minor_ticks=9)
  setup_plots.style(figs[4], axes[4][0][2], None, None, y_scilimits=None, y_bottom=0.6, y_top=1.02, integer_ticks=True, max_major_ticks=4)
  setup_plots.style(figs[4], axes[4][1][2], parameter_name[2], None, y_scilimits=[0, 0], y_bottom=0.95, y_top=1.001, integer_ticks=True, max_major_ticks=4, y_max_minor_ticks=6)

  # Decide where to save plots.
  if subfolder == None:
    images_folder = "images"
  else:
    images_folder = f"images/{subfolder}"

  # Save.
  figs[0].savefig(f"{images_folder}/mega1_{parameter_safe_name[0]}_{parameter_safe_name[1]}_{parameter_safe_name[2]}.png", dpi=300)
  figs[1].savefig(f"{images_folder}/mega2_{parameter_safe_name[0]}_{parameter_safe_name[1]}_{parameter_safe_name[2]}.png", dpi=300)
  figs[2].savefig(f"{images_folder}/mega3_{parameter_safe_name[0]}_{parameter_safe_name[1]}_{parameter_safe_name[2]}.png", dpi=300)
  figs[3].savefig(f"{images_folder}/mega4_{parameter_safe_name[0]}_{parameter_safe_name[1]}_{parameter_safe_name[2]}.png", dpi=300)
  figs[4].savefig(f"{images_folder}/mega5_{parameter_safe_name[0]}_{parameter_safe_name[1]}_{parameter_safe_name[2]}.png", dpi=300)

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