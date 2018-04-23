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
%permutation/spin starts
% Since left-right is symmetric, spin only left, flip the rotation to right.
for j=1:permno
    j
    %set up the randome degrees to rotate
    randx=rand(1) * 360;
    randy=rand(1) * 360;
    randz=rand(1) * 360;
    %rotate
    [R,~]=AxelRot(randx,[1,0,0]);
    bl=verticesl*R;
    [R,~]=AxelRot(randy,[0,1,0]);
    bl=bl*R;
    [R,~]=AxelRot(randz,[0,0,1]);
    bl=bl*R;
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
