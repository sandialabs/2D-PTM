function [rmsd,s] = RMSD(v,w,Q)

% Function that calculates the RMSD value between a central atom and its
% nearest neighbors and a lattice template (FCC, BCC, or HCP)
%
% Inputs:
% v-> an array containing the central atom + 6 nearest neighbors
%     (generally a vFinal array output from the QrotationKabsch function)
% w-> an array containing the template for an FCC, BCC, or HCP lattice
%     (can be found in the structureTemplates script)
% Q-> the rotation matrix between the two above arrays
%     (output from the QrotationKabsch function)
%
% Outputs:
% rmsd-> the least root-mean-squared deviation between the two above arrays
% s-> the scaling factor needed to transform the central atom peak and its
%     nearest neighbors to match the appropriate template

N=length(v);

% Define vbar (barycenter/center of mass of v)
vbar=sum(v)/N;

% Define wbar (barycenter/center of mass of w)
wbar=sum(w)/N;

% Define s (a scaling factor for v)
s_v=0; s_w=0;
for i=1:N
    s_v=s_v+norm(v(i,:)-vbar)^2;
    s_w=s_w+norm(w(i,:)-wbar)^2;
end
s=sqrt(s_w/s_v);

% Calculate the RMSD value
rmsdSum=0;
for i=1:N
    rmsdSum=rmsdSum+norm(s*(v(i,:)-vbar)-...
            (Q*(w(i,:)-wbar).').')^2;
end

rmsd=sqrt(rmsdSum/N);

