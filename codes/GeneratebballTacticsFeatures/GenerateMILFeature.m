function GenerateMILFeature(playerNum,featureName,featureData,tactics,assign,syncFlag,mKeyPlayerIndex)

if playerNum == 1
    playerFolder = 'singlePlayer';
else
    playerFolder = 'multiPlayers';
end
if ~exist('syncFlag','var') || syncFlag
    syncFlag = 1;
    syncPrefix = 'sync';
else
    syncPrefix = 'nonSync';
end
   

largeDataPathPrefix = [pwd '/data/' playerFolder '/' syncPrefix 'Large'];
if ~exist('mKeyPlayerIndex','var')
    for f = 1:length(featureName)
        largeDataPath = [largeDataPathPrefix featureName{f}];
        saveMILLFeatureData(tactics,assign,featureData{f},largeDataPath,featureName{f});
    end
else
    for f = 1:length(featureName)
        largeDataPath = [largeDataPathPrefix featureName{f}];
        saveMILLFeatureData(tactics,assign,featureData{f},largeDataPath,[featureName{f} int2str(playerNum)],mKeyPlayerIndex);
    end
end


end