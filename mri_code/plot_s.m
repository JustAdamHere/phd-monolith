% Plots S graphs, assuming fixed 19 b-values.
fprintf("  Plotting plot S... ")

load(strcat('../output/mri-quantities_', filename_no_ext, '.mat'))

% Create output folders if they are missing.
create_missing_folders('../images/');

% Storage for S images for each choice of b-value.
S_image    = zeros(N_voxels_y, N_voxels_x, N_voxels_z, length(b));
Sx_image   = zeros(N_voxels_y, N_voxels_x, N_voxels_z, length(b));
Sy_image   = zeros(N_voxels_y, N_voxels_x, N_voxels_z, length(b));
if (dim == 3)
  Sz_image = zeros(N_voxels_y, N_voxels_x, N_voxels_z, length(b));
else % Awful hack to avoid error.
  Sz_image = zeros(N_voxels_y, N_voxels_x, N_voxels_z, length(b));
end
SRGB = zeros(N_voxels_y, N_voxels_x, N_voxels_z, length(b), 3);

for voxel = 1:N_voxels
  [~, ~, ~, ~, ~, ~, i, j, k] = voxel2indices(voxel, points_per_voxel_x, points_per_voxel_y, points_per_voxel_z, N_voxels_x, N_voxels_y);

  S_image(j, i, k, :)  = S  {voxel};
  Sx_image(j, i, k, :) = S_x{voxel};
  Sy_image(j, i, k, :) = S_y{voxel};
  if (dim == 3)
    Sz_image(j, i, k, :) = S_z{voxel};
  end
end

% Normalises images.
S_image    = S_image ./ max(S_image(:));
Sx_image   = Sx_image ./ max(Sx_image(:));
Sy_image   = Sy_image ./ max(Sy_image(:));
if (dim == 3)
  Sz_image = Sz_image ./ max(Sz_image(:));
end

% Constructs RGB image.
SRGB_image(:, :, :, :, 1) = Sx_image;
SRGB_image(:, :, :, :, 2) = Sy_image;
if (dim == 3)
  SRGB_image(:, :, :, :, 3) = Sz_image;
else
  SRGB_image(:, :, :, :, 3) = zeros(N_voxels_y, N_voxels_x, N_voxels_z, length(b));
end

% Creates tiled layout for each z-slice.
parfor voxel_z = 1:N_voxels_z
  % Create figures for each graph.
  fig_S    = figure(5*(voxel_z-1) + 1);
  tlo_S    = tiledlayout(fig_S, ceil(sqrt(length(b))), floor(sqrt(length(b))), 'TileSpacing', 'compact');
  fig_Sx   = figure(5*(voxel_z-1) + 2);
  tlo_Sx   = tiledlayout(fig_Sx, ceil(sqrt(length(b))), floor(sqrt(length(b))), 'TileSpacing', 'compact');
  fig_Sy   = figure(5*(voxel_z-1) + 3);
  tlo_Sy   = tiledlayout(fig_Sy, ceil(sqrt(length(b))), floor(sqrt(length(b))), 'TileSpacing', 'compact');
  if (dim == 3)
    fig_Sz   = figure(5*(voxel_z-1) + 4);
    tlo_Sz   = tiledlayout(fig_Sz, ceil(sqrt(length(b))), floor(sqrt(length(b))), 'TileSpacing', 'compact');
  end
  fig_SRGB = figure(5*(voxel_z-1) + 5);
  tlo_SRGB = tiledlayout(fig_SRGB, ceil(sqrt(length(b))), floor(sqrt(length(b))), 'TileSpacing', 'compact');

  % Plot each graph for each b-value.
  for i = 1:length(b)
    % S image.
    ax_S = nexttile(tlo_S);
    image_with_border = padarray(S_image(:, :, voxel_z, i), [1 1], 0, 'both');
    imshow(image_with_border, 'Parent', ax_S, 'Border', 'tight')
    title(['b = ', num2str(b(i))])
    set(gca, 'YDir', 'normal')

    % Sx image.
    ax_Sx = nexttile(tlo_Sx);
    image_with_border = padarray(Sx_image(:, :, voxel_z, i), [1 1], 0, 'both');
    imshow(image_with_border, 'Parent', ax_Sx, 'Border', 'tight')
    title(['b = ', num2str(b(i))])
    set(gca, 'YDir', 'normal')

    % Sy image.
    ax_Sy = nexttile(tlo_Sy);
    image_with_border = padarray(Sy_image(:, :, voxel_z, i), [1 1], 0, 'both');
    imshow(image_with_border, 'Parent', ax_Sy, 'Border', 'tight')
    title(['b = ', num2str(b(i))])
    set(gca, 'YDir', 'normal')

    % Sz image.
    if (dim == 3)
      ax_Sz = nexttile(tlo_Sz);
      image_with_border = padarray(Sz_image(:, :, voxel_z, i), [1 1], 0, 'both');
      imshow(image_with_border, 'Parent', ax_Sz, 'Border', 'tight')
      title(['b = ', num2str(b(i))])
      set(gca, 'YDir', 'normal')
    end

    % SRGB image (red for x; green for y; blue for z).
    ax_SRGB = nexttile(tlo_SRGB);
    image_with_border = padarray(squeeze(SRGB_image(:, :, voxel_z, i, :)), [1 1], 0, 'both');
    imshow(image_with_border, 'Parent', ax_SRGB, 'Border', 'tight')
    title(['b = ', num2str(b(i))])
    set(gca, 'YDir', 'normal')
  end

  % Colour legend example.
  ax_SRGB = nexttile(tlo_SRGB);
  [X, Y, Z] = meshgrid(linspace(0, 1, N_voxels_x), linspace(0, 1, N_voxels_y), flip(linspace(1, 0, N_voxels_z))); % Flip ensures we get 0 when N_points_z = 1.
  image = cat(3, X(:, :, voxel_z), Y(:, :, voxel_z), Z(:, :, voxel_z));
  image_with_border = padarray(image, [1 1], 0, 'both');
  imshow(image_with_border, 'Parent', ax_SRGB, 'Border', 'tight')
  title('Colour legend')
  limits = [xlim; ylim];
  xlabel('S_x', 'Position', [mean(limits(1, :)) limits(2, 1)])
  ylabel('S_y', 'Position', [limits(1, 1) mean(limits(2, :))])
  set(gca, 'YDir', 'normal')

  % Titles.
  title(tlo_S, 'S')
  title(tlo_Sx, 'S_x')
  title(tlo_Sy, 'S_y')
  if (dim == 3)
    title(tlo_Sz, 'S_z')
  end
  title(tlo_SRGB, 'S_{RGB}')

  % Save figures.
  print(fig_S, '-dpng', strcat('../', 'images/', filename_no_ext, '_s_', num2str(voxel_z), '.png'))
  close(fig_S)
  pause(0.01)

  print(fig_Sx, '-dpng', strcat('../', 'images/', filename_no_ext, '_sx_', num2str(voxel_z), '.png'))
  close(fig_Sx)
  pause(0.01)

  print(fig_Sy, '-dpng', strcat('../', 'images/', filename_no_ext, '_sy_', num2str(voxel_z), '.png'))
  close(fig_Sy)
  pause(0.01)

  if (dim == 3)
    print(fig_Sz, '-dpng', strcat('../', 'images/', filename_no_ext, '_sz_', num2str(voxel_z), '.png'))
    close(fig_Sz)
    pause(0.01)
  end

  print(fig_SRGB, '-dpng', strcat('../', 'images/', filename_no_ext, '_srgb_', num2str(voxel_z), '.png'))
  close(fig_SRGB)
  pause(0.01)
end

fprintf("Plotted S.\n")