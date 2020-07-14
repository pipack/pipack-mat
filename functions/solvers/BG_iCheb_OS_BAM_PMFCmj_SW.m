function [BLKGenerator, MG] = BG_iCheb_OS_BAM_PMFCmj_SW(node_precision)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if(nargin < 1)
    node_precision = 'double';
end

node_ordering = 'outwards';

% -- select method --------------------------------------------------------------------------------
MG = PBMGenerator(struct( ...
    'NodeSet_generator', IChebNSG(node_ordering, node_precision), ...
    'ODEPoly_generator', Adams_PG('SMVO', 'PMFOmj', SweepingEPG(), 'diagonally_implicit') ...
    ));

% -- select extrapolation -------------------------------------------------------------------------
EG = PBMGenerator(struct( ...
    'NodeSet_generator', IChebNSG(node_ordering, node_precision), ...
    'ODEPoly_generator', YExtrap_PG('PMFO') ...
    ));

solver_class = @MutableDIBLK;
BLKGenerator = BLKSolverGenerator( ...
    struct(...
    'solver_class',              solver_class, ...
    'method_generator',          MG, ...
    'extrapolator_generator',    EG, ...
    'output_coefficient_handle', @Output_IChebAdams_PMFC, ...
    'name',                      'iCheb-BAM-PMFCmj-SW-' ...
    ) ...
);

end