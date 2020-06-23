% note: only produce derivative values using Adams derivative polynomials.

classdef AdamsDerIVSGenerator < IVSGenerator
    
    properties
        ODEPoly_generator;
        DerNodeSet_generator;
    end
    
    methods
        
        function this = AdamsDerIVSGenerator(options)
            %AdamsDerIVSGENERATOR Constructor for IVS set with only derivative nodes with cooresponding Adams derivative
            % polynomials
            % == Parameters ============================================================================================
            % options (struct) - struct containg optons for method construction. Required Fields:
            %   > "DerNodeSet_generator" (NodeSetGenerator) - nodes for method
            %   > "ODEPoly_generator"    (JQMO_ODEPolyGenerator) - either "E" for explicit or "DI" for diagonally implicit
            % ==========================================================================================================
            this@IVSGenerator(options);
            % -- check for required option fields ----------------------------------------------------------------------
            required_fields = {'ODEPoly_generator', 'DerNodeSet_generator'};
            if(~all(isfield(options, required_fields)))
                error('options requires fields: %s, %s, and %s.', required_fields{:});
            end
            % -- set option fields -------------------------------------------------------------------------------------
            this.ODEPoly_generator = options.ODEPoly_generator;
            this.DerNodeSet_generator = options.DerNodeSet_generator;
        end
        
        % == Set functions =============================================================================================
        
        function set.ODEPoly_generator(this, value)
            if(~isa(value, 'JD_ODEPolynomialGenerator'))
                error('ODEPoly_Generator property must be an JD_ODEPolynomialGenerator');
            else
                this.ODEPoly_generator = value;
            end
        end
        
        function set.DerNodeSet_generator(this, value)
            if(~isa(value, 'NodeSetGenerator'))
                error('NodeSet_generator property must be an NodeSetGenerator');
            else
                this.DerNodeSet_generator = value;
            end
        end
        
    end
    
    methods(Access = protected)
        
        function IVS = generate_(this, l_der, l_sol, DS)
            %GENERATE Generates a BDF method using the local ActiveNodeIndexSet and NodeSet stored in this object.
            % == Parameters ============================================================================================
            % 1. l_der  (integer) - total number of interpolated derivatives
            % 2. l_sol  (integer) - total number of interpolated solution values
            % 3. DS     (ODE_Dataset) - underlying ODE dataset
            % == Returns ===============================================================================================
            % 1. IVS   (InterpolatedValueSet) - Interpolated value set
            % ==========================================================================================================
            
            if(l_sol ~= 0)
                error('This IVS Generator cannot create interpolated solution values');
            end
            
            node_handle = @(alpha) this.DerNodeSet_generator.nodes('all', l_der, alpha);
            
            % -- Create ODE Dataset ------------------------------------------------------------------------------------
            IVS = InterpolatedValueSet();
            IVS.der_tau = node_handle;
            
            % -- Create Active Index Set for Adams Derivative ODE Polynomials ------------------------------------------
            ODE_DP   = cell(l_der, 1);
            ODE_PGen = this.ODEPoly_generator;
            for j = 1 : l_der
                if(isa(ODE_PGen, 'JD_ODEPolynomialGenerator'))
                    ODE_DP{j} = ODE_PGen.generate(j, DS);
                else
                    error('invalid ODEPolyGenerator');
                end
            end
            
            % -- Initialize Method -------------------------------------------------------------------------------------
           IVS.der_polynomials = ODE_DP;
            
        end
        
    end
    
end
