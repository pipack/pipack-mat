% ======================================================================================================================
%   ODE Polynomial:
%
%   An Abstract class for implementing an general ODE polynomial
%
%       p(\tau; b) = \sum_{j=0}^{g} \frac{a_{j}(b)(\tau - b)^j}{j!}
%
%   > Properties
%
%        ApproxDerivPolyIndices (array) - array whose length corresponds to the order of the ODE polynomial and whose
%                                         ith element indicates the index of the stencil used for the (i-1)th derivative
%                                         approximation. i.e. y_stencil{y_stencil_indices(i)} is used to compute the
%                                         (i-1)th derivative of ODE polynomial.
%
%        ApproxDerivPolyAIS     (cell)  - cell array of objects that inherit from ActiveIndexSet class.
%
%        b                      (real)  - expansion point of the ODE polynomial.
%
%   > Properties: Computable
%
%        degree  - the degree of ODE polynomial
%
%   > Methods
%       coefficients - computes coefficients for evaluating the ODE polynomial at a specific point
%
% ======================================================================================================================

classdef ODE_Polynomial < handle
    
    properties(SetAccess = protected)
        % -- ODE polynomial propeties ----------------------------------------------------------------------------------
        ApproxDerivPolyIndices
        ApproxDerivPolyAIS
        b
        degree
    end
    
    methods(Abstract, Access = protected)
        
        W = approxDerivativeMatrix(this, ActIndSet, b, alpha, ODE_DS, IVS);
        %SCALEDYDIFFERENTIATIONMATRIX returns the weights for computing approximate derivatives arising from a
        % polynomial that is constructed from the specified ActiveIndexSet. The jth row contains weights for the
        % scaled approximate derivatives a_j(b) / j!
        % = Parameters =============================================================================================
        %   1. ActIndSet    (Active Index Set) - active index set for interpolating polynomial.
        %   2. b            (real)             - point where scaled derivatives are required.
        %   3. alpha        (real)             - extrapolation parameter.
        %   4. ODE_DS       (ODE_Dataset)      - underlying ODE dataset.
        %   5. IVS          (IVS)              - interpolated value set.
        % = Returns ================================================================================================
        %   1. W            (matrix)  - matrix of weights for computing derivatives. jth row contains weights for
        %                               scaled derivative y^{(j-1)}(b) / (j-1)!
        % ==========================================================================================================
        
    end
    
    methods
        
        function this = ODE_Polynomial(ADPI, ADP_AIS, b)
            % ODE_POLYNOMIAL Constructor
            % = Parameters =============================================================================================
            %   1. ADPI     (vector) - Vector of integers where ith element indicates the index of the ActiveIndexSet
            %                          used to compute the (i-1)th approximate derivative. i.e.
            %
            %                                       this.ApproxDerivPolyAIS{ADAAII(i)}
            %
            %                          is used to compute the (i-1)th approximate derivative of the ODE polynomial. The
            %                          length of this array corresponds to the order of the ODE polynomial.
            %   2. ADP_AIS  (cell)   - cell array of ActiveIndexSet objects describing the
            %                                        polynomials for computing the approximate derivatives.
            %   3. b        (double) - expansion point of the ODE polynomial
            % ==========================================================================================================
            
            type_checks = all(cellfun(@(e) isa(e,'IPoly_AIS'), ADP_AIS)) && isa(b, 'function_handle');
            
            if(type_checks)
                this.ApproxDerivPolyAIS = ADP_AIS;
                this.ApproxDerivPolyIndices = ADPI;
                this.b = b;
            else
                error('invalid ODE polynomial parameters');
            end
            
        end
        
        % === START Property Get Methods ===============================================================================
        
        function ord = get.degree(this)
            %GET.DEGREE returns the degree of the ODE polynomial
            ord = length(this.ApproxDerivPolyIndices) - 1;
        end
        
        % === END Property Get Methods =================================================================================
        
        function [input_indices, stage_indices, output_indices, interp_sol_indices, interp_der_indices] = ActiveNodeIndexSet(this, alpha, ODE_DS, IVS)
            input_indices  = [];
            stage_indices  = [];
            output_indices = [];
            interp_sol_indices = [];
            interp_der_indices = [];
            
            if(~isempty(IVS)) % -- incorporate interpolate values ------------------------------------------------------
                [ivs_sol_input_indices, ivs_sol_stage_indices, ivs_sol_output_indices] = IVS.activeIndexSets('solution', alpha, ODE_DS);
                [ivs_der_input_indices, ivs_der_stage_indices, ivs_der_output_indices] = IVS.activeIndexSets('derivative', alpha, ODE_DS);
            end
            
            for i = 1 : length(this.ApproxDerivPolyIndices)
                poly_AIS = this.ApproxDerivPolyAIS{this.ApproxDerivPolyIndices(i)};
                input_indices  = vcat(true, input_indices,  poly_AIS.input_sol_inds,  poly_AIS.input_der_inds);
                output_indices = vcat(true, output_indices, poly_AIS.output_sol_inds, poly_AIS.output_der_inds);
                stage_indices  = vcat(true, stage_indices,  poly_AIS.stage_sol_inds,  poly_AIS.stage_der_inds);
                if(~isempty(poly_AIS.interp_sol_inds)) % -- incorporate any interpolated solution values ---------------
                    for j = 1 : length(poly_AIS.interp_sol_inds)
                        interp_ind = poly_AIS.interp_sol_inds(j);
                        input_indices  = vcat(true, input_indices,  ivs_sol_input_indices{interp_ind});
                        output_indices = vcat(true, output_indices, ivs_sol_output_indices{interp_ind});
                        stage_indices  = vcat(true, stage_indices,  ivs_sol_stage_indices{interp_ind});
                    end
                    interp_sol_indices = vcat(true, interp_sol_indices, poly_AIS.interp_sol_inds);
                end
                if(~isempty(poly_AIS.interp_der_inds)) % -- incorporate any interpolated derivative values -------------
                    for j = 1 : length(poly_AIS.interp_der_inds)
                        interp_ind = poly_AIS.interp_der_inds(j);
                        input_indices  = vcat(true, input_indices,  ivs_der_input_indices{interp_ind});
                        output_indices = vcat(true, output_indices, ivs_der_output_indices{interp_ind});
                        stage_indices  = vcat(true, stage_indices,  ivs_der_stage_indices{interp_ind});
                    end
                    interp_der_indices = vcat(true, interp_der_indices, poly_AIS.interp_der_inds);
                end
            end
            
            input_indices  = unique(input_indices);
            output_indices = unique(output_indices);
            stage_indices  = unique(stage_indices);
            interp_sol_indices = unique(interp_sol_indices);
            interp_der_indices = unique(interp_der_indices);
        end
        
        function [input_nodes, stage_nodes, output_nodes, interp_sol_nodes, interp_der_nodes] = ActiveNodeSet(this, alpha, ODE_DS, IVS)
            [input_indices, stage_indices, output_indices, interp_sol_indices, interp_der_indices] = this.ActiveNodeIndexSet(alpha, ODE_DS, IVS);
            input_nodes  = ODE_DS.z_in(input_indices);
            stage_nodes  = ODE_DS.c(alpha);
            stage_nodes  = stage_nodes(stage_indices);
            output_nodes = ODE_DS.z_out(output_indices);
            if(~isempty(IVS))
                interp_sol_nodes = IVS.sol_tau(alpha);
                interp_sol_nodes = interp_sol_nodes(interp_sol_indices);
                interp_der_nodes = IVS.der_tau(alpha);
                interp_der_nodes = interp_der_nodes(interp_der_indices);
            else
                interp_sol_nodes = [];
                interp_der_nodes = [];
            end
        end
        
        function [borders] = plotActiveNodeStencil(this, ODE_DS, IVS, options)
            if(nargin < 4)
                options = struct();
            end
            
            [input_indices, stage_indices, output_indices, interp_sol_indices, interp_der_indices] = ...
                this.ActiveNodeIndexSet(1, ODE_DS, IVS); % independt of alpha. 1 used as default
            if(isfield(options, 'ShowInterpolatedValues') && options.ShowInterpolatedValues)
                num_sol_ivs = length(IVS.sol_tau(1));
                ivp_indices = vcat(true, interp_sol_indices, interp_der_indices + num_sol_ivs);
            else
                ivp_indices = [];
            end
            
            borders = plotActiveNodeStencil(input_indices, stage_indices, output_indices, ivp_indices, ODE_DS, IVS, options);
            
        end
        
        function [YI_coeff, YO_coeff, YS_coeff, FI_coeff, FO_coeff, FS_coeff, clean_exit] = coefficients(this, z_out, alpha, ODE_DS, IVS)
            %COEFFICIENTS computes the coefficients for evaluating the ODE polynomial at a local point z_out. Polynomial
            % can be evaluated by taking:
            %          A_coeff * y^{[n]} + r * B_coeff * f^{[n]} + C_coeff * y^{[n+1]} + r * D_coeff * f^{[n]}
            % = Parameters =============================================================================================
            %   1. z_out    (array) - local point(s) to evaluate polynomial at
            %   1. DS       (ODE_Dataset) - local point to evaluate polynomial at
            %   1. IVP      (Interpolated Value Set) - local point to evaluate polynomial at
            % = Returns ================================================================================================
            %   1. YI_coeff     (vector) - 1 x q matrix containing coefficients for inputs
            %   2. FI_coeff     (vector) - 1 x q matrix containing coefficients for input derivatives
            %   3. YO_coeff     (vector) - 1 x m matrix containing coefficients for ouputs
            %   4. FO_coeff     (vector) - 1 x m matrix containing coefficients for output derivatives
            %   5. YS_coeff     (vector) - 1 x s matrix containing coefficients for stage values
            %   6. FS_coeff     (vector) - 1 x s matrix containing coefficients for stage derivatives
            %   7. clean_exit   (bool)   - if false ODE polynomials is invalid and coefficient vectors are NaN.
            % ==========================================================================================================
            
            clean_exit = true;
            np = length(z_out);
            
            % -- read dataset parameters -------------------------------------------------------------------------------
            q = ODE_DS.q; % num input nodes
            m = ODE_DS.m; % num output nodes
            s = ODE_DS.s; % num stages
            if(isempty(IVS))
                IVP_num_sol = 0; % num interpolated solution values
                IVP_num_der = 0; % num interpolated derivatives
            else
                IVP_num_sol = length(IVS.sol_tau(alpha)); % num interpolated solution values
                IVP_num_der = length(IVS.der_tau(alpha)); % num interpolated derivatives
            end
            
            % -- initialize empty coefficient vectors ------------------------------------------------------------------
            if(ODE_DS.isNumeric())
                emptyMatrix = @(m,n) zeros(m,n);
            else
                emptyMatrix = @(m,n) sym(zeros(m,n));
            end
            
            YI_coeff = emptyMatrix(np,q);
            YO_coeff = emptyMatrix(np,m);
            YS_coeff = emptyMatrix(np,s);
            IVS_Y_coeff = emptyMatrix(np,IVP_num_sol);
            
            FI_coeff = emptyMatrix(np,q);
            FO_coeff = emptyMatrix(np,m);
            FS_coeff = emptyMatrix(np,s);
            IVS_F_coeff = emptyMatrix(np,IVP_num_der);
            
            % -- compute scaled differentiation matrices for stencils --------------------------------------------------
            ns = length(this.ApproxDerivPolyAIS);
            diff_mat = cell(ns, 1);
            for j = 1 : ns
                diff_mat{j} = this.approxDerivativeMatrix(this.ApproxDerivPolyAIS{j}, this.b(alpha), alpha, ODE_DS, IVS); % compute differentiation matrix for jth stencil at point b
                % -- check for NaN or Inf ------------------------------------------------------------------------------
                if(any(cellfun(@(x) any(isnan(x(:))) || any(isinf(x(:))), diff_mat(j))))
                    YI_coeff = NaN; FI_coeff = NaN; YO_coeff = NaN; FO_coeff = NaN; YS_coeff = NaN; FS_coeff = NaN;
                    clean_exit = false;
                    return;
                end
            end
            
            % -- place coefficients in augmented matrices --------------------------------------------------------------
            g = length(this.ApproxDerivPolyIndices);        % number of approximate derivatives
            for j = 1 : g
                AII_index = this.ApproxDerivPolyIndices(j); % index of ActiveIndexSet for computing a_j(b)
                AIS = this.ApproxDerivPolyAIS{AII_index};     % ActiveIndexSet used for approximate derivative a_j(b)
                dm = diff_mat{AII_index};                  % differentiation matrix for jth derivative at \tau = b
                if(size(dm,1) >= j)                        % only add contribution if derivative is nonzero
                    cf = (z_out(:) - this.b(alpha)).^(j-1) * dm(j,:); % coefficients for the jth Taylor term
                    
                    % -- distribute coefficients -----------------------------------------------------------------------
                    num_active_sol_inputs  = length(AIS.input_sol_inds);
                    num_active_sol_outputs = length(AIS.output_sol_inds);
                    num_active_sol_stages  = length(AIS.stage_sol_inds);
                    num_active_sol_interp  = length(AIS.interp_sol_inds);
                    
                    num_active_der_inputs  = length(AIS.input_der_inds);
                    num_active_der_outputs = length(AIS.output_der_inds);
                    num_active_der_stages  = length(AIS.stage_der_inds);
                    num_active_der_interp  = length(AIS.interp_der_inds);
                    
                    % -- solution values: inputs -----------------------------------------------------------------------
                    shift = 0;
                    if(num_active_sol_inputs > 0)
                        YI_coeff(:, AIS.input_sol_inds) = YI_coeff(:, AIS.input_sol_inds) + cf(:, shift + (1:num_active_sol_inputs));
                    end
                    % -- solution values: outputs ----------------------------------------------------------------------
                    shift = shift + num_active_sol_inputs;
                    if(num_active_sol_outputs > 0)
                        YO_coeff(:, AIS.output_sol_inds) = YO_coeff(:, AIS.output_sol_inds) + cf(:, shift + (1:num_active_sol_outputs));
                    end
                    % -- solution values: stages -----------------------------------------------------------------------
                    shift = shift + num_active_sol_outputs;
                    if(num_active_sol_stages > 0)
                        YS_coeff(:, AIS.stage_sol_inds) = YS_coeff(:, AIS.stage_sol_inds) + cf(:, shift + (1:num_active_sol_stages));
                    end
                    % -- solution values: interpolated -----------------------------------------------------------------
                    shift = shift + num_active_sol_stages;
                    if(num_active_sol_interp > 0)
                        IVS_Y_coeff(:, AIS.interp_sol_inds) = IVS_Y_coeff(:, AIS.interp_sol_inds) + cf(:, shift + (1:num_active_sol_interp));
                    end
                    % -- derivative values: inputs ---------------------------------------------------------------------
                    shift = shift + num_active_sol_interp;
                    if(num_active_der_inputs > 0)
                        FI_coeff(:, AIS.input_der_inds) = FI_coeff(:, AIS.input_der_inds) + cf(:, shift + (1:num_active_der_inputs));
                    end
                    % -- derivative values: outputs --------------------------------------------------------------------
                    shift = shift + num_active_der_inputs;
                    if(num_active_der_outputs > 0)
                        FO_coeff(:, AIS.output_der_inds) = FO_coeff(:, AIS.output_der_inds) + cf(:, shift + (1:num_active_der_outputs));
                    end
                    % -- derivative values: stages ---------------------------------------------------------------------
                    shift = shift + num_active_der_outputs;
                    if(num_active_der_stages > 0)
                        FS_coeff(:, AIS.stage_der_inds) = FS_coeff(:, AIS.stage_der_inds) + cf(:, shift + (1:num_active_der_stages));
                    end
                    % -- derivative values: interpolated ---------------------------------------------------------------
                    shift = shift + num_active_der_stages;
                    if(num_active_der_interp > 0)
                        IVS_F_coeff(:, AIS.interp_der_inds) = IVS_F_coeff(:, AIS.interp_der_inds) + cf(:, shift + (1:num_active_der_interp));
                    end
                end
            end
            
            % -- incorporate interpolated solution values --------------------------------------------------------------
            if(IVP_num_sol > 0)
                [A1, A2, A3, A4, A5, A6, clean_exit] = IVS.coefficientMatrices('solution', alpha, ODE_DS);
                YI_coeff = YI_coeff + IVS_Y_coeff * A1;
                YO_coeff = YO_coeff + IVS_Y_coeff * A2;
                YS_coeff = YS_coeff + IVS_Y_coeff * A3;
                FI_coeff = FI_coeff + IVS_Y_coeff * A4;
                FO_coeff = FO_coeff + IVS_Y_coeff * A5;
                FS_coeff = FS_coeff + IVS_Y_coeff * A6;
            end
            
            % -- incorporate interpolated derivative values ------------------------------------------------------------
            if(IVP_num_der > 0)
                [B1, B2, B3, B4, B5, B6, clean_exit] = IVS.coefficientMatrices('derivative', alpha, ODE_DS);
                YI_coeff = YI_coeff + IVS_F_coeff * B1;
                YO_coeff = YO_coeff + IVS_F_coeff * B2;
                YS_coeff = YS_coeff + IVS_F_coeff * B3;
                FI_coeff = FI_coeff + IVS_F_coeff * B4;
                FO_coeff = FO_coeff + IVS_F_coeff * B5;
                FS_coeff = FS_coeff + IVS_F_coeff * B6;
            end
            
        end
        
        % === Plotting Functions =======================================================================================
        
        function [figure_handle, aspect_ratio] = polynomialDiagram(this, DS, IVS, plot_options, layout_options)
            %POLYNOMIALDIAGRAM general purpose function that creates polynomial diagram for any ODE polynomial.
            % = PARAMETERS =================================================================================================
            %   1. DS       (ODE_Dataset) - local point to evaluate polynomial at
            %   2. IVP      (Interpolated Value Set) - local point to evaluate polynomial at
            %   3. plot_options        (struct)  - options passed to plotPolynomialStencil.
            %   4. layout_options      (struct)  - diagarm layout options:
            %       {'LeftLabel', []}         - label to the left of the diagram
            %       {'StencilGap', 0}         - gap between each stencil
            %       {'IndexStencils', bool}   - if true, plotter will add lower label "j = 1", "j = 2", ... to stencils
            % = Returns ====================================================================================================
            
            if(nargin < 4)
                plot_options = struct();
            end
            if(nargin < 5)
                layout_options = struct();
            end
            
            default_layout_options = {
                {'IndexStencils', false}
                {'LeftLabel', []}
                {'FigureIndex', []}
                };
            layout_options = setDefaultOptions(layout_options, default_layout_options);
            num_stencils = length(this.ApproxDerivPolyAIS);
            
            function border = plot_function_handle(j, options)
                ind_set = find(this.ApproxDerivPolyIndices() == j);
                ind_str = arrayfun(@(s) [num2str(s),','], ind_set, 'UniformOutput', false);
                ind_str = [ind_str{:}];
                ind_str = ind_str(1:end-1);
                options.LowerLabel = ['j = ', ind_str];
                border = plotPolynomialStencil(this.ApproxDerivPolyAIS{j}, this.b, DS, IVS, options);
            end
            
            if(isempty(layout_options.FigureIndex))
                figure_handle = figure();
            else
                figure(layout_options.FigureIndex);
            end
                
            aspect_ratio  = plotHorizontalStencilSet(num_stencils, @plot_function_handle, plot_options, layout_options);
 
        end
        
        function [figure_handle, aspect_ratio] = expansionpointStencil(this, DS, plot_options)
            %POLYNOMIALDIAGRAM general purpose function that creates polynomial diagram for any ODE polynomial.
            % = PARAMETERS =================================================================================================
            %   1. DS       (ODE_Dataset) - local point to evaluate polynomial at
            %   2. IVP      (Interpolated Value Set) - local point to evaluate polynomial at
            %   3. plot_options        (struct)  - options passed to plotPolynomialStencil.
            % = Returns ====================================================================================================    
            
            if(nargin < 3)
                plot_options = struct();
            end
            layout_options = struct('LeftLabel', [], 'StencilGap', 0, 'IndexStencils', false);
            figure_handle = figure();
            function border = plot_function_handle(~, options)
                border = plotExpansionpointStencil(this.b, [], DS, options); %problem
            end
            aspect_ratio  = plotHorizontalStencilSet(1, @plot_function_handle, plot_options, layout_options);
        end
        
    end
    
    methods(Access = protected)
        
        % === START COEFFICIENT FUNCTIONS ==============================================================================
        
        function [W] = weights(~, z, b, A, B)
            %WEIGHTS returns the weights for computing derivatives 0 to length(A) + length(B) - 1 for a function at the
            % point b, by using function information at the nodes z(A) and derivatives at z(B).
            % = Parameters =============================================================================================
            %   1. z    (vector)    - vector of nodes
            %   2. b    (real)      - location where deriatives are required
            %   3. A    (vector)    - indices of nodes where function information is provided
            %   4. B    (vector)    - indices of nodes where derivative information is provided
            % = Returns ================================================================================================
            %   1. W    (matrix)    - matrix of weights for computing derivatives. jth row contains weights for (j-1)th
            %                         derivative.
            % ==========================================================================================================
            
            len_A = length(A);
            len_B = length(B);
            p     = len_A + len_B;
            
            if(all(isnumeric(z)))
                M = zeros(p);
            else
                M = sym(zeros(p));
            end
            
            % -- Value Conditions --------------------------------------------------------------------------------------
            for i=1:len_A
                z0 = z(A(i));
                for j=1:p
                    M(i,j) = (z0 - b)^(j-1);
                end
            end
            
            % -- Derivative Conditions ---------------------------------------------------------------------------------
            for i=1:len_B
                z0 = z(B(i));
                for j=2:p
                    M(i+len_A,j) = (j-1) * (z0 - b)^(j-2);
                end
            end
            
            if(rank(M) == p) % check if invertible
                W = inv(M);
            else
                W = NaN;
            end
        end
        
        % === END COEFFICIENT FUNCTIONS ================================================================================
        
    end
    
end