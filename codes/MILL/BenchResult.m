function BenchResult(param,EvaluationMethod,kernelType,SVMType) 

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
    
    %Specify datafile input and outputFolder
    if iscell(datafile)
        outFolder = [outputPath strtok(datafile{f},'.') '/' EvaluationMethod '/SVM/' SVMType '/'];
        inputfile = [pathName datafile{f}];
    else
        outFolder = [outputPath strtok(datafile,'.') '/' EvaluationMethod '/SVM/' SVMType '/'];
        inputfile = [pathName datafile];
    end


    % automatic load the SVM depending on feature select
    global preprocess
    preprocess.InputFormat = 0;
    preprocess.Normalization = 0;
    preprocess.Shuffled = 0;
    [~, ~, num_feature] = MIL_Data_Load(inputfile);
    num_feature
    pause(5)
    clear preprocess
    KernelParamO = 1/num_feature;  %KernelParamO = 0.05 (default);
    CostFactorO  = 1;
    NegativeWeightO = 1;



    switch kernelType
        case 'linear'
            
            for iter = 1:param.iter
                
            subfolder = [outFolder kernelType '/'];
            mkdir(subfolder);

            MIL_Run(['classify -t ' inputfile ' -o ' ... 
                subfolder SVMType '.data.result -p ' subfolder SVMType '.data.pred -if 0 ¡Vn ' normalization ' -distrib 0 ' EvalCmd ' -- ' SVMType '_SVM -Kernel 0']);
            end
        case 'RBF'
            for i = param.kernel
                for j= param.cost            
                    for k= param.negativeWeight
                        KernelParam = 2^i*KernelParamO;
                        CostFactor  = 2^j*CostFactorO;
                        NegativeWeight=2^k*NegativeWeightO;
                        
                        for iter = 1:param.iter

                        subfolder = [outFolder kernelType '/K=' num2str(KernelParam) 'C=' num2str(CostFactor) 'N=' num2str(NegativeWeight) '/iter' int2str(iter) '/'];
                        mkdir(subfolder);    

                        MIL_Run(['classify -t ' inputfile ' -o ' ...
                            subfolder SVMType '.data.result -p ' subfolder SVMType '.data.pred -if 0 -n ' normalization ' -distrib 0 ' EvalCmd ' -- ' SVMType '_SVM -Kernel 2 -KernelParam ' ...
                            num2str(KernelParam) ' -CostFactor ' num2str(CostFactor) ' -NegativeWeight ' num2str(NegativeWeight)]);
                        end
                     end
                end
            end

        otherwise
            error('No Specific Kernel Type');
    end

end
toc

end

