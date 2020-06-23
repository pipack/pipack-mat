
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

classdef MutableDIBLK < DI_BLKConst
        
    properties(SetAccess = protected)
        A % A Matrix
        B % B Matrix
        C % C Matrix
        D % D Matrix
        % -- congugate properties --------------------------------------------------------------------------------------
        conjugate_inputs       % integer vector. if ith position is zero, then jth output should be computed. if jth position is non-zero then jth output has conjugate whose index is conjugate_inputs(j)  
        conjugate_outputs      % integer vector. if ith position is zero, then jth output should be computed. if jth position is non-zero then jth output has conjugate whose index is conjugate_outputs(j)
        real_valued_outputs    % bool vector. if ith position is true, then ith output can be computed using only real arithmetic after clipping imaginary parts
        % -- propeties for IntegratorConst -----------------------------------------------------------------------------
        name = 'MutableDIBLK'
        description = 'Mutable Diagonally Implicit Block Method'
        order = [];
    end
    
	properties
        % -- propeties for DI_BLKConst -----------------------------------------------------------------------------
        eval_RHS  = false;                 % boolean - if true RHS will evaluated directly, otherwise F will algebraically obtained after nonlinear solve
        parallel_initial_guess = true;     % if false, previously computed outputs may be used as initial conditions. If true, only initial conditions will be used as guess 
        extrapolate_initial_guess = false; % if true coefficients A_extrapolate and B_extrapolate will be used to form initial guess for any nonlinear systems
        % -- propeties for IntegratorConst -----------------------------------------------------------------------------
        graph_line_style;
   end
     
    methods
        
        function this = MutableDIBLK(options)
            if(nargin == 0)
                options = struct();
            end
            this = this@DI_BLKConst(options);
            
            % -- enable coefficient modification -----------------------------------------------------------------------
            method_coefficient_props = {'A', 'B', 'C', 'D'};
            extrap_coefficient_props = {'A_extrapolate', 'B_extrapolate'};
            output_coefficient_props = {'a_out', 'b_out', 'c_out', 'd_out', 'e_out'};
            output_props             = {'conjugate_inputs', 'conjugate_outputs', 'real_valued_outputs'};
            description_props        = {'name', 'description', 'starting_times', 'order'};
            this.mutable_props       = [method_coefficient_props, extrap_coefficient_props, ...
                output_coefficient_props, output_props, description_props];
            
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