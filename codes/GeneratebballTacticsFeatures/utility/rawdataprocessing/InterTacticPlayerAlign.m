function MILLFeatureDataAlign = InterTacticPlayerAlign(MILLFeatureData,tactics,assign,refTacticsIndex)

%MILLFeatureDataAlign = zeros(size(MILLFeatureData));

for t = 1:length(tactics.refVideoIndex)
    if t ~= refTacticsIndex
        for r = tactics.videoIndex{t}
            for p = 1:size(MILLFeatureData,2)
                MILLFeatureDataAlign(r, assign{refTacticsIndex,t}(p)) = MILLFeatureData(r,p);
            end
        end
    else
        MILLFeatureDataAlign(tactics.videoIndex{t},:) = MILLFeatureData(tactics.videoIndex{t},:);
    end
end
            

end