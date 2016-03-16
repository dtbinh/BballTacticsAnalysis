function CompareSyncDataInVideo(tactics,court,trajAlign,trajSyncFirstP,trajSyncFirstPV,trajSyncMinMedP,refMinMedP,trajSyncMinMedPV,refMinMedPV,trajSyncConcatP,trajSyncConcatPV)

color = {'ro','go','bo','yo','co'};
figure(1),set(1,'Position',[0 0 1280 720]);


folder = 'Output/DiffSyncRef/';
mkdir(folder);

for r = 1:length(tactics.videoIndex)
    for t = tactics.videoIndex{r}
        if t == tactics.refVideoIndex(r)
            prefix = 'ref_';
        else
            prefix = '';
        end
        vidObj = VideoWriter([folder prefix 'video' int2str(t) ' (' tactics.Name{r} ').avi']);
        vidObj.FrameRate = 30;
        open(vidObj);
        subplot(2,4,1),imshow(court); hold on 
        subplot(2,4,2),imshow(court); hold on 
        subplot(2,4,3),imshow(court); hold on
        subplot(2,4,4),imshow(court); hold on 
        subplot(2,4,5),imshow(court); hold on
        subplot(2,4,6),imshow(court); hold on
        subplot(2,4,7),imshow(court); hold on
        subplot(2,4,8),imshow(court); hold on
        for n1 = 1:size(trajAlign{t,1},1)
            for p1 = 1:size(trajAlign,2)
                subplot(2,4,1), plot(trajAlign{t,p1}(n1,1),trajAlign{t,p1}(n1,2),color{p1},'MarkerSize',2);
                title(['origin video (' int2str(n1) '/' int2str(size(trajAlign{t,1},1)) ')']);
               
            end
            frame = getframe(1);
            writeVideo(vidObj, frame);  
        end
                

        
        [n,~] = size(trajSyncFirstP{t,1});
        for i = 1:n
            for p = 1:size(trajSyncFirstP,2)
                subplot(2,4,2), plot(trajAlign{tactics.refVideoIndex(r),p}(i,1),trajAlign{tactics.refVideoIndex(r),p}(i,2),color{p},'MarkerSize',2);
                title(['ref video ' int2str(tactics.refVideoIndex(r)) ' (' int2str(i) '/' int2str(n) ')']);
                subplot(2,4,3), plot(trajSyncFirstP{t,p}(i,1),trajSyncFirstP{t,p}(i,2),color{p},'MarkerSize',2);
                title(['1st player P (' int2str(i) '/' int2str(n) ')']);
                subplot(2,4,4), plot(trajSyncFirstPV{t,p}(i,1),trajSyncFirstPV{t,p}(i,2),color{p},'MarkerSize',2);
                title(['1st player P+V (' int2str(i) '/' int2str(n) ')']);
                subplot(2,4,5), plot(trajSyncMinMedP{t,p}(i,1),trajSyncMinMedP{t,p}(i,2),color{p},'MarkerSize',2);
                title(['minDTW player P:' int2str(refMinMedP(r)) ' (' int2str(i) '/' int2str(n) ')']);
                subplot(2,4,6), plot(trajSyncConcatP{t,p}(i,1),trajSyncConcatP{t,p}(i,2),color{p},'MarkerSize',2);
                title(['ConcatAll players P (' int2str(i) '/' int2str(n) ')']);
                subplot(2,4,7), plot(trajSyncMinMedPV{t,p}(i,1),trajSyncMinMedPV{t,p}(i,2),color{p},'MarkerSize',2);
                title(['minDTW player P+V:' int2str(refMinMedPV(r)) ' (' int2str(i) '/' int2str(n) ')']);
                subplot(2,4,8), plot(trajSyncConcatPV{t,p}(i,1),trajSyncConcatPV{t,p}(i,2),color{p},'MarkerSize',2);
                title(['ConcatAll players P+V (' int2str(i) '/' int2str(n) ')']);
            end
            frame = getframe(1);
            writeVideo(vidObj, frame);   
        end
        close(vidObj)
        subplot(2,4,1),hold off 
        subplot(2,4,2),hold off
        subplot(2,4,3),hold off
        subplot(2,4,4),hold off 
        subplot(2,4,5),hold off
        subplot(2,4,6),hold off
        subplot(2,4,7),hold off
        subplot(2,4,8),hold off
    end
end

end