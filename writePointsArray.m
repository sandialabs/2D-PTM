function pointsArray = writePointsArray(ptmInfo,varargin)

% Function that reads in a ptmInfo data structure and optionally saves a 
% file with the x and y positions, structures, angles, rmsd values, 
% centrosymmetry values, and scaling factors of the atom peaks from the 
% original image. This function can also just return the values in an array
% if desired.
%
% Inputs:
% ptmInfo-> a data structure (comes from a call of identifyAll_parfor).
%           Contains all the information listed in the description above.
%
% path (optional)-> the path and file name of the information you want to
%                   save. Options for files include a .csv, .txt, or .dat
%                   file. 
%
% Output:
% pointsArray-> an Nx7 array, where N is the number of atoms in p2dshift
%       Columns 1-2: x and y coordinates
%       Column 3: template number (1 for FCC, 2 for BCC, 3 for HCP, 0 for other)
%       Column 4: rotation angle (in degrees) (NaN for other/unidentified)
%       Column 5: least rmsd value (NaN for other/unidentified)
%       Column 6: centrosymmetry value (NaN for other/unidentified)
%       Column 7: scaling factor between central atom and its nearest
%                 neighbors and its associated structure template
%                 (NaN for other/unidentified)

% Read in the optional path variable
if ~isempty(varargin)
    path=varargin{1};
else
    path=[];
end

% Initialize pointsArray
numAtoms=length(ptmInfo.xy);
pointsArray=zeros(numAtoms,7);

% Pull out info from our ptmInfo structure
pointsArray(:,1:2)=ptmInfo.xy;
pointsArray(:,3)=ptmInfo.structure;
pointsArray(:,4)=ptmInfo.angle;
pointsArray(:,5)=ptmInfo.rmsd;
pointsArray(:,6)=ptmInfo.csm;
pointsArray(:,7)=ptmInfo.scalingFactor;

% Export pointsArray to the designated path
if ~isempty(path)
    writematrix(pointsArray,path)
end