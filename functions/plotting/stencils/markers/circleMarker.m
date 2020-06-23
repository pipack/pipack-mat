function CircleMarker(z, r, line_width, face_color, edge_color)
%CIRCLEMARKER plots a solid circle marker
% == Parameters ========================================================================================================
% z             (vector) - array of complex-valued nodes
% r             (real)   - radius of marker
% line_width    (real)   - LineWidth for shape border
% face_color    (vector) - 3x1 RGB vector
% edge_color    (vector) - 3x1 RGB vector
% == Returns ===========================================================================================================
% ======================================================================================================================

thetas  = linspace(0, 2*pi, 100);
for i = 1 : length(z)
    xc = r * cos(thetas) + real(z(i));
    yc = r * sin(thetas) + imag(z(i));
    patch(xc, yc, face_color, 'EdgeColor', edge_color, 'LineWidth', line_width);
end
end