close all
clear all

tactics = {'F23','EV','HK','PD','PT','RB','SP','WS','WV','WW'};
%features = {'P','V','A','Arc','deltaA','deltaP','Zone','All'};
%features = {'P','V','A','Arc','deltaA','deltaP','jointAreaIoU'};
%features = {'Zone'};
features = {'P'};
evalOption = {'leave_one_out','cross_validate'};
%dataset = {'small','large'};
dataset = {'nonsyncLarge','syncLarge'};
svm = {'instMI','bagMI'};
%targetDir = 'dataResultForMILL';
%targetDir = 'dataJointArea';
%targetDir = 'data';
targetDir = 'tuning';

%query = [2 10];
query = 1:length(tactics);

for i=1:length(query)%:length(tactics)
    t = query(i);
    for d=1:length(dataset)
        for f=1:length(features)
            for s=1:length(svm)
                fid = figure(1);
                %figure('name',['tatic ' tactics{t} ',' dataset{d} ',' features{f}]);
                fid.Name = ['tatic ' tactics{t} ',' dataset{d} ',' features{f}];
                TuneSVMParam(targetDir,tactics{t},evalOption{2},dataset{d},features{f},svm{s});
                %pause
            end
        end
    end
end