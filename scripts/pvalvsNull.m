function pval=pvalvsNull(readleft1,readright1,readleft2,readright2,permno,wsname, v_exclude_left, v_exclude_right)
% Calculate the p-value of correlation between two surface maps based on
% the null distribution of spins of map 1
% FORMAT pvalvsNull(readleft1,readright1,readleft2,readright2,permno,wsname)
% readleft1     - the filename of the first left surface data to spin 
% readright1    - the filename of the first right surface data to spin 
% readleft2     - the filename of the second left surface data to spin 
% readright2    - the filename of the second right surface data to spin 
% permno       - the number of permutations used in SpinPermuFS/CIVET
% wsname       - the name of a workspace file output from SpinPermuFS/CIVET
% pval         - the calculated p-value
% Added 07/31/2020 (SMW): indicate vertices to exclude (e.g., medial wall)
% v_exclude_left  - left hemisphere vertices to exclude (indicate with 1)
% v_exclude_right - right hemisphere vertices to exclude (indicate with 1)
% Example   p=pvalvsNull('../data/depressionFSdataL.csv','../data/depressionFSdataR.csv','../data/ptsdFSdataL.csv','../data/ptsdFSdataR.csv',100,'../data/rotationFS.mat')
% will calculate the pvalue of correlation between prebuilt data, neurosynth map associated with 'depression',
% and 'PTSD' using the null distribution of depression maps spun 100 times
% from the SpinPermuFS.m
% Simiarly, it can be used for CIVET version as well.
% Aaron Alexander-Bloch & Siyuan Liu 
% pvalvsNull.m, 2018-04-22

%load the saved workspace from SpinPermu
load(wsname)

%read the data saved in csv and merge left and right surfaces into one
datal1=importdata(readleft1); datal1 = datal1.data(); % .data() part may or may not be needed
datar1=importdata(readright1); datar1 = datar1.data();
datal2=importdata(readleft2); datal2 = datal2.data();
datar2=importdata(readright2); datar2 = datar2.data();

% Label medial wall vertices with NaN (07/31/2020):
datal1(v_exclude_left) = NaN;
datal2(v_exclude_left) = NaN;
datar1(v_exclude_right) = NaN;
datar2(v_exclude_right) = NaN;

data1=cat(1,datal1,datar1);
data2=cat(1,datal2,datar2);
%calculate the real Pearson's correlation between two interested maps

realrho=corr(data1,data2, 'rows','complete'); % 'rows','complete' to exclude NaN's
 
% test the observed rho against null described by SpinPermu
nullrho=[];
for i=1:permno
tempdata=cat(2,bigrotl(i,:),bigrotr(i,:))';
nullrho=cat(1,nullrho,corr(tempdata,data2, 'rows','complete')); % 'rows','complete' to exclude NaN's
end
%assuming sign is preserved, calculate the probability that the observed
%correlation coeffcient is above the null distribution
pval=length(find(abs(nullrho)>abs(realrho)))/permno; % added abs() 07/31/2020
