clear all

% filenamePrefix = 'tuning/multiPlayers/syncLargeZoneDist/EVZoneDist3/cross_validate/SVM/inst_MI/RBF/K=0.1C=0.25N=1/';
% fileLists = dir([filenamePrefix 'inst_MI_validate*']);

targetDir = 'tuning/multiPlayers';
tacticSelect = 'EV';
datasetSelect = 'syncLarge';
SVMType = 'inst_MI'; %inst_MI
EvaluationSelect = 'cross_validate';
featureSelect = 'ZoneDist';
SVMKernelType = 'RBF';
playerNum = '3';

KernelParamO = 0.05;
CostFactorO  = 1;
NegativeWeightO = 1;
for i = -3:3
    for j=-3:3
        for k=0
            KernelParam = 2^i*KernelParamO;
            CostFactor  = 2^j*CostFactorO;
            NegativeWeight=2^k*NegativeWeightO;
            if ~isempty(playerNum)
                subfolder = [targetDir '/' datasetSelect featureSelect '/' tacticSelect featureSelect playerNum '/' EvaluationSelect '/SVM/' SVMType '/' SVMKernelType '/K=' num2str(KernelParam) 'C=' num2str(CostFactor) 'N=' num2str(NegativeWeight)];
            else
                subfolder = [targetDir '/' datasetSelect featureSelect '/' tacticSelect featureSelect '/' EvaluationSelect '/SVM/' SVMType '/' SVMKernelType '/K=' num2str(KernelParam) 'C=' num2str(CostFactor) 'N=' num2str(NegativeWeight)];
            end

            fileLists = dir([subfolder '/' SVMType '_validate*']);


            for f = 1:length(fileLists)
                %ConventMultiPlayerInst2SinglePlayer([filenamePrefix fileLists(f).name],5,3);
                %[bagAccu(f),instAccu(f)] = ConventMultiPlayerInst2SinglePlayer([subfolder '/' fileLists(f).name],5,str2double(playerNum));
                [bagAccu(f),instAccu(f)] = ConventMultiPlayerInst2SinglePlayerThreshold([subfolder '/' fileLists(f).name],5,str2double(playerNum));
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