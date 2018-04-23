%%Choosing working directory
cd ~/surfstat

clear all; close all;

%Load surfs
surf = SurfStatReadSurf({'~/surfstat/CIVET_2.0_icbm_avg_mid_sym_mc_left.obj' '~/surfstat/CIVET_2.0_icbm_avg_mid_sym_mc_right.obj'}); 

%Adding the midline mask
mask_left = SurfStatReadData({'~/surfstat/CIVET_2.0_mask_left.txt'});
mask_left = mask_left(1:40962);     %downsampling to lores
mask_right = SurfStatReadData({'~/surfstat/CIVET_2.0_mask_right.txt'});
mask_right = mask_right(1:40962);   %downsampling to lores
mask = [mask_left,mask_right];
mask=logical(mask);

%Creating the matrix of data.
[id, testtime, group, age, ThickFileLeft, ThickFileRight]=textread('/home/llewis/surfstat/glimfiles/tetris_glim.csv', ' %s %s %s %f %s %s');    %textread does not understand ~, so type in your entire path

%To read and assign the actual thickness data
T1 = SurfStatReadData( [ThickFileLeft] );
T2 = SurfStatReadData( [ThickFileRight] );
T3 = horzcat(T1, T2);

%Create terms
TestTime = term (testtime);
Group = term (group);
Age = term (age);
%age_normalized = (age-mean(age))/std(age);  %if you want to normalize age
%Age = term(age_normalized);  %if you want to normalize age

%% MEANS & STDS

%Mean cortical thickness for all
figure
SurfStatView( mean(T3).*mask, surf, 'mean cortical thickness');
SurfStatColLim([0.5,5.5]);

%Standard deviation of cortical thickness for all
figure
SurfStatView( std(T3).*mask, surf, 'std cortical thickness');
SurfStatColLim([0,.7]);

%Mean cortical thickness, per TestTime
figure
SurfStatView( mean(T3(1:27,:)).*mask, surf, 'mean cortical thickness, time1');
SurfStatColLim([0.5,5.5]);

figure
SurfStatView( mean(T3(28:54,:)).*mask, surf, 'mean cortical thickness, time2');
SurfStatColLim([0.5,5.5]);

%Standard deviation of cortical thickness, per TestTime
figure
SurfStatView( std(T3(1:27,:)).*mask, surf, 'std cortical thickness, time1');
SurfStatColLim([0,.7]);

figure
SurfStatView( std(T3(28:54,:)).*mask, surf, 'std cortical thickness, time2');
SurfStatColLim([0,.7]);

%% 1 You are now ready to create your model and to estimate it

Y = 1 + TestTime + Group + Age + random(id) + I;    % 'random(SubjectNum) + I' is only added when there is repeated-measures variable, in this case, TestTime
figure
image(Y);
slm = SurfStatLinMod( T3, Y, surf );

%% MAIN EFFECT OF GROUP, DIRECTION 1 (EXPERIMENT > CONTROL)

%To get your t statistic for group
contrast_group_direction1 = Group.Experiment - Group.Control;
slm_group_direction1 = SurfStatT ( slm, contrast_group_direction1);
figure
SurfStatView ( slm_group_direction1.t.*mask, surf, 'tmap exp>cont, removing age, test-time' );
SurfStatColLim([-3,3]);

%To get thresholded p values using Random Field Theory
[ pval, peak, clus ] = SurfStatP( slm_group_direction1, mask );
figure
SurfStatView( pval, surf, 'RFT exp>cont, removing age, test-time');


%To get thresholded p values using False Discovery Rate
qval = SurfStatQ( slm_group_direction1, mask );
figure
SurfStatView( qval, surf, 'FDR exp>cont, removing age, test-time');


%% MAIN EFFECT OF GENDER, DIRECTION 2 (CONTROL > EXPERIMENT)


%To get your t statistic for group
contrast_group_direction2 = Group.Control - Group.Experiment;
slm_group_direction2 = SurfStatT ( slm, contrast_group_direction2);
figure
SurfStatView ( slm_group_direction2.t.*mask, surf, 'tmap cont>exp, removing age and test-time' );
%SurfStatColLim([-3,3]);

%To get thresholded p values using Random Field Theory
[ pval, peak, clus ] = SurfStatP( slm_group_direction2, mask );
figure
SurfStatView( pval, surf, 'RFT cont>exp, removing age and test-time');

%To get thresholded p values using False Discovery Rate
qval = SurfStatQ( slm_group_direction2, mask );
figure
SurfStatView( qval, surf, 'FDR cont>exp, removing age and test-time');

%% MAIN EFFECT OF TESTTIME, DIRECTION 1 (TIME1 > TIME2)

%To get your t statistic for group
contrast_testtime_direction1 = TestTime.Time1 - TestTime.Time2;
slm_testtime_direction1 = SurfStatT ( slm, contrast_testtime_direction1);
figure
SurfStatView ( slm_testtime_direction1.t.*mask, surf, 'tmap time1>time2, removing age, group' );
SurfStatColLim([-4,4]);

%To get thresholded p values using Random Field Theory
[ pval, peak, clus ] = SurfStatP( slm_testtime_direction1, mask );
figure
SurfStatView( pval, surf, 'RFT time1>time2, removing age, group');


%To get thresholded p values using False Discovery Rate
qval = SurfStatQ( slm_testtime_direction1, mask );
figure
SurfStatView( qval, surf, 'FDR time1>time2, removing age, group');


%% MAIN EFFECT OF TESTTIME, DIRECTION 1 (TIME2 > TIME1)

%To get your t statistic for group
contrast_testtime_direction2 = TestTime.Time2 - TestTime.Time1;
slm_testtime_direction2 = SurfStatT ( slm, contrast_testtime_direction2);
figure
SurfStatView ( slm_testtime_direction2.t.*mask, surf, 'tmap time2>time1, removing age, group' );
SurfStatColLim([-4,4]);

%To get thresholded p values using Random Field Theory
[ pval, peak, clus ] = SurfStatP( slm_testtime_direction2, mask );
figure
SurfStatView( pval, surf, 'RFT time2>time1, removing age, group');

%To get thresholded p values using False Discovery Rate
qval = SurfStatQ( slm_testtime_direction2, mask );
figure
SurfStatView( qval, surf, 'FDR time2>time1, removing age, group');

%% EXAMPLES OF HOW TO CHANGE THE RFT OR FDR THRESHOLD

%%To get thresholded p values using Random Field Theory
p='0.02'; %choose your threshold different from 0.01
[ pval, peak, clus ] = SurfStatP( slm_group_direction2, mask, str2num(p) );
figure
SurfStatView( pval, surf, ['RFT cont>exp, p<' p]);

%%To get thresholded p values using False Discovery Rate
p='0.02'; %choose your threshold different from 0.05
qval = SurfStatQ( slm_group_direction2, mask );
figure
SurfStatView( qval, surf, ['FDR cont>exp, p<' p] );

%% MAIN (NEGATIVE) EFFECT OF AGE

slm_age = SurfStatT ( slm, -age);
figure
SurfStatView ( slm_age.t.*mask, surf, 'tmap for -age, removing group, test-time' );
%SurfStatColLim([-12,12]);

%To get thresholded p values using Random Field Theory
[ pval, peak, clus ] = SurfStatP( slm_age, mask );
figure
SurfStatView( pval, surf, 'RFT map for -age, removing group, test-time');

%To get thresholded p values using False Discovery Rate
qval = SurfStatQ( slm_age, mask );
figure
SurfStatView( qval, surf, 'FDR map for -age, removing group, test-time');

%% PLOTS

subj_means_collapsed_across_vertices= mean(T3_masked'); 
means=[mean(subj_means_collapsed_across_vertices(1:27)), mean(subj_means_collapsed_across_vertices(28:54))];
standarderror=[(std(subj_means_collapsed_across_vertices(1:27))/sqrt(length((subj_means_collapsed_across_vertices(1:27))))), ...
               (std(subj_means_collapsed_across_vertices(28:54))/sqrt(length((subj_means_collapsed_across_vertices(28:54)))))];
figure
hold on
plot(means, 'bo');  %b is for blue and o is for the marker, you can play with these options
set(gca, 'XTick',1:2, 'XTickLabel',{'Time1' 'Time2'})
errorbar(means,standarderror, 'bo') %standard error

ylabel('Mean Cortical Thickness (mm)');
xlabel('Test Time');
title (['Mean Cortical Thickness by Test Time; n=' num2str(length((subj_means_collapsed_across_vertices)))]);

%You may play around with these if you have different datapoints of
%different colors
%y = get(gca, 'Children');
%legend(y([4,2]),'Group1','Group2' 'Location','East') 
