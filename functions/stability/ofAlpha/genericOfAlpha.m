function [result] = genericOfAlpha(F, arg2, alphas, options)
%THETAOFALPHA computes some method property over a range of alphas
% == Parameters ========================================================================================================
%
%       1. F (function_handle) - function for computing property. Will be called as F(method, alpha, options)
%       1. method   (PBM or handle @(alpha)) - method object or a function of alpha that returns a stability function
%       2. alphas   (vector) - extrapolation parameters
%       3. options  (struct) - optional parameter struct (fields described below)
%
%    Options Struct Fields:
%       > NumProcAlpha  (integer)  - alpha values will be distributed over NumProcAlpha processors
%
% == Returns ===========================================================================================================
%       1. thetas - angles of stability for each theta. theta(i) is the angle of stability for alpha = alpha(i).
% ======================================================================================================================

% -- Parse Inputs ------------------------------------------------------------------------------------------------------
if(isa(arg2, 'PBM'))
    arg2_type = 'PBM';
elseif(isa(arg2, 'function_handle'))
    arg2_type = 'function_handle';
else
    error('invalid arguments. second argument must be a PBM or a function_handle');
end
if(nargin < 3)
    options = struct();
end
field_value_pairs = {{'NumProcAlpha', 1}};
options = setDefaultOptions(options, field_value_pairs);
% -- compute data ------------------------------------------------------------------------------------------------------
num_alphas = length(alphas);
n          = options.NumProcAlpha;
if(n > 1 && num_alphas >= n) % -- parallize over alpha -----------------------------------------------------------------
    spmd(n)
        indices = parTaskSplit(num_alphas, n, labindex, 'interleaved');
        num_indices = length(indices);
        result_proc  = zeros(num_indices, 1);
        switch arg2_type
            case 'PBM'
                for i = 1 : num_indices
                    result_proc(i) = F(arg2, alphas(indices(i)), options);
                end
            case 'function_handle'
                for i = 1 : num_indices
                    result_proc(i) = F(arg2(alphas(indices(i))), options);
                end
        end
    end
    result = zeros(1, num_alphas);
    for i = 1 : n
        result(indices{i}) = result_proc{i};
    end
else % -- serial implementation ----------------------------------------------------------------------------------------
    result = zeros(1, num_alphas);
    switch arg2_type
        case 'PBM'
            for i = 1 : num_alphas
                result(i) = F(arg2, alphas(i), options);
            end
            %result = arrayfun(@(a) F(arg2, a, options), alphas);
        case 'function_handle'
            for i = 1 : num_alphas
                result(i) = F(arg2(alphas(i)), options);
            end           
            %result = arrayfun(@(a) F(arg2(a), options), alphas);
    end
end
end