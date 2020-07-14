function [BLKGenerator, MG] = BG_iEqui_BAM_PMFCmj_VI(node_precision, node_ordering)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if(nargin < 1)
    node_precision = 'double';
end
if(nargin < 2)
    node_ordering = 'inwards';
end

if(~any(strcmp(node_ordering, {'inwards', 'outwards'})))
    node_ordering  = 'inwards'; % use inwards for sweeping EPG endpoints
    warning('Invalid node ordering; must be "inwards" or "outwards". Code will use inwards')
end

if(strcmp(node_ordering, 'inwards'))
    name = 'iEqui-BAM-PMFCmj-SW-';
elseif(strcmp(node_ordering, 'outwards'))
    name = 'iEqui-OS-BAM-PMFCmj-SW-';
end

% -- select method --------------------------------------------------------------------------------
MG = PBMGenerator(struct( ...
    'NodeSet_generator', IEquiNSG(node_ordering, node_precision), ...
    'ODEPoly_generator', Adams_PG('SMVO', 'PMFOmj', SweepingEPG(), 'diagonally_implicit') ...
    ));

% -- select extrapolation -------------------------------------------------------------------------
EG = PBMGenerator(struct( ...
    'NodeSet_generator', IEquiNSG(node_ordering, node_precision), ...
    'ODEPoly_generator', YExtrap_PG('PMFO') ...
    ));

solver_class = @MutableDIBLK;
BLKGenerator = BLKSolverGenerator( ...
    struct(...
    'solver_class',              solver_class, ...
    'method_generator',          MG, ...
    'extrapolator_generator',    EG, ...
    'output_coefficient_handle', @Output_IEquiAdams_PMFC, ...
	'name',                      name ...
    ) ...
);

end