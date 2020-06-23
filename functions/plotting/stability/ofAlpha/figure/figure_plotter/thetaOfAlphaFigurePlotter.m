function [figure_handle] = thetaOfAlphaFigurePlotter(data_raw, alphas, options)
%THETAOFALPHAPLOTTER calls ofAlphaXYPlotter to plot A(theta) stability as a function of the extrapolation parameter alpha
% == Parameters ========================================================================================================
%   1. data_raw (array) - nxm array of data. number of columns is equal to number of methods. Each column corresponds
%                         to theta stability as a function of alpha for one method.
%   2. alphas (vector)  - range of alpha values to test.
%   3. options          - options for function "ofAlphaXYPlotter."
% == Returns ===========================================================================================================

if(nargin == 2)
    options = struct();
end
default_field_value_pairs = {
    {'YLabel',  '\theta - Stability Angle (degrees)'}
    {'YAxis', [0 95]}
};
options = setDefaultOptions(options, default_field_value_pairs);
figure_handle = ofAlphaXYPlotter(data_raw, alphas, options);
end