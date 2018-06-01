function [cntr, shift] = samit_orig(V)
% cntr  : Center of the image
% shift : Shift between the center and the locatio of origin
orig   = V.mat;
vox    = sqrt(sum(V.mat(1:3,1:3).^2));
cntr   = spm_matrix(vox/2) \ spm_matrix([-(V.dim .* vox /2) 0 0 0 vox]);
affine = cntr / orig;
shift  = affine(13:15);