function showSVMTune(param,EvaluationMethod,kernelType,SVMType,dataset) 
addpath(genpath([pwd '/codes/MILL']));

tactics = {'F23','EV','HK','PD','PT','RB','SP','WS','WV','WW'};

% features = {'ZoneDist'};
% features = {'ZoneSoftAssignDist'};
% features = {'ZoneVelocitySoftAssign'};
features= {'ZoneVSoftAssignConcat'};
% features = {'P','V'};
% features = {'Zone'}
evalOption = {'leave_one_out','cross_validate'};
dataset = {'nonSyncLarge','syncLarge'};
svm = {'inst_MI','bag_MI'};
SVMKernelType = 'RBF'; % RBF,linear

targetDir = 'tuningUltimate';
dataDir = 'dataUltimate';

% % multiple players setting
group = 'multiPlayers';
Converted = 'Convert(Th)';
% playerNum = {'3','3','3','3','4','3','2','3','5','2'};
playerNum = {'','','','','','','','','',''};

% % single player setting
% group = 'singlePlayer';
% Converted ='';
% if strfind(features{1},'Zone')
%     playerNum = {'1','1','1','1','1','1','1','1','1','1'};
% else    
%     playerNum = {'','','','','','','','','',''};
% end





query = [1:10];

for i=1:length(query)%:length(tactics)
    t = query(i);
    for d=2%:length(dataset)
        for f=1:length(features)
            for s=1%:length(svm)
                fid = figure(1);
                %figure('name',['tatic ' tactics{t} ',' dataset{d} ',' features{f}]);
                fid.Name = ['tatic ' tactics{t} ',' dataset{d} ',' features{f}];
                
                inputfile = [dataDir '/' group '/' dataset{d} features{f} '/' tactics{t} features{f} playerNum{i} '.data'];
                global preprocess
                preprocess.InputFormat = 0;
                preprocess.Normalization = 0;
                preprocess.Shuffled = 0;
                [~, ~, num_feature] = MIL_Data_Load(inputfile);
                % num_feature
                % pause(0.5)
                clear preprocess
                param.kernel0 = 1/num_feature; %default is 1 (or 1/num_feature)
                
                
                TuneSVMParam(param,[targetDir '/' group '/' Converted],playerNum{i},tactics{t},evalOption{d},dataset{d},features{f},svm{s},SVMKernelType);
                pause
            end
        end
    end
end

rmpath(genpath([pwd '/codes/MILL']));