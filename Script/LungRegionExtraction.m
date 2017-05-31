function LRE = LungRegionExtraction(Im)
% Lung Region Extraction Algorithm
% Input
%    Im  -  lung image
% Output
%    LRE is a struct array storing the each step result
%    LRE.bitplane  -  bitplane slicing
%    LRE.ero       -  erosion
%    LRE.median    -  median filter
%    LRE.dil       -  dilation
%    LRE.outline   -  outline
%    LRE.border    -  lung border
%    LRE.floodfill -  flood filling
%    LRE.extract   -  lung extract result

[width, height] = size(Im);

% Bit plane slicing
% ------------- Select the optimal bitplane ------------- %
B5 = logical(bitget(Im, 5));
B6 = logical(bitget(Im, 6));
B7 = logical(bitget(Im, 7));
B8 = logical(bitget(Im, 8));

R1 = B7 + B8;
R2 = B7 + B6;
R3 = ~xor(B6, B7);
R4 = B7;
R5 = B5 + B6;

P1 = Ratio(R1);
P2 = Ratio(R2);
P3 = Ratio(R3);
P4 = Ratio(R4);
P5 = Ratio(R5);
P = [P1, P2, P3, P4, P5];
RI = {R1, R2, R3, R4, R5};
RII = {};

Threshold = 0.88;

S = [];
for i = 1 : 5
    if P(i) < Threshold
        S(end+1) = Score(RI{i});
        RII{end+1} = RI{i};
    end
end

% none of the bitplane result meets
% the ratio and score condition
if isempty(S)
    return;
end

[~, k] = min(S);
% R = RII{k};

bitplane = RII{k};
LRE.bitplane = bitplane;
% ------------- Select the optimal bitplane ------------- %

% Erosion
se = strel('sphere', 2);
imEro = imerode(bitplane, se);
LRE.ero = imEro;

% Median filter
imMedian = medfilt2(bitplane);
LRE.median = imMedian;

% Dialation
imDil = imdilate(imMedian, se);
LRE.dil = imDil;

% ------------- Outlining algorithm ------------- %
imOutline = zeros(width, height);
imLungBorder = zeros(width, height);
[B, L, N] = bwboundaries(imDil);

% draw the outline of the whole image
for k = 1 : numel(B)
    boundary = B{k};
    [numOfPoints, ~] = size(boundary);
    for q = 1 : numOfPoints
        y = boundary(q, 2);
        x = boundary(q, 1);
        imOutline(x, y) = 1;
    end
end
LRE.outline = imOutline;

pointNum = [];
boundSet = {};
threshold = 270;
for k = 1 : length(B),
    [numOfPoints, ~] = size(B{k});
    if numOfPoints < threshold
        continue;
    end
    
    % filter the region touching image boundary
    flag = 0;
    boundary = B{k};
    for q = 1 : numOfPoints
        x = boundary(q, 1);
        y = boundary(q, 2);
        if x <= 12 || y <= 12 || x >= width-12 || y >= height-12
            flag = 1;
            break;
        end
    end
    
    if flag == 1
        continue;
    end
    
    % filter flat region
    wt = 60;
    w1 = max(boundary(:,1)) - min(boundary(:,1));
    w2 = max(boundary(:,2)) - min(boundary(:,2));
    if w1 < wt || w2 < wt
        continue;
    end
    
    boundSet{end+1} = B{k};
    pointNum(end+1) = numOfPoints;
end

% filter the big circle contain two lung region
flag = 0;
for k = 1 : numel(boundSet)
    
    min_left  =  min(boundSet{k}(:,2));
    max_right =  max(boundSet{k}(:,2));
    min_up    =  min(boundSet{k}(:,1));
    max_down  =  max(boundSet{k}(:,1));
    
    for i = 1 : numel(boundSet)
        if i == k
            continue;
        end
        
        min_l = min(boundSet{i}(:,2));
        max_r = max(boundSet{i}(:,2));
        min_u = min(boundSet{i}(:,1));
        max_d = max(boundSet{i}(:,1));
        if min_l > min_left && max_r < max_right &&...
                min_u > min_up && max_d < max_down
            flag = 1;
            break;
        end
    end
    
    if flag == 1
        ind = k;
        break;
    end
end

if flag == 1
    boundSet(ind) = [];
end

% draw the outline of the lung region
for k = 1 : numel(boundSet)
    boundary = boundSet{k};
    [numOfPoints, ~] = size(boundary);
    for q = 1 : numOfPoints
        y = boundary(q, 2);
        x = boundary(q, 1);
        imLungBorder(x, y) = 1;
    end
end

imLungBorder = double(255 * im2bw(imLungBorder));
LRE.border = imLungBorder;
% ------------- Outlining algorithm ------------- %

% Flood Filling Algorithm
se = strel('sphere', 8);
imFloodFilling = im2bw(imfill(imLungBorder));
imFloodFilling = imerode(imFloodFilling, se);
se = strel('sphere', 4);
imFloodFilling = imdilate(imFloodFilling, se);
LRE.floodfill = imFloodFilling;

% Extract lung region
imLungExtract = uint8(imFloodFilling) .* Im;
LRE.extract = imLungExtract;

    % Calculate a score for an image according its quality
    function score = Score(Im)
        
        [w, h] = size(Im);
        
        count = 0;
        all = 0;
        r2 = (h/2 - 1)^2;
        Cx = w/2; Cy = h/2;
        
        % denoi = wiener2(Im, [5, 5]);
        Edge = edge(Im, 'canny');
        
        X1 = 105; X2 = 420;
        Y1 = 100; Y2 = 210; Y3 = 310; Y4 = 420;
        % UpX = 125; DownX = 450;
        
        for x = 1 : w
            for y = 1 : h
                dist = (x - Cx)^2 + (y - Cy)^2;
                if dist > r2
                    continue;
                end
                
                all = all + 1;
                if Edge(x, y) == 1
                    if (x > X1 && x < X2 && y > Y1 && y < Y2) ||...
                            (x > X1 && x < X2 && y > Y3 && y < Y4)
                        count = count + 0.25;
                    else
                        count = count + 1;
                    end
                end
            end
        end
        
        score = count / all;
    end

    % Calculate dark percentage of an image
    function percentage = Ratio(Im)
        counter = 0;
        cAll = 0;
        radius = 240;
        r2 = radius * radius;
        
        [w, h] = size(Im);
        UpX = 110;
        DownX = 425;
        Cx = w/2; Cy = h/2;
        for x = UpX : DownX
            for y = Cy - radius : Cy + radius
                dist = (x - Cx) * (x - Cx) + (y - Cy) * (y - Cy);
                if dist > r2
                    continue;
                else
                    cAll = cAll + 1;
                    if Im(x, y) == 0
                        counter = counter + 1;
                    end
                end
            end
        end
        
        percentage = counter / cAll;
        if percentage < 0.5
            percentage = 1 - percentage;
        end
    end
end