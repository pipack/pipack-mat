function [BLKGenerator, MG] = BG_iEqui_BBDF_pmfc(node_precision, use_spmd)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if(nargin < 1)
    node_precision = 'double';
end
if(nargin < 2)
    use_spmd = true;
end

node_ordering  = 'rclassical';

% -- select method --------------------------------------------------------------------------------
MG = PBMGenerator(struct( ...
    'NodeSet_generator', IEquiNSG(node_ordering, node_precision), ...
    'ODEPoly_generator', BDF_PG('PMFO', 'diagonally_implicit') ...
    ));

% -- select extrapolation -------------------------------------------------------------------------
EG = PBMGenerator(struct( ...
    'NodeSet_generator', IEquiNSG(node_ordering, node_precision), ...
    'ODEPoly_generator', YExtrap_PG('PMFO') ...
    ));

if(use_spmd)
    solver_class = @MutableDIPBLK;
else
    solver_class = @MutableDIBLK;
end


BLKGenerator = BLKSolverGenerator( ...
    struct(...
    'solver_class',              solver_class, ...
    'method_generator',          MG, ...
    'extrapolator_generator',    EG, ...
    'output_coefficient_handle', @Output_IEquiBBDF_PMFC, ...
	'name',                      'iEqui-BBDF-pmfc' ...
    ) ...
);

end