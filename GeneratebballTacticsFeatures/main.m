
% reset system figures and variables
clear all
close all
addpath(genpath('utility'));

LoadTacticsParams;


% Load Pre-Label Trajectories Data
load('S.mat');
% load('SAlign.mat');
% load('originS.mat');



% Load Half-court Image
court = imread('court.png');
court = court(:, 326:end, :);
% leftHalfCourt = court(:,1:325,:);
% rightHalfCourt = court(:,326:end,:);

S = FixVideoMapping(S,court);

gtSAlign = AlignTraj(S,tactics.gtAlignment);

gtSAlignSync = GenerateSyncData(gtSAlign,tactics);

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

featureName = {'P','V'};

MILLFeatureData{1} = gtStagePosition;
MILLFeatureData{2} = gtStageVelocity;

NonSyncMILLFeatureData{1} = DownSamplingFeature(gtSAlign,stageNum);
NonSyncMILLFeatureData{2} = DownSamplingFeature(gtVAlign,stageNum);

plotFlag = 1;
SYNC = 0;

fileIO.sourceDir = ['Collected Tactics' filesep 'Total' filesep];
fileIO.outputDir = ['Output' filesep];
if ~exist(fileIO.outputDir,'dir')
    mkdir(fileIO.outputDir);
end

%for f = 1%:length(featureName)
for ref = 1:length(tactics.refVideoIndex)
%     if SYNC
%         largeDataPath = ['../data/single/syncLarge' featureName{f}];
%         saveMILLFeatureData(tactics,MILLFeatureData{f},largeDataPath,featureName{f});
%     else
%         largeDataPath = ['../data/single/nonSyncLarge' featureName{f}];
%         saveMILLFeatureData(tactics,NonSyncMILLFeatureData{f},largeDataPath,featureName{f});
%     end
%     % visualize data as videos
    if plotFlag    
        for T= tactics.videoIndex{ref}
            testcase = int2str(T);

            sortedImagFiles = readsortimagfiles([fileIO.sourceDir testcase filesep]);
            imagNum = size(sortedImagFiles,1);
            for ss = 1:10
                hit = sum(ismember(tactics.videoIndex{ss},T));
                if hit
                    break
                else
                    continue
                end
            end
           display(['Video' int2str(T) ' Tactics ' tactics.Name{ss} '...Video Frame: ' int2str(imagNum) ', Trajectory Duration: ' int2str(size(S{T,1},1))]);

        %    if halfCourt(T)
        %        court = leftHalfCourt;
        %    else
        %        court = rightHalfCourt;
        %    end
        %   ShowTaticLabeledVideo(fileIO,testcase,sortedImagFiles,court,S(T,:));
        %   ShowBasketballTrajAlign(fileIO,testcase,sortedImagFiles,court,S(T,:), [],gtSAlign(T,:));
        %    ShowTacticSyncResult(fileIO, testcase, court, gtSAlign(T,:), gtSAlignSync(T,:),gtSAlign(tactics.refVideoIndex(ref),:),tactics.refVideoIndex(ref));
        %   ShowTacticFeatureResult(fileIO, testcase, court, gtSAlign(T,:), gtSAlignSync(T,:),gtStagePosition(T,:));
        ShowTacticFeatureResult(fileIO, testcase, court, gtSAlign(T,:), gtSAlign(T,:),gtStagePosition(T,:));
           pause(1);
        end
    end
end
%end


rmpath(genpath('utility'));