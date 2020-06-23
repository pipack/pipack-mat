function [thetas] = thetaOfAlpha(method, alphas, options)
%THETAOFALPHA computes a method's A(theta) stability over a range of alphas
% == Parameters ========================================================================================================
%
%       1. method   (PBM or handle @(alpha)) - method object or function_handle @(alpha) that returns a stability
%                                              function of the form @(z) 
%       2. alphas   (vector) - extrapolation parameters 
%       3. options  (struct) - optional parameter struct (fields described below)
%
%    Options Struct Fields:
%       > NumProcAlpha  (integer)  - alpha values will be distributed over NumProcAlpha processors                             
%
% == Returns ===========================================================================================================
%       1. thetas - angles of stability for each theta. theta(i) is the angle of stability for alpha = alpha(i).
% ======================================================================================================================

if(nargin < 3)
    options = struct();
end
thetas = genericOfAlpha(@stabilityTheta, method, alphas, options);
end