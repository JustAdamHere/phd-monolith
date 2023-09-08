import numpy as np

def Q_2(U, R):
  return 4*U*R/3

def Q_3(U, R):
  return np.pi*U*R**2/2

def A(L):
  return L**2

def V(L):
  return np.pi*L**3/4

import matplotlib.pyplot as plt

# Inlet radius.
R = 2.5e-4 #m

# Assumed inlet velocity in 3D.
U_3 = 1 # m/s

# Length associated with square or cylinder.
L = np.logspace(-4, 0, 100) # m

plt.loglog(L, A(L)*Q_3(U_3, R)/(V(L)*Q_2(1, R)), label='Approximate scaling')
plt.loglog(L, 1e-3/L, label='1/L')
plt.hlines(1, 1e-4, 1, 'k', '--', label='U_3')
plt.xlabel('Length, L (metres)')
plt.ylabel('Velocity in 2D, U_2 (metres per second)')
plt.legend()

print(f"Approximate scaling: {0.00543*Q_3(U_3, R)/(0.0007141*Q_2(1, R))}") # 0.002239556098890987 or 1/446.517057776