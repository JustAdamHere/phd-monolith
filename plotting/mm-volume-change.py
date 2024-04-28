import matplotlib as mpl
mpl.rcParams['figure.dpi'] = 600
plt = mpl.pyplot
import numpy as np

# Data that we use in simulation.
data = np.array([
  [14.809825673534071, -9.32432432432433],
  [15.095087163232964, -13.648648648648653],
  [15.33280507131537, -18.51351351351351],
  [15.594294770206023, -20.810810810810814],
  [15.832012678288432, -29.729729729729726],
  [16.117274167987322, -33.78378378378379]
]).round(1)

# Discarded data taht we don't use.
discarded_data1 = np.array([
  [13.502377179080824, -10.270270270270267],
  [13.835182250396194, -8.24324324324325],
  [14.096671949286847, -10.000000000000007],
  [14.477020602218701, -8.648648648648653]
])
discarded_data1 = np.append(discarded_data1, data[0]).reshape(-1, 2).round(1)
discarded_data2 = np.array([
  [16.37876386687797, -30.81081081081082],
  [16.61648177496038, -27.567567567567565],
  [16.94928684627575, -26.621621621621628],
  [17.210776545166404, -21.48648648648649],
  [17.496038034865293, -20.135135135135137],
  [17.733755942947703, -16.891891891891895],
  [18.066561014263076, -13.378378378378379],
  [18.328050713153722, -14.59459459459459],
  [18.56576862123613, -13.91891891891892],
  [18.85103011093502, -15.54054054054054],
  [19.112519809825674, -14.189189189189186],
  [19.397781299524564, -10.000000000000007],
  [19.730586370839937, -14.864864864864863],
  [19.992076069730583, -10.40540540540541],
])
discarded_data2 = np.append(data[-1], discarded_data2).reshape(-1, 2).round(1)

# Estimate of where zero volume would be given a linear approximation between the first and last data points.
zero_volume_intercept = np.round(14.3114, 1)
zero_volume_periodic = np.round(data[-1, 0] + (data[-1, 0] - 14.3114), 1)

# Equivalent 2D area change.
#  From ./plotting/mm_velocity.py: 
#   3D volume change 33.78378378378379% => 2D area change 24.029863475917455%.
area_change = np.round(-24.029863475917455, 1)

# Plot
import matplotlib.patheffects as pe
fig, ax = plt.subplots()

# Snapshots.
snapshots = [0, 25, 50, 95, 100]
t = np.linspace(14.3, 17.9, 101)
ax.vlines(t[snapshots], -35, 10, colors='gray', linestyles='dotted', alpha=0.5, label='Snapshots in time')

# Data.
ax.plot([zero_volume_intercept, data[-1, 0]], [0, data[-1, 1]], 'r--', label='Linear volume approximation')
# ax.plot([zero_volume_intercept, data[-1, 0]], [0, area_change], 'g--', label='Linear area approximation')
ax.plot(data[-1, 0], area_change, 'gx', label=r'$\Delta_2$ (estimated maximum area)', markeredgewidth=2, markersize=10)
ax.plot([data[-1, 0], zero_volume_periodic], [data[-1, 1], 0], 'r--')
# ax.plot([data[-1, 0], zero_volume_periodic], [area_change, 0], 'g--')
ax.plot(data[:, 0], data[:, 1], 'o-', label='Volume data', color='C0', linewidth=3, path_effects=[pe.Stroke(linewidth=3, foreground='white'), pe.Normal()])
ax.plot(discarded_data1[:, 0], discarded_data1[:, 1], 'o-', label='Discarded volume data', alpha=0.5, color='C0')
ax.plot(discarded_data2[:, 0], discarded_data2[:, 1], 'o-', alpha=0.5, color='C0')
ax.plot(zero_volume_intercept, 0, 'ro', label=r'Estimated zero volume')
ax.plot(zero_volume_periodic, 0, 'ro')

# Style plot.
handles, labels = ax.get_legend_handles_labels()
order = [3, 4, 5, 1, 2, 0]
ax.legend([handles[idx] for idx in order],[labels[idx] for idx in order]) # Reorders legend entries.
ax.set_xlabel('t (minutes)')
ax.set_ylabel('Change from initial (%)')
ax.set_title('Approximate area or volume change over time')
ax.set_xlim([zero_volume_intercept-0.1, zero_volume_periodic+0.1])
ax.set_ylim([-35, 10])
ax.minorticks_on()

fig.show()