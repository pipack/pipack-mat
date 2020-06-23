function [figure_handle, data_raw] = imStabilityFigure(varargin)
%STABILITYFIGURE plot stability region for a stability function along the imaginary axis by evaluating it at a set of 
%                z-values
% = Parameters =========================================================================================================
%   varargin (cell) - input arguments; must be of one of the following:
%
%                     case 1: (PBM : method, real: alpha, vector: z_imag, struct: settings)
%                     case 2: (cell{PBM} : methods, vector: z_imag, struct: settings)
%                     case 3: (function_handle : amp, vector: z_imag, struct: settings)
%                     case 4: (cell{function_handle} : amps, vector: z_imag, struct: settings)
%
%   where the final three arguments are
%       > z_real   (array)  - real z grid values to test
%       > z_imag   (array)  - imaginary z grid values to test
%       > options  (struct) - Optional. struct may contain the following fields:
%           DrawAxis      (bool)              - draws real and imaginary axis
%           LabelAxis     (bool)              - if true adds labels "Re(z)" and "Im(z) to real and imaginary axis
%           Colorize      (bool)              - if true, colors unstable regions in red and stable regions in blue
%           StableColor   (3x1 vector)        - if Colorize = true, then this is color of stable regions. 
%           UnstableColor (3x1 vector)        - if Colorize = false, then this is color of unstable regions. 
%           LineColor     (3x1 vector)        - base color of stability function
%           FigureIndex   (integer or [])     - Figure to draw plot on. If empty new figure will be created.
%           RootConditionWarning    (bool)    - prints warning if a method is not root stable       
%           RootConditionMarker     (bool)    - if true, then a blue circle is drawn at the origin for root stable 
%                                               method and a red circle is draw for a root unstable method.
%           DrawRootUnstableMethod  (bool)    - if true, methods that are not root stable will still be plotted.
%
% = Returns ============================================================================================================
%   1. figure_handle (handle) handle to figure with plot
%   2. data (matrix) stability function evaluated at each z grid point
% ======================================================================================================================

% -- process inputs ----------------------------------------------------------------------------------------------------
[amps, additional_args] = parseStabilityArgs(true, varargin{:});
% -- extract remaining arguments ---------------------------------------------------------------------------------------
z_imag = additional_args{1};
if(length(additional_args) < 2)
    options = struct();
else
    options = additional_args{2};
end

default_field_value_pairs = {
    % -- Stability Properties ------------------------------------------------------------------------------------------
    {'RoundingTol',     eps * 100}
    % ------- Plot Properties ------------------------------------------------------------------------------------------
    {'DrawAxis',        true}
    {'PlotTitle',       ''}
    {'LabelAxis',       true}
    {'Colorize',        true}
    {'StableColor',     [63 169 245] / 255}
    {'UnstableColor',   [237 28 36] / 255}
    {'LineColor',       [.8 .8 .8]}
    {'LineWidth',       1}
    {'MarkerSize',      2}
    {'FontSize',        12}
    {'FontName',        getDefaultFont()}
    {'YAxis',           'default'}
    % -- Figure Properties ---------------------------------------------------------------------------------------------
    {'FigureIndex',     []}
    % -- Root Condition properties -------------------------------------------------------------------------------------
    {'RootConditionWarning',   true}
    {'RootConditionMarker',    true}
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
    [~, data_raw{i}] = isStableAt(amp, 1i * z_imag, options);
    
    if( is_root_stable || getField(options, 'DrawRootUnstableMethod', i) )  % verify method satisfies root stability if hideRootUnstableMethod
        data = arrayfun(amp, 1i * z_imag);
        data_raw{i} = data;
        
        plot(z_imag, data, 'color', getField(options, 'LineColor'), 'LineWidth', getField(options, 'LineWidth'));
        if(getField(options,'Colorize',i))
            inds = find(data < stability_threshold);
            plot(z_imag(inds), data(inds), '.', 'color', getField(options, 'StableColor'), 'MarkerSize', getField(options, 'MarkerSize'));
            inds = find(data > stability_threshold);
            plot(z_imag(inds), data(inds), '.', 'color', getField(options, 'UnstableColor'), 'MarkerSize', getField(options, 'MarkerSize'));
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
        root_amp = amp(0);
        if(root_amp <= stability_threshold)
            origin_color = [52, 152, 219] / 255;
        else
            origin_color = [192, 57, 43] / 255;
        end
        plot(0, root_amp, '.', 'MarkerSize', 20, 'Color', origin_color);
    end
    
end

if(length(amps) == 1)
    data_raw = data_raw{1};
end

% -- Label Axis --------------------------------------------------------------------------------------------------------
if(options.LabelAxis)
    xlabel({'', 'Im(z)'});
    ylabel({'Amplification Factor',''});
end
% -- Set Plot Title ----------------------------------------------------------------------------------------------------
if(~isempty(options.PlotTitle))
    title({options.PlotTitle, ''})
end
% -- Set Y-Axis Range --------------------------------------------------------------------------------------------------
if(ischar(options.YAxis))
    switch options.YAxis
        case 'tight'
            axis tight
    end
elseif(isvector(options.YAxis))
    axis([min(z_imag) max(z_imag) options.YAxis])
end

set(gca,'FontSize', options.FontSize, 'FontName', options.FontName)


end