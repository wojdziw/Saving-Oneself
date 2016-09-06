%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% synapse_prediction(original_file, synapse_matrix, to_predict)
%
% Produces a bagged ensemble of random trees and saves them into a file
%
% Inputs:   something     
% 
% Outputs:  something
%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function synapse_forest_generation_new(original_file, synapses_file)

original_features = feature_matrix_new(original_file);

% Convert the synapse file into a column vector
synapse_vector = synapse_vector_new(synapses_file);

% THIS BETTER NOT BE RUN LOCALLY
% Creates 50 decision trees that are trained to recognize synapses
rng(1); % For reproducibility
BaggedEnsemble = TreeBagger(50,original_features,synapse_vector,'OOBPred','On');

save('trained_ensemble.mat', 'BaggedEnsemble');