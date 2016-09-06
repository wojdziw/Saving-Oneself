%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONVERT_TO_COLUMN(matrix)
%
% Converts a 3x3 matrix to a column
%
% Input:  Large 3D Matrix 
% 
% Outputs: Single column vector of the 3D matrix in form:
% [Row1;Row2;Row3;etc]
%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function vector = matrix_to_column(matrix)

    first_d = size(matrix, 1);
    second_d = size(matrix, 2);
    third_d = size(matrix, 3);
    
    vector = zeros(first_d*second_d*third_d,1);
    
    for layer_index = 1:third_d
        layer = matrix(:,:,layer_index);
        layer_transposed = transpose(layer);
        vector(((layer_index-1)*first_d*second_d)+1:layer_index*first_d*second_d) = layer_transposed(:);
    end