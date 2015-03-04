function samit_template_construction(specie)
%   Construction of tracer-specific PET/SPECT templates for rat / mouse
%   brain. Origin is expected to be at the center of the image
%   FORMAT samit_template_construction(specie)
%       specie  - Animal specie
%                'rat'  (Default)
%                'mouse'

%   Version: 14.12.04 (04 December 2014)
%   Author:  David Vállez Garcia
%   Email:   dvallezgarcia=gmail*com
%   Real_email = regexprep(Email,{'=','*'},{'@','.'})

%   Tested with SPM8 & SPM12
%   Version 14.10:
%       - All flags are moved to samit_defaults
%       - Not neccesary anymore to scale the rat brain x10
%       - Origin of the input files is located at the center of the image
%       before normalisation
%   Version 14.11:
%       - Tested with mice data
%       - Bounding box calculated automatically (spm_get_bbox)
%   Version 14.12:
%       - Adjusted the smoothness

%% Display
display(' ');
display('SAMIT: Construction of PET/SPECT brain template');
display('-----------------------------------------------');

warning('off','all');   % Remove warning notifications due to left-right flip of the image


%% Check input
if ~exist('specie','var');
    specie = 'rat';
end
if ~ismember(specie,{'rat', 'mouse'})
    display('Operation cancelled: Wrong input in the animal specie');
    return
end

%% Load default values from samit_defaults
samit_def = samit_defaults(specie);

%% Name of the template
[template, template_path] = uiputfile('*.nii', 'Name of the new template...');
 
% Error check (no file created)
 if isequal(template,0) || isequal(template_path,0)
     display('Operation cancelled: Output file was not specified.');
     return
 end
 [~, template] = fileparts(template);   % Avoid the use of the extension as part of the name
 cd(template_path);

%% Images to be used for the construction of the template
files = spm_select(Inf,'image','Images will be normilised to the first one in the list');
if isempty(files)
    display('Operation cancelled: No files selected.');
    return
end
nfiles = size(files,1); % Number of images selected

%% Bounding box
samit_def.normalise.write.bb = spm_get_bbox(files(1,:));

%% Adjust of reference smoothing
samit_def.normalise.estimate.smoref = 0.8;

%% Waitbar
w1 = ['Construction of the template: ',template,'.nii'];
w2 = 'Normalising to the first image';
w3 = 'Obtaining the average image';
w4 = 'Co-registration to the MRI template';
multiWaitbar('CloseAll');

%% Step 1: Normalise to the first
multiWaitbar(w1, 'Value', 1/6); % Waitbar

samit_origin('center',specie,files,false);      % Origin is located in the center

VG = spm_vol(files(1,:));                       % Reference image

for i = 2:nfiles
    
    multiWaitbar(w2, 'Value', i/nfiles);        % Waitbar
    
    VF = spm_vol(files(i,:));                   % Image to estimate
    prm = spm_normalise(VG,VF,'','','',samit_def.normalise.estimate);
    spm_write_sn(VF,prm,samit_def.normalise.write);
end
% List of new created files
files_normalise = char(files(1,:), spm_file(files(2:end,:),'prefix',samit_def.normalise.write.prefix));

%% Step 2: Mean image
multiWaitbar(w1, 'Value', 2/6);         % Waitbar
multiWaitbar(w3, 'Value', 1/4);         
Vi = spm_vol(files_normalise);          % Images normalized to the first
Vo = 'tmp_average.nii';                 % Output: temporary file

% Calculation of the mean
if isequal(spm('Ver'),'SPM12')
    spm_imcalc(Vi,Vo,'mean(X)',{1});        
else
    spm_imcalc_ui(files_normalise,Vo,'mean(X)',{1});
end

%% Step 3: Creates a copy, with flipped left-right
multiWaitbar(w1, 'Value', 3/6);     % Waitbar
multiWaitbar(w3, 'Value', 2/4);     % Waitbar
Vf = 'tmp_flip.nii';                % Output: temporary file
M = diag([-1 1 1 1]);               % Flip matrix

Vflip = spm_vol(Vo);                
Vflip.fname = Vf;
Vflip.mat = M * Vflip.mat;
Vflip.private.mat = Vflip.mat;
%Vflip.private.mat0 = Vflip.mat;

dat = spm_read_vols(spm_vol(Vo));
spm_write_vol(Vflip,dat);           % Writes output

%% Step 4: Normalise flipped image to the original average
multiWaitbar(w1, 'Value', 4/6); % Waitbar
multiWaitbar(w3, 'Value', 3/4);  % Waitbar

prm = spm_normalise(spm_vol(Vo),spm_vol(Vf),'','','',samit_def.normalise.estimate);
spm_write_sn(Vf,prm,samit_def.normalise.write); % Output image: 'wtmp_flip.nii'

%% Step 5: Creates a symmetrical template
multiWaitbar(w1, 'Value', 5/6); % Waitbar
multiWaitbar(w3, 'Value', 1);   % Waitbar

% Check SPM version
if isequal(spm('Ver'),'SPM12')
    spm_imcalc({Vo, 'wtmp_flip.nii'},'tmp_symmetrical.nii','mean(X)',{1});
else
    spm_imcalc_ui({Vo, 'wtmp_flip.nii'},'tmp_symmetrical.nii','mean(X)',{1});
end


%% Step 6: Co-registration of symmetrical image to the MRI template
multiWaitbar(w4);               % Waitbar

% Origin is located at bregma
samit_origin('bregma',specie,fullfile(template_path,'tmp_symmetrical.nii'),false);
samit_origin('bregma',specie,files_normalise,false);
    
% Co-registration to MRI template 
x = spm_coreg(spm_vol(samit_def.mri),spm_vol('tmp_symmetrical.nii'),samit_def.coreg);
X = spm_matrix(x);
T = spm_get_space('tmp_symmetrical.nii');
T = X \ T;
spm_get_space('tmp_symmetrical.nii', T);
spm_reslice({samit_def.mri,'tmp_symmetrical.nii'},samit_def.coreg.write);

% Same co-registration matrix is applied to the images used for the construction of the
% template
multiWaitbar(w4,'Value',1/2);             % Waitbar
for i = 1:size(files_normalise,1)
    T0 = spm_get_space(files_normalise(i,:));
    T = X \ T0;
    spm_get_space(files_normalise(i,:), T);
    spm_reslice({samit_def.mri,files_normalise(i,:)},samit_def.coreg.write);
    
    spm_get_space(files_normalise(i,:), T0); % Revert changes   
    
end
multiWaitbar(w1,'Value',1);               % Waitbar
multiWaitbar(w4,'Value',1);               

%% Final steps
% Rename & move files
movefile('tmp_symmetrical.nii', [template,'_Original_Size.nii']);
movefile('rtmp_symmetrical.nii', [template,'_MRI_Size.nii']);

for i = 1:size(files_normalise,1)   
    if ~isequal(spm_file(files_normalise(i,:),'fpath'),pwd);
        movefile(spm_file(files_normalise(i,:),'prefix',samit_def.coreg.write.prefix,'number',''));
    end
    if i == 1
        samit_origin('center',specie,files_normalise(i,:),false);
    else
        delete(spm_file(files_normalise(i,:),'number',''));
    end
end

% Store co-registration matrix
save([template,'_coreg.mat'],'X');

%% Show results
spm_check_registration(char(samit_def.mri, [template,'_MRI_Size.nii']));

%% Clear temporary files
delete('tmp_*', 'wtmp_*');

%% Close multiWaitbar
multiWaitbar('CloseAll');
end
