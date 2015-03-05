function samit_VOI(specie)
%   Extract the mean values from VOIs
%   Origin is expected to be in same location in the images, the VOI and
%   the whole brain mask
%   FORMAT samit_VOI(specie)
%       specie  - Animal specie
%                 'rat' (Default)
%                 'mouse'

%   Version: 14.12.02 (02 December 2014)
%   Author:  David Vállez Garcia
%   Email:   dvallezgarcia=gmail*com
%   Real_email = regexprep(Email,{'=','*'},{'@','.'})

%   Tested with SPM8 & SPM12
% v14.11.28:    Images are masked using spm_imcalc

%% Display
display(' ');
display('SAMIT: Extraction of VOIs data');
display('------------------------------');

%% Check input
if ~exist('specie','var');
    specie = 'rat';
end
if ~ismember(specie,{'rat', 'mouse'})
    display('Operation cancelled: Wrong input in the animal specie');
    return
end

%% Reference VOIs
VOIs = spm_select(1,'image','Please, select the image containing the VOIs...');

if ~isempty(VOIs)
    
    VOIs_vol = spm_vol(VOIs);                   % Vol VOI
    VOIs_dat = spm_read_vols(VOIs_vol);         % Data VOI
    VOIs_v   = unique(VOIs_dat);                % Array with numbers in VOI image
    VOIs_v   = VOIs_v(2:end);                   % Number zero is removed
    VOIs_num = size(VOIs_v,1);                  % Num regions in VOI

    % Load the names for each VOI
    VOIs_txt = spm_file(VOIs,'ext','.txt');     % Name of VOIs regions
    if ~exist(VOIs_txt,'file')
       display('Operation cancelled: The text file with the associated names of the VOIs was not found');
       return
    else
        fid = fopen(VOIs_txt);
        C = textscan(fid, '%d %s', 'Delimiter', '\t', 'CommentStyle', '#');
        fclose(fid);
        VOIs_names = ['Whole_brain'; C{2}];
    end
else % If no VOI file is selected
    VOIs_num = 0;    % Num regions in VOI
    VOIs_names = {'Whole_brain'};
end

%% Whole brain VOI
samit_def = samit_defaults(specie);
mask = samit_def.mask;

%% Files to analyze
files = spm_select(Inf,'image','Please, select the images to be analysed.');
if isempty(files)   % Error check
    display('Operation cancelled: No files were selected');
    return
end

%% Name to store the results
[results_name, results_path] = uiputfile('*.xls', 'New file to store the results...');
% Error check
if isequal(results_name,0) || isequal(results_path,0)
    display('Operation cancelled: Output file was not specified.');
    return
end
[~, results_name] = fileparts(results_name);   % Avoid the use of the extension as part of the name

%% Initialize variables

n_vois = VOIs_num + 1;                              % Number of VOIs + Whole brain
nfiles = size(files,1);                             % Number of files to analyse
voi_results = cell(8, n_vois);                       % Columns per file

M = zeros(nfiles,n_vois);                           % Table with results (used to calculate 'F')
M_corr = zeros(nfiles,n_vois);                      % Table with corrected results (used to calculate 'F')
F = zeros(4,n_vois);                                % Final table with results (mean & SD)
T = struct('name','results');                       % Structure with all individual results


%% Waitbar
w1 = 'Calculating VOIs data: ';
multiWaitbar('CloseAll');
multiWaitbar(w1);

%% Evaluation of the VOIs
for f = 1:nfiles
    
    multiWaitbar(w1, 'Value', f/(nfiles+1));    % Waitbar
       
    % Extract info from the whole brain and VOIs
    for a = 1:n_vois        
               
        % Apply VOI as a mask to calculate the values
        % Selection of the VOI or Wholebrain
        if a == 1   % Whole brain mask                                   
            spm_imcalc({files(f,:); mask},'test.nii','(i2==1) .* i1');
            tmp_dat = spm_read_vols(spm_vol('test.nii'));
            tmp_dat = single(tmp_dat);
            
        else        % VOIs
            v = VOIs_v(a-1);    % Index of the VOI to be masked
            spm_imcalc({files(f,:); VOIs},'test.nii','(i2==v) .* i1',{},v);
            tmp_dat = spm_read_vols(spm_vol('test.nii'));
            tmp_dat = single(tmp_dat);
        end                    
        
        voi_results{1,a} = VOIs_names(a);               % VOI name
        voi_results{2,a} = mean(tmp_dat(tmp_dat~=0));   % Mean
        voi_results{3,a} = std(tmp_dat(tmp_dat~=0));    % SD
        voi_results{4,a} = min(tmp_dat(:));             % Min
        voi_results{5,a} = max(tmp_dat(:));             % Max
        voi_results{6,a} = sum(tmp_dat(:));             % Sum
        
        tmp_dat = tmp_dat ./ voi_results{2,1};          % Corrects for whole brain mean
        voi_results{7,a} = mean(tmp_dat(tmp_dat~=0));   % Mean (corrected)
        voi_results{8,a} = std(tmp_dat(tmp_dat~=0));    % SD (corrected)
        
        M(f,a) = voi_results{2,a};                      % Store mean value in separate variable
        M_corr(f,a) = voi_results{7,a};                 % Store mean corrected value in separate variable
        
        clear tmp_dat m_dat;
        % Remove temporary file
        delete('test.nii');
        
    end
       
    %% Store results
    T(f).name = spm_file(files(f,:),'filename');
    T(f).results = voi_results;
    
end

%% Final values
for i = 1:n_vois
    F(1,i) = mean(M(:,i));
    F(2,i) = std(M(:,i));
    F(3,i) = mean(M_corr(:,i));
    F(4,i) = std(M_corr(:,i));
end

M_table = array2table(M);
M_table.Properties.RowNames = matlab.lang.makeValidName(cellstr(spm_file(files,'basename')));
M_table.Properties.VariableNames = matlab.lang.makeValidName(VOIs_names);

Mcorr_table = array2table(M_corr);
Mcorr_table.Properties.RowNames = M_table.Properties.RowNames;
Mcorr_table.Properties.VariableNames = M_table.Properties.VariableNames;

F_table = array2table(F);
F_table.Properties.RowNames = {'Mean' 'Std', 'Mean_corr', 'Std_corr'};
F_table.Properties.VariableNames = M_table.Properties.VariableNames;


%% Save results
cd(results_path);

% .mat file
save([results_name,'.mat'], 'T', 'M_table', 'Mcorr_table', 'F_table');
% Excel file
if exist([results_name,'.xls'],'file') == 2
    delete([results_name,'.xls']);
end

writetable(M_table, [results_name,'.xls'], 'WriteRowNames',true,'FileType','spreadsheet','Sheet',1);
writetable(Mcorr_table, [results_name,'.xls'], 'WriteRowNames',true,'FileType','spreadsheet','Sheet',2);
writetable(F_table, [results_name,'.xls'], 'WriteRowNames',true,'FileType','spreadsheet','Sheet',3);

%% Close waitbar
multiWaitbar('CloseAll');
end