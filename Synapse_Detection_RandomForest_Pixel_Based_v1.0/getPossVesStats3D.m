function [Vesnum,TotalVes] = getPossVesStats3D(Windows)

for i = 1:size(Windows.Current,2)
    
if (isempty(imfindcircles(Windows.Current{i},[1 5],'ObjectPolarity','dark', 'sensitivity', 0.92)))
    Centers1 = [];
else
Centers1= imfindcircles(Windows.Current{i},[1 5],'ObjectPolarity','dark', 'sensitivity', 0.92);
end
if (isempty(imfindcircles(Windows.Prev{i},[1 5],'ObjectPolarity','dark', 'sensitivity', 0.92)))
    Centers2 = [];
else
Centers2 = imfindcircles(Windows.Prev{i},[1 5],'ObjectPolarity','dark', 'sensitivity', 0.92);
end
if (isempty(imfindcircles(Windows.Next{i},[1 5],'ObjectPolarity','dark', 'sensitivity', 0.92)))
    Centers3 = [];
else
Centers3= imfindcircles(Windows.Next{i},[1 5],'ObjectPolarity','dark', 'sensitivity', 0.92);
end


%Determines wither there are more synapse on one side of the window or
%another, like it should be for a synapse
Vesnum.Current{i} = size(Centers1,1);
Vesnum.Prev{i} = size(Centers2,1);
Vesnum.Next{i} = size(Centers3,1);
TotalVes{i} = Vesnum.Current{i}+Vesnum.Prev{i}+Vesnum.Next{i};
end
