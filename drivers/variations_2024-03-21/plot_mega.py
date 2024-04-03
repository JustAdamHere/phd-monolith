def plot_others(simulations, simulation_bins, parameter_values, parameter_name, parameter_safe_name, subfolder=None, plot_outliers=False):
  import numpy as np

  print(f"\rPlotting simulations...", end="")

  assert(len(parameter_values) == 6)
  assert(len(simulation_bins) == 6)
  assert(len(simulations) == 6)

  # Setup plots.
  from plotting import setup_plots
  fig1, axes1 = setup_plots.setup_megaplot(1, 8, 3, figsize=(10, 18))
  fig2, axes2 = setup_plots.setup_megaplot(2, 8, 3, figsize=(10, 18))
  fig = [fig1, fig2]
  axes = [axes1, axes2]

  # Get data to plot.
  data = np.zeros(6, dtype=object)
  for j in range(6):
    data[j] = setup_plots.get_data(len(simulation_bins[j]), simulation_bins[j], simulations[j])

  # Patches for legends.
  import matplotlib.patches as mpatches
  max_no_patches = 4
  handles = []
  for i in range(max_no_patches):
    handles.append(mpatches.Patch(color=f"C{i}"))

  # AXES 1: Velocity magnitude integrals.
  for i in range(2):
    for j in range(3):
      if plot_outliers:
        for k in range(len(data[3*i+j]["outside_iqr"]["velocity_magnitude_integral"])):
          for l in range(len(data[3*i+j]["outside_iqr"]["velocity_magnitude_integral"][k])):
            axes[i][0][j].scatter(parameter_values[3*i+j][k], data[3*i+j]["outside_iqr"]["velocity_magnitude_integral"][k][l], marker=".", color=f"C0", alpha=1.0/10)

      axes[i][0][j].plot(parameter_values[3*i+j], data[3*i+j]["q50"]["velocity_magnitude_integral"], linestyle="dashed", color=f"C0")
      axes[i][0][j].fill_between(parameter_values[3*i+j], data[3*i+j]["q25"]["velocity_magnitude_integral"], data[3*i+j]["q75"]["velocity_magnitude_integral"], alpha=0.2, color=f"C0")

  # AXES 2: Slow velocity percentages.
  for i in range(2):
    for j in range(3):
      if plot_outliers:
        for k in range(len(data[3*i+j]["outside_iqr"]["slow_velocity_percentage_ivs"])):
          for l in range(len(data[3*i+j]["outside_iqr"]["slow_velocity_percentage_ivs"][k])):
            axes[i][1][j].scatter(parameter_values[3*i+j][k], data[3*i+j]["outside_iqr"]["slow_velocity_percentage_ivs"][k][l], marker=".", color=f"C0", alpha=1.0/10)
        for k in range(len(data[3*i+j]["outside_iqr"]["slow_velocity_percentage_everywhere"])):
          for l in range(len(data[3*i+j]["outside_iqr"]["slow_velocity_percentage_everywhere"][k])):
            axes[i][1][j].scatter(parameter_values[3*i+j][k], data[3*i+j]["outside_iqr"]["slow_velocity_percentage_everywhere"][k][l], marker=".", color=f"C1", alpha=1.0/10)
        for k in range(len(data[3*i+j]["outside_iqr"]["slow_velocity_percentage_dellschaft"])):
          for l in range(len(data[3*i+j]["outside_iqr"]["slow_velocity_percentage_dellschaft"][k])):
            axes[i][1][j].scatter(parameter_values[3*i+j][k], data[3*i+j]["outside_iqr"]["slow_velocity_percentage_dellschaft"][k][l], marker=".", color=f"C2", alpha=1.0/10)
        for k in range(len(data[3*i+j]["outside_iqr"]["slow_velocity_percentage_nominal_everywhere"])):
          for l in range(len(data[3*i+j]["outside_iqr"]["slow_velocity_percentage_nominal_everywhere"][k])):
            axes[i][1][j].scatter(parameter_values[3*i+j][k], data[3*i+j]["outside_iqr"]["slow_velocity_percentage_nominal_everywhere"][k][l], marker=".", color=f"C3", alpha=1.0/10)
      axes[i][1][j].plot(parameter_values[3*i+j], data[3*i+j]["q50"]["slow_velocity_percentage_ivs"], linestyle="dashed", color="C0")
      axes[i][1][j].plot(parameter_values[3*i+j], data[3*i+j]["q50"]["slow_velocity_percentage_everywhere"], linestyle="dashed", color="C1")
      axes[i][1][j].plot(parameter_values[3*i+j], data[3*i+j]["q50"]["slow_velocity_percentage_dellschaft"], linestyle="dashed", color="C2")
      axes[i][1][j].plot(parameter_values[3*i+j], data[3*i+j]["q50"]["slow_velocity_percentage_nominal_everywhere"], linestyle="dashed", color="C3")
      axes[i][1][j].fill_between(parameter_values[3*i+j], data[3*i+j]["q25"]["slow_velocity_percentage_ivs"], data[3*i+j]["q75"]["slow_velocity_percentage_ivs"], alpha=0.2, color="C0")
      axes[i][1][j].fill_between(parameter_values[3*i+j], data[3*i+j]["q25"]["slow_velocity_percentage_everywhere"], data[3*i+j]["q75"]["slow_velocity_percentage_everywhere"], alpha=0.2, color="C1")
      axes[i][1][j].fill_between(parameter_values[3*i+j], data[3*i+j]["q25"]["slow_velocity_percentage_dellschaft"], data[3*i+j]["q75"]["slow_velocity_percentage_dellschaft"], alpha=0.2, color="C2")
      axes[i][1][j].fill_between(parameter_values[3*i+j], data[3*i+j]["q25"]["slow_velocity_percentage_nominal_everywhere"], data[3*i+j]["q75"]["slow_velocity_percentage_nominal_everywhere"], alpha=0.2, color="C3")
      axes[i][1][j].legend(handles=handles[0:4], labels=[r"$V_\text{threshold} = \bar{v}(\Omega_\text{IVS})$", r"$V_\text{threshold} = \bar{v}(\Omega)$", r"$V_\text{threshold} = 0.0005$", r"$V_\text{threshold} = 0.0026$"], loc="upper left")

  # AXES 3: Velocity flux through different veins.
  for i in range(2):
    for j in range(3):
      if plot_outliers:
        for k in range(len(data[3*i+j]["outside_iqr"]["velocity_percentage_basal_plate"])):
          for l in range(len(data[3*i+j]["outside_iqr"]["velocity_percentage_basal_plate"][k])):
            axes[i][2][j].scatter(parameter_values[3*i+j][k], data[3*i+j]["outside_iqr"]["velocity_percentage_basal_plate"][k][l], marker=".", color=f"C0", alpha=1.0/10)
        for k in range(len(data[3*i+j]["outside_iqr"]["velocity_percentage_septal_wall"])):
          for l in range(len(data[3*i+j]["outside_iqr"]["velocity_percentage_septal_wall"][k])):
            axes[i][2][j].scatter(parameter_values[3*i+j][k], data[3*i+j]["outside_iqr"]["velocity_percentage_septal_wall"][k][l], marker=".", color=f"C1", alpha=1.0/10)
        for k in range(len(data[3*i+j]["outside_iqr"]["velocity_percentage_marginal_sinus"])):
          for l in range(len(data[3*i+j]["outside_iqr"]["velocity_percentage_marginal_sinus"][k])):
            axes[i][2][j].scatter(parameter_values[3*i+j][k], data[3*i+j]["outside_iqr"]["velocity_percentage_marginal_sinus"][k][l], marker=".", color=f"C2", alpha=1.0/10)
      axes[i][2][j].plot(parameter_values[3*i+j], data[3*i+j]["q50"]["velocity_percentage_basal_plate"], linestyle="dashed", color="C0")
      axes[i][2][j].plot(parameter_values[3*i+j], data[3*i+j]["q50"]["velocity_percentage_septal_wall"], linestyle="dashed", color="C1")
      axes[i][2][j].plot(parameter_values[3*i+j], data[3*i+j]["q50"]["velocity_percentage_marginal_sinus"], linestyle="dashed", color="C2")
      axes[i][2][j].fill_between(parameter_values[3*i+j], data[3*i+j]["q25"]["velocity_percentage_basal_plate"], data[3*i+j]["q75"]["velocity_percentage_basal_plate"], alpha=0.2, color="C0")
      axes[i][2][j].fill_between(parameter_values[3*i+j], data[3*i+j]["q25"]["velocity_percentage_septal_wall"], data[3*i+j]["q75"]["velocity_percentage_septal_wall"], alpha=0.2, color="C1")
      axes[i][2][j].fill_between(parameter_values[3*i+j], data[3*i+j]["q25"]["velocity_percentage_marginal_sinus"], data[3*i+j]["q75"]["velocity_percentage_marginal_sinus"], alpha=0.2, color="C2")
      axes[i][2][j].legend(handles=handles[0:3], labels=[r"$S = \Gamma_\text{out,bp}$", r"$S = \Gamma_\text{out,sw}$", r"$S = \Gamma_\text{out,ms}$"], loc="center left")

  # AXES 4: Cross-flux velocity.
  for i in range(2):
    for j in range(3):
      if plot_outliers:
        for k in range(len(data[3*i+j]["outside_iqr"]["velocity_cross_flow_flux"])):
          for l in range(len(data[3*i+j]["outside_iqr"]["velocity_cross_flow_flux"][k])):
            axes[i][3][j].scatter(parameter_values[3*i+j][k], data[3*i+j]["outside_iqr"]["velocity_cross_flow_flux"][k][l], marker=".", color=f"C0", alpha=1.0/10)
      axes[i][3][j].plot(parameter_values[3*i+j], data[3*i+j]["q50"]["velocity_cross_flow_flux"], linestyle="dashed", color=f"C0")
      axes[i][3][j].fill_between(parameter_values[3*i+j], data[3*i+j]["q25"]["velocity_cross_flow_flux"], data[3*i+j]["q75"]["velocity_cross_flow_flux"], alpha=0.2, color=f"C0")

  # AXES 5: Transport reaction integral.
  for i in range(2):
    for j in range(3):
      if plot_outliers:
        for k in range(len(data[3*i+j]["outside_iqr"]["transport_reaction_integral"])):
          for l in range(len(data[3*i+j]["outside_iqr"]["transport_reaction_integral"][k])):
            axes[i][4][j].scatter(parameter_values[3*i+j][k], data[3*i+j]["outside_iqr"]["transport_reaction_integral"][k][l], marker=".", color=f"C0", alpha=1.0/10)

      axes[i][4][j].plot(parameter_values[3*i+j], data[3*i+j]["q50"]["transport_reaction_integral"], linestyle="dashed", color=f"C0")
      axes[i][4][j].fill_between(parameter_values[3*i+j], data[3*i+j]["q25"]["transport_reaction_integral"], data[3*i+j]["q75"]["transport_reaction_integral"], alpha=0.2, color=f"C0")

  # AXES 6: Concentration flux through different veins.
  for i in range(2):
    for j in range(3):
      if plot_outliers:
        for k in range(len(data[3*i+j]["outside_iqr"]["transport_percentage_basal_plate"])):
          for l in range(len(data[3*i+j]["outside_iqr"]["transport_percentage_basal_plate"][k])):
            axes[i][5][j].scatter(parameter_values[3*i+j][k], data[3*i+j]["outside_iqr"]["transport_percentage_basal_plate"][k][l], marker=".", color=f"C0", alpha=1.0/10)
        for k in range(len(data[3*i+j]["outside_iqr"]["transport_percentage_septal_wall"])):
          for l in range(len(data[3*i+j]["outside_iqr"]["transport_percentage_septal_wall"][k])):
            axes[i][5][j].scatter(parameter_values[3*i+j][k], data[3*i+j]["outside_iqr"]["transport_percentage_septal_wall"][k][l], marker=".", color=f"C1", alpha=1.0/10)
        for k in range(len(data[3*i+j]["outside_iqr"]["transport_percentage_marginal_sinus"])):
          for l in range(len(data[3*i+j]["outside_iqr"]["transport_percentage_marginal_sinus"][k])):
            axes[i][5][j].scatter(parameter_values[3*i+j][k], data[3*i+j]["outside_iqr"]["transport_percentage_marginal_sinus"][k][l], marker=".", color=f"C2", alpha=1.0/10)

      axes[i][5][j].plot(parameter_values[3*i+j], data[3*i+j]["q50"]["transport_percentage_basal_plate"], linestyle="dashed", color="C0")
      axes[i][5][j].plot(parameter_values[3*i+j], data[3*i+j]["q50"]["transport_percentage_septal_wall"], linestyle="dashed", color="C1")
      axes[i][5][j].plot(parameter_values[3*i+j], data[3*i+j]["q50"]["transport_percentage_marginal_sinus"], linestyle="dashed", color="C2")
      axes[i][5][j].fill_between(parameter_values[3*i+j], data[3*i+j]["q25"]["transport_percentage_basal_plate"], data[3*i+j]["q75"]["transport_percentage_basal_plate"], alpha=0.2, color="C0")
      axes[i][5][j].fill_between(parameter_values[3*i+j], data[3*i+j]["q25"]["transport_percentage_septal_wall"], data[3*i+j]["q75"]["transport_percentage_septal_wall"], alpha=0.2, color="C1")
      axes[i][5][j].fill_between(parameter_values[3*i+j], data[3*i+j]["q25"]["transport_percentage_marginal_sinus"], data[3*i+j]["q75"]["transport_percentage_marginal_sinus"], alpha=0.2, color="C2")
      axes[i][5][j].legend(handles=handles[0:3], labels=[r"$S = \Gamma_\text{out,bp}$", r"$S = \Gamma_\text{out,sw}$", r"$S = \Gamma_\text{out,ms}$"], loc="center left")

  # AXES 7: Kinetic energy flux difference.
  for i in range(2):
    for j in range(3):
      if plot_outliers:
        for k in range(len(data[3*i+j]["outside_iqr"]["kinetic_energy_flux"])):
          for l in range(len(data[3*i+j]["outside_iqr"]["kinetic_energy_flux"][k])):
            axes[i][6][j].scatter(parameter_values[3*i+j][k], data[3*i+j]["data"]["kinetic_energy_flux"][k][l], marker=".", color=f"C0", alpha=1.0/10)

      axes[i][6][j].plot(parameter_values[3*i+j], data[3*i+j]["q50"]["kinetic_energy_flux"], linestyle="dashed", color=f"C0")
      axes[i][6][j].fill_between(parameter_values[3*i+j], data[3*i+j]["q25"]["kinetic_energy_flux"], data[3*i+j]["q75"]["kinetic_energy_flux"], alpha=0.2, color=f"C0")  

  # AXES 8: Total energy flux difference.
  for i in range(2):
    for j in range(3):
      if plot_outliers:
        for k in range(len(data[3*i+j]["outside_iqr"]["total_energy_flux"])):
          for l in range(len(data[3*i+j]["outside_iqr"]["total_energy_flux"][k])):
            axes[i][7][j].scatter(parameter_values[3*i+j][k], data[3*i+j]["data"]["total_energy_flux"][k][l], marker=".", color=f"C0", alpha=1.0/10)

      axes[i][7][j].plot(parameter_values[3*i+j], data[3*i+j]["q50"]["total_energy_flux"], linestyle="dashed", color=f"C0")
      axes[i][7][j].fill_between(parameter_values[3*i+j], data[3*i+j]["q25"]["total_energy_flux"], data[3*i+j]["q75"]["total_energy_flux"], alpha=0.2, color=f"C0")

  # Style plots.
  setup_plots.style(fig1, axes1[0][0], None, r"$\bar{v}$", y_scilimits=[-3, -3] , y_bottom=0, y_top=1e-2, integer_ticks=False, max_major_ticks=2)
  setup_plots.style(fig1, axes1[1][0], None, r"$v_\text{slow}(V_\text{threshold})$", y_scilimits=None , y_top=102, integer_ticks=False, max_major_ticks=2)
  setup_plots.style(fig1, axes1[2][0], None, r"$\frac{v_\text{flux}(S)}{v_\text{flux}(\Gamma_\text{in})}$ (%)", y_scilimits=None , y_top=102, integer_ticks=False, max_major_ticks=2)
  setup_plots.style(fig1, axes1[3][0], None, r"$v_\text{cross}$", y_scilimits=[-3, -3] , y_bottom=0, y_top=3e-3, integer_ticks=False, max_major_ticks=2)
  setup_plots.style(fig1, axes1[4][0], None, r"$\bar{c}$", y_scilimits=[-3, -3], y_bottom=0, y_top=5e-3, integer_ticks=False, max_major_ticks=2)
  setup_plots.style(fig1, axes1[5][0], None, r"$\frac{C_\text{flux}(S)}{C_\text{flux}(\Gamma_\text{in})}$ (%)", y_scilimits=None , y_top=102, integer_ticks=False, max_major_ticks=2)
  setup_plots.style(fig1, axes1[6][0], None, r"$\frac{E_\text{kinetic}(\Gamma_\text{in}) - E_\text{kinetic}(\Gamma_\text{out})}{E_\text{kinetic}(\Gamma_\text{in})}$", y_scilimits=None, y_bottom=0.6, y_top=1.02, integer_ticks=False, max_major_ticks=2)
  setup_plots.style(fig1, axes1[7][0], parameter_name[0], r"$\frac{E_\text{total}(\Gamma_\text{in}) - E_\text{total}(\Gamma_\text{out})}{E_\text{total}(\Gamma_\text{in})}$", y_scilimits=None, y_bottom=0.95, y_top=1.001, integer_ticks=False, max_major_ticks=2)

  setup_plots.style(fig1, axes1[0][1], None, None, y_scilimits=[-3, -3], y_bottom=0, y_top=1e-2, integer_ticks=False, max_major_ticks=2)
  setup_plots.style(fig1, axes1[1][1], None, None, y_scilimits=None , y_top=102, integer_ticks=False, max_major_ticks=2)
  setup_plots.style(fig1, axes1[2][1], None, None, y_scilimits=None , y_top=102, integer_ticks=False, max_major_ticks=2)
  setup_plots.style(fig1, axes1[3][1], None, None, y_scilimits=[-3, -3], y_bottom=0, y_top=3e-3, integer_ticks=False, max_major_ticks=2)
  setup_plots.style(fig1, axes1[4][1], None, None, y_scilimits=[-3, -3], y_bottom=0, y_top=5e-3, integer_ticks=False, max_major_ticks=2)
  setup_plots.style(fig1, axes1[5][1], None, None, y_scilimits=None , y_top=102, integer_ticks=False, max_major_ticks=2)
  setup_plots.style(fig1, axes1[6][1], None, None, y_scilimits=None, y_bottom=0.6, y_top=1.02, integer_ticks=False, max_major_ticks=2)
  setup_plots.style(fig1, axes1[7][1], parameter_name[1], None, y_scilimits=None, y_bottom=0.95, y_top=1.001, integer_ticks=False, max_major_ticks=2)

  setup_plots.style(fig1, axes1[0][2], None, None, y_scilimits=[-3, -3], y_bottom=0, y_top=1e-2, integer_ticks=False, max_major_ticks=2)
  setup_plots.style(fig1, axes1[1][2], None, None, y_scilimits=None , y_top=102, integer_ticks=False, max_major_ticks=2)
  setup_plots.style(fig1, axes1[2][2], None, None, y_scilimits=None , y_top=102, integer_ticks=False, max_major_ticks=2)
  setup_plots.style(fig1, axes1[3][2], None, None, y_scilimits=[-3, -3], y_bottom=0, y_top=3e-3, integer_ticks=False, max_major_ticks=2)
  setup_plots.style(fig1, axes1[4][2], None, None, y_scilimits=[-3, -3], y_bottom=0, y_top=5e-3, integer_ticks=False, max_major_ticks=2)
  setup_plots.style(fig1, axes1[5][2], None, None, y_scilimits=None , y_top=102, integer_ticks=False, max_major_ticks=2)
  setup_plots.style(fig1, axes1[6][2], None, None, y_scilimits=None, y_bottom=0.6, y_top=1.02, integer_ticks=False, max_major_ticks=2)
  setup_plots.style(fig1, axes1[7][2], parameter_name[2], None, y_scilimits=None, y_bottom=0.95, y_top=1.001, integer_ticks=False, max_major_ticks=2)

  setup_plots.style(fig2, axes2[0][0], None, r"$\bar{v}$", y_scilimits=[-3, -3], y_bottom=0, y_top=1e-2, integer_ticks=True, max_major_ticks=5)
  setup_plots.style(fig2, axes2[1][0], None, r"$v_\text{slow}(V_\text{threshold})$", y_scilimits=None , y_top=102, integer_ticks=True, max_major_ticks=5)
  setup_plots.style(fig2, axes2[2][0], None, r"$\frac{v_\text{flux}(S)}{v_\text{flux}(\Gamma_\text{in})}$ (%)", y_scilimits=None , y_top=102, integer_ticks=True, max_major_ticks=5)
  setup_plots.style(fig2, axes2[3][0], None, r"$v_\text{cross}$", y_scilimits=[-3, -3], y_bottom=0, y_top=3e-3, integer_ticks=True, max_major_ticks=5)
  setup_plots.style(fig2, axes2[4][0], None, r"$\bar{c}$", y_scilimits=[-3, -3], y_bottom=0, y_top=5e-3, integer_ticks=True, max_major_ticks=5)
  setup_plots.style(fig2, axes2[5][0], None, r"$\frac{C_\text{flux}(S)}{C_\text{flux}(\Gamma_\text{in})}$ (%)", y_scilimits=None , y_top=102, integer_ticks=True, max_major_ticks=5)
  setup_plots.style(fig2, axes2[6][0], None, r"$\frac{E_\text{kinetic}(\Gamma_\text{in}) - E_\text{kinetic}(\Gamma_\text{out})}{E_\text{kinetic}(\Gamma_\text{in})}$", y_scilimits=None, y_bottom=0.6, y_top=1.02, integer_ticks=True, max_major_ticks=5)
  setup_plots.style(fig2, axes2[7][0], parameter_name[3], r"$\frac{E_\text{total}(\Gamma_\text{in}) - E_\text{total}(\Gamma_\text{out})}{E_\text{total}(\Gamma_\text{in})}$", y_scilimits=None, y_bottom=0.95, y_top=1.001, integer_ticks=True, max_major_ticks=5)

  setup_plots.style(fig2, axes2[0][1], None, None, y_scilimits=[-3, -3], y_bottom=0, y_top=1e-2, integer_ticks=False, max_major_ticks=2)
  setup_plots.style(fig2, axes2[1][1], None, None, y_scilimits=None , y_top=102, integer_ticks=False, max_major_ticks=2)
  setup_plots.style(fig2, axes2[2][1], None, None, y_scilimits=None , y_top=102, integer_ticks=False, max_major_ticks=2)
  setup_plots.style(fig2, axes2[3][1], None, None, y_scilimits=[-3, -3], y_bottom=0, y_top=3e-3, integer_ticks=False, max_major_ticks=2)
  setup_plots.style(fig2, axes2[4][1], None, None, y_scilimits=[-3, -3], y_bottom=0, y_top=5e-3, integer_ticks=False, max_major_ticks=2)
  setup_plots.style(fig2, axes2[5][1], None, None, y_scilimits=None , y_top=102, integer_ticks=False, max_major_ticks=2)
  setup_plots.style(fig2, axes2[6][1], None, None, y_scilimits=None, y_bottom=0.6, y_top=1.02, integer_ticks=False, max_major_ticks=2)
  setup_plots.style(fig2, axes2[7][1], parameter_name[4], None, y_scilimits=None, y_bottom=0.95, y_top=1.001, integer_ticks=False, max_major_ticks=2)

  setup_plots.style(fig2, axes2[0][2], None, None, y_scilimits=[-3, -3], y_bottom=0, y_top=1e-2, integer_ticks=False, max_major_ticks=3)
  setup_plots.style(fig2, axes2[1][2], None, None, y_scilimits=None , y_top=102, integer_ticks=False, max_major_ticks=3)
  setup_plots.style(fig2, axes2[2][2], None, None, y_scilimits=None , y_top=102, integer_ticks=False, max_major_ticks=3)
  setup_plots.style(fig2, axes2[3][2], None, None, y_scilimits=[-3, -3], y_bottom=0, y_top=3e-3, integer_ticks=False, max_major_ticks=3)
  setup_plots.style(fig2, axes2[4][2], None, None, y_scilimits=[-3, -3], y_bottom=0, y_top=5e-3, integer_ticks=False, max_major_ticks=3)
  setup_plots.style(fig2, axes2[5][2], None, None, y_scilimits=None , y_top=102, integer_ticks=False, max_major_ticks=3)
  setup_plots.style(fig2, axes2[6][2], None, None, y_scilimits=None, y_bottom=0.6, y_top=1.02, integer_ticks=False, max_major_ticks=3)
  setup_plots.style(fig2, axes2[7][2], parameter_name[5], None, y_scilimits=None, y_bottom=0.95, y_top=1.001, integer_ticks=False, max_major_ticks=3)

  # Decide where to save plots.
  if subfolder == None:
    images_folder = "images"
  else:
    images_folder = f"images/{subfolder}"

  # Save.
  fig1.savefig(f"{images_folder}/mega_{parameter_safe_name[0]}_{parameter_safe_name[1]}_{parameter_safe_name[2]}.png", dpi=300)
  fig2.savefig(f"{images_folder}/mega_{parameter_safe_name[3]}_{parameter_safe_name[4]}_{parameter_safe_name[5]}.png", dpi=300)

  # Done.
  print(f"\rPlotting simulations... Done.", end="\r\n")

  # Print number of subsamples in each bin.
  from tabulate import tabulate
  rows = []
  for j in range(6):
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
        if plot_outliers:
          for k in range(len(data[i, j]["outside_iqr"]["velocity_magnitude_integral"])):
            for l in range(len(data[i, j]["outside_iqr"]["velocity_magnitude_integral"][k])):
              axes[0][j].scatter(parameter_values[j][k], data[i, j]["outside_iqr"]["velocity_magnitude_integral"][k][l], marker=".", color=f"C{i}", alpha=1.0/10)

        axes[0][j].plot(parameter_values[j], data[i, j]["q50"]["velocity_magnitude_integral"], linestyle="dashed", color=f"C{i}")
        axes[0][j].fill_between(parameter_values[j], data[i, j]["q25"]["velocity_magnitude_integral"], data[i, j]["q75"]["velocity_magnitude_integral"], alpha=0.2, color=f"C{i}")
    if plot_outliers:
      for k in range(len(data[0, j]["outside_iqr"]["velocity_magnitude_integral"])):
        for l in range(len(data[0, j]["outside_iqr"]["velocity_magnitude_integral"][k])):
          axes_mini[0][j].scatter(parameter_values[j][k], data[0, j]["outside_iqr"]["velocity_magnitude_integral"][k][l], marker=".", color=f"C0", alpha=1.0/10)
    axes_mini[0][j].plot(parameter_values[j], data[0, j]["q50"]["velocity_magnitude_integral"], linestyle="dashed", color=f"C0")
    axes_mini[0][j].fill_between(parameter_values[j], data[0, j]["q25"]["velocity_magnitude_integral"], data[0, j]["q75"]["velocity_magnitude_integral"], alpha=0.2, color=f"C0")
    
  axes[0][0].legend(handles=handles[0:2], labels=[r"any $N_\text{V}$", r"$N_\text{V} = 27$"])
  axes[0][1].legend(handles=handles[0:2], labels=[r"any $N_\text{A}$", r"$N_\text{A} = 6$"])

  # AXES 2: Slow velocity percentages.
  for j in range(3):
    if plot_outliers:
      for k in range(len(data[0, j]["outside_iqr"]["slow_velocity_percentage_ivs"])):
        for l in range(len(data[0, j]["outside_iqr"]["slow_velocity_percentage_ivs"][k])):
          axes[1][j].scatter(parameter_values[j][k], data[0, j]["outside_iqr"]["slow_velocity_percentage_ivs"][k][l], marker=".", color=f"C0", alpha=1.0/10)
      for k in range(len(data[0, j]["outside_iqr"]["slow_velocity_percentage_everywhere"])):
        for l in range(len(data[0, j]["outside_iqr"]["slow_velocity_percentage_everywhere"][k])):
          axes[1][j].scatter(parameter_values[j][k], data[0, j]["outside_iqr"]["slow_velocity_percentage_everywhere"][k][l], marker=".", color=f"C1", alpha=1.0/10)
      for k in range(len(data[0, j]["outside_iqr"]["slow_velocity_percentage_dellschaft"])):
        for l in range(len(data[0, j]["outside_iqr"]["slow_velocity_percentage_dellschaft"][k])):
          axes[1][j].scatter(parameter_values[j][k], data[0, j]["outside_iqr"]["slow_velocity_percentage_dellschaft"][k][l], marker=".", color=f"C2", alpha=1.0/10)
      for k in range(len(data[0, j]["outside_iqr"]["slow_velocity_percentage_nominal_everywhere"])):
        for l in range(len(data[0, j]["outside_iqr"]["slow_velocity_percentage_nominal_everywhere"][k])):
          axes[1][j].scatter(parameter_values[j][k], data[0, j]["outside_iqr"]["slow_velocity_percentage_nominal_everywhere"][k][l], marker=".", color=f"C3", alpha=1.0/10)
    axes[1][j].plot(parameter_values[j], data[0, j]["q50"]["slow_velocity_percentage_ivs"], linestyle="dashed", color="C0")
    axes[1][j].plot(parameter_values[j], data[0, j]["q50"]["slow_velocity_percentage_everywhere"], linestyle="dashed", color="C1")
    axes[1][j].plot(parameter_values[j], data[0, j]["q50"]["slow_velocity_percentage_dellschaft"], linestyle="dashed", color="C2")
    axes[1][j].plot(parameter_values[j], data[0, j]["q50"]["slow_velocity_percentage_nominal_everywhere"], linestyle="dashed", color="C3")
    axes[1][j].fill_between(parameter_values[j], data[0, j]["q25"]["slow_velocity_percentage_ivs"], data[0, j]["q75"]["slow_velocity_percentage_ivs"], alpha=0.2, color="C0")
    axes[1][j].fill_between(parameter_values[j], data[0, j]["q25"]["slow_velocity_percentage_everywhere"], data[0, j]["q75"]["slow_velocity_percentage_everywhere"], alpha=0.2, color="C1")
    axes[1][j].fill_between(parameter_values[j], data[0, j]["q25"]["slow_velocity_percentage_dellschaft"], data[0, j]["q75"]["slow_velocity_percentage_dellschaft"], alpha=0.2, color="C2")
    axes[1][j].fill_between(parameter_values[j], data[0, j]["q25"]["slow_velocity_percentage_nominal_everywhere"], data[0, j]["q75"]["slow_velocity_percentage_nominal_everywhere"], alpha=0.2, color="C3")
    # axes[1][j].legend(handles=handles[0:4], labels=["IVS", "everywhere", "Dellschaft", "nominal"])
    axes[1][j].legend(handles=handles[0:4], labels=[r"$V_\text{threshold} = \bar{v}(\Omega_\text{IVS})$", r"$V_\text{threshold} = \bar{v}(\Omega)$", r"$V_\text{threshold} = 0.0005$", r"$V_\text{threshold} = 0.0026$"])

  # AXES 3: Velocity flux through different veins.
  for j in range(3):
    if plot_outliers:
      for k in range(len(data[0, j]["outside_iqr"]["velocity_percentage_basal_plate"])):
        for l in range(len(data[0, j]["outside_iqr"]["velocity_percentage_basal_plate"][k])):
          axes[2][j].scatter(parameter_values[j][k], data[0, j]["outside_iqr"]["velocity_percentage_basal_plate"][k][l], marker=".", color=f"C0", alpha=1.0/10)
      for k in range(len(data[0, j]["outside_iqr"]["velocity_percentage_septal_wall"])):
        for l in range(len(data[0, j]["outside_iqr"]["velocity_percentage_septal_wall"][k])):
          axes[2][j].scatter(parameter_values[j][k], data[0, j]["outside_iqr"]["velocity_percentage_septal_wall"][k][l], marker=".", color=f"C1", alpha=1.0/10)
      for k in range(len(data[0, j]["outside_iqr"]["velocity_percentage_marginal_sinus"])):
        for l in range(len(data[0, j]["outside_iqr"]["velocity_percentage_marginal_sinus"][k])):
          axes[2][j].scatter(parameter_values[j][k], data[0, j]["outside_iqr"]["velocity_percentage_marginal_sinus"][k][l], marker=".", color=f"C2", alpha=1.0/10)
    axes[2][j].plot(parameter_values[j], data[0, j]["q50"]["velocity_percentage_basal_plate"], linestyle="dashed", color="C0")
    axes[2][j].plot(parameter_values[j], data[0, j]["q50"]["velocity_percentage_septal_wall"], linestyle="dashed", color="C1")
    axes[2][j].plot(parameter_values[j], data[0, j]["q50"]["velocity_percentage_marginal_sinus"], linestyle="dashed", color="C2")
    axes[2][j].fill_between(parameter_values[j], data[0, j]["q25"]["velocity_percentage_basal_plate"], data[0, j]["q75"]["velocity_percentage_basal_plate"], alpha=0.2, color="C0")
    axes[2][j].fill_between(parameter_values[j], data[0, j]["q25"]["velocity_percentage_septal_wall"], data[0, j]["q75"]["velocity_percentage_septal_wall"], alpha=0.2, color="C1")
    axes[2][j].fill_between(parameter_values[j], data[0, j]["q25"]["velocity_percentage_marginal_sinus"], data[0, j]["q75"]["velocity_percentage_marginal_sinus"], alpha=0.2, color="C2")
    axes[2][j].legend(handles=handles[0:3], labels=[r"$S = \Gamma_\text{out,bp}$", r"$S = \Gamma_\text{out,sw}$", r"$S = \Gamma_\text{out,ms}$"])

  # AXES 4: Cross-flux velocity.
  for j in range(3):
    for i in range(2):
      if not (j == 2 and i > 0):
        if plot_outliers:
          for k in range(len(data[i, j]["outside_iqr"]["velocity_cross_flow_flux"])):
            for l in range(len(data[i, j]["outside_iqr"]["velocity_cross_flow_flux"][k])):
              axes[3][j].scatter(parameter_values[j][k], data[i, j]["outside_iqr"]["velocity_cross_flow_flux"][k][l], marker=".", color=f"C{i}", alpha=1.0/10)

        axes[3][j].plot(parameter_values[j], data[i, j]["q50"]["velocity_cross_flow_flux"], linestyle="dashed", color=f"C{i}")
        axes[3][j].fill_between(parameter_values[j], data[i, j]["q25"]["velocity_cross_flow_flux"], data[i, j]["q75"]["velocity_cross_flow_flux"], alpha=0.2, color=f"C{i}")
  axes[3][0].legend(handles=handles[0:2], labels=[r"any $N_\text{V}$", r"$N_\text{V} = 27$"])
  axes[3][1].legend(handles=handles[0:2], labels=[r"any $N_\text{A}$", r"$N_\text{A} = 6$"])

  # AXES 5: Transport reaction integral.
  for j in range(3):
    for i in range(2):
      if not (j == 2 and i > 0):
        if plot_outliers:
          for k in range(len(data[i, j]["outside_iqr"]["transport_reaction_integral"])):
            for l in range(len(data[i, j]["outside_iqr"]["transport_reaction_integral"][k])):
              axes[4][j].scatter(parameter_values[j][k], data[i, j]["outside_iqr"]["transport_reaction_integral"][k][l], marker=".", color=f"C{i}", alpha=1.0/10)

        axes[4][j].plot(parameter_values[j], data[i, j]["q50"]["transport_reaction_integral"], linestyle="dashed", color=f"C{i}")
        axes[4][j].fill_between(parameter_values[j], data[i, j]["q25"]["transport_reaction_integral"], data[i, j]["q75"]["transport_reaction_integral"], alpha=0.2, color=f"C{i}")
    if plot_outliers:
      for k in range(len(data[0, j]["outside_iqr"]["transport_reaction_integral"])):
        for l in range(len(data[0, j]["outside_iqr"]["transport_reaction_integral"][k])):
          axes_mini[1][j].scatter(parameter_values[j][k], data[0, j]["outside_iqr"]["transport_reaction_integral"][k][l], marker=".", color=f"C0", alpha=1.0/10)
    axes_mini[1][j].plot(parameter_values[j], data[0, j]["q50"]["transport_reaction_integral"], linestyle="dashed", color=f"C0")
    axes_mini[1][j].fill_between(parameter_values[j], data[0, j]["q25"]["transport_reaction_integral"], data[0, j]["q75"]["transport_reaction_integral"], alpha=0.2, color=f"C0")
  axes[4][0].legend(handles=handles[0:2], labels=[r"any $N_\text{V}$", r"$N_\text{V} = 27$"], loc="lower right")
  axes[4][1].legend(handles=handles[0:2], labels=[r"any $N_\text{A}$", r"$N_\text{A} = 6$"], loc="lower left")

  # AXES 6: Concentration flux through different veins.
  for j in range(3):
    if plot_outliers:
      for k in range(len(data[0, j]["outside_iqr"]["transport_percentage_basal_plate"])):
        for l in range(len(data[0, j]["outside_iqr"]["transport_percentage_basal_plate"][k])):
          axes[5][j].scatter(parameter_values[j][k], data[0, j]["outside_iqr"]["transport_percentage_basal_plate"][k][l], marker=".", color=f"C0", alpha=1.0/10)
      for k in range(len(data[0, j]["outside_iqr"]["transport_percentage_septal_wall"])):
        for l in range(len(data[0, j]["outside_iqr"]["transport_percentage_septal_wall"][k])):
          axes[5][j].scatter(parameter_values[j][k], data[0, j]["outside_iqr"]["transport_percentage_septal_wall"][k][l], marker=".", color=f"C1", alpha=1.0/10)
      for k in range(len(data[0, j]["outside_iqr"]["transport_percentage_marginal_sinus"])):
        for l in range(len(data[0, j]["outside_iqr"]["transport_percentage_marginal_sinus"][k])):
          axes[5][j].scatter(parameter_values[j][k], data[0, j]["outside_iqr"]["transport_percentage_marginal_sinus"][k][l], marker=".", color=f"C2", alpha=1.0/10)
    axes[5][j].plot(parameter_values[j], data[0, j]["q50"]["transport_percentage_basal_plate"], linestyle="dashed", color="C0")
    axes[5][j].plot(parameter_values[j], data[0, j]["q50"]["transport_percentage_septal_wall"], linestyle="dashed", color="C1")
    axes[5][j].plot(parameter_values[j], data[0, j]["q50"]["transport_percentage_marginal_sinus"], linestyle="dashed", color="C2")
    axes[5][j].fill_between(parameter_values[j], data[0, j]["q25"]["transport_percentage_basal_plate"], data[0, j]["q75"]["transport_percentage_basal_plate"], alpha=0.2, color="C0")
    axes[5][j].fill_between(parameter_values[j], data[0, j]["q25"]["transport_percentage_septal_wall"], data[0, j]["q75"]["transport_percentage_septal_wall"], alpha=0.2, color="C1")
    axes[5][j].fill_between(parameter_values[j], data[0, j]["q25"]["transport_percentage_marginal_sinus"], data[0, j]["q75"]["transport_percentage_marginal_sinus"], alpha=0.2, color="C2")
    axes[5][j].legend(handles=handles[0:3], labels=[r"$S = \Gamma_\text{out,bp}$", r"$S = \Gamma_\text{out,sw}$", r"$S = \Gamma_\text{out,ms}$"], loc='upper right')

  # AXES 7: Kinetic energy flux difference.
  for j in range(3):
    for i in range(2):
      if not (j == 2 and i > 0):
        if plot_outliers:
          for k in range(len(data[i, j]["outside_iqr"]["kinetic_energy_flux"])):
            for l in range(len(data[i, j]["outside_iqr"]["kinetic_energy_flux"][k])):
              axes[6][j].scatter(parameter_values[j][k], data[i, j]["data"]["kinetic_energy_flux"][k][l], marker=".", color=f"C{i}", alpha=1.0/10)

        axes[6][j].plot(parameter_values[j], data[i, j]["q50"]["kinetic_energy_flux"], linestyle="dashed", color=f"C{i}")
        axes[6][j].fill_between(parameter_values[j], data[i, j]["q25"]["kinetic_energy_flux"], data[i, j]["q75"]["kinetic_energy_flux"], alpha=0.2, color=f"C{i}")
      # Just for ratio.
      # if (j == 2):
      #   analytic_parameter_values = np.linspace(27/100, 27, 100)
      #   axes[6][j].plot(analytic_parameter_values, 1 - 1.0/9.0*analytic_parameter_values**(-2), linestyle="dotted", color=f"k")
  axes[6][0].legend(handles=handles[0:2], labels=[r"any $N_\text{V}$", r"$N_\text{V} = 27$"], loc="lower right")
  axes[6][1].legend(handles=handles[0:2], labels=[r"any $N_\text{A}$", r"$N_\text{A} = 6$"], loc="lower right")

  # AXES 8: Total energy flux difference.
  for j in range(3):
    for i in range(2):
      if not (j == 2 and i > 0):
        if plot_outliers:
          for k in range(len(data[i, j]["outside_iqr"]["total_energy_flux"])):
            for l in range(len(data[i, j]["outside_iqr"]["total_energy_flux"][k])):
              axes[7][j].scatter(parameter_values[j][k], data[i, j]["data"]["total_energy_flux"][k][l], marker=".", color=f"C{i}", alpha=1.0/10)

        axes[7][j].plot(parameter_values[j], data[i, j]["q50"]["total_energy_flux"], linestyle="dashed", color=f"C{i}")
        axes[7][j].fill_between(parameter_values[j], data[i, j]["q25"]["total_energy_flux"], data[i, j]["q75"]["total_energy_flux"], alpha=0.2, color=f"C{i}")
  axes[7][0].legend(handles=handles[0:2], labels=[r"any $N_\text{V}$", r"$N_\text{V} = 27$"], loc="lower right")
  axes[7][1].legend(handles=handles[0:2], labels=[r"any $N_\text{A}$", r"$N_\text{A} = 6$"], loc="lower right")

  # Plot indiviudal simulations on mini axes.
  simulation_nos = [90, 70, 122, 444]
  colours = ["tab:orange", "tab:purple", "tab:green", "tab:red"]
  for i in range(4):
    sim_no = simulation_nos[i]

    no_arteries = simulations[sim_no-1].get_no_arteries()
    no_veins = simulations[sim_no-1].get_no_veins()

    axes_mini[0][0].plot(no_arteries,          simulations[sim_no-1].velocity_magnitude_integral_ivs, 'X', markersize=10, linewidth=3, color=colours[i], markeredgecolor='white')
    axes_mini[0][1].plot(no_veins,             simulations[sim_no-1].velocity_magnitude_integral_ivs, 'X', markersize=10, linewidth=3, color=colours[i], markeredgecolor='white')
    axes_mini[0][2].plot(no_veins/no_arteries, simulations[sim_no-1].velocity_magnitude_integral_ivs, 'X', markersize=10, linewidth=3, color=colours[i], markeredgecolor='white')

    axes_mini[1][0].plot(no_arteries,          simulations[sim_no-1].transport_reaction_integral,     'X', markersize=10, linewidth=3, color=colours[i], markeredgecolor='white')
    axes_mini[1][1].plot(no_veins,             simulations[sim_no-1].transport_reaction_integral,     'X', markersize=10, linewidth=3, color=colours[i], markeredgecolor='white')
    axes_mini[1][2].plot(no_veins/no_arteries, simulations[sim_no-1].transport_reaction_integral,     'X', markersize=10, linewidth=3, color=colours[i], markeredgecolor='white')

  # Style plots.
  setup_plots.style(fig, axes[0][0], None, r"$\bar{v}(\Omega_\text{IVS})$", y_scilimits=[-3, -3] , y_bottom=0, y_top=1e-2, integer_ticks=True)
  setup_plots.style(fig, axes[1][0], None, r"$v_\text{slow}(V_\text{threshold})$", y_scilimits=None , y_top=102, integer_ticks=True)
  setup_plots.style(fig, axes[2][0], None, r"$\frac{v_\text{flux}(S)}{v_\text{flux}(\Gamma_\text{in})}$ (%)", y_scilimits=None , y_top=145, integer_ticks=True)
  setup_plots.style(fig, axes[3][0], None, r"$v_\text{cross}$", y_scilimits=[-3, -3] , y_bottom=0, y_top=2e-2, integer_ticks=True)
  setup_plots.style(fig, axes[4][0], None, r"$\bar{c}$", y_scilimits=[-3, -3], y_bottom=0, y_top=2e-3, integer_ticks=True)
  setup_plots.style(fig, axes[5][0], None, r"$\frac{C_\text{flux}(S)}{C_\text{flux}(\Gamma_\text{in})}$ (%)", y_scilimits=None , y_top=120, integer_ticks=True)
  setup_plots.style(fig, axes[6][0], None, r"$\frac{E_\text{kinetic}(\Gamma_\text{in}) - E_\text{kinetic}(\Gamma_\text{out})}{E_\text{kinetic}(\Gamma_\text{in})}$", y_scilimits=None, y_bottom=0.6, y_top=1.02, integer_ticks=True)
  setup_plots.style(fig, axes[7][0], parameter_name[0], r"$\frac{E_\text{total}(\Gamma_\text{in}) - E_\text{total}(\Gamma_\text{out})}{E_\text{total}(\Gamma_\text{in})}$", y_scilimits=[-1, -1], y_bottom=0.95, y_top=1.005, integer_ticks=True)

  setup_plots.style(fig, axes[0][1], None, None, y_scilimits=[-3, -3], y_bottom=0, y_top=1e-2, integer_ticks=True, max_major_ticks=4)
  setup_plots.style(fig, axes[1][1], None, None, y_scilimits=None , y_top=102, integer_ticks=True, max_major_ticks=4)
  setup_plots.style(fig, axes[2][1], None, None, y_scilimits=None , y_top=145, integer_ticks=True, max_major_ticks=4)
  setup_plots.style(fig, axes[3][1], None, None, y_scilimits=[-3, -3], y_bottom=0, y_top=2e-2, integer_ticks=True, max_major_ticks=4)
  setup_plots.style(fig, axes[4][1], None, None, y_scilimits=[-3, -3], y_bottom=0, y_top=2e-3, integer_ticks=True, max_major_ticks=4)
  setup_plots.style(fig, axes[5][1], None, None, y_scilimits=None , y_top=120, integer_ticks=True, max_major_ticks=4)
  setup_plots.style(fig, axes[6][1], None, None, y_scilimits=None, y_bottom=0.6, y_top=1.02, integer_ticks=True, max_major_ticks=4)
  setup_plots.style(fig, axes[7][1], parameter_name[1], None, y_scilimits=[-1, -1], y_bottom=0.95, y_top=1.005, integer_ticks=True, max_major_ticks=4)

  setup_plots.style(fig, axes[0][2], None, None, y_scilimits=[-3, -3], y_bottom=0, y_top=1e-2, integer_ticks=True, max_major_ticks=4)
  setup_plots.style(fig, axes[1][2], None, None, y_scilimits=None , y_top=102, integer_ticks=True, max_major_ticks=4)
  setup_plots.style(fig, axes[2][2], None, None, y_scilimits=None , y_top=145, integer_ticks=True, max_major_ticks=4)
  setup_plots.style(fig, axes[3][2], None, None, y_scilimits=[-3, -3], y_bottom=0, y_top=2e-2, integer_ticks=True, max_major_ticks=4)
  setup_plots.style(fig, axes[4][2], None, None, y_scilimits=[-3, -3], y_bottom=0, y_top=2e-3, integer_ticks=True, max_major_ticks=4)
  setup_plots.style(fig, axes[5][2], None, None, y_scilimits=None , y_top=120, integer_ticks=True, max_major_ticks=4)
  setup_plots.style(fig, axes[6][2], None, None, y_scilimits=None, y_bottom=0.6, y_top=1.02, integer_ticks=True, max_major_ticks=4)
  setup_plots.style(fig, axes[7][2], parameter_name[2], None, y_scilimits=[-1, -1], y_bottom=0.95, y_top=1.005, integer_ticks=True, max_major_ticks=4)

  setup_plots.style(fig_mini, axes_mini[0][0], None, r"$\bar{v}(\Omega_\text{IVS})$", y_scilimits=[-3, -3] , y_bottom=0, y_top=1e-2, integer_ticks=True)
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