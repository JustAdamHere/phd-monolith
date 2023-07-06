function [phi, x_t] = calculate_diffusion(x, r, dr, dif, G, t, dt, dim, u, store_every_timestep)
  % Simple diffusion sim and phase calculation.
  % Inputs:
  %         x   (Initial position of each spin)
  %         r   (Initial displacement of each spin)
  %         dr  (Diffusion step size of each spin)
  %         dif (Diffusion flag; true or false)
  %         G   (Gradient profile)
  %         t   (Time array of gradient)
  %         dt  (Time step size)
  %         d   (Dimension of problem; 2 or 3)
  %         u   (Velocity interpolant for each dimension)
  % store_e...  (Flag to store every timestep; true or false)

  % Number of molecules.
  no_molecules = size(x, 2);

  % Calculate gamma.
  gamma = 42.57*2*pi*1e6;

  % Initialise space array.
  if (store_every_timestep)
    x_t = zeros(dim, no_molecules, length(t));
  else
    x_t = zeros(dim, no_molecules);
  end

  % Forward integration of molecule.
  [x0, dudt] = calculate_updated_position(dim, x, u, dt);
  if (store_every_timestep)
    x_t(:, :, 1) = x0;
  else
    x_t(:, :) = x0;
  end

  % Initialise \phi array, to ultimately
  %  cumulativley sum phase accumulation
  %  https://gyazo.com/0f420ade5c1c565c8cb8527b44dc5235.
  if (store_every_timestep)
    phi = zeros(size(r, 2), dim, length(t));
    for d = 1:dim
      phi(:, d, 1) = gamma*G(1)*r(d, :)'.*dt;
    end
  else
    phi = zeros(size(r, 2), dim);
    for d = 1:dim
      phi(:, d) = gamma*G(1)*r(d, :)'.*dt;
    end
  end

  if (store_every_timestep)
    for n = 2:length(t)
      % Update positions of molecules.
      x_t(:, :, n) = x_t(:, :, n-1) + dudt;
      r            = x_t(:, :, n) - x0;

      % If we need to add random diffusion.
      % if (dif)
      %   x = x + dr.*randn(dim, no_molecules);
      % end

      % Cumulativley sum phase accumulation for each dimension.
      %  https://gyazo.com/0f420ade5c1c565c8cb8527b44dc5235
      for d = 1:dim
          phi(:, d, n) = phi(:, d, n-1) + gamma*G(n)*r(d, :)'.*dt;
      end
    end
  else
    for n = 2:length(t)
      % Update positions of molecules.
      x_t(:, :) = x_t(:, :) + dudt;
      r         = x_t(:, :) - x0;

      % If we need to add random diffusion.
      % if (dif)
      %   x = x + dr.*randn(dim, no_molecules);
      % end

      % Cumulativley sum phase accumulation for each dimension.
      %  https://gyazo.com/0f420ade5c1c565c8cb8527b44dc5235
      for d = 1:dim
          phi(:, d) = phi(:, d) + gamma*G(n)*r(d, :)'.*dt;
      end
    end
  end

end