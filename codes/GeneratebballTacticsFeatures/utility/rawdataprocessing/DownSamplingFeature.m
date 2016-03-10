function stageFeature = DownSamplingFeature(trajFeature_Sync,stageNum)

for T = 1:size(trajFeature_Sync,1)
    frameNum = size(trajFeature_Sync{T,1},1);
    interval = round(frameNum/stageNum);
    for p = 1:size(trajFeature_Sync,2)
        s = trajFeature_Sync{T,p};
        for i=1:stageNum
            if i~=stageNum
                %regionIndex((i-1)*interval+1:i*interval) = i;
                dsFeature(i,:) = mean(s((i-1)*interval+1:i*interval,:),1);
            else
                %regionIndex((i-1)*interval+1:frameNum) = i;
                dsFeature(i,:) = mean(s((i-1)*interval+1:frameNum,:),1);
            end
        end
        stageFeature{T,p} = dsFeature;
    end
end

end