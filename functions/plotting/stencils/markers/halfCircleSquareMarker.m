function halfCircleSquareMarker(z, r, line_width, face_color, edge_color)
%HALFCIRCLESQUAREMARKER plots half a circle and half a square joined together.
% == Parameters ========================================================================================================
% z             (vector) - array of complex-valued nodes
% r             (real)   - radius of circle and height of square
% line_width    (real)   - LineWidth for shape border
% face_color    (vector) - 3x1 RGB vector
% edge_color    (vector) - 3x1 RGB vector
% == Returns ===========================================================================================================
% ======================================================================================================================

thetas  = linspace(-pi/2, pi/2, 100);
for i = 1 : length(z)
    xc = r * [cos(thetas), [0 -1 -1 0]] + real(z(i));
    yc = r * [sin(thetas), [1 1 -1 -1]] + imag(z(i));
    patch(xc, yc, face_color, 'EdgeColor', edge_color, 'LineWidth', line_width);
end
end