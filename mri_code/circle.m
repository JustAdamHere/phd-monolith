function h = circle(x, y, r, linestyle)
% Taken from:
%  https://uk.mathworks.com/matlabcentral/answers/98665-how-do-i-plot-a-circle-with-a-given-radius-and-center#answer_108013
    hold on
    th = 0:pi/50:2*pi;
    xunit = r * cos(th) + x;
    yunit = r * sin(th) + y;
    h = plot(xunit, yunit, linestyle);
    hold off
end