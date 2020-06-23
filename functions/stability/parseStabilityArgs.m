function [amp, additional_args] = parseStabilityArgs(allow_cell_inputs, varargin)
%PARSESTABARGS parses first input arguments for stability functions.
% == Parameters ========================================================================================================
%   1. allow_multiple_methods (bool) - if true, varargin can contain cell arrays of functions or PBMs
%   2. varargin (cell) - input arguments; must be of one of the following. If allow_multiple_methods = false, then:
%
%                case 1: (PBM : method, real: alpha, ...)
%                case 2: (function_handle : amp, ...)
%
%   If allow_multiple_methods = true, then there are two additional cases:
%
%                case 3: (cell{PBM} : methods, vector: z_real, vector: z_imag, struct: settings)
%                case 4: (cell{function_handle} : amps, vector: z_real, vector: z_imag, struct: settings)
%
% == Returns ===========================================================================================================
%   amp      (function_handle or {function_handle}) - a function handles that determine stability. Functions will be
%                                                     returned in a cell array if allow_multiple_methods = true.
%   additional_args  (cell) - remaining args
% ======================================================================================================================


method_amp  = @(m, alpha) m.stabilityFunction(alpha);
leading_arg = varargin{1};

if(allow_cell_inputs) % -- cell inputs (multiple methods, function cell array output) ----------------------------------
    if(isa(leading_arg,'PBM')) % case 1
        amp = {method_amp(varargin{1:2})};
        arg_shift = 3;
    elseif(isa(leading_arg, 'function_handle')) % case 2
        amp = {leading_arg};
        arg_shift = 2;
    elseif(iscellOf(leading_arg, 'PBM')) %iscell(leading_arg) && all(cellfun(@(e) isa(e, 'PBM'), leading_arg))) % case 3
        alpha = varargin{2};
        amp  = cellfun(@(m) method_amp(m,alpha), leading_arg, 'UniformOutput', false);
        arg_shift = 3;
    elseif(iscellOf(leading_arg, 'function_handle'))%iscell(leading_arg) && all(cellfun(@(e) isa(e, 'function_handle'), leading_arg))) % case 4
        amp = leading_arg;
        arg_shift = 2;
    else
        error(sprintf(['Invalid Arguments. Possible calling sequences are:\n', ...
            '\t1. (PBM : method, real: alpha, ...)\n', ...
            '\t2. (cell{PBM} : methods, ...)\n', ...
            '\t3. (function_handle : amp, ..)\n', ...
            '\t4. (cell{function_handle} : amps, ...)\n']));
    end    
else % -- no cell inputs (one method and function output) --------------------------------------------------------------    
    if(isa(leading_arg, 'function_handle')) % case 2
        amp = leading_arg;
        arg_shift = 2;
    elseif(isa(leading_arg,'PBM')) % case 1
        amp = method_amp(varargin{1:2});
        arg_shift = 3;
    else
        error(sprintf(['Invalid Leading Arguments. Possible calling sequences are:\n', ...
            '\t1. (PBM : method, real: alpha, ...)\n', ...
            '\t3. (function_handle : amp, ...)\n']));
    end
end
% -- extract remaining arguments ---------------------------------------------------------------------------------------
additional_args = varargin(arg_shift:end);
end