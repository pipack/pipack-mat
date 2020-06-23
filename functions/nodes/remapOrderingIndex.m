function [j_output] = remapOrderingIndex(j_input, q, input_order, output_order)
%MAPORDERINGINDEX returns the indices of the nodes in output_order which correspond to nodes indexed by
% j_input in the input_order
% = Parameters =============================================================================================
%   j_input        (integer)  - index of current node in input_order order
%   q               (integer) - number of total nodes
%   input_order     (string)  - ordering used for input nodes
%   output_order    (string)  - desired ordering
% = Returns ================================================================================================
%   j_output    (integer or vector) - cooresponding nodes in output_order
% ==========================================================================================================

% -- map From input to classical ordering ------------------------------------------------------------------
j_rclassical = mapFromOrderingToRClassical(j_input, q, input_order);
j_output     = mapFromRClassicalToNewOrdering(j_rclassical, q, output_order);
end