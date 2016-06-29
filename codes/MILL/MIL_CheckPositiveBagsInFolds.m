function new_bags = MIL_CheckPositiveBagsInFolds(old_bags,num_folder,verbosity)

[npbags,pbagsIndex] = CalculatePositiveBagNum(old_bags);

% 1xnum_folder structure vector output (num,index)
[npbags_folds] = CalculatePositiveBagInEachFold(pbagsIndex,length(old_bags),num_folder);


% for i = 1:num_folder
%     idealFoldPbagsNum(i) = length(floor((i-1) * npbags / num_folder)+1 : floor( i * npbags/num_folder));
% end
idealFoldPbagsNum = SeparateSubFold(npbags,num_folder);

if exist('verbosity','var') && verbosity
    disp(['Old Positve Bags ...' int2str(pbagsIndex)])
    for i = 1:num_folder
        disp(['fold ' int2str(i) ': ' int2str(npbags_folds(i).numPbags) '...']);
    end
end
%new_bags = WarpPositiveBag(old_bags,overAverageFolds,underAverageFolds);
new_bags = WarpPositiveBag(old_bags,npbags_folds,idealFoldPbagsNum,verbosity);

[Rnpbags,RpbagsIndex] = CalculatePositiveBagNum(new_bags);
[Rnpbags_folds] = CalculatePositiveBagInEachFold(RpbagsIndex,length(new_bags),num_folder);
if exist('verbosity','var') && verbosity
    disp(['New Positive Bags ...' int2str(RpbagsIndex)])
    for i = 1:num_folder
        disp(['fold ' int2str(i) ': ' int2str(Rnpbags_folds(i).numPbags) '...']);
    end
end
end

function fold_storage = SeparateSubFold(num_bags,num_fold)
    rem = mod(num_bags,num_fold);
    basic_storage = repmat((num_bags-rem)/num_fold,1,num_fold);
    add_on = zeros(1,num_fold);        
    % random assign remainder
    add_on(randperm(num_fold,rem)) = 1;
    fold_storage = basic_storage + add_on;
end

function [num_positiveBag,idx_positiveBag] = CalculatePositiveBagNum(bags)
num_positiveBag = 0;
idx_positiveBag = [];

for i = 1:length(bags)
    if bags(i).label
        num_positiveBag = num_positiveBag + 1;
        idx_positiveBag = [idx_positiveBag i];
    end    
end
end

function folds = CalculatePositiveBagInEachFold(pbagsIndex,num_data,num_folder)
for i = 1:num_folder
    folds(i).indexSet = floor((i-1) * num_data / num_folder)+1 : floor( i * num_data/num_folder);
    folds(i).numPbags = 0;
    folds(i).idxPbags = [];
end

for j = 1:length(pbagsIndex)
    bagIdx = floor((pbagsIndex(j)-1)/(num_data/num_folder))+1;
    % display positive bags and their location
    %disp([int2str(pbagsIndex(j)) ',' int2str(bagIdx)]);
    folds(bagIdx).numPbags = folds(bagIdx).numPbags + 1;
    folds(bagIdx).idxPbags = [folds(bagIdx).idxPbags pbagsIndex(j)];
end


end

function new_bags = WarpPositiveBag(old_bags,npbags_folds,idealFoldPbagsNum,verbosity)
num_data = length(old_bags);

% detect warping index
pbags_rand = [];
nbags_rand = [];
for i = 1:length(npbags_folds)
    idxPbag = npbags_folds(i).idxPbags;
    idxNbag = setdiff(npbags_folds(i).indexSet,idxPbag);
    if npbags_folds(i).numPbags ~= idealFoldPbagsNum(i)
        diff = npbags_folds(i).numPbags - idealFoldPbagsNum(i);
        % randomize the data
        rand('state',sum(100*clock));
        if diff < 0
            nbags_rand = [nbags_rand idxNbag(randperm(length(npbags_folds(i).indexSet)-npbags_folds(i).numPbags,-diff))];
            %pbags_rand = [];
        else
            %nbags_rand{i} = [];
            pbags_rand = [pbags_rand idxPbag(randperm(npbags_folds(i).numPbags, diff))];
        end
    end
end

% build random warping lookup table
rand('state',sum(100*clock));
lookup = randperm(length(pbags_rand));

% initialize new_bags
new_bags = old_bags;
% warping bags
for k = 1:length(pbags_rand)
    %temp_bags = old_bags(pbags_rand(k));
    if verbosity
        disp([ int2str(pbags_rand(k)) 'th bag (positive) <-> ' int2str(nbags_rand(lookup(k))) 'th bag (negative)!!']); 
    end
    new_bags(pbags_rand(k)) = old_bags(nbags_rand(lookup(k)));
    new_bags(nbags_rand(lookup(k))) = old_bags(pbags_rand(k));
end
end
