classdef PBCRGenerator < APBCRGenerator
    
    properties
        ODEPoly_generator;
        NodeSet_generator;
        IVS_generator = [];
    end
    
    methods
        
        function this = PBCRGenerator(options)
            %PBMGENERATOR Constructor for BDF PBM Generator.
            % == Parameters ============================================================================================
            % options (struct) - struct containg optons for method construction. Required Fields:
            %   > "ODEPoly_generator"   (JD_ODEPolynomialGenerator) - generator for methods ODE polynomials
            %   > "NodeSet_generator"   (NodeSet) - nodes generator for method
            %   > "IVS_generator"       (IVSGenerator) - optional generator for any interpolated value set
            % ==========================================================================================================
            
            if(nargin < 1)
                options = struct();
            end
            
            % -- check for required option fields ----------------------------------------------------------------------
            required_fields = {'ODEPoly_generator', 'NodeSet_generator'};
            if(~all(isfield(options, required_fields)))
                error('options requires fields: %s and %s.', required_fields{:});
            end
            % -- set option fields -------------------------------------------------------------------------------------
            this.ODEPoly_generator = options.ODEPoly_generator;
            this.NodeSet_generator = options.NodeSet_generator;
            if(isfield(options, 'IVS_generator'))
                this.IVS_generator = options.IVS_generator;
            end
        end
        
        function set.ODEPoly_generator(this, value)
            if(~isa(value, 'JD_ODEPolynomialGenerator'))
                error('ODEPoly_Generator property must be an JD_ODEPolynomialGenerator');
            else
                this.ODEPoly_generator = value;
            end
        end
        
        function set.NodeSet_generator(this, value)
            % allow for either a NodeSetGenerator or a 2x1 cell of 2 NodeSetGenerators
            type_check_a = iscell(value) && length(value) == 2 && all(cellfun(@(e) isa(e, 'NodeSetGenerator'), value));
            type_check_b = isa(value, 'NodeSetGenerator');
            if(type_check_a || type_check_b)
                this.NodeSet_generator = value;
            else
                error('NodeSet_generator property must be an NodeSetGenerator or a 2x1 cell of NodeSetGEnerators for input and output nodes');
            end
        end
        
        function set.IVS_generator(this, value)
            if(~isa(value, 'IVSGenerator'))
                error('IVS_generator property must be an IVSSetGenerator');
            else
                this.IVS_generator = value;
            end
        end
        
    end
    
    methods(Access = protected)
        
        function method = generate_(this, q, m)
            %GENERATE_ Generates a polynomial block coursener/refiner using the generators stored in this object.
            % == Parameters ============================================================================================
            % 1. q (integer) - number of input nodes.
            % 2. m (integer) - number of output nodes.
            % == Returns ===============================================================================================
            % 1. method (GBDF_PBM) - a GBDF type polynomial block method.
            % ==========================================================================================================
            
            [DS, IVS] = this.generateDS(q, m);
            [ODE_SP]   = this.generateODESP(m, DS);
            
            % -- classify type of method and initize appropriate class -------------------------------------------------
            only_adams_polynomials = all(cellfun(@(e) isa(e, 'Adams_ODESP'), ODE_SP));
            only_gbdf_polynomials  = all(cellfun(@(e) isa(e, 'GBDF_ODESP'), ODE_SP));
            
            if(q == m) % -- block method  ------------------------------------------------------------------------------
                if(only_adams_polynomials)
                    method = Adams_PBM(struct('ODE_DS', DS, 'IVS', IVS, 'ODE_SP', {ODE_SP}));
                elseif(only_gbdf_polynomials)
                    method = GBDF_PBM(struct('ODE_DS', DS, 'IVS', IVS, 'ODE_SP', {ODE_SP}));
                else
                    method = PBM(struct('ODE_DS', DS, 'IVS', IVS, 'ODE_SP', {ODE_SP}));
                end
            else % -- block coarsener and refiner ----------------------------------------------------------------------
                if(only_adams_polynomials)
                    method = Adams_PBCR(struct('ODE_DS', DS, 'IVS', IVS, 'ODE_SP', {ODE_SP}));
                elseif(only_gbdf_polynomials)
                    method = GBDF_PBCR(struct('ODE_DS', DS, 'IVS', IVS, 'ODE_SP', {ODE_SP}));
                else
                    method = PBCR(struct('ODE_DS', DS, 'IVS', IVS, 'ODE_SP', {ODE_SP}));
                end
            end
            
        end
        
        function [DS, IVS] = generateDS(this, q, m)
            % GENERATEDS initializes the ode dataset and any cooresponding IVS for the polynomial block method
            % == Parameters ============================================================================================
            % 1. q   (integer) - total number of input nodes
            % 2. m   (integer) - total number of output nodes
            % == Returns ===============================================================================================
            % 1. DS  (ODE_Dataset) - ODE dataset of method
            % ==========================================================================================================
            
            % -- set node set generators -------------------------------------------------------------------------------
            if(iscell(this.NodeSet_generator))
                z_in_generator  = this.NodeSet_generator{1};
                z_out_generator = this.NodeSet_generator{2};
            else
                z_in_generator  = this.NodeSet_generator;
                z_out_generator = this.NodeSet_generator;
            end
            
            if(~strcmp(z_in_generator.ordering, z_out_generator.ordering))
                error('z_in and z_out generators have different node orderings.');
            end
            
            z_in_nodes  = z_in_generator.nodes('all', q, []);
            z_out_nodes = z_out_generator.nodes('all', m, []);
            
            % -- Create ODE Dataset ------------------------------------------------------------------------------------
            DS = ODE_Dataset();
            DS.z_in  = z_in_nodes;
            DS.z_out = z_out_nodes;
            
            % -- Create Interpolated Value Set -------------------------------------------------------------------------
            if(isempty(this.IVS_generator))
                IVS = InterpolatedValueSet();
            else
                IVS = this.IVS_generator.generate(DS);
            end
            
        end
        
        function [ODE_SP] = generateODESP(this, m, DS)
            % GENERATEODESP initializes the ode solution polynomials for each output of the polynomial block method
            % == Parameters ============================================================================================
            % 1. m   (integer) - total number of output nodes
            % 2. DS  (ODE_Dataset) - ODE dataset of methods
            % == Returns ===============================================================================================
            % 1. ODESP  (cell) - a cell array of ODE solution polynomials
            % ==========================================================================================================
            
            ODE_SP   = cell(m, 1);
            ODE_PGen = this.ODEPoly_generator;
            for j = 1 : m
                if(isa(ODE_PGen, 'JD_ODEPolynomialGenerator'))
                    ODE_SP{j}  = ODE_PGen.generate(j, DS);
                else
                    error('invalid ODEPolyGenerator');
                end
            end
            
        end
        
    end
    
end
