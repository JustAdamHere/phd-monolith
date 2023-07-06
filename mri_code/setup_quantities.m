% Output filename.
fprintf('\n  Starting %s\n', filename_no_ext)

% Number of dimensions.
assert((dim == 2) || (dim == 3));

% Problem parameters.
D     = 0;
gamma = 42.57*2*pi*1e6;
delta = 15.9*1e-3;
Delta = 30.9*1e-3;

% Points in entire simulation, per axis.
N_points = N_points_x*N_points_y*N_points_z;

% Number of voxels, per axis.
N_voxels = N_voxels_x*N_voxels_y*N_voxels_z;

% Error checking.
assert(mod(N_points_x, N_voxels_x) == 0)
assert(mod(N_points_y, N_voxels_y) == 0)
assert(mod(N_points_z, N_voxels_z) == 0)

% Domain size.
x_range = x_max - x_min;
y_range = y_max - y_min;
z_range = z_max - z_min;

fprintf("  Voxel size is %d x %d x %d mm^3\n", L*x_range/N_voxels_x*1000, L*y_range/N_voxels_y*1000, L*z_range/N_voxels_z*1000)

% Number of particles in each voxel.
points_per_voxel_x = floor(N_points_x/N_voxels_x);
points_per_voxel_y = floor(N_points_y/N_voxels_y);
points_per_voxel_z = floor(N_points_z/N_voxels_z);
points_per_voxel   = points_per_voxel_x*points_per_voxel_y*points_per_voxel_z;

% Water molecule locations.
x_sample = cell(dim, 1);
if (dim == 2)
  [x_sample{1}, x_sample{2}]  = meshgrid(linspace(L*x_min, L*x_max, N_points_x),  linspace(L*y_min, L*y_max, N_points_y));
elseif (dim == 3)
  [x_sample{1}, x_sample{2}, x_sample{3}]  = meshgrid(linspace(L*x_min, L*x_max, N_points_x),  linspace(L*y_min, L*y_max, N_points_y), linspace(L*z_min, L*z_max, N_points_z));
end