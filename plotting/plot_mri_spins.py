def import_mat(simulation_no, filename_no_ext):
  import scipy.io
  return scipy.io.loadmat(f"./output/mri-quantities_{filename_no_ext}_{simulation_no}.mat")

  # import h5py
  # return h5py.File(f"./output/mri-quantities_{filename_no_ext}_{simulation_no}.mat", 'r')

  # import mat73
  # return mat73.loadmat(f"./output/mri-quantities_{filename_no_ext}_{simulation_no}.mat")

  # from pymatreader import read_mat
  # return read_mat(f"./output/mri-quantities_{filename_no_ext}_{simulation_no}.mat")

def plot_quiver(simulation_no, filename_no_ext):
  mat_vars = import_mat(simulation_no, filename_no_ext)

  import numpy as np
  import matplotlib.pyplot as plt

  fig = plt.figure(figsize=(10, 10))
  ax = fig.add_subplot(111)

  # Colourbar.
  U = np.sqrt(mat_vars['v_sample'][0][0]**2 + mat_vars['v_sample'][1][0]**2)

  cmap = plt.get_cmap('coolwarm')

  import matplotlib.colors as colors
  norm = colors.Normalize(vmin=np.min(U), vmax=np.max(U))
  sm = plt.cm.ScalarMappable(cmap=cmap, norm=norm)
  sm.set_array([])

  w = 0.8
  h = 0.03

  w1 = w*(ax.get_position().x1 - ax.get_position().x0)
  x1 = ax.get_position().x0 + 0.075
  y1 = ax.get_position().y0 - h
  
  cax = fig.add_axes([x1, y1, w1, h])
  cax.tick_params(labelsize=20)
  cbar = fig.colorbar(sm, cax=cax, orientation='horizontal', shrink=1.0, location='bottom')
  cbar.set_label(r'$|\mathbf{u}|$ (m/s)', size=20)

  fig.subplots_adjust(bottom=0.22)

  # Plot.
  ax.quiver(mat_vars['x_sample'][0][0], mat_vars['x_sample'][1][0], mat_vars['v_sample'][0][0], mat_vars['v_sample'][1][0], U, cmap=cmap, scale=0.12, scale_units='xy', angles='xy', width=0.005, headwidth=8, headaxislength=4, clip_on=False) # headlength=5, headwidth=3

  # Style.
  if (filename_no_ext == '2D_accelerating_test'):
    title = f"accelerating flow: $U_1={mat_vars['U_1'][0][0]:g}$, $X={mat_vars['X'][0][0]:.4f}$"
  elif (filename_no_ext == '2D_rotational_test'):
    title = f"rotational flow: $U_1={mat_vars['U_1'][0][0]:g}$, $U_2={mat_vars['U_2'][0][0]:g}$"
  elif (filename_no_ext == '2D_shear_test'):
    title = f"shear flow: $U_1={mat_vars['U_1'][0][0]:g}$, $U_2={mat_vars['U_2'][0][0]:g}$"
  ax.set_xlabel(r'$x$', fontsize=20)
  ax.set_ylabel(r'$y$', fontsize=20)
  fig.suptitle(r"Velocity field at each $\mathbf{x}_j$", fontsize=36)
  ax.set_title(f"{title}", fontsize=24, pad=15) # pad = 10
  ax.tick_params(labelsize=20)

  # Output.
  fig.savefig(f"./images/mri-spins_quiver_{filename_no_ext}_{simulation_no}.png")

def plot_s_vs_b(simulation_no, filename_no_ext):
  mat_vars = import_mat(simulation_no, filename_no_ext)

  import matplotlib.patches as mpatches
  max_no_patches = 3
  handles = []
  for i in range(max_no_patches):
    handles.append(mpatches.Patch(color=f"C{i}"))

  import numpy as np
  import matplotlib.pyplot as plt

  fig_s = plt.figure(figsize=(10, 10))
  ax_s = fig_s.add_subplot(111)

  fig_sx = plt.figure(figsize=(10, 10))
  ax_sx = fig_sx.add_subplot(111)

  fig_sy = plt.figure(figsize=(10, 10))
  ax_sy = fig_sy.add_subplot(111)

  fig_sall = plt.figure(figsize=(10, 10))
  ax_sall = fig_sall.add_subplot(111)

  fig_gall = plt.figure(figsize=(10, 10))
  ax_gall = fig_gall.add_subplot(111)

  # Plot.
  ax_s   .plot(mat_vars['b'][0],      mat_vars['S'][0][0]  /mat_vars['S'][0][0][0],   'o', c='tab:blue')
  ax_sall.plot(mat_vars['b'][0],      mat_vars['S'][0][0]  /mat_vars['S'][0][0][0],   'o', c='tab:blue', label=r'$S/S_0$')
  ax_gall.plot(mat_vars['b'][0]**0.5, mat_vars['S'][0][0]  /mat_vars['S'][0][0][0],   'o', c='tab:blue', label=r'$S/S_0$')
  ax_sx  .plot(mat_vars['b'][0],      mat_vars['S_x'][0][0]/mat_vars['S_x'][0][0][0], 'o', c='tab:orange')
  ax_sall.plot(mat_vars['b'][0],      mat_vars['S_x'][0][0]/mat_vars['S_x'][0][0][0], 'o', c='tab:orange', label=r'$S_x/S_{x,0}$')
  ax_gall.plot(mat_vars['b'][0]**0.5, mat_vars['S_x'][0][0]/mat_vars['S_x'][0][0][0], 'o', c='tab:orange', label=r'$S_x/S_{x,0}$')
  ax_sy  .plot(mat_vars['b'][0],      mat_vars['S_y'][0][0]/mat_vars['S_y'][0][0][0], 'o', c='tab:green')
  ax_sall.plot(mat_vars['b'][0],      mat_vars['S_y'][0][0]/mat_vars['S_y'][0][0][0], 'o', c='tab:green', label=r'$S_y/S_{y,0}$')
  ax_gall.plot(mat_vars['b'][0]**0.5, mat_vars['S_y'][0][0]/mat_vars['S_y'][0][0][0], 'o', c='tab:green', label=r'$S_y/S_{y,0}$')

  # Style.
  if (filename_no_ext == '2D_accelerating_test'):
    title = f"accelerating flow: $U_1={mat_vars['U_1'][0][0]:g}$, $X={mat_vars['X'][0][0]:.4f}$"
  elif (filename_no_ext == '2D_rotational_test'):
    title = f"rotational flow: $U_1={mat_vars['U_1'][0][0]:g}$, $U_2={mat_vars['U_2'][0][0]:g}$"
  elif (filename_no_ext == '2D_shear_test'):
    title = f"shear flow: $U_1={mat_vars['U_1'][0][0]:g}$, $U_2={mat_vars['U_2'][0][0]:g}$"
  ax_s   .set_xlabel(r'$b$', fontsize=20)
  ax_sx  .set_xlabel(r'$b$', fontsize=20)
  ax_sy  .set_xlabel(r'$b$', fontsize=20)
  ax_sall.set_xlabel(r'$b$', fontsize=20)
  ax_gall.set_xlabel(r'$g$', fontsize=20)
  ax_s   .set_ylabel(r'$S/S_0$', fontsize=20)
  ax_sx  .set_ylabel(r'$S_x/S_{x,0}$', fontsize=20)
  ax_sy  .set_ylabel(r'$S_y/S_{y,0}$', fontsize=20)
  ax_sall.set_ylabel(r'$S/S_0$', fontsize=20)
  ax_sall.legend(handles=handles[0:3], labels=[r'$S/S_0$', r'$S_x/S_{x,0}$', r'$S_y/S_{y,0}$'], fontsize=20, loc='upper right')
  ax_gall.legend(handles=handles[0:3], labels=[r'$S/S_0$', r'$S_x/S_{x,0}$', r'$S_y/S_{y,0}$'], fontsize=20, loc='upper right')
  fig_s   .suptitle(r'$S/S_0$ vs $b$', fontsize=36)
  fig_sx .suptitle(r'$S_x/S_{x,0}$ vs $b$', fontsize=36)
  fig_sy   .suptitle(r'$S_y/S_{y,0}$ vs $b$', fontsize=36)
  fig_sall.suptitle(r'$S/S_0$ vs $b$', fontsize=36)
  fig_gall.suptitle(r'$S/S_0$ vs $g$', fontsize=36)
  ax_s   .set_title(f'{title}', fontsize=24, pad=15)
  ax_sx  .set_title(f'{title}', fontsize=24, pad=15)
  ax_sy  .set_title(f'{title}', fontsize=24, pad=15)
  ax_sall.set_title(f'{title}', fontsize=24, pad=15)
  ax_gall.set_title(f'{title}', fontsize=24, pad=15)
  ax_s   .tick_params(labelsize=20)
  ax_sx  .tick_params(labelsize=20)
  ax_sy  .tick_params(labelsize=20)
  ax_sall.tick_params(labelsize=20)
  ax_gall.tick_params(labelsize=20)
  b_range = mat_vars['b'][0][-1] - mat_vars['b'][0][0]
  g_range = mat_vars['b'][0][-1]**0.5 - mat_vars['b'][0][0]**0.5
  S_range = 1
  eps = 0.02
  ax_s   .set_xlim([-eps*b_range, mat_vars['b'][0][-1] + eps*b_range])
  ax_sx  .set_xlim([-eps*b_range, mat_vars['b'][0][-1] + eps*b_range])
  ax_sy  .set_xlim([-eps*b_range, mat_vars['b'][0][-1] + eps*b_range])
  ax_sall.set_xlim([-eps*b_range, mat_vars['b'][0][-1] + eps*b_range])
  ax_gall.set_xlim([-eps*g_range, mat_vars['b'][0][-1]**0.5 + eps*g_range])
  ax_s   .set_ylim ([-eps*S_range, 1 + eps*S_range])
  ax_sx  .set_ylim([-eps*S_range, 1 + eps*S_range])
  ax_sy  .set_ylim([-eps*S_range, 1 + eps*S_range])
  ax_sall.set_ylim([-eps*S_range, 1 + eps*S_range])
  ax_gall.set_ylim([-eps*S_range, 1 + eps*S_range])

  fig_s  .savefig(f"./images/mri-spins_s-vs-b_{filename_no_ext}_{simulation_no}.png")
  fig_sx .savefig(f"./images/mri-spins_sx-vs-b_{filename_no_ext}_{simulation_no}.png")
  fig_sy .savefig(f"./images/mri-spins_sy-vs-b_{filename_no_ext}_{simulation_no}.png")
  fig_sall.savefig(f"./images/mri-spins_sall-vs-b_{filename_no_ext}_{simulation_no}.png")
  fig_gall.savefig(f"./images/mri-spins_gall-vs-b_{filename_no_ext}_{simulation_no}.png")


def plot_spins(simulation_no, filename_no_ext):
  mat_vars = import_mat(simulation_no, filename_no_ext)

  import numpy as np
  import matplotlib.pyplot as plt
  b_index = 20
  if (filename_no_ext == '2D_accelerating_test'):
    grad_direction = 0
    cmap = plt.get_cmap('Blues')
  else:
    grad_direction = 1
    cmap = plt.get_cmap('Greens')

  # Radius and coordinates of each molecule's spin.
  r = 0.9/2
  x = r*np.cos(mat_vars['phi'][0, 0][b_index, :, grad_direction]) + 0.5
  y = r*np.sin(mat_vars['phi'][0, 0][b_index, :, grad_direction]) + 0.5
  # x = r*np.cos(mat_vars['phi'][0][0][b_index, :, grad_direction]) + 0.5
  # y = r*np.sin(mat_vars['phi'][0][0][b_index, :, grad_direction]) + 0.5

  # Arrows from centre to each molecule's spin.
  arrows_u = x - 0.5
  arrows_v = y - 0.5
  arrows_mag = np.sqrt(arrows_u**2 + arrows_v**2)

  # Plot setup.  
  fig_avg = plt.figure(figsize=(10, 10))
  ax_avg = fig_avg.add_subplot(111)

  fig_b = plt.figure(figsize=(10, 10))
  ax_b = fig_b.add_subplot(111)

  # Plot a circle.
  circle_avg = plt.Circle((0.5, 0.5), 0.5, color='k', fill=False)
  ax_avg.add_patch(circle_avg)
  circle_b = plt.Circle((0.5, 0.5), 0.5, color='k', fill=False)
  ax_b.add_patch(circle_b)

  # Plot arrows.
  centre_x = 0.5*np.ones((mat_vars['points_per_voxel'][0]))
  centre_y = 0.5*np.ones((mat_vars['points_per_voxel'][0]))
  # centre_x = 0.5*np.ones((mat_vars['points_per_voxel']))
  # centre_y = 0.5*np.ones((mat_vars['points_per_voxel']))
  ax_avg.quiver(centre_x, centre_y, arrows_u, arrows_v, scale=0.4/arrows_mag, scale_units='xy', angles='xy', color=[0, 0, 0, 1.0/400], width=0.02) 

  # Magnetic spin for b=0.
  r_0 = np.abs(np.sum(np.exp(-1j * mat_vars['phi'][0, 0][0, :, grad_direction])))
  # r_0 = np.abs(np.sum(np.exp(-1j * mat_vars['phi'][0][0][0, :, grad_direction])))

  # Plot all average spins.
  max_color = 0.8
  #for i in range(mat_vars['b'][0].shape[0]):
  for i in range(b_index+1):

    # Average magnetic spin.
    avg_m = np.sum(np.exp(-1j * mat_vars['phi'][0, 0][i, :, grad_direction]))
    # avg_m = np.sum(np.exp(-1j * mat_vars['phi'][0][0][i, :, grad_direction]))

    # Average phase.
    avg_phi = -np.angle(avg_m)

    # Radius and coordinates of average spin.
    r_avg = r*np.abs(avg_m)/r_0
    x_avg = r_avg*np.cos(avg_phi) + 0.5
    y_avg = r_avg*np.sin(avg_phi) + 0.5

    color = list(cmap(max_color*float(i+1)/b_index))
    color[-1] = 0.5 + 0.5*float(i)/b_index
    ax_b.quiver(centre_x[0], centre_y[0], x_avg - 0.5, y_avg - 0.5, scale=0.4/r_avg, scale_units='xy', angles='xy', color=color, width=0.02)

    if (i == b_index):
      ax_avg.quiver(centre_x[0], centre_y[0], x_avg - 0.5, y_avg - 0.5, scale=0.4/r_avg, scale_units='xy', angles='xy', color=color, width=0.02)

    # Label the quiver.
    # if i == 0:
    #   ax_b.text((x_avg + 0.5)/2, (y_avg + 0.5)/2 + 0.03, f'b={mat_vars["b"][0][i]:.2f}', fontsize=20, color=cmap(max_color), ha='center', va='bottom')
    # if i == b_index:
    #   ax_b.text((x_avg + 0.5)/2 - 0.2, (2*y_avg + 1*0.5)/3 + 0.03, f'b={mat_vars["b"][0][i]:.2f}', fontsize=20, color=cmap(max_color), ha='center', va='bottom')

  # Patches for legend.
  import matplotlib.patches as mpatches
  if (filename_no_ext == '2D_accelerating_test'):
    d = 'x'
  else:
    d = 'y'

  individual_patch = mpatches.Patch(color=[0.5, 0.5, 0.5, 1], label=fr'$M_j(T_{d} + t_E)$')
  average_patch    = mpatches.Patch(color='g', label=fr'$\bar{{M}}(T_{d} + t_E)$')

  # Colorbar for different b.
  import matplotlib.colors as colors
  norm = colors.Normalize(vmin=mat_vars['b'][0][0], vmax=mat_vars['b'][0][b_index])
  sm = plt.cm.ScalarMappable(cmap=cmap, norm=norm)
  sm.set_array([])
  #fig_b.colorbar(sm, ax=ax_b, ticks=np.linspace(0, b_index, b_index+1), label='b', orientation='horizontal', shrink=0.6, location='bottom') # pad=-0.2

  w = 0.8
  h = 0.03

  w1 = w*(ax_b.get_position().x1 - ax_b.get_position().x0)
  x1 = ax_b.get_position().x0 + 0.075#(1 - w1)/2
  y1 = ax_b.get_position().y0 - h
  
  cax = fig_b.add_axes([x1, y1, w1, h])
  cax.tick_params(labelsize=20)
  cbar = fig_b.colorbar(sm, cax=cax, ticks=np.linspace(mat_vars['b'][0][0], mat_vars['b'][0][b_index], 5), orientation='horizontal', shrink=1.0, location='bottom')
  cbar.set_label(r'$b$', size=20)

  # Output.
  if (filename_no_ext == '2D_accelerating_test'):
    title = f"accelerating flow: $U_1={mat_vars['U_1'][0][0]:g}$, $X={mat_vars['X'][0][0]:.4f}$"
  elif (filename_no_ext == '2D_rotational_test'):
    title = f"rotational flow: $U_1={mat_vars['U_1'][0][0]:g}$, $U_2={mat_vars['U_2'][0][0]:g}$"
  elif (filename_no_ext == '2D_shear_test'):
    title = f"shear flow: $U_1={mat_vars['U_1'][0][0]:g}$, $U_2={mat_vars['U_2'][0][0]:g}$"
  ax_avg.axis('off')
  ax_b.axis('off')
  fig_avg.legend(handles=[individual_patch, average_patch], fontsize=20, loc='outside lower center')
  fig_avg.suptitle("Spins at $t=t_E$", fontsize=36)
  ax_avg.set_title(f"{title}", fontsize=24, pad=15)
  fig_b.suptitle(fr"$\bar{{M}}(T_{d} + t_E)$ for $b \in [{mat_vars['b'][0][0]:.0f}, {mat_vars['b'][0][b_index]:.0f}]$", fontsize=36)
  ax_b.set_title(f"{title}", fontsize=24, pad=15)
  fig_avg.savefig(f"./images/mri-spins_avg_{filename_no_ext}_{simulation_no}.png")
  fig_b.savefig(f"./images/mri-spins_b_{filename_no_ext}_{simulation_no}.png")
