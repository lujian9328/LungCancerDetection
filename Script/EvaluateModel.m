% Evaluate Model Script
sampDir = '../Data/sample_data/';
filename = 'trainV3.mat';

% load ... training data and training model into file system
T = load([sampDir, filename]);

% Load training set
Xtrain = T.sampleX;
Ytrain = T.sampleY;

% Load test set
Xtest = T.testX; 
Ytest = T.testY;

tic
t1 = clock;

% ----------- SVM Classification ----------- %
% SVMModel = fitcsvm(Xtrain,Ytrain,'Standardize',true,...
%     'KernelFunction','RBF',...
%     'KernelScale','auto');

% [label, score] = koldPredict(SVMModel);
% [label, score] = predict(SVMModel, Xtest);

% CVSVMModel = crossval(SVMModel);

% Estimate the out-of-sample misclassification rate.
% classLoss = kfoldLoss(CVSVMModel)

% estimate posterior probabilities rather than scores
% ScoreSVMModel = fitPosterior(SVMModel, Xtrain, Ytrain);

% [label, score] = predict(ScoreSVMModel, Xtest);
% ----------- SVM Classification ----------- %


% ----------- Random Forest Classification ----------- %
% RFMdl = TreeBagger(50, Xtrain, Ytrain, 'Method', 'classification',...
%     'InBagFraction', 0.8, 'SampleWithReplacement', 'off');

% Calculate posterior probabilities
[~, posterior] = predict(RFMdl, testX);

% Calculate test set label
% [label, score] = predict(RFMdl, Xtest);
% ----------- Random Forest Classification ----------- %

% ----------- Random Forest Cross Validation ----------- %
bag = fitensemble(Xtrain,Ytrain,'Bag',200,'Tree',...
    'Type','Classification');
cv = fitensemble(Xtrain,Ytrain,'Bag',200,'Tree',...
    'type','classification','kfold',10);
[yFit, sFit] = kfoldPredict(cv);

figure;
plot(loss(bag,Xtest,Ytest,'mode','cumulative'));
hold on;
plot(kfoldLoss(cv,'mode','cumulative'),'r.');
plot(oobLoss(bag,'mode','cumulative'),'k--');
hold off;
xlabel('Number of trees');
ylabel('Classification error');
legend('Test','Cross-validation','Out of bag','Location','NE');
% ----------- Random Forest Cross Validation ----------- %

msg = sprintf('Train Mdl takes %0.1f sec', etime(clock, t1));
disp(msg);

% CP = classperf(Ytest, label);
CP = classperf(Ytrain, yFit);
% CP = classperf(Ytest, cellfun(@str2num, label(1:end)));
CP.CorrectRate

% Save the model
% save([sampDir, filename],'RFMdl','-append');