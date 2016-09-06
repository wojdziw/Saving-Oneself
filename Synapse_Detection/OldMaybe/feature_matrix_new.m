
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FEATURE_MATRIX_NEW(original_file)
%
% Applies various transformation to the original image to obtain a feature
% matrix for random forests
%
% Inputs:   None    
% 
% Outputs:  Matrix of vectors of features
%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function output_matrix = feature_matrix_new(original_file)

% Convert the tif into a matrix
original_image = tif_to_matrix(original_file);

for layer = 1:size(original_image,3)
    
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

    no_features = 7;
    output_matrix = zeros(size(centrepx,1), no_features*2);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Now test over each window asking if true, i.e is it a synapse? based on
    %above
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    errormargin = 0.4;         %Our Synapses will be much smaller than the truths so allow for error

    for i=1:size(centrepx,1)
        myconnect = bwconncomp(~ImContWindow{i});
        mystats = regionprops(myconnect, 'Area');

        output_matrix((layer-1)*size(centrepx,1)+i, 1) = max([mystats(:).Area]);
        output_matrix((layer-1)*size(centrepx,1)+i, 2) = min([mystats(:).Area]);
    end

    for i=1:size(centrepx,1)
        myconnect = bwconncomp(~ImContWindow{i}); 
        mystats = regionprops(myconnect, 'Eccentricity');

        output_matrix((layer-1)*size(centrepx,1)+i, 3) = max([mystats(:).Eccentricity]);
        output_matrix((layer-1)*size(centrepx,1)+i, 4) = min([mystats(:).Eccentricity]);
    end

    for i=1:size(centrepx,1)
        myconnect = bwconncomp(~ImContWindow{i}); 
        mystats = regionprops(myconnect, 'Perimeter');

        output_matrix((layer-1)*size(centrepx,1)+i, 5) = max([mystats(:).Perimeter]);
        output_matrix((layer-1)*size(centrepx,1)+i, 6) = min([mystats(:).Perimeter]);
    end

    for i=1:size(centrepx,1)
        myconnect = bwconncomp(~ImContWindow{i}); 
        mystats = regionprops(myconnect, 'EquivDiameter');

        output_matrix((layer-1)*size(centrepx,1)+i, 7) = max([mystats(:).EquivDiameter]);
        output_matrix((layer-1)*size(centrepx,1)+i, 8) = min([mystats(:).EquivDiameter]);
    end

    for i=1:size(centrepx,1)
        myconnect = bwconncomp(~ImContWindow{i}); 
        mystats = regionprops(myconnect, 'MajorAxisLength');

        output_matrix((layer-1)*size(centrepx,1)+i, 9) = max([mystats(:).MajorAxisLength]);
        output_matrix((layer-1)*size(centrepx,1)+i, 10) = min([mystats(:).MajorAxisLength]);
    end

    for i=1:size(centrepx,1)
        myconnect = bwconncomp(~ImContWindow{i}); 
        mystats = regionprops(myconnect, 'MinorAxisLength');

        output_matrix((layer-1)*size(centrepx,1)+i, 11) = max([mystats(:).MinorAxisLength]);
        output_matrix((layer-1)*size(centrepx,1)+i, 12) = min([mystats(:).MinorAxisLength]);
    end

    for i=1:size(centrepx,1)
        myconnect = bwconncomp(~ImContWindow{i}); 
        mystats = regionprops(myconnect, 'ConvexArea');

        output_matrix((layer-1)*size(centrepx,1)+i, 13) = max([mystats(:).ConvexArea]);
        output_matrix((layer-1)*size(centrepx,1)+i, 14) = min([mystats(:).ConvexArea]);
    end

    disp(layer)
end