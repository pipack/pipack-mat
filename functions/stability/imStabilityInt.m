function [R] = imStabilityInt(varargin)
%IMSTABILITYINT numerically estimates the stability interval of a method along the imaginary axis. Assumes that
%stability region is symmetric with respect to real-axis.  There are two possible calling sequences. 
% == Parameters ========================================================================================================
%
%   Possibility 1:
%
%       1. method   (PBM)    - method object
%       2. alpha    (scalar) - extrapolation parameters
%       4. options  (struct) - optional parameter struct (fields described below)
%
%   Possibility 2:
%
%       1. amp      (function_handle) - function handle of one argument coorsponding to stability function
%       3. options  (struct) - optional parameter struct (fields described below)
%
%    Options Struct Fields:
%    > Identical to those of function stabilityRayInt                                   
%
% == Returns ===========================================================================================================
%   1. R - estimated max length of stability along imaginary axis
% ======================================================================================================================

% -- Parse Inputs ------------------------------------------------------------------------------------------------------
[amp, additional_args] = parseStabilityArgs(false, varargin{:});
if(length(additional_args) >= 1)
    options = additional_args{1};
else
    options = struct();
end
R = rayStabilityInt(amp, pi/2, options);
end