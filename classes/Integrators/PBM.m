
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
%       1. blockMatrices     - computes block matricies for a coarsener or refiner
%       2. realInputNodes    - determines which inputs are real-valued
%       3. realOutputNodes   - determines which outputs are real-valued
%       4. stabilityFunction - function of one argument z = h * lambda, which determines stability 
%
% ======================================================================================================================

classdef PBM < PBCR
    
    methods
        
        function this = PBM(param_struct)
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
        
        % -- Public Methods --------------------------------------------------------------------------------------------
        
       	function handle = stabilityFunction(this, alpha)
            %STABILITYFUNCTION Returns stability function R(z) for method. The underlying block method will be stable
            % for all z s.t. R(z) < 1
            % = Parameters =============================================================================================
            %   1. alpha 	(real)   - extrapolation factor
            % = Returns ================================================================================================
            %   1. handle  	(handle) - function of one argument pertaining to stability function
            % ==========================================================================================================
            
            [A, B, C, D, clean_exit] = this.blockMatrices(alpha, 'full');
            if(~clean_exit)
                handle = @(z) NaN;
            else
                handle = @(z) this.blockStabilityFunction(A, B, C, D, z, alpha);
            end
        end
        
    end
    
    methods(Access = protected)
        
        function flag = validODE_Dataset(this, val)            
            flag = isa(val, 'ODE_Dataset') && val.s == 0 && val.q == val.m;
            if(~flag)
                error('ODE_DS must be of type ODE_Dataset where number of stages s = 0');
            end
        end
        
        function amp_factor = blockStabilityFunction(~, A, B, C, D, z, alpha)
            %BLOCKSTABILITYFUNCTION stability function for a block method
            % = Parameters =============================================================================================
            %   1. z     	(integer) - stability parameter z = r * lambda 
            %   2. alpha 	(real)    - extrapolation factor
            % = Returns ================================================================================================
            %   1. amp_factor  (real) - largest eigenvalue of stability matrix
            % ==========================================================================================================
            
            I = eye(size(A));
            % -- form stability matrix ---------------------------------------------------------------------------------
            if(alpha ~= 0)
                SM = (I - C - z / alpha * D) \ (A + z / alpha * B); % scale z for propagators
            else
                SM = (I - C - z * D) \ (A + z * B); % do not scale z for iterators
            end
            % -- check if stability matrix is valid --------------------------------------------------------------------
            if(any(isnan(SM(:))) || any(isinf(SM(:)))) 
                amp_factor = NaN;
            else
                amp_factor = max(abs(eig(SM))); % spectral radius of stability matrix
            end
        end
        
    end
    
end