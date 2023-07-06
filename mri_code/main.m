%% Get MRI-related quantities.
fprintf("  Getting quantities... ")

store_every_timestep = false;

% Pre-allocate storage for signals (total, x-direction, y-direction, and z-direction).
S   = cell(N_voxels, 1);
S_x = cell(N_voxels, 1);
S_y = cell(N_voxels, 1);
if (dim == 3)
    S_z = cell(N_voxels, 1);
end
phi = cell(N_voxels, 1);
G   = cell(N_voxels, 1);
x_t = cell(N_voxels, 1);

% Loop over every voxel.
parfor voxel = 1:N_voxels
  % Correctly pick out entries from sample points.
  [i, j, k] = voxel2indices(voxel, points_per_voxel_x, points_per_voxel_y, points_per_voxel_z, N_voxels_x, N_voxels_y);

  x_voxel = zeros(dim, points_per_voxel);
  x_voxel(1, :) = reshape(x_sample{1}(j, i, k), 1, []);
  x_voxel(2, :) = reshape(x_sample{2}(j, i, k), 1, []);
  if (dim == 3)
    x_voxel(3, :) = reshape(x_sample{3}(j, i, k), 1, []);
  end

  v_voxel = zeros(dim, points_per_voxel);
  v_voxel(1, :) = reshape(v_sample{1}(j, i, k), 1, []);
  v_voxel(2, :) = reshape(v_sample{2}(j, i, k), 1, []);
  if (dim == 3)
    v_voxel(3, :) = reshape(v_sample{3}(j, i, k), 1, []);
  end

  % Compute signal in this voxel.
  if (dim == 3)
    [S{voxel}, S_x{voxel}, S_y{voxel}, S_z{voxel}, phi{voxel}, G{voxel}, x_t{voxel}] = calculate_s(dim, x_voxel, v_voxel, D, no_t_steps, gamma, delta, Delta, b, store_every_timestep);
  else
    [S{voxel}, S_x{voxel}, S_y{voxel}, ~,          phi{voxel}, G{voxel}, x_t{voxel}] = calculate_s(dim, x_voxel, v_voxel, D, no_t_steps, gamma, delta, Delta, b, store_every_timestep);
  end
end

save(strcat('../output/mri-quantities_', filename_no_ext, '.mat'))

fprintf("Got quantities.\n")