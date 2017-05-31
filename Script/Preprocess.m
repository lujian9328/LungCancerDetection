% Script for preprocess the dcm image library
directory = '../Data/stage1/';
preprocessDir = '../Data/sample_preprocess/';
directoryInfo = dir(directory);
[numOfSamples, ~] = size(directoryInfo);

tic
t1 = clock;
for ki = 4 : numOfSamples
    patientId = directoryInfo(ki).name;
    path = [directory, patientId, '/'];
    dcmInfo = dir([path, '*.dcm']);
    [numOfScans, ~] = size(dcmInfo);
    
    % Create folder for saving the bmp scan slices
    newPath = [preprocessDir, patientId];
    if exist(newPath, 'dir') == 0
        system(['mkdir ', newPath]);
    end
    
    % Preprocess the dcm scans of each patient
    mapObj = containers.Map;
    numOfCandidate = 10;
    minDarkPtg = 1;
    candidateId = zeros(1, numOfCandidate);
    removeId = 0;
    pick = 0;
    
    t2 = clock;
    for pi = 1 : numOfScans
        scanFullName = dcmInfo(pi).name;
        scanId = scanFullName(1:end-4);

        % Calculate the dark pixels percentage
        [Y, ~] = dicomread([path, scanFullName]);
        image8 = uint8(255 * mat2gray(Y));
        [w, ~] = size(image8);
        MIN = min(image8(50:w-50,w/2));

        % Interested lung region
        REC_W = 140;
        REC_H = 93;
        X1 = 230;
        Y1 = 129;
        Y2 = 293;
        IM1 = double(image8(X1:X1 + REC_W, Y1:Y1 + REC_H,:));
        IM2 = double(image8(X1:X1 + REC_W, Y2:Y2 + REC_H,:));

        % imshow(image8);
        
        % Count dark pixels and calculate its ratio
        [rec_w, rec_h] = size(IM1);
        [w, h] = size(image8);
        darkValues = 0;
        threshold = MIN + 10;

        for i = 1 : rec_w
            for j = 1 : rec_h
                
                if IM1(i, j) < threshold
                    darkValues = darkValues + 1;
                end
                
                if IM2(i, j) < threshold
                    darkValues = darkValues + 1;
                end
            end
        end
        darkPercentage = darkValues / (2 * rec_w * rec_h);
        % darkPercentage
        
        % Not a candidate slice 
        if darkPercentage == 0
            continue;
        end

        % Initialize a map maintains (scanId, darkPercentage)
        pick = pick + 1;
        if pick <= numOfCandidate
        	mapObj(scanId) = darkPercentage;
        	continue;
        end
        
        % Find the minimum dark percentage value
        if pick == numOfCandidate + 1
            darkPtgs = cell2mat(values(mapObj));
            [allValues, index] = sort(darkPtgs);
            minDarkPtg = allValues(1);
            continue;
        end

        % Find a new candidate image
        if darkPercentage > minDarkPtg
        	allScanIds = keys(mapObj);
        	removeId = cell2mat(allScanIds(index(1)));
        	remove(mapObj, removeId);  % Remove the old minimum dark percentage scanId
        	mapObj(scanId) = darkPercentage;  % Insert new scanId

        	% Update minDarkPtg value
        	darkPtgs = cell2mat(values(mapObj));
            [allValues, index] = sort(darkPtgs);
            minDarkPtg = allValues(1);
      	end
    end
    
    if numOfScans == 0
        continue;
    end
    
    % Output the selected scanId image
    allScanIds = keys(mapObj);
    for pi = 1 : numOfCandidate
    	scanId = cell2mat(allScanIds(pi));
    	scanFullName = [scanId, '.dcm'];
    	[Y, MAP] = dicomread([path, scanFullName]);
        image8 = uint8(255 * mat2gray(Y));
        
        % process image quality difference problem
        [width, height] = size(image8);
        fillValue = image8(5, 256);
        for i = 1 : width
           for j = 1 : height
                Y = (i - 256) * (i - 256) + (j - 256) * (j - 256);
                if Y > 255 * 255
                    image8(i, j) = fillValue;
                end
            end
        end
        
        imwrite(image8, [newPath, '/', scanId, '.bmp']);
    end
    disp(['preprocess ', num2str(ki-3), ' patient: ', num2str(etime(clock, t1)), ' sec']);
end

disp('finish preprocess');
disp(['preprocess time: ', num2str(etime(clock, t1))]);