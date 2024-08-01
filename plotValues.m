function [] = plotValues(ptmInfo,plotStatus,path,markerSize,structureOptions,structureLegend,transparency,markerArray)
% Function that reads in an array of atom peaks and a plot status, and 
% optionally a path to save the output image, marker size, structure options,
% structure legend status, transparency, and a marker array. It then plots 
% the atom peaks colored by structure, rotation angle, rmsd value, or 
% centrosymmetry value, depending on the user input.
%
% This code uses the export_fig function:
% Yair Altman (2023). export_fig (https://github.com/altmany/export_fig/...
% releases/tag/v3.40), GitHub. Retrieved July 26, 2023.
%
% Inputs:
% ptmInfo-> a data structure containing all the information about a set of
%           atom peaks from a given image. The information includes the x
%           and y positions, the structure type, angle, rmsd value,
%           centrosymmetry value, and scaling factor. It also includes the 
%           nearest neighbor lists for each atom peak and the Delaunay
%           triangulation for the atom peaks. This struct variable is
%           output from the identifyAll_parfor function.
% plotStatus-> a string or character that designates which plot you want to 
%              produce.
%       Possible inputs:
%           'structure': plots the atoms colored by lattice structure
%           'angle': plots the atoms colored by angle
%           'rmsd': plots the atoms colored by the least rmsd value
%           'centrosymmetry': plots the atoms colored by centrosymmetry
%                             value
%           'scalingFactor': plots the atoms colored by scaling factor
%
% The following six inputs must be given in order, but any given input can
% be skipped by putting [] as a placeholder.
%
% path (optional)-> a string designating the name of the image that you
%                   would like to save, as well as the path to where you
%                   want it to be saved (if desired)
% markerSize (optional)-> a number designating how large you want the
%                         markers to be.
% structureOptions (optional)-> a string array indicating which of the 4
%                               possible structure outputs you want
%                               plotted for any plot option, not just the
%                               structure plot.
%                               Default is ["FCC","BCC","HCP","other"].
%                               Any of those four inputs are optional,
%                               order doesn't matter. For example, if you
%                               only wanted the HCP and unidentified atoms
%                               to be plotted, you would input
%                               ["HCP","other"].
% structureLegend (optional)-> either 'on' or 'off' (default is off)
%                              Allows you to add a legend to the structure
%                              plot (has no effect on angle, rmsd, or
%                              centrosymmetry plots)
% transparency (optional)-> either 'transparent' or 'off' (default is off)
%                           Allows you to make the background of the image
%                           transparent when saved.
% markerArray (optional)-> an array of marker symbols used to indicate
%                          what you want the structures to be plotted as.
%                          Inputting one symbol (Example: '*') will change
%                          all the markers to that symbol. If you want to
%                          designate separate symbols for the different
%                          structures, you can put in a length of 4 array,
%                          in the following order: FCC, BCC, HCP, and
%                          other (Example: ["*","d","^","p"]). In this case, 
%                          the array inputs must be strings, and they must  
%                          each have only one character.

% Read in optional variables
if nargin < 3 || isempty(path)
    path=[];
end

if nargin < 4 || isempty(markerSize)
    markerSize=[];
end

if nargin < 5 || isempty(structureOptions)
    structureOptions=["FCC","BCC","HCP","other"];
end

if nargin < 6 || isempty(structureLegend)
    structureLegend='off';
end

if nargin < 7 || isempty(transparency)
    transparency='off';
end

if nargin < 8 || isempty(markerArray)
    markerArray=[];
end

% Extract values from our array
xy=ptmInfo.xy;
x=xy(:,1);
y=xy(:,2);
structureValues=ptmInfo.structure;
thetaValues=ptmInfo.angle;
rmsdValues=ptmInfo.rmsd;
csmValues=ptmInfo.csm;
scalingFactorValues=ptmInfo.scalingFactor;

% Read in structureOptions values
xyNew=[];
xNew=[];
yNew=[];
structureValuesNew=[];
thetaValuesNew=[];
rmsdValuesNew=[];
csmValuesNew=[];
scalingFactorValuesNew=[];

% Read in structureOptions (pick which structure types we want to plot)
% Find FCC atoms
if any(structureOptions=='FCC')
    FCCidx=structureValues==1;
    xyNew=[xyNew;xy(FCCidx,:)];
    xNew=[xNew;x(FCCidx)];
    yNew=[yNew;y(FCCidx)];
    structureValuesNew=[structureValuesNew;structureValues(FCCidx)];
    thetaValuesNew=[thetaValuesNew;thetaValues(FCCidx)];
    rmsdValuesNew=[rmsdValuesNew;rmsdValues(FCCidx)];
    csmValuesNew=[csmValuesNew;csmValues(FCCidx)];
    scalingFactorValuesNew=[scalingFactorValuesNew;scalingFactorValues(FCCidx)];
end

% Find BCC atoms
if any(structureOptions=='BCC')
    BCCidx=structureValues==2;
    xyNew=[xyNew;xy(BCCidx,:)];
    xNew=[xNew;x(BCCidx)];
    yNew=[yNew;y(BCCidx)];
    structureValuesNew=[structureValuesNew;structureValues(BCCidx)];
    thetaValuesNew=[thetaValuesNew;thetaValues(BCCidx)];
    rmsdValuesNew=[rmsdValuesNew;rmsdValues(BCCidx)];
    csmValuesNew=[csmValuesNew;csmValues(BCCidx)];
    scalingFactorValuesNew=[scalingFactorValuesNew;scalingFactorValues(BCCidx)];
end

% Find HCP atoms
if any(structureOptions=='HCP')
    HCPidx=structureValues==3;
    xyNew=[xyNew;xy(HCPidx,:)];
    xNew=[xNew;x(HCPidx)];
    yNew=[yNew;y(HCPidx)];
    structureValuesNew=[structureValuesNew;structureValues(HCPidx)];
    thetaValuesNew=[thetaValuesNew;thetaValues(HCPidx)];
    rmsdValuesNew=[rmsdValuesNew;rmsdValues(HCPidx)];
    csmValuesNew=[csmValuesNew;csmValues(HCPidx)];
    scalingFactorValuesNew=[scalingFactorValuesNew;scalingFactorValues(HCPidx)];
end

% Find unidentified atoms
if any(structureOptions=='other')
    otherIdx=structureValues==0;
    xyNew=[xyNew;xy(otherIdx,:)];
    xNew=[xNew;x(otherIdx)];
    yNew=[yNew;y(otherIdx)];
    structureValuesNew=[structureValuesNew;structureValues(otherIdx)];
    thetaValuesNew=[thetaValuesNew;thetaValues(otherIdx)];
    rmsdValuesNew=[rmsdValuesNew;rmsdValues(otherIdx)];
    csmValuesNew=[csmValuesNew;csmValues(otherIdx)];
    scalingFactorValuesNew=[scalingFactorValuesNew;scalingFactorValues(otherIdx)];
end


% Pull out all unidentifiable atoms (used for plotting angle and rmsd)
nanColumn=isnan(thetaValuesNew);
nanAtomIndices=find(all(nanColumn,2));
nanAtoms=xyNew(nanAtomIndices,1:2);

nanX=nanAtoms(:,1);
nanY=nanAtoms(:,2);

% Pull out atoms that we couldn't find a centrosymmetry value for (used for
% plotting centrosymmetry)
nanColumnCSM=isnan(csmValuesNew);
nanAtomIndicesCSM=find(all(nanColumnCSM,2));
nanAtomsCSM=xyNew(nanAtomIndicesCSM,1:2);

nanXcsm=nanAtomsCSM(:,1);
nanYcsm=nanAtomsCSM(:,2);

% Pull out atoms that we couldn't find a scalingFactor value for (used for
% plotting scalingFactor)
nanColumnsF=isnan(scalingFactorValuesNew);
nanAtomIndicessF=find(all(nanColumnsF,2));
nanAtomssF=xyNew(nanAtomIndicessF,1:2);

nanXsF=nanAtomssF(:,1);
nanYsF=nanAtomssF(:,2);

% Plot according to the input given
% PLOTTING BY STRUCTURE
if strcmp(plotStatus,'structure')==1
    % Make the structure values categorical so that we can correctly plot
    % them by color even if not all structures are present in an image
    valueset = [1 2 3 0];
    structureValuesNew=categorical(structureValuesNew,valueset);

    % Determine the labels for the legend based on which structures are
    % actually present in the image if desired
    if strcmp(structureLegend,'on')==1
        labelset = {};
        % Check for FCC
        if any(structureValuesNew == '1')
            labelset{end+1} = 'FCC';
        else
            labelset{end+1} = '';
        end
        % Check for BCC
        if any(structureValuesNew == '2')
            labelset{end+1} = 'BCC';
        else
            labelset{end+1} = '';
        end
        % Check for HCP
        if any(structureValuesNew == '3')
            labelset{end+1} = 'HCP';
        else
            labelset{end+1} = '';
        end
        % Check for other
        if any(structureValuesNew == '0')
            labelset{end+1} = 'Other';
        else
            labelset{end+1} = '';
        end
    end

    % Plot (taking any marker inputs into account)
    % Use gscatter for the structure values so we can plot them by groups
    figure
    % Default to circles if there's no marker input given
    if isempty(markerArray)
        % Change marker size if needed
        if isempty(markerSize)
            gscatter(xNew,yNew,structureValuesNew,'gbrk',[],15,'off')
        else
            gscatter(xNew,yNew,structureValuesNew,'gbrk',[],markerSize,'off')
        end
    % Prioritize an array of markers over a singular marker input
    elseif length(markerArray)==4
        % Join together an array of strings (must be only one character
        % each, example: ["*","d","p","<"])
        structureSymbols=strjoin(markerArray,'');
        % Change marker size if needed
        if isempty(markerSize)
            gscatter(xNew,yNew,structureValuesNew,'gbrk',structureSymbols,...
                    [],'off')
        else
            gscatter(xNew,yNew,structureValuesNew,'gbrk',structureSymbols,...
                    sqrt(markerSize),'off')
        end
    % Change all atoms to a different marker if just one marker input is
    % given
    elseif length(markerArray)==1
        % Change marker size if needed
        if isempty(markerSize)
            gscatter(xNew,yNew,structureValuesNew,'gbrk',markerArray,[],'off')
        else
            gscatter(xNew,yNew,structureValuesNew,'gbrk',markerArray,sqrt(markerSize),...
                    'off')
        end
    end
    if strcmp(structureLegend,'on')==1
        legend(labelset)
    end
    % Maximize size so that the quality is better when you export it
    set(gcf,'WindowState','maximized')
    % Make the background white
    set(gcf,'Color','white')
    axis image
    axis off

    % Message to let you know you need to input a path if you want your
    % image saved
    if isempty(path)
        fprintf("If you would like to save this image, please input a file " + ...
            "name when calling this function, including the path if desired.\n")
    else
        % Check if you wanted the background transparent or not before
        % exporting
        if strcmp(transparency,'transparent')==1
            export_fig(path,'-transparent','-m2.5')
        else
            export_fig(path,'-m2.5')
        end
    end    

% PLOTTING BY ANGLE
elseif strcmp(plotStatus,'angle')==1
    % Plot (taking any marker inputs into account)
    figure
    % Default to circles if there's no marker input given
    if isempty(markerArray)
        % Change marker size if needed
        if isempty(markerSize)
            scatter(xNew,yNew,[],thetaValuesNew,'filled')
            hold on
            % Plot the unidentified atoms as black x's to avoid confusion
            plot(nanX,nanY,'kx')
        else
            scatter(xNew,yNew,markerSize,thetaValuesNew,'filled')
            hold on
            % Plot the unidentified atoms as black x's to avoid confusion
            plot(nanX,nanY,'kx','MarkerSize',sqrt(markerSize))
        end
    % Prioritize an array of markers over a singular marker input
    elseif length(markerArray)==4
        % Pull out the desired markers for each structure type
        fccMarker=markerArray(1);
        bccMarker=markerArray(2);
        hcpMarker=markerArray(3);
        otherMarker=markerArray(4);

        % Pull out which atoms correspond to which structure
        fccAtoms=structureValuesNew==1;
        bccAtoms=structureValuesNew==2;
        hcpAtoms=structureValuesNew==3;

        % Change marker size if needed
        if isempty(markerSize)
            % Scatter each group of atoms separately so we can apply the
            % different markers
            scatter(xyNew(fccAtoms,1),xyNew(fccAtoms,2),[],...
                thetaValuesNew(fccAtoms),fccMarker)
            hold on
            scatter(xyNew(bccAtoms,1),xyNew(bccAtoms,2),[],...
                thetaValuesNew(bccAtoms),bccMarker)
            scatter(xyNew(hcpAtoms,1),xyNew(hcpAtoms,2),[],...
                thetaValuesNew(hcpAtoms),hcpMarker)
            % Also plot the unidentified atoms separately in black to avoid
            % confusion
            otherInfo=strcat('k',otherMarker);
            plot(nanX,nanY,otherInfo)
        else
            % Scatter each group of atoms separately so we can apply the
            % different markers
            scatter(xyNew(fccAtoms,1),xyNew(fccAtoms,2),markerSize,...
                thetaValuesNew(fccAtoms),fccMarker)
            hold on
            scatter(xyNew(bccAtoms,1),xyNew(bccAtoms,2),markerSize,...
                thetaValuesNew(bccAtoms),bccMarker)
            scatter(xyNew(hcpAtoms,1),xyNew(hcpAtoms,2),markerSize,...
                thetaValuesNew(hcpAtoms),hcpMarker)
            % Also plot the unidentified atoms separately in black to avoid
            % confusion
            otherInfo=strcat('k',otherMarker);
            plot(nanX,nanY,otherInfo,'MarkerSize',sqrt(markerSize))
        end
    % Change all atoms to a different marker if just one marker input is
    % given
    elseif length(markerArray)==1
        % Change marker size if needed
        if isempty(markerSize)
            scatter(xNew,yNew,[],thetaValuesNew,markerArray)
            hold on
            % Plot the unidentified atoms as black x's to avoid confusion
            plot(nanX,nanY,'kx')
        else
            scatter(xNew,yNew,markerSize,thetaValuesNew,markerArray)
            hold on
            % Plot the unidentified atoms as black x's to avoid confusion
            plot(nanX,nanY,'kx','MarkerSize',sqrt(markerSize))
        end
    end
    % Maximize size so that the quality is better when you export it
    set(gcf,'WindowState','maximized')
    % Make the background white
    set(gcf,'Color','white')
    axis image
    axis off
    % Add a colorbar with a label
    colormap cool
    c = colorbar;
    c.Label.String = '\theta (degrees)';

    % Message to let you know you need to input a path if you want your
    % image saved
    if isempty(path)
        fprintf("If you would like to save this image, please input a file " + ...
            "name when calling this function, including the path if desired.\n")
    else
        % Check if you wanted the background transparent or not before
        % exporting
        if strcmp(transparency,'transparent')==1
            export_fig(path,'-transparent','-m2.5')
        else
            export_fig(path,'-m2.5')
        end
    end

% PLOTTING BY RMSD
elseif strcmp(plotStatus,'rmsd')==1
    % Plot (taking any marker inputs into account)
    figure
    % Default to circles if there's no marker input given
    if isempty(markerArray)
        % Change marker size if needed
        if isempty(markerSize)
            scatter(xNew,yNew,[],rmsdValuesNew,'filled')
            hold on
            % Plot the unidentified atoms as black x's to avoid confusion
            plot(nanX,nanY,'kx')
        else
            scatter(xNew,yNew,markerSize,rmsdValuesNew,'filled')
            hold on
            % Plot the unidentified atoms as black x's to avoid confusion
            plot(nanX,nanY,'kx','MarkerSize',sqrt(markerSize))
        end
    % Prioritize an array of markers over a singular marker input
    elseif length(markerArray)==4
        % Pull out the desired markers for each structure type
        fccMarker=markerArray(1);
        bccMarker=markerArray(2);
        hcpMarker=markerArray(3);
        otherMarker=markerArray(4);

        % Pull out which atoms correspond to which structure
        fccAtoms=structureValuesNew==1;
        bccAtoms=structureValuesNew==2;
        hcpAtoms=structureValuesNew==3;

        % Change marker size if needed
        if isempty(markerSize)
            % Scatter each group of atoms separately so we can apply the
            % different markers
            scatter(xyNew(fccAtoms,1),xyNew(fccAtoms,2),[],...
                rmsdValuesNew(fccAtoms),fccMarker)
            hold on
            scatter(xyNew(bccAtoms,1),xyNew(bccAtoms,2),[],...
                rmsdValuesNew(bccAtoms),bccMarker)
            scatter(xyNew(hcpAtoms,1),xyNew(hcpAtoms,2),[],...
                rmsdValuesNew(hcpAtoms),hcpMarker)
            % Also plot the unidentified atoms separately in black to avoid
            % confusion
            otherInfo=strcat('k',otherMarker);
            plot(nanX,nanY,otherInfo)
        else
            % Scatter each group of atoms separately so we can apply the
            % different markers
            scatter(xyNew(fccAtoms,1),xyNew(fccAtoms,2),markerSize,...
                rmsdValuesNew(fccAtoms),fccMarker)
            hold on
            scatter(xyNew(bccAtoms,1),xyNew(bccAtoms,2),markerSize,...
                rmsdValuesNew(bccAtoms),bccMarker)
            scatter(xyNew(hcpAtoms,1),xyNew(hcpAtoms,2),markerSize,...
                rmsdValuesNew(hcpAtoms),hcpMarker)
            % Also plot the unidentified atoms separately in black to avoid
            % confusion
            otherInfo=strcat('k',otherMarker);
            plot(nanX,nanY,otherInfo,'MarkerSize',sqrt(markerSize))
        end
    % Change all atoms to a different marker if just one marker input is
    % given
    elseif length(markerArray)==1
        % Change marker size if needed
        if isempty(markerSize)
            scatter(xNew,yNew,[],rmsdValuesNew,markerArray)
            hold on
            % Plot the unidentified atoms as black x's to avoid confusion
            plot(nanX,nanY,'kx')
        else
            scatter(xNew,yNew,markerSize,rmsdValuesNew,markerArray)
            hold on
            % Plot the unidentified atoms as black x's to avoid confusion
            plot(nanX,nanY,'kx','MarkerSize',sqrt(markerSize))
        end
    end
    % Maximize size so that the quality is better when you export it
    set(gcf,'WindowState','maximized')
    % Make the background white
    set(gcf,'Color','white')
    axis image
    axis off
    % Add a colorbar with a label
    colormap cool
    c = colorbar;
    c.Label.String = 'RMSD Value';
    clim([0 .05])

    % Message to let you know you need to input a path if you want your
    % image saved
    if isempty(path)
        fprintf("If you would like to save this image, please input a file " + ...
            "name when calling this function, including the path if desired.\n")
    else
        % Check if you wanted the background transparent or not before
        % exporting
        if strcmp(transparency,'transparent')==1
            export_fig(path,'-transparent','-m2.5')
        else
            export_fig(path,'-m2.5')
        end
    end

% PLOTTING BY CENTROSYMMETRY
elseif strcmp(plotStatus,'centrosymmetry')==1
    % Plot (taking any marker inputs into account)
    figure
    % Default to circles if there's no marker input given
    if isempty(markerArray)
        % Pull out identified and unidentified atoms
        ID=~isnan(xNew) & structureValuesNew~=0;
        unID=structureValuesNew==0 & ~isnan(xNew) & ~isnan(csmValuesNew);
        % Change marker size if needed
        if isempty(markerSize)
            scatter(xNew(ID),yNew(ID),[],csmValuesNew(ID),'filled')
            hold on
            scatter(xNew(unID),yNew(unID),[],csmValuesNew(unID),'x')
            % Plot the atoms without a centrosymmetry value as black x's to 
            % avoid confusion
            plot(nanXcsm,nanYcsm,'kx')
        else
            scatter(xNew(ID),yNew(ID),markerSize,csmValuesNew(ID),'filled')
            hold on
            scatter(xNew(unID),yNew(unID),markerSize,csmValuesNew(unID),'x')
            % Plot the atoms without a centrosymmetry value as black x's to 
            % avoid confusion
            plot(nanXcsm,nanYcsm,'kx','MarkerSize',sqrt(markerSize))
        end
    % Prioritize an array of markers over a singular marker input
    elseif length(markerArray)==4
        % Pull out the desired markers for each structure type
        fccMarker=markerArray(1);
        bccMarker=markerArray(2);
        hcpMarker=markerArray(3);
        otherMarker=markerArray(4);

        % Pull out which atoms correspond to which structure
        fccAtoms=structureValuesNew==1;
        bccAtoms=structureValuesNew==2;
        hcpAtoms=structureValuesNew==3;
        otherAtoms=structureValuesNew==0 & ~isnan(xNew) & ~isnan(csmValuesNew);

        % Change marker size if needed
        if isempty(markerSize)
            % Scatter each group of atoms separately so we can apply the
            % different markers
            scatter(xyNew(fccAtoms,1),xyNew(fccAtoms,2),[],...
                csmValuesNew(fccAtoms),fccMarker)
            hold on
            scatter(xyNew(bccAtoms,1),xyNew(bccAtoms,2),[],...
                csmValuesNew(bccAtoms),bccMarker)
            scatter(xyNew(hcpAtoms,1),xyNew(hcpAtoms,2),[],...
                csmValuesNew(hcpAtoms),hcpMarker)
            scatter(xyNew(otherAtoms,1),xyNew(otherAtoms,2),[],...
                csmValuesNew(otherAtoms),otherMarker)
            % Also plot the atoms without a centrosymmetry value separately 
            % in black to avoid confusion
            otherInfo=strcat('k',otherMarker);
            plot(nanXcsm,nanYcsm,otherInfo)
        else
            % Scatter each group of atoms separately so we can apply the
            % different markers
            scatter(xyNew(fccAtoms,1),xyNew(fccAtoms,2),markerSize,...
                csmValuesNew(fccAtoms),fccMarker)
            hold on
            scatter(xyNew(bccAtoms,1),xyNew(bccAtoms,2),markerSize,...
                csmValuesNew(bccAtoms),bccMarker)
            scatter(xyNew(hcpAtoms,1),xyNew(hcpAtoms,2),markerSize,...
                csmValuesNew(hcpAtoms),hcpMarker)
            scatter(xyNew(otherAtoms,1),xyNew(otherAtoms,2),markerSize,...
                csmValuesNew(otherAtoms),otherMarker)
            % Also plot the atoms without a centrosymmetry value separately 
            % in black to avoid confusion
            otherInfo=strcat('k',otherMarker);
            plot(nanXcsm,nanYcsm,otherInfo,'MarkerSize',sqrt(markerSize))
        end
    % Change all atoms to a different marker if just one marker input is
    % given
    elseif length(markerArray)==1
        % Pull out identified and unidentified atoms
        ID=~isnan(xNew) & structureValuesNew~=0;
        unID=structureValuesNew==0 & ~isnan(xNew) & ~isnan(csmValuesNew);
        % Change marker size if needed
        if isempty(markerSize)
            scatter(xNew(ID),yNew(ID),[],csmValuesNew(ID),markerArray)
            hold on
            scatter(xNew(unID),yNew(unID),[],csmValuesNew(unID),'x')
            % Plot the atoms without a centrosymmetry value as black x's to 
            % avoid confusion
            plot(nanXcsm,nanYcsm,'kx')
        else
            scatter(xNew(ID),yNew(ID),markerSize,csmValuesNew(ID),markerArray)
            hold on
            scatter(xNew(unID),yNew(unID),markerSize,csmValuesNew(unID),'x')
            % Plot the atoms without a centrosymmetry value as black x's to 
            % avoid confusion
            plot(nanXcsm,nanYcsm,'kx','MarkerSize',sqrt(markerSize))
        end
    end
    % Maximize size so that the quality is better when you export it
    set(gcf,'WindowState','maximized')
    % Make the background white
    set(gcf,'Color','white')
    axis image
    axis off
    % Add a colorbar with a label
    colormap cool
    c = colorbar;
    c.Label.String = 'Centrosymmetry Value';

    % Message to let you know you need to input a path if you want your
    % image saved
    if isempty(path)
        fprintf("If you would like to save this image, please input a file " + ...
            "name when calling this function, including the path if desired.\n")
    else
        % Check if you wanted the background transparent or not before
        % exporting
        if strcmp(transparency,'transparent')==1
            export_fig(path,'-transparent','-m2.5')
        else
            export_fig(path,'-m2.5')
        end
    end

    % PLOTTING BY SCALING FACTOR
elseif strcmp(plotStatus,'scalingFactor')==1
    % Plot (taking any marker inputs into account)
    figure
    % Default to circles if there's no marker input given
    if isempty(markerArray)
        % Pull out identified and unidentified atoms
        ID=~isnan(xNew) & structureValuesNew~=0;
        unID=structureValuesNew==0 & ~isnan(xNew) & ~isnan(scalingFactorValuesNew);
        % Change marker size if needed
        if isempty(markerSize)
            scatter(xNew(ID),yNew(ID),[],scalingFactorValuesNew(ID),'filled')
            hold on
            scatter(xNew(unID),yNew(unID),[],scalingFactorValuesNew(unID),'x')
            % Plot the atoms without a scalingFactor value as black x's to 
            % avoid confusion
            plot(nanXsF,nanYsF,'kx')
        else
            scatter(xNew(ID),yNew(ID),markerSize,scalingFactorValuesNew(ID),'filled')
            hold on
            scatter(xNew(unID),yNew(unID),markerSize,scalingFactorValuesNew(unID),'x')
            % Plot the atoms without a scalingFactor value as black x's to 
            % avoid confusion
            plot(nanXsF,nanYsF,'kx','MarkerSize',sqrt(markerSize))
        end
    % Prioritize an array of markers over a singular marker input
    elseif length(markerArray)==4
        % Pull out the desired markers for each structure type
        fccMarker=markerArray(1);
        bccMarker=markerArray(2);
        hcpMarker=markerArray(3);
        otherMarker=markerArray(4);

        % Pull out which atoms correspond to which structure
        fccAtoms=structureValuesNew==1;
        bccAtoms=structureValuesNew==2;
        hcpAtoms=structureValuesNew==3;
        otherAtoms=structureValuesNew==0 & ~isnan(xNew) & ~isnan(scalingFactorValuesNew);

        % Change marker size if needed
        if isempty(markerSize)
            % Scatter each group of atoms separately so we can apply the
            % different markers
            scatter(xyNew(fccAtoms,1),xyNew(fccAtoms,2),[],...
                scalingFactorValuesNew(fccAtoms),fccMarker)
            hold on
            scatter(xyNew(bccAtoms,1),xyNew(bccAtoms,2),[],...
                scalingFactorValuesNew(bccAtoms),bccMarker)
            scatter(xyNew(hcpAtoms,1),xyNew(hcpAtoms,2),[],...
                scalingFactorValuesNew(hcpAtoms),hcpMarker)
            scatter(xyNew(otherAtoms,1),xyNew(otherAtoms,2),[],...
                scalingFactorValuesNew(otherAtoms),otherMarker)
            % Also plot the atoms without a scalingFactor value separately 
            % in black to avoid confusion
            otherInfo=strcat('k',otherMarker);
            plot(nanXsF,nanYsF,otherInfo)
        else
            % Scatter each group of atoms separately so we can apply the
            % different markers
            scatter(xyNew(fccAtoms,1),xyNew(fccAtoms,2),markerSize,...
                scalingFactorValuesNew(fccAtoms),fccMarker)
            hold on
            scatter(xyNew(bccAtoms,1),xyNew(bccAtoms,2),markerSize,...
                scalingFactorValuesNew(bccAtoms),bccMarker)
            scatter(xyNew(hcpAtoms,1),xyNew(hcpAtoms,2),markerSize,...
                scalingFactorValuesNew(hcpAtoms),hcpMarker)
            scatter(xyNew(otherAtoms,1),xyNew(otherAtoms,2),markerSize,...
                scalingFactorValuesNew(otherAtoms),otherMarker)
            % Also plot the atoms without a scalingFactor value separately 
            % in black to avoid confusion
            otherInfo=strcat('k',otherMarker);
            plot(nanXsF,nanYsF,otherInfo,'MarkerSize',sqrt(markerSize))
        end
    % Change all atoms to a different marker if just one marker input is
    % given
    elseif length(markerArray)==1
        % Pull out identified and unidentified atoms
        ID=~isnan(xNew) & structureValuesNew~=0;
        unID=structureValuesNew==0 & ~isnan(xNew) & ~isnan(scalingFactorValuesNew);
        % Change marker size if needed
        if isempty(markerSize)
            scatter(xNew(ID),yNew(ID),[],scalingFactorValuesNew(ID),markerArray)
            hold on
            scatter(xNew(unID),yNew(unID),[],scalingFactorValuesNew(unID),'x')
            % Plot the atoms without a Scaling Factor value as black x's to 
            % avoid confusion
            plot(nanXsF,nanYsF,'kx')
        else
            scatter(xNew(ID),yNew(ID),markerSize,scalingFactorValuesNew(ID),markerArray)
            hold on
            scatter(xNew(unID),yNew(unID),markerSize,scalingFactorValuesNew(unID),'x')
            % Plot the atoms without a Scaling Factor value as black x's to 
            % avoid confusion
            plot(nanXsF,nanYsF,'kx','MarkerSize',sqrt(markerSize))
        end
    end
    % Maximize size so that the quality is better when you export it
    set(gcf,'WindowState','maximized')
    % Make the background white
    set(gcf,'Color','white')
    axis image
    axis off
    % Add a colorbar with a label
    colormap cool
    c = colorbar;
    c.Label.String = 'Scaling Factor';

    % Message to let you know you need to input a path if you want your
    % image saved
    if isempty(path)
        fprintf("If you would like to save this image, please input a file " + ...
            "name when calling this function, including the path if desired.\n")
    else
        % Check if you wanted the background transparent or not before
        % exporting
        if strcmp(transparency,'transparent')==1
            export_fig(path,'-transparent','-m2.5')
        else
            export_fig(path,'-m2.5')
        end
    end
end