function [int_lens] = reIntOfAlpha(method, alphas, options)
%THETAOFALPHA computes length of the stability interval of a method along a ray -r over a range of alphas.
% == Parameters ========================================================================================================
%
%       1. method   (PBM or handle @(alpha)) - method object or function_handle @(alpha) that returns a stability
%                                              function of the form @(z) 
%       2. alphas   (vector) - extrapolation parameters 
%       3. theta    (real)   - angle of ray in radians measured clockwise from negative real axis. 
%       4. options  (struct) - optional parameter struct (fields described below)
%
%    Options Struct Fields:
%       > NumProcAlpha  (integer)  - alpha values will be distributed over NumProcAlpha processors
%       > all options available to method stabilityRayInt
%
% == Returns ===========================================================================================================
%       1. int_lens - lengths of intervals. int_lens(i) is the interval of stability for alpha = alpha(i).
% ======================================================================================================================

% -- Parse Inputs ------------------------------------------------------------------------------------------------------
if(nargin < 3)
    options = struct();
end
int_lens = rayIntOfAlpha(method, alphas, 0, options);
end