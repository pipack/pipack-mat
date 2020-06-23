function halfCircleSquareWithCrossMarker(z, r, line_width, face_color, edge_color)
%HALFCIRCLESQUAREMARKER plots half a circle and half a square joined together with a cross in the center.
% == Parameters ========================================================================================================
% z             (vector) - array of complex-valued nodes
% r             (real)   - radius of circle and height of square
% line_width    (real)   - LineWidth for shape border
% face_color    (vector) - 3x1 RGB vector
% edge_color    (vector) - 3x1 RGB vector
% == Returns ===========================================================================================================
% ======================================================================================================================

w          = 10; % ratio between linewidth and radius of circle
box_width  = r / 8;
box_height = 2 * r * cos( atan( 1 / (2 * w))) * .75;
% -- plot circles ------------------------------------------------------------------------------------------------------
halfCircleSquareMarker(z, r, line_width, face_color, face_color)
crossMarker(z, box_width, box_height, line_width, edge_color, edge_color);
end