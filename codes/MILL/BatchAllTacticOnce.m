function BatchAllTacticOnce(param,EvaluationMethod,kernelType,SVMType,dataset) 

% eg: EvaluationMethod = 'cross_validate')
%     kernelType = 'linear','RBF'
%     SVMType = 'inst_MI','bag_MI'


% Test SVM Parameter
homePathName = '..';
[datafile,pathName] = uigetfile([homePathName filesep  'data/*.data'], 'MultiSelect', 'on');
if iscell(datafile)
    nbfiles = length(datafile);
elseif datafile ~= 0
    nbfiles = 1;
else
    nbfiles = 0;
end

display(datafile);


while ~exist('normalization','var') || (~strcmp(normalization,'1') && ~strcmp(normalization,'0'))
    normalization = input('Q: Need Normalization?(Dist:No [type 0], Other:Yes [type 1])','s');
end

outputPath = strrep(pathName,'data','tuning'); 

if strcmp(EvaluationMethod,'leave_one_out')
    EvalCmd = '-sf 0 -- leave_one_out';
elseif strcmp(EvaluationMethod,'cross_validate')
    EvalCmd = '-sf 1 -- cross_validate -t 5';  % -shuffle in cross-validation
end

% start timer
tic
for f=1:nbfiles  
    tmpPath = strrep(pathName,'data','tmp'); 
    %Specify datafile input and outputFolder
    if iscell(datafile)
        tmpFilePrefix = [tmpPath strtok(datafile{f},'.')];
        inputfile = [pathName datafile{f}];
    else
        tmpFilePrefix = [tmpPath strtok(datafile,'.')];
        inputfile = [pathName datafile];
    end

    % automatic load the SVM depending on feature select
    global preprocess
    preprocess.InputFormat = 0;
    preprocess.Normalization = 0;
    preprocess.Shuffled = 0;
    [bags, ~, num_feature] = MIL_Data_Load(inputfile);
%     num_feature
%     pause(5)
    clear preprocess
    KernelParamO = 1/num_feature;  %KernelParamO = 0.05 (default);
    CostFactorO  = 1;
    NegativeWeightO = 1;
    param.kernel0 = KernelParamO;
    
    if strcmp(dataset,'Training')
        num_fold = 5;
        mkdir(tmpPath);
        
        if ~exist([tmpFilePrefix '_bagSep.mat'],'file')            
            if f == 1
                LoadTacticsParams;
                [train_bagIdx,test_bagIdx] = MIL_BagSeparation(tactics,num_fold);
                save([tmpFilePrefix '_bagSep.mat'],'train_bagIdx','test_bagIdx');
            end
        else
            load([tmpFilePrefix '_bagSep.mat']);
        end
       
        for x = 1: num_fold 
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
                svmsetting = TuneSVMParam(param,strtok(train_data_file,'.'),EvaluationMethod,SVMType,kernelType);
                
                model_data_file = [strtok(train_data_file,'.') '/model.txt'];
                MIL_Run(['classify -t ' train_data_file  ' -- train_only -m ' model_data_file ...
                    ' -- inst_MI_SVM -Kernel 2 ¡VKernelParam ' num2str(svmsetting.kernel) ' -CostFactor ' num2str(svmsetting.cost)]);% ' -Threshold ' threshold]);
        
                MIL_Run(['classify -t ' test_data_file ' -- test_only -m ' model_data_file ' -- inst_MI_SVM']);
        end

    end


    
end
toc

end

