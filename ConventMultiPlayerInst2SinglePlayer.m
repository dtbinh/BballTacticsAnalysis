function [bagAccu,instAccu] = ConventMultiPlayerInst2SinglePlayer(filename,playerNum,k)
% clear all
% filename = 'inst_MI_validate1.txt';
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

% k = 3; %nchoose k (1 2 3 4 5)
% playerNum = 5;
%A = [0.648 0.075 1.000 0.062 1.000 0.681 0.027 0.939 0.068 0.049];
%A = [0.363 0.025 1.000 0.025 0.996 0.025 0.025 0.127 0.025 0.025];
% B = log10(sinst_prob);
% 
% B(isinf(B)) = -4; % set log(0)~ -7 , 0~10^-7

%AAA = log(0.821);

% logP1 = ((AA(1)+AA(2)+AA(3)+AA(4)+AA(5)+AA(6))-sum(AA)/2)/3;
% logP2 = ((AA(1)+AA(2)+AA(3)+AA(7)+AA(8)+AA(9))-sum(AA)/2)/3;
% logP3 = ((AA(1)+AA(4)+AA(5)+AA(7)+AA(8)+AA(10))-sum(AA)/2)/3;
% logP4 = ((AA(2)+AA(4)+AA(6)+AA(7)+AA(9)+AA(10))-sum(AA)/2)/3;
% logP5 = ((AA(3)+AA(5)+AA(6)+AA(8)+AA(9)+AA(10))-sum(AA)/2)/3;

% P1 = exp(logP1)
% P2 = exp(logP2)
% P3 = exp(logP3)
% P4 = exp(logP4)
% P5 = exp(logP5)

% exp((AA(1)+AA(2)+AA(3)+AA(4)+AA(5)+AA(6))/6)
% exp((AA(1)+AA(2)+AA(3)+AA(7)+AA(8)+AA(9))/6)
% exp((AA(1)+AA(4)+AA(5)+AA(7)+AA(8)+AA(10))/6)
% exp((AA(2)+AA(4)+AA(6)+AA(7)+AA(9)+AA(10))/6)
% exp((AA(3)+AA(5)+AA(6)+AA(8)+AA(9)+AA(10))/6)
C = nchoosek(1:playerNum,k);
for i = 1:size(C,1)
    A(i,:) = zeros(1,playerNum);
    for j = 1:size(C,2)
        A(i,C(i,j)) = 1;
    end
end
% M1 = [1 1 1 0 0; 1 1 0 1 0; 1 1 0 0 1; 1 0 1 1 0;1 0 1 0 1; 1 0 0 1 1; 0 1 1 1 0; 0 1 1 0 1; 0 1 0 1 1; 0 0 1 1 1];
% if ~isequal(M,M1)
%     error('Wrong Mask!');
% end

player_labelGT = ConvertGTInst(instGt,A);

%x = lsqr(M,AA'); 
%xx =  exp(M\AA');
for v = 1:size(sinst_prob,1)
    if str2double(instPred{v,1}) ~= 0
        b = log10(sinst_prob(v,:));
        b(isinf(b)) = -7;
        [x,resnorm] = lsqnonneg(-A,b');
         Y(v,:) = 10.^(-x');
    else
        for p = 1:playerNum
            Y(v,p) = sum(sinst_prob(v,:))/(length(C(:))/playerNum);
        end
    end
end



% reconstruct prob
for v = 1:size(sinst_prob,1)
    for i = 1:size(C,1)
        Prob(v,i) = 1;
        for j = 1:size(C,2)
            Prob(v,i) = Prob(v,i) * Y(v,C(i,j));
        end
    end
end

% % show MIL Pred Prob and reconstruct Prob
% Prob
% sinst_prob
% 
% % compare MIL Pred and reconstruct Pred
% instPred
% Prob>=(0.5^k)
Y_label = Y>0.5;
Y_prob = Y;

newFilePath = strrep(filename,'multiPlayers','multiPlayers/Convert');

filesepIdx = strfind(newFilePath,'/');
newFolder = newFilePath(1:filesepIdx(end));
if ~exist(newFolder,'dir')
    mkdir(newFolder);
end
[bagAccu,instAccu] = SaveConventedInstance(newFilePath,Y_prob,Y_label,player_labelGT,bagInfo);
end

function player_label = ConvertGTInst(instGt_label,A)
    for v = 1:size(instGt_label,1)
        for i = 1:size(instGt_label{v,:},2)
            temp(i,:) = A(i,:)*str2double(instGt_label{v}(i));
        end
        player_label(v,:) = sum(temp,1)>0;    
    end

end

function [bagAccu,instAccu] = SaveConventedInstance(newFilePath,Y_prob,Y_label,playerGT_label,bagInfo)

fid = fopen(newFilePath,'w');
  fprintf(fid,'bagName  bagPred  bagTruth  bagProb  instPred  instTruth  instProb \n');
  
  %Positive = 0;
  %Negative=  0;
  truePositive = 0;
  trueNegative = 0;
  falsePositive= 0;
  falseNegative= 0;    

  for j = 1:length(bagInfo)
        str = [bagInfo{j} '  ' int2str(max(Y_prob(j,:))>0.5) '  ' int2str(sum(playerGT_label(j,:))>0) '    ' num2str(max(Y_prob(j,:)),'%.4f') ';  ' ...
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
  fprintf(fid,'TP TN FP FN Accu Prec Reca F1 \n');
  str1 = [int2str(truePositive) ' ' int2str(trueNegative) ' ' int2str(falsePositive) ' ' int2str(falseNegative) ' ' num2str(Accu,'%.3f') ' ' num2str(Prec,'%.3f') ' ' num2str(Reca,'%.3f') ' ' num2str(F1,'%.3f')];
  fprintf(fid, str1);
  fclose(fid);

instAccu = Accu;
bagAccu = sum(~xor(max(Y_prob,[],2)>0.5,max(playerGT_label,[],2)))/size(Y_prob,1);
  
end
