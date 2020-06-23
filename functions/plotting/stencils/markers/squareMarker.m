function squareMarker(z, r, line_width, face_color, edge_color)
%SQUAREMARKER plots a solid square marker
% == Parameters ========================================================================================================
% z             (vector) - array of complex-valued nodes
% r             (real)   - width of square
% line_width    (real)   - LineWidth for shape border
% face_color    (vector) - 3x1 RGB vector
% edge_color    (vector) - 3x1 RGB vector
% == Returns ===========================================================================================================
% ======================================================================================================================

for i = 1 : length(z)
    xc = r * [1 -1 -1 1] + real(z(i));
    yc = r * [1 1 -1 -1] + imag(z(i));
    patch(xc, yc, face_color, 'EdgeColor', edge_color, 'LineWidth', line_width);
end
end