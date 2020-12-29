%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function picks a control electrode (index) in the same 
% brain area as the modulator.
% OUTPUT: indexes of the control modulators - as many as the true
% modulators. Each one of them in the same brain area
%
% @ Gino Del Ferraro, December 2020, Pesaran Lab, NYU
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [mod_Ch_rand,area_Ch_rand] = choose_ALL_control_same_Region(RecordPairMRIlabels,MRIlabels,receiver_idx,mod_Ch)
    
    mod_Ch_rand = []; % -- list to store the control electrodes
    AllBrainReg = {}; % -- list to store the control electrodes' brain areas 
    mod_Ch_check = mod_Ch;
    
    brainRegions = RecordPairMRIlabels(:,1); % -- get all the brain regions
    
        
    AllBrainReg = brainRegions(mod_Ch); % -- get all the brain regions for the modulator(s)
    AllBrainReg = unique(AllBrainReg);  % -- remove duplicates
    L = length(AllBrainReg);
    
    for reg = 1:L % -- for all the modulator(s) brain regions
        
        brainRegMod = AllBrainReg{reg}; % -- get the brain region 
        brain_idx = MRIlabels.(brainRegMod).ElecIndx;  % -- get the indexes of the electrodes in the same brain region
       
        
        brain_idx = setdiff(brain_idx,mod_Ch); % -- remove all the modulator indexes from the list of brain indexes for that region 
        brain_idx(brain_idx == receiver_idx) = []; % -- esclude the receiver from the control modulators, in case it belongs to this brain area
        mod_Ch_rand = [mod_Ch_rand, brain_idx]; % -- return all the control electrodes in the same area as the modulator(s)'
        
    end
        
        

end 