function [GreyMean, GreyStd, GreyMin, GreyMax, GreyRange] = greydetect(WindowNum)
filename = sprintf('images/%d synapse.tif',WindowNum);
filename2 = sprintf('images/%d truth.tif',WindowNum);

syn = imread(filename);
tru = imread(filename2);

x = find(tru);
GreyVals = syn(x);
GreyMean = mean(GreyVals);
GreyStd = std(im2double(GreyVals));
GreyMin = min(GreyVals);
GreyMax = max(GreyVals);
GreyRange = GreyMax-GreyMin;

end