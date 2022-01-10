clear all

tic
digitalDatasetPath =fullfile('E:\cnn_researchWork\orient_p15'); %%Folder path with different classes subfolder
imds = imageDatastore(digitalDatasetPath,'IncludeSubfolders',true,'LabelSource','foldernames');
imdsrand = shuffle(imds); %shuffle data
numTrainingFiles = floor(numel(imdsrand.Files)*0.2);
[imdsTest,imdsTrain] = splitEachLabel(imdsrand,numTrainingFiles,'randomize');

% % Find the first instance of an image for each category
% orig = find(imds.Labels == 'orig_log', 1);
% recap = find(imds.Labels == 'recap_log', 1);
% 
% figure;
% subplot(121),imshow(readimage(imdsrand,orig))
% subplot(122),imshow(readimage(imdsrand,recap))

%tbl = countEachLabel(imdsrand);

%% %CNN feature extraction architerture
layers = [
    imageInputLayer([512 512 1]) 
   

    convolution2dLayer(5,16,'Stride',1)% layer 2
    batchNormalizationLayer
    % swishLayer
    reluLayer
    %eluLayer
    %leakyReluLayer
    averagePooling2dLayer(5,'Stride',2)

   convolution2dLayer(5,32,'Stride',1)% layer 6
    batchNormalizationLayer
    % swishLayer
    reluLayer
    %eluLayer
    %leakyReluLayer
    averagePooling2dLayer(5,'Stride',2)
  
   convolution2dLayer(5,64,'Stride',1)% layer 10
    batchNormalizationLayer
    % swishLayer
    reluLayer
    %eluLayer
    %leakyReluLayer
    averagePooling2dLayer(5,'Stride',2)
    
   convolution2dLayer(5,128,'Stride',1)% layer 14
    batchNormalizationLayer
    % swishLayer
    reluLayer
    %eluLayer
    %leakyReluLayer
    averagePooling2dLayer(5,'Stride',2)
    
    convolution2dLayer(5,256,'Stride',1)% layer 18
    batchNormalizationLayer
    % swishLayer
    reluLayer
    %eluLayer
    %leakyReluLayer
    averagePooling2dLayer(5,'Stride',2)
    
    dropoutLayer(0.2)
    fullyConnectedLayer(2)
    softmaxLayer
    classificationLayer];



% Set the network training options
options = trainingOptions('sgdm', ...
    'Momentum', 0.9, ...
    'InitialLearnRate', 0.001, ...
    'LearnRateSchedule', 'piecewise', ...
    'LearnRateDropFactor', 0.1, ...
    'LearnRateDropPeriod', 8, ...
    'L2Regularization', 0.004, ...
    'MaxEpochs', 10, ...
    'Shuffle','every-epoch', ...
    'ValidationData',imdsTest, ...
    'ValidationFrequency',30, ...
    'MiniBatchSize', 50, ...
    'Verbose', true,...
    'Plots','training-progress');

%training of network
net = trainNetwork(imdsTrain,layers,options);
analyzeNetwork(net)
%% %convolutional filters extraction
layer = 10;
name = net.Layers(layer).Name;
channels = 1:32;
I = deepDreamImage(net,name,channels, ...
    'PyramidLevels',1);
figure
montage(I, 'Size', [4 8]);
imshow(I)
title('Convolution Layer 1 Filter Output')
%%
%testing of network using ANN
YPred = classify(net,imdsTest);
YTest = imdsTest.Labels;

%confusion matrix
plotconfusion(YTest,YPred)

% %accuracy calculation
 accuracy = sum(YPred == YTest)/numel(YTest)
 
 toc
 
 %% %testing using SVM linear classifier
 
 
 inputSize = net.Layers(1).InputSize;
 augimdsTrain = augmentedImageDatastore(inputSize(1:2),imdsTrain);
augimdsTest = augmentedImageDatastore(inputSize(1:2),imdsTest);
 layer = 'avgpool2d_5';
trainingFeatures = activations(net,augimdsTrain,layer,'OutputAs','rows');
testFeatures = activations(net,augimdsTest,layer,'OutputAs','rows');

trainingLabels = imdsTrain.Labels;
testingLabels = imdsTest.Labels;

 t = templateSVM('KernelFunction','linear'); %'gaussian' or 'rbf' , 'linear', 'polynomial'
 
 classifier = fitcecoc(trainingFeatures, trainingLabels, ...
    'Learners', t);
YPred = predict(classifier,testFeatures);
idx = [1 5 10 15];
% figure
% for i = 1:numel(idx)
%     subplot(2,2,i)
%     I = readimage(imdsTest,idx(i));
%     label = YPred(idx(i));
%     imshow(I)
%     title(char(label))
% end
accuracy = mean(YPred == testingLabels)

%% %size checking
inputSize = [64,64];
auimds = augmentedImageDatastore(inputSize,imds,'OutputSizeMode','centercrop');

