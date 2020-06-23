
% ======================================================================================================================
%   ODEDataset
%
%   A class which represents an ODE Dataset. 
%
%   > Properties
%     1. z_in	  (vector) - input nodes
%     2. z_out    (vector) - output nodes
%     3. c(alpha) (handle) - stage nodes
%
%   > Properties (Computable)
%     1. q  (integer) - number of inputs
%     2. m  (integer) - number of outputs
%     3. s  (integer) - number of stages
%
% ======================================================================================================================

classdef ODE_Dataset < handle
    
    properties
        z_in  = [];
        z_out = [];
        c     = @(a) [];
    end
    
    properties(SetAccess = protected)
        q
        m
        s
        node_ordering
        node_type
    end
    
    methods
         
        function q_ = get.q(this) % number of input nodes 
            q_ = length(this.z_in);
        end
        
        function m_ = get.m(this) % number of output nodes
            m_ = length(this.z_out);
        end
        
        function s_ = get.s(this) % number of stage nodes
            s_ = length(this.c(1));
        end
        
        function no_ = get.node_ordering(this)
            no_in  = nodeOrdering(this.z_in);
            no_out = nodeOrdering(this.z_out);
            
            % -- fix following two problems ----------------------------------------------------------------------------
            %   > node sets with q = 2 can be both inwards and outwards. We only want to return matching ordering
            %   > node sets with q = 1 can have any ordering
            flag_in  = any(strcmp(no_in, {'inwards', 'outwards'}));
            flag_out = any(strcmp(no_out, {'inwards', 'outwards'}));            
            if(this.q == 1 || (this.q == 2 && flag_in && flag_out))
                no_in = no_out;
            elseif(this.m == 1 || (this.m == 2 && flag_in && flag_out))
                no_out = no_in;
            end
            % -- end fix -----------------------------------------------------------------------------------------------
            
            if(strcmp(no_in, no_out))
                no_ = no_in;
            else
                no_ = {no_in, no_out};
            end
        end
        
        function nt_ = get.node_type(this)
            nt_in  = nodeType(this.z_in);
            nt_out = nodeType(this.z_out);
            if(strcmp(nt_in, nt_out))
                nt_ = nt_in;
            else
                nt_ = {nt_in, nt_out};
            end
        end
        
        function set.c(this, val) % ensure that stage nodes are function of alpha
            if(isa(val,'function_handle') && isequal(size(val),[1 1]) && isvector(val(1)))
                this.c = val;
            else
                 error('invalid data type. Requires a one argument function that returns a vector (e.g. @(alpha) [])');
            end
        end
        
        function nv = nodeVector(this, alpha)
            % Returns the full node vector ordered as: inputs, outputs, stages
            nv = vcat(true, this.z_in, this.z_out + alpha, this.c(alpha));
        end
        
        function flag = isNumeric(this)
            % Returns true if all nodes are real, false if symbolic
            if(isnumeric(this.nodeVector(1)))
                flag = true;
            else
                flag = false;
            end
        end
           
    end
end
