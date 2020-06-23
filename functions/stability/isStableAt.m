function [flags, data] = isStableAt(varargin)
%ISROOTSTABLE determines if a method is stable at certain z = h * lambda values. Two possible calling sequences.
% == Parameters ========================================================================================================
%
%   Possibility 1:
%
%       1. method   (PBM)    - method object
%       2. alpha    (scalar) - extrapolation parameters
%       3. zs       (vector) - z values to test
%       4. options  (struct) - optional parameter struct (fields described below)
%
%   Possibility 2:
%
%       1. amp      (function_handle) - function handle of one argument coorsponding to stability function
%       2. zs       (vector) - z values to test
%       3. options  (struct) - optional parameter struct (fields described below)
%
%    Options Struct Fields:
%
%       > RoundingTol (real) - methods with amplification factors greater than 1 + RoundingTol will be considered
%                              unstable.
%       > NumProcessors (real) - will use spmd if more than one processor is specified
%
%       > ExitOnFail (bool) - if true exits test as soon a unstable value is found
%
%
% == Returns ===========================================================================================================
%   1. flag - flag(i) is true if method is stable at zs(i), false otherwise
%   2. data - data(i) stores amplification factor at z = zs(i).
% ======================================================================================================================

% -- Parse Inputs ------------------------------------------------------------------------------------------------------
[amp, additional_args] = parseStabilityArgs(false, varargin{:});
zs = additional_args{1};
if(length(additional_args) >= 2)
    options = additional_args{2};
else
    options = struct();
end
% -- Set Options -------------------------------------------------------------------------------------------------------
field_value_pairs = { {'RoundingTol', eps * 100}, {'NumProcessors', 1}, {'ExitOnFail', false}};
options = setDefaultOptions(options, field_value_pairs);
stability_threshold = (1 + options.RoundingTol);
EOF = options.ExitOnFail;
% -- reshape zs into vector ----------------------------------------------------------------------------------------
if(~isvector(zs))
    reshape_on_exit = true;
    start_shape = size(zs);
    zs = zs(:);
else
    reshape_on_exit = false;
end

% -- Test Stability ----------------------------------------------------------------------------------------------------
if(options.NumProcessors > 1) % -- parallel implementation -------------------------------------------------------------    
    n = length(zs);
    p = min(n, options.NumProcessors);
    spmd(p)
        indices = parTaskSplit(n, p, labindex, 'contiguous');
        num_inds = length(indices);
        if(isa(stability_threshold, 'sym'))
            data = 2 * stability_threshold * sym(ones(num_inds, 1));            
        else
            data = 2 * stability_threshold * ones(num_inds, 1);
        end
        if(EOF)
            for i = 1 : num_inds
                data(i) = amp(zs(indices(i)));
                if(data(i) > stability_threshold)
                    break;
                end
            end
        else
            for i = 1 : num_inds
                data(i) = amp(zs(indices(i)));
            end
        end
    end
    data = vcat(true, data{:});
else % -- serial implementation ----------------------------------------------------------------------------------------
    if(isnumeric(stability_threshold))
        data = 2 * stability_threshold * ones(size(zs));
    else
        data = 2 * stability_threshold * sym(ones(size(zs)));
    end
    if(EOF)
        for i = 1 : length(zs)
            data(i) = amp(zs(i));
            if(data(i) > stability_threshold)
                break;
            end
        end
    else
        for i = 1 : length(zs)
            data(i) = amp(zs(i));
        end
    end
end
% -- reshape outputs ---------------------------------------------------------------------------------------------------
if(reshape_on_exit)
    data = reshape(data, start_shape);
end
flags = logical(data <= stability_threshold); % logical required for symbolic type
end