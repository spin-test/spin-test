% Example code for how to run the spin test
% Medial wall removal is now included
% SMW 07/31/2020

% Step 1: SpinPermuFs.m to obtain 'spins' of the data 
% (or use SpinPermuCIVET.m):

% left and right surfaces (group-averaged at every vertex):
readleft = '/path/to/left_data1.csv';
readright = '/path/to/right_data1.csv';
permno = 1000; % how many spins
wsname = sprintf('/where/to/safe/spun/data');

SpinPermuFS(readleft,readright,permno,wsname)

% Step 2: pvalvsNull.m to run the spin test
% left and right hemispheres for the second modality:
readleft1 = readleft;
readright1 = readright;
readleft2 = 'path/to/left_data2.csv'; 
readright2 = 'path/to/right_data2.csv';

% indicate (with 0's and 1's) which vertices in the left and right
% hemispheres are part of the medial wall
[vl, left_labels, ctl] = read_annotation(fullfile(fshome,'/subjects/fsaverage5/label/lh.aparc.a2009s.annot'));
v_exclude_left = left_labels==1644825; % label of vertices in the medial wall is 1644825
[vr,right_labels,ctr] = read_annotation(fullfile(fshome,'/subjects/fsaverage5/label/rh.aparc.a2009s.annot'));
v_exclude_right = right_labels==1644825;

pval=pvalvsNull(readleft1,readright1,readleft2,readright2,permno,wsname, v_exclude_left, v_exclude_right);