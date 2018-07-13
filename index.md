---
layout: default
title: Home
---
# Small Animal Molecular Imaging Toolbox (SAMIT)
## Introduction
The aim of this toolbox is to facilitate voxel-based and/or volume-based analysis of small animal PET and SPECT brain images. It also provides an automatized procedure for the construction of new tracer-specific templates for the spatial registration of small animal PET and SPECT brain images.

In human studies, the analysis of functional neuroimaging data is frequently performed with [SPM](http://www.fil.ion.ucl.ac.uk/spm) software. We decided to develop a toolbox that introduces minimal changes to the original SPM code, being compatible with the most recent versions of SPM (SPM8 and SPM12). Moreover, this toolbox is focused in the analysis of small animal PET and SPECT functional brain images.

The software is distributed with a T<sub>2</sub>-MRI rat template coregistered with the Paxinos anatomical atlas [Schwarz et al. 2006](http://dx.doi.org/10.1016/j.neuroimage.2006.04.214) and several rat PET and SPECT templates. More small animal atlases will be available in the future.

## Download the toolbox
The toolbox is freely available for the research community under the terms of the [GNU GPL v3.0 License]({{ site.github.repository_url }}/blob/master/LICENSE).

It is helpful for us to know more about the potential users of the toolbox. Therefore, we only ask you to complete a [registration form]({{ site.baseurl }}/form) before downloading SAMIT.

## Installation
The installation of SAMIT is easy, just extract the content of the previously downloaded file and rename the folder as `samit` (e.g. from 'samit-1.3' to only 'samit'). Move the folder inside the `toolbox` folder that is located inside SPM. Then, SAMIT will be doi the "Toolbox" menu in the SPM interface.

## SAMIT manual
A brief manual explaining the content of the toolbox can be found [here]({{ site.baseurl }}/manual).

## Example of rat voxel-based analysis in SPM

A step-by-step example of how to use SAMIT in combination with SPM for the data analysis can be found [here]({{ site.baseurl }}/example).

## The SAMIT project

SAMIT is focused in the needs of the research community performing neuroimaging studies in small animal PET and SPECT. Most of the current functions are based on the experience and requirements of our department.
It is assumed that users are already familiar with [SPM](http://www.fil.ion.ucl.ac.uk/spm). Whilst this software has been tested, not every possible combination of SPM environment and platform has been tried, so there may be some bugs. Please, contact us with any suggestion, bug report, or feature request so we can improve the software.

SAMIT software is developed on and hosted in GitHub. If you are interested to collaborate in the project, you are more than welcome. Head to the [SAMIT repository] ({{ site.github.repository_url }}) for more details, or contact us at <samit@umcg.nl>

Thanks!

## Publications that used SAMIT
1. Vállez García D, de Vries EF, Toyohara J, Ishiwata K, Hatano K, Dierckx RA, et al. Evaluation of [11C]CB184 for imaging and quantification of TSPO overexpression in a rat model of herpes encephalitis. Eur J Nucl Med Mol Imaging. 2015 Jun;42(7):1106–18. doi:[10.1007/s00259-015-3021-x](http://dx.doi.org/10.1007/s00259-015-3021-x)
2. Parkinson FE, Paul S, Zhang D, Mzengeza S, Ko JH. The Effect of Endogenous Adenosine on Neuronal Activity in Rats: An FDG PET Study. J Neuroimaging. 2016;26(4):403–5. doi:[10.1111/jon.12349](http://dx.doi.org/10.1111/jon.12349)
3. Sijbesma JW, Zhou X, Vállez García D, Houwertjes MC, Doorduin J, Kwizera C, et al. Novel Approach to Repeated Arterial Blood Sampling in Small Animal PET: Application in a Test-Retest Study with the Adenosine A1 Receptor Ligand [11C]MPDX. Mol Imaging Biol. 2016 Oct 18;18(5):715–23. doi:[10.1007/s11307-016-0954-9](http://dx.doi.org/10.1007/s11307-016-0954-9)
4. Vállez García D, Otte A, Dierckx RA, Doorduin J. Three Month Follow-Up of Rat Mild Traumatic Brain Injury: A Combined [18F]FDG and [11C]PK11195 Positron Emission Study. J Neurotrauma. 2016 Oct 15;33(20):1855–65. doi:[10.1089/neu.2015.4230](http://dx.doi.org/10.1089/neu.2015.4230)
5. Parente A, Kopschina Feltes P, Vallez Garcia D, Sijbesma JW, Moriguchi Jeckel CM, Dierckx RA, et al. Pharmacokinetic Analysis of 11C-PBR28 in the Rat Model of Herpes Encephalitis: Comparison with (R)-11C-PK11195. J Nucl Med. 2016 May 1;57(5):785–91. doi:[10.2967/jnumed.115.165019](http://dx.doi.org/10.2967/jnumed.115.165019)
6. Zhou X, Doorduin J, Elsinga PH, Dierckx RA, de Vries EF, Casteels C. Altered adenosine 2A and dopamine D2 receptor availability in the 6-hydroxydopamine-treated rats with and without levodopa-induced dyskinesia. Neuroimage. 2017;157(December 2016):209–18. doi:[10.1016/j.neuroimage.2017.05.066](http://dx.doi.org/10.1016/j.neuroimage.2017.05.066)
7. Vállez García D, Doorduin J, de Paula Faria D, Dierckx RA, de Vries EF. Effect of Preventive and Curative Fingolimod Treatment Regimens on Microglia Activation and Disease Progression in a Rat Model of Multiple Sclerosis. J Neuroimmune Pharmacol. 2017 Sep;12(3):521–30. doi:[10.1007/s11481-017-9741-x](http://dx.doi.org/10.1007/s11481-017-9741-x)
8. Parente A, Vállez García D, Shoji A, Lopes Alves I, Maas B, Zijlma R, et al. Contribution of neuroinflammation to changes in [11C]flumazenil binding in the rat brain: Evaluation of the inflamed pons as reference tissue. Nucl Med Biol. 2017 Jun;49:50–6. doi:[10.1016/j.nucmedbio.2017.03.001](http://dx.doi.org/10.1016/j.nucmedbio.2017.03.001)
9. Lopes Alves I, Vállez García D, Parente A, Doorduin J, Dierckx RA, Marques da Silva AM, et al. Pharmacokinetic modeling of [11C]flumazenil kinetics in the rat brain. EJNMMI Res. 2017 Dec;7(1):17. doi:[10.1186/s13550-017-0265-4](http://dx.doi.org/10.1186/s13550-017-0265-4)
10.	Lopes Alves I, Vállez García D, Parente A, Doorduin J, Marques da Silva AM, Koole M, et al. Parametric Imaging of [11C]Flumazenil Binding in the Rat Brain. Mol Imaging Biol. 2018;20(1):114–23. doi:[10.1007/s11307-017-1098-2](http://dx.doi.org/10.1007/s11307-017-1098-2)
11.	Lee JH, Lee M, Park JA, Ryu YH, Lee KC, Kim KM, et al. Effects of hypothyroidism on serotonin 1A receptors in the rat brain. Psychopharmacology. 2018. 235(3):729–36. doi:[10.1007/s00213-017-4799-y](http://dx.doi.org/10.1007/s00213-017-4799-y)
12. Lee M, Lee HJ, Park IS, Park JA, Kwon YJ, Ryu YH, et al. Aβ pathology downregulates brain mGluR5 density in a mouse model of Alzheimer”. Neuropharmacology. 2018. 1;133:512–7. doi:[10.1016/j.neuropharm.2018.02.003](http://dx.doi.org/10.1016/j.neuropharm.2018.02.003)
13. Tsartsalis S, Tournier BB, Habiby S, et al. Dual-radiotracer translational SPECT neuroimaging. Comparison of three methods for the simultaneous brain imaging of D2/3and 5-HT2Areceptors. Neuroimage. 2018. 176(March):528-540. doi:[10.1016/j.neuroimage.2018.04.063](http://dx.doi.org/10.1016/j.neuroimage.2018.04.063)
