% Feature Extract Algorithm
function FE = FeatureExtract(Im)
% Input
%    Im  -  lung extraction image
% Output
%    FE.feamap  -  M by 3 feature map
%    FE.color_im  -  colored clustered result image
%    FE.color_slim_im  -  colored clustered result after feature selection

% Output feature map M by 3
featureMap = [];

% Input data init
bandwidth = 13;
[width, height] = size(Im);

% Determine binary gray image level
T1 = 8; T2 = 300;
level = [0.21, 0.31, 0.40, 0.55];
Ne = []; Le = [];
for i = 1 : 4
    BW = im2bw(Im, level(i));
    [~, ~, Ni] = bwboundaries(BW, 'noholes');
    % i, Ni
    if Ni < T1 || Ni > T2
        continue;
    else
        Ne(end+1) = Ni;
        Le(end+1) = level(i);
    end
end

% Determine whether the result is empty
if isempty(Ne)
    FE = [];
    return;
end

% Select the optimal result
[~, ind] = max(Ne);
BW = im2bw(Im, Le(ind));

[clustCent, clustMembsCell] = NoduleCandidate(BW, bandwidth);

numClust = length(clustMembsCell);

% Color clustered feature vectors
imColorClusters = cat(3, Im, Im, Im);
Colors = hsv(numClust);

for k = 1 : numClust
    myMembers = clustMembsCell{k};
    myClustCen = clustCent(:,k);
    [L, ~] = size(myMembers);
    
    Color = Colors(k, :);
    
    for i = 1 : L
        
        x = myMembers(i, 1);
        y = myMembers(i, 2);
        imColorClusters(x, y, :) = 255 * Color;
    end
    
    imColorClusters = insertText(imColorClusters, ...
        [myClustCen(2) myClustCen(1)], k, 'BoxOpacity', 0, 'TextColor', 'white');
end

FE.color_im = imColorClusters;
% imshow(imColorClusters);

% Cluster index
ind = [];

% Region Area Vector
area = [];
T1 = 15;

% MDC vector
mdc = [];
T2 = 3;

% Mean intensity vector
meanIntensity = [];

for k = 1 : numClust
    myMembers = clustMembsCell{k};
    myClustCen = clustCent(:,k);
    [L, ~] = size(myMembers);

    % ------------------Area of Candidate Region------------------ %
    if L <= T1
        continue;
    end
    % ------------------Area of Candidate Region------------------ %

    % ------------------MDC------------------ %
    maxRadius = 1;
    isContain = zeros(width, height);
    for i = 1 : L
        isContain(myMembers(i, 1), myMembers(i, 2)) = 1;
    end

    for i = 1 : L
        radius = 1;
        isMaxCircle = 0;
        xCenter = myMembers(i, 1);
        yCenter = myMembers(i, 2);

        while isMaxCircle == 0
            for x = xCenter - radius : xCenter + radius
                % End for loop condition
                if isMaxCircle == 1
                    break;
                end

                for y = yCenter - radius : yCenter + radius
                    % End for loop condition
                    if isContain(x, y) == 0
                        isMaxCircle = 1;
                        break;
                    else
                        dist = (x - xCenter)^2 + (y - yCenter)^2;
                        dist = dist^(1/2);
                        if dist <= radius
                            continue;
                        end
                    end
                end
            end

            % Increase maximum circle radius
            radius = radius + 1;
        end

        if radius - 1 > maxRadius
            maxRadius = radius;
        end
    end

    % Add an radius value
    if maxRadius < T2
        continue;
    else
        mdc = [mdc, maxRadius];
        area = [area, L];
        % index = [index, k];
        % candidateCount = candidateCount + 1;
    end
    % ----------------- MDC ----------------- %

    % ----------------- Mean Intensity of Candidate Region ----------------- %
    sumUp = 0;
    for i = 1 : L
        intensity = Im(myMembers(i, 1), myMembers(i, 2));
        sumUp = sumUp + double(intensity);
    end
    mean = sumUp / L;
    meanIntensity(end+1) = mean;
    % ----------------- Mean Intensity of Candidate Region ----------------- %
    
    ind(end+1) = k;
end

% Color clustered feature vectors
numClust = numel(ind);
imSlimColorClusters = cat(3, Im, Im, Im);
Colors = hsv(numClust);

for k = 1 : numClust
    myMembers = clustMembsCell{ind(k)};
    myClustCen = clustCent(:,ind(k));
    [L, ~] = size(myMembers);
    
    Color = Colors(k, :);
    
    for i = 1 : L
        
        x = myMembers(i, 1);
        y = myMembers(i, 2);
        imSlimColorClusters(x, y, :) = 255 * Color;
    end
    
    imSlimColorClusters = insertText(imSlimColorClusters, ...
        [myClustCen(2) myClustCen(1)], k, 'BoxOpacity', 0, 'TextColor', 'white');
end

% Store the slimed coloring clusters result in FE
FE.color_slim_im = imSlimColorClusters;

[~, L] = size(area);
for i = 1 : L
    featureMap(end+1,:) = [area(i), mdc(i), meanIntensity(i)];
end
% Store the feature map in FE
FE.feamap = featureMap;