% AbstractGenerator for Polynomial block coursener and refiners

classdef APBCRGenerator < handle
    
    methods
        function method = generate(this, q, m)
            %GENERATE Returns the a PBCR with q inputs. This method wraps the protected method generate_ to ensure 
            % that the calling sequence is identical across subclasses. Subclases SHOULD NOT override this method.
            % == Parameters ============================================================================================
            % 1. q      (integer) - total number of input nodes
            % 2. m      (integer) - total number of output nodes
            % == Returns ===============================================================================================
            % 1. method    (PBCR) - polynomial block coarsener and refiner
            % ==========================================================================================================
            method = this.generate_(q, m);
        end
    end
    
    methods(Abstract, Access = protected)
        generate_(this, q, m); % protected function wrapped by public function generate.        
    end
    
 
end

