function  ShowTacticSyncResult(fileIO, targetFile, court, Traj_Align, Traj_Sync, Traj_Ref, RefIndex)
% 2016/2/20 Tsung-Yu Tsai
% show and save videos of unsync tactics and their sync result, also plot
% trajectory used as sync reference

color = {'ro', 'go', 'bo', 'yo', 'co'};

path = [fileIO.outputDir 'sync_result' filesep];
if ~exist(path,'dir')
    mkdir(path);
end

writerObj = VideoWriter(fullfile(path,[ targetFile '_sync.avi'])); % Name it.
writerObj.FrameRate = 25;
open(writerObj);

fid = figure;
set(fid, 'Position', [1 1 900 600]);

s(1) = subplot(1, 3, 1);
imshow(court * 0.8, 'Border', 'tight'); hold on; 
s(2) = subplot(1, 3, 2);
imshow(court * 0.8, 'Border', 'tight'); hold on; 
s(3) = subplot(1, 3, 3);
imshow(court * 0.8, 'Border', 'tight'), hold on; 

s(1) = subplot(1, 3, 1);

for j = 1:5
    plot(Traj_Align{1, j}(:, 1), Traj_Align{1, j}(:, 2), color{1, j}, 'MarkerFaceColor', color{1, j}(1),'MarkerSize', 3);
    text(Traj_Align{1, j}(1, 1), Traj_Align{1, j}(1, 2), ['P' int2str(j)]);
end



for i = 1:size(Traj_Ref{1},1)
    s(2) = subplot(1, 3, 2);
    for j = 1:5
        plot(Traj_Sync{1, j}(i, 1), Traj_Sync{1, j}(i, 2), color{1, j}, 'MarkerFaceColor', color{1, j}(1),'MarkerSize', 3);
    end
    title(['SYNC (' int2str(i) '/' int2str(size(Traj_Sync{1},1)) ')']);
    s(3) = subplot(1, 3, 3);
    for j = 1:5
        plot(Traj_Ref{1, j}(i, 1), Traj_Ref{1, j}(i, 2), color{1, j}, 'MarkerFaceColor', color{1, j}(1),'MarkerSize', 3);
    end
    title(['Reference' int2str(RefIndex) ' (' int2str(i) '/' int2str(size(Traj_Ref{1},1)) ')']);
    frame = getframe(fid);
    writeVideo(writerObj, frame);    
end


close(writerObj);
close(fid);

end