function samit_PMOD2SPM(files,d)

%% Display
if ~exist('d','var')
    d = true;
end
if d ~= false
    display(' ');
    display('SAMIT: Reorient images from PMOD space to SPM space');
    display('---------------------------------------------------');
end


%% Select images
if ~exist('files','var')
    [files, sts] = spm_select(Inf,'image','Select images...','', pwd);
    if ~sts
        display('Operation cancelled: No files were selected');
        return
    else
        files = cellstr(files);
        %files = deblank(files);
    end
end

for i = 1:numel(files)
    
    % Working file
    f = files{i};
    vol = spm_vol(f);
    mat = vol.mat;
    vox  = sqrt(sum(mat(1:3,1:3).^2)); % Voxel size
    
    % df: difference between center and origin coordinates
    Orig = abs([(mat(1,4)/mat(1,1)) (mat(2,4)/mat(2,2)) (mat(3,4)/mat(3,3))]);
    df = Orig - ((vol.dim+1)./2);
    
    dfm = df;
    dfm(1) = df(1);
    dfm(2) = df(3);
    dfm(3) = -df(2);
    dfm = spm_matrix(dfm .* vox);
    
    % Rotate matrix
    % PMOD space to SPM space (pitch rotation)
    theta = pi/2;
    M = [cos(theta)  0       -sin(theta)        0;
        0       1                0         0;
        sin(theta)  0       cos(theta)         0;
        0           0                0         1];
    
    tform = affine3d(M);
    A = spm_read_vols(vol); % Image data
    RA = imref3d(size(A),vox(1),vox(2),vox(3)); % Limits for otation
    dat_new = imwarp(A,RA,tform);
    
    % Update info for new file
    vol_new = vol;
    vol_new.fname = spm_file(vol.fname,'prefix','r');
          
    % Correct location of origin coordinates
    vol_new.dim = size(dat_new);
    cntr = spm_matrix(vox/2) \ spm_matrix([-(vol_new.dim .* vox /2) 0 0 0 vox]);
    mat_new = dfm \ cntr;       
    vol_new.mat = mat_new; vol_new.private.mat = mat_new;
    vol_new.private.mat0 = mat_new;
    
    % Write new file
    spm_write_vol(vol_new,dat_new);
end
end