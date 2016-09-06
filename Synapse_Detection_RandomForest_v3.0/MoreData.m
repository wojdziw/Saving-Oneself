%More Training Data
addpath('Copy_of_train')
clear
image = tif_to_matrix('image.tif');
% image = tif_to_matrix('synapse.tif');
image_rot_stack = image;
for i = 1:22:359
    for j = 1:size(image,3)
    imagenew(:,:,j) = imrotate(image(:,:,j),i,'bilinear','crop');
    end
   image_rot_stack = cat(3,image_rot_stack,imagenew);     
end