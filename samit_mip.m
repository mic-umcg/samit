function  preset = samit_mip(preset,fnc)

switch fnc
    %% Create MIP
    case 'Create'
        % Variables
        preset.mip.size         = [400 364]; % Standard MIP size
        %preset.mip.margin       = 10;
        preset.mip.thicker      = false;
        preset.mip.gridStep     = 0;    % 1px black, the rest white
        preset.mip.gridWidth    = 0;    % Check: line is 1px + gridWidth
        
        % Functions
        preset = preprocessimg(preset); % Pre-process image
        preset = createmip(preset); % Create MIP parameters
        
    %% Save MIP and Atlas
    case 'Save'
        % Variable
        preset.samit     = spm_file(which('samit'),'path'); % SAMIT folder
        preset.folder    = [preset.atlasname,'_',preset.specie];
        
        % Function
        saveAtlas(preset);
    otherwise
        error('Wrong function expected from sami_MIP');
end
handles.preset = preset;


% ------------------------------------------------------------------------
function preset = preprocessimg(preset)

V = preset.mip.V;

% Create an isotropic volume to make other slices
vox = sqrt(sum(V.mat(1:3,1:3).^2));
voxi = repmat(prod(vox)^(1/3), [1 3]);
dim = floor(V.dim .* (vox./voxi));
vox = voxi;

% Reduce dimensions by increasing voxel size
n = 2;
while(any(dim>256))
    vox = sqrt(sum(V.mat(1:3,1:3).^2));
    voxi = repmat(prod(vox)^(1/3), [1 3])*n;
    dim = floor(V.dim .* (vox./voxi));
    vox = voxi;
    n = n + 1;
    if(n>5)
        warning('An error has probably occured. May be slow. Is voxel size ok in source image?');
        break
    end
end

% Reset translation in image for reconstruction
oldmat = V.mat;

vox0 = sqrt(sum(V.mat(1:3,1:3).^2));
orig0 = (V.dim(1:3) + 1)/2;

oldmatdefault = diag([vox0 1]);
oldmatdefault([13 14 15]) = -vox0.*orig0;

currentaffine = oldmat / oldmatdefault;
originshift = currentaffine([13 14 15]);

V.mat([13 14 15]) = -vox.*((dim(1:3)+1)/2);
off0 = -vox.*((dim(1:3)+1)/2);
off = zeros(4);
off([13 14 15]) = off0;

matout = diag([vox 1]) + off;

if(det(V.mat)<0)
    matout(13) = matout(13) - vox(1).*dim(1);
end

[x,y,zi] = ndgrid(1:dim(1), 1:dim(2),1);
rigid = zeros(dim);

for i=1:dim(3);
    z = zi*i;
    [tx,ty,tz] = coords(V.mat\matout,x,y,z);
    rigid(:,:,i) = spm_sample_vol(V, tx, ty, tz, 3);
end


if(det(V.mat)<0)
    matout(13) = matout(13) + vox(1).*dim(1);
end

matout = spm_matrix(originshift) * matout;
preset.mip.V.mat = matout;
preset.mip.V.dim = dim;
preset.mip.img = rigid;

% ------------------------------------------------------------------------
function preset = createmip(preset)
%
% DXYZ   - length of the X,Y,Z axes of the mip sections (in mip pixels).
% CXYZ   - offsets of the origin into the mip sections (in mip pixels).

try
    
    %% Working Variables
    V         = preset.mip.V;
    thresh    = preset.mip.threshold;
    cannyu    = preset.mip.cannyu;
    cannyl    = preset.mip.cannyl;
    img       = preset.mip.img;
    sz        = preset.mip.size;
    marg      = round(max(preset.mip.margin,1));
    thicker   = preset.mip.thicker;
    gridWidth = preset.mip.gridWidth;
    gridStep  = preset.mip.gridStep;
    
    if isequal(preset.mip.chkAutoEdge, true)
        cannythresh = [];
    else
        cannythresh = [cannyl cannyu];
    end
    
    
    %%
    % Applies threshold
    % img   : Original image data
    % imgTh : Thresholded image data
    imgTh = img > (thresh*max(img(:)));
    
    % X-ray beam on each plane
    imgTrans = (squeeze(sum(imgTh, 3)>0)');
    imgSag = ((squeeze(sum(imgTh, 1)>0)));
    imgCor = (squeeze(sum(imgTh, 2)>0));
    
    % Crop planes
    [rectTransCrop,imgTransC] = GetCropRect(imgTrans);
    [rectSagCrop,imgSagC] = GetCropRect(imgSag);
    [rectCorCrop,imgCorC] = GetCropRect(imgCor);
    
    % Use split between sagittal and coronal to set scale proportionally
    % rectangle format top left bot right, typical matlab xy nonsense
    nSagWidth = rectSagCrop(3) - rectSagCrop(1) + 1;
    nCorWidth = rectCorCrop(3) - rectCorCrop(1) + 1; % remember the mip is rotated...
    
    DY   = floor(nSagWidth / (nSagWidth+nCorWidth) * (sz(1)-2*marg));
    DX   = sz(1) - DY;
    DZ   = sz(2) - DX;
    DXYZ = [DX DY DZ];
    
    
    % Resample image to required dimensions + edge detect
    dZoom = GetZoomFactor(size(imgSagC), [DY-4*marg DZ-4*marg]);
    
    imgTransCe = edge(double(imresize(imgTransC, dZoom, 'bicubic')),'canny',cannythresh);
    imgSagCe   = edge(double(imresize(imgSagC, dZoom, 'bicubic')),'canny',cannythresh);
    imgCorCe   = edge(double(imresize(imgCorC, dZoom, 'bicubic')),'canny',cannythresh);
    
    imgTransC = imresize(imgTransC, dZoom,'bicubic');
    imgSagC = imresize(imgSagC, dZoom,'bicubic');
    imgCorC = imresize(imgCorC, dZoom,'bicubic');
    
    
    if isequal(thicker, true)
        imgSagCe = thicken(imgSagCe);
        imgCorCe = thicken(imgCorCe);
        imgTransCe = thicken(imgTransCe);
    end
    
    
    dWorldCentre = -V.mat([13 14 15]);
    dVoxelSize = sqrt(sum(V.mat(1:3,1:3).^2));
    %dWorldExtent = dVoxelSize .* V.dim;
    
    dMIPCentre = V.mat(1:3,1:3) \ dWorldCentre';
    % dMIPCentre is now in voxel space in the original data, at the origin
    dMIPCentre = floor(dZoom * dMIPCentre);
    
    CX = dMIPCentre(1) - floor((rectTransCrop(2)-1)*dZoom) + marg;
    CY = dMIPCentre(2) - floor((rectSagCrop(1)-1)*dZoom) + marg;
    CZ = dMIPCentre(3) - floor((rectCorCrop(2)-1)*dZoom) + marg;
    CXYZ = [CX CY CZ];
    scale = (1/dZoom) * (prod(dVoxelSize)^(1/3)); % 1 pixel in MIP will be this in world
    
    % Create Image with Brain Glass Contours
    mipc = zeros(sz);
    mipc(marg:marg+size(imgTransC,1)-1, marg:marg+size(imgTransC,2)-1) = imgTransCe;
    mipc(marg:marg+size(imgSagC,1)-1, marg+DX:marg+DX+size(imgSagC,2)-1) = imgSagCe;
    mipc(marg+DY:marg+DY+size(imgCorC,1)-1, marg+DX:marg+DX+size(imgCorC,2)-1) = imgCorCe;
    
    % Create Image with Brain Masks
    mipmask = zeros(sz);
    mipmask(marg:marg+size(imgTransC,1)-1, marg:marg+size(imgTransC,2)-1) = 1-logical(imgTransC);
    mipmask_trans = mipmask; % Save Trans image
    
    mipmask(marg:marg+size(imgSagC,1)-1, marg+DX:marg+DX+size(imgSagC,2)-1) = 1-logical(imgSagC);
    mipmask(marg+DY:(marg+DY+size(imgCorC,1)-1), marg+DX:marg+DX+size(imgCorC,2)-1) = 1-logical(imgCorC);
    
    
    %draw coordinate lines
    % lines on axial/hz slice, first transverse then sagittal
    %mip(round(CY:CY+1),round((0.5*marg):2:(DX+.5*marg))) = 1;
    %mip(round(0.5*marg:2:DY),round(CX:CX+1))=1;
    mipgrid = zeros(sz);
    
    mipgrid = matline(mipgrid, round([CY-1 marg]),round([CY-1+gridWidth marg+size(imgTransC,2)-1]),[1 gridStep]);
    mipgrid = matline(mipgrid, round([marg CX-1]),round([marg+size(imgTransC,1)-1 CX-1+gridWidth]), [gridStep 1]);
    mipgrid_trans = mipgrid;
    
    mipgrid = matline(mipgrid, round([CY-1 marg+DX]),round([CY-1+gridWidth marg+DX+size(imgSagC,2)-1]),[1 gridStep]);
    mipgrid = matline(mipgrid, round([marg DX+CZ-1]),round([marg+size(imgSagC,1)-1 DX+CZ-1+gridWidth]),[gridStep 1]);
    
    mipgrid = matline(mipgrid, round([DY+CX-1 marg+DX]),round([DY+CX-1+gridWidth marg+DX+size(imgCorC,2)-1]), [1 gridStep]);
    mipgrid = matline(mipgrid, round([marg+DY DX+CZ-1]),round([marg+DY+size(imgCorC,1)-1 DX+CZ-1+gridWidth]),[gridStep 1]);
    
    % Combines grid and contour
    mip96 = mipgrid + mipc;
    mip96(mip96 > 1) = 1; % Corrects for the summation of lines
    
    
    %% Save results into 'preset'
    preset.mip.mip96        = mip96;
    preset.mip.mask_trans   = mipmask_trans;
    preset.mip.mask_all     = mipmask;
    preset.mip.grid_trans   = mipgrid_trans;
    preset.mip.grid_all     = mipgrid;
    preset.mip.CXYZ         = CXYZ;
    preset.mip.DXYZ         = DXYZ;
    preset.mip.scale        = 1./repmat(scale,[1 3]);
    
   
catch ME
    fprintf(1,'Error found while creating MIP:\n-------------------------------\n');
    error('An error occured - is your image ok?');
end

%-------------------------------------------------------------------------
function [y1,y2,y3] = coords(M,x1,x2,x3)
% Affine transformation of a set of coordinates.
%_______________________________________________
% From spm code.
y1 = M(1,1)*x1 + M(1,2)*x2 + M(1,3)*x3 + M(1,4);
y2 = M(2,1)*x1 + M(2,2)*x2 + M(2,3)*x3 + M(2,4);
y3 = M(3,1)*x1 + M(3,2)*x2 + M(3,3)*x3 + M(3,4);
return

%-------------------------------------------------------------------------
function [rect,imgCrop] = GetCropRect(img)
% returns the tightest rectangle enclosing the binary image and if desired
% the image itself

if ~any(img)
    rect = [0 0 0 0];
    imgCrop = 0;
    return;
end

nSize = size(img);
rect = [1 1 nSize(1) nSize(2)];

for i=1:nSize(1)
    if any(img(i,:)) % if this row is not empty...
        rect(1) = i-2;
        break;
    end
end

for i=1:nSize(2)
    if any(img(:,i)) % if this row is not empty...
        rect(2) = i-2;
        break;
    end
end


for i=nSize(1):-1:1
    if any(img(i,:)) % if this row is not empty...
        rect(3) = i+2;
        break;
    end
end


for i=nSize(2):-1:1
    if any(img(:,i)) % if this row is not empty...
        rect(4) = i+2;
        break;
    end
end

if(rect(1) < 1), rect(1) = 1;  end
if(rect(2) < 1), rect(2) = 1;  end
if(rect(3) > nSize(1)), rect(3) = nSize(1);  end
if(rect(4) > nSize(2)), rect(4) = nSize(2);  end

if nargout > 1
    imgCrop = img(rect(1):rect(3), rect(2):rect(4));
end

%-------------------------------------------------------------------------
function fact = GetZoomFactor(nSize, nSizeFit)
% Returns the biggest factor nSize can be increased so the whole thing will
% fit in nSizeFit

fact = nSizeFit / nSize;
fact = min(fact);

%-------------------------------------------------------------------------
function imageout = thicken(imagein)
% not everybody has the image processing toolbox, so a quick and dirty
% implementation of dilatation for line thickening.

sz = size(imagein);
imageout = zeros(sz);

for j=2:sz(2)-1
    for i=2:sz(1)-1
        
        if imagein(i,j)
            imageout(i-1:i+1, j-1:j+1) = 1;
        end
        
    end
end

%-------------------------------------------------------------------------
function mat = matline(mat, start, stop, step)
% Draw line
sz = size(mat);

for i=1:2
    if stop(i) < start(i)
        temp = start(i); start(i) = stop(i); stop(i) = temp;
    end
    
    if stop(i) < 1
        return;
    end
    
    if start(i) < 1
        start = 1;
    end
    
    if start(i) > sz(i)
        return;
    end
    
    if stop(i) > sz(i)
        stop(i) = sz(i);
    end;
end

%mat(start(1):step(1):stop(1), start(2):step(2):stop(2)) = 1.5;
mat(start(1):stop(1), start(2):stop(2)) = 1;
mat(start(1):step(1):stop(1), start(2):step(2):stop(2)) = 0;

%-------------------------------------------------------------------------
function saveAtlas(preset)

% Create Atlas folders
atlas_folder = [preset.samit, filesep, preset.folder];
mkdir(atlas_folder);                         % Root folder
mkdir([atlas_folder, filesep, 'mask']);      % Mask folder
mkdir([atlas_folder, filesep, 'templates']); % Templates folder
mkdir([atlas_folder, filesep, 'VOIs']);      % VOIs folder

% Copy MRI & Atlas
copyfile(preset.mri,  [atlas_folder,filesep,'templates']);
copyfile(preset.mask, [atlas_folder,filesep,'mask']);

% Add info to 'samit_atlases.txt' file
% Specie,AtlasName,Details,Folder,MRI,Mask,Bregma
mri  = spm_file(preset.mri, 'filename');
mask = spm_file(preset.mask, 'filename');

fid  = fopen([preset.samit,filesep,'samit_atlases.txt'],'r+t'); % Open samit_atlases.txt

fseek(fid,-1,'eof');    % Check if newline is needed : char(10) = \n
c = fread(fid,1);
fseek(fid,0,'eof');
if ~isequal(c,10)
    fprintf(fid, '\n');
end

fprintf(fid, '%s,%s,%s,%s,%s,%s,%.2f %.2f %.2f\n',...
    preset.specie, preset.atlasname, preset.details,...
    preset.folder, mri, mask, preset.bregma);
fclose(fid);

% Save MIP.mat
mip.CXYZ       = preset.mip.CXYZ;
mip.DXYZ       = preset.mip.DXYZ;
mip.grid_all   = sparse(preset.mip.grid_all);
mip.grid_trans = sparse(preset.mip.grid_trans);
mip.mask_all   = sparse(preset.mip.mask_all);
mip.mask_trans = sparse(preset.mip.mask_trans);
mip.mip95      = zeros([360 352]); % Not sure if needed
mip.mip96      = sparse(preset.mip.mip96);
mip.scale      = preset.mip.scale;

save([atlas_folder,filesep,'MIP.mat'],'-v6','-struct','mip');
