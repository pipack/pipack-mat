function crossMarker(z, box_width, box_height, line_width, face_color, edge_color)
%CROSSMARKER plots a solid circle marker with a cross in the middle
% == Parameters ========================================================================================================
% z             (vector) - array of complex-valued nodes
% box_width     (real)   - width of box for forming cross
% box_height    (real)   - height of box for forming cross
% line_width    (real)   - LineWidth for shape border
% face_color    (vector) - 3x1 RGB vector
% edge_color    (vector) - 3x1 RGB vector
% == Returns ===========================================================================================================
% ======================================================================================================================

for i = 1 : length(z)
    vert_box_x = (box_width / 2)  * [1 1 -1 -1];
    vert_box_y = (box_height / 2) * [1 -1 -1 1];
    patch(vert_box_x + real(z(i)), vert_box_y + imag(z(i)), face_color, 'EdgeColor', edge_color, 'LineWidth', line_width);
    
    horz_box_x = (box_height / 2) * [1 -1 -1 1];
    horz_box_y = (box_width / 2)  * [1 1 -1 -1];
    patch(horz_box_x + real(z(i)), horz_box_y + imag(z(i)), face_color, 'EdgeColor', edge_color, 'LineWidth', line_width);
end
end