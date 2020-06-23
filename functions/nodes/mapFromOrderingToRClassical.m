function [j_order] = mapFromOrderingToRClassical(j, q, order)
%MAPFROMCLASSICALTONEWORDERING maps point indices from order to reversed classical ordering.
% = Parameters =============================================================================================
%   j               (integer or vector) - index or indices of current node in classical ordering
%   q               (integer)           - number of total nodes
%   order           (string)            - desired new ordering
% = Returns ================================================================================================
%   j_order         (integer or vector) - cooresponding indices in new ordering
% ==========================================================================================================

j_order = zeros(size(j));
even_ind = mod(j,2) == 0;
odd_ind  = ~even_ind;

if(any(strcmp(order, {'rclassical', 'leftsweep'})))
    j_order = j;
elseif(any(strcmp(order, {'classical', 'rightsweep'})))
    j_order = q - j + 1;
elseif(strcmp(order, 'inwards'))
    j_order(odd_ind)  = q - (j(odd_ind) - 1)/2;
    j_order(even_ind) = j(even_ind)/2;
elseif(strcmp(order, 'outwards'))
    if(mod(q,2) == 0)
        j_order(odd_ind)  = q/2 + (j(odd_ind) + 1)/2;
        j_order(even_ind) = q/2 - (j(even_ind)-2)/2;
    else
        j_order(odd_ind)  = ceil(q/2) - (j(odd_ind)-1)/2;
        j_order(even_ind) = ceil(q/2) + j(even_ind)/2;
    end
else
    warning('invalid node ordering provided');
    j_order = j;
end

end