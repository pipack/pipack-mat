
% ======================================================================================================================
% Imaginary Chebyshev Nodes : z(j) = -1i * cos(pi*(j-1)/(q-1))
% ======================================================================================================================

classdef IChebNSG < ChebNSG
    
	methods
        
        function this = IChebNSG(ordering, precision, options)
            %NODES - Constructor for generic node object without parameters
            % = Parameters =============================================================================================
            %   1. ordering  (char) - node ordering (e.g. 'leftsweep' or 'inwards')
            %   2. precision (char) - node precision (e.g. 'double' or 'vpa', or 'sym')
            % ==========================================================================================================
            % -- validate intputs --------------------------------------------------------------------------------------
            if(nargin < 3)
                options = struct();
            end
            this = this@ChebNSG(ordering, precision, options);
            this.node_function_ordering = 'rclassical';
        end
        
    end
        
	methods(Access = protected)
        
        function [z_j] = dbl_nodes(this, j, q, ~)
            % = Parameters =============================================================================================
            %   1. j        (integer or vector) - index or indicies of desired nodes
            %   2. q        (integer) - total number of nodes
            %   3. varargin (cell)    - additional arguments
            % = Returns ================================================================================================
            %   1. z_j      (integer) - jth node(s) is set of q total nodes in double precision
            % ==========================================================================================================
            z_j = 1i * dbl_nodes@ChebNSG(this, j, q, []);
        end
        
        function [z_j] = vpa_nodes(this, j, q, ~)
            % = Parameters =============================================================================================
            %   1. j        (integer or vector) - index or indicies of desired nodes
            %   2. q        (integer) - total number of nodes
            %   3. varargin (cell)    - additional arguments
            % = Returns ================================================================================================
            %   1. z_j      (integer) - jth node(s) is set of q total nodes in variable precision arithmatic
            % ==========================================================================================================
            z_j = vpa(1i) * vpa_nodes@ChebNSG(this, j, q, []);
        end
        
        function [z_j] = sym_nodes(this, j, q, ~)
            % = Parameters =============================================================================================
            %   1. j        (integer or vector) - index or indicies of desired nodes
            %   2. q        (integer) - total number of nodes
            %   3. varargin (cell)    - additional arguments
            % = Returns ================================================================================================
            %   1. z_j      (integer) - jth node(s) is set of q total nodes in symbolic arithmatic
            % ==========================================================================================================
            z_j = sym('1i') * sym_nodes@ChebNSG(this, j, q, []);
        end
    end
end

