function varargout = lung_extract(varargin)
% LUNG_EXTRACT MATLAB code for lung_extract.fig
%      LUNG_EXTRACT, by itself, creates a new LUNG_EXTRACT or raises the existing
%      singleton*.
%
%      H = LUNG_EXTRACT returns the handle to a new LUNG_EXTRACT or the handle to
%      the existing singleton*.
%
%      LUNG_EXTRACT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LUNG_EXTRACT.M with the given input arguments.
%
%      LUNG_EXTRACT('Property','Value',...) creates a new LUNG_EXTRACT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before lung_extract_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to lung_extract_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help lung_extract

% Last Modified by GUIDE v2.5 28-May-2017 21:25:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @lung_extract_OpeningFcn, ...
                   'gui_OutputFcn',  @lung_extract_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
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


% --- Executes just before lung_extract is made visible.
function lung_extract_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to lung_extract (see VARARGIN)

% Choose default command line output for lung_extract
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes lung_extract wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% Get data from nodule_detect
lre = varargin{1};
% lung_im = varargin{1};
% lre = LungRegionExtraction(lung_im);

% Show lung region extraction process
axes(handles.axes1);
imshow(lre.bitplane);
axes(handles.axes2);
imshow(lre.ero);
axes(handles.axes3);
imshow(lre.median);
axes(handles.axes4);
imshow(lre.dil);
axes(handles.axes5);
imshow(lre.outline);
axes(handles.axes6);
imshow(lre.border);
axes(handles.axes7);
imshow(lre.floodfill);
axes(handles.axes8);
imshow(lre.extract);


% --- Outputs from this function are returned to the command line.
function varargout = lung_extract_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
