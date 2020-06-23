function [a, b, c, d, e] = Output_ISym_Generic(method_param_struct, options_struct)
%OUTPUT_GENERIC Generates the output coefficients for methods with imaginary symmetric nodes
% Arguments
%   method_param_struct     (struct) - information passed from BLKSolverGenerator class.
%   options                 (struct) - specific option for PBCR method that determned the outputs. Must contain the
%                                      fields:
%           "InputNodeGenerator"      (NodeSetGenerator) - input nodes of method
%           "InputNodeGeneratorArgs"  (cell)             - all arguments for initializing InputNodeGenerator
%           "OutputNodeGenerator"     (NodeSetGenerator) - input nodes of method
%           "OutputNodeGeneratorArgs" (cell)             - all arguments for initializing OutputNodeGenerator
%           "ODEPGenerator"           (JD_ODEPolynomialGenerator) - input nodes of method
%           "ODEPGeneratorArgs"       (cell)             - all arguments for initializing OutputNodeGenerator
% Returns
%       a - 1xq coefficient vector for y^{[n]}
%       b - 1xq coefficient matrix for f^{[n]}
%       c - 1xq coefficient matrix for y^{[n+1]}
%       d - 1xq coefficient matrix for f^{[n+1]}
%       e - 1x1 coefficient vector for f_out
% ======================================================================================================================

node_ordering  = method_param_struct.node_ordering;
q              = method_param_struct.q;
alpha          = method_param_struct.alpha;

if(mod(q, 2) == 0) % if q is even then z = 0 is not a member of z_in ---------------------------------------------------
    
    
    % -- Input Nodes for output method (should be identical to those of underlying method) -----------------------------
    InputNodeGenerator      = options_struct.InputNodeGenerator;
    InputNodeGeneratorArgs  = options_struct.InputNodeGeneratorArgs;

    % -- Output Nodes for output method (should be identical to those of underlying method union {0})-------------------
    OutputNodeGenerator     = options_struct.OutputNodeGenerator;
    OutputNodeGeneratorArgs = options_struct.OutputNodeGeneratorArgs;

    % -- ODEP for output method ----------------------------------------------------------------------------------------
    ODEPGenerator           = options_struct.ODEPGenerator;
    ODEPGeneratorArgs       = options_struct.ODEPGeneratorArgs;
    
    % -- generate coarsener/refinder with q = q, m = q + 1 and z_out = z_in \union {0} ---------------------------------
    OG = PBCRGenerator(struct( ...
        'NodeSet_generator', {
            {InputNodeGenerator(InputNodeGeneratorArgs{:}) 
            OutputNodeGenerator(OutputNodeGeneratorArgs{:}) 
         }}, ...
        'ODEPoly_generator', ODEPGenerator(ODEPGeneratorArgs{:}) ...
        ));
    method = OG.generate(q, q + 1);
    [A, B, C, D] = method.blockMatrices(alpha, 'full_traditional');
    
    % -- compute output index for z = 0 (i.e. z_out(output_index) = 0) -------------------------------------------------
    switch node_ordering
        case 'classical'
            output_index = q / 2 + 1;   % z = 0 is middle point
        case 'rclassical'
            output_index = q / 2 + 1;   % z = 0 is middle point
        case 'inwards'
            output_index = q + 1;       % z = 0 is the last point
        case 'outwards'
            output_index = 1;           % z = 0 is the first pout
    end
    
    mapped_output_inds  = setdiff(1 : q + 1, output_index); % indices of outputs cooresponding to z_in + alpha
    a = A(output_index, 1:q);
    b = B(output_index, 1:q);
    c = C(output_index, mapped_output_inds);
    d = D(output_index, mapped_output_inds);
    e = D(output_index, output_index);
else % if q is odd then z = 0 is a member of z_in ----------------------------------------------------------------------
    
    switch node_ordering
        case 'classical'
            output_index = ceil(q / 2);  % index of z_output
        case 'rclassical'
            output_index = ceil(q / 2);  % index of z_output
        case 'inwards'
            output_index = q;
        case 'outwards'
            output_index = 1;
    end
    
    a = zeros(q, 1);
    b = zeros(q, 1);
    c = [zeros(output_index - 1, 1); 1; zeros(q - output_index, 1)];
    d = zeros(q, 1);
    e = 0;
end
end
