function table_name = samit_table(files,output,d)
%   FORMAT samit_tableSUV(files, output, d)
%       files  - Working files
%       output - Name and path of the output file
%       d      - Display (default: true)
%
%       table_name - Output file
%
%   This function creates a table to fill the information needed
%   in the construction of SUV images.
%     - First column:      Full path of the selected images
%     - Second column:     Injected dose, corrected for the start of the camera (in Bq/cc)
%     - Third column:      Weight of the animal in grams (gr)
%     - Fourth (optional): Glucose value (mmol/L)

%   Version: 14.09 (17 September 2014)
%   Author:  David Vállez Garcia
%   Email:   samit@umcg.nl

%   Tested with SPM8 & SPM12

%% Check input
% Display
if ~exist('d','var')
    d = true;
end
if d ~= false
    display(' ');
    display('SAMIT: Creating SUV table...');
    display('----------------------------');
end

% Selection of files
if ~exist('files','var')
    % Select image
    [files, sts] = spm_select(Inf,'image','Select images...');
    if sts == 0
		display('Operation cancelled: No files were selected');
        return
    end
    files = deblank(files);
end

% Name of the table that will be created
if ~exist('output','var')
    [t_nam, t_pth] = uiputfile('*.txt', 'Creates a Table');
    if isequal(t_nam,0) || isequal(t_pth,0)
        display('Operation cancelled: Output file was not specified.');
        return
    end
else
    [t_pth, t_nam, ~, ~] = spm_fileparts(output);
    if isempty(t_pth)
        t_pth = pwd;
    end
    t_nam = [t_nam,'.txt'];
end

table_name = fullfile(t_pth,t_nam); % Name and path of the table

% Write table file
[n, ~] = size(files);

fid = fopen(table_name, 'w');

% Print header
fprintf(fid, 'File Name \t');            % File name
fprintf(fid, 'Dose (MBq) \t');           % Dose
fprintf(fid, 'Weight (gr) \t');          % Weight
fprintf(fid, 'Glucose (mmol/L) \r\n');   % Glucose

for i = 1:n
    
    % File name
    [pth,nam,ext,~] = spm_fileparts(files(i,:));
    f_name = strcat(pth,filesep,nam,ext);
    
    fprintf(fid, '%s\r\n', f_name);   % File name
end

fclose(fid);

% Display name fo table
if d ~= false
    display(['SUV table created: ', spm_file(table_name,'filename')]);
end

end