function samit_def = samit_defaults(specie)
%   Load default values for SPM analysis of PET/SPECT in rats and mouse
%   FORMAT samit_def = samit_defaults(specie)
%       specie    - Animal specie
%                  'rat' (Default)
%                  'mouse'
%       samit_def - Output variable with all the default parameters

%   Version: 14.09 (17 September 2014)
%   Author:  David Vállez Garcia
%   Email:   samit@umcg.nl

%   Tested with SPM8 & SPM12

%   Recommended Basal Plasma Glucose levels:
%       - Rat:  5.5 mmol/L

%% Check input
if ~exist('specie','var');	% If specie is not specified, 'rat' will be used
    specie = 'rat';
end

%% Information related with the templates
% Rat (Schwarz et al. 2006)
% doi:10.1016/j.neuroimage.2006.04.214
MRI_rat	     = 'Schwarz_T2w.nii';
mask_rat     = 'Schwarz_intracranialMask.nii';
bregma_rat   = [0, 4.9, 4.3]; % mm from the center to bregma

% Mouse (Ma et al. 2005, 2008)
MRI_mouse    = 'Mouse_C57BL6_MRI_masked.nii';
mask_mouse   = 'Mouse_C57BL6_brainmask.nii';
bregma_mouse = [0 0 0]; % Not defined

%% Define variables
[samit_dir, ~, ~] = fileparts(which('samit'));

%global samit_def
samit_def.dir                        = samit_dir;
samit_def.specie					 = specie;

% Normalise
samit_def.normalise.estimate.smosrc   = 0.8;
samit_def.normalise.estimate.smoref   = 0;
%samit_def.normalise.estimate.regtype  = 'rigid'; % Almost rigid affine regularisation
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



%% Switch
switch specie
	case 'rat'
		samit_def.mri 					= fullfile(samit_dir,'rat','templates',MRI_rat);
		samit_def.mask 					= fullfile(samit_dir,'rat','mask',mask_rat);
		samit_def.stats.results.mipmat 	= cellstr(fullfile(samit_dir,'MIP_rat.mat'));
		samit_def.bregma                = bregma_rat;
        
	case 'mouse'
		samit_def.mri 					= fullfile(samit_dir,'mouse','templates',MRI_mouse);
		samit_def.mask 					= fullfile(samit_dir,'mouse','mask',mask_mouse);
        samit_def.stats.results.mipmat 	= cellstr(fullfile(samit_dir,'MIP_mouse.mat'));
        samit_def.bregma                = bregma_mouse;

end

samit_def.normalise.write.bb  = spm_get_bbox(samit_def.mri);

%% Change dafault values in SPM
global defaults;
defaults.stats.results.mipmat   = samit_def.stats.results.mipmat;
defaults.smooth.fwhm            = samit_def.smooth.fwhm;
defaults.normalise              = samit_def.normalise; 
defaults.coreg                  = samit_def.coreg;
end