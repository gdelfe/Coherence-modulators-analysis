%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This code creates the structures session_control_info.mat containing all the
% info about the data except for the LFPs for the case of the
% the controls electrodes - controls are chosen in the same area as the
% modulator's (all the available electrodes in that area)
%
% INPUT:  session_data_info.mat
% OUTPUT: session_control_info.mat in each Session folder containing a modulator 
% 
% @ Gino Del Ferraro, December 2020, Pesaran Lab, NYU


clear all; close all;

% set(0,'DefaultFigureVisible','off')
set(0,'DefaultFigureVisible','on')

%%%%%%%%%%%%%%%%%%%
% - LOAD DATA --- %
%%%%%%%%%%%%%%%%%%%

addpath('/mnt/pesaranlab/People/Gino/Coherence_modulator_analysis/Gino_codes')
dir_RS_Theta = '/mnt/pesaranlab/People/Gino/Coherence_modulator_analysis/Shaoyu_data/Resting_state/Theta_band';
dir_Stim = '/mnt/pesaranlab/People/Gino/Coherence_modulator_analysis/Shaoyu_data/Stim_data';

fid = fopen(strcat(dir_RS_Theta,'/Sessions_with_modulator_info.txt')); % load session info with no repetition
sess_info = textscan(fid,'%d%s%s'); % sess label, date, RS label
fclose(fid);

set(0,'DefaultLineLineWidth',2)

% -- load structure files

% -- print structures on stdout
%format short
for s=1:9
    
    Sess = sess_info{1}(s); % Session number
    dir_Sess = strcat(dir_RS_Theta,sprintf('/Sess_%d/Modulators',Sess));
    load(strcat(dir_Sess,'/session_data_info.mat')); % --- dataG: all data info and LFP
    
    mod_Ch = sess_data.mod_idx;
    RecordPairMRIlabels = sess_data.RecordPairMRIlabels; % -- MRI labels of the recorder pars 
    MRIlabels = sess_data.MRIlabels; % -- all the available MRI labels 
    receiver_idx = sess_data.receiver_idx; % -- receiver idx 

    [mod_Ch_rand,area_Ch_rand] = choose_ALL_control_other_Regions(RecordPairMRIlabels,MRIlabels,receiver_idx,mod_Ch);

    sess_All_controls_other_areas = sess_data;
    sess_All_controls_other_areas.ctrl_idx = mod_Ch_rand;
    sess_All_controls_other_areas.ctrl_area = area_Ch_rand(:)';
    sess_All_controls_other_areas 
    
    dir_Ctrl = strcat(dir_RS_Theta,sprintf('/Sess_%d/Controls_other_areas',Sess));
    if ~exist(dir_Ctrl, 'dir')
        mkdir(dir_Ctrl)
    end
    save(strcat(dir_Ctrl,'/session_controls_other_areas_info.mat'),'sess_All_controls_other_areas');
   
    
end




