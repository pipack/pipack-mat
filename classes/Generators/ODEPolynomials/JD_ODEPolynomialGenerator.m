
% ======================================================================================================================
%   JDA_ODEPolynomialGenerator
%
%   An Abstract generator class for ODE polynomials. Each polynomial depends on the following parameters:
%
%       1. The output index j
%       2. The ODE dataset
%       3. alpha
%
%   > Public Methods
%       generate(this, j, D, alpha)
%
% ======================================================================================================================

classdef JD_ODEPolynomialGenerator < handle
    
    methods
        function ODEP = generate(this, j, DS)
            %GENERATE Returns the jth output ODE polynomial. This method wraps the protected method generate_ to ensure 
            % that the calling sequence is identical across subclasses. Subclases SHOULD NOT override this method.
            % == Parameters ============================================================================================
            % 1. j          (integer)     - output index 
            % 2. DS         (ODE_Dataset) - underlying ODE dataset
            % == Returns ===============================================================================================
            % 1. ODEP (ODE_Polynomial) - ode polynomial generated from parameters
            % ==========================================================================================================
            ODEP = this.generate_(j, DS);
        end
    end
    
    methods(Abstract, Access = protected)
        generate_(this, j, D); % protected function wrapped by public function generate.        
    end
end

