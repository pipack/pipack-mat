function type = nodeType(z)
%NODETYPE Classify the node type
% == Parameters ========================================================================================================
% 1. z  (vector) - nodes to identify.
% == Returns ===========================================================================================================
% 1. type (char) - node type. can be any of the following: 'real', 'imaginary', 'imaginary_realsymmetric', 'unknown'.
% ======================================================================================================================
z = nodeRound(z);  % imaginary rounding errors can cause misclassification of node type.
if(max(abs(real(z))) == 0)
    if(isempty(setdiff(z, conj(z))))
        type = 'imaginary_realsymmetric';
    else
    	type = 'imaginary';
    end
elseif(max(abs(imag(z))) == 0)
    type = 'real';
else
    type = 'unknown';
end
end