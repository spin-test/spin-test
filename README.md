
# Spin Test
This toolbox includes scripts to perform a "spin test" of anatomical correspondence between 
cortical surface maps in either FreeSurfer or CIVET. 
These methods are described in "On testing for spatial correspondence between maps of 
human brain structure and function," Alexander-Bloch et al., NeuroImage, 2018.

## Contents:
data/ directory contains files needed to run scripts
script/ directory includes all m files 

## Requirements:
1) FreeSurfer Matlab toolbox for FreeSurfer IO and it is included in FreeSurfer installation 
2) Toolbox SurfStat (included in scripts directory) for CIVET IO,  
http://www.bic.mni.mcgill.ca/ServicesSoftware/StatisticalAnalysesUsingSurfstatMatlab
3) Nearestneighbour.m incluced in scripts directory, https://www.mathworks.com/matlabcentral/fileexchange/12574-nearestneighbour-m

## Tutorials:
---------
1. Run DemonSpinFS.m
Demonstrate how spin rotation works with a faked dataset in FreeSurfer fsaverage5.
2. Run SpinPermuFS.m
Generate the null distribution of the map in FreeSurfer by randomly spinning user-defined # times. See example included in this code.
2. Run SpinPermuCIVET.m
Generate the null distribution of the map in CIVET by randomly spinning user-defined # times. See example included in this code.
3. Run pvalvsNull.m
Calculate the p-value of correlation between two surface maps based on the null distribution of spins of map 1, output from 2a or 2b. See example included in this code.

This toolbox was developed and tested under Matlab R2015a by Aaron Alexander-Bloch, Simon Vandekar & Siyuan Liu.

## Notes:
Initial commit: 2018-04-22

UPDATE 2018-07-18: bug fix to implement improved method of random rotations, as original method had a preference for certain rotations. See technical note for details.

UPDATE 2019-06-18: updated code to use nearestneighbour function, which saves substantial time compared to our own implementation especially with larger surface files.

