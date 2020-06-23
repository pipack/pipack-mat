function squareWithCrossMarker(z, r, line_width, face_color, edge_color)
%SQUAREWITHCROSSMARKER plots a solid square marker with a cross in the middle
% == Parameters ========================================================================================================
% z             (vector) - array of complex-valued nodes
% r             (real)   - width of square
% line_width    (real)   - LineWidth for shape border
% face_color    (vector) - 3x1 RGB vector
% edge_color    (vector) - 3x1 RGB vector
% == Returns ===========================================================================================================
% ======================================================================================================================

w           = 10; % ratio between linewidth and radius of circle
box_width  = r / 8;
box_height = 2 * r * cos( atan( 1 / (2 * w))) * .75;
% -- plot circles ------------------------------------------------------------------------------------------------------
squareMarker(z, r, line_width, face_color, face_color)
crossMarker(z, box_width, box_height, line_width, edge_color, edge_color);
end