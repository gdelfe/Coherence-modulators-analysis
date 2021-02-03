
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% THETA PICK: 7.8 Hz, BETA PICK: 21 Hz

clear all; close all;

% set(0,'DefaultFigureVisible','off')
set(0,'DefaultFigureVisible','on')


addpath('/mnt/pesaranlab/People/Gino/Coherence_modulator_analysis/Gino_codes')
addpath('/mnt/pesaranlab/People/Gino/Coherence_modulator_analysis/Gino_codes/Resting_State_codes')
dir_RS = '/mnt/pesaranlab/People/Gino/Coherence_modulator_analysis/Shaoyu_data/Resting_state';
dir_Perm = '/mnt/pesaranlab/People/Gino/Coherence_modulator_analysis/Shaoyu_data/Resting_state/Permutation_test2';


fk = 200; W = 5; iter = 1000;

fk = 200; W = 5;
% %%%%%%%%% MODULATORS  %%%%%%
load(strcat(dir_RS,sprintf('/coh_spec_m_fk_%d_W_%d.mat',fk,W))); % structure mod
load(strcat(dir_RS,sprintf('/coh_spec_sr_fk_%d_W_%d.mat',fk,W))); % structure stim
stim_mod = stim;
mod_mod = mod;
modulators = mean_coh_and_spec_RS(mod,stim);

% %%%%%%%%% PERMUTED DATA  %%%%%%
load(strcat(dir_Perm,sprintf('/coh_spec_m_fk_%d_W_%d.mat',fk,W))); % structure mod
load(strcat(dir_Perm,sprintf('/coh_sr_permuted_fk_%d_W_%d.mat',fk,W))); % structure stim
f = linspace(1,fk,size(coh(1).perm(1).c_mr,2)); % frequency values (range)

% Plot to check --- permuted coherence 
set(0,'DefaultFigureVisible','on')
% -- FIGURE: Plot average coherence across sessions for MR, CR same area, CR other areas
fig = figure;
hold all
el = 41; permS = 1 ; permR = 1;
plot(abs(coh(el).perm(permS).c_ms))
hold on 
plot(abs(coh(el).perm(permR).c_mr))
xlabel('freq (Hz)')
ylabel('coherence')
legend('Permuted coherence')


% Theta pick 7.8 Hz -> f(15)
% Beta pick 21 Hz -> f(42)
t_idx = 15; b_idx = 42;

theta_MR = zeros(size(coh,2),iter);
beta_MR = zeros(size(coh,2),iter);

% select only theta frequence and beta frequence at the peaks for each
% electrode 
for ch = 1:size(coh,2)
    for perm = 1:iter
        
        theta_MR(ch,perm) = coh(ch).perm(perm).c_mr(t_idx); % 7.8 Hz
        beta_MR(ch,perm) = coh(ch).perm(perm).c_mr(b_idx);  % 21 Hz
        
    end
end

% pvalue calculation for each electrodes 
pth = 0.05
theta_NZ = 0; % counts for theta non-zero
beta_NZ = 0; % counts for beta non-zero
for ch = 1:size(coh,2)
    
   stats(ch).theta_pval =  nnz(abs(theta_MR(ch,:)) > abs(mod(ch).c_mr(t_idx)))/iter
   stats(ch).beta_pval =  nnz(abs(beta_MR(ch,:)) > abs(mod(ch).c_mr(b_idx)))/iter
   
   % How many times theta and beta are significantly larger than zero (with
   % pval threshold = 0.05)
   theta_NZ = theta_NZ + int8(stats(ch).theta_pval <= pth); % if pval of the channel is smaller than pval threshold add 1
   beta_NZ = theta_NZ + int8(stats(ch).beta_pval <= pth); 
   
end

% counts of theta being significantly zero and beta being significantly zero
theta_Z = size(coh,2) - theta_NZ;
beta_Z = size(coh,2) - beta_NZ;

Obs = double([theta_NZ, theta_Z; beta_NZ, beta_Z]); 

N = sum(sum(Obs)) % Sample size
E_theta_NZ = sum(Obs(1,:)) * sum(Obs(:,1))/N
E_theta_Z = sum(Obs(1,:)) * sum(Obs(:,2))/N
E_beta_NZ = sum(Obs(2,:)) * sum(Obs(:,1))/N
E_beta_Z = sum(Obs(2,:)) * sum(Obs(:,2))/N

Exp = [E_theta_NZ,E_theta_Z; E_beta_NZ,E_beta_Z];




ch = 41;
fig = figure;
histogram(abs(theta_MR(ch,:)),20,'Normalization','probability','FaceAlpha',.6); grid on
hold on; histogram(abs(beta_MR(ch,:)),20,'Normalization','probability','FaceAlpha',.6); grid on
legend('p-val theta','p-val beta')
title('p-val distribution','FontSize',12)


O = reshape(Obs,[1,4]);
E = reshape(Exp,[1,4]);0.0
% Compute Chi-Squared 
chi = 0;
for i = 1:4
    power((O(i) - E(i)),2)/E(i)
    chi = chi + power((O(i) - E(i)),2)/E(i);
    
end
chi













shadedErrorBar(f,modulators.mean_coh_mr,modulators.err_mr,'lineprops',{'color',[0, 51, 0]/255},'patchSaturation',0.4); hold on
shadedErrorBar(f,ctrl_SA.mean_coh_mr,ctrl_SA.err_mr,'lineprops',{'color',[26 198 1]/255},'patchSaturation',0.4); hold on
shadedErrorBar(f,ctrl_OA.mean_coh_mr,ctrl_OA.err_mr,'lineprops',{'color',[102, 255, 217]/255},'patchSaturation',0.4); hold on

grid on
title('Abs MR coherence MODULATORS vs CONTROLS - Resting State','FontSize',11);
xlabel('freq (Hz)');
ylabel('coherence');
legend('Modulators-Receivers','Controls-Receivers  same area','Controls-Receiver  other areas','FontSize',10)
set(gcf, 'Position',  [100, 600, 1000, 600])
grid on
