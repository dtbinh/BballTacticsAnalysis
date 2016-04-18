function ShowTrajOnCourtArea(gtSAlignSync,tactics,courtArea)

color = {'ro', 'go', 'bo', 'yo', 'co'};
for r = 1:length(tactics.videoIndex)
    vidObj = VideoWriter([tactics.Name{r} '(' int2str(tactics.videoIndex{r}(1)) '-' int2str(tactics.videoIndex{r}(end)) ').avi']);
    frameNum = size(gtSAlignSync{tactics.refVideoIndex(r)},1);
    open(vidObj);
    figure(1)
    %set(1, 'Position', [1 1 900 600]);
    set(gcf,'outerposition',get(0,'screensize'));
    set(gcf,'PaperPositionMode','auto');
%     subplot(1,size(gtSAlignSync,2),1),imshow(courtArea);hold on
%     subplot(1,size(gtSAlignSync,2),2),imshow(courtArea);hold on
%     subplot(1,size(gtSAlignSync,2),3),imshow(courtArea);hold on
%     subplot(1,size(gtSAlignSync,2),4),imshow(courtArea);hold on
%     subplot(1,size(gtSAlignSync,2),5),imshow(courtArea);hold on
    for f = 1:frameNum
        for p = 1:size(gtSAlignSync,2)
            subplot(1,size(gtSAlignSync,2),p),imshow(courtArea);hold on
            %subplot(1,size(gtSAlignSync,2),p)
            for t =tactics.videoIndex{r}
                 plot(gtSAlignSync{t, p}(f, 1), gtSAlignSync{t, p}(f, 2), color{1, p}, 'MarkerFaceColor', color{1, p}(1),'MarkerSize', 3);
            end
            title(['(' int2str(f) '/' int2str(frameNum)  ')']);
        end
        
        currFrame = getframe(gcf);
        writeVideo(vidObj,currFrame);
    end
    close(vidObj);
end