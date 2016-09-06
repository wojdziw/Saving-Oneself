close all
K=0
%%%%
% This generates synaptic images 

for layer=1  
    
addpath('train')
imagefile = tif_to_matrix('image.tif');
truthfile = tif_to_matrix('synapse.tif');
load synapse_stats.mat;

% Load our tiff stack of original training images to be processed
ImOrig = imagefile(:,:,layer);
ImSynapse = im2bw(truthfile(:,:,layer));

%% 
% % Use adaptive histogram equalisation to increase contrast of the image
% ImCont = adapthisteq(ImOrig);
% % Binarise equalised image using a 22% threshold (only keep top 22%)
% ImBW = im2bw(ImCont,0.22);
% %Basic pre processing done now weed out (delete) tiny areas
% cc = bwconncomp(~ImBW); 
% stats = regionprops(cc, 'Area'); 
% idx = find([stats.Area] > 80); %(only keep if area greater than 80)
% ImBW = ~ismember(labelmatrix(cc), idx); 

%truth centroids, the actual synapse connected area centres
tcent = regionprops(ImSynapse,'centroid');
tcentroids = cat(1, tcent.Centroid);
%plot showing centroids, mine blue, truth red, JUST FOR VISUALISATION
figure 
imshow(ImOrig)
 hold on
plot(tcentroids(:,1),tcentroids(:,2), 'r-o')

 
% find the central points of the synampse
tcentroids

% matlab indexing works by chosing the top left corner and then seting
% width and height

for k=1:length(tcentroids)
    tcentroids(k,1)=tcentroids(k,1)-200;
    tcentroids(k,2)= tcentroids(k,2)-200;
end

plot(tcentroids(:,1),tcentroids(:,2), 'b-o')
 hold off
%%Check to ensure no overlap

tcentroids

for n=1:length(tcentroids)
    if (tcentroids(n,1) < 0 ||  tcentroids(n,2) <0 || tcentroids(n,1) > 897 ||  tcentroids(n,2) >897)
        
       %still need to do the code for the edge synampse where the above
       %conditions are true
       %complier cant deal with any images not 128x128px
  
    else
        figure
        I=imread('image.tif',layer);

        xxx = imcrop(I,[tcentroids(n,1) tcentroids(n,2) 127 127]);
      
        K=K+1;
        filename = sprintf('%s_%d_%s','non_synapse',K,'.png');
        
        
        %imwrite(xxx , filename)
        figure (777)
        imshow(xxx);
        ImCont = adapthisteq(xxx);
        figure
        imshow(ImCont);
        ImBW = im2bw(ImCont,0.22);
        figure
        imshow(ImBW)
        
        %want to rotate the image who that the membrain is in the middle
        %and vessicle on the right.
        %so split the image into 4 and get the average of the 4 corners -
        %TL- top left
        %TR - top right
        %BL - bottom left
        %BR - bottom right
        %then preform rotations based on who has the lowest average value
        %(lower results in more black/dark error - suggests vessicles
        
        TL= ImBW(1:64,1:64);
        TLM = mean2(TL)
  
        TR= ImBW(1:64,64:128);
        TRM = mean2(TR)
        
        BL= ImBW(64:128,1:64);
        BLM = mean2(BL)
        
        BR= ImBW(64:128,64:128);
        BRM = mean2(BR)
        
%         
%         figure(11)
%         imshow(TL)
%         figure(12)
%         imshow(TR)
%         figure(13)
%         imshow(BL)
%         figure(14)
%         imshow(BR)
%         
        pixel_four = [TLM TRM BLM BRM]
        minpixel = min(pixel_four)
        
       if (minpixel == TLM)
           if (TRM<BLM)
               xxx= imrotate (xxx, -90);
           else
               xxx=imrotate (xxx, 180);
           end
       end
       
       if (minpixel == TRM)
           if (TLM<BRM)
               imrotate (xxx, -90)
           else
    
           end
       end
       
       if (minpixel == BLM)
           if (TLM<BRM)
               xxx=imrotate (xxx, -180);
           else
               xxx=imrotate (xxx, 90)  ;
           end
       end
       
       if (minpixel == BRM)
           if (BLM<TRM)
               xxx=imrotate (xxx, 90);
           else
               
           end
       end
        
       
       figure (8888)
       imshow(xxx);
       
       % save image to be process/tested
       imwrite(xxx , filename)
    end
    end
end



        