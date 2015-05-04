function samit_mask(atlas,files,d)
%   Applies whole brain mask to the defined images
%   FORMAT smait_mask(atlas,files)
%       atlas  - Small animal atlas (see 'samit_defaults')
%       files  - Working files
%       d      - Display (default: true)

%   Version: 15.04 (29 April 2015)
%   Author:  David Vállez Garcia
%   Email:   samit@umcg.nl

%   Tested with SPM8 & SPM12
%   Version 14.11: spm_mask is replaced by spm_imcalc_ui
%   Version 15.04: adjusted to new samit_defaults

%% Remove warning message
warning('off','all');   % Remove warning notifications due to left-right flip of the images

%% Display
if ~exist('d','var')
    d = true;
end

if d ~= false
    display(' ');
    display('SAMIT: Creating masked images...');
    display('--------------------------------');
end

%% Load defaults values
% Mask is selected automatically
if exist('atlas','var')
    samit_def = samit_defaults(atlas);   
else 
    samit_def = samit_defaults; 
end
mask = samit_def.mask;
clear samit_def;
  
    
%% Images to apply mask
if ~exist('files','var')
    files = spm_select(Inf, 'image', 'Select images to apply the mask...');
    if isempty(files)
        display('Operation cancelled: No selected images.');
        return
    end
    files = deblank(files);
end

%% Apply mask to the images
n = size(files,1);

for i = 1:n      
    if isequal(spm('Ver'),'SPM12')
        spm_imcalc({files(i,:), mask}, spm_file(files(i,:),'prefix','m'), 'i1 .* (i2>0)');
    else
        spm_imcalc_ui({files(i,:), mask}, spm_file(files(i,:),'prefix','m'), 'i1 .* (i2>0)');
    end
end

if d ~= false
    display('Masked images created. ')
end

end