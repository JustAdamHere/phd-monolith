function [t, dt, G] = generate_simple_19b_gradients_ns(g1, no_samples, offset)
  % Times in ms.
  t_start = 0;
  t_end   = 53;

  % At some point we need to flip the gradients
  inversion = 30.8;

  % Generate times and map back to 0.
  t = linspace(t_start, t_end, no_samples) - t_start;

  % Time step (assumed uniform).
  dt = t(2) - t(1);

  % Pre allocate gradient at each timestep.
  G = zeros(1, no_samples);

  % Lobe 1.
  t1_1    = 3.2;
  t2_1    = 19.1;
  g_max_1 = g1;
  G(1, :) = add_lobe_ns(G(1, :), dt, t1_1, t2_1, g_max_1);

  % Lobe 2.
  t1_1    = 34.1;
  t2_1    = 50;
  g_max_1 = g1;
  G(1, :) = add_lobe_ns(G(1, :), dt, t1_1, t2_1, g_max_1);

  % Add inversion.
  inv_n           = round((inversion/dt))+1;
  G               = G + offset;
  G(1, inv_n:end) = -G(:, inv_n:end);

  G(:, 1:inv_n-1) = G(:, 1:inv_n-1) + offset;
  G(:, inv_n:end) = G(:, inv_n:end) - offset;

end