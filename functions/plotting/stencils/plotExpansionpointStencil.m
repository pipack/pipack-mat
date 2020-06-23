function [borders] = plotExpansionpointStencil(b, ep_index, ODE_DS, options)
%PLOTEXPANSIONPOINTSTENCIL helper function for plotting expansion point stencil
% = Parameters =========================================================================================================
%   1. b          (function_handle or cell{function_handle})  - function handle @(alpha) or cell array of function
%                                                               handles returning the expansion point as a function of 
%                                                               the extrapolation factor alpha.
%   2. ep_index    (vector) - expanions point index. Cooresponding index of ODE polynomal evaluation point relative to
%                             the ODE_DS.nodevector() comprising of [inputs, outputs]. This information is used to draw
%                             edges for integration paths.
%   2. ODE_DS          (ODE_Dataset) - underlying ODE dataset.
% = Returns ============================================================================================================
%   1. borders         (vector) - 4x1 vector containg coordinates of the borders of stencil in the ordering
%                                               [left_border, right_border bottom_border top_boder]
% ======================================================================================================================

if(nargin <= 3)
    options = struct();
end
options = ApplyStencilProfileSettings(double(ODE_DS.z_in), options);
options = DefaultOptions(options);

% -- set origin --------------------------------------------------------------------------------------------------------
if(~isempty(options.LeftLabel)) % additional padding for left label
    x_origin = options.LeftBound + (options.LeftWidth + options.Padding(4) + options.LabelPadding(4));
else
    x_origin = options.LeftBound + (options.LeftWidth + options.Padding(4));
end
options.origin = [x_origin 0];
% ----------------------------------------------------------------------------------------------------------------------

hold on;
if(options.DrawAxis)
    plot(options.origin(1) + [-options.LeftWidth options.RightWidth], [0 0], 'Color', options.AxisColor); 
    plot(options.origin(1)*[1 1], options.origin(2) + options.height * [-1/2, 1/2], 'Color', options.AxisColor);
end

if(~isempty(options.LowerLabel))
    text(options.origin(1), -options.LabelSeparation + options.origin(2) - options.height/2, options.LowerLabel, 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'top', 'Color', options.LowerLabelColor, 'FontSize', options.FontSize, 'FontName', options.FontName);
end

if(~isempty(options.LeftLabel))
    text(options.origin(1) - options.LeftWidth -options.LabelSeparation,  options.origin(2), options.LeftLabel, 'HorizontalAlignment', 'Right', 'VerticalAlignment', 'middle', 'Color', options.LowerLabelColor, 'FontSize', options.FontSize, 'FontName', options.FontName);
end

if(options.LabelAxis)
    text(options.LabelSeparation + (options.origin(1) + options.RightWidth), options.origin(2),'Re(z)', 'HorizontalAlignment', 'Left', 'Color', options.AxisColor, 'FontSize', options.FontSize); hold on;
    text(options.origin(1), options.LabelSeparation + (options.origin(2) + options.height/2),' Im(z)', 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'bottom', 'Color', options.AxisColor, 'FontSize', options.FontSize);
end

% -- shift all nodes relative to graph origin --------------------------------------------------------------------------
offset          = options.origin(1) + 1i*options.origin(2);
z_in_offset     = double(ODE_DS.z_in  + offset);
z_out_offset    = double((ODE_DS.z_out + options.alpha) + offset);
z_stage_offset  = double(ODE_DS.c(options.alpha) + offset);

nodes_offset    = double(ODE_DS.nodeVector(options.alpha) + offset);
if(isa(b, 'function_handle'))
    b_offset = double(b(options.alpha) + offset);
elseif(iscell(b))
    b_offset = double(cellfun(@(bh) bh(options.alpha), b) + offset);
end



if(options.DrawAllInputsOutputsAndStages) % -- background input and output nodes ---------------------------------------------
    marker_r  = options.MarkerSize / 200;
    marker_lw = options.MarkerSize / 16;    
    circleMarker(z_in_offset, marker_r, marker_lw, options.BackgroundNodeColor, options.BackgroundNodeColor);
    circleMarker(z_out_offset, marker_r, marker_lw, options.BackgroundNodeColor, options.BackgroundNodeColor);
    circleWithDotMarker(z_stage_offset, marker_r, marker_lw, options.BackgroundNodeColor, options.BackgroundNodeColor);
end

% -- set marker size ---------------------------------------------------------------------------------------------------
marker_r  = options.MarkerSize / 300;
marker_lw = options.MarkerSize / 32;
if(options.DrawIntegrationPaths && ~isempty(ep_index))
    directedEdge(b_offset, nodes_offset(ep_index), options.EdgeColor, marker_lw);
end
circleMarker(b_offset, marker_r, marker_lw, options.ExpansionpointColor, options.ExpansionpointColor);

% == Compute Figure Boundaries =========================================================================================
x_axis_lim = options.origin(1) + [-options.LeftWidth, options.RightWidth] + [-options.Padding(4) options.Padding(2)];
if(options.LabelAxis) % additional padding for axis label
    x_axis_lim = x_axis_lim + [0 options.LabelPadding(2)];
end
if(~isempty(options.LeftLabel)) % additional padding for left label
    x_axis_lim = x_axis_lim + [-options.LabelPadding(4) 0];
end

y_axis_lim = options.origin(2) + options.height*[-1/2 1/2] + [-options.Padding(3) options.Padding(1)];
if(options.LabelAxis) % additional padding for axis label
    y_axis_lim = y_axis_lim + [0 options.LabelPadding(1)];
end
if(~isempty(options.LowerLabel)) % additional padding for lower label
    y_axis_lim = y_axis_lim + [-options.LabelPadding(3) 0];
end

axis equal;
xlim(x_axis_lim);
ylim(y_axis_lim);

borders = [x_axis_lim y_axis_lim];

end


% == Options ===========================================================================================================

function options = DefaultOptions(options)

black = [.1 .1 .1];
grey  = [.8 .8 .8];
white = [1  1  1];
blue  = [63 169 245] / 255;

default_field_value_pairs = { ...
    {'DrawAllInputsOutputsAndStages', true}
    {'DrawIntegrationPaths', false}
    {'BackgroundNodeColor', grey}
    {'ExpansionpointColor', blue}
    {'MarkerSize', 10}
    {'EdgeLineWidth', 2}
    {'InputLabelColor', .99*white} % problems exporting pure white
    {'OutputLabelColor', black}    
    {'EdgeColor', black}
    {'LeftBound', 0}
    {'LeftWidth', 1/3}
    {'RightWidth', 1}
    {'alpha', 2/3}
    {'height', 8/3}
    {'DrawAxis', true}
    {'LabelAxis', false}
    {'AxisColor', [.8 .8 .8]}
    {'LowerLabel', []}
    {'LeftLabel', []}
    {'LowerLabelColor', [.1 .1 .1]}
    {'LabelSeparation', .1}; % how far labels are pushed from axis
    {'Padding', [1/6 1/6 1/6 1/6]}; % how much padding is added around axis (Top, Right, Bottom, Left)
    {'LabelPadding', [1/3 7/12 1/3 7/12]}; % how much padding is added around axis (Top, Right, Bottom, Left)
    {'FontSize', 12}
    {'FontName', 'Minion Pro'}
    };

options = setDefaultOptions(options, default_field_value_pairs);

end