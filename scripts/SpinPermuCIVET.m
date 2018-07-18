function SpinPermuCIVET(readleft,readright,permno,wsname)
% Compute designated # of permutations/spins of the input surface data
% in CIVET.
% FORMAT SpinPermuFS(readleft,readright,permno)
% readleft     - the filename of left surface data to spin
% readright    - the filename of right surface data to spin
% permno       - the number of permutations
% wsname       - the name of a workspace file including all spun data to be saved
% Example   SpinPermuCIVET('../data/depressionCIVETdataL.csv','../data/depressionCIVETdataR.csv',100,'../data/rotationCIVET.mat')
% will spin prebuilt data, neurosynth map associated with 'depression', 100
% times, and save the workspace file of all spun data in ../data/rotationFS.mat
% This code requires SurfStat toolbox (included here),
%from http://www.bic.mni.mcgill.ca/ServicesSoftware/StatisticalAnalysesUsingSurfstatMatlab
% Aaron Alexander-Bloch & Siyuan Liu
% SpinPermuCIVET.m, 2018-04-22
% The implementation of generating random rotations originally described in our paper — 
% rotating the coordinates of vertices at angles uniformly chosen between zero and 360 degrees
% about each of the x (left-right), y (anterior-posterior) and z (superior-inferior) axes —
% introduces a preference towards oversampling certain rotations. 
% Thus, we modified the code to incorporate an approach, Lefèvre et al. (2018), 
% that samples uniformly from the space of possible rotations. The updated
% uniform sampling prodcedure does not require AxelRot.m anymore.
% Updated on 2018-07-18

%Set up paths
filepath = 'SurfStat';
path(path,filepath);

%read the data saved in csv
datal=importdata(readleft);
datar=importdata(readright);

%read sphere surface coordinates using SurfStat
%In CIVET, left-right is perfectly symmetric, this surface is the same to
%both hemispheres.
filename='sphere.obj';
[surf ab] = SurfStatReadSurf(filename);
verticesl=surf.coord'; verticesr=surf.coord';


rng(0);
%Use rng to initialize the random generator for reproducible results.
bigrotl=[];
bigrotr=[];
distfun = @(a,b) sqrt(bsxfun(@minus,bsxfun(@plus,sum(a.^2,2),sum(b.^2,1)),2*(a*b)));
%function to calculate Euclidian distance
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
    distl=distfun(verticesl,bl');
    [~, Il]=min(distl,[],2);
    %save rotated data
    bigrotl=[bigrotl; datal(Il)'];
    bigrotr=[bigrotr; datar(Il)'];
    % it is also feasible to save Il Ir and apply them to different datasets
    % for repeated use
end
save(wsname,'bigrotl','bigrotr')
%save bigrotl and bigrotr in a workspace file for the null distribution
%use it in pvalvsNull.m to caclulate pvalue
