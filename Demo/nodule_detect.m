function varargout = nodule_detect(varargin)
% NODULE_DETECT MATLAB code for nodule_detect.fig
%      NODULE_DETECT, by itself, creates a new NODULE_DETECT or raises the existing
%      singleton*.
%
%      H = NODULE_DETECT returns the handle to a new NODULE_DETECT or the handle to
%      the existing singleton*.
%
%      NODULE_DETECT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NODULE_DETECT.M with the given input arguments.
%
%      NODULE_DETECT('Property','Value',...) creates a new NODULE_DETECT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before nodule_detect_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to nodule_detect_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help nodule_detect

% Last Modified by GUIDE v2.5 28-May-2017 21:11:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @nodule_detect_OpeningFcn, ...
                   'gui_OutputFcn',  @nodule_detect_OutputFcn, ...
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


% --- Executes just before nodule_detect is made visible.
function nodule_detect_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to nodule_detect (see VARARGIN)

% Choose default command line output for nodule_detect
handles.output = hObject;

axes_group = { handles.axes1, handles.axes2, ...
    handles.axes3, handles.axes4 };
handles.axes_group = axes_group;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes nodule_detect wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% Get the handles of lung_analysis
lung_handles = varargin{1};

% lre group
lre_group = {};
fea_map_group = {};

% Show coloring clustered nodule candidate image
ct_im = lung_handles.ct_im;
for k = 1 : numel(ct_im)
    lung_im = ct_im{k};
    % Get lung region extract image
    lre = LungRegionExtraction(lung_im);
    lre_group{end+1} = lre;
    lre_im = lre.extract;
    % Get clustered result
    FE = FeatureExtractV2(lre_im);
    fea_map_group{end+1} = FE.feamap;
    nodule_im = FE.color_slim_im;
    % Show
    axes(handles.axes_group{k});
    imshow(nodule_im);
    
end
handles.fea_map_group = fea_map_group;
handles.lre_group = lre_group;
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = nodule_detect_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in detail1_btn.
function detail1_btn_Callback(hObject, eventdata, handles)
% hObject    handle to detail1_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
lung_extract(handles.lre_group{1});

% --- Executes on button press in detail2_btn.
function detail2_btn_Callback(hObject, eventdata, handles)
% hObject    handle to detail2_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
lung_extract(handles.lre_group{2});

% --- Executes on button press in detail3_btn.
function detail3_btn_Callback(hObject, eventdata, handles)
% hObject    handle to detail3_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
lung_extract(handles.lre_group{3});

% --- Executes on button press in detail4_btn.
function detail4_btn_Callback(hObject, eventdata, handles)
% hObject    handle to detail4_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
lung_extract(handles.lre_group{4});

% --- Executes on button press in extract_fea_btn.
function extract_fea_btn_Callback(hObject, eventdata, handles)
% hObject    handle to extract_fea_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
feature_extract(handles.fea_map_group);