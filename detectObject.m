function varargout = detectObject(varargin)
warning off;
%DETECTOBJECT M-file for detectObject.fig
%      DETECTOBJECT, by itself, creates a new DETECTOBJECT or raises the existing
%      singleton*.
%
%      H = DETECTOBJECT returns the handle to a new DETECTOBJECT or the handle to
%      the existing singleton*.
%
%      DETECTOBJECT('Property','Value',...) creates a new DETECTOBJECT using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to detectObject_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      DETECTOBJECT('CALLBACK') and DETECTOBJECT('CALLBACK',hObject,...) call the
%      local function named CALLBACK in DETECTOBJECT.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help detectObject

% Last Modified by GUIDE v2.5 15-May-2017 12:19:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @detectObject_OpeningFcn, ...
                   'gui_OutputFcn',  @detectObject_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
   gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before detectObject is made visible.
function detectObject_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for detectObject
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes detectObject wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = detectObject_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in uploadPushbutton.
function uploadPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to uploadPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[FileName,PathName] = uigetfile('*','Select Image to Test');
image_path = strcat(PathName,FileName);
img_to_test = imread(image_path);
[m n]=size(img_to_test);
if or(m>700,n>700)
    if(m>n)
    img_to_test=imresize(img_to_test,1500/m);
    else
    img_to_test=imresize(img_to_test,1500/n);
    end
end
axes(handles.axes4);
imshow(img_to_test);
title('Image has been uploaded successfully');
cla(handles.axes5,'reset');
handles.img=img_to_test;
guidata(hObject,handles);


% --- Executes on button press in trainPushbutton.
function trainPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to trainPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cascadeTrainer


% --- Executes on button press in objectDetectPushbutton.
function objectDetectPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to objectDetectPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles,'img')
% figure,imshow(handles.img);
b=uint8(handles.img);

% axes(handles.axes5);
% imshow(b);
TestClassifier1(handles,b);
end


% --- Executes on button press in removeObjectpushbutton.
function removeObjectpushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to removeObjectpushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cla(handles.axes5,'reset');
set(handles.axes5,'xtick',[],'ytick',[]);

Img_in=uint8(handles.img);
b=num2str(rand);
pathname='D:\MyThesis\input\input';
name= strcat(pathname,b,'.jpg');
imwrite(Img_in,name);
% Img_in=imresize(Img_in,[200,200]);
% figure,imshow(Img_in);
[x, y] = ginput;

% Img_in=imresize(Img_in,[200,200]);
target_mask = poly2mask(x, y, size(Img_in, 1), size(Img_in, 2));

I = im2uint8(target_mask);
template = cat(3, I, I, I);

pathname='D:\MyThesis\input\mask\mask';
name= strcat(pathname,b,'.jpg');
imwrite(template,name);
% imwrite(I,'Test12.tif');
% template = imread('Test12.tif');

[inpaintedimg] = inpaintingfw(handles,Img_in,template);


% --- Executes on button press in exitPushbutton.
function exitPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to exitPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close;
