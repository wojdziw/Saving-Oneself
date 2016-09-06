%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% generate_stats(synapses_file)
%
% Produces a set of statistics on the synapses
%
% Inputs:   something     
% 
% Outputs:  none, just saving stuff to a file
%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function generate_stats(synapses_file)

truthfile = tif_to_matrix(synapses_file);

MaxArea = 0; MinArea = 1000000;
MaxECC = 0; MinECC = 1000000;
MaxPer = 0; MinPer = 1000000;
MaxDiam = 0; MinDiam = 1000000;
MaxMajor = 0; MinMajor = 1000000;
MaxMinor = 0; MinMinor = 1000000;
MaxConv = 0; MinConv = 1000000;
MaxSolid = 0; MinSolid = 1000000;
MaxExtent = 0; MinExtent = 1000000;

for layer = 1:size(truthfile,3)

    % Load our truth data of synapses for comparison
    ImSynapse = im2bw(truthfile(:,:,layer));
    
    cc = bwconncomp(~ImSynapse); 
    stats = regionprops(cc, 'Area'); 
    idx = find([stats.Area] > 80); %(only keep if area greater than 80)
    ImSynapse = ~ismember(labelmatrix(cc), idx); 

    %Now to generate some stats for our identification data
    %Assigns a ton of variables
    %It gets the data from the truth stack and just looks at the min /max
    %values, we can then use that to compare to OUR possible synapses
    trueconnect = bwconncomp(ImSynapse); 
    truthstats = regionprops(trueconnect, 'Area','Eccentricity','orientation','Perimeter','EquivDiameter','MajorAxisLength', 'MinorAxisLength', 'ConvexArea', 'Solidity', 'Extent'); 
    MaxArea = max([MaxArea truthstats(:).Area]); MinArea= min([MinArea truthstats(:).Area]); 
    MaxECC = max([MaxECC truthstats(:).Eccentricity]); MinECC = min([MinECC truthstats(:).Eccentricity]);
    MaxPer = max([MaxPer truthstats(:).Perimeter]); MinPer= min([MinPer truthstats(:).Perimeter]); 
    MaxDiam = max([MaxDiam truthstats(:).EquivDiameter]); MinDiam= min([MinDiam truthstats(:).EquivDiameter]); 
    MaxMajor = max([MaxMajor truthstats(:).MajorAxisLength]); MinMajor= min([MinMajor truthstats(:).MajorAxisLength]); 
    MaxMinor = max([MaxMinor truthstats(:).MinorAxisLength]); MinMinor= min([MinMinor truthstats(:).MinorAxisLength]); 
    MaxConv = max([MaxConv truthstats(:).ConvexArea]); MinConv= min([MinConv truthstats(:).ConvexArea]); 
    MaxSolid = max([MaxSolid truthstats(:).Solidity]); MinSolid= min([MinSolid truthstats(:).Solidity]); 
    MaxExtent = max([MaxExtent truthstats(:).Extent]); MinExtent= min([MinExtent truthstats(:).Extent]); 

end

save('synapse_stats.mat', 'MaxArea', 'MinArea', 'MaxECC', 'MinECC', 'MaxPer', 'MinPer', 'MaxDiam', 'MinDiam', 'MaxMajor', 'MinMajor', 'MaxMinor', 'MinMinor', 'MaxConv', 'MinConv', 'MaxSolid', 'MinSolid', 'MaxExtent', 'MinExtent');

end

