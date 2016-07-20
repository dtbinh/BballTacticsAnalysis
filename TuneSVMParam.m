%function TuneSVMParam(param,targetDir,playerNum,tacticSelect,EvaluationSelect,datasetSelect,featureSelect,SVMType,SVMKernelType)
function svmsetting = TuneSVMParam(param,targetDir,EvaluationSelect,SVMType,SVMKernelType)
weightNum = length(param.negativeWeight);

if strfind(targetDir,'multiPlayers')
    targetDir = strrep(targetDir,'multiPlayers','multiPlayers/Convert(Th)');
end

KernelParamO = param.KernelO;
CostFactorO  = 1;
NegativeWeightO = 1;
for i = param.kernel
    for j= param.cost
        for k=0:weightNum-1
            KernelParam = 2^i*KernelParamO;
            CostFactor  = 2^j*CostFactorO;
            NegativeWeight=2^k*NegativeWeightO;
            
%             if ~isempty(playerNum)
%                 subfolder = [targetDir '/' datasetSelect featureSelect '/' tacticSelect featureSelect playerNum '/' EvaluationSelect '/SVM/' SVMType '/' SVMKernelType '/K=' num2str(KernelParam) 'C=' num2str(CostFactor) 'N=' num2str(NegativeWeight)];
%             else
%                 subfolder = [targetDir '/' datasetSelect featureSelect '/' tacticSelect featureSelect '/' EvaluationSelect '/SVM/' SVMType '/' SVMKernelType '/K=' num2str(KernelParam) 'C=' num2str(CostFactor) 'N=' num2str(NegativeWeight)];
%             end
            subfolder = [targetDir '/' EvaluationSelect '/SVM/' SVMType '/' SVMKernelType '/K=' num2str(KernelParam) 'C=' num2str(CostFactor) 'N=' num2str(NegativeWeight)];

            fid  = fopen([subfolder '/' SVMType '.data.result'],'r');
            % to lowercase
%             if fid == -1
%                 subfolder = [targetDir '/' tacticSelect '/' datasetSelect '/' lower(tacticSelect) lower(featureSelect) '/' EvaluationSelect '/svm/k=' num2str(KernelParam) 'c=' num2str(CostFactor) 'n=' num2str(NegativeWeight)];
%                 fid  = fopen([subfolder '/' lower(SVMType) '.data.result'],'r');
%             end
            % skip files if files are not existed
            if fid == -1
                disp(['skip ' subfolder '!!']);
                instLabel.tp(-i+param.kernel(1)+1,-j+param.cost(1)+1,k+1) = 0;
                instLabel.tn(-i+param.kernel(1)+1,-j+param.cost(1)+1,k+1) = 0;
                instLabel.fp(-i+param.kernel(1)+1,-j+param.cost(1)+1,k+1) = 0;
                instLabel.fn(-i+param.kernel(1)+1,-j+param.cost(1)+1,k+1) = 0;
                instLabel.Accu(-i+param.kernel(1)+1,-j+param.cost(1)+1,k+1) = 0;
                instLabel.Prec(-i+param.kernel(1)+1,-j+param.cost(1)+1,k+1) = 0;
                instLabel.Reca(-i+param.kernel(1)+1,-j+param.cost(1)+1,k+1) = 0;
                instLabel.F1(-i+param.kernel(1)+1,-j+param.cost(1)+1,k+1)   = 0;
                pause(3)
                continue
            end
            while ~feof(fid)
                tline = fgetl(fid);
            end
            fclose(fid);
            %C = sscanf(tline,'%s = %s, %s = %s');
            [token, remain] = strtok(tline,',');
            [~, sbag] = strtok(token,'=');
            [~, sinst]= strtok(remain,'=');
            bag(-i+param.kernel(1)+1,-j+param.cost(1)+1,k+1) = str2num(sbag(2:end));
            inst(-i+param.kernel(1)+1,-j+param.cost(1)+1,k+1)= str2num(sinst(2:end));
            
            fid  = fopen([subfolder '/' SVMType '_validateAll.txt'],'r');
            while ~feof(fid)
                prev_tline = tline;
                tline = fgetl(fid);                   
            end
            fclose(fid);
            [token,remain] = strtok(prev_tline,'=');
            threshold = str2double(remain(2:end));
            C = textscan(tline,'%f %f %f %f %f %f %f %f');
            C=cell2mat(C);
            C(isnan(C)) = 0;
            instLabel.tp(-i+param.kernel(1)+1,-j+param.cost(1)+1,k+1) = C(1);
            instLabel.tn(-i+param.kernel(1)+1,-j+param.cost(1)+1,k+1) = C(2);
            instLabel.fp(-i+param.kernel(1)+1,-j+param.cost(1)+1,k+1) = C(3);
            instLabel.fn(-i+param.kernel(1)+1,-j+param.cost(1)+1,k+1) = C(4);
            instLabel.Accu(-i+param.kernel(1)+1,-j+param.cost(1)+1,k+1) = C(5);
            instLabel.Prec(-i+param.kernel(1)+1,-j+param.cost(1)+1,k+1) = C(6);
            instLabel.Reca(-i+param.kernel(1)+1,-j+param.cost(1)+1,k+1) = C(7);
            instLabel.F1(-i+param.kernel(1)+1,-j+param.cost(1)+1,k+1)   = C(8);            
            instLabel.Th(-i+param.kernel(1)+1,-j+param.cost(1)+1,k+1)   = threshold;
            

%             for v=1:length(dir([subfolder '/' SVMType '_validate*']))
%                fid  = fopen([subfolder '/' SVMType '_validate' int2str(v) '.txt'],'r');
%                while ~feof(fid)
%                    prev_tline = tline;
%                    tline = fgetl(fid);                   
%                end
%                fclose(fid);
%                [token,remain] = strtok(prev_tline,'=');
%                threshold(v) = str2double(remain(2:end));
%                C(v,:) = textscan(tline,'%f %f %f %f %f %f %f %f');              
%             end
%             C=cell2mat(C);
%             % remove nan as 0
%             C(isnan(C)) = 0;
%             result = mean(C,1);
%             clear C
%             instLabel.tp(-i+param.kernel(1)+1,-j+param.cost(1)+1,k+1) = result(1);
%             instLabel.tn(-i+param.kernel(1)+1,-j+param.cost(1)+1,k+1) = result(2);
%             instLabel.fp(-i+param.kernel(1)+1,-j+param.cost(1)+1,k+1) = result(3);
%             instLabel.fn(-i+param.kernel(1)+1,-j+param.cost(1)+1,k+1) = result(4);
%             instLabel.Accu(-i+param.kernel(1)+1,-j+param.cost(1)+1,k+1) = result(5);
%             instLabel.Prec(-i+param.kernel(1)+1,-j+param.cost(1)+1,k+1) = result(6);
%             instLabel.Reca(-i+param.kernel(1)+1,-j+param.cost(1)+1,k+1) = result(7);
%             instLabel.F1(-i+param.kernel(1)+1,-j+param.cost(1)+1,k+1)   = result(8);
%             %pause
%             instLabel.Th(-i+param.kernel(1)+1,-j+param.cost(1)+1,k+1)   = mean(threshold);
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
    sizeKernel = length(param.kernel);
    sizeCost   = length(param.cost);
    subplot(weightNum,3,3*(n-1)+1),contour(reshape(bag(:,:,n),sizeKernel,sizeCost));
    strKernel = {};
    strCost = {};
    for sk = 1:sizeKernel
        strKernel{sk} = num2str(param.kernel(sk),'%d');
    end
    for sC = 1:sizeCost
        strCost{sC} = num2str(param.cost(sC),'%d');
    end
    set(gca,'XTick',[1:1:sizeCost],'YTick',[1:1:sizeKernel]);
    set(gca,'XTickLabel',strCost,'YTickLabel',strKernel);
    % set(gca,'Xdir','reverse');
    set(gca,'Ydir','reverse');
    
    xlabel(['lg2 Cost Factor (base ' num2str(CostFactorO) ')']);
    ylabel(['lg2 KernelParam (base ' num2str(KernelParamO) ')']);
    title([svmType '/BagAccuray (Negative Weight=' num2str(NegativeWeight) ')']);
    grid on
    colorbar
    axis square
    disp('bag');
    bag(:,:,n)

    subplot(weightNum,3,3*(n-1)+2),contour(reshape(inst(:,:,n),sizeKernel,sizeCost));

    set(gca,'XTick',[1:1:sizeCost],'YTick',[1:1:sizeKernel]);
    set(gca,'XTickLabel',strCost,'YTickLabel',strKernel);
    % set(gca,'Xdir','reverse');
    set(gca,'Ydir','reverse');    
    
    xlabel(['lg2 Cost Factor (base ' num2str(CostFactorO) ')']);
    ylabel(['lg2 KernelParam (base ' num2str(KernelParamO) ')']);
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
    subplot(weightNum,3,3*(n-1)+3),contour(reshape(instLabel.F1(:,:,n),sizeKernel,sizeCost));

    set(gca,'XTick',[1:1:sizeCost],'YTick',[1:1:sizeKernel]);
    set(gca,'XTickLabel',strCost,'YTickLabel',strKernel);
    % set(gca,'Xdir','reverse');
    set(gca,'Ydir','reverse');
    
    xlabel(['lg2 Cost Factor (base ' num2str(CostFactorO) ')']);
    ylabel(['lg2 KernelParam (base ' num2str(KernelParamO) ')']);
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
    disp(['kernelParm=' num2str(KernelParamO*2^param.kernel(row(1))) ', costFactor=' num2str(CostFactorO*2^param.cost(col(1))) ', NegativeWeight=' num2str(NegativeWeight)]);
    tempF1(n) = instLabel.F1(row(1),col(1),n);
    tempKernel(n) = KernelParamO*2^param.kernel(row(1));
    tempCost(n) = CostFactorO*2^param.cost(col(1));
    tempNegativeWeight(n) = NegativeWeight;
    tempTh(n) = instLabel.Th(row(1),col(1),n);
end

disp(' ');
disp(' ');
disp(['tempF1:' num2str(tempF1) ', tempTh:' num2str(tempTh)]);

optimalWeightIdx = find(tempF1 == max(tempF1));
optimalKernel = tempKernel(optimalWeightIdx(1));
optimalCost   = tempCost(optimalWeightIdx(1));
optimalNegativeWeight = tempNegativeWeight(optimalWeightIdx(1));
optimalF1 = tempF1(optimalWeightIdx(1));
optimalTh = tempTh(optimalWeightIdx(1));

disp(' ');
disp(['optKernelParm=' num2str(optimalKernel) ', optCostFactor=' num2str(optimalCost) ', optNegativeWeight=' num2str(optimalNegativeWeight) ': F1=' num2str(optimalF1) ', optTh:' num2str(optimalTh)]);
disp(['KernelParmN1=' num2str(tempKernel(1)) ', CostFactorN1=' num2str(tempCost(1)) ', NegativeWeightN1=' num2str(tempNegativeWeight(1)) ': F1N1=' num2str(tempF1(1)) ', tempTh:' num2str(tempTh)]);

svmsetting.kernel = optimalKernel;
svmsetting.cost = optimalCost;
svmsetting.negativeweight = optimalNegativeWeight;
svmsetting.Th = optimalTh;
svmsetting.F1 = optimalF1;


% if ~isempty(playerNum)
%     optimalFiles = [targetDir '/' datasetSelect featureSelect '/' tacticSelect featureSelect playerNum '/' EvaluationSelect '/SVM/' SVMType '/' SVMKernelType '/K=' num2str(optimalKernel) 'C=' num2str(optimalCost) 'N=' num2str(optimalNegativeWeight) '/' SVMType];
%     outputFolder = strrep(optimalFiles,'tuning','result');
%     filesepIdx = strfind(outputFolder,'/');
%     outputFolder = outputFolder(1:filesepIdx(end));
% else
%     optimalFiles = [targetDir '/' datasetSelect featureSelect '/' tacticSelect featureSelect '/' EvaluationSelect '/SVM/' SVMType '/' SVMKernelType '/K=' num2str(optimalKernel) 'C=' num2str(optimalCost) 'N=' num2str(optimalNegativeWeight) '/' SVMType];
%     outputFolder = strrep(optimalFiles,'tuning','result');
%     filesepIdx = strfind(outputFolder,'/');
%     outputFolder = outputFolder(1:filesepIdx(end));
% end
% 
% 
% if ~exist(outputFolder,'dir')
%     mkdir(outputFolder)
% end
% copyfile([optimalFiles '*'],outputFolder);
% originalFiles = strrep(optimalFiles,'Convert(Th)/','');
% originalFilesOutFolder = strrep(originalFiles,'tuning','result');
% filesepIdx = strfind(originalFilesOutFolder,'/');
% originalFilesOutFolder = originalFilesOutFolder(1:filesepIdx(end));
% if ~exist(originalFilesOutFolder,'dir')
%     mkdir(originalFilesOutFolder)
% end
% copyfile([originalFiles '*'],originalFilesOutFolder);

outputFolder = [targetDir '/' EvaluationSelect '/SVM/' SVMType '/' SVMKernelType];

% set(gcf,'units','normalized','position',[0 0 1 1]);
set(gcf,'outerposition',get(0,'screensize'));
set(gcf,'PaperPositionMode','auto');
saveas(gcf,[outputFolder '/SVMParamTune.png']);

end