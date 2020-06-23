
% ======================================================================================================================
% Equispaced Nodes : z(j) = -1 + 2*((j-1)/(q-1)) Union {0}
% ======================================================================================================================

classdef EquiZeroNSG < NodeSetGenerator
    
    properties(Access = protected)
        node_function_ordering = 'leftsweep'
    end
    
    methods
        
        function this = EquiZeroNSG(ordering, precision, options)
            %NODES - Constructor for generic node object without parameters
            % = Parameters =============================================================================================
            %   1. ordering  (char) - node ordering (e.g. 'leftsweep' or 'inwards')
            %   2. precision (char) - node precision (e.g. 'double' or 'vpa', or 'sym')
            % ==========================================================================================================
            % -- validate intputs --------------------------------------------------------------------------------------
            if(nargin < 3)
                options = struct();
            end
            this = this@NodeSetGenerator(ordering, precision, options);
        end
        
    end
    
    methods(Access = protected)
        
        function [z_j] = dbl_nodes(~, j, q, varargin)
            % = Parameters =============================================================================================
            %   1. j        (integer or vector) - index or indicies of desired nodes
            %   2. q        (integer) - total number of nodes
            %   3. varargin (cell)    - additional arguments
            % = Returns ================================================================================================
            %   1. z_j      (integer) - jth node(s) is set of q total nodes in double precision
            % ==========================================================================================================
            if(q == 0)
                z_j = [];
            elseif(mod(q, 2) == 1)                
                qh      = q - 1;
                j_left  = 1:qh/2;
                j_right = qh/2 + 1:qh;               
                z_all   = [-1 + 2*((j_left-1)/(qh-1)), 0, -1 + 2*((j_right-1)/(qh-1))];
                z_j     = z_all(j);
            else
                error('The node set only supports odd number of nodes');
            end
        end
        
        function [z_j] = vpa_nodes(~, j, q, varargin)
            % = Parameters =============================================================================================
            %   1. j        (integer or vector) - index or indicies of desired nodes
            %   2. q        (integer) - total number of nodes
            %   3. varargin (cell)    - additional arguments
            % = Returns ================================================================================================
            %   1. z_j      (integer) - jth node(s) is set of q total nodes in variable precision arithmatic
            % ==========================================================================================================
            if(q == 0)
                z_j = [];
            elseif(mod(q, 2) == 1)                
                qh      = q - 1;
                j_left  = 1:qh/2;
                j_right = qh/2 + 1:qh;               
                z_all   = [-1 + 2*(vpa(j_left-1)/vpa(qh-1)), 0, -1 + 2*(vpa(j_right-1)/vpa(qh-1))];
                z_j     = z_all(j);
            else
                error('The node set only supports odd number of nodes');
            end
        end
        
        function [z_j] = sym_nodes(~, j, q, varargin)
            % = Parameters =============================================================================================
            %   1. j        (integer or vector) - index or indicies of desired nodes
            %   2. q        (integer) - total number of nodes
            %   3. varargin (cell)    - additional arguments
            % = Returns ================================================================================================
            %   1. z_j      (integer) - jth node(s) is set of q total nodes in symbolic arithmatic
            % ==========================================================================================================
            if(q == 0)
                z_j = [];
            elseif(mod(q, 2) == 1)                
                qh      = q - 1;
                j_left  = 1:qh/2;
                j_right = qh/2 + 1:qh;               
                z_all   = [-1 + 2*(sym(j_left-1)/sym(qh-1)), 0, -1 + 2*(sym(j_right-1)/sym(qh-1))];
                z_j     = z_all(j);
            else
                error('The node set only supports odd number of nodes');
            end
        end
    end
end
