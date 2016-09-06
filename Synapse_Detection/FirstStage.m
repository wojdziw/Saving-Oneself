function Stage1 = FirstStage(layer,direct)
%FirstStage the first step of my filters which extract possible synapses
%   Uses histeq, thresholding, dilation, erosion and area removal to
%   extract multiple areas of possible synapses - definitely needs
%   improvement

%LoadData
addpath(direct)
imagefile = tif_to_matrix('image.tif');

%Get the current layer
Layer = imagefile(:,:,layer);

%Stage to detect membranes which are later removed
%5x5 Median filter to remove debris
P1 = medfilt2(Layer,[5,5]);
%First threshold stage
P2=P1;
P2(P1<=140)=0;
P2(P1>141)=255;
P2=255-P2;
%Thin to a skeleton and then dilate again (Removes any blobs)
P3 = bwmorph(P2,'thin',inf);
P3 = bwmorph(P3,'dilate',1);

%Find locations on the original image
%which were found to be membranes in the step above and then remove them by
%setting to white
locs = find(P3);
P1(locs)=255;

%Do some extra filetering and thresholding to amplify poss synapses
P1=histeq(P1);
P1(P1<=46)=0;
P1(P1>46)=255;
P1 = medfilt2(P1,[3,3]);
P1 = im2bw(P1);
Stage1 =bwmorph(~P1,'dilate',2);

%Perform Steps to remove too large or too small areas 
%Some erosion for seperation

cc = bwconncomp(Stage1); 
stats = regionprops(cc, 'Area'); 
idx = find([stats.Area] > 190); %(only keep if area greater than 80)
Stage1 = ismember(labelmatrix(cc), idx); 


Stage1 =bwmorph(Stage1,'erode',4);
Stage1 = medfilt2(Stage1,[4,4]);

cc = bwconncomp(~Stage1); 
stats = regionprops(cc, 'Area'); 
idx = find([stats.Area] > 800); %(only keep if area greater than 80)
Stage1 = ~ismember(labelmatrix(cc), idx); 


cc = bwconncomp(Stage1); 
stats = regionprops(cc, 'Area'); 
idx = find([stats.Area] < 1400); %(only keep if area greater than 80)
Stage1 = ismember(labelmatrix(cc), idx); 


cc = bwconncomp(Stage1); 
stats = regionprops(cc, 'Area'); 
idx = find([stats.Area] > 80); %(only keep if area greater than 80)
Stage1 = ismember(labelmatrix(cc), idx); 

%Set the output to only include areas which were along the original
%membranes, this is possible because of the dilation step above.
%Essentially we know synapses ahve to be on a membrane boundry so it adds a
%layer of confirmation.

Stage1 = Stage1.*P3;


end







