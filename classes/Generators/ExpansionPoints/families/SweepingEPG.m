classdef SweepingEPG < JD_ExpansionPointGenerator
    
    properties
        prioritize_UHP = true; % In the event that an expansion point can be either z or z^* and prioritize_UHP = true, then it will be chosen in upper half plane.
        preserve_sym   = true; % If possible preserve symmetry between upper and lower plane
    end
    
    methods
        
        function this = SweepingEPG(options)
            %FixedInputEPG generic constructor
            % == Parameters ============================================================================================
            % 1. options (struct) - struct with following fields
            %                           > 'ell' (integer) - ranges from 1 to q, and classifies which input point to use.
            % ==========================================================================================================
            if(nargin < 1)
                options = struct();
            end
            options = setDefaultOptions(options, {{'prioritize_UHP', true}, {'preserve_sym', true}});
            this.prioritize_UHP = options.prioritize_UHP;
            this.preserve_sym   = options.preserve_sym;
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
            
            q = DS.q;
            m = DS.m;
            z_in  = DS.z_in;
            z_out = DS.z_out;
            ordering = DS.node_ordering;
            
            if(strcmp(ordering, 'inwards'))
                if(mod(q,2) == 0) % -- q even --------------------------------------------------------------------------
                    if(mod(m,2) == 0) % -- m even ----------------------------------------------------------------------
                        if(j <= 2)
                            b = this.CATexpansionPointHandle(z_in(j), false);
                        else
                            b = this.CATexpansionPointHandle(z_out(j-2), true);
                        end
                    else % -- m odd ------------------------------------------------------------------------------------
                        if(m == 1)
                            if(this.prioritize_UHP)
                                b = this.CATexpansionPointHandle(z_in(1), false);
                            else
                                b = this.CATexpansionPointHandle(z_in(2), false);
                            end
                        elseif(j <= 2)
                            b = this.CATexpansionPointHandle(z_in(j), false);
                        elseif(j < m)
                            b = this.CATexpansionPointHandle(z_out(j - 2), true);
                        else % j = m
                            if(this.prioritize_UHP)
                                b = this.CATexpansionPointHandle(z_out(m - 2), true);
                            else
                                b = this.CATexpansionPointHandle(z_out(m - 1), true);
                            end
                        end
                    end
                else % --------------- q odd ---------------------------------------------------------------------------
                    if(mod(m, 2) == 0) % -- m even ---------------------------------------------------------------------
                        if(j <= 2)
                            b = this.CATexpansionPointHandle(z_in(j), false);
                        else
                            b = this.CATexpansionPointHandle(z_out(j-2), true);
                        end
                    else % -- m odd ------------------------------------------------------------------------------------
                        if(j <= 2)
                            b = this.CATexpansionPointHandle(z_in(j), false);
                        elseif(j < m)
                            b = this.CATexpansionPointHandle(z_out(j - 2), true);
                        else % j = m
                            if(this.preserve_sym)                           
                                b = this.CATexpansionPointHandle(z_in(q), false);
                            elseif(this.prioritize_UHP)
                                b = this.CATexpansionPointHandle(z_out(m - 2), true);
                            else
                                b = this.CATexpansionPointHandle(z_out(m - 1), true);
                            end
                        end
                    end
                end
            elseif(strcmp(ordering, 'outwards'))
                if(mod(q,2) == 0) % -- q even --------------------------------------------------------------------------
                    if(mod(m, 2) == 0) % -- m even ---------------------------------------------------------------------
                        if(j <= 2)
                            b = this.CATexpansionPointHandle(z_in(j), false);
                        else
                            b = this.CATexpansionPointHandle(z_out(j - 2), true);
                        end
                    else % -- m odd ------------------------------------------------------------------------------------
                        if(j == 1)
                            if(this.prioritize_UHP)
                                b = this.CATexpansionPointHandle(z_in(1), false);
                            else
                                b = this.CATexpansionPointHandle(z_in(2), false);
                            end
                        elseif(j <= 2)
                            b = this.CATexpansionPointHandle(z_out(1), true);
                        else
                            b = this.CATexpansionPointHandle(z_out(j - 2), true);
                        end
                    end
                else % --------------- q odd ---------------------------------------------------------------------------
                    if(mod(m, 2) == 0) % -- m even ---------------------------------------------------------------------
                        if(j <= 2)
                            b = this.CATexpansionPointHandle(z_in(1), false);
                        else
                            b = this.CATexpansionPointHandle(z_out(j - 2), true);
                        end
                    else % -- m odd ------------------------------------------------------------------------------------
                        if(j == 1)
                            b = this.CATexpansionPointHandle(z_in(1), false);
                        elseif(j <= 3)
                            b = this.CATexpansionPointHandle(z_out(1), true);
                        else
                            b = this.CATexpansionPointHandle(z_out(j-2), true);
                        end
                    end
                end
            else
                error('Invalid Ordering for Endpoint');
            end
        end
        
    end
    
end