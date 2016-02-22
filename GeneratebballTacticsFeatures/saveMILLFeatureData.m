function saveMILLFeatureData(tactics,MILLFeatureData,DataPath,featureName)

for ref = 1:length(tactics.refVideoIndex)
    %largeDataPath = ['../data/single/syncLargeP'];
    mkdir(DataPath);
    nonTacticIndex = tactics.videoIndex;
    nonTacticIndex{ref} = [];
    nonTacticIndex = cell2mat(nonTacticIndex);
    tacticIndex = tactics.videoIndex{ref};
    
    CreateBags(DataPath,featureName,MILLFeatureData,tactics.Name{ref},tacticIndex,nonTacticIndex,tactics.keyPlayer(tacticIndex,:)); 
end

end