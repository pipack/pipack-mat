function handle = summedStabilityFunction(methods, alpha, weights)
%AMPMETHODSUM stability function for the weighted sum of several methods
% == Parameters ========================================================================================================
% 1. methods (cell) - cell array of different methods.
% 2. alpha   (numeric or sym) - extrapolation parameter
% 3. weights (vector) - weights for the method sum:
%                                       w_1 * M1 + w_2 * M2 + .... + w_n * Mn
%                                   where \sum_{j=1}^n w_j = 1
% == Returns ===========================================================================================================
% 1. amp (function_handle) - function handle of one argument (z = r h) for determining stability
% ======================================================================================================================
num_methods = length(methods);
if(nargin < 4)
    weights = ones(1, num_methods) / num_methods;
end
if(sum(weights) ~= 1)
    warning('weights do not sum to one. Method will likely be inconsistent');
end

BM = cell(num_methods, 4);
for i = 1 : num_methods
    [A, B, C, D] = methods{i}.blockMatrices(alpha, 'full');
    BM{i,1} = A;
    BM{i,2} = B;
    BM{i,3} = C;
    BM{i,4} = D;
end
handle = @(z) ampSum(BM, z, alpha, weights);
end


function amp = ampSum(BM, z, alpha, weights)

S = zeros(size(BM{1,1}));
I = eye(size(BM{1,1}));

num_methods = size(BM,1);
for i = 1 : num_methods
    if(alpha ~= 0) % -- scale z for propagators ------------------------------------------------------------------------
        S = S + weights(i) * ((I - BM{i,3} - z / alpha * BM{i,4}) \ (BM{i,1} + z / alpha * BM{i,2}));
    else % -- do not scale z for iterators -----------------------------------------------------------------------------
        S = S + weights(i) * ((I - BM{i,3} - z * BM{i,4}) \ (BM{i,1} + z * BM{i,2}));
    end
end

if(any(isnan(S(:))) || any(isinf(S(:)))) % -- check if stability matrix is valid ---------------------------------------
    amp = NaN;
else % -- compute spectrum ---------------------------------------------------------------------------------------------
    amp = max(abs(eig(S)));
end

end

