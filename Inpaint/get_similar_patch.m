function [ptch] = get_similar_patch(patch,S_image,temp,pin);

%%search for a similar exemplar in the source region
% for i=1:size(temp,1)
%     for j=1:size(temp,2)
%         if temp(i,j)==255
%             S_image(i,j,1) = NaN;
%             S_image(i,j,2) = NaN;
%             S_image(i,j,3) = NaN;
%         end
%     end
% end
patch_red = zeros(9,9);
patch_green = zeros(9,9);
patch_blue = zeros(9,9);
patch_red = patch(:,:,1);
patch_green = patch(:,:,2);
patch_blue = patch(:,:,3);

if var(double(patch_red(:)))==0
    disp('yes it happend')
    patch_red = imnoise(patch_red,'gaussian');
end
if var(double(patch_green(:)))==0
    patch_green = imnoise(patch_green,'gaussian');
end
if var(double(patch_blue(:)))==0
    patch_blue = imnoise(patch_blue,'gaussian');
end

psin3 = pin-1;
psin4 = psin3/2;

cc1 = normxcorr2(patch_red,S_image(:,:,1)); 
cc2 = normxcorr2(patch_green,S_image(:,:,2)); 
cc3 = normxcorr2(patch_blue,S_image(:,:,3));
%cc = cc2;
cc = (cc1+cc2+cc3)/3;
[max_cc, imax] = max(abs(cc(:)));
[ypeak, xpeak] = ind2sub(size(cc),imax(1));
corr_offset = [ (ypeak-psin3) (xpeak-psin3) ];
if numel(corr_offset)>2
    disp('yes')
end
ptch = S_image(corr_offset(1)-psin4:corr_offset(1)+psin4,corr_offset(2)-psin4:corr_offset(2)+psin4,:);
x= 1;
% patch = rgb2gray(patch);
% patch = cast(patch,'double');
% [s1 s2 s3] = size(S_image);
% M = zeros(s1-9,s2-9);
% for i=1:size(M,1)
%     for j=1:size(M,2)
%         if temp(i,j,:)==255
%             M(i,j)=255;
%         end
%     end
% end
% M = cast(M,'double');
% for i=1:size(M,1)
%     for j=1:size(M,2)
%         if M(i,j)~=255
%             act_patch = S_image(i:i+8,j:j+8,:);
%             act_patch = rgb2gray(act_patch);
%             act_patch = cast(act_patch,'double');
%             if act_patch(:,:,:)~=0
%                 diff = (act_patch - patch).^2;
% %                 D = abs(act_patch-patch).^2;
% %                 D = cast(D,'double');
% %                 MSE = sum(D(:))/numel(act_patch);
%                 M(i,j) = sum(diff(:))/numel(act_patch);
%             else
%                 M(i,j)=255;
%             end
%         end
%     end
% end
% % M2 = zeros(s1-9,s2-9);
% % for i=1:size(M,1)
% %     for j=1:size(M,2)
% %         if temp(i,j,:)==255
% %             M2(i,j)=255;
% %         end
% %     end
% % end
% % M2 = cast(M2,'double');
% % for i=1:size(M2,1)
% %     for j=1:size(M2,2)
% %         if M2(i,j)~=255
% %             act_patch = S_image(i:i+8,j:j+8,:);
% %             act_patch = cast(act_patch,'double');
% %             if act_patch(:,:,:)~=0
% %                 vr = double(var(act_patch(:)));
% %                 mn = double(mean(patch(:)));
% %                 M2(i,j) = double(vr/mn);
% %             else
% %                 M2(i,j)=255;
% %             end
% %         end
% %     end
% % end
% [r,c]=find(M==min(min(M)));          
% 
% ptch = S_image(r(1):r(1)+8,c(1):c(1)+8,:);
