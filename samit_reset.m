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

%   Version: 14.12.02 (02 December 2014)
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
    if sts == 0
        display('Operation cancelled: No files were selected');
        return
    end
    files = deblank(files);
end

for f = 1:size(files)
    
    vol = nifti(files(f,:));     % Working image
    
    % Check orientation (extracted from spm_orientations)
    M = vol.mat;
    [U,~,V] = svd(M(1:3,1:3));
    M   = U*V';
    lab = 'LRPAIS';
    m   = [1 -1  0  0  0  0
        0  0  1 -1  0  0
        0  0  0  0  1 -1];
    dp = M\m;
    c  = '   ';
    for j=1:3,
        [~,ind] = max(dp(j,:));
        c(j)         = lab(ind);
    end
    
    % Reset orientation
    
    if det(M)>0,
        % 'Right' or 'LPI'
        M = vol.mat0;
        M(1,:) = M(1,:) * -1;
    else
        % 'Left' or 'RPI'
        M = vol.mat0;
    end
    
    spm_get_space(files(f,:),M);      
    
    if d ~= false
        display(['Image corrected: ', spm_file(files(f,:),'filename')]);
    end
    
end


end