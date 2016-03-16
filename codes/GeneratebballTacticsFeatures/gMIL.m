function gMIL(workingDir)
% reset system figures and variables
% clear all
% close all
addpath(genpath(workingDir));
addpath(genpath([workingDir '/utility']));

LoadTacticsParams;


% Load Pre-Label Trajectories Data
load([workingDir '/S.mat']);
% load('SAlign.mat');
% load('originS.mat');



% Load Half-court Image
court = imread([workingDir '/court.png']);
court = court(:, 326:end, :);
% leftHalfCourt = court(:,1:325,:);
% rightHalfCourt = court(:,326:end,:);

S = FixVideoMapping(S,court);

gtSAlign = AlignTraj(S,tactics.gtAlignment);

tacCentroid = [1 25 43 49 60 77 93 101 116 134];

tactics.refVideoIndex = tacCentroid;

%[gtavgDTWPerTactics,gtstdDTWPerTactics,gtTotalPlayerDTW] = CalculateAvgDTW(gtSAlign,tactics);

%ShowDTWonTactics(fileIO,court,gtavgDTWPerTactics,gtstdDTWPerTactics,gtTotalPlayerDTW,tactics,gtSAlign);

%[gtSAlignSync,~] = GenerateSyncData(gtSAlign,tactics,'first','P');
% [gtSAlignSyncFirstP,~] = GenerateSyncData(gtSAlign,tactics,'first','P');
% [gtSAlignSyncFirstPV,~] = GenerateSyncData(gtSAlign,tactics,'first','P+V');
% [gtSAlignSyncMinMedP,refMinMedP] = GenerateSyncData(gtSAlign,tactics,'minMed','P');
% [gtSAlignSyncMinMedPV,refMinMedPV] = GenerateSyncData(gtSAlign,tactics,'minMed','P+V');
% [gtSAlignSyncConcatP,~] = GenerateSyncData(gtSAlign,tactics,'concat','P');
% [gtSAlignSyncConcatPV,~] = GenerateSyncData(gtSAlign,tactics,'concat','P+V');
[gtSAlignSync,~] = GenerateSyncData(gtSAlign,tactics,'concat','P+V');

% if ~exist('gtSAlignSyncFirst.mat','file')
%     [gtSAlignSyncFirst,~] = GenerateSyncDataPV(gtSAlign,tactics,'first');
% else
%     load('gtSAlignSyncFirst.mat');
% end
% if ~exist('gtSAlignSyncMinMed.mat','file')
%     [gtSAlignSyncMinMed,refMinMed] = GenerateSyncDataPV(gtSAlign,tactics,'minMed');
% else
%     load('gtSAlignSyncMinMed.mat');
% end
% if ~exist('gtSAlignSyncConcat.mat','file')
%     [gtSAlignSyncConcat,~] = GenerateSyncDataPV(gtSAlign,tactics,'concat');
% else
%     load('gtSAlignSyncConcat.mat');
% end
% 
% %refMinMed = [3 2 3 5 4 5 1 2 2 3];%P
% refMinMed = [3 2 3 5 4 5 1 2 2 3]; %P+V

% CompareSyncDataInVideo(tactics,court,gtSAlign,gtSAlignSyncFirstP,gtSAlignSyncFirstPV,...
%     gtSAlignSyncMinMedP,refMinMedP,gtSAlignSyncMinMedPV,refMinMedPV,gtSAlignSyncConcatP,gtSAlignSyncConcatPV);

bballZone = LoadBasketballCourtParam(court);

for T = 1:size(gtSAlign,1)
    for p = 1:size(gtSAlign,2)
        gtVAlignSync{T,p} = makeDerivativeOfTime(gtSAlignSync{T,p});
        gtVAlign{T,p} = makeDerivativeOfTime(gtSAlign{T,p});
    end
end
% flip = 1;
% gtSAlignSyncFlip = GenerateSyncData(gtSAlign,tactics,flip);
stageNum = 10;
gtStagePosition = DownSamplingFeature(gtSAlignSync,stageNum);

gtStageVelocity = DownSamplingFeature(gtVAlignSync,stageNum);


featureName = {'P','V','P+V'};

MILLFeatureData{1} = gtStagePosition;
MILLFeatureData{2} = gtStageVelocity;

for T=1:size(gtStagePosition,1)
    for p=1:size(gtStagePosition,2)
        MILLFeatureData{3}{T,p} = [gtStagePosition{T,p} gtStageVelocity{T,p}];
    end
end

NonSyncMILLFeatureData{1} = DownSamplingFeature(gtSAlign,stageNum);
NonSyncMILLFeatureData{2} = DownSamplingFeature(gtVAlign,stageNum);

% gtStageZone = transformPositionToCourtIndex(gtStagePosition,bballZone,court);
% gtStageZoneP = GenerateZoneFeature(gtStageZone,gtStagePosition);
% gtStageZoneV = GenerateZoneFeature(gtStageZone,gtStageVelocity);

plotFlag = 1;
outputFeature = 0;
SYNC = 1;

Zone = 0;


playerNum = 1;
% single player raw sync feature (P,V,P+V)
GenerateMILFeature(playerNum,featureName,MILLFeatureData,tactics,SYNC)
% single player raw nonsync feature (P,V)
GenerateMILFeature(playerNum,featureName(1:2),NonSyncMILLFeatureData,tactics,~SYNC)

zoneFeature = {'ZoneDist'};

gtSZone = transformPositionToCourtIndex(gtSAlignSync,bballZone,court);
gtStageZoneProb = DownSamplingFeature(gtSZone,stageNum);

gtStageZoneProbM{1} = gtStageZoneProb;
mKeyPlayer{1} = tactics.keyPlayer;

[gtStageZoneProbM{2},mKeyPlayer{2}] = MultiplePlayerFeature(gtStageZoneProb,tactics.keyPlayer,2);

[gtStageZoneProbM{3},mKeyPlayer{3}] = MultiplePlayerFeature(gtStageZoneProb,tactics.keyPlayer,3);

[gtStageZoneProbM{4},mKeyPlayer{4}] = MultiplePlayerFeature(gtStageZoneProb,tactics.keyPlayer,4);

[gtStageZoneProbM{5},mKeyPlayer{5}] = MultiplePlayerFeature(gtStageZoneProb,tactics.keyPlayer,5);

for playerNum = 1:5
    GenerateMILFeature(playerNum,zoneFeature,gtStageZoneProbM(playerNum),tactics,SYNC,mKeyPlayer{playerNum});
end

% if outputFeature
%     for f = 1:length(featureName)
%         if ~Zone
%             %for ref = 1:length(tactics.refVideoIndex)
%                 if SYNC
%                     largeDataPath = ['../data/single/syncLargeStage' int2str(stageNum) featureName{f}];
%                     saveMILLFeatureData(tactics,MILLFeatureData{f},largeDataPath,featureName{f});
%                 else
%                     largeDataPath = ['../data/single/nonSyncLarge' featureName{f}];
%                     saveMILLFeatureData(tactics,NonSyncMILLFeatureData{f},largeDataPath,featureName{f});
%                 end
%             %end
%         else
%             largeDataPath = ['../data/single/syncLargeZone'];% featureName{f}];
%             saveMILLFeatureData(tactics,gtStageZone,largeDataPath,['Zone' ]);%featureName{f}]);
%         end
%     end
% end

% fileIO.sourceDir = ['Collected Tactics' filesep 'Total' filesep];
% fileIO.outputDir = ['Output' filesep];
% if ~exist(fileIO.outputDir,'dir')
%     mkdir(fileIO.outputDir);
% end


% if plotFlag
% for ref = 1:length(tactics.refVideoIndex)
% %     % visualize data as videos
% 
%     for T= tactics.videoIndex{ref}
%         testcase = int2str(T);
% 
%         sortedImagFiles = readsortimagfiles([fileIO.sourceDir testcase filesep]);
%         imagNum = size(sortedImagFiles,1);
%         for ss = 1:10
%             hit = sum(ismember(tactics.videoIndex{ss},T));
%             if hit
%                 break
%             else
%                 continue
%             end
%            display(['Video' int2str(T) ' Tactics ' tactics.Name{ss} '...Video Frame: ' int2str(imagNum) ', Trajectory Duration: ' int2str(size(S{T,1},1))]);
% 
%         %    if halfCourt(T)
%         %        court = leftHalfCourt;
%         %    else
%         %        court = rightHalfCourt;
%         %    end
%         %   ShowTaticLabeledVideo(fileIO,testcase,sortedImagFiles,court,S(T,:));
%         %   ShowBasketballTrajAlign(fileIO,testcase,sortedImagFiles,court,S(T,:), [],gtSAlign(T,:));
%             ShowTacticSyncResult(fileIO, testcase, court, gtSAlign(T,:), gtSAlignSync(T,:),gtSAlign(tactics.refVideoIndex(ref),:),tactics.refVideoIndex(ref));
%         %   ShowTacticFeatureResult(fileIO, testcase, court, gtSAlign(T,:), gtSAlignSync(T,:),gtStagePosition(T,:));
%         %ShowTacticFeatureResult(fileIO, testcase, court, gtSAlign(T,:), gtSAlign(T,:),gtStagePosition(T,:));
%         %CompareSyncOrNotFeatureResult(fileIO, testcase, court, gtSAlign(T,:), gtSAlignSync(T,:),NonSyncMILLFeatureData{1}(T,:),gtStagePosition(T,:))
%            pause(1);
%         end
%        display(['Video' int2str(T) ' Tactics ' tactics.Name{ss} '...Video Frame: ' int2str(imagNum) ', Trajectory Duration: ' int2str(size(S{T,1},1))]);
% 
%     %    if halfCourt(T)
%     %        court = leftHalfCourt;
%     %    else
%     %        court = rightHalfCourt;
%     %    end
%     %   ShowTaticLabeledVideo(fileIO,testcase,sortedImagFiles,court,S(T,:));
%        ShowBasketballTrajAlign(fileIO,testcase,sortedImagFiles,court,S(T,:), [],gtSAlign(T,:));
%     %    ShowTacticSyncResult(fileIO, testcase, court, gtSAlign(T,:), gtSAlignSync(T,:),gtSAlign(tactics.refVideoIndex(ref),:),tactics.refVideoIndex(ref));
%     %   ShowTacticFeatureResult(fileIO, testcase, court, gtSAlign(T,:), gtSAlignSync(T,:),gtStagePosition(T,:));
%     %ShowTacticFeatureResult(fileIO, testcase, court, gtSAlign(T,:), gtSAlign(T,:),gtStagePosition(T,:));
%        pause(1);
%     end
% 
% end
% end


rmpath(genpath('utility'));