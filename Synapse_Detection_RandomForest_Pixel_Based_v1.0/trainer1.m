
function FeatureList = trainer1(layer,truthfile,imagefile)

warning off
FeatureList=[];
%Get posible synapses from filters
ImPossSynapse =   truthfile(:,:,layer); % SecondStage(layer);
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
end

