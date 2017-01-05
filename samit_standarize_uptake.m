function samit_standarize_uptake(atlas,units,type,gs,infile,d)
%   Construct standarized images with the information provided in the Tab file  
%   FORMAT samit_createSUV(atlas, units,type,gs, infile, d)
%       atlas    - Small animal atlas (see 'samit_defaults')
%       units    - Units of the image
%                 'Bq'
%                 'kBq'
%                 'MBq'
%                 'mCi'
%       type   - Defines output image
%                 'SUV'    Standarized Uptake Value
%                 'SUVglc' SUV corrected for glucose
%                 'SUVw'   SUV corrected for whole brain uptake             
%                 'IDg'    Percentage of injected dose per gram
%       gs      - Basal glucose level
%       infile  - File with the information (*.txt or *.xls)
%       d       - Display (default: true)
%


%   Version: 15.04 (29 April 2014)
%   Author:  David Vállez Garcia
%   Email:   samit@umcg.nl

%% Tested in SPM8 and SPM12
%   Version 15.04: adjusted to new samit_defaults

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
    [nam, pth, ~] = uigetfile({'*.txt', 'Tab Text (TSV)'; ...
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
end
    
%% Read information from the file
ext = spm_file(infile,'ext'); % File extension
switch ext
    case 'txt'      % Tab Text
        
        fid  = fopen(infile);   % Open the file
        
        row = 1;
        while ~feof(fid)        % Read each line
            tline = fgetl(fid);
            C(row,:) = strsplit(tline,'\t');
            row = row + 1;
        end
        fclose(fid);
        
        % Header is excluded
        txt = C(2:end,1);       % Names of files
        num0 = strrep(C(2:end,2:end), ',', '.'); % Values ('comma' is replaced for 'period')
        
        % Cell matrix to num
        num = zeros(size(num0));
        for i = 1:size(num0,1)
            for j = 1:size(num0,2)
                %num(i,j) = str2num(num0{i,j});
                num(i,j) = isnumeric(str2num(num0{i,j}));
            end
        end

              
    case 'xls'      % Excel file
        
        [num, ~, raw] = xlsread(infile);    % Read Excel file
              
        txt = char(raw(2:end,1));           % Files (excluding header)
        
    otherwise
        display('Operation cancelled: Unexpected file format.');
        return
end


%% A copy of each file is normalized to the data type

[nfiles, ~] = size(txt); % Number of images to process

for i = 1:nfiles
    
    % Dose & Weight
    switch units    % Units of the image
        case 'Bq'
            d = (num(i,1) * 10^6); % Injected dose (MBq), converted to Bq like in the image (Bq/cc)
        case 'kBq'
            d = (num(i,1) * 10^3); % Injected dose (MBq), image (kBq/cc)
        case 'MBq'
            d = num(i,1);          % Injected dose (MBq), image (MBq/cc). No conversion needed
        case 'mCi'
            d = num(i,1) * 37;     % Injected dose (MBq), image (mCi/cc)
        otherwise
            d = num(i,1);          % Not specified
    end
    
    w = num(i,2);                  % Weight of the animal (grams)
    
    % Working file   
    file = deblank(char(txt(i,:)));
         
    % Define function
    switch type
        case 'SUV'
            f = ['i1/',num2str(d/w)];   % Formula
            descrip = ['SUV: Dose ' num2str(num(i,1)) 'MBq; Weight ' num2str(w) 'gr'];
        
        case 'SUVglc'           
            g = num(i,3) / gs;      % Glucose value
            f = ['(i1/',num2str(d/w),') * ',num2str(g)];      % Formula           
            descrip = ['SUVglc: Dose ' num2str(num(i,1)) 'MBq; Weight ' num2str(w) 'gr; Glucose ' num2str(num(i,3)) '/' num2str(gs) ];
            
        case 'SUVw'
            % Brain mask
            if ~exist('atlas','var')	% If atlas is not specified, 'rat' will be used
                samit_def = samit_defaults; % Load default values
            else
                samit_def = samit_defaults(atlas);
            end
            
            mask = samit_def.mask;
            clear samit_def;
         
            c = spm_summarise(file,mask,@mean); % Calculate average value for whole brain uptake
            
            f = ['i1/' num2str(c)];      % Formula
            descrip = ['SUVw: Whole brain average ' num2str(c) ];
        
        case 'IDg'
            f = ['100 * i1/' num2str(d)];   % Formula
            descrip = ['%ID/g: Dose ' num2str(num(i,1)) 'MBq; Weight ' num2str(w) 'gr' ];
            
        otherwise
            display('Operation cancelled: Unexpected normalization type.');
            return
    end
    
    % New name of the file
    newname = spm_file(file, 'suffix', ['-', type]);        
    
        
    %% Calculates and write new SUV image
    if isequal(spm('Ver'),'SPM12')
        spm_imcalc(file, newname, f);
    else       
        spm_imcalc_ui(file, newname, f);
    end
    
    % Correct Matrix values
    nvol = spm_vol(newname);
    nmat = spm_read_vols(nvol);
        
    nvol.descrip = descrip;         % Writes the description
    nvol.private.descrip = descrip;
    
    spm_write_vol(nvol,nmat);
    
    % Display new name
    if d ~= false
        display(['New normalized image created: ', spm_file(newname,'filename')]);
    end
    
end



end

