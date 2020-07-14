function [BLKGenerator, MG] = BG_iCheb_BAM_SMFCmj_FI3(node_precision, node_ordering)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if(nargin < 1)
    node_precision = 'double';
end
if(nargin < 2)
    node_ordering = 'inwards';
end

if(~any(strcmp(node_ordering, {'inwards', 'outwards'})))
    node_ordering  = 'inwards';
    warning('Invalid node ordering; must be "inwards" or "outwards". Code will use inwards')
end

% -- select method --------------------------------------------------------------------------------
MG = PBMGenerator(struct( ...
    'NodeSet_generator', IChebNSG(node_ordering, node_precision), ...
    'ODEPoly_generator', Adams_PG('PMFO', 'SMFOmj', FixedInputEPG(struct('l', 3)), 'diagonally_implicit') ...
    ));

% -- select extrapolation -------------------------------------------------------------------------
EG = PBMGenerator(struct( ...
    'NodeSet_generator', IChebNSG(node_ordering, node_precision), ...
    'ODEPoly_generator', YExtrap_PG('PMFO') ...
    ));

BLKGenerator = BLKSolverGenerator( ...
    struct(...
    'solver_class',              @MutableDIBLK, ...
    'method_generator',          MG, ...
    'extrapolator_generator',    EG, ...
    'output_coefficient_handle', @Output_IChebAdams_SMFC, ...
    'name',                      'iCheb-BAM-SMFCmj-FI3-' ...
    ) ...
);

end