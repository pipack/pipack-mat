function [borders] = plotPolynomialStencil(int_poly_AIS, b, ODE_DS, IVS, options)
%PLOTACTIVENODESTENCIL helper function for plotting an polynomial node stencil
% = Parameters =========================================================================================================
%   1. int_poly_AIS    (IPoly_AIS) - active index set for interpolating polynomial
%   2. b               (real) - expansion point
%   2. ODE_DS          (ODE_Dataset) - underlying ODE dataset.
%   3. IVS             (InterpolatedValueSet) - any interpolated value set associated with ODE_DS.
% = Returns ============================================================================================================
%   1. borders         (vector) - 4x1 vector containg coordinates of the borders of stencil in the ordering
%                                               [left_border, right_border bottom_border top_boder]
% ======================================================================================================================

if(nargin <= 3)
    options = struct();
end
options = ApplyStencilProfileSettings(ODE_DS.z_in, options);
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
z_out_offset    = double(ODE_DS.z_out + options.alpha + offset);
z_stage_offset  = double(ODE_DS.c(options.alpha) + offset);
b_offset        = double(b(options.alpha) + offset);
if(~isempty(IVS))
    z_interp_sol_offset = double(IVS.sol_tau(options.alpha) + offset);
    z_interp_der_offset = double(IVS.der_tau(options.alpha) + offset);
else
    z_interp_sol_offset = [];
    z_interp_der_offset = [];
end

if(options.ShowAllInputsOutputsAndStages) % -- background input and output nodes ---------------------------------------------
    marker_r  = options.MarkerSize / 200;
    marker_lw = options.MarkerSize / 16;    
    circleMarker(z_in_offset, marker_r, marker_lw, options.BackgroundNodeColor, options.BackgroundNodeColor);
    circleMarker(z_out_offset, marker_r, marker_lw, options.BackgroundNodeColor, options.BackgroundNodeColor);
    circleWithDotMarker(z_stage_offset, marker_r, marker_lw, options.BackgroundNodeColor, options.BackgroundNodeColor);
end

if(options.StencilEdges) % -- stencil edges ----------------------------------------------------------------------------
    node_cell = {
        z_in_offset(int_poly_AIS.AIISet())  
        z_stage_offset(int_poly_AIS.ASISet()) 
        z_out_offset(int_poly_AIS.AOISet()) 
        z_interp_sol_offset(int_poly_AIS.interp_sol_inds) 
        z_interp_der_offset(int_poly_AIS.interp_der_inds)
     };
    [X, Y] = stencilEdges(node_cell);
    plot(X,Y,'Color', options.EdgeColor, 'lineWidth', options.EdgeLineWidth);
end



% -- set marker size ---------------------------------------------------------------------------------------------------
marker_r  = options.MarkerSize / 100;
marker_lw = options.MarkerSize / 8;

    % -- helper functions ----------------------------------------------------------------------------------------------
    function plotNodeType(nodes, node_type, marker_handle_no_overlap_sol, marker_handle_no_overlap_der, marker_handle_overlap)
        %PLOTNEPNODES plot nodes that cannot be evaluation ponts (i.e. inputs, interpolated values)
        % = Parameters =================================================================================================
        % nodes         (vector) - nodes in local tau coordinates
        % node_type     (char)   - type of node (input, ouput, stage, interp)
        % marker_handle_overlap (handle) - function for plotting marker of nodes where only solution data is
        %                                         used. The handle must be of the form: 
        %                                               @(nodes, size, line_width, faceColor,EdgeColor)       
        % marker_handle_no_overlap_der (handle) - function for plotting marker of nodes where only derivative data is 
        %                                         used. The handle must be of the form: 
        %                                               @(nodes, size, line_width, faceColor,EdgeColor)
        % marker_handle_no_overlap_sol (handle) - function for plotting marker of nodes where only solution data is
        %                                         used. The handle must be of the form: 
        %                                               @(nodes, size, line_width, faceColor,EdgeColor)
        
        overlapping_sol_inds     = intersect(int_poly_AIS.([node_type, '_sol_inds']), int_poly_AIS.([node_type, '_der_inds']));
        non_overlapping_sol_inds = setdiff(int_poly_AIS.([node_type, '_sol_inds']), int_poly_AIS.([node_type, '_der_inds']));
        non_overlapping_der_inds = setdiff(int_poly_AIS.([node_type, '_der_inds']), int_poly_AIS.([node_type, '_sol_inds']));
        
        cfl = @(x) [upper(x(1)), x(2:end)]; %capitilize first letter
        marker_handle_overlap(nodes(overlapping_sol_inds),   marker_r, marker_lw, options.(['Active', cfl(node_type), 'FaceColor']),   options.(['Active', cfl(node_type), 'EdgeColor']));
        marker_handle_no_overlap_sol(nodes(non_overlapping_sol_inds),   marker_r, marker_lw, options.(['Active', cfl(node_type), 'FaceColor']),   options.(['Active', cfl(node_type), 'EdgeColor']));
        marker_handle_no_overlap_der(nodes(non_overlapping_der_inds),   marker_r, marker_lw, options.(['Active', cfl(node_type), 'FaceColor']),   options.(['Active', cfl(node_type), 'EdgeColor']));
    end

% -- treat IVP values separately ---------------------------------------------------------------------------------------
ivp_sol = z_interp_sol_offset(int_poly_AIS.interp_sol_inds);
ivp_der = z_interp_der_offset(int_poly_AIS.interp_der_inds);
ivp_only_sol = setdiff(ivp_sol, ivp_der);
ivp_only_der = setdiff(ivp_der, ivp_sol);
ivp_overlap  = intersect(ivp_sol, ivp_der);
squareWithCrossMarker(ivp_only_sol, marker_r, marker_lw, options.ActiveInterpFaceColor, options.ActiveInterpEdgeColor);
circleWithCrossMarker(ivp_only_der, marker_r, marker_lw, options.ActiveInterpFaceColor, options.ActiveInterpEdgeColor);
halfCircleSquareWithCrossMarker(ivp_overlap, marker_r, marker_lw, options.ActiveInterpFaceColor, options.ActiveInterpEdgeColor);
% -- plot remaining points ---------------------------------------------------------------------------------------------
plotNodeType(z_in_offset,    'input',  @squareMarker, @circleMarker, @halfCircleSquareMarker)
plotNodeType(z_out_offset,   'output', @squareMarker, @circleMarker, @halfCircleSquareMarker)
plotNodeType(z_stage_offset, 'stage',  @squareWithDotMarker, @circleWithDotMarker, @halfCircleSquareWithDotMarker)

if(~isempty(options.ShowExpansionpoint))
    circleMarker(b_offset, marker_r / 2, marker_lw, options.ExpansionpointColor, options.ExpansionpointColor)
end


% -- number inputs and outputs -----------------------------------------------------------------------------------------
if(options.show_numbering)
    input_indices  = union(int_poly_AIS.input_sol_inds, int_poly_AIS.input_der_inds);
    for i = 1 : length(input_indices)
        ind = input_indices(i);
        z_ind = z_in_offset(ind);
        text(real(z_ind), imag(z_ind), num2str(ind), 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Middle', 'Color', options.InputLabelColor, 'FontSize', options.FontSize, 'FontName', options.FontName);
    end
    
    output_indices =  union(int_poly_AIS.output_sol_inds, int_poly_AIS.output_der_inds);
    for i = 1 : length(output_indices)
        ind = output_indices(i);
        z_ind = z_out_offset(ind);
        text(real(z_ind), imag(z_ind), num2str(ind), 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'middle', 'Color', options.OutputLabelColor, 'FontSize', options.FontSize, 'FontName', options.FontName);
    end
end
hold off;

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
    {'ShowExpansionpoint', []}
    {'ShowAllInputsOutputsAndStages', true}
    {'StencilEdges', true}
    {'BackgroundNodeColor', grey}
    {'ExpansionpointColor', blue}
    {'MarkerSize', 10}
    {'EdgeLineWidth', 2}
    {'ActiveInputFaceColor',    black}
    {'ActiveInputEdgeColor',    black}
    {'ActiveStageFaceColor',    black}
    {'ActiveStageEdgeColor',    white}
    {'ActiveOutputFaceColor',   white}
    {'ActiveOutputEdgeColor',   black}
    {'ActiveInterpFaceColor',   black}
    {'ActiveInterpEdgeColor',   white}
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
    {'show_numbering', true}
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