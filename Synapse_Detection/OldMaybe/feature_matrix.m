
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FEATURE_MATRIX(original_file)
%
% Applies various transformation to the original image to obtain a feature
% matrix for random forests
%
% Inputs:   None    
% 
% Outputs:  Matrix of vectors of features
%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function output_matrix = feature_matrix(original_file)

load synapse_stats.mat;

% Convert the tif into a matrix
original_image = tif_to_matrix(original_file);

for layer = 1:1 %size(original_image,3)
    
% Load our tiff stack of original training images to be processed
ImOrig = original_image(:,:,layer);
% Use adaptive histogram equalisation to increase contrast of the image
ImCont = adapthisteq(ImOrig);
% Binarise equalised image using a 22% threshold (only keep top 22%)
ImBW = im2bw(ImCont,0.22);

%Basic pre processing done now weed out (delete) tiny areas
cc = bwconncomp(~ImBW); 
stats = regionprops(cc, 'Area'); 
idx = find([stats.Area] > 80); %(only keep if area greater than 80)
ImBW = ~ismember(labelmatrix(cc), idx); 

%%%%%Display what has been done so far%%%%%%%
%my centroids, the centres of connected areas
mcon  = bwconncomp(~ImBW); 
mcent = regionprops(~ImBW,'centroid');
mcentroids = cat(1, mcent.Centroid);
%plot showing centroids, mine blue, truth red, JUST FOR VISUALISATION
imshow(ImBW)
hold on
plot(mcentroids(:,1),mcentroids(:,2), 'b*')
hold off


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%placing 74x74 window allowing for cutoff around my centroids as seen above
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

centrepx = round(mcentroids); %make centres into integers

%Take the centres of each area and make a window around them 37 away in x
%and y, if it hits the edge of the image that's okay, set it as a boundry
%along 0 a.k.a a smaller window 
centrepxrange = centrepx;
for i = 1:size(centrepx,1)
   if centrepx(i,1)-37 <=0
       centrepxrange(i,1) = 1;
   else centrepxrange(i,1) = centrepx(i,1)-37;
   end
   if centrepx(i,1)+37 > size(ImCont,2)
       centrepxrange(i,2) = size(ImCont,2);
       else centrepxrange(i,2) = centrepx(i,1)+37;
   end
   
   if centrepx(i,2)-37 <=0
       centrepxrange(i,3) = 1;
   else centrepxrange(i,3) = centrepx(i,2)-37;
   end
   if centrepx(i,2)+37 > size(ImCont,2)
       centrepxrange(i,4) = size(ImCont,2);
       else centrepxrange(i,4) = centrepx(i,2)+37;
   end
end
       
%store each window in a structure so that we can access it later
for i = 1:size(centrepx,1)
ImContWindow{i} = im2bw(adapthisteq(ImCont(centrepxrange(i,1):centrepxrange(i,2),centrepxrange(i,3):centrepxrange(i,4))),0.22);
end

%For example one generated window would be this one, which gets cut off by the image edge:
% figure(2)
% imshow(ImContWindow{3})
% title('An Example of a window')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now test over each window asking if true, i.e is it a synapse? based on
%above
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


errormargin = 0.4;         %Our Synapses will be much smaller than the truths so allow for error

ImBWArea = zeros(size(ImBW));
for i=1:size(centrepx,1)
    myconnect = bwconncomp(~ImContWindow{i});
    mystats = regionprops(myconnect, 'Area');
    if(max([mystats(:).Area])<=(MaxArea*errormargin)&& max([mystats(:).Area])>=(MinArea/errormargin));
        %max([mystats(:).Area])
        ImBWArea(mcon.PixelIdxList{1,i}(:,1)) = 1;
    else 
        %max([mystats(:).Area])
        ImBWArea(mcon.PixelIdxList{1,i}(:,1)) = 0;
    end
end
ImBWAreastack(:,:,layer) = ImBWArea;

ImBWEccentricity = zeros(size(ImBW));
for i=1:size(centrepx,1)
    myconnect = bwconncomp(~ImContWindow{i}); 
    mystats = regionprops(myconnect, 'Eccentricity');
    if(max([mystats(:).Eccentricity])<=(MaxECC*errormargin)&& max([mystats(:).Eccentricity])>=(MinECC/errormargin));
        %max([mystats(:).Eccentricity])
        ImBWEccentricity(mcon.PixelIdxList{1,i}(:,1)) = 1;
    else 
        %max([mystats(:).Eccentricity])
        ImBWEccentricity(mcon.PixelIdxList{1,i}(:,1)) = 0;
    end
end
ImBWEccentricitystack(:,:,layer) = ImBWEccentricity;

ImBWPer = zeros(size(ImBW));
for i=1:size(centrepx,1)
    myconnect = bwconncomp(~ImContWindow{i}); 
    mystats = regionprops(myconnect, 'Perimeter');
    if(max([mystats(:).Perimeter])<=(MaxPer*errormargin)&& max([mystats(:).Perimeter])>=(MinPer/errormargin));
        %max([mystats(:).Perimeter])
        ImBWPer(mcon.PixelIdxList{1,i}(:,1)) = 1;
    else 
        %max([mystats(:).Perimeter])
        ImBWPer(mcon.PixelIdxList{1,i}(:,1)) = 0;
    end
end
ImBWPerstack(:,:,layer) = ImBWPer;

ImBWDiam = zeros(size(ImBW));
for i=1:size(centrepx,1)
    myconnect = bwconncomp(~ImContWindow{i}); 
    mystats = regionprops(myconnect, 'EquivDiameter');
    if(max([mystats(:).EquivDiameter])<=(MaxDiam*errormargin)&& max([mystats(:).EquivDiameter])>=(MinDiam/errormargin));
        %max([mystats(:).EquivDiameter])
        ImBWDiam(mcon.PixelIdxList{1,i}(:,1)) = 1;
    else 
        %max([mystats(:).EquivDiameter])
        ImBWDiam(mcon.PixelIdxList{1,i}(:,1)) = 0;
    end
end
ImBWDiamstack(:,:,layer) = ImBWDiam;

ImBWMajor = zeros(size(ImBW));
for i=1:size(centrepx,1)
    myconnect = bwconncomp(~ImContWindow{i}); 
    mystats = regionprops(myconnect, 'MajorAxisLength');
    if(max([mystats(:).MajorAxisLength])<=(MaxMajor*errormargin)&& max([mystats(:).MajorAxisLength])>=(MinMajor/errormargin));
        %max([mystats(:).MajorAxisLength])
        ImBWMajor(mcon.PixelIdxList{1,i}(:,1)) = 1;
    else 
        %max([mystats(:).MajorAxisLength])
        ImBWMajor(mcon.PixelIdxList{1,i}(:,1)) = 0;
    end
end
ImBWMajorstack(:,:,layer) = ImBWMajor;


ImBWMinor = zeros(size(ImBW));
for i=1:size(centrepx,1)
    myconnect = bwconncomp(~ImContWindow{i}); 
    mystats = regionprops(myconnect, 'MinorAxisLength');
    if(max([mystats(:).MinorAxisLength])<=(MaxMinor*errormargin)&& max([mystats(:).MinorAxisLength])>=(MinMinor/errormargin));
        %max([mystats(:).MinorAxisLength])
        ImBWMinor(mcon.PixelIdxList{1,i}(:,1)) = 1;
    else 
        %max([mystats(:).MinorAxisLength])
        ImBWMinor(mcon.PixelIdxList{1,i}(:,1)) = 0;
    end
end
ImBWMinorstack(:,:,layer) = ImBWMinor;



ImBWConvex = zeros(size(ImBW));
for i=1:size(centrepx,1)
    myconnect = bwconncomp(~ImContWindow{i}); 
    mystats = regionprops(myconnect, 'ConvexArea');
    if(max([mystats(:).ConvexArea])<=(MaxConv*errormargin)&& max([mystats(:).ConvexArea])>=(MinConv/errormargin));
        %max([mystats(:).ConvexArea])
        ImBWConvex(mcon.PixelIdxList{1,i}(:,1)) = 1;
    else 
        %max([mystats(:).ConvexArea])
        ImBWConvex(mcon.PixelIdxList{1,i}(:,1)) = 0;
    end
end
ImBWConvexstack(:,:,layer) = ImBWConvex;

disp(layer)
end

% Plotting

figure
subplot(3,3,1)
imshow(ImBWArea)
title('ImBWArea')
subplot(3,3,2)
imshow(ImBWEccentricity)
title('ImBWEccentricity')
subplot(3,3,3)
imshow(ImBWPer)
title('ImBWPer')
subplot(3,3,4)
imshow(ImBWDiam)
title('ImBWDiam')
subplot(3,3,5)
imshow(ImBWMajor)
title('ImBWMajor')
subplot(3,3,6)
imshow(ImBWMinor)
title('ImBWMinor')
subplot(3,3,7)
imshow(ImBWConvex)
title('ImBWConvex')

ImBWConvexstack_avg = BlockMean(ImBWConvexstack,4,4);
ImBWMinorstack_avg = BlockMean(ImBWMinorstack,4,4);
ImBWMajorstack_avg = BlockMean(ImBWMajorstack,4,4);
ImBWDiamstack_avg = BlockMean(ImBWDiamstack,4,4);
ImBWPerstack_avg = BlockMean(ImBWPerstack,4,4);
ImBWEccentricitystack_avg = BlockMean(ImBWEccentricitystack,4,4);
ImBWAreastac_avg = BlockMean(ImBWAreastack,4,4);

% Converting into a column vector that can be used in random forests
ImBWConvexstack_feature = matrix_to_column(ImBWConvexstack_avg);
ImBWMinorstack_feature = matrix_to_column(ImBWMinorstack_avg);
ImBWMajorstack_feature = matrix_to_column(ImBWMajorstack_avg);
ImBWDiamstack_feature = matrix_to_column(ImBWDiamstack_avg);
ImBWPerstack_feature = matrix_to_column(ImBWPerstack_avg);
ImBWEccentricitystack_feature = matrix_to_column(ImBWEccentricitystack_avg);
ImBWAreastack_feature = matrix_to_column(ImBWAreastac_avg);

output_matrix = [ImBWConvexstack_feature ImBWMinorstack_feature ImBWMajorstack_feature ImBWDiamstack_feature ImBWPerstack_feature ImBWEccentricitystack_feature ImBWAreastack_feature];
