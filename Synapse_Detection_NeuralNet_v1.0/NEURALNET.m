%Script for training TreeBagger
%Stores features of synapses generated from trainer1 and assigns these
%features as 1's in Feat. Also stores features of things that have been
%extracted in processing but are not synapses via trainer0 and assigns
%these as 0's in Feat. Finally the trained forest is saved as
%'trained_ensemble' which can be invoked in a predictor

%Initialise temp feature storage
NewTrueFeat = [];
NewFalseFeat = [];
addpath('train')
truthfile = tif_to_matrix('/train/synapse.tif');
imagefile = tif_to_matrix('/train/image.tif');
%Generate all the features that should give 1's
display('Training 1');
for i =  1:125
FeatureList = trainer1(i,truthfile,imagefile);
NewTrueFeat = [NewTrueFeat;FeatureList];
i
end
%Assign as 1's
result = zeros(size(NewTrueFeat,1),2);
result(:,1) = 1;

%Generate all the feature that should give 0's
display('Training 0');
for i = 1:1
FeatureList = trainer0(i,truthfile,imagefile);
NewFalseFeat = [NewFalseFeat;FeatureList];
i
end
%Assign as 0's
result0 = zeros(size(NewFalseFeat,1),2);
result0(:,2) = 1;
result = [result;result0];

%Place in one big feature matrix
NewFeat = [NewTrueFeat;NewFalseFeat];

NewFeat = transpose(NewFeat);
result = transpose(result);

net = patternnet(1000); 
net = train(net,NewFeat,result);

save('trained_net.mat', 'net');

