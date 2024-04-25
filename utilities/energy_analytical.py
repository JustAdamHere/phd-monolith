def phi_adam(Na, Nv):
  k1 = Na/(3*(2+Nv))
  k2 = k1/2

  return (Na - 3*Nv*k1**2 - 12*k2**2)/Na

def phi_zak(Na, Nv):
  R = 2
  k1 = (-Nv + (Nv*2 + 4)**0.5)/2
  k2 = (1 - Nv*k1)/R

  return 1 - (Nv*k1**2 + R**2*k2**2)

import matplotlib.pyplot as plt
import numpy as np

# Vary arteries.
one = np.linspace(1, 1, 100)
Na = np.linspace(1, 6, 100)
Nv = 27
Pa = phi_adam(Na, Nv)
Pz = phi_zak(1, 27*one)

plt.plot(Na/6, Pa, 'b-', label=r'$\Phi_\text{adam}(N_a, 27)$')
plt.plot(Na/6, Pz, 'r-', label=r'$\Phi_\text{zak}(1, 27)$')

# Vary veins.
Na = 6
Nv = np.linspace(0, 27, 100)
Pa = phi_adam(Na, Nv)
Pz = phi_zak(1, Nv)

plt.plot(Nv/27, Pa, 'b--', label=r'$\Phi_\text{adam}(6, N_v)$')
plt.plot(Nv/27, Pz, 'r--', label=r'$\Phi_\text{zak}(1, N_v)$')

plt.legend()
plt.ylim([-1, 1])