
clear all;
[FileName,PathName] = uigetfile('*','Select Image to Test');
image_path = strcat(PathName,FileName);
Img_in = imread(image_path);
Img_in=imresize(Img_in,[200,200]);

% Img_in = imread('test1.jpg');
imshow(Img_in);
[x, y] = ginput;
target_mask = poly2mask(x, y, size(Img_in, 1), size(Img_in, 2));

I = im2uint8(target_mask);
template = cat(3, I, I, I);
% imwrite(I,'Test12.tif');
% template = imread('Test12.tif');

[inpaintedimg] = inpaintingfw(Img_in,template);