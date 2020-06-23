function [I_j, B_j] = PMFOmj(j, q, m, ordering)
%PMFOMJ Returns AII set I(j) and set B(j) for method with PMFOmj type Active Index Sets
% == Parameters ========================================================================================================
% 1. j          (integer) - output index
% 2. q          (integer) - total number of input nodes
% 3. m          (integer) - total number of output nodes
% 4. ordering   (char)    - node ordering
% == Returns ===========================================================================================================
% 1. I_j (vector) - indices of active input nodes
% 2. B_j (vector) - indices of certain active output nodes. The output set O(j) is given by:
%                       O(j) = B(j) for explict methods
%                       O(j) = B(j) \cup j for diagonally implicit methods.
% ======================================================================================================================

% -- form sets I(j) and B(j) -------------------------------------------------------------------------------------------
[I_j, B_j] = PMFO(j, q, m, ordering);
I_j = setdiff(I_j, j);
end