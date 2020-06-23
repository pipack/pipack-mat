classdef Adams_PG < JD_ODEPolynomialGenerator
    
    properties
        Ly_IBSet
        LF_IBSet
        EP_generator
        type
    end
    
    properties(Constant)
        valid_IBSet_strs = {'PMFO', 'PMFOmj', 'SMFO', 'SMFOmj', 'SMVO'};
        valid_type_strs  = {'explicit', 'diagonally_implicit'};
    end
    
    methods
        
        function this = Adams_PG(Ly_IBSet, LF_IBSet, EP_generator, type)
            %GBDF_PG Initialize a Adams_PG constructor.
            % == Parameters ============================================================================================
            % 1. Ly_IBSet (str) - construction of sets I(j) and B(j) for the polynomial L_y(\tau). Can be any of the 
            %                     following: 'PMFO', 'PMFOmj', 'SMFO', 'SMFOmj', or 'SMVO'.
            % 2. Ly_IBSet (str) - construction of sets I(j) and B(j) for the polynomial L_y(\tau). Can be any of the 
            %                     following: 'PMFO', 'PMFOmj', 'SMFO', 'SMFOmj', or 'SMVO'.
            %
            % 3. EP_generator (ExpansionPointGenerator) 
            %
            % 4. type (str)  - type of method. Can be any of the following: 'explicit' or 'diagonally_implicit'.
            % ==========================================================================================================
            
            this.Ly_IBSet = Ly_IBSet;
            this.LF_IBSet = LF_IBSet;
            this.EP_generator = EP_generator;
            this.type = type;
        end
        
        function set.EP_generator(this, value)
            if(isa(value, 'JD_ExpansionPointGenerator'))
                this.EP_generator = value;
            else
                error('ExpansionPointGenerator prpoerty')
            end
        end
        
        function set.type(this, value)
            if(any(strcmp(value, this.valid_type_strs)))
                this.type = value;
            else
                error(['invalid type. Possible options are: ', sprintf('%s, ', this.valid_type_strs{:})])
            end
        end
        
        function set.Ly_IBSet(this, value)
            if(any(strcmp(value, this.valid_IBSet_strs)))
                this.Ly_IBSet = value;
            else
                error(['invalid IBSet. Possible options are: ', sprintf('%s, ', this.valid_IBSet_strs{:})])
            end
        end
        
        function set.LF_IBSet(this, value)
            if(any(strcmp(value, this.valid_IBSet_strs)))
                this.LF_IBSet = value;
            else
                error(['invalid IBSet. Possible options are: ', sprintf('%s, ', this.valid_IBSet_strs{:})])
            end
        end
        
    end
    
    methods(Access = protected)
        
        function ODEP = generate_(this, j, DS)
            %GENERATE_
            % == Parameters ============================================================================================
            % 1. j          (integer) - output index
            % 2. q          (integer) - total number of input nodes
            % 3. m          (integer) - total number of output nodes
            % 4. ordering   (char)    - node ordering
            % 5. b   	    (double)  - expansion point
            % == Returns ===============================================================================================
            % 1. ODEP (GBDF_ODESP) - indices of active input nodes
            % ==========================================================================================================
            
            % -- compute sets L_y and L_F ------------------------------------------------------------------------------
            Ly = this.generateLy(j, DS.q, DS.m, DS.node_ordering, this.Ly_IBSet);
            LF = this.generateLF(j, DS.q, DS.m, DS.node_ordering, this.LF_IBSet);
            % -- compute expansion point -------------------------------------------------------------------------------
            b = this.EP_generator.generate(j, DS);
            % -- initilize Adams ODE polynomial ------------------------------------------------------------------------
            ODEP = Adams_ODESP(Ly, LF, b);
            
        end
        
        function Ly = generateLy(~, j, q, m, ordering, IBSet)
            %GENERATE_
            % == Parameters ============================================================================================
            % 1. j          (integer) - output index
            % 2. q          (integer) - total number of input nodes
            % 3. m          (integer) - total number of output nodes
            % 4. ordering   (char)    - node ordering
            % 5. IBSET      (char)    - specify how to construct sets I(j) and B(j). Must be one of the following:
            %                           PMFO, PMFOmj, SMFO, SMFOmj, and SMVO.
            % == Returns ===============================================================================================
            % 1. LF (IPoly_AIS) - polynomial active index set for LF
            % ==========================================================================================================
            
            % -- compute sets I(j) and B(j) ----------------------------------------------------------------------------
            switch IBSet
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
            
            % -- initialize Ly -----------------------------------------------------------------------------------------
            Ly = IPoly_AIS();
            Ly.input_sol_inds  = I_j;
            Ly.output_sol_inds = B_j;
            
        end
        
        function LF = generateLF(this, j, q, m, ordering, IBSet)
            %GENERATE_
            % == Parameters ============================================================================================
            % 1. j          (integer) - output index
            % 2. q          (integer) - total number of input nodes
            % 3. m          (integer) - total number of output nodes
            % 4. ordering   (char)    - node ordering
            % 5. IBSET      (char)    - specify how to construct sets I(j) and B(j). Must be one of the following:
            %                           PMFO, PMFOmj, SMFO, SMFOmj, and SMVO.
            % == Returns ===============================================================================================
            % 1. LF (IPoly_AIS) - polynomial active index set for LF
            % ==========================================================================================================
            
            % -- compute sets I(j) and B(j) ----------------------------------------------------------------------------
            switch IBSet
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
            
            switch this.type
                case 'explicit'
                    LF.output_der_inds = B_j;
                case 'diagonally_implicit'
                    LF.output_der_inds = [B_j, j];
            end
            
        end
        
    end
    
end
