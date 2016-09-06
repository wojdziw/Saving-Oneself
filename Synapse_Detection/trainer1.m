
function FeatureList = trainer1(layer, angle)
%trainer1 A function to generate True Synapse data for use in TreeBagger
%   Finds and windows lots of objects which we know from truth files are
%   synapses

%Initialise as empty to prevent errors
FeatureList=[];
CurrentGen = SecondStage(layer,'train');
%Load data
truthfile = tif_to_matrix('/train/synapse.tif');
imagefile = tif_to_matrix('/train/image.tif');
ImOrig = imagefile(:,:,layer);

%Only include my prediction which are definitely true
ImSynapse = im2bw(im2bw(truthfile(:,:,layer)).*CurrentGen);

% Rotate the images by the desired angle
ImOrig = imrotate(ImOrig, angle);
ImSynapse = imrotate(ImSynapse, angle);
CurrentGen = imrotate(CurrentGen, angle);

imWidth = size(ImOrig, 2);
imHeight = size(ImOrig, 1);

%Get centroids
tcent = regionprops(ImSynapse,'centroid');
tcentroids = round(cat(1, tcent.Centroid));

%%%%%%%%%%%%%%%%%%%%%%%%%%
%place 70x70 window around
%%%%%%%%%%%%%%%%%%%%%%%%%%

winsize = 70;

Locations = tcentroids;
Locationsrange = zeros(size(Locations,1),2);
%Determine the starting point for windows
for i = 1:size(Locations,1)
   if Locations(i,1)-winsize/2 <=0
       Locationsrange(i,1) = 1;
   elseif Locations(i,1)+winsize/2 >=imWidth
       Locationsrange(i,1) = imWidth-winsize;      
   else Locationsrange(i,1) = Locations(i,1)-winsize/2;
   end

   
   if Locations(i,2)-winsize/2 <=0
       Locationsrange(i,2) = 1;
   elseif Locations(i,2)+winsize/2 >=imHeight
       Locationsrange(i,2) = imHeight-winsize;  
   else Locationsrange(i,2) = Locations(i,2)-winsize/2;
   end
end

%Add some contrast
ImOrig = histeq(ImOrig);

%Begin the windowing, a.k.a sectioning  into synapses within windows
%Whilst we're at it we generate some stats from the truth data and stick it
%in a structure for later

WindowNum = size(Locations,1);
for i= 1:WindowNum
TruthWindow = imcrop(ImSynapse,[Locationsrange(i,1),Locationsrange(i,2),winsize,winsize]);
trueconnect = bwconncomp(TruthWindow);
truthstats{i} = regionprops(trueconnect, 'Area','Eccentricity','Perimeter',...
'EquivDiameter','MajorAxisLength', 'MinorAxisLength', 'ConvexArea', 'Solidity', 'Extent'); 

%Create the same windows from the original image for finding extra features
Imagewindow = imcrop(ImOrig,[Locationsrange(i,1),Locationsrange(i,2),winsize,winsize]);
filename = sprintf('images/%d synapse.tif',i);
filename2 = sprintf('images/%d truth.tif',i);
imwrite(Imagewindow,filename)
imwrite(TruthWindow,filename2)
end


%Add new features here make sure they go into the next column
%Also make sure traner0 and Tester are exactly the same!!!
%Preferably create a function, as an example see grey detect
%It's your choice whether you want to use stats from the truth window a.k.a
%black n white or the original image window a.k.a grey. Both will give
%working features providing you only put a !single! value into the column 
%per window.

for j = 1:WindowNum
    [vesnum, weighted] = vesdetect(j,winsize);
FeatureList(j,1) = vesnum;
[mean,stdev] = greydetect(j);
FeatureList(j,2) = mean;
FeatureList(j,3) = stdev;
FeatureList(j,4) = truthstats{j}.Area;
FeatureList(j,5) = truthstats{j}.Eccentricity;
FeatureList(j,6) = truthstats{j}.Perimeter;
FeatureList(j,7) = truthstats{j}.EquivDiameter;
FeatureList(j,8) = truthstats{j}.MajorAxisLength;
FeatureList(j,9) = truthstats{j}.MinorAxisLength;
FeatureList(j,10) = truthstats{j}.ConvexArea;
FeatureList(j,11) = truthstats{j}.Solidity;
FeatureList(j,12) = truthstats{j}.Extent;
FeatureList(j,13) = weighted;
end
end

