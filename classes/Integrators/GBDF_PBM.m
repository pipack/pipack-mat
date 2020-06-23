% ======================================================================================================================
%   GBDF_PBM (GBDF Polynomial Block Method) 
%
%   A class which implements basic methods for GBDF polynomial block methods, and stores important properties such as
%   the ODE dataset, any associated interpolated value set and the ODE polynomials for computing the outputs. 
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

classdef GBDF_PBM < PBM & GBDF_PBCR
    
    methods
        
        function this = GBDF_PBM(param_struct)
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
            this = this@PBM(param_struct);
        end
               
        function [figure_handle_Hy, aspect_ratio_Hy, figure_handle_Lk, aspect_ratio_Lk] = plotStencils(this, q, alpha, options, plot_stencil_options)
        	%PLOTSTENCILS plot H^{[j]}_y(tau) stencils for the method
            % = Parameters =============================================================================================
            %   1. q        (integer) - number of input nodes
            %   2. alpha    (real)    - extrapolation factor
            %   3. options  (struct : optional) - options for plotting method stencil set 
            %       'LabelPolynomial' (bool) - if true, plotter will add a label at left of all stencil sets
            %       'StencilGap',     (real) - gap between each stencil
            %       'IndexStencils'   (bool) - if true, plotter will add lower label to each stencil
            %   4. plot_stencil_options (struct : optional) - options passed to function PlotStencil for each stencil. 
            %                                                 See PlotStencil for details.
            % = Returns ================================================================================================
            %   1. figure_handle_Hy (handle) - a handle pointing to figure containing H^{[j]}_y(tau)
            %   2. aspect_ratio_Hy  (vector) - 2x1 vector with relative [width height] of Hy stencil figure
            %   3. figure_handle_Lk (handle) - a handle pointing to figure all interpolated stencils L_k, k = 1, ... , l
            %   4. aspect_ratio_Lk  (vector) - 2x1 vector with relative [width height] of Lk stencil figure
            % ==========================================================================================================
            
            if(nargin < 4)
                options = struct();
            end
            if(nargin < 5)
                plot_stencil_options = struct('alpha', alpha);
            end
            
            % -- set function options -------------------------------------------------------------------------------- %
            default_options = {
                {'LabelPolynomial', true}
                };
            options = setDefaultOptions(options, default_options);
            
            % -- Get ODE Polynomials --------------------------------------------------------------------------------- %
            [z_input, z_output] = this.ioNodes(q, alpha);
            [z_interp] = this.interpNodes(q, alpha);
            ODE_polynomials = this.ODEPolynomials(q, alpha);
            
            % -- Plot Hy polynomials --------------------------------------------------------------------------------- %
            Hy_stencils       = cellfun(@(x) x.y_stencils{1}, ODE_polynomials, 'UniformOutput', false);
            figure_handle_Hy  = figure();
            options.LeftLabel = 'H_y^{[j]} : ';
            aspect_ratio_Hy   = this.plotStencilSet(z_input, z_output, z_interp, Hy_stencils, plot_stencil_options, options);
            
            % -- Plot Ly polynomials --------------------------------------------------------------------------------- %
            F_interp_stencils        = ODE_polynomials{1}.f_interp_stencils;
            if(~isempty(F_interp_stencils))
                figure_handle_Lk  = figure(); 
                options.LeftLabel = 'L_j : ';
                aspect_ratio_Lk   = this.plotStencilSet(z_input, z_output, z_interp, F_interp_stencils, plot_stencil_options, options);
            else
                figure_handle_Lk = [];
                aspect_ratio_Lk = [];                
            end
            
        end
        
    end
    
	methods(Access = protected)
    
        function flag = validODE_SP(this, val)
            flag = this.validODE_SP@PBM(val) & this.validODE_SP@GBDF_PBCR(val);
        end
        
    end
    
end
