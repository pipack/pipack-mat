
% ======================================================================================================================
%   NodeSetGenerator
%
%   Abstract class which implements nodes for polynomial coarseners, refiners, and methods. Nodes can be scaled and 
%   translated using the scale_factor and translation_constant. 
%
%   > Properties
%       1. ordering  (char) - node ordering ('leftsweep', 'rightsweep', 'inwards', 'outwards', 'classical')
%       2. precision (char) - node precision ('double' or 'vpa', or 'sym')
%       3. scale_factor ([] or double/vpa/sym or @(alpha)) - optional scale factor for nodes.
%       4. translation_constant ([] or double/vpa/sym or @(alpha)) - optional translation constant for nodes.
%            
%   > Public Methods
%       nodes(j,q,alpha) - computes jth node(s)
%
% ======================================================================================================================

classdef NodeSetGenerator < handle
    
    properties(Constant, Access = protected)
        valid_orderings  = {'leftsweep', 'rightsweep', 'inwards', 'outwards', 'classical', 'rclassical'}
        valid_precisions = {'double', 'vpa', 'sym'}
    end
    
    properties
        ordering
        precision
        scale_factor = [];
        translation_constant = [];
    end
    
    properties(Abstract, Access = protected)
        node_function_ordering;                 % ordering used in dbl_node, vpa_nodes, sym_nodes
    end
    
    methods(Abstract, Access = protected)
        dbl_nodes(this, j, q, alpha, varargin); % double nodes in right-sweeping order
        vpa_nodes(this, j, q, alpha, varargin); % variable precision nodes in right-sweeping order
        sym_nodes(this, j, q, alpha, varargin); % symblic nodes in right-sweeping order
    end
    
    methods
        
        function this = NodeSetGenerator(ordering, precision, options)
            %NODES - Constructor for generic node object without parameters
            % = Parameters =============================================================================================
            %   1. ordering  (char)   - node ordering (e.g. 'leftsweep' or 'inwards')
            %   2. precision (char)   - node precision (e.g. 'double' or 'vpa', or 'sym')
            %   3. options   (struct) -  
            % ==========================================================================================================
            if(nargin < 2)
                options = struct();
            end
            
            this.ordering = ordering;
            this.precision = precision;
            options = setDefaultOptions(options, {{'translation_constant', []}, {'scale_factor', []}});
            this.scale_factor = options.scale_factor;
            this.translation_constant = options.translation_constant;            
        end
        
        function set.ordering(this, ordering)
            % -- validate intputs --------------------------------------------------------------------------------------
            if(ischar(ordering) && any(strcmp(ordering, this.valid_orderings)))
                this.ordering = ordering;
            else
                error(['Invalid Node Ordering. Allowed orderings are: ', strjoin(this.valid_orderings, ',')]);
            end
        end
        
        function set.precision(this, precision)
            % -- validate intputs --------------------------------------------------------------------------------------
            if(ischar(precision) && any(strcmp(precision, this.valid_precisions)))
                this.precision = precision;
            else
                error(['Invalid Node Precision. Allowed precision types are: ', strjoin(this.valid_precisions, ',')]);
            end
        end
        
        function n = nodes(this, j, q, alpha)
            %NODES returns the jth node in the set to q total nodes, with specified ordering
            % = Parameters =============================================================================================
            %   1. j        (integer or vector or 'all') - index or indicies of desired nodes. if 'all' then all nodes
            %                                              are returned.
            %   2. q        (integer) - total number of nodes
            % = Returns ================================================================================================
            %   1. n        (integer) - jth node(s) is set of q total nodes
            % ==========================================================================================================
            
            if(strcmp(j, 'all'))
                j = 1 : q;
            end
            
            j_classical = remapOrderingIndex(j, q, this.ordering, this.node_function_ordering);
            
            if(strcmp(this.precision, 'double'))
                n = this.dbl_nodes(j_classical, q, alpha);
            elseif(strcmp(this.precision, 'vpa'))
                n = this.vpa_nodes(j_classical, q, alpha);
            elseif(strcmp(this.precision, 'sym'))
                n = this.sym_nodes(j_classical, q, alpha);
            end
            
            % -- apply optional scale factor and translation constant --------------------------------------------------
            sfactor = this.extract('scale_factor', alpha);
            if(~isempty(sfactor))
                n = sfactor * n;
            end
            tconstant = this.extract('translation_constant', alpha);
            if(~isempty(tconstant))
                n = n + tconstant;
            end
            
        end
        
    end
     
    methods(Access = protected)
        
        function value = extract(this, field, alpha)
        %EXTRACT STField - helper function for extracting the proper value of the scalar_factor and translation_constant 
        %properties
        
            valid_fields = {'scale_factor', 'translation_constant'};
            if(~any(strcmp(field, valid_fields)))
                error('invalid field');
            end
            
            % -- extract scale factor ----------------------------------------------------------------------------------
            if(isa(this.(field), 'function_handle'))
                value = this.(field)(alpha);
            else
                value = this.(field);
            end
            % -- convert to proper type --------------------------------------------------------------------------------
            if(strcmp(this.precision, 'double'))
                value = double(value);
            elseif(strcmp(this.precision, 'vpa'))
                value = vpa(value);
            elseif(strcmp(this.precision, 'sym'))
                value = sym(value);
            end
            
        end
        
    end
    
end