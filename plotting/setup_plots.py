import matplotlib.pyplot as plt

def setup(plot_no):
  fig = plt.figure(plot_no)
  fig.clf()
  ax = fig.add_subplot(111)
  ax.cla()

  return fig, ax

def setup_megaplot(plot_no, no_rows, no_cols, **kwargs):
  fig = plt.figure(plot_no, **kwargs)
  fig.clf()
  axes = fig.subplots(no_rows, no_cols)
  for i in range(no_rows):
    for j in range(no_cols):
      axes[i][j].cla()

  return fig, axes

def plot(axis, parameter_values, box_plot_data, average_data, box_plot_width=0.75):
  axis.boxplot(box_plot_data, positions=parameter_values, widths=box_plot_width)
  axis.plot(parameter_values, average_data, 'k--')

def style(figure, axis, x_parameter_name, y_parameter_name, y_scilimits=None, y_bottom=None, y_top=None, integer_ticks=True, xlim=None, y_labelpad=None, max_major_ticks=6, max_minor_ticks=50):
  if (integer_ticks):
    axis.xaxis.set_major_formatter(plt.FormatStrFormatter('%d'))
  else:
    axis.xaxis.set_major_formatter(plt.FormatStrFormatter('%.3f'))
  axis.xaxis.set_major_locator(plt.MaxNLocator(max_major_ticks, integer=integer_ticks, prune='both'))
  axis.xaxis.set_minor_locator(plt.MaxNLocator(max_minor_ticks, integer=integer_ticks, prune='both'))
  if (xlim != None):
    axis.set_xlim(xlim[0], xlim[1])
  if (y_top != None):
    axis.set_ylim(top=y_top)
  if (y_bottom != None):
    axis.set_ylim(bottom=y_bottom)
  if (y_scilimits != None):
    axis.ticklabel_format(style="sci", axis='y', scilimits=(y_scilimits[0], y_scilimits[1]))
  axis.tick_params(axis='both', which='major', labelsize=18)
  if (x_parameter_name != None):
    axis.set_xlabel(f"{x_parameter_name}", fontsize=18)
  if (y_parameter_name != None):
    axis.set_ylabel(f"{y_parameter_name}", fontsize=18, labelpad=y_labelpad)
  # axis.set_title(f"{y_parameter_name}\nagainst {x_parameter_name}")
  
  figure.tight_layout()

def percentiles(data, percentage):
  import numpy as np

  output = []
  for i in range(0, len(data)):
    if (len(data[i]) == 0):
      output.append(np.nan)
    else:
      output.append(np.percentile(data[i], percentage))
  return np.array(output)

def iqr(q25, q75):
  import numpy as np

  return np.array([q75[i] - q25[i] for i in range(0, len(q25))])

def outliers(data, q25, q75):
  import numpy as np

  iqr = [q75[i] - q25[i] for i in range(0, len(q25))]
  return [data[i][np.where((data[i] < q25[i] - 1.5*iqr[i]) | (data[i] > q75[i] + 1.5*iqr[i]))] for i in range(len(data))]

def get_data(no_bins, simulation_bins, simulations):
  import numpy as np
  
  # 1
  velocity_magnitude_integral = [np.zeros(len(simulation_bins[i])) for i in range(no_bins)]
  # 2
  slow_velocity_percentage_ivs                = [np.zeros(len(simulation_bins[i])) for i in range(no_bins)]
  slow_velocity_percentage_everywhere         = [np.zeros(len(simulation_bins[i])) for i in range(no_bins)]
  slow_velocity_percentage_dellschaft         = [np.zeros(len(simulation_bins[i])) for i in range(no_bins)]
  fast_velocity_percentage_dellschaft         = [np.zeros(len(simulation_bins[i])) for i in range(no_bins)]
  slow_velocity_percentage_nominal_everywhere = [np.zeros(len(simulation_bins[i])) for i in range(no_bins)]
  # 3
  transport_reaction_integral = [np.zeros(len(simulation_bins[i])) for i in range(no_bins)]
  # 4
  kinetic_energy_flux = [np.zeros(len(simulation_bins[i])) for i in range(no_bins)]
  # 5
  total_energy_flux = [np.zeros(len(simulation_bins[i])) for i in range(no_bins)]
  # 6
  velocity_cross_flow_flux = [np.zeros(len(simulation_bins[i])) for i in range(no_bins)]
  # 7
  transport_flux = [np.zeros(len(simulation_bins[i])) for i in range(no_bins)]
  # 8 
  velocity_percentage_basal_plate     = [np.zeros(len(simulation_bins[i])) for i in range(no_bins)]
  velocity_percentage_septal_wall     = [np.zeros(len(simulation_bins[i])) for i in range(no_bins)]
  velocity_percentage_marginal_sinus  = [np.zeros(len(simulation_bins[i])) for i in range(no_bins)]
  transport_percentage_basal_plate    = [np.zeros(len(simulation_bins[i])) for i in range(no_bins)]
  transport_percentage_septal_wall    = [np.zeros(len(simulation_bins[i])) for i in range(no_bins)]
  transport_percentage_marginal_sinus = [np.zeros(len(simulation_bins[i])) for i in range(no_bins)]

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
  average_transport_flux                              = []
  average_velocity_percentage_basal_plate             = []
  average_velocity_percentage_septal_wall             = []
  average_velocity_percentage_marginal_sinus          = []
  average_transport_percentage_basal_plate            = []
  average_transport_percentage_septal_wall            = []
  average_transport_percentage_marginal_sinus         = []

  for i in range(0, no_bins):
    for j in range(0, len(simulation_bins[i])):
      run_no = simulation_bins[i][j]

      velocity_magnitude_integral                 [i][j] = simulations[run_no-1].velocity_magnitude_integral_ivs
      slow_velocity_percentage_ivs                [i][j] = simulations[run_no-1].slow_velocity_percentage_ivs
      slow_velocity_percentage_everywhere         [i][j] = simulations[run_no-1].slow_velocity_percentage_everywhere
      slow_velocity_percentage_dellschaft         [i][j] = simulations[run_no-1].slow_velocity_percentage_dellschaft
      fast_velocity_percentage_dellschaft         [i][j] = simulations[run_no-1].fast_velocity_percentage_dellschaft
      slow_velocity_percentage_nominal_everywhere [i][j] = simulations[run_no-1].slow_velocity_percentage_nominal_everywhere
      transport_reaction_integral                 [i][j] = simulations[run_no-1].transport_reaction_integral
      kinetic_energy_flux                         [i][j] = simulations[run_no-1].kinetic_energy_flux
      total_energy_flux                           [i][j] = simulations[run_no-1].total_energy_flux
      velocity_cross_flow_flux                    [i][j] = simulations[run_no-1].abs_velocity_cross_flow_flux
      transport_flux                              [i][j] = simulations[run_no-1].transport_flux
      velocity_percentage_basal_plate             [i][j] = simulations[run_no-1].velocity_percentage_basal_plate
      velocity_percentage_septal_wall             [i][j] = simulations[run_no-1].velocity_percentage_septal_wall
      velocity_percentage_marginal_sinus          [i][j] = simulations[run_no-1].velocity_percentage_marginal_sinus
      transport_percentage_basal_plate            [i][j] = simulations[run_no-1].transport_percentage_basal_plate
      transport_percentage_septal_wall            [i][j] = simulations[run_no-1].transport_percentage_septal_wall
      transport_percentage_marginal_sinus         [i][j] = simulations[run_no-1].transport_percentage_marginal_sinus

    # Calculate mean for those within IQR.
    if (len(simulation_bins[i]) > 0):
      average_velocity_magnitude_integral                 .append(np.mean(velocity_magnitude_integral                 [i])),
      average_slow_velocity_percentage_ivs                .append(np.mean(slow_velocity_percentage_ivs                [i])),
      average_slow_velocity_percentage_everywhere         .append(np.mean(slow_velocity_percentage_everywhere         [i])),
      average_slow_velocity_percentage_dellschaft         .append(np.mean(slow_velocity_percentage_dellschaft         [i])),
      average_fast_velocity_percentage_dellschaft         .append(np.mean(fast_velocity_percentage_dellschaft         [i])),
      average_slow_velocity_percentage_nominal_everywhere .append(np.mean(slow_velocity_percentage_nominal_everywhere [i])),
      average_transport_reaction_integral                 .append(np.mean(transport_reaction_integral                 [i])),
      average_kinetic_energy_flux                         .append(np.mean(kinetic_energy_flux                         [i])),
      average_total_energy_flux                           .append(np.mean(total_energy_flux                           [i])),
      average_velocity_cross_flow_flux                    .append(np.mean(velocity_cross_flow_flux                    [i])),
      average_transport_flux                              .append(np.mean(transport_flux                              [i])),
      average_velocity_percentage_basal_plate             .append(np.mean(velocity_percentage_basal_plate             [i])),
      average_velocity_percentage_septal_wall             .append(np.mean(velocity_percentage_septal_wall             [i])),
      average_velocity_percentage_marginal_sinus          .append(np.mean(velocity_percentage_marginal_sinus          [i])),
      average_transport_percentage_basal_plate            .append(np.mean(transport_percentage_basal_plate            [i])),
      average_transport_percentage_septal_wall            .append(np.mean(transport_percentage_septal_wall            [i])),
      average_transport_percentage_marginal_sinus         .append(np.mean(transport_percentage_marginal_sinus         [i]))
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
      average_velocity_percentage_basal_plate             .append(float('nan'))
      average_velocity_percentage_septal_wall             .append(float('nan'))
      average_velocity_percentage_marginal_sinus          .append(float('nan'))
      average_transport_percentage_basal_plate            .append(float('nan'))
      average_transport_percentage_septal_wall            .append(float('nan'))
      average_transport_percentage_marginal_sinus         .append(float('nan'))

  # Quartile 25.
  q25_velocity_magnitude_integral                 = percentiles(velocity_magnitude_integral                , 25)
  q25_slow_velocity_percentage_ivs                = percentiles(slow_velocity_percentage_ivs               , 25)
  q25_slow_velocity_percentage_everywhere         = percentiles(slow_velocity_percentage_everywhere        , 25)
  q25_slow_velocity_percentage_dellschaft         = percentiles(slow_velocity_percentage_dellschaft        , 25)
  q25_fast_velocity_percentage_dellschaft         = percentiles(fast_velocity_percentage_dellschaft        , 25)
  q25_slow_velocity_percentage_nominal_everywhere = percentiles(slow_velocity_percentage_nominal_everywhere, 25)
  q25_transport_reaction_integral                 = percentiles(transport_reaction_integral                , 25)
  q25_kinetic_energy_flux                         = percentiles(kinetic_energy_flux                        , 25)
  q25_total_energy_flux                           = percentiles(total_energy_flux                          , 25)
  q25_velocity_cross_flow_flux                    = percentiles(velocity_cross_flow_flux                   , 25)
  q25_transport_flux                              = percentiles(transport_flux                             , 25)
  q25_velocity_percentage_basal_plate             = percentiles(velocity_percentage_basal_plate            , 25)
  q25_velocity_percentage_septal_wall             = percentiles(velocity_percentage_septal_wall            , 25)
  q25_velocity_percentage_marginal_sinus          = percentiles(velocity_percentage_marginal_sinus         , 25)
  q25_transport_percentage_basal_plate            = percentiles(transport_percentage_basal_plate           , 25)
  q25_transport_percentage_septal_wall            = percentiles(transport_percentage_septal_wall           , 25)
  q25_transport_percentage_marginal_sinus         = percentiles(transport_percentage_marginal_sinus        , 25)

  # Quartile 50.
  q50_velocity_magnitude_integral                 = percentiles(velocity_magnitude_integral                , 50)
  q50_slow_velocity_percentage_ivs                = percentiles(slow_velocity_percentage_ivs               , 50)
  q50_slow_velocity_percentage_everywhere         = percentiles(slow_velocity_percentage_everywhere        , 50)
  q50_slow_velocity_percentage_dellschaft         = percentiles(slow_velocity_percentage_dellschaft        , 50)
  q50_fast_velocity_percentage_dellschaft         = percentiles(fast_velocity_percentage_dellschaft        , 50)
  q50_slow_velocity_percentage_nominal_everywhere = percentiles(slow_velocity_percentage_nominal_everywhere, 50)
  q50_transport_reaction_integral                 = percentiles(transport_reaction_integral                , 50)
  q50_kinetic_energy_flux                         = percentiles(kinetic_energy_flux                        , 50)
  q50_total_energy_flux                           = percentiles(total_energy_flux                          , 50)
  q50_velocity_cross_flow_flux                    = percentiles(velocity_cross_flow_flux                   , 50)
  q50_transport_flux                              = percentiles(transport_flux                             , 50)
  q50_velocity_percentage_basal_plate             = percentiles(velocity_percentage_basal_plate            , 50)
  q50_velocity_percentage_septal_wall             = percentiles(velocity_percentage_septal_wall            , 50)
  q50_velocity_percentage_marginal_sinus          = percentiles(velocity_percentage_marginal_sinus         , 50)
  q50_transport_percentage_basal_plate            = percentiles(transport_percentage_basal_plate           , 50)
  q50_transport_percentage_septal_wall            = percentiles(transport_percentage_septal_wall           , 50)
  q50_transport_percentage_marginal_sinus         = percentiles(transport_percentage_marginal_sinus        , 50)

  # Quartile 75.
  q75_velocity_magnitude_integral                 = percentiles(velocity_magnitude_integral                , 75)
  q75_slow_velocity_percentage_ivs                = percentiles(slow_velocity_percentage_ivs               , 75)
  q75_slow_velocity_percentage_everywhere         = percentiles(slow_velocity_percentage_everywhere        , 75)
  q75_slow_velocity_percentage_dellschaft         = percentiles(slow_velocity_percentage_dellschaft        , 75)
  q75_fast_velocity_percentage_dellschaft         = percentiles(fast_velocity_percentage_dellschaft        , 75)
  q75_slow_velocity_percentage_nominal_everywhere = percentiles(slow_velocity_percentage_nominal_everywhere, 75)
  q75_transport_reaction_integral                 = percentiles(transport_reaction_integral                , 75)
  q75_kinetic_energy_flux                         = percentiles(kinetic_energy_flux                        , 75)
  q75_total_energy_flux                           = percentiles(total_energy_flux                          , 75)
  q75_velocity_cross_flow_flux                    = percentiles(velocity_cross_flow_flux                   , 75)
  q75_transport_flux                              = percentiles(transport_flux                             , 75)
  q75_velocity_percentage_basal_plate             = percentiles(velocity_percentage_basal_plate            , 75)
  q75_velocity_percentage_septal_wall             = percentiles(velocity_percentage_septal_wall            , 75)
  q75_velocity_percentage_marginal_sinus          = percentiles(velocity_percentage_marginal_sinus         , 75)
  q75_transport_percentage_basal_plate            = percentiles(transport_percentage_basal_plate           , 75)
  q75_transport_percentage_septal_wall            = percentiles(transport_percentage_septal_wall           , 75)
  q75_transport_percentage_marginal_sinus         = percentiles(transport_percentage_marginal_sinus        , 75)

  # Interquartile range.
  iqr_velocity_magnitude_integral                 = iqr(q25_velocity_magnitude_integral                 , q75_velocity_magnitude_integral                )
  iqr_slow_velocity_percentage_ivs                = iqr(q25_slow_velocity_percentage_ivs                , q75_slow_velocity_percentage_ivs               )
  iqr_slow_velocity_percentage_everywhere         = iqr(q25_slow_velocity_percentage_everywhere         , q75_slow_velocity_percentage_everywhere        )
  iqr_slow_velocity_percentage_dellschaft         = iqr(q25_slow_velocity_percentage_dellschaft         , q75_slow_velocity_percentage_dellschaft        )
  iqr_fast_velocity_percentage_dellschaft         = iqr(q25_fast_velocity_percentage_dellschaft         , q75_fast_velocity_percentage_dellschaft        )
  iqr_slow_velocity_percentage_nominal_everywhere = iqr(q25_slow_velocity_percentage_nominal_everywhere , q75_slow_velocity_percentage_nominal_everywhere)
  iqr_transport_reaction_integral                 = iqr(q25_transport_reaction_integral                 , q75_transport_reaction_integral                )
  iqr_kinetic_energy_flux                         = iqr(q25_kinetic_energy_flux                         , q75_kinetic_energy_flux                        )
  iqr_total_energy_flux                           = iqr(q25_total_energy_flux                           , q75_total_energy_flux                          )
  iqr_velocity_cross_flow_flux                    = iqr(q25_velocity_cross_flow_flux                    , q75_velocity_cross_flow_flux                   )
  iqr_transport_flux                              = iqr(q25_transport_flux                              , q75_transport_flux                             )
  iqr_velocity_percentage_basal_plate             = iqr(q25_velocity_percentage_basal_plate             , q75_velocity_percentage_basal_plate            )
  iqr_velocity_percentage_septal_wall             = iqr(q25_velocity_percentage_septal_wall             , q75_velocity_percentage_septal_wall            )
  iqr_velocity_percentage_marginal_sinus          = iqr(q25_velocity_percentage_marginal_sinus          , q75_velocity_percentage_marginal_sinus         )
  iqr_transport_percentage_basal_plate            = iqr(q25_transport_percentage_basal_plate            , q75_transport_percentage_basal_plate           )
  iqr_transport_percentage_septal_wall            = iqr(q25_transport_percentage_septal_wall            , q75_transport_percentage_septal_wall           )
  iqr_transport_percentage_marginal_sinus         = iqr(q25_transport_percentage_marginal_sinus         , q75_transport_percentage_marginal_sinus        )

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
      'transport_flux'                              : transport_flux                              ,
      'velocity_percentage_basal_plate'             : velocity_percentage_basal_plate             ,
      'velocity_percentage_septal_wall'             : velocity_percentage_septal_wall             ,
      'velocity_percentage_marginal_sinus'          : velocity_percentage_marginal_sinus          ,
      'transport_percentage_basal_plate'            : transport_percentage_basal_plate            ,
      'transport_percentage_septal_wall'            : transport_percentage_septal_wall            ,
      'transport_percentage_marginal_sinus'         : transport_percentage_marginal_sinus
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
      'transport_flux'                              : average_transport_flux                              ,
      'velocity_percentage_basal_plate'             : average_velocity_percentage_basal_plate             ,
      'velocity_percentage_septal_wall'             : average_velocity_percentage_septal_wall             ,
      'velocity_percentage_marginal_sinus'          : average_velocity_percentage_marginal_sinus          ,
      'transport_percentage_basal_plate'            : average_transport_percentage_basal_plate            ,
      'transport_percentage_septal_wall'            : average_transport_percentage_septal_wall            ,
      'transport_percentage_marginal_sinus'         : average_transport_percentage_marginal_sinus
    },
    'q25' : {
      'velocity_magnitude_integral'                 : q25_velocity_magnitude_integral                ,
      'slow_velocity_percentage_ivs'                : q25_slow_velocity_percentage_ivs               ,
      'slow_velocity_percentage_everywhere'         : q25_slow_velocity_percentage_everywhere        ,
      'slow_velocity_percentage_dellschaft'         : q25_slow_velocity_percentage_dellschaft        ,
      'fast_velocity_percentage_dellschaft'         : q25_fast_velocity_percentage_dellschaft        ,
      'slow_velocity_percentage_nominal_everywhere' : q25_slow_velocity_percentage_nominal_everywhere,
      'transport_reaction_integral'                 : q25_transport_reaction_integral                ,
      'kinetic_energy_flux'                         : q25_kinetic_energy_flux                        ,
      'total_energy_flux'                           : q25_total_energy_flux                          ,
      'velocity_cross_flow_flux'                    : q25_velocity_cross_flow_flux                   ,
      'transport_flux'                              : q25_transport_flux                             ,
      'velocity_percentage_basal_plate'             : q25_velocity_percentage_basal_plate            ,
      'velocity_percentage_septal_wall'             : q25_velocity_percentage_septal_wall            ,
      'velocity_percentage_marginal_sinus'          : q25_velocity_percentage_marginal_sinus         ,
      'transport_percentage_basal_plate'            : q25_transport_percentage_basal_plate           ,
      'transport_percentage_septal_wall'            : q25_transport_percentage_septal_wall           ,
      'transport_percentage_marginal_sinus'         : q25_transport_percentage_marginal_sinus
    },
    'q50' : {
      'velocity_magnitude_integral'                 : q50_velocity_magnitude_integral                ,
      'slow_velocity_percentage_ivs'                : q50_slow_velocity_percentage_ivs               ,
      'slow_velocity_percentage_everywhere'         : q50_slow_velocity_percentage_everywhere        ,
      'slow_velocity_percentage_dellschaft'         : q50_slow_velocity_percentage_dellschaft        ,
      'fast_velocity_percentage_dellschaft'         : q50_fast_velocity_percentage_dellschaft        ,
      'slow_velocity_percentage_nominal_everywhere' : q50_slow_velocity_percentage_nominal_everywhere,
      'transport_reaction_integral'                 : q50_transport_reaction_integral                ,
      'kinetic_energy_flux'                         : q50_kinetic_energy_flux                        ,
      'total_energy_flux'                           : q50_total_energy_flux                          ,
      'velocity_cross_flow_flux'                    : q50_velocity_cross_flow_flux                   ,
      'transport_flux'                              : q50_transport_flux                             ,
      'velocity_percentage_basal_plate'             : q50_velocity_percentage_basal_plate            ,
      'velocity_percentage_septal_wall'             : q50_velocity_percentage_septal_wall            ,
      'velocity_percentage_marginal_sinus'          : q50_velocity_percentage_marginal_sinus         ,
      'transport_percentage_basal_plate'            : q50_transport_percentage_basal_plate           ,
      'transport_percentage_septal_wall'            : q50_transport_percentage_septal_wall           ,
      'transport_percentage_marginal_sinus'         : q50_transport_percentage_marginal_sinus
    },
    'q75' : {
      'velocity_magnitude_integral'                 : q75_velocity_magnitude_integral                ,
      'slow_velocity_percentage_ivs'                : q75_slow_velocity_percentage_ivs               ,
      'slow_velocity_percentage_everywhere'         : q75_slow_velocity_percentage_everywhere        ,
      'slow_velocity_percentage_dellschaft'         : q75_slow_velocity_percentage_dellschaft        ,
      'fast_velocity_percentage_dellschaft'         : q75_fast_velocity_percentage_dellschaft        ,
      'slow_velocity_percentage_nominal_everywhere' : q75_slow_velocity_percentage_nominal_everywhere,
      'transport_reaction_integral'                 : q75_transport_reaction_integral                ,
      'kinetic_energy_flux'                         : q75_kinetic_energy_flux                        ,
      'total_energy_flux'                           : q75_total_energy_flux                          ,
      'velocity_cross_flow_flux'                    : q75_velocity_cross_flow_flux                   ,
      'transport_flux'                              : q75_transport_flux                             ,
      'velocity_percentage_basal_plate'             : q75_velocity_percentage_basal_plate            ,
      'velocity_percentage_septal_wall'             : q75_velocity_percentage_septal_wall            ,
      'velocity_percentage_marginal_sinus'          : q75_velocity_percentage_marginal_sinus         ,
      'transport_percentage_basal_plate'            : q75_transport_percentage_basal_plate           ,
      'transport_percentage_septal_wall'            : q75_transport_percentage_septal_wall           ,
      'transport_percentage_marginal_sinus'         : q75_transport_percentage_marginal_sinus
    },
    'iqr' : {
      'velocity_magnitude_integral'                 : iqr_velocity_magnitude_integral                 ,
      'slow_velocity_percentage_ivs'                : iqr_slow_velocity_percentage_ivs                ,
      'slow_velocity_percentage_everywhere'         : iqr_slow_velocity_percentage_everywhere         ,
      'slow_velocity_percentage_dellschaft'         : iqr_slow_velocity_percentage_dellschaft         ,
      'fast_velocity_percentage_dellschaft'         : iqr_fast_velocity_percentage_dellschaft         ,
      'slow_velocity_percentage_nominal_everywhere' : iqr_slow_velocity_percentage_nominal_everywhere ,
      'transport_reaction_integral'                 : iqr_transport_reaction_integral                 ,
      'kinetic_energy_flux'                         : iqr_kinetic_energy_flux                         ,
      'total_energy_flux'                           : iqr_total_energy_flux                           ,
      'velocity_cross_flow_flux'                    : iqr_velocity_cross_flow_flux                    ,
      'transport_flux'                              : iqr_transport_flux                              ,
      'velocity_percentage_basal_plate'             : iqr_velocity_percentage_basal_plate             ,
      'velocity_percentage_septal_wall'             : iqr_velocity_percentage_septal_wall             ,
      'velocity_percentage_marginal_sinus'          : iqr_velocity_percentage_marginal_sinus          ,
      'transport_percentage_basal_plate'            : iqr_transport_percentage_basal_plate            ,
      'transport_percentage_septal_wall'            : iqr_transport_percentage_septal_wall            ,
      'transport_percentage_marginal_sinus'         : iqr_transport_percentage_marginal_sinus
    },
    'whisker_low' : {
      'velocity_magnitude_integral'                 : q25_velocity_magnitude_integral                 - 1.5*iqr_velocity_magnitude_integral,
      'slow_velocity_percentage_ivs'                : q25_slow_velocity_percentage_ivs                - 1.5*iqr_slow_velocity_percentage_ivs,
      'slow_velocity_percentage_everywhere'         : q25_slow_velocity_percentage_everywhere         - 1.5*iqr_slow_velocity_percentage_everywhere,
      'slow_velocity_percentage_dellschaft'         : q25_slow_velocity_percentage_dellschaft         - 1.5*iqr_slow_velocity_percentage_dellschaft,
      'fast_velocity_percentage_dellschaft'         : q25_fast_velocity_percentage_dellschaft         - 1.5*iqr_fast_velocity_percentage_dellschaft,
      'slow_velocity_percentage_nominal_everywhere' : q25_slow_velocity_percentage_nominal_everywhere - 1.5*iqr_slow_velocity_percentage_nominal_everywhere,
      'transport_reaction_integral'                 : q25_transport_reaction_integral                 - 1.5*iqr_transport_reaction_integral,
      'kinetic_energy_flux'                         : q25_kinetic_energy_flux                         - 1.5*iqr_kinetic_energy_flux,
      'total_energy_flux'                           : q25_total_energy_flux                           - 1.5*iqr_total_energy_flux,
      'velocity_cross_flow_flux'                    : q25_velocity_cross_flow_flux                    - 1.5*iqr_velocity_cross_flow_flux,
      'transport_flux'                              : q25_transport_flux                              - 1.5*iqr_transport_flux,
      'velocity_percentage_basal_plate'             : q25_velocity_percentage_basal_plate             - 1.5*iqr_velocity_percentage_basal_plate,
      'velocity_percentage_septal_wall'             : q25_velocity_percentage_septal_wall             - 1.5*iqr_velocity_percentage_septal_wall,
      'velocity_percentage_marginal_sinus'          : q25_velocity_percentage_marginal_sinus          - 1.5*iqr_velocity_percentage_marginal_sinus,
      'transport_percentage_basal_plate'            : q25_transport_percentage_basal_plate            - 1.5*iqr_transport_percentage_basal_plate,
      'transport_percentage_septal_wall'            : q25_transport_percentage_septal_wall            - 1.5*iqr_transport_percentage_septal_wall,
      'transport_percentage_marginal_sinus'         : q25_transport_percentage_marginal_sinus         - 1.5*iqr_transport_percentage_marginal_sinus
    },
    'whisker_high' : {
      'velocity_magnitude_integral'                 : q75_velocity_magnitude_integral                 + 1.5*iqr_velocity_magnitude_integral,
      'slow_velocity_percentage_ivs'                : q75_slow_velocity_percentage_ivs                + 1.5*iqr_slow_velocity_percentage_ivs,
      'slow_velocity_percentage_everywhere'         : q75_slow_velocity_percentage_everywhere         + 1.5*iqr_slow_velocity_percentage_everywhere,
      'slow_velocity_percentage_dellschaft'         : q75_slow_velocity_percentage_dellschaft         + 1.5*iqr_slow_velocity_percentage_dellschaft,
      'fast_velocity_percentage_dellschaft'         : q75_fast_velocity_percentage_dellschaft         + 1.5*iqr_fast_velocity_percentage_dellschaft,
      'slow_velocity_percentage_nominal_everywhere' : q75_slow_velocity_percentage_nominal_everywhere + 1.5*iqr_slow_velocity_percentage_nominal_everywhere,
      'transport_reaction_integral'                 : q75_transport_reaction_integral                 + 1.5*iqr_transport_reaction_integral,
      'kinetic_energy_flux'                         : q75_kinetic_energy_flux                         + 1.5*iqr_kinetic_energy_flux,
      'total_energy_flux'                           : q75_total_energy_flux                           + 1.5*iqr_total_energy_flux,
      'velocity_cross_flow_flux'                    : q75_velocity_cross_flow_flux                    + 1.5*iqr_velocity_cross_flow_flux,
      'transport_flux'                              : q75_transport_flux                              + 1.5*iqr_transport_flux,
      'velocity_percentage_basal_plate'             : q75_velocity_percentage_basal_plate             + 1.5*iqr_velocity_percentage_basal_plate,
      'velocity_percentage_septal_wall'             : q75_velocity_percentage_septal_wall             + 1.5*iqr_velocity_percentage_septal_wall,
      'velocity_percentage_marginal_sinus'          : q75_velocity_percentage_marginal_sinus          + 1.5*iqr_velocity_percentage_marginal_sinus,
      'transport_percentage_basal_plate'            : q75_transport_percentage_basal_plate            + 1.5*iqr_transport_percentage_basal_plate,
      'transport_percentage_septal_wall'            : q75_transport_percentage_septal_wall            + 1.5*iqr_transport_percentage_septal_wall,
      'transport_percentage_marginal_sinus'         : q75_transport_percentage_marginal_sinus         + 1.5*iqr_transport_percentage_marginal_sinus
    },
    'outliers' : {
      'velocity_magnitude_integral'                 : outliers(velocity_magnitude_integral                , q25_velocity_magnitude_integral                , q75_velocity_magnitude_integral                ),
      'slow_velocity_percentage_ivs'                : outliers(slow_velocity_percentage_ivs               , q25_slow_velocity_percentage_ivs               , q75_slow_velocity_percentage_ivs               ),
      'slow_velocity_percentage_everywhere'         : outliers(slow_velocity_percentage_everywhere        , q25_slow_velocity_percentage_everywhere        , q75_slow_velocity_percentage_everywhere        ),
      'slow_velocity_percentage_dellschaft'         : outliers(slow_velocity_percentage_dellschaft        , q25_slow_velocity_percentage_dellschaft        , q75_slow_velocity_percentage_dellschaft        ),
      'fast_velocity_percentage_dellschaft'         : outliers(fast_velocity_percentage_dellschaft        , q25_fast_velocity_percentage_dellschaft        , q75_fast_velocity_percentage_dellschaft        ),
      'slow_velocity_percentage_nominal_everywhere' : outliers(slow_velocity_percentage_nominal_everywhere, q25_slow_velocity_percentage_nominal_everywhere, q75_slow_velocity_percentage_nominal_everywhere),
      'transport_reaction_integral'                 : outliers(transport_reaction_integral                , q25_transport_reaction_integral                , q75_transport_reaction_integral                ),
      'kinetic_energy_flux'                         : outliers(kinetic_energy_flux                        , q25_kinetic_energy_flux                        , q75_kinetic_energy_flux                        ),
      'total_energy_flux'                           : outliers(total_energy_flux                          , q25_total_energy_flux                          , q75_total_energy_flux                          ),
      'velocity_cross_flow_flux'                    : outliers(velocity_cross_flow_flux                   , q25_velocity_cross_flow_flux                   , q75_velocity_cross_flow_flux                   ),
      'transport_flux'                              : outliers(transport_flux                             , q25_transport_flux                             , q75_transport_flux                             ),
      'velocity_percentage_basal_plate'             : outliers(velocity_percentage_basal_plate            , q25_velocity_percentage_basal_plate            , q75_velocity_percentage_basal_plate            ),
      'velocity_percentage_septal_wall'             : outliers(velocity_percentage_septal_wall            , q25_velocity_percentage_septal_wall            , q75_velocity_percentage_septal_wall            ),
      'velocity_percentage_marginal_sinus'          : outliers(velocity_percentage_marginal_sinus         , q25_velocity_percentage_marginal_sinus         , q75_velocity_percentage_marginal_sinus         ),
      'transport_percentage_basal_plate'            : outliers(transport_percentage_basal_plate           , q25_transport_percentage_basal_plate           , q75_transport_percentage_basal_plate           ),
      'transport_percentage_septal_wall'            : outliers(transport_percentage_septal_wall           , q25_transport_percentage_septal_wall           , q75_transport_percentage_septal_wall           ),
      'transport_percentage_marginal_sinus'         : outliers(transport_percentage_marginal_sinus        , q25_transport_percentage_marginal_sinus        , q75_transport_percentage_marginal_sinus        )
    }
  }

  return output