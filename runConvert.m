clear all

addpath(genpath([pwd '/codes/MILL']));
% filenamePrefix = 'tuning/multiPlayers/syncLargeZoneDist/EVZoneDist3/cross_validate/SVM/inst_MI/RBF/K=0.1C=0.25N=1/';
% fileLists = dir([filenamePrefix 'inst_MI_validate*']);

targetDir = 'tuningUltimate/multiPlayers';
dataDir = 'dataUltimate/multiPlayers';
tacticSelect = {'F23','EV','HK','PD','PT','RB','SP','WS','WV','WW'};
datasetSelect = 'syncLarge';
SVMType = 'inst_MI'; %inst_MI
EvaluationSelect = 'cross_validate';
featureSelect = 'ZoneDist';
%featureSelect = 'ZoneSoftAssignDist';
%featureSelect = 'ZoneVelocitySoftAssign';
SVMKernelType = 'RBF';
playerNum = {'3','3','3','3','4','3','2','3','5','2'};

param.kernel = 5:-1:-5;
param.cost = 10:-1:-5;
param.negativeWeight = 0;
param.iter = 1;

CostFactorO  = 1;
NegativeWeight0 = 1;

for t = 1:length(tacticSelect)
    % automatic load the SVM kernel param depending on feature select
    inputfile = [dataDir '/' datasetSelect featureSelect '/' tacticSelect{t} featureSelect playerNum{t} '.data'];
    global preprocess
    preprocess.InputFormat = 0;
    preprocess.Normalization = 0;
    preprocess.Shuffled = 0;
    [~, ~, num_feature] = MIL_Data_Load(inputfile);
%     num_feature
%     pause
    clear preprocess
    KernelParamO = 1/num_feature;

    for i = param.kernel
        disp([datasetSelect featureSelect '/' tacticSelect{t} featureSelect '/']);    
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

                if ~isempty(validatefileLists)
                    for f = 1:length(validatefileLists)
                        %ConventMultiPlayerInst2SinglePlayer([filenamePrefix fileLists(f).name],5,3);
                        %[bagAccu(f),instAccu(f)] = ConventMultiPlayerInst2SinglePlayer([subfolder '/' fileLists(f).name],5,str2double(playerNum));
                        [bagAccu(f),instAccu(f)] = ConventMultiPlayerInst2SinglePlayerThreshold([subfolder '/' trainingfileLists(f).name],...
                            [subfolder '/' validatefileLists(f).name],5,str2double(playerNum{t}));
                    end

                    clear fileLists

                    %resultFile = [strrep(subfolder,'multiPlayers','multiPlayers/Convert') '/' SVMType '.data.result']
                    resultFile = [strrep(subfolder,'multiPlayers','multiPlayers/Convert(th)') '/' SVMType '.data.result'];
                    filesepIdx = strfind(subfolder,'/');
                    disp([subfolder(filesepIdx(end)+1:end) '/' SVMType ' converted...']);
                    str = ['Bag label accuracy = ' num2str(mean(bagAccu)) ', Instance label accuracy = ' num2str(mean(instAccu)) ', '];
                    fid = fopen(resultFile,'w');
                    fprintf(fid, str);
                    fclose(fid);
                else
                    filesepIdx = strfind(subfolder,'/');
                    disp(['skip ' subfolder(filesepIdx(end)+1:end) '!!']);
                    disp(['kernel times: ' int2str(i) ', cost times: ' int2str(j) ]);
                    pause(1)
                    continue
                end

                end
            end
        end
    end
end

rmpath(genpath([pwd '/codes/MILL']));