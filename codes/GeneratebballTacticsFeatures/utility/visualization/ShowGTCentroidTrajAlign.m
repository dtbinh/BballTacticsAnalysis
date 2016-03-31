function ShowGTCentroidTrajAlign(fileIO,court,traj_origin,gtCentroidassign,gtCentroidcost,tactics)

color = {'ro', 'go', 'bo', 'yo', 'co'};

path = [fileIO.outputDir 'gtCentroidAlignment' filesep];
if ~exist(path,'dir')
    mkdir(path);
end

fid = figure;
set(fid, 'Position', [1 1 900 600]);

for r = 1:size(traj_origin,1)
    for c = 1:size(traj_origin,2)
        if r ~= c
            s(4) = subplot(2, 2, 4);
            imshow(court * 0.8, 'Border', 'tight'); hold on;
            s(2) = subplot(2, 2, 2);
            imshow(court * 0.8, 'Border', 'tight'); hold on;
            s(3) = subplot(2, 2, 3);
            imshow(court * 0.8, 'Border', 'tight'), hold on;
            s(1) = subplot(2, 2, 1);
            imshow(court * 0.8, 'Border', 'tight'), hold on;


            for p = 1:5
                subplot(2, 2, 1),plot(traj_origin{r, p}(:, 1), traj_origin{r, p}(:, 2), color{1, p}, 'MarkerFaceColor', color{1, p}(1),'MarkerSize', 3); 
                
                subplot(2, 2, 2),plot(traj_origin{c, p}(:, 1), traj_origin{c, p}(:, 2), color{1, gtCentroidassign{r,c}(p)}, 'MarkerFaceColor', color{1, gtCentroidassign{r,c}(p)}(1),'MarkerSize', 3);
                
                subplot(2, 2, 3),plot(traj_origin{r, p}(:, 1), traj_origin{r, p}(:, 2), color{1, p}, 'MarkerFaceColor', color{1, p}(1),'MarkerSize', 3);
                
                subplot(2, 2, 4),plot(traj_origin{c, gtCentroidassign{c,r}(p)}(:, 1), traj_origin{c, gtCentroidassign{c,r}(p)}(:, 2), color{1, p}, 'MarkerFaceColor', color{1, p}(1),'MarkerSize', 3); 
                
                
            end
            subplot(2, 2, 1), title([tactics.Name{r} ': ' int2str(tactics.refVideoIndex(r))]);hold off 
            subplot(2, 2, 2), title([tactics.Name{c} ': ' int2str(tactics.refVideoIndex(c))]);hold off
            subplot(2, 2, 3), title([tactics.Name{r} ': ' int2str(tactics.refVideoIndex(r))]);hold off
            subplot(2, 2, 4), title([tactics.Name{c} ': ' int2str(tactics.refVideoIndex(c))]);hold off 
            saveas(fid,[path '(' tactics.Name{r} ',' tactics.Name{c} ').png'],'png');
        end
    end
end

end