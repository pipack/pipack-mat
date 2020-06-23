function [flag] = isRayStable(varargin)
%ISRAYSTABLE determines if a method is stable along the ray z = r * exp(1i * (pi - theta)) for r \ge 0. There are two 
% possible calling sequences.
% == Parameters ========================================================================================================
%
%   Possibility 1:
%
%       1. method   (PBM)    - method object
%       2. alpha    (scalar) - extrapolation parameters
%       3. theta    (scalar) - angle of ray in radians measured clockwise from negative real axis. 
%       4. options  (struct) - optional parameter struct (fields described below)
%
%   Possibility 2:
%
%       1. amp      (function_handle) - function handle of one argument coorsponding to stability function
%       2. theta    (scalar) - angle of ray in radians measured clockwise from negative real axis.
%       3. options  (struct) - optional parameter struct (fields described below)
%
%    Options Struct Fields:
%       > rInf        (real)    - large R value to test to estimate sability for R = infinity
%       > RayLength   (real)    - length of ray
%       > NumPoints   (integer) - number of points to test along ray   
%       > RoundingTol (real)    - methods with amplification factors greater than 1 + RoundingTol will be considered 
%                                 unstable.                               
%
% == Returns ===========================================================================================================
%   1. flag - true if method appears to be stable along ray, false otherwise
% ======================================================================================================================

% -- Parse Inputs ------------------------------------------------------------------------------------------------------
[amp, additional_args] = parseStabilityArgs(false, varargin{:});
theta = additional_args{1};
if(length(additional_args) >= 2)
    options = additional_args{2};
else
    options = struct();
end
% -- Set Options -------------------------------------------------------------------------------------------------------
field_value_pairs = { {'rInf', 1e10}, {'RayLength', 10}, {'NumPoints', 1000}, {'ExitOnFail', true}};
options = setDefaultOptions(options, field_value_pairs);

% -- Check Stability ---------------------------------------------------------------------------------------------------
switch theta % prevent rounding errors in real and imaginary components for theta = 0 and theta = pi/2
    case 0
        angle = -1;
    case pi/2
        angle = 1i;
    otherwise
        angle = exp(1i * (pi - theta));
end

if(isRootStable(amp))
    zs = [options.rInf, linspace(0, options.RayLength, options.NumPoints)] * angle;
    flags = isStableAt(amp, zs, options);
    flag = all(flags) && all(~isnan(flags));
else
    flag = false;
end
end