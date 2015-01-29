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

% Last Modified by GUIDE v2.5 13-Nov-2014 17:31:31

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
handles.gs = 5.5;        % Creates handles.gs (Glucose: 5.5)
handles.type = 'none';   % Creates handles.type variable (Bq / MBq)
handles.specie = 'none'; % Creates handles.specie variable (rat / mouse)

global defaults          % Allows to open samit without SPM running
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
axes(handles.logo);
imshow(logo);

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

%% Animal specie
% --- Executes during object creation, after setting all properties.
function tag_specie_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tag_specie_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in tag_specie_popup.
function tag_specie_popup_Callback(hObject, eventdata, handles)
% hObject    handle to tag_specie_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns tag_specie_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from tag_specie_popup

% Determine the selected data set
val = get(handles.tag_specie_popup, 'Value');
% Animal species: rat and mouse
switch val
    case 1 % No selection
        set(handles.tag_origin_bregma,'Enable','off');
        set(handles.tag_mask_button,'Enable','off');
        set(handles.tag_templates_construction,'Enable','off');
        set(handles.tag_analysis_VOI,'Enable','off');
        set(handles.tag_correction_wholebrain,'Enable','off');
    case 2
        handles.specie = 'rat';
        set(handles.tag_origin_bregma,'Enable','on');        
        set(handles.tag_mask_button,'Enable','on');
        set(handles.tag_templates_construction,'Enable','on');
        set(handles.tag_analysis_VOI,'Enable','on');
        set(handles.tag_correction_wholebrain,'Enable','on');
        samit_defaults(handles.specie);
    case 3
        handles.specie = 'mouse';
        set(handles.tag_origin_bregma,'Enable','off');  % Bregma is not defined in the current template
        set(handles.tag_mask_button,'Enable','on');
        set(handles.tag_templates_construction,'Enable','on');
        set(handles.tag_analysis_VOI,'Enable','on');
        set(handles.tag_correction_wholebrain,'Enable','on');
        samit_defaults(handles.specie);
end
guidata(hObject, handles);

%% Fix
% --- Executes on button press in tag_fix_button.
function tag_fix_button_Callback(hObject, eventdata, handles)
% hObject    handle to tag_fix_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
samit_fix; % Run samit_fix code

%% Origin
% --- Executes on button press in tag_origin_bregma.
function tag_origin_bregma_Callback(hObject, eventdata, handles)
% hObject    handle to tag_origin_bregma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
samit_origin('bregma',handles.specie);  % Origin coordinates: Bregma (Rat)

% --- Executes on button press in tag_origin_center.
function tag_origin_center_Callback(hObject, eventdata, handles)
% hObject    handle to tag_origin_center (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
samit_origin('center', handles.specie);  % Origin coordinates: Center of the image

%% Scale (Not necessary anymore 06-10-2014)
% --- Executes on button press in tag_scale_button.
%function tag_scale_button_Callback(hObject, eventdata, handles)
% hObject    handle to tag_scale_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%samit_scale;      % Scale image voxel (x1 <-> 0.1)

%% SUV tools
% --- Executes on button press in tag_SUVtools_Table.
function tag_SUVtools_Table_Callback(hObject, eventdata, handles)
% hObject    handle to tag_SUVtools_Table (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
samit_tableSUV;  % Run samit_tableSUV code

% --- Executes during object creation, after setting all properties.
function tag_SUVtools_units_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tag_SUVtools_units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in tag_SUVtools_units.
function tag_SUVtools_units_Callback(hObject, eventdata, handles)
% hObject    handle to tag_SUVtools_units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns tag_SUVtools_units contents as cell array
%        contents{get(hObject,'Value')} returns selected item from tag_SUVtools_units

% Determine the selected data set
val = get(handles.tag_SUVtools_units, 'Value');
% Expected units of the image file (uPET Bq/cc & uSPECT MBq/mL)
switch val
    case 1 % No selection
        set(handles.tag_SUVtools_Create,'Enable','off');
    case 2
        handles.type = 'Bq';
        if handles.gs > 0
            set(handles.tag_SUVtools_Create,'Enable','on');
        end
    case 3
        handles.type = 'MBq';
        if handles.gs > 0
            set(handles.tag_SUVtools_Create,'Enable','on');
        end
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function tag_SUVtools_gs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tag_SUVtools_gs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function tag_SUVtools_gs_Callback(hObject, eventdata, handles)
% hObject    handle to tag_SUVtools_gs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tag_SUVtools_gs as text
%        str2double(get(hObject,'String')) returns contents of tag_SUVtools_gs as a double

% Validate that the glucose value
gs = str2double(get(handles.tag_SUVtools_gs, 'String'));
if isnan(gs) || ~isreal(gs) || sign(gs) ~= 1
    % isdouble returns NaN for non-numbers and 'gs' cannot be complex
    % Disable the 'Create SUV image' button
    set(handles.tag_SUVtools_gs,'ForegroundColor','red')
    set(handles.tag_SUVtools_Create,'Enable','off')
else
    set(handles.tag_SUVtools_gs,'ForegroundColor','black')
    set(handles.tag_SUVtools_Create,'Enable','on')
    
end
handles.gs = gs;
guidata(hObject, handles);

% --- Executes on button press in tag_SUVtools_Create.
function tag_SUVtools_Create_Callback(hObject, eventdata, handles)
% hObject    handle to tag_SUVtools_Create (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
samit_createSUV(handles.type, handles.gs); % Run SUVcreate code

%% Uptake correction
% --- Executes on button press in tag_correction_wholebrain.
function tag_correction_wholebrain_Callback(hObject, eventdata, handles)
% hObject    handle to tag_correction_wholebrain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
samit_correction_wholebrain(handles.specie);

%% Mask
% --- Executes on button press in tag_mask_button.
function tag_mask_button_Callback(hObject, eventdata, handles)
% hObject    handle to tag_mask_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
samit_mask(handles.specie); % Apply whole brain mask

%% Normalise multiple images
% --- Executes on button press in tag_multiNormalise.
function tag_multiNormalise_Callback(hObject, eventdata, handles)
% hObject    handle to tag_multiNormalise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
samit_multiNormalise(handles.specie);

%% Construction & Evaluation of tracer specific templates
% --- Executes on button press in tag_templates_construction.
function tag_templates_construction_Callback(hObject, eventdata, handles)
% hObject    handle to tag_templates_construction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
samit_template_construction(handles.specie);

% --- Executes on button press in tag_templates_accuracy.
function tag_templates_accuracy_Callback(hObject, eventdata, handles)
% hObject    handle to tag_templates_accuracy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
samit_template_accuracy();

%% Analysis
% --- Executes on button press in tag_analysis_VOI.
function tag_analysis_VOI_Callback(hObject, eventdata, handles)
% hObject    handle to tag_analysis_VOI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
samit_VOI(handles.specie);


%% Close SAMIT
% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure

% Display
disp(' ');
disp(['Initializing default parameters: SPM ', handles.modality, '...']);
%disp('SAMIT removed from MATLAB path');
disp(' ');

% Remove pathways
rmpath(fileparts(which('samit'))); % SAMIT
   
% Load default SPM parameters
global defaults;
defaults = spm_get_defaults;
spm('defaults',handles.modality);
spm_jobman('initcfg');
delete(hObject);
