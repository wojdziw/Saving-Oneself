
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SYNAPSE_VECTOR_NEW(original_file)
%
% Applies various transformation to the original image to obtain a feature
% matrix for random forests
%
% Inputs:   None    
% 
% Outputs:  Matrix of vectors of features
%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function output_matrix = synapse_vector_new(original_file, synapse_file)

% Convert the tif into a matrix
original_image = tif_to_matrix(original_file);
synapse_image = tif_to_matrix(synapse_file);

for layer = 1:size(original_image,3)
    
    % Load our tiff stack of original training images to be processed
    ImOrig = original_image(:,:,layer);
    ImSynap = synapse_image(:,:,layer);
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

    output_matrix = zeros(size(centrepx,1), 1);
    
    for i = 1:size(centrepx,1)
        synapse_region = ImSynap(centrepxrange(i,1):centrepxrange(i,2),centrepxrange(i,3):centrepxrange(i,4));
        output_matrix((layer-1)*size(centrepx,1)+i) = ismember(255, synapse_region);   
    end

    disp(layer)
end