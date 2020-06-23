function [figure_handle, data_raw] = stabilityFigure(varargin)
%STABILITYFIGURE plot stability region for a stability function by evaluating it at a grid of z values
% = Parameters =========================================================================================================
%   varargin (cell) - input arguments; must be of one of the following:
%
%                     case 1: (PBM : method, real: alpha, vector: z_real, vector: z_imag, struct: settings)
%                     case 2: (cell{PBM} : methods, vector: z_real, vector: z_imag, struct: settings)
%                     case 3: (function_handle : amp, vector: z_real, vector: z_imag, struct: settings)
%                     case 4: (cell{function_handle} : amps, vector: z_real, vector: z_imag, struct: settings)
%
%   where the final three arguments are
%       > z_real   (array)  - real z grid values to test
%       > z_imag   (array)  - imaginary z grid values to test
%       > options  (struct) - Optional. struct may contain the following fields:
%           RoundingTol   (real)              - Method will be considered stabile if stab_fun(z) <= 1 + RoundingTol.
%           DrawAxis      (bool)              - draws real and imaginary axis
%           LabelAxis     (bool)              - if true adds labels "Re(z)" and "Im(z) to real and imaginary axis
%           StableColor   (3x1 vector or [])  - If non empty, stability region will be colored in FillColor.
%           LineColor     (3x1 vector)        - color of line contour
%           TestRootCond  (bool)              - Test root condition
%           ContourLabel  (numeric)           - Custom label for contour. Must be numeric
%           AxisEqual     (bool)              - if true, axis equal is called
%           FigureIndex   (integer or [])     - Figure to draw plot on. If empty new figure will be created.
%           RootConditionWarning    (bool)    - prints warning if a method is not root stable       
%           RootConditionMarker     (bool)    - if true, then a blue circle is drawn at the origin for root stable 
%                                               method and a red circle is draw for a root unstable method.
%           DrawRootUnstableMethod  (bool)    - if true, methods that are not roots table will still be plotted.
%
% = Returns ============================================================================================================
%   1. figure_handle (handle) handle to figure with plot
%   2. data (matrix) stability function evaluated at each z grid point
% ======================================================================================================================

% -- process inputs ----------------------------------------------------------------------------------------------------
[amps, additional_args] = parseStabilityArgs(true, varargin{:});
% -- extract remaining arguments ---------------------------------------------------------------------------------------
z_real = additional_args{1};
z_imag = additional_args{2};
if(length(additional_args) < 3)
    options = struct();
else
    options = additional_args{3};
end

default_field_value_pairs = {
    % -- Stability Properties ------------------------------------------------------------------------------------------
    {'RoundingTol',     eps * 100}
    % ------- Plot Properties ------------------------------------------------------------------------------------------
    {'DrawAxis',        true}
    {'LabelAxis',       true}
    {'PlotTitle',       ''}
    {'StableColor',     []}
    {'LineColor',       [.7 .7 .7]}
    {'ContourLabel',    []}
    {'AxisEqual',       true}
    {'FontSize',        12}
    {'FontName',        getDefaultFont()}
    % -- Figure Properties ---------------------------------------------------------------------------------------------
    {'FigureIndex',     []}
    % -- Root Condition properties -------------------------------------------------------------------------------------
    {'RootConditionWarning',   true}
    {'RootConditionMarker',    false}
    {'DrawRootUnstableMethod', false}
    };
options = setDefaultOptions(options, default_field_value_pairs);

% -- Set Figure Index --------------------------------------------------------------------------------------------------
if(isempty(options.FigureIndex))
    figure_handle = figure();
else
    figure_handle = figure(options.FigureIndex);
end

hold on;

% -- Test Stability Values ---------------------------------------------------------------------------------------------
num_amps   = length(amps);
data_raw   = cell(num_amps, 1);
[z_r, z_i] = meshgrid(z_real, z_imag);

    function val = getField(options, field, index)
        if(iscell(options.(field)))
            val = options.(field){index};
        else
            val = options.(field);
        end
    end

for i = 1 : length(amps)
    
    amp  = amps{i};
    stability_threshold = 1 + getField(options, 'RoundingTol', i);
    is_root_stable   = isRootStable(amp, options);
    [~, data_raw{i}] = isStableAt(amp, z_r + 1i * z_i, options);
    
    if( is_root_stable || getField(options, 'DrawRootUnstableMethod', i) )  % verify method satisfies root stability if hideRootUnstableMethod
        data = arrayfun(amp, z_r + 1i * z_i);
        data_raw{i} = data;
        
        label = getField(options,'ContourLabel',i);
        show_label = ~isempty(label) && isnumeric(label); 
        
        if(show_label) % shift data so that stability curve is at level 
            delta = label - stability_threshold;
        else % do not shift data if no label is provided
            delta = 0;
        end
        contour_data   = data + delta;
        contour_levels = [0 stability_threshold] + delta;
        
        if(min(data(:)) <= stability_threshold)
            if(isempty(getField(options,'StableColor',i)))
                [c, h] = contour(z_real, z_imag, contour_data, contour_levels, 'color', getField(options, 'LineColor', i));
            else
                [c, h] = contourf(z_real, z_imag, contour_data, contour_levels, 'color', getField(options, 'LineColor', i));
                colormap([getField(options,'StableColor',i); 1 1 1]);
            end
            if(show_label)
                clabel(c, h, 'labelspacing', Inf);
            end
        end
    end
    
    % -- Test Root Condition -------------------------------------------------------------------------------------------
    if(getField(options,'RootConditionWarning',i) && ~is_root_stable)
        if(length(amps) == 1)
            warning('Method does not satisfy root condition');
        else
            warning('Method %i does not satisfy root condition', i);
        end
    end
    
    % -- Draw Root Condition Marker ------------------------------------------------------------------------------------
    if(getField(options,'RootConditionMarker',i))
        if(amp(0) <= stability_threshold)
            origin_color = [52, 152, 219] / 255;
        else
            origin_color = [192, 57, 43] / 255;
        end
        plot(0, 0, '.', 'MarkerSize', 20, 'Color', origin_color);
    end
    
end

if(length(amps) == 1)
    data_raw = data_raw{1};
end

% -- Draw Axis ---------------------------------------------------------------------------------------------------------
if(options.DrawAxis)
    plot([z_real(1) z_real(end)], [0 0], 'Color', [.5 .5 .5]);
    plot([0 0], [z_imag(1) z_imag(end)], 'Color', [.5 .5 .5]);
end
box on;
% -- Label Axis --------------------------------------------------------------------------------------------------------
if(options.LabelAxis)
    xlabel('Re(z)');
    ylabel('Im(z)');
end
set(gca,'FontSize', options.FontSize, 'FontName', options.FontName)
% -- Set Plot Title ----------------------------------------------------------------------------------------------------
if(~isempty(options.PlotTitle))
    title(options.PlotTitle)
end
% -- set natural ratio -------------------------------------------------------------------------------------------------
axis tight;
if(options.AxisEqual)
    axis equal;
end
hold off;

end