%Final Function for predicting an entire tiff stack, the output of this is
%what we will get the F1 score from
clear
addpath('validate')
addpath('F1Score')
Test = tif_to_matrix('image.tif');
Truth = tif_to_matrix('synapse.tif');
Layer = 1;
LayerMax = size(Test,3);

for Layer = 1:LayerMax
    PrevLayer = Layer-1;
    NextLayer = Layer+1;
    PrevPrevLayer = Layer-2;
    NextNextLayer = Layer+2;
    if (Layer-1)<=0
        PrevLayer = Layer;
    end
    if (Layer+1)>=LayerMax
        NextLayer = Layer;
    end
    if (Layer-2)<=0
        PrevPrevLayer = PrevLayer;
    end
    if (Layer+2)>=LayerMax
        NextNextLayer = NextLayer;
    end
    
    Prediction = im2bw(SecondStage(Layer,'validate')+SecondStage(PrevLayer,'validate')+SecondStage(NextLayer,'validate')+SecondStage(PrevPrevLayer,'validate')+SecondStage(NextNextLayer,'validate'));
    imwrite(Prediction,'mine.tif');
    ThisResult = Tester('validate',Layer);
    result(:,:,Layer) = ThisResult;
    Layer
end

%Build Stack then get F1 score
WritetoTif(result);
F1 = sos_evaluate_F1_tiff( '/validate/synapse.tif', 'result.tif');
F1

