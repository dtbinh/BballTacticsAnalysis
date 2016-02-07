function bags = MIL_Scale_Standard(bags)

featureMatrix = [];
for i=1:length(bags)   
    [ninst, nfea] = size(bags(i).instance);
    for j=1:ninst
        featureMatrix = [featureMatrix; bags(i).instance(j,:)];
    end    
end

fMean = mean(featureMatrix,1);
fStd  = std(featureMatrix,0,1);
fStd(find(fStd==0))=1;

for i=1:length(bags)    
    [ninst, nfea] = size(bags(i).instance);

    mean_mat = repmat(fMean, ninst, 1); 
    std_mat = repmat(fStd, ninst, 1);
    
    bags(i).instance = (bags(i).instance-mean_mat)./std_mat;    
end

end