function [data_raw] = isImStableOfAlphaFigureData(inputArg1, alphas, options)
%ATSvsALPHAFIGURE plots A(theta) stability as a function of the extrapolation parameter alpha
% == Parameters ========================================================================================================
%   1. inputArg1 (cell) - must be of one of the following:
%                case 1: (PBM : method, real: alpha, vector: z_real, vector: z_imag, struct: settings)
%                case 2: (cell{PBM} : methods, vector: z_real, vector: z_imag, struct: settings)
%   2. alphas (vector) - range of alpha values to test
%   3. options (struct) - all options for isImStableOfAlphaPlotter
% == Returns ===========================================================================================================

% -- parse arguments ---------------------------------------------------------------------------------------------------
pbms = parseArg1ForOfAlphaFigure(inputArg1);
if(nargin == 2)
    options = struct();
end

% -- generate data -----------------------------------------------------------------------------------------------------
data_raw_imstab = cellfun(@(m) isImStableOfAlpha(m, alphas, options), pbms, 'UniformOutput', false);
data_raw_rstab  = cellfun(@(m) isRootStableOfAlpha(m, alphas, options), pbms, 'UniformOutput', false);
data_raw        = struct('imstab', {data_raw_imstab}, 'rootstab', {data_raw_rstab});
end