
% ======================================================================================================================
%   Adams ODE Solution Polynomial:
%
%   A class which implements an Adams ODE Solution polynomial or any ODE solution polynomial where the 0th approximate  
%   derivative is computed by one interpolating polynomial, and approximate derivatives 1 to g are determined by a 
%   second polynomial.
%
%   Parameters - same as ODE Polynomial
%   Public Methods - same as ODE polynomial
%
% ======================================================================================================================

classdef Adams_ODESP < ODE_SolutionPolynomial
    
    methods
        
        function this = Adams_ODESP(Ly_AIS, LF_AIS, b)
            % ADAMS_ODEP Constructor for an Adams ODE solution polynomial
            % = Parameters =============================================================================================
            %   1. Ly_AIS (Stencil) - Active Index Set for for 0th approximate derivative.
            %   2. LF_AIS (Stencil) - Active Index Set for derivatives greater than 0.
            %   3. b         (real) - expansion point.
            % ==========================================================================================================
            
            if( ~isa(Ly_AIS, 'IPoly_AIS') )
                error('Invalid L_y Active Index Set');
            end
            if( ~isa(LF_AIS, 'IPoly_AIS') )
                error('Invalid L_F Active Index Set');
            end
            if( ~isa(b, 'function_handle') )
                error('Invalid expansion point. Must be function_handle @(alpha) ');
            end
            
            indices = [1 2 * ones(1, LF_AIS.dimension)]; % 0th derivative from Ly and all other derivatives from LF
            this@ODE_SolutionPolynomial(indices, {Ly_AIS, LF_AIS}, b);
        end
        
    end
    
end