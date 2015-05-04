function samit_VOI(atlas)
%   Extract the mean values from VOIs
%   Origin is expected to be in same location in the images, the VOI and
%   the whole brain mask
%   FORMAT samit_VOI(atlas)
%       atlas  - Small animal atlas (see 'samit_defaults')

%   Version: 15.04 (29 April 2015)
%   Author:  David Vallez Garcia
%   Email:   samit@umcg.nl

%   Tested with SPM8 & SPM12
%   v14.11:    Images are masked using spm_imcalc
%   v15.02:    Calculation is done using spm_summarise
%   v15.03:    Adjustment for SPM8 compatibility
%              Adjusted to new samit_defaults        



%% Display
display(' ');
display('SAMIT: Extraction of VOIs data');
display('------------------------------');


%% Reference VOIs
VOIs = spm_select(1,'image','Please, select the image containing the VOIs...');
VOIs = deblank(VOIs);

if ~isempty(VOIs)
    
    VOIs_v   = unique(spm_read_vols(spm_vol(VOIs))); % Array with numbers in VOI image
    
    if isequal(VOIs_v(1),0)
        VOIs_v = VOIs_v(2:end);                      % Number zero is removed
    end 
        
    % Load the names for each VOI
    VOIs_txt = spm_file(VOIs,'ext','.txt');
    
    if ~exist(VOIs_txt,'file')  % If there is no file with the name of each region
       for c=1:size(VOIs_v,1)
           C{c,1} = ['VOI_',num2str(c)];
       end
       VOIs_names = ['Whole_brain'; C];
    else                        % If there is a file with the info
        fid = fopen(VOIs_txt);
        C = textscan(fid, '%d %s', 'Delimiter', '\t', 'CommentStyle', '#');
        fclose(fid);
        VOIs_names = ['Whole_brain'; C{2}];
    end
    
    nvois = size(VOIs_v,1) + 1;        % Number of VOIs + Whole Brain
    
   
else % Only the whole brain VOI will be used if no file was selected
    VOIs_names = {'Whole_brain'};
    nvois =  1;                        % Only Whole Brain
end


%% Whole brain VOI
if ~exist('atlas','var')
    samit_def = samit_defaults; % Load default values
else
    samit_def = samit_defaults(atlas);
end

mask = samit_def.mask;
clear samit_def;

%% Files to analyze
files = spm_select(Inf,'image','Please, select the images to be analysed.');
if isempty(files)   % Error check
    display('Operation cancelled: No files were selected');
    return
end
files = deblank(files);

%% Name to store the results
[results_name, results_path] = uiputfile('*.txt', 'New file to store the results...');
% Error check
if isequal(results_name,0) || isequal(results_path,0)
    display('Operation cancelled: Output file was not specified.');
    return
end
results_name = spm_file(results_name,'basename');  % Removes the extension

%% Initialize variables
nfiles = size(files,1);                            % Number of files to analyse
M = zeros(nvois,4,nfiles);                         % Matrix with results
temp = 'temp_img.nii';

%% Start Progress bar
w1 = 'Extracting VOIs data: ';
multiWaitbar('CloseAll');
multiWaitbar(w1);

%% Evaluation of the VOIs

for v=1:nvois   
    multiWaitbar(w1, 'Value', v/(nvois));    % Waitbar
    
    if isequal(v,1)
        Vo = mask;
        r = 0;  % Init counter
        r = double(r);
    else
        Vo = temp;
        r = r + 1;
        
        if isequal(spm('Ver'),'SPM12')
            spm_imcalc(VOIs,Vo,'i1 == r',{},r);
        else
            Vi = spm_vol(VOIs);
            vol = Vi;
            vol.fname = temp;
            spm_imcalc(Vi,vol,'i1 == r',{},r);
        end
    end
    
    for f = 1:nfiles
        multiWaitbar('Image', 'Value', f/nfiles);    % Waitbar
        M(v,1,f) = spm_summarise(files(f,:),Vo,@mean);
        M(v,2,f) = spm_summarise(files(f,:),Vo,@std);
        M(v,3,f) = spm_summarise(files(f,:),Vo,@min);
        M(v,4,f) = spm_summarise(files(f,:),Vo,@max);
    end
end

if exist(temp,'file')
    delete(temp);
end


%% Save results
cd(results_path);

save([results_name,'.mat'], 'M');

% Save txt file
fid = fopen([results_name '.txt'], 'w');

fprintf(fid, 'File Name \t');
for h = 1:nvois
    fprintf(fid, '%s\t', VOIs_names{h});    % VOI name
end
fprintf(fid, '\r\n');                       % End row

for f = 1:nfiles
    fprintf(fid, '%s\t', spm_file(files(f,:),'basename'));       % File name
    
    for h = 1:nvois
        fprintf(fid, '%12.8f\t', M(h,1,f)); % VOI mean
    end
    fprintf(fid, '\r\n');                   % End row

end

fclose(fid);

multiWaitbar('CloseAll');

end
