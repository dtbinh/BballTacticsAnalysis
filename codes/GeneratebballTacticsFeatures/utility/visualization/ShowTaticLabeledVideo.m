function ShowTaticLabeledVideo(fileIO,testcase,sortedImagFiles,court,pos)
% 2016/2/20 Tsung-Yu Tsai
% show and save tactics trajectories and their original broadcast video,
% trajecties are saved as two type: graph and line


color = {'ro', 'go', 'bo', 'yo', 'co'};
imagNum = size(sortedImagFiles,1);

path = [fileIO.outputDir 'labeled' filesep];
if ~exist(path,'dir')
    mkdir(path);
end

writerObj = VideoWriter(fullfile(path,[testcase '_r.avi'])); % Name it.
writerObj.FrameRate = 5;
open(writerObj);

fid = figure;
set(fid, 'Position', [1 1 900 600]);
s(3) = subplot(2, 3, 6);
imshow(court * 0.8, 'Border', 'tight'), hold on;
for i = 1:min(imagNum,size(pos{1},1))
    figure(fid);
    img = imread([fileIO.sourceDir testcase filesep sortedImagFiles{i}]);
    s(1) = subplot(2, 3, [1 2 4 5]); 
    imshow(img);
    title([int2str(i) '/' int2str(imagNum)]);
    s(2) = subplot(2, 3, 3);
    imshow(court * 0.8, 'Border', 'tight');
    title([int2str(i) '/' int2str(size(pos{1},1))]);
    
    link = [pos{1, 1}(i, :); pos{1, 2}(i, :); pos{1, 3}(i, :); pos{1, 4}(i, :); pos{1, 5}(i, :); pos{1, 1}(i, :); pos{1, 3}(i, :); pos{1, 5}(i, :); pos{1, 2}(i, :); pos{1, 4}(i, :); pos{1, 1}(i, :)]; 
    hold on;
    plot(link(:, 1), link(:, 2), 'Color', [0.3 0.3 0.3]);

    for j = 1:5
        plot(pos{1, j}(i, 1), pos{1, j}(i, 2), 'ko', 'MarkerFaceColor', 'w','MarkerSize', 10);
        text(pos{1, j}(i, 1)-4, pos{1, j}(i, 2), ['\bf' int2str(j) '\bf'], 'Color', 'k', 'FontSize', 8);
    end
    hold off;
    subplot(2, 3, 6); title([int2str(i) '/' int2str(size(pos{1},1))]);
    for j = 1:5
        plot(pos{1, j}(i, 1), pos{1, j}(i, 2), color{1, j}, 'MarkerFaceColor', color{1, j}(1),'MarkerSize', 3);
    end
    frame = getframe(fid);
    writeVideo(writerObj, frame);
end
close(writerObj);
close(fid);
end