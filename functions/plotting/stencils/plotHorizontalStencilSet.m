function aspect_ratio = plotHorizontalStencilSet(num_stencils, plot_function_handle, plot_options, layout_options)
%PLOTHORIZONTALSTENCILSET helper function that plots the set of stencils layed out horizontally.
% = PARAMETERS =========================================================================================================
%   plot_options        (struct)  - options passed to stencil plotting function.
%   layout_options     (struct)   - plotting options
%       {'LeftLabel', []}         - label to the left of the diagram
%       {'StencilGap', 0}         - gap between each stencil
%       {'IndexStencils', bool}   - if true, plotter will add lower label "j = 1", "j = 2", ... to stencils
% = Returns ============================================================================================================
default_options = {
    {'LeftLabel', []}
    {'StencilGap', 0}
    {'IndexStencils', true}
    };
layout_options = setDefaultOptions(layout_options, default_options);
left_bound = 0;
border = [0 0 0 0];

for j = 1 : num_stencils
    % -- Left Label for ODE Polynomial Type ----------------------------------------------------------------------------
    if(j == 1 && ~isempty(layout_options.LeftLabel))
        plot_options.LeftLabel = layout_options.LeftLabel;
    else
        plot_options.LeftLabel = [];
    end
    % -- Lower Stencil Output Index ------------------------------------------------------------------------------------
    if(layout_options.IndexStencils)
        plot_options.LowerLabel = sprintf('j = %i', j);
    end
    % -- set origin and plot jth stencil -------------------------------------------------------------------------------
    plot_options.LeftBound = left_bound;
    plot_border = plot_function_handle(j, plot_options);
    % -- shift origin and update borders -------------------------------------------------------------------------------
    left_bound = left_bound + (plot_border(2) - plot_border(1)) + layout_options.StencilGap;
    if(j == 1)
        border([1 3 4]) = plot_border([1 3 4]);
    end
    if(j == num_stencils)
        border(2) = plot_border(2);
    end
end
% -- set axis ----------------------------------------------------------------------------------------------------------
axis off;
axis equal;
xlim(border(1:2));
ylim(border(3:4));
hold off;
aspect_ratio = [diff(border(3:4)) diff(border(1:2))];

end