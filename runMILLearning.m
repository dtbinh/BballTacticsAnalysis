clear all

addpath(genpath([pwd '/codes/MILL']));
addpath(genpath([pwd '/codes/GeneratebballTacticsFeatures']));

param.kernel = 5:-1:-5;
param.cost = 10:-1:-5;
param.negativeWeight = 0;
param.iter = 1; %default is 1

BatchAllTacticOnce(param,'cross_validate','RBF','inst_MI','Training');

% BenchResult(param,'cross_validate','RBF','inst_MI');

% BenchResult(param,'cross_validate','RBF','bag_MI');

% BenchResult(param,'cross_validate','linear','inst_MI');

% BenchResult(param,'cross_validate','linear','bag_MI');

rmpath(genpath([pwd '/codes/MILL']));
rmpath(genpath([pwd '/codes/GeneratebballTacticsFeatures']));

%rmdir('tmp','s');