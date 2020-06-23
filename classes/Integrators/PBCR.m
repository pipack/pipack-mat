
% ======================================================================================================================
%   PBCR (Polynomial Block Coarsener and Refiners) 
%
%   A class which implements basic methods for polynomial block coarseners and refiners, and stores important properties
%   such as ODE dataset, any Interpolated Value set and the ODE polynomials for determining the outputs. 
%
%   > Properties
%       1. ODE_DS (ODE_Dataset) - ODE dataset for method
%       2. ODE_SP (cell) - cell array of ODE solution polynomials for computing the outputs
%       3. IVS    (InterpolateValueSet) - any interpolated value set associated with the ODE dataset.
%
%   > Public Methods
%       1. blockMatrices   - computes block matricies for a coarsener or refiner
%       2. realInputNodes  - determines which inputs are real-valued
%       3. realOutputNodes - determines which outputs are real-valued
%
% ======================================================================================================================

classdef PBCR < handle
    
    properties
        ODE_DS = ODE_Dataset();
        ODE_SP = {};
        IVS    = InterpolatedValueSet();
    end
    
    methods
        
        function this = PBCR(param_struct)
            %PBCR Constructor
            % = Parameters =============================================================================================
            %   1. param_struct  (struct) - optional struct with fields
            %           > "ODE_DS" (ODE Dataset) - ODE dataset for method
            %           > "IVS"    (InterpolateValueSet) - Any interpolated value set associated with the ODE dataset.
            %           > "ODE_SP" (cell) - cell array of ODE solution polynomials for method
            % ==========================================================================================================
            
            fields = {'ODE_DS', 'IVS', 'ODE_SP'};
            function setField(obj, par_struc, field)
                if(isfield(par_struc, field))
                    obj.(field) = par_struc.(field);
                end
            end
            
            if(nargin > 0)
                cellfun(@(f) setField(this, param_struct, f), fields);
            end
            
        end
        
        % -- Set Methods -----------------------------------------------------------------------------------------------
        
        function set.ODE_DS(this, val)
            if(this.validODE_Dataset(val)) 
                this.ODE_DS = val;
            end
        end
        
        function set.IVS(this, val)
            if(this.validIVS(val)) 
                this.IVS = val;
            end
        end
        
        function set.ODE_SP(this, val)
            if(this.validODE_SP(val))
                this.ODE_SP = val;
            end
        end
        
        % -- Public Methods --------------------------------------------------------------------------------------------
                
        function [A, B, C, D, clean_exit] = blockMatrices(this, alpha, format)
            %BLOCKMATRICES computes block matricies for a method of the form:
            % y^{[n+1]} = A(alpha) * y^{[n]} + r * B(alpha) * f^{[n]} + C(alpha) * y^{[n+1]} + r * D(alpha) * f^{[n+1]}
            % = Parameters =============================================================================================
            %   1. alpha    (real) - extrapolation factor
            %   2. format   (str)  - 'full' or 'compact' or 'full_traditional' or 'compact_traditional':
            %
            %                           if 'full' matrices scale with r so that
            %                               y^[n+1] = Ay^[n] + r * Bf^[n] + Cy^[n+1] + r * Df^[n+1]
            %
            %                           if 'compact' matrices scale with r so that
            %                               y^[n+1] = Ay^[n] + r * Bf^[n] + r * Cf^[n+1]
            %
            %                           if 'full_traditional', then matrices scale with h, so that
            %                               y^[n+1] = Ay^[n] + h * Bf^[n] + Cy^[n+1] + h * Df^[n+1]
            %
            %                           if 'compact_traditional', then matrices scale with h, so that
            %                               y^[n+1] = Ay^[n] + h * Bf^[n] + h * Df^[n+1]
            %
            % = Returns ================================================================================================
            %   1. A            (matrix) - m x q matrix containing coefficients for inputs
            %   2. B            (matrix) - m x q matrix containing coefficients for input derivatives
            %   3. C            (matrix) - m x m matrix containing coefficients for ouputs
            %   4. D            (matrix) - m x m matrix containing coefficients for output derivatives
            %   5. clean_exit   (bool)   - if false ODE polynomials are invalid and matricies are NaN.
            % ==========================================================================================================
            
            clean_exit = true;
            % -- read dataset parameters -------------------------------------------------------------------------------
            q = this.ODE_DS.q; % num input nodes
            m = this.ODE_DS.m; % num output nodes
            % -- Initialize Coefficient Matrices -----------------------------------------------------------------------
            if(this.ODE_DS.isNumeric())
                emptyMatrix = @(m,n) zeros(m,n);
            else
                emptyMatrix = @(m,n) sym(zeros(m,n));
            end
            A = emptyMatrix(m, q);
            B = emptyMatrix(m, q);
            C = emptyMatrix(m, m);
            D = emptyMatrix(m, m);

            % -- Compute Coefficients ----------------------------------------------------------------------------------
            for j = 1 : m
                eval_node = this.ODE_DS.z_out(j) + alpha;                
                [A_row, C_row, ~, B_row, D_row, ~, clean_exit] = this.ODE_SP{j}.coefficients(eval_node, alpha, this.ODE_DS, this.IVS);
                if(~clean_exit)
                    A = NaN; B = NaN; C = NaN; D = NaN;
                    warning('Could not obtain coefficients (q=%i, m=%i, alpha=%e). Returning NaN', q, m, alpha);
                    return;
                end
                A(j, :) = A_row;
                B(j, :) = B_row;
                C(j, :) = C_row;
                D(j, :) = D_row;
            end
            
            if(strcmp(format, 'full')) % -- y^[n+1] = Ay^[n] + r * Bf^[n] + Cy^[n+1] + r * Df^[n] ----------------------
            elseif(strcmp(format, 'compact')) % -- y^[n+1] = Ay^[n] + r * Bf^[n] + r * Cf^[n+1] ------------------------
                A = (eye(m) - C)\A;
                B = (eye(m) - C)\A;
                C = (eye(m) - C)\D;
                D = [];
            elseif(strcmpi(format, 'full_traditional')) % -- y^[n+1] = Ay^[n] + h * Bf^[n] + Cy^[n+1] + h * Df^[n+1] ---
                if(alpha ~= 0)
                    B = B / alpha;
                    D = D / alpha;
                end
            elseif(strcmpi(format, 'compact_traditional')) % -- y^[n+1] = Ay^[n] + h * Bf^[n] + h * Cf^[n+1] -----------
                A = (eye(m) - C)\A;
                if(alpha ~= 0)
                    B = ((eye(m) - C)\A) / alpha;
                    C = ((eye(m) - C)\D) / alpha;
                end
                D = [];
            else
                error('invalid format');
            end
        end
              
        function flags = realInputNodes(this)
            %REALINPUTS determines which inputs nodes are real-valued
            % = Parameters =============================================================================================
            % = Returns ================================================================================================
            %   1. flags    (vector)  - if flag(i) is true then ith input has real time node
            % ==========================================================================================================
            rdig  = 14;
            flags = false(this.ODE_DS.q, 1);
            input_nodes = double(this.ODE_DS.z_in);
            flags(imag(round(input_nodes, rdig)) == 0) = 1;
        end
        
        function flags = realOutputNodes(this)
            %REALOUTPUTS determines which output nodes are real-valued
            % = Parameters =============================================================================================
            % = Returns ================================================================================================
            %   1. flags    (vector)  - if flag(i) is true then ith input has real time node
            % ==========================================================================================================
            rdig  = 14;
            flags = false(this.ODE_DS.q, 1);
            input_nodes = double(this.ODE_DS.z_out);
            flags(imag(round(input_nodes, rdig)) == 0) = 1;
        end
        
        function [figure_handle, aspect_ratio] = activeNodeDiagram(this, plot_options, layout_options)
        %ACTIVENODEDIAGRAM creates node diagram for this method
        % = PARAMETERS =================================================================================================
        %   plot_options        (struct)  - options passed to plotActiveNodeStencil.
        %   layout_options      (struct)  - diagarm layout options:
        %       {'LeftLabel', []}         - label to the left of the diagram
        %       {'StencilGap', 0}         - gap between each stencil
        %       {'IndexStencils', bool}   - if true, plotter will add lower label "j = 1", "j = 2", ... to stencils
        % = Returns ====================================================================================================
            
            
            if(nargin < 2)
                plot_options = struct();
            end
            if(nargin < 3)
                layout_options = struct();
            end
            
            function border = plot_function_handle(j, options)
                options.EvaluationOutputIndex = j;
                border = this.ODE_SP{j}.plotActiveNodeStencil(this.ODE_DS, this.IVS, options);
            end
            figure_handle = figure();
            aspect_ratio  = plotHorizontalStencilSet(this.ODE_DS.m, @plot_function_handle, plot_options, layout_options);
        end
        
        function [figure_handle, aspect_ratio] = expansionPointDiagram(this, plot_options, layout_options)
        
            if(nargin < 2)
                plot_options = struct();
            end
            if(nargin < 3)
                layout_options = struct();
            end
            layout_options = setDefaultOptions(layout_options, {{'IndexStencils', false}});
            
            
            b = cellfun(@(sp) sp.b, this.ODE_SP, 'UniformOutput', false);
            b_index = this.ODE_DS.q + (1:this.ODE_DS.m);
            
            function border = plot_function_handle(~, options)
                border = plotExpansionpointStencil(b, b_index, this.ODE_DS, options);
            end
            figure_handle = figure();
            aspect_ratio  = plotHorizontalStencilSet(1, @plot_function_handle, plot_options, layout_options);
            
        end
        
    end
    
    methods(Access = protected)
        
        % -- Input Validation Function ---------------------------------------------------------------------------------
        
        function flag = validODE_Dataset(this, val)            
            flag = isa(val, 'ODE_Dataset') && val.s == 0;
            if(~flag)
                error('ODE_DS must be of type ODE_Dataset where number of stages s = 0');
            end
        end
        
        function flag = validIVS(this, val)
            flag = isa(val, 'InterpolatedValueSet');
            if(~flag)
                error('IVS must be of type InterpolatedValueSet');
            end
        end
        
        function flag = validODE_SP(this, val)
            type_check = @(e) isa(e, 'ODE_SolutionPolynomial'); 
            flag = iscell(val) && all(cellfun(type_check, val)) && (length(val) == this.ODE_DS.m);
            if(~flag)
                error('ODE_SP must be a cell array containg ODE_SolutionPolynomial objects');
            end
        end
     
    end
    
end