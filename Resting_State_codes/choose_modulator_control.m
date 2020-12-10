function [mod_Ch_rand] = choose_modulator_control(RecordPairMRIlabels,MRIlabels,receiver_idx,Ch,mod_Ch)
    
    brainRegions = RecordPairMRIlabels(:,1); % -- get all the brain regions
    brainRegMod = brainRegions{Ch};  % -- get the brain region of the modulator in channel Ch
    brain_idx = MRIlabels.(brainRegMod).ElecIndx;  % -- get the indexes of the electrodes in the same brain region 
    
    % -- remove all the modulator indexes from the list of brain indexes
    % This is done to avoid resampling another modulator 
    for mod = mod_Ch 
        brain_idx(brain_idx == mod) = [];
    end
    brain_idx(brain_idx == receiver_idx) = []; % -- esclude the receiver from the control modulators, in case it belongs to this brain area
     
    L = length(brain_idx);
    mod_Ch_rand = brain_idx(randperm(L)); % -- randomly permute the indexes of the electrodes in the same brain region
    mod_Ch_rand = mod_Ch_rand(1:length(mod_Ch)); % return as many random idx as the number of modulator in this session
    
    
end 