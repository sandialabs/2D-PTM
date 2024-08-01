function [nnList,vArraySorted] = NN_finder_DT(DT,Edges,idx)
% Function to find nearest neighbors of a given atom using Delaunay
% triangulation
%
% Inputs:
% DT-> the Delaunay triangulation of an array of atom peaks, found using
%      the delaunayTriangulation function
% Edges-> the triangulation edges associated with the Delaunay
%         triangulation (DT), found using the edges function
% idx-> the index of the atom within the p2dshift function that you want to
%       find the nearest neighbors of
%
% Outputs: 
% nnList-> a list of the nearest neighbors, arranged in circular order
% vArraySorted-> a list including the central atom and the nearest neighbors,
%                with the nearest neighbors arranged in circular order

% Find indices of nearest neighbors for the given index
centerPoint=DT.Points(idx,:);
NN_indices=any(Edges==idx,2);

% Pull out the nearest neighbors
endPoints=Edges(NN_indices,:);
nnVerts=DT.Points(endPoints(endPoints~=idx),:);
vArray=[centerPoint;nnVerts];

% Sort the vertices
convex_hull=convhull(vArray);
convex_hull=unique(convex_hull,'stable');
vArraySorted=[vArray(1,:);vArray(convex_hull,:)];
nnList=vArraySorted(2:end,:);