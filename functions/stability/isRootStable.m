function [flag, data] = isRootStable(varargin)
%ISROOTSTABLE determines if a method is root stable. Two possible calling sequences.
% == Parameters ========================================================================================================
%
%   Possibility 1:
%
%       1. method   (PBM)    - method object
%       2. alpha    (scalar) - extrapolation parameters
%       3. options  (struct) - optional parameter struct (fields described below)
%
%   Possibility 2:
%
%       1. amp      (function_handle) - function handle of one argument coorsponding to stability function
%       2. options  (struct) - optional parameter struct (fields described below)
%
%    Options Struct Fields:
%
%       > RoundingTol (real) - methods with amplification factors greater than 1 + RoundingTol will be considered 
%                              unstable.                               
%
% == Returns ===========================================================================================================
%   1. flag - true if method is root stable, false otherwise
%   2. data - amplification factor at z = 0.
% ======================================================================================================================

% -- Parse Inputs ------------------------------------------------------------------------------------------------------
[amp, additional_args] = parseStabilityArgs(false, varargin{:});
if(length(additional_args) >= 1)
    options = additional_args{1};
else
    options = struct();
end
% -- Check Stability ---------------------------------------------------------------------------------------------------
[flag, data] = isStableAt(amp, 0, options);
end