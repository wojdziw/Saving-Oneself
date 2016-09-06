
function WritetoTif(result)
%WritetoTif Function to generate tif file from a 3D matrix
%   If a previous result.tif exists then remove it. Call this function
%   within another script/function which produces a matrix 'result'

outputFileName = 'result.tif'
for K=1:length(result(1, 1, :))
   imwrite(result(:, :, K), outputFileName, 'WriteMode', 'append',  'Compression','none');
end
end