function [X,Y] = stencilEdges(nodes)
%STENCILEDGES determines which stencil edges to draw. 
% == Parameters ========================================================================================================
%   1. nodes (vector or cell) - vector of nodes or cell array containg vectors, which will be merged into one node array.
% == Returns ===========================================================================================================
%   1. X - (matrix) - 2 x m matrix of x coordinates; X(:, j) are x_coordinates of jth line
%   2. Y - (matrix) - 2 x m matrix of y coordinates; Y(:, j) are x_coordinates of jth line

if(iscell(nodes))
    nodes = vcat(true, nodes{:});
end

nodes = unique(nodes);
n = length(nodes);
nodes_x = real(nodes);
nodes_y = imag(nodes);
CM      = zeros(n,n); % connectivity matrix

% -- connect all straight edges ----------------------------------------------------------------------------------------
for i = 1 : n 
    for j = i+1 : n
        if(nodes_x(i) == nodes_x(j) || nodes_y(i) == nodes_y(j))
            CM(i,j) = 1;
        end
    end
end
% -- connect any disjoint nodes ----------------------------------------------------------------------------------------
for i = 1 : n
    if(all(CM(i,:) == 0) && all(CM(:,i) == 0))
        dist = abs(nodes - nodes(i));
        dist(i) = Inf;
        [~, nn_index] = min(dist); % nearest node (excluding self)
        CM(min(i, nn_index),max(i,nn_index)) = 1; % ensure 1 ends up on upper diagonal
    end
end
% convert to x,y line form for plotting
num_lines = sum(CM(:));
X = zeros(2, num_lines);
Y = zeros(2, num_lines);

count = 1;
for i = 1 : n 
    for j = i+1 : n
        if(CM(i,j) == 1)
            X(1, count) = nodes_x(i);
            X(2, count) = nodes_x(j);
            Y(1, count) = nodes_y(i);
            Y(2, count) = nodes_y(j);
            count = count + 1;
        end
    end
end
end