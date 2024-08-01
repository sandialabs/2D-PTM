function tmplt_out = optimize_tmplt_size(image,tmplt,plt_fig)
% Optimize size of the template by scaling to get maximum correlation 

if nargin<3
    plt_fig = 0;
end

if isempty(tmplt)
     tmplt = fspecial('gaussian',25,5.5);
end
% iscale_vec=.2:.1:2; % for template fspecial('gaussian',25,5.5), iscale_vec =.1 gives a 3x3 template,  .2 gives a 5x5 template
step_sz = 1;
sz_vec = 5:step_sz:size(tmplt,1)*2;
iplt = 0;
sz_image = size(image);
maxval = nan(1,length(sz_vec));
sz_tmplt_vec = nan(1,length(sz_vec));
maxval_test = nan(1,length(sz_vec)); %remove


for isz=sz_vec
    tmplt_scaled = imresize(tmplt,[isz,isz],'bilinear'); %bicubic is the default but can give values outside of original range (and can have a "haloing" effect)
    tmplt_scaled = tmplt_scaled-min(tmplt_scaled(:));
    tmplt_scaled = tmplt_scaled/max(tmplt_scaled(:));
    corr_image = normxcorr2(tmplt_scaled,image);
    % remove outer edges of corr_image to account for boundary effects
    sz_tmplt = size(tmplt_scaled); % = [num_rows, num_cols]
    
    corr_image = corr_image(sz_tmplt(1)+1:sz_image(1)-sz_tmplt(1),sz_tmplt(2)+1:sz_image(2)-sz_tmplt(2));  % remove outer edges of corr_image to account for boundary effects
    if length(corr_image)<1
        break
    end
    iplt = iplt+1;
    sz_tmplt_vec(iplt) = sz_tmplt(1);
    maxval(iplt) = median(max(corr_image)); %median maximum value over all columns
    maxval_test(iplt) = max(corr_image(:)); %maximum value  %remove
    % if maxval(iplt)< the last 5 then break
%     idx = max(1,iplt-5):max(1,iplt-1)
%     lgcl = maxval(iplt)<maxval(max(1,iplt-5):max(1,iplt-1))
    dstep = round(10/step_sz);
    if sum(maxval(iplt)<maxval(max(1,iplt-dstep):max(1,iplt-1)))==dstep %this value is less than previous 5
        break
    end
end

% find peaks
[pkt,maxloc] = findpeaks(maxval);

if isempty(pkt)
    [~,maxloc] = max(maxval); % typically first or last entry if pkt is empty
end

if length(pkt)>1
    [~,maxloc_pkt] = max(pkt);
    maxloc = maxloc(maxloc_pkt);
end

sz = sz_vec(maxloc);    

tmplt_out = imresize(tmplt,[sz,sz],'bilinear');
tmplt_out = tmplt_out-min(tmplt_out(:));
tmplt_out = tmplt_out/max(tmplt_out(:));

if plt_fig
    disp(['maxloc ',num2str(maxloc)])
    figure; plot(sz_tmplt_vec,maxval,'-o'); hold on; 
    plot(sz_tmplt_vec,maxval_test,'-o'); %remove maxval_test
    
    plot(sz_tmplt_vec(maxloc),maxval(maxloc),'*')
    
    title('Optimizing template size')
    legend('median max over cols','absolute max')
    xlabel('size template')
end