function squareWithDotMarker(z, r, line_width, face_color, edge_color)
%SQUAREMARKER plots a solid square marker with a dot in the middle
% == Parameters ========================================================================================================
% z             (vector) - array of complex-valued nodes
% r             (real)   - diagonal length of square. sides will be 1 / sqrt(2) * r
% line_width    (real)   - LineWidth for shape border
% face_color    (vector) - 3x1 RGB vector
% edge_color    (vector) - 3x1 RGB vector
% == Returns ===========================================================================================================
% ======================================================================================================================

w = 3; % ratio between outer and inner circle
squareMarker(z, r, line_width, face_color, face_color)
circleMarker(z, r / w, line_width, edge_color, edge_color)
end