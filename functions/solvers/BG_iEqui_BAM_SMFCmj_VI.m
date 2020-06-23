function [BLKGenerator, MG] = BG_iEqui_BAM_SMFCmj_VI(node_precision)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if(nargin < 1)
    node_precision = 'double';
end

node_ordering  = 'inwards';

% -- select method --------------------------------------------------------------------------------
MG = PBMGenerator(struct( ...
    'NodeSet_generator', IEquiNSG(node_ordering, node_precision), ...
    'ODEPoly_generator', Adams_PG('PMFO', 'SMFOmj', VariableInputEPG(), 'diagonally_implicit') ...
    ));

% -- select extrapolation -------------------------------------------------------------------------
EG = PBMGenerator(struct( ...
    'NodeSet_generator', IEquiNSG(node_ordering, node_precision), ...
    'ODEPoly_generator', YExtrap_PG('PMFO') ...
    ));

BLKGenerator = BLKSolverGenerator( ...
    struct(...
    'solver_class',              @MutableDIBLK, ...
    'method_generator',          MG, ...
    'extrapolator_generator',    EG, ...
    'output_coefficient_handle', @Output_IEquiAdams_SMFC, ...
	'name',                      'iEqui-BAM-SMFCmj-VI' ...
    ) ...
);

end