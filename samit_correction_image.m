function samit_correction_image(ref_file, work_files)    
%   Divide the voxel value of the image, by the value of the reference
%   FORMAT samit_correction_image(ref_file, work_file)
%       ref_file    Reference image (e.g. Mean image of control group)
%       work_files  List of files to which apply the correction

%   Version: 15.11 (26 November 2014)
%   Author:  David Vállez Garcia
%   Email:   samit@umcg.nl

%   Tested with SPM8 & SPM12

%% Check input
if ~exist('ref_file','var')
    ref_file = spm_select(Inf,'image','Select refence images (e.g. mean image)');
end

if isempty(ref_file)
    display('Operation cancelled: No reference file selected');
    return
end

if ~exist('work_files','var')
    work_files = spm_select(Inf,'image','Select images to which apply the correction');
end
    
if isempty(work_files)
    display('Operation cancelled: No files were selected');
    return
end
        
%% Display
display(' ');
display('SAMIT: Correct the image by the mean uptake in the whole brain');
display('---------------------------------------------------------------');

%% Correct images with values of reference file

n = size(work_files,1); % Number of files
f = 'i1./i2';            % Function 'Working image' ./ 'Reference image'

for i = 1:n
    
    % Check SPM version
    if isequal(spm('Ver'),'SPM12')
        spm_imcalc({work_files(i,:), ref_file}, spm_file(work_files(i,:),'suffix','_ratio'), f);
    else
        spm_imcalc_ui({work_files(i,:);ref_file}, spm_file(work_files(i,:),'suffix','_ratio'), f);
    end
    
end


end
