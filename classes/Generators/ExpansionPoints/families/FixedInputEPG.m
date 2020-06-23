
% ======================================================================================================================
%   Fixed Input
%
%   Refiners, Projectors, Methods
% ======================================================================================================================

classdef FixedInputEPG < JD_ExpansionPointGenerator
    
    properties
        l = 1;
        prioritize_UHP = true; % In the event that an expansion point can be either z or z^* and prioritize_UHP = true, then it will be chosen in upper half plane. 
        preserve_sym   = true; % If possible preserve symmetry between upper and lower plane
    end
    
    methods
        
        function this = FixedInputEPG(options)
            %FixedInputEPG generic constructor
            % == Parameters ============================================================================================
            % 1. options (struct) - struct with following fields
            %                           > 'ell' (integer) - ranges from 1 to q, and classifies which input point to use.
            % ==========================================================================================================
            if(nargin < 1)
                options = struct();
            end
            options = setDefaultOptions(options, {{'l', 1}, {'prioritize_UHP', true}, {'preserve_sym', true}});
            this.l = options.l;
            this.prioritize_UHP = options.prioritize_UHP;
            this.preserve_sym = options.preserve_sym;
        end
        
        function set.l(this, value)
            if(floor(value) == value && value > 0)
                this.l = value;
            else
                error('property "l" must be a positive integer');
            end
        end
        
    end
    
    methods(Access = protected)
        
        function b = generate_(this, j, DS)
            %GENERATE_ - returns jth expansion point
            % == Parameters ============================================================================================
            % 1. j          (integer)     - output index
            % 2. DS         (ODE_Dataset) - underlying ODE dataset
            % == Returns ===============================================================================================
            % 1. b (function_handle) - function handle that returns the expansion point as a function of alpha
            % ==========================================================================================================
            
            z_input  = DS.z_in;
            ordering = DS.node_ordering;
            ll  = this.l;
            q   = DS.q;
            m   = DS.m;
            
            if(ll < 1 || ll > q)
                error('invalid expansion point parameter l; must satisfy 1 <= l <= q.');
            end
            
            switch DS.node_type
                case 'imaginary_realsymmetric'
                    j_classical = remapOrderingIndex(j, m, ordering, 'rclassical');
                    if(mod(m, 2) == 0) % -- m even ---------------------------------------------------------------------
                        if(j_classical <= m/2)
                            classical_index = ll;
                        else
                            classical_index = q - ll + 1;
                        end
                    else % --------------- m odd -----------------------------------------------------------------------
                        if(j_classical <= floor(m/2))
                            classical_index = ll;
                        elseif(j_classical == ceil(m/2))
                            if(this.preserve_sym && mod(q,2) == 1) % q also odd
                                classical_index = ceil(q/2);
                            elseif(this.prioritize_UHP) % use upper half plane for endpoint corresponding to \tau = 0
                                classical_index = max([ll, q - ll + 1]);
                            else % use upper half plane for endpoint corresponding to \tau = 0
                                classical_index = min([ll, q - ll + 1]);
                            end
                        else
                            classical_index = q - ll + 1;
                        end
                    end
                    % ==================================================================================================
                    b_val = z_input(remapOrderingIndex(classical_index, q, 'rclassical', ordering));
                    b = this.CATexpansionPointHandle(b_val, false);
                otherwise
                    b_val = z_input(ll);
                    b = this.CATexpansionPointHandle(b_val, false);
            end
        end
        
    end
    
end