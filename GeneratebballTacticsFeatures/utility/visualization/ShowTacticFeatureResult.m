function ShowTacticFeatureResult(fileIO, targetFile, court, Traj_Align, Traj_Sync, Traj_Feature)
% 2016/2/20 Tsung-Yu Tsai
% show and save video from unsync video to final feature used in MILL
% toolkit, intermediate is the sync result using specific algorithm, now
% Feature only support dot plot of feature (suitable for position). 
% future version will support scatter plot (for velocity)

color = {'ro', 'go', 'bo', 'yo', 'co'};

colorx = {'rx', 'gx', 'bx', 'yx', 'cx'};

interval = round(size(Traj_Sync{1},1)/size(Traj_Feature{1},1));

path = [fileIO.outputDir 'feature_result' filesep];
if ~exist(path,'dir')
    mkdir(path);
end

writerObj = VideoWriter(fullfile(path,[ targetFile '_f.avi'])); % Name it.
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

for i = 1:size(Traj_Sync{1},1)
    s(2) = subplot(1, 3, 2);
    for j = 1:5
        plot(Traj_Sync{1, j}(i, 1), Traj_Sync{1, j}(i, 2), color{1, j}, 'MarkerFaceColor', color{1, j}(1),'MarkerSize', 3);
    end
    title(['SYNC (' int2str(i) '/' int2str(size(Traj_Sync{1},1)) ')']);
    s(3) = subplot(1, 3, 3);
    if mod(i,interval) == 0
        stage = i/interval;
        for j = 1:5
            plot(Traj_Feature{1, j}(stage, 1), Traj_Feature{1, j}(stage, 2), colorx{1, j}, 'MarkerFaceColor', color{1, j}(1),'MarkerSize', 6);
        end
        title(['Feature Output (' int2str(stage) '/' int2str(size(Traj_Feature{1},1)) ')']);
    end
    frame = getframe(fid);
    writeVideo(writerObj, frame);    
end


close(writerObj);
close(fid);

end