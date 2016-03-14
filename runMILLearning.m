clear all

addpath(genpath([pwd '/codes/MILL']));


BenchResult('cross_validate','RBF','inst_MI');

BenchResult('cross_validate','RBF','bag_MI');

rmpath(genpath([pwd '/codes/MILL']));