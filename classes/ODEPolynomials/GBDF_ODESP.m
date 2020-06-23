
% ======================================================================================================================
%   GBDF ODE Polynomial
%
%   A class which implements a GBDF ODE polynomial, or any ODE solution polynomial where a single interpolating 
%   polynomial is used to compute all the approximate derivatives.
%
%   Parameters - same as ODE Polynomial
%   Public Methods - same as ODE polynomial
%
% ======================================================================================================================

classdef GBDF_ODESP < ODE_SolutionPolynomial
    
    methods
        
        function this = GBDF_ODESP(Hy_AIS)
            % BDF_ODE_Solution POLYNOMIAL Constructor for a BDF ODE Solution polynomial
            % = Parameters =============================================================================================
            %   1. Hy_AIS (Stencil) - Active Index Set for for 0th approximate derivative.
            % ==========================================================================================================
            
            if(~isa(Hy_AIS, 'IPoly_AIS'))
                error('Invalid BDF ODE solution polynomial parameters');
            end
            
            indices = ones(1, Hy_AIS.dimension);                % all derivatives obtained from one stencil
            b = @(alpha) 0;                                     % expansion point is arbitary for BDF (zero for default)
            this@ODE_SolutionPolynomial(indices, {Hy_AIS}, b);
        end
        
    end
   
end