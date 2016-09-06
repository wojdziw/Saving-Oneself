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

function synapse_forest_generation(original_file, synapses_file)

original_features = feature_matrix(original_file, synapses_file);

% Convert the synapse file into a column vector
synapse_matrix = tif_to_matrix(synapses_file);
synapse_matrix_avg = BlockMean(synapse_matrix,4,4);
synapse_vector = matrix_to_column(synapse_matrix_avg);

% THIS BETTER NOT BE RUN LOCALLY
% Creates 50 decision trees that are trained to recognize synapses
rng(1); % For reproducibility
BaggedEnsemble = TreeBagger(50,original_features,synapse_vector,'OOBPred','On');

save('trained_ensemble.mat', 'BaggedEnsemble','-v7.3');
