classdef BDF_PG < GBDF_PG
    
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
                    Hy.output_sol_inds = B_j;
                    Hy.output_der_inds = j;
            end
            
            ODEP = GBDF_ODESP(Hy);
            
        end
        
    end
    
end
