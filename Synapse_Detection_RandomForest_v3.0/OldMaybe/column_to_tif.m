%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TIF_TO_MATRIX(original_file)
%
% Converts a MATLAB column into a tif image based on the original tiff
% dimensions
%
% Inputs: 3D Matrix containing entire stack data     
% 
% Outputs: Void, saving the tiff file
%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function column_to_tif(original_file, column)

% Creating a new tif with the same dimensions
copyfile(original_file, 'synapse_prediction.tif');

% Opening the new tif
new_tif = Tiff('synapse_prediction.tif', 'r+');
                                    
image_info = imfinfo('synapse_prediction.tif');
image_width = image_info(1).Width;
image_height = image_info(1).Height;
image_depth = length(image_info);

new_tif_matrix = zeros(image_height,image_width,image_depth,'uint8');

for i = 1:image_depth
    for j = 1:image_height
        for k = 1:image_width
            location = floor((k-1)/4) + 1 + floor((j-1)/4)*image_width/4 + (i-1)*image_height*image_width/16;
            new_tif_matrix(k, j, i) = str2double(cell2mat(column(location)));
        end
    end
end

for i = 1:image_depth
   new_tif.setDirectory(i);
   new_tif.write(new_tif_matrix(:,:,i));
end

new_tif.close();