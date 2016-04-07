function TuneSVMParam(targetDir,playerNum,tacticSelect,EvaluationSelect,datasetSelect,featureSelect,SVMType,SVMKernelType)

weightNum = 1;

KernelParamO = 0.05;
CostFactorO  = 1;
NegativeWeightO = 1;
for i = -3:3
    for j=-3:3
        for k=0:weightNum-1
            KernelParam = 2^i*KernelParamO;
            CostFactor  = 2^j*CostFactorO;
            NegativeWeight=2^k*NegativeWeightO;
            
            if ~isempty(playerNum)
                subfolder = [targetDir '/' datasetSelect featureSelect '/' tacticSelect featureSelect playerNum '/' EvaluationSelect '/SVM/' SVMType '/' SVMKernelType '/K=' num2str(KernelParam) 'C=' num2str(CostFactor) 'N=' num2str(NegativeWeight)];
            else
                subfolder = [targetDir '/' datasetSelect featureSelect '/' tacticSelect featureSelect '/' EvaluationSelect '/SVM/' SVMType '/' SVMKernelType '/K=' num2str(KernelParam) 'C=' num2str(CostFactor) 'N=' num2str(NegativeWeight)];
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
            bag(i+4,j+4,k+1) = str2num(sbag(2:end));
            inst(i+4,j+4,k+1)= str2num(sinst(2:end));
            for v=1:length(dir([subfolder '/' SVMType '_validate*']))
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
            instLabel.tp(i+4,j+4,k+1) = result(1);
            instLabel.tn(i+4,j+4,k+1) = result(2);
            instLabel.fp(i+4,j+4,k+1) = result(3);
            instLabel.fn(i+4,j+4,k+1) = result(4);
            instLabel.Accu(i+4,j+4,k+1) = result(5);
            instLabel.Prec(i+4,j+4,k+1) = result(6);
            instLabel.Reca(i+4,j+4,k+1) = result(7);
            instLabel.F1(i+4,j+4,k+1)   = result(8);
            %pause
        end
    end
end

if strcmp(SVMType,'inst_MI')
    svmType = 'mi';
else
    svmType = 'MI';
end

% X = repmat(2.^(-3:3),7,1);
% Y = X';
% contour(X,Y,reshape(bag(:,:,4),7,7));
% set(gca,'XScale','log','YScale','log');
for n=1:weightNum
    NegativeWeight=2^(n-1)*NegativeWeightO;
    subplot(weightNum,3,3*(n-1)+1),contour(reshape(bag(:,:,n),7,7));
    set(gca,'XTickLabel',[0.05/8 0.05/4 0.05/2 0.05 0.1 0.2 0.4],'YTickLabel',[1/8 1/4 1/2 1 2 4 8]);
    xlabel('KernelParam');
    ylabel('Cost Factor');
    title([svmType '/BagAccuray (Negative Weight=' num2str(NegativeWeight) ')']);
    grid on
    colorbar
    axis square
    disp('bag');
    bag(:,:,n)

    subplot(weightNum,3,3*(n-1)+2),contour(reshape(inst(:,:,n),7,7));
    kernel = [0.05/8 0.05/4 0.05/2 0.05 0.1 0.2 0.4];
    cost   = [1/8 1/4 1/2 1 2 4 8];
    set(gca,'XTickLabel',kernel,'YTickLabel',cost);
    xlabel('KernelParam');
    ylabel('Cost Factor');
    title([svmType '/InstAccuray (Negative Weight=' num2str(NegativeWeight) ')']);
    grid on
    axis square
    colorbar
    disp('inst')
    inst(:,:,n)

    % instLabel.tp(:,:,4)
    % instLabel.tn(:,:,4)
    % instLabel.fp(:,:,4)
    % instLabel.fn(:,:,4)
    % instLabel.Accu(:,:,4)
    % instLabel.Prec(:,:,4)
    % instLabel.Reca(:,:,4)
    subplot(weightNum,3,3*(n-1)+3),contour(reshape(instLabel.F1(:,:,n),7,7));
    kernel = [0.05/8 0.05/4 0.05/2 0.05 0.1 0.2 0.4];
    cost   = [1/8 1/4 1/2 1 2 4 8];
    set(gca,'XTickLabel',kernel,'YTickLabel',cost);
    xlabel('KernelParam');
    ylabel('Cost Factor');
    title([svmType '/InstF1 (Negative Weight=' num2str(NegativeWeight) ')']);
    grid on
    axis square
    colorbar
    disp('inst_F1')
    instLabel.F1(:,:,n)

    %combine accuracy 
    %combineAccu = bag(:,:,4).*0.6+inst(:,:,4)*0.4;
    combineAccu(:,:,n) = 0.8*instLabel.F1(:,:,n)+0.12*bag(:,:,n)+0.08*inst(:,:,n);
    [row col] = find(combineAccu(:,:,n) == max(max(combineAccu(:,:,n))));

    disp('max combinede Accurcy')
    disp(['row ' int2str(row(1)) ', col ' int2str(col(1)) ' combined:' num2str(combineAccu(row(1),col(1)))]);
    disp(['bag:' num2str(bag(row(1),col(1),n)) ', inst:' num2str(inst(row(1),col(1),n)) ', inst_F1:' num2str(instLabel.F1(row(1),col(1),n))]);
    disp(['kernelParm=' num2str(kernel(col(1))) ', costFactor=' num2str(cost(row(1))) ', NegativeWeight=' num2str(NegativeWeight)]);
    tempF1(n) = instLabel.F1(row(1),col(1),n);
    tempKernel(n) = kernel(col(1));
    tempCost(n) = cost(row(1));
    tempNegativeWeight(n) = NegativeWeight;
end

disp(' ');
disp(' ');
disp(['tempF1:' num2str(tempF1)]);

optimalWeightIdx = find(tempF1 == max(tempF1));
optimalKernel = tempKernel(optimalWeightIdx(1));
optimalCost   = tempCost(optimalWeightIdx(1));
optimalNegativeWeight = tempNegativeWeight(optimalWeightIdx(1));
optimalF1 = tempF1(optimalWeightIdx(1));

disp(' ');
disp(['optKernelParm=' num2str(optimalKernel) ', optCostFactor=' num2str(optimalCost) ', optNegativeWeight=' num2str(optimalNegativeWeight) ': F1=' num2str(optimalF1)]);
disp(['KernelParmN1=' num2str(tempKernel(1)) ', CostFactorN1=' num2str(tempCost(1)) ', NegativeWeightN1=' num2str(tempNegativeWeight(1)) ': F1N1=' num2str(tempF1(1))]);

if ~isempty(playerNum)
    optimalFiles = [targetDir '/' datasetSelect featureSelect '/' tacticSelect featureSelect playerNum '/' EvaluationSelect '/SVM/' SVMType '/' SVMKernelType '/K=' num2str(optimalKernel) 'C=' num2str(optimalCost) 'N=' num2str(optimalNegativeWeight) '/' SVMType];
    outputFolder = strrep(optimalFiles,'tuning','result');
else
    optimalFiles = [targetDir '/' datasetSelect featureSelect '/' tacticSelect featureSelect '/' EvaluationSelect '/SVM/' SVMType '/' SVMKernelType '/K=' num2str(optimalKernel) 'C=' num2str(optimalCost) 'N=' num2str(optimalNegativeWeight) '/' SVMType];
    outputFolder = strrep(optimalFiles,'tuning','result');
end


if ~exist(outputFolder,'dir')
    mkdir(outputFolder)
end
copyfile([optimalFiles '*'],outputFolder);

end