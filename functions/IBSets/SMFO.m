function [I_j, B_j] = SMFO(j, q, m, ordering)
%SMFO Returns AII set I(j) and set B(j) for method with SMFO type Active Index Sets
% == Parameters ========================================================================================================
% 1. j          (integer) - output index
% 2. q          (integer) - total number of input nodes
% 3. m          (integer) - total number of output nodes
% 4. ordering   (char)    - node ordering
% == Returns =
% 1. I_j (vector) - indices of active input nodes
% 2. B_j (vector) - indices of certain active output nodes. The output set O(j) is given by:
%                       O(j) = B(j) for explict methods
%                       O(j) = B(j) \cup j for diagonally implicit methods.
% ======================================================================================================================

if(mod(q,2) == 0) % set maximum j index after which all inputs have been dropped.
    max_j = q;
else
    max_j = q + 1;
end

if(j > max_j) % only outputs
    output_head_shift = headShift(j - max_j, m, ordering);
    output_tail_shift = tailShift(j, m, ordering);
    % -- form sets I(j) and B(j) ---------------------------------------------------------------------------------------
    I_j = [];
    B_j = output_head_shift : j - output_tail_shift; 
else % inputs and outputs
    input_shift  = headShift(j, q, ordering);
    output_shift = tailShift(j, m, ordering);
    % -- form sets I(j) and B(j) ---------------------------------------------------------------------------------------
    I_j = input_shift : q;
    B_j = 1 : j - output_shift; 
end

end

function output_shift = tailShift(j, n, ordering)
%SMVO Returns input shift for method with SMFO
% == Parameters ========================================================================================================
% 1. j          (integer) - output index
% 2. n          (integer) - total number of input nodes
% 3. ordering   (char)    - node ordering
% == Returns ===========================================================================================================
% 1. shift      (integer) - shift which determines how many tail nodes to drop. If used for outputs, then the set
%                           B(j) = [shift : j - 1]
% ======================================================================================================================

% -- compute input and output shifts -----------------------------------------------------------------------------------
switch ordering
    case 'inwards'
        if(mod(j,2) == 1) % j odd
            output_shift = 1;
        else % j even
            output_shift = 2;
        end
    case 'outwards'
        if(mod(n, 2) == mod(j, 2)) % j, q both even or both odd
            output_shift = 2;
        else
            output_shift = 1;
        end
    otherwise
        error('unsupported ordering');
end
end

function shift = headShift(j, n, ordering)
%SMVO Returns input shift for method with SMFO
% == Parameters ========================================================================================================
% 1. j          (integer) - output index
% 2. n          (integer) - total number of input nodes
% 3. ordering   (char)    - node ordering
% == Returns ===========================================================================================================
% 1. shift      (integer) - shift which determines how many head nodes to drop. If used for inputs, then the AII set is
%                           I(j) = [shift : n]
% ======================================================================================================================

% -- compute input and output shifts -----------------------------------------------------------------------------------
switch ordering
    case 'inwards'
        if(mod(j,2) == 1) % j odd
            shift = j;
        else % j even
            shift = j - 1;
        end
    case 'outwards'
        if(mod(n, 2) == mod(j, 2)) % j, q both even or both odd
            shift = max(1, j-1);
        else
            shift = j;
        end
    otherwise
        error('unsupported ordering');
end
end
