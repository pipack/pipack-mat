function [data_raw] = reIntOfAlphaFigureData(inputArg1, alphas, options)
%REINTALPHAFIGURE plots length of real stability interval as a function of the extrapolation parameter alpha
% == Parameters ========================================================================================================
%   1. inputArg1 (cell) - must be of one of the following:
%                case 1: (PBM : method, real: alpha, vector: z_real, vector: z_imag, struct: settings)
%                case 2: (cell{PBM} : methods, vector: z_real, vector: z_imag, struct: settings)
%   2. alphas (vector) - range of alpha values to test
%   3. options (struct) - all options available to methods ofAlphaXYPlotter and reIntOfAlpha
% == Returns ===========================================================================================================

% -- parse arguments ---------------------------------------------------------------------------------------------------
pbms = parseArg1ForOfAlphaFigure(inputArg1);
if(nargin == 2)
    options = struct();
end

% -- generate data -----------------------------------------------------------------------------------------------------
data_raw = cellfun(@(m) reIntOfAlpha(m, alphas, options), pbms, 'UniformOutput', false);
data_raw = reshape(cell2mat(data_raw), [length(alphas), length(pbms)]);
end