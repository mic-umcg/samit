function samit_template_construction(atlas)
%   Construction of tracer-specific PET/SPECT templates for small animal
%   brain.
%   FORMAT samit_template_construction(atlas)
%       atlas  - Small animal atlas (see 'samit_defaults')

%   Version: 15.04 (29 April 2015)
%   Author:  David Vállez Garcia
%   Email:   samit@umcg.nl

%   Tested with SPM8 & SPM12
%   Version 14.10
%       - All flags are moved to samit_defaults
%       - Not necessary anymore to scale the rat brain x10
%       - Origin of the input files is located at the center of the image
%       before normalisation
%   Version 14.11
%       - Tested with mice data
%       - Bounding box calculated automatically (spm_get_bbox)
%   Version 14.12
%       - Adjusted the smoothness
%   Version 15.04
%       - Original files are not used anymore
%       - Bounding box adjusted
%       - Adjusted to new samit_defaults


%% Display
display(' ');
display('SAMIT: Construction of PET/SPECT brain template');
display('-----------------------------------------------');

warning('off','all');   % Remove warning notifications due to left-right flip of the image


%% Load default values from samit_defaults
if ~exist('atlas','var')	% If atlas is not specified, 'rat' will be used
    samit_def = samit_defaults; % Load default values
else
    samit_def = samit_defaults(atlas);
end

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
files = spm_file(files, 'number', ''); % Remove "number" from the name
files = deblank(files);
nfiles = size(files,1); % Number of images selected

%% Bounding box
[bb, vx] = spm_get_bbox(files(1,:));
bb(2,:) = bb(2,:) + abs(vx);
samit_def.normalise.write.bb = bb;

%% Adjust of reference smoothing
samit_def.normalise.estimate.smoref = 0.8;

%% Adjust registration type
samit_def.normalise.estimate.regtype  = 'rigid';

%% Waitbar
w1 = ['Construction of the template: ',template,'.nii'];
w2 = 'Normalising to the first image';
w3 = 'Obtaining the average image';
w4 = 'Co-registration to the MRI template';
multiWaitbar('CloseAll');

%% Step 1: Normalise to the first
multiWaitbar(w1, 'Value', 1/6); % Waitbar

% Creates a copy of the first image
copyfile(files(1,:), spm_file(files(1,:), 'prefix', samit_def.normalise.write.prefix));

files_normalise = spm_file(files,'prefix',samit_def.normalise.write.prefix); % List of new files

VG = spm_vol(files_normalise(1,:));             % Reference image

for i = 2:nfiles
    
    multiWaitbar(w2, 'Value', i/nfiles);        % Waitbar
    
    VF = spm_vol(files(i,:));                   % Image to estimate
    prm = spm_normalise(VG,VF,'','','',samit_def.normalise.estimate);
    spm_write_sn(VF,prm,samit_def.normalise.write);
end

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

copyfile(Vo,Vf);                    % Copy of the file
M = spm_get_space(Vf);              % Matrix of the file
M(1,:) = -M(1,:);                   % Flip image
spm_get_space(Vf,M);                % Apply transformation

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
   
% Co-registration to MRI template 
x = spm_coreg(spm_vol(samit_def.mri),spm_vol('tmp_symmetrical.nii'),samit_def.coreg);
X = spm_matrix(x);
T = spm_get_space('tmp_symmetrical.nii');
T = X \ T;
spm_get_space('tmp_symmetrical.nii', T);
spm_reslice(char(samit_def.mri, 'tmp_symmetrical.nii'),samit_def.coreg.write);

% Same co-registration matrix is applied to the images used for the construction of the
% template
multiWaitbar(w4,'Value',1/2);             % Waitbar
for i = 1:size(files_normalise,1)
    T0 = spm_get_space(files_normalise(i,:));
    T = X \ T0;
    spm_get_space(files_normalise(i,:), T);
    spm_reslice(char(samit_def.mri, files_normalise(i,:)),samit_def.coreg.write);    
    
end
multiWaitbar(w1,'Value',1);               % Waitbar
multiWaitbar(w4,'Value',1);               

%% Final steps
% Reslice Template with the original dimensions (size) [Check LR!!]
VI = spm_vol('tmp_symmetrical.nii');
VO = VI;

vox    = sqrt(sum(VI.mat(1:3,1:3).^2));
O = VI.mat \ [0 0 0 1]'; O=O(1:3)'; % Origin coordinates
off = -vox .* O;
VO.mat   = [vox(1) 0      0      off(1)
            0      vox(2) 0      off(2)
            0      0      vox(3) off(3)
            0      0      0      1];
VO = spm_create_vol(VO); % Not sure if needed
for x3 = 1:VO.dim(3)
        M  = inv(spm_matrix([0 0 -x3 0 0 0 1 1 1])*inv(VO.mat)*VI.mat);
        v  = spm_slice_vol(VI,M,VO.dim(1:2),1);
        VO = spm_write_plane(VO,v,x3);
end;


% Rename & move files
movefile('tmp_symmetrical.nii', [template,'_Original_Size.nii']);
movefile('rtmp_symmetrical.nii', [template,'_MRI_Size.nii']);

% Store co-registration matrix
save([template,'_coreg.mat'],'X');

%% Show results
spm_check_registration(char(samit_def.mri, [template,'_MRI_Size.nii']));

%% Clear temporary files
for d = 1:size(files_normalise,1)
    delete(files_normalise(d,:));
end
delete('tmp_average.nii');
delete('tmp_flip.nii');
delete('wtmp_flip.nii');

%% Close multiWaitbar
multiWaitbar('CloseAll');
end
