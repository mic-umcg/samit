function samit_fix(files,d)
%   Correction of VINCI NIfTI files
%   FORMAT samit_fix_vinci_nii(files,d)
%       files   - Files to be corrected
%       d       - Display (default: true)

%   Version: 14.12.02 (02 December 2014)
%   Author:  David Vállez Garcia
%   Email:   dvallezgarcia=gmail*com
%   Real_email = regexprep(Email,{'=','*'},{'@','.'})

%   Tested with SPM8 & SPM12

%   Version: 14.12 Solved issue with Left/Right


%% Display
if ~exist('d','var')
    d = true;
end
if d ~= false
    display(' ');
    display('SAMIT: Correction of VINCI NIfTI files');
    display('--------------------------------------');
end

%% Select image
if ~exist('files','var')
    [files, sts] = spm_select(Inf,'image','Select images...','', pwd,'.*nii');
    if sts == 0
		display('Operation cancelled: No files were selected');
        return
    end
end

for f = 1:size(files)
    % Working image
          
    vol = nifti(files(f,:));
    
    if ~isequal(vol.mat, vol.mat0)
        
        M = vol.mat0;
        
        % VINCI saves the images in Right-handed orientation (LPI)
        % Example:
        % vol = nifti(file);
        % vol.mat  = [ 1 0 0 -50;
        %              0 1 0 -50;
        %              0 0 1 -50;
        %              0 0 0   1];
        % vol.mat0 = [-1 0 0  50;
        %              0 1 0 -50;
        %              0 0 1 -50;
        %              0 0 0   1];
        
        M(1,1) = abs(M(1,1));
        M(1,4) = M(1,4) * -1;

        
        spm_get_space(files(f,:),M);
        
        if d ~= false
            display(['Image corrected: ', spm_file(files(f,:),'filename')]);
        end
        
    else
        if d ~= false
            display(['Image not modified: ', spm_file(files(f,:),'filename')]);
        end
    end
end


end