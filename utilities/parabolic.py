def parabolic(r, R):
  return 1.0 - (r/R)**2

import numpy as np

R = 0.1
r = np.linspace(-R, R, 100)

import matplotlib.pyplot as plt

plt.plot(r, parabolic(r, R))
plt.show()