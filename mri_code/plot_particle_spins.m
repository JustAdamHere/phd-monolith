fprintf("  Plotting particle spins... ")

load(strcat('../output/mri-quantities_', filename_no_ext, '_', run_no, '.mat'))

% Create output folders if they are missing.
create_missing_folders('../images/');

for voxel_xy = 1:N_voxels_x*N_voxels_y
  b_index = 15;
  grad_direction = 2;

  % Times in ms.
  t_start = 0;
  t_end   = 53;

  % At some point we need to flip the gradients
  inversion = 30.8;

  % All timesteps.
  t = linspace(t_start, t_end, no_t_steps) - t_start;

  % Correctly pick out entries from sample points.
  [i, j, k] = voxel2indices(voxel_xy, points_per_voxel_x, points_per_voxel_y, points_per_voxel_z, N_voxels_x, N_voxels_y);

  x_voxel = zeros(dim, points_per_voxel);
  x_voxel(1, :) = reshape(x_sample{1}(j, i, k), 1, []);
  x_voxel(2, :) = reshape(x_sample{2}(j, i, k), 1, []);
  if (dim == 3)
    x_voxel(3, :) = reshape(x_sample{3}(j, i, k), 1, []);
  end

  % We will plot the circle with centre at the centre of the voxel.
  if (dim == 2)
    centre_of_voxel = [mean(x_voxel(1, :)), mean(x_voxel(2, :))];
  else
    centre_of_voxel = [mean(x_voxel(1, :)), mean(x_voxel(2, :)), mean(x_voxel(3, :))];
  end

  %colors = [1 0 0; 0 1 0; 0 0 1; 0 1 1];
  colors = winter(points_per_voxel);
  %colors(1, :)
  color = [0, 0, 0, 0.99];

  % fig = figure(voxel_xy);
  % set(fig, 'Visible', 'off');
  if (store_every_timestep)
    r_0 = abs(sum(exp(-1i.*phi{voxel_xy}(b_index, :, grad_direction, 1)), 2));
  else
    r_0 = abs(sum(exp(-1i.*phi{voxel_xy}(b_index, :, grad_direction, :)), 2));
  end

  if (store_every_timestep)
    movie_frames = struct('cdata', cell(1, length(t)), 'colormap', cell(1, length(t)));

    for n = 1:length(t)
      % Average phase.
      avg_phi = -angle(sum(exp(-1i.*phi{voxel_xy}(b_index, :, grad_direction, n)), 2));

      % Radius and coordinates of each molecule's spin.
      r = 0.9*min((max(x_voxel(1, :) - min(x_voxel(1, :)))), (max(x_voxel(2, :) - min(x_voxel(2, :)))))/2;
      x = r*cos(phi{voxel_xy}(b_index, :, grad_direction, n)) + centre_of_voxel(1);
      y = r*sin(phi{voxel_xy}(b_index, :, grad_direction, n)) + centre_of_voxel(2);

      % Radius and coordinates of average spins.
      r_avg = 0.9*abs(sum(exp(-1i.*phi{voxel_xy}(b_index, :, grad_direction, n)), 2))/(2*r_0);
      x_avg = r_avg*cos(avg_phi) + centre_of_voxel(1);
      y_avg = r_avg*sin(avg_phi) + centre_of_voxel(2);

      % Draws arrows from centre to each molecule's spin.
      arrows = [x - centre_of_voxel(1); y - centre_of_voxel(2)];
      arrows_mag = 2*sqrt(arrows(1, :).^2 + arrows(2, :).^2)/0.9;

      fig = figure();

      % Plots the phase.
      subplot(2, 2, 1)
      % circle(centre_of_voxel(1), centre_of_voxel(2), r, 'k-');
      circle(0.5, 0.5, 0.5, 'k-');
      hold on
      for i = 1:points_per_voxel
        plot(x(i), y(i), 'o', 'Color', colors(i, :))
        quiver(0.5, 0.5, arrows(1, i)./arrows_mag(i), arrows(2, i)./arrows_mag(i), 0, 'filled', 'Color', colors(i, :))
      end
      plot(x_avg, y_avg, 'ko')
      quiver(0.5, 0.5, x_avg - 0.5, y_avg - 0.5, 0, 'filled', 'k')
      pbaspect([1 1 1])

      % Annotates the molecule number.
      % for i = 1:points_per_voxel
      %   text(x(i), y(i), num2str(i))
      % end

      % Title for current time.
      title(['Spin, t = ', num2str(t(n)), 'ms'])

      % Gradient profile.
      subplot(2, 2, [2, 4])
      title('g(t)')
      plot(t, G{voxel_xy}(b_index, :), 'k-')
      hold on
      plot(t(n), G{voxel_xy}(b_index, n), 'kx')

      % Velocity.
      subplot(2, 2, 3)
      title('Molecule locations')
      for i = 1:points_per_voxel
        plot(squeeze(x_t{voxel_xy}(b_index, 1, i, :)), squeeze(x_t{voxel_xy}(b_index, 2, i, :)), '-', 'Color', colors(i, :))
        hold on
        plot(squeeze(x_t{voxel_xy}(b_index, 1, i, n)), squeeze(x_t{voxel_xy}(b_index, 2, i, n)), 'x', 'Color', colors(i, :))
      end

      % Adds current frame to movie.
      % drawnow
      % movie_frames(n) = getframe(fig);

      print(fig, '-dpng', strcat('../', 'images/subplots/', filename_no_ext, '_phase_', num2str(voxel_xy), '_', num2str(n), '.png'))
      close(fig)
      pause(0.01)

      % Print.
      %fprintf('t = %.2f: %.2f + %.2f + %.2f + %.2f = %.2f\n', [t(n), phi{voxel_xy}(b_index, :, grad_direction, n), avg_phi])
    end

    movie_filename = strcat('../', 'images/', filename_no_ext, '_phase_', num2str(voxel_xy), '.avi');
    video = VideoWriter(movie_filename);
    open(video)

    for i = 1:length(t)
      %writeVideo(video, movie_frames(i));
      image = imread(strcat('../', 'images/subplots/', filename_no_ext, '_phase_', num2str(voxel_xy), '_', num2str(i), '.png'));
      writeVideo(video, image)
    end

    close(video)
  else
    % Average phase.
    avg_phi = -angle(sum(exp(-1i.*phi{voxel_xy}(b_index, :, grad_direction)), 2));

    % Radius and coordinates of each molecule's spin.
    r = 0.9*min((max(x_voxel(1, :) - min(x_voxel(1, :)))), (max(x_voxel(2, :) - min(x_voxel(2, :)))))/2;
    x = r*cos(phi{voxel_xy}(b_index, :, grad_direction)) + centre_of_voxel(1);
    y = r*sin(phi{voxel_xy}(b_index, :, grad_direction)) + centre_of_voxel(2);

    % Radius and coordinates of average spins.
    r_avg = 0.9*abs(sum(exp(-1i.*phi{voxel_xy}(b_index, :, grad_direction)), 2))/(2*r_0);
    x_avg = r_avg*cos(avg_phi) + centre_of_voxel(1);
    y_avg = r_avg*sin(avg_phi) + centre_of_voxel(2);

    % Draws arrows from centre to each molecule's spin.
    arrows = [x - centre_of_voxel(1); y - centre_of_voxel(2)];
    arrows_mag = 2*sqrt(arrows(1, :).^2 + arrows(2, :).^2)/0.9;

    fig = figure();

    % Plots the phase.
    subplot(2, 2, 1)
    % circle(centre_of_voxel(1), centre_of_voxel(2), r, 'k-');
    circle(0.5, 0.5, 0.5, 'k-');
    hold on
    for i = 1:1%points_per_voxel
      plot(x(i), y(i), 'o', 'Color', color(:))
      quiver(0.5, 0.5, arrows(1, i)./arrows_mag(i), arrows(2, i)./arrows_mag(i), 0, 'filled', 'Color', color(:))
    end
    plot(x_avg, y_avg, 'ko')
    pbaspect([1 1 1])

    % Annotates the molecule number.
    % for i = 1:points_per_voxel
    %   text(x(i), y(i), num2str(i))
    % end

    % Title for end time.
    title(['Spin, t = ', num2str(t(end)), 'ms'])

    % Gradient profile.
    subplot(2, 2, [2, 4])
    title('g(t)')
    plot(t, G{voxel_xy}(b_index, :), 'k-')
    hold on
    plot(t(end), G{voxel_xy}(b_index, end), 'kx')

    % Velocity.
    subplot(2, 2, 3)
    title('Molecule locations')
    for i = 1:1%points_per_voxel
      plot(squeeze(x_t{voxel_xy}(b_index, 1, i)), squeeze(x_t{voxel_xy}(b_index, 2, i)), '-', 'Color', color(:))
    end

    % Adds current frame to movie.
    % drawnow
    % movie_frames(n) = getframe(fig);

    print(fig, '-dpng', strcat('../', 'images/', filename_no_ext, '_phase_', num2str(voxel_xy), '_', 'end', '.png'))
    close(fig)
    pause(0.01)
  end

end

fprintf("Plotted particle spins.\n")