% Generates Block Method that can be used with Solver Package

classdef BLKSolverGenerator < handle
    
    properties(Access = protected)
        ctol = 1e-13; % tolerance for comparing two coefficients
    end
    
    properties
        solver_class = @MutableDIBLK    % handle pointing to desired solver class (Must inherit from BLKConst)
        method_generator                % PBM generator for method coefficients of block method.
        extrapolator_generator          % PBM generator for extrolation coefficients of block method.
        output_coefficient_handle       % function handle for generating optional output coefficients of block method.
        name = ''                       % string that holds base name for method (q will appended to name)
    end
     
    methods
        
        function this = BLKSolverGenerator(options)
            
            if(nargin < 1)
                options = struct();
            end
            
            % -- check for required option fields ----------------------------------------------------------------------
            required_fields = {'method_generator'};
            if(~all(isfield(options, required_fields)))
                error('options requires fields: %s and %s.', required_fields{:});
            end
            
            % -- set object fields -------------------------------------------------------------------------------------
            this.method_generator = options.method_generator;
            if(isfield(options, 'extrapolator_generator'))
                this.extrapolator_generator = options.extrapolator_generator;
            end
            if(isfield(options, 'output_coefficient_handle'))
                this.output_coefficient_handle = options.output_coefficient_handle;
            end
            if(isfield(options, 'solver_class'))
                this.solver_class = options.solver_class;
            end
            if(isfield(options, 'name'))
                this.name = options.name;
            end
            
            
        end
        
        % -- set methods to ensure proper types ------------------------------------------------------------------------
        
        function set.method_generator(this, val)
            if(isa(val, 'PBCRGenerator'))
                this.method_generator = val;
            else
                error('method_generator must be of type PBCRGenerator');
            end
        end
        
        function set.extrapolator_generator(this, val)
            if(isa(val, 'PBCRGenerator'))
                this.extrapolator_generator = val;
            else
                error('extrapolator_generator must be of type PBCRGenerator');
            end
        end
        
        function set.output_coefficient_handle(this, val)
            if(~isa(val, 'function_handle'))
                error('output_coefficient_handle must be a function_handle');
            end
            if(nargin(val) ~= 1 || nargout(val) ~= 5)
                error('output_coefficient_handle must accept 1 arguments and produce 5 outputs such that [a,b,c,d,e] = f(struct)');
            end
            this.output_coefficient_handle = val;
        end
        
        function set.solver_class(this, val)
            try
                m = val();
            catch E
                error('unable to instantiate solve_class');
            end
            if(isa(m, 'BLKConst'))
                this.solver_class = val;
            else
                error('solver_class must inherit from BLKConst');
            end
        end
        
        function solver = generate(this, q, alpha, options)
            
            if(nargin == 3)
                options = struct();
            end
            
            solver = this.solver_class(options);
            method = this.method_generator.generate(q);
            z = double(method.ODE_DS.z_out);
            [A, B, C, D] = method.blockMatrices(alpha, 'full_traditional');
            A = double(A); B = double(B); C = double(C); D = double(D);
            
            prop_struct = struct(...
                'starting_times', double(z / alpha), ...
                'A', A, ...
                'B', B, ...
                'C', C, ...
                'D', D, ...
                'conjugate_inputs',    this.computeConjugateInputs(z),                   ...
                'conjugate_outputs',   this.computeConjugateOutputs(z, A, B, C, D),      ...
                'real_valued_outputs', this.computeRealValuedSystemFlags(z, A, B, C, D), ...
                'name',                [this.name, num2str(q)]                           ...
            );
        
            if(~isempty(this.extrapolator_generator))
                 e_method = this.extrapolator_generator.generate(q);
                 [A_extrapolate, B_extrapolate] = e_method.blockMatrices(alpha, 'full_traditional');
                 prop_struct.A_extrapolate  = double(A_extrapolate); 
                 prop_struct.B_extrapolate = double(B_extrapolate);
            end
            
            % -- create struct for computing output coefficients -------------------------------------------------------
            coefficient_struct = struct(...
                'node_ordering',  this.method_generator.NodeSet_generator.ordering, ...
                'node_precision', this.method_generator.NodeSet_generator.precision, ...
                'node_class',     class(this.method_generator.NodeSet_generator), ...
                'z', z, ...
                'q', q, ...
                'alpha', alpha ...
            );
            
            if(~isempty(this.output_coefficient_handle))
                [a_out, b_out, c_out, d_out, e_out] = this.output_coefficient_handle(coefficient_struct);
                prop_struct.a_out = double(a_out);
                prop_struct.b_out = double(b_out); 
                prop_struct.c_out = double(c_out); 
                prop_struct.d_out = double(d_out);
                prop_struct.e_out = double(e_out);
            end
            
            solver.setClassProps(prop_struct);
            
        end
        
    end
    
    
    methods(Access = protected)
        
        % -- functions for determining conjugate inputs and outputs ----------------------------------------------------
        
        function real_system_flags = computeRealValuedSystemFlags(this, z, A, B, C, D)
            
            q   = length(z);
            
            real_system_flags = false(q, 1);
            for i = 1 : q
                flag = abs(imag(z(i))) < this.ctol;
                flag = flag && realCoefficients(A(i, :));
                flag = flag && realCoefficients(B(i, :));
                flag = flag && realCoefficients(C(i, :));
                flag = flag && realCoefficients(D(i, :));
                if(flag)
                    real_system_flags(i) = true;
                end
            end
            
            function flag = realCoefficients(a)
                
                toColumn = @(x) x(:);
                flag     = true;
                
                ai_active_inds = find(abs(a) > this.ctol);
                ai_active = toColumn(a(ai_active_inds));
                zi_active = toColumn(z(ai_active_inds));
                
                if(~isempty(zi_active))
                    % check that for any z_i with coefficient a, there also exists (z_i)^* with coefficient a^*
                    [~, inds] = sort(zi_active, 'ComparisonMethod', 'real');
                    azi       = [zi_active(inds), ai_active(inds)];
                    
                    [~, inds] = sort(conj(zi_active), 'ComparisonMethod', 'real');
                    azi_conj  = conj([zi_active(inds), ai_active(inds)]);
                    
                    diff = azi - azi_conj;
                    flag = max(abs(diff(:))) < this.ctol;
                end
                
            end
            
        end
        
        function conj_flags = computeConjugateInputs(this, z)
            %CONJUGATEINPUTS returns conjugate relationship between inputs
            % -- Returns ---------------------------------------------------------------------------------------------------
            %   conj_flags (vector) - The ith output is conjugate to the output with index conject_flag(i).
            %                         Note: conj_flags(i) can be equal to i
            conj_flags = this.conjugacyFlags(length(z), @(ind) this.getConjInputInds(ind, z));
        end
        
        function conj_flags = computeConjugateOutputs(this, z, A, B, C, D)
            %CONJUGATEOUTPUTS returns conjugate relationship between outputs
            % -- Returns ---------------------------------------------------------------------------------------------------
            %   conj_flags (vector) - The ith output is conjugate to the output with index conject_flag(i).
            %                         Note: conj_flags(i) can be equal to i
            
            conj_flags = this.conjugacyFlags(length(z), @(ind) this.getConjOutputInds(ind, z, A, B, C, D));
        end
        
        function conj_flags = conjugacyFlags(this, q, conj_inds_handle)
            %CONJUGATEOUTPUTS helper function for computing conjugate inputs/outputs/stages
            % -- Parameters ------------------------------------------------------------------------------------------------
            %   conj_inds_handle (vector)
            % -- Returns ---------------------------------------------------------------------------------------------------
            %   conj_flags (vector) - The ith output is conjugate to the output with index conject_flag(i).
            %                         Note: conj_flags(i) can be equal to i
            % --------------------------------------------------------------------------------------------------------------
            
            inds = 1 : q;
            
            conj_flags = zeros(q, 1);
            while(~isempty(inds))
                ind = inds(1);
                conj_inds = setdiff(conj_inds_handle(ind), ind); % get all conjugate indices (excluding self)
                conj_flags(conj_inds) = ind;
                inds = setdiff(inds, [ind; conj_inds(:)]);
            end
            
        end
        
        function conj_inds = getConjInputInds(this, ind, z)
            conj_inds = find(abs(conj(z(ind)) - z) < this.ctol);
        end
        
        function conj_inds = getConjOutputInds(this, ind, z, A, B, C, D)
            
            p         = length(z);
            conj_inds = [];
            for j = 1 : p
                flag = abs(conj(z(ind)) - z(j)) <  this.ctol;
                flag = flag && conjCoeffMatrix(A, ind, j);
                flag = flag && conjCoeffMatrix(B, ind, j);
                flag = flag && conjCoeffMatrix(C, ind, j);
                flag = flag && conjCoeffMatrix(D, ind, j);
                if(flag)
                    conj_inds(end+1) = j;
                end
            end
            
            function flag = conjCoeffMatrix(A, i, j)
                
                toColumn = @(x) x(:);
                
                Ai_active_inds = find(abs(A(i, :)) > this.ctol);
                Aj_active_inds = find(abs(A(j, :)) > this.ctol);
                Ai_active = toColumn(A(i, Ai_active_inds));
                Aj_active = toColumn(A(j, Aj_active_inds));
                zi_active = toColumn(z(Ai_active_inds));
                zj_active = toColumn(z(Aj_active_inds));
                flag = length(zi_active) == length(zj_active);
                
                if(flag && ~isempty(zi_active))
                    % check that for any z_i with coefficient a, there also exists (z_i)^* with coefficient a^*
                    [~, inds] = sort(conj(zi_active), 'ComparisonMethod', 'real');
                    Azi       = conj([zi_active(inds), Ai_active(inds)]);
                    
                    [~, inds] = sort(zj_active, 'ComparisonMethod', 'real');
                    Azj       = [zj_active(inds), Aj_active(inds)];
                    
                    diff   = Azi - Azj;
                    flag = flag && max(abs(diff(:))) < this.ctol;
                end
                
            end
            
        end
        
    end
    
end
