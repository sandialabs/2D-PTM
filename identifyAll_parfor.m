function ptmInfo = identifyAll_parfor(p2dshift,threshold,edgeStatus)
% Function that reads in an array of atom peaks and optionally a threshold 
% value and an edge status. Returns a data structure file including the x 
% and y coordinates, the lattice structure, the rotation angle, the least 
% rmsd of each atom peak, and the centrosymmetry value, scaling factor, and
% the nearest neighbors. The Delaunay triangulation of the atom peaks is
% also included in the data structure.
%
% Inputs:
% p2dshift-> an array of atom peaks taken from a 2D image (see the
%            atom_detect function)
%
% The next two inputs must be given in order, but an input can
% be skipped by putting [] as a placeholder.
%
% threshold (optional)-> the maximum rmsd value allowed before an atom is
%                        designated as "other". If no input is given, the
%                        threshold value will be automatically set to .05.
% edgeStatus (optional)-> either 'on' or 'off' (default is off). Determines
%                         whether or not there are unidentified atoms in
%                         black around the edges of the image.
%
%       Example calls:
%           ptmInfo=identifyAll_parfor(p2dshift);
%           ptmInfo=identifyAll_parfor(p2dshift,.04);
%           ptmInfo=identifyAll_parfor(p2dshift,.06,'on');
%           ptmInfo=identifyAll_parfor(p2dshift,[],'on');
%
% Outputs:
% ptmInfo-> a data structure with 8 fields. The first 7 fields are arrays 
%           with N rows, where N is the number of atoms in p2dshift. The
%           fields are as follows:
%       xy: x and y coordinates (Nx2 array)
%       structure: structure number (Nx1 array)
%                  (1 for FCC, 2 for BCC, 3 for HCP, 0 for other)
%       angle: rotation angle in degrees (Nx1 array) 
%                  (NaN for other/unidentified)
%       rmsd: least rmsd value (Nx1 array)
%                  (NaN for other/unidentified)
%       csm: centrosymmetry value (Nx1 array)
%                  (NaN for other/unidentified)
%       scalingFactor: the scaling factor s that was applied to match an
%                      array of points to a structure template (Nx1 array)
%                  (NaN for other/unidentified)
%       nearestNeighbors: nearest neighbor lists (Nx1 cell array, each cell
%                         has a different length depending on how many
%                         nearest neighbors the atoms have)
%       DT: a structure with 2 fields. The first field is the Points
%           property of a delaunayTriangulation object (Nx2 array); the 
%           second field is the ConnectivityList of a delaunayTriangulation 
%           object.
tic

% Read in optional variables
if nargin < 2 || isempty(threshold)
    threshold=.05;
end

if nargin < 3 || isempty(edgeStatus)
    edgeStatus='off';
end

% Initialize arrays/structures to store information
numAtoms=length(p2dshift);
pointsArray=zeros(numAtoms,7);
NNcell=cell(numAtoms,1);

ptmInfo.xy=zeros(numAtoms,2);
ptmInfo.structure=zeros(numAtoms,1);
ptmInfo.angle=zeros(numAtoms,1);
ptmInfo.rmsd=zeros(numAtoms,1);
ptmInfo.csm=zeros(numAtoms,1);
ptmInfo.scalingFactor=zeros(numAtoms,1);

% Templates for FCC, BCC, and HCP (include within the function instead of
% calling a script to allow for the parfor loop)

numTemplates=3;

% FCC
aFCC=1;
tmpltFCC = [ 0,                0;...
             aFCC*sqrt(6)/4,   0;...
             aFCC/sqrt(6),     aFCC/sqrt(3);...
             -aFCC*sqrt(6)/12, aFCC/sqrt(3);...
             -aFCC*sqrt(6)/4,  0;...
             -aFCC/sqrt(6),    -aFCC/sqrt(3);...
             aFCC*sqrt(6)/12,  -aFCC/sqrt(3)];

% BCC
% BCC lattice parameter defined with respect to the FCC lattice parameter
% (close packed direction)
aBCC=aFCC*sqrt(6)/3;
tmpltBCC = [ 0,               0;...
             aBCC*sqrt(6)/3,  0;...
             aBCC*sqrt(6)/6,  aBCC*sqrt(2)/2;...
             -aBCC*sqrt(6)/6, aBCC*sqrt(2)/2;...
             -aBCC*sqrt(6)/3, 0;...
             -aBCC*sqrt(6)/6, -aBCC*sqrt(2)/2;...
             aBCC*sqrt(6)/6,  -aBCC*sqrt(2)/2];

% HCP
% HCP lattice parameter defined with respect to the FCC lattice parameter
% (close packed direction)
aHCP=aFCC/sqrt(2);
tmpltHCP = [ 0,               0;...
              aHCP*sqrt(3)/2,  0;...
              aHCP*sqrt(3)/6,  aHCP*sqrt(6)/3;...
              -aHCP*sqrt(3)/3, aHCP*sqrt(6)/3;...
              -aHCP*sqrt(3)/2, 0;...
              -aHCP*sqrt(3)/3, -aHCP*sqrt(6)/3;...
              aHCP*sqrt(3)/6,  -aHCP*sqrt(6)/3];

% Find the Delaunay triangulation of your p2dshift array
DT=delaunayTriangulation(p2dshift);
Edges=edges(DT);

% Use a loop to pull out structure type, angle, rmsd value, centrosymmetry
% value, and scaling factor and store in our array
parfor i=1:numAtoms
    % Find nearest neighbors (function: NN_finder_DT)
    [nnList,vArraySorted] = NN_finder_DT(DT,Edges,i);
    % Use a temporary array to allow for parfor loop
    tempArray=zeros(1,7);
    % If there aren't 6 nearest neighbors, assign the atom as unidentified
    if length(vArraySorted)~=7
        tempArray(1,1:2)=vArraySorted(1,:);
        tempArray(1,4:7)=NaN;
    % Otherwise, find all the information we need (function: findAll)
    else
        [tmpltTracker,theta,rmsd,csm,s]=findAll(vArraySorted,threshold,tmpltFCC,...
                                tmpltBCC,tmpltHCP,numTemplates);
        tempArray(1,1:2)=vArraySorted(1,:);
        tempArray(1,3)=tmpltTracker;
        tempArray(1,4)=theta;
        tempArray(1,5)=rmsd;
        tempArray(1,6)=csm;
        tempArray(1,7)=s;
    end
    % Transfer info from our tempArray to our pointsArray
    pointsArray(i,:)=tempArray;
    NNcell{i}=nnList;
end

% If edgeStatus is "off", remove the unidentified atoms at the edges of the
% image (cutoff value may need to be changed depending on the size of the
% image, but works in many cases)
if strcmp(edgeStatus,'off')==1
    % Define a section to remove atoms from
    cutoff=25; % Can be adjusted depending on size of image
    xmin=min(pointsArray(:,1))+cutoff;
    xmax=max(pointsArray(:,1))-cutoff;
    ymin=min(pointsArray(:,2))+cutoff;
    ymax=max(pointsArray(:,2))-cutoff;

    % Find unidentified (structure type = 0) atoms within the cutoff range
    xminValues=pointsArray(:,1)<xmin & pointsArray(:,3)==0;
    xmaxValues=pointsArray(:,1)>xmax & pointsArray(:,3)==0;
    yminValues=pointsArray(:,2)<ymin & pointsArray(:,3)==0;
    ymaxValues=pointsArray(:,2)>ymax & pointsArray(:,3)==0;

    % Remove the atoms
    pointsArray(xminValues,1:3)=NaN;
    pointsArray(xmaxValues,1:3)=NaN;
    pointsArray(yminValues,1:3)=NaN;
    pointsArray(ymaxValues,1:3)=NaN;
end

% Sort array by structure type
pointsArray=sortrows(pointsArray,3);

% Pull out info from our pointsArray and save it to our structure
ptmInfo.xy=pointsArray(:,1:2);
ptmInfo.structure=pointsArray(:,3);
ptmInfo.angle=pointsArray(:,4);
ptmInfo.rmsd=pointsArray(:,5);
ptmInfo.csm=pointsArray(:,6);
ptmInfo.scalingFactor=pointsArray(:,7);

% Save the nearest neighbors cell to our structure
ptmInfo.nearestNeighbors=NNcell;

% Save the DT Points and ConnectivityList to our structure
DTinfo.Points=DT.Points;
DTinfo.ConnectivityList=DT.ConnectivityList;
ptmInfo.DT=DTinfo;

toc