def phi_adam(Na, Nv):
  k1 = Na/(3*(2+Nv))
  k1 /= 1.5
  k2 = k1/2
  k2 /= 1.5

  return (Na - 3*Nv*k1**2 - 12*k2**2)/Na

import matplotlib.pyplot as plt
import numpy as np

# Vary arteries.
one = np.linspace(1, 1, 100)
Na = np.linspace(1, 6, 100)
Nv = 27
Pa = phi_adam(Na, Nv)

plt.plot(Na/6, Pa, 'b-', label=r'$\Phi_\text{adam}(N_a, 27)$')

# Vary veins.
Na = 6
Nv = np.linspace(0, 27, 100)
Pa = phi_adam(Na, Nv)

plt.plot(Nv/27, Pa, 'b--', label=r'$\Phi_\text{adam}(6, N_v)$')

plt.legend()
plt.ylim([0.6, 1])