---
layout: default
title: Home
---

# Introduction

The aim of this toolbox is to facilitate the construction of new tracer specific templates and the subsequent voxel-based and/or volume-of-interest based analysis of small animal PET and SPECT brain images. In human studies, the analysis of functional neuroimaging data is frequently performed with [SPM](http://www.fil.ion.ucl.ac.uk/spm) software. We decided to develop a toolbox that introduces minimal changes to the original SPM code, being compatible with the most recent versions of SPM (SPM8 and SPM12). Moreover, this toolbox is focused in the analysis of small animal PET and SPECT functional brain images.

The software is distributed with a T<sub>2</sub>-MRI rat template coregistered with the Paxinos anatomical atlas [Schwarz et al. 2006](http://dx.doi.org/10.1016/j.neuroimage.2006.04.214) and several rat PET and SPECT templates.

# Download the toolbox

The toolbox is freely available for the research community under the terms of the [GNU GPL v3.0 License]({{ site.github.repository_url }}/blob/master/LICENSE).

It is helpful for us to know about the potential users of the toolbox. Therefore, we only ask you to complete a [registration form]({{ site.baseurl }}/form) before downloading SAMIT.

# Installation

The installation of SAMIT is easy, just extract the content of the previously downloaded file and rename the folder as `samit` (e.g. from 'samit-1.2' to only 'samit'). Move the folder inside the `toolbox` folder that is located inside SPM. The toolbox will be available from the "Toolbox" menu in the SPM interface.

# SAMIT manual

A brief manual explaining the content of the toolbox can be found [here]({{ site.baseurl }}/manual).

# Example of rat voxel-based analysis in SPM

A step-by-step example of how to use SAMIT in combination with SPM for the data analysis can be found [here]({{ site.baseurl }}/example).

# The SAMIT project

SAMIT is focused in the needs of the research community performing neuroimaging studies in small animal PET and SPECT. Most of the current functions are based on the experience and requirements of our department.
It is assumed that users are already familiar with [SPM](http://www.fil.ion.ucl.ac.uk/spm). Whilst this software has been tested, not every possible combination of SPM environment and platform has been tried, so there may be some bugs. Please, contact us with any suggestion, bug report, or feature request so we can improve the software.

SAMIT software is developed on and hosted in GitHub. If you are interested to collaborate in the project, you are more than welcome. Head to the [SAMIT repository] ({{ site.github.repository_url }}) for more details, or contact us at <samit@umcg.nl>

Thanks!

# Publications

1. Vállez García D, de Vries EFJ, Toyohara J, Ishiwata K, Hatano K, Dierckx RAJO, et al. Evaluation of [(11)C]CB184 for imaging and quantification of TSPO overexpression in a rat model of herpes encephalitis. Eur J Nucl Med Mol Imaging. 2015 Jun;42(7):1106–18. [doi](http://dx.doi.org/10.1007/s00259-015-3021-x)

2. Parente A, Kopschina Feltes P, Vállez García D, Sijbesma JWA, Moriguchi Jeckel CM, Dierckx RAJO, et al. Pharmacokinetic analysis of 11C-PBR28 in the rat model of herpes encephalitis (HSE): comparison with (R)-11C-PK11195. J Nucl Med. 2016 [doi](http://dx.doi.org/10.2967/jnumed.115.165019)

3. Vállez García D, Otte A, Dierckx RAJO, Doorduin J. Three months follow-up of rat mild traumatic brain injury: a combined [18F]FDG and [11C]PK11195 PET study. J Neurotrauma. 2016 [doi](http://dx.doi.org/10.1089/neu.2015.4230)