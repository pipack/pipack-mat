function [int_lens] = rayIntOfAlpha(method, alphas, theta, options)
%THETAOFALPHA computes length of the stability interval of a method along a ray r * exp(i theta) over a range of alphas.
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

if(nargin < 3)
    options = struct();
end
if(isa(method, 'PBM'))
    int_lens = genericOfAlpha(@(method_, alpha_, options_) rayStabilityInt(method_, alpha_, theta, options), method, alphas, options);
elseif(isa(method, 'function_handle'))
    int_lens = genericOfAlpha(@(handle_, options_) rayStabilityInt(handle_, theta, options), method, alphas, options);
else
    error('invalid argument types');
end
end