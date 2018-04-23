%%%% this creates 1000 spins of term depression (5)
% This scirpt creates spins for a specific term. Have you considered to
% generate generic spins for all terms, that is, spin-vertex-indexes to
% original-vertex-indexes? That would require only one run of this program
% for all terms. 

%Clear work space
clear variables
close all
%Set up paths
% Replace the following path with the path to the SOBP_neurosynth2 folder
filepath = '/working/SA/group/SOBP_neurosynth 2/SOBP_neurosynth 2';
fshome = getenv('FREESURFER_HOME');
fsmatlab = sprintf('%s/matlab',fshome);
path(path,pwd);

name='depression';
plot_text='depression';
readleft=['interpolated_neurosynth_lh.csv'];
readright=['interpolated_neurosynth_rh.csv'];
%faces are not used below, so not extract them.
[verticesl, ~] = freesurfer_read_surf(fullfile(fshome,'subjects/fsaverage5/surf/lh.sphere'));
[verticesr, ~] = freesurfer_read_surf(fullfile(fshome,'subjects/fsaverage5/surf/rh.sphere'));
datal=importdata(fullfile(filepath,'surfaces',readleft));
%datal=datal.data;
datal=datal(5,1:10242)';% lh for term depression 
datar=importdata(fullfile(filepath,'surfaces',readright));
%datar=datar.data;
datar=datar(5,1:10242)'; % rh for term depression
rng(0);
%Use rng to initialize the random generator for reproducible results.
bigrotl=[];
bigrotr=[];
distfun = @(a,b) sqrt(bsxfun(@minus,bsxfun(@plus,sum(a.^2,2),sum(b.^2,1)),2*(a*b)));
%The original 'dist' function is only available in neural network toolbox.
%I think you want to calculate Euclidian distance using 'dist',
%I wrote this 'distfun' to serve the same purpose.
permno=1000;%permutation number
%I optimized the following codes to make it faster.
%Examine if parallel computing toolbox is installed. 
%If so, par loop will be used to shorten computation time.
%Otherwise, just use plain loops.
tic
if license('test','Distrib_Computing_Toolbox') 
parfor_progress(permno);
parfor j=1:permno
    randx=rand(1) * 360;
    randy=rand(1) * 360;
    randz=rand(1) * 360;
    
    [R,~]=AxelRot(randx,[1,0,0]);%removed shift [0,0,0]
    bl=verticesl*R;
    [R,~]=AxelRot(randx,[1,0,0]);
    br=verticesr*R;
    [R,~]=AxelRot(randy,[0,1,0]);
    bl=bl*R;
    [R,~]=AxelRot(-randy,[0,1,0]);
    br=br*R;
    [R,~]=AxelRot(randz,[0,0,1]);
    bl=bl*R;
    [R,~]=AxelRot(-randz,[0,0,1]);
    br=br*R;
    

    
    distl=distfun(verticesl,bl');
    distr=distfun(verticesr,br');
    %replaced the loop with the following commands to reduce computation
    %time about five folds
    [~, Il]=min(distl,[],2);
    [~, Ir]=min(distr,[],2);
    bigrotl=[bigrotl; datal(Il)'];
    bigrotr=[bigrotr; datar(Ir)'];
%     rotr=[];
%     rotl=[];
%     for i=1:10242
%         indexl = find(distl(i,:) == min(distl(i,:)),1);
%         indexr = find(distr(i,:) == min(distr(i,:)),1);
%         rotr=[rotr, datar(indexr)];
%         rotl=[rotl, datal(indexl)];
%     end
%     
    
%     bigrotl=[bigrotl; rotl];
%     bigrotr=[bigrotr; rotr];
parfor_progress;
end


else 
    for j=1:permno
    j
    randx=rand(1) * 360;
    randy=rand(1) * 360;
    randz=rand(1) * 360;
    
    [R,~]=AxelRot(randx,[1,0,0]);%removed shift [0,0,0]
    bl=verticesl*R;
    [R,~]=AxelRot(randx,[1,0,0]);
    br=verticesr*R;
    [R,~]=AxelRot(randy,[0,1,0]);
    bl=bl*R;
    [R,~]=AxelRot(-randy,[0,1,0]);
    br=br*R;
    [R,~]=AxelRot(randz,[0,0,1]);
    bl=bl*R;
    [R,~]=AxelRot(-randz,[0,0,1]);
    br=br*R;
    
    distl=distfun(verticesl,bl');
    distr=distfun(verticesr,br');
%replaced the loop with the following commands to reduce computation
    %time about five folds
    [~, Il]=min(distl,[],2);
    [~, Ir]=min(distr,[],2);
    bigrotl=[bigrotl; datal(Il)'];
    bigrotr=[bigrotr; datar(Ir)'];
%     rotr=[];
%     rotl=[];
%     for i=1:10242
%         indexl = find(distl(i,:) == min(distl(i,:)),1);
%         indexr = find(distr(i,:) == min(distr(i,:)),1);
%         rotr=[rotr, datar(indexr)];
%         rotl=[rotl, datal(indexl)];
%     end
%     
    
%     bigrotl=[bigrotl; rotl];
%     bigrotr=[bigrotr; rotr];
    end
end
toc
save('rotation.mat','bigrotl','bigrotr')
%save bigrotl and bigrotr for statistics.m