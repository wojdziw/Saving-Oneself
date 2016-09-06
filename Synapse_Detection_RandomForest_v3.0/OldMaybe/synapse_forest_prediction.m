%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% synapse_prediction(original_file, synapse_matrix, to_predict)
%
% Produces a 3d matrix with the identified synapses
%
% Inputs:   something     
% 
% Outputs:  something
%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function synapse_forest_prediction(path_to_ensemble, to_predict)

% Convert the image for prediction into a feature matrix
to_predict_features = feature_matrix(to_predict);

% Load the bagged ensemble
load(path_to_ensemble);

% Simple prediction on the existing data
prediction = predict(BaggedEnsemble, to_predict_features);

% Convert the prediction into a tif
column_to_tif(to_predict, prediction);