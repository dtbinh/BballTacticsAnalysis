function TuneSVMParam(targetDir,playerNum,tacticSelect,EvaluationSelect,datasetSelect,featureSelect,SVMType,linearClassifier)

KernelParamO = 0.05;
CostFactorO  = 1;
NegativeWeightO = 1;
for i = -3:3
    for j=-3:3
        for k=0
            KernelParam = 2^i*KernelParamO;
            CostFactor  = 2^j*CostFactorO;
            NegativeWeight=2^k*NegativeWeightO;
            if ~linearClassifier
            if ~isempty(playerNum)
                subfolder = [targetDir '/' datasetSelect featureSelect '/' playerNum '/' tacticSelect featureSelect playerNum '/' EvaluationSelect '/SVM/K=' num2str(KernelParam) 'C=' num2str(CostFactor) 'N=' num2str(NegativeWeight)];
            else
                subfolder = [targetDir '/' datasetSelect featureSelect '/' tacticSelect featureSelect playerNum '/' EvaluationSelect '/SVM/K=' num2str(KernelParam) 'C=' num2str(CostFactor) 'N=' num2str(NegativeWeight)];
            end
            elseif ~isempty(playerNum)
                subfolder = [targetDir datasetSelect featureSelect '/' playerNum '/' tacticSelect featureSelect playerNum '/' EvaluationSelect '/linear/SVM'];
            else
                subfolder = [targetDir datasetSelect featureSelect '/' tacticSelect featureSelect playerNum '/' EvaluationSelect '/linear/SVM'];
            end
            fid  = fopen([subfolder '/' SVMType '.data.result'],'r');
            % to lowercase
            if fid == -1
                subfolder = [targetDir '/' tacticSelect '/' datasetSelect '/' lower(tacticSelect) lower(featureSelect) '/' EvaluationSelect '/svm/k=' num2str(KernelParam) 'c=' num2str(CostFactor) 'n=' num2str(NegativeWeight)];
                fid  = fopen([subfolder '/' lower(SVMType) '.data.result'],'r');
            end
            while ~feof(fid)
                tline = fgetl(fid);
            end
            fclose(fid);
            %C = sscanf(tline,'%s = %s, %s = %s');
            [token, remain] = strtok(tline,',');
            [~, sbag] = strtok(token,'=');
            [~, sinst]= strtok(remain,'=');
            bag(i+4,j+4,k+4) = str2num(sbag(2:end));
            inst(i+4,j+4,k+4)= str2num(sinst(2:end));
            for v=1:5
               fid  = fopen([subfolder '/' SVMType '_validate' int2str(v) '.txt'],'r');
               while ~feof(fid)
                   tline = fgetl(fid);
               end
               fclose(fid);
               C(v,:) = textscan(tline,'%f %f %f %f %f %f %f %f');              
            end
            C=cell2mat(C);
            % remove nan as 0
            C(isnan(C)) = 0;
            result = mean(C,1);
            clear C
            instLabel.tp(i+4,j+4,k+4) = result(1);
            instLabel.tn(i+4,j+4,k+4) = result(2);
            instLabel.fp(i+4,j+4,k+4) = result(3);
            instLabel.fn(i+4,j+4,k+4) = result(4);
            instLabel.Accu(i+4,j+4,k+4) = result(5);
            instLabel.Prec(i+4,j+4,k+4) = result(6);
            instLabel.Reca(i+4,j+4,k+4) = result(7);
            instLabel.F1(i+4,j+4,k+4)   = result(8);
            %pause
        end
    end
end
% X = repmat(2.^(-3:3),7,1);
% Y = X';
% contour(X,Y,reshape(bag(:,:,4),7,7));
% set(gca,'XScale','log','YScale','log');
subplot(1,3,1),contour(reshape(bag(:,:,4),7,7));
set(gca,'XTickLabel',[0.05/8 0.05/4 0.05/2 0.05 0.1 0.2 0.4],'YTickLabel',[1/8 1/4 1/2 1 2 4 8]);
xlabel('KernelParam');
ylabel('Cost Factor');
title([SVMType '/BagAccuray']);
grid on
colorbar
axis square
disp('bag');
bag(:,:,4)

subplot(1,3,2),contour(reshape(inst(:,:,4),7,7));
kernel = [0.05/8 0.05/4 0.05/2 0.05 0.1 0.2 0.4];
cost   = [1/8 1/4 1/2 1 2 4 8];
set(gca,'XTickLabel',kernel,'YTickLabel',cost);
xlabel('KernelParam');
ylabel('Cost Factor');
title([SVMType '/InstAccuray']);
grid on
axis square
colorbar
disp('inst')
inst(:,:,4)

% instLabel.tp(:,:,4)
% instLabel.tn(:,:,4)
% instLabel.fp(:,:,4)
% instLabel.fn(:,:,4)
% instLabel.Accu(:,:,4)
% instLabel.Prec(:,:,4)
% instLabel.Reca(:,:,4)
subplot(1,3,3),contour(reshape(instLabel.F1(:,:,4),7,7));
kernel = [0.05/8 0.05/4 0.05/2 0.05 0.1 0.2 0.4];
cost   = [1/8 1/4 1/2 1 2 4 8];
set(gca,'XTickLabel',kernel,'YTickLabel',cost);
xlabel('KernelParam');
ylabel('Cost Factor');
title([SVMType '/InstF1']);
grid on
axis square
colorbar
disp('inst_F1')
instLabel.F1(:,:,4)

%combine accuracy 
%combineAccu = bag(:,:,4).*0.6+inst(:,:,4)*0.4;
combineAccu = 0.8*instLabel.F1(:,:,4)+0.12*bag(:,:,4)+0.08*inst(:,:,4);
[row col] = find(combineAccu == max(max(combineAccu)));

disp('max combinede Accurcy')
disp(['row ' int2str(row(1)) ', col ' int2str(col(1)) ' combined:' num2str(combineAccu(row(1),col(1)))]);
disp(['bag:' num2str(bag(row(1),col(1),4)) ', inst:' num2str(inst(row(1),col(1),4)) ', inst_F1:' num2str(instLabel.F1(row(1),col(1),4))]);
disp(['kernelParm=' num2str(kernel(col(1))) ', costFactor=' num2str(cost(row(1)))]);
if ~linearClassifier
if ~isempty(playerNum)
optimalFiles = [targetDir '/' datasetSelect featureSelect '/' playerNum '/' tacticSelect featureSelect playerNum '/' EvaluationSelect '/SVM/K=' num2str(kernel(col(1))) 'C=' num2str(cost(row(1))) 'N=' num2str(NegativeWeight) '/' SVMType];
%outputFolder = ['result/' datasetSelect featureSelect '/' tacticSelect featureSelect '/' EvaluationSelect '/SVM/K=' num2str(kernel(col(1))) 'C=' num2str(cost(row(1))) 'N=' num2str(NegativeWeight)];
outputFolder = ['result/' datasetSelect featureSelect '/' playerNum '/' tacticSelect featureSelect playerNum '/' SVMType '/' EvaluationSelect '/K=' num2str(kernel(col(1))) 'C=' num2str(cost(row(1))) 'N=' num2str(NegativeWeight)];
else
optimalFiles = [targetDir '/' datasetSelect featureSelect '/' tacticSelect featureSelect playerNum '/' EvaluationSelect '/SVM/K=' num2str(kernel(col(1))) 'C=' num2str(cost(row(1))) 'N=' num2str(NegativeWeight) '/' SVMType];
%outputFolder = ['result/' datasetSelect featureSelect '/' tacticSelect featureSelect '/' EvaluationSelect '/SVM/K=' num2str(kernel(col(1))) 'C=' num2str(cost(row(1))) 'N=' num2str(NegativeWeight)];
outputFolder = ['result/' datasetSelect featureSelect '/'  tacticSelect featureSelect playerNum '/' SVMType '/' EvaluationSelect '/K=' num2str(kernel(col(1))) 'C=' num2str(cost(row(1))) 'N=' num2str(NegativeWeight)];
end
elseif ~isempty(playerNum)
  optimalFiles = [targetDir '/' datasetSelect featureSelect '/' playerNum '/' tacticSelect featureSelect playerNum '/' EvaluationSelect '/linear/SVM/' SVMType];
  %outputFolder = ['result/' datasetSelect featureSelect '/' tacticSelect featureSelect '/' EvaluationSelect '/SVM/K=' num2str(kernel(col(1))) 'C=' num2str(cost(row(1))) 'N=' num2str(NegativeWeight)];
  outputFolder = ['result/' datasetSelect featureSelect '/' playerNum '/'  tacticSelect featureSelect playerNum '/' SVMType '/' EvaluationSelect '/linear/'];      
else
  optimalFiles = [targetDir '/' datasetSelect featureSelect '/' tacticSelect featureSelect playerNum '/' EvaluationSelect '/linear/SVM/' SVMType];
  %outputFolder = ['result/' datasetSelect featureSelect '/' tacticSelect featureSelect '/' EvaluationSelect '/SVM/K=' num2str(kernel(col(1))) 'C=' num2str(cost(row(1))) 'N=' num2str(NegativeWeight)];
  outputFolder = ['result/' datasetSelect featureSelect '/'  tacticSelect featureSelect playerNum '/' SVMType '/' EvaluationSelect '/linear/'];  
end
if ~exist(outputFolder,'dir')
    mkdir(outputFolder)
end
copyfile([optimalFiles '*'],outputFolder);

end