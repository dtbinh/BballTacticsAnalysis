function [train_bagIdx,test_bagIdx] = checkBagSep(num_fold)

%% check bag separation existence
sep_file = ['tmp/tactic_bagSep' int2str(num_fold) '.mat'];
if ~exist(sep_file,'file')            
        LoadTacticsParams;
        [train_bagIdx,test_bagIdx] = MIL_BagSeparation(tactics,num_fold);
        save(sep_file,'train_bagIdx','test_bagIdx');
else
    load(sep_file);
end 

end