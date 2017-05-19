clear;clc
load('meta.mat');
load('testData.mat');
load('trainData.mat');

xTrainImages = trainImages;
tTrain = trainLabels;

rng('default') % set the random number generator seed
hiddenSize1 = 200; % set the number of hidden nodes in Layer 1
autoenc1 = trainAutoencoder(xTrainImages,hiddenSize1, ...
 'MaxEpochs',400, ...
 'L2WeightRegularization',0.004, ...
 'SparsityRegularization',4, ...
 'SparsityProportion',0.15, ...
 'ScaleData', false);
plotWeights(autoenc1);

feat1 = encode(autoenc1,xTrainImages);
hiddenSize2 = 100; % set the number of hidden nodes in Layer 2
autoenc2 = trainAutoencoder(feat1,hiddenSize2, ...
 'MaxEpochs',400, ...
 'L2WeightRegularization',0.002, ...
 'SparsityRegularization',4, ...
 'SparsityProportion',0.1, ...
 'ScaleData', false);

feat2 = encode(autoenc2,feat1);
softnet = trainSoftmaxLayer(feat2,tTrain,'MaxEpochs',100);
deepnet = stack(autoenc1,autoenc2,softnet); % stack all layers
view(deepnet)

% Load the test images
xTestImages = testImages;
tTest = testLabels;

y = deepnet(xTestImages);
figure
plotconfusion(tTest,y);
% Perform fine tuning
deepnet = train(deepnet,xTrainImages,tTrain);
y = deepnet(xTestImages);
figure
plotconfusion(tTest,y);