function [S, S_x, S_y, S_z, phi, G_store, x_t] = calculate_s(dim, x, v, D, no_t_steps, gamma, delta, Delta, b, store_every_timestep)
  %% Setup.
  no_molecules = size(x, 2);

  % TODO: check notation for this?
  g1_list = sqrt((b*1e6)./( (gamma^2)*(delta^2)*(Delta - (delta/3))))*1e3;

  G_store = zeros(length(b), no_t_steps);
  if (store_every_timestep)
    phi     = zeros(length(b), no_molecules, dim, no_t_steps);
    x_t     = zeros(length(b), dim, no_molecules, no_t_steps);
  else
    phi     = zeros(length(b), no_molecules, dim);
    x_t     = zeros(length(b), dim, no_molecules);
  end

  %% Loop over each b-value.
  for n = 1:length(b)
    % TODO: perhaps there's a nicer way of doing this?
    [t, dt, G] = generate_simple_19b_gradients_ns(g1_list(n), no_t_steps, 0);

    displacement = zeros(dim, no_molecules);
    position     = x;

    dr                 = zeros(1, no_molecules);
    dr(1:no_molecules) = sqrt(2*D*dt*1e-3);

    t  = t*1e-3;
    dt = dt*1e-3;
    G  = G*1e-3;

    G_store(n, :) = G;

    % Store the phase and gradient..
    if (store_every_timestep)
      [phi(n, :, :, :), x_t(n, :, :, :)] = calculate_diffusion(position, displacement, dr, false, G, t, dt, dim, v, store_every_timestep);
    else
      [phi(n, :, :),    x_t(n, :, :)]    = calculate_diffusion(position, displacement, dr, false, G, t, dt, dim, v, store_every_timestep);
    end
  end

  if (store_every_timestep)
    S_x = abs(sum(exp(-1i.*phi(:, :, 1, end)), 2));
    S_y = abs(sum(exp(-1i.*phi(:, :, 2, end)), 2));
    S   = S_x + S_y;
    if (dim == 3)
      S_z = abs(sum(exp(-1i.*phi(:, :, 3, end)), 2));
      S   = S + S_z;
    else
      S_z = 0;
    end
  else
    S_x = abs(sum(exp(-1i.*phi(:, :, 1)), 2));
    S_y = abs(sum(exp(-1i.*phi(:, :, 2)), 2));
    S   = S_x + S_y;
    if (dim == 3)
      S_z = abs(sum(exp(-1i.*phi(:, :, 3)), 2));
      S   = S + S_z;
    else
      S_z = 0;
    end
  end

end

