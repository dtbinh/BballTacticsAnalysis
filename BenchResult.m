function BenchResult(EvaluationMethod) 

%maxNumCompThreads(1);
% % Leave one out 
% subfolder = ['LOUFeature-dist0/' featureSelect];
% mkdir([subfolder '/WW' featureSelect '/leave_one_out/']);
% MIL_Run(['classify -t ' subfolder '/WW' featureSelect '.data -o ' ...
%     subfolder '/WW' featureSelect '/leave_one_out/APR.data.result -p ' ...
%     subfolder '/WW' featureSelect '/leave_one_out/APR.data.pred -if 0 ¡Vn 1 -distrib 0 -- leave_one_out -- iterdiscrim_APR']);
% pause
% MIL_Run(['classify -t ' subfolder '/WW' featureSelect '.data -o ' ...
%     subfolder '/WW' featureSelect '/leave_one_out/instMI.data.result -p '...
%     subfolder '/WW' featureSelect '/leave_one_out/instMI.data.pred -if 0 ¡Vn 1 -distrib 0 -- leave_one_out -- inst_MI_SVM -Kernel 2']);
% %copyfile('temp/temp.output.txt',[featureSelect '/WW' featureSelect '_mi.output.txt']);
% pause
% MIL_Run(['classify -t ' subfolder '/WW' featureSelect '.data -o ' ...
%     subfolder '/WW' featureSelect '/leave_one_out/bagMI.data.result -p ' ...
%     subfolder '/WW' featureSelect '/leave_one_out/bagMI.data.pred -if 0 ¡Vn 1 -distrib 0 -- leave_one_out -- bag_MI_SVM -Kernel 2']);

% % 3-fold cross validation
% mkdir([featureSelect '/WW' featureSelect '/cross_validate/']);
% MIL_Run(['classify -t ' featureSelect '/WW' featureSelect '.data -o ' featureSelect '/WW' featureSelect '/cross_validate/APR.data.result -p ' featureSelect '/WW' featureSelect '/cross_validate/APR.data.pred -if 0 -sf 1 ¡Vn 1 -distrib 0 -- cross_validate -t 3 -- iterdiscrim_APR']);
% pause
% MIL_Run(['classify -t ' featureSelect '/WW' featureSelect '.data -o ' featureSelect '/WW' featureSelect '/cross_validate/instMI.data.result -p ' featureSelect '/WW' featureSelect '/cross_validate/instMI.data.pred -if 0 -sf 1 ¡Vn 1 -distrib 0 -- cross_validate -t 3 -- inst_MI_SVM -Kernel 0']);
% %copyfile('temp/temp.output.txt',[featureSelect '/WW' featureSelect '_mi.output.txt']);
% pause
% MIL_Run(['classify -t ' featureSelect '/WW' featureSelect '.data -o ' featureSelect '/WW' featureSelect '/cross_validate/bagMI.data.result -p ' featureSelect '/WW' featureSelect '/cross_validate/bagMI.data.pred -if 0 ¡Vn 1 -distrib 0 -- cross_validate -t 3 -- bag_MI_SVM -Kernel 0']);

% % Test SVM Parameter
% KernelParamO = 0.05;
% CostFactorO  = 1;
% NegativeWeightO = 1;
% for i = -3:3
%     for j=-3:3
%         for k=-3:3
%             KernelParam = 2^i*KernelParamO
%             CostFactor  = 2^j*CostFactorO
%             NegativeWeight=2^k*NegativeWeightO
% subfolder = [featureSelect '/WW' featureSelect '/leave_one_out/SVM/K=' num2str(KernelParam) 'C=' num2str(CostFactor) 'N=' num2str(NegativeWeight) '/'];
% mkdir(subfolder);
% 
% MIL_Run(['classify -t ' featureSelect '/WW' featureSelect '.data -o ' ... 
%     subfolder '/instMI.data.result -p ' subfolder '/instMI.data.pred -if 0 ¡Vn 1 -distrib 0 -- leave_one_out -- inst_MI_SVM -Kernel 2 -KernelParam ' ... 
%     num2str(KernelParam) ' -CostFactor ' num2str(CostFactor) ' -NegativeWeight ' num2str(NegativeWeight)]);
% %copyfile('temp/temp.output.txt',[featureSelect '/WW' featureSelect '_mi.output.txt']);
% %pause
% MIL_Run(['classify -t ' featureSelect '/WW' featureSelect '.data -o ' ...
%     subfolder '/bagMI.data.result -p ' subfolder '/bagMI.data.pred -if 0 ¡Vn 1 -distrib 0 -- leave_one_out -- bag_MI_SVM -Kernel 2 -KernelParam ' ...
%     num2str(KernelParam) ' -CostFactor ' num2str(CostFactor) ' -NegativeWeight ' num2str(NegativeWeight)]);
%         end
%     end
% end

% Test SVM Parameter
[datafile,pathName] = uigetfile('*.data', 'MultiSelect', 'on');
if iscell(datafile)
    nbfiles = length(datafile);
elseif datafile ~= 0
    nbfiles = 1;
else
    nbfiles = 0;
end
KernelParamO = 0.05;
CostFactorO  = 1;
NegativeWeightO = 1;

homePathName = pwd;
outputPath = strrep(pathName,[homePathName filesep 'data'],'tuning'); 
% for f=1:nbfiles
%     tic
% for i = -3:3
%     for j=-3:3
%         for k=0
%             KernelParam = 2^i*KernelParamO
%             CostFactor  = 2^j*CostFactorO
%             NegativeWeight=2^k*NegativeWeightO
% if iscell(datafile)
% subfolder = [pathName '/' strtok(datafile{f},'.') '/leave_one_out/SVM/K=' num2str(KernelParam) 'C=' num2str(CostFactor) 'N=' num2str(NegativeWeight) '/'];
% inputfile = [pathName datafile{f}];
% else
% subfolder = [pathName '/' strtok(datafile,'.') '/leave_one_out/SVM/K=' num2str(KernelParam) 'C=' num2str(CostFactor) 'N=' num2str(NegativeWeight) '/'];
% inputfile = [pathName datafile];
% end
% 
% mkdir(subfolder);
% 
% 
% MIL_Run(['classify -t ' inputfile ' -o ' ... 
%     subfolder '/instMI.data.result -p ' subfolder '/instMI.data.pred -if 0 ¡Vn 1 -distrib 0 -- leave_one_out -- inst_MI_SVM -Kernel 2 -KernelParam ' ... 
%     num2str(KernelParam) ' -CostFactor ' num2str(CostFactor) ' -NegativeWeight ' num2str(NegativeWeight)]);
% %copyfile('temp/temp.output.txt',[featureSelect '/WW' featureSelect '_mi.output.txt']);
% %pause
% MIL_Run(['classify -t ' inputfile ' -o ' ...
%     subfolder '/bagMI.data.result -p ' subfolder '/bagMI.data.pred -if 0 ¡Vn 1 -distrib 0 -- leave_one_out -- bag_MI_SVM -Kernel 2 -KernelParam ' ...
%     num2str(KernelParam) ' -CostFactor ' num2str(CostFactor) ' -NegativeWeight ' num2str(NegativeWeight)]);
%         end
%     end
% end
% toc
% %pause
% 
% end
% Test SVM Parameter

for f=1:nbfiles
    tic
for i = -3:3
    for j=-3:3
        for k=0
            KernelParam = 2^i*KernelParamO
            CostFactor  = 2^j*CostFactorO
            NegativeWeight=2^k*NegativeWeightO
if iscell(datafile)
subfolder = [outputPath strtok(datafile{f},'.') '/' EvaluationMethod '/SVM/K=' num2str(KernelParam) 'C=' num2str(CostFactor) 'N=' num2str(NegativeWeight) '/'];
inputfile = [pathName datafile{f}];
else
subfolder = [outputPath strtok(datafile,'.') '/' EvaluationMethod '/SVM/K=' num2str(KernelParam) 'C=' num2str(CostFactor) 'N=' num2str(NegativeWeight) '/'];
inputfile = [pathName datafile];
end

mkdir(subfolder);

if strcmp(EvaluationMethod,'leave_one_out')
    EvalCmd = '-sf 0 -- leave_one_out';
elseif strcmp(EvaluationMethod,'cross_validate')
    EvalCmd = '-sf 1 -- cross_validate -t 5';
end

MIL_Run(['classify -t ' inputfile ' -o ' ... 
    subfolder 'instMI.data.result -p ' subfolder 'instMI.data.pred -if 0 ¡Vn 1 -distrib 0 ' EvalCmd ' -- inst_MI_SVM -Kernel 2 -KernelParam ' ... 
    num2str(KernelParam) ' -CostFactor ' num2str(CostFactor) ' -NegativeWeight ' num2str(NegativeWeight)]);
%copyfile('temp/temp.output.txt',[featureSelect '/WW' featureSelect '_mi.output.txt']);
%pause
MIL_Run(['classify -t ' inputfile ' -o ' ...
    subfolder 'bagMI.data.result -p ' subfolder 'bagMI.data.pred --if 0 ¡Vn 1 -distrib 0 ' EvalCmd ' -- bag_MI_SVM -Kernel 2 -KernelParam ' ...
    num2str(KernelParam) ' -CostFactor ' num2str(CostFactor) ' -NegativeWeight ' num2str(NegativeWeight)]);
        end
    end
end
toc
end

end

%MIL_Run('classify -t WWV.data -- leave_one_out -- DD ¡VNumRuns 1 ¡VAggregate avg');