function samit_template_accuracy(template,files,suffix,d)
%   Evaluation random misalignments of PET / SPECT templates
%   FORMAT samit_template_accuracy(specie,template,files,suffix,d)
%       template    - Reference template to evaluate
%       files       - Images used for the construction of the template
%       suffix      - Suffix added to the name of the template to store
%                      results
%       d           - Display (default: true)

%   Version: 14.12.04 (04 December 2014)
%   Author:  David V?llez Garcia
%   Email:   dvallezgarcia=gmail*com
%   Real_email = regexprep(Email,{'=','*'},{'@','.'})

%   Tested with SPM8 & SPM12
%   Version 14.12.04: Code was adjusted for SPM12 & to small animal scale
%   (not needed anymore to scale x10 the images to resemble human size)

%% Input

% Reference template
if ~exist('template','var')
    template = spm_select(1, 'image', 'Select template image...');
    if isempty(template)
        display('Operation cancelled: No template selected.');
        return
    end
end

template_vol = spm_vol(template);

% Working files
if ~exist('files','var')
    files = spm_select(Inf,'image','Select images...');
    if isempty(files)
        display('Operation cancelled: No files selected.');
        return
    end
end

[nFiles, ~] = size(files);

% Suffix
if ~exist('suffix','var')
    suffix = ' - accuracy';
end

% Name of the file to be saved
file_save = [spm_file(template,'basename'), suffix];

% Display
if ~exist('d','var')
    d = true;
end

if d ~= false
    display(' ');
    display('SAMIT: Test template''s accuracy');
    display('--------------------------------');
end

%% Init flags & variables
working_pth = pwd;  % Initial working directory
prefix = 'affreg_';


flagsAff = struct('sep',2,'regtype','subj','WG',[],'WF',[],'globnorm',1,'debug',0);
flagsWrite = struct('interp',1,'mask',0,'mean',0,'which',1,'wrap',[0 0 0]','prefix',prefix);

nRep = 10;              % Number repetitions (default = 10)
%sm = [1.2 1.2 1.2];     % FWHM of Gaussian filter width in mm
sm = 1.2;               % FWHM of Gaussian filter width in mm

Mt = zeros(4,4,nRep);   % Initilize Translation Matrix
Mr = zeros(4,4,nRep);   % Initilize Rotation Matrix
Ms = zeros(4,4,nRep);   % Initilize Scalation Matrix
Ma = zeros(4,4,nRep);   % Initilize 'All' Matrix (Tranlation, Rotation & Scale)

At = zeros(4,4,nRep);   % Initialize Affine Translation Matrix
Ar = zeros(4,4,nRep);   % Initialize Affine Rotation Matrix
As = zeros(4,4,nRep);   % Initialize Affine Scalation Matrix
Aa = zeros(4,4,nRep);   % Initialize Affine 'All' Matrix

T = struct();           % Structure to store the results

%% Waitbar
%multiWaitbar('CloseAll');
w1 = 'Running Accuracy Test:';
multiWaitbar(w1);

%% Init calculations
for f = 1:nFiles
    
    multiWaitbar(w1, 'Value', f/nFiles);
    
    [file_dir, file_name, ext]  = spm_fileparts(files(f,:));
    
    cd(file_dir);
    
    % Default values of file
    file = strcat(file_name,ext);
    file_vol = spm_vol(file);
    file_m = spm_get_space(file);
    
    
    %% Affine Registration
    % ===================
    
    % Apply Translation
    
    for i = 1:nRep
        
        multiWaitbar('Translation:', 'Value', i/nRep);
        
        M = M_translation();                            % Calculates Translation Matrix
        
        F = file_m;
        F = M * F;                                      % Apply translation
        
        spm_get_space(file, F);
        spm_reslice({template,file},flagsWrite);        % Create temporal file
        
        spm_get_space(file, file_m);                    % Set file to starting point
        
        vol = spm_vol(strcat(prefix,file));
        vol1 = spm_smoothto8bit(vol,sm);

%        file_s = spm_file(vol.fname,'prefix','s');      % Temp smooth file
%        spm_smooth(vol,file_s,sm);
       
%       [Aff, ~] = spm_affreg(template_vol,vol,flagsAff);               % Matrix with Affine values
        [Aff, ~] = spm_affreg(template_vol,vol1,flagsAff);              % Matrix with Affine values (Smooth & Flags)
%       [Aff, ~] = spm_affreg(template_vol,spm_vol(file_s));            % Matrix with Affine values
%       [Aff, ~] = spm_affreg(template_vol,spm_vol(file_s),flagsAff);   % Matrix with Affine values
        
        delete(strcat(prefix,file))                     % Delete temporal file
%       delete(file_s);
        
        Mt(:,:,i) = M;                                  % Store Matrices
        At(:,:,i) = Aff;
        
    end
    
    % Apply Rotation
    
    for i = 1:nRep
        
        multiWaitbar('Rotation:', 'Value', i/nRep);
        
        M = M_rotate();                               % Calculates Rotation Matrix
        
        F = file_m;
        F = M * F;                                      % Apply rotation
        
        spm_get_space(file, F);
        spm_reslice({template,file},flagsWrite);             % Create temporal file
        
        spm_get_space(file, file_m);                    % Set file to starting point
        
        vol = spm_vol(strcat(prefix,file));
        vol1 = spm_smoothto8bit(vol,sm);

%        file_s = spm_file(vol.fname,'prefix','s');      % Temp smooth file
%        spm_smooth(vol,file_s,sm);
       
%       [Aff, ~] = spm_affreg(template_vol,vol,flagsAff);               % Matrix with Affine values
        [Aff, ~] = spm_affreg(template_vol,vol1,flagsAff);              % Matrix with Affine values (Smooth & Flags)
%       [Aff, ~] = spm_affreg(template_vol,spm_vol(file_s));            % Matrix with Affine values
%       [Aff, ~] = spm_affreg(template_vol,spm_vol(file_s),flagsAff);   % Matrix with Affine values
        
        delete(strcat(prefix,file))                     % Delete temporal file
%       delete(file_s);
        
        Mr(:,:,i) = M;                                  % Store Matrices
        Ar(:,:,i) = Aff;
        
    end
    
    
    % Apply Scale
    
    for i = 1:nRep
        
        multiWaitbar('Scale:', 'Value', i/nRep);
        
        M = M_scale();                                  % Scale Matrix
        
        F = file_m;                                     % Apply scale
        F = M * F;
        
        spm_get_space(file, F);
        spm_reslice({template,file},flagsWrite);             % Create temporal file
        
        spm_get_space(file, file_m);                    % Set file to starting point
        
        vol = spm_vol(strcat(prefix,file));
        vol1 = spm_smoothto8bit(vol,sm);

%        file_s = spm_file(vol.fname,'prefix','s');      % Temp smooth file
%        spm_smooth(vol,file_s,sm);
       
%       [Aff, ~] = spm_affreg(template_vol,vol,flagsAff);               % Matrix with Affine values
        [Aff, ~] = spm_affreg(template_vol,vol1,flagsAff);              % Matrix with Affine values (Smooth & Flags)
%       [Aff, ~] = spm_affreg(template_vol,spm_vol(file_s));            % Matrix with Affine values
%       [Aff, ~] = spm_affreg(template_vol,spm_vol(file_s),flagsAff);   % Matrix with Affine values
        
        delete(strcat(prefix,file))                     % Delete temporal file
%       delete(file_s);
        
        Ms(:,:,i) = M;                                  % Store Matrices
        As(:,:,i) = Aff;
        
    end
    
    % Apply all
    
    for i = 1:nRep
        
        multiWaitbar('Combination:', 'Value', i/nRep);
        
        M = M_all();
        
        F = file_m;
        F = M * F;                                     % Apply Rotation & Scale
        
        spm_get_space(file, F);
        spm_reslice({template,file},flagsWrite);
        
        spm_get_space(file, file_m);                    % Set file to starting point
        
        vol = spm_vol(strcat(prefix,file));
        vol1 = spm_smoothto8bit(vol,sm);

%        file_s = spm_file(vol.fname,'prefix','s');      % Temp smooth file
%        spm_smooth(vol,file_s,sm);
       
%       [Aff, ~] = spm_affreg(template_vol,vol,flagsAff);               % Matrix with Affine values
        [Aff, ~] = spm_affreg(template_vol,vol1,flagsAff);              % Matrix with Affine values (Smooth & Flags)
%       [Aff, ~] = spm_affreg(template_vol,spm_vol(file_s));            % Matrix with Affine values
%       [Aff, ~] = spm_affreg(template_vol,spm_vol(file_s),flagsAff);   % Matrix with Affine values
        
        delete(strcat(prefix,file))                     % Delete temporal file
%       delete(file_s);
        
        Ma(:,:,i) = M;                                  % Store Matrices
        Aa(:,:,i) = Aff;
        
    end
    
    multiWaitbar('Translation:', 'Close');
    multiWaitbar('Rotation:', 'Close');
    multiWaitbar('Scale:', 'Close');
    multiWaitbar('Combination:', 'Close');
    
    %% Compute distance
    
    tError = zeros(1,nRep); % Initialize translation error variable
    rError = zeros(1,nRep); % Initialize rotation errorvariable
    sError = zeros(1,nRep); % Initialize scalation error variable
    aError = zeros(1,nRep); % Initialize 'all' error variable
    
    F = file_m;             % File Matrix
    vol = file_vol;         % File Vol
    
    %% Compute Error
        
    % Compute Error: Translation
    
    for r = 1:nRep
        multiWaitbar('Computing Error: Translation', 'Value', r/nRep);
        for i = 1:vol.dim(1)
            for j = 1:vol.dim(2)
                for k = 1:vol.dim(3)
                    [x,y,z] = coords(F,(i-.5),(j-.5),(k-.5));                           % Original coords
                    [newx,newy,newz] = coords(Mt(:,:,r)*At(:,:,r),x,y,z);               % New coords
                    tError(r) = tError(r) + sqrt((x-newx)^2+ (y-newy)^2 + (z-newz)^2);  % Accumulated error
                end
            end
        end
    end
    tError = tError ./ (vol.dim(1)*vol.dim(2)*vol.dim(3));
    multiWaitbar('Computing Error: Translation', 'Close');
    
    % Compute Error: Rotation
    for r = 1:nRep
        multiWaitbar('Computing Error: Rotation', 'Value', r/nRep);
        for i = 1:vol.dim(1)
            for j = 1:vol.dim(2)
                for k = 1:vol.dim(3)
                    [x,y,z] = coords(F,(i-.5),(j-.5),(k-.5));                           % Original coords
                    [newx,newy,newz] = coords(Mr(:,:,r)*Ar(:,:,r),x,y,z);               % New coords
                    rError(r) = rError(r) + sqrt((x-newx)^2+ (y-newy)^2 + (z-newz)^2);  % Accumulated error
                end
            end
        end
    end
    rError = rError ./ (vol.dim(1)*vol.dim(2)*vol.dim(3));
    multiWaitbar('Computing Error: Rotation', 'Close');
    
    % Compute Error: Scale
    
    for r = 1:nRep
        multiWaitbar('Computing Error: Scale', 'Value', r/nRep);
        for i = 1:vol.dim(1)
            for j = 1:vol.dim(2)
                for k = 1:vol.dim(3)
                    [x,y,z] = coords(F,(i-.5),(j-.5),(k-.5));                           % Original coords
                    [newx,newy,newz] = coords(Ms(:,:,r)*As(:,:,r),x,y,z);               % New coords
                    sError(r) = sError(r) + sqrt((x-newx)^2+ (y-newy)^2 + (z-newz)^2);  % Accumulated error
                end
            end
        end
    end
    sError = sError ./ (vol.dim(1)*vol.dim(2)*vol.dim(3));
    multiWaitbar('Computing Error: Scale', 'Close');
    
    % Compute Error: All
    for r = 1:nRep
        multiWaitbar('Computing Error: Combination', 'Value', r/nRep);
        for i = 1:vol.dim(1)
            for j = 1:vol.dim(2)
                for k = 1:vol.dim(3)
                    [x,y,z] = coords(F,(i-.5),(j-.5),(k-.5));                           % Original coords
                    [newx,newy,newz] = coords(Ma(:,:,r)*Aa(:,:,r),x,y,z);               % New coords
                    aError(r) = aError(r) + sqrt((x-newx)^2+ (y-newy)^2 + (z-newz)^2);  % Accumulated error
                end
            end
        end
    end
    aError = aError ./ (vol.dim(1)*vol.dim(2)*vol.dim(3));
    multiWaitbar('Computing Error: Combination', 'Close');
    
    %% Store variables
%     T.(matlab.lang.makeValidName(['file',int2str(f)])).fname = strcat(file_name,ext);
%     T.(matlab.lang.makeValidName(['file',int2str(f)])).Mt = Mt;
%     T.(matlab.lang.makeValidName(['file',int2str(f)])).At = At;
%     T.(matlab.lang.makeValidName(['file',int2str(f)])).tError = tError;
%     T.(matlab.lang.makeValidName(['file',int2str(f)])).Mr = Mr;
%     T.(matlab.lang.makeValidName(['file',int2str(f)])).Ar = Ar;
%     T.(matlab.lang.makeValidName(['file',int2str(f)])).rError = rError;
%     T.(matlab.lang.makeValidName(['file',int2str(f)])).Ms = Ms;
%     T.(matlab.lang.makeValidName(['file',int2str(f)])).As = As;
%     T.(matlab.lang.makeValidName(['file',int2str(f)])).sError = sError;
%     T.(matlab.lang.makeValidName(['file',int2str(f)])).Ma = Ma;
%     T.(matlab.lang.makeValidName(['file',int2str(f)])).Aa = Aa;
%     T.(matlab.lang.makeValidName(['file',int2str(f)])).aError = aError;
    
    T.(['file',int2str(f)]).fname = strcat(file_name,ext);
    T.(['file',int2str(f)]).Mt = Mt;
    T.(['file',int2str(f)]).At = At;
    T.(['file',int2str(f)]).tError = tError;
    T.(['file',int2str(f)]).Mr = Mr;
    T.(['file',int2str(f)]).Ar = Ar;
    T.(['file',int2str(f)]).rError = rError;
    T.(['file',int2str(f)]).Ms = Ms;
    T.(['file',int2str(f)]).As = As;
    T.(['file',int2str(f)]).sError = sError;
    T.(['file',int2str(f)]).Ma = Ma;
    T.(['file',int2str(f)]).Aa = Aa;
    T.(['file',int2str(f)]).aError = aError;
    
    results.translate.values(f,:) = tError;
    results.rotate.values(f,:) = rError;
    results.scale.values(f,:) = sError;
    results.all.values(f,:) = aError;
    
end

%% Calculate Values
results.translate.mean = mean(results.translate.values(:));
results.translate.std = std(results.translate.values(:));
results.translate.min = min(results.translate.values(:));
results.translate.max = max(results.translate.values(:));

results.rotate.mean = mean(results.rotate.values(:));
results.rotate.std = std(results.rotate.values(:));
results.rotate.min = min(results.rotate.values(:));
results.rotate.max = max(results.rotate.values(:));

results.scale.mean = mean(results.scale.values(:));
results.scale.std = std(results.scale.values(:));
results.scale.min = min(results.scale.values(:));
results.scale.max = max(results.scale.values(:));

results.all.mean = mean(results.all.values(:));
results.all.std = std(results.all.values(:));
results.all.min = min(results.all.values(:));
results.all.max = max(results.all.values(:));

%% Save results

cd(working_pth);    % Returns to working directory

% Save .mat file
save([file_save,'.mat'],'T', 'results');

% Write table with result to file
fid = fopen([file_save, '.txt'], 'w');

fprintf(fid, '%s\n', file_save); % Title

fprintf(fid, '\t%s\t', 'Mean');  % Header
fprintf(fid, '%s\t', 'Std');
fprintf(fid, '%s\n', 'Range');

fprintf(fid, '%s\t', 'Translate');
fprintf(fid, '%.3f\t', results.translate.mean);
fprintf(fid, '%.3f\t', results.translate.std);
fprintf(fid, '%.3f - %.3f\n', results.translate.min, results.translate.max);

fprintf(fid, '%s\t', 'Rotate');
fprintf(fid, '%.3f\t', results.rotate.mean);
fprintf(fid, '%.3f\t', results.rotate.std);
fprintf(fid, '%.3f - %.3f\n', results.rotate.min, results.rotate.max);

fprintf(fid, '%s\t', 'Scale');
fprintf(fid, '%.3f\t', results.scale.mean);
fprintf(fid, '%.3f\t', results.scale.std);
fprintf(fid, '%.3f - %.3f\n', results.scale.min, results.scale.max);

fprintf(fid, '%s\t', 'Combined');
fprintf(fid, '%.3f\t', results.all.mean);
fprintf(fid, '%.3f\t', results.all.std);
fprintf(fid, '%.3f - %.3f\n', results.all.min, results.all.max);

fclose(fid);

% Close Waitbar
multiWaitbar(w1, 'Close');

%% Functions
    function M = M_translation
        % Translation (-0.5 to + 0.5 mm)
        % ==========================
        rng('shuffle','twister');           % seeds random number generator based on the current time
        
        P1 = randi([-5 5])/10;              % Translate
        P2 = randi([-5 5])/10;
        P3 = randi([-5 5])/10;
        
        M = spm_matrix([P1 P2 P3 0 0 0 1 1 1 0 0 0]);
        
    end

    function M = M_rotate
        % Rotation x degrees (-20 to +20)
        % ==============================
        rng('shuffle','twister');           % seeds random number generator based on the current time
                
        P4 = randi([-20 20]) * pi / 180;    % Rotate
        P5 = randi([-20 20]) * pi / 180;
        P6 = randi([-20 20]) * pi / 180;
        
        % Combined Rotation Matrix
        M = spm_matrix([0 0 0 P4 P5 P6 1 1 1 0 0 0]);
    end

    function M = M_scale
        % Scaling -10% to +10%
        % ===========================
        rng('shuffle','twister');           % seeds random number generator based on the current time
              
        P7 = 1 + (randi([-10 10]) / 100);
        P8 = 1 + (randi([-10 10]) / 100);
        P9 = 1 + (randi([-10 10]) / 100);
         
        M = spm_matrix([0 0 0 0 0 0 P7 P8 P9 0 0 0 ]);
    end

    function M = M_all
        
        rng('shuffle','twister');           % seeds random number generator based on the current time
               
        P1 = randi([-5 5])/10;              % Translate (-0.5mm to 0.5mm)
        P2 = randi([-5 5])/10;
        P3 = randi([-5 5])/10;
        
        P4 = randi([-10 10]) * pi / 180;    % Rotate (-10 to 10 degrees)
        P5 = randi([-10 10]) * pi / 180;
        P6 = randi([-10 10]) * pi / 180;
        
        P7 = 1 + (randi([-10 10]) / 100);   % Scale (-10% to 10%)
        P8 = 1 + (randi([-10 10]) / 100);
        P9 = 1 + (randi([-10 10]) / 100);
        
        M = spm_matrix([P1 P2 P3 P4 P5 P6 P7 P8 P9 0 0 0]);
    end

    function [y1,y2,y3] = coords(M,x1,x2,x3)
        % Affine transformation of a set of coordinates (from spm_affreg)
        y1 = M(1,1)*x1 + M(1,2)*x2 + M(1,3)*x3 + M(1,4);
        y2 = M(2,1)*x1 + M(2,2)*x2 + M(2,3)*x3 + M(2,4);
        y3 = M(3,1)*x1 + M(3,2)*x2 + M(3,3)*x3 + M(3,4);
    end

end