function saveMILLFeatureData(tactics,assign,MILLFeatureData,DataPath,featureName,mKeyPlayerIndex)

for ref = 1:length(tactics.refVideoIndex)
    %largeDataPath = ['../data/single/syncLargeP'];
    MILLFeatureDataAlign = InterTacticPlayerAlign(MILLFeatureData,tactics,assign,ref);
    
    if ~strcmp(featureName(end),'1') && ~isempty(strfind(featureName(1:end-1),'Zone'))
        if str2num(featureName(end)) == sum(mKeyPlayerIndex(tactics.refVideoIndex(ref),:)) % keyplayer number equal to featureIndex
            [MILLFeatureDataAlign,mKeyPlayerIndexCombined] = MultiplePlayerFeature(MILLFeatureDataAlign,tactics.keyPlayer,str2num(featureName(end)));
        else
            continue
        end
    end
    mkdir(DataPath);
    nonTacticIndex = tactics.videoIndex;
    nonTacticIndex{ref} = [];
    nonTacticIndex = cell2mat(nonTacticIndex);
    tacticIndex = tactics.videoIndex{ref};
    if ~exist('mKeyPlayerIndex','var')
        CreateBags(DataPath,featureName,MILLFeatureDataAlign,tactics.Name{ref},tacticIndex,nonTacticIndex,tactics.keyPlayer(tacticIndex,:));
    else
        CreateBags(DataPath,featureName,MILLFeatureDataAlign,tactics.Name{ref},tacticIndex,nonTacticIndex,mKeyPlayerIndexCombined(tacticIndex,:));
    end
end

end