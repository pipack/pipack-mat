function stabilityOfAlphaMovie(method, alphas, z_real, z_imag, options)
%STABILITYOFALPHAMOVIE Produces a movie of the stability regions for a method as alpha is varied
% == Parameters ========================================================================================================
%   1. method   (PBM)    - method whose stability you want to test
%   2. alphas   (vector) - alpha values to test
%   3. z_real   (vector) - real z grid values to show in stabilityFigure
%   4. z_imag   (vector) - imaginary z grid values to show in stabilityFigure
%   5. options  (struct) - options for stabilityFigure
% ======================================================================================================================

if(nargin < 5)
    options = struct();
end
if(~isa(method,'PBM')) % case 1
    error('invalid first argument. Must be PBM');
end
alphas = sort(alphas, 'ascend');


    function [amp, sf_options] = method_amp_handle(alpha)
        amp = method.stabilityFunction(alpha);
        plot_title  = ['\alpha = ', num2str(round(alpha, 2))];
        sf_options = setDefaultOptions(options, {{'PlotTitle', plot_title}});
    end

method_amp_handle_args = num2cell(alphas);
method_amp_handle_args = cellfun(@(e) {e}, method_amp_handle_args, 'UniformOutput', false);

stabilityMovie(@method_amp_handle, method_amp_handle_args, z_real, z_imag, options);

end