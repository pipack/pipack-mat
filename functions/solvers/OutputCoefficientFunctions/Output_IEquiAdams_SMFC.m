function [a, b, c, d, e] = Output_IEquiAdams_SMFC(method_param_struct)
%OUTPUT_IEQUIAdamsPMFC Produces Adams PMFC output coefficients for methods with imaginary equispaced Nodes

node_ordering  = method_param_struct.node_ordering;
node_precision = method_param_struct.node_precision;
q              = method_param_struct.q;

options_struct = struct( ...
    "InputNodeGenerator",      @IEquiNSG, ...
    "InputNodeGeneratorArgs",  {{node_ordering, node_precision}}, ...  
    "OutputNodeGenerator",     @EquiZeroNSG, ...    
    "OutputNodeGeneratorArgs", {{node_ordering, node_precision, struct('scale_factor', 1i)}}, ... 
    "ODEPGenerator",           @Adams_PG, ...           
    "ODEPGeneratorArgs",       {{'PMFO', 'SMFO', FixedInputEPG(struct('l', ceil(q/2))), 'diagonally_implicit'}} ...       
);

[a, b, c, d, e] = Output_ISym_Generic(method_param_struct, options_struct);

end