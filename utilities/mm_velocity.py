import numpy as np

# SOMETHING INCORRECT HERE, TO DO WITH VOLUME CONSISTING OF CAP AND DISK
# # Placenta dimensions.
# placenta_width  = 22 # 22cm
# placenta_height = 3.626 # 3.626cm
# ms_pipe_width_max   = 0.3   # cm
# dome_centre_x = placenta_width/2
# dome_centre_y = (placenta_height - ms_pipe_width_max)/2 + dome_centre_x**2/(2*(placenta_height - ms_pipe_width_max))
# placenta_dome_radius = dome_centre_y

# print(f"Placenta dimensions: width={placenta_width}, height={placenta_height}, ms_pipe_width_max={ms_pipe_width_max}, dome_centre_x={dome_centre_x}, dome_centre_y={dome_centre_y}, placenta_dome_radius={placenta_dome_radius}")

# # Initial geometry dimensions with 3D volume.
# h_max = placenta_height - ms_pipe_width_max # Cap height.
# a_max = 11.0  # Cap base radius.
# r_max = placenta_dome_radius
# cap_volume = (1/6)*np.pi*h_max*(3*a_max**2 + h_max**2) # Volume of cap [https://www.omnicalculator.com/math/sphere-volume].
# disk_volume = np.pi*r_max**2*ms_pipe_width_max # Volume of disk.
# V_max = cap_volume + disk_volume

# print(f"Initial 3D dimensions: h_max={h_max}, a_max={a_max}, r_max={r_max}, cap_volume={cap_volume}, disk_volume={disk_volume}")
# print(f"Initial 3D volume: V_max={V_max}")

# # Initial 2D area.
# chord_area = r_max**2*np.arccos((r_max-h_max)/r_max) - (r_max-h_max)*np.sqrt(2*r_max*h_max-h_max**2)
# rectangle_area = a_max*ms_pipe_width_max
# A_max = chord_area + rectangle_area

# print(f"Initial 2D area: A_max={A_max}")

# # 3D volume reduction.
# volume_reduction = 0.35
# V_min = V_max*(1-volume_reduction)

# print(f"3D volume reduction by {100*volume_reduction}%: V_min={V_min}")

# # Corresponding cap height and radius, assuming they remain proportional.
# k1 = a_max/h_max
# k2 = ms_pipe_width_max/h_max
# k3 = r_max/h_max
# h_min = (6*V_min/(np.pi*(3*k1**2+1)))**(1/3)
# a_min = k1*h_min
# ms_pipe_width_min = k2*h_min
# r_min = k3*h_min

# print(f"Deflated 3D dimensions: h_min={h_min}, a_min={a_min}, ms_pipe_width_min={ms_pipe_width_min}, r_min={r_min}")

# # Corresponding 2D area.
# chord_area = r_min**2*np.arccos((r_min-h_min)/r_min) - (r_min-h_min)*np.sqrt(2*r_min*h_min-h_min**2)
# rectangle_area = a_min*ms_pipe_width_min
# A_min = chord_area + rectangle_area

# print(f"Equivalent 2D volume, reduced by {100*(1-A_min/A_max)}%: A_min={A_min}")

# Placenta dimensions.
placenta_width  = 22 # 22cm
placenta_height = 3.626 # 3.626cm
ms_pipe_width_max   = 0.3   # cm
dome_centre_x = placenta_width/2
dome_centre_y = (placenta_height - ms_pipe_width_max)/2 + dome_centre_x**2/(2*(placenta_height - ms_pipe_width_max))
placenta_dome_radius = dome_centre_y

print(f"Placenta dimensions: width={placenta_width}, height={placenta_height}, ms_pipe_width_max={ms_pipe_width_max}, dome_centre_x={dome_centre_x}, dome_centre_y={dome_centre_y}, placenta_dome_radius={placenta_dome_radius}")

# Initial geometry dimensions with 3D volume.
h_max = placenta_height # Cap height.
a_max = 11.0  # Cap base radius.
a_hat_max = 0.437 # Extra radius for curve.
r_max = placenta_dome_radius
cap_volume = (1/6)*np.pi*h_max*(3*(a_max+a_hat_max)**2 + h_max**2) # Volume of cap [https://www.omnicalculator.com/math/sphere-volume].
V_max = cap_volume

print(f"Initial 3D dimensions: h_max={h_max}, a_max+a_hat_max={a_max+a_hat_max}, r_max={r_max}")
print(f"Initial 3D volume: V_max={V_max}")

# Initial 2D area.
chord_area = r_max**2*np.arccos((r_max-h_max)/r_max) - (r_max-h_max)*np.sqrt(2*r_max*h_max-h_max**2)
A_max = chord_area

print(f"Initial 2D area: A_max={A_max}")

# 3D volume reduction.
volume_reduction = 0.35
V_min = V_max*(1-volume_reduction)

print(f"3D volume reduction by {100*volume_reduction}%: V_min={V_min}")

# Corresponding cap height and radius, assuming they remain proportional.
k1 = a_max/h_max
k2 = ms_pipe_width_max/h_max
k3 = r_max/h_max
k4 = a_hat_max/h_max
h_min = (6*V_min/(np.pi*(3*(k1+k4)**2+1)))**(1/3)
a_min = k1*h_min
ms_pipe_width_min = k2*h_min
r_min = k3*h_min
a_hat_min = k4*h_min

print(f"Deflated 3D dimensions: h_min={h_min}, a_min+a_hat_min={a_min+a_hat_min}, ms_pipe_width_min={ms_pipe_width_min}, r_min={r_min}")

# Corresponding 2D area.
chord_area = r_min**2*np.arccos((r_min-h_min)/r_min) - (r_min-h_min)*np.sqrt(2*r_min*h_min-h_min**2)
A_min = chord_area

print(f"Equivalent 2D volume, reduced by {100*(1-A_min/A_max):.2f}%: A_min={A_min:.2f}")

# Top left of placenta, not including marginal sinus vein.
p = [placenta_width, placenta_height]

# Maximal displacement of p required to give desired area change.
s_target = a_max - a_min

print(f"Target displacement: {a_max:.2f}-{a_min:.2f}={s_target:.2f}")

## Calculate the best W to approximate the target_s ##
# Centre about the inflation.
x_c = np.array([placenta_width/2, placenta_height/2])

# Oscillating domain velocity.
def w(W, x, x_c, t):
  return W*np.sin(2*np.pi*t)*(x - x_c)

# Displacement at t=0.5 and t=1.
def displacement(W, p0, x_c, t):
  p = p0
  N = len(t)
  for i in range(len(t)):
    p += dt*w(W, p, x_c, t[i])
    if (i == N/2 or i+1 == N/2):
      s_mid = p[0]
  s_end = p[0]

  return [s_mid, s_end]

# Problem parameters.
T = 60*16*2/0.1143 # 2*16 minutes, divided by scaling
N = 1000
dt = T/N
t = np.linspace(0, T, N)

print(f"Time step: {dt}, total time: {T}, number of time steps: {N}")

# Bounds of W.
W_max = -0.00001
W_min = -0.01
s_max = p[0] - displacement(W_max, p, x_c, t/T)[0]
s_min = p[0] - displacement(W_min, p, x_c, t/T)[0]

print(f"Initial domain velocity bounds: [{W_min}, {W_max}]")
print(f"Initial displacement bounds: [{s_min}, {s_max}]")
print(f"Initial position: {p}")

s = 1000
N_max = 10
N = 0
while (np.abs(s - s_target) >= 1e-5) and (N < N_max):
  N += 1
  assert((s_max-s_target)*(s_min-s_target) < 0)
  W = (W_max + W_min)/2
  s, s_end = displacement(W, p, x_c, t/T)
  if ((s-s_target)*(s_max-s_target) < 0):
    W_min = W
    s_min = s
  else:
    W_max = W
    s_max = s

  print(f"W_min={W_min}, W_max={W_max}, s={s}, s_diff={s-s_target}, s_end={s_end}")

print(f"W={W}, s_end={p[0]-s_end}")

# N = 10000: W=-2.685757637023926e-05
# N = 1000: W=-2.6877875328063972e-05
# N = 100: W=-2.7107772827148444e-05