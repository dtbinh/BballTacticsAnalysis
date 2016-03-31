function saveMILLFeatureData(tactics,assign,MILLFeatureData,DataPath,featureName,mKeyPlayerIndex)

for ref = 1:length(tactics.refVideoIndex)
    %largeDataPath = ['../data/single/syncLargeP'];
    MILLFeatureDataAlign = InterTacticPlayerAlign(MILLFeatureData,tactics,assign,ref);
    if ~strcmp(featureName(end),'1') && strcmp(featureName(1:end-1),'ZoneDist')
        [MILLFeatureDataAlign,mKeyPlayerIndex] = MultiplePlayerFeature(MILLFeatureDataAlign,tactics.keyPlayer,str2num(featureName(end)));
    end
    mkdir(DataPath);
    nonTacticIndex = tactics.videoIndex;
    nonTacticIndex{ref} = [];
    nonTacticIndex = cell2mat(nonTacticIndex);
    tacticIndex = tactics.videoIndex{ref};
    if ~exist('mKeyPlayerIndex','var')
        CreateBags(DataPath,featureName,MILLFeatureDataAlign,tactics.Name{ref},tacticIndex,nonTacticIndex,tactics.keyPlayer(tacticIndex,:));
    else
        CreateBags(DataPath,featureName,MILLFeatureDataAlign,tactics.Name{ref},tacticIndex,nonTacticIndex,mKeyPlayerIndex(tacticIndex,:));
    end
end

end