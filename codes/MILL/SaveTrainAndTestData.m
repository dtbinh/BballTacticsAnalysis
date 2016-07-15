function SaveTrainAndTestData(num_fold,pathName,datafile,train_bagIdx,test_bagIdx)

tmpPath = strrep(pathName,'data','tmp'); 
nbfiles = ShowDataFileNumber(datafile);

for f=1:nbfiles
%% Specify datafile input and tactic name
        if iscell(datafile)
            tacticName = strtok(datafile{f},'.');        
            inputfile = [pathName datafile{f}];

        else
            tacticName = strtok(datafile,'.');
            inputfile = [pathName datafile];
        end

global preprocess
preprocess.InputFormat = 0;
preprocess.Normalization = 0;
preprocess.Shuffled = 0;
[bags, ~, ~] = MIL_Data_Load(inputfile);
      
% Save Training and Testing data
for x = 1:num_fold
    mkdir([tmpPath 'train' int2str(x)]);
    tmpFilePrefix = [tmpPath 'train' int2str(x) '/' tacticName];  

    train_bags = bags(train_bagIdx{x});
    test_bags = bags(test_bagIdx{x});
    train_data_file = [tmpFilePrefix '_train' int2str(x) '.data'];
    test_data_file = [tmpFilePrefix '_test' int2str(x) '.data'];

    if ~exist(train_data_file,'file')
        MIL_Data_Save(train_data_file,train_bags);
        MIL_Data_Save(test_data_file,test_bags);
    else
        disp([train_data_file ' exist!!']);
    end
end

end

end