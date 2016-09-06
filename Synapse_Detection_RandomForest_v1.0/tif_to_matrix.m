%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TIF_TO_MATRIX(original_file)
%
% Converts a tif image into a MATLAB matrix
%
% Inputs:   Image tif stack    
% 
% Outputs:  3D Matrix containing entire stack data
%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function original_image = tif_to_matrix(original_file)
                                    
image_info = imfinfo(original_file);
image_width = image_info(1).Width;
image_height = image_info(1).Height;
image_depth = length(image_info);
original_image = zeros(image_height,image_width,image_depth,'uint8');
tif_file = Tiff(original_file, 'r');
for i = 1:image_depth
   tif_file.setDirectory(i);
   original_image(:,:,i) = tif_file.read();
end
tif_file.close();