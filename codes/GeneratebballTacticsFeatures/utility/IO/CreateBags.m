function bags = CreateBags(dataPath,featureSelect,feature,tacticName,positiveBagsIndex,negativeBagsIndex,keyInstanceLabels)
    pb = length(positiveBagsIndex);
    nb = length(negativeBagsIndex);
    indexs = [positiveBagsIndex,negativeBagsIndex];
    ki = size(keyInstanceLabels,2);
    for j=1:pb+nb
        for p=1:ki
            if j<=pb
                %bags(j).name = [tacticName '-' int2str(j)];
                bags(j).name = [tacticName '-' int2str(indexs(j))];
                bags(j).inst_label(p) = keyInstanceLabels(j,p);
            else
                %bags(j).name = ['Non' tacticName '-' int2str(j-pb)];
                bags(j).name = ['Non' tacticName '-' int2str(indexs(j))];
                bags(j).inst_label(p) = 0;
            end

            %bags(j).inst_name{p} = [int2str(j) '-p' int2str(p)];
            bags(j).inst_name{p} = ['p' int2str(p)];
            bags(j).instance(p,:) = reshape(feature{indexs(j),p},1,size(feature{indexs(j),p},1)*size(feature{indexs(j),p},2));
            
        end
    end
    save([dataPath filesep tacticName featureSelect '.mat'], 'bags');
    MIL_Data_Save([dataPath filesep tacticName featureSelect '.data'],bags);
end