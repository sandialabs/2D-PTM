% Example script for how to run the code from beginning to end

% Pick the image you want to analyze
filename='filename.tif';

% Get the atom peaks
% This will produce an image of the atom peaks as well
p2dshift=DispImage(filename); 

% Analyze image and save information to a data structure
ptmInfo=identifyAll_parfor(p2dshift);

% Plot the points according to structure (simple example)
plotValues(ptmInfo,'structure')

% Save the majority of the information to a text or csv file
pointsArray=writePointsArray(ptmInfo,path);

%% Other examples %%

%% identifyAll_parfor information:
% The identifyAll_parfor function has one required input variable, p2dshift: 
% 
% p2dshift: an array of atom peaks taken from a 2D image (see the
% atom_detect function)
% 
% This function also has two optional input variables, threshold and 
% edgeStatus:
% 
% threshold: The maximum rmsd value allowed before an atom is designated as 
%            "other". Default is .05.
% edgeStatus: either 'on' or 'off'. Indicates whether or not you want the
%             unidentified atoms along the outer edges of the image.
%             Default is 'off'.

% Examples:

% Changes the threshold value, edges off
ptmInfo=identifyAll_parfor(p2dshift,.04);

% Changes the threshold value, edges on
ptmInfo=identifyAll_parfor(p2dshift,.06,'on');

% Default threshold value (.05), edges on
ptmInfo=identifyAll_parfor(p2dshift,[],'on');

%% plotValues information:
% The plotValues function has two required input variables, ptmInfo and 
% plotStatus: 
%
% ptmInfo: a data structure with 8 fields. The first 7 fields are arrays 
%          with N rows, where N is the number of atoms in p2dshift. The
%          fields are as follows:
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
% plotStatus: determines which plot is produced; options include structure, 
%             angle, rmsd, centrosymmetry, or scaling factor
% 
% This function also has six optional input variables; path, markerSize,
% structureOptions, structureLegend, transparency, and markerArray:
%
% path: indicates that you want to save the image, provides where to save
%       it and by what name. It must include the name you want to give the
%       image at the end of the string (Example: image1.png).
% markerSize: a number that designates how big you want the markers to be.
% structureOptions: a string array indicating which of the 4 possible 
%                   structure outputs you want plotted for any plot type. 
%                   Default is ["FCC","BCC","HCP","other"].
%                   Any of those four inputs are optional, order doesn't
%                   matter. For example, if you only wanted the HCP and
%                   unidentified atoms to be plotted, you would input
%                   ["HCP","other"].
% structureLegend: either 'on' or 'off' (default is off)
%                  Allows you to add a legend to the structure plot (has no
%                  effect on angle, rmsd, or centrosymmetry plots)
% transparency: either 'transparent' or 'off' (default is off) Allows you 
%               to make the background of the image transparent when saving
%               the image.
% markerArray: an array of marker symbols used to indicate what you want the
%              structures to be plotted as. Inputting one symbol (Example: '*') 
%              will change all the markers to that symbol. If you want to
%              designate separate symbols for the different structures, you
%              can put in a length of 4 array, in the following order: FCC,
%              BCC, HCP, and other (Example: ["*","d","^","p"]). In this case, 
%              the array inputs must be strings, and they must each have 
%              only one character.
%
% The six optional inputs must be given in order, but any given input can
% be skipped by putting [] as a placeholder.

% A note about saving the image:
% If you put in a path, the image output will be automatically be saved,
% and the image will have the extra white space cropped out. If you plot
% the image without saving it and decide to save it later, saving it from
% the Matlab figure menu will result in an image that isn't cropped. It's
% required to use the export_fig function and save the image to a path in 
% order to get the cropped image. Remember to include the name you want to
% give to the file at the end of the path string.
%
% Example 1:
% export_fig(path)
%
% If you want to save the image at a higher magnification (makes the image 
% better quality, this is the default in the code), you can use the following 
% (a larger number will result in more magnification):
%
% Example 2:
% export_fig(path,'-m2.5')
%
% If you would additionally like the background of the image to be 
% transparent, use the following:
%
% Example 3:
% export_fig(path,'-transparent','-m2.5')


% Example variables:

% Example input path variable (used in some examples)
path='C:\Users\username\Pictures\image1.png';

% Example structureOptions (used in some examples)
structureOptions=["HCP","other"];

% Example markerArray (used in some examples)
markerArray=["*","d","^","p"];


% Example calls:

% Plots colored by rotation angle, saves to the designated path
plotValues(ptmInfo,'angle',path)

% Plots colored by rmsd, saves to the designated path, marker size set to 25
plotValues(ptmInfo,'rmsd',path,25)

% Plots colored by structure, saves to the designated path, marker size set
% to 25, only plots HCP and unidentified atoms (due to the structureOptions)
plotValues(ptmInfo,'structure',path,25,structureOptions)

% Plots colored by structure, saves to the designated path, marker size set
% to 25, only plots HCP and unidentified atoms (due to the structureOptions),
% adds a legend to the plot
plotValues(ptmInfo,'structure',path,25,structureOptions,'on')

% Plots colored by centrosymmetry value, saves to the designated path, 
% marker size set to 25, only plots HCP and unidentified atoms (due to the
% structureOptions), no legend (not a structure plot), transparent background
plotValues(ptmInfo,'centrosymmetry',path,25,structureOptions,[],'transparent')

% Plots colored by structure, saves to the designated path, marker size set
% to 25, only plots HCP and unidentified atoms (due to the structureOptions),
% adds a legend to the plot, transparent background, changes all markers to '*'
plotValues(ptmInfo,'structure',path,25,structureOptions,'on','transparent','*')

% Plots colored by structure, saves to the designated path, marker size set
% to 25, only plots HCP and unidentified atoms (due to the structureOptions),
% adds a legend to the plot, transparent background, changes markers based 
% on the input markerArray (see example above)
plotValues(ptmInfo,'structure',path,25,structureOptions,'on','transparent',markerArray)

% Plots colored by scaling factor, changes all markers to '*'. All other
% options are skipped, and thus will be their default values. This image
% will not be automatically saved.
plotValues(ptmInfo,'scalingFactor',[],[],[],[],[],'*')