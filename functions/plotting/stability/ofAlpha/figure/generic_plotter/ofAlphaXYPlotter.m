function [figure_handle] = ofAlphaXYPlotter(data_raw, alphas, options)
%ATSvsALPHAPlotter helper function for plotting XY plot where alpha is on X_axis
% == Parameters ========================================================================================================
%   1. data_raw (matrix) - array containing data to plot. Must be of dimension length(alphas) x n. Each column contains
%                          data for a different method.
%   2. alphas   (vector) - range of alpha values to test
%   3. options  (struct) - struct full of options
%       YLabel          - y axis label
%       LineMarker      - linemaker, or cell array of line markers for each data column
%       MarkerSize      - markersize, or cell array of markersizes for each data column
%       Color           - [0 0 0]
%       LineWidth       - line width, or ell array of linewidths for each data column
%       LabelAxis       - if true axes will be labeled.
%       YAxis           - either 'natural', 'tight', or 2x1 vector with bounds.
%       FigureIndex     - index of figure. if empty then new figure will be generated.
%       FontSize        - font size of labels
%       FontName        - font type of labels
%
% == Returns ===========================================================================================================

if(nargin == 2)
    options = struct();
end
default_field_value_pairs = {
    {'XLabel',      '\alpha - Extrapolation Parameter'}
    {'YLabel',      ''}
    {'LineMarker',  '.'}
    {'MarkerSize',  5}
    {'Color',       [0 0 0]}
    {'LineWidth',   1}
    {'LabelAxis',   true}
    {'PadAxisLabel',false}
    {'YAxis',       [0 1]}
    {'YTicks',      'auto'}
    {'XAxis',       [0 1]}
    {'XTicks',      'auto'}
    {'FigureIndex', []}
    {'FontSize',    12}
    {'FontName',    getDefaultFont()}
    {'ClearFigure', false}
};
options = setDefaultOptions(options, default_field_value_pairs);

% -- Set Figure Index --------------------------------------------------------------------------------------------------
if(isempty(options.FigureIndex))
    figure_handle = figure();
else
    figure_handle = figure(options.FigureIndex);
    if(options.ClearFigure)
        clf;
    end    
end
hold on;

% -- Test Stability Values ---------------------------------------------------------------------------------------------
    function val = getField(options, field, index)
        if(iscell(options.(field)))
            val = options.(field){index};
        else
            val = options.(field);
        end
    end

for i = 1 : size(data_raw, 2)
    line_width = getField(options, 'LineWidth', i);
    line_color = getField(options, 'Color', i);
    line_marker = getField(options, 'LineMarker', i);
    line_marker_size = getField(options, 'MarkerSize', i);
    plot(alphas, data_raw(:, i), line_marker, 'Color', line_color, 'LineWidth', line_width, 'MarkerSize', line_marker_size);
end

% -- Label Axis --------------------------------------------------------------------------------------------------------
if(options.LabelAxis)
    if(options.PadAxisLabel)
        xlabel({'', options.XLabel});
        ylabel({options.YLabel,''});
    else
        xlabel(options.XLabel);
        ylabel(options.YLabel);
    end 
end
% -- Set Axis Range ----------------------------------------------------------------------------------------------------
if(ischar(options.YAxis))
     switch options.YAxis
         case 'tight'
            xl = xlim();
            axis tight;
            xlim(xl);
         otherwise
            ylim(options.YAxis)
     end
else
    ylim(options.YAxis);
end
     

if(ischar(options.XAxis))
     switch options.XAxis
         case 'tight'
            yl = ylim();
            axis tight;
            ylim(yl);
         otherwise
            xlim(options.XAxis)
     end
else
    xlim(options.XAxis);
end
         
xticks(options.XTicks);
yticks(options.YTicks);

% -- Set Fontsize and Name ---------------------------------------------------------------------------------------------
set(gca,'FontSize', options.FontSize, 'FontName', options.FontName)

end