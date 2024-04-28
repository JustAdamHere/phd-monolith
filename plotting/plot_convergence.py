def rate_triangle(x, error, pad_x=None, len_x=None, pos=3):
  import numpy as np

  # Default spacings.
  if len_x == None:
    len_x = 2*x[0]
  if pad_x == None:
    pad_x = len_x/2

  # Calculate rates.
  error_rates = [error[i]/error[i+1] for i in range(len(error)-1)]

  # Take last rate as detected rate.
  rate = np.round(np.log2(error_rates[-1]))

  # Construct triangle points based upon detected rate.
  tri_x = [x[pos] - pad_x, x[pos] - pad_x - len_x, x[pos] - pad_x - len_x]
  tri_y = [error[pos], error[pos], error[pos]*(tri_x[0]/tri_x[1])**rate]
  
  # Close the triangle.
  tri_x.append(tri_x[0])
  tri_y.append(tri_y[0])

  return tri_x, tri_y, rate

def plot(simulation_no, errors, spatial_convergence, temporal_convergence, is_transport=False):
  import matplotlib.pyplot as plt
  import numpy as np

  if (is_transport):
    Nt       = errors[0]
    mesh_no  = errors[1]
    vel_Dofs = errors[2]
    DoFs     = errors[3]
    L2_c     = errors[4]
    H1_c     = errors[5]
    DG_c     = errors[6]
    H2_c     = errors[7]

    no_norms = 1
    norms = [L2_c, H1_c, DG_c, H2_c]
    labels = [r'$||c-c_h||_{L^2}$', r'$||c-c_h||_{H^1}$', r'$||c-c_h||_{DG}$', r'$||c-c_h||_{H^2}$']

    c_offset = 2
  else:
    Nt       = errors[0]
    mesh_no  = errors[1]
    DoFs     = errors[2]
    L2_u     = errors[3]
    L2_p     = errors[4]
    L2_up    = errors[5]
    DG_up    = errors[6]
    L2_div_u = errors[7]

    no_norms = 2
    norms  = [L2_u, L2_p, L2_up, DG_up, L2_div_u]
    labels = [r'$||\mathbf{u}-\mathbf{u}_h||_{L^2}$', r'$||p-p_h||_{L^2}$', r'$||\mathbf{u}-p_h||_{L^2}$', r'$||\mathbf{u}-p_h||_{DG}$', r'$||\nabla\cdot \mathbf{u}||_{L^2}$']

    c_offset = 0

  if spatial_convergence:
    plt.figure(1, figsize=(5, 4))
    plt.clf()

    # Plot data.
    for i in range(no_norms):
      plt.loglog(DoFs**(0.5), norms[i], 'o-', label=labels[i], c=f'CC{c_offset + i}')
      tri_x, tri_y, rate = rate_triangle(DoFs**0.5, norms[i])  
      plt.loglog(tri_x, tri_y, 'k-')
      plt.text(tri_x[1], (tri_y[1]+tri_y[2])/2, f'{rate:.0f} ', fontsize=18, ha='right', va='center')
      plt.text((tri_x[0]+tri_x[1])/2, 0.9*tri_y[0], f'1', fontsize=18, ha='center', va='top')
    # plt.loglog(errors[2]**(0.5), errors[3], 'o-', label='L2_u')
    # plt.loglog(errors[2]**(0.5), errors[4], 'o-', label='L2_p')
    # plt.loglog(errors[2]**(0.5), errors[5], 'o-', label='L2_up')
    # plt.loglog(errors[2]**(0.5), errors[6], 'o-', label='DG_up')
    # plt.loglog(errors[2]**(0.5), errors[7], 'o-', label='div_u')

    # Plot convergence rates.
    # tri_x, tri_y = rate_triangle(DoFs, L2_u)
    # plt.loglog(tri_x, tri_y, 'k-')

    # Style.
    plt.xlabel(r'$\sqrt{N_\text{DoF}}$')
    plt.ylabel('Error')
    plt.xlim([10**np.floor(np.log10(DoFs[0]**(0.5))), 10**np.ceil(np.log10(DoFs[-1]**(0.5)))])
    plt.ylim([10**np.floor(np.log10(np.min(norms[0:no_norms]))), 10**np.ceil(np.log10(np.max(norms[0:no_norms])))])
    plt.legend()
    plt.title('Spatial convergence')
    plt.savefig(f'./images/spatial_convergence_{simulation_no}.png', bbox_inches='tight', dpi=300)

  if temporal_convergence:
    plt.figure(2, figsize=(5, 4))
    plt.clf()
    
    for i in range(no_norms):
      plt.loglog(Nt, norms[i], 'o-', label=labels[i], c=f'CC{c_offset + i}')
      tri_x, tri_y, rate = rate_triangle(Nt, norms[i], len_x=2*Nt[0])
      plt.loglog(tri_x, tri_y, 'k-')
      plt.text(tri_x[1], (tri_y[1]+tri_y[2])/2, f'{rate:.0f} ', fontsize=18, ha='right', va='center')
      plt.text((tri_x[0]+tri_x[1])/2, 0.9*tri_y[0], f'1', fontsize=18, ha='center', va='top')
    plt.xlabel(r'$N_T$')
    plt.ylabel('Error')
    plt.xlim([10**np.floor(np.log10(Nt[0])), 10**np.ceil(np.log10(Nt[-1]))])
    plt.ylim([10**np.floor(np.log10(np.min(norms[0:no_norms]))), 10**np.ceil(np.log10(np.max(norms[0:no_norms])))])
    plt.legend()
    plt.title('Temporal convergence')
    plt.savefig(f'./images/temporal_convergence_{simulation_no}.png', bbox_inches='tight', dpi=300)

def plot_combined(errors_velocity_space, errors_transport_space, errors_velocity_time, errors_transport_time, prepend='', title_append=''):
  import matplotlib.pyplot as plt
  import numpy as np

  # Transport variables.
  _              = errors_transport_space[0]
  _              = errors_transport_space[1]
  velocity_DoFs  = errors_transport_space[2]
  transport_DoFs = errors_transport_space[3]
  x_L2_c         = errors_transport_space[4]
  x_H1_c         = errors_transport_space[5]
  x_DG_c         = errors_transport_space[6]
  x_H2_c         = errors_transport_space[7]

  Nt             = errors_transport_time[0]
  _              = errors_transport_time[1]
  _              = errors_transport_time[2]
  _              = errors_transport_time[3]
  t_L2_c         = errors_transport_time[4]
  t_H1_c         = errors_transport_time[5]
  t_DG_c         = errors_transport_time[6]
  t_H2_c         = errors_transport_time[7]

  no_norms_transport = 1
  x_transport_norms    = [x_L2_c, x_H1_c, x_DG_c, x_H2_c]
  t_transport_norms    = [t_L2_c, t_H1_c, t_DG_c, t_H2_c]
  transport_labels   = [r'$||c-c_h||_{L^2}$', r'$||c-c_h||_{H^1}$', r'$||c-c_h||_{DG}$', r'$||c-c_h||_{H^2}$']

  # Velocity variables.
  _          = errors_velocity_space[0]
  _          = errors_velocity_space[1]
  _          = errors_velocity_space[2]
  x_L2_u     = errors_velocity_space[3]
  x_L2_p     = errors_velocity_space[4]
  x_L2_up    = errors_velocity_space[5]
  x_DG_up    = errors_velocity_space[6]
  x_L2_div_u = errors_velocity_space[7]

  _          = errors_velocity_time[0]
  _          = errors_velocity_time[1]
  _          = errors_velocity_time[2]
  t_L2_u     = errors_velocity_time[3]
  t_L2_p     = errors_velocity_time[4]
  t_L2_up    = errors_velocity_time[5]
  t_DG_up    = errors_velocity_time[6]
  t_L2_div_u = errors_velocity_time[7]

  no_norms_velocity = 2
  x_velocity_norms  = [x_L2_u, x_L2_p, x_L2_up, x_DG_up, x_L2_div_u]
  t_velocity_norms  = [t_L2_u, t_L2_p, t_L2_up, t_DG_up, t_L2_div_u]
  velocity_labels   = [r'$||\mathbf{u}-\mathbf{u}_h||_{L^2}$', r'$||p-p_h||_{L^2}$', r'$||\mathbf{u}-p_h||_{L^2}$', r'$||\mathbf{u}-p_h||_{DG}$', r'$||\nabla\cdot \mathbf{u}||_{L^2}$']

  # Spatial convergence.
  plt.figure(1, figsize=(5, 4))
  plt.clf()

  for i in range(no_norms_velocity):
    plt.loglog(velocity_DoFs**(0.5), x_velocity_norms[i], 'o-', label=velocity_labels[i], c=f'C{i}')
    tri_x, tri_y, rate = rate_triangle(velocity_DoFs**0.5, x_velocity_norms[i])
    plt.loglog(tri_x, tri_y, 'k-')
    plt.text(tri_x[1], (tri_y[1]+tri_y[2])/2, f'{rate:.0f} ', fontsize=18, ha='right', va='center')
    plt.text((tri_x[0]+tri_x[1])/2, 0.9*tri_y[0], f'1', fontsize=18, ha='center', va='top')
  for i in range(no_norms_transport):
    plt.loglog(velocity_DoFs**(0.5), x_transport_norms[i], 'o-', label=transport_labels[i], c=f'C{no_norms_velocity+i}')
    tri_x, tri_y, rate = rate_triangle(velocity_DoFs**0.5, x_transport_norms[i])
    plt.loglog(tri_x, tri_y, 'k-')
    plt.text(tri_x[1], (tri_y[1]+tri_y[2])/2, f'{rate:.0f} ', fontsize=18, ha='right', va='center')
    plt.text((tri_x[0]+tri_x[1])/2, 0.9*tri_y[0], f'1', fontsize=18, ha='center', va='top')

  # Style.
  plt.xlabel(r'$\sqrt{N_\mathrm{DoF}}$')
  plt.ylabel('Error')
  plt.xlim([10**np.floor(np.log10(velocity_DoFs[0]**(0.5))), 10**np.ceil(np.log10(velocity_DoFs[-1]**(0.5)))])
  plt.ylim([10**np.floor(np.log10(np.min(x_velocity_norms[0:no_norms_velocity]))), 10**np.ceil(np.log10(np.max(x_velocity_norms[0:no_norms_velocity])))])
  plt.legend()
  plt.title(f'Spatial convergence{title_append}')
  plt.savefig(f'./images/{prepend}spatial_convergence.png', bbox_inches='tight', dpi=300)

  # Temporal convergence.
  plt.figure(2, figsize=(5, 4))
  plt.clf()

  for i in range(no_norms_velocity):
    plt.loglog(Nt, t_velocity_norms[i], 'o-', label=velocity_labels[i], c=f'C{i}')
    tri_x, tri_y, rate = rate_triangle(Nt, t_velocity_norms[i])
    plt.loglog(tri_x, tri_y, 'k-')
    plt.text(tri_x[1], (tri_y[1]+tri_y[2])/2, f'{rate:.0f} ', fontsize=18, ha='right', va='center')
    plt.text((tri_x[0]+tri_x[1])/2, 0.9*tri_y[0], f'1', fontsize=18, ha='center', va='top')
  for i in range(no_norms_transport):
    plt.loglog(Nt, t_transport_norms[i], 'o-', label=transport_labels[i], c=f'C{no_norms_velocity+i}')
    # tri_x, tri_y, rate = rate_triangle(Nt, t_transport_norms[i])
    # plt.loglog(tri_x, tri_y, 'k-')
    plt.text(tri_x[1], (tri_y[1]+tri_y[2])/2, f'{rate:.0f} ', fontsize=18, ha='right', va='center')
    plt.text((tri_x[0]+tri_x[1])/2, 0.9*tri_y[0], f'1', fontsize=18, ha='center', va='top')

  # Style.
  plt.xlabel(r'$N_T$')
  plt.ylabel('Error')
  plt.xlim([10**np.floor(np.log10(Nt[0])), 10**np.ceil(np.log10(Nt[-1]))])
  plt.ylim([10**np.floor(np.log10(np.min(t_velocity_norms[0:no_norms_velocity]))), 10**np.ceil(np.log10(np.max(t_velocity_norms[0:no_norms_velocity])))])
  plt.legend()
  plt.title(f'Temporal convergence{title_append}')
  plt.savefig(f'./images/{prepend}temporal_convergence.png', bbox_inches='tight', dpi=300)

  # if temporal_convergence:
  #   plt.figure(2, figsize=(5, 4))
  #   plt.clf()
    
  #   for i in range(no_norms):
  #     plt.loglog(Nt, norms[i], 'o-', label=labels[i], c=f'CC{c_offset + i}')
  #     tri_x, tri_y, rate = rate_triangle(Nt, norms[i], len_x=2*Nt[0])
  #     plt.loglog(tri_x, tri_y, 'k-')
  #     plt.text(tri_x[1], (tri_y[1]+tri_y[2])/2, f'{rate:.0f} ', fontsize=18, ha='right', va='center')
  #     plt.text((tri_x[0]+tri_x[1])/2, 0.9*tri_y[0], f'1', fontsize=18, ha='center', va='top')
  #   plt.xlabel(r'$N_T$')
  #   plt.ylabel('Error')
  #   plt.xlim([10**np.floor(np.log10(Nt[0])), 10**np.ceil(np.log10(Nt[-1]))])
  #   plt.ylim([10**np.floor(np.log10(np.min(norms[0:no_norms]))), 10**np.ceil(np.log10(np.max(norms[0:no_norms])))])
  #   plt.legend()
  #   plt.title('Temporal convergence')
  #   plt.savefig(f'./images/temporal_convergence_{simulation_no}.png', bbox_inches='tight', dpi=300)

def plot_from_data():
  # Non-moving mesh.
  velocity_spatial   = 2
  velocity_temporal  = 3
  transport_spatial  = 7
  transport_temporal = 8

  from miscellaneous import get_norms
  vs, _ = get_norms.get_velocity_norms("velocity-transport_convergence", "square_analytic", velocity_spatial)
  vt, _ = get_norms.get_velocity_norms("velocity-transport_convergence", "square_analytic", velocity_temporal)
  ts, _ = get_norms.get_transport_norms("velocity-transport_convergence", "square_analytic", transport_spatial)
  tt, _ = get_norms.get_transport_norms("velocity-transport_convergence", "square_analytic", transport_temporal)

  plot_combined(vs, ts, vt, tt)

  # Moving mesh.
  velocity_spatial   = 4
  velocity_temporal  = 5
  transport_spatial  = 9
  transport_temporal = 10

  from miscellaneous import get_norms
  vs, _ = get_norms.get_velocity_norms("velocity-transport_convergence", "square_analytic", velocity_spatial)
  vt, _ = get_norms.get_velocity_norms("velocity-transport_convergence", "square_analytic", velocity_temporal)
  ts, _ = get_norms.get_transport_norms("velocity-transport_convergence", "square_analytic", transport_spatial)
  tt, _ = get_norms.get_transport_norms("velocity-transport_convergence", "square_analytic", transport_temporal)

  plot_combined(vs, ts, vt, tt, 'mm_', ' with moving mesh')