function [i, j, k, i1, j1, k1, i2, j2, k2] = voxel2indices(voxel, points_per_voxel_x, points_per_voxel_y, points_per_voxel_z, N_voxels_x, N_voxels_y)
  %UNTITLED2 Summary of this function goes here
  %   Detailed explanation goes here

  % Indices for helping label each voxel.
  i1 = mod(voxel-1, N_voxels_x);
  j1 = mod(idivide(int16(voxel-1), int16(N_voxels_x)), N_voxels_y);
  k1 = idivide(int16(voxel-1), int16(N_voxels_x*N_voxels_y));
  i2 = i1 + 1;
  j2 = j1 + 1;
  k2 = k1 + 1;

  % Range of indices of molecules in this voxel.
  i = (i1*points_per_voxel_x+1):i2*points_per_voxel_x;
  j = (j1*points_per_voxel_y+1):j2*points_per_voxel_y;
  k = (k1*points_per_voxel_z+1):k2*points_per_voxel_z;
end

