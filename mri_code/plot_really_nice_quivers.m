%% This script requires the vtkToolbox!!
%   https://uk.mathworks.com/matlabcentral/fileexchange/94993-vtktoolbox

%% Amend the following to change the type of plot you get.
% The velocity in each voxel can be calculated using either the mean of all
% velocities in that voxel, or by taking (roughly) the central point in
% that voxel.
velocity_calculation = "mean"; % or "centre";

% Whether interesting voxels should be coloured.
colour_voxels = true; % or false;
coloured_voxels = [...
    672, ... % Rotational.
    491, ... % Decellerating.
    1726 ... % Shear.
];
voxel_colours = ["#005992", "#db6000", "#008002", "#b30002", "#74499c", "#6c382e", "#c058a0", "#606060"];

% Whether voxels should be displayed.
show_voxels = true; % or false;

% Whether the placenta outline should be displayed.
show_placenta_outline = true; % or false;

% Velocity magnitudes below this will be set to 0.
R_min = 1e-5; % or any float.

% Decide how the arrows should be scaled.
arrow_scaling = "log"; % or "linear", or "none";

% Image resolution scaling.
image_scaling_resolution = 2000;%500;

%% Setup.
fprintf("Plotting... ")

filename_no_ext = 'dg_velocity-transport';

%load(strcat('../output/mri-quantities_', filename_no_ext, '.mat'))

x = zeros(N_voxels_x, N_voxels_y);
y = zeros(N_voxels_x, N_voxels_y);
u = zeros(N_voxels_x, N_voxels_y);
v = zeros(N_voxels_x, N_voxels_y);

fig = figure(1);
clf
fig.Units = 'pixels';
fig.InnerPosition = [0 0 image_scaling_resolution*x_range image_scaling_resolution*y_range];

% "Hack" that gives us the z indices in this z-slice.
[~, ~, k] = voxel2indices(N_voxels_x*N_voxels_y, points_per_voxel_x, points_per_voxel_y, 1, N_voxels_x, N_voxels_y);

%% Plot outline.
if (show_placenta_outline)
    outline_vtk = readVTK('..\meshes\outline-mesh_1.vtk');
    outline_cells  = outline_vtk.cells;
    outline_points = outline_vtk.points*L;

    hold on
    for i = 1:length(outline_cells)
        plot([outline_points(outline_cells(i, 1), 1) outline_points(outline_cells(i, 2), 1)], [outline_points(outline_cells(i, 1), 2) outline_points(outline_cells(i, 2), 2)], 'k-', 'LineWidth', 2)
    end
end

%% Plot voxels.
coloured_voxel_count = 0;
if (show_voxels)
    dx = x_sample{1}(1, 2, 1) - x_sample{1}(1, 1, 1);
    dy = x_sample{2}(2, 1, 1) - x_sample{2}(1, 1, 1);
    for voxel_xy = 1:N_voxels_x*N_voxels_y
        [i, j, ~, i1, j1, ~, i2, j2, ~] = voxel2indices(voxel_xy, points_per_voxel_x, points_per_voxel_y, points_per_voxel_z, N_voxels_x, N_voxels_y);

        % Coordinates inside this voxel.
        x_voxel = x_sample{1}(1, i, 1);
        y_voxel = x_sample{2}(j, 1, 1);

        x_lower = x_voxel(1)   - dx/2;
        x_upper = x_voxel(end) + dx/2;
        y_lower = y_voxel(1)   - dy/2;
        y_upper = y_voxel(end) + dy/2;

        if ismember(voxel_xy, coloured_voxels)
            coloured_voxel_count = coloured_voxel_count + 1;
            rectangle('Position', [x_lower y_lower (x_upper-x_lower) (y_upper-y_lower)], 'EdgeColor', [0.2 0.2 0.2], 'FaceColor', voxel_colours(coloured_voxel_count))
        else
            rectangle('Position', [x_lower y_lower (x_upper-x_lower) (y_upper-y_lower)], 'EdgeColor', [0.2 0.2 0.2])
        end
    end
end

%% Construct velocity in each voxel.
% Loop over x-y voxels.
for voxel_xy = 1:N_voxels_x*N_voxels_y
    [i, j, ~, i1, j1, ~, i2, j2, ~] = voxel2indices(voxel_xy, points_per_voxel_x, points_per_voxel_y, points_per_voxel_z, N_voxels_x, N_voxels_y);

    colour = [0 0.4470 0.7410];

    % Get all positions and velocities in voxel.
    x_temp = x_sample{1}(j, i, k);
    y_temp = x_sample{2}(j, i, k);
    u_temp = v_sample{1}(j, i, k);
    v_temp = v_sample{2}(j, i, k);

    % Calculate velocity magnitude.
    R = hypot(u_temp, v_temp);

    % Cut-off to zero any velocity magnitudes less than R_min m/s.
    u_temp(R < R_min) = 0;
    v_temp(R < R_min) = 0;
    R(R < R_min) = 0;

    % Normalised versions of velocity (excluding cut-offs below 1e-5 m/s).
    uNorm = u_temp./R;
    vNorm = v_temp./R;

    % Scaled versions of velocity.
    if (arrow_scaling == "log")
        uScaled = uNorm*log(R/R_min);
        vScaled = vNorm*log(R/R_min);
    elseif (arrow_scaling == "linear")
        uScaled = uNorm*R;
        vScaled = vNorm*R;
    elseif (arrow_scaling == "none")
        uScaled = uNorm;
        vScaled = vNorm;
    else
        error("Invalid arrow scaling.")
    end

    % Store arrow positions and directons.
    if (velocity_calculation == "mean")
        % Take mean across voxel to give arrow direction.
        x(i2, j2) = mean(x_temp,  "all");
        y(i2, j2) = mean(y_temp,  "all");
        u(i2, j2) = mean(uScaled, "all");
        v(i2, j2) = mean(vScaled, "all");
    elseif (velocity_calculation == "centre")
        % Take (roughly) the centre of voxel to give arrow direction.
        chosen_index = ceil(points_per_voxel_x*points_per_voxel_y/2 + points_per_voxel_x/2);
        x(i2, j2) = x_temp(chosen_index);
        y(i2, j2) = y_temp(chosen_index);
        u(i2, j2) = uScaled(chosen_index);
        v(i2, j2) = vScaled(chosen_index);
    else
        error("Invalid velocity calculation.")
    end
end

%% Plot quiver.
%title(sprintf("Quiver plot"))

%quiver(x, y, u, v, 2e-1, 'Color', [0 0 0], 'LineWidth', 0.5)
quiver(x, y, u, v, 2e-1, 'Color', [0 0 0], 'LineWidth', 1)

%velocity_magnitude = sqrt(u.^2 + v.^2);
%quiver(x, y, u, v, 2e-1, 'Color', [0 0 1])

xlim(L*[x_min, x_max])
ylim(L*[y_min, y_max])

daspect([1 1 1])

%% Style the plot.
set(gca, 'XTick', []);
set(gca, 'YTick', []);
set(gca, 'box',   'off');

%% Save figure.
output_filename = filename_no_ext + "_quiver";
if (velocity_calculation == "mean")
    output_filename = output_filename + "_mean";
elseif (velocity_calculation == "centre")
    output_filename = output_filename + "_centre";
end
if (show_voxels)
    output_filename = output_filename + "_voxels";
end
if (show_placenta_outline)
    output_filename = output_filename + "_outline";
end
output_filename = output_filename + "_Rmin" + num2str(R_min);
if (arrow_scaling == "log")
    output_filename = output_filename + "_log";
elseif (arrow_scaling == "linear")
    output_filename = output_filename + "_linear";
end

print(fig, '-dpng', strcat('../', 'images/', output_filename, '.png'))
pause(0.01)
close(fig)

fprintf("Plotted.\n")