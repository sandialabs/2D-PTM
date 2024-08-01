function tmplt_out = center_template(tmplt,sz_out)
% Input:
%   tmplt:  input template before centering (and possible resizing)
%   sz_out:  (optional), [rows, cols], if sz_out exists, then size out tmplt_out will be
%       this size (if possible)
% Output:
%   tmplt_out: template which has been centered and (optinally) cropped to
%       be size 'sz_out' if possible 

sz = size(tmplt);
szx = sz(2); %length in the x direction (columns)
szy = sz(1); % length in the y direction (rows)

% Typically a buffer was added to the template (size(tmplt) is different
% than sz_out), to enable centering.  Zero out the buffer, then find center
% of this modified template.  

buffer = (size(tmplt)-sz_out)/2;

if round(buffer(1)) ~= buffer(1) | round(buffer(1)) ~= buffer(1)
    error('Error with buffer size')
end

minval = min(tmplt(:));
tmplt_tmp = tmplt; %set buffer to minval 
tmplt_tmp(1:buffer,:) = minval;
tmplt_tmp(:,1:buffer) = minval;
tmplt_tmp(end-buffer+1:end,:) = minval;
tmplt_tmp(:,end-buffer+1:end) = minval;

% % for plotting:
% tmplt_tmp2 = tmplt_tmp;  
% figure; subplot(1,3,1); imagesc(tmplt);  subplot(1,3,2); imagesc(tmplt_tmp2)
% % end for plotting

sortval = sort(tmplt_tmp(:),'ascend');
numpix = round(sz_out(1)*sz_out(2)*.3);
threshval = sortval(end-numpix);
tmplt_tmp(tmplt_tmp<threshval) = minval;

% % for plotting
% subplot(1,3,3); imagesc(tmplt_tmp);
% % end for plotting


% %% test for when length(stats)>1
% tmplt_tmp2 = tmplt;
% tmplt_tmp2(tmplt_tmp2<.6)=0;
% figure; imagesc(tmplt_tmp2); colorbar
% stats2 = regionprops(logical(tmplt_tmp2),tmplt_tmp2,'WeightedCentroid');
% for i = 1:length(stats2)
%     p_tmp(i,:) = stats2(i).WeightedCentroid; %[xval,yval;xval,yval;....];  col format
% end
% hold on; plot(p_tmp(:,1),p_tmp(:,2),'r*')





stats = regionprops(logical(tmplt_tmp>minval),tmplt_tmp,'WeightedCentroid');
for i = 1:length(stats)
    p_tmp(i,:) = stats(i).WeightedCentroid; %[xval,yval;xval,yval;....];  col format
end



    

%% if using fastpeakfind_weightedcentroid use this
% ptest = FastPeakFind_weightedcentroid(tmplt);
%  p_tmp = [ptest(1:2:end),ptest(2:2:end)]; %[xval,yval;xval,yval;....];  col format
% end us this

if length(p_tmp)>2
     % return the peak that is closest to the center of template
   
    midx = size(tmplt,2)/2; midy = size(tmplt,1)/2;
    dist2 = [];
    for i = 1:size(p_tmp,1)
        dist2(i) = (midx-p_tmp(i,1))^2+(midy-p_tmp(i,2))^2;
    end
    [minval,minloc] = min(dist2);
    ptest = p_tmp(minloc,:);
%     figure; imagesc(tmplt)
%     hold on; plot(ptest(1),ptest(2),'r*')   
else
    ptest = p_tmp(1,:);
end

if 0 %for debugging
    figure; imagesc(tmplt);
    hold on; plot(px,py,'r+')
    plot(ptest(1),ptest(2),'ro')
    legend('FPF','weighted centroid')
end %if

% translate image so weighted centroid is at center
% center of pixels are at 1,2,3,...., N, so image goes from .5 to N+.5 and
% midpoint is really given by eqns below
midx = (szx+1)/2; midy = (szy+1)/2;
tmplt = imtranslate(tmplt,[midx-ptest(1),midy-ptest(2)]);

buffer = (size(tmplt)-sz_out)/2; % x and y values should be the same
if buffer(1) ~= buffer(2)
    error('template and size_out should be square')
end

buffer = buffer(1);

if buffer ~= round(buffer)
    error('buffer should be an integer')
end

tmplt_out = tmplt(buffer+1:szx-buffer,buffer+1:szy-buffer);
tmplt_out = tmplt_out-min(tmplt_out(:));
tmplt_out = tmplt_out/max(tmplt_out(:));


if 0
    figure; subplot(1,2,1); imagesc(tmplt); colorbar; axis image
    subplot(1,2,2); imagesc(tmplt_out); colorbar; axis image
end %if 0





