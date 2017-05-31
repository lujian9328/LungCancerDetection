function varargout = feature_extract(varargin)
% FEATURE_EXTRACT MATLAB code for feature_extract.fig
%      FEATURE_EXTRACT, by itself, creates a new FEATURE_EXTRACT or raises the existing
%      singleton*.
%
%      H = FEATURE_EXTRACT returns the handle to a new FEATURE_EXTRACT or the handle to
%      the existing singleton*.
%
%      FEATURE_EXTRACT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FEATURE_EXTRACT.M with the given input arguments.
%
%      FEATURE_EXTRACT('Property','Value',...) creates a new FEATURE_EXTRACT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before feature_extract_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to feature_extract_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help feature_extract

% Last Modified by GUIDE v2.5 29-May-2017 00:31:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @feature_extract_OpeningFcn, ...
                   'gui_OutputFcn',  @feature_extract_OutputFcn, ...
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


% --- Executes just before feature_extract is made visible.
function feature_extract_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to feature_extract (see VARARGIN)

% Choose default command line output for feature_extract
handles.output = hObject;

% UIWAIT makes feature_extract wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% Get data from nodule_detect
fea_map_group = varargin{1};
handles.fea_map_group = fea_map_group;

% Show the feature vector value in the table
table_group = { handles.fea_tbl1, handles.fea_tbl2, ...
    handles.fea_tbl3, handles.fea_tbl4 };
col_names = {'Area', 'MDC', 'MeanPtg'};
for k = 1 : numel(fea_map_group)
    set(table_group{k}, 'data', fea_map_group{k}, ...
        'ColumnName', col_names, ...
        'ColumnWidth', {50, 50, 50} );
end

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = feature_extract_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in diagnose_btn.
function diagnose_btn_Callback(hObject, eventdata, handles)
% hObject    handle to diagnose_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Generate textX feature vector
feaMat = [];
fea_map_group = handles.fea_map_group;
for k = 1 : numel(fea_map_group)
    feaMat = [feaMat(1:end,1:end); fea_map_group{k}];
end
feaX = GeneFeatureVec(feaMat);

% Load training model
fn_train = 'trainV4.mat';
T = load(fn_train);

% Use SVM model to predict
% SVMModel = T.SVMModel;
% ScoreSVMModel = fitPosterior(SVMModel);
% [~, posterior] = predict(ScoreSVMModel, testX);

% Use Random Forest to predict
RFMdl = T.RFMdl;
[~, posterior] = predict(RFMdl, feaX);

msg = sprintf('The probability that the patient has lung cancer is %f', posterior(2));
h = msgbox(msg);


% Convert the feature matrix to 1 by 30 x 3 vector as model input
function feaVec = GeneFeatureVec(feaMat)
[L, ~] = size(feaMat);
feaVec = [];

% Generate a feature vector for a patient
pickCount = 30;

% Extract 30 candidate features according to MDC value
mdc = feaMat(:, 2);
[~, ind] = sort(mdc, 'descend');

% Smaller than 30 candidates
if L < pickCount
    m1 = mean(feaMat);
    for i = 1 : pickCount
        feaVec(1, end+1:end+3) = m1;
    end
    % More than 30 candidates
else
    feaMat = feaMat(ind(1:pickCount), :);
    
    for i = 1 : pickCount
        feaVec(1, end+1:end+3) = feaMat(i, :);
    end
end