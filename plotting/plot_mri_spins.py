def import_mat(simulation_no, filename_no_ext):
  import scipy.io
  return scipy.io.loadmat(f"./output/mri-quantities_{filename_no_ext}_{simulation_no}.mat")

def plot_spins(simulation_no, filename_no_ext):
  mat_vars = import_mat(simulation_no, filename_no_ext)

  import numpy as np
  b_index = 14
  grad_direction = 1

  # Radius and coordinates of each molecule's spin.
  r = 0.9/2
  x = r*np.cos(mat_vars['phi'][0, 0][b_index, :, grad_direction]) + 0.5
  y = r*np.sin(mat_vars['phi'][0, 0][b_index, :, grad_direction]) + 0.5

  # Arrows from centre to each molecule's spin.
  arrows_u = x - 0.5
  arrows_v = y - 0.5
  arrows_mag = np.sqrt(arrows_u**2 + arrows_v**2)

  # Plot setup.
  import matplotlib.pyplot as plt
  fig = plt.figure(figsize=(10, 10))
  ax = fig.add_subplot(111)

  # Plot a circle.
  circle = plt.Circle((0.5, 0.5), 0.5, color='k', fill=False)
  ax.add_patch(circle)

  # Plot arrows.
  centre_x = 0.5*np.ones((mat_vars['points_per_voxel'][0]))
  centre_y = 0.5*np.ones((mat_vars['points_per_voxel'][0]))
  ax.quiver(centre_x, centre_y, arrows_u, arrows_v, scale=0.4/arrows_mag, scale_units='xy', angles='xy', color=[0, 0, 0, 1.0/400], width=0.02) 

  # Plot all average spins.
  max_color = 0.8
  cmap = plt.get_cmap('Greens')
  #for i in range(mat_vars['b'][0].shape[0]):
  for i in range(b_index+1):
    # Average phase.
    avg_phi = -np.angle(np.sum(np.exp(-1j * mat_vars['phi'][0, 0][i, :, grad_direction])))

    # Radius and coordinates of average spin.
    r_avg = r
    x_avg = r_avg*np.cos(avg_phi) + 0.5
    y_avg = r_avg*np.sin(avg_phi) + 0.5

    color = list(cmap(max_color*float(i+1)/b_index))
    color[-1] = 0.5 + 0.5*float(i)/b_index
    ax.quiver(centre_x[0], centre_y[0], x_avg - 0.5, y_avg - 0.5, scale=0.4/r_avg, scale_units='xy', angles='xy', color=color, width=0.02)

    # Label the quiver.
    if i == 0:
      ax.text((x_avg + 0.5)/2, (y_avg + 0.5)/2 + 0.03, f'b={mat_vars["b"][0][i]:.2f}', fontsize=20, color=cmap(max_color), ha='center', va='bottom')
    if i == b_index:
      ax.text((x_avg + 0.5)/2 - 0.1, (2*y_avg + 1*0.5)/3, f'b={mat_vars["b"][0][i]:.2f}', fontsize=20, color=cmap(max_color), ha='center', va='bottom')

  # Patches for legend.
  import matplotlib.patches as mpatches
  individual_patch = mpatches.Patch(color=[0.5, 0.5, 0.5, 1], label='Individual spins')
  average_patch    = mpatches.Patch(color='g', label='Average spin')

  # Colorbar for different b.
  # import matplotlib.colors as colors
  # norm = colors.Normalize(vmin=mat_vars['b'][0][0], vmax=mat_vars['b'][0][b_index])
  # sm = plt.cm.ScalarMappable(cmap=cmap, norm=norm)
  # sm.set_array([])
  # fig.colorbar(sm, ticks=np.linspace(0, b_index, b_index+1), label='b')

  # Output.
  ax.axis('off')
  fig.legend(handles=[individual_patch, average_patch], fontsize=20, loc='outside lower right')
  ax.set_title(f"Spins at t={53}ms", fontsize=36)
  fig.savefig(f"./images/mri-spins_{filename_no_ext}_{simulation_no}.png")
