clear all

% filenamePrefix = 'tuning/multiPlayers/syncLargeZoneDist/EVZoneDist3/cross_validate/SVM/inst_MI/RBF/K=0.1C=0.25N=1/';
% fileLists = dir([filenamePrefix 'inst_MI_validate*']);

targetDir = 'tuning/multiPlayers';
tacticSelect = {'F23','EV','HK','PD','PT','RB','SP','WS','WV','WW'};
datasetSelect = 'syncLarge';
SVMType = 'bag_MI'; %inst_MI
EvaluationSelect = 'cross_validate';
featureSelect = 'ZoneDist';
SVMKernelType = 'RBF';
playerNum = {'3','3','3','3','3','3','2','3','5','2'};

KernelParamO = 1;
CostFactorO  = 1;
NegativeWeightO = 1;
for t = 1:length(tacticSelect)
for i = -3:3
    for j=-3:3
        for k=0
            KernelParam = 2^i*KernelParamO;
            CostFactor  = 2^j*CostFactorO;
            NegativeWeight=2^k*NegativeWeightO;
            if ~isempty(playerNum{t})
                subfolder = [targetDir '/' datasetSelect featureSelect '/' tacticSelect{t} featureSelect playerNum{t} '/' EvaluationSelect '/SVM/' SVMType '/' SVMKernelType '/K=' num2str(KernelParam) 'C=' num2str(CostFactor) 'N=' num2str(NegativeWeight)];
            else
                subfolder = [targetDir '/' datasetSelect featureSelect '/' tacticSelect{t} featureSelect '/' EvaluationSelect '/SVM/' SVMType '/' SVMKernelType '/K=' num2str(KernelParam) 'C=' num2str(CostFactor) 'N=' num2str(NegativeWeight)];
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