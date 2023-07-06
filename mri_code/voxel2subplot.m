function [position] = voxel2subplot(k, N_boxes, N_boxes_x, N_boxes_y)
  %UNTITLED2 Summary of this function goes here
  %   Detailed explanation goes here

  % Indices for helping label each voxel.
  i = mod(k-1, N_boxes_x);
  j = idivide(uint16(k-1), uint16(N_boxes_x));

  % Position in subplot.
  position = single(N_boxes - (j+1)*N_boxes_x + 1 + i);
end

