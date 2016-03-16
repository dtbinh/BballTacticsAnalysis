function [Traj_Sync, refPlayer] = GenerateSyncData(Traj,tactics,mode,feature,flip)

frameRate = 30;
% calculate dtw matching 
for r = 1:length(tactics.refVideoIndex)
    disp(['Calculate Matching in Tactic ' tactics.Name{r} '...']);
        
    switch mode
        case 'first'
            p = 1;
            switch feature
                case 'P'
                    for t = tactics.videoIndex{r}
                        Traj_Temp(t,:) = Traj(t,:);
                    end
                case 'P+V'
                    for t = tactics.videoIndex{r}
                        Traj_Temp(t,:) = GeneratePVFeature(Traj(t,:),frameRate);
                    end
                otherwise
                    error('Not existed feature!');
            end
        case 'minMed'
            p = chooseOptimalPlayerInTactics(Traj(tactics.videoIndex{r},:),Traj(tactics.refVideoIndex(r),:));
            switch feature
                case 'P'
                    for t = tactics.videoIndex{r}
                        Traj_Temp(t,:) = Traj(t,:);
                    end
                case 'P+V'
                    for t = tactics.videoIndex{r}
                        Traj_Temp(t,:) = GeneratePVFeature(Traj(t,:),frameRate);
                    end
                otherwise
                    error('Not existed feature!');
            end                
        case 'concat'
            p = 1;
            switch feature
                case 'P'
                    for t = tactics.videoIndex{r}
                        Traj_Temp{t,:} = [Traj{t,1} Traj{t,2} Traj{t,3} Traj{t,4} Traj{t,5}];
                    end
                case 'P+V'
                    for t = tactics.videoIndex{r}
                        Traj_PV(t,:) = GeneratePVFeature(Traj(t,:),frameRate);
                        Traj_Temp{t,1} = [Traj_PV{t,1} Traj_PV{t,2} Traj_PV{t,3} Traj_PV{t,4} Traj_PV{t,5}];
                    end
                otherwise
                    error('Not existed feature!');
            end                     
        otherwise
            error('Mode don''t exist!!')
    end
    disp(['Optimal Reference Player ' int2str(p)]);
    refPlayer(r) = p;
        
    for t= tactics.videoIndex{r}
        disp(['video ' int2str(t)]);       
        % sync with most important key player
        if ~exist('flip','var') || flip == 0
            %[Dist(t,r),D{t,r},k(t,r),w{t,r}]=dtw(Traj{t,1},Traj{tactics.refVideoIndex(r),1});
            %[Dist{t,r}(p),~,k{t,r}(p),w{t,r}{p}]=dtw(Traj{t,p},Traj{tactics.refVideoIndex(r),p});
            %avgDist(r,p) = Dist{t,r}(p)/k{t,r}(p);
            [Dist(t,r),D{t,r},k(t,r),w{t,r}]=dtw(Traj_Temp{t,p},Traj_Temp{tactics.refVideoIndex(r),p});
        else
            [~,~,~,w{t,r}]=dtw(flipud(Traj{t,1}),flipud(Traj{tactics.refVideoIndex(r),1}));
            w{t,r}(:,1) = flipud(size(Traj{t,1},1)+1-w{t,r}(:,1));
            w{t,r}(:,2) = flipud(size(Traj{tactics.refVideoIndex(r),1},1)+1-w{t,r}(:,2));
        end
       % end
    end
end


for target = 1:length(tactics.refVideoIndex)
    for t = tactics.videoIndex{target}
        disp(['Sync Tactic Video ' int2str(t) ' ...']);
        % each tactic local sync
        matchingTable = w{t,target};
%         % global sync to tactic 1 
%         matchingTable = w{RefTacticIndex(1),TacticsIndex{t}(target)};
        if ~isempty(matchingTable)
            histogram{matchingTable(1,2)} = [];
            for i=1:size(matchingTable,1)
                if ~isempty(histogram{matchingTable(i,2)})
                    histogram{matchingTable(i,2)} = [histogram{matchingTable(i,2)},matchingTable(i,1)];
                else
                    histogram{matchingTable(i,2)} = matchingTable(i,1);
                end
            end
            for p=1:5
                disp(['Sync Player' int2str(p) '!']);
                for h=1:length(histogram)
                    %disp(['hist ' int2str(h)]);
                    Traj_Sync{t,p}(h,:) = mean(Traj{t,p}(histogram{h},:),1);
                end
            end
            clear histogram;
        else %first tactic
            Traj_Sync(t,:) = Traj(t,:);
        end
    end
end
end


function [playerIdx, DTWValue] = chooseOptimalPlayerInTactics(Traj,Traj_Ref)
    for T = 1:size(Traj,1)
        for p = 1:size(Traj,2)
            [Dist(T,p),~,k(T,p),~] = dtw(Traj{T,p},Traj_Ref{1,p});
            Dist(T,p) = Dist(T,p)/k(T,p);
        end
    end
    %totalSumDTW = sum(Dist,1);
    %playerIdx = find(totalSumDTW == min(totalSumDTW));
    %DTWValue = min(mean(Dist,1));
    
    medianDTW = median(Dist,1);
    playerIdx = find(medianDTW == min(medianDTW));
    DTWValue = min(medianDTW);
    

end

function Traj_PV = GeneratePVFeature(Traj,frameRate)
    for p = 1:size(Traj,2)
        [n,~] = size(Traj{1,p});
        Traj_PV{1,p}(:,1) = Traj{1,p}(:,1);
        Traj_PV{1,p}(:,2) = Traj{1,p}(:,2);
        Traj_PV{1,p}(1:n-1,3) = frameRate*(Traj{1,p}(2:n,1)-Traj{1,p}(1:n-1,1));
        Traj_PV{1,p}(n,3) = Traj_PV{1,p}(n-1,3);
        Traj_PV{1,p}(1:n-1,4) = frameRate*(Traj{1,p}(2:n,2)-Traj{1,p}(1:n-1,2));
        Traj_PV{1,p}(n,4) = Traj_PV{1,p}(n-1,4);

    end
end
