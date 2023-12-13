import matplotlib.pyplot as plt

def setup(plot_no):
  fig = plt.figure(plot_no)
  fig.clf()
  ax = fig.add_subplot(111)
  ax.cla()

  return fig, ax

def plot(axis, parameter_values, box_plot_data, average_data, box_plot_width=0.75):
  axis.boxplot(box_plot_data, positions=parameter_values, widths=box_plot_width)
  axis.plot(parameter_values, average_data, 'k--')

def style(figure, axis, x_parameter_name, y_parameter_name, y_scilimits=None, y_bottom=0, y_top=None, integer_ticks=True, xlim=None):
  if (integer_ticks):
    axis.xaxis.set_major_formatter(plt.FormatStrFormatter('%d'))
  else:
    axis.xaxis.set_major_formatter(plt.FormatStrFormatter('%.3f'))
  axis.xaxis.set_major_locator(plt.MaxNLocator(10, integer=integer_ticks, prune='both'))
  axis.set_ylim(bottom=y_bottom)
  if (xlim != None):
    axis.set_xlim(xlim[0], xlim[1])
  if (y_top != None):
    axis.set_ylim(top=y_top)
  if (y_scilimits != None):
    axis.ticklabel_format(style="sci", axis='y', scilimits=(y_scilimits[0], y_scilimits[1]))
  axis.tick_params(axis='both', which='major', labelsize=18)
  axis.set_xlabel(f"{x_parameter_name}", fontsize=18)
  axis.set_ylabel(f"{y_parameter_name}", fontsize=18)
  # axis.set_title(f"{y_parameter_name}\nagainst {x_parameter_name}")
  
  figure.tight_layout()

def get_data(no_bins, simulation_bins, simulations):
  import numpy as np
  
  transport_reaction_integrals         = [[] for i in range(no_bins)]
  velocity_magnitude_integrals         = [[] for i in range(no_bins)]
  slow_velocity_percentages_ivs        = [[] for i in range(no_bins)]
  slow_velocity_percentages_everywhere = [[] for i in range(no_bins)]
  slow_velocity_percentage_dellschaft  = [[] for i in range(no_bins)]
  fast_velocity_percentage_dellschaft  = [[] for i in range(no_bins)]
  velocity_cross_flow_fluxes           = [[] for i in range(no_bins)]
  transport_cross_flow_fluxes          = [[] for i in range(no_bins)]
  average_transport_reaction_integral         = []
  average_velocity_magnitude_integral         = []
  average_slow_velocity_percentage_ivs        = []
  average_slow_velocity_percentage_everywhere = []
  average_slow_velocity_percentage_dellschaft = []
  average_fast_velocity_percentage_dellschaft = []
  average_velocity_cross_flow_flux            = []
  average_transport_cross_flow_flux           = []
  for i in range(0, no_bins):
    for j in range(0, len(simulation_bins[i])):
      run_no = simulation_bins[i][j]
      transport_reaction_integrals        [i].append(simulations[run_no-1].transport_reaction_integral        )
      velocity_magnitude_integrals        [i].append(simulations[run_no-1].velocity_magnitude_integral_ivs    )
      slow_velocity_percentages_ivs       [i].append(simulations[run_no-1].slow_velocity_percentage_ivs       )
      slow_velocity_percentages_everywhere[i].append(simulations[run_no-1].slow_velocity_percentage_everywhere)
      slow_velocity_percentage_dellschaft [i].append(simulations[run_no-1].slow_velocity_percentage_dellschaft)
      fast_velocity_percentage_dellschaft [i].append(simulations[run_no-1].fast_velocity_percentage_dellschaft)
      velocity_cff  = simulations[run_no-1].velocity_cross_flow_fluxes
      transport_cff = simulations[run_no-1].transport_cross_flow_fluxes
      velocity_cross_flow_fluxes          [i].append(np.sum(np.abs(velocity_cff)))
      transport_cross_flow_fluxes         [i].append(np.sum(np.abs(transport_cff)))
    if (len(simulation_bins[i]) > 0):
      average_transport_reaction_integral        .append(np.mean(transport_reaction_integrals         [i]))
      average_velocity_magnitude_integral        .append(np.mean(velocity_magnitude_integrals         [i]))
      average_slow_velocity_percentage_ivs       .append(np.mean(slow_velocity_percentages_ivs        [i]))
      average_slow_velocity_percentage_everywhere.append(np.mean(slow_velocity_percentages_everywhere [i]))
      average_slow_velocity_percentage_dellschaft.append(np.mean(slow_velocity_percentage_dellschaft  [i]))
      average_fast_velocity_percentage_dellschaft.append(np.mean(fast_velocity_percentage_dellschaft  [i]))
      average_velocity_cross_flow_flux           .append(np.mean(velocity_cross_flow_fluxes           [i]))
      average_transport_cross_flow_flux          .append(np.mean(transport_cross_flow_fluxes          [i]))
    else:
      average_transport_reaction_integral        .append(float('nan'))
      average_velocity_magnitude_integral        .append(float('nan'))
      average_slow_velocity_percentage_ivs       .append(float('nan'))
      average_slow_velocity_percentage_everywhere.append(float('nan'))
      average_slow_velocity_percentage_dellschaft.append(float('nan'))
      average_fast_velocity_percentage_dellschaft.append(float('nan'))
      average_velocity_cross_flow_flux           .append(float('nan'))
      average_transport_cross_flow_flux          .append(float('nan'))

  data = [transport_reaction_integrals, velocity_magnitude_integrals, slow_velocity_percentages_ivs, slow_velocity_percentages_everywhere, slow_velocity_percentage_dellschaft, fast_velocity_percentage_dellschaft, velocity_cross_flow_fluxes, transport_cross_flow_fluxes]
  averages = [average_transport_reaction_integral, average_velocity_magnitude_integral, average_slow_velocity_percentage_ivs, average_slow_velocity_percentage_everywhere, average_slow_velocity_percentage_dellschaft, average_fast_velocity_percentage_dellschaft, average_velocity_cross_flow_flux, average_transport_cross_flow_flux]

  return data[0], data[1], data[2], data[3], data[4], data[5], data[6], data[7], averages[0], averages[1], averages[2], averages[3], averages[4], averages[5], averages[6], averages[7]