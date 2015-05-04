function varargout = samit(varargin)
% samit MATLAB code for samit.fig
%      samit, by itself, creates a new samit or raises the existing
%      singleton*.
%
%      H = samit returns the handle to a new samit or the handle to
%      the existing singleton*.
%
%      samit('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in samit.M with the given input arguments.
%
%      samit('Property','Value',...) creates a new samit or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before samit_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to samit_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help samit

% Last Modified by GUIDE v2.5 02-Apr-2015 14:27:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @samit_OpeningFcn, ...
                   'gui_OutputFcn',  @samit_OutputFcn, ...
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


% --- Executes just before samit is made visible.
function samit_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to samit (see VARARGIN)

% Choose default command line output for samit
handles.output = hObject;

% Update handles structure
handles.atlas   = 'none';  % Creates handles.atlas variable
handles.gs      = 5.5;     % Creates handles.gs (Defaults glucose: 5.5)
handles.imgtype = 'none';  % Units in the image
handles.regtype = 'rigid'; % Regularisation type
handles.otype   = 'SUV';   % Standarization procedure of the uptake

global defaults            % Allows to open samit without SPM running
if isempty(defaults)
    spm('defaults','PET');
    handles.modality = spm('CheckModality'); % Saves SPM modality
    clear defaults;
else
    handles.modality = spm('CheckModality');
end
guidata(hObject, handles);

% UIWAIT makes samit wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% ---- Add samit toolbox pathway -----
mypath = fileparts(which('samit'));
addpath(mypath);
spm_select('prevdirs',mypath);

% ---- Load samit defaults -----
%samit_defaults;
   

%% Welcome message
disp(' ');
disp('Small Animal Molecular Imaging Toolbox (SAMIT)');
disp('==============================================');
disp(' ');

% ---- NGMB Logo ----
logo = imread(fullfile(mypath,'images','NGMBlogo2.png')); % Read logo image
image(logo);
axis off;
axis image;
%axis tight;

% --- Splash Screen ---
% Shows splash screen  
WS   = spm('WinScale');		% Window scaling factors
X = imread(fullfile(mypath,'images','NGMBlogo.png'));
aspct = size(X,1) / size(X,2);
ww = 400;
srect = [200 300 ww ww*aspct] .* WS;   % Scaled size splash rectangle
h = figure('visible','off',...
	       'menubar','none',...
	       'numbertitle','off',...
	       'name','Welcome to SAMIT',...
	       'pos',srect);
im = image(X);
%colormap(map);
ax = get(im, 'Parent');
axis off;
axis image;
axis tight;
set(ax,'plotboxaspectratiomode','manual',...
       'unit','pixels',...
       'pos',[0 0 srect(3:4)]);
set(h,'visible','on');
pause(3);
close(h);
% --- end splash

% --- Outputs from this function are returned to the command line.
function varargout = samit_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%% Animal atlas
% --- Executes during object creation, after setting all properties.
function tag_atlas_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tag_atlas_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in tag_atlas_popup.
function tag_atlas_popup_Callback(hObject, eventdata, handles)
% hObject    handle to tag_atlas_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns tag_atlas_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from tag_atlas_popup

% Determine the selected data set
val = get(handles.tag_atlas_popup, 'Value');

% Small Animal Atlases
switch val
    case 1 % No selection
        set(handles.tag_origin_bregma,'Enable','off');
        set(handles.tag_mask_button,'Enable','off');
        set(handles.tag_templates_construction,'Enable','off');
        set(handles.tag_analysis_VOI,'Enable','off');

    case 2 % Schwarz Rat Atlas
        handles.atlas = 'Schwarz';
        set(handles.tag_origin_bregma,'Enable','on');        
        set(handles.tag_mask_button,'Enable','on');
        set(handles.tag_templates_construction,'Enable','on');
        set(handles.tag_analysis_VOI,'Enable','on');
        samit_defaults(handles.atlas);

    case 3 % Ma Mouse Atlas
        handles.atlas = 'Ma';
        set(handles.tag_origin_bregma,'Enable','off');  % Bregma is not defined in this template
        set(handles.tag_mask_button,'Enable','on');
        set(handles.tag_templates_construction,'Enable','on');
        set(handles.tag_analysis_VOI,'Enable','on');
        samit_defaults(handles.atlas);
end
guidata(hObject, handles);

% ========== Image Pre-Processing Section =================

% === Reset image
% --- Executes on button press in tag_reset_button.
function tag_reset_button_Callback(hObject, eventdata, handles)
% hObject    handle to tag_reset_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
samit_reset; % Reset image (transformation and origin)


% === Coordinates of the origin
% --- Executes on button press in tag_origin_center.
function tag_origin_center_Callback(hObject, eventdata, handles)
% hObject    handle to tag_origin_center (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
samit_origin('center', handles.atlas);  % Origin coordinates: Center of the image

% --- Executes on button press in tag_origin_bregma.
function tag_origin_bregma_Callback(hObject, eventdata, handles)
% hObject    handle to tag_origin_bregma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
samit_origin('bregma',handles.atlas);  % Origin coordinates: Bregma (Rat)


% === Spatial registration
% --- Executes during object creation, after setting all properties.
function tag_reg_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tag_reg_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in tag_reg_popup
function tag_reg_popup_Callback(hObject, eventdata, handles)
% hObject    handle to tag_reg_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val = get(handles.tag_reg_popup, 'Value'); % Determine the selected data set

% Registration types
switch val
    case 1 % No selection
        set(handles.tag_multiNormalise,'Enable','off');
    case 2 % No regularisation
        handles.regtype = 'rigid';
        set(handles.tag_multiNormalise,'Enable','on');
    case 3 % Almost rigid body (default)
        handles.regtype = 'subj';
        set(handles.tag_multiNormalise,'Enable','on');
    case 4 % inter-subject registration
        handles.regtype = 'none';
        set(handles.tag_multiNormalise,'Enable','on');
end
guidata(hObject, handles);

% Normalise multiple images
% --- Executes on button press in tag_multiNormalise.
function tag_multiNormalise_Callback(hObject, eventdata, handles)
% hObject    handle to tag_multiNormalise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
samit_multiNormalise(handles.regtype, handles.atlas);


% === Normalize uptake
% --- Executes on button press in tag_uptake_table.
function tag_uptake_table_Callback(hObject, eventdata, handles)
% hObject    handle to tag_uptake_table (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
samit_table;  % Run samit_table code

% --- Executes during object creation, after setting all properties.
function tag_uptake_units_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tag_uptake_units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in tag_uptake_units.
function tag_uptake_units_Callback(hObject, eventdata, handles)
% hObject    handle to tag_uptake_units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Determine the selected data set
val = get(handles.tag_uptake_units, 'Value');

% Expected units in the image file
switch val
    case 1 % No selection
        set(handles.tag_uptake_create,'Enable','off');
    case 2 % Bq
        handles.imgtype = 'Bq';
        if handles.gs > 0
            set(handles.tag_uptake_create,'Enable','on');
        end
    case 3 % kBq
        handles.imgtype = 'kBq';
        if handles.gs > 0
            set(handles.tag_uptake_create,'Enable','on');
        end
    case 4 % MBq
        handles.imgtype = 'MBq';
        if handles.gs > 0
            set(handles.tag_uptake_create,'Enable','on');
        end
    case 5 % mCi
        handles.imgtype = 'mCi';
        if handles.gs > 0
            set(handles.tag_uptake_create,'Enable','on');
        end
end
guidata(hObject, handles);

% Standarization procedure
% --- Executes during object creation, after setting all properties.
function tag_uptake_type_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tag_uptake_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in tag_reg_popup
function tag_uptake_type_Callback(hObject, eventdata, handles)
% hObject    handle to tag_uptake_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val = get(handles.tag_uptake_type, 'Value'); % Determine the selected data set

switch val
    case 1 % 'SUV' Standarized Uptake Value (default)
        handles.otype = 'SUV';
        set(handles.tag_uptake_gs,'Enable','off');
    case 2 % 'SUVglc' SUV corrected for glucose
        handles.otype = 'SUVglc';
        set(handles.tag_uptake_gs,'Enable','on');
    case 3 % 'SUVw' SUV corrected for whole brain uptake
        handles.otype = 'SUVw';
        set(handles.tag_uptake_gs,'Enable','off');
    case 4 % 'IDg'    Percentage of injected dose per gram
        handles.otype = 'IDg';
        set(handles.tag_uptake_gs,'Enable','off');
end
guidata(hObject, handles);

% Standard Glucose Level
% --- Executes during object creation, after setting all properties.
function tag_uptake_gs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tag_uptake_gs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function tag_uptake_gs_Callback(hObject, eventdata, handles)
% hObject    handle to tag_uptake_gs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Reference glucose value
gs = str2double(get(handles.tag_uptake_gs, 'String'));
if isnan(gs) || ~isreal(gs) || sign(gs) ~= 1
    % isdouble returns NaN for non-numbers and 'gs' cannot be complex
    % Disable the 'Create SUV image' button
    set(handles.tag_uptake_gs,'ForegroundColor','red')
    set(handles.tag_uptake_create,'Enable','off')
else
    set(handles.tag_uptake_gs,'ForegroundColor','black')
    set(handles.tag_uptake_create,'Enable','on')
    
end
handles.gs = gs;
guidata(hObject, handles);

% --- Executes on button press in tag_uptake_create.
function tag_uptake_create_Callback(hObject, eventdata, handles)
% hObject    handle to tag_uptake_create (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
samit_standarize_uptake(handles.atlas, handles.imgtype, handles.otype, handles.gs); % Run code



% === Mask image
% --- Executes on button press in tag_mask_button.
function tag_mask_button_Callback(hObject, eventdata, handles)
% hObject    handle to tag_mask_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
samit_mask(handles.atlas); % Apply whole brain mask



% ========== Construction & Evaluation of tracer specific templates =================

% --- Executes on button press in tag_templates_construction.
function tag_templates_construction_Callback(hObject, eventdata, handles)
% hObject    handle to tag_templates_construction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
samit_template_construction(handles.atlas);

% --- Executes on button press in tag_templates_accuracy.
function tag_templates_accuracy_Callback(hObject, eventdata, handles)
% hObject    handle to tag_templates_accuracy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
samit_template_accuracy();

% ========== Analysis =================

% --- Executes on button press in tag_analysis_VOI.
function tag_analysis_VOI_Callback(hObject, eventdata, handles)
% hObject    handle to tag_analysis_VOI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
samit_VOI(handles.atlas);


% ========== Close SAMIT =================

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure

% Display
disp(' ');
disp(['Initializing default parameters: SPM ', handles.modality, '...']);
disp(' ');

% Remove pathways
%rmpath(fileparts(which('samit'))); % SAMIT
%disp('SAMIT removed from MATLAB path');
%disp(' ');
   
% Load default SPM parameters
global defaults;
defaults = spm_get_defaults;
spm('defaults',handles.modality);
spm_jobman('initcfg');
delete(hObject);
