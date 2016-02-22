
tactics.Name = {'F23','EV','HK','PD','PT','RB','SP','WS','WV','WW'};
tactics.videoIndex = {1:15,16:26,27:46,47:55,56:68,69:83,84:98,99:111,112:127,128:134};
tactics.refVideoIndex = [1,19,30,47,60,69,84,106,112,129];
% F23 Alignment
tactics.gtAlignment(tactics.videoIndex{1},:) = [1 5 2 4 3; 1 5 2 4 3; 1 5 2 4 3; 1 5 2 4 3; 1 5 2 4 3; ...
    1 5 2 4 3; 1 5 2 4 3; 1 2 5 4 3; 1 5 2 4 3; 3 4 5 2 1; 1 2 5 4 3; 1 5 2 4 3; 1 5 2 4 3; 1 5 2 4 3;1 5 2 4 3];
% F23 KeyPlayers
tactics.keyPlayer(tactics.videoIndex{1},:)=repmat([1 1 1 0 0],length(tactics.videoIndex{1}),1);

% EV Alignment
tactics.gtAlignment(tactics.videoIndex{2},:) = [5 2 4 1 3; 1 2 4 3 5; 2 4 3 5 1; 3 4 2 5 1; 3 4 2 5 1; 3 4 2 5 1; ...
    3 4 2 5 1; 3 4 2 5 1; 3 4 2 5 1; 3 4 2 5 1; 3 4 2 5 1];
% EV KeyPlayers
tactics.keyPlayer(tactics.videoIndex{2},:)=repmat([1 1 1 0 0],length(tactics.videoIndex{2}),1);

% HK Alignment
tactics.gtAlignment(tactics.videoIndex{3},:) = [5 2 3 4 1; 3 1 2 5 4; 2 5 1 3 4; 2 4 5 3 1; 3 1 5 4 2; 3 1 4 5 2; ...
    3 2 5 4 1; 2 3 5 1 4; 1 5 4 3 2; 4 1 2 3 5; 3 1 4 2 5; 1 2 5 3 4; 5 2 4 3 1; 1 5 4 3 2; 1 4 3 5 2; ...
    3 2 1 4 5; 2 4 5 3 1; 2 4 1 5 3; 5 2 1 4 3; 2 1 5 3 4];
% HK KeyPlayers
tactics.keyPlayer(tactics.videoIndex{3},:)=repmat([1 1 1 0 0],length(tactics.videoIndex{3}),1);

% PD Alignment
tactics.gtAlignment(tactics.videoIndex{4},:) = [2 3 4 1 5; 2 3 4 1 5; 2 3 4 1 5; 2 3 4 1 5; 2 3 4 1 5; 1 3 2 4 5; ...
    2 3 4 1 5; 2 3 4 1 5; 3 2 4 1 5];
% PD KeyPlayers
tactics.keyPlayer(tactics.videoIndex{4},:)=repmat([1 1 1 0 0],length(tactics.videoIndex{4}),1);

% PT Alignment
%tactics.gtAlignment(tactics.videoIndex{5},:) = [1 2 5 4 3; 2 1 3 4 5; 1 2 3 5 4; 2 1 3 4 5; 2 1 3 4 5; 2 1 3 4 5; ...
%    2 1 3 4 5; 1 2 3 4 5;5 3 4 2 1; 1 2 4 3 5; 2 1 3 4 5; 1 3 5 2 4; 1 2 5 4 3];
tactics.gtAlignment(tactics.videoIndex{5},:) = [2 1 4 3 5; 2 1 4 3 5; 2 1 5 3 4; 1 2 4 5 3; 2 1 4 3 5; 2 1 4 3 5; ...
    2 1 4 3 5; 1 2 4 3 5; 5 3 2 4 1; 1 2 3 4 5; 2 1 4 5 3; 1 3 2 5 4; 1 2 4 5 3];
% PT KeyPlayers
tactics.keyPlayer(tactics.videoIndex{5},:)=repmat([1 1 0 1 0],length(tactics.videoIndex{5}),1);

% RB Alignment
tactics.gtAlignment(tactics.videoIndex{6},:) = [5 1 2 4 3; 5 1 2 4 3; 3 1 2 5 4; 3 1 2 4 5; 3 1 2 4 5; 3 1 2 4 5; ...
    3 1 2 4 5; 2 1 3 5 4; 5 1 2 4 3; 5 1 2 4 3; 5 2 1 4 3; 3 2 1 4 5; 5 1 2 4 3; 5 1 2 4 3; 5 1 2 4 3];
% RB Alignment
tactics.keyPlayer(tactics.videoIndex{6},:)=repmat([1 1 1 0 0],length(tactics.videoIndex{6}),1);

% SP Alignment
tactics.gtAlignment(tactics.videoIndex{7},:) = [1 3 2 5 4; 2 4 3 5 1; 5 3 4 2 1; 1 3 2 5 4; 5 3 4 2 1; 5 4 3 1 2; ...
    1 4 3 2 5; 1 3 2 4 5; 1 4 3 5 2; 1 3 2 5 4; 5 3 4 1 2; 5 3 4 1 2; 5 3 4 2 1; 5 3 4 1 2; 5 3 4 1 2];
% SP KeyPlayers
tactics.keyPlayer(tactics.videoIndex{7},:)=repmat([1 1 0 0 0],length(tactics.videoIndex{7}),1);

% WS Alignment
tactics.gtAlignment(tactics.videoIndex{8},:) = [2 5 4 1 3; 2 5 1 3 4; 2 3 4 1 5; 2 5 4 1 3; 2 3 1 5 4; 3 4 1 2 5; ...
    2 3 1 4 5; 4 5 2 1 3; 3 4 2 1 5; 2 3 1 5 4; 4 3 2 1 5; 5 3 1 4 2; 5 4 1 2 3];
% WS KeyPlayers
tactics.keyPlayer(tactics.videoIndex{8},:)=repmat([1 1 1 0 0],length(tactics.videoIndex{8}),1);

% WV Alignment
tactics.gtAlignment(tactics.videoIndex{9},:) = [1 3 2 5 4; 5 3 2 1 4; 1 4 5 3 2; 1 3 5 2 4; 1 4 2 5 3; 1 4 2 5 3; ...
    1 2 3 5 4; 2 1 5 3 4; 1 2 5 4 3; 1 3 2 4 5; 1 4 3 5 2; 1 4 3 5 2; 1 4 3 5 2; 1 4 2 5 3; 2 4 3 5 1; ...
    1 2 4 5 3];
% WV KeyPlayers
tactics.keyPlayer(tactics.videoIndex{9},:)=repmat([1 1 1 1 1],length(tactics.videoIndex{9}),1);

% WW Alignment
tactics.gtAlignment(tactics.videoIndex{10},:) = [2 1 5 4 3; 1 2 5 4 3; 1 2 5 4 3; 1 2 5 4 3; 1 2 5 4 3; 1 2 5 4 3; ...
    1 2 5 4 3];
% WW KeyPlayers
tactics.keyPlayer(tactics.videoIndex{10},:)=repmat([1 1 0 0 0],length(tactics.videoIndex{10}),1);