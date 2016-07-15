function BatchAllTacticOnce(param,EvaluationMethod,kernelType,SVMType,dataset) 

% eg: EvaluationMethod = 'cross_validate')
%     kernelType = 'linear','RBF'
%     SVMType = 'inst_MI','bag_MI'


% Test SVM Parameter
homePathName = '..';
[datafile,pathName] = uigetfile([homePathName filesep  'data/*.data'], 'MultiSelect', 'on');
if iscell(datafile)
    nbfiles = length(datafile);
elseif datafile ~= 0
    nbfiles = 1;
else
    nbfiles = 0;
end

display(datafile);


while ~exist('normalization','var') || (~strcmp(normalization,'1') && ~strcmp(normalization,'0'))
    normalization = input('Q: Need Normalization?(Dist:No [type 0], Other:Yes [type 1])','s');
end

outputPath = strrep(pathName,'data','tuning'); 

if strcmp(EvaluationMethod,'leave_one_out')
    EvalCmd = '-sf 0 -- leave_one_out';
elseif strcmp(EvaluationMethod,'cross_validate')
    EvalCmd = '-sf 1 -- cross_validate -t 5';  % -shuffle in cross-validation
end

% start timer
mkdir('tmp');
param.num_fold = 5;
%% check bag separation existence
[train_bagIdx,test_bagIdx] = checkBagSep(param.num_fold);

tic

for x = 1:num_fold
    for f=1:nbfiles     

        tmpPath = strrep(pathName,'data','tmp'); 
        %% Specify datafile input and tactic name
        if iscell(datafile)
            tacticName = strtok(datafile{f},'.');        
            inputfile = [pathName datafile{f}];

        else
            tacticName = strtok(datafile,'.');
            inputfile = [pathName datafile];
        end

        %% automatic load the SVM depending on feature select
        global preprocess
        preprocess.InputFormat = 0;
        preprocess.Normalization = 0;
        preprocess.Shuffled = 0;
        [bags, ~, num_feature] = MIL_Data_Load(inputfile);
    %     num_feature
    %     pause(5)
        clear preprocess
        KernelParamO = 1/num_feature;  %KernelParamO = 0.05 (default);
        CostFactorO  = 1;
        NegativeWeightO = 1;
        param.kernel0 = KernelParamO;
        
%      if strcmp(dataset,'Training')  %no use by now
        
        mkdir([tmpPath 'train' int2str(x)]);

        tmpFilePrefix = [tmpPath 'train' int2str(x) '/' tacticName];       

        % Save Training and Testing data
        train_bags = bags(train_bagIdx{x});
        test_bags = bags(test_bagIdx{x});
        train_data_file = [tmpFilePrefix '_train' int2str(x) '.data'];
        test_data_file = [tmpFilePrefix '_test' int2str(x) '.data'];
        
        if ~exist(train_data_file,'file')
            MIL_Data_Save(train_data_file,train_bags);
            MIL_Data_Save(test_data_file,test_bags);
        else
            disp([train_data_file ' exist!!']);
        end
        %% Execute cross_validate on Training data for tuning param
        for i = param.kernel
            for j= param.cost         
                for k= param.negativeWeight
                    KernelParam = 2^i*KernelParamO;
                    CostFactor  = 2^j*CostFactorO;
                    NegativeWeight=2^k*NegativeWeightO;


                    for iter = 1:param.iter
                        if param.iter == 1
                            subfolder = [strtok(train_data_file,'.') '/' EvaluationMethod '/SVM/' SVMType '/' kernelType '/K=' num2str(KernelParam) 'C=' num2str(CostFactor) 'N=' num2str(NegativeWeight) '/'];
                        else
                            subfolder = [strtok(train_data_file,'.') '/'  EvaluationMethod '/SVM/' SVMType '/' kernelType '/K=' num2str(KernelParam) 'C=' num2str(CostFactor) 'N=' num2str(NegativeWeight) '/iter' int2str(iter) '/'];
                        end
                        if ~exist(subfolder,'dir')
                            mkdir(subfolder);    

                            MIL_Run(['classify -t ' train_data_file ' -o ' ...
                                subfolder SVMType '.data.result -p ' subfolder SVMType '.data.pred -if 0 -n ' normalization ' -distrib 0 ' EvalCmd ' -- ' SVMType '_SVM -Kernel 2 -KernelParam ' ...
                                num2str(KernelParam) ' -CostFactor ' num2str(CostFactor) ' -NegativeWeight ' num2str(NegativeWeight)]);
                        else
                            continue
                        end
                    end
                 end
            end
        end
        
        %% Find SVM Param from tuning data
        if strfind(train_data_file,'singlePlayer')
            svmsetting = TuneSVMParam(param,strtok(train_data_file,'.'),EvaluationMethod,SVMType,kernelType);
        else
            if ~exist(strrep(strtok(train_data_file,'.'),'multiPlayers', 'multiPlayers/Convert(Th)'),'dir')
                runConvert(param,strtok(train_data_file,'.'),EvaluationMethod,SVMType,kernelType);
            end
            svmsetting = TuneSVMParam(param,strtok(train_data_file,'.'),EvaluationMethod,SVMType,kernelType);
        end
                
        %% re-training whole training data on given optimal SVM param
        model_data_file = [strtok(train_data_file,'.') '/model.txt'];
        MIL_Run(['classify -t ' train_data_file  ' -- train_only -m ' model_data_file ...
            ' -- inst_MI_SVM -Kernel 2 ¡VKernelParam ' num2str(svmsetting.kernel) ' -CostFactor ' num2str(svmsetting.cost)]);% ' -Threshold ' threshold]);
%         end
        %% apply trained model file to preserved test data without any threshold constraint        
        MIL_Run(['classify -t ' test_data_file ' -- test_only -m ' model_data_file ' -- inst_MI_SVM']);
        
        
        %% Load all tactic test result in each validation circle
        [testbag{x,f},test_inst{x,f},test_instGT{x,f},test_inst_prob{x,f}] = ReadClassificationFile(strrep(test_data_file,'.data','_validate.txt'));
        % Convert instance to player 
        if strfind(test_data_file,'singlePlayer')
            %[testbag{x,f},test_inst{x,f},test_instGT{x,f},test_inst_prob{x,f}] = ReadClassificationFile(strrep(test_data_file,'.data','_validate.txt'));
            %% translate text to integer array
            test_Inst_container = cell2mat(test_inst{x,f}); 
            test_InstGT_container = cell2mat(test_instGT{x,f});
            for v = 1:size(test_Inst_container,1)
                for i = 1:size(test_Inst_container,2)
                    test_player{x,f}(v,i) = str2double(test_Inst_container(v,i));
                    test_playerGT{x,f}(v,i) = str2double(test_InstGT_container(v,i));
                    test_player_prob{x,f}(v,i) = test_inst_prob{x,f}(v,i);
                end
        end            
        else
%             [testbag{x,f},Y_label,Y_GT,Y_prob] = ReadClassificationFile(strrep(test_data_file,'.data','_validate.txt'));
            tmpIdx = strfind(test_data_file,'_');
            k = str2num(test_data_file(tmpIdx-1));
            playerNum = 5;
          
            test_bag_prob{x,f} = max(test_inst_prob{x,f},[],2);
            [test_player{x,f},test_player_prob{x,f}] = ClassifyBagInstanceWithThreshold(test_inst_prob{x,f},test_bag_prob{x,f},playerNum,k,svmsetting.Th);
            test_playerGT{x,f} = ConvertGTInst(test_instGT{x,f},playerNum,k);
        end
    end

    %% rearrange data to video-oriented {movie,tactic1_label,tactic2_label,...,tacticN_label}
% %     for f = 1:nbfiles
% %         for vid = 1:size(testbag{x,f},1)
% % %             str = testbag{1,f}{vid};
% % %             vidnum = strfind(str,'-');
% % %             result(vid,f).Idx = str2num(str(vidnum+1:end));
% %         
% % %         %% translate text to integer array
% % %         test_Inst_container = cell2mat(test_inst{x,f}); 
% % %         test_InstGT_container = cell2mat(test_instGT{x,f});
% % %         for v = 1:size(test_Inst_container,1)
% % %             for i = 1:size(test_Inst_container,2)
% % %                 result(v,f).playerLabel(i) = str2double(test_Inst_container(v,i));
% % %                 
% % %                 result(v,f).playerLabelGT(i) = str2double(test_InstGT_container(v,i));
% % %                 result(v,f).instProb(i) = test_inst_prob{x,f}(v,i);
% % %             end
% % % %             i
% % % %             x
% % % %             v
% % % %             f
% % % %             size(test_Inst_container)
% % % %             size(test_InstGT_container)
% % %             result(v,f).bagLabel = max(result(v,f).playerLabel(:));
% % %             result(v,f).bagLabelGT = max(result(v,f).playerLabelGT(:));
% % %             result(v,f).bagProb = max(result(v,f).instProb(:));
% % %             bagLabelMap{x}(v,f) = max(result(v,f).playerLabel(:));
% % %             bagProbMap{x}(v,f) = max(result(v,f).instProb(:));
% % %             bagLabelGTMap{x}(v,f) = max(result(v,f).playerLabelGT(:));
% % %             instLabelMap{x}{v,f} = result(v,f).playerLabel;
% % %             isntLabelTempMap{x}{v,f} = result(v,f).playerLabelGT;
% % %         end
% %             bagProbMap{x}(vid,f) = max(test_inst_prob{x,f}(vid,:),[],2);
% %             bagLabelGTMap{x}(vid,f) = max(test_playerGT{x,f}(vid,:),[],2);
% %             instLabelMap{x}{vid,f} = test_player{x,f}(vid,:);
% %             isntLabelTempMap{x}{vid,f} =  test_playerGT{x,f}(vid,:);
% %         end
% %     end
% %     eachVideoMaxProb = max(bagProbMap{x},[],2);
% %     for vid = 1:size(bagProbMap{x},1)
% %         bagLabelMaxProbMap{x}(vid,:) = bagProbMap{x}(vid,:) >= eachVideoMaxProb(vid);
% %         for tactic = 1:size(bagProbMap{x},2)
% %             if bagLabelMaxProbMap{x}(vid,tactic)
% %                 instLabelMaxProbMap{x}(vid,:) = instLabelMap{x}{vid,tactic};
% %             end
% %             if bagLabelGTMap{x}(vid,tactic)
% %                 instLabelGTMap{x}(vid,:) = isntLabelTempMap{x}{vid,tactic};                
% %             end
% %         end
% %     end
% %     [inst.Accu(x), inst.Prec(x), inst.Reca(x), inst.F1(x)] = InstCalculatePerformanceOfClassification(instLabelMaxProbMap{x},instLabelGTMap{x});
% %     bag.Accu(x) = BagCalculatePerformanceOfClassification(bagLabelMaxProbMap{x},bagLabelGTMap{x});

end
%                 if strfind(test_data_file,'singlePlayer')
%                     [testbag,test_Inst,test_instGT,test_inst_prob] = ReadClassificationFile(strrep(test_data_file,'.data','_validate.txt'));
%                     for v = 1:size(test_Inst,1)
%                         for i = 1:size(test_Inst{v,:},2)
%                             playerLabel(v,i) = str2double(test_Inst{v}(i));
%                             playerLabelGT(v,i) = str2double(test_instGT{v}(i));
%                         end
%                     end
%                     [Accu(x), Prec(x), Reca(x), F1(x)] = CalculatePerformanceOfClassification(playerLabel,playerLabelGT);
%                 else
%                     [testbag,test_Inst,test_instGT,test_inst_prob] = ReadClassificationFile(strrep(test_data_file,'.data','_validate.txt'));
%                     test_bag_prob = max(test_inst_prob,[],2);
%                     k = 3; playerNum = 5;
%                     if ~isnan(k)
%                         C = nchoosek(1:playerNum,k);
%                         for i = 1:size(C,1)
%                             A(i,:) = zeros(1,playerNum);
%                             for j = 1:size(C,2)
%                                 A(i,C(i,j)) = 1;
%                             end
%                         end
%                     else
%                         counter = 1;
%                         for p = 2:playerNum
%                             C = nchoosek(1:playerNum,p);
%                             for i = 1:size(C,1)
%                                 A(counter,:) = zeros(1,playerNum);
%                                 for j = 1:size(C,2)
%                                     A(counter,C(i,j)) = 1;
%                                 end
%                                 counter = counter + 1;
%                             end
%                         end
%                     end
%                     [Y_label,Y_prob] = ClassifyBagInstanceWithThreshold(test_inst_prob,test_bag_prob,A,playerNum,k,svmsetting.Th);
%                     test_playerGT = ConvertGTInst(test_instGT,A);
%                     [Accu(x), Prec(x), Reca(x), F1(x)] = CalculatePerformanceOfClassification(Y_label,test_playerGT);
%                 end
%         end
%         filesepIdx = strfind(pathName,'/');
%         F1
%         disp([pathName(filesepIdx(end-1)+1:filesepIdx(end)) tacticName ' has mean F1 = ' num2str(mean(F1))]);
%         pause
% 
%     end
% 
% 
%     
% end
toc
    disp([dataset ' ' int2str(x) ', bag Accuracy:' num2str(mean(bag.Accu)) ', inst Accuracy:' num2str(mean(inst.Accu)) ', inst F1:' num2str(mean(inst.F1))]);
    pause

end

function player_label = ConvertGTInst(instGt_label,playerNum,k)
    C = nchoosek(1:playerNum,k);
    for i = 1:size(C,1)
        A(i,:) = zeros(1,playerNum);
        for j = 1:size(C,2)
            A(i,C(i,j)) = 1;
        end
    end  
    
    for v = 1:size(instGt_label,1)
        for i = 1:size(instGt_label{v,:},2)
            temp(i,:) = A(i,:)*str2double(instGt_label{v}(i));
        end
        player_label(v,:) = sum(temp,1)>0;    
    end

end

function Accu = BagCalculatePerformanceOfClassification(Y_label,playerGT_label)
  correct = 0; 

  for j = 1:size(Y_label,1)
      correct = correct + isequal(Y_label(j,:),playerGT_label(j,:));
  end
  
  Accu = correct/size(Y_label,1);

end

function [Accu, Prec, Reca, F1] = InstCalculatePerformanceOfClassification(Y_label,playerGT_label)
  truePositive = 0;
  trueNegative = 0;
  falsePositive= 0;
  falseNegative= 0;    

  for j = 1:size(Y_label,1)

    truePositive = truePositive + sum(and(playerGT_label(j,:), Y_label(j,:)));
    trueNegative = trueNegative + sum(and(not(playerGT_label(j,:)),not(Y_label(j,:))));
    falsePositive= falsePositive + sum(and(not(playerGT_label(j,:)),Y_label(j,:)));
    falseNegative= falseNegative + sum(and(playerGT_label(j,:),not(Y_label(j,:))));
  end
  
  Accu = (truePositive+trueNegative)/(truePositive+trueNegative+falsePositive+falseNegative);
  Prec = truePositive/(truePositive+falsePositive);
  Reca = truePositive/(truePositive+falseNegative);
  F1 = 2*truePositive/(2*truePositive+falsePositive+falseNegative);
end


function [Y_label,Y_prob] = ClassifyBagInstanceWithThreshold(sinst_prob,sbag_prob,playerNum,k,Threshold)

    C = nchoosek(1:playerNum,k);
    for i = 1:size(C,1)
        A(i,:) = zeros(1,playerNum);
        for j = 1:size(C,2)
            A(i,C(i,j)) = 1;
        end
    end  

    bag_label = sbag_prob >= Threshold;
    for b = 1:length(bag_label)
        if bag_label(b)
            instIdx = find(sinst_prob(b,:) == sbag_prob(b));
            keyPlayer = A(instIdx,:);
            [~,sortingIndices] = sort(mean(keyPlayer,1),'descend');
            Y_label(b,:) = zeros(1,playerNum);
            Y_prob(b,:) = zeros(1,playerNum);
            if isnan(k)
                p = mode(sum(keyPlayer,2));
            else
                p = k;
            end
            Y_label(b,sortingIndices(1:p)) = 1;
            Y_prob(b,sortingIndices(1:p)) = sbag_prob(b);           
        else
            Y_prob(b,1:playerNum) = sbag_prob(b);
            Y_label(b,:) = zeros(1,playerNum);
        end
    end
end

function [bagInfo,instPred,instGt,sinst_prob] = ReadClassificationFile(filename)
    fid  = fopen(filename,'r');

    tline = fgetl(fid);
    name = textscan(tline,'%s %s %s %s %s %s %s');
    v = 0;
    while ~isempty(tline)%~strcmp(tline,'') 
       v = v + 1;
       tline = fgetl(fid);
       if ~isempty(tline)
           [bag, inst] = strtok(tline,';');
           %inst = inst(2:end)
           bagInfo{v,1} = strtok(bag);
           % get rid of ';'
           [~,remain] = strtok(inst);
           counter = 0;
           while ~isempty(remain)
               counter = counter + 1;
               [instInfo{counter},remain] = strtok(remain);
           end
           instPred{v,1} = instInfo{1};
           instGt{v,1} = instInfo{2};
           %str2double(instInfo{1})
           for i = 3:length(instInfo)
            sinst_prob(v,i-2) = str2double(instInfo{i});
           end
       end
    end

    fclose(fid);
end

