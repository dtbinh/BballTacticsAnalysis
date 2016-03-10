function saveMILLFeatureData(tactics,MILLFeatureData,DataPath,featureName,mKeyPlayerIndex)

for ref = 1:length(tactics.refVideoIndex)
    %largeDataPath = ['../data/single/syncLargeP'];
    mkdir(DataPath);
    nonTacticIndex = tactics.videoIndex;
    nonTacticIndex{ref} = [];
    nonTacticIndex = cell2mat(nonTacticIndex);
    tacticIndex = tactics.videoIndex{ref};
    if ~exist('mKeyPlayerIndex','var')
        CreateBags(DataPath,featureName,MILLFeatureData,tactics.Name{ref},tacticIndex,nonTacticIndex,tactics.keyPlayer(tacticIndex,:));
    else
        CreateBags(DataPath,featureName,MILLFeatureData,tactics.Name{ref},tacticIndex,nonTacticIndex,mKeyPlayerIndex(tacticIndex,:));
    end
end

end