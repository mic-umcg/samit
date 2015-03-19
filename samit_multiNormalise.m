function samit_multiNormalise(specie, template,files,d)
%   Perform "almost rigid" normalisation to  multiple PET/SPECT rat brain images to the
%   reference template
%   FORMAT samit_multiNormalise(template,files,d)
%       specie      - Animal specie: 'rat'  (Default) / 'mouse'
%       template    - Reference template to evaluate
%       files       - Images used for the construction of the template
%       d           - Display (default: true)

%   Version: 14.11 (11 November 2014)
%   Author:  David Vállez Garcia
%   Email:   samit@umcg.nl

%   Tested with SPM8 & SPM12

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

% Specie
if ~exist('specie','var');	% If specie is not specified, 'rat' will be used
    specie = 'rat';
end

% Display
if ~exist('d','var')
    d = true;
end

if d ~= false
    display(' ');
    display('SAMIT: Normalise multiple PET/SPECT brain images to the reference template');
    display('--------------------------------------------------------------------------');
end

%% Flags
samit_def = samit_defaults(specie);
samit_def.normalise.write.bb  = spm_get_bbox(template); % Use Bounding box of the template

%% Waitbar
%multiWaitbar('CloseAll');
w1 = 'Running almost rigid normalisation to multiple images';
multiWaitbar(w1);

%% Normalise images
for i = 1:nFiles
    multiWaitbar(w1, 'Value', i/nFiles);
    VF = spm_vol(files(i,:));   % Image to be normalise
    prm = spm_normalise(template_vol,VF,'','','',samit_def.normalise.estimate);
    spm_write_sn(VF,prm,samit_def.normalise.write);
end

multiWaitbar(w1, 'Close');

end

