
% ======================================================================================================================
%   Adams ODE Derivative Polynomial:
%
%   A class which implements an Adams ODE Derivative polynomial where all the derivatives 0 to g are determined by a 
%   single Lagrange polynomial that interpolates derivative data.
%
%   Parameters - same as ODE Polynomial
%   Public Methods - same as ODE polynomial
%
% ======================================================================================================================

classdef Adams_ODEDP < ODE_DerivativePolynomial
    
    methods
        
        function this = Adams_ODEDP(LF_AIS)
            % ADAMS_ODEP Constructor for an Adams ODE solution polynomial
            % = Parameters =============================================================================================
            %   1. LF_AIS (Stencil) - Active Index Set for for all approximate derivative.
            % ==========================================================================================================
            
            if( ~ isa(LF_AIS, 'IPoly_AIS') || ~LF_AIS.only_derivative_values_active)
                error('Invalid L_F Active Index Set');
            end
            
            indices = ones(1, LF_AIS.dimension); % all derivatives from LF
            b = @(alpha) 0;                      % expansion point is arbitary for Adams derivative (zero for default)
            this@ODE_DerivativePolynomial(indices, {LF_AIS}, b);
        end
        
    end
    
end