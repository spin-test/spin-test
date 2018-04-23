% Spin CIVET surface for Kirk

%Clear work space
clear variables
%read Kirk's data
filename='rawdata.csv';
temp=readtable(filename);%,'ReadVariableNames',false
data=temp.nih_bi;
%this can be used for contiuous as well, just change it to
%nih_c
mask=temp.mask;% use mask to remove the medial wall
data(mask==0)=100;%put all medial wall into 100s to diff from hypo 0s.

%close all
%Set up paths for codes to work
% Replace the following path with the path to the SOBP_neurosynth2 folder
filepath = 'SurfStat';
%this requires toolbox SurfStat, download it (provided here) and set its folder to this filepath 
%http://www.bic.mni.mcgill.ca/ServicesSoftware/StatisticalAnalysesUsingSurfstatMatlab
path(path,filepath);
rng(0);
%Use rng to initialize the random generator for reproducible results.

filename='sphere.obj';
%Read it from SurfStat, this is the sphere projection of CIVET pial surface
% As it is completely symetrical between left and right, this sphere only includes
% one side.
change_parcer_lh=data(1:40962);
[surf ab] = SurfStatReadSurf(filename);%read this sphere
verticesl=surf.coord'; verticesr=surf.coord';
writetable(table(cat(2,verticesl,verticesr)'),['sphere_coordinates.csv'],...
    'WriteVariableNames',false,'Delimiter',',','QuoteStrings',true)
%as you asked, write sphere coordinates into a csv file. 

datal=data(1:40962);% assign left hemisphere to spin
datar=data(40963:end); % right hemisphere 
rng(0);
%Use rng to initialize the random generator for reproducible results.
bigrotl=[];
bigrotr=[];
%initialize where to save the spinning results
distfun = @(a,b) sqrt(bsxfun(@minus,bsxfun(@plus,sum(a.^2,2),sum(b.^2,1)),2*(a*b)));
%I wrote a distfun to replace 'dist' function to calculate Euclidian distance
% so not need to use the neural network toolbox which is required by 'dist'.
%And this is faster than 'dist'.
permno=1000;%permutation number

%% NOte: this version spin only left, flip the rotation matrix to the right.
% so the left and right are spun symmetrically.
    for j=1:permno
        j
        randx=rand(1) * 360;
        randy=rand(1) * 360;
        randz=rand(1) * 360;
        
        [R,~]=AxelRot(randx,[1,0,0]);
        %use AxelRot to rotate the sphere around 3 axis
        %AxelRot is downloaded from and provided here
        %https://www.mathworks.com/matlabcentral/fileexchange/30864-3d-rotation-about-shifted-axis
        bl=verticesl*R;
        [R,~]=AxelRot(randy,[0,1,0]);
        bl=bl*R;
        [R,~]=AxelRot(randz,[0,0,1]);
        bl=bl*R;
        %find a match btw spun and original vertex using the nearest
        %neighbour method
        distl=distfun(verticesl,bl');
        %Save values
        bigrotl=[bigrotl; datal(Il)'];
        bigrotr=[bigrotr; datar(Il)'];
    end


save('rotation_nih_bi_spin2.mat','bigrotl','bigrotr')
%save into a workspace file

writetable(table(cat(2,bigrotl,bigrotr)'),['nih_bi_spin2.csv'],...
    'WriteVariableNames',false,'Delimiter',',','QuoteStrings',true)
% Output it to a csv file.

