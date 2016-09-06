%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% synapse_forest_prediction_testbench.m
%
% Using the bagged ensemble generated in synapse_forest_generation to
% predict the synapses in another file.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
close all

synapse_forest_prediction('trained_ensemble.mat', 'validate/image.tif');