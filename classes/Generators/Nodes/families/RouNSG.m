
% ======================================================================================================================
% Roots of Unity : z(j) = exp(1i * (2 * pi * (j-1)/(q)));
% ======================================================================================================================

classdef RouNSG < NodeSetGenerator
    
    properties(Access = protected)
        node_function_ordering = 'leftsweep'
    end
    
    methods
        
        function this = RouNSG(ordering, precision, options)
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
            if(q > 0)
                z_j = exp(1i * (2 * pi * (j-1)/(q)));
            else
                z_j = 0;
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
            if(q > 0)
                z_j = exp(1i * (2 * vpa('pi') * vpa(j-1)/(q)));
            else
                z_j = vpa(0);
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
            if(q > 0)
                z_j = exp(1i * (2 * sym('pi') * sym(j-1)/(q)));
            else
                z_j = sym(0);
            end
        end
        
    end
    
end
