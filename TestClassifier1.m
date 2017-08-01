function [detected_object] = TestClassifier1(handles, img_to_test )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
sohidMinar_xml_file='SohidMinar.xml';
sohidMinar_detector=vision.CascadeObjectDetector(sohidMinar_xml_file);

% Find bbox of any detected objects
sohidMinar_bbox = step(sohidMinar_detector,img_to_test);

% number of detected sohid minar
sohidMinar_nDetected = size(sohidMinar_bbox,1);
% figure;
% imshow(img_to_test);
% hold on;

axes(handles.axes5);
imshow(img_to_test);

    
% imshow(img_to_test,handles.axes5);


for ii = 1:sohidMinar_nDetected
patch([sohidMinar_bbox(ii,1),sohidMinar_bbox(ii,1)+sohidMinar_bbox(ii,3),sohidMinar_bbox(ii,1)+sohidMinar_bbox(ii,3),sohidMinar_bbox(ii,1),...
    sohidMinar_bbox(ii,1)],[sohidMinar_bbox(ii,2),sohidMinar_bbox(ii,2),sohidMinar_bbox(ii,2)+sohidMinar_bbox(ii,4),...
    sohidMinar_bbox(ii,2)+sohidMinar_bbox(ii,4),sohidMinar_bbox(ii,2)],'g','facealpha',.4);
text(sohidMinar_bbox(ii,1),sohidMinar_bbox(ii,2)+30,'ShohidMinar')
end
sohidttl='';
if sohidMinar_nDetected>0
   sohidttl=strcat(num2str(sohidMinar_nDetected),'  Shohid minar ');
end

stopxml='STOP.xml';
stop_detector=vision.CascadeObjectDetector(stopxml);

% Find bbox of any detected objects
stop_bbox = step(stop_detector,img_to_test);

% number of detected sohid minar
stop_nDetected = size(stop_bbox,1);
% figure;
% imshow(img_to_test);
% hold on;

for ii = 1:stop_nDetected
patch([stop_bbox(ii,1),stop_bbox(ii,1)+stop_bbox(ii,3),stop_bbox(ii,1)+stop_bbox(ii,3),stop_bbox(ii,1),...
    stop_bbox(ii,1)],[stop_bbox(ii,2),stop_bbox(ii,2),stop_bbox(ii,2)+stop_bbox(ii,4),...
    stop_bbox(ii,2)+stop_bbox(ii,4),stop_bbox(ii,2)],'g','facealpha',.4);
text(stop_bbox(ii,1),stop_bbox(ii,2)+30,'Stop Sign')
end


% --happy DETECTOR -- %
% XML File name
apple_xml_file = 'apple.xml';
apple_detector = vision.CascadeObjectDetector(apple_xml_file,'MinSize',[100 100]);

% Find bbox of any detected objects
apple_bbox = step(apple_detector,img_to_test);

% remove any bounding boxes where the red is not the dominant color
apple_nDetected = size(apple_bbox,1);
counter = 0;
for i = 1:apple_nDetected
roi = img_to_test(apple_bbox(i,2):apple_bbox(i,2)+apple_bbox(i,4),...
        apple_bbox(i,1):apple_bbox(i,1)+apple_bbox(i,3),:);

    roi = (rgb2ycbcr(roi));
    roi=roi(:,:,3);
% YCBCR_mask = YCBCR(:,:,3)>143;

    [row, col] = size(roi);
    amount_red = sum(sum(roi>156)); %amount of red pixels
    red_ratio = amount_red/(row*col);
    if red_ratio < 0.54 ;
        %remove bounding box if less than 0.58 the pixels are red
        counter = counter+1;
        to_delete(counter) = i;        
    end    
end
% delete columns that don't meet red threshold
try
apple_bbox(to_delete,:) = [];
end
apple_nDetected = size(apple_bbox,1);


%Show the results
% figure();
% imshow(img_to_test);
% hold on;

for ii = 1:apple_nDetected
patch([apple_bbox(ii,1),apple_bbox(ii,1)+apple_bbox(ii,3),apple_bbox(ii,1)+apple_bbox(ii,3),apple_bbox(ii,1),apple_bbox(ii,1)],...
[apple_bbox(ii,2),apple_bbox(ii,2),apple_bbox(ii,2)+apple_bbox(ii,4),apple_bbox(ii,2)+apple_bbox(ii,4),apple_bbox(ii,2)],...
'r','facealpha',0.5);
text(apple_bbox(ii,1),apple_bbox(ii,2)+20,'Apple')
end




applettl='';
if apple_nDetected>0
    applettl=strcat(' ',num2str(apple_nDetected),'  apple ');
end
ttl=strcat(sohidttl,{' '},applettl,' has been found');

if or(apple_nDetected>0,sohidMinar_nDetected>0)
    title(ttl);
else
    title('No object has been found');
end
end

