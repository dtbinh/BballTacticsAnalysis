
clear all
close all

addpath(genpath([pwd '/codes/GeneratebballTacticsFeatures']));

gMIL('codes/GeneratebballTacticsFeatures',{'ZoneSoftAssignDist'}); %{'ZoneVelocitySoftAssign'});


rmpath(genpath([pwd '/codes/GeneratebballTacticsFeatures']));