function [figure_handle] = isImStableOfAlphaFigurePlotter(data_raw, alphas, options)
%ATSvsALPHAFIGURE plots A(theta) stability as a function of the extrapolation parameter alpha
% == Parameters ========================================================================================================
%   1. raw_data (struct) - struct containing the following two fields
%           'imstab'    (cell) - length of array corres[onds to number of methods. ith entry contains bool array which 
%                                determines stability along imaginary axis. If x(i)=true, then  method is im-stable for 
%                                alpha(i)  
%           'rootstab'  (cell) - length of array cooresponds to number of methods. ith entry contains bool array which
%                                determines root stability. If x(i) = true, then method is root stable for 
%                                alpha = alphas(i).
%   2. alphas (vector) - range of alpha values used to determine theta stability
%   3. options (struct) - struct with any of the following optional fields
%       'FigureIndex',     []}
%       'RootStableLineWidth',    3/4}
%       'RootStableColor',        [.8 .8 .8]}
%       'ImStableLineWidth',      3/4}
%       'ImStableColor',          [.1 .1 .1]}
%       'RootUnstableLineWidth',  3/12}
%       'RootUnstableColor',      [0 0 0]}
%       'DrawRootStabilityBars',  true}
%       'XCoordinate',            0}
%       'XLabel',                 ''}
%       'YLabel',                 '\alpha - extrapolation parameter'}
%       'LabelAxis',              true}
%       'XAxis',                  'natural'}
%       'YAxis',                  'tight'}
%       'FontSize',               12
%       'FontName',               'Minion Pro'
%
%
% == Returns ===========================================================================================================

if(nargin == 2)
    options = struct();
end
default_field_value_pairs = {
    {'FigureIndex',     []}
    {'RootStableLineWidth',    3/4} % should be actual size
    {'RootStableColor',        [.8 .8 .8]}
    {'ImStableLineWidth',      3/4}
    {'ImStableColor',          [.1 .1 .1]}
    {'RootUnstableLineWidth',  3/12}
    {'RootUnstableColor',      [0 0 0]}
    {'DrawRootStabilityBars',  true}
    {'XCoordinate',            0}
    {'XLabel',                 ''}
    {'YLabel',                 '\alpha - extrapolation parameter'}
    {'PadAxisLabel',           false}
    {'YAxis',                  'tight'}
    {'XAxis',                  'natural'}
    {'XTicks',                 'auto'}
    {'YTicks',                 'auto'}
    {'FontSize',               12}
    {'FontName',               getDefaultFont()}
    {'ClearFigure',            false}
    };
options  = setDefaultOptions(options, default_field_value_pairs);
data_raw_imstab   = data_raw.imstab;
data_raw_rootstab = data_raw.rootstab; 
    
% -- sort alpha --------------------------------------------------------------------------------------------------------
alphas = sort(alphas, 'ascend');

% -- Set Figure Index --------------------------------------------------------------------------------------------------
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

% -- Plot Data ---------------------------------------------------------------------------------------------------------
    function val = getField(options, field, index)
        if(iscell(options.(field)))
            val = options.(field){index};
        else
            val = options.(field);
        end
    end

for i = 1 : length(data_raw_imstab)
    
    ims_data = data_raw_imstab{i};
    x_coord = getField(options, 'XCoordinate', i);
    
    if(options.DrawRootStabilityBars) %-- draw root stability bars -----------------------------------------------------
        rs_data  = data_raw_rootstab{i};
        
        rs_color = getField(options, 'RootStableColor', i);
        rs_lw = getField(options,    'RootStableLineWidth', i);
        intervalPlot(x_coord, alphas, rs_data, struct('Color', rs_color, 'LineWidth', rs_lw));
        
        rus_color = getField(options, 'RootUnstableColor', i);
        rus_lw    = getField(options, 'RootUnstableLineWidth', i);
        intervalPlot(x_coord, alphas, ~rs_data, struct('Color', rus_color, 'LineWidth', rus_lw));
    end
    % -- draw im stability bars ----------------------------------------------------------------------------------------
    im_color = getField(options, 'ImStableColor', i);
    im_lw    = getField(options, 'ImStableLineWidth', i);
    intervalPlot(x_coord, alphas, ims_data, struct('Color', im_color, 'LineWidth', im_lw));
end

% -- Label Axis --------------------------------------------------------------------------------------------------------
if(~isempty(options.XLabel))
    if(options.PadAxisLabel)
    	xlabel({'',options.XLabel});
    else
    	xlabel(options.XLabel);
    end
end
if(~isempty(options.YLabel))
    if(options.PadAxisLabel)
    	 ylabel({options.YLabel, ''});
    else
    	 ylabel(options.YLabel);
    end
   
end
set(gca,'FontSize', options.FontSize, 'FontName', options.FontName)
% -- Set Y-Axis Range --------------------------------------------------------------------------------------------------
if(ischar(options.YAxis))
    switch options.YAxis
        case 'tight'
            xl = xlim();
            axis tight;
            xlim(xl);
    end
elseif(isvector(options.YAxis))
   ylim(options.YAxis);
end
% -- Set X-Axis Range --------------------------------------------------------------------------------------------------
if(ischar(options.XAxis))
    xcv  = Param2Vector(options.XCoordinate);       % x-center vector
    islw = Param2Vector(options.ImStableLineWidth); % vector of line-widths
    switch options.XAxis
        case 'tight'
            delta = max(islw)/2;
        case 'natural'
            delta = (3/2) * max(islw)/2;
        otherwise
            warning('Unsupported XAxis string.');
            delta = 0;            
    end
    xlim([min(xcv)-delta max(xcv)+delta]);
elseif(isvector(options.XAxis))
   xlim(options.XAxis);
end
% -- Set Ticks ---------------------------------------------------------------------------------------------------------
xticks(options.XTicks);
yticks(options.YTicks);

hold off;
end


function param = Param2Vector(param)
if(iscell(param))
    param = cell2mat(param);
end
end