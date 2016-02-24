close all
clear all

tactics = {'F23','EV','HK','PD','PT','RB','SP','WS','WV','WW'};
%features = {'P','V','A','Arc','deltaA','deltaP','Zone','All'};
features = {'P','V','A','Arc','deltaA','deltaP','jointAreaIoU'};
%features = {'Zone'};
evalOption = {'leave_one_out','cross_validate'};
dataset = {'small','large'};
svm = {'instMI','bagMI'};
%targetDir = 'dataResultForMILL';
%targetDir = 'dataJointArea';
targetDir = 'data';

query = [2 10];


for i=1:length(query)%:length(tactics)
    t = query(i);
    for d=2%:length(dataset)
        for f=1:length(features)
            for s=1:length(svm)
                fid = figure(1);
                %figure('name',['tatic ' tactics{t} ',' dataset{d} ',' features{f}]);
                fid.Name = ['tatic ' tactics{t} ',' dataset{d} ',' features{f}];
                TuneSVMParam(targetDir,tactics{t},evalOption{d},dataset{d},features{f},svm{s});
                pause
            end
        end
    end
end