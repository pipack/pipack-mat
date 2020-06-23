function [R] = rayStabilityInt(varargin)
%RAYSTABILITYINT numerically estimates the stability interval of a method along a Ray. Combines bisection and
%verification at linearly spaced z values. There are two possible calling sequences.
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
%       > MaxR         (real)    - large initial R value for bisection
%       > BisectionTol (real)    - bisection terminates when the difference between max_R and min_R is below tolerance. 
%       > MaxRestarts  (real)    - maximum times algorithm can restart if unstable values are found in final interval
%       > NumPoints    (integer) - number of points to test along interval
%       > Remaining options are identical to those of the method isStableAt
%
% == Returns ===========================================================================================================
%   1. R - estimated max length of stability along ray
% ======================================================================================================================

% -- Parse Inputs ------------------------------------------------------------------------------------------------------
[amp, additional_args] = parseStabilityArgs(false, varargin{:});
theta = additional_args{1};
if(length(additional_args) >= 2)
    options = additional_args{2};
else
    options = struct();
end
field_value_pairs = { ...
    {'NumPoints',    1000}
    {'MaxRestarts',  10}
    {'BisectionTol', 1e-5}
    {'MaxR', 1e10}
};
options = setDefaultOptions(options, field_value_pairs);
% ----------------------------------------------------------------------------------------------------------------------

switch theta % prevent rounding errors in real and imaginary components for theta = 0 and theta = pi/2
    case 0
        angle = -1;
    case pi/2
        angle = 1i;
    otherwise
        angle = exp(1i * (pi - theta));
end
R = NaN;

% -- verify method is unstable at MaxR ---------------------------------------------------------------------------------
R_min = 0;
R_max = options.MaxR;
if(isStableAt(amp, R_max * angle, options))
    warning('method is stable at max radius');
    return;
end
if(~isStableAt(amp, R_min * angle, options))
    return;
end

% -- run search --------------------------------------------------------------------------------------------------------
continue_search = true;
restarts = 0;
while(continue_search)
    while((R_max - R_min) > options.BisectionTol) % -- run bisection ---------------------------------------------------
        R_mid = (R_max + R_min)/2;
        if(isStableAt(amp, R_mid * angle, options))
            R_min = R_mid;
        else
            R_max = R_mid;
        end
    end
    % -- verify that all R between R_min and 0 are stable, otherwise restart search with new parameters ----------------
    zs = linspace(0, R_min, options.NumPoints) * angle;
    [flags] = isStableAt(amp, zs, options);
    if(all(flags))
        continue_search = false;
        R = R_min;
    else
        restarts = restarts + 1;
        [~, ind] = find(flags == false, 1, 'first');
        R_max    = abs(zs(ind));
        R_min    = 0;
    end
    if(restarts > options.MaxRestarts) % -- terminate if too many restarts
         continue_search = false;
    end    
end
end