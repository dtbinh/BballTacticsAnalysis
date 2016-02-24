function  zoneFeature = GenerateZoneFeature(zoneIndex,stageFeature)

for T=1:size(zoneIndex,1)
    for p=1:size(zoneIndex,2)
        for s = 1:size(zoneIndex{T,p},1)
            for z = 1:size(zoneIndex{T,p},2)
                for f = 1:size(stageFeature{T,p},2)
                if zoneIndex{T,p}(s,z)
                    zoneFeature{T,p}(s,(f-1)*size(zoneIndex{T,p},2)+z) = stageFeature{T,p}(s,f);
                else
                    zoneFeature{T,p}(s,(f-1)*size(zoneIndex{T,p},2)+z) = 0;
                end
                end
            end
        end                    
    end
end

end