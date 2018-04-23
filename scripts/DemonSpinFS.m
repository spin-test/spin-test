% Demonstrate how spin rotation works with a faked dataset in FreeSurfer fsaverage5
% Requires AxelRot.m (included in this directory) from file exchange, 
% https://www.mathworks.com/matlabcentral/fileexchange/30864-3d-rotation-about-shifted-axis?focused=5191309&tab=function
% & installation of FreeSurfer Matlab toolboxes (part of FreeSurfer installation) 
% Aaron Alexander-Bloch & Siyuan Liu 
% DemonSpinFS.m, 2018-04-22

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
subplot(4,2,1);
mincol=min(dataL);
maxcol=max(dataL);
plotFSsurf(facespl,verticespl,dataL,custommap,mincol,maxcol,[-90 0]);
title('Lateral View of Initial Left');
subplot(4,2,2);
plotFSsurf(facespl,verticespl,dataL,custommap,mincol,maxcol,[90 0]);
title('Medial View of Initial Left');



%extract the correspoding sphere surface coordinates for rotation
[verticesl, facesl] = freesurfer_read_surf(fullfile(fshome,'subjects/fsaverage5/surf/lh.sphere'));
[verticesr, facesr] = freesurfer_read_surf(fullfile(fshome,'subjects/fsaverage5/surf/rh.sphere'));


%rotate begin
bl=verticesl;
br=verticesr;

%rotate 180 along x axis, i.e. right-left
[R,~]=AxelRot(180,[1,0,0]);
bl=bl*R;
[R,~]=AxelRot(180,[1,0,0]);
br=br*R;

%Calculate Euclidian distance between the original and rotated surfaces.
distfun = @(a,b) sqrt(bsxfun(@minus,bsxfun(@plus,sum(a.^2,2),sum(b.^2,1)),2*(a*b))); 
distl=distfun(verticesl,bl');
distr=distfun(verticesr,br');

%Find the pair of matched vertices with the min distance and reassign
%values to the rotated surface.
[~, Il]=min(distl,[],2);
[~, Ir]=min(distr,[],2);
dataLrot=dataL(Il);
dataRrot=dataR(Ir);

subplot(4,2,3);
mincol=min(dataLrot);
maxcol=max(dataLrot);
plotFSsurf(facespl,verticespl,dataLrot,custommap,mincol,maxcol,[-90 0]);
title('Lateral View of Left rotated 180 along x axis');
subplot(4,2,4);
plotFSsurf(facespl,verticespl,dataLrot,custommap,mincol,maxcol,[90 0]);
title('Medial View of Left rotated 180 along x axis');


%rotate 180 along y axis, i.e., anterior-posterior
[R,~]=AxelRot(180,[0,1,0]);
bl=bl*R;
[R,~]=AxelRot(-180,[0,1,0]);
br=br*R;

%Calculate Euclidian distance between the original and rotated surfaces.
distl=distfun(verticesl,bl');
distr=distfun(verticesr,br');

%Find the pair of matched vertices with the min distance and reassign
%values to the rotated surface.
[~, Il]=min(distl,[],2);
[~, Ir]=min(distr,[],2);
dataLrot=dataL(Il);
dataRrot=dataR(Ir);

subplot(4,2,5);
mincol=min(dataLrot);
maxcol=max(dataLrot);
plotFSsurf(facespl,verticespl,dataLrot,custommap,mincol,maxcol,[-90 0]);
title('Lateral View of Left rotated 180 along y axis');
subplot(4,2,6);
plotFSsurf(facespl,verticespl,dataLrot,custommap,mincol,maxcol,[90 0]);
title('Medial View of Left rotated 180 along y axis');


%rotate 180 along z axis, i.e., superior-inferior
[R,~]=AxelRot(180,[0,0,1]);
bl=bl*R;
[R,~]=AxelRot(-180,[0,0,1]);
br=br*R;
%Calculate Euclidian distance between the original and rotated surfaces.
distl=distfun(verticesl,bl');
distr=distfun(verticesr,br');

%Find the pair of matched vertices with the min distance and reassign
%values to the rotated surface.
[~, Il]=min(distl,[],2);
[~, Ir]=min(distr,[],2);
dataLrot=dataL(Il);
dataRrot=dataR(Ir);

subplot(4,2,7);
mincol=min(dataLrot);
maxcol=max(dataLrot);
plotFSsurf(facespl,verticespl,dataLrot,custommap,mincol,maxcol,[-90 0]);
title('Lateral View of Left rotated 180 along x axis');
subplot(4,2,8);
plotFSsurf(facespl,verticespl,dataLrot,custommap,mincol,maxcol,[90 0]);
title('Medial View of Left rotated 180 along x axis');
