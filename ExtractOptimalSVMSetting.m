function svmsettings = ExtractOptimalSVMSetting(param,pathName,datafile,EvaluationMethod,SVMType,kernelType)

nbfiles = ShowDataFileNumber(datafile);
tmpPath = strrep(pathName,'data','tmp');

for x = 1:param.num_fold
    for f=1:nbfiles 
        %% Specify datafile input and tactic name
        if iscell(datafile)
            tacticName = strtok(datafile{f},'.');        
            inputfile = [pathName datafile{f}];

        else
            tacticName = strtok(datafile,'.');
            inputfile = [pathName datafile];
        end

        param = IntialSVMParam(param,inputfile);
        
        tmpFilePrefix = [tmpPath 'train' int2str(x) '/' tacticName]; 
        train_data_file = [tmpFilePrefix '_train' int2str(x) '.data'];
        
                %% Find SVM Param from tuning data
        if strfind(train_data_file,'singlePlayer')
            svmsettings = TuneSVMParam(param,strtok(train_data_file,'.'),EvaluationMethod,SVMType,kernelType);
        else
            if ~exist(strrep(strtok(train_data_file,'.'),'multiPlayers', 'multiPlayers/Convert(Th)'),'dir')
                runConvert(param,strtok(train_data_file,'.'),EvaluationMethod,SVMType,kernelType);
            end
            svmsettings(x,f) = TuneSVMParam(param,strtok(train_data_file,'.'),EvaluationMethod,SVMType,kernelType);
        end
        
    end
end