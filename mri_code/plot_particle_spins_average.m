fprintf("  Plotting particle spin averages... ")

% load(strcat('../output/mri-quantities_', filename_no_ext, '.mat'))

% Create output folders if they are missing.
create_missing_folders('../images/');

% for voxel_xy = 1:N_voxels_x*N_voxels_y
voxel_xy = 1;
    grad_direction = 2;

    %%%%% COPIED FROM GENERATE SIMPLE GRADIENTS %%%%%%
    % Times in ms.
    t_start = 0;
    t_end   = 53;

    % At some point we need to flip the gradients
    inversion = 30.8;

    % Generate times and map back to 0.
    t = linspace(t_start, t_end, no_t_steps) - t_start;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Correctly pick out entries from sample points.
    [i, j, k] = voxel2indices(voxel_xy, points_per_voxel_x, points_per_voxel_y, points_per_voxel_z, N_voxels_x, N_voxels_y);

    x_voxel = zeros(dim, points_per_voxel);
    x_voxel(1, :) = reshape(x_sample{1}(j, i, k), 1, []);
    x_voxel(2, :) = reshape(x_sample{2}(j, i, k), 1, []);
    if (dim == 3)
        x_voxel(3, :) = reshape(x_sample{3}(j, i, k), 1, []);
    end

    % We will plot the circle with centre at the centre of the voxel.
    % if (dim == 2)
    %     centre_of_voxel = [mean(x_voxel(1, :)), mean(x_voxel(2, :))];
    % else
    %     centre_of_voxel = [mean(x_voxel(1, :)), mean(x_voxel(2, :)), mean(x_voxel(3, :))];
    % end

    centre_of_voxel = [0.5, 0.5];

    movie_frames = struct('cdata', cell(1, length(t)), 'colormap', cell(1, length(t)));

    colors = [1 0 0; 0 1 0; 0 0 1; 0 1 1];

    % fig = figure(voxel_xy);
    % set(fig, 'Visible', 'off');

    parfor n = 1:length(t)
        fig = figure();

        subplot(2, 2, 1)
        % r = 0.9*min((max(x_voxel(1, :) - min(x_voxel(1, :)))), (max(x_voxel(2, :) - min(x_voxel(2, :)))))/2;
        r = 0.9*0.5;
        circle(centre_of_voxel(1), centre_of_voxel(2), r, 'k-');
        hold on

        % legend_entries = cell(21, 1);
        legend_entries = cell(11, 1);
        legend_entries{1} = '';

        cmap = winter(length(b));

        for i = 1:length(b)
            %b_index = i*50 + 1;
            b_index = i;

            % Average phase.
            avg_phi = -angle(sum(exp(-1i.*phi{voxel_xy}(b_index, :, grad_direction, n)), 2));

            % Initial radius.
            r_0 = abs(sum(exp(-1i.*phi{voxel_xy}(b_index, :, grad_direction, 1)), 2));

            % Radius and coordinates of average spins.
            r_avg = 0.9*abs(sum(exp(-1i.*phi{voxel_xy}(b_index, :, grad_direction, n)), 2))./(2*r_0);
            x_avg = r_avg*cos(avg_phi) + centre_of_voxel(1);
            y_avg = r_avg*sin(avg_phi) + centre_of_voxel(2);

            % Plots the phase.
            %plot(x_avg, y_avg, 'ko')
            quiver(centre_of_voxel(1), centre_of_voxel(2), x_avg - centre_of_voxel(1), y_avg - centre_of_voxel(2), 0, 'linewidth', 2, 'color', cmap(i, :))
            pbaspect([1 1 1])

            % Adds legend entry.
            % legend_entries{2*i}   = num2str('');
            % legend_entries{2*i+1} = num2str(b(i));
            legend_entries{i+1} = num2str(b(b_index));
        end

        %legend(legend_entries, 'Location', 'eastoutside')

        % Annotates the molecule number.
        % for i = 1:points_per_voxel
        %   text(x(i), y(i), num2str(i))
        % end

        % Title for current time.
        title(['t = ', num2str(t(n)), 'ms'])

        % Gradient profile.
        subplot(2, 2, [2, 4])
        plot(t, G{voxel_xy}(b_index, :), 'k-')
        hold on
        plot(t(n), G{voxel_xy}(b_index, n), 'kx')

        % Velocity.
        subplot(2, 2, 3)
        % for i = 1:points_per_voxel
        %     plot(squeeze(x_t{voxel_xy}(b_index, 1, i, :)), squeeze(x_t{voxel_xy}(b_index, 2, i, :)), '-', 'Color', colors(i, :))
        %     hold on
        %     plot(squeeze(x_t{voxel_xy}(b_index, 1, i, n)), squeeze(x_t{voxel_xy}(b_index, 2, i, n)), 'x', 'Color', colors(i, :))
        % end

        % Adds current frame to movie.
        % drawnow
        % movie_frames(n) = getframe(fig);

        print(fig, '-dpng', strcat('../', 'images/subplots/', filename_no_ext, '_phase-avg_', num2str(voxel_xy), '_', num2str(n), '.png'))
        close(fig)
        pause(0.01)

        % Print.
        %fprintf('t = %.2f: %.2f + %.2f + %.2f + %.2f = %.2f\n', [t(n), phi{voxel_xy}(b_index, :, grad_direction, n), avg_phi])
    end

    movie_filename = strcat('../', 'images/', filename_no_ext, '_phase-avg_', num2str(voxel_xy), '.avi');
    video = VideoWriter(movie_filename);
    open(video)

    for i = 1:length(t)
        %writeVideo(video, movie_frames(i));
        image = imread(strcat('../', 'images/subplots/', filename_no_ext, '_phase-avg_', num2str(voxel_xy), '_', num2str(i), '.png'));
        writeVideo(video, image)
    end

    close(video)


% end

fprintf("Plotted particle spin averages.\n")