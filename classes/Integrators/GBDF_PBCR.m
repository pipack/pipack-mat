% ======================================================================================================================
%   GBDF_PBCR (GBDF Polynomial Block Coarsener and Refiners)
%
%   A class which implements basic methods for GBDF polynomial block coarseners and refiners, and stores important
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

classdef GBDF_PBCR < PBCR
    
    methods
        
        function this = GBDF_PBCR(param_struct)
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
        
        function [figure_handle, aspect_ratio] = polynomialDiagram(this, plot_options, layout_options)
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
            
            % -- set function options ----------------------------------------------------------------------------------
            default_layout_options = {
                {'IndexStencils', true}
                {'LeftLabel', 'H_y^{[j]} : '}
                };
            layout_options = setDefaultOptions(layout_options, default_layout_options);
            
            function border = plot_function_handle(j, options)
                border = plotPolynomialStencil(this.ODE_SP{j}.ApproxDerivPolyAIS{1}, this.ODE_SP{j}.b, this.ODE_DS, this.IVS, options);
            end
            figure_handle = figure();
            aspect_ratio  = plotHorizontalStencilSet(this.ODE_DS.m, @plot_function_handle, plot_options, layout_options);
            
            % -- IVS plot ----------------------------------------------------------------------------------------------
            if(~isempty(this.IVS))
                this.IVS.polynomialDiagram(this.ODE_DS)
            end
            
        end
        
    end
    
    methods(Access = protected)
        
        function flag = validODE_SP(this, val)
            type_check = @(e) isa(e, 'GBDF_ODESP');
            flag = iscell(val) && all(cellfun(type_check, val)) && (length(val) == this.ODE_DS.m);
            if(~flag)
                error('ODE_SP must be a cell array containg GBDF_ODESP objects');
            end
        end
        
    end
    
end

