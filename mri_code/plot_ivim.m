%% Plot IVIM.
fprintf("  Plotting IVIM... ")

load(strcat('../output/mri-quantities_', filename_no_ext, '_', num2str(run_no), '.mat'))

% Create output folders if they are missing.
create_missing_folders('../images/');

% Either calculate or load IVIM fit data.
calculate_ivim = true;

%% Calculate IVIM.
if (calculate_ivim)
  ivim_fit = zeros(N_voxels_y, N_voxels_x, 4);
  parfor i = 1:N_voxels_x
    for j = 1:N_voxels_y
      k = (j-1)*N_voxels_x + i;
      S_temp = S{k};

      ivim_fit(j, i, :) = f_ivim_fit(S_temp, b');
    end
  end
  save(strcat('../output/ivim_', filename_no_ext, '_', num2str(run_no), '.mat'), 'ivim_fit')
else
  load(strcat('../output/ivim_', filename_no_ext, '_', num2str(run_no), '.mat'))
end

%% Plot IVIM.
fig = figure(1);
clf
colormap autumn
imagesc(ivim_fit(:, :, 2))
set(gca, 'XTick', [], 'YTick', [])
set(gca, 'YDir', 'normal')
axis equal
axis tight
cb = colorbar('southoutside');
clim([0 1])
xlabel(cb, "$f_{\mathrm{IVIM}}$", 'Interpreter', 'latex')
exportgraphics(fig, strcat('../images/', filename_no_ext, '_ivim_', num2str(run_no), '.png'))

fprintf("Plotted IVIM.\n")