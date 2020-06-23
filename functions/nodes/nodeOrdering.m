function ordering = nodeOrdering(z)
%NODEORDERING Classify the node ordering
% == Parameters ========================================================================================================
% 1. z      (vector) - nodes to identify
% == Returns ===========================================================================================================
% 1. ordering (char) - node type. can be any of the following: 'real', 'imaginary', 'imaginary_realsymmetric', 'unknown'
% ======================================================================================================================

z        = nodeRound(z);  % imaginary rounding errors can cause misclassification of node type
ordering = 'unknown';
type     = nodeType(z);
switch type
    case 'real'
        if(issorted(z, 'ascend'))
            ordering = 'rightsweep';
        elseif(issorted(z, 'descend'))
            ordering = 'leftsweep';
        end
    case 'imaginary_realsymmetric'
        isInwards   = @(a, b) (abs(a) > abs(b)) || (abs(a) == abs(b) && imag(a) >= imag(b));
        isOutwards  = @(a, b) (abs(a) < abs(b)) || (abs(a) == abs(b) && imag(a) >= imag(b));
        isClassical = @(a, b) (imag(a) > imag(b));
        isRClassical = @(a, b) (imag(a) < imag(b));
        
        if(isSortedF(isInwards, z))
            ordering = 'inwards';
        elseif(isSortedF(isOutwards, z))
            ordering = 'outwards';
        elseif(isSortedF(isClassical, z))
            ordering = 'classical';
        elseif(isSortedF(isRClassical, z))
            ordering = 'rclassical';
        end       
end
end

function sorted = isSortedF(f, x)
    sorted = true;
    for i = 1 : length(x) - 1
        if(~f(x(i), x(i+1)))
            sorted = false;
            break;
        end            
    end
end