classdef IVSGenerator < handle
    
    properties
        l_der = @(q, m) 0; % function; Returns number of derivative nodes given the number of method inputs q
        l_sol = @(q, m) 0; % function; returns number of solution nodes given the number of method inputs q
    end
    
    methods
        
        function this = IVSGenerator(options)
            if(nargin < 1)
                options = struct();
            end
            options = setDefaultOptions(options, {{'l_der', @(q,m) 0} {'l_sol', @(q,m) 0}});
            this.l_der = options.l_der;
            this.l_sol = options.l_sol;
        end
        
        function IVS = generate(this, DS)
            %GENERATE Returns the an IVS with l_der interpolated derivatives and l_sol interpolated values. This method 
            % wraps the protected method generate_ to ensure  that the calling sequence is identical across subclasses. 
            % Subclases SHOULD NOT override this method.
            % == Parameters ============================================================================================
            % 1. DS    (ODE_Dataset) - underlying ODE dataset
            % == Returns ===============================================================================================
            % 1. IVS   (InterpolatedValueSet) - interpolated value set
            % ==========================================================================================================
            num_der_nodes = this.l_der(DS.q, DS.m);
            num_sol_nodes = this.l_sol(DS.q, DS.m);
            IVS = this.generate_(num_der_nodes, num_sol_nodes, DS);
        end
        
        function set.l_der(this, value)
            if(isa(value, 'function_handle'))
                this.l_der = value;
            else
                error('l_der property must be a function handle @(q, m) -> integer')
            end
        end
        
        function set.l_sol(this, value)
            if(isa(value, 'function_handle'))
                this.l_sol = value;
            else
                error('l_sol property must be a function handle @(q, m) -> integer')
            end
        end
        
    end
    
    methods(Abstract, Access = protected)
        generate_(this, l_der, l_sol, DS); % protected function wrapped by public function generate.  
            %GENERATE Returns the an IVS with l_der interpolated derivatives and l_sol interpolated values. This method 
            % wraps the protected method generate_ to ensure  that the calling sequence is identical across subclasses. 
            % Subclases SHOULD NOT override this method.
            % == Parameters ============================================================================================
            % 1. l_der  (integer) - total number of interpolated derivatives
            % 2. l_sol  (integer) - total number of interpolated solution values
            % 3. DS     (ODE_Dataset) - underlying ODE dataset
            % == Returns ===============================================================================================
            % 1. IVS   (InterpolatedValueSet) - indices of active input nodes
            % ==========================================================================================================
        
    end
    
end
