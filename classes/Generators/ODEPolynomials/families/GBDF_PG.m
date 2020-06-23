classdef GBDF_PG < JD_ODEPolynomialGenerator
    
    properties
        IBSet
        type
    end
    
    properties(Constant)
        valid_IBSet_strs = {'PMFO', 'PMFOmj', 'SMFO', 'SMFOmj', 'SMVO'};
        valid_type_strs  = {'explicit', 'diagonally_implicit'};
    end
    
    methods
        
        function this = GBDF_PG(IBSet, type)
            %GBDF_PG Initialize a GBDF_PG constructor.
            % == Parameters ============================================================================================
            % 1. IBSet (str) - construction of sets I(j) and B(j). Can be any of the following: 
            %                       'PMFO', 'PMFOmj', 'SMFO', 'SMFOmj', or 'SMVO'.
            %
            % 2. type (str)  - type of method. Can be any of the following: 'explicit' or 'diagonally_implicit'.
            % ==========================================================================================================
            
            this.IBSet = IBSet;
            this.type  = type;
        end
        
        function set.type(this, value)
            if(any(strcmp(value, this.valid_type_strs)))
                this.type = value;
            else
                error(['invalid type. Possible options are: ', sprintf('%s, ', this.valid_type_strs{:})])
            end
        end
        
        function set.IBSet(this, value)
            if(any(strcmp(value, this.valid_IBSet_strs)))
                this.IBSet = value;
            else
                error(['invalid IBSet. Possible options are: ', sprintf('%s, ', this.valid_IBSet_strs{:})])
            end
        end
        
    end
    
    methods(Access = protected)
        
        function ODEP = generate_(this, j, DS)
            %GENERATE_
            % == Parameters ============================================================================================
            % 1. j          (integer)     - output index 
            % 2. DS         (ODE_Dataset) - underlying ODE dataset
            % 3. alpha      (real)        - extrapolation factor
            % == Returns ===============================================================================================
            % 1. ODEP (ODE_Polynomial) - ode polynomial generated from parameters
            % ==========================================================================================================
            
            % -- read parameter from DS --------------------------------------------------------------------------------
            q = DS.q;
            m = DS.m;
            ordering = DS.node_ordering;
            
            % -- compute sets I(j) and B(j) ----------------------------------------------------------------------------
            switch this.IBSet
                case 'PMFO'
                    [I_j, B_j] = PMFO(j, q, m, ordering);
                case 'PMFOmj'
                    [I_j, B_j] = PMFOmj(j, q, m, ordering);
                case 'SMFO'
                    [I_j, B_j] = SMFO(j, q, m, ordering);
                case 'SMFOmj'
                    [I_j, B_j] = SMFOmj(j, q, m, ordering);
                case 'SMVO'
                    [I_j, B_j] = SMVO(j, q, m, ordering);
            end
            
            % -- initialize Hy -----------------------------------------------------------------------------------------
            Hy = IPoly_AIS();
            Hy.input_sol_inds = I_j;
            
            switch this.type
                case 'explicit'
                    Hy.output_der_inds = B_j;
                    Hy.interp_der_inds = j;
                case 'diagonally_implicit'
                    Hy.output_der_inds = [B_j, j];
            end
            
            ODEP = GBDF_ODESP(Hy);
            
        end
        
    end
    
end
