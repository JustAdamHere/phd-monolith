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
  
  # 1
  velocity_magnitude_integral = [[] for i in range(no_bins)]
  # 2
  slow_velocity_percentage_ivs                = [[] for i in range(no_bins)]
  slow_velocity_percentage_everywhere         = [[] for i in range(no_bins)]
  slow_velocity_percentage_dellschaft         = [[] for i in range(no_bins)]
  fast_velocity_percentage_dellschaft         = [[] for i in range(no_bins)]
  slow_velocity_percentage_nominal_everywhere = [[] for i in range(no_bins)]
  # 3
  transport_reaction_integral = [[] for i in range(no_bins)]
  # 4
  kinetic_energy_flux = [[] for i in range(no_bins)]
  # 5
  total_energy_flux = [[] for i in range(no_bins)]
  # 6
  velocity_cross_flow_flux = [[] for i in range(no_bins)]
  # 7
  transport_flux = [[] for i in range(no_bins)]

  # Averages.
  average_velocity_magnitude_integral                 = []
  average_slow_velocity_percentage_ivs                = []
  average_slow_velocity_percentage_everywhere         = []
  average_slow_velocity_percentage_dellschaft         = []
  average_fast_velocity_percentage_dellschaft         = []
  average_slow_velocity_percentage_nominal_everywhere = []
  average_transport_reaction_integral                 = []
  average_kinetic_energy_flux                         = []
  average_total_energy_flux                           = []
  average_velocity_cross_flow_flux                    = []
  average_transport_flux                       = []
  for i in range(0, no_bins):
    for j in range(0, len(simulation_bins[i])):
      run_no = simulation_bins[i][j]

      velocity_magnitude_integral                 [i].append(simulations[run_no-1].velocity_magnitude_integral_ivs             )
      slow_velocity_percentage_ivs                [i].append(simulations[run_no-1].slow_velocity_percentage_ivs                )
      slow_velocity_percentage_everywhere         [i].append(simulations[run_no-1].slow_velocity_percentage_everywhere         )
      slow_velocity_percentage_dellschaft         [i].append(simulations[run_no-1].slow_velocity_percentage_dellschaft         )
      fast_velocity_percentage_dellschaft         [i].append(simulations[run_no-1].fast_velocity_percentage_dellschaft         )
      slow_velocity_percentage_nominal_everywhere [i].append(simulations[run_no-1].slow_velocity_percentage_nominal_everywhere )
      transport_reaction_integral                 [i].append(simulations[run_no-1].transport_reaction_integral                 )
      kinetic_energy_flux                         [i].append(simulations[run_no-1].kinetic_energy_flux                         )
      total_energy_flux                           [i].append(simulations[run_no-1].total_energy_flux                           )
      velocity_cross_flow_flux                    [i].append(simulations[run_no-1].abs_velocity_cross_flow_flux                )
      transport_flux                              [i].append(simulations[run_no-1].transport_flux                              )

    if (len(simulation_bins[i]) > 0):
      average_velocity_magnitude_integral                 .append(np.mean(velocity_magnitude_integral                 [i]))
      average_slow_velocity_percentage_ivs                .append(np.mean(slow_velocity_percentage_ivs                [i]))
      average_slow_velocity_percentage_everywhere         .append(np.mean(slow_velocity_percentage_everywhere         [i]))
      average_slow_velocity_percentage_dellschaft         .append(np.mean(slow_velocity_percentage_dellschaft         [i]))
      average_fast_velocity_percentage_dellschaft         .append(np.mean(fast_velocity_percentage_dellschaft         [i]))
      average_slow_velocity_percentage_nominal_everywhere .append(np.mean(slow_velocity_percentage_nominal_everywhere [i]))
      average_transport_reaction_integral                 .append(np.mean(transport_reaction_integral                 [i]))
      average_kinetic_energy_flux                         .append(np.mean(kinetic_energy_flux                         [i]))
      average_total_energy_flux                           .append(np.mean(total_energy_flux                           [i]))
      average_velocity_cross_flow_flux                    .append(np.mean(velocity_cross_flow_flux                    [i]))
      average_transport_flux                              .append(np.mean(transport_flux                              [i]))
    else:
      average_velocity_magnitude_integral                 .append(float('nan'))
      average_slow_velocity_percentage_ivs                .append(float('nan'))
      average_slow_velocity_percentage_everywhere         .append(float('nan'))
      average_slow_velocity_percentage_dellschaft         .append(float('nan'))
      average_fast_velocity_percentage_dellschaft         .append(float('nan'))
      average_slow_velocity_percentage_nominal_everywhere .append(float('nan'))
      average_transport_reaction_integral                 .append(float('nan'))
      average_kinetic_energy_flux                         .append(float('nan'))
      average_total_energy_flux                           .append(float('nan'))
      average_velocity_cross_flow_flux                    .append(float('nan'))
      average_transport_flux                              .append(float('nan'))

  output = {
    'data' : {
      'velocity_magnitude_integral'                 : velocity_magnitude_integral                 ,
      'slow_velocity_percentage_ivs'                : slow_velocity_percentage_ivs                ,
      'slow_velocity_percentage_everywhere'         : slow_velocity_percentage_everywhere         ,
      'slow_velocity_percentage_dellschaft'         : slow_velocity_percentage_dellschaft         ,
      'fast_velocity_percentage_dellschaft'         : fast_velocity_percentage_dellschaft         ,
      'slow_velocity_percentage_nominal_everywhere' : slow_velocity_percentage_nominal_everywhere ,
      'transport_reaction_integral'                 : transport_reaction_integral                 ,
      'kinetic_energy_flux'                         : kinetic_energy_flux                         ,
      'total_energy_flux'                           : total_energy_flux                           ,
      'velocity_cross_flow_flux'                    : velocity_cross_flow_flux                    ,
      'transport_flux'                              : transport_flux
    },
    'averages' : {
      'velocity_magnitude_integral'                 : average_velocity_magnitude_integral                 ,
      'slow_velocity_percentage_ivs'                : average_slow_velocity_percentage_ivs                ,
      'slow_velocity_percentage_everywhere'         : average_slow_velocity_percentage_everywhere         ,
      'slow_velocity_percentage_dellschaft'         : average_slow_velocity_percentage_dellschaft         ,
      'fast_velocity_percentage_dellschaft'         : average_fast_velocity_percentage_dellschaft         ,
      'slow_velocity_percentage_nominal_everywhere' : average_slow_velocity_percentage_nominal_everywhere ,
      'transport_reaction_integral'                 : average_transport_reaction_integral                 ,
      'kinetic_energy_flux'                         : average_kinetic_energy_flux                         ,
      'total_energy_flux'                           : average_total_energy_flux                           ,
      'velocity_cross_flow_flux'                    : average_velocity_cross_flow_flux                    ,
      'transport_flux'                              : average_transport_flux
    }
  }

  return output