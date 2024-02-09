%% S against b.
fprintf("  Plotting plot S-vs-b... ")

load(strcat('../output/mri-quantities_', filename_no_ext, '_', num2str(run_no), '.mat'))

% Create output folders if they are missing.
create_missing_folders('../images/');
create_missing_folders('../images/subplots/');

% Dimensions of individual plots.
im_dim_x = 400;
im_dim_y = 400;

% Loop over each voxel.
parfor voxel = 1:N_voxels
    % Creates each individual figure.
    fig = figure(5*voxel - 4);
    fig.Units = 'pixels';
    fig.OuterPosition = [0 0 im_dim_x im_dim_y];

    fig_log = figure(5*voxel - 3);
    fig_log.Units = 'pixels';
    fig_log.OuterPosition = [0 0 im_dim_x im_dim_y];

    fig_S_x = figure(5*voxel - 2);
    fig_S_x.Units = 'pixels';
    fig_S_x.OuterPosition = [0 0 im_dim_x im_dim_y];

    fig_S_y = figure(5*voxel - 1);
    fig_S_y.Units = 'pixels';
    fig_S_y.OuterPosition = [0 0 im_dim_x im_dim_y];

    fig_G = figure(5*voxel);
    fig_G.Units = 'pixels';
    fig_G.OuterPosition = [0 0 im_dim_x im_dim_y];

    % if (dim == 3)
    %     fig_S_z = figure(5*voxel);
    %     fig_S_z.Units = 'pixels';
    %     fig_S_z.OuterPosition = [0 0 im_dim_x im_dim_y];
    % end

    % Get S.
    S_value   = S{voxel};
    S_value   = S_value/S_value(1);
    S_x_value = S_x{voxel};
    S_x_value = S_x_value/S_x_value(1);
    S_y_value = S_y{voxel};
    S_y_value = S_y_value/S_y_value(1);
    % if (dim == 3)
    %     S_z_value = S_z{voxel};
    %     S_z_value = S_z_value/S_z_value(1);
    % end

    % Calculates biexponential fit.
    %f_fit = f_ivim_fit(S_value.', b);

    % Plots S-vs-b for this voxel.
    figure(5*voxel - 4);
    plot(b, S_value, '.', 'markersize', 8, 'linewidth', 1, 'color', [1 0 0])
    hold on
    %plot(b, bi_exp(f_fit, b), 'b-')
    title("voxel #" + voxel)
    xlabel('b')
    ylabel('S/S_0')
    ylim([0 1])

    % Plots log(S)-vs-b for this voxel.
    figure(5*voxel - 3);
    semilogy(b, S_value, '.', 'markersize', 8, 'linewidth', 1, 'color', [1 0 0])
    hold on
    %semilogy(b, bi_exp(f_fit, b), 'b-')
    title("voxel #" + voxel)
    xlabel('b')
    ylabel('S/S_0')
    ylim([1e-5 1])

    % Plots S_x-vs-b for this voxel.
    figure(5*voxel - 2);
    plot(b, S_x_value, '.', 'markersize', 8, 'linewidth', 1, 'color', [1 0 0])
    title("voxel #" + voxel)
    xlabel('b')
    ylabel('S_x/S_x_0')
    ylim([0 1])

    % Plots S_y-vs-b for this voxel.
    figure(5*voxel - 1);
    plot(b, S_y_value, '.', 'markersize', 8, 'linewidth', 1, 'color', [1 0 0])
    title("voxel #" + voxel)
    xlabel('b')
    ylabel('S_y/S_y_0')
    ylim([0 1])

    figure(5*voxel);
    g = sqrt((b*1e6)./( (gamma^2)*(delta^2)*(Delta - (delta/3))))*1e3;
    plot(g, S_value, '.', 'markersize', 8, 'linewidth', 1, 'color', [1 0 0])
    title("voxel #" + voxel)
    xlabel('g')
    ylabel('S/S_0')
    ylim([0 1])


    % Plots S_z-vs-b (if apppropriate) for this voxel.
    % if (dim == 3)
    %     figure(5*voxel);
    %     plot(b, S_z_value, '.', 'markersize', 8, 'linewidth', 1, 'color', [1 0 0])
    %     title("voxel #" + voxel)
    %     xlabel('b')
    %     ylabel('S_z/S_z_0')
    %     ylim([0 1])
    % end

    % Saves each individual figure.
    print(fig, '-dpng', strcat('../', 'images/subplots/', filename_no_ext, '_s-vs-b_', num2str(voxel), '_', num2str(run_no) , '.png'))
    close(fig)
    pause(0.01) % Silly hack to close figures properly. [https://uk.mathworks.com/matlabcentral/answers/337109-unable-to-close-gui-figures]
    print(fig_log, '-dpng', strcat('../', 'images/subplots/', filename_no_ext, '_logs-vs-b_', num2str(voxel), '_', num2str(run_no) , '.png'))
    close(fig_log)
    pause(0.01)
    print(fig_S_x, '-dpng', strcat('../', 'images/subplots/', filename_no_ext, '_sx-vs-b_', num2str(voxel), '_', num2str(run_no) , '.png'))
    close(fig_S_x)
    pause(0.01)
    print(fig_S_y, '-dpng', strcat('../', 'images/subplots/', filename_no_ext, '_sy-vs-b_', num2str(voxel), '_', num2str(run_no) , '.png'))
    close(fig_S_y)
    pause(0.01)
    print(fig_G, '-dpng', strcat('../', 'images/subplots/', filename_no_ext, '_s-vs-g_', num2str(voxel), '_', num2str(run_no) , '.png'))
    close(fig_G)
    pause(0.01)
    % if (dim == 3)
    %     print(fig_S_z, '-dpng', strcat('../', 'images/subplots/', filename_no_ext, '_sz-vs-b_', num2str(voxel), '.png'))
    %     close(fig_S_z)
    %     pause(0.01)
    % end
end

% Constructs larger S-vs-b image.
parfor voxel_z = 1:N_voxels_z
    fig = figure(5*N_voxels + 5*voxel_z - 4);
    clf
    fig.Units = 'pixels';
    fig.InnerPosition = [0 0 N_voxels_x*im_dim_x N_voxels_y*im_dim_y];

    fig = figure(5*N_voxels + 5*voxel_z - 3);
    clf
    fig.Units = 'pixels';
    fig.InnerPosition = [0 0 N_voxels_x*im_dim_x N_voxels_y*im_dim_y];

    fig = figure(5*N_voxels + 5*voxel_z - 2);
    clf
    fig.Units = 'pixels';
    fig.InnerPosition = [0 0 N_voxels_x*im_dim_x N_voxels_y*im_dim_y];

    fig = figure(5*N_voxels + 5*voxel_z - 1);
    clf
    fig.Units = 'pixels';
    fig.InnerPosition = [0 0 N_voxels_x*im_dim_x N_voxels_y*im_dim_y];

    fig = figure(5*N_voxels + 5*voxel_z);
    clf
    fig.Units = 'pixels';
    fig.InnerPosition = [0 0 N_voxels_x*im_dim_x N_voxels_y*im_dim_y];

    filenames     = cell(N_voxels_x*N_voxels_y, 1);
    filenames_log = cell(N_voxels_x*N_voxels_y, 1);
    filenames_x   = cell(N_voxels_x*N_voxels_y, 1);
    filenames_y   = cell(N_voxels_x*N_voxels_y, 1);
    filenames_g   = cell(N_voxels_x*N_voxels_y, 1);
    % if (dim == 3)
    %     filenames_z = cell(N_voxels_x*N_voxels_y, 1);
    % end
    for voxel_xy = 1:N_voxels_x*N_voxels_y
        pos                = voxel2subplot(voxel_xy, N_voxels_x*N_voxels_y, N_voxels_x, N_voxels_y);
        filenames{pos}     = strcat('../images/subplots/', filename_no_ext, '_s-vs-b_', num2str((voxel_z-1)*N_voxels_x*N_voxels_y + voxel_xy), '_', num2str(run_no) , '.png');
        filenames_log{pos} = strcat('../images/subplots/', filename_no_ext, '_logs-vs-b_', num2str((voxel_z-1)*N_voxels_x*N_voxels_y + voxel_xy), '_', num2str(run_no) , '.png');
        filenames_x{pos}   = strcat('../images/subplots/', filename_no_ext, '_sx-vs-b_', num2str((voxel_z-1)*N_voxels_x*N_voxels_y + voxel_xy), '_', num2str(run_no) , '.png');
        filenames_y{pos}   = strcat('../images/subplots/', filename_no_ext, '_sy-vs-b_', num2str((voxel_z-1)*N_voxels_x*N_voxels_y + voxel_xy), '_', num2str(run_no) , '.png');
        filenames_g{pos}   = strcat('../images/subplots/', filename_no_ext, '_s-vs-g_', num2str((voxel_z-1)*N_voxels_x*N_voxels_y + voxel_xy), '_', num2str(run_no) , '.png');
        % if (dim == 3)
        %     filenames_z{pos} = strcat('../images/subplots/', filename_no_ext, '_sz-vs-b_', num2str((voxel_z-1)*N_voxels_x*N_voxels_y + voxel_xy), '.png');
        % end
    end

    % "Hack" that gives us the z indices in this z-slice.
    [~, ~, k] = voxel2indices(voxel_z*N_voxels_x*N_voxels_y, points_per_voxel_x, points_per_voxel_y, points_per_voxel_z, N_voxels_x, N_voxels_y);

    fig = figure(5*N_voxels + 5*voxel_z - 4);
    montage_data = get(montage(filenames, 'Size', [N_voxels_y N_voxels_x], 'ThumbnailSize', []), 'CData');
    if (dim == 2)
        title(sprintf("voxels in xy-plane"))
    elseif (dim == 3)
        title(sprintf("voxels between z = %d and z = %d\n", x_sample{3}(1, 1, k(1)), x_sample{3}(1, 1, k(end))))
    end
    imwrite(montage_data, strcat('../', 'images/', filename_no_ext, '_s-vs-b_', num2str(voxel_z), '_', num2str(run_no) , '.png'), 'png')
    close(fig)
    pause(0.01)

    fig = figure(5*N_voxels + 5*voxel_z - 3);
    montage_data = get(montage(filenames_log, 'Size', [N_voxels_y N_voxels_x], 'ThumbnailSize', []), 'CData');
    if (dim == 2)
        title(sprintf("voxels in xy-plane"))
    elseif (dim == 3)
        title(sprintf("voxels between z = %d and z = %d\n", x_sample{3}(1, 1, k(1)), x_sample{3}(1, 1, k(end))))
    end
    imwrite(montage_data, strcat('../', 'images/', filename_no_ext, '_logs-vs-b_', num2str(voxel_z), '_', num2str(run_no) , '.png'), 'png')
    close(fig)
    pause(0.01)

    fig = figure(5*N_voxels + 5*voxel_z - 2);
    montage_data = get(montage(filenames_x, 'Size', [N_voxels_y N_voxels_x], 'ThumbnailSize', []), 'CData');
    if (dim == 2)
        title(sprintf("voxels in xy-plane"))
    elseif (dim == 3)
        title(sprintf("voxels between z = %d and z = %d\n", x_sample{3}(1, 1, k(1)), x_sample{3}(1, 1, k(end))))
    end
    imwrite(montage_data, strcat('../', 'images/', filename_no_ext, '_sx-vs-b_', num2str(voxel_z), '_', num2str(run_no) , '.png'), 'png')
    close(fig)
    pause(0.01)

    fig = figure(5*N_voxels + 5*voxel_z - 1);
    montage_data = get(montage(filenames_y, 'Size', [N_voxels_y N_voxels_x], 'ThumbnailSize', []), 'CData');
    if (dim == 2)
        title(sprintf("voxels in xy-plane"))
    elseif (dim == 3)
        title(sprintf("voxels between z = %d and z = %d\n", x_sample{3}(1, 1, k(1)), x_sample{3}(1, 1, k(end))))
    end
    imwrite(montage_data, strcat('../', 'images/', filename_no_ext, '_sy-vs-b_', num2str(voxel_z), '_', num2str(run_no) , '.png'), 'png')
    close(fig)
    pause(0.01)

    fig = figure(5*N_voxels + 5*voxel_z);
    montage_data = get(montage(filenames_g, 'Size', [N_voxels_y N_voxels_x], 'ThumbnailSize', []), 'CData');
    if (dim == 2)
        title(sprintf("voxels in xy-plane"))
    elseif (dim == 3)
        title(sprintf("voxels between z = %d and z = %d\n", x_sample{3}(1, 1, k(1)), x_sample{3}(1, 1, k(end))))
    end
    imwrite(montage_data, strcat('../', 'images/', filename_no_ext, '_s-vs-g_', num2str(voxel_z), '_', num2str(run_no) , '.png'), 'png')
    close(fig)
    pause(0.01)

    % if (dim == 3)
    %     fig = figure(5*N_voxels + 5*voxel_z);
    %     montage_data = get(montage(filenames_z, 'Size', [N_voxels_y N_voxels_x], 'ThumbnailSize', []), 'CData');
    %     if (dim == 2)
    %         title(sprintf("voxels in xy-plane"))
    %     elseif (dim == 3)
    %         title(sprintf("voxels between z = %d and z = %d\n", x_sample{3}(1, 1, k(1)), x_sample{3}(1, 1, k(end))))
    %     end
    %     imwrite(montage_data, strcat('../', 'images/', filename_no_ext, '_sz-vs-b_', num2str(voxel_z), '.png'), 'png')
    %     close(fig)
    %     pause(0.01)
    % end
end

fprintf("Plotted S-vs-b.\n")