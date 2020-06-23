
% ======================================================================================================================
%   InterpolatedValueSet
%
%   A class which represents an interpolated value set. 
%
%   > Properties
%
%     1. sol_tau            (handle)     - nodes for interpolated solution values. If handle must be a function of alpha
%                                          that returns vector of nodes.
%     2. sol_polynomials    (cell array) - cell array contining ODE polynomial objects
%     3. der_tau            (handle)     - nodes for interpolated derivatives values. If handle must be a function of 
%                                          alpha that returns vector of nodes.
%     4. der_polynomials    (cell array) - cell array contining ODE derivative polynomial objects
%
% ======================================================================================================================

classdef InterpolatedValueSet < handle
    
    properties
        sol_tau  = @(alpha) [];
        sol_polynomials = {};
        der_tau  = @(alpha) [];
        der_polynomials = {};
    end
    
    methods
        
        % -- Set Methods -----------------------------------------------------------------------------------------------
        
        function set.sol_polynomials(this, val) 
            check_type = @(e) isa(e, 'ODE_Polynomial');
            if(iscell(val) && all(cellfun(check_type, val)))
                this.sol_polynomials = val;
            else
                error('invalid data type. Must be a cell array containing ODEPolynomial objects');
            end  
        end
        
        function set.der_polynomials(this, val)
            check_type = @(e) isa(e, 'ODE_DerivativePolynomial');
            if(iscell(val) && all(cellfun(check_type, val)))
                this.der_polynomials = val;
            else
                 error('invalid data type. Must be a cell array containing ODEDerivativePolynomial objects');
            end
        end
        
        function set.sol_tau(this, val)
            if(isa(val,'function_handle') && isequal(size(val),[1 1]) && (isvector(val(1)) || isempty(val(1))))
                this.sol_tau = val;
            else
                 error('invalid data type. Requires a one argument function that returns a vector (e.g. @(alpha) [])');
            end
        end
        
        function set.der_tau(this, val)
            if(isa(val,'function_handle') && isequal(size(val),[1 1]) && (isvector(val(1)) || isempty(val(1))))
                this.der_tau = val;
            else
                 error('invalid data type. Requires a one argument function that returns a vector (e.g. @(alpha) [])');
            end
        end
        
        % -- Public Methods -----------------------------------------------------------------------------------------------
        
        function nv = nodeVector(this, alpha)
             % Returns the full node vector ordered as: solution, derivatives
            nv = vcat(false, this.sol_tau(alpha), this.der_tau(alpha));
        end
        
        function [YI, YO, YS, FI, FO, FS, clean_exit] = coefficientMatrices(this, type, alpha, DS)
            
            if(isnumeric(this.nodeVector(alpha)))
                emptyMatrix = @(m,n) zeros(m,n);
            else
                emptyMatrix = @(m,n) sym(zeros(m,n));
            end
            
            switch type
                case 'solution'
                    ode_ps = this.sol_polynomials;
                    tau = this.sol_tau(alpha);
                case 'derivative'
                    ode_ps = this.der_polynomials;
                    tau = this.der_tau(alpha);            
                otherwise
                    error('invalid type; must be either "solution" or "derivative".');
            end
            
            clean_exit = true;
            n = length(tau);
            YI = emptyMatrix(n, DS.q);
            YO = emptyMatrix(n, DS.m);
            YS = emptyMatrix(n, DS.s);
            FI = emptyMatrix(n, DS.q);
            FO = emptyMatrix(n, DS.m);
            FS = emptyMatrix(n, DS.s);
            
            for i = 1 : n
                [YI(i,:), YO(i,:), YS(i,:), FI(i,:), FO(i,:), FS(i,:), exit_flag] = ode_ps{i}.coefficients(tau(i), alpha, DS, []);
                clean_exit = clean_exit & exit_flag;
            end
            
        end
                
        function [input_indices, stage_indices, output_indices] = activeIndexSets(this, type, alpha, DS)
            
            switch type
                case 'solution'
                    ode_ps = this.sol_polynomials;
                    n = length(this.sol_tau(alpha));
                case 'derivative'
                    ode_ps = this.der_polynomials;
                    n = length(this.der_tau(alpha));
                otherwise
                    error('invalid type; must be either "solution" or "derivative".');
            end
            
            input_indices  = cell(n, 1);
            stage_indices  = cell(n, 1);
            output_indices = cell(n, 1);
            
            for i = 1 : n
                [input_indices{i}, stage_indices{i}, output_indices{i}] = ode_ps{i}.ActiveNodeIndexSet(alpha, DS, []);
            end
        end
        
        function polynomialDiagram(this, DS, layout_options)
            
            if(nargin < 3)
                layout_options = struct();
            end
            layout_options = setDefaultOptions(layout_options, {{'FigureIndex', []}});
            
            num_sol_tau = length(this.sol_tau(1));
            num_der_tau = length(this.der_tau(1));
            sp_width = max(num_sol_tau, num_der_tau);
            sp_height = 2;
            
            if(sp_width > 0)                
                if(isempty(layout_options.FigureIndex))
                    layout_options.FigureIndex = get(figure(), 'Number');
                end
                
                for i = 1 : num_sol_tau
                    subplot(sp_height, sp_width, i);
                    this.sol_polynomials{i}.polynomialDiagram(DS, [], struct(), layout_options);
                    title(['$\tilde{y}_', num2str(i), '$'], 'Interpreter', 'latex');
                end
                
                for i = 1 : num_der_tau
                    subplot(sp_height, sp_width, i + sp_width);
                    this.der_polynomials{i}.polynomialDiagram(DS, [], struct(), layout_options);
                    title(['$\tilde{f}_', num2str(i), '$'], 'Interpreter', 'latex');
                end
            end
            
        end
     
    end
end
