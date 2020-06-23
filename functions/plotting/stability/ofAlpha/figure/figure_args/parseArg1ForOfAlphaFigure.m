function [pbms] = parseArg1ForOfAlphaFigure(inputArg1)
%PARSEARGS parses first input arguments, and prints error if arguments are not of correct type
% == Parameters ========================================================================================================
%   inputArg1 (cell) - must be of one of the following:
%                case 1: (PBM : method, ...)
%                case 2: (cell{PBM} : methods, ...)
% == Returns ===========================================================================================================
%   pbms (cell) - cell array containing all pbm methods
% ======================================================================================================================

% -- classify leading argument -----------------------------------------------------------------------------------------
if(isa(inputArg1,'PBM')) % case 1
    pbms = {inputArg1};
elseif(iscellOf(inputArg1, 'PBM')) % case 2
    pbms = inputArg1;
elseif(isa(inputArg1,'function_handle')) % case 3
    pbms = {inputArg1};
elseif(iscellOf(inputArg1, 'function_handle')) % case 4
    pbms = inputArg1;
else
    error(sprintf(['Invalid Arguments. Possible calling sequences are:\n', ...
        '\t1. (PBM : method, vector: alphas, struct: options)\n', ...
        '\t2. (cell{PBM} : methods, vector: alphas, struct: options)\n', ...
        '\t3. (function_handle @(alpha) -> @(z) : amp, vector: alphas, struct: options)\n', ...
        '\t4. (cell{function_handle @(alpha) -> @(z)} : amps, vector: alphas, struct: options)\n' ...
        ]));
end
end