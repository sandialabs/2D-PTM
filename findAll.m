function [tmpltTracker,theta,rmsd,csm,s]=findAll(vArraySorted,threshold,tmpltFCC,...
                                tmpltBCC,tmpltHCP,numTemplates)

% Function that finds and returns the lattice structure, rotation angle,
% least rmsd value, scaling factor, and the centrosymmetry value of a 
% single atom peak
%
% Inputs:
% vArraySorted-> a sorted list of the central atom peak and its 6 nearest
%                neighbors (see NN_finder function)
% threshold-> the maximum rmsd value allowed before an atom peak is
%             designated as "other"
% The next three inputs are the templates for the FCC, BCC, and HCP lattices.
%       These are provided in the script structureTemplates.
% numTemplates-> the number of templates we're testing (3 in this case).
%                This is also provided in the structureTemplates script.
%
% Outputs:
% tmpltTracker-> a value that represents the lattice structure of the given
%                atom peak (FCC: 1, BCC: 2, HCP: 3, other: 0)
% theta-> the rotation angle between the central atom peak and its nearest
%         neighbors and the appropriate template
% rmsd-> the least root-mean-square deviation between the central atom peak
%        and its nearest neighbors and the appropriate template
% csm-> the centrosymmetry value of the central atom peak
% s-> the scaling factor needed to transform the central atom peak and its
%     nearest neighbors to match the appropriate template

rmsd=10^10;
tmpltTracker=0;

for i=1:numTemplates
    if i==1
        % Check FCC
        % Find the rotation matrix and the correct point-to-point
        % correspondence of our atoms
        [Q,vFinal] = QrotationKabsch(vArraySorted,tmpltFCC);
        % Calculate the rmsd value for the FCC structure
        [rmsdTemp,sTemp] = RMSD(vFinal,tmpltFCC,Q);
        % If it's smaller than the current rmsd value and our threshold
        % value, update it and assign our atom as FCC
        if rmsdTemp<rmsd && rmsdTemp<threshold
            rmsd=rmsdTemp;
            s=sTemp;
            tmpltTracker=1;
            % Round off noise in our rotation matrix before getting the
            % angle
            if Q(1,1)>1
                Q(1,1)=1;
            elseif Q(1,1)<-1
                Q(1,1)=-1;
            end
            % Extract rotation angle from the rotation matrix
            theta=atan2d(Q(2,1),Q(1,1));

            % Round theta if it's close to a whole number
            tempTheta=round(theta);
            diff=abs(tempTheta-theta);
            if diff<10^-5
                theta=tempTheta;
            end

            % Reduce the angle (take into account equivalent supplementary
            % angles)
            if theta<0
                theta=theta+180;
            end
        end
    elseif i==2
        % Check BCC
        % Find the rotation matrix and the correct point-to-point
        % correspondence of our atoms
        [Q,vFinal] = QrotationKabsch(vArraySorted,tmpltBCC);
        % Calculate the rmsd value for the BCC structure
        [rmsdTemp,sTemp] = RMSD(vFinal,tmpltBCC,Q);
        % If it's smaller than the current rmsd value and our threshold
        % value, update it and assign our atom as BCC
        if rmsdTemp<rmsd && rmsdTemp<threshold
            rmsd=rmsdTemp;
            s=sTemp;
            tmpltTracker=2;
            % Round off noise in our rotation matrix before getting the
            % angle
            if Q(1,1)>1
                Q(1,1)=1;
            elseif Q(1,1)<-1
                Q(1,1)=-1;
            end
            % Extract rotation angle from the rotation matrix
            theta=atan2d(Q(2,1),Q(1,1));

            % Round theta if it's close to a whole number
            tempTheta=round(theta);
            diff=abs(tempTheta-theta);
            if diff<10^-5
                theta=tempTheta;
            end

            % Reduce the angle (take into account equivalent supplementary
            % angles, particularly the six-fold symmetry of BCC)
            if theta<0
                theta=theta+180;
            end

            if theta>30 && theta<=60
                theta=60-theta;
            elseif theta>60 && theta<=90
                theta=theta-60;
            elseif theta>90 && theta<=120
                theta=120-theta;
            elseif theta>120 && theta<=150
                theta=theta-120;
            elseif theta>150 && theta<=180
                theta=180-theta;
            end
        end
    elseif i==3
        % Check HCP
        % Find the rotation matrix and the correct point-to-point
        % correspondence of our atoms
        [Q,vFinal] = QrotationKabsch(vArraySorted,tmpltHCP);
        % Calculate the rmsd value for the HCP structure
        [rmsdTemp,sTemp] = RMSD(vFinal,tmpltHCP,Q);
        % If it's smaller than the current rmsd value and our threshold
        % value, update it and assign our atom as HCP
        if rmsdTemp<rmsd && rmsdTemp<threshold
            rmsd=rmsdTemp;
            s=sTemp;
            tmpltTracker=3;
            % Round off noise in our rotation matrix before getting the
            % angle
            if Q(1,1)>1
                Q(1,1)=1;
            elseif Q(1,1)<-1
                Q(1,1)=-1;
            end
            % Extract rotation angle from the rotation matrix
            theta=atan2d(Q(2,1),Q(1,1));

            % Round theta if it's close to a whole number
            tempTheta=round(theta);
            diff=abs(tempTheta-theta);
            if diff<10^-5
                theta=tempTheta;
            end

            % Reduce the angle (take into account equivalent supplementary
            % angles)
            if theta<0
                theta=theta+180;
            end
        end
    end
end

% Round rmsd if it's close to a whole number
tempRMSD=round(rmsd);
diff=abs(tempRMSD-rmsd);
if diff<10^-5
    rmsd=tempRMSD;
end

% Find centrosymmetry parameter
csm=0;
len=length(vArraySorted)-1;

for i=2:len/2+1
    v1=vArraySorted(1,:)-vArraySorted(i,:);
    v2=vArraySorted(1,:)-vArraySorted(i+len/2,:);
    csmTemp=norm(v1+v2)^2;
    csm=csm+csmTemp;
end

% Round csm if it's close to a whole number
tempCSM=round(csm);
diff=abs(tempCSM-csm);
if diff<10^-5
    csm=tempCSM;
end

% Account for unidentified atoms
if rmsd==10^10
    rmsd=NaN;
    theta=NaN;
    s=NaN;
end