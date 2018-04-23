%%%% AAB Dec 2016
% code written to visualize spin test working
% NB AxelRot is from file exchange, https://www.mathworks.com/matlabcentral/fileexchange/30864-3d-rotation-about-shifted-axis?focused=5191309&tab=function
% need to have FreeSurfer Matlab functions loaded
%Clear work space
clear variables
close all
%Set up paths 
% Replace the following path with the path to the SOBP_neurosynth2 folder
fshome = getenv('FREESURFER_HOME');
fsmatlab = sprintf('%s/matlab',fshome);
path(path,pwd);

readleft=fullfile('interpolated_neurosynth_lh.csv');
readright=fullfile('interpolated_neurosynth_rh.csv');

datal=importdata(readleft);
%datal=datal.data;
datal=datal(8,1:10242)';
datar=importdata(readright);
%datar=datar.data;
datar=datar(8,1:10242)';

%faces are not used below, so not extract them.
[verticesl, ~] = freesurfer_read_surf(fullfile(fshome,'subjects/fsaverage5/surf/lh.pial'));
[verticesr, ~] = freesurfer_read_surf(fullfile(fshome,'subjects/fsaverage5/surf/rh.pial'));

% generate fake data where everything anterior is 500, everything superior  is 1000
% to see what this looks like w/o rotation, run plotting without running rotation


datal(verticesl(:,3) > 0) = 1000;
datal(verticesl(:,2) > 0) = 500;

datar(verticesr(:,3) > 0) = 1000;
datar(verticesr(:,2) > 0) = 500;




%%%color stuff%%%
custommap=colormap('jet');
%custommap=colormap('jet');
%custommap = flip(custommap, 1);
non0=[datal; datar];
mincol=min(non0);
maxcol=max(non0);


%rotate begin%

[verticesl, facesl] = freesurfer_read_surf(fullfile(fshome,'subjects/fsaverage5/surf/lh.sphere'));
[verticesr, facesr] = freesurfer_read_surf(fullfile(fshome,'subjects/fsaverage5/surf/rh.sphere'));

bl=verticesl;
br=verticesr;
rng(0);
%Use rng to initialize the random generator for reproducible results.
%I think it may be better to use a fixed angle like 90 instead of a random number
%to demonstrate how surfaces are rotated.
randx=rand(1) * 360;
randy=rand(1) * 360;
randz=rand(1) * 360;
%rotate along x axis, i.e. right-left
[R,~]=AxelRot(randx,[1,0,0]);%removed shift [0,0,0]
bl=bl*R;
[R,~]=AxelRot(randx,[1,0,0]);
br=br*R;
%rotate along y axis, i.e., anterior-posterior
[R,~]=AxelRot(randy,[0,1,0]);
bl=bl*R;
[R,~]=AxelRot(-randy,[0,1,0]);
br=br*R;
%rotate along z axis, i.e., superior-inferior
[R,~]=AxelRot(randz,[0,0,1]);
bl=bl*R;
[R,~]=AxelRot(-randz,[0,0,1]);
br=br*R;
distfun = @(a,b) sqrt(bsxfun(@minus,bsxfun(@plus,sum(a.^2,2),sum(b.^2,1)),2*(a*b)));
%The original 'dist' function is only available in neural network toolbox.
%I think you want to calculate Euclidian distance using 'dist',
%I wrote this 'distfun' to serve the same purpose with a faster performance.
distl=distfun(verticesl,bl');
distr=distfun(verticesr,br');

%replace the following codes for faster performance
[~, Il]=min(distl,[],2);
[~, Ir]=min(distr,[],2);
datal=datal(Il)';
datar=datar(Ir)';
% rotr=[];
% rotl=[];
% for i=1:10242
% indexl = find(distl(i,:) == min(distl(i,:)),1);
% indexr = find(distr(i,:) == min(distr(i,:)),1);
% rotr=[rotr, datar(indexr)];
% rotl=[rotl, datal(indexl)];
% end
% datal=rotl';
% datar=rotr';




%rotate end%


%plot

data=datal;

[vertices, faces] = freesurfer_read_surf(fullfile(fshome,'subjects/fsaverage5/surf/lh.pial'));

asub = subplot(3,2,1);
aplot = trisurf(faces, vertices(:,1), vertices(:,2), vertices(:,3),data);


%set(asub, 'position', [.3 0.5 .5 .5], 'Ztick', [ ], 'Xtick', [ ], 'Ytick', [ ])
view([90 0]);
%
colormap(custommap)
caxis([mincol; maxcol]);
%caxis([NAval; max_data])
daspect([1 1 1]);
axis tight;
axis vis3d off;
lighting gouraud; %phong; 
material metal %shiny %metal; 
shading flat;
camlight;
alpha(1)
%colormap(mycol)

title(plot_text)

%rotate around 
asub = subplot(3,2,3);
aplot = trisurf(faces, vertices(:,1), vertices(:,2), vertices(:,3),data);
%set(asub, 'position', [.3 0.25 .5 .5], 'Ztick', [ ], 'Xtick', [ ], 'Ytick', [ ])
view([90 0]);
rotate(aplot, [0 0 1], 180)
colormap(custommap)
caxis([mincol; maxcol]);
daspect([1 1 1]);
axis tight;
axis vis3d off;
lighting gouraud; %phong; 
material metal %shiny %metal; 
shading flat;
camlight;
alpha(1)
set(gcf,'Color','w')

asub = subplot(3,2,5);
aplot = trisurf(faces, vertices(:,1), vertices(:,2), vertices(:,3),data);
%set(asub, 'position', [.3 0 .5 .5], 'Ztick', [ ], 'Xtick', [ ], 'Ytick', [ ])
view([90 0]);
axis vis3d off;
rotate(aplot, [0 1 0], 270)
colormap(custommap)
caxis([mincol; maxcol]);
daspect([1 1 1]);
axis tight;
lighting gouraud; %phong; 
material metal %shiny %metal; 
shading flat;
camlight;
alpha(1)
set(gcf,'Color','w')


%%%%%%%%%right hem
data=datar;

[vertices, faces] = freesurfer_read_surf(fullfile(fshome,'subjects/fsaverage5/surf/rh.pial'));

asub = subplot(3,2,2);

aplot = trisurf(faces, vertices(:,1), vertices(:,2), vertices(:,3),data);


%set(asub, 'position', [.3 0.5 .5 .5], 'Ztick', [ ], 'Xtick', [ ], 'Ytick', [ ])
view([90 0]);
rotate(aplot, [0 0 1], 180)
colormap(custommap)
caxis([mincol; maxcol]);
%caxis([NAval; max_data])
daspect([1 1 1]);
axis tight;
axis vis3d off;
lighting gouraud; %phong; 
material metal %shiny %metal; 
shading flat;
camlight;
alpha(1)
%colormap(mycol)

asub = subplot(3,2,4);
aplot = trisurf(faces, vertices(:,1), vertices(:,2), vertices(:,3),data);
%set(asub, 'position', [.3 0.25 .5 .5], 'Ztick', [ ], 'Xtick', [ ], 'Ytick', [ ])
view([90 0]);
colormap(custommap)
caxis([mincol; maxcol]);
daspect([1 1 1]);
axis tight;
axis vis3d off;
lighting gouraud; %phong; 
material metal %shiny %metal; 
shading flat;
camlight;
alpha(1)
set(gcf,'Color','w')

asub = subplot(3,2,6);
aplot = trisurf(faces, vertices(:,1), vertices(:,2), vertices(:,3),data);
%set(asub, 'position', [.3 0 .5 .5], 'Ztick', [ ], 'Xtick', [ ], 'Ytick', [ ])
view([90 0]);
axis vis3d off;
rotate(aplot, [0 1 0], 270)
rotate(aplot, [1 0 0], 180)
colormap(custommap)
caxis([mincol; maxcol]);
daspect([1 1 1]);
axis tight;
lighting gouraud; %phong; 
material metal %shiny %metal; 
shading flat;
camlight;
alpha(1)
set(gcf,'Color','w')

acbar = colorbar('WestOutside');
set(acbar, 'position', [0.5 0.1100 0.0314 0.2157]);
print('-dpdf',[name 'fsave5_fsmatplot'])
%I removed resolution -r600, when using it, output is empty

