function BenchResult(param,EvaluationMethod,kernelType,SVMType) 

% eg: EvaluationMethod = 'cross_validate')
%     kernelType = 'linear','RBF'
%     SVMType = 'inst_MI','bag_MI'
%global bagCounter instCounter

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

KernelParamO = 0.05;
CostFactorO  = 1;
NegativeWeightO = 1;

while ~exist('normalization','var') || (~strcmp(normalization,'1') && ~strcmp(normalization,'0'))
    normalization = input('Q: Need Normalization?(Dist:No [type 0], Other:Yes [type 1])','s');
end


outputPath = strrep(pathName,'data','tuning'); 

for f=1:nbfiles
    tic



if strcmp(EvaluationMethod,'leave_one_out')
    EvalCmd = '-sf 0 -- leave_one_out';
elseif strcmp(EvaluationMethod,'cross_validate')
    EvalCmd = '-sf 1 -- cross_validate -t 5';
end

switch kernelType
    case 'linear'
    	if iscell(datafile)
			subfolder = [outputPath strtok(datafile{f},'.') '/' EvaluationMethod '/SVM/' SVMType '/' kernelType '/' ];
			inputfile = [pathName datafile{f}];
		else
			subfolder = [outputPath strtok(datafile,'.') '/' EvaluationMethod '/SVM/' SVMType '/' kernelType  '/'];
			inputfile = [pathName datafile];
		end

		mkdir(subfolder);

% 	    MIL_Run(['classify -t ' inputfile ' -o ' ... 
% 	        subfolder 'instMI.data.result -p ' subfolder 'instMI.data.pred -if 0 ¡Vn 1 -distrib 0 ' EvalCmd ' -- inst_MI_SVM -Kernel 0']);
% 
% 	    MIL_Run(['classify -t ' inputfile ' -o ' ...
% 	        subfolder 'bagMI.data.result -p ' subfolder 'bagMI.data.pred --if 0 ¡Vn 1 -distrib 0 ' EvalCmd ' -- bag_MI_SVM -Kernel 0']);
 	    MIL_Run(['classify -t ' inputfile ' -o ' ... 
	        subfolder SVMType '.data.result -p ' subfolder SVMType '.data.pred -if 0 ¡Vn ' normalization ' -distrib 0 ' EvalCmd ' -- ' SVMType '_SVM -Kernel 0']);
    case 'RBF'
		for i = param.kernel
		    for j= param.cost
		        for k= param.negativeWeight
            		KernelParam = 2^i*KernelParamO
            		CostFactor  = 2^j*CostFactorO
            		NegativeWeight=2^k*NegativeWeightO
					if iscell(datafile)
						subfolder = [outputPath strtok(datafile{f},'.') '/' EvaluationMethod  '/SVM/' SVMType '/' kernelType '/K=' num2str(KernelParam) 'C=' num2str(CostFactor) 'N=' num2str(NegativeWeight) '/'];
						inputfile = [pathName datafile{f}];
					else
						subfolder = [outputPath strtok(datafile,'.') '/' EvaluationMethod '/SVM/' SVMType '/' kernelType '/K=' num2str(KernelParam) 'C=' num2str(CostFactor) 'N=' num2str(NegativeWeight) '/'];
						inputfile = [pathName datafile];
					end

					mkdir(subfolder);    
%         			MIL_Run(['classify -t ' inputfile ' -o ' ... 
%             			subfolder 'instMI.data.result -p ' subfolder 'instMI.data.pred -if 0 ¡Vn 0 -distrib 0 ' EvalCmd ' -- inst_MI_SVM -Kernel 2 -KernelParam ' ... 
%             			num2str(KernelParam) ' -CostFactor ' num2str(CostFactor) ' -NegativeWeight ' num2str(NegativeWeight)]);
%         
%         			MIL_Run(['classify -t ' inputfile ' -o ' ...
%             			subfolder 'bagMI.data.result -p ' subfolder 'bagMI.data.pred --if 0 ¡Vn 0 -distrib 0 ' EvalCmd ' -- bag_MI_SVM -Kernel 2 -KernelParam ' ...
%             			num2str(KernelParam) ' -CostFactor ' num2str(CostFactor) ' -NegativeWeight ' num2str(NegativeWeight)]);
        			MIL_Run(['classify -t ' inputfile ' -o ' ...
            			subfolder SVMType '.data.result -p ' subfolder SVMType '.data.pred --if 0 ¡Vn ' normalization ' -distrib 0 ' EvalCmd ' -- ' SVMType '_SVM -Kernel 2 -KernelParam ' ...
            			num2str(KernelParam) ' -CostFactor ' num2str(CostFactor) ' -NegativeWeight ' num2str(NegativeWeight)]);
                end
            end
        end
   
    otherwise
        error('No Specific Kernel Type');
	end
toc
end

%save('SVM_Iter.mat','bagCounter','instCounter');

end
