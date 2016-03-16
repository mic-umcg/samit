function samit_VOIsLR

% This function divides a VOI image into right and left regions.
% It assumes that data is stored using the SPM orientation,
% and that Left/right center is located in the center of the image


vol = spm_vol(spm_select(1,'image','Please, select the image containing the VOIs...'));

if isempty(vol)
    display('Operation cancelled: No file was selected');
    return
end

% Obtain data matrix
dat = spm_read_vols(vol);
% Array with numbers in VOI image, number zero is remove
vois  = unique(dat);
if isequal(vois(1),0)
    vois = vois(2:end);
end
nvois = size(vois,1); % Number of VOIs

% Load the names for each VOI
vois_txt = spm_file(vol.fname,'ext','txt');

if ~exist(vois_txt,'file') % If there is no file with the name of each region
    for c=1:nvois
        C{c,1} = ['VOI_',num2str(c)];
    end
    vois_names = C;
else  % If there is a file with the info
    fid = fopen(vois_txt);
    C = textscan(fid, '%d %s', 'Delimiter', '\t', 'CommentStyle', '#');
    fclose(fid);
    vois_names = C{2};
end

x_half = floor((vol.dim(1) + 1) /2);

datR = dat;
datR = (datR .* 2) -1;
datR(x_half+1:end,:,:) = 0;
datL = dat;
datL = (datL .* 2);
datL(1:x_half,:,:) = 0;
datNew = datL + datR;
datNew(datNew < 0) = 0;

volNew = vol;
volNew.fname = spm_file(volNew.fname,'suffix','_LR');

spm_write_vol(volNew,datNew);

%% Print Text file
fid = fopen(spm_file(volNew.fname,'ext','txt'), 'w');

fprintf(fid, '%s\t', '#Index');  % Header
fprintf(fid, '%s\n', 'Name');    % Header

for i = 1:nvois
    fprintf(fid, '%d\t', (vois(i) * 2) - 1 );                   % Index
    fprintf(fid, '%s\n', char(strcat(vois_names(i),' Right'))); % Name
    fprintf(fid, '%d\t', vois(i) * 2  );                        % Index
    fprintf(fid, '%s\n', char(strcat(vois_names(i),' Left')));  % Name
end
fclose(fid);
end