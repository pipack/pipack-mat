% ======================================================================================================================
%   ODE Polynomial:
%
%   An Abstract class for implementing an general ODE polynomial
%
%       p(\tau; b) = \sum_{j=0}^{g} \frac{a_{j}(b)(\tau - b)^j}{j!}
%
%   where p(\tau; b) approximates the ODE solution y(\tau).
%
%   > Properties
%
%        ApproxDerivAAIIndices  (array) - array whose length corresponds to the order of the ODE polynomial and whose  
%                                         ith element indicates the index of the stencil used for the (i-1)th derivative
%                                         approximation. i.e. y_stencil{y_stencil_indices(i)} is used to compute the 
%                                         (i-1)th derivative of ODE polynomial.
%
%        ActiveIndexSets        (cell)  - cell array of objects that inherit from ActiveIndexSet class.
%
%        b                      (real)  - expansion point of the ODE polynomial.
%
%   > Properties: Computable
%
%        degree  - the degree of ODE polynomial
%
%   > Methods
%       coefficients - computes coefficients for evaluating the ODE polynomial at a specific point
%
% ======================================================================================================================

classdef ODE_SolutionPolynomial < ODE_Polynomial
    
    methods(Access = protected)
       
        % === START COEFFICIENT FUNCTIONS ==============================================================================
        
        function [W] = approxDerivativeMatrix(this, ActIndSet, b, alpha, ODE_DS, IVS)
            %SCALEDYDIFFERENTIATIONMATRIX returns the weights for computing approximate derivatives arising from a 
            % polynomial that is constructed from the specified ActiveIndexSet. The jth row contains weights for the 
            % scaled approximate derivatives a_j(b) / j!
            % = Parameters =============================================================================================
            %   1. ActIndSet    (Active Index Set) - active index set for interpolating polynomial.
            %   2. b            (real)             - point where scaled derivatives are required.
            %   3. ODE_DS       (ODE_Dataset)      - underlying ODE dataset.
            %   4. IVS          (IVS)              - interpolated value set.
            % = Returns ================================================================================================
            %   1. W            (matrix)  - matrix of weights for computing derivatives. jth row contains weights for 
            %                               scaled derivative y^{(j-1)}(b) / (j-1)!                          
            % ==========================================================================================================
            
            % -- read dataset parameters -------------------------------------------------------------------------------
            if(isempty(IVS))
                nodes = vcat(true, ODE_DS.nodeVector(alpha));
            else
                nodes = vcat(true, ODE_DS.nodeVector(alpha), IVS.nodeVector(alpha));
            end
            
            if(ActIndSet.only_derivative_values_active)
                A = ActIndSet.ActiveDerivativeIndexSet(ODE_DS);
                B = [];
                W = this.weights(nodes, b, A, B);
                if(isnumeric(nodes))
                    C = diag(1 ./ (1:length(A)));
                    W = [zeros(1, length(A)); C*W];
                else
                    C = diag(1 ./ sym(1:length(A)));
                    W = [sym(zeros(1, length(A))); C*W];
                end
            else
                A = ActIndSet.ActiveSolutionIndexSet(ODE_DS);
                B = ActIndSet.ActiveDerivativeIndexSet(ODE_DS);
                W = this.weights(nodes, b, A, B);
            end
        end
        
    end
    
end