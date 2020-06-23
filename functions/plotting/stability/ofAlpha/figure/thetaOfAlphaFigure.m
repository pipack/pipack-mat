function [figure_handle, data_raw] = thetaOfAlphaFigure(inputArg1, alphas, options)
%ATSvsALPHAFIGURE plots A(theta) stability as a function of the extrapolation parameter alpha
% == Parameters ========================================================================================================
%   1. inputArg1 (cell) - must be of one of the following:
%                case 1: (PBM : method, real: alpha, vector: z_real, vector: z_imag, struct: settings)
%                case 2: (cell{PBM} : methods, vector: z_real, vector: z_imag, struct: settings)
%   2. alphas (vector) - range of alpha values to test
%   3. options (struct) - all options available to methods ofAlphaXYPlotter and thetaOfAlpha
% == Returns ===========================================================================================================

% -- generate data & plot ----------------------------------------------------------------------------------------------
data_raw      = thetaOfAlphaFigureData(inputArg1, alphas, options);
figure_handle = thetaOfAlphaFigurePlotter(data_raw, alphas, options);
end