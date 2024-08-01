function [Q,vFinal] = QrotationKabsch(vArraySorted,tmpltArray)

% Function that finds the proper rotation to match two input arrays
% ***You must have the Kabsch function downloaded from Matlab to use this 
% function
%
% Inputs:
% vArraySorted-> a sorted list of the central atom and its 6 nearest
%                neighbors (see NN_finder function)
% tmpltArray-> an array that holds the seven atoms of a template for the 
%              FCC, BCC, or an HCP lattice. All of these can be accessed 
%              through the structureTemplates script.
% *The central atom should be the first row in both arrays (should already
% be the case if you have used the code mentioned above)
%
% Outputs:
% Q-> the rotation matrix that aligns the 2 input arrays the best
% vFinal-> a reordered vArraySorted, such that point-to-point correspondence
%          between the input arrays is best suited to find a match

N=length(vArraySorted)-1;
lrms=10^10;
Q=zeros(2);
vFinal=zeros(size(vArraySorted));

% Recenter at origin before rotation
tVector=vArraySorted(1,:);
vArraySorted=vArraySorted-tVector;

for i=1:N
    % Use Kabsch's algorithm to pull out a rotation matrix and its rmsd
    % value
    [Qtemp,~,lrmsTemp] = Kabsch(tmpltArray.',vArraySorted.');
    % If the rmsd is lower than the current value, update the rotation
    % matrix (Q) and our vArraySorted-- we're looking for the best order of
    % the atoms (point-to-point correspondence)
    if lrmsTemp<lrms
        lrms=lrmsTemp;
        Q=Qtemp;
        vFinal=vArraySorted;
    end
    % Rotate the order of the atoms in our array so we can test all the
    % options and find the one with the lowest rmsd value
    vTemp=vArraySorted(2:end,:);
    vTempShifted=circshift(vTemp,1);
    vArraySorted=[vArraySorted(1,:);vTempShifted];  
end