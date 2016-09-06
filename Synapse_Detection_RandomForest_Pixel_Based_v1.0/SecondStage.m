
function Stage2 = SecondStage(layer)
%SecondStage the second step of my filters which extract possible synapses
%   Brings the process into 2D so calls Stage1 twice - could use
%   improvement but Stage1 is still too rough to bother using more layers
%   in 2D


%LoadData
imagefile = tif_to_matrix('image.tif');

%Get the current layers extraction and dilate
Stage2a = FirstStage(layer);
Stage2a =bwmorph(Stage2a,'dilate',1);
%Get the next layers extraction and dilate, unless we've reached the end in
%which case just re-use the current (does nothing in this case)
if layer == size(imagefile,3)
    layer=layer-1;
end
Stage2b = FirstStage(layer+1);
Stage2b =bwmorph(Stage2b,'dilate',1);
%Multiply together to give more likely synapses
Stage2 = im2bw(Stage2a+Stage2b);
Stage2 = bwmorph(Stage2,'dilate',2);


% imwrite(Stage2,'mine.tif');

end