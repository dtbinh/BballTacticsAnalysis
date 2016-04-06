clear all

addpath(genpath([pwd '/codes/MILL']));

param.kernel = 3:-1:-3;
param.cost = 3:-1:-3;
param.negativeWeight = 0;

BenchResult(param,'cross_validate','RBF','inst_MI');

BenchResult(param,'cross_validate','RBF','bag_MI');

BenchResult(param,'cross_validate','linear','inst_MI');

BenchResult(param,'cross_validate','linear','bag_MI');

rmpath(genpath([pwd '/codes/MILL']));