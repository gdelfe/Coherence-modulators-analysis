
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all; close all;

% set(0,'DefaultFigureVisible','off')
set(0,'DefaultFigureVisible','on')
set(0,'DefaultLineLineWidth',2)


addpath('/mnt/pesaranlab/People/Gino/Coherence_modulator_analysis/Gino_codes')
addpath('/mnt/pesaranlab/People/Gino/Coherence_modulator_analysis/Gino_codes/Resting_State_codes')
dir_main = '/mnt/pesaranlab/People/Gino/Coherence_modulator_analysis/Shaoyu_data/';
dir_fig = strcat(dir_main,'Figures_paper');


% Load SR coherence for high/low modulator power, ordered by ranking
% --- Maverick
monkey = 'Maverick';
dir_high_low_theta = strcat(dir_main,sprintf('/%s/Resting_State/high_low_theta',monkey));
mav_coh_H = load(strcat(dir_high_low_theta,'/coh_all_sess_sr_high_mod_ranked.mat'))
mav_coh_L = load(strcat(dir_high_low_theta,'/coh_all_sess_sr_low_mod_ranked.mat'))

% --- Archie
monkey = 'Archie';
dir_high_low_theta = strcat(dir_main,sprintf('/%s/Resting_State/high_low_theta',monkey));
arc_coh_H = load(strcat(dir_high_low_theta,'/coh_all_sess_sr_high_mod_ranked.mat'))
arc_coh_L = load(strcat(dir_high_low_theta,'/coh_all_sess_sr_low_mod_ranked.mat'))


diff_array = []; err_arr = [];
percentage = [0.1,0.2,0.3,0.4,0.5,1];
for percent = percentage
    
    mav_idx = round(size(mav_coh_H.coh_all_c_sr_high,1)*percent) % amount of modulators in Maverick
    arc_idx = round(size(arc_coh_H.coh_all_c_sr_high,1)*percent) % amount of modulators in Archie
    
    
    % coherences for high and low modulator power
    coh_high = [mav_coh_H.coh_all_c_sr_high(1:mav_idx,:); arc_coh_H.coh_all_c_sr_high(1:arc_idx,:)];
    coh_low = [mav_coh_L.coh_all_c_sr_low(1:mav_idx,:); arc_coh_L.coh_all_c_sr_low(1:arc_idx,:)];
    
    % coherence difference
    diff = abs(coh_high) - abs(coh_low);
    diff_mean = mean(diff);
    diff_mean_theta = mean(diff_mean(9:19)); % average difference over theta band
    diff_array = [diff_array, diff_mean_theta]; % store differences in array
    
    % coherence difference error
    diff_var = var(diff); % variance
    diff_var_theta = diff_var(9:19);
    diff_var_mean = mean(diff_var_theta); % mean of the variance in theta
    std_diff = sqrt(diff_var_mean);
    err_diff = std_diff/sqrt(11*(mav_idx+arc_idx)) % 11 is the number of time points in the theta frequency
    err_arr = [err_arr, err_diff];
    
end

x = [0.1,0.2,0.3,0.4,0.5,1];
figure;
errorbar(x,diff_array,err_arr)
xlim([0.05 1.05])
ylim([0 0.18])
xlabel('Modulator ranking','FontName','Arial','FontSize',10);
ylabel('SR coherence difference (high-low)','FontName','Arial','FontSize',10);
title('SR coherence difference (high-low)','FontName','Arial','FontSize',10);



keyboard

errorbar(percentage,mod_avg_mr,err_mod_avg_mr,'color',[28 199 139]/255,'LineWidth',1); hold on
errorbar(percentage,ctrl_SA_avg_mr,err_ctrl_SA_avg_mr,'color',[50 250 93]/255,'LineWidth',1); hold on
errorbar(percentage,ctrl_OA_avg_mr,err_ctrl_OA_avg_mr,'color',[19 148 92]/255,'LineWidth',1);

% shadedErrorBar(f,modulators.mean_coh_mr,modulators.err_mr,'lineprops',{'color',[28 199 139]/255 },'patchSaturation',0.5); hold on
% shadedErrorBar(f,ctrl_SA.mean_coh_mr,ctrl_SA.err_mr,'lineprops',{'color',[50 250 93]/255 },'patchSaturation',0.5); hold on
% shadedErrorBar(f,ctrl_OA.mean_coh_mr,ctrl_OA.err_mr,'lineprops',{'color',[19 148 92]/255 },'patchSaturation',0.5);

% xlim([6,105])
xlim([85,110])
ylim([0.1 0.57])
% xticks([0 10 20 30 40 50 60 80 100])
grid on
set(gca,'FontSize',14)
% title('Coherence at the Theta peak vs TOP modulators','FontSize',11')
xlabel('Frequency (Hz)','FontName','Arial','FontSize',15);
ylabel('Theta-Coherence','FontName','Arial','FontSize',15);
legend('Modulator - Receiver','Controls-SA - Receiver','Controls-OA - Receiver','FontSize',10)
set(gcf, 'Position',  [100, 600, 650, 450])

% fname = strcat(dir_both_monkeys,'/Coherence_MR_vs_TOP_modulators_both_monkeys.png');


fname = strcat(dir_fig,'/Coherence_MR_vs_TOP_modulators_both_monkeys_only100.pdf');
saveas(fig,fname);














