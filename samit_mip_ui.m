function varargout = samit_mip_ui(varargin)
% MIP_GUI MATLAB code for mip_gui.fig
%      MIP_GUI, by itself, creates a new MIP_GUI or raises the existing
%      singleton*.
%
%      H = MIP_GUI returns the handle to a new MIP_GUI or the handle to
%      the existing singleton*.
%
%      MIP_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MIP_GUI.M with the given input arguments.
%
%      MIP_GUI('Property','Value',...) creates a new MIP_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mip_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mip_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mip_gui

% Last Modified by GUIDE v2.5 18-Dec-2017 12:01:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @samit_mip_ui_OpeningFcn, ...
                   'gui_OutputFcn',  @samit_mip_ui_OutputFcn, ...
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


% --- Executes just before mip_gui is made visible.
function samit_mip_ui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mip_gui (see VARARGIN)

% Choose default command line output for mip_gui
handles.output = hObject;

% MIP Variables
handles.preset.mip.margin      = 10;
handles.preset.mip.threshold   = 0.15;
handles.preset.mip.cannyu      = 0.1;
handles.preset.mip.cannyl      = 0.01;
handles.preset.mip.chkAutoEdge = 0;
handles.preset.specie          = [];
handles.preset.atlasname       = [];
handles.preset.details         = [];
handles.preset.mri             = [];
handles.preset.mask            = [];

% Display
set(findall(handles.panelMIP,'-property','Enable'),'Enable','off');
set(findall(handles.panelSave,'-property','Enable'),'Enable','off');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes mip_gui wait for user response (see UIRESUME)
% uiwait(handles.figureMIP_ui);


% --- Outputs from this function are returned to the command line.
function varargout = samit_mip_ui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% ---------------------------------------------------
% ------------------ WORKING IMAGE ------------------
% ---------------------------------------------------

% --- Executes on button press in loadImg_button.
function loadImg_button_Callback(hObject, eventdata, handles)
% hObject    handle to loadImg_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

V = spm_vol(spm_select(1,'image','Select Image to create the MIP...'));

if ~isempty(V)
    set(handles.loadImg_txt,'String',spm_file(V.fname,'filename'));
    set(findall(handles.panelMIP,'-property','Enable'),'Enable','on');
    set(findall(handles.panelSave,'-property','Enable'),'Enable','on');
    set(handles.saveMIP, 'Enable', 'off');
    set(handles.canny_auto,'Value', 0);  
    % Update Handles
    handles.preset.mip.V = V;
    [~, handles.preset.bregma] = samit_orig(V);
    handles = regenerateMIP(handles); % Create MIP
end

guidata(hObject, handles);

% ---------------------------------------------------
% ------------------ WORKING IMAGE ------------------
% ---------------------------------------------------


function margin_value_Callback(hObject, eventdata, handles)
% hObject    handle to margin_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of margin_value as text
%        str2double(get(hObject,'String')) returns contents of margin_value as a double
handles.preset.mip.margin = round(str2double(get(hObject, 'String')));
if(handles.preset.mip.margin < 0), handles.preset.mip.threshold = 1; end
if(handles.preset.mip.margin > 25), handles.preset.mip.threshold = 25; end  
handles = regenerateMIP(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function margin_value_CreateFcn(hObject, eventdata, handles)
% hObject    handle to margin_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function margin_slider_Callback(hObject, eventdata, handles)
% hObject    handle to margin_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.preset.mip.margin = round(get(hObject, 'Value'));
set(handles.margin_value, 'String', handles.preset.mip.margin);
handles = regenerateMIP(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function margin_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to margin_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% -----------------------------------------------
% ------------------ THRESHOLD ------------------
% -----------------------------------------------

% --- Executes during object creation, after setting all properties.
function threshold_value_CreateFcn(hObject, eventdata, handles)
% hObject    handle to threshold_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function threshold_value_Callback(hObject, eventdata, handles)
% hObject    handle to threshold_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of threshold_value as text
%        str2double(get(hObject,'String')) returns contents of threshold_value as a double
handles.preset.mip.threshold = roundn(str2double(get(hObject, 'String')),-2);
if(handles.preset.mip.threshold < 0), handles.preset.mip.threshold = 0; end
if(handles.preset.mip.threshold > 1), handles.preset.mip.threshold = 1; end  
handles = regenerateMIP(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function threshold_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to threshold_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on slider movement.
function threshold_slider_Callback(hObject, eventdata, handles)
% hObject    handle to threshold_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.preset.mip.threshold = roundn(get(hObject, 'Value'),-2);
set(handles.threshold_value, 'String', handles.preset.mip.threshold);
handles = regenerateMIP(handles);
guidata(hObject, handles);



% --------------------------------------------
% ------------------ CANNYU ------------------
% --------------------------------------------

% --- Executes during object creation, after setting all properties.
function cannyu_value_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cannyu_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function cannyu_value_Callback(hObject, eventdata, handles)
% hObject    handle to cannyu_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cannyu_value as text
%        str2double(get(hObject,'String')) returns contents of cannyu_value as a double
handles.preset.mip.cannyu = roundn(str2double(get(hObject, 'String')),-2);

if(handles.preset.mip.cannyu < 0.01), handles.preset.mip.cannyu = 0.01; end
if(handles.preset.mip.cannyu > 0.99), handles.preset.mip.cannyu = 0.99; end
if handles.preset.mip.cannyu <= handles.preset.mip.cannyl
    handles.preset.mip.cannyl = handles.preset.mip.cannyu - 0.01;
    set(handles.cannyl_value, 'String', handles.preset.mip.cannyl);
    set(handles.cannyl_slider, 'Value', handles.preset.mip.cannyl);
end     
    
set(handles.cannyu_slider, 'Value', handles.preset.mip.cannyu);
handles = regenerateMIP(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function cannyu_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cannyu_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on slider movement.
function cannyu_slider_Callback(hObject, eventdata, handles)
% hObject    handle to cannyu_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.preset.mip.cannyu = roundn(get(hObject, 'Value'),-2);

if(handles.preset.mip.cannyu < 0.01), handles.preset.mip.cannyu = 0.01; end
if(handles.preset.mip.cannyu > 0.99), handles.preset.mip.cannyu = 0.99; end
if handles.preset.mip.cannyu <= handles.preset.mip.cannyl
    handles.preset.mip.cannyl = handles.preset.mip.cannyu - 0.01;
    set(handles.cannyl_value, 'String', handles.preset.mip.cannyl);
    set(handles.cannyl_slider, 'Value', handles.preset.mip.cannyl);
end    

set(handles.cannyu_value, 'String', handles.preset.mip.cannyu);
handles = regenerateMIP(handles);
guidata(hObject, handles);


% --------------------------------------------
% ------------------ CANNYL ------------------
% --------------------------------------------

% --- Executes during object creation, after setting all properties.
function cannyl_value_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cannyl_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function cannyl_value_Callback(hObject, eventdata, handles)
% hObject    handle to cannyl_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cannyl_value as text
%        str2double(get(hObject,'String')) returns contents of cannyl_value as a double
handles.preset.mip.cannyl = roundn(str2double(get(hObject, 'String')),-2);

if(handles.preset.mip.cannyl < 0), handles.preset.mip.cannyl = 0; end
if(handles.preset.mip.cannyl > 0.98), handles.preset.mip.cannyl = 0.98; end
if handles.preset.mip.cannyl >= handles.preset.mip.cannyu
    handles.preset.mip.cannyu = handles.preset.mip.cannyl + 0.01;
    set(handles.cannyu_value, 'String', handles.preset.mip.cannyu);
    set(handles.cannyu_slider, 'Value', handles.preset.mip.cannyu);
end

set(handles.cannyl_slider, 'Value', handles.preset.mip.cannyl);
handles = regenerateMIP(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function cannyl_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cannyl_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on slider movement.
function cannyl_slider_Callback(hObject, eventdata, handles)
% hObject    handle to cannyl_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.preset.mip.cannyl = roundn(get(hObject, 'Value'),-2);

if(handles.preset.mip.cannyl < 0), handles.preset.mip.cannyl = 0; end
if(handles.preset.mip.cannyl > 0.98), handles.preset.mip.cannyl = 0.98; end
if handles.preset.mip.cannyl >= handles.preset.mip.cannyu
    handles.preset.mip.cannyu = handles.preset.mip.cannyl + 0.01;
    set(handles.cannyu_value, 'String', handles.preset.mip.cannyu);
    set(handles.cannyu_slider, 'Value', handles.preset.mip.cannyu);
end


set(handles.cannyl_value, 'String', handles.preset.mip.cannyl);
handles = regenerateMIP(handles);
guidata(hObject, handles);


% ------------------------------------------------
% ------------------ CANNY AUTO ------------------
% ------------------------------------------------

% --- Executes on button press in canny_auto.
function canny_auto_Callback(hObject, eventdata, handles)
% hObject    handle to canny_auto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of canny_auto
handles.chkAutoEdge = get(hObject, 'Value');
if handles.chkAutoEdge == true
    set(handles.cannyu_value, 'Enable', 'off');
    set(handles.cannyu_slider, 'Enable', 'off');
    set(handles.cannyl_value, 'Enable', 'off');
    set(handles.cannyl_slider, 'Enable', 'off');
else
    set(handles.cannyu_value, 'Enable', 'on');
    set(handles.cannyu_slider, 'Enable', 'on');
    set(handles.cannyl_value, 'Enable', 'on');
    set(handles.cannyl_slider, 'Enable', 'on');
end
handles = regenerateMIP(handles);
guidata(hObject, handles);

%
% SAVE MIP
%

function atlas_specie_Callback(hObject, eventdata, handles)
% hObject    handle to atlas_specie (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of atlas_specie as text
%        str2double(get(hObject,'String')) returns contents of atlas_specie as a double
Txt = get(hObject, 'String');
Txt = strClean(Txt);
set(hObject, 'String', Txt);
handles.preset.specie = Txt;
handles = saveMIPactive(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function atlas_specie_CreateFcn(hObject, eventdata, handles)
% hObject    handle to atlas_specie (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function atlas_name_Callback(hObject, eventdata, handles)
% hObject    handle to atlas_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of atlas_name as text
%        str2double(get(hObject,'String')) returns contents of atlas_name as a double
Txt = get(hObject, 'String');
Txt = strClean(Txt);
set(hObject, 'String', Txt);
handles.preset.atlasname = Txt;
handles = saveMIPactive(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function atlas_name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to atlas_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.




function atlas_details_Callback(hObject, eventdata, handles)
% hObject    handle to atlas_details (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of atlas_details as text
%        str2double(get(hObject,'String')) returns contents of atlas_details as a double
Txt = get(hObject, 'String');
handles.preset.details = Txt;
handles = saveMIPactive(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function atlas_details_CreateFcn(hObject, eventdata, handles)
% hObject    handle to atlas_details (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.


% --- Executes on button press in atlas_mri_button.
function atlas_mri_button_Callback(hObject, eventdata, handles)
% hObject    handle to atlas_mri_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mri = spm_select(1,'image','Select the Brain MRI image');
mri = mri(1:end-2);   % Remove the frame infor (check for alternative)
if ~isempty(mri)
    handles.preset.mri = mri;
    set(handles.atlas_mri_file,'String',spm_file(mri,'filename'));
end
handles = saveMIPactive(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function atlas_mri_button_CreateFcn(hObject, eventdata, handles)
% hObject    handle to atlas_mri_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in atlas_mask_button.
function atlas_mask_button_Callback(hObject, eventdata, handles)
% hObject    handle to atlas_mask_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mask = spm_select(1,'image','Select the Brain Mask image');
mask = mask(1:end-2);   % Remove the frame info (check for alternative)
if ~isempty(mask)
    handles.preset.mask = mask;
    set(handles.atlas_mask_file,'String',spm_file(mask,'filename'));
end
handles = saveMIPactive(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function atlas_mask_button_CreateFcn(hObject, eventdata, handles)
% hObject    handle to atlas_mask_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function atlas_mri_file_CreateFcn(hObject, eventdata, handles)
% hObject    handle to atlas_mri_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function atlas_mask_file_CreateFcn(hObject, eventdata, handles)
% hObject    handle to atlas_mask_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in saveMIP.
function saveMIP_Callback(hObject, eventdata, handles)
% hObject    handle to saveMIP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.preset = samit_mip(handles.preset,'Save');
msgbox('The new atlas was created successfully and added to SAMIT.', 'SAMIT');
close(handles.figureMIP_ui);
%guidata(hObject, handles);



% --
% -- Extra functions
% --
function handles = regenerateMIP(handles)
% Regenerates the MIP after loading the image or modification of one of the
% parameters
handles.preset = samit_mip(handles.preset,'Create');
axes(handles.figureMIP);
imshow(rot90(handles.preset.mip.mip96));
%title('Preview of the MIP template');

function Txt = strClean(Txt)
% Remove / Replace whitespaces
Txt = strtrim(Txt);          % Remove leading and trailing white space
Txt = strrep(Txt, ' ', '_'); % Replace white space by '_' character
Txt = strrep(Txt, ',', '_'); % Replace comma by '_' character

function handles = saveMIPactive(handles)
if strcmp(get(handles.saveMIP, 'Enable'),'off') && ...
        ~isempty(handles.preset.specie) && ...
        ~isempty(handles.preset.atlasname) && ...
        ~isempty(handles.preset.details) && ...
        ~isempty(handles.preset.mri) && ...
        ~isempty(handles.preset.mask)
    set(handles.saveMIP, 'Enable', 'on');
end


% --- Executes when user attempts to close figureMIP_ui.
function figureMIP_ui_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figureMIP_ui (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);
samit;
