% Input pararmeter: 
% data_file: data file, including the feature data and output class

function run = MIL_Cross_Validate(data_file, classifier_wrapper_handle, classifier)

global preprocess model train_label_predict train_prob_predict;
%[X, Y, num_data, num_feature] = preprocessing(D);
%clear D;
[bags, num_data, num_feature] = MIL_Data_Load(data_file);

% The statistics of dataset
num_folder = preprocess.NumCrossFolder;
%num_class = length(preprocess.ClassSet);
%class_set = preprocess.ClassSet;

% run.Y_pred = zeros(num_data, 4);
% run.Y_pred(:, 1) = (1:num_data)';
  run.bag_pred = zeros(num_data, 3);
  run.bag_pred(:, 1) = (1:num_data)';

% check and ensure each fold has enough positive bags (average distribute)
bags = MIL_CheckPositiveBagsInFolds(bags,num_folder,0);
% debug mode  
% bags = MIL_CheckPositiveBagsInFolds(bags,num_folder,1);
% pause(1)

for i = 1:num_folder
  fprintf('Iteration %d ......\n', i);  
  % Generate the data indeces for the testing data
  testindex = floor((i-1) * num_data / num_folder)+1 : floor( i * num_data/num_folder);
  
%   if (preprocess.ShotAvailable == 1) & (preprocess.ValidateByShot == 1)      
%     num_shot = length(preprocess.ShotIDSet);
%     ValidateTestShot = preprocess.ShotIDSet(floor((i-1) * num_shot / num_folder) + 1 : floor(i * num_shot / num_folder));
%     testindex = []; for j = 1:length(ValidateTestShot), testindex = [testindex; find(preprocess.ShotInfo == ValidateTestShot(j))]; end;
%   end;  
  
  trainindex = setdiff(1:num_data, testindex);
  
  % separate new validate index from trainindex
  validateindex = trainindex(1 : floor(num_data/num_folder));
  trainindex = setdiff(trainindex, validateindex);
  testindex = [validateindex testindex]; % combine validate and test together, then separate them when run end
  
  % Classificaiton
  run_class(i) = feval(classifier_wrapper_handle, bags, trainindex, testindex, classifier); 
  %copyfile('temp/temp.output.txt',[preprocess.WorkingDir '/' strtok(preprocess.input_file,'.') '/cross_validate/' classifier '_iter' int2str(i) '_' classifier '.txt']);
  %copyfile('temp/temp.output.txt',[strtok(preprocess.input_file,'.') '/cross_validate/' classifier '_iter' int2str(i) '_' classifier '.txt']);
  k = strfind(preprocess.output_file,'.data.result');
  
  % save trainbags svm final result
  trainbags = bags(trainindex);
  filename = [preprocess.output_file(1:k-1) '_training' int2str(i) '.txt'];
  fid = fopen(filename,'w');
  fprintf(fid,'bagName  bagPred  bagTruth  bagProb  instPred  instTruth  instProb \n');

  %Positive = 0;
  %Negative=  0;
  truePositive = 0;
  trueNegative = 0;
  falsePositive= 0;
  falseNegative= 0;    

  idx = 0;
  for j = 1:length(trainbags)
    [num_inst, num_feature] = size(trainbags(j).instance);
%     idx+1 : idx+num_inst
%     train_prob_predict (idx+1 : idx+num_inst)
%     train_label_predict (idx+1 : idx+num_inst)
%     str_inst_prob = '';
%     for i= 1:num_inst
%         str_inst_prob = [str_inst_prob ' ' num2str(train_prob_predict(idx+i),'%.3f')];
%     end
    str = [trainbags(j).name '  ' int2str(max(train_prob_predict (idx+1 : idx+num_inst))>0.5) '  ' int2str(trainbags(j).label) '    ' num2str(max(train_prob_predict(idx+1 : idx+num_inst)),'%.3f') ';  ' ...
        num2str(train_label_predict(idx+1 : idx+num_inst)','%d') '  ' num2str(trainbags(j).inst_label,'%d') '  ' num2str(train_prob_predict(idx+1 : idx+num_inst)','% f') '\n'];
    fprintf(fid, str);

    truePositive = truePositive + sum(and(train_label_predict(idx+1 : idx+num_inst)', trainbags(j).inst_label));
    trueNegative = trueNegative + sum(and(not(train_label_predict(idx+1 : idx+num_inst)'),not(trainbags(j).inst_label)));
    falsePositive= falsePositive + sum(and(not(train_label_predict(idx+1 : idx+num_inst)'),trainbags(j).inst_label));
    falseNegative= falseNegative + sum(and(train_label_predict(idx+1 : idx+num_inst)',not(trainbags(j).inst_label)));
    
    idx = idx + num_inst;
  end
  
  Accu = (truePositive+trueNegative)/(truePositive+trueNegative+falsePositive+falseNegative);
  Prec = truePositive/(truePositive+falsePositive);
  Reca = truePositive/(truePositive+falseNegative);
  F1 = 2*truePositive/(2*truePositive+falsePositive+falseNegative);
  fprintf(fid,'\n');
  fprintf(fid,'TP TN FP FN Accu Prec Reca F1 \n');
  str1 = [int2str(truePositive) ' ' int2str(trueNegative) ' ' int2str(falsePositive) ' ' int2str(falseNegative) ' ' num2str(Accu,'%.3f') ' ' num2str(Prec,'%.3f') ' ' num2str(Reca,'%.3f') ' ' num2str(F1,'%.3f')];
  fprintf(fid, str1);
  fclose(fid);
  
  
  %record model txt file
  %copyfile([preprocess.WorkingDir '/temp/temp.model.txt'],[preprocess.output_file(1:k-1) '_model' int2str(i) '.txt']);
  save([preprocess.output_file(1:k-1) '_model' int2str(i) '.mat'],'model','-mat');
  
  % save testbags svm final result
  testbags = bags(testindex);
  filename = [preprocess.output_file(1:k-1) '_validate' int2str(i) '.txt'];
  fid = fopen(filename,'w');
  fprintf(fid,'bagName  bagPred  bagTruth  bagProb  instPred  instTruth  instProb \n');
  
  %Positive = 0;
  %Negative=  0;
  truePositive = 0;
  trueNegative = 0;
  falsePositive= 0;
  falseNegative= 0;    

  for j = 1:length(testbags)
    [num_inst, num_feature] = size(testbags(j).instance);
    %for j = 1:num_inst
        %str = [bags(i).name ',' cell2mat(bags(i).inst_name(j)) ',' feature_line(bags(i).instance(j,:)) num2str(bags(i).inst_label(j)) '\n'];
        str = [testbags(j).name '  ' int2str(run_class(i).bag_label(j)) '  ' int2str(testbags(j).label) '    ' num2str(run_class(i).bag_prob(j),'%.3f') ';  ' ...
            num2str(run_class(i).inst_label((j-1)*num_inst+1:j*num_inst)','%d') '  ' num2str(testbags(j).inst_label,'%d') '  ' num2str(run_class(i).inst_prob((j-1)*num_inst+1:j*num_inst)','% f') '\n'];
        fprintf(fid, str);
    %end
    %Positive = Positive + sum(testbags(j).inst_label);
    %Negative= Negative + sum(not(testbags(j).inst_label));
    truePositive = truePositive + sum(and(run_class(i).inst_label((j-1)*num_inst+1:j*num_inst)', testbags(j).inst_label));
    trueNegative = trueNegative + sum(and(not(run_class(i).inst_label((j-1)*num_inst+1:j*num_inst)'),not(testbags(j).inst_label)));
    falsePositive= falsePositive + sum(and(not(run_class(i).inst_label((j-1)*num_inst+1:j*num_inst)'),testbags(j).inst_label));
    falseNegative= falseNegative + sum(and(run_class(i).inst_label((j-1)*num_inst+1:j*num_inst)',not(testbags(j).inst_label)));
  end
  
  Accu = (truePositive+trueNegative)/(truePositive+trueNegative+falsePositive+falseNegative);
  Prec = truePositive/(truePositive+falsePositive);
  Reca = truePositive/(truePositive+falseNegative);
  F1 = 2*truePositive/(2*truePositive+falsePositive+falseNegative);
  fprintf(fid,'\n');
  fprintf(fid,'TP TN FP FN Accu Prec Reca F1 \n');
  str1 = [int2str(truePositive) ' ' int2str(trueNegative) ' ' int2str(falsePositive) ' ' int2str(falseNegative) ' ' num2str(Accu,'%.3f') ' ' num2str(Prec,'%.3f') ' ' num2str(Reca,'%.3f') ' ' num2str(F1,'%.3f')];
  fprintf(fid, str1);
  fclose(fid);
  
  
  run.bag_pred(testindex, 2) = run_class(i).bag_prob; 
  run.bag_pred(testindex, 3) = run_class(i).bag_label; 
  run.bag_pred(testindex, 4) = [bags(testindex).label]';  
  
%   run.Y_pred(testindex, 2) = run_class(i).Y_prob; 
%   run.Y_pred(testindex, 3) = run_class(i).Y_compute; 
%   run.Y_pred(testindex, 4) = run_class(i).Y_test;
end

% if (isfield(run_class(1), 'Err')), run.Err = mean([run_class(:).Err]); end;
% if (isfield(run_class(1), 'Prec')), run.Prec = mean([run_class(:).Prec]); end;
% if (isfield(run_class(1), 'Rec')), run.Rec = mean([run_class(:).Rec]); end;
% if (isfield(run_class(1), 'F1')), run.F1 = mean([run_class(:).F1]); end;
% if (isfield(run_class(1), 'Micro_Prec')), run.Micro_Prec = mean([run_class(:).Micro_Prec]); end;
% if (isfield(run_class(1), 'Micro_Rec')), run.Micro_Rec = mean([run_class(:).Micro_Rec]); end;
% if (isfield(run_class(1), 'Micro_F1')), run.Micro_F1 = mean([run_class(:).Micro_F1]); end;
% if (isfield(run_class(1), 'Macro_Prec')), run.Macro_Prec = mean([run_class(:).Macro_Prec]); end;
% if (isfield(run_class(1), 'Macro_Rec')), run.Macro_Rec = mean([run_class(:).Macro_Rec]); end;
% if (isfield(run_class(1), 'Macro_F1')), run.Macro_F1 = mean([run_class(:).Macro_F1]); end;
% if (isfield(run_class(1), 'AvgPrec')), run.AvgPrec = mean([run_class(:).AvgPrec]); end;
% if (isfield(run_class(1), 'BaseAvgPrec')), run.BaseAvgPrec = mean([run_class(:).BaseAvgPrec]); end;

if (isfield(run_class(1), 'BagAccu')), run.BagAccu = mean([run_class(:).BagAccu]); end;
if (isfield(run_class(1), 'InstAccu')), run.InstAccu = mean([run_class(:).InstAccu]); end;

if (isfield(preprocess, 'EnforceDistrib') && preprocess.EnforceDistrib == 1)
   num_pos = 0;
   for i = 1:num_data, num_pos = num_pos + bags(i).label; end;
   [sort_ret, sort_idx ] = sort(run.bag_pred(:,2));
   threshold = sort_ret(num_data - num_pos + 1);   
   run.bag_pred(:, 3) = (run.bag_pred(:,2) >= threshold);
   run.BagAccu = sum(run.bag_pred(:,3) == run.bag_pred(:,4)) / num_data;
end

% function RemoveConstraints()
% 
% global preprocess;
% if (preprocess.ConstraintAvailable == 1) & (preprocess.ShotAvailable == 1)
%       for j = 1:size(preprocess.constraintMap, 1),
%           ShotInfo = preprocess.ShotInfo;
%           preprocess.constraintUsed(j) = (all(ShotInfo(trainindex) ~= preprocess.constraintMap(j,1)) && ...
%               all(ShotInfo(trainindex) ~= preprocess.constraintMap(j,2)));
%       end;
% end;

