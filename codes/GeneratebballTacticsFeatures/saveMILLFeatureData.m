function saveMILLFeatureData(tactics,assign,MILLFeatureData,DataPath,featureName,mKeyPlayerIndex)

for ref = 1:length(tactics.refVideoIndex)
    MILLFeatureDataAlign = InterTacticPlayerAlign(MILLFeatureData,tactics,assign,ref);
    if isempty(strfind(featureName,'Concat'))
        %largeDataPath = ['../data/single/syncLargeP'];

        if ~strcmp(featureName(end),'1') && ~isempty(strfind(featureName(1:end-1),'Zone'))
            if str2num(featureName(end)) == sum(mKeyPlayerIndex(tactics.refVideoIndex(ref),:)) % keyplayer number equal to featureIndex
                [MILLFeatureDataFinal,mKeyPlayerIndexCombined] = MultiplePlayerFeature(MILLFeatureDataAlign,tactics.keyPlayer,str2num(featureName(end)));
            else
                continue
            end
        end
     else
        MILLFeatureDataFinal = [];
        mKeyPlayerIndexCombined =[];
        for i = 2:size(mKeyPlayerIndex,2)
            [MILLFeatureDataAlignTemp,mKeyPlayerIndexTemp] =  MultiplePlayerFeature(MILLFeatureDataAlign,tactics.keyPlayer,i);
            MILLFeatureDataFinal = [MILLFeatureDataFinal MILLFeatureDataAlignTemp];
            if i ~= sum(mKeyPlayerIndex(tactics.refVideoIndex(ref),:))
                mKeyPlayerIndexCombined = [mKeyPlayerIndexCombined zeros(size(mKeyPlayerIndexTemp))];
            else
                mKeyPlayerIndexCombined = [mKeyPlayerIndexCombined mKeyPlayerIndexTemp];
            end
        end
    end
    
    mkdir(DataPath);
    nonTacticIndex = tactics.videoIndex;
    nonTacticIndex{ref} = [];
    nonTacticIndex = cell2mat(nonTacticIndex);
    tacticIndex = tactics.videoIndex{ref};
    if ~exist('mKeyPlayerIndex','var') || strcmp(featureName(end),'1')
        CreateBags(DataPath,featureName,MILLFeatureDataAlign,tactics.Name{ref},tacticIndex,nonTacticIndex,tactics.keyPlayer(tacticIndex,:));
    else
        CreateBags(DataPath,featureName,MILLFeatureDataFinal,tactics.Name{ref},tacticIndex,nonTacticIndex,mKeyPlayerIndexCombined(tacticIndex,:));
    end

end

end