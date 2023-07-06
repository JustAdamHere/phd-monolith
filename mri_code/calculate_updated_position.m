function [x, dudt] = calculate_updated_position(dim, x, u, dt)
%CALCULATE_UPDATED_POSITION Calculates updated position.
%   Uses the velocity interpolant to calculate the updated position.
%   Inputs:
%       dim: dimension of the problem
%       x:   position
%       u:   velocity
%       dt:  time step

%     if (dim == 2)
%         x = x + [u{1}; u{2}].*dt;
%     elseif (dim == 3)
%         x = x + [u{1}; u{2}; u{3}].*dt;
%     end
    dudt = u.*dt;
    x = x + dudt;
end