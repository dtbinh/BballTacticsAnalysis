clear all

% filenamePrefix = 'tuning/multiPlayers/syncLargeZoneDist/EVZoneDist3/cross_validate/SVM/inst_MI/RBF/K=0.1C=0.25N=1/';
% fileLists = dir([filenamePrefix 'inst_MI_validate*']);

targetDir = 'tuning/multiPlayers';
tacticSelect = {'F23','EV','HK','PD','PT','RB','SP','WS','WV','WW'};
datasetSelect = 'syncLarge';
SVMType = 'inst_MI'; %inst_MI
EvaluationSelect = 'cross_validate';
featureSelect = 'ZoneVelocitySoftAssign';%'ZoneDist';
SVMKernelType = 'RBF';
playerNum = {'3','3','3','3','4','3','2','3','5','2'};

param.kernel = 5:-1:-5;
param.cost = 10:-1:-5;
param.negativeWeight = 0;
param.iter = 2;

KernelParamO = 1/1040;
CostFactorO  = 1;
NegativeWeight0 = 1;

for t = 2%1:length(tacticSelect)
    
for i = param.kernel
    
    for j= param.cost
        for k=param.negativeWeight
            for iter = 1:param.iter
            KernelParam = 2^i*KernelParamO;
            CostFactor  = 2^j*CostFactorO;
            NegativeWeight=2^k* NegativeWeight0;
            if ~isempty(playerNum{t})
                subfolder = [targetDir '/' datasetSelect featureSelect '/' tacticSelect{t} featureSelect playerNum{t} '/' EvaluationSelect '/SVM/' SVMType '/' SVMKernelType '/K=' num2str(KernelParam) 'C=' num2str(CostFactor) 'N=' num2str(NegativeWeight)];
            else
                subfolder = [targetDir '/' datasetSelect featureSelect '/' tacticSelect{t} featureSelect '/' EvaluationSelect '/SVM/' SVMType '/' SVMKernelType '/K=' num2str(KernelParam) 'C=' num2str(CostFactor) 'N=' num2str(NegativeWeight)];
            end
            if param.iter ~= 1
                subfolder = [subfolder '/iter' int2str(iter)];
            end

            trainingfileLists = dir([subfolder '/' SVMType '_training*']);
            validatefileLists = dir([subfolder '/' SVMType '_validate*']);


            for f = 1:length(validatefileLists)
                %ConventMultiPlayerInst2SinglePlayer([filenamePrefix fileLists(f).name],5,3);
                %[bagAccu(f),instAccu(f)] = ConventMultiPlayerInst2SinglePlayer([subfolder '/' fileLists(f).name],5,str2double(playerNum));
                [bagAccu(f),instAccu(f)] = ConventMultiPlayerInst2SinglePlayerThreshold([subfolder '/' trainingfileLists(f).name],...
                    [subfolder '/' validatefileLists(f).name],5,str2double(playerNum{t}));
            end

            clear fileLists
            
            %resultFile = [strrep(subfolder,'multiPlayers','multiPlayers/Convert') '/' SVMType '.data.result']
            resultFile = [strrep(subfolder,'multiPlayers','multiPlayers/Convert(th)') '/' SVMType '.data.result']
            str = ['Bag label accuracy = ' num2str(mean(bagAccu)) ', Instance label accuracy = ' num2str(mean(instAccu)) ', '];
            fid = fopen(resultFile,'w');
            fprintf(fid, str);
            fclose(fid);
            end
        end
    end
end
end