
% ======================================================================================================================
%   JD_ExpansionPointGenerator
%
%  An Abstract generator class for obtaining expansion points constructed from the parameters:
%
%       1. The output index j
%       2. The ODE dataset D
%
%   > Public Methods
%       generate(this, j, D, alpha)
%
% ======================================================================================================================

classdef JD_ExpansionPointGenerator < handle
    
    methods
        
        function b = generate(this, j, DS)
            %GENERATE Returns the jth expansion point. This method wraps the protected method generate_ to ensure
            % that the calling sequence is identical across subclasses. Subclases SHOULD NOT override this method.
            % == Parameters ============================================================================================
            % 1. j          (integer)     - output index
            % 2. DS         (ODE_Dataset) - underlying ODE dataset
            % == Returns ===============================================================================================
            % 1. b (function_handle) - function handle that returns the expansion point as a function of alpha
            % ==========================================================================================================
            b = this.generate_(j, DS);
        end
        
    end
    
    methods(Abstract, Access = protected)
        
        generate_(this, j, D); % protected function wrapped by public function generate.
    
    end
    
    methods(Access = protected)
        
        function b = CATexpansionPointHandle(~, b_val, translate_by_alpha)
            %ENDPOINTHANDLE (Constant or Alpha translated endpoint) this helper function creates an expansion point 
            % that is either constant or a constant translated by the extrapolation factor alpha.
            % == Parameters ============================================================================================
            % 1. b_val              (numeric or sym) - expansion point value.
            % 2. translate_by_alpha (bool) - if true, expansion point is translated by the extrapolation factor alpha.
            % == Returns ===============================================================================================
            % 1. b (function_handle) - endpoint as a function of extrapolation factor
            % ==========================================================================================================
            
            if(translate_by_alpha)
                b = @(alpha) b_val + alpha;
            else
                b = @(alpha) b_val;
            end
        end
        
    end
    
end
