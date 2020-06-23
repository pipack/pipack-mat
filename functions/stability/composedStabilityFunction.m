function handle = composedStabilityFunction(methods, composition_weights, alpha)
%AMPMETHODSUM stability function for composition of any number of methods
% == Parameters ========================================================================================================
% 1. methods (cell) - cell array of different methods.
% 2. composition_weights (vector) - weights for the composition
%                                       M(d_1 * alpha) \circ M(d_2 * \alpha) ... \circ M(d_n * \alpha)
%                                   where \sum_{j=1}^n d_j = 1
% 3. alpha   (numeric or sym) - extrapolation parameter
% == Returns ===========================================================================================================
% 1. amp (function_handle) - function handle of one argument (z = r h) for determining stability
% ======================================================================================================================

num_methods = length(methods);
% -- verify composition is valid ---------------------------------------------------------------------------------------
for i = 1 : num_methods - 1
    if(~isequal(methods{i}.ODE_DS.z_out, methods{i+1}.ODE_DS.z_in))
        error('Invalid Composition: method %i z_in is not equal to method $i z_out', i, i + 1);
    end
end
if(~isequal(methods{1}.ODE_DS.z_in, methods{end}.ODE_DS.z_out))
    error('Composition leads to a Coarsener/Refiner.')
end

% -- get block matrices ------------------------------------------------------------------------------------------------
BM = cell(num_methods, 4);
for i = 1 : num_methods
    [A, B, C, D] = methods{i}.blockMatrices(composition_weights(i) * alpha, 'full');
    BM{i,1} = A;
    BM{i,2} = B;
    BM{i,3} = C;
    BM{i,4} = D;
end
handle = @(z) ampComposed(BM, z, alpha);
end


function amp = ampComposed(BM, z, alpha)

P = 1;
I = eye(size(BM{1,1}));

num_methods = size(BM,1);
for i = 1 : num_methods
    
    if(alpha ~= 0) % -- scale z for propagators ------------------------------------------------------------------------
        SM = ((I - BM{i,3} - z / alpha * BM{i,4}) \ (BM{i,1} + z / alpha * BM{i,2}));
    else % -- do not scale z for iterators -----------------------------------------------------------------------------
        SM = ((I - BM{i,3} - z * BM{i,4}) \ (BM{i,1} + z * BM{i,2}));
    end
    P = SM * P;
end

if(any(isnan(P(:))) || any(isinf(P(:)))) % -- check if stability matrix is valid ---------------------------------------
    amp = NaN;
else % -- compute spectrum ---------------------------------------------------------------------------------------------
    amp = max(abs(eig(P)));
end

end

