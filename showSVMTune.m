close all
clear all

tactics = {'F23','EV','HK','PD','PT','RB','SP','WS','WV','WW'};
%features = {'P','V','A','Arc','deltaA','deltaP','Zone','All'};
%features = {'P','V','A','Arc','deltaA','deltaP','jointAreaIoU'};
%features = {'Zone','ZoneV'};
%features = {'P+V'}%,'V'};
%features = {'ZoneDist'};
features = {'P','V'};
%features = {'Zone'}
evalOption = {'leave_one_out','cross_validate'};
%dataset = {'small','large'};
dataset = {'nonSyncLarge','syncLarge'};
svm = {'inst_MI','bag_MI'};
SVMKernelType = 'RBF'; % RBF,linear

targetDir = 'tuningNEW';

% multiple players setting
% group = 'multiPlayers/Convert(Th)';
% playerNum = {'3','3','3','3','3','3','2','3','5','2'};

% % % single player setting
group = 'singlePlayer';
% playerNum = {'1','1','1','1','1','1','1','1','1','1'};
playerNum = {'','','','','','','','','',''};

param.kernel0 = 1;

param.kernel = 3:-1:-15;
param.cost = 15:-1:-5;
param.negativeWeight = 0;


query = [1:10];

for i=1:length(query)%:length(tactics)
    t = query(i);
    for d=2%:length(dataset)
        for f=1:length(features)
            for s=1%:length(svm)
                fid = figure(1);
                %figure('name',['tatic ' tactics{t} ',' dataset{d} ',' features{f}]);
                fid.Name = ['tatic ' tactics{t} ',' dataset{d} ',' features{f}];
                TuneSVMParam([targetDir '/' group],playerNum{i},tactics{t},evalOption{d},dataset{d},features{f},svm{s},SVMKernelType);
                pause
            end
        end
    end
end