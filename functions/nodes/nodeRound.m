function z = nodeRound(z)
%NODEROUND rounds double nodes to approximately 14 digits of precision. Used by node classiciation to prevent 
% misclassification due to round off errors. Symbolic types are also cast to double precision to avoid round-off with vpa
% == Parameters ========================================================================================================
% z (vector) - unrounded nodes
% == Returns ===========================================================================================================
% z (vector) - rounded nodes.
% ======================================================================================================================
    
z = double(z); % cast symbolic types to double
digits = max(1, log(max(abs(z))) / log(10));
z = round(z, 13 - floor(digits));

end

