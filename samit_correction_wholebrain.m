function samit_correction_wholebrain(specie)
%   Correct the image by the mean uptake in the whole brain
%   FORMAT samit_correction_wholebrain(specie)
%       specie  - Animal specie
%                 'rat' (Default)
%                 'mouse'

%   Version: 14.09 (17 September 2014)
%   Author:  David Vállez Garcia
%   Email:   dvallezgarcia=gmail*com
%   Real_email = regexprep(Email,{'=','*'},{'@','.'})

%   Tested with SPM8

%% Check input
if ~exist('specie','var');
    specie = 'rat';
end
if ~ismember(specie,{'rat', 'mouse'})
    display('Operation cancelled: Wrong input in the animal specie');
    return
end

%% Display
display(' ');
display('SAMIT: Correct the image by the mean uptake in the whole brain');
display('---------------------------------------------------------------');

%% Whole brain VOI from samit_defaults
samit_def = samit_defaults(specie);

%% Select images
files = spm_select(Inf,'image','Select images to correct for whole brain uptake');
if isempty(files)   % Error check
    display('Operation cancelled: No files were selected');
    return
end

%% Waitbar
w1 = 'Calculating mean values... ';
w2 = 'Creating corrected images...';
multiWaitbar('CloseAll');
multiWaitbar(w1);
multiWaitbar(w2);

%% Mask images
nfiles = size(files,1);
spm_mask(samit_def.mask,files);
%pth = pwd;
%files_mask = spm_file(files,'path',pth,'prefix','m','number','');
files_mask = spm_file(files,'prefix','m','number','');
multiWaitbar(w1, 'Value', 1);

%% Calculate mean of whole brain and create new file with corrected value
for i = 1:nfiles
    
    multiWaitbar(w2, 'Value', i/nfiles);
    
    tmp_dat = spm_read_vols(spm_vol(files_mask(i,:)));
    
    d = mean(tmp_dat(tmp_dat~=0));
    f = ['i1/', num2str(d)];
    
    % Check SPM version
    if isequal(spm('Ver'),'SPM12')
        spm_imcalc(files(i,:), spm_file(files(i,:),'suffix','_ratio'), f);
    else
        spm_imcalc_ui(files(i,:), spm_file(files(i,:),'suffix','_ratio'), f);
    end
        
end

%% Remove temporary files
for r = 1:nfiles
    delete(files_mask(r,:));
end

%% Close waitbar
multiWaitbar('CloseAll');

end
