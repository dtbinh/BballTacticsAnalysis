function [bags, num_data, num_feature] = MIL_Data_Load(filename)

global preprocess;
mat_file = [strtok(filename,'.') '.mat'];
if exist(mat_file,'file')
    load(mat_file);
    for nbag = 1:length(bags)
        bags(nbag).label = any(bags(nbag).inst_label);
    end
        
else
matrix_file = [filename '.matrix'];
label_file  = [filename '.label'];
insts = [];

if preprocess.InputFormat == 1
    %sparse input format
    if ispc && ~strfind(system_dependent('getos'),'Microsoft Windows 10')
        strcmd = sprintf('!ReadInput.pl %s 1', filename);
    else
        strcmd = sprintf('perl ReadInput.pl %s 1', filename);
    end
    eval(strcmd);
    D = load(matrix_file);
    insts = spconvert(D);
else
    if ispc && ~strfind(system_dependent('getos'),'Microsoft Windows 10')
        strcmd = sprintf('!ReadInput.pl %s', filename);
    else
        strcmd = sprintf('perl ReadInput.pl %s', filename);
    end
    eval(strcmd);    
    insts = load(matrix_file);
end
        
fid = fopen(label_file, 'r');
if fid == -1, error('The label file is not generated, quitting...'); end;

nbag = 0;
prev_bag_name = '';
ninst = 0;
idx = 0;
while feof(fid) == 0

    line = MIL_strtrim(fgets(fid));
    elems = MIL_strsplit(' ',line);    %instance_name, bag_name, label

    bag_name = cell2mat(elems(2));
    if strcmp(bag_name, prev_bag_name) == 0     %change of bag
        if (nbag >= 1)
            bags(nbag).instance = insts(idx + 1:idx + ninst, :);
            bags(nbag).label = any(bags(nbag).inst_label);
            idx = idx + ninst;
        end;
        nbag = nbag + 1;
        bags(nbag).name = bag_name;
        prev_bag_name = bag_name;
        ninst = 0;
    end

    ninst = ninst + 1;
    bags(nbag).inst_name(ninst) = elems(1);
    label = cell2mat(elems(3));
    bags(nbag).inst_label(ninst) = strcmp(label,'1');   %the positive label must be set to 1
end;

if (nbag >= 1)
    bags(nbag).instance = insts(idx + 1:idx + ninst,:);
    bags(nbag).label = any(bags(nbag).inst_label);
end;
fclose(fid);
end

num_data = length(bags);
num_feature = size(bags(1).instance, 2);

% normalize the data set
if (preprocess.Normalization == 1) 
    %bags = MIL_Scale(bags);
    bags = MIL_Scale_Standard(bags);
end;

% randomize the data
rand('state',sum(100*clock));
if (preprocess.Shuffled == 1) %Shuffle the datasets
    Vec_rand = rand(num_data, 1);
    [B, Index] = sort(Vec_rand);
    bags = bags(Index);
end;

