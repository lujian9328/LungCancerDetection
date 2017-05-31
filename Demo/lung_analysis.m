function varargout = lung_analysis(varargin)
% LUNG_ANALYSIS MATLAB code for lung_analysis.fig
%      LUNG_ANALYSIS, by itself, creates a new LUNG_ANALYSIS or raises the existing
%      singleton*.
%
%      H = LUNG_ANALYSIS returns the handle to a new LUNG_ANALYSIS or the handle to
%      the existing singleton*.
%
%      LUNG_ANALYSIS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LUNG_ANALYSIS.M with the given input arguments.
%
%      LUNG_ANALYSIS('Property','Value',...) creates a new LUNG_ANALYSIS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before lung_analysis_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to lung_analysis_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help lung_analysis

% Last Modified by GUIDE v2.5 28-May-2017 20:58:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @lung_analysis_OpeningFcn, ...
                   'gui_OutputFcn',  @lung_analysis_OutputFcn, ...
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


% --- Executes just before lung_analysis is made visible.
function lung_analysis_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to lung_analysis (see VARARGIN)

% Choose default command line output for lung_analysis
handles.output = hObject;



% UIWAIT makes lung_analysis wait for user response (see UIRESUME)
% uiwait(handles.figure1);

axes_group = { handles.axes1, handles.axes2, ...
    handles.axes3, handles.axes4 };
handles.axes_group = axes_group;

% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = lung_analysis_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in read_btn.
function read_btn_Callback(hObject, eventdata, handles)
% hObject    handle to read_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fn, pn, fi] = uigetfile('*.bmp', 'File Selector', 'MultiSelect', 'on');
if fi ~= 0
    ct_im = {};
    for k = 1 : numel(fn)
        imgdir = strcat(pn, fn{k});
        Im = imread(imgdir);
        ct_im{end+1} = Im;
        axes(handles.axes_group{k});
        imshow(Im);
    end
    handles.ct_im = ct_im;
end
guidata(hObject, handles);

% --- Executes on button press in detect_btn.
function detect_btn_Callback(hObject, eventdata, handles)
% hObject    handle to detect_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
nodule_detect(handles);