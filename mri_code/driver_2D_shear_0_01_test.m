% Clean workspace.
clearvars -except total_tic
%clf

% Filename of solution file.
filename_no_ext = '2D_shear_0_01_test';

% Dimension of problem.
dim = 2;

% Number of voxels in each direction.
N_voxels_x = 1;
N_voxels_y = 1;
N_voxels_z = 1; % Set to 1 for 2D.

% Number of points in each direction.
N_points_x = N_voxels_x*20;
N_points_y = N_voxels_y*20;
N_points_z = N_voxels_z*1; % Set to 1 in 2D.

% Number of time steps.
no_t_steps = 531; % Number required dt=0.1 in [0, 53].

% Domain size.
x_min = 0;
x_max = 1;
y_min = 0;
y_max = 1;
z_min = 0;
z_max = 0;

% b-values.
b = linspace(0, 500, 5001);

% Domain scaling (1 if problem solved in dimensional units).
L = 1;

% Velocity scaling (1 if problem solved in dimensional units).
U = 1;

% Create "interpolants".
v_interpolant    = cell(dim, 1);
v_interpolant{1} = @(x, y) zeros(size(x, 1), size(x, 2));
v_interpolant{2} = @(x, y) 0.01*(2*(x<0.5).*ones(size(x, 1), size(x, 2)) - ones(size(x, 1), size(x, 2)));

% Setup useful variables from options set above.
setup_quantities

% Evaluate velocity at sample points.
tic
v_sample = importdata_manufactured(dim, x_sample, L, U, v_interpolant);
toc

% Run main program, then plot.
tic
main
toc

% Plot quiver.
tic
plot_quiver
toc

% Plot S-vs-b.
tic
plot_s_vs_b
toc

% Plot S.
tic
plot_s
toc

% Plot phase.
tic
% plot_particle_spins
toc