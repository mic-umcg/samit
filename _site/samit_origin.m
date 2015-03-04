function samit_origin(pos,specie,files,d)
%   Replace the location of origin's coordinates
%   FORMAT samit_origin(pos,specie,files,d)
%       pos    - Desired position of the "origins" coordinates.
%               'center' : Center of the image
%               'bregma' : Bregma location
%       specie - Animal specie
%                'rat' (Default)
%                'mouse'
%       files  - Working files
%       d      - Display (default: true)

%   Version: 14.09 (17 September 2014)
%   Author:  David Vállez Garcia
%   Email:   dvallezgarcia=gmail*com
%   Real_email = regexprep(Email,{'=','*'},{'@','.'})

%   Tested with SPM8 & SPM12


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

% If specie is not introduced, then 'rat' will be used as default
if ~exist('specie','var');	% If specie is not specified, 'rat' will be used
    specie = 'rat';
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
end

%% Change location of coordinates
% Obtain defaults values from samit_defaults
samit_def = samit_defaults(specie);
bregma = samit_def.bregma;
clear samit_def;

for f = 1:size(files)
    % Working image
    [file_dir, file_name, ext]  = spm_fileparts(files(f,:));
    vol = spm_vol([file_dir, filesep, file_name, ext]);
    dat = spm_read_vols(vol);
    
    % Image matrix
    mat = vol.mat;
       
    % Origin: Center Image
    xc = (vol.dim(1) + 1) * mat(1,1) / 2;
    yc = (vol.dim(2) + 1) * mat(2,2) / 2;
    zc = (vol.dim(3) + 1) * mat(3,3) / 2;
    
    mat(1,4) = -xc;
    mat(2,4) = -yc;
    mat(3,4) = -zc;
    
    if isequal(pos,'bregma')
        % Origin: Bregma (from center of the template to bregma)
                       
        % Calculate location
        if abs(mat(1,1)) < 1   % Image rat size
            xb = xc + bregma(1); 
            yb = yc + bregma(2);    
            zb = zc + bregma(3);
        else                   % Image scaled x10 (~human size)
            xb = xc + (bregma(1) * 10); 
            yb = yc + (bregma(2) * 10);      
            zb = zc + (bregma(3) * 10);
        end
        
        mat(1,4) = -xb;
        mat(2,4) = -yb;
        mat(3,4) = -zb;
    end
    
    % Write new file
    vol.mat = mat;
    vol.private.mat = mat;
    vol.private.mat0 = mat;
    
    cd(file_dir);
    spm_write_vol(vol,dat);
    
    % Display info
    if d ~= false
        display(['Origin located in ', pos , ' for: ', file_name, ext]);
    end
    
end

cd(current_dir);

end
