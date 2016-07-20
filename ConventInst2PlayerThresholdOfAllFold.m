function [bagAccuAll,instAccuAll] = ConventInst2PlayerThresholdOfAllFold(filefolder,trainingfilename,validatefileLists,playerNum,k)

A = GenerateTransformMatrix(playerNum,k);

for f = 1:length(validatefileLists)
    [vbagInfo{f},vinstPred{f},vinstGt{f},vinst_prob{f}] = ReadClassificationFile([filefolder '/' validatefileLists(f).name]);
    vplayer_labelGT{f} = ConvertGTInst(vinstGt{f},A);
    vbag_prob{f} = max(vinst_prob{f},[],2);
end

step = 0.01;
Threshold = 0:step:1;
for Th = 1:length(Threshold)

    for f = 1:length(validatefileLists)
        [Y_label{f},Y_prob{f}] = ClassifyBagInstanceWithThreshold(vinst_prob{f},vbag_prob{f},A,playerNum,k,Threshold(Th));
    end
    [Accu(Th), Prec(Th), Reca(Th), F1(Th)] = CalculatePerformanceOfClassification(Y_label,vplayer_labelGT);

end

thRegion = find(F1 == max(F1));
y_th = (Threshold(thRegion(1))+Threshold(thRegion(end)))/2;

newFolder = strrep(filefolder,'multiPlayers','multiPlayers/Convert(Th)');
if ~exist(newFolder,'dir')
    mkdir(newFolder);
end

Y_label_total = [];
Y_prob_total = [];
vplayer_labelGT_total = [];
vbagInfo_total = [];

for f = 1:length(validatefileLists)
[vY_label{f},vY_prob{f}] = ClassifyBagInstanceWithThreshold(vinst_prob{f},vbag_prob{f},A,playerNum,k,y_th);

newFilePathv = [newFolder '/' validatefileLists(f).name];

[bagAccu,instAccu] = SaveConventedInstance(newFilePathv,vY_prob{f},vY_label{f},vplayer_labelGT{f},vbagInfo{f},y_th);


Y_label_total = [Y_label_total; vY_label{f}];
Y_prob_total = [Y_prob_total; vY_prob{f}];
vplayer_labelGT_total = [vplayer_labelGT_total; vplayer_labelGT{f}];
vbagInfo_total = [vbagInfo_total; vbagInfo{f}];
end

sepIndex = strfind(validatefileLists(1).name,'.');
newFilePathall = [newFolder '/' validatefileLists(1).name(1:sepIndex-2) 'All.txt'];
[bagAccuAll,instAccuAll] = SaveConventedInstance(newFilePathall,Y_prob_total,Y_label_total,vplayer_labelGT_total,vbagInfo_total,y_th);

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

function [Accu, Prec, Reca, F1] = CalculatePerformanceOfClassification(Y_label,playerGT_label)
  truePositive = 0;
  trueNegative = 0;
  falsePositive= 0;
  falseNegative= 0;    

  for f = 1:size(Y_label,2)
      for j = 1:size(Y_label{f},1)

        truePositive = truePositive + sum(and(playerGT_label{f}(j,:), Y_label{f}(j,:)));
        trueNegative = trueNegative + sum(and(not(playerGT_label{f}(j,:)),not(Y_label{f}(j,:))));
        falsePositive= falsePositive + sum(and(not(playerGT_label{f}(j,:)),Y_label{f}(j,:)));
        falseNegative= falseNegative + sum(and(playerGT_label{f}(j,:),not(Y_label{f}(j,:))));
      end
  end
  
  Accu = (truePositive+trueNegative)/(truePositive+trueNegative+falsePositive+falseNegative);
  Prec = truePositive/(truePositive+falsePositive);
  Reca = truePositive/(truePositive+falseNegative);
  F1 = 2*truePositive/(2*truePositive+falsePositive+falseNegative);
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

function player_label = ConvertGTInst(instGt_label,A)
    for v = 1:size(instGt_label,1)
        for i = 1:size(instGt_label{v,:},2)
            temp(i,:) = A(i,:)*str2double(instGt_label{v}(i));
        end
        player_label(v,:) = sum(temp,1)>0;    
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


function A = GenerateTransformMatrix(playerNum,k)

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

end
