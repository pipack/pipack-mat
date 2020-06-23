function [I_j, B_j] = SMVO(j, q, m, ordering)
%SMVO Returns AII set I(j) and set B(j) for method with SMVO type Active Index Sets
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

% -- compute input and output shifts -----------------------------------------------------------------------------------
switch ordering
    case 'inwards'
        if(mod(j,2) == 1) % j odd
            output_shift = 1;
        else % j even
            output_shift = 2;
        end
    case 'outwards'
        if(mod(m, 2) == mod(j, 2))
            output_shift = 2;
        else
            output_shift = 1;
        end
    otherwise
        error('unsupported ordering');
end
% -- form sets I(j) and B(j) -------------------------------------------------------------------------------------------
I_j = 1 : q;
B_j = 1 : j - output_shift;
end

