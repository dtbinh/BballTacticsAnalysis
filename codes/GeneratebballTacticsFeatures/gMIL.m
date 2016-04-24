function gMIL(workingDir,featureSet)
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
[h w c] = size(court);
% leftHalfCourt = court(:,1:325,:);
% rightHalfCourt = court(:,326:end,:);

S = FixVideoMapping(S,court);

gtSAlign = AlignTraj(S,tactics.gtAlignment);

tacCentroid = [1 25 43 49 60 77 93 101 116 134];

tactics.refVideoIndex = tacCentroid;

Traj = gtSAlign(tacCentroid,:);
if  ~exist('gtCentroidAssign.mat','file')
    [gtCentroidAssign,gtCentroidCost] = FindGTCentroidAlign(tactics,Traj,'P+V');
    save('gtCentroidAssign.mat','gtCentroidAssign');
else
    load('gtCentroidAssign.mat');
end


fileIO.sourceDir = ['Collected Tactics' filesep 'Total' filesep];
fileIO.outputDir = ['Output' filesep];
if ~exist(fileIO.outputDir,'dir')
    mkdir(fileIO.outputDir);
end
%ShowGTCentroidTrajAlign(fileIO,court,Traj,gtCentroidAssign,gtCentroidCost,tactics)

%[gtavgDTWPerTactics,gtstdDTWPerTactics,gtTotalPlayerDTW] = CalculateAvgDTW(gtSAlign,tactics);

%ShowDTWonTactics(fileIO,court,gtavgDTWPerTactics,gtstdDTWPerTactics,gtTotalPlayerDTW,tactics,gtSAlign);

%[gtSAlignSync,~] = GenerateSyncData(gtSAlign,tactics,'first','P');
% [gtSAlignSyncFirstP,~] = GenerateSyncData(gtSAlign,tactics,'first','P');
% [gtSAlignSyncFirstPV,~] = GenerateSyncData(gtSAlign,tactics,'first','P+V');
% [gtSAlignSyncMinMedP,refMinMedP] = GenerateSyncData(gtSAlign,tactics,'minMed','P');
% [gtSAlignSyncMinMedPV,refMinMedPV] = GenerateSyncData(gtSAlign,tactics,'minMed','P+V');
% [gtSAlignSyncConcatP,~] = GenerateSyncData(gtSAlign,tactics,'concat','P');
% [gtSAlignSyncConcatPV,~] = GenerateSyncData(gtSAlign,tactics,'concat','P+V');
if  ~exist('gtSAlignSync.mat','file')
    [gtSAlignSync,~] = GenerateSyncData(gtSAlign,tactics,'concat','P+V');
    save('gtSAlignSync.mat','gtSAlignSync');
else
    load('gtSAlignSync.mat');
end
% courtArea = imread('courtZone.png');
% ShowTrajOnCourtArea(gtSAlignSync,tactics,courtArea)

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
plotFlag = 1;
outputFeature = 0;
SYNC = 1;
stageNum = 10;
Zone = 0;



if sum(ismember(featureSet,{'P','V','P+V'}))

frameRate = 30;
for T = 1:size(gtSAlign,1)
    for p = 1:size(gtSAlign,2)
        gtSAlignSyncN{T,p}(:,1) = gtSAlignSync{T,p}(:,1)/w;
        gtSAlignSyncN{T,p}(:,2) = gtSAlignSync{T,p}(:,2)/h;
        gtVAlignSync{T,p} = makeDerivativeOfTime(gtSAlignSyncN{T,p},frameRate);
        gtVAlign{T,p} = makeDerivativeOfTime(gtSAlign{T,p},frameRate);
    end
end
% flip = 1;
% gtSAlignSyncFlip = GenerateSyncData(gtSAlign,tactics,flip);

gtStagePosition = DownSamplingFeature(gtSAlignSyncN,stageNum);

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




playerNum = 1;
% single player raw sync feature (P,V,P+V)
GenerateMILFeature(playerNum,featureName,MILLFeatureData,tactics,gtCentroidAssign,SYNC)
% single player raw nonsync feature (P,V)
GenerateMILFeature(playerNum,featureName(1:2),NonSyncMILLFeatureData,tactics,gtCentroidAssign,~SYNC)
end


if sum(ismember(featureSet,{'ZoneDist'}))
% Hard Assigment
zoneFeature = {'ZoneDist'};

if ~exist('gtSZone.mat','file')
    gtSZone = transformPositionToCourtIndex(gtSAlignSync,bballZone,court);
    save('gtSZone.mat','gtSZone');
else
    load('gtSZone.mat');
end
gtStageZoneProb = DownSamplingFeature(gtSZone,stageNum);

gtStageZoneProbM{1} = gtStageZoneProb;
mKeyPlayer{1} = tactics.keyPlayer;
% ================================================================================================
% [gtStageZoneProbM{2},mKeyPlayer{2}] = MultiplePlayerFeature(gtStageZoneProb,tactics.keyPlayer,2);
% 
% [gtStageZoneProbM{3},mKeyPlayer{3}] = MultiplePlayerFeature(gtStageZoneProb,tactics.keyPlayer,3);
% 
% [gtStageZoneProbM{4},mKeyPlayer{4}] = MultiplePlayerFeature(gtStageZoneProb,tactics.keyPlayer,4);
% 
% [gtStageZoneProbM{5},mKeyPlayer{5}] = MultiplePlayerFeature(gtStageZoneProb,tactics.keyPlayer,5);
% 
% for playerNum = 1:5
%     GenerateMILFeature(playerNum,zoneFeature,gtStageZoneProbM(playerNum),tactics,gtCentroidAssign,SYNC,mKeyPlayer{playerNum});
% end
% =================================================================================================
for playerNum = 1:5
    GenerateMILFeature(playerNum,zoneFeature,gtStageZoneProbM,tactics,gtCentroidAssign,SYNC,mKeyPlayer{1});
end
end

% Soft Assignment
basketballArea = LoadBasketballCourtArea;
radius = 15;
minW = 1e-3;

if sum(ismember(featureSet,{'ZoneSoftAssignDist'}))

for v = 1:size(gtSAlignSync,1)
    for p = 1:size(gtSAlignSync,2)
        for f = 1:size(gtSAlignSync{v,p},1)
            %gtSAreaSoftAssign{v,p}(f,:) = zeros(1,length(basketballArea));
            c = gtSAlignSync{v,p}(f,1);
            r = gtSAlignSync{v,p}(f,2);
            for a = 1:length(basketballArea)
                distArray(a) = sqrt((c-basketballArea(a).CenterPosition(1))^2+ (r-basketballArea(a).CenterPosition(2))^2);
            end
            GMMWeight = exp(-distArray./(radius*2));
            GMMWeight = GMMWeight/sum(GMMWeight);
            GMMWeight(find(GMMWeight<minW)) = 0;
            gtSAreaSoftAssign{v,p}(f,:) = GMMWeight;
        end
    end
end
gtPhaseAreaProb = DownSamplingFeature(gtSAreaSoftAssign,stageNum);
gtPhaseAreaProbM{1} = gtPhaseAreaProb;
zoneFeature = {'ZoneSoftAssignDist'};
for playerNum = 2:5
    GenerateMILFeature(playerNum,zoneFeature,gtPhaseAreaProbM,tactics,gtCentroidAssign,SYNC ,tactics.keyPlayer);
end

end
if sum(ismember(featureSet,{'ZoneVelocitySoftAssign'}))
Direction = [0 1/4 1/2 3/4 1 -3/4 -1/2 -1/4]*pi;
frameRate = 30;
% velocity soft assignment
for T = 1:size(gtSAlignSync,1)
    disp(['Video ' int2str(T) ' processing ...']);
    for p = 1:size(gtSAlignSync,2)
        for f = 1:size(gtSAlignSync{T,p},1)
            c = gtSAlignSync{T,p}(f,1);
            r = gtSAlignSync{T,p}(f,2);
            for a = 1:length(basketballArea)
                distArray(a) = sqrt((c-basketballArea(a).CenterPosition(1))^2+ (r-basketballArea(a).CenterPosition(2))^2);
            end
            GMMWeight = exp(-distArray./(radius*2));
            GMMWeight = GMMWeight/sum(GMMWeight);
            GMMWeight(find(GMMWeight<minW)) = 0;
            
            if f ~= size(gtSAlignSync{T,p},1)
                v = frameRate*(gtSAlignSync{T,p}(f+1,:) - gtSAlignSync{T,p}(f,:));
            else
                v = frameRate*(gtSAlignSync{T,p}(f,:) - gtSAlignSync{T,p}(f-1,:));
            end
            vMag = sqrt(v(1)^2+v(2)^2);
            vAng = atan2(v(2),v(1));
            for t = 1:length(Direction)
                %weight(t) = cos((vAng-Direction(t))/2)^4;
                weight(t) = circ_vmpdf(Direction(t),vAng,2);
            end
            Prob = weight/sum(weight);
            for a = 1:length(basketballArea)
                gtVZoneSoftAssign{T,p}(f,(a-1)*length(Direction)+1:a*length(Direction)) = GMMWeight(a)*Prob*vMag;
            end
        end
    end
end
gtVPhaseAreaProb = DownSamplingFeature(gtVZoneSoftAssign,stageNum);
gtVPhaseAreaProbM{1} = gtVPhaseAreaProb;
zoneFeature = {'ZoneVelocitySoftAssign'};
for playerNum = 2:5
    GenerateMILFeature(playerNum,zoneFeature,gtVPhaseAreaProbM,tactics,gtCentroidAssign,SYNC ,tactics.keyPlayer);
end
end

if sum(ismember(featureSet,{'ZoneVSoftAssignConcat'}))
    Direction = [0 1/4 1/2 3/4 1 -3/4 -1/2 -1/4]*pi;
    frameRate = 30;
    % velocity soft assignment
    for T = 1:size(gtSAlignSync,1)
        disp(['Video ' int2str(T) ' processing ...']);
        for p = 1:size(gtSAlignSync,2)
            for f = 1:size(gtSAlignSync{T,p},1)
                c = gtSAlignSync{T,p}(f,1);
                r = gtSAlignSync{T,p}(f,2);
                for a = 1:length(basketballArea)
                    distArray(a) = sqrt((c-basketballArea(a).CenterPosition(1))^2+ (r-basketballArea(a).CenterPosition(2))^2);
                end
                GMMWeight = exp(-distArray./(radius*2));
                GMMWeight = GMMWeight/sum(GMMWeight);
                GMMWeight(find(GMMWeight<minW)) = 0;

                if f ~= size(gtSAlignSync{T,p},1)
                    v = frameRate*(gtSAlignSync{T,p}(f+1,:) - gtSAlignSync{T,p}(f,:));
                else
                    v = frameRate*(gtSAlignSync{T,p}(f,:) - gtSAlignSync{T,p}(f-1,:));
                end
                vMag = sqrt(v(1)^2+v(2)^2);
                vAng = atan2(v(2),v(1));
                for t = 1:length(Direction)
                    %weight(t) = cos((vAng-Direction(t))/2)^4;
                    weight(t) = circ_vmpdf(Direction(t),vAng,2);
                end
                Prob = weight/sum(weight);
                for a = 1:length(basketballArea)
                    gtVZoneSoftAssign{T,p}(f,(a-1)*length(Direction)+1:a*length(Direction)) = GMMWeight(a)*Prob*vMag;
                end
            end
        end
    end
    gtVPhaseAreaProb = DownSamplingFeature(gtVZoneSoftAssign,stageNum);
    gtVPhaseAreaProbM{1} = gtVPhaseAreaProb;
    zoneFeature = {'ZoneVSoftAssignConcat'};
    playerNum = [];
    GenerateMILFeature(playerNum,zoneFeature,gtVPhaseAreaProbM,tactics,gtCentroidAssign,SYNC ,tactics.keyPlayer);
   
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
rmpath(genpath(workingDir));
end