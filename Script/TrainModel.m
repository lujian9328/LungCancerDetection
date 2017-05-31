% Training Model
function TrainModel

labelFileName = '../Data/stage1_labels.csv';
solFileName = '../Data/stage1_solution.csv';
lreDir = '../Data/lung_region_extraction/';
sampDir = '../Data/sample_data/';

directoryInfo = dir(lreDir);
[numOfSamples, ~] = size(directoryInfo);

% Train data
labelTable = readtable(labelFileName, 'Delimiter',',', 'Format', '%s %f');
pidSet = labelTable{:, {'id'}};
labelSet = labelTable{:, {'cancer'}};

mapObj = containers.Map(pidSet, labelSet);

% Test data
labelTable = readtable(solFileName, 'Delimiter',',', 'Format', '%s %f %s');
pidSet = labelTable{:, {'id'}};
labelSet = labelTable{:, {'cancer'}};

mapObj2 = containers.Map(pidSet, labelSet);

% Train input vector
sampleX = [];
% Train label vector
sampleY = [];

% Test input vector
testX = [];
% Test label vector
testY = [];

% Write down the patient can't generate feature
uncertainId = {};

tic
t1 = clock;
for ki = 4 : numOfSamples
    % determine whether the patient in the list
    patientId = directoryInfo(ki).name;
    tf = isKey(mapObj, patientId);
    
    path = [lreDir, patientId, '/'];
    scanInfo = dir([path, '*.bmp']);
    [numOfScans, ~] = size(scanInfo);
    
    % Create folder for saving the bmp scan slices
    % newPath = [feaDir, patientId, '/'];
    % if exist(newPath, 'dir') == 0
    %     system(['mkdir ', newPath]);
    % end
    
    featureMatrix = [];
    for pi = 1 : numOfScans
        scanFullName = scanInfo(pi).name;
        image8 = imread([path, scanFullName]);
        
        % subplot(1, 2, 1);
        % imshow(image8);
        
        % ----------- DETERMINE BINARY IMAGE LEVEL TEST ----------- %
        % T1 = 8; T2 = 300;
        % level = [0.21, 0.31, 0.40, 0.55];
        % Ne = []; Le = [];
        % for i = 1 : 4
        %    BW = im2bw(image8, level(i));
        %    [~, ~, Ni] = bwboundaries(BW, 'noholes');
        
        %    if Ni < T1 || Ni > T2
        %        continue;
        %    else
        %        Ne(end+1) = Ni;
        %        Le(end+1) = level(i);
        %    end
        % end
        
        % Determine whether the result is empty
        % if isempty(Ne)
        %     continue;
        % end
        
        % Select the optimal result
        % [~, ind] = max(Ne);
        % BW = im2bw(image8, Le(ind));
        % for i = 1 : 4
        %     BWi = im2bw(image8, level(i));
        %     subplot(3, 2, i);
        %     imshow(BWi);
        % end
        
        % subplot(3, 2, 6);
        % imshow(BW);
        
        % subplot(1, 2, 2);
        % imshow(BW);
        
        % continue;
        
        % imwrite(BW, [newPath, scanFullName, '_bw.bmp']);
        % ----------- DETERMINE BINARY IMAGE LEVEL TEST ----------- %
        
        FE = FeatureExtractV2(image8);
        if ~isempty(FE)
            feaMap = FE.feamap;
            featureMatrix = [featureMatrix(1:end,1:end); feaMap];
        end
    end
    
    if isempty(featureMatrix)
        uncertainId{end+1} = patientId;
        continue;
    else
        featureVec = GeneFeatureVec(featureMatrix);
    end
    
    % Contruct training matrix
    if tf == 1
        sampleX(end+1, :) = featureVec;
        sampleY(end+1, 1) = mapObj(patientId);
    else
        testX(end+1, :) = featureVec;
        testY(end+1, 1) = mapObj2(patientId);
    end
    
    msg = sprintf('process %d patients: %0.1f sec', ki - 3, etime(clock, t1));
    disp(msg);
end

% SVMModel = fitcsvm(sampleX, sampleY);

% save training data and training model into file system
save([sampDir, 'trainV3.mat'], 'sampleX', 'sampleY',...
    'testX', 'testY', 'uncertainId', '-append');

disp('finish feature extraction');
msg = sprintf('feature extraction takes time %0.1f sec', etime(clock, t1));
disp(msg);

% [label, score] = predict(SVMModel, testX);

    function feaVec = GeneFeatureVec(feaMat)
        [L, ~] = size(feaMat);
        feaVec = [];
        
        % Generate a feature vector for a patient
        pickCount = 30;
        
        % Extract 30 candidate features according to MDC value
        mdc = feaMat(:, 2);
        [~, ind] = sort(mdc, 'descend');
        
        % Smaller than 30 candidates
        if L < pickCount
            m1 = mean(feaMat);
            for i = 1 : pickCount
                feaVec(1, end+1:end+3) = m1;
            end
        % More than 30 candidates
        else
            feaMat = feaMat(ind(1:pickCount), :);
            
            for i = 1 : pickCount
                feaVec(1, end+1:end+3) = feaMat(i, :);
            end
        end
        
    end
end