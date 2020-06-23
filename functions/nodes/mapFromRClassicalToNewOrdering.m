function [j_class] = mapFromRClassicalToNewOrdering(j, q, order)
%MAPFROMORDERINGTOCLASSICAL maps point indices from reversed classical / right-sweeping ordering tp any ordering.
%   j               (integer) - index of current node
%   q               (integer) - number of total nodes
%   order           (string)  - current ordering used to generate index j
% = Returns ================================================================================================
%   j_class         (integer or vector) - cooresponding indices in classical ordering
% ==========================================================================================================

j_class      = zeros(size(j));
left_ind   = j <= floor(q/2);
right_ind  = ~left_ind;

if(any(strcmp(order, {'rclassical', 'leftsweep'})))
    j_class = j;
elseif(any(strcmp(order, {'classical', 'rightsweep'})))
    j_class = q - j + 1;
elseif(strcmp(order, 'inwards'))
    j_class(left_ind) = 2*j(left_ind);
    j_class(right_ind)  = 2*q - 2*j(right_ind) + 1;
elseif(strcmp(order, 'outwards'))
    if(mod(q,2) == 0)
        j_class(right_ind) = 2*j(right_ind) - (q + 1);
        j_class(left_ind)  = (q + 2) - 2*j(left_ind);
    else
        left_ind   = j <= ceil(q/2);
        right_ind  = ~left_ind;
        j_class(right_ind) = 2*j(right_ind) - 2*ceil(q/2);
        j_class(left_ind)  = 2*ceil(q/2) + 1 - 2*j(left_ind);
    end
else
    warning('invalid node ordering provided');
    j_class = j;
end

end