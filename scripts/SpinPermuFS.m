function SpinPermuFS(readleft,readright,permno,wsname)
% Compute designated # of permutations/spins of the input surface data
% in FreeSurfer fsaverage5.
% FORMAT SpinPermuFS(readleft,readright,permno)
% readleft     - the filename of left surface data to spin 
% readright    - the filename of right surface data to spin 
% permno       - the number of permutations
% wsname       - the name of a workspace file including all spun data to be saved
% Example   SpinPermuFS('../data/depressionFSdataL.csv','../data/depressionFSdataR.csv',100,'../data/rotationFS.mat')
% will spin prebuilt data, neurosynth map associated with 'depression', 100
% times, and save the workspace file of all spun data in ../data/rotationFS.mat
% Aaron Alexander-Bloch & Siyuan Liu 
% SpinPermuFS.m, 2018-04-22
% The implementation of generating random rotations originally described in our paper — 
% rotating the coordinates of vertices at angles uniformly chosen between zero and 360 degrees
% about each of the x (left-right), y (anterior-posterior) and z (superior-inferior) axes —
% introduces a preference towards oversampling certain rotations. 
% Thus, we modified the code to incorporate an approach, Lefèvre et al. (2018), 
% that samples uniformly from the space of possible rotations. The updated
% uniform sampling prodcedure does not require AxelRot.m anymore.
% Updated on 2018-07-18
% Update 07/31/2020 (SMW): will automatically remove medial wall for
% fsaverage5. may need to change if not fsaverage5 (10242 vertices per
% hemisphere)


%Set up paths
fshome = getenv('FREESURFER_HOME');
fsmatlab = sprintf('%s/matlab',fshome);
path(path,fsmatlab);
%read the data saved in csv
datal=importdata(readleft); datal = datal.data(); % .data() part may or may not be needed
datar=importdata(readright);datar = datar.data(); % .data() part may or may not be needed
%For an annotation file, please used the following command to load the data
% [Vl, dataL, ctl] = read_annotation(readleft);
% [Vr, dataR, ctr] = read_annotation(readright);

%If there is a mask,e.g. median wall, to be excluded, use the following
%command to assign vertices in this mask with a special value out of the
%real range, e.g. 100 here, to mark these vertices and exclude them later
%in pvalvsNull.m
% leftmask=importdata(readleftmask);
% datal(leftmask==1)=100;
% rightmask=importdata(readrightmask);
% datar(rightmask==1)=100;

% Added 07/31/2020

% Exclude the medial wall by labeling those vertices with NaN: 
%   Note: in the lh(rh).aparc.a2009s.annot for fsaverage5 data, 1644825 is
%   the label of vertices in the medial wall. Assign those vertices to NaN

% left:
[vl, left_labels, ctl] = read_annotation(fullfile(fshome,'/subjects/fsaverage5/label/lh.aparc.a2009s.annot'));
datal(left_labels==1644825)=NaN;

% right:
[vr,right_labels,ctr] = read_annotation(fullfile(fshome,'/subjects/fsaverage5/label/rh.aparc.a2009s.annot'));
datar(right_labels==1644825)=NaN;

%%extract the corresponding sphere surface coordinates for rotation
[verticesl, ~] = freesurfer_read_surf(fullfile(fshome,'subjects/fsaverage5/surf/lh.sphere'));
[verticesr, ~] = freesurfer_read_surf(fullfile(fshome,'subjects/fsaverage5/surf/rh.sphere'));


rng(0);
%Use rng to initialize the random generator for reproducible results.
%initialize variables to save rotation
bigrotl=[];
bigrotr=[];
%distfun = @(a,b) sqrt(bsxfun(@minus,bsxfun(@plus,sum(a.^2,2),sum(b.^2,1)),2*(a*b)));
%function to calculate Euclidian distance, deprecated 2019-06-18 see home page
I1 = eye(3,3);
I1(1,1)=-1;
bl=verticesl;
br=verticesr;
%permutation starts
for j=1:permno
    j
    %the updated uniform sampling procedure
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
    
    %Find the pair of matched vertices with the min distance and reassign
    %values to the rotated surface.
    %distl=distfun(verticesl,bl'); % deprecated 2019-06-18 see home page
    %distr=distfun(verticesr,br'); % deprecated 2019-06-18 see home page
    %[~, Il]=min(distl,[],2); % deprecated 2019-06-18 see home page
    %[~, Ir]=min(distr,[],2); % deprecated 2019-06-18 see home page
    Il = nearestneighbour(verticesl', bl'); % added 2019-06-18 see home page
    Ir = nearestneighbour(verticesr', br'); % added 2019-06-18 see home page

    %save rotated data
    bigrotl=[bigrotl; datal(Il)'];
    bigrotr=[bigrotr; datar(Ir)'];
    % it is also feasible to save Il Ir and apply them to different datasets
    % for repeated use
    %If annotation file is used, annotation file for each rotation could be
    %saved by write_annotation.m of FreeSurfer
end
save(wsname,'bigrotl','bigrotr')
%save bigrotl and bigrotr in a workspace file for the null distribution
%use it in pvalvsNull.m to caclulate pvalue
