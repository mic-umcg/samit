function samit_createSUV(type,gs,infile,d)
%   Construct SUV images with the information provided in the Tab file
%   (a template of this file can be created with 'samit_tableSUV.m')
%   FORMAT samit_createSUV(type,gs,infile,d)
%       type    - Defines the image units
%                 'Bq'  for Bq/cc
%                 'kBq' for kBq/cc
%                 'MBq' for MBq/cc
%       gs      - Basal glucose level
%       file    - File with the SUV table (*.txt or *.xls)
%       d       - Display (default: true)
%
%   Expected units of uPET images are Bq/cc, and for uSPECT MBq/cc.
%   The variable 'type' is used to specify if the data
%   in the table file needs to be, or not, converted from MBq to Bq, since
%   the information from the SUV table is expected in MBq.
%   Extra information about the SPECT acquisition and its conversion to MBq
%   can be found at DOI 10.1007/s00259-010-1519-9

%   Version: 15.02 (04 February 2015)
%   Author:  David Vállez Garcia
%   Email:   samit@umcg.nl

%   Tested with SPM8 and SPM12

%% Check input and SPM version
% SPM Version
v = spm('Ver');

% Display
if ~exist('d','var')
    d = true;
end
if d ~= false
    display(' ');
    display('SAMIT: Creating SUV images...');
    display('-----------------------------');
end

% Obtain table file
if ~exist('infile','var')
    [nam, pth, index] = uigetfile({'*.txt', 'Tab Text (TSV)'; ...
                                         '*.xls', 'Microsoft Excel'}, ...
                                         'Select the file with the SUV information');
    % Check if no file was introduced
    if isequal(nam,0) || isequal(pth,0)
        display('Operation cancelled: No file was selected.');
        return
    end
    infile = fullfile(pth,nam);
    
else
    % Check if file exist
    if ~exist(infile,'file')
        display('Operation cancelled: Input file was not found.');
        return                        
    end
    
    ext = spm_file(infile,'ext');
    if isequal(ext,'txt')
        index = 1;
    elseif isequal(ext,'xls')
        index = 2;
    else
        display('Operation cancelled: Unexpected file format.');
        return
    end
    
end    
    
%% Read information from the file
switch index
    case 1      % Tab Text
        
        % Check the format of the decimal ('comma' is replaced for 'period')
        fid  = fopen(infile,'r'); % Open file
        f = fread(fid,'*char')';           % Read file to variable
        fclose(fid);
        
        f = strrep(f, ',', '.');           % Replace
        
        tmp_infile = spm_file(infile,'prefix','tmp-'); 
        
        fid  = fopen(tmp_infile,'w');      % Write again the text
        fprintf(fid,'%s',f);
        fclose(fid);
        
        % Read the Tab file
        [num,~,txt] = tblread(tmp_infile,'tab');
        delete(tmp_infile);
        
        
    case 2      % Excel file
        
        [num, ~, raw] = xlsread(infile); % Read Excel file
              
        txt = char(raw(2:end,1));                  % Files (excluding header)
        
    otherwise
        display('Operation cancelled: Unexpected file format.');
        return
end


%% A copy of each file is created as SUV image

[nfiles, ~] = size(txt); % Number of images to process

for i = 1:nfiles
    % Dose & Weight
    switch type
        case 'Bq'
            d = (num(i,1)*10^6); % Injected dose (MBq), image (Bq/cc)
        case 'kBq'
            d = (num(i,1)*10^3); % Injected dose (MBq), image (kBq/cc)
        case 'MBq'
            d = num(i,1);        % Injected dose (MBq), image (MBq/cc)
    end
    
    w = num(i,2);               % Weight of the animal (grams)
    
    % Extract name parts
    [pathname, name, ext] = fileparts(txt(i,:));
    
    % vol = spm_vol(txt(i,:));  % Load matrix (Test)
    
    % Define function
    if size(num,2) == 2 % Without glucose correction
        f = ['i1/',num2str(d/w)];   % Function to calculate SUV image
        % Define new image name
        newname = [pathname,filesep,name,'-SUV',ext];
        descrip = ['SUV: Dose ' num2str(num(i,1)) 'MBq; Weight ' num2str(w) 'gr.'];
    else                % With glucose correction
        g = gs / num(i,3);      % Glucose value
        f = ['(i1/',num2str(d/w),')*',num2str(g)];
        % Define new image name
        newname = [pathname,filesep,name,'-SUVglc',ext];
        descrip = ['SUVglc: Dose ' num2str(num(i,1)) 'MBq; Weight ' num2str(w) 'gr; Glucose ' num2str(num(i,3)) '/' num2str(gs) ];
    end
    
    % Calculates and write new SUV image
    if isequal(v,'SPM12')
        spm_imcalc(txt(i,:), newname, f);
    else
        spm_imcalc_ui(txt(i,:), newname, f);
    end
    
    % Correct Matrix values
    nvol = spm_vol(newname);
    mat = spm_read_vols(nvol);
    
    %nvol.mat = vol.private.mat0;   % Matrix are expected to be correct
    %nvol.private.mat = nvol.mat;   % May be removed in future version
    %nvol.private.mat0 = nvol.mat;  % if code is ok
    
    nvol.descrip = descrip;         % Write SUV values in description
    nvol.private.descrip = descrip;
    
    spm_write_vol(nvol,mat);
    
    % Display new name
    if d ~= false
        display(['New SUV image created: ', spm_file(newname,'filename')]);
    end
    
end



end

