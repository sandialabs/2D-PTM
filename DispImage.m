function p2dshift = DispImage(filename)

% Function that generates a p2dshift array (detects atom peaks of a 2D image)
% and plots the atom peaks over the corresponding image
%
% Inputs:
% filename-> the name of the image you-re inputting
%       Example: filename='1213_STEM_HAADF_5.40_Mx DCFI(HAADF).tif’;
%
% Outputs:
% p2dshift-> an array of atom peaks taken from a 2D image
% This function additionally plots the generated atom peak positions over
% the provided image

img=imread(filename);
img = flipud(img);
tmplt = [];
p2dshift=atom_detect(img,tmplt);

% convert image to grayscale double and scale between 0 and 1
if length(size(img))==3
    img = rgb2gray(img);
end

img=double(img);

% Plot the image and add the option to apply contrast
figure
imagesc(img)
axis image
colormap default
imcontrast

% Overlay the peaks onto the image
hold on
plot(p2dshift(:,1),p2dshift(:,2),'k*')