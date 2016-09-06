%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COLUMN_TO_TIF_NEW(original_file)
%
% Converts a MATLAB column into a tif image based on the original tiff
% dimensions
%
% Inputs: 3D Matrix containing entire stack data     
% 
% Outputs: Void, saving the tiff file
%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function column_to_tif_new(original_file, column)

% Creating a new tif with the same dimensions
copyfile(original_file, 'synapse_prediction.tif');

% Opening the new tif
new_tif = Tiff('synapse_prediction.tif', 'r+');
                                    
image_info = imfinfo('synapse_prediction.tif');
image_width = image_info(1).Width;
image_height = image_info(1).Height;
image_depth = length(image_info);

new_tif_matrix = zeros(image_height,image_width,image_depth,'uint8');

% Convert the tif into a matrix
original_image = tif_to_matrix(original_file);

column_index = 1;

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
    
    for i = 1:size(centrepx,1)
        new_tif_matrix(centrepxrange(i,1):centrepxrange(i,2),centrepxrange(i,3):centrepxrange(i,4),layer) = str2double(cell2mat(column(column_index)));
        column_index = column_index + 1;
    end

    disp(layer)
end

for i = 1:image_depth
   new_tif.setDirectory(i);
   new_tif.write(new_tif_matrix(:,:,i));
end

new_tif.close();
