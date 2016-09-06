

% function result = Tester(layer,imagefile,truthfile)
%Tester
warning off
FeatureList=[];
layer=50;
rmpath('train')
addpath('validate')
truthfile = tif_to_matrix('/validate/synapse.tif');
imagefile = tif_to_matrix('/validate/image.tif');
%Get posible synapses from filters
ImPossSynapse =  SecondStage(layer);
%Load the Original image
ImOrigCurrent = imagefile(:,:,layer);
if layer-1 >0
    ImOrigPrev = imagefile(:,:,layer-1);
else
    ImOrigPrev = imagefile(:,:,layer);
end

if layer+1 >125
    ImOrigNext = imagefile(:,:,layer+1);
else
    ImOrigNext = imagefile(:,:,layer);
end


%Get windows for every pixel 71x71 
[Locationsrange,Locations,Windows] = windower(ImPossSynapse,ImOrigCurrent,ImOrigPrev,ImOrigNext);
%Get the most likely synapse area 

% PossSynStats = getPossSynStats(Windows);
[VesNum, TotalVes] = getPossVesStats3D(Windows);
% 
% GreyStats =    getGreyScaleStats(Windows);
 

FeatureList(:,1) = cell2mat(VesNum.Current(1:end))';
FeatureList(:,2) = cell2mat(VesNum.Prev(1:end))';
FeatureList(:,3) = cell2mat(VesNum.Next(1:end))';
FeatureList(:,4) = cell2mat(TotalVes(1:end))';

load('trained_ensemble.mat'); % gets save from TREEBAG
if size(FeatureList,1)>0
prediction = predict(BaggedEnsemble, FeatureList);

%Now begin window stitching 
%first get the window top left corner for truths

Predictor = str2double(prediction);
Rownum = find(Predictor);
result = im2bw(zeros(1024,1024));


%now stick all those windows into a logical image 

for i = 1:size(Rownum)
    pixel = sub2ind(size(ImOrigCurrent),Locations(Rownum(i),1),Locations(Rownum(i),2));
    result(pixel) = 1;
end
else
    result = im2bw(zeros(size(ImOrigCurrent)));
end

