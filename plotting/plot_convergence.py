def plot(simulation_no, errors, spatial_convergence, temporal_convergence):
  import matplotlib.pyplot as plt

  if spatial_convergence:
    plt.figure(1)
    plt.clf()
    plt.loglog(errors[1]**(0.5), errors[3])
    plt.loglog(errors[1]**(0.5), errors[4])
    plt.loglog(errors[1]**(0.5), errors[5])
    plt.loglog(errors[1]**(0.5), errors[6])
    plt.loglog(errors[1]**(0.5), errors[7])
    plt.xlabel('DoFs^0.5')
    plt.ylabel('Error')
    plt.plot(errors[1]**(0.5), errors[1]**(-0.5), 'k--')
    plt.plot(errors[1]**(0.5), errors[1]**(-1), 'k-.')
    plt.plot(errors[1]**(0.5), errors[1]**(-2), 'k:')
    plt.legend(['L2_u', 'L2_p', 'L2_up', 'E_up', 'div_u', '1/(DoFs^0.5)', '1/(DoFs^1)', '1/(DoFs^2)'])
    plt.title('Spatial convergence')
    plt.savefig(f'./images/spatial_convergence_{simulation_no}.png')

  if temporal_convergence:
    plt.figure(2)
    plt.clf()
    plt.loglog(errors[0], errors[3])
    plt.loglog(errors[0], errors[4])
    plt.loglog(errors[0], errors[5])
    plt.loglog(errors[0], errors[6])
    plt.loglog(errors[0], errors[7])
    plt.xlabel('dt')
    plt.ylabel('Error')
    plt.plot(errors[0], errors[0]**(-1), 'k--')
    plt.plot(errors[0], errors[0]**(-2), 'k-.')
    plt.legend(['L2_u', 'L2_p', 'L2_up', 'E_up', 'div_u', 'dt^-1', 'dt^-2'])
    plt.title('Temporal convergence')
    plt.savefig(f'./images/temporal_convergence_{simulation_no}.png')

# import numpy as np
# errors = np.array([
#   [0 ,     60 , 0.0321277   , 0.322154   , 0.323752   , 1.05041    , 0.015284    ],
#   [0 ,    240 , 0.0046323   , 0.126813   , 0.126897   , 0.252987   , 0.00444613  ],
#   [0 ,    960 , 0.000518768 , 0.0480915  , 0.0480943  , 0.0662202  , 0.00168993  ],
#   [0 ,   3840 , 5.25035e-05 , 0.0146499  , 0.01465    , 0.0175645  , 0.00055165  ],
#   [0 ,  15360 , 5.44549e-06 , 0.00400733 , 0.00400733 , 0.00457184 , 0.000156423 ]
# ])

# plot(1, errors.transpose(), True, False)