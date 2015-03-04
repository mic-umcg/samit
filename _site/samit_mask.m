function samit_mask(specie,files,d)
%   Applies whole brain mask to the defined images
%   FORMAT smait_mask(specie,files)
%       specie - Animal specie
%                'rat' (Default)
%                'mouse'
%       files  - Working files
%       d      - Display (default: true)

%   Version: 14.11 (26 November 2014)
%   Author:  David Vállez Garcia
%   Email:   dvallezgarcia=gmail*com
%   Real_email = regexprep(Email,{'=','*'},{'@','.'})

%   Tested with SPM8 & SPM12
%   Version 14.11: spm_mask is replaced by spm_imcalc_ui

%% Display
if ~exist('d','var')
    d = true;
end

if d ~= false
    display(' ');
    display('SAMIT: Creating masked images...');
    display('--------------------------------');
end

%% Working mask
if ~exist('specie','var')
    specie = 'rat'; % By default 'rat' is selected
end

% Mask is selected automatically
samit_def = samit_defaults(specie);
mask = samit_def.mask;
clear samit_def;

% Manual selection of the mask
% mask = spm_select(1, 'image', 'Select mask image...');
% if isempty(mask)
%    display('Operation cancelled: No selected mask.');
%	return
% end    
    
%% Images to apply mask
if ~exist('files','var')
    files = spm_select(Inf, 'image', 'Select images to apply the mask...');
    if isempty(files)
        display('Operation cancelled: No selected images.');
        return
    end
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