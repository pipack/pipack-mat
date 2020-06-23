function [a, b, c, d, e] = Output_IEquiBGBDF_PMFC(method_param_struct)
%OUTPUT_IEQUIBBDFPMFC Produces BBDF PMFC output coefficients for methods with imaginary equispaced Nodes

node_ordering  = method_param_struct.node_ordering;
node_precision = method_param_struct.node_precision;

options_struct = struct( ...
    "InputNodeGenerator",      @IEquiNSG, ...
    "InputNodeGeneratorArgs",  {{node_ordering, node_precision}}, ...  
    "OutputNodeGenerator",     @EquiZeroNSG, ...    
    "OutputNodeGeneratorArgs", {{node_ordering, node_precision, struct('scale_factor', 1i)}}, ... 
    "ODEPGenerator",           @GBDF_PG, ...           
    "ODEPGeneratorArgs",       {{'PMFO', 'diagonally_implicit'}} ...       
);

[a, b, c, d, e] = Output_ISym_Generic(method_param_struct, options_struct);

end