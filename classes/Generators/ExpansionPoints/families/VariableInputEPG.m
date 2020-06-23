% ======================================================================================================================
%   Sliding Inputs
%
%   Methods
%
% ======================================================================================================================

classdef VariableInputEPG < JD_ExpansionPointGenerator
    
    methods(Access = protected)
        
        function b = generate_(this, j, DS)
            %GENERATE_ - returns jth expansion point
            % == Parameters ============================================================================================
            % 1. j          (integer)     - output index
            % 2. DS         (ODE_Dataset) - underlying ODE dataset
            % == Returns ===============================================================================================
            % 1. b (function_handle) - function handle that returns the expansion point as a function of alpha
            % ==========================================================================================================
            
            if(DS.q < DS.m)
                error('This endpoint requires m <= q');
            end
            b  = this.CATexpansionPointHandle(DS.z_in(j), false);
        end
        
    end
    
end