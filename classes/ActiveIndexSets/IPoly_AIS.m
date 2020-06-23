
% ======================================================================================================================
%   IPoly_AIS (Interpolating Polynomial ActiveIndexSet)
%
%   A class which stores the active index set for an interpolating polynomial. This class does not contain 
%   node or data information. It only specifies which data indices are used for interpolation. Its primarily purpose is
%   to represent the interpolating polynomials for computing the approximate derivatives
%
%   > Properties
%
%      1. input_sol_inds  - indices of active input solution values
%      2. input_der_inds  - indices of active input derivative values
%      3. output_sol_inds - indices of active output solution values
%      4. output_der_inds - indices of active output derivative values
%      5. stage_sol_inds  - indices of active stage solution values
%      6. stage_der_inds  - indices of active stage derivative values
%      7. interp_sol_inds - indices of active interpolated solution values
%      8. interp_der_inds - indices of active interpolated derivative values
%
%   > Properties (Computable)
%
%      1. AIISet - Active Input Index Set
%      2. AOISet - Active Output Index Set
%      3. only_active_derivatives - true if only derivative data is active
%
%   > Public Methods
%
%      1. ActiveSolutionIndexSet - index of active solution values relative to dataset's nodevector
%      2. ActiveDerivativeIndexSet - index of active derivative values relative to dataset's nodevector
%
% ======================================================================================================================

classdef IPoly_AIS < handle
    
    properties
        input_sol_inds  = []; % indices of active input solution values
        input_der_inds  = []; % indices of active input derivative values
        output_sol_inds = []; % indices of active output solution values
        output_der_inds = []; % indices of active output derivative values
        stage_sol_inds  = []; % indices of active output solution values
        stage_der_inds  = []; % indices of active output derivative values
        interp_sol_inds = []; % indices of active interpolated solution values
        interp_der_inds = []; % indices of active interpolated derivative values
    end
    
    properties(SetAccess = protected)
        AIISet                              % Active Input Index Set
        AOISet                              % Active Output Index Set
        ASISet                              % Active Output Index Set
        only_derivative_values_active       % true if only derivative data is active
        only_solution_values_active         % true if only solution data is active
        dimension                           % size of the set (total number of active data values)
    end
    
    methods
        
        % -- Constructor -----------------------------------------------------------------------------------------------
        
        function this = IPoly_AIS(param_struct)
            
            fields = {'input_sol_inds', 'input_der_inds', 'output_sol_inds', 'output_der_inds', 'stage_sol_inds', ...
                'stage_der_inds', 'interp_sol_inds', 'interp_der_inds'};
            function setField(obj, par_struc, field)
                if(isfield(par_struc, field))
                    obj.(field) = par_struc.(field);
                end
            end            
            
            if(nargin > 0)
                cellfun(@(f) setField(this, param_struct, f), fields);
            end
               
        end
        
        % -- Computable Properties -------------------------------------------------------------------------------------
        
        function AIISet = get.AIISet(this) % Returns Active Input Index Set
            AIISet = union(this.input_sol_inds, this.input_der_inds);
        end
        
        function AOISet = get.AOISet(this) % Returns Active Output Index Set
            AOISet = union(this.output_sol_inds, this.output_der_inds);
        end
        
        function ASISet = get.ASISet(this) % Returns Active Stage Index Set
            ASISet = union(this.stage_sol_inds, this.stage_der_inds);
        end
        
        function flag = get.only_derivative_values_active(this) % Returns True if only derivative data is active
            if(isempty(vcat(true, this.input_sol_inds, this.output_sol_inds, this.stage_sol_inds, this.interp_der_inds)))
                flag = true;
            else
                flag = false;
            end
        end
        
        function flag = get.only_solution_values_active(this) % Returns True if only solution data is active
            if(isempty(vcat(true, this.input_der_inds, this.output_der_inds, this.stage_der_inds, this.interp_der_inds)))
                flag = true;
            else
                flag = false;
            end
        end
        
        function ind = get.dimension(this)
            ind = length(this.input_sol_inds) + length(this.output_sol_inds) + length(this.stage_sol_inds) + length(this.interp_sol_inds) + ...
                length(this.input_der_inds) + length(this.output_der_inds) + length(this.stage_der_inds) + length(this.interp_der_inds);
        end
        
        % -- Public Methods -------------------------------------------------------------------------------------------
        
        function ASIS = ActiveSolutionIndexSet(this, D) %
            %ACTIVESOLUTIONINDEXSET returns indices of active solution data with respect to the Dataset D's nodevector
            % = Parameters =============================================================================================
            %   1. D        (ODE_Dataset) - underlying ODE dataset
            % = Returns ================================================================================================
            %   1. ASIS     (vector) - Indices of active solution data, ordered by inputs, outputs, stages
            % ==========================================================================================================
            
            shifts = [0 cumsum([D.q, D.m, D.s])];
            ASIS = vcat(true, shifts(1) + this.input_sol_inds, shifts(2) + this.output_sol_inds, shifts(3) + this.stage_sol_inds, shifts(4) + this.interp_sol_inds);
        end
        
        function ADIS = ActiveDerivativeIndexSet(this, D) %
            %ACTIVESOLUTIONINDEXSET returns indices of active derivative data with respect to the Dataset D's nodevector
            % = Parameters =============================================================================================
            %   1. D        (ODE_Dataset) - underlying ODE dataset
            % = Returns ================================================================================================
            %   1. ASIS     (vector) - Indices of active solution data, ordered by inputs, outputs, stages
            % ==========================================================================================================
            
            shifts = [0 cumsum([D.q, D.m, D.s])];
            ADIS = vcat(true, shifts(1) + this.input_der_inds, shifts(2) + this.output_der_inds, shifts(3) + this.stage_der_inds, shifts(4) + this.interp_der_inds);
        end
        
    end
    
end
