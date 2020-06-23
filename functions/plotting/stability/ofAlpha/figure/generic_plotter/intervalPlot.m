function intervalPlot(x, y, flag, options)
%INTERVALPLOT Summary of this function goes here
%   Detailed explanation goes here

default_field_value_pairs = {{'LineWidth', 15} {'Color', [0 0 0]}};
if(nargin <= 3)
    options = struct();
end
options = setDefaultOptions(options, default_field_value_pairs);


if(isvector(flag))
    flag = flag(:);
end

num_x = length(x);
num_y = length(y);
if(~all(size(flag) == [num_y, num_x]))
    error('invalid data, size(flag) must return [length(y) length(x)].');
end
box on;
for i = 1 : length(x)
    intervals = getTrueIntervalIndices(flag);
    plotNonNanIntervals(intervals, y, x(i), options.Color, options.LineWidth);
end
end

function intervals = getTrueIntervalIndices(flag_column)
    intervals = {};
    interval_start = 0;
    interval_open  = false;
    num_flags = length(flag_column);
    
    for i = 1 : num_flags
        flag = flag_column(i);
        if(interval_open && ~flag)
            intervals{end+1} = [interval_start i];
            interval_open    = false;
        elseif(~interval_open && flag)
            interval_start = i;
            interval_open  = true;
        elseif(interval_open && i == num_flags) % add open interval if array ends
            intervals{end+1} = [interval_start i];
            interval_open    = false;
        end
    end
end

function plotNonNanIntervals(intervals, y, x0, color, width)
    for i = 1 : length(intervals)
        yi = double(y(intervals{i})); % cast to double for symbolic data
        xc = double([x0 - width/2, x0 - width/2, x0 + width/2, x0 + width/2]); 
        yc = [yi(1) yi(2) yi(2) yi(1)];
        patch(xc, yc, color, 'EdgeColor', color);
    end
end