function samit_reset(files,d)
%   Reset images (transformation matrix & origin)
%   FORMAT samit_reset(files,d)
%       files   - Files to be corrected
%       d       - Display (default: true)

% Right-handed orientation
% RAS = LR = LPI = Neurological (Left is right)
% mat == mat0 
%
% vol = spm_vol(file);
% vol.mat  = [-1 0 0  50;
%              0 1 0 -50;
%              0 0 1 -50;
%              0 0 0   1];
% vol.mat0 = [-1 0 0  50;
%              0 1 0 -50;
%              0 0 1 -50;
%              0 0 0   1];
%
% Left-handed orientation (RPI)
% LAS = RL = RPI = Radiological (Right is left)
% mat ~= mat0
%
% vol = spm_vol(file);
% vol.mat  = [ 1 0 0 -50;
%              0 1 0 -50;
%              0 0 1 -50;
%              0 0 0   1];
% vol.mat0 = [-1 0 0  50;
%              0 1 0 -50;
%              0 0 1 -50;
%              0 0 0   1];
%

% VINCI saves the images in Ragiological convention
% and the information in vol.mat is not properly stored

%   Version: 15.06.23 (23 June 2015)
%   Author:  David Vállez Garcia
%   Email:   samit@umcg.nl

%   Tested with SPM8 & SPM12


%% Display
if ~exist('d','var')
    d = true;
end
if d ~= false
    display(' ');
    display('SAMIT: Reset image files');
    display('------------------------');
end

%% Select image
if ~exist('files','var')
    [files, sts] = spm_select(Inf,'image','Select images...','', pwd);
    if ~sts
        display('Operation cancelled: No files were selected');
        return
    else
        files = cellstr(files);
        %files = deblank(files);
    end    
end

for i = 1:numel(files)
    
% Extracted from spm_image('resetorient')
        V    = spm_vol(files{i});
        M    = V.mat;

%% VINCI NIfTI Fix (last version tested 4.46):
% the matrix are not properly stored in the header
% this fix is needed to avoid wrong orientation and
% voxel size
% data is transformed from radiological orientation to neurological

        % Default "wrong" matrix used by VINCI
        M_vinci = [2 0 0 -2; 0 2 0 -2; 0 0 2 -2; 0 0 0 1];
        
        if isequal(M, M_vinci) && ~isequal(M, V.private.mat0)
            M = V.private.mat0;
            %M(1) = M(1) * -1;
            Y = spm_read_vols(V);
            Y = flip(Y,1);
            spm_write_vol(V,Y);

        end
        
% End VINCI Fix

%% PMOD NIfTI Fix
%   PMOD saves the files with anterior/posterior flip, as compared with SPM
        M_pmod = diag([1 -1 1]);
        [A, ~ , B] = svd(M(1:3,1:3));
        Pmod = A*B';
        if isequal(M_pmod, Pmod)
            M(2,:) = M(2,:) * -1;
            Y = spm_read_vols(V);
            Y = flip(Y, 2); % Flip data A/P
            spm_write_vol(V,Y);
        end
        

%% Reset
        vox  = sqrt(sum(M(1:3,1:3).^2));
        if det(M(1:3,1:3))<0
            vox(1) = -vox(1);
        end
        orig = (V.dim(1:3)+1)/2;
        off  = -vox.*orig;
        M    = [vox(1) 0      0      off(1)
                0      vox(2) 0      off(2)
                0      0      vox(3) off(3)
                0      0      0      1];
        spm_get_space(files{i},M);

%

    if d ~= false
        display(['Image corrected: ', spm_file(files{i},'filename')]);
    end
    
end


end