def import_mat(filename_no_ext):
  import scipy.io
  return scipy.io.loadmat(f"./output/mri-quantities_{filename_no_ext}.mat")

def plot_spins(filename_no_ext):
  mat_vars = import_mat(filename_no_ext)

  import numpy as np
  b_index = 14
  grad_direction = 1
  
  # Average phase.
  avg_phi = -np.angle(np.sum(np.exp(-1j * mat_vars['phi'][0, 0][b_index, :, grad_direction])))

  # Radius and coordinates of each molecule's spin.
  r = 0.9/2
  x = r*np.cos(mat_vars['phi'][0, 0][b_index, :, grad_direction]) + 0.5
  y = r*np.sin(mat_vars['phi'][0, 0][b_index, :, grad_direction]) + 0.5

  # Radius and coordinates of average spin.
  # r_0   =     np.abs(np.sum(np.exp(-1j * mat_vars['phi'][0, 0][b_index, :, grad_direction])))
  # r_avg = 0.9*np.abs(np.sum(np.exp(-1j * mat_vars['phi'][0, 0][b_index, :, grad_direction])))/(2*r_0)
  r_avg = r
  x_avg = r_avg*np.cos(avg_phi) + 0.5
  y_avg = r_avg*np.sin(avg_phi) + 0.5

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
  ax.quiver(centre_x[0], centre_y[0], x_avg - 0.5, y_avg - 0.5, scale=0.4/r_avg, scale_units='xy', angles='xy', color='g', width=0.02)
  ax.quiver(centre_x, centre_y, arrows_u, arrows_v, scale=0.4/arrows_mag, scale_units='xy', angles='xy', color=[0, 0, 0, 1.0/400], width=0.02) 

  # Output.
  ax.axis('off')
  fig.legend(['Individual spins', 'Average spin'], fontsize=20, loc='outside lower right')
  ax.set_title(f"Spins at t={53}ms", fontsize=36)
  fig.savefig(f"./images/mri-spins_{filename_no_ext}.png")

plot_spins("2D_shear_0_01_test")