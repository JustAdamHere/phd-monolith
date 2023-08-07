% Clean workspace.
clearvars -except total_tic
clf

% Filename of solution file.
%filename_no_ext = '2D_placenta';
filename_no_ext = 'dg_velocity_placenta';

% Aptofem run number (if from FEM solution).
aptofem_run_no = 1;

% Recompute velocity sample (if from FEM solution).
recompute_v_sample = true;

% Dimension of problem.
dim = 2;

% Number of points in each direction.
N_points_x = 91*20;
N_points_y = 19*20;
N_points_z = 1; % Set to 1 in 2D.

% Number of voxels in each direction.
N_voxels_x = 91;
N_voxels_y = 19;
N_voxels_z = 1; % Set to 1 for 2D.

% Number of time steps.
no_t_steps = 531; % Number required dt=0.1 in [0, 53].

% Domain size.
x_min = -0.075 - 0.01875;
x_max =  5.575 + 0.01875;
y_min = -0.25  - 0.0155;
y_max = 0.9065 + 0.0155;
z_min = 0;
z_max = 0;

% b-values.
b = [0 1 3 9 18 32 54 88 110 147 180 200 230 270 300 350 400 450 500];

% Domain scaling (1 if problem solved in dimensional units).
L = 0.04;

% Velocity scaling (1 if problem solved in dimensional units).
U = 0.4;

% Setup useful variables from options set above.
setup_quantities

% Import FE solution data.
tic
v_sample = importdata_fem(dim, x_sample, filename_no_ext, aptofem_run_no, L, U, recompute_v_sample, 'placenta');
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