function Traj_Sync = GenerateSyncData(Traj,tactics,flip)

% calculate dtw matching 
for r = 1:length(tactics.refVideoIndex)
    disp(['Calculate Matching in Tactic ' tactics.Name{r} '...']);
    for t = tactics.videoIndex{r}
        disp(['video ' int2str(t)]);
        % sync with most important key player
        if ~exist('flip','var') || flip == 0
            [Dist(t,r),D{t,r},k(t,r),w{t,r}]=dtw(Traj{t,1},Traj{tactics.refVideoIndex(r),1});
        else
            [~,~,~,w{t,r}]=dtw(flipud(Traj{t,1}),flipud(Traj{tactics.refVideoIndex(r),1}));
            w{t,r}(:,1) = flipud(size(Traj{t,1},1)+1-w{t,r}(:,1));
            w{t,r}(:,2) = flipud(size(Traj{tactics.refVideoIndex(r),1},1)+1-w{t,r}(:,2));
        end
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

%save('SAlignSync.mat','SAlignSync');