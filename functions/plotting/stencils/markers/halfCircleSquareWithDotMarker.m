function halfCircleSquareWithDotMarker(z, r, line_width, face_color, edge_color)
%HALFCIRCLESQUAREWITHDOTMARKER plots half a circle and half a square joined together with a dot in the center.
% == Parameters ========================================================================================================
% z             (vector) - array of complex-valued nodes
% r             (real)   - radius of circle
% line_width    (real)   - LineWidth for shape border
% face_color    (vector) - 3x1 RGB vector
% edge_color    (vector) - 3x1 RGB vector
% == Returns ===========================================================================================================
% ======================================================================================================================

w = 3; % ratio between outer and inner circle
halfCircleSquareMarker(z, r, line_width, face_color, face_color)
circleMarker(z, r / w, line_width, edge_color, edge_color)
end