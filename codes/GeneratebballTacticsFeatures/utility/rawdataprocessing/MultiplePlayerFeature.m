function [multipleFeature,multipleKeyPlayer] = MultiplePlayerFeature(feature,keyPlayerIndex,playerNum)

b = nchoosek(1:size(keyPlayerIndex,2),playerNum);

map = zeros(size(b,1),size(keyPlayerIndex,2));
for c = 1:size(b,1)
    for pi = 1:size(b,2)
        map(c,b(c,pi)) = 1;
    end
end
        
% map
% multipleFeature = 1;
% multipleKeyPlayer = 1;

for c = 1:size(b,1)
    for T = 1:size(keyPlayerIndex,1)
        binaryMatch = and(map(c,:), keyPlayerIndex(T,:));
        if sum(binaryMatch) == playerNum
            multipleKeyPlayer(T,c) = 1;
        else
            multipleKeyPlayer(T,c) = 0;
        end
    end
end

for T= 1:size(feature,1)
    for c = 1:size(map,1)
        for p = 1:size(map,2)
            if p ~= 1
                multipleFeature{T,c} = multipleFeature{T,c} + map(c,p)*feature{T,p}/playerNum;
            else
                multipleFeature{T,c} = map(c,p)*feature{T,p}/playerNum;
            end
        end
    end
end

end