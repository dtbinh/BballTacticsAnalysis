function MIL_RunParam(param,pathName,datafile,EvaluationMethod,SVMType,kernelType)

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
        
KernelParamO = param.KernelO;   
CostFactorO  = param.CostFactorO;
NegativeWeightO = param.NegativeWeightO;        
        
normalization = param.normalization;
EvalCmd =  param.EvalCmd;

%% Execute cross_validate on Training data for tuning param
for i = param.kernel
    for j= param.cost         
        for k= param.negativeWeight
            KernelParam = 2^i*KernelParamO;
            CostFactor  = 2^j*CostFactorO;
            NegativeWeight=2^k*NegativeWeightO;


            for iter = 1:param.iter
                if param.iter == 1
                    subfolder = [strtok(train_data_file,'.') '/' EvaluationMethod '/SVM/' SVMType '/' kernelType '/K=' num2str(KernelParam) 'C=' num2str(CostFactor) 'N=' num2str(NegativeWeight) '/'];
                else
                    subfolder = [strtok(train_data_file,'.') '/'  EvaluationMethod '/SVM/' SVMType '/' kernelType '/K=' num2str(KernelParam) 'C=' num2str(CostFactor) 'N=' num2str(NegativeWeight) '/iter' int2str(iter) '/'];
                end
                if ~exist(subfolder,'dir')
                    mkdir(subfolder);    

                    MIL_Run(['classify -t ' train_data_file ' -o ' ...
                        subfolder SVMType '.data.result -p ' subfolder SVMType '.data.pred -if 0 -n ' normalization ' -distrib 0 ' EvalCmd ' -- ' SVMType '_SVM -Kernel 2 -KernelParam ' ...
                        num2str(KernelParam) ' -CostFactor ' num2str(CostFactor) ' -NegativeWeight ' num2str(NegativeWeight)]);
                else
                    continue
                end
            end
         end
    end
end

    end

end