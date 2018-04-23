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
path(path,fsmatlab);
filepath = 'SurfStat';
path(path,filepath);

readleft=fullfile('interpolated_neurosynth_lh.csv');
readright=fullfile('interpolated_neurosynth_rh.csv');

datal=importdata(readleft);
datar=importdata(readright);

%L=datal(5,1:10242)'; R=datar(5,1:10242)';%depression
L=datal(11,1:10242)'; R=datar(11,1:10242)';%ptsd
%*********
[verticesl, facesl] = freesurfer_read_surf(fullfile(fshome,'subjects/fsaverage5/surf/lh.pial'));
[verticesr, facesr] = freesurfer_read_surf(fullfile(fshome,'subjects/fsaverage5/surf/rh.pial'));

XYZl_FS=verticesl';
XYZr_FS=verticesr';

custommap=colormap('jet');
mincol=min(L);
maxcol=max(L);
figure,plotsurf_L(facesl,verticesl,L,custommap,mincol,maxcol)


mincol=min(R);
maxcol=max(R);
figure,plotsurf_R(facesr,verticesr,R,custommap,mincol,maxcol)

%% Read CIVET coordinates
filename='surf_reg_model_left.obj';
[surfL ab] = SurfStatReadSurf(filename);%better than mni_getmesh 
filename='surf_reg_model_right.obj';
[surfR ab] = SurfStatReadSurf(filename);%better than mni_getmesh 
%XYZ=cat(2,surfL.coord,surfR.coord);
XYZl=surfL.coord; XYZr=surfR.coord;

%left
newL=zeros(1,40962);
idx = nearestneighbour(XYZl, XYZl_FS,'Radius',10,'NumberOfNeighbours', 1);
neidx=idx;
neidx(neidx==0)=[];
newL(idx~=0)=L(neidx);

idx(idx~=0)=1;
datal=[];
datal(1,:)=idx;
datal(2,:)=newL;



%right
newR=zeros(1,40962);
idx = nearestneighbour(XYZr, XYZr_FS,'Radius',10,'NumberOfNeighbours', 1);
neidx=idx;
neidx(neidx==0)=[];
newR(idx~=0)=R(neidx);

idx(idx~=0)=1;
datar=[];
datar(1,:)=idx;
datar(2,:)=newR;

custommap=colormap('jet');
mincol=min(newL);
maxcol=max(newL);
figure,plotsurf_CIVET_L(surfL.tri,surfL.coord,newL,custommap,mincol,maxcol)

mincol=min(newR);
maxcol=max(newR);
figure,plotsurf_CIVET_R(surfR.tri,surfR.coord,newR,custommap,mincol,maxcol)



% writetable(table(newL'),'depressionCIVETdataL.csv',...
%        'Delimiter',',','QuoteStrings',true,'writeVariableNames',false)
% writetable(table(newR'),'depressionCIVETdataR.csv',...
%        'Delimiter',',','QuoteStrings',true,'writeVariableNames',false)
   
writetable(table(newL'),'ptsdCIVETdataL.csv',...
       'Delimiter',',','QuoteStrings',true,'writeVariableNames',false)
writetable(table(newR'),'ptsdCIVETdataR.csv',...
       'Delimiter',',','QuoteStrings',true,'writeVariableNames',false)
   
   
writetable(table(datal(5,1:10242)'),'depressionFSdataL.csv',...
       'Delimiter',',','QuoteStrings',true,'writeVariableNames',false)
writetable(table(datar(5,1:10242)'),'depressionFSdataR.csv',...
       'Delimiter',',','QuoteStrings',true,'writeVariableNames',false)

writetable(table(datal(11,1:10242)'),'ptsdFSdataL.csv',...
       'Delimiter',',','QuoteStrings',true,'writeVariableNames',false)
writetable(table(datar(11,1:10242)'),'ptsdFSdataR.csv',...
       'Delimiter',',','QuoteStrings',true,'writeVariableNames',false)

readleft=fullfile('interpolated_neurosynth_lh.csv');
readright=fullfile('interpolated_neurosynth_rh.csv');

datal=importdata(readleft);
%datal=datal.data;
datal=datal(8,1:10242)';
datar=importdata(readright);
%datar=datar.data;
datar=datar(8,1:10242)';



%% Read FS 310 parcellation
% filename='lh.500.aparc.annot';
% %read annot file
% [Vl, L, ctl] = read_annotation(filename);
% filename='rh.500.aparc.annot';
% [Vr, R, ctr] = read_annotation(filename);


%extract the vertice coordinates from the correspoding surface for display.
[verticesl, ~] = freesurfer_read_surf(fullfile(fshome,'subjects/fsaverage5/surf/lh.pial'));
[verticesr, ~] = freesurfer_read_surf(fullfile(fshome,'subjects/fsaverage5/surf/rh.pial'));


% generate fake data where everything anterior is 500, everything superior  is 1000
% to see what this looks like w/o rotation, run plotting without running rotation


datal(verticesl(:,3) > 0) = 1000;
datal(verticesl(:,2) > 0) = 500;

datar(verticesr(:,3) > 0) = 1000;
datar(verticesr(:,2) > 0) = 500;

writetable(table(datal),'fakeFSdataL.csv',...
       'Delimiter',',','QuoteStrings',true,'writeVariableNames',false)
writetable(table(datar),'fakeFSdataR.csv',...
       'Delimiter',',','QuoteStrings',true,'writeVariableNames',false)



