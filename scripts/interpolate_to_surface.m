%For each term, project their volume maps to white surface in fsaverage5
%Clear work space
clear variables
close all
%Set up paths 
% Replace the following path with the path to the SOBP_neurosynth2 folder
filepath = '/working/SA/group/SOBP_neurosynth 2/SOBP_neurosynth 2';
fshome = getenv('FREESURFER_HOME');
fsmatlab = sprintf('%s/matlab',fshome);
path(path,pwd);
%faces are not used below, so not extract them.
%I know white surface is default surface used by surf2vol in FreeSurfer. I
%am just curious why pial surface is not used. I guess the results would be
%similar.
[lhvertices, ~] = freesurfer_read_surf(fullfile(fshome,'subjects/fsaverage5/surf/lh.white'));
[rhvertices, ~] = freesurfer_read_surf(fullfile(fshome,'subjects/fsaverage5/surf/rh.white'));


biglh=[];
bigrh=[];
names=[];
files = dir(fullfile(filepath,'volumes/*.nii'));
for file = files'
    file.name
    a= regexp(file.name, '_', 'split');
    names=[names a(1)];
    hdr = load_nifti(fullfile(filepath,'volumes',file.name));
    lhvox=[];
    rhvox=[];
    for i=1:10242
        lh=lhvertices(i,:);
        a=round(inv(hdr.vox2ras)*[lh 1]');
        a(1:3)=a(1:3)+a(4); %indexing issue
        lhvox=[lhvox, hdr.vol(a(1), a(2), a(3))];
        % I am not sure I understand why you handled rh differently as you did lh
        % It seems that you select the max of interpolated values in neighbours
        % instead of directly extract the value.
        rh=rhvertices(i,:);
        a=round(inv(hdr.vox2ras)*[rh 1]');
        a(1:3)=a(1:3)+a(4); %indexing issue
        b=sign(a-(inv(hdr.vox2ras)*[rh 1]'));
        options=[hdr.vol(a(1), a(2), a(3)); hdr.vol(a(1) - b(1), a(2), a(3)); hdr.vol(a(1) , a(2) - b(2), a(3)); hdr.vol(a(1) - b(1), a(2), a(3)- b(3))]; %most active vertex in neighborhood
        rhvox=[rhvox, max(options)];
    end
    
    biglh=[biglh; lhvox];
    bigrh=[bigrh; rhvox];
    
end

%%%%SOME COMMENTS%%%%
%#a=inv(hdr.vox2ras)*[mnix mnyi mniz 1]; give you voxel estimate
%a=round(a); gives you real voxel
%
%hdr.vol(a(1), a(2), a(3)) and you're golden


csvwrite(fullfile(filepath,'surfaces','interpolated_neurosynth_lh.csv'), biglh)
csvwrite(fullfile(filepath,'surfaces','interpolated_neurosynth_rh.csv'), bigrh)
writetable(cell2table(names),fullfile(filepath,'surfaces','terms.csv'));
%Using the above line, I replaced csvwrite('../surfaces/terms.csv', names), 
%which does not handle text cell well.
bigcor = corr([biglh, bigrh]');

csvwrite('../surfaces/mapcor.csv', bigcor)
% I am not sure why correlation values calculated here are different with mapcor.csv you sent.
% I tried load lh and rh from csv files you sent and calculated correlation
% values. The results matched results directly calculated from this code but did not match
% mapcor.csv you sent either. The results calculated directly from this code matched what you described 
% in the abstract. 
save('biglhrh.mat','biglh','bigrh');
%save biglh and bigrh for statistics.m




