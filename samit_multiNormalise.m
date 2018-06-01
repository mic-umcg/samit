function samit_multiNormalise(regtype, atlas, files, template, d)
%   Perform spatial normalisation to  multiple PET/SPECT brain images to the
%   reference template
%   FORMAT samit_multiNormalise(files, template, atlas, regtype, d)
%       regtype   - Regularisation type (spm_affreg.m)
%                   'none'  - no regularisation (default)
%                   'rigid' - almost rigid body
%                   'subj'  - inter-subject registration
%       atlas  - Small animal atlas (see 'samit_defaults')
%       files     - Images to be registered
%       template  - Reference image (template)
%       d         - Display (default: true)

%   Version: 15.04 (29 April 2015)
%   Author:  David Vállez Garcia
%   Email:   samit@umcg.nl

%   Tested with SPM8 & SPM12
%   Version 15.04: adjusted to new samit_defaults

%% Input

% Working files
if ~exist('files','var')
    files = spm_select(Inf,'image','Select images...');
    if isempty(files)
        display('Operation cancelled: No files selected.');
        return
    end
    files = deblank(files);
end

[nFiles, ~] = size(files);

% Reference template
if ~exist('template','var')
    template = spm_select(1, 'image', 'Select template image...');
    if isempty(template)
        display('Operation cancelled: No template selected.');
        return
    end
    template = deblank(template);
end

template_vol = spm_vol(template);

% Atlas
if ~exist('atlas','var')	% If atlas is not specified, 'rat' will be used
    samit_def = samit_defaults; % Load default values
else
    samit_def = samit_defaults(atlas);
end

% Regularisation type
if ~exist('regtype','var')
    regtype = 'rigid';
end    

% Display
if ~exist('d','var')
    d = true;
end

if d ~= false
    display(' ');
    display('SAMIT: Normalise multiple PET/SPECT brain images to the reference image');
    display('-----------------------------------------------------------------------');
end

%% Flags for normalise
[bb, vx] = spm_get_bbox(template);
bb(2,:) = bb(2,:) + abs(vx); % Correction for number of slides
samit_def.normalise.write.bb  = bb; % Use Bounding box of the template
samit_def.normalise.estimate.regtype = regtype;


%% Waitbar
%multiWaitbar('CloseAll');
w1 = 'Running normalisation to multiple images';
multiWaitbar(w1);

%% Normalise images
for i = 1:nFiles
    multiWaitbar(w1, 'Value', i/nFiles);
    VF = spm_vol(files(i,:));   % Image to be normalise
    prm = spm_normalise(template_vol,VF,'','','',samit_def.normalise.estimate);
    spm_write_sn(VF,prm,samit_def.normalise.write);
% Save .mat file
    matname   = spm_file(VF.fname, 'suffix', '_sn', 'ext','.mat');
    save(matname, 'prm', spm_get_defaults('mat.format'));
end

multiWaitbar(w1, 'Close');

end

