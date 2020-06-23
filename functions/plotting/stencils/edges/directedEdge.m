function directedEdge(start_z, end_z, lineColor, lineWidth)
%DIRECTEDEDGE draws a directed edge from start to end point. Arrow is located slighly right of the midpoint
% == PARAMETERS ========================================================================================================
% start_z   (vector) - complex starting points
% end_z     (vector) - complex ending points
    
for i = 1 : length(start_z)
    s = start_z(i);
    e = end_z(i);    
    plot(real([s e]), imag([s e]), 'Color', lineColor, 'LineWidth', lineWidth);
    
    r = lineWidth / 5;                               %length of arrow
    origin = (.45 * s + .55 * e);                    % center of arrow
    theta  = ArcTan(imag(e - s), real(e - s));       % edge angle
    upper_tip = r * exp(1i*(3*pi/4 + theta)) + origin;   
    lower_tip = r * exp(1i*(-3*pi/4 + theta)) + origin;    
    plot(real([origin upper_tip]), imag([origin upper_tip]), 'Color', lineColor, 'LineWidth', lineWidth);
    plot(real([origin lower_tip]), imag([origin lower_tip]), 'Color', lineColor, 'LineWidth', lineWidth);    
end
end

function theta = ArcTan(delta_y, delta_x)
    theta = atan(delta_y / delta_x);
    if(delta_x < 0)
        theta = theta + pi;
    end
end