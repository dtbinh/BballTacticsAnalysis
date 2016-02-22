function ShowBasketballTrajAlign(fileIO,targetFile,sortedImagFiles,court,traj_origin,traj_assign,traj_gt)
% 2016/2/20 Tsung-Yu Tsai
% show and save videos of order of original tactic trajectories and order
% after running specific player alignment algorithm comparing to ground truth labeled manually 

color = {'ro', 'go', 'bo', 'yo', 'co'};
imagNum = size(sortedImagFiles,1);

path = [fileIO.outputDir 'alignment_result' filesep];
if ~exist(path,'dir')
    mkdir(path);
end

writerObj = VideoWriter(fullfile(path,[ targetFile '_a.avi'])); % Name it.
writerObj.FrameRate = 25;
open(writerObj);

fid = figure;
set(fid, 'Position', [1 1 900 600]);

s(4) = subplot(3, 3, 8);
imshow(court * 0.8, 'Border', 'tight'); hold on;
s(2) = subplot(3, 3, 7);
imshow(court * 0.8, 'Border', 'tight'); hold on;
s(3) = subplot(3, 3, 9);
imshow(court * 0.8, 'Border', 'tight'), hold on;
for i = 1:min(imagNum,size(traj_origin{1},1))
    figure(fid);
    %img = imread([dirname imgNames(i).name]);
    img = imread([fileIO.sourceDir filesep targetFile filesep sortedImagFiles{i}]);
    s(1) = subplot(3, 3, [1 2 3 4 5 6]); 
    imshow(img);
    title([int2str(i) '/' int2str(imagNum)]);
    s(2) = subplot(3, 3, 7);
    title(['Before ' int2str(i) '/' int2str(size(traj_origin{1},1))]);
    
    for j = 1:5
        plot(traj_origin{1, j}(i, 1), traj_origin{1, j}(i, 2), color{1, j}, 'MarkerFaceColor', color{1, j}(1),'MarkerSize', 3);
    end
    
    if ~isempty(traj_assign)
    subplot(3, 3, 9); title(['After ' int2str(i) '/' int2str(size(traj_assign{1},1))]);
    
    for j = 1:5
        plot(traj_assign{1, j}(i, 1), traj_assign{1, j}(i, 2), color{1, j}, 'MarkerFaceColor', color{1, j}(1),'MarkerSize', 3);
    end
    end
    
    % added groundtruth
    if ~isempty(traj_gt)    
    subplot(3,3,8); title(['Ground Truth ' int2str(i) '/' int2str(size(traj_gt{1},1))]);
    for j = 1:5
        plot(traj_gt{1, j}(i, 1), traj_gt{1, j}(i, 2), color{1, j}, 'MarkerFaceColor', color{1, j}(1),'MarkerSize', 3);
    end
    end
    
    frame = getframe(fid);
    writeVideo(writerObj, frame);
end

close(writerObj);
close(fid);

end
