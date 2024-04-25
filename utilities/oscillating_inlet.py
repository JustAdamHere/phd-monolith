import matplotlib as mpl
mpl.rcParams['figure.dpi'] = 600
plt = mpl.pyplot
import numpy as np

def amplitude(t):
  # Taken from https://apps.automeris.io/wpd/
  # Data from Fig4 H in [Carson, 2021]
  sample_t = np.array([0.32918, 0.33902, 0.34897, 0.35569, 0.36334, 0.37005, 0.37473, 0.37795, 0.38308, 0.38656, 0.38984, 0.39113, 0.39476, 0.39804, 0.40131, 0.40459, 0.40787, 0.41291, 0.41607, 0.41935, 0.42590, 0.43273, 0.44038, 0.44722, 0.45377, 0.46033, 0.46689, 0.47344, 0.48000, 0.48656, 0.49377, 0.50213, 0.50869, 0.51771, 0.52754, 0.53738, 0.54721, 0.55705, 0.56689, 0.57672, 0.58656, 0.59639, 0.60623, 0.61606, 0.62590, 0.63574, 0.64557, 0.65541, 0.66524, 0.67508, 0.68492, 0.69475, 0.70459, 0.71442, 0.72426, 0.73409, 0.74393, 0.75377, 0.76360, 0.77344, 0.78327, 0.79311, 0.80295, 0.81278, 0.82262, 0.83196, 0.83819, 0.84100, 0.84475, 0.84680, 0.85008, 0.85335, 0.85695, 0.86041, 0.86401, 0.86770, 0.87016, 0.87344, 0.87671, 0.87999, 0.88327, 0.88655, 0.88983, 0.89311, 0.89639, 0.89967, 0.90294, 0.90622, 0.90950, 0.91278, 0.91641, 0.91969, 0.92453, 0.92945, 0.93475, 0.93901, 0.94393, 0.94896, 0.95540, 0.96196, 0.96879, 0.97709, 0.98655, 0.99638])
  sample_u = np.array([140.66, 140.40, 139.08, 137.32, 135.65, 133.41, 131.14, 129.03, 126.76, 124.43, 122.33, 120.24, 118.02, 115.52, 113.00, 110.43, 107.93, 105.52, 103.29, 101.59, 99.682, 97.637, 95.718, 93.596, 91.417, 89.086, 86.820, 84.641, 82.591, 80.713, 78.858, 77.477, 76.139, 74.945, 73.420, 71.981, 70.600, 69.420, 68.327, 67.406, 66.572, 65.852, 65.133, 64.356, 63.666, 62.975, 62.285, 61.594, 60.904, 60.127, 59.321, 58.602, 57.854, 57.106, 56.329, 55.581, 54.832, 54.113, 53.308, 52.617, 51.926, 51.236, 50.517, 49.941, 50.171, 51.685, 54.305, 56.760, 58.961, 61.982, 65.176, 68.197, 71.300, 74.446, 77.218, 79.817, 82.425, 84.612, 86.684, 88.755, 90.827, 92.899, 94.970, 97.042, 99.114, 101.21, 103.37, 105.56, 107.75, 109.79, 111.95, 114.20, 116.63, 119.22, 121.79, 124.43, 126.48, 128.58, 130.78, 132.87, 134.98, 136.91, 139.22, 140.40])

  # Rescale.
  sample_t -= sample_t[0]
  sample_u *= 0.35 / sample_u[0]

  # Interpolate.
  return np.interp(t, sample_t, sample_u, period=sample_t[-1] - sample_t[0])

P = 0.99638 - 0.32918
current_time = [0, 0.5, P, 3*P, 5*P]
show_current = True

plt.figure(1)
t = np.linspace(0, 5*P, 1000)
plt.plot(t, amplitude(t), color='tab:blue')
if (show_current):
  plt.vlines(current_time, 0, 0.36, colors='tab:green', linestyles='dashed')
  # for i in range(len(current_time)):
  #   plt.annotate(f'$A={amplitude(current_time[i]):.3f}$', (current_time[i] + 0.1, 0.06), textcoords='offset points', xytext=(0, 10), ha='left', va='center', color='tab:blue', fontsize=24)
  #   plt.annotate(f'$t={current_time[i]}$', (current_time[i] + 0.19, 0.03), textcoords='offset points', xytext=(0, 10), ha='left', va='center', color='tab:green', fontsize=24)  
plt.ylim(0, 0.36)
plt.xlabel('$t$ (s)')
plt.ylabel('$A(t)$ (m/s)')
plt.title('Oscillating inlet amplitude')
plt.minorticks_on()

print(f"Min: A({t[np.argmin(amplitude(t[0:200]))]}) = {np.min(amplitude(t))}, max: A({t[np.argmax(amplitude(t[0:200]))]}) = {np.max(amplitude(t))}")