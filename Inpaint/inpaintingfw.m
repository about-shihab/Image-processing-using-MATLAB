function [inpaintedimg] = inpaintingfw(handles,InputImg,TemplateImg)%fillfront approach
psize = 9;%%default patch size used
%InputImg = imread('Input1.png');
%TemplateImg = imread('template2.tif');

% colorTransform = makecform('srgb2lab');
% lab = applycform(InputImg, colorTransform);
% InputImg = lab;

Template_gray = rgb2gray(TemplateImg);
Template_bin = im2bw(Template_gray);
cntr = edge(Template_bin,'canny');%%or use log
Sourceimg = InputImg - TemplateImg;
SourceImg2 = Sourceimg;
% figure,imshow(SourceImg2)
for i=1:size(SourceImg2,1)
    for j=1:size(SourceImg2,2)
        if cntr(i,j)==1
            SourceImg2(i,j,1)=255;
            SourceImg2(i,j,2)=0;
            SourceImg2(i,j,3)=0;
        end
    end
end
% figure,imshow(SourceImg2)
%title('fill front in red')

%%Algorithm: This how the algorithm the proceeds
%The object which has to be removed from the original image has been
%removed and the Sourceimg has empty pixel which has to be filled with best
%possible pixels so that human eye cannot make any difference. Treat the
%problem as evolving a fill front by giving a temporary priority value for
% each pixel in the fill front until all the pixels are filled.

%% create confidence image
disp('creating confidence Image')
padedimage = padarray(Sourceimg,[psize psize],'post');
NumofUnFildPix = numel(find(TemplateImg(:,:,:)==255));

disp('calculating isophotes')
Ix = zeros(size(InputImg));
Iy = zeros(size(InputImg));
[Ix(:,:,1) Iy(:,:,1)] = gradient(double(InputImg(:,:,1)));
[Ix(:,:,2) Iy(:,:,2)] = gradient(double(InputImg(:,:,2)));
[Ix(:,:,3) Iy(:,:,3)] = gradient(double(InputImg(:,:,3)));

Ix = sum(Ix,3)/765;%%summing along 3rd dimension
Iy = sum(Iy,3)/765;
temp = Ix;
Ix = -Iy;%%isophote in x
Iy = temp;%%isophote in y

% temp = Iy;
% Iy = -Ix;%%isophote in x
% Ix = temp;%%isophote in y
%figure,imshow(Ix)
%figure,imshow(Iy)
%%initializing confience image
confidenceImage = zeros(size(padedimage));
for i=1:size(confidenceImage,1)-psize
    for j=1:size(confidenceImage,2)-psize
        if TemplateImg(i,j)==255
            confidenceImage(i,j,:)=0;
        else
            confidenceImage(i,j,:)=1;
        end
        
    end
end

itrn = 1;
p_confid = cast(confidenceImage,'double');
%%%data image
dataimage = zeros(size(confidenceImage));

disp('inpaint start')
while NumofUnFildPix ~=0
%1.a Identify the fill front

    fillfront_xlist = [];%%list of x locations of the fill front
    fillfront_ylist = [];%% list of y locations of the fill front
    in = 1;
    in1 = single(rgb2gray(TemplateImg));
    in2 = im2bw(in1);
    cntr = edge(in2,'canny');
    in3 = ~in1;
    cntr2 = bwdist(in3);%%distance transform
    for i=1:size(in1,1)
        for j=1:size(in1,2)
            if cntr(i,j)~=0
                fillfront_xlist(in) = i;
                fillfront_ylist(in) = j;
                in = in+1;
            end
            
        end
    end
    %compute the patch priorities
    
    numoffillfrontpixls = numel(fillfront_xlist);
    psin = (psize-1)/2;
    cpixels = zeros(1,numoffillfrontpixls);
    %confidence along the fill frontpixels
    for i=1:numoffillfrontpixls
        confpatch = confidenceImage(fillfront_xlist(i)-psin:fillfront_xlist(i)+psin,fillfront_ylist(i)-psin:fillfront_ylist(i)+psin,:);
        val = sum(sum(sum(confpatch)))/numel(confpatch);
        cpixels(i)=val;
    end
    
    
    %%data term made up of the isotope values and normal values
    ispopixels_x = zeros(1,numoffillfrontpixls);
    ispopixels_y = zeros(1,numoffillfrontpixls);
    for i=1:numoffillfrontpixls
        ispopixels_x(i)= Ix(fillfront_xlist(i),fillfront_ylist(i));
        ispopixels_y(i)= Iy(fillfront_xlist(i),fillfront_ylist(i));
    end
    nx = [];
    ny = [];
    [nx,ny] = gradient(double(in3));
    normalpixels_x = zeros(1,numoffillfrontpixls);
    normalpixels_y = zeros(1,numoffillfrontpixls);
    for i=1:numoffillfrontpixls
        normalpixels_x(i)= nx(fillfront_xlist(i),fillfront_ylist(i))/255;
        normalpixels_y(i)= ny(fillfront_xlist(i),fillfront_ylist(i))/255;
    end
    
    datavalpixels_x = zeros(1,numoffillfrontpixls);
    datavalpixels_y = zeros(1,numoffillfrontpixls);
    datavalpixels_x = ispopixels_x.*normalpixels_x;
    datavalpixels_y = ispopixels_y.*normalpixels_y;
    
    Dval = abs(datavalpixels_x+datavalpixels_y)+0.001;
    priorofpix = zeros(1,numoffillfrontpixls);
    %cpixels = 0.5*cpixels+0.5;
    %priorofpix = (cpixels+Dval)+0.001;
    priorofpix = cpixels.*Dval+0.001;
    idx = [];
    ing = [];
    [ing,idx] = sort(priorofpix,'descend');
    %[ing,idx] = max(priorofpix(:));
    
   for i=1:numoffillfrontpixls
    toppixl = idx(i);
    patch2 = padedimage(fillfront_xlist(toppixl)-psin:fillfront_xlist(toppixl)+psin,fillfront_ylist(toppixl)-psin:fillfront_ylist(toppixl)+psin,:);
    patch3 = get_similar_patch(patch2,padedimage,TemplateImg,psize);
    patch4 = zeros(size(patch2));
    patch4 = cast(patch4,'uint8');
    timage = [];
    timage = padarray(TemplateImg,[9 9],'post');
    patch_templ = timage(fillfront_xlist(toppixl)-psin:fillfront_xlist(toppixl)+psin,fillfront_ylist(toppixl)-psin:fillfront_ylist(toppixl)+psin,:);
    for p=1:size(patch_templ,1)
        for q=1:size(patch_templ,2)
            if patch_templ(p,q,:)==0
                patch4(p,q,1)=patch2(p,q,1);
                patch4(p,q,2)=patch2(p,q,2);
                patch4(p,q,3)=patch2(p,q,3);
            else
                patch4(p,q,1)=patch3(p,q,1);
                patch4(p,q,2)=patch3(p,q,2);
                patch4(p,q,3)=patch3(p,q,3);
            end
        end
    end
    confidenceImage(fillfront_xlist(toppixl),fillfront_ylist(toppixl))= cpixels(toppixl);
    
    padedimage(fillfront_xlist(toppixl)-psin:fillfront_xlist(toppixl)+psin,fillfront_ylist(toppixl)-psin:fillfront_ylist(toppixl)+psin,:)= patch4;
   end

    %confidenceImage(fillfront_xlist(toppixl),fillfront_ylist(toppixl))= cpixels(toppixl);
    TemplateImg2 = zeros(size(InputImg));
    for i=1:size(InputImg,1)
        for j=1:size(InputImg,2)
            if padedimage(i,j,1)==0 && padedimage(i,j,2)==0 && padedimage(i,j,3)==0 && TemplateImg(i,j,1)==255 && TemplateImg(i,j,2)==255 && TemplateImg(i,j,3)==255
                TemplateImg2(i,j,:)=255;
            end
        end
    end
    TemplateImg = TemplateImg2;
    NumofUnFildPix = numel(find(TemplateImg(:,:,:)==255))
   
end
inpaintedimg = padedimage(1:size(InputImg,1),1:size(InputImg,2),:);
%imwrite(inpaintedimg,'birdsimage.tif')
% figure,imshow(inpaintedimg)
axes(handles.axes5);
imshow(inpaintedimg);
b=num2str(rand);
pathname='D:\MyThesis\Inpainted Images\Inpainted Images';
name= strcat(pathname,b,'.jpg');
imwrite(inpaintedimg,name);
title('After removing Object')