function Stage1 = FirstStage(layer)
%FirstStage the first step of my filters which extract possible synapses
%   Uses histeq, thresholding, dilation, erosion and area removal to
%   extract multiple areas of possible synapses - definitely needs
%   improvement
%LoadData
imagefile = tif_to_matrix('image.tif');
%Get the current layer
imagelayer = imagefile(:,:,layer);

%Stage to detect membranes which are later removed
%5x5 Median filter to remove debris
imagelayer = medfilt2(imagelayer,[5,5]);

%First threshold stage
Filter1=imagelayer;
Filter1(imagelayer<=140)=0;
Filter1(imagelayer>141)=255;
Filter1=255-Filter1;
%Thin to a skeleton and then dilate again (Removes any blobs)
Filter1 = bwmorph(Filter1,'thin',inf);
Filter1 = bwmorph(Filter1,'dilate',1);

%Find locations on the original image
%which were found to be membranes in the step above and then remove them by
%setting to white
imagelayer(find(Filter1)) = 255;

%Do some extra filetering and thresholding to amplify poss synapses
imagelayer=histeq(imagelayer);
imagelayer(imagelayer<=46)=0;
imagelayer(imagelayer>46)=255;
imagelayer = medfilt2(imagelayer,[3,3]);
imagelayer = im2bw(imagelayer);
Stage1 =bwmorph(~imagelayer,'dilate',2);

% %Perform Steps to remove too large or too small areas 
% %Some erosion for seperation
% 
cc = bwconncomp(Stage1); 
stats = regionprops(cc, 'Area'); 
idx = find([stats.Area] > 190); %(only keep if area greater than 80)
Stage1 = ismember(labelmatrix(cc), idx); 


Filter2 = imagefile(:,:,layer);
Filter2(Filter2<=100)=0;
Filter2(Filter2>100)=255;
Filter2 = medfilt2(Filter2, [7 7]);
Filter2 = ~im2bw(Filter2);
Filter2 = imfill(Filter2, 'holes');
cc = bwconncomp(Filter2);
stats = regionprops(cc, 'Area');
idx = find([stats.Area] > 900); %(only keep if area greater than 80)
Filter2 = ismember(labelmatrix(cc), idx);
Filter2 = bwmorph(Filter2,'dilate',2);
Stage1 = Stage1 .* ~Filter2;



Stage1 =bwmorph(Stage1,'erode',4);
Stage1 = medfilt2(Stage1,[4,4]);

cc = bwconncomp(~Stage1); 
stats = regionprops(cc, 'Area'); 
idx = find([stats.Area] > 800); %(only keep if area greater than 80)
Stage1 = ~ismember(labelmatrix(cc), idx); 

end