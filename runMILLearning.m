clear all

addpath(genpath([pwd '/codes/MILL']));


% multiplayer region-temporal kernel param 0 (stage 10)
% param.kernel0 = 1/(11*10);  % 11regions*stageNume

% % single player temporal 
% param.kernel0 = 1/(2*10);

% default kernel0
param.kernel0 = 1;

param.kernel = 3:-1:-15;
param.cost = 15:-1:-5;
param.negativeWeight = 0;

BenchResult(param,'cross_validate','RBF','inst_MI');

BenchResult(param,'cross_validate','RBF','bag_MI');

BenchResult(param,'cross_validate','linear','inst_MI');

BenchResult(param,'cross_validate','linear','bag_MI');

rmpath(genpath([pwd '/codes/MILL']));