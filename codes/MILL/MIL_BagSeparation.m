function [train_bagIdx,test_bagIdx] = BagSeparation(tactics,num_fold)
    for t = 1:length(tactics.videoIndex)
        fold_storage = SeparateSubFold(length(tactics.videoIndex{t}),num_fold);
        


        rand('state',sum(100*clock));
        Vec_rand = rand(length(tactics.videoIndex{t}), 1);
        [B, Index] = sort(Vec_rand);
        C(t,:) = mat2cell((Index+tactics.videoIndex{t}(1)-1)',1,fold_storage);
    end
    for j=1:num_fold
        test_bagIdx{j} = cell2mat(C(:,j)');
        train_bagIdx{j} = setdiff(1:size(tactics.keyPlayer,1),cell2mat(C(:,j)'));
    end
end


function fold_storage = SeparateSubFold(num_video,num_fold)
    rem = mod(num_video,num_fold);
    basic_storage = repmat((num_video-rem)/num_fold,1,num_fold);
    add_on = zeros(1,num_fold);        
    % random assign remainder
    add_on(randperm(num_fold,rem)) = 1;
    fold_storage = basic_storage + add_on;
end