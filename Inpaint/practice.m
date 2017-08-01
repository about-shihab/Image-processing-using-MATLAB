clc;
clear all;
Img_in= imread('test1.jpg');
b=num2str(rand);
pathname='D:\MyThesis\input';
name= strcat(b,'.jpg');
imwrite(Img_in,name);