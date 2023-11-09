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

def style(axis, x_parameter_name, y_parameter_name, y_scilimits=None, y_bottom=0, y_top=None):
  axis.xaxis.set_major_formatter(plt.FormatStrFormatter('%d'))
  axis.xaxis.set_major_locator  (plt.MaxNLocator(10, integer=True, prune='both'))
  axis.set_ylim(bottom=y_bottom)
  if (y_top != None):
    axis.set_ylim(top=y_top)
  if (y_scilimits != None):
    axis.ticklabel_format(style="sci", axis='y', scilimits=(y_scilimits[0], y_scilimits[1]))
  axis.set_xlabel(f"{x_parameter_name}")
  axis.set_ylabel(f"{y_parameter_name}")
  axis.set_title(f"{y_parameter_name}\nagainst {x_parameter_name}")

def get_data(no_bins, simulation_bins, simulations):
  import numpy as np
  
  transport_reaction_integrals = [[] for i in range(no_bins)]
  velocity_magnitude_integrals = [[] for i in range(no_bins)]
  slow_velocity_percentages_i  = [[] for i in range(no_bins)]
  slow_velocity_percentages_e  = [[] for i in range(no_bins)]
  average_transport_reaction_integral = []
  average_velocity_magnitude_integral = []
  average_slow_velocity_percentage_i  = []
  average_slow_velocity_percentage_e  = []
  for i in range(0, no_bins):
    for j in range(0, len(simulation_bins[i])):
      run_no = simulation_bins[i][j]
      transport_reaction_integrals[i].append(simulations[run_no-1].transport_reaction_integral)
      velocity_magnitude_integrals[i].append(simulations[run_no-1].velocity_magnitude_integral_ivs)
      slow_velocity_percentages_i [i].append(simulations[run_no-1].slow_velocity_percentage_ivs)
      slow_velocity_percentages_e [i].append(simulations[run_no-1].slow_velocity_percentage_everywhere)
      #slow_velocity_percentages   [i].append(simulations[run_no-1].slow_velocity_percentage_0_05)
      #slow_velocity_percentages   [i].append(simulations[run_no-1].fast_velocity_percentage_0_1)
    if (len(simulation_bins[i]) > 0):
      average_transport_reaction_integral.append(np.mean(transport_reaction_integrals[i]))
      average_velocity_magnitude_integral.append(np.mean(velocity_magnitude_integrals[i]))
      average_slow_velocity_percentage_i .append(np.mean(slow_velocity_percentages_i [i]))
      average_slow_velocity_percentage_e .append(np.mean(slow_velocity_percentages_e [i]))
    else:
      average_transport_reaction_integral.append(float('nan'))
      average_velocity_magnitude_integral.append(float('nan'))
      average_slow_velocity_percentage_i .append(float('nan'))
      average_slow_velocity_percentage_e .append(float('nan'))

  return transport_reaction_integrals, velocity_magnitude_integrals, slow_velocity_percentages_i, slow_velocity_percentages_e, average_transport_reaction_integral, average_velocity_magnitude_integral, average_slow_velocity_percentage_i, average_slow_velocity_percentage_e