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
      plt.loglog(DoFs**(0.5), norms[i], 'o-', label=labels[i], c=f'C{c_offset + i}')
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
      plt.loglog(Nt, norms[i], 'o-', label=labels[i], c=f'C{c_offset + i}')
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