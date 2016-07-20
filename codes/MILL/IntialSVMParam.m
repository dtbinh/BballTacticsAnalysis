function param = IntialSVMParam(param,inputfile)

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
    param.CostFactorO  = 1;
    param.NegativeWeightO = 1;
    param.KernelO = KernelParamO;
    
end