function samit_origin(pos,atlas,files,d)
%   Replace the location of origin's coordinates
%   FORMAT samit_origin(pos,specie,files,d)
%       pos    - Desired position of the "origins" coordinates.
%               'center' : Center of the image
%               'bregma' : Bregma location
%       atlas  - Small animal atlas (see 'samit_defaults')
%       files  - Working files
%       d      - Display (default: true)

%   Version: 15.04 (29 April 2015)
%   Author:  David Vállez Garcia
%   Email:   samit@umcg.nl

%   Tested with SPM8 & SPM12
%   Version 15.04: adjusted to new samit_defaults


%% Variables & Input
current_dir = pwd;  % Working directory

% If postion is not specified then 'center' is used as default
if ~exist('pos','var')
    pos = 'center';
end

if ~ismember(pos,{'center', 'bregma'})
    display('Operation cancelled: Wrong input in the position of the origin');
	return
end

% Display
if ~exist('d','var')
    d = true;
end

if d ~= false
    display(' ');
    display('SAMIT: Origin''s coordinates');
    display('----------------------------');
end

% If files are defined, ask for its selection
if ~exist('files','var')
    % Select image
    [files, sts] = spm_select(Inf,'image','Select images...');
    if sts == 0
		display('Operation cancelled: No files were selected');
        return
    end
    files = deblank(files);
end

%% Change location of coordinates
% Obtain defaults values from samit_defaults
if ~exist('atlas','var')
    samit_def = samit_defaults; % Load default values
else
    samit_def = samit_defaults(atlas);
end

bregma = spm_matrix(samit_def.bregma);
clear samit_def;

vols = spm_vol(files); 

for V = vols'
%%    Old code
%     % Working image
%     [file_dir, file_name, ext]  = spm_fileparts(files(f,:));
%     vol = spm_vol([file_dir, filesep, file_name, ext]);
%     dat = spm_read_vols(vol);
%     
%     % Image matrix
%     mat = vol.mat;
%        
%     % Origin: Center Image
%     xc = (vol.dim(1) + 1) * mat(1,1) / 2;
%     yc = (vol.dim(2) + 1) * mat(2,2) / 2;
%     zc = (vol.dim(3) + 1) * mat(3,3) / 2;
%     
%     mat(1,4) = -xc;
%     mat(2,4) = -yc;
%     mat(3,4) = -zc;
%     
%     if isequal(pos,'bregma')
%         % Origin: Bregma (from center of the template to bregma)
%                        
%         % Calculate location
%         if abs(mat(1,1)) < 1   % Image rat size
%             xb = xc + bregma(1); 
%             yb = yc + bregma(2);    
%             zb = zc + bregma(3);
%         else                   % Image scaled x10 (~human size)
%             xb = xc + (bregma(1) * 10); 
%             yb = yc + (bregma(2) * 10);      
%             zb = zc + (bregma(3) * 10);
%         end
%         
%         mat(1,4) = -xb;
%         mat(2,4) = -yb;
%         mat(3,4) = -zb;
%     end
%     
%     % Write new file
%     vol.mat = mat;
%     vol.private.mat = mat;
%     vol.private.mat0 = mat;
%     
%     cd(file_dir);
%     spm_write_vol(vol,dat);

    % Voxel size    
    voxdim = diag(V.mat)';
    voxdim = voxdim(1:3);
    
    % Matrix with location of the image center
    mat = spm_matrix(voxdim/2) \ spm_matrix([-(V.dim .* voxdim /2) 0 0 0 voxdim]);
        
    % If 'bregma' option is selected
    if isequal(pos,'bregma')
        mat = bregma \ mat; 
    end
    
    % Save new location of origin
    spm_get_space(V.fname,mat);
    
    % Display info
    if d ~= false
        display(['Origin located in ', pos , ' for: ', spm_file(V.fname, 'filename')]);
    end
    
end

cd(current_dir);

end
