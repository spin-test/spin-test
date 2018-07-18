% Demonstrate how spin rotation works with a faked dataset in FreeSurfer fsaverage5
% Requires AxelRot.m (included in this directory) from file exchange, 
% https://www.mathworks.com/matlabcentral/fileexchange/30864-3d-rotation-about-shifted-axis?focused=5191309&tab=function
% & installation of FreeSurfer Matlab toolboxes (part of FreeSurfer installation) 
% Aaron Alexander-Bloch & Siyuan Liu 
% DemonSpinFS.m, 2018-04-22
% The implementation of generating random rotations originally described in our paper — 
% rotating the coordinates of vertices at angles uniformly chosen between zero and 360 degrees
% about each of the x (left-right), y (anterior-posterior) and z (superior-inferior) axes —
% introduces a preference towards oversampling certain rotations. 
% Thus, we modified the code to incorporate an approach, Lefèvre et al. (2018), 
% that samples uniformly from the space of possible rotations. The updated
% uniform sampling prodcedure does not require AxelRot.m anymore.
% Updated on 2018-07-18

clear variables
close all

%Set up FreeSurfer paths 
fshome = getenv('FREESURFER_HOME');
% if this variable is not set up, please mannually add the path
fsmatlab = sprintf('%s/matlab',fshome);
path(path,fsmatlab);

%Read the faked surface value saved in a csv file
dataL=importdata(['../data/fakeFSdataL.csv']);
dataR=importdata(['../data/fakeFSdataR.csv']);


%For an annotation file, please used the following command to load the data
% filename='lh.annot';% your annotation file name
% [Vl, dataL, ctl] = read_annotation(filename);
% filename='rh.annot';
% [Vr, dataR, ctr] = read_annotation(filename);


%extract the vertice coordinates from the correspoding surface for display.
[verticespl, facespl] = freesurfer_read_surf(fullfile(fshome,'subjects/fsaverage5/surf/lh.pial'));
[verticespr, facespr] = freesurfer_read_surf(fullfile(fshome,'subjects/fsaverage5/surf/rh.pial'));

%show original view
custommap=colormap('jet');
subplot(2,2,1);
mincol=min(dataL);
maxcol=max(dataL);
plotFSsurf(facespl,verticespl,dataL,custommap,mincol,maxcol,[-90 0]);
title('Lateral View of Initial Left');
subplot(2,2,2);
plotFSsurf(facespl,verticespl,dataL,custommap,mincol,maxcol,[90 0]);
title('Medial View of Initial Left');



%extract the correspoding sphere surface coordinates for rotation
[verticesl, facesl] = freesurfer_read_surf(fullfile(fshome,'subjects/fsaverage5/surf/lh.sphere'));
[verticesr, facesr] = freesurfer_read_surf(fullfile(fshome,'subjects/fsaverage5/surf/rh.sphere'));
bl=verticesl;
br=verticesr;

%the updated uniform sampling procedure
I1 = eye(3,3);
I1(1,1)=-1;
A = normrnd(0,1,3,3);
[TL, temp] = qr(A);
TL = TL * diag(sign(diag(temp)));
if(det(TL)<0)
    TL(:,1) = -TL(:,1);
end
%reflect across the Y-Z plane for right hemisphere
TR = I1 * TL * I1;
bl =bl*TL;
br = br*TR;


%Calculate Euclidian distance between the original and resampled surfaces.
distfun = @(a,b) sqrt(bsxfun(@minus,bsxfun(@plus,sum(a.^2,2),sum(b.^2,1)),2*(a*b))); 
distl=distfun(verticesl,bl');
distr=distfun(verticesr,br');

%Find the pair of matched vertices with the min distance and reassign
%values to the resampled surface.
[~, Il]=min(distl,[],2);
[~, Ir]=min(distr,[],2);
dataLrot=dataL(Il);
dataRrot=dataR(Ir);

subplot(2,2,3);
mincol=min(dataLrot);
maxcol=max(dataLrot);
plotFSsurf(facespl,verticespl,dataLrot,custommap,mincol,maxcol,[-90 0]);
title('Lateral View of resampled Left');
subplot(2,2,4);
plotFSsurf(facespl,verticespl,dataLrot,custommap,mincol,maxcol,[90 0]);
title('Medial View of resampled Left');



