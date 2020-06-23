function stabilityMovie(method_amp_handle, method_amp_handle_params, z_real, z_imag, options)
%STABILITYMOVIE make a movie using where each frame is created using stabilityFigure
% == Parameters ========================================================================================================
%   1. method_amp_handle   (function_handle) - function handle for producing stability functions. It is passed 
%                                              method_amp_handle_params{i}{:}, and must produces a stabilty function and 
%                                              a struct of options for stabilty figure:
%
%                                               Inputs:  method_amp_handle_params{i}{:}
%                                               Outputs: @(z) stability function and struct() of options
%                                           
%   2. method_amp_handle_params (cell)       - a cell array of cell arrays where method_amp_handle_params{i} stores a  
%                                              cell array with the parameters for obtaining the ith method stability
%                                              function.
%   3. z_real   (array) - real z grid values to test
%   4. z_imag   (array) - imaginary z grid values to test
%   5. options  (struct) - options for stabilityFigure

if(nargin < 5)
    options = struct();
end
default_options = {};
options = setDefaultOptions(options, default_options);
figure_index = 1;

    function frame_handle(i)
        clf;
        [amp, sf_options] = method_amp_handle(method_amp_handle_params{i}{:});
        sf_options.FigureIndex = figure_index;
        stabilityFigure(amp, z_real, z_imag, sf_options);
    end

figure(figure_index);
frame_handle_params = arrayfun(@(i) {i}, 1:length(method_amp_handle_params), 'UniformOutput', false);
saveMovie(@frame_handle, frame_handle_params, options);

end