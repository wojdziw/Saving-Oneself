sfunction [Locationsrange,Locations,Windows] = windower(ImSynapse, ImOrig, ImOrigPrev, ImOrigNext)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%place 70x70 window around each px
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

winsize = 70;

[Locations(:,1),Locations(:,2)] = find(ImSynapse);

Locationsrange = zeros(size(Locations,1),2);
%Determine the starting point for windows
for i = 1:size(Locations,1)
   if Locations(i,1)-winsize/2 <=0
       Locationsrange(i,1) = 1;
   elseif Locations(i,1)+winsize/2 >=1024
       Locationsrange(i,1) = 1024-winsize;      
   else Locationsrange(i,1) = Locations(i,1)-winsize/2;
   end

   
   if Locations(i,2)-winsize/2 <=0
       Locationsrange(i,2) = 1;
   elseif Locations(i,2)+winsize/2 >=1024
       Locationsrange(i,2) = 1024-winsize;  
   else Locationsrange(i,2) = Locations(i,2)-winsize/2;
   end
end

for i= 1:size(Locations,1);
%Create windows from the original image for finding features
Windows.Current{i} = ImOrig(Locationsrange(i,1):Locationsrange(i,1)+winsize ,Locationsrange(i,2):Locationsrange(i,2)+winsize);
Windows.Prev{i} = ImOrigPrev(Locationsrange(i,1):Locationsrange(i,1)+winsize ,Locationsrange(i,2):Locationsrange(i,2)+winsize);
Windows.Next{i} = ImOrigNext(Locationsrange(i,1):Locationsrange(i,1)+winsize ,Locationsrange(i,2):Locationsrange(i,2)+winsize);
end

end