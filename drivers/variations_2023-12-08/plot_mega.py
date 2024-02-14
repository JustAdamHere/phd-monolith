def plot(simulations, simulation_bins, parameter_values, parameter_name, parameter_safe_name, subfolder=None):
  import numpy as np

  print(f"\rPlotting simulations...", end="")
  no_bins = len(simulation_bins[0])

  # Setup plots.
  from plotting import setup_plots
  fig, axes = setup_plots.setup_megaplot(1, 8, 2, figsize=(8, 18))

  # Get data to plot.
  data = np.zeros(2, dtype=object)
  for i in range(2):
    data[i] = setup_plots.get_data(no_bins, simulation_bins[i], simulations[i])

  # Patches for legends.
  import matplotlib.patches as mpatches
  patch_any = mpatches.Patch(color="C0", label='any veins')
  patch_27  = mpatches.Patch(color="C1", label='27 veins')

  # Plot data.
  for i in range(2):
    axes[0][0].plot(parameter_values, data[i]["q50"]["velocity_magnitude_integral"], linestyle="dashed", color=f"C{i}")
    axes[0][0].legend(["any #veins", "27 veins"], loc="upper left")
    axes[0][0].fill_between(parameter_values, data[i]["q25"]["velocity_magnitude_integral"], data[i]["q75"]["velocity_magnitude_integral"], alpha=0.2, color=f"C{i}")

  axes[0][0].legend(handles=[patch_any, patch_27])

  # Style plots.
  setup_plots.style(fig, axes[0][0], None, r"$\bar{v}$", y_scilimits=[-3, -3] , y_bottom=0, integer_ticks=True)
  setup_plots.style(fig, axes[1][0], None, r"$v_\text{slow}(V_\text{threshold})$", y_scilimits=None , y_top=102, integer_ticks=True)
  setup_plots.style(fig, axes[2][0], None, r"$\frac{v_\text{flux}(S)}{v_\text{flux}(\Gamma_\text{in})}$", y_scilimits=None , y_top=102, integer_ticks=True)
  setup_plots.style(fig, axes[3][0], None, r"$v_\text{cross}$", y_scilimits=None , y_top=102, integer_ticks=True)
  setup_plots.style(fig, axes[4][0], None, r"$\bar{c}$", y_scilimits=None , y_top=102, integer_ticks=True)
  setup_plots.style(fig, axes[5][0], None, r"$c_\text{flux}(\Gamma_\text{in}) - c_\text{flux}(\Gamma_\text{out})$", y_scilimits=None , y_top=102, integer_ticks=True)
  setup_plots.style(fig, axes[6][0], None, r"$E_\text{kinetic}(\Gamma_\text{in}) - E_\text{kinetic}(\Gamma_\text{out})$", y_scilimits=None , y_top=102, integer_ticks=True)
  setup_plots.style(fig, axes[7][0], parameter_name[0], r"$E_\text{total}(\Gamma_\text{in}) - E_\text{total}(\Gamma_\text{out})$", y_scilimits=None , y_top=102, integer_ticks=True)

  setup_plots.style(fig, axes[0][1], None, None, y_scilimits=[-3, -3] , y_bottom=0, integer_ticks=True)
  setup_plots.style(fig, axes[1][1], None, None, y_scilimits=None , y_top=102, integer_ticks=True)
  setup_plots.style(fig, axes[2][1], None, None, y_scilimits=None , y_top=102, integer_ticks=True)
  setup_plots.style(fig, axes[3][1], None, None, y_scilimits=None , y_top=102, integer_ticks=True)
  setup_plots.style(fig, axes[4][1], None, None, y_scilimits=None , y_top=102, integer_ticks=True)
  setup_plots.style(fig, axes[5][1], None, None, y_scilimits=None , y_top=102, integer_ticks=True)
  setup_plots.style(fig, axes[6][1], None, None, y_scilimits=None , y_top=102, integer_ticks=True)
  setup_plots.style(fig, axes[7][1], parameter_name[1], None, y_scilimits=None , y_top=102, integer_ticks=True)

  # Decide where to save plots.
  if subfolder == None:
    images_folder = "images"
  else:
    images_folder = f"images/{subfolder}"

  # Save.
  fig.savefig(f"{images_folder}/mega_{parameter_safe_name}.png", dpi=300)

  # Done.
  print(f"\rPlotting simulations... Done.", end="\r\n")