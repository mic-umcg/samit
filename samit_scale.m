function samit_scale(files,d)
%   Scale the image voxel size and origin coordinates
%   FORMAT samit_scale(files,d)
%       files   - Working files
%       d       - Display (default: true)

%   Version: 14.09 (17 September 2014)
%   Author:  David Vállez Garcia
%   Email:   samit@umcg.nl

%   Tested with SPM8 & SPM12

%% Check display flag
if ~exist('d','var')
    d = true;
end

%% Display
if d ~= false
    display(' ');
    display('SAMIT: Scale image x1 <-> x0.1');
    display('------------------------------');
end

%% Working directory
current_dir = pwd;

%% Select images
if ~exist('files','var')
    [files, sts] = spm_select(Inf,'image','Select images...');
    if sts == 0
        display('Operation cancelled: No selected images.');
        return
    end
end
    
%% Scale images
for f = 1:size(files)
    % Working image
    [file_dir, file_name, ext]  = spm_fileparts(files(f,:));
    vol = spm_vol([file_dir, filesep, file_name, ext]);
    dat = spm_read_vols(vol);
    
    if isequal(vol.mat, vol.private.mat0)
        
        % Image matrix info
        mat = vol.private.mat0;
        
        if abs(mat(1)) > 1  % Absolute value, to avoid L&R negative values
            mat(1:3,:) = mat(1:3,:) ./ 10;
        else
            mat(1:3,:) = mat(1:3,:) .* 10;
        end
        
        % Write new file
        vol.mat          = mat;
        vol.private.mat  = mat;
        vol.private.mat0 = mat;
        
        vol.private.mat_intent  = 'Aligned';
        vol.private.mat0_intent = 'Aligned';
        
        
        cd(file_dir);
        spm_write_vol(vol,dat);
        
        % Display info
        if d ~= false
            display(['Image scaled: ', file_name, ext]);
        end
    else
        if d ~= false
            display(['Unchanged. Different NIfTI matrices: ', file_name, ext]);
        end
    end
    
    % Clear variables
    clearvars -except f current_dir files d
end

cd(current_dir);

end
