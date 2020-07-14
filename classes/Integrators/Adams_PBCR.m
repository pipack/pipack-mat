% ======================================================================================================================
%   Adams_PBCR (Adams Polynomial Block Coarsener and Refiners) 
%
%   A class which implements basic methods for Adams polynomial block coarseners and refiners, and stores important 
%   properties such as the ODE dataset, any associated interpolated value set and the ODE polynomials for computing the 
%   outputs.
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

classdef Adams_PBCR < PBCR
    
    methods
        function this = Adams_PBCR(param_struct)
            %PBCR Constructor
            % = Parameters =============================================================================================
            %   1. param_struct  (struct) - optional struct with fields
            %           > "ODE_DS" (ODE Dataset) - ODE dataset for method
            %           > "IVS"    (InterpolateValueSet) - Any interpolated value set associated with the ODE dataset.
            %           > "ODE_SP" (cell) - cell array of ODE solution polynomials for method
            % ==========================================================================================================
            if(nargin == 0)
                param_struct = struct();
            end
            this = this@PBCR(param_struct);            
        end
        
        function [figure_handle, aspect_ratio] = expansionPointDiagram(this, plot_options, layout_options)
        
            if(nargin < 2)
                plot_options = struct();
            end
            if(nargin < 3)
                layout_options = struct();
            end
            plot_options = setDefaultOptions(plot_options, {{'DrawIntegrationPaths', true}});
            [figure_handle, aspect_ratio] = this.expansionPointDiagram@PBCR(plot_options, layout_options);
        end
        
        function [figure_handle_Ly, aspect_ratio_Ly, figure_handle_LF, aspect_ratio_LF] = polynomialDiagram(this, plot_options, layout_options)
        %POLYNOMIALDIAGRAM creates polynomial diagram for this method
        % = PARAMETERS =================================================================================================
        %   plot_options        (struct)  - options passed to plotPolynomialStencil.
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
            
            % -- L_y plot ----------------------------------------------------------------------------------------------
            default_layout_options = {
                {'IndexStencils', true}
                {'LeftLabel', 'L_y^{[j]} : '}
                };
            layout_options_Ly = setDefaultOptions(layout_options, default_layout_options);
            
            function border = plot_function_handle_Ly(j, options)
                border = plotPolynomialStencil(this.ODE_SP{j}.ApproxDerivPolyAIS{1}, this.ODE_SP{j}.b, this.ODE_DS, this.IVS, options);
            end
            figure_handle_Ly = figure();
            aspect_ratio_Ly  = plotHorizontalStencilSet(this.ODE_DS.m, @plot_function_handle_Ly, plot_options, layout_options_Ly);
            
            % -- L_F plot ----------------------------------------------------------------------------------------------
            default_layout_options = {
                {'IndexStencils', true}
                {'LeftLabel', 'L_F^{[j]} : '}
                };
            layout_options_LF = setDefaultOptions(layout_options, default_layout_options);
            
            function border = plot_function_handle_LF(j, options)
                border = plotPolynomialStencil(this.ODE_SP{j}.ApproxDerivPolyAIS{2}, this.ODE_SP{j}.b, this.ODE_DS, this.IVS, options);
            end
            figure_handle_LF = figure();
            aspect_ratio_LF  = plotHorizontalStencilSet(this.ODE_DS.m, @plot_function_handle_LF, plot_options, layout_options_LF);
            
            % -- IVS plot ----------------------------------------------------------------------------------------------
            if(~isempty(this.IVS))
                this.IVS.polynomialDiagram(this.ODE_DS)
            end
                     
        end
        
        function [figure_handle_Ly, aspect_ratio_Ly, figure_handle_LF, aspect_ratio_LF, figure_handle_b, aspect_ratio_b] = plotStencils(this, q, m, alpha, options, plot_stencil_options)
        	%PLOTSTENCILS plot L^{[j]}_y(tau), L^{[j]}_F(tau) stencils and endpoints for the method
            % = Parameters =============================================================================================
            %   1. q        (integer) - number of input nodes
            %   2. m        (integer) - number of output nodes
            %   3. alpha    (real)    - extrapolation factor
            %   4. options  (struct : optional) - options for plotting method stencil set 
            %       'LabelPolynomial' (bool) - if true, plotter will add a label at left of all stencil sets
            %       'StencilGap',     (real) - gap between each stencil
            %       'IndexStencils'   (bool) - if true, plotter will add lower label to each stencil
            %   5. plot_stencil_options (struct : optional) - options passed to function PlotStencil for each stencil. 
            %                                                 See PlotStencil for details.
            % = Returns ================================================================================================
            %   1. figure_handle_Hy (handle) - a handle pointing to figure containing H^{[j]}_y(tau)
            %   2. aspect_ratio_Hy  (vector) - 2x1 vector with relative [width height] of stencil figure
            % ==========================================================================================================
            
            if(nargin < 5)
                options = struct();
            end
            if(nargin < 6)
                plot_stencil_options = struct('alpha', alpha);
            end
            % -- set function options -------------------------------------------------------------------------------- %
            default_options = {
                {'LabelPolynomial', true}
                };
            options = setDefaultOptions(options, default_options);
            
            % -- Get ODE Polynomials --------------------------------------------------------------------------------- %
            [z_input, z_output] = this.ioNodes(q, m, alpha);
            ODE_polynomials = this.ODEPolynomials(q, m, alpha);
            
            % -- Plot Ly polynomials --------------------------------------------------------------------------------- %
            Ly_stencils       = cellfun(@(x) x.y_stencils{1}, ODE_polynomials, 'UniformOutput', false);
            figure_handle_Ly  = figure(); 
            options.LeftLabel = 'L_y^{[j]} : ';
            aspect_ratio_Ly   = this.plotStencilSet(z_input, z_output, Ly_stencils, plot_stencil_options, options);
            
            % -- Plot Ly polynomials --------------------------------------------------------------------------------- %
            LF_stencils       = cellfun(@(x) x.y_stencils{2}, ODE_polynomials, 'UniformOutput', false);
            figure_handle_LF  = figure(); 
            options.LeftLabel = 'L_F^{[j]} : ';
            aspect_ratio_LF   = this.plotStencilSet(z_input, z_output, LF_stencils, plot_stencil_options, options);
            
            % -- Plot expansion points ------------------------------------------------------------------------------- %
            b = cellfun(@(p) p.b, ODE_polynomials);
            figure_handle_b = figure(); 
            plot_endpoint_options = plot_stencil_options;
            plot_endpoint_options.LeftLabel = 'b : ';            
            aspect_ratio_b  = plotAdamsEndpoints(z_input, z_output, b, plot_endpoint_options);
        end
        
    end
    
    methods(Access = protected)
    
        function flag = validODE_SP(this, val)
            type_check = @(e) isa(e, 'Adams_ODESP'); 
            flag = iscell(val) && all(cellfun(type_check, val)) && (length(val) == this.ODE_DS.m);
            if(~flag)
                error('ODE_SP must be a cell array containg Adams_ODESP objects');
            end
        end
        
    end
    
end