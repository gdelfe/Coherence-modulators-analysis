
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This code computes the theta coherence between the modulator-sender and
% modulator-receiver for modulators having high/low theta power and
% z-scores the results by using the data from the  permutation test used to
% create a null distribution for the zero-coherence hypothesis 
%
%    @ Gino Del Ferraro, November 2020, Pesaran lab, NYU
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all; close all;

% set(0,'DefaultFigureVisible','off')
set(0,'DefaultFigureVisible','on')
set(0,'DefaultLineLineWidth',2)

%%%%%%%%%%%%%%%%%%%
% - LOAD DATA --- %
%%%%%%%%%%%%%%%%%%%

addpath('/mnt/pesaranlab/People/Gino/Coherence_modulator_analysis/Gino_codes');
dir_main = '/mnt/pesaranlab/People/Gino/Coherence_modulator_analysis/Shaoyu_data';
dir_high_low_theta = '/mnt/pesaranlab/People/Gino/Coherence_modulator_analysis/Shaoyu_data/Maverick/Resting_State/high_low_theta';

name_struct_input = '/session_data_lfp.mat';
filename = '.mat'; % -- filename for sess_data_info.mat
recording = 'last_recording';

freq_band = 'theta_band';
monkey = 'Maverick';
dir_RS_Theta = strcat(dir_main,sprintf('/%s/Resting_state/%s',monkey,freq_band));


fid = fopen(strcat(dir_RS_Theta,'/Sessions_with_modulator_info_movie.txt')); % load session info with no repetition
sess_info = textscan(fid,'%d%s%s'); % sess label, date, RS label
fclose(fid);

n_iter = 5000;
% p-value coherence difference for each modulator 
p_ms_tot = [];
p_mr_tot = [];

for s = 1:size(sess_info{1},1)  % For each session with at least one modulator
    
    Sess = sess_info{1}(s); % Session number
    display(['-- Session ',num2str(s),' -- label: ',num2str(Sess),', out of tot  ',num2str(size(sess_info{1},1)),' sessions'])
    dir_Sess_mod_send_data = strcat(dir_high_low_theta,sprintf('/Sess_%d/mod_send/Data',Sess));
    dir_Sess_mod_rec_data = strcat(dir_high_low_theta,sprintf('/Sess_%d/mod_rec/Data',Sess));

    % load coherence difference permuted for each session 
    load(strcat(dir_Sess_mod_send_data,'/mod_send_perm.mat'));
    load(strcat(dir_Sess_mod_rec_data,'/mod_rec_perm.mat'));
    
    for cnt_m = 1:length(mod_send_perm.mod_idx)
        
        % load coherences (high/low) for each modulator
        load(strcat(dir_Sess_mod_send_data,sprintf('/modulator_%d_send.mat',cnt_m)));
        load(strcat(dir_Sess_mod_rec_data,sprintf('/modulator_%d_rec.mat',cnt_m)));
        
        % coherence difference
        D_ms = abs(mod_send.coh_ms_high) - abs(mod_send.coh_ms_low);
        D_mr = abs(mod_rec.coh_mr_high) - abs(mod_rec.coh_mr_low);
               
        % permuted coherence difference: n_perm x freq = 5000 x 409
        PD_ms = abs(mod_send_perm.mod(cnt_m).c_ms_high) - abs(mod_send_perm.mod(cnt_m).c_ms_low);
        PD_mr = abs(mod_rec_perm.mod(cnt_m).c_mr_high) - abs(mod_rec_perm.mod(cnt_m).c_mr_low);
        
        % p-values 
        p_ms = sum(abs(PD_ms) > abs(D_ms))/n_iter;
        p_mr = sum(abs(PD_mr) > abs(D_mr))/n_iter;
        
        p_ms_tot = [p_ms_tot; p_ms];
        p_mr_tot = [p_mr_tot; p_mr];

    
    end % for each modulator



end % for each session 

% for the p-values which are exactly zero, replace with 1/n_iter
p_ms_tot(p_ms_tot == 0) = 1/5e3;
p_mr_tot(p_mr_tot == 0) = 1/5e3;

z_ms = norminv(p_ms_tot);
z_mr = norminv(p_mr_tot);


z_ms_mean = mean(z_ms);
z_mr_mean = mean(z_mr);

err_zms = std(z_ms)/sqrt(size(z_ms,1));
err_zmr = std(z_mr)/sqrt(size(z_mr,1));

f = mod_send.freq;

%%%%%%%%%%%%%%%%%%%%%%
% FIGURES %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%


% %%%% COHERENCE DIFFERENCE %%%%%%%%%%%%%%%%%%%%%%

set(0,'DefaultFigureVisible','on')
%     load(strcat(dir_high_low_theta,sprintf('/Sess_%d/coherence_all.mat')));

fig = figure;
shadedErrorBar(f,z_mr_mean,err_zmr,'lineprops',{'color',[28 199 139]/255 },'patchSaturation',0.5); hold on
shadedErrorBar(f,z_ms_mean,err_zms,'lineprops',{'color',[0.4940, 0.1840, 0.5560] },'patchSaturation',0.5); 

grid on
% title(sprintf('Both animals: Abs MS coherence, %s - Resting State',titleN),'FontSize',11);
set(gca,'FontSize',14)
xlabel('Frequency (Hz)','FontName','Arial','FontSize',15);
ylabel('z-scored coh diff','FontName','Arial','FontSize',15);
title('Z-scored Coherence diff MR and MS - high and low pow theta trial','FontSize',10)
legend('MR coh diff','MS coh diff','FontSize',10,'FontName','Arial')
set(gcf, 'Position',  [100, 600, 898, 500])
xlim([1 95])
% ylim([0 0.25])
grid on


fname = strcat(dir_high_low_theta,sprintf('/z-scored_coh_diff.jpg',cnt_m));
saveas(fig,fname);




