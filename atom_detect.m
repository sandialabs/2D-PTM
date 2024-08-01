function [p2dshft,tmplt] = atom_detect(image1,tmplt)

% Function to cross-correlate with image template
% based on templateXcorr_peakfind_script_atom_topleft_function
%
% Step 1:  template 1.  based on user input (which could be from a segmen
%          extracted from the image of interest.
%
% Step 2:  cross-correlate image with the template 1
% Step 3: find peaks.
%      This uses the "FastPeakFind" ver 1.7 matlab function by Adi Natan, Oct 10 2013
%      http://www.mathworks.com/matlabcentral/fileexchange/37388-fast-2d-peak-finder
%      accessed 2/12/14
%
% Step 4: template 2    extract and average all regions around the center
%        of template 1 to get an "average" template
%
% Step 5.  cross-correlate template 2 with the image
%
% Step 6:  find the peaks of this new cross-correlation image.
%
%
%   -Annotation updated  7/17/2014
%   -added uigetfile for user selection of input file

% modifications by Michelle Hummel:  First the image converted to double and 
% is scaled between 0 and 1.
% Atom center is center of template.
% rather than upper left.  Updated template is the same orientation as
% original template (rather than shifted).  Use matlab correlation function
% with the 'same' size option rather than different size. Utilize a
% modified fastPeakFind, which sets threshold = 0 and which works better
% when the peaks have varying intensity.  
% 
% Fa
%-------------------------------------------------------------------------


plotfig = 0;

% convert image to grayscale double and scale between 0 and 1
if length(size(image1))==3
    image1 = rgb2gray(image1);
end

image1=double(image1);
image1 = image1-min(image1(:));
image1 = image1/max(image1(:));

if isempty(tmplt)
    %     tmplt = load('template.mat');
    %     tmplt = tmplt.tmplt;
   
    tmplt = optimize_tmplt_size(image1,[],0);
%     figure; imagesc(tmplt); title('auto-detected template:  should be centered')
else
    %center template (ensure atom center is at center of template)
    tmplt = center_template(tmplt);
end


if plotfig
    figure; imagesc(image1);axis image; title('starting img');
end %if plotfig
imagesizei=size(image1,1);
imagesizej=size(image1,2);


%-cross correlate with template
if plotfig
figure; imagesc(tmplt); axis image; title('starting template');
end %if plotfig
[ny,nx]=size(tmplt);
ci=normxcorr2(tmplt,image1);


%figure; imagesc(ci); axis image;

%---set threshold for ci images
% thresh=0.175;
thresh = 0;
cithresh=ci.*(ci>=thresh); %correlation can have negative and positive values.  Only consider positive values
cithresh = cithresh/max(cithresh(:));  %MHH.  It seems that there are errors when ci>1.

%--find peaks
p=FastPeakFind(cithresh);
%plot(p(1:2:end),p(2:2:end),'r+');
%
p2d=[p(1:2:end),p(2:2:end)]; %convert to 2 column format
%figure;plot(p2d(:,1),p2d(:,2),'r+');
if plotfig
    figure; imagesc(cithresh);axis image;title('init corr map'); hold on
    plot(p2d(:,1),p2d(:,2),'r+');
    hold off
end %if plotfig

%overlay plot of peak positions with original image
p2dshft =[p2d(:,1)-floor(nx/2),p2d(:,2)-floor(ny/2)];
if plotfig
    figure; imagesc(image1); axis image;
    hold on
    plot(p2dshft(:,1),p2dshft(:,2),'r+');
    title('overlay plot of peak positions with original image')
    hold off
end %if plotfig

%go back through and refine template.
buffer = 3; % make the template this much bigger, so we can center template at peak and still have the same size new template
npeaks=size(p2d,1);
tmpltnew=zeros(ny+2*buffer,nx+2*buffer);
tmpltnew=double(tmpltnew);
ngoodpeaks=0;

for n=1:npeaks
    iimin=round(p2dshft(n,2))-floor(ny/2)-buffer;  %y
    jjmin=round(p2dshft(n,1))-floor(nx/2)-buffer;  %x
    iimax=round(p2dshft(n,2))+ceil(ny/2)-1+buffer;
    jjmax=round(p2dshft(n,1))+ceil(nx/2)-1+buffer;
    if (  iimin >0 ...
            && jjmin > 0 ...
            && iimax <= imagesizei ...
            && jjmax <= imagesizej);
        
        tmpltnew=tmpltnew+image1(iimin:iimax,jjmin:jjmax);
        ngoodpeaks=ngoodpeaks+1;
    end
    
    
end
tmpltnew=tmpltnew/double(ngoodpeaks) ; %divide by npeaks to get average
if 0 
    figure; imagesc(tmpltnew); axis image;
    title('late before centering')
end
%disp(size(tmpltnew))
%disp(size(tmplt))
tmpltnew = center_template(tmpltnew,size(tmplt));
% figure; imagesc(tmpltnew); title('new template')
% figure; imagesc(tmpltnew); axis image; title('Second template')

[ny,nx]=size(tmpltnew);
% center peak
if 0 %plotfig
    figure;imagesc(tmpltnew); axis image;
    title('new template')
end %if plotfig
%-------now cross-correlate new image and redo

cinew=normxcorr2(tmpltnew,image1);


%---set threshold for ci images
% thresh=0.2;
cithresh=cinew.*(cinew>=thresh);

%-----
clear p; clear p2d; clear p2dshft;

%--find peaks
% figure; imagesc(cithresh)
p=FastPeakFind(cithresh);
%plot(p(1:2:end),p(2:2:end),'r+');
%
p2d=[p(1:2:end),p(2:2:end)]; %convert to 2 column format
if plotfig
    figure; imagesc(cithresh); hold on; plot(p2d(:,1),p2d(:,2),'r+'); %
    title('peaks on correlation (and thresholded) image with template 2')
    
    figure; imagesc(cinew);axis image; hold on
    plot(p2d(:,1),p2d(:,2),'r+');
    title('peaks on correlation image with template 2')
    
    hold off
end %if plotfig

%overlay plot of peak positions with original image
p2dshft(:,:)=[p2d(:,1)-floor(nx/2),p2d(:,2)-floor(ny/2)];
if plotfig
    figure; imagesc(image1); axis image;
    hold on
    plot(p2dshft(:,1),p2dshft(:,2),'r+');
    title('peaks on original image')
    
    hold off
    
    imcontrast;
end %if


