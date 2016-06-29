function MIL_Instance_F1Evaluate(bags,filename,label_predict,prob_predict)
threshold = 0.5; % predefined threshold

fid = fopen(filename,'w');
  fprintf(fid,'bagName  bagPred  bagTruth  bagProb  instPred  instTruth  instProb \n');

  %Positive = 0;
  %Negative=  0;
  truePositive = 0;
  trueNegative = 0;
  falsePositive= 0;
  falseNegative= 0;    

  idx = 0;
  for j = 1:length(bags)
    [num_inst, num_feature] = size(bags(j).instance);
%     idx+1 : idx+num_inst
%     prob_predict (idx+1 : idx+num_inst)
%     label_predict (idx+1 : idx+num_inst)
%     str_inst_prob = '';
%     for i= 1:num_inst
%         str_inst_prob = [str_inst_prob ' ' num2str(prob_predict(idx+i),'%.3f')];
%     end
    str = [bags(j).name '  ' int2str(max(prob_predict (idx+1 : idx+num_inst))>threshold) '  ' int2str(bags(j).label) '    ' num2str(max(prob_predict(idx+1 : idx+num_inst)),'%.3f') ';  ' ...
        num2str(label_predict(idx+1 : idx+num_inst)','%d') '  ' num2str(bags(j).inst_label,'%d') '  ' num2str(prob_predict(idx+1 : idx+num_inst)','% f') '\n'];
    fprintf(fid, str);

    truePositive = truePositive + sum(and(label_predict(idx+1 : idx+num_inst)', bags(j).inst_label));
    trueNegative = trueNegative + sum(and(not(label_predict(idx+1 : idx+num_inst)'),not(bags(j).inst_label)));
    falsePositive= falsePositive + sum(and(not(label_predict(idx+1 : idx+num_inst)'),bags(j).inst_label));
    falseNegative= falseNegative + sum(and(label_predict(idx+1 : idx+num_inst)',not(bags(j).inst_label)));
    
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
end