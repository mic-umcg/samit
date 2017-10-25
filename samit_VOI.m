function samit_VOI(atlas)
%   Extract the mean values from VOIs
%   Origin is expected to be in same location in the images, the VOI and
%   the whole brain mask
%   FORMAT samit_VOI(atlas)
%       atlas  - Small animal atlas (see 'samit_defaults')

%   Version: 17.10 (24 October 2015)
%   Author:  David Vallez Garcia
%   Email:   samit@umcg.nl

%   Tested with SPM8 & SPM12
%   v14.11:    Images are masked using spm_imcalc
%   v15.02:    Calculation is done using spm_summarise
%   v15.03:    Adjustment for SPM8 compatibility
%              Adjusted to new samit_defaults
%   v17.01:    Improved speed


%% Display
display(' ');
display('SAMIT: Extraction of VOIs data');
display('------------------------------');

%% Extract brain mask info from the atlas settings
if ~exist('atlas','var')
    %samit_def = samit_defaults('Schwarz'); % For debug only
    error('No atlas selected!');
else
    samit_def = samit_defaults(atlas);
end
mask_file = samit_def.mask;
clear samit_def;

%% Reference VOIs
VOI = spm_select(1,'image','Please, select the image containing the VOIs...');
VOI = deblank(VOI);

if isempty(VOI)
    % Only the whole brain VOI will be used if no file was selected
    VOI_names = {'Whole_brain'};  
    nvois = 1;                        % Only Whole Brain
    
else
    % Load VOI info
    VOI_V = spm_vol(VOI);
    VOI_Y = spm_read_vols(VOI_V);
    VOI_n = unique(VOI_Y);          % Array with numbers in VOI image
    VOI_n = VOI_n(VOI_n ~= 0);      % Remove zero
    nvois = numel(VOI_n) + 1;       % Total number of regions + Wholebrain
    
    % Load the names for each region in the VOI
    VOI_txt = spm_file(VOI,'ext','.txt');
    
    if ~exist(VOI_txt,'file')  % If there is no file with the name of each region
        VOI_names = ['WholeBrain'; cellstr(strcat('VOI_', num2str(VOI_n,'%02d')))];
    else                        % If there is a file with the info
        fid = fopen(VOI_txt);
        C = textscan(fid, '%d %s', 'Delimiter', '\t', 'CommentStyle', '//');
        fclose(fid);
        VOI_names = ['WholeBrain'; cellstr(C{2})];
    end   
end


%% Whole brain VOI
mask_V = spm_vol(mask_file);
mask_Y = spm_read_vols(mask_V);
mask_Y(mask_Y~=0) = 1;      % If several regions, all merged into one


%% Files to analyze
files = spm_select(Inf,'image','Please, select the images to be analysed.');
if isempty(files)   % Error check
    display('Operation cancelled: No files were selected');
    return
end
files = deblank(files);
V = spm_vol(files);     % SPM volumes

%% Name to store the results
[results_name, results_path] = uiputfile('*.txt', 'New file to store the results...');
% Error check
if isequal(results_name,0) || isequal(results_path,0)
    display('Operation cancelled: Output file was not specified.');
    return
end
results_name = spm_file(results_name,'basename');  % Removes the extension

%% Initialize variables                          
nfiles = numel(V);                             % Number of files to analyse
M = cell(nvois*nfiles,8);                      % Matrix with results

%% Start Progress bar
w1 = 'Extracting VOIs data: ';
multiWaitbar('CloseAll');
multiWaitbar(w1);

%% Evaluation of the VOIs
l = 1;
for f = 1:nfiles
    multiWaitbar('Image', 'Value', f/nfiles);    % Waitbar
    
    for i=1:nvois
        multiWaitbar(w1, 'Value', i/nvois);    % Waitbar
        
        % Load mask
        if i==1                 % Load BrainMask
            Vm = mask_V;
            Ym = mask_Y;
            voi = 1;
        else
            Vm = VOI_V;
            Ym = VOI_Y;
            voi = i - 1;
        end
        
        % Construct vector of the region
        idx = find(Ym == voi);
        plane   = Vm.dim(1)*Vm.dim(2);
        voi_x   =      mod(idx, Vm.dim(1));  % + 1 --> debugging found this off by one
        voi_y   =  fix(mod(idx, plane ) / Vm.dim(1)) +1;
        voi_z   =  fix(    idx/ plane ) +1;
        XYZ = [ voi_x, voi_y, voi_z, ones(length(idx), 1) ]';
        X = spm_data_read(V(f), 'xyz', XYZ);
        
        M{l,1} = spm_file(V(f).fname, 'filename'); % Name file
        M{l,2} = f;                                % Number of the file
        M{l,3} = i;                                % Number for the Region
        M{l,4} = VOI_names{i};                     % Name of the Region
        M{l,5} = mean(X);                          % Mean
        M{l,6} = std(X);                           % Standard deviation
        M{l,7} = min(X);                           % Min
        M{l,8} = max(X);                           % Max
                
        l = l + 1 ;
    end
end


%% Save results
T = cell2table(M);
T.Properties.VariableNames = {'FileName' 'File_idx' 'VOI' 'VOI_idx' 'Mean' 'SD' 'Min' 'Max'};

cd(results_path);
save([results_name,'.mat'], 'T');
%writetable(T, [results_name,'.xlsx']);
writetable(T, [results_name,'.txt']);
multiWaitbar('CloseAll');

end
