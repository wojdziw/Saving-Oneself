%Script for training TreeBagger
%Stores features of synapses generated from trainer1 and assigns these
%features as 1's in Feat. Also stores features of things that have been
%extracted in processing but are not synapses via trainer0 and assigns
%these as 0's in Feat. Finally the trained forest is saved as
%'trained_ensemble' which can be invoked in a predictor

%Initialise temp feature storage
NewTrueFeat = [];
NewFalseFeat = [];

%Generate all the features that should give 1's
for i = 1:1
    for angle = 0:45:360
        FeatureList = trainer1(i, angle);
        NewTrueFeat = [NewTrueFeat;FeatureList];
    end
i
end
%Assign as 1's
result = ones(size(NewTrueFeat,1),1);

%Generate all the feature that should give 0's
for i = 1:1
    for angle = 0:45:360
        FeatureList = trainer0(i, angle);
        NewFalseFeat = [NewTrueFeat;FeatureList];
    end
i
end
%Assign as 0's
result = [result;zeros(size(NewFalseFeat,1),1)];

%Place in one big feature matrix
NewFeat = [NewTrueFeat;NewFalseFeat];

%This is commented out so you don't accidently run it
%I've included a trained ensemble already so only 
%run this and uncomment when it needs retraining

%Train TreeBagger and save RF

display('Starting TreeBagger');
rng(1); % For reproducibility
BaggedEnsemble = TreeBagger(5000,NewFeat,result,'OOBPred','On');
display('Saving ensemble+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
save('trained_ensemble.mat', 'BaggedEnsemble');

