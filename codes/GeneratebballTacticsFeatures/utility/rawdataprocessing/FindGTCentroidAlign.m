function [assign,matcost] = FindGTCentroidAlign(tactics,Traj,feature)

frameRate = 30;
% calculate dtw matching 
for r = 1:length(tactics.refVideoIndex)
    disp(['Calculate Matching in Tactic ' tactics.Name{r} '...']);
        
    switch feature
        case 'P'
            for t = 1:length(tactics.refVideoIndex)
                Traj_Temp(t,:) = Traj(t,:);
            end
        case 'P+V'
            for t = 1:length(tactics.refVideoIndex)
                Traj_Temp(t,:) = GeneratePVFeature(Traj(t,:),frameRate);
            end
        otherwise
            error('Not existed feature!');
    end

end

for t = 1:length(tactics.refVideoIndex)
    disp(['video ' int2str(t) ' dtw processing...']);  
    for r= 1:length(tactics.refVideoIndex)%tactics.videoIndex{r}
        for p1= 1:size(Traj_Temp,2)
            for p2= 1:size(Traj_Temp,2)
                     
                % sync with most important key player
                if ~exist('flip','var') || flip == 0
                %[Dist(t,r),D{t,r},k(t,r),w{t,r}]=dtw(Traj{t,1},Traj{tactics.refVideoIndex(r),1});
                %[Dist{t,r}(p),~,k{t,r}(p),w{t,r}{p}]=dtw(Traj{t,p},Traj{tactics.refVideoIndex(r),p});
                %avgDist(r,p) = Dist{t,r}(p)/k{t,r}(p);
                [Dist{t,r}(p1,p2),D{t,r}{p1,p2},k{t,r}(p1,p2),w{t,r}{p1,p2}]=dtw(Traj_Temp{t,p1},Traj_Temp{r,p2});
                Dist{t,r}(p1,p2) = Dist{t,r}(p1,p2)/k{t,r}(p1,p2);
                end
            end
        end
        [assign{t,r},matcost(t,r)] = munkres(Dist{t,r});
    end
end
    

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