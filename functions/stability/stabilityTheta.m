function [theta] = stabilityTheta(varargin)
%STABILITYTHETA numerically estimates A(theta) stability for method using bisection. Note this function will not
%estimated the correct stability angle if the stabity region is not connected, and symmetric about the Re(z) axis.
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
%       > BisectionTol (real) - bisection terminates when the difference between max and min angle is below tolerance. 
%       > Units (str) - 'degrees' or 'radians'
%       > Remaining options are identical to those of the method isRayStable.
%
% == Returns ===========================================================================================================
%   1. theta - computed theta stability value
% ======================================================================================================================

% -- Parse Inputs ------------------------------------------------------------------------------------------------------
[amp, additional_args] = parseStabilityArgs(false, varargin{:});
if(length(additional_args) >= 1)
    options = additional_args{1};
else
    options = struct();
end
field_value_pairs = { ...
    {'BisectionTol', 1e-5}
    {'ExitOnFail', true}
    {'Units', 'radians'}
};
options = setDefaultOptions(options, field_value_pairs);
% ----------------------------------------------------------------------------------------------------------------------

theta = NaN;
if(~isRayStable(amp, 0, options)) % -- verify stability along real axis ------------------------------------------------
    return;
elseif(isRayStable(amp, pi/2, options)) % -- test stability along imaginary axis ---------------------------------------
    theta = pi/2;
else % -- bisection method --------------------------------------------------------------------------------------------- 
    theta_min = 0;
    theta_max = pi/2;
    theta_mid = theta_max;
    while((theta_max - theta_min) > options.BisectionTol)
        theta_mid = (theta_max + theta_min)/2;
        if(isRayStable(amp, theta_mid, options))
            theta_min = theta_mid;
        else
            theta_max = theta_mid;
        end
    end
    theta = theta_mid;
end

% -- round theta -------------------------------------------------------------------------------------------------------
error_bound = options.BisectionTol;                          % bisection precision
error_exp   = ceil(log(error_bound)/log(10));                % exponent of error
theta       = floor(theta / 10^error_exp) * 10^error_exp;    % round theta angle to limit of bisection precision 

if(strcmp(options.Units, 'degrees'))
    theta = 180 / pi * theta;
end
end