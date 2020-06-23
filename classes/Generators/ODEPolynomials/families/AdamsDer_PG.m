classdef AdamsDer_PG < JD_ODEPolynomialGenerator
    
    properties
        IBSet
    end
    
    properties(Constant)
        valid_IBSet_strs = {'PMFO', 'PMFOmj', 'SMFO', 'SMFOmj', 'SMVO'};
    end
    
    methods
        
        function this = AdamsDer_PG(IBSet)
            %GBDF_PG Initialize a GBDF_PG constructor.
            % == Parameters ============================================================================================
            % 1. IBSet (str) - construction of sets I(j) and B(j). Can be any of the following:
            %                       'PMFO', 'PMFOmj', 'SMFO', 'SMFOmj', or 'SMVO'.
            %
            % 2. type (str)  - type of method. Can be any of the following: 'explicit' or 'diagonally_implicit'.
            % ==========================================================================================================
            
            this.IBSet = IBSet;
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
            
            % -- initialize LF -----------------------------------------------------------------------------------------
            LF = IPoly_AIS();
            LF.input_der_inds  = I_j;
            LF.output_der_inds = B_j;
            ODEP = Adams_ODEDP(LF);
            
        end
        
    end
    
end
