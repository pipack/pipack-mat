classdef PBMGenerator < PBCRGenerator
    
    methods
        
        % override public method generate to allow for simplified calling sequence.
        function ODEP = generate(this, q)
            %GENERATE Returns the a PBM with q inputs. This method wraps the protected method generate_ to ensure 
            % that the calling sequence is identical across subclasses. Subclases SHOULD NOT override this method.
            % == Parameters ============================================================================================
            % 1. q      (integer) - total number of input nodes
            % == Returns ===============================================================================================
            % 1. ODEP   (vector)  - indices of active input nodes
            % ==========================================================================================================
            ODEP = this.generate_(q, q);
        end
    end
    
end
