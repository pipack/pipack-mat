
% ======================================================================================================================
%
%  Diagonally Implicit Block Method : y^{(n+1)} = A * y^{(n)} + r * B * y^{(n+1)} + C * y^{(n+1)} + r * D * f^{[n+1]}
%  with optional output point 
%       y_out = a_out * y^{(n)} + r * b_out * y^{(n+1)} + c_out * y^{(n+1)} + r * d_out * f^{[n+1]} + r * e_out * f_out 
%   
%  A diagonally implicit block method must satisfy the following conditions:
%   1. The matrix D must be lower triagular
%
% ======================================================================================================================

classdef MutableDILMM < DI_LMMConst
        
    properties(SetAccess = protected)
        a % vector of coeffients for y
        b % vector of coefficients for f
        % -- propeties for IntegratorConst -----------------------------------------------------------------------------
        name = 'MutableDIBLK'
        description = 'Mutable Diagonally Implicit Block Method'
        order = [];
    end
    
	properties
        % -- propeties for DI_BLKConst -----------------------------------------------------------------------------
        eval_RHS                    % boolean - if true RHS will evaluated directly, otherwise F will obtained algebraically after nonlinear solve
        extrapolate_initial_guess   % if true coefficients a_extrapolate and b_extrapolate will be used to form initial guess for any nonlinear systems 
        % -- propeties for IntegratorConst -----------------------------------------------------------------------------
        graph_line_style = 'r*';
   end
     
    methods
        
        function this = MutableDILMM(options)
            if(nargin == 0)
                options = struct();
            end
            this = this@DI_LMMConst(options);
            
            % -- enable coefficient modification -----------------------------------------------------------------------
            method_coefficient_props = {'a', 'b'};
            extrap_coefficient_props = {'a_extrapolate', 'b_extrapolate'};
            description_props        = {'name', 'description', 'order'};
            this.mutable_props       = [method_coefficient_props, extrap_coefficient_props, description_props];
            
        end
        
        function setClassProps(this, prop_struct)
            setClassProps@DI_BLKConst(this, prop_struct);
            
            % -- recompute fields if coefficient matrices are redefined ------------------------------------------------
            fields = fieldnames(prop_struct);
            if(any(contains(fields, {'A', 'B', 'C', 'D'}))) 
                this.verifyCefficientMatrices();
                this.setNonZeroMatrixIndices();
            end
        end
        
    end
    
end