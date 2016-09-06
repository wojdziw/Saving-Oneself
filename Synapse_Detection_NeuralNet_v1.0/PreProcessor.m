%This File Generates a pretty good set of edges that could be synapses
%Removes lots of crap leaving only relevant data
%produces mine.tif 


function PreProcessor(layer,direct)
warning off;
addpath(direct)
imagefile = tif_to_matrix('image.tif');
%truthfile = tif_to_matrix('synapse.tif');
%load synapse_stats.mat;

% Load our tiff stack of original training images to be processed
ImOrig = imagefile(:,:,layer);
%	

%% 
% Use adaptive histogram equalisation to increase contrast of the image
ImCont = histeq(ImOrig);
% Binarise equalised image using a 22% threshold (only keep top 22%)
ImBW = im2bw(ImCont,0.22);
%Basic pre processing done now weed out (delete) tiny areas
cc = bwconncomp(~ImBW); 
stats = regionprops(cc, 'Area'); 
idx = find([stats.Area] > 80); %(only keep if area greater than 80)
ImBW = ~ismember(labelmatrix(cc), idx); 

%truth centroids, the actual synapse connected area centres
% tcent = regionprops(ImSynapse,'centroid');
% tcentroids = cat(1, tcent.Centroid);
%plot showing centroids, mine blue, truth red, JUST FOR VISUALISATION
% imshow(ImBW)
% hold on
% plot(tcentroids(:,1),tcentroids(:,2), 'r-o')
% hold off

ImBW = double(ImBW);
sobel_edges=sobel33(ImBW);
smagnitude=(sobel_edges(:,:,1));
smagnitude=50*(uint8(smagnitude));
% figure(2)
% imshow(smagnitude);
% title ('Magnitude of ImOrig edges by Sobel');

[centers, radii] = imfindcircles(smagnitude,[1 30],'ObjectPolarity','dark', 'sensitivity', 0.97);
centersStrong = round(centers(1:end/2,:));
radiiStrong = round(radii(1:end/2));

% Create a logical image of a circle with specified
% diameter, center, and image size.
imageSizeX = 1024;
imageSizeY = 1024;
[columnsInImage rowsInImage] = meshgrid(1:imageSizeX, 1:imageSizeY);
% Next create the circle in the image.
centerX = centersStrong(:,1) ;
centerY = centersStrong(:,2) ; 
radius = radiiStrong;
circlePixels=zeros(1024);
for i =1:size(radiiStrong)
circlePixels = (rowsInImage - centerY(i)).^2 ...
    + (columnsInImage - centerX(i)).^2 <= radius(i).^2;
smagnitude = im2bw(smagnitude).*(1-circlePixels);
end

smagnitude(smagnitude>0) = 1;

% figure(3)
% imshow(smagnitude);
% title ('Magnitude of ImOrig edges by Sobel');

smagnitude = imfill(smagnitude);
h = fspecial('gaussian', [9 9], 0.5);
smagnitude = conv2(smagnitude, h, 'same');
smagnitude(smagnitude>0) = 1;
se = strel('diamond',2);
smagnitude = imerode(smagnitude,se);

% figure(4)
% imshow(smagnitude);
% hold on
% plot(tcentroids(:,1),tcentroids(:,2), 'r-o')
% hold off
% title ('Magnitude of ImOrig edges by Sobel');

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
thresh = im2uint8(ImOrig);
thresh(thresh<120)=0;
thresh(thresh>=120)=255;

ImVes = im2bw(thresh);
cc = bwconncomp(~ImVes); 
stats = regionprops(cc, 'Area'); 
idx = find([stats.Area] < 150); %(only keep if area greater than 80)
ImVes = ~ismember(labelmatrix(cc), idx); 
cc = bwconncomp(~ImVes); 
stats = regionprops(cc, 'Area'); 
idx = find([stats.Area] > 6);
ImVes = ~ismember(labelmatrix(cc), idx); 

max=900;
[centers, radii, metric] = imfindcircles(ImVes,[1 8],'ObjectPolarity','dark', 'sensitivity', 1);
centersStrong5 = centers(1:max,:);
radiiStrong5 = radii(1:max);
metricStrong5 = metric(1:max);


% figure(9)
% imshow(ImVes)
% viscircles(centersStrong5, radiiStrong5,'EdgeColor','b');
% hold on
% plot(tcentroids(:,1),tcentroids(:,2), 'r-o')
% hold off

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Take both images and do a 30x100 rectangle on any white point
%if in the vesicle image it has a value greater than X
%set that pixel true

PossSyn = smagnitude;

imageSizeX = 1024;
imageSizeY = 1024;
[columnsInImage rowsInImage] = meshgrid(1:imageSizeX, 1:imageSizeY);
% Next create the circle in the image.
centerX = centersStrong5(:,1) ;
centerY = centersStrong5(:,2) ; 
radius = radiiStrong5;
circlePixels=zeros(1024);
vesicleApprox=ones(1024);
for i =1:size(radiiStrong5)
circlePixels = (rowsInImage - centerY(i)).^2 ...
    + (columnsInImage - centerX(i)).^2 <= radius(i).^2;
% imshow(circlePixels)
vesicleApprox = (vesicleApprox).*(1-circlePixels);
end

[Locations(:,1),Locations(:,2)] = find(PossSyn);
Locationsrange = zeros(size(Locations,1),2);

for i = 1:size(Locations,1)
   if Locations(i,1)-125 <=0
       Locationsrange(i,1) = 1;
   else Locationsrange(i,1) = Locations(i,1)-25;
   end

   
   if Locations(i,2)-45 <=0
       Locationsrange(i,2) = 1;
   else Locationsrange(i,2) = Locations(i,2)-25;
   end
end



% figure(1)
% imshow(PossSyn);
% title('This is membranes');


for i=1:size(Locations,1)
    section = imcrop(vesicleApprox,[Locationsrange(i,2),Locationsrange(i,1),50,50]);   
    if sum(sum(1-section))>30
        PossSyn(Locations(i,1),Locations(i,2)) = 1;
         %True =  sum(sum(1-section))
         %pause;
         %imshow(section);
         %title('true')
    else
              
        PossSyn(Locations(i,1),Locations(i,2)) = 0;
        %False = sum(sum(1-section))
        %pause;
        %imshow(section)
    end
end



% figure(2)
% imshow(PossSyn)
% viscircles(centersStrong5, radiiStrong5,'EdgeColor','b');
% hold on
% plot(tcentroids(:,1),tcentroids(:,2), 'r-o')
% hold off
% title('this is poss synapses')
imwrite(PossSyn,'mine.tif');
%save('tcentroids.mat','tcentroids');
clear
end





