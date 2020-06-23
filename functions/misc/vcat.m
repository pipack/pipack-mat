function output = vcat(output_row_vector, varargin)
%VCAT Concatentates any number of column or row vectors into one large column or row vector  
% = Parameters =========================================================================================================
%   1. output_row_vector (bool) - if true outputs larger row vector, if false outputs large column vector
%   2. varargin          (cell) - any number of column or row vectors
% = Returns ============================================================================================================
%   1. output           (vector) - column or row vector formed by concatenating input vectors
% ======================================================================================================================

column_vector_inputs = cellfun(@(x) x(:), varargin, 'UniformOutput', false);
output = vertcat(column_vector_inputs{:});
if(output_row_vector)
    output = transpose(output);
else
end