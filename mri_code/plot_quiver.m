%% Quiver plots.
fprintf("  Plotting quiver... ")

load(strcat('../output/mri-quantities_', filename_no_ext, '.mat'))

% Create output folders if they are missing.
create_missing_folders('../images/');

% Dimensions of individual plots.
im_dim_x = 400;
im_dim_y = 400;

% % Loop over each z-slice.
% parfor voxel_z = 1:N_voxels_z
%     fig = figure(N_voxels + voxel_z);
%     clf
%     fig.Units = 'pixels';
%     fig.InnerPosition = [0 0 2000*x_range 2000*y_range];

%     % "Hack" that gives us the z indices in this z-slice.
%     [~, ~, k] = voxel2indices(voxel_z*N_voxels_x*N_voxels_y, points_per_voxel_x, points_per_voxel_y, points_per_voxel_z, N_voxels_x, N_voxels_y);

%     if (dim == 2)
%         quiverInLogScale(x_sample{1}(:, :, k), x_sample{2}(:, :, k), v_interpolant{1}(x_sample{1}(:, :, k), x_sample{2}(:, :, k)), v_interpolant{2}(x_sample{1}(:, :, k), x_sample{2}(:, :, k)), 1, [0 0 1])
%     elseif (dim == 3)
%         quiverInLogScale(x_sample{1}(:, :, k), x_sample{2}(:, :, k), v_interpolant{1}(x_sample{1}(:, :, k), x_sample{2}(:, :, k), x_sample{3}(:, :, k)), v_interpolant{2}(x_sample{1}(:, :, k), x_sample{2}(:, :, k), x_sample{3}(:, :, k)), 1, [0 0 1])
%     end

%     if (dim == 2)
%         title(sprintf("u and v"))
%     elseif (dim == 3)
%         title(sprintf("u and v between z = %d and z = %d\n", x_sample{3}(1, 1, k(1)), x_sample{3}(1, 1, k(end))))
%     end

%     hold on

%     for voxel_xy = 1:N_voxels_x*N_voxels_y
%         % Get the xy-indices for this voxel (no z-dependence).
%         [i, j, k] = voxel2indices(voxel_xy, points_per_voxel_x, points_per_voxel_y, points_per_voxel_z, N_voxels_x, N_voxels_y);

%         % Coordinates inside this voxel.
%         x_voxel = x_sample{1}(1, i, 1);
%         y_voxel = x_sample{2}(j, 1, 1);

%         x_lower = x_voxel(1);
%         x_upper = x_voxel(end);
%         y_lower = y_voxel(1);
%         y_upper = y_voxel(end);

%         % Add red lines for voxel outline, and adds voxel number text to centre.
%         plot([x_lower x_lower], L*[y_min - y_range*0.2 y_max + y_range*0.2], 'r--')
%         plot([x_upper x_upper], L*[y_min - y_range*0.2 y_max + y_range*0.2], 'r--')
%         plot(L*[x_min - x_range*0.2, x_max + x_range*0.2], [y_lower y_lower], 'r--')
%         plot(L*[x_min - x_range*0.2, x_max + x_range*0.2], [y_upper y_upper], 'r--')

%         text((x_lower+x_upper)/2, (y_lower+y_upper)/2, [num2str((voxel_z-1)*N_voxels_x*N_voxels_y + voxel_xy)], 'FontSize', 16, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'Color', [0 0 0 0])
%     end

%     daspect([1 1 1])
%     print(fig, '-dpng', strcat('../', 'images/', filename_no_ext, '_quiver_', num2str(voxel_z), '.png'))
%     close(fig)
%     pause(0.01)
% end

% Loop over each z-slice.
parfor voxel_z = 1:N_voxels_z
    fig = figure(N_voxels + voxel_z);
    clf
    fig.Units = 'pixels';
    fig.InnerPosition = [0 0 2000*x_range 2000*y_range];

    % "Hack" that gives us the z indices in this z-slice.
    [~, ~, k] = voxel2indices(voxel_z*N_voxels_x*N_voxels_y, points_per_voxel_x, points_per_voxel_y, points_per_voxel_z, N_voxels_x, N_voxels_y);

    % Loop over x-y voxels.
    for voxel_xy = 1:N_voxels_x*N_voxels_y
        [i, j, ~, i1, j1, ~, i2, j2, ~] = voxel2indices(voxel_xy, points_per_voxel_x, points_per_voxel_y, points_per_voxel_z, N_voxels_x, N_voxels_y);

        % Set point cloud colours.
        colour = [double(mod(i1, 2)) double(mod(j1, 2)) 0];

        % if (dim == 2)
        %     quiverInLogScale(x_sample{1}(j, i, k), x_sample{2}(j, i, k), v_interpolant{1}(x_sample{1}(j, i, k), x_sample{2}(j, i, k)), v_interpolant{2}(x_sample{1}(j, i, k), x_sample{2}(j, i, k)), 1, colour)
        % elseif (dim == 3)
        %     quiverInLogScale(x_sample{1}(j, i, k), x_sample{2}(j, i, k), v_interpolant{1}(x_sample{1}(j, i, k), x_sample{2}(j, i, k), x_sample{3}(j, i, k)), v_interpolant{2}(x_sample{1}(j, i, k), x_sample{2}(j, i, k), x_sample{3}(j, i, k)), 1, colour)
        % end

        quiverInLogScale(x_sample{1}(j, i, k), x_sample{2}(j, i, k), v_sample{1}(j, i, k), v_sample{2}(j, i, k), 1, colour)

        if (voxel_xy == 1)
            hold on
        end

        % Coordinates inside this voxel.
        x_voxel = x_sample{1}(1, i, 1);
        y_voxel = x_sample{2}(j, 1, 1);

        x_lower = x_voxel(1);
        x_upper = x_voxel(end);
        y_lower = y_voxel(1);
        y_upper = y_voxel(end);

        text((x_lower+x_upper)/2, (y_lower+y_upper)/2, [num2str((voxel_z-1)*N_voxels_x*N_voxels_y + voxel_xy)], 'FontSize', 16, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'Color', [0 0 0 0])
    end

    if (dim == 2)
        title(sprintf("u and v"))
    elseif (dim == 3)
        title(sprintf("u and v between z = %d and z = %d\n", x_sample{3}(1, 1, k(1)), x_sample{3}(1, 1, k(end))))
    end

    xlim(L*[x_min, x_max])
    ylim(L*[y_min, y_max])

    daspect([1 1 1])
    print(fig, '-dpng', strcat('../', 'images/', filename_no_ext, '_quiver_', num2str(voxel_z), '.png'))
    close(fig)
    pause(0.01)
end

fprintf("Plotted quiver.\n")