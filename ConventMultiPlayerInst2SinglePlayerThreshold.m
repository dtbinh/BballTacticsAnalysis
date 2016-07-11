function [bagAccu,instAccu] = ConventMultiPlayerInst2SinglePlayerThreshold(trainingfilename,validatefilename,playerNum,k)

%[bagInfo,instPred,instGt,sinst_prob] = ReadClassificationFile(trainingfilename);
[bagInfo,instPred,instGt,inst_prob] = ReadClassificationFile(validatefilename);

if ~isnan(k)
    C = nchoosek(1:playerNum,k);
    for i = 1:size(C,1)
        A(i,:) = zeros(1,playerNum);
        for j = 1:size(C,2)
            A(i,C(i,j)) = 1;
        end
    end
else
    counter = 1;
    for p = 2:playerNum
        C = nchoosek(1:playerNum,p);
        for i = 1:size(C,1)
            A(counter,:) = zeros(1,playerNum);
            for j = 1:size(C,2)
                A(counter,C(i,j)) = 1;
            end
            counter = counter + 1;
        end
    end
end
        
% validate set (first-half in testing bags)
vBagInfo = bagInfo(1:floor(length(bagInfo)/2));
vinstPred = instPred(1:floor(length(bagInfo)/2));
vinstGt   = instGt(1:floor(length(bagInfo)/2)); 
vinst_prob= inst_prob(1:floor(length(bagInfo)/2),:);

vplayer_labelGT = ConvertGTInst(vinstGt,A);

vbag_prob = max(vinst_prob,[],2);

% % content-aware
% Threshold = unique(sbag_prob);
% heurstic increasing
step = 0.01;
Threshold = 0:step:1;
F1_max = 0;
for Th = 1:length(Threshold)
%     bag_label = sbag_prob >= Threshold(Th);
%     for b = 1:length(bag_label)
%         if bag_label(b)
%             instIdx = find(sinst_prob(b,:) == sbag_prob(b));
%             keyPlayer = A(instIdx,:);
%             [~,sortingIndices] = sort(mean(keyPlayer,1),'descend');
%             Y_label(b,:) = zeros(1,playerNum);
%             Y_prob(b,:) = zeros(1,playerNum);
%             Y_label(b,sortingIndices(1:k)) = 1;
%             Y_prob(b,sortingIndices(1:k)) = sbag_prob(b);            
%             
%         else
%             Y_prob(b,1:playerNum) = sbag_prob(b);
%             Y_label(b,:) = zeros(1,playerNum);
%         end
%     end
    [Y_label,Y_prob] = ClassifyBagInstanceWithThreshold(vinst_prob,vbag_prob,A,playerNum,k,Threshold(Th));
    [Accu(Th), Prec(Th), Reca(Th), F1(Th)] = CalculatePerformanceOfClassification(Y_label,vplayer_labelGT);
%     if   Th == 1 || F1(Th) >= F1_max
%         y_Label = Y_label;
%         y_Prob = Y_prob;
%         y_th = Threshold(Th);
%         F1_max = F1(Th);
%     end
end



thRegion = find(F1 == max(F1));
y_th = (Threshold(thRegion(1))+Threshold(thRegion(end)))/2;



[vY_label,vY_prob] = ClassifyBagInstanceWithThreshold(vinst_prob,vbag_prob,A,playerNum,k,y_th);


%[vbagInfo,vinstPred,vinstGt,vsinst_prob] = ReadClassificationFile(validatefilename);
tBagInfo = bagInfo(floor(length(bagInfo)/2)+1:length(bagInfo));
tinstPred = instPred(floor(length(bagInfo)/2)+1:length(bagInfo));
tinstGt   = instGt(floor(length(bagInfo)/2)+1:length(bagInfo)); 
tinst_prob= inst_prob(floor(length(bagInfo)/2)+1:length(bagInfo),:);


tplayer_labelGT = ConvertGTInst(tinstGt,A);
tbag_prob = max(tinst_prob,[],2);
[tY_label,tY_prob] = ClassifyBagInstanceWithThreshold(tinst_prob,tbag_prob,A,playerNum,k,y_th);



newFilePathv = strrep(validatefilename,'multiPlayers','multiPlayers/Convert(Th)');
newFilePatht = strrep(trainingfilename,'multiPlayers','multiPlayers/Convert(Th)');
newFilePatht = strrep(newFilePatht,'training','testing');

filesepIdx = strfind(newFilePatht,'/');
newFolder = newFilePatht(1:filesepIdx(end));
if ~exist(newFolder,'dir')
    mkdir(newFolder);
end

[bagAccu,instAccu] = SaveConventedInstance(newFilePathv,vY_prob,vY_label,vplayer_labelGT,vBagInfo,y_th);

SaveConventedInstance(newFilePatht,tY_prob,tY_label,tplayer_labelGT,tBagInfo,y_th);

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

function player_label = ConvertGTInst(instGt_label,A)
    for v = 1:size(instGt_label,1)
        for i = 1:size(instGt_label{v,:},2)
            temp(i,:) = A(i,:)*str2double(instGt_label{v}(i));
        end
        player_label(v,:) = sum(temp,1)>0;    
    end

end

function [Y_label,Y_prob] = ClassifyBagInstanceWithThreshold(sinst_prob,sbag_prob,A,playerNum,k,Threshold)
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

function [Accu, Prec, Reca, F1] = CalculatePerformanceOfClassification(Y_label,playerGT_label)
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

function [bagAccu,instAccu] = SaveConventedInstance(newFilePath,Y_prob,Y_label,playerGT_label,bagInfo,threshold)
  fid = fopen(newFilePath,'w');
  fprintf(fid,'bagName  bagPred  bagTruth  bagProb  instPred  instTruth  instProb \n');
  
  %Positive = 0;
  %Negative=  0;
  truePositive = 0;
  trueNegative = 0;
  falsePositive= 0;
  falseNegative= 0;    

  for j = 1:length(bagInfo)
    str = [bagInfo{j} '  ' int2str(max(Y_prob(j,:))>threshold) '  ' int2str(sum(playerGT_label(j,:))>0) '    ' num2str(max(Y_prob(j,:)),'%.4f') ';  ' ...
        num2str(Y_label(j,:),'%d') '  ' num2str(playerGT_label(j,:),'%d') '  ' num2str(Y_prob(j,:),'% .4f') '\n'];
    fprintf(fid, str);

    truePositive = truePositive + sum(and(playerGT_label(j,:), Y_label(j,:)));
    trueNegative = trueNegative + sum(and(not(playerGT_label(j,:)),not(Y_label(j,:))));
    falsePositive= falsePositive + sum(and(not(playerGT_label(j,:)),Y_label(j,:)));
    falseNegative= falseNegative + sum(and(playerGT_label(j,:),not(Y_label(j,:))));
  end
  
  Accu = (truePositive+trueNegative)/(truePositive+trueNegative+falsePositive+falseNegative);
  Prec = truePositive/(truePositive+falsePositive);
  Reca = truePositive/(truePositive+falseNegative);
  F1 = 2*truePositive/(2*truePositive+falsePositive+falseNegative);
  fprintf(fid,'\n');
  fprintf(fid,'TP TN FP FN Accu Prec Reca F1 Th=%f\n',threshold);
  str1 = [int2str(truePositive) ' ' int2str(trueNegative) ' ' int2str(falsePositive) ' ' int2str(falseNegative) ...
      ' ' num2str(Accu,'%.3f') ' ' num2str(Prec,'%.3f') ' ' num2str(Reca,'%.3f') ' ' num2str(F1,'%.3f')];
  fprintf(fid, str1);
  fclose(fid);

instAccu = Accu;
% original 0.5 threshold
bagAccu = sum(~xor(max(Y_prob,[],2)>threshold,max(playerGT_label,[],2)))/size(Y_prob,1); 
end
