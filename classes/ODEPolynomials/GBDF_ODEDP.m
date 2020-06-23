
% ======================================================================================================================
%   GBDF ODE Derivative Polynomial
%
%   A class which implements a GBDF ODE Derivative polynomial, or any derivative ODE polynomial where a single 
%   interpolating polynomial is used to compute all the approximate derivatives.
%
%   Parameters - same as ODE Polynomial
%   Public Methods - same as ODE polynomial
%
% ======================================================================================================================

classdef GBDF_ODEDP < ODE_DerivativePolynomial
    
    methods
        
        function this = GBDF_ODEDP(AIS)
            % ADAMS_ODEP Constructor for an Adams ODE solution polynomial
            % = Parameters =============================================================================================
            %   1. AIS (Stencil) - Active Index Set for interpolating polynomial that determines all approximate derivatives.
            % ==========================================================================================================
            
            if(~isOrInhertsFrom(AIS, 'IPoly_AIS'))
                error('Invalid GBDF ODE derivative polynomial parameters');
            end
            
            indices = ones(1, AIS.dimension);            % all derivatives from a single polynomial
            b = @(alpha) 0;                              % expansion point is arbitary for BDF (zero for default)
            this@ODE_DerivativePolynomial(indices, {AIS}, b);
        end
        
    end
    
end