function velocity = importdata_manufactured(dim, x_sample, L, U, v_interpolant)
  % Evaluate at all sample points.
  velocity = cell(dim, 1);
  if (dim == 2)
    velocity{1} = U.*v_interpolant{1}(x_sample{1}./L, x_sample{2}./L);
    velocity{2} = U.*v_interpolant{2}(x_sample{1}./L, x_sample{2}./L);

    % Set NaN values to 0.
    velocity{1}(isnan(velocity{1})) = 0;
    velocity{2}(isnan(velocity{2})) = 0;
  elseif (dim == 3)
    velocity{1} = U.*v_interpolant{1}(x_sample{1}./L, x_sample{2}./L, x_sample{3}./L);
    velocity{2} = U.*v_interpolant{2}(x_sample{1}./L, x_sample{2}./L, x_sample{3}./L);
    velocity{3} = U.*v_interpolant{3}(x_sample{1}./L, x_sample{2}./L, x_sample{3}./L);

    % Set NaN values to 0.
    velocity{1}(isnan(velocity{1})) = 0;
    velocity{2}(isnan(velocity{2})) = 0;
    velocity{3}(isnan(velocity{3})) = 0;
  end

end