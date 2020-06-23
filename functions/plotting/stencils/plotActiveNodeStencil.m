function [borders] = plotActiveNodeStencil(active_input_inds, active_stage_inds, active_output_inds, active_interp_inds, ODE_DS, IVS, options)
%PLOTACTIVENODESTENCIL helper function for plotting an active node stencil
% = Parameters =========================================================================================================
%   1. active_input_inds    (vector) - indices of active input data
%   2. active_stage_inds    (vector) - indices of active stage data
%   3. active_output_inds   (vector) - indices of active output data
%   4. active_interp_inds   (vector) - indices of active interpolated data. NOTE must be relative to nodevector of
%                                      interpolated value set, which is comprised of [solution, derivative] nodes.
%   5. ODE_DS               (ODE_Dataset) - underlying ODE dataset.
%   6. IVS                  (InterpolatedValueSet) - any interpolated value set associated with ODE_DS.
% = Returns ============================================================================================================
%   1. borders              (vector) - 4x1 vector containg coordinates of the borders of stencil in the ordering
%                                               [left_border, right_border bottom_border top_boder]
% ======================================================================================================================

if(nargin <= 6)
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
    text(options.origin(1), options.LabelSeparation + (options.origin(2) + options.height/2),' Im(z)', 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'bottom', 'Color', options.AxisColor, 'FontSize', options.FontSize, 'FontName', options.FontName);
end

% -- shift all nodes relative to graph origin --------------------------------------------------------------------------
offset          = options.origin(1) + 1i*options.origin(2);
z_in_offset     = ODE_DS.z_in  + offset;
z_out_offset    = (ODE_DS.z_out + options.alpha) + offset;
z_stage_offset  = ODE_DS.c(options.alpha) + offset;
if(~isempty(IVS))
    z_interp_offset = IVS.nodeVector(options.alpha) + offset;
else
	z_interp_offset = [];  
end

if(options.StencilEdges)
    if(options.ShowInterpolatedValues)
        node_cell = {z_in_offset(active_input_inds),  z_stage_offset(active_stage_inds), z_out_offset(active_output_inds), z_interp_offset(active_interp_inds)};
    else
        node_cell = {z_in_offset(active_input_inds),  z_stage_offset(active_stage_inds), z_out_offset(active_output_inds)};
    end
    [X, Y] = stencilEdges(node_cell);
    plot(X,Y,'Color', options.EdgeColor, 'lineWidth', options.EdgeLineWidth);
end

% -- set marker size ---------------------------------------------------------------------------------------------------
marker_r  = options.MarkerSize / 100;
marker_lw = options.MarkerSize / 8;

% -- helper functions --------------------------------------------------------------------------------------------------
    function plotNEPNodes(nodes, active_inds, marker_handle, node_type, node_state)
        %PLOTNEPNODES plot nodes that cannot be evaluation ponts (i.e. inputs, interpolated values)
        % = Parameters =================================================================================================
        % nodes         (vector) - nodes in local tau coordinates
        % active_inds   (vector) -
        % marker_handle (handle) - function for plotting node marker. must be of form
        %                                   @(nodes, size, line_width, faceColor,EdgeColor)
        % node_type     (char)   - type of node (Inputs, InterpolatedDerivatives, InterpolatedSolutions)
        % node_state    (char)   - type of node (Active, Inactive)
        switch node_state
            case 'Active'
                marker_handle(nodes(active_inds),   marker_r, marker_lw, options.(['Active', node_type, 'FaceColor']),   options.(['Active', node_type, 'EdgeColor']));
            case 'Inactive'
                inactive_inds = setdiff(1:length(nodes), active_inds);
                marker_handle(nodes(inactive_inds), marker_r, marker_lw, options.(['Inactive', node_type, 'FaceColor']),   options.(['Inactive', node_type, 'EdgeColor']));
        end
    end

    function plotEPNodes(nodes, active_inds, marker_handle, node_type, node_state)
        %PLOTEPNODES plot nodes that can be evaluation ponts (i.e. outputs and stages)
        % = Parameters =================================================================================================
        % nodes         (vector) - nodes in local tau coordinates
        % active_inds   (vector) -
        % marker_handle (handle) - function for plotting node marker. must be of form
        %                                   @(nodes, size, faceColor,EdgeColor)
        % node_type     (char)   - type of node (Inputs, InterpolatedDerivatives, InterpolatedSolutions)
        % node_state    (char)   - type of node (Active, Inactive)
        
        inactive_inds = setdiff(1:length(nodes), active_inds);
        ei = options.(['Evaluation', node_type, 'Index']);
        if(~isempty(ei)) % plot evaluation node differently
            if(ismember(ei, active_inds))
                active_inds = setdiff(active_inds, ei);
                if(strcmp(node_state, 'Evaluation'))
                    marker_handle(nodes(ei), marker_r, marker_lw, options.(['ActiveCurrent', node_type, 'FaceColor']), options.(['ActiveCurrent', node_type, 'EdgeColor']));
                end
            else
                inactive_inds = setdiff(inactive_inds, ei);
                if(strcmp(node_state, 'Evaluation'))
                    marker_handle(nodes(ei), marker_r, marker_lw, options.(['InactiveCurrent', node_type, 'FaceColor']), options.(['InactiveCurrent', node_type, 'EdgeColor']));
                end                                
            end
            switch node_state
                case 'Active'
                    marker_handle(nodes(active_inds),   marker_r, marker_lw, options.(['Active', node_type, 'FaceColor']),   options.(['Active', node_type, 'EdgeColor']));
                case 'Inactive'
                    marker_handle(nodes(inactive_inds), marker_r, marker_lw, options.(['Inactive', node_type, 'FaceColor']), options.(['Inactive', node_type, 'EdgeColor']));
            end            
        else
            plotNEPNodes(nodes, active_inds, marker_handle, node_type, node_state)
        end
    end

    function plotNodeState(node_state)
        % -- Non Evaluation Point Nodes --------------------------------------------------------------------------------
        plotNEPNodes(z_in_offset, active_input_inds, @circleMarker, 'Input', node_state);
        if(options.ShowInterpolatedValues)
            plotNEPNodes(z_interp_offset, active_interp_inds, @circleWithCrossMarker, 'Interpolated', node_state);
        end
        % -- Evaluation Point Nodes ------------------------------------------------------------------------------------
        plotEPNodes(z_stage_offset, active_stage_inds, @circleWithDotMarker, 'Stage', node_state)
        plotEPNodes(z_out_offset, active_output_inds, @circleMarker, 'Output', node_state)
    end

plotNodeState('Inactive');
plotNodeState('Active');
plotNodeState('Evaluation');

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

default_field_value_pairs = { ...
    {'LeftBound', 0}
    {'LeftWidth', 1/3}
    {'RightWidth', 1}
    {'alpha', 2/3}
    {'height', 8/3}
    {'DrawAxis', true}
    {'LabelAxis', false}
    {'MarkerSize', 10}
    {'EdgeLineWidth', 2}
    {'ShowInterpolatedValues', false}
    {'StencilEdges', true}
    {'EvaluationOutputIndex', []}
    {'EvaluationStageIndex', []}
    {'AxisColor', grey}
    {'ActiveInputFaceColor',            black}
    {'ActiveInputEdgeColor',            black}
    {'ActiveStageFaceColor',            black}
    {'ActiveStageEdgeColor',            white}
    {'ActiveOutputFaceColor',           black}
    {'ActiveOutputEdgeColor',           black}
    {'ActiveInterpolatedFaceColor',     black}
    {'ActiveInterpolatedEdgeColor',     white}
    {'InactiveInputFaceColor',          grey}
    {'InactiveInputEdgeColor',          grey}
    {'InactiveStageFaceColor',          grey}
    {'InactiveStageEdgeColor',          white}
    {'InactiveOutputFaceColor',         grey}
    {'InactiveOutputEdgeColor',         grey}
    {'InactiveInterpolatedFaceColor',   grey}
    {'InactiveInterpolatedEdgeColor',   white}
    {'ActiveCurrentOutputFaceColor',    white}
    {'ActiveCurrentOutputEdgeColor',    black}
    {'ActiveCurrentStageFaceColor',     white}
    {'ActiveCurrentStageEdgeColor',     black}
    {'InactiveCurrentOutputEdgeColor',  grey}
    {'InactiveCurrentOutputFaceColor',  white}
    {'InactiveCurrentStageEdgeColor',   white}
    {'InactiveCurrentStageFaceColor',   grey}
    {'EdgeColor', black}
    {'LowerLabel', []}
    {'LeftLabel', []}
    {'LowerLabelColor', black}
    {'LabelSeparation', .1} % how far labels are pushed from axis
    {'Padding', [1/6 1/6 1/6 1/6]} % how much padding is added around axis (Top, Right, Bottom, Left)
    {'LabelPadding', [1/3 7/12 1/3 7/12]} % how much padding is added around axis (Top, Right, Bottom, Left)
    {'FontSize', 12}
    {'FontName', 'Minion Pro'}
    };

options = setDefaultOptions(options, default_field_value_pairs);

end