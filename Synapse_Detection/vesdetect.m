function [Vesnum,weighted] = vesdetect(WindowNum,winsize)
warning off;
filename = sprintf('images/%d synapse.tif',WindowNum);
ImVes = imread(filename);
[Centers, radii] = imfindcircles(ImVes,[1 5],'ObjectPolarity','dark', 'sensitivity', 0.92);
% centersStrong5 = Centers(:,:);
% radiiStrong5 = radii;

%Determines wither there are more synapse on one side of the window or
%another, like it should be for a synapse

Vesnum = size(Centers,1);
L = size(find(Centers(:,1)<38),1);
T = size(find(Centers(:,2)<38),1);
R = size(Centers(:,1),1)-L;
B = size(Centers(:,2),1)-T;

if max([L R T B]) - min([L R T B]) > 2
    weighted = 1;
else
    weighted = 0;
end
% figure
% imshow(ImVes)
% viscircles(centersStrong5, radiiStrong5,'EdgeColor','b');
end
