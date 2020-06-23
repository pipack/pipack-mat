function [flag] = isReStable(varargin)
%ISROOTSTABLE determines if a method is stable along the real axis. There are two possible calling sequences.
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
%       > rInf        (real)    - large R value to test to estimate sability for R = infinity
%       > RayLength   (real)    - length of ray
%       > NumPoints   (integer) - number of points to test along ray   
%       > RoundingTol (real)    - methods with amplification factors greater than 1 + RoundingTol will be considered 
%                                 unstable.                               
%
% == Returns ===========================================================================================================
%   1. flag - true if method appears to be stable along real axis, false otherwise
% ======================================================================================================================

% -- Parse Inputs ------------------------------------------------------------------------------------------------------
[amp, additional_args] = parseStabilityArgs(false,varargin{:});
if(length(additional_args) >= 1)
    options = additional_args{1};
else
    options = struct();
end
% -- Check Stability ---------------------------------------------------------------------------------------------------
flag = isRayStable(amp, 0, options);
end