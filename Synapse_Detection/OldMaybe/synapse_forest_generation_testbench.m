%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% synapse_forest_generation_testbench.m
%
% Generating the bagged ensemble of trees.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
close all

synapse_forest_generation('train/image.tif', 'train/synapse.tif');
