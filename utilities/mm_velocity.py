import numpy as np

def get_segment_area(h, r):
  # Area of segment [https://www.omnicalculator.com/math/segment-area].
  return r**2*np.arccos((r-h)/r) - (r-h)*np.sqrt(2*r*h-h**2)

def get_spherical_cap_volume(h, a):
  # Volume of cap [https://www.omnicalculator.com/math/sphere-volume].
  return (1/6)*np.pi*h*(3*(a)**2 + h**2)

# Placenta dimensions.
placenta_width  = 22e-2/0.04 # 22cm
placenta_height = 3.626e-2/0.04 # 3.626cm
ms_pipe_width_max   = 0.3e-2/0.04 # 0.3cm
dome_centre_x = placenta_width/2
dome_centre_y = (placenta_height - ms_pipe_width_max)/2 + dome_centre_x**2/(2*(placenta_height - ms_pipe_width_max))
placenta_dome_radius = dome_centre_y

print(f"Placenta dimensions: width={placenta_width:.2f}, height={placenta_height:.2f}, ms_pipe_width_max={ms_pipe_width_max:.2f}, dome_centre_x={dome_centre_x:.2f}, dome_centre_y={dome_centre_y:.2f}, placenta_dome_radius={placenta_dome_radius:.2f}")

# Initial geometry dimensions with 3D volume.
h_max = placenta_height # Cap height.
a_max = 11.0e-2/0.04  # Cap base radius.
a_hat_max = 0.437e-2/0.04 # Extra length for curve.
r_max = placenta_dome_radius
cap_volume = get_spherical_cap_volume(h_max, a_max + a_hat_max)
V_max = cap_volume

print(f"Initial 3D dimensions: h_max={h_max}, a_max+a_hat_max={a_max+a_hat_max}, r_max={r_max}")
print(f"Initial 3D volume: V_max={V_max}")

# Initial 2D area.
chord_area = r_max**2*np.arccos((r_max-h_max)/r_max) - (r_max-h_max)*np.sqrt(2*r_max*h_max-h_max**2)
A_max = chord_area

print(f"Initial 2D area: A_max={A_max}")

# 3D volume reduction.
volume_reduction = 0.3378378378378379#0.35
area_reduction = 1 - (1-volume_reduction)**(2/3)
V_min = V_max*(1-volume_reduction)
A_min = A_max*(1-area_reduction)

print(f"3D volume reduction by {100*volume_reduction}%: V_min={V_min}")
print(f"2D area reduction by {100*area_reduction}%: A_min={A_min}")

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
print(f"Deflated 3D volume: V_min={get_spherical_cap_volume(h_min, a_min+a_hat_min)}")
print(f"Deflated 2D area: A_min={get_segment_area(h_min, r_min)}")

p = [placenta_width/2, placenta_height]

print(f"Initial position: {p}")

## Calculate the best W to approximate the target_s ##
# Centre about the inflation.
x_c = np.array([placenta_width/2, placenta_height/2])

# Oscillating domain velocity.
def w(W, x, x_c, t):
  return W*np.sin(2*np.pi*t)*(x - x_c)
  #return np.where(t<0.5, W*(x - x_c), -W*(x - x_c))

# Displacement at t=0.5 and t=1.
def p_positions(W, p0, x_c, t):
  p = p0
  N = len(t)
  for i in range(int(N/2)):
    p += dt*w(W, p, x_c, t[i])
  x_mid = p.copy()
  for i in range(int(N/2), N):
    p += dt*w(W, p, x_c, t[i])
  x_end = p

  return x_mid, x_end

# Problem parameters.
#T = 60*16*2/0.1143 # 2*16 minutes, divided by scaling
#T = 2*60*(15.262237762237763-14.055944055944057)/0.1143
T = 2*60*(16.117274167987322-14.3114)/0.1143
N = 100#100000
dt = T/N
t = np.linspace(0, T, N)

print(f"Time step: {dt}, total time: {T}, number of time steps: {N}")

# Bounds of W.
W_max = -1e-10
W_min = -1e-3

print(f"Initial velocity bounds: [{W_min}, {W_max}]")

def get_reduced_area(W, p, x_c, t, r_max, h_max):
  x_mid, x_end = p_positions(W, p, x_c, t/T)

  s = p - x_mid
  h = x_mid[1] - s[1]
  k5 = r_max/h_max
  r = h*k5
  A = get_segment_area(h, r)

  s_end = p - x_end
  h_end = x_end[1] - s_end[1]
  r_end = h_end*k5

  A_end = get_segment_area(h_end, r_end)

  return A, A_end

# Do bisection.
A_test_min, _ = get_reduced_area(W_min, p, x_c, t, r_max, h_max)
A_test_max, _ = get_reduced_area(W_max, p, x_c, t, r_max, h_max)

print(f"Initial reduced area bounds: [{A_test_min}, {A_test_max}]")

W = (W_min + W_max)/2
A, A_end = get_reduced_area(W, p, x_c, t, r_max, h_max)
N_itns = 0
while ((np.abs(A_min - A) > 1e-10) and (N_itns < 100)):
  N_itns += 1
  W = (W_min + W_max)/2
  A, A_end = get_reduced_area(W, p, x_c, t, r_max, h_max)
  if (A < A_min):
    W_min = W
    A_test_min = A
  else:
    W_max = W
    A_test_max = A
  print(f"Iteration {N_itns}: W={W}, A={A}, A_end_diff_percentage={100*(A_end-A_max)/A_max}")

print(f"Complete in {N_itns} iterations")
print(f"Final domain velocity: {W}, area: {A}, target area: {A_min}, diff = {A - A_min}, A_end_diff_percentage={100*(A_end-A_max)/A_max}")