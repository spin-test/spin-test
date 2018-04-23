%AAB 29 May 2017 adapted from code written Summer, 2015
%mni_getmesha and sphere obj from www.stat.wisc.edu/~mchung/softwares/hk/
%for illustration purposes, load aal_civet.mat from http://mgui.wikidot.com/mgui-neuro-civet-matlab

%Clear work space
clear variables
filename='rawdata.csv';
temp=readtable(filename);%,'ReadVariableNames',false
% filename = 'rawdata.xlsx';%'ABAassociation_correlationOHBM.xlsx';
% temp=readtable(filename,'sheet','rawdata');
data=temp.nih_bi;%pnc_bi nih_c 
mask=temp.mask;
data(mask==0)=100;

%close all
%Set up paths
% Replace the following path with the path to the SOBP_neurosynth2 folder
filepath = '/working/SA/group/SOBP_neurosynth 2/SOBP_neurosynth 2/scripts/SurfStat';
fshome = getenv('FREESURFER_HOME');
fsmatlab = sprintf('%s/matlab',fshome);
%also requires freesurfer matlab toolbox, you can find it under your
%freesurfer home directory
path(path,fsmatlab);
path(path,filepath);
filepath2 = '/working/SA/group/SOBP_neurosynth 2/SOBP_neurosynth 2/scripts';
path(path,filepath2);
rng(0);
%Use rng to initialize the random generator for reproducible results.

%filename='00205tc/surfaces/nih_chp_00205tc_gray_surface.obj';
%filename='00205tc/surfaces/nih_chp_00205tc_gray_surface_left_81920.obj';
%change_parcer_lh=aal_labels;
filename='sphere.obj';%SurfStat/
change_parcer_lh=data(1:40962);
[surf ab] = SurfStatReadSurf(filename);%better than mni_getmesh 
verticesl=surf.coord'; verticesr=surf.coord';
%[asphere,bsphere,csphere,dsphere]=mni_getmesh(filename);

%test writing sphere.obj out, works
% surf.tri=a; surf.coord=b;
% filename='sphere_test.obj';
% SurfStatWriteSurf( filename, surf, ab );

% writetable(table(cat(2,verticesl,verticesr)'),['sphere_coordinates.csv'],...
%     'WriteVariableNames',false,'Delimiter',',','QuoteStrings',true)

datal=data(1:40962);% lh for term depression
datar=data(40963:end); % =datal to exam rotx -y -z % rh for term depression
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

%% compared to 1 (spin right), this version spin only left, flip to right. 
tic
    for j=1:permno
        j
        randx=rand(1) * 360;
        randy=rand(1) * 360;
        randz=rand(1) * 360;
        
        [R,~]=AxelRot(randx,[1,0,0]);%removed shift [0,0,0]
        bl=verticesl*R;
%         [R,~]=AxelRot(randx,[1,0,0]);
%         br=verticesr*R;
        [R,~]=AxelRot(randy,[0,1,0]);
        bl=bl*R;
%         [R,~]=AxelRot(-randy,[0,1,0]);
%         br=br*R;
        [R,~]=AxelRot(randz,[0,0,1]);
        bl=bl*R;
%         [R,~]=AxelRot(-randz,[0,0,1]);
%         br=br*R;
        
        distl=distfun(verticesl,bl');
%         distr=distfun(verticesr,br');
        %replaced the loop with the following commands to reduce computation
        %time about five folds
        [~, Il]=min(distl,[],2);
%         [~, Ir]=min(distr,[],2);
        bigrotl=[bigrotl; datal(Il)'];
        bigrotr=[bigrotr; datar(Il)'];
        
%        
%         randx=rand(1) * 360;
%         randy=rand(1) * 360;
%         randz=rand(1) * 360;
%         
%         [R,~]=AxelRot(randx,[1,0,0]);%removed shift [0,0,0]
%         bl=verticesl*R;
%         [R,~]=AxelRot(randx,[1,0,0]);
%         br=verticesr*R;
%         [R,~]=AxelRot(randy,[0,1,0]);
%         bl=bl*R;
%         [R,~]=AxelRot(-randy,[0,1,0]);
%         br=br*R;
%         [R,~]=AxelRot(randz,[0,0,1]);
%         bl=bl*R;
%         [R,~]=AxelRot(-randz,[0,0,1]);
%         br=br*R;
%         
% %         distl=dist(verticesl,bl');
% %         distr=dist(verticesr,br');
%        % original way 
% %         distl=distfun(verticesl,bl');
% %         distr=distfun(verticesr,br');
% %         %replaced the loop with the following commands to reduce computation
% %         %time about five folds
% %         [~, Il]=min(distl,[],2);
% %         [~, Ir]=min(distr,[],2);
%         Il=[];Ir=[];distl=[];distr=[];
%         for k=1:163
%            % k
%         distl=distfun(verticesl((k-1)*1000+1:k*1000,:),bl');
%         distr=distfun(verticesr((k-1)*1000+1:k*1000,:),br');
%         %replaced the loop with the following commands to reduce computation
%         %time about five folds
%         [~, Ils]=min(distl,[],2);
%         [~, Irs]=min(distr,[],2);
%         Il=[Il; Ils];
%         Ir=[Ir; Irs];
%         end
%         distl=[];distr=[];Ils=[];Irs=[];
%         distl=distfun(verticesl(k*1000+1:163842,:),bl');
%         distr=distfun(verticesr(k*1000+1:163842,:),br');
%         %replaced the loop with the following commands to reduce computation
%         %time about five folds
%         [~, Ils]=min(distl,[],2);
%         [~, Irs]=min(distr,[],2);
%         Il=[Il; Ils];
%         Ir=[Ir; Irs];
%         
%         bigrotl=[bigrotl; datal(Il)'];
%         bigrotr=[bigrotr; datar(Ir)'];
%         write_annotation(['lh.500.' num2str(j+400) '.aparc.annot'],Vl, datal(Il), ctl);
%         write_annotation(['rh.500.' num2str(j+400) '.aparc.annot'],Vr, datar(Ir), ctr);

    end

toc
save('rotation_nih_bi_spin2.mat','bigrotl','bigrotr')

writetable(table(cat(2,bigrotl,bigrotr)'),['nih_bi_spin2.csv'],...
    'WriteVariableNames',false,'Delimiter',',','QuoteStrings',true)
% dlmwrite(['pnc_bi_spin2.txt'],cat(2,bigrotl,bigrotr)','delimiter',',')
%save bigrotl and bigrotr for statistics.m



% filename='surf_reg_model_left.obj';%SurfStat/
% [surfl ab] = SurfStatReadSurf(filename);%better than mni_getmesh 
% custommap=colormap('jet');
% mincol=min(datal);
% maxcol=max(datal);
% figure,plotsurf_CIVET(surfl.tri,surfl.coord,datal,custommap,mincol,maxcol)
% 
% 
% filename='surf_reg_model_right.obj';%SurfStat/
% [surfr ab] = SurfStatReadSurf(filename);%better than mni_getmesh 
% mincol=min(datar);
% maxcol=max(datar);
% figure,plotsurf_CIVET(surfr.tri,surfr.coord,datar,custommap,mincol,maxcol)

% figure,plotsurf_CIVET(surfl.tri,surfl.coord,datal(Il),custommap,mincol,1)
% figure,plotsurf_CIVET(surfr.tri,surfr.coord,datar(Il),custommap,mincol,1)


