function samit_def = samit_defaults(atlas)
%   Load default values for SPM analysis of PET/SPECT in small animals
%   FORMAT samit_def = samit_defaults(atlas)
%       atlas     - Small animal atlas
%                  'Schwarz'    Rat Atlas (Default)
%                  'Ma'         Mouse Atlas
%       samit_def - Output variable with all the default parameters

%   Version: 15.04 (29 April 2015)
%   Author:  David Vállez Garcia
%   Email:   samit@umcg.nl

%   Tested with SPM8 & SPM12

%   Recommended Basal Plasma Glucose levels:
%       - Rat:  5.5 mmol/L


%% Atlas
default_atlas = 'Schwarz'; % This atlas will be used as the defatult
if ~exist('atlas','var');
    atlas = default_atlas;
end

switch atlas
	case 'Schwarz'
		% Rat (Schwarz et al. 2006)
        % doi:10.1016/j.neuroimage.2006.04.214
        pathname = 'Schwarz_rat';
        MRI	     = 'Schwarz_T2w.nii';
        mask     = 'Schwarz_intracranialMask.nii';
        bregma   = [-0.1, 4.9, 4.5];
             		  
	case 'Ma'
		% Mouse (Ma et al. 2005, 2008)        
        pathname = 'Ma_mouse';
        MRI      = 'Mouse_C57BL6_MRI_masked.nii';
        mask     = 'Mouse_C57BL6_brainmask.nii';
        bregma   = [0 0 0];

% Example fro new atlas
%    case 'Atlas_name'
%    % Add some description for the atlas        
%       pathname = 'pathname';                    % Name of the path were atlas is located
%       MRI      = 'SmallAnimal_MRI.nii';         % Name of the reference MRI
%       mask     = 'SmallAnimal_brainmask.nii';   % Name of the brain mask
%       bregma   = [0 0 0]; % Distance (mm) to bregma from center of MRI image
        
       
end


%% Define variables
samit_def.dir                   = fileparts(which('samit'));
samit_def.atlas                 = atlas;
samit_def.mri 					= fullfile(samit_def.dir,pathname,'templates',MRI);
samit_def.mask 					= fullfile(samit_def.dir,pathname,'mask',mask);
%samit_def.stats.results.mipmat  = cellstr(fullfile(samit_def.dir,'rat','MIP.mat'));
samit_def.stats.results.mipmat 	= fullfile(samit_def.dir,pathname,'MIP.mat');
samit_def.bregma                = bregma;

% Normalise
samit_def.normalise.estimate.smosrc   = 0.8;
samit_def.normalise.estimate.smoref   = 0;
samit_def.normalise.estimate.regtype  = 'none';
samit_def.normalise.estimate.cutoff   = 25;
samit_def.normalise.estimate.nits     = 0;	    % Avoid warp
samit_def.normalise.estimate.reg      = 0;
samit_def.normalise.estimate.graphics = 0;

samit_def.normalise.write.preserve   = 0;
samit_def.normalise.write.vox        = [0.2 0.2 0.2];  % Voxel size
samit_def.normalise.write.interp     = 1;              % Interpolation method
samit_def.normalise.write.wrap       = [0 0 0];        % Warping
samit_def.normalise.write.prefix	 = 'w';

% Check if it is correct
[bb, vx] = spm_get_bbox(samit_def.mri);
bb(2,:) = bb(2,:) + abs(vx);            % Correction for number of slides
samit_def.normalise.write.bb         = bb;

% Smooth
samit_def.smooth.fwhm  = [1.2 1.2 1.2];

% Co-registration
samit_def.coreg.estimate.cost_fun = 'nmi';
samit_def.coreg.estimate.sep      = [0.4 0.2];
samit_def.coreg.estimate.tol      = [0.002 0.002 0.002 0.0001 0.0001 0.0001 0.001 0.001 0.001 0.0001 0.0001 0.0001];
samit_def.coreg.estimate.fwhm     = [0.7 0.7];

samit_def.coreg.write.mask        = 0;
samit_def.coreg.write.mean        = 0;
samit_def.coreg.write.interp      = 1; %4
samit_def.coreg.write.which       = 1;
samit_def.coreg.write.wrap        = [0 0 0];
samit_def.coreg.write.prefix      = 'r';


%% Change dafault values in SPM
global defaults;
defaults.stats.results.mipmat   = samit_def.stats.results.mipmat;
defaults.smooth.fwhm            = samit_def.smooth.fwhm;
defaults.normalise              = samit_def.normalise; 
defaults.coreg                  = samit_def.coreg;
end